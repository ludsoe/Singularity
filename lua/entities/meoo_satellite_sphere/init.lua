AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

// Initialize

function ENT:Initialize()
	self:SetModel( self.cModel )
	self:SetName( self.cName )
	
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:PhysicsInitSphere(1)
	self:SetCollisionBounds(Vector(-1,-1,-1),Vector(1,1,1))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:DrawShadow(false)
	self:SetNotSolid( true )
	
	self:SetNWFloat("Scale", self.Scale)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:SetupAtmosphere(Scale)
	local rad = 500*Scale
	self:PhysicsInitSphere(rad)
	self:SetCollisionBounds(Vector(-rad,-rad,-rad),Vector(rad,rad,rad))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:SetMoveType( MOVETYPE_NONE )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
end

function ENT:StartTouch(ent)

end

function ENT:EndTouch(ent)

end