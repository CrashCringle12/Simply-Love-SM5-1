local VisualList

if GAMESTATE:IsCourseMode() then
	VisualList = LoadActor("./CourseContentsList.lua")
	
elseif THEME:GetMetric("Common", "AutoSetStyle") == true then
	-- returning a NullActor meets the needs of returning an Actor but doesn't display anything
	VisualList = NullActor
	
elseif SL.Global.GameMode == "ITG" then
	VisualList = LoadActor("./Grid-ITG.lua")
	
else
	VisualList = LoadActor("./Grid.lua")
end

return VisualList