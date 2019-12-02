local unauthorized_message = {
	title = "**Unauthorized**",
	color = 16711689,
	footer = {
		text = "sCON"
	}
}

local function sCON_ErrorMSG(reason, messageClass)
	return {
		title = "**Error**",
		description = reason,
		color = 16711689,
		timestamp = messageClass.timestamp,
		footer = {
			text = "sCON"
		},
	}
end

local timeToStr = Utime.timeToStr

--[[-------------------------------------------------------------------------
Hello world test command
---------------------------------------------------------------------------]]
sCON:RegisterCommand("ping", function(message)
	local author = message:GetAuthor()
	message:ReturnResponse("Hello " .. author:Nick() .. "!")
end)

--[[-------------------------------------------------------------------------
gmodstore scanner
---------------------------------------------------------------------------]]
local GM_JOBS = {"NULL"}
local function getGmodStore(int)
	http.Fetch("https://www.gmodstore.com/jobmarket/jobs/browse?sortby=new&page=" .. int, function(body)
		local e = body:Split("\n")
		GM_JOBS = {}
		for k,v in pairs(e) do
			if v:find("placement") then
				table.insert(GM_JOBS, v:sub(85):Replace('"', ""):Replace(">", ""))
			end
		end
	end)
end

sCON:RegisterCommand("gm_jobs", function(message)
	local page = message:Args()[1] or 1
	if message:GetAuthor():HasRole("Owner") then
		getGmodStore(page)
		timer.Simple(3, function()
			message:ReturnResponse({
				title = "**Gmodstore jobs** (Page " .. page .. ")",
				url = "https://www.gmodstore.com/jobmarket/jobs/browse?sortby=new&page=" .. page,
				description = table.concat(GM_JOBS, "\n"),
				color = 8781827, -- color stays the same
			})
		end)
	end
end)

--[[-------------------------------------------------------------------------
Find command
---------------------------------------------------------------------------]]

