--[[----------------------------------------------------
sh_universe -Where all the universe building functions are stored.
----------------------------------------------------]]--
local Singularity = Singularity --Localise the global table for speed.
Singularity.Universe = Singularity.Universe or {}
local Universe = Singularity.Universe --SPEEEEEEEEEED WOOT!
local Utl = Singularity.Utl --Makes it easier to read the code.
local SubKeys = SubSpaces.SubSpaceKeys

math.randomseed(SubSpaces.MapSeed)

function Universe.ScaleEntity(ent,scale)

	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		local mesh = phys:GetMesh()
		
		if(mesh)then
			for k,v in pairs(mesh) do
				v.pos = v.pos*scale
			end
			ent:PhysicsFromMesh(mesh)
			ent:EnableCustomCollisions()
		end
	end
	
	if(SERVER)then
		net.Start( "universe_setscale" )
			net.WriteEntity(ent)
			net.WriteFloat(scale)
		net.Broadcast()
	else
		local s = Vector( scale,scale,scale )
		local mat = Matrix()
		mat:Scale( s )
		ent:EnableMatrix( "RenderMultiply", mat )
		ent.DrawEntityOutline = function() end//fixes it breaking the clientside scale
	end
end

if(SERVER)then
	util.AddNetworkString( "universe_setscale" )
	
	local seed = SubSpaces.MapSeed --Get the seed.
	
	--salmonmans function
	//This function gets a "random" number from a 3d point. The 4th value can be whatever you want, it just allows you to get multiple random numbers from the same point.
	function Noise( x , y , z , val)
		local n = x^2 + y * 57 + z*23
		--n = bit.arshift(n,13)^n --Doesnt appear to do anything
		return math.fmod(( (n * (n * n * seed*15731 + 789221*val) + seed*1376312589*val)) / 1073741824*val , 256) //<That last 256 is 1+ the highest random value the function can return (0-255)
	end
	
	function GenerateStar( x,y,z )

		//This assumes that each x,y,z value will be like 20 map sizes apart, or else the entire galaxy will be too small.

		//Pretty sure atan2 returns radians, and we need in degrees. Not sure though
		local dir = math.deg(math.atan2(y,x))
		local dist = math.Dist(0,0,x,y)
		//This equation is the mathematical representation of the spiral galaxy shape
		local over = math.Clamp( 255-(dist*1.5-math.abs(30 - (dir+dist)%60)*12)-240 + (255-dist)/2,0,255)
		//This is the random noise field value (0-255)
		local noise = Noise(x,y,z,1)
		
		if(over>0 and noise<4) then
			//Create a new star at the center of chunk x,y,z
			//To draw more random values from this, just do Noise(x,y,z,#) and replace # with some other value than 1, then do math.fmod and a second value to get a max range
			//ex. star.planetcount = math.fmod( Noise(x,y,z,2) , 11 )     the star will have between 0 and 10 planets
			local PSize = math.abs(math.fmod( Noise(x,y,z,2) , 9 ))
			Universe.BuildPlanet(Vector(0,0,0),PSize,SubSpaces:SubSpaceFromVector(SPos),{Color=Color(255,255,255,255)})
		end
	end

	local fl = math.floor
	function Universe.PreCache(ply)
		local Grid = 4
		local UP = ply:GetUniPos()
		local PPos = Vector(fl(UP.X/10)*10,fl(UP.Y/10)*10,fl(UP.Z/10)*10) --Converts the player pos into a 10 chunk grid.
		for X=1,Grid do
			XI=(X-Grid/2)*10
			for Y=1, Grid do
				YI=(Y-Grid/2)*10
				for Z=1, Grid do
					ZI=(Z-Grid/2)*10
					SPos = Vector(PPos.X+XI,PPos.Y+YI,PPos.Z+ZI)
					local Key = tostring(SPos)
					if(not SubKeys[Key])then
						SubSpaces:SubSpaceFromVector(SPos)
						GenerateStar( SPos.X,SPos.Y,SPos.Z )
					end
				end
			end	
		end
	end
	Utl:SetupThinkHook("UniversePreCache",3,0,function() Utl:LoopValidPlayers(Universe.PreCache) end)
	
	function Universe.BuildPlanet(Vec,Scale,SubSpace,Data)
		local planet = ents.Create( "sing_planet" )
		planet:SetPos(Vec)
		planet:SetAngles( Angle( 0, 0, 0 ) )
		planet:SetColor(Data.Color)
		planet:SetNWFloat("Scale", Scale)
		planet:Spawn()
		planet:Activate()
		planet:SetSubSpace(SubSpace)
		Universe.ScaleEntity(planet,Scale)
		
		local atmos = ents.Create( "sing_atmosphere" )
		atmos:SetPos( Vec )
		atmos:SetAngles( Angle( 0, 0, 0 ) )
		atmos:SetNWFloat("Scale", Scale)
		atmos:Spawn()
		atmos:Activate()
  		atmos:SetParent( planet )
		atmos:SetColor(Data.Color)
		atmos:SetSubSpace(SubSpace)
		atmos:SetupAtmosphere(Scale)
		Universe.ScaleEntity(atmos,Scale)
	end

	function Universe.LoadPlanet() end
	function Universe.SavePlanet() end
	
	function Universe.GeneratePlanet(Star) end
	
	
	function Universe.GenerateStar() 
		
	end
	
	
	function Universe.LoadSystem() end
	function Universe.SaveSystem() end
	
	function Universe.GenerateSystem() end
	
	
else
	net.Receive( "universe_setscale", function( length, client )
		local Ent,Scale = net.ReadEntity(),net.ReadFloat()
		if(not Ent or not Ent:IsValid())then return end
		Universe.ScaleEntity(Ent,Scale)
	end)
	
end		