sBMRP.Tax = sBMRP.Tax || {}

local math = math
local tonumber = tonumber

--[[-------------------------------------------------------------------------
Mayor tax Config (by Sirro)
---------------------------------------------------------------------------]]

sBMRP.Tax.NonTaxedJobs = { -- any job in here will not be affected by the tax
	[TEAM_ADMINISTRATOR] = true,
	[TEAM_SECURITY] = true,
	[TEAM_SECURITYCHEIF] = true,
	--[TEAM_ETC] = true,
}

sBMRP.Tax.AdminRanks = { -- these are ranks that can use the /tax command when they aren't Administrator
	["superadmin"] = true,
	["staff"] = true,
	["trialstaff"] = true,
}


sBMRP.Tax.MayorSensitive = true -- Should the server ONLY tax when someone is playing as a Administrator?

sBMRP.Tax.DefaultTaxRatio = 0 -- This is the tax ratio the server will start with (0 for no tax)

sBMRP.Tax.ResetOnMayorDeath = true -- when the Administrator dies, should the tax be reset back to the default value?

-- Below is the actual script itself

local function getMayor()
	for k,v in pairs(player.GetAll()) do
		if v:isMayor() then
			return v
		end
	end
	return false
end

--[[-------------------------------------------------------------------------
Chat command
---------------------------------------------------------------------------]]
sBMRP.Tax.TaxRatio = sBMRP.Tax.TaxRatio || sBMRP.Tax.DefaultTaxRatio
sBMRP.Tax.CollectedMoney = sBMRP.Tax.CollectedMoney || 0
local function taxCommand(ply, args)
	if !ply:isMayor() && !sBMRP.Tax.AdminRanks[ ply:GetUserGroup() ] then
		DarkRP.notify(ply, 1, 5, "Insufficent permissions!")
		return ""
	end

	if !args || !tonumber(args) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	else
		local number = math.Clamp( math.Round( tonumber(args) ), 0, 100 )

		sBMRP.Tax.TaxRatio = number
		if number == 0 then
			DarkRP.notifyAll(0, 10, "Administrator " .. ply:GetName() .. " has removed the salary tax!")
		else
			DarkRP.notifyAll(0, 10, "Administrator " .. ply:GetName() .. " has set the salary tax to " .. number .. "%!")
		end

		return ""
	end
end

if SERVER then
	DarkRP.defineChatCommand("tax", taxCommand)
end

DarkRP.declareChatCommand{
	command = "tax",
	description = "Tax your citizens as the Administrator.",
	delay = 1.5
}

--[[-------------------------------------------------------------------------
Tax deduction
---------------------------------------------------------------------------]]

local function doTax(ply, salary)
	if sBMRP.Tax.TaxRatio <= 1 || sBMRP.Tax.NonTaxedJobs[ ply:Team() ] || (sBMRP.Tax.MayorSensitive && !getMayor()) then return end



	local deduction = salary * (sBMRP.Tax.TaxRatio * .01 )
	local newsalary = math.Round( salary  -  deduction )
	local message = "You have recieved your salary of " .. DarkRP.formatMoney(newsalary) .. " (" .. DarkRP.formatMoney(deduction) .. " was deducted via taxing)."
	sBMRP.Tax.CollectedMoney = sBMRP.Tax.CollectedMoney + deduction

	return true, message, newsalary

end
hook.Add("playerGetSalary", "sBMRP.Tax_doTax", doTax)

local function resetOnMayorDeath(ply, before)
	if ply:isMayor() || tonumber(before) and before == TEAM_ADMINISTRATOR && sBMRP.Tax.ResetOnMayorDeath then

		sBMRP.Tax.TaxRatio = sBMRP.Tax.DefaultTaxRatio
		if sBMRP.Tax.DefaultTaxRatio == 0 then
			DarkRP.notifyAll(0, 10, "The salary tax has been removed due to the Administrator's death/demotion!")
		else
			DarkRP.notifyAll(0, 10, "The salary tax has been set to " .. sBMRP.Tax.DefaultTaxRatio .. "% due to the Administrator's death/demotion!")
		end
		sBMRP.Tax.CollectedMoney = 0
	end
end
hook.Add("PlayerDeath", "sBMRP.Tax_resetOnMayorDeath", resetOnMayorDeath)
hook.Add("OnPlayerChangedTeam", "sBMRP.Tax_resetOnMayorDeath", resetOnMayorDeath)
