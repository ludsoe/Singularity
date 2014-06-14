--[[----------------------------------------------------
Jupiter Menu Core -Provides a modular menu system.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
Singularity.MenuCore = {}
Singularity.MenuCore.SuperMenu = {}

if(CLIENT)then
	---------------------------------------------------------------
	---------------Vgui Derma Related Functions--------------------
	---------------------------------------------------------------
	
	function Singularity.MenuCore.CreateFrame(Size,Visible,XButton,Draggable,CloseDelete)
		local Derma = vgui.Create( "DFrame" )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetVisible( Visible )
			Derma:ShowCloseButton( XButton )
			Derma:SetDraggable( Draggable )
			Derma:SetDeleteOnClose( CloseDelete )
		return Derma
	end
	
	function Singularity.MenuCore.CreatePanel(Parent,Size,Spot,Draw)
		local Derma = vgui.Create( "DPanel", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma.Paint = Draw or Derma.Paint
		return Derma
	end
	
	function Singularity.MenuCore.CreateTextBar(Parent,Size,Spot,Text,Func)
		local Derma = vgui.Create( "DTextEntry", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text )
			Derma.OnEnter = function( self )
				Func( self:GetValue() )	
			end
		return Derma
	end
	
	function Singularity.MenuCore.CreateSlider(Parent,Spot,Values,Width)
		local Derma = vgui.Create( "DNumSlider", Parent )
			Derma:SetMinMax( Values.Min, Values.Max )
			Derma:SetDecimals( Values.Dec )
			Derma:SetWide( Width )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function Singularity.MenuCore.CreatePSheet(Parent,Size,Spot)
		local Derma = vgui.Create( "DPropertySheet", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function Singularity.MenuCore.DisplayModel(Parent,Size,Spot,Model,View,Look)
		local Derma = vgui.Create( "DModelPanel", Parent )
			Derma:SetModel(Model)
			Derma:SetSize( Size, Size )
			Derma:SetCamPos(Vector(View,View,View))
			if(Look)then
				Derma:SetLookAt(Vector(0,0,Look))
			end
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end	
	
	function Singularity.MenuCore.CreatePBar(Parent,Size,Spot,Progress)
		local Derma = vgui.Create( "DProgress", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetFraction( Progress() )
		return Derma
	end
	
	function Singularity.MenuCore.CreateText(Parent,Spot,Text,Color)
		local Derma = vgui.Create( "DLabel", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text or "" )
			Derma:SetTextColor( Color or Color( 255, 255, 255, 255 ) )
			Derma.OldText = Derma.SetText
			Derma.SetText = function(self,Text)
				self:OldText(Text)
				self:SizeToContents()
			end
			Derma:SizeToContents()
		return Derma
	end
	
	function Singularity.MenuCore.PropertyGrid(Parent,Size,Spot)
		local Derma = vgui.Create( "DProperties",Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma.GetPParent = function() return Parent end
			Derma.GetPSize = function() return Size end
			Derma.GetPPos = function() return Spot end
		return Derma
	end
	
	function Singularity.MenuCore.CreateList(Parent,Size,Spot,Multi,Func)
		local Derma = vgui.Create( "DListView", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetMultiSelect(Multi)
			if Func then 
				Derma.OldThink = Derma.Think or function() end
				Derma.Think = function(self) 	
					if self:GetSelected() and self:GetSelected()[1] then 
						local selectedValue = self:GetSelected()[1]:GetValue(1) 
						if selectedValue ~= self.Selected then 
							self.Selected = selectedValue
							Func(selectedValue)
						end
					end 
					self:OldThink() 
				end 
			end
		return Derma
	end	
	
	function Singularity.MenuCore.CreateButton(Parent,Size,Spot,Text,OnClick)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetText( Text or "" )
			Derma.DoClick = OnClick or function() end
		return Derma
	end
	
	function Singularity.MenuCore.LoadWebpage(Parent,Size,Link)
		local label = vgui.Create("HTML",Parent)
		label:SetSize(Size.x, Size.y)
		label:OpenURL(Link)
		return label		
	end
	
	function Singularity.MenuCore.LoadHtml(Parent,Text)
		Singularity.Debug("Opening Url: "..Text,3,"MenuCore")
		local label = vgui.Create("HTML",Parent)
		label:SetSize(800, 200)
		label:OpenURL(Text)
		return label
	end
	
	---------------------------------------------------------------
	--------------Draw Library Related Functions-------------------
	---------------------------------------------------------------
	
	function Singularity.MenuCore.DrawRoundedBox(Size,Spot,Color,Sides)
		draw.RoundedBoxEx( Sides.R, Spot.x, Spot.y, Size.x, Size.y, Color, Sides.TL, Sides.TR, Sides.BL, Sides.BR )
	end
	
else
	----Server side-----

end