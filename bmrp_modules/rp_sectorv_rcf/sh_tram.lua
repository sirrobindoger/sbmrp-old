--[[-------------------------------------------------------------------------
TRAM Altercations
---------------------------------------------------------------------------]]
if SERVER then

    sBMRP.Tram =  ents.GetMapCreatedEntity(2215)
	num = 1
	goodsounds = table.ValuesToKeys({
	"bmtram/ttrain_start1.wav", 
	"bmtram/ttrain1.wav", 
	"bmtram/ttrain_brake1.wav", 
	"plats/bigmove2.wav", 
	"plats/ttrain_start1.wav", 
	"ambient/machines/wall_ambient1.wav",
	"npc/scanner/cbot_energyexplosion1.wav", 
	"npc/attack_helicopter/aheli_charge_up.wav",
	"ambient/machines/zap3.wav",
	"npc/dog/dog_straining1.wav",
	"npc/scanner/scanner_explode_crash2.wav", 
	})
	creedsoundsreg = {"6","7","8","13","14","15","16","17","18","19","20","21","22","23","24","25"}
	creedsoundsbroken = {"9","10","11","12"}
	currentlist = creedsoundsreg
	hook.Add("EntityEmitSound", "bmrp_tram", function(data)
	    ent = data.Entity
	    if not IsValid(ent) then return end
	    if (ent:MapCreationID() == 2215) then
            if sBMRP.TramBroken then print("FUCK") return false end
	        if sBMRP.Disaster then
				currentlist = creedsoundsbroken
			else
				currentlist = creedsoundsreg
			end
			if num >= #currentlist then
	            num = 1
	        end
	        if not string.find(data.SoundName,"creed_") then
	               if goodsounds[data.SoundName] then
	                return nil
	            else
                    --if timer.Exists("creed_Tram-antispam") then return false end
	                num = num + 1
	                creedstring = "creed_tram" .. currentlist[num] .. ".mp3"
	                data.SoundName = creedstring
                    --local tramsound = CreateSound( sBMRP.Tram, creedstring)
                   -- tramsound:SetDSP(57)
                    --tramsound:SetSoundLevel(data.SoundLevel)
                    --tramsound:ChangeVolume(data.Volume)
                    --tramsound:ChangePitch(data.Pitch)
                    --tramsound:Play()
                    --timer.Create("creed_Tram-antispam", 1, 1, function() end)
	                return true
	            end
	        end
	     end
	end)



    function createtram()
        local ent = ents.Create("prop_physics")
        ent:SetPos(util.StringToType("-6596.82 -3796.50 -83.22", "Vector"))
        ent:SetAngles(util.StringToType("0 0 0", "Angle"))
        ent:SetModel("models/props/propshl3/tramsupport00.mdl")
        ent:SetName("cTramArm")
        ent:SetMoveType(MOVETYPE_NONE)
        ent:Spawn()
        ent:GetPhysicsObject():EnableMotion(false)

        local ent = ents.Create("prop_physics")
        ent:SetPos(util.StringToType("-6600.84 -3795.70 -260.03", "Vector"))
        ent:SetAngles(util.StringToType("0 90 0", "Angle"))
        ent:SetModel("models/props/hl20props/c0a0etram.mdl")
        ent:SetName("cTram")
        ent:SetMoveType(MOVETYPE_NONE)
        ent:Spawn()
        ent:GetPhysicsObject():EnableMotion(false)


        
        sBMRP.BrokeTram = ents.FindByName("cTram")[1]
        sBMRP.BrokeTramArm = ents.FindByName("cTramArm")[1]
        sBMRP.BrokeTramArm:LerpToVector(Vector(-6350.82, -3796.50, -83.22),2)
        sBMRP.BrokeTram:LerpToVector(Vector(-6350.84, -3795.70, -260.03), 2)
        SetGlobalEntity("cTram", sBMRP.BrokeTram)
        timer.Create("tram_broken-vox", 34, 0, function()
            SetGlobalEntity("cTram", sBMRP.BrokeTram)
            sBMRP.BrokeTram:EmitSound("creed-tram-broken")
        end)
    end

    hook.Add("InitPostEntity", "tram-startup", createtram)
    hook.Add("PostCleanupMap", "tram-loop", createtram)
    --[[-------------------------------------------------------------------------
    sounds
    ---------------------------------------------------------------------------]]
    sound.Add({
        name = "creed-tram-broken",
        channel = CHAN_STATIC,
        volume = .8,
        level = 65,
        pitch = {100},
        sound = "tram_burn_2.mp3"
    })

    --[[-------------------------------------------------------------------------
    impact sounds:
    physics/metal/metal_sheet_impact_hard8.wav (8-6)
    vehicles/v8/vehicle_impact_heavy3.wav
    ambient/materials/metal_big_impact_scrape1.wav
    physics/metal/metal_sheet_impact_hard8.wav

    vehicles/v8/v8_turbo_on_loop1.wav
    ---------------------------------------------------------------------------]]
    hook.Add("LerpMovementEnded", "tram_slam-loop", function(ent)
        if not IsValid(sBMRP.BrokeTramArm) or not IsValid( sBMRP.BrokeTram) then return end
        if ent:GetPos():Round() == Vector(-6350.84, -3795.70, -260.03):Round() then

            sBMRP.BrokeTramArm:LerpToVector(Vector(-6400.82, -3796.50, -83.22), 3)
            sBMRP.BrokeTram:LerpToVector(Vector(-6400.84, -3795.70, -260.03), 3)
        elseif ent:GetPos():Round() == Vector(-6400.84, -3795.70, -260.03):Round() then
            sBMRP.BrokeTramArm:LerpToVector(Vector(-6400.82, -3796.50, -83.22), 1.7)
            sBMRP.BrokeTram:LerpToVector(Vector(-6400.84, -3795.70, -260.03), 1.7)
            timer.Simple(.2, function()
                sBMRP.BrokeTramArm:LerpToVector(Vector(-6350.82, -3796.50, -83.22),6)
                sBMRP.BrokeTram:LerpToVector(Vector(-6350.84, -3795.70, -260.03), 6)
            end)
            timer.Simple(.3, function()
                ent:EmitSound(string.format("physics/metal/metal_sheet_impact_hard8.wav", math.random(6,8)),85,math.random(80,100),.5)
                ent:EmitSound(string.format("ambient/materials/metal_big_impact_scrape1.wav", math.random(6,8)),85,math.random(80,100),.2)

            end)
        end
    end)
    

    --[[
    local function lerptramtest(ply, args)
        if not ply:IsSirro() then return end
        if args[1] == "1" then
            ply:ChatPrint("Args 1")
            sBMRP.BrokeTramArm:LerpToVector(Vector(-6350.82, -3796.50, -83.22),2)
            sBMRP.BrokeTram:LerpToVector(Vector(-6350.84, -3795.70, -260.03), 2)
        else
            ply:ChatPrint("Setting back to position")
            sBMRP.BrokeTramArm:LerpToVector(Vector(-6400.82, -3796.50, -83.22), 5)
            sBMRP.BrokeTram:LerpToVector(Vector(-6400.84, -3795.70, -260.03), 5)
        end
    end
    sBMRP.RemoveChatCommand("lerp")
    sBMRP.CreateChatCommand("lerp", lerptramtest)
    ]]--
end


if CLIENT then
    local function setupbroketram()
        
    	hook.Add( "Think", "Think_Lights!", function()
            sBMRP.BrokeTram = GetGlobalEntity("cTram")
            if !IsValid(sBMRP.BrokeTram) or GetLocation(LocalPlayer()) != "Sector D Tram Station" then return end
    		local vec = sBMRP.BrokeTram:GetPos()
    		local dlight = DynamicLight( sBMRP.BrokeTram )
    		if ( dlight ) then
    			dlight.pos = Vector(vec.x-10, vec.y-20, vec.z+80)
    			dlight.r = 255
    			dlight.g = 255
    			dlight.b = 255
    			dlight.dir = Vector(0, 180, 0)
    			dlight.brightness = 3
    			dlight.Decay = 1000
    			dlight.Size = 128
    			dlight.style = 2
    			dlight.DieTime = CurTime() + 1
    		end
    	end )
    end
    hook.Add("InitPostEntity", "tram-startup", setupbroketram)
    hook.Add("PostCleanupMap", "tram-loop", setupbroketram)
end
