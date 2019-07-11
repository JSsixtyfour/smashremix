_slowattack:
sw	s1, 0x0018(sp)				// original code
sw	s0, 0x0014(sp)				// original code

addiu   sp, sp,-0x0014			// allocate stack space
sw      t0, 0x0004(sp)              // ~
sw      t1, 0x0008(sp)              // ~
sw      t2, 0x000C(sp)              // store t0 - t2
swc1      f1, 0x0010(sp)              // store f1

//charactercheck
lw t2, 0x0084(a0)                			// load player struct address into t2
lhu t0, 0x000A(t2)               			// load player struct value of current player character
addiu t1, r0, 0x0007						// load falconvalue into t1
beq t1, t0, _falconupsmashcheck 			// if current player is captain falcon goto next check
nop
addiu t1, r0, 0x0005
beq t1, t0, _linkdashcheck
nop
addiu t1, r0, 0x0001
beq t1, t0, _foxruncheck
nop

j _end										// jump to end
nop

// falcon attack check

_falconupsmashcheck:
addiu t1, r0, 0x00CF							// load the value of an upsmash to t1
beq t1, a1, _falconupsmash						// if current action = upsmash, jump to upsmash
nop

_falcondashcheck:
addiu t1, r0, 0x00C0							// load the value of a dash to t1
beq t1, a1, _falcondash							// if current action = upsmash, jump to upsmash
nop

_falconforwardtiltupcheck:
addiu t1, r0, 0x00C1							// load the value of a forward tilt to t1
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

_falconruncheck:
addiu t1, r0, 0x0010							// load the value of dash to t1
beq t1, a1, _falconrun							// if current action = falconrun, jump to upsmash
nop

_falconjabcheck:
addiu t1, r0, 0x00BE							// load the value of jab to t1
beq t1, a1, _falconjab							// if current action = jab, jump to jab
nop

_falconpunchcheck:
addiu t1, r0, 0x00E4							// load the value of jab to t1
beq t1, a1, _falconpunch							// if current action = jab, jump to jab
nop

_falconpunchaircheck:
addiu t1, r0, 0x00E5							// load the value of jab to t1
beq t1, a1, _falconpunchair							// if current action = jab, jump to jab
nop

_falconidlecheck:
addiu t1, r0, 0x000A							// load the value of jab to t1
beq t1, a1, _falconidle							// if current action = jab, jump to jab
nop


//end of falcon attack checks
j _end							// jump to end because no falcon attacks need to be slowed
nop

//falconattackslowdown

_falconpunch:
lui a3, 0x3F66
addiu a3, a3, 0x6666			// set to 90%
j _end							// jump to end
nop

_falconpunchair:
lui a3, 0x3F66
addiu a3, a3, 0x6666			// set to 90%
j _end							// jump to end
nop

_falconupsmash:
lui a3, 0x3F80
addiu a3, a3, 0x0000			// set to 100%
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
addiu a3, a3, 0x6666			// set to 90%
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

_falconrun:
lui a3, 0x3f0D					// set to 55ish%
j _end									// jump to end
nop

_falconjab:
lui a3, 0x3F8C
addiu a3, a3, 0xCCCD			// set to 110%
j _end							// jump to end
nop

_falconidle:
lui a3, 0x3f33					// set to 70ish%
j _end									// jump to end
nop

// link attack checks
_linkdashcheck:
addiu t1, r0, 0x00C0					// load the value of an attack to t1
beq t1, a1, _linkdash					// if current action = attack, jump to attack
nop

_linkftiltcheck:
addiu t1, r0, 0x00C3					// load the value of an attack to t1
beq t1, a1, _linkftilt					// if current action = attack, jump to attack
nop

_linkfsmashcheck:
addiu t1, r0, 0x00CC					// load the value of an attack to t1
beq t1, a1, _linkfsmash					// if current action = attack, jump to attack
nop

_linkgrabcheck:
addiu t1, r0, 0x00A6					// load the value of an attack to t1
beq t1, a1, _linkgrab					// if current action = attack, jump to attack
nop

