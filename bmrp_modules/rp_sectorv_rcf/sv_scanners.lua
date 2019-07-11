--[[-------------------------------------------------------------------------
Retinal scanner processing
---------------------------------------------------------------------------]]

local sciencedoors = {
	[2207] = true, -- amsdoor 1
	[2213] = true, -- amsdoor 2
	[2227] = true, -- ams chamber door
	[3502] = true, -- ams observ door 1
	[3511] = true, -- ams observ door 2
	[2220] = true, -- sectorc ams
	[4561] = true, -- sectora portal

}

local blackmesadoors = {
	[1935] = true, -- sectorc airlock
	[1949] = true, -- sectorc airlock 2
	[1944] = true, -- sectora airlock 1
	[1938] = true, -- sectora airlock 2
	[2247] = true, -- sectora enterence
	[2281] = true, -- Black Mesa Lobby
	[2327] = true, -- BLack Mesa Lobby 1
	[3839] = true, -- topside lift
}

local securitydoors = {
	[2233] = true, -- sectorb enterance
	[3269] = true, -- sectorb enterance 1
}

local hecudoors = {
	[3003] = true, -- base enterance
}

local healthchargers = {
	[3075] = true,
	[3079] = true,
	[3266] = true,
	[1823] = true,
	[3084] = true
}

local function scanner(ply, ent)
	if !IsFirstTimePredicted() then return end
	local Team = ply:Team()
	local name = ent:GetName()
	local mapid = ent:MapCreationID()
    
	if ply.antispam_use == nil or ply.antispam_use == 0 then -- cBMRP antispam code
		ply.antispam_use = 1
		timer.Destroy("gm_"..ply:SteamID().."_antispam_use")
		timer.Create("gm_"..ply:SteamID().."_antispam_use", 0.25, 1, function()
			ply.antispam_use = 0
		end )
	elseif ply.antispam_use == 1 then
		timer.Destroy("gm_"..ply:SteamID().."_antispam_use")
		timer.Create( "gm_"..ply:SteamID().."_antispam_use", 0.25, 1, function()
			ply.antispam_use = 0
		end )
		return false
	end
	if sciencedoors[mapid] then
		if not ply:IsScience() and not ply:IsService() and not ply:IsSecurity() and not ply:IsAdmin() then
			ent:EmitSound("vox/access.wav", 45, 100)
			ent:EmitSound("buttons/button2.wav", 80, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ent:EmitSound("vox/denied.wav", 45, 100)
			end )
			return false
		end
	elseif blackmesadoors[mapid] then
		if not ply:IsBlackMesa() then
			if ply:IsHECU() and sBMRP.AllowHECUToBMRF and not ply:IsAdmin() then return end
			ent:EmitSound("vox/access.wav", 45, 100)
			ent:EmitSound("buttons/button2.wav", 80, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ent:EmitSound("vox/denied.wav", 45, 100)
			end )
			return false			
		end
	elseif securitydoors[mapid] then
		if not ply:IsSecurity() and not ply:IsAdmin() then
			ent:EmitSound("vox/access.wav", 45, 100)
			ent:EmitSound("buttons/button2.wav", 80, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ent:EmitSound("vox/denied.wav", 45, 100)
			end )
			return false				
		end
	elseif hecudoors[mapid] then
		if not ply:IsHECU() and not ply:IsAdmin() then
			ent:EmitSound("vox/access.wav", 45, 100)
			ent:EmitSound("buttons/button2.wav", 80, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ent:EmitSound("vox/denied.wav", 45, 100)
			end )
			return false			
		end
	elseif name == "biosector-door" then	
		
		if not ply:IsBio() and not ply:IsAdmin() then
			ply:EmitSound("vox/access.wav", 35, 100)
			ply:EmitSound("buttons/button2.wav", 45, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ply:EmitSound("vox/denied.wav", 35, 100)
			end )
			return false
		end
		for k,v in pairs({1912, 1913}) do		
			EntID(v):Fire("Unlock")
			EntID(v):Fire("Open")
			timer.Simple(1, function() EntID(v):Fire("Lock") end)
		end
	elseif name == "hecu-door" then
		if not ply:IsHECU() and not ply:IsAdmin() then
			ply:EmitSound("vox/access.wav", 35, 100)
			ply:EmitSound("buttons/button2.wav", 45, 100)
			timer.Create( "VoxDeny2", 0.8, 1, function()
				ply:EmitSound("vox/denied.wav", 35, 100)
			end )
			return false
		end
		ent:EmitSound("buttons/button5.wav", 75)
		for k,v in pairs({2990}) do		
			EntID(v):Fire("Unlock")
			EntID(v):Fire("Open")
		end
	elseif mapid == 1930 then
		if Team != TEAM_BIO_HEAD and not ply:IsAdmin() then
			ply:EmitSound("buttons/button2.wav", 45, 100)
			return false
		end
	end


	if ent:GetClass() == "func_recharge" then
		if ply:HasHEV() then
			if ply:Armor() != 100 then
				ply:SetArmor(100)
				ent:EmitSound("items/suitchargeok1.wav")
				return true
			end
		else
			if (ply:IsHECU() or (ply:IsSecurity() and ply:Team() != TEAM_ADMINISTRATOR)) then
				if ply:Armor() != 100 then
					ply:SetArmor(100)
					ply:ChatPrint("*The machine dispenses a vest, you put it on.")
					ent:EmitSound("npc/combine_soldier/gear3.wav")
					return false
				else
					return false
				end
			else
				if antispam_hev == 0 then
					antispam_hev = 1
					timer.Create( "antispam_hev_0", 0.1, 1, function()
						ply:ChatPrint("Dispenser Display: [Error: No HEV suit detected.]")
						
						timer.Create( "antispam_hev_1", 3, 1, function()
							antispam_hev = 0
						end)
						
						ent:EmitSound("buttons/button2.wav", 80, 100)
						ent:EmitSound("hl1/fvox/hev_general_fail.wav", 80, 100)
					end)
				else 
					return false 
				end
			end
			return false 
		end
	end
	if ent:GetClass() == "func_healthcharger" then
		if ply:Health() != ply:GetMaxHealth() then
			ply:SetHealth(ply:GetMaxHealth())
			ent:EmitSound("items/smallmedkit1.wav")
			return true
		end
	end

end

hook.Add("PlayerUse", "bmrp-scanner-logic", scanner)
