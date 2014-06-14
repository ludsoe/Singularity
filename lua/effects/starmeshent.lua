function EFFECT:Init(data)		
	--self:SetModel("models/hunter/misc/shell2x2.mdl")
	self:SetModel("models/hunter/misc/sphere2x2.mdl")
	self:SetAngles(LocalPlayer():GetUniAng())
	self:SetMaterial("skybox/sky_space_01up")
	
	local Scale = -100000*(1/SubSpaces.Scale)
	
	local mat = Matrix()
	mat:Scale(Vector(Scale,Scale,Scale))
	self:EnableMatrix("RenderMultiply", mat)
	
	self:SetPos(SubSpaces.SkyBox)
	
end

function EFFECT:Think()
	return false
end
