--[[-------------------------------------------------------------------------
Varible Declaration
---------------------------------------------------------------------------]]
if SERVER then -- values for server only
	sBMRP.AllowXenToEarth = false
	sBMRP.AllowEarthToXen = false
	sBMRP.AllowHECUToBMRF = false
	sBMRP.AntiRDM = true
end
local ply = FindMetaTable("Player")
local ent = FindMetaTable( "Entity" )

--[[-------------------------------------------------------------------------
sBMRP Job Info func's
---------------------------------------------------------------------------]]
-- shared code
function ply:CanHurt(ent)
	-- If the target is not marked "anything can hurt this target", and (the ply in questions is marked "cannot give damage" or the rdmgroup of the target and ply are the same)
	if not(ent:getJobTable()["rdmnoblockingdamage"]) and (self:getJobTable()["rdmnogivingdamage"] or self:getJobTable()["rdmgroup"] == ent:getJobTable()["rdmgroup"]) and sBMRP.AntiRDM then
		return false --Say no, we cannot hurt this ent
	else 
		return true --Otherwise fuck it yeah damage it
	end 
end

function ply:IsAlien()
	if(self:getJobTable()["isalien"]) then --We need to build a wall
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
if SERVER then
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
		if ply:IsAlien() then
			Log("Trying to override " .. ply:GetName() .. "/" .. ply:Team() .. "'s xen permissions when they are a xenian!")
			return
		end
		if bool then
			self:SetNWBool("XenAllowed", true)
		else
			self:SetNWBool("XenAllowed", false)
		end
	end

	function ply:AllowToEarth(bool)
		if not ply:IsAlien() then
			Log("Trying to override " .. ply:GetName() .. "/" .. ply:Team() .. "'s earth permissions when they aren't a xenian!")
			return
		end
		if bool then
			self:SetNWBool("EarthAllowed", true)
		else
			self:SetNWBool("EarthAllowed", false)
		end
	end

	function ply:AllowToBMRF(bool)
		if not ply:IsHECU() then
			Log("Trying to override " .. ply:GetName() .. "/" .. ply:Team() .. "'s BMRF permissions when they aren't a HECU!")
			return
		end
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
			DarkRP.notify(ply, 7, 3, "You have put on your vest and are now on-duty.")	
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
			DarkRP.notify(ply, 6, 3, "You have taken off your vest and are now off-duty.")
		end
	end
end