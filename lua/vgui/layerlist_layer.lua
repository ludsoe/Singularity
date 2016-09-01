--[[------------------------------------------------------------------------------------------------------------------
	SubSpace control
------------------------------------------------------------------------------------------------------------------]]--

PANEL = {}

function PANEL:Init()	
	self.OwnerButton = vgui.Create( "DImageButton", self )
	self.OwnerButton:SetMaterial( "icon16/key.png" )
	
	self.InfoButton = vgui.Create( "DImageButton", self )
	self.InfoButton:SetMaterial( "icon16/package_green.png" )
	
	self.PosButton = vgui.Create( "DImageButton", self )
	self.PosButton:SetMaterial( "icon16/world.png" )
	self.PosButton.Think = function()
		self.PosButton:SetTooltip( "Position: " .. tostring(self.SubSpace.Pos))
	end
	
	self.InfoButton.Think = function()
		local count = 0
		
		for _, ent in ipairs( ents.GetAll() ) do
			if ( ent:GetSubSpace() == self.SubSpace.ID and !ent:IsWeapon() ) then count = count + 1 end
		end
		
		self.InfoButton:SetTooltip( "Amount of entities: " .. count )
	end
	
	self.PlayersButton = vgui.Create( "DImageButton", self )
	self.PlayersButton:SetMaterial( "icon16/group.png" )
	
	self.PlayersButton.Think = function()
		local players = ""
		
		for _, ply in ipairs( player.GetAll() ) do
			if ( ply:GetSubSpace() == self.SubSpace.ID ) then
				players = players .. ply:Nick() .. ", "
			end
		end
		
		if ( #players == 0 ) then
			players = "None."
		else
			players = string.Left( players, #players - 2 )
		end
		
		self.PlayersButton:SetTooltip( "Players: " .. players )
	end
	
	self.Selected = false
end

function PANEL:OnMouseReleased( mc )
	for _, subspace in pairs( SubSpaces.layerList.List:GetItems() ) do subspace.Selected = false end
	
	self.Selected = true
	SubSpaces.layerList.SelectedLayer = self.SubSpace.ID
	
	--RunConsoleCommand( "subspaces_select", self.SubSpace.ID )
	
	Singularity.Utl.NetMan.AddData({Name="subspaces_player_select",Val=1,Dat={ID=self.SubSpace.ID}})
end

function PANEL:SetLayer( id, title, owner, pos)
	self.SubSpace = { ID = id, Title = title, Owner = owner, Pos=pos}

	self.OwnerButton:SetTooltip( "Owner: " .. owner )
end

function PANEL:PerformLayout()
	self.PlayersButton:SizeToContents()
	self.PlayersButton.y = 4
	self.PlayersButton:AlignRight( 6 )
	
	self.OwnerButton:SizeToContents()
	self.OwnerButton.x = self.PlayersButton.x - self.PlayersButton:GetWide() - 5
	self.OwnerButton.y = 4
	
	self.InfoButton:SizeToContents()
	self.InfoButton.x = self.OwnerButton.x - self.OwnerButton:GetWide() - 5
	self.InfoButton.y = 4
	
	self.PosButton:SizeToContents()
	self.PosButton.x = self.InfoButton.x - self.OwnerButton:GetWide() - 5
	self.PosButton.y = 4
	
	self:SetTall( self.PlayersButton:GetTall() + 8 )
end

function PANEL:Paint()
	if ( self.Selected ) then
		draw.RoundedBox( 2, 0, 0, self:GetWide(), self:GetTall(), Color( 48, 150, 253, 255 ) )
	else
		draw.RoundedBox( 2, 0, 0, self:GetWide(), self:GetTall(), Color( 121, 121, 121, 150 ) )
	end
	
	draw.SimpleText( self.SubSpace.Title, "Default", 6, 6, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	
	return false
end