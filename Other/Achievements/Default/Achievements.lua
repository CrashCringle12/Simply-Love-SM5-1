return {
	{
		Name = "Fantabulous",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 
		end,
		Desc = "Pass your first song",
		Difficulty = 1,
		ID = 1,
	},
	{
		Name = "Got Milk",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Pass I'll Make a Man Out of You on Expert difficulty or higher",
		Difficulty = 3,
		ID = 2,
	},
	{
		Name = "Roadrunner",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Successfully pass 10 songs in the 15 block rating",
		Difficulty = 5,
		ID = 3
	},
	{
		Name = "Omae Wa Mou",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "This is a Secret Achievement",
		Difficulty = 1,
		ID = 4
	},
	{
		Name = "Maniac",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Play 500 songs",
		Difficulty = 4,
		ID = 5
	},
	{
		Name = "#Goals",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Pass your first Couples Song!",
		Difficulty = 2,
		ID = 6
	},
	{
		Name = "Open Sesame",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Pass Gate Openerz on Expert difficulty or higher",
		Difficulty = 3,
		ID = 7
	},
	{
		Name = "Top G",
		Icon = "tate.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Defeat Andrew Tate and end his reign of terror",
		Difficulty = 4,
		ID = 8
	},
	{
		Name= "Great Player",
		Icon = "medal 4x3.png",
		Condition = function(pn) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetTapNoteScores("TapNoteScore_W1") >= 1 end,
		Desc = "Achieve over 10,000 lifetime greats.",
		Difficulty = 3,
		ID = 9,
		Data = {
			Progress = 0,
			Target = 10000,
		}
	}
}