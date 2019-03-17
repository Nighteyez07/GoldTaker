_G["GoldTaker"] = GoldTaker
print("GoldTaker Loaded")

GoldTaker:RegisterEvent("MAIL_SHOW")

function GoldTaker:MAIL_SHOW()
	GoldTaker.Print("GoldTaker ready and waiting")
	print("GoldTaker ready and waiting")
end


function GoldTaker:slash(arg)
	
end
