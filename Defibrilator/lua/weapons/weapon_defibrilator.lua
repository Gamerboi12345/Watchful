AddCSLuaFile()

if SERVER then
	resource.AddWorkshop( "2868046966" )
else -- CLIENT
	SWEP.DrawWeaponInfoBox	= false
	SWEP.BounceWeaponIcon	= false 

	--SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_defibrilator") 

	language.Add("weapon_defibrilator", "Defibrilator")
end

SWEP.PrintName = "Defibrilator"
SWEP.Category = "Other"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/weapons/defib/v_defibrillator.mdl"
SWEP.WorldModel = "models/weapons/defib/w_eq_defibrillator.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale = 1
SWEP.SwayScale = 1
SWEP.UseHands = true

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Weight = 0
SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.HoldType = "duel"
SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.CSMuzzleFlashes = 1
SWEP.Base = "weapon_base"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.2

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self:SetHoldType( self.HoldType )
	self.Incm = 75
	if !IsValid(self.Owner) then
		self.WorldModel = "models/weapons/defib/w_eq_defibrillator.mdl"
	else
		self.WorldModel = "models/weapons/defib/w_eq_defibrillator_paddles.mdl"
	end
	
	self.Idle = 0
	self.IdleTimer = CurTime() + 1
end

function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK) then
		if self.Incm < 85 then
			self.Incm = self.Incm + 3
			self.ViewModelFOV = self.Incm
		end
	else
		if self.Incm > 75 then
			self.Incm = self.Incm - 3
			self.ViewModelFOV = self.Incm
		end
	end
	
	if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		end
		self.Idle = 1
	end
end

local TargClass = {	
	["npc_hunter"] = 1,
	["npc_turret_ceiling"] = 1,
	["npc_combine_camera"] = 1,
	["npc_manhack"] = 2,
	["npc_rollermine"] = 2,
	["npc_turret_floor"] = 2,
	["npc_strider"] = 2,
	["npc_helicopter"] = 2,
	["npc_combinegunship"] = 2,
	["npc_cscanner"] = 3,
	["npc_clawscanner"] = 3,
	["gmod_sent_vehicle_fphysics_base"] = 4,
	["wac_hc"] = 5,
	["wac_pl"] = 6,
	["lfs"] = 7,
	["lunasflightschool"] = 7,
	["combine_mine"] = 8,
	["prop_vehicle_jeep"] = 9,
	["prop_vehicle_airboat"] = 9,
 }

