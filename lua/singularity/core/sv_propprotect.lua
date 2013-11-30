local Singularity = Singularity --Localise the global table for speed.
Singularity.PropProtect = Singularity.PropProtect or {}
local PropProtect = Singularity.PropProtect --SPEEEEEEED BOOOOOOST!!!!

function PropProtect.PlayerCanTouch(ply, ent)
	if(ent:IsWorld())then return true end
	
	if(not ent:IsValid() or not ply:IsValid() or ent:IsPlayer() or !ply:IsPlayer())then return false end
	
	if(ent.UnTouchable)then
		if(ply:IsAdmin())then return true end
		return false
	end
	
	return true
end

function PropProtect.PlayerCanTouchSafe(ply, ent)
	if(not ent:IsValid() or ent:IsPlayer())then return end
	if(not PropProtect.PlayerCanTouch(ply,ent))then return false end
end
hook.Add("PhysgunPickup", "PropProtection", PropProtect.PlayerCanTouchSafe)
