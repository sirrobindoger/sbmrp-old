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

--[[
	These two functions must exist outside the package or else they will not work
	It took me a while to figure it out and now im suicidal
]]



if SERVER then
	util.AddNetworkString("Hot.Start")
	util.AddNetworkString("Hot.Request")
	util.AddNetworkString("Hot.Execute")
	function compileWeapon(path, wepname)
		oldCSLua = oldCSLua || AddCSLuaFile
		oldInclude = oldInclude || include
		AddCSLuaFile = function()  end
		include = function(p)
			local sEnt = {
				["init.lua"] = true,
				["cl_init.lua"] = true,
				["shared.lua"] = true,
			}
			if sEnt[p] then
				return CompileFile(table.concat(path:Split("/"), "/", 1, 2) .. "/" ..  p)()
			end
			CompileFile(p)() 
		end
		SWEP = weapons.Get("weapon_base")
		CompileFile(path)()
		weapons.Register(SWEP, wepname:Replace(".lua", ""))
		print("Registered weapon: " .. SWEP.PrintName or "NULL")
		SWEP = nil
		AddCSLuaFile = oldCSLua
		include = oldInclude
	end

	function compileEnt(path, enttname)
		oldCSLua = oldCSLua || AddCSLuaFile
		oldInclude = oldInclude || include
		AddCSLuaFile = function()  end
		include = function(p)
			local sEnt = {
				["init.lua"] = true,
				["cl_init.lua"] = true,
				["shared.lua"] = true,
			}
			if sEnt[p] then
				return CompileFile(table.concat(path:Split("/"), "/", 1, 2) .. "/" .. p)()
				
			end
			return CompileFile(p)() 
		end
		ENT = scripted_ents.Get("base_gmodentity")
		CompileFile(path)()
		scripted_ents.Register(ENT, enttname:Replace(".lua", ""))
		print("Registered entity: " .. ENT.PrintName or "NULL")
		ENT = nil
		AddCSLuaFile = oldCSLua
		include = oldInclude
	end
else
	function compileWeapon(code, name, path)
		local oldInclude = include
		include = function(p)
			local sEnt = {
				["init.lua"] = true,
				["cl_init.lua"] = true,
				["shared.lua"] = true,
			}
			if sEnt[p] then
				return CompileString(LUA_CACHE[table.concat(path:Split("/"), "/", 1, 2) .. "/" .. p], name)()
			end
			return CompileFile(p)() 
		end
		SWEP = weapons.Get("weapon_base")
			CompileString(code, name:Replace(".lua", ""))()
			weapons.Register(SWEP, name:Replace(".lua", ""))
			print("Registered weapon: " .. SWEP.PrintName or "NULL")
		SWEP = nil
		include = oldInclude
	end

	function compileEnt(code, name, path)
		local oldInclude = include
		include = function(p)
			local sEnt = {
				["init.lua"] = true,
				["cl_init.lua"] = true,
				["shared.lua"] = true,
			}
			if sEnt[p] then
				return CompileString(LUA_CACHE[table.concat(path:Split("/"), "/", 1, 2) .. "/" .. p], name)()
				
			end
			return CompileFile(p)() 
		end
		ENT = scripted_ents.Get("base_gmodentity")
			CompileString(code, name)()
			scripted_ents.Register(ENT, name:Replace(".lua", ""))
			print("Registered entity: " .. ENT.PrintName or "NULL")
		ENT = nil
		include = oldInclude
	end
