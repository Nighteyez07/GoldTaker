local frame, events = CreateFrame("Frame"), {};
local deletedelay, t = 0.5, 0
local button2, waitForMail, doNothing, openAll, openMail, retryTakeMoney, takeMoney, lastopened, stopOpening, onEvent, totalCollected, attempt
local totalMailCount, currentMailCount
local _G = _G
local limit = 0
local debug = false
local mailBoxOpen = false

function events:ADDON_LOADED()
  print("GoldTaker loaded")
end

function events:MAIL_SHOW()
  mailBoxOpen = true;
  CheckInbox();
	print("GoldTaker ready, /goldtaker or /gt to get started");
  totalCollected = 0;
end

function events:MAIL_CLOSED()
	mailBoxOpen = false;
  totalCollected = 0;
end

frame:SetScript("OnEvent", function(self, event, ...)
  events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
  frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

function openAll()
  currentMailCount, totalMailCount = GetInboxNumItems()
  if currentMailCount == 0 then return end
  dPrint("totalMailCount = " .. totalMailCount)
  openMail(GetInboxNumItems())
end

function openMail(index)
  if index <= 0 then return stopOpening() end
	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
  local copperTotal = buyout + deposit - consignment;
  local total = math.floor((buyout + deposit - consignment) / 10000); --only handle in gold amounts

  if total <= limit and invoiceType == "seller" then
    attempt = 0
    takeMoney(index) 
  else
    local items = GetInboxNumItems()
    if items > 1 and index < items + 1 then
      return openMail(index-1)
    end
	end

	local items = GetInboxNumItems()
	if items > 1 and index < items + 1 then
		lastopened = index
		t = 0
		frame:SetScript("OnUpdate", waitForMail)
	else
		return stopOpening()
	end
end

function takeMoney(index) 
  local playerMoney = GetMoney()
  dPrint("takeMoney:index = " .. index)
  dPrint("takeMoney:attempt = " .. attempt)

  if attempt < 5 then
    TakeInboxMoney(index)
    --did we loot money
    if playerMoney == GetMoney() then
      dPrint("takeMoney:: no money looted")

      attempt = attempt + 1
      lastopened = index
      t = 0
      dPrint("takeMoney:lastopened = " .. lastopened)

      frame:SetScript("OnUpdate", retryTakeMoney)

      retryTakeMoney() --no idea why this is needed, but without this call then the OnUpdate for this function isn't actually called
    else 
      dPrint("Initial gold = " .. math.floor(playerMoney / 10000) .. " new total is " .. math.floor(GetMoney() / 10000))
      print(("GoldTaker: Collected %dg %ds %dc"):format(copperTotal / 100 / 100, (copperTotal / 100) % 100, copperTotal % 100));
      totalCollected = totalCollected + copperTotal;
      attempt = 5  
    end

    dPrint("takeMoney:: END")
  end
end

function retryTakeMoney(self, elapsed)
  t = t + elapsed
  if t > deletedelay then
    frame:SetScript("OnUpdate", nil)
    takeMoney(lastopened) 
  end
end

function waitForMail(self, elapsed)
	t = t + elapsed
	if t > deletedelay then
		frame:SetScript("OnUpdate", nil)
		openMail(lastopened - 1)
	end
end

function stopOpening()
  if totalCollected > 0 then
    print(("GoldTaker: Total Collected %dg %ds %dc"):format(totalCollected / 100 / 100, (totalCollected / 100) % 100, totalCollected % 100));
  else
    print("GoldTaker finished, nothing collected")
  end
  do return end
end

SLASH_GOLDTAKER1, SLASH_GOLDTAKER2 = '/goldtaker', '/gt';
local function handler(msg, editBox)
  slashArguments(msg)
end
SlashCmdList["GOLDTAKER"] = handler;

function dPrint(str)
  if str == nil then
    return
  end

  if debug then
    print("GoldTaker DEBUG:: " .. str)
  end
end

function slashArguments(msg)
  --if handle more statements, then swap to better way to run this
  if msg == "" then
    print("GoldTaker: No valid command found")
  elseif tonumber(msg) then 
    limit = tonumber(msg);
    
    if mailBoxOpen == false then
      print("Mailbox must be open to retrieve gold")
      return stopOpening()
    elseif limit <= 0 then
      print("Limit must be a number, like '/gt 500'")
      return stopOpening()
    else
      openAll()
    end
  elseif string.lower(msg) == "debug" then
    debug = not debug
    print(debug)
  else
    print("GoldTaker: '" .. msg .. "' is not a valid command")
  end

end

