AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Quest Dealer"
ENT.Author = "Sirro"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "npcName")
	self:NetworkVar("String", 1, "questerID")
	self:NetworkVar( 'Bool', 0, 'InUse' )
	self:NetworkVar('Entity',0,"PlayerUsing")
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

if SERVER then
	function ENT:Initialize(  )
		self:SetquesterID(#ents.FindByClass( 'freshcardealer' ))
		self:SetnpcName('Unnamed Quest NPC' )

		self:SetInUse( false )

		self:SetModel( 'models/decay/scientist_rosenberg.mdl' )
		self:SetHullType( HULL_HUMAN )
		self:SetHullSizeNormal(  )
		self:SetNPCState( NPC_STATE_SCRIPT )
		self:SetSolid( SOLID_BBOX )
		self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD )
		self:SetUseType( SIMPLE_USE )
		self:DropToFloor(  )
		self:SetMaxYawSpeed( 90 )
	end

	function ENT:AcceptInput( name, act, cal )
		if cal:IsPlayer() then
			if name == 'Use' then
				cal:Notify( "Test" )
			end
		end
	end
end