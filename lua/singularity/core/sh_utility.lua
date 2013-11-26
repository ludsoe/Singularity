--[[----------------------------------------------------
Shared Utility LUA -Holds all the utility functions for the mod.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
Singularity.Utl = {} --Make a Utility Table.
local Utl = Singularity.Utl --Makes it easier to read the code.

Utl.ThinkLoop = {} --Create the think loop table.
Utl.DebugTable = {} --Create the debug output storage.
Utl.Hooks = {} --Create the hook table.

local DTable = Utl.DebugTable --Localise the debug storage.
local HTable = Utl.Hooks --Localise the hook table for speed.

--[[----------------------------------------------------
Debugging Functions.
----------------------------------------------------]]--

--The Debug function, allows us to easily enable/disable debugging.
function Utl:Debug(Source,String,Type)
	local Time = tostring(os.date())
	if(not DTable[Type])then DTable[Type]={} end
	local TypeTab=DTable[Type] 
	if(not TypeTab[Source])then TypeTab[Source]={} end
	
	table.insert(TypeTab[Source],Time..": "..String)

	if(Singularity.Debug or Type=="Error")then
		print("["..Type.."]: "..Source..": "..String)
	end
end

--[[----------------------------------------------------
Hook Management -Hook Management, allows for easily adding/killing hooks aswell as viewing them and debugging.
----------------------------------------------------]]--

function Utl:RunHooks(Name,a1,a2,a3,a4,a5)--Run the HookHooks and return the most important return we get.
	local ReturnTable = {}
	local Hook = HTable[Name]
	
	for I, H in pairs( Hook ) do --Loop all the HookHooks.
		xpcall(function()
			local R = H.F(a1,a2,a3,a4,a5) --Call the HookHook.
			if(R~=nil)then --Did we get a return?
				local RS=tostring(R) --Localise a string version of the return.
				if(not ReturnTable[RS])then ReturnTable[RS]={N=0,R=R}end
				local RT = ReturnTable[RS]
				RT.N=RT.N+H.I --Add the HookHook's importance to the return.
			end
		end,ErrorNoHalt)
	end 
	 
	if(table.Count(ReturnTable)>0)then --We got anything to return?
		local N = 0
		for I, H in pairs( ReturnTable ) do
			if(H.N>N)then
				Return = H.R
			end
		end
		
		return Return --Return the most important return.
	end
end

function Utl:HookHook(Hook,Name,Func,Impo) --Makes the HookHook in the hook table.
	--[[
		Hook: The Name of the hook we are HookHooking.
		Name: The Name of the HookHook.
		Func: The function called when the hook is called.
		Impo: The Importance of the HookHook, this is for figuring out what we return to the hook from all HookHooks.
	]]
	if(HTable[Hook][Name])then
		Utl:Debug("Hooks","There already is a HookHook in "..Hook.." for "..Name.." overwriting!","Error")
	end
	HTable[Hook][Name]={N=Name,F=Func,I=Impo}
end

function Utl:KillHook(Name,Func) end --When we want to remove hooks from the table.

function Utl:MakeHook(Name) --Make the hookhook storage.
	if(not HTable[Name])then
		HTable[Name]={}
		local Func = function(a1,a2,a3,a4,a5)
			Utl:RunHooks(Name,a1,a2,a3,a4,a5)
		end
		hook.Add(Name,"SingHookMake",Func)
	else
		Utl:Debug("Hooks","There already is a Hook table for "..Name,"Error")
	end
end	

--[[----------------------------------------------------
NonShared Utility Functions.
----------------------------------------------------]]--

if(SERVER)then
	local Thinks = Utl.ThinkLoop --Faster Access to the think loop table.
	
	--Our Think Loop, Processes all the functions in one place.
	hook.Add("Think","SingularityMainLoop",function()
		xpcall(function()
			for I, T in pairs( Thinks ) do --Loop all the think functions.
				if(T.S+T.D<CurTime())then --Check if its time to run the function.
					local Remove,TR = false,T.R --Define some variables.
					if(TR>0)then if(TR>1)then T.R=TR-1 else Remove=true end end --Repeat check.
					xpcall(function()
						if(T.F)then
							T.F()
						else
							Utl:Debug("ThinkLoop",T.N.." has no function!","Error")
						end
					end,ErrorNoHalt) --Running the function.
					if(Remove)then Thinks[I]=nil end --Removing ended functions.
				end
			end
		end,ErrorNoHalt)
	end)

	--Function for easily adding into the main think loop.
	function Utl:SetupThinkHook(Name,Delay,Repeat,Function)
		--[[
			Name: Name of the function.
			Delay: The time it waits before being ran. (Resets after each run.)
			Repeat: How many times the function repeats before being removed.
			Function: The function thats called.
		]]
		Thinks[Name]={N=Name,S=CurTime(),D=Delay,R=Repeat,F=Function}
	end
	
	Utl:MakeHook("PlayerSpawnedSENT") 
	Utl:MakeHook("PlayerSpawnedNPC") 
	Utl:MakeHook("PlayerSpawnedVehicle") 
	Utl:MakeHook("PlayerSpawnedProp") 
	Utl:MakeHook("PlayerSpawnedEffect")
	Utl:MakeHook("PlayerSpawnedRagdoll") 
	Utl:MakeHook("PlayerInitialSpawn") 
	Utl:MakeHook("OnEntityCreated") 
else

end

