AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Spawnable = true
function ENT:Initialize()
    self:SetModel("models/bandages.mdl")
    self:SetSpawnEffect(false)
    -- Sets what color to use
    self:SetColor( Color( 200, 255, 200 ) )
    -- Physics stuff
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMaterial("materials\npc_gargitron.png")
    -- Init physics only on server, so it doesn't mess up physgun beam
    if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end
    -- Make prop to fall on spawn
    self:PhysWake()
    
end

function ENT:Use()
    
end