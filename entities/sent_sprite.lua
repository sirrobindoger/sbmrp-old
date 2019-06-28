--[[-------------------------------------------------------------------------
CREATED BY AXEL (https://steamcommunity.com/id/AxelSyverson)
---------------------------------------------------------------------------]]

AddCSLuaFile()
-- This is a fix for an unusual problem where sprites weren't animated on a Linux Server (probably because of sprites not mounting)
-- It works by recreating env_sprite in Lua to function mostly clientside

local r = debug.getregistry().IMaterial
--https://developer.valvesoftware.com/wiki/Valve_Texture_Format
--signature, version, headersize, width, height, flags
local headerpos = 4 + 8 + 4 + 2 + 2 + 4

function r:GetFrameCount()
	if self:IsError() or not self:GetTexture("$basetexture") then return 1 end
	local p = "materials/" .. self:GetTexture("$basetexture"):GetName() .. ".vtf"

	if not file.Exists(p, "GAME") then return 1 end

	local handle = file.Open(p, "rb", "GAME")
	if handle then
		local count
		handle:Seek(headerpos) --Signature
		count = handle:ReadShort()
		handle:Close()
		return count
	else
		return 1
	end
end

ENT.Type = "anim"
ENT.Spawnable = false
ENT.Author = "Axel"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CMaterial")
	self:NetworkVar("Int", 0, "Framerate")
	self:NetworkVar("Float", 0, "Scale")
	self:NetworkVar("Bool", 0, "Enabled")
	self:NetworkVar("Vector", 0, "SpriteColor")
	self:NetworkVar("Int", 1, "SpriteAlpha")
end

function ENT:Initialize()
	self:SetCMaterial(self:GetCMaterial() or "")
	self:SetFramerate(self:GetFramerate() or 0)
	self:SetScale(self:GetScale() or 1)
end

function ENT:DrawTranslucent()
	self:DrawShadow(false)
	if not self:GetEnabled() then return end

	if self.Material ~= (self:GetCMaterial() or "") and (not self.Material or self.Material:GetName() ~= self:GetCMaterial()) then
		if Material(self:GetCMaterial()):IsError() then self.Material = self:GetCMaterial() or "" end
		self.Material = CreateMaterial("spr_fixent_" .. self:GetCMaterial(), "UnlitGeneric", {
			["$basetexture"] = self:GetCMaterial(),
			["$nocull"] = 1,
			["$additive"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
		})
		if not self.Material or self.Material:IsError() then self.Material = self:GetCMaterial() or "" return end

		self.Frames = self.Material:GetFrameCount()
	end

	if not self.Material or self.Material:IsError() then return end
	self.Frame = self.Frame or 0
	self.Frametime = self.Frametime or CurTime() + 1 / self:GetFramerate()
	if self.Frametime < CurTime() then
		self.Frame = (self.Frame + 1) % (self.Frames or 1)
		self.Material:SetInt("$frame", self.Frame)
		self.Frametime = CurTime() + 1 / self:GetFramerate()
	end
	render.SetMaterial(self.Material)
	local color = self:GetSpriteColor():ToColor()
	color.a = self:GetSpriteAlpha()

	if not self.PixVis then self.PixVis = util.GetPixelVisibleHandle() end
	local vis = util.PixelVisible(self:GetPos(), 1 * self:GetScale(), self.PixVis)
	if vis == 1 and color.a ~= 255 then
		if vis == 0 then return end

		cam.IgnoreZ(true)
	end
	render.DrawSprite(self:GetPos(), self:GetScale() * self.Material:Width(), self:GetScale() * self.Material:Height(), color)
	cam.IgnoreZ(false)
end

function ENT:AcceptInput(key)
	key = key:lower()
	if key == "showsprite" then
		self:SetEnabled(true)
	elseif key == "hidesprite" then
		self:SetEnabled(false)
	elseif key == "togglesprite" then
		self:SetEnabled(not self:GetEnabled())
	elseif key == "kill" then
		self:Remove()
	end
end

function ENT:KeyValue(key, value)
	if key == "renderamt" then
		self:SetSpriteAlpha(tonumber(value) or 255)
	elseif key == "rendercolor" then
		local color = string.ToColor(value)
		self:SetSpriteColor(color:ToVector())
	elseif key == "framerate" then
		self:SetFramerate(tonumber(value) or 0)
	elseif key == "scale" then
		self:SetScale(tonumber(value) or 1)
	elseif key == "model" then
		self:SetCMaterial(value)
	end
end

hook.Add("OnEntityCreated", "FixSprites", function(ent)
	if CLIENT or ent:GetClass() ~= "env_sprite" then return end
	timer.Simple(0.1, function()
		if not IsValid(ent) or ent:MapCreationID() == -1 then return end

		local keys = ent:GetKeyValues()
		if keys["framerate"] == 0 then return end

		local newent = ents.Create("sent_sprite")
		newent:SetPos(ent:GetPos())
		newent:SetScale(keys["scale"] or 1)
		newent:SetFramerate(keys["framerate"] or 0)
		newent:SetCMaterial(string.StripExtension(ent:GetModel() or ""))
		if bit.band(ent:GetEffects(), EF_NODRAW) == EF_NODRAW then
			newent:SetEnabled(false)
		else
			newent:SetEnabled(true)
		end
		local color = string.ToColor(keys["rendercolor"])
		newent:SetSpriteAlpha(color.a)
		newent:SetSpriteColor(color:ToVector())
		newent:SetName(ent:GetName() or "")
		newent:Spawn()

		ent:Remove()
	end)
end)
