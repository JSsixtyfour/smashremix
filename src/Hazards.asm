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
        sw      ra, 0x0008(sp)              // save registers

        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        variable _end(pc() + 4 * 3)
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        jal     {function_address}          // original line 1
        nop                                 // original line 2

        // _end:
        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // restore registers
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
        li      a1, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a1)              // a1 = hazard_mode (hazards disabled when a1 = 1 or 3)
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        lui     at, 0x8013                  // ~
        lwc1    f4, 0xEB1C(at)              // f4 = correct camera position
        lui     at, 0x8013                  // ~
        swc1    f4, 0x13FC(at)              // store correct camera position

        bnezl   a1, _end                    // if hazard_mode is on, don't create acid object
        addiu   sp, sp, 0x0020              // original line before original jr ra

        addiu   a0, r0, 0x03F2              // original line 1
        or      a1, r0, r0                  // original line 2
        j       _no_hazards_check_return
        nop

        _no_movement_check:
        li      a1, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a1)              // a1 = hazard_mode (hazards disabled when a1 = 2 or 3)
        srl     a1, a1, 0x0001              // a1 = 1 if hazard_mode is 2 or 3, 0 otherwise

        bnez    a1, _end                    // if hazard_mode is on, don't allow acid to rise
        nop

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     0x801082B4                  // original line 1
        nop                                 // original line 2

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop

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
        sw      ra, 0x0008(sp)              // save registers

        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

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
        nop
        bnez    v1, _end                    // if current stage is not Peach's Castle (stage_id = 0), then always disable bumper
        nop
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
        b       _original
        nop

        _norfair:
        li      t6, norfair_lava_levels     // t6 = norfair_lava_levels
        // uncomment below 2 lines if we do more levels with custom lava
        //b       _loop_setup
        //nop

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

}


} // __HAZARDS__
