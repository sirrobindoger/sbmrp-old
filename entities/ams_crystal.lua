AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "ai"
ENT.PrintName = "AMS Crystal"
ENT.Author = "Sirro"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( 'Bool', 0, 'HoldingCrystal' )
	self:NetworkVar('Entity',0,"Crystal")
end

--[[-------------------------------------------------------------------------
Placeholder for next restart

---------------------------------------------------------------------------]]

if SERVER then
	function ENT:Initialize(  )

		self:SetHoldingCrystal( false )

		self:SetModel( "models/props_am/crystal_cart.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:DropToFloor(  )
	end

	function ENT:Touch(ent)
		-- 36.97 -4.62 32.79
		if not self:GetHoldingCrystal() and ent:GetModel() == "models/props_am/xencrystal.mdl" then
			ent:SetPos(self:LocalToWorld(Vector(36.97, -4.62, 32.79)))
			ent:SetParent(self)
			ent:SetAngles(Angle(-0.000, -135.000, 0.000))
			self:SetHoldingCrystal(true)
			self:SetCrystal(ent)
			self:EmitSound("^phx/EpicMetal_Soft1.wav")
			player.GetSirro():ChatPrint("Successfully attached the crystal to the cart.")
		end
	end
	function ENT:Use(activator)
		if activator:IsSirro() then
			player.GetSirro():ChatPrint("Successfully detached the crystal to the cart.")
			self:GetCrystal():SetParent(nil)
			self:EmitSound("buttons/lever6.wav")
			self:SetCrystal(nil)
			self:SetHoldingCrystal(false)
		end
	end
end