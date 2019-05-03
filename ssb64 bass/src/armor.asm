_armorsetup:

addiu   sp, sp,-0x0014				// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2

addiu	t8, r0, 0xFFFF
sb		t8, 0x0A9D(s1)

lhu t0, 0x000A(s1)               			// load player struct value of current player character
addiu t1, r0, 0x0007						// load falconvalue into t1
beq t1, t0, _punchcheck						// if current player is captain falcon goto next check
nop
j _endarmor										// jump to end because character is not falcon
nop

_punchcheck:
addiu t1, r0, 0x00E4							// load the value of a falcon punch ground to t1
lhu t2, 0x0026(s1)								// load the value of current action into t2
beq t1, t2, _armor								// if current action = falconpunch, jump to armor
nop

addiu t1, r0, 0x00E5							// load the value of an falcon punch air to t1
lhu t2, 0x0026(s1)								// load the value of current action into t2
beq t1, t2, _armor								// if current action = falconpunch, jump to armor
nop

// end of falcon attack checks
j _endarmor							// jump to end because no falcon attacks needs armor
nop

_armor:
lui t0, 0x4461					// load the value of 900 to t0
sw 	t0, 0x07E8(s1)				// move value of t0 to f6, which will be saved by the standard code to armor spot
j _endarmor
nop

_endarmor:
lw      t0, 0x0004(sp)              // ~
lw      t1, 0x0008(sp)              // ~
lw      t2, 0x000C(sp)              // ~ restore value of t0 - t2
addiu   sp, sp, 0x0014				// reallocate stack space
j _armorreturn						// jump to main
nop