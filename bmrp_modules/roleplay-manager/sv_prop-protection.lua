require("fps")

--[[-------------------------------------------------------------------------
CONFIG
---------------------------------------------------------------------------]]


local nodamageclass = { -- list of damage types player's can't be damaged by
	["entityflame"] = true,
	["prop_physics"] = true,
	["worldspawn"] = true,
	["func_movelinear"] = true,
	["prop_ragdoll"] = true,
	["gmod_wheel"] = true,
	["gmod_wire_turret"] = true,
	["gmod_wire_explosive"] = true,
	["gmod_wire_simple_explosive"] = true,
}

local BuildingEnts = { -- when the server lags a little, only these ents will be frozen
	["prop_physics"] = true,
	["gmod_button"] = true,
	["gmod_cameraprop"] = true,
	["keypad"] = true,
}

local LagCheck = 3 -- the delay at which the server checks if it is lagging


-- The precentage at which if a prop exceeds at on being outside the world, is blocked from being spawned
-- Ex. Spawning a massive prop in a small room will result in most of the prop being outside the world
	sPP.PropPrecentage = 40

-- This is the same as the last setting, expect that it is for props being duped in, recommend that this is higher
-- as props being duped in are most likely not going to crash the server
--	sPP.PropPrecentageDupe = 60 (This setting is now deprecated.)




local function PlayerHit( ent, dmginfo )
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	if ent:IsPlayer() then
		if inf == NULL or inf == nil or att == NULL or inf == nil or (inf:GetClass() == nil and not(att:IsPlayer())) then return end
	    if nodamageclass[inf:GetClass()] or dmginfo:GetDamageType() == 1 then
			return true
		end
	end
	
end
hook.Add( "EntityTakeDamage", "PlayerHit", PlayerHit )


--[[-------------------------------------------------------------------------
Anti crash
---------------------------------------------------------------------------]]
sPP = sPP or {}

local entity = FindMetaTable("Entity")
local PhysObj = FindMetaTable("PhysObj")
local ply = FindMetaTable("Player")



function sPP.Ghost(self) -- Ghosting the entities
	if self.ghosted or self:IsPlayer() then return end

	self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )

	self.ghosted = true
end
function sPP.Unghost(self) -- Unghosting the entities
	if not self.ghosted or self:IsPlayer()  then return end
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.ghosted = false
end

function sPP.CanUnghost(self)
	if not IsValid(self) then return end
	local PObj = self:GetPhysicsObject()
	if IsValid(PObj) and !self:IsVehicle() then
		if not PObj:GetVolume() then return true end
		for k, v in pairs(ents.FindInSphere(self:GetPos(), PObj:GetVolume() / 10000 + 20 ) ) do
			if v:IsPlayer() then
				return false
			end
		end
	end
	return true
end


function entity:Ghost()
	return sPP.Ghost(self)
end
function entity:Unghost()
	return sPP.Ghost(self)
end
function entity:GetPlayerOwner()
	return sPP.GetPlayerOwner(self)
end


-- Server is dying, try to save it!
local AntiSpamWarning = CurTime()
function sPP.StopLag()
	if CurTime() < AntiSpamWarning then return end
    	
	RunConsoleCommand( "phys_timescale", "0" )
	for k,v in pairs(player.GetAll()) do
		v:ChatPrint("Server physics have been frozen.")
		if v:IsAdmin() then
			v:ChatPrint("Server physics frozen! Resuming in 30 seconds.")
		end
	end
	game.ConsoleCommand("darkrp admintellall Server physics have been frozen temporaraly.\n")
	timer.Simple(30, function()
		RunConsoleCommand( "phys_timescale", "1" )

		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("Server physics have been unfrozen.")
		end
		game.ConsoleCommand("darkrp admintellall Server physics have been unfrozen.\n")		
	end)
	local admins = false
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			admins = true
		end
	end
	if not admins then 
		for k,v in pairs(ents.GetAll()) do if v:IsNPC() and v.PrintName then v:Remove() end end
		game.ConsoleCommand("say Cleared all NPC's due to extreme lag.\n")
	end
	for k, v in pairs(ents.GetAll()) do
		local pobj = v:GetPhysicsObject()
		if IsValid(pobj) then
			pobj:EnableMotion(false)
		end
	end
	AntiSpamWarning = CurTime() + 60
end



function sPP.DeLag()
	for k, v in pairs(ents.GetAll()) do
		if BuildingEnts[v:GetClass()] then
			local pobj = v:GetPhysicsObject()
			if IsValid(pobj) then
				pobj:EnableMotion(false)
			end
		end
	end
end


-- Work out when the server is lagging
hook.Add("Tick", "sPP.Tick", function()
	local systime = SysTime()
	if sPP.Delay and sPP.Delay > systime then return end

	local realframetime = engine.RealFrameTime()
	if realframetime >= 0.5 then -- We're seriously lagging
		if !sPP.ClearCheck then
			sPP.StopLag()
		else
			sPP.DeLag()
		end
		sPP.ClearCheck = false
	elseif realframetime >= 0.3 then -- We're just lagging a bit
		if !sPP.ClearCheck then
			sPP.DeLag()
		end
		sPP.ClearCheck = false
	else
		sPP.ClearCheck = true
	end

	sPP.Delay = systime + LagCheck
end)

