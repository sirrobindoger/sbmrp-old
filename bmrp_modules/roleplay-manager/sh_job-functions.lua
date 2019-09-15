--[[-------------------------------------------------------------------------
Varible Declaration
---------------------------------------------------------------------------]]
sBMRP.AllowXenToEarth = false
sBMRP.AllowEarthToXen = false
sBMRP.AllowHECUToBMRF = false
sBMRP.AntiRDM = true

local ply = FindMetaTable("Player")
local ent = FindMetaTable( "Entity" )

--[[-------------------------------------------------------------------------
sBMRP Job Info func's
---------------------------------------------------------------------------]]

function ply:CanHurt(ent)
	local damageoverride = hook.Run("AntiRDMOverride", self, ent)
	-- If the target is not marked "anything can hurt this target", and (the ply in questions is marked "cannot give damage" or the rdmgroup of the target and ply are the same)
	if not(ent:getJobTable()["rdmnoblockingdamage"]) and (self:getJobTable()["rdmnogivingdamage"] or self:getJobTable()["rdmgroup"] == ent:getJobTable()["rdmgroup"]) and sBMRP.AntiRDM and damageoverride != true then
		return false --Say no, we cannot hurt this ent
	else
		return true --Otherwise fuck it yeah damage it
	end
end

function ply:IsAlien()
	if (self:getJobTable()["isalien"]) then --We need to build a wall
		return true
	else return false end
end

function ply:IsBlackMesa()
	if (self:getJobTable()["isblackmesa"]) then
		return true
	else return false end
end

function ply:IsScience()	
	if ( self:getJobTable()["isscience"]) then 
		return true
	else return false end
end

function ply:IsBio()
	if (self:getJobTable()["isbio"]) then
		return true
	else return false end
end

function ply:IsService()
	if (self:getJobTable() and self:getJobTable()["isservice"]) then
		return true
	else return false end
end

function ply:IsSecurity()
	if (self:getJobTable()["issecurity"]) then
		return true
	else return false end
end

function ply:IsHECU()
	if (self:getJobTable()["ishecu"]) then
		return true
	else return false end
end

function ply:IsSubject()
	if(self:getJobTable()["issubject"]) then
		return true
	else return false end
end

function ply:IsSurvey()
	if (self:getJobTable()["issurvey"]) then
		return true
	else return false end
end

function ply:IsPill()
	if(self:getJobTable()["ispill"]) then
		return true
	else return false end
end

function ply:HasHEV()
	for k,v in pairs({"models/jheviv/jhevmk4.mdl"}) do
		if (self:GetModel() == v) then
			return true
		end
	end
	return false
end


--[[-------------------------------------------------------------------------
Pill functions 
---------------------------------------------------------------------------]]

function ply:JobPill(pill)
	if not (pk_pills or self.PillActive) and (not self:Alive()) then return end
	self:SetNWBool("InPill", true)
	pk_pills.apply(self, pill, "lock-life")
end





--[[-------------------------------------------------------------------------
Retreive job functions
---------------------------------------------------------------------------]]

function player.GetHECU()
	local ply = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsHECU() then
			table.insert(ply, v)
		end
	end
	return ply
end

function player.GetAlien()
	local ply = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsAlien() then
			table.insert(ply, v)
		end
	end
	return ply
end

function player.GetSecurity()
	local ply = {}
	for k,v in pairs(player.GetAll()) do
		if v:IsSecurity() then
			table.insert(ply, v)
		end
	end
	return ply
end

--[[-------------------------------------------------------------------------
Functions to check if x player is allowed at x location
---------------------------------------------------------------------------]]
function ply:IsAllowedXen()
	return self:IsAlien() or self:HasHEV() or self:GetNWBool("XenAllowed") or sBMRP.AllowXenToEarth 
end

function ply:IsAllowedEarth()
	return not self:IsAlien() or self:GetNWBool("EarthAllowed") or sBMRP.AllowEarthToXen 
end

function ply:IsAllowedBMRF()
	return not self:IsHECU() or sBMRP.AllowHECUToBMRF or self:GetNWBool("IsAllowedBMRF")
end

--[[-------------------------------------------------------------------------
Functions to allow/disallow a spesific player to x location
---------------------------------------------------------------------------]]

function ply:AllowToXen(bool)

	if bool then
		self:SetNWBool("XenAllowed", true)
	else
		self:SetNWBool("XenAllowed", false)
	end
end

function ply:AllowToEarth(bool)

	if bool then
		self:SetNWBool("EarthAllowed", true)
	else
		self:SetNWBool("EarthAllowed", false)
	end
end

