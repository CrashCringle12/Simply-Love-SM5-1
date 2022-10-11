return function(player, AllSteps)
	local song = GAMESTATE:GetCurrentSong()
	AllSteps = AllSteps or (song and SongUtil.GetPlayableSteps(song)) or {}

	if #AllSteps < 10 then
		local t = {}
		local _i = 9
		for i=1,10 do
			t[i] = AllSteps[#AllSteps-_i]
			_i = _i - 1
		end
		return t
	end

	player = player or GAMESTATE:GetMasterPlayerNumber()
	if not player then return {} end

	local current_steps = GAMESTATE:GetCurrentSteps(player)
	local i = FindInTable(current_steps, AllSteps)
	if not i then return {} end

	local t = {}
	local _i


	if i < 6 then
		_i = 1
	elseif i > 5 and i < #AllSteps-5 then
		_i = i-5
	else
		_i=#AllSteps-9
	end

	for index=1,10 do
		t[index] = AllSteps[_i]
		_i = _i + 1
	end

	return t
end