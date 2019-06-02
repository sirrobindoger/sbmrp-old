--[[---------------------------------------------------------------------------
DarkRP custom jobs
---------------------------------------------------------------------------
This file contains your custom jobs.
This file should also contain jobs from DarkRP that you edited.

Note: If you want to edit a default DarkRP job, first disable it in darkrp_config/disabled_defaults.lua
      Once you've done that, copy and paste the job to this file and edit it.

The default jobs can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/jobrelated.lua

For examples and explanation please visit this wiki page:
http://wiki.darkrp.com/index.php/DarkRP:CustomJobFields

Add your custom jobs under the following line:

NEW JOB VARIABLES:
rdmgroup = "GroupName" --If RDM Groups is enabled, any people in the same group cannot harm each other.
rdmnogivingdamage = true --This job cannot damage anyone
rdmnoblockingdamage = true --Anyone can damage this job 
noradio         = true --They do not spawn with a radio
isalien         = true --Various checks, including whether they can go through a portal or are allowed in xen without a suit
isblackmesa     = true --They can get into/are allowed in black mesa
isscience       = true --They can use high-clearance scanners or machines like the AMS
isbio           = true --They can use certain things in the biolabs
issecurity      = true --They can use security doors and spawn with/can purchase certain weapons
ishecu          = true --They can purchase certain weapons (thats all its used as for now)
issubject       = true --They are restricted from a lot of things
issurvey        = true --Can they suit up, essentially
ispill          = true --They receive special functions that allow them to NOT fuck up the entire server with the shitty pills addon, wow what an honor

---------------------------------------------------------------------------]]

Scientistmodels = {
        "models/player/bms_scientist.mdl",
        "models/player/bms_scientist_female.mdl",
        "models/player/bms_kleiner.mdl",
        "models/player/bms_eli.mdl",
        "models/bmscientistcits/p_female_01.mdl",
        "models/bmscientistcits/p_female_02.mdl",
        "models/bmscientistcits/p_female_03.mdl",
        "models/bmscientistcits/p_female_04.mdl",
        "models/bmscientistcits/p_female_06.mdl",
        "models/bmscientistcits/p_female_07.mdl",
        "models/bmscientistcits/p_male_01.mdl",
        "models/bmscientistcits/p_male_02.mdl",
        "models/bmscientistcits/p_male_03.mdl",
        "models/bmscientistcits/p_male_04.mdl",
        "models/bmscientistcits/p_male_05.mdl",
        "models/bmscientistcits/p_male_06.mdl",
        "models/bmscientistcits/p_male_07.mdl",
        "models/bmscientistcits/p_male_08.mdl",
        "models/bmscientistcits/p_male_09.mdl",
        "models/bmscientistcits/p_male_10.mdl",
}

Securitymodels = {
    "models/player/bms_guard.mdl",
    "models/player/office1/male_08.mdl",
    "models/heartbit_female_guards3_pm.mdl",
 
}



AMSOperatormodels = {
	"models/paynamia/bms/gordon_survivor_player.mdl"
}



--[[-------------------------------------------------------------------------
Scientists 
---------------------------------------------------------------------------]]

TEAM_RESEARCH = DarkRP.createJob("Research Personnel", {
	color = Color(0, 86, 247, 255),
	model = Scientistmodels,
	description = [[An accomplished scientist at the BMRF, you get to own a Lab and conduct experiments with the help of your associates.]],
	weapons = {},
	command = "reserachpersonnel",
	max = 10,
	salary = 45,
	admin = 0,
	vote = false,
	hasLicense = false,
	candemote = true,
	isblackmesa = true,
	isscience = true,
	rdmgroup = "BMRF",
	category = "Science Personnel",
	customCheck = function(ply) return ply:GetUtimeTotalHours() >= 3 end,
	CustomCheckFailMsg = "You need at least 3 hours to play as this job!"
})

