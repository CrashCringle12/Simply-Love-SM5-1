local t = {}
gui_actors = {}
SL.Accolades.Notifications = {
    current = 0,
    achievements = {},
}

local function AchievementUnlocked(achievementName, achievementDesc)
    -- +"UNLOCKED")
     gui_actors.sound:playcommand('Play')
     gui_actors.achieve:diffusealpha(1):zoomx(0.09):spring(0.5):zoomx(0.4):sleep(2.52*2):linear(0.2):zoomx(0)
     gui_actors.text:diffusealpha(1):settext(achievementName):zoomx(0.09):spring(0.5):zoomx(1):sleep(1.94):linear(0.2):zoomx(0):diffusealpha(0)
     gui_actors.text2:diffusealpha(0):zoomx(0.7):settext(achievementDesc):sleep(2.52):linear(0.5):diffusealpha(1):sleep(2.56):linear(0.2):zoomx(0)
 end
 
t["ScreenGameOver"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SM("Loading All Achievements")
        SL.Accolades.Achievements = LoadAllAchievements()
    end
}

t["ScreenSelectMusic"] = Def.ActorFrame {
    ModuleCommand=function(self)
        if (SL.Global.Stages.PlayedThisGame > 0) then
            for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
                -- Save current achievement status and progress to profile
               -- UpdateAchievements(pn)
            end
        end
    end,
    AchievementUnlockedMessageCommand=function(self, params)
        -- Process SL.Accolades.Notifications.achievements
        -- For each one, queue a command to display it
        if #SL.Accolades.Notifications.achievements > 0 then
            for i, achievement in ipairs(SL.Accolades.Notifications.achievements) do
                Trace("Queue up achievement "..i .. " ".. achievement.Name)
                self:queuecommand("Unlocked"):sleep(7*i)
            end
        end
    end,
    Def.Sprite{
        Frames = {
            { Frame=0,	Delay=0.09},
            { Frame=1,	Delay=0.09},
            { Frame=2,	Delay=0.09},
            { Frame=3,	Delay=0.09},
            { Frame=4,	Delay=0.09},
            { Frame=5,	Delay=0.09},
            { Frame=6,	Delay=0.09},
            { Frame=7,	Delay=0.09},
            { Frame=8,	Delay=0.09},
            { Frame=9,	Delay=0.51},
            { Frame=8,	Delay=0.15},
            { Frame=7,	Delay=0.09},
            { Frame=6,	Delay=0.09},
            { Frame=5,	Delay=0.09},
            { Frame=4,	Delay=0.09},
            { Frame=3,	Delay=0.09},
            { Frame=2,	Delay=0.09},
            { Frame=1,	Delay=0.09},
            { Frame=0,	Delay=0.51},
        };
        Texture=THEME:GetPathO("", "Achievements/achievement 2x5.png"),
        OnCommand=function(self)
            self:CenterX():y(_screen.h*.85):zoom(.4):diffusealpha(0)
            gui_actors.achieve = self
        end,
        ModuleCommand=function(self)
            self:CenterX():y(_screen.h*.85):zoom(.4):diffusealpha(0)
            gui_actors.achieve = self
    end},
    Def.BitmapText{
        File=THEME:GetPathO("", "Achievements/_x360 by redge 20px.ini"),
        OnCommand=function(self)
            self:x(_screen.w*.52):y(_screen.h*.875):diffusealpha(0)
            gui_actors.text = self
        end,
        ModuleCommand = function(self)
            self:x(_screen.w*.52):y(_screen.h*.875):diffusealpha(0)
            gui_actors.text = self	
    end},
    Def.BitmapText{
        File=THEME:GetPathO("", "Achievements/_x360 by redge 20px.ini"),
        OnCommand=function(self)
            self:zoom(0.70):x(_screen.w*.52):y(_screen.h*.875):diffusealpha(0)
            gui_actors.text2 = self
            self:wrapwidthpixels(250/self:GetZoom())
        end,
        ModuleCommand = function(self)
            self:zoom(0.70):x(_screen.w*.52):y(_screen.h*.875):diffusealpha(0)
            gui_actors.text2 = self	
            self:wrapwidthpixels(250/self:GetZoom())
    end},
    Def.Sound{
        Name="Achievement Sound",
        File=THEME:GetPathO("", "Achievements/sound.ogg"),
        OnCommand=function(self) gui_actors.sound = self end,
        ModuleCommand=function(self) gui_actors.sound = self end,
        PlayCommand=function(self) self:stop():play() end,
        StopCommand=function(self) self:stop() end,
        UnlockedCommand=function(self, params)
            if #SL.Accolades.Notifications.achievements > 0 then
                AchievementUnlocked(SL.Accolades.Notifications.achievements[1].Name, SL.Accolades.Notifications.achievements[1].Desc)
                -- Remove
                table.remove(SL.Accolades.Notifications.achievements, 1)
            end
        end
    }
}


return t;