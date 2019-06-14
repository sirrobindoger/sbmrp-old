local CATEGORY_NAME = "Black Mesa RP"


--[[-------------------------------------------------------------------------
			VOX COMMANDS 													
---------------------------------------------------------------------------]]
StateDisclaimers = { -- don't ask
	"off",
	"cvox",
	"cvox-cascade",
	"cjohnson",
	"bms-vox",
	"bms-cascade",
}

function ulx.setvox(calling_ply, state)
	sBMRP.VOX.State = table.KeyFromValue(StateDisclaimers, state)
	ulx.fancyLog( player.GetAdmins(), "#P changed the VOX state to #s",calling_ply, state)
end

local setvox = ulx.command( CATEGORY_NAME, "ulx setvox", ulx.setvox, nil, false, false)
setvox:addParam{ type=ULib.cmds.StringArg, completes=StateDisclaimers, hint="Vox Alert State", error="invalid state \"%s\" specified", ULib.cmds.restrictToCompletes }
setvox:defaultAccess( ULib.ACCESS_ADMIN)
setvox:help( "Sets the vox state." )

function ulx.voxtime(calling_ply, time)
	sBMRP.VOX.Time = tonumber(time)
	sBMRP.VOX.VoxTime = os.time() + sBMRP.VOX.Time
	ulx.fancyLog( player.GetAdmins(), "#P changed the VOX time interval to #i seconds",calling_ply, time)
end
local voxtime = ulx.command(CATEGORY_NAME, "ulx voxtime", ulx.voxtime, nil, false, false )
voxtime:addParam{type=ULib.cmds.NumArg, min=10, max=720,default=60,hint="time(seconds)",ULib.cmds.round}
voxtime:defaultAccess(ULib.ACCESS_ADMIN)
voxtime:help("Sets the vox time in seconds.")
