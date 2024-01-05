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
    // Describes the types of stage hazards available
    scope type {
        constant NONE(0x00)
        constant HAZARDS(0x01)
        constant MOVEMENT(0x02)
        constant BOTH(0x03)
    }

    // @ Description
    // Constants for hazard mode
    scope mode {
        constant HAZARDS_OFF_MOVEMENT_OFF(0b0011)
        constant HAZARDS_ON_MOVEMENT_OFF(0b0010)
        constant HAZARDS_OFF_MOVEMENT_ON(0b0001)
        constant HAZARDS_ON_MOVEMENT_ON(0b0000)
    }

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
        beq     a1, a0, _mk_clone           // if current stage is SMBBF, then skip pirahna and platforms
        nop
        lli     a1, Stages.id.SMBO          // t0 = Stages.id.SMBO
        beq     a1, a0, _mk_clone           // if current stage is SMBO, then skip pirahna and platforms
        nop

        jal     0x801094A0                  // original line 1
        nop                                 // original line 2

        j       return
        nop

        _mk_clone:
        j       0x80109C2C
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
    // Extends AI stage ID check so cpus walk away from tornados on Hyrule Remix
    scope ai_extend_hyrule_tornado_check: {
        OS.patch_start(0xAF790, 0x80134D50)
        j       ai_extend_hyrule_tornado_check
        addiu   a0, sp, 0x0030              // og line 1
        OS.patch_end()

        lbu     t9, 0x0001(t8)              // t9 = current stage id (og line 2)
        beq     at, t9, _tornado_check      // branch if HYRULE
        addiu   at, r0, Stages.id.HCASTLE_DL// at = HCASTLE_DL
        beq     at, t9, _tornado_check
        addiu   at, r0, Stages.id.HCASTLE_O // at = HCASTLE_O
        beq     at, t9, _tornado_check
        addiu   at, r0, Stages.id.HCASTLE_REMIX // at = HCASTLE_REMIX
        beq     at, t9, _tornado_check
        nop

        //_normal:
        j       0x80134E88 + 0x4            // return to normal routine
        or      v0, r0, r0                  // return 0

        _tornado_check:
        j       0x80134D60 + 0x4
        sw      a3, 0x0058(sp)
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
        beq     t6, t7, standard_barrel_
        lli     t6, Stages.id.CONGOJ_DL     // t6 = Congo Jungle DL
        beq     t6, t7, standard_barrel_
        lli     t6, Stages.id.CONGOJ_O      // t6 = Congo Jungle O
        beq     t6, t7, standard_barrel_
        lli     t6, Stages.id.FALLS         // t6 = Stages.id.FALLS
        beq     t6, t7, standard_barrel_
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
    // Toggle for Saffron City Pokemon Rate (Inititialize)
    // @ Note
    // Door time is initalized at 0x8010B28C (open at start), but we don't need to modify it
    scope saffron_city_pokemon_rate_init: {
        OS.patch_start(0x000864F4, 0x8010ACF4)
        j       saffron_city_pokemon_rate_init
        sb      t8, 0x140C(at)              // original line 2
        nop
        _return:
        OS.patch_end()

        // a0 = range 0x03E8 (16 seconds)
        jal     Global.get_random_int_      // get random integer (original line 1)
        nop

        li      at, Global.current_screen   // at = pointer to current screen
        lbu     at, 0x0000(at)              // at = current screen_id
        lli     t9, 0x0016                  // t9 = vs screen_id
        beq     t9, at, _check_hazard       // if vs, check hazard mode
        lli     t9, 0x0036                  // t9 = training screen_id
        beq     t9, at, _check_hazard       // if training, check hazard mode
        nop
        b       _end                        // otherwise, don't check hazard mode

        _check_hazard:
        addiu   t9, v0, 0x03E8              // original line 3
        li      at, Toggles.entry_saffron_poke_rate
        lw      at, 0x0004(at)              // at = saffron_poke_rate (0 if DEFAULT, 1 if SUPER, 2 if HYPER, 3 if "QUICK ATTACK")

        beqz    at, _end                    // if DEFAULT, use default values (16-32 second range)
        nop

        slti    at, at, 0x0003              // at = 1 if SUPER or HYPER
        bnezl   at, _end                    // if SUPER or HYPER, divide Pokemon timer by 2 (8-16 second range)
        srl     t9, t9, 1                   // t9 = t9 / 2

        // if we're here, it is set to QUICK ATTACK
        b       _end
        addiu   t9, r0, 1                   // t9 = 1 delay

        _end:
        j       _return
        nop
    }

    // @ Description
    // Toggle for Saffron City Pokemon Rate
    // @ Note
    // Pokemon/door timers are halfwords stored at 0x8013140E
    scope saffron_city_pokemon_rate: {
        OS.patch_start(0x000868CC, 0x8010B0CC)
        j       saffron_city_pokemon_rate
        sb      t6, 0x001C(v0)                  // original line 2
        OS.patch_end()

        // Default          Door timer is 16 seconds, Pokemon timer is 16-32 seconds
        // Super            Pokemon double rate
        // Hyper            Pokemon double rate, door always open
        // Quick Attack     Non-stop Pokemon

        li      at, Global.current_screen       // at = pointer to current screen
        lbu     at, 0x0000(at)                  // at = current screen_id
        lli     t7, 0x0016                      // t7 = vs screen_id
        beq     t7, at, _check_hazard           // if vs, check hazard mode
        lli     t7, 0x0036                      // t7 = training screen_id
        beq     t7, at, _check_hazard           // if training, check hazard mode
        nop
        j       0x8010B0D4                      // otherwise, return to original routine
        addiu   t7, r0, 0x03E8                  // original line 1

        _check_hazard:
        li      at, Toggles.entry_saffron_poke_rate
        lw      at, 0x0004(at)                  // at = saffron_poke_rate (0 if DEFAULT, 1 if SUPER, 2 if HYPER, 3 if "QUICK ATTACK")

        beqz    at, _set_door_timer             // if DEFAULT, use default values (16 seconds)
        addiu   t7, r0, 0x03E8                  // original line 1

        slti    at, at, 0x0002                  // at = 0 if HYPER or "QUICK ATTACK", or 1 if "SUPER"
        beqzl   at, _set_door_timer             // branch accordingly
        addiu   t7, r0, 1                       // t7 = 1 (instant door)
        srl     t7, t7, 1                       // t7 = t7 / 2 (8 seconds)

        _set_door_timer:
        sh      t7, 0x0020(v0)                  // store door timer

        jal     Global.get_random_int_          // get random integer
        addiu   a0, r0, 0x03E8                  // a0 - range (0, N-1)

        li      at, Toggles.entry_saffron_poke_rate
        lw      at, 0x0004(at)                  // at = saffron_poke_rate (0 if DEFAULT, 1 if SUPER, 2 if HYPER, 3 if "QUICK ATTACK")

        addiu   t8, v0, 0x03E8                  // t8 = Pokemon timer (16-32 second range)
        beqz    at, _end                        // if DEFAULT, use default values
        nop

        slti    at, at, 0x0003                  // at = 1 if SUPER or HYPER
        bnezl   at, _end                        // if SUPER or HYPER, divide Pokemon timer by 2 (8-16 second range)
        srl     t8, t8, 1                       // t8 = t8 / 2

        // if we're here, it is set to QUICK ATTACK
        addiu   t8, r0, 15                      // t8 = 15 frame delay

        _end:
        j       0x8010B0E4                      // return to original function (store Pokemon timer)
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
        beq     v1, t0, _pc_clone           // if stage Peach's Castle Dreamland, load the bumper if hazards not off
        nop
        lli     t0, Stages.id.PCASTLE_O     // t0 = Stages.id.PCASTLE_O
        beq     v1, t0, _pc_clone           // if stage Peach's Castle Dreamland, load the bumper if hazards not off
        nop
        lli     t0, Stages.id.PCASTLE_BETA  // t0 = Stages.id.PCASTLE_O
        beq     v1, t0, _pc_clone           // if stage Peach's Castle Dreamland, load the bumper if hazards not off
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
    // Toggle for restoring Yoshi's Island cloud animations that are present but unused in vanilla
    scope yoshis_island_cloud_anims_: {
        OS.patch_start(0x842F4, 0x80108AF4)
        jal     yoshis_island_cloud_anims_
        addiu   a3, r0, 0x0012              // original line 1 - a3 = render routine index
        OS.patch_end()

        OS.read_word(Toggles.entry_yi_clouds + 0x4, a2) // a2 = 1 if on, 0 if off
        bnezl   a2, _end                    // if on, set a3 to 0x1C
        lli     a3, 0x001C                  // a3 = render routine index which applies scaling

        _end:
        jr      ra
        or      a2, r0, r0                  // original line 1
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
        lbu     t6, 0x0001(a0)              // a0 = stage_id
        addiu   a0, t6, -Stages.id.ONETT    // a0 = 0 if on Onett
        beqzl   a0, _check_mode             // if on Onett, treat as hazard toggle instead of movement toggle
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        addiu   a0, t6, -Stages.id.TALTAL   // a0 = 0 if on Tal Tal
        beqzl   a0, _check_mode             // if on Tal Tal, treat as hazard toggle instead of movement toggle
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        addiu   a0, t6, -Stages.id.TALTAL_REMIX    // a0 = 0 if on Tal Tal Remix
        beqzl   a0, _check_mode             // if on Tal Tal Remix, treat as hazard toggle instead of movement toggle
        andi    a1, a1, 0x0001              // a1 = 1 if hazard_mode is 1 or 3, 0 otherwise

        srl     a1, a1, 0x0001              // a1 = 1 if hazard_mode is 2 or 3, 0 otherwise

        li      a0, Stages.dont_freeze_stage// a0 = address of dont_freeze_stage
        lw      a0, 0x0000(a0)              // a0 = 0 if stage has movement, 1 otherwise
        bnez    a0, _original               // if the stage doesn't have movement, don't freeze the stage
        nop

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
        addiu   v1, r0, Stages.id.BTP_BANJO
        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // a1 = match info
        lbu     t7, 0x0001(t7)              // a1 = current stage ID
        beql    t7, v1, _banjo              // if current stage is Banjo's Board the Platforms, then load from new location
        lw      t7, 0x00E0(t6)              // load barrel pointer

        lw      t7, 0x0080(t6)              // load pointer for all other stages

        _banjo:
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

        addiu   a3, r0, Stages.id.BTP_BANJO
        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a1 = match info
        lbu     a0, 0x0001(a0)              // a1 = current stage ID
        beql    a0, a3, _banjo_2            // if current stage is Banjo's Board the Platforms, then load from new location
        lw      a1, 0x00E0(a1)              // load barrel pointer

        lw      a1, 0x0080(a1)

        _banjo_2:
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
    // Enables using a custom stage collision object array so we can have TOO MANY BARRELS!
    scope many_barrels_fix_: {
        // Loop over array
        OS.patch_start(0x5D71C, 0x800E1F1C)
        jal     many_barrels_fix_
        sll     t8, t6, 9                   // original line 2
        bltz    t8, 0x800E1FBC              // original line 3
        nop
        OS.patch_end()
        // Clear array
        OS.patch_start(0x5D500, 0x800E1D00)
        j       many_barrels_fix_._clear_array
        lli     v0, Stages.id.BTP_BANJO
        nop
        nop
        nop
        _clear_return:
        OS.patch_end()
        // Populate array
        OS.patch_start(0x5D554, 0x800E1D54)
        j       many_barrels_fix_._append_array
        addiu   v1, v1, 0x1180              // original line 1
        _append_return:
        bnez    t6, 0x800E1D84
        nop
        nop
        OS.patch_end()

        addiu   s1, s1, 0x1180              // original line 1 - address of stage collision object array
        addiu   s4, s4, 0x1198              // original line 4 - address of stage collision object count

        lli     t2, Stages.id.BTP_BANJO     // t2 = Stages.id.BTP_BANJO
        li      t9, Global.match_info
        lw      t9, 0x0000(t9)              // t9 = match info
        lbu     t9, 0x0001(t9)              // t9 = current stage ID
        bne     t9, t2, _end                // if current stage is not Banjo's Board the Platforms, then skip
        nop

        li      s1, barrel_array
        li      s4, barrel_array_size

        _end:
        jr      ra
        nop

        _clear_array:
        li      v1, Global.match_info
        lw      v1, 0x0000(v1)              // v1 = match info
        lbu     v1, 0x0001(v1)              // v1 = current stage ID
        bne     v1, v0, _end_clear_normal   // if current stage is not Banjo's Board the Platforms, then skip
        nop
        li      v1, barrel_array            // v1 = start of array
        li      v0, barrel_array_size       // v0 = end of array
        j       _clear_return
        sw      r0, 0x0000(v0)              // 0 out array size

        _end_clear_normal:
        li      v1, 0x80131180              // original line 1/5
        li      v0, 0x80131190              // original line 2/4
        j       _clear_return
        sw      r0, 0x1198(at)              // original line 3 - clear stage collision object count

        _append_array:
        lli     t6, Stages.id.BTP_BANJO     // t2 = Stages.id.BTP_BANJO
        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        bne     t7, t6, _end_append_normal  // if current stage is not Banjo's Board the Platforms, then skip
        nop

        li      v1, barrel_array            // v1 = start of array
        li      v0, barrel_array_size       // v0 = end of array
        or      a2, v0, r0                  // a2 = barrel array size
        j       _append_return
        lw      t6, 0x0000(v1)              // original line 1

        _end_append_normal:
        li      a2, 0x80131198              // original lines 4/5
        j       _append_return
        lw      t6, 0x0000(v1)              // original line 1
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
        // TODO: see if we can use our own file_address here and update any hardcodings
        li      a1, 0x801313F4              // a1 = file_address (array of file RAM addresses to use for later referencing)
        jal     Render.load_file_
        lli     a0, 0x127                   // a0 = file containing RTTF bomb info

        b       _begin                      // branch to begin
        nop

        _load_bowser_bomb_files:
        // TODO: see if we can use our own file_address here and update any hardcodings
        li      a1, 0x801313F4              // a1 = file_address (array of file RAM addresses to use for later referencing)
        jal     Render.load_file_
        // NOTE, the pointer at 0xA8 in this file needs to be updated if the bomb model file is updated
        lli     a0, File.BOWSER_BOMB_HEADER // a0 = modified RTTF header file, contains hitbox info (alternate 0x127)

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
        lli     t3, 0x0001                  // t3 = 1
        sw      t3, 0x0010(sp)              // 0x0010(sp) = 1
        mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0000(a3)              // set up float 1
        swc1    f4, 0x0004(a3)              // set up float 2
        jal     0x8016EA78                  // spawn stage item
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
        constant PK_FIRE_PILLAR(0x0014)
        constant BOMB(0x0015)
    }

    scope stage {
        constant POW_BLOCK(0x0016)
        constant BUMPER(0x0017)
        constant PIRANHA_PLANT(0x0018)
        constant TARGET(0x0019)
        constant RTTF_BOMB(0x001A)
        constant BOWSER_BOMB(0x011A)        // custom
        constant CHANSEY(0x001B)
        constant ELECTRODE(0x001C)
        constant CHARMANDER(0x001D)
        constant VENUSAUR(0x001E)
        constant PORYGON(0x001F)
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
        constant CLEFAIRY(0x002B)
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
        lli     t6, Stages.id.NORFAIR_REMIX // t6 = Stages.id.NORFAIR_REMIX
        beq     t6, t7, _norfair_remix      // if current stage is Norfair Remix, then use alt y positions
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

        _norfair_remix:
        li      t6, norfair_remix_lava_levels // t6 = norfair_remix_lava_levels
        b       _loop_setup
        nop

        _zebes_dl:
        li      t6, zebes_dl_lava_levels     // t6 = zebes_dl_lava_levels
        b       _loop_setup
        nop

        _zebes_o:
        li      t6, zebes_o_lava_levels     // t6 = zebes_o_lava_levels
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

    norfair_remix_lava_levels:
    dw 0xc2c80000       // slightly below main plat
    dw 0xC5160000       // very low
    dw 0x43480000       // first platform coverage
    dw 0xC5160000       // very low
    dw 0xC4160000       // below main plat
    dw 0x44960000       // second platform coverage
    dw 0xC5160000       // very low
    dw 0x43480000       // first platform coverage
    dw 0xC4160000       // below main plat
    dw 0xC5160000       // very low
    dw 0x44960000       // second platform coverage
    dw 0xc2c80000       // slightly below main plat
    dw 0xC5160000       // very low
    dw 0x43480000       // first platform coverage
    dw 0xC4160000       // below main plat
    dw 0xC5160000       // very low

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
        beq     t3, r0, _classic_bumper     // original line 1 modified
        addiu   t0, r0, Stages.id.PCASTLE_DL
        beq     t3, t0, _classic_bumper     // check for Peach's Castle DL
        addiu   t0, r0, Stages.id.PCASTLE_O
        beq     t3, t0, _classic_bumper     // check for Peach's Castle O
        addiu   t0, r0, Stages.id.PCASTLE_BETA
        beq     t3, t0, _classic_bumper     // check for Peach's Castle Beta
        addiu   t0, r0, Stages.id.CASINO
        beq     t3, t0, _casino     // check for Peach's Castle Beta
        nop


        _standard_bumper:
        lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       0x8017D724
        lw      ra, 0x001C(sp)              // original line 2

        _classic_bumper:
        lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop

        _casino:
        addiu   t4, r0, 0x03D5                  // bumper sound ID
        sh      t4, 0x0156(v0)                  // save to hitbox sound
        lui     t4, 0x437A                      // load 250 in fp
        sw      t4, 0x0138(v0)                  // save to hitbox size
        addiu   t4, r0, 0x0040                  // put hitbox fkb at 0x40
        j       _standard_bumper
        sb      t4, 0x0143(v0)                  // set hitbox fkb
    }

    constant BOWSER_BOMB_FLASH_TIME(120)        // frames until active

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
        lw      t0, 0x0074(a1)              // t0 = position struct = 0 if destroyed
        beqz    t0, _timer                  // if destroyed (likely Marina absorbed), then decrement timer
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
        b       _setup_bomb
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

        _setup_bomb:
        OS.read_word(0x801313F8, v0)        // created item with add_item
        beqz    v0,   _end                  // branch if no item was created
        nop
        lw      v1, 0x0084(v0)              // v1 = item struct
        sw      r0, 0x010C(v1)              // disable hitbox
        addiu   at, r0, BOWSER_BOMB_FLASH_TIME
        sw      at, 0x02C0(v1)              // set flash timer
        li      at, bowser_bomb_flash_main
        sw      at, 0x0378(v1)              // store new main routine
        addiu   at, r0, 0x011A              // at = bowser bomb item/hazard id
        sw      at, 0x000C(v1)              // overwrite RTTF bomb id with bowser bomb id
        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // main routine when the bowser bomb is initially spawned in
    scope bowser_bomb_flash_main: {
        OS.routine_begin(0x20)
        lw      v1, 0x0084(a0)              // v1 =

        lw      t0, 0x02C0(v1)              // t0 = duration
        addiu   t0, t0, -1                  // duration -=1
        andi    t6, t0, 0x0002
        srl     at, t6, 1
        sw      at, 0x007C(a0)              // save draw flag to make it flash
        bnez    t0, _end
        sw      t0, 0x02C0(v1)              // store updated duration

        // if here, duration is over and end flash
        sw      r0, 0x007C(a0)              // enable draw
        sw      r0, 0x0378(v1)              // overwrite routine
        addiu   at, r0, 3
        sw      at, 0x010C(v1)              // enable hitbox

        FGM.play(0xC2)

        _end:
        addiu   v0, r0, 0                   // return 0
        OS.routine_end(0x20)
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
        ori     at, r0, 0x001A              // at = RTTF Bomb ID
        lw      v0, 0x0084(t8)              // ~
        lw      v0, 0x000C(v0)              // v0 = current item ID
        beq     at, v0, _apply_hitstun      // apply hitstun if ID matches

        ori     at, r0, 0x011A              // at = Bowser Bomb ID
        bne     at, v0, _end                // if ID does not match, skip

        // at this point we can reasonably assume the player is being hit by a bowser bomb
        // the bowser bomb will apply an extra multiplier to hitstun, formula for the multiplier is 9 / (GRAVITY + 4)
        // f0 = stun frames
        _apply_hitstun:
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
    // this routine gets run by whenever a projectile crosses the blast zone.
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
        lli     t8, Stages.id.BTT_MARINA      // t0 = Stages.id.BTT_MARINA
        _return:
        OS.patch_end()

        li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID

        beql    t6, t8, _rolling_bombs      // if Marina's Break the Targets, branch
        lw      t6, 0x0000(t0)              // load item id

        lli     t8, Stages.id.BTP_MTWO      // t0 = Stages.id.BTP_MTWO
        bne     t6, t8, _klaptrap_check     // if current stage is not Mewtwo's Board the Platforms, then do klaptrap check
        lw      t6, 0x0000(t0)              // load item id

        _rolling_bombs:
        lli     t8, stage.RTTF_BOMB         // load RTTF Bomb ID
        bne     t6, t8, _klaptrap_check     // if not RTTF Bomb, branch to klaptrap check
        nop


        li      t6, 0x8013141C              // load location of RTTF Ram address when in Mewtwo BTP
        j       _return
        addiu   a2, r0, 0x000B              // original line 1

        _klaptrap_check:
        lli     t8, Item.Car.id
        beq     t6, t8, _end
        addiu   a2, r0, 0x0012
        lli     t8, Item.RobotBee.id
        beq     t6, t8, _bee
        lli     t8, Item.Cacodemon.id
        beq     t6, t8, _bee
        lli     t8, Item.KlapTrap.id
        bnel    t6, t8, _end
        addiu   a2, r0, 0x000B              // original line 1
        _bee:
        addiu   a2, r0, 0x0004              // proper room for klaptrap, Bee, and Car

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

        li      t1, Global.current_screen   // ~
        lbu     t1, 0x0000(t1)              // t0 = screen_id
        ori     a0, r0, 0x0036              // ~
        beq     a0, t1, _skip_check        // skip if screen_id = training mode
        nop

        li      t1, Global.match_info       // ~
        lw      t1, 0x0000(t1)              // t1 = match info struct
        lw      t1, 0x0018(t1)              // t1 = time elapsed
        beqz    t1, _intro_splash_prevent
        nop
        _skip_check:
        jal     0x800269C0                // play fgm
        addiu   a0, r0, 0x03D1            // fgm id = 0x3D1 (Splash)

        _intro_splash_prevent:
        lw      v1, 0x0010(sp)            // load from stack to v1
        lw      v0, 0x000C(sp)            // load from stack
        lw      t1, 0x0008(sp)            // load from stack to v1

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
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x0109          // fgm id = gameboy_startup_sound 57, 151

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


    // @ Description
    // Adds rolling bombs to mewtwos board the platforms
    scope mtwo_btp_setup: {
        OS.patch_start(0x11228C, 0x8018DB4C)
        jal     mtwo_btp_setup
        lli     v1, Stages.id.BTP_BANJO     // t0 = Stages.id.BTP_MTWO
        return:
        OS.patch_end()

        li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        beq     a1, v1, _banjo              // if current stage is Banjo's Board the Platforms, then do barrels
        nop
        lli     v1, Stages.id.BTP_MTWO      // t0 = Stages.id.BTP_MTWO
        bne     a1, v1, _normal             // if current stage is not Mewtwo's Board the Platforms, then do normal functions
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
        beq     r0, r0, _normal
        nop

        _banjo:
        addiu   sp, sp, -0x0030
        sw      ra, 0x0014(sp)
        sw      t6, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x001C(sp)
        sw      t5, 0x0020(sp)

        lui     t7, 0x8013
        lw      t7, 0x1300(t7)              // load hardcoded stage pointer
        lw      t7, 0x00E4(t7)              // load address of animation file from stage header

        addiu   t6, r0, TOTAL_BARRELS
        li      t5, _banjo_btp_barrel_structs

        _loop:
        sw      t6, 0x0024(sp)              // save count
        sw      t5, 0x0028(sp)              // save struct address
        sw      t7, 0x002C(sp)              // save current animation address
        lw      a0, 0x0000(t5)              // x position
        lw      a1, 0x0004(t5)              // y position
        lw      a2, 0x0008(t5)              // rotation

        jal     add_barrel_
        addiu   a3, t7, 0x0000              // animation address

        lw      t6, 0x0024(sp)              // load count
        lw      t5, 0x0028(sp)              // load struct address
        lw      t7, 0x002C(sp)              // load current animation address
        addiu   t7, t7, 0x0008              // move to next animation address
        addiu   t6, t6, -0x0001             // subtract from counter
        bnezl   t6, _loop
        addiu   t5, t5, 0x0010              // move to next struct

        lw      ra, 0x0014(sp)
        lw      t6, 0x0004(sp)
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x001C(sp)
        lw      t5, 0x0020(sp)
        addiu   sp, sp, 0x0030
        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14

        // targets seem to use, in 801313f0 space, 0x4, 0xC, and 0x70

        _normal:
        lw      a1, 0x0080(t6)              // original line 1
        jr      ra
        lui     v1, 0x800A                  // original line 2
    }

    constant TOTAL_BARRELS(12)
    _banjo_btp_barrel_structs:
    // 0x0
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x1
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x2
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x3
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x5
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x6
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x7
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x8
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0x9
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0xA
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0xB
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    // 0xC
    dw  0x00000000                          // x position
    dw  0x00000000                          // y position
    dw  0x00000000                          // rotation
    dw  0x00000000                          // animation address

    barrel_array:
    fill TOTAL_BARRELS * 0x8

    barrel_array_size:
    dw TOTAL_BARRELS

    // @ Description
    // Fixes header issue related to barrels firing
    scope banjo_btp_barrel_firing_fix: {
        OS.patch_start(0xBEAAC, 0x8014406C)
        jal     banjo_btp_barrel_firing_fix
        lli     t4, Stages.id.BTP_BANJO    // t4 = Stages.id.BTP_BANJO
        return:
        OS.patch_end()

        li      t5, Global.match_info
        lw      t5, 0x0000(t5)              // t5 = match info
        lbu     t5, 0x0001(t5)              // t5 = current stage ID
        bnel    t5, t4, _normal             // if current stage is not BANJO_BTP, then do normal functions
        subu    t9, t7, t8                  // original line 1, subtract 0x14 from header pointer, which is necessary for normal stages, but not for bonus stages

        addu    t9, t7, r0                  // place the correct pointer for BTP stages
        _normal:
        j   return
        swc1    f4, 0x0024(t3)              // original line 2
    }

    // @ Description
    // Adds rolling bombs to marina's break the targets
    scope marina_btt_setup: {
        OS.patch_start(0x111AE0, 0x8018D3A0)
        jal     marina_btt_setup
        lli     t7, Stages.id.BTT_MARINA    // t0 = Stages.id.BTT_MARINA
        return:
        OS.patch_end()

        li      t1, Global.match_info
        lw      t1, 0x0000(t1)              // a1 = match info
        lbu     t1, 0x0001(t1)              // a1 = current stage ID
        bne     t1, t7, _normal             // if current stage is not Marina's Break the Targets, then do normal functions
        nop

        _bombs:
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        sw      t6, 0x0004(sp)
        // the code below is to replace a jal to   0x8010B4D0
        // it establishes stage free space to work with bombs
        // needed to be moved to accomodate targets
        lui     t8, 0x8013
        lw      t8, 0x1300(t8)             // load hardcoded stage pointer
        lui     t7, 0x0000
        lui     t9, 0x0000
        lw      t6, 0x0080(t8)
        lui     t1, 0x8013
        addiu   t7, t7, 0x0000
        addiu   t9, t9, 0x0000
        addiu   t1, t1, 0x13F0              // load to stage free space
        subu    t0, t8, t9
        subu    t8, t6, t7
        sw      t8, 0x0028(t1)              // save RTF bomb relevant pointer
        sw      t0, 0x002C(t1)              // save RTF bomb relevant pointer
        li      t0, 0x457d2000              // floating point for bomb spawn point X (4050)
        sw      t0, 0x0030(t1)              // save X address
        li      t0, 0x45bb8000              // floating point for bomb spawn point Y (6000)
        sw      t0, 0x0034(t1)              // save Y address

        jal     0x8010B660                  // setups up bomb spawning object
        sw      r0, 0x0038(t1)              // save Z address in the interest of caution

        lui     t6, 0x8013                  // overwriting the time until first bomb spawned
        lli     at, 0x0001                  // at = 1 frame
        sw      at, 0x01404(t6)             // overwrite timer (default is 0xB4)

        lw      t6, 0x0004(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020

        // to add more of these to future stages, you'll need to copy and paste the additional portion of the header

        _normal:
        lbu     t7, 0x0001(t6)              // original line 1
        jr      ra
        mtc1    r0, f20                     // original line 2
    }

    // @ Description
    // Changes how bombs position are set
    scope rolling_bomb_position: {
        OS.patch_start(0x86E1C, 0x8010B61C)
        j       rolling_bomb_position
        lli     a0, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
        return:
        OS.patch_end()

        li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID

        beq     a0, a1, _special            // if current stage is Mewtwo's Board the Platforms, then do special functions
        lli     a0, Stages.id.BTT_MARINA    // t0 = Stages.id.BTT_MARINA

        bnel    a1, a0, _normal             // if current stage is not Marina's Break the Targets, then do not do special functions
        addiu   a2, a2, 0x13F8              // original line 1

        _special:
        addiu   a2, a2, 0x1420              // x and y as done in bonuses

        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14

        _normal:
        j       return
        or      a0, r0, r0                  // original line 2
    }

    // @ Description
    // Changes how bombs explosions are loaded
    scope rolling_bomb_explosion_1: {
        OS.patch_start(0xFF614, 0x80184BD4)
        j       rolling_bomb_explosion_1
        lli     at, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
        return:
        OS.patch_end()

        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID

        beql    t7, at, _special            // if current stage is Mewtwo's Board the Platforms, then do special functions
        lui     at, 0xC1C0                  // original line 1

        lli     at, Stages.id.BTT_MARINA    // t0 = Stages.id.BTT_MARINA

        bne     t7, at, _normal             // if current stage is not Marina's Break the Targets, then do normal functions
        lui     at, 0xC1C0                  // original line 1

        _special:
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
    scope rolling_bomb_explosion_2: {
        OS.patch_start(0xFFC98, 0x80185258)
        j       rolling_bomb_explosion_2
        lli     t8, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
        return:
        OS.patch_end()

        li      t9, Global.match_info
        lw      t9, 0x0000(t9)              // t7 = match info
        lbu     t9, 0x0001(t9)              // t7 = current stage ID

        beql    t9, t8, _normal             // if current stage is Mewtwo's Board the Platforms, then do special functions
        lui     t9, 0x0000                  // original line 2

        lli     t8, Stages.id.BTT_MARINA    // t0 = Stages.id.BTT_MARINA
        bne     t9, t8, _normal             // if current stage is not Marina's Break the Targets, then do normal functions
        lui     t9, 0x0000                  // original line 2

        _special:
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
    scope rolling_bomb_explosion_3: {
        OS.patch_start(0xFFA44, 0x80185004)
        j       rolling_bomb_explosion_3
        lli     a1, Stages.id.BTP_MTWO         // t0 = Stages.id.BTP_MTWO
        return:
        OS.patch_end()

        li      t1, Global.match_info
        lw      t1, 0x0000(t1)              // t7 = match info
        lbu     t1, 0x0001(t1)              // t7 = current stage ID

        beql    t1, a1, _special            // if current stage is Mewtwo's Board the Platforms, then do special functions
        lui     t1, 0x0000                  // original line 2


        lli     a1, Stages.id.BTT_MARINA    // t0 = Stages.id.BTT_MARINA

        bne     t1, a1, _normal             // if current stage is not Marina's Break the Targets, then do normal functions
        lui     t1, 0x0000                  // original line 2

        _special:
        li      t9, 0x8013141C              // load in new address for pointer
        j       return
        nop

        // targets use same spots as bombs for ram address, maybe modify code to use other address, it needs 0x0, 0x4, and 0x14

        _normal:
        j       return
        lw      t9, 0xB5A4(t9)              // original line 1
    }

    // @ Description
    // This establishes Remix RTTF hazard objects
    scope remix_rttf_setup_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)

        jal     0x8010B4D0      // unknown RTTF routine
        nop

        jal     0x8010B508      // Bumpers routine
        nop

        jal     0x8010B660
        //jal     remix_rttf_bombs_
        nop

        jal     0x8010B784      // 0xE clipping flag end stage setup
        nop

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        or      v0, r0, r0      // unknown, done in RTTF
        jr      ra
        nop
    }

    // @ Description
    // This establishes Remix RTTF bombs
    // bomb spawning based on 0x8010B660
   //scope remix_rttf_bombs_: {
   //    addiu   sp, sp, -0x0030
   //    sw      ra, 0x001C(sp)
   //    sw      s0, 0x0018 (sp)
   //
   //    // rolling bomb 1
   //    addiu   a0, r0, 0x03f2
   //    or      a1, r0, r0
   //    addiu   a2, r0, 0x0001
   //
   //    jal     0x80009968          // object creation
   //    lui     a3, 0x8000
   //
   //    lui     a1, 0x8011
   //    addiu   a1, a1, 0xb5f0
   //    or      a0, v0, r0
   //    addiu   a2, r0, 0x0001
   //
   //    jal     0x80008188          // Associate the routine in a1 to object
   //    addiu   a3, r0, 0x0004
   //
   //    // rolling bomb 2
   //    // addiu   a0, r0, 0x03f2
   //    // or      a1, r0, r0
   //    // addiu   a2, r0, 0x0001
   //    //
   //    // jal     0x80009968          // object creation
   //    // lui     a3, 0x8000
   //    //
   //    // li      a1, rttf_bomb_2_
   //    // or      a0, v0, r0
   //    // addiu   a2, r0, 0x0001
   //    //
   //    // jal     0x80008188          // Associate the routine in a1 to object
   //    // addiu   a3, r0, 0x0004
   //
   //    addiu   a0, r0, 0x0029      // rolling bomb spawn id
   //    addiu   at, r0, 0x0001
   //
   //    // part below finds the two spawns
   //    addiu   a1, sp, 0x0024
   //    lui     t6, 0x8013
   //    lw      t6, 0x1368 (t6)
   //    or      a2, a0, r0
   //    or      a3, a1, r0
   //    lhu     v0, 0x0014 (t6)
   //    or      a0, r0, r0
   //    or      v1, r0, r0
   //
   //    beqz    v0, _spawn
   //    nop
   //
   //    blez    v0, _spawn
   //    or      a1, v0, r0
   //
   //    lui     t0, 0x8013
   //    addiu   t0, t0, 0x1380
   //    or      v0, r0, r0
   //    addiu   t4, r0, r0
   //    sll     t1, v1, 2
   //    addu    t2, a3, t1
   //
   //    _loop:
   //    lw      t7, 0x0000 (t0)
   //    addu    t8, t7, v0
   //    lhu     t9, 0x0000 (t8)
   //    lui     t3, 0x8013
   //
   //    bnel    a2, t9, _check_objects
   //    addiu   a0, a0, 0x0001
   //
   //    sb      a0, 0x0000 (t2)
   //    //addiu   t2, t2, 0x0001      // advance to next bomb space
   //    //addiu   t4, t4, 0x0001      // advance bomb count
   //
   //
   //    lw      t3, 0x1368 (t3)
   //    addiu   v1, v1, 0x0001
   //    lhu     a1, 0x0014 (t3)
   //    addiu   a0, a0, 0x0001
   //
   //    _check_objects:
   //    slt     at, a0, a1
   //    bnez    at, _loop
   //    addiu   v0, v0, 0x0006
   //
   //    // sets to the spawn location
   //    _spawn:
   //    addu    t2, r0, sp
   //    lbu     a0, 0x0024(t2)
   //
   //    _loop_2:
   //    lui     a1, 0x8013
   //    addiu   a1, a1, 0x13f8      // bomb 1 pointer space
   //
   //    jal     0x800fc894
   //    nop
   //
   //    //lbu     a0, 0x0025(t2)      // second bomb id
   //    //lui     a1, 0x8013
   //    //addiu   a1, a1, 0x1420      // bomb 2 pointer space
   //
   //    //jal     0x800fc894
   //    //nop
   //
   //    addiu   t6, r0, 0x00b4
   //    lui     at, 0x8013
   //    lw      s0, 0x0018 (sp)
   //    sw      t6, 0x1404 (at)
   //    sw      t6, 0x142C (at)
   //
   //
   //    lw      ra, 0x001C(sp)
   //    addiu   sp, sp, 0x0030
   //    jr      ra
   //    nop
   //}

    // @ Description
    // Hardcoding for bumpers on Race to the Finish Stages
    scope rttf_bomb_2_: {
        lui            v1, 0x8013
        addiu          v1, v1, 0x13f0
        lw             v0, 0x003C (v1)
        addiu          sp, sp, -0x30
        sw             ra, 0x001c (sp)

        bnez           v0, _end
        sw             a0, 0x0030 (sp)

        mtc1           r0, f0
        lui            a2, 0x8013
        addiu          t6, r0, 0x0001
        sw             t6, 0x0010 (sp)
        addiu          a2, a2, 0x1420
        or             a0, r0, r0
        addiu          a1, r0, 0x001a
        addiu          a3, sp, 0x0024
        swc1           f0, 0x002c (sp)
        swc1           f0, 0x0028 (sp)

        jal            0x8016ea78
        swc1           f0, 0x0024 (sp)

        lui            v1, 0x8013
        addiu          v1, v1, 0x13f0
        addiu          v0, r0, 0x00b4
        sw             v0, 0x003C (v1)

        _end:
        lw             ra, 0x001c (sp)
        addiu          t8, v0, 0xffff
        sw             t8, 0x003C (v1)

        jr             ra
        addiu          sp, sp, 0x30
    }

    // @ Description
    // Hardcoding for bumpers on Race to the Finish Stages
    scope rttf_bumpers_: {
        OS.patch_start(0x86D50, 0x8010B550)
        jal     rttf_bumpers_
        lui     t7, 0x0000                  // original line 1
        return_:
        OS.patch_end()

        addiu   s3, r0, Stages.id.REMIX_RTTF   // ~
        li      s2, Global.match_info       // load match info pointer
        lw      s2, 0x0000(s2)              // load match info
        lbu     s2, 0x0001(s2)              // load stage id
        bnel    s2, s3, _end                // if stage_id is not remix_rttf, do as normal
        addiu   t7, t7, 0x0110              // original line 2

        addiu   t7, t7, 0x01E8              // Remix RTTF hardcoding, replacing original line 2

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Toggle for Whispy Downtime Counter initially
    scope dreamland_downtime_initially_: {
        OS.patch_start(0x81E6C, 0x8010666C)
        jal     dreamland_downtime_initially_
        nop
        return_:
        OS.patch_end()

        li      t4, Global.current_screen   // ~
        lbu     t4, 0x0000(t4)              // t4 = screen_id
        ori     a0, r0, 0x0001              // ~
        beql    a0, t4, _end                // if screen_id = 1P, do as normal
        addiu   t4, v0, 0x03C0              // original line 1, adds set amount to variable downtime period

        li      t4, Toggles.entry_whispy_mode
        lw      t4, 0x0004(t4)              // t7 = 3 if Hyper Mode
        addiu   a0, r0, 0x0003              // Hyper mode id
        bnel    a0, t4, _end                // if toggle not turned on to Hyper mode, do as normal
        addiu   t4, v0, 0x03C0              // original line 1, adds set amount to variable downtime period

        // hyper mode
        addiu   t4, r0, 0x0100              // set 100 frames before first blow

        _end:
        jr      ra
        sh      t4, 0x0020(s0)              // original line 2, save to hardcoded timer location
    }

    // @ Description
    // Toggle for Whispy Downtime Counter
    scope dreamland_downtime_: {
        OS.patch_start(0x81610, 0x80105E10)
        jal     dreamland_downtime_
        addiu   v1, v1, 0x13F0              // original line 1
        return_:
        OS.patch_end()

        li      t7, Global.current_screen   // ~
        lbu     t7, 0x0000(t7)              // t7 = screen_id
        ori     t8, r0, 0x0001              // ~
        beql    t8, t7, _end                // if screen_id = 1P, do as normal
        addiu   t7, v0, 0x03C0              // original line 2, adds set amount to variable downtime period

        li      t7, Toggles.entry_whispy_mode
        lw      t7, 0x0004(t7)              // t7 = 3 if Hyper Mode
        addiu   t8, r0, 0x0003              // Hyper mode id
        bnel    t7, t8, _end                // if toggle not turned on to Hyper mode, do as normal
        addiu   t7, v0, 0x03C0              // original line 2, adds set amount to variable downtime period

        // hyper mode
        addiu   t7, r0, 0x0025              // set 25 frames between blows

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Toggle for the Dreamland wind speed multiplier to use the value in different modes.
    scope dreamland_wind_speed_multiplier_: {
        OS.patch_start(0x81274, 0x80105A74)
        jal     dreamland_wind_speed_multiplier_
        lwc1    f6, 0x0AA0(at)              // original line 1 (f6 = U wind speed multiplier)
        return_:
        OS.patch_end()

        addiu   sp, sp, -0x10
        sw      t1, 0x0004(sp)

        li      at, Toggles.entry_whispy_mode
        lw      at, 0x0004(at)              // at = whispy_mode

        beqz    at, _end                    // at = 0 if we should use U wind
        addiu   t1, r0, Toggles.whispy_mode.JAPANESE

        beq     at, t1, _japanese           // at = 1 if we should use J wind
        nop

        li      t1, Global.current_screen   // ~
        lbu     t1, 0x0000(t1)              // t1 = screen_id
        ori     at, r0, 0x0001              // ~
        beq     at, t1, _end                // if screen_id = 1P, then use U value
        addiu   t1, r0, Toggles.whispy_mode.SUPER

        beq     at, t1, _super              // if at = 3 go to super, or if not, with no remaining options, hyper mode
        nop

        // hyper mode
        li      at, 0x3A1D4952              // hyper mode floating point multiplier
        beq     r0, r0, _end_alt
        nop

        _japanese:
        li      at, 0x399D4952              // japanese whispy floating point multiplier
        beq     r0, r0, _end_alt
        nop

        _super:
        li      at, 0x3A1D4952              // super mode floating point multiplier


        _end_alt:
        mtc1    at, f6                      // f6 = J wind speed multiplier

        _end:
        lw      t1, 0x0004(sp)
        addiu   sp, sp, 0x10
        jr      ra
        mul.s   f8, f2, f6                  // original line 2
    }

    // @ Description
    // Toggle for the Dreamland wind speed max to determine maximum speeed
    scope dreamland_wind_speed_max_: {
        OS.patch_start(0x81250, 0x80105A50)
        jal     dreamland_wind_speed_max_
        lui     at, 0x40C0                  // original line 1, max speed=6
        return_:
        OS.patch_end()

        addiu   sp, sp, -0x10
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)

        li      t1, Toggles.entry_whispy_mode
        lw      t1, 0x0004(t1)              // t1 = 0 or 1 use standard max

        beqz    t1, _end                    // if toggle not turned on, then use U value
        addiu   t2, r0, Toggles.whispy_mode.JAPANESE

        // japanese mode
        beq     t2, t1, _end
        addiu   t1, r0, Toggles.whispy_mode.SUPER

        // super mode
        beq     t2, t1, _end                // go to super, or if not, with no remaining options, hyper mode
        lui     at, 0x41a0                  // super mode = 20

        // hyper mode
        lui     at, 0x41f0                  // hyper mode max = 30

        _end:
        lw      t2, 0x0008(sp)
        lw      t1, 0x0004(sp)
        addiu   sp, sp, 0x10
        jr      ra
        mtc1    at, f4                      // original line 2, move speed to floating point register
    }

     // @ Description
     // Changes wind parameters for Dream Greens and super/hyper modes
     scope dream_land_wind_parameters: {
        OS.patch_start(0x811A0, 0x801059A0)
        j       dream_land_wind_parameters
        lwc1    f30, 0x0A94(at)             // original line 1
        nop
        return:
        OS.patch_end()

        lwc1    f28, 0x0A98(at)             // original line 3, loads max left
        addiu   v1, r0, Stages.id.DREAM_LAND_SR         // v1 = Dream Greens
        li      at, Global.match_info
        lw      at, 0x0000(at)              // at = match info
        lbu     at, 0x0001(at)              // at = current stage ID
        bne     v1, at, _toggle_check       // if current stage is not Dream Greens, then do normal settings
        lui     at, 0x8013                  // original line 2

        // parameters for dream greens
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

        _toggle_check:
        addiu   sp, sp, -0x10
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f2, 0x000C(sp)

        li      t1, Global.current_screen   // ~
        lbu     t1, 0x0000(t1)              // t1 = screen_id
        ori     t2, r0, 0x0001              // ~
        beq     t2, t1, _end                // if screen_id = 1P, use standard max
        nop
        li      t1, Toggles.entry_whispy_mode
        lw      t1, 0x0004(t1)              // t1 = 0 or 1 use standard max
        addiu   t2, r0, Toggles.whispy_mode.SUPER
        beql    t1, t2, _multiply                // if super modify parameters
        lui     t1, 0x3F8C
        addiu   t2, r0, Toggles.whispy_mode.HYPER
        bne     t1, t2, _end                // if not hyper, do normal parameters
        nop

        // hyper mode
        lui     t1, 0x3f99

        _multiply:
        mtc1    t1, f2
        mul.s   f30, f2, f30
        mul.s   f28, f2, f28
        mul.s   f24, f2, f24

        _end:
        lwc1    f2, 0x000C(sp)
        lw      t2, 0x0008(sp)
        lw      t1, 0x0004(sp)
        addiu   sp, sp, 0x10

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
         bnel    a1, a3, _normal             // if current stage is not Dream Greens, then do normal settings
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
        lui     a2, 0x8010                    // original line 2
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
         bnel    a2, a3, _normal             // if current stage is not Dream Greens, then do normal settings
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
         bnel    a2, a3, _normal            // if current stage is not Dream Greens, then do normal settings
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
         bnel    a1, a3, _normal            // if current stage is not Dream Greens, then do normal settings
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
        bnel    t0, v1, _normal             // if current stage is not Dream Greens, then do normal settings
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
        bnel    t5, t7, _normal             // if current stage is not Dream Greens, then do normal settings
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
        bnel    a2, a1, _normal             // if current stage is not Dream Greens, then do normal settings
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
        bnel    a2, a1, _normal             // if current stage is not Dream Greens, then do normal settings
        lw      t2, 0xE8E8(t2)              // original line 1

        li      t2, DREAM_GREENS_OFFSETS    // hardcoding 1
        addu    t2, t2, t1                  // additional offset
        lw      t2, 0x0078(t2)              // load offset

        _normal:
        j       return
        addiu   a2, r0,0x0000               // original line 2
    }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_1: {
        OS.patch_start(0x84D14, 0x80109514)
        j       mk_remix_hardcoding_1
        addiu   a3, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a1, Global.match_info
        lw      a1, 0x0000(a1)              // a1 = match info
        lbu     a1, 0x0001(a1)              // a1 = current stage ID
        bnel    a3, a1, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t7, t7, 0x0380              // original line 1

        addiu   t7, t7, 0x0628              // original line 1 replacement

        _normal:
        j       return
        lui     a3, 0x8013                  // original line 2
        }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_2: {
        OS.patch_start(0x84D74, 0x80109574)
        j       mk_remix_hardcoding_2
        addiu   t4, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0001(t7)              // t7 = current stage ID
        bnel    t7, t4, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t5, t5, 0x05F0              // original line 1

        addiu   t5, t5, 0x0830              // original line 1 replacement

        _normal:
        j       return
        lui     t4, 0x8001                  // original line 2
        }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_3: {
        OS.patch_start(0x84A50, 0x80109250)
        j       mk_remix_hardcoding_3
        addiu   a2, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a0 = match info
        lbu     a0, 0x0001(a0)              // a0 = current stage ID
        bnel    a0, a2, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   v1, v1, 0x0734              // original line 1

        addiu   v1, v1, 0x0968              // original line 1 replacement

        _normal:
        j       return
        sb      t9, 0x0032(v0)               // original line 2
        }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_4: {
        OS.patch_start(0x853EC, 0x80109BEC)
        j       mk_remix_hardcoding_4
        addiu   t0, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      t8, Global.match_info
        lw      t8, 0x0000(t8)              // t8 = match info
        lbu     t8, 0x0001(t8)              // t8 = current stage ID
        bnel    t8, t0, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t7, t7, 0x05F0              // original line 1

        addiu   t7, t7, 0x0830              // original line 1 replacement

        _normal:
        j       return
        addiu   t9, t9, 0x0014              // original line 2
        }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_5: {
        OS.patch_start(0xF7B4C, 0x8017D10C)
        j       mk_remix_hardcoding_5
        addiu   a2, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a0 = match info
        lbu     a0, 0x0001(a0)              // a0 = current stage ID
        bnel    a0, a2, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t2, t2, 0x0CC8              // original line 1

        addiu   t2, t2, 0x0BC8              // original line 1 replacement

        _normal:
        j       return
        sw      v1, 0x0024(sp)               // original line 2
        }

    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_6: {
        OS.patch_start(0xF7B70, 0x8017D130)
        j       mk_remix_hardcoding_6
        addiu   a2, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a0 = match info
        lbu     a0, 0x0001(a0)              // a0 = current stage ID
        bnel    a0, a2, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t4, t4, 0x0CF8              // original line 1

        addiu   t4, t4, 0x0BEC              // original line 1 replacement

        _normal:
        j       return
        lw      a0, 0x0080(s0)               // original line 2
        }



    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
     scope mk_remix_hardcoding_7: {
        OS.patch_start(0xF7E40, 0x8017D400)
        j       mk_remix_hardcoding_7
        addiu   a2, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a0 = match info
        lbu     a0, 0x0001(a0)              // a0 = current stage ID
        bnel    a0, a2, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        addiu   t1, t1, 0x0E04              // original line 1

        addiu   t1, t1, 0x0CE4              // original line 1 replacement

        _normal:
        j       return
        lw      a0, 0x0080(s1)               // original line 2
        }



    // @ Description
    // Changes hardcoding for Mushroom Kingdom Remix
    scope mk_remix_hardcoding_8: {
        OS.patch_start(0xF6BC0, 0x8017C180)
        j       mk_remix_hardcoding_8
        addiu   t9, r0, Stages.id.MK_REMIX         // v1 = Mushroom Kingdom Remix
        return:
        OS.patch_end()

        li      a3, Global.match_info
        lw      a3, 0x0000(a3)              // a0 = match info
        lbu     a3, 0x0001(a3)              // a0 = current stage ID
        bne     t9, a3, _normal              // if current stage is not Mushroom Kingdom Remix, then do normal settings
        lui     t9, 0x0000                  // original line 1

        or      a3, a0, r0                  // original line 2
        addiu   t9, t9, 0x0F80              // hardcoding fix 1
        lui     t1, 0x0000
        j       0x8017C194                  // skip original hardcodings
        addiu   t1, t1, 0x1060              // hardcidubg fix 2

        _normal:
        j       return
        or      a3, a0, r0                   // original line 2
    }

    scope mk_remix_hardcoding_9: {
        // Enable CPU AI to avoid falling to blastzone on dropping plats
        OS.patch_start(0x000B1EA4, 0x80137464)
        jal     mk_remix_hardcoding_9
        lbu     t6, 0x0001(t5)              // original line 2 - t6 = current stage ID
        OS.patch_end()

        lli     at, Stages.id.MK_REMIX
        beq     t6, at, _do_check           // if MK Remix, do check for AI on dropping plat
        lli     at, Stages.id.BIG_BOOS_HAUNT
        beq     t6, at, _do_check           // if Big Boo's Haunt, do check for AI on dropping plat
        lli     at, Stages.id.YOSHIS_ISLAND_II
        beq     t6, at, _do_check           // if Yoshi's Island II, do check for AI on dropping plat
        lli     at, Stages.id.GREAT_BAY
        beq     t6, at, _great_bay         // if GREAT_BAY, do check for AI on dropping turtle plat
        // lli     at, Stages.id.DATA
        // beq     t6, at, _taxi_check         // if Datadyne, do check for AI on moving taxi
        lli     at, Stages.id.MUSHROOM_KINGDOM // original line 1 - at = MK stage ID

        jr      ra
        nop

        _great_bay:
        lw      a0, 0x00EC(a2)              // a0 = current clipping id
        bltz    a0, _normal
        nop
        sw      v1, 0x0024(sp)              // save v1 to sp
        jal     0x800FCA18                  // ??
        sw      a2, 0x004C(sp)              // save a2 to sp
        lw      v1, 0x0024(sp)              // restore v1

        beqz    v0, _normal                 // branch if unknown routine returned zero
        lw      a2, 0x004C(sp)              // restore a2

        lw      t7, 0x08E8(a2)              // get top joint
        lui     at, 0xc47a                  // max coordinate -500 (MK = 0xC2C8, -100.0)
        mtc1    at, f10                     // f10 = max coordinate
        lwc1    f8, 0x0020(t7)              // f8 = cpu y coordinate
        c.lt.s  f8, f10                     // compare floats
        nop
        bc1f    _normal                     // branch to normal routine if not below certain Y
        nop

        // v1 = fighter AI struct
        lbu     t8, 0x0000(v1)              // t8 = current CPU state
        addiu   at, r0, 0x4                 // at = STATE_ID.RECOVER
        addiu   t1, r0, 0x4                 // t1 = STATE_ID.RECOVER
        beq     t8, at, _skip               // branch if not already recovering
        addiu   v0, r0, 0x0001              // return 1
        lbu     t0, 0x0049(v1)              // load input byte?
        andi    t9, t0, 0xFFFE              // add to input byte
        sb      t9, 0x0049(v1)              // save input byte
        j       0x80137768
        sb      t1, 0x0000(v1)              // set cpu STATE to RECOVER

        _skip:
        j       0x80137768                  // ~
        addiu   v0, r0, 0x0001              // return 1

        // could not prevent datadyne issue with this code
        // _taxi_check:
        // lw      a0, 0x00EC(a2)              // get current clipping id
        // bltz    a0, _normal
        // nop
        // sw      v1, 0x0024(sp)              // save v1 to sp
        // jal     0x800FCA18                  // ??
        // sw      a2, 0x004C(sp)              // save a2 to sp
        // lw      v1, 0x0024(sp)              // restore v1

        // beqz    v0, _normal                 // branch if unknown routine returned zero
        // lw      a2, 0x004C(sp)              // restore a2

        // lw      t7, 0x08E8(a2)              // get top joint
        // lui     at, 0x451C                  // max coordinate
        // mtc1    at, f10                     // f10 = max coordinate
        // lwc1    f8, 0x001C(t7)              // f8 = cpu x coordinate
        // c.lt.s  f10, f8                     // compare floats
        // nop

        // j       0x801374B0
        // nop


        _normal:
        j       0x801374E0 + 0x4
        lui     t3, 0x800A

        _do_check:
        j       0x80137474                  // jump to AI platform and height check code
        nop
    }

    // @ Description
    // Cannon related constants
    scope Cannon {
        // note: BARREL_X_LEFT and BARREL_X_RIGHT are assumed to be multiples of TURN_SPEED and FRENZY_TURN_SPEED. BARREL_X_MIDDLE is assumed to be 0.
        constant BARREL_Y(0x4270)           // current setting - float: 60
        constant BARREL_X_LEFT(0xC300)      // current setting - float: -128
        constant BARREL_X_RIGHT(0x4300)     // current setting - float: 128
        constant TURN_SPEED(0x4080)         // current setting - float: 4
        constant SHOT_SCALING(0x3F90)       // current setting - float: 1.125
        constant FRENZY_TURN_SPEED(0x4100)  // current setting - float: 8
        constant id.WAITING(0x0)
        constant id.TURNING(0x1)
        constant id.FIRING(0x2)
        constant pos.LEFT(0x0)
        constant pos.MIDDLE(0x1)
        constant pos.RIGHT(0x2)
        // note: The following 3 offsets are hard coded
        constant offset.LEFT(0x0000)
        constant offset.MIDDLE(0x0610)
        constant offset.RIGHT(0x0C50)
        constant WAIT_BASE_TIME(90)
        constant WAIT_TIME_RANGE(60)
        constant CHANCE_FRENZY(5)
        constant FRENZY_WAIT_TIME(30)
        constant FRENZY_BASE_MOVES(10)
        constant FRENZY_MOVES_RANGE(10)
    }

    // @ Description
    // This establishes Pirate Land hazard object in which cannon is tied to
    scope pirate_land_setup: {
        addiu   sp, sp,-0x0060              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // store ra, s0

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        li      t0, 0x80131300              // load hardcoded place for stage header + 14
        lw      t0, 0x0000(t0)              // load stage header + 14
        lw      t1, 0x00AC(t0)              // load pointer to cannon hitbox file
        lw      t0, 0x0080(t0)              // load pointer to cannon file

        li      s0, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      t0, 0x0000(s0)              // save pointer to cannon file
        sw      t1, 0x0004(s0)              // save pointer to cannonball hitbox file
        lli     at, Cannon.id.WAITING       // ~
        sh      at, 0x0050(s0)              // set initial state to WAITING
        lli     at, Cannon.id.FIRING        // ~
        sh      at, 0x0052(s0)              // set previous state to FIRING
        lli     at, Cannon.pos.MIDDLE       // ~
        sh      at, 0x0054(s0)              // set intiial position to MIDDLE
        sh      at, 0x0056(s0)              // set previous position to MIDDLE
        lli     at, 000360                  // ~
        sw      at, 0x0058(s0)              // set initial state timer to 360 frames
        sw      r0, 0x005C(s0)              // ~
        sw      r0, 0x0060(s0)              // clear under_water flags and frenzy turns

        li      t3, cannonball_hitbox_pointer
        sw      t1, 0x0000(t3)              // save pointer to pointer spot
        li      t2, cannonball_projectile_struct
        sw      t3, 0x0008(t2)              // save pointer to cannonball hitbox file
        li      t2, cannonball_properties_struct
        sw      t3, 0x0024(t2)              // save pointer to cannonball hitbox file
        lui     a0, 0x0000
        lui     a1, 0x0000
        addiu   a1, a1, 0x0970              // 0x801065E4, offset for whispy mouth, UPDATE ON REIMPORT
        addiu   a0, a0, 0x07A8              // 0x801065E8, offset for whispy mouth, UPDATE ON REIMPORT
        li      a2, 0x80104D90              // assembly routine for creating display list
        addiu   a3, r0, 0x0004

        sw      a0, 0x0028(sp)              // offset to joint struct
        sw      a1, 0x002C(sp)              // offset to model/textures
        sw      a2, 0x0030(sp)              // assembly routine for display list
        sw      a3, 0x0034(sp)
        sw      s0, 0x0020(sp)              // hardcoded space used by hazards, generally for pointers


        li      a1, pirate_land_main_       // pirate land routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id

        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        sw      v0, 0x0050(sp)              // save object address
        addiu   t6, r0, 0xFFFF
        or      s0, v0, r0
        sw      t6, 0x0010(sp)
        or      a0, v0, r0
        lw      a1, 0x0030(sp)
        addiu   a2, r0, 0x0004

        jal     Render.DISPLAY_INIT_        // initliaze object for display
        lui     a3, 0x8000

        lui     t7, 0x8013
        lw      t7, 0x13F0(t7)
        lw      t8, 0x0028(sp)
        or      a0, s0, r0
        or      a2, r0, r0
        addiu   a3, r0, 0x001C
        sw      r0, 0x0010(sp)
        sw      r0, 0x0014(sp)

        jal     Render.STAGE_OBJECT_INIT_   // The routine that initializes stage objects for display
        addu    a1, t7, t8

        lw      v0, 0x002C(sp)              // load offset to model/textures of cannon
        lui     t9, 0x8013
        lw      t9, 0x13F0(t9)              // load address to cannon file
        or      a0, s0, r0

        jal     0x8000F8F4
        addu    a1, t9, v0                  // load address of cannon model/textures

        lui     a1, 0x8001
        addiu   a1, a1, 0xDF34
        or      a0, s0, r0
        addiu   a2, r0, 0x0001

        jal     Render.REGISTER_OBJECT_ROUTINE_  // The routine that adds associates a routine with an object
        addiu   a3, r0, 0x0005

        ori     t2, r0, 0xBB4               // animation offset, UPDATE ON REIMPORT
        ori     t3, r0, 0xBF0               // animation offset, UPDATE ON REIMPORT
        lw      t0, 0x0020(sp)
        lw      t0, 0x0000(t0)              // loaded cannon file address
        addiu   a3, r0, r0                  // clear out
        addu    a1, t0, t2                  // load animation struct?
        addu    a2, t0, t3                  // load animation struct?
        jal     0x8000BED8                  // apply stage animation
        lw      a0, 0x0050(sp)              // load object address
        jal     0x8000DF34                  // apply animation part 2
        lw      a0, 0x0050(sp)              // load object address
        lw      a0, 0x0050(sp)              // ~
        lw      a0, 0x0074(a0)              // ~
        lw      a0, 0x0010(a0)              // ~
        lw      a0, 0x0010(a0)              // ~
        lw      a0, 0x0008(a0)              // a0 = cannon barrel joint struct
        lui     at, Cannon.BARREL_Y         // ~
        sw      r0, 0x001C(a0)              // set initial barrel x position
        sw      at, 0x0020(a0)              // set initial barrel y position

        _end:
        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0060              // deallocate stack space
    }

    // @ Description
    // Main function for Pirate Land.
    scope pirate_land_main_: {
        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        // run main function for cannon
        jal     cannon_main_
        nop

        // run main function for water
        jal     pirate_land_water_
        nop

        lw      ra, 0x0024(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for Pirate Land's water.
    scope pirate_land_water_: {
        constant WATER_Y(0xC416)            // current setting - float: -600
        constant SPLASH_Y(0xC3B4)           // current setting - float: -360
        constant RIGHT_X(0x4550)            // current setting - float: 3328
        constant LEFT_X(0xC580)             // current setting - float: -4096

        addiu   sp, sp, -0x0050             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // ~
        sw      s1, 0x002C(sp)              // store ra, s0, s1
        or      s0, r0, r0                  // current port = 0
        lli     s1, 0x0003                  // final iteration = 0x3

        _loop:
        jal     Character.port_to_struct_   // v0 = player struct for current port
        or      a0, s0, r0                  // a0 = current port
        beqz    v0, _loop_end               // skip if no struct found for current port
        nop

        // if the player is present
        sw      v0, 0x003C(sp)              // 0x003C(sp) = px struct

        lw      t6, 0x0008(v0)              // t6 = character id
        lli     at, Character.id.FOX        // at = id.FOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.JFOX       // at = id.JFOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.FALCO      // at = id.FALCO
        bne     at, t6, _check_intro        // skip action check if character != FALCO

        _fire_fox_check:
        lw      t6, 0x0024(v0)              // t6 = action id
        lli     at, Action.FOX.FireFoxAir   // same as FALCO.Action.FireBirdAir
        beq     t6, at, _loop_end           // skip if Fox/Falco are doing their up special
        nop

        _check_intro:
        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t6 = screen_id
        ori     at, r0, 0x0036              // ~
        beq     at, t6, _check_y            // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _loop_end               // skip if time elapsed = 0
        nop

        _check_y:
        lw      v0, 0x0078(v0)              // v0 = px x/y/z coordinates
        li      t8, 0x801313F0              // t8 = stage data
        addu    t8, t8, s0                  // t8 = stage data + port offset
        lwc1    f2, 0x0004(v0)              // f2 = px y position
        lui     at, WATER_Y                 // ~
        mtc1    at, f4                      // f4 = WATER_Y
        c.le.s  f2, f4                      // compare player location to beginning of water
        nop
        bc1fl   _loop_end                   // skip if player is above water...
        sb      r0, 0x005C(t8)              // ...and set px_under_water to FALSE

        lbu     t0, 0x005C(t8)              // t0 = px_under_water
        bnez    t0, _water_physics          // branch if px_under_water != FALSE
        lli     at, OS.TRUE                 // ~

        // if the player has just gone under the water
        sb      at, 0x005C(t8)              // px_under_water = TRUE
        lw      at, 0x0000(v0)              // at = px x
        sw      at, 0x0030(sp)              // 0x0030(sp) = px x
        lui     at, SPLASH_Y                // ~
        sw      at, 0x0034(sp)              // 0x0034(sp) = SPLASH_Y
        sw      r0, 0x0038(sp)              // 0x0038(sp) = 0
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0, 0x0001              // a1 = 1
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0,-0x0001              // a1 = -1
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03D1              // fgm id = 0x3D1 (Splash)

        _water_physics:
        lw      v0, 0x003C(sp)              // v0 = px struct
        lbu     at, 0x018D(v0)              // at = bit field
        andi    at, at, 0x0007              // at = bit field & mask(0b01111111), this disables the fast fall flag
        sb      at, 0x018D(v0)              // store updated bit field
        lui     at, 0xC1A0                  // ~
        mtc1    at, f2                      // f2 = -20.0
        lui     at, 0x3F70                  // ~
        mtc1    at, f4                      // f4 = 0.9375
        lui     at, 0x3F60                  // ~
        mtc1    at, f6                      // f6 = 0.875
        lwc1    f8, 0x0048(v0)              // f8 = x velocity
        lwc1    f10, 0x004C(v0)             // f10 = y velocity
        mul.s   f8, f8, f4                  // f8 = x velocity * 0.9375
        mul.s   f10, f10, f6                // f10 = y velocity * 0.875
        c.le.s  f2, f10                     // ~
        swc1    f8, 0x0048(v0)              // store updated x velocity
        bc1fl   _water_knockback            // if y velocity =< -20...
        swc1    f10, 0x004C(v0)             // ...store updated y velocity

        _water_knockback:
        lui     at, 0x3F7B                  // ~
        mtc1    at, f6                      // f6 = 0.980469
        lwc1    f8, 0x0054(v0)              // f8 = x kb velocity
        lwc1    f10, 0x0058(v0)             // f10 = y kb velocity
        mul.s   f8, f8, f6                  // f8 = x velocity * 0.980469
        mul.s   f10, f10, f6                // f10 = y velocity * 0.980469
        swc1    f8, 0x0054(v0)              // store updated kb x velocity
        swc1    f10, 0x0058(v0)             // store updated kb y velocity
        c.le.s  f2, f10                     // ~
        mul.s   f10, f10, f4                // f10 = y velocity * 0.9375
        bc1fl   _loop_end                   // if y velocity =< -20...
        swc1    f10, 0x0058(v0)             // ...store updated kb y velocity

        _loop_end:
        bne     s0, s1, _loop               // loop if final iteration has not been reached
        addiu   s0, s0, 0x0001              // iterate current port

        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // ~
        lw      s1, 0x002C(sp)              // load ra, s0, s1
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for the cannon.
    scope cannon_main_: {
        addiu   sp, sp, -0x0060             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      s0, 0x002C(sp)              // ~
        sw      s1, 0x0030(sp)              // store ra, a0, s0, s1
        li      s0, 0x801313F0              // s0 = stage data
        lw      s1, 0x0074(a0)              // ~
        lw      s1, 0x0010(s1)              // ~
        lw      s1, 0x0010(s1)              // ~
        lw      s1, 0x0008(s1)              // ~
        addiu   s1, s1, 0x001C              // s1 = cannon barrel joint x/y/z

        _check_state:
        lhu     t0, 0x0050(s0)              // t0 = current state id
        lli     at, Cannon.id.TURNING       // at = id.TURNING
        beq     at, t0, _while_turning      // branch if state id = TURNING
        lli     at, Cannon.id.FIRING        // at = id.FIRING
        beq     at, t0, _while_firing       // branch if state id = FIRING
        nop

        _while_waiting:
        lw      t0, 0x0058(s0)              // t0 = state timer
        addiu   t0, t0,-0x0001              // decrement state timer
        sw      t0, 0x0058(s0)              // store updated timer
        bnez    t0, _end                    // end if state timer has not reached 0
        nop
        // if state timer reaches 0
        lhu     t0, 0x0052(s0)              // t0 = previous state
        lli     at, Cannon.id.TURNING       // at = id.TURNING
        beq     t0, at, _begin_firing       // begin firing if previous state was turning
        nop
        b       _begin_turning              // otherwise, begin turning
        nop

        _while_turning:
        lui     at, Cannon.TURN_SPEED       // at = TURN_SPEED
        lw      t0, 0x0060(s0)              // t0 = frenzy moves
        bnel    t0, r0, _check_position     // branch if frenzy is active...
        lui     at, Cannon.FRENZY_TURN_SPEED // ...and use FRENZY_TURN_SPEED

        _check_position:
        mtc1    at, f2                      // f2 = turn speed
        lhu     t0, 0x0054(s0)              // t0 = current position (destination)
        lli     at, Cannon.pos.LEFT         // at = pos.LEFT
        beql    at, t0, _check_direction    // branch if current position = pos.LEFT
        lui     t1, Cannon.BARREL_X_LEFT    // t1 = BARREL_X_LEFT
        lli     at, Cannon.pos.RIGHT        // at = pos.RIGHT
        beql    at, t0, _check_direction    // branch if current position = pos.RIGHT
        lui     t1, Cannon.BARREL_X_RIGHT   // t1 = BARREL_X_RIGHT
        // if we're here assume position is MIDDLE
        or      t1, r0, r0                  // t1 = BARREL_X_MIDDLE

        _check_direction:
        lw      at, 0x0058(s0)              // at = turning direction
        bnel    at, r0, _apply_turn         // branch if turning direction = left...
        neg.s   f2, f2                      // ...and set f2 to -TURN_SPEED

        _apply_turn:
        lwc1    f4, 0x0000(s1)              // f4 = barrel x
        add.s   f4, f4, f2                  // f4 = barrel x + TURN_SPEED
        swc1    f4, 0x0000(s1)              // store updated barrel x
        mfc1    t0, f4                      // t1 = updated barrel x
        bne     t0, t1, _end                // end if destination has not been reached
        nop
        // if destination has been reached
        b       _begin_waiting              // begin waiting
        nop

        _while_firing:
        lw      t0, 0x0058(s0)              // t0 = state timer
        addiu   t0, t0,-0x0001              // decrement state timer
        sw      t0, 0x0058(s0)              // store updated timer
        bnez    t0, _end                    // end if state timer has not reached 0
        nop
        // if state timer reaches 0
        lui     at, 0x3F80                  // ~
        sw      at, 0x0024(s1)              // ~
        sw      at, 0x0028(s1)              // ~
        b       _begin_waiting              // begin waiting
        sw      at, 0x002C(s1)              // reset x/y/z scale

        _begin_waiting:
        lli     at, Cannon.id.WAITING       // id.WAITING
        lhu     t0, 0x0050(s0)              // t0 = current state id
        sh      at, 0x0050(s0)              // current state = WAITING
        sh      t0, 0x0052(s0)              // update previous state
        lw      at, 0x0060(s0)              // at = frenzy moves
        lli     t0, Cannon.FRENZY_WAIT_TIME // t0 = FRENZY_WAIT_TIME
        addiu   t1, at,-0x0001              // t1 = decremented frenzy moves
        bnel    at, r0, _set_wait_time      // branch if frenzy is active...
        sw      t1, 0x0060(s0)              // ...and store updated frenzy move count
        // if the cannon is not in a frenzy, use normal wait time
        jal     Global.get_random_int_      // v0 = (0-WAIT_TIME_RANGE)
        lli     a0, Cannon.WAIT_TIME_RANGE + 1
        addiu   t0, v0, Cannon.WAIT_BASE_TIME // t0 = WAIT_BASE_TIME + (0-WAIT_TIME_RANGE)
        _set_wait_time:
        b       _end                        // ~
        sw      t0, 0x0058(s0)              // store updated state timer

        _begin_turning:
        lw      at, 0x0060(s0)              // at = frenzy moves
        addiu   t0, at,-0x0001              // t0 = decremented frenzy moves
        bnel    at, r0, pc() + 0x8          // branch if frenzy is active...
        sw      t0, 0x0060(s0)              // ...and store updated frenzy move count

        lli     at, Cannon.id.TURNING       // id.TURNING
        lhu     t0, 0x0050(s0)              // t0 = current state id
        sh      at, 0x0050(s0)              // current state = TURNING
        sh      t0, 0x0052(s0)              // update previous state
        jal     Global.get_random_int_      // v0 = new position(0-2)
        lli     a0, 000003                  // ~
        lhu     t0, 0x0054(s0)              // t0 = current position
        sh      v0, 0x0054(s0)              // update current position
        beq     t0, v0, _begin_waiting      // if current position = previous position, begin waiting immediately
        sh      t0, 0x0056(s0)              // update previous position

        // if the cannon needs to turn
        slt     at, v0, t0                  // at = 1 if turning left, 0 if turning right
        sw      at, 0x0058(s0)              // store turning direction
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 001012              // fgm id = 1012 (cannon turn)
        b       _end                        // branch to end
        nop

        _begin_firing:
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 001013              // fgm id = 1013 (cannon shot)
        jal     0x801008F4                  // screen shake
        lli     a0, 0x0000                  // shake severity = light
        lw      a0, 0x0028(sp)              // a0 = cannon object
        jal     cannonball_stage_setting_   // INITIATE CANNONBALL
        lhu     a1, 0x0054(s0)              // a1 = current position
        lli     at, Cannon.id.FIRING        // id.FIRING
        lhu     t0, 0x0050(s0)              // t0 = current state id
        sh      at, 0x0050(s0)              // current state = FIRING
        sh      t0, 0x0052(s0)              // update previous state
        lli     at, 000012                  // ~
        sw      at, 0x0058(s0)              // state timer = 12 frames
        lui     at, Cannon.SHOT_SCALING     // ~
        sw      at, 0x0024(s1)              // ~
        sw      at, 0x0028(s1)              // ~
        sw      at, 0x002C(s1)              // increase x/y/z scale
        // check if the cannon should go into a frenzy
        lw      at, 0x0060(s0)              // at = frenzy moves
        addiu   t0, at,-0x0001              // t0 = decremented frenzy moves
        bnel    at, r0, _end                // branch if frenzy is active...
        sw      t0, 0x0060(s0)              // ...and store updated frenzy move count

        jal     Global.get_random_int_      // v0 = (0-99)
        lli     a0, 000100                  // ~
        sltiu   at, v0, Cannon.CHANCE_FRENZY // ~
        beqz    at, _end                    // skip if random int is outside of CHANCE_FRENZY range
        nop

        _begin_frenzy:
        jal     Global.get_random_int_      // v0 = new position(0-FRENZY_MOVES_RANGE)
        lli     a0, Cannon.FRENZY_MOVES_RANGE + 1
        addiu   at, v0, Cannon.FRENZY_BASE_MOVES // at = FRENZY_BASE_MOVES + (0-FRENZY_MOVES_RANGE)
        sw      at, 0x0060(s0)              // store frenzy moves

        _end:
        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x002C(sp)              // ~
        lw      s1, 0x0030(sp)              // load ra, s0, s1
        addiu   sp, sp, 0x0060              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    // a0 - cannon object, a1 - firing direction
    scope cannonball_stage_setting_: {
        addiu   sp, sp, -0x0080             // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0040(sp)              // ~
        sw      a1, 0x0044(sp)              // store ra, a0, a1
        lw      t0, 0x0074(a0)              // ~
        lw      t0, 0x0010(t0)              // t0 = cannon base joint struct
        lw      t1, 0x0010(t0)              // ~
        lw      t1, 0x0008(t1)              // t1 = cannon barrel joint struct
        lwc1    f2, 0x001C(t0)              // f2 = cannon base x
        lwc1    f4, 0x001C(t1)              // f4 = cannon barrel x
        add.s   f2, f2, f4                  // f2 = base + barrel x position
        lwc1    f6, 0x0020(t0)              // f6 = cannon base y
        lwc1    f8, 0x0020(t1)              // f8 = cannon barrel y
        add.s   f6, f6, f8                  // f6 = base + barrel y position
        lwc1    f10, 0x0024(t0)             // f10 = cannon base z
        lwc1    f12, 0x0024(t1)             // f12 = cannon barrel z
        add.s   f10, f10, f12               // f10 = base + barrel z position
        swc1    f2, 0x0020(sp)              // ~
        swc1    f6, 0x0024(sp)              // ~
        swc1    f10, 0x0028(sp)             // store x/y/z coordinates
        lw      a0, 0x0040(sp)              // a0 = cannon object
        li      a1, cannonball_projectile_struct // a1 = main projectile struct address
        addiu   a2, sp, 0x0020              // a2 = coordinates to create projectile at
        jal     0x801655C8                  // create projectile
        addiu   a3, r0, 0x0001              // I believe this makes the projectile hit all players

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        sw      v0, 0x0030(sp)              // 0x0030(sp) = projectile object
        jal     0x80100480                  // create small explosion gfx
        addiu   a0, sp, 0x0020              // a0 = cannon barrel coordinates
        lw      v0, 0x0030(sp)              // v0 = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile special struct
        addiu   at, r0, 0x0080              // at = bit flag for camera tracking
        sb      at, 0x026C(v1)              // influence camera flag = true
        lli     at, OS.TRUE                 // ~
        sw      at, 0x01B4(v1)              // first frame flag = TRUE
        sw      r0, 0x01B8(v1)              // smoke trail timer = 0
        lw      a0, 0x0074(v0)              // a0 = projectile first joint struct
        lui     at, 0x8019                  // ~
        lw      at, 0xCA80(at)              // at = 1.5708 rads/90 degrees
        sw      at, 0x0034(a0)              // set joint rotation to 90 degrees
        lw      a1, 0x0044(sp)              // a1 = cannon position
        lli     at, Cannon.pos.LEFT         // at = pos.LEFT
        beql    at, a1, _apply_animation    // branch if current position = pos.LEFT
        lli     at, Cannon.offset.LEFT      // at = offset.LEFT
        lli     at, Cannon.pos.RIGHT        // at = pos.RIGHT
        beql    at, a1, _apply_animation    // branch if current position = pos.RIGHT
        lli     at, Cannon.offset.RIGHT     // at = offset.RIGHT
        // if we're here assume position is MIDDLE
        lli     at, Cannon.offset.MIDDLE    // at = offset.RIGHT

        _apply_animation:
        li      a1, 0x801313F0              // ~
        lw      a1, 0x0004(a1)              // ~
        lw      a1, 0x0008(a1)              // a1 = animation tracks address
        add     a1, a1, at                  // a1 = animation tracks + offset
        jal     0x8000BD1C                  // apply animation track to joint
        or      a2, r0, r0                  // a2 = 0

        _end_stage_setting:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0080              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for the cannonball.
    scope cannonball_main_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0084(a0)              // a0 = projectile special struct

        _check_animation_end:
        lw      at, 0x01B4(a1)              // at = first frame flag
        bnel    at, r0, _end                // branch if first frame flag != FALSE...
        sw      r0, 0x01B4(a1)              // ...and set first frame flag to FALSE
        mtc1    r0, f6                      // f6 = 0
        lwc1    f8, 0x0078(a0)              // f8 = animation frame
        c.le.s  f8, f6                      // ~
        nop                                 // ~
        bc1fl   _smoke_trail                // branch if animation end has not been reached
        nop

        _explosion:
        // if the end of the animation has been reached, begin explosion
        jal     cannonball_explosion_       // explode
        nop
        b       _end                        // jump to end
        nop

        _smoke_trail:
        lw      t0, 0x01B8(a1)              // t0 = smoke trail timer
        addiu   t0, t0, 0x0001              // increment smoke trail timer
        lli     at, 000009                  // at = timer end
        bnel    at, t0, _end                // skip if timer has not reached end
        sw      t0, 0x01B8(a1)              // store updated timer

        // if we're here, create a smoke gfx and reset the timer
        sw      r0, 0x01B8(a1)              // reset smoke trail timer
        lw      a0, 0x0074(a0)              // a0 = projectile joint struct
        addiu   a0, a0, 0x001C              // at = projectile x/y/z coordinates
        jal     0x800FF590                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return FALSE (don't destroy projectile)
    }

    // @ Description
    // This subroutine sets up the explosion for the cannonball.
    // a0 = projectile object
    scope cannonball_explosion_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lw      a1, 0x0084(a0)              // a1 = projectile special struct
        lui     t2, 0x43B4                  // ~
        sw      t2, 0x0128(a1)              // set hitbox size to 360.00
        lli     t2, 000025                  // ~
        sw      t2, 0x0104(a1)              // set hitbox damage to 25
        lli     t2, 000001                  // ~
        sw      t2, 0x010C(a1)              // set hitbox type to fire
        lli     t2, 000361                  // ~
        sw      t2, 0x012C(a1)              // set hitbox angle to 361
        lli     t2, 000090                  // ~
        sw      t2, 0x0130(a1)              // set hitbox kbg to 90
        lli     t2, 000050                  // ~
        sw      t2, 0x0138(a1)              // set hitbox bkb to 50
        lli     t2, 000025                  // ~
        sh      t2, 0x0146(a1)              // set hitbox FGM to 25
        lw      a0, 0x0074(a0)              // ~
        jal     0x801005C8                  // create explosion gfx
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z
        lw      a0, 0x0018(sp)              // a0 = projectile object
        // copy logic from 0x80168F2C, which is used for setting up the samus bomb explosion
        // but omit the line which originally set the hitbox size, and the jump to return address instruction
        OS.copy_segment(0xE396C, 0x38)      // ~
        OS.copy_segment(0xE39A8, 0x28)      // ~
        sw      r0, 0x0290(v0)              // copy original logic
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 000001              // fgm id = 1
        jal     0x801008F4                  // screen shake
        lli     a0, 0x0001                  // shake severity = moderate
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = projectile special struct
        lli     at, 000015                  // ~
        sw      at, 0x0268(a0)              // set explosion timer to 15 frames
        // refresh hitbox
        sw      r0, 0x0214(a0)              // reset hit object pointer 1
        sw      r0, 0x021C(a0)              // reset hit object pointer 2
        sw      r0, 0x0224(a0)              // reset hit object pointer 3
        sw      r0, 0x022C(a0)              // reset hit object pointer 4
        sw      r0, 0x0008(a0)              // remove owner
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return FALSE (don't destroy projectile)
    }

    cannonball_hitbox_pointer:
    dw  0x00000000

    OS.align(16)
    cannonball_projectile_struct:
    constant CANNONBALL_ID(0x1005)
    dw 0x00000000                           // unknown
    dw CANNONBALL_ID                        // projectile id
    dw 0x00000000                           // address of cannonball file
    dw 0x00000000                           // offset to hitbox
    dw 0x12480000                           // This determines z axis rotation? (samus is 1246)
    dw cannonball_main_                     // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0                                    // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw 0                                    // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0                                    // This function runs when the projectile collides/clangs with a hitbox.
    dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    cannonball_properties_struct:
    dw 999                                  // 0x0000 - duration (int)
    float32 999                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.1                             // 0x0014 - rotation speed
    float32 270                             // 0x0018 - initial angle (ground)
    float32 270                             // 0x001C   initial angle (air)
    float32 100                             // 0x0020   initial speed
    dw 0x00000000                           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

    // @ Description
    // This alters the Bumper display list to use the casino bumper texture.
    // Also updates the sfx for the bumper.
    scope sonic_btp_setup: {
        OS.patch_start(0x112354, 0x8018DC14)
        jal     sonic_btp_setup
        ldc1    f20, 0x0020(sp)             // original line 2
        lw      ra, 0x003C(sp)              // original line 1
        OS.patch_end()

        lli     at, Stages.id.BTP_SONIC     // at = Stages.id.BTP_SONIC
        li      s1, Global.match_info
        lw      s1, 0x0000(s1)              // s1 = match info
        lbu     s1, 0x0001(s1)              // s1 = current stage ID
        bne     s1, at, _end                // if current stage is not Sonic's Board the Platforms, then skip
        lui     at, 0x8013
        lw      at, 0x1300(at)              // at = stage file address
        lw      at, 0x00B0(at)              // at = bumper file address

        // s0 is the last bumper

        lw      t0, 0x0074(s0)              // t0 = bumper position struct
        lw      t1, 0x0050(t0)              // t1 = bumper display list

        lui     t2, 0xFD10                  // t2 = FD100000 = load palette command
        addiu   t3, at, 0x0040              // t3 = address of palette
        addiu   t4, at, 0x0090              // t4 = address of bumper texture

        sw      t2, 0x0050(t1)              // update load palette command to not be dynamic
        sw      t3, 0x0054(t1)              // ~
        sw      t4, 0x0084(t1)              // update texture pointer

        or      t0, s0, r0                  // t0 = last bumper object
        lli     t4, 0x03D5                  // t4 = Sonic bumper fgm_id
        _loop:
        lw      t1, 0x0084(t0)              // t1 = bumper special struct
        sh      t4, 0x0156(t1)              // set hit sfx
        lw      t0, 0x0008(t0)              // t0 = previous bumper object
        bnez    t0, _loop                   // keep looping if there is a previous bumper
        nop

        _end:
        jr      ra
        lw      s0, 0x0028(sp)              // original line 3
    }

    // @ Description
    // This creates the Bumper
    scope casino_night_setup: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0024(sp)

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        addiu   a0, r0, 0x0017              // item ID
        addiu   a1, r0, r0                  // x coordinate
        lui     a2, 0x4522                  // y coordinate
        addiu   a3, r0, r0                  // stage ID of original stage
        addiu   t0, r0, r0                  // default ecb
        addiu   t1, r0, r0                  // do not run a routine every frame
        jal     add_item_                   // add item routine
        addiu   t2, r0, 0x0002              // unique id for casino night bumper

        lui     at, 0x8013
        lw      v0, 0x13F8(at)              // v0 = bumper object
        lw      at, 0x13F0(at)              // at = bumper file address
        addiu   t1, at, 0x02D0              // t1 = address of casino bumper display list

        lw      t0, 0x0074(v0)              // t0 = bumper position struct
        sw      t1, 0x0050(t0)              // update display list

        _end:
        lw      ra, 0x0024(sp)
        jr      ra
        addiu   sp, sp, 0x0040
    }

    // @ Description
    // Changes how hard the characters bounce of the side bumpers in Casino Night
    scope casino_night_side_bumper_bounce: {
        OS.patch_start(0xBC5C8, 0x80141B88)
        j       casino_night_side_bumper_bounce
        addiu   a1, r0, Stages.id.CASINO         // a1 = Casino Night
        return:
        OS.patch_end()

        // s0 = player struct
        li      a0, Global.match_info
        lw      a0, 0x0000(a0)              // a0 = match info
        lbu     a0, 0x0001(a0)              // a0 = current stage ID
        bnel    a1, a0, _normal             // if current stage is not Casino Night Zone, then do normal settings
        lui     a1, 0x3F4C                  // original line 1

        lhu     a1, 0x00CE(s0)              // load collision bit field in player struct

        addiu   a0, r0, 0x0001              // left hit wall bitfield 1
        beql    a0, a1, _right_check
        lbu     a1, 0x011F(s0)              // load surface type
        lbu     a1, 0x0133(s0)              // load surface type

        _right_check:
        ori     a0, r0, 0x0016              // all surface ID above 16 are bumpers
        addiu   v0, r0, r0
        slt     v0, a0, a1                  // if surface ID is greater than 16, should use bumper bounce
        beqzl   v0, _normal
        lui     a1, 0x3F4C                  // original line 1


        jal     0x800269C0                  // play fgm
        ori     a0, r0, 0x3D6               // fgm id = 0x3D6


        li      a1, 0x3f8ccccd              // 1.1 in fp
        j       return
        nop

        _normal:
        j       return
        ori     a1, a1, 0xCCCD              // original line 2
    }

    // @ Description
    // Applies knockback to characters that bump into the side bumpers
    scope casino_night_side_bumper_knockback: {
        OS.patch_start(0x61440, 0x800E5C40)
        j       casino_night_side_bumper_knockback
        nop
        _return:
        OS.patch_end()

        // a0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // store
        sw      t1, 0x0008(sp)
        sw      t2, 0x000C(sp)

        addiu   t1, r0, Stages.id.CASINO    // t1 = Casino Night
        li      t0, Global.match_info
        lw      t0, 0x0000(t0)              // t0 = match info
        lbu     t0, 0x0001(t0)              // t0 = current stage ID
        bne     t1, t0, _normal             // if current stage is not Casino Night Zone, then do normal settings

        _action_check:
        addiu   t1, r0, r0
        lw      t0, 0x0024(a0)              // load current action
        slti    t1, t0, Action.DamageHigh1  // if action is less than damage high, apply knockback
        bnez    t1, _wall_check
        ori     t2, Action.DamageFlyRoll
        slt     t1, t2, t0                  // if action is greater than damage fly roll, apply knockback
        bnez    t1, _wall_check
        nop
        beq     r0, r0, _normal
        nop

        _wall_check:
        lw      t1, 0x00CC(a0)              // load collision bit field in player struct
        li      t0, 0x00010001              // left hit wall bitfield 1
        beq     t0, t1, _right_check
        nop
        li      t0, 0x00200020              // right hit wall bitfield 2
        beq     t0, t1, _left_check
        nop
        beq     r0, r0, _normal
        nop

        _right_check:
        lbu     t1, 0x011F(a0)              // load surface type
        ori     t0, r0, 0x0016              // all surface ID above 16 are bumpers
        addiu   t2, r0, r0
        slt     t2, t0, t1                  // if surface ID is greater than 16, should use bumper knockback
        beqz    t2, _normal
        nop
        lw      t0, 0x0044(a0)              // load players facing
        addiu   t2, r0, 0x0001
        beql    t0, t2, _surface_end
        addiu   t1, t1, -0x0003
        beq     r0, r0, _surface_end
        nop

        _left_check:
        lbu     t1, 0x0133(a0)              // load surface type
        ori     t0, r0, 0x0016              // all surface ID above 16 are bumpers
        addiu   t2, r0, r0
        slt     t2, t0, t1                  // if surface ID is greater than 16, should use bumper knockback
        beqz    t2, _normal
        nop
        lw      t0, 0x0044(a0)              // load players facing
        addiu   t2, r0, 0x0001
        beql    t0, t2, _surface_end
        addiu   t1, t1, 0x0003

        _surface_end:
        addu    t8, t1, r0                  // place surface type in t8 to apply knockback
        lw      t0, 0x0004(sp)              // load
        lw      t1, 0x0008(sp)
        lw      t2, 0x000C(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        j       0x800E5C64                  // skip some checks
        lw      v0, 0x00EC(a0)


        _normal:
        lw      t0, 0x0004(sp)              // load
        lw      t1, 0x0008(sp)
        lw      t2, 0x000C(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        bnel    t7, r0, _0x800E5D18         // original line 1, modified
        or      v0, r0, r0                  // original line 2

        j       _return
        nop

        _0x800E5D18:
        j       0x800E5D18
        nop
    }

    // @ Description
    // This establishes Robot Bee in Metallic Madness
    scope metallic_madness_setup: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop



        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address


        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to Robot Bee
        addiu   t3, t3, -0x07E8             // subtract offset amount to get to top of Robot Bee file
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0008(t2)              // clear spot used for timer
        lw      t4, 0x0130(t1)              // load pointer to laser hitbox file
        sw      t3, 0x0000(t2)              // save Robot Bee header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save stage header address to second word of this struct, as Pirhana Plant does the same
        sw      t4, 0x000C(t2)              // save pointer to laser hitbox file

        li      t3, robot_bee_laser_hitbox_pointer
        sw      t4, 0x0000(t3)              // save pointer to pointer spot
        li      t2, robot_bee_laser_projectile_struct
        sw      t3, 0x0008(t2)              // save pointer to cannonball hitbox file

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, bee_factory_            // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, shrink_timer_           // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0068
        jr      ra
        nop
    }

    robotbee_coordinates:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000



    // @ Description
    // main routine for Robot Bee
    scope bee_factory_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t0 = screen_id
        ori     t5, r0, 0x0036              // ~
        beq     t5, t6, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0008(t5)              // load timer
        addiu   t7, t6, 0x0001              // add to timer
        addiu   at, r0, 0x0001
        slti    t8, t6, 0x05DC              // wait 1500 frames
        bne     t8, r0, _end                // if not 1500 or greater, skip animation application, this is the initial check, Robot Bee won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)              // save updated timer
        sw      t6, 0x0010(sp)              // save original timer
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x05DC              // decimal 1500 possible integers
        lw      a0, 0x0020(sp)              // load registers
        addiu   t4, r0, 0x0050              // place 50 as the random number to spawn Robot Bee
        beq     t4, v0, _spawn              // if 50, spawn Robot Bee
        addiu   t4, r0, 0x0BB8              // put in max time before Robot Bee, 3000 frames
        lw      t6, 0x0010(sp)              // load timer from stack
        bne     t4, t6, _end                // if not same as timer, skip animation
        nop

        _spawn:
        sw      r0, 0x0008(t5)              // restart timer

        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.RobotBee.id        // set item id to Robot Bee
        li      a2, robotbee_coordinates    // location in which Robot Bee spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        sw      a0, 0x0024(sp)
        li      t5, 0x801313F0

        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x0002              // decimal 2 possible integers
        sw      v0, 0x0020(t5)              // save direction ID
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x0002              // decimal 2 possible integers

        sw      v0, 0x0020(t5)              // save direction ID

        lw      t1, 0x0000(t5)              // load Robot Bee file ram address
        bnez    v0, _movement
        addiu   t2, r0, 0x0908              // load in offset of animation track 1
        addiu   t2, r0, 0x3598              // load in offset of animation track 1

        _movement:
        lw      a0, 0x0024(sp)
        addiu   a2, r0, 0x0000              // clear out a2
        lw      a0, 0x0074(a0)              // Load Top Joint
        jal     0x8000BD1C                  // animation track 1 set up
        addu    a1, t1, t2                  // place animation track address in a1

        li      t5, 0x801313F0

        lw      t3, 0x0000(t5)              // load Robot Bee file ram address
        addiu   t4, r0, 0x09B4              // offset to track 2
        lw      a0, 0x0080(a0)              // unknown, probably for image swapping
        jal     0x8000BD54                  // set up track 2
        addu    a1, t3, t4                  // place animation track address in a1

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    shrink_timer_table:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    // @ Description
    // main routine for shrink ray duration
    scope shrink_timer_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        // check to see if mushroom acquired during shrink ray time
        li      t0, shrink_timer_table
        li      t5, Item.SuperMushroom.player_shrooms
        addiu   t6, r0, 0x0003

        _loop:
        lw      t1, 0x0000(t5)      // t1 = active mushrom routine object, or 0 if no active shroom
        bnezl   t1, _skip           // if active shroom, clear timer
        sw      r0, 0x0000(t0)      // clear timer

        _skip:
        addiu   t0, t0, 0x0004      // advance port
        addiu   t5, t5, 0x0004      // advance port
        bnezl   t6, _loop           // loop after all ports gone through
        addiu   t6, t6, 0xFFFF      // subtract 1


        // check to see if should end duration of shrink
        li      t0, shrink_timer_table
        li      t6, Size.multiplier_table
        li      t8, Size.match_state_table
        addiu   t5, r0, 0x0003      // load loop amount

        _loop_2:
        lw      t1, 0x0000(t0)      // load timer for port 1
        addiu   t3, r0, 0x0001      // place 1 in timer
        addiu   t2, t1, 0xFFFF      // subtract 1 from timer
        beq     t1, t3, _end_duration
        nop
        bnezl   t1, pc() + 8        // if timer isn't 0, update timer
        sw      t2, 0x0000(t0)      // update timer
        b       _next
        nop

        _end_duration:
        lw      t3, 0x0000(t8)      // t3 = size state
        beqzl   t3, _reset_size_multiplier // if in NORMAL state, use normal size multiplier
        lui     t4, 0x3F80          // t4 = (float) 1.0
        lli     t1, Size.state.GIANT // t1 = GIANT
        beql    t3, t1, _reset_size_multiplier // if in GIANT state, use giant size multiplier
        lui     t4, 0x4010          // t4 = 2.25 (float)
        // otherwise, we're in TINY state so use tiny size multiplier
        lui     t4, 0x3F00          // t4 = 0.5 (float)

        _reset_size_multiplier:
        sw      t4, 0x0000(t6)      // reset size multiplier
        sw      r0, 0x0000(t0)      // clear timer

        _next:
        addiu   t0, t0, 0x0004      // advance port
        addiu   t6, t6, 0x0004      // advance port
        addiu   t8, t8, 0x0004      // advance port
        bnez    t5, _loop_2         // if t5 isn't 0, then we haven't looped through each spots
        addiu   t5, t5, 0xFFFF      // subtract 1 from t5

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    constant REPEAT_TIMER(0x000D)
    // @ Description
    // Subroutine which sets up initial properties of Robot Bee.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope robot_bee_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.RobotBee.item_info_array
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        li      a3, robotbee_coordinates
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, robotbee_coordinates        // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object


        // item is created
        sw      r0, 0x0040(v0)                  // clear laser timer
        addiu   t1, r0, 0x0030
        sw      t1, 0x0044(v0)                  // save sfx timer so it starts with noise
        addiu   t1, r0, REPEAT_TIMER
        sw      t1, 0x0048(v0)                  // laser repeat
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        sw      r0, 0x0020(t9)                  // set initial y
        sw      r0, 0x001C(t9)                  // save initial x coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        sw      r0, 0x0024(t9)                  // set initial z

        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag

        lli     at, 0x0001                      // ~
        sw      at, 0x010C(v1)                  // enable hitbox

        lui     at, 0x4316                      // 150 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0005                  // hitbox damage set to 5
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0361                  // sakurai angle
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        // 0x0118 damage multiplier
        addiu   t4, r0, r0                      // punch effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = punch
        addiu   t4, r0, 0x0026                  // medium kick sound ID
        sh      t4, 0x0156(v1)                  // save hitbox sound (could also do bat ping 0x34)
        addiu   t4, r0, 0x0050                  // put hitbox bkb at 20
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0025                  // put hitbox kbs at 25
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, robot_bee_blast_zone_       // load Robot Bee blast zone routine
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
    // main routine for Robot Bee
    scope robot_bee_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0018(sp)
        lw      t1, 0x0040(a0)          // load laser timer
        addiu   t2, r0, 0x0100
        slt     at, t2, t1
        bnez    at, _duration           // if over 100 frames of don't fire
        addiu   t2, r0, 0x0060

        slt     at, t2, t1
        beqz    at, _duration           // if not 60 frames of don't fire
        lw      t1, 0x0048(a0)          // load laser repeat timer

        addiu   t3, t1, 0x0001
        addiu   t2, r0, REPEAT_TIMER    // timer count
        bnel    t1, t2, _sfx_timer      // branch if duration % 0x1E != 0
        sw      t3, 0x0048(a0)          // update laser repeat timer

        jal     robot_bee_laser_
        sw      r0, 0x0048(a0)

        _sfx_timer:
        lw      a0, 0x0018(sp)
        lw      t1, 0x0044(a0)          // load sfx timer
        addiu   t3, t1, 0x0001          // add to timer
        addiu   t2, r0, 0x0030          // timer count = 10
        bnel    t1, t2, _duration       // branch if duration % 0x1E != 0
        sw      t3, 0x0044(a0)          // save updated timer

        sw      r0, 0x0044(a0)          // clear sfx timer
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x03FB          // fgm id = Shrinkray

        _duration:
        lw      a0, 0x0018(sp)
        lw      t1, 0x0040(a0)          // load laser timer
        addiu   t3, t1, 0x0001
        addiu   t2, r0, 0x0186
        slt     at, t2, t1

        beqz    at, _continue           // if not 390 frames of existence continue
        sw      t3, 0x0040(a0)          // save updated timer

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001          // set to destroy

        _continue:
        addu    v0, r0, r0

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Destruction routine for Robot Bee
    scope robot_bee_destroy_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03E8              // fgm id = Badnik Destroy

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001         // set to destroy

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // this routine gets run by whenever Bee crosses the blast zone.
    scope robot_bee_blast_zone_: {
        jr      ra
        addiu   v0, r0, 0x0001      // destroys Robot Bee when it hits the blast zone
    }

    // @ Description
    // This sets up for stage spawning of projectile
    scope robot_bee_laser_: {
        addiu   sp, sp, -0x0038
        sw      ra, 0x0014(sp)      // save ra to stack
        sw      a0, 0x0020(sp)      // save object struct
        lw      v0, 0x0084(a0)      // load item special struct
        sw      v0, 0x0034(sp)      // save item special struct to stack

        lw      t0, 0x0074(a0)      // load position struct/topjoint

        lui     at, 0x4270          // x scaling amount set to 60 in FP
        sw      at, 0x0018(sp)      // x scaling set to
        sw      at, 0x001C(sp)      // y scaling is 0
        sw      r0, 0x0020(sp)      // z scaling is 0

        li      at, 0x801313F0
        lw      at, 0x0020(at)      // load facing of bee
        bnez    at, _x_spawn
        lui     at, 0xc342          // load -194
        lui     at, 0x4342          // load 194

        _x_spawn:
        lwc1    f2, 0x001C(t0)      // load x address of robot bee

        mtc1    at, f4
        add.s   f2, f2, f4
        swc1    f2, 0x0028(sp)      // save x address to stack for spawn projectile addresses

        lwc1    f2, 0x0020(t0)      // load y address of robot bee
        lui     at, 0xc3a8          // load -336.0
        mtc1    at, f4
        add.s   f2, f2, f4
        swc1    f2, 0x002C(sp)      // save y address to stack for spawn projectile addresses

        sw      r0, 0x0030(sp)      // save z address of robot bee for spawn projectile addresses
        jal     robot_bee_laser_stage_setting   // jump to laser stage setting
        addiu   a2, sp, 0x0028      // addresses portion of stack


        // normally saves  something to player struct in free space
        lw      ra, 0x0014(sp)      // load ra from stack
        addiu   sp, sp, 0x0038
        jr      ra
        nop
    }

    // @ Description
    // Stage spawning for initial laser
    scope robot_bee_laser_stage_setting: {
        addiu   sp, sp, -0x0028
        sw      a2, 0x0024(sp)      // save spawn addresses
        sw      ra, 0x0014(sp)      // save ra
        //      a0 = object struct
        li      a1, robot_bee_laser_projectile_struct

        jal     0x801655C8          // Projectile stage settling
        addiu   a3, r0, 0x0001      // Hit all players

        bnez    v0, _destroyed_projectile_check_branch
        or      v1, v0, r0
        beq     r0, r0, _end
        or      v0, r0, r0

        _destroyed_projectile_check_branch:
        lw      a0, 0x0084(v1)      // item special struct loaded in


        addiu   t7, r0, 0x0028      // load in duration
        sw      t7, 0x0268(a0)      // save duration

        li      t5, 0x801313F0
        lw      t4, 0x0020(t5)      // load facing of bee
        bnez    t4, _x_speed
        lui     at, 0xc2c8
        lui     at, 0x42c8

        _x_speed:
        sw      at, 0x0020(a0)      // save x speed
        lui     at, 0xc2c8
        sw      at, 0x0024(a0)      // save y speed

        lwc1    f12, 0x0020(a0)     // f12 = x speed
        lwc1    f14, 0x0024(a0)     // f14 = y speed
        jal     0x8001863C          // f0 = atan2f(f12, f12) = rotation angle
        sw      v1, 0x0018(sp)
        lw      t7, 0x0018(sp)      // t7 = projectile object
        lw      t8, 0x0074(t7)      // t8 = projectile position struct
        swc1    f0, 0x0038(t8)      // update rotation angle

        jal     0x80103320          // fox laser fire blast effect
        lw      a0, 0x0024(sp)

        lw      v0, 0x0018(sp)

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Main routine for Metallic Madness Laser
    // Based on 0x8016a700
    scope robot_bee_laser_main_: {
        // a0 = projectile object
        lw      v0, 0x0074(a0)      // v0 = position struct

        li      at, 0x801313F0      // load hardcoded stage address
        lw      at, 0x0020(at)      // load direction ID of Bee
        beqz    at, _direction
        lwc1    f0, 0x0040(v0)      // f0 = current X scaling

        li      t0, 0xc2555555      // t0 = minimum scaling
        mtc1    t0, f2              // move to f2
        c.lt.s  f2, f0              // check if current X scaling < minimum X scaling

        bc1f    _end                // if current X scaling =< max X scaling, skip
        nop

        lui     at, 0xc040          // at = change to X scaling
        mtc1    at, f4              // f4 = change to X scaling
        add.s   f6, f0, f4          // f6 = new X scaling
        swc1    f6, 0x0040(v0)      // set new X scaling
        c.lt.s  f6, f2              // check if min X scaling > new X scaling
        nop
        bc1f    _end                // if min X scaling =< new X scaling, skip
        nop

        beq     r0, r0, _end
        swc1    f2, 0x0040(v0)      // set X scaling to min

        _direction:
        lui     at, 0x8019
        lwc1    f2, 0xCAA0(at)      // f2 = maximum X scaling
        lui     at, 0x8019
        c.lt.s  f0, f2              // check if current X scaling < max X scaling

        bc1f    _end                // if current X scaling >= max X scaling, skip
        nop

        //lwc1    f4, 0xCAA4(at)    // f4 = change to X scaling (fox laser)
        lui     at, 0x4040          // at = change to X scaling
        mtc1    at, f4              // f4 = change to X scaling
        add.s   f6, f0, f4          // f6 = new X scaling
        swc1    f6, 0x0040(v0)      // set new X scaling
        c.lt.s  f2, f6              // check if max X scaling < new X scaling
        nop
        bc1f    _end                // if max X scaling >= new X scaling, skip
        nop

        swc1    f2, 0x0040(v0)      // set X scaling to max

        _end:
        jr      ra
        or      v0, r0, r0
    }


    // @ Description
    // Collision routine for Metallic Madness Laser
    scope robot_bee_laser_collision_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)

        jal     0x80167C04
        sw      a0, 0x0018(sp)
        beq     v0, r0, _continue
        lw      a0, 0x0018(sp)

        //      if hits collision and should be destroyed
        lw      t6, 0x0018(sp)
        lw      a0, 0x0074(t6)
        jal     0x80103320          // Laser explosion routine
        addiu   a0, a0, 0x001C

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001      // place 1 in v0 for destruction

        _continue:
        or      v0, r0, r0          // clear v0, so projectile continues

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // @ Description
    // Hit routine for Metallic Madness Laser
    scope robot_bee_laser_hit_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      v0, 0x0008(sp)

        lw      t0, 0x0084(a0)      // load special struct
        addiu   t0, t0, 0x0214      // beginning of the player hit detections
        addiu   t5, r0, 0x0003      // place loop amount
        li      t6, Size.multiplier_table
        li      t8, shrink_timer_table
        li      v1, Item.SuperMushroom.player_shrooms

        _loop:
        lw      t1, 0x0000(t0)      // load slot one, may contain player object
        beqz    t1, _end
        nop

        lw      t2, 0x0000(t1)      // t2 = object type
        lli     t3, 0x03E8          // t3 = player object id
        bne     t2, t3, _next       // skip if object type != player
        nop
        lw      t2, 0x0084(t1)      // load player struct from object
        lw      t3, 0x018C(t2)
        li      v0, 0x04000010      // this is a check to see if player is reflecting and is thereby immune to shrinkage
        beq     v0, t3, _next
        nop
        li      v0, 0x08800110      // this is a check to see if player is using psi magnet and should be immune
        beq     v0, t3, _next
        nop

        lbu     t3, 0x000D(t2)      // load port
        sll     t3, t3, 0x0002      // t1 = offset to size multiplier
        addu    t7, t6, t3          // t0 = address of size multiplier
        addu    t9, t8, t3          // t9 = address of shrink timer

        lui     t4, 0x3F00          // t4 = Shrunk size multiplier
        addiu   at, r0, 0x0384      // at = shrink duration
        sw      at, 0x0000(t9)      // save duration to shrink timer for port
        sw      t4, 0x0000(t7)      // save size to multiplier table for port
        addu    t9, v1, t3          // t9 = address of player shroom
        lw      t4, 0x0000(t9)      // t9 = active shroom routine if not 0
        beqz    t4, _next           // if no active shroom, skip
        sw      r0, 0x0000(t9)      // clear shroom reference

        // destroy the active shroom routine
        addiu   sp, sp, -0x0020     // allocate stack space
        sw      ra, 0x0004(sp)      // save registers
        sw      a0, 0x0008(sp)      // ~
        sw      t0, 0x000C(sp)      // ~
        sw      t5, 0x0010(sp)      // ~
        sw      t6, 0x0014(sp)      // ~
        sw      t8, 0x0018(sp)      // ~
        sw      v1, 0x001C(sp)      // ~
        jal     Render.DESTROY_OBJECT_
        or      a0, t4, r0          // a0 = shroom routine object
        lw      ra, 0x0004(sp)      // restore registers
        lw      a0, 0x0008(sp)      // ~
        lw      t0, 0x000C(sp)      // ~
        lw      t5, 0x0010(sp)      // ~
        lw      t6, 0x0014(sp)      // ~
        lw      t8, 0x0018(sp)      // ~
        lw      v1, 0x001C(sp)      // ~
        addiu   sp, sp, 0x0020      // deallocate stack space

        _next:
        addiu   t0, t0, 0x0008      // add to get address of next hit detection space
        bnez    t5, _loop           // if t5 isn't 0, then we haven't looped through each spots
        addiu   t5, t5, 0xFFFF      // subtract 1 from t5

        _end:
        lw      ra, 0x0014(sp)
        lw      v1, 0x0010(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        addiu   v0, r0, r0          // keep projectile alive
    }

    // @ Description
    // Hit routine for Metallic Madness Laser
    scope robot_bee_laser_reflect_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        lw      a0, 0x0084(a0)
        lw      t7, 0x0008(a0)
        lw      a1, 0x0084(t7)
        sw      a0, 0x001C(sp)
        lwc1    f0, 0x0020(a0)

        neg.s   f16, f0
        swc1    f16, 0x0020(a0)

        _y_axis:
        lwc1    f0, 0x0024(a0)
        neg.s   f16, f0         // flip y axis
        swc1    f16, 0x0024(a0) // saved flipped y

        // revert animation
        lwc1    f12, 0x0020(a0)     // f12 = x speed
        jal     0x8001863C          // f0 = atan2f(f12, f12) = rotation angle
        lwc1    f14, 0x0024(a0)     // f14 = y speed
        lw      t1, 0x0004(a0)      // load object
        lw      t8, 0x0074(t1)      // t8 = projectile position struct
        swc1    f0, 0x0038(t8)      // update rotation angle


        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        or      v0, r0, r0
    }

    robot_bee_laser_hitbox_pointer:
    dw  0x00000000

    OS.align(16)
    robot_bee_laser_projectile_struct:
    constant BEE_LASER_ID(0x1006)
    dw 0x00000000                           // unknown, (0x02000000 Pikachu's thunderbolt)
    dw BEE_LASER_ID                         // projectile id
    dw 0x00000000                           // address of Bee Laser file
    dw 0x00000000                           // offset to hitbox
    dw 0x1C000000                           // This determines z axis rotation? (samus is 1246), (Pikachu's thunderbolt) 0x1C000000    = pikachu
    dw robot_bee_laser_main_                // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw robot_bee_laser_collision_           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw robot_bee_laser_hit_                 // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0                                    // This function runs when the projectile collides/clangs with a hitbox.
    dw robot_bee_laser_reflect_             // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0x80168964                           // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)

//    // @ Description
//    // This establishes Crateria hazard object in which Acid Rain is tied to
//    scope crateria_setup: {
//        addiu   sp, sp,-0x0060              // allocate stack space
//        sw      ra, 0x0024(sp)              // ~
//        sw      s0, 0x0028(sp)              // store ra, s0
//
//        // _check_hazard:
//        li      t0, Toggles.entry_hazard_mode
//        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
//        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
//        bnez    t0, _end                    // if hazard_mode enabled, skip original
//        nop
//
//        li      t0, 0x80131300              // load hardcoded place for stage header + 14
//        sw      r0, 0x0060(t0)              // clear timer
//        sw      r0, 0x005C(t0)              // clear timer
//        lw      t0, 0x0000(t0)              // load stage header + 14
//        lw      t1, 0x00CC(t0)              // load pointer to Acid hitbox file
//        lw      t0, 0x0080(t0)              // load pointer to Acid Graphic file
//
//
//        li      s0, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
//        sw      t0, 0x0000(s0)              // save pointer to Acid Rain Grapih file
//        sw      t1, 0x0004(s0)              // save pointer to Acid Rain hitbox file
//
//        sw      at, 0x0058(s0)              // set initial state timer to 360 frames
//
//        li      t3, acidrain_hitbox_pointer
//        sw      t1, 0x0000(t3)              // save pointer to pointer spot
//        li      t2, acidrain_projectile_struct
//        sw      t3, 0x0008(t2)              // save pointer to acid rain hitbox file
//        li      t2, acidrain_properties_struct
//        sw      t3, 0x0024(t2)              // save pointer to acid rain hitbox file
//
//        sw      s0, 0x0020(sp)              // hardcoded space used by hazards, generally for pointers
//
//
//        li      a1, acidrain_cloud_         // Acid Rain routine
//        addiu   a2, r0, 0x0001              // group
//        addiu   a0, r0, 0x03F2              // object id
//
//        jal     Render.CREATE_OBJECT_       // create object
//        lui     a3, 0x8000                  // unknown
//
//        sw      v0, 0x0050(sp)              // save object address
//
//        _end:
//        lw      ra, 0x0024(sp)              // ~
//        lw      s0, 0x0028(sp)              // load ra, s0
//        jr      ra                          // return
//        addiu   sp, sp, 0x0060              // deallocate stack space
//    }
//
//    // @ Description
//    // This routine produces rain at random intervals across the stage
//    // a0 = Acid Rain Cloud object
//    scope acidrain_cloud_: {
//        addiu   sp, sp, -0x0068
//        sw      ra, 0x0014(sp)
//        sw      a0, 0x0000(sp)
//        sw      s0, 0x0004(sp)
//
//        li      t0, 0x801313F0          // load hardcoded stage struct
//        sw      t0, 0x0050(sp)          // save hardcoded
//        lw      t6, 0x0060(t0)          // load timer
//        sw      t6, 0x0064(sp)
//        addiu   t2, t6, 0x0001          // add 1 to timer
//        sw      t2, 0x0060(t0)          // update timer
//        addiu   t1, r0, 0x0400          // rain end timer
//
//
//
//        beql    t1, t6, _end            // check if rain should end
//        sw      r0, 0x0060(t0)          // restart timer
//        addiu   t4, r0, r0
//        slti    t4, t6, 0x001E
//        bnez    t4, _end                // if not past minimum time for rain, don't rain
//        lw      t5, 0x005C(t0)          // load rain loop
//
//        addiu   t3, r0, 0x0020          // 0x20 drops per frame
//        sw      t3, 0x0018(sp)
//
//        li      t0, 0x80131460          // a0 = global ptr to camera object
//        lw      t0, 0x0000(t0)          // a0 = global camera object
//        addiu   t2, r0, 0x0002          // t2 = 2
//        sw      t2, 0x108(t0)           // set mode to 2. (default is 4)
//        addiu   at, r0, 0x001E          // timer amount for rain
//        li      t1, 0xFFFFFFFF          // t1 = white
//        beq     at, t6, _sfx
//        addiu   at, r0, 0x0020          // timer amount for rain
//        beq     at, t6, _set_color
//        addiu   at, r0, 0x001F          // timer amount for rain
//        li      t1, 0x040433FF          // t1 = dark blue
//        beq     at, t6, _set_color
//        addiu   at, r0, 0x0021          // timer amount for rain
//        beq     at, t6, _set_color
//        addiu   t2, r0, 0x0004          // set mode to 4
//        beq     r0, r0, _rain_sfx
//        sw      t2, 0x108(t0)           // set mode to 4. (default is 4)
//
//        _sfx:
//        jal     0x800269C0              // play fgm
//        addiu   a0, r0, 0x00E8          // sets the fgm id
//        li      t1, 0xFFFFFFFF          // t1 = white
//        li      t0, 0x80131460          // a0 = global ptr to camera object
//        lw      t0, 0x0000(t0)          // a0 = global camera object
//        beq     r0, r0, _play_rain
//        _set_color:
//        sw      t1, 0x010C(t0)          // t1 = overwrite global camera draw colour
//
//        _rain_sfx:
//        lw      t0, 0x0050(sp)          // load hardcoded stage struct
//        lw      t5, 0x005C(t0)          // load rain time
//        addiu   t3, r0, 0x0060          // set to 60
//
//        beql    t5, t3, _rain_loop      // clear timer if 60 frames
//        sw      r0, 0x005C(t0)
//        addiu   t2, t5, 0x0001
//        bnez    t5, _rain_loop
//        sw      t2, 0x005C(t0)          // update timer
//
//        _play_rain:
//        jal     0x800269C0              // play fgm
//        addiu   a0, r0, 0x0400          // sets the fgm id to rain
//
//        _rain_loop:
//        jal     acidrain_stage_setting_
//        lw      a0, 0x0000(sp)          // load acid rain Object Struct
//        lw      t3, 0x0018(sp)
//        addiu   t3, t3, 0xFFFF          // subtract 1
//        bne     t3, r0, _rain_loop
//        sw      t3, 0x0018(sp)          // save updated rain amount
//
//
//        _end:
//        lw      ra, 0x0014(sp)          // load ra
//        lw      a0, 0x0000(sp)          // load great fox object
//        lw      s0, 0x0004(sp)
//        addiu   sp, sp, 0x0068
//
//        jr      ra
//        nop
//    }
//
//    // @ Description
//    // Subroutine which sets up the initial properties for the projectile.
//    scope acidrain_stage_setting_: {
//        addiu   sp, sp, -0x0050
//        sw      s0, 0x0018(sp)
//        sw      ra, 0x001C(sp)
//        sw      a0, 0x0040(sp)
//        li      s0, acidrain_properties_struct      // s0 = projectile properties struct address
//        li      a1, acidrain_projectile_struct      // a1 = main projectile struct address
//        addiu   a3, r0, 0x0001                      // I believe this makes the projectile hit all players
//
//        jal     Global.get_random_int_              // get random integer
//        addiu   a0, r0, 0x1F40                      // decimal 8000 possible spawn points
//        addiu   t1, r0, -4000                       // load -4000
//        addu    t1, v0, t1                          // subtract 4000 to center
//        mtc1    t1, f2
//        cvt.s.w f2
//        swc1    f2, 0x0020(sp)                      // save acid rain x spawn point
//        li      t1, 0x45bb8000                      // load 6000 for y spawn point
//        sw      t1, 0x0024(sp)                      // save acid rain y spawn position
//        sw      r0, 0x0028(sp)                      // save acid rain z spawn position
//        addiu   a2, sp, 0x0020                      // a2 = coordinates to create projectile at
//        jal     0x801655C8                          // This is a generic routine that does much of the work for defining all projectiles
//        sw      a2, 0x0030(sp)                      // save spawn address
//
//        bnez    v0, _destroyed_projectile_check_branch
//        or      v1, v0, r0
//        beq     r0, r0, _end
//        or      v0, r0, r0
//
//        _destroyed_projectile_check_branch:
//        lw      a0, 0x0084(v1)      // item special struct loaded in
//
//        addiu   t7, r0, 0x0028      // load in duration
//        sw      t7, 0x0268(a0)      // save duration
//
//        _x_speed:
//        sw      r0, 0x0020(a0)      // save x speed
//        lui     at, 0xc2c8
//        sw      at, 0x0024(a0)      // save y speed
//
//        lwc1    f12, 0x0020(a0)     // f12 = x speed
//        lwc1    f14, 0x0024(a0)     // f14 = y speed
//        jal     0x8001863C          // f0 = atan2f(f12, f12) = rotation angle
//        sw      v1, 0x0034(sp)
//        lw      t7, 0x0034(sp)      // t7 = projectile object
//        lw      t8, 0x0074(t7)      // t8 = projectile position struct
//        swc1    f0, 0x0038(t8)      // update rotation angle
//
//        jal     0x80103320
//        lw      a0, 0x0030(sp)
//
//        lw      v0, 0x0028(sp)
//
//
//
//        _end:
//        lw      ra, 0x001C(sp)
//        lw      s0, 0x0018(sp)
//        addiu   sp, sp, 0x0050
//        jr      ra
//        nop
//    }
//
//    // @ Description
//    // Main subroutine for the Acid Rain projectile.
//    scope acidrain_main_: {
//        _end:
//        jr      ra
//        or      v0, r0, r0
//    }
//
//    // @ Description
//    // This subroutine sets up the splash effect for the rain.
//    // a0 = projectile object
//    // a1 = projectile struct
//    scope acidrain_after_effect_: {
//        addiu   sp, sp, 0xFFE8              // allocate stack space
//        sw      ra, 0x0014(sp)              // ~
//        sw      a0, 0x0018(sp)              // store ra, a0
//
//        jal     0x801005C8                  // create explosion graphic?
//        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z
//        lw      a0, 0x0018(sp)              // a0 = projectile object
//        // copy logic from 0x80168F2C, which is used for setting up the samus bomb explosion
//        // but omit the line which originally set the hitbox size, and the jump to return address instruction
//        // TODO: this could be incorporated more naturally, and we could probably control the duration of the explosion hitbox if we wanted to
//        OS.copy_segment(0xE396C, 0x38)      // ~
//        OS.copy_segment(0xE39A8, 0x28)      // ~
//        sw      r0, 0x0290(v0)              // copy original logic
//        jal     0x800269C0                  // play fgm
//        addiu   a0, r0, 0x0000              // sets the fgm id
//        lw      ra, 0x0014(sp)              // load ra
//        addiu   sp, sp, 0x0018              // deallocate stack space
//        jr      ra                          // return
//        or      v0, r0, r0                  // v0 = 0
//    }
//
//    // @ Description
//    // This subroutine destroys the rain and creates an splash gfx
//    scope acidrain_destruction_: {
//        addiu   sp, sp,-0x0018              // allocate stack space
//        sw      ra, 0x0014(sp)              // store ra
//        lw      a0, 0x0074(a0)              // ~
//        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
//        jal     0x800FF648                  // create smoke gfx
//        lui     a1, 0x3F80                  // a1 = 1.0
//        lw      ra, 0x0014(sp)              // load ra
//        addiu   sp, sp, 0x0018              // deallocate stack space
//        jr      ra                          // return
//        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
//    }
//
//    // @ Description
//    // This subroutine destroys the rain and creates an splash gfx when colliding with clipping
//    scope acidrain_collision_: {
//        addiu   sp, sp,-0x0020              // allocate stack space
//        sw      ra, 0x0014(sp)              // store ra
//
//        jal     0x80167C04
//        sw      a0, 0x0018(sp)              // save projectile object
//
//        beq     v0, r0, _end
//        lw      t6, 0x0018(sp)              // load projectile object
//
//        lw      a0, 0x0074(t6)
//        lui     a1, 0x3F80
//
//        jal     0x800FF648
//        addiu   a0, a0, 0x001C
//
//        beq     r0, r0, _end
//        addiu   v0, r0, 0x0001
//
//        or      v0, r0, r0                  // return FALSE (prolong projectile)
//
//        _end:
//        lw      ra, 0x0014(sp)              // load ra
//        addiu   sp, sp, 0x0020              // deallocate stack space
//        jr      ra                          // return
//        nop
//    }
//
//    acidrain_hitbox_pointer:
//    dw  0x00000000
//
//    OS.align(16)
//    acidrain_projectile_struct:
//    constant ACIDRAIN_ID(0x1006)
//    dw 0x00000000                           // unknown
//    dw ACIDRAIN_ID                          // projectile id
//    dw 0x00000000                           // address of rain file
//    dw 0x00000000                           // offset to hitbox
//    dw 0x1C000000                           // This determines z axis rotation? (samus is 1246)
//    dw acidrain_main_                       // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
//    dw acidrain_collision_                  // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
//    dw acidrain_destruction_                // This function runs when the projectile collides with a hurtbox.
//    dw acidrain_destruction_                // This function runs when the projectile collides with a shield.
//    dw acidrain_destruction_                // This function runs when the projectile collides with edges of a shield and bounces off
//    dw acidrain_destruction_                // This function runs when the projectile collides/clangs with a hitbox.
//    dw acidrain_destruction_                // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
//    dw acidrain_destruction_                // This function runs when the projectile collides with Ness's psi magnet
//    OS.copy_segment(0x103904, 0x0C)         // empty
//
//    OS.align(16)
//    acidrain_properties_struct:
//    dw 999                                  // 0x0000 - duration (int)
//    float32 999                             // 0x0004 - max speed
//    float32 0                               // 0x0008 - min speed
//    float32 0                               // 0x000C - gravity
//    float32 0                               // 0x0010 - bounce multiplier
//    float32 0.1                             // 0x0014 - rotation speed
//    float32 270                             // 0x0018 - initial angle (ground)
//    float32 270                             // 0x001C   initial angle (air)
//    float32 300                             // 0x0020   initial speed
//    dw 0x00000000                           // 0x0024   projectile data pointer
//    dw 0x00000000                           // 0x0028   unknown (default 0)
//    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
//
//    // Applies damage during rain
//    // Normally an attack must have knockback in order to do damage, with the exclusion of armor, which has the unfortunate consequence of slowing the player
//    scope acidrain_damage: {
//       OS.patch_start(0x5FDD0, 0x800E45D0)
//       j        acidrain_damage
//       lw       a3, 0x000C(s4)          // original line 1, loads projectile ID
//       _return:
//       OS.patch_end()
//
//        // player struct in a0
//        addiu   a2, r0, ACIDRAIN_ID
//        bne     a2, a3, _end
//        nop
//
//        OS.save_registers()
//
//        jal     0x800EA248              // jump to damage application routine
//        addiu   a1, r0, 0x0001          // set to 1 damage per drop
//
//        OS.restore_registers()
//
//        _end:
//        j       _return
//        lw      a2, 0x0000(s2)          // original line 2
//    }

    // @ Description
    // This establishes Rainbow Road hazard object in which Chain Chomp is tied to
    scope rainbow_road_setup: {
        addiu   sp, sp,-0x0060              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // store ra, s0

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        bnez    t0, _sfx                    // if hazard_mode enabled, skip chomp
        nop

        li      t0, 0x80131300              // load hardcoded place for stage header + 14
        lw      t0, 0x0000(t0)              // load stage header + 14
        lw      t1, 0x00AC(t0)              // load pointer to Chain Chomp Hitbox file
        lw      t0, 0x0080(t0)              // load pointer to Chain Chomp file

        li      t3, chainchomp_hitbox_pointer
        sw      t1, 0x0000(t3)              // save pointer to pointer spot
        li      t2, chainchomp_projectile_struct
        sw      t3, 0x0008(t2)              // save pointer to chain chomp hitbox file
        li      t2, chainchomp_properties_struct
        sw      t3, 0x0024(t2)              // save pointer to chain chomp hitbox file

        li      s0, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      t0, 0x0000(s0)              // save pointer to chain chomp file
        sw      r0, 0x0058(s0)              // set initial state timer to 0 frames
        lui     a0, 0x0000
        lui     a1, 0x0000
        addiu   a1, a1, 0x19E8              // 0x801065E4, offset for whispy mouth, UPDATE ON REIMPORT
        addiu   a0, a0, 0x17F0              // 0x801065E8, offset for whispy mouth, UPDATE ON REIMPORT
        li      a2, 0x80104D90              // assembly routine for creating display list
        addiu   a3, r0, 0x0004

        sw      a0, 0x0028(sp)              // offset to joint struct
        sw      a1, 0x002C(sp)              // offset to model/textures
        sw      a2, 0x0030(sp)              // assembly routine for display list
        sw      a3, 0x0034(sp)
        sw      s0, 0x0020(sp)              // hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0024(s0)              // clear chomp

        li      a1, chain_chomp_main_       // Chain Chomp routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id

        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        sw      v0, 0x0058(sp)              // save object address
        sw      v0, 0x0010(s0)              // save object address to stage information struct

        lw      v0, 0x0058(sp)              // load chain chomps object
        addiu   t6, r0, 0x0001
        sw      t6, 0x007C(v0)              // make invisible

        addiu   t6, r0, 0xFFFF
        or      s0, v0, r0
        sw      t6, 0x0010(sp)
        or      a0, v0, r0
        lw      a1, 0x0030(sp)
        addiu   a2, r0, 0x0011

        jal     Render.DISPLAY_INIT_        // initliaze object for display
        lui     a3, 0x8000

        lui     t7, 0x8013
        lw      t7, 0x13F0(t7)
        lw      t8, 0x0028(sp)
        or      a0, s0, r0
        or      a2, r0, r0
        addiu   a3, r0, 0x001C
        sw      r0, 0x0010(sp)
        sw      r0, 0x0014(sp)

        jal     Render.STAGE_OBJECT_INIT_   // The routine that initializes stage objects for display
        addu    a1, t7, t8

        lw      v0, 0x002C(sp)              // load offset to model/textures of Chain Chomp
        lui     t9, 0x8013
        lw      t9, 0x13F0(t9)              // load address to Chain Chomp file
        or      a0, s0, r0

        jal     0x8000F8F4
        addu    a1, t9, v0                  // load address of Chain Chomp model/textures

        lui     a1, 0x8001
        addiu   a1, a1, 0xDF34
        or      a0, s0, r0
        addiu   a2, r0, 0x0001

        jal     Render.REGISTER_OBJECT_ROUTINE_  // The routine that adds associates a routine with an object
        addiu   a3, r0, 0x0005

        _sfx:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (movement disabled when t0 = 2 or 3)
        lli     t1, 0x0001                  // t1 = 1
        bgt     t0, t1, _end                // if movement disabled, skip sfx
        addiu   a0, r0, 0x03F2              // object id
        li      a1, sfx_main_               // SFX routine
        addiu   a2, r0, 0x0001              // group

        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // order

        _end:
        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0060              // deallocate stack space
    }

    // @ Description
    // Main function for Chain Chomp.
    scope chain_chomp_main_: {
        addiu   sp, sp, -0x0060             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      s0, 0x002C(sp)              // ~
        sw      s1, 0x0030(sp)              // store ra, a0, s0, s1
        li      s0, 0x801313F0              // s0 = stage data
        lw      s1, 0x0074(a0)              // ~

        lw      t9, 0x0058(s0)              // load timer
        addiu   t1, t9, 0x0001              // add 1 to timer
        addiu   t3, r0, 0x5DC
        slt     t2, t1, t3                  // first scene begins
        bnez    t2, _end                    // scene 1 check
        sw      t1, 0x0058(s0)              // save new time

        beql    t9, t3, _refresh_1
        sw      r0, 0x0024(s0)              // clear chomp

        _refresh_1:
        addiu   t3, t3, 0x1F4               // end scene 1 amount
        slt     t2, t3, t9                  // first scene ends

        bnez    t2, _scene2_check           // end scene 1 check
        addiu   t3, r0, 0x10A4

        lw      t7, 0x0024(s0)              // load chomp flag
        bnez    t7, _end                    // if chomp has spawn, skip
        nop

        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x032A              // decimal 810 possible integers

        addiu   t4, r0, 0x100

        bne     t4, v0, _end
        addiu   t5, r0, 0x0001

        sw      t5, 0x0024(s0)              // save chomp flag

        ori     t2, r0, 0x9518              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0
        beq     r0, r0, _animation
        ori     t3, r0, 0x9558              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0



        _scene2_check:
        beql    t9, t3, _refresh_2
        sw      r0, 0x0024(s0)              // clear chomp

        _refresh_2:
        slt     t2, t9, t3                  // second scene begins
        bnez    t2, _end                    // scene 2 check
        addiu   t3, t3, 0x1F4               // end scene 2 amount
        slt     t2, t3, t9                  // second scene ends
        bnez    t2, _scene3_check           // end scene 2 check
        addiu   t3, r0, 0x1B6C

        lw      t7, 0x0024(s0)              // load chomp flag
        bnez    t7, _end                    // if chomp has spawned, skip
        nop

        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x032A              // decimal 810 possible integers

        addiu   t4, r0, 0x100

        bne     t4, v0, _end
        addiu   t5, r0, 0x0002

        sw      t5, 0x0024(s0)              // save chomp flag

        ori     t2, r0, 0xE658              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0
        beq     r0, r0, _animation
        ori     t3, r0, 0xE6A4              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0

        _scene3_check:
        beql    t9, t3, _refresh_3
        sw      r0, 0x0024(s0)              // clear chomp

        _refresh_3:
        slt     t2, t9, t3                  // third scene begins
        bnez    t2, _end                    // scene 3 check
        addiu   t3, t3, 0x1F4               // end scene 3 amount
        slt     t2, t3, t9                  // third scene ends
        bnez    t2, _scene5_check           // end scene 3 check
        addiu   t3, r0, 0x30FC

        lw      t7, 0x0024(s0)              // load chomp flag
        bnez    t7, _end                    // if chomp has spawn, skip
        nop


        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x032A              // decimal 810 possible integers

        addiu   t4, r0, 0x100
        bne     t4, v0, _end
        addiu   t5, r0, 0x0003

        sw      t5, 0x0024(s0)              // save chomp flag

        li     t2, 0x00015AB8              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0
        li     t3, 0x00015B04              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0
        beq    r0, r0, _animation
        nop

        _scene5_check:
        beql    t9, t3, _refresh_5
        sw      r0, 0x0024(s0)              // clear chomp

        _refresh_5:
        slt     t2, t9, t3                  // fifth scene begins
        bnez    t2, _end                    // scene 5 check
        addiu   t3, t3, 0x120               // end scene 5 amount
        slt     t2, t3, t9                  // fifth scene ends
        bnez    t2, _end                    // end scene 5 check
        addiu   t3, r0, 0x30FC

        lw      t7, 0x0024(s0)              // load chomp flag
        bnez    t7, _end                    // if chomp has spawn, skip
        nop

        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x032A              //

        addiu   t4, r0, 0x100

        bne     t4, v0, _end
        addiu   t5, r0, 0x0004

        sw      t5, 0x0024(s0)              // save chomp flag
        li      t2, 0x0001EDA4              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0
        li      t3, 0x0001EDF0              // animation offset, UPDATE ON REIMPORT, whispy mouth at 801063D0


        _animation:
        lw      a0, 0x0028(sp)              // ~
        lw      t0, 0x0000(s0)              // loaded cannon file address
        addiu   a3, r0, r0                  // clear out
        addu    a1, t0, t2                  // load animation struct?
        addu    a2, t0, t3                  // load animation struct?
        jal     0x8000BED8                  // apply stage animation
        sw      r0, 0x007C(a0)              // make visible
        jal     0x8000DF34                  // apply animation part 2
        lw      a0, 0x0010(s0)              // load object address



        jal     chainchomp_hitbox_stage_setting_
        lw      a0, 0x0010(s0)              // load object address

        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x0401              // fgm id = 0x401 (chain chomp)

        _end:
        lw      t9, 0x0058(s0)              // load timer
        addiu   t0, r0, 0x35E8              // total duration of animations for rainbow road
        beql    t9, t0, _clear_timer        //
        sw      r0, 0x0058(s0)              // clear timer out

        _clear_timer:
        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x002C(sp)              // ~
        lw      s1, 0x0030(sp)              // load ra, s0, s1
        addiu   sp, sp, 0x0060              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for Sounds in Rainbox Road.
    scope sfx_main_: {
        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      s0, 0x002C(sp)              // ~
        sw      s1, 0x0030(sp)              // store ra, a0, s0, s1

        li      s0, 0x801313F0              // s0 = stage data
        lw      t1, 0x005C(s0)              // load sfx timer
        addiu   t2, t1, 0x0001
        addiu   t5, r0, 0x960               // first sound
        sw      t2, 0x005C(s0)              // save sfx timer
        beq     t5, t1, _sound
        addiu   a0, r0, 0x0402              // MK64 Noise

        addiu   t6, r0, 0x0004              // loop times

        _sound_2_loop:
        addiu   t5, t5, 0x003C              // new sound played every 60 frames
        beq     t1, t5, _sound
        addiu   a0, r0, 0x0403              // MK64 Noise
        bnez    t6, _sound_2_loop
        addiu   t6, t6, 0xFFFF
        addiu   t5, t5, 0x003C

        addiu   a0, r0, 0x0404              // MK64 Noise
        beql    t1, t5, _sound
        sw      r0, 0x005C(s0)

        beq     r0, r0, _end
        nop

        _sound:
        jal     0x800269C0                  // play fgm
        nop

        _end:
        lw      ra, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        lw      s0, 0x002C(sp)              // ~
        lw      s1, 0x0030(sp)              // load ra, s0, s1
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    scope chainchomp_hitbox_stage_setting_: {
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        sw      ra, 0x001C(sp)
        sw      a0, 0x0040(sp)
        li      s0, chainchomp_properties_struct    // s0 = projectile properties struct address
        li      a1, chainchomp_projectile_struct    // a1 = main projectile struct address
        addiu   a3, r0, 0x0001                      // I believe this makes the projectile hit all players

        li      t0, 0x801313F0                      // load hardcoded space used by hazards, generally for pointers
        lw      t1, 0x0010(t0)                      // load chain chomp object
        lw      t2, 0x0074(t1)                      // load top joint

        lw      t3, 0x001C(t2)
        sw      t3, 0x0020(sp)                      // save hitbox x spawn point

        lw      t3, 0x0020(t2)
        sw      t3, 0x0024(sp)                      // save hitbox y spawn position

        lw      t3, 0x0024(t2)
        sw      r0, 0x0028(sp)                      // save hitbox z spawn position


        addiu   a2, sp, 0x0020                      // a2 = coordinates to create projectile at
        jal     0x801655C8                          // This is a generic routine that does much of the work for defining all projectiles
        sw      a2, 0x0030(sp)                      // save spawn address

        bnez    v0, _destroyed_projectile_check_branch
        or      v1, v0, r0
        beq     r0, r0, _end
        or      v0, r0, r0

        _destroyed_projectile_check_branch:
        lw      a0, 0x0084(v1)      // projectile struct loaded in

        // Camera tracking in case we want it. Looks jank in certain situations
        // addiu   at, r0, 0x0080      // at = bit flag for camera tracking
        // sb      at, 0x026C(a0)      // influence camera flag = true
        addiu   at, r0, 0x0008      // at = bit flag for reflectability (Similar to Samus mine or Pikas thunder)
        sb      at, 0x0148(a0)      // save projectile reflectability (if type != custom)
        addiu   t7, r0, 0x0546      // load in duration
        sw      t7, 0x0268(a0)      // save duration
        sw      r0, 0x029C(a0)      // clear free space
        li      t7, 0x801313F0
        sw      a0, 0x0014(t7)      // save projectile to hardcoded stage struct

        addiu   t7, r0, 0x0019      // 25 damage
        sw      t7, 0x0104(a0)
        lw      v0, 0x0028(sp)

        _end:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop
    }

    // @ Description
    // Main subroutine for the Chain Chomp Hitbox.
    scope chainchomp_hitbox_main_: {
        // a0 = projectile object
        // a2 = active projective struct
        addiu   sp, sp,-0x0010      // allocate stack space
        sw      ra, 0x0004(sp)
        li      t7, 0x801313F0      // load hardcoded stage struct
        lw      t8, 0x0010(t7)      // load chain chomp object
        sw      t8, 0x0008(sp)
        sw      a2, 0x000C(sp)
        lw      t6, 0x0074(t8)      // load position struct/top joint
        lw      t0, 0x001C(t6)      // load x position
        lw      t1, 0x0020(t6)      // load y position
        lw      t2, 0x0024(t6)      // load z position
        lw      t3, 0x0074(a0)      // load projectile top joint
        sw      t0, 0x001C(t3)      // load x position
        sw      t1, 0x0020(t3)      // load y position
        sw      t2, 0x0024(t3)      // load z position

        addiu   t5, a2, 0x214       // hitbox area address
        addiu   t7, a2, 0x029C      // hitbox counters address
        addiu   t6, r0, 0x0003      // loops

        _loop:
        lbu     t4, 0x0000(t7)      // hitbox counter
        beqzl   t4, _next           // clear hitbox if counter is done
        sw      r0, 0x0000(t5)
        addiu   t4, t4, 0xFFFF
        sb      t4, 0x0000(t7)      // update counter amount

        _next:
        addiu   t6, t6, 0xFFFF      // update loop
        addiu   t5, t5, 0x8         // update hitbox area
        bnez    t6, _loop
        addiu   t7, t7, 0x1         // update counter address

        lbu     t5, 0x000E(a0)      // load frame count
        slti    t7, t5, 0x000F
        beqz    t7, _duration
        nop

        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x0050          // decimal 80 possible integers

        addiu   t7, r0, 0x0002          // magic number

        bne     v0, t7, _duration
        nop

        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x0401          // fgm id = 0x401 (chain chomp)

        _duration:
        lw      t8, 0x000C(sp)
        lw      t7, 0x0268(t8)          // load duration
        beqzl   t7, _end
        ori     v0, r0, 0x0001          // destroy
        or      v0, r0, r0              // continue
        addiu   t7, t7, 0xFFFF
        sw      t7, 0x0268(t8)          // save updated duration
        _end:
        lw      ra, 0x0004(sp)
        addiu   sp, sp,0x0010           // allocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Main subroutine for the Chain Chomp Hitbox.
    scope chainchomp_hitbox_connect_: {
        // a0 = projectile object
        // a2 = active projective struct
        //lw      t1, 0x0000(sp)          // load player object
        //addiu   sp, sp,-0x0010          // allocate stack space
        //sw      ra, 0x0004(sp)
        //lw      t2, 0x0084(t1)          // load player struct
        //lbu     t3, 0x000D(t2)          // load port
        //addiu   t3, t3, 0xFFFF          // subtract 1 to get true port
        //lw      t5, 0x0084(a0)          // load projectile struct
        //addiu   t5, t5, 0x029C          //
        //addu    t5, t5, t3              // add port
        //addiu   at, r0, 0x0019          // refresh period timer

        //sb      at, 0x0000(t5)          // save counter

        _end:
        //lw      ra, 0x0004(sp)
        //addiu   sp, sp,0x0010           // allocate stack space
        jr      ra
        addiu   v0, r0, r0
    }

    // @ Description
    // allows chain chomp hitbox to refresh by setting counter
    scope chain_chomp_projectile_counter: {
        OS.patch_start(0xE10E0, 0x801666A0)
        j       chain_chomp_projectile_counter
        addiu   t9, s2, 0x29C               // counter address
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t8, 0x0004(sp)
        sw      t6, 0x000C(sp)

        _restart:
        beql    t5, r0, _0x801666BC         // original line 1
        addiu   at, r0, 0x0020              // original line 2

        addiu   t9, t9, 0x0001              // advance to next part of counter

        addiu   v1, v1, 0x0008
        slti    at, v1, 0x0020
        bnez    at, _0x8016669C
        addiu   t0, t0, 0x0008              // advance hitbox monitor spot

        lw      t8, 0x0004(sp)
        lw      t6, 0x000C(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        j       0x801666B8
        nop

        _0x801666BC:
        lw      t8, 0x000C(s2)              // load projectile ID
        ori     t6, r0, CHAINCHOMP_ID       // place chain chomp ID in
        bne     t8, t6, _normal             // if not chain chomp don't do extra stuff
        addiu   t8, r0, 0x0019              // refresh period timer
        sb      t8, 0x0000(t9)              // save counter amount

        _normal:
        lw      t8, 0x0004(sp)
        lw      t6, 0x000C(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        j       0x801666BC
        nop

        _0x8016669C:
        lw      t8, 0x0004(sp)
        lw      t6, 0x000C(sp)
        j       _restart
        lw      t5, 0x0114(t0)
    }

    // @ Description
    // Prevents Chain Chomp Projectile From being destroyed for being past blast
    scope blast_zone_destroy_prevent: {
        OS.patch_start(0xE0E90, 0x80166450)
        j       blast_zone_destroy_prevent
        cvt.s.w f16, f10                    // original line 1
        _return:
        OS.patch_end()

        c.lt.s  f2, f16                     // original lines 2

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)
        sw      t1, 0x0008(sp)

        lw      t0, 0x000C(a2)              // load projectile ID
        ori     t1, CHAINCHOMP_ID           // place chain chomp ID in
        bne     t0, t1, _end                // go through normal checks if not chain chomp
        lw      t0, 0x0004(sp)

        lw      t1, 0x0008(sp)
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       0x80166530                  // keep projectile alive regardless
        lw      v0, 0x027C(a2)

        _end:
        lw      t1, 0x0008(sp)
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop
    }

    // @ Description
    // Adds additional sound for 1 on stoplight
    scope stoplight_1: {
        OS.patch_start(0x8DBE8, 0x801123E8)
        j       stoplight_1
        nop
        _return:
        OS.patch_end()

        jal     0x800269C0                  // original line 1
        addiu   s2, r0, 0x0006              // original line 2

        addiu   v0, r0, Stages.id.TOADSTURNPIKE
        li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID
        beq     v0, t6, _mk64
        addiu   v0, r0, Stages.id.RAINBOWROAD
        bne     v0, t6, _end
        nop

        _mk64:
        jal     0x800269C0                  // original line 1
        addiu   a0, r0, 0x0405              // original line 2


        _end:
        j       _return
        nop
    }

    // @ Description
    // Adds additional sound for 2 on stoplight
    scope stoplight_2: {
        OS.patch_start(0x8DBFC, 0x801123FC)
        j       stoplight_2
        nop
        _return:
        OS.patch_end()

        jal     0x800269C0                  // original line 1
        addiu   s2, r0, 0x0007              // original line 2

        jal     PokemonAnnouncer.opening_comment
        nop

        addiu   v0, r0, Stages.id.TOADSTURNPIKE
        li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID
        beq     v0, t6, _mk64
        addiu   v0, r0, Stages.id.RAINBOWROAD
        bne     v0, t6, _end
        nop

        _mk64:
        jal     0x800269C0                  // original line 1
        addiu   a0, r0, 0x0405              // original line 2


        _end:
        j       _return
        nop
    }

    // @ Description
    // Adds additional sound for 3 on stoplight
    scope stoplight_3: {
        OS.patch_start(0x8DC10, 0x80112410)
        j       stoplight_3
        nop
        _return:
        OS.patch_end()

        jal     0x800269C0                  // original line 1
        addiu   s2, r0, 0x0008              // original line 2

        addiu   v0, r0, Stages.id.TOADSTURNPIKE
        li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID
        beq     v0, t6, _mk64
        addiu   v0, r0, Stages.id.RAINBOWROAD
        bne     v0, t6, _end
        nop

        _mk64:
        jal     0x800269C0                  // original line 1
        addiu   a0, r0, 0x0405              // original line 2


        _end:
        j       _return
        nop
    }

    // @ Description
    // Adds additional sound for Go on stoplight
    scope stoplight_go: {
        OS.patch_start(0x8DC3C, 0x8011243C)
        j       stoplight_go
        nop
        _return:
        OS.patch_end()

        jal     0x800269C0                  // original line 1
        addiu   a0, r0, 0x01EA              // original line 2, GO FGM

        addiu   v0, r0, Stages.id.TOADSTURNPIKE
        li      t6, Global.match_info
        lw      t6, 0x0000(t6)              // t6 = match info
        lbu     t6, 0x0001(t6)              // t6 = current stage ID
        beq     v0, t6, _mk64
        addiu   v0, r0, Stages.id.RAINBOWROAD
        bne     v0, t6, _end
        nop

        _mk64:
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x0406              // MK64 Noise


        _end:
        j       _return
        nop
    }

    chainchomp_hitbox_pointer:
    dw  0x00000000

    OS.align(16)
    chainchomp_projectile_struct:
    constant CHAINCHOMP_ID(0x1007)
    dw 0x00000000                           // unknown
    dw CHAINCHOMP_ID                        // projectile id
    dw 0x00000000                           // address of chainchomphitbox file
    dw 0x00000000                           // offset to hitbox
    dw 0x1C000000                           // This determines z axis rotation? (samus is 1246)
    dw chainchomp_hitbox_main_              // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x00000000                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw chainchomp_hitbox_connect_           // This function runs when the projectile collides with a hurtbox.
    dw chainchomp_hitbox_connect_           // This function runs when the projectile collides with a shield.
    dw chainchomp_hitbox_connect_           // This function runs when the projectile collides with edges of a shield and bounces off
    dw chainchomp_hitbox_connect_           // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x00000000                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0x00000000                           // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    chainchomp_properties_struct:
    dw 999                                  // 0x0000 - duration (int)
    float32 999                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.1                             // 0x0014 - rotation speed
    float32 270                             // 0x0018 - initial angle (ground)
    float32 270                             // 0x001C   initial angle (air)
    float32 300                             // 0x0020   initial speed
    dw 0x00000000                           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

    // @ Description
    // Runs once. This routine writes toads_turnpike_setup_2 to global camera object and will run on first frame.
    scope toads_turnpike_setup: {
        addiu   sp, sp, -0x0010              // allocate
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)

        // camera object is created at this point

        li      a0, 0x80131460               // pointer to global camera object
        lw      a0, 0x0000(a0)               // a0 = global camera object
        li      a1, toads_turnpike_setup_2
        sw      a1, 0x110(a0)                // save subroutine to unused space in global camera object, the camera object will automatically execute it

        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        jr   ra
        addiu   sp, sp, 0x0010               // deallocate

    }

    // @ Description
    // Runs once. Registers turnpike lighting routine when routine registrations are allowed.
    scope toads_turnpike_setup_2: {

        OS.save_registers()

        // Check if movement disabled
        li      a0, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a0)
        addiu   a3, r0, 0x0001
        bgt     a1, a3, _end_loop                   // don't create light angle routine handler if light angle should not change
        nop

        _movement_enabled:

        Render.register_routine(toads_turnpike_main)
        // v0 = routine handler
        // we are going to save each player struct to the routine handler

        li      at, turnpike_timeline               // pointer to turnpike_timeline
        sw      at, 0x0030(v0)                      // write pointer to table
        sw      r0, 0x0034(v0)                      // initial state = 0
        sw      at, 0x0038(v0)                      // ~
        sw      r0, 0x003C(v0)                      // ~
        sw      r0, 0x0040(v0)                      // p1
        sw      r0, 0x0044(v0)                      // p2
        sw      r0, 0x0048(v0)                      // p3
        sw      r0, 0x004C(v0)                      // p4
        sw      r0, 0x0050(v0)                      // always null
        sw      r0, 0x0054(v0)                      // timer value

        li      t0, 0x800466FC                      // t0 = hard coded ptr to first player object
        lw      t0, 0x0000(t0)                      // t0 = first player object
        addiu   t1, v0, 0x0040                      // t1 = the spot we are writing override values for this player

        _loop:
        lw      t3, 0x0084(t0)                      // load players struct
        sw      t3, 0x0000(t1)                      // save players struct to routine handler

        _next:
        lw      t0, 0x0004(t0)                      // t0 = next player object
        beqz    t0, _end_loop                       // end loop if no player
        nop
        b       _loop
        addiu   t1, t1, 0x0004                      // t1 = next spot for player struct

        _end_loop:
        li      a0, 0x80131460                      // pointer to global camera object
        lw      a0, 0x0000(a0)                      // a0 = global camera object
        sw      r0, 0x110(a0)                       // prevents this routine from running next frame

        OS.restore_registers()
        jr   ra
        nop
    }

    // cycle time = 720
    // lamp 1 pass = 90
    // lamp 2 pass = 450
    turnpike_timeline:
    // back light passing
    float32 -90      		// 0x0 - starting rotation
    float32 1.0      		// 0x4 - rotation speed
    dw -1            		// 0x8 - rotation direction
    dw 180           		// 0xC - entry end time
    // hold for a moment
    float32 90       		// starting rotation
    float32 0.00     		// rotation speed
    dw -1            		// rotation direction
    dw 225           		// entry end time
    //180
    float32 90       		// starting rotation
    float32 1.25     		// rotation speed
    dw -1            		// rotation direction
    dw 360           		// entry end time
    //360 - front light passing
    float32 -90      		// starting rotation
    float32 1.0      		// rotation speed
    dw 1             		// rotation direction
    dw 540           		// entry end time

    // hold for a moment
    float32 90       		// starting rotation
    float32 0.00     		// rotation speed
    dw 1            		// rotation direction
    dw 585           		// entry end time

    //540
    float32 90       		// starting rotation
    float32 1.25     		// rotation speed
    dw 1             		// rotation direction
    dw 0             		// entry end time

    // @ Description
    // This routine works but is unfinished
    scope toads_turnpike_main: {

        constant stage_loop_point(720)

        addiu   sp, sp, -0x0020                     // allocate sp
        sw      a0, 0x0004(sp)                      // save routine handler to sp
        sw      a1, 0x0008(sp)

        // a0 = routine handler object
        // 0x30(a0) = pointer to table
        // 0x34(a0) = state
        // 0x38(a0) = pointer to current entry
        // 0x3C(a0) = float
        // 0x40(a0) = first player struct

        lw      t8, 0x0054(a0)                      // load timer
        addiu   t8, t8, 0x0001                      // increment timer

        addiu   at, r0, stage_loop_point
        beql    at, t8, _check_table                // continue if timer not maxed
        addiu   t8, r0, 0x0000                      // or reset timer then continue

        _check_table:
        sw      t8, 0x0054(a0)                      // save timer
        lw      t7, 0x0038(a0)                      // t7 = current entry in timeline
        lw      t6, 0x000C(t7)                      // load time to change state
        bne     t6, t8, _continue                   // skip if time isn't finished for this entry
        nop

        // if here, then we change the table state
        lw      t5, 0x0034(a0)                      // t5 = state
        addiu   t5, t5, 0x0001                      // increase state
        addiu   at, r0, 0x0006                      // at = max state + 1
        beql    at, t5, _apply_state                // branch if not over max state
        addiu   t5, r0, 0x0000                      // t5 = 0
        _apply_state:
        sw      t5, 0x0034(a0)                      // save state
        sll     t5, t5, 0x0004                      // t5 = table offset
        lw      t6, 0x0030(a0)                      // load timeline table pointer
        addu    t6, t6, t5                          // t6 = pointer to current entry
        sw      t6, 0x0038(a0)                      // save ptr to handler object
        sw      r0, 0x003C(a0)                      // set starting offset back to 0

        _continue:
        lw      t6, 0x0038(a0)                      // load ptr to timeline entry
        lw      t1, 0x003C(a0)                      // get starting offset
        lw      t2, 0x0008(t6)                      // get rotation direction
        addu    t1, t1, t2                          // increment it
        mtc1    t1, f4                              // move to float 4
        cvt.s.w f4, f4                              // convert int to float
        lw      at, 0x0004(t6)                      // at = rotation speed
        mtc1    at, f6                              // move to float 5
        nop
        mul.s   f4, f4, f6                          // f4 = angle offset
        lw      at, 0x0000(t6)                      // at = initial angle
        mtc1    at, f2                              // move to float 7
        sw      t1, 0x003C(a0)                      // save offset to handler
        addiu   a0, a0, 0x0040                      // a0 = first player index in routine handler
        lw      a1, 0x0000(a0)                      // a1 = first player struct

        add.s   f10, f4, f2                         // f10 = all players initial light x rotation
        lui     at, 0xBF80                          // at = -1 in float
        mtc1    at, f12                             // move to float 9
        nop

        mul.s   f14, f10, f12                        // f12 = alternate initial light x rotation
        nop

        _loop:
        lbu     t2, 0x0A88(a1)            			// get current flag
        ori     t3, t2, 0x0040            			// append light angle override flag to existing flag
        sb      t3, 0x0A88(a1)            			// add to player struct

        mul.s   f4, f4, f6                          // f4 = angle offset

        lw     t7, 0x0044(a1)                       // t7 = player facing direction
        addiu  at, r0, 0x0001                       // at = 1
        beql   at, t7, _write_light_x_rotation
        mfc1   t3, f10                              // move final angle back
        mfc1   t3, f14                              // move final angle back (+ 180 if facing other direction)

        _write_light_x_rotation:
        sw     t3, 0x0A74(a1)                       // save x angle to player light angle struct

        _write_light_y_rotation:
        lui    at, 0x41f0                           // y angle
        sw     at, 0x0A78(a1)                       // save y angle

        _next:
        addiu   a0, a0, 0x0004                      // a0 = next player index in routine handler
        lw      a1, 0x0000(a0)                      // a1 = next entry
        bnez    a1, _loop                           // loop again if there is another player
        nop

        _end_loop:
        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        jr      ra
        addiu   sp, sp, 0x0020                      // deallocate sp

    }

    // @ Description
    // This establishes car hazard object
    scope onett_setup: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address

        sw      r0, 0x0008(t1)              // clear spot used for timer

        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to Car
        addiu   t3, t3, -0x07E8             // subtract offset amount to get to top of car file
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      t3, 0x0000(t2)              // save car header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save car header address to second word of this struct, as Pirhana Plant does the same

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)
        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.Car.id             // set item id to car
        li      a2, car_coordinates         // location in which car spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        li      t0, car_honked              // t0 = address of car_honked flag
        sw      r0, 0x0000(t0)              // reset car_honked flag

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0068
        jr      ra
        nop
    }

    car_coordinates:
    dw  0x45dac000
    dw  0x44AF0000
    dw  0x44bb8000
    dw  0x00000000

    // @ Description
    // main routine for car
    scope car_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)

        sw      v1, 0x0024(sp)
        sw      a2, 0x0018(sp)              // save item special struct to stack

        li      t1, Global.current_screen   // ~
        lbu     t1, 0x0000(t1)              // t0 = screen_id
        ori     t2, r0, 0x0036              // ~
        beq     t2, t1, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0008(t5)          // load timer
        addiu   t7, t6, 0x0001          // add to timer

        li      t4, car_honked          // t4 = address of car_honked flag
        lw      at, 0x0000(t4)          // at = 1 if the car has honked, 0 otherwise
        beqz    at, _pre_honk           // branch if the car hasn't honked yet
        nop
        sw      t7, 0x0008(t5)          // save updated timer
        slti    t8, t6, 0x0023          // wait 35 frames
        beqzl   t8, _spawn              // if 35 or greater, spawn
        sw      r0, 0x0000(t4)          // reset car_honked flag
        b       _end
        nop

        _pre_honk:
        slti    t8, t6, 0x0A8C          // wait 2700 frames
        bne     t8, r0, _end            // if not 2700 or greater, skip to end, this is the initial check, car won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)          // save updated timer
        sw      t6, 0x0010(sp)          // save original timer
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x00c8          // decimal 200 possible integers
        lw      a0, 0x0020(sp)          // load registers
        addiu   t4, r0, 0x0050          // place 50 as the random number to spawn car
        beq     t4, v0, _honk           // if 50, honk and prepare to spawn car
        addiu   t4, r0, 0x0E10          // put in max time before car, 3600 frames
        lw      t6, 0x0010(sp)          // load timer from stack
        blt     t4, t6, _end            // if not same as timer, skip honk
        nop

        _honk:
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x041C          // fgm id (car honk)
        li      t4, car_honked          // t4 = address of car_honked flag
        addiu   at, r0, 0x0001          // at = 1
        sw      at, 0x0000(t4)          // car_honked flag = true
        sw      r0, 0x0008(t5)          // restart timer
        b       _end
        nop

        // car is spawned
        _spawn:
        addiu   at, r0, 0x0001
        sw      at, 0x010C(a2)          // enable hitbox
        sw      at, 0x0038(s0)          // make car visible again
        sw      r0, 0x0008(t5)          // restart timer
        lui     t6, 0xc316
        sw      t6, 0x002C(a2)          // save speed
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x0481          // fgm id (car moving)

        _end:
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        addu    v0, r0, r0
    }

    car_honked:
    dw 0

    // @ Description
    // Subroutine which sets up initial properties of klaptrap.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope car_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.Car.item_info_array
        sw      r0, 0x0040(sp)
        sw      r0, 0x0044(sp)
        sw      r0, 0x0048(sp)
        sw      r0, 0x004C(sp)
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        addiu   a3, sp, 0x0040                  // velocity settings
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, car_coordinates        // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object


        // item is created
        //sw      r0, 0x0038(v0)                  // save to object struct to make car invisible
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        lui     t2, 0x3f40
        sw      t2, 0x0040(t9)
        sw      t2, 0x0044(t9)
        sw      t2, 0x0048(t9)                  // reduce scale to 0.75

        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        lw      t4, 0x0000(a2)
        sw      t4, 0x001C(t9)                  // save initial x coordinates
        lw      t4, 0x0004(a2)
        sw      t4, 0x0020(t9)                  // set initial y
        lw      t4, 0x0008(a2)
        sw      t4, 0x0024(t9)                  // set initial z

        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag

        lui     at, 0x442F                      // 700 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0014                  // hitbox damage set to 20
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0010                  // horizontal hit
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        lui     t4, 0xc42f
        sw      t4, 0x0124(v1)                  // save to hitbox y offset
        lui      t4, 0xc496
        sw      t4, 0x0128(v1)                  // save to hitbox z offset so it can hit players
        // 0x0118 damage multiplier
        addiu   t4, r0, 0x0000                  // slash effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = normal
        addiu   t4, r0, 0x011F                  // sound effect
        sh      t4, 0x0156(v1)                  // save hitbox sound
        addiu   t4, r0, 0x0080                  // put hitbox bkb at 140
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0020                  // put hitbox kbs at 20
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, car_blast_zone_             // load car blast zone routine
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
    // this routine gets run by whenever a projectile crosses the blast zone.
    scope car_blast_zone_: {
        sw      r0, 0x010C(a2)                  // disable hitbox
        sw      r0, 0x002C(a2)                  // turn speed to 0
        lw      t9, 0x0074(a0)
        li      t1, car_coordinates
        lw      t8, 0x0000(t1)                  // load x coordinates
        sw      t8, 0x001C(t9)

        lw      t8, 0x0004(t1)                  // load y coordinates
        sw      t8, 0x0354(a2)                  // save y coordinates

        j       0x8016F8C0                      // jump to address that bomb/grenade normally goes to
        sw      r0, 0x0038(s0)                  // make car invisible
    }

    // @ Description
    // This establishes Pirate Land hazard object in which cannon is tied to
    scope great_bay_setup: {
        addiu   sp, sp,-0x0060              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // store ra, s0

        li      s0, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0060(s0)              // clear under_water flags and frenzy turns

        sw      s0, 0x0020(sp)              // hardcoded space used by hazards, generally for pointers

        li      a1, great_bay_water_        // great bay water routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id

        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        sw      v0, 0x0050(sp)              // save object address
        addiu   t6, r0, 0xFFFF
        or      s0, v0, r0
        sw      t6, 0x0010(sp)
        or      a0, v0, r0
        lw      a1, 0x0030(sp)
        addiu   a2, r0, 0x0004

        //jal     Render.DISPLAY_INIT_        // initliaze object for display
        //lui     a3, 0x8000

        lui     t7, 0x8013
        lw      t7, 0x13F0(t7)
        lw      t8, 0x0028(sp)
        or      a0, s0, r0
        or      a2, r0, r0
        addiu   a3, r0, 0x001C
        sw      r0, 0x0010(sp)
        sw      r0, 0x0014(sp)

        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0060              // deallocate stack space
    }

    // @ Description
    // Main function for Great Bay's water. Based on Pirate Land's water.
    scope great_bay_water_: {
        constant WATER_Y(0xC48D)            // current setting - float: -1128
        constant SPLASH_Y(0xC44F)           // current setting - float: -828
        constant RIGHT_X(0x4550)            // current setting - float: 3328
        constant LEFT_X(0xC580)             // current setting

        addiu   sp, sp, -0x0050             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // ~
        sw      s1, 0x002C(sp)              // store ra, s0, s1
        or      s0, r0, r0                  // current port = 0
        lli     s1, 0x0003                  // final iteration = 0x3

        _loop:
        jal     Character.port_to_struct_   // v0 = player struct for current port
        or      a0, s0, r0                  // a0 = current port
        beqz    v0, _loop_end               // skip if no struct found for current port
        nop

        // if the player is present
        sw      v0, 0x003C(sp)              // 0x003C(sp) = px struct

        lw      t6, 0x0008(v0)              // t6 = character id
        lli     at, Character.id.FOX        // at = id.FOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.JFOX       // at = id.JFOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.FALCO      // at = id.FALCO
        bne     at, t6, _check_intro        // skip action check if character != FALCO

        _fire_fox_check:
        lw      t6, 0x0024(v0)              // t6 = action id
        lli     at, Action.FOX.FireFoxAir   // same as FALCO.Action.FireBirdAir
        beq     t6, at, _loop_end           // skip if Fox/Falco are doing their up special
        nop

        _check_intro:
        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t6 = screen_id
        ori     at, r0, 0x0036              // ~
        beq     at, t6, _check_y            // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _loop_end               // skip if time elapsed = 0
        nop

        _check_y:
        lw      v0, 0x0078(v0)              // v0 = px x/y/z coordinates
        li      t8, 0x801313F0              // t8 = stage data
        addu    t8, t8, s0                  // t8 = stage data + port offset
        lwc1    f2, 0x0004(v0)              // f2 = px y position
        lui     at, WATER_Y                 // ~
        mtc1    at, f4                      // f4 = WATER_Y
        c.le.s  f2, f4                      // compare player location to beginning of water
        nop
        bc1fl   _loop_end                   // skip if player is above water...
        sb      r0, 0x005C(t8)              // ...and set px_under_water to FALSE

        lbu     t0, 0x005C(t8)              // t0 = px_under_water
        bnez    t0, _water_physics          // branch if px_under_water != FALSE
        lli     at, OS.TRUE                 // ~

        // if the player has just gone under the water
        sb      at, 0x005C(t8)              // px_under_water = TRUE
        lw      at, 0x0000(v0)              // at = px x
        sw      at, 0x0030(sp)              // 0x0030(sp) = px x
        lui     at, SPLASH_Y                // ~
        sw      at, 0x0034(sp)              // 0x0034(sp) = SPLASH_Y
        sw      r0, 0x0038(sp)              // 0x0038(sp) = 0
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0, 0x0001              // a1 = 1
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0,-0x0001              // a1 = -1
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03D1              // fgm id = 0x3D1 (Splash)

        _water_physics:
        lw      v0, 0x003C(sp)              // v0 = px struct
        lbu     at, 0x018D(v0)              // at = bit field
        andi    at, at, 0x0007              // at = bit field & mask(0b01111111), this disables the fast fall flag
        sb      at, 0x018D(v0)              // store updated bit field
        lui     at, 0xC1A0                  // ~
        mtc1    at, f2                      // f2 = -20.0
        lui     at, 0x3F70                  // ~
        mtc1    at, f4                      // f4 = 0.9375
        lui     at, 0x3F60                  // ~
        mtc1    at, f6                      // f6 = 0.875
        lwc1    f8, 0x0048(v0)              // f8 = x velocity
        lwc1    f10, 0x004C(v0)             // f10 = y velocity
        mul.s   f8, f8, f4                  // f8 = x velocity * 0.9375
        mul.s   f10, f10, f6                // f10 = y velocity * 0.875
        c.le.s  f2, f10                     // ~
        swc1    f8, 0x0048(v0)              // store updated x velocity
        bc1fl   _water_knockback            // if y velocity =< -20...
        swc1    f10, 0x004C(v0)             // ...store updated y velocity

        _water_knockback:
        lui     at, 0x3F7B                  // ~
        mtc1    at, f6                      // f6 = 0.980469
        lwc1    f8, 0x0054(v0)              // f8 = x kb velocity
        lwc1    f10, 0x0058(v0)             // f10 = y kb velocity
        mul.s   f8, f8, f6                  // f8 = x velocity * 0.980469
        mul.s   f10, f10, f6                // f10 = y velocity * 0.980469
        swc1    f8, 0x0054(v0)              // store updated kb x velocity
        swc1    f10, 0x0058(v0)             // store updated kb y velocity
        c.le.s  f2, f10                     // ~
        mul.s   f10, f10, f4                // f10 = y velocity * 0.9375
        bc1fl   _loop_end                   // if y velocity =< -20...
        swc1    f10, 0x0058(v0)             // ...store updated kb y velocity

        _loop_end:
        bne     s0, s1, _loop               // loop if final iteration has not been reached
        addiu   s0, s0, 0x0001              // iterate current port

        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // ~
        lw      s1, 0x002C(sp)              // load ra, s0, s1
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

	// @ Description
    // Sets the lighting for Draculas Castle
    scope draculas_castle_setup_: {
        addiu   sp, sp, -0x0010             // allocate sp
        sw      ra, 0x0008(sp)
        li      a0, 0xFFA8C4FF				// colour to use (kinda pink)
		jal		set_player_env_colour_
		nop
        lw      ra, 0x0008(sp)
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate sp

    }

    // @ Description
    // Sets the lighting for Grim Reapers Cavern
    scope reapers_setup_: {
        addiu   sp, sp, -0x0010             // allocate sp
        sw      ra, 0x0008(sp)
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        addiu   at, r0, 1
        beq     at, t0, _end                // skip if hazards disabled
        addiu   at, r0, 3
        beq     at, t0, _end                // skip if hazards disabled
        li      a0, 0xFF0000FF              // colour to use (red)
        jal     set_player_env_colour_
        nop
        _end:
        lw      ra, 0x0008(sp)
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate sp

    }

	// @ Description
	// Set all global player env lighting colour
	// a0 = colour to use (RRGGBBAA)
	scope set_player_env_colour_: {
		lui		v0, 0x8013
		jr		ra
		sw		a0, 0x1388(v0)				// overwrite colour
	}


    // @ Description
    // This establishes water in wave race stage
    scope twilight_city_setup: {
        addiu   sp, sp,-0x0060              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // store ra, s0

        li      s0, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0060(s0)              // clear under_water flags and frenzy turns

        sw      s0, 0x0020(sp)              // hardcoded space used by hazards, generally for pointers

        li      a1, twilight_city_water_    // water routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id

        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        sw      v0, 0x0050(sp)              // save object address
        addiu   t6, r0, 0xFFFF
        or      s0, v0, r0
        sw      t6, 0x0010(sp)
        or      a0, v0, r0
        lw      a1, 0x0030(sp)
        addiu   a2, r0, 0x0004

        //jal     Render.DISPLAY_INIT_        // initliaze object for display
        //lui     a3, 0x8000

        lui     t7, 0x8013
        lw      t7, 0x13F0(t7)
        lw      t8, 0x0028(sp)
        or      a0, s0, r0
        or      a2, r0, r0
        addiu   a3, r0, 0x001C
        sw      r0, 0x0010(sp)
        sw      r0, 0x0014(sp)

        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0060              // deallocate stack space
    }

    // @ Description
    // Main function for twilight_city_water_. Based on great bays water.
    scope twilight_city_water_: {
        constant WATER_Y(0)            // current setting - float:
        constant SPLASH_Y(0x0)           // current setting - float:
        constant RIGHT_X(0x4550)            // current setting - float: 3328
        constant LEFT_X(0xC580)             // current setting

        addiu   sp, sp, -0x0050             // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // ~
        sw      s1, 0x002C(sp)              // store ra, s0, s1
        or      s0, r0, r0                  // current port = 0
        lli     s1, 0x0003                  // final iteration = 0x3

        _loop:
        jal     Character.port_to_struct_   // v0 = player struct for current port
        or      a0, s0, r0                  // a0 = current port
        beqz    v0, _loop_end               // skip if no struct found for current port
        nop

        // if the player is present
        sw      v0, 0x003C(sp)              // 0x003C(sp) = px struct

        lw      t6, 0x0008(v0)              // t6 = character id
        lli     at, Character.id.FOX        // at = id.FOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.JFOX       // at = id.JFOX
        beq     at, t6, _fire_fox_check     // perform action check if character = FOX
        lli     at, Character.id.FALCO      // at = id.FALCO
        bne     at, t6, _check_intro        // skip action check if character != FALCO

        _fire_fox_check:
        lw      t6, 0x0024(v0)              // t6 = action id
        lli     at, Action.FOX.FireFoxAir   // same as FALCO.Action.FireBirdAir
        beq     t6, at, _loop_end           // skip if Fox/Falco are doing their up special
        nop

        _check_intro:
        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t6 = screen_id
        ori     at, r0, 0x0036              // ~
        beq     at, t6, _check_y            // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _loop_end               // skip if time elapsed = 0
        nop

        _check_y:
        lw      v0, 0x0078(v0)              // v0 = px x/y/z coordinates
        li      t8, 0x801313F0              // t8 = stage data
        addu    t8, t8, s0                  // t8 = stage data + port offset
        lwc1    f2, 0x0004(v0)              // f2 = px y position
        lui     at, WATER_Y                 // ~
        mtc1    at, f4                      // f4 = WATER_Y
        c.le.s  f2, f4                      // compare player location to beginning of water
        nop
        bc1fl   _loop_end                   // skip if player is above water...
        sb      r0, 0x005C(t8)              // ...and set px_under_water to FALSE

        lbu     t0, 0x005C(t8)              // t0 = px_under_water
        bnez    t0, _water_physics          // branch if px_under_water != FALSE
        lli     at, OS.TRUE                 // ~

        // if the player has just gone under the water
        sb      at, 0x005C(t8)              // px_under_water = TRUE
        lw      at, 0x0000(v0)              // at = px x
        sw      at, 0x0030(sp)              // 0x0030(sp) = px x
        lui     at, SPLASH_Y                // ~
        sw      at, 0x0034(sp)              // 0x0034(sp) = SPLASH_Y
        sw      r0, 0x0038(sp)              // 0x0038(sp) = 0
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0, 0x0001              // a1 = 1
        addiu   a0, sp, 0x0030              // a0 = coordinates to create gfx at
        jal     0x801001A8                  // create "splash" gfx
        addiu   a1, r0,-0x0001              // a1 = -1
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03D1              // fgm id = 0x3D1 (Splash)

        _water_physics:
        lw      v0, 0x003C(sp)              // v0 = px struct
        lbu     at, 0x018D(v0)              // at = bit field
        andi    at, at, 0x0007              // at = bit field & mask(0b01111111), this disables the fast fall flag
        sb      at, 0x018D(v0)              // store updated bit field
        lui     at, 0xC1A0                  // ~
        mtc1    at, f2                      // f2 = -20.0
        lui     at, 0x3F70                  // ~
        mtc1    at, f4                      // f4 = 0.9375
        lui     at, 0x3F60                  // ~
        mtc1    at, f6                      // f6 = 0.875
        lwc1    f8, 0x0048(v0)              // f8 = x velocity
        lwc1    f10, 0x004C(v0)             // f10 = y velocity
        mul.s   f8, f8, f4                  // f8 = x velocity * 0.9375
        mul.s   f10, f10, f6                // f10 = y velocity * 0.875
        c.le.s  f2, f10                     // ~
        swc1    f8, 0x0048(v0)              // store updated x velocity
        bc1fl   _water_knockback            // if y velocity =< -20...
        swc1    f10, 0x004C(v0)             // ...store updated y velocity

        _water_knockback:
        lui     at, 0x3F7B                  // ~
        mtc1    at, f6                      // f6 = 0.980469
        lwc1    f8, 0x0054(v0)              // f8 = x kb velocity
        lwc1    f10, 0x0058(v0)             // f10 = y kb velocity
        mul.s   f8, f8, f6                  // f8 = x velocity * 0.980469
        mul.s   f10, f10, f6                // f10 = y velocity * 0.980469
        swc1    f8, 0x0054(v0)              // store updated kb x velocity
        swc1    f10, 0x0058(v0)             // store updated kb y velocity
        c.le.s  f2, f10                     // ~
        mul.s   f10, f10, f4                // f10 = y velocity * 0.9375
        bc1fl   _loop_end                   // if y velocity =< -20...
        swc1    f10, 0x0058(v0)             // ...store updated kb y velocity

        _loop_end:
        bne     s0, s1, _loop               // loop if final iteration has not been reached
        addiu   s0, s0, 0x0001              // iterate current port

        lw      ra, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // ~
        lw      s1, 0x002C(sp)              // load ra, s0, s1
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    scope scuttle_town_setup_: {
        constant COLOR_NIGHT(0x00105000)
        constant COLOR_DAY(0x94CEFF00)
        constant COLOR_NIGHT_GLASS(0x00103800)
        constant COLOR_DAY_GLASS(0x9ACEFF00)

        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)

        OS.read_byte(Global.current_screen, t1) // t1 = screen_id
        lli     t0, Global.screen.TRAINING_MODE
        bne     t1, t0, _init_fade          // do fade when screen_id != training mode
        nop
        OS.read_word(Training.entry_bg + 0x4, t0) // t0 = 0 if normal training bg
        beqz    t0, _check_hazard          // if not showing the stage bg, skip fade
        nop

        _init_fade:
        Render.draw_rectangle(0x0, 0xD, 10, 10, 300, 220, 0x00000000, OS.TRUE)

        li      t0, scuttle_town_bg_fade_
        sw      t0, 0x0014(v0)              // set update routine
        sw      r0, 0x0050(v0)              // clear transition flag
        li      t0, COLOR_NIGHT
        sw      t0, 0x0060(v0)              // set night color
        li      t0, COLOR_DAY
        sw      t0, 0x0064(v0)              // set day color
        li      t0, COLOR_NIGHT_GLASS
        sw      t0, 0x0048(v0)              // set night color glass
        li      t0, COLOR_DAY_GLASS
        sw      t0, 0x004C(v0)              // set day color glass
        lui     t0, 0x8013
        lw      t0, 0x1300(t0)              // t0 = header struct
        lw      t1, 0x0048(t0)              // t1 = day bg image header
        lw      t2, 0x00C8(t0)              // t2 = night bg image header
        lw      t1, 0x0034(t1)              // t1 = day bg address
        lw      t2, 0x0034(t2)              // t2 = night bg address
        sw      t2, 0x0068(v0)              // save night bg address
        sw      t1, 0x006C(v0)              // save day bg address
        lui     t0, 0x8004
        lw      t0, 0x6800(t0)              // t0 = bg image object
        lw      t0, 0x0074(t0)              // t0 = bg image object position struct
        sw      t0, 0x005C(v0)              // save bg image object position struct

        _check_hazard:
        // TODO: remove when minions stop crashing
        b _end
        nop
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address


        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to Minion
        addiu   t3, t3, -0x0668             // subtract offset amount to get to top of [this would be to the top of the GFX file, need a GFX pointer here]
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0008(t2)              // clear spot used for timer
        //lw      t4, 0x0130(t1)              // load pointer to laser hitbox file
        sw      t3, 0x0000(t2)              // save Robot Bee header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save stage header address to second word of this struct, as Pirhana Plant does the same
        sw      t4, 0x000C(t2)              // save pointer to laser hitbox file

        //li      t3, robot_bee_laser_hitbox_pointer
        //sw      t4, 0x0000(t3)              // save pointer to pointer spot
        //li      t2, robot_bee_laser_projectile_struct
        //sw      t3, 0x0008(t2)              // save pointer to cannonball hitbox file

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        li      a1, minion_factory_         // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0068
    }

    scope scuttle_town_bg_fade_: {
        lw      t2, 0x0050(a0)              // t2 = transition flag
        bnez    t2, _in_transition          // if in transition, skip to that logic
        lli     t2, 0x0001                  // t2 = 1

        // If here, we are waiting for the stage palette change to start
        lui     t0, 0x8004
        lw      t0, 0x66F8(t0)              // t0 = grpup 0x2 head
        lw      t0, 0x0074(t0)              // t0 = top joint
        lw      t0, 0x0010(t0)              // t0 = 1st joint
        lw      t0, 0x0080(t0)              // t0 = part image struct
        lw      t0, 0x0088(t0)              // t0 = current palette index

        // if t0 is 1, we are transitioning to night
        // if t0 is 9, we are transitioning to day

        lui     t1, 0x3F80                  // t1 = 1 (transition to night started)
        beql    t1, t0, _start_transition   // if the first palette is displayed, start night transition
        lli     t1, 0x0000                  // t1 = 0 (offset for transition to night)
        lui     t1, 0x4110                  // t1 = 9 (transition to day started)
        beql    t1, t0, _start_transition   // if the 2nd to last palette is displayed, start night transition
        lli     t1, 0x0004                  // t1 = 4 (offset for transition to day)

        // if here, then still waiting
        b       _finish
        nop

        _start_transition:
        sw      t2, 0x0050(a0)              // set transition flag to on
        lli     t0, 0x0004                  // t0 = alpha delta
        sw      t0, 0x0054(a0)              // set alpha delta
        addiu   t0, a0, 0x0060              // t0 = color array
        addu    t0, t0, t1                  // t0 = address of color
        lw      t1, 0x0000(t0)              // t1 = transition color
        sw      t1, 0x0040(a0)              // set prim color
        lw      t1, 0x0008(t0)              // t1 = bg address
        sw      t1, 0x0058(a0)              // set bg address
        lw      t1, -0x0018(t0)             // t1 = magnifying glass color address
        sw      t1, 0x0084(a0)              // set magnifying glass color

        _in_transition:
        lw      t1, 0x0054(a0)              // t1 = alpha delta
        lbu     t0, 0x0043(a0)              // t0 = alpha
        addu    t0, t0, t1                  // t0 = updated alpha

        beqzl   t0, pc() + 8                // if just got back to 00, transition is done
        sw      r0, 0x0050(a0)              // clear transition flag

        lw      t2, 0x0040(a0)              // t2 = prim color
        addiu   t1, r0, -0x0100             // t1 = 0xFFFFFF00
        and     t2, t2, t1                  // t2 = prim color, no alpha

        lli     t1, 0x0080                  // t1 = middle alpha
        bne     t0, t1, _check_max          // if not at middle alpha, check max alpha
        lw      t1, 0x0084(a0)              // t1 = magnifying glass color

        // midway through the transition, change the magnifying glass color
        lui     t3, 0x8013
        lw      t3, 0x1300(t3)              // t3 = stage header
        b       _set_color
        sw      t1, 0x004C(t3)              // set magnifying glass color

        _check_max:
        lli     t1, 0x00FC                  // t1 = max alpha
        bne     t0, t1, _set_color          // if not at max alpha, set alpha
        addiu   t1, r0, -0x0004             // t1 = alpha delta

        sw      t1, 0x0054(a0)              // set alpha delta

        // here, need to change the bg image
        lw      t1, 0x0058(a0)              // t1 = bg address
        lw      t3, 0x005C(a0)              // t3 = bg image object position struct
        sw      t1, 0x0044(t3)              // set bg image

        _set_color:
        or      t0, t2, t0                  // t2 = prim color
        sw      t0, 0x0040(a0)              // set alpha

        _finish:
        jr      ra
        nop
    }

    minion_coordinates:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    // @ Description
    // main routine for Minions
    scope minion_factory_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t0 = screen_id
        ori     t5, r0, 0x0036              // ~
        beq     t5, t6, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0008(t5)              // load timer
        addiu   t7, t6, 0x0001              // add to timer
        addiu   at, r0, 0x0001
        slti    t8, t6, 0x05DC              // wait 1500 frames
        bne     t8, r0, _end                // if not 1500 or greater, skip animation application, this is the initial check, Minions won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)              // save updated timer
        sw      t6, 0x0010(sp)              // save original timer
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x05DC              // decimal 1500 possible integers
        lw      a0, 0x0020(sp)              // load registers
        addiu   t4, r0, 0x0050              // place 50 as the random number to spawn Minion

        // this is added to prevent spawn crash until the item object works
        //b       _end
        //nop
        //

        beq     t4, v0, _spawn              // if 50, spawn Minion
        addiu   t4, r0, 0x0BB8              // put in max time before Minion, 3000 frames
        lw      t6, 0x0010(sp)              // load timer from stack
        bne     t4, t6, _end                // if not same as timer, skip animation
        nop

        _spawn:
        sw      r0, 0x0008(t5)              // restart timer

        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.ScuttleMinion.id   // set item id to Scuttle Minion
        li      a2, minion_coordinates      // location in which minion spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        sw      a0, 0x0024(sp)
        li      t5, 0x801313F0

        //jal     Global.get_random_int_      // get random integer
        //addiu   a0, r0, 0x0002              // decimal 2 possible integers
        //sw      v0, 0x0020(t5)              // save direction ID
        //jal     Global.get_random_int_      // get random integer
        //addiu   a0, r0, 0x0002              // decimal 2 possible integers

        //sw      v0, 0x0020(t5)              // save direction ID

        lw      t1, 0x0000(t5)              // load Minion file ram address
        bnez    v0, _movement
        addiu   t2, r0, 0x0908              // load in offset of animation track 1
        //addiu   t2, r0, 0x3598              // load in offset of animation track 1

        _movement:
        // lw      a0, 0x0024(sp)
        // addiu   a2, r0, 0x0000              // clear out a2
        // lw      a0, 0x0074(a0)              // Load Top Joint
        // jal     0x8000BD1C                  // animation track 1 set up
        // addu    a1, t1, t2                  // place animation track address in a1

        // li      t5, 0x801313F0

        // lw      t3, 0x0000(t5)              // load Minion file ram address
        // addiu   t4, r0, 0x09B4              // offset to track 2
        // lw      a0, 0x0080(a0)              // unknown, probably for image swapping
        // jal     0x8000BD54                  // set up track 2
        // addu    a1, t3, t4                  // place animation track address in a1

        _end:
        lw  ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // @ Description
    // Subroutine which sets up initial properties of Minion.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope minion_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.ScuttleMinion.item_info_array
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        li      a3, minion_coordinates
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, minion_coordinates          // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object

        // item is created
        sw      r0, 0x0040(v0)                  // clear laser timer
        addiu   t1, r0, 0x0030
        sw      t1, 0x0044(v0)                  // save sfx timer so it starts with noise

        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        sw      r0, 0x0020(t9)                  // set initial y
        sw      r0, 0x001C(t9)                  // save initial x coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        sw      r0, 0x0024(t9)                  // set initial z

        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag

        lli     at, 0x0001                      // ~
        sw      at, 0x010C(v1)                  // enable hitbox

        lui     at, 0x4316                      // 150 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0005                  // hitbox damage set to 5
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0361                  // sakurai angle
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        // 0x0118 damage multiplier
        addiu   t4, r0, r0                      // punch effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = punch
        addiu   t4, r0, 0x0026                  // medium kick sound ID
        sh      t4, 0x0156(v1)                  // save hitbox sound (could also do bat ping 0x34)
        addiu   t4, r0, 0x0050                  // put hitbox bkb at 20
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0025                  // put hitbox kbs at 25
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, minion_blast_zone_          // load Minion blast zone routine
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
    // main routine for Minion
    scope minion_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0018(sp)
        //lw      t1, 0x0040(a0)          // load laser timer
        //addiu   t2, r0, 0x0100
        //slt     at, t2, t1
        //bnez    at, _duration           // if over 100 frames of don't fire
        //addiu   t2, r0, 0x0060

        //slt     at, t2, t1
        //beqz    at, _duration           // if not 60 frames of don't fire
        //lw      t1, 0x0048(a0)          // load laser repeat timer

        //addiu   t3, t1, 0x0001
        //addiu   t2, r0, REPEAT_TIMER    // timer count
        //bnel    t1, t2, _sfx_timer      // branch if duration % 0x1E != 0
        //sw      t3, 0x0048(a0)          // update laser repeat timer

        //jal     robot_bee_laser_
        //sw      r0, 0x0048(a0)

        _sfx_timer:
        //lw      a0, 0x0018(sp)
        //lw      t1, 0x0044(a0)          // load sfx timer
        //addiu   t3, t1, 0x0001          // add to timer
        //addiu   t2, r0, 0x0030          // timer count = 10
        //bnel    t1, t2, _duration       // branch if duration % 0x1E != 0
        //sw      t3, 0x0044(a0)          // save updated timer
        //
        //sw      r0, 0x0044(a0)          // clear sfx timer
        //jal     0x800269C0              // play fgm
        //addiu   a0, r0, 0x03FB          // fgm id = Shrinkray

        _duration:
        lw      a0, 0x0018(sp)
        lw      t1, 0x0040(a0)          // load laser timer
        addiu   t3, t1, 0x0001
        addiu   t2, r0, 0x0186
        slt     at, t2, t1

        beqz    at, _continue           // if not 390 frames of existence continue
        sw      t3, 0x0040(a0)          // save updated timer

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001          // set to destroy

        _continue:
        addu    v0, r0, r0

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Destruction routine for Minion
    scope minion_destroy_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03E8              // fgm id = Badnik Destroy

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001         // set to destroy

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // this routine gets run by whenever Minion crosses the blast zone.
    scope minion_blast_zone_: {
        jr      ra
        addiu   v0, r0, 0x0001      // destroys Minion when it hits the blast zone
    }

    // @ Description
    // this routine sets up hazards for Peach's Castle II, primarily Banzai Bill
        scope peach_castle_II_setup_: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t0, _end                    // if hazard_mode enabled, skip original
        nop

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address

        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to Banzai Bill
        addiu   t3, t3, -0x07E8             // subtract offset amount to get to top of Robot Bee file
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0008(t2)              // clear spot used for timer
        //lw      t4, 0x0130(t1)              // load pointer to laser hitbox file
        sw      t3, 0x0000(t2)              // save Robot Bee header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save stage header address to second word of this struct, as Pirhana Plant does the same
        sw      t4, 0x000C(t2)              // save pointer to laser hitbox file

        //li      t3, robot_bee_laser_hitbox_pointer
        //sw      t4, 0x0000(t3)              // save pointer to pointer spot
        //li      t2, robot_bee_laser_projectile_struct
        //sw      t3, 0x0008(t2)              // save pointer to cannonball hitbox file

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        li      a1, banzai_bill_factory_    // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0068
    }

    banzai_bill_coordinates:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    // @ Description
    // main routine for Banzai Bill Spawning
    scope banzai_bill_factory_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t0 = screen_id
        ori     t5, r0, 0x0036              // ~
        beq     t5, t6, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        // this is added to prevent spawn crash until the item object works
        b       _end
        nop
        //

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0008(t5)              // load timer
        addiu   t7, t6, 0x0001              // add to timer
        addiu   at, r0, 0x0001
        slti    t8, t6, 0x05DC              // wait 1500 frames
        bne     t8, r0, _end                // if not 1500 or greater, skip animation application, this is the initial check, Minions won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)              // save updated timer
        sw      t6, 0x0010(sp)              // save original timer
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x05DC              // decimal 1500 possible integers
        lw      a0, 0x0020(sp)              // load registers
        addiu   t4, r0, 0x0050              // place 50 as the random number to spawn Banzai Bill
        beq     t4, v0, _spawn              // if 50, spawn Banzai Bill
        addiu   t4, r0, 0x0BB8              // put in max time before Banzai Bill, 3000 frames
        lw      t6, 0x0010(sp)              // load timer from stack
        bne     t4, t6, _end                // if not same as timer, skip animation
        nop

        _spawn:
        sw      r0, 0x0008(t5)              // restart timer

        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.RobotBee.id        // set item id to Robot Bee
        li      a2, banzai_bill_coordinates      // location in which Banzai Bill spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        sw      a0, 0x0024(sp)
        li      t5, 0x801313F0

        //jal     Global.get_random_int_      // get random integer
        //addiu   a0, r0, 0x0002              // decimal 2 possible integers
        //sw      v0, 0x0020(t5)              // save direction ID
        //jal     Global.get_random_int_      // get random integer
        //addiu   a0, r0, 0x0002              // decimal 2 possible integers

        //sw      v0, 0x0020(t5)              // save direction ID

        lw      t1, 0x0000(t5)              // load Banzai Bill file ram address
        bnez    v0, _movement
        addiu   t2, r0, 0x0908              // load in offset of animation track 1
        //addiu   t2, r0, 0x3598              // load in offset of animation track 1

        _movement:
        lw      a0, 0x0024(sp)
        addiu   a2, r0, 0x0000              // clear out a2
        lw      a0, 0x0074(a0)              // Load Top Joint
        jal     0x8000BD1C                  // animation track 1 set up
        addu    a1, t1, t2                  // place animation track address in a1

        li      t5, 0x801313F0

        lw      t3, 0x0000(t5)              // load Banzai file ram address
        addiu   t4, r0, 0x09B4              // offset to track 2
        lw      a0, 0x0080(a0)              // unknown, probably for image swapping
        jal     0x8000BD54                  // set up track 2
        addu    a1, t3, t4                  // place animation track address in a1

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which sets up initial properties of Minion.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope banzai_bill_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.RobotBee.item_info_array
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        li      a3, banzai_bill_coordinates
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, banzai_bill_coordinates          // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object

        // item is created
        sw      r0, 0x0040(v0)                  // clear laser timer
        addiu   t1, r0, 0x0030
        sw      t1, 0x0044(v0)                  // save sfx timer so it starts with noise

        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        sw      r0, 0x0020(t9)                  // set initial y
        sw      r0, 0x001C(t9)                  // save initial x coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        sw      r0, 0x0024(t9)                  // set initial z

        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag

        lli     at, 0x0001                      // ~
        sw      at, 0x010C(v1)                  // enable hitbox

        lui     at, 0x4316                      // 150 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0005                  // hitbox damage set to 5
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0361                  // sakurai angle
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        // 0x0118 damage multiplier
        addiu   t4, r0, r0                      // punch effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = punch
        addiu   t4, r0, 0x0026                  // medium kick sound ID
        sh      t4, 0x0156(v1)                  // save hitbox sound (could also do bat ping 0x34)
        addiu   t4, r0, 0x0050                  // put hitbox bkb at 20
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0025                  // put hitbox kbs at 25
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, banzai_bill_blast_zone_     // load Banzai Bill blast zone routine
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
    // main routine for Banzai Bill
    scope banzai_bill_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0018(sp)
        //lw      t1, 0x0040(a0)          // load laser timer
        //addiu   t2, r0, 0x0100
        //slt     at, t2, t1
        //bnez    at, _duration           // if over 100 frames of don't fire
        //addiu   t2, r0, 0x0060

        //slt     at, t2, t1
        //beqz    at, _duration           // if not 60 frames of don't fire
        //lw      t1, 0x0048(a0)          // load laser repeat timer

        //addiu   t3, t1, 0x0001
        //addiu   t2, r0, REPEAT_TIMER    // timer count
        //bnel    t1, t2, _sfx_timer      // branch if duration % 0x1E != 0
        //sw      t3, 0x0048(a0)          // update laser repeat timer

        //jal     robot_bee_laser_
        //sw      r0, 0x0048(a0)

        _sfx_timer:
        //lw      a0, 0x0018(sp)
        //lw      t1, 0x0044(a0)          // load sfx timer
        //addiu   t3, t1, 0x0001          // add to timer
        //addiu   t2, r0, 0x0030          // timer count = 10
        //bnel    t1, t2, _duration       // branch if duration % 0x1E != 0
        //sw      t3, 0x0044(a0)          // save updated timer
        //
        //sw      r0, 0x0044(a0)          // clear sfx timer
        //jal     0x800269C0              // play fgm
        //addiu   a0, r0, 0x03FB          // fgm id = Shrinkray

        _duration:
        lw      a0, 0x0018(sp)
        lw      t1, 0x0040(a0)          // load laser timer
        addiu   t3, t1, 0x0001
        addiu   t2, r0, 0x0186
        slt     at, t2, t1

        beqz    at, _continue           // if not 390 frames of existence continue
        sw      t3, 0x0040(a0)          // save updated timer

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001          // set to destroy

        _continue:
        addu    v0, r0, r0

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Destruction routine for Banzai Bill
    scope banzai_bill_destroy_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03E8              // fgm id = Badnik Destroy

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001         // set to destroy

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // this routine gets run by whenever Banzai Bill crosses the blast zone.
    scope banzai_bill_blast_zone_: {
        jr      ra
        addiu   v0, r0, 0x0001      // destroys Banzai Bill when it hits the blast
        }

    // @ Description
    // this routine sets up sound effects for the Boos on Big Boo's Haunt
        scope bbh_setup_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)

        li      t0, Global.current_screen   // t0 = pointer to current screen
        lbu     t0, 0x0000(t0)              // t0 = current screen_id
        lli     t1, 0x0036                  // t1 = training screen_id
        beq     t1, t0, _end                // if training, check hazard mode
        nop

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address

        addiu   t1, t1, -0x0014             // acquire address of header
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0004(t2)              // clear spot used for Boo timer
        sw      t6, 0x0010(sp)

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        li      a1, boo_sound_              // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // This code is responsible for making the Boos laugh
    // a0 =  boo laugh object
    scope boo_sound_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0014(sp)
        sw      a0, 0x0000(sp)
        sw      s0, 0x0004(sp)

        _bg_object:
        li      t0, 0x80131AD8          // load hardcoded bg object
        lw      t5, 0x0000(t0)          // load bg object flag
        bnez    t5, _end
        nop

        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x0527          // fgm id = Boo Laugh

        _end:
        lw      ra, 0x0014(sp)          // load ra
        lw      a0, 0x0000(sp)          //
        lw      s0, 0x0004(sp)
        addiu   sp, sp, 0x0020

        jr      ra
        nop
    }

    // @ Description
    // Runs once. Registers turnpike lighting routine when routine registrations are allowed.
    scope spawned_fear_acid_setup_: {
        OS.routine_begin(0x60)

        // Check if hazards disabled
        li      a0, Toggles.entry_hazard_mode
        lw      a1, 0x0004(a0)
        andi    a1, a1, 0x0001                  // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    a1, _end                        // don't register if hazards are off
        nop

        Render.register_routine(spawned_fear_acid_main_)
        // v0 = routine handler
        // we are going to save each player struct to the routine handler

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address

        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, 0x00E0(t1)              // load pointer to Cacodemon
        addiu   t3, t3, -0x7F8              // subtract offset amount to get to top of Cacodemon file (first pointer -10)
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      r0, 0x0020(t2)              // clear spot used for timer
        sw      r0, 0x001C(t2)              // clear spot used for prevent flag
        lw      t4, 0x0130(t1)              // load pointer to thunderball hitbox file
        sw      t3, 0x0000(t2)              // save Cacodemon header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save stage header address to second word of this struct, as Pirhana Plant does the same
        sw      t4, 0x0024(t2)              // save pointer to thunderball hitbox file

       li      t3, thunderball_hitbox_pointer
       sw      t4, 0x0000(t3)              // save pointer to hitbox spot
       li      t2, thunderball_projectile_struct
       sw      t3, 0x0008(t2)              // save pointer to projectile struct
       li      t2, thunderball_properties_struct
       sw      t3, 0x0024(t2)              // save pointer to cannonball hitbox file

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)

        addiu   a1, r0, r0                  // clear routine
        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown
        li      a1, cacodemon_factory_            // associated routine
        or      a0, v0, r0                  // place object address in a0
        addiu   a2, r0, 0x0001              // unknown, used by Dreamland
        jal     0x80008188                  // assigns special routines that can work correctly with player location
        addiu   a3, r0, 0x0004

        sw      r0, 0x0040(v0)                      // p1
        sw      r0, 0x0044(v0)                      // p2
        sw      r0, 0x0048(v0)                      // p3
        sw      r0, 0x004C(v0)                      // p4
        sw      r0, 0x0050(v0)                      // none
        _end:
        OS.routine_end(0x60)
    }

    // @ Description
    // This routine works but is unfinished
    scope spawned_fear_acid_main_: {

        constant ACID_DURATION(60)              // 1 second
        constant ACID_DAMAGE(3)
        constant KILL_PERCENT(666)

        addiu   sp, sp, -0x0020                     // allocate sp
        sw      a0, 0x0004(sp)                      // save routine handler to sp
        sw      a1, 0x0008(sp)

        li      at, 0x801313F8                      // load free space
        lh      t0, 0x0000(at)

        addiu   t1, t0, 1                           // to +=1
        beqz    t0, _initial
        sh      t1, 0x0000(at)                      // overwrite timer used by poison

        // a0 = routine handler object
        // 0x40(a0) = first player struct
        li      a1, Global.p_struct_head            // t0= pointer to player struct linked list
        lw      a1, 0x0000(a1)                      // a1 = first player struct

        bnezl   a1, _continue
        nop

        _initial:
        addiu   t1, a0, 0x0040                      // t1 = the spot we are writing override values for this player
        sw      r0, 0x0000(t1)                      // clear spot used for player structs
        sw      r0, 0x0004(t1)                      //
        sw      r0, 0x0008(t1)                      //
        sw      r0, 0x000C(t1)                      //

        li      t3, Global.p_struct_head            // t0= pointer to player struct linked list
        _initial_loop:
        lw      t3, 0x0000(t3)                      // load players struct
        sw      t3, 0x0000(t1)                      // save players struct to routine handler

        _initial_next:
        beqz    t3, _end_loop                       // end loop if no player
        nop
        b       _initial_loop
        addiu   t1, t1, 0x0004                      // t1 = next spot for player struct

        _continue:
        _loop:
        // first, check if grounded
        lw      t0, 0x014C(a1)                      // get kinetic state
        bnez    t0, _next                           // branch if aerial
        // check if on doom acid surface
        lb      t0, 0x00F7(a1)                      // get clipping flag
        addiu   at, r0, 0x23                        // at = doom acid clipping id
        bne     t0, at, _next                       // not acid, NEXT
        // branch to next if not poisoned
        lw      t3, 0x002C(a1)                      // t3 = current HP value
        slti    t3, t3, KILL_PERCENT                // t3 = 0 if HP is 666 or above
        bnez    t3, _poison_continue
        nop
        lw      t3, 0x05B0(a1)                      // t3 = super star counter
        bnez    t3, _next                           // skip if they have a super star
        nop
        OS.save_registers()
        sw      r0, 0x0A20(a1)                      // clear Overlay Routine
        sw      r0, 0x0A24(a1)                      // clear Overlay Routine
        sw      r0, 0x0A28(a1)                      // clear Overlay Routine
        sw      r0, 0x0A30(a1)                      // clear Overlay Flag
        sw      r0, 0x0A88(a1)                      // clear current Overlay
        jal     0x8013C1C4                          // KO this player
        lw      a0, 0x0004(a1)                      // a0 = player obj
        OS.restore_registers()
        b       _next
        nop

        _poison_continue:
        lw      at, 0x0A28(a1)                      // set player gfx routine
        bnez    at, _poison_continue_2
        li      at, GFXRoutine.DOOM_ACID
        sw      at, 0x0A28(a1)                      // set player gfx routine
        _poison_continue_2:
        li      t0, Poison.poisoned_players
        lbu     t1, 0x000D(a1)                      // t1 = player port
        sll     t1, t1, 4                           // t1 = offset to port
        addu    t0, t0, t1                          // t0 = player entry
        addiu   t2, r0, ACID_DURATION
        sw      t2, 0x0000(t0)                      // save duration
        addiu   t2, r0, ACID_DAMAGE                 // set damage
        sw      t2, 0x0004(t0)
        sw      r0, 0x0008(t0)                      // set poison type (0 = doom acid)

        _next:
        lw      a1, 0x0000(a1)                      // a1 = next entry
        bnez    a1, _loop                           // loop again if there is another player
        nop

        _end_loop:
        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        jr      ra
        addiu   sp, sp, 0x0020                      // deallocate sp

    }

    cacodemon_coordinates:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    // @ Description
    // main routine for spawning Cacodemons
    scope cacodemon_factory_: {
        addiu   sp, sp, -0x0060
        sw      ra, 0x001C(sp)

        li      t6, Global.current_screen   // ~
        lbu     t6, 0x0000(t6)              // t0 = screen_id
        ori     t5, r0, 0x0036              // ~
        beq     t5, t6, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0020(t5)              // load timer
        addiu   t7, t6, 0x0001              // add to timer
        addiu   at, r0, 0x0001
        slti    t8, t6, 0x05DC              // wait 1500 frames
        bne     t8, r0, _end                // if not 1500 or greater, skip animation application, this is the initial check, Robot Bee won't spawn until at least 484 frames
        sw      t7, 0x0020(t5)              // save updated timer
        sw      t6, 0x0010(sp)              // save original timer
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x05DC              // decimal 1500 possible integers
        lw      a0, 0x0020(sp)              // load registers
        addiu   t4, r0, 0x0050              // place 50 as the random number to spawn Cacodemon
        beq     t4, v0, _spawn              // if 50, spawn Cacodemon
        addiu   t4, r0, 0x0BB8              // put in max time before Cacodemon, 3000 frames
        lw      t6, 0x0010(sp)              // load timer from stack
        bne     t4, t6, _end                // if not same as timer, skip animation
        nop

        _spawn:
        lw      t0, 0x001C(t5)              // load cacodemon prevent flag
        bnez    t0, _end
        sw      r0, 0x0020(t5)              // restart timer
        addiu   t0, r0, 0x0001
        sw      t0, 0x001C(t5)              // set cacodemon prevent flag

        lli     a1, Item.Cacodemon.id       // set item id to Cacodemon
        li      a2, cacodemon_coordinates   // location in which Cacodemon spawns
        jal     0x8016EA78                  // spawn stage item
        addiu   a0, r0, 0x03F5              // set object ID
        sw      a0, 0x0024(sp)
        li      t5, 0x801313F0

        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x0002              // decimal 2 possible integers
        sw      v0, 0x0020(t5)              // save direction ID
        jal     Global.get_random_int_      // get random integer
        addiu   a0, r0, 0x0002              // decimal 2 possible integers

        sw      v0, 0x0020(t5)              // save direction ID

        lw      t1, 0x0000(t5)              // load Cacodemon file ram address
        bnez    v0, _movement
        addiu   t2, r0, 0x0918              // load in offset of animation track 1
        //addiu   t2, r0, 0x10C4              // load in offset of animation track 1

        _movement:
        lw      a0, 0x0024(sp)
        addiu   a2, r0, 0x0000              // clear out a2
        lw      a0, 0x0074(a0)              // Load Top Joint
        jal     0x8000BD1C                  // animation track 1 set up
        addu    a1, t1, t2                  // place animation track address in a1

        li      t5, 0x801313F0

        lw      t3, 0x0000(t5)              // load Cacodemon file ram address
        addiu   t4, r0, 0x10C4              // offset to track 2
        lw      a0, 0x0080(a0)              // unknown, probably for image swapping
        jal     0x8000BD54                  // set up track 2
        addu    a1, t3, t4                  // place animation track address in a1

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0060
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which sets up initial properties of Cacodemon.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope cacodemon_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.Cacodemon.item_info_array
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        li      a3, cacodemon_coordinates
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        li      a2, cacodemon_coordinates       // 0x003C(sp) = original x/y/z
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object


        // item is created
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        sw      r0, 0x0020(t9)                  // set initial y
        sw      r0, 0x001C(t9)                  // save initial x coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        sw      r0, 0x0024(t9)                  // set initial z

        //lbu     t9, 0x0158(v1)                  // ~
        //ori     t9, t9, 0x0010                  // ~
        sb      r0, 0x0158(v1)                  // remove clanking

        lli     at, 0x0001                      // ~
        sw      at, 0x010C(v1)                  // enable hitbox
        sw      r0, 0x01C8(v1)                  // clear free space used for projectile timer
        lui     at, 0x42fa                      // 125 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0005                  // hitbox damage set to 5
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0361                  // sakurai angle
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        // 0x0118 damage multiplier
        addiu   t4, r0, r0                      // punch effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = punch
        addiu   t4, r0, 0x0026                  // medium kick sound ID
        sh      t4, 0x0156(v1)                  // save hitbox sound (could also do bat ping 0x34)
        addiu   t4, r0, 0x0050                  // put hitbox bkb at 20
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0025                  // put hitbox kbs at 25
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, cacodemon_blast_zone_       // load Cacodemon blast zone routine
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
    // main routine for Cacodemon
    scope cacodemon_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0018(sp)
        lhu     t1, 0x01C8(a2)       // load initial timer
        addiu   t2, r0, 0x3C         // Spawn to Loop time frame
        addiu   t3, t1, 0x0001       // add to timer
        bnel    t1, t2, _end         // skip loop timer
        sh      t3, 0x01C8(a2)       // save new timer

        _second_timer:
        lhu     t1, 0x01CA(a2)       // load loop timer
        addiu   t3, t1, 0x0001       // add to timer
        sh      t3, 0x01CA(a2)       // save new timer
        addiu   t2, r0, 0x3E         // projectile first shot
        beq     t1, t2, _shoot
        addiu   t2, r0, 0x70         // projectile second shot
        beq     t1, t2, _shoot
        addiu   t2, r0, 0x106        // turn to right
        beq     t1, t2, _turn_right
        addiu   t2, r0, 0x12E        // projectile third shot
        beq     t1, t2, _shoot
        addiu   t2, r0, 0x160        // projectile fourth shot
        beq     t1, t2, _shoot
        addiu   t2, r0, 0x20C        // loop restart
        bne     t1, t2, _end
        nop

        addiu   at, r0, 0x000E
        sb      at, 0x0228(a2)                  // reset active hitbox 1
        sb      at, 0x0230(a2)                  // reset active hitbox 2
        sb      at, 0x0238(a2)                  // reset active hitbox 3
        sb      at, 0x0240(a2)                  // reset active hitbox 4
        sw      r0, 0x0224(a2)                  // reset hit object pointer 1
        sw      r0, 0x022C(a2)                  // reset hit object pointer 2
        sw      r0, 0x0234(a2)                  // reset hit object pointer 3
        sw      r0, 0x023C(a2)                  // reset hit object pointer 4
        lw      t1, 0x0074(a0)       // t1 = position struct
        OS.read_word(0x801313F0, t2) // t2 = cacodemon file address
        addiu   t2, t2, 0x06C8       // t2 = display list (facing left)
        sw      t2, 0x0050(t1)       // update display list
        b       _end
        sh      r0, 0x01CA(a2)       // clear timer

        _shoot:
        jal     cacodemon_thunderball_
        nop

        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x055D          // fgm id = Cacodemon Shoot

        _end:
        addu    v0, r0, r0           // cacodemon continues
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop

        _turn_right:
        addiu   at, r0, 0x000E
        sb      at, 0x0228(a2)                  // reset active hitbox 1
        sb      at, 0x0230(a2)                  // reset active hitbox 2
        sb      at, 0x0238(a2)                  // reset active hitbox 3
        sb      at, 0x0240(a2)                  // reset active hitbox 4
        sw      r0, 0x0224(a2)                  // reset hit object pointer 1
        sw      r0, 0x022C(a2)                  // reset hit object pointer 2
        sw      r0, 0x0234(a2)                  // reset hit object pointer 3
        sw      r0, 0x023C(a2)                  // reset hit object pointer 4
        lw      t1, 0x0074(a0)       // t1 = position struct
        OS.read_word(0x801313F0, t2) // t2 = cacodemon file address
        addiu   t2, t2, 0x3058       // t2 = display list (facing right)
        b       _end
        sw      t2, 0x0050(t1)       // update display list
    }

    // @ Description
    // Destruction routine for Cacodemon
    scope cacodemon_destroy_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)

        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x055E          // fgm id = Cacodemon Death
        addiu   v0, r0, 0x0001          // set to destroy

        li      t5, 0x801313F0          // load stage space address
        sw      r0, 0x001C(t5)

        _end:
        lw  ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // this routine gets run by whenever Cacodemon crosses the blast zone.
    scope cacodemon_blast_zone_: {
        li      t5, 0x801313F0      // load stage space address
        addiu   v0, r0, 0x0001      // destroys Cacodemon when it hits the blast zone
        jr      ra
        sw      r0, 0x001C(t5)      // clear prevent flag
    }

    // @ Description
    // This sets up for stage spawning of projectile
    scope cacodemon_thunderball_: {
        addiu   sp, sp, -0x0038
        sw      ra, 0x0014(sp)      // save ra to stack
        sw      a0, 0x0020(sp)      // save object struct
        lw      v0, 0x0084(a0)      // load item special struct
        sw      v0, 0x0034(sp)      // save item special struct to stack

        lw      t0, 0x0074(a0)      // load position struct/topjoint


        lwc1    f2, 0x001C(t0)      // load x address of Cacodemon

        //mtc1    at, f4
        //add.s   f2, f2, f4
        swc1    f2, 0x0028(sp)      // save x address to stack for spawn projectile addresses

        lwc1    f2, 0x0020(t0)      // load y address of Cacodemon
        swc1    f2, 0x002C(sp)      // save y address to stack for spawn projectile addresses

        sw      r0, 0x0030(sp)      // save z address of Cacodemon for spawn projectile addresses
        jal     thunderball_stage_setting   // jump to laser stage setting
        addiu   a2, sp, 0x0028      // addresses portion of stack


        // normally saves  something to player struct in free space
        lw      ra, 0x0014(sp)      // load ra from stack
        addiu   sp, sp, 0x0038
        jr      ra
        nop
    }

    // @ Description
    // Stage spawning for initial thunderball
    scope thunderball_stage_setting: {
        addiu   sp, sp, -0x0050
        sw      a2, 0x0034(sp)      // save spawn addresses
        sw      ra, 0x0014(sp)      // save ra
        sw      s0, 0x0030(sp)      // save item object
        sw      s1, 0x0004(sp)      // save ra
        //      a0 = object struct
        li      a1, thunderball_projectile_struct
        li      s0, thunderball_properties_struct       // load blaster format address

        jal     0x801655C8          // Projectile stage settling
        addiu   a3, r0, 0x0001      // Hit all players

        bnez    v0, _destroyed_projectile_check_branch
        or      v1, v0, r0
        beq     r0, r0, _true_end
        or      v0, r0, r0

        _destroyed_projectile_check_branch:
        mtc1    r0, f4
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        sw      v1, 0x0038(sp)              // v1 = projectile struct
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration
        sw      r0, 0x029C(v1)              // clear free space used for explosion check
        lwc1    f12, 0x0018(s0)


        _trajectory:
        lw      a0, 0x0084(v0)      // projectile struct loaded in
        addiu   t7, r0, 0x0028      // load in duration
        sw      t7, 0x0268(a0)      // save duration

        li      s1, 0x800466FC              // s1 = player object head
        lw      s1, 0x0000(s1)              // s1 = first player object
        lw      s0, 0x0030(sp)              // load item object
        lw      s2, 0x0084(s0)              // s2 = Cacodemon Item struct

        _player_loop:
        beqz    s1, _player_loop_exit       // exit loop when s1 no longer holds an object pointer
        nop

        _action_check:
        lw      t0, 0x0084(s1)              // t0 = target player struct
        lw      t0, 0x0024(t0)              // t0 = target player action
        sltiu   at, t0, 0x0007              // at = 1 if action id < 7, else at = 0
        bnez    at, _player_loop_end        // skip if target action id < 7 (target is in a KO action)
        nop

        _target_check:
        or      a0, s2, r0                  // a0 = Cacodemon Item struct
        lw      a1, 0x0074(s1)              // a1 = target top joint struct
        jal     check_target_               // check_target_
        or      a2, s1, r0                  // a2 = target object struct
        beqz    v0, _player_loop_end        // branch if no new target
        nop

        // if check_target_ returned a new valid target
        sw      v0, 0x01C0(s2)              // store target object
        sw      v1, 0x01C4(s2)              // store target X_DIFF

        _player_loop_end:
        b       _player_loop                // loop
        lw      s1, 0x0004(s1)              // s1 = next object

        _player_loop_exit:
        lw      t0, 0x01C0(s2)              // t0 = target object
        bnez    t0, _target                 // end if there is a targeted object
        nop

        _default:
        lw      t8, 0x0028(sp)      // t8 = projectile object
        lw      t8, 0x0084(t8)      // t8 = projectile struct
        lui     at, 0xc2c8
        sw      at, 0x0020(t8)      // save x speed
        lui     at, 0xc2c8
        sw      at, 0x0024(t8)      // save y speed


        beq     r0, r0, _end
        lw      v0, 0x0028(sp)

        _target:
        lw      a0, 0x0030(sp)              // a0 = Cacodemon object
        lw      a0, 0x0084(a0)              // a0 = item struct
        lw      t8, 0x0074(s0)              // t8 = Cacodemon x/y/z coordinates
        addiu   t8, t8, 0x001C
        lw      t9, 0x01C0(a0)              // ~
        lw      t9, 0x0074(t9)              // ~
        addiu   t9, t9, 0x001C              // t9 = target x/y/z coordinates
        lwc1    f4, 0x0000(t8)              // f4 = cacodemon x
        lwc1    f6, 0x0000(t9)              // f6 = target x
        sub.s   f14, f6, f4                 // f14 = X_DIFF
        //mul.s   f14, f14, f10               // f14 = X_DIFF * DIRECTION
        lwc1    f4, 0x0004(t8)              // f4 = cacodemon y
        lwc1    f6, 0x0004(t9)              // f6 = target y
        sub.s   f12, f6, f4                 // f12 = Y_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop

        mov.s   f12, f0                     // f12 = DIFF_ANGLE
        jal     0x80035CD0                  // f0 = cos(f12)
        swc1    f12, 0x0040(sp)             // f12 = movement angle saved
        lui     at, 0x42a0
        mtc1    at, f4                      // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = x velocity (SPEED * cos(angle))
        swc1    f4, 0x003C(sp)              // 0x003C(sp) = x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0040(sp)             // f12 = movement angle saved
        lui     at, 0x42a0
        mtc1    at, f4                      // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = y velocity (SPEED * sin(angle))

        lw      t8, 0x0028(sp)      // t8 = projectile object
        lw      t8, 0x0084(t8)      // t8 = projectile struct
        lwc1    f2, 0x003C(sp)              // f2 = x velocity
        swc1    f2, 0x0020(t8)      // save x speed
        swc1    f4, 0x0024(t8)      // save y speed

        _end:
        lw      s0, 0x0030(sp)              // load item object
        lw      v1, 0x0038(sp)              // v1 = projectile struct
        addiu   t7, r0, r0                  // set facing to right
        lui     at, 0x8000
        mtc1    at, f18
        mtc1    r0, f12
        jal     0x800303F0                  // ~
        nop

        mtc1    r0, f18
        lw      v1, 0x0038(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        lw      t8, 0x0074(a0)              // ~
        mtc1    r0, f10                     // sets pallette index flag
        lw      t9, 0x0080(t8)              // ~
        jal     0x80167FA0                  // ~
        swc1    f10, 0x0088(t9)             // ~
        lw      v0, 0x0028(sp)              // original logic

        _true_end:
        lw      s1, 0x0004(sp)      // save s1
        lw      ra, 0x0014(sp)
        lw      s0, 0x0030(sp)      // load item object
        addiu   sp, sp, 0x0050
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which checks if a potential target is in range for Cacodemon's Thunderball.
    // a0 - item struct
    // a1 - target top joint struct
    // a2 - target object struct
    // returns
    // v0 - target object (NULL when no valid target)
    // v1 - target X_DIFF
    scope check_target_: {
        lw      t8, 0x0074(s0)              // t8 = Cacodemon x/y/z coordinates
        addiu   t8, t8, 0x001C
        addiu   t9, a1, 0x001C              // t9 = target x/y/z coordinates

        // check if the target is within x range
        mtc1    r0, f0                      // f0 = 0
        lwc1    f2, 0x0000(t8)              // f2 = Cacodemon x coordinate
        lwc1    f4, 0x0000(t9)              // f4 = target x coordinate
        sub.s   f10, f4, f2                 // f10 = X_DIFF (target x - player x)
        abs.s   f10, f10                    // absolute value
        //c.le.s  f0, f10                      // ~
        //nop                                 // ~
        //bc1fl   _end                        // end if X_DIFF =< 0
        //or      v0, r0, r0                  // return 0

        // check if there is a previous target
        lw      t0, 0x01C0(a0)              // t0 = current target
        beq     t0, r0, _check_y            // branch if there is no current target
        lwc1    f8, 0x01C4(a0)              // f8 = current target X_DIFF

        // compare X_DIFF to see if the previous target was within closer x proximity
        c.le.s  f10, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if prev X_DIFF =< current X_DIFF
        or      v0, r0, r0                  // return 0

        _check_y:
       // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
       //lwc1    f2, 0x0004(t8)              // f2 = player y coordinate
       //lwc1    f4, 0x0004(t9)              // f4 = target y coordinate
       //sub.s   f12, f4, f2                 // f12 = Y_DIFF (target y - player y)
       //abs.s   f12, f12                    // f12 = absolute Y_DIFF
       //lui     at, MIN_Y_RANGE             // at = MIN_Y_RANGE
       //ori     t6, r0, Character.id.SSONIC // t6 = id.SSONIC
       //lw      t7, 0x0008(a0)              // t7 = character id
       //beql    t7, t6, pc() + 8            // if character = SSONIC...
       //lui     at, MIN_Y_RANGE_SS          // ...use MIN_Y_RANGE_SS instead
       //mtc1    at, f8                      // f8 = MIN_Y_RANGE
       //lui     at, 0x3F00                  // ~
       //mtc1    at, f6                      // f6 = 0.5
       //mul.s   f6, f6, f10                 // f6 = X_DIFF * 0.5
       //add.s   f8, f8, f6                  // f8 = Y_RANGE (MIN_Y_RANGE + X_DIFF * 0.5)
       //c.le.s  f12, f8                     // ~
       //nop                                 // ~
       //bc1fl   _end                        // end if Y_RANGE =< Y_DIFF
       //or      v0, r0, r0                  // return 0

        // if we're here then the target is the closest within range
        or      v0, a2, r0                  // v0 = target object
        mfc1    v1, f10                     // v1 = X_DIFF

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main routine for Cacodemon Thunderball Projectile
    scope thunderball_main_: {
        // a0 = projectile object
        //lw      v0, 0x0074(a0)      // v0 = position struct

        //_end:
        //jr      ra
        //or      v0, r0, r0
        addiu   sp, sp, 0xFFE0              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        lw      a0, 0x0084(a0)              // a0 = projectile struct
        jal     0x80167FE8                  // original logic, subroutine returns 1 if projectile duration is over
        sw      a0, 0x001C(sp)              // 0x001C(sp) = projectile struct
        //beq     v0, r0, _continue           // branch if projectile duration has not ended
        //lw      a0, 0x001C(sp)              // a0 = projectile struct

        _end_duration:
        lw      t2, 0x029C(a0)              // load projectile struct free space for explosion flag
        beqz    t2, _continue
        addiu   t1, r0, 0x0010
        addiu   t3, t2, 0x0001
        bne     t1, t2, _continue
        sw      t3, 0x29C(a0)
        beq     r0, r0, _end
        lli     v0, OS.TRUE                // return TRUE (destroy)

        _continue:
        li      v0, thunderball_properties_struct   // v0 = cannonball_properties_struct
        //lw      a1, 0x000C(v0)              // a1 = gravity
        //jal     0x80168088                  // apply gravity to nut
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, thunderball_properties_struct   // at = cannonball properties struct
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }


    // @ Description
    // Collision routine for Cacodemon Thunderball
    scope thunderball_collision_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)

        jal     0x80167C04
        sw      a0, 0x0018(sp)
        beq     v0, r0, _continue
        lw      a0, 0x0018(sp)

        lw      a0, 0x0018(sp)
        lw      a0, 0x0074(a0)              // a0 = projectile joint struct
        addiu   a0, a0, 0x001C              // at = projectile x/y/z coordinates
        jal     0x800FF048                  // create small smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0

        //      if hits collision and should be destroyed
        lw      t6, 0x0018(sp)
        lw      a0, 0x0074(t6)

        beq     r0, r0, _end
        addiu   v0, r0, 0x0001      // place 1 in v0 for destruction

        _continue:
        or      v0, r0, r0          // clear v0, so projectile continues

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // @ Description
    // Hit routine for Cacodemon Thunderball
    scope thunderball_hit_: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      v0, 0x0008(sp)

        _end:
        lw      ra, 0x0014(sp)
        lw      v1, 0x0010(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        addiu   v0, r0, 0x0001          // destroy projectile
    }

    thunderball_hitbox_pointer:
    dw 0x00000000

    OS.align(16)
    thunderball_properties_struct:
    dw 999                                  // 0x0000 - duration (int)
    float32 999                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.1                             // 0x0014 - rotation speed
    float32 270                             // 0x0018 - initial angle (ground)
    float32 270                             // 0x001C   initial angle (air)
    float32 100                             // 0x0020   initial speed
    dw 0x00000000                           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

    OS.align(16)
    thunderball_projectile_struct:
    constant THUNDERBALL_ID(0x1009)
    dw 0x00000000                           // unknown, (0x02000000 Pikachu's thunderbolt)
    dw THUNDERBALL_ID                       // projectile id
    dw 0x00000000                           // address of Thunderball file
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246), (Pikachu's thunderbolt) 0x1C000000    = pikachu
    dw thunderball_main_                    // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw thunderball_collision_               // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw thunderball_hit_                     // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0                                    // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x80168748                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0x80168964                           // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)


} // __HAZARDS__
