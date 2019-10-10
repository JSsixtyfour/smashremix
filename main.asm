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

// DMA hook
origin  0x00001234
base    0x80000634
j       0x80000438
nop

// DMA function
origin  0x00001038
base    0x80000438

jal     0x80002CA0
addiu   a2, r0, 0x0100
lui     a0, 0x0200          // load rom address (0x01000000)
lui     a1, 0x8040          // load ram address (0x80400000)
jal     0x80002CA0          // dmaCopy
lui     a2, 0x000A          // load length of 4 MB
//j       boot_               // run additional boot functions
j       0x8000063C          // original line
nop

constant GAME_MODE(0x03)
constant TIME(0x08)
constant STOCKS(0x03)
constant TEAM_ATTACK(0x01)
constant ITEM_FREQUENCY(0x00)
constant vsgame_mode(0x800A4D0B)
constant vsstocks_(0x800A4D0F)
constant vstimer_(0x800A4D1C)
constant vstime(0x800A4D0E)
constant calculate_time_score_(0x801373F4)
constant calculate_stock_score_(0x801373CC)
constant vsteam_attack(0x800A4D11)
constant vsitem_frequency(0x800A4D24)

// unlock all
origin 0x00042B3A
base 0x800A3DEA
dw 0x007F0C90

// Nintendo 64 logo cannot be skipped (Cyjorg)
// Instead of checking for a button press, the check has been disabled.
origin 0x0017EE18
base 0x80131C58
beq     r0, r0, 0x80131C80

// Nintendo 64 logo exits to title screen because t1 contains screen ID 0x0001
// instead of 0x001C (Cyjorg)
origin 0x0017EE54
base 0x80131C94
ori     t1, r0, 0x0001

origin 0x00040898
base   0x800A1B48
j      Settings.set_vs_settings_
nop
_set_vs_settings_return:

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
include "src/OS.asm"
include "src/Settings.asm"
include "src/Moveset.asm"
include "src/Command.asm"
include "src/Timeouts.asm"
include "src/Resultsscreen.asm"
// partial 19XX merge
include "src/Color.asm"
include "src/Crash.asm"
include "src/FD.asm"
include "src/FGM.asm"
include "src/Global.asm"
include "src/Joypad.asm"
include "src/Overlay.asm"
include "src/RCP.asm"
include "src/Spawn.asm"
include "src/Stages.asm"
include "src/String.asm"
include "src/Texture.asm"
include "src/Costumes.asm"
// CONSTANTS
include "src/Action.asm"
include "src/File.asm"
// CHARACTER
include "src/Character.asm"
include "src/Fireball.asm"
// FALCO
include "src/Falco/Phantasm.asm"
include "src/Falco/Falco.asm"
// GANONDORF
include "src/Ganondorf/Ganondorf.asm"
// YOUNG LINK
include "src/YoungLink/YoungLink.asm"
// DR MARIO
include "src/DrMario/DrMario.asm"

// MIDI
include "src/MIDI.asm"

// rom size = 40MB
origin 0x27FFFFF
db 0x00
