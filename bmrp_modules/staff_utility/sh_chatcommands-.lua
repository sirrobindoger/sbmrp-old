CATEGORY_NAME = "BMRP"
--[[-------------------------------------------------------------------------
Pac Commands
---------------------------------------------------------------------------]]
local function sCONGivePac(targ, bool)
	if not isstring(targ) then return end
	local method = (bool and "DELETE") or nil
	if sCON:IsRegistered(targ) then
		local member = sCON.Guild:GetMember(targ)
		if bool then
			member:EditRole("542120309210218508", "DELETE")
		else
			member:EditRole("542120309210218508")
		end
	else
		print(targ .. "gay")
	end
end

local function playernames() local playernames = {} for k,v in pairs(player.GetAll()) do table.insert(playernames, v:GetName()) end return playernames end

function ulx.unpac(ply, target_ply)
   local target = target_ply[1] or false
   
	if target then
	   ulx.fancyLog( player.GetAdmins(), "[Staff]: #P forcefully unweared #P PAC Outfit",ply, target)
		target:ConCommand("pac_clear_parts;pac_wear_parts")
		target:ChatPrint("Your pac outfit has been forcefully removed by staff.\nConsider re-thinking your pac outfit.")
	end
end
local unpac = ulx.command(CATEGORY_NAME .. " - PAC3", "ulx unpac", ulx.unpac, "!unpac", true, false)
unpac:addParam{ type=ULib.cmds.PlayersArg }
unpac:defaultAccess(ULib.ACCESS_ADMIN)
unpac:help("Forefully make a player unwear their current PAC outfit.")

function ulx.grantpac(ply, targ)
	local target = sCON:findPlayer(targ) or targ or false
	if target and not isstring(target) and target:IsPlayer() then
		ulx.fancyLog(player.GetAll(), "#P granted PAC3 permissions to #P.", ply, target)
		sCONGivePac(target:SteamID())
		target:ConCommand("pac_clear_parts;pac_wear_parts")
		target:SetPData("PAC3", true)
	elseif isstring(target) and target:find("STEAM_") and tobool(util.GetPData(target, "scon",false)) then
		ulx.fancyLog(player.GetAll(), "#P granted PAC3 permissions to STEAMID: #s.", ply, targ)
		sCONGivePac(target)
		util.SetPData(target, "PAC3", true)
	else
		ULib.tsayError(ply, "Invalid playername/steamid!")
	end
end
local grantpac = ulx.command(CATEGORY_NAME .. " - PAC3", "ulx grantpac", ulx.grantpac, "!grantpac", true, false)
grantpac:addParam{ type=ULib.cmds.StringArg, completes=playernames(), hint="Name or Steamid",}
grantpac:defaultAccess( ULib.ACCESS_ADMIN)
grantpac:help( "Grants the target player or steamid PAC3 permissions." )


function ulx.removepac(ply, targ)
	local target = sCON:findPlayer(targ) or targ or false
	if target and not isstring(target) and target:IsPlayer() then
		ulx.fancyLog(player.GetAll(), "#P revoked PAC3 permissions to #P.", ply, target)
		target:SetPData("PAC3", false)
		sCONGivePac(target:SteamID())
	elseif isstring(target) and target:find("STEAM_") and tobool(util.GetPData(target, "scon",false)) then
		ulx.fancyLog(player.GetAll(), "#P revoked PAC3 permissions to STEAMID: #s.", ply, targ)
		sCONGivePac(target)
		util.SetPData(target, "PAC3", false)
	else
		ULib.tsayError(ply, "Invalid playername/steamid!")
	end
end
local removepac = ulx.command(CATEGORY_NAME .. " - PAC3", "ulx removepac", ulx.removepac, "!removepac", true, false)
removepac:addParam{ type=ULib.cmds.StringArg, completes=playernames(), hint="Name or Steamid",}
removepac:defaultAccess( ULib.ACCESS_ADMIN)
removepac:help( "Grants the target player or steamid PAC3 permissions." )

