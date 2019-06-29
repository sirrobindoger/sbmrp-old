--[[-------------------------------------------------------------------------
Map init/cleanup handler
---------------------------------------------------------------------------]]

local function mapinit()

	--[[-------------------------------------------------------------------------
	Sounds
	---------------------------------------------------------------------------]]

	for k,v in pairs({5201, 5198}) do
		SafeRemoveEntity(ents.GetMapCreatedEntity(v))
	end
	timer.Create("ambience-sound_fix", 1, 0, function()
		for k,v in pairs(ents.FindByName("amb")) do
			local shouldplay = false
			for k,ply in pairs(ents.FindInSphere(v:GetPos(),20)) do
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
end
/*
for k,v in pairs(ents.GetAll()) do
	if v:GetPos():WithinAABox(Vector(6196.2192382813,1101.5805664063,173.81211853027),Vector(6443.576171875,814.38983154297,-30.359924316406)) then
		print(v:GetClass() .. " " .. v:MapCreationID())
	end
end*/


sBMRP.MapHook("map_init", mapinit)
