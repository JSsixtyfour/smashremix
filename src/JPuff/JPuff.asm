// JPuff.asm

// This file contains file inclusions, action edits, and assembly for JPuff.

scope JPuff {
    // Insert Moveset files
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert DSMASH, "moveset/DSMASH.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    insert BLINK_SUBROUTINE, "moveset/BLINK_SUBROUTINE.bin"
    insert TECH_STAND, "moveset/TECH_STAND.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    insert STUN, "moveset/STUN_LOOP.bin"; Moveset.GO_TO(STUN)
    insert TAUNT, "moveset/TAUNT.bin"
		dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
		dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
		dw 0x0800003C
		dw 0x58000001
		dw 0x00000000
    insert DASHATTACK, "moveset/DASHATTACK.bin"
    insert NEUTRAL_SPECIAL, "moveset/NEUTRAL_SPECIAL.bin"
    insert UP_SPECIAL, "moveset/UP_SPECIAL.bin"
    insert DSPECIAL, "moveset/DSPECIAL.bin"; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
        dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
        dw 0x00000000

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JPUFF, Action.ShieldBreak,     -1,                         SHIELD_BREAK,                 -1)
    Character.edit_action_parameters(JPUFF, Action.Stun,            -1,                         STUN,                         -1)
    Character.edit_action_parameters(JPUFF, Action.Tech,            -1,                         TECH_STAND,                   -1)
    Character.edit_action_parameters(JPUFF, Action.TechF,           -1,                         TECH_ROLL,                    -1)
    Character.edit_action_parameters(JPUFF, Action.TechB,           -1,                         TECH_ROLL,                    -1)
    Character.edit_action_parameters(JPUFF, Action.DSmash,          -1,                         DSMASH,                       -1)
    Character.edit_action_parameters(JPUFF, Action.ThrowF,          -1,                         FTHROW,                       -1)
    Character.edit_action_parameters(JPUFF, Action.Taunt,           -1,                         TAUNT,                        -1)
    Character.edit_action_parameters(JPUFF, Action.DashAttack,      -1,                         DASHATTACK,                   -1)
    Character.edit_action_parameters(JPUFF, 0xE6,                   -1,                         NEUTRAL_SPECIAL,              -1)
    Character.edit_action_parameters(JPUFF, 0xE7,                   -1,                         NEUTRAL_SPECIAL,              -1)
    Character.edit_action_parameters(JPUFF, 0xE8,                   -1,                         UP_SPECIAL,                    -1)
    Character.edit_action_parameters(JPUFF, 0xE9,                   -1,                         UP_SPECIAL,                    -1)
    Character.edit_action_parameters(JPUFF, 0xEA,                   -1,                         DSPECIAL,                     -1)
    Character.edit_action_parameters(JPUFF, 0xEB,                   -1,                         DSPECIAL,                     -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JPUFF, 0x2)
    dh  0x031F
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JPUFF, 0x4)
    dw  Action.JIGGLY.action_string_table
    OS.patch_end()
}
