local file

if GAMESTATE:IsCourseMode() then
	file = LoadActor("./CourseContentsList.lua")
elseif SL.Global.GameMode == "ITG" then
	file = LoadActor("./Grid-ITG.lua")
else
	-- file = LoadActor("./Grid.lua")
end
return file