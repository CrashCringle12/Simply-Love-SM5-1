local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == "Off" then return end

local FilterAlpha = {
	Dark      = 0.5,
	Darker    = 0.75,
	Darkest   = 0.95,
}

local FilterColors = {
	Rainbow     = color("#000000dd"),
	Pink        = color("#c9855e"),
	Peach       = color("#c9855e"),
	Gold        = color("#e29c18"),    -- Gold
	Original    = color("#000000"),    -- Dark
	Blue        = color("#123456"),    -- Blue
	Light       = color("#FFFFFF"),    -- Light
	Green       = color("#5CE087"),    -- Green
	Grey        = color("#AAAAAA"),    -- Grey
}
return Def.Quad{
	InitCommand=function(self)
		if mods.BackgroundColor == Rainbow or mods.BackgroundColor == "Rainbow" then
			self:xy(GetNotefieldX(player), _screen.cy )
				:rainbow()
				:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
				:zoomto( GetNotefieldWidth(), _screen.h )
		else
			self:xy(GetNotefieldX(player), _screen.cy )
				:diffuse(FilterColors[mods.BackgroundColor])
				:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
				:zoomto( GetNotefieldWidth(), _screen.h )
		end
	end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
	ComboFlashCommand=function(self)
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local FlashColor = nil
		local WorstAcceptableFC = SL.Preferences[SL.Global.GameMode].MinTNSToHideNotes:gsub("TapNoteScore_W", "")

		for i=1, tonumber(WorstAcceptableFC) do
			if pss:FullComboOfScore("TapNoteScore_W"..i) then
				FlashColor = SL.JudgmentColors[SL.Global.GameMode][i]
				break
			end
		end

		if (FlashColor ~= nil) then
			self:accelerate(0.25):diffuse( FlashColor )
				:accelerate(0.5):faderight(1):fadeleft(1)
				:accelerate(0.15):diffusealpha(0)
		end
	end
}