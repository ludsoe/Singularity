AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

// Initialize

function ENT:Initialize()
	self:SetModel( self.cModel )
	self:SetName( self.cName )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.UnTouchable=true
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
 		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end

end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
end