--[[----------------------------------------------------
Cubic Universe System --Creates a larger universe by allowing players to move to differnt sectors.
----------------------------------------------------]]--

--Create ease links to the global table.
local SubSpaces = SubSpaces
local SubKeys = SubSpaces.SubSpaceKeys
local Spaces = SubSpaces.SubSpaces
local Utl = Singularity.Utl --Makes it easier to read the code.

if(SERVER)then
	
	SubSpaces.EntCheck = CurTime()
	
	--This function will makesure a subspace exists before we try flying to it.
	function SubSpaces:BufferTransferEvent(Vect)
		local Key = tostring(Vect)
		if(not SubKeys[Key])then
			SubSpaces:WorldGenLayer(Key,Vect,false)--The System doesnt exist, lets create it.
		end
	end
	
	--Gets the subspace we want from a universe vector.
	function SubSpaces:SubSpaceFromVector(Vect)
		SubSpaces:BufferTransferEvent(Vect)
		return SubKeys[tostring(Vect)].ID
	end
	
	function SubSpaces:TransferSubSpaceEvent(Ent,SubSpace,Direction,Inverted)
		local JumpEnts = constraint.GetAllConstrainedEntities_B( Ent )

		local WarpDrivePos = Ent:GetPos()
		local DoneList = {Ent}
		ConstrainedEnts = ents.FindInSphere( WarpDrivePos , 600)
		for _, v in pairs(ConstrainedEnts) do
			if v:IsValid() and not DoneList[v] then
				ToTele = constraint.GetAllConstrainedEntities_B(v)
				for ent,_ in pairs(ToTele)do
					if ent:IsValid() and not DoneList[ent] then
						DoneList[ent]=ent
					end
				end
			end
		end
		table.Add(JumpEnts,DoneList)
		local Lvecs = {Pos={},Vel={}}
		for i, ent in pairs( JumpEnts ) do
			Lvecs.Pos[i] = Ent:WorldToLocal( ent:GetPos() )
			Lvecs.Vel[i] = Ent:WorldToLocal( ent:GetVelocity() + ent:GetPos() )
			ent:SetVelocity( ent:GetVelocity() * -1 )
		end
		local Velocity=Ent:GetVelocity()
		
		Ent:SetPos(-Ent:GetPos())
		Ent:SetVelocity(Velocity) --Carry the velocity over.
		
		Ent:SetSubSpace(SubSpace)
		
		for i, ent in pairs( JumpEnts ) do
			ent:SetSubSpace(SubSpace)
			if(not ent:GetParent():IsValid())then
				ent:SetPos(Ent:LocalToWorld(Lvecs.Pos[i]))
				-- Set new velocity
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocity( Ent:LocalToWorld( Lvecs.Vel[i] ) - ent:GetPos() )
					phys:Wake()
				else
					ent:SetVelocity( Ent:LocalToWorld( Lvecs.Vel[i] ) )
				end
			end
		end
	end
	
	local function sign(Num)
		if(Num>0)then 
			return 1
		elseif(Num<0)then
			return -1
		else
			return 0
		end
	end
	
	function SubSpaces:BeginTransferEvent(Ent,Direction)
		local mbs=math.abs
		local D=Direction
		local Dir = Vector(0,0,0)
		local Inv = Vector(1,1,1)
		if(mbs(D.X)>mbs(D.Y) and mbs(D.X)>mbs(D.Z))then
			Dir=Vector(sign(D.X),0,0)
			Inv=Vector(-1,1,1)
		elseif(mbs(D.Y)>mbs(D.X) and mbs(D.Y)>mbs(D.Z))then
			Dir=Vector(0,sign(D.Y),0)
			Inv=Vector(1,-1,1)
		else
			Dir=Vector(0,0,sign(D.Z))
			Inv=Vector(1,1,-1)
		end
		
		local UniPos=Spaces[Ent:GetSubSpace()].Pos --Where are we.....
		local SubSpace = SubSpaces:SubSpaceFromVector(UniPos+Dir) --Gets the subspace were moving to.
		
		SubSpaces:TransferSubSpaceEvent(Ent,SubSpace,Dir,Inv) --Lets actually move now.
	end
	
	function SubSpaces:WarpImmune(ent)
		local Blocked = {"dynamic","phygun_beam","predicted_viewmodel","func","func_physbox","info_","point_","path_","node","Environment","environment","env_","star"}
		local Always = {"resource","storage","asteroid","generator","lde","lifesupport","environments","dispenser","weapon","probe","lscore","factory","pump","health","trade"}
		if(not ent:IsValid())then return true end
		local str = ent:GetClass()
		for _,b in pairs(Blocked) do
			if(string.find(str,b))then
				for _,v in pairs(Always) do
					if(string.find(str,v))then
						return false
					end
				end
				return true
			end
		end
		return false
	end

	--The magical think that will manage transitions.
	local Func = function()
		local mbs=math.abs
		for _, ent in ipairs( ents.GetAll() ) do
			if(Utl:CheckValid(ent) and not SubSpaces:WarpImmune( ent ) and not ent:GetParent():IsValid())then
				if(not ent.LastChecked or ent.LastChecked<CurTime())then --Makesure we didnt check this entity already
					if(not ent:IsValid() or not ent)then continue end
					
					--Tell the entity we already checked it.
					if(ent:IsConstrained())then
						local Conts = constraint.GetAllWeldedEntities( ent )
						for id, ent in pairs( Conts ) do
							if(ent and ent:IsValid())then
								ent.LastChecked=CurTime()+0.2
							end
						end
					end
					
					local Dir = ent:GetPos()+(ent:GetVelocity()*2)
					local Size = SubSpaces.MapSize
					if(mbs(Dir.X)>Size or mbs(Dir.Y)>Size or mbs(Dir.Z)>Size)then
						SubSpaces:BeginTransferEvent(ent,Dir)--Time to teleport! Hold on tight.
					end
				end
			end
		end
	end
	Utl:SetupThinkHook("EntityScans",0.1,0,Func)
else

end