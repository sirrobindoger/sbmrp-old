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
	ProgressToNextStage = {function(ply) 
		if ply.Quest.WayPointObjective then 
			return true
		end 
	end},
	QuestHooks = {
		{"PlayerSay", function(ply, text)
			if ply:IsAdmin() then 
				ply:ChatPrint("You are in a quest!")
			end
		end},
	},
	QuestDerma = {
			"Quest: Walk & Say!", {
			Colors = {{255,255,255}, {0,255,255}, {0,255,0}, {0,0,255}},
			Text = {"Proceed ", " to ", " the ", " checkpoint! "}
		}
	}
}

FETCH_ITEM[2] = {
	ProgressToNextStage = {function(ply)
		if ply.Quest.TalkCheck then
			return true, "END"
		end
	end},
	QuestHooks = {
		{"PlayerSay", function(ply, text)
			if ply:IsAdmin() and text == "/lol" then 
				ply:ChatPrint("You passed!")
				ply.Quest.TalkCheck = true
			end
		end},		
	},
	QuestDerma = {
			"Quest: Walk & Say!", {
			Colors = {{255,255,255}},
			Text = {"Say something really funny. "}
		}
	}
}

sBMRP.RegisterQuest(FETCH_ITEM, "FetchQuest", "science")

/*
for k,v in pairs(player.GetAll()) do
	sBMRP.Quests.Functions["WayPointObjective"](Vector(-4009.013672, -637.154724, -188.968750), 150, v )
end
*/



--player.GetAll()[1]:QuestDerma(_,_,"DELETE")