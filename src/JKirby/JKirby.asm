// JKirby.asm

// This file contains file inclusions, action edits, and assembly for JKirby.

scope JKirby {
    // Insert Moveset files

    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert NEUTRAL2, "moveset/NEUTRAL2.bin"
    insert NEUTRALINF_SUB, "moveset/NEUTRALINF_SUB.bin"
    insert NEUTRALINF, "moveset/NEUTRALINF.bin"
        dw  0x5c000001; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x08000006
        dw  0x5c000002; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x0800000b
        dw  0x5c000003; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x08000010
        dw  0x5c000004; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x08000015
        dw  0x5c000005; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x94000000; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001; Moveset.GO_TO(NEUTRALINF) 
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert NEUTRAL_SPECIAL_START_THROW_DATA, "moveset/NEUTRAL_SPECIAL_START_THROW_DATA.bin"
    NEUTRAL_SPECIAL_START:; Moveset.THROW_DATA(NEUTRAL_SPECIAL_START_THROW_DATA); insert "moveset/NEUTRAL_SPECIAL_START.bin"
    insert FTHROW_IMPACT, "moveset/FTHROW_IMPACT.bin"
    insert DOWN_SPECIAL_FALL, "moveset/DOWN_SPECIAL_FALL.bin"
    insert DOWN_SPECIAL_LANDING, "moveset/DOWN_SPECIAL_LANDING.bin"
    insert DOWN_SPECIAL_FALL_OFF, "moveset/DOWN_SPECIAL_FALL_OFF.bin"
    
        

    // Modify Action Parameters              // Action              // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JKIRBY, Action.Jab2,           -1,                         NEUTRAL2,                   -1)
    Character.edit_action_parameters(JKIRBY, Action.DSmash,         -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(JKIRBY, Action.USmash,         -1,                         USMASH,                     -1)
    Character.edit_action_parameters(JKIRBY, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(JKIRBY, 0xDD,                  -1,                         NEUTRALINF,                 -1)
    Character.edit_action_parameters(JKIRBY, 0xE4,                  -1,                         FTHROW,                     -1)
    Character.edit_action_parameters(JKIRBY, 0xE6,                  -1,                         FTHROW_IMPACT,              -1)
    Character.edit_action_parameters(JKIRBY, 0x10E,                 -1,                         NEUTRAL_SPECIAL_START,      -1)
    Character.edit_action_parameters(JKIRBY, 0x117,                 -1,                         NEUTRAL_SPECIAL_START,      -1)
    Character.edit_action_parameters(JKIRBY, 0x109,                 -1,                         DOWN_SPECIAL_FALL,          -1)
    Character.edit_action_parameters(JKIRBY, 0x10A,                 -1,                         DOWN_SPECIAL_LANDING,       -1)
    Character.edit_action_parameters(JKIRBY, 0x10B,                 -1,                         DOWN_SPECIAL_FALL_OFF,      -1)
    
    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(JKIRBY, GND_NSP_Ground,     0x127,          -1,                         Kirby.GND_NSP_GROUND,       -1)
    Character.add_new_action_params(JKIRBY, GND_NSP_Air,        0x128,          -1,                         Kirby.GND_NSP_AIR,          -1)
    Character.add_new_action_params(JKIRBY, DRM_NSP_Ground,     0xE7,           -1,                         Kirby.DRM_NSP_GROUND,       -1)
    Character.add_new_action_params(JKIRBY, DRM_NSP_Air,        0xE8,           -1,                         Kirby.DRM_NSP_AIR,          -1)
    Character.add_new_action_params(JKIRBY, DSAMUS_Charge,      0xEE,           -1,                         Kirby.DSAMUS_CHARGE,        -1)
    Character.add_new_action_params(JKIRBY, YLINK_NSP_Ground,   0x11F,          -1,                         Kirby.YLINK_NSP,            -1)
    Character.add_new_action_params(JKIRBY, YLINK_NSP_Air,      0x122,          -1,                         Kirby.YLINK_NSP,            -1)
    Character.add_new_action_params(JKIRBY, LUCAS_NSP_Ground,   0xFE,           File.KIRBY_LUCAS_NSP_G,     -1,                         0x40000000)
    Character.add_new_action_params(JKIRBY, LUCAS_NSP_Air,      0xFF,           File.KIRBY_LUCAS_NSP_A,     -1,                         0x00000000)
    Character.add_new_action_params(JKIRBY, WARIO_NSP_Ground,   -1,             File.KIRBY_WARIO_NSP_G,     Kirby.WARIO_NSP_GROUND,     0)
    Character.add_new_action_params(JKIRBY, WARIO_NSP_Air,      -1,             File.KIRBY_WARIO_NSP_A,     Kirby.WARIO_NSP_AIR,        0)
    Character.add_new_action_params(JKIRBY, WARIO_NSP_Recoil,   -1,             File.KIRBY_WARIO_NSP_R,     Kirby.WARIO_NSP_RECOIL,     0)
    Character.add_new_action_params(JKIRBY, FALCO_NSP_Ground,   0xEB,           File.KIRBY_FALCO_NSP_G,     Kirby.FALCO_NSP_GROUND,     0)
    Character.add_new_action_params(JKIRBY, FALCO_NSP_Air,      0xEC,           File.KIRBY_FALCO_NSP_A,     Kirby.FALCO_NSP_AIR,        0)
    Character.add_new_action_params(JKIRBY, BOWSER_NSP_Ground,  0x129,          File.KIRBY_BOWSER_NSP,      Kirby.BOWSER_NSP,           0x1D000000)
    Character.add_new_action_params(JKIRBY, BOWSER_NSP_Air,     0x12C,          File.KIRBY_BOWSER_NSP,      Kirby.BOWSER_NSP,           0x1D000000)
    Character.add_new_action_params(JKIRBY, PIANO_NSP_Ground,   0xE7,           File.KIRBY_PIANO_NSP_G,     Kirby.PIANO_NSP,            0x1C000000)
    Character.add_new_action_params(JKIRBY, PIANO_NSP_Air,      0xE8,           File.KIRBY_PIANO_NSP_A,     Kirby.PIANO_NSP,            0x1C000000)
    Character.add_new_action_params(JKIRBY, WOLF_NSP_Ground,    0xE7,           File.KIRBY_WOLF_NSP_G,      Kirby.WOLF_NSP_GROUND,      -1)
    Character.add_new_action_params(JKIRBY, WOLF_NSP_Air,       0xE8,           File.KIRBY_WOLF_NSP_A,      Kirby.WOLF_NSP_AIR,         -1)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Ground_Begin, -1,        File.KIRBY_CONKER_NSPG_BEGIN, Kirby.CONKER_NSP_BEGIN,    0)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Ground_Wait,  -1,        File.KIRBY_CONKER_NSPG_WAIT,  Kirby.CONKER_NSP_WAIT,     0)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Ground_End,   -1,        File.KIRBY_CONKER_NSPG_END,   Kirby.CONKER_NSP_END,      0)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Air_Begin,    -1,        File.KIRBY_CONKER_NSPA_BEGIN, Kirby.CONKER_NSP_BEGIN,    0)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Air_Wait,     -1,        File.KIRBY_CONKER_NSPA_WAIT,  Kirby.CONKER_NSP_WAIT,     0)
    Character.add_new_action_params(JKIRBY, CONKER_NSP_Air_End,      -1,        File.KIRBY_CONKER_NSPA_END,   Kirby.CONKER_NSP_END,      0)
    

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM             // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(JKIRBY, GND_NSP_Ground,    0x127,          ActionParams.GND_NSP_Ground,        -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, GND_NSP_Air,       0x128,          ActionParams.GND_NSP_Air,           -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, DRM_NSP_Ground,    0xE7,           ActionParams.DRM_NSP_Ground,        -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, DRM_NSP_Air,       0xE8,           ActionParams.DRM_NSP_Air,           -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, DSAMUS_Charge,     0xEE,           ActionParams.DSAMUS_Charge,         -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, YLINK_NSP_Ground,  0x11F,          ActionParams.YLINK_NSP_Ground,      -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, YLINK_NSP_Air,     0x122,          ActionParams.YLINK_NSP_Air,         -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, LUCAS_NSP_Ground,  0xFE,           ActionParams.LUCAS_NSP_Ground,      -1,             -1,                     -1,                             0x800D8CCC,                     -1)
    Character.add_new_action(JKIRBY, LUCAS_NSP_Air,     0xFF,           ActionParams.LUCAS_NSP_Air,         -1,             -1,                     LucasNSP.air_move_,             -1,                             -1)
    Character.add_new_action(JKIRBY, WARIO_NSP_Ground,  -1,             ActionParams.WARIO_NSP_Ground,      0x12,           0x800D94C4,             WarioNSP.ground_move_,          WarioNSP.ground_physics_,       WarioNSP.ground_collision_)
    Character.add_new_action(JKIRBY, WARIO_NSP_Air,     -1,             ActionParams.WARIO_NSP_Air,         0x12,           0x800D94E8,             WarioNSP.air_move_,             WarioNSP.air_physics_,          WarioNSP.air_collision_)
    Character.add_new_action(JKIRBY, WARIO_NSP_Recoil,  -1,             ActionParams.WARIO_NSP_Recoil,      0x12,           0x800D94E8,             WarioNSP.recoil_move_,          WarioNSP.recoil_physics_,       0x800DE99C)
    Character.add_new_action(JKIRBY, FALCO_NSP_Ground,  0xEB,           ActionParams.FALCO_NSP_Ground,      -1,             0x800D94C4,             Phantasm.ground_subroutine_,    -1,                             -1)
    Character.add_new_action(JKIRBY, FALCO_NSP_Air,     0xEC,           ActionParams.FALCO_NSP_Air,         -1,             0x8015C750,             Phantasm.air_subroutine_,       Phantasm.air_physics_,          Phantasm.air_collision_)
    Character.add_new_action(JKIRBY, BOWSER_NSP_Ground, 0x129,          ActionParams.BOWSER_NSP_Ground,     -1,             BowserNSP.main_,        -1,                             0x800D8BB4,                     0x800DDF44)
    Character.add_new_action(JKIRBY, BOWSER_NSP_Air,    0x12C,          ActionParams.BOWSER_NSP_Air,        -1,             BowserNSP.main_,        -1,                             0x800D91EC,                     BowserNSP.air_collision_)
    Character.add_new_action(JKIRBY, PIANO_NSP_Ground,  0xE7,           ActionParams.PIANO_NSP_Ground,      -1,             -1,                     -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, PIANO_NSP_Air,     0xE8,           ActionParams.PIANO_NSP_Air,         -1,             -1,                     -1,                             0x800D91EC,                     -1)
    Character.add_new_action(JKIRBY, WOLF_NSP_Ground,   0xEB,           ActionParams.WOLF_NSP_Ground,       -1,             WolfNSP.main,           -1,                             -1,                             -1)
    Character.add_new_action(JKIRBY, WOLF_NSP_Air,      0xEC,           ActionParams.WOLF_NSP_Air,          -1,             WolfNSP.main,           -1,                             -1,                             WolfNSP.air_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Ground_Begin, -1,       ActionParams.CONKER_NSP_Ground_Begin, 0x12,         ConkerNSP.ground_begin_main_, 0,                        0x800D8BB4,                     ConkerNSP.ground_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Ground_Wait,  -1,       ActionParams.CONKER_NSP_Ground_Wait,  0x12,         ConkerNSP.ground_wait_main_,  0,                        0x800D8BB4,                     ConkerNSP.ground_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Ground_End,   -1,       ActionParams.CONKER_NSP_Ground_End,   0x12,         ConkerNSP.end_main_,          0,                        0x800D8BB4,                     ConkerNSP.ground_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Air_Begin,    -1,       ActionParams.CONKER_NSP_Air_Begin,    0x12,         ConkerNSP.air_begin_main_,    0,                        0x800D90E0,                     ConkerNSP.air_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Air_Wait,     -1,       ActionParams.CONKER_NSP_Air_Wait,     0x12,         ConkerNSP.air_wait_main_,     0,                        0x800D90E0,                     ConkerNSP.air_collision_)
    Character.add_new_action(JKIRBY, CONKER_NSP_Air_End,      -1,       ActionParams.CONKER_NSP_Air_End,      0x12,         ConkerNSP.end_main_,          0,                        0x800D90E0,                     ConkerNSP.air_collision_end_)
    
    
}
