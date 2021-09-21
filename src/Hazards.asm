// Hazards.asm [bit]
if !{defined __HAZARDS__} {
define __HAZARDS__()
print "included Hazards.asm\n"

// @ Description
// This file contains various functions for disabling stage hazards (based on Toggles.entry_hazard_mode).

include "OS.asm"
include "Stages.asm"

scope Hazards {

    // @ Description
    // Macro for toggling various hazards
    macro hazard_toggle(function_address) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // save registers

        li      t0, Global.current_screen   // t0 = pointer to current screen
        lbu     t0, 0x0000(t0)              // t0 = current screen_id
        lli     t1, 0x0016                  // t1 = vs screen_id
        variable _check_hazard(pc() + 4 * 5)
        beq     t1, t0, _check_hazard       // if vs, check hazard mode
        lli     t1, 0x0036                  // t1 = training screen_id
        beq     t1, t0, _check_hazard       // if training, check hazard mode
        nop
        variable _original(pc() + 4 * 7)
        b       _original                   // otherwise, don't check hazard mode
        nop

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        variable _end(pc() + 4 * 3)
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        // _original:
        jal     {function_address}          // original line 1
        nop                                 // original line 2

        // _end:
        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Toggles for Dream Land wind
    scope dream_land_wind_: {
        OS.patch_start(0x00081734, 0x80105F34)
        jal     dream_land_wind_
        nop
        OS.patch_end()

        hazard_toggle(0x80105BE8)
    }

    // @ Description
    // Toggle for Sector Z arwing
    scope sector_z_arwing_: {
        OS.patch_start(0x0008364C, 0x80107E4C)
        jal     sector_z_arwing_
        nop
        OS.patch_end()

        hazard_toggle(0x80106AC0)
    }

    // @ Description
    // Toggle for Mushroom Kingdom POW blocks.
    scope mushroom_kingdom_pow_: {
        OS.patch_start(0x000851AC, 0x801099AC)
        jal     mushroom_kingdom_pow_
        nop
        OS.patch_end()

        hazard_toggle(0x80109888)
    }

    // @ Description
    // Toggle for Mushroom Kingdom Piranha Plants
    scope mushroom_kingdom_piranha_plants_: {
        OS.patch_start(0x00085424, 0x80109C24)
        jal     mushroom_kingdom_piranha_plants_
        nop
        OS.patch_end()

        hazard_toggle(0x80109774)
    }
	
	// @ Description
    // Remove pirhana plants and swing platform from the Mushroom Kingdom clones
    scope mk_clone_hazard_removal_: {
        OS.patch_start(0x0008541C, 0x80109C1C)
        j       mk_clone_hazard_removal_
        nop
		return:
        OS.patch_end()

		li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // t7 = match info
        lbu     a0, 0x0001(a0)              // t7 = current stage ID
		lli     a1, Stages.id.SMBBF         // t0 = Stages.id.SMBBF
        beq     a1, a0, _mk_clone     		// if current stage is SMBBF, then skip pirahna and platforms
		nop
		lli     a1, Stages.id.SMBO         // t0 = Stages.id.SMBO
        beq     a1, a0, _mk_clone     		// if current stage is SMBO, then skip pirahna and platforms
		nop

        jal		0x801094A0					// original line 1
		nop									// original line 2
		
		j		return
		nop
		
		_mk_clone:
		j		0x80109C2C
		nop
    }

    // @ Description
    // Toggles and a CPU fix for Planet Zebes acid
    // If no hazards mode is on, then no acid will be created
    // If no movement mode is on, then the acid won't rise
    scope planet_zebes_acid_: {
        // Disable acid if hazards are off
        OS.patch_start(0x00083C50, 0x80108450)
        j       planet_zebes_acid_._no_hazards_check
        nop
        _no_hazards_check_return:
        OS.patch_end()
        // Disable acid rising/falling if movement is off
        OS.patch_start(0x00083C10, 0x80108410)
        jal     planet_zebes_acid_._no_movement_check
        nop
        _no_movement_check_return:
        OS.patch_end()
        // Enable CPU AI to avoid acid
        OS.patch_start(0x000B1F28, 0x801374E8)
        jal     planet_zebes_acid_._ai_fix
        lbu     t2, 0x0001(t3)              // original line 3
        nop
        OS.patch_end()

        _no_hazards_check:
        lui     at, 0x8013                  // ~
        lwc1    f4, 0xEB1C(at)              // f4 = correct camera position
        lui     at, 0x8013                  // ~
        swc1    f4, 0x13FC(at)              // store correct camera position

        li      a0, Global.current_screen   // a0 = pointer to current screen
        lbu     a0, 0x0000(a0)              // a0 = current screen_id
        lli     a1, 0x0016                  // a1 = vs screen_id
        beq     a1, a0, _check_hazard_1     // if vs, check hazard mode
        lli     a1, 0x0036                  // a1 = training screen_id
        beq     a1, a0, _check_hazard_1     // if training, check hazard mode
        nop
        b       _no_hazards_original        // otherwise, don't check hazard mode
        nop

        _check_hazard_1:
        li      a1, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a1)              // a1 = hazard_mode (hazards disabled when a1 = 1 or 3)
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        bnezl   a1, _end                    // if hazard_mode is on, don't create acid object
        addiu   sp, sp, 0x0020              // original line before original jr ra

        _no_hazards_original:
        addiu   a0, r0, 0x03F2              // original line 1
        or      a1, r0, r0                  // original line 2
        j       _no_hazards_check_return
        nop

        _no_movement_check:
        li      a0, Global.current_screen   // a0 = pointer to current screen
        lbu     a0, 0x0000(a0)              // a0 = current screen_id
        lli     a1, 0x0016                  // a1 = vs screen_id
        beq     a1, a0, _check_hazard_2     // if vs, check hazard mode
        lli     a1, 0x0036                  // a1 = training screen_id
        beq     a1, a0, _check_hazard_2     // if training, check hazard mode
        nop
        b       _no_movement_original       // otherwise, don't check hazard mode
        nop

        _check_hazard_2:
        li      a1, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a1)              // a1 = hazard_mode (hazards disabled when a1 = 2 or 3)
        srl     a1, a1, 0x0001              // a1 = 1 if hazard_mode is 2 or 3, 0 otherwise

        bnez    a1, _end                    // if hazard_mode is on, don't allow acid to rise
        nop

        _no_movement_original:
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     0x801082B4                  // original line 1
        nop                                 // original line 2

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra                          // return
        nop

        _ai_fix:
        // See if we're on a stage based on Zebes instead of only checking for Zebes
        li      a0, Stages.function_table   // a0 = function_table
        sll     at, t2, 0x0002              // at = offset in function_table
        addu    a0, a0, at                  // a0 = address in function_table
        lw      t2, 0x0000(a0)              // t2 = function for this stage

        // addiu   at, r0, 0x0003              // original line 1

        li      at, Toggles.entry_hazard_mode
        lw      at, 0x0004(at)              // at = hazard_mode (hazards disabled when at = 1 or 3)
        andi    at, at, 0x0001              // at = 1 if hazard_mode is 1 or 3, 0 otherwise

        bnezl   at, _end_ai_fix             // if hazard_mode is on, don't treat as Zebes
        addiu   at, r0, 0xFFFF              // ...this way CPU won't avoid something that isn't there

        li      at, Stages.function.PLANET_ZEBES

        _end_ai_fix:
        jr      ra
        addiu   a0, sp, 0x0034              // original line 2
    }

    // @ Description
    // Toggle for Hyrule Castle tornadoes
    scope hyrule_castle_tornadoes_: {
        OS.patch_start(0x00086160, 0x8010A960)
        jal     hyrule_castle_tornadoes_
        nop
        OS.patch_end()

        hazard_toggle(0x8010A3B4)
    }

    // @ Description
    // Toggle for Congo Jungle barrel
    scope congo_jungle_barrel_: {
        OS.patch_start(0x000857BC, 0x80109FBC)
        jal     congo_jungle_barrel_
        nop
        OS.patch_end()
        
        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        lli     t6, Stages.id.SMASHKETBALL       // t6 = Stages.id.NBA_JAM
        beq     t6, t7, _nba_jam            // if current stage is NBA_JAM, then add custom barrels
        nop
        lli     t6, Stages.id.CONGO_JUNGLE  // t6 = Stages.id.CONGO_JUNGLE
        beq		t6, t7, standard_barrel_
		lli     t6, Stages.id.CONGOJ_DL  	// t6 = Congo Jungle DL
        beq		t6, t7, standard_barrel_		
		lli     t6, Stages.id.CONGOJ_O  	// t6 = Congo Jungle O
        beq		t6, t7, standard_barrel_
		lli     t6, Stages.id.FALLS  		// t6 = Stages.id.FALLS
		beq		t6, t7, standard_barrel_	
		nop
		j       _end                // if current stage is not Congo Jungle or Congo Falls, then always disable barrel
        nop
		standard_barrel_:
        hazard_toggle(0x80109E84)

        _nba_jam:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip adding barrels
        nop

        // Add 2 barrels - one on the left, one on the right - both pointing down
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      a0, 0xC5772000              // left of main plat
        li      a1, 0x44DDE000              // slightly below 0
        li      a2, 0x41AFF000              // pointed down
        lli     a3, 0x0000                  // no animation
        jal     add_barrel_
        nop
        li      a0, 0x45772000              // right of main plat
        li      a1, 0x44DDE000              // slightly below 0
        li      a2, 0x41AFF000              // pointed down
        lli     a3, 0x0000                  // no animation
        jal     add_barrel_
        nop
        
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Toggle for Saffron City Pokemon
    scope saffron_city_pokemon_: {
        OS.patch_start(0x00086974, 0x8010B174)
        jal     saffron_city_pokemon_
        nop
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // save registers

        li      t0, Global.current_screen   // t0 = pointer to current screen
        lbu     t0, 0x0000(t0)              // t0 = current screen_id
        lli     t1, 0x0016                  // t1 = vs screen_id
        beq     t1, t0, _check_hazard       // if vs, check hazard mode
        lli     t1, 0x0036                  // t1 = training screen_id
        beq     t1, t0, _check_hazard       // if training, check hazard mode
        nop
        b       _original                   // otherwise, don't check hazard mode
        nop

        _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        _original:
        jal     0x8010AF48                  // original line 1
        nop                                 // original line 2
        jal     0x8010B108                  // original line 3
        nop                                 // original line 4

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Toggle for Peach's Bumper.
    // registers v0 and v1 have current stage ID, but v0 is free
    scope peach_bumper_: {
        OS.patch_start(0x00086CB4, 0x8010B4B4)
        jal     peach_bumper_
        nop
        OS.patch_end()
        
        lli     t0, Stages.id.BOWSERB       // t0 = Stages.id.BOWSERB
        beq     v1, t0, _bowser_stadium     // if current stage is BOWSERB, then add bombs
        lli     t0, Stages.id.PCASTLE_DL    // t0 = Stages.id.PCASTLE_DL
        beq		v1, t0, _pc_clone			// if stage Peach's Castle Dreamland, load the bumper if hazards not off
		nop
		lli     t0, Stages.id.PCASTLE_O     // t0 = Stages.id.PCASTLE_O
        beq		v1, t0, _pc_clone			// if stage Peach's Castle Dreamland, load the bumper if hazards not off
		nop
        lli     t0, Stages.id.PCASTLE_BETA  // t0 = Stages.id.PCASTLE_O
        beq		v1, t0, _pc_clone			// if stage Peach's Castle Dreamland, load the bumper if hazards not off
		nop
		
		bnez    v1, _end                    // if current stage is not Peach's Castle (stage_id = 0), then always disable bumper
        nop
		_pc_clone:
        hazard_toggle(0x8010B378)           // standard toggle

        _bowser_stadium:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip adding barrels
        nop

        // Add rttf bombs
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      a1, 0x453AE000              // right plat edge
        li      a2, 0x44000000              // slightly above plat
        lli     a0, stage.BOWSER_BOMB       // BOWSER_BOMB
        lli     a3, Stages.id.DREAM_LAND    // original stage ID
        li      t1, replenish_bowser_bombs_ // routine to run to check if this bomb needs to be recreated
        lli     t2, 0x0000                  // right bomb unique ID
        jal     add_item_
        lui     t0, 0xC3D0                  // create hover effect by specifying bottom ECB

        li      a1, 0xC53AE000              // left plat edge
        li      a2, 0x44000000              // above 0
        lli     a0, stage.BOWSER_BOMB       // BOWSER_BOMB
        lli     a3, Stages.id.DREAM_LAND    // original stage ID
        li      t1, replenish_bowser_bombs_ // routine to run to check if this bomb needs to be recreated
        lli     t2, 0x0001                  // left bomb unique ID
        jal     add_item_
        lui     t0, 0xC3D0                  // create hover effect by specifying bottom ECB

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Toggle for Yoshi's Island clouds.
    scope yoshis_island_clouds_: {
        OS.patch_start(0x84488, 0x80108C88)
        j       yoshis_island_clouds_
        addiu   a0, r0, 0x03F2              // original line 1
        _return:
        OS.patch_end()

        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        beqz    t0, _original               // if hazards enabled, do original
        nop                                 // otherwise skip to the end of the function

        // We need to disable the cloud platforms' clipping, which is centered on the stage when hazards are off, creating a hidden platform
        lui     t0, 0x8013
        lw      t0, 0x1304(t0)              // t0 = pointer to clipping struct references?
        lli     a0, 0x0004                  // a0 = 4, which seems to disable the clipping
        lw      v0, 0x0004(t0)              // v0 = first cloud's clipping struct
        sw      a0, 0x0084(v0)              // disable clipping
        lw      v0, 0x0008(t0)              // v0 = second cloud's clipping struct
        sw      a0, 0x0084(v0)              // disable clipping
        lw      v0, 0x000C(t0)              // v0 = third cloud's clipping struct
        sw      a0, 0x0084(v0)              // disable clipping

        j       0x80108CBC                  // skip to the end of the function
        nop

        _original:
        j       _return
        or      a1, r0, r0                  // original line 2
    }

    // @ Description
    // This disables platform movement when hazard mode is on
    scope platform_movement_: {
        OS.patch_start(0x00080DA8, 0x801055A8)
        j       platform_movement_
        nop
        _return:
        OS.patch_end()

        li      a0, Global.current_screen   // a0 = pointer to current screen
        lbu     a0, 0x0000(a0)              // a0 = current screen_id
        lli     a1, 0x0016                  // a1 = vs screen_id
        beq     a1, a0, _check_hazard       // if vs, check hazard mode
        lli     a1, 0x0036
        beq     a1, a0, _check_hazard       // if training, check hazard mode
        nop
        b       _original                   // otherwise, initialize plat movement
        nop

        _check_hazard:
        li      a1, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a1)              // a1 = hazard_mode (movement disabled when a1 = 2 or 3)

        // for Onett, treat the moving plat (taxi) as a stage hazard instead of a moving plat
        li      a0, Global.match_info       // a0 = pointer to match info
        lw      a0, 0x0000(a0)              // a0 = match info struct
        lbu     a0, 0x0001(a0)              // a0 = stage_id
        addiu   a0, a0, -Stages.id.ONETT    // a0 = 0 if on Onett
        beqzl   a0, _check_mode             // if on Onett, treat as hazard toggle instead of movement toggle
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        srl     a1, a1, 0x0001              // a1 = 1 if hazard_mode is 2 or 3, 0 otherwise

        _check_mode:
        bnez    a1, _end                    // if hazard_mode is on, don't initialize platform movement
        nop

        _original:
        or      a0, s0, r0                  // restore a0
        jal     0x80008188                  // original line 1
        lw      a1, 0x000C(v0)              // original line 2

        _end:
        j       _return
        nop
    }

    // @ Description
    // Adds a barrel to a Congo Jungle stage.
    // @ Arguments
    // a0 - X position relative to center
    // a1 - Y position relative to center
    // a2 - rotation
    // a3 - animation track RAM address (0 if none)
    scope add_barrel_: {
        // Much of the below is taken from Congo Jungle's main stage function
        // at 0x80109E84.
        OS.save_registers()
        addiu   sp, sp, -0x0028             // allocate stack space

        // This block ensures the address of file 0x9E is stored at 0x801313F0
        lui     t6, 0x8013
        lw      t6, 0x1300(t6)
        lw      t7, 0x0080(t6)
        lli     v1, 0x0A98
        subu    v0, t7, v1
        lui     at, 0x8013
        sw      v0, 0x13F0(at)

        // Loads a generic object?
        addiu   a0, r0, 0x03F2              // not sure if this is an arbitrary ID
        or      a1, r0, r0
        addiu   a2, r0, 0x0001
        jal     0x80009968
        lui     a3, 0x8000

        // v0 is the RAM address of the block that was just allotted and partially filled in
        // We store that value at 0x801313F4 for the first custom barrel... hardcodings will
        // need to be addressed regarding this most likely.
        lui     at, 0x8013
        sw      v0, 0x13F4(at)

        // More barrel object loading?
        or      s0, v0, r0                  // save v0
        addiu   t8, r0, 0xFFFF
        sw      t8, 0x0010(sp)
        or      a0, v0, r0
        li      a1, 0x80014038
        addiu   a2, r0, 0x0006
        jal     0x80009DF4
        lui     a3, 0x8000

        // More barrel object loading?
        lui     a1, 0x8013
        lw      a1, 0x1300(a1)
        lw      a1, 0x0080(a1)
        or      a0, s0, r0
        li      a3, 0x8012EB50
        jal     0x80105760
        or      a2, r0, r0

        // Update coordinates
        lw      a0, 0x0038(sp)              // a0 = X position
        lw      a1, 0x003C(sp)              // a1 = Y position
        lw      a2, 0x0040(sp)              // a2 = rotation
        lw      at, 0x0074(s0)              // at = address of parameters
        sw      a0, 0x001C(at)              // update X position
        sw      a1, 0x0020(at)              // update Y position
        sw      a2, 0x0038(at)              // update rotation

        // Animation track
        // a1 needs to be the RAM address of the animation track
        lw      a1, 0x0044(sp)              // a1 = animation track
        beqz    a1, _barrel_animation       // if a1 is 0, skip
        nop
        addiu   a2, r0, 0x0000
        jal     0x8000BD8C
        or      a0, s0, r0

        _barrel_animation:
        // Barrel enter/exit animations
        li      a1, 0x8000DF34
        or      a0, s0, r0
        addiu   a2, r0, 0x0001
        jal     0x80008188
        addiu   a3, r0, 0x0005

        // Add interaction with barrel
        li      a1, 0x80109FD8              // a1 = routine that runs when players overlap with barrel
        jal     0x800E1D48
        or      a0, s0, r0

        addiu   sp, sp, 0x0028              // deallocate stack space

        OS.restore_registers()

        jr      ra
        nop
    }

    // @ Description
    // This makes it so additional barrels can have their own rotation values
    // and the ejection angle will use the correct rotation value.
    scope barrel_angle_fix_: {
        OS.patch_start(0x8592C, 0x8010A12C)
        // lui     t6, 0x8013               // original line 1
        // lw      t6, 0x13F4(t6)           // original line 2
        // s0 = player struct
        lw      t6, 0x0B20(s0)              // get barrel parameters address from player struct
        nop
        OS.patch_end()
    }

    // @ Description
    // Adds an item to a stage.
    // Note: some items may only work on certain stages, e.g. bumpers on a Peach's Castle stage.
    // @ Arguments
    // a0 - item ID
    // a1 - X position relative to center
    // a2 - Y position relative to center
    // a3 - stage ID of original stage
    // t0 - set to a float to set custom bottom ECB point, otherwise 0 will use default bounds. need to be over a platform to work as a hover height
    // t1 - routine to run every frame
    // t2 - unique ID for custom use
    // TODO: support action track for bumper
    // TODO: extend support to other stages? at least for item/pokemon spawns
    // TODO: may be a graphical glitch where standard items are spawned? not sure
    // TODO: test in other emus and console (only tested most standard items and pokemons in Nemu)
    // TODO: fix pokemon issues
    // TODO: fix crate/barrel/capsule/egg crashes
    scope add_item_: {
        // Much of the below is taken from Peach's Castle main stage function
        // at 0x8010B378.
        OS.save_registers()
        addiu   sp, sp, -0x0060             // allocate stack space

        // TODO: make this more dynamic so that we can load files that are necessary for different items
        lli     t0, stage.BOWSER_BOMB       // t0 = stage.BOWSER_BOMB hazard ID
        beq     t0, a0, _load_bowser_bomb_files // branch if adding a bowser bomb
        nop
        lli     t0, stage.RTTF_BOMB         // t0 = stage.RTTF_BOMB hazard ID
        bne     t0, a0, _begin              // if not adding a bomb, skip
        nop                                 // otherwise, we have to load it

        _load_rttf_files:
        li      a0, rttf_req_list           // a0 = req_list (array of file IDs)
        // TODO: see if we can use our own file_address here and update any hardcodings
        li      a2, 0x801313F4              // a1 = file_address (array of file RAM addresses to use for later referencing)
        li      a3, free_memory_pointer     // a3 = free_memory_pointer (free memory space to load the file to)
        lw      a3, 0x0000(a3)              // a3 = address to load file to
        jal     0x800CDE04
        addiu   a1, r0, 0x0001              // a2 = 1 (number of files in array)
        li      a3, free_memory_pointer     // a3 = free_memory_pointer (free memory space to load the file to)
        sw      t7, 0x0000(a3)              // store updated free memory address
        b       _begin                      // branch to begin
        nop

        _load_bowser_bomb_files:
        li      a0, bowser_bomb_req_list    // a0 = req_list (array of file IDs)
        // TODO: see if we can use our own file_address here and update any hardcodings
        li      a2, 0x801313F4              // a1 = file_address (array of file RAM addresses to use for later referencing)
        li      a3, free_memory_pointer     // a3 = free_memory_pointer (free memory space to load the file to)
        lw      a3, 0x0000(a3)              // a3 = address to load file to
        jal     0x800CDE04
        addiu   a1, r0, 0x0001              // a2 = 1 (number of files in array)
        li      a3, free_memory_pointer     // a3 = free_memory_pointer (free memory space to load the file to)
        sw      t7, 0x0000(a3)              // store updated free memory address
        lli     a0, stage.RTTF_BOMB         // t0 = stage.RTTF_BOMB hazard ID
        sw      a0, 0x0070(sp)              // update item ID to cloned item ID

        _begin:
        // This block ensures the address of file 0x9C (for bumper) is stored at 0x801313F0
        lui     t6, 0x8013
        lw      t6, 0x1300(t6)
        lw      v0, 0x0080(t6)
        lui     at, 0x8013
        sw      v0, 0x13F0(at)

        _create_object:
        // Create a generic object
        addiu   a0, r0, 0x03F2              // not sure if this is an arbitrary ID
        lw      a1, 0x0084(sp)              // a1 = 0 if no routine needs to run
        addiu   a2, r0, 0x0001
        jal     0x80009968
        lui     a3, 0x8000

        // v0 is the RAM address of the block that was just allotted and partially filled in

        or      s0, v0, r0                  // save v0

        // Object loading?
        jal     0x8000DF34
        or      a0, s0, r0

        // More object loading?
        addiu   a0, r0, 0x0013              // seems to be dependent on stage - for stages imported over DL, this should be 0x0004
        lw      t0, 0x007C(sp)              // t0 = original stage ID
        lli     t1, Stages.id.DREAM_LAND    // t1 = Stages.id.DREAM_LAND
        beql    t0, t1, pc() + 8            // if the original stage was Dream Land, then use 0x0004
        addiu   a0, r0, 0x0004              // a0 = 0x0004
        jal     0x800FC814
        addiu   a1, sp, 0x003C

        // More object loading?
        addiu   s1, sp, 0x004C              // s0 = location of coordinates
        or      a1, s1, r0                  // a1 = location of coordinates
        jal     0x800FC894
        lw      a0, 0x003C(sp)

        // update coordinates - seems to be where it spawns
        lw      a1, 0x0074(sp)              // a1 = X position
        lw      a2, 0x0078(sp)              // a2 = Y position
        sw      a1, 0x0000(s1)              // update X position
        sw      a2, 0x0004(s1)              // update Y position

        // More object loading?
        or      a0, r0, r0
        lw      a1, 0x0070(sp)              // a1 = item ID
        or      a2, s1, r0                  // a2 = location of coordinates
        addiu   sp, sp, -0x0030             // allocate some space
        addiu   a3, sp, 0x0020              // a3 = address of setup floats
        addiu   t3, 0x0001                  // t3 = 1
        sw      t3, 0x0010(sp)              // 0x0010(sp) = 1
        mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0000(a3)              // set up float 1
        swc1    f4, 0x0004(a3)              // set up float 2
        jal     0x8016EA78
        swc1    f4, 0x0008(a3)              // set up float 3
        addiu   sp, sp, 0x0030              // deallocate

        // Update coordinates
        lw      at, 0x0074(v0)              // pointer to item struct
        lw      a1, 0x0074(sp)              // a1 = X position
        lw      a2, 0x0078(sp)              // a2 = Y position
        sw      a1, 0x001C(at)              // update X position
        sw      a2, 0x0020(at)              // update Y position
        lw      t0, 0x0080(sp)              // t0 = 0 if default ECB
        beqz    t0, _save_struct_location   // if not explicitly setting ECB, skip
        nop                                 // otherwise, use given value for bottom ECB
        lw      at, 0x0084(v0)              // at = animation info?
        sw      t0, 0x0078(at)              // set final Y position from ground

        _save_struct_location:
        // save item struct location
        lui     at, 0x8013
        sw      v0, 0x13F8(at)

        // Also want to store a reference to the item struct in our original object for our own custom use
        sw      v0, 0x0030(s0)              // 0x0030 is free to use it seems
        lw      t0, 0x0088(sp)              // t0 = custom use value
        sw      t0, 0x0034(s0)              // 0x0034 is free to use it seems

        addiu   sp, sp, 0x0060              // deallocate stack space

        OS.restore_registers()

        jr      ra
        nop

        rttf_req_list:
        dw      0x127                       // file containing RTTF bomb info
        
        bowser_bomb_req_list:
        // NOTE, the pointer at 0xA8 in this file needs to be updated if the bomb model file is updated
        dw      File.BOWSER_BOMB_HEADER     // modified RTTF header file, contains hitbox info (alternate 0x127)
    }

    scope standard {
        constant CRATE(0x0000)              // crashes when interacted with when added with add_item_
        constant BARREL(0x0001)             // crashes when interacted with when added with add_item_
        constant CAPSULE(0x0002)            // crashes when interacted with when added with add_item_
        constant EGG(0x0003)                // crashes when interacted with when added with add_item_
        constant MAXIM_TOMATO(0x0004)
        constant HEART(0x0005)
        constant STAR(0x0006)
        constant BEAM_SWORD(0x0007)
        constant HOME_RUN_BAT(0x0008)
        constant FAN(0x0009)
        constant STAR_ROD(0x000A)
        constant RAY_GUN(0x000B)
        constant FIRE_FLOWER(0x000C)
        constant HAMMER(0x000D)
        constant MOTION_SENSOR_BOMB(0x000E)
        constant BOBOMB(0x000F)
        constant BUMPER(0x0010)
        constant GREEN_SHELL(0x0011)
        constant RED_SHELL(0x0012)
        constant POKEBALL(0x0013)           // not 100% functional when added with add_item_ (Chansey spawns no eggs, Clefairy uses random pokemon attack)
    }

    scope stage {
        // 0x14, 0x15, 0x16, 0x18, 0x19, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F all crash on stage load with add_item_
        // 0x19 does nothing with add_item_
        constant BUMPER(0x0017)
        constant RTTF_BOMB(0x001A)
        constant BOWSER_BOMB(0x011A)        // custom
    }

    scope pokemon {
        constant ONIX(0x0020)
        constant SNORLAX(0x0021)
        constant GOLDEEN(0x0022)
        constant MEOWTH(0x0023)
        constant CHARIZARD(0x0024)
        constant BEEDRILL(0x0025)
        constant BLASTOISE(0x0026)
        constant CHANSEY(0x0027)            // not 100% functional when added with add_item_: no eggs spawn
        constant STARMIE(0x0028)
        constant HITMONLEE(0x0029)
        constant KOFFING(0x002A)
        constant CLEFAIRY(0x002B)           // not 100% functional when added with add_item_: uses random pokemon attack
        constant MEW(0x002C)
    }
	
	// @ Description
    // Alt Y positions for Zebes level acid
    scope alt_acid_levels_: {
        OS.patch_start(0x000839E0, 0x801081E0)
        jal     alt_acid_levels_
        nop
        OS.patch_end()

        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        lli     t6, Stages.id.NORFAIR       // t6 = Stages.id.NORFAIR
        beq     t6, t7, _norfair            // if current stage is Norfair, then use alt y positions
        nop
		lli     t6, Stages.id.ZEBES_DL      // t6 = Stages.id.ZEBES_DL 
        beq     t6, t7, _zebes_dl           // if current stage is Zebes DL, then use alt y positions
        nop
		lli     t6, Stages.id.ZEBES_O       // t6 = Stages.id.ZEBES_O 
        beq     t6, t7, _zebes_o            // if current stage is Zebes Omega, then use alt y positions
        nop
        b       _original
        nop

        _norfair:
        li      t6, norfair_lava_levels     // t6 = norfair_lava_levels
        b       _loop_setup
        nop
		
		_zebes_dl:
        li      t6, zebes_dl_lava_levels     // t6 = norfair_lava_levels
        b       _loop_setup
        nop
		
		_zebes_o:
        li      t6, zebes_o_lava_levels     // t6 = norfair_lava_levels
        //b       _loop_setup
        // nop

        _loop_setup:
        li      at, 0x8012EA60
        lli     t3, 0x0000                  // t3 = index

        _loop:
        lw      t7, 0x0000(t6)              // t7 = level y position
        sw      t7, 0x0008(at)              // store level
        addiu   at, at, 0x000C              // increment at
        addiu   t3, t3, 0x0001              // increment t3
        slti    t8, t3, 0x0010              // t8 = 1 if at last track
        bnez    t8, _loop                   // if not at last track, loop
        addiu   t6, t6, 0x0004              // increment t6

        _original:
        lui     at, 0x8013                  // original line 1
        lwc1    f4, 0xEB1C(at)              // original line 2

        jr      ra
        nop
    }

    norfair_lava_levels:
    dw 0x43480000
    dw 0xc4160000
    dw 0xc2c80000
	dw 0xC5160000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x43480000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x43480000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x43480000
	dw 0xC5160000
	
	zebes_dl_lava_levels:
    dw 0x43480000
    dw 0xc4160000
    dw 0xc2c80000
	dw 0xC5160000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x44898000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x44610000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0x43960000
	dw 0xC5160000
	
	zebes_o_lava_levels:
    dw 0xc3960000
    dw 0xc4160000
    dw 0xC5160000
	dw 0xC5160000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc2c80000
    dw 0xc3960000
    dw 0xC5160000
    dw 0xc4160000
    dw 0xc4160000
    dw 0xc3960000
    dw 0xc4160000
    dw 0xC5160000
    dw 0xc3960000
	dw 0xC5160000

	// @ Description
    // Use the correct Bumper Hitbox for Peach's Castle clones
    scope peach_bumper_hitbox_: {
        OS.patch_start(0xF8150, 0x8017D710)
        j     peach_bumper_hitbox_
        nop
		_return:
        OS.patch_end()
		
		addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
		beq		t3, r0, _classic_bumper	    // original line 1 modified
		addiu	t0, r0, Stages.id.PCASTLE_DL
		beq		t3, t0, _classic_bumper	    // check for Peach's Castle DL
		addiu	t0, r0, Stages.id.PCASTLE_O
		beq		t3, t0, _classic_bumper	    // check for Peach's Castle O
		addiu	t0, r0, Stages.id.PCASTLE_BETA
        beq		t3, t0, _classic_bumper	    // check for Peach's Castle Beta
		nop
		lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		j		0x8017D724
		lw		ra, 0x001C(sp)				// original line 2
			
		_classic_bumper:
		lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		j		_return
		nop
		}

	// @ Description
	// Respawns bombs on Bowser's Stadium after they've been destroyed
	scope replenish_bowser_bombs_: {
	    // @ Description
	    // The number of (approximate) frames to wait before respawning
	    constant RESPAWN_TIME(0x3C * 5)
	    
	    addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

	    // a0 = object struct
	    // 0x0030(a0) = bomb object struct
	    // 0x0034(a0) = 0 for right, 1 for left
	    // 0x0038(a0) = timer value to use before respawning

	    lw      a1, 0x0030(a0)              // a1 = bomb object struct
        beqz    a1, _timer                  // if there is no object at 0x0030, decrement timer
        nop
	    lw      t0, 0x0080(a1)              // t0 = 1 if explosion has started
	    lli     t1, RESPAWN_TIME            // t1 = RESPAWN_TIME to act as timer value
	    beqzl   t0, _end                    // if the bomb is not yet exploded, skip
	    sw      t1, 0x0038(a0)              // store timer value

        _timer:
        sw      r0, 0x0030(a0)              // reset stored object
	    lw      t1, 0x0038(a0)              // t1 = timer value
	    addiu   t1, t1, -0x0001             // t1 = t1 - 1
	    bnezl   t1, _end                    // if timer is not zero, skip
	    sw      t1, 0x0038(a0)              // store updated timer

        // stop this routine from running any more
	    addiu   t0, r0, 0x0001              // t0 = 1
	    sw      r0, 0x0014(a0)              // clear subroutine
	    sw      t0, 0x007C(a0)              // turn off this object

	    lw      t0, 0x0034(a0)              // t0 = 0 for right, 1 for left
	    bnez    t0, _left                   // if left exploded, recreate left one
	    nop                                 // otherwise create right one

	    // add new one
	    _right:
        li      a1, 0x453AE000              // right plat edge
        li      a2, 0x44000000              // slightly above plat
        lli     a0, stage.BOWSER_BOMB       // BOWSER_BOMB
        lli     a3, Stages.id.DREAM_LAND    // original stage ID
        li      t1, replenish_bowser_bombs_ // routine to run to check if this bomb needs to be recreated
        lli     t2, 0x0000                  // right bomb unique ID
        jal     add_item_
        lui     t0, 0xC3D0                  // create hover effect by specifying bottom ECB
        b       _end
        nop

        _left:
        li      a1, 0xC53AE000              // left plat edge
        li      a2, 0x44000000              // above 0
        lli     a0, stage.BOWSER_BOMB       // BOWSER_BOMB
        lli     a3, Stages.id.DREAM_LAND    // original stage ID
        li      t1, replenish_bowser_bombs_ // routine to run to check if this bomb needs to be recreated
        lli     t2, 0x0001                  // left bomb unique ID
        jal     add_item_
        lui     t0, 0xC3D0                  // create hover effect by specifying bottom ECB

	    _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

	    jr      ra                          // return
        nop
	}
    
    // @ Description
    // Hard coded patch for the RTTF bomb explosion subroutine 0x80184DC4.
    // Skips the shrapnel effect, sets the respawn flag, and plays a different FGM based on stage id.
    scope bowser_bomb_explosion_: {
        OS.patch_start(0xFF810, 0x80184DD0)
        j       bowser_bomb_explosion_
        nop
        _return:
        OS.patch_end()
        
        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        lli     t6, Stages.id.BOWSERB       // t6 = Stages.id.BOWSERB
        bne     t6, t7, _original           // run original subroutine if current stage != BOWSERB
        nop
        
        // 0x0080 in the bomb's object struct appears to be safe to use... it is set to 0 upon the
        // creation of the object (good) and seemingly not read from/written to after that, so we will
        // use it to hold the respawn flag for replenish_bowser_bombs_
        lw      t6, 0x0018(sp)              // t6 = bomb object struct
        ori     t7, r0, 0x0001              // ~
        sw      t7, 0x0080(t6)              // enable respawn flag
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x0001              // fgm id = 0x1
        j       0x80184DE8                  // return and skip shrapnel
        nop
        
        
        _original:
        jal     0x800269C0                  // original line 1 (play fgm)
        addiu   a0, r0, 0x0046              // original line 2
        j       _return
        nop
        
    }
    
    // @ Description
    // Hard coded patch for the RTTF bomb air collision(and physics?) subroutine 0x80184EDC.
    // Plays an alternate FGM based on stage id.
    scope bowser_bomb_air_collision_: {
        OS.patch_start(0xFF9C4, 0x80184F84)
        j       bowser_bomb_air_collision_
        addiu   a0, r0, 0x0047              // original line 2
        _return:
        OS.patch_end()
        
        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        lli     t6, Stages.id.BOWSERB       // t6 = Stages.id.BOWSERB
        bne     t6, t7, _end                // skip if current stage != BOWSERB
        nop
        
        addiu   a0, r0, 0x00C2              // new fgm id
        _end:
        jal     0x800269C0                  // play fgm (original line 1)
        nop
        j       _return
        nop
    }
    
    // @ Description
    // Applies extra hitstun to a player hit by a bowser bomb.
    scope bomb_hitstun_: {
        OS.patch_start(0xBB984, 0x80140F44)
        j       bomb_hitstun_
        nop
        _return:
        OS.patch_end()
        
        // check if the stage is BOWSERB
        li      t9, Global.match_info
        lw      t9, 0x0000(t9)              // t9 = match info
        lbu     t9, 0x0001(t9)              // t9 = current stage ID
        lli     t8, Stages.id.BOWSERB       // t8 = Stages.id.BOWSERB
        bne     t8, t9, _end                // skip if current stage != BOWSERB
        nop
        
        // check if px_object_hit_by is an item
        li      t9, object_hit_by_table     // ~
        lbu     t8, 0x000D(s0)              // ~
        sll     t8, t8, 0x2                 // ~
        addu    t9, t9, t8                  // t8 = px_object_hit_by address
        lw      t9, 0x0000(t9)              // t9 = px_object_hit_by
        li      t8, 0x80046700              // t8 = item list head
        lw      t8, 0x0000(t8)              // t8 = first "item" object
        _loop:
        beq     t8, r0, _end                // if current object = NULL, skip
        nop
        beq     t9, t8, _check_bomb         // if current object = px_object_hit_by, check for bowser bomb
        nop
        b       _loop                       // loop
        lw      t8, 0x0004(t8)              // t8 = next object
        
        
        _check_bomb:
        // check if px_object_hit_by is a bowser bomb
        ori     at, r0, 0x03F5              // at = GOBJ ID of bowser bomb hazard
        lw      v0, 0x0000(t8)              // v0 = GOBJ ID of current object
        bne     at, v0, _end                // if GOBJ ID does not match, skip
        nop
        ori     at, r0, 0x001A              // at = unique ID of RTTF bomb?
        lw      v0, 0x0084(t8)              // ~
        lw      v0, 0x000C(v0)              // v0 = unique ID of current object
        bne     at, v0, _end                // if ID does not match, skip
        
        // at this point we can reasonably assume the player is being hit by a bowser bomb
        // the bowser bomb will apply an extra multiplier to hitstun, formula for the multiplier is 9 / (GRAVITY + 4)
        // f0 = stun frames
        lw      v0, 0x09C8(s0)              // ~
        lw      v0, 0x0058(v0)              // ~
        mtc1    v0, f10                     // f10 = GRAVITY
        lui     at, 0x4080                  // ~
        mtc1    at, f12                     // f12 = 4
        add.s   f10, f10, f12               // f10 = GRAVITY + 4
        lui     at, 0x4110                  // ~
        mtc1    at, f12                     // f12 = 9
        div.s   f12, f12, f10               // f12 = 9 / (GRAVITY + 4)
        mul.s   f0, f0, f12                 // stun frames = stun frames * (9 / (GRAVITY + 4))
        
        _end:
        trunc.w.s f10, f0                   // original line 1
        mov.s   f12, f0                     // original line 2
        j       _return
        nop
    }
    
    // @ Description
    // Keeps track of the most recent object to hit each player.
    // TODO: this could be useful elsewhere, so move it somewhere outside of this file?
    scope track_hit_object_: {
        OS.patch_start(0x5F714, 0x800E3F14)
        j       track_hit_object_
        nop
        _return:
        OS.patch_end()
        
        li      s2, 0x801311C8              // original lines 1/2
        li      t8, object_hit_by_table     // ~
        lbu     at, 0x000D(s5)              // ~
        sll     at, at, 0x2                 // ~
        addu    t8, t8, at                  // t8 = px_object_hit_by address
        lw      at, 0x000C(s2)              // ~
        sw      at, 0x0000(t8)              // update px_object_hit_by
        
        _end:
        j       _return
        nop
    }
    
    object_hit_by_table:
    dw 0                                    // p1
    dw 0                                    // p2
    dw 0                                    // p3
    dw 0                                    // p4
    
    
    // @ Description
    // This establishes Jungle Japes hazard object in which rushing water is tied to
    scope jungle_japes_setup: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)
        
        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop
        
        addiu   a1, r0, r0                  // clear routine
        
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, rushing_water           // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004
        
        
        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address
        
        sw      r0, 0x0008(t1)              // clear spot used for timer
        
        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to klaptrap
        addiu   t3, t3, -0x07E8             // subtract offset amount to get to top of klaptrap file
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      t3, 0x0000(t2)              // save klaptrap header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save stage header address to second word of this struct, as Pirhana Plant does the same

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)
        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.KlapTrap.id        // set item id to klaptrap
        li      a2, klaptrap_coordinates    // location in which klaptrap spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        
        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0068
        jr      ra
        nop
    }
    
    klaptrap_coordinates:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    
    // @ Description
    // main routine for klaptrap
    scope klaptrap_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        
        sw      v1, 0x0024(sp)
        sw      a2, 0x0018(sp)            // save item special struct to stack
        
        
        
        li      t5, 0x801313F0
        lw      at, 0x0010(t5)
        addiu   t6, r0, 0x0001
        bne     at, t6, _timer_check
        lli     at, 0x0001              // ~
        sw      r0, 0x0010(t5)          // clear hitbox check
        sw      at, 0x010C(a2)          // enable hitbox
        sw      at, 0x0038(s0)          // make klaptrap visible again
        
        _timer_check:
        lw      t6, 0x0008(t5)          // load timer
        addiu   t7, t6, 0x0001          // add to timer
        addiu   at, r0, 0x0001 
        slti    t8, t6, 0x01E4          // wait 484 frames
        bne     t8, r0, _end            // if not 484 or greater, skip animation application, this is the initial check, klaptrap won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)          // save updated timer
        sw      t6, 0x0010(sp)          // save original timer
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x00A0          // decimal 160 possible integers
        lw      a0, 0x0020(sp)          // load registers
        addiu   t4, r0, 0x0050          // place 50 as the random number to spawn klaptrap
        beq     t4, v0, _spawn          // if 50, spawn klaptrap             
        addiu   t4, r0, 0x0258          // put in max time before klaptrap, 600 frames
        lw      t6, 0x0010(sp)          // load timer from stack
        bne     t4, t6, _end            // if not same as timer, skip animation
        nop

        // klaptrap is spawned
        _spawn:
        sw      r0, 0x0008(t5)          // restart timer
        li      t5, 0x801313F0
        addiu   at, r0, 0x0001
        sw      at, 0x0010(t5)          // save klaptrap spawn hitbox id
        li      at, 0xFFFFFFFF
        
        
        lw      t1, 0x0000(t5)          // load klaptrap file ram address
        addiu   t2, r0, 0x0908          // load in offset of animation track 1
        addiu   a2, r0, 0x0000          // clear out a2
            
        lw      a0, 0x0074(a0)          // unknown, investigate (probably relates to the object location)
        jal     0x8000BD1C              // animation track 1 set up
        addu    a1, t1, t2              // place animation track address in a1
        
        lui     t3, 0x8013
        lw      t3, 0x13F0(t3)          // load klaptrap file ram address
        addiu   t4, r0, 0x0E20          // offset to track 2
        lw      a0, 0x0080(a0)          // unknown, probably for image swapping
        jal     0x8000BD54              // set up track 2
        addu    a1, t3, t4              // place animation track address in a1
        //jal     0x8000DF34              // apply animation tracks
        //or      a0, s1, r0
        
        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        addu    v0, r0, r0 
    }
    
    // @ Description
    // Subroutine which sets up initial properties of klaptrap.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope klaptrap_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.KlapTrap.item_info_array
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        li      a3, klaptrap_coordinates
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, klaptrap_coordinates        // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object

        
        // item is created
        sw      r0, 0x0038(v0)                  // save to object struct to make klaptrap invisible
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        lw      t8, 0x0000(a2)                  // load x coordinate
        sw      t8, 0x0350(v1)                  // save initial x coordinates
        sw      t8, 0x001C(t9)                  // save initial x coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        
        lw      t7, 0x0004(a2)                  // load initial y coordinates
        sw      t7, 0x0354(v1)                  // save initial y coordinates
        sw      t8, 0x0020(t9)
        lw      t8, 0x0008(a2)                  // load initial z coordinates
        sw      t8, 0x0358(v1)                  // save initial z coordinates
        sw      t8, 0x0024(t9)
        
        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag
        sw      r0, 0x010C(v1)                  // disable hitbox

        
        
        
        addiu   t4, r0, 0x00014                 // hitbox damage set to 20
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0270                  // spike hitbox angle
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        // 0x0118 damage multiplier
        addiu   t4, r0, 0x0003                  // slash effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x3 = slash
        addiu   t4, r0, 0x0105                  // heavy slash sound ID
        sh      t4, 0x0156(v1)                  // save hitbox sound to heavy slash (could also do bat ping 0x34)
        addiu   t4, r0, 0x0100                  // put hitbox bkb at 100
        sw      t4, 0x0148(v1)                  // set hitbox bkb 
        sw      t4, 0x0140(v1)                  // set hitbox kbs
        
        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x0248(v1)                  // disable hurtbox
        // sw      r0, 0x01CC(v1)               // rotation direction = 0
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, klaptrap_blast_zone_        // load klaptrap blast zone routine
        sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

        _end:
        or      v0, a0, r0                      // v0 = item object
        lw      s0, 0x0020(sp)                  // ~
        lw      s1, 0x0024(sp)                  // ~
        lw      ra, 0x0028(sp)                  // load s0, s1, ra
        jr      ra                              // return
        addiu   sp, sp, 0x0060                  // deallocate stack space
    }
    

    // @ Description
    // this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to restock Conker's grenades
    scope klaptrap_blast_zone_: {
        sw      r0, 0x010C(a2)                  // disable hitbox
        lw      t9, 0x0074(a0)
        li      t1, klaptrap_coordinates
        lw      t8, 0x0000(t1)                  // load x coordinates
        sw      t8, 0x0350(a2)                  // save x coordinates
        sw      t8, 0x001C(t9)
        
        lw      t8, 0x0004(t1)                  // load y coordinates
        sw      t8, 0x0354(a2)                  // save y coordinates
        
        j       0x8016F8C0                      // jump to address that bomb/grenade normally goes to
        sw      r0, 0x0038(s0)                  // make klaptrap invisible
    }
    
    // @ Description
    // Room ordering fix for Klaptrap.
    scope klaptrap_room_: {
        OS.patch_start(0xE8C1C, 0x8016E1DC)
        j       klaptrap_room_
        lli     t8, Stages.id.BTP_MTWO      // t0 = Stages.id.BTP_MTWO
        _return:
        OS.patch_end()
        
		li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID
        bne     t6, t8, _klaptrap_check     // if current stage is not Mewtwo's Board the Platforms, then do klaptrap check
		lw      t6, 0x0000(t0)              // load item id
        lli     t8, stage.RTTF_BOMB         // load RTTF Bomb ID
        bne     t6, t8, _klaptrap_check     // if not RTTF Bomb, branch to klaptrap check
        nop
        li      t6, 0x8013141C              // load location of RTTF Ram address when in Mewtwo BTP
        j       _return
        addiu   a2, r0, 0x000B              // original line 1
        
        _klaptrap_check:
        lli     t8, Item.KlapTrap.id
        bnel    t6, t8, _end
        addiu   a2, r0, 0x000B              // original line 1
        addiu   a2, r0, 0x0004              // proper room for klaptrap

        _end:
        j       _return
        lw      t6, 0x0004(t0)              // original line 2
    }
    
    // @ Description
    // Jungle Japes Rushing Water Routine based on Dreamland's wind at 0x8010595C
    // This routine is fairly simple. It pulls the global player struct head and loops through to check each player
    // it then checks how low the player is, if beneath a certain point it will subtract from the players position and save a new location, moving the player leftward
    // a0 = rushing water object struct
    scope rushing_water: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        sw      a0, 0x0000(sp)
        
        addiu   t1, r0, 0x0003            // establishes counter for loop
        // player structs loaded in
        li      v1, Global.p_struct_head  // v1= pointer to player struct linked list
        _loop:
        lw      v1, 0x0000(v1)            // v1 = 1p player struct address
        beqz    v1, _player_loop          // if player is not initialized skips
        lw      t5, 0x0004(v1)            // load player object pointer
        beqz    t5, _player_loop          // check to see if player is loaded by checking to see if there's a pointer to the player object
        nop

        // player data loaded
        _player_data:
        lw      v0, 0x0078(v1)            // load address of location struct of player
        lwc1    f0, 0x0000(v0)            // loads player's x position
        lwc1    f2, 0x0004(v0)            // loads player's y position

        // loading parameters of wind effect
        lui     at, 0xc47a                // y address where rushing water effect becomes active
        mtc1    at, f22                   // move to floating point
        li      t9, under_water_table     // ~
        lbu     t8, 0x000D(v1)            // ~
        sll     t8, t8, 0x2               // ~
        addu    t9, t9, t8                // t9 = px_under_water address
        // location checks begin
        // vertical checks
        c.le.s  f2, f22                   // compare player location to beginning of water
        nop
        bc1fl   _player_loop              // branch taken if player is too high for effect to work
        sw      r0, 0x0000(t9)            // clear out table location as player is now above water
        
        addiu   t3, r0, 0x0001            // load flag for already under water
        
        lw      t8, 0x0000(t9)            // t8 = px_under_water flag
        beq     t8, t3, _position_calculation // skip fgm if already under water
        
        sw      v1, 0x0010(sp)            // save v1 to stack
        sw      v0, 0x000C(sp)            // save v0 to stack
        sw      t1, 0x0008(sp)            // save t1 to stack
        sw      t3, 0x0000(t9)            // save 1 to player's under_water_table     
        jal     0x800269C0                // play fgm
        addiu   a0, r0, 0x03D1            // fgm id = 0x3D1 (Splash)
        lw      v1, 0x0010(sp)            // load from stack to v1
        lw      v0, 0x000C(sp)            // load from stack 
        lw      t1, 0x0008(sp)            // load from stack to v1
        
         
        //mtc1    r0, f18
        //lw      at, 0x004C(v1)            // load player velocity
        //mtc1    at, f16                   // move velocity to floating point register
        //c.lt.s  f16, f18                  // compare player velocity to zero
        //nop
        //bc1f    _position_calculation     // if velocity is greater than or equal to 0, skip splash fgm
        //nop
        
        

        // the calculation of player's new position
        _position_calculation:
        li      at, Toggles.entry_hazard_mode
        lw      at, 0x0004(at)
        bne     at, r0, _player_loop
        
        lui     at, 0x42b4                // water speed (90)
        mtc1    at, f4                    // water speed put into floating point

        li      at, 0xc4034000            // load set number subtracted from current player position to determine rate of movement (based on Whispy)
        mtc1    at, f22
        sub.s   f2, f0, f20               // subtraction of set amount in location calculation
        li      at, 0x3A1D4952            // multiplier used by whispy and reused here
        mtc1    at, f6                    // move whispy multiplier to floating point
        mul.s   f8, f2, f6                // multiply by whispy multiplier
        sub.s   f8, f4, f8                // subtract product from water speed

        sub.s   f0, f0, f8                // subtract amount from player x position

        _set_new_position:                // this was based on 800E86B4 (from whispy) but tweaked to work within a player action, but really nothing remains at all
        swc1    f0, 0x0000(v0)            // new location data saved [ this doesn't work right when player moves rightwards)
        // swc1    f0, 0x00a4(v1)            // new location data saved, this is what Dreamland does but a function wipes this area out and our routine doesn't time it right

        _player_loop:
        bnel    t1, r0, _loop
        addiu   t1, t1, -0x0001
        
        lw      ra, 0x0014(sp)
        lw      a0, 0x0000(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    under_water_table:
    dw 0                                    // p1
    dw 0                                    // p2
    dw 0                                    // p3
    dw 0                                    // p4
    
    // @ Description
    // This establishes Corneria hazard object in which lasers are fired
    scope corneria_setup: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        
        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop
        
        jal     0x80107FCC                  // run normal Sector Z hard routine
        nop
        
        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, great_fox_              // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004
        li      t1, 0x801313F0
        sw      r0, 0x0060(t1)
        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }

    // @ Description
    // Corneria Laser routine based on Arwings
    // This code is responsible for firing the lasers of the great fox, it is largely reliant on the arwing's coding
    // If the Corneria Stage is ever updated, the header will need to be modified by adding the hitbox information to it
    // We have modified file a1 in Remix, so that other stages can have the arwing flying
    // These files have the arwings hitbox (and pointer to the projectile graphic) in their headers and I added an additional one there for the great fox
    // all stages use 0x99F instead of the normal sector z file 2
    // a0 = great fox laser object
    scope great_fox_: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)
        sw      a0, 0x0000(sp)
        sw      s0, 0x0004(sp)
  
        li      t0, 0x801313F0          // load hardcoded stage struct
        lw      t6, 0x0060(t0)          // load timer
        addiu   t2, t6, 0x0001          // add 1 to timer
        addiu   at, r0, 0x010E          // timer amount for lasers
        beq     t6, at, _fire           // first shot jump
        sw      t2, 0x0060(t0)          // save updated timer
        addiu   at, r0, 0x97E
        beq     t6, at, _fire           // second shot jump
        addiu   at, r0, 0x987
        beq     t6, at, _fire           // third shot jump
        addiu   at, r0, 0x990
        beq     t6, at, _fire           // fourth shot jump
        addiu   at, r0, 0x999
        beq     t6, at, _fire           // fifth shot jump
        addiu   at, r0, 0x9A2
        beq     t6, at, _fire           // sixth shot jump
        addiu   at, r0, 0x9AB
        beq     t6, at, _fire           // seventh shot jump
        addiu   at, r0, 0x9B4
        beq     t6, at, _fire           // eighth shot jump
        addiu   at, r0, 0x9BD
        beq     t6, at, _fire           // ninth shot jump
        addiu   at, r0, 0x9C6
        beq     t6, at, _fire           // tenth shot jump
        addiu   at, r0, 0x107D
        beql    t6, at, _end            // tenth shot jump
        sw      r0, 0x0060(t0)          // restart timer
        beq     r0, r0, _end            // no shot, so jump to end
        nop
     

        _fire:
        li      a1, great_fox_projectile_struct // a1 = main projectile struct address
        li      a2, great_fox_spawn_location    // a2, spawn location x/y/z      
        
        jal     0x801655C8          // generic projectile stage setting that establishes much of what a projectile is
        addiu   a3, r0, 0x0001      // I believe this makes the projectile hit all players
        
       
        beq     v0, r0, _end        // jump to end if spawn projectile fails
        lui     at, 0xC366
        
        lw      v1, 0x0084(v0)
        mtc1    at, f18
        mtc1    r0, f0
        lui     at, 0xBF80
        swc1    f18, 0x0020(v1)
        mtc1    at, f4
        sw      v0, 0x0064(sp)
        addiu   a0, sp, 0x0024
        addiu   a1, sp, 0x0030
        swc1    f0, 0x0028(sp)
        swc1    f0, 0x002C(sp)
        
        jal     0x8010719C          // determines projectile velocity
        swc1    f4, 0x0024(sp)
        
        
        // projectile rotation left shot
        lw      a3, 0x0064(sp)      // load object struct for projectile
        li      t1, great_fox_spawn_rotation    // load rotation pointer
        lw      t9, 0x0074(a3)      // load positional struct from projectilesobject struct
        lw      t3, 0x0000(t1)      // load x rotation
        sw      t3, 0x0030(t9)      // save x rotation
        lw      t3, 0x0004(t1)      // load y rotation
        sw      t3, 0x0034(t9)      // save y rotation
        lw      t3, 0x0008(t1)      // load z rotation
        sw      t3, 0x0038(t9)      // save z rotation
        
       
        li      a1, great_fox_projectile_struct  // a1 = main projectile struct address
        
        lw      a0, 0x0000(sp)          // load Great Fox Object Struct
        li      a2, great_fox_spawn_location_2  // load x/y/z of projectile spawn location 2      
        
        jal     0x801655C8              // generic projectile stage setting that establishes much of what a projectile is
        addiu   a3, r0, 0x0001          // believe this makes the projectile hit all players
        
        beq     v0, r0, _end            // jump to end if spawn projectile fails
        lui     at, 0xC366
        lw      v1, 0x0084(v0)          
        mtc1    at, f4                  // unknown
        
        // projectile rotation right shot
        li      t9, great_fox_spawn_rotation    // load rotation pointer
        swc1    f4, 0x0020(v1)          // unknown        
        lw      t2, 0x0000(t9)          // load x rotation
        lw      t8, 0x0074(v0)          // load positional struct from projectiles object struct       
        sw      t2, 0x0030(t8)          // save x rotation
        lw      t1, 0x0004(t9)          // load y rotation
        sw      t1, 0x0034(t8)          // save y rotation
        lw      t2, 0x0008(t9)          // load z rotation
        sw      t2, 0x0038(t8)          // save z rotation
                                        
        
        _end:
        lw      ra, 0x0014(sp)          // load ra
        lw      a0, 0x0000(sp)          // load great fox object
        lw      s0, 0x0004(sp)
        addiu   sp, sp, 0x0068
        
        jr      ra
        nop
    }
    
    great_fox_spawn_location:
    dw  0xc541c000           // x
    dw  0xc3660000           // y
    dw  0x43480000           // z
    
    great_fox_spawn_location_2:
    dw  0xc541c000           // x
    dw  0xc3660000           // y
    dw  0xc2c80000           // y
    
    great_fox_spawn_rotation:
    dw  0xBFC90FDB           // x
    dw  0xBF978C23           // y
    dw  0x3FC90FDB           // z
    
    OS.align(16)
    great_fox_projectile_struct:
    dw 0x00000000                     // unknown
    dw 0x00000012                     // projectile id (Arwing's)
    dw 0x80131428                     // address of hitbox and graphic pointer for stage header
    dw 0x00000130                     // offset to hitbox added to header (normally 0xBC for regular arwing shot)
    dw 0x1B000000                     // This determines z axis rotation? (samus is 1246)
    dw 0x00000000                     // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x80107030                     // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw 0x80107074                     // This function runs when the projectile collides with a hurtbox.
    dw 0x80107074                     // This function runs when the projectile collides with a shield.
    dw 0x80107238                     // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0x80107074                     // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801072C0                     // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0x80107074                     // This function runs when the projectile collides with Ness's psi magnet
    dw 0x00000000
    dw 0x00000013
    dw 0x80131428
    
    // @ Description
    // This establishes GB Land Sound Effect and Music Changes
    scope gbland_setup: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen_id
        ori     t1, r0, 0x0036              // ~
        beq     t0, t1, _end                // skip if screen_id = training mode
        nop
        
        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, gb_music_               // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004
        li      t1, 0x801313F0
        sw      r0, 0x0060(t1)              // clear timer
        sw      r0, 0x0004(t1)              // clear transition flag
        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // @ Description
    // Operates sounds and music for gameboy land
    // a0 = object
    scope gb_music_: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
        sw      a0, 0x0000(sp)
        sw      s0, 0x0004(sp)
        
        li      t0, 0x801313F0          // load hardcoded stage struct
        sw      t0, 0x0030(sp)          // save struct
        lw      t6, 0x0060(t0)          // load timer
        addiu   t2, t6, 0x0001          // add 1 to timer
        sw      t2, 0x0060(t0)          // save updated timer
        
        
        
        music_stop:
        beqz    t6, _mute               // skip stoping music after initial loop
        nop

        _skip_mute:
        addiu   at, r0, 0x00B4          // timer amount for gameboy sound
        beq     t6, at, _beep           // skip if past timer
        nop
               
        
        _skip_beep:
        addiu   at, r0, 0x0188
        slt     t7, t6, at
        bnez    t7, _end                // if not at frame 188, skip to end
        nop
        
        li      t7, 0x8013139C          // load address of currently playing song
        lw      t7, 0x0004(t7)          // load currently playing song
        addiu   a1, r0, {MIDI.id.GB_MEDLEY}
        bne     t7, a1, _random_check
        lw      t0, 0x0030(sp)          // load struct
        
        lw      t3, 0x0004(t0)          // load transition skip flag
        bnez    t3, _end                // skip to end
        nop
        
       
        jal     BGM.play_               // play music
        addiu   a0, r0, r0              // needs to be 0 for some reason
        lw      t0, 0x0030(sp)          // load struct
        addiu   t5, r0, 0x0001
        beq     r0, r0, _end            // play Gameboy Medley
        sw      t5, 0x0004(t0)          // save to skip transitions flag address
        
        _random_check:
        li      t9, Toggles.entry_random_music
        lw      t9, 0x0004(t9)          // t0 = random_music (off when t9 = 0)
        beqz    t9, _transitions
        lw      t0, 0x0030(sp)          // load struct
        
        lw      t3, 0x0004(t0)          // load transition skip flag
        bnez    t3, _end                // skip to end
        nop
        
        addu    a1, r0, t7              // move stage song to a1
        jal     BGM.play_               // play music
        addiu   a0, r0, r0              // needs to be 0 for some reason
        lw      t0, 0x0030(sp)          // load struct
        addiu   t5, r0, 0x0001
        beq     r0, r0, _play           // play random song
        sw      t5, 0x0004(t0)          // save to skip transitions flag address
        
        _transitions:
        beq     t6, at, _play           // play muda
        addiu   a1, r0, {MIDI.id.MUDA}
        
        addiu   at, r0, 0x0CC8
        beq     t6, at, _beep           // stop muda
        addiu   at, r0, 0x0D40
        
        beq     t6, at, _play           // start bubbly
        addiu   a1, r0, {MIDI.id.BUBBLY}
        addiu   at, r0, 0x1880
        
        beq     t6, at, _beep           // stop bubbly
        addiu   at, r0, 0x18F8
        
        beq     t6, at, _play           // start road to cerulean 
        addiu   a1, r0, {MIDI.id.ROADTOCERULEANCITY}
        addiu   at, r0, 0x2439
        
        beq     t6, at, _beep           // stop cerulean
        addiu   at, r0, 0x24B0
        
        beq     t6, at, _play           // start Stage 1 Music
        addiu   a1, r0, {MIDI.id.LEVEL1_WARIO}
        addiu   at, r0, 0x2FF0
        
        beq     t6, at, _beep           // stop stage 1 music
        addiu   at, r0, 0x3068
        
        beq     t6, at, _play           // start mabe
        addiu   a1, r0, {MIDI.id.MABE}
        addiu   at, r0, 0x3BA8
        
        beq     t6, at, _beep           // stop mabe
        addiu   t1, r0, 0x0188
        
        addiu   at, r0, 0x3C20          
        beql    t6, at, _end            // restart timer branch
        sw      t1, 0x0060(t0)          // restart timer
        beq     r0, r0, _end            // no shot, so jump to end
        nop
     
        _mute:
        jal     BGM.stop_               // stop music
        nop
        beq     r0, r0, _end
        nop
        
        _beep:
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x03D2          // fgm id = gameboy_startup_sound
        beq     r0, r0, _mute
        nop

        _play:
        li      t1, 0x8013139C          // load address of currently playing song
        lw      t2, 0x0000(t1)          // load currently playing song
        addiu   t3, r0, 0x002D
        beq     t2, t3, _end
        addiu   t3, r0, 0x002E
        beq     t2, t3, _end
        nop
        // NEED A WAY TO HAVE THIS ONLY FUNCTION WHEN MAIN THEME PLAYS
        //addiu   t4, r0, 0x00A2
        //slt     t5, t2, t4
        //bnez    t5, _end
        //addiu   t4, r0, 0x00A6
        //slt     t5, t4, t2
        //bnez    t5, _end
        addiu   a0, r0, r0              // needs to be 0 for some reason
        sw      a1, 0x0000(t1)          // save song to stage song (it will play after star or
        jal     BGM.play_               // play music
        sw      a1, 0x0004(t1)          // save song to stage song (it will play after star or hammer ends)
        
        _end:
        lw      ra, 0x0014(sp)          // load ra
        lw      a0, 0x0000(sp)          // load object
        lw      s0, 0x0004(sp)
        addiu   sp, sp, 0x0040
        
        jr      ra
        nop
    }
    
