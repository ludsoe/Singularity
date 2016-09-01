-- 0 Client 1 Shared 2 Server
function Singularity.LoadFile(Path,Mode,Print)
	xpcall(function()
		Mode=Mode or 1
		if SERVER then
			if Mode >= 1 then
				include(Path)
				if Mode == 1 then
					AddCSLuaFile(Path)
				end
			else
				AddCSLuaFile(Path)
			end
		else
			if Mode <= 1 then
				include(Path)
			end
		end
		if Print~=nil then print("Loaded "..Print) end
	end,function(err)
		if Print~=nil then print("Loading "..Print.." Failed!") end
		print("Error: "..err)
		debug.Trace()
	end)
end

