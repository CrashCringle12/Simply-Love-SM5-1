
local characters = {
	"Crash Cringle",
}
local timeAtStart = GetTimeSinceStart()
-- Not including Epilogue Characters or map NPCs
local speaker = "Brandon"
local bigImages = false
----------------------------------------------------------------------------
----------------------------------------------------------------------------
local P1, P2, P1Score, P2Score
local difficulty, sTable
local colorDefault = "#ffffff"
local textDefault = 0.02
local textComma = 0.28
local textPeriod = 0.14
local textExclamation = 0.36
local textQuestion = 0.36
local text_actor = {}

local textMessage = 'test'
local textCounter
local box_flag = false
local num = math.random(0, 28)
local showMe = true

function TextSet(text, character)
	if not box_flag then
		text_actor.box:queuecommand('Show')
		text_actor.speaker:queuecommand('Show')
		text_actor["Andrew Tate"]:queuecommand('Show')

	end
	MESSAGEMAN:Broadcast('StartTalking')

	speaker = character
	textMessage = text
	textCounter = 0
	text_actor.mainText:queuecommand('Type')
end

function TextClear()
	text_actor.mainText:queuecommand('TextClear')
	if box_flag then
		MESSAGEMAN:Broadcast('HideBox')
	end
end

local version = tonumber(string.match(ProductID(),'%d+%.?%d*$')) or 5.0;
if version > 5.1 then
	SCREENMAN:SystemMessage('Sorry, this song was made for SM 5.1');
end

local WideScale = function(AR4_3, AR16_9)
	-- return scale( SCREEN_WIDTH, 640, 854, AR4_3, AR16_9 )
	local w = 480 * PREFSMAN:GetPreference("DisplayAspectRatio")
	return scale( w, 640, 854, AR4_3, AR16_9 )
 end

-- Messages to be applied, Number denotes the Mission these messages go off for.
 local messages1 = {
	{5, 'Test'},
	{19, 'HideCrash'},
	{20, 'HideDialogue'},
	{44, 'Clear'}
}

-- Dialogue for Mission 02
-- Casey's Rescue Mission
-- Song: Busta Rhymes goes to the Wii Shop
-- The chart ends with a captain viridian invasion.
local dialogue2 = {
	{1, function() TextSet("Hello uh, sorry to interrupt your session. But I could really use your help", "Crash Cringle");  end},
	{5, function() TextSet("My friends and I have been kidnapped and trapped inside this machine by my brother"); end},
	{10, function() TextSet("If you have a moment could you look around for them?")  end},
	{14, function() TextSet("Brandon might be able to help you, but even he is a little confused..") end},
	{19, function() TextSet("I'd suggest checking out that strange pack on the machine with the ominous question mark'");
		SCREENMAN:GetTopScreen():GetMusicWheel():SetOpenSection("UPSRT2.5 - Locked Away"); end},
	{25, function() TextSet("If you find anything do let me know. I'll be around if you need anything") end},

	{30, function() TextClear(); end},
}


local dialogue3 = {
	{1, function() TextSet("Hello uh, sorry to interrupt your session. But I could really use your help", "Crash Cringle");  end},
	{5, function() TextSet("My friends and I have been kidnapped and trapped inside this machine by my brother"); end},
	{10, function() TextSet("If you have a moment could you look around for them?")  end},
	{14, function() TextSet("Brandon might be able to help you, but even he is a little confused..") end},
	{19, function() TextSet("I'd suggest checking out that strange pack-") end};
	{21, function() TextClear(); end},
	{22, function() TextSet("Who is this pathetic lot with the audacity to ASK for help?", "Andrew Tate") end},
	{27, function() TextSet("You're old news. If you can't save your friends yourself you don't need them") end},
	{31, function() TextSet("Now, let ME show you something.") end},
	{35, function() TextSet("You see this ? That's my Dojo. Stay out of it");
		SCREENMAN:GetTopScreen():GetMusicWheel():SetOpenSection("UPSRT2.9"); end},
	{38, function() TextSet("This machine is now property of the Tate Brothers.") end},
	{43, function() TextClear(); end}
}

