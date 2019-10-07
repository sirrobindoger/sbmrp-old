--[[---------------------------------------------------------------------------
DarkRP custom shipments and guns
---------------------------------------------------------------------------

This file contains your custom shipments and guns.
This file should also contain shipments and guns from DarkRP that you edited.

Note: If you want to edit a default DarkRP shipment, first disable it in darkrp_config/disabled_defaults.lua
    Once you've done that, copy and paste the shipment to this file and edit it.

The default shipments and guns can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/addentities.lua

For examples and explanation please visit this wiki page:
http://wiki.darkrp.com/index.php/DarkRP:CustomShipmentFields


Add shipments and guns under the following line:
---------------------------------------------------------------------------]]

local security = {
	TEAM_SECURITYCHEIF,
	TEAM_SECURITY,
	TEAM_SECURITYRECRUIT,
}

local survey = {
	TEAM_SURVEY_SUPPORT
}

local military = {
	TEAM_HECUCOMMAND,
	TEAM_HECUMED,
	TEAM_HECU,
	TEAM_HECUSPECOPS,

}

--[[-------------------------------------------------------------------------
SMALL ARMS
---------------------------------------------------------------------------]]
DarkRP.createShipment("P228", {
    model = "models/weapons/3_pist_p228.mdl",
    entity = "tfcss_p228_alt",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 400,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_p228_alt"] and JobRanks[ply:Team()].Entities["tfcss_p228_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl" ..  JobRanks[ply:Team()].Entities["tfcss_p228_alt"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF, TEAM_SECURITY, TEAM_SECURITYRECRUIT},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})
DarkRP.createShipment("Glock18", {
    model = "models/weapons/3_pist_glock18.mdl",
    entity = "tfcss_glock_alt",
    price = 1250,
    amount = 1,
    separate = true,
    pricesep = 550,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_glock_alt"] and JobRanks[ply:Team()].Entities["tfcss_glock_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl" .. JobRanks[ply:Team()].Entities["tfcss_glock_alt"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF,TEAM_SECURITY, TEAM_SECURITYRECRUIT},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("FiveseveN", {
	model = "models/weapons/w_pist_fiveseven.mdl",
	entity = "tfcss_fiveseven_alt",
	price = 900,
	amount = 1,
	separate = true,
	pricesep = 550,
	noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_fiveseven_alt"] and JobRanks[ply:Team()].Entities["tfcss_fiveseven_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " .. JobRanks[ply:Team()].Entities["tfcss_fiveseven_alt"] .. " to purchase this." end,
	allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF,TEAM_SECURITY,TEAM_SECURITYRECRUIT},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})
--[[-------------------------------------------------------------------------
MED ARMS
---------------------------------------------------------------------------]]
DarkRP.createShipment(".357 Magnum", {
    model = "models/bms/weapons/w_357.mdl",
    entity = "weapon_bms_357",
    price = 750,
    amount = 1,
    separate = true,
    pricesep = 550,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["weapon_bms_357"] and JobRanks[ply:Team()].Entities["weapon_bms_357"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["weapon_bms_357"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF,TEAM_SECURITY,TEAM_SECURITYRECRUIT, TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("Desert Eagle", {
    model = "models/weapons/3_pist_fiveseven.mdl",
    entity = "tfcss_deagle_alt",
    price = 700,
    amount = 1,
    separate = true,
    pricesep = 550,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_deagle_alt"] and JobRanks[ply:Team()].Entities["tfcss_deagle_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " .. JobRanks[ply:Team()].Entities["tfcss_deagle_alt"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF,TEAM_SECURITY,TEAM_SECURITYRECRUIT, TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("HK USP", {
    model = "models/weapons/3_pist_usp.mdl",
    entity = "tfcss_usp_alt",
    price = 900,
    amount = 1,
    separate = true,
    pricesep = 750,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_usp_alt"] and JobRanks[ply:Team()].Entities["tfcss_usp_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " .. JobRanks[ply:Team()].Entities["tfcss_usp_alt"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_SECURITYCHEIF,TEAM_SECURITY,TEAM_SECURITYRECRUIT, TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("MAC 10", {
    model = "models/weapons/w_smg_mac10.mdl",
    entity = "tfcss_ump45_alt",
    price = 850,
    amount = 1,
    separate = true,
    pricesep = 1000,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_ump45_alt"] and JobRanks[ply:Team()].Entities["tfcss_ump45_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["tfcss_ump45_alt"] .. " to purchase this." end,
    allowed = {TEAM_SURVEY_SUPPORT, TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

--[[-------------------------------------------------------------------------
HEAVY ARMS
---------------------------------------------------------------------------]]

DarkRP.createShipment("SPAS-12", {
    model = "models/bms/weapons/w_shotgun.mdl",
    entity = "weapon_bms_shotgun",
    price = 1500,
    amount = 1,
    separate = true,
    pricesep = 600,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["weapon_bms_shotgun"] and JobRanks[ply:Team()].Entities["weapon_bms_shotgun"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["weapon_bms_shotgun"] .. " to purchase this." end,
    allowed = {TEAM_SECURITYCHEIF,TEAM_SECURITY, TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("MP5", {
    model = "models/bms/weapons/w_mp5.mdl",
    entity = "weapon_bms_mp5",
    price = 1100,
    amount = 1,
    separate = true,
    pricesep = 600,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["weapon_bms_mp5"] and JobRanks[ply:Team()].Entities["weapon_bms_mp5"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["weapon_bms_mp5"] .. " to purchase this." end,
    allowed = {TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS, TEAM_SECURITY},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("M4", {
    model = "models/weapons/3_rif_m4a1.mdl",
    entity = "tfcss_m4a1_alt",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 850,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_m4a1_alt"] and JobRanks[ply:Team()].Entities["tfcss_m4a1_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["tfcss_m4a1_alt"] .. " to purchase this." end,
    allowed = {TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS, TEAM_SECURITY},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("Xm1014", {
    model = "models/weapons/w_shot_xm1014.mdl",
    entity = "tfcss_xm1014_alt",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 850,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_xm1014_alt"] and JobRanks[ply:Team()].Entities["tfcss_xm1014_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["tfcss_xm1014_alt"] .. " to purchase this." end,
    allowed = {TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("AWP", {
    model = "models/weapons/3_snip_awp.mdl",
    entity = "tfcss_awp_alt",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 850,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_awp_alt"] and JobRanks[ply:Team()].Entities["tfcss_awp_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["tfcss_awp_alt"] .. " to purchase this." end,
    allowed = {TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment("Leash", {
    model = "models/items/boxmrounds.mdl",
    entity = "weapon_leash_default",
    price = 0,
    amount = 1,
    separate = true,
    pricesep = 0,
    noship = true,
    customCheck = function(ply) if JobRanks[ply:Team()] and JobRanks[ply:Team()].Entities["tfcss_awp_alt"] and JobRanks[ply:Team()].Entities["tfcss_awp_alt"] > ply:GetJobRank() then return false else return true end end,
    CustomCheckFailMsg = function(ply) return "You must be Lvl. " ..  JobRanks[ply:Team()].Entities["tfcss_awp_alt"] .. " to purchase this." end,
    allowed = {TEAM_HECUCOMMAND,TEAM_HECUMED,TEAM_HECU,TEAM_HECUSPECOPS},
    onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})
--[[-------------------------------------------------------------------------
MISC
---------------------------------------------------------------------------]]
DarkRP.createShipment( "Alien Capture Cuffs", { 
    model = "models/items/boxmrounds.mdl",
    entity = "weapon_leash_survey",
    price = 0,
    amount = 1,
    separate = true,
    pricesep = 850,
    noship = true,
   allowed = {TEAM_SURVEY_MINER},
   onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createShipment( "Door Ram", { 
    model = "models/items/boxmrounds.mdl",
    entity = "door_ram",
    price = 0,
    amount = 1,
    separate = true,
    pricesep = 600,
    noship = true,
   allowed = {TEAM_SECURITYCHEIF,TEAM_SECURITY},
   onBought = function(ply, shipment) ply:Give(shipment.entity) end,
})

DarkRP.createEntity( "Universal Ammo", { 
   ent = "universal_ammo",
   model = "models/items/boxmrounds.mdl",
   price = 10,
   max = 5,
   cmd = "buyuniammo",
})


local ply = FindMetaTable( "Player" )

function ply:SetMaxAmmo()
    for k,v in pairs(self:GetWeapons()) do
        local wep = v:GetPrimaryAmmoType()

        if wep and wep != -1 and v:GetMaxClip1() != nil then
            local ammo = game.GetAmmoName(wep)
            local amount = math.random(20, 60)
            self:GiveAmmo(amount, ammo)
        end
    end
end

hook.Add("PlayerUse", "universal_ammo_override", function(ply, ent)
    if not IsFirstTimePredicted() then return end
    if ent:GetClass() == "universal_ammo" then
        ply:SetMaxAmmo()
        ent:Remove()
    end
end)