# Smash Remix
*A Super Smash Bros. 64 Mod Organized by The_Smashfather*

## Building
### THIS IS ONLY FOR THOSE INTERESTED IN THE SOURCE CODE OF THE MOD. PLEASE DOWNLOAD THE RELEASE VERSION BY CLICKING THE RELEASE TAB.
The original xdelta will generate a smash rom that is compatible with our ASM code. Much of our edits are done within
the compressed files within the rom. If you utilize a vanilla Smash 64 rom, it will not work correctly.

You must utilize the xdelta patch to generate a good rom for Assembly.

You must place your legally acquired patched ROM in the rom folder for this to work. It must be named original.z64

# Features
(Note: Smash Remix requires the the 8 MB expansion pak to be enabled.)
## Gameplay
### AI Improvements
Computer controlled players have recieved a variety of improvements.
- They attempt to recover more than once.
- They randomly tech (30% left, 30% right, 30% in place, 10% missed).
- They Z-Cancel (95% success rate).

#### Toggle Name: _Improved AI_

### Combo Meter Improvements
- "Improved Combo Meter" prevents the combo meter from resetting when the character is grabbed or bounces off of a wall.
- Additionally, the "Tech Chase Combo Meter" toggle will prevent the combo meter from resetting on an inescapable tech chase.

#### Toggle Names: _Improved Combo Meter_, _Tech Chase Combo Meter_

### Vs Mode Combo Meter
- Displays a combo meter above players being combo'd in Vs mode.
- Combo meter color corresponds with attacking player's port or team.
- In 1v1 matches, the "1v1 Combo Meter Swap" toggle will display the combo meter above the player performing the combo.

#### Toggle Names: _VS Mode Combo Meter_, _1v1 Combo Meter Swap_

### Expanded Character Select Screen
- The character select screen is now expanded 24 slots including 7 custom characters.
- Metal Mario, Giant DK, and polygon versions of the original cast are available via d-pad up or down.
- Japanese versions of the original cast are available via d-pad left.
- European versions of some of the original cast are available via d-pad right.

### Expanded Stage Select Screen
- The stage select screen is now expanded to multiple pages.
- All original stages are playable as well as dozens of new stages.

### Stage Hazard Modes
- Pressing L on the stage select screen will cycle through options related to stage hazards.
- This is indicated by the stage selection cursor's color changing to blue and the wooden circle having the state of hazards.
- Hazards (bumpers, barrels, etc.) and Movement (of platforms) can be controlled.

#### Toggle Name: _Hazard Mode_

### Stage Select Layout
- Choose between NORMAL and TOURNAMENT stage select layouts. In the TOURNAMENT layout, the best performing and likely tournament legal stages are on the first page.

#### Toggle Name: _Stage Select Layout_

### Hold to Pause
- Prevents accidental pausing by requiring the start button to be held for half of a second before pausing.

#### Toggle Name: _Hold To Pause_

### Neutral Spawns
- Players spawn across from one another regardless of port.

#### Toggle Name: _Neutral Spawns_

### Salty Runback
- Holding Start along with A + B + Z + R will restart the match on the same stage.

#### Toggle Name: _Salty Runback_

### Timed Stock Matches
- Stock matches have a timer. Enabled by default but can be toggled off by setting TIME to "infinity."

### Match Stats
- Results screen has the option to show stats about the match such as damage given to each player.
- If the Vs Mode Combo Meter toggle is on, combo stats are also displayed.

### 12-Character Battle Mode
- New VS mode for easily tracking 12cbs.
- Features 3 preset character sets (Default, Japanese, Remix) and allows for a custom character set per player.
- Best character for each player is tracked as the number of TKOs the opposing player experiences against your character.
- Only ports 1 and 2 work with this mode.

## Customization
### Costume Selection Improvements
- Access all available costumes by scrolling with the left and right C buttons.
- Access all available shades by scrolling with the up and down C buttons.
- Metal Mario and the polygons also have alternate costumes.

### Random Music
- Random music allows players to listen to music from other stages.

#### Toggle Name: _Random Music_

### Random Music Switch
- Changes the possible music tracks to be used when random music is enabled.

#### Toggle Name: Each track's title is listed in the Music Settings menu

### Menu Music
- Choose between the classic SSB64 music or from Melee's and Brawl's menu themes.
- By default, the Melee and Brawl themes will play from time to time.

#### Toggle Name: _Menu Music_

### Alternate Music
- Custom stages have up to two alternate tracks that will play at random.
- The "Occasional" alternate track plays more frequently than the "Rare" alternate track.
- The music track can be forced by holding a C button when choosing the stage: C-up = Default, C-left = Occasional, C-right = Rare

### Random Stage Switch 
- Changes possible outcomes of pressing RANDOM on the stage select screen.

#### Toggle Name: Each stage's name is listed under Random Stage Toggles in the Stage Settings menu

### Random Select With Variants
- By default, the variants (Metal Mario, Giant DK, polygons, J/E regional versions) are not included in the random character select that occurs when toggling the CPU button on the character select screen.
- This toggle allows for them to be included.

#### Toggle Name: _Random Select With Variants_

## Practice
### Special Model Display
Use the toggle or cycle using D-Pad down in Training Mode.
- Hitbox: Displays hitboxes and hurtboxes instead of normal characters/items/projectiles.
- ECB: View character and item collision diamonds.
- Skeleton: Perfect for Halloween.

#### Toggle Name: _Special Model Display_

### Color Overlays
- Fills in the character model with a solid color during certain player states.

#### Toggle Name: _Color Overlays_

### Flash On Z-Cancel
- Displays a sparkle effect when a successful Z-cancel input is detected on landing.

