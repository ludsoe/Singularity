ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ship Module"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsModule = true
ENT.InitData = {}
ENT.ModuleData = {}
ENT.ClientSide = false

function ENT:GetPriority()
	local Priority = 1
	
	if self.IsReactor then Priority = 1000 end
	
	return Priority
end
