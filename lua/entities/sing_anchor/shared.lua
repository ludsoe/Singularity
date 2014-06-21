ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "SubSpace Anchor"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.IsCore = true
ENT.IsDead = false

function ENT:SetupDataTables()

	self:NetworkVar( "Angle", 0, "SubAng" )
	self:NetworkVar( "Vector", 1, "SubPos" )
	self:NetworkVar( "String", 2, "SubAnchor" )

end