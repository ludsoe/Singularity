
function EFFECT:Init(data)
	
	local ent = data:GetEntity()
	
	if(not ent or not ent:IsValid())then return end
	
	local Mod,Pos = ent:GetModel(),ent:GetPos()
	if(not Mod or Mod=="" or not util.IsValidProp(Model(Mod)))then return end
	local SubPos = ent:GetUniPos()-LocalPlayer():GetUniPos()
	
	if(SubPos.X>13 or SubPos.Y>13 or SubPos.Z>13)then return end --Dont render it if its too far to view.
	
	self:SetModel(Mod)
	self:SetAngles(ent:GetAngles())
	self:SetSkin(ent:GetSkin())
	self:SetColor(ent:GetColor())
	self:SetModelScale(1/128,0)

	self:SetPos(SubSpaces.SkyBox+(Pos+(SubSpaces.MapSize*SubPos))/128)
	
end

function EFFECT:Think()
	return false
end
