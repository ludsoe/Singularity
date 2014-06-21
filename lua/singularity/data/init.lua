local Singularity = Singularity --Localise the global table for speed.
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.PreBuilt = {}

local PB = Singularity.PreBuilt

function SubSpaces:MakePreBuilt(Name,Data)
	print("Making Prebuilt "..Name)
	local Tab = util.JSONToTable(Data)
	print("Length: "..string.len( Data ))
	--PrintTable(Tab)
	PB[Name]=Tab
	print("T: "..table.Count(PB))
end

function SubSpaces:LoadData()
	print("Loading Data!")
	local Folder = "singularity/data/prebuilt/"
	for k,v in pairs(file.Find(Folder .. "*.lua","LUA")) do
		local f = string.StripExtension( v )
		if(f~="init")then
			local Data = file.Read(Folder .. v,"LUA")
			SubSpaces:MakePreBuilt(f,Data)
		end
	end
end

if SERVER then SubSpaces:LoadData() end

LoadFile("singularity/data/client.lua",0)
LoadFile("singularity/data/effectsys.lua",1)
--Add weapon loading here.
LoadFile("singularity/data/modules.lua",1)
LoadFile("singularity/data/ownership.lua",2)