#### Toggle Name: _Flash On Z-Cancel_

## Quality of Life
### 360 Degree Pause Camera
- Allows the camera to be rotated freely while the game is paused.

### Crash Debugger
- When a game crash occurs, attempts to display a screen with detailed information on what went wrong.

### Disable Cinematic Camera
- Disables the cinematic camera zooms which occasionally occur at the start of a versus match.

#### Toggle Name: _Disable Cinematic Camera_

### Idle Timeouts Disabled
- Remaining idle on various menu screen for 5 minutes no longer results in returning to the START screen.

### Quick Start
- All stages and characters unlocked
- Tournament approved match settings set by default. (4 stocks, 8:00 timer)

### Shield Colors Match Player Ports and Teams
- Shield colors will match the color of the port or team the character is on.

### Skip Results Screen
- The results screen is not shown.

#### Toggle Name: _Skip Results Screen_

### Widescreen
- Better widescreen support during matches.

#### Toggle Name: _Widescreen_

### Disable Anti-Aliasing
- Turn off anti-aliasing.

#### Toggle Name: _Disable Anti-Aliasing_

### FPS Display *BETA
- Display FPS in the top left of the screen.
- For an overclocked N64, use the OVERCLOCKED option.

#### Toggle Name: _FPS Display *BETA_

## Training Mode
### Custom Menu
- Pressing Z while the menu is open will open the custom 19XX training menu. This menu allows you to access special settings for each port.
    - Character: The character used.
    - Costume: The costume used by the character.
    - Type: The type of player. (Human, CPU, Disabled)
    - Spawn: The position the character  will spawn in when the reset button is pressed.
    - Set Custom Spawn: Sets the position to be used when the "Custom" spawn option is selected.
    - Percent: The percent to be applied to the character on reset, or when the "Set Percent" button is pressed.
    - Set Percent: Changes the character's percent to the above value.
    - Reset Sets Percent: Toggles whether or not the character's percent will be changed on reset.

### D-Pad Shortcuts
- Pressing up on the d-pad will pause/unpause the game
- Pressing right on the d-pad will advance to the next frame
- Pressing down on the d-pad will cycle through special model display modes
- Pressing left on the d-pad will reset

### Reset Counter
- The reset count for the current training session will be recorded and displayed at the top of the screen while the menu is open.

### Shield Break Mode
- Practice shield pressure by turning on Shield Break Mode in the custom menu.

### Music
- Pick which track you want to listen to while in Training Mode via the custom menu.

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

## Single Player
### Bonus 3 (Race to the Finish)
- Record best times for completing the RTTF stage using all characters just like for Bonus 1 and Bonus 2.

### Multiman Mode
- Fight a neverending polygon team and track KOs as highscores.

### Cruel Multiman
- Same as Multiman Mode but much more difficult.

## Profiles
- Toggles can be controlled quickly by choosing one of three built-in profiles: Community, Tournament and Japanese

### Defaults
#### Remix Settings
Toggle                     | Community          | Tournament        | Japanese
---------------------------|--------------------|-------------------|-------------------
Color Overlays             | Off                | Off               | Off
Disable Cinematic Camera   | Off                | Off               | Off
Flash On Z-Cancel          | Off                | Off               | Off
FPS Display *BETA          | Off                | Off               | Off
Special Model Display      | Off                | Off               | Off
Hold To Pause              | On                 | On                | On
Improved Combo Meter       | On                 | Off               | On
Tech Chase Combo Meter     | On                 | Off               | On
VS Mode Combo Meter        | On                 | Off               | On
1V1 Combo Meter Swap       | Off                | Off               | Off
Improved AI                | On                 | Off               | On
Neutral Spawns             | On                 | On                | On
Skip Results Screen        | Off                | Off               | Off
Stereo Sound               | On                 | On                | On
Salty Runback              | On                 | Off               | On
Widescreen                 | Off                | Off               | Off
Japanese Hitlag            | Off                | Off               | On
Japanese DI                | Off                | Off               | On
Japanese Sounds            | Default            | Default           | Default
Momentum Slide             | Off                | Off               | On
Japanese Shield Stun       | Off                | Off               | On
Random Select With Variants| Off                | Off               | Off
Disable Anti-Aliasing      | Off                | Off               | Off

#### Music Settings
Toggle                          | Community          | Tournament        | Japanese
--------------------------------|--------------------|-------------------|-------------------
Play Music                      | On                 | On                | On 
Menu Music                      | DEFAULT            | DEFAULT           | DEFAULT
Random Music                    | Off                | Off               | Off
_Random Toggles for All Tracks_ | On                 | On                | On

#### Stage Settings
Toggle                          | Community          | Tournament        | Japanese
--------------------------------|--------------------|-------------------|-------------------
Stage Select Layout             | NORMAL             | TOURNAMENT        | NORMAL
Hazard Mode                     | Off                | Off               | Off
_Random Toggles for All Stages_ | On                 | Off*              | On

\* These stages are set to on in the Tournament profile:
- Dream Land
- Mini Yoshi's Island
- Deku Tree
- First Destination
- Kalos Pokemon League
- Pokemon Stadium
- Glacial River
- WarioWare, Inc.
- Dr. Mario
- Battlefield
- Fray's Stage
- Tower of Heaven
- Spiral Mountain
- Mute City
- Mushroom Kingdom DL
- Zebes Landing
- Smashville
- Gerudo Valley
- Hyrule Castle DL
- Congo Jungle DL
- Peach's Castle DL
- Sector Z DL
- Saffron City DL
- Saffron City O
- Yoshi's Island DL
- Planet Zebes DL
