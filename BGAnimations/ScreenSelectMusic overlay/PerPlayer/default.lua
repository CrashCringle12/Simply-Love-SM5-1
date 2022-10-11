local t = Def.ActorFrame{}

-- don't load StepArtist.lua or Cursor.lua when AutoSetStyle is in effect
-- because that mode uses "tabs" along the top of the panedisplay for listing
-- available stepcharts (rather than the difficulty block grid), and I don't know
-- how to fit the stepartist and cursor UI into the tabbed UI.  -quietly
if THEME:GetMetric("Common", "AutoSetStyle") == false then

	-- Always add these elements for both players, even if only one is joined right now
	-- If the other player suddenly latejoins, we can't dynamically add more actors to the screen
	-- We can only unhide hidden actors that were there all along
	for player in ivalues( PlayerNumber ) do
		t[#t+1] = LoadActor("./DensityGraph.lua", player)

		-- StepArtist.lua contains actors to show:
		--   AuthorCredit, Description, and ChartName associated with the current stepchart
		-- Cursor.lua contains the actor for a rounded arrow that bounces in time with the beat
		--   and moves up and down the difficulty block grid
		if SL.Global.GameMode == "FA+" then
			t[#t+1] = LoadActor("./StepArtist.lua", player)
			t[#t+1] = LoadActor("./Cursor.lua", player)
		else
			t[#t+1] = LoadActor("./StepArtist-ITG.lua", player)
			t[#t+1] = LoadActor("./Cursor-ITG.lua", player)
		end
	end
end

return t