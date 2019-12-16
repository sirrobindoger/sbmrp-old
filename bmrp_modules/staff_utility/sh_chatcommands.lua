--[[-------------------------------------------------------------------------
sBMRP ChatCommand handler
---------------------------------------------------------------------------]]
-- Useless DarkRP commands
DarkRP.removeChatCommand("addagenda")
DarkRP.removeChatCommand("addlaw")
DarkRP.removeChatCommand("addjailpos")
DarkRP.removeChatCommand("agenda")
DarkRP.removeChatCommand("cr")
DarkRP.removeChatCommand("disablestorm")
DarkRP.removeChatCommand("enablestorm")
DarkRP.removeChatCommand("hitprice")
DarkRP.removeChatCommand("lottery")
DarkRP.removeChatCommand("placelaws")
DarkRP.removeChatCommand("removelaws")
DarkRP.removeChatCommand("requesthit")
DarkRP.removeChatCommand("resetlaws")
DarkRP.removeChatCommand("buyradio")
DarkRP.removeChatCommand("advert")
DarkRP.removeChatCommand("a")
DarkRP.removeChatCommand("/")
DarkRP.removeChatCommand("g")
DarkRP.removeChatCommand("ooc")



--[[-------------------------------------------------------------------------
VOX COMMANDS
---------------------------------------------------------------------------]]
local StateDisclaimers = { -- don't ask
	["off"] = 1,
	["vox"] = 5,
	["cascade"] = 6,
}

local function setvox(ply, cmd, args)
	if !StateDisclaimers[ args[1] ] then
		return false, "Invalid state entered!"
	else
		sBMRP.VOX.State = StateDisclaimers(args[1])
		sBMRP.ChatNotify(player.GetAdmins(),"Staff", ("%s set the VOX state to %s."):format(ply:GetName(), args[1]) )
		return true, {
			targets = player.GetAll(),
			targetmsg = "Staff changed the VOX to " .. args[1],
			plymsg = "You changed the VOX state.",
			consolemsg = ply:GetName() .. " set the VOX state to " .. args[1]
		}
	end
end
sBMRP.SetupFAdminCommand({
	name = "setvox",
	func = setvox,
	params = {"State (off/vox/cascade)"},
	level = 2
})

local function voxtime(ply, cmd, args)
	sBMRP.VOX.Time = tonumber(args[1]) || 120
	sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
	sBMRP.ChatNotify(player.GetAdmins(),"Staff", ("%s set the VOX time to %s."):format(ply:GetName(), sBMRP.VOX.Time) )
	return true, {
		targets = player.GetAll(),
		targetmsg = "Staff changed the VOX time to " .. sBMRP.VOX.Time,
		plymsg = "You changed the VOX time.",
		consolemsg = ply:GetName() .. " set the VOX time to " .. sBMRP.VOX.Time
	}
end
sBMRP.SetupFAdminCommand({
	name = "setvox",
	func = setvox,
	params = {"State (off/vox/cascade)"},
	level = 2
})

--[[-------------------------------------------------------------------------
Skybox
---------------------------------------------------------------------------]]
local validSkyboxes = {
	"2desert",
	"alien1",
	"alien2",
	"alien3",
	"avanti",
	"badlands",
	"black",
	"blue",
	"city",
	"cliff",
	"cx",
	"de_storm",
	"des",
	"desert",
	"dmcw",
	"doom1",
	"drkg",
	"dusk",
	"dustbowl",
	"forest",
	"green",
	"murlock",
	"neb1",
	"neb7",
	"night",
	"office",
	"snow",
	"snowlake_",
	"space",
	"tornsky",
	"trainyard",
	"xen8",
	"xen9",
	"xen10",
}


local function skybox(ply, cmd, args)
	if !table.HasValue(validSkyboxes, args[1]) then
		return false, "Invalid skybox! (Type 'skybox' in console for a list.)"
	end
	sBMRP.ChangeSkybox(args[1])
	sBMRP.ChatNotify(player.GetAdmins(),"Staff", ("%s set the skybox to %s."):format(ply:GetName(), args[1]) )
	return true, {
		targets = player.GetAll(),
		targetmsg = "Staff changed the skybox to " .. args[1],
		plymsg = "You changed the skybox.",
		consolemsg = ply:GetName() .. " set the skybox to " .. args[1]
	}
