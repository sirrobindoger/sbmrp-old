concommand.Add("tee",function ()
	for k,v in pairs(ents.GetAll()) do 
		if v:GetPos():WithinAABox(Vector(7277.736328125,-9325.5,-563.47277832031),Vector(7534.0014648438,-9109.5087890625,-819.39190673828)) then
			print(v:MapCreationID() .. " " .. v:GetClass() .. " " .. v:GetName())
		end
	end
end)
local function SpawnPortals()
	for k,v in pairs({5143, 5144, 5142,5282,5283,5284,5285,5286,5288,5289,5290 }) do
		pcall(function() ents.GetMapCreatedEntity(v):Remove() end)
	end
	

	for k, v in pairs( ents.FindInSphere(Vector(-8571.630859375,-7904.9389648438,-2850.7353515625),50) ) do
		v:Remove() --Contingency
	end

	
	for k, v in pairs( ents.FindByClass( "portal_xen_*" ) ) do
		v:Remove()
	end

	local portal = nil
	local portallist = {
		
		{
			noalien=true,
			pos=Vector(-5675.5,-11101,-2848),
			dest={
				{Vector(-13100.44140625,-846.84008789063,-412.96875),Angle(0,90,0)},
			},
			aliendest={
				{Vector(-13150.047851563,-948.74255371094,-348.96875),Angle(0,90,0)},
				{Vector(-11425.114257813,-1061.2156982422,-184.96875),Angle(0,90,0)},
				{Vector(-10207.090820313,-435.19815063477,-188.96875),Angle(0,-135,0)},
				{Vector(-8469.548828125,-1096.9293212891,-72.854202270508),Angle(30,90,0)},
				{Vector(-6912.5561523438,629.63995361328,-234.86169433594),Angle(0,0,0)},
			},
			destgravity=1,
			name="portal_XenToEarthL_entrance",
			arrivalmsg="You arrive on Earth.",
		},
		{
			noalien=true,
			pos=Vector(-5275.5,-11101,-2848),
			dest={
				{Vector(-13100.44140625,-846.84008789063,-412.96875),Angle(0,90,0)},
			},
			destgravity=0.4,
			aliendest={
				{Vector(-13150.047851563,-948.74255371094,-348.96875),Angle(0,90,0)},
				{Vector(-11425.114257813,-1061.2156982422,-184.96875),Angle(0,90,0)},
				{Vector(-10207.090820313,-435.19815063477,-188.96875),Angle(0,-135,0)},
				{Vector(-8469.548828125,-1096.9293212891,-72.854202270508),Angle(30,90,0)},
				{Vector(-6912.5561523438,629.63995361328,-234.86169433594),Angle(0,0,0)},
			},
			name="portal_XenToEarthR_entrance",
			arrivalmsg="You arrive on Earth.",
		},
		{
			noalien=false,
			pos=Vector(-8435.501953125,-7940.1127929688,-2949.96875),
			dest={
				{Vector(-5493.048828125,-11319.596679688,-2726.2145996094),Angle(0,90,0)},
			},
			destgravity=0.4,
			aliendest={
				{Vector(-5493.048828125,-11319.596679688,-2726.2145996094),Angle(0,90,0)},
			},
			name="portal_OldXenPortalToNew_entrance",
			arrivalmsg="You arrive at the Xenian breeding grounds.",
		},
	}
	
	
	

	
	for k,portalobj in pairs(portallist) do
		if portalobj["isexit"] == true then 
			portal = ents.Create("portal_xen_ex")
			portal:Spawn()
			portal:SetPos(portalobj["pos"])
		else
			portal = ents.Create("portal_xen_ent")
			portal:Spawn()
			portal:SetPos(portalobj["pos"])
			for kk,portalelement in pairs({"dest","destgravity","aliendest","name","arrivalmsg","noalien","blacklist"}) do
				if portalobj[portalelement] != nil then
					if portalelement == "dest" then
						portal.Destination = portalobj[portalelement]
					elseif portalelement == "alienexit" then
						portal.AlienDestination = portalobj[portalelement]
					elseif portalelement == "destgravity" then
						portal.DestinationGravity = portalobj[portalelement]
					elseif portalelement == "arrivalmsg" then
						portal:SetArrivalText(portalobj[portalelement])
					elseif portalelement == "name" then
						portal:SetName(portalobj[portalelement])
					elseif portalelement == "noalien" then
						portal:SetHumanOrEventOnly(portalobj[portalelement])
					elseif portalelement == "blacklist" then
						portal.Blacklist = portalobj[portalelement]
					end
				end
			end
		end
	end
end

hook.Add("PostCleanupMap", "gm_mapcleanup_portals", SpawnPortals)
hook.Add("InitPostEntity", "gm_mapinitialization_portals", function() timer.Simple(1,function() SpawnPortals();print("--Initial Portals!--") end) end)