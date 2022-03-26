return Def.ActorFrame{
	Def.Actor{
		OnCommand=function(self)
		 self:queuecommand("Listen")
		  -- currently 7 seconds as defined in metrics.ini
		  local duration = THEME:GetMetric("ScreenCoronaLines", "TimerSeconds")
		  -- get ScreenCoronaLines
		  local screen = SCREENMAN:GetTopScreen()
		  -- don't let the players interact with it for duration (7) seconds
		  screen:lockinput(duration)
		end,
		ListenCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
		 	local seconds = topscreen:GetChild("Timer"):GetSeconds()
			if seconds <= 0 then
				self:playcommand("Finish")
			else
				self:sleep(0.25):queuecommand("Listen")
			end
		end,
		FinishCommand=function(self)
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	  },
	LoadActor("Guidelines.png")..{
		InitCommand=function(self) self:FullScreen() end,
		OnCommand=function(self) self:diffusealpha(0):decelerate(2):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
	},
}