local Singularity = Singularity
local SubSpaces = SubSpaces
local LoadFile = Singularity.LoadFile --Lel Speed.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

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
	OpenShipConsole(activator)
end

Singularity.ShipMods.MakeModule(Data)

if SERVER then
	function OpenShipConsole(Ply)
		--print("syncing "..Name.." subspace")
		local Data = {Name="open_shipconsole",Val=1,Dat={
			{N="DryDock",T="B",V=true}
		}}
		NDat.AddData(Data,Ply)
	end	
end

function SubSpaces.OpenDryDockSpace(Ply)
	local X = SubSpaces.MapSize/2
	local DryDockPos = Vector(X,SubSpaces.MapSize,-X/2)
	local ShipSpace = Ply:Nick()
	if SubSpaces.SubSpaceTab(ShipSpace).ID then --Do they already have a shipspace?
		print("Ship Already Exists.")
		--Move their ship to the drydock and change its rendering settings.
		SubSpaces:SSSetPos(ShipSpace,DryDockPos) SubSpaces:SSSetVVel(ShipSpace,Vector()) SubSpaces:SSSetAVel(ShipSpace,Angle())
		local Anchor = SubSpaces.GetSubSpaceEntity(ShipSpace) Anchor.Compiled = false
	else 
		--Lets generate a shipspace for the player now and move it to the drydock.
		SubSpaces:WorldGenLayer(ShipSpace,DryDockPos,Angle(),true)
	end
	SubSpaces:UpdateSubSpaceRendering(ShipSpace,true) --Disable rendering on it when your not inside it. (This is so we can stack them.)
	
	Ply:SetSubSpace(ShipSpace)
	Ply:SetPos(Vector(0,0,0)) --Should be the center of thier ship.
	Ply:SetMoveType( MOVETYPE_NOCLIP ) --Ply:SetMoveType( MOVETYPE_WALK )
	--Add in giving of toolgun/physgun
end

LoadFile("singularity/data/userinterfaces/shipconsole.lua",1)