function SWEP:PrimaryAttack()	
	local tr = util.TraceLine( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
	filter = self.Owner,
	mask = MASK_SHOT_HULL,
	} )
	
	if !IsValid( tr.Entity ) then
		tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
		filter = self.Owner,
		mins = Vector( -20, -20, 0 ),
		maxs = Vector( 20, 20, 0 ),
		mask = MASK_SHOT_HULL,
		} )
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 0.2 )
	
	if SERVER then
		if IsValid(tr.Entity) then
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 4 )
			
			local force = self.Owner:GetAimVector() * 5000
			local v = tr.Entity
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(self.Owner:GetShootPos())
			dmginfo:SetDamageType(DMG_SHOCK)
			dmginfo:SetDamage(math.random(25,100) + v:Health()/math.Rand(10,1))
			
			local spark = ents.Create( "env_spark" )
			spark:SetPos(tr.HitPos)
			spark:SetKeyValue( "spawnflags", "128" + "64" )
			spark:SetKeyValue( "traillength", "1" )
			spark:SetKeyValue( "magnitude", "2" )
			--spark:SetParent(self)
			spark:Spawn()
			spark:Fire( "SparkOnce", "", 0.05 )
			spark:Fire( "kill", "", 0.1 )
			
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", "4")
			FireLight1:SetKeyValue("distance", "160")
			FireLight1:SetPos(tr.HitPos + tr.HitNormal*5)
			FireLight1:Fire("Color", "60 150 255")
			--FireLight1:SetParent(self)
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn","",0)
			FireLight1:Fire("Kill","",0.07)
			self:DeleteOnRemove(FireLight1)
			
			self.Owner:ViewPunch(Angle(-10,0,0))
			self.Owner:EmitSound("weapons/empgun/arc"..math.random(1,2)..".wav",75,100,0.8)
			self.Owner:EmitSound("defibl/warmup.wav",75,100)
			sound.Play("ambient/energy/zap"..math.random(1,9)..".wav",v:GetPos()+Vector(0,0,20),75)
			self:SetClip1(10)
			
			timer.Create( "DefiblAmmoCount"..self:EntIndex(), 0.4, 8, function()
				if !IsValid(self) then return end
				self:SetClip1(self:Clip1()+10)
			end)
			
			timer.Simple(3.8, function()
				if !IsValid(self) then return end
				self:EmitSound("defibl/charged.wav",75,100)
				self:SetClip1(100)
			end)
			
			for class, action in pairs(TargClass) do
				if v:GetClass():find(tostring(class)) then
					v:EmitSound("weapons/empgun/emp.mp3",75,100)
					v:EmitSound("defibl/defibrillator_use.wav", 75, 90)
					
					if action == 1 then -- anything that would die to damage
						local dmginfo2 = DamageInfo()
						dmginfo2:SetInflictor(self)
						dmginfo2:SetAttacker(self.Owner)
						dmginfo2:SetDamage(v:Health()/5 + 50)
						dmginfo2:SetDamageType(DMG_SHOCK)
						dmginfo2:SetDamagePosition(v:GetPos())
						dmginfo2:SetDamageForce(self.Owner:GetAimVector()*5000)
						v:TakeDamageInfo(dmginfo2)
					elseif action == 2 then -- manhacks, turret & rollers
						v:Fire("interactivepowerdown","")
						v:Fire("selfdestruct","")
						if v:GetClass() == "npc_roller" then
							v:SetColor(Color(255,100,0,255))
						elseif !v:GetClass() == "npc_turret_floor" then
							v:SetHealth(0)
							v:TakeDamage(1000,self.Owner,self)
						end
					elseif action == 3 then -- city scanners
						v:Ignite(5)
						v:Fire("sethealth","0",5)
					elseif action == 4 then -- simfphys
						v:StopEngine()
						v:SetActive( false )
						v:SetIsBraking( false )
						v.LightsActivated = false
						v.LampsActivated = false
						v.VehicleLocked = true
						v:SetLightsEnabled(false)
						v:SetLampsEnabled(false)
					
						v:EmitSound("ambient/energy/powerdown2.wav", 80, 100)
						timer.Simple(2.5, function() if IsValid(v) then
							v:StartEngine()
							v:SetActive( true )
							v.VehicleLocked = false
							v:EmitSound("ambient/machines/sputter1.wav", 75, 100)
						end end)
					elseif action == 5 then -- wac heli
						v.active=false
						if v.UsePhysRotor then
							v.topRotor.Phys:AddAngleVelocity((v.topRotor.Phys:GetAngleVelocity()*-10)*0.02)
						end
						self:DoHeliWeeWoo(v)
					elseif action == 6 then -- wac plane
						v.active=false
						v.rotor.phys:AddAngleVelocity((v.rotor.phys:GetAngleVelocity()*-10)*0.02)
						self:DoHeliWeeWoo(v)
					elseif action == 7 then -- LFS
						if !v:GetClass():find("maintenance") and !v:GetClass():find("spammer") then
							v:StopEngine()
							self:DoHeliWeeWoo(v)
						end
					elseif action == 8 then -- combine mine
						local exp = ents.Create( "env_explosion" )
						exp:SetPos(v:GetPos())
						exp:Spawn()
						exp:SetKeyValue( "iMagnitude", "50" )
						exp:Fire("Explode", 0, 0)
						exp:Fire("Remove", 0, 0.2)
						util.BlastDamage(v,v,v:GetPos() + Vector(0,0,64),200,300)
						v:Remove()
					elseif action == 9 then -- base vehicle
						v:Fire("turnoff",0,0)
						v:Fire("handbrakeoff",0,0)
						v:EmitSound("ambient/energy/powerdown2.wav", 80, 100)
						timer.Simple(2.5, function() if IsValid(v) then
							v:Fire("turnon",0,0)
							v:EmitSound("ambient/machines/sputter1.wav", 75, 100)
						end end)
					end
				end
			end
			
			if v:IsPlayer() or v:IsNPC() or v.Type == "nextbot" or v:GetClass() == "prop_ragdoll" then
				self.Owner:EmitSound( "defibl/defibrillator_use.wav",75,math.random(95,105))
				dmginfo:SetDamageForce(force)
				if v:GetModel():find("bot") or v:GetModel():find("robo")
				or v:GetModel():find("droid") or (v:GetModel():find("fnaf") and !v:GetModel():find("van"))
				or v:GetModel():find("foxy") or v:GetModel():find("bonnie") or v:GetModel():find("chica")
				or v:GetModel():find("mangle") or v:GetModel():find("springtrap") or v:GetModel():find("spring_trap")
				or (v:GetModel():find("freddy") and !v:GetModel():find("krueger"))
				or v:GetModel():find("blackh3art")
				or v:GetModel():find("animatronic") -- zap anything that has a robot like model
				or v:GetClass():find("robo") or (v:GetClass():find("tank") and !v:GetClass():find("l4d"))
				or v:GetClass():find("mech") or (v:GetClass():find("fnaf") and !v:GetClass():find("van"))
				or v:GetClass():find("foxy") or v:GetClass():find("bonnie") or v:GetClass():find("chica")
				or v:GetClass():find("mangle") or v:GetClass():find("springtrap") or v:GetClass():find("spring_trap")
				or (v:GetClass():find("freddy") and !v:GetClass():find("krueger"))
				or v:GetClass():find("blackh3art") or v:GetClass():find("abrams") or v:GetClass():find("_lav")
				or v:GetClass():find("turret") or v:GetClass():find("sentry") or v:GetClass():find("t72")
				or v:GetClass():find("merkava") or v:GetClass():find("apache") or v:GetClass():find("osprey")
				or v:GetClass():find("bradley") or v:GetClass():find("hlr1_rgrunt")
				or v:GetClass():find("animatronic") then
					dmginfo:SetDamage(math.random(25,100)*2000)
				end
				v:TakeDamageInfo(dmginfo)
				v:SetVelocity(Vector(force.x,force.y,10))
				
				if v.Type == "nextbot" then
					v.loco:SetVelocity(force)
					v.Target = NULL
					v.Targ = NULL
					v.Enemy = NULL
					v.CurrentTarget = NULL
					timer.Simple(0.5, function() 
						if !IsValid(v) then return end
						v:NextThink(CurTime() + 4)
						timer.Create( "DefiblZap"..v:EntIndex(), 0.25, 16, function()
							local effect2 = EffectData()
							if !IsValid(v) then return end
							effect2:SetOrigin(v:GetPos())
							effect2:SetStart(v:GetPos())
							effect2:SetMagnitude(5)
							effect2:SetEntity(v)
							util.Effect("teslaHitBoxes",effect2)
							v:EmitSound("Weapon_StunStick.Activate")
						end)
					end)
				elseif v:IsPlayer() then
					v:ScreenFade(SCREENFADE.IN, Color(255,255,255), 0.7, 0.03);
					v:ViewPunch(Angle(20,0,20))
				elseif v:IsNPC() then
					v:SetSchedule(SCHED_NPC_FREEZE)
					v:NextThink(CurTime() + 0.5)
					timer.Create( "DefiblAIScrewer"..v:EntIndex(), 0.01, 500, function()
						if !IsValid(v) then return end
						local decoy = Entity(math.random(1,999))
						if IsValid(decoy) then -- generate a stream of terrible ideas
							v:SetEnemy(decoy, true)
							v:SetTarget(decoy)
						else
							if math.random() < 0.5 then
								v:SetEnemy(v, true)
							else
								v:SetEnemy(NULL, true)
							end
							v:SetTarget(v)
						end
					end)
					timer.Simple(3, function() 
						if !IsValid(v) then return end
						v:SetCondition( 68 ) -- wake from freeze
						v:SetSchedule(SCHED_MOVE_AWAY)
					end)
					timer.Create( "DefiblZap"..v:EntIndex(), 0.25, 16, function()
						local effect2 = EffectData()
						if !IsValid(v) then return end
						effect2:SetOrigin(v:GetPos())
						effect2:SetStart(v:GetPos())
						effect2:SetMagnitude(5)
						effect2:SetEntity(v)
						util.Effect("teslaHitBoxes",effect2)
						v:EmitSound("Weapon_StunStick.Activate")
					end)
				elseif v:GetClass() == "prop_ragdoll" then
					v:Fire("startragdollboogie","",0)
					v:Fire("startragdollboogie","",5)
					
					timer.Create( "DefiblZap"..v:EntIndex(), 0.25, 16, function()
						local effect2 = EffectData()
						if !IsValid(v) then return end
						effect2:SetOrigin(v:GetPos())
						effect2:SetStart(v:GetPos())
						effect2:SetMagnitude(5)
						effect2:SetEntity(v)
						util.Effect("teslaHitBoxes",effect2)
						v:EmitSound("Weapon_StunStick.Activate")
						
						if math.random() < 0.05 and v.DefiblReviveEnt ~= nil then
							v:EmitSound("ambient/levels/citadel/weapon_disintegrate"..math.random(1,4)..".wav")
							local targname = "dissolveme"..v:EntIndex()
							v:SetKeyValue("targetname",targname)
							local numbones = v:GetPhysicsObjectCount()
							for bone = 0, numbones - 1 do 
								local PhysObj = v:GetPhysicsObjectNum(bone)
								if PhysObj:IsValid()then
									PhysObj:SetVelocity(PhysObj:GetVelocity()*0.04)
									PhysObj:EnableGravity(false)
								end
							end
							local dissolver = ents.Create("env_entity_dissolver")
							dissolver:SetKeyValue("magnitude",0)
							dissolver:SetPos(v:GetPos())
							dissolver:SetKeyValue("target",targname)
							dissolver:Spawn()
							dissolver:Fire("Dissolve",targname,0)
							dissolver:Fire("kill","",0.1)
							dissolver:SetKeyValue("dissolvetype",3)
					
							local newhp = v.DefiblReviveEntHP*1.5
							if isnumber(v.DefiblReviveEnt) then
								local ply = Entity(v.DefiblReviveEnt)
								ply:Spawn()
								ply:SetPos(v:GetPos() + Vector(0,0,8))
								ply:SetHealth(newhp)
								ply:SetMaxHealth(newhp)
							else
								local NPC = ents.Create(v.DefiblReviveEnt)
								NPC:SetPos(v:GetPos() + Vector(0,0,8))
					
								if NPC.IsVJBaseSNPC then
									if VJ_PICK(list.Get("NPC")[NPC:GetClass()].Weapons) ~= false then
										NPC:Give(VJ_PICK(list.Get("NPC")[NPC:GetClass()].Weapons))
									end
								end
								NPC:Spawn()
								NPC:Activate()
								
								if !v.DefiblReviveEnt:find("drg") then
									NPC:SetHealth(newhp)
									NPC:SetMaxHealth(newhp)
									if v.DefiblReviveEnt == "npc_combine_s" or v.DefiblReviveEnt == "npc_citizen" then
										NPC:SetModel(v.DefiblReviveEntMDL)
									end
									if v.DefiblReviveEntName ~= "" and v.DefiblReviveEntName ~= nil then
										NPC:SetName(v.DefiblReviveEntName)
									end
									if v.DefiblReviveEntWep ~= nil and v.DefiblReviveEntWep ~= "" and !IsValid(NPC:GetActiveWeapon()) then
										NPC:Give(tostring(v.DefiblReviveEntWep))
									end
									
									NPC:SetSchedule(SCHED_NPC_FREEZE)
									NPC:NextThink(CurTime() + 0.5)
									timer.Simple(1, function() 
										if !IsValid(NPC) then return end
										NPC:SetCondition( 68 ) -- wake from freeze
										NPC:SetSchedule(SCHED_MOVE_AWAY)
									end)
								end
							end
						end
					end)
				end
			end
		else
			for k,v in pairs (ents.FindInSphere(self.Owner:GetShootPos(), 70)) do
				if v:IsPlayer() and !v:Alive() then
					self:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 4 )
			
					local oldpos = v:GetPos()
					local spark = ents.Create( "env_spark" )
					spark:SetPos(oldpos)
					spark:SetKeyValue( "spawnflags", "128" + "64" )
					spark:SetKeyValue( "traillength", "1" )
					spark:SetKeyValue( "magnitude", "2" )
					--spark:SetParent(self)
					spark:Spawn()
					spark:Fire( "SparkOnce", "", 0.05 )
					spark:Fire( "kill", "", 0.1 )
					
					local FireLight1 = ents.Create("light_dynamic")
					FireLight1:SetKeyValue("brightness", "4")
					FireLight1:SetKeyValue("distance", "160")
					FireLight1:SetPos(oldpos)
					FireLight1:Fire("Color", "60 150 255")
					--FireLight1:SetParent(self)
					FireLight1:Spawn()
					FireLight1:Activate()
					FireLight1:Fire("TurnOn","",0)
					FireLight1:Fire("Kill","",0.07)
					self:DeleteOnRemove(FireLight1)
					
					self.Owner:ViewPunch(Angle(-10,0,0))
					self.Owner:EmitSound("weapons/empgun/arc"..math.random(1,2)..".wav",75,100,0.8)
					self.Owner:EmitSound("defibl/warmup.wav",75,100)
					sound.Play("ambient/energy/zap"..math.random(1,9)..".wav",oldpos,75)
					self:SetClip1(10)
					
					timer.Create( "DefiblAmmoCount"..self:EntIndex(), 0.4, 8, function()
						if !IsValid(self) then return end
						self:SetClip1(self:Clip1()+10)
					end)
					
					timer.Simple(3.8, function()
						if !IsValid(self) then return end
						self:EmitSound("defibl/charged.wav",75,100)
						self:SetClip1(100)
					end)
			
					if math.random() < 0.8 then
						v.BeingRevived = true
						v:Spawn()
						v:SetPos(oldpos)
					else
						self.Owner:PrintMessage( HUD_PRINTCENTER, "Failed to revive, try again" )
						v:PrintMessage( HUD_PRINTCENTER, "You are being revived" )
					end
					
					return
				end
			end
			self.Owner:EmitSound( "HL2Player.UseDeny")
		end
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:DoHeliWeeWoo(v)
	v:EmitSound("ambient/energy/powerdown2.wav", 80, 100)
	v:EmitSound("heli/damage_alarm"..math.random(1,4)..".wav", 75, 100)
