--[[-------------------------------------------------------------------------
Sirro"s Prop Protection (recoded)
---------------------------------------------------------------------------]]
sPropProtection = sPropProtection || {}

local eMeta = FindMetaTable("Entity")
local pMeta = FindMetaTable("Player")

local IsValid = IsValid
local pairs = pairs
local string = string
local ToJSON = util.TableToJSON
local FromJSON = util.JSONToTable
local file = file

sPropProtection.CollisionOverride = sPropProtection.CollisionOverride || false
sPropProtection.NoCollidedEnts = file.Read("blockedents.txt", "DATA") && FromJSON(file.Read("blockedents.txt", "DATA")) || {}

--[[-------------------------------------------------------------------------
CONFIG
---------------------------------------------------------------------------]]

local NoDamageEnts = { -- list of damage types player"s can"t be damaged by
	["entityflame"] = true, -- flames
	["prop_physics"] = true, -- props
	["worldspawn"] = false, -- fall damage
	["func_movelinear"] = true, -- moving map entites
	["prop_ragdoll"] = true, -- ragdolls
	["gmod_wheel"] = true, -- wheels (from the toolgun)
	["gmod_wire_turret"] = true, -- wire turrents
	["gmod_wire_explosive"] = true, -- wire explosives
	["gmod_wire_simple_explosive"] = true, -- wire explosives pt. 2
}

-- The precentage at which if a prop exceeds at on being outside the world, is blocked from being spawned
-- Ex. Spawning a massive prop in a small room will result in most of the prop being outside the world
sPropProtection.PropPrecentage = 50 --%

--[[-------------------------------------------------------------------------
END OF CONFIG
(see ULX commands about collision blacklisting)
---------------------------------------------------------------------------]]

-- collision nerf
//sPropProtection.OldConstant = sPropProtection.OldConstant || constraint.NoCollide -- double declaring for redundency 
//function constraint.NoCollide() end

concommand.Add("sPropProtection_RestoreConstraintFunc", function(ply) -- incase players freak the fuck out
	if IsValid(ply) then return end
	constraint.NoCollide = sPropProtection.OldConstant
end)


-- anti prop kill
local function PlayerHit( ent, dmginfo )
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	if ent:IsPlayer() then
		if inf == NULL || inf == nil || att == NULL || inf == nil || (inf:GetClass() == nil && !att:IsPlayer()) then return end
	    if NoDamageEnts[inf:GetClass()] || dmginfo:GetDamageType() == 1 then
			return true
		end
	end
end
hook.Add( "EntityTakeDamage", "PlayerHit", PlayerHit )

-- Ghosting

function eMeta:Ghost() -- Ghosting the entities
	if !IsValid(self) || self.ghosted || self:IsPlayer() then return end
	self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	self.ghosted = true
end

function eMeta:UnGhost() -- Unghosting the entities
	if !IsValid(self) || !self.ghosted || self:IsPlayer()  then return end
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.ghosted = false
end

function eMeta:CanUnghost()
	if !IsValid(self) then return end
	local PObj = self:GetPhysicsObject()
	if IsValid(PObj) && !self:IsVehicle() then
		if !PObj:GetVolume() then return true end
		for k, v in pairs(ents.FindInSphere(self:GetPos(), PObj:GetVolume() / 10000 + 20 ) ) do -- if the player unghosts a prop inside a player, keep ghosted
			if v:IsPlayer() then
				return false
			end
		end
	end
	return true
end

function sPropProtection.DoGrab(ply, ent)
	ent:Ghost()
	if ent:IsConstrained() then
		for k, v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if ent == k then continue end
			k:Ghost()
		end
	end
end


function sPropProtection.DoUngrab(ply, ent)
	ent:UnGhost()
	if ent:IsConstrained() then
		for k, v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if ent == k then continue end
			if k:CanUnghost() then
				k:UnGhost()
			end
		end
	end
end

for k,v in pairs({"OnPhysgunPickup", "GravGunOnPickedUp"}) do
	hook.Add(v, "sPropProtection_ghost", sPropProtection.DoGrab)
end

for k,v in pairs({"GravGunOnDropped", "PhysgunDrop"}) do
	hook.Add(v, "sPropProtection_unghost", sPropProtection.DoUngrab)
end

hook.Add("CanProperty", "bmrp_fireblock", function(ply, ent) -- smoking isn"t cool
	if (!ply:IsAdmin() && ent == "ignite") then
		return false
	end
end)

