local Singularity = Singularity
local SubSpaces = SubSpaces
local Utl = Singularity.Utl --Makes it easier to read the code.

local Data = {
	Name="Ship Console",
	Type="Generic",
	Class="sing_smod",
	MyModel="models/sbep_community/d12console.mdl",
	Wire = {},
	Extra = {},
	Admin = true
}

Data.OnUse = function(self,name,activator,caller)
	--Opens up the drydock interface allowing you to generate a shipspace to work in.
end

Singularity.ShipMods.MakeModule(Data)

if SERVER then
	function OpenShipConsole(Ply,SubSpace)
		--print("syncing "..Name.." subspace")
		local Data = {Name="open_shipconsole",Val=1,Dat={
			{N="T",T="S",V=SubSpace.Title},
			{N="E",T="F",V=SubSpace.Anchor}
		}}
		NDat.AddData(Data,Ply)
	end	
else
	Utl:HookNet("open_shipconsole","",function(D)
		--Open the ship console and fill tabs.
	end)
end

function OpenShipConsoleGui()
	
end

function SubSpaces.OpenDryDockSpace(Ply)
	local DryDockPos = Vector(X,SubSpaces.MapSize,X)
	local ShipSpace = Ply:Nick()
	if SubSpaces.SubSpaceTab(ShipSpace)~={} then --Do they already have a shipspace?
		--Move their ship to the drydock and change its rendering settings.
		SubSpaces:SSSetPos(ShipSpace,DryDockPos) SubSpaces:SSSetVVel(ShipSpace,Vector()) SubSpaces:SSSetAVel(ShipSpace,Angle())
	else 
		--Lets generate a shipspace for the player now and move it to the drydock.
		local X = SubSpaces.MapSize/2
		SubSpaces:WorldGenLayer(ShipSpace,DryDockPos,Angle(),true)
	end
	SubSpaces:UpdateSubSpaceRendering(ShipSpace,true) --Disable rendering on it when your not inside it. (This is so we can stack them.)
end






