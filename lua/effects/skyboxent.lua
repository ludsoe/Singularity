
local BadTypes = {"sing_playerspawn","class","C_"}


function EFFECT:IsGood(T)
	for _,b in pairs(BadTypes) do
		if(string.find(T,b))then
			return false
		end
	end
	return true
end

function EFFECT:Init(data)
	
	local ent = data:GetEntity()
	--print(tostring(ent))
	if(not ent or not ent:IsValid())then return end
	
	local Mod,Pos,Type = ent:GetModel(),ent:GetPos(),ent:GetClass()
	if(not Mod or Mod=="")then return end
	if(not self:IsGood(Type))then return end
	
	local SubPos = ent:GetUniPos()-LocalPlayer():GetUniPos()
	
	if(SubPos.X>13 or SubPos.Y>13 or SubPos.Z>13)then return end --Dont render it if its too far to view.
	
	self:SetModel(Mod)
	self:SetAngles(ent:GetAngles())
	self:SetSkin(ent:GetSkin())
	self:SetColor(ent:GetColor())
	
	local Scale = 1/SubSpaces.Scale
	if(ent.Scale)then
		Scale = (ent.Scale*10)/SubSpaces.Scale
	end
	self:SetModelScale(Scale,0)
	
	local Spot = (Pos+((SubSpaces.MapSize*1.5)*SubPos))/SubSpaces.Scale
	
	--print(tostring(Spot))
	
	self:SetPos(SubSpaces.SkyBox+Spot)
end

function EFFECT:Think()
	return false
end
