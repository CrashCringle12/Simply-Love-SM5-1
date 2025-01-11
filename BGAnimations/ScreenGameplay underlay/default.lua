-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local holdingCtrl = false
local po = {}
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	po[player] = GAMESTATE:GetPlayerState(player):GetPlayerOptions('ModsLevel_Song')
end
-- helper function for returning the player AF
-- works as expected in ScreenGameplay
--     arguments:  pn is short string PlayerNumber like "P1" or "P2"
--     returns:    the "PlayerP1" or "PlayerP2" ActorFrame in ScreenGameplay
--                 or, the unnamed equivalent in ScrenEdit
local GetPlayerAF = function(pn)
    local topscreen = SCREENMAN:GetTopScreen()
    if not topscreen then
        lua.ReportScriptError(
            "GetPlayerAF() failed to find the player ActorFrame because there is no Screen yet.")
        return nil
    end
    local apple = ""
    if pn == 0 then
		for name,layer in pairs(topscreen:GetChildren()) do
			if (name=="PlayerP1" or name=="PlayerP2") then
				--layer:smooth(1.5):diffusealpha(0)
			end
			if layer then
				apple = apple .. name .. " "
				--SM(apple)
			end
		end
        return nil
    end

    local playerAF = nil

    -- Get the player ActorFrame on ScreenGameplay
    -- It's a direct child of the screen and named "PlayerP1" for P1
    -- and "PlayerP2" for P2.
    -- This naming convention is hardcoded in the SM5 engine.
    --
    -- ScreenEdit does not name its player ActorFrame, but we can still find it.

    -- find the player ActorFrame in edit mode
    if (THEME:GetMetric(topscreen:GetName(), "Class") == "ScreenEdit") then
        -- loop through all nameless children of topscreen
        -- and find the one that contains the NoteField
        -- which is thankfully still named "NoteField"
        for _, nameless_child in ipairs(topscreen:GetChild("")) do
            if nameless_child:GetChild("NoteField") then
                playerAF = nameless_child
                break
            end
        end

        -- find the player ActorFrame in gameplay
    else
        local player_af = topscreen:GetChild("Player" .. pn)
        if player_af then playerAF = player_af end
    end

    return playerAF
end
------

-- For each player check if speed mod type is R
-- If it is, set the speed mod to the value in the SL table
for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	if SL[pn].ActiveModifiers.SpeedModType == "R" then
		local mini = tonumber(SL[pn].ActiveModifiers.Mini:sub(1, -2)) / 100
		local rmod = 720000/(SL[pn].ActiveModifiers.SpeedMod * (2-mini))
		GAMESTATE:ApplyGameCommand("mod,m"..rmod, pn)
	end
end
-- If the style is TwoPlayersSharedSides, we need to set the speed mod for the routine as well
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_TwoPlayersSharedSides" then
	local xmod = po[PLAYER_1]:XMod()
	local mmod = po[PLAYER_1]:MMod()
	local cmod = po[PLAYER_1]:CMod()
	local mini = po[PLAYER_1]:Mini()

	local speedmod     = (cmod ~= nil and cmod)   or (mmod ~= nil and mmod)   or (xmod ~= nil and xmod)
	local speedmod_str = (cmod ~= nil and "CMod") or (mmod ~= nil and "MMod") or (xmod ~= nil and "XMod")

	local fmt = {
		XMod = "mod,%.2fx",
		MMod = "mod,m%d",
		CMod = "mod,c%d",
	}
	local gcString = fmt[speedmod_str]:format(speedmod)
	gcString = gcString .. ""
	po[PLAYER_2]:Mini(mini)
	-- apply the new speed mod to the player immediately
	GAMESTATE:ApplyGameCommand(gcString, PLAYER_2)
	po[PLAYER_2]:Mini(mini)
end
local RestartHandler = function(event)
	if not event then return end

	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = true
		elseif event.DeviceInput.button == "DeviceButton_r" then
			if holdingCtrl then
				SCREENMAN:GetTopScreen():SetPrevScreenName("ScreenGameplay"):SetNextScreenName("ScreenGameplay"):begin_backing_out()
			end
		end
	elseif event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = false
		end
	end
end

local t = Def.ActorFrame{
	Name="GameplayUnderlay",
	OnCommand=function(self)
		if ThemePrefs.Get("KeyboardFeatures") and PREFSMAN:GetPreference("EventMode") and not GAMESTATE:IsCourseMode() then
			SCREENMAN:GetTopScreen():AddInputCallback(RestartHandler)
		end
		GetPlayerAF(0)
	end,
	CodeMessageCommand=function(self, params)
		local time = GAMESTATE:GetCurrentSong():MusicLengthSeconds()
		local seconds = math.floor(time % 60)
        local song_progress = GAMESTATE:GetPlayerState(pn):GetSongPosition():GetMusicSeconds() / time
		-- The AddScrollSpeed and SubtractScrollSpeed codes allow players to modify their speed in gameplay
		-- similar to functionality in StepManiaX. Players are only able to change their speed within the first
		-- 10% of the song. This is to prevent players from changing their speed during "difficult" segments to pass
		-- This is only available to players using Xmod
		-- TODO Maybe: Check if song has speed changes? If so, don't allow speed changes
		if song_progress < 0.10 then
			local pn = ToEnumShortString(params.PlayerNumber)
			if params.Name == "AddScrollSpeed" then
				if (SL[pn].ActiveModifiers.SpeedModType == "X") then
					SL[pn].ActiveModifiers.SpeedMod = SL[pn].ActiveModifiers.SpeedMod + 0.1
					SM(SL[pn].ActiveModifiers.SpeedMod)
				end
				GAMESTATE:GetPlayerState(params.PlayerNumber):GetPlayerOptions("ModsLevel_Song"):ScrollSpeed(SL[pn].ActiveModifiers.SpeedMod, 1)

			elseif params.Name == "SubtractScrollSpeed" then
				local pn = ToEnumShortString(params.PlayerNumber)
				if (SL[pn].ActiveModifiers.SpeedModType == "X") then
					SL[pn].ActiveModifiers.SpeedMod = SL[pn].ActiveModifiers.SpeedMod - 0.1
					SM(SL[pn].ActiveModifiers.SpeedMod)
				end
				GAMESTATE:GetPlayerState(params.PlayerNumber):GetPlayerOptions("ModsLevel_Song"):ScrollSpeed(SL[pn].ActiveModifiers.SpeedMod, 1)
			end
		end
	end,
}

for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/Danger.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/StepStatistics/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/BackgroundFilter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/nice.lua", player)
end

-- UI elements shared by both players
t[#t+1] = LoadActor("./Shared/VersusStepStatistics.lua")
t[#t+1] = LoadActor("./Shared/Header.lua")
t[#t+1] = LoadActor("./Shared/SongInfoBar.lua") -- song title and progress bar

-- per-player UI elements
for player in ivalues(Players) do
	-- Tournament Mode modifications. Put this before everything as it sets
	-- player mods and other actors below might depend on it.
	t[#t+1] = LoadActor("./PerPlayer/TournamentMode.lua", player)

	t[#t+1] = LoadActor("./PerPlayer/UpperNPSGraph.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/TargetScore/default.lua", player)

	-- All NoteField specific actors are contained in this file.
	t[#t+1] = LoadActor("./PerPlayer/NoteField/default.lua", player)

end

-- add to the ActorFrame last; overlapped by StepStatistics otherwise
t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

return t
