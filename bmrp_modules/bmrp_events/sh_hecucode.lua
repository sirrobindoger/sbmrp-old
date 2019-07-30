--[[-------------------------------------------------------------------------
HECU Code
---------------------------------------------------------------------------]]
SetGlobalString("HECUCode", "Green")

local HECU_Codes = {
	["Red"] = {
		color = {255,0,0, 156},
		text = "Evacuate Facility",
		canenterbmrf = true,
	},
	["Green"] = {
		color = {0,150,0, 156},
		text = "No Active Threats",
		canenterbmrf = false
	},
	["Black"] = {
		color = {0,0,0, 156},
		text = "Kill On Sight",
		canenterbmrf = true,
	},
	["Yellow"] = {
		color = {212, 184, 28, 156},
		text = "On Alert",
		cantenterbmrf = false,
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
	--[[-------------------------------------------------------------------------
	Logic processing
	---------------------------------------------------------------------------]]
	local function OnHECUCodeChanged(oldcode, newcode)
		local oldcodetbl = HECU_Codes[ oldcode ]
		local newcodetbl = HECU_Codes[ newcode ]
		ulx.logString("HECU Code Updated: " .. oldcode .. " --> " .. newcode .. "\n")
		for k,v in pairs(player.GetAll()) do
			v:AddText(Color(27, 158, 62),"[Vox]", Color(4, 217, 61), " The HECU Code has been updated from code ", Color(unpack(oldcodetbl.color)), oldcode, Color(4, 217, 61), " to " , Color(unpack(newcodetbl.color)), newcode,Color(4, 217, 61), "!")
		end
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




