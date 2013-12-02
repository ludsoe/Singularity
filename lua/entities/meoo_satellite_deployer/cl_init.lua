include('shared.lua')

// Draw

function ENT:Draw()
	--self:DrawEntityOutline( 1.0 )
	self:DrawModel()
	local tr = LocalPlayer():GetEyeTrace()
	if(tr.Entity:IsValid() and tr.Entity == self) then
		if(self:GetNWFloat("time") > 0) then
			AddWorldTip( self:EntIndex(), tostring("Deployment in "..math.Round(self:GetNWFloat("time"))), 0.5, self:GetPos(), self )
		else
			AddWorldTip( self:EntIndex(), "Ready", 0.5, self:GetPos(), self )
		end
	end
end 