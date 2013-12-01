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
local CoreF = "singularity/core/"
local DataF = "singularity/data/"
local MainF = "singularity/main/"

--Ease Function to load files both serverside and client side.
local function LoadFile(Path)
	print("*Loading "..Path)
	include(Path)
	if(SERVER)then
		AddCSLuaFile(Path)
	end
end

LoadFile(CoreF.."sh_utility.lua")
LoadFile(CoreF.."sh_entitypersistance.lua")
LoadFile(CoreF.."sh_subspacecore.lua")
LoadFile(CoreF.."sh_cubicuniverse.lua")
LoadFile(DataF.."init.lua")
LoadFile(MainF.."init.lua")
if(SERVER)then include(CoreF.."sv_propprotect.lua") end

LoadFile(CoreF.."emptylua.lua")

print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
