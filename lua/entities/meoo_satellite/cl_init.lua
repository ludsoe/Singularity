include('shared.lua')

// Initialize

function ENT:Initialize()
	timer.Simple( 0.1, function() self.Scale = self:GetNWFloat("Scale") end)
end

// Draw

function ENT:Draw()
	self:DrawModel()
	--self:SetModelScale( self.Scale, 0 )

	if (self.Scale > 1) then
		local angles = self:GetAngles()
		local mins = self:OBBMins() * self.Scale
		local maxs = self:OBBMaxs() * self.Scale
		self:SetRenderBounds( mins, maxs )
	end
end