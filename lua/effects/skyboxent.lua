/*
3:55 PM - Ludsoe: SubSpaces.GetSubSpaceTable(ent:GetSubSpace()).Anchor
3:55 PM - Ludsoe: to grab the anchor entity of ent
3:55 PM - Ludsoe: of the subspace ent is in
3:55 PM - Ludsoe: *
3:55 PM - Christopher Columbutts: that confuses the hell out of me
3:56 PM - Ludsoe: nah its simple
3:56 PM - Ludsoe: SubSpaces.GetSubSpaceTable(ent:GetSubSpace()) gets the subspace table
3:56 PM - Ludsoe: ent:GetSubSpace() gets the subspace
3:56 PM - Ludsoe: the .Anchor at the end is reading into the table getsubspacetable returns
3:57 PM - Ludsoe: example is local Anchor = SubSpaces.GetSubSpaceTable(ent:GetSubSpace()).Anchor
3:58 PM - Ludsoe: then you can call Anchor:WorldToLocalAngles(ent:GetAngles())

*/


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
	
	local Mod,Pos,Type,Ang = ent:GetModel(),ent:GetPos(),ent:GetClass(),ent:GetAngles()
	if(not Mod or Mod=="")then return end
	if(not self:IsGood(Type))then return end
	
	local SubPos = ent:GetUniPos()-LocalPlayer():GetUniPos()
	if(SubPos.X>13 or SubPos.Y>13 or SubPos.Z>13)then return end --Dont render it if its too far to view.
	
	local SubAng,PlyAng = ent:GetUniAng(),LocalPlayer():GetUniAng() //ent:GetUniAng() Returns ent subspace angle
	local Anchor = SubSpaces.GetSubSpaceEntity(ent:GetSubSpace())
	if not IsValid(Anchor) then return end
	
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
	
	--Pos:Rotate(SubAng-PlyAng)
	Pos=Anchor:LocalToWorld(Pos)
		
	SubPos:Rotate(PlyAng)
	local Spot = ((Pos+(SubSpaces.MapSize*SubPos))/SubSpaces.Scale)
	
	--print(tostring(Spot))
	
	self:SetPos(SubSpaces.SkyBox+Spot)
end

function EFFECT:Think()
	return false
end
