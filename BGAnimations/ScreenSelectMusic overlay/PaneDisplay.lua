-- get the machine_profile now at file init; no need to keep fetching with each SetCommand
local machine_profile = PROFILEMAN:GetMachineProfile()

-- the height of the footer is defined in ./Graphics/_footer.lua, but we'll
-- use it here when calculating where to position the PaneDisplay
local footer_height = 32

-- height, width of the PaneDisplay in pixels
local pane_height = 60
local pane_width = _screen.w/2 - 10

local text_zoom = WideScale(0.7, 0.8)

-- -----------------------------------------------------------------------
-- Convenience function to return the SongOrCourse and StepsOrTrail for a
-- for a player.
local GetSongAndSteps = function(player)
	local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	return SongOrCourse, StepsOrTrail
end


-- -----------------------------------------------------------------------
local GetScoreFromProfile = function(profile, SongOrCourse, StepsOrTrail)
	-- if we don't have everything we need, return nil
	if not (profile and SongOrCourse and StepsOrTrail) then return nil end

	return profile:GetHighScoreList(SongOrCourse, StepsOrTrail):GetHighScores()[1]
end

local GetScoreForPlayer = function(player)
	local highScore
	if PROFILEMAN:IsPersistentProfile(player) then
		local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
		highScore = GetScoreFromProfile(PROFILEMAN:GetProfile(player), SongOrCourse, StepsOrTrail)
	end
	return highScore
end

-- -----------------------------------------------------------------------
local SetNameAndScore = function(name, score, nameActor, scoreActor)
	if not scoreActor or not nameActor then return end
	scoreActor:settext(score)
	nameActor:settext(name)
end

local GetMachineTag = function(gsEntry)
	if not gsEntry then return end
	if gsEntry["machineTag"] then
		-- Make sure we only use up to 4 characters for space concerns.
		return gsEntry["machineTag"]:sub(1, 4):upper()
	end

	-- User doesn't have a machineTag set. We'll "make" one based off of
	-- their name.
	if gsEntry["name"] then
		-- 4 Characters is the "intended" length.
		return gsEntry["name"]:sub(1,4):upper()
	end

	return ""
end

