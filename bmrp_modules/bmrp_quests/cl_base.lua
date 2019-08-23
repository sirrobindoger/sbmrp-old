if SERVER then return end


surface.CreateFont("sBMRP.notify", {
	font = "ZektonRG-Regular",
	size = 17,
	weight = 100,
	antialias = true,
	outline = false,
	additive = true,
	shadow = true,
	underline = true
})

concommand.Add("descape", function()
	if QuestMenu then
		QuestMenu:Close()
		QuestMenu = nil
	end
end)

NOTIFY_POS = {
	["TOP_RIGHT"] = {780, 0}
}

function QuestNotify(POS, QUEST_TITLE, QUEST_DIR)
	if QuestMenu then QuestMenu:Close() end
	QuestMenu = vgui.Create("DFrame")
	QuestMenu:SetPos(2000,ScrH() * NOTIFY_POS[POS][2]/720)
	QuestMenu:LerpPositions(.5,true)
	QuestMenu:SetPos( ScrW() * 0.609375,ScrH() * 0 )

	QuestMenu:SetSize( ScrW()*500/1280, ScrH()*100/720 )
	QuestMenu:SetDraggable( true )
	--QuestMenu:SlideDown(.7)
	QuestMenu:SetTitle("")
	QuestMenu:ShowCloseButton(false)
	function QuestMenu:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color(50,50,50, 255) )
		surface.SetDrawColor( 50,50,50, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local text = vgui.Create("RichText", QuestMenu)
	text:Dock(FILL)
	text:SetPos(10,20)
	text:SetContentAlignment(4)
	text:SetToFullHeight()
	text:SetVerticalScrollbarEnabled(false)
	local numoflines = 0
	for k,v in pairs(QUEST_DIR.Text) do
		if !QUEST_DIR.Colors[k] then QuestMenu:Close() return end
		text:InsertColorChange(QUEST_DIR.Colors[k][1], QUEST_DIR.Colors[k][2], QUEST_DIR.Colors[k][3], QUEST_DIR.Colors[k][4] or 255)
		text:AppendText(v)
		if v:find("\n") then
			numoflines = numoflines + 1
		end
		text:SetWrap(true)
	end
	function text:PerformLayout()
		text:SetFontInternal("sBMRP.notify")
	end

	

	local header = vgui.Create("DFrame", QuestMenu)
	header:SetPos(0,0)
	header:SetTitle("")
	header:SetDraggable(false)
	header:ShowCloseButton(false)
	header:SetSize( ScrW()*500/1280, ScrH()*19/720)
	function header:Paint(w,h)
		--draw.RoundedBox( 0, 0, 0, w, h, Color(100,100,100, 255) )
		surface.SetDrawColor( 100,100,100, 255 )
		surface.DrawRect( 0, 0, w, h )
	end		
	local headertext = vgui.Create("DLabel", header)
	headertext:SetPos(5, 0)
	headertext:CenterVertical(.5)
	headertext:SetFont("sBMRP.notify")
	headertext:SetColor(Color(255,255,255))
	headertext:SetText(QUEST_TITLE)
	headertext:SetWrap(false)
	headertext:SizeToContents()

	local textheight = numoflines *17

	local width, height = QuestMenu:GetSize()
	print("TextHeight---> " .. textheight)
	print("Height---> " .. height)
	print("TextHeight-Height---> " .. textheight-height)
	print("NewHeight --->" .. newheight)
	newheight = height + (height-textheight)
	if newheight > 0 then 
		
		QuestMenu:SetSize(width, newheight)
	end

end

net.Receive("sBMRP.Quests",function ()
	local pos = net.ReadString()  or "TOP_RIGHT"
	if pos == "DELETE" then pcall(function() QuestMenu:Close() end) return end
	local questinfo = net.ReadTable()
	local title = questinfo.title
	local directions = questinfo.directions

	QuestNotify(pos, title, directions)
end)

net.Receive("sBMRP.DrawHalo",function()
	local halos = net.ReadCompressedTable()

	if next(halos) != nil then
		LocalPlayer().Halos = halos
	else
		LocalPlayer().Halos = false
	end
end)


if QuestMenu then

	pcall(function() QuestMenu:Close() end)
	QuestMenu = nil
end


--[[-------------------------------------------------------------------------




---------------------------------------------------------------------------]]