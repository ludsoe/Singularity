include('shared.lua')

// Initialize

function ENT:Initialize()
	timer.Simple( 0.1, function() self.Scale = self:GetNWFloat("Scale") end)
end

