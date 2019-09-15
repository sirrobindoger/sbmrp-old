AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "ToucherEnt"
ENT.Author = "Sirro"
ENT.Spawnable = true
ENT.AdminSpawnable = false


if SERVER then

	function ENT:Touch( ent )
		hook.Run("TriggerEntTouch",self, ent)
	end
end