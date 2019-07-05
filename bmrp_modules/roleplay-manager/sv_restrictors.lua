--[[-------------------------------------------------------------------------
AntiRDM
---------------------------------------------------------------------------]]
local function AntiRDM(ent,dmginfo)
	local inf = dmginfo:GetInflictor()
	local att = dmginfo:GetAttacker()
	if inf == NULL or inf == nil or att == NULL or inf == nil or (inf:GetClass() == nil and not(att:IsPlayer())) then return end
	if ent:IsPlayer() and att:IsPlayer() then
		if not att:CanHurt(ent) then
			return true
		end
	end
end



hook.Add("EntityTakeDamage", "sBMRP_AntiRDM", AntiRDM)


--[[-------------------------------------------------------------------------
Locational Restrictions
---------------------------------------------------------------------------]]

local xenlocations = {

}

local function LocationChanged(ply, old, new)
	if ply:IsAdmin() then return end 


end
--[[-------------------------------------------------------------------------
Weapon Restrict
---------------------------------------------------------------------------]]
local function WepRestrict(ply,wep)
	if ( ply:Team() == TEAM_VISITOR) and wep:GetClass() != "weapon_handcuffed" and not ply:IsSuperAdmin() then
		if wep:GetClass() != "labrental" and wep:GetClass() != "gmod_camera" and wep:GetClass() != "weapon_physcannon" and wep:GetClass() != "unarrest_stick" and wep:GetClass() != "weapon_keypadchecker" and wep:GetClass() != "gmod_tool" and wep:GetClass() != "weapon_physgun" and wep:GetClass() != "keys" and wep:GetClass() != "none" and wep:GetClass() != "bkeycard" then
			return false
		end
	end
	if ( ply:Team() == TEAM_TESTSUBJECT or ply:Team() == TEAM_HEADCRAB or ply:Team() == TEAM_XENHEADCRAB) and wep:GetClass() != "weapon_handcuffed" and wep:GetClass() != "keys" and wep:GetClass() != "weapon_fists" then	
		return false 
	end
	if (ply:Team() == TEAM_GARGANTUA) and wep:GetClass() != "weapon_752_m2_flamethrower" then
		return false
	end
	if wep:GetClass() == "weapon_gauss" and  ply:Team() != TEAM_HEADSURVEY then
		return false
	end
end
hook.Add( "PlayerCanPickupWeapon", "bmrp_restrict_weaponpickup", WepRestrict)

--[[-------------------------------------------------------------------------
Lab Restriction
---------------------------------------------------------------------------]]
sBMRP.Labcost = {}
sBMRP.Labcost.Small = 450
sBMRP.Labcost.Medium = 600
sBMRP.Labcost.Large = 750

sBMRP.Labs = {
	["Sector A Lab 1"] = {
		{2306}, Vector(-11028.186523, -826.935303, -188.968750), "Medium"
	},
	["Sector A Lab 2"] = {
		{2352}, Vector(-11006.873047, -44.445019, -188.968750), "Large"
	},
	["Sector A Lab 3"] = {
		{3286}, Vector(-11719.198242, -228.716599, -188.968750), "Medium"
	},
	["Sector A Lab 4"] = {
		{3285}, Vector(-11556.583984, -765.396118, -188.968750), ""
	},	
	["Sector C Lab 1"] = {
		{1881}, Vector(-3210.531738, -1184.199463, -164.968750), "Medium"
	},
	["Sector C Lab 2"] = {
		{1880}, Vector(-3875.118896, -1565.995483, -164.968750), "Medium"
	},
	["Sector C Lab 3"] = {
		{3398, 3320}, Vector(-5009.699219, -479.791321, -237.046753), "Large"
	},
	["Sector C Lab 4"] = {
		{3321}, Vector(-5333.298340, -597.528564, -237.046753), "Small"
	},
	["Sector C Lab 5"] = {
		{3319}, Vector(-5668.966309, -652.146240, -237.046753), "Small"
	},
	["Sector C Lab 6"] = {
		{3295, 3875}, Vector(-5589.724121, -1260.996338, -237.046753), "Large"
	},
	["Bio Sector Lab 3"] = {
		{3881}, Vector(-1796.953125, -2881.724854, -164.968750), "Large"
	},
	["Bio Sector Lab 2"] = {
		{3913}, Vector(-2676.284180, -2563.989502, -164.968750), "Medium"
	},
	["Bio Sector Lab 1"] = {
		{3898}, Vector(-1660.430908, -2497.404053, -164.968750), "Large"
	},
}

local meta = FindMetaTable("Player")

function meta:GetOwnedDoors()
	local owneddoors = {}
	for k,door in pairs(ents.GetAll()) do
		if door:isDoor() and door:getDoorOwner() == self or (door:getKeysCoOwners() and door:getKeysCoOwners()[self:UserID()]) then
			table.insert(owneddoors, door)
		end
	end
	return owneddoors
