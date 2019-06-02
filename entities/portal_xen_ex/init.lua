AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
function ENT:Initialize()
	self:SetModel( self.Model)
	self:RebuildPhysics()
	timer.Simple(0.02, function() self:SetPos(self:GetPos()+Vector(0,0,40)) end)
end
function ENT:RebuildPhysics( value )

	-- This is necessary so that the vphysics.dll will not crash when attaching constraints to the new PhysObj after old one was destroyed
	-- TODO: Somehow figure out why it happens and/or move this code/fix to the constraint library
	self.ConstraintSystem = nil
	
	self:PhysicsInitBox( Vector( -self.Size, -self.Size, -self.Size), Vector( self.Size, self.Size, self.Size ) )
	self:SetCollisionBounds( Vector( -self.Size, -self.Size, -self.Size ), Vector( self.Size, self.Size, self.Size ) )
	
	self:SetMoveType(8)
	self:SetCollisionGroup(20)
end