---------------------------------------------------------------------
-- Character Select Wheel(s)
---------------------------------------------------------------------

-- the theme may not have Consensual's sick_wheel.lua in ./Scripts
-- so load a bundled copy now
--LoadActor("../Scripts/Consensual-sick_wheel.lua")

local GalleryScreenshotWheels = {}
	-- Add the full character display
	GalleryScreenshotWheels= setmetatable({}, sick_wheel_mt)


local Screenshots = GetPlayerScreenshotsPath(ThemePrefs.Get("GalleryPlayer"))
--SM(Screenshots)
local duration_between_frames = 0.2

-- the metatable for the fullbody character in the wheel
local wheel_item_mt2 = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=self.name,
				InitCommand=function(subself)
					self.container = subself
				end
			}
			af[#af+1] = Def.BitmapText{
				Font="Common normal",
				InitCommand=function(subself)
					self.bmt = subself
					subself:zoom(0.4)
					subself:diffuse(Color.White)
					subself:y(37)
				end,

			}
			af[#af+1] = Def.Sprite{
				InitCommand=function(subself)
					self.sprite = subself
					subself:diffusealpha(0)
					subself:zoom(0.25)
					subself:animate(true)
				end,
				OnCommand=function(subself)
					subself:sleep(0.2)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(1)
				end,
				OffCommand=function(subself)
					subself:sleep(0.04 * self.index)
					subself:linear(0.2)
					subself:diffusealpha(0)
				end,
				TestCommand=function(subself)
					subself:linear(0.5):zoom(0.16):addrotationx(360)
				end,
			}
			
			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:linear(0.2)
			self.index=item_index

			local OffsetFromCenter = (item_index - math.floor(num_items/2))-1
			local x_padding = 520
			local x = x_padding * OffsetFromCenter
			local z = -1.25 * math.abs(OffsetFromCenter)
			local zoom = (z + math.floor(num_items/2) + 1) * 0.95

			if item_index <= 1 or item_index >= num_items then
				self.container:diffusealpha(0)
			else
				if has_focus then
					self.container:diffusealpha(1)
				else	
					self.container:diffusealpha(1)
				end
			end
			

			self.container:x(x)
			self.container:zoom( zoom )
		end,

		set = function(self, character)
			if not character then return end
			--SM(character)

			--local dir = GAMESTATE:GetCurrentSong():GetSongDir()
			if PROFILEMAN:IsPersistentProfile(ThemePrefs.Get("GalleryPlayer")) then
				local dir = split("/",character)
				local month = split("-",dir[8])[2]
				local year = dir[7]
				local day = split("_",split("-",dir[9])[3])[1]
				self.character = character
				self.bmt:settext( month.. " "..day..", "..year )
				self.sprite:Load(character)
				self.sprite:setsize(418*2.8,300*1.95):zoom(0.11)
			else
				local dir = split("/",character)
				local month = split("-",dir[5])[2]
				local year = dir[4]
				local day = split("_",split("-",dir[6])[3])[1]
				self.character = character
				self.bmt:settext( month.. " "..day..", "..year )
				self.sprite:Load(character)
				self.sprite:setsize(418*2.8,300*1.95):zoom(0.11)
			--self.sprite:SetStateProperties( frames.Down )
			end
		end
	}
}


---------------------------------------------------------------------
-- Initialize generalized Event Handling function(s)
---------------------------------------------------------------------
-- load the InputHandler and pass it the table of params
--local Input = LoadActor( "./Input.lua", params_for_input )

local InputHandler = function(event)
	----------------------------------------------------------------------------

	-- if any of these, don't attempt to handle input
	if not event.PlayerNumber or not event.button then
		return false
	end

	-- truncate "PlayerNumber_P1" into "P1" and "PlayerNumber_P2" into "P2"
	local pn = ToEnumShortString(event.PlayerNumber)
	if event.type == "InputEventType_FirstPress" then

		if event.GameButton == "MenuRight" then
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			GalleryScreenshotWheels:scroll_by_amount(1)
			
		elseif event.GameButton == "MenuLeft" then
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			GalleryScreenshotWheels:scroll_by_amount(-1)
			
		elseif event.GameButton == "Start" then
			GalleryScreenshotWheels.container:queuecommand("Test")
			--##Note
		elseif event.GameButton == "Select" then
			local top_screen = SCREENMAN:GetTopScreen()
			if top_screen then         
			   top_screen:SetNextScreenName("ScreenSelectMusic")
			   top_screen:StartTransitioningScreen("SM_GoToNextScreen")
			end
		end

	end

	return false
end

---------------------------------------------------------------------
-- Primary ActorFrame and children
---------------------------------------------------------------------
local t = Def.ActorFrame{
	InitCommand=function(self)
		self:Center():visible(true):diffusealpha(1)
		self:fov(90)
			-- set_info_set() takes two arguments:
			--		a table of meaningful data to divvy up to wheel items
			--		the index of which item we want to initially give focus to
			GalleryScreenshotWheels:set_info_set(GetPlayerScreenshotsPath(ThemePrefs.Get("GalleryPlayer")), 1)
		-- queue the next command so that we can actually GetTopScreen()
		self:queuecommand("Capture")
	--		:sleep( 60/140 * 16 ):accelerate(0.5):diffusealpha(0)
	end,
	CharacterSelectionMessageCommand=function(self)
		self:visible(true):accelerate(0.4):diffusealpha(1)
	end,
	CaptureCommand=function(self)
		
		-- attach our InputHandler to the TopScreen and pass it this ActorFrame
		-- so we can manipulate stuff more easily from there
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )
	end,
	
}
	
-- add a CharacterWheel for each available player
	local x_pos = _screen.cx-(_screen.w*160/640)+50
	t[#t+1] = GalleryScreenshotWheels:create_actors( "GalleryScreenshotWheel", 6, wheel_item_mt2, x_pos-265 , _screen.cy-230)
	--GalleryScreenshotWheels:scroll_by_amount(1)


---------------------------------------------------------------------
return t