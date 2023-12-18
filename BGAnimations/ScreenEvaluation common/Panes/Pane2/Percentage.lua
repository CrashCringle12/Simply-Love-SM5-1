local player, controller = unpack(...)

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local styletype = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
if (styletype == "TwoPlayersSharedSides") then
	stats = STATSMAN:GetCurStageStats():GetRoutineStageStats()
end
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")
-- Take the average of the CalculateEXScore for both players
local exPercent = 0 
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	exPercent = exPercent + CalculateExScore(pn)
end
exPercent = exPercent / #GAMESTATE:GetHumanPlayers()

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#101519")):zoomto(158.5, SL.Global.GameMode == "Casual" and 60 or 88)
			self:horizalign(controller==PLAYER_1 and left or right)
			self:x(150 * (controller == PLAYER_1 and -1 or 1))
			if SL.Global.GameMode ~= "Casual" then
				self:y(14)
			end
		end
	},

	LoadFont("Wendy/_wendy white")..{
		Name="Percent",
		Text=("%.2f"):format(exPercent),
		InitCommand=function(self)
			self:horizalign(right):zoom(0.585)
			self:x( (controller == PLAYER_1 and 1.5 or 141))
			self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
		end
	}
}
