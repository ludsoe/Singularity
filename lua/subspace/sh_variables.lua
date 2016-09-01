local Singularity = Singularity

Singularity.IgnoreClasses = {}
local Ig = Singularity.IgnoreClasses
Ig["class C_PlayerResource"]=true
Ig["class C_GMODGameRulesProxy"]=true
Ig["scene_manager"]=true
Ig["bodyque"]=true
Ig["gmod_gamerules"]=true
Ig["soundent"]=true
Ig["phys_constraint"]=true
Ig["ai_network"]=true
Ig["player_manager"]=true
Ig["info_player_start"]=true
Ig["sing_stars"]=true

Singularity.NoRender = {}
local NR = Singularity.NoRender
NR["sing_anchor"]=true
NR["sing_spawn"]=true
NR["class C_RopeKeyframe"]=true