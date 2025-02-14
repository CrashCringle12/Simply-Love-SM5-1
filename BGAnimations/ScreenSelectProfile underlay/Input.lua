local args = ...
local af = args.af
local scrollers = args.Scrollers
local localprofile_data = args.ProfileData
local guest_data = args.GuestData
local function getAPIKey()
	local path = "/"..THEME:GetCurrentThemeDirectory().."Other/apiKey.txt"
	local file = RageFileUtil.CreateRageFile()
	if file:Open(path, 1) then
		local apiKey = file:Read()
		file:Close()
		file:destroy()
		-- trim whitespace
		apiKey = apiKey:gsub("^%s*(.-)%s*$", "%1")
		return apiKey
	else
		return ""
	end

end
local apiKey = getAPIKey()

-- a simple boolean flag we'll use to ignore input once profiles have been
-- selected and the screen's OffCommand has been queued.
--
-- aside: SM's screen class does have a RemoveInputCallback() method,
-- but it needs a reference to the original input handler funtion as
-- a passed-in argument, and that's tricky with how I've split
-- ScreenSelectProfile's code across multiple files.
local finished = false
-- Counter used to determine if both players have selected their profile. 
-- This value basically represents the amount of players that are ready to
-- move forward + 1. Each time a player presses enter this value goes up until
-- it matches the amount of human players (This sounds a little more heavy than it really is)
local playersSelected = 1

--The player number of the last player to press enter. Used to prevent one player from
--incrementing the counter themself and still skipping and not letting the other player select.
local lastPlayerNumber

-- we need to calculate how many dummy rows the scroller was "padded" with
-- (to achieve the desired transform behavior since I am not mathematically
-- perspicacious enough to have done so otherwise).
-- we'll use index_padding to get the correct info out of profile_data.
local index_padding = 1

local profile_data = {guest_data}
for profile in ivalues(localprofile_data) do
	table.insert(profile_data, profile)
	if profile.index == nil or profile.index <= 0 then
		index_padding = index_padding + 1
	end
end

local PreferredStyle = ThemePrefs.Get("PreferredStyle")
local mpn = GAMESTATE:GetMasterPlayerNumber()
local activeGenerations = 0
local Handle = {}

