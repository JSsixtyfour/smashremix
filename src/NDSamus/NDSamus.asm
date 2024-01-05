// NDSamus.asm

// This file contains file inclusions, action edits, and assembly for Polygon Dark Samus.

scope NDSamus {
    // Insert Moveset files
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NDSAMUS, Action.Entry,          File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(NDSAMUS, 0x006,                 File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(NDSAMUS, Action.Idle,           File.DARK_SAMUS_IDLE,       -1,                        -1)
    Character.edit_action_parameters(NDSAMUS, Action.ReviveWait,     File.DARK_SAMUS_IDLE,       -1,                        -1)
    Character.edit_action_parameters(NDSAMUS, Action.Dash,           File.DSAMUS_DASH,           -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.TurnRun,        File.DSAMUS_TURNRUN,        -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.RunBrake,       File.DSAMUS_RUNBRAKE,       -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.Walk3,          File.DSAMUS_WALK3,          -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.Run,            File.DSAMUS_RUN,            DSamus.RUN_LOOP,                   -1)
    Character.edit_action_parameters(NDSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          DSamus.ROLLF,                      -1)
    Character.edit_action_parameters(NDSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          DSamus.ROLLSUB,                    -1)
    Character.edit_action_parameters(NDSAMUS, Action.JumpF,          File.DSAMUS_JUMPF,          -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.JumpB,          File.DSAMUS_JUMPB,          -1,                         -1)
    Character.edit_action_parameters(NDSAMUS, Action.JumpAerialF,    0x8E6,                      DSamus.JUMP2,                      -1)
    Character.edit_action_parameters(NDSAMUS, Action.JumpAerialB,    0x8E7,                      DSamus.JUMP2,                      -1)
    Character.edit_action_parameters(NDSAMUS, Action.Jab1,           -1,                         DSamus.NEUTRAL1,                   -1)
    Character.edit_action_parameters(NDSAMUS, Action.DashAttack,     -1,                         DSamus.DASHATTACK,                 -1)
    Character.edit_action_parameters(NDSAMUS, Action.AttackAirN,     File.DSAMUS_NAIR,           DSamus.NAIR,                       -1)
    Character.edit_action_parameters(NDSAMUS, Action.LandingAirN,    File.DSAMUS_NAIR_LANDING,   DSamus.LANDING_NAIR,               -1)
    Character.edit_action_parameters(NDSAMUS, Action.AttackAirF,     File.DSAMUS_FAIR,           DSamus.FAIR,                       -1)
    Character.edit_action_parameters(NDSAMUS, Action.AttackAirU,     -1,                         DSamus.UAIR,                       -1)
    Character.edit_action_parameters(NDSAMUS, Action.AttackAirB,     File.DSAMUS_BAIR,           DSamus.BAIR,                       -1)
    // Character.edit_action_parameters(NDSAMUS, Action.AttackAirD,     -1,                         DSamus.DAIR,                       -1)
    Character.edit_action_parameters(NDSAMUS, Action.FTiltHigh,      -1,                         DSamus.FTILTUP,                    -1)
    Character.edit_action_parameters(NDSAMUS, Action.FTiltMidHigh,   -1,                         DSamus.FTILTMIDUP,                 -1)
    Character.edit_action_parameters(NDSAMUS, Action.FTilt,          -1,                         DSamus.FTILTMID,                   -1)
    Character.edit_action_parameters(NDSAMUS, Action.FTiltMidLow,    -1,                         DSamus.FTILTDOWN,                  -1)
    Character.edit_action_parameters(NDSAMUS, Action.FTiltLow,       -1,                         DSamus.FTILTDOWN,                  -1)
    Character.edit_action_parameters(NDSAMUS, Action.UTilt,          -1,                         DSamus.UTILT,                      -1)
    Character.edit_action_parameters(NDSAMUS, Action.DTilt,          File.DSAMUS_DTILT,          DSamus.DTILT,                      -1)
    Character.edit_action_parameters(NDSAMUS, Action.USmash,         File.DSAMUS_UPSMASH,        DSamus.USMASH,                     -1)
    Character.edit_action_parameters(NDSAMUS, Action.DSmash,         File.DSAMUS_DSMASH,         DSamus.DSMASH,                     -1)
    Character.edit_action_parameters(NDSAMUS, Action.FSmashHigh,     -1,                         DSamus.FSMASHUP,                   -1)
    Character.edit_action_parameters(NDSAMUS, Action.FSmashMidHigh,  -1,                         DSamus.FSMASHMIDUP,                -1)
    Character.edit_action_parameters(NDSAMUS, Action.FSmash,         -1,                         DSamus.FSMASHMID,                  -1)
    Character.edit_action_parameters(NDSAMUS, Action.FSmashMidLow,   -1,                         DSamus.FSMASHMIDDOWN,              -1)
    Character.edit_action_parameters(NDSAMUS, Action.FSmashLow,      -1,                         DSamus.FSMASHDOWN,                 -1)
    Character.edit_action_parameters(NDSAMUS, Action.Taunt,          File.DSAMUS_TAUNT,          DSamus.TAUNT,                      -1)
    Character.edit_action_parameters(NDSAMUS, 0xE3,                  -1,                         DSamus.UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(NDSAMUS, 0xE4,                  -1,                         DSamus.UP_SPECIAL_AIR,             -1)
    Character.edit_action_parameters(NDSAMUS, 0xDF,                  -1,                         DSamus.CHARGE,                     -1)
    Character.edit_action_parameters(NDSAMUS, 0xDC,                  File.DARK_SAMUS_IDLE,       0x80000000,                0x00000000)
    Character.edit_action_parameters(NDSAMUS, 0xDD,                  File.DARK_SAMUS_IDLE,       0x80000000,                0x00000000)

    Character.edit_action_parameters(NDSAMUS,    Action.EggLay,      File.DARK_SAMUS_IDLE,       -1,                         -1)

     // Modify Actions            // Action             // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
       Character.edit_action(NDSAMUS, 0xE4,                 -1,             -1,                         0x80160370,                     -1,                             -1)
       Character.edit_action(NDSAMUS, 0xDC,                 -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
       Character.edit_action(NDSAMUS, 0xDD,                 -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    // Modify Menu Action Parameters                // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NDSAMUS,   0x0,               File.DARK_SAMUS_IDLE,      -1,                           -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0x1,               -1,                         DSamus.VICTORY,                     -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0x2,               File.DSAMUS_VICTORY1,       DSamus.VICTORY1,                    -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0x3,               File.DSAMUS_SELECT,         DSamus.SELECT,                      -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0x4,               File.DSAMUS_SELECT,         DSamus.SELECT,                      -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0x5,               -1,                         DSamus.CLAP,                        -1)
    Character.edit_menu_action_parameters(NDSAMUS,   0xE,               File.DSAMUS_1P_CPU_POSE,    0x80000000,                  -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NDSAMUS, 0x4)
    float32 1.05
    OS.patch_end()
    
    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.NDSAMUS, 0x2)
    dh  0x0086
    OS.patch_end()

    Character.table_patch_start(variant_original, Character.id.NDSAMUS, 0x4)
    dw      Character.id.DSAMUS // set Dark Samus as original character (not Samus, who NDSAMUS is a clone of)
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NDSAMUS, 0x4)
    dw      DSamus.CPU_ATTACKS
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NDSAMUS, DSAMUS)

}
