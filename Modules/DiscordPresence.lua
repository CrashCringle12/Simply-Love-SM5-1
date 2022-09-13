local t = {}
local discordPresence = {
    startTime = os.time(),
    lastSeenSong = "",
    smalltext = "",
    state = "",
    details = "",
    largetext = "",
}
t["ScreenSelectMusic"] = Def.ActorFrame {
    ModuleCommand=function(self)
		discordPresence.smalltext = GAMESTATE:IsEventMode() and "Event Mode" or GAMESTATE:GetCoins().." credits remaining..."
		discordPresence.state = GAMESTATE:IsCourseMode() and "Playing ".. SL.Global.GameMode.." "..GAMESTATE:GetCurrentStyle():GetName().. "s marathon" or "Playing ".. SL.Global.GameMode.." "..GAMESTATE:GetCurrentStyle():GetName().. "s"
		if not transitioning_out then
			GAMESTATE:UpdateDiscordPresenceDetails("Stage: "..(GAMESTATE:GetCurrentStageIndex()+1) .." || "..GAMESTATE:GetNumSidesJoined().." Player",discordPresence.smalltext,"default","selectmusic","Selecting Music...",discordPresence.state, discordPresence.startTime)
		else
			discordPresence.startTime = os.time()
			GAMESTATE:UpdateDiscordPresenceDetails("Stage: "..(GAMESTATE:GetCurrentStageIndex()+1) .." || "..GAMESTATE:GetNumSidesJoined().." Player",discordPresence.smalltext,"default","selectmusic","Selecting Music...",discordPresence.state, discordPresence.startTime)
        end
    end 
}
t["ScreenTitleMenu"] = Def.ActorFrame {
    ModuleCommand=function(self)
        GAMESTATE:UpdateDiscordMenu("Title Menu: Simply "..ThemePrefs.Get("VisualStyle"))
    end
}
t["ScreenEdit"] = Def.ActorFrame {
    ModuleCommand=function(self)
        local groupName = GAMESTATE:GetCurrentSong():GetGroupName()
        local style = GAMESTATE:GetCurrentStyle():GetName()
        local bpm
        local bpms = GAMESTATE:GetCurrentSong():GetDisplayBpms()
        if bpms[1] == bpms[2] then bpm = bpms[1]
        elseif bpms[1] <= 0 then bpm = bpms[2]
        elseif bpms[2] <= 0 then bpm = bpms[1]
        else bpm = bpms[1].. " - "..bpms[2] end
        local currBeat = GAMESTATE:GetSongBeat()
        local lastBeat = round(GAMESTATE:GetCurrentSong():GetLastBeat())
        GAMESTATE:UpdateDiscordPresenceDetails("Working in the ".. groupName .." pack.","Current beat: ".. currBeat.."/".. lastBeat .." ("..bpm.."bpm)", "default", "editing", "Currently in Edit Mode..", "Editing a ".. style  .. "s chart",discordPresence.startTime)
    end
}
t["ScreenEditMenu"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SM(groupName)
        GAMESTATE:UpdateDiscordPresence("This is where the magic happens...", "Currently in Edit Mode..", "Browsing the Edit Menu",discordPresence.startTime)    
    end
}
t["ScreenPlayerOptions"] = Def.ActorFrame {
    ModuleCommand=function(self)
        SM(groupName)
        GAMESTATE:UpdateDiscordPresenceDetails("Song: "..GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." | Stage: "..GAMESTATE:GetCurrentStageIndex()+1,GAMESTATE:GetNumSidesJoined().." Player || "..discordPresence.smalltext,"default","selectmusic","Entering Players Options...",discordPresence.state, discordPresence.startTime)
    end
}


return t