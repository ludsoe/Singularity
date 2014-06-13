--[[----------------------------------------------------
SubSpace Core -Manages the subspace systems of the mod allowing an bigger universe.
----------------------------------------------------]]--
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local LoadFile = Singularity.LoadFile

SubSpaces = SubSpaces or {}
local SubSpaces = SubSpaces --SPEED!!! WEEEEEE

SubSpaces.SubSpaces = SubSpaces.SubSpaces or {}
SubSpaces.SubSpaceKeys = SubSpaces.SubSpaceKeys or {}

SubSpaces.Center = Vector(0,0,0)
SubSpaces.SkyBox = Vector(0,0,-14144)
SubSpaces.MapSize = SubSpaces.MapSize or 16000
SubSpaces.SkySize = SubSpaces.SkySize or SubSpaces.MapSize/128
SubSpaces.Scale = SubSpaces.Scale or 128
SubSpaces.MainSpace = "MainSpace"

--Gets the position of the subspace.
function SubSpaces.SubSpacePos(subspace)
	local Table = SubSpaces.GetSubSpaceEntity(subspace)
	if IsValid(Table) then
		return Table:GetSubPos() or Vector(0,0,0)
	end
	return Vector(0,0,0)
end

--Gets the angle of the subspace.
function SubSpaces.SubSpaceAng(subspace)
	local Table = SubSpaces.GetSubSpaceEntity(subspace)
	if IsValid(Table) then
		return Table:GetSubAng() or Angle(0,0,0)
	end
	return Angle(0,0,0)
end

--Returns the table of a subspace.
function SubSpaces.SubSpaceTab(subspace) return SubSpaces.SubSpaces[subspace] or {} end

function SubSpaces.GetSubSpaceEntity(subspace)
	local Table = SubSpaces.SubSpaceTab(subspace)
	if not Table then return end
	if SERVER then
		if not Table.Anchor or  Table.Anchor and not IsValid(Entity(Table.Anchor)) then
			local A = ents.Create("sing_anchor")
			A:Spawn()
			Table.Anchor = A:EntIndex()
			SubSpaces:UpdateSubSpace(Table)
		end
	end
	if not Table.Anchor then return end
	--Table.Anchor:SetAngles(Table.Ang)
	return Entity(Table.Anchor)
end
	
if(SERVER)then
	AddCSLuaFile( "vgui/layerlist.lua" )
	AddCSLuaFile( "vgui/layerlist_layer.lua" )
	
	--[[------------------------------------------------------------------------------------------------------------------
		SubSpace management
	------------------------------------------------------------------------------------------------------------------]]--
	function SubSpaces:WorldGenLayer(Name,Vect,Ang,Type)
		if(not SubSpaces.SubSpaces[Name])then
			print("Generating "..Name.." subspace")
			local SubSpace = {}
			
			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, VVel = Vector(), AVel=Angle(), Ang = Ang, Entitys={}, Importance = Type, Bubble={}, Size = 0}
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
	
	--Set Position and angle functions.
	function SubSpaces:SSSetPos(Name,Vect) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.Pos=Vect or SubSpace.Pos end
	function SubSpaces:SSSetAng(Name,Ang) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.Ang=Ang or SubSpace.Ang end	
	
	--Set Velocity functions.
	function SubSpaces:SSSetVVel(Name,Vect) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.VVel=Vect or SubSpace.VVel end
	function SubSpaces:SSSetAVel(Name,Ang) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.AVel=Ang or SubSpace.AVel end	
		
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
	
	concommand.Add( "subspaces_sync", function( ply ) SubSpaces:SyncLayers() end )
	concommand.Add( "subspaces_select", function( ply, com, args )
		if ( ply:IsValid() and SubSpaces.SubSpaces[args[1]] ) then
			ply.SelectedLayer = args[1] 
		end
	end )
	
	-----------------------------------------------------------------------
	/*						SubSpace Functions							 */
	-----------------------------------------------------------------------
	
	function SubSpaces:Compile(subspace) --If this becomes laggy on large ships, slow it down.
		local Table = SubSpaces.SubSpaceTab(subspace)
		if not Table then return end
		local Dist,Rad = 0,0
		for ID, ent in pairs( Table.Entitys ) do
			if IsValid(ent) then
				local D,R = ent:GetPos():DistToSqr( Vector() ), ent:BoundingRadius()
				if D+R > Dist+Rad then
					Dist,Rad = D,R
				end
			end
		end
		Table.Size = math.sqrt(Dist)+Rad
	end
	
	-----------------------------------------------------------------------
	/*						SubSpace Movement							 */
	-----------------------------------------------------------------------
	local PhysMult = 67
	
	function SubSpaces:BubbleLoop(subspace)
		local Bub,CT = subspace.Bubble,CurTime()
		for ID, sub in pairs( SubSpaces.SubSpaces ) do
			if sub ~= subspace and (Bub[sub.ID] or 0)<=CT then
				--local Dist = subspace.Pos:DistToSqr( sub.Pos )
				local mpos,spos = subspace.Pos,sub.Pos
				local Dist,S1,S2 = mpos:Distance(spos),subspace.Size,sub.Size
				--print("Dist: "..Dist.." R: "..S1+S2)				
				if Dist<S1+S2 then
					print("Too Close!")
					local Dir = spos-mpos
					Dir:Normalize()
					if S1 > S2 then
						SubSpaces:SSSetPos(ID,(Dir*(S1+S2))*1.01)
					else
						return (Dir*(S1+S2))*1.01
					end
					return mpos
				else
					--Farther away the longer we can wait to check distance for collisions.
					--Bub[sub.ID]=CT+
				end
			end
		end
	end
	
	Utl:SetupThinkHook("SubSpaceMovement",0.01,0,function() 
		for id, subspace in pairs( SubSpaces.SubSpaces ) do
			local Pos,Ang = subspace.Pos+(subspace.VVel/PhysMult),subspace.Ang+(Angle(subspace.AVel.p/PhysMult,subspace.AVel.y/PhysMult,subspace.AVel.r/PhysMult))
			
			Pos = SubSpaces:BubbleLoop(subspace) or Pos
			
			subspace.Pos,subspace.Ang = Pos,Ang
			local Anc = SubSpaces.GetSubSpaceEntity(id)
			if IsValid(Anc) then Anc:SetSubPos(Pos) Anc:SetSubAng(Ang) end
		end			
	end)
end

LoadFile("singularity/core/subspace/cl_rendering.lua",0)

LoadFile("singularity/core/subspace/sh_entity.lua",1)
LoadFile("singularity/core/subspace/sh_hooks.lua",1)
LoadFile("singularity/core/subspace/sh_mapsize.lua",1)
LoadFile("singularity/core/subspace/sh_netmsgs.lua",1)
LoadFile("singularity/core/subspace/sh_overrides.lua",1)

if SERVER then
	SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(),Angle(),true)
	SubSpaces:WorldGenLayer("NullSpace",Vector(),Angle(),true)
end