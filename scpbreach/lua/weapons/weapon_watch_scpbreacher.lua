-- USER CONFIGURATION --

BreachTime = 1 -- In seconds
AnnouncementEnabled = false -- true/false Custom sound file that plays when a certain SCP breaches. Ensure you have the sounds in a content pack so your player can hear them!
BreachPos = {

 {1, Vector(112, 783, -12288), "scp682.wav"}, --I was going to put how to do this here, but just contact Watchful#5406 on discord for help if you dont understand.

}

-- END USER CONFIGURATION! DO NOT TOUCH ANYTHING PAST HERE! --

AddCSLuaFile()

SWEP.PrintName = "SCP Breach SWEP"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "pistol"
SWEP.Base = "weapon_base"
SWEP.Category = "Watchfuls Sweps"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

concommand.Add("pos", function(ply)
    if CLIENT then return end
    if ply:IsSuperAdmin() then
    local playerpos = ply:GetPos()
    print(playerpos)
    end
end)

function SWEP:Initialize()
    self.m_bInitialized = true
    self:SetHoldType( "pistol" )


end

function SWEP:Think()
    if (not self.m_bInitialized) then
        self:Initialize()
    end
    self:SetHoldType( "pistol" )
end

if SERVER then
    util.AddNetworkString("scpbreachsweptimerstart")
    util.AddNetworkString("scpbreacherused")
    util.AddNetworkString("scpbreacherfailed")
    util.AddNetworkString("scpbreacherannounce")
end

net.Receive("scpbreachsweptimerstart", function(_,ply)
    --print("woe")
    if CLIENT then return end
    local plys = tostring(ply)
    --print(timer.TimeLeft(plys))
    if timer.Exists(plys) == false then
        timer.Create(plys, BreachTime, 1, function()

        end)
    end
end)

net.Receive("scpbreacherused", function(_,ply)
    if CLIENT then return end
    local plys = tostring(ply)
    local timertime = timer.TimeLeft(plys)
    if timertime == nil then timertime = 0 end
    if timertime > 1 then
        local amount = math.Round(timer.TimeLeft(plys),0)
        net.Start("scpbreacherfailed")
            net.WriteInt(amount,32)
        net.Send(ply)
    elseif timertime < 1 then
        timer.Create(plys, BreachTime, 1, function()

        end)
        for k,v in pairs(BreachPos) do
            --PrintTable(v)
            --print(ply:Team())
            if v[1] == ply:Team() then
                --print("scpbreached! woohoo!")
                --PrintTable(v)
                ply:SetPos(v[2])
                if AnnouncementEnabled == true then
                    --print("announced")
                    net.Start("scpbreacherannounce")
                        net.WriteString(v[3])
                    net.Broadcast()
                end
                return
            end
        end
    end
end)

if CLIENT then
clientclickedalready = false
end

function SWEP:SecondaryAttack()
    if SERVER and game.SinglePlayer() then self:CallOnClient( "SecondaryAttack" ) end
    if SERVER then return end
    --print("secattack")
    if not clientclickedalready then
    net.Start("scpbreachsweptimerstart")
    net.SendToServer()
    end
    clientclickedalready = true
    local panel = vgui.Create("DFrame")
    panel:SetPos(750,400)
    panel:SetSize(400,300)
    panel:SetTitle( "SCP Breacher" )
    panel:SetVisible( true )
    panel:SetDraggable( false )
    panel:MakePopup()
    panel.Paint = function(_,x,y)
        draw.RoundedBox(2,0,0,x,y,Color(88,138,231))
    end
    local button = vgui.Create("DButton",panel)
    button:Center()
    button:SetPos(100,50)
    button:SetSize(200,50)
    button:SetText("BREACH")
    button:SetTextColor(Color(255,255,255))
    button.Paint = function(_,x,y)
        draw.RoundedBox(4,0,0,x,y,Color(102,4,4))
    end
    function button:DoClick()
        net.Start("scpbreacherused")
        net.SendToServer()
    end
end

net.Receive("scpbreacherfailed", function()
    if SERVER then return end
    local amount = net.ReadInt(32)
    notification.AddLegacy( "You must wait " .. tostring(amount) .. " more seconds!", 1, 4 )
end)

net.Receive("scpbreacherannounce", function()
    if SERVER then return end
    --print("announcedcl")
    local snd = net.ReadString()
    surface.PlaySound(snd)
end)