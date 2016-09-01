--[[------------------------------------------------------------------------------------------------------------------
	SubSpace list control
------------------------------------------------------------------------------------------------------------------]]--

PANEL = {}
 
local layerButtonControl = vgui.RegisterFile( "vgui/layerlist_layer.lua" )

function PANEL:Init()
	print("LayerList Initing!")
	self.List = vgui.Create( "DPanelList", self )
	self.List:SetSpacing( 2 )
	self.List:SetPadding( 2 )
	
	self.ListedLayers = {}
	
	self.SelectedLayer = 1
		
	--RunConsoleCommand( "subspaces_sync" )
	--Singularity.Utl.NetMan.AddData({Name="subspaces_request_sync",Val=1,Dat={}})
end

function PANEL:Think()
	--print("LayerList Thinking!")
	
	for id, subspace in pairs( SubSpaces.SubSpaces ) do
		if not self.ListedLayers[id] then
			self.ListedLayers[id]=true
			self:AddLayer( id, subspace.Title, subspace.Owner, Vector())
		end
	end
end

function PANEL:PerformLayout()
	self:SetTall( 400 )
	
	self.List:StretchToParent( 0, 0, 0, 0 )
end

function PANEL:AddLayer( id, title, owner, pos)
	local layerButton = vgui.CreateFromTable( layerButtonControl, self.List )
	layerButton:SetLayer( id, title, owner, pos)
	
	self.List:AddItem( layerButton )
	
	print("Layer Added!")
end