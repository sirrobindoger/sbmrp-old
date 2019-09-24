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
timer.Remove("hotmount_fetch")
didRun = false
TRANSMIT_CACHE = {}
if SERVER then
	util.AddNetworkString("sHotmount.Start")
	util.AddNetworkString("sHotmount.Request")
	TRANSMIT_CACHE = TRANSMIT_CACHE || {}
	function sBMRP.HotLoad(WSID)
		print("Starting hotload for " .. WSID .. ".")
		local host, pi = nil, math.huge
		table.Iterate(player.GetAll(), function(v)
			if v:Ping() < pi and v:Team() != TEAM_VISITOR then
				pi = v:Ping()
				host = v
			end
		end)
		print("HOST " .. host:GetName())
		net.Start("sHotmount.Start")
			net.WriteInt(WSID, 32)
			net.WriteString(host:SteamID())
		net.Broadcast() // TODO: CHANGE
	end
	--[[-------------------------------------------------------------------------
	TODO:

		Task assigining for players (each player retrieves one fragment)
		Make a function that returns an empty fragment part, if there are none return nil
		resource.AddWorkshop()
		Lua mounting
	---------------------------------------------------------------------------]]
	net.Receive("sHotmount.Start", function()
		local addonID = net.ReadString()
		local fragmentSize = net.ReadInt(32)

		print("Fragments to collect: " .. fragmentSize)
		TRANSMIT_CACHE[addonID] = {}
		for i = 1, fragmentSize do
			TRANSMIT_CACHE[addonID][i] = -1
		end
		local playeritr = 1
		timer.Create("hotmount_fetch", 1, 5, function()

			for k,ply in pairs(player.GetAll()) do
				if !ply:GetNWBool("isactive") and not ply.isSending then continue end
				for i = 1, fragmentSize do
					if TRANSMIT_CACHE[addonID][i] == -1 and not ply.isSending then
						print("Assigned " .. ply:GetName() .. " with getting fragment " .. i)
						TRANSMIT_CACHE[addonID][i] = 0
						ply.isSending = true
						didRun = true
						net.Start("sHotmount.Request")
							net.WriteString(addonID)
							net.WriteInt(i, 16)
						net.Send(ply)
						timer.Simple(5, function()
							if TRANSMIT_CACHE[addonID][i] == 0 then
								print("FRAGMENT: " .. i .. " timed out!")
								ply.isSending = false
							end
						end)
					end
				end		
			end
			if didRun then return end
			local compressedAddon =  "" // table.concat(TRANSMIT_CACHE[addonID])
			for i = 1, fragmentSize do
				if TRANSMIT_CACHE[addonID][i] == -1 || TRANSMIT_CACHE[addonID][i] == "" then
					print("MISSING FRAGMENT " .. i .. "???")
					return
				end
				compressedAddon = compressedAddon .. TRANSMIT_CACHE[addonID][i]
			end
			local addon = compressedAddon //util.Decompress(compressedAddon) or "" -- we made it :D
			local writePath = "sbmrp-cache/" .. addonID .. ".dat"
			print(#compressedAddon .. "<-- THINGY")
			print(#addon .. "<-- -THINGY 2!")
			print(writePath)
			file.Write(writePath, addon)
			local success, tab = game.MountGMA("data/" .. writePath)
			if success then
				print("MOUNTED FILE SUCCESSFULLY!")
				PrintTable(tab)
			else
				print("FILE FAILED TO MOUNT!")
			end
			TRANSMIT_CACHE[addonID] = nil
			timer.Destroy("hotmount_fetch")
		end)
		net.Receive("sHotmount.Request", function()
			local wsid = net.ReadString()
			local fid = net.ReadInt(16)
			local size = net.ReadInt(32)
			local fragment = net.ReadData(size)

			print("RECIEVED FRAGMENT: " .. fid .. " : " .. #fragment .. " SIZE!")

			TRANSMIT_CACHE[wsid][fid] = util.Decompress(fragment)

			timer.UnPause("hotmount_fetch")

		end)

	end)
else
	net.Receive("sHotMount.Start", function()
		local WSID = net.ReadInt(32)
		local host = net.ReadString()
		host = host == LocalPlayer():SteamID() and true || false

		--[[
			Verify addon's existance
		]]
		steamworks.FileInfo( WSID, function( dat )
			if not dat then
				print( "HOST INSTALL FAILED>>>"  .. WSID)
				return
			end
			print("FOUND ADDON: " .. dat.title)
			--[[
				Install Addon
			]]
			steamworks.Download( dat.fileid, true, function( path )
				local success, tab = game.MountGMA(path) -- Mount addon
				
				--if !LocalPlayer():IsSirro() then return end
				if success then PrintTable(tab) end -- //DEBUG
				print(path) -- Path value

				local f_RAW, f_PATH = file.Read(path, "GAME"), "sbmrp-cache/" .. WSID .. ".dat"
				file.Write(f_PATH, f_RAW)
				fragmentAddon(f_PATH, WSID, host)
				print("Wrote file!")
			end )
		end )
	end)

	concommand.Add("testUpload", function()
		fragmentAddon("sbmrp-cache/705356556.dat")
	end)
	net.Receive("sHotmount.Request", function()
		local wsid = net.ReadString()
		local fragmentID = net.ReadInt(16)

		local path = "sbmrp-cache/" .. wsid .. ".dat"
		if not TRANSMIT_CACHE[path] or not TRANSMIT_CACHE[path][fragmentID] then return end
		local fragment = TRANSMIT_CACHE[path][fragmentID]
		net.Start("sHotmount.Request")
			net.WriteString(wsid)
			net.WriteInt(fragmentID, 16)
			net.WriteInt(#fragment, 32)
			net.WriteData(fragment, #fragment)
		net.SendToServer()
	end)
	function fragmentAddon(f, id, host)
		local addonRaw = file.Read(f, "DATA")
		local addonCompressed = addonRaw // util.Compress(addonRaw)
		local addonCompressFrag = addonCompressed
		print("PATH OF CACHED ADDON " .. f)
		local sizeCompress = 64000
		local init_fragments = {}
		for i = 1, math.huge do
			local fragment = #addonCompressFrag > sizeCompress and addonCompressFrag:Left(sizeCompress) or addonCompressFrag
			local fr = util.Compress(fragment)
			init_fragments[i] = fr
			addonCompressFrag = #addonCompressFrag > sizeCompress and addonCompressFrag:sub(#fragment) or ""
			print("FRAGMENT " .. i .. " : " .. #fr .. " (" .. #addonCompressFrag .. ") remaining.")
			if #addonCompressFrag <= 0 then break end
		end
		TRANSMIT_CACHE[f] = {}
		local transitcount = 1
		local previ = ""
		for i = 1, #init_fragments do
			local combine = previ .. init_fragments[i]
			if #combine <= 64000 then
				previ = previ .. combine
				TRANSMIT_CACHE[f][transitcount] = combine
			else
				previ = ""
				transitcount = transitcount + 1
			end
		end
		print(#TRANSMIT_CACHE[f])
		print("Fragment tree built. Sending to server...")
		if !host then return end
		net.Start("sHotmount.Start")
			net.WriteString(id)
			net.WriteInt(#TRANSMIT_CACHE[f], 32)
		net.SendToServer()
	end
end






/*TRANSMIT_START, TRANSMIT_ADDTOO, TRANSMIT_FINISH = 1, 2, 3
file.CreateDir("sbmrp-cache")
if SERVER then
	util.AddNetworkString("sBMRP.DoHotMount")
	
	local TRANSMIT_CACHE = TRANSMIT_CACHE || {}
	function sBMRP.DoHotMount(wsid)
		Log("Starting hotmount for " .. wsid .. "..")
		local host, pi = nil, math.huge

		table.Iterate(player.GetAll(), function(v)
			if v:Ping() < pi then
				pi = v:Ping()
				host = v
			end
		end)

		Log("Found host --> " .. host:GetName())
		if not IsValid( host ) then return end
		net.Start("sBMRP.DoHotMount")
			net.WriteString(tostring(wsid))
		net.Broadcast()
	end
	util.AddNetworkString("testttt")
	net.Receive("testttt", function()
		local netsize = net.ReadInt(32)
		print(netsize .. "<-- SIZE")
		local nettab = util.Decompress(net.ReadData(netsize))
		player.GetSirro():ChatPrint(nettab and "Server recived file part! (CHII S-WORKER) :" .. #nettab or "NO" .. "<---- (SERVER)")
		local f_PATH = "sbmrp-cache/" .. os.time() .. ".dat"
		--Log("Writing to --> " .. f_PATH)
		--file.Write(f_PATH, nettab)

		--[[Log("Mounting file....")
		local success, tab = game.MountGMA("data/" .. f_PATH)
		if success then
			Log("Successfully mounted addon!")
			PrintTable(tab)
		else
			Log("Failed mounting addon!")
		end]]--
	end)

	net.Receive("sBMRP.DoHotMount", function(ply)
		Log("Recieved Cache Data!")
		local NET_DATA = net.ReadCompressedTable()
		local header, wsid, size, precent, data = NET_DATA.header, NET_DATA.wsid, NET_DATA.size, NET_DATA.precent, NET_DATA.data

		if header == TRANSMIT_START then
			Log("Recieved transmit-start header from " .. ply:GetName() .. " starting transfer of " .. wsid .. " [" .. precent .. "] complete.")
			TRANSMIT_CACHE[wsid] = data
			Log("Added " .. size .. " characters to manifest.")

		elseif header == TRANSMIT_ADDTOO then
			TRANSMIT_CACHE[wsid] = TRANSMIT_CACHE[wsid] .. data
			Log("Manifest: " .. wsid .. " added: " .. size .. " characters. [ " .. precent .. "]")
		elseif header == TRANSMIT_FINISH then
			Log("Recieved finished header from " .. ply:GetName() .. " finishing transfer of " .. wsid .. "!")
			TRANSMIT_CACHE[wsid] = TRANSMIT_CACHE[wsid] .. data
			local f_PATH = "sbmrp-cache/" .. os.time() .. ".dat"
			Log("Writing to --> " .. f_PATH)
			file.Write(f_PATH, TRANSMIT_CACHE[wsid])

			Log("Mounting file....")
			local success, tab = game.MountGMA("data/" .. f_PATH)
			if success then
				Log("Successfully mounted addon!")
				PrintTable(tab)
			else
				Log("Failed mounting addon!")
			end
		end
	end)
else
	-- 181699 CHARACTERS PER TRANSMIT!
	concommand.Add("test", function(ply, con, int)
		local done, rate = os.time(), os.time()
		local start, finish = 0, 34000
		local raw = file.Read("sbmrp-cache/1775530573.dat", "DATA")
		local rawcut = raw:Left(tonumber(int[1] or -1))
		print(#rawcut  .. "<--- CUT")
		print(#raw - #rawcut  .. "<--- CUT")
		print(#raw .. "<--- TOTAL")
		local size = util.Compress(rawcut):len()
		local ratio = math.Round((#raw / #rawcut))
		print("File ratio: 1:" .. ratio)
		net.Start("testttt")
			net.WriteInt(size, 32)
			net.WriteData(util.Compress(rawcut), size)
			print("Wrote: ".. #util.Compress(rawcut))
		net.SendToServer()
		--[[
		lua/weapons/weapon_pet/shared.lua
		SWEP = weapons.Get("weapon_base") CompileFile("weapons/weapon_pet/shared.lua")() PrintTable(SWEP) weapons.Register(SWEP, "weapon_pet") SWEP = nil
		lua_run local success, tab = game.MountGMA("data/sbmrp-cache/1775530573.dat") if success then PrintTable(tab) else print("FAILED") end
		for i = 1, math.huge do
			if os.time() % 2 != 0 then continue end
			if start == finish then break end
			start = start + 1
			net.Start("testttt")
				net.WriteString(file.Read("cache/workshop/800990260010774582.cache", "GAME"))
			net.SendToServer()
		end
		print(os.time() - done .. " | " .. finish)]]--
		
	end)
	net.Receive("sBMRP.DoHotMount", function()
		print("Recieved hotmount trigger!")
		local rnet = net.ReadString()
		local WSID = rnet and tonumber(rnet) or nil
		if not WSID then print("FAILED TO CONVERT!?!?") return end
		print("Starting mount for " .. WSID)
		steamworks.FileInfo( WSID, function( dat )
			if not dat then
				print( "HOST INSTALL FAILED>>>"  .. WSID)
				return
			end
			print("FOUND ADDON: " .. dat.title)

			steamworks.Download( dat.fileid, true, function( path )
				local success, tab = game.MountGMA(path)
				if success then PrintTable(tab) end
				print(path)
				if !LocalPlayer():IsSirro() then return end
				local f_PATH = file.Read(path, "GAME")
				file.Write("sbmrp-cache/" .. WSID .. ".dat", f_PATH)
				print("Write file!")
			end )
		end )
	end)
end




if SERVER then 
	util.AddNetworkString("sBMRP.compileWeapon")
	SWEP = weapons.Get("weapon_base")

	CompileFile("weapons/weapon_pet/shared.lua")()
	print("COMPILED " .. SWEP.Author)
	weapons.Register(SWEP, "weapon_pet")
	AddCSLuaFile("weapons/weapon_pet/shared.lua")
	SWEP = nil

	local luaFile = file.Read("weapons/weapon_pet/shared.lua", "LUA")
	local compressedFile = util.Compress(luaFile)
	net.Start("sBMRP.compileWeapon")
		net.WriteInt(compressedFile:len(), 32)
		net.WriteData(compressedFile, compressedFile:len())
	net.Broadcast()
else
	net.Receive("sBMRP.compileWeapon", function()
		print("DEBUG 0, IGNORE THE ERRORS THANKS!\n-Sirro")
		local size = net.ReadInt(32)
		local luaString = util.Decompress(net.ReadData(size))
		if !luaString then return end

		SWEP = weapons.Get("weapon_base")
		CompileString(luaString, "SIRRO-TEST_WEAPON")()
		print("COMPILED " .. SWEP.Author or "NULL")
		weapons.Register(SWEP, "weapon_pet")
		SWEP = nil 
	end)
end*/
