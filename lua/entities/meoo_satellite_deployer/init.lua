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

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
 		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
	end
end

// Use

function ENT:Use()
	self.Active = true
end

// Think

function ENT:Think()
	if (self.Active) then
		self.Time = self.Time - 0.1
		if (self.Time > 0) then
			self:SetNWFloat("time", self.Time)
		else
			local ent = ents.Create( "meoo_satellite" )
				ent:SetPos(self:GetPos() )
				ent:SetAngles( Angle( 0, 0, 0 ) )
				ent:SetColor(self:GetColor())
				ent:SetNWFloat("Scale", self.Scale)
				ent:Spawn()
				ent:Activate()
				ent:RegisterPlanet(self.Scale)
				ent:SetSubSpace(SubSpaces.MainSpace)
			self:Remove()
		end
	end
end

// SpawnFunction

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "meoo_satellite_deployer" )
		ent:SetPos( SpawnPos )
		ent:SetAngles( Angle( 0, 0, 0 ) )
		ent:Spawn()
		ent:Activate()
	return ent
end