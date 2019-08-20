--[[-------------------------------------------------------------------------
sBMRP ChatCommand handler
---------------------------------------------------------------------------]]
CATEGORY_NAME = "BMRP"
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
StateDisclaimers = { -- don't ask
	"off",
	"cvox",
	"cvox-cascade",
	"cjohnson",
	"bms-vox",
	"bms-cascade",
}

function ulx.setvox(calling_ply, state)
	sBMRP.VOX.State = table.KeyFromValue(StateDisclaimers, state)
	ulx.fancyLog( player.GetAdmins(), "[Staff]: #P changed the VOX state to #s",calling_ply, state)
end

local setvox = ulx.command( CATEGORY_NAME .. " - Chat", "ulx setvox", ulx.setvox, nil, false, false)
setvox:addParam{ type=ULib.cmds.StringArg, completes=StateDisclaimers, hint="Vox Alert State", error="invalid state \"%s\" specified", ULib.cmds.restrictToCompletes }
setvox:defaultAccess( ULib.ACCESS_ADMIN)
setvox:help( "Sets the vox state." )

function ulx.voxtime(calling_ply, time)
	sBMRP.VOX.Time = tonumber(time)
	sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
	ulx.fancyLog( player.GetAdmins(), "[Staff]: #P changed the VOX time interval to #i seconds",calling_ply, time)
end
local voxtime = ulx.command(CATEGORY_NAME .. " - Chat", "ulx voxtime", ulx.voxtime, nil, false, false )
voxtime:addParam{type=ULib.cmds.NumArg, min=10, max=720,default=60,hint="time(seconds)",ULib.cmds.round}
voxtime:defaultAccess(ULib.ACCESS_ADMIN)
voxtime:help("Sets the vox time in seconds.")

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

function ulx.DisableOOC(ply, args)
	sBMRP.OOCState = !sBMRP.OOCState
	if sBMRP.OOCState == false then
		ulx.fancyLog( player.GetAll(), "#P disabled the OOC Chat.",ply)
	else
		ulx.fancyLog( player.GetAll(), "#P enabled the OOC Chat.",ply)
	end
end
local DisableOOC = ulx.command(CATEGORY_NAME .. " - Chat", "ulx disableooc", ulx.DisableOOC, "!disableooc", true, false )
DisableOOC:defaultAccess(ULib.ACCESS_ADMIN)
DisableOOC:help("Disable or enable OOC.")




--[[-------------------------------------------------------------------------
Dev Box commands
---------------------------------------------------------------------------]]
local DevBoxs = {
	["Open"] = Vector(-11456.893554688,3849.1801757813,-1967.96875),
	["Closed"] = Vector(-11556.98828125,7204.3393554688,-1967.96875),
	["Canyon"] = Vector(-9100.609375,5628.7661132813,-2092.8466796875),
	["Helipad"] = Vector(-8807.2734375,8082.2431640625,-1967.96875),
}
local devtitle = table.GetKeys(DevBoxs)

function ulx.devbox(ply, args)

	if DevBoxs[args] then
		local pos = DarkRP.findEmptyPos(DevBoxs[args], {ply}, 300, 10, Vector(16, 16, 64))
		ply:SetPos(pos)
		SpawnXenFlash(pos)

	end
end
local devbox = ulx.command(CATEGORY_NAME .. " - Players", "ulx devbox", ulx.devbox, "!devbox", true, false )
devbox:addParam{ type=ULib.cmds.StringArg, completes=devtitle, hint="Dev Box name", error="invalid location \"%s\" specified", ULib.cmds.restrictToCompletes }
devbox:defaultAccess( ULib.ACCESS_ADMIN)
devbox:help( "Teleports you to a dev box location to build in." )

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
function ulx.toggleannounce(calling_ply, args)

	if sBMRP.AnnounceState then
		sBMRP.AnnounceState = false
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P disabled the announcement system.",calling_ply)
	else
		sBMRP.AnnounceState = true
		ulx.fancyLog( player.GetAdmins(), "[Staff]: #P enabled the announcement system.",calling_ply)
	end
end
local toggleannounce = ulx.command(CATEGORY_NAME .. " - Chat", "ulx toggleannounce", ulx.toggleannounce, "!toggleannounce", true, false )
toggleannounce:defaultAccess(ULib.ACCESS_ADMIN)
toggleannounce:help("Disable or enable the announcement system.")



