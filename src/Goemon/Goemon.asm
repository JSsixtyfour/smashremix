// Goemon.asm

// This file contains file inclusions, action edits, and assembly for Goemon.

scope Goemon {
    // Model Commands
    scope MODEL {
        scope PIPE {
            constant HIDE(0xA0880000)
            constant SHOW(0xA0880001)
        }

        scope SUDDEN_IMPACT {
            constant HIDE(0xA0600000)
            constant SHOW(0xA0600001)
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
            constant RYO(0xA0500002)
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
            constant ATTACK_2(0xAC000005)
            constant SLEEP(0xAC000006)
            constant DIZZY(0xAC000007)
        }
    }

    // Insert Moveset files
    // Subroutine for hiding the Chain Pipe.
    HIDE_CHAIN:
    dw MODEL.CHAIN.HIDE_BASE
    dw MODEL.CHAIN.HIDE_1
    dw MODEL.CHAIN.HIDE_2
    dw MODEL.CHAIN.HIDE_3
    dw MODEL.CHAIN.HIDE_4
    dw MODEL.CHAIN.HIDE_5
    dw MODEL.CHAIN.HIDE_6
    dw MODEL.CHAIN.HIDE_7
    dw MODEL.CHAIN.HIDE_END
    Moveset.RETURN()
    // Subroutine for showing the Chain Pipe.
    SHOW_CHAIN:
    dw MODEL.CHAIN.SHOW_BASE
    dw MODEL.CHAIN.SHOW_1
    dw MODEL.CHAIN.SHOW_2
    dw MODEL.CHAIN.SHOW_3
    dw MODEL.CHAIN.SHOW_4
    dw MODEL.CHAIN.SHOW_5
    dw MODEL.CHAIN.SHOW_6
    dw MODEL.CHAIN.SHOW_7
    dw MODEL.CHAIN.SHOW_END
    Moveset.RETURN()

    // Insert Moveset files
    BLINK:; dw MODEL.FACE.IDLE_BLINK; Moveset.WAIT(3); dw MODEL.FACE.IDLE; Moveset.WAIT(3); Moveset.RETURN()
    IDLE:; dw 0xBC000003                        // set slope contour state
    Moveset.SUBROUTINE(BLINK)                   // blink
    dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
    dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
    dw 0x04000050; Moveset.GO_TO(IDLE)          // loop

    TAUNT:;  dw MODEL.FACE.ATTACK; Moveset.AFTER(50); Moveset.VOICE(0x4C5); Moveset.AFTER(0x80); dw 0x58000001; Moveset.END();
    VICTORY_2:; dw MODEL.PIPE.SHOW; dw MODEL.FACE.IDLE; Moveset.WAIT(12); dw MODEL.FACE.IDLE_BLINK;
    Moveset.WAIT(6); dw MODEL.FACE.IDLE; Moveset.WAIT(60); dw MODEL.FACE.IDLE_BLINK; Moveset.WAIT(7);
    dw MODEL.FACE.IDLE; Moveset.WAIT(68); dw MODEL.FACE.IDLE_BLINK; Moveset.WAIT(5); Moveset.VOICE(0x4D2); dw MODEL.FACE.NORMAL; Moveset.END();

    insert JUMP_1, "moveset/JUMP_1.bin"
    insert JUMP_2, "moveset/JUMP_2.bin"
    insert ENTRY, "moveset/ENTRY.bin"
    insert TECH, "moveset/TECH.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    TEETER:; dw MODEL.FACE.HURT; Moveset.VOICE(0x440); Moveset.END();



    DOWN_ATTACK_D:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DOWN_ATTACK_D.bin"
    DOWN_ATTACK_U:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DOWN_ATTACK_U.bin"
    CLIFF_ATTACK_F:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/CLIFF_ATTACK_F.bin"
    CLIFF_ATTACK_S:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/CLIFF_ATTACK_S.bin"
    JAB_1:; dw MODEL.FACE.ATTACK_2; dw MODEL.PIPE.SHOW; insert "moveset/JAB_1.bin"
    JAB_2:; dw MODEL.FACE.ATTACK_2; dw MODEL.PIPE.SHOW; insert "moveset/JAB_2.bin"
    JAB_3:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/JAB_3.bin"
    DASH_ATTACK:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DASH_ATTACK.bin"
    FTILT_HIGH:; dw MODEL.FACE.ATTACK_2; dw MODEL.YOYO.SHOW; insert "moveset/FTILT_HIGH.bin"
    FTILT:; dw MODEL.FACE.ATTACK_2; dw MODEL.YOYO.SHOW; insert "moveset/FTILT.bin"
    FTILT_LOW:; dw MODEL.FACE.ATTACK_2; dw MODEL.YOYO.SHOW; insert "moveset/FTILT_LOW.bin"
    UTILT:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/UTILT.bin"
    DTILT:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DTILT.bin"
    FSMASH:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/FSMASH.bin"
    USMASH:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/USMASH.bin"
    DSMASH:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DSMASH.bin"
    NAIR:; insert "moveset/NAIR.bin"
    FAIR:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/FAIR.bin"
    BAIR:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/BAIR.bin"
    UAIR:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/UAIR.bin"
    DAIR:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/DAIR.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/F_THROW.bin"
    insert FTHROW_DATA,"moveset/F_THROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"

    ONEP:; dw MODEL.HAND_L.OPEN; dw MODEL.PIPE.SHOW; Moveset.END();
    CPU:; dw MODEL.HAND_L.OPEN; dw MODEL.PIPE.SHOW; dw MODEL.FACE.ATTACK; Moveset.END();

    NSP_BEGIN:; dw MODEL.FACE.IDLE;  insert "moveset/NSP_BEGIN.bin"
    NSP_WAIT:; dw MODEL.FACE.IDLE; dw MODEL.HAND_R.RYO; insert "moveset/NSP_WAIT.bin"
    NSP_END:; dw MODEL.FACE.IDLE; dw MODEL.HAND_R.RYO; insert "moveset/NSP_END.bin"
    DSP_THROW_DATA:; insert "moveset/DSP_THROW_DATA.bin"
    USP_IDLE:; Moveset.HIDE_ITEM(); dw MODEL.PIPE.SHOW; dw MODEL.FACE.IDLE; dw 0;
    USP_JUMP:; insert "moveset/USP_JUMP.bin"
    USP_ESCAPE:; insert "moveset/USP_ESCAPE.bin"
    USP_ATTACK:; dw MODEL.FACE.ATTACK; dw MODEL.PIPE.SHOW; insert "moveset/USP_ATTACK.bin"

    DSP_AIR:
    Moveset.HIDE_ITEM()
    Moveset.THROW_DATA(DSP_THROW_DATA)
    dw 0xBC000003
    dw MODEL.PIPE.SHOW
    Moveset.AFTER(17)
    Moveset.SFX(0x2A)   // fgm woosh
    Moveset.AFTER(20)
    Moveset.SUBROUTINE(SHOW_CHAIN)
    Moveset.SFX(0x474)  // fgm chain pipe
    dw 0x98004000, 0, 0xFF9C0000, 0; // air dash gfx
    Moveset.GO_TO(DSP_CONTINUE);

    DSP:
    Moveset.HIDE_ITEM()
    Moveset.THROW_DATA(DSP_THROW_DATA)
    dw 0xBC000003
    dw MODEL.PIPE.SHOW
    Moveset.AFTER(17)
    Moveset.SFX(0x2A)   // fgm woosh
    Moveset.AFTER(20)
    Moveset.SUBROUTINE(SHOW_CHAIN)
    Moveset.SFX(0x474)  // fgm chain pipe
    dw 0x98004C00, 0, 0xFF9C0000, 0; // ground dash gfx
    DSP_CONTINUE:
    insert "moveset/DSP.bin"
    Moveset.AFTER(60)
    Moveset.SFX(0x475)  // fgm chain pipe 2
    Moveset.SUBROUTINE(HIDE_CHAIN)
    dw MODEL.PIPE.SHOW
    dw 0
    DSP_PULL:; Moveset.THROW_DATA(DSP_THROW_DATA); Moveset.SUBROUTINE(SHOW_CHAIN); insert "moveset/DSP_PULL.bin"
    DSP_ATTACK:; insert "moveset/DSP_ATTACK.bin"

    BAT_SMASH:
    dw 0xC4000007, 0x50000000, 0xB1300028, MODEL.FACE.ATTACK, 0x08000014, 0xBC000004, 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000003, 0xBC000003, 0x04000003, 0x18000000, 0;

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    SUDDEN_IMPACT:
    dw MODEL.FACE.IDLE;
    Moveset.AFTER(0x30); Moveset.VOICE(0x4CB);
    Moveset.AFTER(120); Moveset.SFX(0x86);
    dw 0xB1D80000;
    dw MODEL.SUDDEN_IMPACT.SHOW;
    dw MODEL.FACE.IDLE;
    Moveset.WAIT(4);
    dw 0;

    HEAVY_ITEM_PICKUP:
    Moveset.SFX(0x86); dw 0xB1D80000; dw MODEL.SUDDEN_IMPACT.SHOW; dw MODEL.FACE.IDLE; Moveset.AFTER(3); dw 0x08000004, 0x58000001, 0;

    HEAVY_ITEM_HOLD:
    HEAVY_ITEM_TURN:
    dw MODEL.SUDDEN_IMPACT.SHOW; dw MODEL.FACE.IDLE; dw 0;

    HEAVY_ITEM_THROW_F:
    dw MODEL.SUDDEN_IMPACT.SHOW; dw MODEL.FACE.IDLE; Moveset.AFTER(3);
    HEAVY_ITEM_THROW_ITEM:
    dw 0x08000012, 0x54000001;
    dw 0x04000008, 0xB1D80000;
    dw MODEL.SUDDEN_IMPACT.HIDE; dw MODEL.FACE.ATTACK; dw 0x0;

    HEAVY_ITEM_THROW_B:
    dw 0x60000009; Moveset.GO_TO(HEAVY_ITEM_THROW_F);

    HEAVY_ITEM_THROW_SMASH_F:
    dw MODEL.SUDDEN_IMPACT.SHOW; dw MODEL.FACE.IDLE; Moveset.AFTER(3);
    Moveset.GO_TO(HEAVY_ITEM_THROW_ITEM);

    HEAVY_ITEM_THROW_SMASH_B:
    dw 0x60000009; Moveset.GO_TO(HEAVY_ITEM_THROW_SMASH_F)

    CSS:
    dw MODEL.PIPE.SHOW; Moveset.WAIT(80); dw MODEL.HAND_L.RYO; dw 0;

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Goemon's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Entry_R(0x0DD)
        constant Entry_L(0x0DE)
        constant USP(0x0DF)
        // constant USPTurn(0x0E0)
        constant USPAttack(0x0E0)
        constant USPJump(0x0E1)
        constant USPEscape(0x0E2)

        // strings!
        string_0x0DC:; String.insert("Jab3")
        string_0x0DE:; String.insert("Entry")
        string_0x0DF:; String.insert("MagicCloudRide")
        string_0x0E0:; String.insert("MagicCloudAttack")
        string_0x0E1:; String.insert("MagicCloudJump")
        string_0x0E2:; String.insert("MagicCloudEscape")
        string_0x0E5:; String.insert("RyoTossGroundBegin")
        string_0x0E6:; String.insert("RyoTossGroundWait")
        string_0x0E7:; String.insert("RyoTossGroundWalk1")
        string_0x0E8:; String.insert("RyoTossGroundWalk2")
        string_0x0E9:; String.insert("RyoTossGroundBWalk1")
        string_0x0EA:; String.insert("RyoTossGroundBWalk2")
        string_0x0EB:; String.insert("RyoTossGroundEnd")
        string_0x0EC:; String.insert("RyoTossAirBegin")
        string_0x0ED:; String.insert("RyoTossAirIdle")
        string_0x0EE:; String.insert("RyoTossAirEnd")
        string_0x0EF:; String.insert("ChainPipeGround")
        string_0x0F0:; String.insert("ChainPipeGroundPull")
        string_0x0F1:; String.insert("ChainPipeGroundWallPull")
        string_0x0F2:; String.insert("ChainPipeAttack")
        string_0x0F3:; String.insert("ChainPipeAir")
        string_0x0F4:; String.insert("ChainPipeAirPull")
        string_0x0F5:; String.insert("ChainPipeAirWallPull")
        string_0x0F6:; String.insert("ChainPipeAirAttack")
        string_0x0F7:; String.insert("ChainPipeEnd")


        action_string_table:
        dw string_0x0DC
        dw Action.COMMON.string_jabloop
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
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
        dw string_0x0F3
        dw string_0x0F4
        dw string_0x0F5
        dw string_0x0F6
        dw string_0x0F7
        dw string_0x0F7
    }

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(GOEMON,    Action.Entry,           File.GOEMON_IDLE,           ENTRY,                       -1)
    Character.edit_action_parameters(GOEMON,    0x006,                  File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.Idle,            File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.ReviveWait,      File.GOEMON_IDLE,           IDLE,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.Crouch,          File.GOEMON_CROUCH_BEGIN,   -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.CrouchIdle,      File.GOEMON_CROUCH_IDLE,    -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.CrouchEnd,       File.GOEMON_CROUCH_END,     -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.JumpF,           File.GOEMON_JUMP_F,         JUMP_1,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.JumpB,           File.GOEMON_JUMP_B,         JUMP_1,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.JumpAerialF,     File.GOEMON_JUMP_AIR_F,     JUMP_2,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.JumpAerialB,     File.GOEMON_JUMP_AIR_B,     JUMP_2,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.Fall,            File.GOEMON_FALL,           -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.FallAerial,      File.GOEMON_FALL_AERIAL,    -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.FallSpecial,     File.GOEMON_SFALL,          -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.Teeter,          File.GOEMON_TEETER,         TEETER,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.TeeterStart,     File.GOEMON_TEETER_START,   -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.TechF,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(GOEMON,    Action.TechB,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(GOEMON,    Action.Tech,            -1,                         TECH,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(GOEMON,    Action.Stun,            File.GOEMON_STUN,           STUN,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.Sleep,           File.GOEMON_STUN,           ASLEEP,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.Taunt,           File.GOEMON_TAUNT,          TAUNT,                      -1)
    Character.edit_action_parameters(GOEMON,    Action.Dash,            File.GOEMON_DASH,           -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.Run,             File.GOEMON_RUN,            -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.RunBrake,        File.GOEMON_RUN_BRAKE,      -1,                         -1)
    //Character.edit_action_parameters(GOEMON,    Action.Turn,            File.GOEMON_TURN,           -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.TurnRun,         File.GOEMON_TURN_RUN,       -1,                         -1)

    Character.edit_action_parameters(GOEMON,    Action.JumpSquat,       File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.ShieldJumpSquat, File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingLight,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingHeavy,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingSpecial,  File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingAirB,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingAirU,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingAirD,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(GOEMON,    Action.LandingAirX,     File.GOEMON_JUMPSQUAT,      -1,                         0)

    Character.edit_action_parameters(GOEMON, Action.EnterPipe,              File.GOEMON_ENTER_PIPE,             -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.ExitPipe,               File.GOEMON_EXIT_PIPE,              -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffWait,              File.GOEMON_CLIFF_WAIT,             -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffClimbQuick2,       File.GOEMON_CLIFF_CLIMB_QUICK_2,    -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffClimbSlow2,        File.GOEMON_CLIFF_CLIMB_SLOW_2,     -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffAttackQuick1,      File.GOEMON_CLIFF_ATTACK_QUICK_1,   -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffAttackQuick2,      File.GOEMON_CLIFF_ATTACK_QUICK_2,   CLIFF_ATTACK_F,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffAttackSlow2,       File.GOEMON_CLIFF_ATTACK_SLOW_2,    CLIFF_ATTACK_S,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffEscapeQuick2,      File.GOEMON_CLIFF_ESCAPE_QUICK_2,   -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffEscapeSlow1,       File.GOEMON_CLIFF_ESCAPE_SLOW_1,    -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.CliffEscapeSlow2,       File.GOEMON_CLIFF_ESCAPE_SLOW_2,    -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownAttackD,            File.GOEMON_DOWN_ATTACK_D,          DOWN_ATTACK_D,  -1)
    Character.edit_action_parameters(GOEMON, Action.DownAttackU,            File.GOEMON_DOWN_ATTACK_U,          DOWN_ATTACK_U,  -1)
    Character.edit_action_parameters(GOEMON, Action.DownStandD,             File.GOEMON_DOWN_STAND_D,           -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownStandU,             File.GOEMON_DOWN_STAND_U,           -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownForwardD,           File.GOEMON_DOWN_FORWARD_D,         -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownForwardU,           File.GOEMON_DOWN_FORWARD_U,         -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownBackD,              File.GOEMON_DOWN_BACK_D,            -1,             -1)
    Character.edit_action_parameters(GOEMON, Action.DownBackU,              File.GOEMON_DOWN_BACK_U,            -1,             -1)


    Character.edit_action_parameters(GOEMON,    Action.EggLay,          File.GOEMON_IDLE,           -1,                         -1)

    Character.edit_action_parameters(GOEMON,    Action.Jab1,            File.GOEMON_JAB1,           JAB_1,                      -1)
    Character.edit_action_parameters(GOEMON,    Action.Jab2,            File.GOEMON_JAB2,           JAB_2,                      -1)
    Character.edit_action_parameters(GOEMON,    Action.DashAttack,      File.GOEMON_DASH_ATTACK,    DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(GOEMON,    Action.FTiltHigh,       File.GOEMON_FTILT_HIGH,     FTILT_HIGH,                 0x10000000)
    Character.edit_action_parameters(GOEMON,    Action.FTilt,           File.GOEMON_FTILT,          FTILT,                      0x10000000)
    Character.edit_action_parameters(GOEMON,    Action.FTiltLow,        File.GOEMON_FTILT_LOW,      FTILT_LOW,                  0x10000000)
    Character.edit_action_parameters(GOEMON,    Action.UTilt,           File.GOEMON_UTILT,          UTILT,                      0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.DTilt,           File.GOEMON_DTILT,          DTILT,                      0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.FSmashHigh,      0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.FSmashMidHigh,   0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.FSmash,          File.GOEMON_FSMASH,         FSMASH,                     0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.FSmashMidLow,    0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.FSmashLow,       0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.USmash,          File.GOEMON_USMASH,         USMASH,                     0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.DSmash,          File.GOEMON_DSMASH,         DSMASH,                     0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.AttackAirN,      File.GOEMON_NAIR,           NAIR,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.AttackAirF,      File.GOEMON_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.AttackAirB,      File.GOEMON_BAIR,           BAIR,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.AttackAirU,      File.GOEMON_UAIR,           UAIR,                       -1)
    Character.edit_action_parameters(GOEMON,    Action.AttackAirD,      File.GOEMON_DAIR,           DAIR,                       0x00000000)
    Character.edit_action_parameters(GOEMON,    Action.BatSmash,        -1,                         BAT_SMASH,                  -1)
    Character.edit_action_parameters(GOEMON,    Action.HeavyItemThrowF, -1,                         HEAVY_ITEM_THROW_F,         -1)
    Character.edit_action_parameters(GOEMON,    Action.HeavyItemThrowB, -1,                         HEAVY_ITEM_THROW_B,         -1)
    Character.edit_action_parameters(GOEMON,    Action.HeavyItemThrowSmashF, -1,                    HEAVY_ITEM_THROW_SMASH_F,   -1)
    Character.edit_action_parameters(GOEMON,    Action.HeavyItemThrowSmashB, -1,                    HEAVY_ITEM_THROW_SMASH_B,   -1)
    Character.edit_action_parameters(GOEMON,    Action.Grab,            File.GOEMON_GRAB,           GRAB,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.GrabPull,        File.GOEMON_GRAB_PULL,      -1,                         -1)
    Character.edit_action_parameters(GOEMON,    Action.ThrowF,          File.GOEMON_THROW_FORWARD,  FTHROW,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.ThrowB,          File.GOEMON_THROW_BACKWARD, BTHROW,                     -1)
    Character.edit_action_parameters(GOEMON,    Action.Jab3,            File.GOEMON_JAB3,           JAB_3,                      -1)
    Character.edit_action_parameters(GOEMON,    Action.USP,             File.GOEMON_USP_LOOP,       USP_IDLE,                    0)
    // Character.edit_action_parameters(GOEMON,    Action.USPTurn,         0x1FB,                      0x80000000,               0)
    Character.edit_action_parameters(GOEMON,    Action.USPAttack,       File.GOEMON_USP_ATTACK,     USP_ATTACK,                  0)
    Character.edit_action_parameters(GOEMON,    Action.USPJump,         File.GOEMON_USP_JUMP,       USP_JUMP,                    0)
    Character.edit_action_parameters(GOEMON,    Action.USPEscape,       File.GOEMON_USP_ESCAPE,     USP_ESCAPE,                  0)
    Character.edit_action_parameters(GOEMON,    Action.Entry_R,         File.GOEMON_ENTRY,          ENTRY,                 -1)
    Character.edit_action_parameters(GOEMON,    Action.Entry_L,         File.GOEMON_ENTRY,          ENTRY,                 -1)
    Character.edit_action_parameters(GOEMON,    Action.ShieldOn, 		File.GOEMON_SHIELD_ON,   	-1,                         -1)
	Character.edit_action_parameters(GOEMON,    Action.ShieldOff, 		File.GOEMON_SHIELD_OFF,   	-1,                         -1)


    // Modify Actions             // Action             // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(GOEMON, Action.USP,           0x11,           GoemonUSP.main_,                GoemonUSP.interrupt_,           GoemonUSP.physics_,             GoemonUSP.collision_)
    // Character.edit_action(GOEMON, Action.USPTurn,       0x11,           GoemonUSP.turn_main_,           GoemonUSP.interrupt_,           GoemonUSP.physics_,             GoemonUSP.collision_)
    Character.edit_action(GOEMON, Action.USPAttack,     0x11,           GoemonUSP.attack_main_,         0,                              GoemonUSP.physics_,             GoemonUSP.collision_)
    Character.edit_action(GOEMON, Action.USPJump,       0x11,           GoemonUSP.jump_main_,           0,                              GoemonUSP.jump_physics_,        GoemonUSP.collision_)
    Character.edit_action(GOEMON, Action.USPEscape,     0x11,           GoemonUSP.escape_main_,         0,                              0x800D9160,                     GoemonUSP.collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(GOEMON, DSPGround,          -1,             File.GOEMON_DSPG,           DSP,                        0x1FF00000)
    Character.add_new_action_params(GOEMON, DSPGroundPull,      -1,             File.GOEMON_DSP_PULL,       DSP_PULL,                   0x5FF00000)
    Character.add_new_action_params(GOEMON, DSPGAttack,         -1,             File.GOEMON_DSPG_ATTACK,    DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(GOEMON, DSPAir,             -1,             File.GOEMON_DSPA,           DSP_AIR,                    0x1FF00000)
    Character.add_new_action_params(GOEMON, DSPAirPull,         -1,             File.GOEMON_DSP_PULL,       DSP_PULL,                   0x5FF00000)
    Character.add_new_action_params(GOEMON, DSPAAttack,         -1,             File.GOEMON_DSPA_ATTACK,    DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(GOEMON, DSPEnd,             -1,             File.GOEMON_DSP_END,        0x80000000,                 0x00000000)
    Character.add_new_action_params(GOEMON, NSP_Ground_Begin,   -1,             File.GOEMON_NSPG_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(GOEMON, NSP_Ground_Wait,    -1,             File.GOEMON_NSPG_IDLE,      NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Ground_Walk1,   -1,             File.GOEMON_NSPG_WALK_1,    NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Ground_Walk2,   -1,             File.GOEMON_NSPG_WALK_2,    NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Ground_BWalk1,  -1,             File.GOEMON_NSPG_BWALK_1,   NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Ground_BWalk2,  -1,             File.GOEMON_NSPG_BWALK_2,   NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Ground_End,     -1,             File.GOEMON_NSPG_END,       NSP_END,                    0)
    Character.add_new_action_params(GOEMON, NSP_Air_Begin,      -1,             File.GOEMON_NSPG_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(GOEMON, NSP_Air_Wait,       -1,             File.GOEMON_NSPG_IDLE,      NSP_WAIT,                   0)
    Character.add_new_action_params(GOEMON, NSP_Air_End,        -1,             File.GOEMON_NSPG_END,       NSP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(GOEMON, NSP_Ground_Begin,  -1,             ActionParams.NSP_Ground_Begin,  0x12,           GoemonNSP.ground_begin_main_,   0,                              0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_Wait,   -1,             ActionParams.NSP_Ground_Wait,   0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_Walk1,  -1,             ActionParams.NSP_Ground_Walk1,  0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_Walk2,  -1,             ActionParams.NSP_Ground_Walk2,  0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_BWalk1, -1,             ActionParams.NSP_Ground_BWalk1, 0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_BWalk2, -1,             ActionParams.NSP_Ground_BWalk2, 0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,    0x12,           GoemonNSP.end_main_,            0,                              0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(GOEMON, NSP_Air_Begin,     -1,             ActionParams.NSP_Air_Begin,     0x12,           GoemonNSP.air_begin_main_,      0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(GOEMON, NSP_Air_Wait,      -1,             ActionParams.NSP_Air_Wait,      0x12,           GoemonNSP.air_wait_main_,       0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(GOEMON, NSP_Air_End,       -1,             ActionParams.NSP_Air_End,       0x12,           GoemonNSP.end_main_,            0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(GOEMON, DSPGround,         -1,             ActionParams.DSPGround,         0x1E,           GoemonDSP.main_,                0,                              0x800D8BB4,                         GoemonDSP.ground_collision_)
    Character.add_new_action(GOEMON, DSPGroundPull,     -1,             ActionParams.DSPGroundPull,     0x1E,           GoemonDSP.pull_main_,           0,                              0x800D8C14,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(GOEMON, DSPGroundWallPull, -1,             ActionParams.DSPGroundPull,     0x1E,           GoemonDSP.wall_pull_main_,      0,                              0x800D8C14,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(GOEMON, DSPGAttack,         -1,            ActionParams.DSPGAttack,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(GOEMON, DSPAir,            -1,             ActionParams.DSPAir,            0x1E,           GoemonDSP.main_,                0,                              0x800D90E0,                         GoemonDSP.air_collision_)
    Character.add_new_action(GOEMON, DSPAirPull,        -1,             ActionParams.DSPAirPull,        0x1E,           GoemonDSP.pull_main_,           0,                              0x800D93E4,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(GOEMON, DSPAirWallPull,    -1,             ActionParams.DSPAirPull,        0x1E,           GoemonDSP.wall_pull_main_,      0,                              0x800D93E4,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(GOEMON, DSPAAttack,         -1,            ActionParams.DSPAAttack,        0x1E,           0x800D94E8,                     0,                              0x800D91EC,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(GOEMON, DSPEnd,            -1,             ActionParams.DSPEnd,            0x1E,           0x800D94E8,                     0,                              0x800D9160,                         0x800DE99C)

    // Modify Menu Action Parameters                    // Action       // Animation                    // Moveset Data    // Flags
    Character.edit_menu_action_parameters(GOEMON,       0x0,            File.GOEMON_IDLE,               IDLE,           -1)
    Character.edit_menu_action_parameters(GOEMON,       0x1,            File.GOEMON_CSS,                CSS,            -1)
    Character.edit_menu_action_parameters(GOEMON,       0x2,            File.GOEMON_VICTORY_2,          VICTORY_2,      -1)
    Character.edit_menu_action_parameters(GOEMON,       0x3,            File.GOEMON_VICTORY_3,          SUDDEN_IMPACT,  -1)
    Character.edit_menu_action_parameters(GOEMON,       0x4,            File.GOEMON_CSS,                CSS,            -1)
    Character.edit_menu_action_parameters(GOEMON,       0x5,            File.GOEMON_CLAP,                -1,            -1)
    Character.edit_menu_action_parameters(GOEMON,       0xD,            File.GOEMON_1P_POSE,            ONEP,           -1)
    Character.edit_menu_action_parameters(GOEMON,       0xE,            File.GOEMON_1P_CPU,             CPU,            -1)
    Character.edit_menu_action_parameters(GOEMON,       0xA,            File.GOEMON_PUPPET_UP,          -1,             -1)

    Character.table_patch_start(ground_nsp, Character.id.GOEMON, 0x4)
    dw      GoemonNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.GOEMON, 0x4)
    dw      GoemonNSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.GOEMON, 0x4)
    dw      GoemonUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.GOEMON, 0x4)
    dw      GoemonUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.GOEMON, 0x4)
    dw      GoemonDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.GOEMON, 0x4)
    dw      GoemonDSP.air_initial_
    OS.patch_end()

    // Allows Goemon to use his entry which is similar to Link
    Character.table_patch_start(entry_action, Character.id.GOEMON, 0x8)
    dw Action.Entry_R, Action.Entry_L
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.GOEMON, 0x4)
    dw goemon_entry_routine_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.GOEMON, 0x2)
    dh  0x0557
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.GOEMON, 0xC)
    dh 0x22
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.GOEMON, 0, 1, 2, 3, 4, 1, 3)
    Teams.add_team_costume(YELLOW, GOEMON, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(GOEMON, RED, BLUE, GREEN, PURPLE, MAGENTA, WHITE, YELLOW, NA)
    
    Character.table_patch_start(variants, Character.id.GOEMON, 0x4)
    db      Character.id.EBI // set EBI as SPECIAL variant for GOEMON
    db      Character.id.NGOEMON
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()


    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  10,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  20,   0,  50, 700, 0, 150)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  20,   0,  50, 700, 0, 150)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  7,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  9,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  7,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  12,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  3,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  3,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  25,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  25,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  0,   0,  0, 0, 0, 0)   // never use up special to attack
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  0,   0,  0, 0, 0, 0)   // never use up special to attack
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  12,   0,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  5,   0,  -1, -1, -1, -1)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.GOEMON, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()



    // Set action strings
    Character.table_patch_start(action_string, Character.id.GOEMON, 0x4)
    dw  Action.action_string_table
    OS.patch_end()


    // Hook allows goemon to have his golden hair while holding a heavy item
    scope heavy_item_hold_moveset: {
        OS.patch_start(0xC0B50, 0x80146110)
        j       heavy_item_hold_moveset
        lw      t9, 0x0024(sp)      // og line 1
        _return:
        OS.patch_end()

        lw      t8, 0x0008(t9)      // t8 = character id
        addiu   at, r0, Character.id.GOEMON

        bne     at, t8, _normal
        nop

        // if here, goemon

        li      at, HEAVY_ITEM_HOLD
        sw      at, 0x086C(t9)      // update moveset pointer 1

        _normal:
        j       _return
        lui     t8, 0x8014          // og line 2
    }

    // Hook allows goemon to have his golden hair while holding a heavy item
    scope heavy_item_hold_moveset_2: {
        OS.patch_start(0xC0B34, 0x801460F4)
        j       heavy_item_hold_moveset_2
        lw      t8, 0x0008(t6)      // t8 = character id
        _return:
        OS.patch_end()


        addiu   at, r0, Character.id.GOEMON

        bnel    at, t8, _normal
        addiu   t7, r0, 0x0040      // og line 1

        // if here, goemon
        addiu   t7, r0, 0x0060      // new flag for Goemon

        _normal:
        j       _return
        sw      t7, 0x0010(sp)      // og line 2
    }
    
    // Hook allows goemon to have his golden hair after he picks up a heavy item
    scope heavy_item_pickup_moveset: {
        OS.patch_start(0xC0A88, 0x80146048)
        j       heavy_item_pickup_moveset
        lw      t8, 0x0008(v1)      //t8 = character id
        OS.patch_end()

        addiu   at, r0, Character.id.GOEMON
        bne     at, t8, _normal

        // if here, goemon
        li      at, HEAVY_ITEM_PICKUP
        sw      at, 0x086C(v1)      // update moveset pointer 1

        _normal:
        j       0x80146054          // og line 1 modified
        sw      t9, 0x09EC(v1)      // og line 2
    }

    // Hook allows goemon to have his golden hair while holding a heavy item
    scope heavy_item_turn_moveset: {
        OS.patch_start(0xC0C70, 0x80146230)
        j       heavy_item_turn_moveset
        lw      a0, 0x0024(sp)      // og line 1
        _return:
        OS.patch_end()

        lw      t8, 0x0008(a0)      // t8 = character id
        addiu   at, r0, Character.id.GOEMON

        bne     at, t8, _normal
        nop

        // if here, goemon
        li      at, HEAVY_ITEM_TURN
        sw      at, 0x086C(a0)      // update moveset pointer 1

        _normal:
        j       _return
        lui     t8, 0x8014          // og line 2
    }

    // Hook allows goemon to have his golden hair while holding a heavy item
    scope heavy_item_turn_moveset_2: {
        OS.patch_start(0xC0C54, 0x80146214)
        j       heavy_item_turn_moveset_2
        lw      t8, 0x0008(t6)      // t8 = character id
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.GOEMON

        bnel    at, t8, _normal
        addiu   t7, r0, 0x0040      // og line 1

        // if here, goemon
        addiu   t7, r0, 0x0060      // new flag for Goemon

        _normal:
        j       _return
        sw      t7, 0x0010(sp)      // og line 2
    }

    // @ Description
    // Entry routine for Goemon. Sets the correct facing direction and then jumps to Link's entry routine.
    scope goemon_entry_routine_: {
        lw      a1, 0x0B1C(s0)              // a1 = direction
        addiu   at, r0,-0x0001              // at = -1 (left)
        beql    a1, at, _end                // branch if direction = left...
        sw      v1, 0x0B24(s0)              // ...and enable reversed direction flag

        _end:
        j       0x8013DCCC                  // jump to Link's entry routine to load entry object
        nop
    }

    // // @ Description
    // // double damage for crates that Goemon throws
    // scope double_crate_damage: {
        // OS.patch_start(0xF42D0, 0x80179894)
        // j       double_crate_damage
        // lw      t0, 0x0084(a0)      // t0 = item struct
        // _return:
        // OS.patch_end()

        // lw      t1, 0x0008(t0)      // t1 = player owner
        // beqz    t1, _normal         // failsafe in case there is no player owner
        // nop
        // lw      t2, 0x0084(t1)      // t2 = player owner struct
        // lw      t3, 0x0008(t2)      // t3 = character id
        // addiu   at, r0, Character.id.GOEMON
        // bne     at, t3, _normal
        // lui     at, 0x4000          // at = 2.0 in fp

        // // if here, Goemon
        // sw      at, 0x0118(t0)      // set damage multiplier to 2.0

        // _normal:
        // lui     a1, 0x8019          // og line 1, load crate item struct
        // j       _return
        // addiu   a1, a1, 0xA384      // og line 2

    // }
    // // @ Description
    // // double damage for barrels that Goemon throws
    // scope double_barrel_damage: {
        // OS.patch_start(0xF4968, 0x80179F28)
        // j       double_barrel_damage
        // lw      t0, 0x0084(a0)      // t0 = item struct
        // _return:
        // OS.patch_end()

        // lw      t1, 0x0008(t0)      // t1 = player owner
        // beqz    t1, _normal         // failsafe in case there is no player owner
        // nop
        // lw      t2, 0x0084(t1)      // t2 = player owner struct
        // lw      t3, 0x0008(t2)      // t3 = character id
        // addiu   at, r0, Character.id.GOEMON
        // bne     at, t3, _normal
        // lui     at, 0x4000          // at = 2.0 in fp

        // // if here, Goemon
        // sw      at, 0x0118(t0)      // set damage multiplier to 2.0

        // _normal:
        // sw      a0, 0x0018(sp)     // og line 1, load crate item struct
        // j       _return
        // addiu   a1, a1, 0xA484      // og line 2

    // }


}
