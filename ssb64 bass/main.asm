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
lui     a0, 0x00F6          // load rom address (0x01000000)
lui     a1, 0x8040          // load ram address (0x80400000)
jal     0x80002CA0          // dmaCopy
lui     a2, 0x000A          // load length of 4 MB
j       0x8000063C          // original line
nop

// unlock all
origin 0x00042B3A
base 0x800A3DEA
dw 0x007F0C90

// change fair animation to Donkey Kong Punch animation
origin 0x0009D53C
base 0x80121D3C
dw 0x000003A8

// slowattack
origin 0x0006272C
base 0x800E6F2C
j _slowattack
nop
_codereturn:

// armor
origin 0x00062AD8
base 0x800E72D8
j _armorsetup
nop
_armorreturn:

// add asm to rom
origin  0x00F60000
base    0x80400000
include "src/slowattack.asm"
include "src/armor.asm"
insert "src/gnd.bin"

fill    0x1000000 - origin(), 0xFF  