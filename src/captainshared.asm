// captainshared.asm

// This file contains shared functions by Captain Falcon Clones.

scope CaptainShared {
    // Original Falcon Punch animation struct: 0xA9AEC
    // We are going to change the way it renders so that we can scale the gfx.
    OS.patch_start(0xA9AF5, 0x0)
    db  0x1C                                // originally 0x1A (does not scale)
    OS.patch_end()
    OS.patch_start(0xA9B00, 0x0)
    dw  Size.falcon.punch.render_routine_   // originally 0x800CB4B0
    OS.patch_end()

    // Original Falcon Kick animation struct: 0xA9AC4 / 0x8012E2C4
    // We are going to change the way it updates so that we can scale the gfx.
    OS.patch_start(0xA9AD4, 0x8012E2D4)
    dw  Size.falcon.kick.update_routine_    // scales gfx based on size (originally 0x800FD5D8)
    OS.patch_end()

    kick_anim_struct:
    dw  0x060F0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x08)
    dw  Size.falcon.kick.update_routine_    // scales gfx based on size
    OS.copy_segment(0xA9AD8, 0x14)

    punch_anim_struct:
    dw  0x020F0000
    dw  Character.GND_file_8_ptr
    dw  0x501C0000
    OS.copy_segment(0xA9AF8, 0x0008)
    dw  Size.falcon.punch.render_routine_
    OS.copy_segment(0xA9B04, 0x0010)

    entry_anim_struct:
    dw  0x060A0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)

    kick_anim_struct_JFALCON:
    dw  0x060F0000
    dw  Character.JFALCON_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x08)
    dw  Size.falcon.kick.update_routine_    // scales gfx based on size
    OS.copy_segment(0xA9AD8, 0x14)

    punch_anim_struct_JFALCON:
    dw  0x020F0000
    dw  Character.JFALCON_file_8_ptr
    dw  0x501C0000
    OS.copy_segment(0xA9AF8, 0x0008)
    dw  Size.falcon.punch.render_routine_
    OS.copy_segment(0xA9B04, 0x0010)
    
    kick_anim_struct_DRAGONKING:
    dw  0x060F0000
    dw  Character.DRAGONKING_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x08)
    dw  Size.falcon.kick.update_routine_    // scales gfx based on size
    OS.copy_segment(0xA9AD8, 0x14)
    
    punch_anim_struct_DRAGONKING:
    dw  0x020F0000
    dw  Character.DRAGONKING_file_8_ptr
    dw  0x501C0000
    OS.copy_segment(0xA9AF8, 0x0008)
    dw  Size.falcon.punch.render_routine_
    OS.copy_segment(0xA9B04, 0x0010)

    // THIS WILL NEED UPDATED ON REIMPORT
    slash_anim_struct_WOLF:
    dw  0x020F0000
    dw  Character.WOLF_file_9_ptr
    dw  0x501C0000
    OS.copy_segment(0xA9AF8, 0x0008)
    dw  Size.falcon.punch.render_routine_
    dw  0x000008F0                  // customized because this animation was added to an existing file, these are offsets
    dw  0x00000A90                  // customized because this animation was added to an existing file, these are offsets
    dw  0x00000000                  // beginning of graphic within file, normally 0, but unique since added to another file
    dw  0x00000ABC                  // customized because this animation was added to an existing file, these are offsets

    usmash_anim_struct_MTWO:
    dw  0x020F0000
    dw  Character.MTWO_file_7_ptr
    dw  0x501A0000
    dw  0x00000000
    dw  0x800FD5D8
    dw  0x800CB4B0
    dw  0x00000040
    dw  0x000001E8
    dw  0x00000000
    dw  0x0000021C

    entry_anim_struct_JFALCON:
    dw  0x060A0000
    dw  Character.JFALCON_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)
    
    entry_anim_struct_DRAGONKING:
    dw  0x060A0000
    dw  Character.DRAGONKING_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)

	entry_anim_struct_BOWSER:
    dw  0x060A0000
    dw  Character.BOWSER_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x10)
	dw	0x00001E80					// Clown car alters this, relates to model hierarchy I believe
	OS.copy_segment(0xA9EC0, 0x0C)

    entry_anim_struct_CONKER:
    dw  0x060A0000
    dw  Character.CONKER_file_8_ptr
    OS.copy_segment(0xA9EAC, 0x10)
	dw	0x00000F60					// Greg's Hand alters this, relates to model hierarchy I believe
	OS.copy_segment(0xA9EC0, 0x0C)

    // @ Description
    // loads a different animation struct when Ganondorf uses his down special.
    scope get_kick_anim_struct_: {
        OS.patch_start(0x7D6E4, 0x80101EE4)
        j       get_kick_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()

        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, kick_anim_struct        // a0 = kick_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      a0, kick_anim_struct_JFALCON        // a0 = kick_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        
        ori     t1, r0, Character.id.DRAGONKING    // t1 = id.JFALCON
        li      a0, kick_anim_struct_DRAGONKING        // a0 = kick_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop

        li      a0, 0x8012E2C4              // original line 1/3 (load falcon kick animation struct)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop

        beqz    v0, _finish                 // skip if no gfx object was created
        lw      t7, 0x0018(sp)              // t7 = player object

        // apply scale first frame
        jal     Size.falcon.kick.update_routine_._apply_scale
        or      a0, v0, r0                  // a0 = gfx object

        _finish:
        j       _return                     // return
        nop
    }

    // @ Description
    // loads a different animation struct when Ganondorf uses his neutral special.
    scope get_punch_anim_struct_: {
        OS.patch_start(0x7D790, 0x80101F90)
        j       get_punch_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()

        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(v1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(v1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, punch_anim_struct       // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop

        ori     t1, r0, Character.id.WOLF   // t1 = id.WOLF
        li      a0, slash_anim_struct_WOLF  // a0 = slash_anim_struct
        beq     t0, t1, _end                // end if character id = WOLF
        nop

        ori     t1, r0, Character.id.MTWO   // t1 = id.MTWO
        li      a0, usmash_anim_struct_MTWO // a0 = usmash_anim_struct
        beq     t0, t1, _end                // end if character id = MTWO
        nop

        jal     PokemonAnnouncer.firepunch_announcement_
        nop

        ori     t1, r0, Character.id.JFALCON // t1 = id.JFALCON
        li      a0, punch_anim_struct_JFALCON // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        
        ori     t1, r0, Character.id.DRAGONKING // t1 = id.JFALCON
        li      a0, punch_anim_struct_DRAGONKING // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        li      a0, 0x8012E2EC              // original line 1/3 (load falcon punch animation struct)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop
        j       _return                     // return
        nop
    }

    // @ Description
    // loads a different animation struct when Ganondorf uses his entry animation.
    scope get_entry_anim_struct_: {
        OS.patch_start(0x7EDA0, 0x801035A0)
        j       get_entry_anim_struct_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, entry_anim_struct       // a0 = entry_anim_struct
        beq     t0, t1, _gnd                // end if character id = GND
        nop


	    ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      a0, entry_anim_struct_JFALCON       // a0 = entry_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        
        ori     t1, r0, Character.id.DRAGONKING    // t1 = id.JFALCON
        li      a0, entry_anim_struct_DRAGONKING      // a0 = entry_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop

		ori     t1, r0, Character.id.BOWSER   // t1 = id.BOWSER
        li      a0, entry_anim_struct_BOWSER       // a0 = entry_anim_struct_BOWSER
        beq     t0, t1, _end                // end if character id = BOWSER, this is used for Clown Copter
        nop

        ori     t1, r0, Character.id.CONKER        // t1 = id.CONKER
        li      a0, entry_anim_struct_CONKER       // a0 = entry_anim_struct_CONKER
        beq     t0, t1, _end                       // end if character id = CONKER, this is used for Clown Copter
        nop

        li      a0, 0x8012E6A4              // original line 1/3 (load entry animation struct?)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       _return                     // return
        nop

		_gnd:
		lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       0x801035AC                  // return
        nop
    }

    // @ Description
    // loads the correct file pointer when Ganondorf uses his entry animation.
    scope get_entry_file_ptr_: {
        OS.patch_start(0x7EDBC, 0x801035BC)
        j       get_entry_file_ptr_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      s2, Character.GND_file_7_ptr // a0 = Character.GND_file_7_ptr
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      s2, Character.JFALCON_file_7_ptr // a0 = Character.JFALCON _file_7_ptr
        beq     t0, t1, _end                // end if character id = JFALCON
        nop

		ori     t1, r0, Character.id.BOWSER    // t1 = id.BOWSER
        li      s2, Character.BOWSER_file_7_ptr // a0 = Character.BOWSER _file_7_ptr
        beq     t0, t1, _end                // end if character id = BOWSER, this is used for Clown Copter
        nop

        ori     t1, r0, Character.id.CONKER    // t1 = id.BOWSER
        li      s2, Character.CONKER_file_8_ptr // a0 = Character.CONKER _file_8_ptr
        beq     t0, t1, _end                // end if character id = CONKER, this is used for Greg's Hand
        nop

        li      s2, 0x8013103C              // original line 1/2 (load falcon file 7 ptr)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // @ Description
    // adds a check for Ganondorf to a routine which determines which bone the punch graphic is
    // attached to
    scope get_punch_bone_: {
         OS.patch_start(0x7D7C8, 0x80101FC8)
        j       get_punch_bone_
        nop
        nop
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()

        // a1 = character id
        // at = id.CAPTAIN
        beq     a1, at, _end                // end if character id = CAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.NCAPTAIN
        beq     a1, at, _end                // end if character id = NCAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.GND
        beq     a1, at, _end                // end if character id = GND
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.JFALCON
        beq     a1, at, _end                // end if character id = JFALCON
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.DRAGONKING
        beq     a1, at, _end                // end if character id = JFALCON
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.WOLF
        beq     a1, at, _end                // end if character id = WOLF
        lw      v1, 0x0928(a0)              // v1 = wolf hand bone struct
        ori     at, r0, Character.id.MTWO
        beq     a1, at, _end                // end if character id = MTWO
        lw      v1, 0x0930(a0)              // v1 = mewtwo hand bone struct

        lw      v1, 0x0960(a0)              // v1 = other bone struct (used for kirby presumably)

        _end:
        j       _return
        nop
    }

	// @ Description
    // loads the correct t7 digit for Clown Car
    scope clown_car_animation1: {
        OS.patch_start(0x7EDC8, 0x801035C8)
        j       clown_car_animation1
        ori     t7, r0, Character.id.BOWSER    // t1 = id.BOWSER
        _return:
        OS.patch_end()

        lw		s5, 0x0008(s0)
		beq		t7, s5, _bowser				// load correct T7 value for BOWSER
		lui		t7, 0x0000					// original line 1

        ori     t7, r0, Character.id.CONKER    // t1 = id.CONKER
        beq		t7, s5, _conker				// load correct T7 value for CONKER
		lui		t7, 0x0000					// original line 1

        j       _return                     // return
        addiu	t7, t7, 0x6200				// original line 2

		_bowser:
		j		_return
		addiu	t7, t7, 0x248C				// animation related change

        _conker:
		j		_return
		addiu	t7, t7, 0x188C				// animation related change
    }

	// @ Description
    // loads the correct s3 and s4 digits for Clown Car animation
    scope clown_car_animation2: {
        OS.patch_start(0x7EDF4, 0x801035F4)
        j       clown_car_animation2
        ori     s1, r0, Character.id.BOWSER    // s1 = id.BOWSER
        _return:
        OS.patch_end()

        lw		s0, 0x0008(s0)              // load player id
		beq		s0, s1, _bowser				// load correct values for BOWSER
		ori     s1, r0, Character.id.CONKER    // s1 = id.CONKER

		beq		s0, s1, _conker				// load correct values for CONKER
		nop

        addiu	s4, s4, 0x6598				// original line 1
		j       _return                     // return
        addiu	s3, s3, 0x6518				// original line 2

		_bowser:
		addiu	s4, s4, 0x2530
		j		_return
		addiu	s3, s3, 0x24C0

        _conker:
		addiu	s4, s4, 0x1930
		j		_return
		addiu	s3, s3, 0x18C0
    }


    // @ Description
    // Extends a check on ID that occurs when Kirby absorbs or ejects a power.
    scope kirby_power_change_: {
        OS.patch_start(0xDC90C, 0x80161ECC)
        j       kirby_power_change_
        nop
        _kirby_power_change_return:
        OS.patch_end()

        beq     v0, at, j_0x80161EF8        // original line 1, modified to use jump
        lli     at, Character.id.JFALCON    // at = JFALCON
        beq     v0, at, j_0x80161EF8        // if JFALCON, take Falcon branch
        lli     at, Character.id.GND        // at = GND
        beq     v0, at, j_0x80161EF8        // if GND, take Falcon branch
        nop

        j       _kirby_power_change_return
        addiu   at, r0, 0x000A              // original line 2

        j_0x80161EF8:
        j       0x80161EF8
        nop
    }

    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        // if currently doing NSP, hold UP
        lw at, 0x24(a0) // at = action id
        lli t0, Action.CAPTAIN.FalconPunchAir
        beq at, t0, _hold_up
        nop

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        mtc1 r0, f0 // guarantee f0 = 0

        // check closest ledge in X
        scope ledge_check: {
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x54(a0) // load nearest RIGHT ledge X

            sub.s f6, f6, f2
            abs.s f6, f6 // f6 = abs(distance) to left ledge

            sub.s f8, f8, f2
            abs.s f8, f8 // f8 = abs(distance) to right ledge

            c.le.s f6, f8
            nop
            bc1f _right
            nop

            _left:
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y
            
            b _check_end
            nop

            _right:
            lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
            lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

            _check_end:
        }

        sub.s f14, f6, f2 // f14 = x diff
        sub.s f12, f8, f4 // f12 = y diff

        // check if too close to use nsp
        lui at, 0x457A
        mtc1 at, f22 // f22 = 4000.0

        abs.s f16, f14 // f16 = abs(x distance to ledge)

        c.le.s f16, f22 // if distance to ledge is lower than 4000.0
        nop
        bc1t _end // do not go for NSP if already close to ledge
        nop

        // check if up high
        lui at, 0xC2C8
        mtc1 at, f22 // f22 = -100.0

        c.le.s f12, f22 // if 100 units or more above ledge
        nop
        bc1f _end // do not go for NSP if not high enough
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.JumpAerialF // right as we doublejump, use NSP
        bne at, t0, _end // not doing double jump, skip
        nop

        // Check if X speed is not max. Skip when not at max air speed
        lw t6, 0x9C8(a0) // t6 = attribute pointer
        lwc1 f22, 0x50(t6) // f22 = max air speed X
        lwc1 f24, 0x54(t6) // f24 = air friction
        sub.s f22, f22, f24 // f22 = max air speed X - air friction
        lwc1 f24, 0x48(a0) // f24 = X speed
        abs.s f24, f24 // f24 = |X speed|

        c.lt.s f24, f22 // if x speed < max x speed
        nop
        bc1t _end // skip
        nop

        lw at, 0x001C(a0) // get current frame of current action
        sltiu at, at, 20 // at = 1 if action frame < 20
        bnez at, _nsp // if action frame < 20, go for NSP
        nop

        b _end // no conditions matched, skip
        nop

        _nsp:
        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP_TOWARDS // arg1 = NSP

        b _end
        nop

        // when doing NSP, hold up and towards ledge
        _hold_up:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = NULL so our inputs are not overridden

        lli at, 0x50 // max stick Y value (up)
        sb at, 0x01C9(a0) // save CPU stick y

        c.lt.s f14, f0 // if x diff < 0
        nop
        bc1t _hold_left // if x diff < 0, hold left
        nop

        _hold_right:
        lli at, 0x50 // max stick X value (right)
        b _apply_x // apply X value
        nop
        
        _hold_left:
        addiu at, r0, 0xFFB0 // max stick X value (left)

        _apply_x:
        sb at, 0x01C8(a0) // save CPU stick x

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.FALCON, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JFALCON, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.DRAGONKING, 0x4)
    dw recovery_logic; OS.patch_end()
    // Character.table_patch_start(recovery_logic, Character.id.GND, 0x4)
    // dw recovery_logic; OS.patch_end()

    scope cpu_attack_weight: {
        // s0 = character struct
        // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
        // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
        OS.routine_begin(0x20)

        // Check CPU level
        lbu t0, 0x13(s0) // t0 = cpu level
        addiu t0, t0, -10 // t0 = 0 if level 10
        bnez t0, _end // if not lv10, perform original logic
        nop

        lw t0, 0x0(s2) // t0 = input id
        addiu at, r0, AI.ATTACK_TABLE.USMASH.INPUT
        beq t0, at, _uair_upsmash
        addiu at, r0, AI.ROUTINE.DASH_GRAB
        beq t0, at, _uair_upsmash
        addiu at, r0, AI.ROUTINE.DASH_USMASH
        beq t0, at, _uair_upsmash
        addiu at, r0, AI.ATTACK_TABLE.USPG.INPUT
        beq t0, at, _usp
        nop
        b _end // no attack matched
        nop

        _uair_upsmash:
        // usmash and uair more often in general
        lui at, 0x4000 // at = 2.0
        mtc1 at, f4
        b _end
        mul.s f2, f2, f4 // f2 = new weight

        _usp:
        // do not usp if opponent is 100 units or more below us
        lw t4, 0x1CC+0x6C(s0) // opponent struct
        lw at, 0x78(s0) // at = location vector
        lwc1 f4, 0x4(at) // f4 = our Y position
        lw at, 0x78(t4) // at = opponent location vector
        lwc1 f6, 0x4(at) // f6 = opponent Y position
        sub.s f4, f6, f4 // f4 = opponent Y - our Y
        lui at, 0xC2C8 // at = -100.0
        mtc1 at, f6 // f6 = -100.0
        // if not allow, set f2 (odds) to 0 and skip to end
        c.le.s f6, f4 // if opponent is 100 units or more below us
        nop
        bc1t _usp_allow
        nop
        // if here, opponent is below us. Set odds to 0
        b _end
        mtc1 r0, f2 // f2 = 0.0

        _usp_allow:
        // usp more often vs shielding opponents
        lw t1, 0x24(t4) // opponent's current action
        addiu at, r0, Action.Shield
        beq t1, at, _usp_continue
        addiu at, r0, Action.ShieldStun
        beq t1, at, _usp_continue
        addiu at, r0, Action.ShieldOn
        beq t1, at, _usp_continue
        nop
        b _end // opponent not shielding, skip
        nop
        _usp_continue:
        lui at, 0x42C8 // at = 100.0
        b _end
        mtc1 at, f2 // f2 = new weight (override)

        _end:
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_attack_weight, Character.id.FALCON, 0x4)
    dw cpu_attack_weight; OS.patch_end()
    Character.table_patch_start(cpu_attack_weight, Character.id.JFALCON, 0x4)
    dw cpu_attack_weight; OS.patch_end()

    scope cpu_post_process_falcon: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.CAPTAIN.FalconDive
        beq t0, at, _point_to_target
        lli t0, Action.CAPTAIN.FalconDiveEnd2
        beq t0, at, _point_to_target
        nop
        b _end // no actions matched
        nop

        _point_to_target:
        // if recovering with usp, skip this logic
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // skip if not above clipping to not mess up recovery
        nop

        // here, if we're not facing the opponent we hold the correct direction for a turnaround
        // otherwise just point towards the opponent to chase
        lw t0, 0x44(a0) // t0 = facing direction

        lwc1 f6, 0x01CC+0x60(a0) // f6 = target X
        lw at, 0x78(a0) // load location vector
        lwc1 f2, 0x0(at) // f2 = location X

        sub.s f14, f6, f2 // f14 = x diff

        mtc1 r0, f0 // guarantee f0 = 0
        c.lt.s f14, f0 // if x diff < 0
        nop
        bc1t _opponent_left // if x diff < 0, opponent is to the left
        nop

        _opponent_right:
        bgtz t0, _facing_opponent // if facing right already, just point to target
        lli at, 0x50 // max stick X value (right)
        b _apply_x // apply X value
        nop
        
        _opponent_left:
        bltz t0, _facing_opponent // if facing left already, just point to target
        addiu at, r0, 0xFFB0 // min stick X value (left)

        _apply_x:
        sb at, 0x01C8(a0) // save CPU stick x
        sb r0, 0x01C9(a0) // CPU stick y = 0
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = NULL so our inputs are not overridden
        b _end
        nop

        _facing_opponent:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_post_process, Character.id.FALCON, 0x4)
    dw cpu_post_process_falcon; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JFALCON, 0x4)
    dw cpu_post_process_falcon; OS.patch_end()
}
