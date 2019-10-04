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

	for k,v in pairs({4647,3003, 5606, 4542, 2936}) do
		SafeRemoveEntity(ents.GetMapCreatedEntity(v))
	end
	timer.Create("ambience-sound_fix", 5, 0, function()
		for k,v in pairs(ents.FindByName("amb")) do
			for k,ply in pairs(player.GetAll()) do
				if ply:IsPlayer() and ply:GetPos():DistToSqr(v:GetPos()) <= 40000 then
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

	EntID(3788):SetName("biolab1")
	EntID(3801):SetName("biolab2")
	EntID(3771):SetName("biolab3")

	--[[-------------------------------------------------------------------------
	Custom buttons yo
	---------------------------------------------------------------------------]]
	EntID(1889):Fire("Lock")
	EntID(1888):Fire("Lock")

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

	-- HECU Scanner
	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-4931.60, -896.86, 642.72))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90,90,180))
	button:SetName("hecu-door")
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
	button:SetPos(Vector(-4911.11, -901.15, 642.28))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90.000, -90.000, 180.000))
	button:SetName("hecu-door")
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
	-- Biolabs container
	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-2824.5,-1786,-187.2))
	button:SetModel("models/dav0r/buttons/button.mdl")
	button:SetModelScale(button:GetModelScale() * 2,0)
	button:SetColor(Color( 0, 0, 0, 0 ))
	button:Spawn()
	button:SetAngles(Angle(28,0,0))
	button:SetName("biolabs_container_toggle")
	button:GetPhysicsObject():EnableMotion(false)
	button:SetRenderMode(RENDERMODE_TRANSALPHA)
	function button:Use( activator, caller )
		if IsValid( caller ) and caller:IsPlayer() then
			self:EmitSound( "buttons/button3.wav" )
			if ents.GetMapCreatedEntity(2522):GetPos()[3] == -157 then
				ents.GetMapCreatedEntity(2522):EmitSound("doors/doormove2.wav")
			elseif ents.GetMapCreatedEntity(2522):GetPos()[3] == -238 then
				ents.GetMapCreatedEntity(2522):EmitSound("doors/doormove6.wav",150)
			end
			ents.GetMapCreatedEntity(2522):Fire("Toggle")
		end
	end
	--Biolabs container gas buton
	
	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-2824.6,-1774.5,-184.8))
	button:SetModel("models/cheeze/buttons2/air.mdl")
	button:SetModelScale(button:GetModelScale() * 2,0)
	button:Spawn()
	button:SetAngles(Angle(28,0,0))
	button:SetName("biolabs_container_jewgasser9k")
	button:GetPhysicsObject():EnableMotion(false)
	function button:Use( activator, caller )
		if IsValid( caller ) and caller:IsPlayer() then
			if ents.GetMapCreatedEntity(2522):GetPos()[3] == -157 then
				self:EmitSound( "buttons/button3.wav" )
				ents.GetMapCreatedEntity(2522):EmitSound("ambient/machines/steam_release_2.wav")
				local d = DamageInfo()
				d:SetDamageType( DMG_SLOWBURN )
				local smoke= ents.Create("env_smoketrail")
				smoke:SetKeyValue("startsize","10000")
				smoke:SetKeyValue("endsize","130")
				smoke:SetKeyValue("spawnradius","1")
				smoke:SetKeyValue("minspeed","0.1")
				smoke:SetKeyValue("maxspeed","0.5")
				smoke:SetKeyValue("startcolor","0 255 0")
				smoke:SetKeyValue("endcolor","0 255 0")
				smoke:SetKeyValue("opacity","0.1")
				smoke:SetKeyValue("spawnrate","100")
				smoke:SetKeyValue("lifetime","2")
				smoke:SetPos(Vector(-2587.585205,-1882.356445,-120.592384))
				smoke:Spawn()
				smoke:Fire("kill","",1)
				for k,v in pairs(ents.FindInSphere( Vector( -2595.856934,-1884.289429,-147.692139), 50)) do
					
					d:SetDamage( v:GetMaxHealth()/4)
					v:TakeDamageInfo( d )
				end
			elseif ents.GetMapCreatedEntity(2522):GetPos()[3] == -238 then
				self:EmitSound("buttons/button11.wav",150)
			end
		end
	end

	local button = ents.Create("gmod_button")
	button:SetPos(Vector(-7423.00, -250.51, -200.95))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90.000, -90.000, 180.000))
	button:SetName("secalarglab-door")
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
	button:SetPos(Vector(-7423.29, -237.72, -203.46))
	button:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	button:Spawn()
	button:SetAngles(Angle(90.000, 90.000, 180.000))
	button:SetName("secalarglab-door2")
	button:GetPhysicsObject():EnableMotion(false)
	button:SetMaterial("!CUSTOMHLBUTTONTEXTURE3",true)

	local button_lighting = ents.Create("prop_physics_nolighting")
	button_lighting:SetPos(button:GetPos())
	button_lighting:SetAngles(button:GetAngles())
	button_lighting:SetModel(button:GetModel())
	button_lighting:SetParent(button)
	button_lighting:SetRenderMode(RENDERMODE_TRANSALPHA)
	button_lighting:Spawn()
	for k,v in pairs({5385, 5384, 5386, 5383}) do
		ents.GetMapCreatedEntity(v):Fire("Lock")
	end
	hook.Add("PlayerUse", "sector_large-lab", function(ply, ent)
		if not IsFirstTimePredicted() then return end
		if ent:GetName() == "secalarglab-door" then
			if table.HasValue(ply:GetOwnedDoors(), ents.GetMapCreatedEntity(5384)) then
				for k,v in pairs({5385, 5384, 5386, 5383}) do
					ents.GetMapCreatedEntity(v):Fire("Unlock")
					ents.GetMapCreatedEntity(v):Fire("Open")
					ents.GetMapCreatedEntity(v):Fire("Lock")
				end
				ent:EmitSound("buttons/button5.wav")
			else
				ent:EmitSound("buttons/button2.wav")
			end
		end

	end)

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


	--[[-------------------------------------------------------------------------
	fast travel doors (topside canyon)
	---------------------------------------------------------------------------]]
	local toucherents = {
		{"models/hunter/plates/plate8x16.mdl", Vector(-4378.50, 10425.73, 225.74),Angle(-90, 180, 180.000), "canyon_2"},
		{"models/hunter/plates/plate3x5.mdl", Vector(-2467.15, -1002.22, 640.75), Angle(90.000, 90.000, 180.000), "canyon_1"}
	}
	for k,v in pairs(ents.FindByClass("npc_quest-dealer")) do v:Remove() end
	for k,v in pairs(toucherents) do
		local ent = ents.Create("npc_quest-dealer")

		ent:SetModel(v[1])
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetPos(v[2])
		ent:SetAngles(v[3])
		ent:SetName(v[4])
		ent:Spawn()
		ent:SetRenderMode(RENDERMODE_NONE)
		ent:GetPhysicsObject():EnableMotion(false)
	end


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

