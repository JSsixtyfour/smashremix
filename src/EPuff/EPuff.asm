// EPuff.asm

// This file contains file inclusions, action edits, and assembly for EPuff.

scope EPuff {
    // Insert Moveset files
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert DAIR, "moveset/DAIR.bin"
    insert DASHATTACK, "moveset/DASHATTACK.bin"
    insert BLINK_SUBROUTINE, "moveset/BLINK_SUBROUTINE.bin"
    insert NEUTRAL_SPECIAL, "moveset/NEUTRAL_SPECIAL.bin"
    insert UP_SPECIAL, "moveset/UP_SPECIAL.bin"
    insert DSPECIAL, "moveset/DSPECIAL.bin"; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x00000000
    insert TECH_STAND, "moveset/TECH_STAND.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    insert STUN, "moveset/STUN_LOOP.bin"; Moveset.GO_TO(STUN)
    insert TAUNT, "moveset/TAUNT.bin"
    dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x0800003C
    dw 0x58000001
    dw 0x00000000
    insert SLEEP, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP)                      // loops

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags

    Character.edit_action_parameters(EPUFF, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(EPUFF, Action.ShieldBreak,     -1,                         SHIELD_BREAK,                 -1)
    Character.edit_action_parameters(EPUFF, Action.Stun,            -1,                         STUN,                         -1)
    Character.edit_action_parameters(EPUFF, Action.Sleep,           -1,                         SLEEP,                        -1)
    Character.edit_action_parameters(EPUFF, Action.Tech,            -1,                         TECH_STAND,                   -1)
    Character.edit_action_parameters(EPUFF, Action.TechF,           -1,                         TECH_ROLL,                    -1)
    Character.edit_action_parameters(EPUFF, Action.TechB,           -1,                         TECH_ROLL,                    -1)
    Character.edit_action_parameters(EPUFF, Action.Taunt,           -1,                         TAUNT,                        -1)
    Character.edit_action_parameters(EPUFF, Action.DashAttack,      -1,                         DASHATTACK,                   -1)
    Character.edit_action_parameters(EPUFF, 0xE6,                   -1,                         NEUTRAL_SPECIAL,              -1)
    Character.edit_action_parameters(EPUFF, 0xE7,                   -1,                         NEUTRAL_SPECIAL,              -1)
    Character.edit_action_parameters(EPUFF, 0xE8,                   -1,                         UP_SPECIAL,                   -1)
    Character.edit_action_parameters(EPUFF, 0xE9,                   -1,                         UP_SPECIAL,                   -1)
    Character.edit_action_parameters(EPUFF, 0xEA,                   -1,                         DSPECIAL,                     -1)
    Character.edit_action_parameters(EPUFF, 0xEB,                   -1,                         DSPECIAL,                     -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.EPUFF, 0x2)
    dh  0x0579
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.EPUFF, 0x4)
    dw  Action.JIGGLY.action_string_table
    OS.patch_end()
}
