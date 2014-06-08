AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
 
function ENT:Initialize()	
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:DrawShadow(false)
	
	self:SetNotSolid( true )
end

function ENT:CanTool()
	return false
end
 
function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

