util.AddNetworkString("sBMRP.Events")
local ply = FindMetaTable("Player")
sBMRP.Event = sBMRP.Event || {}

sBMRP.Event.rEvents = sBMRP.Event.rEvents || {} -- event registry
sBMRP.Event.aEvents = sBMRP.Event.aEvents || {} -- table reserved for exclusively active events
--[[-------------------------------------------------------------------------
Event Meta
---------------------------------------------------------------------------]]

local function getEvent( event )
	return sBMRP.Event.rEvents[ event ]
end

function sBMRP.Event.Active()
	return self.Event.Active || {}
end

function sBMRP.Event.CanStart(event)
	if !sBMRP.Event.rEvents[ event ].canstart || !sBMRP.Event.rEvents[ event ].canstart() then
		return false
	else
		return true
	end
end

function sBMRP.Event.SetActive( event, stage )
	if !sBMRP.Events.rEvents[ event ] then return end

	if sBMRP.Events.aEvents[ event ] then
		sBMRP.Event.UpdateEvent(event, stage || 1)
	else
		sBMRP.Event.SetupEvent(event, stage || 1)
	end
end

function sBMRP.Event.SetupEvent(event, stage)
	sBMRP.Events.aEvents[ event ] = {}
	local Event = sBMRP.Event.rEvents[ event ]
	sBMRP.Events.aEvents[ event ].Name = Event.name
	sBMRP.Events.aEvents[ event ].Hooks = {}
	sBMRP.Events.aEvents[ event ].Timers = {}

	sBMRP.Events.aEvents[ event ].Meta = Event

end