--[[-------------------------------------------------------------------------
Prop Protection shit
---------------------------------------------------------------------------]]
local ToJSON = util.TableToJSON
local propoverrides = {
	["worldspawn"] = true,
	["player"] = true,
}
function ulx.addBlockedCollisionEnt(ply, entityclass, remove)
	local entity = entityclass && not entityclass == "" || ply:GetEyeTrace().Entity:GetClass()
	if not entity || propoverrides[ entity ] then
		ULib.tsayError( calling_ply, "You must be looking at a prop || type its class!", true )
		return
	end
	if not remove then 
		sPropProtection.NoCollidedEnts[entity] = true -- update list
		file.Write("blockedents.txt", ToJSON(sPropProtection.NoCollidedEnts))
		ulx.fancyLog( player.GetAll(), "#P added #s to the collision blacklist.",ply, entity)
		if sPropProtection.CollisionOverride then
			for k,v in pairs(ents.FindByClass(entity)) do
				if not v:CPPIGetOwner() then continue end
				v:SetCustomCollisionCheck(true)
				v:CollisionRulesChanged()
			end
		end
	else
		sPropProtection.NoCollidedEnts[entity] = false
		file.Write("blockedents.txt", ToJSON(sPropProtection.NoCollidedEnts))
		ulx.fancyLog( player.GetAll(), "#P removed #s from the collision blacklist.",ply, entity)
		if sPropProtection.CollisionOverride then
			for k,v in pairs(ents.FindByClass(entity)) do
				if not v:CPPIGetOwner() then continue end
				v:SetCustomCollisionCheck(false)
				v:CollisionRulesChanged()
			end
		end
	end
end

local addBlockedCollisionEnt = ulx.command(CATEGORY_NAME .. "- Players", "ulx addblacklist", ulx.addBlockedCollisionEnt, "!addblacklist", true, false)
addBlockedCollisionEnt:addParam{ type=ULib.cmds.StringArg, hint="Entity class (you can also look at the ent).",ULib.cmds.optional}
addBlockedCollisionEnt:addParam{ type=ULib.cmds.BoolArg, invisible=true}
addBlockedCollisionEnt:defaultAccess( ULib.ACCESS_ADMIN)
addBlockedCollisionEnt:help( "Blacklist/Unblacklist the entered entity/entity you are looking at from colliding with other entitys." )
addBlockedCollisionEnt:setOpposite( "ulx removeblacklist", {_, _, true}, "!removeblacklist" )


--[[-------------------------------------------------------------------------
Anti RDM
---------------------------------------------------------------------------]]
function ulx.antirdm(calling_ply)	
	if not sBMRP.AntiRDM then
		sBMRP.AntiRDM = true
		ulx.fancyLog( player.GetAll(), "#P enabled the AntiRDM Field.",calling_ply)
	else
		sBMRP.AntiRDM = false
		ulx.fancyLog( player.GetAll(), "#P disabled the AntiRDM Field.",calling_ply)
	end
end
local antirdm = ulx.command(CATEGORY_NAME .. " - Players", "ulx antirdm", ulx.antirdm, "!antirdm", true, false)
antirdm:defaultAccess(ULib.ACCESS_ADMIN)
antirdm:help("Toggle AntiRDM.")

--[[-------------------------------------------------------------------------
Tram
---------------------------------------------------------------------------]]
sBMRP.TramState = true
function ulx.tram(calling_ply)
	if sBMRP.TramState then
		timer.Simple(.1, function() sBMRP.TramState = false end)
		for k, v in pairs( ents.FindByName( "train" ) ) do
			v:SetMoveType(0)
			v:EmitSound("npc/scanner/scanner_explode_crash2.wav", 80, 100)
			v:EmitSound("npc/dog/dog_straining1.wav", 80, 100)
			v:EmitSound("ambient/machines/wall_ambient1.wav", 80, 100)
			v:EmitSound("ambient/machines/zap3.wav", 80,100)
		end
		for k, v in pairs( ents.FindByName( "traindoor1") ) do
			v:Fire( "Open" )
		end
		for k, v in pairs( ents.FindByName( "traindoor2") ) do
			v:Fire( "Open" )
		end
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P disabled the tram.",calling_ply)
	else
		sBMRP.TramState = true
		for k, v in pairs( ents.FindByName( "train" ) ) do
			v:SetMoveType(7)
			v:EmitSound("npc/attack_helicopter/aheli_charge_up.wav", 80, 100)
			v:EmitSound("npc/scanner/cbot_energyexplosion1.wav", 80, 100)
			v:EmitSound("ambient/machines/wall_ambient1.wav", 80, 100)
		end
		
		for k, v in pairs( ents.FindByName( "traindoor1") ) do
			v:Fire( "Close" )
		end
		for k, v in pairs( ents.FindByName( "traindoor2") ) do
			v:Fire( "Close" )
		end
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P enabled the tram.",calling_ply)
	end
