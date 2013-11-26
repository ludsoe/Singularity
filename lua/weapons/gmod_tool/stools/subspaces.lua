--[[------------------------------------------------------------------------------------------------------------------
	SubSpaces STOOL
		Description: Put entities in different layers.
		Usage: Left click to set the subspace of an entity and right click to set the subspace you're in yourself.
------------------------------------------------------------------------------------------------------------------]]--

TOOL.Category = "Construction"
TOOL.Name = "#SubSpaces"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "subspace" ] = 1

if ( CLIENT ) then
	language.Add( "Tool.subspaces.name", "SubSpaces" )
	language.Add( "Tool.subspaces.desc", "Construct in multiple layers." )
	language.Add( "Tool.subspaces.0", "Left click to set the subspace of an entity, right click to set the subspace you're in yourself." )
end 

--[[------------------------------------------------------------------------------------------------------------------
	Left click to set the subspace of an entity.
------------------------------------------------------------------------------------------------------------------]]--

function TOOL:LeftClick( tr )
	if ( not tr.Entity:IsValid() ) then return false end
	if ( CLIENT ) then return true end
	if ( !self:GetOwner().SelectedLayer) then return false end
	
	local entities = constraint.GetAllConstrainedEntities( tr.Entity )
	
	for _, ent in pairs( entities ) do
		ent:SetSubSpace( self:GetOwner().SelectedLayer )
	end
	
	return true
end

--[[------------------------------------------------------------------------------------------------------------------
	Right click to set the subspace you're in yourself.
------------------------------------------------------------------------------------------------------------------]]--

function TOOL:RightClick( tr )
	if ( not self:GetOwner():IsValid()) then return false end
	if ( CLIENT ) then return false end
	if ( !self:GetOwner().SelectedLayer ) then return false end
	
	self:GetOwner():SetSubSpace( self:GetOwner().SelectedLayer )
	
	return false
end

if ( CLIENT ) then
	local layerListControl = vgui.RegisterFile( "vgui/layerlist.lua" )

	function TOOL.BuildCPanel( pnl )	
		SubSpaces.layerList = vgui.CreateFromTable( layerListControl )
		pnl:AddPanel( SubSpaces.layerList )
	end
end 