local Tool = {}
Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	local Mod = Singularity.MT.AddModular()
	Tab.Save = Tab.Save or {}
	
	Singularity.MT.ModAddButton(Mod,"Reset Tool",function() 
		--Clear out the settings table
		--Singularity.MT.Tools = {}
		Singularity.MT.Settings = {}
		Singularity.MT.SyncedSettings = {}
		Singularity.MT.SelectedTool = ""
		
		--Sync the reset to the server
		Singularity.MT.ApplySettings() 
		Singularity.MT.GuiMenu.Base:Remove()
	end)
end --This is clientside only, called when the tool is selected.

Tool.OnSync = function(ply,Settings)
	if SERVER then
		Singularity.MT.BindHotKey(ply,Settings.Key)
	end
end

Singularity.MT.AddTool("Settings",Tool)





















