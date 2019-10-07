if SERVER then
	--[[-------------------------------------------------------------------------
	Lockdown enhancement
	3468
	Name: alarmbuttons
	---------------------------------------------------------------------------]]
	sBMRP.RemoveChatCommand("/lockdown")
	local lockdownEvent = {}
	lockdownEvent["Lockdown"] = {}

	local lockdownNoUse = table.ValuesToKeys({
		2213, -- secA elevator
		5358, -- akari up
		5357, -- akari down
		1911, -- secC airlock
		1913, -- bioSec door
		5633, -- AMS ELevator
		2163, -- secC AMS entr
		2150, -- amsContr
		2176, -- Security
		3192, -- Security 2
		3187, -- secC enterance
		4130, -- secD door1
		4129, -- secD door2
		2391, -- teleport1
		2392, -- teleport2
		4459, -- teleEntr
	})

	local doorsLock = {
		2239, -- secA staircase
		2269, -- secA enterance
		3748, -- topside Ele enterance
		1887, -- bioSec kennel1
		1886, -- bioSec kennel2
		1847, -- secC lock
		5231, -- secStorage door

	}
	lockdownEvent["Lockdown"]["CanStart"] = function()
		if sBMRP.Event:GetActive()["Lockdown"] || #player.GetAll() <= 5 then
			return false
		else
			return true
		end
	end

	lockdownEvent["Lockdown"]["Hooks"] = {
		{"PlayerUse", function(ply, ent)
	    if !IsFirstTimePredicted() then return end
	    if !ply:AntiSpam() then return end
			if lockdownNoUse[ent:MapCreationID()] then
				if !ply:IsSecurity() and !ply:IsHECU() then
					sBMRP.ChatNotify({ply}, "Error", "Lockdown in effect. Inoperable.")
					ent:EmitSound("buttons/button2.wav", 80, 100)
				end
				return false
			end
		end},
	}

	lockdownEvent["Lockdown"]["Timers"] = {
		{10, 0, function()
			for k, door in pairs(doorsLock) do
				ents.sMapEnt(door, function(v)
					v:Fire("Lock")
					v:Fire("Close")
				end)
			end
		end},
	}

	lockdownEvent["Lockdown"]["OnStart"] = {
		function()
			sBMRP.Lockdown = true
			SetGlobalBool("Lockdown", true)
			sBMRP.SetHECUCode("Blue")
		end
	}
	lockdownEvent["Lockdown"]["OnEnd"] = {
		function()
			sBMRP.Lockdown = false
			SetGlobalBool("Lockdown", false)
			sBMRP.SetHECUCode("Green")
			for k, door in pairs(doorsLock) do
				ents.sMapEnt(door, function(v)
					v:Fire("Unlock")
				end)
			end			
		end
	}

	sBMRP.Event.rEvents[ "Lockdown" ] = lockdownEvent

	local function lockdownCommand(ply, args)
		if ply:IsAdmin() or ply:Team() == TEAM_ADMINISTRATOR then
			if sBMRP.Lockdown then
				sBMRP.Event.SetInactive("Lockdown")
			else
				sBMRP.Event.SetActive("Lockdown")
			end
		end
	end
end