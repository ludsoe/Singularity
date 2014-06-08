--[[----------------------------------------------------
SubSpace Core -Manages the subspace systems of the mod allowing an bigger universe.
----------------------------------------------------]]--

SubSpaces = SubSpaces or {}
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local SubSpaces = SubSpaces --SPEED!!! WEEEEEE
local math,ENT,PLY = math,FindMetaTable( "Entity" ),FindMetaTable( "Player" )

SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
SubSpaces.SubSpaceKeys = SubSpaces.SubSpaceKeys or {}

SubSpaces.Center = Vector(0,0,0)
SubSpaces.SkyBox = Vector(0,0,-14144)
SubSpaces.MapSize = SubSpaces.MapSize or 16000
SubSpaces.SkySize = SubSpaces.SkySize or SubSpaces.MapSize/128
SubSpaces.Scale = SubSpaces.Scale or 128
SubSpaces.MainSpace = "MainSpace"

function SubSpaces.SubSpacePos(subspace)
	if SubSpaces.SubSpaces[subspace] then
		return SubSpaces.SubSpaces[subspace].Pos or Vector(0,0,0)
	end
	return Vector(0,0,0)
end

function SubSpaces.SubSpaceAng(subspace)
	if SubSpaces.SubSpaces[subspace] then
		return SubSpaces.SubSpaces[subspace].Ang or Angle(0,0,0)
	end
	return Angle(0,0,0)
end

--[[------------------------------------------------------------------------------------------------------------------
	Basic set and get subspace functions
------------------------------------------------------------------------------------------------------------------]]--

function ENT:SetSubSpace( subspace )
	local OldSub = self:GetSubSpace()
	if(OldSub==subspace)then return end --Dont run if were trying to change to the same subspace

	if(OldSub~="")then
		SubSpaces.SubSpaces[OldSub].Entitys[self:EntIndex()]=nil
	end
	SubSpaces.SubSpaces[subspace].Entitys[self:EntIndex()]=self

	self:SetNWString( "SubSpace", subspace )
	self:SetNWVector( "UniPos", SubSpaces.SubSpaces[subspace].Pos or Vector(0,0,0) )
	if ( !self.UsingCamera ) then self:SetViewSubSpace( subspace ) end
end

function ENT:SetViewSubSpace( subspace )
	self:SetNWString( "ViewSubSpace", subspace )
end

function ENT:GetSubSpace()
	return self:GetNWString( "SubSpace", "" )
end

function ENT:GetUniPos()
	return SubSpaces.SubSpacePos(self:GetSubSpace())
end

function ENT:GetUniAng()
	return SubSpaces.SubSpaceAng(self:GetSubSpace())
end
		
function ENT:GetViewSubSpace()
	return self:GetNWString("ViewSubSpace",SubSpaces.MainSpace)
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

if(not SubSpaces.OriginalTraceLine)then SubSpaces.OriginalTraceLine = util.TraceLine end
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

if not SubSpaces.OriginalPlayerTrace then SubSpaces.OriginalPlayerTrace = util.GetPlayerTrace end
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

 
 --Function to grab the maps size using raytracing and guessing.
function SubSpaces.GetAreaSize(Vec)
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
		
		tr.start = Vec
		tr.endpos = Vec+(Dir*TraceDist)
		tr.mask = 147467
		
		local Trace = util.TraceLine( tr,"")
		local Dist = math.floor(Vec:Distance(Trace.HitPos))
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
	--print("I Think the Area Size is "..Dist)
	
	return Dist
end

function SubSpaces.GetMapSize()
	SubSpaces.MapSize=SubSpaces.GetAreaSize(SubSpaces.Center)
	SubSpaces.SkySize=SubSpaces.GetAreaSize(SubSpaces.SkyBox)
	
	print("Map Size "..SubSpaces.MapSize)
	print("Sky Size "..SubSpaces.SkySize)
	print("Scale "..SubSpaces.Scale)
end

Utl:SetupThinkHook("SubSpaceInit",0,1,function()
	if SERVER then
		SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(0,0,0),Angle(0,0,0),true)
	end
	SubSpaces.GetMapSize() 
end)--Because running it first things first caused crashs.