TEAM_ASSOCIATE = DarkRP.createJob("Research Assistant", {
	color = Color(0, 86, 247, 255),
	model = Scientistmodels,
	description = [[You're a new worker at BMRF, you are here to help the Research Staff with their experiments.]],
	weapons = {},
	command = "reserachassistant",
	max = 0,
	salary = 35,
	admin = 0,
	vote = false,
	hasLicense = false,
	candemote = false,
	-----------------
	isblackmesa = true,
	isscience = true,
	rdmgroup = "BMRF",
	-----------------
	category = "Science Personnel",
})

TEAM_HEAD_SCIENTIST = DarkRP.createJob("Head Researcher", {
	color = Color(0, 86, 247, 255),
	model = Scientistmodels,
	description = [[You are the head researcher at the Black Mesa Research Facility, it is your job to make sure that all experiments are running smoothly and that saftey is being practiced at all times.]],
	weapons = {},
	command = "reserachhead",
	max = 0,
	salary = 35,
	admin = 0,
	vote = false,
	hasLicense = false,
	candemote = false,
	-----------------
	isblackmesa = true,
	isscience = true,
	rdmgroup = "BMRF",
	-----------------
	customCheck = function(ply) return ply:GetUtimeTotalHours() >= 6 end,
	CustomCheckFailMsg = "You need at least 6 hours to play as this job!",
	category = "Science Personnel",
	NeedToChangeFrom = TEAM_RESEARCH,
})


--[[-------------------------------------------------------------------------
Survey
---------------------------------------------------------------------------]]

TEAM_SURVEY_MINER = DarkRP.createJob("Anomoulous Materials Extractor",{
	color = Color(255, 153, 0, 255),
	model = Scientistmodels,
	description = [[Your job is to handle dangerous materials during your team missions to an unknown border world.]],
	weapons = {},
	command = "surveyminer",
	max = 6,
	salary = 50,
	admin = 0,
	vote = false,
	hasLicense = true,
	candemote = true,
	-----------------
	isblackmesa = true,
	issurvey = true,
	isscience = true,
	rdmgroup = "BMRF",
	----------------
	category = "Survey Personnel"
})

TEAM_SURVEY_SUPPORT = DarkRP.createJob("Survey Munitions Expert",{
	color = Color(255, 153, 0, 255),
	model = Scientistmodels,
	description = [[You're the person that knows how to make weapons. Setup a weapons station and use your team's help to craft deadly weapons to protect yourself.]],
	weapons = {},
	command = "surveysupport",
	max = 6,
	salary = 50,
	admin = 0,
	vote = false,
	hasLicense = true,
	candemote = true,
	-----------------
	isblackmesa = true,
	issurvey = true,
	isscience = true,
	rdmgroup = "BMRF",
	----------------
	category = "Survey Personnel"
})


TEAM_SURVEY_CATCHER = DarkRP.createJob("Survey Specimen Extractor",{
	color = Color(255, 153, 0, 255),
	model = Scientistmodels,
	description = [[Your job is to find and extract Xenian specimens for the bio sector back on Earth.]],
	weapons = {},
	command = "surveycatcher",
	max = 6,
	salary = 50,
	admin = 0,
	vote = false,
	hasLicense = true,
	candemote = true,
	-----------------
	isblackmesa = true,
	issurvey = true,
	isscience = true,
	rdmgroup = "BMRF",
	----------------
	category = "Survey Personnel"
})


TEAM_SURVEYTEAM_COMMANDER = DarkRP.createJob("Survey Team Commander", {
    color = Color(8, 222, 171, 255),
    model = Scientistmodels,
    description = [[The commander of the Survey Team, lead your team on an expedition into the unknown.]],
    weapons = {},
    command = "surveyteamcommander",
    max = 1,
    salary = 100,
    admin = 0,
    vote = true,
    hasLicense = true,
    candemote = true,
    rdmgroup = "BMRF",
    -----------------
    isblackmesa = true,
    isscience = true,
    issurvey = true,
    -----------------
    category = "Survey Personnel",
    NeedToChangeFrom = TEAM_SURVEY
})

--[[-------------------------------------------------------------------------
Security Jobs
---------------------------------------------------------------------------]]


TEAM_SECURITYCHEIF = DarkRP.createJob("Security Chief", {
    color = Color(0, 49, 156, 255),
    model = Securitymodels,
    description = [[You're chief of the Black Mesa Security force.]],
    weapons = {"itemstore_pickup"},
    command = "securitycheif",
    max = 1,
    admin = 0,
    salary = 120,
    vote = true,   
    PlayerSpawn = function(ply)
    ply:SetModel("models/player/office1/male_08.mdl")
    end,
    ------------------
    isblackmesa = true,
    issecurity = true,
    rdmgroup = "BMRF",
    ------------------
    category = "Security Personnel"
})


TEAM_SECURITY = DarkRP.createJob("Security Guard", {
    color = Color(25, 25, 170, 255),
    model = Securitymodels,
    description = [[The vast majority of guards work as security officers, tasked with protecting secured areas and information, reporting breaches of authority to their administrative sponsor and helping with the general maintenance tasks.
    In rare cases, security officers will be tasked with with capturing escaped research specimens]],
    weapons = {"itemstore_pickup"},
    command = "security",
    max = 4,
    admin = 0,
    salary = 75, 
    PlayerSpawn = function(ply)
        ply:SetModel("models/player/office1/male_08.mdl")
    end,
    customCheck = function(ply)
    	return ply:GetUtimeTotalHours() >= 2.5
    end,
    ------------------
    rdmgroup = "BMRF",
    isblackmesa = true,
    issecurity = true,
    ------------------
    category = "Security Personnel"
})


TEAM_SECURITYRECRUIT = DarkRP.createJob("Security Recruit", {
    color = Color(41, 17, 136, 255),
    model = Securitymodels,
    description = [[You're a recruit. Working your way up the ranks in the BMRF Security Force.]],
    weapons = {},
    command = "securityrecruit",
    max = 6,
    admin = 0,
    salary = 0,
    PlayerSpawn = function(ply) 
        ply:SetModel("models/player/office1/male_08.mdl")
    end,
    ------------------
    rdmgroup = "BMRF",
    isblackmesa = true,
    issecurity = true,
    ------------------
    category = "Security Personnel"
})




--[[-------------------------------------------------------------------------
Administration/Office Jobs
---------------------------------------------------------------------------]]

TEAM_OFFICE = DarkRP.createJob("Office Employee", {
    color = Color(34, 85, 85, 255),
    model = {
    "models/player/suits/male_07_closed_tie.mdl",
    "models/player/suits/male_07_open.mdl",
    "models/player/suits/male_07_open_tie.mdl",
    "models/player/suits/male_07_open_waistcoat.mdl",
    },
    description = [[You are an office employee of BMRF, do your work and be nice to your co-workers.]],
    weapons = {},
    command = "officeworker",
    max = 6,
    salary = 120,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Office Personnel",
    ------------------
    rdmgroup = "BMRF",
    isblackmesa = true
    ------------------
})


TEAM_OFFICEMANAGER = DarkRP.createJob("Office Manager", {
    color = Color(34, 85, 85, 255),
    model = {
    "models/player/suits/male_07_closed_tie.mdl",
    "models/player/suits/male_07_open.mdl",
    "models/player/suits/male_07_open_tie.mdl",
    "models/player/suits/male_07_open_waistcoat.mdl",
    },
    description = [[You are the #1 regional manager of the BMRF Office Complex.]],
    weapons = {},
    command = "officemanger",
    max = 1,
    salary = 120,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Office Personnel",
    ------------------
    rdmgroup = "BMRF",
    isblackmesa = true,
    ------------------
    NeedToChangeFrom = TEAM_OFFICE,
})

TEAM_ITTECH = DarkRP.createJob("IT Technician", {
    color = Color(34, 85, 85, 255),
    model = {"models/player/hostage/hostage_02.mdl",
        "models/player/hostage/hostage_03.mdl"
    },
    description = [[Setup and maintain the computers for the Office Workers.]],
    weapons = {},
    command = "ittech",
    max = 4,
    salary = 120,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Office Personnel",
    ------------------
    rdmgroup = "BMRF",
    isblackmesa = true
    ------------------
})


TEAM_ADMINISTRATOR = DarkRP.createJob("Facility Administrator", {
    color = Color(214, 0, 0, 255),
    model = {"models/player/breen.mdl"},
    description = [[As the Facility Administrator it is your job to maintain order thoughout Black Mesa, and to oversee AMS operations.]],
    weapons = {},
    command = "administrator",
    max = 1,
    admin = 0,
    salary = 300,
    vote = true,
    mayor = true,
    category = "Security Personnel",
    PlayerSpawn = function(ply)
        ply:SetHealth(100)
        ply:SetArmor(145)
    end,
    PlayerDeath = function(ply, weapon, killer)
        ply:teamBan()
        ply:changeTeam(GAMEMODE.DefaultTeam, true)
        DarkRP.notifyAll(0, 4, "The Facility Administrator has been murdered!")
    end,
    ------------------
    rdmgroup = "BMRF",
    isscience = true,
    issecurity = true,
    isblackmesa = true,
    ------------------
})


--[[-------------------------------------------------------------------------
Bio Sector jobs
---------------------------------------------------------------------------]]


TEAM_BIO = DarkRP.createJob("Bioworker", {
    color = Color(255, 97, 3, 255),
     model = {
        "models/hazmatcitizens/p_hazmatmale07.mdl",
        "models/hazmatcitizens/p_hazmatfemale01.mdl",
        "models/hazmatcitizens/p_hazmatfemale02.mdl",
        "models/hazmatcitizens/p_hazmatfemale03.mdl",
        "models/hazmatcitizens/p_hazmatmale01.mdl",
        "models/hazmatcitizens/p_hazmatmale02.mdl",
        "models/hazmatcitizens/p_hazmatmale03.mdl"
    },
    description = [[Run experiments on your subjects, handle hazerdous materials.]],
    weapons = {"taser","cage","weapon_leash_bio"},
    command = "bioworker",
    max = 4,
    admin = 0,
    salary = 75,
    rdmgroup = "BMRF",
    isblackmesa = true,
    isbio = true,
    category = "Bioworker Division"
})

--[[-------------------------------------------------------------------------
Specimens job
---------------------------------------------------------------------------]]

TEAM_TESTSUBJECT = DarkRP.createJob("Human Test Subject", {
    color = Color(255, 97, 3, 255),
    model = {
        "models/player/aperture_science/male_07.mdl",
        "models/player/aperture_science/male_01.mdl",
        "models/player/aperture_science/male_02.mdl",
        "models/player/aperture_science/male_03.mdl",
        "models/player/aperture_science/male_04.mdl",
        "models/player/aperture_science/male_05.mdl",
        "models/player/aperture_science/male_06.mdl",
        "models/player/aperture_science/male_08.mdl",
        "models/player/aperture_science/male_09.mdl"
    },
    description = [[A prisioner, Instead of death sentence you were sent here, who knows what they have in store for you.]],
    weapons = {},
    command = "testsubject",
    max = 4,
    admin = 0,
    salary = 1,
    rdmnoblockingdamage = true,
    rdmnogivingdamage = true,
    PlayerSpawn = function(ply)
        ply:StripWeapons()
    end,
    noradio = true,
    issubject = true,
    category = "BMRF Specimens"
})

/*
TEAM_HEADCRAB = DarkRP.createJob("De-Fanged Headcrab", {
    color = Color(160, 100, 190, 255),
    model = "models/player/inv2.mdl",
    description = [[*headcrab noises*]],
    weapons = {},
    command = "headcrab",
    max = 2,
    admin = 0,
    salary = 1,
    PlayerSpawn = function(ply) 
        if not ply:Alive() or not IsValid(ply) then 
            return 
        end 
        if not ply:IsAdmin() then 
            pk_pills.apply(ply,"headcrab",'lock-life') 
        elseif not ply:GetNWBool("IsInPill") == true then 
            pk_pills.apply(ply,"headcrab",'force') 
        end 
        ply:SetNoTarget(true) 
        ply:SetNWBool("IsInPill", true)
        ply:SetGravity(1.5)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(500)
        end,
    PlayerDeath = function(ply, weapon, killer) 
        ply:SetNoTarget(false) 
        pk_pills.restore(ply,true) 
        ply:SetNWBool("IsInPill", false) 
        end,
    rdmnoblockingdamage = true,
    rdmnogivingdamage = true,
    noradio = true,
    issubject = true,
    category = "Biolabs - Bioscience Division"
})
*/



--[[-------------------------------------------------------------------------
TOPSIDE HECU 
---------------------------------------------------------------------------]]


--[[-------------------------------------------------------------------------
MISC
---------------------------------------------------------------------------]]

TEAM_VISITOR = DarkRP.createJob("Visitor", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/player/Group01/Female_01.mdl",
        "models/player/Group01/Female_02.mdl",
        "models/player/Group01/Female_03.mdl",
        "models/player/Group01/Female_04.mdl",
        "models/player/Group01/Female_06.mdl",
        "models/player/group01/male_01.mdl",
        "models/player/Group01/Male_02.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/Male_04.mdl",
        "models/player/Group01/Male_05.mdl",
        "models/player/Group01/Male_06.mdl",
        "models/player/Group01/Male_07.mdl",
        "models/player/Group01/Male_08.mdl",
        "models/player/Group01/Male_09.mdl"
    },
    description = [[The Vistor is only here to observe. He has no rights unless he is shaparoned by a Science Personel.]],
    weapons = {"none"},
    command = "visitor",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    --------------------
    rdmnogivingdamage = true,
    noradio = true,
    rdmnoblockingdamage = true,
    --------------------
    category = "Visitor",
})





--[[---------------------------------------------------------------------------
Define which team joining players spawn into and what team you change to if demoted
---------------------------------------------------------------------------]]
GAMEMODE.DefaultTeam = TEAM_VISITOR
--[[---------------------------------------------------------------------------
Define which teams belong to civil protection
Civil protection can set warrants, make people wanted and do some other police related things
---------------------------------------------------------------------------]]
GAMEMODE.CivilProtection = {
    [TEAM_SECURITYRECRUIT] = true,
    [TEAM_SECURITY] = true,
    [TEAM_SECURITYCHEIF] = true,
    [TEAM_ADMINISTRATOR] = true,
}
--[[---------------------------------------------------------------------------
Jobs that are hitmen (enables the hitman menu)
---------------------------------------------------------------------------]]
DarkRP.addHitmanTeam(TEAM_MOB)
