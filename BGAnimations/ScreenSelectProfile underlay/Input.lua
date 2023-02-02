local args = ...
local af = args.af
local scrollers = args.Scrollers
local localprofile_data = args.ProfileData
local guest_data = args.GuestData


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
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(-1)

			local data = profile_data[index+index_padding-1]
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
			frame:playcommand("Set", data)
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
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(1)

			local data = profile_data[index+index_padding+1]
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
			frame:playcommand("Set", data)
		end
	end
end
Handle.MenuDown = Handle.MenuRight
Handle.DownRight = Handle.MenuRight

Handle.Back = function(event)
	if GAMESTATE:GetNumPlayersEnabled()==0 then
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
		if Handle[event.GameButton] then Handle[event.GameButton](event) end
	end
end

return InputHandler
