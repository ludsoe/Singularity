include('shared.lua')

function ENT:Draw()
	self:DrawModel()
		
	--Put model modifications here.
end

function ENT:Compile(T,N)
	--Make a copy of the data pattern.
	local MyData = table.Copy(Singularity.ShipMods.Modules[T][N].E)
	self.ModuleData = MyData
	self.BubbleData = MyData.WorldTip
	
	self.CThink = MyData.ClientThink or function() end
end

function ENT:Think()
	if not self.ClientSide then
		self.ModType = self:GetNWString("Type","")
		self.ModName = self:GetNWString("Name","")
		if self.ModType~="" and self.ModName~="" then
			self.ClientSide = true
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
	local txt = "[ "..(self.ModName or "Ship Module").." ]"
	local Core = self:GetNWEntity("ShipCore")
	self.Core = Core
	if Core and IsValid(Core)then
		txt=self:BubbleFunc(txt,Core,Trace,Pos)
	else
		txt=txt.."\n No ShipCore Detected"
	end
	--Add Stuff Here related to what the ship Module Displays.
	return txt
end