end

function SWEP:SecondaryAttack()
	local tr = util.TraceLine( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 55,
	filter = self.Owner,
	mask = MASK_SHOT_HULL,
	} )
	
	if !IsValid( tr.Entity ) then
		tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 55,
		filter = self.Owner,
		mins = Vector( -20, -20, 0 ),
		maxs = Vector( 20, 20, 0 ),
		mask = MASK_SHOT_HULL,
		} )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "melee" ) )
	
	if SERVER then
		local force = self.Owner:GetAimVector() * 1000
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageType(DMG_SLASH) 
		dmginfo:SetDamage(10)
			
		if tr.Hit and (tr.Entity:IsPlayer() || tr.Entity:IsNPC() || tr.Entity.Type == "nextbot" || tr.Entity:GetClass() == "prop_ragdoll") then
			self.Owner:EmitSound( "player/survivor/hit/rifle_swing_hit_infected" .. math.random(7, 12) .. ".wav")
			dmginfo:SetDamageForce(force)
			tr.Entity:TakeDamageInfo(dmginfo)
			tr.Entity:SetVelocity(Vector(force.x,force.y,10))
		elseif tr.Hit then
			self.Owner:EmitSound( "player/survivor/hit/rifle_swing_hit_world.wav")
			if IsValid(tr.Entity) then
				dmginfo:SetDamageForce(force/100)
				tr.Entity:TakeDamageInfo(dmginfo)
			end
		else
			self.Owner:EmitSound( "weapons/bat/bat_swing_miss" .. math.random(1, 2) .. ".wav")
		end
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay + 0.7 )
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:Equip()
	self.ViewModelFOV = 75
	self.WorldModel = "models/weapons/defib/w_eq_defibrillator_paddles.mdl"
	self:SetModel("models/weapons/defib/w_eq_defibrillator_paddles.mdl")
	self.Incm = 75
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "deploy" ) )
	
	self.ViewModelFOV = 75
	self.WorldModel = "models/weapons/defib/w_eq_defibrillator_paddles.mdl"
	self:SetModel("models/weapons/defib/w_eq_defibrillator_paddles.mdl")
	self.Incm = 75
	self:EmitSound("defibl/deploy.wav",60)
	self:SendWeaponAnim(ACT_VM_DEPLOY)
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:Holster()
	self.Idle = 0
	self.IdleTimer = CurTime()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:OnDrop()
	self:Holster()