--[[-------------------------------------------------------------------------
Blocking some known exploits (credits to Crident"s anticrash for this one)
---------------------------------------------------------------------------]]
hook.Add( "CanTool", "sPropProtection.CanTool", function( ply, tr, tool ) -- Stop people fucking with tools
	-- Advanced Dupe model scale exploit
	local dupetab =
		(tool == "adv_duplicator" && ply:GetActiveWeapon():GetToolObject().Entities) ||
		(tool == "advdupe2" && ply.AdvDupe2 && ply.AdvDupe2.Entities) ||
		(tool == "duplicator" && ply.CurrentDupe && ply.CurrentDupe.Entities)

	if dupetab then
		for k, v in pairs(dupetab) do
			if !v.ModelScale then continue end
			if v.ModelScale > 10 then
				return false
			end
			v.ModelScale = 1
		end
	end

	if tool:lower() == "material" then -- blackscreen exploit
		local tool = ply:GetActiveWeapon():GetToolObject()
		local mat = string.lower(tool:GetClientInfo("override"))
		if string.StartWith(mat, "pp/") && string.EndsWith(mat, "/copy") then -- blackscreen exploit
			return false
		end
	end
end)

--[[-------------------------------------------------------------------------
Prop canFit function
---------------------------------------------------------------------------]]

hook.Add("PlayerSpawnProp", "sPropProtection_primary", function(ply, model, stacker)

	if ply.AdvDupe2 && ply.AdvDupe2.Pasting || stacker then return end

	local prop = ents.Create("prop_dynamic")
	prop:SetPos(ply:GetEyeTrace().HitPos)
	prop:SetModel(model)
	prop:Spawn()
	
	local vec1, vec2 = prop:GetModelBounds()
	prop:SetPos(prop:GetPos() + Vector(0,0,math.abs(vec1.z*2)))
	prop:DropToFloor()
	local propphys = prop:GetPhysicsObject()
	local propmesh = propphys:GetMesh()
	local numoutside = 0
	local totalmesh = 0
	for k,vec in pairs(propmesh) do
		totalmesh = totalmesh + 1
		if not util.IsInWorld(propphys:LocalToWorld(vec.pos)) then
			numoutside = numoutside + 1
		end
	end
	local precentageoutside = math.Round( numoutside / totalmesh * 100)

	if precentageoutside >= sPropProtection.PropPrecentage then
		ply:Notify("This prop is " .. precentageoutside .. "% outside the world; cannot fit!", 1, 3)
		Log(ply:GetName() .. " tried to spawn in " .. model .. ".[" .. precentageoutside .. "% outside map.]")
		prop:Remove()
		return false
	end
	Log(ply:GetName() .. " spawned in " .. model .. ".[" .. precentageoutside .. "% outside map.]")
	prop:Remove()

end)

--[[-------------------------------------------------------------------------
Collision Overrides Section
---------------------------------------------------------------------------]]

local function onEntityCreated(ent)
	timer.Simple(0, function()
		local ply = ent:CPPIGetOwner()
		if ply && sPropProtection.CollisionOverride && sPropProtection.NoCollidedEnts[ ent:GetClass() ] then
			ent:SetCustomCollisionCheck(true)
			ent:CollisionRulesChanged()
			if !ply.warned then
				ply.warned = true
				sBMRP.ChatNotify({ply}, "Warning", "Due to the high traffic in players, prop collisions for player-props have been disabled for proformance reasons.")
			end
		end
	end)
end
hook.Add("OnEntityCreated", "prop_collide", onEntityCreated)

hook.Add("ShouldCollide", "sPropProtectionShouldCollide" , function(e1 , e2)
	if sPropProtection.NoCollidedEnts[e1:GetClass()] && sPropProtection.NoCollidedEnts[e2:GetClass()] then
		return false
	end
end)

function sPropProtection.EnableCollisionCheck(bool)
	for k,v in pairs(ents.GetAll()) do
		if sPropProtection.NoCollidedEnts[ v:GetClass() ] && v:CPPIGetOwner() then
			ent:SetCustomCollisionCheck(bool)
			ent:CollisionRulesChanged()
		end
	end
	sPropProtection.CollisionOverride = bool
end


local function doCollisionCheck(plycount)
	if plycount >= 30 && !sPropProtection.CollisionOverride && !sPropProtection.AdminOverride then
		sPropProtection.EnableCollisionCheck(true)
		Log("Enabling collision checks.")
		sBMRP.ChatNotify(player.GetAll(), "Server", "High player traffic detected, disabling collisions for player-props to ensure proformance.")
	elseif plycount < 29 && sPropProtection.CollisionOverride then
		sPropProtection.EnableCollisionCheck(false)
		Log("Disabling collision checks.")
		sBMRP.ChatNotify(player.GetAll(), "Server", "High player traffic subsided, re-enabling collisions for player-props.")
	end
end

for k,v in pairs({"PlayerInitalSpawn", "PlayerDisconnected"}) do
	hook.Add(v, "sPP_CollisionCheck", function()
		doCollisionCheck(#player.GetHumans())
	end)
end