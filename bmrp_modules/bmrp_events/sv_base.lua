--[[-------------------------------------------------------------------------
EVENT BASE (FOR SIRRO'S SHITTY ROLEPLAY SHIT STUFF; HOLY. SHIT. I. WANT. TO. DIE.)

Flags:

-	UpdateStage (function) :
	-	Runs every tick
	-	First return value is a boolean (true for change stage, false for don't)
	-	Second return value is optional, it can be either 
-	


---------------------------------------------------------------------------]]


util.AddNetworkString("sBMRP.Event")
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
	if !sBMRP.Event.rEvents[ event ]["CanStart"] || !sBMRP.Event.rEvents[ event ]["CanStart"]() then
		return false
	else
		return true
	end
end

function sBMRP.Event.SetActive( event, stage )
	if !sBMRP.Event.rEvents[ event ] then return end



		sBMRP.Event.SetupEvent(event, stage || 1)

end

function sBMRP.Event.SetupEvent(event, stage)
	sBMRP.Event.aEvents[ event ] = {}
	local Event = sBMRP.Event.rEvents[ event ]
	sBMRP.Event.aEvents[ event ].Name = event
	sBMRP.Event.aEvents[ event ].Hooks = {}
	sBMRP.Event.aEvents[ event ].Timers = {}
	sBMRP.Event.aEvents[ event ].Entities = {}
	sBMRP.Event.aEvents[ event ].Stage = stage || 1
	sBMRP.Event.aEvents[ event ].Meta = Event

	sBMRP.Event.UpdateEvent(getEvent(event), getEvent(event, true), stage || 1)
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
		if v.EventPersistant then
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
				local progress, level = rEvent[stage]["UpdateStage"]()
				if progress then
					if level then
						
						if level == "END" then sBMRP.Event.SetInactive(rEvent.name) return end -- TODO: ADD FUNCTION
						aEvent.Stage = level
						sBMRP.Event.UpdateEvent(rEvent, aEvent, level)
					else
						aEvent.Stage = aEvent.Stage + 1
						sBMRP.Event.UpdateEvent(rEvent, aEvent, aEvent.Stage)
					end
				end
			end)
		elseif flag == "Timers" then
			for _, timers in pairs(rEvent[stage]["Timers"]) do
				local timername = aEvent.Name .. "_eventtimer-" .. _
				table.insert(aEvent.Timers, timername)

				timer.Create(timername, timers[stage], timers[2], function() timers[3]() end)
			end
		elseif flag == "Hooks" then
			for _, hooks in pairs(rEvent[stage]["Hooks"]) do
				local hookname = aEvent.Name .. "_eventhook-" .. hooks[1]
				table.insert(aEvent.Hooks, {hooks[1], hookname})

				hook.Add(hooks[1], hookname, hooks[2])
			end
		elseif flag == "Functions" then
			for k,func in pairs(rEvent[stage]["Functions"]) do
				pcall(function() func(ply) end)
			end
		elseif flag == "Entities" then
			for _, enttab in pairs(rEvent[stage]["Entities"]) do
				local eEnt = ents.Create(enttab[1])
				if !eEnt then return end
				eEnt.EventEntity = aEvent.Name
				eEnt.EventStage = stage
				eEnt.EventPersistant = enttab[2]
				local entsetup = pcall(function() enttab[3](eEnt) end)
				if !entsetup then ErrorNoHalt("Entity " .. enttab[1] .. " errored while being passed into your function!") end
				table.insert(aEvent.Entities, eEnt)
				
			end
		end
	end
end

function sBMRP.Event.SetInactive(event)
	if !sBMRP.Event.rEvents[ event ] || !sBMRP.Event.aEvents[ event ] then return end
	local rEvent, aEvent = getEvent(event), getEvent(event, true)
	for k,v in pairs(aEvent.Hooks) do hook.Remove(v[1], v[2]) end
	for k,v in pairs(aEvent.Timers) do timer.Remove(v) end
	for k,v in pairs(aEvent.Entities) do
		if v and v:IsValid() then
			v:Remove()
		end
		table.remove(aEvent.Entities, k)
	end
	tRemove({aEvent.Hooks, aEvent.Timers})
	sBMRP.Event.aEvents[event] = nil


end