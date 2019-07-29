--[[-------------------------------------------------------------------------
Core functions
---------------------------------------------------------------------------]]
local ent = FindMetaTable("Entity")
local ply = FindMetaTable("Player")
if SERVER then
	util.AddNetworkString("sbmrpcommandhandler")
	-- Log function i guess
	function Log(str)
		ServerLog(str .. "\n")
	end

	-- Chat command that fills in darkrp shit for me
	function sBMRP.CreateChatCommand(command, func, desc, delay) -- declars and defines
		if not command or not func or not isfunction(func) then
			error("Invalid parameters!")
		end
		desc = desc or "sBMRP Chat Command"
		delay = delay or 1.5
		DarkRP.declareChatCommand{command = command, description = desc, delay = delay}
		net.Start("sbmrpcommandhandler")
			net.WriteTable({command, desc, delay})
			net.WriteBool(false)
		net.Broadcast()
		DarkRP.defineChatCommand(command, func)
	end

	function ARitzDDMsg(...)
		return -- ARitz can go fuck himself
	end
	function sBMRP.RemoveChatCommand(command)
		if not command then error("Invalid parameters!") end
		DarkRP.removeChatCommand(command)
		net.Start("sbmrpcommandhandler")
			net.WriteTable({command})
			net.WriteBool(true)
		net.Broadcast()
	end

	function dprint(...)
		if sBMRP.debug then print(...) end
	end

	concommand.Add("weapondet", function(ply)
		if not ply:GetActiveWeapon() then return end
		
		ply:ChatPrint(ply:GetActiveWeapon():GetWeaponWorldModel())
		ply:ChatPrint(ply:GetActiveWeapon():GetClass())
	end)
end

if CLIENT then
	net.Receive("sbmrpcommandhandler",function(ret)
		local define = net.ReadTable()
		local remove = net.ReadBool()
		if not remove then
			DarkRP.declareChatCommand{command = define[1], description = define[2], delay = define[3]}
			return
		end
		DarkRP.removeChatCommand(define[1])
	end)
end

concommand.Add("animprop_selectname", function() return end)

function ply:IsSirro()
	return self:SteamID() == "STEAM_0:1:72140646"
end

function player.GetSirro()
	for k,v in pairs(player.GetAll()) do
		if v:IsSirro() then return v end
	end
	return nil
end

function player.GetAdmins()
	local admins = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then table.insert(admins, v) end
	end
	return admins
end


function player.InLocation(loc)
	local entry = {}
	local istrue = false
	for k,v in pairs(player.GetAll()) do
		if GetLocation(v) == loc then
			table.insert(entry, v)
			istrue = true
		end
	end
	return istrue, entry
end




if SERVER then
	function adminchatall(text)
		for k,v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				v:ChatPrint(text)
			end
		end
	end

	function chatall(text)
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint(text)
		end
	end
	function EntID(ent)
		if not IsValid(ents.GetMapCreatedEntity(ent)) then return end
		return ents.GetMapCreatedEntity(ent)
	end
end


if SERVER then
	function sBMRP.MapHook(name, func)
		hook.Add("InitPostEntity", name, func)
		hook.Add("PostCleanupMap", name, func)
	end
end

function ply:Notify(text, typeint, time)
	DarkRP.notify(self, typeint or 5, time or 5, text)
end

if SERVER then
	local vec = FindMetaTable("Vector")
	function vec:Round(dec)
		if not dec then dec = 0 end vec = self
		return math.Round(vec.x,dec),math.Round(vec.y,dec),math.Round(vec.z,dec)
	end
	function ent:LerpToVector(vec,mult)

		if !mult then mult = 1 end
		hook.Remove("Think", "lerp-motion_" .. self:EntIndex())  -- make sure there are no other lerp motions running

		local targetvec = vec
		local entindex = self:EntIndex()
		local ent = self
		hook.Add("Think", "lerp-motion_" .. entindex, function()
			if not IsValid(ent) then hook.Remove("Think", "lerp-motion_" .. entindex) end -- something went wrong
			if ent:GetPos():Round() == targetvec:Round() then hook.Remove("Think", "lerp-motion_" .. entindex) hook.Run("LerpMovementEnded", ent) return end
			local newpos = LerpVector(FrameTime()*mult, ent:GetPos(), targetvec)
			--local dir = (targetvec - self:GetPos()):GetNormalized() * mult
			--ent:SetPos(self:GetPos() + dir )
			ent:SetPos(newpos)
		end)

	end


	function ent:LerpToAngle(ang)
		local targ = ang
		print("Starting Motion")
		hook.Add("Think", "lerp-ang_" .. self:EntIndex(), function()
			local targlerp = LerpAngle(FrameTime(), self:GetAngles(), targ)
			if RoundVector(targlerp) == RoundVector(targ) then print(util.TypeToString(RoundVector(targlerp)) .. "=" .. util.TypeToString(RoundVector(targ))) hook.Remove("Think","lerp-ang_" .. self:EntIndex()) end -- reached destination
			self:SetAngles(targlerp)
			print(targlerp)
		end)
	end


	function FindInVectors(vec1, vec2)
		for k,v in pairs(ents.GetAll()) do
			if v:GetPos():WithinAABox(vec1,vec2) then
				print("-------------")
				print("MAPID: " .. v:MapCreationID())
				print("CLASS: " .. v:GetClass())
				print("NAME: " .. v:GetName())
				print("ENTID: " .. v:EntIndex())
				print("-------------")
			end
		end
	end
