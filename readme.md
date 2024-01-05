# Smash Remix
*A Super Smash Bros. 64 Mod Organized by The_Smashfather*

## Building
### THIS IS ONLY FOR THOSE INTERESTED IN THE SOURCE CODE OF THE MOD. PLEASE DOWNLOAD THE RELEASE VERSION BY CLICKING THE RELEASE TAB.
The original xdelta will generate a smash rom that is compatible with our ASM code. Much of our edits are done within
the compressed files within the rom. If you utilize a vanilla Smash 64 rom, it will not work correctly.

You must utilize the xdelta patch to generate a good rom for Assembly.

You must place your legally acquired patched ROM in the 'roms' folder for this to work. It must be named ssb.rom

# Features
(Note: Smash Remix requires the the 8 MB expansion pak to be enabled.)
## Gameplay
### AI Improvements
Computer controlled players have received a variety of improvements.
- They attempt to recover more than once.
- They randomly tech (30% left, 30% right, 30% in place, 10% missed).
- They Z-Cancel (95% success rate).
- CPU Level 10 added.

#### Toggle Name: _Improved AI_


### Combo Meter Improvements
- "Improved Combo Meter" prevents the combo meter from resetting when the character is grabbed or bounces off of a wall.
- Additionally, the "Tech Chase Combo Meter" toggle will prevent the combo meter from resetting on an inescapable tech chase.

#### Toggle Names: _Improved Combo Meter_, _Tech Chase Combo Meter_

### Combo Meter Display
- Displays a combo meter above players being comboed outside Training mode.
- Combo meter color corresponds with attacking player's port or team.
- In 1v1 matches, the "1v1 Combo Meter Swap" toggle will display the combo meter above the player performing the combo.

#### Toggle Names: _Combo Meter_, _1v1 Combo Meter Swap_

### Expanded Character Select Screen
- The character select screen is now expanded to 30 slots including 16 custom characters.
- Metal Mario, Giant DK, and polygon versions of the original cast are available via d-pad up or down.
- Japanese versions of the original cast are available via d-pad left.
- European versions of some of the original cast are available via d-pad right.
- Giga Bowser, Mad Piano, Super Sonic, Peppy, Slippy, Metal Luigi, Ebisumaru, and Dragon King are available via d-pad up.
- Polygon versions of some of the remix cast are available via d-pad down.

### Character Select Debug Menu
A menu for modifying certain character attributes is available on each panel.

##### Shield
- Allows selecting a shield color.
- The Costume option will use a shield color matching the selected costume.
- The Vanilla option will use the vanilla shield color scheme for that port.
##### Visibility
- Allows playing as completely invisible (None), slightly visible (Cloaked), or as a silhouette (Dark).
##### Player Tag
- Allows player to select a stored tag.
- Names are always visible when selected.
##### Skeleton
- Setting to enabled is perfect for Halloween.
##### Model
- Allows forcing high definition or low definition version of character.
##### Input HUD
- Allows showing the button and joystick inputs in an unobtrusive overlay.
- Can be configured to show on top or bottom of screen.
##### Size
- Allows playing as the giant or tiny version of the character.
##### Stock
- "Last" mode maintains stock count from the previous game. Useful for crew battles.
- "Manual" mode allows specifying the stock count.
##### Knockback
- Setting to random will create a moveset for the character with randomized knockback.
- The knockback angle is generated for each move at the start of the match and will persist until the end of the match.
- Resetting training mode or performing a salty runback will not generate a new set of knockback angles.
##### Delay
- Adds input delay to imitate netplay. HMN ports only.
##### Handicap
- Allows modifying CPU handicap. CPU ports only.
##### Start With
- Allows specifying an item for the character to start matches and respawn with.
##### Taunt Itm.
- Allows specifying an item that will spawn in the character's possession when the taunt button is pressed.
##### Taunt Btn.
- Allows remapping the taunt button to C or d-pad buttons.
##### Kirby Hat
- Allows setting Kirby's hat.
##### Practice
- Activates 1p Practice mode and allows stage selection (for 1p and Remix 1p).
- Scores are disabled while this is active.
- Can reset stage while mode is activated (press L while paused, during GameEnd, or at Score Screen).
##### Dpad map
- Available mappings are: 'Smash', 'Tilt' or 'Special'
##### Dpad ctrl
- Available control schemes are: 'Stick Swap', 'Stickless', 'Stick Swap J', or 'Stickless J'
    - 'Stick Swap' switches Dpad and Stick inputs, and can be used in conjunction with 'Dpad Map'.
