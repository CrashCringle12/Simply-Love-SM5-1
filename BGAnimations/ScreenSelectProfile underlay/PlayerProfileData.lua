
-- ----------------------------------------------------
-- local tables containing NoteSkins and JudgmentGraphics available to SL
-- We'll compare values from profiles against these "master" tables as it
-- seems to be disconcertingly possible for user data to contain errata, typos, etc.

local noteskins = NOTESKIN:GetNoteSkinNames()
local judgment_graphics = {}

-- get a table like { "ITG", "FA+" }
local judgment_dirs = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."Graphics/_judgments/", true, false)
for dir in ivalues(judgment_dirs) do
	judgment_graphics[dir] = GetJudgmentGraphics(dir)
end
-- ----------------------------------------------------
-- some local functions that will help process profile data into presentable strings

local RecentMods = function(mods)
	if type(mods) ~= "table" then return "" end

	local text = ""

	-- SpeedModType should be a string and SpeedMod should be a number
	if type(mods.SpeedModType)=="string" and type(mods.SpeedMod)=="number" then
		-- for ScreenSelectProfile, allow either "x" or "X" to be in the player's profile for SpeedModType
		if (mods.SpeedModType):upper()=="X" and mods.SpeedMod > 0 then
			-- take whatever number is in the player's profile, string format it to 2 decimal places
			-- convert back to a number to remove potential trailing 0s (we want "1.5x" not "1.50x")
			-- and finally convert that back to a string
			text = ("%gx"):format(tonumber(("%.2f"):format(mods.SpeedMod)))

		elseif (mods.SpeedModType=="M" or mods.SpeedModType=="C") and mods.SpeedMod > 0 then
			text = ("%s%.0f"):format(mods.SpeedModType, mods.SpeedMod)
		end
	end

	-- -----------------------------------------------------------------------
	-- the NoteSkin and JudgmentGraphic previews are not text, and are loaded, handled, and positioned separately

	-- ASIDE: My informal testing of reading ~80 unique JudgmentGraphic files from disk and
	-- loading them into memory caused StepMania to hang for a few seconds, so
	-- JudgmentGraphicPreviews.lua and NoteSkinPreviews.lua only load assets that are
	-- needed by current player profiles (not every possible asset).

	-- FIXME: If a profile's values for NoteSkin and/or JudgmentGraphic don't match with anything
	-- available to StepMania (players commonly modify their profiles by hand and introduce typos),
	-- we currently don't show anything.  Maybe a generic graphic of a question mark (or similar)
	-- would be nice but that can wait for a future release.
	-- -----------------------------------------------------------------------

	-- Mini should definitely be a string
	if type(mods.Mini)=="string" and mods.Mini ~= "" then text = ("%s %s, "):format(mods.Mini, THEME:GetString("OptionTitles", "Mini")) end

	-- DataVisualizations should be a string and a specific string at that
	if mods.DataVisualizations=="Target Score Graph" or mods.DataVisualizations=="Step Statistics" then
		text = text .. THEME:GetString("SLPlayerOptions", mods.DataVisualizations)..", "
	end

	-- loop for mods that save as booleans
	local flags, hideflags = "", ""
	for k,v in pairs(mods) do
		-- explicitly check for true (not Lua truthiness)
		if v == true then
			-- gsub() returns two values:
			-- the string resulting from the substitution, and the number of times the substitution occurred (0, 1, 2, 3, ...)
			-- custom modifier strings in SL should have "Hide" occur as a substring 0 or 1 times
			local mod, hide = k:gsub("Hide", "")

			if THEME:HasString("SLPlayerOptions", mod) then
				if hide == 0 then
					flags = flags..THEME:GetString("SLPlayerOptions", mod)..", "
				elseif hide == 1 then
					hideflags = hideflags..THEME:GetString("ThemePrefs", "Hide").." "..THEME:GetString("SLPlayerOptions", mod)..", "
				end
			end
		end
	end
	text = text .. hideflags .. flags

	-- remove trailing comma and whitespace
	text = text:sub(1,-3)

	return text, mods.NoteSkin, mods.JudgmentGraphic, mods.SpeedMod, mods.SpeedModType, mods.lifeMeterType
end

-- ----------------------------------------------------
-- profiles have a GetTotalSessions() method, but the value doesn't (seem to?) increment in EventMode
-- making it much less useful for the players who will most likely be using this screen
-- for now, just retrieve total songs played

local TotalSongs = function(numSongs)
	if numSongs == 1 then
		return Screen.String("SingularSongPlayed"):format(numSongs)
	else
		return Screen.String("SeveralSongsPlayed"):format(numSongs)
	end
	return ""
end

local ValidSong = function(lastSong)
	if lastSong == nil or lastSong == "" then
		return "N/A"

	else
		return lastSong:GetDisplayMainTitle()

	end
	return ""
end
-- ----------------------------------------------------
-- retrieves profile data from disk without applying it to the SL table

