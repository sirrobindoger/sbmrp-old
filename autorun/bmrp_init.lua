--[[-------------------------------------------------------------------------
sBMRP -- Coded by Sirro, Fay and Creed et al.

---------------------------------------------------------------------------]]
sBMRP = sBMRP || {}
sBMRP.LoadedModules = sBMRP.LoadedModules || {}
sBMRP.version = "2.1"

--[[-------------------------------------------------------------------------
Localazing varibles
-- localizing global functions/tables is an encouraged practice that improves code efficiency,
-- since accessing a local value is considerably faster than a global value
---------------------------------------------------------------------------]]
local net = net
local util = util
local concommand = concommand
local pairs = pairs
local table = table
local ents = ents
local hook = hook
local math = math -- MATH IS MATH
local print = print
local string = string
local IsValid = IsValid
local type = type
local os = os
local timer = timer
local RunConsoleCommand = RunConsoleCommand



--[[-------------------------------------------------------------------------
Module loading
---------------------------------------------------------------------------]]

hook.Add("Initialize", "bmrp_core_init", function() -- Loads this code after DarkRP loads.
	if SERVER then
		print("[----------------] sBMRP [----------------]")
		local _, libraries = file.Find( "bmrp_modules/*", "LUA" )
		for _, lib in pairs( libraries ) do

			---------------- Server ----------------
			for _, filename in pairs( file.Find( "bmrp_modules/" .. lib .. "/sv_*.lua", "LUA" ) ) do
				include( "bmrp_modules/" .. lib .. "/" .. filename )
			end

			---------------- Shared ----------------
			for _, filename in pairs( file.Find( "bmrp_modules/" .. lib .. "/sh_*.lua", "LUA" ) ) do
				include( "bmrp_modules/" .. lib .. "/" .. filename )
				AddCSLuaFile( "bmrp_modules/" .. lib .. "/" .. filename )
			end
			
			---------------- Client ----------------
			for _, filename in pairs( file.Find( "bmrp_modules/" .. lib .. "/cl_*.lua", "LUA" ) ) do
				AddCSLuaFile( "bmrp_modules/" .. lib .. "/" .. filename )
			end
			sBMRP.LoadedModules[lib] = true
			print("[] Init Module. " .. lib)
		end	
		print("[----------------] sBMRP [----------------]")
	end


	if CLIENT then
		local _, libraries = file.Find( "bmrp_modules/*", "LUA" )
		for _, lib in pairs( libraries ) do
			---------------- Shared ----------------
			for _, filename in pairs( file.Find( "bmrp_modules/" .. lib .. "/sh_*.lua", "LUA" ) ) do
				include( "bmrp_modules/" .. lib .. "/" .. filename )
			end
			---------------- Client ----------------
			for _, filename in pairs( file.Find( "bmrp_modules/" .. lib .. "/cl_*.lua", "LUA" ) ) do
				include( "bmrp_modules/" .. lib .. "/" .. filename ) 
			end
			sBMRP.LoadedModules[lib] = true
		end
		print("[----------------] CL sBMRP INITALIZED! [----------------]")
	end
end)