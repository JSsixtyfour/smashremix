// Mewtwo.asm

// This file contains file inclusions, action edits, and assembly for Mewtwo.

scope Mewtwo {
    // Insert Moveset files
    insert RUN_LOOP,"moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP)                 // loops
    insert RUN_TURN,"moveset/RUN_TURN.bin"
    insert JUMP_1, "moveset/JUMP_1.bin"
    insert JUMP_2, "moveset/JUMP_2.bin"

    insert DOWN_BOUNCE, "moveset/DOWN_BOUNCE.bin"
    insert DOWN_ATTACK_D, "moveset/DOWN_ATTACK_D.bin"
    insert DOWN_ATTACK_U, "moveset/DOWN_ATTACK_U.bin"
    insert EDGE_GRAB, "moveset/EDGE_GRAB.bin"
    insert EDGE_WAIT, "moveset/EDGE_WAIT.bin"
    insert EDGE_ATTACK_QUICK_2, "moveset/EDGE_ATTACK_QUICK_2.bin"
    insert EDGE_ATTACK_SLOW_2, "moveset/EDGE_ATTACK_SLOW_2.bin"

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert TECH,"moveset/TECH.bin"

    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert GRAB_PULL,"moveset/GRAB_PULL.bin"
    insert THROW_CONCURRENT,"moveset/THROW_CONCURRENT.bin"
    insert FTHROW_DATA,"moveset/FORWARD_THROW_DATA.bin"
    FTHROW:; Moveset.CONCURRENT_STREAM(THROW_CONCURRENT); Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FORWARD_THROW.bin"
    insert BTHROW_DATA,"moveset/BACK_THROW_DATA.bin"
    BTHROW:; Moveset.CONCURRENT_STREAM(THROW_CONCURRENT); Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BACK_THROW.bin"
    insert ITEM_SHOOT,"moveset/ITEM_SHOOT.bin"

    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_LOOP_START,"moveset/JAB_LOOP_START.bin"
    insert JAB_LOOP, "moveset/JAB_LOOP.bin"; Moveset.GO_TO(JAB_LOOP) // loops
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_LOW.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH_HI,"moveset/FORWARD_SMASH_HIGH.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert FSMASH_LO,"moveset/FORWARD_SMASH_LOW.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"

    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NAIR_LANDING,"moveset/NEUTRAL_AERIAL_LANDING.bin"
    insert FAIR_LANDING,"moveset/FORWARD_AERIAL_LANDING.bin"

    insert NSPG_BEGIN,"moveset/NSPG_BEGIN.bin"
    insert NSPG_CHARGE, "moveset/NSPG_CHARGE.bin"
    insert NSP_CHARGE_LOOP, "moveset/NSP_CHARGE_LOOP.bin"; Moveset.GO_TO(NSP_CHARGE_LOOP) // loops
    insert NSPA_CHARGE, "moveset/NSPA_CHARGE.bin"; Moveset.GO_TO(NSP_CHARGE_LOOP) // go to loop
    insert NSPG_SHOOT,"moveset/NSPG_SHOOT.bin"
    insert NSPA_BEGIN,"moveset/NSPA_BEGIN.bin"
    insert NSPA_SHOOT,"moveset/NSPA_SHOOT.bin"
    insert USP_BEGIN,"moveset/USP_BEGIN.bin"
    insert USP_END,"moveset/USP_END.bin"
    insert DSP,"moveset/DSP.bin"

    insert ENTRY,"moveset/ENTRY.bin"
    insert VICTORY_1,"moveset/VICTORY_1.bin"
    insert VICTORY_2,"moveset/VICTORY_2.bin"
    insert VICTORY_3,"moveset/VICTORY_3.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action                   // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(MTWO,  Action.DeadU,               File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ScreenKO,            File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Entry,               File.MTWO_IDLE,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  0x006,                      File.MTWO_IDLE,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Revive1,             File.MTWO_DOWN_BNCE_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Revive2,             File.MTWO_DOWN_STND_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ReviveWait,          File.MTWO_IDLE,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Idle,                File.MTWO_IDLE,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Walk1,               File.MTWO_WALK_1,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Walk2,               File.MTWO_WALK_2,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Walk3,               File.MTWO_WALK_3,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  0x00E,                      File.MTWO_WALK_END,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Dash,                File.MTWO_DASH,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Run,                 File.MTWO_RUN,              RUN_LOOP,                   0x00000000)
    Character.edit_action_parameters(MTWO,  Action.RunBrake,            File.MTWO_RUN_BRAKE,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Turn,                File.MTWO_TURN,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.TurnRun,             File.MTWO_TURN_RUN,         RUN_TURN,                   0x40000000)
    Character.edit_action_parameters(MTWO,  Action.JumpSquat,           File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldJumpSquat,     File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.JumpF,               File.MTWO_JUMP_F,           JUMP_1,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.JumpB,               File.MTWO_JUMP_B,           JUMP_1,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.JumpAerialF,         File.MTWO_JUMP_AERIAL_F,    JUMP_2,                     0x40000000)
    Character.edit_action_parameters(MTWO,  Action.JumpAerialB,         File.MTWO_JUMP_AERIAL_B,    JUMP_2,                     0x40000000)
    Character.edit_action_parameters(MTWO,  Action.Fall,                File.MTWO_FALL,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FallAerial,          File.MTWO_FALL_AERIAL,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Crouch,              File.MTWO_CROUCH_BEGIN,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.CrouchIdle,          File.MTWO_CROUCH_IDLE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.CrouchEnd,           File.MTWO_CROUCH_END,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingLight,        File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingHeavy,        File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Pass,                File.MTWO_PLAT_DROP,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldDrop,          File.MTWO_PLAT_DROP,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Teeter,              File.MTWO_TEETER,           0x80000000,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.TeeterStart,         File.MTWO_TEETER_START,     0x80000000,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageHigh1,         File.MTWO_DMG_HIGH_1,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageHigh2,         File.MTWO_DMG_HIGH_2,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageHigh3,         File.MTWO_DMG_HIGH_3,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageMid1,          File.MTWO_DMG_MID_1,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageMid2,          File.MTWO_DMG_MID_2,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageMid3,          File.MTWO_DMG_MID_3,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageLow1,          File.MTWO_DMG_LOW_1,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageLow2,          File.MTWO_DMG_LOW_2,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageLow3,          File.MTWO_DMG_LOW_3,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageAir1,          File.MTWO_DMG_AIR_1,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageAir2,          File.MTWO_DMG_AIR_2,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageAir3,          File.MTWO_DMG_AIR_3,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageElec1,         File.MTWO_DMG_ELEC,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageElec2,         File.MTWO_DMG_ELEC,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageFlyHigh,       File.MTWO_DMG_FLY_HIGH,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageFlyMid,        File.MTWO_DMG_FLY_MID,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageFlyLow,        File.MTWO_DMG_FLY_LOW,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageFlyTop,        File.MTWO_DMG_FLY_TOP,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DamageFlyRoll,       File.MTWO_DMG_FLY_ROLL,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.WallBounce,          File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Tumble,              File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FallSpecial,         File.MTWO_FALL_SPECIAL,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingSpecial,      File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Tornado,             File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.EnterPipe,           File.MTWO_ENTER_PIPE,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ExitPipe,            File.MTWO_EXIT_PIPE,        -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ExitPipeWalk,        File.MTWO_EXIT_PIPE_WALK,   -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.CeilingBonk,         File.MTWO_CEILING_BONK,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DownBounceD,         File.MTWO_DOWN_BNCE_D,      DOWN_BOUNCE,                0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DownBounceU,         File.MTWO_DOWN_BNCE_U,      DOWN_BOUNCE,                0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DownStandD,          File.MTWO_DOWN_STND_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DownStandU,          File.MTWO_DOWN_STND_U,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.TechF,               File.MTWO_TECH_F,           TECH_ROLL,                  0x40000000)
    Character.edit_action_parameters(MTWO,  Action.TechB,               File.MTWO_TECH_B,           TECH_ROLL,                  0x40000000)
    Character.edit_action_parameters(MTWO,  Action.DownForwardD,        File.MTWO_DOWN_FWRD_D,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.DownForwardU,        File.MTWO_DOWN_FWRD_U,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.DownBackD,           File.MTWO_DOWN_BACK_D,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.DownBackU,           File.MTWO_DOWN_BACK_U,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.DownAttackD,         File.MTWO_DOWN_ATTK_D,      DOWN_ATTACK_D,              0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DownAttackU,         File.MTWO_DOWN_ATTK_U,      DOWN_ATTACK_U,              0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Tech,                File.MTWO_TECH,             TECH,                       0x00000000)
    Character.edit_action_parameters(MTWO,  0x053,                      File.MTWO_UNKNOWN_053,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.CliffCatch,          File.MTWO_CLF_CATCH,        EDGE_GRAB,                  0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffWait,           File.MTWO_CLF_WAIT,         EDGE_WAIT,                  0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffQuick,          File.MTWO_CLF_QUICK,        -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffClimbQuick1,    File.MTWO_CLF_CLM_Q_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffClimbQuick2,    File.MTWO_CLF_CLM_Q_2,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffSlow,           File.MTWO_CLF_SLOW,         -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffClimbSlow1,     File.MTWO_CLF_CLM_S_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffClimbSlow2,     File.MTWO_CLF_CLM_S_2,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffAttackQuick1,   File.MTWO_CLF_ATK_Q_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffAttackQuick2,   File.MTWO_CLF_ATK_Q_2,      EDGE_ATTACK_QUICK_2,        0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffAttackSlow1,    File.MTWO_CLF_ATK_S_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffAttackSlow2,    File.MTWO_CLF_ATK_S_2,      EDGE_ATTACK_SLOW_2,         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffEscapeQuick1,   File.MTWO_CLF_ESC_Q_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffEscapeQuick2,   File.MTWO_CLF_ESC_Q_2,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffEscapeSlow1,    File.MTWO_CLF_ESC_S_1,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.CliffEscapeSlow2,    File.MTWO_CLF_ESC_S_2,      -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.LightItemPickup,     File.MTWO_L_ITM_PICKUP,     -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HeavyItemPickup,     File.MTWO_H_ITM_PICKUP,     -1,                         0x10000000)
    Character.edit_action_parameters(MTWO,  Action.ItemDrop,            File.MTWO_ITM_DROP,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowDash,       File.MTWO_ITM_THROW_DASH,   -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowF,          File.MTWO_ITM_THROW_F,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowB,          File.MTWO_ITM_THROW_F,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowU,          File.MTWO_ITM_THROW_U,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowD,          File.MTWO_ITM_THROW_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowSmashF,     File.MTWO_ITM_THROW_F,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowSmashB,     File.MTWO_ITM_THROW_F,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowSmashU,     File.MTWO_ITM_THROW_U,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowSmashD,     File.MTWO_ITM_THROW_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirF,       File.MTWO_ITM_THROW_AIR_F,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirB,       File.MTWO_ITM_THROW_AIR_F,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirU,       File.MTWO_ITM_THROW_AIR_U,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirD,       File.MTWO_ITM_THROW_AIR_D,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirSmashF,  File.MTWO_ITM_THROW_AIR_F,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirSmashB,  File.MTWO_ITM_THROW_AIR_F,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirSmashU,  File.MTWO_ITM_THROW_AIR_U,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ItemThrowAirSmashD,  File.MTWO_ITM_THROW_AIR_D,  -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HeavyItemThrowF,     File.MTWO_HEAVY_ITM_THROW,  -1,                         0x10000000)
    Character.edit_action_parameters(MTWO,  Action.HeavyItemThrowB,     File.MTWO_HEAVY_ITM_THROW,  -1,                         0x10000000)
    Character.edit_action_parameters(MTWO,  Action.HeavyItemThrowSmashF,File.MTWO_HEAVY_ITM_THROW,  -1,                         0x10000000)
    Character.edit_action_parameters(MTWO,  Action.HeavyItemThrowSmashB,File.MTWO_HEAVY_ITM_THROW,  -1,                         0x10000000)
    Character.edit_action_parameters(MTWO,  Action.BeamSwordNeutral,    File.MTWO_ITM_NEUTRAL,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.BeamSwordTilt,       File.MTWO_ITM_TILT,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.BeamSwordSmash,      File.MTWO_ITM_SMASH,        -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.BeamSwordDash,       File.MTWO_ITM_DASH,         -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.BatNeutral,          File.MTWO_ITM_NEUTRAL,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.BatTilt,             File.MTWO_ITM_TILT,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.BatSmash,            File.MTWO_ITM_SMASH,        -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.BatDash,             File.MTWO_ITM_DASH,         -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.FanNeutral,          File.MTWO_ITM_NEUTRAL,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FanTilt,             File.MTWO_ITM_TILT,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FanSmash,            File.MTWO_ITM_SMASH,        -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.FanDash,             File.MTWO_ITM_DASH,         -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.StarRodNeutral,      File.MTWO_ITM_NEUTRAL,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StarRodTilt,         File.MTWO_ITM_TILT,         -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StarRodSmash,        File.MTWO_ITM_SMASH,        -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.StarRodDash,         File.MTWO_ITM_DASH,         -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.RayGunShoot,         File.MTWO_ITM_SHOOT,        ITEM_SHOOT,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.RayGunShootAir,      File.MTWO_ITM_SHOOT_AIR,    ITEM_SHOOT,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FireFlowerShoot,     File.MTWO_ITM_SHOOT,        ITEM_SHOOT,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FireFlowerShootAir,  File.MTWO_ITM_SHOOT_AIR,    ITEM_SHOOT,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerIdle,          File.MTWO_HAMMER_IDLE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerWalk,          File.MTWO_HAMMER_MOVE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerTurn,          File.MTWO_HAMMER_MOVE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerJumpSquat,     File.MTWO_HAMMER_MOVE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerAir,           File.MTWO_HAMMER_MOVE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.HammerLanding,       File.MTWO_HAMMER_MOVE,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldOn,            File.MTWO_SHIELD_ON,        -1,                         0xA0000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldOff,           File.MTWO_SHIELD_OFF,       -1,                         0xA0000000)
    Character.edit_action_parameters(MTWO,  Action.RollF,               File.MTWO_ROLL_F,           -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.RollB,               File.MTWO_ROLL_B,           -1,                         0x40000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldBreak,         File.MTWO_DMG_FLY_TOP,      SHIELD_BREAK,               0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ShieldBreakFall,     File.MTWO_TUMBLE,           SPARKLE,                    0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StunLandD,           File.MTWO_DOWN_BNCE_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StunLandU,           File.MTWO_DOWN_BNCE_U,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StunStartD,          File.MTWO_DOWN_STND_D,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.StunStartU,          File.MTWO_DOWN_STND_U,      -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Stun,                File.MTWO_STUN,             STUN,                       0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Sleep,               File.MTWO_STUN,             ASLEEP,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Grab,                File.MTWO_CATCH,            GRAB,                       0x10000000)
    Character.edit_action_parameters(MTWO,  Action.GrabPull,            File.MTWO_CATCH_PULL,       GRAB_PULL,                  0x10000000)
    Character.edit_action_parameters(MTWO,  Action.ThrowF,              File.MTWO_THROW_F,          FTHROW,                     0x10000000)
    Character.edit_action_parameters(MTWO,  Action.ThrowB,              File.MTWO_THROW_B,          BTHROW,                     0x10000000)
    Character.edit_action_parameters(MTWO,  Action.CapturePulled,       File.MTWO_CAPTURE_PULLED,   -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.InhalePulled,        File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.InhaleSpat,          File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.InhaleCopied,        File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.EggLayPulled,        File.MTWO_CAPTURE_PULLED,   -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.EggLay,              File.MTWO_IDLE,             -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FalconDivePulled,    File.MTWO_DMG_HIGH_3,       -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  0x0B4,                      File.MTWO_TUMBLE,           -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.ThrownDKPulled,      File.MTWO_THROWN_DK_PULLED, -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.ThrownMarioBros,     File.MTWO_THROWN_BROS,      -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.ThrownDK,            File.MTWO_THROWN_DK,        -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.Thrown1,             File.MTWO_THROWN_1,         -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.Thrown2,             File.MTWO_THROWN_2,         -1,                         0x80000000)
    Character.edit_action_parameters(MTWO,  Action.Taunt,               File.MTWO_TAUNT,            TAUNT,                      0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Jab1,                File.MTWO_JAB_1,            JAB_1,                      0x00000000)
    Character.edit_action_parameters(MTWO,  Action.Jab2,                0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DashAttack,          File.MTWO_DASH_ATTACK,      DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(MTWO,  Action.FTiltHigh,           File.MTWO_FTILT_HIGH,       FTILT_HI,                   0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FTilt,               File.MTWO_FTILT,            FTILT,                      0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FTiltLow,            File.MTWO_FTILT_LOW,        FTILT_LO,                   0x00000000)
    Character.edit_action_parameters(MTWO,  Action.UTilt,               File.MTWO_UTILT,            UTILT,                      0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DTilt,               File.MTWO_DTILT,            DTILT,                      0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FSmashHigh,          File.MTWO_FSMASH_HIGH,      FSMASH_HI,                  0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FSmash,              File.MTWO_FSMASH,           FSMASH,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.FSmashLow,           File.MTWO_FSMASH_LOW,       FSMASH_LO,                  0x00000000)
    Character.edit_action_parameters(MTWO,  Action.USmash,              File.MTWO_USMASH,           USMASH,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.DSmash,              File.MTWO_DSMASH,           DSMASH,                     0x00000000)
    Character.edit_action_parameters(MTWO,  Action.AttackAirN,          File.MTWO_ATTACK_AIR_N,     NAIR,                       0x00000000)
    Character.edit_action_parameters(MTWO,  Action.AttackAirF,          File.MTWO_ATTACK_AIR_F,     FAIR,                       0x10000000)
    Character.edit_action_parameters(MTWO,  Action.AttackAirB,          File.MTWO_ATTACK_AIR_B,     BAIR,                       0x00000000)
    Character.edit_action_parameters(MTWO,  Action.AttackAirU,          File.MTWO_ATTACK_AIR_U,     UAIR,                       0x00000000)
    Character.edit_action_parameters(MTWO,  Action.AttackAirD,          File.MTWO_ATTACK_AIR_D,     DAIR,                       0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirN,         File.MTWO_LANDING_AIR_N,    NAIR_LANDING,               0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirF,         File.MTWO_LANDING_AIR_F,    FAIR_LANDING,               0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirB,         File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirU,         File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirD,         File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  Action.LandingAirX,         File.MTWO_LANDING,          -1,                         0x00000000)
    Character.edit_action_parameters(MTWO,  0xDC,                       File.MTWO_ENTRY_R,          ENTRY,                      0x40000000)
    Character.edit_action_parameters(MTWO,  0xDD,                       File.MTWO_ENTRY_L,          ENTRY,                      0x40000000)
    Character.edit_action_parameters(MTWO,  0xDE,                       File.MTWO_NSPG_BEGIN,       NSPG_BEGIN,                 0x10000000)
    Character.edit_action_parameters(MTWO,  0xDF,                       File.MTWO_NSPG_CHARGE,      NSPG_CHARGE,                0x10000000)
    Character.edit_action_parameters(MTWO,  0xE0,                       File.MTWO_NSPG_SHOOT,       NSPG_SHOOT,                 0x10000000)
    Character.edit_action_parameters(MTWO,  0xE1,                       File.MTWO_NSPA_BEGIN,       NSPA_BEGIN,                 0x10000000)
    Character.edit_action_parameters(MTWO,  0xE2,                       File.MTWO_NSPA_CHARGE,      NSPA_CHARGE,                0x10000000)
    Character.edit_action_parameters(MTWO,  0xE4,                       File.MTWO_NSPA_SHOOT,       NSPA_SHOOT,                 0x10000000)
    Character.edit_action_parameters(MTWO,  0xE5,                       File.MTWO_DSPG,             DSP,                        0x10000000)
    Character.edit_action_parameters(MTWO,  0xE6,                       File.MTWO_DSPA,             DSP,                        0x10000000)
    Character.edit_action_parameters(MTWO,  0xE7,                       File.MTWO_JAB_2,            JAB_LOOP_START,             0x00000000)
    Character.edit_action_parameters(MTWO,  0xE8,                       File.MTWO_JAB_2_LOOP,       JAB_LOOP,                   0x00000000)
    Character.edit_action_parameters(MTWO,  0xE9,                       File.MTWO_JAB_2_END,        0x80000000,                 0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                     // Interrupt/Other ASM              // Movement/Physics ASM         // Collision ASM
    Character.edit_action(MTWO, 0xDE,               0x12,             MewtwoNSP.begin_main_,        0x8015D464,                         0x800D8BB4,                     MewtwoNSP.ground_begin_collision_)  //NSP_Ground_Begin
    Character.edit_action(MTWO, 0xDF,               0x12,             MewtwoNSP.charge_main_,       MewtwoNSP.ground_charge_interrupt_, 0x800D8BB4,                     MewtwoNSP.ground_charge_collision_) //NSP_Ground_Charge
    Character.edit_action(MTWO, 0xE0,               0x12,             MewtwoNSP.shoot_main_,        0,                                  0x800D8BB4,                     MewtwoNSP.ground_shoot_collision_)  //NSP_Ground_Shoot
    Character.edit_action(MTWO, 0xE1,               0x12,             MewtwoNSP.begin_main_,        0x8015D464,                         0x800D90E0,                     MewtwoNSP.air_begin_collision_)     //NSP_Air_Begin
    Character.edit_action(MTWO, 0xE2,               0x12,             MewtwoNSP.charge_main_,       MewtwoNSP.air_charge_interrupt_,    0x800D91EC,                     MewtwoNSP.air_charge_collision_)    //NSP_Air_Charge
    Character.edit_action(MTWO, 0xE4,               0x12,             MewtwoNSP.shoot_main_,        0,                                  0x800D91EC,                     MewtwoNSP.air_shoot_collision_)     //NSP_Air_Shoot
    Character.edit_action(MTWO, 0xE5,               0x1E,             0x800D94C4,                   0,                                  0x800D8BB4,                     MewtwoDSP.ground_collision_)        //DSP_Ground
    Character.edit_action(MTWO, 0xE6,               0x1E,             0x800D94E8,                   0,                                  0x800D91EC,                     MewtwoDSP.air_collision_)           //DSP_Air
    Character.edit_action(MTWO, 0xE5,               0x1E,             0x800D94C4,                   0,                                  0x800D8BB4,                     MewtwoDSP.ground_collision_)        //DSP_Ground_Begin
    Character.edit_action(MTWO, 0xE6,               0x1E,             0x800D94E8,                   0,                                  0x800D91EC,                     MewtwoDSP.air_collision_)           //DSP_Air
    Character.edit_action(MTWO, 0xE7,               0x4,              0x8014F0D0,                   0,                                  0x800D8BB4,                     0x800DDF44)                         //RapidJabStart
    Character.edit_action(MTWO, 0xE8,               0x4,              0x8014F2A8,                   0x8014F388,                         0x800D8BB4,                     0x800DDF44)                         //RapidJabLoop
    Character.edit_action(MTWO, 0xE9,               0x4,              0x800D94C4,                   0,                                  0x800D8BB4,                     0x800DDF44)                         //RapidJabEnd

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(MTWO,   USP_Ground_Begin,   -1,             File.MTWO_USPG_BEGIN,       USP_BEGIN,                  0)
    Character.add_new_action_params(MTWO,   USP_Ground_End,     -1,             File.MTWO_USPG_END,         USP_END,                    0)
    Character.add_new_action_params(MTWO,   USP_Air_Begin,      -1,             File.MTWO_USPA_BEGIN,       USP_BEGIN,                  0)
    Character.add_new_action_params(MTWO,   USP_Air_End,        -1,             File.MTWO_USPA_END,         USP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(MTWO,   USP_Ground_Begin,  -1,             ActionParams.USP_Ground_Begin,      0x11,           MewtwoUSP.begin_main_,          0,                              0x800D8BB4,                         MewtwoUSP.ground_begin_collision_)
    Character.add_new_action(MTWO,   USP_Ground_Move,   -1,             -1,                                 0x11,           MewtwoUSP.move_main_,           0,                              MewtwoUSP.move_physics_,            MewtwoUSP.ground_move_collision_)
    Character.add_new_action(MTWO,   USP_Ground_End,    -1,             ActionParams.USP_Ground_End,        0x11,           MewtwoUSP.ground_end_main_,     0,                              0x800D8BB4,                         MewtwoUSP.end_collision_)
    Character.add_new_action(MTWO,   USP_Air_Begin,     -1,             ActionParams.USP_Air_Begin,         0x11,           MewtwoUSP.begin_main_,          0,                              0x800D91EC,                         MewtwoUSP.air_begin_collision_)
    Character.add_new_action(MTWO,   USP_Air_Move,      -1,             -1,                                 0x11,           MewtwoUSP.move_main_,           0,                              MewtwoUSP.move_physics_,            MewtwoUSP.air_move_collision_)
    Character.add_new_action(MTWO,   USP_Air_End,       -1,             ActionParams.USP_Air_End,           0x11,           MewtwoUSP.air_end_main_,        0,                              0x800D91EC,                         MewtwoUSP.end_collision_)

    // Modify Menu Action Parameters                // Action       // Animation                 // Moveset Data             // Flags
    Character.edit_menu_action_parameters(MTWO,     0x0,            File.MTWO_IDLE,             -1,                         -1)
    Character.edit_menu_action_parameters(MTWO,     0x1,            File.MTWO_VICTORY_1,        VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(MTWO,     0x2,            File.MTWO_VICTORY_2,        VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(MTWO,     0x3,            File.MTWO_VICTORY_3,        VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(MTWO,     0x4,            File.MTWO_VICTORY_2,        VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(MTWO,     0x5,            File.MTWO_CLAP,             0x80000000,                 -1)
    Character.edit_menu_action_parameters(MTWO,     0x9,            File.MTWO_CONTINUE_FALL,    0x80000000,                 -1)
    Character.edit_menu_action_parameters(MTWO,     0xA,            File.MTWO_CONTINUE_UP,      0x80000000,                 -1)
    Character.edit_menu_action_parameters(MTWO,     0xD,            File.MTWO_POSE_1P,          0x80000000,                 -1)
    Character.edit_menu_action_parameters(MTWO,     0xE,            File.MTWO_1P_CPU_POSE,      0x80000000,                 -1)

    // Set subroutines for special move initiations.
    Character.table_patch_start(ground_nsp, Character.id.MTWO, 0x4)
    dw      MewtwoNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.MTWO, 0x4)
    dw      MewtwoNSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.MTWO, 0x4)
    dw      MewtwoUSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MTWO, 0x4)
    dw      MewtwoUSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.MTWO, 0x4)
    dw      MewtwoDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MTWO, 0x4)
    dw      MewtwoDSP.air_initial_
    OS.patch_end()

    // Set subroutines for rapid jab actions.
    Character.table_patch_start(rapid_jab_begin_action, Character.id.MTWO, 0x4)
    dw      set_rapid_jab_begin_action_
    OS.patch_end()
    Character.table_patch_start(rapid_jab_loop_action, Character.id.MTWO, 0x4)
    dw      set_rapid_jab_loop_action_
    OS.patch_end()
    Character.table_patch_start(rapid_jab_ending_action, Character.id.MTWO, 0x4)
    dw      set_rapid_jab_ending_action_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.MTWO, 0x4)
    float32 0.9
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.MTWO, 0, 2, 3, 1, 2, 3, 1)
    Teams.add_team_costume(YELLOW, MTWO, 0x4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MTWO, PURPLE, GREEN, RED, BLUE, YELLOW, CYAN, NA, NA)

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.MTWO, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.MTWO, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MTWO, 0x2)
    dh 0x3B1
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MTWO, 0xC)
    dh 0x1B
    OS.patch_end()

    // Patches for full charge Neutral B effect.
    Character.table_patch_start(gfx_routine_end, Character.id.MTWO, 0x4)
    dw      charge_gfx_routine_
    OS.patch_end()
    Character.table_patch_start(initial_script, Character.id.MTWO, 0x4)
    dw      0x800D7DEC                      // use samus jump
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.MTWO, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.MTWO, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

	// Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.MTWO, 0x4)
    dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  8,   15,  -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  15,  20,  50,  100,  60,  200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  15,  20,  50,  100,  60,  200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  14,  21,  -20, -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,   9,   -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  6,   12,  -1,  -1,   -1,  -1)  // shared with bair
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  18,  25,  -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,   9,   -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,  -1,  -1,  -1,   -1,  -1)  // todo: check range
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  4,   6,   -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  5,   32,  -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  10,  15,  500, 1500, 200, 445) // copied from Samus
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  9,   14,  500, 1500, 200, 445) // copied from Samus
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   13,  -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   0x0D, 0,   0,   0,   0,    0,   0)   // prevent up special
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   0x0D, 0,   0,   0,   0,    0,   0)   // prevent up special
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  10,  41,  -1,  -1,   -1,  -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,   13,  -1,  -1,   -1,  -1)

    // @ Description
    // Bowser's extra actions
    scope Action {
        constant Appear1(0x0DC)
        constant Appear2(0x0DD)
        constant ShadowBallStart(0x0DE)
        constant ShadowBallCharge(0x0DF)
        constant ShadowBallShoot(0x0E0)
        constant ShadowBallStartAir(0x0E1)
        constant ShadowBallChargeAir(0x0E2)
        //constant x(0x0E3)
        constant ShadowBallShootAir(0x0E4)
        constant Disable(0x0E5)
        constant DisableAir(0x0E6)
        constant JabLoopStart(0x0E7)
        constant JabLoop(0x0E8)
        constant JabLoopEnd(0x0E9)
        constant TeleportStart(0x0EA)
        constant Teleport(0x0EB)
        constant TeleportEnd(0x0EC)
        constant TeleportStartAir(0x0ED)
        constant TeleportAir(0x0EE)
        constant TeleportEndAir(0x0EF)

        // strings!
        string_0x0DE:; String.insert("ShadowBallStart")
        string_0x0DF:; String.insert("ShadowBallCharge")
        string_0x0E0:; String.insert("ShadowBallShoot")
        string_0x0E1:; String.insert("ShadowBallStartAir")
        string_0x0E2:; String.insert("ShadowBallChargeAir")
        //string_0x0E3:; String.insert("x")
        string_0x0E4:; String.insert("ShadowBallShootAir")
        string_0x0E5:; String.insert("Disable")
        string_0x0E6:; String.insert("DisableAir")
        //string_0x0E7:; String.insert("JabLoopStart")
        //string_0x0E8:; String.insert("JabLoop")
        //string_0x0E9:; String.insert("JabLoopEnd")
        string_0x0EA:; String.insert("TeleportStart")
        string_0x0EB:; String.insert("Teleport")
        string_0x0EC:; String.insert("TeleportEnd")
        string_0x0ED:; String.insert("TeleportStartAir")
        string_0x0EE:; String.insert("TeleportAir")
        string_0x0EF:; String.insert("TeleportEndAir")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw 0 //dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
        dw string_0x0EF
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MTWO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.MTWO, 0x2)
    dh  0x006B
    OS.patch_end()

    // @ Description
    // Jump table patch which sets the rapid jab begin action.
    scope set_rapid_jab_begin_action_: {
        lli     t8, 0x00E7                  // t8 = rapid jab begin action id
        j       0x8014F174                  // return
        sw      t8, 0x0020(sp)              // store action id
    }

    // @ Description
    // Jump table patch which sets the rapid jab loop action.
    scope set_rapid_jab_loop_action_: {
        lli     t8, 0x00E8                  // t8 = rapid jab loop action id
        j       0x8014F42C                  // return
        sw      t8, 0x0020(sp)              // store action id
    }

    // @ Description
    // Jump table patch which sets the rapid jab ending action.
    scope set_rapid_jab_ending_action_: {
        lli     t8, 0x00E9                  // t8 = rapid jab ending action id
        j       0x8014F42C                  // return
        sw      t8, 0x0020(sp)              // store action id
    }

    // @ Description
    // Patch which initiates a rapid jab instead of jab 2 for Mewtwo.
    scope rapid_jab_patch_: {
        OS.patch_start(0xC9518, 0x8014EAD8)
        j   rapid_jab_patch_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0028              // original line 1
        sw      ra, 0x001C(sp)              // original line 2
        lw      t6, 0x0084(a0)              // ~
        lw      t6, 0x0008(t6)              // t6 = character ID
        lli     at, Character.id.MTWO       // at = id.MTWO
        beq     t6, at, _mewtwo             // branch if character = MTWO
        lli     at, Character.id.NMTWO       // at = id.NMTWO
        beq     t6, at, _mewtwo             // branch if character = NMTWO
        nop

        // if the character is not mewtwo
        j       _return                     // return and continue original subroutine
        nop

        _mewtwo:
        jal     0x8014F0F4                  // rapid jab initial subroutine
        nop
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // end subroutine
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Jump table patch which enables Mewtwo's charged neutral b effect when another gfx routine ends, or upon action change.
    scope charge_gfx_routine_: {
        lw      t9, 0x0ADC(a3)              // t9 = charge level
        lli     at, 0x0007                  // at = 7
        lw      a0, 0x0020(sp)              // a0 = player object
        bne     t9, at, _end                // skip if charge level != 7 (full)
        lli     a1, GFXRoutine.id.MEWTWO_CHARGE // a1 = MEWTWO_CHARGE id

        // if the neutral special is full charged
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3

        _end:
        j       0x800E9A60                  // return
        lw      a3, 0x001C(sp)              // load a3
    }

    // Originally, Mewtwo was intended to use a unique graphical effect for Up Smash. This was never finished.
//  // @ Description
//  // Modifies the standard Up Smash Main Routine so that Mewtwo can use his Up Smash GFX
//      OS.patch_start(0xA5608, 0x80129E08)
//      dw      custom_usmash_
//      OS.patch_end()
//
//      scope custom_usmash_: {
//      addiu   sp, sp, -0x0018
//      sw      ra, 0x0014(sp)
//      sw      a0, 0x000C(sp)
//      sw      a2, 0x0004(sp)
//      sw      v1, 0x0010(sp)
//      lw      at, 0x0008(a2)              // load character ID
//      lli     t0, Character.id.MTWO       // at = id.MTWO
//      bne     at, t0, _normal             // do normal routine if not Mewtwo
//      lw      at, 0x017C(a2)              // load moveset variable 1 (54000000)
//      beqz    at, _normal                 // if variable not active, do normal routine
//      sw      a0, 0x0018(sp)              // save a0 to stack
//      addiu   t0, r0, 0x0002
//      beq     at, t0, _end_graphics       // if at stage 2, end graphics
//      addu    v1, r0, a2                  // place player struct in v1
//      jal     0x80101F84                  // falcon punch animation struct routine
//      lw      a0, 0x0004(v1)              // load player object into a0
//      lw      v1, 0x0004(sp)
//      lbu     t1, 0x018F(v1)
//      ori     t2, t1, 0x0010
//      sb      t2, 0x018F(v1)              // this is done so that the GFX can be destroyed, this a bitfield related to the bone struct
//      beq     r0, r0, _normal
//      sw      r0, 0x017C(v1)
//
//      _end_graphics:
//      lw      v1, 0x0004(sp)              // load player struct
//      jal     0x800E9C3C                  // routine that ends graphics
//      lw      a0, 0x0004(v1)              // load player object into a0
//
//      _normal:
//      lw      v1, 0x0010(sp)
//      lw      a0, 0x000C(sp)
//      jal     0x800D94C4                  // original Up Smash Routine
//      lw      a2, 0x0004(sp)
//      lw      ra, 0x0014(sp)
//      addiu   sp, sp, 0x0018
//      jr      ra
//      nop
//  }
   }
