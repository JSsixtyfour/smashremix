// DededeSpecial.asm

// This file contains subroutines used by Dedede's special moves.

// @ Description
// Subroutines for Up Special
scope DededeUSP {
    constant BEGIN_SPEED(0x3F00)    // float 0.5
    constant MOVE_SPEED_X(0x3F30)   // float 0.6875
    constant MOVE_SPEED_Y(0x4310)   // float 144
    constant GRAVITY(0x4000)        // float 2
    constant GRAVITY_PEAK(0x3e4c)   // float 0.2
    constant GRAVITY_FALLING(0x4020) // float 2.5
    constant MAX_FALLING(0x42c8)    // float 100
    constant B_PRESSED(0x40)                // bitmask for b press

    // @ Description
    // Holds each player's button presses from the previous frame.
    // Used to add a single frame input buffer to shorten.
    button_press_buffer:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4

    // @ Description
    // Subroutine which runs when Dedede initiates an up special.
    scope begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Dedede.Action.USP_BEGIN // a1(action id) = USP_Ground_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        lw      a0, 0x0020(sp)              // load player object
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // load player struct

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~

        sw      r0, 0x0060(a0)              // stop x velocity
        sw      r0, 0x0064(a0)              // stop y velocity
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // Main subroutine for USP_Begin
    scope begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      t8, 0x014C(a2)              // t8 = kinetic state
        li      a1, move_initial_           // a1(transition subroutine) = move_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Physics subroutine for USP_BEGIN.
    scope begin_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0024(sp)              // save player object
        lw      t3, 0x0084(a0)              // load player struct
        lw      t1, 0x0184(t3)              // load moveset variable 3
        beqz    t1, _lateral
        addiu   t2, r0, 0x0002
        beq     t1, t2, _vertical
        nop

        // take mid-air jumps away at this point
        lw      t0, 0x09C8(t3)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(t3)              // jumps used = max jumps

        _continue:
        lb      t0, 0x01C2(t3)              // t0 = stick_x
        mtc1    t0, f14                     // ~
        cvt.s.w f14, f14                    // f14 = stick x
        swc1    f14, 0x0B20(t3)             // store stick position
        lui     t0, MOVE_SPEED_X            // load move speed into t0
        mtc1    t0, f12                     // move move speed to fp register
        mul.s   f10, f14, f12               // multiply move speed by stick_x input
        swc1    f10, 0x0048(t3)             // store updated x velocity
        lui     at, MOVE_SPEED_Y            // load y velocity
        sw      at, 0x004C(t3)              // save updated y velocity

        _vertical:
        jal     apply_vertical_movement_    // apply movement
        lw      a0, 0x0024(sp)              // save player object

        beq     r0, r0, _end
        nop

        _lateral:
        jal     apply_lateral_movement_     // apply movement
        lw      a0, 0x0084(a0)              // a0 = player struct

        _end:
        lw      a0, 0x0024(sp)              // save player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Subroutine which applies movement to Dedede's first phase of up special based on the angle stored at 0x0B20 in the player struct.
    // a0 - player struct
    scope apply_lateral_movement_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lui     at, BEGIN_SPEED                   // ~
        sw      at, 0x0018(sp)              // 0x0018(sp) = SPEED
        lb      t0, 0x01C2(a0)              // t0 = stick_x
        mtc1    t0, f12                     // ~
        cvt.s.w f12, f12                    // f12 = stick x
        swc1    f12, 0x0B20(a0)             // store stick x
        swc1    f12, 0x001C(sp)             // 0x001C(sp) = movement angle
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player struct

        lwc1    f4, 0x0018(sp)              // f4 = SPEED
        mul.s   f4, f4, f12                 // f4 = x velocity (SPEED * stick input)
        swc1    f4, 0x0024(sp)              // 0x0024(sp) = x velocity
        lw      at, 0x0020(sp)              // at = player struct
        swc1    f4, 0x0048(a0)              // store updated x velocity
        sw      r0, 0x004C(a0)              // set y velocity to 0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Subroutine which controls the collision the begin stage of Dedede's Up Special.
    scope begin_collision_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x001c (sp)      // save return address to stack
        lw             a1, 0x0084 (a0)      // load player struct
        sw             a0, 0x0028 (sp)      // save player object to stack

        jal            0x800de87c           // check to see if player has collided with clipping
        sw             a1, 0x0024 (sp)      // save player struct

        beqz           v0, _end             // if no collision, skip to end
        lw             a1, 0x0024 (sp)      // load player struct

        lhu            v0, 0x00d2 (a1)
        andi           t6, v0, 0x0800       // clipping flag we are looking for

        beqz           t6, _branch
        andi           t7, v0, 0x3000

        jal            0x800dee98
        or             a0, a1, r0           // place player struct in a0

        b              _end
        lw             ra, 0x001c (sp)      // load return address

        _branch:
        beqzl          t7, _end             // branch if not a cliff
        lw             ra, 0x001c (sp)      // load return address

        jal            0x80144c24           // cliff catch routine
        lw             a0, 0x0028 (sp)      // load player object

        _end:
        lw             ra, 0x001c (sp)      // load return address
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Dedede's up special movement actions.
    scope move_initial_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store a0, s0, ra
        lw      s0, 0x0084(a0)              // s0 = player struct
        lli     a1, Dedede.Action.USP_MOVE  // a1(action id) = USP_MOVE
        lw      a0, 0x0020(sp)              // a0 = player object
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        addiu   at, r0, 0x0001
        jal     0x800E6F24                  // change action
        sw      at, 0x0010(sp)              // argument 4 = 1
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0024(sp)              // load s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Cancel Subroutine for movement stage of Dedede's Up Special
    scope move_cancel_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        lwc1    f4, 0x004C(a2)              // load y velocity
        mtc1    r0, f6
        c.le.s  f4, f6
        bc1f    _end                        // skip if not at apex or descending
        addiu   t2, r0, 0x40

        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        andi    t1, t1, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        bne     t1, r0, _cancel             // branch if (B_PRESSED)
        lb      t1, 0x01C3(a2)              // t1 = stick_y
        slti    at, t1, -39                 // at = 1 if stick_y < -39, else at = 0
        beq     at, r0, _end                // skip if stick_y >= -39...
        nop

        _cancel:
        addiu   a1, r0, Dedede.Action.USP_CANCEL // load action ID
        addiu   a2, r0, 0x0000
        lui     a3, 0x3f80                  // 1.0 placed in a3
        jal     0x800e6f24                  // change action routine
        sw      r0, 0x0010 (sp)

        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Subroutine which controls the physics of the movement stage of Dedede's Up Special.
    scope move_physics_: {
        // a0 = player object
        addiu          sp, sp, -0x10        // allocate stack
        sw             ra, 0x0008 (sp)      // save return address

        jal            apply_vertical_movement_
        nop

        _end:
        lw             ra, 0x0008 (sp)      // save return address
        jr             ra
        addiu          sp, sp, 0x10
    }

    // @ Description
    // Subroutine which controls vertical movement during Dedede's Up Special.
    scope apply_vertical_movement_: {
        // a0 = player object
        addiu          sp, sp, -0x20        // allocate stack
        sw             ra, 0x001c (sp)      // save return address
        sw             s0, 0x0018 (sp)
        lw             s0, 0x0084 (a0)      // load player struct
        sw             a0, 0x0020 (sp)      // save player object
        lw             t6, 0x0180 (s0)      // load moveset variable 2
        or             a0, s0, r0           // place player struct in a0
        lw             v0, 0x09c8 (s0)      // load attribute pointer
        addiu          t5, r0, 0x0001
        beqzl          t6, _branch_1        // branch if beginning
        lui            at, GRAVITY
        beql           t6, t5, _branch_1    // branch if near apex
        lui            at, GRAVITY_PEAK
        lui            at, GRAVITY_FALLING

        _branch_1:
        mtc1           at, f6
        lwc1           f4, 0x0058 (v0)      // load player gravity
        mul.s          f0, f4, f6           // multiply player gravity by aerial boost multiplier
        nop
        mfc1           a1, f0               // move gravity to a1
        jal            0x800d8d68           // determine vertical lift amount, a1=gravity, a2=max falling speed
        lui            a2, MAX_FALLING      // load max falling speed
        or             a0, s0, r0           // player struct moved to a0
        jal            0x800d8fa8
        lw             a1, 0x09c8 (s0)      // loads attribute pointer
        lw             ra, 0x001c (sp)      // load return address

        _end:
        lw             s0, 0x0018 (sp)
        jr             ra
        addiu          sp, sp, 0x20
    }

    // @ Description
    // Subroutine which controls the collision of the movement stage of Dedede's Up Special.
    scope move_collision_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x001c (sp)      // save return address to stack
        lw             a1, 0x0084 (a0)      // load player struct
        sw             a0, 0x0028 (sp)      // save player object to stack

        jal            0x800de87c           // check to see if player has collided with clipping
        sw             a1, 0x0024 (sp)      // save player struct

        beqz           v0, _end             // if no collision, skip to end
        lw             a1, 0x0024 (sp)      // load player struct

        lhu            v0, 0x00d2 (a1)      // load collision clipping flag
        andi           t6, v0, Surface.GROUND // check if colliding with a floor

        beqz           t6, _cliff_check     // branch not colliding with a wall
        andi           t7, v0, 0x3000       // check if colliding with cliff

		_ground:
        jal            0x800dee98
        or             a0, a1, r0           // place player struct in a0

        lw             a0, 0x0028 (sp)      // load player object
        addiu          a1, r0, Dedede.Action.USP_LAND // load action ID
        addiu          a2, r0, 0x0000
        lui            a3, 0x3f80           // 1.0 placed in a3

        jal            0x800e6f24           // change action routine
        sw             r0, 0x0010 (sp)

        b              _end_2
        lw             ra, 0x001c (sp)      // load return address

        _cliff_check:
        beqzl          t7, _ceiling_check   // branch if not a cliff
        andi           t6, v0, Surface.CEILING // check if colliding with a ceiling
        jal            0x80144c24           // cliff catch routine
        lw             a0, 0x0028 (sp)      // load player object

		_ceiling_check:
        beqzl          t6, _end_2           // branch if not colliding with ceiling
        lw             ra, 0x001c (sp)      // load return address
        lw             a0, 0x0028 (sp)      // load player object
		Action.change(Dedede.Action.USP_CEILING_BONK)	// set to Ceiling Bonk Action
		FGM.play(0x0134)					// Play FGM

        _end:
        lw             ra, 0x001c (sp)      // load return address
		_end_2:
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }


    // @ Description
    // Main Subroutine for landing stage of Dedede's Up Special
    // Based on 0x8015EDE4, Yoshi's Down Special Landing Routine
    scope landing_main_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x0014 (sp)      // save return address
        sw             a0, 0x0028 (sp)      // save player object
        lw             v0, 0x0084 (a0)      // load player struct
        lw             t7, 0x017c (v0)      // load moveset variable 1
        beqz           t7, _branch          // branch if not time to generate star projectiles
        nop

        mtc1           r0, f0               // move 0 to floating point register
        sw             r0, 0x017c (v0)      // save 0 to moveset variable 1
        addiu          a1, sp, 0x0018       // place 0x18 address of stack in a1
        swc1           f0, 0x0018 (sp)      // save 0 to stack struct
        swc1           f0, 0x001c (sp)      // save 0 to stack struct
        swc1           f0, 0x0020 (sp)      // save 0 to stack struct

        jal            0x800edf24           // determine origin point of projectiles
        lw             a0, 0x08e8 (v0)      // load player top joint

        lw             a0, 0x0028 (sp)      // load player object

        jal            0x8016C954           // yoshi star generation routine
        addiu          a1, sp, 0x0018       // put stack struct location in a1

        _branch:
        lui            a1, 0x8014           // ~
        addiu          a1, a1, 0xe1c8       // return to idle routine
        jal            0x800d9480           // if animation ends, routine
        lw             a0, 0x0028 (sp)      // load player object
        lw             ra, 0x0014 (sp)      // load return address
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }

	// Cancels Dedede USP
    scope cancel_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0020(sp)              // store ra
		Action.change(Dedede.Action.USP_CANCEL)
        lw      ra, 0x0020(sp)              // restore ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
	}

    // Main subroutine for USP_Cancel
    scope cancel_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0020(sp)              // store ra
        lwc1    f6, 0x0078(a0)              // load anim state
        mtc1    r0, f4                      // place 0 in fp register
        c.le.s  f6, f4                      // check if animation is over
        lui     at, 0x3F80                  // landing fsm
        bc1f    _end                        // if not over, do not transition
        lui     a1, 0x3F80                  // a1 (drift multiplier?) = 1.0
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE

        jal     0x801438F0                  // transition to Special Fall
        sw      at, 0x0014(sp)              // store landing fsm

        _end:
        lw      ra, 0x0020(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which controls the collision of the cancel stage of Dedede's Up Special.
    scope cancel_collision_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x001c (sp)      // save return address to stack
        lw             a1, 0x0084 (a0)      // load player struct
        sw             a0, 0x0028 (sp)      // save player object to stack

        jal            0x800de87c           // check to see if player has collided with clipping
        sw             a1, 0x0024 (sp)      // save player struct

        beqz           v0, _end             // if no collision, skip to end
        lw             a1, 0x0024 (sp)      // load player struct

        lhu            v0, 0x00d2 (a1)
        andi           t6, v0, 0x0800       // clipping flag we are looking for

        beqz           t6, _branch
        andi           t7, v0, 0x3000

        jal            0x800dee98
        or             a0, a1, r0           // place player struct in a0

        lw             a0, 0x0028 (sp)      // load player object
        lw             a1, 0x0024 (sp)      // load player struct
        sw             r0, 0xB18(a1)        // clear flag used to cancel landing lag
        addiu          a1, r0, Action.LandingSpecial // load action ID
        addiu          a2, r0, 0x0000
        lui            a3, 0x3f80           // 1.0 placed in a3

        jal            0x800e6f24           // change action routine
        sw             r0, 0x0010 (sp)

        b              _end
        lw             ra, 0x001c (sp)      // load return address

        _branch:
        beqzl          t7, _end             // branch if not a cliff
        lw             ra, 0x001c (sp)      // load return address

        jal            0x80144c24           // cliff catch routine
        lw             a0, 0x0028 (sp)      // load player object

        _end:
        lw             ra, 0x001c (sp)      // load return address
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }

	// @ Description
	// Change to special fall on animation end
	scope ceiling_bonk_main_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014 (sp)
		li		a1, cancel_initial_			// routine to run on animation end
		jal		0x800d9480
		nop
		lw		ra, 0x0014 (sp)
		jr		ra
		addiu	sp, sp, 0x18
	}

	// @ Description
	// based on ceiling bonk routine 0x800DE99C
	scope ceiling_bonk_collision_: {
		addiu          sp, sp, -0x20
		sw             ra, 0x0014(sp)
		lw             v1, 0x0084(a0)
		sw             a0, 0x0020(sp)
		jal            0x800de87c
		sw             v1, 0x001c(sp)
		lw             v1, 0x001c(sp)
		beqz           v0, _end
		lw             a0, 0x0020(sp)
		lhu            v0, 0x00d2(v1)
		andi           t6, v0, 0x3000
		beqz           t6, _branch
		andi           t7, v0, 0x0800
		jal            0x80144c24
		nop
		b              _end_2
		lw             ra, 0x0014(sp)

		_branch:
		beqzl          t7, _branch_2
		lhu            t8, 0x00ce(v1)
		jal            0x800de8e4
		nop
		b              _end_2
		lw             ra, 0x0014(sp)
		lhu            t8, 0x00ce(v1)

		_branch_2:
		andi           t9, t8, 0x4000
		beqzl          t9, _end_2
		lw             ra, 0x0014(sp)
		jal            ceiling_subroutine_
		nop
		_end:
		lw             ra, 0x0014(sp)
		_end_2:
		jr             ra
		addiu          sp, sp, 0x20
}

	// @ Description
	// ? Based on 0x801441C0
	scope ceiling_subroutine_: {
		addiu	sp, sp, -0x28
		sw   	ra, 0x001C(sp)
		lw   	t6, 0x0084(a0)
		sw   	a0, 0x0028(sp)
		sw   	r0, 0x0010(sp)
		addiu	a1, r0, Dedede.Action.USP_CEILING_BONK
		addiu	a2, r0, 0x0000
		lui  	a3, 0x3f80
		jal  	0x800e6f24		// change action
		sw   	t6, 0x0024(sp)
		jal  	0x800e0830		// unknown
		lw   	a0, 0x0028(sp)
		lw   	v0, 0x0024(sp)
		mtc1 	r0, f0
		nop
		swc1 	f0, 0x0050(v0)
		swc1 	f0, 0x004C(v0)
		lw   	ra, 0x001C(sp)
		jr   	ra
		addiu	sp, sp, 0x28
	}

}

