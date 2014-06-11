------------------------------------------------------------------------------------------
-- Name: LoadData
-- Desc: Load all other files depending on their file name prefix.
------------------------------------------------------------------------------------------
local Singularity = Singularity --Localise the global table for speed.
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