local GetScoresRequestProcessor = function(res, params)
	local master = params.master
	if master == nil then return end
	-- If we're not hovering over a song when we get the request, then we don't
	-- have to update anything. We don't have to worry about courses here since
	-- we don't run the RequestResponseActor in CourseMode.
	if GAMESTATE:GetCurrentSong() == nil then return end

	local data = res.statusCode == 200 and JsonDecode(res.body) or nil
	local requestCacheKey = params.requestCacheKey
	-- If we have data, and the requestCacheKey is not in the cache, cache it.
	if data ~= nil and SL.GrooveStats.RequestCache[requestCacheKey] == nil then
		SL.GrooveStats.RequestCache[requestCacheKey] = {
			Response=res,
			Timestamp=GetTimeSinceStart()
		}
	end

	for i=1,2 do
		local paneDisplay = master:GetChild("PaneDisplayP"..i)

		local machineScore = paneDisplay:GetChild("MachineHighScore")
		local machineName = paneDisplay:GetChild("MachineHighScoreName")

		local worldScore = paneDisplay:GetChild("WorldHighScore")
		local worldName = paneDisplay:GetChild("WorldHighScoreName")

		local worldEXScore = paneDisplay:GetChild("WorldEXHighScore")
		local worldEXName = paneDisplay:GetChild("WorldEXHighScoreName")

		local playerScore = paneDisplay:GetChild("PlayerHighScore")
		local playerName = paneDisplay:GetChild("PlayerHighScoreName")

		local playerEXName = paneDisplay:GetChild("PlayerEXHighScoreName")
		local playerEXScore = paneDisplay:GetChild("PlayerEXHighScore")

		local loadingText = paneDisplay:GetChild("Loading")

		local playerStr = "player"..i
		local rivalNum = 1
		local worldRecordSet = false
		local worldEXRecordSet = false
		local personalRecordSet = false
		local personalEXRecordSet = false
		local foundLeaderboard = false
		local showExScore
		-- First check to see if the leaderboard even exists.
		if data and data[playerStr] then
			showExScore = SL["P"..i].ActiveModifiers.ShowEXScore and data[playerStr]["exLeaderboard"] ~= nil
			local leaderboardData = {GS=nil, EX=nil}
			if showExScore then
				leaderboardData["EX"] = data[playerStr]["exLeaderboard"]
			end
			if data[playerStr]["gsLeaderboard"] then
				leaderboardData["GS"] = data[playerStr]["gsLeaderboard"]
			end

			if leaderboardData["EX"] or leaderboardData["GS"] then
				foundLeaderboard = true
			end

			-- And then also ensure that the chart hash matches the currently parsed one.
			-- It's better to just not display anything than display the wrong scores.
			if SL["P"..i].Streams.Hash == data[playerStr]["chartHash"] and (leaderboardData["EX"] or leaderboardData["GS"]) then
				if leaderboardData["EX"] then
					for exEntry in ivalues(leaderboardData["EX"]) do
						if exEntry["rank"] == 1 then
							SetNameAndScore(
								GetMachineTag(exEntry),
								string.format("*%.2f%%", exEntry["score"]/100),
								worldEXName,
								worldEXScore
							)
							worldEXRecordSet = true
						end
						if exEntry["isSelf"] then
							SetNameAndScore(
								GetMachineTag(exEntry),
								string.format("*%.2f%%", exEntry["score"]/100),
								playerEXName,
								playerEXScore
							)
							personalEXRecordSet = true
						end
					end
				end
				
				for gsEntry in ivalues(leaderboardData["GS"]) do
					if gsEntry["rank"] == 1 then
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							worldName,
							worldScore
						)
						worldRecordSet = true
					end

					if gsEntry["isSelf"] then
	
						-- Let's check if the GS high score is higher than the local high score
						local player = PlayerNumber[i]
						local localScore = GetScoreForPlayer(player)
						-- GS's score entry is a value like 9823, so we need to divide it by 100 to get 98.23
						local gsScore = gsEntry["score"] / 100

						-- GetPercentDP() returns a value like 0.9823, so we need to multiply it by 100 to get 98.23
						if not localScore or gsScore >= localScore:GetPercentDP() * 100 then
							-- It is! Let's use it instead of the local one.
							SetNameAndScore(
								GetMachineTag(gsEntry),
								string.format("%.2f%%", gsScore),
								playerName,
								playerScore
							)
							personalRecordSet = true
						end
					end

					if gsEntry["isRival"] then
						local rivalScore = paneDisplay:GetChild("Rival"..rivalNum.."Score")
						local rivalName = paneDisplay:GetChild("Rival"..rivalNum.."Name")
						SetNameAndScore(
							GetMachineTag(gsEntry),
							string.format("%.2f%%", gsEntry["score"]/100),
							rivalName,
							rivalScore
						)
						rivalNum = rivalNum + 1
					end
				end
			end
		end
		-- If no world record has been set, fall back to displaying the not found text.
		-- This chart may not have been ranked, or there is no WR, or the request failed.
		if not worldRecordSet then
			loadingText:settext("")
			worldName:queuecommand("SetDefault")
			worldScore:queuecommand("SetDefault")
		end

		-- Fall back to to using the personal profile's record if we never set the record.
		-- This chart may not have been ranked, or we don't have a score for it, or the request failed.
		if not personalRecordSet then
			playerName:queuecommand("SetDefault")
			playerScore:queuecommand("SetDefault")
		end

		if worldEXRecordSet then
			worldEXName:visible(true):queuecommand("QueueShifting")
			worldEXScore:visible(true):queuecommand("QueueShifting")
			worldScore:queuecommand("QueueShifting")
			worldName:queuecommand("QueueShifting")
		else
			worldEXName:visible(false):queuecommand("QuitShifting")
			worldEXScore:visible(false):queuecommand("QuitShifting")
			worldScore:queuecommand("QuitShifting")
			worldName:queuecommand("QuitShifting")
		end
		if personalEXRecordSet then
			playerEXName:visible(true):queuecommand("QueueShifting")
			playerEXScore:visible(true):queuecommand("QueueShifting")
			playerScore:queuecommand("QueueShifting")
			playerName:queuecommand("QueueShifting")
		else
			playerEXName:visible(false):queuecommand("QuitShifting")
			playerEXScore:visible(false):queuecommand("QuitShifting")
			playerScore:queuecommand("QuitShifting")
			playerName:queuecommand("QuitShifting")
		end

		-- Iterate over any remaining rivals and hide them.
		-- This also handles the failure case as rivalNum will never have been incremented.
		for j=rivalNum,3 do
			local rivalScore = paneDisplay:GetChild("Rival"..j.."Score")
			local rivalName = paneDisplay:GetChild("Rival"..j.."Name")
			rivalScore:settext("??.??%")
			rivalName:settext("----")
		end

		if res.error or res.statusCode ~= 200 then
			local error = res.error and ToEnumShortString(res.error) or nil
			if error == "Timeout" then
				loadingText:settext("Timed Out")
			elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
				loadingText:settext("Failed")
			end
		elseif res["status"] == "fail" then
			loadingText:settext("Failed")
			worldName:visible(false)
			worldScore:visible(false)
		elseif res["status"] == "disabled" then
			loadingText:settext("Disabled")
			worldName:visible(false)
			worldScore:visible(false)
		else
			if data and data[playerStr] then
				if foundLeaderboard then
					-- If we found a leaderboard then show the World high score and hide the loading text.
					loadingText:visible(false)
					worldName:visible(true)
					worldScore:visible(true)
					-- Commenting this out until I think of how to display everything
					-- if SL["P"..i].ActiveModifiers.ShowEXScore then
					-- 	loadingText:settext("EX Score")
					-- else
					-- 	loadingText:settext("GrooveStats")
					-- end
				else
					if SL["P"..i].ActiveModifiers.ShowEXScore then
						loadingText:settext("No EX Data")
					else
						loadingText:settext("No Data")
					end
				end
			else
				-- Just hide the text
				loadingText:queuecommand("Set")
			end
		end
	end
