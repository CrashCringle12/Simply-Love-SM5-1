local t = {}
local achievementName = ""
gui_actors = {}


local function AchievementUnlocked(achievementName)
    -- +"UNLOCKED")
     gui_actors.sound:playcommand('Play')
     gui_actors.achieve:diffusealpha(1):zoomx(0.075):spring(0.5):zoomx(0.4):sleep(3):linear(0.2):zoomx(0)
     gui_actors.text:diffusealpha(1):settext(achievementName):zoomx(0.075):spring(0.5):zoomx(1):sleep(3):linear(0.2):zoomx(0)
 end
 
-- t["ScreenEvaluation"] = Def.ActorFrame {
--     ModuleCommand=function(self)
--         for player in ivalues(PlayerNumber) do
-- 			-- Save current achievement status and progress to profile
-- 			UpdateAchievements(player)
-- 		end
--     end,
--     AchievementUnlockedMessageCommand=function(self, params)
--         AchievementUnlocked(params.Name)
--     end,
--     Def.Sprite{
--         Texture=THEME:GetPathO("", "Achievements/achievement.png"),
--         ModuleCommand=function(self)
--             self:CenterX():y(_screen.h*.85):zoom(.4):diffusealpha(0)
--             gui_actors.achieve = self
--     end},
--     Def.BitmapText{
--         File=THEME:GetPathO("", "Achievements/_x360 by redge 20px.ini"),
--         ModuleCommand = function(self)
--             self:x(_screen.w*.52):y(_screen.h*.875):diffusealpha(0)
--             gui_actors.text = self	
--     end},
--     Def.Sound{
--         Name="Achievement Sound",
--         File=THEME:GetPathO("", "Achievements/sound.ogg"),
--         ModuleCommand=function(self) gui_actors.sound = self end,
--         PlayCommand=function(self) self:stop():play() end,
--         StopCommand=function(self) self:stop() end,
--         UnlockedCommand=function(self, params)
--             AchievementUnlocked(params.Name) 
--         end
--     }
-- }

t["ScreenGameOver"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SM("Loading All Achievements")
        SL.Accolades = LoadAllAchievements()
    end
}
t["ScreenSelectMusic"] = Def.ActorFrame {
    ModuleCommand=function(self)
        for player in ivalues(PlayerNumber) do
			-- Save current achievement status and progress to profile
			UpdateAchievements(player)
		end
    end,
    AchievementUnlockedMessageCommand=function(self, params)
        achievementName = params.Name
        self:queuecommand("Unlocked"):sleep(5)
    end,
    Def.Sprite{
        Texture=THEME:GetPathO("", "Achievements/achievement.png"),
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
    Def.Sound{
        Name="Achievement Sound",
        File=THEME:GetPathO("", "Achievements/sound.ogg"),
        OnCommand=function(self) gui_actors.sound = self end,
        ModuleCommand=function(self) gui_actors.sound = self end,
        PlayCommand=function(self) self:stop():play() end,
        StopCommand=function(self) self:stop() end,
        UnlockedCommand=function(self, params)
            AchievementUnlocked(achievementName)
        end
    }
}


return t;