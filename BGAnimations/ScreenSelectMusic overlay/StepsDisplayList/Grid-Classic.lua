-- this difficulty grid doesn't support CourseMode
-- CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------
local isTrial = false
local num_rows    = 2
local num_columns = 20

local GridZoomX = IsUsingWideScreen() and 0.435 or 0.39
local BlockZoomY = IsUsingWideScreen() and 0.125 or 0.27

local GetStepsToDisplay = LoadActor("./StepsToDisplay.lua")

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=function(self) self:vertalign(top):xy(IsUsingWideScreen() and _screen.cx-30 or _screen.cx-160 , _screen.cy + 50):rotationz(-90) end,

	OnCommand=function(self)                           self:queuecommand("RedrawStepsDisplay") end,
	CurrentSongChangedMessageCommand=function(self)    self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,

	RedrawStepsDisplayCommand=function(self)

		local song = GAMESTATE:GetCurrentSong()
		-- isTrial = song and FindInTable(song, SL.Global.Trials)
		
		if song then
			local steps = SongUtil.GetPlayableSteps( song )
			if steps then
				local StepsToDisplay = { GAMESTATE:GetCurrentSteps(PLAYER_1), GAMESTATE:GetCurrentSteps(PLAYER_2) }
				for i=1,num_rows do
					if StepsToDisplay[i] then
						-- if this particular song has a stepchart for this row, update the Meter
						-- and BlockRow coloring appropriately
						local meter = StepsToDisplay[i]:GetMeter()
						local difficulty = StepsToDisplay[i]:GetDifficulty()
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Set", {Meter=meter, Difficulty=difficulty})
					else
						-- otherwise, set the meter to an empty string and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Unset")
					end
				end
			end
		else
			self:playcommand("Unset")
		end
	end,

	-- - - - - - - - - - - - - -

	-- background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:diffuse(color("#1e282f")):zoomto(150, 50):addy(-6)
			else
				self:diffuse(color("#1e282f")):zoomto(300, 94)
			end
			self:diffusealpha(0.9)
			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.9)
			end
		end
	},
}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=function(self) self:horizalign(left):vertalign(top):xy(8, -45 ) end,
}


for RowNumber=1,num_rows do

	Grid[#Grid+1] =	Def.Sprite{
		Name="Blocks_"..RowNumber,
		Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

		InitCommand=function(self) self:diffusealpha(0) end,
		OnCommand=function(self)
			local width = self:GetWidth()
			local height= self:GetHeight()
			self:y( RowNumber * 25)
			self:zoomto(155, 25)
		end,
		SetCommand=function(self, params)
			-- the engine's Steps::TidyUpData() method ensures that difficulty meters are positive
			-- (and does not seem to enforce any upper bound that I can see)
			self:customtexturerect(0, 0, num_columns, 1)
			self:cropright( 1 - (params.Meter * (1/num_columns)) )
			self:diffuse( DifficultyColor(params.Difficulty, true) )
			-- if isTrial then
			-- 	-- if the song is not in SL.Global.TrialDiffs then all difficulties count
			-- 	-- If the song is in SL.Global.TrialDiffs, only the difficulties in that table count
			-- 	local song = GAMESTATE:GetCurrentSong()
			-- 	if SL.Global.TrialDiffs[song:GetSongDir()] then
			-- 		if SL.Global.TrialDiffs[song:GetSongDir()][params.Meter] then
			-- 			self:rainbow()
			-- 		end
			-- 	else
			-- 		--self:rainbow()
			-- 	end
			-- else
			-- 	self:stopeffect()
			-- end
		end,
		UnsetCommand=function(self)
			self:customtexturerect(0,0,0,0)
		end
	}


end

t[#t+1] = Grid

return t