local changes = {}

local function setChanges()
	if showMe then
		if math.random() <  0.5 then 
			changes = dialogue3
		else
			changes = dialogue2
		end
		messages = messages1
		-- sort the messages by beat number (first index) just in case
		table.sort(messages, function (m1, m2) return m1[1] < m2[1] end )
	end
end


local function Handler_init() -- Useful for command shorcuts

	fgcurcommand = 0;
	wndr_skewx=0.3;
	checked = false;


	curmod = 1;
	--{beat,'mod'},
	mods = {

	}
	--SCREAMING GUMBALL / timed message broadcaster
	curmessage = 1;
	--{beat,message,ignoreIfAhead}
	messages = {}
	setChanges()

end
local counter = 1

local function Handler_update() -- Updates the command to look for the players at the start of the song.

	local time = GetTimeSinceStart() - timeAtStart

	if changes[counter] and time >= changes[counter][1] then
		changes[counter][2]()
		counter = counter + 1
	end
	--SM(beat)

	while curmessage<= #messages and time>=messages[curmessage][1] do
		if messages[curmessage][3] and time>=messages[curmessage][1]+5 then
			curmessage = curmessage+1;
		else
			MESSAGEMAN:Broadcast(messages[curmessage][2])
			curmessage = curmessage+1;
		end
	end