- Note: When using this, Shield is mapped to L and Taunt is mapped to Z.
##### Initial Damage
- Allows setting the damage percent to begin the match with.
##### Poison Dmg
- Applies constant percent damage every two seconds.
- Available strengths are: 'Low' (1%), 'Med' (2%), 'High' (4%), 'Heal' (-1%)

#### Toggle Name: _CSS Panel Menu_

### Expanded Stage Select Screen
- The stage select screen is now expanded to multiple pages.
- All original stages are playable as well as dozens of new stages.

### Stage Hazard Modes
- Pressing L on the stage select screen will cycle through the selected stage's available hazards.
- Hazards (bumpers, barrels, etc.) and Movement (of platforms) can turned off.
- The Cursor's color indicates which hazard types are being turned off:
    - Red = None, Lightblue = Hazards, Cyan = Movement, Blue = Both
- Note: Stage hazards cannot be changed when using the TOURNAMENT stage select layout.

#### Toggle Name: _Hazard Mode_

### Whispy Mode
- Available Whispy wind speeds are: 'Normal', 'Japanese', 'Super', or 'Hyper'

#### Toggle Name: _Whispy Mode_

### Saffron Pokemon Rate
- Available Pokemon rates are: 'Normal', 'Super', 'Hyper', or 'Quick Attack'

#### Toggle Name: _Saffron Pokemon Rate_

### Pokemon Announcer
- Available options are: 'Stadium', 'All Stages', or 'Off'

#### Toggle Name: _Pokemon Announcer_

### Dragon King HUD
- Available options are: 'Dragon King', 'All Stages', or 'Off'

#### Toggle Name: _Dragon King HUD_

### Stage Select Layout
- Choose between NORMAL and TOURNAMENT stage select layouts. In the TOURNAMENT layout, the stages available align with the Smash Remix Tour ruleset.
- Note: Random stage selection respects layout.

#### Toggle Name: _Stage Select Layout_

### Hold to Pause
- Prevents accidental pausing by requiring the start button to be held for half of a second before pausing.

#### Toggle Name: _Hold To Pause_

### Neutral Spawns
- Players spawn across from one another regardless of port.

#### Toggle Name: _Neutral Spawns_

### Salty Runback
- Holding Start along with A + B + Z + R will restart the match on the same stage.
- Note: Can select alternate button combo (A + B + Z + R + D-Pad Right).

#### Toggle Name: _Salty Runback_

### Salty Runback Preserves Song
- Salty Runbacks will restart with the same track.

#### Toggle Name: _Salty Runback Preserves Song_

### Timed Stock Matches
- Stock matches have a timer. Enabled by default but can be toggled off by setting TIME to "infinity."

### Match Stats
- Results screen has the option to show stats about the match such as damage given to each player.
- If the Vs Mode Combo Meter toggle is on, combo stats are also displayed.

### 12-Character Battle Mode
- New VS mode for easily tracking 12cbs.
- Features 4 preset character sets (Default, Japanese, Polygon, Remix) and allows for a custom character set per player.
- Best character for each player is tracked as the number of TKOs the opposing player experiences against your character.
- Only ports 1 and 2 work with this mode.

### Stamina Mode
- New VS mode rule option which enables H.P. to be used instead of damage.
- The player is out when H.P. reaches 0, and the match ends when only one player/team has H.P. remaining.

### Additional Items
 - New items available in training mode and in VS mode.
 - VS Mode Item Switch expanded to allowing toggling new items.
#### Cloaking Device
 - Renders the player invisible and impervious to damage for 10 seconds.
#### Super Mushroom
 - Player grows into giant form with added passive armor while dealing higher damage.
 - Lasts 10 seconds.
#### Poison Mushroom
 - Player shrinks into tiny form and deals less damage.
 - Lasts 10 seconds.
#### Spiny Shell
 - Throwable. Similar to Red/Green Shells. While active, it will go towards the player who is in first place.
#### Lightning
 - Shrinks the players opponents into tiny form.
 - Lasts 10 seconds.
#### Deku Nut
 - Throwable. Stuns opponents who get hit.
#### Franklin Badge
 - Player becomes immune to projectiles. Projectiles that hit the player will be reflected back.
 - Lasts 20 seconds.