end
sBMRP.SetupFAdminCommand({
	name = "skybox",
	func = skybox,
	params = {"State (Type 'skybox' in console for a list.)"},
	level = 2
})

concommand.Add("skybox", function()
	print("VALID SKYBOXES:")
	table.Iterate(validSkyboxes, function(v) MsgC(Color(255,255,255), v .. "\n") end)
	print("Example, /skybox xen8")
end)


--[[-------------------------------------------------------------------------
Light settings
---------------------------------------------------------------------------]]

local lightTable = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}



local function setlight(ply, cmd, args)
	if !table.HasValue(lightTable, args[1]:lower()) then
		return false, "Invalid value."
	end
	sBMRP.UpdateEngineLight(lightTable[args[1]:lower()], true)
	sBMRP.ChatNotify(player.GetAdmins(),"Staff", ("%s set the light to %s/26."):format(ply:GetName(), args[1]) )
	return true, {
		targets = player.GetAdmins(),
		targetmsg = "Staff changed the light to " .. args[1],
		plymsg = "You changed the light settings.",
		consolemsg = ply:GetName() .. " set the light setting to " .. args[1]
	}
end
sBMRP.SetupFAdminCommand({
	name = "setlight",
	func = setlight,
	params = {"State (a-z)"},
	level = 2
})


