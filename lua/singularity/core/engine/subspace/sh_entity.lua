local ENT,PLY = FindMetaTable( "Entity" ),FindMetaTable( "Player" )


--[[------------------------------------------------------------------------------------------------------------------
	Basic set and get subspace functions
------------------------------------------------------------------------------------------------------------------]]--

function ENT:SetSubSpace( subspace )
	local OldSub = self:GetSubSpace()
	if(OldSub==subspace)then return end --Dont run if were trying to change to the same subspace

	if(OldSub~="")then
		SubSpaces.SubSpaces[OldSub].Entitys[self:EntIndex()]=nil
	end
	SubSpaces.SubSpaces[subspace].Entitys[self:EntIndex()]=self

	self:SetNWString( "SubSpace", subspace )
	if ( !self.UsingCamera ) then self:SetViewSubSpace( subspace ) end
end

function ENT:SetViewSubSpace( subspace )
	self:SetNWString( "ViewSubSpace", subspace )
end

function ENT:GetSubSpace()
	return self:GetNWString( "SubSpace", "" )
end

function ENT:GetUniPos()
	return SubSpaces.SubSpacePos(self:GetSubSpace())
end

function ENT:GetUniAng()
	return SubSpaces.SubSpaceAng(self:GetSubSpace())
end
		
function ENT:GetViewSubSpace()
	return self:GetNWString("ViewSubSpace",SubSpaces.MainSpace)
end
