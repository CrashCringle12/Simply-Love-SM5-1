
local binfo = ...
local apple = ""
local pages = binfo.pages
local currPage = 0;
local rows = binfo.rows
local cols = binfo.cols 
local accolades = binfo.achievements
local activePack = "Default"
local achievements = Def.ActorFrame {
	Name="Badges",
	-- Def.Quad {
	-- 	InitCommand=function(self)
	-- 		self:zoomto(binfo.w+24,3):rotationz(0):align(0,0):xy(-124,-18):diffusealpha(0)
	-- 		if ThemePrefs.Get("RainbowMode") then self:diffuse(0,0,0,0) end
	-- 	end,
	-- 	OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0) end,
	-- 	PageMessageCommand=function(self, params)
	-- 		if params.Player ~= binfo.player then return; end;
	-- 		if params.Page ~= 0 then
	-- 			currPage = params.Page
	-- 			self:linear(0.1):diffusealpha(0.8)
	-- 		else
	-- 			self:linear(0.1):diffusealpha(0)
	-- 		end
	-- 	end,
	-- },
	-- LoadFont("Wendy/_wendy white")..{
	-- 	Name='Achievements',
	-- 	InitCommand=function(self)
	-- 		self:settext("Achievements")
	-- 		self:y(binfo.y+148):zoom(0.20):shadowlength(ThemePrefs.Get("RainbowMode") and 0.5 or 0):cropright(1):diffusealpha(0)
	-- 	end,
	-- 	OnCommand=function(self) self:sleep(0.2):smooth(0.2):cropright(0) end,
	-- 	PageMessageCommand=function(self, params)
	-- 		if params.Player ~= binfo.player then return; end
	-- 		if params.Page ~= 0 then
	-- 			self:linear(0.1):diffusealpha(1)
	-- 		else
	-- 			self:linear(0.1):diffusealpha(0)
	-- 		end
	-- 	end,
	-- }
}
-- badges[#badges+1] = Def.ActorFrame {
-- 	Def.Quad {
-- 		InitCommand=function(self)
-- 			self:zoomto(info.w+25,1.25):rotationz(90):align(0,0):xy(info.padding*-8.5,33):diffusealpha(0)
-- 		end,
-- 		OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0.5) end,
-- 	},
-- 	LoadActor("tate.png")..{
-- 		InitCommand=function(self)
-- 			self:zoom(0.06):align(0,0):xy(50,-33):diffusealpha(0)
-- 			self:diffuse(0.1,0,0.1,1)

-- 		end,
-- 		OnCommand=function(self) self:sleep(0.45):linear(0.1):diffusealpha(0.5) end,
-- 	},

-- }
-- for loop to create 4 rows and 4 columns of badges
for p=1,pages do
	local badges = Def.ActorFrame {
		InitCommand=function(self)
			self:x(-28):y(-20):diffusealpha(0):zoom(1)
		end,
		PageMessageCommand=function(self, params)
			if params.Player ~= binfo.player then return; end;
			if params.Page == p  then
				self:linear(0.2):diffusealpha(1):zoom(1):visible(true)	
			else
				self:linear(0.4):diffusealpha(0):linear(0.01):zoom(1)
			end
		end,
	}
	local pI = ((p-1)*cols)
	local pY = ((p-1)*rows)
	-- 
	for j=1,rows do
		for i=1,cols do
				badges[#badges+1] = Def.ActorFrame {
					InitCommand=function(self)
						self:xy(0,0)
					end,
					Def.Sprite {
						InitCommand=function(self)
							self:visible(true)
							self:Load(SL.Accolades.Achievements[activePack][(j-1)*cols + i+pI ] and THEME:GetPathO("", "Achievements/"..activePack.."/"..SL.Accolades.Achievements[activePack][(j-1)*cols + i+pI].Icon) or "medal 4x3.png")
							self:zoomto(50,50):align(0,0):xy(-400+(90*i),-25+(68*((j-1)%rows))):diffusealpha(0)
							self:diffuse(0.1,0,0.1,1)
							--self:setstate(math.random(1,11))
							if math.random(0,100) % 30 == 0 then
								self:SetAllStateDelays(0.3)
							else
								self:animate(false)
							end
						end,
						OnCommand=function(self) 
							self:sleep(0.45):linear(0.1):diffusealpha(0.5) 
						end,
						GlowCommand=function(self)
							self:glowshift():effectcolor1(1,1,1,0.7):effectcolor2(1,1,1,0.1):effectperiod(1)
						end,
						UnGlowCommand=function(self)
							self:stopeffect()
						end,
						MigratoMessageCommand=function(self, params)
							-- TODO FIX THISSSS
							if true then
								if (activePack == "Trial") then
									self:Load("medal 4x3.png")
								else
									self:Load(SL.Accolades.Achievements[params.activePack][(j-1)*cols + i+pI ] and THEME:GetPathO("", "Achievements/"..params.activePack .."/"..SL.Accolades.Achievements[params.activePack][(j-1)*cols + i+pI].Icon) or "medal 4x3.png")
								end
								self:zoomto(50,50):align(0,0):xy(-400+(90*i),-25+(68*((j-1)%rows))):diffusealpha(0)
								self:diffuse(0.1,0,0.1,1)
								self:visible(true)
								--self:setstate(math.random(1,11))
								if math.random(0,100) % 30 == 0 then
									self:SetAllStateDelays(0.3)
								else
									self:animate(false)
								end
								if (j*i >= 20) then
									activePack = params.activePack
								end
							end
							if params.achievements then
								if ((j-1)*cols + i+pI) <= #SL.Accolades.Achievements[params.activePack] then
									if params.achievements[params.activePack     ] then
										if params.achievements[params.activePack     ][(j-1)*cols + i+pI] then
											if params.achievements[params.activePack     ][(j-1)*cols + i+pI].Unlocked then
												self:diffuse(1,1,1,1)
											else
												self:diffuse(0.1,0,0.1,0.5)
											end
										else
											self:diffuse(0.1,0,0.1,0.5)
										end
									else
										self:diffuse(0.1,0,0.1,0.5)
									end
								else
									--self:diffuse(0.1,0,0.1,0.5)
									self:visible(false)
								end
							end
							if ( (j-1)*cols + i+pI) == params.achievementIndex then
								self:queuecommand("Glow")
							else
								self:queuecommand("UnGlow")
							end
						end,
						
					},
		
				}
		end
	end
	achievements[#achievements+1] = badges
end

return achievements