end

tram = ulx.command(CATEGORY_NAME .. " - Map", "ulx tram", ulx.tram, "!tram", true, false)
tram:defaultAccess(ULib.ACCESS_ADMIN)
tram:help("Toggle the tram to be broken or working.")

--[[-------------------------------------------------------------------------
Ragdolls
---------------------------------------------------------------------------]]
function ulx.ragdolls(calling_ply)
	RunConsoleCommand( "g_ragdoll_maxcount", "0")
	--[[
	for k,v in pairs(ents.FindByClass( "weapon_*" )) do
		v:Remove()
	end]]
	timer.Simple(1,function()
		RunConsoleCommand( "g_ragdoll_maxcount","32")
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P cleared all corpses.",calling_ply)
	end)
end
ragdolls = ulx.command(CATEGORY_NAME .. " - Map", "ulx ragdolls", ulx.ragdolls, "!ragdolls", true, false)
ragdolls:defaultAccess(ULib.ACCESS_ADMIN)
ragdolls:help("Remove Ragdolls.")
--[[-------------------------------------------------------------------------
ClearFire
---------------------------------------------------------------------------]]
function ulx.clearfire(calling_ply)
	RunConsoleCommand( "vfire_remove_all")

	ulx.fancyLog( player.GetAdmins(), "[Staff]: #P cleared all fire.",calling_ply)

end
clearfire = ulx.command(CATEGORY_NAME .. " - Map", "ulx clearfire", ulx.clearfire, "!clearfire", true, false)
clearfire:defaultAccess(ULib.ACCESS_ADMIN)
clearfire:help("Remove fire.")

--[[-------------------------------------------------------------------------
HECU Code
---------------------------------------------------------------------------]]

local GoodCodes = {
	["Yellow"] = true,
	["Green"] = true,
	["Black"] = true,
	["Red"] = true,
}


function ulx.hecucode(ply, code)
	if !GoodCodes[ code ] then
		ULib.tsayError( ply, "Invalid code entered, valid codes (case sensitive):\n " .. table.concat(table.GetKeys(GoodCodes), ", "))
	else
		sBMRP.SetHECUCode(code)
		ulx.fancyLog( player.GetAdmins(), "#P forced the HECU code to #s.",ply, code)
	end
end
local hecucode = ulx.command(CATEGORY_NAME .. " - Map", "ulx hecucode", ulx.hecucode, "!hecucode", true, false)
hecucode:addParam{ type=ULib.cmds.StringArg, completes=GoodCodes, hint="Code to change too.",}
hecucode:defaultAccess( ULib.ACCESS_ADMIN)
hecucode:help( "Forces the HECU code." )
--[[-------------------------------------------------------------------------
Timed cleanup
---------------------------------------------------------------------------]]


function ulx.cleanup(ply, time)
	local timeLeft = time
	ulx.fancyLog( player.GetAll(), "#P triggered a timed mapclean.",ply)
	timer.Create("bmrp_cleanup", 1, timeLeft, function()
		if timeLeft >= 1 then
			RunConsoleCommand("darkrp", "admintellall", "Cleanup in " .. timeLeft .. " seconds.")
			timeLeft = timeLeft - 1
		else
			RunConsoleCommand("fadmin", "cleanup")
		end
	end)
end
local cleanup = ulx.command("Essentials", "ulx cleanup", ulx.cleanup, "!cleanup", true, false)
cleanup:addParam{type=ULib.cmds.NumArg, min=10, max=420,default=60,hint="time(seconds)",ULib.cmds.round}
cleanup:defaultAccess(ULib.ACCESS_ADMIN)
cleanup:help("Timed cleanup")
--[[-------------------------------------------------------------------------
Utime
---------------------------------------------------------------------------]]
local function ulxGetTimeC(ply, target_ply)
   local target = target_ply[1] or false
   
	if target then
		local curTime, totalTime = Utime.timeToStr(target:GetUTimeSessionTime()), Utime.timeToStr(target:GetUTimeTotalTime())
		print(curTime .. totalTime)
		ply:ChatPrint(("Time Info for %s:\nSession Time: %s\nTotal Time: %s"):format(target:GetName(), curTime, totalTime))
	end
