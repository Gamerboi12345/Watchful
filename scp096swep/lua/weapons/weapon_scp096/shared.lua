SWEP.Category               = "Ciarox SCP-096 Swep"
SWEP.PrintName              = "SCP-096 Swep"        
SWEP.Author                 = "Watchful/Ciarox"
SWEP.Instructions           = "Kill people!"
SWEP.ViewModelFOV           = 56
SWEP.droppable              = false
SWEP.Spawnable              = true
SWEP.AdminOnly              = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Delay          = 2
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "None"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "None"
SWEP.Weight                 = 3
SWEP.AutoSwitchTo           = false
SWEP.AutoSwitchFrom         = false
SWEP.Slot                   = 0
SWEP.SlotPos                = 4
SWEP.DrawAmmo               = false
SWEP.DrawCrosshair          = true
SWEP.droppable              = false
SWEP.Primary.Distance       = 100
SWEP.IdleAnim               = true
SWEP.ViewModel              = "models/weapons/v_arms_scp096.mdl"
SWEP.WorldModel             = ""
SWEP.IconLetter             = "w"
SWEP.Primary.Sound          = ("weapons/scp96/attack1.wav")
SWEP.HoldType               = "normal"
SWEP.NextSound 				= CurTime()
SWEP.whitelisted = {
    TEAM_131A,
    TEAM_131B,
    TEAM_343,
    TEAM_999,
    TEAM_006FR,
    TEAM_049,
    TEAM_053,
    TEAM_060FR,
    TEAM_066,
    TEAM_082,
    TEAM_096,
    TEAM_173,
    TEAM_1128,
    TEAM_035,
    TEAM_106,
    TEAM_1048,
    TEAM_IA,
    TEAM_STAFF
}

local Swep = nil

if SERVER then
    util.AddNetworkString( "checkVariable" )
    util.AddNetworkString( "ClientShared" )
end

if (CLIENT) then
    SWEP.WepSelectIcon      = surface.GetTextureID( "vgui/entities/weapon_scp096" )
    killicon.Add( "kill_icon_scp096", "vgui/icons/kill_icon_scp096", Color( 255, 255, 255, 255 ) )
end

function SWEP:Initialize()
    Swep = self
    self:SetNWInt("watching", 0)
    util.PrecacheSound("weapons/scp96/attack1.wav")
    util.PrecacheSound("weapons/scp96/attack2.wav")
    util.PrecacheSound("weapons/scp96/096_3.mp3")
    util.PrecacheSound("weapons/scp96/096_idle1.wav")
    util.PrecacheSound("weapons/scp96/096_idle2.wav")
    util.PrecacheSound("weapons/scp96/096_idle3.wav")
    self:SetWeaponHoldType( self.HoldType )
    self.NextAttackW = CurTime()
    self.NextSound = CurTime()
end
 
function SWEP:SpeedChange(var) -- Resets the speed
    if var == false then
        if self.Owner:IsValid() then
            self.Owner:SetRunSpeed(150)
            self.Owner:SetWalkSpeed(150)
            self.Owner:SetMaxSpeed(150)
        end
    else
        if self.Owner:IsValid() then
            self.Owner:SetRunSpeed(350)
            self.Owner:SetWalkSpeed(350)
            self.Owner:SetMaxSpeed(350)
        end
    end
end
 
function SWEP:PrimaryAttack()
 
    if !self:CanPrimaryAttack() then return end
    if not IsFirstTimePredicted() then return end
    local ent = nil
    if self:GetNWInt("watching") > 0 then
        self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
        
        local trace = self.Owner:GetEyeTrace();
        local ent = trace.Entity
        if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 50 then
            if ent:GetNWBool("haveLooked") then
                self.Owner:SetAnimation( PLAYER_ATTACK1 );
                self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
                    bullet = {}
                    bullet.Num    = 1
                    bullet.Src    = self.Owner:GetShootPos()
                    bullet.Dir    = self.Owner:GetAimVector()
                    bullet.Spread = Vector(0, 0, 0)
                    bullet.Tracer = 0
                    bullet.Force  = 25
                    bullet.Damage = 1000
                self.Owner:FireBullets(bullet)
            else
                self.Owner:SetAnimation( PLAYER_ATTACK1 );
                self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
                self.Weapon:EmitSound( "weapons/scp96/attack"..math.random(1,4)..".wav" )
            end
        else
            self.Owner:SetAnimation( PLAYER_ATTACK1 );
            self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
            self.Weapon:EmitSound( "weapons/scp96/attack"..math.random(1,4)..".wav" )
        end
        if self.Owner:EyePos():Distance(trace.HitPos) <= 50 then
            if ent:IsValid() then
                if ent:isDoor() then
                    ent:Fire("open", "")
                end
            end
        end
        
        self.Weapon:SetNextPrimaryFire( CurTime() + 0.43 )
    end
