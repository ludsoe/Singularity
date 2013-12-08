include('shared.lua')

// Initialize

function ENT:Initialize()
	timer.Simple( 0.1, function() self.SkyScale = self:GetNWFloat("Scale") end)
end


function ENT:Draw()
	self:DrawModel()
	--self:SetModelScale(self.Scale,0 )

	if (self.SkyScale > 1) then
		local angles = self:GetAngles()
		local mins = self:OBBMins() * self.SkyScale
		local maxs = self:OBBMaxs() * self.SkyScale
		self:SetRenderBounds( mins, maxs )
	end
end