sCON:RegisterCommand("find", function(message)
	local targ = message:Args()[1]
	local f_title = "" local f_description = "" local f_fields = {}

	if not targ:find("<@") and not tonumber(targ) then -- mention to discord object. Will be parsed differently
		local playerIG = sCON:findPlayer(targ)
			if playerIG then -- player is currently in game!
				--[[-------------------------------------------------------------------------]]
				f_title = "In-Game: :white_check_mark:"
				f_description = string.format("**%s/%s**", playerIG:Nick(), playerIG:SteamID())
				if sCON:IsRegistered(playerIG:SteamID()) then
					f_description = string.format("**%s/%s/<@%s>**", playerIG:Nick(), playerIG:SteamID(), sCON:GetFromDB(playerIG:SteamID()))
				end
				f_fields = {
						{
							name = "**SESSION TIME:**:",
							value = timeToStr(playerIG:GetUTimeSessionTime())
						},
						{
							name = "**TOTAL TIME:**:",
							value = timeToStr(playerIG:GetUTimeTotalTime())
						},
						{
							name = "**JOB:**",
							value = playerIG:getJobTable().name
						},
						{
							name = "**Location**",
							value = GetLocation(playerIG)
						}
				}
			elseif string.starts(targ, "STEAM_") then -- entered steamid? Well, lets check the offline database if they ain't in game.				
				if sCON:RecordOnPlayer(targ) then -- steamid has joined before!!
					print("WTF!")
					DarkRP.offlinePlayerData(targ, function(body) rpname = body[1].rpname end) -- searching DarkRP for the player
					if not rpname then rpname = message.author.id end
					local row = sql.QueryRow( "SELECT totaltime, lastvisit FROM utime WHERE player = " .. util.CRC( "gm_" .. targ .. "_gm" ) .. ";" )
					local lastvist = os.date( "%c", row.lastvisit )
					f_title = "In-Game: :x:"
					f_description = string.format("**%s/%s**", rpname, targ)
					if sCON:IsRegistered(targ) then -- hey, their on discord too!
						f_description = string.format("**%s/%s/<@%s>**", rpname, targ, sCON:GetFromDB(targ))
					end
					f_fields = {
						{
							name = "**Last visit**",
							value = lastvist
						}
					}
				else
					f_title = "**Find Error**"
					f_description = "Couldn't find player in server database!"
				end
			else
				f_title = "**Find Error**"
				f_description = "Couldn't find player with name given."		
			end		
	else
		local dID = string.Replace(targ,"<@",""):Replace(">",""):Replace("!", "")
		if sCON:IsRegistered(_,dID) then
			local member = sCON:GetFromDB(_,dID)
			DarkRP.offlinePlayerData(member, function(body) rpname = body and body[1] and body[1].rpname or "NULL" end)
			if sCON:findPlayer(member) then
				local player = sCON:findPlayer(member)
				--[[-------------------------------------------------------------------------]]
				f_title = "In-Game: :white_check_mark:"
				f_description = string.format("**%s/%s/<@%s>**", player:Nick(), player:SteamID(), dID)
				f_fields = {
					{
						name = "**SESSION TIME:**:",
						value = timeToStr(player:GetUTimeSessionTime())
					},
					{
						name = "**TOTAL TIME:**:",
						value = timeToStr(player:GetUTimeTotalTime())
					},
					{
						name = [[**JOB**]],
						value = player:getJobTable().name
					},
					{
						name = "**Location**",
						value = GetLocation(player)
					}
				}
			else
				if not rpname then
					rpname = message.author.id
				end
				local row = sql.QueryRow( "SELECT totaltime, lastvisit FROM utime WHERE player = " .. util.CRC( "gm_" .. member .. "_gm" ) .. ";" )
				local lastvist = os.date( "%c", row.lastvisit )
				f_title = "In-Game: :x:"
				f_description = string.format("**%s/%s/<@%s>**", rpname, member, dID)
				f_fields = {
					{
						name = "**Last visit**",
						value = lastvist
					}

				}				
			end
		else
			f_title = "**Find Error**"
			f_description = "That discord user is not registered into the Database."
		end
	end
	if f_fields then
		message:ReturnResponse({
			title = f_title,
			description = f_description,
			color = 8781827, -- color stays the same
			timestamp = message.timestamp, -- timestamp/footer never change
			footer = {
				text = "sCON"
			},
			fields = f_fields,
		})
	else
		message:ReturnResponse({
			title = f_title,
			description = f_description,
			color = 8781827, -- color stays the same
			timestamp = message.timestamp, -- timestamp/footer never change
			footer = {
				text = "sCON"
			},
		})
	end
end)

--[[-------------------------------------------------------------------------
Status
---------------------------------------------------------------------------]]

