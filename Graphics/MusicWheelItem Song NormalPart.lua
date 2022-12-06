-- the MusicWheelItem for CourseMode contains the basic colored Quads
-- use that as a common base, and add in a Sprite for "Has Edit"
local af = LoadActor("./MusicWheelItem Course NormalPart.lua")

local stepstype = GAMESTATE:GetCurrentStyle():GetStepsType()

-- using a png in a Sprite ties the visual to a specific rasterized font (currently Miso Light),
-- but Sprites are cheaper than BitmapTexts, so we should use them where dynamic text is not needed
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("", "Has Edit (doubleres).png"),
	InitCommand=function(self)
		self:horizalign(left):visible(false):zoom(0.375)
		self:x( _screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 8 )

		if DarkUI() then self:diffuse(0,0,0,1) end
	end,
	SetCommand=function(self, params)
		self:visible(params.Song and params.Song:HasEdits(stepstype) or false)
	end
}

af[#af+1] = Def.Sprite{
	-- This will likely rarely be used, but it's here because there was a situation for it.
	-- In Fall 2022, the PSU cab underwent a lot of maintenance, including an overhaul to the pads.
	-- While the pads were being powdercoated, the PSU cab had pump pads in place of its ITG pads.
	-- I put most of the pump official charts on the machine, but I also used a dance -> pump chart converter
	-- to convert all of the songs on the machine to pump. 
	-- You can imagine what sort of... "mixed" results that had. But... it wasn't that bad? There were a lot of charts
	-- that generated pretty well. Interesting tech that actually worked. I added this tag to the charts so
	-- players know the difference between charts made for pump and charts converted from dance.
	
	-- You can add the Autogen tag to show in the music wheel by putting 'autogen' as your simfile's origin.
	-- I've been using Origin as a place to hold certain information about the chart for the theme.
	Texture=THEME:GetPathG("", "Autogen (doubleres).png"),
	InitCommand=function(self)
	  self:horizalign(left):visible(false):zoom(0.375)
	  self:x( _screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 36 )
  
	  if DarkUI() then self:diffuse(0,0,0,1) end
	end,
	SetCommand=function(self, params)
	  self:visible(params.Song and (params.Song:GetOrigin():find('autogen')) or false)
	end
  }
return af