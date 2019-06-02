if SERVER then
	--[[-------------------------------------------------------------------------
	MAIN FUNCTIONS
	---------------------------------------------------------------------------]]
	sBMRP.VOX = sBMRP.VOX || {}
		local function r(t) -- a better table.random
		local keys = {}
		for key, value in pairs(t) do
	        keys[#keys+1] = key 
	    end
	    index = keys[math.random(1, #keys)]
	    return t[index]
	end
	util.AddNetworkString("cvox_say")
	sBMRP.VOX.cVox = {'cvox_1.mp3', 'cvox_10.mp3', 'cvox_11.mp3', 'cvox_12.mp3', 'cvox_13.mp3', 'cvox_14.mp3', 'cvox_15.mp3', 'cvox_16.mp3', 'cvox_17.mp3', 'cvox_18.mp3', 'cvox_19.mp3', 'cvox_2.mp3', 'cvox_20.mp3', 'cvox_3.mp3', 'cvox_4.mp3', 'cvox_5.mp3', 'cvox_6.mp3', 'cvox_7.mp3', 'cvox_8.mp3', 'cvox_9.mp3'}
	sBMRP.VOX.cFailures = {'cvox_comms_off.mp3', 'cvox_flood_big.mp3', 'cvox_flood_small.mp3', 'cvox_flood_tram.mp3', 'cvox_powerfail_large.mp3', 'cvox_powerfail_small.mp3'}
	sBMRP.VOX.cVoxCascade = {'cvox_cascade_1.mp3', 'cvox_cascade_10.mp3', 'cvox_cascade_11.mp3', 'cvox_cascade_12.mp3', 'cvox_cascade_13.mp3', 'cvox_cascade_2.mp3', 'cvox_cascade_3.mp3', 'cvox_cascade_4.mp3', 'cvox_cascade_5.mp3', 'cvox_cascade_6.mp3', 'cvox_cascade_7.mp3', 'cvox_cascade_8.mp3', 'cvox_cascade_9.mp3'}
	sBMRP.VOX.cJohnson = { 'cvox_91degrees.mp3', 'cvox_accident.mp3', 'cvox_alldisappoint.mp3', 'cvox_amsfrozenfood.mp3',  'cvox_biocontain.mp3', 'cvox_birdsonsatellite.mp3', 'cvox_birdvendorr.mp3', 'cvox_bringyourkid.mp3', 'cvox_casserolecontraband.mp3', 'cvox_catstrash.mp3', 'cvox_centralpowergrid.mp3', 'cvox_cometoams.mp3', 'cvox_contactsexpire.mp3', 'cvox_creategod.mp3', 'cvox_ctram.mp3', 'cvox_duolingo.mp3', 'cvox_firecracker.mp3', 'cvox_gatfay.mp3', 'cvox_governmentofficials.mp3', 'cvox_hermit.mp3', 'cvox_imdead.mp3', 'cvox_limbtolimb.mp3', 'cvox_livetargets.mp3', 'cvox_lukewarmpizza.mp3', 'cvox_maintenance.mp3',  'cvox_nodarpa.mp3', 'cvox_notnekos.mp3', 'cvox_otis.mp3', 'cvox_peanutbutter.mp3', 'cvox_petsentientcasserole.mp3', 'cvox_pornslug.mp3', 'cvox_reactorclaim.mp3', 'cvox_redspy.mp3', 'cvox_runlowmicrowave.mp3', 'cvox_sectorcheadcrabs.mp3', 'cvox_sentientcasserole.mp3', 'cvox_sick.mp3', 'cvox_stoptramsuicide.mp3', 'cvox_surveysurvey.mp3', 'cvox_testsubjects.mp3', 'cvox_toyotahilux.mp3', 'cvox_weapondev.mp3', 'cvox_xenianmeth.mp3', 'cvox_xenopork.mp3', 'cvox_xenpizza.mp3', 'cvox_yourere.mp3'}
	sBMRP.VOX.cJohnsonCascade = {'cvox_4billion.mp3', 'cvox_anyoneleft.mp3','cvox_infinitevoid.mp3','cvox_negative582.mp3','cvox_rabiddogs.mp3',}

	--[[-------------------------------------------------------------------------
	AUTOMATIC sBMRP.VOX
	---------------------------------------------------------------------------]]
	local randomline = r(sBMRP.VOX.cJohnson)
	local cascadenum = 1
	local voxnum = 1
	sBMRP.VOX.State = 1
	sBMRP.VOX.StateDisclaimers = { -- don't ask
		[0] = "0: Off",
		[1] = "1: cVox",
		[2] = "2: cVox Cascade",
		[3] = "3: cJohnson",
		[4] = "4: BM:S Vox",
		[5] = "5: BM:S Cascade",
	}
	sBMRP.VOX.Paths = {
		cJohnson = "cjohnson/",
		cVox = "cvox/",
		cVoxCascade = "cvox/cascade/",
		BMSVox = "vox/"

	}
	sBMRP.VOX.VoxLocations = {
		{"Topside",Vector(-9930.9150390625,-965.42504882813,721.28070068359),80,0.5},
		{"Sector A Elevator",Vector(-10294.462890625,-1038.7280273438,-143.98173522949),80,0.5}, 
		{"Sector A Labs",Vector(-11144.450195313,-506.85906982422,-168.76760864258),80,0.5},
		{"Sector A Teleporters",Vector(-12995.48828125,-296.11029052734,-275.03274536133),80,0.5},
		{"Sector A Tramstation",Vector(-8239.33203125,-971.05883789063,50.674354553223),80,0.5},
		{"Sector A to C tunnels",Vector(-6890.9692382813,-99.482955932617,-211.83834838867),80,0.5},
		{"Sector C Lockers",Vector(-5865.5390625,413.55822753906,-229.59399414063),80,0.5},
		{"Sector C Locker Hallway", Vector(-5042.9013671875,-7.4623680114746,-225.70129394531),80,0.5},
		{"Sector C IT Hallway", Vector(-4045.6821289063,-565.92321777344,-131.81768798828),80,0.5},
		{"Sector C Labs Hallway", Vector(-3539.7358398438,-1444.5537109375,-67.009315490723),80,0.5},
		{"Biolabs Gas", Vector(-2694.3120117188,-1992.8134765625,-106.24745941162),80,0.5},
		{"Biolabs", Vector(-2221.9211425781,-3651.361328125,6.7733497619629),80,0.5},
		{"AMS Hallways", Vector(-5856.0205078125,-1304.6120605469,-219.28689575195),80,0.5},
		{"Middle of AMS Elevator 1", Vector(-4880.7177734375,-1638.0032958984,-613.92449951172),80,0.5},
		{"Sector C Main Entrance",Vector(-3000.4479980469,-577.65747070313,-47.795288085938),80,0.5},
		{"Office Complex Entrance", Vector(213.38430786133,-3221.3225097656,-160.5661315918),80,0.5},
		{"Sector B", Vector(4385.2573242188,-1507.5706787109,-166.283203125),80,0.5},
	}
	sBMRP.VOX.Time = 60
	sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
	function sBMRP.VOX.AutoVox()
		if os.time() > sBMRP.VOX.VoxTime then
			sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
			local state = tonumber(sBMRP.VOX.State) or r({1, 4, 3})
			---- Off
		if state == 0 then
			sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
				return 
		elseif state == 1 then -- cVox
			sBMRP.VOX.Play(sBMRP.VOX.Paths.cVox .. r(sBMRP.VOX.cVox))
		elseif state == 2 then --cVox Cascade
			sBMRP.VOX.PlayLoud(sBMRP.VOX.Paths.cVoxCascade .. r(sBMRP.VOX.cVoxCascade))
		elseif state == 3 then --cJohnson
			sBMRP.VOX.Play(sBMRP.VOX.Paths.cJohnson .. r(sBMRP.VOX.cJohnson))
		elseif state == 4 then -- BM:S Vox
			sBMRP.VOX.Play(sBMRP.VOX.Paths.BMSVox .. "vox_" .. math.random(1,49) .. ".wav")
		elseif state == 5 then
			sBMRP.VOX.Play(sBMRP.VOX.Paths.BMSVox .. "vox_cascade_" .. math.random(1,28) .. ".wav")
		end

		
			
		end
	end
	hook.Add("Think", "bmrp_vox", sBMRP.VOX.AutoVox)

	--[[-------------------------------------------------------------------------
	CHAT COMMANDS
	---------------------------------------------------------------------------]]
	sBMRP.VOX.ChatCommands = {
		["setvox"] = function(ply, args)
			if !ply:IsAdmin() then
				ply:ChatPrint("You are not admin!")
			end
			if not args[1] then ply:ChatPrint("Invalid arugment, values: " .. table.concat(sBMRP.VOX.StateDisclaimers, ", ")) return end
			local state = tonumber(args[1])
			if state <= 6 and state >= 0 then
				sBMRP.VOX.State = state
				ply:ChatPrint("Set value to " .. sBMRP.VOX.StateDisclaimers[state])
			else
				ply:ChatPrint("Invalid arugment, values: " .. table.concat(sBMRP.VOX.StateDisclaimers, ", "))
			end
			return ""
		end,
		["voxtime"] = function(ply, args)
			if !ply:IsAdmin() then
				ply:ChatPrint("You are not admin!")
			end
			if not isnumber(tonumber(args[1])) then
				ply:ChatPrint("Please enter the time interval in seconds!")
			else
				sBMRP.VOX.Time = tonumber(args[1])
				sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
				ply:ChatPrint("Set vox interval to " .. args[1] .. " seconds!")

			end
			return ""
		end,
		["voxmute"] = function(ply, args)
			if ply then ply:ChatPrint("Chat command is not ready yet.") return end

		end,
	}

	for k,v in pairs(sBMRP.VOX.ChatCommands) do
		sBMRP.CreateChatCommand(k, v)
	end


	/*
	hook.Add("PlayerSay", "Vox-Commands", function(ply, text)
	    local ltext = string.lower(text)
	    local args = string.Split(ltext, " ")  
	    if sBMRP.VOX.ChatCommands[args[1]] != nil then
	        passargs = table.Copy(args)
	        table.remove(passargs, 1)
	        sBMRP.VOX.ChatCommands[args[1]](ply, passargs)
	        return ""
	    end
	end)
	*/
	--[[-------------------------------------------------------------------------
	sBMRP.VOX FUNCTIONS
	---------------------------------------------------------------------------]]
	function sBMRP.VOX.PlayLoud(voxsound, location) -- LOCATION IS OPTIONAL
		local cSay = {["sound"] = voxsound}
		if location then cSay["location"] = location end
		
		net.Start("cvox_say")
			net.WriteTable(cSay) 
		net.Broadcast() -- send nudes
	end

	function sBMRP.VOX.Play(voxsound, location) -- LOCATION IS OPTIONAL
		if not location then
			for k,v in pairs(sBMRP.VOX.VoxLocations) do
				sound.Play( voxsound, v[2],v[3],100,v[4] )
			end	
		else
			local v = sBMRP.VOX.VoxLocations[location] -- :]
			sound.Play( voxsound, v[2],v[3],100,v[4] )
		end
	end
else
	net.Receive("cvox_say",function()
		local cSay = net.ReadTable()
		local voxsound = cSay["sound"]
		if cSay["location"] then
			if cSay["location"] == GetLocation(LocalPlayer()) then
				surface.PlaySound(voxsound)
			end
		else
			surface.PlaySound(voxsound)
		end
	end)

end



--[[-------------------------------------------------------------------------
	---LEGECY sBMRP.VOX---
	local letters = {
		"alpha",
		"b",
		"c",
		"d",
		"i",
	}

	local prefix = {
		"doctor",
		"security officer",
		"agent",
		"captain",
		"officer",
		"sargeant",
	}

	local soundtype = {
		"doop",
		"deeoo",
		"dadeda",
	}
	local bnumbers = {
		"twenty",
		"thirty",
		"fourty",
		"fifty",
		"sixty",
		"seventy",
		"eighty",
		"ninty",
	}

	local numbers = {
		"one",
		"two",
		"three",
		"four",
		"five",
		"six",
		"seven",
		"eight",
		"nine",
		"ten"
	}

	local names = {
		"birdwell",
		"black",
		"charlie",
		"johnson",
		"juliet",
		"kilo",
		"kit",
		"may",
		"roger",
	}

	local location = {
		"sector " .. table.Random(letters),
		"test chamber " .. table.Random(numbers) .. " " .. table.Random(numbers) .. " " .. table.Random(numbers),
		"central command",
		"anomalous test lab _comma",
		"processing plant",
		"biological waste processing plant",
		"cryogenic test lab _comma",
		"decontamination chamber",
		"dimensional test lab _comma",
		"topside",
		"hydro plant",
		"administration _comma",
		"lambda reactor",
		"storage facility"

	}

	local reason = {
		"inspection",
		"questioning",
		"cleanup",
		"decontamination",
		"flooding report",
		"experimental test",
		"test report",
		"observation",
		"operations report",
	}
---------------------------------------------------------------------------]]