end
local ulxGetTime = ulx.command("Essentials", "ulx showtime", ulxGetTimeC, "!showtime", true, false)
ulxGetTime:addParam{ type=ULib.cmds.PlayersArg }
ulxGetTime:defaultAccess(ULib.ACCESS_ALL)
ulxGetTime:help("Get info about a player's time.")

--[[-------------------------------------------------------------------------
Lockdown
---------------------------------------------------------------------------]]

local goodgroups = table.ValuesToKeys({
	"superadmin",
	"staff",
	"trialstaff",
	"supporter"
})
function ulx.lockdown(calling_ply, shouldkick, unlockdown)
	if shouldkick then
		for k,v in pairs(player.GetAll()) do
			if not v:IsAdmin() then 
				v:Kick("Server is entering into a lockdown state.\nOnly admins may enter at this time.\nhttps://sbmrp.com/discord")
			end
		end
	end
	if not unlockdown then
		--RunConsoleCommand("sv_password","Sirro2.0")
		hook.Add("CheckPassword", "bmrp_password-check", function(steamid, ip, svpass, clpass, name)
			local steamid = util.SteamIDFrom64(steamid)
			if not ULib.ucl.users[steamid] || not ULib.ucl.users[steamid].group || not goodgroups[ULib.ucl.users[steamid].group] then
				Log("[" .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp ) .. "] " .. name .. "/" .. steamid .. " attempted to connect, but has invalid permissions. ")
				return false, "--==Access Restricted: Unauthorized Usergroup.==--\n\nThe server is currently in lockdown.\nTo learn more please visit sbmrp.com/discord\n\nsCON | " .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )
			end
		end)
		ulx.fancyLog( player.GetAll(), "#P activated server lockdown.",calling_ply)
	else
		hook.Remove("CheckPassword", "bmrp_password-check")
		--RunConsoleCommand("sv_password","")
		ulx.fancyLog( player.GetAll(), "#P removed server lockdown.",calling_ply)
	end

end
lockdown = ulx.command(CATEGORY_NAME .. " - Players", "ulx lockdown", ulx.lockdown, "!lockdown", true, false)
lockdown:addParam{ type=ULib.cmds.BoolArg, hint="Kick non-admins?" }
lockdown:addParam{ type=ULib.cmds.BoolArg, invisible=true}
lockdown:defaultAccess(ULib.ACCESS_SUPERADMIN)
lockdown:setOpposite( "ulx unlockdown", {_, _, true}, "!unlockdown" )
lockdown:help("Locks down the server.")

--[[-------------------------------------------------------------------------
Allow ALL xenians/hecu
---------------------------------------------------------------------------]]

function ulx.AllowAllHECU(calling_ply)	
	if not sBMRP.AllowHECUToBMRF then
		sBMRP.AllowHECUToBMRF = true
		ulx.fancyLog( player.GetAll(), "#P allowed HECU's entry into BMRF!",calling_ply)
	else
		sBMRP.AllowHECUToBMRF = false
		for k,v in pairs(player.GetAll()) do
			v:AllowToBMRF(false)
		end
		sBMRP.LocationScan()
		ulx.fancyLog( player.GetAll(), "#P revoked HECU's entry into BMRF.",calling_ply)
	end
end
local AllowAllHECU = ulx.command(CATEGORY_NAME .. " - Players", "ulx allowallhecu", ulx.AllowAllHECU, "!allowallhecu", true, false)
AllowAllHECU:defaultAccess(ULib.ACCESS_ADMIN)
AllowAllHECU:help("Enable or disable HECU's entry into BMRF. Revoking entry will also reset all allowsinglehecu to their default value.")

function ulx.AllowAllXenians(calling_ply)	
	if not sBMRP.AllowEarthToXen then
		sBMRP.AllowEarthToXen = true
		ulx.fancyLog( player.GetAll(), "#P allowed Xenian's entry into Earth!",calling_ply)
	else
		sBMRP.AllowEarthToXen = false 
		for k,v in pairs(player.GetAll()) do
			v:AllowToEarth(false)
		end
		sBMRP.LocationScan()
		ulx.fancyLog( player.GetAll(), "#P revoked Xenian's entry into Earth.",calling_ply)
	end
