// NSheik.asm

// This file contains file inclusions, action edits, and assembly for Polygon Sheik.

scope NSheik {
    // Insert Moveset files
	OS.align(16)

    // Action name constants.
    scope Action {
        constant JAB_LOOP_START(0xDC)
        constant JAB_LOOP(0xDD)
        constant JAB_LOOP_END(0xDE)
        constant USPG_BEGIN(0xE4)
        constant USPG_MOVE(0xE5)
        constant USPG_END(0xE6)
        constant USPA_BEGIN(0xE7)
        constant USPA_MOVE(0xE8)
        constant USPA_END(0xE9)
        constant NSPG_BEGIN(0xEA)
        constant NSPG_CHARGE(0xEB)
        constant NSPG_SHOOT(0xEC)
        constant NSPA_BEGIN(0xED)
        constant NSPA_CHARGE(0xEE)
        constant NSPA_SHOOT(0xEF)
        constant DSP_BEGIN(0xF0)
        constant DSP_ATTACK(0xF1)
        constant DSP_LANDING(0xF2)
        constant DSP_RECOIL(0xF3)

    }

    // Modify Action Parameters             // Action                       // Animation                        // Moveset Data             // Flags
Character.edit_action_parameters(NSHEIK, Action.DeadU,                   File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ScreenKO,                File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Entry,                   File.SHEIK_IDLE,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, 0x006,                          File.SHEIK_IDLE,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Revive1,                 File.SHEIK_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Revive2,                 File.SHEIK_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ReviveWait,              File.SHEIK_IDLE,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Idle,                    File.SHEIK_IDLE,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Walk1,                   File.SHEIK_WALK_1,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Walk2,                   File.SHEIK_WALK_2,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Walk3,                   File.SHEIK_WALK_3,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Dash,                    File.SHEIK_DASH,                    Sheik.DASH,                       -1)
Character.edit_action_parameters(NSHEIK, Action.Run,                     File.SHEIK_RUN,                     Sheik.RUN,                        -1)
Character.edit_action_parameters(NSHEIK, Action.RunBrake,                File.SHEIK_RUN_BRAKE,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Turn,                    File.SHEIK_TURN,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.TurnRun,                 File.SHEIK_TURN_RUN,                Sheik.TURNRUN,                    -1)
Character.edit_action_parameters(NSHEIK, Action.JumpSquat,               File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ShieldJumpSquat,         File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.JumpF,                   File.SHEIK_JUMP_F,                  Sheik.JUMP,                       -1)
Character.edit_action_parameters(NSHEIK, Action.JumpB,                   File.SHEIK_JUMP_B,                  Sheik.JUMP,                       -1)
Character.edit_action_parameters(NSHEIK, Action.JumpAerialF,             File.SHEIK_JUMP_AERIAL_F,           Sheik.JUMP_AERIAL,                -1)
Character.edit_action_parameters(NSHEIK, Action.JumpAerialB,             File.SHEIK_JUMP_AERIAL_B,           Sheik.JUMP_AERIAL,                -1)
Character.edit_action_parameters(NSHEIK, Action.Fall,                    File.SHEIK_FALL,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FallAerial,              File.SHEIK_FALL_AERIAL,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Crouch,                  File.SHEIK_CROUCH,                  Sheik.CROUCH_START,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CrouchIdle,              File.SHEIK_CROUCH_IDLE,             Sheik.CROUCH_IDLE,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CrouchEnd,               File.SHEIK_CROUCH_END,              Sheik.CROUCH_END,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingLight,            File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingHeavy,            File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Teeter,                  File.SHEIK_TEETER,                  Sheik.TEETER,                     -1)
Character.edit_action_parameters(NSHEIK, Action.TeeterStart,             File.SHEIK_TEETER_START,            Sheik.TEETER_START,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageHigh1,             File.SHEIK_DAMAGE_HIGH_1,           -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageHigh2,             File.SHEIK_DAMAGE_HIGH_2,           -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageHigh3,             File.SHEIK_DAMAGE_HIGH_3,           -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageMid1,              File.SHEIK_DAMAGE_MID_1,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageMid2,              File.SHEIK_DAMAGE_MID_2,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageMid3,              File.SHEIK_DAMAGE_MID_3,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageLow1,              File.SHEIK_DAMAGE_LOW_1,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageLow2,              File.SHEIK_DAMAGE_LOW_2,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageLow3,              File.SHEIK_DAMAGE_LOW_3,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageAir1,              File.SHEIK_DAMAGE_AIR_1,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageAir2,              File.SHEIK_DAMAGE_AIR_2,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageAir3,              File.SHEIK_DAMAGE_AIR_3,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageFlyHigh,           File.SHEIK_DAMAGE_FLY_HIGH,         -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageFlyMid,            File.SHEIK_DAMAGE_FLY_MID,          -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageFlyLow,            File.SHEIK_DAMAGE_FLY_LOW,          -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageFlyTop,            File.SHEIK_DAMAGE_FLY_TOP,          -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.DamageFlyRoll,           File.SHEIK_DAMAGE_FLY_ROLL,         -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.Tumble,                  File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.WallBounce,              File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.FallSpecial,             File.SHEIK_FALL_SPECIAL,            -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.LandingSpecial,          File.SHEIK_LANDING,                 -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.Tornado,                 File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.EnterPipe,               File.SHEIK_ENTER_PIPE,              -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.ExitPipe,                File.SHEIK_EXIT_PIPE,               -1,                         -1)
 Character.edit_action_parameters(NSHEIK, Action.ExitPipeWalk,            File.SHEIK_EXIT_PIPE_WALK,          -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownBounceD,             File.SHEIK_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownBounceU,             File.SHEIK_DOWN_BOUNCE_U,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownStandD,              File.SHEIK_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownStandU,              File.SHEIK_DOWN_STAND_U,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.TechF,                   -1,                                Sheik.TECHROLL,                  -1)
Character.edit_action_parameters(NSHEIK, Action.TechB,                   -1,                                Sheik.TECHROLL,                  -1)
Character.edit_action_parameters(NSHEIK, Action.DownForwardD,            File.SHEIK_DOWN_FORWARD_D,          -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownForwardU,            File.SHEIK_DOWN_FORWARD_U,          -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownBackD,               File.SHEIK_DOWN_BACK_D,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownBackU,               File.SHEIK_DOWN_BACK_U,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownAttackD,             File.SHEIK_DOWN_ATTACK_D,           Sheik.FLOORATTACK_D,                         -1)
Character.edit_action_parameters(NSHEIK, Action.DownAttackU,             File.SHEIK_DOWN_ATTACK_U,           Sheik.FLOORATTACK_U,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Tech,                    File.SHEIK_TECH,                    Sheik.TECH,                       -1)
Character.edit_action_parameters(NSHEIK, Action.CliffQuick,              File.SHEIK_CLIFF_QUICK,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffClimbQuick1,        File.SHEIK_CLIFF_ATTACK_QUICK_1,     -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffClimbQuick2,        File.SHEIK_CLIFF_CLIMB_QUICK_2,     -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffSlow,               File.SHEIK_CLIFF_SLOW,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffClimbSlow1,         File.SHEIK_CLIFF_ATTACK_SLOW_1,      -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffClimbSlow2,         File.SHEIK_CLIFF_CLIMB_SLOW_2,      -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffAttackQuick1,       File.SHEIK_CLIFF_ATTACK_QUICK_1,    -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffAttackQuick2,       File.SHEIK_CLIFF_ATTACK_QUICK_2,    Sheik.CLIFF_ATTACK_QUICK_2,       -1)
Character.edit_action_parameters(NSHEIK, Action.CliffAttackSlow1,        File.SHEIK_CLIFF_ATTACK_SLOW_1,     -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.CliffAttackSlow2,        File.SHEIK_CLIFF_ATTACK_SLOW_2,     Sheik.CLIFF_ATTACK_SLOW_2,        -1)
Character.edit_action_parameters(NSHEIK, Action.CliffEscapeSlow1,        File.SHEIK_CLIFF_ATTACK_SLOW_1,     -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ItemThrowDash,           File.SHEIK_ITEM_THROW_DASH,         -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ItemThrowAirU,           File.SHEIK_ITEM_THROW_AIR_U,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ItemThrowAirSmashU,      File.SHEIK_ITEM_THROW_AIR_U,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BeamSwordNeutral,        File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BeamSwordTilt,           File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BeamSwordSmash,          File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BeamSwordDash,           File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BatNeutral,              File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BatTilt,                 File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BatSmash,                File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.BatDash,                 File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FanNeutral,              File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FanTilt,                 File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FanSmash,                File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FanDash,                 File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StarRodNeutral,          File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StarRodTilt,             File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StarRodSmash,            File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StarRodDash,             File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.RayGunShootAir,          File.SHEIK_ITEM_SHOOT_AIR,          -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.FireFlowerShootAir,      File.SHEIK_ITEM_SHOOT_AIR,          -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.HammerWalk,              File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.HammerTurn,              File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.HammerJumpSquat,         File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.HammerAir,               File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.HammerLanding,           File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ShieldOn,                File.SHEIK_SHIELD_ON,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ShieldOff,               File.SHEIK_SHIELD_OFF,              -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.RollF,                   File.SHEIK_ROLL_F,                  Sheik.ROLL_F,                         -1)
Character.edit_action_parameters(NSHEIK, Action.RollB,                   File.SHEIK_ROLL_B,                  Sheik.ROLL_B,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ShieldBreak,             -1,                                 Sheik.SHIELD_BREAK,               -1)
Character.edit_action_parameters(NSHEIK, Action.ShieldBreakFall,         File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StunLandD,               File.SHEIK_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StunLandU,               File.SHEIK_DOWN_BOUNCE_U,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StunStartD,              File.SHEIK_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.StunStartU,              File.SHEIK_DOWN_STAND_U,            -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Stun,                    File.SHEIK_STUN,                    Sheik.STUN,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Sleep,                   File.SHEIK_STUN,                    Sheik.ASLEEP,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Grab,                    File.SHEIK_GRAB,                    Sheik.GRAB,                       -1)
Character.edit_action_parameters(NSHEIK, Action.GrabPull,                File.SHEIK_GRAB_PULL,               -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.ThrowF,                  File.SHEIK_THROW_F,                 Sheik.THROW_F,                    -1)
Character.edit_action_parameters(NSHEIK, Action.ThrowB,                  File.SHEIK_THROW_B,                 Sheik.THROW_B,                    -1)
Character.edit_action_parameters(NSHEIK, Action.InhalePulled,            File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.InhaleSpat,              File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.InhaleCopied,            File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.EggLay,                  File.SHEIK_IDLE,                    -1,                         -1)
Character.edit_action_parameters(NSHEIK, 0x0B4,                          File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.Taunt,                   File.SHEIK_TAUNT,                   Sheik.TAUNT,                      -1)
Character.edit_action_parameters(NSHEIK, Action.Jab1,                    File.SHEIK_JAB_1,                   Sheik.JAB_1,                      -1)
Character.edit_action_parameters(NSHEIK, Action.Jab2,                    File.SHEIK_JAB_2,                   Sheik.JAB_2,                      -1)
Character.edit_action_parameters(NSHEIK, Action.JAB_LOOP_START,          File.SHEIK_JAB_LOOP_START,          Sheik.JAB_LOOP_START,             -1)
Character.edit_action_parameters(NSHEIK, Action.JAB_LOOP,                File.SHEIK_JAB_LOOP,                Sheik.JAB_LOOP,                   -1)
Character.edit_action_parameters(NSHEIK, Action.JAB_LOOP_END,            File.SHEIK_JAB_LOOP_END,            Sheik.JAB_LOOP_END,               -1)
Character.edit_action_parameters(NSHEIK, Action.DashAttack,              File.SHEIK_DASH_ATTACK,             Sheik.DASH_ATTACK,                -1)
Character.edit_action_parameters(NSHEIK, Action.FTiltHigh,               0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FTiltMidHigh,            0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FTilt,                   File.SHEIK_F_TILT,                  Sheik.F_TILT,                     -1)
Character.edit_action_parameters(NSHEIK, Action.FTiltMidLow,             0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FTiltLow,                0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.UTilt,                   File.SHEIK_U_TILT,                  Sheik.U_TILT,                     -1)
Character.edit_action_parameters(NSHEIK, Action.DTilt,                   File.SHEIK_D_TILT,                  Sheik.D_TILT,                     -1)
Character.edit_action_parameters(NSHEIK, Action.FSmashHigh,              0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FSmashMidHigh,           0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FSmash,                  File.SHEIK_F_SMASH,                 Sheik.F_SMASH,                    -1)
Character.edit_action_parameters(NSHEIK, Action.FSmashMidLow,            0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.FSmashLow,               0,                                  0x80000000,                 0)
Character.edit_action_parameters(NSHEIK, Action.USmash,                  File.SHEIK_U_SMASH,                 Sheik.U_SMASH,                    -1)
Character.edit_action_parameters(NSHEIK, Action.DSmash,                  File.SHEIK_D_SMASH,                 Sheik.D_SMASH,                    -1)
Character.edit_action_parameters(NSHEIK, Action.AttackAirN,              File.SHEIK_ATTACK_AIR_N,            Sheik.ATTACK_AIR_N,               -1)
Character.edit_action_parameters(NSHEIK, Action.AttackAirF,              File.SHEIK_ATTACK_AIR_F,            Sheik.ATTACK_AIR_F,               -1)
Character.edit_action_parameters(NSHEIK, Action.AttackAirB,              File.SHEIK_ATTACK_AIR_B,            Sheik.ATTACK_AIR_B,               -1)
Character.edit_action_parameters(NSHEIK, Action.AttackAirU,              File.SHEIK_ATTACK_AIR_U,            Sheik.ATTACK_AIR_U,               -1)
Character.edit_action_parameters(NSHEIK, Action.AttackAirD,              File.SHEIK_ATTACK_AIR_D,            Sheik.ATTACK_AIR_D,               -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirN,             File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirF,             File.SHEIK_LANDING_AIR_F,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirB,             File.SHEIK_LANDING_AIR_B,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirU,             File.SHEIK_LANDING_AIR_U,           -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirD,             File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(NSHEIK, Action.LandingAirX,             File.SHEIK_LANDING,                 -1,                         -1)

   Character.edit_action_parameters(NSHEIK, Action.USPG_BEGIN,              File.SHEIK_USPG_BEGIN,              Sheik.USP_BEGIN,                  0)
   Character.edit_action_parameters(NSHEIK, Action.USPG_MOVE,               -1,                                 Sheik.USP_MOVE,                   -1)
   Character.edit_action_parameters(NSHEIK, Action.USPG_END,                File.SHEIK_USPG_END,                Sheik.USP_END,                    0)
   Character.edit_action_parameters(NSHEIK, Action.USPA_BEGIN,              File.SHEIK_USPA_BEGIN,              Sheik.USP_BEGIN,                  0)
   Character.edit_action_parameters(NSHEIK, Action.USPA_MOVE,               -1,                                 Sheik.USP_MOVE,                   -1)
   Character.edit_action_parameters(NSHEIK, Action.USPA_END,                File.SHEIK_USPA_END,                Sheik.USP_END,                    0)
   Character.edit_action_parameters(NSHEIK, Action.NSPG_BEGIN,              File.SHEIK_NSPG_BEGIN,              Sheik.NSP_BEGIN,                  0)
   Character.edit_action_parameters(NSHEIK, Action.NSPG_CHARGE,             File.SHEIK_NSPG_CHARGE,             Sheik.NSP_CHARGE,                 0)
   Character.edit_action_parameters(NSHEIK, Action.NSPG_SHOOT,              File.SHEIK_NSPG_SHOOT,              Sheik.NSP_SHOOT,                  0)
   Character.edit_action_parameters(NSHEIK, Action.NSPA_BEGIN,              File.SHEIK_NSPA_BEGIN,              Sheik.NSP_BEGIN,                  0)
   Character.edit_action_parameters(NSHEIK, Action.NSPA_CHARGE,             File.SHEIK_NSPA_CHARGE,             Sheik.NSP_CHARGE,                 0)
   Character.edit_action_parameters(NSHEIK, 0xE0,                           File.SHEIK_IDLE,                    0x80000000,                        0x00000000)
   Character.edit_action_parameters(NSHEIK, 0xE1,                           File.SHEIK_IDLE,                    0x80000000,                        0x00000000)

   // Modify Actions            // Action              // Staling ID    // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
   Character.edit_action(NSHEIK, Action.JAB_LOOP_START, 0x4,            0x8014F0D0,                    0,                              0x800D8C14,                    0x800DDF44)
   Character.edit_action(NSHEIK, Action.JAB_LOOP,       0x4,            0x8014F2A8,                    0x8014F388,                     0x800D8C14,                    0x800DDF44)
   Character.edit_action(NSHEIK, Action.JAB_LOOP_END,   0x4,            0x800D94C4,                    0,                              0x800D8C14,                    0x800DDF44)

   Character.edit_action(NSHEIK, Action.USPG_BEGIN,     0x11,            SheikUSP.begin_main_,          0,                               0x800D8BB4,                     SheikUSP.ground_begin_collision_)
   Character.edit_action(NSHEIK, Action.USPG_MOVE,      0x11,            SheikUSP.move_main_,           0,                               SheikUSP.move_physics_,         SheikUSP.ground_move_collision_)
   Character.edit_action(NSHEIK, Action.USPG_END,       0x11,            SheikUSP.ground_end_main_,     0,                               0x800D8BB4,                     SheikUSP.end_collision_)
   Character.edit_action(NSHEIK, Action.USPA_BEGIN,     0x11,            SheikUSP.begin_main_,          0,                               0x800D90E0,                     SheikUSP.air_begin_collision_)
   Character.edit_action(NSHEIK, Action.USPA_MOVE,      0x11,            SheikUSP.move_main_,           0,                               SheikUSP.move_physics_,         SheikUSP.air_move_collision_)
   Character.edit_action(NSHEIK, Action.USPA_END,       0x11,            SheikUSP.air_end_main_,        0,                               SheikUSP.end_physics_,          SheikUSP.end_collision_)
   Character.edit_action(NSHEIK, Action.NSPG_BEGIN,     0x12,            SheikNSP.begin_main_,          SheikNSP.ground_begin_interrupt_,                      0x800D8BB4,                     SheikNSP.ground_begin_collision_)  //NSP_Ground_Begin
   Character.edit_action(NSHEIK, Action.NSPG_CHARGE,    0x12,            SheikNSP.charge_main_,         SheikNSP.ground_charge_interrupt_, 0x800D8BB4,                   SheikNSP.ground_charge_collision_) //NSP_Ground_Charge
   Character.edit_action(NSHEIK, Action.NSPG_SHOOT,     0x12,            SheikNSP.shoot_main_,          0,                               0x800D8BB4,                     SheikNSP.ground_shoot_collision_)  //NSP_Ground_Shoot
   Character.edit_action(NSHEIK, Action.NSPA_BEGIN,     0x12,            SheikNSP.begin_main_,          SheikNSP.air_begin_interrupt_,                      0x800D90E0,                     SheikNSP.air_begin_collision_)     //NSP_Air_Begin
   Character.edit_action(NSHEIK, Action.NSPA_CHARGE,    0x12,            SheikNSP.charge_main_,         SheikNSP.air_charge_interrupt_,  0x800D91EC,                     SheikNSP.air_charge_collision_)    //NSP_Air_Charge
   Character.edit_action(NSHEIK, 0xE0,                  -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
   Character.edit_action(NSHEIK, 0xE1,                  -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    Character.edit_action(NSHEIK, Action.DSP_RECOIL,     0x13,            SheikDSP.recoil_main_,         0,                               SheikDSP.recoil_physics_,       0x800DE99C)
    
    // Modify Menu Action Parameters             // Action      // Animation                // Moveset Data             // Flags

    Character.edit_menu_action_parameters(NSHEIK, 0x0,           File.SHEIK_IDLE,            -1,                         -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x1,           File.SHEIK_VICTORY_1,       Sheik.CSS,                        -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x2,           File.SHEIK_VICTORY_1,       Sheik.VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x3,           File.SHEIK_VICTORY_2,       Sheik.VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x4,           File.SHEIK_VICTORY_3,       Sheik.VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x5,           File.SHEIK_CLAP,            -1,                         -1)
    Character.edit_menu_action_parameters(NSHEIK, 0xD,           File.SHEIK_1P,              Sheik.ONEP,                       -1)
    Character.edit_menu_action_parameters(NSHEIK, 0xE,           File.SHEIK_1P_CPU,          Sheik.CPU,                        -1)
    Character.edit_menu_action_parameters(NSHEIK, 0x9,           File.SHEIK_PUPPET_FALL,     -1,                         -1)
    Character.edit_menu_action_parameters(NSHEIK, 0xA,           File.SHEIK_PUPPET_UP,       -1,                         -1)
	
    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(SHEIK,  NSP_Shoot_Air,      -1,             File.SHEIK_NSPA_SHOOT,      Sheik.NSP_SHOOT,                  0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Begin,          -1,             File.SHEIK_DSP_BEGIN,       Sheik.DSP_BEGIN,                  0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Attack,         -1,             File.SHEIK_DSP_ATTACK,      Sheik.DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Landing,        -1,             File.SHEIK_DSP_LANDING,     Sheik.DSP_LANDING,                0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Recoil,         -1,             File.SHEIK_DSP_RECOIL,      Sheik.DSP_RECOIL,                 0x00000000)

    // Add Actions                  // Action Name      // Base Action  // Parameters                       // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(SHEIK, NSP_Shoot_Air,      -1,             ActionParams.NSP_Shoot_Air,         0x12,           SheikNSP.shoot_main_,       0,                              0x800D91EC,                         0x800DE934)
    Character.add_new_action(SHEIK, DSP_Begin,          -1,             ActionParams.DSP_Begin,             0x13,           SheikDSP.main_,             0,                              SheikDSP.physics_,                  SheikDSP.air_collision_)
    Character.add_new_action(SHEIK, DSP_Attack,         -1,             ActionParams.DSP_Attack,            0x13,           0x800D94E8,                 0,                              SheikDSP.physics_,                  SheikDSP.attack_collision_)
    Character.add_new_action(SHEIK, DSP_Landing,        -1,             ActionParams.DSP_Landing,           0x13,           0x800D94C4,                 0,                              0x800D8CCC,                         0x800DDEE8)
    Character.add_new_action(SHEIK, DSP_Recoil,         -1,             ActionParams.DSP_Recoil,            0x13,           SheikDSP.recoil_main_,      0,                              SheikDSP.recoil_physics_,           0x800DE99C)


     // Set action strings
     Character.table_patch_start(action_string, Character.id.NSHEIK, 0x4)
     dw  Sheik.Action.action_string_table
     OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.NSHEIK, 0x4)
    dw      SheikUSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.NSHEIK, 0x4)
    dw      SheikUSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.NSHEIK, 0x4)
    dw      SheikDSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.NSHEIK, 0x4)
    dw      SheikDSP.initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.NSHEIK, 0x4)
    dw      SheikNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.NSHEIK, 0x4)
    dw      SheikNSP.air_begin_initial_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NSHEIK, 0x2)
    dh  0x2B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.NSHEIK, 0xC)
    dh 0x08
    OS.patch_end()

    // Set rapid jab begin action.
    Character.table_patch_start(rapid_jab_begin_action, Character.id.NSHEIK, 0x4)
    dw 0x8014F13C
    OS.patch_end()

    // Set rapid jab loop action.
    Character.table_patch_start(rapid_jab_loop_action, Character.id.NSHEIK, 0x4)
    dw 0x8014F3F4
    OS.patch_end()

    // Set rapid jab end action.
    Character.table_patch_start(rapid_jab_ending_action, Character.id.NSHEIK, 0x4)
    dw 0x8014F490
    OS.patch_end()

    // Patches for full charge Neutral B effect removal.
    Character.table_patch_start(gfx_routine_end, Character.id.NSHEIK, 0x4)
    dw      Sheik.charge_gfx_routine_
    OS.patch_end()

    Character.table_patch_start(initial_script, Character.id.NSHEIK, 0x4)
    dw      0x800D7DEC                      // use samus jump
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NSHEIK, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.NSHEIK, 0, 1, 4, 5, 1, 3, 2)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(NSHEIK, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NSHEIK, 0x4)
    dw      Sheik.CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.NSHEIK, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

}