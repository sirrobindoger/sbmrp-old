--[[-------------------------------------------------------------------------
Gronarch Boss fight
---------------------------------------------------------------------------]]

local function GetGonarch()
    for k,v in pairs(ents.FindByClass("monster_gonarch")) do
        if GetLocation(v:GetPos()) == "Gonarch Lair" then
            return v
        end
    end
end

print(GetGonarch():GetName())