Handle.Start = function(event)
	local topscreen = SCREENMAN:GetTopScreen()
	-- if the input event came from a side that is not currently registered as a human player, we'll either
	-- want to reject the input (we're in Pay mode and there aren't enough credits to join the player),
	-- or we'll use ScreenSelectProfile's inscrutably custom SetProfileIndex() method to join the player.
	if not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then

		-- IsArcade() is defined in _fallback/Scripts/02 Utilities.lua
		-- in CoinMode_Free, EnoughCreditsToJoin() will always return true
		-- thankfully, EnoughCreditsToJoin() factors in Premium settings
		if IsArcade() and not GAMESTATE:EnoughCreditsToJoin() then
			-- play the InvalidChoice sound and don't go any further
			MESSAGEMAN:Broadcast("InvalidChoice", {PlayerNumber=event.PlayerNumber})
			return
		end

		-- otherwise, pass -1 to SetProfileIndex() to join that player
		-- see ScreenSelectProfile.cpp for details
		topscreen:SetProfileIndex(event.PlayerNumber, -1)
	else
		if apiKey ~= "" then
			local raw_name = profile_data[scrollers[event.PlayerNumber]:get_info_at_focus_pos().index+1].displayname
			-- We need to clean this name up before sending it to TTS
			-- Strip any trailing numbers if they're more than 3 digits
			-- If there is a hyphen, space or underscore in the name (after the 3rd character), remove everything after it
			-- If what we have left is less than 3 characters, use the whole name
			-- Code:
			local name = raw_name:gsub("(%d%d%d+)$", "") --:gsub("[- _].*$", "")
			-- -- Remove any special characters at the end or beginning of the name
			-- name = name:gsub("^[^%w]+", ""):gsub("[^%w]+$", "")
			-- if #name < 3 then
			-- 	name = raw_name
			-- end
			-- make the name all uppercase
			-- name = name:upper()

			if #name > 20 then
				name = "YOU!!"
			end
			local voice = "echo"
			-- Check if the name file already exists:
			local path = "/"..THEME:GetCurrentThemeDirectory().."Sounds/Generated/"..voice.."/"..name .. ".mp3"
			if not FILEMAN:DoesFileExist(path) and scrollers[event.PlayerNumber]:get_info_at_focus_pos().index > 0 then
				--SM("File does not exist, generating")
				-- If the file doesn't exist, generate it
				if activeGenerations <= 2 then
					activeGenerations = activeGenerations + 1
					local uuid = CRYPTMAN:GenerateRandomUUID()
					NETWORK:HttpRequest{
					url = "https://api.openai.com/v1/audio/speech",
					method = "POST",
					downloadFile=name .. ".mp3",
					headers = {
						["Authorization"] = "Bearer "..apiKey,
						["Content-Type"] = "application/json",
					},
					body = '{"model": "tts-1", "input": "...'..name..'!!!!!!!", "voice": "'..voice..'"}',
					connectTimeout = 60,
					transferTimeout = 1800,
					onProgress = function(currentBytes, totalBytes)
						--SM("Downloaded " .. currentBytes .. " of " .. totalBytes .. " bytes")
					end,
					onResponse = function(response)
						--SM(response, 10)

						if response.error ~= nil then
							--SM("Error: " .. response.error)
							return
						end
						if response.statusCode == 200 then
							if response.headers["Content-Type"] == "audio/mpeg" then
								--SM("Downloaded " .. response.body:len() .. " bytes")
								FILEMAN:Copy("/Downloads/"..name .. ".mp3", path)
								SOUND:PlayOnce(path)
								activeGenerations = activeGenerations - 1
							else
								SM("Attempted to download from which is not audio!")
							end
						else
						end
					end,
					}
				end
			else
				SOUND:PlayOnce(path)
			end
		end

		-- we only bother checking scrollers to see if both players are
		-- trying to choose the same profile if there are scrollers because
		-- there are local profiles.  If there are no local profiles, there are
		-- no scrollers to compare.
		if PROFILEMAN:GetNumLocalProfiles() > 0
		-- and if both players have joined and neither is using a memorycard
		and #GAMESTATE:GetHumanPlayers() > 1 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then
			-- and both players are trying to choose the same profile
			if scrollers[PLAYER_1]:get_info_at_focus_pos().index == scrollers[PLAYER_2]:get_info_at_focus_pos().index
			-- and that profile they are both trying to choose isn't [GUEST]
			and scrollers[PLAYER_1]:get_info_at_focus_pos().index ~= 0 then
				-- broadcast an InvalidChoice message to play the "Common invalid" sound
				-- and "shake" the playerframe for the player that just pressed start
				MESSAGEMAN:Broadcast("InvalidChoice", {PlayerNumber=event.PlayerNumber})
				return
			end
		end
		if (#GAMESTATE:GetHumanPlayers() > playersSelected or lastPlayerNumber == event.PlayerNumber) then
			playersSelected = 2
			MESSAGEMAN:Broadcast("Cursor", {PlayerNumber=event.PlayerNumber})
			lastPlayerNumber = event.PlayerNumber
			MESSAGEMAN:Broadcast("InvalidChoice", {PlayerNumber=event.PlayerNumber})
			return
		end
		MESSAGEMAN:Broadcast("Cursor", {PlayerNumber=event.PlayerNumber})
		finished = true
		-- otherwise, play the StartButton sound
		MESSAGEMAN:Broadcast("StartButton")
		-- and queue the OffCommand for the entire screen
		topscreen:queuecommand("Off"):sleep(0.4)
	end
end
Handle.Center = Handle.Start

Handle.MenuLeft = function(event)

	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) and MEMCARDMAN:GetCardState(event.PlayerNumber) == 'MemoryCardState_none' then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0
		if index - 1 > -1 then
			if SL.Global.AchievementMenuActive then
				local data = profile_data[index+index_padding]
				local achievements = af:GetChild('AchievementFrame')
				if event.button == "MenuLeft" then
					data.activePack = data.activePack == "Default" and "Trials" or "Default"
				else
					data.achievementIndex = data.achievementIndex - (string.match(event.button, "Up") and 8 or 1)
					if data.achievementIndex < 1 then
						data.achievementIndex = 1
					end
				end
				achievements:playcommand("Set", data)
			elseif SL.Global.AchievementPackMenu then
				local achievementPacks = af:GetChild('AchievementPacksFrame')
				data.activePack = data.activePack - (string.match(event.button, "Up") and 8 or 1)
				if data.activePack < 1 then
					data.activePack = 1
				end
				achievementPacks:playcommand("Set", data)
			else
				if event.button ~= "MenuLeft" then return end
				MESSAGEMAN:Broadcast("DirectionButton")
				scrollers[event.PlayerNumber]:scroll_by_amount(-1)
	
				local data = profile_data[index+index_padding-1]
				local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
				frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
				frame:playcommand("Set", data)
				local achievements = af:GetChild('AchievementFrame')
				achievements:playcommand("Set", data)	
			end
		end
	end
end

Handle.MenuUp = Handle.MenuLeft

Handle.DownLeft = Handle.MenuLeft

