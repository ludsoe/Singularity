local Singularity = Singularity
Singularity.MT = Singularity.MT or {}
Singularity.MT.Tools = Singularity.MT.Tools or {}
Singularity.MT.Settings = Singularity.MT.Settings or {}
Singularity.MT.SyncedSettings = Singularity.MT.SyncedSettings or {}
Singularity.MT.ToolBindings = Singularity.MT.ToolBindings or {}
Singularity.MT.SelectedTool = Singularity.MT.SelectedTool or ""
Singularity.MT.OldSelected = Singularity.MT.OldSelected or ""

local SettingsName = "jupiteromnitool.txt"

function Singularity.MT.SaveSettings() 
	local Data = {Settings=Singularity.MT.Settings,Bindings=Singularity.MT.ToolBindings}
	local File =  util.TableToJSON(Data)
	file.Write(SettingsName,File)
end

function Singularity.MT.LoadSettings()
	if file.Exists(SettingsName,"DATA") then
		local File = file.Read(SettingsName,"DATA")
		if File == "" then print("ERROR! File Is Blank!") file.Delete(SettingsName) return end
		local Data = util.JSONToTable(File)
		Singularity.MT.Settings = Data.Settings
		for k,v in pairs(Data.Bindings) do
			Singularity.MT.BindTool(v.N,v.D)
		end
		
		timer.Simple(0.4,function() 
			net.Start( "Jupiter_loadBind" )
				net.WriteFloat(Data.Settings.KeyBind or 0)
			net.SendToServer()
		end)
		print("Settings Loaded!")
	end
end

function Singularity.MT.ApplySettings()
	local Tool = Singularity.MT.SelectedTool
	local Table = Singularity.MT.GetSettings(Tool)
	
	if Table.Propertys then
		Table.Server.Propertys={}
		local Grid = Table.PropGrid
		for k,v in pairs(Table.Propertys) do
			local Prop = v.Value
			Table.Server.Propertys[k]=Prop
		end
	end
	
	local Data = util.TableToJSON(Table.Server) or ""
	net.Start('Jupiter_ToolSelect')
		net.WriteString(Tool)
		net.WriteString(Data)
	net.SendToServer()
		
	if Tool~=Singularity.MT.OldSelected then
		Singularity.MT.OldSelected = Tool
		HolsterTool(Singularity.MT.OldSelected)
	end
	
	Singularity.MT.SyncedSettings = table.Copy(Singularity.MT.Settings)
	Singularity.MT.SaveSettings() --Save the settings!
	
	local OnSync = Singularity.MT.Tools[Tool]
	if OnSync and OnSync.OnSync then
		OnSync.OnSync(LocalPlayer(),Table)
	end
end

function Singularity.MT.GetSettings(Tool)
	if not Singularity.MT.Settings[Tool] then 
		Singularity.MT.Settings[Tool] = {Server={}}
	end
	return Singularity.MT.Settings[Tool]
end

function Singularity.MT.OpenGui()
	local Super = {}
	
	if Singularity.MT.GuiMenu then
		Singularity.MT.GuiMenu.Base:Remove()
		Singularity.MT.GuiMenu=nil
	end	
	
	Base = Singularity.MenuCore.CreateFrame({x=700,y=400},true,false,false,true)
	Base:Center()
	Base:SetTitle( "Jupiter OmniTool" )
	Base:MakePopup()
	Super.Base = Base
	
	local OnSelect = function(Data)
		if Singularity.MT.GuiMenu.Panel and Singularity.MT.GuiMenu.Panel:IsValid() then Singularity.MT.GuiMenu.Panel:Remove() end
		local Panel = Singularity.MenuCore.CreatePanel(Singularity.MT.GuiMenu.Base,{x=520,y=355},{x=170,y=35})
		Panel.Offset = 0
		Singularity.MT.GuiMenu.Panel = Panel
		Singularity.MT.SelectedTool = Data
		Singularity.MT.Tools[Data].Open(Panel,Singularity.MT.GetSettings(Data))
	end
	
	local menupage = Singularity.MenuCore.CreateList(Base,{x=150,y=300},{x=10,y=35},false,OnSelect)
	menupage:AddColumn("Tool Mode") -- Add column
	Super.Pages = menupage

	for k,v in pairs(Singularity.MT.Tools) do
		menupage:AddLine(k)
	end
	
	local apply = Singularity.MenuCore.CreateButton(Base,{x=150,y=40},{x=10,y=345})
	apply:SetText( "Apply" )
	apply.DoClick = function() Singularity.MT.ApplySettings() Singularity.MT.GuiMenu.Base:Remove() end

	Singularity.MT.GuiMenu = Super
		
	if Singularity.MT.SelectedTool ~= "" then OnSelect(Singularity.MT.SelectedTool) end
