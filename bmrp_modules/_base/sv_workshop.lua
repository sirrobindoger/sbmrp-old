
--RunConsoleCommand("sv_setsteamaccount","2F3DA84B9166661A163C4CBD833EA260")



if file.Exists("workshop.txt", "DATA") then
	local addons = util.JSONToTable(file.Read("workshop.txt", "DATA"))

	for k,addonid in pairs(addons) do
		resource.AddWorkshop(addonid)
	end
	timer.Simple(0, function()
		print("[WorkshopDL]: Added " .. #addons .. " to the workshop download!")
	end)
else
	timer.Simple(0, function()
		print("[WorkshopDL]: Critical error, could not find the workshop list! Please run 'lua_run UpdateWorkshop()' to fix this...")
	end)
end

function UpdateWorkshop()
	if file.Exists("workshop.txt", "DATA") then print("Deleting old workshop list...") file.Delete("workshop.txt") end


		local addonum = 0
		function ParseCollectionHTML( html )

		    local nicelines = {}

		    local links = string.gmatch(html, "https%://steamcommunity%.com/sharedfiles/filedetails/%?id=(%d+)",1)

		    nodups = {}

		    local colid = string.match(CollectionURL, "(%d+)")

		    for link in links do
		        if(link==colid) then continue end

		        nodups[link] = true
		    end

		    file.Write("workshop.txt", util.TableToJSON(table.GetKeys(nodups)))
		    print("[WorkshopDL]: Updated workshop list!")
		end

	timer.Simple(1, function()
		CollectionURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. 1509877966
		print("[WorkshopDL]: Fetching workshop collection from: " .. CollectionURL)
		http.Fetch(CollectionURL, function(body)
		    ParseCollectionHTML(body)
		end, function(err)
		    ErrorNoHalt("[WorkshopDL]: Failed fetching workshop collection\n")
		    ErrorNoHalt(err)
		end)
	end)
end
concommand.Add("updateworkshop", function(ply)
	if IsValid(ply) then return end
	UpdateWorkshop()
end)