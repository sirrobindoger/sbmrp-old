function GetLocationEnt(recpos)
        recpos = recpos:GetPos()
    local location = DarkRP.getPhrase("gm_unknown")
    for k,v in pairs(GAMEMODE.locationnames) do
        if CheckInRange(v[2],v[3],recpos) then
            location = v[1]
            break
        else location = "Unknown"
        end
    end
    return location
end

function sBMRP.ShakeMap(optional)
    if optional == 1 then
        engine.LightStyle(0,"vvvcvvvpvpsvvvvcvd")
        timer.Simple(2, function()
            engine.LightStyle(0,"vvvpvvpvs")
        end)
    else
        engine.LightStyle(0,"vvvbvprvvbvpcvvvvdvf")
        timer.Simple(2, function()
            engine.LightStyle(0,"vvvpvvpvs")
        end)
    end        
    timer.Simple(7, function()
        if sBMRP.powerout then
            engine.LightStyle(0, "b")
        else
            engine.LightStyle(0, "v")
        end
        for k,v in pairs(player.GetAll()) do
            v:SendLua([[render.RedownloadAllLightmaps(true)]])
        end
    end)
    if optional == 1 then
        for k,v in pairs(player.GetAll()) do
            v:SendLua([[
                surface.PlaySound("env/rumble_shake.wav")]])
        end
    else
        for k,v in pairs(player.GetAll()) do
            v:SendLua([[
                surface.PlaySound("env/rumble_shake.wav")
                surface.PlaySound("ambient/explosions/explode_9.wav")
                util.ScreenShake( Vector( 0, 0, 0 ), 5, 5, 7, 5000 )]])
        end
    end
end

--[[-------------------------------------------------------------------------
Rotor speed
---------------------------------------------------------------------------]]
function sBMRP.AMS.SetRotorSpeed(speed)
    ents.GetMapCreatedEntity(5369):SetKeyValue("speed",speed)
end