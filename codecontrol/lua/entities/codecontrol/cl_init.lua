include("shared.lua")


function ENT:Draw()

    self:DrawModel()



end
net.Receive("OpenPropMenu", function()
    local Frame = vgui.Create( "DFrame" )
Frame:SetPos( 100, 100 )
Frame:SetSize( 300, 370 )
Frame:SetTitle( "Code Control Console" )
Frame:SetVisible( true )
Frame:Center()
Frame:SetDraggable( false )
Frame:ShowCloseButton( true )
Frame:MakePopup()

Frame.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(50,50,50))
end

local CodeGreenB = vgui.Create("DButton", Frame)
CodeGreenB:SetText("Code Green")
CodeGreenB:SetTextColor( Color(0,255,0,255))
CodeGreenB:SetPos( 90, 50 )
CodeGreenB:SetSize( 110, 40 )
CodeGreenB.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
CodeGreenB.DoClick = function()
    net.Start("ChangeCodeStatus")
        net.WriteString("g")
    net.SendToServer()
    Frame:Close()
end

local CodeYellowB = vgui.Create("DButton", Frame)
CodeYellowB:SetText("Code Yellow")
CodeYellowB:SetTextColor( Color(255,255,0,255))
CodeYellowB:SetPos( 90, 110 )
CodeYellowB:SetSize( 110, 40 )
CodeYellowB.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
CodeYellowB.DoClick = function()
    net.Start("ChangeCodeStatus")
        net.WriteString("y")
    net.SendToServer()
    Frame:Close()
end

local CodeRedB = vgui.Create("DButton", Frame)
CodeRedB:SetText("Code Red")
CodeRedB:SetTextColor( Color(255,0,0,255))
CodeRedB:SetPos( 90, 170 )
CodeRedB:SetSize( 110, 40 )
CodeRedB.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
CodeRedB.DoClick = function()
    net.Start("ChangeCodeStatus")
        net.WriteString("r")
    net.SendToServer()
    Frame:Close()
end

local CodeWB = vgui.Create("DButton", Frame)
CodeWB:SetText("Code White")
CodeWB:SetTextColor( Color(255,255,255,255))
CodeWB:SetPos( 90, 230 )
CodeWB:SetSize( 110, 40 )
CodeWB.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
CodeWB.DoClick = function()
    net.Start("ChangeCodeStatus")
        net.WriteString("w")
    net.SendToServer()
    Frame:Close()
end

local CodeBB = vgui.Create("DButton", Frame)
CodeBB:SetText("Code Black")
CodeBB:SetTextColor( Color(0,0,0,255))
CodeBB:SetPos( 90, 290 )
CodeBB:SetSize( 110, 40 )
CodeBB.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
CodeBB.DoClick = function()
    Frame:Close()
    Framsure = vgui.Create( "DFrame" )
    Framsure:SetPos( 100, 100 )
    Framsure:SetSize( 200, 100 )
    Framsure:SetTitle( "Are you sure?" )
    Framsure:SetVisible( true )
    Framsure:Center()
    Framsure:SetDraggable( false )
    Framsure:ShowCloseButton( true )
    Framsure:MakePopup()
    Framsure.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(50,50,50))
    end
    local Yes = vgui.Create("DButton", Framsure)
Yes:SetText("No")
Yes:SetTextColor( Color(255,255,255,255))
Yes:SetPos( 975, 555 )
Yes:SetSize( 70, 25 )
Yes:MakePopup()
Yes.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
Yes.DoClick = function()
    Framsure:Close()
end

    local No = vgui.Create("DButton", Framsure)
No:SetText("Yes")
No:SetTextColor( Color(255,255,255,255))
No:SetPos( 875, 555 )
No:SetSize( 70, 25 )
No:MakePopup()
No.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(80,80,80))
end
No.DoClick = function()
    net.Start("ChangeCodeStatus")
        net.WriteString("b")
    net.SendToServer()
    Framsure:Close()
end

end

end)


net.Receive("ClientCodeUpdate",function()
    if LocalPlayer().Team() == 31 then
        c = net.ReadString()
        --print("Client Received!", c)
        --For whoever reads this code, I am dearly sorry for this longass code.
        if c == "g" then CodeMaterial = Material( "materials/codecontrol/CodeGreenV3.png" , "codegreen") surface.PlaySound("CodeGreenWatch.wav") chat.AddText( Color( 100, 0,0 ),"|Site Systems|",Color(0,100,0), " Code Green ",Color(255,255,255), "has been put into effect!") end
        if c == "y" then CodeMaterial = Material( "materials/codecontrol/CodeYellowV3.png" , "codeyellow") surface.PlaySound("CodeYelloWatch.wav") chat.AddText( Color( 100, 0,0 ),"|Site Systems|",Color(200,200,0), " Code Yellow ",Color(255,255,255), "has been put into effect!") end
        if c == "r" then CodeMaterial = Material( "materials/codecontrol/CodeRedV3.png" , "codered") surface.PlaySound("CodeRedWatchful.wav") chat.AddText( Color( 100, 0,0 ),"|Site Systems|",Color(150,0,0), " Code Red ",Color(255,255,255), "has been put into effect!") end
        if c == "b" then CodeMaterial = Material( "materials/codecontrol/CodeBlackV2.png" , "codeblack") surface.PlaySound("CodeBlackWatch.wav") chat.AddText( Color( 100, 0,0 ),"|Site Systems|",Color(0,0,0), " Code Black ",Color(255,255,255), "has been put into effect!") end
        if c == "w" then CodeMaterial = Material( "materials/codecontrol/CodeWhiteV2.png" , "codewhite") surface.PlaySound("CodeWhiteWatchful.wav") chat.AddText( Color( 100, 0,0 ),"|Site Systems|",Color(200,200,200), " Code White ",Color(255,255,255), "has been put into effect!") end
    end
end )

CodeMaterial = Material( "materials/codecontrol/CodeGreen.png" , "codegreen")





hook.Add("HUDPaint", "ClientCodePaint", function()
    surface.SetDrawColor( 255, 255, 255, 255 ) -- Set the drawing color
    surface.SetMaterial( CodeMaterial ) -- Use our cached material
    surface.DrawTexturedRect( 25, 10, 200, 34 ) -- Actually draw the rectangle
end )


