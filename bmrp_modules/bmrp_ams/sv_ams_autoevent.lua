--[[-------------------------------------------------------------------------
AMS Recode

This code overrides the default map AMS
---------------------------------------------------------------------------]]
sBMRP.AMS = sBMRP.AMS || {}

sound.Add( {
    name = "bmrp_ams_",
    channel = 6,
    volume = 1.0,
    level = 80,
    pitch = { 100 },
    sound = "ambient/levels/citadel/stalk_StalkerTrainInterior_Loop.wav"
} )
sound.Add( {
    name = "bmrp_ams_start",
    channel = 6,
    volume = 1.0,
    level = 80,
    pitch = { 100 },
    sound = "ambient/levels/citadel/stalk_StalkerTrainStartUp.wav"
} )
sound.Add( {
    name = "bmrp_ams_zap",
    channel = 6,
    volume = 1.0,
    level = 80,
    pitch = { 100 },
    sound = "ambient/levels/citadel/zapper_loop1.wav"
} )


--[[-------------------------------------------------------------------------
flicker pattersn
mmnmmommommnonmmonqnmmo
mmnnmmnnnmmnn
nmonqnmomnmomomno
---------------------------------------------------------------------------]]


local function setRotorSpeed(int)
	table.Iterate(ents.GetAll(), function(v) 
		if v:GetName():find("zap") then 
			v:SetKeyValue("speed", tostring(int)) 
		end 
	end)
end

local function probeArmsOpen(bool)
	table.Iterate(ents.GetAll(), function(v) 
		if v:GetName():find("probe_arm_*") then
			timer.Simple(1, function()
				v:Fire(!bool && "Open" || "Close") 
			end)
		end 
	end)
end

sBMRP.MapHook("close_probe", function()
	probeArmsOpen(false)
end)


sBMRP.AMS.StateChange = {
	[0] = function(state)
		table.Iterate(ents.FindByName("floor_spotlight_1"), function(v) v:Fire("TurnOff") end)
		table.Iterate(player.InLocation("AMS Chamber"), function(v) v:SendLua([[util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 4, 5000 )]]) end)
	    amsCore:EmitSound("ambient/levels/labs/teleport_winddown1.wav", 80, 100, 1)
	    amsCore:EmitSound("ambient/energy/powerdown2.wav", 80, 95, 1)
	    amsCore:EmitSound("ambient/levels/citadel/stalk_StalkerTrainXtraBump03.wav", 80, 40, 1)
	    amsCore:StopSound("bmrp_ams_start")
	    amsCore:StopSound("bmrp_ams_")
	    probeArmsOpen(false)
	end,
	[1] = function(state)
		if state then
			probeArmsOpen(true)
			table.Iterate(ents.FindByName("floor_spotlight_1"), function(v) v:SetKeyValue("pattern", "mmnmmommommnonmmonqnmmo") v:Fire("TurnOn") end)
			table.Iterate(player.InLocation("AMS Chamber"), function(v) v:SendLua([[util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 4, 5000 )]]) end)
	        amsCore:EmitSound("bmrp_ams_start")
	        amsCore:EmitSound("bmrp_ams_")
	        amsCore:EmitSound("ambient/machines/thumper_startup1.wav", 75, 47, 1)

	    else

		    amsCore:EmitSound("vehicles/apc/apc_shutdown.wav")
            amsCore:StopSound("vehicles/apc/apc_start_loop3.wav")
	    end
	end,
	[2] = function(state)


		if state then
	       amsCore:EmitSound("ambient/machines/thumper_startup1.wav", 75, 100 )
		else
			amsCore:EmitSound("npc/scanner/cbot_discharge1.wav", 75, 70)
	    end
	end,
	[3] = function(state)

	if state then
		--sBMRP.UpdateEngineLight("mmnmmommommnonmmonqnmmo")
		--RunConsoleCommand("vox", "deeoo", "warning", "high", "energy", "field", "detected", "in", "anomalous", "test", "lab")
		amsCore:EmitSound("weapons/stunstick/alyx_stunner2.wav")
		amsCore:EmitSound("ambient/levels/citadel/zapper_warmup1.wav")
		amsCore:EmitSound("ambient/levels/intro/Rhumble_2_12_13.wav")
	else
		amsCore:EmitSound("npc/scanner/cbot_discharge1.wav")
	end



	end,
	[4] = function(state)

	end,

}



hook.Add("EntityEmitSound", "silence_ams", function(data)
    if data.SoundName == "ambience/steamburst1.wav" then
    	data.SoundName = "hl1/ambience/steamburst1.wav"
        return true
    end
end)



hook.Add("AMSStateChange", "bmrp-ams", function(state, prevstate)
	amsCore = ents.GetMapCreatedEntity(5367)
	if sBMRP.AMS.StateChange[state] != nil then
		if state > prevstate then -- moving up a state
			sBMRP.AMS.StateChange[state](true)
		else
			sBMRP.AMS.StateChange[state]() -- its moving down a state
		end	
	end
end)


local function createNewCart() --5546
	local amsCart = ents.GetMapCreatedEntity(5546)
	amsCart:SetRenderMode(RENDERMODE_NONE)
	amsCart:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	local amsCartPos = amsCart:GetPos()
	local amsCartAngs = amsCart:GetAngles()
	--amsCart:SetPos(Vector(0,0,0))

	local newCart = ents.Create("ams_cart")
	newCart:SetPos(amsCartPos)
	newCart:SetAngles(amsCartAngs)
	newCart:Spawn()
	amsCart:SetParent(newCart)
end
sBMRP.MapHook("Create_cart",createNewCart)
