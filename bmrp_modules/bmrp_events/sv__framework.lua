util.AddNetworkString("sBMRP.Events")
local ply = FindMetaTable("Player")
sBMRP.Events = sBMRP.Events || {}

function sBMRP:InEvent()
	return self.Events.Active or false
end


