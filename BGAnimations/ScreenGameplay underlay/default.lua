-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local holdingCtrl = false

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
