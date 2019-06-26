_dkslowattack:
sw	s1, 0x0018(sp)				// original code
sw	s0, 0x0014(sp)				// original code

addiu   sp, sp,-0x0014			// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2
swc1      f1, 0x0010(sp)              // store f1

//dk check
lw t2, 0x0084(a0)                			// load player struct address into t2
lhu t0, 0x000A(t2)               			// load player struct value of current player character
addiu t1, r0, 0x0002							//load dkvalue into t1
beq t1, t0, _dkdownsmashcheck				// if current player is dk goto next check
nop
j _end										// jump to end
nop

// attack check

_dkdownsmashcheck:
addiu t1, r0, 0x00D0						// load the value of a downsmash to t1
beq t1, a1, _dkdownsmash					// if current action = downsmash, jump to downsmash
nop

//end of attack checks
j _end							// jump to end because no falcon attacks need to be slowed
nop

//attackslowdown

_dkdownsmash:
lui a3, 0x3F33
addiu a3, a3, 0x999A			// set to 70%
j _end							// jump to end
nop


//
_end:
lw      t0, 0x0004(sp)              // ~
lw      t1, 0x0008(sp)              // ~
lw      t2, 0x000C(sp)              // ~ restore value of t0 - t2
lwc1      f1, 0x0010(sp)              // ~ restore value of f1
addiu   sp, sp, 0x0014				//reallocate stack space
j _codereturn						// jump to main
nop
