return Def.ActorFrame{
	InitCommand=function(self) self:Center() end,

	LoadActor("quarter.png")..{
		InitCommand=function(self) self:shadowlength(1):y(-75) end,
		OnCommand=function(self) self:zoom(0.7):glow(1,1,1,1):glowshift():diffusealpha(0):sleep(3):decelerate(2):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},
	LoadFont("Common Header")..{
		Text=ScreenString("Header"),
		InitCommand=function(self) self:shadowlength(1):y(-150):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(1.0):decelerate(1):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},
	LoadFont("_eurostile normal")..{
		Text=ScreenString("Top"),
		InitCommand=function(self) self:shadowlength(1):y(80):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(2.0):decelerate(1):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},
    LoadFont("_eurostile normal")..{
		Text=ScreenString("Middle"),
		InitCommand=function(self) self:shadowlength(1):y(120):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(3.0):decelerate(1):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
    },
    
	LoadFont("_eurostile normal")..{
		Text=ScreenString("Bottom"),
		InitCommand=function(self) self:shadowlength(1):y(160):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(3.0):decelerate(1):diffusealpha(1):sleep(8):linear(0.75):diffusealpha(0) end,
	},
	LoadFont("_eurostile normal")..{
		Text=ScreenString("Start"),
		InitCommand=function(self) self:shadowlength(1):y(200):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(4.0):decelerate(1):diffusealpha(1):sleep(8):linear(0.75):diffusealpha(0) end,
	}
}