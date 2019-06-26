// This code enhances DK's y velocity during his up b. His y velocity gets written to by a command
// at 800D8D7C. I placed my code at 800D8D78

dkjrub_:
// original code
neg.s	f0, f14

//begining of additions
addiu   sp, sp,-0x0014				// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2

//charactercheck
lhu t0, 0x000A(a0)               			// load player struct value of current player character
addiu t1, r0, 0x0002						// load donkeykongvalue into t1
beq t1, t0, dkupbcheckair_ 			// if current player is captain falcon goto next check
nop
j 		noeffect_
nop	

dkupbcheckair_:
lhu t2, 0x0026(a0)                		// load player struct address into t2
addiu t1, r0, 0x00E7					// load the value of aerial up B to t1
beq	 t1, t2, addy_						// if current action = upsmash, jump to upsmash
nop
j		noeffect_
nop

addy_:
lui		t1, 0x4220					// load first half of hex number, higher than standard number of 40B147D0
addiu	t1, t1, 0x0000				// load second half of hex number higher than standard number (actually in floating point)
sw		t1, 0x004C(a0)				// save to y acceleration location
j		enddkjrupb_
nop

noeffect_:
swc1	f6, 0x004C(a0)

enddkjrupb_:
lw      t0, 0x0004(sp)              // ~
lw      t1, 0x0008(sp)              // ~
lw      t2, 0x000C(sp)              // ~ restore value of t0 - t2
addiu   sp, sp, 0x0014				// reallocate stack space


j 		dkjrupbreturn_						// jump to main
nop