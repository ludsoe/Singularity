--[[----------------------------------------------------
SubSpace Core -Manages the subspace systems of the mod allowing an bigger universe.
----------------------------------------------------]]--

local Utl = Singularity.Utl --Makes it easier to read the code.

SubSpaces = SubSpaces or {}
SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
SubSpaces.SubSpaceKeys = SubSpaces.SubSpaceKeys or {}
SubSpaces.ThinkFuncs = SubSpaces.ThinkFuncs or {}

SubSpaces.Center = Vector(0,0,0)
SubSpaces.MapSize = 16000
SubSpaces.MainSpace = "MainSpace"
SubSpaces.NullSpace = "NullSpace"

--[[------------------------------------------------------------------------------------------------------------------
	Basic set and get subspace functions
------------------------------------------------------------------------------------------------------------------]]--
local ENT = FindMetaTable( "Entity" )
local PLY = FindMetaTable( "Player" )

function ENT:SetSubSpace( subspace )
	local OldSub = self:GetSubSpace()
	if(OldSub==subspace)then return end --Dont run if were trying to change to the same subspace
	if(self:IsPlayer())then
	
	else
		SubSpaces.SubSpaces[OldSub].Entitys[self:EntIndex()]=nil
		SubSpaces.SubSpaces[subspace].Entitys[self:EntIndex()]=self
	end
	
	self:SetNWString( "SubSpace", subspace )
	if ( !self.UsingCamera ) then self:SetViewSubSpace( subspace ) end
end

function ENT:SetViewSubSpace( subspace )
	self:SetNWString( "ViewSubSpace", subspace )
end

function ENT:GetSubSpace()
	if(SERVER)then
		return self:GetNWString( "SubSpace",SubSpaces.MainSpace )
	else
		if ( !self:IsValid() ) then return SubSpaces.MainSpace end
		return self:GetNWString( "SubSpace",SubSpaces.MainSpace )
	end
end

function ENT:GetViewSubSpace()
	if(SERVER)then
		return self:GetNWString( "ViewSubSpace",SubSpaces.MainSpace)
	else
		return self:GetNWString("ViewSubSpace",SubSpaces.MainSpace)
	end
end

--[[------------------------------------------------------------------------------------------------------------------
	Collision handling
------------------------------------------------------------------------------------------------------------------]]--

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

--[[------------------------------------------------------------------------------------------------------------------
	Trace modification
------------------------------------------------------------------------------------------------------------------]]--

if(not SubSpaces.OriginalTraceLine)then
	SubSpaces.OriginalTraceLine = util.TraceLine
end
function util.TraceLine( td, subspace )
	if ( !subspace ) then 
		if(SERVER)then
			subspace = "Global"
		else
			subspace = LocalPlayer():GetSubSpace()
		end
	end
	local originalResult = SubSpaces.OriginalTraceLine( td )
	if ( !originalResult.Entity:IsValid() or originalResult.Entity:GetSubSpace() == subspace or subspace=="Global") then
		return originalResult
	else
		if ( td.filter ) then
			if ( type( td.filter ) == "table" ) then
				table.insert( td.filter, originalResult.Entity )
			else
				td.filter = { td.filter, originalResult.Entity }
			end
		else
			td.filter = originalResult.Entity
		end
		
		return util.TraceLine( td )
	end
end

if(not SubSpaces.OriginalPlayerTrace)then
	SubSpaces.OriginalPlayerTrace = util.GetPlayerTrace
end
function util.GetPlayerTrace( ply, dir )
	local originalResult = SubSpaces.OriginalPlayerTrace( ply, dir )
	originalResult.filter = { ply }
	
	for _, ent in ipairs( ents.GetAll() ) do
		if ( ent:GetSubSpace() != ply:GetSubSpace() ) then
			table.insert( originalResult.filter, ent )
		end
	end
	
	return originalResult
end
 
 ---Function to grab the maps size using raytracing and guessing.
function SubSpaces.GetMapSize()
	local Directions = {
		Up=Vector(0,0,1),
		Down=Vector(0,0,-1),
		Right=Vector(1,0,0),
		Left=Vector(-1,0,0),
		Forw=Vector(0,1,0),
		Back=Vector(0,-1,0)
	}
	
	local Lengths = {}
	
	for name, Dir in pairs( Directions ) do
		Msg("Tracing "..name.." Dist: ")
		local tr = {}
		local TraceDist = 300000
		
		tr.start = SubSpaces.Center
		tr.endpos = SubSpaces.Center+(Dir*TraceDist)
		
		local Trace = util.TraceLine( tr,"")
		local Dist = math.floor(SubSpaces.Center:Distance(Trace.HitPos))
		local Key = tostring(Dist)
		if(Lengths[Key])then
			Lengths[Key]=Lengths[Key]+1
		else
			Lengths[Key]=1
		end
		Msg(Dist.."\n")
	end
	
	local Dist=0
	local DCou=0
	for name, Num in pairs( Lengths ) do
		if(Num>DCou)then
			Dist=tonumber(name)
			DCou=Num
		end
	end
	
	SubSpaces.MapSize=Dist
	
	print("I Think the Map Size is "..Dist)
