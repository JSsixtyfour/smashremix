// Ebi.asm

// This file contains file inclusions, action edits, and assembly for Ebi.

scope Ebi {
    // Model Commands
    scope MODEL {
        scope WEAPON {
            constant HIDE(0xA0880000)
            constant FLUTE(0xA0880001)
            constant MEAT(0xA0880002)   // meat hammer
            constant HAMMER(0xA0880003) // basic hammer
            constant PADDLE(0xA0880004) // wooden paddle
            constant FAN(0xA0880005)    // paper fan
            constant CAMERA(0xA0880006) // ghost camera
        }

        scope CHAIN {
            constant HIDE_BASE(0xA0880000)
            constant HIDE_1(0xA0900000)
            constant HIDE_2(0xA0980000)
            constant HIDE_3(0xA0A00000)
            constant HIDE_4(0xA0A80000)
            constant HIDE_5(0xA0B00000)
            constant HIDE_6(0xA0B80000)
            constant HIDE_7(0xA0C00000)
            constant HIDE_END(0xA0C80000)
            constant SHOW_BASE(0xA0880002)
            constant SHOW_1(0xA0900001)
            constant SHOW_2(0xA0980001)
            constant SHOW_3(0xA0A00001)
            constant SHOW_4(0xA0A80001)
            constant SHOW_5(0xA0B00001)
            constant SHOW_6(0xA0B80001)
            constant SHOW_7(0xA0C00001)
            constant SHOW_END(0xA0C80001)
        }
        scope HAND_L {
            constant DEFAULT(0xA0500000)
            constant OPEN(0xA0500001)
            constant PADDLE(0xA0500002)
            constant POINT(0xA0500003)
        }
        scope HAND_R {
            constant DEFAULT(0xA0800000)
            constant OPEN(0xA0800001)
            constant RYO(0xA0800002)
            constant POINT(0xA0800003)
        }
        scope YOYO {
            constant HIDE(0xA127FFFF)
            constant SHOW(0xA1200000)
        }
        scope FACE {
            constant NORMAL(0xAC000000)
            constant HURT(0xAC000001)
            constant IDLE_BLINK(0xAC000002)
            constant IDLE(0xAC000003)
            constant ATTACK(0xAC000004)
            constant BLUSH(0xAC000005)
            constant SLEEP(0xAC000006)
            constant DIZZY(0xAC000007)
        }
    }
    
    EBI_GROW: // victory 1
    Moveset.WAIT(15);
    dw 0xB1EC0000
    Moveset.WAIT(0x10);
    Moveset.VOICE(0x0525);
    dw 0
    
    ENTRY:
    Moveset.WAIT(1);
    dw 0x5C000001;
    Moveset.WAIT(44);
    Moveset.SFX(0x11F);
    Moveset.VOICE(0x51D);
    dw 0;

    // Insert Moveset files
    BLINK:;
    IDLE:; dw 0

    TAUNT:;
    Moveset.VOICE(0x523);
    dw MODEL.WEAPON.CAMERA;  dw MODEL.FACE.BLUSH; Moveset.AFTER(20);
    dw 0x98007C00, 0x00000100, 0x00800000, 0x00000000 // flash gfx
    dw 0xB0C00000// overlay
    Moveset.SFX(0x556)
    // HITBOX(bone_id, ID_1, ID_2, x, y, z, size, hit_ground, hit_air, damage, shield_damage, damage_type, clang, base_kb, fixed_kb, kb_scaling, kb_angle, sfx_type, sfx_level)
    Moveset.HITBOX(0, 0, 0, 0, 175, -200, 250, 1, 1, 1, 0, 8, 0, 10, 10, 10, 361, 4, 0) // stun
    Moveset.HITBOX(0, 1, 1, 0, 175, -500, 300, 1, 1, 1, 0, 8, 0, 10, 10, 10, 361, 4, 0) // stun
    Moveset.WAIT(1);
    Moveset.END_HITBOXES();
    Moveset.END();

    VICTORY_2:; dw MODEL.WEAPON.FLUTE; dw MODEL.FACE.IDLE; Moveset.WAIT(12); dw MODEL.FACE.IDLE_BLINK;
    Moveset.WAIT(6); dw MODEL.FACE.IDLE; Moveset.WAIT(60); dw MODEL.FACE.IDLE_BLINK; Moveset.WAIT(7);
    dw MODEL.FACE.IDLE; Moveset.WAIT(68); dw MODEL.FACE.IDLE_BLINK; Moveset.WAIT(5); Moveset.VOICE(0x51A); dw MODEL.FACE.NORMAL; Moveset.END();

    insert JUMP_1, "moveset/JUMP_1.bin"
    insert JUMP_2, "moveset/JUMP_2.bin"
    insert TECH, "moveset/TECH.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    TEETER:; dw MODEL.FACE.HURT; Moveset.END();

    insert FROLL, "moveset/FROLL.bin"
    insert BROLL, "moveset/BROLL.bin"

    DOWN_ATTACK_D:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/DOWN_ATTACK_D.bin"
    DOWN_ATTACK_U:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/DOWN_ATTACK_U.bin"
    CLIFF_ATTACK_F:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/CLIFF_ATTACK_F.bin"
    CLIFF_ATTACK_S:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/CLIFF_ATTACK_S.bin"

    JAB_1:;
    dw 0xD0003FC0
    dw MODEL.FACE.BLUSH; Moveset.HIDE_ITEM(); dw MODEL.WEAPON.FAN; Moveset.AFTER(1); dw 0xCC340000; Moveset.AFTER(3);
         // HITBOX(bone_id, ID_1, ID_2, x,  y,  z,  size,GT, AT, damage, shield_dam, type, clang, BKB, FKB, KBS, kb_angle, sfx_type, sfx_level)
    Moveset.HITBOX(17,      0,    0,    0,  0,  0, 125,  1,  1,  2,      10,         0,    0,     28,  0,   30,  361,      6,        0) // inner
    Moveset.HITBOX(17,      1,    0,    0,  150,0, 125,  1,  1,  2,      10,         0,    0,     28,  0,   30,  180,      6,        0) // outer
    dw 0x4C00002B; Moveset.AFTER(6); Moveset.END_HITBOXES();
    Moveset.AFTER(9); dw 0x58000001; Moveset.AFTER(0xC); dw 0xCC03FFFF; dw 0;

    DASH_ATTACK:; dw MODEL.FACE.BLUSH; insert "moveset/DASH_ATTACK.bin"
    FTILT:; dw MODEL.FACE.BLUSH; dw MODEL.WEAPON.HAMMER; insert "moveset/FTILT.bin"

    UTILT:; dw MODEL.FACE.BLUSH; Moveset.AFTER(5); dw 0xCC340000;
         // HITBOX(bone_id, ID_1, ID_2, x,  y,    z,  size,   GT, AT, damage, shield_dam, type, clang, BKB, FKB,  KBS, kb_angle, sfx_type, sfx_level)
    Moveset.HITBOX(29,      0,    0,    0,  0,    0,  0xB0,   1,  1,  12,     0,          0,    1,     50,  0,    50,  85,      1,        1) // foot
    Moveset.HITBOX(27,      1,    0,    0,  0,    0,  0x90,   1,  1,  12,     0,          0,    1,     50,  0,    50,  85,      1,        1) // leg
    Moveset.HITBOX(12,      2,    0,    0,  0x50, 0,  0x90,   1,  1,  8,      0,          0,    1,     20,  0,    100, 361,    0,        0) // head
    dw 0x4C00002B;
    Moveset.WAIT(8); Moveset.END_HITBOXES(); Moveset.WAIT(3); dw 0xCC03FFFF; dw 0;

    DTILT:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/DTILT.bin"
    FSMASH:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/FSMASH.bin"
    USMASH:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.FLUTE; insert "moveset/USMASH.bin"
    DSMASH:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/DSMASH.bin"
    NAIR:; insert "moveset/NAIR.bin"
    FAIR:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.FAN; insert "moveset/FAIR.bin"
    BAIR:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.FLUTE; insert "moveset/BAIR.bin"
    UAIR:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.PADDLE; insert "moveset/UAIR.bin"
    DAIR:; dw MODEL.FACE.ATTACK; dw MODEL.WEAPON.HAMMER; insert "moveset/DAIR.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/F_THROW.bin"
    insert FTHROW_DATA,"moveset/F_THROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"

    CPU:; dw MODEL.HAND_L.OPEN; dw MODEL.WEAPON.FLUTE; dw MODEL.FACE.ATTACK; Moveset.END();

    NSP_BEGIN:; dw MODEL.FACE.IDLE;  insert "moveset/NSP_BEGIN.bin"
    NSP_WAIT:; dw MODEL.FACE.IDLE; dw MODEL.WEAPON.MEAT; insert "moveset/NSP_WAIT.bin"
    NSP_END:; dw MODEL.FACE.IDLE; dw MODEL.WEAPON.MEAT; insert "moveset/NSP_END.bin"
    USP_IDLE:; Moveset.HIDE_ITEM(); dw MODEL.WEAPON.PADDLE; dw MODEL.HAND_L.PADDLE; dw MODEL.FACE.IDLE; Moveset.WAIT(3);
    USP_IDLE_LOOP:
    Moveset.SFX(0x2B)
         // HITBOX(bone_id, ID_1, ID_2, x,  y,  z, size, GT, AT, damage, shield_dam, type, clang, BKB, FKB, KBS, kb_angle, sfx_type, sfx_level)
    Moveset.HITBOX(9,       0,    0,    0,  0,  0, 100,  1,  1,  2,      0,          0,    0,     20,  0,    100, 45,      0,        1) // inner
    Moveset.HITBOX(9,       1,    0,    200,0,  0, 125,  1,  1,  2,      0,          0,    0,     20,  0,    100, 45,      0,        1) // outer
    Moveset.HITBOX(15,      2,    0,    0,  0,  0, 100,  1,  1,  2,      0,          0,    0,     20,  0,    100, 45,      0,        1) // inner
    Moveset.HITBOX(15,      3,    0,    200,0,  0, 125,  1,  1,  2,      0,          0,    0,     20,  0,    100, 45,      0,        1) // outer
    Moveset.WAIT(4)
    Moveset.END_HITBOXES()
    Moveset.WAIT(4)
    Moveset.GO_TO(USP_IDLE_LOOP)
    dw 0

    DSP_RECOIL:
    //dw 0xD0013E99
    Moveset.HURTBOXES(3); // set tangibility
    Moveset.WAIT(5);
    Moveset.HURTBOXES(1); // reset tangibility
    dw 0xB0080000
    Moveset.WAIT(33)
    
    dw 0;            // end

    insert DSP_LANDING,"moveset/DOWN_SPECIAL_LANDING.bin" // recoil
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"

    BAT_SMASH:
    dw 0xC4000007, 0x50000000, 0xB1300028, MODEL.FACE.ATTACK, 0x08000014, 0xBC000004, 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000003, 0xBC000003, 0x04000003, 0x18000000, 0;

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops

    CSS:
    Moveset.WAIT(0x30); Moveset.VOICE(0x0563); dw 0;

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Ebi's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Entry_R(0x0DD)
        constant Entry_L(0x0DE)
        constant USP(0x0DF)

        constant NSPBEGIN(0xE6)
        constant NSPWAIT(0xE6)
        constant NSPWALK1(0xE7)
        constant NSPWALK2(0xE8)
        constant NSPBACKWALK1(0xE9)
        constant NSPBACKWALK2(0xEA)
        constant NSPEND(0xEB)
        constant NSPBEGINAIR(0xEC)
        constant NSPWAITAIR(0xED)
        constant NSPENDAIR(0xEE)
        constant DSPGROUND(0xEF)
        constant DSPAIR(0xF0)
        constant DSPLANDING(0xF1)
        constant DSPRECOIL(0xF2)

        // strings!
        string_0x0DC:; String.insert("Jab3")
        string_0x0DE:; String.insert("Entry")
        string_0x0DF:; String.insert("PaddleFly")
        //string_0x0E0:; String.insert("PaddleFly")
        //string_0x0E1:; String.insert("PaddleFly")
        //string_0x0E2:; String.insert("PaddleFly")
        string_0x0E5:; String.insert("MeatSaw-HammerBeginG")
        string_0x0E6:; String.insert("MeatSaw-HammerWaitG")
        string_0x0E7:; String.insert("MeatSaw-HammerWalk1G")
        string_0x0E8:; String.insert("MeatSaw-HammerWalk2G")
        string_0x0E9:; String.insert("MeatSaw-HammerWalk1G")
        string_0x0EA:; String.insert("MeatSaw-HammerWalk2G")
        string_0x0EB:; String.insert("MeatSaw-HammerAttack")
        string_0x0EC:; String.insert("MeatSaw-HammerBeginA")
        string_0x0ED:; String.insert("MeatSaw-HammerIdleA")
        string_0x0EE:; String.insert("MeatSaw-HammerAttackA")
        string_0x0EF:; String.insert("HipAttackGround")
        string_0x0F0:; String.insert("HipAttackAir")
        string_0x0F1:; String.insert("HipAttackLanding")
        string_0x0F2:; String.insert("HipAttackRecoil")


        action_string_table:
        dw string_0x0DC
        dw Action.COMMON.string_jabloop
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0DF
        dw string_0x0DF
        dw string_0x0DF
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloop
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
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
    }

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(EBI,    Action.Entry,           File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(EBI,    0x006,                  File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(EBI,    Action.Idle,            File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(EBI,    Action.ReviveWait,      File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(EBI,    Action.Crouch,          File.GOEMON_CROUCH_BEGIN,   -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.CrouchIdle,      File.GOEMON_CROUCH_IDLE,    -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.CrouchEnd,       File.GOEMON_CROUCH_END,     -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.Walk1,           File.EBISUMARU_WALK_1,      -1,                         -1)

    Character.edit_action_parameters(EBI,    Action.JumpF,           File.GOEMON_JUMP_F,         JUMP_1,                     -1)
    Character.edit_action_parameters(EBI,    Action.JumpB,           File.GOEMON_JUMP_B,         JUMP_1,                     -1)
    Character.edit_action_parameters(EBI,    Action.JumpAerialF,     File.GOEMON_JUMP_AIR_F,     JUMP_2,                     -1)
    Character.edit_action_parameters(EBI,    Action.JumpAerialB,     File.GOEMON_JUMP_AIR_B,     JUMP_2,                     -1)
    Character.edit_action_parameters(EBI,    Action.Fall,            File.GOEMON_FALL,           -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.FallAerial,      File.GOEMON_FALL_AERIAL,    -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.FallSpecial,     File.GOEMON_SFALL,          -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.Teeter,          File.GOEMON_TEETER,         TEETER,                     -1)
    Character.edit_action_parameters(EBI,    Action.TeeterStart,     File.GOEMON_TEETER_START,   -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.TechF,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(EBI,    Action.TechB,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(EBI,   Action.RollF,            -1,                         FROLL,                      -1)
    Character.edit_action_parameters(EBI,   Action.RollB,            -1,                         BROLL,                      -1)
    Character.edit_action_parameters(EBI,    Action.Tech,            -1,                         TECH,                       -1)
    Character.edit_action_parameters(EBI,    Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(EBI,    Action.Stun,            File.GOEMON_STUN,           STUN,                       -1)
    Character.edit_action_parameters(EBI,    Action.Sleep,           File.GOEMON_STUN,           Goemon.ASLEEP,              -1)
    Character.edit_action_parameters(EBI,    Action.Taunt,           File.EBISUMARU_TAUNT,       TAUNT,                      -1)
    Character.edit_action_parameters(EBI,    Action.Dash,            File.EBISUMARU_DASH,        -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.Run,             File.EBISUMARU_RUN,         -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.RunBrake,        -1,                         -1,                         -1)
    //Character.edit_action_parameters(EBI,    Action.Turn,            File.EBI_TURN,            -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.TurnRun,         -1,                         -1,                         -1)

    Character.edit_action_parameters(EBI,    Action.JumpSquat,       File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.ShieldJumpSquat, File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingLight,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingHeavy,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingSpecial,  File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingAirB,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingAirU,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingAirD,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(EBI,    Action.LandingAirX,     File.GOEMON_JUMPSQUAT,      -1,                         0)

    Character.edit_action_parameters(EBI, Action.EnterPipe,              File.GOEMON_ENTER_PIPE,             -1,             -1)
    Character.edit_action_parameters(EBI, Action.ExitPipe,               File.GOEMON_EXIT_PIPE,              -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffWait,              File.GOEMON_CLIFF_WAIT,             -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffClimbQuick2,       File.GOEMON_CLIFF_CLIMB_QUICK_2,    -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffClimbSlow2,        File.GOEMON_CLIFF_CLIMB_SLOW_2,     -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffAttackQuick1,      File.GOEMON_CLIFF_ATTACK_QUICK_1,   -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffAttackQuick2,      File.GOEMON_CLIFF_ATTACK_QUICK_2,   CLIFF_ATTACK_F,             -1)
    Character.edit_action_parameters(EBI, Action.CliffAttackSlow2,       File.GOEMON_CLIFF_ATTACK_SLOW_2,    CLIFF_ATTACK_S,             -1)
    Character.edit_action_parameters(EBI, Action.CliffEscapeQuick2,      File.GOEMON_CLIFF_ESCAPE_QUICK_2,   -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffEscapeSlow1,       File.GOEMON_CLIFF_ESCAPE_SLOW_1,    -1,             -1)
    Character.edit_action_parameters(EBI, Action.CliffEscapeSlow2,       File.GOEMON_CLIFF_ESCAPE_SLOW_2,    -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownAttackD,            File.GOEMON_DOWN_ATTACK_D,          DOWN_ATTACK_D,  -1)
    Character.edit_action_parameters(EBI, Action.DownAttackU,            File.GOEMON_DOWN_ATTACK_U,          DOWN_ATTACK_U,  -1)
    Character.edit_action_parameters(EBI, Action.DownStandD,             File.GOEMON_DOWN_STAND_D,           -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownStandU,             File.GOEMON_DOWN_STAND_U,           -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownForwardD,           File.GOEMON_DOWN_FORWARD_D,         -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownForwardU,           File.GOEMON_DOWN_FORWARD_U,         -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownBackD,              File.GOEMON_DOWN_BACK_D,            -1,             -1)
    Character.edit_action_parameters(EBI, Action.DownBackU,              File.GOEMON_DOWN_BACK_U,            -1,             -1)

    Character.edit_action_parameters(EBI,    Action.EggLay,          File.GOEMON_IDLE,           -1,                         -1)

    Character.edit_action_parameters(EBI,    Action.Jab1,            File.GOEMON_JAB1,           JAB_1,                      -1)
    Character.edit_action_parameters(EBI,    Action.DashAttack,      File.EBISUMARU_DASH_ATTACK, DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(EBI,    Action.FTiltHigh,       0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.FTilt,           0x0258,                     FTILT,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.FTiltLow,        0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.UTilt,           File.EBISUMARU_UTILT,       UTILT,                      0x40000000)
    Character.edit_action_parameters(EBI,    Action.DTilt,           File.GOEMON_DTILT,          DTILT,                      0x00000000)
    Character.edit_action_parameters(EBI,    Action.FSmashHigh,      0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.FSmashMidHigh,   0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.FSmash,          File.GOEMON_FSMASH,         FSMASH,                     0x00000000)
    Character.edit_action_parameters(EBI,    Action.FSmashMidLow,    0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.FSmashLow,       0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(EBI,    Action.USmash,          File.GOEMON_USMASH,         USMASH,                     0x00000000)
    Character.edit_action_parameters(EBI,    Action.DSmash,          File.GOEMON_DSMASH,         DSMASH,                     0x00000000)
    Character.edit_action_parameters(EBI,    Action.AttackAirN,      File.EBISUMARU_NAIR,        NAIR,                       -1)
    Character.edit_action_parameters(EBI,    Action.AttackAirF,      File.GOEMON_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(EBI,    Action.AttackAirB,      File.WARIO_BAIR,            Wario.BAIR,                       -1)
    Character.edit_action_parameters(EBI,    Action.AttackAirU,      File.GOEMON_UAIR,           UAIR,                       -1)
    Character.edit_action_parameters(EBI,    Action.AttackAirD,      File.GOEMON_DAIR,           DAIR,                       0x00000000)
    Character.edit_action_parameters(EBI,    Action.BatSmash,        -1,                         BAT_SMASH,                  -1)
    Character.edit_action_parameters(EBI,    Action.Grab,            File.GOEMON_GRAB,           GRAB,                         -1)
    Character.edit_action_parameters(EBI,    Action.GrabPull,        File.GOEMON_GRAB_PULL,      -1,                         -1)
    Character.edit_action_parameters(EBI,    Action.ThrowF,          File.GOEMON_THROW_FORWARD,  FTHROW,                     -1)
    Character.edit_action_parameters(EBI,    Action.ThrowB,          File.DRM_BTHROW,            BTHROW,                     0x50000000)
    Character.edit_action_parameters(EBI,    Action.USP,             File.EBISUMARU_UP_SPECIAL,  USP_IDLE,                    0)
    Character.edit_action_parameters(EBI,    Action.Entry_R,         File.EBISUMARU_ENTRY,       ENTRY,                     -1)
    Character.edit_action_parameters(EBI,    Action.Entry_L,         File.EBISUMARU_ENTRY,       ENTRY,                     -1)
    Character.edit_action_parameters(EBI,    Action.ShieldOn, 		File.GOEMON_SHIELD_ON,   	-1,                         -1)
	Character.edit_action_parameters(EBI,    Action.ShieldOff, 		File.GOEMON_SHIELD_OFF,   	-1,                         -1)


    // Modify Actions             // Action     // Staling ID   // Main ASM         // Interrupt/Other ASM      // Movement/Physics ASM     // Collision ASM
    Character.edit_action(EBI, Action.USP,      0x11,           EbiUSP.main_,       0x8013F660,                 EbiUSP.physics_,            EbiUSP.collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(EBI, DSPGround,          -1,             File.EBISUMARU_DSP_GROUNDED,   DSP_GROUND,                 0)
    Character.add_new_action_params(EBI, DSPAir,             -1,             File.EBISUMARU_DSP_START,   DSP_AIR,                    0)
    Character.add_new_action_params(EBI, DSPLanding,         -1,             File.EBISUMARU_DSP_LAND,    DSP_LANDING,                 0)
    Character.add_new_action_params(EBI, DSPRecoil,          -1,             File.EBISUMARU_DSP_RECOIL,  DSP_RECOIL,                 0)
    Character.add_new_action_params(EBI, NSP_Ground_Begin,   -1,             File.GOEMON_NSPG_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(EBI, NSP_Ground_Wait,    -1,             File.GOEMON_NSPG_IDLE,      NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Ground_Walk1,   -1,             File.GOEMON_NSPG_WALK_1,    NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Ground_Walk2,   -1,             File.GOEMON_NSPG_WALK_2,    NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Ground_BWalk1,  -1,             File.GOEMON_NSPG_BWALK_1,   NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Ground_BWalk2,  -1,             File.GOEMON_NSPG_BWALK_2,   NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Ground_End,     -1,             File.EBISUMARU_NSP_ATTACK,  NSP_END,                    0)
    Character.add_new_action_params(EBI, NSP_Air_Begin,      -1,             File.GOEMON_NSPG_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(EBI, NSP_Air_Wait,       -1,             File.GOEMON_NSPG_IDLE,      NSP_WAIT,                   0)
    Character.add_new_action_params(EBI, NSP_Air_End,        -1,             File.EBISUMARU_NSP_ATTACK,  NSP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(EBI, NSP_Ground_Begin,  -1,             ActionParams.NSP_Ground_Begin,  0x12,           EbiNSP.ground_begin_main_,   0,                           0x800D8BB4,                          EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_Wait,   -1,             ActionParams.NSP_Ground_Wait,   0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    0x800D8BB4,                          EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_Walk1,  -1,             ActionParams.NSP_Ground_Walk1,  0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,      EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_Walk2,  -1,             ActionParams.NSP_Ground_Walk2,  0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,      EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_BWalk1, -1,             ActionParams.NSP_Ground_BWalk1, 0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_BWalk2, -1,             ActionParams.NSP_Ground_BWalk2, 0x12,           EbiNSP.ground_wait_main_,    EbiNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,    0x12,           EbiNSP.end_main_,            0,                           0x800D8BB4,                          EbiNSP.ground_collision_)
    Character.add_new_action(EBI, NSP_Air_Begin,     -1,             ActionParams.NSP_Air_Begin,     0x12,           EbiNSP.air_begin_main_,      0,                           GoemonNSP.air_physics_,              EbiNSP.air_collision_)
    Character.add_new_action(EBI, NSP_Air_Wait,      -1,             ActionParams.NSP_Air_Wait,      0x12,           EbiNSP.air_wait_main_,       0,                           GoemonNSP.air_physics_,              EbiNSP.air_collision_)
    Character.add_new_action(EBI, NSP_Air_End,       -1,             ActionParams.NSP_Air_End,       0x12,           EbiNSP.end_main_,            0,                           GoemonNSP.air_physics_,              EbiNSP.air_collision_)
    Character.add_new_action(EBI, DSPGround,         -1,             ActionParams.DSPGround,         0x1E,           EbiDSP.grounded_main_,              0,                           0x800D8BB4,                          0x800DDEE8)
    Character.add_new_action(EBI, DSPAir,            -1,             ActionParams.DSPAir,            0x1E,           0x800D94E8,                  EbiDSP.ground_move_,         EbiDSP.physics_,                     EbiDSP.collision_)
    Character.add_new_action(EBI, DSPLanding,        -1,             ActionParams.DSPLanding,        0x1E,           EbiDSP.landing_main_,        0,                           0x800D91EC,                          0x800DDEE8)
    Character.add_new_action(EBI, DSPRecoil,        -1,             ActionParams.DSPRecoil,         0x1E,           0x800D94E8,                   EbiDSP.recoil_move_,         EbiDSP.recoil_physics_,              EbiDSP.recoil_air_collision_)
    // Modify Menu Action Parameters                    // Action       // Animation                    // Moveset Data    // Flags
    Character.edit_menu_action_parameters(EBI,       0x0,            File.GOEMON_IDLE,               IDLE,           -1)
    Character.edit_menu_action_parameters(EBI,       0x1,            File.EBISUMARU_CSS,             CSS,            -1)
    Character.edit_menu_action_parameters(EBI,       0x2,            File.GOEMON_VICTORY_2,          VICTORY_2,      -1)
    Character.edit_menu_action_parameters(EBI,       0x3,            File.EBISUMARU_VICTORY_1,       EBI_GROW,       -1) // grow from shrink state
    Character.edit_menu_action_parameters(EBI,       0x4,            File.EBISUMARU_CSS,             CSS,            -1)
    Character.edit_menu_action_parameters(EBI,       0x5,            File.GOEMON_CLAP,                -1,            -1)
    Character.edit_menu_action_parameters(EBI,       0xD,            File.EBISUMARU_1P_POSE,         0x80000000,     -1)
    Character.edit_menu_action_parameters(EBI,       0xE,            File.GOEMON_1P_CPU,             CPU,            -1)
    Character.edit_menu_action_parameters(EBI,       0xA,            File.GOEMON_PUPPET_UP,          -1,             -1)

    Character.table_patch_start(ground_nsp, Character.id.EBI, 0x4)
    dw      EbiNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.EBI, 0x4)
    dw      EbiNSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.EBI, 0x4)
    dw      EbiUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.EBI, 0x4)
    dw      EbiUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.EBI, 0x4)
    dw      EbiDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.EBI, 0x4)
    dw      EbiDSP.air_initial_
    OS.patch_end()

    // Allows Ebi to use his entry which is similar to Link
    Character.table_patch_start(entry_action, Character.id.EBI, 0x8)
    dw Action.Entry_R, Action.Entry_L
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.EBI, 0x4)
    dw ebisumaru_entry_routine_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.EBI, 0x2)
    dh  0x02B7              // generic cheering
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.EBI, 0xC)
    dh 0x28
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.EBI, 0, 1, 2, 3, 3, 0, 1)
    Teams.add_team_costume(YELLOW, EBI, 5)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(EBI, BLUE, GREEN, PINK, RED, WHITE, YELLOW, ORANGE, NA)

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  10,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  16,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  15,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  7,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  9,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  7,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  9,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  2,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  3,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  23,   0,  50, 275, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  23,   0,  50, 275, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  0,   0,  0, 0, 0, 0)   // never use up special to attack
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  0,   0,  0, 0, 0, 0)   // never use up special to attack
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  12,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  5,   0,  -1, -1, -1, -1)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.EBI, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.EBI, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Ebisumaru as variant
    Character.table_patch_start(variants, Character.id.EBI, 0x4)
    db      Character.id.GOEMON
    OS.patch_end()

    Character.table_patch_start(variant_original, Character.id.EBI, 0x4)
    dw      Character.id.GOEMON
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.EBI, 0x4)
    dw grounded_script_
    OS.patch_end()

    grounded_script_: {
        sw      r0, 0x0ADC(v0)
        j       0x800DE44C
        sw      r0, 0x0AE0(v0)
    }

    // @ Description
    // Entry routine for Ebi. Sets the correct facing direction and then jumps to Link's entry routine.
    scope ebisumaru_entry_routine_: {
        lw      a1, 0x0B1C(s0)              // a1 = direction
        addiu   at, r0,-0x0001              // at = -1 (left)
        beql    a1, at, _end                // branch if direction = left...
        sw      v1, 0x0B24(s0)              // ...and enable reversed direction flag

        _end:
        j       0x8013DCCC                  // jump to Link's entry routine to load entry object
        nop
    }

}