local RetrieveProfileData = function(profile, dir)
	local theme_name = THEME:GetThemeDisplayName()
	local path = dir .. theme_name .. " UserPrefs.ini"
	if FILEMAN:DoesFileExist(path) then
		return IniFile.ReadFile(path)[theme_name]
	end
	return false
end

local RetrieveProfileAchievements = function(profile, dir)
	-- local theme_name = THEME:GetThemeDisplayName()
	local path = dir .. "Achievements.json"
	
	if FILEMAN:DoesFileExist(path) then
		local f = RageFileUtil:CreateRageFile()
		local achievements = {}
		if f:Open(path, 1) then
			local data = JsonDecode(f:Read())
			if data ~= nil then
				achievements = data
			end
		end
		f:destroy()
		return achievements
	end
	return {}
end

SweatLevelRibbon = function(profile)
	-- Params.totalsongs returns the text "## Songs Played also so we need to split it
	-- Now we need to conver the amount of songs played to an integer and check if it meets the criteria
	local numSongs = profile:GetNumTotalSongsPlayed()
	if numSongs > 10000 then
		return "Dance Dance Maniac",(11)
	elseif numSongs > 7500 then
		return "I ❤️ Dance Games",(10)
	elseif numSongs > 5000 then
		return "Broken",(9)
	elseif numSongs > 4000 then
		return "Not Casual",(8)
	elseif numSongs > 3000 then
		return "Groove Master",(7)
	elseif numSongs > 2000 then
		return "DDR God",(6)
	elseif numSongs > 1000 then
		return "Maniac",(5)
	elseif numSongs > 750 then
		return "True Gamer",(4)
	elseif numSongs > 500 then
		return "Insane",(3)
	elseif numSongs > 250 then
		return "Competitive", (2)
	elseif numSongs > 100 then
		return "Casual", (1)
	elseif numSongs > 50 then
		return "Casual", (0)
	else
		return "Casual",-1
	end
end

-- ----------------------------------------------------
-- Retrieve and process data (mods, most recently played song, high score name, etc.)
-- for each available local profile and put it in the profile_data table.
-- Since both players are using the same list of local profiles, this only needs to be performed once (not once for each player).
-- I'm doing it here, in PlayerProfileData.lua, to keep default.lua from growing too large/unwieldy.  Once done, pass the
-- table of data back default.lua where it can be sent via playcommand parameter to the appropriate PlayerFrames as needed.

local profile_data = {}
--Handle Guest Profile
GetMachineProfileData = function()
	-- Get Machine Profile
	local profile = PROFILEMAN:GetMachineProfile()
	-- GetLocalProfileIDFromIndex() also expects indices to start at 0
	local sweatLevel, ribbon = SweatLevelRibbon(profile)
	local data = {
		index = 0,
		dir = nil,
		lifeMeterType = nil,
		sweatLevel = sweatLevel,
		timePlayed = roundToDecimal((profile:GetTotalGameplaySeconds()/60)/60, 2),
		displayname = THEME:GetString("ScreenSelectProfile", "GuestProfile"),
		highscorename = profile:GetLastUsedHighScoreName(),
		recentsong = ValidSong(profile:GetLastPlayedSong()),
		totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
		ribbon = ribbon,
		mods = nil,
		popularSong = ValidSong(profile:GetMostPopularSong()),
		noteskin = "cel",
		judgment = "Love",
		guid = profile:GetGUID(),
		achievementIndex = 1,
		packIndex = 1,
		achievements = nil,
		activePack = "Default"
	}
	return data
end


for i=1, PROFILEMAN:GetNumLocalProfiles() do

	-- GetLocalProfileFromIndex() expects indices to start at 0
	local profile = PROFILEMAN:GetLocalProfileFromIndex(i-1)
	-- GetLocalProfileIDFromIndex() also expects indices to start at 0
	local id = PROFILEMAN:GetLocalProfileIDFromIndex(i-1)
	local dir = PROFILEMAN:LocalProfileIDToDir(id)
	local userprefs = RetrieveProfileData(profile, dir)
	local mods, noteskin, judgment, speedMod, speedModType, lifeMeterType = RecentMods(userprefs)
	local sweatLevel, ribbon = SweatLevelRibbon(profile)
	local data = {
		index = i,
		dir = dir,
		speedmod = speedMod,
		speedModType = speedModType,
		lifeMeterType = lifeMeterType,
		sweatLevel = sweatLevel,
		timePlayed = roundToDecimal((profile:GetTotalGameplaySeconds()/60)/60, 2),
		displayname = profile:GetDisplayName(),
		highscorename = profile:GetLastUsedHighScoreName(),
		recentsong = ValidSong(profile:GetLastPlayedSong()),
		totalsongs = TotalSongs(profile:GetNumTotalSongsPlayed()),
		ribbon = ribbon,
		mods = mods,
		popularSong = ValidSong(profile:GetMostPopularSong()),
		noteskin = noteskin,
		judgment = judgment,
		guid = profile:GetGUID(),
		achievementIndex = 1,
		achievements = RetrieveProfileAchievements(profile, dir),
		activePack = "Default"

	}

	table.insert(profile_data, data)
end

return profile_data, GetMachineProfileData()
