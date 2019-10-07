--[[-------------------------------------------------------------------------
Output base
---------------------------------------------------------------------------]]


sBMRP.AMS.Outcomes = sBMRP.AMS.Outcomes || {}

function sBMRP.CreateAMSOutcome(tab)
	if not tab || not istable(tab) then return end

	if not tab.name and not isstring(tab.name) then
		return error("Name not included!")
	elseif not tab.chance and not isnumber(tab.name) then
		return error("Chance not included!")
	elseif not tab.output and not isfunction(tab.output) then
		return error("Output function not included!")
	end

	sBMRP.AMS.Outcomes[tab.name] = tab
end