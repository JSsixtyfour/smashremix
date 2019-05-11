_slowattack:
sw	s1, 0x0018(sp)				// original code
sw	s0, 0x0014(sp)				// original code

addiu   sp, sp,-0x0014			// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2
swc1      f1, 0x0010(sp)              // store f1

//falconcheck
lw t2, 0x0084(a0)                			// load player struct address into t2
lhu t0, 0x000A(t2)               			// load player struct value of current player character
addiu t1, r0, 0x0007						// load falconvalue into t1
beq t1, t0, _falconupsmashcheck 			// if current player is captain falcon goto next check
nop
j _end										// jump to end
nop

// falcon attack check

_falconupsmashcheck:
addiu t1, r0, 0x00CF							// load the value of an upsmash to t1
beq t1, a1, _falconupsmash						// if current action = upsmash, jump to upsmash
nop

_falcondashcheck:
addiu t1, r0, 0x00C0							// load the value of an upsmash to t1
beq t1, a1, _falcondash							// if current action = upsmash, jump to upsmash
nop

nop
_falconforwardtiltupcheck:
addiu t1, r0, 0x00C1							// load the value of an upsmash to t1
beq t1, a1, _falconforwardtiltup				// if current action = upsmash, jump to upsmash
nop

_falconforwardtiltmidupcheck:
addiu t1, r0, 0x00C2							// load the value of an upsmash to t1
beq t1, a1, _falconforwardtiltmidup				// if current action = upsmash, jump to upsmash
nop

_falconforwardtiltsidecheck:
addiu t1, r0, 0x00C3							// load the value of an upsmash to t1
beq t1, a1, _falconforwardtiltside				// if current action = upsmash, jump to upsmash
nop

_falconforwardtiltmiddowncheck:
addiu t1, r0, 0x00C4							// load the value of an upsmash to t1
beq t1, a1, _falconforwardtiltmiddown			// if current action = upsmash, jump to upsmash
nop

_falconforwardtiltdowncheck:
addiu t1, r0, 0x00C5							// load the value of an upsmash to t1
beq t1, a1, _falconforwardtiltdown				// if current action = upsmash, jump to upsmash
nop

_falconuptiltcheck:
addiu t1, r0, 0x00C7							// load the value of an upsmash to t1
beq t1, a1, _falconuptilt						// if current action = upsmash, jump to upsmash
nop

_falconforwardsmashupcheck:
addiu t1, r0, 0x00CA							// load the value of an upsmash to t1
beq t1, a1, _falconforwardsmashup				// if current action = upsmash, jump to upsmash
nop

_falconforwardsmashmidupcheck:
addiu t1, r0, 0x00CA							// load the value of an upsmash to t1
beq t1, a1, _falconforwardsmashmidup				// if current action = upsmash, jump to upsmash
nop

_falconforwardsmashsidecheck:
addiu t1, r0, 0x00CC							// load the value of an upsmash to t1
beq t1, a1, _falconforwardsmashside				// if current action = upsmash, jump to upsmash
nop

_falconforwardsmashmiddowncheck:
addiu t1, r0, 0x00CC							// load the value of an upsmash to t1
beq t1, a1, _falconforwardsmashmiddown			// if current action = upsmash, jump to upsmash
nop

_falconforwardsmashdowncheck:
addiu t1, r0, 0x00CE							// load the value of an upsmash to t1
beq t1, a1, _falconforwardsmashdown				// if current action = upsmash, jump to upsmash
nop

_falconnaircheck:
addiu t1, r0, 0x00D1							// load the value of an upsmash to t1
beq t1, a1, _falconnair							// if current action = upsmash, jump to upsmash
nop

_falconfaircheck:
addiu t1, r0, 0x00D2							// load the value of an upsmash to t1
beq t1, a1, _falconfair							// if current action = upsmash, jump to upsmash
nop

_falconuaircheck:
addiu t1, r0, 0x00D4							// load the value of an upsmash to t1
beq t1, a1, _falconuair							// if current action = upsmash, jump to upsmash
nop

_falconkickgroundcheck:
addiu t1, r0, 0x00E6							// load the value of an upsmash to t1
beq t1, a1, _falconkickground					// if current action = upsmash, jump to upsmash
nop

_falconkickgroundaircheck:
addiu t1, r0, 0x00E7							// load the value of an upsmash to t1
beq t1, a1, _falconkickgroundairconnect			// if current action = upsmash, jump to upsmash
nop

//end of falcon attack checks
j _end							// jump to end because no falcon attacks need to be slowed
nop

//attackslowdown

_falconupsmash:
lui a3, 0x3F19
addiu a3, a3, 0x999A			// set to 70%
j _end							// jump to end
nop

_falcondash:
lui a3, 0x3F66
addiu a3, a3, 0x6666				// set to 90%
j _end							// jump to end
nop

_falconforwardtiltup:
lui a3, 0x3F66
addiu a3, a3, 0x6666					// set to 90%
j _end							// jump to end
nop

_falconforwardtiltmidup:
lui a3, 0x3F66
addiu a3, a3, 0x6666					// set to 90%
j _end							// jump to end
nop

_falconforwardtiltside:
lui a3, 0x3F66
addiu a3, a3, 0x6666					// set to 90%
j _end							// jump to end
nop

_falconforwardtiltmiddown:
lui a3, 0x3F66
addiu a3, a3, 0x6666					// set to 90%
j _end							// jump to end
nop

_falconforwardtiltdown:
lui a3, 0x3F66
addiu a3, a3, 0x6666					// set to 90%
j _end							// jump to end
nop

_falconuptilt:
lui a3, 0x3F0C
addiu a3, a3, 0x0000					// set to 55ish%
j _end							// jump to end
nop

_falconforwardsmashup:
lui a3, 0x3F33
addiu a3, a3, 0x3333			// set to 70%
j _end							// jump to end
nop

_falconforwardsmashmidup:
lui a3, 0x3F33
addiu a3, a3, 0x3333			// set to 70%
j _end							// jump to end
nop

_falconforwardsmashside:
lui a3, 0x3F33
addiu a3, a3, 0x3333			// set to 70%
j _end							// jump to end
nop

_falconforwardsmashmiddown:
lui a3, 0x3F33
addiu a3, a3, 0x3333			// set to 70%
j _end							// jump to end
nop

_falconforwardsmashdown:
lui a3, 0x3F33
addiu a3, a3, 0x3333			// set to 70%
j _end							// jump to end
nop

_falconnair:
lui a3, 0x3f67					// set to 90ish%
j _end							// jump to end
nop

_falconfair:
lui a3, 0x3FA7					// set to 130ish%
j _end							// jump to end
nop

_falconuair:
lui a3, 0x3F4C
addiu a3, a3, 0xCCCD			// set to 80%
j _end							// jump to end
nop

_falconkickground:
lui a3, 0x3F59					// set to 85ish%
j _end									// jump to end
nop

_falconkickgroundairconnect:
lui a3, 0x3F59					// set to 85ish%
j _end									// jump to end
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
