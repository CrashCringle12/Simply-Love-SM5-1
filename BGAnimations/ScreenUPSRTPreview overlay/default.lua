
local oop
local t = Def.ActorFrame{}
SleepDuration = 0.5
local frames = {
	Down = {
		{ Frame=1,	Delay=SleepDuration/1.5},
		{ Frame=2,	Delay=SleepDuration/1.5},
		{ Frame=3,	Delay=SleepDuration/1.5},
		{ Frame=0,	Delay=SleepDuration/1.5}
	},
	Left = {
		{ Frame=5,	Delay=SleepDuration/1.5},
		{ Frame=6,	Delay=SleepDuration/1.5},
		{ Frame=7,	Delay=SleepDuration/1.5},
		{ Frame=4,	Delay=SleepDuration/1.5}
	},
	Right = {
		{ Frame=9,	Delay=SleepDuration/1.5},
		{ Frame=10,	Delay=SleepDuration/1.5},
		{ Frame=11,	Delay=SleepDuration/1.5},
		{ Frame=8,	Delay=SleepDuration/1.5}
	},
	Up = {
		{ Frame=13,	Delay=SleepDuration/1.5},
		{ Frame=14,	Delay=SleepDuration/1.5},
		{ Frame=15,	Delay=SleepDuration/1.5},
		{ Frame=12,	Delay=SleepDuration/1.5}
	}
}

function createStarExplosion(x, y)
    for i = 1, 50 do
        t[#t+1] = Def.Sprite{
            Texture="star.png",
            InitCommand=function(self)
                self:diffusealpha(0)
            end,
            StarsMessageCommand=function(self)
                self:zoom(0.1)
                self:xy(x, y)
                self:diffuse(math.random(), math.random(), math.random(), math.random())
                self:zoom(math.random()*0.1 + 0.1)
                self:rotationz(math.random() * 360)
                self:accelerate(math.random() + 0.5)
                self:addx(math.random() * 2*SCREEN_WIDTH - SCREEN_WIDTH)
                self:addy(math.random() * 2*SCREEN_WIDTH - SCREEN_WIDTH)
                self:faderight(math.random() + 0.5)
                self:fadeleft(math.random() + 0.5)
                self:fadetop(math.random() + 0.5)
                self:fadebottom(math.random() + 0.5)
                self:decelerate(math.random() + 1)
                self:queuecommand("Remove")
            end,
            RemoveCommand=function(self) self:diffusealpha(0) end
        }
    end
