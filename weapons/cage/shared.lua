SWEP.WElements = {
	["handle"] = { type = "Model", model = "models/props_wasteland/panel_leverhandle001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "element_name", pos = Vector(0, 0, 17.142), angle = Angle(26.882, 0, 0), size = Vector(1.08, 1.534, 1.144), color = Color(255, 255, 255, 255), surpresslightning = false, material = "mechanics/metal2", skin = 0, bodygroup = {} },
	["element_name"] = { type = "Model", model = "models/props_lab/kennel_physics.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-15.065, 5.714, 19.221), angle = Angle(47.922, 12.857, -178.831), size = Vector(0.432, 0.432, 0.432), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.VElements = {
	["Case"] = { type = "Model", model = "models/props_lab/kennel_physics.mdl", bone = "ValveBiped.Bip01", rel = "", pos = Vector(-9.87, -3.636, 31.687), angle = Angle(59.61, 40.909, -143.767), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
if CLIENT then
	SWEP.PrintName = "Cage"
else

end
SWEP.Category 				= "BMRP - Miscellaneous"
SWEP.Author                 = "Creed"
SWEP.HoldType 				= "melee"
SWEP.Slot					= 2
SWEP.SlotPos				= 1
SWEP.Spawnable = true;
SWEP.AdminOnly = false
SWEP.Instructions = "Left Click to cage. Right click to open cage."

SWEP.ViewModelFOV 			= 70
SWEP.ViewModelFlip 			= false
SWEP.UseHands 				= false
SWEP.ViewModel 				= "models/weapons/v_pistol.mdl"
SWEP.WorldModel 			= "models/props_lab/kennel_physics.mdl"
SWEP.ShowViewModel 			= true
SWEP.ShowWorldModel 		= false
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo	= "none"
SWEP.CarryingEnt			= nil
SWEP.ViewModelBoneMods = {
	["ValveBiped.base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.clip"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01"] = { scale = Vector(1, 1, 1), pos = Vector(15, -7.963, 0), angle = Angle(-27.778, 12.222, 0) }
}

local function OnHandlerDeath(ply,att,dmg)
	if IsValid(ply.CarryingEnt) and ply.CarryingEnt != nil then
		ent = ply.CarryingEnt
		ent:SetParent()
		ent:Spawn()
		if ply:GetEyeTrace().HitPos:Distance(ply:GetPos()) >300 then
			pos = ply:GetPos()
		else
			pos = ply:GetEyeTrace().HitPos
		end
		ent:SetPos(pos)
		ent:SetPos(DarkRP.findEmptyPos(pos, {ent}, 600, 10, Vector(0, 0, 30)))
		if not ent:IsAdmin() then 
			pk_pills.apply(ent,"headcrab",'lock-life') 
		elseif not ent:GetNWBool("IsInPill") == true then 
			pk_pills.apply(ent,"headcrab",'force') 
		end 
		ent:SetNoTarget(true) 
		ent:SetGravity(1.5)
		ent:SetWalkSpeed(200)
		ent:SetRunSpeed(500)
		ply.CarryingEnt = nil
		ent.CageOwner = nil
	end
end
local function OnHandlerDisconnect(ply)
	if IsValid(ply.CarryingEnt) and ply.CarryingEnt != nil then
		ent = ply.CarryingEnt
		ent:SetParent()
		ent:Spawn()
		if ply:GetEyeTrace().HitPos:Distance(ply:GetPos()) >300 then
			pos = ply:GetPos()
		else
			pos = ply:GetEyeTrace().HitPos
		end
		ent:SetPos(pos)
		ent:SetPos(DarkRP.findEmptyPos(pos, {ent}, 600, 10, Vector(0, 0, 30)))
		if not ent:IsAdmin() then 
			pk_pills.apply(ent,"headcrab",'lock-life') 
		elseif not ent:GetNWBool("IsInPill") == true then 
			pk_pills.apply(ent,"headcrab",'force') 
		end 
		ent:SetNoTarget(true) 
		ent:SetGravity(1.5)
		ent:SetWalkSpeed(200)
		ent:SetRunSpeed(500)
		ply.CarryingEnt = nil
		ent.CageOwner = nil
	end
end
local function OnCagedSwitchJobs(ply,before,after)
	if before == TEAM_HEADCRAB then
		if IsValid(ply.CageOwner) then
			ply:UnSpectate()
			--pk_pills.restore(ply,true)
			ply:SetParent()
			--ply:Spawn()
			--[[
			if ply.CageOwner.HitPos:Distance(ply.CageOwner:GetPos()) >300 then
				pos = ply.CageOwner:GetPos()
			else
				pos = ply.CageOwner:GetEyeTrace().HitPos
			end]]
			--ply:SetPos(pos)
			--ply:SetPos(DarkRP.findEmptyPos(pos, {ent}, 600, 10, Vector(0, 0, 30)))
			ply.CageRespawn = true
			hook.Add( "PlayerSpawn", "cage_jobrespawn_"..ply:SteamID(), function(ply)
				if ply.CageRespawn == true then
					pk_pills.restore(ply,true)
					ply.CageRespawn = false
					ply.CageOwner.CarryingEnt = nil
					ply.CageOwner = nil
					hook.Remove("PlayerSpawn","cage_jobrespawn_"..ply:SteamID())
				end
			end)
			ply.CageOwner.CarryingEnt = nil
			ply.CageOwner:ChatPrint("You have dropped what you are carrying! (Player switched jobs)")
			ply.CageOwner:EmitSound("physics/metal/metal_chainlink_impact_soft2.wav")
			
		end
	end
end

if SERVER then
	hook.Remove("DoPlayerDeath","cage_onhandlerdeath")
	hook.Remove("PlayerDisconnected","cage_onhandlerdisconnect")
	hook.Remove("OnPlayerChangedTeam","cage_oncagedswitchjobs")
	while hook.GetTable()["cage_oncagedswitchjobs"] do
		hook.Remove("OnPlayerChangedTeam","cage_oncagedswitchjobs")
	end
	if not hook.GetTable()["cage_onhandlerdeath"] then
		hook.Add("DoPlayerDeath","cage_onhandlerdeath",OnHandlerDeath)
	end
	if not hook.GetTable()["cage_onhandlerdisconnect"] then
		hook.Add("PlayerDisconnected","cage_onhandlerdisconnect",OnHandlerDisconnect)
	end
	if not hook.GetTable()["cage_oncagedswitchjobs"] then
		hook.Add("OnPlayerChangedTeam","cage_oncagedswitchjobs",OnCagedSwitchJobs)
	end
end

function SWEP:DoPickup(ent)
	if SERVER then
		for k,v in pairs(ent:GetChildren()) do -- Kick players sitting on the crab off
			if v:IsVehicle() then
				v:Remove()
			end
		end
		pk_pills.restore(ent,true)
		local trace = self.Owner:GetEyeTrace()
		local ent = trace.Entity
		ent:KillSilent()
		ent:SetParent(self.Owner)
		--ent:ScreenFade(SCREENFADE.IN, Color(230, 230, 230), 0.7, 1.4)
		ent:Spectate(OBS_MODE_CHASE)
		ent:SpectateEntity(self.Owner)
		ent.CageOwner = self.Owner
		self.CarryingEnt = ent
		self.Owner.CarryingEnt = ent
		self.Owner:EmitSound("physics/metal/metal_grate_impact_hard1.wav")
		self.Owner:ChatPrint("You have picked something up!")
		ent:ChatPrint("You have been picked up!")
	end
end
function SWEP:DoDrop(ent)
	ent:SetParent()
	ent:Spawn()
	if self.Owner:GetEyeTrace().HitPos:Distance(self.Owner:GetPos()) >300 then
		pos = self.Owner:GetPos()
	else
		pos = self.Owner:GetEyeTrace().HitPos
	end
	ent:SetPos(pos)
	ent:SetPos(DarkRP.findEmptyPos(pos, {ent}, 600, 10, Vector(0, 0, 30)))	
	if not ent:IsAdmin() then 
		pk_pills.apply(ent,"headcrab",'lock-life') 
	elseif not ent:GetNWBool("IsInPill") == true then 
		pk_pills.apply(ent,"headcrab",'force') 
	end 
	ent:SetNoTarget(true) 
	ent:SetGravity(1.5)
	ent:SetWalkSpeed(200)
	ent:SetRunSpeed(500)
	self.Owner.CarryingEnt = nil
	self.Owner:EmitSound("physics/metal/metal_chainlink_impact_soft2.wav")
	self.CarryingEnt = nil
	ent.CageOwner = nil
end
function SWEP:PrimaryAttack()
    local trace = self.Owner:GetEyeTrace()
    local ent = trace.Entity
	if IsValid(ent) then
		if ent:IsPlayer() then
			if ent:Team() == TEAM_HEADCRAB then				
				if IsValid(self.Owner.CarryingEnt) then
					self.Owner:ChatPrint("You are currently carrying something!")
				else
					self:DoPickup(ent)
				end
			end
		end
	end
end
function SWEP:SecondaryAttack()
	if SERVER then
		if IsFirstTimePredicted() then
			if IsValid(self.Owner.CarryingEnt) and self.Owner.CarryingEnt != nil then
				self:DoDrop(self.Owner.CarryingEnt)
				self.Owner:ChatPrint("You have dropped what you are carrying!")
			else
				self.Owner:ChatPrint("You are not carrying anything!")
			end
		end
	end
end
function SWEP:Initialize()
	self:SwepBuilderInit()
end

function SWEP:SwepBuilderInit()
	self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType(self.HoldType)
	self.WElements = table.FullCopy( self.WElements )
	self:CreateModels(self.WElements)
	self.VElements = table.FullCopy( self.VElements )
	self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

	self:CreateModels(self.VElements)
	
	
	if IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
			
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				vm:SetColor(Color(255,255,255,255))
			else
				vm:SetColor(Color(255,255,255,1))
				vm:SetMaterial("Debug/hsv")			
			end
		end
	end
end
function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end
function SWEP:CreateModels( tab )

	if (!tab) then return end

	for k, v in pairs( tab ) do
		if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
				string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
			
			if CLIENT then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			end
			if (IsValid(v.modelEnt)) then
				v.modelEnt:SetPos(self:GetPos())
				v.modelEnt:SetAngles(self:GetAngles())
				v.modelEnt:SetParent(self)
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
			
		elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
			and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
			
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			for i, j in pairs( tocheck ) do
				if (v[j]) then
					params["$"..j] = 1
					name = name.."1"
				else
					name = name.."0"
				end
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
			
		end
	end
	
end
SWEP.wRenderOrder = nil
function SWEP:DrawWorldModel()	
	
	self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType(self.HoldType)
	if (self.ShowWorldModel == nil or self.ShowWorldModel) then
		self:DrawModel()
	end
	
	if (!self.WElements) then return end
	
	if (!self.wRenderOrder) then

		self.wRenderOrder = {}

		for k, v in pairs( self.WElements ) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end

	end
	
	if (IsValid(self.Owner)) then
		bone_ent = self.Owner
	else
		bone_ent = self
	end
	
	for k, name in pairs( self.wRenderOrder ) do
	
		local v = self.WElements[name]
		if (!v) then self.wRenderOrder = nil break end
		if (v.hide) then continue end
		
		local pos, ang
		
		if (v.bone) then
			pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
		else
			pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
		end
		
		if (!pos) then continue end
		
		local model = v.modelEnt
		local sprite = v.spriteMaterial
		
		if (v.type == "Model" and IsValid(model)) then

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix( "RenderMultiply", matrix )
			
			if (v.material == "") then
				model:SetMaterial("")
			elseif (model:GetMaterial() != v.material) then
				model:SetMaterial( v.material )
			end
			
			if (v.skin and v.skin != model:GetSkin()) then
				model:SetSkin(v.skin)
			end
			
			if (v.bodygroup) then
				for k, v in pairs( v.bodygroup ) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
			end
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end
			
			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end
			
		elseif (v.type == "Sprite" and sprite) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			
		elseif (v.type == "Quad" and v.draw_func) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func( self )
			cam.End3D2D()

		end
		
	end
	
end

SWEP.vRenderOrder = nil
function SWEP:ViewModelDrawn()
	
	local vm = self.Owner:GetViewModel()
	if !IsValid(vm) then return end
	
	if (!self.VElements) then return end
	
	self:UpdateBonePositions(vm)

	if (!self.vRenderOrder) then
		
		self.vRenderOrder = {}

		for k, v in pairs( self.VElements ) do
			if (v.type == "Model") then
				table.insert(self.vRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.vRenderOrder, k)
			end
		end
		
	end

	for k, name in ipairs( self.vRenderOrder ) do
	
		local v = self.VElements[name]
		if (!v) then self.vRenderOrder = nil break end
		if (v.hide) then continue end
		
		local model = v.modelEnt
		local sprite = v.spriteMaterial
		
		if (!v.bone) then continue end
		
		local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
		
		if (!pos) then continue end
		
		if (v.type == "Model" and IsValid(model)) then

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix( "RenderMultiply", matrix )
			
			if (v.material == "") then
				model:SetMaterial("")
			elseif (model:GetMaterial() != v.material) then
				model:SetMaterial( v.material )
			end
			
			if (v.skin and v.skin != model:GetSkin()) then
				model:SetSkin(v.skin)
			end
			
			if (v.bodygroup) then
				for k, v in pairs( v.bodygroup ) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
			end
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end
			
			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end
			
		elseif (v.type == "Sprite" and sprite) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			
		elseif (v.type == "Quad" and v.draw_func) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func( self )
			cam.End3D2D()

		end
		
	end
	
end

function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
	
	local bone, pos, ang
	if (tab.rel and tab.rel != "") then
		
		local v = basetab[tab.rel]
		
		if (!v) then return end
		
		pos, ang = self:GetBoneOrientation( basetab, v, ent )
		
		if (!pos) then return end
		
		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
	else
	
		bone = ent:LookupBone(bone_override or tab.bone)

		if (!bone) then return end
		
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
		
		if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r
		end
	
	end
	
	return pos, ang
end

local allbones
local hasGarryFixedBoneScalingYet = false

function SWEP:UpdateBonePositions(vm)
	
	if self.ViewModelBoneMods then
		
		if (!vm:GetBoneCount()) then return end
		local loopthrough = self.ViewModelBoneMods
		if (!hasGarryFixedBoneScalingYet) then
			allbones = {}
			for i=0, vm:GetBoneCount() do
				local bonename = vm:GetBoneName(i)
				if (self.ViewModelBoneMods[bonename]) then 
					allbones[bonename] = self.ViewModelBoneMods[bonename]
				else
					allbones[bonename] = { 
						scale = Vector(1,1,1),
						pos = Vector(0,0,0),
						angle = Angle(0,0,0)
					}
				end
			end
			
			loopthrough = allbones
		end
		
		for k, v in pairs( loopthrough ) do
			local bone = vm:LookupBone(k)
			if (!bone) then continue end
			
			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)
			if (!hasGarryFixedBoneScalingYet) then
				local cur = vm:GetBoneParent(bone)
				while(cur >= 0) do
					local pscale = loopthrough[vm:GetBoneName(cur)].scale
					ms = ms * pscale
					cur = vm:GetBoneParent(cur)
				end
			end
			
			s = s * ms
			
			if vm:GetManipulateBoneScale(bone) != s then
				vm:ManipulateBoneScale( bone, s )
			end
			if vm:GetManipulateBoneAngles(bone) != v.angle then
				vm:ManipulateBoneAngles( bone, v.angle )
			end
			if vm:GetManipulateBonePosition(bone) != p then
				vm:ManipulateBonePosition( bone, p )
			end
		end
	else
		self:ResetBonePositions(vm)
	end
	   
end
 
function SWEP:ResetBonePositions(vm)
	
	if (!vm:GetBoneCount()) then return end
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
	end
	
end
function table.FullCopy( tab )

	if (!tab) then return nil end
	
	local res = {}
	for k, v in pairs( tab ) do
		if (type(v) == "table") then
			res[k] = table.FullCopy(v)
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end
	
	return res
	
end


