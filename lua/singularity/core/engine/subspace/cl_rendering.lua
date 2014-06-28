--[[------------------------------------------------------------------------------------------------------------------
	Rendering
------------------------------------------------------------------------------------------------------------------]]--
local NR,IG = Singularity.NoRender,Singularity.IgnoreClasses

function SubSpaces:SetEntityVisiblity( ent, subspace )
	if ent:EntIndex() < 0 or not ent:IsValid() then return end
	if ent.StarField then return end --Dont touch the space background
	
	local visible = false
	
	local class = ent:GetClass()
	if NR[class] or IG[class] then
		Visible=true
	else
		if IsValid(ent:GetOwner()) then
			visible = ent:GetOwner():GetSubSpace() == subspace
		else
			visible = ent:GetSubSpace() == subspace
		end
		
		if not visible then
			if not SubSpaces.SubSpaceTab(ent:GetSubSpace() or "").DryDock then 
				local effectdata = EffectData()
				effectdata:SetEntity( ent )
				util.Effect( "skyboxent", effectdata )
			end
		end
	end
	ent:SetNoDraw( not visible ) --Make it invisible.
end

function SubSpaces.RenderEntities()
	local localLayer = LocalPlayer():GetViewSubSpace()	
	for _, ent in ipairs( ents.GetAll() ) do
		SubSpaces:SetEntityVisiblity( ent, localLayer )			
	end
	--util.Effect( "starmeshent", EffectData() )
end
hook.Add( "RenderScene", "SingularityEntityDrawing", SubSpaces.RenderEntities )





