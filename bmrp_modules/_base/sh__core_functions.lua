local ent = FindMetaTable("Entity")
local ply = FindMetaTable("Player")
--[[-------------------------------------------------------------------------
SERVER FUNCTIONS
---------------------------------------------------------------------------]]
if SERVER then
	--[[
		Log function
	]]
	function Log(str)
		ServerLog(str .. "\n")
	end


	--[[
		DarkRP SERVER only chat command creator that networks to clients.
	]]
	util.AddNetworkString("sbmrpcommandhandler")
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
	function sBMRP.RemoveChatCommand(command)
		if not command then error("Invalid parameters!") end
		DarkRP.removeChatCommand(command)
		net.Start("sbmrpcommandhandler")
			net.WriteTable({command})
			net.WriteBool(true)
		net.Broadcast()
	end


	--[[
		Simple console command that prints the model of the weapon you're holding.
	]]
	concommand.Add("getweaponinfo", function(ply)
		if not ply:GetActiveWeapon() then return end
		
		ply:ChatPrint(ply:GetActiveWeapon():GetWeaponWorldModel())
		ply:ChatPrint(ply:GetActiveWeapon():GetClass())
	end)

	--[[
		This just mutes another addon's print function because of how annoying it is.
	]]
	function ARitzDDMsg(...)
		return -- ARitz can go fuck himself
	end

	--[[
		This just allows me to perma prop stuff without having to Toolgun it.
		Basically mass perma prop shit.
	]]
	function sBMRP.PermaProp(ent)
		--local ply = self:GetOwner()

		if not PermaProps then Log( "ERROR: Lib not found" ) return end
		

		if not ent:IsValid() then Log( "That is not a valid entity !" ) return end
		if ent:IsPlayer() then Log( "That is a player !" ) return end
		if ent.PermaProps then Log( "That entity is already permanent !" ) return end

		local content = PermaProps.PPGetEntTable(ent)
		if not content then return end

		local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;"))
		if not max then max = 1 else max = max + 1 end

		local new_ent = PermaProps.PPEntityFromTable(content, max)
		if !new_ent or !new_ent:IsValid() then return end

		PermaProps.SparksEffect( ent )

		PermaProps.SQL.Query("INSERT INTO permaprops (id, map, content) VALUES(NULL, ".. sql.SQLStr(game.GetMap()) ..", ".. sql.SQLStr(util.TableToJSON(content)) ..");")
		Log("You saved " .. ent:GetClass() .. " with model ".. ent:GetModel() .. " to the database.")

		ent:Remove()
	end

	--[[
		Simple function that checks the validity of a map ID code.
	]]
	function EntID(ent)
		if not IsValid(ents.GetMapCreatedEntity(ent)) then return end
		return ents.GetMapCreatedEntity(ent)
	end

	function ply:AntiSpam()
		local ply = self
		if ply.antispam_use == nil or ply.antispam_use == 0 then -- cBMRP antispam code
			ply.antispam_use = 1
			timer.Destroy("gm_"..ply:SteamID().."_antispam_use")
			timer.Create("gm_"..ply:SteamID().."_antispam_use", 0.25, 1, function()
				ply.antispam_use = 0
			end )
			return true
		else
			return false
		end
	end


	--[[
		IDK why nobody thought of this, so I made it myself.
		Returns the vector but with rounded values.
	]]
	local vec = FindMetaTable("Vector")
	function vec:Round(dec)
		if not dec then dec = 0 end vec = self
		return math.Round(vec.x,dec),math.Round(vec.y,dec),math.Round(vec.z,dec)
	end

	--[[
		These two func's just simulate movement via linear interpolation, kinda buggy, but works.
	]]
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

	function ent:LerpToAngle(ang, mult)
		hook.Remove("Think", "lerp-ang_" .. self:EntIndex())  -- make sure there are no other lerp motions running

		local targang = vec
		local entindex = self:EntIndex()
		local ent = self
		hook.Add("Think", "lerp-ang_" .. self:EntIndex(), function()
			if not IsValid(ent) then hook.Remove("Think", "lerp-ang__" .. entindex) end -- something went wrong
			local targlerp = LerpAngle(FrameTime()*mult, self:GetAngles(), targang)
			if RoundVector(targlerp) == RoundVector(targang) then hook.Remove("Think","lerp-ang_" .. entindex) end -- reached destination
			self:SetAngles(targlerp)
		end)
	end
	--[[
		Function that copy pastes a function into two hooks at once.
		(When the server finishes starting and right after a map clean)
		This is used for setting up perma map ents right after a map clean.
	]]
	function sBMRP.MapHook(name, func)
		hook.Add("InitPostEntity", name, func)
		hook.Add("PostCleanupMap", name, func)
	end
	--[[
		Shakey map effect for players... I should remake this its kind bad.
	]]
	function sBMRP.ShakeMap(optional)
	    if optional == 1 then
	        engine.LightStyle(0,"vvvcvvvpvpsvvvvcvd")
	        timer.Simple(2, function()
	            engine.LightStyle(0,"vvvpvvpvs")
	        end)
	    else
	        engine.LightStyle(0,"vvvbvprvvbvpcvvvvdvf")
	        timer.Simple(2, function()
	            engine.LightStyle(0,"jklmnopqrstuvwxyzyxwvutsrqponmlkj")
	        end)
	    end        
	    timer.Simple(7, function()
	        if sBMRP.powerout then
	            engine.LightStyle(0, "b")
	        else
	            engine.LightStyle(0, "v")
	        end
	        for k,v in pairs(player.GetAll()) do
	            v:SendLua([[render.RedownloadAllLightmaps(true)]])
	        end
	    end)
	    if optional == 1 then
	        for k,v in pairs(player.GetAll()) do
	            v:SendLua([[
	                surface.PlaySound("ambient/levels/intro/Rhumble_1_42_07.wav")]])
	        end
	    else
	        for k,v in pairs(player.GetAll()) do
	            v:SendLua([[
	                surface.PlaySound("env/rumble_shake.wav")
	                surface.PlaySound("ambient/explosions/explode_9.wav")
	                util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 7, 5000 )]])
	        end
	    end
	end

	--[[
		Safter version of using an ent to avoid nil errors.
	]]
	function sBMRP.MapFire(entid, fire)
		local ent = tonumber(entid) and IsValid(ents.GetMapCreatedEntity(entid)) and ents.GetMapCreatedEntity(entid) or IsValid(entid) and IsEntity(entid) or false
		if ent then 
			ent:Fire(fire)
		end
	end

	function ents.sMapEnt(id, func)
		local ent = ents.GetMapCreatedEntity(id)
		if IsValid(ent) then
			func(ent)
			return true
		end
	end
	--[[
		Resets all the doors in the map to unownable, this is used for resetting up doors when a map update happens.
	]]
	function sBMRP.WipeDoorData()
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


	--[[
		This effectively ties engine.LightStyle and render.RedownloadAllLightMaps together.
	]]
	util.AddNetworkString("sBMRP.enginelight")

	function sBMRP.UpdateEngineLight(lightstyle, doStaticProps)
		engine.LightStyle(0, lightstyle)
		timer.Simple(0.5, function()
			net.Start("sBMRP.enginelight")
				net.WriteBool(doStaticProps or false)
			net.Broadcast()
		end)
	end

	--[[
		Vaporizes player
	]]
	function vaporize(ply)
		local d = DamageInfo()
		d:SetDamage( math.huge )
		d:SetAttacker(game.GetWorld())
		d:SetDamageType( DMG_DISSOLVE )
		ply:TakeDamageInfo( d )
	end
