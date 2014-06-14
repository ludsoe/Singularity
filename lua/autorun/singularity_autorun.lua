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
Singularity.Version = "InDev V:11"
Singularity.DebugMode = "Verbose" 
Singularity.EnableMenu = true --Debug Menu

include("singularity/load.lua")
if SERVER then AddCSLuaFile("singularity/load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.
local CoreF,DataF,MainF = "singularity/core/","singularity/data/","singularity/main/"

--Shared
LoadFile("singularity/menusys.lua",1)
LoadFile("singularity/debug.lua",1)
LoadFile(CoreF.."sh_utility.lua",1)
LoadFile(CoreF.."sh_constraints.lua",1)
LoadFile(CoreF.."sh_entitypersistance.lua",1)
LoadFile(CoreF.."/engine/sh_subspacecore.lua",1)
LoadFile(DataF.."init.lua",1)

if game.GetMap() == "lde_space_v1" then
	LoadFile(MainF.."init.lua",1)
	LoadFile(CoreF.."sh_shared.lua",1)
	
	LoadFile("vgui/hud.lua",0)

	if CLIENT then
		language.Add( "worldspawn", "World" )
		language.Add( "trigger_hurt", "Environment" )
		
		local function Reload() LoadHud() end Reload()
		concommand.Add("lss_reload_hud", Reload)
	else
		hook.Add("GetGameDescription", "GameDesc", function() 
			return "Singularity: "..Singularity.Version
		end)
	end
end

print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