end


	


hook.Add( "DoPlayerDeath", "Defibl_Revive", function( ply, attacker, dmginfo )
	
	ply.LastDeathTime = CurTime()
	
	--The weapon the player is holding when they die
	if IsValid( ply:GetActiveWeapon() ) then
		ply.ReviveActiveWeapon = ply:GetActiveWeapon():GetClass()
	end
	
	--The weapons the player has when they die
	ply.ReviveWeapons = {}
	for k, v in pairs( ply:GetWeapons() ) do
		table.insert( ply.ReviveWeapons, v:GetClass() )
	end
	
	--The player's position when they die (REMOVED FROM THIS CODE)
	--ply.RevivePos = ply:GetPos()
	plys = tostring(ply)
	timer.Create( plys, 1,0,function() ply.RevivePos = Ply:GetRagdollEntity() end)
	

	
	
	--The player's eye angles when they die
	ply.ReviveAng = ply:EyeAngles()

	
	
	--The player's ammo before they die adjusted to make death a loss
	ply.RevivalPreviousAmmo = {}
	for k, v in pairs( ply:GetWeapons() ) do
		--Get primary and secondary ammo types
		local primary = v:GetPrimaryAmmoType()
		local secondary = v:GetSecondaryAmmoType()
		
		--Get the adjusted ammo amounts based on the ammotypes
		local newPrimary = math.floor( ply:GetAmmoCount( primary ) * 0.5 )
		local newSecondary = math.floor( ply:GetAmmoCount( secondary ) * 0.5 )
		
		--Save the new ammocounts
		ply.RevivalPreviousAmmo[primary] = newPrimary
		ply.RevivalPreviousAmmo[secondary] = newSecondary
	end
end)

