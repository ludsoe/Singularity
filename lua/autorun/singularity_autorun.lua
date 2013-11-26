--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--
print("Singularity AutoRun Core Loading!")

Singularity = {} --Create our Global Table.
local Singularity = Singularity --Localise the global table for speed.

Singularity.Debug = true --Print to console Debugging variable.

include("singularity/core/sh_utility.lua")
if(SERVER)then
	AddCSLuaFile("singularity/core/sh_utility.lua")
	AddCSLuaFile("autorun/singularity_autorun.lua")
end