end

-- -----------------------------------------------------------------------
-- define the x positions of four columns, and the y positions of three rows of PaneItems
local pos = {}
pos.row = { 13, 31, 49 }

if IsUsingWideScreen() then
	-- five columns
	pos.col = { WideScale(-110,-155), WideScale(-60, -82), WideScale(-5, -5), WideScale(130,135), IsServiceAllowed(SL.GrooveStats.GetScores) and WideScale(200,230) or WideScale(150,200)}
else
	-- four columns
	pos.col = { WideScale(-104,-133), WideScale(-36,-38), WideScale(100,85), IsServiceAllowed(SL.GrooveStats.GetScores) and WideScale(190, 220) or WideScale(150, 190)   }
end


local num_cols = IsUsingWideScreen() and 4 or 3

-- HighScores handled as special cases for now until further refactoring
local PaneItems = {
	-- first row
	{ name=THEME:GetString("RadarCategory","Taps"),  rc='RadarCategory_TapsAndHolds'},
	{ name=THEME:GetString("RadarCategory","Mines"), rc='RadarCategory_Mines'},
	{ name=THEME:GetString("ScreenSelectMusic","NPS") },
	{ name=THEME:GetString("RadarCategory","Jumps"), rc='RadarCategory_Jumps'},
	{ name=THEME:GetString("RadarCategory","Hands"), rc='RadarCategory_Hands'},
	{ name=THEME:GetString("RadarCategory","Lifts"), rc='RadarCategory_Lifts'},
	{ name=THEME:GetString("RadarCategory","Holds"), rc='RadarCategory_Holds'},
	{ name=THEME:GetString("RadarCategory","Rolls"), rc='RadarCategory_Rolls'},
	{ name=THEME:GetString("RadarCategory","Fakes"), rc='RadarCategory_Fakes'},
}
-- don't show NPS, Lifts, or Fakes counts if not WideScreen
if not IsUsingWideScreen() then
	table.remove(PaneItems, 9) -- fakes
	table.remove(PaneItems, 6) -- lifts
	table.remove(PaneItems, 3) -- NPS
