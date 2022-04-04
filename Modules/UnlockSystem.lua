local t = {}
local machinePath = ""
--local apple = ""
function getPlayersProfilePath(player)
	if not player then return end
	
	local profile_slot = {"ProfileSlot_Player1","ProfileSlot_Player2"}
	local dir = ""
	if ToEnumShortString(player) == "P1" then
		if PROFILEMAN:IsPersistentProfile(PLAYER_1) then
			return PROFILEMAN:GetProfileDir(profile_slot[1])..'/Unlock System/'
		else
			return machinePath
		end
	else
		if PROFILEMAN:IsPersistentProfile(PLAYER_2) then
			dir  = PROFILEMAN:GetProfileDir(profile_slot[2])..'/Unlock System/'
		else
			return machinePath
		end
	end
	return dir
end

function SongUnlockCheck(songName)
	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
		local Song = getPlayersProfilePath(player)..'/Unlocks.lua' 
		if UnlockFileExists(Song) then
			if UnlockFileCheck(Song, songName) then return true end
		end
	end
    return false
end

function UnlockFileExists(filePath)
	if FILEMAN:DoesFileExist(filePath) then
		return true
	end
	return false
end
function UnlockFileCheck(filePath, songName)
	local pass = lua.ReadFile(filePath)
	--SM(pass .. "\n".. songName)
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
	for i, song in ipairs(SONGMAN:GetSongsInGroup("UPSRT2.5 - Locked Away")) do
		machinePath = song:GetSongDir() .. "../Unlock System/"
        if song:GetOrigin() ~= "" then
			--apple = apple .. song:GetOrigin().. " ".. song:GetDisplayMainTitle() .. "\n"
			if SongUnlockCheck(song:GetDisplayMainTitle()) then
				UNLOCKMAN:UnlockEntryID(song:GetOrigin())
			else 
				UNLOCKMAN:LockEntryID(song:GetOrigin())
			end
		end	
	end	

	for i, song in ipairs(SONGMAN:GetSongsInGroup(groupName)) do
		machinePath = song:GetSongDir() .. "../Unlock System/"
        if song:GetOrigin() ~= "" then
			if SongUnlockCheck(song:GetDisplayMainTitle()) then
           		UNLOCKMAN:UnlockEntryID(song:GetOrigin())
			else 
				UNLOCKMAN:LockEntryID(song:GetOrigin())
			end
		end
	end	
end

t["ScreenSelectMusic"] = Def.ActorFrame {
    ModuleCommand=function(self)
        LockUnlockCheck();
    end
}
return t

