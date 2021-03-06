AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
 
function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("sing_anchor")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	return ent

end

function ENT:Initialize()	
	self:SetModel("models/hunter/plates/plate1x1.mdl")	
	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetMoveType( MOVETYPE_NONE )
	--self:SetSolid( SOLID_NONE )
	self:DrawShadow(false)
	
	self:SetNotSolid( true )	
end
 
function ENT:ShipCoreInit()
    self.Modules,self.ModThink = {},{}
		
	self.SyncData = {Reactor=0,MaxSpeed=200,MaxTurnSpeed=40}
	self.OldData,self.Teleports = {},{}
	
	local Cur = CurTime()
    self.Next = {Scan=Cur,Trans=Cur} 	
	
	self.LastAttacked = 0
	self.MassCenter = Vector(0,0,0)
end

function ENT:Think()
	if self.IsDead or not self.Compiled then return end --We DEAD!

	if self.Next.Trans<CurTime() then
		self:TransmitData()
		self.Next.Trans = CurTime()+0.2	  
	end
	
	self.SyncData.Reactor = 0
	for id, mod in pairs( self.ModThink ) do
		local Ent = mod.E
		if IsValid(Ent) then
			if Ent.ModuleThink then
				if (Ent.NextModThink or 0) < CurTime() then
					if Ent:ModuleThink(self) then
						Ent.NextModThink = CurTime() + Ent.ThinkSpeed
					end
				end
			end
		else
			self.ModThink[id]=nil
		end
	end
end

function ENT:UsePower(Need) return self.SyncData.Reactor >= Need end
function ENT:GenPower(Amt) self.SyncData.Reactor = self.SyncData.Reactor+(Amt or 0) end

function ENT:EngineVVel(Vec)
	local Vel = self.SubSpaceDat.VVel
	if (Vel+Vec):Length()<self.SyncData.MaxSpeed then
		SubSpaces:SSSetVVel(self.SubSpaceNam,Vel+Vec)
	end
end

function ENT:EngineAVel(Ang)
	local AngV = self.SubSpaceDat.AVel
	if (Vector(AngV.p,AngV.y,AngV.r)+Vector(Ang.p,Ang.y,Ang.r)):Length()<self.SyncData.MaxTurnSpeed then
		SubSpaces:SSSetAVel(self.SubSpaceNam,AngV+Ang)
	end
end

function ENT:ScanModules()
	local Props = self.SubSpaceDat.Entitys
	
	for n, ent in pairs( Props ) do
		if ent.IsModule then
			local ID = ent:EntIndex()
			if not IsValid(self.Modules[ID]) then
				ent:ModuleInstall(self)
				self.Modules[ID] = ent
				table.insert(self.ModThink,{E=ent,I=ID,P=ent:GetPriority()})
			end
		end
	end
	
	if table.Count(self.ModThink)>1 then
		table.sort(self.ModThink, function(a, b) return a.P > b.P end)
	end
end

function ENT:TransmitData()
	local Data = table.Copy(self.SyncData) --Create a copy of the sync data table so we dont mess with the real one.
	local Transmit = {}

	for n, v in pairs( self.OldData ) do --Update our existing data first.
		if v.V ~= Data[n] then --If Data doesnt match
			self.OldData[n] = {V=Data[n],C=true} --Set it to the new value and mark as changed.
			Transmit[n] = Data[n]
		else
			v.C = false --Mark It unchanged.
		end
		Data[n]=nil --Remove pre parsed data to make the next part faster.
	end
	
	for n, v in pairs( Data ) do --Lets mark down the new data.
		self.OldData[n] = {V=v,C=true} --Tell the data its got to be sent.
		Transmit[n] = v
	end
		
	local Data = {Name="SingularityCoreSync",Val=5,Dat={
		{N="E",T="E",V=self},
		{N="T",T="T",V=Transmit}
	}}
	Singularity.Utl.NetMan.AddDataAll(Data)
end

function ENT:TransmitAllData(Ply)
	local Transmit = {}
	
	if self.OldData == {} then return end
	
	for n, v in pairs( self.OldData ) do --Lets mark down the new data.
		Transmit[n] = v.V
	end
	
	local Data = {Name="SingularityCoreSync",Dat={
		{N="E",T="E",V=self},
		{N="T",T="T",V=Transmit}
	}}
	NDat.AddData(Data,Ply)
end

function ENT:CanTool()
	return false
end
 
function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
