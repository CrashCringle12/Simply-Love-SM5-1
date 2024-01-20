-- Returns True if rate mod is at least 1
function RateCheck()
    local rateMod
    if GAMESTATE:GetSongOptionsString() == '' then
        rateMod = '1.00'
    else
        rateMod = string.format("%.2f",string.sub(GAMESTATE:GetSongOptionsString(), 1,string.len(GAMESTATE:GetSongOptionsString()) - 6))
    end
    return tonumber(rateMod) >= 1
end

-- Returns rate mod
function RateCheck2()
    local rateMod
    if GAMESTATE:GetSongOptionsString() == '' then
        rateMod = '1.00'
    else
        rateMod = string.format("%.2f",string.sub(GAMESTATE:GetSongOptionsString(), 1, string.len( GAMESTATE:GetSongOptionsString()) - 6))
    end
    return tonumber(rateMod)
end

function PassCheck(pn)
    if RateCheck() then
        return not STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetFailed()
    else
        return false
    end
end

function ScoreCheck(pn, score, greaterThan)
    local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
    local PercentDP = stats:GetPercentDancePoints()
    local percent = FormatPercentScore(PercentDP)
    -- Format the Percentage string, removing the % symbol
    percent = percent:gsub("%%", "")
    if not stats:GetFailed() then
        return greaterThan and tonumber(percent) >= score or tonumber(percent) <= score
    else
        return false
    end
end

function TimingWindowCheck(pn, window, amount greaterThan)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
	return greaterThan and number >= amount or number <= amount
end

function ComboCheck(pn, amount, greaterThan)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local number = stats:GetCurrentCombo()
	return greaterThan and number >= amount or number <= amount
end

function RadarCheck(pn, RCType, amount, greaterThan)
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
	return greaterThan and performance >= amount or performance <= amount
end

-- -----------------------------------------------------------------------
-- Convenience function to return the SongOrCourse and StepsOrTrail for a
-- for a player.
local GetSongAndSteps = function(player)
    local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
    local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
    return SongOrCourse, StepsOrTrail
end

-- -----------------------------------------------------------------------
local GetScoreFromProfile = function(profile, SongOrCourse, StepsOrTrail)
    -- if we don't have everything we need, return nil
    if not (profile and SongOrCourse and StepsOrTrail) then return nil end

    return profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]
end

local GetScoreForPlayer = function(player)
    local highScore
    if PROFILEMAN:IsPersistentProfile(player) then
        local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
        highScore = GetScoreFromProfile(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
    end
    return highScore
end

function HasPassed(pn)
    if PassCheck(pn) then
        return true
    else
        local highScore = GetScoreForPlayer(pn)
        if highScore then return highScore:GetGrade() ~= 'Grade_Failed' end
    end
    return false
end

function updateSingleProgress(pn, pack, i, amount)
	if SL[pn].AchievementData[pack][i].Data then
		if SL[pn].AchievementData[pack][i].Data.Progress then
			SL[pn].AchievementData[pack][i].Data.Progress = SL[pn].AchievementData[pack][i].Data.Progress + amount
		else
			SL[pn].AchievementData[pack][i].Data.Progress = amount
		end
	else
		SL[pn].AchievementData[pack][i].Data = {Progress = amount, Target = SL.Accolades[pack][i].Data.Target}
	end
	if SL[pn].AchievementData[pack][i].Data.Progress >= SL[pn].AchievementData[pack][i].Data.Target then
		return true
	end
	return false
end

function updateMultiProgress(pn, pack, i, incrementTable)
	-- Increment table can look like { Holds = 1, Mines = 2, Jumps = 3 }
	-- This will increment the Holds progress by 1, Mines by 2, and Jumps by 3
	-- We will loop through the table and add the values to the achievement data
	if SL[pn].AchievementData[pack][i].Data then
		for k,v in pairs(incrementTable) do
			if SL[pn].AchievementData[pack][i].Data[k] then
				SL[pn].AchievementData[pack][i].Data[k].Progress = SL[pn].AchievementData[pack][i].Data[k].Progress + v
			else
				SL[pn].AchievementData[pack][i].Data[k] = {Progress = v, Target = SL.Accolades[pack][i].Data[k].Target}
			end
		end
	else
		SL[pn].AchievementData[pack][i].Data = {}
		for k,v in pairs(incrementTable) do
			SL[pn].AchievementData[pack][i].Data[k] = {Progress = v, Target = SL.Accolades[pack][i].Data[k].Target}
		end
	end
end

function updatePassData(pn, pack, i)
    local songName = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
    local difficulty = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
    if SL[pn].AchievementData[pack][i].Data then
        if SL[pn].AchievementData[pack][i].Data.Pass then
            if SL[pn].AchievementData[pack][i].Data.Pass[songName] then
                if SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty] then
                    if not SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty].played then
                        SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty].played = true
                    end
                    if not SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty].passed then
                        SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty] = HasPassed(pn)
                    end
                else
                    SL[pn].AchievementData[pack][i].Data.Pass[songName][difficulty] = {played = true, passed = HasPassed(pn)}
                end
            else
                SL[pn].AchievementData[pack][i].Data.Pass[songName] = {
                    [difficulty] = {played = true, passed = HasPassed(pn)}
                }
            end
        else
            SL[pn].AchievementData[pack][i].Data.Pass = {
                [songName] = {
                    [difficulty] = {played = true, passed = HasPassed(pn)}
                }
            }
        end
    else
        SL[pn].AchievementData[pack][i].Data = {
            Pass = {
                [songName] = {
                    [difficulty] = {played = true, passed = HasPassed(pn)}
                }
            }
        }
    end
    SM(SL[pn].AchievementData[pack][i].Data)
