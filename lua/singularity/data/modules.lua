local Singularity = Singularity --MAH SPEED
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.ShipMods = {}
Singularity.ShipMods.Modules = {}

local ShipMods = Singularity.ShipMods

function ShipMods.RegisterModule(Name,Type,Data,Base)
	if not ShipMods.Modules[Type] then
		ShipMods.Modules[Type]={}
	end
	
	ShipMods.Modules[Type][Name]={M=Data,E=Base}
end

function ShipMods.CompileSetting(Name,Default)
	local Data = {
		ID = Name,
		Type = type(Default),
		Value = Default
	}
	return Data
end

function ShipMods.GenerateInfo(Data)
	if Data.Info ~= {} then return Data.Info end
	local Info = {}
	
	return Info
end

function ShipMods.MakeModule(Data)
	local Name = Data.Name
	local Type = Data.Type or "Generic"
	local Info = ShipMods.GenerateInfo(Data)
	local Mod = {N=Name,T=Type,E=Data.Class,M=Data.Model,Sets={},Info=Info or {},Mods=Data.Extra or {}}
	if Data.Propertys then
		for k,v in pairs(Data.Propertys) do
			Mod.Sets[v.Name]=ShipMods.CompileSetting(v.Name,v.Value)
		end
	end
	ShipMods.RegisterModule(Name,Type,Mod,Data)
	print("Registered: "..Name.." as a "..Type)
end

--Ship Modules.
local ModPath = "singularity/data/shipmodules/"
--LoadFile("lss/addon/shipcores/modules/lifesupport.lua",1)
LoadFile(ModPath.."drydockconsole.lua",1)
LoadFile(ModPath.."reactor.lua",1)
LoadFile(ModPath.."teleportconsole.lua",1)
















