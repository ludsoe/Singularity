--[[----------------------------------------------------
Shared Utility LUA -Holds all the utility functions for the mod.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
Singularity.Utl = {} --Make a Utility Table.
local Utl = Singularity.Utl --Makes it easier to read the code.

Utl.ThinkLoop = Utl.ThinkLoop or {} --Create the think loop table.
Utl.DebugTable = Utl.DebugTable or {} --Create the debug output storage.
Utl.Hooks = Utl.Hooks or {} --Create the hook table.
Utl.Effect = Utl.Effect or {} --Create a table to store effect data in.
Utl.NetMan = Utl.NetMan or {} --Where we store the queued up data to sync.

local DTable = Utl.DebugTable --Localise the debug storage.
local HTable = Utl.Hooks --Localise the hook table for speed.

--[[----------------------------------------------------
Debugging Functions.
----------------------------------------------------]]--

--The Debug function, allows us to easily enable/disable debugging.
function Utl:Debug(Source,String,Type)
	Singularity.Debug(String,2,"["..Type.."]"..Source)--Redirect this to use the debug.lua debug functions.
	--print("["..Type.."]: "..Source..": "..String)
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
	Utl:MakeHook("PlayerDisconnected")
	Utl:MakeHook("PlayerConnect")
	Utl:MakeHook("PlayerConnect")
	Utl:MakeHook("OnRemove")
	Utl:MakeHook("Shutdown")
	
	function Utl:LoopValidPlayers(F,A1,A2,A3,A4,A5)
		local players = player.GetAll()	
		for _, ply in ipairs( players ) do
			if ply and ply:IsConnected() then
				local Return = F(ply,A1,A2,A3,A4,A5)
				if(Return and Return~=nil)then
					return Return
				end
			end
		end
	end
	
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
	Serverside Networking Handling.
	----------------------------------------------------]]--
	function NumBool = function(V) if V then return 1 else return 0 end end --Bool to number.

	util.AddNetworkString( "sing_basenetmessage" )
	local NDat = Utl.NetMan --Ease link to the netdata table.
	NDat.Data = NDat.Data or {} -- The actual table we store data in.
	NDat.NetDataTypes = {S=net.WriteString,E=net.WriteEntity,F=net.WriteFloat,V=net.WriteVector,A=net.WriteAngle,B=function(V) net.WriteFloat(NumBool(V)) end}
	
	--Loops the players and prepares to send their data.
	function NDat.CyclePlayers()
		for nick, pdat in pairs( NDat.Data ) do
			local Max = 10
			for id, Data in pairs( pdat.Data ) do
				if(Max<=0)then break end--We reached the maximum amount of data for this player.
				Max=Max-Data.Val
				NDat.SendData(Data,Data.Name,pdat.Ent)
				table.remove(pdat.Data,id)
			end
		end
	end

	--Actually sends the data out.
	function NDat.SendData(Data,Name,ply)
		net.Start("sing_basenetmessage")
			net.WriteString(Name)
			net.WriteFloat(table.Count(Data.Dat))
			for I, S in pairs( Data.Dat ) do --Loop all the variables.
				net.WriteString(S.N)--Get the variable name.
				net.WriteString(S.T)
				NDat.NetDataTypes[S.T](S.V)
			end
		net.Send(ply)
	end
	
	--[[
		Data={Name="example",Val=1,Dat={{N="D",T="S",V="example"}}}
	]]	
	function NDat.AddData(Data,ply)
		local T=NDat.Data[ply:Nick()]
		if not T then return end
		table.insert(T.Data,Data)
	end
	
	function NDat.AddDataAll(Data)
		Utl:LoopValidPlayers(function(ply) NDat.AddData(Data,ply) end)
	end
	
	--Creates the table we will use for each player.
	function NDat.AddPlay(ply)
		NDat.Data[ply:Nick()]={Data={},Ent=ply}
	end
	
	Utl:SetupThinkHook("SyncNetData",0.2,0,NDat.CyclePlayers)
	
	Utl:HookHook("PlayerInitialSpawn","NetDatHook",NDat.AddPlay,1)

	--[[----------------------------------------------------
	Serverside Chat Functions.
	----------------------------------------------------]]--
	util.AddNetworkString( "sing_sendcolchat" )
	
	function Utl:NotifyPlayers(Source,String,Color)
		local plys = player.GetAll()
		for k,v in pairs(plys) do
			v:SendColorChat(Source,Color,String)
		end
	end
	
	local meta = FindMetaTable("Player")

	function meta:SendColorChat(nam,col,msg)
		net.Start("sing_sendcolchat")
			net.WriteString(nam)
			net.WriteVector(Vector(col.r,col.g,col.b))
			net.WriteString(msg)
		net.Send(self)
	end
	
	--OnJoin
	local F = function( name, address )
		local Text = name .. " has connected from IP: " .. address
		Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
	end
	Utl:HookHook("PlayerConnect","UtlChatMsg",F,1)
	
	--OnLeave
	local F = function( ply )
		local Text = ply:GetName().." has disconnected from the server. (SteamID: "..ply:SteamID().." )"
		Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
	end
	Utl:HookHook("PlayerDisconnected","UtlChatMsg",F,1)	
	
	--OnIntSpawn
	local F = function( ply )
		local Text = ply:GetName().." has spawned."
		Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
	end
	Utl:HookHook("PlayerInitialSpawn","UtlChatMsg",F,1)
	
else
	--[[----------------------------------------------------
	ClientSide Chat Handling.
	----------------------------------------------------]]--
	net.Receive( "sing_sendcolchat", function( length )
		local nam = net.ReadString()
		local vcol = net.ReadVector()
		local col = Color(vcol.x,vcol.y,vcol.z)
		local msg = net.ReadString()
		
		chat.AddText(unpack({col, nam,Color(255,255,255),": "..msg}))
	end)
	
	--[[----------------------------------------------------
	ClientSide Networking Handling.
	----------------------------------------------------]]--	
	local NDat = Utl.NetMan --Ease link to the netdata table.
	NDat.Data = {} 
	NDat.NetDataTypes = {S=net.ReadString,E=net.ReadEntity,F=net.ReadFloat,V=net.ReadVector,A=net.ReadAngle,B=function() return net.ReadFloat()>0 end}
	
	function Utl:HookNet(MSG,ID,Func)
		NDat.Data[MSG] = Func
	end
	
	function NDat:InNetF(MSG,Data)
		if(NDat.Data[MSG])then
			NDat.Data[MSG](Data)
		else
			print("Unhandled message... "..MSG)
		end
	end
	
	net.Receive( "sing_basenetmessage", function( length )
		local Name = net.ReadString() --Gets the name of the message.
		local Count = net.ReadFloat() --Get the amount of variables were recieving.
		
		local D = {}
		for I=1,Count do --Read all the variables.
			local VN = net.ReadString()
			local Ty = net.ReadString()
			D[VN]=NDat.NetDataTypes[Ty]()
		end
		NDat:InNetF(Name,D)		
	end)
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
