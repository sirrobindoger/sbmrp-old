if SERVER then
	util.AddNetworkString("sBMRP.Quests")
	local ply = FindMetaTable("Player")
	sBMRP.Quests = sBMRP.Quests || {} 

	function ply:InQuest()
		return self.QuestName
	end

	function ply:StartQuest(QUEST)
		if not sBMRP.Quests[QUEST] then return end
		--if self:InQuest() then error("[sQuests]:" .. self:Name() .. " is already in a quest.") end
		-------------Setting up varibles----------
		self.QuestName = QUEST
		self.QuestLevel = 1
		ply.Quest = ply.Quest || {}
		ply.Quest.QuestHooks = ply.Quest.QuestHooks || {}
		ply.Quest.QuestTimers = ply.Quest.QuestTimers || {}
		-------------------------------=----------
		sBMRP.Quests.UpdatePlayer(sBMRP.Quests[QUEST][1], self)
	end
	
	function ply:QuestDerma(TITLE,DIR,POS)
		if POS == "DELETE" then
			net.Start("sBMRP.Quests")
				net.WriteString("DELETE")
			net.Send(self)
			return
		else
			net.Start("sBMRP.Quests")
				net.WriteString(POS or "TOP_RIGHT")
				local questinfo = {}
				questinfo.title = TITLE
				questinfo.directions = DIR
				net.WriteTable(questinfo)
			net.Send(self)
		end
	end
	function sBMRP.RegisterQuest(Quest, name)
		--if sBMRP.Quests[name] then return end
		sBMRP.Quests[name] = Quest
	end
	--[[-------------------------------------------------------------------------
	Quest Logic
	---------------------------------------------------------------------------]]
	function sBMRP.Quests.UpdatePlayer(QUEST, ply)
		dprint("Debug running")
		if not IsValid(ply) and not ply:IsPlayer() then error("Invalid Parameters!") end
		-------------Cleanup old varibles----------
		for k,v in pairs(ply.Quest.QuestHooks) do dprint("Removing " .. v[1] .. " " .. v[2]) hook.Remove(v[1], v[2]) end
		for k,v in pairs(ply.Quest.QuestTimers) do timer.Remove(v) end
		table.Empty(ply.Quest)
		ply.Quest.QuestHooks = {}
		ply.Quest.QuestTimers = {}
		------------------------------------------
		
		for flag, func in pairs(QUEST) do
			if flag == "ProgressToNextStage" then
				--if QUEST["ProgressToNextStage"][1](ply) == false then dprint("PROGRESS!") end
 				table.insert(ply.Quest.QuestHooks, {"Think","quest_progress-think_" .. ply:SteamID()})
 				
				hook.Add("Think", "quest_progress-think_" .. ply:SteamID(), function()
					local progress, level = QUEST["ProgressToNextStage"][1](ply)
					if progress then
							
						if level then
							if level == "END" then ply:EndQuest() return end
							ply.QuestLevel = level
							sBMRP.Quests.UpdatePlayer(sBMRP.Quests[ply.QuestName][level], ply)	
						else
							ply.QuestLevel = ply.QuestLevel + 1
							sBMRP.Quests.UpdatePlayer(sBMRP.Quests[ply.QuestName][ply.QuestLevel], ply)
						end
					end
				end)
				
			elseif flag == "QuestHooks" then
				for _, hooks in pairs(QUEST["QuestHooks"]) do
					local hookname = ply:SteamID() .. "_questhook-" .. hooks[1]
					table.insert(ply.Quest.QuestHooks, {hooks[1], hookname})

					hook.Add(hooks[1], hookname, hooks[2])
				end
			elseif flag == "QuestDerma" then
				ply:QuestDerma(func[1], func[2])
			elseif sBMRP.Quests.Functions[flag] then
				table.insert(func, ply) -- fuck this shit ya'know
				sBMRP.Quests.Functions[flag][1](unpack(func))
			end

		end
	end
	function ply:EndQuest()
		local ply = self
		if !ply:InQuest() then error("Player " .. ply:GetName() .. " is not in a quest!") end
		for k,v in pairs(ply.Quest.QuestHooks) do dprint("Removing " .. v[1] .. " " .. v[2]) hook.Remove(v[1], v[2]) end
		for k,v in pairs(ply.Quest.QuestTimers) do timer.Remove(v) end
		table.Empty(ply.Quest)
		for flag,func in pairs(sBMRP.Quests[ply.QuestName][self.QuestLevel]) do
			if sBMRP.Quests.Functions[flag] then
				dprint(sBMRP.Quests.Functions[flag][2])
				sBMRP.Quests.Functions[flag][2](ply)
			end
		end
		hook.Run("sBMRP.EndQuest", ply, ply.QuestName)
		ply.QuestName = nil
		self.QuestLevel = 0
		ply:QuestDerma(_,_,"DELETE")
	end
	hook.Add("PlayerDisconnected", "player_quest-cleanup", function()
		if ply:InQuest() then ply:EndQuest() end
	end)

	hook.Add("sBMRP.EndQuest", "test", function(ply, quest)
		Log(ply:GetName() .. " concluded quest: " .. quest)
		ply:Notify("You completed the quest!")
	end)
	concommand.Add("StartQuest", function()
		player.GetAll()[1]:StartQuest("FetchQuest")
	end)
	concommand.Add("EndQuest",function ()
		player.GetAll()[1]:EndQuest()
	end)
	--[[-------------------------------------------------------------------------
	Quest functions

	RULES:
	1. You MUST make sure that the function will clean up after itself. 
	2. Insert ALL of the hooks and timers you make into ply.Quest.QuestTimers and ply.Quest.QuestHooks.
	3. Add a "End" function, so if the quest is cut short it can still effectivly clean after itself.

	Looks like this:

	sBMRP.Quests.Functions[FlagNameHere] = {function(YourArgs, ply) code here end, function(ply) END CODE HERE end}

	---------------------------------------------------------------------------]]--
	sBMRP.Quests.Functions = {}

	sBMRP.Quests.Functions["WayPointObjective"] = {function(vector, radius, ply)
		if !isvector(vector) or !isnumber(radius) or !ply:IsPlayer() then error("Invalid Parameters!") end
		table.insert(ply.Quest.QuestTimers, "quest_waypoint_" .. ply:SteamID())
		timer.Create("quest_waypoint_" .. ply:SteamID(), 1, 0, function()
			if ply:GetPos():Distance(vector) <= radius then
				ply.Quest.WayPointObjective = true
				ply:MapWayPoint(false)
				ply:Notify("Destination reached!")
				timer.Destroy("quest_waypoint_" .. ply:SteamID())
			else
				ply:MapWayPoint(vector)
			end
		end)
	end, 
	function(ply)
		dprint("LMAO")
		ply:MapWayPoint(false)
	end}

end