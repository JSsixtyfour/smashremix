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
    insert WOLF_NSP_GROUND,"moveset/WOLF_NSP_GROUND.bin"
    insert WOLF_NSP_AIR,"moveset/WOLF_NSP_AIR.bin"
    insert CONKER_NSP_BEGIN,"moveset/CONKER_NSP2_BEGIN.bin"
    insert CONKER_NSP_WAIT,"moveset/CONKER_NSP2_WAIT.bin"
    insert CONKER_NSP_WAIT_LOOP,"moveset/CONKER_NSP2_WAIT_LOOP.bin"; Moveset.GO_TO(CONKER_NSP_WAIT_LOOP) // loops
    insert CONKER_NSP_END,"moveset/CONKER_NSP2_END.bin"
    insert MTWO_NSPG_BEGIN,"moveset/MTWO_NSPG_BEGIN.bin"
    insert MTWO_NSPG_CHARGE, "moveset/MTWO_NSPG_CHARGE.bin"
    insert MTWO_NSP_CHARGE_LOOP, "moveset/MTWO_NSP_CHARGE_LOOP.bin"; Moveset.GO_TO(MTWO_NSP_CHARGE_LOOP) // loops
    insert MTWO_NSPA_CHARGE, "moveset/MTWO_NSPA_CHARGE.bin"; Moveset.GO_TO(MTWO_NSP_CHARGE_LOOP) // go to loop
    insert MTWO_NSPG_SHOOT,"moveset/MTWO_NSPG_SHOOT.bin"
    insert MTWO_NSPA_BEGIN,"moveset/MTWO_NSPA_BEGIN.bin"
    insert MTWO_NSPA_SHOOT,"moveset/MTWO_NSPA_SHOOT.bin"
    insert MARTH_NSP_1,"moveset/MARTH_NSP_1.bin"
    insert MARTH_NSP_2_HIGH,"moveset/MARTH_NSP_2_HIGH.bin"
    insert MARTH_NSP_2,"moveset/MARTH_NSP_2.bin"
    insert MARTH_NSP_2_LOW,"moveset/MARTH_NSP_2_LOW.bin"
    insert MARTH_NSP_3_HIGH,"moveset/MARTH_NSP_3_HIGH.bin"
    insert MARTH_NSP_3,"moveset/MARTH_NSP_3.bin"
    insert MARTH_NSP_3_LOW,"moveset/MARTH_NSP_3_LOW.bin"
    insert SONIC_NSP_CHARGE,"moveset/SONIC_NSP_CHARGE.bin"
    insert SONIC_NSP_MOVE,"moveset/SONIC_NSP_MOVE.bin"
    insert SONIC_NSP_BOUNCE,"moveset/SONIC_NSP_BOUNCE.bin"
    insert SHEIK_NSP_BEGIN,"moveset/SHEIK_NSP_BEGIN.bin"
    insert SHEIK_NSP_CHARGE,"moveset/SHEIK_NSP_CHARGE.bin"
    insert SHEIK_NSP_SHOOT,"moveset/SHEIK_NSP_SHOOT.bin"
    insert MARINA_NSP,"moveset/MARINA_NSP.bin"
    MARINA_NSP_PULL:; Moveset.THROW_DATA(Marina.GRAB_RELEASE_DATA); insert "moveset/MARINA_NSP_PULL.bin"
    MARINA_NSPG_THROW:; Moveset.THROW_DATA(Marina.NSPG_THROW_DATA); insert "moveset/MARINA_NSPG_THROW.bin"
    MARINA_NSPG_THROWU:; Moveset.THROW_DATA(Marina.NSPG_THROWU_DATA); insert "moveset/MARINA_NSPG_THROWU.bin"
    MARINA_NSPG_THROWD:; Moveset.THROW_DATA(Marina.NSPG_THROWD_DATA); insert "moveset/MARINA_NSPG_THROWD.bin"
    MARINA_NSPA_THROW:; Moveset.THROW_DATA(Marina.NSPA_THROW_DATA); insert "moveset/MARINA_NSPA_THROW.bin"
    MARINA_NSPA_THROWU:; Moveset.THROW_DATA(Marina.NSPA_THROWU_DATA); insert "moveset/MARINA_NSPA_THROWU.bin"
    MARINA_NSPA_THROWD:; Moveset.THROW_DATA(Marina.NSPA_THROWD_DATA); insert "moveset/MARINA_NSPA_THROWD.bin"
    insert DEDEDE_NSP_SUBROUTINE,"moveset/DEDEDE_NSP_SUBROUTINE.bin"
    insert DEDEDE_NSP_BEGIN,"moveset/DEDEDE_NSP_BEGIN.bin"; Moveset.SUBROUTINE(DEDEDE_NSP_SUBROUTINE); dw 0x00000000
    insert DEDEDE_NSP_INHALE_THROW_DATA,"moveset/DEDEDE_NSP_INHALE_THROW_DATA.bin"
    DEDEDE_NSP_INHALE:; Moveset.THROW_DATA(DEDEDE_NSP_INHALE_THROW_DATA); insert "moveset/DEDEDE_NSP_INHALE.bin"
    insert DEDEDE_NSP_SWALLOW,"moveset/DEDEDE_NSP_SWALLOW.bin"
    DEDEDE_NSP_SPIT:
    dw      0x08000007      // after 7 frames
    Moveset.SUBROUTINE(DEDEDE_NSP_SUBROUTINE)
    insert DEDEDE_NSP_SPIT_2,"moveset/DEDEDE_NSP_SPIT_2.bin"
    insert DEDEDE_NSP_PULL,"moveset/DEDEDE_NSP_PULL.bin"
    GOEMON_NSP_BEGIN:; insert "moveset/GOEMON_NSP_BEGIN.bin"
    GOEMON_NSP_WAIT:; insert "moveset/GOEMON_NSP_WAIT.bin"
    GOEMON_NSP_END:; insert "moveset/GOEMON_NSP_END.bin"

    insert SLIPPY_NSP_GROUND,"moveset/SLIPPY_NSP.bin"
    SLIPPY_NSP_AIR:
    dw 0x98004000
    dw 0x00000000
    dw 0xFF2E0000
    dw 0x00000000
    Moveset.GO_TO(SLIPPY_NSP_GROUND + 0x14)

    insert PEPPY_NSP_BEGIN,"moveset/PEPPY_NSP_BEGIN.bin"
    PEPPY_NSP_CHARGE:;
    Moveset.HIDE_ITEM();
    dw 0xA0880000, 0xD0004000;
    PEPPY_NSP_CHARGE_LOOP:
    Moveset.WAIT(0x16); Moveset.SET_FLAG(0); dw 0x4400002C; Moveset.WAIT(9); Moveset.GO_TO(PEPPY_NSP_CHARGE_LOOP)
    insert PEPPY_NSP_SHOOT,"moveset/PEPPY_NSP_SHOOT.bin"

    BANJO_NSP_BEGIN:
    Moveset.END();

    BANJO_NSP_FORWARD:
    Moveset.VOICE(0x504);
    Moveset.WAIT(4);
    dw 0xA0300027;
    Moveset.SET_FLAG(0);
    Moveset.WAIT(13)
    dw 0xA0A80000;
    Moveset.END();

    BANJO_NSP_BACKWARD:
    // dw 0xA0980001;
    // dw 0xA0A80002;
    Moveset.WAIT(4);
    Moveset.VOICE(0x505)
    Moveset.SET_FLAG(0);
    Moveset.END();

    EBI_NSP_BEGIN:; insert "moveset/EBI_NSP_BEGIN.bin"
    EBI_NSP_WAIT:; insert "moveset/EBI_NSP_WAIT.bin"
    EBI_NSP_END:; insert "moveset/EBI_NSP_END.bin"
    
    insert DRAGONKING_NSP,"moveset/DRAGONKING_NSP.bin"

    // Add Action Parameters                // Action Name       // Base Action // Animation                    // Moveset Data         // Flags
    Character.add_new_action_params(KIRBY,  GND_NSP_Ground,             0x127,  -1,                             GND_NSP_GROUND,         -1)
    Character.add_new_action_params(KIRBY,  GND_NSP_Air,                0x128,  -1,                             GND_NSP_AIR,            -1)
    Character.add_new_action_params(KIRBY,  DRM_NSP_Ground,             0xE7,   -1,                             DRM_NSP_GROUND,         -1)
    Character.add_new_action_params(KIRBY,  DRM_NSP_Air,                0xE8,   -1,                             DRM_NSP_AIR,            -1)
    Character.add_new_action_params(KIRBY,  DSAMUS_Charge,              0xEE,   -1,                             DSAMUS_CHARGE,          -1)
    Character.add_new_action_params(KIRBY,  YLINK_NSP_Ground,           0x11F,  -1,                             YLINK_NSP,              -1)
    Character.add_new_action_params(KIRBY,  YLINK_NSP_Air,              0x122,  -1,                             YLINK_NSP,              -1)
    Character.add_new_action_params(KIRBY,  LUCAS_NSP_Ground,           0xFE,   File.KIRBY_LUCAS_NSP_G,         -1,                     0x40000000)
    Character.add_new_action_params(KIRBY,  LUCAS_NSP_Air,              0xFF,   File.KIRBY_LUCAS_NSP_A,         -1,                     0x00000000)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Ground,           -1,     File.KIRBY_WARIO_NSP_G,         WARIO_NSP_GROUND,       0)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Air,              -1,     File.KIRBY_WARIO_NSP_A,         WARIO_NSP_AIR,          0)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Recoil_Ground,     -1,    File.KIRBY_WARIO_NSPR_G,        WARIO_NSP_RECOIL,       0)
    Character.add_new_action_params(KIRBY,  WARIO_NSP_Recoil_Air,        -1,    File.KIRBY_WARIO_NSPR_A,        WARIO_NSP_RECOIL,       0)
    Character.add_new_action_params(KIRBY,  FALCO_NSP_Ground,           0xEB,   File.KIRBY_FALCO_NSP_G,         FALCO_NSP_GROUND,       0)
    Character.add_new_action_params(KIRBY,  FALCO_NSP_Air,              0xEC,   File.KIRBY_FALCO_NSP_A,         FALCO_NSP_AIR,          0)
    Character.add_new_action_params(KIRBY,  BOWSER_NSP_Ground,          0x129,  File.KIRBY_BOWSER_NSP,          BOWSER_NSP,             0x1D000000)
    Character.add_new_action_params(KIRBY,  BOWSER_NSP_Air,             0x12C,  File.KIRBY_BOWSER_NSP,          BOWSER_NSP,             0x1D000000)
    Character.add_new_action_params(KIRBY,  PIANO_NSP_Ground,           0xE7,   File.KIRBY_PIANO_NSP_G,         PIANO_NSP,              0x1C000000)
    Character.add_new_action_params(KIRBY,  PIANO_NSP_Air,              0xE8,   File.KIRBY_PIANO_NSP_A,         PIANO_NSP,              0x1C000000)
    Character.add_new_action_params(KIRBY,  WOLF_NSP_Ground,            0xE7,   File.KIRBY_WOLF_NSP_G,          WOLF_NSP_GROUND,        -1)
    Character.add_new_action_params(KIRBY,  WOLF_NSP_Air,               0xE8,   File.KIRBY_WOLF_NSP_A,          WOLF_NSP_AIR,           -1)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Ground_Begin,    -1,     File.KIRBY_CONKER_NSPG_BEGIN,   CONKER_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Ground_Wait,     -1,     File.KIRBY_CONKER_NSPG_WAIT,    CONKER_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Ground_End,      -1,     File.KIRBY_CONKER_NSPG_END,     CONKER_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Air_Begin,       -1,     File.KIRBY_CONKER_NSPA_BEGIN,   CONKER_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Air_Wait,        -1,     File.KIRBY_CONKER_NSPA_WAIT,    CONKER_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  CONKER_NSP_Air_End,         -1,     File.KIRBY_CONKER_NSPA_END,     CONKER_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Ground_Begin,      -1,     File.KIRBY_MTWO_NSPG_BEGIN,     MTWO_NSPG_BEGIN,        0x10000000)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Ground_Charge,     -1,     File.KIRBY_MTWO_NSPG_CHARGE,    MTWO_NSPG_CHARGE,       0x10000000)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Ground_Shoot,      -1,     File.KIRBY_MTWO_NSPG_SHOOT,     MTWO_NSPG_SHOOT,        0x10000000)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Air_Begin,         -1,     File.KIRBY_MTWO_NSPA_BEGIN,     MTWO_NSPA_BEGIN,        0x10000000)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Air_Charge,        -1,     File.KIRBY_MTWO_NSPA_CHARGE,    MTWO_NSPA_CHARGE,       0x10000000)
    Character.add_new_action_params(KIRBY,  MTWO_NSP_Air_Shoot,         -1,     File.KIRBY_MTWO_NSPA_SHOOT,     MTWO_NSPA_SHOOT,        0x10000000)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_1,               -1,     File.KIRBY_MARTH_NSPG_1,        MARTH_NSP_1,            0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_2_High,          -1,     File.KIRBY_MARTH_NSPG_2_HI,     MARTH_NSP_2_HIGH,       0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_2_Mid,           -1,     File.KIRBY_MARTH_NSPG_2,        MARTH_NSP_2,            0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_2_Low,           -1,     File.KIRBY_MARTH_NSPG_2_LO,     MARTH_NSP_2_LOW,        0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_3_High,          -1,     File.KIRBY_MARTH_NSPG_3_HI,     MARTH_NSP_3_HIGH,       0x40000000)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_3_Mid,           -1,     File.KIRBY_MARTH_NSPG_3,        MARTH_NSP_3,            0x40000000)
    Character.add_new_action_params(KIRBY,  MARTH_NSPG_3_Low,           -1,     File.KIRBY_MARTH_NSPG_3_LO,     MARTH_NSP_3_LOW,        0x40000000)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_1,               -1,     File.KIRBY_MARTH_NSPA_1,        MARTH_NSP_1,            0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_2_High,          -1,     File.KIRBY_MARTH_NSPA_2_HI,     MARTH_NSP_2_HIGH,       0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_2_Mid,           -1,     File.KIRBY_MARTH_NSPA_2,        MARTH_NSP_2,            0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_2_Low,           -1,     File.KIRBY_MARTH_NSPA_2_LO,     MARTH_NSP_2_LOW,        0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_3_High,          -1,     File.KIRBY_MARTH_NSPA_3_HI,     MARTH_NSP_3_HIGH,       0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_3_Mid,           -1,     File.KIRBY_MARTH_NSPA_3,        MARTH_NSP_3,            0)
    Character.add_new_action_params(KIRBY,  MARTH_NSPA_3_Low,           -1,     File.KIRBY_MARTH_NSPA_3_LO,     MARTH_NSP_3_LOW,        0)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Begin,            -1,     File.KIRBY_SONIC_NSP_LOOP,      SONIC_NSP_CHARGE,       0x10000000)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Move,             -1,     File.KIRBY_SONIC_NSP_LOOP,      SONIC_NSP_MOVE,         0x10000000)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Locked_Move,      -1,     File.KIRBY_SONIC_NSP_LOOP,      SONIC_NSP_MOVE,         0x10000000)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Ground_End,       -1,     File.KIRBY_SONIC_NSPG_END_F,    0x80000000,             0)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Air_End,          -1,     File.KIRBY_SONIC_NSPA_END_F,    0x80000000,             0)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Ground_Recoil,    -1,     File.KIRBY_SONIC_NSPG_END_B,    0x80000000,             0)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Air_Recoil,       -1,     File.KIRBY_SONIC_NSPA_END_B,    0x80000000,             0)
    Character.add_new_action_params(KIRBY,  SONIC_NSP_Bounce,           -1,     File.KIRBY_SONIC_NSPA_END_F,    SONIC_NSP_BOUNCE,       0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Ground_Begin,     -1,     File.KIRBY_SHEIK_NSPG_START,    SHEIK_NSP_BEGIN,             0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Ground_Charge,    -1,     File.KIRBY_SHEIK_NSPG_CHARGE,   SHEIK_NSP_CHARGE,            0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Ground_Shoot,     -1,     File.KIRBY_SHEIK_NSPG_SHOOT,    SHEIK_NSP_SHOOT,             0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Air_Begin,        -1,     File.KIRBY_SHEIK_NSPA_START,    SHEIK_NSP_BEGIN,             0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Air_Charge,       -1,     File.KIRBY_SHEIK_NSPA_CHARGE,   SHEIK_NSP_CHARGE,            0)
    Character.add_new_action_params(KIRBY,  SHEIK_NSP_Air_Shoot,        -1,     File.KIRBY_SHEIK_NSPA_SHOOT,    SHEIK_NSP_SHOOT,             0)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_BEGIN_GROUND,    -1,     File.KIRBY_NSP_BEGIN,           DEDEDE_NSP_BEGIN,       0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_LOOP_GROUND,     -1,     File.KIRBY_NSP_LOOP,            DEDEDE_NSP_INHALE,      0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_PULL_GROUND,     -1,     File.KIRBY_NSP_LOOP,            DEDEDE_NSP_PULL,        0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_SWALLOW_GROUND,  -1,     File.KIRBY_NSP_SWALLOW,         DEDEDE_NSP_SWALLOW,     0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_IDLE_GROUND,     -1,     File.KIRBY_NSP_IDLE,            DEDEDE_NSP_SWALLOW,     0x0C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_SPIT_GROUND,     -1,     File.KIRBY_NSP_SPIT,            DEDEDE_NSP_SPIT,        0x4C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_TURN_GROUND,     -1,     File.KIRBY_NSP_TURN,            0x80000000,             0x00000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_END_GROUND,      -1,     File.KIRBY_NSP_END,             0x80000000,             0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_BEGIN_AIR,       -1,     File.KIRBY_NSP_BEGIN,           DEDEDE_NSP_BEGIN,       0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_LOOP_AIR,        -1,     File.KIRBY_NSP_LOOP,            DEDEDE_NSP_INHALE,      0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_PULL_AIR,        -1,     File.KIRBY_NSP_LOOP,            DEDEDE_NSP_PULL,        0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_SWALLOW_AIR,     -1,     File.KIRBY_NSP_SWALLOW,         DEDEDE_NSP_SWALLOW,     0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_FALL,            -1,     File.KIRBY_NSP_IDLE,            DEDEDE_NSP_SWALLOW,     0x0C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_SPIT_AIR,        -1,     File.KIRBY_NSP_SPIT,            DEDEDE_NSP_SPIT,        0x4C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_TURN_AIR,        -1,     File.KIRBY_NSP_TURN,            0x80000000,             0x00000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_END_AIR,         -1,     File.KIRBY_NSP_END,             0x80000000,             0x1C000000)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_WALK_1,          -1,     File.KIRBY_DEDEDE_NSP_INHALED_WALK, 0x80000000,         0)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_WALK_2,          -1,     File.KIRBY_DEDEDE_NSP_INHALED_WALK, 0x80000000,         0)
    Character.add_new_action_params(KIRBY,  DEDEDE_NSP_WALK_3,          -1,     File.KIRBY_DEDEDE_NSP_INHALED_WALK, 0x80000000,         0)
    Character.add_new_action_params(KIRBY,  MARINA_NSPG,                -1,     File.KIRBY_MARINA_NSPG,         MARINA_NSP,             0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPGPull,            -1,     File.KIRBY_MARINA_NSPG_PULL,    MARINA_NSP_PULL,        0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPGThrow,           -1,     File.KIRBY_MARINA_NSPG_THROW,   MARINA_NSPG_THROW,      0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPGThrowU,          -1,     File.KIRBY_MARINA_NSPG_THROW_U, MARINA_NSPG_THROWU,     0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPGThrowD,          -1,     File.KIRBY_MARINA_NSPG_THROW_D, MARINA_NSPG_THROWD,     0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPA,                -1,     File.KIRBY_MARINA_NSPA,         MARINA_NSP,             0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPAPull,            -1,     File.KIRBY_MARINA_NSPA_PULL,    MARINA_NSP_PULL,        0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPAThrow,           -1,     File.KIRBY_MARINA_NSPA_THROW,   MARINA_NSPA_THROW,      0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPAThrowU,          -1,     File.KIRBY_MARINA_NSPA_THROW_U, MARINA_NSPA_THROWU,     0x10000000)
    Character.add_new_action_params(KIRBY,  MARINA_NSPAThrowD,          -1,     File.KIRBY_MARINA_NSPA_THROW_D, MARINA_NSPA_THROWD,     0x10000000)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_Begin,    -1,     File.KIRBY_GOEMON_NSPG_BEGIN,   GOEMON_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_Wait,     -1,     File.KIRBY_GOEMON_NSPG_IDLE,    GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_Walk1,    -1,     File.KIRBY_GOEMON_NSPG_WALK_1,  GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_Walk2,    -1,     File.KIRBY_GOEMON_NSPG_WALK_2,  GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_BWalk1,   -1,     File.KIRBY_GOEMON_NSPG_BWALK_1, GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_BWalk2,   -1,     File.KIRBY_GOEMON_NSPG_BWALK_2, GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Ground_End,      -1,     File.KIRBY_GOEMON_NSPG_END,     GOEMON_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Air_Begin,       -1,     File.KIRBY_GOEMON_NSPG_BEGIN,   GOEMON_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Air_Wait,        -1,     File.KIRBY_GOEMON_NSPG_IDLE,    GOEMON_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  GOEMON_NSP_Air_End,         -1,     File.KIRBY_GOEMON_NSPG_END,     GOEMON_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  SLIPPY_NSP_Ground,          -1,     0x55C,                          SLIPPY_NSP_GROUND,      0)
    Character.add_new_action_params(KIRBY,  SLIPPY_NSP_Air,             -1,     0x5A4,                          SLIPPY_NSP_AIR,         0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Ground_Begin,     -1,     File.KIRBY_PEPPY_NSP_CHARGESTART, PEPPY_NSP_BEGIN,      0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Ground_Charge,    -1,     File.KIRBY_PEPPY_NSP_CHARGELOOP, PEPPY_NSP_CHARGE,     0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Ground_Shoot,     -1,     0x582,                          PEPPY_NSP_SHOOT,        0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Air_Begin,        -1,     File.KIRBY_PEPPY_NSP_CHARGESTART_AIR, PEPPY_NSP_BEGIN,      0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Air_Charge,       -1,     File.KIRBY_PEPPY_NSP_CHARGELOOP_AIR,PEPPY_NSP_CHARGE,       0)
    Character.add_new_action_params(KIRBY,  PEPPY_NSP_Air_Shoot,        -1,     File.KIRBY_PEPPY_NSP_SHOOT_AIR, PEPPY_NSP_SHOOT,     0)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Ground_Begin,     -1,     File.KIRBY_BANJO_NSP_START,     BANJO_NSP_BEGIN,     0)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Ground_Forward,   -1,     File.KIRBY_BANJO_NSP_FORWARD,   BANJO_NSP_FORWARD,   0x1C000000)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Ground_Backward,  -1,     File.KIRBY_BANJO_NSP_BACKWARD,  BANJO_NSP_BACKWARD,  0)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Air_Begin,        -1,     File.KIRBY_BANJO_NSP_START,     BANJO_NSP_BEGIN,     0)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Air_Forward,      -1,     File.KIRBY_BANJO_NSP_FORWARD,   BANJO_NSP_FORWARD,   0x1C000000)
    Character.add_new_action_params(KIRBY,  BANJO_NSP_Air_Backward,     -1,     File.KIRBY_BANJO_NSP_BACKWARD,  BANJO_NSP_BACKWARD,  0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_Begin,       -1,     File.KIRBY_GOEMON_NSPG_BEGIN,   EBI_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_Wait,        -1,     File.KIRBY_GOEMON_NSPG_IDLE,    EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_Walk1,       -1,     File.KIRBY_GOEMON_NSPG_WALK_1,  EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_Walk2,       -1,     File.KIRBY_GOEMON_NSPG_WALK_2,  EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_BWalk1,      -1,     File.KIRBY_GOEMON_NSPG_BWALK_1, EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_BWalk2,      -1,     File.KIRBY_GOEMON_NSPG_BWALK_2, EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Ground_End,         -1,     File.KIRBY_EBI_NSP_END,         EBI_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Air_Begin,          -1,     File.KIRBY_GOEMON_NSPG_BEGIN,   EBI_NSP_BEGIN,       0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Air_Wait,           -1,     File.KIRBY_GOEMON_NSPG_IDLE,    EBI_NSP_WAIT,        0)
    Character.add_new_action_params(KIRBY,  EBI_NSP_Air_End,            -1,     File.KIRBY_EBI_NSP_END,         EBI_NSP_END,         0)
    Character.add_new_action_params(KIRBY,  DRAGONKING_NSP_Ground,      -1,     File.KIRBY_DKING_NSP_G,         DRAGONKING_NSP,      0x40000000)
    Character.add_new_action_params(KIRBY,  DRAGONKING_NSP_Air,         -1,     File.KIRBY_DKING_NSP_A,         DRAGONKING_NSP,      0x00000000)


    // Add Actions                  // Action Name       // Base Action //Parameters                       // Staling ID    // Main ASM                 // Interrupt/Other ASM              // Movement/Physics ASM     // Collision ASM
    Character.add_new_action(KIRBY, GND_NSP_Ground,             0x127,  ActionParams.GND_NSP_Ground,            -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, GND_NSP_Air,                0x128,  ActionParams.GND_NSP_Air,               -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, DRM_NSP_Ground,             0xE7,   ActionParams.DRM_NSP_Ground,            -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, DRM_NSP_Air,                0xE8,   ActionParams.DRM_NSP_Air,               -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, DSAMUS_Charge,              0xEE,   ActionParams.DSAMUS_Charge,             -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, YLINK_NSP_Ground,           0x11F,  ActionParams.YLINK_NSP_Ground,          -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, YLINK_NSP_Air,              0x122,  ActionParams.YLINK_NSP_Air,             -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, LUCAS_NSP_Ground,           0xFE,   ActionParams.LUCAS_NSP_Ground,          -1,         -1,                         -1,                                 0x800D8CCC,                 -1)
    Character.add_new_action(KIRBY, LUCAS_NSP_Air,              0xFF,   ActionParams.LUCAS_NSP_Air,             -1,         -1,                         LucasNSP.air_move_,                 -1,                         -1)
    Character.add_new_action(KIRBY, WARIO_NSP_Ground,           -1,     ActionParams.WARIO_NSP_Ground,          0x12,       0x800D94C4,                 WarioNSP.ground_move_,              WarioNSP.ground_physics_,   WarioNSP.ground_collision_)
    Character.add_new_action(KIRBY, WARIO_NSP_Air,              -1,     ActionParams.WARIO_NSP_Air,             0x12,       0x800D94E8,                 WarioNSP.air_move_,                 WarioNSP.air_physics_,      WarioNSP.air_collision_)
    Character.add_new_action(KIRBY, WARIO_NSP_Recoil_Ground,    -1,     ActionParams.WARIO_NSP_Recoil_Ground,   0x12,       0x800D94C4,                 0,                                  0x800D8BB4,                 WarioNSP.recoil_ground_collision_)
    Character.add_new_action(KIRBY, WARIO_NSP_Recoil_Air,       -1,     ActionParams.WARIO_NSP_Recoil_Air,      0x12,       0x800D94E8,                 WarioNSP.recoil_move_,              WarioNSP.recoil_physics_,   WarioNSP.recoil_air_collision_)
    Character.add_new_action(KIRBY, FALCO_NSP_Ground,           0xEB,   ActionParams.FALCO_NSP_Ground,          -1,         0x800D94C4,                 Phantasm.ground_subroutine_,        -1,                         -1)
    Character.add_new_action(KIRBY, FALCO_NSP_Air,              0xEC,   ActionParams.FALCO_NSP_Air,             -1,         0x8015C750,                 Phantasm.air_subroutine_,           Phantasm.air_physics_,      Phantasm.air_collision_)
    Character.add_new_action(KIRBY, BOWSER_NSP_Ground,          0x129,  ActionParams.BOWSER_NSP_Ground,         -1,         BowserNSP.main_,            -1,                                 0x800D8BB4,                 0x800DDF44)
    Character.add_new_action(KIRBY, BOWSER_NSP_Air,             0x12C,  ActionParams.BOWSER_NSP_Air,            -1,         BowserNSP.main_,            -1,                                 0x800D91EC,                 BowserNSP.air_collision_)
    Character.add_new_action(KIRBY, PIANO_NSP_Ground,           0xE7,   ActionParams.PIANO_NSP_Ground,          -1,         -1,                         -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, PIANO_NSP_Air,              0xE8,   ActionParams.PIANO_NSP_Air,             -1,         -1,                         -1,                                 0x800D91EC,                 -1)
    Character.add_new_action(KIRBY, WOLF_NSP_Ground,            0xEB,   ActionParams.WOLF_NSP_Ground,           -1,         WolfNSP.main,               -1,                                 -1,                         -1)
    Character.add_new_action(KIRBY, WOLF_NSP_Air,               0xEC,   ActionParams.WOLF_NSP_Air,              -1,         WolfNSP.main,               -1,                                 -1,                         WolfNSP.air_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Ground_Begin,    -1,     ActionParams.CONKER_NSP_Ground_Begin,   0x12,       ConkerNSP.ground_begin_main_, 0,                                0x800D8BB4,                 ConkerNSP.ground_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Ground_Wait,     -1,     ActionParams.CONKER_NSP_Ground_Wait,    0x12,       ConkerNSP.ground_wait_main_,  0,                                0x800D8BB4,                 ConkerNSP.ground_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Ground_End,      -1,     ActionParams.CONKER_NSP_Ground_End,     0x12,       ConkerNSP.end_main_,          0,                                0x800D8BB4,                 ConkerNSP.ground_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Air_Begin,       -1,     ActionParams.CONKER_NSP_Air_Begin,      0x12,       ConkerNSP.air_begin_main_,    0,                                0x800D90E0,                 ConkerNSP.air_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Air_Wait,        -1,     ActionParams.CONKER_NSP_Air_Wait,       0x12,       ConkerNSP.air_wait_main_,     0,                                0x800D90E0,                 ConkerNSP.air_collision_)
    Character.add_new_action(KIRBY, CONKER_NSP_Air_End,         -1,     ActionParams.CONKER_NSP_Air_End,        0x12,       ConkerNSP.end_main_,          0,                                0x800D90E0,                 ConkerNSP.air_collision_end_)
    Character.add_new_action(KIRBY, MTWO_NSP_Ground_Begin,      -1,     ActionParams.MTWO_NSP_Ground_Begin,     0x12,       MewtwoNSP.begin_main_,        0x8015D464,                         0x800D8BB4,               MewtwoNSP.kirby_ground_begin_collision_)
    Character.add_new_action(KIRBY, MTWO_NSP_Ground_Charge,     -1,     ActionParams.MTWO_NSP_Ground_Charge,    0x12,       MewtwoNSP.kirby_charge_main_, MewtwoNSP.ground_charge_interrupt_, 0x800D8BB4,               MewtwoNSP.kirby_ground_charge_collision_)
    Character.add_new_action(KIRBY, MTWO_NSP_Ground_Shoot,      -1,     ActionParams.MTWO_NSP_Ground_Shoot,     0x12,       MewtwoNSP.kirby_shoot_main_,  0,                                  0x800D8BB4,               MewtwoNSP.kirby_ground_shoot_collision_)
    Character.add_new_action(KIRBY, MTWO_NSP_Air_Begin,         -1,     ActionParams.MTWO_NSP_Air_Begin,        0x12,       MewtwoNSP.begin_main_,        0x8015D464,                         0x800D90E0,               MewtwoNSP.air_begin_collision_)
    Character.add_new_action(KIRBY, MTWO_NSP_Air_Charge,        -1,     ActionParams.MTWO_NSP_Air_Charge,       0x12,       MewtwoNSP.kirby_charge_main_, MewtwoNSP.air_charge_interrupt_,    0x800D91EC,               MewtwoNSP.air_charge_collision_)
    Character.add_new_action(KIRBY, MTWO_NSP_Air_Shoot,         -1,     ActionParams.MTWO_NSP_Air_Shoot,        0x12,       MewtwoNSP.kirby_shoot_main_,  0,                                  0x800D91EC,               MewtwoNSP.air_shoot_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_1,               -1,     ActionParams.MARTH_NSPG_1,              0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_2_High,          -1,     ActionParams.MARTH_NSPG_2_High,         0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_2_Mid,           -1,     ActionParams.MARTH_NSPG_2_Mid,          0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_2_Low,           -1,     ActionParams.MARTH_NSPG_2_Low,          0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_3_High,          -1,     ActionParams.MARTH_NSPG_3_High,         0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_3_Mid,           -1,     ActionParams.MARTH_NSPG_3_Mid,          0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPG_3_Low,           -1,     ActionParams.MARTH_NSPG_3_Low,          0x12,       MarthNSP.ground_main_,      0,                                  0x800D8CCC,                 MarthNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_1,               -1,     ActionParams.MARTH_NSPA_1,              0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_2_High,          -1,     ActionParams.MARTH_NSPA_2_High,         0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_2_Mid,           -1,     ActionParams.MARTH_NSPA_2_Mid,          0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_2_Low,           -1,     ActionParams.MARTH_NSPA_2_Low,          0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_3_High,          -1,     ActionParams.MARTH_NSPA_3_High,         0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_3_Mid,           -1,     ActionParams.MARTH_NSPA_3_Mid,          0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, MARTH_NSPA_3_Low,           -1,     ActionParams.MARTH_NSPA_3_Low,          0x12,       MarthNSP.air_main_,         0,                                  0x800D91EC,                 MarthNSP.air_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Begin,            -1,     ActionParams.SONIC_NSP_Begin,           0x12,       SonicNSP.begin_main_,       0,                                  0,                          0x800DE6B0)
    Character.add_new_action(KIRBY, SONIC_NSP_Move,             -1,     ActionParams.SONIC_NSP_Move,            0x12,       SonicNSP.move_main_,        0,                                  SonicNSP.move_physics_,     SonicNSP.move_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Locked_Move,      -1,     ActionParams.SONIC_NSP_Locked_Move,     0x12,       SonicNSP.move_main_,        0,                                  SonicNSP.move_physics_,     SonicNSP.move_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Ground_End,       -1,     ActionParams.SONIC_NSP_Ground_End,      0x12,       0x800D94C4,                 0,                                  0x800D8BB4,                 SonicNSP.ground_end_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Air_End,          -1,     ActionParams.SONIC_NSP_Air_End,         0x12,       0x800D94E8,                 0,                                  0x800D91EC,                 SonicNSP.air_end_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Ground_Recoil,    -1,     ActionParams.SONIC_NSP_Ground_Recoil,   0x12,       0x800D94C4,                 0,                                  0x800D8BB4,                 SonicNSP.ground_recoil_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Air_Recoil,       -1,     ActionParams.SONIC_NSP_Air_Recoil,      0x12,       0x800D94E8,                 0,                                  0x800D91EC,                 SonicNSP.air_recoil_collision_)
    Character.add_new_action(KIRBY, SONIC_NSP_Bounce,           -1,     ActionParams.SONIC_NSP_Bounce,          0x12,       0x800D94E8,                 0,                                  0x800D91EC,                 0x800DE99C)
    Character.add_new_action(KIRBY, SHEIK_NSP_Ground_Begin,     -1,     ActionParams.SHEIK_NSP_Ground_Begin,    0x12,       SheikNSP.begin_main_,       0x8015D464,                         0x800D8BB4,                 SheikNSP.kirby_ground_begin_collision_)
    Character.add_new_action(KIRBY, SHEIK_NSP_Ground_Charge,    -1,     ActionParams.SHEIK_NSP_Ground_Charge,   0x12,       SheikNSP.charge_main_,      SheikNSP.ground_charge_interrupt_,  0x800D8BB4,                 SheikNSP.kirby_ground_charge_collision_)
    Character.add_new_action(KIRBY, SHEIK_NSP_Ground_Shoot,     -1,     ActionParams.SHEIK_NSP_Ground_Shoot,    0x12,       SheikNSP.shoot_main_,       0,                                  0x800D8BB4,                 SheikNSP.kirby_ground_shoot_collision_)
    Character.add_new_action(KIRBY, SHEIK_NSP_Air_Begin,        -1,     ActionParams.SHEIK_NSP_Air_Begin,       0x12,       SheikNSP.begin_main_,       0x8015D464,                         0x800D90E0,                 SheikNSP.air_begin_collision_)
    Character.add_new_action(KIRBY, SHEIK_NSP_Air_Charge,       -1,     ActionParams.SHEIK_NSP_Air_Charge,      0x12,       SheikNSP.charge_main_,      SheikNSP.air_charge_interrupt_,     0x800D91EC,                 SheikNSP.air_charge_collision_)
    Character.add_new_action(KIRBY, SHEIK_NSP_Air_Shoot,        -1,     ActionParams.SHEIK_NSP_Air_Shoot,       0x12,       SheikNSP.shoot_main_,       0,                                  0x800D91EC,                 SheikNSP.air_shoot_collision_)
    Character.add_new_action(KIRBY, DEDEDE_NSP_BEGIN_GROUND,    -1,     ActionParams.DEDEDE_NSP_BEGIN_GROUND,   0x12,       DededeNSP.ground_begin_main_,   0,                                  0x800D8BB4,             0x80162750)
    Character.add_new_action(KIRBY, DEDEDE_NSP_LOOP_GROUND,     -1,     ActionParams.DEDEDE_NSP_LOOP_GROUND,    0x12,       0x8016201C,                     0x80162468,                         0x800D8BB4,             DededeNSP.inhale_loop_ground_to_air_check_)
    Character.add_new_action(KIRBY, DEDEDE_NSP_PULL_GROUND,     -1,     ActionParams.DEDEDE_NSP_PULL_GROUND,    0x12,       0x80162078,                     0,                                  0x800D8BB4,             0x801627BC)
    Character.add_new_action(KIRBY, DEDEDE_NSP_SWALLOW_GROUND,  -1,     ActionParams.DEDEDE_NSP_SWALLOW_GROUND, 0x12,       0x80162214,                     0,                                  0x800D8BB4,             0x801627E0)
    Character.add_new_action(KIRBY, DEDEDE_NSP_IDLE_GROUND,     -1,     ActionParams.DEDEDE_NSP_IDLE_GROUND,    0x12,       0,                              DededeNSP.ground_idle_interrupt_,   0x800D8BB4,             0x80162828)
    Character.add_new_action(KIRBY, DEDEDE_NSP_SPIT_GROUND,     -1,     ActionParams.DEDEDE_NSP_SPIT_GROUND,    0x12,       DededeNSP.ground_spit_main_,    0,                                  0x800D8C14,             0x80162804)
    Character.add_new_action(KIRBY, DEDEDE_NSP_TURN_GROUND,     -1,     ActionParams.DEDEDE_NSP_TURN_GROUND,    0x12,       0x801621CC,                     0,                                  0x800D8BB4,             0x8016284C)
    Character.add_new_action(KIRBY, DEDEDE_NSP_END_GROUND,      -1,     ActionParams.DEDEDE_NSP_END_GROUND,     0x12,       0x800D94C4,                     0,                                  0x800D8BB4,             0x80162798)
    Character.add_new_action(KIRBY, DEDEDE_NSP_BEGIN_AIR,       -1,     ActionParams.DEDEDE_NSP_BEGIN_AIR,      0x12,       DededeNSP.air_begin_main_,      0,                                  0x800D91EC,             0x80162894)
    Character.add_new_action(KIRBY, DEDEDE_NSP_LOOP_AIR,        -1,     ActionParams.DEDEDE_NSP_LOOP_AIR,       0x12,       0x8016201C,                     0x80162498,                         0x800D91EC,             DededeNSP.inhale_loop_air_to_ground_check_)
    Character.add_new_action(KIRBY, DEDEDE_NSP_PULL_AIR,        -1,     ActionParams.DEDEDE_NSP_PULL_AIR,       0x12,       0x80162078,                     0,                                  0x800D91EC,             0x80162900)
    Character.add_new_action(KIRBY, DEDEDE_NSP_SWALLOW_AIR,     -1,     ActionParams.DEDEDE_NSP_SWALLOW_AIR,    0x12,       0x80162214,                     0,                                  0x800D91EC,             0x80162924)
    Character.add_new_action(KIRBY, DEDEDE_NSP_FALL,            -1,     ActionParams.DEDEDE_NSP_FALL,           0x12,       0,                              DededeNSP.air_fall_interrupt_,      0x800D91EC,             0x8016296C)
    Character.add_new_action(KIRBY, DEDEDE_NSP_SPIT_AIR,        -1,     ActionParams.DEDEDE_NSP_SPIT_AIR,       0x12,       DededeNSP.air_spit_main_,       0,                                  0x800D93E4,             0x80162948)
    Character.add_new_action(KIRBY, DEDEDE_NSP_TURN_AIR,        -1,     ActionParams.DEDEDE_NSP_TURN_AIR,       0x12,       0x801621F0,                     0,                                  0x800D91EC,             0x80162990)
    Character.add_new_action(KIRBY, DEDEDE_NSP_END_AIR,         -1,     ActionParams.DEDEDE_NSP_END_AIR,        0x12,       0x800D94E8,                     0,                                  0x800D91EC,             0x801628DC)
    Character.add_new_action(KIRBY, DEDEDE_NSP_WALK_1,          -1,     ActionParams.DEDEDE_NSP_WALK_1,         0x12,       0,                              DededeNSP.ground_walk_interrupt_,   0x8013E548,             DededeNSP.ground_walk_collision_)
    Character.add_new_action(KIRBY, DEDEDE_NSP_WALK_2,          -1,     ActionParams.DEDEDE_NSP_WALK_2,         0x12,       0,                              DededeNSP.ground_walk_interrupt_,   0x8013E548,             DededeNSP.ground_walk_collision_)
    Character.add_new_action(KIRBY, DEDEDE_NSP_WALK_3,          -1,     ActionParams.DEDEDE_NSP_WALK_3,         0x12,       0,                              DededeNSP.ground_walk_interrupt_,   0x8013E548,             DededeNSP.ground_walk_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPG,                -1,     ActionParams.MARINA_NSPG,               0x12,       0x800D94C4,                     0,                              MarinaNSP.ground_physics_,    MarinaNSP.ground_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPGPull,            -1,     ActionParams.MARINA_NSPGPull,           0x12,       MarinaNSP.ground_pull_main_,    0,                              0x800D8BB4,                   MarinaNSP.grab_ground_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPGThrow,           -1,     ActionParams.MARINA_NSPGThrow,          0x12,       0x8014A0C0,                     MarinaNSP.throw_turn_,          0x800D8BB4,                   0x80149B78)
    Character.add_new_action(KIRBY, MARINA_NSPGThrowU,          -1,     ActionParams.MARINA_NSPGThrowU,         0x12,       0x8014A0C0,                     0,                              0x800D8BB4,                   0x80149B78)
    Character.add_new_action(KIRBY, MARINA_NSPGThrowD,          -1,     ActionParams.MARINA_NSPGThrowD,         0x12,       0x8014A0C0,                     0,                              0x800D8BB4,                   0x80149B78)
    Character.add_new_action(KIRBY, MARINA_NSPA,                -1,     ActionParams.MARINA_NSPA,               0x12,       0x800D94E8,                     0,                              MarinaNSP.air_physics_,       MarinaNSP.air_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPAPull,            -1,     ActionParams.MARINA_NSPAPull,           0x12,       MarinaNSP.air_pull_main_,       0,                              0x800D91EC,                   MarinaNSP.grab_air_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPAThrow,           -1,     ActionParams.MARINA_NSPAThrow,          0x12,       0x8014A0C0,                     MarinaNSP.throw_turn_,          MarinaNSP.throw_air_physics_, MarinaNSP.throw_air_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPAThrowU,          -1,     ActionParams.MARINA_NSPAThrowU,         0x12,       0x8014A0C0,                     0,                              MarinaNSP.throw_air_physics_, MarinaNSP.throw_air_collision_)
    Character.add_new_action(KIRBY, MARINA_NSPAThrowD,          -1,     ActionParams.MARINA_NSPAThrowD,         0x12,       0x8014A0C0,                     0,                              MarinaNSP.throw_air_physics_, MarinaNSP.throw_air_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_Begin,    -1,     ActionParams.GOEMON_NSP_Ground_Begin,  0x12,        GoemonNSP.ground_begin_main_,   0,                              0x800D8BB4,                         GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_Wait,     -1,     ActionParams.GOEMON_NSP_Ground_Wait,   0x12,        GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    0x800D8BB4,                         GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_Walk1,    -1,     ActionParams.GOEMON_NSP_Ground_Walk1,  0x12,        GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_Walk2,    -1,     ActionParams.GOEMON_NSP_Ground_Walk2,  0x12,        GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_BWalk1,   -1,     ActionParams.GOEMON_NSP_Ground_BWalk1, 0x12,        GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_BWalk2,   -1,     ActionParams.GOEMON_NSP_Ground_BWalk2, 0x12,        GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Ground_End,      -1,     ActionParams.GOEMON_NSP_Ground_End,    0x12,        GoemonNSP.end_main_,            0,                              0x800D8BB4,                         GoemonNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Air_Begin,       -1,     ActionParams.GOEMON_NSP_Air_Begin,     0x12,        GoemonNSP.air_begin_main_,      0,                              GoemonNSP.air_physics_,             GoemonNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Air_Wait,        -1,     ActionParams.GOEMON_NSP_Air_Wait,      0x12,        GoemonNSP.air_wait_main_,       0,                              GoemonNSP.air_physics_,             GoemonNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, GOEMON_NSP_Air_End,         -1,     ActionParams.GOEMON_NSP_Air_End,       0x12,        GoemonNSP.end_main_,            0,                              GoemonNSP.air_physics_,             GoemonNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, SLIPPY_NSP_Ground,          -1,     ActionParams.SLIPPY_NSP_Ground,        0x12,        SlippyNSP.main_,                0x8015BBD8,                     0x800D8BB4,                         0x800DDF44)
    Character.add_new_action(KIRBY, SLIPPY_NSP_Air,             -1,     ActionParams.SLIPPY_NSP_Air,           0x12,        SlippyNSP.main_,                0x8015BBD8,                     0x800D90E0,                         SlippyNSP.air_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Ground_Begin,     -1,     ActionParams.PEPPY_NSP_Ground_Begin,   0x12,        PeppyNSP.begin_main_,           0x8015D464,                     0x800D8BB4,                     PeppyNSP.kirby_ground_begin_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Ground_Charge,    -1,     ActionParams.PEPPY_NSP_Ground_Charge,  0x12,        PeppyNSP.charge_main_,          PeppyNSP.ground_charge_interrupt_, 0x800D8BB4,                  PeppyNSP.kirby_ground_charge_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Ground_Shoot,     -1,     ActionParams.PEPPY_NSP_Ground_Shoot,   0x12,        PeppyNSP.shoot_main_,           0,                              0x800D8BB4,                     PeppyNSP.kirby_ground_shoot_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Air_Begin,        -1,     ActionParams.PEPPY_NSP_Air_Begin,      0x12,        PeppyNSP.begin_main_,           0x8015D464,                     0x800D90E0,                     PeppyNSP.air_begin_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Air_Charge,       -1,     ActionParams.PEPPY_NSP_Air_Charge,     0x12,        PeppyNSP.charge_main_,          PeppyNSP.air_charge_interrupt_, 0x800D90E0,                     PeppyNSP.air_charge_collision_)
    Character.add_new_action(KIRBY, PEPPY_NSP_Air_Shoot,        -1,     ActionParams.PEPPY_NSP_Air_Shoot,      0x12,        PeppyNSP.shoot_main_,           0,                              0x800D90E0,                     PeppyNSP.air_shoot_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPBeginG,            -1,     ActionParams.BANJO_NSP_Ground_Begin,  0x12,        BanjoNSP.begin_main_,           0,                              0x800D8BB4,                 BanjoNSP.ground_begin_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPForwardG,          -1,     ActionParams.BANJO_NSP_Ground_Forward, 0x12,        BanjoNSP.shoot_forward_main_,   0,                              0x800D8BB4,                 BanjoNSP.ground_shoot_forward_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPBackwardG,         -1,     ActionParams.BANJO_NSP_Ground_Backward, 0x12,        BanjoNSP.shoot_backward_main_,  0,                              0x800D8BB4,                 BanjoNSP.ground_shoot_backward_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPBeginA,            -1,     ActionParams.BANJO_NSP_Air_Begin,      0x12,        BanjoNSP.begin_main_,           0,                              0x800D90E0,                 BanjoNSP.air_begin_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPForwardA,          -1,     ActionParams.BANJO_NSP_Air_Forward,    0x12,        BanjoNSP.shoot_forward_main_,   0,                              0x800D90E0,                 BanjoNSP.air_shoot_forward_collision_)
    Character.add_new_action(KIRBY, BANJO_NSPBackwardA,         -1,     ActionParams.BANJO_NSP_Air_Backward,   0x12,        BanjoNSP.shoot_backward_main_,  0,                              0x800D90E0,                 BanjoNSP.air_shoot_backward_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_Begin,       -1,     ActionParams.EBI_NSP_Ground_Begin,  0x12,           EbiNSP.ground_begin_main_,   0,                              0x800D8BB4,                         EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_Wait,        -1,     ActionParams.EBI_NSP_Ground_Wait,   0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    0x800D8BB4,                         EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_Walk1,       -1,     ActionParams.EBI_NSP_Ground_Walk1,  0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_Walk2,       -1,     ActionParams.EBI_NSP_Ground_Walk2,  0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_BWalk1,      -1,     ActionParams.EBI_NSP_Ground_BWalk1, 0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_BWalk2,      -1,     ActionParams.EBI_NSP_Ground_BWalk2, 0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Ground_End,         -1,     ActionParams.EBI_NSP_Ground_End,    0x12,           EbiNSP.end_main_,            0,                              0x800D8BB4,                         EbiNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Air_Begin,          -1,     ActionParams.EBI_NSP_Air_Begin,     0x12,           EbiNSP.air_begin_main_,      0,                              GoemonNSP.air_physics_,             EbiNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Air_Wait,           -1,     ActionParams.EBI_NSP_Air_Wait,      0x12,           EbiNSP.air_wait_main_,       0,                              GoemonNSP.air_physics_,             EbiNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, EBI_NSP_Air_End,            -1,     ActionParams.EBI_NSP_Air_End,       0x12,           EbiNSP.end_main_,            0,                              GoemonNSP.air_physics_,             EbiNSP.kirby_air_collision_)
    Character.add_new_action(KIRBY, DRAGONKING_NSP_Ground,      -1,     ActionParams.DRAGONKING_NSP_Ground, 0x12,           DragonKingNSP.main_,         0,                              0x800D8CCC,                         DragonKingNSP.kirby_ground_collision_)
    Character.add_new_action(KIRBY, DRAGONKING_NSP_Air,         -1,     ActionParams.DRAGONKING_NSP_Air,    0x12,           DragonKingNSP.main_,         0,                              DragonKingNSP.physics_aerial_,      DragonKingNSP.kirby_air_collision_)


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

    Character.table_patch_start(kirby_ground_nsp, Character.id.CONKER, 0x4)
    dw      ConkerNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.CONKER, 0x4)
    dw      ConkerNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.MTWO, 0x4)
    dw      MewtwoNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.MTWO, 0x4)
    dw      MewtwoNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.MARTH, 0x4)
    dw      MarthNSP.ground_1_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.MARTH, 0x4)
    dw      MarthNSP.air_1_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.SONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.SONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.SHEIK, 0x4)
    dw      SheikNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.SHEIK, 0x4)
    dw      SheikNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.DEDEDE, 0x4)
    dw      DededeNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.DEDEDE, 0x4)
    dw      DededeNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.MARINA, 0x4)
    dw      MarinaNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.MARINA, 0x4)
    dw      MarinaNSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.GOEMON, 0x4)
    dw      GoemonNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.GOEMON, 0x4)
    dw      GoemonNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.SLIPPY, 0x4)
    dw      SlippyNSP.kirby_ground_begin_initial
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.SLIPPY, 0x4)
    dw      SlippyNSP.kirby_air_begin_initial
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.PEPPY, 0x4)
    dw      PeppyNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.PEPPY, 0x4)
    dw      PeppyNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.BANJO, 0x4)
    dw      BanjoNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.BANJO, 0x4)
    dw      BanjoNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(kirby_ground_nsp, Character.id.EBI, 0x4)
    dw      EbiNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.EBI, 0x4)
    dw      EbiNSP.air_begin_initial_
    OS.patch_end()
    
    Character.table_patch_start(kirby_ground_nsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingNSP.kirby_ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(kirby_air_nsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingNSP.kirby_air_begin_initial_
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
    // This handles '???' Magic Kirby Hat (NSP rolls a random power each time)
    scope kirby_magic_hat: {
        // Grounded Kirby
        OS.patch_start(0xCBAB0, 0x80151070)
        jal     kirby_magic_hat
        nop
        OS.patch_end()

        // Aerial Kirby
        OS.patch_start(0xCB920, 0x80150EE0)
        jal     kirby_magic_hat
        nop
        OS.patch_end()

        // a1 = player struct
        // t6, t7, t0 are safe
        li      t7, KirbyHats.magic_hat_on  // t7 = magic_hat_on
        lbu     t0, 0x000D(a1)              // t0 = port
        sll     t0, t0, 0x0002              // t0 = offset to port
        addu    t6, t7, t0                  // t6 = address of magic_hat_on
        lw      t0, 0x0000(t6)              // t0 = magic_hat_on
        beqzl   t0, _end                    // if magic hat not active, skip
        lw      t6, 0x0ADC(v0)              // original line 2 (load Kirby power ID)

        _check_hat:
        lbu     t7, 0x0980(a1)              // t7 = Kirby Hat ID
        beqzl   t7, _end                    // safety branch if Kirby has no hat
        lw      t6, 0x0ADC(v0)              // original line 2 (load Kirby power ID)

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // store registers
        sw      ra, 0x0008(sp)              // ~
        sw      v1, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      at, 0x0014(sp)              // ~

        lbu     t0, 0x000D(a1)              // t0 = player port
        sll     t0, t0, 0x0002              // t0 = offset to player entry
        li      t7, magic_kirby_hat_history // t7 = address of magic_kirby_hat_history
        addu    t7, t7, t0                  // add to table address to get entry in magic_kirby_hat_history
        lw      t0, 0x0000(t7)              // t0 = last used kirby hat

        // we need to store the previous hat's charge in table...
        // ...and then load any stored charge for newly selected hat (t6)
        li      a0, magic_kirby_hat_charge  // a0 = address of magic_kirby_hat_charge table
        _check_recent_hat_loop:
        lh      t7, 0x0004(a0)              // t7 = character ID in table (-1 if final entry)
        bltz    t7, _clear_ammo             // branch if last used hat is not in table
        nop
        beql    t7, t0, _store_hat_charge   // branch if last used hat matches ID
        nop
        addiu   a0, a0, 8                   // a0 = address of next entry in table
        b       _check_recent_hat_loop      // if not done, continue looping
        nop

        _store_hat_charge:
        lbu     at, 0x000D(a1)              // at = player port
        addu    at, a0, at                  // at = charge level in table + port offset
        lli     t7, Character.id.DONKEY     // t7 = id.DONKEY
        beql    t7, t0, pc() + 12           // load ammo from appropriate address
        lw      t7, 0x0AE8(a1)              // t7 = ammo value (DK)
        lw      t7, 0x0AE0(a1)              // t7 = ammo value (others)
        sb      t7, 0x0000(at)              // store current charge in table

        // ...if fully charged, instead of randomizing use the previously selected kirby hat
        lh      t0, 0x0006(a0)              // t0 = max charge value for that character
        lw      t6, 0x0ADC(a1)              // t6 = current Kirby power ID
        beql    t0, t7, _continue           // branch if charge is at max value...
        sb      r0, 0x0000(at)              // ...and clear stored charge in table
        // clear ammo in player struct
        _clear_ammo:
        sw      r0, 0x0AE8(a1)              // clear ammo (DK)
        sw      r0, 0x0AE0(a1)              // clear ammo (others)

        _get_random_hat:
        lli     a0, KirbyHats.total_hats    // a0 = total_hats
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        addiu   v0, v0, 0x0001              // v0++ (can't be 0 'NA' Kirby)
        li      a0, KirbyHats.spawn_with_table_
        addu    a0, v0, a0                  // add to table address to get character ID
        lbu     t6, 0x0000(a0)              // t6 = character ID
        lli     a0, Character.id.NONE       // a0 = ID used for magic hat
        beq     t6, a0, _get_random_hat     // if magic hat ID, get a different ID
        nop

        _check_current_hat:
        li      a0, magic_kirby_hat_charge  // a0 = address of magic_kirby_hat_charge table
        _check_current_hat_loop:
        lh      t7, 0x0004(a0)              // t7 = character ID in table (-1 if final entry)
        bltz    t7, _continue               // branch if last used hat is not in table
        nop
        beql    t7, t6, _load_hat_charge    // branch if currently picked hat matches ID
        nop
        addiu   a0, a0, 8                   // a0 = address of next entry in table
        b       _check_current_hat_loop     // if not done, continue looping
        nop

        _load_hat_charge:
        lbu     t0, 0x000D(a1)              // t0 = player port
        addu    t0, a0, t0                  // t0 = charge level in table + port offset
        lb      t0, 0x0000(t0)              // t0 = charge level value
        lli     t7, Character.id.DONKEY     // t7 = id.DONKEY
        beql    t7, t6, pc() + 12           // store ammo in appropriate address
        sw      t0, 0x0AE8(a1)              // store ammo (DK)
        sw      t0, 0x0AE0(a1)              // store ammo (others)

        // (Alternative Method)
        // we're looking to see if Kirby has stored a charge, and using that same hat again if there is ammo
        //// _check_for_chargeable_hat:
        //// lbu     t0, 0x000D(a1)              // t0 = player port
        //// sll     t0, t0, 0x0002              // t0 = offset to player entry
        //// li      t7, magic_kirby_hat_history // t7 = address of magic_kirby_hat_history
        //// addu    t7, t7, t0                  // add to table address to get entry in magic_kirby_hat_history
        //// lw      t0, 0x0000(t7)              // t0 = last used kirby hat
        //// // check for a 'chargeable' whitelisted character; clear otherwise (so no risk of 'stuck' ammo)
        //// lli     at, Character.id.DONKEY     // at = id.DONKEY
        //// beq     t0, at, _check_ammo         // branch if match
        //// lli     at, Character.id.SAMUS      // at = id.SAMUS
        //// beq     t0, at, _check_ammo         // branch if match
        //// lli     at, Character.id.DSAMUS     // at = id.DSAMUS
        //// beq     t0, at, _check_ammo         // branch if match
        //// lli     at, Character.id.MTWO       // at = id.MTWO
        //// beq     t0, at, _check_ammo         // branch if match
        //// lli     at, Character.id.SHEIK      // at = id.SHEIK
        //// beq     t0, at, _check_ammo         // branch if match
        //// lli     at, Character.id.PEPPY      // at = id.PEPPY
        //// beq     t0, at, _check_ammo         // branch if match
        //// nop

        //// // if we reach this point then Kirby didn't previously use a move that could store a charge
        //// sw      r0, 0x0AE0(a1)              // clear ammo just to be safe
        //// sw      r0, 0x0AE8(a1)              // ~
        //// // sw      r0, 0x0000(t7)              // ..and last used kirby hat?
        //// b       _continue
        //// nop

        //// _check_ammo:
        //// lw      t0, 0x0AE0(a1)              // t0 = ammo value (Samus, DSamus, Mewtwo, Sheik, Peppy)
        //// bnezl   t0, pc() + 8                // load the last used kirby hat if there is stored ammo
        //// lw      t6, 0x0000(t7)              // ~
        //// lw      t0, 0x0AE8(a1)              // t0 = ammo value (DK)
        //// bnezl   t0, pc() + 8                // load the last used kirby hat if there is stored ammo
        //// lw      t6, 0x0000(t7)              // ~
        //// nop

        _continue:
        // Bowser-specific (initialize)
        lli     at, Character.id.BOWSER     // at = id.BOWSER
        addiu   a0, r0, 0x0014              // a0 = 0x0014
        beql    at, t6, pc() + 8            // Bowser Kirby starts with full fire ammo (single use)
        sh      a0, 0x0AE2(a1)              // ~

        lw      a0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        lw      v1, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      at, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        lbu     t0, 0x000D(a1)              // t0 = player port
        sll     t0, t0, 0x0002              // t0 = offset to player entry
        li      t7, magic_kirby_hat_history // t7 = address of magic_kirby_hat_history
        addu    t7, t7, t0                  // t7 = magic_kirby_hat_history + port offset
        sw      t6, 0x0000(t7)              // save kirby hat to magic_kirby_hat_history
        sw      t6, 0x0ADC(v0)              // store random Kirby power ID

        // Swap hat
        OS.save_registers()
        li      t3, Character.kirby_inhale_struct.table
        sll     t4, t6, 0x0002              // t4 = char_id * 4
        subu    t4, t4, t6                  // t4 = char_id * 3
        sll     t4, t4, 0x0002              // t4 = char_id * 12 = offset to inhale array
        addu    t3, t3, t4                  // t3 = inhale array
        lh      a2, 0x0002(t3)              // a2 = hat_id
        lw      a0, 0x0004(v0)              // a0 = player object
        jal     0x800E8EAC                  // set part
        lli     a1, 0x0006                  // a1 = part ID (Kirby hat)

        lw      v0, 0x0008(sp)              // v0 = player struct
        jal     0x800E8ECC                  // swap part
        lw      a0, 0x0004(v0)              // a0 = player object

        // draw gfx on head
        lw      v0, 0x0008(sp)              // v0 = player struct
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      r0, 0x0010(sp)              // ~
        lui     t0, 0x4300                  // t0 = y offset
        sw      t0, 0x0014(sp)              // ~
        sw      r0, 0x0018(sp)              // establish origin points for x, y, and z
        lw      a0, 0x0900(v0)              // a0 = part 2 (Kirby's head/body)
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        addiu   a1, sp, 0x0010              // a1 = address to return x/y/z coordinates to

        addiu   a0, sp, 0x0010              // a0 = coords
        jal     0x8010066C                  // create spark gfx
        lui     a1, 0x3FA0                  // a1 = size multiplier
        addiu   sp, sp, 0x0020              // deallocate stack space
        OS.restore_registers()

        _end:
        sll     t7, t6, 2                   // original line 3
        jr      ra
        nop
    }

    // @ Description
    // This clears stored Magic Hat charges when Kirby is spawning
    scope clear_magic_hat_charge: {
        // v1 = player struct
        // v0, t5 are safe

        li      v0, magic_kirby_hat_charge  // v0 = address of magic_kirby_hat_charge table
        _loop:
        lbu     t5, 0x000D(v1)              // t5 = port
        addu    t5, v0, t5                  // t5 = charge level in table + port offset
        sb      r0, 0x0000(t5)              // clear the charge level of that port's entry in table
        lh      t5, 0x0004(v0)              // t5 = character ID in table (-1 if final entry)
        addiu   v0, v0, 8                   // v0 = address of next entry in table
        bgez    t5, _loop                   // if not done, continue looping
        nop

        _end:
        j       KirbyHats.kirby_hat_select_._get_character_id  // return to function
        nop
    }

    magic_kirby_hat_history:
    dw 0,0,0,0

    // @ Description
    // Keeps track of each port's per-Hat stored charge, and what that the maximum charge value is for that Character
    magic_kirby_hat_charge:
    db 0, 0, 0, 0; dh Character.id.DONKEY;  dh 10
    db 0, 0, 0, 0; dh Character.id.SAMUS;   dh 7
    db 0, 0, 0, 0; dh Character.id.DSAMUS;  dh 7
    db 0, 0, 0, 0; dh Character.id.MTWO;    dh 7
    db 0, 0, 0, 0; dh Character.id.SHEIK;   dh 6
    db 0, 0, 0, 0; dh Character.id.PEPPY;   dh 5
    db 0, 0, 0, 0; dh -1;                   dh 0 // Dummy (indicates last entry)

    // @ Description
    // This switches Kirby's hat back to the magic hat when special ends
    scope restore_magic_hat_: {
        OS.patch_start(0x62744, 0x800E6F44)
        jal     restore_magic_hat_
        lw      s1, 0x0084(a0)              // original line 1 - s1 = player struct
        OS.patch_end()

        lw      t7, 0x0008(s1)              // t7 = character id
        lli     t8, Character.id.KIRBY      // t8 = id.KIRBY
        beq     t7, t8, _kirby              // branch if character = KIRBY
        lli     t8, Character.id.JKIRBY     // t8 = id.JKIRBY
        bne     t7, t8, _end                // skip if character != JKIRBY
        nop

        _kirby:
        li      t7, KirbyHats.magic_hat_on  // pointer to magic_hat_on flag
        lbu     t9, 0x000D(s1)              // t9 = port
        sll     t9, t9, 0x0002              // t9 = offset to port
        addu    t6, t7, t9                  // t6 = address of magic_hat_on
        lw      t6, 0x0000(t6)              // t6 = magic_hat_on
        beqz    t6, _end                    // if not on, skip
        nop

        _check_hat:
        lbu     t7, 0x0980(s1)              // t7 = Kirby Hat ID
        lli     t9, 0x0025                  // t9 = Magician Hat ID
        beq     t7, t9, _end                // skip if already magician hat
        lw      t0, 0x0094(sp)              // t0 = action ID

        // Check actions
        sltiu   t1, t0, Kirby.Action.GND_NSP_Ground // t1 = 0 if a new Kirby action
        beqz    t1, _end                    // if a new kirby action, don't restore magic hat
        sltiu   t1, t0, Action.KIRBY.MarioFireball // t1 = 1 if not a Vanilla Kirby action
        bnez    t1, _restore                // if not a NSP action, restore
        sltiu   t1, t0, Action.KIRBY.Staring1 // t1 = 1 if a Vanilla Kirby action
        bnez    t1, _end                    // if a vanilla kirby action, don't restore magic hat
        sltiu   t1, t0, Action.KIRBY.Lightning // t1 = 1 if not a Vanilla Kirby action
        bnez    t1, _restore                // if not a NSP action, restore
        sltiu   t1, t0, Action.KIRBY.FinalCutter // t1 = 1 if a Vanilla Kirby action
        bnez    t1, _end                    // if a vanilla kirby action, don't restore magic hat
        sltiu   t1, t0, Action.KIRBY.StoneStart // t1 = 1 if not a Vanilla Kirby action or DSP
        bnez    t1, _restore                // if not a NSP action, restore
        nop
        // Everything else is NSP (or DSP), so don't restore
        b       _end
        nop

        _restore:
        // if here, restore the magic hat, baby!
        OS.save_registers()
        or      a2, t9, r0                  // a2 = magician hat_id
        jal     0x800E8EAC                  // set part
        lli     a1, 0x0006                  // a1 = part ID (Kirby hat)

        jal     0x800E8ECC                  // swap part
        lw      a0, 0x0010(sp)              // a0 = player object

        // draw gfx on head
        lw      s1, 0x004C(sp)              // s1 = player struct
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      r0, 0x0010(sp)              // ~
        lui     t0, 0x4300                  // t0 = y offset
        sw      t0, 0x0014(sp)              // ~
        sw      r0, 0x0018(sp)              // establish origin points for x, y, and z
        lw      a0, 0x0900(s1)              // a0 = part 2 (Kirby's head/body)
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        addiu   a1, sp, 0x0010              // a1 = address to return x/y/z coordinates to

        addiu   a0, sp, 0x0010              // a0 = coords
        jal     0x8010066C                  // create spark gfx
        lui     a1, 0x3FA0                  // a1 = size multiplier
        addiu   sp, sp, 0x0020              // deallocate stack space
        OS.restore_registers()

        _end:
        jr      ra
        addiu   t8, sp, 0x0064              // original line 2
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
        lli     t8, Character.id.WOLF       // t8 = id.WOLF
        beq     t7, t8, _wolf_actions       // branch if copied power = WOLF
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

        _wolf_actions:
        // this block contains action swaps for Wolf's power
        clone_action(0xEB, Action.WOLF_NSP_Ground)
        clone_action(0xEC, Action.WOLF_NSP_Air)
        // if we reach this point then Kirby is not initializing a cloned action
        b       _end
        nop

        _end:
        j       _return
        sw      a1, 0x0094(sp)              // original line 2
    }

    // Modify grounded routine for Kirby
    Character.table_patch_start(grounded_script, Character.id.KIRBY, 0x4)
    dw clear_marth_flag_
    OS.patch_end()

    // @ Description
    // Jump table patch for which clears the pseudo-jump flag if Kirby is using the Marth hat.
    scope clear_marth_flag_: {
        lw      t0, 0x0ADC(v0)              // t0 = character id of copied power
        lli     at, Character.id.MARTH      // at = id.MARTH
        beql    at, t0, _end                // branch if copied character is Marth...
        sw      r0, 0x0AE0(v0)              // ...and clear pseudo-jump flag

        _end:
        j       0x800DE44C                  // return
        nop
    }
}