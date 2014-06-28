local Singularity = Singularity
local Utl = Singularity.Utl --Makes it easier to read the code.

Utl:HookNet("SingularityCoreSync","",function(D) D.E.SyncData = table.Merge(D.E.SyncData or {},D.T) end)
	
function GetWorldTips()
	local Trace = LocalPlayer():GetEyeTrace()
	local Pos = Trace.HitPos
	if EyePos():Distance(Pos) < 512 then
		local TraceEnt = Trace.Entity
		Singularity.TraceEnt=TraceEnt
		
		if TraceEnt.WorldBubble then
			AddWorldTip(1,TraceEnt:WorldBubble(Trace,Pos),1,Pos,NULL)
		end
	else
		Singularity.TraceEnt = nil
    end
end
hook.Add("Think", "GetWorldTips", GetWorldTips)