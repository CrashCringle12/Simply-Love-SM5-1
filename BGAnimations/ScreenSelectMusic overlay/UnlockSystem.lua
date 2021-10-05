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
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		Song = getPlayersProfilePath(player)..'Unlock System/Unlocks.lua' 
		if PassFileExists(Song) then
			if UnlockFileCheck(Song, songName) then return true end
		end
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
	if pass then
		for line in pass:gmatch("[^\r\n]+") do
			if line == songName then
				return true
			end
		end
	end
	return false
end


function LockUnlockCheck()
	groupName = "Squeaky Beds and Leaky Faucets (Nightly Beta)"

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