--[[-------------------------------------------------------------------------
Create custom job 

TEAM_CONTROLLER = DarkRP.createJob("Xenian Controller", {
	color = Color(234, 0, 255, 255),
	model = {"models/player/bms_controller.mdl"},
	description = You are a species of Xenian that can control the lesser minds of the creatures that inhabit Xen. ,
	weapons = {"weapon_possessor", "weapon_sporelauncher"},
	command = "controller",
	max = 2,
	salary = 250,
	admin = 0,
	vote = true,
	hasLicense = false,
	candemote = false,
	category = "Xenians",
	rdmgroup = "Xenian",
	noradio = true,
	isalien = true,
})
---------------------------------------------------------------------------]]
if SERVER then
	util.AddNetworkString("ulx.job")
end

local function getJobCategories() -- Getting all the job categories in DarkRP because falco couldn't have made it any fucking easier.
	local c = {}
	local j = table.Copy(DarkRP.getCategories())
	for k, v in pairs(j) do
		if k != "jobs" then
			continue
		end
		for _,l in pairs(v) do
			if !c[l.name] then
				c[l.name] = true
			end
		end
	end
	return table.GetKeys(c)
end

function getJobs(keys, command) -- Getting all the job categories in DarkRP because falco couldn't have made it any fucking easier.
	local c = {}
	local j = table.Copy(DarkRP.getCategories())
	for k, v in pairs(j) do
		if k != "jobs" then
			continue
		end
		for _,l in pairs(v) do
			for x,o in pairs(l.members) do
				if !select(1, DarkRP.getJobByCommand(o.command)) then continue end
				c[o.name] = !command and o.team or o.command
			end
		end
	end
	if keys then
		return table.GetKeys(c)
	else
		return c
	end
end


local rdmGroups = {
	"BMRF",
	"Xenian",
	"None",
}

local factions = {
	"Security",
	"Black Mesa (not scientist or security)",
	"Scientist",
	"Xenians",
	"HECU",
	"None"
}

function ulx.CreateJob(ply, name, desc, color, model, weapons, command, max, rdmgroup, canannounce, category, hide, faction)
	ply:AddText(Color(255,255,255), "Compiling job...")
	print(faction)
	local ctab = string.Explode(",", color:Replace(" ", ""))
	local wtab = string.Explode(",", weapons:Replace(" ", ""))
	local mtab = string.Explode(",", model:Replace(" ", ""))
	local job_struct = {
		color = Color( ctab[1] and tonumber(ctab[1]) or 255,ctab[2] and tonumber(ctab[2]) or 255, ctab[3] and tonumber(ctab[3]) or 255),
		model = mtab,
		description = desc,
		weapons = wtab,
		command = command,
		max = max,
		salary = 0,
		admin = hide and 1 or 0,
		vote = false,
		hasLicence = false,
		candemote = false,
		isblackmesa = true,
		category = category,
		rdmgroup = rdmgroup != "None" and rdmgroup or false,
		isblackmesa = faction != "Xenians" and faction != "HECU" and faction != "None",
		isscience = faction == "Scientist",
		isalien = faction == "Xenians",
		issecurity = faction == "Security",
		ishecu = faction == "HECU",
	}
	job_struct.name = name
	job_struct.default = DarkRP.DARKRP_LOADING
	local valid, err, hints = DarkRP.validateJob(job_struct)
	if not valid then
		ply:AddText(Color(255,0,0), "Compilation failed, check console!")
		DarkRP.error(string.format("Failed creating custom team! %s!\n%s", job_struct.name or "", err), 2, hints) 
		return
	end
	ply:AddText(Color(0,255,0), "Compilation successfull!")
	DarkRP.createJob(job_struct.name, job_struct)
	net.Start("ulx.job")
		net.WriteBool(false)
		net.WriteTable(job_struct)
	net.Broadcast()
	ulx.fancyLog( player.GetAll(), "#P created the job #s.",ply, job_struct.name)
