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
insert "src/model/falcoparts.bin"
insert "src/model/gnd.bin"
insert "src/model/spear.bin"
insert "src/model/ylink.bin"
insert "src/model/drmhead.bin"
insert "src/model/drmpillhand.bin"
insert "src/model/ylinkbottlehand.bin"
include "src/Boot.asm"
include "src/OS.asm"
include "src/Settings.asm"
include "src/Moveset.asm"
include "src/Command.asm"
include "src/Timeouts.asm"
include "src/GFX.asm"
// 19XX merge
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
include "src/RCP.asm"
include "src/Spawn.asm"
include "src/Stages.asm"
include "src/String.asm"
include "src/Texture.asm"
include "src/Toggles.asm"
include "src/Cheats.asm"
include "src/TimedStock.asm"
// CONSTANTS
include "src/Action.asm"
include "src/File.asm"
// 19XX merge continued
include "src/Shield.asm"
include "src/Training.asm"
include "src/VsCombo.asm"
include "src/VsStats.asm"
include "src/Widescreen.asm"
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

// MIDI
include "src/MIDI.asm"

include "src/FPS.asm"
include "src/SinglePlayer.asm"
include "src/Skeleton.asm"

// rom size = 40MB
origin 0x27FFFFF
db 0x00