end

-- -----------------------------------------------------------------------
local af = Def.ActorFrame{ Name="PaneDisplayMaster" }

af[#af+1] = RequestResponseActor(17, IsUsingWideScreen() and 50 or 42)..{
	Name="GetScoresRequester",
	OnCommand=function(self)
		-- Create variables for both players, even if they're not currently active.
		self.IsParsing = {false, false}
	end,
	-- Broadcasted from ./PerPlayer/DensityGraph.lua
	P1ChartParsingMessageCommand=function(self)	self.IsParsing[1] = true end,
	P2ChartParsingMessageCommand=function(self)	self.IsParsing[2] = true end,
	P1ChartParsedMessageCommand=function(self)
		self.IsParsing[1] = false
		if GAMESTATE:GetCurrentSong() == nil then return end
		-- local groupInfo = ""
		-- -- ADD_METHOD( GetGroupName );
		-- -- ADD_METHOD( GetSortTitle );
		-- -- ADD_METHOD( GetDisplayTitle );
		-- -- ADD_METHOD( GetTranslitTitle );
		-- -- ADD_METHOD( GetSeries );
		-- -- ADD_METHOD( GetSyncOffset );
		-- -- ADD_METHOD( HasGroupIni );
		-- -- ADD_METHOD( GetSongs );
		-- -- ADD_METHOD( GetBannerPath );
		-- -- ADD_METHOD( GetStepArtistCredits );
		-- -- ADD_METHOD( GetAuthorsNotes );
        -- -- ADD_METHOD( GetYearReleased );
		-- apple = "GroupName: " .. GAMESTATE:GetCurrentSong():GetGroupName()
		-- apple = apple .. "\nSortTitle: " .. GAMESTATE:GetCurrentSong():GetGroup():GetSortTitle()
		-- apple = apple .. "\nDisplayTitle: " .. GAMESTATE:GetCurrentSong():GetGroup():GetDisplayTitle()
		-- apple = apple .. "\nTranslitTitle: " .. GAMESTATE:GetCurrentSong():GetGroup():GetTranslitTitle()
		-- apple = apple .. "\nSeries: " .. GAMESTATE:GetCurrentSong():GetGroup():GetSeries()
		-- apple = apple .. "\nSyncOffset: " .. GAMESTATE:GetCurrentSong():GetGroup():GetSyncOffset()
		-- apple = apple .. "\nHasGroupIni: " .. (GAMESTATE:GetCurrentSong():GetGroup():HasGroupIni() and "true" or "false")
		-- apple = apple .. "\nBannerPath: " .. GAMESTATE:GetCurrentSong():GetGroup():GetBannerPath()
		-- apple = apple .. "\nStepArtistCredits: "
		-- for i, v in ipairs(GAMESTATE:GetCurrentSong():GetGroup():GetStepArtistCredits()) do
		-- 	apple = apple .. v .. ", "
		-- end
		-- apple = apple .. "\nAuthorsNotes: " .. GAMESTATE:GetCurrentSong():GetGroup():GetAuthorsNotes()
		-- apple = apple .. "\nYearReleased: " .. GAMESTATE:GetCurrentSong():GetGroup():GetYearReleased()
		-- -- Number of songs
		-- apple = apple .. "\nSongs: " .. #GAMESTATE:GetCurrentSong():GetGroup():GetSongs()
		--SM(apple)
		self:queuecommand("ChartParsed")
	end,
	P2ChartParsedMessageCommand=function(self)
		self.IsParsing[2] = false
		self:queuecommand("ChartParsed")
	end,
	ChartParsedCommand=function(self)
		local master = self:GetParent()

		if not IsServiceAllowed(SL.GrooveStats.GetScores) then
			if SL.GrooveStats.IsConnected then
				-- loadingText is made visible when requests complete.
				-- If we disable the service from a previous request, surface it to the user here.
				for i=1,2 do
					local loadingText = master:GetChild("PaneDisplayP"..i):GetChild("Loading")
					loadingText:settext("Disabled")
					loadingText:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
				end
			end
			return
		end

		-- Make sure we're still not parsing either chart.
		if self.IsParsing[1] or self.IsParsing[2] then return end

		-- This makes sure that the Hash in the ChartInfo cache exists.
		local sendRequest = false
		local headers = {}
		local query = {}
		local requestCacheKey = ""

		for i=1,2 do
			local pn = "P"..i
			if SL[pn].ApiKey ~= "" and SL[pn].Streams.Hash ~= "" then
				query["chartHashP"..i] = SL[pn].Streams.Hash
				headers["x-api-key-player-"..i] = SL[pn].ApiKey
				requestCacheKey = requestCacheKey .. SL[pn].Streams.Hash .. SL[pn].ApiKey .. pn
				local loadingText = master:GetChild("PaneDisplayP"..i):GetChild("Loading")
				local worldScore = master:GetChild("PaneDisplayP"..i):GetChild("WorldHighScore")
				local worldName = master:GetChild("PaneDisplayP"..i):GetChild("WorldHighScoreName")
				worldScore:visible(false)
				worldName:visible(false)
				loadingText:visible(true)
				loadingText:settext("Loading ...")
				sendRequest = true
			end
		end

		-- Only send the request if it's applicable.
		if sendRequest then
			requestCacheKey = CRYPTMAN:SHA256String(requestCacheKey.."-player-scores")
			local params = {requestCacheKey=requestCacheKey, master=master}
			RemoveStaleCachedRequests()
			-- If the data is still in the cache, run the request processor directly
			-- without making a request with the cached response.
			if SL.GrooveStats.RequestCache[requestCacheKey] ~= nil then
				local res = SL.GrooveStats.RequestCache[requestCacheKey].Response
				GetScoresRequestProcessor(res, params)
			else
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="player-scores.php?"..NETWORK:EncodeQueryParameters(query),
					method="GET",
					headers=headers,
					timeout=10,
					callback=GetScoresRequestProcessor,
					args=params,
				})
			end
		end
	end
}

