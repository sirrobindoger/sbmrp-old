--[[-------------------------------------------------------------------------
Retinal scanner processing
---------------------------------------------------------------------------]]


local function scanner(ply, ent)
	if !IsFirstTimePredicted() then return end
	local Team = ply:Team()
	local name = ent:GetName()
	local mapid = ent:MapCreationID()


end