end

if(SERVER)then
	Utl:SetupThinkHook("GetMapSize",10,1,function() SubSpaces.GetMapSize() end)--Because running it first things first caused crashs.
 
	
	--[[------------------------------------------------------------------------------------------------------------------
		Serverside subspaces core
	------------------------------------------------------------------------------------------------------------------]]--

	AddCSLuaFile( "vgui/layerlist.lua" )
	AddCSLuaFile( "vgui/layerlist_layer.lua" )
	
	local Func = function()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			if(not subspace.Importance)then --Make sure the subspace has a timed despawn.
				if(subspace.Age+30<CurTime())then --Give subspaces that were just created time to fill with entities.
					local EntCount=table.Count(subspace.Entitys)
					if(EntCount<=0)then --Make sure theres no entitys in the subspace.
						SubSpaces:DestroyLayerByKey( id ) --Kill it.
					end
				end
			end
		end
	end
	Utl:SetupThinkHook("SpaceCleaner",1,0,Func)
	Utl:SetupThinkHook("SubSpaceSync",60,0,function() SubSpaces:SyncLayers() end)
	
	--[[------------------------------------------------------------------------------------------------------------------
		SubSpace management
	------------------------------------------------------------------------------------------------------------------]]--
	util.AddNetworkString( "subspaces_create" )
	util.AddNetworkString( "subspaces_destroyed" )
	util.AddNetworkString( "subspaces_clearall" )
	
	function SubSpaces:SyncLayer(Name,SubSpace)
		print("syncing "..Name.." subspace")
		net.Start( "subspaces_create" )
			net.WriteString(Name)
			net.WriteString(SubSpace.Title)
			net.WriteString(SubSpace.Owner)
			net.WriteVector(SubSpace.Pos)
		net.Broadcast()
	end
	
	function SubSpaces:SyncLayers()
		net.Start( "subspaces_clearall" )
		net.Broadcast()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			SubSpaces:SyncLayer(id,subspace)
		end	
	end
	
	function SubSpaces:CreateLayer( ply, title ) --Disabled for now.
		--[[if ( !ply.OwnedLayer ) then
			local Name = ply:Nick()
			local SubSpace = { Owner = Name, Title = title , Pos = Vector(0,0,0), Entitys={} , Age=CurTime() , Importance = true}
			SubSpaces.SubSpaces[Name]=SubSpace
			SubSpaces:SyncLayer(Name,SubSpace)
			ply.OwnedLayer = Name
		end]]
	end 
	
	function SubSpaces:WorldGenLayer(Name,Vect,Type)
		if(not SubSpaces.SubSpaces[Name])then
			print("Generating "..Name.." subspace")
			local SubSpace = {}
			--local id = table.insert( SubSpaces.SubSpaces, SubSpace )
			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, Entitys={}, Age=CurTime() , Importance = Type}
			SubSpaces.SubSpaces[Name]=SubSpace
			
			if(not Vect==Vector(0,0,0) or Name == SubSpaces.MainSpace)then
				SubSpaces.SubSpaceKeys[tostring(Vect)]=SubSpaces.SubSpaces[Name] --Vector to subspace key link.
			end
			
			SubSpaces:SyncLayer(Name,SubSpace)
		else
			Utl:Debug("SubSpaces","Error Subspace: "..Name.." already exists!","Error")
		end
	end
	
	--Ease Function To get a new empty subspace. (At vec(0,0,0) of course.)
	function SubSpaces:GetEmptySubSpace()
		local ID = "SubSpace "..math.random(1,600)--Generate a random subspace Name.
		if(SubSpaces.SubSpaces[ID])then
			return ShipS.GetEmptySubSpace() --Name was taken, lets try again.
		else
			SubSpaces:WorldGenLayer(ID,Vector(0,0,0),false)--Generate the subspace using our new name.
			return ID --Return our new subspace
		end
	end

	SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(0,0,0),true)
	SubSpaces:WorldGenLayer(SubSpaces.NullSpace,Vector(0,0,0),true)
	
	function SubSpaces:DestroyLayerByKey( Key,Protect )
		local STable = SubSpaces.SubSpaces[Key]
		if(STable)then
			print("Deleting Subspace "..Key)
			net.Start( "subspaces_destroyed" )
				net.WriteString(Key)
			net.Broadcast()
			
			--Remove the vector key.
			SubSpaces.SubSpaceKeys[tostring(STable.Pos)]=nil
			
			if(Protect)then
				for ID, ent in pairs( STable.Entitys ) do
					ent:SetSubSpace( SubSpaces.MainSpace )
				end
			end
			
			STable = nil
		end
	end
	
	function SubSpaces:DestroyLayer( ply )
		if ( ply.OwnedLayer ) then		
			SubSpaces:DestroyLayerByKey( ply.OwnedLayer,true )
		end
	end

	concommand.Add( "subspaces_create", function( ply )
		if ( ply:IsValid() ) then
			SubSpaces:CreateLayer( ply, ply:Nick() .. "'s subspace")
		end
	end )

	concommand.Add( "subspaces_destroy", function( ply )
		if ( ply:IsValid() ) then
			SubSpaces:DestroyLayer( ply )
		end
	end )

	concommand.Add( "subspaces_select", function( ply, com, args )
		if ( ply:IsValid() and SubSpaces.SubSpaces[args[1]] ) then
			ply.SelectedLayer = args[1] 
		end
	end )

	concommand.Add( "subspaces_sync", function( ply )
		SubSpaces:SyncLayers()
	end )

	--[[------------------------------------------------------------------------------------------------------------------
		Constraint handling
	------------------------------------------------------------------------------------------------------------------]]--

	if(not SubSpaces.OldKeyframeRope)then
		SubSpaces.OldKeyframeRope = constraint.CreateKeyframeRope
	end
	function constraint.CreateKeyframeRope( pos, width, material, constr, ent1, lpos1, bone1, ent2, lpos2, bone2, kv )
		local rope = SubSpaces.OldKeyframeRope( pos, width, material, constr, ent1, lpos1, bone1, ent2, lpos2, bone2, kv )
		
		if ( rope ) then
			if ( ent1:IsWorld() and !ent2:IsWorld() ) then
				rope:SetNWEntity( "CEnt", ent2 )
			elseif ( !ent1:IsWorld() and ent2:IsWorld() ) then
				rope:SetNWEntity( "CEnt", ent1 )
			else
				// For a pulley, the two specified entities are both the world for the middle rope, so we just remember the entity from the first rope
				rope:SetNWEntity( "CEnt", SubSpaces.KeyframeEntityCache )
			end
		end
		
		SubSpaces.KeyframeEntityCache = ent1
		
		return rope
	end		
	
	--[[------------------------------------------------------------------------------------------------------------------
		Camera handling
	------------------------------------------------------------------------------------------------------------------]]--
	if(not SubSpaces.OldSetViewEntity)then
		SubSpaces.OldSetViewEntity = PLY.SetViewEntity
		function PLY:SetViewEntity( ent )
			self:SetViewSubSpace( ent:GetSubSpace() )
			return SubSpaces.OldSetViewEntity( self, ent )
		end
	end

	--[[------------------------------------------------------------------------------------------------------------------
		Set the subspace of spawned entities
	------------------------------------------------------------------------------------------------------------------]]--

	function SubSpaces.EntitySpawnLayer( ply, ent )
		ent:SetSubSpace( ply:GetSubSpace() )
		ent:SetCustomCollisionCheck()
	end

	function SubSpaces.EntitySpawnLayerProxy( ply, mdl, ent )
		SubSpaces.EntitySpawnLayer( ply, ent )
	end

	function SubSpaces.InitializePlayerLayer( ply )
		ply:SetSubSpace(SubSpaces.MainSpace)
		ply:SetCustomCollisionCheck()
	end

	function SubSpaces.OnEntityCreated( ent )
		ent:SetCustomCollisionCheck()
	end	

	Utl:HookHook("PlayerSpawnedSENT","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedNPC","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedVehicle","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedProp","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedEffect","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedRagdoll","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerInitialSpawn","SubSpace",SubSpaces.InitializePlayerLayer,1)
	Utl:HookHook("OnEntityCreated","SubSpace",SubSpaces.OnEntityCreated,1)
	
	if(not SubSpaces.OriginalAddCount)then
		SubSpaces.OriginalAddCount = PLY.AddCount
	end
	function PLY:AddCount( type, ent )
		ent:SetSubSpace( self:GetSubSpace() )
		return SubSpaces.OriginalAddCount( self, type, ent )
	end
	
	if(not SubSpaces.OriginalCleanup)then
		SubSpaces.OriginalCleanup = cleanup.Add
	end
	function cleanup.Add( ply, type, ent )
		if ( ent ) then ent:SetSubSpace( ply:GetSubSpace() ) end
		return SubSpaces.OriginalCleanup( ply, type, ent )
	end
