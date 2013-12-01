--[[----------------------------------------------------
Shared Utility LUA -Holds all the utility functions for the mod.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
Singularity.Utl = {} --Make a Utility Table.
local Utl = Singularity.Utl --Makes it easier to read the code.

Utl.ThinkLoop = {} --Create the think loop table.
Utl.DebugTable = {} --Create the debug output storage.
Utl.Hooks = {} --Create the hook table.
Utl.Effect = {} --Create a table to store effect data in.

local DTable = Utl.DebugTable --Localise the debug storage.
local HTable = Utl.Hooks --Localise the hook table for speed.

--[[----------------------------------------------------
Debugging Functions.
----------------------------------------------------]]--

--The Debug function, allows us to easily enable/disable debugging.
function Utl:Debug(Source,String,Type)
	print("["..Type.."]: "..Source..": "..String)
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
MasterThink Loop
----------------------------------------------------]]--

local Thinks = Utl.ThinkLoop --Faster Access to the think loop table.

--Our Think Loop, Processes all the functions in one place.
hook.Add("Think","SingularityMainLoop",function()
	xpcall(function()
		for I, T in pairs( Thinks ) do --Loop all the think functions.
			if(T.S+T.D<CurTime())then --Check if its time to run the function.
				T.S=CurTime()--Sets the time for the next run (If we have one) 
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

--[[----------------------------------------------------
NonShared Utility Functions.
----------------------------------------------------]]--
if(SERVER)then	
	Utl:MakeHook("PlayerSpawnedSENT") 
	Utl:MakeHook("PlayerSpawnedNPC") 
	Utl:MakeHook("PlayerSpawnedVehicle") 
	Utl:MakeHook("PlayerSpawnedProp") 
	Utl:MakeHook("PlayerSpawnedEffect")
	Utl:MakeHook("PlayerSpawnedRagdoll") 
	Utl:MakeHook("PlayerInitialSpawn") 
	Utl:MakeHook("OnEntityCreated")
	Utl:MakeHook("PlayerSpawn")
	Utl:MakeHook("OnRemove")
	Utl:MakeHook("Shutdown")

	--[[----------------------------------------------------
	Settings and File Functions.
	----------------------------------------------------]]--
	
	local SettingsPath = Singularity.SaveDataPath..Singularity.SettingsName..".txt"
	
	if(not file.Exists(Singularity.SaveDataPath,"DATA"))then
		file.CreateDir(Singularity.SaveDataPath)
	end
	
	function Utl:LoadSettings()
		Singularity.Settings = util.JSONToTable(file.Read(SettingsPath,"DATA") or "") or {}
	end
	Utl:LoadSettings()
	
	function Utl:SaveSettings()
		file.Write(SettingsPath, util.TableToJSON({Settings = Singularity.Settings}))
	end
	
	Utl:HookHook("Shutdown","SettingsSave",Utl.SaveSettings,1)
	
	--[[----------------------------------------------------
	Serverside Effect Handling.
	----------------------------------------------------]]--
	util.AddNetworkString( "sing_sendeffectbase" )
	util.AddNetworkString( "sing_sendeffectdata" )
	util.AddNetworkString( "sing_requesteffectdata" )
	
	--Sends the base data of the effect.
	function Utl:SendEffectData(ply,Data)
		local Name = ply:Nick()
		if(not Utl.Effect[Name])then Utl.Effect[Name]={} end
		
	end
	
	--Sends the real effect data.
	net.Receive( "sing_requesteffectdata", function( length, client )
        
	end )
	
	--Packages the effect up and prepares to send it.
	function Utl:CreateEffect(Name,Data)
		
	end	
	
else
	--[[----------------------------------------------------
	ClientSide Effect Handling.
	----------------------------------------------------]]--
	Utl.NetDataTypes = {S=net.ReadString,E=net.ReadEntity,F=net.ReadFloat,V=net.ReadVector,A=net.ReadAngle}
	
	function Utl:RenderEffect(D)
		--[[
			Add Effect calling code here.
		]]
	end
	
	--Recieves the base data of the effect, and requests the rest.
	net.Receive( "sing_sendeffectbase", function( length )
		
		local Name = net.ReadString() --Gets the name of the effect.
		local Count = net.ReadFloat() --Get the amount of variables were recieving.
		
		local D = {}
		for I=1,Count do --Read all the variables.
			D[I]=net.ReadString()
		end
		Utl.Effect[Name]=D --Give the global effect table our D!
		
		--Request the real effect data.
		net.Start( "sing_requesteffectdata" )
		net.SendToServer()
	end ) 
	
	--Recieves the real effect data, and sends it off to be rendered.
	net.Receive( "sing_sendeffectdata", function( length )
        local Name = net.ReadString()
		
		if(Utl.Effect[Name])then --Do we have data for it?
			local D = Utl.Effect[Name]
			
			local E = {}
			for I, S in pairs( D ) do --Loop all the variables.
				local N = net.ReadString()--Get the variable name.
				E[N]=Utl.NetDataTypes[S]--Get the variable data.
			end
			Utl:RenderEffect(E)--Send it off to be rendered.
			
			Utl.Effect[Name]=nil --Nil the effect, no reason to keep outdated data.
		else
			Utl:Debug("EffectSys","Recieving effect data from none synced "..Name,"ERROR") --Oopsie
		end
	end )
	
end

--[[----------------------------------------------------
Other Functions
----------------------------------------------------]]--

function Utl:CheckValid( entity )
	if (not entity or not entity:IsValid()) then return false end
	if (entity:IsWorld()) then return false end
	if (not entity:GetPhysicsObject():IsValid()) then return false end
	if (not entity:GetPhysicsObject():GetVolume()) then return false end
	if (not entity:GetPhysicsObject():GetMass()) then return false end
	return true
end

--[[----------------------------------------------------
Constraint Functions.
----------------------------------------------------]]--

function constraint.GetAllWeldedEntities( ent, ResultTable ) --Modded constraint.GetAllConstrainedEntities to find only welded ents
	local ResultTable = ResultTable or {}
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	if ( ResultTable[ ent ] ) then return end	
	ResultTable[ ent ] = ent	
	local ConTable = constraint.GetTable( ent )	
	for k, con in ipairs( ConTable ) do	
		for EntNum, Ent in pairs( con.Entity ) do
			if (con.Type == "Weld") or (con.Type == "Axis") or (con.Type == "Ballsocket") or (con.Type == "Hydraulic") then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end	
	end
	return ResultTable	
end

function constraint.GetAllConstrainedEntities_B( ent, ResultTable ) --Modded to filter out grabbers
	local ResultTable = ResultTable or {}
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	if ( ResultTable[ ent ] ) then return end
	ResultTable[ ent ] = ent
	local ConTable = constraint.GetTable( ent )
	for k, con in ipairs( ConTable ) do
		for EntNum, Ent in pairs( con.Entity ) do
			if con.Type != ""  then
				constraint.GetAllWeldedEntities( Ent.Entity, ResultTable )
			end
		end
	end
	return ResultTable
end
