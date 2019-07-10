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

	for k,v in pairs({4647,3003}) do
		SafeRemoveEntity(ents.GetMapCreatedEntity(v))
	end
	timer.Create("ambience-sound_fix", 1, 0, function()
		for k,v in pairs(ents.FindByName("amb")) do
			local shouldplay = false
			for k,ply in pairs(ents.FindInSphere(v:GetPos(),200)) do
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

	EntID(3879):SetName("biolab1")
	EntID(3894):SetName("biolab2")
	EntID(3862):SetName("biolab3")

	--[[-------------------------------------------------------------------------
	Custom buttons yo
	---------------------------------------------------------------------------]]
	EntID(1913):Fire("Lock")
	EntID(1912):Fire("Lock")

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
			if ents.GetMapCreatedEntity(2586):GetPos()[3] == -157 then
				ents.GetMapCreatedEntity(2586):EmitSound("doors/doormove2.wav")
			elseif ents.GetMapCreatedEntity(2586):GetPos()[3] == -238 then
				ents.GetMapCreatedEntity(2586):EmitSound("doors/doormove6.wav",150)
			end
			ents.GetMapCreatedEntity(2586):Fire("Toggle")
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
			if ents.GetMapCreatedEntity(2586):GetPos()[3] == -157 then
				self:EmitSound( "buttons/button3.wav" )
				ents.GetMapCreatedEntity(2586):EmitSound("ambient/machines/steam_release_2.wav")
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
			elseif ents.GetMapCreatedEntity(2586):GetPos()[3] == -238 then
				self:EmitSound("buttons/button11.wav",150)
			end
		end
	end

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