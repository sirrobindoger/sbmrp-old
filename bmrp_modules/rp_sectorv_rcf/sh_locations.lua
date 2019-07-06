sBMRP.locationnames = {}
sBMRP.LocList = {}
--[[-------------------------------------------------------------------------
Quick access loc tables
---------------------------------------------------------------------------]]
sBMRP.LocList.Xen = {
	["Xen"] = true,
	["Xenian Cave"] = true,
	["Gonarch Lair"] = true,
	["Xenian Spawn"] = true
}

sBMRP.LocList.Topside = {
	["Topside Entrance"] = true,
	["Topside Parking Lot"] = true,
	["HECU Base"] = true,
	["Topside Lobby"] = true,
	["Parking Lot Elevator"] = true,
	["Topside Underground"] = true,
	["Ventilation Shaft"] = true,
	["Topside"] = true,
}

sBMRP.LocList.Biosector = {
	["Bio Sector Lab 1"] = true,
	["Bio Sector Lab 2"] = true,
	["Bio Sector Lab 3"] = true,
	["Bio Sector Main Lab"] = true,
	["Bio Sector"] = true,
}

--[[-------------------------------------------------------------------------
sBMRP Locations
---------------------------------------------------------------------------]]

if game.GetMap() == "rp_sectorc_s" then
	table.insert(sBMRP.locationnames,{"Rift",Vector(-12506.098632813,-989.16461181641,286.60958862305),Vector(-11933.997070313,-1150.001953125,-112.37423706055)})

	table.insert(sBMRP.locationnames,{"Gonarch Lair",Vector(7098.5668945313,1623.1097412109,-271.58898925781),Vector(3751.6201171875,-1233.2895507813,1136.5404052734)})
	table.insert(sBMRP.locationnames,{"Xenian Cave",Vector(3284.3041992188,-4713.1157226563,-286.81982421875),Vector(1371.0236816406,-8697.5986328125,-2389.3171386719)})
	table.insert(sBMRP.locationnames,{"Xenian Spawn",Vector(9000.5234375,-10320.479492188,-101.16801452637),Vector(6111.4965820313,-8218.0576171875,-1053.1689453125)})

	table.insert(sBMRP.locationnames,{"Xen",Vector(1082.2784423828,-9863.03515625,-2590.9377441406),Vector(7520.4252929688,3365.5139160156,1773.4493408203)})
	table.insert(sBMRP.locationnames,{"HECU Base",Vector(-2807.275879,-732.159241,567.249573),Vector(-5563.524902,384.642731,821.905457)})
	table.insert(sBMRP.locationnames,{"Topside Entrance",Vector(-2409.415039, -1720.561646, 845.073547),Vector(-1609.948120, -2699.017578, 564.176758)})
	table.insert(sBMRP.locationnames,{"Topside Parking Lot",Vector(-6674.695313, -1600.678711, 486.844330),Vector(-3730.725098, -4524.578125, 997.631897)})
	table.insert(sBMRP.locationnames,{"Sector H",Vector(-6044.6728515625,994.28479003906,1282.7595214844),Vector(-9646.9599609375,-426.29504394531,545.421875)})
	table.insert(sBMRP.locationnames,{"Topside Tram Station",Vector(-413.104828, -2111.416748, 1381.952515),Vector(-2676.043213, -3573.435547, 50.428474)})
	table.insert(sBMRP.locationnames,{"Topside Lobby",Vector(-10927.525391, -443.453094, 1080.224121),Vector(-9334.310547, -1456.305054, 283.680664)})
	table.insert(sBMRP.locationnames,{"Parking Lot Elevator",Vector(-4774.485840, -3776.471680, 850.410217),Vector(-4964.471191, -3574.090576, -82.026550)})
	table.insert(sBMRP.locationnames,{"Topside Underground",Vector(-4365.741699, -4053.309814, 50.468201),Vector(-5437.611816, -383.447540, 336.467896)})
	table.insert(sBMRP.locationnames,{"Ventilation Shaft",Vector(-4959.451660, -2089.336670, 594.332214),Vector(-4710.870117, -2332.955811, -708.270081)})

		table.insert(sBMRP.locationnames,{"Topside",Vector(-9624.730469, -103.092438, 423.933105),Vector(-1616.055176, -1717.239624, 855.260925)})
	table.insert(sBMRP.locationnames,{"Sector A Security Room",Vector(-10412.298828,-1239.380859,-256.606445),Vector(-10663.860352,-618.754700,-60.018631)})
	table.insert(sBMRP.locationnames,{"Sector A Restroom",Vector(-9914.382813, -1248.363159, -90.837036),Vector(-9516.666016, -1707.104980, -268.652740)})
	table.insert(sBMRP.locationnames,{"Sector A Lab 1",Vector(-11264.538086,-893.771729,-63.702896),Vector(-10846.016602,-634.912354,-253.795746)})
	table.insert(sBMRP.locationnames,{"Sector A Lab 2",Vector(-11272.318359,-370.406067,-290.014526),Vector(-10749.855469,333.548676,69.050468)})
	table.insert(sBMRP.locationnames,{"Sector A Lab 3",Vector(-11272.318359,-370.406067,-256.014526),Vector(-12214.122070,11.295838,-62.144188)})
	table.insert(sBMRP.locationnames,{"Sector A Lab 4",Vector(-11806.405273,-635.380737,-270.877167),Vector(-11296.560547,-1156.130859,80.841766)})
	table.insert(sBMRP.locationnames,{"Sector A Xen Teleporter",Vector(-13675.705078,42.873905,339.552917),Vector(-12076.139648,-1003.819336,-464.552429)})
	table.insert(sBMRP.locationnames,{"Sector A Cafe",Vector(-7058.286621, -1032.131104, -125.840302),Vector(-7543.797363, -246.835449, -275.438141)})
	table.insert(sBMRP.locationnames,{"Sector A Corridor",Vector(-6821.401367, -1251.251343, -128.884842),Vector(-7619.587891, -1036.770508, -267.537933)})
	table.insert(sBMRP.locationnames,{"Sector A Tram Station",Vector(-7299.680176,1961.003906,315.674377),Vector(-9485.122070,-1452.933105,-778.312683)})
	table.insert(sBMRP.locationnames,{"Sector A Tram Station",Vector(-8483.285156, -1483.649048, 32.597389),Vector(-8001.805176, -2068.462158, -403.010620)})
	table.insert(sBMRP.locationnames,{"Multisector Junction",Vector(-6424.829590, -1047.823242, 458.271667),Vector(-6830.276855, -1452.199707, -279.917084)})
	table.insert(sBMRP.locationnames,{"Sector A Staircase",Vector(-10769.560547, -390.730225, 907.169922),Vector(-9851.692383, 118.393280, -467.809204)})
	table.insert(sBMRP.locationnames,{"Sector A Staircase",Vector(-10747.308594, -487.449829, 738.208984),Vector(-10110.795898, 203.674103, 517.855713)})

	table.insert(sBMRP.locationnames,{"Sector A",Vector(-13856.784180,354.020020,-480.311707),Vector(-9525.233398,-1416.123047,504.963776)})
	table.insert(sBMRP.locationnames,{"Sector A Elevator",Vector(-10461.849609, -1328.819336, 829.468628),Vector(-10092.453125, -1784.527100, -395.212463)})
	table.insert(sBMRP.locationnames,{"Bio Sector Lab 1",Vector(-2126.222412, -3274.173340, -76.835297),Vector(-1611.608398, -2700.826416, -230.001068)})
	table.insert(sBMRP.locationnames,{"Bio Sector Lab 2",Vector(-2383.818848, -2329.128662, -67.199409),Vector(-2920.980957, -2785.801514, -236.147583)})
	table.insert(sBMRP.locationnames,{"Bio Sector Lab 3",Vector(-2156.546387, -2313.428467, -91.989326),Vector(-1429.923462, -2672.828125, -241.815552)})
	table.insert(sBMRP.locationnames,{"Bio Sector Main Lab",Vector(-1903.022949, -3290.750244, 39.463791),Vector(-2421.039795, -4068.249268, -240.266907)})
		table.insert(sBMRP.locationnames,{"Bio Sector",Vector(-1898.773071,-3990.525391,-248.276398),Vector(-2905.365723,-1661.649170,155.706757)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 1",Vector(-3366.358398,-1481.771484,-232.367706),Vector(-3073.752197,-965.234253,-36.687782)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 2",Vector(-3697.277344,-1807.172241,-235.233948),Vector(-4055.693359,-1269.069214,-41.257652)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 3",Vector(-4847.770508, -95.423203, -111.738312),Vector(-5172.493652, -413.248596, -319.733032)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 3",Vector(-5200.968750, -392.848938, -100.683167),Vector(-4839.809570, -806.946838, -319.666718)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 4",Vector(-5170.836914, -785.273071, -126.060944),Vector(-5547.352051, -290.013977, -328.753845)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 5",Vector(-5502.191406, -778.190674, -324.732727),Vector(-5955.830078, -530.707642, -153.707703)})
	table.insert(sBMRP.locationnames,{"Sector C Lab 6",Vector(-5470.387695, -1550.985352, -119.416138),Vector(-5755.708984, -1026.757080, -339.558258)})
	table.insert(sBMRP.locationnames,{"Sector C Enterance",Vector(-5996.100098, -1342.561035, -95.774582),Vector(-6424.329590, -1176.609131, -256.456604)})

	table.insert(sBMRP.locationnames,{"Sector C Tram Station",Vector(61.546783, 1086.345825, 441.823059),Vector(-2414.739258, -1129.254395, -691.79907)})

	table.insert(sBMRP.locationnames,{"Sector C Locker Room",Vector(-6558.045898,968.227600,-381.548157),Vector(-5542.659180,-170.103485,-36.064056)})
	table.insert(sBMRP.locationnames,{"AMS Chamber",Vector(-5386.953613,-1500.900635,-695.280579),Vector(-2608.192627,-4478.685059,-1776.814209)})
	table.insert(sBMRP.locationnames,{"Service Tunnel",Vector(-7022.563965, -1034.354980, -88.559280),Vector(-6578.231934, 1034.522461, -299.639587)})
	table.insert(sBMRP.locationnames,{"Sector D Lab",Vector( -5930.024414, -3117.835693, -8.396614),Vector(-5341.229492, -2584.570068, -319.631409)})

		table.insert(sBMRP.locationnames,{"Sector C",Vector(-1158.375854,-4013.810791,77.264313),Vector(-6011.024902,412.513031,-607.998718)})

	table.insert(sBMRP.locationnames,{"Sector D Atrium",Vector(-6150.604004, -2202.554688, 457.409790),Vector(-7008.967773, -1441.504272, -400.323151)})
	table.insert(sBMRP.locationnames,{"Sector D Conference Room",Vector(-7024.562012, -2200.279297, -128.316818),Vector(-7262.903809, -1437.356201, -291.812469)})
	table.insert(sBMRP.locationnames,{"Sector D Tram Station",Vector(-5796.801270, -3291.895752, 304.328339),Vector(-7749.785156, -5058.060547, -368.289490)})
	table.insert(sBMRP.locationnames,{"Sector D Elevator",Vector(-6405.660156, -5344.047852, -88.971130),Vector(-6747.342285, -5011.734863, -1165.615967)})
	table.insert(sBMRP.locationnames,{"Old Storage Facility",Vector(-6460.409180, -1913.391846, -488.057251),Vector(-10313.464844, -6267.962402, -1796.778564)})

		table.insert(sBMRP.locationnames,{"Sector D",Vector(-5977.900879, -1426.087158, 470.736755),Vector(-7021.045410, -3295.386475, -255.406372)})
	
	table.insert(sBMRP.locationnames,{"Administrator Office",Vector(-8445.008789, -2948.125000, 145.284637),Vector(-8919.926758, -2245.051270, -306.407074)})
	table.insert(sBMRP.locationnames,{"Jail",Vector(-7927.189941, -2685.702881, -37.215248),Vector(-7585.955078, -3202.347900, -297.974854)})

	table.insert(sBMRP.locationnames,{"Sector B Enterance",Vector(-7901.445801, -1991.870239, 30.585373),Vector(-7433.161133, -1376.621582, -395.137939)})
	table.insert(sBMRP.locationnames,{"Sector B Elevator",Vector(-7289.021484, -3128.812256, 732.834167),Vector(-7572.153809, -3414.557617, -338.486267)})
	table.insert(sBMRP.locationnames,{"Sector B Hangar",Vector(-6742.805176, -3480.156006, 961.765381),Vector(-9722.073242, -2173.113525, 431.038025)})

		table.insert(sBMRP.locationnames,{"Sector B",Vector(-7000.384766, -1981.233154, -372.548035),Vector(-8450.850586, -2729.565918, 359.742493)})
		table.insert(sBMRP.locationnames,{"Sector B",Vector(-7243.549805, -2700.562744, -1.543182),Vector(-7597.800781, -3138.128662, -264.575073)})


		table.insert(sBMRP.locationnames,{"Tram",Vector(-7339.092285, 1985.572998, 598.660583),Vector(-579.495972, 1056.513428, -769.497528)})
		table.insert(sBMRP.locationnames,{"Tram",Vector(6069.286133,239.049194,-373.228607),Vector(-8454.666016,-3010.634277,175.476715)})

end