--[[-------------------------------------------------------------------------
Advert/Announce
---------------------------------------------------------------------------]]
sBMRP.AnnounceState = true
local function PlayerAnnounce(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	
	local Team = ply:Team()
	if ( Team == TEAM_VISITOR or  Team == TEAM_TESTSUBJECT or  Team == TEAM_HEADCRAB ) then
		DarkRP.notify(ply, 1, 4, "You do not have a radio")
		return ""
	end
	
	if !sBMRP.AnnounceState then
		ply:ChatPrint("You try to send the message, but all you can hear is static on the other end. You assume no one heard it.")
		return ""
	end
	if ply:IsAlien() then
		DoSay = function(text)
			if text == "" then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
				return
			end
			for k,v in pairs(player.GetAll()) do
				local col = team.GetColor(ply:Team())
				if CheckInRange(Vector(-11615.540039,-4814.913574,-5864.372070),Vector(-1696.177734,-13936.375977,2038.580933),v:GetPos()) then 
					DarkRP.talkToPerson(v, col, "[Xenian Communication] " .. ply:Nick(), Color(255, 255, 0, 255), text, ply)
				end
			end
		end
	else
		DoSay = function(text)
			if text == "" then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
				return
			end
			for k,v in pairs(player.GetAll()) do
				local col = team.GetColor(ply:Team())
				DarkRP.talkToPerson(v, col, "[Announcement] " .. ply:Nick(), Color(255, 255, 0, 255), text, ply)
			end
		end
	end
	return args, DoSay
end
if SERVER then
	sBMRP.CreateChatCommand("announce", PlayerAnnounce, "Announce your message.", 4)
	sBMRP.CreateChatCommand("advert", PlayerAnnounce, "Announce your message.", 4)
end

--[[-------------------------------------------------------------------------
OOC
---------------------------------------------------------------------------]]
local rankTitles = {
	["superadmin"] = "Administrator",
	["eventcoordinator"] = "Event Co-Ordinator",
	["supporter"] = "Supporter",
	["staff"] = "Staff",
	["trialstaff"] = "Trial Staff",
}
local steamTitles = {}

sBMRP.OOCState = true
local function OOC(ply, args)
	if not GAMEMODE.Config.ooc then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", DarkRP.getPhrase("ooc"), ""))
		return ""
	end
	if !sBMRP.OOCState and !ply:IsAdmin() then
		DarkRP.notify(ply, 1, 4, "OOC is currently disabled.")
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
		local col = team.GetColor(ply:Team())
		local col2 = Color(255,255,255,255)
		local title = steamTitles[ply:SteamID()] or rankTitles[ply:GetUserGroup()] or "Player"
		if not ply:Alive() then
			col2 = Color(255,200,200,255)
			col = col2
		end

		for k,v in pairs(player.GetAll()) do
			DarkRP.talkToPerson(v, col, "("..title..") (" .. DarkRP.getPhrase("ooc") .. ") " .. ply:Name(), col2, text, ply)
		end
	end
	return args, DoSay
end
if SERVER then
	sBMRP.CreateChatCommand("/", OOC, "Global Out-of-character chat.", 1.5)
	sBMRP.CreateChatCommand("a", OOC, "Global Out-of-character chat.", 1.5)
	sBMRP.CreateChatCommand("ooc", OOC, "Global Out-of-character chat.", 1.5)
end

--[[-------------------------------------------------------------------------
Toggle OOC
---------------------------------------------------------------------------]]
local function disableooc(ply, cmd, args)
	sBMRP.OOCState = !sBMRP.OOCState
	local state = sBMRP.OOCState && "enabled" || "disabled"
	sBMRP.ChatNotify(player.GetAll(), "Staff", ply:GetName() .. " " .. state .. " OOC.")

	return true, {
		targets = player.GetAll(),
		targetmsg = "The AntiRDM Field was " .. state .. ".",
		plymsg = "You " .. state .. " OOC.",
		consolemsg = ply:GetName() .. " " .. state .. " OOC."
	}
end
sBMRP.SetupFAdminCommand({
	name = "disableooc",
	func = disableooc,
	params = {},
	level = 2
})


--[[-------------------------------------------------------------------------
it/who
---------------------------------------------------------------------------]]
local function it(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return
		end
			DarkRP.talkToRange(ply, text, "", 250)
	end
	return args, DoSay
end
if SERVER then
	sBMRP.CreateChatCommand("it", it)
	sBMRP.CreateChatCommand("who", it)
end
--[[-------------------------------------------------------------------------
Disable Announce/Advert
---------------------------------------------------------------------------]]
local function disableannounce(ply, cmd, args)
	sBMRP.AnnounceState = !sBMRP.AnnounceState
	local state = sBMRP.OOCState && "enabled" || "disabled"
	sBMRP.ChatNotify(player.GetAll(), "Staff", ply:GetName() .. " " .. state .. " /announce.")

	return true, {
		targets = player.GetAll(),
		targetmsg = "The Announcement System was " .. state .. ".",
		plymsg = "You " .. state .. " /announce.",
		consolemsg = ply:GetName() .. " " .. state .. " /announce."
	}
end
sBMRP.SetupFAdminCommand({
	name = "disableannounce",
	func = disableannounce,
	params = {},
	level = 2
})



--[[-------------------------------------------------------------------------
LOOC
---------------------------------------------------------------------------]]
local function LOOC(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		end
			DarkRP.talkToRange(ply, "(LOOC) " .. ply:Nick(), text, 250)
	end
	return args, DoSay
end
if SERVER then
	sBMRP.CreateChatCommand("looc", LOOC, "Local OOC", 1.5)
end

local function LOOCCustom(ply, txt, public)
	if string.find(txt, '^' .. ".//") ~= nil then
		args = string.gsub(txt,".// ","")
		args = string.gsub(args,".//","")
		if args == "" then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
			return ""
		else
		   DarkRP.talkToRange(ply, "(LOOC) " .. ply:Nick(), args, 250)
		   return ""
		end
	end
end
hook.Add( "PlayerSay", "chat_looccustom", LOOCCustom)


--[[-------------------------------------------------------------------------
Pac Commands
---------------------------------------------------------------------------]]


local function unpac(ply, cmd, args)
	local target = player.Find(args[1]) or false
	if target then
	   	sBMRP.ChatNotify( player.GetAdmins(), "StafF", ("%s forcefully unweared %s PAC Outfit"):format(ply:GetName(), target:GetName()))
		target:ConCommand("pac_clear_parts;pac_wear_parts")
		target:ChatPrint("Your pac outfit has been forcefully removed by staff.\nConsider re-thinking your pac outfit.")
		return true, {
			targets = {target},
			targetmsg = "Your pac outfit was removed by staff.",
			plymsg = "You removed " .. target:GetName() .. "'s pac outfit.",
			consolemsg = ply:GetName() .. " removed " .. target:GetName() .. "'s pac3 outfit."

		}
	else
		return false, "Target not found!"
	end
end
sBMRP.SetupFAdminCommand({
	name = "unpac",
	func = unpac,
	params = {"<Player>"},
	level = 2
})


local function grantpac(ply, cmd, args)
	local target = player.Find(args[1]) || args[1]
	if target && !isstring(target) && target:IsPlayer() then
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s granted PAC3 Permissions to %s."):format(ply:GetName(), target:GetName()))
		--sCONGivePac(target:SteamID())
		target:ConCommand("pac_clear_parts;pac_wear_parts")
		target:SetPData("PAC3", true)
	elseif isstring(target) && target:find("STEAM_") && tobool(util.GetPData(target, "scon",false)) then
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s granted PAC3 Permissions to %s."):format(ply:GetName(), target))
		--sCONGivePac(target)
		util.SetPData(target, "PAC3", true)
	else
		return false, "Invalid Player/SteamID!"
	end
	return true, {
		targets = {target},
		targetmsg = "You were granted PAC3 Permissions.",
		plymsg = "You granted PAC3 Permissions to " .. ( IsValid(target) && target:GetName() ) || target,
		consolemsg = ply:GetName() .. " granted PAC3 perms to " .. ( IsValid(target) && target:GetName() ) || target,
	}
end
sBMRP.SetupFAdminCommand({
	name = "grantpac",
	func = grantpac,
	params = {"<Player>"},
	level = 2
})



local function removepac(ply, cmd, args)
	local target = player.Find(args[1]) || args[1]
	if target && !isstring(target) && target:IsPlayer() then
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s revoked PAC3 Permissions to %s."):format(ply:GetName(), target:GetName()))
		--sCONGivePac(target:SteamID())
		target:ConCommand("pac_clear_parts;pac_wear_parts")
		target:SetPData("PAC3", false)
	elseif isstring(target) && target:find("STEAM_") && tobool(util.GetPData(target, "scon",false)) then
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s revoked PAC3 Permissions to %s."):format(ply:GetName(), target) )
		--sCONGivePac(target)
		util.SetPData(target, "PAC3", true)
	else
		return false, "Invalid Player/SteamID!"
	end
	return true, {
		targets = {target},
		targetmsg = "You were revoked of PAC3 Permissions.",
		plymsg = "You revoked PAC3 Permissions to " .. ( IsValid(target) && target:GetName() ) || target,
		consolemsg = ply:GetName() .. " revoked PAC3 perms to " .. ( IsValid(target) && target:GetName() ) || target,
	}
end
sBMRP.SetupFAdminCommand({
	name = "removepac",
	func = removepac,
	params = {"<Player>"},
	level = 2
})


local function voxban(ply, cmd, args)
	local targ = player.Find(args[1]) or false
	if targ and !targ:IsAdmin() then
		targ:SetPData("voxBanned", true)
		sBMRP.ChatNotify(player.GetAll(), "Staff", ("%s voxbanned %s."):format( ply:GetName(), targ:GetName()) )
		return true, {
			targets = {targ},
			targetmsg = "You were voxbanned, this is a permaneant status.",
			plymsg = "You voxbanned " .. targ:GetName(),
			consolemsg = ("%s voxbanned %s."):format(ply:GetName(), targ:GetName())
		}
	end
	return false, "Player not found."
end
sBMRP.SetupFAdminCommand({
	name = "voxban",
	func = voxban,
	params = {"<Player>"},
	level = 2
})


--[[-------------------------------------------------------------------------
Set Model
---------------------------------------------------------------------------]]
local function setmodel(ply, cmd, args)
   local target = player.Find(args[1]) or false
   
	if target then
		target:SetModel(args[2])
		return true, {
			targets = {target},
			targetmsg = "Your model was set to " .. args[2],
			plymsg = "You set " .. target:GetName() .. "'s model to " .. args[2],
			consolemsg = ("%s set %s's model to %s"):format(ply:GetName(), target:GetName(), args[2])
		}
	end
	return false, "Player not found."
end
sBMRP.SetupFAdminCommand({
	name = "setmodel",
	func = setmodel,
	params = {"<Player>", "Model"},
	level = 2
})


--[[-------------------------------------------------------------------------
Clear NPC's
---------------------------------------------------------------------------]]
local function clearnpcs(ply)
	for k,v in pairs(ents.GetAll()) do
		if v:IsNPC() and v:MapCreationID() == -1 then
			v:Remove()
		end
	end
	sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " removed all NPC's.")
	return true, {
		targets = player.GetAll(),
		targetmsg = "All NPC's have been removed.",
		plymsg = "You cleared all NPC's.",
		consolemsg = ply:GetName() .. " removed all NPC's."
	}

end
sBMRP.SetupFAdminCommand({
	name = "clearnpcs",
	func = clearnpcs,
	params = {},
	level = 2
})


local function antirdm(ply)
	sBMRP.AntiRDM = !sBMRP.AntiRDM
	local state = sBMRP.AntiRDM && "enabled" || "disabled"
	sBMRP.ChatNotify(player.GetAll(), "Staff", ply:GetName() .. " " .. state .. " the AntiRDM field.")

	return true, {
		targets = player.GetAll(),
		targetmsg = "The AntiRDM Field was " .. state .. ".",
		plymsg = "You " .. state .. " the AntiRDM Field.",
		consolemsg = ply:GetName() .. " " .. state .. " the AntiRDM field."
	}
end
sBMRP.SetupFAdminCommand({
	name = "antirdm",
	func = antirdm,
	params = {},
	level = 2
})



--[[-------------------------------------------------------------------------
Tram
---------------------------------------------------------------------------]]
sBMRP.TramState = true
local function tram(calling_ply)
	local state = !sBMRP.TramState && "enabled" || "disabled"
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
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s disabled the tram."):format(calling_ply:GetName()) )
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
		sBMRP.ChatNotify( player.GetAdmins(), "Staff", ("%s enabled the tram."):format(calling_ply:GetName()) )
	end
	return true, {
		targets = player.GetAll(),
		targetmsg = "The tram was " .. state .. ".",
		plymsg = "You " .. state .. " the tram.",
		consolemsg = ("%s set the tram to %s."):format(calling_ply:GetName(), state)
	}
end
sBMRP.SetupFAdminCommand({
	name = "tram",
	func = tram,
	params = {},
	level = 2
})



--[[-------------------------------------------------------------------------
Ragdolls
---------------------------------------------------------------------------]]
local function clearcorpses(calling_ply)
	RunConsoleCommand( "g_ragdoll_maxcount", "0")
	--[[
	for k,v in pairs(ents.FindByClass( "weapon_*" )) do
		v:Remove()
	end]]
	timer.Simple(1,function()
		RunConsoleCommand( "g_ragdoll_maxcount","32")
	end)
	sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " removed all corpses.")
	return true, {
		targets = player.GetAll(),
		targetmsg = "All corpses have been removed.",
		plymsg = "You cleared all corpses.",
		consolemsg = ply:GetName() .. " removed all corpses."
	}
end
sBMRP.SetupFAdminCommand({
	name = "tram",
	func = tram,
	params = {},
	level = 2
})


--[[-------------------------------------------------------------------------
ClearFire
---------------------------------------------------------------------------]]
local function clearfire(calling_ply)
	RunConsoleCommand( "vfire_remove_all")

	sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " removed all fire.")
	return true, {
		targets = player.GetAll(),
		targetmsg = "All fire have been removed.",
		plymsg = "You cleared all fire.",
		consolemsg = ply:GetName() .. " removed all fire."
	}