end
local last_score_x = 0
local g = Def.ActorFrame{
	InitCommand=function(self)
		if not showMe then
			self:visible(false)
		end
	end,

	OnCommand=function(self)
		Handler_init()
		self:SetUpdateFunction(Handler_update)

		-- ---------------------
		-- hide ScreenGameplay's "in" layer,
		-- which typically has a text overlay for
		-- "EVENT MODE" or "STAGE 1" or similar
		local screen = SCREENMAN:GetTopScreen()
		-- ---------------------
	end,
	Def.Quad{
		Name= "I may be sleeping, but I preserve the world.",
		InitCommand= cmd(visible,false),
		OnCommand= cmd(sleep, showMe and 33 or 3),
	},
}
g[#g+1] = Def.ActorFrame{
	InitCommand = cmd(zoom,.7*((SCREEN_HEIGHT/600));x,SCREEN_CENTER_X;y,SCREEN_BOTTOM-80);
			--Crash Speaking sprite
			--Currently trying to figure out how the bouncing works on the sprites
			Def.Sprite{
				Frames = {												
				{Frame=0,Delay=.1},
				{Frame=1,Delay=.13},
				-- {Frame=0,Delay=0.541459/4},
				-- {Frame=1,Delay=0.541459/4},
				};

				Texture = 'crash speaks 2x1.png';
				InitCommand = function(self) 
					sprite_9 = self;
					self:animate(false):visible(false)
				end, 
				OnCommand = cmd(diffusealpha,0;sleep,2;linear,.7;diffusealpha,1;addx,-30;addy,-332;visible,true);
				Delete0MessageCommand = cmd(visible,false);
				HideDialogueMessageCommand = cmd(diffusealpha,1;linear,.2;diffusealpha,0);
				HideCrashMessageCommand=function(self)
					self:linear(3):addrotationz(360):addx(700)
				end,
				StartTalkingMessageCommand=function(self)
					-- start animating
					-- regardless of direction the sprite is "facing".
					self:animate(true):visible(true)
				end;
				StopTalkingMessageCommand=function(self)
					-- stop animating and set the sprite's frame to 0,
					-- regardless of direction the sprite is "facing".
					self:animate(false):setstate(0)
				end
			};    
			Def.Sprite {
				-- Texture=FILEMAN:DoesFileExist(path..'lua/Dialog/'..person..' 1x3.png') and '../lua/Dialog/'..person..' 1x3.png' or '../lua/Dialog/'..person..' 1x2.png',
				Texture = 'Andrew Tate.png',
				OnCommand = function(self)
					self:diffusealpha(0):sleep(19):addx(-30):addy(-280):diffusealpha(1):zoom(0.7)
						:SetAllStateDelays(0.15):visible(true)
					text_actor["Andrew Tate"] = self
				end,

			},
			LoadActor('namebox')..{
				InitCommand = cmd(addy,-91;addx,-240;visible,true);
				OnCommand = cmd(diffusealpha,0;sleep,2;linear,.1;diffusealpha,1;);
				HideDialogueMessageCommand = cmd(diffusealpha,1;linear,.2;diffusealpha,0);
				HideCrashMessageCommand=function(self)
					self:linear(3):addrotationz(360):addx(700)
				end,

			};
			
			
			LoadActor('textbox')..{
				InitCommand=function(self)
					--self:CenterX():y(_screen.h*.85):zoom(.2):diffusealpha(0):SetAllStateDelays(0.15)
					text_actor.box = self
				end,
				ShowCommand=function(self)
					self:visible(true):zoom(0.9):diffusealpha(0.9):linear(.1):zoom(1)
				end,
				HideBoxMessageCommand=function(self)
					self:zoom(.3):linear(.1):zoom(0.1):diffusealpha(0)
				end,
				HideCommand=function(self)
					self:zoom(.3):linear(.1):zoom(0.1):diffusealpha(0)
				end,
				ClearMessageCommand=function(self)

					self:visible(false)
				end,
				HideDialogueMessageCommand = cmd(diffusealpha,1;linear,.2;diffusealpha,0);
				


		};
		Def.BitmapText{
			Font = "_open sans semibold";
			InitCommand = function(self) 
				text_actor.mainText = self
				self:visible(true):diffusealpha(1)
				self:Stroke(color('#000000'))
				self:shadowlength(0)
				self:zoom(1)
				self:addx(-355)
				self:addy(-50):horizalign("left"):vertalign("top"):wrapwidthpixels(750/self:GetZoom())
				self:sleep(2)
			end,
			TypeCommand = function(self)
				if textCounter <= string.len(textMessage) then
					textCounter = textCounter + 1
					self:settext(string.sub(textMessage,1,textCounter))
					if string.sub(textMessage,textCounter,textCounter) == ',' then
						self:sleep(textComma)
					elseif string.sub(textMessage,textCounter,textCounter) == '.' then
						self:sleep(textPeriod)
					elseif string.sub(textMessage,textCounter,textCounter) == '!' then
						self:sleep(textExclamation)
					elseif string.sub(textMessage,textCounter,textCounter) == '?' then
						self:sleep(textQuestion)
					end
					if textCounter % 4 == 0 then
						MESSAGEMAN:Broadcast('Talk')
					end
					self:sleep(textDefault)
					self:queuecommand('Type')
				else
					MESSAGEMAN:Broadcast('StopTalking')
				end
			end,
			TextClearCommand = function(self)
				self:settext('')
			end
			},		
			-- Loads the "Name holder"
			LoadActor('crash (doubleres).png')..{
				--To edit position edit the addy, and addx (Adjustments may be necessary for different names
				InitCommand = cmd(zoom,.75*((SCREEN_HEIGHT/600));addy,-90;addx,-238;visible,true);
				OnCommand = cmd(diffusealpha,0;sleep,2;linear,.1;diffusealpha,1;shadowlength,0;diffuse,1,1,1,1);
				HideDialogueMessageCommand = cmd(diffusealpha,1;linear,.2;diffusealpha,0);
				AppearCommand = cmd(visible,true);
			};

			Def.BitmapText{
				File='_helvetica neue 20px.ini',
				InitCommand = function(self)
					text_actor.speaker = self
					self:horizalign("left"):x(_screen.w*.15):y(_screen.h*.76):zoom(0.48):vertalign("top")
				end,
				ShowCommand=function(self)
					if speaker == 'Andrew Tate' then
						self:visible(true)
					else
						self:visible(false)
					end
					self:x(_screen.w*.17):settext("Andrew Tate")
				end,
				TextClearCommand = function(self)
					self:settext('')
				end,
				ClearMessageCommand=function(self)

					self:visible(false)
				end,
			};
};


return g
