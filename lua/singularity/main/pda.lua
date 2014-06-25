local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

if(SERVER)then
	function OpenPda( ply )
		local Data = {Name="open_pda",Val=1,Dat={}}
		NDat.AddData(Data,ply)
	end
	hook.Add( "ShowSpare1", "bindtoSpare1", OpenPda )
else
	local PDA,Pages = {},{}
	
	function LoadPDAPages()
		local A = SubSpaces.GetSubSpaceEntity(LocalPlayer():GetSubSpace())
		if A and A.DryDock then Pages["DryDock"](A) end
	end
	
	function AccessPDA()
		--Add a check so multiple menus cant open at once.
		PDA = {}
		PDA.Base = Singularity.MenuCore.CreateFrame({x=700,y=500},true,true,false,true)
		PDA.Base:Center()
		PDA.Base:SetTitle( "Singularity: Personal Data Assistant" )
		PDA.Base:MakePopup()
		
		PDA.Sheet = Singularity.MenuCore.CreatePSheet(PDA.Base,{x=700,y=475},{x=0,y=25})
		
		LoadPDAPages()
	end
	
	Utl:HookNet("open_pda","",function(D) AccessPDA() end)
	
	Pages["DryDock"]=function(A)
		local P = vgui.Create( "DPanel" )
		Sheet:AddSheet( "Ship Editor" , P , "icon16/shield.png" , false, false, "Ship Editor Functions" )
		
		Singularity.MenuCore.CreateButton(P,{x=80,y=50},{x=0,y=0},"Compile Ship",function() 
			local Data = {Name="compileship",Val=1,Dat={}}
			NDat.AddData(Data)
		end)		
	end
end		 
