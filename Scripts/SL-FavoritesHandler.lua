-- SM5 Favorites manager by leadbman & modified for RIO by Rhythm Lunatic
-- Slightly Modified and implemented by Crash Cringle

-- Inhibit Regular Expression magic characters ^$()%.[]*+-?)
local function strPlainText(strText)
	-- Prefix every non-alphanumeric character (%W) with a % escape character,
	-- where %% is the % escape, and %1 is original character
	return strText:gsub("(%W)","%%%1")
end


addOrRemoveFavorite = function(player)
	local profileName = PROFILEMAN:GetPlayerName(player)
	local path = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[player]+1]).."FavoriteSongs.txt"

	local songDir = GAMESTATE:GetCurrentSong():GetSongDir()
	local songTitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
	local arr = split("/", songDir)
	local favoritesString = lua.ReadFile(path) or ""

	if not PROFILEMAN:IsPersistentProfile(player) then
		favoritesString = ""

	elseif favoritesString then
		--If song found in the player's favorites
		local checksong = string.match(favoritesString, strPlainText(arr[3].."/"..arr[4]))

		--Song found
		if checksong then
			favoritesString= string.gsub(favoritesString, strPlainText(arr[3].."/"..arr[4]).."\n", "")
			SCREENMAN:SystemMessage(songTitle.." removed from "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "Common invalid.ogg"))
		else
			favoritesString= favoritesString..arr[3].."/"..arr[4].."\n";
			SCREENMAN:SystemMessage(songTitle.." added to "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "_unlock.ogg"))
		end
	end

	-- write string to disk as txt file in player's profile directory
	local file = RageFileUtil.CreateRageFile()
	if file:Open(path, 2) then
		file:Write(favoritesString)
		file:Close()
		file:destroy()
	else
		Warn("**Could not open '" .. path .. "' to write current playing info.**")
	end
end

--[[
This is the only way to use favorites in the stock StepMania songwheel,
It reads the favorites file and then generates a Preferred Sort formatted file which SM can read.
Call this before ScreenSelectMusic and after addOrRemoveFavorite.
To open the favorties folder, call this from ScreenSelectMusic:
SCREENMAN:GetTopScreen():GetMusicWheel():ChangeSort("SortOrder_Preferred")
SONGMAN:SetPreferredSongs("FavoriteSongs");
SCREENMAN:GetTopScreen():GetMusicWheel():SetOpenSection("P1 Favorites");
]]
generateFavoritesForMusicWheel = function()


	for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
		if PROFILEMAN:IsPersistentProfile(pn) then
			local strToWrite = ""
			-- declare listofavorites inside the loop so that P1 and P2 can have independent lists
			local listofavorites = {}
			local profileName = PROFILEMAN:GetPlayerName(pn)
			local path = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[pn]+1]).."FavoriteSongs.txt"

			if FILEMAN:DoesFileExist(path) then
				local favs = lua.ReadFile(path)

				-- the txt file has been read into a string as `favs`
				-- ensure it isn't empty
				if favs:len() > 2 then

					-- split it on newline characters and add each line as a string
					-- to the listofavorites table
					for line in favs:gmatch("[^\r\n]+") do
						SL[ToEnumShortString(pn)].Favorites[#SL[ToEnumShortString(pn)].Favorites+1] = SONGMAN:FindSong(line)
						listofavorites[#listofavorites+1] = line
					end
					-- sort alphabetically
					table.sort(listofavorites, function(a, b) return split("/",a)[2]:lower() < split("/",b)[2]:lower() end)

					-- append a line like "---Lilley Pad's Favorites" to strToWrite
					strToWrite = strToWrite .. ("---%s's Favorites\n"):format(profileName)
					
					-- append each group/song string to the overall strToWrite
					for fav in ivalues(listofavorites) do
						strToWrite = strToWrite .. ("%s\n"):format(fav)
					end
				end
			else
				--SM("No favorites found at "..path)
			end
			
			if strToWrite ~= "" then
				local path = THEME:GetCurrentThemeDirectory().."Other/SongManager "..ToEnumShortString(pn).."_Favorites.txt"
				local file= RageFileUtil.CreateRageFile()

				if file:Open(path, 2) then
					file:Write(strToWrite)
					file:Close()
					file:destroy()
				else
					SM("Could not open '" .. path .. "' to write current playing info.")
				end
			end

		end
	end
end