end
sBMRP.SetupFAdminCommand({
	name = "clearfire",
	func = clearfire,
	params = {},
	level = 2
})


--[[-------------------------------------------------------------------------
HECU Code
---------------------------------------------------------------------------]]

local GoodCodes = {
	["Yellow"] = true,
	["Green"] = true,
	["Black"] = true,
	["Red"] = true,
	["Blue"] = true,
}


local function hecucode(ply, cmd ,args)
	if !GoodCodes[ args[1] ] then
		return false, "Invalid code entered!"
	else
		sBMRP.SetHECUCode(args[1])
		sBMRP.ChatNotify(player.GetAdmins(),"Staff", ("%s forced the HECU code to %s."):format(ply:GetName(), args[1]) )
		return true, {
			targets = player.GetAll(),
			targetmsg = "Staff have overrided the HECU code.",
			plymsg = "You overrode the HECU code.",
			consolemsg = ply:GetName() .. " set the HECU code to " .. args[1]
		}
	end
end
sBMRP.SetupFAdminCommand({
	name = "hecucode",
	func = hecucode,
	params = {"Code (Yellow/Green/Black/Red/Blue)"},
	level = 2
})


--[[-------------------------------------------------------------------------
Xenian Toggle
---------------------------------------------------------------------------]]

local function allowsinglexenian(ply, cmd, args)
	local target = player.Find(args[1]) 
	local ply = calling_ply
	if !target then
		return false, "Player not found."
	elseif !target:IsAlien() then
		return false, "The player targeted is not a xenian."
	end
	local bool = tobool(args[2]) || false
	local state = bool and "granted" || "denied"

	target:AllowToEarth(bool)
	sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " " .. state .. " " .. target:GetName() .. "'s permission to go to earth.")
	sBMRP.LocationScan()

	local function resetperms(ply)
		target:AllowToEarth(false)
		for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
			hook.Remove(k, "sBMRP.EarthRestrictPerms_" .. ply:SteamID())
		end
	end
	for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
		hook.Add(k, "sBMRP.EarthRestrictPerms_" .. ply:SteamID(), resetperms)
	end
	return true, {
		targets = {target},
		targetmsg = "You've been given permission to go earth.",
		plymsg = "You granted" .. target:GetName() .. "'s permission to go to earth",
		consolemsg = ply:GetName() .. " " .. state .. " " .. target:GetName() .. "'s permission to go to earth."
	}
