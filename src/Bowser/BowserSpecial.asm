// BowserSpecial.asm

// This file contains subroutines used by Bowser's special moves.

// @ Description
// Subroutines for Neutral Special
scope BowserNSP {
    // @ Description
    // Initial subroutine for Bowser's grounded neutral special.
    // This is based on Yoshi's Neutral special code, for no reason other than the fact Bowser is based on Yoshi, much is probably unnecessary. I have added portions of initial subroutines used when using a fireflower.
    scope ground_initial_: {
        addiu   sp, sp, 0xFFD8      // based on yoshi's = 8015E740
        sw      ra, 0x001C(sp)
        lw      v0, 0x0084(a0)

        sw      r0, 0x017C(v0)      // from fireflower initial coding

        addiu   t6, r0, 0x0001      // altered form of item initial coding
        sw      r0, 0x0B18(v0)      // used
        sw      t6, 0x0B1C(v0)
        sw      t6, 0x0B20(v0)
        sw      r0, 0x0B24(v0)      // used
        sw      r0, 0x0B28(v0)      // used
        sw      r0, 0x0B2C(v0)      // used
		ori		a1, r0, Character.id.GBOWSER	// load Giga Bowser ID for check
		lw		t6, 0x0008(v0)		// load character id
		bne	    t6, a1, _bowser	    // branch for everyone else but G Bowser ammo
        addiu   t6, r0, 0x0028      // setting initial ammo amount for GBOWSER
        sw      t6, 0x0B30(v0)      // I store ammo here, could potentially be unsafe, but seems to be used by other no conflicting things

        _bowser:
        // lui     t6, 0x8016
        // addiu   t6, t6, 0xE57C

        // sw      t6, 0x0A0C(v0)
        sw      a0, 0x0028(sp)
        sw      r0, 0x0010(sp)

        // kirby id check to select proper action
        lw		a2, 0x0008(v0)		        // load character id
        ori		a1, r0, Character.id.KIRBY	// load Kirby ID for check
		beq 	a1, a2, _kirby_action	    // branch for Kirby Action
        lli     a1, Kirby.Action.BOWSER_NSP_Ground           // Kirby Fire Breath Action ID
        ori		a1, r0, Character.id.JKIRBY	// load Kirby ID for check
        beq 	a1, a2, _kirby_action	    // branch for Kirby Action
        lli     a1, Kirby.Action.BOWSER_NSP_Ground              // Kirby Fire Breath Action ID
        addiu   a1, r0, 0x00E4
        _kirby_action:
        addiu   a2, r0, 0x0000
        lui     a3, 0x3F80
        jal     0x800E6F24
        sw      v0, 0x0024(sp)
        addiu   a1, r0, r0
        //lui     a1, 0x8016
        //addiu   a1, a1, 0xE83C
        //jal     0x8015E310
        //lw      a0, 0x0024(sp)
        jal     0x800E0830
        lw      a0, 0x0028(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Initial subroutine for Bowser's aerial neutral special.
    // This is based on Yoshi's Neutral special code, for no reason other than the fact Bowser is based on Yoshi, much is probably unnecessary. I have added portions of initial subroutines used when using a fireflower.
    scope air_initial_: {
        addiu   sp, sp, 0xFFD8      // based on yoshi's = 8015E79C
        sw      ra, 0x001C(sp)
        lw      v0, 0x0084(a0)

        sw      r0, 0x017C(v0)      // from fireflower initial coding

        addiu   t6, r0, 0x0001      // altered form of item initial coding
        sw      r0, 0x0B18(v0)      // used
        sw      t6, 0x0B1C(v0)
        sw      t6, 0x0B20(v0)
        sw      r0, 0x0B24(v0)      // used
        sw      r0, 0x0B28(v0)      // used
        sw      r0, 0x0B2C(v0)      // used
		ori		a1, r0, Character.id.GBOWSER	// load Giga Bowser ID for check
		lw		t6, 0x0008(v0)		// load character id
		bne	    t6, a1, _bowser	    // branch for everyone but G Bowser ammo
		addiu	t6, r0, 0x0028		// setting gbowser initial ammo
		
        sw      t6, 0x0B30(v0)      // I store ammo here, could potentially be unsafe, but seems to be used by other no conflicting things

        _bowser:
        //lui     t6, 0x8016
        //addiu   t6, t6, 0xE588

        //sw      t6, 0x0A0C(v0)
        sw      a0, 0x0028(sp)
        sw      r0, 0x0010(sp)
        ori		a1, r0, Character.id.KIRBY	// load Kirby ID for check
		lw		a2, 0x0008(v0)		        // load character id
		beq 	a1, a2, _kirby_action	    // branch for Kirby Action
        lli     a1, Kirby.Action.BOWSER_NSP_Air              // Kirby Fire Breath Action ID
        ori		a1, r0, Character.id.KIRBY	// load Kirby ID for check
        ori		a1, r0, Character.id.JKIRBY	// load Kirby ID for check
        beq 	a1, a2, _kirby_action	    // branch for Kirby Action
        lli     a1, Kirby.Action.BOWSER_NSP_Air              // Kirby Fire Breath Action ID
        addiu   a1, r0, 0x00E7
        _kirby_action:
        addiu   a2, r0, 0x0000
        lui     a3, 0x3F80
        jal     0x800E6F24
        sw      v0, 0x0024(sp)
        lui     a1, 0x8016
        addiu   a1, a1, 0xE880
        //jal     0x8015E310
        //lw      a0, 0x0024(sp)
        jal     0x800E0830
        lw      a0, 0x0028(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Main subroutine for Bowser's neutral special, heavily based on Fireflower routine located at 0x80147434.
    scope main_: {
        addiu   sp, sp, 0xFF80
        sw      ra, 0x002C(sp)
        sw      s0, 0x0028(sp)
        sw      a0, 0x0080(sp)

        jal     idletransition_                     // this is a jump to what was the main subroutine of character using fireflower, it's just used to transition to idle
        nop

        lw      s0, 0x0084(a0)

        BowserNSP_part1_:
        addiu   t0, r0, 0x0001
        lhu     t7, 0x01BC(s0)          // load current button presses
        lhu     t8, 0x01B6(s0)          // originally 0x01B4, which would be an number used to compare for an A button press, instead of B
        and     t9, t7, t8

        bnel    t9, r0, button1_        // begin wind down process if not pressing B
        OS.copy_segment(0xC1E9C, 0x0C)

        button1_:
        slti    at, v0, 0x0014

        beq     at, r0, button2_        // will begin wind down if 0x0014 frames since pressing B
        OS.copy_segment(0xC1EB0, 0x0C)

        button2_:
        slti    at, v0, 0x0014

        beql    at, r0, button3_        // another branch contingent on button presses
        nop

        // lw      v0, 0x084C(s0)       // this originally pulled a ram address which contained the given fireflowers object struct, unnecessary now
        lhu     t2, 0x01BE(s0)          // load current button presses
        lhu     t3, 0x01B6(s0)          // originally 0x01B4, which would be an number used to compare for an A button press, instead of B
        and     t4, t2, t3

        beql    t4, r0, button3_        // another branch related to button presses
        OS.copy_segment(0xC1ED8, 0x0C)

        button3_:
        // beql    v0, r0, fireloop1_           // reliant on pointer that is typically filled when holding an item
        // lw      ra, 0x002C(sp)
        lw      t5, 0x017C(s0)                  // this loads the 5400 moveset command data, which in this move is done to signify the transition to the flame portion of the move

        beql    t5, r0, fireloopcheck1_         // this branch is to determine if we are at the beginning (no flames), middle (produce flame projectile), and end (no flames) of the move, jumps to end basically
        lw      t1, 0x0B24(s0)

        //      lw      t6, 0x0084(v0)          // this shouldn't be necessary anymore without need for fireflower object
        addiu   t9, r0, 0x0001
        addiu   t8, r0, 0x0002
        //      sw      t6, 0x0078(sp)          // this shouldn't be necessary anymore without need for fireflower object
        lw      t7, 0x0B24(sp)
        addiu   t3, r0, 0x000C

        bnel    t7, r0, graphics1_              // branch should be taken every time except first frame as it is used for certain initial graphical effects and such
        sw      t9, 0x0074(sp)

        beq     r0, r0, graphics1_
        sw      t8, 0x0074(sp)

        sw      t9, 0x0074(sp)                  // unclear purpose of this line as it doesn't seem like it can ever be read
        graphics1_:
        lw      t0, 0x0B20(s0)
        addiu   t1, t0, 0xFFFF

        bnez    t1, fireflower_attack_loop1_    // this branch is responsibile for determining the loop rate of projectile/graphic creation
        sw      t1, 0x0B20(s0)

        sw      t3, 0x0B20(s0)
        //      lw      t4, 0x0078(sp)                  // shouldn't be necessary with new ammo coding
        lw      t6, 0x0074(sp)
        lui     t7, 0x8019
        ori     t5, r0, Character.id.GBOWSER
        lw      t4, 0x0008(s0)                      // load character ID
        beq     t4, t5, _post_ammo
        lw      t5, 0x0B30(s0)                      // load ammo (modified from original coding)

        ori     t5, r0, Character.id.BOWSER
        beq     t4, t5, _post_ammo
        lhu     t5, 0x0ADE(s0)                      // load ammo (modified from original coding)

        // kirby

        lhu     t5, 0x0AE2(s0)                      // load ammo (modified from original coding)

        _post_ammo:
        lui     t4, 0x8019
        addiu   t7, t7, 0x8684
        // slti    at, t5, t6

        // beq     at, r0, ammo_jump1_                 // checks current ammo to see if a projectile should be spawned
        bnez	t5, ammo_jump1_
		addiu   t4, t4, 0x8690

        // Out of Ammo Smoke Generation
        // The code below is for the generation of smoke when Bowser runs out of ammo
        addiu   a3, sp, 0x0068
		sw      r0, 0x0000(a3)						// clearing out a3 to prevent crash
        addiu   t3, r0, 0x0001
        addiu   a1, r0, 0x000B

        OS.copy_segment(0xC1F80, 0x20)

        // hard code the x/y/z position of the smoke to align it with Bowser's mouth
        lw		t9, 0x0008(s0)
		ori		t0, r0, Character.id.GBOWSER	// load Giga Bowser ID for check
		beq		t9, t0, _gbowser_smoke
        ori		t0, r0, Character.id.KIRBY	    // load KIRBY ID for check
		beq		t9, t0, _kirby_smoke
        ori		t0, r0, Character.id.JKIRBY	    // load JKIRBY ID for check
		beq		t9, t0, _kirby_smoke
		nop


        lui     t9, 0x42A2                          // smoke x position = 81
        sw      t9, 0x0000(a3)                      // x location of smoke saved
        lui     t9, 0x4398                          // smoke y position = 304
        sw      t9, 0x0004(a3)                      // y location of smoke saved
        lui     t9, 0x4382                          // smoke z position = 260
        j		_generate_graphic
		sw      t9, 0x0008(a3)                      // z location of smoke saved		
		
        _gbowser_smoke:
		lui     t9, 0xC1f0                          // smoke x position = -30
        sw      t9, 0x0000(a3)                      // x location of smoke saved
        lui     t9, 0x43d4                          // smoke y position = 424
        sw      t9, 0x0004(a3)                      // y location of smoke saved
        lui     t9, 0x4382                          // smoke z position = 260
        j		_generate_graphic
        sw      t9, 0x0008(a3)                      // z location of smoke saved

        _kirby_smoke:
		lui     t9, 0xC396                          // smoke x position = -300
        sw      t9, 0x0000(a3)                      // x location of smoke saved
        lui     t9, 0xC2C3                          // smoke y position = -97.5
        sw      t9, 0x0004(a3)                      // y location of smoke saved
        lui     t9, 0x0000                          // smoke z position = 0
        sw      t9, 0x0008(a3)                      // z location of smoke saved
        lli     a2, 0x0010                          // hard code joint

        _generate_graphic:
        jal     0x800EABDC                          // generic 2D Graphic Effect Generation, creates smoke effect here. This is taken if ammo check fails
        sw      t2, 0x0014(sp)
        jal     0x800269C0                          // "Play FGM" plays smoke sound, takes this route if ammo check fails
        addiu   a0, r0, 0x0030
        beq     r0, r0, ammo_jump2_                 // jump skips much of the effects that would be loaded if ammo check was successful
        lw      t8, 0x0B1C(s0)



        ammo_jump1_:            // Bowser's code will jump to here when Bowser has enough ammo to produce flames

        // This portion produces the smoke when Bowser has ammo to produce flames
        lw      t6, 0x0000(t4)
        addiu   a3, sp, 0x005C
        addiu   a1, r0, 0x000B
		sw      r0, 0x0000(a3)							// clearing out a3 to prevent crash
        sw      t6, 0x0000(t4)
        lw      t5, 0x0004(t4)
        or      a2, r0, r0
        sw      t5, 0x0004(a3)
        lw      t6, 0x0008(t4)
        sw      t6, 0x0008(a3)

        OS.copy_segment(0xC1FDC, 0x14)

        jal     0x800EABDC                          // generic 2D Graphic Effect Generation, creates little back smoke effect here. This is taken if ammo check succeeds
        sw      t7, 0x0014(sp)
        jal     0x800269C0                          // "Play FGM" plays blowing effect if ammo check succeeds
        addiu   a0, r0, 0x001A

        fireflower_attack_loop1_:
        lw      t8, 0x0B1C(s0)                      // loads current step in attack loop

        ammo_jump2_:

        OS.copy_segment(0xC2004, 0x0C)

        bnez    t9, post_BowserNSP_part2_           // branch determines if projectile should be spawned based on loop rate
        sw      t9, 0x0B1C(s0)
        sw      t1, 0x0B1C(s0)
        jal     BowserNSP_part2_                    // this jump is only taken if spawning a projectile is possible, there still some additional checks and other collateral effects taken care of here.
        lw      a1,     0x0074(sp)

        // POST PROJECTILE PORTION - This portion is read after the projectile has been either skipped or generated

        post_BowserNSP_part2_:
        lw      t2, 0x017C(s0)
        addiu   at, r0, 0x0001
        // lw       t3, 0x0078(sp)                  // shouldn't be necessary with new ammo function

        bne     t2, at, skip_initial                // branch's purpose is to skip the initial graphic effects spawned after the first frame (801475E4 of fireflower original code)
        lw      t5, 0x0074(sp)
        lw      at, 0x0008(s0)
        ori     t4, r0, Character.id.GBOWSER
        beq     at, t4, _post_character_check
        lw      t4, 0x0B30(s0)                      // load ammo (modified from original coding)
        ori     t4, r0, Character.id.BOWSER
        beq     at, t4, _post_character_check
        lhu     t4, 0x0ADE(s0)                      // load ammo (modified from original coding)

        // kirby
        lhu     t4, 0x0AE2(s0)                      // load ammo (modified from original coding)

        _post_character_check:
        OS.copy_segment(0xC203C, 0x0C)

        bnel    at, r0, unknowncheck2_              // 801476CC, doesn't seem to work right with revised ammo and probably relates to when fireflower is started without ammo, not necessary
        addiu   t0, r0, 0x0002

        OS.copy_segment(0xC2050, 0x74)

        //lw      a2, 0x033C(t6)                      // similarly to flames this loaded a joint equivalent to the hand, located at 80147685
        sw      v0, 0x0010(sp)
        lw      t7, 0x0044(s0)
        sw      r0, 0x001C(sp)
        sw      t8, 0x0018(sp)

        // jal          0x800EABDC                          // generic subroutine used to load 2D graphic effects, used for white spark here. I'm replacing it with a moveset command for simplicitie's sake.
        sw          t7, 0x0014(sp)

        OS.copy_segment(0xC20E0, 0x2C)

        unknowncheck2_:
        sw      t0, 0x017C(s0)
        lw      a0, 0x0080(sp)

        jal     0x8000BB04                          // this generic subroutine is used to stop and restart the animation used for this attack
        addiu   a1, r0, 0x0000

        skip_initial:
        lw      t1, 0x0B24(s0)
        fireloopcheck1_:
        slti    at, t1, 0x0005

        bnel    at, r0, fireloop1_                  // this ending branches all have an unclear purpose which relate to a looping function
        lw      ra, 0x002C(sp)

        lw      t2, 0x0B28(s0)

        beql    t2, r0, fireloop1_
        lw      ra, 0x002C(sp)

        lw      t3, 0x0B2C(s0)
        lui     a1, 0x3F80
        slti    at, t3, 0x0014

        bnel    at, r0, fireloop1_                  // possibly related to idle transition?
        lw      ra, 0x002C(sp)

        sw      r0, 0x017C(s0)
        jal     0x8000BB04                          // this generic subroutine is used to stop and restart the animation used for this attack
        lw      a0, 0x0080(sp)

        fireloop1_:
        lw      ra, 0x002C(sp)
        lw      s0, 0x0028(sp)
        addiu   sp, sp, 0x0080
        jr      ra
        nop

        // This second stage of the Bowser's Neutral Special is focused on the projectile and spawning there of, with some other collateral functions. It's heaviliy based on the fireflower function
        // located at 0x801472D4

        BowserNSP_part2_:
        addiu   sp, sp, 0xFFC0
        sw      ra, 0x001C(sp)
        sw      s0, 0x0018(sp)
        lui     t7, 0x8019
        //      lw      t6, 0x084C(a0)              // shouldn't be necessary with new ammo code
        addiu   t7, t7, 0x8678                      // loads hardcoded address that is used to determine flames origin point relative to the character
        lw      t9, 0x0000(t7)
        //      lw      v0, 0x0084(t6)              // shouldn't be necessary with new ammo code

        OS.copy_segment(0xC1D34, 0x20)

        lw      at, 0x0008(s0)
        ori     t0, r0, Character.id.GBOWSER
        beq     at, t0, _branch
        lw      t0, 0x0B30(s0)                      // load ammo (modified from original coding)
        ori     t0, r0, Character.id.BOWSER
        beq     at, t0, _branch
        lhu     t0, 0x0ADE(s0)                      // load ammo (modified from original coding)

        // kirby
        lhu     t0, 0x0AE2(s0)                      // load ammo (modified from original coding)

        _branch:
        slt     at, t0, a1
        bnel    at, r0, smoke_                      // used to breakdown here because at is based on t0, which is based on V0, which is based on T6, which is the fireflower object struct the game can't load. This is another ammo check, which skips much of the code if failed.
        lw      t7, 0x0B24(s0)
        lw      t1, 0x09C8(a0)

        // The below is how the x and y position of flames are set relative to the joint I have set
        // there's a character ID check for kirbys to give them a new location for the flame relative to their joint

        lw		t4, 0x0008(s0)
        lui     a1, 0x4000
        ori		t5, r0, Character.id.KIRBY
		beq		t4, t5, _kirby_set_location_y
        mtc1    a1, f4
        ori		t5, r0, Character.id.JKIRBY
		beq		t4, t5, _kirby_set_location_y
        mtc1    a1, f4

        lui     at, 0x3F80                          // Can be used to increase y location of flames
        mtc1    at, f4

        _kirby_set_location_y:
        lwc1    f6, 0x0000(t1)
        //lui       a1, 0xc4bb                          //
        //mtc1  a1, f8
        lwc1    f8, 0x0030(sp)                  //
        //mtc1  r0, f16
        lwc1    f16, 0x0034(sp)                     //

        div.s   f0, f4, f6
        lw		t4, 0x0008(s0)
		
        lui     a1, 0xc1a0
        ori		t5, r0, Character.id.KIRBY
		beq		t4, t5, _kirby_set_location_x
        mtc1    a1, f4
        ori		t5, r0, Character.id.JKIRBY
		beq		t4, t5, _kirby_set_location_x
        mtc1    a1, f4

        // lwc1    f4, 0x0038(sp)                  // original means of setting x location of flames
        lui     a1, 0x42f0

        _kirby_set_location_x:
        mtc1    a1, f4
        or      a1, a2, r0


        OS.copy_segment(0xC1D88, 0x20)

        lw		t4, 0x0008(s0)
		ori		t5, r0, Character.id.KIRBY
		beq		t4, t5, _kirby_id_2
        addiu   t3, r0, 0x000D                      // this number determines relevant object/joint. Originally this loaded a number from the address in t2 that corresponded to the hand object
        ori		t5, r0, Character.id.JKIRBY
		beq		t4, t5, _kirby_id_2
        addiu   t3, r0, 0x000D
        // lw      t2, 0x09C8(a0)                      // loads a location within the player struct which can be used to determine where the hand object is normally


        addiu   t3, r0, 0x0007                      // this number determines relevant object/joint. Originally this loaded a number from the address in t2 that corresponded to the hand object
        _kirby_id_2:
        sll     t4, t3, 0x2
        addu    t5, a0, t4                          // address related to individual object parts
        lw      a0, 0x08E8(t5)                      // loads location of relevant object part to be used in subsequent generic subroutine
        jal     0x800EDF24                          // Generic function that is at least responsible for determination of the origin point/position of the projectile, register A0 is the object it will spawn at.
        sw      a3, 0x0044(sp)

        OS.copy_segment(0xC1DC4, 0x10)

        bnez    at, projectile_spawn_jump           // purpose of branch is unknown
        or      a2, v0, r0
        addiu   t6, r0, 0x0008
        beq     r0, r0, projectile_spawn_jump
        subu    a2, t6, v0

        projectile_spawn_jump:
		lw		t7, 0x0008(s0)
		ori		t2, r0, Character.id.GBOWSER
		li		ra, _post_projectile
		beq		t7, t2, gbowser_projectile_spawn
		lw      a0, 0x0004(s0)
		

        jal     projectile_spawn                    // begins the actual process of spawning the projectile itself
        lw      a0, 0x0004(s0)

		_post_projectile:
        or      a0, s0, r0                          // post projectile spawning functions begin
        addiu   a1, r0, 0x0006
        jal     0x800E806C                          // unknown purpose
        or      a2, r0, r0
        lw      t7, 0x0B24(s0)                      // loads amount of frames the flame has been active
        smoke_:
        lui     at, 0x0001
        OS.copy_segment(0xC1E08, 0x0C)
        bnez    at, unknowncheck3_                  // possibly related to up and down motion of flame?
        sw      t8, 0x0B24(s0)
        lui     t0, 0x0001
        sw      t0, 0x0B24(s0)
        unknowncheck3_:

        OS.copy_segment(0xC1E24, 0x14)

        bnez    at, unknowncheck4_
        sw      t2, 0x0B18(s0)

        OS.copy_segment(0xC1E40, 0x20)

        unknowncheck4_:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0040
        jr      ra
        nop

        // the necessary structure of the projectile is loaded in at this function based on 8017604C
        projectile_spawn:
        OS.copy_segment(0xF0A8C, 0x20)  // was 8C
        //      lw      t8, 0x084C(t7)  // shouldn't be necessary with new ammo code
        lui     t2, 0x0000
        addiu   t2, t2, 0x0360
        //      lw      t9, 0x0084(t8)  // shouldn't be necessary with new ammo code
        sll     t3, a2, 0x2
        //      sw      t9, 0x002C(sp)      // shouldn't be necessary with new ammo code

        OS.copy_segment(0xF0AC4, 0x54)      // somewhere in here flame direction is set, this was 801760B0 in fireflower

        jal     hitbox_generation           // jump which creates hitbox used by flames
        swc1    f10, 0x0024(sp)
        //      lw      v0, 0x002C(sp)      // shouldn't be necessary with new ammo code
        lw      t5, 0x003C(sp)                      // load amount to subtract from ammo
        lw      t6, 0x0008(s0)
        ori     t4, r0, Character.id.GBOWSER
        beq     t6, t4, gbowser_subtract
        lw      t4, 0x0B30(s0)                      // load ammo (modified from original coding)

        ori     t4, r0, Character.id.BOWSER
        beq     t6, t4, bowser_subtract
        lhu     t4, 0x0ADE(s0)                      // load ammo (modified from original coding)

        // kirby
        lhu     t4, 0x0AE2(s0)                      // load ammo (modified from original coding)
        subu    t6, t4, t5                          // subtract from ammo amount
        beq     r0, r0, _end
        sh      t6, 0x0AE2(s0)                      // save ammo (modified from original coding)


        bowser_subtract:
        subu    t6, t4, t5                          // subtract from ammo amount
        beq     r0, r0, _end
        sh      t6, 0x0ADE(s0)                      // save ammo (modified from original coding)

        gbowser_subtract:
        //subu    t6, t4, t5                          // subtract from ammo amount
        //sw      t6, 0x0B30(s0)                      // save ammo (modified from original coding)


        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0030
        jr      ra
        nop
        nop
        nop
        nop

        // the hitbox for the projectile is created here and the generic portions of the projectile creation process begin after this point
        // this is based on 80175F48
        hitbox_generation:
        OS.copy_segment(0xF0988, 0x04)
        // s0 = player struct
        // a1 = address of hitbox spawn coordinates
		swc1	f6, 0x0024(sp)
        sw      ra, 0x002C(sp)
        jal     PokemonAnnouncer.flamethrower_announcement_
        nop
        lw      ra, 0x002C(sp)
        lwc1    f4, 0x0044(s0)                        // ~
        cvt.s.w f4, f4                                // f4 = DIRECTION
        lui     at, 0x42C8                            // ~
        mtc1    at, f6                                // f6 = X_OFFSET (0x42C80000 = 100)
        mul.s   f6, f4, f6                            // f6 = X_OFFSET * DIRECTION
        lwc1    f4, 0x0000(a1)                        // f4 = X_POSITION
        add.s   f4, f4, f6                            // f6 = Adjusted X_POSITION
        swc1    f4, 0x0000(a1)                        // save adjusted X_POSITION
        lui     at, 0xC348                            // ~
        mtc1    at, f6                                // f6 = Y_OFFSET (0xC3480000 = -200)
        lwc1    f4, 0x0004(a1)                        // f4 = Y_POSITION
        add.s   f4, f4, f6                            // f6 = Adjusted Y_POSITION
        swc1    f4, 0x0004(a1)                        // save adjusted Y_POSITION

        OS.copy_segment(0xF098C, 0x28)
        bnez    v0, unknowncheck5_
        or      t1, v0, r0
        beq     r0, r0, unknowncheck6_
        or      v0, r0, r0
        unknowncheck5_:
        OS.copy_segment(0xF09C4, 0xB4)
        unknowncheck6_:
        lw      ra, 0x002C(sp)
        lw      s0, 0x0028(sp)
		lwc1	f6, 0x0024(sp)
        addiu   sp, sp, 0x0038
        jr      ra
        nop
		
		// the necessary structure of the projectile is loaded in at this function based on 8017604C
        gbowser_projectile_spawn:
        OS.copy_segment(0xF0A8C, 0x20)  // was 8C
        //      lw      t8, 0x084C(t7)  // shouldn't be necessary with new ammo code
        lui     t2, 0x0000
        addiu   t2, t2, 0x0360
        //      lw      t9, 0x0084(t8)  // shouldn't be necessary with new ammo code
        sll     t3, a2, 0x2
        //      sw      t9, 0x002C(sp)      // shouldn't be necessary with new ammo code

        OS.copy_segment(0xF0AC4, 0x2C)
		lui		v0, 0xBF00					// sets alternate direction
		jal		0x800303F0
		mtc1	v0, f12
		OS.copy_segment(0xF0AF8, 0x20)

        jal     hitbox_generation           // jump which creates hitbox used by flames
        swc1    f10, 0x0024(sp)
        //      lw      v0, 0x002C(sp)      // shouldn't be necessary with new ammo code
        lw      t5, 0x003C(sp)                      // load amount to subtract from ammo

        lw      t6, 0x0008(s0)
        ori     t4, r0, Character.id.GBOWSER
        beq     t6, t4, gbowser_subtract_2
        lw      t4, 0x0B30(s0)                      // load ammo (modified from original coding)

        ori     t4, r0, Character.id.BOWSER
        beq     t6, t4, bowser_subtract_2
        lhu     t4, 0x0ADE(s0)                      // load ammo (modified from original coding)

        // kirby
        lhu     t4, 0x0AE2(s0)                      // load ammo (modified from original coding)
        subu    t6, t4, t5                          // subtract from ammo amount
        beq     r0, r0, _end_section
        sh      t6, 0x0AE2(s0)                      // save ammo (modified from original coding)


        bowser_subtract_2:
        subu    t6, t4, t5                          // subtract from ammo amount
        beq     r0, r0, _end_section
        sh      t6, 0x0ADE(s0)                      // save ammo (modified from original coding)

        gbowser_subtract_2:
        //subu    t6, t4, t5                          // subtract from ammo amount
        //sw      t6, 0x0B30(s0)                      // save ammo (modified from original coding)

        _end_section:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0030
        jr      ra
        nop
        nop
        nop
        nop

        // the hitbox for the projectile is created here and the generic portions of the projectile creation process begin after this point
        // this is based on 80175F48
        // gbowser_hitbox_generation:
        //OS.copy_segment(0xF0988, 0x04)
        // s0 = player struct
        // a1 = address of hitbox spawn coordinates
		// swc1	f6, 0x0024(sp)
        // lwc1    f4, 0x0044(s0)                        // ~
        // cvt.s.w f4, f4                                // f4 = DIRECTION
        // lui     at, 0x42C8                            // ~
        // mtc1    at, f6                                // f6 = X_OFFSET (0x42C80000 = 100)
        //mul.s   f6, f4, f6                            // f6 = X_OFFSET * DIRECTION
        // lwc1    f4, 0x0000(a1)                        // f4 = X_POSITION
        // add.s   f4, f4, f6                            // f6 = Adjusted X_POSITION
        // swc1    f4, 0x0000(a1)                        // save adjusted X_POSITION
        // lui     at, 0xC348                            // ~
        // mtc1    at, f6                                // f6 = Y_OFFSET (0xC3480000 = -200)
        // lwc1    f4, 0x0004(a1)                        // f4 = Y_POSITION
        // add.s   f4, f4, f6                            // f6 = Adjusted Y_POSITION
        // swc1    f4, 0x0004(a1)                        // save adjusted Y_POSITION

		// sw		s0, 0x0028(sp)
		// or		s0, a1, r0
		// sw		ra, 0x002c(sp)
		// sw		a2, 0x0040(sp)
		// li		a1, _gbowser_hitbox_struct
        // or		a2, s0, r0
		// jal		0x801655C8
		// lui		a3, 0x8000
		// lw		t0, 0x0040(sp)
   	    // bnez    v0, g_unknowncheck5_
        // or      t1, v0, r0
        // beq     r0, r0, g_unknowncheck6_
        // or      v0, r0, r0
        // g_unknowncheck5_:
        // OS.copy_segment(0xF09C4, 0xB4)
        // g_unknowncheck6_:
        // lw      ra, 0x002C(sp)
        // lw      s0, 0x0028(sp)
		// lwc1	f6, 0x0024(sp)
        // addiu   sp, sp, 0x0038
        // jr      ra
        // nop

        // idle transition code based on 801472B0, which is used by character's as their main subroutine when using a fireflower
        idletransition_:
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)
        sw      a1, 0x0010(sp)
        sw      a0, 0x000C(sp)
        lui     a1, 0x800E
        jal     0x800D9480
        addiu   a1, a1, 0xEE54
        lw      a0, 0x000C(sp)
        lw      a1, 0x0010(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
		
		_gbowser_hitbox:
		dw 0x00000000
		dw 0x00000000
		dw 0x00000000
		dw 0x00000000
		dw 0x00000000
		dw 0x00000000
		dw 0x00000000
		dw 0x00320000
		dw 0xFFCE0032
		dw 0x010E0000    // where actual properties begin (ie. damage, type, size, sound, ect.)
		dw 0x19010403
		dw 0x0140E19C
		dw 0x00000000    // where actual properties end
		dw 0xBE860A92
		dw 0xBE060A92
		dw 0x00000000
        dw 0x3E060A92
        dw 0x3E860A92
    }

    // Version of air_collision_ which allows a landing cancel to be performed.
    scope air_collision_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        swc1    f0, 0x0020(sp)              // ~
        swc1    f2, 0x0024(sp)              // ~
        sw      ra, 0x0014(sp)              // store f0, f2, ra
        li      a1, air_to_ground_          // a1 = air_to_ground_ (transition to ground nsp)

        _check_cancel:
        // check if the current animation frame is higher than 20, if so, Bowser is shooting fire
        // or is in endlag and we should check if the B button is held or not for the landing transition.
        lwc1    f0, 0x0078(a0)              // f0 = current animation frame
        lui     t6, 0x41A0                  // ~
        mtc1    t6, f2                      // f2 = float: 20
        c.le.s  f2, f0                      // fp compare
        nop
        bc1fl   _continue                   // branch if animation frame =< 20
        nop
        // if the b button is held, transition to grounded neutral special, otherwise run normal landing subroutine
        lw      at, 0x0084(a0)              // at = player struct
        lh      at, 0x01BC(at)              // at = buttons_held
        andi    at, at, Joypad.B            // at = 0x0020 if (B_HELD); else a2 = 0
        bnez    at, _continue               // branch if (B_HELD)
        nop
        // if we reach this point, the conditions for a normal landing transition have been met
        li      a1, 0x800DE8E4              // a1 = normal ground collision (transition to landing)

        _continue:
        jal     0x800DE6E4                  // ground collision subroutine
        nop
        lwc1    f0, 0x0020(sp)              // ~
        lwc1    f2, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load f0, f2, ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }
	
	// Version of air_collision_ which allows a landing cancel to be performed.
    scope gbowser_air_collision_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        swc1    f0, 0x0020(sp)              // ~
        swc1    f2, 0x0024(sp)              // ~
        sw      ra, 0x0014(sp)              // store f0, f2, ra
        li      a1, air_to_ground_flame_cancel          // a1 = air_to_ground_flame_cancel (transition to ground nsp)

        _check_cancel:
        // check if the current animation frame is higher than 16, if so, Bowser is shooting fire
        // or is in endlag and we should check if the B button is held or not for the landing transition.
        lwc1    f0, 0x0078(a0)              // f0 = current animation frame
        lui     t6, 0x41A0                  // ~
        mtc1    t6, f2                      // f2 = float: 20
        c.le.s  f2, f0                      // fp compare
        nop
        bc1fl   _continue                   // branch if animation frame =< 20
        nop
        // if the b button is held, transition to grounded neutral special, otherwise run normal landing subroutine
        lw      at, 0x0084(a0)              // at = player struct
        lh      at, 0x01BC(at)              // at = buttons_held
        andi    at, at, Joypad.B            // at = 0x0020 if (B_HELD); else a2 = 0
        bnez    at, _continue               // branch if (B_HELD)
        nop
        // if we reach this point, the conditions for a normal landing transition have been met
        li      a1, 0x800DE8E4              // a1 = normal ground collision (transition to landing)

        _continue:
        jal     0x800DE6E4                  // ground collision subroutine
        nop
        lwc1    f0, 0x0020(sp)              // ~
        lwc1    f2, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load f0, f2, ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition Bowser's grounded neutral special.
    // this actually does the work when transitioning to air from ground. It is heavily based on 80147774
    // Modified to recreate something similar to the "flame cancel" technique from version 1.0/1.1 of SSBM.
    scope air_to_ground_flame_cancel: {
        OS.copy_segment(0xC21B4, 0x1C)
        addiu   sp, sp,-0x0010              // allocate stack space
        swc1    f0, 0x0008(sp)              // ~
        swc1    f2, 0x000C(sp)              // store f0, f2 (99% sure this isn't needed)
        addiu   a1, r0, 0x00E4              // a1 = action id: ground nsp
        lw      t7, 0x0074(a0)              // ~
        lw      a3, 0x0078(t7)              // a3 = frame speed multiplier

        // check if the current animation frame is lower than 16, if so, set the animation frame to
        // 16 so that Bowser will always start shooting flames within 5 frames of landing.
        lwc1    f0, 0x0078(a0)              // f0 = current animation frame
        lui     t7, 0x4180                  // ~
        mtc1    t7, f2                      // f2 = float: 16
        c.le.s  f2, f0                      // fp compare
        nop
        bc1fl   _continue                   // branch if animation frame =< 16
        mfc1    a2, f2                      // a2 = 16
        // if we reach this point, Bowser has passed frame 16 of the animation
        mfc1    a2, f0                      // a2 = current animation frame

        _continue:
        lwc1    f0, 0x0008(sp)              // ~
        lwc1    f2, 0x000C(sp)              // load f0, f2 (99% sure this isn't needed)
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800E6F24                  // ~
        sw      r0, 0x0010(sp)              // ~
        lw      t9, 0x0024(sp)              // original logic
        li      t8, main_
        //      sw      t8, 0x09D8(t9)      // in the original code for fireflower this was the address of the main code, but it causes a loop and then crash in this action and seems to have no consequence when removed
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // Original version of air_to_ground_.
    scope air_to_ground_: {
        OS.copy_segment(0xC21B4, 0x1C)
        lw      a2, 0x0008(s1)
        ori		t7, r0, Character.id.KIRBY  // t7 = id.KIRBY
        beq     t7, a2, _kirby_action
        lli     a1, Kirby.Action.BOWSER_NSP_Ground              // Kirby Fire Breath Action ID              // Kirby and J Kirby Grounded Flame Breath Action ID
        ori		t7, r0, Character.id.JKIRBY  // t7 = id.JKIRBY
        beq     t7, a2, _kirby_action
       lli     a1, Kirby.Action.BOWSER_NSP_Ground              // Kirby Fire Breath Action ID              // Kirby and J Kirby Grounded Flame Breath Action ID

        addiu   a1, r0, 0x00E4              // Bowser and Giga Bowser's Grounded Flame Breath Action ID
        _kirby_action:
        OS.copy_segment(0xC21D4, 0x18)
        li      t8, main_
        //      sw      t8, 0x09D8(t9)      // in the original code for fireflower this was the address of the main code, but it causes a loop and then crash in this action and seems to have no consequence when removed
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }
}

// @ Description
// Subroutines for Up Special
scope BowserUSP {
    constant G_INITIAL_SPEED(0x42A0)
	constant INITIAL_SPEED(0x4270)          // TODO: current setting ///////////////////////////////////
    constant G_MAX_X_SPEED(0x4270)
	constant MAX_X_SPEED(0x4220)
	constant G_X_ACCELERATION(0x3D23)
    constant X_ACCELERATION(0x3D00)
    constant GRAVITY(0x3F90)

    // @ Description
    // Initial Subroutine for Bowser's aerial up special.
    // Changes action, sets velocity, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3

        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x0B18(a0)
        sw      r0, 0x0B1C(a0)
        sw      r0, 0x0B20(a0)
        sw      r0, 0x0B24(a0)
        sw      r0, 0x0B28(a0)
        sw      r0, 0x0B2C(a0)
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        lw      a0, 0x0020(sp)              // a0 = player object struct
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00DF              // a1 = 0xDF
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // take mid-air jumps away
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t6 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        // set y velocity
		ori		t6, r0, Character.id.GBOWSER// t6 = id.GBOWSER
		lw		v1, 0x0008(a0)              // v1 = character id
		beql	v1, t6, _store_speed        // branch if character = GBOWSER
		lui		v1, G_INITIAL_SPEED         // v1 = G_INITIAL_SPEED
        // bowser initial speed
        lui     v1, INITIAL_SPEED           // v1 = INITIAL_SPEED
		_store_speed:
        sw      v1, 0x004C(a0)              // y velocity = INITIAL_SPEED
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine for Bowser's grounded up special, heavily based on Donkey Kongs located at 0x8015B744.
    scope ground_physics_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)  // allocate stack space
        sw      a0, 0x0018(sp)


        lw      a0, 0x0084(a0)  // load player struct
        or      a1, r0, r0
        lw      t6, 0x0180(a0)  // load temp variable 2
        beqz    t6, _beginningspeed
        lui     a3, 0x4230      // determines maximum horizontal velocity, DK's is 0x41D0 (26)
        lui     a3, 0x4120      // determines maximum horizontal velocity, DK's is 0x41D0 (26)

        _beginningspeed:
        lui     a2, 0x3D5D      // determines acceleration rate of horizontal movement, DK's is 3CCC
        jal     0x800D89E0      // generic function that calculates horizontal movement amount
        ori     a2, a2, 0xCCCD  // determines acceleration rate of horizontal movement

        _apply:
        jal     0x800D87D0      // generic function that applies calculated movement speed amount
        lw      a0, 0x0018(sp)

        _end:
        lw      ra, 0x0014(sp)  // load ra
        addiu   sp, sp, 0x0018  // deallocate stack space
        jr      ra              // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Bowser's aerial up special.
    scope air_physics_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        // apply modified gravity
        or      a3, s1, r0                  // a3 = attribute pointer
        lui     a1, GRAVITY                 // a1 = GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lw      a2, 0x005C(a3)              // a2 = max fall speed
        // air control
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
		lw		a0, 0x0008(a0)
		addiu	v0, r0, Character.id.GBOWSER
		lui     a2, G_X_ACCELERATION          // a2 = X_ACCELERATION
        beql	a0, v0, _velocity
		lui     a3, G_MAX_X_SPEED             // a3 = MAX_X_SPEED
		
		
        lui     a2, X_ACCELERATION          // a2 = X_ACCELERATION
        lui     a3, MAX_X_SPEED             // a3 = MAX_X_SPEED
		
		_velocity:
        jal     0x800D8FC8                  // air drift subroutine?
        or      a0, s0, r0                  // a0 = player struct
        // apply air friction
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // apply air friction
        or      a1, s1, r0                  // a1 = attribute pointer
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original return logic
    }

    // @ Description
    // Subroutine for Bowser's up special, allows a direction change with the command 58000002
    scope air_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // store t0, t1, ra, a1
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop
        lw      a1, 0x0010(sp)              // load a1
        ori     t1, r0, 0x0001              // t1 = 0x1
        sw      t1, 0x0180(a1)              // temp variable 2 = 1
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Patch which enables the ledge grab flag when Bowser transitions from ground to air up special.
    scope ledge_grab_patch_: {
        OS.patch_start(0xD96A4, 0x8015EC64)
        j       ledge_grab_patch_
        sw      a0, 0x0024(sp)              // original line 2
        _return:
        OS.patch_end()

        ori     t6, r0, Character.id.GBOWSER // t6 = id.BOWSER
        lw      t7, 0x0008(a0)              // t7 = character id
        beq		t6, t7, _bowser				// apply patch if Giga Bowser
		ori     t6, r0, Character.id.BOWSER // t6 = id.BOWSER
		bne     t6, t7, _skip               // skip if character !BOWSER
        nop
		_bowser:
        ori     t7, r0, 0x0001              // t7 = 0x1
        sw      t7, 0x0180(a0)              // temp variable 2 = 1

        _skip:
        jal     0x800DEEC8                  // original line 1
        nop
        j       _return                     // return
        nop
    }
}

// @ Description
// Subroutines for Down Special
scope BowserDSP {
    // @ Description
    // Subroutine which handles physics for Bowser's aerial down special.
    // This takes in part from the generic physics used by down special at 800D93E4 and Kirby's Up Special Physics.
    scope air_physics_: {
        addiu   sp, sp, 0xFFE0
        sw      ra, 0x001C(sp)
        sw      s1, 0x0018(sp)
        sw      s0, 0x0014(sp)
        lw      s0, 0x0084(a0)
        lw      s1, 0x09C8(s0)
        sw      a0, 0x0020(sp)

        //lui       at, 0x8019
        //lwc1  f4, 0xC9C0(at)      // normally the number here determines the percentage of the vertical movement as determined by the animation, I set this to one instead
        lui     at, 0x3F80
        mtc1    at, f4                      // set animation height multiplier to 1 in floating point
        lw      t6, 0x08E8(s0)
        lw      a0, 0x0020(sp)
        //swc1  f4, 0x0048(t6)
        lw      v0, 0x08E8(s0)
        lwc1    f0, 0x0048(v0)
        swc1    f0, 0x0044(v0)
        lw      t7, 0x08E8(s0)
        jal     0x800D9414                  // generic routine which limits or in someway controls vertical movement
        swc1    f0, 0x0040(t7)

        // lui      at, 0x3F80
        // mtc1 at, f6                      // loads a multiplier that determines the amount of player control and size of the player
        // lw       t8, 0x08E8(s0)
        // or       a0, s0, r0
        // or       a1, s1, r0
        // swc1 f6, 0x0048(t8)
        // lw       v0, 0x08E8(s0)
        // lwc1 f0, 0x0048(v0)              // loads character size
        // swc1 f0, 0x0044(v0)
        // lw       t6, 0x0180(a0)              // load temp variable 2
        // bnez t6, skip_player_control_    // ends player control when command set in moveset
        // lw       t9, 0x08E8(s0)
        // jal      0x800D8FA8                  // generic routine allowing player control
        // swc1 f0, 0x0040(t9)

        skip_player_control_:
        // bnez v0, end_
        // lui      at, 0x3F00
        // lwc1 f8, 0x004C(s1)
        // mtc1 at, f10
        // or       a0, s0, r0
        //addiu a1, r0, 0x0008
        //mul.s f16, f8, f10
        //lw        a3, 0x0050(s1)
        //mfc1  a2, f16
        //jal       0x800D8FC8                  // generic routine that is used to determine horizontal aerial velocity, loads joystick position
        //nop

        // or       a0, s0, r0
        // jal      0x800D9074                  // generic function with unknown purpose
        // or       a1, s1, r0

        end_:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0014(sp)
        lw      s1, 0x0018(sp)
        jr      ra
        addiu   sp, sp, 0x0020

    }

    // @ Description
    // Bowser Down Special patch to prevent crashing.
    scope skip_projectile_: {
        OS.patch_start(0xD9864, 0x8015EE24)
        j       skip_projectile_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t2, 0x0084(a0)                  // load character struct from t6
        lw      t2, 0x0008(t2)
        addiu   t1, r0, Character.id.BOWSER     // BOWSER ID
        beq     t1, t2, _bowser
        nop
		addiu   t1, r0, Character.id.GBOWSER     // BOWSER ID
        beq     t1, t2, _bowser
        nop

        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x8016C954                 // original line 1
        addiu   a1, sp, 0x0018             // original line 2
        j       _return
        nop

        _bowser:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
}

// @ Description
// Subroutines for Forward Throw
scope BowserFThrow {
    // @ Descriptions
    // Main subroutine for Bowser's throw, heavily based on Kirby' fthrow located at 0x8014A430.
    // Important note: relevant Bowser code is located in jigglypuffkirbyshared.asm that changes throw action to 0xE5
    // All this does is transition to the next step in the action to 0xE6
    scope main_: {
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)

        li      a1, transition_1_
        jal     0x800D9480
        nop

        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // @ Description
    // Collision subroutine for Bowser's second stage of forward throw, heavily based on Kirby's fthrow located at 0x8014A454.
    // All this does is transition to the next step in the action to 0xE8
    scope collision_: {
        OS.copy_segment(0xC4E94, 0x18)
        beq     v0, r0, _no_collision_1
        lw      a0, 0x0020(sp)
        lw      t7, 0x001C(sp)
        mtc1    r0, f6
        lwc1    f4, 0x004C(t7)
        c.lt.s  f4, f6
        nop
        bc1fl   _no_collision_2
        lw      ra, 0x0014(sp)
        jal     transition_2_
        nop

        _no_collision_1:
        lw      ra, 0x0014(sp)

        _no_collision_2:
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }


    // @ Description
    // First Transition for Bowser's throw, heavily based on Kirby's fthrow located at 0x8014A4A8.
    // All this does is transition to the next step in the action to 0xE6
    scope transition_1_: {
        addiu   sp, sp, 0xFFD0
        sw      ra, 0x001C(sp)
        lw      v0, 0x0084(a0)
        addiu   t6, r0, 0x0080
        addiu   a1, r0, 0x00E6

        OS.copy_segment(0xC4EFC, 0x3C)
    }

    // @ Description
    // Second Transition for Bowser's throw, heavily based on Kirby's fthrow located at 0x8014A5AC.
    // All this does is transition to the next step in the action to 0xE8
    scope transition_2_: {

        OS.copy_segment(0xC4FEC, 0x20)

        addiu   a1, r0, 0x00E8
        addiu   a2, r0, 0x0000
        jal     0x800E6F24
        lui     a3, 0x3F80
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
}
