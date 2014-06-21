local Singularity = Singularity
local Debug = function(MSG) Singularity.Debug(MSG,3,"LSSOwner") end

function LoadPP()
	if CPPI and CPPI.GetName then
		Debug("Prop Protection Detected! Using its functions.")
		--Oh good we have a CPPI prop protection installed, we can use it.
		function Singularity.GivePlyProp(owner,prop)
			prop:CPPISetOwner(owner) 
			Debug("Entity: "..tostring(prop).." Given to "..owner:Nick())
		end
		
		function Singularity.GetPropOwner(prop)
			return prop:CPPIGetOwner()
		end		
	else
		--Code better failsafe prop protections later.
		Debug("No Prop Protections Detected! Defaulting to built in functions.")
		--Use failsafe ownership detections by running own "prop protection" code.
		local metaent = FindMetaTable("Entity")
		local metaply = FindMetaTable("Player")

		function Singularity.GivePlyProp(owner,prop)
			prop.LSSOwner = owner
			Debug("Entity: "..tostring(prop).." Given to "..owner:Nick())
		end

		function Singularity.GetPropOwner(prop)
			if prop.LSSOwner and IsValid(prop.LSSOwner) then
				return prop.LSSOwner
			end
			return game.GetWorld()
		end

		CPPI={}
		function CPPI:GetName() return "Singularity FailSafe" end
		function CPPI:GetVersion() return Singularity.Version end
		function metaent:CPPIGetOwner() return Singularity.GetPropOwner(self) end
		function metaent:CPPISetOwner(ply) return Singularity.GivePlyProp(ply,self) end
		function metaply:CPPIGetFriends() return {} end
		function metaent:CPPICanTool(ply,mode) return true end
		function metaent:CPPICanPhysgun(ply) return true end
		function metaent:CPPICanPickup(ply) return true end
		function metaent:CPPICanPunt(ply) return true end

		hook.Add("PlayerSpawnedSENT","LSSOwnerGive", Singularity.GivePlyProp)
		hook.Add("PlayerSpawnedVehicle","LSSOwnerGive", Singularity.GivePlyProp)
		hook.Add("PlayerSpawnedSWEP", "LSSOwnerGive", Singularity.GivePlyProp)
		hook.Add("PlayerSpawnedProp","LSSOwnerGive", function(p,m,e) Singularity.GivePlyProp(p,e) end)
	end
end

hook.Add("InitPostEntity","LSSOwnerShip", LoadPP)
