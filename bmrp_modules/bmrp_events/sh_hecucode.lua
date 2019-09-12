--[[-------------------------------------------------------------------------
HECU Code
---------------------------------------------------------------------------]]
SetGlobalString("HECUCode", "Green")

--[[-------------------------------------------------------------------------
Code declarlations

Flags:
color = Color() (the color of the code on the HUD in RGB)
text = string (What the subtext will appear as on the HUD)
canenterbmrf = bool (if the hecu are allowed to enter BMRF at that stage)
candamage = int (0 if they can't, 1 they are allowed to damage only on topside, 2 they can damage any team)
---------------------------------------------------------------------------]]


local HECU_Codes = {
	["Red"] = {
		color = {255,0,0, 156},
		text = "Active Threat(s)",
		canenterbmrf = true,
		candamage = 2,
		order = 3,
	},
	["Green"] = {
		color = {0,150,0, 156},
		text = "No Active Threat(s)",
		canenterbmrf = false,
		candamage = 0,
		order = 1,
	},
	["Black"] = {
		color = {0,0,0, 156},
		text = "Deadly Force Authorized",
		canenterbmrf = true,
		candamage = 2,
		order = 4,
	},
	["Yellow"] = {
		color = {212, 184, 28, 156},
		text = "Potential Active Threat(s)",
		cantenterbmrf = false,
		candamage = 1,
		order = 2,
	},
}


if SERVER then
	--[[-------------------------------------------------------------------------
	Meta functions
	---------------------------------------------------------------------------]]
	function sBMRP.SetHECUCode(code)
		if !HECU_Codes[ code ] then return end
		hook.Run("OnHECUCodeChanged", GetGlobalString("HECUCode", "Green"), code)

		SetGlobalString("HECUCode", code)
	end

	function sBMRP.GetHECUCode()
		return GetGlobalString("HECUCode", "Green")
	end

	local function HECUAntiRDM(att, targ)
		if att:IsHECU() and !targ:IsHECU() then
			local codeint = HECU_Codes[sBMRP.GetHECUCode()].candamage
			if sBMRP.LocList.Topside[targ] and codeint == 1 then
				return true
			elseif codeint == 2 then
				return true
			end
		end
	end
	hook.Add("AntiRDMOverride", "sBMRP_HECUDamage", HECUAntiRDM)
	--[[-------------------------------------------------------------------------
	Logic processing
	---------------------------------------------------------------------------]]
	local function OnHECUCodeChanged(oldcode, newcode)
		local oldcodetbl = HECU_Codes[ oldcode ]
		local newcodetbl = HECU_Codes[ newcode ]
		ulx.logString("HECU Code Updated: " .. oldcode .. " --> " .. newcode .. "\n")
		for k,v in pairs(player.GetAll()) do
			v:AddText(Color(27, 158, 62),"[Vox]", Color(4, 217, 61), " The HECU Code has been updated from code ", Color(unpack(oldcodetbl.color)), oldcode, Color(4, 217, 61), " to " , Color(unpack(newcodetbl.color)), newcode,Color(4, 217, 61), "! [" .. newcodetbl.text .. "]")
		end
		RunConsoleCommand("vox", newcodetbl.canenterbmrf and "buzwarn" or "deeoo", "alert", "code", oldcode:lower(), "is", "now", "on", "code", newcode:lower())
		--sBMRP.VOX.Play("hecu_code/code_" .. oldcode:lower() .. "_to_" .. newcode:lower() .. ".wav")
		-- if the old code can enter BMRF and the new code can't, update permissions
		if oldcodetbl.canenterbmrf and not newcodetbl.canenterbmrf then
			sBMRP.HECUAllowAll(false)
			sBMRP.LocationScan()
			sBMRP.ChatNotify( player.GetAdmins(),"Info", "Automatically removed the HECU to BMRF entry. (only admins can see this)")
		elseif not oldcodetbl.canenterbmrf and newcodetbl.canenterbmrf then -- the new code can enter BMRF
			sBMRP.HECUAllowAll(true)
			sBMRP.LocationScan()
			sBMRP.ChatNotify( player.GetAdmins(),"Info", "Automatically gave the HECU entry to BMRF. (only admins can see this)")

		end
	end
	hook.Add("OnHECUCodeChanged","bmrp_announcecode", OnHECUCodeChanged)

	--[[-------------------------------------------------------------------------
	Chat Commands
	---------------------------------------------------------------------------]]
	local codeRequest
	local function RequestCodeChange(ply, args)
		if ply:Team() != TEAM_HECUCOMMAND and ply:Team() != TEAM_ADMINISTRATOR and not ply:IsAdmin() then
			sBMRP.ChatNotify({ply}, "Error", "You job is not qualified to use this command!")
			return ""
		end
		if !HECU_Codes[ args ] or args == "Black" and not ply:IsAdmin() then
			sBMRP.ChatNotify({ply}, "Error", "Invalid code! Valid codes are: Green, Yellow, Red (case sensitive!).")
			return ""
		end

		--if not ply:IsAdmin() then
			if ply:Team() == TEAM_HECUCOMMAND then
				for k,rec in pairs(player.GetAll()) do
					if rec:Team() == TEAM_ADMINISTRATOR then
						sBMRP.ChatNotify({ply}, "Info", "Sent code request to the Administrator!")
						codeRequest = args
						sBMRP.ChatNotify({rec}, "Info", "The HECU Commander has requested a code change to code " .. args .. ".\nTo confirm, please type /confirmcode.")
						timer.Create("confirmcode_" .. rec:SteamID(), 15, 1, function()
							sBMRP.ChatNotify({rec, ply}, "Info", "Code request expired. Cancelling code change.")
						end)
						return ""
					end
				end
			else
				for k,rec in pairs(player.GetAll()) do
					if rec:Team() == TEAM_HECUCOMMAND then
						sBMRP.ChatNotify({ply}, "Info", "Sent code request to the HECU Commander!")
						codeRequest = args
						sBMRP.ChatNotify({rec}, "Info", "The Facility Administartor has requested a code change to code " .. args .. ".\nTo confirm, please type /confirmcode.")
						timer.Create("confirmcode_" .. rec:SteamID(), 15, 1, function()
							sBMRP.ChatNotify({rec, ply}, "Info", "Code request expired. Cancelling code change.")
							rec.codereq = nil
						end)
						return ""
					end
				end				
			end
			sBMRP.ChatNotify({ply}, "Error", "Missing Administrator/HECU Commander player!")
			return ""
		--end
	end
	sBMRP.CreateChatCommand("coderequest", RequestCodeChange, "Request a code change.", 10)

	local function ConfirmCodeChange(ply, args)
		if ply:Team() != TEAM_HECUCOMMAND and ply:Team() != TEAM_ADMINISTRATOR and not ply:IsAdmin() then
			sBMRP.ChatNotify({ply}, "Error", "You job is not qualified to use this command!")
			return ""
		end
		if !timer.Exists("confirmcode_" .. ply:SteamID()) then
			sBMRP.ChatNotify({ply}, "Error", "No codes to confirm right now!")

		else
			sBMRP.SetHECUCode(codeRequest or "Green")
			codeRequest = args
			timer.Remove("confirmcode_" .. ply:SteamID())
		end
	end
	sBMRP.CreateChatCommand("confirmcode", ConfirmCodeChange, "Confirm a code change", 10)
end




if CLIENT then
	local codefont = sBMRP.AppendFont("codefont", ScreenScale(10))

	hook.Add("HUDPaint", "hecu-code_hud", function()
		local ply = LocalPlayer()
		if not ply:IsHECU() then return end
		surface.SetFont(codefont)
		local codename = GetGlobalString("HECUCode", "Green")
		local titlename = "HECU Code: "

		local titlesize = surface.GetTextSize(titlename)
		local textsize = surface.GetTextSize(codename)
		local subtextsize = surface.GetTextSize(HECU_Codes[codename].text)
		local boxlength = 190

		local titlepos = 533 + math.abs(boxlength-titlesize)/2
		local codepos = 553 + math.abs(boxlength-textsize)/2
		local subpos = 533 + math.abs(boxlength-subtextsize)
		
		-- Box
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( ScrW() *(553/1280), ScrH()*(0/720), ScrW() *(boxlength/1280),ScrH() *(40/720))
		-- Header
		surface.SetDrawColor( 50,50,50, 255 )
		surface.DrawRect( ScrW() *(553/1280), ScrH()*(0/720),ScrW() *(boxlength/1280),ScrH()*(20/720) )
		-- Color box
		surface.SetDrawColor( unpack(HECU_Codes[codename].color))
		surface.DrawRect( ScrW() *(553/1280), ScrH()*(20/720),ScrW() *((boxlength)/1280), ScrH()*(20/720) )
		-- Title
		surface.SetTextColor(255,255,255,100)
		surface.SetTextPos(ScrW() *(titlepos/1280),0)
		surface.DrawText(titlename)
		-- Title 1
		surface.SetTextColor(unpack(HECU_Codes[codename].color))
		surface.SetTextPos(ScrW() *(titlepos*1.16 /1280),0)
		surface.DrawText(codename)

		-- subtext 1
		surface.SetTextColor(255,255,255)
		surface.SetTextPos(ScrW() *(subpos/1280),ScrH()*(20/720))
		surface.DrawText(HECU_Codes[codename].text)
	end)
end




