--[[-------------------------------------------------------------------------
Playerspawn
---------------------------------------------------------------------------]]
local function playerspawn(ply)
	local Team = ply:Team()
	local admin = ply:IsAdmin()
	----------------------------
	if Team == TEAM_VISTOR and not admin then
		ply:StripWeapons()
	end 
	---------------------------
	if not ply:IsAlien() then
		ply:SetRunSpeed(GAMEMODE.Config.runspeed)
		ply:SetWalkSpeed(GAMEMODE.Config.walkspeed)
		ply:SetModelScale(1)
		ply:SetGravity(1)
	end
end
hook.Add("PlayerSpawn", "bmrp_playerspawned", playerspawn)

--[[-------------------------------------------------------------------------
Change teams
---------------------------------------------------------------------------]]
local function TeamChange(ply, before, after)
	----- smart spawn
	timer.Simple(2, function()
		teambefore = ply:getJobTable().category
		ply:SetNWString("teambefore",teambefore)
	end)

	if (ply:GetNWString( "teambefore" ) != ply:getJobTable().category) and not ply:GetNWBool("norespawn") then
		ply:KillSilent()
	end
	if ply:GetNWBool("norespawn",true) then
		timer.Simple(2, function()
			ply:SetNWBool("norespawn",false)
		end)
	end
end
hook.Add("OnPlayerChangedTeam", "bmrp_jobchange", TeamChange)

--[[-------------------------------------------------------------------------
Security Stuff
---------------------------------------------------------------------------]]
local securityguard = table.ValuesToKeys({
	"models/heartbit_female_guards3_pm.mdl",
	"models/player/bms_guard.mdl",
})


function SuitChecker()
	for k,ply in pairs (player.GetAll()) do
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if securityguard[ply:GetModel()] and ply:IsSecurity() and ply:Alive() and not ply:HasWeapon("stunstick") then
			SuitUp(ply, "")
		else if not securityguard[ply:GetModel()] and ply:IsSecurity() and ply:HasWeapon("stunstick") then
			SuitDown(ply)
		end
		end
	end
end
hook.Add("Think", "bmrp_security-engine", SuitChecker)


--[[-------------------------------------------------------------------------
Xenian capture/handcuffs
---------------------------------------------------------------------------]]
hook.Add("CuffsCanHandcuff", "bmrp_xen_capture", function(ply, targ)
	if ply:IsSurvey() then
		if not targ:IsAlien() then
			return false
		end
	elseif ply:IsBio() then
		if targ:IsAlien() then
			return true
		end
	end
end)

timer.Create("bmrp_xen_capture", .25, 0, function()
	for k,ply in pairs(player.GetAll()) do
		if ply:IsHandcuffed() and ply:IsAlien() then
			local cuffed, cuffs = ply:IsHandcuffed()
			local kidnapper = cuffs:GetKidnapper()
			if IsValid(kidnapper) and kidnapper:IsPlayer() then
				if not kidnapper:IsSurvey() then return end
				if GetLocation(kidnapper) != "Xen" and GetLocation(ply) == "Xen" then
					local pos = DarkRP.findEmptyPos(kidnapper:GetPos(),{},600, 30, Vector(16, 16, 64))
					if pos then
						ply:SetNWBool("xenallowed",true)
						ply:SetPos(pos)
						SpawnXenFlash(ply:GetPos())
					end
				end
			end
		end
	end
end)



--[[-------------------------------------------------------------------------
Donator Stuff
---------------------------------------------------------------------------]]
function supporterinv(ply)
	if ply:GetUserGroup() == "supporter" then
		if ply:IsBlackMesa() then
			timer.Simple(2, function() ply:Give("itemstore_pickup") end)
		end
	end
end

hook.Add("OnPlayerChangedTeam", "bmrp_donate", supporterinv)
hook.Add("PlayerSpawn", "bmrp_donate_hoook", supporterinv) 
