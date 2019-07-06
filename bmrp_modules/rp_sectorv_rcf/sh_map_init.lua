if CLIENT then 
	local tempMat = Material("HALFLIFE/+0~lab_crt2.vtf");
	local matTable = {
		["$basetexture"] = tempMat:GetName(),
		["$basetexturetransform"] = "center .5 .5 scale " .. (1 /0.5) .. " " .. (1 / 0.5) .. " rotate 0 translate " .. .5 .. " " .. .5,
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
	};
	local buttontexture = CreateMaterial("CUSTOMHLBUTTONTEXTURE3", "VertexLitGeneric", matTable);
	buttontexture:SetTexture("$basetexture", tempMat:GetTexture("$basetexture"));
	return
end

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

	EntID(3881):SetName("biolab1")
	EntID(3913):SetName("biolab2")
	EntID(3898):SetName("biolab3")

	--[[-------------------------------------------------------------------------
	Custom buttons yo
	---------------------------------------------------------------------------]]
	EntID(1901):Fire("Lock")
	EntID(1902):Fire("Lock")

	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-2171.19, -3168.60, -177.48))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90,0,180))
	button:SetName("biosector-door")
	button:GetPhysicsObject():EnableMotion(false)
	button:SetMaterial("!CUSTOMHLBUTTONTEXTURE3",true)
	local button_lighting = ents.Create("prop_physics_nolighting")
	button_lighting:SetPos(button:GetPos())
	button_lighting:SetAngles(button:GetAngles())
	button_lighting:SetModel(button:GetModel())
	button_lighting:SetParent(button)
	button_lighting:SetRenderMode(RENDERMODE_TRANSALPHA)
	button_lighting:Spawn()


	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-2342.83, -3110.97, -174.24))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90.000, 180.000, 180.000))
	button:SetName("biosector-door")
	button:GetPhysicsObject():EnableMotion(false)
	button:SetMaterial("!CUSTOMHLBUTTONTEXTURE3",true)
	local button_lighting = ents.Create("prop_physics_nolighting")
	button_lighting:SetPos(button:GetPos())
	button_lighting:SetAngles(button:GetAngles())
	button_lighting:SetModel(button:GetModel())
	button_lighting:SetParent(button)
	button_lighting:SetRenderMode(RENDERMODE_TRANSALPHA)
	button_lighting:Spawn()


	timer.Simple(5, function()
		BODYMAN:LoadClosets()
	end)
end
/*
for k,v in pairs(ents.GetAll()) do
	if v:GetPos():WithinAABox(Vector(6196.2192382813,1101.5805664063,173.81211853027),Vector(6443.576171875,814.38983154297,-30.359924316406)) then
		print(v:GetClass() .. " " .. v:MapCreationID())
	end
end*/

if SERVER then
	sBMRP.MapHook("map_init", mapinit)

end
