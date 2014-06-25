
local Singularity = Singularity

local Sync = function()
	local Ent,Table = net.ReadEntity(),util.JSONToTable(net.ReadString())
	Ent.SyncData = table.Merge(Ent.SyncData or {},Table)
end
net.Receive( "JupiterCoreSync", Sync)

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