end
sBMRP.SetupFAdminCommand({
	name = "allowearth",
	func = allowsinglexenian,
	params = {"<Player>", "Allow(1/0)"},
	level = 2
})

local function allowsinglehecu(ply, cmd, args)
	local target = player.Find(args[1]) 
	local ply = calling_ply
	if !target then
		return false, "Player not found."
	elseif !target:IsHECU() then
		return false, "The player targeted is not a HECU."
	end
	local bool = tobool(args[2]) || false
	local state = bool and "granted" || "denied"

	target:AllowToBMRF(bool)
	sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " " .. state .. " " .. target:GetName() .. "'s permission to go to BMRF.")
	sBMRP.LocationScan()

	local function resetperms(ply)
		target:AllowToBMRF(false)
		for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
			hook.Remove(k, "sBMRP.BMRFRestrictPerms_" .. ply:SteamID())
		end
	end
	for k,v in pairs({"PlayerDeath", "OnPlayerChangedTeam"}) do
		hook.Add(k, "sBMRP.BMRFRestrictPerms_" .. ply:SteamID(), resetperms)
	end
	return true, {
		targets = {target},
		targetmsg = "You've been given permission to go BMRF.",
		plymsg = "You granted" .. target:GetName() .. "'s permission to go to BMRF",
		consolemsg = ply:GetName() .. " " .. state .. " " .. target:GetName() .. "'s permission to go to BMRF."
	}
