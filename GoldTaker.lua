local frame, events = CreateFrame("Frame"), {};
local deletedelay, t = 0.5, 0
local mailBoxOpen, button2, waitForMail, doNothing, openAll, openMail, lastopened, stopOpening, onEvent, totalCollected
local _G = _G
local limit = 0

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
  if GetInboxNumItems() == 0 then return end
  openMail(GetInboxNumItems())
end

function openMail(index)
	if index <= 0 then return stopOpening() end
	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
  local copperTotal = buyout + deposit - consignment;
  local total = math.floor((buyout + deposit - consignment) / 10000); --only handle in gold amounts

	if total <= limit then
		TakeInboxMoney(index)
    print(("GoldTaker: Collected %dg %ds %dc"):format(copperTotal / 100 / 100, (copperTotal / 100) % 100, copperTotal % 100));
    totalCollected = totalCollected + copperTotal;
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
  limit = tonumber(msg);
  if limit == nil then
    print("Limit must be a number, like '/gt 500'")
    return stopOpening()
  end
  openAll()
end
SlashCmdList["GOLDTAKER"] = handler;
