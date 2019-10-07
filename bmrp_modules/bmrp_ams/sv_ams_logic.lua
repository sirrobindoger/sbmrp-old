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
sBMRP.AMS.State = sBMRP.AMS.State|| 0
sBMRP.AMS.prev = 0
local amsbuttons = {
    1912, -- Motor button
    1922, -- Stage 1 Emitters
    1919, -- Stage 2 Emitters
    --1818, -- AMS Prop Arm
}

amsControls = {
    rotorStart = 1912,
    stageOne = 1922,
    stageTwo = 1919,
    cartBay = 1929,
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
local ent = FindMetaTable("Entity")
function ent:IsActivated() -- this is pretty useful
    local func = MetaStates[self:GetClass()]
    if func then
        return func( self )
    end
end

local function EntID(id)
    return ents.GetMapCreatedEntity(id)
end


timer.Create("ams_radioactive-burn", 10, 0, function()
    table.Iterate(ents.GetInVec(Vector(-2849.6381835938,-2990.3813476563,-600.14013671875), Vector(-3890.35546875,-4095.1398925781,-1605.2644042969)), function(v)
        if v:IsPlayer() then
            if sBMRP.AMS.State > 1 && !ply:HasHEV() then
                --local d = DamageInfo()
               --d:SetDamage( 20 )
                --d:SetAttacker(game.GetWorld())
                --d:SetDamageType( DMG_DISSOLVE )
                --ply:TakeDamageInfo( d )
                --ply:EmitSound("player/pl_burnpain1.wav")
                player.GetSirro():ChatPrint(v:getName())
            end
        end
    end)
end)



------------------------------

hook.Add("Think", "ams_state", function()
    state = 0
    for _,v in pairs(amsbuttons) do
        if EntID(v):IsActivated() then
            state = state + 1
        end
    end
    if EntID(1818):IsActivated() && state == 3 then
        state = 4
    end
    sBMRP.AMS.State = state

    
    if (sBMRP.AMS.prev != sBMRP.AMS.State) then
        hook.Run("AMSStateChange", sBMRP.AMS.State, sBMRP.AMS.prev)
        SetGlobalInt("AMSState", sBMRP.AMS.State)
        Log("AMS State changed from Stage: " .. sBMRP.AMS.prev .. " -> " .. sBMRP.AMS.State)
        sBMRP.AMS.prev = sBMRP.AMS.State
    end
end)