//    // @ Description
//    // Spawns the RTTF bombs used on Mewtwo's Board the Platforms
//    scope mtwo_btp_setup: {
//        addiu   sp, sp, -0x0020
//        sw      ra, 0x0014(sp)
//        
//        jal     0x8010B4D0          // establish stage free space to work with bombs
//        nop
//        
//        jal     0x8010B660          // setups up bomb spawning object
//        nop
//        
//        _end:
//        lw      ra, 0x0014(sp)
//        addiu   sp, sp, 0x0020
//        jr      ra
//        nop
//    }
    
    // @ Description
    // Adds rolling bombs to mewtwos board the platforms
    scope mtwo_btp_setup: {
        OS.patch_start(0x11228C, 0x8018DB24)
        jal     mtwo_btp_setup
        lli     v1, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
		return:
        OS.patch_end()

		li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        bne     a1, v1, _normal     		// if current stage is not Mewtwo's Board the Platforms, then do normal functions
		nop

        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        sw      t6, 0x0004(sp)
        // the code below is to replace a jal to   0x8010B4D0
        // it establishes stage free space to work with bombs
        // needed to be moved to accomodate targets
        lui     v0, 0x8013
        lw      v0, 0x1300(v0)             // load hardcoded stage pointer
        lui     t7, 0x0000
        lui     t9, 0x0000
        lw      t6, 0x0080(v0)
        lui     v1, 0x8013
        addiu   t7, t7, 0x0000
        addiu   t9, t9, 0x0000
        addiu   v1, v1, 0x13F0              // load to stage free space
        subu    t0, v0, t9
        subu    t8, t6, t7
        sw      t8, 0x0028(v1)              // save RTF bomb relevant pointer
        sw      t0, 0x002C(v1)              // save RTF bomb relevant pointer
        li      t0, 0x45960000              // floating point for bomb spawn point X (4800)
        sw      t0, 0x0030(v1)              // save X address
        li      t0, 0x45834000              // floating point for bomb spawn point Y (4200)
        sw      t0, 0x0034(v1)              // save Y address
        jal     0x8010B660                  // setups up bomb spawning object
        sw      r0, 0x0038(v1)              // save Z address in the interest of caution
        lw      t6, 0x0004(sp) 
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14
		
		_normal:
        lw      a1, 0x0080(t6)              // original line 1
		jr		ra
		lui     v1, 0x800A                  // original line 2
    }
    
    // @ Description
    // Changes how bombs position are set
    scope mtwo_btp_bomb_position: {
        OS.patch_start(0x86E1C, 0x8010B61C)
        j       mtwo_btp_bomb_position
        lli     a0, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
		return:
        OS.patch_end()

		li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        bnel    a1, a0, _normal     		// if current stage is not Mewtwo's Board the Platforms, then do normal functions
		addiu   a2, a2, 0x13F8              // original line 1

        addiu   a2, a2, 0x1420              // x and y as done in m2 btp
        
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14
		
		_normal:            
		j       return  
		or      a0, r0, r0                  // original line 2
    }
    
    // @ Description
    // Changes how bombs explosions are loaded
    scope mtwo_btp_bomb_explosion_1: {
        OS.patch_start(0xFF614, 0x80184BD4)
        j       mtwo_btp_bomb_explosion_1
        lli     at, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
		return:
        OS.patch_end()

		li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        bne     t7, at, _normal     		// if current stage is not Mewtwo's Board the Platforms, then do normal functions
		lui     at, 0xC1C0                  // original line 1

        li      t7, 0x8013141C              // load in new address for pointer
        j       return
        nop
        
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14
		
		_normal:            
		j       return  
		lw      t7, 0x0004(v0)              // original line 2
    }
    
    // @ Description
    // Changes how bombs explosions are loaded
    scope mtwo_btp_bomb_explosion_2: {
        OS.patch_start(0xFFC98, 0x80185258)
        j       mtwo_btp_bomb_explosion_2
        lli     t8, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
		return:
        OS.patch_end()

		li      t9, Global.match_info
        lw      t9, 0x0000(t9)              // t7 = match info
        lbu     t9, 0x0001(t9)              // t7 = current stage ID
        bne     t9, t8, _normal     		// if current stage is not Mewtwo's Board the Platforms, then do normal functions
		lui     t9, 0x0000                  // original line 2

        li      t7, 0x8013141C              // load in new address for pointer
        j       return
        nop
        
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14
		
		_normal:            
		j       return  
		lw      t7, 0xB5A4(t7)              // original line 1
    }
    
    // @ Description
    // Changes how bombs explosions are loaded
    scope mtwo_btp_bomb_explosion_3: {
        OS.patch_start(0xFFA44, 0x80185004)
        j       mtwo_btp_bomb_explosion_3
        lli     a1, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
		return:
        OS.patch_end()

		li      t1, Global.match_info
        lw      t1, 0x0000(t1)              // t7 = match info
        lbu     t1, 0x0001(t1)              // t7 = current stage ID
        bne     t1, a1, _normal     		// if current stage is not Mewtwo's Board the Platforms, then do normal functions
		lui     t1, 0x0000                  // original line 2

        li      t9, 0x8013141C              // load in new address for pointer
        j       return
        nop
        
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14
		
		_normal:            
		j       return  
		lw      t9, 0xB5A4(t9)              // original line 1
    }
    
     // @ Description
     // Changes wind parameters for Dream Greens
     scope dream_greens_wind: {
         OS.patch_start(0x811A0, 0x801059A0)
         j       dream_greens_wind
         lwc1    f30, 0x0A94(at)             // original line 1
  		return:
         OS.patch_end()
         addiu   v1, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		li      at, Global.match_info
         lw      at, 0x0000(at)              // at = match info
         lbu     at, 0x0001(at)              // at = current stage ID
         bne     v1, at, _normal     		// if current stage is not Dream Greens, then do normal settings
  		lui     at, 0x8013                  // original line 2
         
  
         li      v1, 0x456e3000              // load in new max right
         mtc1    v1, f30
         li      v1, 0xc56e3000              // load in new max left
         mtc1    v1, f28
         mtc1    r0, f20                     // load in new center X
         mtc1    r0, f22                     // load in center Y?
         lui     v1, 0x447A                  // max high
         mtc1    v1, f24
         lui     v1, 0xC120                  // load in max low
         j       0x801059C8                  // skip loading f28 normally
         mtc1    v1, f26
         
  		_normal:            
  		j       return  
  		nop
     }
     
     // @ Description
     // Changes hardcoding for Dream Greens
     scope dream_greens_hardcoding_1: {
         OS.patch_start(0x81DAC, 0x801065AC)
         j       dream_greens_hardcoding_1
         addiu   a1, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      a3, Global.match_info
         lw      a3, 0x0000(a3)              // a3 = match info
         lbu     a3, 0x0001(a3)              // a3 = current stage ID
         bnel    a1, a3, _normal     		// if current stage is not Dream Greens, then do normal settings
  		addiu   a0, a0, 0x10F0              // original line 1
         
         lui     a2, 0x8010                  // original line 2
         addiu   a0, a0, 0x0158              // hardcoding fix 1
         addiu   s0, s0, 0x13F0              
         addiu   a2, a2, 0x4D90
         lui     a1, 0x0000
         subu    t8, t7, a0
         sw      t8, 0x0000(s0)
         j       0x801065CC                  // jump to correct spot
         addiu   a1, a1, 0x0298              // hardcoding fix 2
         
         
  		_normal:            
  		j       return  
  		lui     a2, 0x8010                  // original line 2
     }
     
     // @ Description
     // Changes hardcoding for Dream Greens
     scope dream_greens_hardcoding_2: {
         OS.patch_start(0x81DE4, 0x801065E4)
         j       dream_greens_hardcoding_2
         addiu   a2, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      a3, Global.match_info
         lw      a3, 0x0000(a3)              // a3 = match info
         lbu     a3, 0x0001(a3)              // a3 = current stage ID
         bnel    a2, a3, _normal     		// if current stage is not Dream Greens, then do normal settings
  		addiu   a1, a1, 0x13B0              // original line 1
         
         addiu   a1, a1, 0x0960              // hardcoding 1
         j       return
         addiu   a0, a0, 0x0798              // hardcoding 2
         
         
  		_normal:            
  		j       return  
  		addiu   a0, a0, 0x1770              // original line 2
     }
     
     // @ Description
     // Changes hardcoding for Dream Greens
     scope dream_greens_hardcoding_3: {
         OS.patch_start(0x81E00, 0x80106600)
         j       dream_greens_hardcoding_3
         addiu   a2, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      a3, Global.match_info
         lw      a3, 0x0000(a3)              // a3 = match info
         lbu     a3, 0x0001(a3)              // a3 = current stage ID
         bnel    a2, a3, _normal     		// if current stage is not Dream Greens, then do normal settings
  		addiu   a0, a0, 0x2A80              // original line 1
         
         addiu   a0, a0, 0x1A20              // hardcoding 1       
         
  		_normal:            
  		j       return  
  		or      a1, r0, r0                  // original line 2
     }
     
     // @ Description
     // Changes hardcoding for Dream Greens
     scope dream_greens_hardcoding_4: {
         OS.patch_start(0x81E24, 0x80106624)
         j       dream_greens_hardcoding_4
         addiu   a1, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      a3, Global.match_info
         lw      a3, 0x0000(a3)              // a3 = match info
         lbu     a3, 0x0001(a3)              // a3 = current stage ID
         bnel    a1, a3, _normal     		// if current stage is not Dream Greens, then do normal settings
  		addiu   a0, a0, 0x31F8              // original line 1
         
         addiu   a0, a0, 0x2190              // hardcoding 1       
         
  		_normal:            
  		j       return  
  		or      a1, r0, r0                  // original line 2
    }
    
    insert DREAM_GREENS_OFFSETS,"stages/dream_greens_offsets.bin"
   
    // @ Description
    // Changes hardcoding for Dream Greens animation
     scope dream_greens_hardcoding_animation_1: {
         OS.patch_start(0x81B4C, 0x8010634C)
         j       dream_greens_hardcoding_animation_1
         addiu   t0, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      v1, Global.match_info
        lw      v1, 0x0000(v1)              // v1 = match info
        lbu     v1, 0x0001(v1)              // v1 = current stage ID
        bnel    t0, v1, _normal     		// if current stage is not Dream Greens, then do normal settings
  		addiu   t1, t1, 0xE870              // original line 1
         
        li      t1, DREAM_GREENS_OFFSETS    // hardcoding 1 
         
  		_normal:            
  		j       return  
  		addu    t0, t9, t1                  // original line 2
    }
    
    // @ Description
    // Changes hardcoding for Dream Greens animation
     scope dream_greens_hardcoding_animation_2: {
         OS.patch_start(0x81B98, 0x80106398)
         j       dream_greens_hardcoding_animation_2
         addiu   t5, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        bnel    t5, t7, _normal     		// if current stage is not Dream Greens, then do normal settings
  		lui     t7, 0x8013                  // original line 1
         
        li      t7, DREAM_GREENS_OFFSETS    // hardcoding 1 
        j       return
        addiu   t7, t7, 0x0020              // additional offsetting 
         
  		_normal:            
  		j       return  
  		addiu   t7, t7,0xE890               // original line 2
    }
    
    // @ Description
    // Changes hardcoding for Dream Greens animation
     scope dream_greens_hardcoding_animation_3: {
         OS.patch_start(0x81C14, 0x80106414)
         j       dream_greens_hardcoding_animation_3
         addiu   a2, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
         OS.patch_end()
        
  		li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        bnel    a2, a1, _normal     		// if current stage is not Dream Greens, then do normal settings
  		lw      t5, 0xE8D0(t5)              // original line 1
        
        li      t5, DREAM_GREENS_OFFSETS    // hardcoding 1 
        addu    t5, t5, t4                  // additional offset
        lw      t5, 0x0060(t5)              // load offset
         
  		_normal:            
  		j       return  
  		addiu   a2, r0,0x0000               // original line 2
    }
    
    // @ Description
    // Changes hardcoding for Dream Greens animation
    scope dream_greens_hardcoding_animation_4: {
        OS.patch_start(0x81C60, 0x80106460)
        j       dream_greens_hardcoding_animation_4
        addiu   a2, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
  		return:
        OS.patch_end()
        
  		li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        bnel    a2, a1, _normal     		// if current stage is not Dream Greens, then do normal settings
  		lw      t2, 0xE8E8(t2)              // original line 1
        
        li      t2, DREAM_GREENS_OFFSETS    // hardcoding 1 
        addu    t2, t2, t1                  // additional offset
        lw      t2, 0x0078(t2)              // load offset
         
  		_normal:            
  		j       return  
  		addiu   a2, r0,0x0000               // original line 2
    }
   
