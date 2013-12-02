AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

// Initialize

function ENT:Initialize()
	self:SetModel( self.cModel )
	self:SetName( self.cName )
end

function ENT:RegisterPlanet(Scale)
	self.Scale = Scale
	
	print(Scale)
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	print("V")
	
	local phys = self:GetPhysicsObject()
	local mesh = phys:GetMesh()
	
	for k,v in pairs(mesh) do
		v.pos = v.pos*Scale
	end
	
	self:PhysicsFromMesh(mesh)
	self:EnableCustomCollisions()
	
	if (phys:IsValid()) then
		phys:Wake()
 		phys:EnableGravity(false)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end
	
	local ent = ents.Create( "meoo_satellite_sphere" )
		ent:SetPos( self:GetPos() )
		ent:SetAngles( Angle( 0, 0, 0 ) )
		ent:SetNWFloat("Scale", Scale)
		ent:Spawn()
		ent:Activate()
  		ent:SetParent( self )
		ent:SetColor(self:GetColor())
		ent:SetSubSpace(SubSpaces.MainSpace)
		ent:SetupAtmosphere(Scale)
end