end
local AllowAllXenians = ulx.command(CATEGORY_NAME .. " - Players", "ulx allowallxenians", ulx.AllowAllXenians, "!allowallxenians", true, false)
AllowAllXenians:defaultAccess(ULib.ACCESS_ADMIN)
AllowAllXenians:help("Enable or disable Xenian's entry into Earth. Revoking entry will also reset all allowsinglexenian to their default value.")


--[[-------------------------------------------------------------------------
NPC XEN SHIT
---------------------------------------------------------------------------]]
function ulx.npcpopulation(calling_ply, pop)
	local population = tonumber(pop)
	if population == 0 then
		sBMRP.NPCs.Sterile = true
		sBMRP.NPCs.Population = 0
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P disabled the spawning of xenian NPCs",calling_ply)
	else
		sBMRP.NPCs.Sterile = false
		sBMRP.NPCs.Population = population
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P changed the xenian population to #i",calling_ply, population)
		for k,v in pairs(ents.GetAll()) do
			if v:IsNPC() and v.PrintName and sBMRP.LocList.Xen[GetLocation(v:GetPos())] then
				SpawnXenFlash(v:GetPos())
				v:Remove()
			end
		end
	end
	
end
local npcpopulation = ulx.command(CATEGORY_NAME .. " - Map", "ulx npcpopulation", ulx.npcpopulation, nil, false, false )
npcpopulation:addParam{type=ULib.cmds.NumArg, min=0, max=20,default=20,hint="Amount of NPCs",ULib.cmds.round}
npcpopulation:defaultAccess(ULib.ACCESS_ADMIN)
npcpopulation:help("Sets NPC Population in xen, 0 to disable spawning.")

local behaviors = { -- don't ask
	["hostile"] = D_HT,
	["fear"] = D_FR,
	["neutral"] = D_NU,
	["like"] = D_LI,
}

local titles = {
	"hostile",
	"fear",
	"neutral",
	"like"
}

function ulx.xenbehavior(calling_ply, state)
	sBMRP.NPCs.Behavior = behaviors[state]
	ulx.fancyLog( player.GetAdmins(), "[Staff]: #P changed the Xenian NPC's state to #s",calling_ply, state)
	for k,v in pairs(ents.GetAll()) do
		if v:IsNPC() and v.PrintName and sBMRP.LocList.Xen[GetLocation(v:GetPos())] then
			SpawnXenFlash(v:GetPos())
			v:Remove()
		end
	end
end

local xenbehavior = ulx.command( CATEGORY_NAME  .. " - Map", "ulx xenbehavior", ulx.xenbehavior, nil, false, false)
xenbehavior:addParam{ type=ULib.cmds.StringArg, completes=titles, hint="Xen NPC's Behavior", error="invalid state \"%s\" specified", ULib.cmds.restrictToCompletes }
xenbehavior:defaultAccess( ULib.ACCESS_ADMIN)
xenbehavior:help( "Sets the xenian NPC's behavior towards humans." )

--[[-------------------------------------------------------------------------
Lab prop spawning
---------------------------------------------------------------------------]]

function ulx.labprotection(calling_ply)	
	if not sBMRP.LabPropProtection then
		sBMRP.LabPropProtection = true
		ulx.fancyLog( player.GetAdmins(), "#P revoked player's rights to build in labs they do not own.",calling_ply)
	else
		sBMRP.LabPropProtection = false

		ulx.fancyLog( player.GetAdmins(), "#P granted player's rights to build in labs they do not own.",calling_ply)
	end
end
local labprotection = ulx.command(CATEGORY_NAME .. " - Players", "ulx labprotection", ulx.labprotection, "!labprotection", true, false)
labprotection:defaultAccess(ULib.ACCESS_ADMIN)
labprotection:help("Toggle weather or not players are allowed to build in labs they do not own.")

--[[-------------------------------------------------------------------------
Xenian Toggle
---------------------------------------------------------------------------]]