// @ Description
// ASM and hooks in Kirby's existing routines
scope DededeNSP {

	constant SPIT_DAMAGE(16)				// spitting out players
	constant SPIT_VELOCITY(0x4370)			// initial velocity for spat players
	constant SPIT_DECELERATION(0x4120)		// decelleration applied to spat players (default = 0x4040)

	// @ Description
	// based on 0x8014C260
	spat_deceleration_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)
		jal		0x8014BF04					// seems to be Kirbys main duration routine
		lui		a1, SPIT_DECELERATION
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x18
	}

	// @ Description
	// Suspend a projectile object (does not destroy)
	// a0 = player struct
	// a1 = projectile object
	scope suspend_projectile_: {

		lw		v1, 0x0084(a1)				// v1 = projectile struct
		// save projectile object to last_reflected_object_table
        li      at, last_reflected_object_table
        lbu     t1, 0x000D(a0)
        sll     t1, t1, 2
        addu    t1, t1, at                  // v0 = entry in Reflect.last_reflected_object_table
        sw      a1, 0x0000(t1)              // save last reflected projectile to table

		// special cases here
		lw		t0, 0x000C(v1)				// t1 = projectile ID
		addiu	at, r0, 0x000E				// at = PK thunder head projectile ID
		beql	at, t0, _pk_thunder			// branch if pk thunder
        sw      at, 0x0000(t1)              // save last reflected projectile to table
		addiu	at, r0, 0x000F				// at = PK thunder tail projectile ID
		beql	at, t0, _pk_thunder			// branch if pk thunder
        sw      at, 0x0000(t1)              // save last reflected projectile to table

		// add any other special cases as needed
		b		_continue
		nop

		_pk_thunder:
		move	a0, a1						// a0 = projectile object
		lw      a1, 0x0294(v1)              // a1 = absorb routine
		jr 		a1							// run absorb routine (destroy pk thunder)
		nop
		b		_end						// branch if no reflect routine
		addiu   v0, r0, 1					// return 1 (not suspended)

		_continue:
		lli     at, 0xFFFF                  // t1 = -1
		sb      at, 0x0260(v1)              // stop movement for this projectile
		sw      r0, 0x0150(v1)              // disable hitboxes
		lli     t0, 0x0001                  // t0 = TRUE
		sw      t0, 0x007C(a1)              // disables drawing for this object
		lw      at, 0x0004(a0)				// at = player object
		sw 		at, 0x0008(v1)				// overwrite projectile owner
		lw      at, 0x0290(v1)              // a1 = reflect routine
		//sw		r0, 0x0000(t1)				// save 0 to table
		beqzl	at, _end					// branch if no reflect routine
		addiu   v0, r0, 1					// return 1 (not suspended)
		//sw      a1, 0x0000(t1)              // save last reflected projectile to table
		jr 		at							// run reflect routine
		move 	a0, a1						// a0 = projectile
		addiu	v0, r0, 0 					// return 0 (projectile suspended)
		_end:
		jr 		ra
		nop

	}

	// a0 = player object
	// a1 = coordinates to place it
	// a2 = projectile object
	scope unsuspend_projectile_: {
		lw      v0, 0x0084(a0)				// v0 = player struct
		lw		v1, 0x0084(a2)				// v1 = projectile struct

		lw		at, 0x0008(v1)				// at = player owner
		bnel	a0, at, _end				// if this player does not own the projectile, don't unsuspend it.
		addiu	v0, r0, 1					// v0 = 1 (no projectile to unsuspend)

		// if here, then unsuspend
		// set coordinates
		lw		at, 0x0000(a1)				// at = x position
		sw      at, 0x0034(v1)              // update projectile.x
		lw		at, 0x0004(a1)				// at = y position
		sw      at, 0x0038(v1)              // update projectile.y
		lw		at, 0x0008(a1)				// at = z position
		sw      at, 0x003C(v1)              // update projectile.z

		lli     t1, 0x003F                  // t1 = 0 // ???
		sb      t1, 0x0260(v1)              // start timing for projectile
		lli     t1, 0x0001                  // t1 = 1
		sw      t1, 0x0150(v1)              // enable hitboxes

		// update visibility
		sw      r0, 0x007C(a2)              // re-enable projectile visibility (0 = visible)

		//set the projectiles direction (not used by all projectiles)
		lw      t1, 0x0044(a0)              // t1 = player direction
		lw      t2, 0x0018(v1)              // t2 = projectile direction
		sw      t1, 0x0018(v1)              // projectile direction = player direction
		//projectile velocity
		lwc1    f6, 0x0020(v1)              // f6 = projectile velocity
		abs.s   f6, f6                      // get absolute value
		lwc1    f7, 0x0044(v0)              // f7 = player direction
		cvt.s.w f7, f7                      // convert to float
		mul.s   f8, f6, f7                  // multiply projectile velocity by player direction
		lui     at, 0x4000			     	// at = float 2
		mtc1    at, f6						// move to f6
		mul.s   f8, f8, f6                  // multiply projectile velocity by 2
		nop
		swc1    f8, 0x0020(v1)              // save new projectile velocity
		sw      r0, 0x0024(v1)				// y velocity = 0
		sw      r0, 0x0028(v1)				// z velocity = 0

		//lw      v1, 0x0074(a2)              // v1 = projectile object position struct
		//set image x scale
		//lwc1    f6, 0x0044(v1)              // f6 = image x scale
		//abs.s   f6, f6                      // get absolute value
		//mul.s   f8, f6, f7                  // multiply that by player direction
		//swc1    f8, 0x0044(v1)              // save new velocity
		//sw      t1, 0x0020(v1)              // save player y to projectile

		addiu	v0, r0, 0					// v0 = 0 (projectile unsuspended)
		_end:
		jr 		ra
		nop
	}

	make_pk_thunder_: {
		jal     0x8016B2C4                  // main routine for creating PK thunder
		nop
		jr	ra
		nop
	}

    // @ Description
    // Used by Dedede
	last_reflected_object_table:
	dw 0, 0, 0, 0

    // @ Description
    // Subroutine which occurs after Dedede eats a projectile
    scope absorb_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct

		// check if kirby
	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE	// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beq 	at, t0, _dedede				// branch if dedede
        lw      t6, 0x014C(v0)              // t6 = kinetic state

		_kirby:
		lli     a1, Kirby.Action.DEDEDE_NSP_SPIT_GROUND // a1(action id) = NSP_SPIT_GROUND
		bnezl   t6, _continue
        lli     a1, Kirby.Action.DEDEDE_NSP_SPIT_AIR // ...and a1(action id) = NSP_SPIT_AIR
		b 		_continue
		nop

		_dedede:
        lli     a1, Dedede.Action.NSP_SPIT_GROUND // a1(action id) = NSP_SPIT_GROUND
        bnezl   t6, _continue               	// use aerial action if aerial
        lli     a1, Dedede.Action.NSP_SPIT_AIR // ...and a1(action id) = NSP_SPIT_AIR

        _continue:
        lli     t6, 0x0006                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0006
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
		jal		0x80163018					// kirby routine that sets action in a1
        sw      v0, 0x0024(sp)              // 0x0024(sp) = player struct

        _destroy:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }



    // @ Description
    // Subroutine which runs when Dedede initiates a neutral special.
	// kirbys is 0x80163154
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

		// check if kirby
	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
        lli     a1, Dedede.Action.NSP_BEGIN_GROUND // a1(action id) = NSP_BEGIN_GROUND
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_BEGIN_GROUND

		_change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
		lw		a0, 0x0020(sp)
		jal 	0x80161E08					// forces the action even if B is released
		or 		a1, r0, r0
		jal		0x80161E94
		lw		a0, 0x0020 (sp)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~

        sw      r0, 0x0060(a0)              // stop x velocity
        sw      r0, 0x0064(a0)              // stop y velocity
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Subroutine which runs when Dedede initiates a neutral special
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
		lli     a1, Dedede.Action.NSP_BEGIN_AIR // action id =  DEDEDE.NSP_BEGIN_AIR
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_BEGIN_AIR

		_change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

		lw		a0, 0x0020(sp)
		jal 	0x80161E08					// forces the action even if B is released
		or 		a1, r0, r0
		jal		0x80161E94
		lw		a0, 0x0020 (sp)

        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~

        sw      r0, 0x0060(a0)              // stop x velocity
        sw      r0, 0x0064(a0)              // stop y velocity
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
	// this hook corrects the action id for ending Dedede's NSP
	scope inhale_begin_ground_to_air_: {
		OS.patch_start(0xDD518, 0x80162AD8)
		j		inhale_begin_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_BEGIN_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0116				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_BEGIN_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2

	}

    // @ Description
	// this hook corrects the action id for ending Dedede's NSP
	scope inhale_begin_air_to_ground_: {
		OS.patch_start(0xDD434, 0x801629F4)
		j		inhale_begin_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_BEGIN_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x010D				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_BEGIN_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2

	}

    // @ Description
    // based on 0x80161FF8, Kirby's
    scope ground_begin_main_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014 (sp)
        OS.UPPER(a1, ground_loop_initial_)		// a1 = upper byte of routine pointer
        jal     0x800D9480                     	// subroutine runs asm in a1 if animation is done ?
        addiu   a1, a1, ground_loop_initial_	// a1 = routine pointer
        lw      ra, 0x0014 (sp)
        jr      ra
        addiu   sp, sp, 0x18
    }

    // @ Description
    // based on 0x801621A8, Kirby's
    scope air_begin_main_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        OS.UPPER(a1, air_loop_initial_) // a1 = upper byte of routine pointer
        jal     0x800D9480              // subroutine runs asm in a1 if animation is done ?
        addiu   a1, a1, air_loop_initial_ // a1 = routine pointer
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x18
    }

	scope inhale_loop_ground_to_air_check_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        OS.UPPER(a1, inhale_loop_ground_to_air_initial_)
        jal     0x800DDDDC      // subroutine runs a1 if aerial
        addiu   a1, a1, inhale_loop_ground_to_air_initial_
		// a1 = routine pointer
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x18
	}

	scope inhale_loop_air_to_ground_check_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        OS.UPPER(a1, inhale_loop_air_to_ground_initial_)
        jal     0x800DE6E4     // subroutine runs a1 if grounded
        addiu   a1, a1, inhale_loop_air_to_ground_initial_
		// a1 = routine pointer
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x18
	}

    // @ Description
    // based on 0x801631A0, Kirbys transition to inhale
	// setup up absorb/reflect flags
    scope ground_loop_initial_: {
        addiu   sp, sp, -0x20
        sw      ra, 0x001C(sp)
        addiu   t6, r0, 0x0824
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)

	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
        addiu   a1, r0, Dedede.Action.NSP_LOOP_GROUND   // action id
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_LOOP_GROUND

		_change_action:
        addiu   a2, r0, 0x0000
        jal     0x800E6F24                              // change action
        lui     a3, 0x3f80

        jal     0x80161E94                              //
        lw      a0, 0x0020(sp)                          // a0 = player object

		jal     absorb_setup_                           // absorb setup
        lw      a0, 0x0020(sp)                          // a0 = player object

        jal     0x800e0830                              //
        lw      a0, 0x0020(sp)                          // a0 = player object

        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x20
    }

	// @ Description
	// kirbys = 0x801633EC. transition air begin > air loop
	// setup up absorb/reflect flags
	scope air_loop_initial_: {
        addiu   sp, sp, -0x20
        sw      ra, 0x001C(sp)
        addiu   t6, r0, 0x0824
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)

	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
        addiu   a1, r0, Dedede.Action.NSP_LOOP_AIR      // action id
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_LOOP_AIR

		_change_action:
        addiu   a2, r0, 0x0000
        jal     0x800E6F24                              // change action
        lui     a3, 0x3f80

        jal     0x80161E94                              //
        lw      a0, 0x0020(sp)

		jal     absorb_setup_                           // absorb setup
        lw      a0, 0x0020(sp)                          // a0 = player object

        jal     0x800e0830                              //
        lw      a0, 0x0020(sp)

        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x20
	}

	// @ Description
	// transition air loop > ground loop
	// based on kirbys 0x80162A6C
	scope inhale_loop_air_to_ground_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800dee98
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x4825

	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
        addiu   a1, r0, Dedede.Action.NSP_LOOP_GROUND // action id
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_LOOP_GROUND

		_change_action:
        addiu   a2, r0, 0x0000
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800e6f24            // change action
        lui     a3, 0x3f80
        jal     0x80161e3c
        lw      a0, 0x0024(sp)

        jal     absorb_setup_
        lw      a0, 0x0028(sp)

        lw      ra, 0x001c(sp)
        jr      ra
        addiu   sp, sp, 0x28
	}

    // @ Description
	// transition ground loop > air loop
	// based on kirbys 0x80162B04
	scope inhale_loop_ground_to_air_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800deec8
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x4825

	    lw      v0, 0x0084(a0)              // v0 = player struct
		addiu	at, r0, Character.id.DEDEDE		// at = id.DEDEDE
		lw		t0, 0x0008(v0)				// t0 = character id
		beql	at, t0, _change_action		// branch if dedede
        addiu   a1, r0, Dedede.Action.NSP_LOOP_AIR // action id
		// kirby
		lli     a1, Kirby.Action.DEDEDE_NSP_LOOP_AIR

		_change_action:
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800e6f24        // change action
        lui     a3, 0x3f80
        jal     0x80161e3c
        lw      a0, 0x0024(sp)

        jal     absorb_setup_
		lw      a0, 0x0028(sp)    // a0 = player object

        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x28

	}

    // @ Description
	// transition ground loop > ground end
	scope ground_end_transition_: {
		OS.patch_start(0xDDDB8, 0x80163378)
		j		ground_end_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// v1 = player struct
		lw		a1, 0x0008(v1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop
		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_END_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(v1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x010F				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_END_GROUND

		_change_action:
		j		_return						// back to original routine
		addiu	a2, r0, 0x0000 				// original line 2

	}

    // @ Description
	// transition air loop > air end
	scope air_end_transition_: {
		OS.patch_start(0xDE004, 0x801635C4)
		j		air_end_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// v1 = player struct
		lw		a1, 0x0008(v1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop
		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_END_AIR

		_kirby_hat_check:
		lb		at, 0x0980(v1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0118				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_END_AIR

		_change_action:
		j		_return						// back to original routine
		addiu	a2, r0, 0x0000 				// original line 2

	}

    // @ Description
	// transition air end > ground end
	scope inhale_end_air_to_ground_: {
		OS.patch_start(0xDD4CC, 0x80162A8C)
		j		inhale_end_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop
		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_END_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x010F				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_END_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// transition ground end > air end
	scope inhale_end_ground_to_air_: {
		OS.patch_start(0xDD5B0, 0x80162B70)
		j		inhale_end_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_END_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0118				// original line 2 (kirby normal)
		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_END_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}


	// @ Description
	// transition ground loop > ground pull
	scope ground_pull_transition_: {
		OS.patch_start(0xDDC2C, 0x801631EC)
		j		ground_pull_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s0 = player struct
		lw		a1, 0x0008(s0)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_PULL_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0110				// original line 2 (kirby normal)

		// kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_PULL_GROUND

		_change_action:
		jal		0x801630A0					// original line 1, kirby routine that sets action in a1
		nop
		j		_return
		nop

	}

	// @ Description
	// transition air loop > air pull
	scope air_pull_transition_: {
		OS.patch_start(0xDDE78, 0x80163438)
		j		air_pull_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s0 = player struct
		lw		a1, 0x0008(s0)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_PULL_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0119				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_PULL_AIR

		_change_action:
		jal		0x801630A0					// original line 1, kirby routine that sets action in a1
		nop
		j		_return
		nop

	}

    // @ Description
	// this hook corrects the action id
	scope inhale_pull_ground_to_air_: {
		OS.patch_start(0xDD650, 0x80162C10)
		j		inhale_pull_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_PULL_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0119				// original line 1
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_PULL_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_pull_air_to_ground_: {
		OS.patch_start(0xDD6A0, 0x80162C60)
		j		inhale_pull_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_PULL_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0110				// original line 1
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_PULL_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

	// @ Description
	// this hook corrects the action id when a character is swallowed with Dedede's NSP G
	scope ground_swallow_transition_: {
		OS.patch_start(0xDDC4C, 0x8016320C)
		j		ground_swallow_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s0 = player struct
		lw		a1, 0x0008(s0)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SWALLOW_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0111				// original line 2 (kirby normal)
		//  kirby dedede hat action id
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SWALLOW_GROUND

		_change_action:
		jal		0x80163018					// original line 1, kirby routine that sets action in a1
		nop
		j		_return
		nop

	}

	// @ Description
	// this hook corrects the action id when a character is swallowed with Dedede's NSP A
	scope air_swallow_transition_: {
		OS.patch_start(0xDDE98, 0x80163458)
		j		air_swallow_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s0 = player struct
		lw		a1, 0x0008(s0)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SWALLOW_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011A				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SWALLOW_AIR

		_change_action:
		jal		0x80163018					// original line 1, kirby routine that sets action in a1
		nop
		j		_return
		nop

	}

    // @ Description
	// this hook corrects the action id
	scope inhale_swallow_air_to_ground_: {
		OS.patch_start(0xDD6F0, 0x80162CB0)
		j		inhale_swallow_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SWALLOW_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0111				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SWALLOW_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_swallow_ground_to_air_: {
		OS.patch_start(0xDD600, 0x80162BC0)
		j		inhale_swallow_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SWALLOW_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011A				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SWALLOW_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

	// @ Description
	// hook fixes action id to from swallow to idle with Dedede's NSP
	scope ground_idle_transition_: {
		OS.patch_start(0xDDCCC, 0x8016328C)
		j		ground_idle_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// a2 = player struct
		lw		a1, 0x0008(a2)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_IDLE_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(a2)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0113				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND

		_change_action:
		j		_return						// back to original routine
		addiu	a2, r0, 0x0000 				// original line 2

	}

	// @ Description
	// does nothing?
	scope ground_idle_transition_2_: {
		//OS.patch_start(0, 0)
		j		ground_idle_transition_2_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		//OS.patch_end()

		// ?? = player struct
		//lw		a1, 0x0008()			// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_IDLE_GROUND


		// is this even needed?
		_kirby_hat_check:
		lb		at, 0x0980(s0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0113				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND

		_change_action:
		j		_return						// back to original routine
		addiu	a2, r0, 0x0000 				// original line 2

	}

    // @ Description
	// this hook corrects the action id
	scope inhale_idle_ground_to_air_: {
		OS.patch_start(0xDD7E0, 0x80162DA0)
		j		inhale_idle_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = captured players struct
		lw		a2, 0x0084(a0) 				// a2 = capturing players struct
		lw		a1, 0x0008(a2)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_FALL

		_kirby_hat_check:
		lb		at, 0x0980(a2)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011C				// original line 2, action is kirbys original
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_FALL

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_idle_air_to_ground_: {
		OS.patch_start(0xDD830, 0x80162DF0)
		j		inhale_idle_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_IDLE_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0113				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope air_fall_transition_: {
		OS.patch_start(0xDDF18, 0x801634D8)
		j		air_fall_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// t6 = player struct
		lw		a1, 0x0008(t6)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_FALL

		_kirby_hat_check:
		lb		at, 0x0980(t6)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011C				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_FALL

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// Interrupt routine for NSP Inhaled Idle, transition to Spit, Turn, or Walk
	scope ground_idle_interrupt_: {
        addiu	sp, sp, -0x18           // allocate stack space
        sw   	ra, 0x0014 (sp)         // save return address to stack
        li   	a1, DededeNSP.ground_spit_transition_    // will transition to this routine when spitting

        jal  	check_for_spit_         // kirby inhale routine, checks if should transition to spit
        sw   	a0, 0x0018 (sp)         // save player object to stack

        bnez 	v0, _end
        lw   	a0, 0x0018 (sp)         // load player object from stack

		_turn_check:
        lui    	a1, 0x8016
        jal    	0x801625b0              // if stick points in opposite direction
        addiu  	a1, a1, 0x32c4			// ... change action to inhale_turn
		bnez	v0, _end				// skip to end if dedede should turn
        lw   	a0, 0x0018(sp)          // load player object from stack

		_walk_check:
		// t1 = player object
		jal		ground_walk_transition_check_
        lw   	a0, 0x0018(sp)          // load player object from stack

        lw   	a0, 0x0018 (sp)         // load player object from stack
        _end:
        lw      ra, 0x0014 (sp)         // load return address
        jr      ra                      // return
        addiu   sp, sp, 0x18            // deallocate stack space
	}

	// based on 0x80162534
	scope check_for_spit_: {
		addiu   sp, sp, -0x18
		sw      ra, 0x0014(sp)
		sw      a1, 0x001C(sp)
		lw      v0, 0x0084(a0)
		_check_a_press:
		lhu     t6, 0x01BE(v0)
		lhu     t7, 0x01B4(v0)
		and     t8, t6, t7
		bnez    t8, _continue

		_check_B_press:
		lhu     t6, 0x01BE(v0)
		lhu     t7, 0x01B6(v0)
		and     t8, t6, t7
		beqzl   t8, _end
		or      v0, r0, r0

		_continue:
		lw      a1, 0x0840(v0)
		// beqzl   a1, _end       // branch if no player object grabbed
		// or      v0, r0, r0
		beqz    a1, _execute_spit

		addiu   a2, r0, SPIT_DAMAGE // damage amount?
		jal     0x80161CA0          // apply damage
		sw      a0, 0x0018(sp)
		lw      a0, 0x0018(sp)

		_execute_spit:
		lw      t9, 0x001C(sp)
		jalr    ra, t9         // spit opponent/item
		nop

		b       _end
		addiu   v0, r0, 0x0001
		or      v0, r0, r0
		_end:
		lw      ra, 0x0014 (sp)
		jr      ra
		addiu   sp, sp, 0x18
	}

	// copied subroutine that checks if DK should walk forward during cargo @ 8014D6F8
	scope ground_walk_transition_check_: {
		addiu	sp, sp, -0x18
		sw   	ra, 0x0014(sp)
		jal  	0x8013E614						// common stick direction check?
		sw   	a0, 0x0018(sp)
		beqzl	v0, _end
		or   	v0, r0, r0
		jal  	ground_walk_transition_initial_	// routine is run if Dedede should walk forward (og = jal 0x8014D6D8)
		lw   	a0, 0x0018(sp)
		b    	_end
		addiu	v0, r0, 0x0001
		or   	v0, r0, r0
		_end:
		addiu	sp, sp, 0x18
		jr   	ra
		lw   	ra, 0x0014(sp)

	}

	// based on DK's cargo walk routine 0x8014D6D8
	scope ground_walk_transition_initial_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)
		jal		ground_walk_initial_2_				// og = jal 0x8014D68C
		addiu	a1, r0, 0x0000						// starting frame = 0
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x18
	}

	// animation speed multipliers
	walk_speed_table:
	float32     1.0    // slow walk
	float32     1.0   // middle
	float32     1.0    // fast walk

	// This routine handles walk action, based on DK's @ 8014D68C
	scope ground_walk_initial_2_: {
		addiu	sp, sp, -0x20						// allocate stackspace
		sw   	ra, 0x001C(sp)						// save registers
		sw   	a0, 0x0020(sp)						// save player object
		sw   	a1, 0x0024(sp)						// ~
		lw   	v0, 0x0084(a0)						// v0 = player struct

		jal  	0x8013E340							// v0 = 0xB, 0xC or 0xD based on how far stick is
		lb   	a0, 0x01C2(v0)						// a0 = joystick angle x

		lw   	a0, 0x0020(sp)						// restore a0
		lw		v1, 0x0084(a0)						// v1 = player struct

		addiu   at, r0, Character.id.DEDEDE
		lw		v1, 0x0008(v1)						// v1 = character id
		beql	at, v1, _continue
		addiu	a1, v0, Dedede.Action.NSP_WALK_1 - 0x0B // a1 = NSP walk action id to use (DEDEDE)
		// kirby hat action
		addiu	a1, v0, Kirby.Action.DEDEDE_NSP_WALK_1 - 0x0B // a1 = NSP walk action id to use (KIRBY)

		_continue:
		addiu   v0, v0, 0xFFF5 						// v0 = walk animation speed index
		sll		v0, v0, 2							// v0 = offset in table
		li		at, walk_speed_table				// at = walk speed table
		addu	at, at, v0							// at = entry in walk speed table

		lw      a3, 0x0000(at)						// a3 = new animation speed
		lw		at, 0x0024(at)						// at = current action
		beq		at, a1, _end						// branch to end if action is same
		lw   	a2, 0x0024(sp)						// a2 = starting frame
		jal  	0x800E6F24							// change action
		sw   	r0, 0x0010(sp)						// unknown argument
		jal  	0x800E0830							// ?
		lw   	a0, 0x0020(sp)						// restore a0

		_end:
		lw   	ra, 0x001C(sp)						// restore registers
		jr   	ra
		addiu	sp, sp, 0x20						// deallocate stackspace
	}

	// @ Description
	// based on DK Cargo walk interupt @ 0x8014D590
	scope ground_walk_interrupt_: {
		addiu   sp, sp, -0x30
		sw      ra, 0x001c(sp)
		sw      s0, 0x0018(sp)		// save s0
		sw      s0, 0x0018(sp)		// save s0

		lw      t6, 0x0084(a0)
		or      s0, a0, r0			// s0 = player object
		sw      t6, 0x002C(sp)		// save player struct


		// DK cargo throw check
		// jal     0x8014DFA8							// DK A press
		// or      a0, s0, r0
		// bnezl   v0, _end
		// lw      ra, 0x001C(sp)

		// Dedede spit check while walking
		li   	a1, DededeNSP.ground_spit_transition_   // will transition to this routine when spitting
        jal  	check_for_spit_             			// checks if should transition to spit
		or      s0, a0, r0								// s0 = player object
        bnezl 	v0, _end
		lw      ra, 0x001C(sp)

		// DK plat drop check
		// jal     0x8014DC08							// subroutine allows plat drop-thru
		// or      a0, s0, r0
		// bnezl   v0, _end
		// lw      ra, 0x001C(sp)

		jal     ground_walk_to_idle_transition_check_	// movement stopped, idle, og = jal 8014D4EC
		or      a0, s0, r0
		bnez    v0, _end_0					// skip if not moving
		lw      t7, 0x002C(sp)				// t7 = player struct (I assume)
		lb      v0, 0x01C2(t7)				// get stick x
		bgez    v0, _apply_movement			// branch if positive value
		or      v1, v0, r0					// v1 = stick x
		b       _apply_movement				// convert stick x to positive value
		subu    v1, r0, v0					// v1 = abs(stick.x)

		_apply_movement:
		sll     a0, v1, 24					// a0 = v1 clamped to 255
		jal    	0x8013E340					// v0 = 0xB, 0xC or 0xD based on how far stick is
		sra    	a0, a0, 24					// ~
		lw     	a0, 0x002C(sp)				// restore player struct
		lw     	v1, 0x0008(a0)				// get character id
		addiu	at, r0, Character.id.DEDEDE	// at = dedede character id
		beql	at, v1, _continue
		addiu  	v1, v0, Dedede.Action.NSP_WALK_1 - 0xB 			// v1 = dededes walk
		// if here, kirby wearing a hat
		addiu  	v1, v0, Kirby.Action.DEDEDE_NSP_WALK_1 - 0xB	// v1 = kirbys walk
		_continue:
		lw     	a1, 0x0024(a0)				// a1 = current walk action
		beql   	v1, a1, _end				// branch if already walking at this speed
		lw     	ra, 0x001C(sp)

		or     	a0, s0, r0					// a0 = player object
		jal     ground_walk_initial_2_		// change cargo walk action
		lw		a1, 0x0078(a0)				// starting frame = current

		_end_0:
		lw     ra, 0x001C(sp)
		_end:
		lw     s0, 0x0018(sp)
		jr     ra
		addiu  sp, sp, 0x30

	}

	// based on kirbys @ 0x80162684
	scope air_fall_interrupt_: {
		addiu	sp, sp, -0x18
		sw   	ra, 0x0014(sp)
		sw   	a0, 0x0018(sp)

        li   	a1, DededeNSP.air_spit_transition_    // will transition to this routine when spittin
        jal  	check_for_spit_         // kirby inhale routine, checks if should transition to spit
        sw   	a0, 0x0018 (sp)         // save player object to stack
		bnez 	v0, _end
		lw   	a0, 0x0018(sp)

		_end:
		lw   	ra, 0x0014(sp)
		jr   	ra
		addiu	sp, sp, 0x18

	}

	// based on 8014D4EC
	scope ground_walk_to_idle_transition_check_: {
		addiu	sp, sp, -0x18
		sw   	ra, 0x0014(sp)
		jal  	0x8013e258
		sw   	a0, 0x0018(sp)
		beqzl	v0, _end
		or   	v0, r0, r0

		jal  	ground_walk_to_idle_initial_	// original = jal 0x8014d49C
		lw   	a0, 0x0018(sp)

		b    	_end
		addiu	v0, r0, 0x0001
		or   	v0, r0, r0

		_end:
		lw   	ra, 0x0014(sp)
		jr   	ra
		addiu	sp, sp, 0x18
	}

	// based on 8014D49C
	scope ground_walk_to_idle_initial_: {
		addiu	sp, sp, -0x20
		sw   	ra, 0x001c(sp)
		sw   	a0, 0x0020(sp)
		lw   	a1, 0x0084(a0)
		addiu	at, r0, 0x0001
		lw   	t7, 0x014c(a1)
		bnel 	t7, at, kirby_action_check
		lw   	a0, 0x0020(sp)
		jal  	0x800DEE98			// ?
		or   	a0, a1, r0
		lw   	a0, 0x0020(sp)

		kirby_action_check:
		lw   	a0, 0x0020(sp)
		lw   	a1, 0x0084(a0)		// a1 = player struct
		lli     at, Character.id.DEDEDE
		lw 		v0, 0x0008(a1)		// v0 = characters id
		beql	at, v0, _change_action
		addiu	a1, r0, Dedede.Action.NSP_IDLE_GROUND	// a1 = action id (nsp inhaled idle)
		// kirby action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND	// a1 = action id (nsp inhaled idle)

		_change_action:
		addiu	a2, r0, 0x0000
		lui  	a3, 0x3f80
		jal  	0x800E6f24			// change action routine
		sw   	r0, 0x0010(sp)
		lw   	ra, 0x001C(sp)
		jr   	ra
		addiu	sp, sp, 0x20
	}

	// based on 0x8014D478
	scope ground_walk_collision_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014 (sp)
        OS.UPPER(a1, ground_walk_fall_initial_)		// a1 = upper byte of routine pointer
		jal		0x800DDDDC							// check if aerial
        addiu   a1, a1, ground_walk_fall_initial_	// a1 = routine pointer (original = 8014DA98)
		lw		ra, 0x0014 (sp)
		jr		ra
		addiu	sp, sp, 0x18
	}

	// based on 8014DA98
	scope ground_walk_fall_initial_: {
		addiu          sp, sp, -0x28
		sw             ra, 0x001C(sp)
		sw             a0, 0x0028(sp)
		lw             t7, 0x0084(a0)
		sw             t7, 0x0024(sp)
		lw             t8, 0x014C(t7)
		bnezl          t8, kirby_action_check
		mtc1           r0, f0
		jal            0x800DEEC8
		or             a0, t7, r0
		mtc1           r0, f0

		kirby_action_check:
		lw   	a0, 0x0028(sp)
		lw   	a1, 0x0084(a0)		// a1 = player struct
		addiu   at, Character.id.DEDEDE
		lw 		v0, 0x0008(a1)		// v0 = characters id
		beql	at, v0, _change_action
		addiu   a1, r0, Dedede.Action.NSP_FALL	// action to change to
		// kirby action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_FALL // a1 = action id (nsp inhaled idle)

		_change_action:
		addiu          t9, r0, 0x0008
		sw             t9, 0x0010(sp)
		mfc1           a2, f0
		mfc1           a3, f0

		jal            0x800E6F24						// change action
		lw             a0, 0x0028(sp)

		jal            0x800D8EB8						// ?
		lw             a0, 0x0024(sp)
		lw             ra, 0x001C(sp)
		jr             ra
		addiu          sp, sp, 0x28
	}

	// @ Description
	// This transitions to spit action
	scope ground_spit_transition_: {
		addiu 	sp, sp, -0x28  			// allocate stack space
        sw    	ra, 0x001c (sp)			// save return address to stack
        lw    	t6, 0x0084 (a0)			// load player struct
        //sw             r0, 0x0010 (sp)       // unknown argument
        sw      a0, 0x0028(sp)          // save player object to stack

		// character id check
		lw		t7, 0x0008(t6)			// get character id
		lli		at, Character.id.DEDEDE
		beql	at, t7, _change_action
        addiu   a1, r0, Dedede.Action.NSP_SPIT_GROUND    // action to transition to
		// kirby
        addiu   a1, r0, Kirby.Action.DEDEDE_NSP_SPIT_GROUND

		_change_action:
        addiu   t7, r0, 0x00a4        	// unknown argument
        sw      t7, 0x0010 (sp)
        addiu   a2, r0, r0              // argument 2
        lui     a3, 0x3f80              // animation speed modifier
        jal     0x800E6f24              // change action routine
        sw      t6, 0x0024(sp)          // save player struct to stack
        lw      a0, 0x0024(sp)          // load player struct from stack

        jal     0x800e8098              // unknown uncommon routine
        addiu   a1, r0, 0x003f

        jal     0x800e0830              // common transition routine
        lw      a0, 0x0028 (sp)         // load player object from stack

        lw      ra, 0x001c (sp)         // load return address
        jr      ra                      // return
        addiu   sp, sp, 0x28            // deallocate stack space
	}

	// @ Description
	// This transitions to spit action
	scope air_spit_transition_: {
		addiu 	sp, sp, -0x28            // allocate stack space
        sw    	ra, 0x001c (sp)          // save return address to stack
        lw    	t6, 0x0084 (a0)          // load player struct
        //sw  	  r0, 0x0010 (sp)        // unknown argument
        sw    	a0, 0x0028 (sp)          // save player object to stack

		// character id check
		lw		t7, 0x0008(t6)			// get character id
		lli		at, Character.id.DEDEDE
		beql	at, t7, _change_action
        addiu   a1, r0, Dedede.Action.NSP_SPIT_AIR // action to transition to
		// kirby
        addiu   a1, r0, Kirby.Action.DEDEDE_NSP_SPIT_AIR

		_change_action:
        addiu 	a2, r0, r0               // argument 2
        addiu 	t7, r0, 0x00a4           // unknown argument
        sw    	t7, 0x0010 (sp)
        lui   	a3, 0x3f80               // animation speed modifier
        jal   	0x800E6f24               // change action routine
        sw    	t6, 0x0024(sp)           // save player struct to stack

        lw    	a0, 0x0024(sp)           // load player struct from stack

        jal   	0x800e8098               // unknown uncommon routine
        addiu 	a1, r0, 0x003f

        jal   	0x800e0830               // common transition routine
        lw    	a0, 0x0028 (sp)          // load player object from stack

        lw    	ra, 0x001c (sp)          // load return address
        jr    	ra                       // return
        addiu 	sp, sp, 0x28             // deallocate stack space
	}

	//80162374
	scope ground_spit_main_: {
		addiu 	sp, sp, -0x18
		sw 		ra, 0x0014(sp)
		jal		spit_shoot_check_
		sw 		a0, 0x0018 (sp)
		jal		0x800d94E8
		lw 		a0, 0x0018(sp)
		lw 		ra, 0x0014(sp)
		jr 		ra
		addiu 	sp, sp, 0x18
	}

	//8016239C
	scope air_spit_main_: {
		addiu 	sp, sp, -0x18
		sw 		ra, 0x0014(sp)
		jal		spit_shoot_check_
		sw 		a0, 0x0018 (sp)
		jal		0x800D94E8
		lw 		a0, 0x0018(sp)
		lw 		ra, 0x0014(sp)
		jr 		ra
		addiu 	sp, sp, 0x18
	}

	// @ Description
	// Checks if there is something to shoot while in spitting animation. based on 80162258
	scope spit_shoot_check_: {
		addiu  	sp, sp, -0x48
		sw     	ra, 0x0014(sp)
		sw      a0, 0x0018(sp)
		lw     	v0, 0x0084(a0)
		or     	a1, a0, r0
		lw     	t6, 0x0184(v0)     // check temp variable to see if time to shoot
		beqzl  	t6, _end
		lw     	ra, 0x0014(sp)

		sw      r0, 0x0184(v0)     // reset temp variable if here
		lw     	a0, 0x0840(v0)
		bnez  	a0, _shoot_player  // shoots a player out
		lw     	ra, 0x0014(sp)

		_shoot_other:
		// initial, get coords
		lw     	a0, 0x0018(sp)
		lw      a3, 0x0018(sp)
        sw      r0, 0x0020(sp)     // x origin point
        sw      r0, 0x0024(sp)     // y origin point
        sw      r0, 0x0028(sp)     // z origin point
        lw      a0, 0x0928(v0)     // a0 = players joint
        sw      a3, 0x0030(sp)
        sw      v0, 0x002C(sp)
        jal     0x800EDF24         // generic function used to determine projectile origin point
        addiu   a1, sp, 0x0020
		lw      a0, 0x0018(sp)
		lw     	v0, 0x0084(a0)

		// creating a star only
		b 	_create_star
		nop

		// shoot projectile
        li      at, last_reflected_object_table
        lbu     t1, 0x000D(v0)
        sll     t1, t1, 2
        addu    t1, t1, at                  // t1 = entry in Reflect.last_reflected_object_table
		lw		at, 0x0000(t1)				// at = last projectile
		beqz	at, _create_star			// create a star object instead
		sw		r0, 0x0000(t1)				// clear this object from table

		addiu	t1, r0, 0x000F				// t1 = Ness's PK thunder
		beq		at, t1, _pk_thunder
		addiu 	t1, r0, 0x000E
		beq		at, t1, _pk_thunder
		nop

		// if here, then unsuspend this projectile "normally"
		move    a2, at						// a2 = projectile
		jal		unsuspend_projectile_
		nop
		beqz	v0, _end
		lw     	ra, 0x0014(sp)
		b		_unsusp_end
		nop

		_pk_thunder:
		// PK thunder is removed from play
		b 	_create_star
		nop
		// TODO:
		//jal		make_pk_thunder_
		//nop
		//b		_end
		//lw     	ra, 0x0014(sp)

		_unsusp_end:
		beqz	v0, _end
		lw     	ra, 0x0014(sp)
		// if here, v0 = 1. So shoot out a star projectile
		lw      a0, 0x0018(sp)

		_create_star:
        lw      v0, 0x002C(sp)
        lw      a3, 0x0030(sp)
        sw      r0, 0x001C(sp)
        or      a0, a3, r0
        addiu   a1, sp, 0x0020
        jal     0x80178474         // shoots a star rod star for now
        addiu   a1, sp, 0x0020
		lw     	a2, 0x0018(sp)
	    b       _end
		lw     	ra, 0x0014(sp)

		_shoot_player:
		lw     	a2, 0x0084(a0)		// a2 = held player
		sw     	a1, 0x0020(sp)
		jal    	0x8014C508         // kirby routine shoots held player
		sw     	a2, 0x0018(sp)
		lw     	a2, 0x0018(sp)		// a2 = shot player struct

		// we can change the timer to mash out here. probably not needed
		// lw		t0, 0x002C(a2)		// get player percent
		// addiu	t0, t0, 3			// timer = player% + 3
		// sw		t0, 0x026C(a2)		// overwrite captured timer

		lw     	a1, 0x0020(sp)
		jal    	0x800E80C4			// turns the player into a projectile?
		lw     	a0, 0x0018(sp)
		lw     	a2, 0x0018(sp)		//
		li		at, spat_deceleration_
		sw		at, 0x09E0(a2)		// save new routine to spat players struct
		lui    	at, SPIT_VELOCITY	//
		mtc1   	at, f8
		lw     	t7, 0x0044(a2)
		mtc1   	r0, f0
		subu   	t8, r0, t7
		mtc1   	t8, f4
		swc1   	f0, 0x0050(a2)
		swc1   	f0, 0x004C(a2)
		cvt.s.w	f6, f4
		mul.s  	f10, f6, f8
		swc1   	f10, 0x0048(a2)
		lw     	ra, 0x0014(sp)
		_end:
		jr     	ra
		addiu  	sp, sp, 0x48
	}

	// @ Description
	// this hook corrects the action id
	scope inhale_spit_ground_to_air_: {
		OS.patch_start(0xDD740, 0x80162D00)
		j		inhale_spit_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SPIT_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011B				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SPIT_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_turn_to_fall_air_: {
		OS.patch_start(0xDDA34, 0x80162FF4)
		j		inhale_turn_to_fall_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// a2 = player struct
		lw		a1, 0x0008(a2)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_FALL

		_kirby_hat_check:
		lb		at, 0x0980(a2)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011C				// original line 1
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_FALL

		_change_action:
		j		_return						// back to original routine
		addiu	a2, r0, 0x0000 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_spit_air_to_ground_: {
		OS.patch_start(0xDD790, 0x80162D50)
		j		inhale_spit_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check	// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_SPIT_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0112				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_SPIT_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

	// @ Description
	// this hook corrects the action id when turning with Dedede's NSP
	scope ground_idle_to_turn_transition_: {
		OS.patch_start(0xDDD1C, 0x801632DC)
		j		ground_idle_to_turn_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// t6 = player struct
		lw		a1, 0x0008(t6)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_TURN_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(t6)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0114				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_TURN_GROUND

		_change_action:
		j		_return
		addiu	a2, r0, 0x0000 				// original line 2
	}

	// @ Description
	// this hook corrects the action id when turning with Dedede's NSP
	scope ground_turn_to_idle_transition_: {
		OS.patch_start(0xDD9FC, 0x80162FBC)
		j		ground_turn_to_idle_transition_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// v0 = player struct
		lw		a1, 0x0008(v0)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_IDLE_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(v0)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0113				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND

		_change_action:
		j		_return
		addiu	a2, r0, 0x0000 				// original line 2
	}

	   // @ Description
	// this hook corrects the action id
	scope inhale_turn_ground_to_air_: {
		OS.patch_start(0xDD880, 0x80162E40)
		j		inhale_turn_ground_to_air_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_TURN_AIR

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x011D				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_TURN_AIR

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

    // @ Description
	// this hook corrects the action id
	scope inhale_turn_air_to_ground_: {
		OS.patch_start(0xDD8D0, 0x80162E90)
		j		inhale_turn_air_to_ground_
		addiu	at, r0, Character.id.DEDEDE // at = DEDEDE character id
		_return:
		OS.patch_end()

		// s1 = player struct
		lw		a1, 0x0008(s1)				// a1 = characters id
		bne		at, a1, _kirby_hat_check				// branch if not Dedede
		nop

		b		_change_action
		addiu	a1, r0, Dedede.Action.NSP_TURN_GROUND

		_kirby_hat_check:
		lb		at, 0x0980(s1)				// at = current hat ID
		sltiu	at, at, 0x0020				// v0 = dededes hat id
		bnez	at, _change_action
		addiu	a1, r0, 0x0114				// original line 2
		// set dedede hat action
		addiu	a1, r0, Kirby.Action.DEDEDE_NSP_TURN_GROUND

		_change_action:
		j		_return						// back to original routine
		lw		a2, 0x0078(a0) 				// original line 2
	}

	// other possible hooks
	// 0x801633B0 (action 0x116)
	// inhale copy hook locations
	// 80162EE0 (0x11E)
	// 80162F30 (0x115)

    // @ Description
    //

    // @ Description
    // Subroutine which sets up the absorb range for Dedede
    scope absorb_setup_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        lw      v1, 0x0084(a0)              // v1 = player struct
        lbu     t3, 0x018C(v1)              // ~
        ori     t4, t3, 0x0004              // ~
        sb      t4, 0x018C(v1)              // enable reflect bitflag
        li      t7, absorb_struct           // t7 = absorb_struct
        sw      t7, 0x0850(v1)              // store absorb_struct pointer
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    absorb_struct:
    dh 0x0002                               // index to custom reflect routine table
    dh Reflect.reflect_type.CUSTOM          // reflect type
    dw 0x00000000                           // not sure
    float32 0                               // 0x08 local offset x
    dw 0x43900000                           // 0x0C local offset y
    float32 250                             // 0x10 local offset z
    dw 0x44000000                           // 0x14 size x
    dw 0x43900000                           // 0x18 size y
    dw 0x437A0000                           // 0x1C size z
    dw 0x18000000                           // 0x?? hp value maybe
	OS.align(16)

}

// @ Description
// Subroutines for Down Special.
scope DededeDSP {
    constant FIRST_PULL(6)
    constant FIRST_STOW(32)
    constant SECOND_PULL(61)
    constant SECOND_STOW(87)
    constant FINAL_PULL(116)
    constant CHARGE_END(0x41A0)
	constant MINION_RUMMAGE_TIME(12)      	// time until Dedede can toss out a minion

    // @ Description
    // Subroutine which runs when Dedede initiates a grounded down special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lli     a1, Dedede.Action.DSPG_BEGIN // a1(action id) = DSP_Ground_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Dedede initiates an aerial down special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lli     a1, Dedede.Action.DSPA_BEGIN // a1(action id) = DSP_Air_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine for when Dedede initiates a down special.
    // Based on subroutine 0x8015DB64, which is the initial subroutine for Samus' grounded neutral special.
    // a0 - player object
    // a1 - action id
    scope begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0028(sp)              // a0 = player object

        _dedede:
        jal     dedede_on_hit_subroutine_establishment_ // on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct

        _continue:
        lw      t7, 0x0AE4(s0)              // t7 = charge level
        lli     at, 0x0002                  // at = 0x0002
        lli     t8, 0x0001                  // t8 = 0x0001
        bnel    t7, at, _end                // end if charge level != 2(max)
        sw      r0, 0x0B18(s0)              // set transition bool to 0 (charge)

        // if we're here, the neutral special is fully charged, so set transition bool to shoot
        sw      t8, 0x0B18(s0)              // set transition bool to 1 (shoot)

        _end:
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSP_Ground_Begin and DSP_Air_Begin.
    // Based on subroutine 0x8015D3EC, which is the main subroutine for Samus's NSPG_Begin and NSPA_Begin actions.
    scope begin_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0030(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        // checks the current animation frame to see if we've reached end of the animation
        lwc1    f6, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f6, f4                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0014(sp)              // load ra
        lw      t6, 0x014C(v0)              // t6 = kinetic state (0 = grounded, 1 = aerial)
        beq     t6, r0, _grounded           // branch if kinetic state = grounded
        lw      t7, 0x0B18(v0)              // t7 = transition bool (0 = charge, 1 = shoot)

        _aerial:
        bnez    t7, _air_shoot              // branch if transition bool = shoot
        nop

        _air_charge:
        jal     air_charge_initial_         // air_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _air_shoot:
        jal     air_shoot_initial_          // air_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra


        _grounded:
        bnez    t7, _ground_shoot           // branch if transition bool = shoot
        nop

        _ground_charge:
        jal     ground_charge_initial_      // ground_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _ground_shoot:
        jal     ground_shoot_initial_       // ground_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Begin.
    scope ground_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_begin_transition_   // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Air_Begin.
    scope air_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_begin_transition_ // a1(transition subroutine) = ground_begin_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_Begin.
    scope air_begin_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct

        jal     0x800D8EB8                  // momentum capture?
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lli     a1, Dedede.Action.DSPA_BEGIN // a1(action id) = DSP_Air_Begin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~

        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        _dedede:
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Establishment of on hit routine for DSP, based on 0x8015DB4C
    scope dedede_on_hit_subroutine_establishment_: {
       li       t6, dedede_on_hit_subroutine_
       sw       t6, 0x09EC(a0)
       sw       r0, 0x0B20(a0)

       jr       ra
       sw       r0, 0x017C(a0)
    }

    // @ Description
    // On hit routine for DSP.
    scope dedede_on_hit_subroutine_: {
       addiu    sp, sp,-0x0018              // allocate stack space
       sw       ra, 0x0014(sp)              // store ra
       lw       a0, 0x0084(a0)              // a0 = player struct
       jal      destroy_attached_minion_    // destroy attached minion
       sw       r0, 0x0AE4(a0)              // reset charge level
       lw       ra, 0x0014(sp)              // load ra
       addiu    sp, sp, 0x0018              // deallocate stack space
       jr       ra                          // return
       nop
    }

    // @ Description
    // Destroys Dedede's attached item object.
    // @ Arguments
    // a0 - player struct
    scope destroy_attached_minion_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0B20(a0)              // a1 = attached item object
        beqz    a1, _end                    // skip if no attached item object
        sw      r0, 0x0B20(a0)              // reset attached item object

        or      a0, a1, r0                  // a0 = attached item object
        lw      a1, 0x0084(a0)              // a1 = item special struct
        lli     at, 0x001C                  // at = fake item id
        jal     0x801728D4                  // destroy item
        sw      at, 0x000C(a1)              // override item id to prevent smoke gfx

        _end:
        lw       ra, 0x0014(sp)             // load ra
        addiu    sp, sp, 0x0018             // deallocate stack space
        jr       ra                         // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Begin.
    scope ground_begin_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        jal     0x800DEE98                  // set grounded state
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lli     a1, Dedede.Action.DSPG_BEGIN // a1(action id) = DSP_Ground_Begin
        lw      t8, 0x08E8(s0)              // t8 = top joint struct (original logic, useless?)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        _dedede:
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Ground_Charge.
    scope ground_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lw      a2, 0x0084(a0)              // a2 = player struct
        sw      r0, 0x0B1C(a2)              // timer = 0

        lli     a1, Dedede.Action.DSPG_CHARGE// a1(action id) = DSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~

        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002

        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(a0)              // store on hit subroutine in player struct
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Air_Charge.
    scope air_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lw      a2, 0x0084(a0)              // a2 = player struct
        sw      r0, 0x0B1C(a2)              // timer = 0

        lli     a1, Dedede.Action.DSPA_CHARGE // a1(action id) = DSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~

        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002

        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(a0)              // store on hit subroutine in player struct
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Charge and DSP_Air_Charge.
    scope charge_main_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0044(sp)              // 0x0044(sp) = player object
        lw      a3, 0x0084(a0)              // load player struct
        sw      a3, 0x0040(sp)              // 0x0040(sp) = player struct

        lw      t0, 0x0AE4(a3)              // t0 = current charge level
        lli     at, 0x0002                  // at = max charge
        beql    t0, at, _check_end          // branch if full charge has been reached
        lui     t1, CHARGE_END              // t1 = animation frame to end on

        lw      t5, 0x0B1C(a3)              // t5 = timer
        addiu   t5, t5, 0x0001              // increment timer
        sw      t5, 0x0B1C(a3)              // store updated timer
        lli     at, FIRST_PULL              // at = FIRST_PULL
        beq     at, t5, _attach             // if timer = FIRST_PULL, attach a minion without updating charge
        lli     at, FIRST_STOW              // at = FIRST_STOW
        beq     at, t5, _destroy            // if timer = FIRST_STOW, destroy attached minion
        lli     at, SECOND_PULL             // at = SECOND_PULL
        beq     at, t5, _add_charge         // if timer = SECOND_PULL, attach a minion and update charge
        lli     at, SECOND_STOW             // at = SECOND_STOW
        beq     at, t5, _destroy            // if timer = SECOND_STOW, destroy attached minion
        lli     at, FINAL_PULL              // at = FINAL_PULL
        bne     at, t5, _end                // end if timer != FINAL_PULL
        nop

        _add_charge:
        lw      t0, 0x0AE4(a3)              // t0 = current charge level
        addiu   t0, t0, 0x0001              // increment charge level
        sw      t0, 0x0AE4(a3)              // store updated charge level
        lli     at, 0x0002                  // at = max charge
        bne     t0, at, _attach             // branch if charge isn't max
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id
        jal     0x800E9814                  // begin gfx routine which attaches white spark to hand
        or      a2, r0, r0                  // a2 = 0
        lw      a0, 0x0044(sp)              // 0x0044(sp) = player object

        _attach:
        jal     attach_minion_              // create and attach minion
        nop
        b       _end                        // branch to end
        nop

        _destroy:
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     destroy_attached_minion_    // destroy attached minion
        nop
        b       _end                        // branch to end
        nop

        _check_end:
        mtc1    t1, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.lt.s  f8, f6                      // ~
        nop
        bc1t   _end                         // skip if animation end has not been reached
        nop

        jal     0x800DEE54                  // transition to idle (ground and air)
        nop
        jal     destroy_attached_minion_    // destroy attached minion
        lw      a0, 0x0040(sp)              // a0 = player struct

        _end:
        lw      ra, 0x0014(sp)
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Interrupt subroutine for DSP_Ground_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope ground_charge_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        // begin by checking if B is held
        lw      a1, 0x0084(a0)              // a1 = player struct
		lw		v0, 0x0B1C(a1)				// v0 = timer
		sltiu	v0, v0, MINION_RUMMAGE_TIME // v0 = 0 if able to toss minion
	    bnezl	v0, _check_cancel			// cannot shoot if not above minimum timer
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        lhu     v0, 0x01BC(a1)              // v0 = buttons_held
        andi    t6, v0, Joypad.B            // t6 = 0x4000 if (B_HELD); else t6 = 0
        bnez    t6, _check_cancel           // branch if (B_HELD)
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed

        // if we're here B has been released, so transition to NSP_Ground_Shoot
        jal     ground_shoot_initial_       // ground_shoot_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_cancel:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to idle
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     destroy_attached_minion_    // destroy attached minion
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x8013E1C8                  // transition to idle
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
    }

    // @ Description
    // Interrupt subroutine for DSP_Air_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope air_charge_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        // begin by checking if B is held
        lw      a1, 0x0084(a0)              // a1 = player struct
		lw		v0, 0x001C(a1)				// v0 = action frame timer
		sltiu	v0, v0, MINION_RUMMAGE_TIME // v0 = 0 if able to toss minion
	    bnezl	v0, _check_cancel			// cannot shoot if not above minimum timer
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        lhu     v0, 0x01BC(a1)              // v0 = buttons_held
        andi    t6, v0, Joypad.B            // t6 = 0x4000 if (B_HELD); else t6 = 0
        bnez    t6, _check_cancel           // branch if (B_HELD)
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed

        // if we're here B has been released, so transition to NSP_Air_Shoot
        jal     air_shoot_initial_          // air_shoot_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_cancel:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     destroy_attached_minion_    // destroy attached minion
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x8013F9E0                  // transition to fall
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        addiu   sp, sp, 0x0030              // dellocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Charge.
    scope ground_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_charge_transition_  // a1(transition subroutine) = air_charge_transition_

        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop

        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Charge
    scope air_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_charge_transition_ // a1(transition subroutine) = ground_charge_transition_

        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop

        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Charge.
    scope ground_charge_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        jal     0x800DEE98                  // set grounded state
        or      a0, s0, r0                  // a0 = player struct

        lw      a0, 0x0028(sp)              // a0 = player object

        lli     a1, Dedede.Action.DSPG_CHARGE// a1(action id) = DSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~

        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        _dedede:
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_Charge.
    scope air_charge_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct

        jal     0x800D8EB8                  // momentum capture?
        or      a0, s0, r0                  // a0 = player struct

        lw      a0, 0x0028(sp)              // a0 = player object

        lli     a1, Dedede.Action.DSPA_CHARGE// a1(action id) = DSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~

        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        _dedede:
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra                          // return
        nop
    }


    // @ Description
    // initial routine for minion toss
    scope ground_shoot_initial_: {
        addiu   sp, sp, -0x0028             // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x0B28(v0)              // clear 0x0B28
        addiu   a1, r0, Dedede.Action.DSPG_SHOOT // a1(action id) = DSPG_SHOOT
        addiu   a2, r0, 0x0000              // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        sw      v0, 0x0024(sp)              // 0x0024(sp) = player struct
        jal     0x800E6F24                  // change action
        sw      a0, 0x0028(sp)              // 0x0028(sp) = player object

        lw      v0, 0x0024(sp)              // v0 = player struct
        lbu     t9, 0x0192(v0)              // ~
        ori     t0, t9, 0x0080              // ~
        sb      t0, 0x0192(v0)              // enabled unknown bitflag
        lw      t0, 0x0B20(v0)              // attached item object
        bnez    t0, _continue               // branch if attached item is present
        nop

        // if there's no attached item object, attempt to attach one
        jal     attach_minion_              // attach_minion_
        lw      a0, 0x0028(sp)              // a0 = player object

        _continue:
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      v0, 0x0024(sp)              // v0 = player struct
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(v0)              // store on hit subroutine in player struct

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // initial routine for minion toss
    scope air_shoot_initial_: {
        addiu   sp, sp, -0x0028             // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x0B28(v0)              // clear 0x0B28
        addiu   a1, r0, Dedede.Action.DSPA_SHOOT // a1(action id) = DSPA_SHOOT
        addiu   a2, r0, 0x0000              // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        sw      v0, 0x0024(sp)              // 0x0024(sp) = player struct
        jal     0x800E6F24                  // change action
        sw      a0, 0x0028(sp)              // 0x0028(sp) = player object

        lw      v0, 0x0024(sp)              // v0 = player struct
        lbu     t9, 0x0192(v0)              // ~
        ori     t0, t9, 0x0080              // ~
        sb      t0, 0x0192(v0)              // enabled unknown bitflag
        lw      t0, 0x0B20(v0)              // attached item object
        bnez    t0, _continue               // branch if attached item is present
        nop

        // if there's no attached item object, attempt to attach one
        jal     attach_minion_              // attach_minion_
        lw      a0, 0x0028(sp)              // a0 = player object

        _continue:
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      v0, 0x0024(sp)              // v0 = player struct
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(v0)              // store on hit subroutine in player struct

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // main subroutine for Dedede's waddle_dee based on Mario's fireball coding
    scope shoot_main_: {
        addiu   sp, sp, -0x0080
        sw      ra, 0x0014(sp)
        swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)                      // 0x0034(sp) = player object
        lw      v0, 0x0084(a0)                      // loads player struct
        sw      v0, 0x0050(sp)                      // save player struct
        addiu   t6, r0, r0                          // clear register
        lw      t6, 0x0B28(v0)                      // load from frame counter/character free space
        addiu   t8, t6, 0x0001                      // add a frame
        sw      t8, 0x0B28(v0)                      // save new frame amount
        slti    at, t6, 0x0003
        or      a3, a0, r0
        lw      t6, 0x017C(v0)

        beql    t6, r0, _idle_transition_check      // this checks moveset variables to see if projectile should be spawned
        lw      ra, 0x0014(sp)

        mtc1    r0, f0
        sw      r0, 0x017C(v0)                      // reset temp variable 1
        sw      r0, 0x0040(sp)                      // ~
        sw      r0, 0x0044(sp)                      // ~
        sw      r0, 0x0048(sp)                      // unknown x/y/z offset?
        addiu   a1, sp, 0x0020
        swc1    f0, 0x0020(sp)                      // x offset
        swc1    f0, 0x0024(sp)                      // y offset
        swc1    f0, 0x0028(sp)                      // z offset
        lw      a0, 0x08F8(v0)                      // a0 = joint
        sw      a3, 0x0030(sp)

        jal     0x800EDF24                          // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)

        li      at, 0x80000002                      // ~
        sw      at, 0x0010(sp)                      // unknown argument = 0x80000002

        // throw minion or gordo and clears charge
        lw      a0, 0x0034(sp)                      // 0x0034(sp) = player object
        lw      t0, 0x0050(sp)                      // loads player struct
        sw      r0, 0x0AE4(t0)                      // clear charge
        lw      v0, 0x0B20(t0)                      // v0 = attached item object
		// v0 = minion object
        beqz    v0, _idle_transition_check          // skip if no attached minion
        nop
        sw      r0, 0x0B20(t0)                      // clear attached item object
		lw		v1, 0x0084(v0)
		lli		at, 0x0001
		sh		at, 0x033E(v1)						// flag sets minion to throw state

        // checks frame counter to see if reached end of the move
        _idle_transition_check:
        lw      a2, 0x0034(sp)
        _idle_transition_check_2:
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
        lw      ra, 0x0014(sp)
        lw      a2, 0x0034(sp)
        jal     0x800DEE54
        or      a0, a2, r0

        _end:
        lw      a0, 0x0034(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0080
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which attaches a minion to dedede's hand.
    // a0 - player object
    scope attach_minion_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0038(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _dedede:
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine

        _continue:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        or      a0, s0, r0                  // a0 = player struct
        jal     0x8015D35C                  // get part position
        addiu   a1, sp, 0x0028              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a2, sp, 0x0028              // x/y/z coordinates

		// makes a minion
        lw      a0, 0x0038(sp)              // 0x0034(sp) = player object
        lw      t0, 0x0084(a0)              // loads player struct
        lw      v0, 0x0AE4(t0)              // load charge
        addiu   a3, sp, 0x0040              // a3 = unknown x/y/z offset
        sw      r0, 0x0000(a3)              // x offset
        lui     at, 0x4282                  // load 6a5 (fp)
        sw      at, 0x0004(a3)              // set y offset to 75
        sw      r0, 0x0008(a3)              // z offset
        li      a1, Item.WaddleDee.item_info_array // a1 = waddle dee
        beqz    v0, _create_minion          // branch if Waddle Dee
        addiu   at, r0, 0x0001              // waddle doo ID
        li      a1, Item.WaddleDoo.item_info_array // a1 = waddle doo
        beq     v0, at, _create_minion      // branch if Waddle Doo
        nop

        _create_gordo:
        li      a1, Item.Gordo.item_info_array // a1 = gordo
        jal     Item.Gordo.SPAWN_ITEM       // create gordo item
        nop
        b       _end
		nop

        _create_minion:
        jal     Item.WaddleDee.SPAWN_ITEM           // create item
        addiu   a3, sp, 0x0040                      // a3 = unknown x/y/z offset

        _end:
        sw      v0, 0x0B20(s0)              // store attached item object
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    scope ground_shoot_collision_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, ground_to_air

        jal     0x800DDE84
        nop

        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // DSP ground to air transition
    scope ground_to_air: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)

        jal     0x800DEEC8
        sw      a0, 0x0024(sp)

        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        lw      a1, 0x0024(sp)  // load player struct
        lw      a1, 0x0024(a1)  // load current action
        addiu   a1, a1, 0x0003  // add 3 to get air action
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)

        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80

        jal     0x800D8EB8
        lw      a0, 0x0024(sp)

        lw      a0, 0x0024(sp)              // ~
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(a0)              // store on hit subroutine in player struct

        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // Based on Mario NSP collision at 80155F28
    scope air_shoot_collision_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, air_to_ground

        jal     0x800DE6E4
        nop

        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // DSP air to ground transition
    scope air_to_ground: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)

        jal     0x800DEE98
        sw      a0, 0x0024(sp)

        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        lw      a1, 0x0024(sp)  // load player struct
        lw      a1, 0x0024(a1)  // load current action
        addiu   a1, a1, -0x0003 // subtract 3 to get ground action
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)

        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80

        lw      a0, 0x0024(sp)              // load player struct
        li      t7, dedede_on_hit_subroutine_ // t7 = on hit subroutine
        sw      t7, 0x09EC(a0)              // store on hit subroutine in player struct

        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }
}
