local file = ...

local t = Def.ActorFrame{
	InitCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "ITL")
	end,
	OnCommand=function(self) self:fov(90):accelerate(0.8):diffusealpha(1) end,
	HideCommand=function(self) self:visible(false) end,

	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		if style == "ITL" then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end,

}

-- a simple Quad to serve as the backdrop
t[#t+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse( Color.Black ) end
}

-- add common background here
--t[#t+1] = LoadActor("./wf07still.png")..{ -- If you are having performance issues, use this one instead
	-- add common background here
	--t[#t+1] = LoadActor("./wf07still.png")..{ -- If you are having performance issues, use this one instead
local randomNum  = math.random(1, 100)
if randomNum % 4 == 0 then
    t[#t+1] = LoadActor("./hd277.mp4")..{
        InitCommand = function(self)
            self:zoom(SCREEN_HEIGHT/1080)
            self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        end,
        VisualStyleSelectedMessageCommand=function(self)
            local style = ThemePrefs.Get("VisualStyle")
            if style == "ITL" then
                self:rate(1):visible(true)
            else
                self:rate(0):visible(false)
            end
        end,
    }
elseif randomNum % 4 == 1 then
    t[#t+1] = LoadActor("./hd278.mp4")..{
        InitCommand = function(self)
            self:zoom(SCREEN_HEIGHT/1080)
            self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        end,
        VisualStyleSelectedMessageCommand=function(self)
            local style = ThemePrefs.Get("VisualStyle")
            if style == "ITL" then
                self:rate(1):visible(true)
            else
                self:rate(0):visible(false)
            end
        end,
    }
elseif randomNum % 4 == 2 then
    t[#t+1] = LoadActor("./hd279.mp4")..{
        InitCommand = function(self)
            self:zoom(SCREEN_HEIGHT/1080)
            self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        end,
        VisualStyleSelectedMessageCommand=function(self)
            local style = ThemePrefs.Get("VisualStyle")
            if style == "ITL" then
                self:rate(1):visible(true)
            else
                self:rate(0):visible(false)
            end
        end,
    }
else
    t[#t+1] = LoadActor("./hd280.mp4")..{
        InitCommand = function(self)
            self:zoom(SCREEN_HEIGHT/1080)
            self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        end,
        VisualStyleSelectedMessageCommand=function(self)
            local style = ThemePrefs.Get("VisualStyle")
            if style == "ITL" then
                self:rate(1):visible(true)
            else
                self:rate(0):visible(false)
            end
        end,
    }
end
t[#t+1] = Def.Quad{
	ScreenChangedMessageCommand = function(self)
		self:visible(SCREENMAN:GetTopScreen():GetName() ~= "ScreenTitleMenu")
	end,
	InitCommand = function(self)
		self:zoom(SCREEN_WIDTH, SCREEN_HEIGHT)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		self:diffuse(0,0,0,0.4)
	end
}

return t