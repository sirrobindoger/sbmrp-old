--[[-------------------------------------------------------------------------
Core Hooks 
---------------------------------------------------------------------------]]
hook.Remove("Think", "player_location-process")
if SERVER then
	hook.Add("Think", "player_location-process", function()
		for k,v in pairs(player.GetAll()) do
			local plyloc = GetLocationRaw(v)
			local currlocation = v:GetNWString("location", "Unknown")
			if currlocation != plyloc then
				v:SetNWString("location", plyloc)
				hook.Run("PlayerChangedLocation", v, currlocation, plyloc)
			end

		end
	end)
end

function GetLocation(recpos)
	if type(recpos) == "Player" then
		return recpos:GetNWString("location", "Unknown")
	end
	local location = DarkRP.getPhrase("gm_unknown")
	for k,v in pairs(sBMRP.locationnames) do
		if CheckInRange(v[2],v[3],recpos) then
			location = v[1]
			break
		else location = "Unknown"
		end
	end
	return location
end
if SERVER then
	hook.Add( "PlayerNoClip", "isInNoClip", function( ply, desiredNoClipState )
	    if ply:IsAdmin() then
	        if desiredNoClipState == true then
	            ply:GodEnable()
	            ply:SetNoTarget(true)
	--            timer.Simple(.1, function() Zap(ply) end)
	            RunConsoleCommand( "fadmin", "cloak", ply:SteamID())
	            RunConsoleCommand("ulx","cloak", ply:GetName())
	--            DarkRP.notify(ply, 5, 1, "Noclip/Cloak/Godmode Enabled")
	        end
	        if desiredNoClipState == false then
	            ply:GodDisable()
	--            timer.Simple(.1, function() Zap(ply) end)
	            ply:SetNoTarget(false)
	            RunConsoleCommand( "fadmin", "uncloak", ply:SteamID())
	            RunConsoleCommand("ulx","uncloak", ply:GetName())
	--            DarkRP.notify(ply, 5, 1, "Noclip/Cloak/Godmode Disabled")
	        end
	    end
	end)
end

if SERVER then
	hook.Add("PlayerChangedLocation", "ply_location-log", function(ply, old, new)
		Log(ply:GetName() .. " changed locations (" .. (old or "NULL") .. " --> " .. new .. ")")
	end)
end
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


--[[
hook.Add("CheckPassword", "bmrp_password-check", function(steamid, ip, svpass, clpass, name)
	local steamid = util.SteamIDFrom64(steamid)
	if not ULib.ucl.users[steamid] || not ULib.ucl.users[steamid].group || not goodgroups[ULib.ucl.users[steamid].group] then
		Log("[" .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp ) .. "] " .. name .. "/" .. steamid .. " attempted to connect, but has invalid permissions. ")
		return false, "--==Access Restricted: Unauthorized Usergroup.==--\n\nThe server is currently in closed development.\nTo learn more please visit sbmrp.com/discord\n\nsCON | " .. os.date( "%H:%M:%S - %d/%m/%Y" , Timestamp )
	end
end)
]]--
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
			ply:ChatPrint(ent:MapCreationID() .. "\nName: " ..  ent:GetName() .. "\nAngs:" .. util.TypeToString(ent:GetAngles()) .. "\nPOS:" .. util.TypeToString(ent:GetPos()) .. "\nMODEL:" .. ent:GetModel() /*.. "\nCLASS:" .. ent:GetClass()*/)
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

if SERVER then
	local disallowedNames = {["ooc"] = true, ["shared"] = true, ["world"] = true, ["world prop"] = true}
	function GAMEMODE:CanChangeRPName(ply, RPname)
	    if disallowedNames[string.lower(RPname)] then return false, DarkRP.getPhrase("forbidden_name") end
	    --if not string.match(RPname, "^[a-zA-ZЀ-џ0-9 ]+$") then return false, DarkRP.getPhrase("illegal_characters") end

	    local len = string.len(RPname)
	    if len > 30 then return false, DarkRP.getPhrase("too_long") end
	    if len < 3 then return false,  DarkRP.getPhrase("too_short") end
	end