function ulx.allowsinglexenian(calling_ply, target_ply, disallow)
	local target = target_ply[1]
	local ply = calling_ply
	if !target:IsAlien() then
		ULib.tsayError( calling_ply, "The player targeted is not a xenian.", true )
		return
	end
	local recepients = table.insert(player.GetAdmins(), target)
	if not disallow then
		target:AllowToEarth(true)
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P gave #P permission go to earth.",calling_ply, target)
	else
		ulx.fancyLog({unpack(player.GetAdmins()), target}, "#P revoked #P's permission to go earth.",calling_ply, target)
		target:AllowToEarth(false)
		sBMRP.LocationScan()
	end

	local function resetperms(ply)
		target:AllowToEarth(false)
		for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
			hook.Remove(k, "sBMRP.EarthRestrictPerms")
		end
	end
	for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
		hook.Add(k, "sBMRP.EarthRestrictPerms", resetperms)
	end
end
local allowsinglexenian = ulx.command(CATEGORY_NAME .. " - Players", "ulx allowsinglexenian", ulx.allowsinglexenian, "!allowsinglexenian", true, false)
allowsinglexenian:addParam{ type=ULib.cmds.PlayersArg }
allowsinglexenian:addParam{ type=ULib.cmds.BoolArg, invisible=true}
allowsinglexenian:defaultAccess(ULib.ACCESS_ADMIN)
allowsinglexenian:help("Allow the temporary access of a xenian player, will auto revoke on death/teamchange.")
allowsinglexenian:setOpposite( "ulx unallowsinglexenian", {_, _, true}, "!unallowsinglexenian" )

function ulx.allowsinglehecu(calling_ply, target_ply, disallow)
	local target = target_ply[1]
	local ply = calling_ply
	local reciptients = {}

	if !target:IsHECU() then
		ULib.tsayError( calling_ply, "The player targeted is not a HECU.", true )
		return
	end
	if not disallow then
		target:AllowToBMRF(true)
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P gave #P permission go to earth.",calling_ply, target)
	else
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P revoked #P's permission to go earth.",calling_ply, target)
		target:AllowToBMRF(false)
		sBMRP.LocationScan()
	end

	local function resetperms(ply)
		target:AllowToBMRF(false)
		for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
			hook.Remove(k, "sBMRP.AllowToBMRF")
		end
	end
	for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
		hook.Add(k, "sBMRP.AllowToBMRF", resetperms)
	end
end
local allowsinglehecu = ulx.command(CATEGORY_NAME.. " - Players", "ulx allowsinglehecu", ulx.allowsinglehecu, "!allowsinglehecu", true, false)
allowsinglehecu:addParam{ type=ULib.cmds.PlayersArg }
allowsinglehecu:addParam{ type=ULib.cmds.BoolArg, invisible=true}
allowsinglehecu:defaultAccess(ULib.ACCESS_ADMIN)
allowsinglehecu:help("Allow the temporary access of a HECU player, will auto revoke on death/teamchange.")
allowsinglehecu:setOpposite( "ulx unallowsinglehecu", {_, _, true}, "!unallowsinglehecu" )

--[[-------------------------------------------------------------------------
Building toggle
---------------------------------------------------------------------------]]
sBMRP.DisableBuilding = false
function ulx.DisableBuilding(calling_ply)
	if not sBMRP.DisableBuilding then
		sBMRP.DisableBuilding = true
		ulx.fancyLog( player.GetAll(), "#P disabled building for players.",calling_ply)
		local function blockspawning(ply)
			if not ply:IsAdmin() then
				return false
			end
		end
		for k,v in pairs({"PlayerSpawnProp", "CanTool", "PlayerSpawnVehicle","PlayerSpawnRagdoll", "PlayerSpawnEffect"}) do
			hook.Add(v, "sBMRP.BlockSpawning", blockspawning)
		end

	else
		sBMRP.DisableBuilding = false
		ulx.fancyLog( player.GetAll(), "#P enabled building for players.",calling_ply)
		for k,v in pairs({"PlayerSpawnProp", "CanTool", "PlayerSpawnVehicle","PlayerSpawnRagdoll", "PlayerSpawnEffect"}) do
			hook.Remove(v, "sBMRP.BlockSpawning")
		end
	end
end
local DisableBuilding = ulx.command(CATEGORY_NAME .. " - Map", "ulx disablebuilding", ulx.DisableBuilding, "!disablebuilding", true, false)
DisableBuilding:defaultAccess(ULib.ACCESS_ADMIN)
DisableBuilding:help("Enable or disable propspawing and toolgun usage.")