end

if SERVER then
	util.AddNetworkString("sBMRP.HighlightEnts")

	function ply:AddHighlightEnt(ent, append)
		if !istable( ent )  then return end
		self.highlightedents = ( self.highligthedents and append and table.Add(self.highligthedents, ent) ) or ent
		net.Start("sBMRP.HighlightEnts")
			net.WriteCompressedTable(self.highlightedents)
		net.Send(self)
	end

	function ply:HasHightedEnts()
		if #self.highlightedents > 0 then
			return true, self.highlightedents
		end
	end

	function ply:ClearHighlightEnts()
		net.Start("sBMRP.HighlightEnts")
			net.WriteCompressedTable({-1})
		net.Send(self)
	end
end


if CLIENT then
	local highlightents = highlightents || false

	net.Receive("sBMRP.HighlightEnts", function(len)
		local netents = net.ReadCompressedTable()

		if netents[1] == -1 then highlightents = false return end
		PrintTable(netents)
		highlightents = netents

	end)

	hook.Add( "PreDrawHalos", "bmrp_halodraw", function()
		if not highlightents then return end
		halo.Add( highlightents, Color( 255, 0, 0 ), 5, 5, 1 )
	end )
end



function timeToStr( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	return string.format( "%02iw %id %02ih %02im %02is", w, d, h, m, s )
end


function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end


function SetAllDoorsUnownable()
	for k,ent in pairs(ents.GetAll()) do
		if IsValid(ent) then
		    ent:setKeysNonOwnable(not ent:getKeysNonOwnable())
		    ent:removeAllKeysExtraOwners()
		    ent:removeAllKeysAllowedToOwn()
		    ent:removeAllKeysDoorTeams()
		    ent:setDoorGroup(nil)
		    ent:setKeysTitle(nil)

		    -- Save it for future map loads
		    DarkRP.storeDoorData(ent)
		    DarkRP.storeDoorGroup(ent, nil)
		    DarkRP.storeTeamDoorOwnability(ent)
		end
	end

end
if CLIENT then
	concommand.Add("getposvec", function(ply)
		location = LocalPlayer():EyePos()
		print("Vector(" .. location[1] .. "," .. location[2] .. "," .. location[3] .. ")")
	end)
end
function table.ValuesToKeys(tab)
	local newtab = {}
	for k, v in pairs(tab) do
		if !v then continue end
		newtab[v] = true
	end
	return newtab
end

function CheckInRange(vec1,vec2,vecx)
	if IsEntity(vecx) then
		local vecx = vecx:GetPos()
	end
	if vecx:WithinAABox(vec1,vec2) then
		return true
	else
		return false
	end
end

function TriggerEnt(entid, event) -- safe way to execute map functions
	if !IsValid(ents.GetMapCreatedEntity(entid)) then return end
	ents.GetMapCreatedEntity(entid):Fire(event)
end

if CLIENT then
	function sBMRP.AppendFont(name, size, weight, antialias, outline, additive, shadow, underline)
		surface.CreateFont("sBMRP." .. name, {
			font = "ZektonRG-Regular",
			size = size or 17,
			weight = weight or 100,
			antialias = antialias or true,
			outline = outline or false,
			additive = additive or true,
			shadow = shadow or true,
			underline = underline or false,
		})
		sBMRP.Fonts = sBMRP.Fonts || {}
		sBMRP.Fonts[name] = true
		return "sBMRP." .. name
	end
end


function GetLocationRaw(recpos)
	if type(recpos) == "Player" then
		recpos = recpos:GetPos()
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
	function vaporize(ply)
		local d = DamageInfo()
		d:SetDamage( math.huge )
		d:SetAttacker(game.GetWorld())
		d:SetDamageType( DMG_DISSOLVE )
		ply:TakeDamageInfo( d )
	end
end