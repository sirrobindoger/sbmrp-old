if SERVER then
	util.AddNetworkString("sBMRP.Quests")
	local ply = FindMetaTable("Player")
	sBMRP.Quests = sBMRP.Quests || {}

	function ply:InQuest()
		return self:GetNWBool("InQuest"),false)
	end

	function ply:StartQuest(QUEST)
	end

end