end
sBMRP.SetupFAdminCommand({
	name = "allowbmrf",
	func = allowsinglehecu,
	params = {"<Player>", "Allow(1/0)"},
	level = 2
})

--[[-------------------------------------------------------------------------
Building toggle
---------------------------------------------------------------------------]]
sBMRP.DisableBuilding = false
local function disablebuilding(ply)
	if not sBMRP.DisableBuilding then
		sBMRP.DisableBuilding = true
		sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " disabled bulding for players.")
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
		sBMRP.ChatNotify(player.GetAdmins(), "Staff", ply:GetName() .. " enabled bulding for players.")
		for k,v in pairs({"PlayerSpawnProp", "CanTool", "PlayerSpawnVehicle","PlayerSpawnRagdoll", "PlayerSpawnEffect"}) do
			hook.Remove(v, "sBMRP.BlockSpawning")
		end
	end
	local state = !sBMRP.DisableBuilding and "enabled" or "disabled"
	return true, {
		targets = player.GetAll(),
		targetmsg = "Building has " .. state .. "by staff.",
		plymsg = "You " .. state .. " player building.",
		consolemsg = ply:GetName() .. " " .. state .. " " .. "player building."
	}
end
sBMRP.SetupFAdminCommand({
	name = "disablebuilding",
	func = disablebuilding,
	params = {},
	level = 2
})

