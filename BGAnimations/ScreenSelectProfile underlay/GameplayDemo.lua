local game = GAMESTATE:GetCurrentGame():GetName()
local ScreenName, TopScreen, MPN = nil, nil, GAMESTATE:GetMasterPlayerNumber()
local choices = {}

local arrow	= {
	w = 12,
	h = 35,
	rotation = {
		center = 0,
		up = 45,
		upright = 90,
		right = 135,
		downright= 180,
		down = 225,
		downleft = 270,
		left = 315,
		upleft = 0,
	},
	x = {
		pump = { downleft=-48, upleft=-24, center=0, upright=24, downright=48 },
		techno = { downleft=-84, left=-60, upleft=-36, down=-12, up=12, upright=36, right=60, downright=84 },
		dance = { left=-36, down=-12, up=12, right=36 }
	},
	columns = {
		pump = { "downleft", "upleft", "center", "upright", "downright" },
		techno = { "downleft", "left", "upleft", "down", "up", "upright", "right", "downright" },
		dance = { "left", "down", "up", "right" }
	}
}

local timePerArrow = 0.2
local pattern = {
	dance =	{
		"left", "down", "left", "right", "down", "up",
		"left", "right", "left", "down", "up", "right",
		"left", "right", "down", "up", "down", "right",
		"left", "right", "up", "down", "up", "right"},
	pump = {
		"upright", "center", "downright", "downleft", "center", "upleft",
		"upright", "downleft", "downright", "center", "upright", "downleft",
		"upleft", "center", "upright", "center", "downright", "upleft",
		"downright", "upright", "center", "upleft", "center", "downleft"},
	techno = {"upleft", "upright", "down", "downright", "downleft", "up", "down", "right", "left", "downright", "downleft", "up"},
}

-- I don't intend to include visualization for kb7, beat, or pop'n,
-- so fall back on the visualization for dance if necessary.
if not pattern[game] then
	game = "dance"
end

local notefield = Def.ActorFrame{
	InitCommand=function(self)
		if game == "dance" then
			self:xy(80,90):zoom(0.625)
		elseif game == "techno" then
			self:zoom(0.6):xy(90,-10)
		elseif game == "pump" then
			self:zoom(0.8):xy(80, 90)
		end
	end,
	OnCommand=function(self)
		TopScreen = SCREENMAN:GetTopScreen()
		ScreenName = TopScreen:GetName()

		-- for choice in THEME:GetMetric(ScreenName, "ChoiceNames"):gmatch('([^,]+)') do
		-- 	choices[#choices+1] = choice
		-- end
	end,
	OffCommand=function(self) self:sleep(0.4):diffusealpha(0) end
}

local function ColumnZoom(column)
	if (game ~= "pump") then return 0.18 end
	return (column == "center") and 0.165 or 0.2
end

-- loop through columns for this gametype and add Receptor arrows
for i, column in ipairs( arrow.columns[game] ) do

	local file = "arrow-body.png"
	if column == "center" then file = "center-body.png" end

	notefield[#notefield+1] = LoadActor( file )..{
		InitCommand=function(self)
			self:rotationz( arrow.rotation[column] )
				:x( arrow.x[game][column] )
				:y(-55)
				:zoom(ColumnZoom(column))
		end
	}
end

local function YieldStepPattern(i, dir)

	local step = Def.ActorFrame{
		InitCommand=function(self) self:queuecommand("Update"):MaskDest() end,
		SetCommand=function(self, params)
			if params then
				-- if params.speedModType == "X" then
				-- 	arrow.h = 25 * params.speedmod
				-- 	timePerArrow = 0.2
				-- 	--SM(params.speedModType .. " ".. params.speedmod.. " ".. arrow.h .. " " .. timePerArrow)
				-- elseif params.speedModType == "M" then
				-- 	arrow.h = 35
				-- 	timePerArrow = 0.2 / (params.speedmod / 600) 
				-- 	--SM(params.speedModType .. " ".. params.speedmod.. " ".. timePerArrow)

				-- end

			end
		end,
		OnCommand=function(self) self:queuecommand("FirstLoopRegular") end,
		UpdateCommand=function(self)
			self:visible(true)
			-- if ScreenName == "ScreenSelectProfile" and TopScreen:GetSelectionIndex(MPN) == 0 and i % 3 ~= 0 then
			-- 	self:visible(false)
			-- end
		end,
		FirstLoopRegularCommand=function(self)
			self:stoptweening()

			self:y( -55 + (i * (arrow.h+5)))
				:rotationz( arrow.rotation[dir] )
				:x( arrow.x[game][dir] )

			self:linear(timePerArrow * i)
				:y(-55)
				:queuecommand("LoopRegular")
		end,
		LoopRegularCommand=function(self)
			-- reset the y of this arrow to a lower position
			self:y(#pattern[game] * arrow.h)
			-- tween the arrow moving up the faux playfield again
			self:linear(timePerArrow *  #pattern[game])
				:y(-55)
				:queuecommand('LoopRegular')
		end,
		FirstLoopMarathonCommand=function(self)
			self:stoptweening()

			self:y( -55 + (i * (arrow.h+5)))
				:rotationz( arrow.rotation[dir] )
				:x( arrow.x[game][dir] )

			self:ease(timePerArrow * i, 75):addrotationz(720)
				:y(-55)
				:queuecommand("LoopMarathon")
		end,
		LoopMarathonCommand=function(self)
			-- reset the y of this arrow to a lower position
			self:y(#pattern[game] * arrow.h)
			-- and tween it spinning up the faux playfield again
			self:ease(timePerArrow * #pattern[game], 75):addrotationz(720)
				:y(-55)
				:queuecommand('LoopMarathon')
		end
	}
	local files
	if dir == "center" then
		files = { "center-body.png", "center-border.png", "center-feet.png" }
	else
		files = {"arrow-border.png", "arrow-body.png", "arrow-stripes.png" }
	end

	for index,file in ipairs(files) do
		step[#step+1] = LoadActor( file )..{
			InitCommand=function(self) self:diffuse(1,1,1,1):zoom(ColumnZoom(dir)) end,
			OnCommand=function(self)
				if file == "center-feet.png" or file == "arrow-stripes.png" then
					self:blend(Blend.Multiply)
				end
				if file == "center-body.png" or file == "center-feet.png" or file == "arrow-body.png" then
					self:diffuse( GetHexColor(i, true) )
				end
			end,
		}
	end

	return step
end

for index, direction in ipairs(pattern[game]) do
	notefield[#notefield+1] = YieldStepPattern(index, direction)
end

return notefield
