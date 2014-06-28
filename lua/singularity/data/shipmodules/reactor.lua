local Data = {
	Type="Reactors",
	Class="sing_smod",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.WorldTip = {Capacity="ReactorCapacity"}

Data.Setup = function(self,Data,MyData)
	self.IsReactor = true
	self.Capacity = MyData.Extra.Capacity
end

Data.ThinkSpeed = 0
Data.Think = function(self,Core)
	Core:GenPower(self.Capacity)
	return true
end

function Singularity.ShipMods.RegisterReactor(New,Data)
	Data.Extra.Capacity = New.Cap
	Data.Info["Reactor Capacity"] = New.Cap
	
	Data.Name = New.Name or "Reactor"
	Data.MyModel = New.MyModel
	
	Singularity.ShipMods.MakeModule(table.Copy(Data))
end

local RCT = {Name="Generic Reactor",Energy=500,MyModel="models/cerus/modbridge/misc/ls/ls_gen11a.mdl"}
Singularity.ShipMods.RegisterReactor(RCT,Data)








