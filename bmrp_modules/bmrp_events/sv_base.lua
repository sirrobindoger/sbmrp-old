util.AddNetworkString("sBMRP.Events")
local ply = FindMetaTable("Player")
sBMRP.Event = sBMRP.Event || {}

sBMRP.Event.rEvents = sBMRP.Event.rEvents || {} -- event registry
sBMRP.Event.aEvents = sBMRP.Event.aEvents || {} -- table reserved for exclusively active events
--[[-------------------------------------------------------------------------
Event Meta
---------------------------------------------------------------------------]]

local function getEvent( event, active )
	return not active and sBMRP.Event.rEvents[ event ] or sBMRP.Event.aEvents[ event ]
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
	sBMRP.Event.aEvents[ event ].Name = Event.name
	sBMRP.Event.aEvents[ event ].Hooks = {}
	sBMRP.Event.aEvents[ event ].Timers = {}
	sBMRP.Event.aEvents[ event ].Entities = {}
	sBMRP.Event.aEvents[ event ].Stage = stage or 1
	sBMRP.Event.aEvents[ event ].Meta = Event

	sBMRP.Event.UpdateEvent(getEvent(event), getEvent(event, true), stage or 1)
end

--[[-------------------------------------------------------------------------
Event Logic
---------------------------------------------------------------------------]]
local tRemove = function(tab) for k,v in pairs(tab) do table.Empty(v) end end
function sBMRP.Event.UpdateEvent(rEvent, aEvent, stage)
	-------------Cleanup old varibles----------
	for k,v in pairs(aEvent.Hooks) do hook.Remove(v[1], v[2]) end
	for k,v in pairs(aEvent.Timers) do timer.Remove(v) end
	for k,v in pairs(aEvent.Entities) do
		if v.PersistStage then
			continue
		end
		if IsValid(v) then
			v:Remove()
		end
		table.remove(aEvent.Entities, v)
	end
	tRemove({aEvent.Hooks, aEvent.Timers})
	------------------------------------------

	for flag, func in pairs(rEvent[stage]) do
		if flag == "UpdateStage" then
			table.insert(aEvent.Hooks, {"Think","update-stage-think_" .. aEvent.Name})
				
			hook.Add("Think", "update-stage-think_" .. aEvent.Name, function()
				local progress, level = rEvent["UpdateStage"][1]
				if progress then
					if level then
						if level == "END" then sBMRP.Event.SetInactive(aEvent) return end -- TODO: ADD FUNCTION
						aEvent.Stage = level
						sBMRP.Event.UpdateEvent(rEvent, aEvent, level)
					else
						aEvent.Stage = aEvent.Stage + 1
						sBMRP.Event.UpdateEvent(rEvent, aEvent, aEvent.Stage)
					end
				end
			end)
		elseif flag == "Timers" then
			for _, timers in pairs(rEvent["Timers"]) do
				local timername = aEvent.Name .. "_eventtimer-" .. _
				table.insert(aEvent.Timers, timername)

				timer.Create(timername, timers[1], timers[2], function() timers[3]() end)
			end
		elseif flag == "Hooks" then
			for _, hooks in pairs(rEvent["Hooks"]) do
				local hookname = aEvent.Name .. "_eventhook-" .. hooks[1]
				table.insert(aEvent.Hooks, {hooks[1], hookname})

				hook.Add(hooks[1], hookname, hooks[2])
			end
		elseif flag == "Functions" then
			for k,func in pairs(rEvent["Functions"]) do
				pcall(function() func(ply) end)
			end
		elseif  flag == "Entites" then
			for _, enttab in pairs(rEvent["Entities"]) do
				local eEnt = ents.Create(enttab[1])
				if !eEnt then return end
				eEnt.EventEntity = eEvent.Name
				eEnt.EventStage = stage
				table.insert(aEvent.Entities, eEnt)
				pcall(function() enttab[2](eEnt) end)
			end
		end
	end
end
