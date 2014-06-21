--[[------------------------------------------------------------------------------------------------------------------
	Rendering
------------------------------------------------------------------------------------------------------------------]]--
local NoDraw = {}
NoDraw["class C_PlayerResource"]=true
NoDraw["class C_GMODGameRulesProxy"]=true
NoDraw["sing_anchor"]=true
NoDraw["sing_spawn"]=true
NoDraw["class C_RopeKeyframe"]=true

function SubSpaces:SetEntityVisiblity( ent, subspace )
	if ( ent:EntIndex() < 0 or not ent:IsValid() ) then return end
	
	local visible = false
	
	local class = ent:GetClass()
	if NoDraw[class] then
		Visible=true
	else
		if ( ent:GetOwner():IsValid() ) then
			visible = ent:GetOwner():GetSubSpace() == subspace
		elseif ( ent:GetClass() == "class C_RopeKeyframe" ) then
			visible = ent:GetNWEntity( "CEnt", ent ):GetSubSpace() == subspace
		else
			visible = (ent:GetSubSpace() == subspace)
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





