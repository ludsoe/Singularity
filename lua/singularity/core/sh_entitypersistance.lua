--[[----------------------------------------------------
Singularity Entity Persistance -Adds the persistance part of the mod.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
Singularity.Persistance = {} --Make our table.

local Pers = Singularity.Persistance --Localise the persistance table for speed.

if(SERVER)then
	
	--Returns a entitys persistance data.
	function Pers:GetEntityData(C,Ent,Props)
		local Data = {E={}}
		
		Data.M=Ent:GetModel()
		
		local Class = Ent:GetClass()
		if Class~="prop_physics" then Data.T = Class end
		
		Data.V=C:WorldToLocal(Ent:GetPos())
		Data.A=C:WorldToLocalAngles(Ent:GetAngles())
		
		local Skin = Ent:GetSkin()
		if Skin~=1 then Data.S=Skin end
		
		local Col = Ent:GetColor()
		if Col~=Color(255,255,255,255) then Data.C=Col end
		
		local Par = Ent:GetParent()
		if Par:IsValid() then Data.P=Par:EntIndex() end
		
		--Get entity persistant data.
		if Ent.GetPersData then Data.E=Ent:GetPersData() end
		
		if Ent.PreEntityCopy then
			Ent:PreEntityCopy()
			Data.W=Ent.EntityMods
		end
		
		Props[Ent:EntIndex()]=Data
	end
	
	--Gets the extra data from a constraint
	function Pers:GetConsExtra(T,c)
		local E={}
		if T=="Rope" then E={w=c.width,l=c.length,m=c.material,P1=c.LPos1,P2=c.LPos2} end
		return E
	end
	
	--Gets all the constraints of a entity.
	function Pers:GetConstraints(Ent,Welds)
		local cons = constraint.GetTable( Ent )
		
		for _, c in pairs( cons ) do
			local T = c.Type
			local E = Pers:GetConsExtra(T,c)
			if(c.Identity and c~="")then --Makesure the constraint is valid.
				Welds[c.Identity]={T=T,f=c.forcelimit,E1=c.Ent1:EntIndex(),E2=c.Ent2:EntIndex(),E=E}
			end
		end
	end
	
	--Gets a entire contraptions save data.
	function Pers:GetShipData(Ent) 
		local ShipData = {Welds={},Props={},Meta={}}
		local Ents = constraint.GetAllConstrainedEntities( Ent )
		local Welds,Props = {},{}
		
		for _, ent in pairs( Ents ) do
			Pers:GetEntityData(Ent,ent,Props)
			Pers:GetConstraints(ent,Welds)
		end
		
		ShipData.Welds=Welds
		ShipData.Props=Props

		return ShipData
	end
	
	function Pers:LoadConstraint(D,E)
		local T=D.T
		local K1,K2 = D.E1,D.E2

		if(T=="Weld")then
			constraint.Weld( E[K1], E[K2], 0, 0, D.f,true)
		elseif(T=="Rope")then
			constraint.Rope( E[K1], E[K2], 1, 1, D.E.P1, D.E.P2, D.E.l, 0, D.f, D.E.w, D.E.m, false)
		end
	end
	
	--Loads a contraption from entity data. And makes it static.
	function Pers:LoadFromData(Vect,Data,World,SubSpace,Owner)
		if not Data then print("Error No data!") return end
		local W,P,M,E,L = Data.Welds,Data.Props,Data.Meta,{},{}
		
		for ID, PD in pairs( P ) do
			local ent = ents.Create(PD.T or "prop_physics")
			E[ID]=ent
			ent:SetModel(PD.M)
			ent:SetPos(Vect+PD.V)
			ent:SetAngles(PD.A)
			ent:SetColor(PD.C or Color(255,255,255,255))
			ent:SetSkin(PD.S or 1)
			ent:SetSubSpace(SubSpace)
			ent.UnTouchable = not World
			
			if PD.P and PD.P~=0 then
				L[ID]=function()
					ent:SetParent(E[PD.P])
				end
			end
			
			--Get entity persistant data.
			if ent.SetPersData then ent:SetPersData(PD.E) end		
			if PD.W then ent.EntityMods=PD.W end
			
			if IsValid(Owner) then
				Singularity.GivePlyProp(Owner,ent)
			end
			
			ent:Spawn()
			
			local Phys = ent:GetPhysicsObject()
			if Phys:IsValid() then
				Phys:EnableMotion(false)
			end
			ent:SetMoveType( MOVETYPE_NONE )
		end
		
		--Make the constraints
		for _, w in pairs( W ) do Pers:LoadConstraint(w,E) end
		
		--Run any entity predupefinish functions
		for _, f in pairs( L ) do f() end
		
		--Intialize all the entitys at the same time.
		for _, ent in pairs( E ) do
			if ent.EntityMods then ent:PostEntityPaste(Owner,ent,E) end
		end
		
		return E --Return the completed ship.
	end
	
else

end		


