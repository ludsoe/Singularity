
function EFFECT:Init(data)
	
	local ent = data:GetEntity()
	
	if(not ent or not ent:IsValid())then return end
	
	local Mod,Pos = ent:GetModel(),ent:GetPos()
	
	if(not Mod or Mod=="" or not util.IsValidProp(Model(Mod)))then return end
	
	self:SetModel(Mod)
	self:SetAngles(ent:GetAngles())
	self:SetSkin(ent:GetSkin())
	self:SetColor(ent:GetColor())
	self:SetModelScale(1/128,0)

	local SubPos = ent:GetUniPos()-LocalPlayer():GetUniPos()
	self:SetPos(SubSpaces.SkyBox+(Pos+(SubSpaces.MapSize*SubPos))/128)
	
end

function EFFECT:Think()
	return false
end
