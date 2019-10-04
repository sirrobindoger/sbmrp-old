local net = net


net.OrigWriteTable = net.OrigWriteTable or net.WriteTable
net.OrigReadTable = net.OrigReadTable or net.ReadTable

function net.ReadCompressedTable()
	local size = net.ReadUInt(32)

	-- size of zero indicates an empty table
	if size == 0 then
		return {}
	end

	return von.deserialize(util.Decompress(net.ReadData(size)))
end

function net.WriteCompressedTable(tbl)
	if next(tbl) == nil then -- is table empty
		-- send a size of zero to indicate an empty table
		net.WriteUInt(0, 32)
	else
		local compressedTbl = util.Compress(von.serialize(tbl))
		local size = compressedTbl:len()
		print(size)
		net.WriteUInt(size, 32)
		net.WriteData(compressedTbl, size)
	end
end

--[[
	Hotloading function, bascially it forces a player to download a workshop addon,
	that player then sends that file to the server so that the server can mount it.
	705356556
]]



file.CreateDir("sbmrp-cache")

REGISTERED_TOOLS = REGISTERED_TOOLS || {}

--[[-------------------------------------------------------------------------
Shared section
---------------------------------------------------------------------------]]
local oPrint = oPrint || print
local print = function(...) return oPrint("[sHotMount] " .. ...) end -- Yes, I'm detouring print cause i'm that lazy, fuck you.
function compileWeapon(path, wepname, tool)
	local wepname = wepname:Replace(".lua", "")
	--if tool then print(wepname .. " is a tool, those are not supported (yet), skipping.") return end
	oldCSLua = oldCSLua || AddCSLuaFile
	oldInclude = oldInclude || include
	AddCSLuaFile = function()  end
	include = function(p)
		if #p:Split("/") <= 1 then
			if SERVER then
				return CompileFile(table.concat(path:Split("/"), "/", 1, 2) .. "/" ..  p)()
			else
				return CompileString(f_Read(table.concat(path:Split("/"), "/", 1, 2) .. "/" ..  p), p)()
			end
		end
		return CompileFile(p)() 
	end
	SWEP = weapons.Get("weapon_base")
	--[[
		Tool object registry
	]]
	if tool then
		ToolObj = newToolObj()
		TOOL = ToolObj:Create()
		TOOL.Mode = wepname
		
	end
	if SERVER then
		CompileFile(path)()
	else
		CompileString(f_Read(path), path)()
	end
	--[[
		Add tool into menu system.
	]]
	if tool then
		REGISTERED_TOOLS[wepname] = TOOL
		toolName = TOOL.Name or "#" .. wepname
		TOOL:CreateConVars()
		//SWEP.Tool[ wepname ] = TOOL
		hook.Add( "PopulateToolMenu", "sHotMount_tool_" .. wepname, function()
			TOOL = TOOL || REGISTERED_TOOLS[wepname]
			if ( TOOL.AddToMenu != false ) then
				spawnmenu.AddToolMenuOption(
					TOOL.Tab or "Main",
					TOOL.Category or "New Category",
					wepname,
					TOOL.Name or "#" .. wepname,
					TOOL.Command or "gmod_tool " .. wepname,
					TOOL.ConfigName or wepname,
					TOOL.BuildCPanel
				)
			end
			--hook.Remove("PopulateToolMenu", "sHotMount_tool_" .. wepname)
		end)
		TOOL = nil
		ToolObj = nil
	end

	weapons.Register(SWEP, wepname:Replace(".lua", ""))
	print("Registered " .. (tool and "tool: " .. toolName or "weapon: " .. SWEP.PrintName ) || "NULL")
	SWEP = nil
	AddCSLuaFile = oldCSLua
	include = oldInclude
end

