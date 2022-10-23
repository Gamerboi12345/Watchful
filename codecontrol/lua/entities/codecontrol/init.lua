AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cc_menu.lua")

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
--FIXME:Check if player is in a sgt+ role.
    net.Start("OpenPropMenu")
    net.Send(ply)
end

