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



--[[-------------------------------------------------------------------------
Shared section
---------------------------------------------------------------------------]]
local oPrint = oPrint || print
local print = function(...) return oPrint("[sHotMount] " .. ...) end -- Yes, I'm detouring print cause i'm that lazy, fuck you.
function compileWeapon(path, wepname)
	oldCSLua = oldCSLua || AddCSLuaFile
	oldInclude = oldInclude || include
	AddCSLuaFile = function()  end
	file.Write("hehe.txt", file.Read(path, "LUA"))
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
	if SERVER then
		CompileFile(path)()
	else
		CompileString(f_Read(path), path)()
	end
	weapons.Register(SWEP, wepname:Replace(".lua", ""))
	print("Registered weapon: " .. SWEP.PrintName || "NULL")
	SWEP = nil
	AddCSLuaFile = oldCSLua
	include = oldInclude
end

function compileEnt(path, enttname)
	oldCSLua = oldCSLua || AddCSLuaFile
	oldInclude = oldInclude || include
	AddCSLuaFile = function()  end
	include = function(p)
		print(#path:Split("/") .. "<-- PATH")
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
	LOADED_ADDONS = {}
	function sLoad(WSID)
		print("Downloading GMA...")
		http.Fetch("https://sbmrp.com/workshop/?id=" .. WSID, function(body)
			print("Decompressing/Mounting GMA (" .. string.NiceSize(#body) .. ")")
			file.Write("sbmrp-cache/" .. WSID .. ".dat", util.Decompress(body))
			local success, tab = game.MountGMA("data/sbmrp-cache/" .. WSID .. ".dat")
			if success then
				print("Succesfully mounted addon!")
				PrintTable(tab)
				compileLuaFiles(tab)
				LOADED_ADDONS[WSID] = tab
				net.Start("sHotMount")
					net.WriteInt(WSID, 32)
				net.Broadcast()
			end
		end)

	end
end


local function compileLuaFiles(path)
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
					compileWeapon(lPath, t[3])
				elseif t[4] and t[4] == "cl_init.lua" then
					if c then compileWeapon(lPath, t[3]) end
				else
					compileWeapon(lPath, t[3])
				end
				weps = weps + 1
			elseif t[2] == "entities" then
				if t[4] and t[4] == "init.lua" then
					if s then compileEnt(lPath, t[3]) end
				elseif t[4] and t[4] == "shared.lua" then
					compileEnt(lPath, t[3])
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
				PrintTable(tab)
				compileLuaFiles(tab)
				print("Mounted.")
			end )
		end )
	end)




end
