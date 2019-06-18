--[[-------------------------------------------------------------------------
sBMRP ChatCommand handler
---------------------------------------------------------------------------]]
CATEGORY_NAME = "Black Mesa Roleplay"
-- Useless DarkRP commands
DarkRP.removeChatCommand("addagenda")
DarkRP.removeChatCommand("addlaw")
DarkRP.removeChatCommand("addjailpos")
DarkRP.removeChatCommand("agenda")
DarkRP.removeChatCommand("cr")
DarkRP.removeChatCommand("demotelicense")
DarkRP.removeChatCommand("disablestorm")
DarkRP.removeChatCommand("enablestorm")
DarkRP.removeChatCommand("givelicense")
DarkRP.removeChatCommand("jailpos")
DarkRP.removeChatCommand("hitprice")
DarkRP.removeChatCommand("lottery")
DarkRP.removeChatCommand("placelaws")
DarkRP.removeChatCommand("removelaws")
DarkRP.removeChatCommand("requesthit")
DarkRP.removeChatCommand("requestlicense")
DarkRP.removeChatCommand("resetlaws")
DarkRP.removeChatCommand("setjailpos")
DarkRP.removeChatCommand("warrant")
DarkRP.removeChatCommand("wanted")
DarkRP.removeChatCommand("buyradio")
DarkRP.removeChatCommand("advert")


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
	ulx.fancyLog( player.GetAdmins(), "#P changed the VOX state to #s",calling_ply, state)
end

local setvox = ulx.command( CATEGORY_NAME, "ulx setvox", ulx.setvox, nil, false, false)
setvox:addParam{ type=ULib.cmds.StringArg, completes=StateDisclaimers, hint="Vox Alert State", error="invalid state \"%s\" specified", ULib.cmds.restrictToCompletes }
setvox:defaultAccess( ULib.ACCESS_ADMIN)
setvox:help( "Sets the vox state." )

function ulx.voxtime(calling_ply, time)
	sBMRP.VOX.Time = tonumber(time)
	sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
	ulx.fancyLog( player.GetAdmins(), "#P changed the VOX time interval to #i seconds",calling_ply, time)
end
local voxtime = ulx.command(CATEGORY_NAME, "ulx voxtime", ulx.voxtime, nil, false, false )
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
	sBMRP.CreateChatCommand("announce", PlayerAnnounce, "Announce your message.", 10)
	sBMRP.CreateChatCommand("advert", PlayerAnnounce, "Announce your message.", 10)
end
--[[-------------------------------------------------------------------------
Disable Announce/Advert
---------------------------------------------------------------------------]]
function ulx.toggleannounce(calling_ply, args)

	if sBMRP.AnnounceState then
	    sBMRP.AnnounceState = false
		ulx.fancyLog( player.GetAdmins(), "#P disabled the announcement system.",calling_ply)
	else
	    sBMRP.AnnounceState = true
		ulx.fancyLog( player.GetAdmins(), "#P enabled the announcement system.",calling_ply)
	end
end
local toggleannounce = ulx.command(CATEGORY_NAME, "ulx toggleannounce", ulx.toggleannounce, "!toggleannounce", true, false )
toggleannounce:defaultAccess(ULib.ACCESS_ADMIN)
toggleannounce:help("Disable or enable the announcement system.")

--[[-------------------------------------------------------------------------
Building toggle
---------------------------------------------------------------------------]]
sBMRP.DisableBuilding = false
function ulx.DisableBuilding(calling_ply)	
	if not sBMRP.DisableBuilding then
	    sBMRP.DisableBuilding = true
		ulx.fancyLog( player.GetAll(), "#P disabled building for players.",calling_ply)
		local function blockspawning(ply)
			if ply:IsAdmin() then
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
local DisableBuilding = ulx.command(CATEGORY_NAME, "ulx disablebuilding", ulx.DisableBuilding, "!disablebuilding", true, false)
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
		ply:AllowToEarth(true)
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P gave #P permission go to earth.",calling_ply, target)
	else
		ulx.fancyLog({unpack(player.GetAdmins()), target}, "#P revoked #P's permission to go earth.",calling_ply, target)
		ply:AllowToEarth(false)
	end

	local function resetperms(ply)
		ply:AllowToEarth(false)
		for k,v in pairs("PlayerDeath", "OnPlayerChangedTeam") do
			hook.Remove(k, "sBMRP.EarthRestrictPerms")
		end
	end
	for k,v in pairs("PlayerDeath", "OnPlayerChangedTeam") do
		hook.Add(k, "sBMRP.EarthRestrictPerms", resetperms)
	end
end
local allowsinglexenian = ulx.command(CATEGORY_NAME, "ulx allowsinglexenian", ulx.allowsinglexenian, "!allowsinglexenian", true, false)
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
		ply:AllowToBMRF(true)
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P gave #P permission go to earth.",calling_ply, target)
	else
		ulx.fancyLog( {unpack(player.GetAdmins()), target}, "#P revoked #P's permission to go earth.",calling_ply, target)
		ply:AllowToBMRF(false)
	end

	local function resetperms(ply)
		ply:AllowToBMRF(false)
		for k,v in pairs("PlayerDeath", "OnPlayerChangedTeam") do
			hook.Remove(k, "sBMRP.AllowToBMRF")
		end
	end
	for k,v in pairs("PlayerDeath", "OnPlayerChangedTeam") do
		hook.Add(k, "sBMRP.AllowToBMRF", resetperms)
	end
end
local allowsinglehecu = ulx.command(CATEGORY_NAME, "ulx allowsinglehecu", ulx.allowsinglehecu, "!allowsinglehecu", true, false)
allowsinglehecu:addParam{ type=ULib.cmds.PlayersArg }
allowsinglehecu:addParam{ type=ULib.cmds.BoolArg, invisible=true}
allowsinglehecu:defaultAccess(ULib.ACCESS_ADMIN)
allowsinglehecu:help("Allow the temporary access of a HECU player, will auto revoke on death/teamchange.")
allowsinglehecu:setOpposite( "ulx unallowsinglehecu", {_, _, true}, "!unallowsinglehecu" )




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
		if ply:GetPos():Distance(Vector(-10276.729492,-1333.907471,251.889832)) <= 800 then
			timer.Simple(0.2,function() ply:Say( "@[sBMRP OVERRIDE]: Do not respond to this call") end)
			ply:SetPos(DarkRP.findEmptyPos(Vector(-10288.088867,-1378.205200,-189.00775), {ent}, 600, 30, Vector(16, 16, 64)))
			ply:ChatPrint("--IF YOU ARE STILL STUCK TYPE @still stuck--")
		else
			timer.Simple(0.2,function() ply:Say( "@[sBMRP OVERRIDE]: Do not respond to this call") end)
			local pos = DarkRP.findEmptyPos(ply:GetPos(), {ply}, 600, 10, Vector(16, 16, 64))
			ply:SetPos(pos)
			if ply:GetPos()[3] > -146 and ply:GetPos()[3] < -144 then
				pos[3] = pos[3] - 30
				ply:SetPos(DarkRP.findEmptyPos(pos, {ply}, 600, 10, Vector(16, 16, 64)))
			end
			ply:ChatPrint("--IF YOU ARE STILL STUCK TYPE @still stuck--")
			return ""
		end
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






