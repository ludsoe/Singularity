--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--
print("Singularity AutoRun Core Loading!")
local StartTime = SysTime()

Singularity = {} --Create our Global Table.
local Singularity = Singularity --Localise the global table for speed.

Singularity.Debug = true --Print to console Debugging variable.
local Path = "singularity/"

include(Path.."core/sh_utility.lua")
include(Path.."core/sh_entitypersistance.lua")
include(Path.."core/sh_subspacecore.lua")
include(Path.."core/sh_cubicuniverse.lua")
if(SERVER)then
	AddCSLuaFile(Path.."core/sh_utility.lua")
	AddCSLuaFile(Path.."core/sh_entitypersistance.lua")
	AddCSLuaFile(Path.."core/sh_subspacecore.lua")
	AddCSLuaFile(Path.."core/sh_cubicuniverse.lua")
end

print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