end

function Singularity.MT.AddTool(Name,Func)
	Singularity.MT.Tools[Name]=Func
end

function Singularity.MT.AddList(Title,Options,OnSelect)
	local Panel = Singularity.MT.GuiMenu.Panel
	local IC = Panel.Offset
	
	local List = Singularity.MenuCore.CreateList(Panel,{x=150,y=355},{x=(IC),y=0},false,OnSelect)
	List:AddColumn(Title) -- Add column

	for k,v in pairs(Options) do
		List:AddLine(k)
	end
	
	Panel.Offset = IC+160
	
	return List
end

function Singularity.MT.AddModular()
	local Panel = Singularity.MT.GuiMenu.Panel
	local IC = Panel.Offset
	local Save = {}
	
	local Paint  = function()
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, Save:GetWide(), Save:GetTall() )
	end
	Save=Singularity.MenuCore.CreatePanel(Panel,{x=280,y=355},{x=(IC),y=0})
	Save.IsModular = true
	Save.Offset = 0
	Save.Paint = Paint
	
	Panel.Offset = IC+290
	
	return Save
end

function Singularity.MT.ModAddModel(Panel,Model)
	if not Panel.IsModular then return end --Y U DO DIS!!??!?!
	local ModelDisplay = Singularity.MenuCore.DisplayModel(Panel,120,{x=60,y=Panel.Offset},Model or "models/maxofs2d/logo_gmod_b.mdl",80,10)
	
	Panel.Offset=Panel.Offset+120
	
	return ModelDisplay
end

function Singularity.MT.ModAddlabel(Panel,Text,Offset)
	if not Panel.IsModular then return end --Y U DO DIS!!??!?!
	local Label = Singularity.MenuCore.CreateText(Panel,{x=Offset or 60,y=Panel.Offset},Text,Color(0,0,0,255))
	Panel.Offset=Panel.Offset+20
	return Label
end

function Singularity.MT.ModAddButton(Panel,Text,Func)
	if not Panel.IsModular then return end --Y U DO DIS!!??!?!
	local Button = Singularity.MenuCore.CreateButton(Panel,{x=280,y=40},{x=0,y=Panel.Offset},Text,Func)
	Panel.Offset=Panel.Offset+40
	return Button
end

function Singularity.MT.ModAddBindable(Panel,Func)
	if not Panel.IsModular then return end --Y U DO DIS!!??!?!
	local DBinder = vgui.Create( "DBinder",Panel )
	DBinder :SetPos( 0, Panel.Offset )
	DBinder :SetSize( 280, 40 )
	
	DBinder.OldThink = DBinder.Think
	DBinder.Think = function(self)
		local Value = self:GetValue() or 0
		if Value~=0 and Value ~= self.OldValue then
			self.OldValue = Value
			if Func then
				Func(Value)
			end
		end
		self:OldThink()
	end
	
	Panel.Offset=Panel.Offset+40
	return DBinder
end

function Singularity.MT.ModUpdSettings(Panel,Data,clear)
	if not Panel.IsPropGrid then return end --Y U DO DIS!!??!?!
	
	if clear then
		local Par,Pos,Size = Panel:GetPParent(),Panel:GetPPos(),Panel:GetPSize()
		Panel:Remove()
		
		Panel = Singularity.MenuCore.PropertyGrid(Par,Size,Pos)
		Panel.IsPropGrid = true
	end
	
	local Rows = {}
	if Data then
		for Cat,tab in pairs(Data) do
			for k,v in pairs(tab) do
				local Row = Panel:CreateRow( Cat or "Error", v.ID or "Error" )
				Row:Setup(v.Type or "Boolean")
				if v.Type == "Boolean" then
					Row:SetValue(tobool(v.Value))
				else
					Row:SetValue(v.Value or false)
				end
				Row.Value = {T=v.Type,V=v.Value or false}
				
				--HACK
				Row.Inner.ValueChanged = function( self, newval, bForce )
					Row.Value.V = newval
					Data[Cat][k].Value = newval
				end
				
				Rows[k]=Row
			end
		end
	end
	return Panel,Rows
end

function Singularity.MT.ModAddSettings(Panel,Height,Data)
	if not Panel.IsModular then return end --Y U DO DIS!!??!?!
	
	local Grid = Singularity.MenuCore.PropertyGrid(Panel,{x=280,y=Height},{x=0,y=Panel.Offset})
	Grid.IsPropGrid = true
	
	Singularity.MT.ModUpdSettings(Grid,Data)
	
	Panel.Offset=Panel.Offset+Height
	return Grid 
end







