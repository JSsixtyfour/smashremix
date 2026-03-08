// GBowser.asm

// This file contains file inclusions, action edits, and assembly for Giga Bowser.

scope GBowser {
    // Insert Moveset files

    insert USPG, "moveset/USPG.bin"
    insert USPA, "moveset/USPA.bin"
    insert NSP, "moveset/NSP.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert FTHROW_2, "moveset/FTHROW_2.bin"
    insert FTHROW_3, "moveset/FTHROW_3.bin"
    insert BTHROW_DATA, "moveset/BTHROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BTHROW.bin"
    insert DSP_GROUND, "moveset/DSP_GROUND.bin"
    insert DSP_AIR, "moveset/DSP_AIR.bin"
    insert DSP_LAND, "moveset/DSP_LAND.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert FSMASH, "moveset/FSMASH.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert FTILT, "moveset/FTILT.bin"
    insert FTILT_HIGH, "moveset/FTILT_HIGH.bin"
    insert FTILT_LOW, "moveset/FTILT_LOW.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert DAIR, "moveset/DAIR.bin"
    insert DAIR_LAND, "moveset/DAIR_LAND.bin"
    insert JAB1, "moveset/JAB1.bin"
    insert JAB2, "moveset/JAB2.bin"
    insert JAB3, "moveset/JAB3.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert DASH_ATTACK, "moveset/DASH_ATTACK.bin"
    insert DOWNATTACK_D, "moveset/DOWNATTACK_D.bin"
    insert DOWNATTACK_U, "moveset/DOWNATTACK_U.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert EDGEATTACKF1, "moveset/EDGEATTACKF1.bin"
    insert EDGEATTACKF2, "moveset/EDGEATTACKF2.bin"
    insert EDGEATTACKS1, "moveset/EDGEATTACKS1.bin"
    insert EDGEATTACKS2, "moveset/EDGEATTACKS2.bin"
    insert ENTRY, "moveset/ENTRY.bin"
    insert WALK2, "moveset/WALK2.bin"; Moveset.GO_TO(WALK2)                 // loops
    insert WALK3, "moveset/WALK3.bin"; Moveset.GO_TO(WALK3)                 // loops
    insert RUN, "moveset/RUN.bin"; Moveset.GO_TO(RUN)                       // loops
    insert TURN, "moveset/TURN.bin"
    DASH:; insert "moveset/DASH.bin"

    // Insert AI attack options
    include "AI/Attacks.asm"

    // Modify Action Parameters                  // Action                 // Animation                 // Moveset Data             // Flags
    Character.edit_action_parameters(GBOWSER,    Action.Entry,             File.BOWSER_IDLE,            -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.ReviveWait,        File.BOWSER_IDLE,            -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    0x06,                     File.BOWSER_IDLE,            -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.Walk1,             File.BOWSER_WALK1,           -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.Walk2,             File.BOWSER_WALK2,           WALK2,                      -1)
    Character.edit_action_parameters(GBOWSER,    Action.Walk3,             File.BOWSER_WALK3,           WALK3,                      -1)

    Character.edit_action_parameters(GBOWSER,    Action.DamageHigh1,       File.BOWSER_DAMAGE_HIGH_1,   -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageHigh2,       File.BOWSER_DAMAGE_HIGH_2,   -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageHigh3,       File.BOWSER_DAMAGE_HIGH_3,   -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageMid1,        File.BOWSER_DAMAGE_MID_1,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageMid2,        File.BOWSER_DAMAGE_MID_2,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageMid3,        File.BOWSER_DAMAGE_MID_3,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageLow1,        File.BOWSER_DAMAGE_LOW_1,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageLow2,        File.BOWSER_DAMAGE_LOW_2,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageLow3,        File.BOWSER_DAMAGE_LOW_3,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageAir1,        File.BOWSER_DAMAGE_AIR_1,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageAir2,        File.BOWSER_DAMAGE_AIR_2,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageAir3,        File.BOWSER_DAMAGE_AIR_3,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageElec1,       File.BOWSER_DAMAGE_ELEC,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageElec2,       File.BOWSER_DAMAGE_ELEC,     -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.Sleep,             File.BOWSER_STUNNED,         Bowser.SLEEP,               -1)
    Character.edit_action_parameters(GBOWSER,    Action.Stun,              File.BOWSER_STUNNED,         Bowser.STUN,                -1)
    Character.edit_action_parameters(GBOWSER,    Action.Tech,              File.BOWSER_TECH,            Bowser.TECH,                -1)
    Character.edit_action_parameters(GBOWSER,    Action.TechF,             File.BOWSER_TECH_F,          Bowser.TECHF,               -1)
    Character.edit_action_parameters(GBOWSER,    Action.TechB,             File.BOWSER_TECH_B,          Bowser.TECHF,               -1)

    Character.edit_action_parameters(GBOWSER,    Action.EnterPipe,         File.BOWSER_ENTER_PIPE,      -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ExitPipe,          File.BOWSER_EXIT_PIPE,       -1,                        -1)

    Character.edit_action_parameters(GBOWSER,    Action.Crouch,            File.BOWSER_CROUCH,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.CrouchIdle,        File.BOWSER_CROUCH_IDLE,     -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.CrouchEnd,         File.BOWSER_CROUCH_END,      -1,                        -1)

    Character.edit_action_parameters(GBOWSER,    Action.CeilingBonk,       File.BOWSER_CEILING_BONK,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownBounceD,       File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.StunLandD,         File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.Revive1,           File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownBounceU,       File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.StunLandU,         File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownStandD,        File.BOWSER_DOWN_STAND_D,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownStandU,        File.BOWSER_DOWN_STAND_U,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.Revive2,           File.BOWSER_DOWN_STAND_D,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.StunStartD,        File.BOWSER_DOWN_STAND_D,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.StunStartU,        File.BOWSER_DOWN_STAND_U,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownForwardD,      File.BOWSER_DOWN_FORWARD_D,  -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownForwardU,      File.BOWSER_DOWN_FORWARD_U,  -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownBackD,         File.BOWSER_DOWN_BACK_D,     -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownBackU,         File.BOWSER_DOWN_BACK_U,     -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownAttackU,       File.BOWSER_DOWN_ATTACK_U,   DOWNATTACK_U,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DownAttackD,       File.BOWSER_DOWN_ATTACK_D,   DOWNATTACK_D,                        -1)

    Character.edit_action_parameters(GBOWSER,    Action.CliffCatch,        File.BOWSER_CLIFFCATCH,      -1,                          -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffWait,         File.BOWSER_CLIFFWAIT,          -1,                          -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffQuick,        File.BOWSER_CLIFFQUICK,      -1,                          -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffSlow,         File.BOWSER_CLIFFSLOW,          -1,                          -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffClimbQuick1,  File.BOWSER_CLIFF_CLIMB_QUICK_1, -1,                   -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffClimbQuick2,  File.BOWSER_CLIFF_CLIMB_QUICK_2, -1,                   -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffClimbSlow1,   File.BOWSER_CLIFF_CLIMB_SLOW_1, -1,                     -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffClimbSlow2,   File.BOWSER_CLIFF_CLIMB_SLOW_2, -1,                     -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffEscapeQuick1, File.BOWSER_CLIFF_ESCAPE_QUICK_1, -1,                 -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffEscapeQuick2, File.BOWSER_CLIFF_ESCAPE_QUICK_2, -1,                 -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffEscapeSlow1,  File.BOWSER_CLIFF_ESCAPE_SLOW_1, -1,                   -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffEscapeSlow2,  File.BOWSER_CLIFF_ESCAPE_SLOW_2, -1,                   -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffAttackQuick1, File.BOWSER_CLIFFATTACKQ1, EDGEATTACKF1,              -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffAttackQuick2, File.BOWSER_CLIFFATTACKQ2, EDGEATTACKF2,              -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffAttackSlow1,  File.BOWSER_CLIFFATTACKS1,  EDGEATTACKS1,              -1)
    Character.edit_action_parameters(GBOWSER,    Action.CliffAttackSlow2,  File.BOWSER_CLIFFATTACKS2,  EDGEATTACKS2,              -1)

    Character.edit_action_parameters(GBOWSER,    Action.DamageFlyHigh,     File.BOWSER_DAMAGE_FLY_HIGH, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageFlyMid,      File.BOWSER_DAMAGE_FLY_MID,  -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageFlyLow,      File.BOWSER_DAMAGE_FLY_LOW,  -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageFlyTop,      File.BOWSER_DAMAGE_FLY_TOP,  -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DamageFlyRoll,     File.BOWSER_DAMAGE_FLY_ROLL, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.DeadU,             File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ScreenKO,          File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.WallBounce,        File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.Tumble,            File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.Tornado,           File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ShieldBreak,       File.BOWSER_DAMAGE_FLY_TOP,  Bowser.SHIELD_BREAK,       -1)
    Character.edit_action_parameters(GBOWSER,    Action.ShieldBreakFall,   File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.InhalePulled,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.InhaleSpat,        File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.InhaleCopied,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.FalconDivePulled,  File.BOWSER_DAMAGE_HIGH_3,   -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    0xB4,                     File.BOWSER_TUMBLE,          -1,                        -1)

    Character.edit_action_parameters(GBOWSER,    Action.LightItemPickup,   File.BOWSER_LIGHT_ITEM_PICK, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.HeavyItemPickup,   File.BOWSER_HEAVY_ITEM_PICK, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemDrop,          File.BOWSER_ITEM_DROP,       -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowDash,     File.BOWSER_ITEM_THROW_DASH, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowF,        File.BOWSER_ITEM_THROW_F,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowB,        File.BOWSER_ITEM_THROW_F,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowSmashF,   File.BOWSER_ITEM_THROW_F,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowSmashB,   File.BOWSER_ITEM_THROW_F,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowU,        File.BOWSER_ITEM_THROW_U,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowSmashU,   File.BOWSER_ITEM_THROW_U,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowD,        File.BOWSER_ITEM_THROW_D,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowSmashD,   File.BOWSER_ITEM_THROW_D,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirF,     File.BOWSER_ITEM_THROW_F_AIR, -1,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirSmashF, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirB,     File.BOWSER_ITEM_THROW_F_AIR,    -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirSmashB, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirU,     File.BOWSER_ITEM_THROW_U_AIR,    -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirSmashU, File.BOWSER_ITEM_THROW_U_AIR, -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirD,     File.BOWSER_ITEM_THROW_D_AIR,    -1,                    -1)
    Character.edit_action_parameters(GBOWSER,    Action.ItemThrowAirSmashD, File.BOWSER_ITEM_THROW_D_AIR, -1,                    -1)

    Character.edit_action_parameters(GBOWSER,    Action.HeavyItemThrowF,   File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.HeavyItemThrowB,   File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.HeavyItemThrowSmashF, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)
    Character.edit_action_parameters(GBOWSER,    Action.HeavyItemThrowSmashB, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)

    Character.edit_action_parameters(GBOWSER,    Action.RayGunShoot,       File.BOWSER_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.RayGunShootAir,    File.BOWSER_RAYGUN_AIR,      -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.FireFlowerShoot,   File.BOWSER_RAYGUN_GND,          -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.FireFlowerShootAir, File.BOWSER_RAYGUN_AIR,    -1,                        -1)

    Character.edit_action_parameters(GBOWSER,    Action.HammerIdle,        File.BOWSER_HAMMER_IDLE,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.HammerWalk,        File.BOWSER_HAMMER_WALK,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.HammerTurn,        File.BOWSER_HAMMER_WALK,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.HammerJumpSquat,   File.BOWSER_HAMMER_WALK,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.HammerAir,         File.BOWSER_HAMMER_WALK,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.HammerLanding,     File.BOWSER_HAMMER_WALK,     -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.CapturePulled,   File.BOWSER_EGG_LAY_PULLED,  -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.EggLay,            File.BOWSER_IDLE,              -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.EggLayPulled,    File.BOWSER_EGG_LAY_PULLED,  -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.ThrownDKPulled,  File.BOWSER_THROWN_DK_PULLED, -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ThrownDK,        File.BOWSER_THROWN_DK,       -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.Thrown1,         File.BOWSER_THROWN_1,        -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.Thrown2,         File.BOWSER_THROWN_2,        -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.Taunt,           File.BOWSER_TAUNT,          Bowser.TAUNT,               -1)

    Character.edit_action_parameters(GBOWSER,    Action.Turn,            File.GBOWSER_TURN,          TURN,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.Jab1,            File.BOWSER_JAB1,           JAB1,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.Jab2,            File.BOWSER_JAB2,           JAB2,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.DTilt,           File.BOWSER_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(GBOWSER,    Action.AttackAirN,      File.GBOWSER_ATTACK_AIR_N,  NAIR,                       -1)

    Character.edit_action_parameters(GBOWSER,    Action.Idle,            File.BOWSER_IDLE,           -1,                         0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.JumpSquat,       File.BOWSER_LANDING,       -1,                         0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.ShieldJumpSquat, File.BOWSER_LANDING,       -1,                         0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.LandingLight,    File.BOWSER_LANDING,       -1,                         0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.LandingHeavy,    File.BOWSER_LANDING,       -1,                         0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.LandingSpecial,  File.BOWSER_LANDING,       -1,                         0x00000000)

    Character.edit_action_parameters(GBOWSER,    Action.Fall,            File.BOWSER_FALL,           -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.FallAerial,      File.BOWSER_FALL2,           -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.AttackAirF,      File.BOWSER_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.LandingAirF,     File.BOWSER_FAIR_LAND,      -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.LandingAirN,     File.BOWSER_LANDING,        -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.LandingAirX,     File.BOWSER_LANDING,        -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.Grab,            File.GBOWSER_GRAB,          GRAB,                       0x10000000)
    Character.edit_action_parameters(GBOWSER,    Action.FSmash,          File.BOWSER_FSMASH,         FSMASH,                     0x40000000)
    Character.edit_action_parameters(GBOWSER,    Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(GBOWSER,    Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(GBOWSER,    Action.DSmash,          File.GBOWSER_DSMASH,        DSMASH,                     -1)

    Character.edit_action_parameters(GBOWSER,    Action.GrabPull,        File.BOWSER_PULL,           Bowser.GRAB_PULL,           0x10000000)
    Character.edit_action_parameters(GBOWSER,    Action.ThrowB,          File.BOWSER_BTHROW,         BTHROW,                     0x10000000)
    Character.edit_action_parameters(GBOWSER,    Action.ThrownMarioBros, File.BOWSER_THROWN_MARIO,   -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.ShieldOn,        File.BOWSER_SHIELD_ON,      -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ShieldOff,       File.BOWSER_SHIELD_OFF,     -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.ShieldDrop,      File.BOWSER_SHIELD_DROP,    -1,                        -1)
	Character.edit_action_parameters(GBOWSER,    Action.Pass, 			 File.BOWSER_SHIELD_DROP,    -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.RollF,           File.BOWSER_ROLL_F,         -1,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.RollB,           File.BOWSER_ROLL_B,         -1,                        -1)

    Character.edit_action_parameters(GBOWSER,    0xE0,                   File.BOWSER_BOMB_GROUND,    DSP_GROUND,                 -1)
    Character.edit_action_parameters(GBOWSER,    0xE1,                   File.BOWSER_BOMB_LAND,      DSP_LAND,                   -1)
    Character.edit_action_parameters(GBOWSER,    0xE2,                   File.BOWSER_BOMB_AIR,       DSP_AIR,                    -1)
    Character.edit_action_parameters(GBOWSER,    0xE5,                   File.BOWSER_FTHROW,         FTHROW,                     0x50000000)
    Character.edit_action_parameters(GBOWSER,    0xE6,                   File.BOWSER_FTHROW_2,       FTHROW_2,                   0x50000000)
    Character.edit_action_parameters(GBOWSER,    0xE8,                   File.BOWSER_FTHROW_3,       FTHROW_3,                   0x50000000)
    Character.edit_action_parameters(GBOWSER,    0xDE,                   File.BOWSER_USP_GROUND,     USPG,                       0x00000000)
    Character.edit_action_parameters(GBOWSER,    0xDF,                   File.BOWSER_USP_AIR,        USPA,                       0x00000000)
    Character.edit_action_parameters(GBOWSER,    0xE4,                   File.BOWSER_FIRE,           NSP,                        0x00000001)
    Character.edit_action_parameters(GBOWSER,    0xE7,                   File.BOWSER_FIRE,           NSP,                        0x00000001)
    Character.edit_action_parameters(GBOWSER,    0xE9,                   File.BOWSER_JAB3,           JAB3,                       0x40000000)
    Character.edit_action_parameters(GBOWSER,    Action.FallSpecial,     File.BOWSER_SFALL,          -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.AttackAirB,      File.BOWSER_BAIR,           BAIR,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.LandingAirB,     File.BOWSER_BAIR_LANDING,   -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.AttackAirU,      File.GBOWSER_ATTACK_AIR_U,  UAIR,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.AttackAirD,      File.GBOWSER_ATTACK_AIR_D,  DAIR,                       0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.LandingAirD,     File.BOWSER_DAIR_LAND,      DAIR_LAND,                  0x00000000)

    Character.edit_action_parameters(GBOWSER,    Action.UTilt,           File.GBOWSER_UTILT,         UTILT,                      0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.USmash,          File.GBOWSER_USMASH,        USMASH,                     -1)

    Character.edit_action_parameters(GBOWSER,    Action.Teeter,          File.BOWSER_TEETER_LOOP,    Bowser.TEETER,              -1)
    Character.edit_action_parameters(GBOWSER,    Action.TeeterStart,     File.BOWSER_TEETER_START,   -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.FTiltHigh,       File.GBOWSER_FTILT_HIGH,    FTILT_HIGH,                 -1)
    Character.edit_action_parameters(GBOWSER,    Action.FTilt,           File.GBOWSER_FTILT,         FTILT,                      -1)
    Character.edit_action_parameters(GBOWSER,    Action.FTiltLow,        File.GBOWSER_FTILT_LOW,     FTILT_LOW,                  -1)

    Character.edit_action_parameters(GBOWSER,    Action.Dash,            File.BOWSER_DASH,           DASH,                       -1)
    Character.edit_action_parameters(GBOWSER,    Action.Run,             File.BOWSER_RUN,            RUN,                        -1)
    Character.edit_action_parameters(GBOWSER,    Action.TurnRun,         File.BOWSER_TURN_RUN,       Bowser.TURN_RUN,            -1)
    Character.edit_action_parameters(GBOWSER,    Action.RunBrake,        File.BOWSER_RUN_BRAKE,      -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.DashAttack,      File.BOWSER_DASH_ATTACK,    DASH_ATTACK,                -1)
    Character.edit_action_parameters(GBOWSER,    Action.JumpF,           File.BOWSER_JUMPF,          Bowser.JUMP1,               -1)
    Character.edit_action_parameters(GBOWSER,    Action.JumpB,           File.BOWSER_JUMPB,          Bowser.JUMP1,               -1)
    Character.edit_action_parameters(GBOWSER,    Action.JumpAerialB,     File.BOWSER_JUMP2_B,        Bowser.JUMP2,               0x00000000)
    Character.edit_action_parameters(GBOWSER,    Action.JumpAerialF,     File.BOWSER_JUMP2,          Bowser.JUMP2,               -1)

    Character.edit_action_parameters(GBOWSER,    Action.BeamSwordNeutral, File.BOWSER_SWING_NEUTRAL, -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BeamSwordTilt,   File.BOWSER_SWING_TILT,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BeamSwordSmash,  File.BOWSER_SWING_SMASH,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BeamSwordDash,   File.BOWSER_SWING_DASH,     -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.BatNeutral,       File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BatTilt,          File.BOWSER_SWING_TILT,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BatSmash,         File.BOWSER_SWING_SMASH,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.BatDash,          File.BOWSER_SWING_DASH,     -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.FanNeutral,       File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.FanTilt,          File.BOWSER_SWING_TILT,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.FanSmash,         File.BOWSER_SWING_SMASH,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.FanDash,          File.BOWSER_SWING_DASH,     -1,                         -1)

    Character.edit_action_parameters(GBOWSER,    Action.StarRodNeutral,  File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.StarRodTilt,     File.BOWSER_SWING_TILT,     -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.StarRodSmash,    File.BOWSER_SWING_SMASH,    -1,                         -1)
    Character.edit_action_parameters(GBOWSER,    Action.StarRodDash,     File.BOWSER_SWING_DASH,     -1,                         -1)

	Character.edit_action_parameters(GBOWSER,    0xDC,     				 File.GBOWSER_ENTRY_RIGHT,  ENTRY,                       -1)
	Character.edit_action_parameters(GBOWSER,    0xDD,     				 File.GBOWSER_ENTRY_LEFT,   ENTRY,                       -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM                  // Movement/Physics ASM                         // Collision ASM
    Character.edit_action(GBOWSER, 0xDE,             -1,             0x8015B6D0,                 -1,                                     BowserUSP.ground_physics_,                      -1)
    Character.edit_action(GBOWSER, 0xDF,             -1,             0x8015B6F0,                 BowserUSP.air_direction_,               BowserUSP.air_physics_,                         -1)
    Character.edit_action(GBOWSER, 0xE0,             -1,             -1,                         -1,                                     -1,                                             -1)
    Character.edit_action(GBOWSER, 0xE2,             -1,             -1,                         -1,                                     BowserDSP.air_physics_,                         -1)
    Character.edit_action(GBOWSER, 0xE4,             -1,             BowserNSP.main_,            -1,                                     0x800D8BB4,                                     0x800DDF44)
    Character.edit_action(GBOWSER, 0xE7,             -1,             BowserNSP.main_,            -1,                                     -1,                                             BowserNSP.gbowser_air_collision_)             //0x800DE934
    Character.edit_action(GBOWSER, 0xE5,             -1,             BowserFThrow.main_,         0x00000000,                             0x800D93E4,                                     BowserFThrow.collision_)
    Character.edit_action(GBOWSER, 0xE6,             -1,             0x00000000,                 0x00000000,                             0x00000000,                                     BowserFThrow.collision_)
    Character.edit_action(GBOWSER, 0xE8,             -1,             0x8014A0C0,                 0x00000000,                             0x8014A4F8,                                     0x8014A538)
    Character.edit_action(GBOWSER, 0xE9,             0x3,            0x800D94C4,                 0x00000000,                             0x800D8C14,                                     0x800DDF44)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(GBOWSER,    0x0,               File.BOWSER_IDLE,           -1,                            -1)
    Character.edit_menu_action_parameters(GBOWSER,    0x1,               File.BOWSER_DANCE,          Bowser.VICTORY2,               -1)
    Character.edit_menu_action_parameters(GBOWSER,    0x2,               File.BOWSER_CSS,            Bowser.CSS,                    -1)
    Character.edit_menu_action_parameters(GBOWSER,    0x3,               File.BOWSER_LAUGH,          Bowser.VICTORY1,               -1)
    Character.edit_menu_action_parameters(GBOWSER,    0x5,               File.BOWSER_CLAP,           Bowser.CLAP,                   -1)
    Character.edit_menu_action_parameters(GBOWSER,    0xD,               File.BOWSER_1P,             -1,                            -1)
    Character.edit_menu_action_parameters(GBOWSER,    0xE,               File.GBOWSER_1P_CPU,        -1,                            -1)
    Character.edit_menu_action_parameters(GBOWSER,    0x9,               File.BOWSER_CONTINUE_FALL,  -1,                            -1)
    Character.edit_menu_action_parameters(GBOWSER,    0xA,               File.BOWSER_CONTINUE_UP,    -1,                            -1)

    Character.table_patch_start(variant_original, Character.id.GBOWSER, 0x4)
    dw      Character.id.BOWSER // set Bowser as original character (not Yoshi, who GBOWSER is a clone of)
    OS.patch_end()

    // Add initial script/passive armor.
    Character.table_patch_start(initial_script, Character.id.GBOWSER, 0x4)
    dw initial_script_
    OS.patch_end()

	// Remove entry script.
    Character.table_patch_start(entry_script, Character.id.GBOWSER, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.GBOWSER, 0x4)
    dw      BowserUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.GBOWSER, 0x4)
    dw      BowserNSP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.GBOWSER, 0x4)
    dw      BowserNSP.air_initial_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.GBOWSER, 0x2)
    dh  0x0363
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.GBOWSER, 0x4)
    float32 1.7
    OS.patch_end()

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.GBOWSER, 0xC)
    dw Character.kirby_inhale_struct.star_damage.GDONKEY
    OS.patch_end()

    // Set Kirby copy power and hat_id
    Character.table_patch_start(kirby_inhale_struct, Character.id.GBOWSER, 0xC)
    dh Character.id.BOWSER
    dh 0x15
    OS.patch_end()

    // Set Yoshi Egg Size override ID, these values are just copied from DK
    Character.table_patch_start(yoshi_egg, Character.id.GBOWSER, 0x1C)
    dw    0x40B66666
    dw    0x00000000
    dw    0x43C80000
    dw    0x00000000
    dw    0x43AF0000
    dw    0x43AF0000
    dw    0x43AF0000
    OS.patch_end()

    // Add Jab 3
    Character.table_patch_start(jab_3_timer, Character.id.GBOWSER, 0x4)
    dw 0x8014EB54                           // jab 3 timer routine copied from Mario
    OS.patch_end()
    Character.table_patch_start(jab_3_action, Character.id.GBOWSER, 0x4)
    dw set_jab_3_action_                    // subroutine which sets action id
    OS.patch_end()
    Character.table_patch_start(jab_3, Character.id.GBOWSER, 0x4)
    dw Character.jab_3.ENABLED              // jab 3 = ENABLED
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.GBOWSER, 0x4)
    dw  Bowser.Action.action_string_table
    OS.patch_end()

    Teams.add_team_costume(YELLOW, GBOWSER, 0x5)

    // Shield colors for costume matching
    Character.table_patch_start(costume_shield_color, Character.id.GBOWSER, 0x4)
    dw Bowser.costume_shield_color
    OS.patch_end()
    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.GBOWSER, 0x2)
    dh {MIDI.id.FIRST_DESTINATION}
    OS.patch_end()

    // @ Description
    // Sets Giga Bowser's Passive Armor. This is based on Giant DK's script at 800D7DD4
    scope initial_script_: {
        lui        at, 0x425C
        mtc1    at, f6
        nop
        swc1    f6, 0x07E4(v1)
        j        0x800D7F0C
        sw        r0, 0x0ADC(v1)
    }

    // @ Description
    // Sets Giga Bowser's Jab 3 action.
    scope set_jab_3_action_: {
        ori     t7, r0, 0x00E9              // t7 = action id
        j       0x8014EC30                  // return
        sw      t7, 0x0020(sp)              // store action id
    }

    // he will not chase opponents while on Final Destination
    // we could prevent random hopping at 0x80133EBC
    // scope prevent_aerial_chase: {
        // OS.patch_start(0xAD524, 0x80132AE4)
        // j       prevent_aerial_chase
        // swc1    f20, 0x0060(v1)             // set target x coordinate
        // _return:
        // OS.patch_end()
        
        // lw      t6, 0x0008(s1)              // get character id
        // addiu   at, r0, Character.id.GBOWSER
        // bne     at, t6, _normal
        // addiu   at, r0, Global.GAMEMODE.CLASSIC

        // OS.read_word(Global.match_info, t6) // get game mode
        // lb      t6, 0x0000(t6)              // ~
        // bne     at, t6, _normal
        // nop

        // // if here, assume we are in remix 1P's final Boss on Final Destination
        // j       _return
        // sw      r0, 0x0064(v1)             // set target y coordinate to 0
        
        // _normal:
        // j       _return
        // swc1    f22, 0x0064(v1)             // set target y coordinate
    // }

    // prevent boss gbowser from dying in remix 1P
    scope _remix_1p_prevent_bottom_blast_zone_KO: {
        OS.patch_start(0xB77A4, 0x8013CD64)
        j       _remix_1p_prevent_bottom_blast_zone_KO
        nop
        _return:
        OS.patch_end();
        
        // Giga Bowser in 1P check
        // s1 = player struct
        lw      t0, 0x0008(s1)                  // t0 = fighter/character id
        addiu   at, r0, Character.id.GBOWSER
        bne     at, t0, _KO
        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)
        addiu   at, r0, 4                       // at = remix 1p mode
        bne     at, t0, _KO
        lw      at, 0x0020(s1)                  // at = player type
        beqz    at, _KO                         // branch if fighter is a player
        nop

        // if here, remix 1p giga bowser
        // check if very easy
        //OS.read_word(SinglePlayerModes.saved_difficulty, t0)   // get difficulty
        //beqz    t0, _KO                             // if 0 (very easy, KO Gbowser)
        //nop

        addiu   sp, sp, -0x0028                 // allocate stack space
        sw      a1, 0x0004(sp)                  // save registers
        sw      a2, 0x0008(sp)                  // ~
        sw      a3, 0x000C(sp)                  // ~
        sw      v0, 0x0014(sp)                  // ~
        sw      v1, 0x0018(sp)
        
        // gbowser check y coordinate
        lh      at, 0x004C(s1)                  // player y velocity
        andi    at, at, 0x8000                  // at != 0 if negative y velocity
        beqz    at, _skip_KO
        nop
        
        lwc1    f4, 0x0004(a2)                  // f4 = player y coordinate
        lui     at, 0xC5CA                      // y coordinate to check against
        mtc1    at, f6
        c.le.s  f4, f6                          // if fighter y < lower y

        bc1fl   _skip_KO
        nop

        // if here, gbowser goes upwards
        lui     at, 0x4380                      // at = y velocity
        sw      at, 0x004C(s1)                  // save new y velocity
        lb      t2, 0x018D(s1)
        ori     t6, r0, 0x0007                  // t6 = bitmask (01111111)
        and     t6, t2, t6                      // ~
        sb      t6, 0x018D(s1)                  // disable fast fall flag

        lh      at, 0x0000(a2)                  // at = player x coordinate
        addiu   t0, r0, -1                      // t0 = player direction (right)
        andi    at, 0x8000                      // at != 0 if negative x coordinate
        beqz    at, _gbowser_continue
        lui     at, 0x458f
        addiu   t0, r0, 1                       // t0 = player direction (left)// t0 = player direction (right)
        lui     at, 0xC58f
        _gbowser_continue:
        sw      at, 0x0000(a2)                  // save new x coordinate
        
        sw      t0, 0x0044(s1)                  // set new player direction
        lw      a0, 0x0004(s1)                  // a0 = player obj

        jal     0x800DEE54                      // transition to idle
        nop

        // gbowser play fgm
        FGM.play(0x369)

        _skip_KO:
        lw      a1, 0x0004(sp)                    // restore registers
        lw      a2, 0x0008(sp)                    // ~
        lw      a3, 0x000C(sp)                    // ~
        lw      v0, 0x0014(sp)                    // ~
        lw      v1, 0x0018(sp)
        addiu   sp, sp, 0x0028                    // deallocate stack space
        j       0x8013CD78                        // go back to rest of routine
        lh      t4, 0x0096(v1)                    // og branch line 2
      
        _KO:
        jal     0x8013C1C4
        nop
        j       _return
        nop
    }

    // @ Description
    // prevent gboswer from dashing if a CPU. Could not find a better way to do this.
    scope prevent_dash: {
        OS.patch_start(0xB9760, 0x8013ED20)
        jal     prevent_dash
        lui     a3, 0x3F80                      // og line 1
        _return:
        OS.patch_end()

        lw      t0, 0x0008(v0)               // t0 = character id
        addiu   at, r0, Character.id.GBOWSER
        bne     at, t0, _normal              // return if not gbowser
        lb      t0, 0x0023(v0)               // t0 = player type (0 = player, 1 = CPU)
        bnezl   t0, _normal
        addiu   a1, r0, Action.Walk3         // Walk3 instead of Dash for GBOWSER

        _normal:
        jal     0x800E6F24
        sw      v0, 0x0024(sp)
        j       0x8013ED2C
        nop
    }
}
