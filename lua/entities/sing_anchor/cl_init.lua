include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.SyncData = {}
end

function ENT:GetData(Data)
	if self.SyncData[Data] then
		return self.SyncData[Data]
	end
	return 0
end

function ENT:Draw()
	return false
end

