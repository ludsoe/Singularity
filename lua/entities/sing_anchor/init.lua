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
    self.Modules,self.Modifiers,self.PropHealth = {},{},{}
		
	self.SyncData = {BandWidth=0,MaxBandWidth=0,Hull=1,MaxHull=1,Shields=0,MaxShields=0,Reactor=0,MaxReactor=1}
	self.OldData = {}
	
	local Cur = CurTime()
    self.Next = {Scan=Cur,Trans=Cur,Shld=Cur} 	
	
	self.LastAttacked = 0
	self.MassCenter = self:WorldToLocal(phy:GetMassCenter())
	self.Compiled = true
end
 
function ENT:Think()
	if self.IsDead or not self.Compiled then return end --We DEAD!
	local SDat,PHeal = self.SyncData,self.PropHealth

    if self.Next.Scan<CurTime() then
		--self:ScanProps() --Have the core loop its subspace and install any new props/modules.
        self.Next.Scan = CurTime()+2
    end
	
	/*
	if self.Next.Shld<CurTime() then
		if not self.Modifiers.Shields or not IsValid(self.Modifiers.Shields) then
			SDat.MaxShield = 0
			if SDat.Shields > 200 then
				SDat.Shields = SDat.Shields-(SDat.Shields*0.1)
			else
				SDat.Shields = 0
			end
		end
		self.Next.Shld = CurTime()+0.1
	end
	
	SDat.BandWidth = 0
	for id, mod in pairs( self.Modules ) do
		if mod and mod:IsValid() and Singularity.ValidCoreLink(mod) then
			if mod.ModuleThink then
				local Cost = (mod.ModuleCost or 0)
				if SDat.BandWidth+Cost<=SDat.MaxBandWidth then
					SDat.BandWidth = SDat.BandWidth+Cost
					if (mod.NextModThink or 0) < CurTime() then
						if mod:ModuleThink(self) then
							mod.NextModThink = CurTime() + mod.ThinkSpeed
						end
					end
				end
			end
		else
			self.Modules[id]=nil
		end
	end
	*/
	
	if self.Next.Trans<CurTime() then
		self:TransmitData()
		self.Next.Trans = CurTime()+0.2	  
		SDat.Reactor = 0		
	end
end

function ENT:OnDamage(ent,position,amount,attacker,inflictor)
	if self.IsDead then return end
	self.LastAttacked = CurTime()
	
end

function ENT:OnKilled()
	if self.IsDead then return end self.IsDead = true --Dont kill me more then once >:(
	
	--Add death explosion effect, set all props to "dead/deconstructed". --Teleport to drydock?
	--Send Player to nearest drydock.
end

util.AddNetworkString('JupiterCoreSync')
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
	
	local Data = util.TableToJSON(Transmit) or ""
	net.Start('JupiterCoreSync')
		net.WriteEntity(self)
		net.WriteString(Data)
	net.Broadcast()
end

function ENT:TransmitAllData(Ply)
	local Transmit = {}
	
	if self.OldData == {} then return end
	
	for n, v in pairs( self.OldData ) do --Lets mark down the new data.
		Transmit[n] = v.V
	end
	
	local Data = util.TableToJSON(Transmit) or ""
	net.Start('JupiterCoreSync')
		net.WriteEntity(self)
		net.WriteString(Data)
	net.Send(Ply)
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
