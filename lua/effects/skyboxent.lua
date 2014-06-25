function EFFECT:Init(data)
	
	local Invisible = function(self) self:SetColor(Color(0,0,0,0)) end
	
	local ent = data:GetEntity()
	if(not ent or not ent:IsValid())then Invisible(self) return end
	
	local Mod,Pos,Type,Ang = ent:GetModel(),ent:GetPos(),ent:GetClass(),ent:GetAngles()
	if(not Mod or Mod=="")then Invisible(self) return end
	
	local SubPos = ent:GetUniPos()-LocalPlayer():GetUniPos()
	
	local SubAng,PlyAng = ent:GetUniAng(),LocalPlayer():GetUniAng() //ent:GetUniAng() Returns ent subspace angle
	local Anchor = SubSpaces.GetSubSpaceEntity(ent:GetSubSpace())
	if not IsValid(Anchor) then Invisible(self) return end
	
	Anchor:SetAngles(SubAng-PlyAng)
	
	self:SetModel(Mod)
	
	local Angles = Anchor:LocalToWorldAngles(ent:GetAngles())
		
	self:SetAngles(Angles)
	self:SetSkin(ent:GetSkin())
	self:SetColor(ent:GetColor())
	
	local Scale = (ent.SkyScale or 1)*(1/SubSpaces.Scale)
	
	local mat = Matrix()
	mat:Scale(Vector(Scale,Scale,Scale))
	self:EnableMatrix("RenderMultiply", mat)
	
	Pos=Anchor:LocalToWorld(Pos)
	
	SubPos:Rotate(-PlyAng)
	local Spot = (Pos+SubPos)/SubSpaces.Scale
		
	self:SetPos(SubSpaces.SkyBox+Spot)
end

function EFFECT:Think()
	return false
end
