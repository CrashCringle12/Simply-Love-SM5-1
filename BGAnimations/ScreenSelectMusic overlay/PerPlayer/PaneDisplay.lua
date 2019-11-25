local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local rv
local zoom_factor = WideScale(0.7,0.8)
--local zoom_factor = WideScale(0.8,0.9)

--This function rounds to a single decimal place.
function roundOne(number)
	return math.floor(number * 10) / 10
end


local x2 = -40
local y2 = x2 + 10
local x3 = 30
local y3 = x3 + 10
local x4 = 64
local y4 = x4 + 24
--These refer to the Notes per Second.
local npsL = 38
local npsD = 38

--16:9
if (roundOne(GetScreenAspectRatio()) == 1.7) then
	x2 = -38
	y2 = x2 + 10
	x3 = 50
	y3 = x3 + 10
	x4 = 83
	y4 = x4 + 24
	npsL = 43
	npsD = 43
	--4:3
	else
		if (roundOne(GetScreenAspectRatio()) == 1.3) then
			 x2 = -30
			 y2 = x2 + 10
			 x3 = 30
			 y3 = x3 + 10
			 x4 = 64
			 y4 = x4 + 24
			 npsL = 32
			 npsD = 32
		end
end


local labelX_col1 = WideScale(-91,-111)
local dataX_col1  = WideScale(-95,-116)

local labelX_col2 = WideScale(x2,y2)
local dataX_col2  = WideScale(x2-4,y2-4)

local labelX_col3 = WideScale(x3,y3)
local dataX_col3 = WideScale(x3-4,y3-4)

local highscoreX = WideScale(x4,y4)
local highscorenameX = WideScale(x4+4,y4+10)

local PaneItems = {}

PaneItems[THEME:GetString("RadarCategory","Taps")] = {
	-- "rc" is RadarCategory
	rc = 'RadarCategory_TapsAndHolds',
	label = {
		x = labelX_col1,
		y = 150,
	},
	data = {
		x = dataX_col1,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Mines")] = {
	rc = 'RadarCategory_Mines',
	label = {
		x = labelX_col2,
		y = 150,
	},
	data = {
		x = dataX_col2,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Jumps")] = {
	rc = 'RadarCategory_Jumps',
	label = {
		x = labelX_col1,
		y = 168,
	},
	data = {
		x = dataX_col1,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Hands")] = {
	rc = 'RadarCategory_Hands',
	label = {
		x = labelX_col2,
		y = 168,
	},
	data = {
		x = dataX_col2,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Holds")] = {
	rc = 'RadarCategory_Holds',
	label = {
		x = labelX_col1,
		y = 186,
	},
	data = {
		x = dataX_col1,
		y = 186
	}
}

PaneItems[THEME:GetString("RadarCategory","Rolls")] = {
	rc = 'RadarCategory_Rolls',
	label = {
		x = labelX_col2,
		y = 186,
	},
	data = {
		x = dataX_col2,
		y = 186
	}
}

PaneItems[THEME:GetString("RadarCategory","Fakes")] = {
	rc = 'RadarCategory_Fakes',
	label = {
		x = labelX_col3,
		y = 168,
	},
	data = {
		x = dataX_col3,
		y = 168
	}
}
PaneItems[THEME:GetString("RadarCategory","Lifts")] = {
	rc = 'RadarCategory_Lifts',
	label = {
		x = labelX_col3,
		y = 186,
	},
	data = {
		x = dataX_col3,
		y = 186
	}
}

local GetNameAndScore = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""

	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
			name = topscore:GetName()
		else
			score = string.format("%.2f%%", 0)
			name = "????"
		end
	end

	return score, name
end


local af = Def.ActorFrame{
	Name="PaneDisplay"..ToEnumShortString(player),

	InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))

		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x( _screen.w * 0.75 + 5)
		end

		self:y(_screen.cy + 5)
	end,

	PlayerJoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:visible(true)
				:zoom(0):croptop(0):bounceend(0.3):zoom(1)
				:playcommand("Set")
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0)
		end
	end,

	-- These playcommand("Set") need to apply to the ENTIRE panedisplay
	-- (all its children) so declare each here
	OnCommand=function(self) self:queuecommand("Set") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	StepsHaveChangedCommand=function(self) self:queuecommand("Set") end,

	SetCommand=function(self)
		local machine_score, machine_name = GetNameAndScore( PROFILEMAN:GetMachineProfile() )

		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name):diffuse({0,0,0,1})

		DiffuseEmojis(self, machine_name)

		if PROFILEMAN:IsPersistentProfile(player) then
			local player_score, player_name = GetNameAndScore( PROFILEMAN:GetProfile(player) )

			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name):diffuse({0,0,0,1})

			DiffuseEmojis(self, player_name)
		end
	end
}

