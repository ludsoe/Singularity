//localize stuff
local surface = surface
local draw = draw
local math = math
local string = string

local t = {}
t.font = "digital-7"
t.size = 36
t.weight = nil
t.additive = false
t.antialias = true
surface.CreateFont("lcd2", t)

local NoDraw = {
	"CHudHealth",
	"CHudBattery"
}

function CheckDraw(name)
	for i, n in pairs( NoDraw ) do
		if n == name then
			return false
		end
	end
	return true
end

function LoadHud()
	local Box = {IH=62,OH=56}
	function Draw()
		local alpha = 150
		local a = Vector(ScrW()-120,ScrH(100),0)
					
		draw.NoTexture()
		draw.RoundedBox(16,20,a.y-103,268,64, Color(50,50,50,alpha))
		draw.RoundedBox(16,24,a.y-100,260,56,Color(0,0,0,alpha))
		draw.NoTexture()
		
		surface.SetDrawColor(0,0,0,alpha)
		
		local Spot,Col = Vector(a.y-86,130,0),Color(0,140,220,255)
		draw.DrawText(tostring(LocalPlayer():Health()),"lcd2",Spot.y,Spot.x,Col,2)
		draw.DrawText("Health", "DermaDefault",Spot.y,Spot.x-7,Col, 2)

		local Spot = Vector(a.y-86,230,0)
		draw.DrawText(tostring(LocalPlayer():Armor()),"lcd2",Spot.y,Spot.x,Col,2)
		draw.DrawText("Armor", "DermaDefault",Spot.y,Spot.x-7,Col, 2)			
	end
	hook.Add("HUDPaint", "HDHud", Draw)
	
	function ShouldDraw(name)
		return CheckDraw(name)
	end
	hook.Add("HUDShouldDraw", "LsDisplay", ShouldDraw)
end
