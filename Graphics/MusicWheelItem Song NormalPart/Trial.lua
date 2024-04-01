local ar = GetScreenAspectRatio()

local af = Def.ActorFrame {
	InitCommand=function(self)
	end,
    Def.Sprite {
        InitCommand=function(self)
            self:animate(false):visible(false)
            self:Load( THEME:GetPathG("", "Relic.png") ):zoom(0.08)
        end,
        SetCommand=function(self,params)
            if params.Song then
                local song = params.Song
                if song and FindInTable(song, SL.Global.Trials) then 
                    self:visible(true)
                else
                    self:visible(false)
                end
                self:x(-18)
            else
                self:visible(false)
            end
        end,
        UnsetCommand=function(self)
            self:visible(false)
        end
    },
}


return af
