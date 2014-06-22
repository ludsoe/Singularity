local Data = {
	Name="Teleport Console",
	Type="Generic",
	Class="sing_smod",
	MyModel="models/sbep_community/d12console.mdl",
	Wire = {},
	Extra = {}
}

Data.OnUse = function(self,name,activator,caller)
	--Opens up a interface to teleport between nearby shipspaces.
end

Singularity.ShipMods.MakeModule(Data)