end

function checkSingleProgress(pn, pack, i)
	if SL[pn].AchievementData[pack][i].Data then
		if SL[pn].AchievementData[pack][i].Data.Progress then
			return SL[pn].AchievementData[pack][i].Data.Progress >= SL[pn].AchievementData[pack][i].Data.Target
		end
	end
	return false
end

function checkMultiProgress(pn, pack, i)
	if SL[pn].AchievementData[pack][i].Data then
		for k,v in pairs(SL[pn].AchievementData[pack][i].Data) do
			if v.Progress < v.Target then
				return false
			end
		end
		return true
	end
	return false
end

-- { StepType = - steps type here -, Difficulty = -difficulty here-}
-- StepsType = * -> Singles and Doubles
-- Difficulty = * -> All difficulties
-- Otherwise we receive a table of specific songs and difficulties
function checkPassData(pn, pack, i, groupName)
	local requiredSongDifficulties = SL.Accolades[pack][i].Data.RequiredPasses
	if requiredSongDifficulties then
		for song,difficulties in pairs(requiredSongDifficulties) do
			if not SL[pn].AchievementData[pack][i].Data.Pass[song] then
				return false
			end
			for difficulty,v in pairs(difficulties) do
				if difficulty == "Any" then
					local passed = false
					for diff,i in pairs(SL[pn].AchievementData[pack][i].Data.Pass[song]) do
						if SL[pn].AchievementData[pack][i].Data.Pass[song][diff].passed then
							passed = true
							break;
						end
					end
					if not passed then
						return false
					end
				else
					if not SL[pn].AchievementData[pack][i].Data.Pass[song][difficulty] then
						return false
					end
					if not SL[pn].AchievementData[pack][i].Data.Pass[song][difficulty].passed then
						return false
					end
				end
			end
		end
		return true
	else
		local requirement = SL.Accolades[pack][i].Data.ClearType
		if requirement == "*" then
			for i, song in ipairs(SONGMAN:GetSongsInGroup(groupName)) do
				if not SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()] then
					return false
				end
				local passed = false
				for difficulty,v in pairs(SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()]) do
					if not v.passed then
						passed = true;
						break;
					end
				end
				if not passed then
					return false
				end
			end
			return true;
		elseif requirement == "**" then
			for i, song in ipairs(SONGMAN:GetSongsInGroup(groupName)) do
				if not SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()] then
					return false
				end
				for difficulty,v in pairs(SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()]) do
					if not v.passed then
						return false
					end
				end
			end
			return true;
		elseif requirement == "Easy*" then
			for i, song in ipairs(SONGMAN:GetSongsInGroup(groupName)) do
				if not SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()] then
					return false
				end
				if not SL[pn].AchievementData[pack][i].Data.Pass[song:GetDisplayMainTitle()]["Difficulty_Easy"].passed then
					return false
				end
			end
			return true;
	end
	return false
end


function checkPlayedData(pn, pack, i)
	local requiredSongDifficulties = SL.Accolades[pack][i].Data.RequiredPlays
	if requiredSongDifficulties then
		for song,difficulties in pairs(requiredSongDifficulties) do
			if not SL[pn].AchievementData[pack][i].Data.Pass[song] then
				return false
			end
			for difficulty,v in pairs(difficulties) do
				if difficulty == "Any" then
					local played = false
					for diff,i in pairs(SL[pn].AchievementData[pack][i].Data.Pass[song]) do
						if SL[pn].AchievementData[pack][i].Data.Pass[song][diff].played then
							played = true
							break;
						end
					end
					if not played then
						return false
					end
				else
					if not SL[pn].AchievementData[pack][i].Data.Pass[song][difficulty] then
						return false
					end
					if not SL[pn].AchievementData[pack][i].Data.Pass[song][difficulty].played then
						return false
					end
				end
			end
		end
		return true
	end
	return false
end

