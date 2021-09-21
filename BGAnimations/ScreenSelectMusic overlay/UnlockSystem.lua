
local t = Def.ActorFrame{}
function getPlayersProfilePath(player)
	if not player then return end
	
	local profile_slot = {"ProfileSlot_Player1","ProfileSlot_Player2"}
	local dir = ""
	if ToEnumShortString(player) == "P1" then
		dir  = PROFILEMAN:GetProfileDir(profile_slot[1])
	else
		dir  = PROFILEMAN:GetProfileDir(profile_slot[2])
	end
	return dir
end

function SongUnlockCheck(songName)
    local p1Song = getPlayersProfilePath(PLAYER_1)..'Unlock System/Unlocks.lua' 
    local p2Song = getPlayersProfilePath(PLAYER_2)..'Unlock System/Unlocks.lua' 
    if PassFileExists(p1Song) then
        if UnlockFileCheck(p1Song, songName) then return true end
    end
    if PassFileExists(p2Song) then
        if UnlockFileCheck(p2Song, songName) then return true end
    end
    return false
end

function PassFileExists(filePath)
	if FILEMAN:DoesFileExist(filePath) then
		return true
	end
	return false
end
function UnlockFileCheck(filePath, songName)
	local pass = lua.ReadFile(filePath)
	for line in pass:gmatch("[^\r\n]+") do
		if line == songName then
			return true
		end
	end
	return false
end


function LockUnlockCheck()
	groupName = "Squeaky Beds and Leaky Faucets (29.8.2021 Beta)"

	for i, song in ipairs(SONGMAN:GetSongsInGroup(groupName)) do
        if song:GetOrigin() ~= "" then
			if SongUnlockCheck(song:GetDisplayMainTitle()) then
           		UNLOCKMAN:UnlockEntryID(song:GetOrigin())
			else 
				UNLOCKMAN:LockEntryID(song:GetOrigin())
			end
		end
		
	end	
end
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(self)
			LockUnlockCheck()
		end,

	}

return t