sCON:RegisterCommand("status", function(message)
	local staffcount = 0
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			staffcount = staffcount + 1
		end
	end
	local uptime = string.format("%.2d:%.2d:%.2d",
		math.floor(CurTime() / 60 / 60), -- hours
		math.floor(CurTime() / 60 % 60), -- minutes
		math.floor(CurTime() % 60) -- seconds
	)
	local players = {}
	for _, ply in next, player.GetAll() do
		players[#players + 1] = ply:Nick()
	end
	players = table.concat(players, ", ")
	message:ReturnResponse({
	    title = GetHostName(),
	    description = "**Uptime:** `" .. uptime .. "` - **Join**: steam://connect/" .. game.GetIPAddress() .. "/",
	    timestamp = message.timestamp,
	    color = 0x3295C7,
	    footer = {
	        text = "sCON"
	    },
		fields = {
			{
				name = "Players: " .. player.GetCount() .. " | " .. staffcount .. " Staff",
				value = players:Trim() ~= "" and [[```]] .. players .. [[```]] or "Server is empty."
			}
		},
	})
end)

--[[-------------------------------------------------------------------------
Register Command
---------------------------------------------------------------------------]]
local function formatsteamid(steamid) return util.SteamIDFrom64(util.SteamIDTo64(string.Replace(steamid, "👍", ":1:"))) end
sCON:RegisterCommand("register", function(message)
	local steamid = message:Args()[1]
	if not steamid or not string.starts(steamid, "STEAM_") then
		message:ReturnResponse({
			title = "**Error:**",
			description = "You did not enter a SteamID!",
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},			
		})
	elseif message:GetAuthor():IsRegistered() then
		local regissteamid = message:GetAuthor():SteamID()
		DarkRP.offlinePlayerData(regissteamid, function(body) rpname = body[1].rpname end)
		if not rpname then
			local rpname = message.author.name
		end
		message:ReturnResponse({
			title = "**Error:**",
			description = "You are already registered!\nSTEAMID: " .. regissteamid .. " | NAME: " .. rpname,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})
	elseif sCON:RecordOnPlayer(formatsteamid(steamid)) then
		if not sCON:IsRegistered(formatsteamid(steamid)) then
			if ULib.bans[steamid] then
				message:ReturnResponse({
					title = "**Warning:**",
					description = "Registration completed.\nBut you are banned on the server.\nPlease appeal in #ban-appeals before getting access to the discord.",
					timestamp = message.timestamp,
					footer = {
						text = "sCON"
					},
				})
				message:GetAuthor():EditRole("565177336807424000")
				sCON:InsertIntoDB(formatsteamid(steamid), message.author.id)
				return
			end
			sCON:InsertIntoDB(formatsteamid(steamid), message:GetAuthor().user.id)
			DarkRP.offlinePlayerData(steamid, function(body) rpname = body[1].rpname end)
			if not rpname then
				rpname = message.author.name
			end
			message:GetAuthor():EditRole("562464453812027412", "DELETE")
			message:GetAuthor():EditRole("562464023925227520")
			message:ReturnResponse({
				title = "**Verification Successfull**",
				description = string.format("Welcome, %s", rpname),
				timestamp = message.timestamp,
				color = 2031360,
				footer = {
				text = "sCON"
				}
			})
		else
			alreadyuser = sCON.Guild:GetMember(formatsteamid(steamid))
			message:ReturnResponse({
				title = "**Error**",
				description = string.format("**The current steamid is already in use by <@%s>, if this is not you please contact staff immediately.**", alreadyuser.user.id),
				color = 16711689,
				timestamp = message.timestamp,
				footer = {
					text = "sCON"
				},
			})
		end
	else
		message:ReturnResponse({
			title = "**Error**",
			description = string.format("**Error:** no record found on SteamID entered, make sure you have joined the Gmod server at least once.", message.channel_id),
			color = 16711689,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})		
	end
end)


sCON:RegisterCommand("unregister", function(message)
	if not message:GetAuthor():HasRole("Staff") then message:ReturnResponse("Unauthorized") end
	local targetsteamid = message:Args()[1]
	if string.starts(targetsteamid, "STEAM_") then
		print("SteamID!")
		local steamid = formatsteamid(targetsteamid)
		if not sCON:IsRegistered(steamid) then
			message:ReturnResponse({
				title = "**Error:**",
				description = "The steamid is not registered in the Database!",
				timestamp = message.timestamp,
				footer = {
					text = "sCON"
				},
			})
		else
			local user sCON:GetFromDB(steamid)
			sCON:RemoveFromDB(steamid)
			message:ReturnResponse({
				description = string.format("**Successfully unregistered <@%s>/`%s` from the database.**", user, steamid),
				timestamp = message.timestamp,
				color = 16711689,
				footer = {
				text = "sCON"
				}
			})			
		end
	elseif string.starts(targetsteamid, "<@") then
		local dID = string.Replace(targetsteamid,"<@!",""):Replace(">",""):Replace("<@", "")
		if sCON:IsRegistered(_,dID) then
			local member = sCON:GetFromDB(_,dID)
			sCON:RemoveFromDB(_,dID)
			message:ReturnResponse({
				description = string.format("**Successfully unregistered <@%s>/`%s` from the database.**", dID, member),
				timestamp = message.timestamp,
				color = 16711689,
				footer = {
				text = "sCON"
				}
			})	
		end
	end
end)

