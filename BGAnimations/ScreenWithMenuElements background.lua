local t = Def.ActorFrame{}

if (ThemePrefs.Get("RainbowMode") or ThemePrefs.Get("VisualStyle") == "Boba")or ThemePrefs.Get("VisualStyle") == "Boba" then
	t[#t+1] = Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( Color.White ) end
	}
end

t[#t+1] = LoadActor( THEME:GetPathB("", "_shared background"))

return t