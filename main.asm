// main.asm

// general setup
arch    n64.cpu
endian  msb
include "assembler/N64.inc"
include "src/os.asm"

// copy fresh rom
origin  0x0
insert  "roms/original.z64"

// change ROM name
origin  0x20
db  "SMASH BROTHERS"
db  0x00

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
lui     a0, 0x0100          // load rom address (0x01000000)
lui     a1, 0x8040          // load ram address (0x80400000)
jal     0x80002CA0          // dmaCopy
lui     a2, 0x000A          // load length of 4 MB
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

// change fair animation to new fair move
origin 0x0009D53C
base 0x80121D3C
dw 0x00000857

// change cfalcon's nair animation to fair animation
origin 0x0009D530
base 0x80121D30
dw 0x00000667

// change falcon forward smash up animation status to normal to prevent animation issues
origin 0x0009D4E4
base 0x80121CE4
dw 0x00000000

// change falcon forward smash mid animation status to normal to prevent animation issues
origin 0x0009D4FC
base 0x80121CFC
dw 0x00000000

// change falcon forward smash down animation status to normal to prevent animation issues
origin 0x0009D514
base 0x80121D14
dw 0x00000000

// change falcon forward smash down to beam sword animation
origin 0x0009D50C
base 0x80121D0C
dw 0x0000064E

// change falcon forward smash mid to beam sword animation
origin 0x0009D4F4
base 0x80121CF4
dw 0x0000064E

// change falcon forward smash up to beam sword animation
origin 0x0009D4DC
base 0x80121CDC
dw 0x0000064E

// change falcon forward smash down to beam sword animation
origin 0x0009D510
base 0x80121D10
dw 0x000013A8

// change falcon forward smash mid to beam sword animation
origin 0x0009D4F8
base 0x80121CF8
dw 0x000013A8

// change the offset the game goes to to load aerial falcon kick(original just goes to a go to command that leads to ground falcon kick)
origin 0x0009D654
base 0x80121E54
dw 0x000000FFC

// change the offset the game goes to to load aerial falcon punch
origin 0x0009D624
base 0x802F9864
dw 0x0000019DC

// remove Captain Falcon animation flag for upsmash
origin 0x0009D520
base 0x80121D20
dw 0x00000000

// change start point of Captain Falcon's upsmash
origin 0x0009D51C
base 0x80121D1C
dw 0x000014F0

// change animation of Captain Falcon's upsmash
origin 0x0009D518
base 0x80121D18
dw 0x00000854

// change animation of Captain Falcon's downsmash
origin 0x0009D524
base 0x80121D24
dw 0x00000855

// change startpoint of Captain Falcon's downsmash
origin 0x0009D528
base 0x80121D28
dw 0x00001588

// link up b turn around
origin 0x000A5E54
base 0x8012A654
dw 0x80160370

// link up b velocity
origin 0x000DEDC8
base 0x80164388
dw 0x3C014240

// link boomerang return damage decrease to 7%
origin 0x000E7814
base 0x8016CDD4
dw 0x24180007

// change Captain Falcon's text name to Ganon, this changes his victory screen name (unclear if has other effects)
origin 0x001589A8
base 0x80139808
dw 0x20322032
origin 0x001589AC
base 0x8013980C
dw 0x4741314E
origin 0x001589B0
base 0x80139810
dw 0x314F314E
origin 0x001589B4
base 0x80139814
dw 0x31200000

// slowattack
origin 0x0006272C
base 0x800E6F2C
j _slowattack
nop
_codereturn:

// resistance
origin 0x0005488C
base 0x800D908C
j _upbsetup
nop
_resistancereturn:

origin 0x000548B8
base 0x800D90B8
j _rightairresistance
nop
_rightresistancereturn:

origin  0x0006453C
base    0x800E8D3C
j spear_
nop
spear_return:

    // phantasm hooks
    // phantasm action subroutine
    origin	0x5D1CC
    base	0x800E19CC
    j		action_sub
    nop
    action_sub_return:
    // phantasm landing fsm
    origin	0xD0E10
    base	0x801563D0
    j		phantasm_land
    nop
    phantasm_land_return:
    // phantasm moveset data
    origin	0x63140
    base	0x800E7940
    j		moveset_data
    nop
    origin	0x6316C
    base	0x800E796C
    moveset_data_return:
    // action frame counter fix
    origin	0x5CA88
    base	0x800E1288
    j		action_frame_count
    nop
    action_frame_count_return:
    
    // change up special distance & delay
    origin  0xD6A03
    db      0x1A                // up special delay
    origin  0xD6FFA
    dh      0x42CC              // up special velocity
    origin  0xD7132
    dh      0x42CC              // up special velocity
    origin  0xD7156
    dh      0x42CC              // up special velocity

    // change phantasm assembly subroutines
    origin	0xA5A7C
    dw		0x800D94C4			// ground ending data
    dw		0x00000000			// ground interruptibility
    origin	0xA5A90
    dw		0x8015C750			// air ending data
    dw		0x00000000			// air interruptibility
    dw		0x800D91EC			// air movement data
    dw		0x80156358			// air collision data

    // change phantasm animation/data pointers
    origin	0x94E10
    dw		0x000002E9			// ground animation
    origin	0x94E1C
    dw		0x000002E9			// air animation
    dw		0x000017B4			// air data (02/06/2019 - no idea why this change is needed just leave it in I guess)
//

origin 0x00040898
base   0x800A1B48
j       set_vs_settings_
nop
_set_vs_settings_return:

// add asm to rom
origin  0x01000000
base    0x80400000
insert "src/gnd.bin"
insert "src/spear.bin"
insert "src/ylink.bin"
insert "src/falcoparts.bin"
include "src/slowattack.asm"
include "src/resist.asm"
include "src/rightresist.asm"
include "src/speararmor.asm"
include "src/phantasm.asm"
include "src/settings.asm"





fill    0x2000000 - origin(), 0xFF  