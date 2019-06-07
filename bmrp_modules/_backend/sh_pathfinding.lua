if SERVER then
	--[[-------------------------------------------------------------------------
	Path finding (https://wiki.garrysmod.com/page/Simple_Pathfinding)
	---------------------------------------------------------------------------]]
	local ply = FindMetaTable("Player")
	util.AddNetworkString("pathfinding")
	function Astar( start, goal )
		if ( !IsValid( start ) || !IsValid( goal ) ) then return false end
		if ( start == goal ) then return true end

		start:ClearSearchLists()

		start:AddToOpenList()

		local cameFrom = {}

		start:SetCostSoFar( 0 )

		start:SetTotalCost( heuristic_cost_estimate( start, goal ) )
		start:UpdateOnOpenList()

		while ( !start:IsOpenListEmpty() ) do
			local current = start:PopOpenList() // Remove the area with lowest cost in the open list and return it
			if ( current == goal ) then
				return reconstruct_path( cameFrom, current )
			end

			current:AddToClosedList()

			for k, neighbor in pairs( current:GetAdjacentAreas() ) do
				local newCostSoFar = current:GetCostSoFar() + heuristic_cost_estimate( current, neighbor )

				if ( neighbor:IsUnderwater() ) then // Add your own area filters or whatever here
					continue
				end

				if ( ( neighbor:IsOpen() || neighbor:IsClosed() ) && neighbor:GetCostSoFar() <= newCostSoFar ) then
					continue
				else
					neighbor:SetCostSoFar( newCostSoFar );
					neighbor:SetTotalCost( newCostSoFar + heuristic_cost_estimate( neighbor, goal ) )

					if ( neighbor:IsClosed() ) then

						neighbor:RemoveFromClosedList()
					end

					if ( neighbor:IsOpen() ) then
						// This area is already on the open list, update its position in the list to keep costs sorted
						neighbor:UpdateOnOpenList()
					else
						neighbor:AddToOpenList()
					end

					cameFrom[ neighbor:GetID() ] = current:GetID()
				end
			end
		end

		return false
	end

	function heuristic_cost_estimate( start, goal )
		// Perhaps play with some calculations on which corner is closest/farthest or whatever
		return start:GetCenter():Distance( goal:GetCenter() )
	end

	// using CNavAreas as table keys doesn't work, we use IDs
	function reconstruct_path( cameFrom, current )
		local total_path = { current }

		current = current:GetID()
		while ( cameFrom[ current ] ) do
			current = cameFrom[ current ]
			table.insert( total_path, navmesh.GetNavAreaByID( current ) )
		end
		return total_path
	end
	function drawThePath( path, time )
		local prevArea
		for _, area in pairs( path ) do
			debugoverlay.Sphere( area:GetCenter(), 8, time or 9, color_white, true	)
			if ( prevArea ) then
				debugoverlay.Line( area:GetCenter(), prevArea:GetCenter(), time or 9, color_white, true )
			end

			area:Draw()
			prevArea = area
		end
	end
	function ply:MapWayPoint(vector)
		local ply = self
		local vectorpath = {}
		if isvector(vector) then
			
			print("Mapping waypoint!")
			local start = navmesh.GetNearestNavArea( ply:GetPos() )
			local goal = navmesh.GetNearestNavArea( vector )
			local path = Astar( start, goal )
			if ( !istable( path ) ) then // We can't physically get to the goal or we are in the goal.
				print("Path is impossible!")
				return
			end	
			for k,v in pairs(path) do table.insert(vectorpath, v:GetCenter()) end
		end

		net.Start("pathfinding")
			if next(vectorpath) == nil then vectorpath = {false} end
			net.WriteTable(vectorpath)
		net.Send(ply)
	end
end






if CLIENT then
	surface.CreateFont("sBMRP-waypoint", {
		font = "ZektonRG-Regular",
		size = 17,
		weight = 100,
		antialias = true,
		outline = false,
		additive = true,
		shadow = true,
		underline = true
	})
	--timer.Simple(5, function() DermaTest("TOP_RIGHT") end)
	--timer.Simple(10, function() sBMRP.DermaTest:CloseDerma() end)
	net.Receive("pathfinding",function ()
		local vectorpath = net.ReadTable()
		if #vectorpath <= 1 then LocalPlayer().drawdir = nil return end
		LocalPlayer().drawdir = vectorpath
	end)
	hook.Add("PreDrawTranslucentRenderables", "bmrp_line-drawling", function()
		local pathlines = LocalPlayer().drawdir
		if !pathlines then return end
		local prevArea
		for _, area in pairs( pathlines ) do
			if ( prevArea ) then
				render.DrawLine( area, prevArea, Color(135,206,250), true )
				render.SetColorMaterial()
				render.DrawSphere( area, 1, 10, 10, Color( 135,206,250, 255 ) )

				render.DrawSphere( pathlines[1], 150, 30, 30, Color(135,206,250, 10 ) )
			end
			prevArea = area

		end
	end)
	local MAT_WRENCH = Material( "cityworker/wrench.png" )
    hook.Add( "HUDPaint", "bmrp_quest-drawling", function()
    	local pathlines = LocalPlayer().drawdir
    	if !pathlines then return end
        local screenPos = pathlines[1]:ToScreen()
--        surface.SetDrawColor( 255, 255, 255 )
--        surface.SetMaterial( MAT_WRENCH )
--        surface.DrawTexturedRect( screenPos.x - 16, screenPos.y - 16, 32, 32 )

        draw.SimpleTextOutlined( math.ceil( ( LocalPlayer():GetPos():Distance( pathlines[1] ) / 16 ) / 3.28084 ).."m (" .. GetLocation(pathlines[1]) .. ")", "sBMRP-waypoint", screenPos.x, screenPos.y + 16, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )
    end )
end