for player in ivalues(PlayerNumber) do
	local pn = ToEnumShortString(player)

	af[#af+1] = Def.ActorFrame{ Name="PaneDisplay"..ToEnumShortString(player) }

	local af2 = af[#af]

	af2.InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))

		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x(_screen.w * 0.75 + 5)
		end

		self:y(_screen.h - footer_height - pane_height)
	end

	af2.PlayerJoinedMessageCommand=function(self, params)
		if player==params.Player then
			-- ensure BackgroundQuad is colored before it is made visible
			self:GetChild("BackgroundQuad"):playcommand("Set")
			self:visible(true)
				:zoom(0):croptop(0):bounceend(0.3):zoom(1)
				:playcommand("Update")
		end
	end

	af2.PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0):queuecommand("Hide")
		end
	end

	af2.PlayerProfileSetMessageCommand=function(self, params)
		if player == params.Player then
			self:playcommand("Set")
		end
	end
	af2.HideCommand=function(self) self:visible(false) end

	af2.OnCommand=function(self)                                    self:playcommand("Set") end
	af2.SLGameModeChangedMessageCommand=function(self)              self:playcommand("Set") end
	af2.CurrentCourseChangedMessageCommand=function(self)			self:playcommand("Set") end
	af2.CurrentSongChangedMessageCommand=function(self)				self:playcommand("Set") end
	af2["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end
	af2["CurrentTrail"..pn.."ChangedMessageCommand"]=function(self) self:playcommand("Set") end

	-- -----------------------------------------------------------------------
	-- colored background Quad

	af2[#af2+1] = Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self)
			self:zoomtowidth(pane_width)
			self:zoomtoheight(pane_height)
			self:vertalign(top)
		end,
		SetCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			if GAMESTATE:IsHumanPlayer(player) then
				if StepsOrTrail then
					local difficulty = StepsOrTrail:GetDifficulty()
					self:diffuse( DifficultyColor(difficulty) )
				else
					self:diffuse( PlayerColor(player) )
				end
			end
		end
	}

	-- -----------------------------------------------------------------------
	-- tabs along the top of the PaneDisplay, one per available stepchart

	if THEME:GetMetric("Common", "AutoSetStyle") == true then
		af2[#af2+1] = LoadActor("./StepsDisplayList/TabbedStepchartList/default.lua", {player, pane_width})
	end
	
	-- -----------------------------------------------------------------------
	-- loop through the six sub-tables in the PaneItems table
	-- add one BitmapText as the label and one BitmapText as the value for each PaneItem

	-- machine highscore, world highscore, and player highscore are handled outside this loop
	for i, item in ipairs(PaneItems) do

		local col = ((i-1)%(num_cols-1)) + 1
		local row = math.floor((i-1)/(num_cols-1)) + 1

		af2[#af2+1] = Def.ActorFrame{

			Name=item.name,

			-- numerical value
			LoadFont("Common Normal")..{
				InitCommand=function(self)
					self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
					self:x(pos.col[col])
					self:y(pos.row[row])
				end,

				SetCommand=function(self)
					local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
					if not SongOrCourse then self:settext("?"); return end
					if not StepsOrTrail then self:settext("");  return end

					if item.rc then
						local val = StepsOrTrail:GetRadarValues(player):GetValue( item.rc )
						-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
						self:settext( val >= 0 and val or "?" )
					-- only NPS ends up in this else block for now
					else
						if not SongOrCourse then self:settext(""); return end

						local seconds
						if GAMESTATE:IsCourseMode() then
							seconds = SongOrCourse:GetTotalSeconds(StepsOrTrail:GetStepsType())
						else
							-- song:MusicLengthSeconds() will return the duration of the music file as read from its metadata
							-- this may not accurately correspond with first note and late note in the stepchart
							-- if there is empty space at the start and/or end of the stepchart without notes
							-- So, let's prefer to use (LastSecond - FirstSecond)
							seconds = SongOrCourse:GetLastSecond() - SongOrCourse:GetFirstSecond()

							-- however, the engine initializes Song's member variable lastSecond to -1
							-- depending on how current engine-side parsing goes, it may never change from -1
							--
							-- for example:
							--   • use audacity to generate an ogg that is 5.000 seconds
							--   • use SM5's editor to set Song timing in the ssc file to 0.000 bpm at beat 0
							--   • do not specify any DisplayBPM; do not use steps timing
							--   • add a single quarter note at beat 0
							--
							-- GetFirstSecond() will return 0 and GetLastSecond() will return -1
							-- I'm not suggesting such stepcharts are reasonable, but they are possible.

							-- fall back on using MusicLengthSeconds in such cases
							-- having two different ways to determine seconds is inconsistent and confusing
							-- but I'm not sure what else to do here
							if seconds <= 0 then seconds = SongOrCourse:MusicLengthSeconds() end
						end

						-- FIXME: DOWNS4/ymbg currently shows 107.23 NPS here and 106.67 Peak NPS in gameplay's StepStats pane


						-- handle some circumstances by just bailing early and displaying a question mark
						-- ------------------------------------------------------------------
						-- the engine will return nil for GetTotalSeconds() on courses like "Most Played 01-04"
						if seconds == nil then self:settext("?"); return end
						-- don't allow division by zero
						if (seconds/SL.Global.ActiveModifiers.MusicRate) <= 0 then self:settext("?"); return end
						-- ------------------------------------------------------------------


						local totalnotes = StepsOrTrail:GetRadarValues(player):GetValue("RadarCategory_TapsAndHolds")
						local nps = totalnotes / (seconds/SL.Global.ActiveModifiers.MusicRate)

						-- NPS shouldn't be greater than the stepchart's total note count
						if nps > totalnotes then
							-- so far, I've only seen this occur when seconds is <1 and >0
							-- see: Crapyard Scent/Windows XP Critical Stop
							if seconds < 1 and seconds > 0 then
								seconds = SongOrCourse:MusicLengthSeconds()
								-- try again
								nps = totalnotes / (seconds/SL.Global.ActiveModifiers.MusicRate)
							end

							-- I sure hope we never get here, but I'll deal with it when we do.
							if nps > totalnotes then nps = totalnotes end
						end

						self:settext( ("%.2f"):format(nps) )
					end
				end
			},

			-- label
			LoadFont("Common Normal")..{
				Text=item.name,
				InitCommand=function(self)
					self:zoom(text_zoom):diffuse(Color.Black):horizalign(left)
					self:x(pos.col[col]+3)
					self:y(pos.row[row])
				end
			},
		}
	end

	-- Machine Record Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScoreName",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)

			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-5)
				self:y(pos.row[2])
			else
				self:x(pos.col[#pos.col-1]*text_zoom)
				self:y(pos.row[1])
			end
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
			self:queuecommand("QuitShifting")
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machineScore = GetScoreFromProfile(machine_profile, SongOrCourse, StepsOrTrail)
			self:settext(machineScore and machineScore:GetName() or "----")
			DiffuseEmojis(self:ClearAttributes())
		end
	}

	-- Machine Record HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="MachineHighScore",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-22)
				self:y(pos.row[2])
			else
				self:x(pos.col[#pos.col-1]*text_zoom-17)
				self:y(pos.row[1])	
			end
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
			self:queuecommand("QuitShifting")
		end,
		SetDefaultCommand=function(self)
			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			local machineScore = GetScoreFromProfile(machine_profile, SongOrCourse, StepsOrTrail)
			if machineScore ~= nil then
				self:settext(FormatPercentScore(machineScore:GetPercentDP()))
			else
				self:settext("??.??%")
			end
		end
	}

	-- World Record Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="WorldHighScoreName",
		InitCommand=function(self)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-5)
				self:y(pos.row[1])
			end
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:queuecommand("QuitShifting")
			self:settext("----")
			DiffuseEmojis(self:ClearAttributes())
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,1):effectcolor2(0,0,0,0):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}

	-- World Record HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="WorldHighScore",
		InitCommand=function(self)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-22)
				self:y(pos.row[1])
			end
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:queuecommand("QuitShifting")
			self:settext("??.??%")
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,1):effectcolor2(0,0,0,0):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}

	
	-- World Record Machine Tag
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="WorldEXHighScoreName",
		InitCommand=function(self)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-5)
				self:y(pos.row[1])
			end
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:queuecommand("QuitShifting")
			self:settext("")
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,0):effectcolor2(0,0,0,1):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}

	-- World Record HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="WorldEXHighScore",
		InitCommand=function(self)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			self:x(pos.col[#pos.col-1]*text_zoom-22)
			self:y(pos.row[1])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:queuecommand("QuitShifting")
			self:settext("")
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,0):effectcolor2(0,0,0,1):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}

	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScoreName",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-5)
				self:y(pos.row[3])
			else
				self:x(pos.col[#pos.col-1]*text_zoom)
				self:y(pos.row[2])
			end
		end,
		SetCommand=function(self)
			-- There isn't a point of setting it to ---- when SetDefault already
			-- handles this. This check introduced a delay when scores were existing locally.
			-- Either way the text gets set.
				-- -- We overload this actor to work both for GrooveStats and also offline.
				-- -- If we're connected, we let the ResponseProcessor set the text
				-- if IsServiceAllowed(SL.GrooveStats.GetScores) then
				-- 	self:settext("----")
				-- else
				-- 	self:queuecommand("SetDefault")
				-- end
			self:queuecommand("SetDefault")
			self:queuecommand("QuitShifting")
		end,
		SetDefaultCommand=function(self)
			local playerScore = GetScoreForPlayer(player)
			self:settext(playerScore and playerScore:GetName() or "----")
			DiffuseEmojis(self:ClearAttributes())
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,1):effectcolor2(0,0,0,0):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}

	-- Player Profile/GrooveStats HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerHighScore",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:x(pos.col[#pos.col-1]*text_zoom-22)
				self:y(pos.row[3])
			else
				self:x(pos.col[#pos.col-1]*text_zoom-17)
				self:y(pos.row[2])	
			end
		end,
		SetCommand=function(self)
			-- There isn't a point of setting it to ??.?? when SetDefault already
			-- handles this. This check introduced a delay when scores were existing locally.
			-- Either way the text gets set.
					-- -- We overload this actor to work both for GrooveStats and also offline.
					-- -- If we're connected, we let the ResponseProcessor set the text
					-- if IsServiceAllowed(SL.GrooveStats.GetScores) then
					-- 	self:settext("??.??%")
					-- else
					-- 	self:queuecommand("SetDefault")
					-- end
			self:queuecommand("SetDefault")
			self:queuecommand("QuitShifting")
		end,
		SetDefaultCommand=function(self)
			local playerScore = GetScoreForPlayer(player)
			if playerScore ~= nil then
				self:settext(FormatPercentScore(playerScore:GetPercentDP()))
			else
				self:settext("??.??%")
			end
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,1):effectcolor2(0,0,0,0):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerEXHighScoreName",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:x(pos.col[#pos.col-1]*text_zoom-5)
			self:y(pos.row[3])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:settext("")
			self:queuecommand("QuitShifting")
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,0):effectcolor2(0,0,0,1):effecttiming(1,2,1,2,2)
		end
	}
	-- Player Profile/GrooveStats HighScore
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="PlayerEXHighScore",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			self:x(pos.col[#pos.col-1]*text_zoom-22)
			self:y(pos.row[3])
		end,
		SetCommand=function(self)
			self:queuecommand("SetDefault")
		end,
		SetDefaultCommand=function(self)
			self:settext("")
			self:queuecommand("QuitShifting")
		end,
		QueueShiftingCommand=function(self)
			self:diffuseshift():effectcolor1(0,0,0,0):effectcolor2(0,0,0,1):effecttiming(1,2,1,2,2)
		end,
		QuitShiftingCommand=function(self)
			self:stopeffect():diffusealpha(1)
		end
	}
	-- Loading Text
	af2[#af2+1] = LoadFont("Common Normal")..{
		Name="Loading",
		Text="Loading ... ",
		InitCommand=function(self)
			self:zoom(text_zoom):diffuse(Color.Black)
			self:x(pos.col[#pos.col-1]*text_zoom-20)
			self:y(pos.row[1])
			self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
		end,
		SetCommand=function(self)
			self:settext("Loading ...")
			self:visible(false)
		end
	}

	-- Chart Difficulty Meter
	af2[#af2+1] = LoadFont("Wendy/_wendy small")..{
		Name="DifficultyMeter",
		InitCommand=function(self)
			self:horizalign(right):diffuse(Color.Black)
			self:xy(pos.col[#pos.col], pos.row[2])
			if not IsUsingWideScreen() then self:maxwidth(66) end
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			-- Hide the difficulty number if we're connected.
			if IsServiceAllowed(SL.GrooveStats.GetScores) then
				self:visible(false)
			end

			local SongOrCourse, StepsOrTrail = GetSongAndSteps(player)
			if not SongOrCourse then self:settext("") return end
			local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"
			self:settext( meter )
		end
	}

	-- Add actors for Rival score data. Hidden by default
	-- We position relative to column 3 for spacing reasons.
	for i=1,3 do
		-- Rival Machine Tag
		af2[#af2+1] = LoadFont("Common Normal")..{
			Name="Rival"..i.."Name",
			InitCommand=function(self)
				self:zoom(text_zoom):diffuse(Color.Black):maxwidth(30)
				self:x(pos.col[#pos.col]*text_zoom)
				self:y(pos.row[i])
			end,
			OnCommand=function(self)
				self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			end,
			SetCommand=function(self)
				self:settext("----")
			end
		}

		-- Rival HighScore
		af2[#af2+1] = LoadFont("Common Normal")..{
			Name="Rival"..i.."Score",
			InitCommand=function(self)
				self:zoom(text_zoom):diffuse(Color.Black):horizalign(right)
				self:x(pos.col[#pos.col]*text_zoom-17)
				self:y(pos.row[i])
			end,
			OnCommand=function(self)
				self:visible(IsServiceAllowed(SL.GrooveStats.GetScores))
			end,
			SetCommand=function(self)
				self:settext("??.??%")
			end
		}
	end
end

return af
