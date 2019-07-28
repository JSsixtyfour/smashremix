_upbsetup:
lwc1 	f4, 0x0054(a1)

addiu   sp, sp,-0x0014				// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2

lhu t0, 0x000A(s0)               			// load player struct value of current player character
addiu t1, r0, 0x0005						// load linkvalue into t1
beq t1, t0, _upbcheck						// if current player is link goto next check
nop
j _endresistance							// jump to end because link doesn't need air resistance
nop

_upbcheck:
addiu t1, r0, 0x00E4							// load the value of a up b air to t1
lhu t2, 0x0026(s0)								// load the value of current action into t2
beq t1, t2, _resistance							// if current action = up b air, jump to resistance
nop

j _endresistance								// jump to end because link doesn't need air resistance
nop

// end of link attack checks

_resistance:
lui t2, 0x3F97
mtc1 t2, f4					// load the FP value of 1.18, which will give greater air resistance to link
lui t2, 0x3F97
mtc1 t2, f10				// load the FP value of 1.18, which will give greater air resistance to link

_endresistance:
add.s f6, f0, f4
lw      t0, 0x0004(sp)              // ~
lw      t1, 0x0008(sp)              // ~
lw      t2, 0x000C(sp)              // ~ restore value of t0 - t2
addiu   sp, sp, 0x0014				// reallocate stack space
j _resistancereturn						// jump to main
nop