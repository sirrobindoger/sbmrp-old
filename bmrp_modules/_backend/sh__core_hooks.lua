--[[-------------------------------------------------------------------------
Core Hooks 
---------------------------------------------------------------------------]]

hook.Add("InitPostEntity","bmrp_jumpstart", function()
	print("\n\n\n----SERVER HAS FINISHED INITALIZING----\n\n\n")
	RunConsoleCommand("bot")
	RunConsoleCommand("sv_hibernate_think", 1)
	RunConsoleCommand("kick","bot01")
end)

local goodgroups = table.ValuesToKeys({
	"superadmin",
	"staff",
	"trialstaff",
	"trusted",
	"supporter",
	"whitelisted",
})

hook.Add("CheckPassword", "bmrp_password-check", function(steamid, ip, svpass, clpass, name)
	local steamid = util.SteamIDFrom64(steamid)
	if not ULib.ucl.users[steamid] || not ULib.ucl.users[steamid].group || not goodgroups[ULib.ucl.users[steamid].group] then
		Log("[" .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp ) .. "] " .. name .. "/" .. steamid .. " attempted to connect, but has invalid permissions. ")
		return false, "--==Access Restricted: Unauthorized Usergroup.==--\n\nThe server is currently in closed development.\nTo learn more please visit sbmrp.com/discord\n\nsCON | " .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )
	end
end)

timer.Create( "Tick1s", 1, 0, function()
	pcall(function() hook.Call("Tick_1S") end)
end)

timer.Create( "Tick60s", 60, 0, function()
	pcall(function() hook.Call("Tick_60S") end)
	if CLIENT then return end
	if #player.GetAll() <= 0 then return end
	Log("--60s Tick-- [" .. os.date( "%H:%M", os.time()) .. "] {" .. player.GetCount() .. " players}")
end)


-- Debug
if SERVER then
	hook.Add("PlayerUse", "sirro_debug", function(ply, ent)
		if not IsValid(ent) or not IsValid(ply) or not IsFirstTimePredicted() then return end
		if sBMRP.Debug and ply:IsSirro() then
			ply:ChatPrint(ent:MapCreationID() .. "\nName: " ..  ent:MapCreationID() .. "\nAngs:" .. util.TypeToString(ent:GetAngles()) .. "\nPOS:" .. util.TypeToString(ent:GetPos()) .. "\nMODEL:" .. ent:GetModel())
		end
	end)
end

-- Player fully loaded
if SERVER then
	util.AddNetworkString("PlayerFullyLoaded_net")
	net.Receive("PlayerFullyLoaded_net",function(len)
		local ply = net.ReadEntity()
		hook.Call("PlayerFullyLoaded",ply)
		Log(ply:GetName() .. "<" .. ply:IPAddress() .. "> has finished loading.")
		ply:EmitSound("items/suitchargeok1.wav")
	end)
end

if CLIENT then
	hook.Add( "InitPostEntity", "PlayerFullyLoaded_cl", function()
		hook.Remove("InitPostEntity","PlayerFullyLoaded_cl")
		net.Start("PlayerFullyLoaded_net")
			net.WriteEntity(LocalPlayer())
		net.SendToServer()
	end)
end


if SERVER then
	local function PlayerInitStartConvars(ply)
		ply:SendLua([[RunConsoleCommand( "thruster_soundname", '""' )]]) --So fucking 11 year old kids that spam thrusters on shit at LEAST do so quietly, 
		ply:SendLua([[RunConsoleCommand( "mat_specular", "0" )
		RunConsoleCommand( "stopsound" )]]) --rp_sectorc_beta specific
	end
	hook.Add( "PlayerInitialSpawn", "gm_init_startconvars", PlayerInitStartConvars)
end


if CLIENT then
	-- Darkrp rewrites
	local function AdminLog(um)
	    local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	    local text = DarkRP.deLocalise(um:ReadString() .. "\n")

	    MsgC(Color(0, 175, 196, 255), "[" .. GAMEMODE.Name .. "] ", colour, text)

	    hook.Call("DarkRPLogPrinted", nil, text, colour)
	end
	usermessage.Hook("DRPLogMsg", AdminLog)


	local function DisplayNotify(msg)
	    local txt = msg:ReadString()
	    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	    surface.PlaySound("buttons/lightswitch2.wav")

	    -- Log to client console
	    MsgC(Color(0, 175, 196, 255), "[" .. GAMEMODE.Name .. "] ", Color(200, 200, 200, 255), txt, "\n")
	end
	usermessage.Hook("_Notify", DisplayNotify)
end