sCON:RegisterCommand("fregister", function(message)
	if not message:GetAuthor():HasRole("Staff") then message:ReturnResponse("Unauthorized") return end

	local steamid = message:Args()[1]
	local discordid = message:Args()[2]
	if not steamid:find("STEAM_") or not tonumber(discordid) then message:ReturnResponse("Incorrect syntax!\n```/register STEAMID DISCORDID```") return end
	if sCON:IsRegistered(steamid) or sCON:IsRegistered(_,discordid) then message:ReturnResponse("User is registered already.") return end
	
	sCON:InsertIntoDB(formatsteamid(steamid), discordid)
	DarkRP.offlinePlayerData(steamid, function(body) pcall(function() rpname = body[1].rpname end)end)
	if not rpname then
		rpname = message.author.name
	end
	sCON.Guild:GetMember(discordid):EditRole("562464453812027412", "DELETE")
	sCON.Guild:GetMember(discordid):EditRole("562464023925227520")
	message:ReturnResponse({
		title = "**Verification Successfull**",
		description = string.format("Welcome, %s", rpname),
		timestamp = message.timestamp,
		color = 2031360,
		footer = {
		text = "sCON"
		}
	})
end)

--[[-------------------------------------------------------------------------
Ban/Unban commands
---------------------------------------------------------------------------]]

sCON:RegisterCommand("ban", function(message)
	if not message:GetAuthor():HasRole("Staff") then message:ReturnResponse(unauthorized_message) return end
	local target = message:Args()[1]
	local time = ULib.stringTimeToMinutes(message:Args()[2]) or "0"
	local reason = message:Args()[3] and table.concat(message:Args(), " "):Replace(target, ""):Replace(time, "") or "You have been banned due to reports on our discord. Please go to the discord if you wish to resolve this."
	local playerIG = sCON:findPlayer(target)
	if playerIG then -- player is in game
		ULib.ban(playerIG, time, reason)
		message:ReturnResponse({
			title = "**Ban successful:**",
			description = string.format("``%s/%s`` was banned by ``%s`` for ``%s``, with reason: ``%s``", playerIG:GetName(),playerIG:SteamID(),message:GetAuthor():Nick(),time, reason ),
			color = 2031360,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})
	elseif string.starts(target,"STEAM_") and sCON:RecordOnPlayer(formatsteamid(target)) then
		DarkRP.offlinePlayerData(formatsteamid(target), function(body) pcall(function() rpname = body[1].rpname end)end)
		if not rpname then rpname = "Unknown" end
		message:ReturnResponse({
			title = "**Ban successful:**",
			description = string.format("``%s/%s`` was banned by ``%s`` for ``%s``, with reason: ``%s``", rpname,target,message:GetAuthor():Nick(),time, reason ),
			color = 2031360,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})		
		RunConsoleCommand("ulx", "banid", formatsteamid(target), time, reason)
	elseif string.starts(target, "<@") or tonumber(target) then
		if sCON:IsRegistered(_, target:Replace(">",""):Replace("<@", ""):Replace("<@!", "")) then
			local steamid = sCON.Guild:GetMember(target:Replace(">",""):Replace("<@", ""):Replace("<@!", "")):SteamID()
			DarkRP.offlinePlayerData(formatsteamid(steamid), function(body) pcall(function() rpname = body[1].rpname end)end)
			if not rpname then rpname = "Unknown" end			
			message:ReturnResponse({
				title = "**Ban successful:**",
				description = string.format("``%s/%s`` was banned by ``%s`` for ``%s``, with reason: ``%s``", rpname,steamid,message:GetAuthor():Nick(),time, reason ),
				color = 2031360,
				timestamp = message.timestamp,
				footer = {
					text = "sCON"
				},
			})		
			RunConsoleCommand("ulx", "banid", formatsteamid(steamid), time, reason)
		end
	else
		message:ReturnResponse({
			title = "**Error**",
			description = "Could not find player on online or offline databases.",
			color = 16711689,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})
	end
end)

