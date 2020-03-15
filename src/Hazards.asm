// Hazards.asm [bit]
if !{defined __HAZARDS__} {
define __HAZARDS__()
print "included Hazards.asm\n"

// @ Description
// This file contains various functions for disabling stage hazards (when Stages.frozen_mode is on).

include "OS.asm"
include "Stages.asm"

scope Hazards {

    // @ Description
    // Macro for toggling various hazards
    macro hazard_toggle(function_address) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // save registers

        li      t0, Stages.frozen_mode      // t0 = address of frozen_mode
        lw      t0, 0x0000(t0)              // t0 = frozen_mode
        variable _end(pc() + 4 * 3)
        bnez    t0, _end                    // if frozen_mode enabled, skip original
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
    // Toggle for Planet Zebes acid
    scope planet_zebes_acid_: {
        OS.patch_start(0x00083C10, 0x80108410)
        jal     planet_zebes_acid_
        nop
        OS.patch_end()

        hazard_toggle(0x801082B4)
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
        
        lui     t7, 0x8013
        addiu   t7, 0x1304
        lw      t7, 0x0044(t7)
        lui     t6, 0x0005
        bne     t6, t7, _end                    // if current stage is not Congo (stage_id = 5), then always disable barrel
        nop

        hazard_toggle(0x80109E84)
        
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

        li      t0, Stages.frozen_mode      // t0 = address of frozen_mode
        lw      t0, 0x0000(t0)              // t0 = frozen_mode
        bnez    t0, _end                    // if frozen_mode enabled, skip original
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
        
        bnez    v1, _end                    // if current stage is not Peach's Castle (stage_id = 0), then always disable bumper
        nop
        hazard_toggle(0x8010B378)           // standard toggle

        _end:
        jr      ra                          // return
        nop
    }

}


} // __HAZARDS__
