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
FETCH_ITEM.Prompt = "Dr. Fitzgerald needs you to find his very important microscope!\nI think he last saw it in Sector D "
FETCH_ITEM.Title = "Find Fitzgerald's Microscope"

FETCH_ITEM[1] = {
	ProgressToNextStage = {function(ply) 
		if GetLocation(ply) == "Sector D" then
			ply:MapWayPoint(false)
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
	QuestTimers = {
		{1, 0, function(ply)
			ply:MapWayPoint(Vector(-6621.270996, -2460.237061, -188.968750))
		end},
	},
	QuestDerma = {
			FETCH_ITEM.Title, {
			Colors = {{255,255,255}, {255,0,0}, {255,0,0}, {255,0,0}},
			Text = {FETCH_ITEM.Prompt, 
			"\n1. Head to Sector D", "\n2. Find the microscope ", "\n3. Bring it back to the Doctor "}
		}
	},
}

FETCH_ITEM[2] = {
	ProgressToNextStage = {function(ply)
		if ply.Quest.PickedUpProp then
			return true
		end
	end},
	QuestHooks = {
		{"PlayerSay", function(ply, text)
			if ply:IsAdmin() and text == "/lol" then 
				ply:ChatPrint("You passed!")
				ply.Quest.TalkCheck = true
			end
		end},
		{"PlayerUse", function(ply, ent)
			if !ent.QuestEntity or not IsFirstTimePredicted() then return end
			ply:ChatPrint("You picked up a quest ent!")
			if ply != ent.Parent then
				ply:ChatPrint("It isn't yours!")
				return false
			else
				ply:ChatPrint("Its yours!")
				ply.Quest.PickedUpProp = true
			end
		end},	
	},
	QuestDerma = {
			FETCH_ITEM.Title, {
			Colors = {{255,255,255}, {0,255,0}, {255,0,0}, {255,0,0}},
			Text = {FETCH_ITEM.Prompt, 
			"\n1. Head to Sector D", "\n2. Find the microscope ", "\n3. Bring it back to the Doctor "}
		}
	},
	Functions = {
		function(ply)
			local proppos = Vector(-5565.797363, -2857.772461, -188.968750)
			local propent = ents.Create("prop_physics")
			propent:SetName("QuestEnt" .. ply:SteamID())
			propent:SetModel("models/props_questionableethics/microscope.mdl")
			propent:SetPos(DarkRP.findEmptyPos(proppos, {}, 300, 30, Vector(16,16,64)))
			propent:Spawn()
			propent.QuestEntity = true
			propent.Parent = ply
			ply.QuestEnts = {}
			ply.QuestEnts["Microscope"] = propent
		end,
	}
}

FETCH_ITEM[3] = {
	ProgressToNextStage = {function(ply)
		if GetLocation(ply) == "Multisector Junction" and ply.Quest.PropReturned then
			return true, "END"
		end
	end},
	QuestTimers = {
		{1, 0, function(ply)
			if ply.QuestEnts["Microscope"]:GetPos():WithinAABox(Vector(-6636.458496, -1092.492065, -104.842941),Vector(-6484.599121, -1172.760132, -271.868347)) then
				ply.Quest.PropReturned = true
			end
		end},
	},
	QuestDerma = {
			FETCH_ITEM.Title, {
			Colors = {{255,255,255}, {0,255,0}, {0,255,0}, {255,0,0}},
			Text = {FETCH_ITEM.Prompt, 
			"\n1. Head to Sector D", "\n2. Find the microscope ", "\n3. Bring it back to the Doctor "}
		}
	},
}

sBMRP.RegisterQuest(FETCH_ITEM, "FetchQuest", "science")

/*
for k,v in pairs(player.GetAll()) do
	sBMRP.Quests.Functions["WayPointObjective"](Vector(-4009.013672, -637.154724, -188.968750), 150, v )
end
*/



--player.GetAll()[1]:QuestDerma(_,_,"DELETE")