sCON:RegisterCommand("msg", function(message)
	local rtarg = message:Args()[1]
	local targ = sCON:findPlayer(rtarg)
	local msg = table.concat(message:Args(), " "):Replace(rtarg, ""):Trim() || "Something broke"
	local author = message:GetAuthor():Nick()
	if targ then
		targ:AddText(Color(225, 25, 255), "[Discord - PM] " .. author .. " to you: ", Color(225, 255, 255), msg)
		message:ReturnResponse({
			title = author .. " to " .. targ:Nick(),
			description =  "```" .. msg .. "```",
			color = 2031360,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})
	else
		message:ReturnResponse({
			title = "**Error**",
			description = "Could not find player.",
			color = 16711689,
			timestamp = message.timestamp,
			footer = {
				text = "sCON"
			},
		})		
	end

end)

sCON:RegisterCommand("unban", function(message)
	if not message:GetAuthor():HasRole("Staff") then message:ReturnResponse(unauthorized_message) return end
	local target = message:Args()[1]

	if string.starts(target,"STEAM_") then
		local steamid = formatsteamid(target)
		if !ULib.bans[steamid] then
			message:ReturnResponse(sCON_ErrorMSG("SteamID entered found no banned players.", message))
		else

			local name = ULib.bans[steamid].name or "Unknown"
			
			RunConsoleCommand("ulx", "unban", steamid)

			message:ReturnResponse({
				description = "``" .. name .. "/" .. steamid .. "`` **was sucessfully unbanned.**",
				timestamp = message.timestamp,
				color = 2031360,
				footer = {
				text = "sCON"
				}
			})
		end
	elseif string.starts(target, "<@") or tonumber(target) then
		local dID = target:Replace(">",""):Replace("<@", ""):Replace("<@!", "")
		local member = sCON.Guild:GetMember(dID)
		if member and member:IsRegistered() then
			local steamid = member:SteamID()
			local name = member:Nick()

			if !ULib.bans[steamid] then
				message:ReturnResponse(sCON_ErrorMSG(name .. "/" .. steamid .. " is not banned!", message))
				return
			end
			message:ReturnResponse({
				description = "``" .. name .. "/" .. steamid .. "`` **was sucessfully unbanned.**",
				timestamp = message.timestamp,
				color = 2031360,
				footer = {
				text = "sCON"
				}
			})
			RunConsoleCommand("ulx", "unban", steamid)
		end
	else
		message:ReturnResponse(sCON_ErrorMSG("Invalid syntax. (SteamID or Discord Object)", message))
	end
end)

--[[-------------------------------------------------------------------------
View
---------------------------------------------------------------------------]]

sCON:RegisterCommand("view", function(message)
	local target = message:Args()[1] 

	if not sCON:findPlayer(message:Args()[1]) then 
		message:ReturnResponse(sCON_ErrorMSG("Couldn't find player! (Use their name or their SteamID!)", message))
		return
	end
	
	local ply = sCON:findPlayer(target)

	message:ReturnResponse({
		title = "**Screenshotting " .. ply:GetName() .. "/" .. ply:SteamID() .."**",
		color = 2031360,
		timestamp = message.timestamp,
		footer = {
		text = "sCON"
		}		
	})
	ScreenshotPlayer(ply, message.channel_id)

end)

--[[-------------------------------------------------------------------------
Props
---------------------------------------------------------------------------]]
sCON:RegisterCommand("props", function(message)
	message:ReturnResponse({
		description = "**Prop Count:** ```" .. getproptable() .. "```",
		color = 3046486,
		timestamp = message.timestamp,
		footer = {
			text = "sCON"
		},
	})
end)


--[[-------------------------------------------------------------------------
Commmands
---------------------------------------------------------------------------]]
sCON:RegisterCommand("commands", function(message)
	message:ReturnResponse({
		title = "List of registered commands:",
		description = "```".. table.concat(table.GetKeys(sCON.Commands), ", ") .. "```",
		timestamp = message.timestamp,
		footer = {
		text = "sCON"
		}
	})
end)