
local t = Def.ActorFrame {
	InitCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then self:queuecommand("Listen") end
	end,
	OnCommand=function(self)
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		if seconds <= 0 then
			self:playcommand("Finish")
		else
			self:sleep(0.25)
			self:queuecommand("Listen")
		end
	end,
	FinishCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	LoadActor("./Header.lua", 1),

--	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0, true),
	LoadActor("./gallery.lua"),

	LoadActor("FooterHelpText.lua"),
}

-- FIXME: This is dumb.  Add the player option StartButton visual last so it
--  draws over everything else and we can hide cursors behind it when needed...
t[#t+1] = LoadActor("./StartButton.lua")

return t