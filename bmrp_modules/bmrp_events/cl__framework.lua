
EVENT_POS = {
	["TOP_RIGHT"] = {930, 0},
	["TOP_MIDDLE"] = {500, 0}
}

function EventNotify(POS,TITLE,SUBTEXT)
	if sNotify then sNotify:Close() end
	
	sNotify = vgui.Create("DFrame")
	sNotify:SetPos(ScrW() * EVENT_POS[POS][1]/1280, ScrH()*EVENT_POS[POS][2]/720)
	sNotify:SetSize(350,100)
	sNotify:SetTitle("")
	sNotify:ShowCloseButton(false)
	function sNotify:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color(50,50,50, 255) )
		surface.SetDrawColor( 50,50,50, 255 )
		surface.DrawRect( 0, 0, w, h )
	end

	local text = vgui.Create("RichText", sNotify)
	text:Dock(FILL)
	text:SetPos(10,20)
	text:SetContentAlignment(4)
	text:SetToFullHeight()
	text:SetVerticalScrollbarEnabled(false)
	text:SetFontInternal("sBMRP.notify")
	for k,v in pairs(SUBTEXT.Text) do
		if !SUBTEXT.Colors[k] then error("[sBMRP.Quest]: Invalid color -> text order! {" .. v .. "}") end
		text:InsertColorChange(SUBTEXT.Colors[k][1], SUBTEXT.Colors[k][2], SUBTEXT.Colors[k][3], SUBTEXT.Colors[k][4] or 255)
		text:AppendText(v)
		text:SetWrap(true)
	end

	local header = vgui.Create("DFrame", sNotify)
	header:SetPos(0,0)
	header:SetTitle("")
	header:SetDraggable(false)
	header:ShowCloseButton(false)
	header:SetSize(359, 25)
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
	headertext:SetText(TITLE)
	headertext:SetWrap(false)
	headertext:SizeToContents()

end

EventNotify("TOP_MIDDLE", "This is a test of the Event System Notifer", {
	Colors = {{255,255,255}},
	Text = {"HEllo"}
})