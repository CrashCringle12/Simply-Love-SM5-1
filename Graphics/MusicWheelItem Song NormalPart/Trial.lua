local player = ...
local pn = ToEnumShortString(player)

local ar = GetScreenAspectRatio()

local af = Def.ActorFrame {
	InitCommand=function(self)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			GAMESTATE:ResetPlayerOptions(params.Player)
			SL[ToEnumShortString(params.Player)]:initialize()
		end
		if pn == nil then
			player = params.Player
			pn = ToEnumShortString(player)
		end
	end,
    Def.Quad{
        InitCommand=function(self)
            self:animate(false):visible(false)
            self:diffuse(Color.Blue):scaletoclipped(SL_WideScale(5, 6), 31):zoomto(400,100)
        end,
        SetCommand=function(self,params)
            if params.Song then
                local song = params.Song
                if song and FindInTable(song, SL[pn].Favorites) then 
                    self:visible(true)
                else
                    self:visible(false)
                end
            else
                self:visible(false)
            end

        end,
        UnsetCommand=function(self)
            self:visible(false)
        end
    }
}


return af
