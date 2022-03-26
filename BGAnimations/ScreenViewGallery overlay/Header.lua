local row = ...
local name = PROFILEMAN:IsPersistentProfile(ThemePrefs.Get("GalleryPlayer")) and PROFILEMAN:GetProfile(ThemePrefs.Get("GalleryPlayer")):GetDisplayName() or "Cabby"
local af = Def.ActorFrame{

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#000000dd"))
			self:zoomto(_screen.w, 65):valign(0):xy( _screen.cx, 0 )
		end,
		SwitchFocusToSongsMessageCommand=function(self)
			self:sleep(0.1):linear(0.1):zoomtoheight(65)
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):zoomtoheight(32) end,
	},

	-- "Choose Your Song"
	Def.BitmapText{
		Name="HeaderText",
		Font="Wendy/_wendy small",
		Text="Viewing",
		InitCommand=function(self) self:diffuse(1,1,1,1):zoom(WideScale(0.5,0.6)):xy(_screen.cx, 15)  end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	},
		-- "Choose Your Song"
		Def.BitmapText{
			Name="HeaderText",
			Font="Wendy/_wendy small",
			Text=name.."\'s Gallery",
			InitCommand=function(self) self:diffuse(1,1,1,1):zoom(WideScale(0.5,0.6)):xy(_screen.cx, 45) end,
			OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
			SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
			SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
		},
}

-- Stage Number
if not PREFSMAN:GetPreference("EventMode") then
	af[#af+1] = Def.BitmapText{
		Font=PREFSMAN:GetPreference("EventMode") and "_wendy monospace numbers" or "Wendy/_wendy small",
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:diffusealpha(1):halign(1):zoom(0.5):x(_screen.w-8)
			if PREFSMAN:GetPreference("MenuTimer") then
				self:y(44)
			else
				self:y(34)
			end
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
		SwitchFocusToSongsMessageCommand=function(self) self:sleep(0.25):linear(0.1):diffusealpha(1) end,
	}
end

return af