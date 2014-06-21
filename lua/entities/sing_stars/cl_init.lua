include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	local Scale = -100000*(1/SubSpaces.Scale)
	
	local mat = Matrix()
	mat:Scale(Vector(Scale,Scale,Scale))
	self:EnableMatrix("RenderMultiply", mat)
	
	self.MyDraw = self.Draw
	
	self.Draw = function(self,NoDraw)
		render.OverrideDepthEnable( true, false )
		self:MyDraw()
		render.OverrideDepthEnable( false, true )
	end
end

function ENT:Think()
	self:SetAngles(-LocalPlayer():GetUniAng())
end


--function ENT:Draw()
--	return false
--end

