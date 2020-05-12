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
include "src/RCP.asm"

// @ Description
// Custom display list goes here.
OS.align(16)
display_list:
fill 0x20000

display_list_info:
RCP.display_list_info(display_list, 0x20000)

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
include "src/FD.asm"
include "src/FGM.asm"
include "src/GameEnd.asm"
include "src/Global.asm"
include "src/Handicap.asm"
include "src/Hazards.asm"
include "src/Hitbox.asm"
include "src/Joypad.asm"
include "src/Menu.asm"
include "src/Overlay.asm"
include "src/Pause.asm"
include "src/Practice.asm"
include "src/Spawn.asm"
include "src/Stages.asm"
include "src/String.asm"
include "src/Texture.asm"
include "src/Toggles.asm"
include "src/Cheats.asm"
include "src/TimedStock.asm"
include "src/Shield.asm"
include "src/Training.asm"
include "src/VsCombo.asm"
include "src/VsStats.asm"
include "src/Widescreen.asm"
include "src/Japan.asm"
include "src/FPS.asm"
include "src/SinglePlayer.asm"
include "src/Skeleton.asm"
include "src/Surface.asm"
// CHARACTER
include "src/Character.asm"
include "src/CharacterSelect.asm"
include "src/Costumes.asm"
include "src/Fireball.asm"
include "src/ResultsScreen.asm"
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

// MIDI
include "src/MIDI.asm"

file_table:  // This is where we move the file table to in order to load more files
fill 0x300

custom_heap: // This is where we move the heap to when we need to increase its size

// rom size = 40MB
origin 0x27FFFFF
db 0x00
