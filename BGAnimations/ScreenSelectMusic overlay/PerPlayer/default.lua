local t = Def.ActorFrame{}

-- Always add these elements for both players, even if only one is joined right now
-- If the other player suddenly latejoins, we can't dynamically add more actors to the screen
-- We can only unhide hidden actors that were there all along
for player in ivalues( PlayerNumber ) do
	if SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadActor("./DensityGraph.lua", player)
	end
	-- AuthorCredit, Description, and ChartName associated with the current stepchart
	if SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadActor("./StepArtist.lua", player)
	else
		t[#t+1] = LoadActor("./StepArtist-ITG.lua", player)
	end

end

-- Bouncing cursor inside the grid of difficulty blocks. These should be on top of both of the other elements.
for player in ivalues( PlayerNumber ) do
	if SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadActor("./Cursor.lua", player)
	else
		t[#t+1] = LoadActor("./Cursor-ITG.lua", player)
	end
end

return t