end

local function MapDoorNames()
	for k,ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent:isDoor() then
			for LabName,v in pairs(sBMRP.Labs) do
				for k,v in ipairs(v[1]) do -- L O O P S
					if ent:MapCreationID() == v then
						ent.LabName = LabName
					end
				end
			end
		end
	end
end 
sBMRP.MapHook("sBMRP_LabInit", MapDoorNames)


local function OnLabBuy(ply, door)
	if not sBMRP.Labs[door.LabName] then return end
	if table.Count(ply:GetOwnedDoors()) > 0 then
		return false, "You already own a lab!"
	elseif !ply:IsScience() then
		return false, "Only Scientists can own a lab!"
	elseif ply:Team() == TEAM_ASSOCIATE then
		if door:getDoorOwner() == nil then -- he is not trying to buy a co-owned lab.
			return false, "Interns cannot own a lab. You can co-own one with a scientist!"
		end
	else
		for k,v in pairs(sBMRP.Labs[door.LabName][1]) do
			if IsValid(ents.GetMapCreatedEntity(v)) then
				ents.GetMapCreatedEntity(v):keysOwn(ply)
			end
		end
		return true
	end
end
hook.Add("playerBuyDoor", "bmrp_lab-functions", OnLabBuy)

local function OnLabSell(ply, door)
	for k,v in pairs(ents.GetAll()) do
		if ent:CPPIGetOwner() == ply then
			if sBMRP.Labs[GetLocation(ent:GetPos())] then
				for k,v in pairs(sBMRP.Labs[GetLocation(ent:GetPos())][1]) do
					door = ents.GetMapCreatedEntity(v)
					plydoors = table.ValuesToKeys(ply:GetOwnedDoors())
					if plydoors[door] then
						continue
					else
						ent:Remove() 
					end
				end		
			end			
		end
	end
	ply:Notify("Locking lab doors in 10 seconds. Please vacate the lab.", 1, 10)
	if sBMRP.Labs[door.LabName] then
		for k,v in pairs(sBMRP.Labs[door.LabName][1]) do
			if isnumber(v) and IsValid(ents.GetMapCreatedEntity(v)) then
				ents.GetMapCreatedEntity(v):keysUnOwn(ply)
				ents.GetMapCreatedEntity(v):Fire("Unlock")
				timer.Simple(10, function()
					ents.GetMapCreatedEntity(v):EmitSound("buttons/combine_button_locked.wav")
					ents.GetMapCreatedEntity(v):Fire("Close")
					ents.GetMapCreatedEntity(v):Fire("Lock")
				end)
			end
		end
	end
end
hook.Add("playerSellDoor", "bmrp_lab-functions", OnLabSell)

local function LabBlockSpawning(ply)
	if ply:IsAdmin() then return end
	loc = GetLocation(ply)
	if sBMRP.Labs[loc] then
		for k,v in pairs(sBMRP.Labs[loc][1]) do
			door = ents.GetMapCreatedEntity(v)
			plydoors = table.ValuesToKeys(ply:GetOwnedDoors())
			if plydoors[door] then
				return true
			end
		end
		ply:Notify("You do not own/co-own this lab.", 1, 1)
		return false
	end
end
for k,v in pairs({"PlayerSpawnProp", "CanTool", "PlayerSpawnVehicle","PlayerSpawnRagdoll", "PlayerSpawnEffect"}) do
	hook.Add(v, "sBMRP.LabRestriction", LabBlockSpawning)
end

local function LabPlayerSpawn(ply)
	if table.Count(ply:GetOwnedDoors()) > 0 then
		for k,door in pairs(ply:GetOwnedDoors()) do
			if sBMRP.Labs[door.LabName] then
				timer.Simple(0, function()
					ply:SetPos(DarkRP.findEmptyPos(sBMRP.Labs[door.LabName][2], {}, 300, 30, Vector(16,16,64)))
					ply:SetVelocity(Vector(0,0,0))
				end)
			end
		end
	end
end
hook.Add("PlayerSpawn", "lab_rp-spawn", LabPlayerSpawn)



/*
timer.Create("sBMRP-Lab-Cleanup", .5, 0, function()
	for k,ent in pairs(ents.GetAll()) do
		if ent:CPPIGetOwner() and ent:CPPIGetOwner():IsPlayer() then
			ply = ent:CPPIGetOwner()
			if sBMRP.Labs[GetLocation(ent:GetPos())] then
				for k,v in pairs(sBMRP.Labs[GetLocation(ent:GetPos())][1]) do
					door = ents.GetMapCreatedEntity(v)
					plydoors = table.ValuesToKeys(ply:GetOwnedDoors())
					if plydoors[door] then
						continue
					else
						ent:Remove() 
					end
				end		
			end
		end
	end
end)*/

