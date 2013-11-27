--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Pers = Singularity.Persistance --Localise the persistance table for speed.
local PB = Singularity.PreBuilt --Grab the prebuilt designs.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.Station = Singularity.Station or {}

if(SERVER)then
	Utl:SetupThinkHook("CreateSpawnStation",0.1,1,function() Pers:LoadFromData(Vector(0,0,0),PB["spawnstation"],false) end)
else

end