end


if SERVER then
	util.AddNetworkString("playerconnect")
	util.AddNetworkString("spawn")
	util.AddNetworkString("disconnect")
	gameevent.Listen( "player_connect" )
	hook.Add( "player_connect", "connectnotification", function( data )
		local name = data.name			
		local steamid = data.networkid	
		local info = name .. " [" .. steamid .. "] has connected to the server."
		for k,v in pairs (player.GetAll()) do
		net.Start("playerconnect")
	    local sendinfo = info
	    net.WriteString(sendinfo)
	 
	    	net.Send(v)
	    end
	end )
	gameevent.Listen( "player_disconnect" )
	hook.Add("player_disconnect", "disconnectnotification", function(data)
		local name = data.name			
		local steamid = data.networkid	
		local reason = data.reason
		local info = name .. " [" .. steamid .. "] has left the server <" .. reason .. ">."
		for k,v in pairs (player.GetAll()) do 
		net.Start("disconnect")
	    local sendinfo = info
	    net.WriteString(sendinfo)

	    	net.Send(v)
	    end
	end)

	hook.Add("PlayerInitialSpawn", "spawnoticiation", function(ply)
		local name = ply:GetName()			
		local steamid = ply:SteamID()	
		local info = name .. " [" .. steamid .. "] has spawned in the server."
		for k,v in pairs (player.GetAll()) do
		net.Start("spawn")
	    local sendinfo = info
	    net.WriteString(sendinfo)
	 
	    	net.Send(v)
	    end
	end)

end

if CLIENT then
	net.Receive("playerconnect",function()
		connectinfo = net.ReadString()
		chat.AddText(Color(18, 204, 48), connectinfo )
		surface.PlaySound("ui/buttonclick.wav")
	end)

	net.Receive("spawn",function()
		spawninfo = net.ReadString()
		chat.AddText(Color(2, 244, 41), spawninfo )
		surface.PlaySound("player/footsteps/dirt2.wav")
	end)

	net.Receive("disconnect",function()
		spawninfo = net.ReadString()
		chat.AddText(Color(255, 0, 0), spawninfo )
		surface.PlaySound("garrysmod/ui_return.wav")
	end)
	hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
		if ( typ == "joinleave" ) then return true end
	end)
end

--[[-------------------------------------------------------------------------
Client Optimizations
---------------------------------------------------------------------------]]

if CLIENT then
	local function antilagOn()
		RunConsoleCommand("gmod_mcore_test", "1")
		RunConsoleCommand("mat_queue_mode", "-1")
		RunConsoleCommand("cl_threaded_bone_setup", "1")
		RunConsoleCommand("cl_threaded_client_leaf_system", "1")
		RunConsoleCommand("r_threaded_client_shadow_manager", "1")
		RunConsoleCommand("r_threaded_particles", "1")
		RunConsoleCommand("r_threaded_renderables", "1")
		RunConsoleCommand("r_queued_ropes", "1")
		RunConsoleCommand("studio_queue_mode", "1")
		
		hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
	    hook.Remove("RenderScreenspaceEffects", "RenderBloom")
	 	hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
	 	hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
	 	hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
	 	hook.Remove("RenderScreenspaceEffects", "RenderSobel")
	 	hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
	 	hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
	 	hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
	 	hook.Remove("RenderScene", "RenderStereoscopy")
	 	hook.Remove("RenderScene", "RenderSuperDoF")
	 	hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
	 	hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
	 	hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
	 	hook.Remove("PostRender", "RenderFrameBlend")
	 	hook.Remove("PreRender", "PreRenderFrameBlend")
	 	hook.Remove("Think", "DOFThink")
	 	hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
	 	hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
	 	hook.Remove("PostDrawEffects", "RenderWidgets")
	 	--hook.Remove("PostDrawEffects", "RenderHalos")
	end
	timer.Simple(0, antilagOn)
end