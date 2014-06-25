
local Singularity = Singularity

function Singularity.CanNoClip(ply) 
    --if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if ply:IsAdmin() then return true end -- Only Admins can Noclip.

    return false    
end

hook.Add( "CanDrive","FUCKCANDRIVE", function( ply, ent ) return false end)

if SERVER then
	Singularity.PropProtect = Singularity.PropProtect or {}
	local PropProtect = Singularity.PropProtect --SPEEEEEEED BOOOOOOST!!!!

	PropProtect.Enabled = true

	function PropProtect.PlayerCanTouch(ply, ent)
		if ent:IsWorld() then return true end
		if ent.UnTouchable then return false end
		if not ent:IsValid() or not ply:IsValid() or ent:IsPlayer() or not ply:IsPlayer() then return false end
		
		return true
	end

	function PropProtect.PlayerCanTouchSafe(ply, ent)
		if not ent:IsValid() or ent:IsPlayer() then return end
		if not PropProtect.PlayerCanTouch(ply,ent) then return (not PropProtect.Enabled) end
	end
	hook.Add("PhysgunPickup", "PropProtection", PropProtect.PlayerCanTouchSafe)
end



