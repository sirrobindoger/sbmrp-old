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
		if self:GetHumanOrEventOnly()==true and LocalPlayer():IsAlien() and not(bmrp_xenallowed) then 
			drawcolor = Color(255,0,0,255)
		end
		render.SetMaterial(portalmat_entrance)
		render.DrawSprite( self:GetPos(), 32, 32, drawcolor ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end