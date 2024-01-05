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
}