end

--[[-------------------------------------------------------------------------
SHARED (CLIENT AND SERVER) FUNCTIONS
---------------------------------------------------------------------------]]

--[[
	Skybox changer.
]]
if CLIENT then
    local SourceSkyname = GetConVar("sv_skyname"):GetString()
    local SourceSkyPre  = {"lf","ft","rt","bk","dn","up",}
    local SourceSkyMat  = {
        Material("skybox/"..SourceSkyname.."lf"),
        Material("skybox/"..SourceSkyname.."ft"),
        Material("skybox/"..SourceSkyname.."rt"),
        Material("skybox/"..SourceSkyname.."bk"),
        Material("skybox/"..SourceSkyname.."dn"),
        Material("skybox/"..SourceSkyname.."up"),
    }
    
    local DefaultSkyTex = DefaultSkyTex || {}
    for i = 1,6 do
    	DefaultSkyTex[i] = SourceSkyMat[i]:GetTexture("$basetexture"):GetName()
    end
    net.Receive( "BMRP_Skybox", function( len, ply )
        local netstr = net.ReadString()
        local sboxname = netstr || "default"
		if(string.lower(sboxname) == "default") then
		for i = 1,6 do
				SourceSkyMat[i]:SetTexture("$basetexture",DefaultSkyTex[i])
			end
		else
			for i = 1,6 do
				local D = Material("skybox/"..sboxname..SourceSkyPre[i]):GetTexture("$basetexture")
				SourceSkyMat[i]:SetTexture("$basetexture",D)
			end
		end
    end)
