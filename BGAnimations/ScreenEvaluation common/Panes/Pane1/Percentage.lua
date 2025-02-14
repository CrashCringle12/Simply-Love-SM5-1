local player, controller = unpack(...)
local styletype = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
if (styletype == "TwoPlayersSharedSides") then
	stats = STATSMAN:GetCurStageStats():GetRoutineStageStats()
end
local TNSTypes = {
	'TapNoteScore_W1',
	'TapNoteScore_W2',
	'TapNoteScore_W3',
	'TapNoteScore_W4',
	'TapNoteScore_W5',
	'TapNoteScore_Miss'
}
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
SM(stats:GetActualDancePoints() .. " out of " ..stats:GetPossibleDancePoints() .. " = " .. (stats:GetActualDancePoints() / stats:GetPossibleDancePoints()) * 100, 20)

-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#101519")):zoomto(158.5, (styletype == "TwoPlayersSharedSides" or SL.Global.GameMode == "FA+") and 88 or 60)
			self:horizalign(controller==PLAYER_1 and left or right)
			self:x(150 * (controller == PLAYER_1 and -1 or 1))
			if styletype == "TwoPlayersSharedSides" or SL.Global.GameMode == "FA+" then
				self:y(14)
			end
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},

	LoadFont("Wendy/_wendy white")..{
		Name="Percent",
		Text=percent,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.585)
			self:x( (controller == PLAYER_1 and 1.5 or 141))
		end
	}
}
