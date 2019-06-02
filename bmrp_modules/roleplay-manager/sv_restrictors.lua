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

-- DarkRP doors
hook.Add("playerBuyDoor", "bmrp_door_block", function(ply, door)
	if ply:Team() == TEAM_ASSOCIATE then
		return false, "Research associates can't own labs!"
	elseif not ply:IsBlackMesa() then
		return false, "You are not a Black Mesa Employee!"
	end
end)





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