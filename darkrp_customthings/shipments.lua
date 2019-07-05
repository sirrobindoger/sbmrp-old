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
    entity = "tfcss_p228",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 500,
    noship = true,
    allowed = {survey, security}
})
DarkRP.createShipment("Glock18", {
    model = "models/weapons/3_pist_glock18.mdl",
    entity = "tfcss_glock",
    price = 1250,
    amount = 1,
    separate = true,
    pricesep = 700,
    noship = true,
    allowed = {survey, security}
})

DarkRP.createShipment("FiveseveN", {
	model = "models/weapons/w_pist_fiveseven.mdl",
	entity = "tfcss_fiveseven",
	price = 900
	amount = 1,
	separate = true,
	pricesep = 750,
	noship = true,
	allowed = {survey, security}
})
--[[-------------------------------------------------------------------------
MED ARMS
---------------------------------------------------------------------------]]
DarkRP.createShipment(".357 Magnum", {
    model = "models/weapons/3_pist_deagle.mdl",
    entity = "tfa_bms_357",
    price = 750,
    amount = 1,
    separate = true,
    pricesep = 750,
    noship = true,
    allowed = {survey, security, military}
})

DarkRP.createShipment("Desert Eagle", {
    model = "models/weapons/3_pist_fiveseven.mdl",
    entity = "tfcss_deagle",
    price = 700,
    amount = 1,
    separate = true,
    pricesep = 700,
    noship = true,
    allowed = {survey, security, military}
})

DarkRP.createShipment("HK USP", {
    model = "models/weapons/3_pist_usp.mdl",
    entity = "tfcss_usp",
    price = 900,
    amount = 1,
    separate = true,
    pricesep = 900,
    noship = true,
    allowed = {survey, security, military}
})

DarkRP.createShipment("MAC 10", {
    model = "models/weapons/w_smg_mac10.mdl",
    entity = "tfcss_mac10",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 1000,
    noship = true,
    allowed = {survey, military}
})

--[[-------------------------------------------------------------------------
HEAVY ARMS
---------------------------------------------------------------------------]]

DarkRP.createShipment("SPAS-12", {
    model = "models/weapons/3_shot_xm1014.mdl",
    entity = "tfa_bms_shotgun",
    price = 1500,
    amount = 1,
    separate = true,
    pricesep = 900,
    noship = true, 
    allowed = {security, military}
})

DarkRP.createShipment("MP5", {
    model = "models/weapons/3_smg_mp5.mdl",
    entity = "tfa_bms_mp5",
    price = 1100,
    amount = 1,
    separate = true,
    pricesep = 1100,
    noship = true,
    allowed = {military}
})

DarkRP.createShipment("M4", {
    model = "models/weapons/3_rif_m4a1.mdl",
    entity = "tfcss_m4a1",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 1000,
    noship = true,
    allowed = {military}
})

DarkRP.createShipment("Xm1014", {
    model = "models/weapons/w_shot_xm1014.mdl",
    entity = "tfcss_xm1014",
    price = 1000,
    amount = 1,
    separate = true,
    pricesep = 1000,
    noship = true,
    allowed = {military}
})

--[[-------------------------------------------------------------------------
MISC
---------------------------------------------------------------------------]]

DarkRP.createEntity( "Universal Ammo", { 
   ent = "universal_ammo",
   model = "models/items/boxmrounds.mdl",
   price = 80,
   max = 5,
   cmd = "buyuniammo",
})