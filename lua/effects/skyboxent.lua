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
	local SubAng,PlyAng = ent:GetUniAng(),LocalPlayer():GetUniAng() //ent:GetUniAng() Returns ent subspace angle
	
	if(SubPos.X>13 or SubPos.Y>13 or SubPos.Z>13)then return end --Dont render it if its too far to view.
	
	//local Anchor = SubSpaces.GetSubSpaceTable(ent:GetSubSpace()).Anchor

	
	self:SetModel(Mod)
	//self:SetAngles(Anchor:WorldToLocalAngles(ent:GetAngles())+(SubAng-PlyAng))

	self:SetAngles( Angle(0,0,-45)   ) //ent:GetAngles()    )// ent:WorldToLocalAngles(SubAng-PlyAng)) -6,-133,-6 -38,-133,27
	self:SetSkin(ent:GetSkin())
	self:SetColor(ent:GetColor())
	
	/*
	if(Mod == "models/hunter/triangles/2x2.mdl") then 
		print("DEBUG: Model = ["..Mod.."] SubAng = ["..tostring(SubAng).."] PlyAng = ["..tostring(PlyAng).."] Ang ["..tostring(Ang).."]")
	end
	*/
	local Scale = (ent.SkyScale or 1)*(1/SubSpaces.Scale)
	
	
	local mat = Matrix()
	mat:Scale(Vector(Scale,Scale,Scale))
	self:EnableMatrix("RenderMultiply", mat)

	Pos:Rotate(SubAng-PlyAng)
	SubPos:Rotate(PlyAng)
	local Spot = ((Pos+(SubSpaces.MapSize*SubPos))/SubSpaces.Scale)
	
	--print(tostring(Spot))
	
	self:SetPos(SubSpaces.SkyBox+Spot)
end

function EFFECT:Think()
	return false
end