_linkutiltcheck:
addiu t1, r0, 0x00C7					// load the value of an attack to t1
beq t1, a1, _linkutilt					// if current action = attack, jump to attack
nop

_linkdtiltcheck:
addiu t1, r0, 0x00C9					// load the value of an attack to t1
beq t1, a1, _linkdtilt					// if current action = attack, jump to attack
nop

_linkusmashcheck:
addiu t1, r0, 0x00CF					// load the value of an attack to t1
beq t1, a1, _linkusmash					// if current action = attack, jump to attack
nop

_linkdsmashcheck:
addiu t1, r0, 0x00D0					// load the value of an attack to t1
beq t1, a1, _linkdsmash					// if current action = attack, jump to attack
nop

_linkuaircheck:
addiu t1, r0, 0x00D4					// load the value of an attack to t1
beq t1, a1, _linkuair					// if current action = attack, jump to attack
nop

_linkdaircheck:
addiu t1, r0, 0x00D5					// load the value of an attack to t1
beq t1, a1, _linkdair					// if current action = attack, jump to attack
nop

_linkbombcheck:
addiu t1, r0, 0x00E8					// load the value of an attack to t1
beq t1, a1, _linkbomb					// if current action = attack, jump to attack
nop

_linkboomerangcheck:
addiu t1, r0, 0x00E5					// load the value of an attack to t1
beq t1, a1, _linkboomerang				// if current action = attack, jump to attack
nop

//end of link attack checks
j _end							// jump to end because no link attacks need to be slowed
nop

//link speed changes

_linkdash:
lui a3, 0x3F8C
addiu a3, a3, 0xCCCD			// set to 110%
j _end							// jump to end
nop

_linkftilt:
lui a3, 0x3f99
addiu a3, a3, 0x999A			// set to 120%
j _end							// jump to end
nop

_linkutilt:
lui a3, 0x3F86
addiu a3, a3, 0x6666			// set to 105%
j _end							// jump to end
nop

_linkdtilt:
lui a3, 0x3F93
addiu a3, a3, 0x3333			// set to 115%
j _end							// jump to end
nop

_linkusmash:
lui a3, 0x3FA6
addiu a3, a3, 0x6666			// set to 130%
j _end							// jump to end
nop

_linkfsmash:
lui a3, 0x3f99
addiu a3, a3, 0x999A			// set to 120%
j _end							// jump to end
nop

_linkdsmash:
lui a3, 0x3F86
addiu a3, a3, 0x6666			// set to 105%
j _end							// jump to end
nop

_linkuair:
lui a3, 0x3F8C
addiu a3, a3, 0xCCCD			// set to 110%
j _end							// jump to end
nop

_linkdair:
lui a3, 0x3F86
addiu a3, a3, 0x6666			// set to 105%
j _end							// jump to end
nop

_linkboomerang:
lui a3, 0x3F86
addiu a3, a3, 0x6666			// set to 105%
j _end							// jump to end
nop

_linkbomb:
lui a3, 0x3f80					// set to 100%
j _end							// jump to end
nop

_linkgrab:
lui a3, 0x3f99
addiu a3, a3, 0x999A			// set to 120%
j _end							// jump to end
nop

// fox attack checks

_foxruncheck:
addiu t1, r0, 0x0010					// load the value of an attack to t1
beq t1, a1, _foxrun		// if current action = attack, jump to attack
nop

_foxdashcheck:
addiu t1, r0, 0x000F					// load the value of an attack to t1
beq t1, a1, _foxdash		// if current action = attack, jump to attack
nop

j _end							// jump to end because attack checks are over
nop

// fox speed changes

_foxrun:
lui a3, 0x3F40
j _end							// jump to end
nop

_foxdash:
lui a3, 0x3F58
j _end							// jump to end
nop

// ending
_end:
lw      t0, 0x0004(sp)              // ~
lw      t1, 0x0008(sp)              // ~
lw      t2, 0x000C(sp)              // ~ restore value of t0 - t2
lwc1      f1, 0x0010(sp)              // ~ restore value of f1
addiu   sp, sp, 0x0014				//reallocate stack space
j _codereturn						// jump to main
nop
