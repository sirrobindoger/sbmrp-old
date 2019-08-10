--[[---------------------------------------------------------------------------
DarkRP custom entities
---------------------------------------------------------------------------

This file contains your custom entities.
This file should also contain entities from DarkRP that you edited.

Note: If you want to edit a default DarkRP entity, first disable it in darkrp_config/disabled_defaults.lua
	Once you've done that, copy and paste the entity to this file and edit it.

The default entities can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/addentities.lua#L111

For examples and explanation please visit this wiki page:
http://wiki.darkrp.com/index.php/DarkRP:CustomEntityFields

Add entities under the following line:
---------------------------------------------------------------------------]]
--[[
DarkRP.createEntity("Radio", {
	ent = "rp_radio",
	model = "models/props_lab/citizenradio.mdl",
	price = 200,
	max = 1,
	cmd = "buyradio",
	category = "Electronics"
})
]]--


--[[DarkRP.createEntity("Terminal",{
	ent = "sent_computer",
	model = "models/props_lab/monitor01a.mdl",
	price = 0,
	max = 10,
	cmd = "buyterminal",
	allowed = {TEAM_ITTECH},
	category = "IT Equipment"
})]]--

DarkRP.createEntity("Crystal Storage", {
	ent = "tester_storage",
	model = "models/props_marines/ammocrate01.mdl",
	price = 0,
	max = 1,
	cmd = "buycrystalstorage",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_storage" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})
DarkRP.createEntity("Crystal Analzyer", {
	ent = "tester_analyzer",
	model = "models/props/portedprops/computer.mdl",
	price = 0,
	max = 1,
	cmd = "buycrystalanalyzer",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_analyzer" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Crystal Exporter", {
	ent = "crystal_sale_machine",
	model = "models/props_blackmesa/metalcrate01.mdl",
	price = 0,
	max = 1,
	cmd = "buycrystalexporter",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "crystal_sale_machine" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Crystal Exporter Console", {
	ent = "crystal_sale_console",
	model = "models/props_lab/hev_controlpanel.mdl",
	price = 0,
	max = 1,
	cmd = "buycrystalexporterconsole",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "crystal_sale_console" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})
/*
DarkRP.createEntity("Universal Tester", {
	ent = "tester_universal",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buyuniversaltester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_universal" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})
*/
DarkRP.createEntity("Ballistic Tester", {
	ent = "tester_bullet",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buyballistictester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_bullet" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Force Tester", {
	ent = "tester_melee",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buybluntforcetester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_melee" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Stability Tester", {
	ent = "tester_explosion",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buyexplosivetester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_explosion" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Gravity Tester", {
	ent = "tester_gravity",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buygravitytester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_gravity" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Laser Tester", {
	ent = "tester_burn",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buylasertester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_burn" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Organic Tester", {
	ent = "tester_player",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buypersontester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_player" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Timed Tester", {
	ent = "tester_think",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buytimedtester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_think" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})

DarkRP.createEntity("Water Tester", {
	ent = "tester_water",
	model = "models/props_lab/surgical_laser.mdl",
	price = 0,
	max = 1,
	cmd = "buywatertester",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "tester_water" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Research Equipment"
})


DarkRP.createEntity("Guncrafting Machine", {
	ent = "guncrafting_bench",
	model = "models/props_lab/console03c.mdl",
	price = 0,
	max = 1,
	cmd = "buyguncraftingbench",
	allowTools = true,
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "guncrafting_bench" ) entr:CPPISetOwner(ply)entr.SID = ply.SID entr.OwnerID = ply:SteamID() entr:SetPos( tr.HitPos + tr.HitNormal * 16 ) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_RESEARCH, TEAM_HEAD_SCIENTIST},
	category = "Weapon Manufacturer"
})

--[[
DarkRP.createEntity("Media TV",{
	ent = "mediaplayer_tv",
	model = "models/gmod_tower/suitetv_large.mdl",
	price = 10,
	max = 1,
	cmd = "buytv",
	category = "Electronics"
})
]]--

DarkRP.createEntity("Long Jump Module",{
	ent = "item_longjump",
	model = "models/halflife/items/longjump.mdl",
	price = 10,
	max = 1,
	cmd = "longjump",
	allowed = {TEAM_SURVEYTEAM, TEAM_SURVEYTEAM_COMMANDER, TEAM_SURVEYTEAM_SUPPORT, TEAM_SURVEYTEAM_WEAPONS},
	category = "Research Equipment"
})



DarkRP.createEntity("Mobile HEV Mk. IV Deployer", {
	ent = "item_hevsuit_delivery",
	model = "models/Items/hevsuit.mdl",
	price = 500,
	max = 1,
	allowTools = true,
	cmd = "buyhevsuitup",
	spawn = function(ply, tr, tblEnt) local entr = ents.Create( "item_hevsuit_delivery" ) entr:SetPos( tr.HitPos + tr.HitNormal * 16) entr:Spawn() entr:Activate() return entr end,
	allowed = {TEAM_SURVEYTEAM_SUPPORT}
})
-- CHEF SHIT
--[[
DarkRP.createEntity("Bag", {
	ent = "fx_openbag",
	model = "models/oldbill/ahfoodbagopen.mdl",
	price = 0,
	max = 4,
	cmd = "fbbag",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Bun Bottom", {
	ent = "fb_bunbottom",
	model = "models/oldbill/ahbunbottom.mdl",
	price = 0,
	max = 4,
	cmd = "fbbottom",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Bun Top", {
	ent = "fb_buntop",
	model = "models/oldbill/ahbuntop.mdl",
	price = 0,
	max = 4,
	cmd = "fbtop",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Burger Box", {
	ent = "fb_openburgerbox",
	model = "models/oldbill/ahburgerboxopen.mdl",
	price = 0,
	max = 4,
	cmd = "fbopenbox",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Burger", {
	ent = "fb_rawburger",
	model = "models/oldbill/ahrawburger.mdl",
	price = 0,
	max = 4,
	cmd = "fbburger",
	allowed = {TEAM_CHEF},
	category = "Food"

})


DarkRP.createEntity("Egriddle", {
	ent = "fb_egriddle",
	model = "models/oldbill/egriddle.mdl",
	price = 0,
	max = 1,
	cmd = "fb",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Fries", {
	ent = "ff_fries",
	model = "models/oldbill/ahfries.mdl",
	price = 0,
	max = 4,
	cmd = "fbfries",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Fry Basket", {
	ent = "ff_frybasket",
	model = "models/oldbill/ahfryerh.mdl",
	price = 0,
	max = 4,
	cmd = "fbfrybasket",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Fryer", {
	ent = "ff_fryer",
	model = "models/oldbill/ahfryer.mdl",
	price = 0,
	max = 4,
	cmd = "fbfryer",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Lettuce", {
	ent = "fb_lettuce",
	model = "models/oldbill/ahlettuce.mdl",
	price = 0,
	max = 4,
	cmd = "fblettuce",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Onion", {
	ent = "fb_onion",
	model = "models/oldbill/ahonion.mdl",
	price = 0,
	max = 4,
	cmd = "fbonion",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Tomato", {
	ent = "fb_tomato",
	model = "models/oldbill/ahtomato.mdl",
	price = 0,
	max = 4,
	cmd = "fbtomato",
	allowed = {TEAM_CHEF},
	category = "Food"
})

/*
DarkRP.createEntity("Pizza", {
	ent = "fz_pizzaraw",
	model = "models/oldbill/ahpizzaraw.mdl",
	price = 0,
	max = 4,
	cmd = "fbpizza",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Pizza Box", {
	ent = "fz_openpizzabox",
	model = "models/oldbill/ahpizzabox_open.mdl",
	price = 0,
	max = 4,
	cmd = "fbbox",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Pizza Oven", {
	ent = "fz_pizzaoven",
	model = "models/oldbill/ahpizzaoven.mdl",
	price = 0,
	max = 2,
	cmd = "fbovenpizza",
	allowed = {TEAM_CHEF},
	category = "Food"
})
*/
DarkRP.createEntity("Soda Machine", {
	ent = "fs_sodamachine",
	model = "models/oldbill/ahsodamachine.mdl",
	price = 0,
	max = 1,
	cmd = "fbsodamachine",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Straw", {
	ent = "fs_sodastraw",
	model = "models/oldbill/ahstraw.mdl",
	price = 0,
	max = 4,
	cmd = "fbstraw",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Soda Cup", {
	ent = "fs_sodacup",
	model = "models/oldbill/ahsodacup.mdl",
	price = 0,
	max = 4,
	cmd = "fbsodacup",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Soda Top", {
	ent = "fs_sodatop",
	model = "models/oldbill/ahsodacontainer.mdl",
	price = 0,
	max = 4,
	cmd = "fbsodatop",
	allowed = {TEAM_CHEF},
	category = "Food"
})

DarkRP.createEntity("Tray", {
	ent = "fx_tray",
	model = "models/oldbill/ahtray.mdl",
	price = 0,
	max = 4,
	cmd = "fbtray",
	allowed = {TEAM_CHEF},
	category = "Food"    
})
]]--