end
local CreateJob = ulx.command(CATEGORY_NAME .. " - Jobs", "ulx createjob", ulx.CreateJob, nil, false, false )
CreateJob:addParam{ type=ULib.cmds.StringArg, hint="Name of the job."}
CreateJob:addParam{ type=ULib.cmds.StringArg, hint="Description of the job."}
CreateJob:addParam{ type=ULib.cmds.StringArg, hint='255,255,255'}
CreateJob:addParam{ type=ULib.cmds.StringArg, hint='models/player/gman_high.mdl'}
CreateJob:addParam{ type=ULib.cmds.StringArg, hint='weapon_crowbar,weapon_fists'}
CreateJob:addParam{ type=ULib.cmds.StringArg, hint='Job Command'}
CreateJob:addParam{type=ULib.cmds.NumArg, min=0, max=48,default=1,hint="Job Slot Count (0=infinte)", ULib.cmds.round}
CreateJob:addParam{ type=ULib.cmds.StringArg, completes=rdmGroups, hint="RDM Group", ULib.cmds.restrictToCompletes }
CreateJob:addParam{ type=ULib.cmds.BoolArg, hint ="'/announce?'", default=false}
CreateJob:addParam{ type=ULib.cmds.StringArg, completes=getJobCategories(), hint="Job Category", ULib.cmds.restrictToCompletes }
CreateJob:addParam{ type=ULib.cmds.BoolArg, hint ="Staff only?"}
CreateJob:addParam{ type=ULib.cmds.StringArg, completes=factions, hint="Job Faction", ULib.cmds.restrictToCompletes }
CreateJob:defaultAccess(ULib.ACCESS_ADMIN)
CreateJob:help("Create a custom job for events. You can add more than one weapon/model to the job by seperating them with commas. eg. model1,model2")


function ulx.removeJob(ply, job)
	if job == "visitor" then
		ULib.tsayError( calling_ply, "Removing the vistior job would fuck everything up. Nice try though.", true )
		return
	end
	local jobindex = select(2, DarkRP.getJobByCommand(job))
	if not jobindex then
		ULib.tsayError( calling_ply, "Job index is nil! (Job doesn't exist)", true )
		return
	end
	for k,ply in pairs(player.GetAll()) do
		if ply:Team() == jobindex then
			ply:changeTeam(TEAM_VISITOR, true)
			sBMRP.ChatNotify({ply}, "Info", "The job you are in is being removed, so you are being moved to visitor.")
		end
	end
	net.Start("ulx.job")
		net.WriteBool(true)
		net.WriteInt(jobindex, 7)
	net.Broadcast()
	DarkRP.removeJob(jobindex)
	ulx.fancyLog( player.GetAll(), "#P removed the job #s.",ply, job)
end


local removeJob = ulx.command(CATEGORY_NAME .. " - Jobs", "ulx removejob", ulx.removeJob, "!removejob", true, false )
removeJob:addParam{ type=ULib.cmds.StringArg, hint="jobcommand" }
removeJob:defaultAccess(ULib.ACCESS_ADMIN)
removeJob:help("Remove custom created job by using its command. If you don't know what its command is; use the console command 'getjobcommands' for reference.")

concommand.Add("getjobcommands", function()
	PrintTable(getJobs(false, true))
end)

net.Receive("ulx.job", function(len)
	local remove = net.ReadBool()
	if !remove then
		local job_struct = net.ReadTable()
		PrintTable(job_struct)
		DarkRP.createJob(job_struct.name, job_struct)
	else
		local job = net.ReadInt(7)

		DarkRP.removeJob(job)
	end
end)


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
GMAN Time
---------------------------------------------------------------------------]]
-- Probably not good that I process the whole code here but whatever
GmanTimeFreezeToggleVar = 0
function ulx.gmantime(ply, args)
	if ply:IsAdmin() then
		if GmanTimeFreezeToggleVar == 0 then
			GmanTimeFreezeToggleVar = 1
