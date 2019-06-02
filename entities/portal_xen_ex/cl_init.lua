include('shared.lua') 
local tempMat = Material("sprites/exit1.vmt");
local matTable = {
	["$basetexture"] = tempMat:GetName(),
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$nolod"] = 1,
	["$additive"] = 1,
};
local portalmat_exit = CreateMaterial("exitportalmat2", "UnlitGeneric", matTable);
portalmat_exit:SetTexture("$basetexture", tempMat:GetTexture("$basetexture"));

function ENT:Draw()
	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		render.SetMaterial(portalmat_exit)
		render.DrawSprite( self:GetPos(), 32, 32, Color(255,255,255,255) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end