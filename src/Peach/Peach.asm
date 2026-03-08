// Peach.asm

// This file contains file inclusions, action edits, and assembly for Peach.

scope Peach {

    scope MODEL {
        scope EYE_L {
            constant NORMAL(0xAC000000)
            constant HURT(0xAC000001)
            constant MID(0xAC000002)
            constant CLOSED(0xAC000003)
            constant UP(0xAC000004)
        }
        scope EYE_R {
            constant NORMAL(0xAC100000)
            constant HURT(0xAC100001)
            constant MID(0xAC100002)
            constant CLOSED(0xAC100003)
            constant UP(0xAC100004)
        }
        scope WEAPON {
            constant PAN(0xA0900000)
            constant RACKET(0xA0900001)
            constant CLUB(0xA0900002)
            constant PRSL_CLS(0xA0900003)
            constant PRSL_OPEN(0xA0900004)
            constant HIDE(0xA0900005) // not proper but I don't really care.
        }
        scope HEAD {
            constant NORMAL(0xA0500000)
            constant NOCROWN(0xA0500001)
        }
        scope RIGHT_HAND {
            constant NORMAL(0xA0600000)
            constant CROWN(0xA0600001)
        }
    }

    // Insert Moveset files
    insert JUMP_1,"moveset/JUMP_1.bin"
    insert JUMP_2,"moveset/JUMP_2.bin"
    FLOAT:; insert "moveset/FLOAT.bin";
    insert TEETER,"moveset/TEETER.bin"

    insert FROLL,"moveset/FROLL.bin"
    insert BROLL,"moveset/BROLL.bin"
    insert TECH_STAND,"moveset/TECH_STAND.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"

	insert STUN_START,"moveset/STUN_START.bin"
	insert STUN_LAND,"moveset/STUN_LAND.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    TAUNT:; insert "moveset/TAUNT.bin"
    NAIR:; insert "moveset/AIR_ATTACK_N.bin"
    BAIR:; insert "moveset/AIR_ATTACK_B.bin"
    UAIR:; insert "moveset/AIR_ATTACK_U.bin"
    DAIR:; insert "moveset/AIR_ATTACK_D.bin"
    FAIR:; insert "moveset/AIR_ATTACK_F.bin"
    JAB1:; insert "moveset/JAB1.bin"
    JAB2:; insert "moveset/JAB2.bin"
    DTILT:; insert "moveset/DTILT.bin"
    FTILT:; insert "moveset/FTILT.bin"
    UTILT:; insert "moveset/UTILT.bin"
    DASHATTACK:; insert "moveset/DASHATTACK.bin"
    USMASH:; insert "moveset/USMASH.bin"
    DSMASH:; insert "moveset/DSMASH.bin"

    CLIFF_CATCH:; insert "moveset/CLIFF_CATCH.bin"
    CLIFF_WAIT:; insert "moveset/CLIFF_WAIT.bin"

    RUN:; insert "moveset/RUN.bin"; Moveset.GO_TO(RUN) // loops

    FSMASH_HIGH:; dw MODEL.WEAPON.PAN; insert "moveset/FSMASH_HIGH.bin"
    FSMASH:; dw MODEL.WEAPON.RACKET; insert "moveset/FSMASH.bin"
    FSMASH_LOW:; dw MODEL.WEAPON.CLUB; insert "moveset/FSMASH_LOW.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert THROW_F_DATA,"moveset/THROW_F_DATA.bin"
    THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); insert "moveset/THROW_F.bin"
    insert THROW_B_DATA,"moveset/THROW_B_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
    DOWN_ATTACK_D:; insert "moveset/DOWN_ATTACK_D.bin"
    DOWN_ATTACK_U:; insert "moveset/DOWN_ATTACK_U.bin"
    EDGE_ATTACK_QUICK_2:; insert "moveset/EDGE_ATTACK_QUICK_2.bin"
    EDGE_ATTACK_SLOW_2:; insert "moveset/EDGE_ATTACK_SLOW_2.bin"

    insert NSP_CONCURRENT,"moveset/NSP_CONCURRENT.bin"
    NSP:; Moveset.CONCURRENT_STREAM(NSP_CONCURRENT); insert "moveset/NSP.bin"
    NSP_RECOIL:; insert "moveset/NSP_RECOIL.bin"

    insert USP_CONCURRENT,"moveset/USP_CONCURRENT.bin"
    USP:; Moveset.CONCURRENT_STREAM(USP_CONCURRENT); Moveset.HIDE_ITEM(); dw MODEL.WEAPON.PRSL_CLS; insert "moveset/USP.bin"
    USP_OPEN:; Moveset.HIDE_ITEM(); dw MODEL.WEAPON.PRSL_CLS; insert "moveset/USP_OPEN.bin"
    USP_FLOAT:; Moveset.HIDE_ITEM(); dw MODEL.WEAPON.PRSL_OPEN; dw 0
    USP_CLOSE:; Moveset.HIDE_ITEM(); dw 0xB01C0000; Moveset.AFTER(3); dw MODEL.WEAPON.PRSL_CLS; dw 0
    USP_FALL:; Moveset.HIDE_ITEM(); dw MODEL.WEAPON.PRSL_CLS; dw 0

    LIGHT_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x3800009D; dw 0x58000001; dw 0
    ITEM_DROP:; dw 0xBC000003;  dw 0x08000008; dw 0x54000001; dw 0
    ITEM_THROW_DASH:; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_DASH); dw 0
    ITEM_THROW_F:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_F:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_U:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_D:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_F:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_B:; dw 0xBC000003; dw 0x60000004; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_SMASH_F:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_B:; dw 0xBC000003; dw 0x60000006; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_U:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    ITEM_THROW_AIR_SMASH_D:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    HEAVY_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x58000001; dw 0
    HEAVY_ITEM_THROW_F:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_B:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_SMASH_F:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_SMASH_B:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    BEAMSWORD_JAB:; dw 0xBC000003; dw 0x08000005; dw 0xCC040000; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000005; dw 0x18000000; dw 0x04000004; dw 0xCC03FFFF; dw 0
    BEAMSWORD_TILT:; dw 0xBC000003; dw 0x6000000A; dw 0x08000004; dw 0xBC000004; dw 0xCC040000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000006; dw 0x18000000; dw 0x04000006; dw 0xCC03FFFF; dw 0x08000026; dw 0xBC000003; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000003; dw 0x08000002; dw 0xCC040000; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000003; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000003; dw 0xCC03FFFF; dw 0x0400000F; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_JAB:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000004; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    BAT_SMASH:; dw 0xC4000007; dw 0xBC000003; dw 0xB1300028; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_JAB:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000004; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    FAN_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    STARROD_JAB:; dw 0xBC000003; dw 0xB12C0010; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000004; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000002; dw 0x54000001; dw 0x04000002; dw 0x18000000;  dw 0x08000026; dw 0xBC000003; dw 0
    STARROD_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0xB12C0024; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000002; dw 0x54000002; dw 0x04000005; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    HAMMER:; dw 0xC4000007; dw 0xBC000004; dw 0xAC000001; dw 0xAC100001; Moveset.SUBROUTINE(Moveset.shared.HAMMER); dw 0x04000010; dw 0x18000000; Moveset.GO_TO(HAMMER)


    DSP:
    dw MODEL.EYE_L.HURT; dw MODEL.EYE_R.HURT;
    Moveset.WAIT(12); Moveset.SFX(0x599); Moveset.SET_FLAG(0);
    dw MODEL.EYE_L.NORMAL; dw MODEL.EYE_R.NORMAL;
    Moveset.WAIT(12); Moveset.SET_FLAG(1);  // When she will say BINGO if pulled a stitch
    dw 0;

    ENTRY:
    dw MODEL.WEAPON.PRSL_OPEN;
    Moveset.AFTER(42);
    dw 0x5C000001
    Moveset.AFTER(77);
    dw MODEL.WEAPON.PRSL_CLS;
    dw 0;

    VICTORY1:
    Moveset.AFTER(13);
    Moveset.VOICE(0x591);
    Moveset.AFTER(31);
    dw MODEL.EYE_L.MID; dw MODEL.EYE_R.MID;
    Moveset.AFTER(33);
    dw MODEL.EYE_L.CLOSED; dw MODEL.EYE_R.CLOSED;
    Moveset.AFTER(37);
    dw MODEL.EYE_L.MID; dw MODEL.EYE_R.MID;
    Moveset.AFTER(39);
    dw MODEL.EYE_L.NORMAL; dw MODEL.EYE_R.NORMAL;
    Moveset.AFTER(76);
    dw MODEL.EYE_L.MID; dw MODEL.EYE_R.MID;
    Moveset.AFTER(78);
    dw MODEL.EYE_L.CLOSED; dw MODEL.EYE_R.CLOSED;
    Moveset.AFTER(82);
    dw MODEL.EYE_L.MID; dw MODEL.EYE_R.MID;
    Moveset.AFTER(84);
    dw MODEL.EYE_L.NORMAL; dw MODEL.EYE_R.NORMAL;
    Moveset.END();

    VICTORY2:
    dw MODEL.EYE_L.CLOSED; dw MODEL.EYE_R.CLOSED;
    Moveset.AFTER(0x26);
    Moveset.VOICE(0x597);
    Moveset.AFTER(0x50);
    dw MODEL.EYE_L.MID; dw MODEL.EYE_R.MID;
    Moveset.AFTER(0x52);
    dw MODEL.EYE_L.UP; dw MODEL.EYE_R.UP;
    Moveset.END();

    scope Action: {
        constant EntryL(0xDC)
        constant EntryR(0xDD)
        constant Float(0xDE)
        constant NSPG(0xDF)
        constant NSPA(0xE0)
        constant NSPRecoil(0xE1)
        //constant ?(0xE2)
        constant USPG(0xE3)
        constant USPA(0xE4)
        constant USPOpen(0xE5)
        constant USPFloat(0xE6)
        constant USPClose(0xE7)
        constant USPFall(0xE8)
        constant DSPPull(0xE9)

        // strings!
        string_0x0DC:; String.insert("")
        string_0x0DD:; String.insert("")
        string_0x0DE:; String.insert("Float")
        string_0x0DF:; String.insert("PeachBomber")
        string_0x0E0:; String.insert("PeachBomberAir")
        string_0x0E1:; String.insert("PeachBomberRecoil")
        string_0x0E3:; String.insert("PeachParasol")
        string_0x0E4:; String.insert("PeachParasolAir")
        string_0x0E5:; String.insert("PeachParasolOpen")
        string_0x0E6:; String.insert("PeachParasolFloat")
        string_0x0E7:; String.insert("PeachParasolClose")
        string_0x0E8:; String.insert("FallSpecial")
        string_0x0E9:; String.insert("PeachTurnip")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw 0
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
    }

    // AI stuff, doing this with a new method.
    include "AI/Attacks.asm"

    // Modify Action Parameters             // Action                       // Animation                    // Moveset Data             // Flags
    Character.edit_action_parameters(PEACH, Action.DeadU,                   File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ScreenKO,                File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Entry,                   File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(PEACH, 0x006,                          File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Revive1,                 File.PEACH_DOWN_BOUNCE_D,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Revive2,                 File.PEACH_DOWN_STAND_D,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ReviveWait,              File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Idle,                    File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Walk1,                   File.PEACH_WALK1,               -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Walk2,                   File.PEACH_WALK2,               -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Walk3,                   File.PEACH_WALK3,               -1,                         -1)
    Character.edit_action_parameters(PEACH, 0x00E,                          File.PEACH_TEETER_START,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Dash,                    File.PEACH_DASH,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Run,                     File.PEACH_RUN,                 RUN,                         -1)
    Character.edit_action_parameters(PEACH, Action.RunBrake,                File.PEACH_RUN_BRAKE,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Turn,                    File.PEACH_TURN,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.TurnRun,                 File.PEACH_TURN_RUN,            -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.JumpSquat,               File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ShieldJumpSquat,         File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.JumpF,                   File.PEACH_JUMP_F,              JUMP_1,                     -1)
    Character.edit_action_parameters(PEACH, Action.JumpB,                   File.PEACH_JUMP_B,              JUMP_1,                     -1)
    Character.edit_action_parameters(PEACH, Action.JumpAerialF,             File.PEACH_JUMP_AERIAL_F,       JUMP_2,                     0x40000000)
    Character.edit_action_parameters(PEACH, Action.JumpAerialB,             File.PEACH_JUMP_AERIAL_B,       JUMP_2,                     0x40000000)
    Character.edit_action_parameters(PEACH, Action.Fall,                    File.PEACH_FALL,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.FallAerial,              File.PEACH_FALL_AERIAL,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Crouch,                  File.PEACH_CROUCH,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CrouchIdle,              File.PEACH_CROUCH_IDLE,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CrouchEnd,               File.PEACH_CROUCH_END,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LandingLight,            File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LandingHeavy,            File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Pass,                    File.PEACH_PLAT_DROP,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ShieldDrop,              File.PEACH_PLAT_DROP,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Teeter,                  File.PEACH_TEETER,              TEETER,                     -1)
    Character.edit_action_parameters(PEACH, Action.TeeterStart,             File.PEACH_TEETER_START,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageHigh1,             File.PEACH_DAMAGE_HIGH1,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageHigh2,             File.PEACH_DAMAGE_HIGH2,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageHigh3,             File.PEACH_DAMAGE_HIGH3,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageMid1,              File.PEACH_DAMAGE_MID1,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageMid2,              File.PEACH_DAMAGE_MID2,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageMid3,              File.PEACH_DAMAGE_MID3,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageLow1,              File.PEACH_DAMAGE_LOW1,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageLow2,              File.PEACH_DAMAGE_LOW2,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageLow3,              File.PEACH_DAMAGE_LOW3,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageAir1,              File.PEACH_DAMAGE_AIR1,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageAir2,              File.PEACH_DAMAGE_AIR2,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageAir3,              File.PEACH_DAMAGE_AIR3,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageElec1,             File.PEACH_DAMAGE_ELEC,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageElec2,             File.PEACH_DAMAGE_ELEC,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageFlyHigh,           File.PEACH_DAMAGE_FLY_HIGH,     -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageFlyMid,            File.PEACH_DAMAGE_FLY_MID,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageFlyLow,            File.PEACH_DAMAGE_FLY_LOW,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageFlyTop,            File.PEACH_DAMAGE_FLY_TOP,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DamageFlyRoll,           File.PEACH_DAMAGE_FLY_ROLL,     -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.WallBounce,              File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Tumble,                  File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.FallSpecial,             File.PEACH_FALL_SPECIAL,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LandingSpecial,          File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Tornado,                 File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.EnterPipe,               File.PEACH_ENTER_PIPE,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ExitPipe,                File.PEACH_EXIT_PIPE,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ExitPipeWalk,            File.PEACH_EXIT_PIPE_WALK,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CeilingBonk,             File.PEACH_CEILING_BONK,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownBounceD,             File.PEACH_DOWN_BOUNCE_D,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownBounceU,             File.PEACH_DOWN_BOUNCE_U,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownStandD,              File.PEACH_DOWN_STAND_D,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownStandU,              File.PEACH_DOWN_STAND_U,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.TechF,                   File.PEACH_TECH_F,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(PEACH, Action.TechB,                   File.PEACH_TECH_B,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(PEACH, Action.DownForwardD,            File.PEACH_DOWN_FORWARD_D,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownForwardU,            File.PEACH_DOWN_FORWARD_U,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownBackD,               File.PEACH_DOWN_BACK_D,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownBackU,               File.PEACH_DOWN_BACK_U,         -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.DownAttackD,             File.PEACH_DOWN_ATK_D,          DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(PEACH, Action.DownAttackU,             File.PEACH_DOWN_ATK_U,          DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(PEACH, Action.Tech,                    File.PEACH_TECH,                TECH_STAND,                 -1)
    Character.edit_action_parameters(PEACH, Action.ClangRecoil,             File.PEACH_CLANG_RECOIL,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffCatch,              File.PEACH_CLF_CATCH,           CLIFF_CATCH,                -1)
    Character.edit_action_parameters(PEACH, Action.CliffWait,               File.PEACH_CLF_WAIT,            CLIFF_WAIT,                 -1)
    Character.edit_action_parameters(PEACH, Action.CliffQuick,              File.PEACH_CLF_Q,               -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffClimbQuick1,        File.PEACH_CLF_CLM_Q1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffClimbQuick2,        File.PEACH_CLF_CLM_Q2,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffSlow,               File.PEACH_CLF_S,               -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffClimbSlow1,         File.PEACH_CLF_CLM_S1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffClimbSlow2,         File.PEACH_CLF_CLM_S2,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffAttackQuick1,       File.PEACH_CLF_ATK_Q1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffAttackQuick2,       File.PEACH_CLF_ATK_Q2,          EDGE_ATTACK_QUICK_2,        -1)
    Character.edit_action_parameters(PEACH, Action.CliffAttackSlow1,        File.PEACH_CLF_ATK_S1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffAttackSlow2,        File.PEACH_CLF_ATK_S2,          EDGE_ATTACK_SLOW_2,         -1)
    Character.edit_action_parameters(PEACH, Action.CliffEscapeQuick1,       File.PEACH_CLF_ESC_Q1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffEscapeQuick2,       File.PEACH_CLF_ESC_Q2,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffEscapeSlow1,        File.PEACH_CLF_ESC_S1,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.CliffEscapeSlow2,        File.PEACH_CLF_ESC_S2,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LightItemPickup,         File.PEACH_L_ITM_PICKUP,        LIGHT_ITEM_PICKUP,          -1)
    Character.edit_action_parameters(PEACH, Action.HeavyItemPickup,         File.PEACH_H_ITM_PICKUP,        HEAVY_ITEM_PICKUP,          -1)
    Character.edit_action_parameters(PEACH, Action.ItemDrop,                File.PEACH_ITM_DROP,            ITEM_DROP,                  -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowDash,           File.PEACH_ITM_THROW_DASH,      ITEM_THROW_DASH,            -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowF,              File.PEACH_ITM_THROW_F,         ITEM_THROW_F,               -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowB,              File.PEACH_ITM_THROW_F,         ITEM_THROW_B,               -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowU,              File.PEACH_ITM_THROW_U,         ITEM_THROW_U,               -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowD,              File.PEACH_ITM_THROW_D,         ITEM_THROW_D,               -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowSmashF,         File.PEACH_ITM_THROW_F,         ITEM_THROW_SMASH_F,         -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowSmashB,         File.PEACH_ITM_THROW_F,         ITEM_THROW_SMASH_B,         -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowSmashU,         File.PEACH_ITM_THROW_U,         ITEM_THROW_SMASH_U,         -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowSmashD,         File.PEACH_ITM_THROW_D,         ITEM_THROW_SMASH_D,         -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirF,           File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_F,           -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirB,           File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_B,           -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirU,           File.PEACH_ITM_THROW_AIR_U,     ITEM_THROW_AIR_U,           -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirD,           File.PEACH_ITM_THROW_AIR_D,     ITEM_THROW_AIR_D,           -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirSmashF,      File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_SMASH_F,     -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirSmashB,      File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_SMASH_B,     -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirSmashU,      File.PEACH_ITM_THROW_AIR_U,     ITEM_THROW_AIR_SMASH_U,     -1)
    Character.edit_action_parameters(PEACH, Action.ItemThrowAirSmashD,      File.PEACH_ITM_THROW_AIR_D,     ITEM_THROW_AIR_SMASH_D,     -1)
    Character.edit_action_parameters(PEACH, Action.HeavyItemThrowF,         File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_F,         -1)
    Character.edit_action_parameters(PEACH, Action.HeavyItemThrowB,         File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_B,         -1)
    Character.edit_action_parameters(PEACH, Action.HeavyItemThrowSmashF,    File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_SMASH_F,   -1)
    Character.edit_action_parameters(PEACH, Action.HeavyItemThrowSmashB,    File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_SMASH_B,   -1)
    Character.edit_action_parameters(PEACH, Action.BeamSwordNeutral,        File.PEACH_ITM_JAB,             BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(PEACH, Action.BeamSwordTilt,           File.PEACH_ITM_TILT,            BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(PEACH, Action.BeamSwordSmash,          File.PEACH_ITM_SMASH,           BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(PEACH, Action.BeamSwordDash,           File.PEACH_ITM_DASH,            BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(PEACH, Action.BatNeutral,              File.PEACH_ITM_JAB,             BAT_JAB,                    -1)
    Character.edit_action_parameters(PEACH, Action.BatTilt,                 File.PEACH_ITM_TILT,            BAT_TILT,                   -1)
    Character.edit_action_parameters(PEACH, Action.BatSmash,                File.PEACH_ITM_SMASH,           BAT_SMASH,                  -1)
    Character.edit_action_parameters(PEACH, Action.BatDash,                 File.PEACH_ITM_DASH,            BAT_DASH,                   -1)
    Character.edit_action_parameters(PEACH, Action.FanNeutral,              File.PEACH_ITM_JAB,             FAN_JAB,                    -1)
    Character.edit_action_parameters(PEACH, Action.FanTilt,                 File.PEACH_ITM_TILT,            FAN_TILT,                   -1)
    Character.edit_action_parameters(PEACH, Action.FanSmash,                File.PEACH_ITM_SMASH,           FAN_SMASH,                  -1)
    Character.edit_action_parameters(PEACH, Action.FanDash,                 File.PEACH_ITM_DASH,            FAN_DASH,                   -1)
    Character.edit_action_parameters(PEACH, Action.StarRodNeutral,          File.PEACH_ITM_JAB,             STARROD_JAB,                -1)
    Character.edit_action_parameters(PEACH, Action.StarRodTilt,             File.PEACH_ITM_TILT,            STARROD_TILT,               -1)
    Character.edit_action_parameters(PEACH, Action.StarRodSmash,            File.PEACH_ITM_SMASH,           STARROD_SMASH,              -1)
    Character.edit_action_parameters(PEACH, Action.StarRodDash,             File.PEACH_ITM_DASH,            STARROD_DASH,               -1)
    Character.edit_action_parameters(PEACH, Action.RayGunShoot,             File.PEACH_ITM_SHOOT,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.RayGunShootAir,          File.PEACH_ITM_SHOOT_AIR,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.FireFlowerShoot,         File.PEACH_ITM_SHOOT,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.FireFlowerShootAir,      File.PEACH_ITM_SHOOT_AIR,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.HammerIdle,              File.PEACH_HAMMER_IDLE,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.HammerWalk,              File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.HammerTurn,              File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.HammerJumpSquat,         File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.HammerAir,               File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.HammerLanding,           File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(PEACH, Action.ShieldOn,                File.PEACH_SHIELD_ON,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ShieldOff,               File.PEACH_SHIELD_OFF,          -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.RollF,                   File.PEACH_ROLL_F,              FROLL,                      -1)
    Character.edit_action_parameters(PEACH, Action.RollB,                   File.PEACH_ROLL_B,              BROLL,                      -1)
    Character.edit_action_parameters(PEACH, Action.ShieldBreak,             File.PEACH_DAMAGE_FLY_TOP,      SHIELD_BREAK,               -1)
    Character.edit_action_parameters(PEACH, Action.ShieldBreakFall,         File.PEACH_TUMBLE,              SPARKLE,                    -1)
    Character.edit_action_parameters(PEACH, Action.StunLandD,               File.PEACH_DOWN_BOUNCE_D,       STUN_LAND,                  -1)
    Character.edit_action_parameters(PEACH, Action.StunLandU,               File.PEACH_DOWN_BOUNCE_U,       STUN_LAND,                  -1)
    Character.edit_action_parameters(PEACH, Action.StunStartD,              File.PEACH_DOWN_STAND_D,        STUN_START,                 -1)
    Character.edit_action_parameters(PEACH, Action.StunStartU,              File.PEACH_DOWN_STAND_U,        STUN_START,                 -1)
    Character.edit_action_parameters(PEACH, Action.Stun,                    File.PEACH_STUN,                STUN,                       -1)
    Character.edit_action_parameters(PEACH, Action.Sleep,                   File.PEACH_STUN,                ASLEEP,                     -1)
    Character.edit_action_parameters(PEACH, Action.Grab,                    File.PEACH_GRAB,                GRAB,                       -1)
    Character.edit_action_parameters(PEACH, Action.GrabPull,                File.PEACH_GRAB_PULL,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ThrowF,                  File.PEACH_THROW_F,             THROW_F,                    -1)
    Character.edit_action_parameters(PEACH, Action.ThrowB,                  File.PEACH_THROW_B,             THROW_B,                    -1)
    Character.edit_action_parameters(PEACH, Action.CapturePulled,           File.PEACH_CAPTURE_PULLED,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.InhalePulled,            File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.InhaleSpat,              File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.InhaleCopied,            File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.EggLayPulled,            File.PEACH_CAPTURE_PULLED,      -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.EggLay,                  File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.FalconDivePulled,        File.PEACH_DAMAGE_HIGH3,        -1,                         -1)
    Character.edit_action_parameters(PEACH, 0x0B4,                          File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ThrownDKPulled,          File.PEACH_THROWN_DK_PULLED,    -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ThrownMarioBros,         File.PEACH_THROWN_MARIO_BROS,   -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ThrownDK,                File.PEACH_THROWN_DK,           -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Thrown1,                 File.PEACH_THROWN1,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Thrown2,                 File.PEACH_THROWN2,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Thrown3,                 File.PEACH_THROWN3,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.ThrownFoxB,              File.PEACH_THROWN_FOX_B,        -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.Taunt,                   File.PEACH_TAUNT,               TAUNT,                      -1)
    Character.edit_action_parameters(PEACH, Action.Jab1,                    File.PEACH_JAB1,                JAB1,                       -1)
    Character.edit_action_parameters(PEACH, Action.Jab2,                    File.PEACH_JAB2,                JAB2,                       -1)
    Character.edit_action_parameters(PEACH, Action.DashAttack,              File.PEACH_DASH_ATTACK,         DASHATTACK,                 -1)
    Character.edit_action_parameters(PEACH, Action.FTiltHigh,               0,                              0x80000000,                 -1)
    Character.edit_action_parameters(PEACH, Action.FTiltMidHigh,            0,                              0x80000000,                 -1)
    Character.edit_action_parameters(PEACH, Action.FTilt,                   File.PEACH_F_TILT,              FTILT,                      -1)
    Character.edit_action_parameters(PEACH, Action.FTiltMidLow,             0,                              0x80000000,                 -1)
    Character.edit_action_parameters(PEACH, Action.FTiltLow,                0,                              0x80000000,                 -1)
    Character.edit_action_parameters(PEACH, Action.UTilt,                   File.PEACH_U_TILT,              UTILT,                      -1)
    Character.edit_action_parameters(PEACH, Action.DTilt,                   File.PEACH_D_TILT,              DTILT,                      -1)
    Character.edit_action_parameters(PEACH, Action.FSmashHigh,              File.PEACH_F_SMASH,             FSMASH_HIGH,                0)
    Character.edit_action_parameters(PEACH, Action.FSmashMidHigh,           File.PEACH_F_SMASH,             FSMASH_HIGH,                0)
    Character.edit_action_parameters(PEACH, Action.FSmash,                  File.PEACH_F_SMASH,             FSMASH,                     0)
    Character.edit_action_parameters(PEACH, Action.FSmashMidLow,            File.PEACH_F_SMASH,             FSMASH_LOW,                 0)
    Character.edit_action_parameters(PEACH, Action.FSmashLow,               File.PEACH_F_SMASH,             FSMASH_LOW,                 0)
    Character.edit_action_parameters(PEACH, Action.USmash,                  File.PEACH_U_SMASH,             USMASH,                     -1)
    Character.edit_action_parameters(PEACH, Action.DSmash,                  File.PEACH_D_SMASH,             DSMASH,                     -1)
    Character.edit_action_parameters(PEACH, Action.AttackAirN,              File.PEACH_ATTACK_AIR_N,        NAIR,                       -1)
    Character.edit_action_parameters(PEACH, Action.AttackAirF,              File.PEACH_ATTACK_AIR_F,        FAIR,                       -1)
    Character.edit_action_parameters(PEACH, Action.AttackAirB,              File.PEACH_ATTACK_AIR_B,        BAIR,                       -1)
    Character.edit_action_parameters(PEACH, Action.AttackAirU,              File.PEACH_ATTACK_AIR_U,        UAIR,                       -1)
    Character.edit_action_parameters(PEACH, Action.AttackAirD,              File.PEACH_ATTACK_AIR_D,        DAIR,                       -1)
    Character.edit_action_parameters(PEACH, Action.LandingAirF,             File.PEACH_LANDING_AIR_F,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LandingAirB,             File.PEACH_LANDING_AIR_B,       -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.LandingAirX,             File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(PEACH, Action.EntryL,                  File.PEACH_ENTRY_L,             ENTRY,                      0x40000000)
    Character.edit_action_parameters(PEACH, Action.EntryR,                  File.PEACH_ENTRY_R,             ENTRY,                      0x40000000)
    Character.edit_action_parameters(PEACH, Action.Float,                   File.PEACH_FLOAT,               FLOAT,                      0)
    Character.edit_action_parameters(PEACH, Action.NSPG,                    File.PEACH_NSP_G,               NSP,                        0)
    Character.edit_action_parameters(PEACH, Action.NSPA,                    File.PEACH_NSP_A,               NSP,                        0)
    Character.edit_action_parameters(PEACH, Action.NSPRecoil,               File.PEACH_NSP_RECOIL,          NSP_RECOIL,                 0)
    Character.edit_action_parameters(PEACH, Action.USPG,                    File.PEACH_USPG,                USP,                        0)
    Character.edit_action_parameters(PEACH, Action.USPA,                    File.PEACH_USPA,                USP,                        0)
    Character.edit_action_parameters(PEACH, Action.USPOpen,                 File.PEACH_USP_OPEN,            USP_OPEN,                   0)
    Character.edit_action_parameters(PEACH, Action.USPFloat,                File.PEACH_USP_FLOAT,           USP_FLOAT,                  0)
    Character.edit_action_parameters(PEACH, Action.USPClose,                File.PEACH_USP_CLOSE,           USP_CLOSE,                  0)
    Character.edit_action_parameters(PEACH, Action.USPFall,                 File.PEACH_FALL_SPECIAL,        USP_FALL,                   0)
    Character.edit_action_parameters(PEACH, Action.DSPPull,                 File.PEACH_TURNIPPULL,          DSP,                        -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(PEACH, Action.EntryL,     0,              0x8013DA94,                 0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(PEACH, Action.EntryR,     0,              0x8013DA94,                 0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(PEACH, Action.Float,      0,              PeachFloat.main_,           PeachFloat.interrupt_,          0x800D9160,                     0x800DE99C)
    Character.edit_action(PEACH, Action.NSPG,       0x12,           0x800D94C4,                 0,                              PeachNSP.ground_physics_,       PeachNSP.ground_collision_)
    Character.edit_action(PEACH, Action.NSPA,       0x12,           0x800D94E8,                 0,                              PeachNSP.air_physics_,          PeachNSP.air_collision_)
    Character.edit_action(PEACH, Action.NSPRecoil,  0x12,           0x800D94E8,                 0,                              0x800D91EC,                     0x800DE99C)
    Character.edit_action(PEACH, Action.USPG,       0x11,           PeachUSP.main_,             PeachUSP.change_direction_,     PeachUSP.physics_,              PeachUSP.collision_)
    Character.edit_action(PEACH, Action.USPA,       0x11,           PeachUSP.main_,             PeachUSP.change_direction_,     PeachUSP.physics_,              PeachUSP.collision_)
    Character.edit_action(PEACH, Action.USPOpen,    0x11,           PeachUSP.open_main_,        0,                              PeachUSP.float_physics_,        PeachUSP.collision_)
    Character.edit_action(PEACH, Action.USPFloat,   0x11,           0,                          PeachUSP.float_interrupt_,      PeachUSP.float_physics_,        PeachUSP.collision_)
    Character.edit_action(PEACH, Action.USPClose,   0x11,           PeachUSP.close_main_,       0,                              0x800D9160,                     PeachUSP.collision_)
    Character.edit_action(PEACH, Action.USPFall,    0x11,           0,                          PeachUSP.fall_interrupt_,       0x80143750,                     0x8014384C)
    Character.edit_action(PEACH, Action.DSPPull,    0x1E,           PeachDSP.main,              0,                              0x800D8BB4,                     0x800DDF44)

    // Modify Menu Action Parameters              // Action // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(PEACH,  0x0,      File.PEACH_IDLE,            -1,                         -1)
    Character.edit_menu_action_parameters(PEACH,  0x1,      File.PEACH_VICTORY1,        VICTORY1,                   -1)
    Character.edit_menu_action_parameters(PEACH,  0x2,      File.PEACH_VICTORY2,        VICTORY2,                   -1)
    Character.edit_menu_action_parameters(PEACH,  0x3,      File.PEACH_VICTORY3,        0x80000000,                 -1)
    Character.edit_menu_action_parameters(PEACH,  0x4,      File.PEACH_VICTORY3,        0x80000000,                 -1)
    Character.edit_menu_action_parameters(PEACH,  0x5,      File.PEACH_CLAP,            0x80000000,                 -1)
    Character.edit_menu_action_parameters(PEACH,  0x9,      File.PEACH_CONTINUE_FALL,   -1,                         -1)
    Character.edit_menu_action_parameters(PEACH,  0xA,      File.PEACH_CONTINUE_UP,     -1,                         -1)
    Character.edit_menu_action_parameters(PEACH,  0xD,      File.PEACH_1P_POSE,         -1,                         -1)
    Character.edit_menu_action_parameters(PEACH,  0xE,      File.PEACH_CPU_POSE,        -1,                         -1)

    Character.table_patch_start(air_usp, Character.id.PEACH, 0x4)
    dw      PeachUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.PEACH, 0x4)
    dw      PeachUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.PEACH, 0x4)
    dw      PeachDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.PEACH, 0x4)
    dw      PeachDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.PEACH, 0x4)
    dw      PeachNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_nsp, Character.id.PEACH, 0x4)
    dw      PeachNSP.ground_initial_
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.PEACH, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
    Character.table_patch_start(grounded_script, Character.id.PEACH, 0x4)
    dw grounded_script_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.PEACH, 0x4)
    float32 1.225
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.PEACH, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set entry action
    Character.table_patch_start(entry_action, Character.id.PEACH, 0x8)
    dw Action.EntryR, Action.EntryL
    OS.patch_end()

    Character.table_patch_start(jab_3, Character.id.PEACH, 0x4)
    dw      Character.jab_3.DISABLED        // disable jab 3
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.PEACH, 0x2)
    dh  0x05D8
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.PEACH, 0xC)
    dh 0x2B
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.PEACH, 0, 1, 2, 3, 2, 3, 4)
    Teams.add_team_costume(YELLOW, PEACH, 1)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(PEACH, MAGENTA, YELLOW, RED, BLUE, GREEN, PURPLE, PINK, WHITE, ORANGE, NA, NA, NA)
	

    // Set action strings
    Character.table_patch_start(action_string, Character.id.PEACH, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.PEACH, 0x2)
    dh {MIDI.id.SM64STAFF}
    OS.patch_end()

    // Set special Jump2 physics
    Character.table_patch_start(ness_jump, Character.id.PEACH, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set 1P Victory Image
    SinglePlayer.set_ending_image(Character.id.PEACH, File.PEACH_VICTORY_IMAGE_BOTTOM)

    OS.align(4)
    // charged smash attack frame data
    charge_smash_frames:
    db 7        // forward
    db 9        // up
    db 3        // down
    db 0        // unused

    // Set Charge Smash attacks entry
    ChargeSmashAttacks.set_charged_smash_attacks(Character.id.PEACH, charge_smash_frames)

    // @ Description
    // Allows Peach's float to not be restored when grabbing the ledge
    scope ledge_patch_: {
        OS.patch_start(0x59E80, 0x800DE680)
        jal     ledge_patch_
        lw      a0, 0x003C(sp)              // original line 2
        OS.patch_end()

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra

        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t7, 0x0008(t6)              // t7 = current character id
        lli     at, Character.id.PEACH      // at = id.PEACH
        beq     at, t7, _peach              // branch if Peach
        lli     at, Character.id.NPEACH    // at = id.NPEACH
        bne     at, t7, _continue           // skip if not NPEACH
        nop

        _peach:
        // if the character is peach or npeach
        li      t6, ledge_flag              // ~
        lli     at, OS.TRUE                 // ~
        sw      at, 0x0000(t6)              // ledge_flag = TRUE

        _continue:
        jal     0x800DE368                  // original line 1 (mpCommonSetFighterLandingParams)
        nop

        _end:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    ledge_flag:
    dw 0

    // Don't restore float when Peach grabs the ledge
    scope grounded_script_: {
        li      t0, ledge_flag              // ~
        lw      at, 0x0000(t0)              // at = ledge_flag
        beqzl   at, _end                    // if ledge_flag = FALSE...
        sw      r0, 0x0ADC(v0)              // ...restore float
        _end:
        j       0x800DE44C
        sw      r0, 0x0000(t0)              // reset ledge_flag
    }


    // restores peach float flag when she initiates a ledge action
    // hook is at the end of the routine that sets a player into a ledge action
    scope restore_float_flag_ledge_action: {
        OS.patch_start(0xBFAAC, 0x8014506C)
        j       restore_float_flag_ledge_action
        sw      t3, 0x09EC(v0)  // og line 1
        _return:
        OS.patch_end()

        sw      t9, 0x0B1C(v0)  // og line 2

        lw      t9, 0x0008(v0)  // t9 = character id
        lli     t3, Character.id.PEACH      // t3 = id.PEACH
        beq     t9, t3, _peach
        lli     t3, Character.id.NPEACH      // t3 = id.NPEACH
        bne     t3, t9, _normal     // branch if not npeach
        nop

        _peach:
        sw      r0, 0x0ADC(v0)      // reset peach float value

        _normal:
        j       _return
        nop
    }

    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        mtc1 r0, f0 // guarantee f0 = 0

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        // check closest ledge in X
        scope ledge_check: {
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x54(a0) // load nearest RIGHT ledge X

            sub.s f6, f6, f2
            abs.s f6, f6 // f6 = abs(distance) to left ledge

            sub.s f8, f8, f2
            abs.s f8, f8 // f8 = abs(distance) to right ledge

            c.le.s f6, f8
            nop
            bc1f _right
            nop

            _left:
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y
            
            b _check_end
            nop

            _right:
            lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
            lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

            _check_end:
        }

        sub.s f14, f6, f2 // f14 = x diff
        sub.s f12, f8, f4 // f12 = y diff

        // if currently jumping or floating, hold jump button
        lw at, 0x24(a0) // at = action id
        lli t0, Action.JumpAerialF
        beq at, t0, _hold_jump
        lli t0, Action.Float
        beq at, t0, _hold_jump
        lli t0, Action.FallAerial
        beq at, t0, _hold_jump
        nop

        // check if too close to use nsp
        lui at, 0x44FA
        mtc1 at, f22 // f22 = 2000.0

        abs.s f16, f14 // f16 = abs(x distance to ledge)

        c.le.s f16, f22 // if distance to ledge is lower than 2000.0
        nop
        bc1t _end // do not go for NSP if already close to ledge
        nop

        // check if up high
        // in this case, go for NSP
        lui at, 0xC4FA
        mtc1 at, f22 // f22 = -2000.0

        c.le.s f12, f22 // if 2000 units or more above ledge
        nop
        bc1t _nsp
        nop

        b _end // no conditions matched, skip
        nop

        _nsp:
        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP_TOWARDS // arg1 = NSP

        b _end
        nop

        // when double jumping, hold a jump button to float
        _hold_jump:
        // check if too close in X to keep floating
        lui at, 0x447A
        mtc1 at, f22 // f22 = 1000.0
        abs.s f16, f14 // f16 = abs(x distance to ledge)
        c.le.s f16, f22 // if distance to ledge is lower than 1000.0
        nop
        bc1t _release_jump // release jump button if already close to ledge
        nop
        lh at, 0x01C6(a0) // at = buttons pressed
        ori at, at, 0x0008 // press C UP
        sh at, 0x01C6(a0) // save pressed buttons mask
        b _end
        nop

        _release_jump:
        lh at, 0x01C6(a0) // at = buttons pressed
        andi at, at, 0xFFF0 // release C UP
        sh at, 0x01C6(a0) // save pressed buttons mask

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.PEACH, 0x4)
    dw recovery_logic; OS.patch_end()
}
