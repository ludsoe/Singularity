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
	
	print("Click")
	
	if ( not tr.Hit or tr.HitWorld) then return false end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create( "meoo_satellite_deployer" )
		print("Click2")
		ent:SetPos( SpawnPos )
		ent:SetAngles( Angle( 0, 0, 0 ) )
		ent:SetColor(Color(self:GetClientNumber("red"),self:GetClientNumber("green"),self:GetClientNumber("blue"),255))
		ent:Spawn()
		ent:Activate()
		ent.Scale = self:GetClientNumber("scale")
		ent.Time = self:GetClientNumber("time")
	return true
end

// Right click

function TOOL:RightClick(Trace)
	local tr = self:GetOwner():GetEyeTrace()
	if ( !tr.Hit or tr.HitWorld or !self:GetOwner():IsAdmin() ) then return false end
	if ( tr.Entity:IsValid() and tr.Entity:GetClass() == "meoo_satellite_deployer" ) then
		tr.Entity:SetColor(Color(self:GetClientNumber("red"),self:GetClientNumber("green"),self:GetClientNumber("blue"),255))
		tr.Entity.Scale = self:GetClientNumber("scale")
		tr.Entity.Time = self:GetClientNumber("time")
		return true	
	end
	return false
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