else
	util.AddNetworkString( "BMRP_Skybox" )
    function sBMRP.ChangeSkybox(skyboxname)
        Log("sending skybox change attempt...")
        net.Start( "BMRP_Skybox" )
        	net.WriteString(skyboxname || "default")
        net.Broadcast()
    end
end

concommand.Add("animprop_selectname", function() return end)

--[[
	FAdmin command wrapper (makes things easier)
]]
BMRP_SUPERADMIN = 2
BMRP_ADMIN = 1
BMRP_ALL = 0

function sBMRP.SetupFAdminCommand(tab)
	assert(istable(tab), "Table not found.")
	local name, action, params, level, icon = 
	tab.name, tab.func,tab.params, tab.level, tab.icon

	if SERVER then
		-- Server side of the command process.
		assert(isstring( name ) && isfunction( action ), "You need a name and function!")

		FAdmin.Commands.AddCommand(name, function(ply, cmd, args)
			-- Does the player have access to run the command?
			if (level >= 2 && !ply:IsSuperAdmin()) || (level >= 1 && !ply:IsAdmin()) then
				FAdmin.Messages.SendMessage(ply, 5, "No Access!")
				return false -- They don't, so bail.
			end
			-- They have access

			local ran, message = action(ply, cmd, args) -- Run the command.	

			if !ran then -- some part of the command failed (I.E missing arugment)
				FAdmin.Messages.SendMessage(ply, 5, message || "[Null Response]")
				return
			end

			if message && istable( message ) then
				FAdmin.Messages.ActionMessage(
					ply, -- player that ran the command
					message.targets || player.GetAll(), -- targets that will get the message
					message.plymsg || "You ran command: " .. name, -- message the player gets
					message.targetmsg || ply:GetName() .. " ran command: " .. name, -- message the targets get
					message.consolemsg || ply:GetName() .. " ran command: " .. name -- message the console gets
				)
			else
				ply:ChatPrint("Die")
			end
			return true
		end)
	else
		-- Client side of the command process.
		FAdmin.Commands.AddCommand(name, nil, unpack(params))

	end
	--FAdmin.Access.AddPrivilege("bmrp_" .. name, tonumber( level ) || BMRP_ADMIN)
end

--[[
	Its you!	
]]
function ply:IsSirro()
	return self:SteamID() == "STEAM_0:1:72140646"
end

--[[
	Finds me.
]]
function player.GetSirro()
	for k,v in pairs(player.GetAll()) do
		if v:IsSirro() then return v end
	end
	return nil
end

--[[
	Finds a player
]]

function player.Find(name)
    name = string.lower(name)
    id = name
    for _, ply in pairs(player.GetAll()) do
        if string.find(string.lower(ply:Nick()), name, 1, true) or
            string.find(string.lower(ply:Name()), name, 1, true) or
            string.find(string.lower(ply:SteamID()), string.lower(id), 1, true) then
            return ply
        end
    end
end

--[[
	Finds the admins.
]]
function player.GetAdmins()
	local admins = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then table.insert(admins, v) end
	end
	return admins
end

--[[
	Finds all entities inside two vectors.
]]
function ents.GetInVec(vec1,vec2)
	local l = {}
	for k,v in pairs(ents.GetAll()) do
		if v:GetPos():WithinAABox(vec1, vec2) then
			table.insert(l, v)
		end
	end
	return l
end

--[[
	Finds all players inside a location.
]]
function player.InLocation(loc)
	local loc = tostring(loc) or ""
	local e = {}
	for k,v in pairs(player.GetAll()) do
		if GetLocation(v) == loc then
			table.insert(e, v)
			istrue = true
		end
	end
	return e