hook.Add( "PlayerLoadout", "Defibl_Revive", function( ply )
	if !IsValid( ply ) then return end
	if !ply.BeingRevived then return end
	
	ply.BeingRevived = nil
	
	--Give the player back their weapons
	for k, v in pairs( ply.ReviveWeapons ) do
		ply:Give( v )
	end
	
	--Select the weapon they had out
	ply:SelectWeapon( ply.ReviveActiveWeapon )
	
	--Give the player back their ammo
	for k, v in pairs( ply.RevivalPreviousAmmo ) do
		ply:GiveAmmo( v, k, true )
	end
	
	return true
end)

if SERVER then
	hook.Add( "OnEntityCreated", "Defibl_Revive", function( ent )
		if ent:IsNPC() then
			timer.Simple(0, function() if IsValid(ent) then
				if IsValid(ent:GetActiveWeapon()) then -- because this returns nothing if called when npc is dead
					ent.DefiblReviveEntWep = ent:GetActiveWeapon():GetClass()
				end
			end
			end)
		end
		
		if ent:GetClass() == "prop_ragdoll" then
			timer.Simple(0, function() if IsValid(ent) then
				ent.DefiblReviveEnt = ent.EntityClass -- DrGBase
				ent.DefiblReviveEntHP = 0 -- we can't get the Nextbot entity
			end
			end)
		end
	end)

	hook.Add( "CreateEntityRagdoll", "Defibl_Revive", function( owner,ent )
		if IsValid(ent) and IsValid(owner) and (owner:IsNPC() or (owner.Type == "nextbot" and !owner:GetClass():find("drg")) or (owner:IsPlayer() and !owner:Alive())) then
			local hp = owner:GetMaxHealth()
			local mdl = owner:GetModel()
			local name = owner:GetName()
			local wepclass = owner.DefiblReviveEntWep -- given to us by create hook
			
			if owner:IsPlayer() then
				ent.DefiblReviveEnt = owner:EntIndex()
			else
				local npc = owner:GetClass()
				ent.DefiblReviveEnt = npc -- VJ
				timer.Simple(0, function() if IsValid(ent) then -- for Keep Corpses
					ent.DefiblReviveEnt = npc
					ent.DefiblReviveEntHP = hp
					ent.DefiblReviveEntMDL = mdl
					ent.DefiblReviveEntName = name
					ent.DefiblReviveEntWep = wepclass
				end
				end)
			end
			ent.DefiblReviveEntHP = hp
			ent.DefiblReviveEntMDL = mdl
			ent.DefiblReviveEntName = name
			ent.DefiblReviveEntWep = wepclass
		end
	end )
