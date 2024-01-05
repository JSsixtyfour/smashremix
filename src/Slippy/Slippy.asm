// Slippy.asm

// This file contains file inclusions, action edits, and assembly for Slippy Toad.

scope Slippy {
    include "SlippyHipTranslation.asm"

    scope MODEL {
        scope FACE {
            constant NORMAL(0xAC000000)
            constant HURT(0xAC000001)
        }
    }

    // Insert Moveset files
    CLIFF_CATCH:; dw MODEL.FACE.HURT; Moveset.HURTBOXES(3); Moveset.SFX(0x13); dw 0;
    CLIFF_WAIT:; dw MODEL.FACE.HURT; Moveset.HURTBOXES(3); Moveset.WAIT(0x3C); Moveset.HURTBOXES(1); dw 0;

    insert DASH,"moveset/DASH.bin"
    insert RUN,"moveset/RUN.bin"
    insert RUN_LOOP,"moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP) // loops
    insert RUN_TURN,"moveset/RUN_TURN.bin"
    insert JUMP_1,"moveset/JUMP_1.bin"
    insert JUMP_2,"moveset/JUMP_2.bin"
    insert LANDING_SPECIAL, "moveset/LANDING_SPECIAL.bin"
    insert FROLL, "moveset/FROLL.bin"
    insert BROLL, "moveset/BROLL.bin"
    insert TECH_STAND, "moveset/TECH_STAND.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_DATA,"moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert BTHROW_DATA,"moveset/BTHROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BTHROW.bin"
    insert TEETERING, "moveset/TEETERING.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops

    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert DASH_ATTACK, "moveset/DASH_ATTACK.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"

    insert NSP_GROUND,"moveset/NEUTRAL_SPECIAL.bin"
    NSP_AIR:
    dw 0x98004000
    dw 0x00000000
    dw 0xFF2E0000
    dw 0x00000000
    Moveset.GO_TO(NSP_GROUND + 0x14)
    insert USP_BEGIN,"moveset/USP_BEGIN.bin"
    insert USP_CHARGE,"moveset/USP_CHARGE.bin"
    insert USP_MOVE,"moveset/USP_MOVE.bin"
    insert USP_LOOP,"moveset/USP_LOOP.bin"; Moveset.GO_TO(USP_LOOP) // loops
    insert USP_END_G,"moveset/USP_END_G.bin"
    insert USP_BOUNCE,"moveset/USP_BOUNCE.bin"
    insert DSP_GROUND_START,"moveset/DOWN_SPECIAL_GROUND_START.bin"
    insert DSP_AIR_START,"moveset/DOWN_SPECIAL_AIR_START.bin"

    insert VICTORY_POSE_1,"moveset/VICTORY_POSE_1.bin"
    insert VICTORY_POSE_2,"moveset/VICTORY_POSE_2.bin"
    insert SELECT,"moveset/SELECT.bin"

    insert SHINE,"moveset/SHINE.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Slippy's extra actions
    scope Action {
        constant Jab3(0x0DC)
        //constant JabLoop(0x0DD)
        //constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant Blaster(0x0E1)
        constant BlasterAir(0x0E2)
        constant JetPackAir(0x0E3)
        constant JetPackStart(0x0E4)
        //constant ReadyingFireFox(0x0E5)
        constant WolfFlash(0x0E6)
        //constant FireFox(0x0E7)
        constant WolfFlashAir(0x0E8)
        //constant FireFoxEnd(0x0E9)
        //constant FireFoxEndAir(0x0EA)
        //constant LandingFireFoxAir(0x0EB)
        constant ReflectorStart(0x0EC)
        constant Reflecting(0x0ED)
        constant ReflectorEnd(0x0EE)
        constant ReflectorLoop(0x0EF)
        constant ReflectorSwitchDirection(0x0F0)
        constant ReflectorStartAir(0x0F1)
        // constant ?(0x0F2)
        constant ReflectorEndAir(0x0F3)
        constant ReflectorAir(0x0F4)
        constant ReflectorSwitchDirectionAir(0x0F5)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("JabLoop")
        //string_0x0DE:; String.insert("JabLoopEnd")
        //string_0x0DF:; String.insert("Appear1")
        //string_0x0E0:; String.insert("Appear2")
        string_0x0E1:; String.insert("DemonSniper")
        string_0x0E2:; String.insert("DemonSniperAir")
        string_0x0E3:; String.insert("JetPackAir")
        string_0x0E4:; String.insert("JetPackStart")
        string_0x0E5:; String.insert("JetPackReadying")
        string_0x0E6:; String.insert("JetPackFlash")
        string_0x0E7:; String.insert("FireFox")
        string_0x0E8:; String.insert("JetPackAir")
        string_0x0E9:; String.insert("JetPackEnd")
        string_0x0EA:; String.insert("JetPackEndAir")
        string_0x0EB:; String.insert("JetPackLandingAir")
        //string_0x0EC:; String.insert("ReflectorStart")
        //string_0x0ED:; String.insert("Reflecting")
        //string_0x0EE:; String.insert("ReflectorEnd")
        //string_0x0EF:; String.insert("ReflectorLoop")
        //string_0x0F0:; String.insert("ReflectorSwitchDirection")
        //string_0x0F1:; String.insert("ReflectorStartAir")
        //string_0x0F2:; String.insert("ReflectingAir")
        //string_0x0F3:; String.insert("ReflectorEndAir")
        //string_0x0F4:; String.insert("ReflectorAir")
        //string_0x0F5:; String.insert("ReflectorSwitchDirectionAir")

        action_string_table:
        dw 0 //dw Action.COMMON.string_jab3
        dw 0 //dw Action.COMMON.string_jabloop
        dw 0 //dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw Action.FOX.string_0x0EC
        dw Action.FOX.string_0x0ED
        dw Action.FOX.string_0x0EE
        dw Action.FOX.string_0x0EF
        dw Action.FOX.string_0x0F0
        dw Action.FOX.string_0x0F1
        dw Action.FOX.string_0x0F2
        dw Action.FOX.string_0x0F3
        dw Action.FOX.string_0x0F4
        dw Action.FOX.string_0x0F5
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.SLIPPY, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Modify Action Parameters              // Action                  // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(SLIPPY, Action.Idle,               0x1F3,                      -1,                         -1); add_hip_translation(Action.Idle, 1.6)
    Character.edit_action_parameters(SLIPPY, 0x06,                      0x1F3,                      -1,                         -1); add_hip_translation(0x06, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Entry,              0x1F3,                      -1,                         -1); add_hip_translation(Action.Entry, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.ReviveWait,         0x1F3,                      -1,                         -1); add_hip_translation(Action.ReviveWait, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.EggLay,             0x1F3,                      -1,                         -1); add_hip_translation(Action.EggLay, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Dash,               File.WARIO_DASH,            DASH,                       -1); add_hip_translation(Action.Dash, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Run,                File.WARIO_RUN,             RUN,                        -1); add_hip_translation(Action.Run, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.RunBrake,           0x451,                      -1,                         -1); add_hip_translation(Action.RunBrake, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Turn,               0x1FB,                      -1,                         -1); add_hip_translation(Action.Turn, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.TurnRun,            File.WARIO_RUN_TURN,        RUN_TURN,                   -1); add_hip_translation(Action.TurnRun, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Fall,               0x201,                      -1,                         -1); add_hip_translation(Action.Fall, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.FallAerial,         0x202,                      -1,                         -1); add_hip_translation(Action.FallAerial, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.JumpF,              File.WARIO_JUMP_F,          JUMP_1,                     -1); add_hip_translation(Action.JumpF, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.JumpB,              File.WARIO_JUMP_B,          JUMP_1,                     -1); add_hip_translation(Action.JumpB, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.JumpAerialF,        File.WARIO_JUMP_AERIAL_F,   JUMP_2,                     -1); add_hip_translation(Action.JumpAerialF, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.JumpAerialB,        File.WARIO_JUMP_AERIAL_B,   JUMP_2,                     -1); add_hip_translation(Action.JumpAerialB, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Crouch,             0x203,                      -1,                         -1); add_hip_translation(Action.Crouch, 1.5)
    Character.edit_action_parameters(SLIPPY, Action.CrouchIdle,         0x204,                      -1,                         -1); add_hip_translation(Action.CrouchIdle, 1.5)
    Character.edit_action_parameters(SLIPPY, Action.CrouchEnd,          0x205,                      -1,                         -1); add_hip_translation(Action.CrouchEnd, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.LandingSpecial,     -1,                         LANDING_SPECIAL,            -1)
    Character.edit_action_parameters(SLIPPY, Action.Walk1,              File.CONKER_WALK1,          -1,                         -1); add_hip_translation(Action.Walk1, 0.95)
    Character.edit_action_parameters(SLIPPY, Action.Walk2,              File.CONKER_WALK2,          -1,                         -1); add_hip_translation(Action.Walk2, 0.95)
    Character.edit_action_parameters(SLIPPY, Action.Walk3,              File.CONKER_WALK3,          -1,                         -1); add_hip_translation(Action.Walk3, 0.97)
    Character.edit_action_parameters(SLIPPY, Action.Teeter,             0x208,                      0x80000000,                 -1); add_hip_translation(Action.Teeter, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.TeeterStart,        0x209,                      0x80000000,                 -1); add_hip_translation(Action.TeeterStart, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.CliffCatch,         -1,                         CLIFF_CATCH,                -1)
    Character.edit_action_parameters(SLIPPY, Action.CliffWait,          -1,                         CLIFF_WAIT,                 -1)
    Character.edit_action_parameters(SLIPPY, Action.CliffEscapeQuick1,  0x248,                      -1,                         -1); add_hip_translation(Action.CliffEscapeQuick1, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.CliffEscapeQuick2,  0x249,                      -1,                         -1); add_hip_translation(Action.CliffEscapeQuick2, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.ShieldOn,           0x22D,                      -1,                         -1); add_hip_translation(Action.ShieldOn, 1.6); add_hip_translation(Action.Shield, 1.6); add_hip_translation(Action.ShieldStun, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.ShieldOff,          0x22E,                      -1,                         -1); add_hip_translation(Action.ShieldOff, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.RollF,              -1,                         FROLL,                      -1)
    Character.edit_action_parameters(SLIPPY, Action.RollB,              -1,                         BROLL,                      -1)
    Character.edit_action_parameters(SLIPPY, Action.TechF,              -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(SLIPPY, Action.TechB,              -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(SLIPPY, Action.Tech,               -1,                         TECH_STAND,                 -1)
    Character.edit_action_parameters(SLIPPY, Action.Teeter,             -1,                         TEETERING,                  -1)
    Character.edit_action_parameters(SLIPPY, Action.ShieldBreak,        -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(SLIPPY, Action.Stun,               -1,                         STUN,                       -1)
    Character.edit_action_parameters(SLIPPY, Action.Sleep,              -1,                         ASLEEP,                     -1)
    Character.edit_action_parameters(SLIPPY, Action.Taunt,              File.WARIO_TAUNT,           TAUNT,                      -1); add_hip_translation(Action.Taunt, 1.6)

    Character.edit_action_parameters(SLIPPY, Action.Grab,               File.WARIO_GRAB,            GRAB,                       -1); add_hip_translation(Action.Grab, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.GrabPull,           File.SLIPPY_GRAB_PULL,      -1,                         -1)
    Character.edit_action_parameters(SLIPPY, Action.ThrowF,             0x233,                      FTHROW,                     -1); add_hip_translation(Action.ThrowF, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.ThrowB,             File.WARIO_BTHROW,          BTHROW,                     0x50000000); add_hip_translation(Action.ThrowB, 1.5)
    Character.edit_action_parameters(SLIPPY, Action.Jab1,               0x25E,                      JAB_1,                      -1); add_hip_translation(Action.Jab1, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.Jab2,               0x25F,                      JAB_2,                      -1); add_hip_translation(Action.Jab2, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.DashAttack,         0x454,                      DASH_ATTACK,                -1); add_hip_translation(Action.DashAttack, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.UTilt,              File.WARIO_UTILT,           UTILT,                      -1); add_hip_translation(Action.UTilt, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.DTilt,              0x455,                      DTILT,                      -1); add_hip_translation(Action.DTilt, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.FSmash,             File.WARIO_FSMASH,          FSMASH,                     0x40000000); add_hip_translation(Action.FSmash, 1.3)
    Character.edit_action_parameters(SLIPPY, Action.USmash,             0x26C,                      USMASH,                     -1); add_hip_translation(Action.USmash, 1.3)
    Character.edit_action_parameters(SLIPPY, Action.DSmash,             File.WARIO_DSMASH,          DSMASH,                     0x80000000); add_hip_translation(Action.DSmash, 1.4)
    Character.edit_action_parameters(SLIPPY, Action.AttackAirN,         File.WARIO_NAIR,            NAIR,                       -1); add_hip_translation(Action.AttackAirN, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.AttackAirF,         File.WARIO_FAIR,            FAIR,                       -1); add_hip_translation(Action.AttackAirF, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.AttackAirB,         0x270,                      BAIR,                       -1); add_hip_translation(Action.AttackAirB, 1.6)
    Character.edit_action_parameters(SLIPPY, Action.AttackAirU,         -1,                         UAIR,                       -1)
    Character.edit_action_parameters(SLIPPY, Action.AttackAirD,         File.WARIO_DAIR,            DAIR,                        0)
    Character.edit_action_parameters(SLIPPY, Action.LandingAirB,        0x274,                      -1,                         -1); add_hip_translation(Action.LandingAirB, 1.6)

    Character.edit_action_parameters(SLIPPY, 0xE1,                      0x25D,                      NSP_GROUND,                 0);add_hip_translation(0xE1, 1.6)
 	Character.edit_action_parameters(SLIPPY, 0xE2,                      0x281,                      NSP_AIR,                    0);add_hip_translation(0xE2, 1.6)
    Character.edit_action_parameters(SLIPPY, 0xE3,                      -1,                         USP_BEGIN,                  -1)
    Character.edit_action_parameters(SLIPPY, 0xE4,                      -1,                         USP_BEGIN,                  -1)
    Character.edit_action_parameters(SLIPPY, 0xE5,                      -1,                         USP_CHARGE,                 -1)
    Character.edit_action_parameters(SLIPPY, 0xE6,                      -1,                         USP_CHARGE,                 -1)
    Character.edit_action_parameters(SLIPPY, 0xE7,                      -1,                         USP_MOVE,                   -1)
    Character.edit_action_parameters(SLIPPY, 0xE8,                      -1,                         USP_MOVE,                   -1)
    Character.edit_action_parameters(SLIPPY, 0xE9,                      -1,                         USP_END_G,                  -1)
    Character.edit_action_parameters(SLIPPY, 0xEB,                      -1,                         USP_BOUNCE,                 -1)
    Character.edit_action_parameters(SLIPPY, 0xEC,                      -1,                         DSP_GROUND_START,           -1)
    Character.edit_action_parameters(SLIPPY, 0xF1,                      -1,                         DSP_AIR_START,              -1)
    Character.edit_action_parameters(SLIPPY, Action.FOX.ReflectorLoop,  -1,                         SHINE,                      -1)
    Character.edit_action_parameters(SLIPPY, Action.FOX.ReflectorAir,   -1,                         SHINE,                      -1)

    Character.edit_action_parameters(SLIPPY, Action.HeavyItemPickup,    0x255,                      -1,                        -1)
    Character.edit_action_parameters(SLIPPY, Action.HeavyItemThrowF,    0x256,                      -1,                        -1)
    Character.edit_action_parameters(SLIPPY, Action.HeavyItemThrowB,    0x256,                      -1,                        -1)
    Character.edit_action_parameters(SLIPPY, Action.HeavyItemThrowSmashF, 0x256,                    -1,                        -1)
    Character.edit_action_parameters(SLIPPY, Action.HeavyItemThrowSmashB, 0x256,                    -1,                        -1)

    // Modify Actions               // Action           // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(SLIPPY,   0xE1,               -1,             SlippyNSP.main_,            -1,                             -1,                             -1)
    Character.edit_action(SLIPPY,   0xE2,               -1,             SlippyNSP.main_,            -1,                             -1,                             SlippyNSP.air_collision_)
    Character.edit_action(SLIPPY,   0xE8,               -1,             -1,                         -1,                             SlippyUSP.movement_physics_,    -1)
    Character.edit_action(SLIPPY,   0xF3,               -1,             -1,                         -1,                             SlippyDSP.air_physics_,         -1)
    Character.edit_action(SLIPPY,   0xF4,               -1,             -1,                         -1,                             SlippyDSP.air_physics_,         -1)
    Character.edit_action(SLIPPY,   0xF5,               -1,             -1,                         -1,                             SlippyDSP.air_physics_,         -1)

    // Modify Menu Action Parameters                // Action       // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(SLIPPY,   0x0,            0x1F3,                      -1,                         -1); add_hip_translation(0x00010000, 1.6)
    Character.edit_menu_action_parameters(SLIPPY,   0x1,            0x166,                      VICTORY_POSE_1,             -1); add_hip_translation(0x00010001, 1.6)
    Character.edit_menu_action_parameters(SLIPPY,   0x2,            File.SLIPPY_SELECT,         SELECT,                     0x00000000)
    Character.edit_menu_action_parameters(SLIPPY,   0x3,            0x1CF,                      VICTORY_POSE_2,             -1); add_hip_translation(0x00010003, 1.6)
    Character.edit_menu_action_parameters(SLIPPY,   0x4,            File.SLIPPY_SELECT,         SELECT,                     0x00000000)
    Character.edit_menu_action_parameters(SLIPPY,   0x5,            0x169,                      -1,                         -1); add_hip_translation(0x00010005, 1.6)
    Character.edit_menu_action_parameters(SLIPPY,   0xD,            File.SLIPPY_1P_POSE,        0x80000000,                 -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.SLIPPY, 0x4)
    float32 1.14
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.SLIPPY, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.SLIPPY, 0xC)
    dh 0x23
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.SLIPPY, 0, 1, 4, 5, 1, 0, 3)
    Teams.add_team_costume(YELLOW, SLIPPY, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(SLIPPY, WHITE, RED, BLUE, TURQUOISE, PURPLE, ORANGE, YELLOW, NA)

    Character.table_patch_start(variant_original, Character.id.SLIPPY, 0x4)
    dw      Character.id.FALCO // set Falco as original character (not Fox, who SLIPPY is a clone of)
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.SLIPPY, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.SLIPPY, 0x4)
    dw      AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  5,   0,  -1, -1, -1, -1)   // todo: confirm coords for all
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  -1,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  -1,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  14,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  3,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  12,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  8,  0,  -1, -1, -1, -1) // fair actually comes out frame 5, but bair is frame 10
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,   0,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,   0,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  3,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  31,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  31,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  13,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  13,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  7,  0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,   0,  -1, -1, -1, -1)

    // @ Description
    // Patch which allows Slippy Toad's jab 2 to cancel back into jab 1.
    scope unique_jab_loop_: {
        OS.patch_start(0xC9B34, 0x8014F0F4)
        j       unique_jab_loop_
        nop
        _return:
        OS.patch_end()

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      v1, 0x0008(v1)              // v1 = character
        lli     at, Character.id.SLIPPY     // at = id.SLIPPY
        bne     v1, at, _original           // branch if character != SLIPPY
        nop

        _slippy:
        j       0x8014EA44                  // switch to subroutine 0x8014EA44 (begin jab 1)
        nop

        _original:
        addiu   sp, sp,-0x0028              // original line 1
        j       _return                     // return
        sw      ra, 0x001C(sp)              // original line 2
    }

    // Modifies function 0x8000CCBC to support applying a Y translation multiplier to a given joint during animations.
    // Replaces original stack allocation and sets default translation multiplier to 1.0. (1/2)
    scope animate_part_patch_: {
        // patch beginning of function
        OS.patch_start(0xD8BC, 0x8000CCBC)
        j       animate_part_patch_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0070              // allocate stack space (original -0x0058)
        sw      ra, 0x004C(sp)              // store ra (original line 2)
        lui     at, 0x3F80                  // at = float: 1.0
        j       _return                     // return and continue original subroutine
        sw      at, 0x0060(sp)              // set default Y translation multiplier to 1.0

        // patch end of function
        OS.patch_start(0xDB64, 0x8000CF64)
        jr      ra                          // original line 1
        addiu   sp, sp, 0x0070              // deallocate stack space (original 0x0058)
        OS.patch_end()
    }

    // Modifies function 0x8000CCBC to support applying a Y translation multiplier to a given joint during animations.
    // Applies Y translation multiplier. (2/2)
    scope apply_y_multiplier_: {
        OS.patch_start(0xDAE8, 0x8000CEE8)
        j       apply_y_multiplier_
        nop
        OS.patch_end()

        lwc1    f8, 0x0060(sp)              // f8 = Y translation multiplier
        mul.s   f26, f26, f8                // update Y translation
        j       0x8000CF0C                  // jump to 0x8000CF0C (original line 1)
        swc1    f26, 0x0020(a3)             // store Y translation (original line 2)
    }

    // Alternate version of function 0x8000CCBC, sets the Y translation multiplier.
    // a0 = part to animate
    // a1 = Y translation to be added
    scope animate_part_y_multiplier_: {
        addiu   sp, sp,-0x0070              // allocate stack space (original -0x0058)
        sw      ra, 0x004C(sp)              // store ra (original line 2)
        j       0x8000CCC4                  // jump into function 0x8000CCBC and continue
        sw      a1, 0x0060(sp)              // store Y translation
    }

    // Patch which applies Y translation multipliers to Slippy's hips for certain animations.
    scope hips_y_translation_: {
        OS.patch_start(0x63BD8, 0x800E83D8)
        j       hips_y_translation_
        or      a0, s1, r0                  // a0 = part struct (original line 2)
        _return:
        OS.patch_end()

        lw      t6, 0x0008(s6)              // t6 = character id
        lli     t7, Character.id.SLIPPY     // t7 = id.Slippy
        bne     t6, t7, _original           // skip if character != SLIPPY
        lw      t6, 0x8F8(s6)               // t6 = part 0 struct
        bne     t6, s1, _original           // skip if part struct != part 0
        nop

        // if we're here, slippy's hips are being animated, so load Y translation multiplier
        lw      t6, 0x0024(s6)              // s6 = current action
        lui     t7, 0x0001
        and     t8, t6, t7                  // t8 = 0x10000 if menu action, 0 otherwise
        bnezl   t8, _menu                   // branch if menu action
        andi    t6, t6, 0xFFFF              // bitmask for correct offset

        _match:
        li      t7, hip_translation_table   // t7 = hip_translation_table
        b       _end                        // branch to end
        nop

        _menu:
        li      t7, hip_translation_menu_table // t7 = hip_translation_table

        _end:
        sll     t6, t6, 0x2                 // t6 = offset (action * 4)
        addu    t6, t6, t7                  // t6 = Y translation address (table + offset)
        jal     animate_part_y_multiplier_  // apply animation with multiplier
        lw      a1, 0x0000(t6)              // a1 = Y translation multiplier
        j       _return                     // return
        nop

        _original:
        jal     0x8000CCBC                  // apply animation (original line 1)
        nop
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which forces Slippy Toad's up special to be angled upwards, only allowing the x input to influence the angle. (1/3)
    scope up_special_angle_patch_1_: {
    OS.patch_start(0xD6F90, 0x8015C550)
        j       up_special_angle_patch_1_
        swc1    f16, 0x0040(sp)             // original line 2
        _return:
        OS.patch_end()

        lw      t0, 0x0008(s0)              // t0 = character id
        lli     at, Character.id.SLIPPY     // t0 = id.Slippy
        bne     t0, at, _original           // skip if character != SLIPPY
        lb      t0, 0x01C3(s0)              // t0 = stick_y (original line 1)

        // if the character is slippy
        lli     t0, 0x012C                  // force hard coded stick_y value

        _original:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which forces Slippy Toad's up special to be angled upwards, only allowing the x input to influence the angle. (2/3)
    scope up_special_angle_patch_2_: {
    OS.patch_start(0xD707C, 0x8015C63C)
        j       up_special_angle_patch_2_
        nop
        nop
        _return:
        OS.patch_end()

        lw      a0, 0x0008(s0)              // a0 = character id
        lli     t8, Character.id.SLIPPY     // t8 = id.Slippy
        beq     a0, t8, _branch             // always branch if character = SLIPPY...
        lli     a0, 0x012C                  // ...and force hard coded stick_y value

        // if the character isn't slippy, replicate the original branch we replaced
        lb      a0, 0x01C3(s0)              // a0 = stick_y (original line 1)
        bgez    a0, _branch                 // branches if y input is detected (original line 2)
        nop

        _no_branch:
        j       _return                     // return
        or      v1, a0, r0                  // original line 3

        _branch:
        j       0x8015C650                  // original branch destination
        or      v1, a0, r0                  // original line 3
    }

    // @ Description
    // Patch which forces Slippy Toad's up special to be angled upwards, only allowing the x input to influence the angle. (3/3)
    scope up_special_angle_patch_3_: {
    OS.patch_start(0xD70C8, 0x8015C688)
        j       up_special_angle_patch_3_
        lw      t9, 0x0044(s0)              // original line 2
        _return:
        OS.patch_end()

        lw      a0, 0x0008(s0)              // a0 = character id
        lli     t0, Character.id.SLIPPY     // t0 = id.Slippy
        bne     a0, t0, _original           // skip if character != SLIPPY
        lb      a0, 0x01C3(s0)              // t0 = stick_y (original line 1)

        // if the character is slippy
        lli     a0, 0x012C                  // force hard coded stick_y value

        _original:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patches  a small subroutine which usually sets the up special duration for Fox.
    // Sets a different value for Slippy Toad.
    scope up_special_duration_: {
        OS.patch_start(0xD6F08, 0x8015C4C8)
        j       up_special_duration_
        nop
        _return:
        OS.patch_end()

        lw      t6, 0x0008(a0)              // t6 = character id
        lli     at, Character.id.SLIPPY     // at = id.SLIPPY
        beq     at, t6, _end                // branch if chracter = SLIPPY
        lli     t6, SlippyUSP.DURATION      // up special duration = SlippyUSP.DURATION

        // if the character isn't Slippy
        addiu   t6, r0, 0x001E              // up special duration = 0x1E (30) (original line 1)

        _end:
        j       _return                     // continue original subroutine
        sw      t6, 0x0B24(a0)              // store duration (original line 2)
    }

    // @ Description
    // Extends the end of Fox's USP collision function. Adds a ledge grab check for Slippy.
    scope usp_collision_patch_: {
    OS.patch_start(0xD6E98, 0x8015C458)
        j       usp_collision_patch_
        lw      a0, 0x0020(sp)              // a0 = player object
        _return:
        OS.patch_end()

        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0008(t6)              // t6 = character id
        lli     at, Character.id.SLIPPY     // at = id.SLIPPY
        bne     at, t6, _end                // branch if chracter != SLIPPY
        nop

        // if the character is Slippy, check for ledge grabs
        jal     SlippyUSP.check_ledge_grab_ // unknown up special subroutine (original line 1)
        lw      a0, 0x0020(sp)              // a0 = player object (original line 2)

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0018(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original ending
    }
}
