if SERVER then
	--[[-------------------------------------------------------------------------
	Path finding (https://wiki.garrysmod.com/page/Simple_Pathfinding)
	---------------------------------------------------------------------------]]
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
	concommand.Add( "test_astar", function( ply )
		timer.Create("Navtest", 1, 60, function()
		// Use the start position of the player who ran the console command
		local start = navmesh.GetNearestNavArea( ply:GetPos() )

		// Target position, use the player's aim position for this example
		local goal = navmesh.GetNearestNavArea( Vector(-6064.652344, -3075.306396, -188.968750) )

		local path = Astar( start, goal )
		if ( !istable( path ) ) then // We can't physically get to the goal or we are in the goal.
			return
		end
		local vectorpath = {}
		for k,v in pairs(path) do table.insert(vectorpath, v:GetCenter()) end
		net.Start("pathfinding")
			net.WriteTable(vectorpath)
		net.Send(ply)
	end)
	end )
end






if CLIENT then

	--timer.Simple(5, function() DermaTest("TOP_RIGHT") end)
	--timer.Simple(10, function() sBMRP.DermaTest:CloseDerma() end)
	net.Receive("pathfinding",function ()
		local vectorpath = net.ReadTable()
		LocalPlayer().drawdir = vectorpath
		PrintTable(vectorpath)
	end)
	hook.Add("PreDrawTranslucentRenderables", "bmrp_line-drawling", function()
		local pathlines = LocalPlayer().drawdir
		if !pathlines then return end
		local prevArea
		for _, area in pairs( pathlines ) do
			if ( prevArea ) then
				render.DrawLine( area, prevArea, Color(255,255,255), true )
			end
			prevArea = area
		end
	end)
end