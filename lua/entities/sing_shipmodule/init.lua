AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("sing_shipmodule")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	return ent

end
 
function ENT:Initialize()	
	self:SetModel("models/hunter/plates/plate1x1.mdl")
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
end

