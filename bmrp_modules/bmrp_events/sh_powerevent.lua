if SERVER then
	local POWER_EVENT = {}
	POWER_EVENT["SetupStage"] = {}
	POWER_EVENT["StageOne"] = {}
	POWER_EVENT["StageTwo"] = {}
	POWER_EVENT["StageThree"] = {}

	POWER_EVENT.name = "PowerEvent"
	SetGlobalString("generatorIDs", "")
	--[[-------------------------------------------------------------------------
	CanStart
	---------------------------------------------------------------------------]]

	POWER_EVENT["CanStart"] = function()
		if player.GetCount() < 10 then
			return false
		end
	end




	--[[-------------------------------------------------------------------------
	Stage(s)
	---------------------------------------------------------------------------]]
	local PowerSetup = POWER_EVENT["SetupStage"]

	PowerSetup["UpdateStage"] = function()
		local ent = ents.FindByName("gm_power")[1] or false
		if ent then
			if ent:IsOnFire() then
				sBMRP.ChatNotify(player.GetAll(), "Server", "Event ended.")
				return true, "END"
			end
		end
	end


	PowerSetup["Entities"] = {}
	local generatorEnts = {
		{"models/props_am/powersource.mdl", Vector(-13589.46, -538.12, -412.52), Angle(0,0,0)},
		{"models/props/hl10props/amsmachine00.mdl",  Vector(-5060.69, -3012.82, -1124.32), Angle(0,90,0)},
		{"models/props/hl16props/generator03.mdl",  Vector(-5957.46 ,-3499.58, -184.54), Angle(0,90,0)}
	}
	for k,v in pairs(generatorEnts) do
		print("Debug 0")
		PrintTable(v)
		table.insert(PowerSetup["Entities"],{
			"prop_physics", true, function(ent)
				print("Debug 1")
				print(v[1])
				ent:SetModel(v[1])
				ent:SetPos(Vector(v[2]))
				ent:SetAngles(Angle(v[3]))
				ent:SetName("gm_power")
				ent:DropToFloor()
				ent.pos = ent:GetPos()
				ent:Spawn()
				ent:SetNWInt("GMhealth", 100)
				ent:GetPhysicsObject():EnableMotion(false)
				SetGlobalString("generatorIDs", GetGlobalString("generatorIDs", "") .. ";" .. ent:EntIndex())
			end
		})
	end

	PowerSetup["Functions"] = {
		function()
			--sBMRP.ChatNotify(player.GetAll(), "Server", "AutoEvent - PowerEvent [test]")
		end,
	}

	PowerSetup["Timers"] = {
		--{1, 10, function() player.GetSirro():ChatPrint("haha") end}

	}


	sBMRP.Event.rEvents[ "PowerEvent" ] = POWER_EVENT

	concommand.Add("eset", function()
		print("----------")
		sBMRP.Event.SetInactive("PowerEvent")
		sBMRP.Event.SetActive("PowerEvent", "SetupStage")
	end)
end

if CLIENT then


	local function getIndexedEnt(str)
		local ent = {}
		local nocopy = {}
		local generatorIndex = string.Explode(";", str)
		for k,v in pairs(generatorIndex) do
			if IsValid(ents.GetByIndex(tonumber(v) or -100)) and not nocopy[ v ] then
				table.insert(ent, ents.GetByIndex(v))
				nocopy[ v ] = true
			end
		end
		return ent
	end


	hook.Add("PreDrawHalos", "gm_power-highlight", function()
		if not LocalPlayer():IsService() then return end
		local generatorIndex = getIndexedEnt(GetGlobalString("generatorIDs", ""))
		if generatorIndex == {} then return end
		for k,ent in pairs(generatorIndex) do			
			local genhlt = ent:GetNWInt("GMhealth", 100)
			local color = Color(255, genhlt*2.55,genhlt*2.55)
			halo.Add( {ent}, color, .5, .5, 1 )
		end
	end)
	local codefont = sBMRP.AppendFont("genfont", ScreenScale(10))

	hook.Add("HUDPaint", "gm_power-genhud", function()
		local ply = LocalPlayer()
		if not ply:IsService() then return end

		local generatorIndex = getIndexedEnt(GetGlobalString("generatorIDs", ""))

		if generatorIndex == {} then return end
		surface.SetFont(codefont)
		local boxlength = 200
		for k,v in ipairs(generatorIndex) do

			local offsety = 40 * k
			-- BG Box
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( ScrW() *(1081/1280), ScrH()*((offsety - 40)/720), ScrW() *(boxlength/1280),ScrH() *(40/720))
			-- Generator info
			surface.SetDrawColor( 60,60,60, 255 )
			surface.DrawRect( ScrW() *(1081/1280), ScrH()*((offsety - 40)/720),ScrW() *(110/1280),ScrH()*(40/720) )

			surface.SetTextColor(255,255,255)
			surface.SetTextPos(ScrW() *(1085/1280),offsety - 30)
			local distanceFromGen = math.Round(ply:GetPos():Distance(v:GetPos()) / 16 * .3) -- converts gmod units to feet to meters /shrug
			surface.DrawText("Gen: " .. k .. " | " .. distanceFromGen .. "m")
			surface.SetTextPos(0,50)
			

			local healthpercent = v:GetNWInt("GMHealth", 100)/100
			surface.SetDrawColor( 237, 24, 24, 255 )
			surface.DrawRect( ScrW() *(1186/1280), ScrH()*((offsety - 40)/720),ScrW() *((healthpercent*100)/1280), ScrH()*(40/720) )
			-- subtext 1
			surface.SetTextColor(255,255,255)
			surface.SetTextPos(ScrW() *(1205/1280),offsety - 30)
			surface.DrawText(math.Round(healthpercent*100) .. "%")


			

		end



	end)
end