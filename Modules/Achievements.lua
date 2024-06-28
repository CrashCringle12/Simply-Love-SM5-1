local t = {}

t["ScreenGameOver"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SL.Accolades.Achievements = LoadAllAchievements()
    end
}

t["ScreenEvaluationStage"] = Def.ActorFrame {
    ModuleCommand=function(self)
        for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
            --Save current achievement status and progress to profile
            UpdateAchievements(pn)
        end
    end,
}


return t;