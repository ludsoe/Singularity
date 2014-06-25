local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

if(SERVER)then
	Utl:HookNet("enterdrydock","",function(D,P)
		SubSpaces.OpenDryDockSpace(P)
	end)
	
	Utl:HookNet("compileship","",function(D,P)
		SubSpaces.CompileShip(P)
	end)
else
	local Console = {}
	local Tabs = {}
	
	function OpenConsole()
		if Console and IsValid(Console.Base) then Console.Base:Remove() end
		Console.Base = Singularity.MenuCore.CreateFrame({x=700,y=500},true,true,false,true)
		Console.Base:Center()
		Console.Base:SetTitle( "Console" )
		Console.Base:MakePopup()
		
		Console.Sheet = Singularity.MenuCore.CreatePSheet(Console.Base,{x=700,y=475},{x=0,y=25})
	end	
	
	function AddTab(Tab)
		if not IsValid(Console.Sheet) then return end
		Tabs[Tab](Console.Sheet)
	end

	Utl:HookNet("open_shipconsole","",function(D)
		OpenConsole()
		
		for N,V in pairs(D) do
			if V then
				AddTab(N)
			end
		end
	end)
	
	Tabs["DryDock"]=function(Sheet)
		local P = vgui.Create( "DPanel" )
		Sheet:AddSheet( "DryDock" , P , "icon16/shield.png" , false, false, "DryDock" )
		
		Singularity.MenuCore.CreateButton(P,{x=80,y=50},{x=0,y=0},"Enter DryDock",function() 
			local Data = {Name="enterdrydock",Val=1,Dat={}}
			NDat.AddData(Data)
			Console.Base:Remove()
		end)
	end
	
end