--[[			for k, v in pairs( ents.FindByName( "train" ) ) do
				v:SetMoveType(0)
				v:EmitSound("npc/dog/dog_straining1.wav", 80, 100)
				v:EmitSound("ambient/machines/wall_ambient1.wav", 80, 100)
				v:EmitSound("ambient/machines/zap3.wav", 80,100)
			end -- setpos -17040.894531 8124.455078 -20616.332031;setang -0.214555 102.681900 0.000000
]]			for k, v in pairs(player.GetAll()) do
				v:EmitSound("npc/attack_helicopter/aheli_charge_up.wav", 80, 100)
				v:EmitSound( "TimeGrenade/TimeExplosion.mp3",50 )
				v:EmitSound( "hl1/ambience/labdrone2.wav",50 )
				if v:SteamID() != "STEAM_0:1:72140646" then
					v:Freeze(true)
				end
			timer.Simple(2,function()
				for k, v in pairs(player.GetAll()) do
					if !v:IsAdmin() then
						v:Freeze(true)
					end
			end
			end)
				--local effectdata = EffectData()
				--while GmanTimeFreezeToggleVar == 1 do
					--DrawMaterialOverlay( string Material, number RefractAmount )
				--	effectdata:SetOrigin( v:GetPos() )
				--	util.Effect( "TimeStop", effectdata )
				--end
				timer.Simple(7,function() 			
					v:EmitSound( "vo/citadel/gman_exit01.wav",50 )
					timer.Simple(3,function() 
						v:EmitSound( "vo/citadel/gman_exit02.wav",50 )
						timer.Simple(4,function()
							v:EmitSound( "vo/citadel/gman_exit03.wav",50 )
							timer.Simple(4.5,function()
								v:EmitSound( "vo/citadel/gman_exit04.wav",50 )
								timer.Simple(5.8,function()
									v:EmitSound( "vo/citadel/gman_exit05.wav",50 )
									timer.Simple(15,function()
										v:EmitSound( "vo/citadel/gman_exit06.wav",50 )
										timer.Simple(15,function()
											v:EmitSound( "vo/citadel/gman_exit07.wav",50 )
											timer.Simple(14,function()
												v:EmitSound( "vo/citadel/gman_exit08.wav",50 )
												timer.Simple(4,function()
													v:EmitSound( "vo/citadel/gman_exit09.wav",50 )
													timer.Simple(3,function()
														v:EmitSound( "vo/citadel/gman_exit10.wav",50 )
														timer.Simple(5,function()
														v:Freeze(false)
														GmanTimeFreezeToggleVar = 0
														v:ConCommand( "stopsound" )
															--v:EmitSound( "vo/citadel/gman_exit10.wav",30 )
														end)
													end)
												end)
											end)
										end)
									end)
								end)
							end)
						end)
					end)
				end)
				end
			--end
		end
	else
		ply:ChatPrint("You are not admin!")
	end
end
local gmantime = ulx.command(CATEGORY_NAME .. " - Players", "ulx gmantime", ulx.gmantime, "!gmantime", true, false)
gmantime:defaultAccess(ULib.ACCESS_ADMIN)
gmantime:help("Is it really that time again?")

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
Lockdown
---------------------------------------------------------------------------]]

