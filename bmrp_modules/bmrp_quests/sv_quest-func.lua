if SERVER then
	util.AddNetworkString("sBMRP.Quests")
	local ply = FindMetaTable("Player")
	sBMRP.Quests = sBMRP.Quests || {} 

	function ply:InQuest()
		return self:GetNWBool("InQuest",false)
	end

	function ply:StartQuest(QUEST)
		if self:InQuest() then error("[sQuests]:" .. self:Name() .. " is already in a quest.") end
		ply.QuestHooks = ply.QuestHooks || {}
		ply.QuestTimers = ply.QuestTimers || {}
		if not sBMRP.Quests[QUEST] then return end
		local QUEST = sBMRP.Quests[QUEST]

		sBMRP.Quests.UpdatePlayer(QUEST[1], self)

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
				PrintTable(questinfo)
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
	function sBMRP.Quests.UpdatePlayer(level, ply)
		print("Debug running")
		if not IsValid(ply) and not ply:IsPlayer() then error("Invalid Parameters!") end
		
		-- Cleanup old hooks/timers
		for k,v in pairs(ply.QuestHooks) do hook.Remove(v[1], v[2]) end
		for k,v in pairs(ply.QuestTimers) do timer.Remove(v) end
		ply.QuestHooks,ply.QuestTimers = {}, {}
		

	end
	--player.GetAll()[1]:StartQuest("FetchQuest")
	--[[-------------------------------------------------------------------------
	Quest functions
	---------------------------------------------------------------------------]]
	sBMRP.Quests.Functions = {}

	sBMRP.Quests.Functions["WayPointObjective"] = function(vector, radius, ply)
		if !isvector(vector) or !isnumber(radius) or !ply:IsPlayer() then error("Invalid Parameters!") end
		table.insert(ply.QuestTimers, "quest_waypoint_" .. ply:SteamID())
		timer.Create("quest_waypoint_" .. ply:SteamID(), 1, 0, function()
			if ply:GetPos():Distance(vector) <= radius then
				ply.WayPointObjective = true
				ply:MapWayPoint(false)
				ply:Notify("Destination reached!")
				timer.Destroy("quest_waypoint_" .. ply:SteamID())
			else
				ply:MapWayPoint(vector)
			end
		end)

	end

end