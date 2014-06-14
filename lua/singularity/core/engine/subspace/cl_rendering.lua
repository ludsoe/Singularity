--[[------------------------------------------------------------------------------------------------------------------
	Rendering
------------------------------------------------------------------------------------------------------------------]]--
local NoDraw,Logged = {},{}
NoDraw["class C_PlayerResource"]=true
NoDraw["class C_GMODGameRulesProxy"]=true
NoDraw["sing_anchor"]=true
NoDraw["sing_spawn"]=true
function SubSpaces:SetEntityVisiblity( ent, subspace )
	if ( ent:EntIndex() < 0 or not ent:IsValid() ) then return end
	
	local visible = false
	
	if ( ent:GetOwner():IsValid() ) then
		visible = ent:GetOwner():GetSubSpace() == subspace
	elseif ( ent:GetClass() == "class C_RopeKeyframe" ) then
		visible = ent:GetNWEntity( "CEnt", ent ):GetSubSpace() == subspace
	else
		visible = (ent:GetSubSpace() == subspace)
	end
	
	local class = ent:GetClass()
	if ( class == "class C_RopeKeyframe" ) then
		if ( visible ) then
			ent:SetColor( 255, 255, 255, 255 )
		else
			ent:SetColor( 255, 255, 255, 0 )
		end
	else
		if NoDraw[class] then
			Visible=true
		else
			if not visible then
				if not SubSpaces.SubSpaceTab(ent:GetSubSpace() or "").NoEffect then 
					local effectdata = EffectData()
					effectdata:SetEntity( ent )
					util.Effect( "skyboxent", effectdata )
				end
			end
		end
		ent:SetNoDraw( not visible ) --Make it invisible.
	end
end

function SubSpaces.RenderEntities()
	local localLayer = LocalPlayer():GetViewSubSpace()	
	for _, ent in ipairs( ents.GetAll() ) do
		SubSpaces:SetEntityVisiblity( ent, localLayer )			
	end
	--util.Effect( "starmeshent", EffectData() )
end
hook.Add( "RenderScene", "SingularityEntityDrawing", SubSpaces.RenderEntities )