else -- CLIENT
	local MEEEEEEEM = Material( "entities/weapon_defibrilator.png" )
	
	hook.Add( "PostDrawOpaqueRenderables", "Defibl_RenderDeadSpot", function()
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "weapon_defibrilator" then
			for k,v in pairs (ents.FindInSphere(LocalPlayer():GetPos(), 1024)) do
				if v:IsPlayer() and !v:Alive() then
					local pos = v:GetPos()
					
					local angles = LocalPlayer():EyeAngles()
					local distance = pos:Distance(LocalPlayer():GetPos())
					local distance_m = math.Round(distance / 39.370)
					local xy = distance/10 + 200
			 
					angles:RotateAroundAxis(angles:Forward(), 90)
					angles:RotateAroundAxis(angles:Right(), 90)
					--angles:RotateAroundAxis(angles:Up(), 0)
					
					cam.Start3D2D(pos, angles, 0.1)
						cam.IgnoreZ(true)
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(MEEEEEEEM)
						surface.DrawTexturedRect(-xy/2, (-xy/2)*2, xy, xy)
						--draw.RoundedBox( 30, -xy/2, (-xy/2)*2, xy, xy, Color(25,200,255,255) )

						cam.IgnoreZ(false)
					cam.End3D2D()
				end
			end
		end
	end)
end