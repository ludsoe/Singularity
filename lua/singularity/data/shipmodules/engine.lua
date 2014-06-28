local Data = {
	Name="Engine Core",
	MyModel="models/spacebuild/nova/drone2.mdl",
	Type="Engines",
	Class="sing_smod",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Setup = function(self,Data,MyData)
	self.Forces = {L=0,R=0,U=0,D=0,F=0,B=0,PU=0,PD=0,YR=0,YL=0,RR=0,RL=0}
	self.Dampeners = true
end

Data.Install = function(self,Core)
	Core.EngineCore = self
end

local WF = {}
WF["Move Left"]="L"
WF["Move Right"]="R"
WF["Move Forward"]="F"
WF["Move BackWard"]="B"
WF["Move Up"]="U"
WF["Move Down"]="D"

WF["Yaw Left"]="YL"
WF["Yaw Right"]="YR"
WF["Roll Left"]="RL"
WF["Roll Right"]="RR"
WF["Pitch Up"]="PU"
WF["Pitch Down"]="PD"

Data.Wire.Func = function(self,iname,value)
	if WF[iname] then
		self.Forces[WF[iname]]=value
	else
		if iname == "Disable Dampeners" then
			self.Dampeners = value>0
		end
	end
end
Data.Wire.In = {ID={"Move Left","Move Right","Move Forward","Move Backward","Move Up","Move Down","Yaw Left","Yaw Right","Pitch Up","Pitch Down","Roll Left","Roll Right","Disable Dampeners"}}

Data.ThinkSpeed = 0.1
Data.Think = function(self,Core)
	local F,Dat=self.Forces,Core.SubSpaceDat
	
	if self.Dampeners then
		Core:EngineVVel(Dat.VVel*-0.1)
		Core:EngineAVel(Dat.AVel*-0.1)
	end
	
	local Vec = (self:GetForward()*(F.F-F.B))+(self:GetRight()*(F.R-F.L))+(self:GetUp()*(F.U-F.D))
	Vec:Rotate(Dat.Ang)
	Core:EngineVVel(Vec)
	
	local Ang = Angle(F.PD-F.PU,F.YR-F.YL,F.RR-F.RL)
	Core:EngineAVel(Ang)
	return true
end

Singularity.ShipMods.MakeModule(Data)



