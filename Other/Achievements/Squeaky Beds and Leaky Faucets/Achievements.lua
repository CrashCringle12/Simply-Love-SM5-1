return {
	{
		Name = "Pekora Ch Megamix",
		ID = 1,
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Pass your first song",
		Difficulty = 1,
	},
	{
		Name = "Exercise ",
		ID = 2,
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Pass I'll Make a Man Out of You on Expert difficulty or higher",
		Difficulty = 3,
	},
}