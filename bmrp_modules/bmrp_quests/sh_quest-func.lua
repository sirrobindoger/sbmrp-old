if SERVER then
	util.AddNetworkString("sBMRP.Quests")
	local ply = FindMetaTable("Player")
	sBMRP.Quests = sBMRP.Quests 

	function ply:InQuest()
		return self:GetNWBool("InQuest",false)
	end

	function ply:StartQuest(QUEST)
		if self:InQuest() then Error("[sQuests]:" .. self:Name() .. " is already in a quest.") end
		

	end

	function sBMRP.RegisterQuest(Quest, name)
		if sBMRP.Quests[name] then return end
		sBMRP.Quests[name] = Quest
	end

	--[[-------------------------------------------------------------------------
	Quest functions
	---------------------------------------------------------------------------]]
	sBMRP.Quests.Functions = {}

	sBMRP.Quests.Functions["WayPointObjective"] = function(vector, radius, ply)
		if !isvector(vector) or !isnumber(radius) or !ply:IsPlayer() then error("Invalid Parameters!") end
		
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