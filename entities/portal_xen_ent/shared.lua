ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Entrance Portal"
ENT.Author			= "Creed"
ENT.Contact			= "Don't"
ENT.Purpose			= "Beta Testing"
ENT.Instructions	= "Use with care. Always handle with gloves."
ENT.Model 			= ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Blacklist = {}
ENT.Destination = {}
ENT.AlienDestination = {}
ENT.Size = 15
ENT.AlienBlockMsg = "You are not allowed to use this portal, as a staff event is not taking place."
ENT.DestinationGravity = 1


ENT.TeleportSounds = {"ambient/machines/teleport1.wav","ambient/machines/teleport3.wav","ambient/machines/teleport4.wav"}
function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "PlayersOnly")
	self:NetworkVar("Bool", 1, "HumanOrEventOnly")
	self:NetworkVar("Bool", 2, "SafeMode")
	self:NetworkVar("Bool", 3, "TeleSound")
	self:NetworkVar("String", 0, "ArrivalText")
end