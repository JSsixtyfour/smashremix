// Piano.asm

// This file contains file inclusions, action edits, and assembly for Piano.

scope Piano {
    // Insert Moveset files
    insert WALK_1,"moveset/WALK_1.bin"
    insert WALK_2,"moveset/WALK_2.bin"
    insert DASH,"moveset/DASH.bin"
    insert RUN_LOOP,"moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP)                 // loops
    insert JUMP_1,"moveset/JUMP_1.bin"
    insert JUMP_2,"moveset/JUMP_2.bin"
    insert HARD_LANDING,"moveset/HARD_LANDING.bin"
    insert TEETER_START,"moveset/TEETER_START.bin"
    DMG_FGM_ARRAY_1:; dh 0x384; dh 0x385; OS.align(4)
    DMG_FGM_ARRAY_2:; dh 0x384; dh 0x385; dh 0x386; dh 0x387; dh 0x388; OS.align(4)
    DMG_1:; Moveset.RANDOM_SFX(25, 0x0, 0x2, DMG_FGM_ARRAY_1)   // play a random voice fx
    nop
    DMG_2:; Moveset.RANDOM_SFX(35, 0x0, 0x5, DMG_FGM_ARRAY_2)   // play a random voice fx
    nop
    DMG_3:; Moveset.RANDOM_SFX(50, 0x0, 0x5, DMG_FGM_ARRAY_2)   // play a random voice fx
    nop
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert TECH_STAND,"moveset/TECH_STAND.bin"
    insert FLOOR_ATTACK,"moveset/FLOOR_ATTACK.bin"
    insert CLIFF_ATTACK_QUICK,"moveset/CLIFF_ATTACK_QUICK.bin"
    insert CLIFF_ATTACK_SLOW,"moveset/CLIFF_ATTACK_SLOW.bin"
    insert CLIFF_ESCAPE_QUICK,"moveset/CLIFF_ESCAPE_QUICK.bin"
    insert CLIFF_ESCAPE_SLOW,"moveset/CLIFF_ESCAPE_SLOW.bin"
    insert ITEM_PICKUP,"moveset/ITEM_PICKUP.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP_CONCURRENT, "moveset/ASLEEP_CONCURRENT.bin"; Moveset.GO_TO(ASLEEP_CONCURRENT) // loops
    ASLEEP:; Moveset.CONCURRENT_STREAM(ASLEEP_CONCURRENT); insert "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP+0x8) // loops
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert GRAB_PULL,"moveset/GRAB_PULL.bin"
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert BTHROW_DATA, "moveset/BTHROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BTHROW.bin"
    insert JAB,"moveset/JAB.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT,"moveset/FTILT.bin"
    insert UTILT,"moveset/UTILT.bin"
    insert DTILT,"moveset/DTILT.bin"
    insert USMASH,"moveset/USMASH.bin"
    insert DSMASH,"moveset/DSMASH.bin"
    insert FSMASH,"moveset/FSMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert LANDING_DAIR,"moveset/LANDING_DAIR.bin"
    insert USP_TRAIL,"moveset/UP_SPECIAL_TRAIL.bin"
    USP:; Moveset.CONCURRENT_STREAM(USP_TRAIL); insert "moveset/UP_SPECIAL.bin"
    TAUNT_FGM_ARRAY:; dh 0x380; dh 0x381; dh 0x382; OS.align(4)
    TAUNT:; dw 0x08000005                           // wait 5 frames
    Moveset.RANDOM_SFX(100, 0x1, 0x3, TAUNT_FGM_ARRAY)   // play a random voice fx
    insert "moveset/TAUNT.bin"
    insert DSP_BEGIN, "moveset/DOWN_SPECIAL_BEGIN.bin"
    insert DSP_WAIT, "moveset/DOWN_SPECIAL_WAIT.bin"
    insert DSP_ABSORB, "moveset/DOWN_SPECIAL_ABSORB.bin"
    insert DSP_END, "moveset/DOWN_SPECIAL_END.bin"
    insert COMMAND_THROW_DATA, "moveset/COMMAND_THROW_DATA.bin"
    COMMAND_THROW:; Moveset.THROW_DATA(COMMAND_THROW_DATA); insert "moveset/COMMAND_THROW.bin"
    insert NSP, "moveset/NEUTRAL_SPECIAL.bin"
    insert ENTRY, "moveset/ENTRY.bin"
    insert VICTORY_1_CONCURRENT, "moveset/VICTORY_1_CONCURRENT.bin"; Moveset.GO_TO(VICTORY_1_CONCURRENT) // loops
    VICTORY_1:; Moveset.CONCURRENT_STREAM(VICTORY_1_CONCURRENT); insert "moveset/VICTORY_1.bin"; Moveset.GO_TO(VICTORY_1+0x8) // loops
    insert VICTORY_2, "moveset/VICTORY_2.bin"
    insert SELECT, "moveset/SELECT.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action                   // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(PIANO, Action.DeadU,               File.PIANO_TUMBLE,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.ScreenKO,            File.PIANO_TUMBLE,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.Entry,               File.PIANO_IDLE,            0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, 0x6,                        File.PIANO_IDLE,            -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Revive1,             File.PIANO_DOWN_BNCE_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Revive2,             File.PIANO_DOWN_STND_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ReviveWait,          File.PIANO_IDLE,            0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.Idle,                File.PIANO_IDLE,            0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.Walk1,               File.PIANO_WALK,            WALK_1,                     -1)
    Character.edit_action_parameters(PIANO, Action.Walk2,               File.PIANO_WALK,            WALK_2,                     -1)
    Character.edit_action_parameters(PIANO, Action.Walk3,               File.PIANO_WALK,            -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Dash,                File.PIANO_DASH,            DASH,                       -1)
    Character.edit_action_parameters(PIANO, Action.Run,                 File.PIANO_RUN,             RUN_LOOP,                   -1)
    Character.edit_action_parameters(PIANO, Action.RunBrake,            File.PIANO_RUN_BRAKE,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Turn,                File.PIANO_TURN,            -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.TurnRun,             File.PIANO_RUN_TURN,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.JumpSquat,           File.PIANO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ShieldJumpSquat,     File.PIANO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.JumpF,               File.PIANO_JUMP_F,          JUMP_1,                     -1)
    Character.edit_action_parameters(PIANO, Action.JumpB,               File.PIANO_JUMP_B,          JUMP_1,                     -1)
    Character.edit_action_parameters(PIANO, Action.JumpAerialF,         File.PIANO_JUMP_AERIAL_F,   JUMP_2,                     -1)
    Character.edit_action_parameters(PIANO, Action.JumpAerialB,         File.PIANO_JUMP_AERIAL_B,   JUMP_2,                     -1)
    Character.edit_action_parameters(PIANO, Action.Fall,                File.PIANO_FALL,            -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FallAerial,          File.PIANO_FALL_AERIAL,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Crouch,              File.PIANO_CROUCH_BEGIN,    -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CrouchIdle,          File.PIANO_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CrouchEnd,           File.PIANO_CROUCH_END,      -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.LandingLight,        File.PIANO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.LandingHeavy,        File.PIANO_LANDING,         HARD_LANDING,               -1)
    Character.edit_action_parameters(PIANO, Action.Pass,                File.PIANO_PLAT_DROP,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ShieldDrop,          File.PIANO_PLAT_DROP,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Teeter,              File.PIANO_TEETER,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.TeeterStart,         File.PIANO_TEETER_START,    TEETER_START,               -1)
    Character.edit_action_parameters(PIANO, Action.Teeter,              File.PIANO_TEETER,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.DamageHigh1,         File.PIANO_DMG_1,           DMG_1,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageHigh2,         File.PIANO_DMG_2,           DMG_2,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageHigh3,         File.PIANO_DMG_3,           DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageMid1,          File.PIANO_DMG_1,           DMG_1,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageMid2,          File.PIANO_DMG_2,           DMG_2,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageMid3,          File.PIANO_DMG_3,           DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageLow1,          File.PIANO_DMG_1,           DMG_1,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageLow2,          File.PIANO_DMG_2,           DMG_2,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageLow3,          File.PIANO_DMG_3,           DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageAir1,          File.PIANO_DMG_1,           DMG_1,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageAir2,          File.PIANO_DMG_2,           DMG_2,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageAir3,          File.PIANO_DMG_3,           DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageElec1,         File.PIANO_DMG_ELEC,        0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.DamageElec2,         File.PIANO_DMG_ELEC,        0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.DamageFlyHigh,       File.PIANO_DMG_FLY,         DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageFlyMid,        File.PIANO_DMG_FLY,         DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageFlyLow,        File.PIANO_DMG_FLY,         DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageFlyTop,        File.PIANO_DMG_FLY_TOP,     DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.DamageFlyRoll,       File.PIANO_DMG_FLY_ROLL,    DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.WallBounce,          File.PIANO_TUMBLE,          DMG_3,                      -1)
    Character.edit_action_parameters(PIANO, Action.Tumble,              File.PIANO_TUMBLE,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.FallSpecial,         File.PIANO_FALL_SPECIAL,    -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.LandingSpecial,      File.PIANO_LANDING,         HARD_LANDING,               -1)
    Character.edit_action_parameters(PIANO, Action.Tornado,             File.PIANO_TUMBLE,          0x80000000,                 -1)
    Character.edit_action_parameters(PIANO, Action.EnterPipe,           File.PIANO_PIPE_ENTER,      -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ExitPipe,            File.PIANO_PIPE_EXIT,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ExitPipeWalk,        File.PIANO_PIPE_EXIT_WALK,  -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CeilingBonk,         File.PIANO_CEILING_BONK,    -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownBounceD,         File.PIANO_DOWN_BNCE_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownBounceU,         File.PIANO_DOWN_BNCE_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownStandD,          File.PIANO_DOWN_STND_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownStandU,          File.PIANO_DOWN_STND_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownForwardD,        File.PIANO_DOWN_FWRD_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.TechF,               File.PIANO_TECH_F,          TECH_ROLL,                  -1)
    Character.edit_action_parameters(PIANO, Action.TechB,               File.PIANO_TECH_B,          TECH_ROLL,                  -1)
    Character.edit_action_parameters(PIANO, Action.DownForwardU,        File.PIANO_DOWN_FWRD_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownBackD,           File.PIANO_DOWN_BACK_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownBackU,           File.PIANO_DOWN_BACK_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.DownAttackD,         File.PIANO_DOWN_ATTK_D,     FLOOR_ATTACK,               -1)
    Character.edit_action_parameters(PIANO, Action.DownAttackU,         File.PIANO_DOWN_ATTK_U,     FLOOR_ATTACK,               -1)
    Character.edit_action_parameters(PIANO, Action.Tech,                File.PIANO_TECH,            TECH_STAND,                 -1)
    Character.edit_action_parameters(PIANO, 0x53,                       File.PIANO_UNKNOWN_053,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffCatch,          File.PIANO_CLF_CATCH,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffWait,           File.PIANO_CLF_WAIT,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffQuick,          File.PIANO_CLF_QUICK,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffClimbQuick1,    File.PIANO_CLF_CLM_Q_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffClimbQuick2,    File.PIANO_CLF_CLM_Q_2,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffSlow,           File.PIANO_CLF_SLOW,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffClimbSlow1,     File.PIANO_CLF_CLM_S_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffClimbSlow2,     File.PIANO_CLF_CLM_S_2,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffAttackQuick1,   File.PIANO_CLF_CLM_Q_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffAttackQuick2,   File.PIANO_CLF_ATK_Q_2,     CLIFF_ATTACK_QUICK,         -1)
    Character.edit_action_parameters(PIANO, Action.CliffAttackSlow1,    File.PIANO_CLF_ATK_S_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffAttackSlow2,    File.PIANO_CLF_ATK_S_2,     CLIFF_ATTACK_SLOW,          -1)
    Character.edit_action_parameters(PIANO, Action.CliffEscapeQuick1,   File.PIANO_CLF_CLM_Q_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffEscapeQuick2,   File.PIANO_CLF_ESC_Q_2,     CLIFF_ESCAPE_QUICK,         -1)
    Character.edit_action_parameters(PIANO, Action.CliffEscapeSlow1,    File.PIANO_CLF_ESC_S_1,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.CliffEscapeSlow2,    File.PIANO_CLF_ESC_S_2,     CLIFF_ESCAPE_SLOW,          -1)
    Character.edit_action_parameters(PIANO, Action.LightItemPickup,     File.PIANO_L_ITM_PICKUP,    ITEM_PICKUP,                -1)
    Character.edit_action_parameters(PIANO, Action.HeavyItemPickup,     File.PIANO_HEAVY_ITM_PICKUP,-1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemDrop,            File.PIANO_ITM_DROP,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowDash,       File.PIANO_ITM_THROW_DASH,  -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowF,          File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowB,          File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowU,          File.PIANO_ITM_THROW_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowD,          File.PIANO_ITM_THROW_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowSmashF,     File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowSmashB,     File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowSmashU,     File.PIANO_ITM_THROW_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowSmashD,     File.PIANO_ITM_THROW_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirF,       File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirB,       File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirU,       File.PIANO_ITM_THROW_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirD,       File.PIANO_ITM_THROW_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirSmashF,  File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirSmashB,  File.PIANO_ITM_THROW_F,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirSmashU,  File.PIANO_ITM_THROW_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ItemThrowAirSmashD,  File.PIANO_ITM_THROW_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HeavyItemThrowF,     File.PIANO_HEAVY_ITM_THROW, -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HeavyItemThrowB,     File.PIANO_HEAVY_ITM_THROW, -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HeavyItemThrowSmashF,File.PIANO_HEAVY_ITM_THROW, -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HeavyItemThrowSmashB,File.PIANO_HEAVY_ITM_THROW, -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BeamSwordNeutral,    File.PIANO_ITM_NEUTRAL,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BeamSwordTilt,       File.PIANO_ITM_TILT,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BeamSwordSmash,      File.PIANO_ITM_SMASH,       -1,                         0x40000000)
    Character.edit_action_parameters(PIANO, Action.BeamSwordDash,       File.PIANO_ITM_DASH,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BatNeutral,          File.PIANO_ITM_NEUTRAL,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BatTilt,             File.PIANO_ITM_TILT,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.BatSmash,            File.PIANO_ITM_SMASH,       -1,                         0x40000000)
    Character.edit_action_parameters(PIANO, Action.BatDash,             File.PIANO_ITM_DASH,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FanNeutral,          File.PIANO_ITM_NEUTRAL,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FanTilt,             File.PIANO_ITM_TILT,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FanSmash,            File.PIANO_ITM_SMASH,       -1,                         0x40000000)
    Character.edit_action_parameters(PIANO, Action.FanDash,             File.PIANO_ITM_DASH,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StarRodNeutral,      File.PIANO_ITM_NEUTRAL,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StarRodTilt,         File.PIANO_ITM_TILT,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StarRodSmash,        File.PIANO_ITM_SMASH,       -1,                         0x40000000)
    Character.edit_action_parameters(PIANO, Action.StarRodDash,         File.PIANO_ITM_DASH,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.RayGunShoot,         File.PIANO_RAY_GUN,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.RayGunShootAir,      File.PIANO_RAY_GUN,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FireFlowerShoot,     File.PIANO_RAY_GUN,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FireFlowerShootAir,  File.PIANO_RAY_GUN,         -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerIdle,          File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerWalk,          File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerTurn,          File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerJumpSquat,     File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerAir,           File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.HammerLanding,       File.PIANO_HAMMER,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ShieldOn,            File.PIANO_SHIELD_ON,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ShieldOff,           File.PIANO_SHIELD_OFF,      -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.RollF,               File.PIANO_ROLL_F,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.RollB,               File.PIANO_ROLL_B,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ShieldBreak,         File.PIANO_DMG_FLY_TOP,     SHIELD_BREAK,               -1)
    Character.edit_action_parameters(PIANO, Action.ShieldBreakFall,     File.PIANO_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StunLandD,           File.PIANO_DOWN_BNCE_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StunLandU,           File.PIANO_DOWN_BNCE_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StunStartD,          File.PIANO_DOWN_STND_D,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.StunStartU,          File.PIANO_DOWN_STND_U,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Stun,                File.PIANO_STUN,            STUN,                       -1)
    Character.edit_action_parameters(PIANO, Action.Sleep,               File.PIANO_STUN,            ASLEEP,                     -1)
    Character.edit_action_parameters(PIANO, Action.Grab,                File.PIANO_GRAB,            GRAB,                       -1)
    Character.edit_action_parameters(PIANO, Action.GrabPull,            File.PIANO_GRAB_PULL,       GRAB_PULL,                  -1)
    Character.edit_action_parameters(PIANO, Action.ThrowF,              File.PIANO_THROW_F,         FTHROW,                     -1)
    Character.edit_action_parameters(PIANO, Action.ThrowB,              File.PIANO_THROW_B,         BTHROW,                     0x50000000)
    Character.edit_action_parameters(PIANO, Action.CapturePulled,       File.PIANO_CAPTURE_PULLED,  -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.InhalePulled,        File.PIANO_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.InhaleSpat,          File.PIANO_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.InhaleCopied,        File.PIANO_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.EggLayPulled,        File.PIANO_CAPTURE_PULLED,  -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.EggLay,              File.PIANO_IDLE,            -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.FalconDivePulled,    File.PIANO_DMG_3,           -1,                         -1)
    Character.edit_action_parameters(PIANO, 0x0B4,                      File.PIANO_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ThrownDKPulled,      File.PIANO_THROWN_DK_PULLED,-1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ThrownMarioBros,     File.PIANO_THROWN_BROS,     -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.ThrownDK,            File.PIANO_THROWN_DK,       -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Thrown1,             File.PIANO_THROWN_1,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Thrown2,             File.PIANO_THROWN_2,        -1,                         -1)
    Character.edit_action_parameters(PIANO, Action.Taunt,               File.PIANO_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(PIANO, Action.Jab1,                File.PIANO_JAB,             JAB,                        0)
    Character.edit_action_parameters(PIANO, Action.Jab2,                0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.DashAttack,          File.PIANO_ATTACK_HEAVY,    DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(PIANO, Action.FTiltHigh,           0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FTiltMidHigh,        0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FTilt,               File.PIANO_FTILT,           FTILT,                      0)
    Character.edit_action_parameters(PIANO, Action.FTiltMidLow,         0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FTiltLow,            0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.UTilt,               File.PIANO_UTILT,           UTILT,                      0)
    Character.edit_action_parameters(PIANO, Action.DTilt,               File.PIANO_DTILT,           DTILT,                      0x40000000)
    Character.edit_action_parameters(PIANO, Action.FSmashHigh,          0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FSmashMidHigh,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FSmash,              File.PIANO_ATTACK_HEAVY,    FSMASH,                     0x40000000)
    Character.edit_action_parameters(PIANO, Action.FSmashMidLow,        0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.FSmashLow,           0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.USmash,              File.PIANO_USMASH,          USMASH,                     0)
    Character.edit_action_parameters(PIANO, Action.DSmash,              File.PIANO_DSMASH,          DSMASH,                     0)
    Character.edit_action_parameters(PIANO, Action.AttackAirN,          File.PIANO_NAIR,            NAIR,                       0)
    Character.edit_action_parameters(PIANO, Action.AttackAirF,          File.PIANO_FAIR,            FAIR,                       0)
    Character.edit_action_parameters(PIANO, Action.AttackAirB,          File.PIANO_BAIR,            BAIR,                       0)
    Character.edit_action_parameters(PIANO, Action.AttackAirU,          File.PIANO_UAIR,            UAIR,                       0)
    Character.edit_action_parameters(PIANO, Action.AttackAirD,          File.PIANO_DAIR,            DAIR,                       0)
    Character.edit_action_parameters(PIANO, Action.LandingAirX,         File.PIANO_LANDING,         -1,                         0)
    Character.edit_action_parameters(PIANO, Action.LandingAirN,         0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.LandingAirF,         0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.LandingAirB,         0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.LandingAirU,         0,                          0x80000000,                 0)
    Character.edit_action_parameters(PIANO, Action.LandingAirD,         File.PIANO_LANDING,         LANDING_DAIR,               0)
    Character.edit_action_parameters(PIANO, 0xDD,                       File.PIANO_ENTRY_R,         ENTRY,                      0x40000000)
    Character.edit_action_parameters(PIANO, 0xDE,                       File.PIANO_ENTRY_L,         ENTRY,                      0x40000000)
    Character.edit_action_parameters(PIANO, 0xDF,                       File.PIANO_NSP_G,           NSP,                        0)
    Character.edit_action_parameters(PIANO, 0xE0,                       File.PIANO_NSP_A,           NSP,                        0)
    Character.edit_action_parameters(PIANO, 0xE1,                       File.PIANO_USP,             USP,                        0)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(PIANO, 0xE0,              -1,             -1,                         -1,                             0x800D91EC,                     -1)
    Character.edit_action(PIANO, 0xE1,              -1,             PianoUSP.main_,             PianoUSP.change_direction_,     PianoUSP.physics_,              PianoUSP.collision_)


    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(PIANO,    0x0,                File.PIANO_IDLE,            0x80000000,                 -1)
    Character.edit_menu_action_parameters(PIANO,    0x1,                File.PIANO_VICTORY_1,       VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(PIANO,    0x2,                File.PIANO_VICTORY_2,       VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(PIANO,    0x3,                File.PIANO_STUN,            ASLEEP,                     -1)
    Character.edit_menu_action_parameters(PIANO,    0x4,                File.PIANO_SELECT,          SELECT,                     -1)
    Character.edit_menu_action_parameters(PIANO,    0x5,                File.PIANO_IDLE,            0x80000000,                 -1)
    Character.edit_menu_action_parameters(PIANO,    0x9,                File.PIANO_CONTINUE_FALL,   0x80000000,                 -1)
    Character.edit_menu_action_parameters(PIANO,    0xA,                File.PIANO_CONTINUE_UP,     0x80000000,                 -1)
    Character.edit_menu_action_parameters(PIANO,    0xD,                File.PIANO_POSE_1P,         0x80000000,                 -1)
    Character.edit_menu_action_parameters(PIANO,    0xE,                File.PIANO_1P_CPU_POSE,     0x80000000,                 -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(PIANO,  DSP_Ground_Begin,   -1,             File.PIANO_DSP_BEGIN_G,     DSP_BEGIN,                  -1)
    Character.add_new_action_params(PIANO,  DSP_Ground_Wait,    -1,             File.PIANO_DSP_WAIT,        DSP_WAIT,                   -1)
    Character.add_new_action_params(PIANO,  DSP_Ground_Absorb,  -1,             File.PIANO_DSP_ABSORB,      DSP_ABSORB,                 -1)
    Character.add_new_action_params(PIANO,  DSP_Ground_End,     -1,             File.PIANO_DSP_END_G,       DSP_END,                    -1)
    Character.add_new_action_params(PIANO,  DSP_Air_Begin,      -1,             File.PIANO_DSP_BEGIN_A,     DSP_BEGIN,                  -1)
    Character.add_new_action_params(PIANO,  DSP_Air_Wait,       -1,             File.PIANO_DSP_WAIT,        DSP_WAIT,                   -1)
    Character.add_new_action_params(PIANO,  DSP_Air_Absorb,     -1,             File.PIANO_DSP_ABSORB,      DSP_ABSORB,                 -1)
    Character.add_new_action_params(PIANO,  DSP_Air_End,        -1,             File.PIANO_DSP_END_A,       DSP_END,                    -1)
    Character.add_new_action_params(PIANO,  Ground_Cmd_Throw,   Action.ThrowF,  File.PIANO_DSP_THROW_G,     COMMAND_THROW,              -1)
    Character.add_new_action_params(PIANO,  Air_Cmd_Throw,      Action.ThrowF,  File.PIANO_DSP_THROW_A,     COMMAND_THROW,              -1)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(PIANO,  DSP_Ground_Begin,  -1,             ActionParams.DSP_Ground_Begin,      0x1E,           PianoDSP.ground_begin_main_,    PianoUSP.change_direction_,     0x800D8BB4,                         PianoDSP.ground_collision_)
    Character.add_new_action(PIANO,  DSP_Ground_Wait,   -1,             ActionParams.DSP_Ground_Wait,       0x1E,           PianoDSP.ground_wait_main_,     0,                              0x800D8BB4,                         PianoDSP.ground_collision_)
    Character.add_new_action(PIANO,  DSP_Ground_Absorb, -1,             ActionParams.DSP_Ground_Absorb,     0x1E,           PianoDSP.ground_absorb_main_,   0,                              0x800D8BB4,                         PianoDSP.ground_collision_)
    Character.add_new_action(PIANO,  DSP_Ground_End,    -1,             ActionParams.DSP_Ground_End,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         PianoDSP.ground_collision_)
    Character.add_new_action(PIANO,  DSP_Air_Begin,     -1,             ActionParams.DSP_Air_Begin,         0x1E,           PianoDSP.air_begin_main_,       PianoUSP.change_direction_,     0x800D90E0,                         PianoDSP.air_collision_)
    Character.add_new_action(PIANO,  DSP_Air_Wait,      -1,             ActionParams.DSP_Air_Wait,          0x1E,           PianoDSP.air_wait_main_,        0,                              0x800D90E0,                         PianoDSP.air_collision_)
    Character.add_new_action(PIANO,  DSP_Air_Absorb,    -1,             ActionParams.DSP_Air_Absorb,        0x1E,           PianoDSP.air_absorb_main_,      0,                              0x800D90E0,                         PianoDSP.air_collision_)
    Character.add_new_action(PIANO,  DSP_Air_End,       -1,             ActionParams.DSP_Air_End,           0x1E,           0x800D94E8,                     0,                              0x800D90E0,                         PianoDSP.air_collision_)
    Character.add_new_action(PIANO,  Ground_Cmd_Throw,  Action.ThrowF,  ActionParams.Ground_Cmd_Throw,      0x1E,           -1,                             PianoDSP.cmd_throw_hide_,       PianoDSP.cmd_throw_ground_physics_, PianoDSP.cmd_throw_ground_collision_)
    Character.add_new_action(PIANO,  Air_Cmd_Throw,     Action.ThrowF,  ActionParams.Air_Cmd_Throw,         0x1E,           -1,                             PianoDSP.cmd_throw_hide_,       0x800D90E0,                         PianoDSP.cmd_throw_air_collision_)

    // Set subroutines for special move initiations.
    Character.table_patch_start(ground_dsp, Character.id.PIANO, 0x4)
    dw      PianoDSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.PIANO, 0x4)
    dw      PianoDSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.PIANO, 0x4)
    dw      PianoUSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.PIANO, 0x4)
    dw      PianoUSP.initial_
    OS.patch_end()

    // Set the fireball jump table routines for Piano's book projectile.
    Character.table_patch_start(fireball, Character.id.PIANO, 0x4)
    dw      Fireball.Book.create_
    OS.patch_end()
    Character.table_patch_start(kirby_fireball, Character.id.PIANO, 0x4)
    dw      Fireball.Book.create_
    OS.patch_end()

    // Set Luigi as original character (not Mario, who PIANO is a clone of)
    Character.table_patch_start(variant_original, Character.id.PIANO, 0x4)
    dw      Character.id.LUIGI
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.PIANO, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.PIANO, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.PIANO, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.PIANO, 0x4)
    float32 1.1
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.PIANO, 0, 1, 2, 3, 1, 3, 4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(PIANO, BLACK, RED, YELLOW, CYAN, GREEN, WHITE, NA, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.PIANO, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby copy power and hat_id
    Character.table_patch_start(kirby_inhale_struct, Character.id.PIANO, 0xC)
    dh Character.id.PIANO
    dh 0x17
    OS.patch_end()

    // Set Yoshi Egg Size override ID, these values are just copied from DK
    Character.table_patch_start(yoshi_egg, Character.id.PIANO, 0x1C)
    dw  0x40600000
    dw  0x00000000
    dw  0x43660000
    dw  0x00000000
    dw  0x43750000
    dw  0x43750000
    dw  0x43750000
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.PIANO, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  12,   33,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  15,   45,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  15,   45,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  10,   38,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  8,    13,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  8,    15,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  10,   19,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,    11,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  12,   27,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  4,    9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,    31,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  26,   45,  50, 150, 200, 500) // todo: check if coords good
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  26,   45,  50, 150, 200, 500) // todo: check if coords good
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  3,    32,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  14,   47,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1, 14,    47,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  10,   33,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,    13,  -1, -1, -1, -1)

    // @ Description
    // Mad Piano's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        constant Book(0x0DF)
        constant BookAir(0x0E0)
        constant SuperJumpChomp(0x0E1)
        constant SuperJumpChompAir(0x0E2)
        //constant MarioTornado(0x0E3)
        //constant MarioTornadoAir(0x0E4)
        constant EatStart(0x0E5)
        constant EatLoop(0x0E6)
        constant Eat(0x0E7)
        constant EatEnd(0x0E8)
        constant EatStartAir(0x0E9)
        constant EatLoopAir(0x0EA)
        constant EatAir(0x0EB)
        constant EatEndAir(0x0EC)
        constant EatThrow(0x0ED)
        constant EatThrowAir(0x0EE)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("Appear1")
        //string_0x0DE:; String.insert("Appear2")
        string_0x0DF:; String.insert("Book")
        string_0x0E0:; String.insert("BookAir")
        string_0x0E1:; String.insert("SuperJumpChomp")
        string_0x0E2:; String.insert("SuperJumpChompAir")
        //string_0x0E3:; String.insert("MarioTornado")
        //string_0x0E4:; String.insert("MarioTornadoAir")
        string_0x0E5:; String.insert("EatStart")
        string_0x0E6:; String.insert("EatLoop")
        string_0x0E7:; String.insert("Eat")
        string_0x0E8:; String.insert("EatEnd")
        string_0x0E9:; String.insert("EatStartAir")
        string_0x0EA:; String.insert("EatLoopAir")
        string_0x0EB:; String.insert("EatAir")
        string_0x0EC:; String.insert("EatEndAir")
        string_0x0ED:; String.insert("EatThrow")
        string_0x0EE:; String.insert("EatThrowAir")

        action_string_table:
        dw 0 //dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw 0 //dw string_0x0E3
        dw 0 //dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.PIANO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // @ Description
    // Controls visibility for Piano's tongue and held item.
    scope extra_part_visibility_: {
        OS.patch_start(0x62A20, 0x800E7220)
        //ori     t6, t4, 0x0002            // replaced line 1
        //sb      t6, 0x0190(s1)            // replaced line 2
        jal     extra_part_visibility_
        nop
        OS.patch_end()

        // s1 = player struct
        ori     t6, t4, 0x0002            // original line 1
        sb      t6, 0x0190(s1)            // original line 2
        OS.save_registers()
        // check if the character is Piano
        lw      t0, 0x0008(s1)              // t0 = character id
        lli     t1, Character.id.PIANO      // t1 = id.PIANO
        bne     t0, t1, _end                // skip if character != PIANO
        nop

        // determine whether or not the Piano's tongue and item parts should be displayed
        lw      t8, 0x0024(s1)              // t8 = current action
        lli     t0, Action.Grab             // t0 = Action.Grab
        beq     t0, t8, _end                // show parts if action = Grab
        lli     t0, Action.GrabPull         // t0 = Action.GrabPull
        beq     t0, t8, _end                // show parts if action = GrabPull
        nop
        // every action from LightItemPickup to HammerLanding should display the tongue and item
        slti    t0, t8, Action.LightItemPickup // if (action < LightItemPickup)...
        bnez    t0, _hide_parts                // ...then hide parts
        nop
        slti    t0, t8, Action.HammerLanding + 0x1 // if (action is between LightItemPickup and HammerLanding)...
        bnez    t0, _end                       // ...then show parts
        nop


        _hide_parts:
        // if we reach this point, hide the tongue and item
        // disable the display item bitflag
        lbu     t0, 0x0190(s1)              // t0 = bit field
        andi    t0, t0, 0xFFFD              // t0 = bit field & bitmask (disables display item bitflag)
        sb      t0, 0x0190(s1)              // update bit field
        // begin a loop which will hide the tongue
        // this is loosely based on the loop at 0x800E912C
        _begin_loop:
        lli     s2, 0x000E                  // s2 = 0xE (first/current part)
        lli     s3, 0x0010                  // s3 = 0x10 (final part)
        addiu   sp, sp,-0x0030              // deallocate stack space

        _loop:
        // begin a loop which iterates through the three tongue parts, and sets them up to be
        // visually disabled and then reverted later
        sll     t0, s2, 0x2                 // t0 = offset (part number * 0x4)
        addu    t0, t0, s1                  // t0 = player struct + offset
        lw      s0, 0x08E8(t0)              // s0 = model part struct
        sll     t1, s2, 0x1                 // t1 = offset (part number * 0x2)
        addu    t1, t1, s1                  // t1 = player struct + offset
        addiu   t2, r0,-0x0001              // t2 = -1
        sb      t2, 0x0975(t1)              // set special part id to -1
        sw      s0, 0x0010(sp)              // ~
        sw      s1, 0x0014(sp)              // ~
        sw      s2, 0x0018(sp)              // ~
        sw      s3, 0x001C(sp)              // store s0-s3 (safety, probably not needed)
        // call 800091F4, which pushes a model part so that its display list can later be reverted
        jal     0x800091F4                  // push model part
        or      a0, s0, r0                  // a0 = model part struct
        lw      s0, 0x0010(sp)              // ~
        lw      s1, 0x0014(sp)              // ~
        lw      s2, 0x0018(sp)              // ~
        lw      s3, 0x001C(sp)              // load s0-s3 (safety, probably not needed)
        sw      r0, 0x0050(s0)              // clear display list for pushed model part
        bne     s2, s3, _loop               // loop if current part number != final part number
        addiu   s2, s2, 0x0001              // increment current part number

        _exit_loop:
        addiu   sp, sp, 0x0030              // allocate stack space
        // finally, enable a bitflag which will cause model parts to be reverted on the next action change
        lbu     t0, 0x018C(s1)              // t0 = bit field
        ori     t0, t0, 0x0010              // t0 = bit field | bitmask (enables revert model parts bitflag)
        sb      t0, 0x018C(s1)              // update bit field


        _end:
        OS.restore_registers()
        jr      ra                          // return
        lbu     t6, 0x0190(s1)              // refresh t6
    }

}
