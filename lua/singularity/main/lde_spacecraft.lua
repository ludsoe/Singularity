
Singularity.SpaceCraft = {}

function Singularity.SpaceCraft.SpaceCThink(self)

end

function Singularity.SpaceCraft.HandleWing(self,WingAngle)
	if(self and self:IsValid())then
		self:SetLocalAngles(WingAngle)
	end
end

function Singularity.SpaceCraft.CreateWing(self,Body,Model,Pos,Angles)
	local Wing = ents.Create( "prop_physics" )
	Wing:SetModel( Model ) 
	Wing:SetPos( Body:GetPos()+Pos )
	Wing:Spawn()
	Wing:Activate()
	Wing:SetParent(Body)
	Wing:SetLocalPos(Pos)
	Wing:SetLocalAngles(Angles)
	Wing:SetSolid( 0 )
	Wing.IsSpaceCraft = true
	table.insert(self.Parts,Wing)
	
	local phys = Wing:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass( 1 )
	end
	
	return Wing
end

//Base Code for ships.
function Singularity.SpaceCraft.MakeSpaceC(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = Data.name
	ENT.Spawnable			= true
	ENT.AdminSpawnable		= true
	ENT.Category = "Singularity"
	ENT.Data = Data

	if SERVER then

		function ENT:Initialize()   

			self:SetModel( "models/props_junk/PopCan01a.mdl" ) 
			self:SetName(Data.name)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( 0 )
			
			local phys = self:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(false)
				phys:SetMass(1)
			end
			self:SetKeyValue("rendercolor", "255 255 255")
			self.PhysObj = self:GetPhysicsObject()
			
			self.Parts = {}
			
			self.SingMove = {
			Turn={Roll=0,Pitch=0,Yaw=0},
			DTurn={Roll=0,Pitch=0,Yaw=0},
			DFwd=0,Fwd=0,DThrust=0,Thrust=0,
			DVThrust=0,VThrust=0,TMul=0,
			AMul=0,Strafe=0,Strafe=0
			}

			local SpawnPos = self:GetPos()
			
			
			Body = ents.Create( "prop_vehicle_prisoner_pod" )
			Body:SetModel( self.Data.model ) 
			Body:SetPos( self:GetPos() + self:GetForward() * 150 + self:GetUp() * -50 )
			Body:SetAngles(self:GetAngles())
			Body:Spawn()
			Body:Activate()
			Body:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
			Body:SetKeyValue("limitview", 0)
			local TB = Body:GetTable()
				TB.HandleAnimation = function (vec, ply)
				return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
			end 
			Body:SetLocalPos(Vector(-55,0,38))
			Body:SetLocalAngles(Angle(0,0,0))
			Body.Singularity = {Core=self}
			Body.IsSpaceCraft = true
			self.Body = Body
			table.insert(self.Parts,Body)
			self:SetParent(Body)
			local Weld = constraint.Weld(self,Body)
			
			local phys = Body:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(true)
				phys:SetMass( 1000 )
			end

			self:SetNetworkedEntity("Pod",self.Body,true)			
			
			self.Data.Setup(self,Body)
		end
		
		function ENT:Think()
			--self.Entity:SetColor( 0, 0, 255, 255)
			local Phys = self.Body:GetPhysicsObject()

			if self.Body and self.Body:IsValid() then
				
				self.CPL = self.Body:GetPassenger(1)
				if self.CPL and self.CPL:IsValid() then
					self.AMul = 1
					self.Active = true

					self.Data.flythink(self)--Call the fly think function inside our data class
				else
					self.SingMove.DThrust = 0
					self.SingMove.DTurn.Pitch = 0
					self.SingMove.DTurn.Roll = 0
					self.SingMove.DTurn.Yaw = 0
					self.SingMove.DFwd = 0
					self.SingMove.AMul = 0
					self.OPAng = nil
					self.Active = false
					self.CPLsuitcheck = true
				end
			else
				
				self:Remove()
			end
				
			
			local TSpeed = 1
			if self.SingMove.Thrust > self.SingMove.DThrust then
				TSpeed = 50
			end
			--self.VThrust = math.Approach(self.VThrust, self.DVThrust * self.TMul, VTSpeed)
			--self.Strafe = math.Approach(self.Strafe, self.DStrafe, 1.5)

			--This is where we do the speed up and slow down logic.
			self.SingMove.Thrust = math.Approach(self.SingMove.Thrust, self.SingMove.DThrust * self.SingMove.TMul, TSpeed)
			self.SingMove.Turn.Pitch = math.Approach(self.SingMove.Turn.Pitch, self.SingMove.DTurn.Pitch, 2)
			self.SingMove.Turn.Yaw = math.Approach(self.SingMove.Turn.Yaw, self.SingMove.DTurn.Yaw, 2)
			self.SingMove.Turn.Roll = math.Approach(self.SingMove.Turn.Roll, self.SingMove.DTurn.Roll, 2)
			self.SingMove.Fwd = math.Approach(self.SingMove.Fwd, self.SingMove.DFwd, 2)		
			
			local RAng = {} RAng.r,RAng.y,RAng.p = self.SingMove.Turn.Yaw * 0.2,self.SingMove.Turn.Pitch * 0.2,self.SingMove.Turn.Roll * 0.2
			--Had to convert a angle into a vector.
			
			if Phys:IsValid() then
				if self.Active then
					if Phys and Phys:IsValid() then
						Phys:EnableGravity(false)
					end
					Phys:SetVelocity(Phys:GetVelocity() * .96)
					if self.Data.EngineCheck(self) then
						Phys:ApplyForceCenter(self.Body:GetRight() * (self.SingMove.Thrust * Phys:GetMass()) )
						Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.1) + Vector(RAng.p,RAng.y,RAng.r))
					end
				else
					if Phys and Phys:IsValid() then
						Phys:EnableGravity(true)
					end
				end
			end
			
			self:NextThink( CurTime() + 0.01 )
			return true	
		end
		
		function ENT:OnRemove()
			if self.Body and self.Body:IsValid() then
				self.Body:Remove()
			end
		end

	else
		ENT.RenderGroup = RENDERGROUP_OPAQUE

		--Client stuff ;)
	end
	scripted_ents.Register(ENT, Data.class.."_spacecraft", true, false)
	print("SpaceShip Class Registered: "..Data.class)
