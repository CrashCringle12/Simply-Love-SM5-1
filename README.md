# Simply Love (StepMania 5)

![Arrow Logo](https://i.imgur.com/oZmxyGo.png)
======================

## About

Simply Love is a StepMania 5 theme for the post-ITG community.

It features a clean and simple design, offers numerous data-driven features not implemented by the StepMania 5 engine, and allows the current generation of ITG fans to breathe new life into the game they've known for over a decade.

Simply Love was originally designed and implemented for a previous version of StepMania (SM3.95) by hurtpiggypig.  For more information on that version of Simply Love, check here:
https://www.youtube.com/watch?v=OtcWy5m6-CQ



## Setup

You'll need to install [StepMania 5.0.12](https://github.com/stepmania/stepmania/releases/tag/v5.0.12) or [StepMania 5.1 beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2) to use this theme.

Older versions of StepMania are not compatible.  StepMania 5.2 is not compatible.

### Troubleshooting StepMania

StepMania can be tricky to install and the process has different stumbling points unique to each OS.

#### Windows

You'll need to install Microsoft's [Visual C++ x86 Redistributable for Visual Studio 2015](http://www.microsoft.com/en-us/download/details.aspx?id=48145) first.

With that done, follow along with the StepMania installer, ensuring that you **do not install to Program Files** to avoid conflicts with Windows UAC.  By default, the installer will install to `C:\Games\` and this is fine for most players.

If StepMania crashes with **d3dx9_43.dll was not found** you'll need to install the DirectX 9 runtime. [This GitHub issue](https://github.com/stepmania/stepmania-site/issues/64) provides a link to how you can download it from Microsoft.  It [should be okay](https://github.com/stepmania/stepmania/issues/1936#issuecomment-557917810) to have multiple DirectX runtimes installed.

#### macOS

If you are unable to open the dmg installer with an error like "No mountable file systems", you'll need to [update your copy of macOS](https://github.com/stepmania/stepmania/issues/1726) for the time being.

If StepMania crashes immediately with **No NoteSkins found** or **Metric "Common::ScreenWidth" is missing**, [this wiki page](https://github.com/stepmania/stepmania/wiki/Installing-on-macOS) provides a way of fixing it on your computer until it the problem is properly fixed in StepMania.

#### Linux

If the precompiled executable is not compatible with your architecture/distro/etc., you'll likely have better luck compiling from source.

* [Linux Dependencies](Linux-dependencies)
* [Instructions on Compiling](Compiling-StepMania)

### Other Setup/Troubleshooting Resources

The StepMania project has wiki pages for configuring USB profiles for [Windows](https://github.com/stepmania/stepmania/wiki/Static-Mount-Points-for-USB-Profiles-(Windows)) and [Linux](https://github.com/stepmania/stepmania/wiki/Creating-Static-Mount-Points-For-USB-Profiles-%28Linux%29).  USB profiles are handy for public arcade machines so that players can enjoy their own custom content from USB drives.

GitHub user geefr has a [wiki page](https://github.com/geefr/stepmania-linux-goodies/wiki/So-You-Think-You-Have-Polling-Issues) on identifying and troubleshooting USB polling rate issues.

## Installing Simply Love

Head to the [Releases Page](https://github.com/quietly-turning/Simply-Love-SM5/releases/latest) to download the most recent formal release of Simply Love.

To install this theme, unzip it and move the resulting *Simply Love* folder inside your [StepMania user data directory](https://github.com/stepmania/stepmania/wiki/User-Data-Locations).  The paths will look like this:

* **Windows**: `%APPDATA%\StepMania 5.1\Themes\Simply Love\`
* **macOS**: `~/Library/Application Support/StepMania 5.1/Themes/Simply Love/`
* **Linux**: `~/.stepmania-5.1/Themes/Simply Love/`

## Screenshots

Visit my imgur album for screenshots of this theme in action: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)

## New Features

Or, *things I've added that were not present in the original Simply Love for StepMania 3.95.*

#### New GameModes

* [Casual](http://imgur.com/zLLhDWQh.png) – Intended for novice players; restricted song list, no failing, no LifeMeter, simplified UI, etc.  You can read more about customizing what content appears in Casual Mode [here](./Other/CasualMode-README.md).
* [ITG](http://imgur.com/HS03hhJh.png) – Play using the *In the Groove* standards established over a decade ago
* [FA+](http://imgur.com/teZtlbih.png) – Similar to ITG, but features tighter TimingWindows; can be used to qualify for ECFA events
* [StomperZ](http://imgur.com/dOKTpVbh.png) – Emulates a very small set of features from Rhythm Horizon gameplay

#### New Auxiliary Features

  * [Live Step Statistics](https://imgur.com/w4ddgSK.png) – This optional gameplay overlay tracks how many of each judgment have been earned in real time and features a notes-per-second density histogram.  This can make livestreaming more interesting for viewers.
  * [Judgment Scatter Plot](https://imgur.com/JK5Li2w.png) – ScreenEvaluation now features a judgment scatterplot where notes hit early are rendered "below the middle" and notes hit late are rendered "above the middle." This can offer insight into how a player performed over time. Did the player gradually hit notes earlier and earlier as the song wore on? This feature can help players answer such questions.
  * [Judgment Density Histogram](https://imgur.com/FAuieAf.png) – The evaluation screen also now features a histogram that will help players assess whether they are more often hitting notes early or late.
  * [Per-Column Judgment Breakdown](https://imgur.com/ErcvncM.png)
  * [IIDX-inspired Pacemaker](http://imgur.com/NwN8Fnbh.png)
  * [QR Code Integration with GrooveStats](https://imgur.com/olgg4hS.png) – Evaluation now displays a QR code that will upload the score you just earned to your [GrooveStats](http://groovestats.com/) account.
  * improved MeasureCounter – Stepcharts can now be parsed ahead of time, so it is no longer necessary to play through a stepchart at least once to acquire a stream breakdown.

#### New Aesthetic Features
 * [RainbowMode](http://i.imgur.com/aKsvrcch.png) – add some color to Simply Love!
 * [NoteSkin and Judgment previews](https://imgur.com/QUSqxr8.png) in the modifier menu
 * improved widescreen support

#### New Conveniences for Public Machine Operators
  * [MenuTimer Options](http://imgur.com/DPffsdQh.png) – Set the MenuTimers for various screens.
  * [Long/Marathon Song Cutoffs](http://i.imgur.com/fzNJDVDh.png) – The cutoffs for songs that cost 2 and 3 rounds can be set in *Arcade Options*.

#### Language Support

Simply Love has support for:

  * English
  * Español
  * Français
  * Português Brasileiro
  * 日本語
  * Deutsch

The current language can be changed in Simply Love under *System Options*.


---

## FAQ

#### Why are my high scores ranking out of order?
You need to set `PercentageScoring=1` in your Preferences.ini file.  Please note that you must quit StepMania before opening and editing Preferences.ini.

Your existing scores will remain ranked out of order, but all scores going forward after making this change will be ranked correctly.

#### Where is my Preferences.ini file?
See the [Manually Changing Preferences](https://github.com/stepmania/stepmania/wiki/Manually-Changing-Preferences) page on StepMania's GitHub Wiki.

#### How can I get more songs to show up in Casual Mode?
Please refer to the [Casual Mode README](./Other/CasualMode-README.md).

