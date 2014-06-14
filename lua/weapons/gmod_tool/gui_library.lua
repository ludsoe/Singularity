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

if SERVER then
	util.AddNetworkString('Jupiter_loadBind')
	util.AddNetworkString('Jupiter_ToolBind')
	numpad.Register( "Jupiter_ToolBind", function ( ply )
		net.Start( "Jupiter_ToolBind" )
			local wep = ply:GetActiveWeapon()
			if wep:IsValid() then
				net.WriteString(wep:GetClass())
				net.WriteString(ply:GetInfo("gmod_toolmode"))
			end
		net.Send( ply )
		return true
	end )
	
	function Singularity.MT.BindHotKey(ply,Key)
		if Key and Key~=0 then
			numpad.Remove( Key )
			ply.OmniKeyBind = numpad.OnDown( ply, Key, "Jupiter_ToolBind")
		end
	end
	
	net.Receive("Jupiter_loadBind", function(length, client)
		local Key = net.ReadFloat() or 0
		Singularity.MT.BindHotKey(client,Key)
	end)
	
else
	function Singularity.MT.BindTool(Name,Data)
		local Tool = {}
		Tool.Open = function()
			local Mod = Singularity.MT.AddModular()
			Singularity.MT.ModAddButton(Mod,"Remove Bind",function() 
				Singularity.MT.Settings = {}
				Singularity.MT.SyncedSettings = {}
				
				if Data.C =="gmod_tool" then
					Singularity.MT.ToolBindings[Data.M]=nil
				else
					Singularity.MT.ToolBindings[Data.C]=nil
				end
				
				Singularity.MT.Tools[Name]=nil
				
				Singularity.MT.SelectedTool = ""
				Singularity.MT.ApplySettings() 
				
				Singularity.MT.OpenGui()	
			end)
		end
		if Data.C =="gmod_tool" then
			Tool.OnSync = function(ply)
				ply:ConCommand("gmod_tool "..Data.M)
			end
			Singularity.MT.ToolBindings[Data.M]={N=Name,D=Data}
		else
			Tool.OnSync = function(ply)
				ply:ConCommand("use "..Data.C)
			end	
			Singularity.MT.ToolBindings[Data.C]={N=Name,D=Data}			
		end
		Singularity.MT.Tools[Name]=Tool
	end
	
	net.Receive("Jupiter_ToolBind", function() 
		local Class,Mode = net.ReadString() or "",net.ReadString() or ""
		
		if Class == "gmod_tool" then
			if not Singularity.MT.ToolBindings[Mode] and Mode~="master_tool" then
				Singularity.MT.BindGui(Mode,{C=Class,M=Mode})
			else
				if Mode ~= "master_tool" then
					LocalPlayer():ConCommand("use gmod_tool")
					LocalPlayer():ConCommand("gmod_tool master_tool")	
				end
				Singularity.MT.OpenGui()
			end
		else
			if not Singularity.MT.ToolBindings[Class] then
				Singularity.MT.BindGui(Class,{C=Class,M=Mode})
			else
				LocalPlayer():ConCommand("use gmod_tool")
				LocalPlayer():ConCommand("gmod_tool master_tool")	
				Singularity.MT.OpenGui()
			end
		end
	end)
	
	Singularity.MT.LoadSettings()
end

function Singularity.MT.BindGui(Name,Data)
	local Super = {}
	
	if Singularity.MT.BindMenu then
		Singularity.MT.BindMenu.Base:Remove()
		Singularity.MT.BindMenu=nil
	end
	
	Base = Singularity.MenuCore.CreateFrame({x=200,y=120},true,false,false,true)
	Base:Center()
	Base:SetTitle( "Bind Tool: "..Name.."?")
	Base:MakePopup()
	Super.Base = Base
	
	local TextBar = Singularity.MenuCore.CreateTextBar(Base,{x=200,y=20},{x=0,y=30},Name,function(Text) Singularity.MT.BindText = Text end)
	
	local apply = Singularity.MenuCore.CreateButton(Base,{x=100,y=60},{x=0,y=60})
	apply:SetText( "Bind!" )
	apply.DoClick = function()
		Singularity.MT.BindTool((TextBar:GetValue() or Singularity.MT.BindText or Name),Data)
		LocalPlayer():ConCommand("use gmod_tool")
		LocalPlayer():ConCommand("gmod_tool master_tool")
		Singularity.MT.OpenGui()
		Singularity.MT.BindMenu.Base:Remove() 
	end
	
	local close = Singularity.MenuCore.CreateButton(Base,{x=100,y=60},{x=100,y=60})
	close:SetText( "Cancel!" )
	close.DoClick = function() 
		Singularity.MT.BindMenu.Base:Remove()
		Singularity.MT.BindMenu=nil
	end
	
	Singularity.MT.BindMenu = Super
end









