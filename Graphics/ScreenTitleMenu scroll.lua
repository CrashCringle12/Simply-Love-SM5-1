local index = Var("GameCommand"):GetIndex()
local has_focus = false

local VirtualIndex = 1
local MaxIndex = 4
local Scroller
local ScrollSound = THEME:GetPathS("MusicWheel", "change.ogg")
local SelectSound = THEME:GetPathS("Common", "start.ogg")
local ScrollLength = get_music_file_length(ScrollSound)
local SelectLength = get_music_file_length(SelectSound)
local Volume = PREFSMAN:GetPreference("SoundVolume")/10


-- ChoiceNames="1,2,3,4"
-- DefaultChoice="1"
-- Choice1="applydefaultoptions;screen,"..Branch.AllowScreenSelectProfile()..";text,Dance Mode"
-- Choice2="screen,ScreenEditMenu;text,Edit Mode"
-- Choice3="screen,ScreenOptionsService;text,Options"
-- Choice4="screen,ScreenExit;text,Exit"

-- ScrollerX=_screen.cx
-- ScrollerY=_screen.cy+_screen.h/3.8
-- ScrollerTransform=function(self,offset,itemIndex,numItems) self:y(22*offset) end


local InputHandler = function(event)
	
	-- Don't run any mouse input if the mouse is offscreen.
	if not IsMouseOnScreen() then return end

	-- if (somehow) there's no event, bail
	if not event then return end
	local event11 = event
	event11.MouseX = INPUTFILTER:GetMouseX()
	event11.MouseY = INPUTFILTER:GetMouseY()
	event11.CenterX = _screen.cx
	event11.HeightY = SCREEN_HEIGHT
	if event.type == "InputEventType_FirstPress" and  event.type ~= "InputEventType_Release" then
		
		if event.DeviceInput.button == "DeviceButton_mousewheel up" or event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
			if VirtualIndex == 1 then
				VirtualIndex = MaxIndex
			else
				VirtualIndex = VirtualIndex - 1
			end
			MESSAGEMAN:Broadcast("UpdateScroll")
			-- the engine will already play this with the menu buttons, so we only need to do it for the mouse.
			if event.DeviceInput.button == "DeviceButton_mousewheel up" then
				MESSAGEMAN:Broadcast('ScrollSound')
			end
		end
		
		if event.DeviceInput.button == "DeviceButton_mousewheel down" or event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
			if VirtualIndex == MaxIndex then
				VirtualIndex = 1
			else
				VirtualIndex = VirtualIndex + 1
			end
			MESSAGEMAN:Broadcast("UpdateScroll")
			-- the engine will already play this with the menu buttons, so we only need to do it for the mouse.
			if event.DeviceInput.button == "DeviceButton_mousewheel down" then
				MESSAGEMAN:Broadcast('ScrollSound')
			end
		end
		
		
		-- Advance to the next screen on enter.
		if event.GameButton == "Start" then
			if VirtualIndex == 1 then
				SCREENMAN:SetNewScreen("ScreenSelectProfile")
			elseif VirtualIndex == 2 then
				SCREENMAN:SetNewScreen("ScreenEditMenu")
			elseif VirtualIndex == 3 then
				SCREENMAN:SetNewScreen("ScreenOptionsService")
			elseif VirtualIndex == 4 then
				SCREENMAN:SetNewScreen("ScreenExit")
			end
		end
		
		-- or a left click
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			-- check which choice is selected to determine the zoom.
			if IsMouseGucci(_screen.cx-2,_screen.h-115, 670, 105, "center", "middle", VirtualIndex ==1 and 0.4 or 0.3) then
				MESSAGEMAN:Broadcast('SelectSound')
				SCREENMAN:SetNewScreen(Branch.AllowScreenSelectProfile())
			elseif IsMouseGucci(_screen.cx-3,_screen.h - (_screen.h-386), 688, 105, "center", "middle", VirtualIndex ==2 and 0.4 or 0.3) then
				MESSAGEMAN:Broadcast('SelectSound')
				SCREENMAN:SetNewScreen("ScreenEditMenu")
			elseif IsMouseGucci(_screen.cx-3,(_screen.h-410), 515, 106, "center", "middle", VirtualIndex ==3 and 0.4 or 0.3) then
				MESSAGEMAN:Broadcast('SelectSound')
				SCREENMAN:SetNewScreen("ScreenOptionsService")
			elseif IsMouseGucci(_screen.cx-2,(_screen.h-4311), 282, 106, "center", "middle", VirtualIndex ==4 and 0.4 or 0.3) then
				MESSAGEMAN:Broadcast('SelectSound')
				SCREENMAN:SetNewScreen("ScreenExit")
			end
		end
		
	end

end
local t = Def.ActorFrame{
	OnCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		screen:AddInputCallback(InputHandler)
		Scroller = screen:GetChild("Scroller")
	end,
	
	UpdateScrollMessageCommand=function(self)
		Scroller:playcommand("LoseFocus")
		Scroller:SetDestinationItem(VirtualIndex)
		Scroller:GetChild("ScrollChoice"..VirtualIndex):playcommand("GainFocus")
	end,
	
	-- Scroll Sound
	Def.Sound {
		File=ScrollSound,
		Name="ScollerSound",
		IsAction=true,

		ScrollSoundMessageCommand=function(self)
			self:get():volume(Volume)
			self:play()
		end,
	},
	
	-- Select Sound
	Def.Sound {
		File=SelectSound,
		Name="SelectSound",
		IsAction=true,

		SelectSoundMessageCommand=function(self)
			self:get():volume(Volume)
			self:play()
		end,
	},
}

-- this renders the text of a single choice in the scroller
t[#t+1] = LoadFont("Common Bold")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	InitCommand=function(self) self:shadowlength(0.5) end,
	OnCommand=function(self) self:diffusealpha(0):sleep(index*0.075):linear(0.2):diffusealpha(1) end,
	OffCommand=function(self)
		-- if the first TitleMenu choice (Gameplay) was chosen by the player
		-- broadcast using MESSAGEMAN
		SM("TitleMenuToGameplay")
		if index==0 and has_focus then
			-- actors can hook into this like
			-- TitleMenuToGameplayMessageCommand=function(self) end
			MESSAGEMAN:Broadcast("TitleMenuToGameplay")
		end

		self:sleep(index*0.075):linear(0.18):diffusealpha(0)
	end,
	VisualStyleSelectedMessageCommand=function(self)
		self:playcommand("UpdateColor")
	end,
	UpdateColorCommand=function(self)
		if has_focus then
			local textColor = PlayerColor(PLAYER_2)
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				textColor = GetCurrentColor(true)
			end
			self:diffuse(textColor)
		else
			local textColor = color("#888888")
			if ThemePrefs.Get("RainbowMode") then
				textColor = Color.White
			end
			if ThemePrefs.Get("VisualStyle") == "SRPG8" then
				textColor = color(SL.SRPG8.TextColor)
			end
			self:diffuse(textColor)
		end
	end,

	GainFocusCommand=function(self)
		has_focus = true
		self:stoptweening():zoom(0.5)
		self:accelerate(0.1):glow(1,1,1,0.5)
		self:decelerate(0.05):glow(1,1,1,0)
		self:playcommand("UpdateColor")
	end,
	LoseFocusCommand=function(self)
		has_focus = false
		self:stoptweening():zoom(0.4)
		self:accelerate(0.1):glow(1,1,1,0)
		self:playcommand("UpdateColor")
	end
}

return t
