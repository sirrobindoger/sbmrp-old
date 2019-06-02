
if SERVER then
util.AddNetworkString("ArrestReason")
util.AddNetworkString("ArrestReasonReturn")
hook.Add("playerArrested", "ReasonForArrest", function(ply, _, pol)
net.Start("ArrestReason")
net.Send(pol)
ply:ChatPrint("[sBMRP]: Please wait while the person that arrested you types their message before calling an admin.")


net.Receive("ArrestReasonReturn", function()
    shit = net.ReadString()
    print("[ARREST]: " .. ply:GetName() .. " was arrested by " .. pol:GetName() .. " for reason: " .. shit )
    for k, all in pairs( player.GetAll() ) do
	all:ChatPrint("[ARREST]: " .. ply:GetName() .. " was arrested by " .. pol:GetName() .. " for reason: " .. shit )
end
end)
end)

end



if CLIENT then


net.Receive("ArrestReason", function()
local frame = vgui.Create( "DFrame" )
frame:SetTitle("Specify reason for arrest: (and hit enter)")
frame:SetSize( 300, 120 )
frame:Center()
frame:MakePopup()
frame:ShowCloseButton(false)
frame:SetBackgroundBlur(true)


local TextEntry = vgui.Create( "DTextEntry", frame ) -- create the form as a child of frame
TextEntry:SetPos( 50, 50 )
TextEntry:SetSize( 200, 25 )
TextEntry:SetText( "Reason" )
TextEntry.OnEnter = function(ply)
    net.Start("ArrestReasonReturn")
    local dstring = TextEntry:GetValue()
    net.WriteString(dstring)
        frame:Close()
        LocalPlayer():ChatPrint("Your reason was recorded.")
    net.SendToServer()
end
end)
end