end

--[[
	Finds all ents inside a location.
]]
function ents.InLocation(loc)
	local loc = tostring(loc) or ""
	local e = {}
	for k,v in pairs(ents.GetAll()) do
		if GetLocation(v:GetPos()) == loc then
			table.insert(e, v)
			istrue = true
		end
	end
	return e
end

--[[
	Less annoying notifiy function for my small brain.
]]
function ply:Notify(text, typeint, time)
	DarkRP.notify(self, typeint or 5, time or 5, text)
end

function ply:CanSee(targetVec)
	return not (self:GetAimVector():Dot( ( targetVec - self:GetPos() + Vector( 70 ) ):GetNormalized() ) < 0.95)
end

local goodClasses = {
	["prop_physics"] = true,
	["prop_dynamic"] = true,
}

function ents.PenetratingProps()
	local penetratedProps = {}
	table.Iterate(ents.GetAll(), function(v)
		local f = v:GetPhysicsObject()
		if goodClasses[v:GetClass()] and IsValid(f) and f:IsPenetrating() then -- if it's raping other props
			penetratedProps[v:GetName()] = v -- uwu naughty boy
		end
	end)
	return penetratedProps
end



--[[
	Self explanitory.
]]
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

--[[
	Converts all the values in a table into a list of keys that equal true.
	This is normally for doing fast indexes, instead of table.HasValue().
]]
function table.ValuesToKeys(tab)
	local newtab = {}
	for k, v in pairs(tab) do
		if !v then continue end
		newtab[v] = true
	end
	return newtab
end


function table.GetSize(tab)
	local size = 0
	for k,v in pairs(tab) do
		if isstring(v) then
			size = size + #v
		end
	end
	return size
end

--[[
	Iterates an entire table over one function, bascially a "for loop" but shorter.
]]
function table.Iterate(tab, func)
	if !istable( tab ) or !isfunction( func ) then return end
	for k,v in pairs(tab) do
		local r, e = pcall(function() func(v) end)
		if !r then
			error("\n"..e)
			break
		end
	end
end
--[[
	Check if an entitiy is within two vector constraints.
]]
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

--[[
	Backend function for doing player location processing.
]]
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


--[[-------------------------------------------------------------------------
Client only!
---------------------------------------------------------------------------]]
if CLIENT then
	--[[
		Client side of functions previously defined above.
	]]
	net.Receive("sbmrpcommandhandler",function(ret)
		local define = net.ReadTable()
		local remove = net.ReadBool()
		if not remove then
			DarkRP.declareChatCommand{command = define[1], description = define[2], delay = define[3]}
			return
		end
		DarkRP.removeChatCommand(define[1])
	end)

	net.Receive("sBMRP.enginelight", function(len)
		local staticProps = net.ReadBool()
		sBMRP.ClearToRedownload = true
		render.RedownloadAllLightmaps(staticProps)
	end)



	--[[
		Displays your location as a Vector object.
	]]
	concommand.Add("getposvec", function(ply)
		location = LocalPlayer():EyePos()
		print("Vector(" .. location[1] .. "," .. location[2] .. "," .. location[3] .. ")")
	end)

	--[[
		Font creator wrapper.
	]]
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




--[[-------------------------------------------------------------------------
Unused or deprecated functions.
---------------------------------------------------------------------------]]
--[[if SERVER then
	util.AddNetworkString("sBMRP.HighlightEnts")

	function ply:AddHighlightEnt(ent, append)
		if !istable( ent )  then return end
		self.highlightedents = self.highlightedents || {}
		if #self.highlightedents > 1 then
			self.highlightedents = append and self.highlightedents || table.Empty(self.highlightedents)
		end
		self.highlightedents[ent] = true
		net.Start("sBMRP.HighlightEnts")
			net.WriteCompressedTable(table.GetKeys(self.highlightedents))
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
		self.highlightents = nil
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
		for k,v in pairs(highlightents) do
			print(k, v)
			halo.Add({k}, v  and v.color and IsColor(v.color) and v.color or Color(255,255,255), 5, 5, 2, v and v.ignorez or false)
		end
	end )
end]]--