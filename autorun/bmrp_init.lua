--[[-------------------------------------------------------------------------
sBMRP -- Coded by Sirro, Fay and Creed et al.

---------------------------------------------------------------------------]]
sBMRP = sBMRP || {}
sBMRP.LoadedModules = sBMRP.LoadedModules || {}
sBMRP.version = "2.1"

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