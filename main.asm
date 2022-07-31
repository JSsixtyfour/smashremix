// main.asm

// general setup
arch    n64.cpu
endian  msb
include "assembler/N64.inc"

// copy fresh rom
origin  0x0
insert  "roms/original.z64"

// change ROM name
origin  0x20
db  "SMASH REMIX"
fill 0x34 - origin(), 0x20

// add asm to rom
origin  0x02000000
base    0x80400000
include "src/OS.asm"
include "src/String.asm"
include "src/Render.asm"
include "src/Action.asm"
include "src/File.asm"
include "src/Boot.asm"
include "src/Settings.asm"
include "src/Moveset.asm"
include "src/Command.asm"
include "src/Timeouts.asm"
include "src/GFX.asm"
include "src/AI.asm"
include "src/BGM.asm"
include "src/Camera.asm"
include "src/Color.asm"
include "src/Combo.asm"
include "src/Crash.asm"
include "src/Credits.asm"
include "src/FD.asm"
include "src/FGM.asm"
include "src/GameEnd.asm"
include "src/Global.asm"
include "src/Handicap.asm"
include "src/Hazards.asm"
include "src/Hitbox.asm"
include "src/Item.asm"
include "src/Joypad.asm"
include "src/Menu.asm"
include "src/Pause.asm"
include "src/Practice.asm"
include "src/Spawn.asm"
include "src/Stages.asm"
include "src/Toggles.asm"
include "src/Cheats.asm"
include "src/TimedStock.asm"
include "src/Shield.asm"
include "src/Training.asm"
include "src/VsCombo.asm"
include "src/VsStats.asm"
include "src/Widescreen.asm"
include "src/AA.asm"
include "src/Japan.asm"
include "src/FPS.asm"
include "src/SinglePlayer.asm"
include "src/Skeleton.asm"
include "src/Surface.asm"
include "src/SinglePlayerModes.asm"
include "src/SinglePlayerMenus.asm"
include "src/HRC.asm"
include "src/Bonus.asm"
include "src/TwelveCharBattle.asm"
include "src/Size.asm"
include "src/CharEnvColor.asm"
include "src/SwordTrail.asm"
include "src/GFXRoutine.asm"
include "src/Damage.asm"
include "src/Knockback.asm"
include "src/InputDelay.asm"
include "src/InputDisplay.asm"
include "src/StockMode.asm"
include "src/Stereo.asm"
include "src/Stamina.asm"
include "src/Practice_1P.asm"
include "src/SinglePlayerEnemy.asm"
include "src/PlayerTag.asm"
include "src/Reflect.asm"
// CHARACTER
include "src/Character.asm"
include "src/CharacterSelect.asm"
include "src/CharacterSelectDebugMenu.asm"
include "src/Costumes.asm"
include "src/Fireball.asm"
include "src/ResultsScreen.asm"
include "src/linkshared.asm"
include "src/captainshared.asm"
include "src/dkshared.asm"
include "src/nessshared.asm"
include "src/jigglypuffkirbyshared.asm"
include "src/yoshishared.asm"
include "src/pikashared.asm"
include "src/samusshared.asm"
// FALCO
include "src/Falco/Phantasm.asm"
include "src/Falco/Falco.asm"
// GANONDORF
include "src/Ganondorf/Ganondorf.asm"
// YOUNG LINK
include "src/YoungLink/YoungLink.asm"
// DR MARIO
include "src/DrMario/DrMario.asm"
// WARIO
include "src/Wario/WarioSpecial.asm"
include "src/Wario/Wario.asm"
// DARK SAMUS
include "src/DSamus/DSamus.asm"
// ELINK
include "src/ELink/ELink.asm"
// JSAMUS
include "src/JSamus/JSamus.asm"
// JNESS
include "src/JNess/JNess.asm"
// LUCAS
include "src/Lucas/LucasSpecial.asm"
include "src/Lucas/Lucas.asm"
// JLINK
include "src/JLink/JLink.asm"
// JFALCON
include "src/JFalcon/JFalcon.asm"
// JFOX
include "src/JFox/JFox.asm"
// JMARIO
include "src/JMario/JMario.asm"
// JLUIGI
include "src/JLuigi/JLuigi.asm"
// JDK
include "src/JDK/JDK.asm"
// EPIKA
include "src/EPika/EPika.asm"
// JPUFF
include "src/JPuff/JPuff.asm"
// EPUFF
include "src/EPuff/EPuff.asm"
// JYOSHI
include "src/JYoshi/JYoshi.asm"
// JPIKA
include "src/JPika/JPika.asm"
// ESAMUS
include "src/ESamus/ESamus.asm"
// BOWSER
include "src/Bowser/BowserSpecial.asm"
include "src/Bowser/Bowser.asm"
// GBOWSER
include "src/GBowser/GBowser.asm"
// PIANO
include "src/Piano/PianoSpecial.asm"
include "src/Piano/Piano.asm"
// WOLF
include "src/Wolf/WolfSpecial.asm"
include "src/Wolf/Wolf.asm"
// CONKER
include "src/Conker/ConkerSpecial.asm"
include "src/Conker/Conker.asm"
// MEWTWO
include "src/Mewtwo/MewtwoSpecial.asm"
include "src/Mewtwo/Mewtwo.asm"
// MARTH
include "src/Marth/MarthSpecial.asm"
include "src/Marth/Marth.asm"
// SONIC
include "src/Sonic/SonicSpecial.asm"
include "src/Sonic/Sonic.asm"
// SANDBAG
include "src/Sandbag/Sandbag.asm"
// SUPER SONIC
include "src/SSonic/SSonic.asm"
// SHEIK
include "src/Sheik/SheikSpecial.asm"
include "src/Sheik/Sheik.asm"

// KIRBY
include "src/Kirby/Kirby.asm"
include "src/KirbyHats.asm"
// JKIRBY
include "src/JKirby/JKirby.asm"

// MIDI
include "src/MIDI.asm"

OS.align(16)
midi_memory_block: // This is where music files will be loaded
fill MIDI.largest_midi  // Allocate as much space as we need!

OS.align(16)
file_table:  // This is where we move the file table to in order to load more files
fill 0x480

custom_heap: // This is where we move the heap to when we need to increase its size

// rom size = 48MB
origin 0x2FFFFFF
db 0x00
