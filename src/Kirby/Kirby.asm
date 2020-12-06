// Kirby.asm

// This file contains file inclusions, action edits, and assembly for Kirby.

scope Kirby {
    // Insert Moveset files
    insert GND_NSP_GROUND,"moveset/GND_NSP_GROUND.bin"
    insert GND_NSP_AIR,"moveset/GND_NSP_AIR.bin"
    insert DRM_NSP_GROUND,"moveset/DRM_NSP_GROUND.bin"
    insert DRM_NSP_AIR,"moveset/DRM_NSP_AIR.bin"
    insert DSAMUS_CHARGE, "moveset/DSAMUS_CHARGE.bin"
    insert DSAMUS_CHARGELOOP, "moveset/DSAMUS_CHARGELOOP.bin"; Moveset.GO_TO(DSAMUS_CHARGELOOP) // loops
    insert YLINK_NSP,"moveset/YLINK_NSP.bin"
    insert WARIO_NSP_TRAIL,"moveset/WARIO_NSP_TRAIL.bin"
    WARIO_NSP_GROUND:; Moveset.CONCURRENT_STREAM(WARIO_NSP_TRAIL); insert "moveset/WARIO_NSP_GROUND.bin"
    WARIO_NSP_AIR:; Moveset.CONCURRENT_STREAM(WARIO_NSP_TRAIL); insert "moveset/WARIO_NSP_AIR.bin"
    insert WARIO_NSP_RECOIL,"moveset/WARIO_NSP_RECOIL.bin"
    insert FALCO_NSP_GROUND,"moveset/FALCO_NSP_GROUND.bin"
    insert FALCO_NSP_AIR,"moveset/FALCO_NSP_AIR.bin"
    insert BOWSER_NSP,"moveset/BOWSER_NSP.bin"
    insert PIANO_NSP,"moveset/PIANO_NSP.bin"

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(KIRBY,  GND_NSP_Ground,     0x127,          -1,                         GND_NSP_GROUND,             -1)
    Character.add_new_action_params(KIRBY,  GND_NSP_Air,        0x128,          -1,                         GND_NSP_AIR,                -1)
    Character.add_new_action_params(KIRBY,  DRM_NSP_Ground,     0xE7,           -1,                         DRM_NSP_GROUND,             -1)
    Character.add_new_action_params(KIRBY,  DRM_NSP_Air,        0xE8,           -1,                         DRM_NSP_AIR,                -1)
    Character.add_new_action_params(KIRBY,  DSAMUS_Charge,      0xEE,           -1,                         DSAMUS_CHARGE,              -1)
    Character.add_new_action_params(KIRBY,  YLINK_NSP_Ground,   0x11F,          -1,                         YLINK_NSP,                  -1)
    Character.add_new_action_params(KIRBY,  YLINK_NSP_Air,      0x122,          -1,                         YLINK_NSP,                  -1)
    Character.add_new_action_params(KIRBY,  LUCAS_NSP_Ground,   0xFE,           File.KIRBY_LUCAS_NSP_G,     -1,                         0x40000000)
    Character.add_new_action_params(KIRBY,  LUCAS_NSP_Air,      0xFF,           File.KIRBY_LUCAS_NSP_A,     -1,                         0x00000000)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Ground,   -1,             File.KIRBY_WARIO_NSP_G,     WARIO_NSP_GROUND,           0)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Air,      -1,             File.KIRBY_WARIO_NSP_A,     WARIO_NSP_AIR,              0)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Recoil,   -1,             File.KIRBY_WARIO_NSP_R,     WARIO_NSP_RECOIL,           0)
    Character.add_new_action_params(KIRBY,  FALCO_NSP_Ground,   0xEB,           File.KIRBY_FALCO_NSP_G,     FALCO_NSP_GROUND,           0)
    Character.add_new_action_params(KIRBY,  FALCO_NSP_Air,      0xEC,           File.KIRBY_FALCO_NSP_A,     FALCO_NSP_AIR,              0)
    Character.add_new_action_params(KIRBY,  BOWSER_NSP_Ground,  0x129,          File.KIRBY_BOWSER_NSP,      BOWSER_NSP,                 0x1D000000)
    Character.add_new_action_params(KIRBY,  BOWSER_NSP_Air,     0x12C,          File.KIRBY_BOWSER_NSP,      BOWSER_NSP,                 0x1D000000)
    Character.add_new_action_params(KIRBY,  PIANO_NSP_Ground,   0xE7,           File.KIRBY_PIANO_NSP_G,     PIANO_NSP,                  0x1C000000)
    Character.add_new_action_params(KIRBY,  PIANO_NSP_Air,      0xE8,           File.KIRBY_PIANO_NSP_A,     PIANO_NSP,                  0x1C000000)


    // Add Actions                  // Action Name      // Base Action  //Parameters                        // Staling ID   // Main ASM             // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(KIRBY, GND_NSP_Ground,     0x127,          ActionParams.GND_NSP_Ground,        -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, GND_NSP_Air,        0x128,          ActionParams.GND_NSP_Air,           -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, DRM_NSP_Ground,     0xE7,           ActionParams.DRM_NSP_Ground,        -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, DRM_NSP_Air,        0xE8,           ActionParams.DRM_NSP_Air,           -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, DSAMUS_Charge,      0xEE,           ActionParams.DSAMUS_Charge,         -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, YLINK_NSP_Ground,   0x11F,          ActionParams.YLINK_NSP_Ground,      -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, YLINK_NSP_Air,      0x122,          ActionParams.YLINK_NSP_Air,         -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, LUCAS_NSP_Ground,   0xFE,           ActionParams.LUCAS_NSP_Ground,      -1,             -1,                     -1,                             0x800D8CCC,                     -1)
    Character.add_new_action(KIRBY, LUCAS_NSP_Air,      0xFF,           ActionParams.LUCAS_NSP_Air,         -1,             -1,                     LucasNSP.air_move_,             -1,                             -1)
    Character.add_new_action(KIRBY, WARIO_NSP_Ground,   -1,             ActionParams.WARIO_NSP_Ground,      0x12,           0x800D94C4,             WarioNSP.ground_move_,          WarioNSP.ground_physics_,       WarioNSP.ground_collision_)
    Character.add_new_action(KIRBY, WARIO_NSP_Air,      -1,             ActionParams.WARIO_NSP_Air,         0x12,           0x800D94E8,             WarioNSP.air_move_,             WarioNSP.air_physics_,          WarioNSP.air_collision_)
    Character.add_new_action(KIRBY, WARIO_NSP_Recoil,   -1,             ActionParams.WARIO_NSP_Recoil,      0x12,           0x800D94E8,             WarioNSP.recoil_move_,          WarioNSP.recoil_physics_,       0x800DE99C)
    Character.add_new_action(KIRBY, FALCO_NSP_Ground,   0xEB,           ActionParams.FALCO_NSP_Ground,      -1,             0x800D94C4,             Phantasm.ground_subroutine_,    -1,                             -1)
    Character.add_new_action(KIRBY, FALCO_NSP_Air,      0xEC,           ActionParams.FALCO_NSP_Air,         -1,             0x8015C750,             Phantasm.air_subroutine_,       Phantasm.air_physics_,          Phantasm.air_collision_)
    Character.add_new_action(KIRBY, BOWSER_NSP_Ground,  0x129,          ActionParams.BOWSER_NSP_Ground,     -1,             BowserNSP.main_,        -1,                             0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(KIRBY, BOWSER_NSP_Air,     0x12C,          ActionParams.BOWSER_NSP_Air,        -1,             BowserNSP.main_,        -1,                             0x800D91EC,                     BowserNSP.air_collision_)
    Character.add_new_action(KIRBY, PIANO_NSP_Ground,   0xE7,           ActionParams.PIANO_NSP_Ground,      -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(KIRBY, PIANO_NSP_Air,      0xE8,           ActionParams.PIANO_NSP_Air,         -1,             -1,                     -1,                             0x800D91EC,                     -1)
    

    Character.table_patch_start(kirby_ground_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.air_initial_
    OS.patch_end()
    
    Character.table_patch_start(kirby_ground_nsp, Character.id.BOWSER, 0x4)
    dw      BowserNSP.ground_initial_
    OS.patch_end()
    
    Character.table_patch_start(kirby_air_nsp, Character.id.BOWSER, 0x4)
    dw      BowserNSP.air_initial_
    OS.patch_end()
    
    //TODO: maybe move this asm to the shared file?

    // @ Description
    // Macro for clone_power_action_swap_, used to fill action blocks.
    macro clone_action(original, clone) {
        lli     t7, {original}              // t7 = original action id
        beql    t7, a1, _end                // end if current action = {original}
        lli     a1, {clone}                 // a1 = {clone} if branch is taken
    }

    // @ Description
    // Patch which overrides the action ID when Kirby uses a cloned version of a copied power (Ganondorf, Dr. Mario, etc.)
    scope clone_power_action_swap_: {
        OS.patch_start(0x62734, 0x800E6F34)
        j       clone_power_action_swap_
        sw      a0, 0x0090(sp)              // original line 1
        _return:
        OS.patch_end()

        // a1 contains the action ID we are changing to
        // s1, t8, t7, t0 are all safe
        lw      s1, 0x0084(a0)              // s1 = player struct
        lw      t7, 0x0008(s1)              // t7 = character id
        lli     t8, Character.id.KIRBY      // t8 = id.KIRBY
        beq     t7, t8, _kirby              // branch if character = KIRBY
        lli     t8, Character.id.JKIRBY     // t8 = id.JKIRBY
        bne     t7, t8, _end                // skip if character != JKIRBY
        nop

        _kirby:
        // this block will determine if Kirby has copied a character with cloned actions
        lw      t7, 0x0ADC(s1)              // t7 = character id of copied power
        lli     t8, Character.id.GND        // t8 = id.GND
        beq     t7, t8, _gnd_actions        // branch if copied power = GND
        lli     t8, Character.id.DRM        // t8 = id.DRM
        beq     t7, t8, _drm_actions        // branch if copied power = DRM
        lli     t8, Character.id.JMARIO     // t8 = id.JMARIO
        beq     t7, t8, _jmario_actions     // branch if copied power = JMARIO
        lli     t8, Character.id.DSAMUS     // t8 = id.DSAMUS
        beq     t7, t8, _dsamus_actions     // branch if copied power = DSAMUS
        lli     t8, Character.id.YLINK      // t8 = id.YLINK
        beq     t7, t8, _ylink_actions      // branch if copied power = YLINK
        lli     t8, Character.id.LUCAS      // t8 = id.LUCAS
        beq     t7, t8, _lucas_actions      // branch if copied power = LUCAS
        lli     t8, Character.id.FALCO      // t8 = id.FALCO
        beq     t7, t8, _falco_actions      // branch if copied power = FALCO
        lli     t8, Character.id.PIANO      // t8 = id.PIANO
        beq     t7, t8, _piano_actions      // branch if copied power = PIANO
        nop
        // add additional clone checks here
        // if we reach this point then Kirby isn't using a cloned power
        b       _end
        nop

        _gnd_actions:
        // this block contains action swaps for Ganondorf's power
        clone_action(0x127, Action.GND_NSP_Ground)
        clone_action(0x128, Action.GND_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _drm_actions:
        // this block contains action swaps for Dr. Mario's power
        clone_action(0xE9, Action.DRM_NSP_Ground)
        clone_action(0xEA, Action.DRM_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _jmario_actions:
        // this block contains action swaps for J Mario's power
        clone_action(0xE9, 0xE7)
        clone_action(0xEA, 0xE8)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _dsamus_actions:
        // this block contains action swaps for Dark Samus's power
        clone_action(0xEE, Action.DSAMUS_Charge)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _ylink_actions:
        // this block contains action swaps for Young Link's power
        clone_action(0x11F, Action.YLINK_NSP_Ground)
        clone_action(0x122, Action.YLINK_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _lucas_actions:
        // this block contains action swaps for Lucas's power
        clone_action(0xFE, Action.LUCAS_NSP_Ground)
        clone_action(0xFF, Action.LUCAS_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop
        
        _falco_actions:
        // this block contains action swaps for Falco's power
        clone_action(0xEB, Action.FALCO_NSP_Ground)
        clone_action(0xEC, Action.FALCO_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop
        
        _piano_actions:
        // this block contains action swaps for Piano's power
        clone_action(0xE9, Action.PIANO_NSP_Ground)
        clone_action(0xEA, Action.PIANO_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _end:
        j       _return
        sw      a1, 0x0094(sp)              // original line 2
    }
}