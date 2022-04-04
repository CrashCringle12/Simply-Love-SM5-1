local transitioning_out = false

local Update = function(self, dt)
	if not transitioning_out then
		SL.Global.MenuTimer.ScreenSelectMusic = SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds()
	end
end

return Def.ActorFrame{
	InitCommand=function(self)
		-- if the MenuTimer is being used, save the current number of seconds remaining
		-- before transitioning to the next screen.  In this manner, we can reinstate this
		-- value if the player opts to return to ScreenSelectMusic from ScreenPlayerOptions.
		if PREFSMAN:GetPreference("MenuTimer") then
			self:SetUpdateFunction(Update)
		end
		-- SL.Global.DiscordPresence.smalltext = GAMESTATE:IsEventMode() and "Event Mode" or GAMESTATE:GetCoins().." credits remaining..."
		-- SL.Global.DiscordPresence.state = GAMESTATE:IsCourseMode() and "Playing ".. SL.Global.GameMode.." "..GAMESTATE:GetCurrentStyle():GetName().. "s marathon" or "Playing ".. SL.Global.GameMode.." "..GAMESTATE:GetCurrentStyle():GetName().. "s"
		-- if not transitioning_out then
		-- 	GAMESTATE:UpdateDiscordPresenceDetails("Stage: "..(GAMESTATE:GetCurrentStageIndex()+1) .." || "..GAMESTATE:GetNumSidesJoined().." Player",SL.Global.DiscordPresence.smalltext,"default","selectmusic","Selecting Music...",SL.Global.DiscordPresence.state, SL.Global.DiscordPresence.startTime)
		-- else
		-- 	SL.Global.DiscordPresence.startTime = os.time()
		-- 	GAMESTATE:UpdateDiscordPresenceDetails("Stage: "..(GAMESTATE:GetCurrentStageIndex()+1) .." || "..GAMESTATE:GetNumSidesJoined().." Player",SL.Global.DiscordPresence.smalltext,"default","selectmusic","Selecting Music...",SL.Global.DiscordPresence.state, SL.Global.DiscordPresence.startTime)
		-- end
	end,
	ViewGalleryCommand=function(self)
		transitioning_out = true
	end,
	ShowPressStartForOptionsCommand=function(self)
		transitioning_out = true
	end
}