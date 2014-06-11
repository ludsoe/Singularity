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
	if SubSpaces.SubSpaces[subspace] then
		return SubSpaces.SubSpaces[subspace].Pos or Vector(0,0,0)
	end
	return Vector(0,0,0)
end

--Gets the angle of the subspace.
function SubSpaces.SubSpaceAng(subspace)
	if SubSpaces.SubSpaces[subspace] then
		return SubSpaces.SubSpaces[subspace].Ang or Angle(0,0,0)
	end
	return Angle(0,0,0)
end

--Returns the table of a subspace.
function SubSpaces.SubSpaceTab(subspace) return SubSpaces.SubSpaces[subspace] or {} end

--Add basic physics to the movement.
Utl:SetupThinkHook("SubSpaceMovement",0.01,0,function() 
	local Mult = 67
	if not SERVER then Mult=1/FrameTime() end
	for id, subspace in pairs( SubSpaces.SubSpaces ) do
		subspace.Pos = subspace.Pos+(subspace.VVel/Mult) --Move the subspace based on its velocity.
		subspace.Ang = subspace.Ang+(Angle(subspace.AVel.p/Mult,subspace.AVel.y/Mult,subspace.AVel.r/Mult)) --Rotate it now.
	end			
end)
	
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

			SubSpace = {ID=Name, Owner = "World", Title = Name , Pos = Vect, VVel = Vector(), AVel=Angle(), Ang = Ang, Entitys={}, Importance = Type}
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
	function SubSpaces:SSSetPos(Name,Vect) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.Pos=Vect or SubSpace.Pos SubSpaces:UpdateSubSpace(SubSpace) end
	function SubSpaces:SSSetAng(Name,Ang) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.Ang=Ang or SubSpace.Ang SubSpaces:UpdateSubSpace(SubSpace) end	
	
	--Set Velocity functions.
	function SubSpaces:SSSetVVel(Name,Vect) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.VVel=Vect or SubSpace.VVel SubSpaces:UpdateSubSpace(SubSpace) end
	function SubSpaces:SSSetAVel(Name,Ang) local SubSpace = SubSpaces.SubSpaces[Name] SubSpace.AVel=Ang or SubSpace.AVel SubSpaces:UpdateSubSpace(SubSpace) end	
		
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
else	
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

LoadFile("singularity/core/subspace/cl_rendering.lua",0)

LoadFile("singularity/core/subspace/sh_entity.lua",1)
LoadFile("singularity/core/subspace/sh_hooks.lua",1)
LoadFile("singularity/core/subspace/sh_mapsize.lua",1)
LoadFile("singularity/core/subspace/sh_netmsgs.lua",1)
LoadFile("singularity/core/subspace/sh_overrides.lua",1)

if SERVER then
	SubSpaces:WorldGenLayer(SubSpaces.MainSpace,Vector(),Angle(),true)
	SubSpaces:WorldGenLayer("NullSpace",Vector(),Angle(),true)
	SubSpaces:SSSetAVel(SubSpaces.MainSpace,Angle(0,5,0))
end