#### Pitfall
 - Throwable. Can be planted, similar to a proximity mine. When stepped on, buries a player in the ground.
#### Golden Gun
 - A powerful, single-shot weapon. Similar to the RayGun. TOP SECRET.
#### Dango
 - Ebisumaru's food of choice. Heals 10%.
#### P-Wing
 - Player can jump continuously in midair.
 - Lasts 20 seconds.

### Tripping
- If enabled, characters will randomly trip when dashing or running.

#### Toggle Name: Tripping

### Footstool Jumping
- If enabled, you can jump off characters heads!

#### Toggle Name: Footstool Jumping

### Air Dodging
- If enabled, fighters can air dodge to evade attacks! Also has an Air-Dashing mode.

#### Toggle Name: Air Dodging

### Jab Locking
- If enabled, you can jab-lock your opponents.

#### Toggle Name: Jab Locking

### Edge C-Jumping
- If enabled, you can press one of the C-Buttons to jump up while hanging from a ledge.

#### Toggle Name: Edge C-Jumping

### Perfect Shielding
- If enabled, you can perform perfect/power shielding against your opponents attacks.

#### Toggle Name: Perfect Shielding

### Spot Dodging
- If enabled, you can dodge opponents attacks while grounded with Z/R + Down.

#### Toggle Name: Spot Dodging

### Fast Fall Aerials
- If enabled, you can input a fast fall while doing an aerial attack.

#### Toggle Name: Fast Fall Aerials

### Ledge Trumping
- If enabled, you can grab a ledge even if another fighter is already holding onto it.

#### Toggle Name: Ledge Trumping

### Wall Teching
- If enabled, fighters can tech off walls and ceilings too.

#### Toggle Name: Wall Teching

### Charged Smash Attacks
- If enabled, fighters can charge smash attacks.

#### Toggle Name: Charged Smash Attacks

### Item Containers
- Allows disabling item containers, having them never explode, or forcing explosions.
- Affects Crates, Barrels, Capsules.

#### Toggle Name: Item Containers

### Blastzone Warp *BETA
- If enabled, fighters will warp across Blastzones instead of KOing.

#### Toggle Name: Blastzone Warp *BETA

## Customization
### Costume Selection Improvements
- Access all available costumes by scrolling with the left and right C buttons.
- Access all available shades by scrolling with the up and down C buttons.
- Metal Mario and the polygons also have alternate costumes.
- To control CPU costumes, hover over the panel at the bottom of the screen and press the C buttons.

### Random Music
- Random music allows players to listen to music from other stages.

#### Toggle Name: _Random Music_

### Random Music Switch
- Changes the possible music tracks to be used when random music is enabled.

#### Toggle Name: Each track's title is listed in the Music Settings menu

### Random Music Profiles
Load a curated list of tracks.
- Community: All tracks.
- Vanilla: Only tracks from the original game.
- Classics: Features themes and arrangements from games on the N64 and prior systems.
- Into Battle: Mostly comprised of dramatic, intense, or exciting music.
- Positive Vibes: Mostly comprised of upbeat, energetic, or happy music.
- Slappers Only: The_Smashfather's personal favorite tracks.
- Staff Picks: Favorites of the contributors of Smash Remix.

### Menu Music
- Choose between the classic SSB64 music or from Melee's and Brawl's menu themes, as well as various tracks from other games.
- By default, the Melee and Brawl themes will play from time to time.
- Can turn menu music off if desired.

#### Toggle Name: _Menu Music_

### Alternate Music
- Custom stages have up to two alternate tracks that will play at random.
- The "Occasional" alternate track plays more frequently than the "Rare" alternate track.
- The music track can be forced by holding a C button when choosing the stage: C-up = Default, C-left = Occasional, C-right = Rare

### Random Stage Switch
- Changes possible outcomes of pressing RANDOM on the stage select screen.

#### Toggle Name: Each stage's name is listed under Random Stage Toggles in the Stage Settings menu

