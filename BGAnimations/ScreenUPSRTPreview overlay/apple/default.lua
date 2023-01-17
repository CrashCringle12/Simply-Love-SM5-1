
local characters = {
	"Taro",
	"Tejas",
	"Reen"
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
--[[

	Some of the code below here is part of the "Preliminary Check"
	We want to just check on a couple things to ensure a safe flight

	1. Version Warning - Stepmania Versions above 5.1 seem to interpet the mods differently
	2. Edit Chart - If the player is in Edit Mode or is on the Edit Chart, the mods do not play
	3. Mixmatch Choices - If one player is on Edit and the other is not, then both get set to Edit
		This is to ensure that no one is able to get a score on the modded charts by playing/reading an
		unmodded chart

]]--


function TextSet(text, character)
	if not box_flag then
		text_actor.box:queuecommand('Show')
		text_actor.speaker:queuecommand('Show')
	end
	speaker = character
	textMessage = text
	textCounter = 0
	text_actor.mainText:queuecommand('Type')
end

function TextClear()
	text_actor.speaker:queuecommand('TextClear')
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
}

-- Dialogue for Mission 02
-- Casey's Rescue Mission
-- Song: Busta Rhymes goes to the Wii Shop
-- The chart ends with a captain viridian invasion.
local dialogue2 = {
	{1, function() TextSet("Er -um sorry to interrupt.", "Professor Taro")  end},
	{5, function() TextSet("First, Congratulations on another succesful tournament")  end},
	{10, function() TextSet("I'm really glad to see everyone's having a good time but....")  end},
	{14, function() TextSet("I've sorta been kidnapped since 2015") end},
	{20, function() TextSet("As much as I love Taco Wednesdays at WinDEU's") end},
	{23, function() TextSet("I'd uh really like to get home.") end},
	{26, function() TextClear() end},
	{27, function() TextSet("Sorry about that. We were on our way but uh", "Reen") end},
	{30, function() TextSet("We ran into a few hiccups ourselves") end},
	{33, function() TextClear() end},

	{34, function() TextSet("Don't worryyy Professor, I've faith *someone* is coming", "Tejas") end},
	{39, function() TextClear() end},
	{41, function() TextSet("*Sigh* Is it going to take another 7 years?", "Professor Taro")  end},

	{44, function() TextSet("Ehhh I'd give it juust one more.", "Tejas") end},
	{49, function() TextClear() end},
}


local changes = {}

local function setChanges()
	changes = dialogue2
	messages = messages1
	-- sort the messages by beat number (first index) just in case
	table.sort(messages, function (m1, m2) return m1[1] < m2[1] end )
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
		OnCommand= cmd(sleep,1000),
	},
}
g[#g+1] = LoadActor("Dialog/box.png")..{
	InitCommand=function(self)
		self:CenterX():y(_screen.h*.85):zoom(.2):diffusealpha(0):SetAllStateDelays(0.15)
		text_actor.box = self

	end,
	ShowCommand=function(self)
		self:visible(true):zoom(0.2):diffusealpha(0.9):linear(.1):zoom(.3)
	end,
	HideBoxMessageCommand=function(self)
		self:zoom(.3):linear(.1):zoom(0.1):diffusealpha(0)
	end,
	HideCommand=function(self)
		self:zoom(.3):linear(.1):zoom(0.1):diffusealpha(0)
	end
}

g[#g+1] = Def.BitmapText{
	File='_helvetica neue 20px.ini',
	InitCommand = function(self)
		text_actor.speaker = self
		self:horizalign("left"):x(speaker == "Brandon" and _screen.w*.21 or _screen.w*.18):y(_screen.h*.76):zoom(0.8):vertalign("top")
	end,
	ShowCommand=function(self)
		self:x(speaker == "Brandon" and _screen.w*.21 or _screen.w*.18):settext(speaker)
	end,
	TextClearCommand = function(self)
		self:settext('')
	end,
}
g[#g+1] = Def.BitmapText{
	File='_helvetica neue 20px.ini',
	InitCommand = function(self)
		text_actor.mainText = self
		self:horizalign("left"):x(_screen.w*.20):y(_screen.h*.83):zoom(1.1):vertalign("top"):wrapwidthpixels(572/self:GetZoom())
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
}
return g
