--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--
print("((----------------------------------------------------))")
print("((------------Singularity AutoRun Loading!------------))")
print("((----------------------------------------------------))")
local StartTime = SysTime()

Singularity = {} --Create our Global Table.
local Singularity = Singularity --Localise the global table for speed.
Singularity.Settings = Singularity.Settings or {} --Setup our settings table.
Singularity.SettingsName = "singularitysettings"
Singularity.SaveDataPath = "singularity/"
Singularity.Version = "ReDev V:1"
Singularity.DebugMode = "Verbose" 
Singularity.EnableMenu = true --Debug Menu

include("sh_load.lua")
if SERVER then AddCSLuaFile("sh_load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.

--Create the subspace global table.
SubSpaces = SubSpaces or {}

LoadFile("subspace/sh_debug.lua",1,"Debug Functions")
LoadFile("subspace/sh_utility.lua",1,"Utility Libraries")
LoadFile("subspace/sh_networking.lua",1,"Networking Systems")
LoadFile("subspace/sh_vguiease.lua",1,"VGui ShortCuts")
LoadFile("subspace/sh_datamanagement.lua",1,"File System Managers")

LoadFile("subspace/sh_variables.lua",1,"Variables")

LoadFile("subspace/sh_gameinit.lua",1)

--Shared
--LoadFile("singularity/variables.lua",1)
--LoadFile("singularity/menusys.lua",1)
--LoadFile("singularity/debug.lua",1)
--LoadFile(CoreF.."sh_utility.lua",1)
--LoadFile(CoreF.."/engine/sh_networking.lua",1)
--LoadFile(CoreF.."sh_constraints.lua",1)
--LoadFile(CoreF.."sh_entitypersistance.lua",1)
--LoadFile(CoreF.."/engine/sh_subspacecore.lua",1)
--LoadFile(DataF.."init.lua",1)

print("((----------------------------------------------------))")
print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
print("((----------------------------------------------------))")