--3497
hook.Add("EntityTakeDamage", "breakable_forcegod", function(ent, data)
	if ent:MapCreationID() == 3497 && !sBMRP.Cascade then
		return true
	end
end)


hook.Add("PlayerUse", "ladder_ply", function(ply, ent)
	if not IsFirstTimePredicted() then return end
	if IsValid(ent) and ply:GetPos():WithinAABox(Vector(40.617343902588,-2494.8203125,-494.66076660156),Vector(-8.9349412918091,-2555.556640625,-623.42175292969)) then
		ply:EmitSound("player/footsteps/ladder1.wav")
		ply:SetPos(Vector(48.75016784668,-2521.4235839844,-442.96875))
		ply:SetAngles(Angle(0,180,0))
	end
end)


if SERVER then


	concommand.Add("regentoucherents", function()
		table.Iterate(ents.FindByClass("quest_npc-dealer"), function(ent) ent:Remove() end)
		local toucherents = {
			{"models/hunter/plates/plate8x16.mdl", Vector(-4378.50, 10425.73, 225.74),Angle(-90, 180, 180.000), "canyon_2"},
			{"models/hunter/plates/plate3x5.mdl", Vector(-2467.15, -1002.22, 640.75), Angle(90.000, 90.000, 180.000), "canyon_1"}
		}
		for k,v in pairs(ents.FindByClass("npc_quest-dealer")) do v:Remove() end
		for k,v in pairs(toucherents) do
			local ent = ents.Create("npc_quest-dealer")

			ent:SetModel(v[1])
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetPos(v[2])
			ent:SetAngles(v[3])
			ent:SetName(v[4])
			ent:Spawn()
			ent:SetRenderMode(RENDERMODE_NONE)
			ent:GetPhysicsObject():EnableMotion(false)
		end
	end)
	hook.Add("TriggerEntTouch", "test", function(ent, triggerEnt)
		if ent:GetName() == "canyon_1" and triggerEnt:IsPlayer() then
			triggerEnt:SetPos(DarkRP.findEmptyPos(Vector(-4225.3720703125,10443.5,136.03125), {}, 300, 30, Vector(16,16,64)))
			triggerEnt:DropToFloor()
			triggerEnt:SetEyeAngles(Angle(0,0,0))
			sound.Play("doors/handle_pushbar_locked1.wav",triggerEnt:GetPos(),75,100,0.5)
		elseif ent:GetName() == "canyon_2" and triggerEnt:IsPlayer() then
			triggerEnt:SetPos(DarkRP.findEmptyPos(Vector(-2472.7902832031,-1078.8332519531,633.14520263672), {}, 300, 30, Vector(16,16,64)))
			triggerEnt:DropToFloor()
			triggerEnt:SetEyeAngles(Angle(0,-90,0))
			sound.Play("doors/metal_stop1.wav",triggerEnt:GetPos(),75,100,0.25)
		end
	end)
end