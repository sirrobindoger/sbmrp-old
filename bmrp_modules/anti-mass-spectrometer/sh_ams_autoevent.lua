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
    sound = "ambience/zapmachine.wav"
} )
sound.Add( {
    name = "bmrp_ams_start",
    channel = 6,
    volume = 1.0,
    level = 80,
    pitch = { 100 },
    sound = "env/ams_start.wav"
} )
sound.Add( {
    name = "bmrp_ams_zap",
    channel = 6,
    volume = 1.0,
    level = 80,
    pitch = { 100 },
    sound = "ambient/levels/citadel/zapper_loop1.wav"
} )

amsCore = ents.GetMapCreatedEntity(5367)


sBMRP.AMS.StateChange = {
	[0] = function(state)
		for k,v in pairs(ents.GetAll()) do if v:GetName() == "floor_spotlight_1" then v:Fire("TurnOff") end end
	    amsCore:EmitSound("ambient/levels/labs/teleport_winddown1.wav", 80, 100, 1) 
	    amsCore:EmitSound("ambient/energy/powerdown2.wav", 80, 95, 1)
	    amsCore:StopSound("bmrp_ams_")
	    amsCore:StopSound("bmrp_ams_start")
	    timer.Remove("sBMRP.AMSTEST")
	end,
	[1] = function(state)
		if state then
			for k,v in pairs(player.GetAll()) do if GetLocation(v) == "AMS Chamber" then v:SendLua([[util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 4, 5000 )]]) end end
			local rotorspeed = { {3, 5}, {8, 10}, {10,15}, {15, 35} }
	        sBMRP.AMS.SetRotorSpeed(1)
	        for k,v in pairs(rotorspeed)do
	            timer.Simple(v[1], function()
	                sBMRP.AMS.SetRotorSpeed(v[2])
	            end)
	        end
	        amsCore:EmitSound("bmrp_ams_start")
	        sBMRP.ShakeMap(1)
	        muteSound = true
	        timer.Create("sBMRP.AMSTEST", 11, 1, function()
	        	muteSound = false
	            if sBMRP.AMS.state != 0 then
	                sBMRP.AMS.SetRotorSpeed(70)
	                amsCore:EmitSound("bmrp_ams_")
	            end
	        end)
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

	end,
	[4] = function(state)

	end,

}



hook.Add("EntityEmitSound", "silence_ams", function(data)
    ent = data.Entity
    if data.SoundName == "ambience/zapmachine.wav" and not muteSound then
        return false
    end
end)



hook.Add("AMSStateChange", "bmrp-ams", function(state, prevstate)
	if sBMRP.AMS.StateChange[state] != nil then
		if state > prevstate then -- moving up a state
			sBMRP.AMS.StateChange[state](true)
		else
			sBMRP.AMS.StateChange[state]() -- its moving down a state
		end	
	end
end)