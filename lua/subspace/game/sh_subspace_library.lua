local SubSpaces = SubSpaces --SPEED!!! WEEEEEE
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
SubSpaces.SubSpaceKeys = SubSpaces.SubSpaceKeys or {}

--Setup locations for our map center and skybox center
SubSpaces.Center = Vector(0,0,0)
SubSpaces.SkyBox = Vector(0,0,-14144)

--Setup the size of our map and skybox
SubSpaces.MapSize = SubSpaces.MapSize or 16000
SubSpaces.SkySize = SubSpaces.SkySize or SubSpaces.MapSize/128

--The scale we render at
SubSpaces.Scale = SubSpaces.Scale or 128

--The name of the default subspace
SubSpaces.MainSpace = "MainSpace"

----------------------------
------------Main------------
----------------------------

--Returns the subspaces table
function SubSpaces.SubSpaceTab(subspace) return SubSpaces.SubSpaces[subspace] or {} end

if(SERVER)then
	--Generates a subspace table and syncs it.
	function SubSpaces:WorldGenLayer(Name,Vect,Ang,Type)
		if(not SubSpaces.SubSpaces[Name])then
			print("Generating "..Name.." subspace")
			local SubSpace = {}
			
			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, VVel = Vector(), AVel=Angle(), Ang = Ang, Entitys={}, Importance = Type, Bubble={}, Size = 0, DryDock=false}
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

else

end		

--To run after the entire file loads.
function PostLoad()
	if(SERVER)then
		SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(),Angle(),true)
		SubSpaces:WorldGenLayer("NullSpace",Vector(),Angle(),true)
	else

	end
end

----------------------------
----------Physics-----------
----------------------------


----------------------------
---------Rendering----------
----------------------------

if(SERVER)then
	AddCSLuaFile( "vgui/layerlist.lua" )
	AddCSLuaFile( "vgui/layerlist_layer.lua" )
else
	local NR,IG = Singularity.NoRender,Singularity.IgnoreClasses

	function SubSpaces:SetEntityVisiblity( ent, subspace )
		if ent:EntIndex() < 0 or not ent:IsValid() then return end
		if ent.StarField then return end --Dont touch the space background
		
		local visible = false
		
		local class = ent:GetClass()
		if NR[class] or IG[class] then
			visible=true
		else
			if IsValid(ent:GetOwner()) then
				visible = ent:GetOwner():GetSubSpace() == subspace
			else
				visible = ent:GetSubSpace() == subspace
			end
			
			if not visible then
				if not SubSpaces.SubSpaceTab(ent:GetSubSpace() or "").DryDock then 
					--This is where we put rendering of other subspaces at
				end
			end
		end
		ent:SetNoDraw( not visible ) --Make it invisible.
	end

	function SubSpaces.RenderEntities()
		local localLayer = LocalPlayer():GetViewSubSpace()	
		for _, ent in ipairs( ents.GetAll() ) do
			SubSpaces:SetEntityVisiblity( ent, localLayer )			
		end
		--util.Effect( "starmeshent", EffectData() )
	end
	hook.Add( "RenderScene", "SingularityEntityDrawing", SubSpaces.RenderEntities )
end

----------------------------
--Entity Meta Table Functions
----------------------------

local ENT,PLY = FindMetaTable( "Entity" ),FindMetaTable( "Player" )

function ENT:SetSubSpace( subspace )
	local OldSub = self:GetSubSpace()
	if OldSub==subspace then return end --Dont run if were trying to change to the same subspace

	if OldSub~="" then
		SubSpaces.SubSpaces[OldSub].Entitys[self:EntIndex()]=nil
	end
	SubSpaces.SubSpaces[subspace].Entitys[self:EntIndex()]=self

	self:SetNWString( "SubSpace", subspace )
	if not self.UsingCamera then self:SetViewSubSpace( subspace ) end
end

function ENT:SetViewSubSpace( subspace ) self:SetNWString( "ViewSubSpace", subspace ) end

function ENT:GetSubSpace() return self:GetNWString( "SubSpace", "" ) end

function ENT:GetUniPos() return SubSpaces.SubSpacePos(self:GetSubSpace()) end

function ENT:GetUniAng() return SubSpaces.SubSpaceAng(self:GetSubSpace()) end
		
function ENT:GetViewSubSpace() return self:GetNWString("ViewSubSpace",SubSpaces.MainSpace) end

----------------------------
-----------Hooks------------
----------------------------

function SubSpaces:ShouldCollide( ent1, ent2 )
	return ent1:GetSubSpace() == ent2:GetSubSpace()
end

function ShouldEntitiesCollide( ent1, ent2 )
	if ent1:IsWorld() or ent2:IsWorld() then return true end
	if ent1 == ent2 then return false end
	if SubSpaces:ShouldCollide( ent1 , ent2  ) then
		return true
	else
		return false
	end
end
hook.Add( "ShouldCollide", "LayerCollide", ShouldEntitiesCollide )

if(SERVER)then
	local IG = Singularity.IgnoreClasses

	function SubSpaces.EntitySpawnLayer( ply, ent ) ent:SetSubSpace( ply:GetSubSpace() ) ent:SetCustomCollisionCheck()  end
	function SubSpaces.EntitySpawnLayerProxy( ply, mdl, ent ) SubSpaces.EntitySpawnLayer( ply, ent ) end
	function SubSpaces.OnEntityCreated( ent ) if IG[ent:GetClass()] then return end ent:SetCustomCollisionCheck() if ent:GetSubSpace()=="" then ent:SetSubSpace(SubSpaces.MainSpace) end end	
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

----------------------------
---------Networking---------
----------------------------

if(SERVER)then
	util.AddNetworkString( "subspaces_destroyed" )
	util.AddNetworkString( "subspaces_clearall" )
	
	function SubSpaces:SyncSubSpace(Name,SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="subspace_create",Val=1,Dat={
			N=Name,
			T=SubSpace.Title,
			O=SubSpace.Owner
		}}
		
		NDat.AddDataAll(Data)
	end
	
	function SubSpaces:SyncLayers()
		net.Start( "subspaces_clearall" ) net.Broadcast()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			SubSpaces:SyncSubSpace(id,subspace)
		end	
	end
	
	function SubSpaces:UpdateSubSpace(SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="subspaces_update",Val=1,Dat={
			T=SubSpace.Title,
		}}
		NDat.AddDataAll(Data)
	end	
	
	function SubSpaces:UpdateLayers()
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			SubSpaces:UpdateSubSpace(subspace)
		end	
	end
	--Utl:SetupThinkHook("SubSpaceUpdate",1,0,SubSpaces.UpdateLayers)
	
	Utl:HookNet("subspaces_request_sync",function(Dat,Ply)
		SubSpaces:SyncLayers()
	end)
	
	Utl:HookNet("subspaces_player_select",function(Dat,Ply)
		local ID = Dat.ID
		if IsValid(Ply) and SubSpaces.SubSpaces[ID] then
			Ply.SelectedLayer = ID
		end
	end)
else
	Utl:HookNet("subspace_create",function(D)
		print("Recieved SubSpace Data")
		local id, title, owner = D.N, D.T, D.O
		SubSpaces.SubSpaces[id]={Owner=owner,Title=title}
	end)
	
	Utl:HookNet("subspaces_update",function(D)
		local SS = SubSpaces.SubSpaces[D.T] if not SS then return end

	end)

	net.Receive( "subspaces_clearall", function( length, client )
		if SubSpaces.layerList then
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
end		 

PostLoad()
