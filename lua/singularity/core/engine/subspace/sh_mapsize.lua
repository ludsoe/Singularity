local Utl = Singularity.Utl --Makes it easier to read the code.
local SubSpaces = SubSpaces --SPEED!!! WEEEEEE

 --Function to grab the maps size using raytracing and guessing.
function SubSpaces.GetAreaSize(Vec)
	local Directions = {
		Up=Vector(0,0,1),
		Down=Vector(0,0,-1),
		Right=Vector(1,0,0),
		Left=Vector(-1,0,0),
		Forw=Vector(0,1,0),
		Back=Vector(0,-1,0)
	}
	
	local Lengths = {}
	
	for name, Dir in pairs( Directions ) do
		Msg("Tracing "..name.." Dist: ")
		local tr = {}
		local TraceDist = 300000
		
		tr.start = Vec
		tr.endpos = Vec+(Dir*TraceDist)
		tr.mask = 147467
		
		local Trace = util.TraceLine( tr,"")
		local Dist = math.floor(Vec:Distance(Trace.HitPos))
		local Key = tostring(Dist)
		if(Lengths[Key])then
			Lengths[Key]=Lengths[Key]+1
		else
			Lengths[Key]=1
		end
		Msg(Dist.."\n")
	end
	
	local Dist=0
	local DCou=0
	for name, Num in pairs( Lengths ) do
		if(Num>DCou)then
			Dist=tonumber(name)
			DCou=Num
		end
	end
	--print("I Think the Area Size is "..Dist)
	
	return Dist
end

function SubSpaces.GetMapSize()
	SubSpaces.MapSize=SubSpaces.GetAreaSize(SubSpaces.Center)
	SubSpaces.SkySize=SubSpaces.GetAreaSize(SubSpaces.SkyBox)
	
	print("Map Size "..SubSpaces.MapSize)
	print("Sky Size "..SubSpaces.SkySize)
	print("Scale "..SubSpaces.Scale)
end

Utl:SetupThinkHook("GetMapSize",0,1,function() SubSpaces.GetMapSize() end)--Because running it first things first caused crashs.

