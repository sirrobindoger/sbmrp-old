
function SpawnPortals()
	for k,v in pairs({5008, 5149, 5150, 5152, 5156,5268,}) do
		SafeRemoveEntity(ents.GetMapCreatedEntity(v))
	end
	
	
	for k, v in pairs( ents.FindByClass( "portal_xen_*" ) ) do
		v:Remove()
	end

	local portal = nil
	local portallist = {
		
		{
			noalien=true,
			pos=Vector(7391.0590820313,-9207.099609375,-710.96875),
			dest={
				{Vector(-3490.4821777344,-1082.5817871094,-164.96875),Angle(0,90,0)},
			},
			aliendest={
				{Vector(-3576,-3702,-1268),Angle(0,90,0)},
				{Vector(-2969,-769,-188),Angle(0,90,0)},
				{Vector(-6832,712,-237),Angle(0,-135,0)},
				{Vector(-6381,-1777,-223),Angle(30,90,0)},
				--{Vector(-6912.5561523438,629.63995361328,-234.86169433594),Angle(0,0,0)},
			},
			destgravity=1,
			name="portal_XenToEarthL_entrance",
			arrivalmsg="You arrive on Earth.",
		},
		{
			noalien=false,
			pos=Vector(5269.740234, -8913.000000, -461.000000),
			dest={
				{Vector(-6688,-1809,111),Angle(0,90,0)},
			},
			destgravity=0.4,
			aliendest={
				{Vector(4641,-3365,223),Angle(0,90,0)},
				{Vector(4992,-1832,221),Angle(0,90,0)},
				{Vector(5116,371,254),Angle(0,-135,0)},
				--{Vector(6223,-6337,138),Angle(30,90,0)},
				--{Vector(-6912.5561523438,629.63995361328,-234.86169433594),Angle(0,0,0)},
			},
			name="portal_XenToEarthR_entrance",
			arrivalmsg="",
		},
	}
	
	
	

	timer.Simple(0, function()
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
						elseif portalelement == "aliendest" then
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
	end)
end

SpawnPortals()
hook.Add("PostCleanupMap", "gm_mapcleanup_portals", SpawnPortals)
hook.Add("InitPostEntity", "gm_mapinitialization_portals", function() timer.Simple(1,function() SpawnPortals();print("--Initial Portals!--") end) end)