hook.Add( "CanTool", "sPP.CanTool", function( ply, tr, tool ) -- Stop people fucking with tools
    -- Advanced Dupe model scale exploit
	local dupetab =
		(tool == 'adv_duplicator' and ply:GetActiveWeapon():GetToolObject().Entities) or
		(tool == 'advdupe2' and ply.AdvDupe2 and ply.AdvDupe2.Entities) or
		(tool == 'duplicator' and ply.CurrentDupe and ply.CurrentDupe.Entities)

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
        if string.StartWith(mat, "pp/") and string.EndsWith(mat, "/copy") then -- blackscreen exploit
            return false
        end
    end
end)

-- Code below this stops collisions

hook.Add("PlayerSpawnedProp", "sPP.PlayerSpawnedProp", function(ply, _, ent)
	local mat = ent:GetMaterial()
	if string.StartWith(mat, "pp/") and string.EndsWith(mat, "/copy") then -- blackscreen exploit
        ent:Remove()
    end
    if ply.AdvDupe2 and ply.AdvDupe2.Pasting then return end
    ent:GetPhysicsObject():EnableMotion(false)
end)


hook.Add( "PhysgunPickup", "sPP.PhysgunPickup", function( ply, ent )
	if ent:IsPlayer() then return end
	local cantouch = ent:CPPICanPhysgun(ply)
	if cantouch then
		sPP.Ghost(ent)
		if ent:IsConstrained() then
			local tbl = constraint.GetAllConstrainedEntities(ent)
			for k, v in pairs(tbl) do
				if ent == k then continue end
				sPP.Ghost(k)
			end
		end
	else
		return false
	end
end)

hook.Add("PhysgunDrop", "sPP.PhysgunDrop", function(ply, ent)
    if sPP.CanUnghost(ent, ply) then
        sPP.Unghost(ent)
        if ent:IsConstrained() then
			local tbl = constraint.GetAllConstrainedEntities(ent)
			for k, v in pairs(tbl) do
				if ent == k then continue end
				if sPP.CanUnghost(k, ply) then
					sPP.Unghost(k)
				end
			end
		end
    end
end)

hook.Add("GravGunOnPickedUp", "bmrp_grav", function(ply, ent)
		sPP.Ghost(ent)
end)

hook.Add("GravGunOnDropped", "bmrp_ghost_drop_grav", function(ply, ent)
		sPP.Unghost(ent)
end)

hook.Add("CanProperty", "bmrp_fireblock", function(ply, ent) 
	if (!ply:IsAdmin() and ent == "ignite") then return false end end)

--[[
	<-- Overwriting the default setposition functions and clamping them.
--	This shouldn't be needed however it could stop strange stuff happening. -->
]]--
if (entity.SetRealPos == nil) and (PhysObj.SetRealPos == nil) then
	entity.SetRealPos = entity.SetPos
	PhysObj.SetRealPos = PhysObj.SetPos
end

local Clamp = math.Clamp
function entity.SetPos(ent, pos)
    pos.x = Clamp(pos.x, -20000, 20000)
    pos.y = Clamp(pos.y, -20000, 20000)
    pos.z = Clamp(pos.z, -20000, 20000)
    entity.SetRealPos(ent, pos) -- called with pos being nil? wtf
end
function PhysObj.SetPos(phys, pos)
    pos.x = Clamp(pos.x, -20000, 20000)
    pos.y = Clamp(pos.y, -20000, 20000)
    pos.z = Clamp(pos.z, -20000, 20000)
    PhysObj.SetRealPos(phys, pos)
end



hook.Add("PlayerSpawnProp", "sPP_primary", function(ply, model)
	if model then
		if ply.AdvDupe2 and ply.AdvDupe2.Pasting then return end
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
		local precentageoutside = math.Round(numoutside/totalmesh*100)

		--[[if ply.AdvDupe2 and ply.AdvDupe2.Pasting then
			if precentageoutside >= sPP.PropPrecentageDupe then
				ply:ChatPrint("[sPP - AdvDupe2]: " .. prop:GetModel() .. " was removed for being " .. precentageoutside .. "% outside the world.")
				Log(ply:GetName() .. " tried to spawn in " .. model .. " while duping. [" .. precentageoutside .. "% outside map.]")
				prop:Remove()
				return false
			else
				prop:Remove()
				return
			end
		else]]--
		if precentageoutside >= sPP.PropPrecentage then
			ply:Notify("[sPP]: This prop is " .. precentageoutside .. "% outside the world; cannot fit!", 1, 3)
			Log(ply:GetName() .. " tried to spawn in " .. model .. ".[" .. precentageoutside .. "% outside map.]")
			prop:Remove()
			return false
		end
		
		

		--timer.Simple(1, function() ply:SetPos(pos) end)
		prop:Remove()
	end
end)
