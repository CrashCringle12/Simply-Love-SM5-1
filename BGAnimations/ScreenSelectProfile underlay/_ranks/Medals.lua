local info = ...

return 	Def.Sprite {
    Texture="_ranks/medal 4x3.png",
    Name="medal",
    InitCommand=function(self)
        self:zoom(0.35):visible(false):diffuseshift():xy(info.padding+78, info.y+92)
            :animate(false):effectperiod(1.5):effectcolor1(1,1,1,1):effectcolor2(1,1,1,1)
    end,
    SetCommand=function(self, params)
        if params then
            if (params.ribbon >= 0) then
                self:visible(true):setstate(params.ribbon)
            else
                self:visible(false)
            end
        else
            self:visible(false)
        end
    end
}