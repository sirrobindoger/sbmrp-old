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