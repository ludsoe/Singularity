--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local Pers = Singularity.Persistance --Localise the persistance table for speed.
local PB = Singularity.PreBuilt

local MainF = "singularity/main/"
local ScorF = "singularity/scoreboard/"

Singularity.LoadFile(ScorF.."init.lua",1)

if SERVER then
	Utl:SetupThinkHook("SpawnStation",0,1,function() Pers:LoadFromData(Vector(0,0,0),PB["spawnstation"],false,SubSpaces.MainSpace) end)--Because running it first things first caused crashs.
end