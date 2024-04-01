LoadActor('../helper.lua')

return {
    {
        Name = "Trial of Silly Arrows",
        Icon = "medal 4x3.png",
        Condition = function(pn)
            -- Checks if the song just played was passed
            return PassCheck(pn)
        end,
        Desc = "Pass your first song",
        Difficulty = 1,
        ID = 1
    }, 
	{
        Name = "Trial of Exemplorary Multitudes",
        Icon = "medal 4x3.png",
        Condition = function(pn)
            -- Checks if the song just played was passed
            local trialSongs = TrialCheck("Trial of Exemplorary Multitudes")
            local song = GAMESTATE:GetCurrentSong()
            if song then
                if trialSongs[song:GetDisplayMainTitle()] then end
            end
            return TrialCheck("Trial of Exemplorary Multitudes")
        end,
        Data = {RequiredPasses = {}}
    }

}
