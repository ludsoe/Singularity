
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
		local txt = "[ "..TraceEnt:GetClass().." ]\n"
		local Changed = false
		
		Singularity.TraceEnt=TraceEnt
		
		if TraceEnt.ExtraBubble then
			for n, ex in pairs( TraceEnt.ExtraBubble ) do
				txt = txt..n..": "..ex
				Changed = true
			end			
		end
		
		if TraceEnt.WorldBubble and not Changed then
			txt = TraceEnt:WorldBubble(Trace,Pos)
			Changed = true
		end
		
		if Changed then
			AddWorldTip(1,txt,1,Pos,NULL)
		end
	else
		Singularity.TraceEnt = nil
    end
end
hook.Add("Think", "GetWorldTips", GetWorldTips)