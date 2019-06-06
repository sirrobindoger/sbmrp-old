--[[-------------------------------------------------------------------------
Sirro's Questing System (sBMRP)

Quest flags:
WayPointObjective = {Position(Vector), Proximity(int)}
ProgressToNextStage = function()(when returning true, it will move to the next table)

---------------------------------------------------------------------------]]


--[[-------------------------------------------------------------------------
Fetch and retrieve quest
---------------------------------------------------------------------------]]

FETCH_ITEM = {}

FETCH_ITEM[1] = {
	WayPointObjective = {Vector(-2267.979004, -3622.374756, -165.024750), 150}, -- position and proximity the player must reach to that distance
	ProgressToNextStage = {function() 
		if WayPointObjective then 
			return true 
		end 
	end},
	QuestHooks = {
		{"PlayerSay", function(ply, args)
			if ply:IsAdmin() then 
				ply:ChatPrint("You are in a quest!")  
			end
		end},
	}
}

sBMRP.RegisterQuest(FETCH_ITEM, "FetchQuest")

for k,v in pairs(player.GetAll()) do
	sBMRP.Quests.Functions["WayPointObjective"](Vector(-4009.013672, -637.154724, -188.968750), 150, v )
end