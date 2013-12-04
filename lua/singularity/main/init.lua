--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Pers = Singularity.Persistance --Localise the persistance table for speed.
local PB = Singularity.PreBuilt --Grab the prebuilt designs.
local Utl = Singularity.Utl --Makes it easier to read the code.

if(SERVER)then
	Utl:SetupThinkHook("CreateSpawnStation",0.1,1,function() 
		Pers:LoadFromData(Vector(0,0,0),PB["spawnstation"],false,SubSpaces.MainSpace) 
	end)
	
	function Singularity.PlayerSpawn(ply)
		local Spawns = ents.FindByClass("sing_playerspawn")
		local Spawn = table.Random(Spawns)
		ply:SetPos(Spawn:GetPos()+Vector(0,0,5))
		ply:SetSubSpace(Spawn:GetSubSpace())
	end
	Utl:HookHook("PlayerSpawn","SubSpace",Singularity.PlayerSpawn,1)	
else

end

local MainF = "singularity/main/"
local ScorF = "singularity/scoreboard/"

Singularity.LoadFile(MainF.."lde_spacecraft.lua")
Singularity.LoadFile(MainF.."sh_universe.lua")
Singularity.LoadFile(ScorF.."init.lua")

