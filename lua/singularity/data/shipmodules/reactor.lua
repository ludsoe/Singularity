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
	self:SetNWFloat("ReactorCapacity", self.Capacity)
end

Data.ThinkSpeed = 0
Data.Think = function(self,Core)
	local Dat = Core.SyncData
	Dat.Reactor = Dat.Reactor+Power
	
	return true
end

function Singularity.ShipMods.RegisterReactor(New,Data)
	Data.Extra.Capacity = New.Cap
	Data.Info["Reactor Capacity"] = New.Cap
	
	Data.Name = New.Name or "Reactor"
	Data.Model = New.Model
	
	Singularity.ShipMods.MakeModule(table.Copy(Data))
end

local RCT = {Name="Generic Reactor",Cap=1500,Model="models/props_wasteland/laundry_washer003.mdl"}
Singularity.ShipMods.RegisterReactor(RCT,Data)