end
t[#t+1] = Def.Sprite {
    Texture="Taro 4x4.png",
    InitCommand=function(self)
        self:zoom(1.75):y(SCREEN_CENTER_Y):x(SCREEN_WIDTH):SetStateProperties( frames["Left"] ):animate(true):linear(4):x(SCREEN_CENTER_X):queuecommand("Cease")
    end,
    OffCommand=function(self)
        self:linear(0.5):diffusealpha(0)
    end,
    CeaseCommand=function(self)
        self:animate(false):SetStateProperties( frames["Down"] ):setstate(3)
    end,
}
t[#t+1] = LoadActor("apple/default.lua")
t[#t+1] = Def.Sprite {
    Texture="Tejas 4x4.png",
    InitCommand=function(self)
        self:zoom(1.6):y(SCREEN_CENTER_Y-7):x(5*SCREEN_WIDTH/4):sleep(29):SetStateProperties( frames["Left"] ):animate(true):linear(5):x(5*SCREEN_WIDTH/8):queuecommand("Cease")
    end,
    OffCommand=function(self)
        self:linear(0.5):diffusealpha(0)
    end,
    CeaseCommand=function(self)
        self:animate(false):SetStateProperties( frames["Down"] ):setstate(3)
    end,
}
t[#t+1] = Def.Sprite {
    Texture="Reen 4x4.png",
    InitCommand=function(self)
        self:zoom(1.75):y(SCREEN_CENTER_Y):x(-1*SCREEN_WIDTH/4):sleep(24):SetStateProperties( frames["Right"] ):animate(true):linear(3):x(3*SCREEN_WIDTH/8):queuecommand("Cease")
    end,
    TestMessageCommand=function(self)
    end,
    OffCommand=function(self)
        self:linear(0.5):diffusealpha(0)
    end,
    CeaseCommand=function(self)
        self:animate(false):SetStateProperties( frames["Down"] ):setstate(3)
    end,
}
t[#t+1] = Def.ActorFrame {
    InitCommand=function(self)
        self:hibernate(45)
    end,
    Def.Quad{
        InitCommand=function(self)
            self:sleep(1):diffuse(0,0,0,1):FullScreen():queuecommand("Crop")
        end,
        CropCommand=function(self)
            self:croptop(1)
                :linear(8):croptop(0)
        end,
        OffCommand=function(self)
            self:diffusealpha(0):croptop(1)
                :sleep(7.9):accelerate(0.5):diffuse(0,0,0,1)
        end
    },
    Def.Quad{
        StarsCommand=function(self)
            MESSAGEMAN:Broadcast("Stars")
        end,
        InitCommand=function(self)
            self:sleep(9):queuecommand("Stars")
        end
    },
    LoadActor("bg.png")..{
        InitCommand=function(self)
            self:diffusealpha(0):FullScreen():queuecommand("Begin1")
        end,
        Begin1Command=function(self)
            self:sleep(8):accelerate(2.5):diffusealpha(1)
            self:texcoordvelocity(0.17,0):SetTextureFiltering(false)
            oop:sleep(9):queuecommand("Dog")
        end,
    },
    Def.Sound{
        File="Oop.ogg",
        InitCommand=function(self)
          oop = self
        end,
        DogMessageCommand=function(self)
            self:stop():play()
        end
    },

    Def.ActorFrame {
        InitCommand=function(self)
            self:sleep(8):zoom(0.7):x(SCREEN_CENTER_X)
        end,
        BeginCommand=function(self)
            self:decelerate(0.5):zoom(0.8):queuecommand("Begin1"):sleep(0.2)
        end,
        Begin1Command=function(self)
            self:smooth(1.5):zoom(0.7):addy(80)
        end,

        --Title
        LoadActor("Title.png")..{
            InitCommand=function(self)
                self:diffusealpha(0):sleep(8):zoom(0):y(SCREEN_HEIGHT+100)
                    
            end,
            BeginCommand=function(self)
                self:accelerate(1):y(SCREEN_CENTER_Y-120):addrotationz(720):zoom(0.4):diffusealpha(1)
            end,
            Begin1Command=function(self)
                self:sleep(0.8):linear(1):diffusealpha(1):wag():effectmagnitude(0,4,5):effectperiod(3)
            end
        },
    },

    Def.Sound{
        File="InsideStory.ogg",
        BeginCommand=function(self)
            self:sleep(45):play() 
        end
    },
	Def.Sound{
		File="Voice.ogg",
		TalkMessageCommand=function(self)
			self:play()
		end
	},
     Def.Quad {
        InitCommand=function(self)
            self:diffuse(1,1,1,1):FullScreen():diffusealpha(0):queuecommand("Begin1")
        end,
        Begin1Command=function(self)
            self:sleep(8.9):accelerate(0.1):diffusealpha(1):sleep(0.1):decelerate(3):diffusealpha(0)
        end
    },
     LoadActor("ComingSoon.png")..{
        InitCommand=function(self)
            self:Center():y(SCREEN_HEIGHT+100):diffusealpha(0):rotationz(25)
        end,
        StarsMessageCommand=function(self)
            self:linear(8):diffusealpha(1):addy(-1*SCREEN_HEIGHT/1.75)
    
        end
    }
}
createStarExplosion(SCREEN_CENTER_X, SCREEN_CENTER_Y-120)



return t 