if(SERVER)then
	
	--[[------------------------------------------------------------------------------------------------------------------
		Serverside subspaces core
	------------------------------------------------------------------------------------------------------------------]]--

	AddCSLuaFile( "vgui/layerlist.lua" )
	AddCSLuaFile( "vgui/layerlist_layer.lua" )
	
	local DistCheck = function(ply,subspace)
		local Dist = ply:GetUniPos():Distance(subspace.Pos)
		if(Dist<50)then
			return true
		end
	end
	
	local Func = function()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			if(not subspace.Importance)then --Make sure the subspace has a timed despawn.
				if(subspace.Age+3<CurTime())then --Give subspaces that were just created time to fill with entities.
					if(not Utl:LoopValidPlayers(DistCheck,subspace))then --NearbyPlayers?
						SubSpaces:DestroyLayerByKey( id ) --Kill it.
					else
						subspace.Age=CurTime()--Give the subspace a longer life if it has entitys contained in it.
					end
				end
			end
		end
	end
	Utl:SetupThinkHook("SpaceCleaner",10,0,Func)
	--Utl:SetupThinkHook("SubSpaceSync",60,0,function() SubSpaces:SyncLayers() end)
	
	--[[------------------------------------------------------------------------------------------------------------------
		SubSpace management
	------------------------------------------------------------------------------------------------------------------]]--
	util.AddNetworkString( "subspaces_create" )
	util.AddNetworkString( "subspaces_update" )
	util.AddNetworkString( "subspaces_destroyed" )
	util.AddNetworkString( "subspaces_clearall" )
	
	function SubSpaces:SyncSubSpace(Name,SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="subspace_create",Val=1,Dat={
			{N="N",T="S",V=Name},
			{N="T",T="S",V=SubSpace.Title},
			{N="O",T="S",V=SubSpace.Owner},
			{N="E",T="E",V=SubSpace.Anc},
			{N="V",T="V",V=SubSpace.Pos},
			{N="A",T="A",V=SubSpace.Ang}
		}}
		
		NDat.AddDataAll(Data)
	end
	
	function SubSpaces:UpdateSubSpace(SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="subspaces_update",Val=1,Dat={
			{N="T",T="S",V=SubSpace.Title},
			{N="V",T="V",V=SubSpace.Pos},
			{N="A",T="A",V=SubSpace.Ang}
		}}
		
		NDat.AddDataAll(Data)
	end	
	
	function SubSpaces:SyncLayers()
		net.Start( "subspaces_clearall" )
		net.Broadcast()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			SubSpaces:SyncSubSpace(id,subspace)
		end	
	end

	function SubSpaces:WorldGenLayer(Name,Vect,Ang,Type)
		if(not SubSpaces.SubSpaces[Name])then
			print("Generating "..Name.." subspace")
			local SubSpace = {}
			--local id = table.insert( SubSpaces.SubSpaces, SubSpace )
			local anchor = ents.Create("sing_anchor")
			anchor:SetPos(Vector(0,0,0)) anchor:SetAngles(Angle(0,0,0))
			
			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, Ang = Ang, Entitys={}, Age=CurTime(), Anc=anchor, Importance = Type}
			SubSpaces.SubSpaces[Name]=SubSpace
			
			SubSpaces.SubSpaceKeys[tostring(Vect)]=SubSpaces.SubSpaces[Name] --Vector to subspace key link.
			
			SubSpaces:SyncSubSpace(Name,SubSpace)
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
			SubSpaces:WorldGenLayer(ID,Vector(0,0,0),Angle(0,0,0),false)--Generate the subspace using our new name.
			return ID --Return our new subspace
		end
	end 
	
	function SubSpaces:MoveSubSpace(Name,Vect,Ang)
		local SubSpace = SubSpaces.SubSpaces[Name]
		SubSpace.Pos=Vect or SubSpace.Pos
		SubSpace.Ang=Ang or SubSpace.Ang
		
		SubSpaces:UpdateSubSpace(SubSpace)
	end
	
	function SubSpaces:DestroyLayerByKey( Key,Protect )
		local STable = SubSpaces.SubSpaces[Key]
		if(STable)then
			--print("Deleting Subspace "..Key)
			net.Start( "subspaces_destroyed" )
				net.WriteString(Key)
			net.Broadcast()
			
			--Remove the vector key.
			SubSpaces.SubSpaceKeys[tostring(STable.Pos)]=nil
			
			for ID, ent in pairs( STable.Entitys ) do
				if IsValid(ent) and ent.OnUnload then
					ent:OnUnload()
				else
					if(Protect)then
						ent:SetSubSpace( SubSpaces.MainSpace )
					else
						if IsValid(ent) then
							if ent:IsPlayer() then
								ent:Kill() --Kill players causing them to respawn.
							else
								ent:Remove() --Remove entities.
							end
						end
					end			
				end
			end
			
			SubSpaces.SubSpaces[Key] = nil
		end
	end
	
	function SubSpaces:DestroyLayer( ply )
		if ( ply.OwnedLayer ) then		
			SubSpaces:DestroyLayerByKey( ply.OwnedLayer,true )
		end
	end

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

	if not SubSpaces.OldKeyframeRope then
		SubSpaces.OldKeyframeRope = constraint.CreateKeyframeRope
	
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
	end
	
	--[[------------------------------------------------------------------------------------------------------------------
		Camera handling
	------------------------------------------------------------------------------------------------------------------]]--
	if not SubSpaces.OldSetViewEntity then
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
		if(ent:GetSubSpace()=="")then
			ent:SetSubSpace(SubSpaces.MainSpace)
		end
	end	

	function SubSpaces.OnEntityRemove( ent )
		SubSpaces.SubSpaces[ent:GetSubSpace()].Entitys[ent:EntIndex()]=nil
	end
	
	Utl:HookHook("PlayerSpawnedSENT","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedNPC","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedVehicle","SubSpace",SubSpaces.EntitySpawnLayer,1)
	Utl:HookHook("PlayerSpawnedProp","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedEffect","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerSpawnedRagdoll","SubSpace",SubSpaces.EntitySpawnLayerProxy,1)
	Utl:HookHook("PlayerInitialSpawn","SubSpace",SubSpaces.InitializePlayerLayer,1)
	Utl:HookHook("OnEntityCreated","SubSpace",SubSpaces.OnEntityCreated,1)
	Utl:HookHook("OnRemove","SubSpace",SubSpaces.OnEntityRemove,1)	
	
	if not SubSpaces.OriginalAddCount then
		SubSpaces.OriginalAddCount = PLY.AddCount
		
		function PLY:AddCount( type, ent )
			ent:SetSubSpace( self:GetSubSpace() )
			return SubSpaces.OriginalAddCount( self, type, ent )
		end
	end
	
	if not SubSpaces.OriginalCleanup then
		SubSpaces.OriginalCleanup = cleanup.Add
	
		function cleanup.Add( ply, type, ent )
			if ( ent ) then ent:SetSubSpace( ply:GetSubSpace() ) end
			return SubSpaces.OriginalCleanup( ply, type, ent )
		end
	end
