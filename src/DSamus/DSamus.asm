// DSamus.asm

// This file contains file inclusions, action edits, and assembly for Dark Samus.

scope DSamus {

    scope MODEL {
        scope HAND_L {
            constant DEFAULT(0xA0500000)
            constant CLOSED(0xA0500001)
        }
    }

    // @ Description
    // Dark Samus's extra actions
    scope Action {
        constant Appear1(0x0DC)
        constant Appear2(0x0DD)
        constant ChargeShotStart(0x0DE)
        constant ChargeShotCharging(0x0DF)
        constant ChargeShotShooting(0x0E0)
        constant ChargeShotStartAir(0x0E1)
        constant ChargeShotShootingAir(0x0E2)
        constant ScrewAttack(0x0E3)
        constant ScrewAttackAir(0x0E4)
        constant BoostBall(0x0E5)
        constant BoostBallJump(0x0E6)

        // strings!
        string_0x0DC:; String.insert("Appear1")
        string_0x0DD:; String.insert("Appear2")
        string_0x0DE:; String.insert("ChargeShotStart")
        string_0x0DF:; String.insert("ChargeShotCharging")
        string_0x0E0:; String.insert("ChargeShotShooting")
        string_0x0E1:; String.insert("ChargeShotStartAir")
        string_0x0E2:; String.insert("ChargeShotShootingAir")
        string_0x0E3:; String.insert("ScrewAttack")
        string_0x0E4:; String.insert("ScrewAttackAir")
        string_0x0E5:; String.insert("BoostBall")
        string_0x0E6:; String.insert("BoostBallJump")
        string_0x0E7:; String.insert("ChargeShotChargingAir")
        string_0x0E8:; String.insert("BoostBallAir")
        string_0x0E9:; String.insert("BoostBallLanding")

        action_string_table:
        dw string_0x0DC
        dw string_0x0DD
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
    }

    // Subroutine for enabling ball hurtboxes
    BALL_HURTBOX_ON:
    dw 0xA8000000   // uhh
    dw 0xA0300001   // blob body
    dw 0x7C300000, 0x00000019, 0xFFF800C8, 0x01040096   // body hurtbox
    dw 0x70280003   // ~
    dw 0x70680003   // ~
    dw 0x70780003   // ~
    dw 0x70400003   // ~
    dw 0x70800003   // ~
    dw 0x70480003   // ~
    dw 0x71000003   // ~
    dw 0x70D80003   // ~
    dw 0x71080003   // ~
    dw 0x70E00003   // make other hurtboxes intangible
    Moveset.RETURN()

    // Insert Moveset files
    insert ROLLSUB, "moveset/ROLLSUBROUTINE.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert RUN_LOOP, "moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP)           // loops
    FAIR:; insert "moveset/FAIR.bin"
    NAIR:; insert "moveset/NAIR.bin"
    UAIR:; insert "moveset/UAIR.bin"
    insert FTILTUP, "moveset/FTILTUP.bin"
    insert FTILTMIDUP, "moveset/FTILTMIDUP.bin"
    insert FTILTMID, "moveset/FTILTMID.bin"
    insert FTILTDOWN, "moveset/FTILTDOWN.bin"
    insert UTILT, "moveset/UTILT.bin"
    DTILT:; insert "moveset/DTILT.bin"
    insert FSMASHUP, "moveset/FSMASHUP.bin"
    insert FSMASHMIDUP, "moveset/FSMASHMIDUP.bin"
    insert FSMASHMID, "moveset/FSMASHMID.bin"
    insert FSMASHMIDDOWN, "moveset/FSMASHMIDDOWN.bin"
    insert FSMASHDOWN, "moveset/FSMASHDOWN.bin"
    DSMASH:; insert "moveset/DSMASH.bin"
    USMASH:; insert "moveset/USMASH.bin"
    UP_SPECIAL_AIR:; insert "moveset/UP_SPECIAL_AIR.bin"
    UP_SPECIAL_GROUND:; insert "moveset/UP_SPECIAL_GROUND.bin"
    ROLLF:; Moveset.CONCURRENT_STREAM(ROLLSUB); insert "moveset/FROLL.bin"
    insert NEUTRAL1, "moveset/NEUTRAL1.bin"
    insert CLIFFATTACKSLOW, "moveset/CLIFFATTACKSLOW.bin" // cliff attack 2
    insert DASHATTACK, "moveset/DASH.bin"
    //insert DAIR, "moveset/DAIR.bin"
    BAIR:; insert "moveset/BAIR.bin"
    insert LANDING_NAIR, "moveset/LANDING_NAIR.bin"
    insert VICTORY, "moveset/VICTORY.bin"
    insert VICTORY1, "moveset/VICTORY1.bin"
    insert SELECT, "moveset/SELECT.bin"
    insert CHARGE, "moveset/CHARGE.bin"
    insert CHARGELOOP, "moveset/CHARGELOOP.bin"; Moveset.GO_TO(CHARGELOOP)    // loops
    insert CLAP, "moveset/CLAP.bin"
    insert TAUNT, "moveset/TAUNT.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert TECH,"moveset/TECH.bin"
    ENTRY:; insert "moveset/ENTRY.bin"

    WALK:
    dw MODEL.HAND_L.CLOSED; dw 0

    NSP_CHARGE_2: // air
    dw 0x98004000, 0x0000FF9C, 0xFF380000, 0x00000000;
    Moveset.WAIT(1)
    dw 0x94000000
    Moveset.GO_TO(NSP_CHARGE_2); // loops

    NSP_CHARGE: // air
    dw 0x98807C00, 0x00960000, 0x00000000, 0x00000000, 0xC4000007;
    dw 0x98004000, 0x0000FF9C, 0xFF380000, 0x00000000;
    Moveset.WAIT(1)
    dw 0x94000000;
    Moveset.GO_TO(NSP_CHARGE_2)

    DSP_GROUND:
    dw 0x98003400, 0x00000000, 0x00000000, 0x00000000
    Moveset.AFTER(3)
    Moveset.SUBROUTINE(BALL_HURTBOX_ON)
    insert "moveset/DSP_GROUND.bin"

    DSP_AIR:
    dw 0x98002C00, 0x00000000, 0x00000000, 0x00000000
    Moveset.AFTER(3)
    Moveset.SUBROUTINE(BALL_HURTBOX_ON)
    insert "moveset/DSP_AIR.bin"

    DSP_LANDING:; insert "moveset/DSP_LANDING.bin"

    // Insert AI attack options
    include "AI/Attacks.asm"

    // Modify Action Parameters             // Action                               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.Entry,                          File.DARK_SAMUS_IDLE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, 0x006,                                 File.DARK_SAMUS_IDLE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Idle,                           File.DARK_SAMUS_IDLE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.ReviveWait,                     File.DARK_SAMUS_IDLE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Dash,                           File.DSAMUS_DASH,           -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.TurnRun,                        File.DSAMUS_TURNRUN,        -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RunBrake,                       File.DSAMUS_RUNBRAKE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Walk1,                          File.DSAMUS_WALK_1,         WALK,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.Walk2,                          File.DSAMUS_WALK_2,         WALK,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.Walk3,                          File.DSAMUS_WALK_3,         WALK,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.Run,                            File.DSAMUS_RUN,            RUN_LOOP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.RollF,                          File.DSAMUS_ROLLF,          ROLLF,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,                          File.DSAMUS_ROLLB,          ROLLSUB,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpF,                          File.DSAMUS_JUMPF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpB,                          File.DSAMUS_JUMPB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,                    0x8E6,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,                    0x8E7,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.Jab1,                           -1,                         NEUTRAL1,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.CliffAttackSlow2                ,-1,                        CLIFFATTACKSLOW,            -1)
    Character.edit_action_parameters(DSAMUS, Action.TechF,                          -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.TechB,                          -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.Tech,                           -1,                         TECH,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.DashAttack,                     -1,                         DASHATTACK,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,                     File.DSAMUS_NAIR,           NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.LandingAirN,                    File.DSAMUS_NAIR_LANDING,   LANDING_NAIR,               -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,                     File.DSAMUS_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,                     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirB,                     File.DSAMUS_BAIR,           BAIR,                       -1)
    // Character.edit_action_parameters(DSAMUS, Action.AttackAirD,                     -1,                         DAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltHigh,                      -1,                         FTILTUP,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidHigh,                   -1,                         FTILTMIDUP,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.FTilt,                          -1,                         FTILTMID,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidLow,                    -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltLow,                       -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,                          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,                          File.DSAMUS_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.USmash,                         File.DSAMUS_UPSMASH,        USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,                         File.DSAMUS_DSMASH,         DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashHigh,                     -1,                         FSMASHUP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidHigh,                  -1,                         FSMASHMIDUP,                -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmash,                         -1,                         FSMASHMID,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidLow,                   -1,                         FSMASHMIDDOWN,              -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashLow,                      -1,                         FSMASHDOWN,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.Taunt,                          File.DSAMUS_TAUNT,          TAUNT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.ScrewAttack,                    -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, Action.ScrewAttackAir,                 -1,                         UP_SPECIAL_AIR,             -1)
    Character.edit_action_parameters(DSAMUS, Action.ChargeShotCharging,             File.DSAMUS_NSP_CHARGE,     CHARGE,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.ChargeShotStart,                File.DSAMUS_NSP_START,      -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.ChargeShotShooting,             File.DSAMUS_NSP_SHOOT,      -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.ChargeShotStartAir,             File.DSAMUS_NSP_START_AIR,  -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.ChargeShotShootingAir,          File.DSAMUS_NSP_SHOOT_AIR,  -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.BoostBall,                      -1,                         DSP_GROUND,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.BoostBallJump,                  -1,                         DSP_GROUND,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.EggLay,                         File.DARK_SAMUS_IDLE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Appear1,                        File.DSAMUS_APPEAR_L,       ENTRY,                      0x40000008)
    Character.edit_action_parameters(DSAMUS, Action.Appear2,                        File.DSAMUS_APPEAR_R,       ENTRY,                      0x40000008)

    // Add Action Parameters                // Action Name      // Base Action          // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(DSAMUS, NSPChargeAir,       -1,                     File.DSAMUS_NSP_CHARGE_AIR, NSP_CHARGE,                 0)
    Character.add_new_action_params(DSAMUS, DSPAir,             Action.SAMUS.BombAir,   -1,                         DSP_AIR,                    -1)
    Character.add_new_action_params(DSAMUS, DSPLanding,         -1,                     File.DSAMUS_DSP_LANDING,    DSP_LANDING,                0)

    // Modify Actions             // Action                             // Staling ID   // Main ASM     // Interrupt/Other ASM  // Movement/Physics ASM     // Collision ASM
    Character.edit_action(DSAMUS, Action.SAMUS.ChargeShotStartAir,      -1,             -1,             0x8015D464,             -1,                         -1)
    Character.edit_action(DSAMUS, Action.SAMUS.ChargeShotCharging,      -1,             -1,             -1,                     -1,                         DSamusNSP.ground_charge_collision_)
    Character.edit_action(DSAMUS, Action.SAMUS.Bomb,                    -1,             -1,             -1,                     -1,                         DSamusDSP.ground_collision_)
    Character.edit_action(DSAMUS, Action.SAMUS.BombAir,                 -1,             -1,             -1,                     DSamusDSP.air_physics_,     -1)


    // Add Actions                   // Action Name     // Base Action          //Parameters                // Staling ID   // Main ASM                 // Interrupt/Other ASM              // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(DSAMUS, NSPChargeAir,      -1,                     ActionParams.NSPChargeAir,  0x12,           DSamusNSP.air_charge_main,  DSamusNSP.air_charge_interrupt_,    0x800D91EC,                     DSamusNSP.air_charge_collision_)    //NSP_Air_Charge
    Character.add_new_action(DSAMUS, DSPAir,            Action.SAMUS.BombAir,   ActionParams.DSPAir,        0x1E,           -1,                         -1,                                 DSamusDSP.air_physics_,         DSamusDSP.air_collision_)
    Character.add_new_action(DSAMUS, DSPLanding,        -1,                     ActionParams.DSPLanding,    0x1E,           0x800D94C4,                 0,                                  0x800D8BB4,                     0x800DDEE8)

    // Modify Menu Action Parameters                // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(DSAMUS,   0x0,               File.DSAMUS_IDLE_CSS,       -1,                          -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x1,               -1,                         VICTORY,                     -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x2,               File.DSAMUS_VICTORY1,       VICTORY1,                    -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x3,               File.DSAMUS_SELECT,         SELECT,                      -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x4,               File.DSAMUS_SELECT,         SELECT,                      -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x5,               -1,                         CLAP,                        -1)
    Character.edit_menu_action_parameters(DSAMUS,   0xD,               File.DSAMUS_1P_POSE,        0x80000000,                  -1)
    Character.edit_menu_action_parameters(DSAMUS,   0xE,               File.DSAMUS_1P_CPU_POSE,    0x80000000,                  -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.DSAMUS, 0x2)
    dh  0x0503
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.DSAMUS, 0x4)
    float32 1.05
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.DSAMUS, 0xC)
    dh 0x13
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.DSAMUS, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 5, 3, 7)
    Teams.add_team_costume(YELLOW, DSAMUS, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(DSAMUS, BLACK, YELLOW, ORANGE, BLUE, MAGENTA, RED, YELLOW, GREEN)

    Character.table_patch_start(variants, Character.id.DSAMUS, 0x4)
    db      Character.id.NONE   // set as SPECIAL variant for DSAMUS
    db      Character.id.NDSAMUS // set as POLYGON variant for DSAMUS
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.DSAMUS, 0x2)
    dh  0x0086
    OS.patch_end()

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.DSAMUS, 0x2)
    dh {MIDI.id.VS_DSAMUS}
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.DSAMUS, 0x4)
    dw      AI.PREVENT_ATTACK.ROUTINE.SONIC_DSP
    OS.patch_end()

    // // Prevents Dark Samus from losing a jump after using air down special
    // scope bomb_loss_prevention: {
        // OS.patch_start(0xD8D34, 0x8015E2F4)
        // j       bomb_loss_prevention
        // nop
        // _return:
        // OS.patch_end()

        // addiu   sp, sp,-0x0010              // allocate stack space
        // sw      t0, 0x0004(sp)              // ~
        // sw      t1, 0x0008(sp)              // store t0, t1
        // lw      t0, 0x0008(s0)              // current character ID
        // ori     t1, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        // beq     t1, t0, _end                // end if character id = DSAMUS
        // nop
        // sb      t9, 0x0148(s0)              // original code

        // _end:
        // lw      t0, 0x0004(sp)              // ~
        // lw      t1, 0x0008(sp)              // load t0, t1
        // addiu   sp, sp, 0x0010              // deallocate stack space
        // lw      ra, 0x0024(sp)              // original code
        // j       _return                     // return
        // nop
    // }

    // // Prevents Dark Samus from losing a jump after using ground down special
    // scope ground_bomb_loss_prevention: {
        // OS.patch_start(0xD8C04, 0x8015E1C4)
        // j       bomb_loss_prevention
        // nop
        // _return:
        // OS.patch_end()

        // addiu   sp, sp,-0x0010              // allocate stack space
        // sw      t0, 0x0004(sp)              // ~
        // sw      t1, 0x0008(sp)              // store t0, t1
        // lw      t0, 0x0008(s0)              // current character ID
        // ori     t1, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        // beq     t1, t0, _end                // end if character id = DSAMUS
        // nop
        // sb      t9, 0x0148(s0)              // original code

        // _end:
        // lw      t0, 0x0004(sp)              // ~
        // lw      t1, 0x0008(sp)              // load t0, t1
        // addiu   sp, sp, 0x0010              // deallocate stack space
        // lw      ra, 0x0024(sp)              // original code
        // j       _return                     // return
        // nop
    // }

  //      // Loads an alternate animation for Dark Samus bomb explosion if explodes via timer
  //  scope alt_bomb_explosion: {
  //      OS.patch_start(0xE3A04, 0x80168FC4)
  //      jal       alt_bomb_explosion
  //      addiu   a0, a0, 0x001C              // original line
  //      _return:
  //      OS.patch_end()
  //
  //      addiu   sp, sp,-0x0010              // allocate stack space
  //      sw      t0, 0x0004(sp)              // ~
  //      sw      t1, 0x0008(sp)              // store t0, t1
  //      lw      t0, 0x010C (a2)             // t0 = projectile type
  //      ori     t1, r0, TYPE                // t1 = Electric type
  //      beq     t0, t1, _dsbombgraphic      // branch if type = Electric
  //      nop
  //      lw      t0, 0x0004(sp)              // ~
  //      lw      t1, 0x0008(sp)              // load t0, t1
  //      addiu   sp, sp, 0x0010              // deallocate stack space
  //      j     0x801005C8                    // original line modified
  //      nop
  //
  //      _dsbombgraphic:
  //      lw      t0, 0x0004(sp)              // ~
  //      lw      t1, 0x0008(sp)              // load t0, t1
  //      addiu   sp, sp, 0x0010              // deallocate stack space
  //      addiu   sp, sp, 0xFFD8              // original line
  //      sw      a0, 0x0028(sp)              // original line
  //      lui     a0, 0x8013                  // original line
  //      lw      a0, 0x13C4(a0)              // original line
  //      sw      ra, 0x001C(sp)              // original line
  //      sw      s0, 0x0018(sp)              // original line
  //      addiu   a1, r0, 0x0078              // place new graphic ID
  //      lui     ra, 0x8010                  // set to original return address
  //      addiu   ra, ra, 0x05EC              // set to original return address
  //      j       0x800CE9E8                  // jump to "Create GFX"
  //      ori     a0, a0, 0x0008
  //      j       _return                     // return
  //      nop
  //  }
  //
  //  // Loads an alternate animation for Dark Samus bomb explosion if explodes via connecting with an opponent
  //  // active projectile struct is in 0x34(sp)
  //  scope alt_bomb_explosion_connect: {
  //      OS.patch_start(0xE3C58, 0x80169218)
  //      jal     alt_bomb_explosion_connect
  //      addiu   a0, a0, 0x001C              // original line
  //      _return:
  //      OS.patch_end()
  //
  //      addiu   sp, sp,-0x0010              // allocate stack space
  //      sw      t0, 0x0004(sp)              // ~
  //      sw      t1, 0x0008(sp)              // store t0, t1
  //      lw      t0, 0x0044(sp)              // load active projectile struct
  //      lw      t0, 0x010C (t0)             // t0 = projectile type
  //      ori     t1, r0, TYPE                // t1 = Electric type
  //      beq     t0, t1, alt_bomb_explosion._dsbombgraphic      // branch if type = Electric
  //      nop
  //      lw      t0, 0x0004(sp)              // ~
  //      lw      t1, 0x0008(sp)              // load t0, t1
  //      addiu   sp, sp, 0x0010              // deallocate stack space
  //      j     0x801005C8                    // original line modified
  //      nop
  //  }

    constant TYPE(0x2)                  // electric type damage used in Dark Samus down special in contrast to Samus (Fire type 0x1)
}
