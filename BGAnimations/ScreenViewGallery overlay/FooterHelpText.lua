local cancel = THEME:GetString("ScreenViewGallery", "FooterTextSingleSong")
if PREFSMAN:GetPreference("ThreeKeyNavigation") then cancel = THEME:GetString("ScreeviewGallery", "FooterTextSingleSong3Key") end

return LoadFont("Common Normal")..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.h - 16):zoom(0.7):diffusealpha(1) end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:diffusealpha(0):settext(THEME:GetString("ScreenviewGallery", "FooterTextGroups")):linear(0.15):diffusealpha(1)
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		self:diffusealpha(0):settext(THEME:GetString("ScreenviewGallery", "FooterTextSongs")):linear(0.15):diffusealpha(1)
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:diffusealpha(0):settext( cancel ):linear(0.15):diffusealpha(1)
	end,
}