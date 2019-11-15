return Def.ActorFrame{
	InitCommand=function(self) self:Center() end,

	LoadActor("quarter.png")..{
		InitCommand=function(self) self:shadowlength(1):y(60) end,
		OnCommand=function(self) self:zoom(0.4):glow(1,1,1,1):glowshift():diffusealpha(0):sleep(3):decelerate(2):diffusealpha(1):sleep(6):linear(0.75):diffusealpha(0) end,
	},
	LoadFont("_wendy white")..{
		Text=ScreenString("Header"),
		InitCommand=function(self) self:shadowlength(1):y(-120):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(1.0):decelerate(1):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
	},
	LoadFont("Common Normal")..{
		Text=ScreenString("Top"),
		InitCommand=function(self) self:shadowlength(1):y(0):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(2.0):decelerate(1):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
	},

    LoadFont("Common Normal")..{
		Text=ScreenString("Middle"),
		InitCommand=function(self) self:shadowlength(1):y(120):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(3.0):decelerate(1):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
    },
    
	LoadFont("Common Normal")..{
		Text=ScreenString("Bottom"),
		InitCommand=function(self) self:shadowlength(1):y(180):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(4.0):decelerate(1):diffusealpha(1):sleep(4):linear(0.75):diffusealpha(0) end,
	}
}