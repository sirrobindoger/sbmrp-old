
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