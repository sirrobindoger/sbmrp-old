--[[-------------------------------------------------------------------------
AMS Logic
-- ambient/machines/thumper_startup1.wav pit 47
plats/elevator_large_start1.wav
ambient/machines/wall_move4.wav
weapons/stunstick/alyx_stunner2.wav
ambient/levels/citadel/zapper_warmup1.wav
npc/scanner/cbot_discharge1.wav
npc/strider/charging.wav
weapons/stickybomblauncher_charge_up.wav
weapons/loose_cannon_charge.wav
---------------------------------------------------------------------------]]

sBMRP.AMS = sBMRP.AMS || {}
sBMRP.AMS.state = sBMRP.AMS.state|| 0
sBMRP.AMS.prev = 0
local amsbuttons = {
    1912, -- Motor button
    1922, -- Stage 1 Emitters
    1919, -- Stage 2 Emitters
    1818, -- AMS Prop Arm
}


local MetaStates = {
    ["func_door"] = function( self )
        return ( self:GetSaveTable().m_toggle_state == 0 )
    end,
    ["func_door_rotating"] = function( self )
        return ( self:GetSaveTable().m_toggle_state == 0 )
    end,
    ["prop_door_rotating"] = function( self )
        return ( self:GetSaveTable().m_eDoorState ~= 0 )
    end,
    ["func_button"] = function(self)
        return (self:GetSaveTable().m_toggle_state == 0)
    end,
}

function IsActivated( door ) -- this is pretty useful
    local func = MetaStates[door:GetClass()]
    if func then
        return func( door )
    end
end

local function EntID(id)
    return ents.GetMapCreatedEntity(id)
end

------------------------------

hook.Add("Think", "ams_state", function()
    state = 0
    for _,v in pairs(amsbuttons) do
        if IsActivated(EntID(v)) then
            state = state + 1
        end
    end
    sBMRP.AMS.state = state

    
    if (sBMRP.AMS.prev != sBMRP.AMS.state) then
        hook.Run("AMSStateChange", sBMRP.AMS.state, sBMRP.AMS.prev)
        Log("AMS State changed from Stage: " .. sBMRP.AMS.prev .. " -> " .. sBMRP.AMS.state)
        sBMRP.AMS.prev = sBMRP.AMS.state
    end
end)
