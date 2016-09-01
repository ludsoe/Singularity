local SubSpaces = SubSpaces
local LoadFile = Singularity.LoadFile

print("--[[ Loading Gameplay Elements... ]]--")

--Set the subspace mode to basic.
SubSpaces.SubSpaceMode = "Basic"

if game.GetMap() == "lde_space_v1" then
	SubSpace.SubSpaceMode = "Advanced" --Set the subspace mode to advanced
end

print("Initializing SubSpace libraries in "..SubSpaces.SubSpaceMode.." Mode.")

--Load up the subspace core.
LoadFile("subspace/game/sh_subspace_library.lua",1)