end


local SetupFunc = function(self,Body)
	self.LWing = Singularity.SpaceCraft.CreateWing(self,Body,"models/props_junk/PopCan01a.mdl",Vector(-100,50,27),Angle(0,0,0))
	self.RWing = Singularity.SpaceCraft.CreateWing(self,Body,"models/props_junk/PopCan01a.mdl",Vector(-100,-50,27),Angle(0,0,0))
	self.LWingE = Singularity.SpaceCraft.CreateWing(self,Body,"models/Slyfo/arwing_engineleft.mdl",Vector(-100,100,-54),Angle(0,0,0))
	self.RWingE = Singularity.SpaceCraft.CreateWing(self,Body,"models/Slyfo/arwing_engineright.mdl",Vector(-100,-100,-54),Angle(0,0,0))
end

local FlyThink = function(self)
	if self.CPL:KeyDown( IN_MOVELEFT ) then
		self.SingMove.DTurn.Roll = -30
	elseif self.CPL:KeyDown( IN_MOVERIGHT ) then
		self.SingMove.DTurn.Roll = 30
	else
		self.SingMove.DTurn.Roll = 0
	end
	
	if self.Alt then
		self.SingMove.DStrafe = 90
	else
		self.SingMove.DStrafe = 0
	end
	
	if self.CPL:KeyDown( IN_BACK ) then
		self.SingMove.DThrust = -10 ---math.Clamp(self:GetUp():DotProduct( Phys:GetVelocity() ) , -5 , -1.2 ) * -4
	elseif self.CPL:KeyDown( IN_FORWARD ) then
		self.SingMove.DThrust = 60
	else
		self.SingMove.DThrust = 0
	end
	
	if self.CPL:KeyDown( IN_JUMP ) then
		self.SingMove.TMul = 0.1
		if self.SingMove.Thrust < 0 then
			self.SingMove.TMul = 1
		end
		self.SingMove.DFwd = -90
	else
		self.SingMove.TMul = 1
		self.SingMove.DFwd = 0
	end

	if self.OPAng then
	--	self.CPL:SetEyeAngles(self:WorldToLocalAngles(self.OPAng):Forward():Angle())
	else
		self.OPAng = self.CPL:EyeAngles()
	end

	if self.CPL:KeyDown( IN_SPEED ) then
		self.SingMove.DTurn.Pitch = 0
		self.SingMove.DTurn.Yaw = 0
	else
		local AAng = self.Body:WorldToLocalAngles(self.CPL:EyeAngles())
		self.SingMove.DTurn.Pitch = AAng.p
		self.SingMove.DTurn.Yaw = (AAng.y)
	end
end

local enginecheck = function(self)
	if(self.RWingE and self.RWingE:IsValid() and self.LWingE and self.LWingE:IsValid())then
		return true
	else
		return false
	end
end

local Stats = {}
local Data = {name="Arwing",class="ship_arwing",model="models/Slyfo/arwing_body.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
Singularity.SpaceCraft.MakeSpaceC(Data)

local SetupFunc = function(self) end
local enginecheck = function(self) return true end
local Stats = {}
local Data = {name="Sword",class="ship_sword",model="models/Slyfo/sword.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
Singularity.SpaceCraft.MakeSpaceC(Data)

local SetupFunc = function(self) end
local enginecheck = function(self) return true end
local Stats = {}
local Data = {name="StingRay",class="ship_stingray",model="models/Cerus/Fighters/stingray.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
Singularity.SpaceCraft.MakeSpaceC(Data)