end




function SWEP:IsLookingAt( ply )
    local yes = ply:GetAimVector():Dot( ( self.Owner:GetPos() - ply:GetPos() + Vector( 70 ) ):GetNormalized() )
    return (yes > 0.39)
end

function SWEP:Think()
    for _,v in pairs(player.GetAll()) do
        
        if !v:GetNWBool("haveLooked") then
            v:SetNWBool( "haveLooked", false )
        end


        if IsValid(v) and v:Alive() and v != self.Owner then
            local tr_eyes = util.TraceLine( {
                start = v:EyePos() + v:EyeAngles():Forward() * 5,
                //start = v:LocalToWorld( v:OBBCenter() ),
                //start = v:GetPos() + (self.Owner:EyeAngles():Forward() * 5000),
                endpos = self.Owner:EyePos(),
                //filter = v
            } )

            local tr_center = util.TraceLine( {
                start = v:LocalToWorld( v:OBBCenter() ),
                endpos = self.Owner:LocalToWorld( self.Owner:OBBCenter() ),
                filter = v
            } )

            if tr_eyes.Entity == self.Owner or tr_center.Entity == self.Owner then
                if self:IsLookingAt( v ) then
                    local f = false
                    for _,t in pairs(self.whitelisted) do
                        if v:Team() == t then f = true end
                    end
                    if v:GetNWBool("haveLooked") == false and f == false and v:IsValid() and v:Alive() then
                        v:SetNWBool("haveLooked", true)
                        if SERVER and self:GetNWInt("watching") == 0 then
                            self.Owner:EmitSound("weapons/scp96/096_3.mp3", 500, 100, 1, CHAN_AUTO)
                        end
                        self:SetNWInt("watching", self:GetNWInt("watching") + 1 )
                        self.Owner:PrintMessage(HUD_PRINTTALK, v:Nick() .. "Hatt dich angeschaut")
                        v:PrintMessage(HUD_PRINTTALK, "")
                    end
                end
            end
        end
    end

    if self.NextSound < CurTime() then
        if self:GetNWInt("watching") == 0 then
            self.NextSound = CurTime() + 30
            if SERVER then
                self:EmitSound("weapons/scp96/096_idle"..math.random(1,3)..".wav", 255, 100, 1, CHAN_AUTO)
            end
        end
    end

    if self:GetNWInt("watching") > 0 then
        self:SpeedChange(true)
        function self:CanPrimaryAttack() return true end
    else
        self:SpeedChange(false)
        function self:CanPrimaryAttack() return false end
    end
end

function DrawHalo()
    if LocalPlayer() == NULL then LP = 0 end
	if not IsValid( LP ) then return end
	if not LP:GetActiveWeapon() then return end
    if LP:GetActiveWeapon():GetClass() == "weapon_scp096" then
        a = {}
        for _,v in pairs(player.GetAll()) do
            if v:GetNWBool("haveLooked") then
                if v:Alive() then
                    table.insert(a, v)
                end
            end
        end
        halo.Add( a, Color(255, 0, 0, 255), 1, 1, 1, true, true )
    end
end

function OnPLayerDeath (ply, inf, att)
    if IsValid(ply) then
        if ply:GetNWBool("haveLooked") then
            ply:SetNWBool("haveLooked", false)
            Swep:SetNWInt("watching", Swep:GetNWInt("watching") - 1 )
        end
    end
end

function SWEP:Reload()
    Swep:SetNWInt("watching", 0 )
    for _,v in pairs(player.GetAll()) do
        v:SetNWBool("haveLooked", false)
    end
end


hook.Add( "PreDrawHalos", "PlayerHalosDraw096", DrawHalo )
hook.Add("PlayerDeath", "CheckOnDeath", OnPLayerDeath)

function SWEP:SecondaryAttack()

end
