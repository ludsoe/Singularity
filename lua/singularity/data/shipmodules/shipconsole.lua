local Singularity,SubSpaces = Singularity,SubSpaces
local LoadFile = Singularity.LoadFile --Lel Speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Pers,PB = Singularity.Persistance,Singularity.PreBuilt --Localise the persistance table for speed.

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
	local DryDockPos = Vector(-X,SubSpaces.MapSize,-X/2)
	local ShipSpace = Ply:Nick()
	if SubSpaces.SubSpaceTab(ShipSpace).ID then --Do they already have a shipspace?
		--Move their ship to the drydock and change its rendering settings.
		SubSpaces:SSSetPos(ShipSpace,DryDockPos) SubSpaces:SSSetVVel(ShipSpace,Vector()) SubSpaces:SSSetAng(ShipSpace,Angle()) SubSpaces:SSSetAVel(ShipSpace,Angle())
		local Anchor = SubSpaces.GetSubSpaceEntity(ShipSpace) Anchor.Compiled = false
	else 
		--Lets generate a shipspace for the player now and move it to the drydock.
		SubSpaces:WorldGenLayer(ShipSpace,DryDockPos,Angle(),true)
		Pers:LoadFromData(Vector(0,0,0),PB["shalefrieghter"],true,ShipSpace,Ply)
	end
	SubSpaces:SubspaceDryDockMode(ShipSpace,true) --Disable rendering on it when your not inside it. (This is so we can stack them.)
	
	Ply:SetSubSpace(ShipSpace)
	Ply:SetPos(Vector(0,0,0)) --Should be the center of thier ship.
	Ply:SetMoveType( MOVETYPE_NOCLIP ) --Ply:SetMoveType( MOVETYPE_WALK )
	--Add in giving of toolgun/physgun
end

local function GetRand(A) 
	local T,I = Utl:TableRand(A.Teleports)
	if IsValid(T) then
		return T
	else
		table.remove(A.Teleports,I)
		return GetRand(A)
	end
end

--Add support to detect other missing components such as reactors/engines
function SubSpaces.CompileShip(Ply)
	local ShipSpace = Ply:Nick()
	if SubSpaces.SubSpaceTab(ShipSpace).ID and Ply:GetSubSpace() == ShipSpace then
		SubSpaces:Compile(ShipSpace)
		local Anchor = SubSpaces.GetSubSpaceEntity(ShipSpace)
		Anchor:ShipCoreInit() Anchor:ScanModules()
		if table.Count(Anchor.Teleports)>0 then
			local Tele = GetRand(Anchor)
			Ply:SetPos(Tele:GetPos()+Vector(0,0,10))
			Ply:SetMoveType( MOVETYPE_WALK )
			
			SubSpaces:SSSetPos(ShipSpace,DryDockPos)
			SubSpaces:SubspaceDryDockMode(ShipSpace,false)
			Anchor.Compiled = true
		else
			--Inform the player they do not have teleport pads.
			print("No TelePads")
		end
	else
		--Inform the player they cant compile ships they dont own.
		print("You Dont Own this subspace.")
	end
end

LoadFile("singularity/data/userinterfaces/shipconsole.lua",1)





