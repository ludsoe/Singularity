local Singularity = Singularity
local SubSpaces = SubSpaces
local LoadFile = Singularity.LoadFile --Lel Speed.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Name="Teleporter Platform",
	Type="Generic",
	Class="sing_smod",
	MyModel="models/props_junk/sawblade001a.mdl",
	Wire = {},
	Extra = {}
}

--Lets insert ourselfs into the cores teleporter list!
Data.Install = function(self,Core)
	table.insert(Core.Teleports,self)
end

Singularity.ShipMods.MakeModule(Data)



