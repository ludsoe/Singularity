local ENT,PLY = FindMetaTable( "Entity" ),FindMetaTable( "Player" )


--[[------------------------------------------------------------------------------------------------------------------
	Trace modification
------------------------------------------------------------------------------------------------------------------]]--

if(not SubSpaces.OriginalTraceLine)then SubSpaces.OriginalTraceLine = util.TraceLine end
function util.TraceLine( td, subspace )
	if not subspace then if(SERVER)then subspace = "Global" else subspace = LocalPlayer():GetSubSpace() end end
	local originalResult = SubSpaces.OriginalTraceLine( td )
	if not IsValid(originalResult.Entity) or originalResult.Entity:GetSubSpace() == subspace or subspace=="Global") then
		return originalResult
	else
		if ( td.filter ) then
			if ( type( td.filter ) == "table" ) then
				table.insert( td.filter, originalResult.Entity )
			else
				td.filter = { td.filter, originalResult.Entity }
			end
		else
			td.filter = originalResult.Entity
		end
		
		return util.TraceLine( td )
	end
end

if not SubSpaces.OriginalPlayerTrace then SubSpaces.OriginalPlayerTrace = util.GetPlayerTrace end
function util.GetPlayerTrace( ply, dir )
	local originalResult = SubSpaces.OriginalPlayerTrace( ply, dir )
	originalResult.filter = { ply }
	
	for _, ent in ipairs( ents.GetAll() ) do
		if ent:GetSubSpace() ~= ply:GetSubSpace() then
			table.insert( originalResult.filter, ent )
		end
	end
	
	return originalResult
end

if not SubSpaces.OriginalEyeTrace then SubSpaces.OriginalEyeTrace = PLY.GetEyeTrace end
function PLY:GetEyeTrace()
	local Table = util.GetPlayerTrace( self, self:GetAimVector() )
	
	return  util.TraceLine( Table, self:GetSubSpace() )
end

if(SERVER)then
	if not SubSpaces.OldSetViewEntity then SubSpaces.OldSetViewEntity = PLY.SetViewEntity end
	function PLY:SetViewEntity( ent )
		self:SetViewSubSpace( ent:GetSubSpace() )
		return SubSpaces.OldSetViewEntity( self, ent )
	end
		
	if not SubSpaces.OriginalAddCount then SubSpaces.OriginalAddCount = PLY.AddCount end
	function PLY:AddCount( type, ent )
		ent:SetSubSpace( self:GetSubSpace() )
		return SubSpaces.OriginalAddCount( self, type, ent )
	end
	
	if not SubSpaces.OriginalCleanup then SubSpaces.OriginalCleanup = cleanup.Add end
	function cleanup.Add( ply, type, ent )
		if ( ent ) then ent:SetSubSpace( ply:GetSubSpace() ) end
		return SubSpaces.OriginalCleanup( ply, type, ent )
	end		
else
	if not SubSpaces.oldEmitSound then SubSpaces.oldEmitSound = ENT.EmitSound end
	function ENT:EmitSound( filename, soundlevel, pitchpercent )
		if LocalPlayer():GetSubSpace() ~= self:GetSubSpace() then return end
		
		SubSpaces.oldEmitSound( self, filename, soundlevel, pitchpercent )
	end
end		 
