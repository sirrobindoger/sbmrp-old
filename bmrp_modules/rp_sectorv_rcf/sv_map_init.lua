--[[-------------------------------------------------------------------------
Map init/cleanup handler
---------------------------------------------------------------------------]]

local function mapinit()

	local xenelevator = ents.GetMapCreatedEntity(4781)

	xenelevator:SetKeyValue("noise1","plats/elevator_start1.wav")
	xenelevator:SetKeyValue("noise2","plats/talkmove2.wav")
	xenelevator:SetKeyValue("startclosesound", Sound("plats/railstop1.wav"))

end




sBMRP.MapHook("map_init", mapinit)
