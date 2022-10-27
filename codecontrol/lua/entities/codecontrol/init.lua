AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

    self:SetModel("models/props_lab/reciever_cart.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType( SIMPLE_USE )

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then

        phys:Wake()

    end


end
util.AddNetworkString("OpenPropMenu")
function ENT:Use(ply)
    if ply:Team() == 31 then
    net.Start("OpenPropMenu")
    net.Send(ply)
    end
end

