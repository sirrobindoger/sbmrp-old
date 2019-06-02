--[[-----------------------------------------------------------------------
Categories
---------------------------------------------------------------------------
The categories of the default F4 menu.

Please read this page for more information:
http://wiki.darkrp.com/index.php/DarkRP:Categories

In case that page can't be reached, here's an example with explanation:

DarkRP.createCategory{
    name = "Citizens", -- The name of the category.
    categorises = "jobs", -- What it categorises. MUST be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo".
    startExpanded = true, -- Whether the category is expanded when you open the F4 menu.
    color = Color(0, 107, 0, 255), -- The color of the category header.
    canSee = function(ply) return true end, -- OPTIONAL: whether the player can see this category AND EVERYTHING IN IT.
    sortOrder = 100, -- OPTIONAL: With this you can decide where your category is. Low numbers to put it on top, high numbers to put it on the bottom. It's 100 by default.
}


Add new categories under the next line!
---------------------------------------------------------------------------]]

DarkRP.createCategory{
    name = "Visitor", -- The name of the category.
    categorises = "jobs", -- What it categorises. MUST be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo".
    startExpanded = false, -- Whether the category is expanded when you open the F4 menu.
    color = Color(20, 150, 20, 255), -- The color of the category header.
    canSee = function(ply) return false end, -- OPTIONAL: whether the player can see this category AND EVERYTHING IN IT.
    sortOrder = 50, -- OPTIONAL: With this you can decide where your category is. Low numbers to put it on top, high numbers to put it on the bottom. It's 100 by default.
}

DarkRP.createCategory{
    name = "Science Personnel",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 225, 255),
    canSee = function(ply) return true end,
    sortOrder = 10
}

DarkRP.createCategory{
    name = "Survey Personnel",
    categorises = "jobs",
    startExpanded = true,
    color = Color(188, 176, 9),
    canSee = function(ply) return true end,
    sortOrder = 15
}

DarkRP.createCategory{
    name = "Security Personnel",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 16
}

DarkRP.createCategory{
    name = "Office Personnel",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 0, 0),
    canSee = function(ply) return true end,
    sortOrder = 20
}

DarkRP.createCategory{
    name = "Black Mesa Faculty",
    categorises = "jobs",
    startExpanded = true,
    color = Color(119, 112, 117),
    canSee = function(ply) return true end,
    sortOrder = 22
}


DarkRP.createCategory{
    name = "Bioworker Division",
    categorises = "jobs",
    startExpanded = true,
    color = Color(66, 244, 116),
    canSee = function(ply) return true end,
    sortOrder = 25
}

DarkRP.createCategory{
    name = "BMRF Specimens",
    categorises = "jobs",
    startExpanded = false,
    color = Color(66, 244, 116),
    canSee = function(ply) return true end,
    sortOrder = 26
}

DarkRP.createCategory{
    name = "Military/Government",
    categorises = "jobs",
    startExpanded = true,
    color = Color(124, 123, 130, 255),
    canSee = function(ply) return true end,
    sortOrder = 30
}

DarkRP.createCategory{
    name = "Xenians",
    categorises = "jobs",
    startExpanded = true,
    color = Color(220, 25, 237, 255),
    canSee = function(ply) return true end,
    sortOrder = 31
}



-- Ents start

DarkRP.createCategory{
    name = "Text Signs",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 255, 255, 255),
    canSee = function(ply) return true end,
    sortOrder = 5
}

DarkRP.createCategory{
    name = "Electronics",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 184, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 5
}

DarkRP.createCategory{
    name = "Research Equipment",
    categorises = "entities",
    startExpanded = true,
    color = Color(219, 0, 255, 255),
    canSee = function(ply) return table.HasValue({TEAM_CRYSTALSSPECIALIST}, ply:Team()) end,
    sortOrder = 1
}

DarkRP.createCategory{
    name = "IT Equipment",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 184, 0, 255),
    canSee = function(ply) return table.HasValue({TEAM_ITTECH, TEAM_OFFICE, TEAM_OFFICEMANAGER}, ply:Team()) end,
    sortOrder = 1
}

DarkRP.createCategory{
    name = "Weapon Manufacturer",
    categorises = "entities",
    startExpanded = true,
    color = Color(219, 0, 255, 255),
    canSee = function(ply) return table.HasValue({TEAM_WEAPONSDEVELOPMENT}, ply:Team()) end,
    sortOrder = 2
}

DarkRP.createCategory{
    name = "Food",
    categorises = "entities",
    startExpanded = true,
    color = Color(219, 255, 0, 255),
    canSee = function(ply) return table.HasValue({TEAM_CHEF}, ply:Team()) end,
    sortOrder = 4
}