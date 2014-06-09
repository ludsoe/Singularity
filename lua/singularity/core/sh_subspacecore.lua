--[[----------------------------------------------------
SubSpace Core -Manages the subspace systems of the mod allowing an bigger universe.
----------------------------------------------------]]--
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local LoadFile = Singularity.LoadFile

SubSpaces = SubSpaces or {}
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

function SubSpaces.SubSpaceTab(subspace)
	return SubSpaces.SubSpaces[subspace]
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

Utl:SetupThinkHook("GetMapSize",0,1,function() SubSpaces.GetMapSize() end)--Because running it first things first caused crashs.

Utl:SetupThinkHook("SubSpaceMovement",0.01,0,function() 
	for id, subspace in pairs( SubSpaces.SubSpaces ) do
		subspace.Pos = subspace.Pos+(subspace.VVel/100) --Move the subspace based on its velocity.
		subspace.Ang = subspace.Ang+(Angle(subspace.AVel.p/100,subspace.AVel.y/100,subspace.AVel.r/100)) --Rotate it now.
	end			
end)

if(SERVER)then
	AddCSLuaFile( "vgui/layerlist.lua" )
	AddCSLuaFile( "vgui/layerlist_layer.lua" )
	--[[------------------------------------------------------------------------------------------------------------------
		SubSpace management
	------------------------------------------------------------------------------------------------------------------]]--
	util.AddNetworkString( "subspaces_destroyed" )
	util.AddNetworkString( "subspaces_clearall" )
	
	function SubSpaces:SyncSubSpace(Name,SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="subspace_create",Val=1,Dat={
			{N="N",T="S",V=Name},
			{N="T",T="S",V=SubSpace.Title},
			{N="O",T="S",V=SubSpace.Owner},
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
			{N="A",T="A",V=SubSpace.Ang},
			{N="VV",T="V",V=SubSpace.VVel},
			{N="AV",T="A",V=SubSpace.AVel}			
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
	
	function SubSpaces:UpdateLayers()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			SubSpaces:UpdateSubSpace(subspace)
		end	
	end
	Utl:SetupThinkHook("SubSpaceUpdate",0.1,0,SubSpaces.UpdateLayers)

	function SubSpaces:WorldGenLayer(Name,Vect,Ang,Type)
		if(not SubSpaces.SubSpaces[Name])then
			print("Generating "..Name.." subspace")
			local SubSpace = {}

			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, VVel = Vector(), AVel=Angle(), Ang = Ang, Entitys={}, Age=CurTime(), Importance = Type}
			SubSpaces.SubSpaces[Name]=SubSpace
			SubSpaces.SubSpaceKeys[tostring(Vect)]=SubSpaces.SubSpaces[Name] --Vector to subspace key link.
			
			SubSpaces:SyncSubSpace(Name,SubSpace)
		else
			Utl:Debug("SubSpaces","Error Subspace: "..Name.." already exists!","Error")
		end
	end
	
	--Ease Function To get a new empty subspace. (At vec(0,0,0) of course.)
	function SubSpaces:GetEmptySubSpace()
		local ID = "ShipSpace "..math.random(1,999)--Generate a random subspace Name.
		if(SubSpaces.SubSpaces[ID])then
			return ShipS.GetEmptySubSpace() --Name was taken, lets try again.
		else
			SubSpaces:WorldGenLayer(ID,Vector(),Angle(),false)--Generate the subspace using our new name.
			return ID --Return our new subspace
		end
	end
	
	function SubSpaces:MoveSubSpace(Name,Vect,Ang)
		local SubSpace = SubSpaces.SubSpaces[Name]
		SubSpace.Pos=Vect or SubSpace.Pos
		SubSpace.Ang=Ang or SubSpace.Ang
		
		SubSpaces:UpdateSubSpace(SubSpace)
	end
	
	function SubSpaces:AddMoveSubSpace(Name,Vect,Ang)
		local SubSpace = SubSpaces.SubSpaces[Name]
		SubSpace.VVel=Vect or SubSpace.VVel
		SubSpace.AVel=Ang or SubSpace.AVel
		
		SubSpaces:UpdateSubSpace(SubSpace)
	end
	
	SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(),Angle(),true)
	
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
	
	concommand.Add( "subspaces_sync", function( ply ) SubSpaces:SyncLayers() end )
	concommand.Add( "subspaces_select", function( ply, com, args )
		if ( ply:IsValid() and SubSpaces.SubSpaces[args[1]] ) then
			ply.SelectedLayer = args[1] 
		end
	end )


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
	
else	
	--SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
	Singularity.Utl:HookNet("subspace_create","",function(D)
		local id, title, owner, pos, ang = D.N, D.T, D.O, D.V, D.A
		if ( SubSpaces.layerList ) then		
			if(SubSpaces.SubSpaces[id])then
			--	print("SubSpace already synced.")
			else
				SubSpaces.layerList:AddLayer( id, title, owner, pos )
			end
		end
		SubSpaces.SubSpaces[id]={Owner=owner,Title=Title,Pos=pos,Ang=ang,VVel=Vector(),AVel=Angle()}
		--print(id.." is synced now clientside.")
	end)
	
	Singularity.Utl:HookNet("subspaces_update","",function(D)
		local id, pos, ang, vel, angv = D.T, D.V, D.A, D.VV,D.AV
		local SS = SubSpaces.SubSpaces[id] if not SS then return end
		SS.Pos=pos SS.Ang=ang SS.AVel = angv SS.VVel = vel
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
	NoDraw["sing_anchor"]=true
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
	
	function SubSpaces.GetSubSpaceEntity(subspace)
		local Table = SubSpaces.SubSpaceTab(subspace)
		if not Table then return end
		if not IsValid(Table.Anchor) then
			Table.Anchor = ents.CreateClientProp()
		end
		--Table.Anchor:SetAngles(Table.Ang)
		return Table.Anchor
	end
end

LoadFile("singularity/core/subspace/sh_overrides.lua",1)