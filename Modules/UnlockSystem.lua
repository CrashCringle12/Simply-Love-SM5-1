-- If you have a pack that has unlockable songs add the pack to this list.
-- Make sure to also update metrics.ini with your UnlockCodes.
local groups = {
    "Squeaky Beds and Leaky Faucets (Nightly Beta)",
    "UPSRT2.5 - Locked Away",
}
 local t = {}
 local machinePath = ""
 function getPlayersProfilePath(player)
 	if not player then return end
 	
 	local profile_slot = {"ProfileSlot_Player1","ProfileSlot_Player2"}
 	local dir = ""
 	if ToEnumShortString(player) == "P1" then
 		if PROFILEMAN:IsPersistentProfile(PLAYER_1) then
 			return PROFILEMAN:GetProfileDir(profile_slot[1])
 		else
 			return machinePath
 		end
 	else
 		if PROFILEMAN:IsPersistentProfile(PLAYER_2) then
 			dir  = PROFILEMAN:GetProfileDir(profile_slot[2])
 		else
 			return machinePath
 		end
 	end
 	return dir
 end
 
 function SongUnlockCheck(songName)
 	for player in ivalues(GAMESTATE:GetHumanPlayers()) do
 		local Song = getPlayersProfilePath(player)..'Unlock System/Unlocks.lua' 
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
    for _, group in ipairs(groups) do
        if SONGMAN:DoesSongGroupExist(group) then
            for i, song in ipairs(SONGMAN:GetSongsInGroup(group)) do
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
    end
 end
 
 t["ScreenSelectMusic"] = Def.ActorFrame {
     ModuleCommand=function(self)
         LockUnlockCheck();
     end
 }
 return t
 
