util.AddNetworkString("Event")
local ply = FindMetaTable("Player")
Event = {}

--[[-------------------------------------------------------------------------
Event Object

Event:
	Name:
		-Name
	stages:
		-stageOne
		-stageTwo

---------------------------------------------------------------------------]]

Event._meta = {}

Event._meta.__index = Event._meta


Event._meta["setName"] = function(self, str)
	self.Name = str
	self.ID = str:Replace(" ", ""):trim()
	return self.ID
end

Event._meta["getName"] = function(self, str)
	return self.Name || "NULL", self.ID || "NULL"
end

Event._meta["getStage"] = function(self,str)
	return self.stages[str]
end

Event._meta["getStages"] = function(self)
	return self.stages
end

Event._meta["getActiveStages"] = function(self)
	local activeStages = {}
	table.Iterate(self.stages, function(v)
		if v.IsActive then
			activeStages[v.ID] = v
		end
	end)
end



--[[-------------------------------------------------------------------------
Event -> Stage Object
---------------------------------------------------------------------------]]

Event._stageMeta = {}

Event._stageMeta.__index = Event._stageMeta

Event._stageMeta["isActive"] = function(self)
	return self.IsActive
end

--[[-------------------------------------------------------------------------
Event Meta
---------------------------------------------------------------------------]]

/*local function getEvent( event, active )
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
	sBMRP.Event.aEvents[ event ].OnEnd = {}
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
	for k,v in pairs(aEvent.OnEnd) do v() end
	for k,v in pairs(aEvent.Entities) do
		if v.EventPersistant then
			continue
		end
		if IsValid(v) then
			v:Remove()
		end
		table.remove(aEvent.Entities, v)
	end
	tRemove({aEvent.Hooks, aEvent.Timers, aEvent.OnEnd})
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

				timer.Create(timername, timers[1], timers[2], function() timers[3]() end)
			end
		elseif flag == "Hooks" then
			for _, hooks in pairs(rEvent[stage]["Hooks"]) do
				local hookname = aEvent.Name .. "_eventhook-" .. hooks[1]
				table.insert(aEvent.Hooks, {hooks[1], hookname})

				hook.Add(hooks[1], hookname, hooks[2])
			end
		elseif flag == "OnStart" then
			for k,func in pairs(rEvent[stage]["OnStart"]) do
				pcall(function() func(ply) end)
			end
		elseif flag == "OnEnd" then
			table.insert(aEvent.OnEnd, func)
		elseif flag == "Entities" then
			for _, enttab in pairs(rEvent[stage]["Entities"]) do
				local eEnt = ents.Create(enttab[1])
				if !eEnt then return end
				eEnt.EventEntity = aEvent.Name
				eEnt.EventStage = stage
				eEnt.EventPersistant = enttab[2]
				local entsetup,err = pcall(function() enttab[3](eEnt) end)
				if !entsetup then ErrorNoHalt("Entity " .. enttab[1] .. " errored while being passed into your function!\n" .. err) end
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
	for k,v in pairs(aEvent.OnEnd) do v[1]() end
	for k,v in pairs(aEvent.Entities) do
		if v and v:IsValid() then
			v:Remove()
		end
		table.remove(aEvent.Entities, k)
	end
	sBMRP.Event.aEvents[event] = nil


end*/