include('shared.lua') 
local tempMat = Material("sprites/enter1.vmt");
local matTable = {
	["$basetexture"] = tempMat:GetName(),
	["$vertexalpha"] = 1, 
	["$vertexcolor"] = 1,
	["$nolod"] = 1,
	["$additive"] = 1,
};
local portalmat_entrance = CreateMaterial("entranceportalmat2", "UnlitGeneric", matTable);
portalmat_entrance:SetTexture("$basetexture", tempMat:GetTexture("$basetexture"));

function ENT:Draw()
	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		local drawcolor = Color(255,255,255,255)
		render.SetMaterial(portalmat_entrance)
		render.DrawSprite( self:GetPos(), 64, 64, drawcolor ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end
 
		