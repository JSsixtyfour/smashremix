// MarinaSpecial.asm

// This file contains subroutines used by Marina's special moves.

scope MarinaCargo {
    // @ Description
    // Main subroutine for CargoJump.
    scope jump_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x8014DA98                  // transition to CargoAir
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    constant SHAKE_FGM_ID(0x420)			// JPN voice clip
    constant SHAKE_ALTERNATE_FGM_ID(0x43C)	// NA voice clip

    // @ Description
    // Initial subroutine for CargoShake
    // Changes action, and sets up initial variable values.
    scope shake_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store ra, a0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Marina.Action.CargoShake // a1(action id) = CargoShake
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        lw      a0, 0x0020(sp)              // restore a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x017C(v0)              // temp variable 1 = 0
        sw      r0, 0x0180(v0)              // b press flag = FALSE
        sw      r0, 0x0184(v0)              // loop flag = FALSE

		// Play voice FGM
        lh      t6, 0x01BA(v0)              // t6 = taunt button mask
        lh      t5, 0x01BC(v0)              // t5 = buttons held
        and		t5, t5, t6                  // t5 != 0 if taunt held
        beqzl   t5, _play_voice
        lli     a0, SHAKE_FGM_ID            // arg0 = default voice
        lli     a0, SHAKE_ALTERNATE_FGM_ID  // or arg0 = alternate voice
        _play_voice:
        jal		0x800269C0                  // play FGM
        nop

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Main subroutine for CargoShake.
    scope shake_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      v0, 0x001C(sp)              // 0x001C(sp) = player struct

        // check if damage should be applied
        lw      a1, 0x017C(v0)              // a1 = damage to add
        beqz    a1, _check_b_press          // skip if no damage to add
        lw      a0, 0x0840(v0)              // a0 = captured player object

        jal     0x800E8AAC                  // check vulnerability
        nop
        lli     at, 0x0001                  // at = 1
        bne     v0, at, _check_b_press      // skip if captured player is not vulernable
        lw      v0, 0x001C(sp)              // v0 = player struct

        lw      a0, 0x0840(v0)              // a0 = captured player object
        lw      a0, 0x0084(a0)              // a0 = captured played struct
        lw      a1, 0x017C(v0)              // a1 = damage to add
        jal     0x800EA248                  // apply damage
        sw      r0, 0x017C(v0)              // reset damage variable

        // check if an item should be spawned
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0B28(v0)              // t6 = gem_spawned
        bnez    t6, _check_b_press          // skip if gem_spawned != FALSE
        lli     at, OS.TRUE                 // ~

        addiu   sp, sp, -0x0060             // allocate stack space (0x8016EA78 is unsafe)
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      r0, 0x0000(a1)              // ~
        sw      r0, 0x0004(a1)              // ~
        sw      r0, 0x0008(a1)              // clear space for x/y/z coordinates
        lw      a0, 0x0960(v0)              // a0 = marina grab joint
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      at, 0x0B28(v0)              // gem_spawned = TRUE
        or      a0, r0, r0                  // a0 = owner (none)
        lli     a1, Item.Gem.id             // a1 = item id (gem)
        addiu   a2, sp, 0x0020              // a2 = coordinates to create item at
        addiu   a3, sp, 0x002C              // a3 = address of velocity floats
        lli     t3, 0x0001                  // t3 = 1
        sw      t3, 0x0010(sp)              // 0x0010(sp) = 1
        sw      r0, 0x0008(a2)              // initial z position = 0
        sw      r0, 0x0000(a3)              // initial x velocity = 0
        lui     t3, 0x41F0                  // ~
        sw      t3, 0x0004(a3)              // initial y velocity = 30
        jal     0x8016EA78                  // create item
        sw      r0, 0x0008(a3)              // initial z velocity = 0
        beqz    v0, _check_b_press          // branch if no item object was created
        addiu   sp, sp, 0x0060              // deallocate stack space

        // prevent spawned item from clipping into walls
        lw      a1, 0x001C(sp)					// a1 = player struct
        addiu   a2, a1, 0x0078                  // a2 = unknown
        lw      a1, 0x0078(a1)                  // a1 = player x/y/z coordinates
        jal     0x800DF058                      // check clipping
        or      a0, v0, r0                      // a0 = item object

        _check_b_press:
        // check if b presses are allowed
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0180(v0)              // t6 = b press flag
        beqz    t6, _check_loop             // branch if b presses aren't allowed yet
        nop

        // check if the b button is being pressed
        lhu     t6, 0x01BE(v0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _check_loop             // skip if B is not pressed
        lli     at, OS.TRUE                 // at = TRUE

        // if we're here, the b button was pressed so enable the loop flag
        sw      at, 0x0184(v0)              // loop flag = TRUE

        _check_loop:
        // if the animation frame is 0, then check if we should loop or end the shake
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t6, 0x0078(a0)              // t6 = current animation frame
        lui     at, 0x8000                  // ~
        bne     t6, at, _end                // branch if current animation frame != 0x80000000 (loop frame)
        lw      t6, 0x0184(v0)              // t6 = loop flag
        sw      r0, 0x0184(v0)              // reset loop flag
        bnez    t6, _end                    // branch if loop flag = TRUE
        sw      r0, 0x0180(v0)              // reset b press flag

        // if we're here then the end of the animation has been reached but the loop flag is disabled, so end the shake
        jal     0x8014D49C                  // transition to Cargo
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Patch which extends Cargo action checks to include CargoShake for Marina.
    scope shake_check_: {
        OS.patch_start(0xC89F4, 0x8014DFB4)
        j       shake_check_
        or      a2, a0, r0                  // original line 1
        _return:
        OS.patch_end()

        or      a1, r0, r0                  // original line 2
        lw      t6, 0x0008(v1)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        bne     at, t6, _end                // skip if character != MARINA...
        nop

        // if the character is MARINA, check kinetic state
        lw      t6, 0x014C(v1)              // t0 = kinetic state
        bnez    t6, _end                    // skip if kinectic state != grounded
        nop

        // if Marina is grounded, check for a B press
        lhu     t6, 0x01BE(v1)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _end                    // skip if B is not pressed
        nop

        // if the B button was pressed, change the action to CargoShake and end the function
        jal     shake_initial_
        nop
        j       0x8014E034                  // end original function
        lli     v1, OS.TRUE                 // return TRUE (action change occured)

        _end:
        j       _return
        nop

    }

    // @ Description
    // Patch which sets the CargoJump action and FSM for Marina.
    scope jump_patch_: {
        OS.patch_start(0xC8568, 0x8014DB28)
        j       jump_patch_
        mfc1    a2, f0                      // original line 1
        _return:
        OS.patch_end()


        lw      t6, 0x0008(s0)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _marina
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bnel    at, t6, _end                // branch if character != MARINA...
        mfc1    a3, f0                      // ...and a3(frame speed multiplier) = 0 (original line 2)

        _marina:
        // if we're here then the character is MARINA, so load CargoJump parameters
        lli     a1, Marina.Action.CargoJump // ...and a1(action id) = CargoJump
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which sets the FSM to 1.0 for Marina's CargoAir action.
    scope air_patch_: {
        OS.patch_start(0xC850C, 0x8014DACC)
        j       air_patch_
        mfc1    a2, f0                      // original line 1
        _return:
        OS.patch_end()

        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      t7, 0x0024(sp)              // t7 = player struct
        lw      t6, 0x0008(t7)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _end                // branch if character = MARINA
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bnel    at, t6, _end                // branch if character != NMARINA...
        // if we're here then the character is not (N)MARINA, so set FSM to 0
        mfc1    a3, f0                      // a3(frame speed multiplier) = 0 (original line 2)

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which sets the FSM to 1.0 for Marina's CargoJumpSquat action.
    scope jumpsquat_patch_: {
        OS.patch_start(0xC83A4, 0x8014D964)
        j       jumpsquat_patch_
        mfc1    a2, f0                      // original line 1
        _return:
        OS.patch_end()

        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      t6, 0x0008(v0)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _end                // branch if character = MARINA
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bnel    at, t6, _end                // branch if character != NMARINA...
        // if we're here then the character is not (N)MARINA, so set FSM to 0
        mfc1    a3, f0                      // a3(frame speed multiplier) = 0 (original line 2)

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which adjusts the damage of Marina's ThrowF action and initializes gem_spawned.
    scope throw_f_patch_: {
        OS.patch_start(0xC9000, 0x8014E5C0)
        j       throw_f_patch_
        lwc1    a2, 0x0288(s1)              // original line 2
        _return:
        OS.patch_end()

        lw      t6, 0x0008(s1)              // t6 = character id
        addiu   a1, r0, 0x0005              // damage = 5 (for Marina)
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _marina             // branch if character = MARINA...
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bnel    at, t6, _end                // branch if character != NMARINA...
        // if we're here then the character is not (N)MARINA, so continue normally
        addiu   a1, r0, 0x0008              // original line 1

        _marina:
        // if the character is MARINA, set the intial value for gem_spawned
        sw      r0, 0x0B28(s1)              // gem_spawned = FALSE

        _end:
        j       _return                     // return
        nop
    }
}

scope MarinaNSP {
    constant X_SPEED(0x4270)                // current setting - float32 60
    constant X_AIR_SPEED(0x4240)            // current setting - float32 48
    constant THROW_GRAVITY(0x4000)          // current setting - float32 2
    constant AIR_FRICTION(0x4040)           // current setting - float32 3
    constant GROUND_TRACTION(0x3F80)        // current setting - float32 1

    constant BEGIN_MOVE(0x1)
    constant MOVE(0x2)
    constant END_MOVE(0x3)
    constant END(0x4)

    // @ Description
    // Initial subroutine for NSPGround.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPG
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPG

        lli     a1, Marina.Action.NSPGround // a1(action id) = NSPGround
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, ground_pull_initial_    // a1 = ground_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSPAir.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPA
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPA

        lli     a1, Marina.Action.NSPAir    // a1(action id) = NSPAir
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSPGroundPull.
    scope ground_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPGPull
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPGPull

        lli     a1, Marina.Action.NSPGroundPull // a1(action id) = NSPGroundPull
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     grab_pull_setup_            // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // turn frame timer = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSPAirPull.
    scope air_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPAPull
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPAPull

        lli     a1, Marina.Action.NSPAirPull // a1(action id) = NSPAirPull
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     grab_pull_setup_            // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, 0x3F00                  // ~
        mtc1    at, f2                      // f2 = 0.5
        lwc1    f4, 0x0048(a0)              // f4 = x velocity
        mul.s   f4, f4, f2                  // f4 = x velocity * 0.5
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x004C(a0)              // y velocity = 0
        sw      r0, 0x0B18(a0)              // turn frame timer = 0
        swc1    f4, 0x0048(a0)              // store updated x velocity
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which helps set up the command grab for Marina.
    scope grab_pull_setup_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x003F                  // a1 = bitflags?
        jal     0x800E8098                  // sets the byte at 0x193 in the player struct to the value in a1
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t6, 0x0830(a0)              // ~
        sw      t6, 0x0840(a0)              // update captured player?
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSPGroundThrow, NSPGroundThrowU and NSPGroundThrowD.
    scope ground_throw_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        multu   t6, t7                      // stick_x * DIRECTION
        lb      t6, 0x01C3(v1)              // t6 = stick_y

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPGThrow
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPGThrow

        lli     a1, Marina.Action.NSPGroundThrow // a1(action id) = NSPGroundThrow
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPGroundThrowU
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0, _change_action      // branch if stick_y < -39...
        addiu   a1, a1, 0x0002              // ...and increment action id to Action.NSPGroundThrowD

        // if action id = NSPGroundThrow
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0

        beqz    at, _change_action           // branch if stick_x >= -39
        nop

        // if stick_x < -39
        lli     t0, 0x0008                  // t0 = 8
        sw      t0, 0x0B18(v1)              // set turn frame timer to 8
        lw      at, 0x0044(v1)              // t0 = DIRECTION
        subu    at, r0, at                  // ~
        sw      at, 0x0044(v1)              // reverse and update DIRECTION


        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSPAirThrow, NSPAirThrowU and NSPAirThrowD.
    scope air_throw_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        multu   t6, t7                      // stick_x * DIRECTION
        lb      t6, 0x01C3(v1)              // t6 = stick_y

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPAThrow
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPAThrow

        lli     a1, Marina.Action.NSPAirThrow // a1(action id) = NSPAirThrow
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPAirThrowU
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0, _change_action      // branch if stick_y < -39...
        addiu   a1, a1, 0x0002              // ...and increment action id to Action.NSPAirThrowD

        // if action id = NSPAirThrow
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0

        beqz    at, _change_action           // branch if stick_x >= -39
        nop

        // if stick_x < -39
        lli     t0, 0x0006                  // t0 = 6
        sw      t0, 0x0B18(v1)              // set turn frame timer to 6
        lw      at, 0x0044(v1)              // t0 = DIRECTION
        subu    at, r0, at                  // ~
        sw      at, 0x0044(v1)              // reverse and update DIRECTION

        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x0048(a0)              // x velocity = 0
        sw      r0, 0x004C(a0)              // y velocity = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }


    // @ Description
    // Main subroutine for NSPGroundPull.
    scope ground_pull_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     ground_throw_initial_       // transition to throw action
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Main subroutine for NSPAirPull.
    scope air_pull_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     air_throw_initial_          // transition to throw action
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Handles character model rotation during NSPGroundThrow and NSPAirThrow
    scope throw_turn_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0018(sp)              // store ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t7, 0x0B18(t0)              // t7 = turn frame timer
        beqz    t7, _end                    // end if frame timer = 0
        lw      t9, 0x0044(t0)              // t9 = DIRECTION

        // if the turn frame timer is active
        addiu   t6, r0, 0x0001              // t6 = 1
        addiu   t8, t7,-0x0001              // t8 = frame timer - 1
        mtc1    t8, f4                      // ~
        lui     at, 0x4100                  // ~
        mtc1    at, f8                      // f8 = 8
        cvt.s.w f6, f4                      // f6 = frame timer (float)
        sw      t8, 0x0B18(t0)              // store udpated frame timer
        bne     t9, t6, _left               // branch if DIRECTION != RIGHT
        nop

        _right:
        // if the target facing direction is right
        lui     at, 0x8019                  // ~
        lwc1    f16, 0xC230(at)             // ~
        lui     at, 0x8019                  // ~
        b       _update                     // branch and update rotation
        lwc1    f4, 0xC234(at)              // logic copied from dk cargo

        _left:
        // if the target facing direction is left
        lui     at, 0x8019                  // ~
        lwc1    f16, 0xC238(at)             // ~
        lui     at, 0x8019                  // ~
        lwc1    f4, 0xC23C(at)              // logic copied from dk cargo

        _update:
        lw      t1, 0x0074(a0)              // ~
        div.s   f10, f6, f8                 // ~
        mul.s   f18, f10, f16               // ~
        sub.s   f6, f4, f18                 // logic copied from dk cargo
        swc1    f6, 0x0034(t1)              // store updated rotation

        _end:
        lw      ra, 0x0018(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Physics subroutine for NSPGround.
    // Temp variable 3 values:
    // 0x0 - begin, 0x1 - begin movement, 0x2 - movement, 0x3 - end movement, 0x4 - end?
    scope ground_physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t6, 0x0184(s0)              // t6 = temp variable 3
        lli     at, BEGIN_MOVE              // ~
        beq     t6, at, _begin_move         // branch if temp variable 3 = BEGIN_MOVE
        lli     at, MOVE                    // ~
        beq     t6, at, _move               // branch if temp variable 3 = MOVE
        lli     at, END_MOVE                // ~
        beq     t6, at, _end_move           // branch if temp variable 3 = END_MOVE
        nop

        // if no movement state is set
        jal     0x800D8BB4                  // physics subroutine
        nop
        b       _end                        // branch to end
        nop

        _begin_move:
        lui     at, X_SPEED                 // ~
        sw      at, 0x0060(s0)              // ground x velocity = SPEED
        lli     at, MOVE                    // ~
        sw      at, 0x0184(s0)              // temp variable 3 = MOVE

        _move:
        jal     0x800D87D0                  // apply grounded movement
        nop
        b       _end                        // branch to end
        nop

        _end_move:
        jal     ground_end_move_physics_    // custom physics subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for NSPAir.
    // Temp variable 3 values:
    // 0x0 - begin, 0x1 - begin movement, 0x2 - movement, 0x3 - end movement, 0x4 - end?
    scope air_physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t6, 0x0184(s0)              // t6 = temp variable 3
        lli     at, BEGIN_MOVE              // ~
        beq     t6, at, _begin_move         // branch if temp variable 3 = BEGIN_MOVE
        lli     at, MOVE                    // ~
        beq     t6, at, _end                // skip if temp variable 3 = MOVE
        lli     at, END_MOVE                // ~
        beq     t6, at, _end_move           // branch if temp variable 3 = END_MOVE
        lli     at, END                     // ~
        beq     t6, at, _end_control        // branch if temp variable 3 = END
        nop

        // if no movement state is set
        jal     0x800D91EC                  // physics subroutine (disallows player control)
        nop
        b       _end                        // branch to end
        nop

         _begin_move:
        lui     at, X_AIR_SPEED             // ~
        mtc1    at, f2                      // f2 = X_AIR_SPEED
        lwc1    f4, 0x0044(s0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = X_AIR_SPEED * DIRECTION
        swc1    f2, 0x0048(s0)              // x velocity = X_AIR_SPEED * DIRECTION
        sw      r0, 0x004C(s0)              // y velocity = 0
        lli     at, MOVE                    // ~
        b       _end                        // branch to end
        sw      at, 0x0184(s0)              // temp variable 3 = MOVE

        _end_move:
        jal     air_end_move_physics_       // custom physics subroutine
        nop
        b       _end                        // branch to end
        nop


        _end_control:
        jal     0x800D9160                  // physics subroutine (allows player control and fast fall)
        nop

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for non-actionable grounded movement
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_end_move_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Physics subroutine for non-actionable aerial movement
    // Modified version of subroutine 0x800D91EC.
    scope air_end_move_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        //sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        //lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        lw      a3, 0x09C8(s0)              // a3 = attribute pointer
        lw      a1, 0x0058(a3)              // a2 = gravity
        jal     0x800D8D68                  // apply gravity/fall speed
        lw      a2, 0x005C(a3)              // a2 = max fall speed

        // Subroutine 0x800D9074 applies air friction. Usually, air friction is loaded from
        // 0x0054(a1), with a1 being the attribute pointer for the character. In this case, a
        // different air friction value is stored at 0x0054(sp) and then the stack pointer is
        // passed to a1 for subroutine 0x800D9074.
        or      a0, s0, r0                  // a0 = player struct
        addiu   sp, sp,-0x0058              // allocate stack space
        lui     a1, AIR_FRICTION            // a1 = AIR_FRICTION
        sw      a1, 0x0054(sp)              // store AIR_FRICTION
        jal     0x800D9074                  // apply air friction
        or      a1, sp, r0                  // a1 = stack pointer
        addiu   sp, sp, 0x0058              // deallocate stack space
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Physics subroutine for NSPAirThrow.
    // Disallows player control until temp variable 1 is set.
    scope throw_air_physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        beqz    t6, _end                    // skip if temp variable 1 = 0
        nop

        _end_move:
        jal     air_throw_move_physics_     // custom physics subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Aerial movement subroutine for NSPAirThrow
    // Modified version of subroutine 0x800D90E0.
    scope air_throw_move_physics_: {
        // Copy the first 8 lines of subroutine 0x800D90E0
        OS.copy_segment(0x548E0, 0x20)

        // Skip 7 lines (fast fall branch logic)

        // jal 0x800D8E50                   // ~
        // or a1, s1, r0                    // original 2 lines call gravity subroutine
        lui     a1, THROW_GRAVITY           // a1 = THROW_GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lw      a2, 0x005C(s1)              // a2 = max fall speed

        // Copy the last 15 lines of subroutine 0x800D90E0
        OS.copy_segment(0x54924, 0x3C)
    }


    // @ Description
    // Collision wubroutine for NSPGround.
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for NSPAir.
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from NSPGround to NSPAir.
    scope ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPA
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPA

        lli     a1, Marina.Action.NSPAir    // a1 = Action.NSPAir
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from NSPAir to NSPGround.
    scope air_to_ground_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPG
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARINA_NSPG

        lli     a1, Marina.Action.NSPGround // a1 = Action.NSPGround
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP grab actions.
    scope grab_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, grab_ground_to_air_     // a1(transition subroutine) = grab_ground_to_air_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for NSP throw actions.
    scope throw_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x800DE934                  // check ground collision
        sw      a0, 0x0018(sp)              // store a0
        beql    v0, r0, _end                // branch if landing transition didn't occured
        nop

        // if a landing transition is occuring, grab release the opponent
        jal     0x80149AC8                  // grab release
        lw      a0, 0x0018(sp)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for NSP grab actions.
    scope grab_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, grab_air_to_ground_     // a1(transition subroutine) = grab_air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from grounded to aerial NSP grab actions.
    scope grab_ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1, 0x0005              // a1 = equivalent air action for current ground action (id + 5)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from aerial to grounded NSP grab actions.
    scope grab_air_to_ground_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1,-0x0005              // a1 = equivalent air action for current ground action (id - 5)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
}

scope MarinaUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x42B8)            // current setting - float32 92
    constant GROUND_Y_SPEED(0x42C4)         // current setting - float32 98
    constant X_SPEED(0x4120)                // current setting - float32 10
    constant AIR_ACCELERATION(0x3C88)       // current setting - float32 0.0166
    constant AIR_SPEED(0x41B0)              // current setting - float32 22
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)

    // @ Description
    // Subroutine which runs when Marina initiates an aerial up special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Marina.Action.USPA      // a1 = Action.USPA
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // freeze y position
        lw      v1, 0x09C8(a0)              // v1 = attribute pointer
        lw      v1, 0x0058(v1)              // v1 = gravity
        sw      v1, 0x004C(a0)              // y velocity = gravity
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Marina initiates a grounded up special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Marina.Action.USPG      // a1 = Action.USPG
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main subroutine for Marina's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Marina's landing FSM value and disable the interrupt flag.
    scope main_: {
        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Marina's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Marina's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = ending
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // store ra, s0, s1

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t0, 0x014C(s0)              // t0 = kinetic state
        bnez    t0, _aerial                 // branch if kinetic state !grounded
        nop

        _grounded:
        jal     0x800D8BB4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        nop

        _aerial:
        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _apply_air_physics  // branch if temp variable 3 != MOVE
        nop
        li      t8, air_control_             // t8 = air_control_

        _apply_air_physics:
        or      a0, s0, r0                  // a0 = player struct
        jalr    t8                          // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Marina.Action.USPG      // t1 = Action.USPG
        beq     t0, t1, _check_begin_move   // skip if current action = USP_GROUND
        nop
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Marina.Action.USPG      // t1 = Action.USPG
        beq     t0, t1, _apply_velocity     // branch if current action = USP_GROUND
        lui     t1, GROUND_Y_SPEED          // t1 = GROUND_Y_SPEED
        // if current action != USP_GROUND
        lui     t1, AIR_Y_SPEED             // t1 = AIR_Y_SPEED

        _apply_velocity:
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps
        swc1    f2, 0x0048(s0)              // store x velocity
        sw      t1, 0x004C(s0)              // store y velocity

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // loar ra, s0, s1
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Marina's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui     a2, AIR_ACCELERATION        // a2 = AIR_ACCELERATION
        lui     a3, AIR_SPEED               // a3 = AIR_SPEED
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // load ra, t0, t1
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for Marina's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Marina.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
}

// @ Description
// Subroutines for Down Special
scope MarinaDSP {
    constant MAX_CHARGE(4)

    // @ Description
    // Subroutine which runs when Marina initiates a grounded down special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x084C(v0)              // t6 = held item object
        beqz    t6, _begin                  // begin down special normally if no held item
        lw      t6, 0x0ADC(v0)              // t6 = charge level
        lli     at, MAX_CHARGE              // at = MAX_CHARGE
        beq     t6, at, _end                // skip if charge level = MAX_CHARGE
        nop

        _stow:
        jal     ground_stow_initial_        // begin grounded item stow
        nop
        b       _end                        // branch to end
        nop

        _begin:
        jal     ground_begin_initial_       // begin grounded down special
        nop

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Marina initiates an aerial down special.
    scope air_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x084C(v0)              // t6 = held item object
        beqz    t6, _begin                  // begin down special normally if no held item
        lw      t6, 0x0ADC(v0)              // t6 = charge level
        lli     at, MAX_CHARGE              // at = MAX_CHARGE
        beq     t6, at, _end                // skip if charge level = MAX_CHARGE
        nop

        _stow:
        jal     air_stow_initial_           // begin aerial item stow
        nop
        b       _end                        // branch to end
        nop

        _begin:
        jal     air_begin_initial_          // begin aerial down special
        nop

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's grounded down special beginning action.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPG_Begin // a1(action id) = DSPG_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155454                  // Ness DSP setup subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        addiu   at, r0, -1                  // ~
        sw      at, 0x0B20(a0)              // b_press_buffer = -1
        sw      r0, 0x0B24(a0)              // add_charge = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's aerial down special beginning action.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPA_Begin // a1(action id) = DSPA_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155454                  // Ness DSP setup subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        addiu   at, r0, -1                  // ~
        sw      at, 0x0B20(a0)              // b_press_buffer = -1
        sw      r0, 0x0B24(a0)              // add_charge = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's grounded down special wait action.
    scope ground_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPG_Wait // a1(action id) = DSPG_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0804                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0804
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     absorb_setup_               // absorb setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's aerial down special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPA_Wait // a1(action id) = DSPA_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0804                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0804
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     absorb_setup_               // absorb setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's down special absorb actions.
    scope absorb_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      t6, 0x018C(v0)              // ~
        sll     t6, t6, 000006              // ~
        sra     t6, t6, 000030              // t6 = reflect direction
        sw      t6, 0x0044(v0)              // update facing direction match reflect direction
        lw      t6, 0x018C(v0)              // t6 = kinetic state
        bnezl   t6, _continue               // branch if kinetic state = aerial...
        lli     a1, Marina.Action.DSPA_Absorb // ...and a1(action id) = DSPA_Absorb

        // if we're here then Marina is grounded
        lli     a1, Marina.Action.DSPG_Absorb //a1(action id) = DSPG_Absorb

        _continue:
        lli     t6, 0x0006                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0006
        jal     0x800E6F24                  // change action
        sw      v0, 0x0024(sp)              // 0x0024(sp) = player struct
        lw      v0, 0x0024(sp)              // v0 = player struct
        sw      r0, 0x0180(v0)              // reset temp variable 2
        lbu     t0, 0x018C(v0)              // ~
        ori     t0, t0, 0x0004              // ~
        sb      t0, 0x018C(v0)              // enable reflect bitflag
        lw      t0, 0x0ADC(v0)              // t0 = charge level
        lw      t1, 0x0B24(v0)              // t1 = add_charge
        addu    t1, t1, t0                  // t1 = charge level + add_charge
        sltiu   at, t1, MAX_CHARGE + 1      // at = 1 if updated charge level =< MAX_CHARGE, else at = 0
        bnezl   at, _destroy                // branch if updated charge level =< MAX_CHARGE...
        sw      t1, 0x0ADC(v0)              // ...and store updated charge level
        lli     at, MAX_CHARGE              // ~
        sw      at, 0x0ADC(v0)              // otherwise, set charge level to MAX_CHARGE

        _destroy:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's grounded down special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPG_End // a1(action id) = DSPG_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's aerial down special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPA_End  // a1(action id) = DSPA_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's grounded down special pull actions.
    scope ground_pull_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t0, 0x0ADC(t0)              // t0 = charge level
        beql    t0, r0, _change_action      // branch if charge level = 0...
        lli     a1, Marina.Action.DSPG_Pull_Fail // ...and a1(action id) = DSPG_Pull_Fail
        lli     a1, Marina.Action.DSPG_Pull // otherwise, a1(action id) = DSPG_Pull

        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

		// Play voice FGM
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lh      t6, 0x01BA(v0)              // t6 = taunt button mask
        lh      t5, 0x01BC(v0)              // t5 = buttons held
        and		t5, t5, t6                  // t5 != 0 if taunt held
        beqzl   t5, _play_voice
        lli     a0, MarinaCargo.SHAKE_FGM_ID            // arg0 = default voice
        lli     a0, MarinaCargo.SHAKE_ALTERNATE_FGM_ID  // or arg0 = alternate voice
        _play_voice:
        jal		0x800269C0                  // play FGM
        nop

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's aerial down special pull actions.
    scope air_pull_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t0, 0x0ADC(t0)              // t0 = charge level
        beql    t0, r0, _change_action      // branch if charge level = 0...
        lli     a1, Marina.Action.DSPA_Pull_Fail // ...and a1(action id) = DSPA_Pull_Fail
        lli     a1, Marina.Action.DSPA_Pull // otherwise, a1(action id) = DSPA_Pull

        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

		// Play voice FGM
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lh      t6, 0x01BA(v0)              // t6 = taunt button mask
        lh      t5, 0x01BC(v0)              // t5 = buttons held
        and		t5, t5, t6                  // t5 != 0 if taunt held
        beqzl   t5, _play_voice
        lli     a0, MarinaCargo.SHAKE_FGM_ID            // arg0 = default voice
        lli     a0, MarinaCargo.SHAKE_ALTERNATE_FGM_ID  // or arg0 = alternate voice
        _play_voice:
        jal		0x800269C0                  // play FGM
        nop

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's grounded down special stowing action.
    scope ground_stow_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPG_Stow // a1(action id) = DSPG_Stow
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Marina's aerial down special stowing action.
    scope air_stow_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marina.Action.DSPA_Stow // a1(action id) = DSPA_Stow
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_Begin
    scope ground_begin_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     update_buffer_              // update b_press_buffer
        sw      a0, 0x0018(sp)              // store a0

        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0180(a0)              // t0 = temp variable 2
        beqz    t0, _check_end_transition   // branch if temp variable 2 is not set
        lw      t0, 0x0ADC(a0)              // a0 = charge level
        lli     at, MAX_CHARGE              // at = MAX_CHARGE
        bne     at, t0, _check_end_transition // branch if charge level != MAX_CHARGE
        nop

        // if temp variable 2 is set and down special is fully charged
        jal     ground_pull_initial_        // transition to DSPG_Pull
        lw      a0, 0x0018(sp)              // load a0
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, ground_wait_initial_    // a1(transition subroutine) = ground_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        lw      a0, 0x0018(sp)              // load a0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPA_Begin
    scope air_begin_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     update_buffer_              // update b_press_buffer
        sw      a0, 0x0018(sp)              // store a0

        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0180(a0)              // t0 = temp variable 2
        beqz    t0, _check_end_transition   // branch if temp variable 2 is not set
        lw      t0, 0x0ADC(a0)              // a0 = charge level
        lli     at, MAX_CHARGE              // at = MAX_CHARGE
        bne     at, t0, _check_end_transition // branch if charge level != MAX_CHARGE
        nop

        // if temp variable 2 is set and down special is fully charged
        jal     air_pull_initial_           // transition to DSPA_Pull
        lw      a0, 0x0018(sp)              // load a0
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, air_wait_initial_       // a1(transition subroutine) = air_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        lw      a0, 0x0018(sp)              // load a0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_Wait
    scope ground_wait_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0020(sp)              // store a0

        lh      t6, 0x01BE(v0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        bnez    t6, _begin_pull             // branch if (B_PRESSED)
        lw      t6, 0x0B20(v0)              // t6 = b_press_buffer
        beqz    t6, _check_transition       // skip if (!B_PRESSED)
        nop

        // if we're here then the B button was pressed, so begin a pull action
        _begin_pull:
        jal     ground_pull_initial_        // transition to DSPG_Pull or DSPG_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_transition:
        jal     0x80155518                  // subroutine which updates min_frame_timer and b_not_held variables
        sw      v0, 0x001C(sp)              // store v0
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0B18(v0)              // t6 = min_frame_timer
        bgtz    t6, _end                    // if min_frame_timer > 0, skip
        lw      t7, 0x0B1C(v0)              // t7 = b_not_held
        beqz    t7, _end                    // skip if !b_not_held
        nop

        // if we reach this point, the minimum number of frames before the action can end has elapsed, and b is not held
        jal     ground_end_initial_         // transition to DSPG_End
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPA_Wait
    scope air_wait_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0020(sp)              // store a0

        lh      t6, 0x01BE(v0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        bnez    t6, _begin_pull             // branch if (B_PRESSED)
        lw      t6, 0x0B20(v0)              // t6 = b_press_buffer
        beqz    t6, _check_transition       // skip if (!B_PRESSED)
        nop

        // if we're here then the B button was pressed, so begin a pull action
        _begin_pull:
        jal     air_pull_initial_           // transition to DSPA_Pull or DSPA_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_transition:
        jal     0x80155518                  // subroutine which updates min_frame_timer and b_not_held variables
        sw      v0, 0x001C(sp)              // store v0
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0B18(v0)              // t6 = min_frame_timer
        bgtz    t6, _end                    // if min_frame_timer > 0, skip
        lw      t7, 0x0B1C(v0)              // t7 = b_not_held
        beqz    t7, _end                    // skip if !b_not_held
        nop

        // if we reach this point, the minimum number of frames before the action can end has elapsed, and b is not held
        jal     air_end_initial_            // transition to DSPA_End
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_Absorb
    scope ground_absorb_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     update_buffer_              // update b_press_buffer
        sw      a0, 0x0018(sp)              // store a0

        lw      a0, 0x0018(sp)              // load a0
        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0180(t5)              // t6 = temp variable 2
        beqz    t6, _check_end_transition   // skip if temp variable 2 = 0
        lw      t6, 0x0B20(t5)              // t6 = b_press_buffer
        beqz    t6, _check_b_held           // skip if b_press_buffer = FALSE
        lh      t6, 0x01BC(t5)              // t6 = buttons_held

        // if temp variable has been set, and b_press_buffer = TRUE
        jal     ground_pull_initial_        // transition to DSPG_Pull or DSPG_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_b_held:
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_HELD); else t6 = 0
        bnez    t6, _check_end_transition   // skip if (B_HELD)
        nop

        // if temp variable 2 has been set, and the player is not holding B
        jal     ground_end_initial_         // transition to DSPG_End
        nop
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, ground_wait_initial_    // a1(transition subroutine) = ground_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop


        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPA_Absorb
    scope air_absorb_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     update_buffer_              // update b_press_buffer
        sw      a0, 0x0018(sp)              // store a0

        lw      a0, 0x0018(sp)              // load a0
        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0180(t5)              // t6 = temp variable 2
        beqz    t6, _check_end_transition   // skip if temp variable 2 = 0
        lw      t6, 0x0B20(t5)              // t6 = b_press_buffer
        beqz    t6, _check_b_held           // skip if b_press_buffer = FALSE
        lh      t6, 0x01BC(t5)              // t6 = buttons_held

        // if temp variable has been set, and b_press_buffer = TRUE
        jal     air_pull_initial_           // transition to DSPA_Pull or DSPA_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_b_held:
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_HELD); else t6 = 0
        bnez    t6, _check_end_transition   // skip if (B_HELD)
        nop

        // if temp variable 2 has been set, and the player is not holding B
        jal     air_end_initial_            // transition to DSPA_End
        nop
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, air_wait_initial_       // a1(transition subroutine) = air_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop


        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_End
    scope ground_end_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t5, 0x0084(a0)              // t5 = player struct
        lh      t6, 0x01BE(t5)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _check_idle             // skip if (!B_PRESSED)
        nop

        // if we're here then the B button was pressed, so begin a pull action
        jal     ground_pull_initial_        // transition to DSPG_Pull or DSPG_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_idle:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPA_End
    scope air_end_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t5, 0x0084(a0)              // t5 = player struct
        lh      t6, 0x01BE(t5)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _check_idle             // skip if (!B_PRESSED)
        nop

        // if we're here then the B button was pressed, so begin a pull action
        jal     air_pull_initial_           // transition to DSPA_Pull or DSPA_Pull_Fail
        nop
        b       _end                        // end subroutine
        nop

        _check_idle:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_Pull and DSPA_Pull
    scope pull_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // store a0

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x017C(t5)              // t6 = temp variable 1
        beqz    t6, _check_idle             // skip if temp variable 1 = 0
        nop

        // if we're here then temp variable 2 is set, so create an item
        jal     create_and_assign_clanpot_item_ // transition to DSPG_Pull or DSPG_Pull_Fail
        sw      r0, 0x017C(t5)              // reset temp variable 1
        lw      a0, 0x0018(sp)              // ~
        lw      t5, 0x0084(a0)              // t5 = player struct
        sw      r0, 0x0ADC(t5)              // reset charge level

        _check_idle:
        // checks the current animation frame to see if we've reached end of the animation
        lw      a0, 0x0018(sp)              // load a0
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSPG_Stow and DSPA_Stow
    scope stow_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // store a0

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x017C(t5)              // t6 = temp variable 1
        beqz    t6, _check_idle             // skip if temp variable 1 = 0
        nop

        // if we're here then temp variable 2 is set, so destroy the item and add charge
        lw      a0, 0x084C(t5)              // a0 = held item object
        beqz    a0, _check_idle             // skip if there's no held item object for some reason
        sw      r0, 0x017C(t5)              // reset temp variable 1
        jal     get_item_level_             // v0 = item charge level
        lw      a0, 0x0084(a0)              // a0 = held item special struct
        lw      a0, 0x084C(t5)              // a0 = held item object
        lw      t0, 0x0ADC(t5)              // t0 = charge level
        addu    t1, t0, v0                  // t1 = charge level + add_charge
        sltiu   at, t1, MAX_CHARGE + 1      // at = 1 if updated charge level =< MAX_CHARGE, else at = 0
        bnezl   at, _destroy                // branch if updated charge level =< MAX_CHARGE...
        sw      t1, 0x0ADC(t5)              // ...and store updated charge level
        lli     at, MAX_CHARGE              // ~
        sw      at, 0x0ADC(t5)              // otherwise, set charge level to MAX_CHARGE

        _destroy:
        jal     0x801728D4                  // destroy item
        sw      r0, 0x084C(t5)              // reset held item object

        _check_idle:
        // checks the current animation frame to see if we've reached end of the animation
        lw      a0, 0x0018(sp)              // load a0
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which updates b_press_buffer for down special actions.
    scope update_buffer_: {
        lw      t5, 0x0084(a0)              // t5 = player struct
        // prevent the buffer from being updated on the first frame of down special
        lw      t6, 0x0B20(t5)              // t6 = b_press_buffer
        bltzl   t6, _end                    // branch if b_press_buffer = -1...
        sw      r0, 0x0B20(t5)              // ...and set b_press_buffer to FALSE
        lh      t6, 0x01BE(t5)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        lli     at, OS.TRUE                 // at = TRUE
        bnezl   t6, _end                    // branch if (B_PRESSED)...
        sw      at, 0x0B20(t5)              // ...and set b_press_buffer to TRUE

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground collision for down special actions
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air collision for down special actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition for down special actions
    scope ground_to_air_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0038(sp)              // store a0, ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct

        li      t6, ground_to_air_table     // t6 = ground_to_air_table
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7,-Marina.Action.DSPG_Begin // ~
        sll     t7, t7, 0x3                 // t7 = offset for ground_to_air_table
        addu    t6, t6, t7                  // t6 = ground_to_air_table + offset
        sw      t6, 0x0030(sp)              // store address of current action in ground_to_air_table
        lhu     t7, 0x0002(t6)              // t7 = argument 4 for current action
        sw      t7, 0x0010(sp)              // store argument 4

        lw      a0, 0x0038(sp)              // a0 = player object
        lhu     a1, 0x0000(t6)              // a1 = action id to transition to
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct

        _check_set_bitflag:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0004(v0)              // v0 = bool set_bitflag
        beqz    v0, _end                    // skip if !set_flag
        lw      v0, 0x0034(sp)              // v0 = player struct

        lbu     t9, 0x018C(v0)              // ~
        ori     t0, t9, 0x0004              // ~
        sb      t0, 0x018C(v0)              // enable reflect bitflag

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition for down special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0038(sp)              // store a0, ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct

        li      t6, air_to_ground_table     // t6 = air_to_ground_table
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7,-Marina.Action.DSPA_Begin // ~
        sll     t7, t7, 0x3                 // t7 = offset for air_to_ground_table
        addu    t6, t6, t7                  // t6 = air_to_ground_table + offset
        sw      t6, 0x0030(sp)              // store address of current action in air_to_ground_table
        lhu     t7, 0x0002(t6)              // t7 = argument 4 for current action
        sw      t7, 0x0010(sp)              // store argument 4

        lw      a0, 0x0038(sp)              // a0 = player object
        lhu     a1, 0x0000(t6)              // a1 = action id to transition to
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        _check_set_bitflag:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0004(v0)              // v0 = bool set_bitflag
        beqz    v0, _end                    // skip if !set_flag
        lw      v0, 0x0034(sp)              // v0 = player struct

        lbu     t9, 0x018C(v0)              // ~
        ori     t0, t9, 0x0004              // ~
        sb      t0, 0x018C(v0)              // enable reflect bitflag

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the absorb range for Marina
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
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Creates and assigns the clanpot item to Marina
    // @ Arguments
    // a0 - player object
    scope create_and_assign_clanpot_item_: {
        lw      t0, 0x0084(a0)                      // t0 = player struct
        lw      t0, 0x084C(t0)                      // t0 = player held item pointer
        bnez    t0, _end                            // if player is holding an item, skip
        nop

		addiu	at, r0, 0x0001
        li      t0, Item.skip_item_spawn_gfx_.flag
        sw      at, 0x0000(t0)                      // update override flag to skip showing spawn gfx

        addiu   sp, sp, -0x0010                     // allocate stack space
        sw      ra, 0x0004(sp)                      // save registers
        sw      a0, 0x0008(sp)                      // ~

        addiu   sp, sp, -0x0030                     // allocate stack space (0x8016EA78 is unsafe)
        lw      a1, 0x0074(a0)                      // t1 = location of coordinates (use player position)
        addiu   a1, a1, 0x001C                      // ~
        addiu   a2, sp, 0x0020                      // a2 = address of setup floats
        or      a3, r0, r0                          // a3 = 0
        sw      r0, 0x0000(a2)                      // set up float 1
        sw      r0, 0x0004(a2)                      // set up float 2

        lw      t0, 0x0084(a0)                      // t0 = player struct
        lw      t0, 0x0ADC(t0)	                    // t7 = clanpot charge level
	    lli     at, 0x0002                          // at = shuriken
        beq     at, t0, _shuriken                   // branch if shuriken
		lli     at, 0x0003                          // at = boomerang
        beq     at, t0, _boomerang                  // branch if boomerang
        lli     at, 0x0004                          // at = clanbomb
        beq     at, t0, _clanbomb                   // branch if clanbomb
        nop

        _gem:
        jal     Item.Gem.SPAWN_ITEM                 // create gem item
        sw      r0, 0x0008(a2)                      // set up float 3
        b       _continue                           // continue after item is created
        addiu   sp, sp, 0x0030                      // deallocate stack space

        _shuriken:
        jal     Item.Shuriken.SPAWN_ITEM     		// create shuriken item
        sw      r0, 0x0008(a2)                      // set up float 3
        b       _continue                           // continue after item is created
        addiu   sp, sp, 0x0030                      // deallocate stack space

        _boomerang:
        jal     Item.Boomerang.SPAWN_ITEM     		// create boomerang item
        sw      r0, 0x0008(a2)                      // set up float 3
        b       _continue                           // continue after item is created
        addiu   sp, sp, 0x0030                      // deallocate stack space

        _clanbomb:
        jal     Item.ClanBomb.SPAWN_ITEM     		// create clanbomb item
        sw      r0, 0x0008(a2)                      // set up float 3
        addiu   sp, sp, 0x0030                      // deallocate stack space

        _continue:
        beqz    v0, _finish                         // if no item spawned, don't try to assign it!
        or      a0, v0, r0                          // a0 = item object
        lw      a1, 0x0008(sp)                      // a1 = player object
        jal     0x80172CA4                          // initiate item pickup
        addiu   sp, sp, -0x0030                     // allocate stack space (0x80172CA4 is unsafe)
        addiu   sp, sp, 0x0030                      // deallocate stack space

        lw      a0, 0x0008(sp)                      // a0 = player object
        lw      t0, 0x0084(a0)                      // a1 = player struct

        _finish:
        li      t0, Item.skip_item_spawn_gfx_.flag
        sw      r0, 0x0000(t0)                      // clear skip gfx flag

        lw      ra, 0x0004(sp)                      // restore ra
        addiu   sp, sp, 0x0010                      // deallocate stack space

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Patch which prevents Marina's items from being destroyed when landing on floors.
    scope prevent_item_despawn_: {
        OS.patch_start(0xEE644, 0x80173C04)
        j       prevent_item_despawn_
        nop
        _return:
        OS.patch_end()

        // s0 = item struct
        lw      t0, 0x000C(s0)              // t0 = item_id
        lli     t1, Item.Gem.id        		// t1 = gem/bomb id
        beq     t1, t0, _j_0x80173C28       // skip if item = gem/bomb
        lli     t1, Item.Shuriken.id        // t1 = shuriken id
        beq     t1, t0, _j_0x80173C28       // skip if item = shuriken
        lli     t1, Item.Boomerang.id       // t1 = boomerang id
        beq     t1, t0, _j_0x80173C28       // skip if item = boomerang
        lli     t1, Item.ClanBomb.id        // t1 = clanbomb id
        beq     t1, t0, _j_0x80173C28       // skip if item = boomerang
        nop

        beq     v1, at, _j_0x80173C1C       // original line 1 (destroys item if it has landed 4 times)
        nop

        j       _return                     // return
        nop

        _j_0x80173C1C:
        j       0x80173C1C                  // jump to original branch location
        nop

        _j_0x80173C28:
        j       0x80173C28                  // skips random despawning
        lw      t0, 0x02CC(s0)              // original line 2
    }

    // @ Description
    // Patch which gets the charge level for projectiles when absorbed by Marina's down special
    // 800E5330
    // fp - projectile special struct
    // s7 - player struct
    // a0 = projectile special struct
    scope projectile_absorb_charge_: {
        OS.patch_start(0x60B30, 0x800E5330)
        j       projectile_absorb_charge_
        nop
        _return:
        OS.patch_end()

        lw      t5, 0x0850(s7)              // t5 = reflect hitbox
        lli     at, Reflect.reflect_type.CUSTOM // at = custom reflect id
        lhu     t6, 0x0002(t5)              // t6 = reflect id
        bne     at, t6, _end                // skip if reflect id != CUSTOM
        lhu     t6, 0x0000(t5)              // t6 = custom reflect id
        beqz    t6, _end                    // skip if custom id = franklin badge
        nop

        // if here, custom reflect type is 1
        jal     get_projectile_level_       // v0 = projectile charge level
        nop

        sw      v0, 0x0B24(s7)              // add_charge = projectile charge level

        _end:
        jal     0x800E31B4                  // original line 1
        lw      a3, 0x00B8(sp)              // original line 2
        j       _return
        nop
    }

    // @ Description
    // Patch which gets the charge level for items when absorbed by Marina's down special
    // 800E5A10
    // fp - item special struct
    // s7 - player struct
    scope item_absorb_charge_: {
        OS.patch_start(0x61210, 0x800E5A10)
        j       item_absorb_charge_
        nop
        _return:
        OS.patch_end()

        lw      t5, 0x0850(s7)              // t5 = reflect hitbox
        lli     at, Reflect.reflect_type.CUSTOM // at = custom reflect id
        lhu     t6, 0x0002(t5)              // t6 = reflect id
        bne     at, t6,_end                 // skip if reflect id != CUSTOM
        lhu     t6, 0x0000(t5)              // t6 = custom reflect id
        beqz    t6, _end                    // skip if custom id = franklin badge
        nop

        // if here, custom reflect type is 1
        jal     get_item_level_             // v0 = item charge level
        nop

        sw      v0, 0x0B24(s7)              // add_charge = item charge level

        _end:
        jal     0x800E3860                  // original line 1
        lw      a3, 0x00B8(sp)              // original line 2
        j       _return
        nop
    }

    // @ Description
    // Returns the clanpot charge level for a projectile.
    // @ Arguments
    // a0 - projectile special struct
    // @ Returns
    // v0 - clanpot charge level
    scope get_projectile_level_: {
        lw      t0, 0x000C(a0)              // t0 = projectile id
        lli     at, 0x2                     // at = charge shot id
        beq     t0, at, _charge_shot        // branch if projectile = charge shot
        lli     at, 0x0005                  // at = yoshi egg id
        beql    t0, at, _end                // branch if projectile = yoshi egg...
        lli     v0, 0x0002                  // ...and return 2
        lli     at, 0x0007                  // at = link boomerang id
        beql    t0, at, _end                // branch if projectile = link boomerang...
        lli     v0, 0x0002                  // ...and return 2
        lli     at, 0x000B                  // at = pikachu thunder head id
        beql    t0, at, _end                // branch if projectile = pikachu thunder head...
        lli     v0, 0x0002                  // ...and return 2
        lli     at, 0x000C                  // at = pikachu thunder tail id
        beql    t0, at, _end                // branch if projectile = pikachu thunder tail...
        lli     v0, 0x0002                  // ...and return 2
        lli     at, 0x0012                  // at = arwing shot id
        beql    t0, at, _end                // branch if projectile = arwing shot...
        lli     v0, 0x0004                  // ...and return 4
        lli     at, 0x1005                  // at = pirate land cannonball id
        beql    t0, at, _end                // branch if projectile = pirate land cannonball...
        lli     v0, 0x0004                  // ...and return 4
        b       _end                        // for all other projectiles...
        lli     v0, 0x0001                  // ...return 1

        _charge_shot:
        lw      t0, 0x02A4(a0)              // t0 = charge shot level
        lli     at, 0x0007                  // at = 7 (full charge)
        beql    t0, at, _end                // branch if charge shot is full charge...
        lli     v0, 0x0003                  // ...and return 3
        sltiu   v0, t0, 0x0004              // return 1 if charge level < 4
        beqzl   v0, _end                    // branch if charge level >= 4...
        lli     v0, 0x0002                  // ...and return 2

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Returns the clanpot charge level for a projectile.
    // @ Arguments
    // a0 - item special struct
    // @ Returns
    // v0 - clanpot charge level
    scope get_item_level_: {
        lw      t0, 0x000C(a0)              // t0 = item id
        li      t1, item_charge_table       // t1 = item_charge_table
        addu    t1, t1, t0                  // t1 = item charge table + id
        jr      ra                          // return
        lbu     v0, 0x0000(t1)              // v0 = return value from table
    }

    // @ Description
    // Table which holds charge level for all items.
    item_charge_table:
    db 2    // 0x00 - Crate
    db 2    // 0x01 - Barrel
    db 1    // 0x02 - Capsule
    db 1    // 0x03 - Egg
    db 0    // 0x04 - Maxim Tomato
    db 0    // 0x05 - Heart
    db 0    // 0x06 - Star
    db 2    // 0x07 - Beam Sword
    db 2    // 0x08 - Home Run Bat
    db 1    // 0x09 - Fan
    db 2    // 0x0A - Star Rod
    db 1    // 0x0B - Ray Gun
    db 1    // 0x0C - Fire Flower
    db 4    // 0x0D - Hammer
    db 4    // 0x0E - Motion Sensor Bomb
    db 4    // 0x0F - Bobomb
    db 1    // 0x10 - Bumper
    db 1    // 0x11 - Green Shell
    db 2    // 0x12 - Red Shell
    db 2    // 0x13 - Pokeball
    db 1    // 0x14 - Pk Fire Pillar
    db 1    // 0x15 - Bomb
    db 0    // 0x16 - Pow Block
    db 0    // 0x17 - Aerial Bumper
    db 0    // 0x18 - Piranha Plant
    db 0    // 0x19 - Target
    db 2    // 0x1A - RTTF Bomb
    db 0    // 0x1B - Chansey
    db 0    // 0x1C - Electrode
    db 0    // 0x1D - Charmander
    db 0    // 0x1E - Venusaur
    db 0    // 0x1F - Porygon
    db 0    // 0x20 - Onix
    db 0    // 0x21 - Snorlax
    db 0    // 0x22 - Goldeen
    db 0    // 0x23 - Meowth
    db 0    // 0x24 - Charizard
    db 0    // 0x25 - Beedrill
    db 0    // 0x26 - Blastoise
    db 0    // 0x27 - Chansey
    db 0    // 0x28 - Starmie
    db 0    // 0x29 - Hitmonlee
    db 0    // 0x2A - Koffing
    db 0    // 0x2B - Clefairy
    db 0    // 0x2C - Mew
	// custom items
    db 0    // 0x2D - CloakingDevice
    db 0    // 0x2E - SuperMushroom
    db 0    // 0x2F - PoisonMushroom
    db 3    // 0x30 - BlueShell
    db 0    // 0x31 - Lightning
    db 2    // 0x32 - DekuNut
    db 0    // 0x33 - FranklinBadge
    db 1    // 0x34 - PitFall
	// custom stage items
    db 0    // 1 - KlapTrap
    db 0    // 2 - RobotBee
    db 0    // 3 - Car
	// custom pokemon
	// custom character items
    db 1    // 1 - Gem
    db 2    // 2 - Shuriken
    db 3    // 3 - Boomerang
    db 4    // 4 - ClanBomb
    db 1    // 5 - Waddle Dee
    db 1    // 6 - Waddle Doo
    db 1    // 7 - Gordo
    OS.align(4)

    // @ Description
    // table containing arguments for air_to_ground_
    // format is XXXXYYYYZZZZ0000
    // XXXX = action id for ground transition
    // YYYY = argument 4 for change action subroutine
    // ZZZZ = bool for setting the bitflag at 0x018C in the player struct
    air_to_ground_table:
    // ground action id                     // change action arg 4  // set_bitflag      // padding
    dh Marina.Action.DSPG_Begin             ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPG_Begin
    dh Marina.Action.DSPG_Wait              ; dh  0x0097            ; dh OS.TRUE        ; dh 0          // DSPG_Wait
    dh Marina.Action.DSPG_Absorb            ; dh  0x0097            ; dh OS.TRUE        ; dh 0          // DSPG_Absorb
    dh Marina.Action.DSPG_End               ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPG_End
    dh Marina.Action.DSPG_Pull              ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPG_Pull
    dh Marina.Action.DSPG_Pull_Fail         ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPG_Pull_Fail
    dh Marina.Action.DSPG_Stow              ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPG_Stow

    // @ Description
    // table containing arguments for ground_to_air_
    // format is XXXXYYYYZZZZ0000
    // XXXX = action id for ground transition
    // YYYY = argument 4 for change action subroutine
    // ZZZZ = bool for setting the bitflag at 0x018C in the player struct
    ground_to_air_table:
    // aerial action id                     // change action arg 4  // set_bitflag      // padding
    dh Marina.Action.DSPA_Begin             ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPA_Begin
    dh Marina.Action.DSPA_Wait              ; dh  0x0097            ; dh OS.TRUE        ; dh 0          // DSPA_Wait
    dh Marina.Action.DSPA_Absorb            ; dh  0x0097            ; dh OS.TRUE        ; dh 0          // DSPA_Absorb
    dh Marina.Action.DSPA_End               ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPA_End
    dh Marina.Action.DSPA_Pull              ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPA_Pull
    dh Marina.Action.DSPA_Pull_Fail         ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPA_Pull_Fail
    dh Marina.Action.DSPA_Stow              ; dh  0x0092            ; dh OS.FALSE       ; dh 0          // DSPA_Stow

    OS.align(16)
    absorb_struct:
    dh 0x0001                               // index to custom reflect routine table
    dh Reflect.reflect_type.CUSTOM          // reflect type
    dw 0x00000000                           // not sure
    float32 0                               // offset x
    float32 500                             // offset y
    float32 450                             // offset z
    float32 650                             // size x
    float32 650                             // size y
    float32 650                             // size z
    dw 0x18000000                     // hp value maybe
}