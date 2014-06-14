
function Singularity.MT.CreateDevice(ply, trace, Class, Model, Ang)
	--if !ply:CheckLimit(self.CleanupGroup) then return end
	local ent = ents.Create( Class )
	if not ent:IsValid() then return end
		
	-- Pos/Model/Angle
	ent:SetModel( Model )
	ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
	ent:SetAngles( trace.HitNormal:Angle() + (Ang or Angle(90,0,0)) )
	
	ent:Spawn()
	ent:Activate()
	ent:GetPhysicsObject():Wake()
	
	Singularity.GivePlyProp(ply,ent)
	
	ply:AddCleanup("Jupiter Device",ent)

	undo.Create("Entity: "..Class)
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()
	
	return ent
end




