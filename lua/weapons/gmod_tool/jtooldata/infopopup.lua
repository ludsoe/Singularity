local PD = Singularity.PageData

PD.OnSelect=function(Base,Data,Table,Tab)
	local Info =  Table.Info
	
	for id, info in pairs( Tab ) do
		if IsValid(Tab[id]) then
			Tab[id]:Remove()
		end
		Tab[id]=nil
	end
	
	local X=135
	for id, info in pairs( Info ) do
		if info~= 0 then
			if Tab[id]==nil or not IsValid(Tab[id]) then
				Tab[id] = Singularity.MenuCore.CreateText(Base,{x=170,y=X},id..": "..info,Color(0,0,0,255))
				X=X+15
			else
			--	Tab[id]:SetText(id..": "..info)
			end
		end
	end
end

