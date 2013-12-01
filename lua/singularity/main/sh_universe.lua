--[[----------------------------------------------------
sh_universe -Where all the universe building functions are stored.
----------------------------------------------------]]--

if(SERVER)then

else

end		

math.randomseed(SubSpaces.MapSeed)

function RU()
	return math.random(-10,10)
end

function R()
	return math.random(-100000,100000)/10000
end

print("Planet 1")
X,Y,Z=R(),R(),R()
print(tostring(Vector(X,Y,Z)))

X,Y,Z=RU(),RU(),RU()
print(tostring(Vector(X,Y,Z)))

print("Planet 2")
X,Y,Z=R(),R(),R()
print(tostring(Vector(X,Y,Z)))

X,Y,Z=RU(),RU(),RU()
print(tostring(Vector(X,Y,Z)))