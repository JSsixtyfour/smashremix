// DSamus.asm

// This file contains file inclusions, action edits, and assembly for Dark Samus.

scope DSamus {

    scope MODEL {
        scope HAND_L {
            constant DEFAULT(0xA0500000)
            constant OPEN(0xA0500001)
        }
    }

    // Insert Moveset files
    insert ROLLSUB, "moveset/ROLLSUBROUTINE.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert RUN_LOOP, "moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP)           // loops
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert FTILTUP, "moveset/FTILTUP.bin"
    insert FTILTMIDUP, "moveset/FTILTMIDUP.bin"
    insert FTILTMID, "moveset/FTILTMID.bin"
    insert FTILTDOWN, "moveset/FTILTDOWN.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert FSMASHUP, "moveset/FSMASHUP.bin"
    insert FSMASHMIDUP, "moveset/FSMASHMIDUP.bin"
    insert FSMASHMID, "moveset/FSMASHMID.bin"
    insert FSMASHMIDDOWN, "moveset/FSMASHMIDDOWN.bin"
    insert FSMASHDOWN, "moveset/FSMASHDOWN.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UP_SPECIAL_AIR, "moveset/UP_SPECIAL_AIR.bin"
    insert UP_SPECIAL_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    ROLLF:; Moveset.CONCURRENT_STREAM(ROLLSUB); insert "moveset/FROLL.bin"
    insert NEUTRAL1, "moveset/NEUTRAL1.bin"
    insert CLIFFATTACKSLOW, "moveset/CLIFFATTACKSLOW.bin" // cliff attack 2
    insert DASHATTACK, "moveset/DASH.bin"
    //insert DAIR, "moveset/DAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert LANDING_NAIR, "moveset/LANDING_NAIR.bin"
    insert VICTORY, "moveset/VICTORY.bin"
    insert VICTORY1, "moveset/VICTORY1.bin"
    insert SELECT, "moveset/SELECT.bin"
    insert CHARGE, "moveset/CHARGE.bin"
    insert CHARGELOOP, "moveset/CHARGELOOP.bin"; Moveset.GO_TO(CHARGELOOP)    // loops
    insert CLAP, "moveset/CLAP.bin"
    insert TAUNT, "moveset/TAUNT.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.Entry,          File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(DSAMUS, 0x006,                 File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.Idle,           File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.ReviveWait,     File.DARK_SAMUS_IDLE,       -1,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.Dash,           File.DSAMUS_DASH,           -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.TurnRun,        File.DSAMUS_TURNRUN,        -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RunBrake,       File.DSAMUS_RUNBRAKE,       -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Walk3,          File.DSAMUS_WALK3,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Run,            File.DSAMUS_RUN,            RUN_LOOP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          ROLLF,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          ROLLSUB,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpF,          File.DSAMUS_JUMPF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpB,          File.DSAMUS_JUMPB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,    0x8E6,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,    0x8E7,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.Jab1,           -1,                         NEUTRAL1,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.CliffAttackSlow2,-1,                        CLIFFATTACKSLOW,            -1)

    Character.edit_action_parameters(DSAMUS, Action.DashAttack,     -1,                         DASHATTACK,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     File.DSAMUS_NAIR,           NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.LandingAirN,    File.DSAMUS_NAIR_LANDING,   LANDING_NAIR,               -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,     File.DSAMUS_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirB,     File.DSAMUS_BAIR,           BAIR,                       -1)
    // Character.edit_action_parameters(DSAMUS, Action.AttackAirD,     -1,                         DAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltHigh,      -1,                         FTILTUP,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidHigh,   -1,                         FTILTMIDUP,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.FTilt,          -1,                         FTILTMID,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidLow,    -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltLow,       -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,          File.DSAMUS_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.USmash,         File.DSAMUS_UPSMASH,        USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,         File.DSAMUS_DSMASH,         DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashHigh,     -1,                         FSMASHUP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidHigh,  -1,                         FSMASHMIDUP,                -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmash,         -1,                         FSMASHMID,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidLow,   -1,                         FSMASHMIDDOWN,              -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashLow,      -1,                         FSMASHDOWN,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.Taunt,          File.DSAMUS_TAUNT,          TAUNT,                      -1)
    Character.edit_action_parameters(DSAMUS, 0xE3,                  -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, 0xE4,                  -1,                         UP_SPECIAL_AIR,             -1)
    Character.edit_action_parameters(DSAMUS, 0xDF,                  -1,                         CHARGE,                     -1)

    Character.edit_action_parameters(DSAMUS,    Action.EggLay,      File.DARK_SAMUS_IDLE,       -1,                         -1)

     // Modify Actions            // Action             // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
       Character.edit_action(DSAMUS, 0xE4,                 -1,             -1,                         0x80160370,                     -1,                             -1)

    // Modify Menu Action Parameters                // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(DSAMUS,   0x0,                File.DARK_SAMUS_IDLE,      -1,                          -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x1,               -1,                         VICTORY,                     -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x2,               File.DSAMUS_VICTORY1,       VICTORY1,                    -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x3,               File.DSAMUS_SELECT,         SELECT,                      -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x4,               File.DSAMUS_SELECT,         SELECT,                      -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x5,               -1,                         CLAP,                        -1)
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
    dw  Action.SAMUS.action_string_table
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 5, 1, 3)
    Teams.add_team_costume(YELLOW, DSAMUS, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(DSAMUS, BLUE, YELLOW, ORANGE, GREEN, MAGENTA, RED, YELLOW, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.DSAMUS, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

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

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  25,  33,  -1, -1, -10, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  10,  14,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  8,   10,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  10,  13,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  3,   25,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   26,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  14,  22,  -1, -1, -25, 1250)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  -1,  -1,  -1, -1, -1, -1)

    // Prevents Dark Samus from losing a jump after using air down special
    scope bomb_loss_prevention: {
        OS.patch_start(0xD8D34, 0x8015E2F4)
        j       bomb_loss_prevention
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // current character ID
        ori     t1, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        beq     t1, t0, _end                // end if character id = DSAMUS
        nop
        sb      t9, 0x0148(s0)              // original code

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      ra, 0x0024(sp)              // original code
        j       _return                     // return
        nop
    }

    // Prevents Dark Samus from losing a jump after using ground down special
    scope ground_bomb_loss_prevention: {
        OS.patch_start(0xD8C04, 0x8015E1C4)
        j       bomb_loss_prevention
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // current character ID
        ori     t1, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        beq     t1, t0, _end                // end if character id = DSAMUS
        nop
        sb      t9, 0x0148(s0)              // original code

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      ra, 0x0024(sp)              // original code
        j       _return                     // return
        nop
    }

        // Loads an alternate animation for Dark Samus bomb explosion if explodes via timer
    scope alt_bomb_explosion: {
        OS.patch_start(0xE3A04, 0x80168FC4)
        jal       alt_bomb_explosion
        addiu   a0, a0, 0x001C              // original line
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x010C (a2)             // t0 = projectile type
        ori     t1, r0, TYPE                // t1 = Electric type
        beq     t0, t1, _dsbombgraphic      // branch if type = Electric
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j     0x801005C8                    // original line modified
        nop

        _dsbombgraphic:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        addiu   sp, sp, 0xFFD8              // original line
        sw      a0, 0x0028(sp)              // original line
        lui     a0, 0x8013                  // original line
        lw      a0, 0x13C4(a0)              // original line
        sw      ra, 0x001C(sp)              // original line
        sw      s0, 0x0018(sp)              // original line
        addiu   a1, r0, 0x0078              // place new graphic ID
        lui     ra, 0x8010                  // set to original return address
        addiu   ra, ra, 0x05EC              // set to original return address
        j       0x800CE9E8                  // jump to "Create GFX"
        ori     a0, a0, 0x0008
        j       _return                     // return
        nop
    }

    // Loads an alternate animation for Dark Samus bomb explosion if explodes via connecting with an opponent
    // active projectile struct is in 0x34(sp)
    scope alt_bomb_explosion_connect: {
        OS.patch_start(0xE3C58, 0x80169218)
        jal     alt_bomb_explosion_connect
        addiu   a0, a0, 0x001C              // original line
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0044(sp)              // load active projectile struct
        lw      t0, 0x010C (t0)             // t0 = projectile type
        ori     t1, r0, TYPE                // t1 = Electric type
        beq     t0, t1, alt_bomb_explosion._dsbombgraphic      // branch if type = Electric
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j     0x801005C8                    // original line modified
        nop
    }

    constant TYPE(0x2)                  // electric type damage used in Dark Samus down special in contrast to Samus (Fire type 0x1)
}
