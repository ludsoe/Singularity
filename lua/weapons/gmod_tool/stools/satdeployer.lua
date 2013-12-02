TOOL.Category    = "~Meoowe"
TOOL.Name        = "#Satellite Deployer Tool"
TOOL.Command     = nil
TOOL.ConfigName  = ""

// ConVars

TOOL.ClientConVar["red"] = "255"
TOOL.ClientConVar["green"] = "255"
TOOL.ClientConVar["blue"] = "255"
TOOL.ClientConVar["scale"] = "1"
TOOL.ClientConVar["time"] = "10"

// Client

if (CLIENT) then
	// Tool
	
	language.Add("Tool.satdeployer.name", "Satellite Deployer Tool")
	language.Add("Tool.satdeployer.desc", "Create your own planet :) Admin Only")
	language.Add("Tool.satdeployer.0", "Left click to spawn a Deployer, Right click to update")
end

// Left click

function TOOL:LeftClick(Trace)
	local tr = self:GetOwner():GetEyeTrace()
	
	
	if ( not tr.Hit or tr.HitWorld) then return false end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		Singularity.Universe.GeneratePlanet(SpawnPos,self:GetClientNumber("scale"),self:GetOwner():GetSubSpace(),{Color=Color(self:GetClientNumber("red"),self:GetClientNumber("green"),self:GetClientNumber("blue"),255)})
	return true
end

// Right click

function TOOL:RightClick(Trace)
end

// Control panel

function TOOL.BuildCPanel(Panel)
	Panel:AddControl("Header", {Text = "#Tool.satdeployer.name", Description = "#Tool.satdeployer.desc"})
	
	Panel:AddControl("Slider", {Label = "Red", Type = "Integer", Min = 0, Max = 255, Command = "satdeployer_red"})
	Panel:AddControl("Slider", {Label = "Green", Type = "Integer", Min = 0, Max = 255, Command = "satdeployer_green"})
	Panel:AddControl("Slider", {Label = "Blue", Type = "Integer", Min = 0, Max = 255, Command = "satdeployer_blue"})
	Panel:AddControl("Slider", {Label = "Scale", Type = "Float", Min = 0.3, Max = 3, Command = "satdeployer_scale"})
	Panel:AddControl("Slider", {Label = "Time", Type = "Integer", Min = 3, Max = 30, Command = "satdeployer_time"})
end