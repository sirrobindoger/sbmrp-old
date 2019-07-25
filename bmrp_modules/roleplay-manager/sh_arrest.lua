
if SERVER then
    util.AddNetworkString("ArrestReason")
    util.AddNetworkString("ArrestReasonReturn")
    hook.Add("playerArrested", "ReasonForArrest", function(ply, _, pol)
        net.Start("ArrestReason")
            net.WriteEntity(ply)
        net.Send(pol)
        sBMRP.ChatNotify({ply}, "Info", "Please wait while the person that arrested you types their message before calling an admin.")

    end)

    net.Receive("ArrestReasonReturn", function()
        local reason = net.ReadString()
        local ply = net.ReadEntity() 
        policename = IsValid(pol) and pol:GetName() or "Console"
        print("[ARREST]: " .. ply:GetName() .. " was arrested by " .. policename .. " for reason: " .. reason )
        sBMRP.ChatNotify(player.GetAll(), "VOX", ply:GetName() .. " was arrested by " .. policename .. " for: " .. reason )
    end)
end



if CLIENT then


    net.Receive("ArrestReason", function()
        Arrestedply = net.ReadEntity()
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
            net.WriteEntity(Arrestedply)
                frame:Close()
                LocalPlayer():ChatPrint("Your reason was recorded.")
            net.SendToServer()
        end
    end)
end
