local counter = 5
local num = math.random(1,6)
return Def.ActorFrame{
	InitCommand=function(self) self:draworder(1000) end,
Def.Actor{
    OnCommand=function(self)
        self:queuecommand("Listen")
        -- currently 7 seconds as defined in metrics.ini
        local duration = 5
        -- get ScreenCoronaLines
        local screen = SCREENMAN:GetTopScreen()
        -- don't let the players interact with it for duration (7) seconds
        screen:lockinput(duration)
    end,
    ListenCommand=function(self)
        local topscreen = SCREENMAN:GetTopScreen()
        local seconds = counter
        if seconds <= 0 then
            self:playcommand("Finish")
        else
            counter = counter - 1
            self:sleep(0.99):queuecommand("Listen")
        end
    end,
    FinishCommand=function(self)
        SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
    end
    },
	Def.Quad{
		InitCommand=function(self) self:FullScreen() end,
		OnCommand=function(self) self:diffuse(Color.Black):diffusealpha(0):decelerate(1.8):diffusealpha(1):sleep(3):linear(0.75):diffusealpha(0) end,
	},
    Def.Sound{
		File=THEME:GetPathB("ScreenSponsors", "overlay/SalemSponsor"..num..".ogg"),
		OnCommand=function(self) self:play() end
	},
	LoadFont("Common Bold")..{
		Text="And now a word from our Sponsors!",
		InitCommand=function(self) self:visible(true):Center():zoom(0.70) end,
	}
}
