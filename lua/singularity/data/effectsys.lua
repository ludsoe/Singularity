local Singularity = Singularity

if CLIENT then
	function Singularity.GetEmitter(pos,use3d)
		if not Singularity.emitter then Singularity.emitter = { } end
		
		if use3d then
			if not Singularity.emitter.use3d then
				Singularity.emitter.use3d = ParticleEmitter(pos,true)
				print("New Emitter!")
			else
				Singularity.emitter.use3d:SetPos(pos)
			end	
			return Singularity.emitter.use3d
		else
			if not Singularity.emitter.use2d then
				Singularity.emitter.use2d = ParticleEmitter(pos,false)
				print("New Emitter!")
			else
				Singularity.emitter.use2d:SetPos(pos)
			end	
			return Singularity.emitter.use2d
		end
	end
end







