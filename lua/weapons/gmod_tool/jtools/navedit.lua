local Tool = {}

local Commands = {
	"nav_mark",
	"nav_merge",
	"nav_splice",
	"nav_split",
	"nav_connect",
	"nav_disconnect",
	"nav_avoid",
	"nav_delete",
	"nav_delete_marked",
	"nav_mark_walkable",
	"nav_save",
	"nav_begin_area",
	"nav_end_area"
}

Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	
	local OnSelect = function(Data)
		Tab.Server.Selected = Data
		Tab.Selected = Data	
	end	
	
	local List = Singularity.MenuCore.CreateList(Menu,{x=150,y=325},{x=0,y=0},false,OnSelect)
	List:AddColumn("Selection") -- Add column

	for k,v in pairs(Commands) do
		List:AddLine(v)
	end
	
	Tab.Save = Tab.Save or ToolProps
	
	if Tab.Selected or "" ~= "" then OnSelect(Tab.Selected) end
end --This is clientside only, called when the tool is selected.

Tool.Primary = function(trace,ply,Settings)
	if not Settings.Selected then return end
	
	ply:ConCommand( Settings.Selected )
	
	return true
end

Tool.Secondary = function(trace,ply,Settings)
	return true
end

Tool.Think = function(ply,Settings) end --Think Function use CLIENT and SERVER to create client and server only thinks.
Singularity.MT.AddTool("Nav Mesh Edit",Tool)

