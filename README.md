# Simply Love for SM5 - Cabby Edition (v4.10.*)
![Arrow Logo](https://i.imgur.com/oZmxyGo.png)

# About
This is information regarding Simply Love v4.10 or the PSU ("Cabby") Fork of Simply Love. The intention of this fork isn't really to divert from upstream Simply Love, but rather to orient this fork to the public cab experience. For that reason, some features are modified, reverted, or hidden by default in order to ensure the best public cab experience. The "Public Cab Experience" is just based off of the PSU Dance Dance Maniac's new and old club member experience on the public cab.
***
## Supported Versions of StepMania
✅ StepMania 5.0.12 [Branch](https://github.com/CrashCringle12/Simply-Love-SM5/tree/stepmania) <br />
✅ StepMania 5.1-b2 [Branch](https://github.com/CrashCringle12/Simply-Love-SM5/tree/stepmania) <br />
✅ StepMania 5.1-psu-cabby (Fork) [Branch](https://github.com/CrashCringle12/Simply-Love-SM5/tree/stepmania) <br />
✅ ITGMania [Branch](https://github.com/CrashCringle12/Simply-Love-SM5/tree/psu-cabby)

Cabby is currently using ITGMania (Though it is likely we will be moving back to StepMania in the future. Psu-cabby branch reflects what is currently in use on cabby. See the respective itgmania and stepmania branches for the respective support.


# Major Differences

## Classic ITG UI
The Density Graph + Tech Analyzer Added in Simply Love v5.0.0 is truly an incredible feature. However, we felt that the feature was a bit overwhelming for newer players. We felt that it also could ward players off from trying new songs out of fear of what is displayed here. In short, this feature sort of removes a lot of the _wonder_ and/or _surprise_ from going into new charts. This was a factor that DDM seemed to want to keep intact. As a result, the Density Graph + Tech Analyzer was moved to **Only** be present in FA+ mode. When in ITG mode the Select Music screen will replicate its now _legacy_ look.
<h3 align="center">ITG</h3>

![](https://i.imgur.com/NLzYOtR.png)
<h3 align="center">FA+</h3>

![](https://i.imgur.com/9hr7kLM.png)

## Screenshot Gallery
Quickly access and view your gallery of screenshots while still in game. I thought this feature might make increase the accessibility of screenshots. Currently on Cabby, if you are using a LocalProfile (Profile stored on the machine), you pretty much can't view your screenshots without additional help.  Even if you have a USB Profile or have access to the machine in question, you still have to manually navigate to your screenshot folder to view screenshots. This feature allows you to view all of your screenshots straight from the game. 

![](https://i.imgur.com/BgUWnPU.png)

The Gallery has its own Timer editable under `MenuTimer Options` in the Operator Menu

## Favorites

You ever wish you could just favorite songs? Cabby has over 16000 songs, so it eventually can be difficult to remember _that one song I played 4 months ago that was kinda fun_. Well now you can save songs to your favorites and quickly scroll through your own makeshift pack of songs

![](https://i.imgur.com/TQznbmx.png)

The feature adds pad codes for favoriting songs on the `Screen Evaluation` after playing a song. These codes are editable in `metrics.ini` but by default **you can favorite a song by performing a spin on your respective pad** (RDLUR or LDRUL) on the Evaluation screen (Screen showing your stage results)
Favorites can be accessed from the Sort Menu as shown below.

![](https://i.imgur.com/nbhZq0G.png)

In order to use favorites you must be on a profile! Favorites can be removed the same way they are added!

**KNOWN ISSUES** If you are playing in TWO-PLAYER mode, you notice that your list of favorites now includes several separators throughout with an incorrect song count. This seems to be a bug with StepMania, and unfortunately was the only way to get this feature to work. It is purely visual and has no effect on your favorites listing or gameplay. Both players should be able to view their respective favorites without issue otherwise.

## Money Legend
We often see new players very confused when approaching the machine. From presuming touchscreen functionality to searching for the credit card reader, new players are often perplexed by the intricacies of Cabby. I hope to make the experience a lot easier and straightforward for new players and maybe one day make them into a not-so-new player. One of the big and unfortunate misconceptions about cabby is that the machine is either free or costs strictly a dollar. This screen aims to catch a new player and explain the pricing. It might not be free, but it's definitely a lot cheaper than $1. The text is editable in `en.ini`

![](https://i.imgur.com/1TUPzDj.png) 

## COVID/Safety Warning
The PSU Cab was permitted to stay active throughout the COVID-19 pandemic; however, in order to do so I had to hastily draft up a letter of standards and practices we would adhere to throughout it. In the letter I offered to create a new screen that would show up before gameplay instructing players of some of these guidelines. The letter was quickly responded to, responded before the screen even existed which meant that would need to change before any officials came to cabby. Thanks to the help of @quietly-turning and @Jeremy who did graphic design at a rest stop to get this up.

![](https://i.imgur.com/7D55olf.jpg)

This screen was put in place for the Fall 2020-2021 school year and has remained in place since then. With COVID restrictions changing, the player limit has long since been restored. This screen will likely be converted into a Safety Warning screen that still appears before gameplay.

## Good Reads Mode & "Virtual Profiles"
Note: this behavior has since been changed with ITGMania's introduction. I haven't updated this wiki to reflect that yet.
![](https://i.imgur.com/dwLsDcC.png)

For a full information on the Good Reads tournament view the [Good Reads](https://github.com/CrashCringle12/Simply-Love-SM5/wiki/Tournaments#Good-Reads) page. Good Reads Mode functions no differently than ITG mode. The mode exists the enable certain good reads features that are not available otherwise. The most notable of these features is the idea of being able to use a "Virtual Profile." In Good Reads mode there is now an option to Select Profile in the middle of a session through the Sort Menu. This brings back the Select Profile screen for both players allowing them to choose a profile. 

![](https://i.imgur.com/WNNhk9b.png)

The difference between Selecting a profile in good reads mode vs at the start is that this **only** pulls all of the profile's settings and information. You are still technically _signed in_ as the profile you chose at start. Choosing a profile here allows you to quickly switch settings in the middle of a session.
There are a few use cases for this (Mainly oriented for public cabs):
* Running the Good Reads tournament
* Late joining another player in a session and wanting to quickly enable your settings
* Wanting to view the settings of another player without signing in as them.

Another use case that would prove useful for people on their own setup (Note however, this wasn't the intended purpose for this feature but it _could_ be used this way) :
* Having Multiple profiles that exist as different settings for different styles/modes 
    * For example, you could create four profiles called "Stamina," "Gimmicks," "Standard," and "Couples." apply your couples settings to this profile.
![](https://i.imgur.com/2ruAtot.png)

If you check the bottom of the screen you can see that I had already chosen the `Lamar` profile. By choosing `Stamina` here, I will changing my current settings (Speed Mod, Mini, Filter, FA+ Windows, etc.) to `Stamina` for this **current** session. This does not modify the settings for the `Lamar` profile but allows us to _virtually_ change profiles, but not actually. This could be used for having multiple settings presets as described above. However, I would probably recommend a bit of a UI change for this new Select Profile screen if that becomes an actually used use-case.

# Minor Changes/Other
* Timing Windows on Casual Mode are expanded in order to help new and random players feel the barrier for entry isn't as high as it may seem. After watching casual and random players play on the machine for a few years and barely be able to scrape by, I thought this was needed.
    * Timing Window Scale 1 -> 2.5
* Option to choose Screen Filter Background Color
    * Honestly, I did not expect this to actually be used. I personally don't really like the look of the non-black colors. I added the Rainbow option as a bit of a joke. I left the feature on the machine and to my surprise it's seen a lot of traction.
* WIP Github Wiki explaining various stuffs
* Discord Rich Presence support via my SM5 fork (Commented out by defualt)
* Column Cues are always enabled in Casual Mode
* The Ex/FA+ Scoring is not visible by default in ITG mode
    * This was a bit intimidating to new players and made the gateway for entry seem even more unattainable. By default in ITG mode you only receive your ITG score on ScreenEvaluation. You can still view your Ex/FA+ Scoring if you enable one of the options in AdvancedOptions
* New Visual Styles
    * PSU, Lucky, GotEm, Ice_Cream, Spades, and Boba
    * Default Visual Style: PSU
* Option to Randomize Visual Styles 
* When two players are selecting their profiles, both players must select their profiles before moving forward.
    * Previously, one player could choose and move on before the other was ready
    * Added a cursor to show selected profile
* SelectProfile starts on Guest instead of the first profile
    * The Select Profile screen is always present on cabby. New players often end up just picking the first profile they are set on which was `Laurence`. With the additional of Profile based achievements this became a bit of an issue.
* Additional Packs/Groups added to Casual Mode
    * 2014 Billboard Hits
    * DDRA
    * DDRA20
    * PSU SOWNDS
    * RIME's Collection
* Altered Casual Mode Default Song possibilities to include some of these new packs added to the mode
* New Emojis
    * 🍦❄☔♠🌸🧋 (Bubble Tea Emoji here)
* Additional ITG Judgement Fonts
    * 3_9
    * Backwards
    * Brit
    * DDR SuperNOVA
    * DDR X
    * DDR X2
    * DDR X3
    * Epsilon
    * Funkin
    * Moist
    * TM1 (TrotMania)
    * TM2
    * TM3
    * TM4
    * TM4Night
    * TMITG
    * Unown
    * Yummy
* Added Funkin Hold Judgement
* Quad "That RIMES" Easter Egg
> RIME was a prominent club member when I first joined in 2017. He usually had the high score on the majority of the songs I liked to play. At the time his scores seem unattainable... "How can someone so consistently score above 98% on everything he plays? His sightreading abilities were something I hadn't seen before. Passing songs such as D.O.W.N.S 4's Box and S.M.H.4's Brain Power with little to no previous practice. He was the first person some of us had ever seen quad any songs. Many of his scores live on today as his legacy continues even after his graduation. During his last year here, I wanted to find a way to immortalize RIME, to sort of show that he had became "something" in our eyes. At the time I had very little theming experience, but came up with the easter that would appear if you get 100% on a song. I put the easter egg up on his birthday and tried to get him to quad something that day to show it.
