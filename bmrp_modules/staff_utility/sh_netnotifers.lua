--[[-------------------------------------------------------------------------
Chat Notifers for sBMRP
---------------------------------------------------------------------------]]

sBMRP_Notify = {}

sBMRP_Notify["Info"] = {
	[1] = {0, 118, 204},
	[2] = {52, 158, 235} 
}

sBMRP_Notify["Error"] = {
	[1] = {201, 0, 10},
	[2] = {255, 0, 13}
}

sBMRP_Notify["Security"] = {
	[1] = {0, 213, 255},
	[2] = {40, 160, 184}
}

sBMRP_Notify["VOX"] = {
	[1] = {27, 158, 62},
	[2] = {4, 217, 61}	
}

sBMRP_Notify["Tip"] = {
	[1] = {201, 168, 0},
	[2] = {255, 213, 0}	
}


if SERVER then
	local ply = FindMetaTable("Player")
	util.AddNetworkString("sBMRP.Notifers")
	util.AddNetworkString("sBMRP.ChatText")

	function sBMRP.ChatNotify(plytab, tab, str)
		if !sBMRP_Notify[ tab ] then return end
		if !istable( plytab ) then return end
		if !isstring( str ) then return end

		local nettab = {}
		nettab[ "type" ] = tab
		nettab[ "msg" ] = str

		local rf = RecipientFilter()
		for k,v in pairs(plytab) do rf:AddPlayer(v) end
		net.Start("sBMRP.Notifers")
			net.WriteCompressedTable(nettab)
		net.Send(rf)
	end

	function ply:AddText(...) -- serverside "chat.AddText()"
		local nettab = {...}

		net.Start("sBMRP.ChatText")
			net.WriteCompressedTable(nettab)
		net.Send(self)
	end
else
	net.Receive("sBMRP.Notifers", function(len)
		local nettab = net.ReadCompressedTable()

		if !nettab[ "type" ] or !nettab[ "msg" ] then return end
		
		local color1 = Color(unpack(sBMRP_Notify[nettab["type"]][1]))
		local color2 = Color(unpack(sBMRP_Notify[nettab["type"]][2]))
		local notifyflag = "[" .. nettab["type"] .. "] "
		local message = nettab["msg"]
		chat.AddText(color1, notifyflag, color2, message)
	end)

	net.Receive("sBMRP.ChatText", function(len)
		local nettab = net.ReadCompressedTable()

		chat.AddText(unpack(nettab))
	end)

end