else	
	--SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
	Singularity.Utl:HookNet("subspace_create","",function(D)
		local id, title, owner, pos, ang, anc = D.N, D.T, D.O, D.V, D.A, D.E
		if ( SubSpaces.layerList ) then		
			if(SubSpaces.SubSpaces[id])then
			--	print("SubSpace already synced.")
			else
				SubSpaces.layerList:AddLayer( id, title, owner, pos )
			end
		end
		SubSpaces.SubSpaces[id]={Owner=owner,Title=Title,Pos=pos,Ang=ang,Anchor=anc}
		--print(id.." is synced now clientside.")		
	end)
	
	Singularity.Utl:HookNet("subspaces_update","",function(D)
		local id, pos, ang = D.T, D.V, D.A
		local SS = SubSpaces.SubSpaces[id]
		SS.Pos=pos SS.Ang=ang	
		--print(id.." is synced now clientside.")		
	end)
	
	net.Receive( "subspaces_clearall", function( length, client )
		if ( SubSpaces.layerList ) then
			print("Killing ALL subspaces!")
			for _, subspace in pairs( SubSpaces.layerList.List:GetItems() ) do
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
	local NoDraw,Logged = {},{}
	NoDraw["class C_PlayerResource"]=true
	NoDraw["class C_GMODGameRulesProxy"]=true
	function SubSpaces:SetEntityVisiblity( ent, subspace )
		if ( ent:EntIndex() < 0 or not ent:IsValid() ) then return end
		
		local visible = false
		
		if ( ent:GetOwner():IsValid() ) then
			visible = ent:GetOwner():GetSubSpace() == subspace
		elseif ( ent:GetClass() == "class C_RopeKeyframe" ) then
			visible = ent:GetNWEntity( "CEnt", ent ):GetSubSpace() == subspace
		else
			visible = (ent:GetSubSpace() == subspace)
		end
		
		local class = ent:GetClass()
		if ( class == "class C_RopeKeyframe" ) then
			if ( visible ) then
				ent:SetColor( 255, 255, 255, 255 )
			else
				ent:SetColor( 255, 255, 255, 0 )
			end
		else
			if NoDraw[class] then
				Visible=true
			else
				if not Logged[class] then
					Logged[class]=class
					print(class)
				end
				if(not visible)then
					local effectdata = EffectData()
					effectdata:SetEntity( ent )
					util.Effect( "skyboxent", effectdata )
				end
			end
			ent:SetNoDraw( not visible ) --Make it invisible.
		end
	end
	
	function SubSpaces.RenderEntities()
		local localLayer = LocalPlayer():GetViewSubSpace()
		
		for _, ent in ipairs( ents.GetAll() ) do
			SubSpaces:SetEntityVisiblity( ent, localLayer )			
		end
	end
	hook.Add( "RenderScene", "SingularityEntityDrawing", SubSpaces.RenderEntities )
	
	if not SubSpaces.oldEmitSound then
		SubSpaces.oldEmitSound = ENT.EmitSound
		
		function ENT:EmitSound( filename, soundlevel, pitchpercent )
			if LocalPlayer():GetSubSpace() ~= self:GetSubSpace() then return end
			
			SubSpaces.oldEmitSound( self, filename, soundlevel, pitchpercent )
		end
	end
end