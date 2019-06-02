--[[-------------------------------------------------------------------------
AMS Recode

This code overrides the default map AMS
---------------------------------------------------------------------------]]
AMS = AMS || {}


AMS.StateChanges = {
	[0] = function(state)
		
	end,
	[1] = function(state)

	end,
	[2] = function(state)

	end,
	[3] = function(state)

	end,
	[4] = function(state)

	end,

}



hook.Add("AMSStateChange", "bmrp-ams", function(state, prevstate)
	if AMS.StateChange[state] != nil then
		if state > prevstate then -- moving up a state
			AMS.StateChange[state](true)
		else
			AMS.StateChange[state](false) -- its moving down a state
		end	
	end
end)