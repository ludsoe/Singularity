AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("sing_spawn")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	return ent

end
 
function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate1x1.mdl")	
	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetMoveType( MOVETYPE_NONE )
	--self:SetSolid( SOLID_NONE )
	self:DrawShadow(false)
	
	--self:SetNotSolid( true )
end

--[[
function ENT:CanTool()
	return false
end
 ]]
 
function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