end
file.CreateDir("sbmrp-cache")
timer.Remove("hotmount_fetch")
sHotMount = {}
TRANSMIT_CACHE = {}
LOADED_ADDONS = {}
if SERVER then

	TRANSMIT_CACHE = TRANSMIT_CACHE || {}
	function sHotMount.Load(WSID)
		print("Starting hotload for " .. WSID .. ".")
		local host, pi = nil, math.huge
		table.Iterate(player.GetAll(), function(v)
			if v:Ping() < pi and v:Team() != TEAM_VISITOR then
				pi = v:Ping()
				host = v
			end
		end)
		if file.Exists("sbmrp-cache/" .. WSID .. ".dat", "DATA") then
			print("File already exists in cache! Skipping fragment-download!")
			net.Start("Hot.Start")
				net.WriteInt(WSID, 32)
				net.WriteString("-1")
			net.Broadcast()

			TRANSMIT_CACHE[WSID] = {file.Read("sbmrp-cache/" .. WSID .. ".dat", "DATA")}

			compileToGMA(WSID)
		else
			print("File doesn't exist in cache. Starting download...")
			net.Start("Hot.Start")
				net.WriteInt(WSID, 32)
				net.WriteString(host:SteamID())
			net.Broadcast()
		end

	end
	function checkForCompletion(wsid)
		if !TRANSMIT_CACHE[wsid] then return nil end
		local isComplete = true
		local emptyFrags, transitFrags = {}, {}
		for i = 1, #TRANSMIT_CACHE[wsid] do
			if TRANSMIT_CACHE[wsid][i] == 0 then
				table.insert(transitFrags, i)
				isComplete = false
			elseif TRANSMIT_CACHE[wsid][i] == -1 then
				table.insert(emptyFrags, i)
				isComplete = false
			end
		end
		return isComplete, emptyFrags, transitFrags
	end
	function sendLuaFile(path, type, t)
		local fCode = file.Read(path, "LUA")
		net.Start("Hot.Execute")
			net.WriteTable(t)
			net.WriteString(type)
			net.WriteString(path)
			net.WriteInt(#fCode, 32)
			net.WriteData(fCode, #fCode)
		net.Broadcast()
	end

	--lua_run sHotMount.Load("535135982")
	function compileLuaFiles(path)
		local weps, ent, auto = 0, 0, 0

		for k,v in pairs(path) do
			if v:find("lua/") then
				local t = v:Split("/")
				local lPath = table.concat(t, "/", 2)
				if t[2] == "autorun" then
					if t[3] == "server" then
						CompileFile(lPath)()
					elseif t[3] == "client" then
						sendLuaFile(lPath, "autorun", t)
					else
						CompileFile(lPath)()
						sendLuaFile(lPath, "autorun", t)
					end
					auto = auto + 1
				elseif t[2] == "weapons" then
					if t[4] and t[4] == "init.lua" then
						compileWeapon(lPath, t[3])
					elseif t[4] and t[4] == "shared.lua" then
						compileWeapon(lPath, t[3])
						sendLuaFile(lPath, "weapon", t)
					elseif t[4] and t[4] == "cl_init.lua" then
						sendLuaFile(lPath, "weapon", t)
					else
						compileWeapon(lPath, t[3])
						sendLuaFile(lPath, "weapon", t)						
					end
					weps = weps + 1
				elseif t[2] == "entities" then
					if t[4] and t[4] == "init.lua" then
						compileEnt(lPath, t[3])
					elseif t[4] and t[4] == "shared.lua" then
						compileEnt(lPath, t[3])
						sendLuaFile(lPath, "entity", t)
					elseif t[4] and t[4] == "cl_init.lua" then
						sendLuaFile(lPath, "entity", t)
					else
						compileEnt(lPath, t[3])
						sendLuaFile(lPath, "entity", t)				
					end
					ent = ent + 1
				else
					sendLuaFile(lPath, "cache", t)
				end
			end
		end

		print("Compiled " .. ent .. " entities, " .. weps .. " weapons and " .. auto .. " autorun files.")
	end
	function compileToGMA(wsid)
		local addon = table.concat(TRANSMIT_CACHE[wsid])
		local writePath = "sbmrp-cache/" .. wsid .. ".dat"
		print(string.NiceSize(#addon) .. "<-- ADDON SIZE")
		file.Write(writePath, addon)
		local success, tab = game.MountGMA("data/" .. writePath)
		resource.AddWorkshop(wsid)
		if success then
			print("MOUNTED FILE SUCCESSFULLY!")
			PrintTable(tab)
			LOADED_ADDONS[wsid] = tab
			compileLuaFiles(LOADED_ADDONS[wsid])
		else
			file.Delete(writePath)
			print("FILE FAILED TO MOUNT!")
		end
	end
	--[[-------------------------------------------------------------------------
	TODO:

		Task assigining for players (each player retrieves one fragment)
		Make a function that returns an empty fragment part, if there are none return nil
		resource.AddWorkshop()
		Lua mounting
	---------------------------------------------------------------------------]]

	net.Receive("Hot.Start", function()

		local addonID = net.ReadString()
		local fragmentSize = net.ReadInt(32)

		print("Fragments to collect: " .. fragmentSize)
		TRANSMIT_CACHE[addonID] = {}
		for i = 1, fragmentSize do
			TRANSMIT_CACHE[addonID][i] = -1
		end
		timer.Simple(10, function()
			table.Iterate(player.GetAll(), function(ply)
				if !ply:GetNWBool("isactive") then return end
				local sID = ply:SteamID64()
				ply.attFrag = 3
				timer.Create("hotmount_" .. sID, 0, 0, function()
					local complete, frags = checkForCompletion(addonID)
					if frags[1] then
						local frag = frags[1]
						net.Start("Hot.Request")
							net.WriteString(addonID)
							net.WriteInt(frag, 16)
						net.Send(ply)
						print("Requesting fragment: " .. frag .. "/" .. #TRANSMIT_CACHE[addonID] .. " from " .. ply:GetName())
						TRANSMIT_CACHE[addonID][frag] = 0
						timer.Pause("hotmount_" .. sID)
						timer.Simple(5, function()
							if TRANSMIT_CACHE[addonID][frag] == 0 then
								TRANSMIT_CACHE[addonID][frag] = -1
								if ply.attFrag <= 0 then
									timer.Remove("hotmount_" .. sID)
									print(ply:GetName() .. " " ..  ply.attFrag .. " attempts left.")
								else
									ply.attFrag = ply.attFrag - 1
									print(ply:GetName() .. " " ..  ply.attFrag .. " attempts left.")
									timer.UnPause("hotmount_" .. sID)
								end
							end
						end)
					elseif complete then
						print(ply:GetName() .. " has completed its task!")
						timer.Remove("hotmount_" .. sID)
						return
					end
				end)
			end)
		end)
	end)

	net.Receive("Hot.Request", function(len, ply)
		local wsid = net.ReadString()
		local fid = net.ReadInt(16)
		local size = net.ReadInt(32)
		local fragment = net.ReadData(size)

		print("RECIEVED FRAGMENT: " .. fid .. " : " .. string.NiceSize(#fragment) .. " SIZE!")

		TRANSMIT_CACHE[wsid][fid] = util.Decompress(fragment)

		timer.UnPause("hotmount_" .. ply:SteamID64())
		print("Resuming " .. ply:GetName())
		local complete, frags = checkForCompletion(wsid)

		if complete then
			print("Got all files!")
			compileToGMA(wsid)
		end

	end)
	net.Receive("Hot.Execute", function(len, ply)
		for k,v in pairs(LUA_CACHE) do
			compileLuaFiles(k)
		end
	end)
end
if CLIENT then
	print("Running")
	LUA_CACHE = LUA_CACHE || {}
	net.Receive("Hot.Execute", function()
		local t = net.ReadTable()
		local lType = net.ReadString()
		local lPath = net.ReadString()
		local size = net.ReadInt(32)
		local lCode = net.ReadData(size)
		LUA_CACHE[lPath] = lCode
		timer.Simple(2, function()
			if lType == "autorun" then
				CompileString(lCode, "sHotMount-" .. lPath)
			elseif lType == "weapon" then
				compileWeapon(lCode, t[3], lPath)
			elseif lType == "entity" then
				compileEnt(lCode, t[3], lPath)
			end
		end)
	end)
	net.Receive("Hot.Start", function()
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
				local f_RAW, f_PATH = file.Read(path, "GAME"), "sbmrp-cache/" .. WSID .. ".dat"
				print("Mouting...")
				if host == "-1" then return end
				file.Write(f_PATH, f_RAW)
				fragmentAddon(f_PATH, WSID, host)
				print("Mounted.")
			end )
		end )
	end)

	hook.Add("InitPostEntity", "catch_lua", function()
		net.Start("Hot.Execute")
		net.SendToServer()
	end)

	concommand.Add("testUpload", function()
		fragmentAddon("sbmrp-cache/705356556.dat")
	end)
	net.Receive("Hot.Request", function()
		local wsid = net.ReadString()
		local fragmentID = net.ReadInt(16)

		local path = "sbmrp-cache/" .. wsid .. ".dat"
		if not TRANSMIT_CACHE[path] or not TRANSMIT_CACHE[path][fragmentID] then return end
		local fragment = TRANSMIT_CACHE[path][fragmentID]
		net.Start("Hot.Request")
			net.WriteString(wsid)
			net.WriteInt(fragmentID, 16)
			net.WriteInt(#fragment, 32)
			net.WriteData(fragment, #fragment)
		net.SendToServer()
	end)
	local sizeCompress = 64000
	function fragmentAddon(f, id, host)
		local addonCompressFrag = file.Read(f, "DATA")		
		local init_fragments = {}
		local i = 1
		timer.Create("split_up-slowley", .1, 0, function()
			local fragment = #addonCompressFrag > sizeCompress and addonCompressFrag:Left(sizeCompress) or addonCompressFrag
			local fr = util.Compress(fragment)
			init_fragments[i] = fr
			addonCompressFrag = #addonCompressFrag > sizeCompress and addonCompressFrag:sub(#fragment) or ""
			--print("FRAGMENT " .. i .. " : " .. #fr .. " (" .. #addonCompressFrag .. ") remaining.")
			i = i + 1
			if #addonCompressFrag <= 0 then 
				timer.Remove("split_up-slowley") 
				combineAndSend(f, id, init_fragments, host)
			end
		end)
	end
	function combineAndSend(f, id, init_fragments, host)
		TRANSMIT_CACHE[f] = {}
		local transitcount = 1
		local previ = ""
		for i = 1, #init_fragments do
			local combine = previ .. init_fragments[i]
			if #combine <= sizeCompress then
				previ = previ .. combine
				TRANSMIT_CACHE[f][transitcount] = combine
			else
				previ = ""
				transitcount = transitcount + 1
			end
		end
		print("Debug1")
		--print(#TRANSMIT_CACHE[f])
		print("Fragment tree built. Sending to server...")
		if host != LocalPlayer():SteamID() then return end
		net.Start("Hot.Start")
			net.WriteString(id)
			net.WriteInt(#TRANSMIT_CACHE[f], 32)
		net.SendToServer()
	end
	
end
