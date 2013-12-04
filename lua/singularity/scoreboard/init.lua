local ScorF = "singularity/scoreboard/"

Singularity.LoadFile(ScorF.."scoreboard.lua")
Singularity.LoadFile(ScorF.."player_frame.lua")
Singularity.LoadFile(ScorF.."player_infocard.lua")
Singularity.LoadFile(ScorF.."player_row.lua")

if(SERVER)then

else
	SingularityBoard = nil
	
	timer.Simple( 1.5, function()
		
		function GAMEMODE:CreateScoreboard()
		
			if ( ScoreBoard ) then
			
				ScoreBoard:Remove()
				ScoreBoard = nil
				
			end
			
			SingularityBoard = vgui.Create( "SingularityBoard" )
			
			return true

		end
		
		function GAMEMODE:ScoreboardShow()
		
			if not SingularityBoard then
				self:CreateScoreboard()
			end 

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SingularityBoard:SetVisible( true )
			SingularityBoard:UpdateScoreboard( true )
			
			return true

		end
		
		function GAMEMODE:ScoreboardHide()
		
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			SingularityBoard:SetVisible( false )
			
			return true
			
		end
		
	end )
end		