function ply:AllowToBMRF(bool)

	if bool then
		self:SetNWBool("IsAllowedBMRF", true)
	else
		self:SetNWBool("IsAllowedBMRF", false)
	end
end

--[[-------------------------------------------------------------------------
Functions to allow EVERYONE's permission to x location.
---------------------------------------------------------------------------]]

function sBMRP.ToXenAllowAll(bool)
	if bool then
		sBMRP.AllowXenToEarth = true
		Log("Allowed all Earth players access rights to xen!")
	else
		Log("Set all Earth players access rights to xen to its default value!")
		sBMRP.AllowXenToEarth = false
	end
end

function sBMRP.HECUAllowAll(bool)
	if bool then
		Log("Allowed all HECU's players access rights to BMRF!")
		sBMRP.AllowHECUToBMRF = true
	else
		Log("Set all HECU players access rights to BMRF to its default value!")
		sBMRP.AllowHECUToBMRF = false
	end	
end

function sBMRP.ToEarthAllowAll(bool)
	if bool then
		Log("Allowed all Xenian's players access rights to Earth!")
		sBMRP.AllowEarthToXen = true
	else
		Log("Set all Xenain players access rights to Earth to its default value!")
		sBMRP.AllowEarthToXen = false
	end
end

--[[-------------------------------------------------------------------------
Security Suitup
---------------------------------------------------------------------------]]
function SuitUp( ply, args)
	if (ply:IsSecurity() and ply:Team() != TEAM_ADMINISTRATOR) then

		ply:SetArmor(100)
		ply:EmitSound("npc/combine_soldier/gear2.wav")
		ply:EmitSound("npc/combine_soldier/zipline_clothing1.wav")
		ply:EmitSound("npc/metropolice/vo/on1.wav")
		ply:Give( "stunstick" )
		ply:Give("bkeycard")
		ply:Give("itemstore_pickup")
		ply:Give( "weaponchecker" )
		ply:Give( "weapon_cuff_default" )
		ply:Give( "weapon_leash_default" )
		ply:Give( "swep_radiodevice")
		--ply:Give( "arrest_stick" )
		ply:Give( "weapon_baton" )
		if ply:Team() != TEAM_SECURITYRECRUIT then
			ply:Give( "arrest_stick" )
		end
		sBMRP.ChatNotify({ply}, "Info", "You have put on your vest and are now on-duty.")	
	end
	return ""
end


function SuitDown(ply)
	if (ply:IsSecurity() and ply:Team() != TEAM_ADMINISTRATOR) then
		ply:SetArmor(0)
		ply:StripWeapons()
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:Give( "weapon_physgun" )
		ply:Give("bkeycard")
		ply:Give( "keys" )
		ply:Give( "weapon_physcannon" )
		ply:EmitSound("npc/combine_soldier/zipline_clothing1.wav")
		ply:EmitSound("npc/metropolice/vo/off2.wav")
		ply:SetModel("models/player/office1/male_08.mdl")
		sBMRP.ChatNotify({ply}, "Info", "You have removed your vest and are now off duty.")
	end
end

--[[-------------------------------------------------------------------------
Tazer
---------------------------------------------------------------------------]]

