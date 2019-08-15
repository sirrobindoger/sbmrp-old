AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/v_pistol.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" )

SWEP.Author                 = "Creed/JJl77"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 256
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "256"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Category =             "BMRP - Miscellaneous"

SWEP.PrintName	= "Taser"

SWEP.Slot		= 2
SWEP.SlotPos	= 1
SWEP.Base = "weapon_base"
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.Spawnable		= true

SWEP.ShootSound = Sound( "weapons/taser.wav" )

local duration = 15
local dmg = 0
local taser_distance = 256
local taser_firerate = 4.8
local screenfade = 1
local dropweapon = 1

function SWEP:Deploy()
	self.Weapon:EmitSound("weapons/physcannon/superphys_small_zap3.wav")
	local attachmentIndex = self.Owner:LookupAttachment("anim_attachment_RH")
	if self.Owner:GetAttachment(attachmentIndex) then
		self.WM = self.Owner
		self.WAttach = attachmentIndex
		self.pos = self.Owner:GetAttachment(attachmentIndex).Pos
	end
	local data = EffectData()
	data:SetOrigin(self.pos)
	data:SetMagnitude(0.2)
	data:SetScale(1)
	data:SetRadius(1.2)
	util.Effect("TeslaZap", data)
end
function SWEP:DoTaze(ent)
    if CLIENT then
        local trace = self.Owner:GetEyeTrace()
        local distance = 15
        local sparksize = 1
        if(IsFirstTimePredicted())then
            if(trace.StartPos:Distance(trace.HitPos) > taser_distance) then return end
            local data = EffectData()
            data:SetOrigin(trace.HitPos)
            data:SetNormal(trace.HitNormal)
            data:SetMagnitude(1.3)
            data:SetScale(sparksize)
            data:SetRadius(1.2)
            util.Effect("Sparks", data)
			util.ParticleTracer("LaserTracer", self.Owner:GetPos(), trace.HitPos, true)
        end
    end
	if CLIENT then return end

	ent:ExitVehicle()
	Taze(ent,"tazegun")
	--self:ShootEffect(effect or "vortigaunt_beam",self.Owner:EyePos(),trace.HitPos)
	self:SetNextPrimaryFire(CurTime() + taser_firerate)
    ent:EmitSound(Sound("npc/roller/mine/rmine_shockvehicle2.wav"))

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
	if self.ChargeSound then
		self.ChargeSound:Stop()
	end
	self.ChargeSound = CreateSound(self.Owner,"ambient/levels/labs/teleport_mechanism_windup4.wav")
	self.ChargeSound:Play()
	self.ChargeSound:ChangePitch(255,0)
	self.ChargeSound:ChangeVolume(0.1)
	timer.Simple(4.7, function()
		self.ChargeSound:Stop()
			self.Owner:EmitSound("weapons/physcannon/superphys_small_zap1.wav")
	end)
end
function SWEP:PrimaryAttack()
    local trace = self.Owner:GetEyeTrace()
    local ent = trace.Entity
	if IsValid(ent) and IsFirstTimePredicted() and SERVER then
		for k,v in pairs(ent:GetChildren()) do
			if v:IsVehicle() and v:GetDriver():IsPlayer() then
				ent = v
				break
			end
		end
		if ent:IsVehicle() and ent:GetDriver() != nil and ent:GetDriver():IsPlayer() then
			ent = ent:GetDriver()
		end
		
		if ent:IsPlayer() then
			if self.Owner:Team() == TEAM_BIO then
				if ent:Team() == TEAM_TESTSUBJECT or ent:IsAlien() then
					self:DoTaze(ent)
				end
			end
		end
	end
end
