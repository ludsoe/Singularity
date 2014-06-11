local SubSpaces = SubSpaces --SPEED!!! WEEEEEE
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

if(SERVER)then
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
else
	Utl:HookNet("subspace_create","",function(D)
		local id, title, owner, pos, ang = D.N, D.T, D.O, D.V, D.A
		if SubSpaces.layerList then		
			if not SubSpaces.SubSpaces[id] then
				SubSpaces.layerList:AddLayer( id, title, owner, pos )
			end
		end
		SubSpaces.SubSpaces[id]={Owner=owner,Title=Title,Pos=pos,Ang=ang,VVel=Vector(),AVel=Angle()}
	end)
	
	Utl:HookNet("subspaces_update","",function(D)
		local SS = SubSpaces.SubSpaces[D.T] if not SS then return end
		SS.Pos=D.V SS.Ang=D.A SS.AVel = D.AV SS.VVel = D.VV
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
