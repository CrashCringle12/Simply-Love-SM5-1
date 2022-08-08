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
            -- Params.totalsongs returns the text "## Songs Played also so we need to split it
            local numSongs = split(" ",params.totalsongs)
            -- Now we need to conver the amount of songs played to an integer and check if it meets the criteria
            if tonumber(numSongs[1]) > 10000 then
                self:visible(true):setstate(11)
            else
                if tonumber(numSongs[1]) > 7500 then
                    self:visible(true):setstate(10)
                else
                    if tonumber(numSongs[1]) > 5000 then
                        self:visible(true):setstate(9)
                    else
                        if tonumber(numSongs[1]) > 4000 then
                            self:visible(true):setstate(8)
                        else
                            if tonumber(numSongs[1]) > 3000 then
                                self:visible(true):setstate(7)
                            else
                                if tonumber(numSongs[1]) > 2000 then
                                    self:visible(true):setstate(6)
                                else
                                    if tonumber(numSongs[1]) > 1000 then
                                        self:visible(true):setstate(5)
                                    else
                                        if tonumber(numSongs[1]) > 750 then
                                            self:visible(true):setstate(4)
                                        else
                                            if tonumber(numSongs[1]) > 500 then
                                                self:visible(true):setstate(3)
                                            else
                                                if tonumber(numSongs[1]) > 250 then
                                                    self:visible(true):setstate(2)
                                                else
                                                    if tonumber(numSongs[1]) > 100 then
                                                        self:visible(true):setstate(1)
                                                    else
                                                        if tonumber(numSongs[1]) > 50 then
                                                            self:visible(true):setstate(0)
                                                        else
                                                            self:visible(false)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
}