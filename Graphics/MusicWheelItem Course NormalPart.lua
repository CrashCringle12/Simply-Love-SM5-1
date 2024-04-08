local num_items = THEME:GetMetric("MusicWheel", "NumWheelItems")
-- subtract 2 from the total number of MusicWheelItems
-- one MusicWheelItem will be offsceen above, one will be offscreen below
local num_visible_items = num_items - 2

local item_width = _screen.w / 2.125

return Def.ActorFrame{
	-- the MusicWheel is centered via metrics under [ScreenSelectMusic]; offset by a slight amount to the right here
	InitCommand=function(self) self:x(WideScale(28,33)) end,

	Def.Quad{ InitCommand=function(self) self:horizalign(left):diffuse(0, 10/255, 17/255, 0.5):zoomto(item_width, _screen.h/num_visible_items) end },
	Def.Quad{ 
		InitCommand=function(self)
			self:horizalign(left):diffuse(DarkUI() and {1,1,1,0.5} or {10/255, 20/255, 27/255, 1}):zoomto(item_width, (_screen.h/num_visible_items)-1)
			if ThemePrefs.Get("VisualStyle") == "SRPG7" or ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5) 
			end
		end,
		SetCommand=function(self,params)
            if params.Song then
                local song = params.Song
                if song and SL.Global.Trials[song] then 
					self:horizalign(left):diffuse(DarkUI() and {0.8,0.9,1,0.5} or color("#a67c00") ):diffusealpha(0.75):zoomto(item_width, (_screen.h/num_visible_items)-1)
                else
					self:horizalign(left):diffuse(DarkUI() and {1,1,1,0.5} or {10/255, 20/255, 27/255, 1}):zoomto(item_width, (_screen.h/num_visible_items)-1)
                end
            else
				self:horizalign(left):diffuse(DarkUI() and {1,1,1,0.5} or {10/255, 20/255, 27/255, 1}):zoomto(item_width, (_screen.h/num_visible_items)-1)
            end

        end,
	},

    -- Def.Sprite {
    --     InitCommand=function(self)
    --         self:animate(false):visible(false)
    --         self:Load( THEME:GetPathG("", "Rune.png") ):zoom(0.13):rotationz(90):blend(3)
    --     end,
    --     SetCommand=function(self,params)
    --         if params.Song then
    --             local song = params.Song
    --             if song and FindInTable(song, SL.Global.Trials) then 
    --                 self:visible(true)
    --             else
    --                 self:visible(false)
    --             end
    --             self:x(200):zoomto(35,400):diffusealpha(0.75)
    --         else
    --             self:visible(false)
    --         end
    --     end,
    --     UnsetCommand=function(self)
    --         self:visible(false)
    --     end
    -- }

}