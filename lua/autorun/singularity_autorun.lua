--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--
print("Singularity AutoRun Core Loading!")
local StartTime = SysTime()

Singularity = {} --Create our Global Table.
local Singularity = Singularity --Localise the global table for speed.
Singularity.Settings = Singularity.Settings or {} --Setup our settings table.
Singularity.SettingsName = "singularitysettings"
Singularity.SaveDataPath = "singularity/"

Singularity.Debug = true --Print to console Debugging variable.
local CoreF,DataF,MainF = "singularity/core/","singularity/data/","singularity/main/"

include("singularity/load.lua")
if SERVER then AddCSLuaFile("singularity/load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.

--Shared
LoadFile(CoreF.."sh_utility.lua",1)
LoadFile(CoreF.."sh_entitypersistance.lua",1)
LoadFile(CoreF.."sh_subspacecore.lua",1)
LoadFile(CoreF.."sh_cubicuniverse.lua",1)
LoadFile(DataF.."init.lua",1)
LoadFile(MainF.."init.lua",1)
LoadFile(CoreF.."sh_emptylua.lua",1)

--Client
LoadFile(CoreF.."sv_propprotect.lua",0)

if CLIENT then
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
else
	hook.Add("GetGameDescription", "GameDesc", function() 
		return "Singularity"
	end)
end
SinglePlayer = game.SinglePlayer

print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
