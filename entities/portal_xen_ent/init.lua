AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
function ENT:Initialize()
	self:SetSafeMode(true)
	self.Destination = {{Vector(-13098.798828125,-843.54486083984,-320.14852905273),Angle(0,0,0)}}
	self:SetHumanOrEventOnly(false)
	self:SetTeleSound(true)
	self:ObjInit()
end
function ENT:ObjInit()
	self:SetModel( self.Model)
	self:RebuildPhysics()
	timer.Simple(0.02, function() self:SetPos(self:GetPos()+Vector(0,0,40)) end)
	self:SetTrigger(true)
	self:SetCollisionGroup(20)
end
function ENT:RebuildPhysics( value )

	-- This is necessary so that the vphysics.dll will not crash when attaching constraints to the new PhysObj after old one was destroyed
	-- TODO: Somehow figure out why it happens and/or move this code/fix to the constraint library
	self.ConstraintSystem = nil
	
	self:PhysicsInitBox( Vector( -self.Size, -self.Size, -self.Size), Vector( self.Size, self.Size, self.Size ) )
	self:SetCollisionBounds( Vector( -self.Size, -self.Size, -self.Size ), Vector( self.Size, self.Size, self.Size ) )
	
	self:SetMoveType(8)
end
function ENT:StartTouch(ent)
	if self:GetPlayersOnly() and not(ent:IsPlayer()) then return end
	if self:GetSafeMode() and (ent:GetClass() == "physgun_beam" or ent:GetClass() =="sammyservers_textscreen" or ent:IsWorld() or ent:GetClass() == "prop_dynamic" or ent:IsConstrained() or ent:MapCreationID() != -1) then return end
	if table.HasValue(self.Blacklist,ent:GetModel()) or table.HasValue(self.Blacklist,ent:GetClass()) then return end
	if self:GetHumanOrEventOnly() and ent:IsPlayer() and ent:IsAlien() and not ent:IsAllowedEarth() then sBMRP.ChatNotify({ent}, "Error",self.AlienBlockMsg) return end
	
	if self:GetTeleSound() then 
		local telesound = self.TeleportSounds[math.random(1,#self.TeleportSounds )]
		ent:EmitSound(telesound) 
		timer.Simple(0.1,function() self:EmitSound(telesound) end)
	end
	local dest = self.Destination[ math.random( #self.Destination ) ]
	if (ent:IsPlayer() and ent:IsAlien()) and (table.Count(self.AlienDestination) > 0) then
		dest = self.AlienDestination[ math.random( #self.AlienDestination ) ]
	end
	ent:SetPos(dest[1])
	if ent:IsPlayer() then
		SpawnXenFlash(ent:GetPos())
		ent:SetGravity(self.DestinationGravity)
		ent:SetEyeAngles(dest[2])
		if self:GetArrivalText() != "" then
			sBMRP.ChatNotify({ent}, "Info",self:GetArrivalText())
		end
	end
end