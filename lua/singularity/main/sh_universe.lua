--[[----------------------------------------------------
sh_universe -Where all the universe building functions are stored.
----------------------------------------------------]]--
local Singularity = Singularity --Localise the global table for speed.
Singularity.Universe = Singularity.Universe or {}
local Universe = Singularity.Universe --SPEEEEEEEEEED WOOT!

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