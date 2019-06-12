// Spear.asm

// This file adds a new model form falcon's right hand and also grants armor!
// The armor is added with the moveset data instruction A0800004 (armor) will switch armor on, unless specified by the code below.
// The armor is removed with the moveset data instruction A0800000 (close fist). This instruction gets ignored if already in closed fist state.
// originally created by Fray and bastardized by JS!

scope spear_: {
    constant DLIST_SPEAR(0x80412AD8)
	constant DLIST_RHAND(0x80409710)
	constant DLIST_OPEN(0x80406178)
	constant DLIST_DUMMY(0x8040FE98)
    // struct in s1
    // model form in a2
    // display list in t3
    addiu 	sp, sp,-0x000C				// allocate stack space
    sw    	t0, 0x0004(sp)              // ~
    sw    	t1, 0x0008(sp)              
	sw      t2, 0x000C(sp)				// store t0, t1, t2
    lbu		t0,	0x000B(s1)				// t0 = current char id
    ori     t1, r0, 0x0007              // t1 = char id: captain falcon
    bne     t1, t0, _end                // skip if char id != captain falcon
    nop
	addiu 	t2, r0, 0x0004				// t2 = armor flag
	beq 	a2, t2, _armor 				// jump to armor if armor flag is present
	nop
	beqz 	a2, _endarmor 			// jump to endarmor if armor flag is present
	nop
	j		_end
	nop
	
	_endarmor:
	sw 	r0, 0x07E8(s1)				// move value of t0 to f6, which will be saved by the standard code to armor spot
	li  	t3, DLIST_RHAND
	j		_end
	nop
	
	_armor:
	lhu t2, 0x0026(s1)                			// load player struct address into t2
	addiu t1, r0, 0x00CA						// load the value of an forward smash to t1
	beq t1, t2, _trident						// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00CB							// load the value of an forwardsmash to t1
	beq t1, t2, _trident							// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00CC						// load the value of an forward smash to t1
	beq t1, t2, _trident						// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00CD							// load the value of an forward smash to t1
	beq t1, t2, _trident						// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00CE							// load the value of an forward smash to t1
	beq t1, t2, _trident				// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00CF							// load the value of an up smash to t1
	beq t1, t2, _trident				// if current action = forwardsmash, jump to trident
	nop
	addiu t1, r0, 0x00D0				// load the value of a down smash to t1
	beq t1, t2, _trident				// if current action = down smash, jump to add trident
	nop
	lui 	t0, 0x4479					// load the value of 999ish to t0
	sw 		t0, 0x07E8(s1)				// saves 999 armor to armor spot, effectively unbreakable
	li  	t3, DLIST_OPEN             // t3 = DLIST_HAND
	j		_end
	nop
	
	_trident:
	li      t3, DLIST_SPEAR             // t3 = DLIST_SPEAR
    
    _end:
    lw    	t0, 0x0004(sp)              // ~
    lw    	t1, 0x0008(sp)              // load t0 and t1
	lw		t2, 0x000C(sp)
    sw      t3, 0x0050(s0)              // original line 1 (store display list)
    lbu     t4, 0x0010(t0)              // original line 2
    addiu 	sp, sp, 0x000C				// deallocate stack space
    j       spear_return                
    nop
}
