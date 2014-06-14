local Utl = Singularity.Utl --Makes it easier to read the code.
local SubSpaces = SubSpaces --SPEED!!! WEEEEEE

function SubSpaces:ShouldCollide( ent1, ent2 )
	return ent1:GetSubSpace() == ent2:GetSubSpace()
end

function ShouldEntitiesCollide( ent1, ent2 )
	if (ent1:IsWorld() or ent2:IsWorld())then return true end
	if ( ent1 == ent2 ) then return false end
	if ( SubSpaces:ShouldCollide( ent1 , ent2  ) ) then
		return true
	else
		return false
	end
end
hook.Add( "ShouldCollide", "LayerCollide", ShouldEntitiesCollide )

if(SERVER)then
	function SubSpaces.EntitySpawnLayer( ply, ent ) ent:SetSubSpace( ply:GetSubSpace() ) ent:SetCustomCollisionCheck() end
	function SubSpaces.EntitySpawnLayerProxy( ply, mdl, ent ) SubSpaces.EntitySpawnLayer( ply, ent ) end
	function SubSpaces.OnEntityCreated( ent ) ent:SetCustomCollisionCheck() if ent:GetSubSpace()=="" then ent:SetSubSpace(SubSpaces.MainSpace) end end	
	function SubSpaces.OnEntityRemove( ent ) SubSpaces.SubSpaces[ent:GetSubSpace()].Entitys[ent:EntIndex()]=nil end
	
	function SubSpaces.InitializePlayerLayer( ply ) 
		ply:SetSubSpace(SubSpaces.MainSpace) 
		ply:SetCustomCollisionCheck() 
		Utl:SetupThinkHook("SubSpaceSync:"..ply:Nick(),5,1,SubSpaces.SyncLayers)		
	end	
	
	function SubSpaces.HandlePlayerSpawn(ply)
		local Spawns = ents.FindByClass("sing_spawn")
		if table.Count(Spawns or {}) > 0 then
			Spawn = table.Random(Spawns)
			ply:SetPos(Spawn:GetPos()+Vector(0,0,20))
			ply:SetSubSpace(Spawn:GetSubSpace())
		end
	end
	
	Utl:HookHook("PlayerSpawnedSENT","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedNPC","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedVehicle","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedProp","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedEffect","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedRagdoll","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerInitialSpawn","SubSpace",SubSpaces.InitializePlayerLayer,1)
	Utl:HookHook("PlayerSpawn","SubSpace",SubSpaces.HandlePlayerSpawn,1)	
	Utl:HookHook("OnEntityCreated","SubSpace",SubSpaces.OnEntityCreated,1)
	Utl:HookHook("OnRemove","SubSpace",SubSpaces.OnEntityRemove,1)		
end		 
