
TOOL.Category = "Construction"
TOOL.Name = "#Localizer"
TOOL.Command = nil
TOOL.ConfigName = ""

if ( CLIENT ) then
	language.Add( "Tool.localizer.name", "Localizer" )
	language.Add( "Tool.localizer.desc", "Localises props and prints to console." )
	language.Add( "Tool.localizer.0", "Left click a entity to localise all its constraints." )
end 

function TOOL:LeftClick( tr )
	if ( not tr.Entity:IsValid() ) then return false end
	if ( CLIENT ) then return true end
	
	local Data = Singularity.Persistance:GetShipData(tr.Entity) 
	--Singularity.Persistance:LoadFromData(Vector(0,0,0),Data)
	local Str=util.TableToJSON(Data)
	file.Append( "localiseoutput.txt", Str )
	return true
end

function TOOL:RightClick( tr )
end