function compileEnt(path, enttname)
	oldCSLua = oldCSLua || AddCSLuaFile
	oldInclude = oldInclude || include
	AddCSLuaFile = function()  end
	include = function(p)
		if #p:Split("/") <= 1 then
			if SERVER then
				return CompileFile(table.concat(path:Split("/"), "/", 1, 2) .. "/" ..  p)()
			else
				return CompileString(f_Read(table.concat(path:Split("/"), "/", 1, 2) .. "/" ..  p), p)()
			end
		end
		return CompileFile(p)()
	end
	ENT = scripted_ents.Get("base_gmodentity")
	if SERVER then
		CompileFile(path)()
	else
		CompileString(f_Read(path), path)()
	end
	scripted_ents.Register(ENT, enttname:Replace(".lua", ""))
	print("Registered entity: " .. ENT.PrintName || "NULL")
	ENT = nil
	AddCSLuaFile = oldCSLua
	include = oldInclude
end


if SERVER then
	util.AddNetworkString("sHotMount")
	util.AddNetworkString("sHotMount.Catchup")
	LOADED_ADDONS = LOADED_ADDONS || {}
	function sLoad(WSID)
		print("Downloading GMA...")
		http.Fetch("https://sbmrp.com/workshop/?id=" .. WSID, function(body)
			print("Decompressing/Mounting GMA (" .. string.NiceSize(#body) .. ")")
			file.Write("sbmrp-cache/" .. WSID .. ".dat", util.Decompress(body))
			local success, tab = game.MountGMA("data/sbmrp-cache/" .. WSID .. ".dat")
			if success then
				print("Succesfully mounted addon!")
				compileFiles(tab)
				LOADED_ADDONS[WSID] = tab
				net.Start("sHotMount")
					net.WriteInt(WSID, 32)
				net.Broadcast()
				resource.AddWorkshop(WSID)
			end
		end)
	end

	net.Receive("sHotMount.Catchup",  function(len, ply)
		net.Start("sHotMount.Catchup")
			net.WriteTable(LOADED_ADDONS)
		net.Send(ply)
		print("Catching up " .. ply:GetName())
	end)

end


function compileFiles(path)
	local s, c = SERVER, CLIENT
	local weps, ent, auto = 0, 0, 0

	for k,v in pairs(path) do
		if v:find("lua/") then
			local t = v:Split("/")
			local lPath = table.concat(t, "/", 2)
			if t[2] == "autorun" then
				if t[3] == "server" then
					if s then CompileFile(lPath)() end
				elseif t[3] == "client" then
					if c then CompileString(f_Read(lPath), v) end
				else
					if s then
						CompileFile(lPath)()
					else
						CompileString(f_Read(lPath), v)
					end
				end
				auto = auto + 1
			elseif t[2] == "weapons" then
				if t[4] and t[4] == "init.lua" then
					if s then compileWeapon(lPath, t[3]) end
				elseif t[4] and t[4] == "shared.lua" then
					continue
				elseif t[4] and t[4] == "cl_init.lua" then
					if c then compileWeapon(lPath, t[3]) end
				else
					compileWeapon(lPath, t[3] != "gmod_tool" and t[3] or t[5],t[3] == "gmod_tool" )
				end
				weps = weps + 1
			elseif t[2] == "entities" then
				if t[4] and t[4] == "init.lua" then
					if s then compileEnt(lPath, t[3]) end
				elseif t[4] and t[4] == "shared.lua" then
					continue
				elseif t[4] and t[4] == "cl_init.lua" then
					if c then compileEnt(lPath, t[3]) end
				else
					compileEnt(lPath, t[3])
				end
				ent = ent + 1
			end
		elseif v:find(".mdl") then
			util.PrecacheModel(v)
		end
	end
	
	if ent > 0 or weps > 0 or auto > 0 then
		timer.Create("sHotMount.refreshMenus", 10, 1, function()
			if CLIENT then
				RunConsoleCommand("spawnmenu_reload")
				chat.AddText(Color(0, 118, 204), "[sHotMounter] ", Color(52, 158, 235), "New addons detected, re-loading menu system.")
			else
				print("New addons detected, reloading menu systems.")
			end
		end)
	end
	
	print("Compiled " .. ent .. " entities, " .. weps .. " weapons and " .. auto .. " autorun files.")
end



if CLIENT then
	function f_Read(path) return file.Read(path, "LUA") end
	net.Receive("sHotMount", function()
		local WSID = net.ReadInt(32)
		local host = net.ReadString()

		--[[
			Verify addon's existance
		]]
		steamworks.FileInfo( WSID, function( dat )
			if not dat then
				print( "HOST INSTALL FAILED>>>"  .. WSID)
				return
			end
			print("Downloading/Mounting " .. dat.title)
			--[[
				Install Addon
			]]
			steamworks.Download( dat.fileid, true, function( path )
				local success, tab = game.MountGMA(path) -- Mount addon
				if !success then return end

				print("Successfully loaded " .. dat.title)
				compileFiles(tab)



			end )
		end )
	end)

	hook.Add("InitPostEntity", "hotmount_catchup", function()
		print("Starting catchup.")
		net.Start("sHotMount.Catchup")
		net.WriteString("a")
		net.SendToServer()
	end)

	net.Receive("sHotMount.Catchup", function()
		print("Got catchup table.")
		local addonTab = net.ReadTable()
		PrintTable(addonTab)
		for k,v in pairs(addonTab) do
			compileFiles(v)
		end
	end)
end

--[[-------------------------------------------------------------------------
Tool meta stuff
-	Don't fucking judge me, i don't know enough about enviornments to ""simulate"" it any other way.
---------------------------------------------------------------------------]]
function newToolObj()
	local toolPath = "weapons/gmod_tool/"
	local oldInclude = oldInclude || include
	local include = function(p) return oldInclude(toolPath .. p) end
	ToolObj = {}

	include( "ghostentity.lua" )
	include( "object.lua" )

	if ( CLIENT ) then
		include( "stool_cl.lua" )
	end

	function ToolObj:Create()

		local o = {}

		setmetatable( o, self )
		self.__index = self

		o.Mode				= nil
		o.SWEP				= nil
		o.Owner				= nil
		o.ClientConVar		= {}
		o.ServerConVar		= {}
		o.Objects			= {}
		o.Stage				= 0
		o.Message			= "start"
		o.LastMessage		= 0
		o.AllowedCVar		= 0

		return o

	end

	function ToolObj:CreateConVars()

		local mode = self:GetMode()

		if ( CLIENT ) then

			for cvar, default in pairs( self.ClientConVar ) do

				CreateClientConVar( mode .. "_" .. cvar, default, true, true )

			end

			return
		end

		-- Note: I changed this from replicated because replicated convars don't work
		-- when they're created via Lua.

		if ( SERVER ) then

			self.AllowedCVar = CreateConVar( "toolmode_allow_" .. mode, 1, FCVAR_NOTIFY )

		end

	end

	function ToolObj:GetServerInfo( property )

		local mode = self:GetMode()

		return GetConVarString( mode .. "_" .. property )

	end

	function ToolObj:BuildConVarList()

		local mode = self:GetMode()
		local convars = {}

		for k, v in pairs( self.ClientConVar ) do convars[ mode .. "_" .. k ] = v end

		return convars

	end

	function ToolObj:GetClientInfo( property )

		return self:GetOwner():GetInfo( self:GetMode() .. "_" .. property )

	end

	function ToolObj:GetClientNumber( property, default )

		return self:GetOwner():GetInfoNum( self:GetMode() .. "_" .. property, tonumber( default ) or 0 )

	end

	function ToolObj:Allowed()

		if ( CLIENT ) then return true end
		return self.AllowedCVar:GetBool()

	end

	-- Now for all the ToolObj redirects

	function ToolObj:Init() end

	function ToolObj:GetMode()		return self.Mode end
	function ToolObj:GetSWEP()		return self.SWEP end
	function ToolObj:GetOwner()		return self:GetSWEP().Owner or self.Owner end
	function ToolObj:GetWeapon()	return self:GetSWEP().Weapon or self.Weapon end

	function ToolObj:LeftClick()	return false end
	function ToolObj:RightClick()	return false end
	function ToolObj:Reload()		self:ClearObjects() end
	function ToolObj:Deploy()		self:ReleaseGhostEntity() return end
	function ToolObj:Holster()		self:ReleaseGhostEntity() return end
	function ToolObj:Think()		self:ReleaseGhostEntity() end


	return ToolObj

end




