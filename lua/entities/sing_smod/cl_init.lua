include('shared.lua')

function ENT:Compile(T,N)
	--Make a copy of the data pattern.
	local MyData = table.Copy(Singularity.ShipMods.Modules[T][N].E)
	self.ModuleData = MyData
	self.BubbleData = MyData.WorldTip
	
	self.CThink = MyData.ClientThink or function() end
	self.ClientSide = true
end

function ENT:Think()
	if not self.ClientSide then
		self.ModType = self:GetNWString("Type","")
		self.ModName = self:GetNWString("Name","Ship Module")
		self.DisplayName = self:GetNWString("DName",self.ModName)
		if self.ModType~="" and self.ModName~="" then	
			self:Compile(self.ModType,self.ModName)
		end
	else
		if self.CThink then
			self.CThink(self,self.Core)
		end
	end
end

function ENT:BubbleFunc(Txt,Core,Trace,Pos)
	for n, v in pairs( self.BubbleData or {} ) do
		Txt=Txt.."\n"..n..": "..tostring(self:GetNWFloat(v))
	end
	return Txt
end

function ENT:WorldBubble(Trace,Pos)
	local txt = "[ "..(self.DisplayName or self.ModName).." ]"
	--Add Stuff Here related to what the ship Module Displays.
	return txt
end