-- colored background for chart statistics
af[#af+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=function(self) self:zoomto(_screen.w/2-10, _screen.h/8):y(_screen.h/2 - 67) end,
	SetCommand=function(self, params)
		if GAMESTATE:IsHumanPlayer(player) then
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	end
}



for key, item in pairs(PaneItems) do

	af[#af+1] = Def.ActorFrame{

		Name=key,
		OnCommand=function(self) self:xy(-_screen.w/20, 6) end,

		-- label
		LoadFont("Common Normal")..{
			Text=key,
			InitCommand=function(self) self:zoom(zoom_factor):xy(item.label.x, item.label.y):diffuse(Color.Black):horizalign(left) end
		},
		--  numerical value
		LoadFont("Common Normal")..{
			InitCommand=function(self) self:zoom(zoom_factor):xy(item.data.x, item.data.y):diffuse(Color.Black):horizalign(right) end,
			OnCommand=function(self) self:playcommand("Set") end,
			SetCommand=function(self)
				local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
				if not SongOrCourse then self:settext("?"); return end

				local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
				if steps then
					rv = steps:GetRadarValues(player)
					local val = rv:GetValue( item.rc )

					-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
					self:settext( val >= 0 and val or "?" )
				else
					self:settext( "" )
				end
			end
		}
	}
end

-- chart difficulty meter
af[#af+1] = LoadFont("_wendy small")..{
	Name="DifficultyMeter",
	InitCommand=function(self) self:horizalign(right):diffuse(Color.Black):xy(_screen.w/4 - 10, _screen.h/2 - 65):queuecommand("Set") end,
	SetCommand=function(self)
		local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if not SongOrCourse then self:settext(""); return end

		local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
		local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"
		self:settext( meter )
	end
}

--MACHINE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScore",
	InitCommand=function(self) self:x(highscoreX):y(156):zoom(zoom_factor):diffuse(Color.Black):horizalign(right) end
}

--MACHINE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreName",
	InitCommand=function(self) self:x(highscorenameX):y(156):zoom(zoom_factor):diffuse(Color.Black):horizalign(left):maxwidth(80) end
}

--Average specificity
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Name="npsLabelBar",
	-- I'm unsure why labelX_col3 doesn't simply get the job done, but eh this does the trick as well
	InitCommand=cmd(zoom, zoom_factor; x, labelX_col3-npsL; y, 141; diffuse, Color.Black; shadowlength, 0.2; halign, 0; queuecommand, "Set"),
	SetCommand=function(self)
		self:settext("__")

	end
}
--Notes per second Label
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Name="npsLabel",
	-- I'm unsure why labelX_col3 doesn't simply get the job done, but eh this does the trick as well
	InitCommand=cmd(zoom, zoom_factor; x, labelX_col3-npsL; y, 156; diffuse, Color.Black; shadowlength, 0.2; halign, 0; queuecommand, "Set"),
	SetCommand=function(self)
		self:settext("Nps")

	end
}

-- Notes per Second data
af[#af+1] = Def.BitmapText{
	Font="_miso",
	Name="nps",
	-- I'm unsure why dataX_col3 doesn't simply get the job done, but eh this does the trick as well
	InitCommand=cmd(zoom, zoom_factor; x, dataX_col3-npsD; y, 156; diffuse, Color.Black; shadowlength, 0.2; halign, 1; queuecommand, "Set"),
	SetCommand=function(self)
		-- Getting the notes per second
		local duration
		local nps

		local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if not song then
			self:settext("?")
			return
		end
		local steps1 = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

		if steps1 then
			rr = steps1:GetRadarValues(player)
			local va = rr:GetValue( 'RadarCategory_TapsAndHolds' )

			if GAMESTATE:IsCourseMode() then
				local Playahs = GAMESTATE:GetHumanPlayers()
				local playah = Playahs[1]
				local trail = GAMESTATE:GetCurrentTrail(playah)

				if trail then
					duration = TrailUtil.GetTotalSeconds(trail)
				end
			else
				local song = GAMESTATE:GetCurrentSong()
				if song then
					duration = song:GetLastSecond() - song:GetFirstSecond()
				end
			end

			duration = duration / SL.Global.ActiveModifiers.MusicRate

			local minutes = 0
			--Calculation of Notes for second here. Accurate to 2 decimal places
			nps = (va / duration) - ((va / duration) % .01)
			if (nps < 0) then
				self:settext('?')
			else
				self:settext(nps)
			end
		end
	end
}

--PLAYER PROFILE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScore",
	InitCommand=function(self) self:x(highscoreX):y(176):zoom(zoom_factor):diffuse(Color.Black):horizalign(right) end
}

--PLAYER PROFILE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScoreName",
	InitCommand=function(self) self:x(highscorenameX):y(176):zoom(zoom_factor):diffuse(Color.Black):horizalign(left):maxwidth(80) end
}

return af