Handle.MenuRight = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) and MEMCARDMAN:GetCardState(event.PlayerNumber) == 'MemoryCardState_none' then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0
		if index+1 < PROFILEMAN:GetNumLocalProfiles()+1 then
			if SL.Global.AchievementMenuActive then
				local data = profile_data[index+index_padding]
				local achievements = af:GetChild('AchievementFrame')
				if event.button == "MenuRight" then
					data.activePack = data.activePack == "Default" and "Trials" or "Default"
				else
					data.achievementIndex = data.achievementIndex + (string.match(event.button, "Down") and 8 or 1)
					if data.achievementIndex > #SL.Accolades.Achievements[data.activePack] then
						data.achievementIndex = #SL.Accolades.Achievements[data.activePack]
					end
					if data.achievementIndex > #SL.Accolades.Achievements[data.activePack] then
						data.achievementIndex = #SL.Accolades.Achievements[data.activePack]
						-- if data.achievementIndex < 32 then
						-- 	MESSAGEMAN:Broadcast("Page", {Player = event.PlayerNumber, Page = 3})
						-- else
						-- 	MESSAGEMAN:Broadcast("Page", {Player = event.PlayerNumber, Page = 3})
						-- end
					-- else
					-- 	MESSAGEMAN:Broadcast("Page", {Player = event.PlayerNumber, Page = 1})
					end
				end

				achievements:playcommand("Set", data)
			elseif SL.Global.AchievementPackMenu then
				local achievementPacks = af:GetChild('AchievementPacksFrame')
				data.activePack = data.activePack + (string.match(event.button, "Down") and 8 or 1)
				if data.achievementIndex > #SL.Accolades.Achievements[data.activePack] then
					data.achievementIndex = #SL.Accolades.Achievements[data.activePack]
				end
				if data.activePack > 24 then
					data.activePack = 24
				end
				achievementPacks:playcommand("Set", data)
			else
				if event.button ~= "MenuRight" then return end
				MESSAGEMAN:Broadcast("DirectionButton")
				scrollers[event.PlayerNumber]:scroll_by_amount(1)

				local data = profile_data[index+index_padding+1]
				local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
				frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
				frame:playcommand("Set", data)
				local achievements = af:GetChild('AchievementFrame')
				achievements:playcommand("Set", data)
			end
		end
	end
end

Handle.MenuDown = Handle.MenuRight

Handle.DownRight = Handle.MenuRight
Handle.EffectUp = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) and MEMCARDMAN:GetCardState(event.PlayerNumber) == 'MemoryCardState_none' then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0
		if index+1 < PROFILEMAN:GetNumLocalProfiles()+1 then
			local data = profile_data[index+index_padding]
			local achievements = af:GetChild('AchievementFrame')
			data.achievementIndex = data.achievementIndex + (event.GameButton == "MenuDown" and 8 or 1)
			if data.achievementIndex > #SL.Accolades.Achievements[data.activePack] then
				data.achievementIndex = #SL.Accolades.Achievements[data.activePack]
			end
			if data.achievementIndex > 24 then
				data.achievementIndex = 24
			end
			achievements:playcommand("Set", data)
		end
	end
end
Handle.Up = Handle.MenuUp
Handle.Down = Handle.MenuDown
Handle.Right = Handle.MenuRight
Handle.Left =Handle.MenuLeft

Handle.Back = function(event)
	if SL.Global.AchievementMenuActive then
		local achievements = af:GetChild('AchievementFrame')
		achievements:playcommand("Hide", data)
		SL.Global.AchievementMenuActive = false
	elseif SL.Global.AchievementPackMenu then
		local achievementPacks = af:GetChild('AchievementPacksFrame')
		achievementPacks:playcommand("Hide", data)
		SL.Global.AchievementPackMenu = false
	elseif GAMESTATE:GetNumPlayersEnabled()==0 then
		if SL.Global.FastProfileSwitchInProgress then
			-- Going back to the song wheel without any players connected doesn't
			-- make much sense; disallow dismissing the ScreenSelectProfile
			-- top screen until at least one player has joined in
			MESSAGEMAN:Broadcast("PreventEscape")
		else
			-- On the other hand, dismissing the regular ScreenSelectProfile
			-- (not in fast switch mode) is perfectly fine since we can just go
			-- back to the previous screen
			SCREENMAN:GetTopScreen():Cancel()
		end
	else
		MESSAGEMAN:Broadcast("BackButton", {PlayerNumber=event.PlayerNumber})
		if (playersSelected > 1) then
			playersSelected = 1
			lastPlayerNumber = nil
			return
		end
		-- ScreenSelectProfile:SetProfileIndex() will interpret -2 as
		-- "Unjoin this player and unmount their USB stick if there is one"
		-- see ScreenSelectProfile.cpp for details
		SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, -2)
		-- CurrentStyle has to be explicitly set to single in order to be able to
		-- unjoin a player from a 2-player setup
		if SL.Global.FastProfileSwitchInProgress and GAMESTATE:GetNumSidesJoined() == 1 then
			GAMESTATE:SetCurrentStyle("single")
			SCREENMAN:GetTopScreen():playcommand("Update")
		end
	end
end


local InputHandler = function(event)
	if finished then return false end
	if not event or not event.button then return false end
	if (PreferredStyle=="single" or PreferredStyle=="double") and event.PlayerNumber ~= mpn then return false	end
	if event.type ~= "InputEventType_Release" then
		if Handle[event.button] then Handle[event.button](event) end
		
	end
end

return InputHandler