local goodgroups = table.ValuesToKeys({
	"superadmin",
	"staff",
	"trialstaff",
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
ADMIN HELP NOTIFER
---------------------------------------------------------------------------]]
local function ChatNotifier ( ply, txt, public )
	if ply:IsAdmin() then return end
	local txt = string.lower( txt )
	local txts = string.gsub(txt, "@ ", "")
	txts = string.gsub(txts,"@","")
	txts = string.gsub(txts,"// ","")
	txts = string.gsub(txts,"/ooc ","")
	txts = string.gsub(txts,"/pm sirro ","")
	txts = string.gsub(txts,"/// ","")
	--UNSTUCK--
	if txt != "@/stuck" and not(string.find(txt, "still")) and string.find(txt, "stuck") and (string.find(txt, '^' .. "@") ~= nil or string.find(txt, '^' .. "///") ~= nil) then
		--timer.Simple(0.2,function() ply:Say( "@[sBMRP OVERRIDE]: Do not respond to this call") end)
		local pos = DarkRP.findEmptyPos(ply:GetPos(), {ply}, 2000, 10, Vector(16, 16, 64))
		ply:SetPos(pos)
		ply:ChatPrint("--IF YOU ARE STILL STUCK TYPE @still stuck--")
		return ""
		/*
	elseif txt != "@/stuck" and (string.find(txt, "still") and string.find(txt, "stuck")) and (string.find(txt, '^' .. "@") ~= nil or string.find(txt, '^' .. "///") ~= nil) then
		timer.Simple(0.2,function() ply:Say( "@[sBMRP OVERRIDE]: Do not respond to this call") end)
		local pos = {}
		if ply:Team() == TEAM_TESTSUBJECT or ply:Team() == TEAM_HEADCRAB then
			pos = {{Vector(-2584.057373,-3678.041260,-165.024750),"Test Subject Spawn"}}
		elseif CheckInRange(Vector(-1407.327393,1061.189697,318.697754),Vector(-9684.939453,-3459.970459,3820.808838),ply:GetPos()) then --Surface, non-bm
			pos = {{Vector( -3676.808350,-906.981079,629.872925),"Black Mesa Spawn"},{Vector(-5861.890625,-1257.135132,634.031250),"Black Mesa Topside"}}
		elseif CheckInRange(Vector(-11615.540039,-4814.913574,-5864.372070),Vector(-1696.177734,-13936.375977,2038.580933),ply:GetPos()) then --Xen
			pos = {{Vector(-4394.238281,-10876.547852,72.502808),"Xen Survey Spawn"},{Vector(-5263.162109,-6148.592773,-912.968750),"Xen Hallway"}}
		else
			pos = {{Vector(-4829.938965,-589.023254,-237.046753),"Sector C Hallway"},{Vector(-8743.806641,-1029.124268,-188.968750),"Sector A Tramstation"},{Vector( -10273.783203,-1385.192261,-189.007751),"Sector A Elevator"},{Vector(153.759689,-3076.688477,-188.968750),"Sector D"},{Vector(5532.438477,-1470.136597,-177.968750),"Sector B"},{Vector(861.198547,-3463.968994,-2793.968750),"Canals"},{Vector(2300.0590820313,304.84335327148,-297.96875),"Upper Canals"}}
		end
		local distance=0
		local curpos = Vector(-3676.808350,-906.981079,629.872925)
		local curposname = "Black Mesa Spawn"
		for k,v in pairs(pos) do
			if distance == 0 or ply:GetPos():Distance(v[1]) < distance then
				distance = ply:GetPos():Distance(v[1])
				curpos = v[1]
				curposname = v[2]
			end
		end
		ply:SetPos(DarkRP.findEmptyPos(curpos, {ply}, 500, 30, Vector(16, 16, 64)))
		ply:ChatPrint("--SET POSITION TO "..curposname.."--")
		ply:ChatPrint("--FOR FURTHER HELP TYPE @/stuck--")
		--Antispam--
		*/
	elseif (txts == "to me" or txts == "sirro" or txts == "sirro cmere" or txts == "admin" or txts == "admin to me" or txts == "admin tp" or txts == "help" or txts == "tp to me" or txts == "come to me" or txts == "can a staff member come to me please" or txts == "staff tp to me" or txts=="can i please get an admin to me?" or txts=="c'mere" or txts == "admin to me please" or txts == "i need an admin" or txts == "i need a admin") then
		if (string.find(txt, '^' .. "/ooc") ~= nil) or (string.find(txt, '^' .. "//") ~= nil) or (string.find(txt, '^' .. "/pm")) ~= nil then
			ply:ChatPrint("--You are attempting to summon a staff member without a valid reason, in OOC or pms. Please ensure you include a valid reason in your request, and use '@' instead of '/ooc' or '//'--") 		
		else
			ply:ChatPrint("--You are attempting to summon a staff member without a valid reason. Please ensure you include a valid reason in your request.--")
		end
		
		if string.find(txt, '^' .. "@") ~= nil then
			timer.Simple(0.2,function() ply:Say( "@[sBMRP]: Do not respond to this call") end)
			return ""
		elseif string.find(txt, '^' .. "/pm") ~= nil then
			return ""
		elseif string.find(txt, '^' .. "//") ~= nil or string.find(txt, '^' .. "/ooc") ~= nil then
			return ""
		else
			return ""
		end
	elseif (string.find(txt, '^' .. "@") ~= nil or string.find(txt, '^' .. "///") ~= nil) then
		local adminon = false
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				adminon = true
			end
		end
		if adminon == false then
			ply:ChatPrint("[sBMRP]: There are no staff on at the moment! Visit our discord at [https://discord.gg/ajbT4vh] and mention a staff member for help.")
			ply:ChatPrint("[sBMRP]: If you wish to report a minge do /report <name> offence.")
		end
	end
end
hook.Add( "PlayerSay", "bmrp_chatnotifier", ChatNotifier)