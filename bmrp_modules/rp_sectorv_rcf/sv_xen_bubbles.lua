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
    util.Effect( "cball_explode", effectdata )
    util.Effect("Sparks",effectdata)
    for i = 40, 100, 1 do
        timer.Simple(1 / i, function()
            util.Effect("TeslaHitBoxes", effectdatat, true, true)
        end)
    end
end

function SpawnXenFlashNPC(position, NPCClass)
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
            util.Effect("TeslaHitBoxes", effectdatat, true, true)
        end)
    end
    return ent
end