function Taze(ent,mode)
	if ent:IsPlayer() or ent:IsBot() then
		if ent:GetNWBool("IsBeingTased!") then return end
		ent:SetNWBool("IsBeingTased!", true)
		ent:ViewPunch( Angle(-10, 0, 0))
		if(false) then
			ent:DropWeapon(ent:GetActiveWeapon())
		end
		ent:DrawViewModel(false)
		
		local weps = {}
		for u, l in pairs(ent:GetWeapons()) do
			table.insert(weps,l:GetClass())
		end
		
		ent.Weps = weps
		local weapon = ent:GetActiveWeapon()
		if weapon:IsValid() then
			ent.LastWeap = weapon:GetClass()
		end
		ent:StripWeapons(weps)
		ent.Armor = ent:Armor()
		local ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetPos(ent:GetPos())
		ragdoll:SetAngles(ent:GetAngles())
		ragdoll:SetModel(ent:GetModel())
		ragdoll:SetVelocity(ent:GetVelocity())
		ragdoll:Spawn()
		ragdoll.IsTased = true
		ragdoll.TaseOwner = ent
		ragdoll:Activate()
		ragdoll:EmitSound("ambient/energy/spark5.mp3")
		
		local effectdata = EffectData()
		effectdata:SetOrigin( ragdoll:GetPos() )
		util.Effect( "cball_explode", effectdata )
		ent:SetParent(ragdoll)
		ent:ScreenFade(SCREENFADE.IN, Color(230, 230, 230), 0.7, 1.4)
		ent:Spectate(OBS_MODE_CHASE)
		ent:SpectateEntity(ragdoll)
		if mode == "testsubject" then
			local head = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_Pelvis" ) ) )
			if timer.Exists("TaserJolt_"..ent:UniqueID()) then timer.Destroy("TaserJolt_"..ent:UniqueID()) end		
			head:ApplyForceCenter( Vector(0,0,1000) )
			timer.Create("TaserJolt_"..ent:UniqueID(), 0.01, 100, function ()
				--local x = math.max(1000,math.min(3000,(3000 * math.rand(-1,1))))
				--local y = math.max(1000,math.min(3000,(3000 * math.rand(-1,1))))
				local x = 1000*(math.Round(math.random(-1,1)))
				local y = 1000*(math.Round(math.random(-1,1)))
				--local z = 500*(math.Round(math.random(-1,1)))
				head:ApplyForceCenter( Vector(x,y,-1500) )--* math.Rand( -5, 5 ) )
			end)
		else
			local head = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_Head1" ) ) )
			local spine = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_Spine1" ) ) )
			local pelvis = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_Pelvis" ) ) )
			local lhand = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_L_Hand" ) ) )
			local rhand = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_R_Hand" ) ) )
			local lfoot = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_L_Foot" ) ) )
			local rfoot = ragdoll:GetPhysicsObjectNum( ragdoll:TranslateBoneToPhysBone( ragdoll:LookupBone( "ValveBiped.Bip01_R_Foot" ) ) )
			if timer.Exists("TaserJolt_"..ent:SteamID()) then timer.Destroy("TaserJolt_"..ent:SteamID()) end		
			pelvis:ApplyForceCenter( Vector(0,0,-2000) )
			timer.Create("TaserJolt_"..ent:SteamID(), 0.01, 50, function ()
				--local x = math.max(1000,math.min(3000,(3000 * math.rand(-1,1))))
				--local y = math.max(1000,math.min(3000,(3000 * math.rand(-1,1))))
				local x = 150*(math.Round(math.random(-1,1)))
				local y = 150*(math.Round(math.random(-1,1)))
				--local z = 500*(math.Round(math.random(-1,1)))
				pelvis:ApplyForceCenter( Vector(0,0,-2000) )
				lhand:ApplyForceCenter( Vector(x*-1,y*-1,0) )--* math.Rand( -5, 5 ) )
				rhand:ApplyForceCenter( Vector(x,y,0) )--* math.Rand( -5, 5 ) )				
				rfoot:ApplyForceCenter( Vector(x*-1,y*-1,0) )--* math.Rand( -5, 5 ) )				
				lfoot:ApplyForceCenter( Vector(x,y,0) )--* math.Rand( -5, 5 ) )
				head:ApplyForceCenter( Vector(x/2,y/2,-1000) )--* math.Rand( -5, 5 ) )
				spine:ApplyForceCenter( Vector(0,0,-1000) )--* math.Rand( -5, 5 ) )
			end)
		end		
		if timer.Exists("TaserTimer_"..ent:UniqueID()) then timer.Destroy("TaserTimer_"..ent:UniqueID()) end
		timer.Create("TaserTimer_"..ent:UniqueID(), 8, 1, function ()
			ent:SetNWBool("IsBeingTased!",false)
			ent:UnSpectate()
			ent:SetParent()
			ent:Spawn()
			local pos = ragdoll:GetPos()
			ent:SetPos(pos)
			ent:SetModel(ragdoll:GetModel())
			ragdoll:Remove()
			ent:DrawViewModel(true)
			ent:SetPos(DarkRP.findEmptyPos(pos, {ent}, 600, 10, Vector(0, 0, 30)))
			if mode == "testsubject" then
				ent:KillSilent()
			end
			ent:SetNWBool("IsBeingTased!", false)
			for i=1, #ent.Weps do
				ent:Give(ent.Weps[i])
			end
		end)
	end
end


--[[-------------------------------------------------------------------------
Facility Administrator functions
---------------------------------------------------------------------------]]
if CLIENT then 
	concommand.Add("TestAdminMenu", function(ply)
		if not ply:IsSirro() then return end
		if AdminMenu then AdminMenu:Close() print("Yes Fuick") end
		AdminMenu = vgui.Create("DFrame")
		print(ScrH().."\n"..ScrW())
		AdminMenu:SetSize(500,500)
		AdminMenu:Center()
		AdminMenu:SetTitle("")
		AdminMenu:ShowCloseButton(true)

		function AdminMenu:OnClose()
			AdminMenu = nil

		end	

	end)
end

