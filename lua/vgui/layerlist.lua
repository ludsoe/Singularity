--[[------------------------------------------------------------------------------------------------------------------
	SubSpace list control
------------------------------------------------------------------------------------------------------------------]]--

PANEL = {}
 
local layerButtonControl = vgui.RegisterFile( "vgui/layerlist_layer.lua" )

function PANEL:Init()
	self.List = vgui.Create( "DPanelList", self )
	self.List:SetSpacing( 2 )
	self.List:SetPadding( 2 )
	
	self.SelectedLayer = 1
	
	RunConsoleCommand( "subspaces_sync" )
end

function PANEL:PerformLayout()
	self:SetTall( 400 )
	
	self.List:StretchToParent( 0, 0, 0, 0 )
end

function PANEL:AddLayer( id, title, owner, pos)
	local layerButton = vgui.CreateFromTable( layerButtonControl, self.List )
	layerButton:SetLayer( id, title, owner, pos)
	
	self.List:AddItem( layerButton )
end