--[[-------------------------------------------------------------------------
Prop and tools
---------------------------------------------------------------------------]]
hook.Add("playerBoughtCustomEntity", "SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    ent:CPPISetOwner(ply)
end)

local function VehicleRestrict(ply,model,class,info)
	if class == "Jeep" or class == "Airboat" then
		return false
	end
end
hook.Add("PlayerSpawnVehicle","bmrp_restrict_vehiclespawn",VehicleRestrict)

local function AntiVehicleSpawn(ply, model, class, info)
	if ply:Team() == TEAM_VISITOR and not ply:IsSuperAdmin() then
		ply:ChatPrint("[BME] Sorry, you cannot spawn items as a visitor.")
		return false
	elseif ply:Team() == TEAM_TESTSUBJECT or ply:Team() == TEAM_HEADCRAB or ply:Team() == TEAM_XENHEADCRAB then
		ply:ChatPrint("[BME] Sorry, you cannot spawn items as a test subject.")
		return false
	end
end

local function AntiPropSpawn(ply, model, entity)
	if ply:Team() == TEAM_VISITOR and not ply:IsAdmin() then
		ply:ChatPrint("You cannot spawn items as a visitor.")
		entity:Remove()
	elseif ply:Team() == TEAM_TESTSUBJECT or ply:Team() == TEAM_HEADCRAB or ply:Team() == TEAM_XENHEADCRAB then
		ply:ChatPrint("You cannot spawn items as a test subject.")
		entity:Remove()
	elseif sBMRP.DisablePropsSpawn and not ply:IsAdmin() then
		ply:ChatPrint("Prop Spawning has been disabled by staff.")
		entity:Remove()
	elseif not ply:IsAdmin() or not ply:GetUserGroup() == "supporter" then
		ply:addMoney(-1)
	end
end
hook.Add( "PlayerSpawnVehicle", "bmrp_AntiPropSpawn_vehicle",AntiVehicleSpawn)
hook.Add( "PlayerSpawnedProp", "bmrp_AntiPropSpawn_prop", AntiPropSpawn)
hook.Add( "PlayerSpawnedRagdoll", "bmrp_AntiPropSpawn_ragdoll", AntiPropSpawn)
hook.Add( "PlayerSpawnedEffect", "bmrp_AntiPropSpawn_effect", AntiPropSpawn)


--[[-------------------------------------------------------------------------
Pac-User
---------------------------------------------------------------------------]]

local alloweddgroups = {
	["user"] = true,
	["noaccess"] = true
}
local function PacRestrict(ply, outfit_data)
	if alloweddgroups[ply:GetUserGroup()] or ply:GetPData("pacban") then
		return false, "Sorry, you don't have access to PAC3. Apply on our discord (http://sbmrp.com/discord), in the '#pac3_apps' channel."
	end
end
hook.Add("PrePACConfigApply", "bmrp_rectrict_pac3", PacRestrict)


local PacCommands = {
    ["unpac"] = function(ply, args)
        if not ply:IsAdmin() then ply:Notify("Unauthorized.") return end
        local targ = findPlayer(table.concat(args, " "))
        if targ then
            ply:ChatPrint("Force unwearing " .. targ:GetName() .. "'s pac.")
            targ:ConCommand("pac_clear_parts;pac_wear_parts")
            targ:ChatPrint("Your pac outfit has been forcefully removed by staff.\nConsider re-thinking your pac outfit.")
        end
    end,
    ["pacban"] = function(ply, args)
        if not ply:IsAdmin() then ply:Notify("Unauthorized.") return end
        local targ = findPlayer(table.concat(args, " "))
        if targ and targ:GetUserGroup() == "pacuser" then
            ply:ChatPrint("Force unwearing & demoting " .. targ:GetName() .. "'s pacuser rank.")
            targ:ConCommand("pac_clear_parts;pac_wear_parts")
            targ:ChatPrint("Your pac rank has been removed.")
            RunConsoleCommand("ulx", "removeuserid", targ:SteamID())
        elseif !ply:IsAdmin() then
        	targ:SetPData("pacban",true)
        	targ:ChatPrint("You have been stripped of your PAC3 permissions, while retaining your rank.")
        else
            ply:ChatPrint("Target could not be found or is immune to /pacban!.")
        end
    end,
    ["pacallow"] = function(ply, args)
    	if not ply:IsAdmin() then ply:Notify("Unauthorized.") return end
        local targ = findPlayer(table.concat(args, " "))
        if targ and targ:GetUserGroup() == "user" then
        	RunConsoleCommand("ulx","addid", targ:SteamID(), "pacuser")
        	targ:Notify("You've been given pac3 perms!")
        elseif targ:GetPData("pacban") then
        	targ:RemovePData("pacban")
        	targ:Notify("Your PAC3 ban has been removed.")
        end
    end,
}

for k,v in pairs(PacCommands) do
	sBMRP.CreateChatCommand(k, v, "PAC3")
end