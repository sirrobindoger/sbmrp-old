if SERVER then return end


surface.CreateFont("sBMRP-notify", {
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
	if sBMRP.QuestMenu then
		sBMRP.QuestMenu:Close()
		sBMRP.QuestMenu = nil
	end
end)

NOTIFY_POS = {
	["TOP_RIGHT"] = {780, 0}
}

function QuestNotify(POS, QUEST_TITLE, QUEST_DIR)
	sBMRP.QuestMenu = vgui.Create("DFrame")
	sBMRP.QuestMenu:SetPos(2000,ScrH() * NOTIFY_POS[POS][2]/720)
	sBMRP.QuestMenu:LerpPositions(.5,true)
	sBMRP.QuestMenu:SetPos( ScrW() * 0.609375,ScrH() *  0 )

	sBMRP.QuestMenu:SetSize( 500, 100 )
	sBMRP.QuestMenu:SetDraggable( true )
	--sBMRP.QuestMenu:SlideDown(.7)
	sBMRP.QuestMenu:SetTitle("")
	sBMRP.QuestMenu:ShowCloseButton(false)
	local fadetime = math.huge + os.time()
	local curcolor = 255

	
	function sBMRP.QuestMenu:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color(50,50,50, 255) )
		surface.SetDrawColor( 50,50,50, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	local moving = false
	function sBMRP.QuestMenu:CloseDerma()
		sBMRP.QuestMenu:LerpPositions(.1,true)
		sBMRP.QuestMenu:SetPos(ScrH() * 2.8,ScrH() * 0)
		moving = true
	end
	
	function sBMRP.QuestMenu:Think()
		if (sBMRP.QuestMenu:GetPos() >= ScrH() * 2.5 and moving) then
			sBMRP.QuestMenu:Close()
			sBMRP.QuestMenu = nil
		end
	end

	local text = vgui.Create("RichText", sBMRP.QuestMenu)
	text:Dock(FILL)
	text:SetPos(10,20)
	text:SetContentAlignment(4)
	text:InsertColorChange(255,255,255,255)
	text:SetToFullHeight()
	text:SetFontInternal("sBMRP-notify")
	text:SetText(QUEST_DIR)
	text:SetWrap(true)
xdcxz
	local header = vgui.Create("DFrame", sBMRP.QuestMenu)
	header:SetPos(0,0)
	header:SetTitle("")
	header:SetDraggable(false)
	header:ShowCloseButton(false)
	header:SetSize(500, 25)
	function header:Paint(w,h)
		--draw.RoundedBox( 0, 0, 0, w, h, Color(100,100,100, 255) )
		surface.SetDrawColor( 100,100,100, 255 )
		surface.DrawRect( 0, 0, w, h )
	end		
	local headertext = vgui.Create("DLabel", header)
	headertext:SetPos(5, 0)
	headertext:CenterVertical(.5)
	headertext:SetFont("sBMRP-notify")
	headertext:SetColor(Color(255,255,255))
	headertext:SetText(QUEST_TITLE)
	headertext:SetWrap(false)
	headertext:SizeToContents()


end


timer.Simple(5, function() QuestNotify("TOP_RIGHT", "Test", "Testss\ntest")  end)
timer.Simple(10, function() sBMRP.QuestMenu:CloseDerma() end)


if sBMRP.QuestMenu then

	pcall(function() sBMRP.QuestMenu:Close() end)
	sBMRP.QuestMenu = nil
end

