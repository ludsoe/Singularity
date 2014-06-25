--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local Pers = Singularity.Persistance --Localise the persistance table for speed.
local PB = Singularity.PreBuilt
local SubSpaces = SubSpaces

local MainF = "singularity/main/"
local ScorF = "singularity/scoreboard/"

Singularity.LoadFile(ScorF.."init.lua",1)
Singularity.LoadFile(MainF.."pda.lua",1)

if SERVER then
	Utl:SetupThinkHook("SpawnStation",0,1,function() --Because running it first things first caused crashs.
		Pers:LoadFromData(Vector(0,0,0),PB["spawnstation"],false,SubSpaces.MainSpace) 
		SubSpaces:Compile(SubSpaces.MainSpace) --Compile the spawn station.
		
		if not IsValid(Singularity.StarField) then
			Singularity.StarField = ents.Create("sing_stars"):Spawn()
		end
	end)
	
	SubSpaces:SSSetAVel(SubSpaces.MainSpace,Angle(0,5,0))
end
