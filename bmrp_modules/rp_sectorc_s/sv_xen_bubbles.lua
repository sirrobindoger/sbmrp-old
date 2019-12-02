


function flashply(ply)
    if not ply or not ply:IsPlayer() then return end
    ply:DoScreenFade(Color(0, 255, 0, 200), 0.3, 0)
end

function SpawnXenFlash(position)
    local effectdata = EffectData()
    effectdata:SetOrigin( position )
    effectdata:SetRadius(10)
    effectdata:SetMagnitude(5)
    local clr = Color( 0, 255, 0, 255 )
    local r = bit.band( clr.r, 255 )
    local g = bit.band( clr.g, 255 )
    local b = bit.band( clr.b, 255 )
    local a = bit.band( clr.a, 255 )
    local numberClr = bit.lshift( r, 24 ) + bit.lshift( r, 16 ) + bit.lshift( r, 8 ) + a
    effectdata:SetColor(numberClr)
    effectdata:SetScale(1)
    local effectdatat = EffectData()
    effectdatat:SetStart(position)
    effectdatat:SetOrigin(position)
    effectdatat:SetScale(1)
    effectdatat:SetMagnitude(1)
    effectdatat:SetScale(3)
    effectdatat:SetRadius(2)
    effectdatat:SetEntity(position)
    local ent = ents.Create( "xen_teleport_ball" )
    if ( !IsValid( ent ) ) then return end // Check whether we successfully made an entity, if not - bail
    ent:SetPos( position )
    ent:Spawn()
    for k,v in pairs(player.GetAll()) do if ent:Visible(v) then flashply(v) end end
    for i = 40, 100, 1 do
        timer.Simple(1 / i, function()
            local effectdata = EffectData()
            effectdata:SetStart(position)
            effectdata:SetOrigin(position)
            effectdata:SetScale(1)
            effectdata:SetMagnitude(1)
            effectdata:SetScale(3)
            effectdata:SetRadius(2)
            effectdata:SetEntity(ent)
            util.Effect("TeslaHitBoxes", effectdatat, true, true)
        end)
    end

end

function SpawnXenFlashNPC(NPCClass,position)
    local effectdata = EffectData()
    effectdata:SetOrigin( position )
    effectdata:SetRadius(10)
    effectdata:SetMagnitude(5)
    local clr = Color( 0, 255, 0, 255 )
    local r = bit.band( clr.r, 255 )
    local g = bit.band( clr.g, 255 )
    local b = bit.band( clr.b, 255 )
    local a = bit.band( clr.a, 255 )
    local numberClr = bit.lshift( r, 24 ) + bit.lshift( r, 16 ) + bit.lshift( r, 8 ) + a
    effectdata:SetColor(numberClr)
    effectdata:SetScale(1)
    local effectdatat = EffectData()
    effectdatat:SetStart(position)
    effectdatat:SetOrigin(position)
    effectdatat:SetScale(1)
    effectdatat:SetMagnitude(1)
    effectdatat:SetScale(3)
    effectdatat:SetRadius(2)
    effectdatat:SetEntity(position)
    local ent = ents.Create( "xen_teleport_ball" )
    if ( !IsValid( ent ) ) then return end // Check whether we successfully made an entity, if not - bail
    ent:SetPos( position )
    ent:Spawn()
    util.Effect( "cball_explode", effectdata )
    util.Effect("Sparks",effectdata)
    local ent = ents.Create( NPCClass )
    if ( !IsValid( ent ) ) then return end // Check whether we successfully made an entity, if not - bail
    ent:SetPos( position - Vector(0,0,15) )
    ent:Spawn()
    for k,v in pairs(player.GetAll()) do if ent:Visible(v) then flashply(v) end end
    for i = 40, 100, 1 do
        timer.Simple(1 / i, function()
            local effectdata = EffectData()
            effectdata:SetStart(position)
            effectdata:SetOrigin(position)
            effectdata:SetScale(1)
            effectdata:SetMagnitude(1)
            effectdata:SetScale(3)
            effectdata:SetRadius(2)
            effectdata:SetEntity(ent)
            util.Effect("TeslaHitBoxes", effectdatat, true, true)
        end)
    end
    return ent
end

-- npc/strider/charging.wav
function DramaticNPCSpawn(npc, position)
    sound.Play("npc/strider/charging.wav", position)
    local effectdata = EffectData() 
    effectdata:SetOrigin( position )
    util.Effect( "dc_portal_implode", effectdata )
    timer.Simple(1.254, function()
        local ent = SpawnXenFlashNPC(npc,position)
        sound.Play("ambient/levels/citadel/portal_beam_shoot1.wav", position)
        local neweffect = EffectData() 
        neweffect:SetOrigin( position ) 
        util.Effect( "dc_portal_explode", neweffect )
        effectdata:SetOrigin( position ) 
        util.Effect( "dc_teleport_in", effectdata )
        --timer.Simple(.5, function() ParticleEffectAttach("portal_seq_main",PATTACH_ABSORIGIN,ent,0) end)
        return ent
    end)
end