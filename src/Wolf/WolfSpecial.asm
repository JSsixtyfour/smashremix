// WolfSpecial.asm

// This file contains subroutines used by Wolf's special moves.

scope WolfNSP {
 // @ Description
    // main subroutine for Wolf's Blaster
    scope main: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
        swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)
        addu    a2, a0, r0
        lw      v0, 0x0084(a0)                      // loads player struct

        or      a3, a0, r0
        lw      t6, 0x017C(v0)
        beql    t6, r0, _idle_transition_check      // this checks moveset variables to see if projectile should be spawned
        lw      ra, 0x0014(sp)
        mtc1    r0, f0
        sw      r0, 0x017C(v0)                      // clears out variable so he only fires one shot
        addiu   a1, sp, 0x0020
        swc1    f0, 0x0020(sp)                      // x origin point
        swc1    f0, 0x0024(sp)                      // y origin point
        swc1    f0, 0x0028(sp)                      // z origin point
        lw      a0, 0x0928(v0)
        sw      a3, 0x0030(sp)
        jal     0x800EDF24                          // generic function used to determine projectile origin point
        sw      v0, 0x002C(sp)
        lw      v0, 0x002C(sp)
        lw      a3, 0x0030(sp)
        sw      r0, 0x001C(sp)
        or      a0, a3, r0
        addiu   a1, sp, 0x0020
        jal     projectile_stage_setting            // this sets the basic features of a projectile
        lw      a2, 0x001C(sp)
        lw      a2, 0x0034(sp)
        lw      ra, 0x0014(sp)

        // checks frame counter to see if reached end of the move
        _idle_transition_check:
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
        addiu   sp, sp, 0x0040
        jr      ra
        nop

        projectile_stage_setting:
        addiu   sp, sp, -0x0050
        sw      a2, 0x0038(sp)
        lw      t7, 0x0038(sp)
        sw      s0, 0x0018(sp)
        li      s0, _blaster_fireball_struct       // load blaster format address


        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, _blaster_projectile_struct      // load projectile addresses
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)
        //sw      t0, 0x0008(a1)        // would revise default pointer, which has another pointer, which is to the hitbox data
        jal     0x801655C8                // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        bnez    v0, _projectile_branch
        sw      v0, 0x0028(sp)
        beq     r0, r0, _end_stage_setting
        or      v0, r0, r0

        _projectile_branch:
        lw      v1, 0x0084(v0)
        lui     t2, 0x3f80              // load 1(fp) into f2
        addiu   at, r0, 0x0001
        mtc1    r0, f4
        sw      t2, 0x029C(v1)           // save 1(fp) to projectile struct free space
        lw      t3, 0x0000(s0)
        sw      t3, 0x0268(v1)

        OS.copy_segment(0xE3268, 0x2C)
        lw      t6, 0x002C(sp)
        lwc1    f6, 0x0020(s0)           // load speed (integer)
        lw      v1, 0x0024(sp)
        lw      t7, 0x0044(t6)
        mul.s   f8, f0, f6
        lwc1    f12, 0x0020(sp)
        mtc1    t7, f10
        nop
        cvt.s.w f16, f10
        mul.s   f18, f8, f16
        jal     0x800303F0
        swc1    f18, 0x0020(v1)
        lwc1    f4, 0x0020(s0)
        lw      v1, 0x0024(sp)
        lw      a0, 0x0028(sp)
        mul.s   f6, f0, f4
        swc1    f6, 0x0024(v1)
        lw      t8, 0x0074(a0)
        lwc1    f10, 0x002C(s0)
        lw      t9, 0x0080(t8)
        // This ensures the projectile faces the correct direction
        jal     0x80167FA0
        swc1    f10, 0x0088(t9)
        lw      v0, 0x0028(sp)

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop

        // this subroutine seems to have a variety of functions, but definetly deals with the duration of move and result at the end of duration
        blaster_duration:
        addiu   sp, sp, -0x0024
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        swc1    f10, 0x0024(sp)
        lw      a0, 0x0084(a0)
        sw      a0, 0x001C(sp)

        _continue:
        addiu   t8, r0, r0          // used to use free space area, but for no apparent reason, affects graphics
        //lw      t8, 0x029C(a0)
        li      t0, _blaster_fireball_struct
        addu    v0, r0, t0
        lw      a1, 0x000C(v0)
        lw      a2, 0x0004(v0)
        lw      t1, 0x0020(sp)
        addiu   t2, r0, r0          // used to use free space area, but for no apparent reason, effects graphics
        lw      v1, 0x0074(t1)
        or      v0, r0, r0
        lwc1    f8, 0x0020(a0)      // load current speed
        lui     at, 0x3F84          // speed multiplier (accel) loaded in at (1.03125)
        mtc1    at, f6              // move speed multiplier to floating point register
        mul.s   f8, f8, f6          // speed multiplied by accel


        lw      at, 0x0004(t0)      // load max speed
        mtc1    at, f6
        lw      at, 0x029C(a0)      // load multiplier that is typically one, unless reflected
        mtc1    at, f10
        mul.s   f6, f6, f10
        c.le.s  f8, f6
        nop
        bc1f    _scaling
        swc1    f6, 0x0020(a0)      // if speed is greater than max rightward velocity, save max speed
        neg.s   f6, f6
        c.le.s  f8, f6
        nop
        bc1t    _scaling
        swc1    f6, 0x0020(a0)      // if speed is less than max leftward velocity, save max speed
        swc1    f8, 0x0020(a0)      // save new speed amount to projectile hitbox information

        _scaling:
        // v1 = projectile joint 1
        // a0 = projectile struct
        // t1 = projectile object
        lwc1    f6, 0x0020(a0)      // ~
        abs.s   f6, f6              // f6 = absolute current speed
        lui     at, 0x41B0          // ~
        mtc1    at, f8              // f8 = initial speed (currently 22)
        lui     at, 0x3E80          // ~
        mtc1    at, f10             // f10 = 0.25
        add.s   f6, f6, f8          // ~
        add.s   f6, f6, f8          // ~
        add.s   f6, f6, f8          // ~
        mul.s   f6, f6, f10         // f6 = (current speed + 66) * 0.25
        div.s   f6, f6, f8          // f6 = x size multiplier (adjusted current speed / initial speed)
        swc1    f6, 0x0040(v1)      // store x size multiplier to projectile joint
        add.s   f10, f10, f10       // f10 = 0.5
        mul.s   f6, f6, f10         // ~
        add.s   f6, f6, f10         // f6 = (x size multiplier * 0.5) + 0.5
        add.s   f10, f10, f10       // f10 = 1.0
        div.s   f6, f10, f6         // f6 = y size multiplier (1.0 / ((x size multiplier * 0.5) + 0.5))
        swc1    f6, 0x0044(v1)      // store y size multiplier to projectile joint

        _end_duration:
        lw      ra, 0x0014(sp)
        lwc1    f10, 0x0024(sp)
        addiu   sp, sp, 0x0024
        jr      ra
        nop

        _hitbox_end:
        OS.copy_segment(0xE396C, 0x38)
        // swc1 f4, 0x0148(v0)
        OS.copy_segment(0xE39A8, 0x30)

        // this subroutine determines the behavior of the projectile upon reflection
        blaster_reflection:
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        sw      a0, 0x0018(sp)
        lw      a0, 0x0084(a0)      // loads active projectile struct
        lw      t0, 0x0008(v0)
        addiu   t7, r0, Character.id.WOLF
        bnel    t0, t7, _standard
        lui     t7, 0x3F80          // load normal reflect multiplier if not wolf and thereby top speed of wolf projectile will not increase
        li      t7, 0x3FC90FDB      // load reflect multiplier
        _standard:
        mtc1    t7, f4              // move reflect multiplier to floating point
        sw      t7, 0x029C(a0)      // save multiplier to free space to increase max speed
        lw      t7, 0x0008(a0)
        li      t0, _blaster_fireball_struct // load fireball struct to pull parameters
        lw      t0, 0x0000(t0)      // loads max duration from fireball struct
        sw      t0, 0x0268(a0)      // save max duration to active projectile struct current remaining duration
        lw      a1, 0x0084(t7)      // loads reflective character's struct

        // Before determining new direction, multiply speed.
        lw      t6, 0x0044(a1)      // loads player direction 1 or -1 in fp
        lwc1    f0, 0x0020(a0)      // loads projectile velocity
        mul.s   f0, f0, f4          // multiply current speed by reflection speed multiplier
        nop
        swc1    f0, 0x0020(a0)      // save new speed
        nop
        jal     0x801680EC          // go to the default subroutine that determines direction
        nop

        // old routine for reference, was based on 0x801680EC
        // lw      t6, 0x0044(a1)      // loads direction 1 or -1 in fp
        // lwc1    f0, 0x0020(a0)      // loads velocity
        // mul.s   f0, f0, f4          // multiply current speed by reflection speed multiplier (not original logic)
        // mtc1    r0, f10             // move 0 to f10
        // mtc1    t6, f4              // place direction in f4
        // nop
        // cvt.s.w f6, f4              // cvt to sw floating point
        // mul.s   f8, f0, f6          // change direction of projectile to the opposite direction via multiplication
        // //  lw      t6, 0x0004(t0)      // load max speed
        // //  mtc1    t6, f6              // move max speed to f6
        // c.lt.s  f8, f10             // current velocity compared to 0 (less than or equal to)
        // nop
        // bc1f    _branch              // jump if velocity is greater than 0
        // nop
        // neg.s   f16, f0
        // swc1    f16, 0x0020(a0)     // save velocity

        _branch:
        lw      a0, 0x0018(sp)
        lw      v0, 0x0084(a0)      // load active projectile struct
        mtc1    r0, f6              // move 0 to f6
        lwc1    f4, 0x0020(v0)      // load current velocity of projectile
        c.le.s  f6, f4              // compare 0 to current velocity to see if now traveling leftward
        nop
        bc1f    _left               // jump if 0 is greater than velocity, this means the projectile is traveling leftward
        nop
        li        at, 0x3FC90FDB
        mtc1      at, f8
        lw      t6, 0x0074(a0)
        j       _end_reflect
        swc1    f8, 0x0034(t6)
        _left:
        li        at, 0xBFC90FDB
        mtc1      at, f10
        lw      t7, 0x0074(a0)
        swc1    f10, 0x0034(t7)
        _end_reflect:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        or      v0, r0, r0
        jr      ra
        nop


        _blaster_projectile_struct:
        dw 0x00000000                   // this has some sort of bit flag to tell it to use secondary type display list?
        dw 0x00000000
        dw Character.WOLF_file_6_ptr    // pointer to file
        dw 0x00000000                   // 00000000
        dw 0x12480000                   // rendering routine?
        dw blaster_duration             // duration (default 0x80168540) (samus 0x80168F98)
        dw 0x80175914                   // collision (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80175958                   // after_effect 0x801691FC, this one is used when grenade connects with player
        dw 0x80175958                   // after_effect 0x801691FC, used when touched by player when object is still, by setting to null, nothing happens
        dw 0x8016DD2C                   // determines behavior when projectile bounces off shield, this uses Master Hand's projectile coding to determine correct angle of graphic (0x8016898C Fox)
        dw 0x80175958                   // after_effect                // rocket_after_effect 0x801691FC
        dw blaster_reflection           // OS.copy_segment(0x1038FC, 0x04)            // this determines reflect behavior (default 0x80168748)
        dw 0x80175958                   // This function is run when the projectile is used on ness while using psi magnet
        OS.copy_segment(0x103904, 0x0C) // empty


        _blaster_fireball_struct:
        dw 100                          // 0x0000 - duration (int)
        float32 200                     // 0x0004 - max speed
        float32 22                      // 0x0008 - min speed
        float32 0                       // 0x000C - gravity
        float32 0                       // 0x0010 - bounce multiplier
        float32 0                       // 0x0014 - rotation angle
        float32 0                       // 0x0018 - initial angle (ground)
        float32 0                       // 0x001C   initial angle (air)
        float32 22                      // 0x0020   initial speed
        dw Character.WOLF_file_6_ptr    // 0x0024   projectile data pointer
        dw 0                            // 0x0028   unknown (default 0)
        float32 0                       // 0x002C   palette index (0 = mario, 1 = luigi)
        OS.copy_segment(0x1038A0, 0x30)
        }

   // @ Description
   // Subroutine which handles air collision for neutral special actions
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
    // Subroutine which handles ground to air transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0008(v0)              // load character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground


        addiu   a1, r0, 0x00E1              // a1 = equivalent ground action for current air action
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }
    }



