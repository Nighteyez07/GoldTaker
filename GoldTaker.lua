local frame, events = CreateFrame("Frame"), {};
local deletedelay, t = 0.5, 0
local openAll, openMail, stopOpening, onEvent, totalCollected, attempt, playerMoney, copperTotal, playerMoneyTotal, currentMailCount;
local _G = _G
local limit = 0
local debug = false
local mailBoxOpen = false
local isRunning = false

-- EVENT REGISTRATIONS
function events:ADDON_LOADED()
  playerMoneyTotal = GetMoney();
end

function events:PLAYER_MONEY()
  if mailBoxOpen and isRunning then
    copperTotal = GetMoney() - playerMoneyTotal;
    playerMoneyTotal = GetMoney(); -- update current total
    totalCollected = totalCollected + copperTotal;

    print(("GoldTaker: Collected %dg %ds %dc"):format(copperTotal / 100 / 100, (copperTotal / 100) % 100, copperTotal % 100));
  end
end

function events:MAIL_SHOW()
  mailBoxOpen = true;
  CheckInbox();
	print("GoldTaker ready, /goldtaker or /gt to get started");
  totalCollected = 0;
end

function events:MAIL_CLOSED()
  mailBoxOpen = false;
  isRunning = false;
  totalCollected = 0;
end

-- ATTACH EVENTS
frame:SetScript("OnEvent", function(self, event, ...)
  events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
  frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end

--
function preFlightCheck()
  local hasGoldRecordsToLoot = false;
  currentMailCount = GetInboxNumItems();

  for i = currentMailCount, 1, -1 do
    local invoiceType, _, _, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(i);

    if invoiceType == "seller" and math.floor((buyout + deposit - consignment) / 10000) <= limit then
      hasGoldRecordsToLoot = true;
      break;
    end
  end

  return hasGoldRecordsToLoot;
end

function openAll()
  if preFlightCheck() == true then
    print(("GoldTaker: Retrieving sales %dg or less"):format(limit))
    isRunning = true;
    attempt = 0;
    openMail(currentMailCount);
  else
    print(("GoldTaker: nothing to loot, no mail with %dg or less"):format(limit));
    return;
  end
end

function openMail(index)
  if index <= 0 then return stopOpening(); end
  
  local invoiceType, itemName, buyer, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(index)
	local _, _, sender, subject, money, codAmount = GetInboxHeaderInfo(index)
  
  dPrint("Open mail at index = " .. index);

  if invoiceType == "seller" and buyer and buyer ~= "" then -- AH Sales
    local total = floor((bid - ahcut) / 10000); --only handle in gold amounts
    if total <= limit and attempt < 5 then
      TakeInboxMoney(index);
      
      C_Timer.After(0.2, function() 
        local invoiceTypeCheck = GetInboxInvoiceInfo(index);
        if invoiceTypeCheck == nill then
          attempt = 0;
          openMail(index-1);
        else
          attempt = attempt + 1;
          openMail(index);
        end
      end);
    else
      attempt = 0;
      return openMail(index-1);  
    end  
  else
    attempt = 0;
    return openMail(index-1);
	end
end

function stopOpening()
  isRunning = false;
  if totalCollected > 0 then
    print(("GoldTaker: Total Collected %dg %ds %dc"):format(totalCollected / 100 / 100, (totalCollected / 100) % 100, totalCollected % 100));
  else
    print("GoldTaker finished, nothing collected");
  end
  do return end
end

SLASH_GOLDTAKER1, SLASH_GOLDTAKER2 = '/goldtaker', '/gt';
local function handler(msg, editBox)
  slashArguments(msg);
end
SlashCmdList["GOLDTAKER"] = handler;

function dPrint(str)
  if str == nil then
    return;
  end

  if debug then
    print("GoldTaker DEBUG:: " .. str);
  end
end

function slashArguments(msg)
  --if handle more statements, then swap to better way to run this
  if msg == "" then
    print("GoldTaker: No valid command found");
  elseif tonumber(msg) then 
    limit = tonumber(msg);
    
    if mailBoxOpen == false then
      print("Mailbox must be open to retrieve gold");
      return stopOpening();
    elseif limit <= 0 then
      print("Limit must be a number, like '/gt 500'");
      return stopOpening();
    else
      totalCollected = 0;
      openAll();
    end
  elseif string.lower(msg) == "debug" then
    debug = not debug;
    print(debug);
  else
    print("GoldTaker: '" .. msg .. "' is not a valid command");
  end
end