local num_items = THEME:GetMetric("MusicWheel", "NumWheelItems")
-- subtract 2 from the total number of MusicWheelItems
-- one MusicWheelItem will be offsceen above, one will be offscreen below
local num_visible_items = num_items - 2

local item_width = _screen.w / 2.125

return Def.ActorFrame{
	-- the MusicWheel is centered via metrics under [ScreenSelectMusic]; offset by a slight amount to the right here
	InitCommand=function(self) self:x(WideScale(28,33)) end,

	Def.Quad{ InitCommand=function(self) self:horizalign(left):diffuse(color("#000000")):diffusealpha(0.3):zoomto(item_width, _screen.h/num_visible_items) end },
	Def.Quad{ InitCommand=function(self) self:horizalign(left):diffuse(color("#2e3a42")):diffusealpha(0.9):zoomto(item_width, _screen.h/num_visible_items - 1) end }
}