//   // @ Description
//   // Changes hardcoding for Dream Greens
//   scope dream_greens_hardcoding_5: {
//       OS.patch_start(0x81EAC, 0x801066AC)
//       j       dream_greens_hardcoding_5
//       addiu   t6, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
//		return:
//       OS.patch_end()
//      
//		li      at, Global.match_info
//       lw      at, 0x0000(at)              // at = match info
//       lbu     at, 0x0001(at)              // at = current stage ID
//       bnel    t6, at, _normal     		// if current stage is not Dream Greens, then do normal settings
//		addiu   a3, a3, 0xa880              // original line 1
//       
//       addiu   a3, a3, 0x1E10              // hardcoding 1     
//       addiu   a2, a2, 0x0C90              // hardcoding 2 
//       addiu   a1, a1, 0x0C90              // hardcoding 3
//       jal     0x801159F8                  // run subroutine 
//       addiu   a0, a0, 0x0AF0              // hardcoding 4
//       j       0x801066C0
//       nop
//       
//		_normal:            
//		j       return  
//		addiu   a2, a2, 0x9700              // original line 2
//   }
//   
//   // @ Description
//   // Changes hardcoding for Dream Greens
//   scope dream_greens_hardcoding_6: {
//       OS.patch_start(0x81E88, 0x80106688)
//       j       dream_greens_hardcoding_6
//       addiu   t6, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
//		return:
//       OS.patch_end()
//      
//		li      at, Global.match_info
//       lw      at, 0x0000(at)              // at = match info
//       lbu     at, 0x0001(at)              // at = current stage ID
//       bnel    t6, at, _normal     		// if current stage is not Dream Greens, then do normal settings
//		lui     a0, 0x0146                  // original line 1
//       
//       lui     a0, 0x00B2                  // hardcoding 1 
//       lui     a1, 0x00B2                  // hardcoding 2 
//       lui     a2, 0x00B2                  // hardcoding 3
//       j       0x80106698                  // jump to the correct spot
//       lui     a3, 0x00B2                  // hardcoding 4
//       
//		_normal:            
//		j       return  
//		lui     a1, 0x0146                  // original line 1
//   }
}


} // __HAZARDS__
