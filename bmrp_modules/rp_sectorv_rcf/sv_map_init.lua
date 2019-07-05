--[[-------------------------------------------------------------------------
Map init/cleanup handler
---------------------------------------------------------------------------]]

local function mapinit()

	--[[-------------------------------------------------------------------------
	Sounds
	---------------------------------------------------------------------------]]

	for k,v in pairs({5201, 5198, 5197, 5205}) do
		SafeRemoveEntity(ents.GetMapCreatedEntity(v))
	end
	timer.Create("ambience-sound_fix", 1, 0, function()
		for k,v in pairs(ents.FindByName("amb")) do
			local shouldplay = false
			for k,ply in pairs(ents.FindInSphere(v:GetPos(),1000)) do
				if ply:IsPlayer() then
					shouldplay = true
					break
				end
			end
			if not shouldplay then
				v:Fire("StopSound")
			else
				v:Fire("PlaySound")
			end
		end
	end)
	suitone = ents.Create( "item_hevsuit" )
	suitone:SetPos( Vector(-6565.938965,-74.106972,-292.046753))
	suitone:Spawn()
	suittwo = ents.Create( "item_hevsuit" )
	suittwo:SetPos( Vector( -6565.938965,55.042885,-292.046753) )
	suittwo:Spawn()
	suitthree = ents.Create( "item_hevsuit" )
	suitthree:SetPos( Vector(-6565.922852,182.081421,-292.046753)) 
	suitthree:Spawn()
end
/*
for k,v in pairs(ents.GetAll()) do
	if v:GetPos():WithinAABox(Vector(6196.2192382813,1101.5805664063,173.81211853027),Vector(6443.576171875,814.38983154297,-30.359924316406)) then
		print(v:GetClass() .. " " .. v:MapCreationID())
	end
end*/


sBMRP.MapHook("map_init", mapinit)
