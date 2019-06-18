if SERVER then
	--[[-------------------------------------------------------------------------
	Varibles
	---------------------------------------------------------------------------]]
	util.AddNetworkString("shotloader")
	shotloader =  shotloader || {}
	shotloader.hotloadlist = shotloader.hotloadlist || {}
	shotloader.CollectionsToParse = shotloader.CollectionsToParse || {}
	--[[-------------------------------------------------------------------------
	Functions
	---------------------------------------------------------------------------]]

	function resource.HotLoadAddon(id)
		if not id then error("No addon ID provided!") return end
		shotloader.hotloadlist[id] = true
	end
	function resource.HotLoadCollection(id)
		if not id then error("No collection ID provided!") return end
		shotloader.CollectionsToParse[id] = true
		if shotloader.runtime then
			FetchCollections() -- Lua refreash support?
		end
	end
	net.Receive("shotloader", function(len)
		local ply = net.ReadEntity()
		net.Start("shotloader")
			net.WriteTable(shotloader.hotloadlist)
		net.Send(ply)
	end)


	function CollectionIDToAddons( html, CollectionURL )
		local rawcol = {}

		local addons = string.gmatch(html, "https%://steamcommunity%.com/sharedfiles/filedetails/%?id=(%d+)",1)

		local collectionid = string.match(CollectionURL, "(%d+)")

		for addon in addons do
			if(addon==collectionid) then continue end

			rawcol[addon] = true
		end

		for addons, _ in pairs(rawcol) do
			shotloader.hotloadlist[ addons ] = true
		end
		print("[sHotloader]: mounted " .. CollectionURL .. "!")
	end


	function FetchCollections()
		for k,v in pairs(shotloader.CollectionsToParse) do
			http.Fetch("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. k, function(body)
				CollectionIDToAddons(body, "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. k)
			end, function(err)
				ErrorNoHalt("[sHotloader]: Failed fetching workshop collection -->" .. err .. " \n")
			end)	
		end	
	end

	--[[-------------------------------------------------------------------------
	Initalization
	---------------------------------------------------------------------------]]

	timer.Simple(1, function()
		if not shotloader.CollectionsToParse == 0 then
			pcall(FetchCollections())	
		end
		shotloader.runtime = true
	end)


	hook.Add("PlayerSay", "shotloader_remount", function(ply,text)
		if IsValid(ply) and text:lower() == "/remount" then
		net.Start("shotloader")
			net.WriteTable(shotloader.hotloadlist)
		net.Send(ply)			
		end
	end)
end


if CLIENT then
	print('Initalizing sHotloader Cl')
	local toDownload = {}
	local currentAddon = 1

	local function DownloadSteamworksAddon( id, callback )
		if not id then return end
		steamworks.FileInfo( id, function( dat )
			if not dat then
				print( "Couldn't download or addon is invalid! Skipping..." )
				callback()
				return
			end

			notification.AddProgress( "wsdl_notify_" .. id, "Loading " .. dat.title .. " " .. #table.GetKeys( toDownload ) - currentAddon .. " addons left." )

			steamworks.Download( dat.fileid, true, function( path )
					print( path )
					pcall(game.MountGMA( path ))
				notification.Kill( "wsdl_notify_" .. id )
				callback()
			end )
		end )
	end

	local function DownloadLoop()
		currentAddon = currentAddon + 1
		print( currentAddon, #table.GetKeys( toDownload ), currentAddon < #toDownload )

		if currentAddon <= #table.GetKeys( toDownload ) then
			DownloadSteamworksAddon( table.GetKeys( toDownload )[ currentAddon ], DownloadLoop )
		else			isdone = true
			chat.AddText( "--------------------------------\nWorkshop download done!\nType /remount to re-run this diagnostic!\n--------------------------------" )
		end
	end


	net.Receive("shotloader",function (msglen)

	    local addonlist = net.ReadTable()
		for k,v in pairs(addonlist) do
			toDownload[ k ] = true
			print("Mounting " .. #toDownload .. " addons.")
		end
		timer.Simple(10, function()			
			chat.AddText("----------------------------------------------------------------\nPreparing to mount/download addons in 10 seconds.\nThis may lag for a few minutes if you are a new player.\n----------------------------------------------------------------")
		end)

		timer.Simple( 20, function() -- Now we download the addons
			xpcall(DownloadSteamworksAddon( table.GetKeys( toDownload )[ currentAddon ], DownloadLoop ), retry)
		end )
	end)


	hook.Add( "InitPostEntity", "WDSL_Start", function()
		net.Start("shotloader")
			net.WriteEntity(LocalPlayer())
		net.SendToServer()
	end)

end