else	
	--SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
	net.Receive( "subspaces_create", function( length, client )
		if ( SubSpaces.layerList ) then
			local id, title, owner, pos = net.ReadString(), net.ReadString(), net.ReadString(), net.ReadVector()
			
			if ( owner == LocalPlayer() ) then
				SubSpaces.layerList.HasLayer = true
				SubSpaces.layerList.CreateButton:SetText( "Remove your subspace" )
			end
			
			if(SubSpaces.SubSpaces[id])then
				print("SubSpace already synced.")
			else
				SubSpaces.layerList:AddLayer( id, title, owner, pos )
				SubSpaces.SubSpaces[id]={Owner=owner,Title=Title,Pos=pos}
			end
			
		end		
	end )
	
	net.Receive( "subspaces_clearall", function( length, client )
		if ( SubSpaces.layerList ) then
			print("Killing ALL subspaces!")
			for _, subspace in pairs( SubSpaces.layerList.List:GetItems() ) do
				if ( subspace.SubSpace.Owner == LocalPlayer():Nick() ) then
					SubSpaces.layerList.HasLayer = false
					SubSpaces.layerList.CreateButton:SetText( "Create new subspace" )
				end
				
				SubSpaces.layerList.List:RemoveItem( subspace )
			end
			SubSpaces.SubSpaces={}
		end	
	end )
	
	net.Receive( "subspaces_destroyed", function( length, client )
		if ( SubSpaces.layerList ) then
			local layerId = net.ReadString()
			print("Killing subspace: "..layerId)

			for _, subspace in pairs( SubSpaces.layerList.List:GetItems() ) do
				if ( subspace.SubSpace.ID == layerId ) then
					if ( subspace.SubSpace.Owner == LocalPlayer():Nick()  ) then
						SubSpaces.layerList.HasLayer = false
						SubSpaces.layerList.CreateButton:SetText( "Create new subspace" )
					end
					
					SubSpaces.layerList.List:RemoveItem( subspace )
					SubSpaces.SubSpaces[layerId]=nil
					break
				end
			end
		end	
	end )
	
	--[[------------------------------------------------------------------------------------------------------------------
		Rendering
	------------------------------------------------------------------------------------------------------------------]]--

	function SubSpaces:SetEntityVisiblity( ent, subspace )
		if ( ent:EntIndex() < 0 or !ent:IsValid() ) then return end
		
		local visible = false
		
		if ( ent:GetOwner():IsValid() ) then
			visible = ent:GetOwner():GetSubSpace() == subspace
		elseif ( ent:GetClass() == "class C_RopeKeyframe" ) then
			visible = ent:GetNWEntity( "CEnt", ent ):GetSubSpace() == subspace
		else
			visible = ent:GetSubSpace() == subspace
		end
		
		if ( ent:GetClass() == "class C_RopeKeyframe" ) then
			if ( visible ) then
				ent:SetColor( 255, 255, 255, 255 )
			else
				ent:SetColor( 255, 255, 255, 0 )
			end
		else
			ent:SetNoDraw( !visible )
			
			if ( visible and !ent.LayerVisibility ) then
				ent:CreateShadow()
			end
		end
		
		ent.LayerVisibility = visible
	end

	function SubSpaces.RenderEntities()
		local localLayer = LocalPlayer():GetViewSubSpace()
		
		for _, ent in ipairs( ents.GetAll() ) do
			SubSpaces:SetEntityVisiblity( ent, localLayer )
			
			if ( ent.SubSpace and ent.SubSpace != ent:GetSubSpace() and ( ent.SubSpace != localLayer and ent:GetSubSpace() == localLayer ) or ( ent.SubSpace == localLayer and ent:GetSubSpace() != localLayer ) and !ent:GetOwner():IsValid() ) then
				local ed = EffectData()
				
				ed:SetEntity( ent )
				util.Effect( "entity_remove", ed, true, true )	
			end
			
			ent.SubSpace = ent:GetSubSpace()
		end
	end
	hook.Add( "RenderScene", "LayersEntityDrawing", SubSpaces.RenderEntities )
	
	if(not SubSpaces.oldEmitSound)then
		SubSpaces.oldEmitSound = ENT.EmitSound
	end
	function ENT:EmitSound( filename, soundlevel, pitchpercent )
		if LocalPlayer():GetSubSpace() != self:GetSubSpace() then return end
		
		SubSpaces.oldEmitSound( self, filename, soundlevel, pitchpercent )
	end
end