// Subroutines for Up Special
scope WolfUSP {
    constant X_SPEED(0x435c)                // current setting - float:100.0
    constant Y_SPEED(0x42f0)                // current setting - float:40.0
    constant LANDING_FSM(0x3E80)            // current setting - float:0.25
    constant Y_INPUT(0x3f4c)                // current setting - float:0.5
    constant B_PRESSED(0x40)                // bitmask for b press


    // @ Description
    // Subroutine which runs when Wolf initiates an up special (both ground).
    // Changes action, and sets up initial variable values.
    scope initial_ground: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop
        _change_action:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00E4              // a1 = 0xE4
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
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
    // Subroutine which runs when Wolf initiates an up special (both ground).
    // Changes action, and sets up initial variable values.
    scope initial_air: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop
        _change_action:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00E3              // a1 = 0xE3
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
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
    // Holds each player's button presses from the previous frame.
    // Used to add a single frame input buffer to shorten.
    button_press_buffer:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4

    // @ Description
    // Main Subroutine which runs when Wolf initiates an up special (both ground and air) based on 8015BD24.
    // Deals with transition to part 2 of action and thereby, shortening.
    scope main_ground: {
        addiu   sp, sp, -0x0020              // ~
        sw      ra, 0x0014(sp)              // ~

        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer
        sw      t3, 0x0018(sp)              // save button_pressed to stack

        li      a1, usp_2_transition_ground
        jal     0x800D9480
        nop



        lui     at, 0x4190                  // at = 18.0
        mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _end                        // skip if haven't reached frame 18
        nop

        lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if (!B_PRESSED)
        nop
        //lh      t8, 0x01BE(a2)              // t8 buttons_pressed
        //andi    t8, t8, Joypad.B            // t8 = 0x0040 if (B_PRESSED); else t8 = 0
        //beqz    t8, _end                  // skip if (!B_PRESSED)
        //nop
        jal     usp_2_transition_ground
        nop

        _end:
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main Subroutine which runs when Wolf initiates an up special (both ground and air) based on 8015BD24.
    // Deals with transition to part 2 of action and thereby, shortening.
    scope main_air: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x0014(sp)              // ~

        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer
        sw      t3, 0x0018(sp)              // save button_pressed to stack

        li      a1, usp_2_transition_air
        jal     0x800D9480
        nop

        lui     at, 0x4190                  // at = 18.0
        mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _end                        // skip if haven't reached frame 18
        nop

        lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if (!B_PRESSED)
        nop

        //lh      t8, 0x01BE(a2)              // t8 buttons_pressed
        //andi    t8, t8, Joypad.B            // t8 = 0x0040 if (B_PRESSED); else t8 = 0
        //beqz    t8, _end                  // skip if (!B_PRESSED)
        //nop

        jal     usp_2_transition_air
        nop

        _end:
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main Subroutine which runs when Wolf initiates an up special (both ground and air) based on 8015C750.
    // Deals with transition to part 2 of action and thereby, shortening.
    scope usp_2_transition_ground: {
        addiu   sp, sp, -0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0003
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)
        addiu   a1, r0, 0x00E8              // insert action in a1
        addiu   a2, r0, 0x0000
        jal     0x800E6F24                  // change action routine
        lui     a3, 0x3f80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015BFBC
        lw      a0, 0x0020(sp)



        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main Subroutine which runs when Wolf initiates an up special (both ground and air) based on 8015C750.
    // Deals with transition to part 2 of action and thereby, shortening.
    scope usp_2_transition_air: {
        addiu   sp, sp, -0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0003
        sw      a0, 0x0020(sp)
        sw      t6, 0x0010(sp)
        addiu   a1, r0, 0x00E6              // insert action in a1
        addiu   a2, r0, 0x0000
        jal     0x800E6F24                  // change action routine
        lui     a3, 0x3f80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015BFBC
        lw      a0, 0x0020(sp)



        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Wolf's up special.
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
    // Subroutine which handles movement for Wolf's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement?
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)
        constant END_MOVE(0x4)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4

        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        beq     t0, t1, _continue           // branch if temp variable 3 = BEGIN
        nop
        li      t8, air_control_            // t8 = air_control_

        _continue:
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
        nop
        // slow x movement
        //lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        //lui     t0, 0x3F60                  // ~
        //mtc1    t0, f2                      // f2 = 0.875
        //mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        //swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze x position
        sw      r0, 0x0048(s0)              // y velocity = 0
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:

        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _check_move         // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f4                      // f4 = X_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C3(s0)              // ~
        mtc1    t0, f0                      // ~
        cvt.s.w f0, f0                      // f0 = stick_y
        mtc1    r0, f2                      // f2 = 0
        lui     t0, Y_SPEED                 // load default y speed
        //c.le.s  f2, f0                      // ~
        //nop                                 // ~
        //bc1f    _apply_movement             // branch if stick_y  =< 0
        mtc1    t0, f2                      // put default y speed into f2

        // update y velocity based on stick_y
        // f0 = stick_y
        lui     t0, Y_INPUT                 // ~
        mtc1    t0, f6                      // f4 = 0.4
        mul.s   f6, f0, f6                  // f4 = y velocity input(stick_y * 0.5)
        add.s   f2, f2, f6                  // f2 = y velocity (default y velocity + y velocity input)
        // update x velocity based on y velocity (higher y = lower x)
        lui     t0, 0x3E60                  // ~
        mtc1    t0, f0                      // f0 = 0.21875
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = X_SPEED - (y velocity * 0.21875)

        _apply_movement:
        // f2 = x velocity
        // f4 = y velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f4, f0, f4                  // f2 = x velocity * direction
        swc1    f2, 0x004C(s0)              // store y velocity
        swc1    f4, 0x0048(s0)              // store x velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps
        b       _end                        // end
        nop


        _check_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_end_move     // skip if temp variable 3 != MOVE
        nop
        // update y velocity to negate gravity
        lwc1    f0, 0x0058(s1)              // f0 = gravity
        lwc1    f2, 0x004C(s0)              // f2 = y velocity
        add.s   f2, f2, f0                  // f2 = y velocity + GRAVITY
        swc1    f2, 0x004C(s0)              // store updated y velocity

        _check_end_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != END_MOVE
        nop

        lw      t1, 0x0A88(s0)              // t1 = overlay settings
        li      t0, 0x7FFFFFFF              // t2 = bitmask
        and     t1, t1, t0                  // ~
        sw      t1, 0x0A88(s0)              // disable colour overlay bit

        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        //sw        r0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze y position
        lwc1    f0, 0x004C(s0)              // f0 = current y velocity
        mul.s   f0, f0, f2                  // f0 = y velocity * 0.875
        swc1    f0, 0x004C(s0)              // y velocity = (y velocity * 0.875)
        //lw      t1, 0x09C8(s0)              // t1 = attribute pointer
       // lw      t1, 0x0058(t1)              // t1 = fall speed acceleration
        //sw      t1, 0x004C(s0)              // overwrite y velocity with fall speed acceleration value
        //sw      r0, 0x004C(s0)              // y velocity = 0
        OS.copy_segment(0x548F4, 0x58)      // AT 0X800d90f0

        _end:
        lw      t0, 0x0024(sp)              // ~
        lw      t1, 0x0028(sp)              // ~
        lwc1    f0, 0x002C(sp)              // ~
        lwc1    f2, 0x0030(sp)              // ~
        lwc1    f4, 0x0034(sp)              // load t0, t1, f0, f2, f4
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Wolf's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        lw      a2, 0x004C(t6)              // a2 = air acceleration
        lw      a3, 0x0050(t6)              // a3 = max air speed
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        _check_move:
        ori     t1, r0, physics_.MOVE       // t1 = MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = MOVE
        lui     a2, 0x3CC0                  // on branch, a2 = 0.0234375
        _check_end_move:
        ori     t1, r0, physics_.END_MOVE   // t1 = END_MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = END_MOVE
        lui     a2, 0x3C00                  // on branch, a2 = 0.0078125

        _continue:
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
    // Subroutine which handles collision for Wolf's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Wolf.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Main subroutine for Wolf's up special part 2.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Wolf's landing FSM value and disable the interrupt flag.
    scope main_2: {
        // Copied the first 8 lines of subroutine 0x8015C750
        addiu   sp, sp, -0x0038
        sw      ra, 0x0024(sp)
        sw      v1, 0x0028(sp)
        sw      a0, 0x002C(sp)

        jal     _wolf_slash_graphics
        addu    v1, r0, a2                  // load player struct into v1
        lw      v1, 0x0028(sp)
        lw      a0, 0x002C(sp)

        idle_transition:
        lwc1    f6, 0x0078(a0)
        mtc1    r0, f4
        lui     a1, 0x3f80
        or      a2, r0, r0
        c.le.s  f6, f4
        addiu   a3, r0, 0x0001
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      t6, 0x0018(sp)              // interrupt flag saved

        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        lw      a0, 0x002C(sp)
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        lw      v1, 0x0028(sp)
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop

        _wolf_slash_graphics:
        addiu   sp, sp, -0x0028
        sw      ra, 0x0014(sp)
        sw      v1, 0x0020(sp)
        sw      a0, 0x0024(sp)
        lw      a0, 0x0004(v1)
        lw      t6, 0x017C(v1)              // load moveset variable
        bnez    t6, skip_graphics           // don't redo graphics routine after completion
        nop

        jal     PokemonAnnouncer.slash_announcement_
        nop

        jal     0x80101F84                  // falcon punch animation struct routine
        sw      v1, 0x0020(sp)              // save player struct
        lw      v1, 0x0020(sp)              // load player struct
        lbu     t1, 0x018F(v1)
        ori     t2, t1, 0x0010
        sb      t2, 0x018F(v1)
        addiu   t1, r0, 0x0001
        sb      t1, 0x017C(v1)

        skip_graphics:
        lw      v1, 0x0020(sp)              // load player struct
        addiu   t0, r0, 0x0002
        bne     t6, t0, _end_graphics
        nop

        jal     0x800E9C3C                  // routine that ends graphics
        nop

        _end_graphics:
        lw      a0, 0x0024(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }


    }

    scope WolfDSP {

    // @ Description
    // Subroutine which handles physics for Wolf's down special.
    // Copy of subroutine 0x8015CC64, which is the physics subroutine for Fox's Down Special.
    // Essentially it sets the speed to different values
    scope physics_: {
        OS.copy_segment(0xD76A4, 0x28)
        beq     r0, r0, _branch
        sw      t7, 0x0B28(a3)
        lui     a1, 0x4000
        lw      a2, 0x005C(t8)
        jal     0x800D8D68
        sw      a3, 0x001C(sp)
        lw      a3, 0x001C(sp)
        _branch:
        OS.copy_segment(0xD76EC, 0x34)
    }

    }
