LoadActor('../helper.lua')

return {
	{
		Name = "Getting Started",
		Icon = "medal 4x3.png",
        Condition = function(pn) 
			-- Checks if the song just played was passed
		   return PassCheck(pn)
	   end,
		Desc = "Pass your first song",
		Difficulty = 1,
		ID = 1,
	},
	{
		Name = "Getting Better",
		Icon = "medal 4x3.png",
		Desc = "Pass 10 songs",
		Data = {
			Progress = 0,
			Target = 10,
		},
		ID = 2,
		Difficulty = 1,
		Condition= function(pn) 
			if PassCheck(pn) then
				return updateSingleProgress(pn, "Default", 2, 1)
			else
				return checkSingleProgress(pn, "Default", 2)
			end
		end,
	},
	{
		Name = "Got Milk",
		Icon = "tate.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass I'll Make a Man Out of You on Expert difficulty",
		Difficulty = 3,
		ID = 3,
	},
	{
		Name = "ITG 15 pass club",
		Icon = "medal 4x3.png",
		Condition = function(pn)
			 -- Check if the group contains the word DDR, this is to prevent the achievement from being unlocked on DDR songs
			 if string.match(GAMESTATE:GetCurrentSong():GetGroupName(), "DDR") ~= nil or string.match(GAMESTATE:GetCurrentSong():GetGroupName(), "DanceDance") ~= nil then
				return false
			 else
				-- Check if the song meter is 15
				if GAMESTATE:GetCurrentSteps(pn):GetMeter() == 15 then
					return PassCheck(pn)
				else
					return false
				end
			 end
		end,
		Desc = "Successfully pass your first 15",
		Difficulty = 5,
		ID = 4
	},
	{
		Name = "Omae Wa Mou",
		Icon = "medal 4x3.png",
		Condition = function(pn)
			return false
		end,
		Desc = "This is a Secret Achievement",
		Difficulty = 1,
		ID = 5
	},
	{
		Name = "Maniac",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			-- Check if the profile has played 500 songs
			if PROFILEMAN:GetProfile(pn):GetTotalNumSongsPlayed() >= 500 then
				return PassCheck(pn)
			else
				return false
			end		
		end,
		Desc = "Play 500 songs",
		Difficulty = 4,
		ID = 6
	},
	{
		Name = "#Goals",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			-- Couples packs have the following in their group name: "Couples", "OnlyOneCouples", "OOC"
			-- Additionally they could have these in their steps description: "Couples", "OnlyOneCouples", "OOC"
			-- First lets see if the group name contains any of the above
			if string.match(GAMESTATE:GetCurrentSong():GetGroupName(), "Couples") ~= nil or string.match(GAMESTATE:GetCurrentSong():GetGroupName(), "OnlyOneCouples") ~= nil or string.match(GAMESTATE:GetCurrentSong():GetGroupName(), "OOC") ~= nil then
				return PassCheck(pn)
			elseif string.match(GAMESTATE:GetCurrentSteps(pn):GetDescription(), "couples") ~= nil or string.match(GAMESTATE:GetCurrentSteps(pn):GetDescription(), "OnlyOneCouples") ~= nil or string.match(GAMESTATE:GetCurrentSteps(pn):GetDescription(), "OOC") ~= nil then
				return PassCheck(pn)
			else
				return false
			end	
		end,
		Desc = "Pass your first Couples Song!",
		Difficulty = 2,
		ID = 7
	},
	{
		Name = "Open Sesame",
		Icon = "medal 4x3.png",
		Condition = function(pn) return false end,
		Desc = "Pass Gate Openerz on Expert difficulty or higher",
		Difficulty = 3,
		ID = 8
	},
	{
		Name = "Top G",
		Icon = "tate.png",
		Condition = function(pn) return false end,
		Desc = "Defeat Andrew Tate and end his reign of terror",
		Difficulty = 4,
		ID = 9
	},
	{
		Name= "Great Player",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return updateSingleProgress(pn, "Default", 10,  _GetTapNoteScores(pn, "W3"))
		end,
		Desc = "Achieve over 10,000 lifetime greats.",
		Difficulty = 3,
		ID = 10,
		Data = {
			Progress = 0,
			Target = 10000,
		}
	},
	{
		Name= "Test Achievement",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			if GAMESTATE:GetCurrentSong():GetDisplayMainTitle() == "After LIKE" then
				updatePassData(pn, "Default", 11)
				if PassCheck(pn) then
					return true;
				else
					return false;
				end
			end
		end,
		Desc = "Pass Peggy Suave",
		Difficulty = 2,
		ID = 11,
	},
	{
		Name= "Nice",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			if ThemePrefs.Get("nice") <= 0 then return false end

			if string.match(percent, "69") ~= nil then return true end
		
			-- check timing ratings (W1..W5, miss)
			local scores_table = {}
			for index, window in ipairs(TapNoteScores) do
				local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
				scores_table[window] = number
			end
		
			for label,item in pairs(scores_table) do
				if string.match(tostring(item), "69") ~= nil then return true end
			end
		
			-- check holds mines hands rolls, and their "total possible"
			for index, RCType in ipairs(RadarCategories) do
				local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
				local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )
		
				if string.match(tostring(performance), "69") ~= nil then return true end
				if string.match(tostring(possible), "69") ~= nil then return true end
			end
		
			-- check difficulty
			local meter
			if GAMESTATE:IsCourseMode() then -- course mode
				local trail = GAMESTATE:GetCurrentTrail(player)
				if trail then
					meter = trail:GetMeter()
					if string.match(tostring(meter), "69") ~= nil then return true end
				end
			else
				local steps = GAMESTATE:GetCurrentSteps(player) -- regular mode
				if steps then
					meter = steps:GetMeter()
					if string.match(tostring(meter), "69") ~= nil then return true end
				end
			end
		
			-- song title
			local songtitle = (GAMESTATE:IsCourseMode()
								and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle())
								or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
		
			if songtitle then
				if string.match(tostring(songtitle), "69") ~= nil then return true end
			end
		
			return false
		end,
		Desc = "nice",
		Difficulty = 1,
		ID = 12
	},
	{
		Name= "Mine v1",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return TimingWindowCheck(pn, "HitMine", 10, true)
		end,
		Desc = "Hit 10 Mines in one song",
		Difficulty = 1,
		ID = 13
	},
	{
		Name= "Mine v2",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return TimingWindowCheck(pn, "HitMine", 50, true)
		end,
		Desc = "Hit 50 Mines in one song",
		Difficulty = 2,
		ID = 14
	},
	{
		Name= "Mine v3",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return TimingWindowCheck(pn, "HitMine", 100, true)
		end,
		Desc = "Hit 100 Mines in one song",
		Difficulty = 3,
		ID = 15
	},
	{
		Name= "Long Haul",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			-- Check if the song is at least 3 minutes and 30 seconds long
			if GAMESTATE:GetCurrentSong():MusicLengthSeconds() >= 210 then
				return PassCheck(pn)
			else
				return false
			end
		end,
		Desc = "Pass a song that's at least 3 minutes and 30 seconds long.",
		Difficulty = 3,
		ID = 16
	},
	{
		Name= "Long Haul",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			if GAMESTATE:GetCurrentSong():MusicLengthSeconds() >= 600 then
				return PassCheck(pn)
			else
				return false
			end
		end,
		Desc = "Play a song that's at least 10 minutes song long.",
		Difficulty = 3,
		ID = 17
	},
	{
		Name= "Little Engine that could",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			if BPMCheck(pn, 50, true) then
				return PassCheck(pn)
			else
				return false
			end
		end,
		Desc = "Pass a song with an average BPM below 50",
		Difficulty = 3,
		ID = 18
	},
	{
		Name= "Need for Speed",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return BPMCheckRange(pn, 180, 200) and PassCheck(pn)
		end,
		Desc = "Pass a song with an average BPM in the 180 - 200 range",
		Difficulty = 3,
		ID = 19
	},
	{
		Name= "Speed for Need",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return BPMCheckRange(pn, 201, 220) and PassCheck(pn)
		end,
		Desc = "Pass a song with an average BPM in the 201 - 220 range",
		Difficulty = 3,
		ID = 20
	},
	{
		Name= "Footspeed Mastery",
		Icon = "medal 4x3.png",
		Condition = function(pn)
			return BPMCheck(pn, 250, true) and PassCheck(pn)
		end,
		Desc = "Pass a song with an average BPM over 250",
		Difficulty = 3,
		ID = 21
	},
	{
		Name= "👏👏👏👏",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			
		end,
		Desc = "Pass Go Go Sing ",
		Difficulty = 3,
		ID = 22
	},
	{
		Name= "B",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the original B.B.K.K.B.K.K",
		Difficulty = 3,
		ID = 23
	},
	{
		Name= "B",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the sequel to B.B.K.K.B.K.K",
		Difficulty = 3,
		ID = 24
	},
	{
		Name= "K",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the Burger King B.K.K.B.K.K",
		Difficulty = 3,
		ID = 25
	},
	{
		Name= "K",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the Slam Jam",
		Difficulty = 3,
		ID = 26
	},
	{
		Name= "B",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the gallopy bass kick",
		Difficulty = 3,
		ID = 27
	},
	{
		Name= "B",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the tachyon enhanced bass kick",
		Difficulty = 3,
		ID = 27
	},
	{
		Name= "B",
		Icon = "medal 4x3.png",
		Condition = function(pn) 
			return false
		end,
		Desc = "Pass the couples chart for B.B.K.K.B.K.K",
		Difficulty = 3,
		ID = 27
	},
	-- Passes 15, 15 pass club
	-- 100% mini, 12
	-- Bumblee Bee 
	-- History Maker 14
	-- 


}