### Random Stage Profiles
Load a curated list of stages.
- Community: All stages except for Dream Land Beta 1 and 2 and How to Play.
- Tournament: All stages generally agreed to be "legal" in tournaments.
- Semi-Competitive: Stages that give some variation but are still considered somewhat competitive.
- Competitive: Stages that may not be "tournament legal" but are still considered competitive.
- Vanilla: All original stages except for Dream Land Beta 1 and 2 and How to Play.
- Dream Land Only: All stages with Dream Land layout.
- No Omega Variants: All stages except for Omega variants, Dream Land Beta 1 and 2 and How to Play.
- No Variants: All stages except for variants, Dream Land Beta 1 and 2 and How to Play. (Fray's Stage Night is included.)
- Staff Picks: Favorites of the contributors of Smash Remix.

### Random Select With Variants
- By default, the variants (Metal Mario, Giant DK, polygons, J/E regional versions) are not included in the random character select that occurs when toggling the CPU button on the character select screen.
- This toggle allows for them to be included.

#### Toggle Name: _Random Select With Variants_

### Player Tags
- Can store up to 20 names (which are be selected via Character Menu Panel).

## Practice
### Hold to Exit Training
- Prevents accidentally exiting training mode by requiring the A button to be held for half of a second when on the Exit pause menu option.

#### Toggle Name: _Hold To Pause_

### Special Model Display
Use the toggle or cycle using D-Pad down in Training Mode.
- Hitbox: Displays hitboxes and hurtboxes instead of normal characters/items/projectiles.
- Hitbox+: Displays transparent hitboxes and hurtboxes alongside normal characters/items/projectiles.
- ECB: View character and item collision diamonds.

#### Toggle Name: _Special Model Display_

### Advanced Hurtbox Display
When Special Model Display is Hitbox or Hitbox+, these changes are applied:
- Transparent hitboxes
- Cyan grab-immune hurtboxes
- Gray hurtboxes during active armor
#### Toggle Name: _Advanced Hurtbox Display_

### Color Overlays
- Fills in the character model with a solid color during certain player states.

#### Toggle Name: _Color Overlays_

### Flash On Z-Cancel
- Displays a sparkle effect when a successful Z-cancel input is detected on landing.

#### Toggle Name: _Flash On Z-Cancel_

### Z-Cancel
- Allows Disabling Z-Cancel, using Melee timing (7 frames), Automating, or 'Glide Mode' (landing does not cancel attack).

### Punish Failed Z-Cancel
- Punishes the player in various ways for missing Z-cancels.

#### Toggle Name: _Punish Failed Z-Cancel_

## Quality of Life
## New Music Added
- Dozens of new music tracks featuring some new instruments added.

### Improved Pause Camera
- Allows the camera to be zoomed, moved and rotated freely while the game is paused.
- A and B to zoom, C buttons to move. Z+A or Z+B to adjust FOV.

### Cycle Music Tracks
- Players can change music tracks during a match with d-pad while the game is paused.
    - D-Pad Right cycles through the stage's music tracks.
    - D-Pad Down picks a random music track.
	- Can view current track in Pause Legend.

### Settings Menu Shorcut
- Quickly access Settings from any CSS or SSS screen by holding 'L'.

### Crash Debugger
- When a game crash occurs, attempts to display a screen with detailed information on what went wrong.

### Cinematic Camera
- Controls the cinematic camera zooms which occasionally occur at the start of a versus match.

#### Toggle Name: _Cinematic Camera_

### Idle Timeouts Disabled
- Remaining idle on various menu screen for 5 minutes no longer results in returning to the START screen.

### Quick Start
- All stages and characters unlocked
- Tournament approved match settings set by default. (4 stocks, 8:00 timer)

### Shield Colors Match Player Ports and Teams
- Shield colors will match the color of the port or team the character is on, unless the Shield CSS debug menu setting is set to Vanilla for the port.

### Improved VS Results Screen Scoring for Timeouts
- In timed matches, ties are broken by number of KOs.

### Skip Results Screen
- The results screen is not shown.
- Can be overridden by holding L + R at the end of a match.

#### Toggle Name: _Skip Results Screen_

### Widescreen
- Better widescreen support during matches.

#### Toggle Name: _Widescreen_

### Music Title at Match Start
- See the title of the track and its game of origin at the start of matches.

#### Toggle Name: _Music Title at Match Start_

### Disable Anti-Aliasing
- Turn off anti-aliasing.

#### Toggle Name: _Disable Anti-Aliasing_

### FPS Display *BETA
- Display FPS in the top left of the screen.
- For an overclocked N64, use the OVERCLOCKED option.

#### Toggle Name: _FPS Display *BETA_

### Stereo Fix for Hit SFX
- Fixes a vanilla bug where some SFX is panned in the wrong direction.

#### Toggle Name: _Stereo Fix for Hit SFX_

### Always Show Full Results
- When off, restores vanilla results screen behavior for stock matches.

#### Toggle Name: _Always Show Full Results_

### 'L' selects Random Character
- Allows selecting a random character via L button if 'Press L' is selected.

#### Toggle Name: _'L' selects Random Character_

### Dpad CSS Cursor Control
- Allows Dpad to control cursor (for controllers without a stick).

#### Toggle Name: _Dpad CSS Cursor Control_

### PK Thunder Reflect Crash Fix
- Allows toggling _PK Thunder Reflect Crash fix_

#### Toggle Name: _PK Thunder Reflect Crash Fix_

### Camera Mode
- Override the in-game Camera
- Normal: No change.
- Bonus: Force the camera to follow and track players.
- Fixed: Force the camera to show the entire stage.
- Scene: Camera remains frozen at the last pause position, HUD is disabled, cinematic entry is disabled.

#### Toggle Name: _Camera Mode_

## Accessibility features
### Flash Guard
- Reduces screen flashing effects when turned on.

#### Toggle Name: _Flash Guard_

### Screenshake
- Allows reducing or disabling screen shake visual effect.
- May help with motion sensitivity.

#### Toggle Name: _Screenshake_

## Training Mode
### Custom Menu
- Pressing Z while the menu is open will open the custom training menu. This menu allows you to access special settings for each port.
    - Character: The character used.
    - Costume: The costume used by the character.
    - Type: The type of player. (Human, CPU, Disabled)
    - Spawn: The position the character will spawn in when the reset button is pressed.
    - Set Custom Spawn: Sets the position to be used when the "Custom" spawn option is selected.
    - Percent: The percent to be applied to the character on reset, or when the "Set Percent" button is pressed.
    - Set Percent: Changes the character's percent to the above value.
    - Reset Sets Percent: Toggles whether or not the character's percent will be changed on reset.
    - OOS Action: The action CPU will take out of shield in Shield Break Mode.
    - CPU Teching: Set CPU teching. (Random, Roll Backward, Roll Forward, In Place, None)
    - CPU DI Type: Set CPU DI Type. (None, Random, Smash, Slide)
    - CPU DI Strength: Set CPU DI Strength. (High, Medium, Low, Random)
    - CPU DI Direction: Set CPU DI Direction. (Left, Right, Up, Down, Toward, Away, Random)
    - D-Pad Controls: Toggles the Training D-pad functions. (On, Reset Only, Disabled)

### D-Pad Shortcuts
- Pressing up on the d-pad will pause/unpause the game.
- Pressing right on the d-pad will advance to the next frame.
- Pressing down on the d-pad will cycle through special model display modes.
- Pressing left on the d-pad will reset.

### Reset Counter
- The reset count for the current training session will be recorded and displayed at the top of the screen while the menu is open.

### Shield Break Mode
- Practice shield pressure by turning on Shield Break Mode in the custom menu.

### Music
- Pick which track you want to listen to while in Training Mode via the custom menu.

### Show Action and Frame
- Pressing L toggles display of each character's current action and frame of animation.

### Skip Training Start Cheer
- Disables the cheer sound at the start of Training Mode.

#### Toggle Name: Skip Training Start Cheer

## Japanese Gameplay
### Japanese Hitlag
- Use the Japanese version's hitlag value.

#### Toggle Name: _Japanese Hitlag_

### Japanese DI
- Use the Japanese version's DI value.

#### Toggle Name: _Japanese DI_

### Japanese Sounds
- By default, J characters use Japanese sound effects.
- This toggle enables further controlling the J sound effects to be used for all characters or no characters.

#### Toggle Name: _Japanese Sounds_

### Momentum Slide
- This toggle enables a momentum glitch that exists in the Japanese version.

#### Toggle Name: _Momentum Slide_

### Japanese Shield Stun
- Use the Japanese version's shield stun value.

#### Toggle Name: _Japanese Shield Stun_

## Single Player Modes

### Bonus 3 (Race to the Finish)
- Record best times for completing the RTTF stage using all characters just like for Bonus 1 and Bonus 2.

### Remix BTT/BTP
- Use any character on any BTT/BTP stage and track best times.

### Remix 1p Mode
- A new take on the standard 1p Mode
    - Fight randomly selected Remix characters at one of their three randomly selected stages
    - Increased difficulty with Very Easy mode being the equivalent of standard 1p Mode's Normal Difficulty
    - Challenge Fox and Falco in a doubles battle
    - Characters have Alternate Bonus Stages for Bonuses 1 & 2
    - Fight a Kirby Team with brand new powers
    - Face new boss characters

### All-Star Mode
- Fight all characters in the roster.
- Heal at the rest area between battles by using one of the three hearts.

### Multiman Mode
- Fight a neverending polygon team and track KOs as highscores.

### Cruel Multiman
- Same as Multiman Mode but much more difficult.

### Home-Run Contest
- Deal as much damage to the Sandbag to knock it as far as you can before time runs out.

### 1p Enemy Control Mode
- Activated by another player pressing 'Z' at 1p, Remix 1p, or Allstar CSS.
- Scores are disabled while this is active.
- Master Hand controls can be found [here](https://www.ssbwiki.com/Master_Hand_(SSB)#Moveset).

### Gallery
- View 1P "Congratulations" images and listen to music tracks.
    - Press Start to enter Idle mode (all 1P images and music cycle on a timer)
    - Press Start a second time to enter Idle 2 mode (your Random music and matching 1P images cycle on a timer)
    - Press A to play music, or skip to the next track in Idle modes
    - Press B to exit

## Profiles
- Toggles can be controlled quickly by choosing one of four built-in profiles: Community, Tournament, Netplay and Japanese

### Defaults
#### Remix Settings
Toggle                     | Community          | Tournament        | Netplay           | Japanese
---------------------------|--------------------|-------------------|-------------------|-------------------
Skip Results Screen        | Off                | Off               | On                | Off
Hold To Pause              | Off                | On                | On                | Off
CSS Panel Menu             | On                 | Off               | On                | On
Color Overlays             | Off                | Off               | Off               | Off
Cinematic Camera           | Default            | Default           | Default           | Default
Flash On Z-Cancel          | Off                | Off               | Off               | Off
FPS Display *BETA          | Off                | Off               | Off               | Off
Model Display              | Default            | Default           | High Poly         | Default
Special Model Display      | Off                | Off               | Off               | Off
Advanced Hurtbox Display   | Off                | Off               | Off               | Off
Hold To Exit Training      | Off                | On                | Off               | Off
Improved Combo Meter       | On                 | Off               | On                | On
Tech Chase Combo Meter     | On                 | Off               | On                | On
Combo Meter                | On                 | Off               | On                | On
1v1 Combo Meter Swap       | Off                | Off               | Off               | Off
Neutral Spawns             | On                 | On                | On                | On
Salty Runback              | On                 | Off               | On                | On
Widescreen                 | Off                | Off               | Off               | Off
Japanese Sounds            | Default            | Default           | Default           | Always
Stereo Fix for Hit SFX     | On                 | On                | On                | On
Random Select With Variants| Off                | Off               | Off               | Off
Disable HUD                | Off                | Off               | Off               | Off
Disable Anti-Aliasing      | Off                | Off               | Off               | Off
Always Show Full Results   | On                 | On                | On                | On
Skip Training Start Cheer  | Off                | Off               | Off               | Off
Default CPU LVL (V.S.)     | 3                  | 3                 | 3                 | 3
Jigglypuff Sing GFX Anims  | On                 | Off               | On                | On
L Selects Random Character | Off                | Off               | Off               | OFf
PK Thunder Reflect Crash Fix  | On              | On                | On                | On
Flash Guard                | Off                | Off               | Off               | OFf
Screenshake                | Default            | Default           | Default           | Default

#### Gameplay Settings
Toggle                     | Community          | Tournament        | Netplay           | Japanese
---------------------------|--------------------|-------------------|-------------------|-------------------
Hitstun                    | Normal             | Normal            | Normal            | Normal
Hitlag                     | Normal             | Normal            | Normal            | Japanese
Japanese DI                | Off                | Off               | Off               | On
Japanese Sounds            | Default            | Default           | Default           | Always
Momentum Slide             | Off                | Off               | Off               | On
Japanese Shield Stun       | Off                | Off               | Off               | On
Z-Cancel                   | Default            | Default           | Default           | Default
Punish Failed Z-Cancel     | Off                | Off               | Off               | Off
Improved AI                | On                 | Off               | On                | On
Tripping                   | Off                | Off               | Off               | Off
Footstool Jumping          | Off                | Off               | Off               | Off
Air Dodging                | Off                | Off               | Off               | Off
Jab Locking                | Off                | Off               | Off               | Off
Edge C-Jumping             | Off                | Off               | Off               | Off
Perfect Shielding          | Off                | Off               | Off               | Off
Spot Dodging               | Off                | Off               | Off               | Off
Fast Fall Aerials          | Off                | Off               | Off               | Off
Ledge Trumping             | Off                | Off               | Off               | Off
Wall Teching               | Off                | Off               | Off               | Off
Charged Smash Attacks      | Off                | Off               | Off               | Off
Item Containers            | Default            | Default           | Default           | Default
Blastzone Warp *BETA       | Off                | Off               | Off               | Off

#### Music Settings
Toggle                          | Community          | Tournament        | Netplay           | Japanese
--------------------------------|--------------------|-------------------|-------------------|-------------------
Play Music                      | On                 | On                | On                | On
Random Music                    | Off                | Off               | On                | Off
Salty Runback Preserves Song    | Off                | Off               | Off               | Off
Menu Music                      | DEFAULT            | DEFAULT           | 64                | DEFAULT
Music Title at Match Start      | On                 | Off               | On                | On
_Random Toggles for All Tracks_ | On                 | On                | On                | On

#### Stage Settings
Toggle                          | Community          | Tournament        | Netplay           | Japanese
--------------------------------|--------------------|-------------------|-------------------|-------------------
Stage Select Layout             | NORMAL             | TOURNAMENT        | NORMAL            | NORMAL
Hazard Mode                     | NORMAL             | NORMAL            | NORMAL            | NORMAL
Whispy Mode                     | NORMAL             | NORMAL            | NORMAL            | JAPANESE
Saffron Pokemon Rate            | NORMAL             | NORMAL            | NORMAL            | NORMAL
Pokemon Announcer               | DEFAULT            | OFF               | DEFAULT           | OFF
Dragon King HUD                 | DEFAULT            | OFF               | DEFAULT           | DEFAULT
Yoshi's Island Cloud Anims      | Off                | Off               | Off               | Off
Camera Mode                     | NORMAL             | NORMAL            | NORMAL            | NORMAL
_Random Toggles for All Stages_ | [Community]        | [Tournament]      | [Semi-Competitive]| [Community]

These stages are set to On in the Tournament profile:
- Dream Land
- Deku Tree
- Kalos Pokemon League
- Pokemon Stadium
- Tal Tal Heights (Hazards Off)
- Glacial River
- Dr. Mario
- Fray's Stage
- Spiral Mountain
- Mushroom Kingdom DL (Hazards Off)
- Crateria
- Smashville
- Yoshi's Story
- Gerudo Valley
- Hyrule Castle DL (Hazards Off)
- Peach's Castle DL (Hazards Off)
- Fray's Stage - Night
- Goomba Road
- Sector Z DL (Hazards Off)
- Saffron City DL
- Yoshi's Island DL (Hazards Off)
- Zebes DL (Hazards Off)
- Planet Clancer
- Final Destination DL
- Duel Zone DL
- Meta Crysal DL
- Green Hill Zone
- Pokemon Stadium 2
- Winter Dream Land
- Glacial River Remix

These stages are set to On in the Semi-Competitive profile:
- Congo Jungle
- Dream Land
- Hyrule Castle
- Meta Crystal
- Peach's Castle
- Saffron City
- Mini Yoshi's Island
- First Destination
- Ganon's Tower
- Kalos Pokemon League
- Pokemon Stadium
- Tal Tal Heights
- Glacial River
- WarioWare, Inc.
- Dr. Mario
- Great Bay
- Tower of Heaven
- Fountain of Dreams
- Muda Kingdom
- Mementos
- Sprial Mountain
- Mute City DL
- Mad Monster Mansion
- Bowser's Stadium
- Delfino Plaza
- Kitchen Island
- Crateria
- Smashville
- New Pork City
- Norfair
- Corneria City
- Congo Falls
- Yoshi's Story
- Gerudo Valley
- Fray's Stage Night
- Goomba Road
- Saffron City DL
- Yoshi's Island DL
- Bowser's Keep
- Windy
- dataDyne
- Planet Clancer
- Castle Siege
- Yoshi's Island II
- Cool Cool Mountain SR
- Cool Cool Mountain DL
- Hyrule Castle SR
- Mute City
- Green Hill Zone
- Pirate Land
- Casino Night Zone
- Metallic Madness
- Pokemon Stadium 2
- Norfair Remix
- Glacial River Remix
