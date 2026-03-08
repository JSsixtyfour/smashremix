// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 4, 22, 529, 190, 390)
AI.add_attack_behaviour(FTILT, 6, -29, 427, 134, 634)
AI.add_attack_behaviour(UTILT, 6, -177, 173, 146, 729)
AI.add_attack_behaviour(DTILT, 8, 136, 814, 45, 245)
AI.add_attack_behaviour(FSMASH, 10, 250, 1002, 106, 932)
AI.add_attack_behaviour(USMASH, 10, -482, 448, -88, 1143)
AI.add_attack_behaviour(DSMASH, 10, -680, 671, 30, 333)
AI.add_attack_behaviour(GRAB, 12, 160, 886, 78, 519)
AI.add_attack_behaviour(DSPG, 15, 97, 287, 265, 455)
AI.add_attack_behaviour(NSPG, 70, 700, 1000, 200, 600)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 9, 264, 1036, 108, 932)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(UAIR, 3, -180, 384, 232, 973)
AI.add_attack_behaviour(NAIR, 4, -605, 579, 140, 449)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -965, 0, -67, 728)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, -12, 417, 104, 702)
AI.add_attack_behaviour(DAIR, 12, -127, 123, 130, 445)
AI.add_attack_behaviour(DSPA, 15, 97, 287, 265, 455)
AI.add_attack_behaviour(NSPA, 70, 700, 1000, 200, 600)

// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.PIANO, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.PIANO, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.PIANO, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

scope cpu_attack_weight: {
    // s0 = character struct
    // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
    // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
    OS.routine_begin(0x20)

    // Check CPU level
    lbu t0, 0x13(s0) // t0 = cpu level
    addiu t0, t0, -10 // t0 = 0 if level 10
    bnez t0, _end // if not lv10, perform original logic
    nop

    lw t0, 0x0(s2) // t0 = input id
    addiu at, r0, AI.ATTACK_TABLE.DSPG.INPUT
    beq t0, at, _nsp
    nop
    b _end // no attack matched
    nop

    _nsp:
    // nsp more often vs shielding opponents
    lw t4, 0x1CC+0x6C(s0) // opponent struct
    lw t1, 0x24(t4) // opponent's current action
    addiu at, r0, Action.Shield
    beq t1, at, _nsp_continue
    addiu at, r0, Action.ShieldStun
    beq t1, at, _nsp_continue
    addiu at, r0, Action.ShieldOn
    beq t1, at, _nsp_continue
    nop
    b _end // opponent not shielding, skip
    nop
    _nsp_continue:
    lui at, 0x42C8 // at = 100.0
    b _end
    mtc1 at, f2 // f2 = new weight (override)

    _end:
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_attack_weight, Character.id.PIANO, 0x4)
dw cpu_attack_weight; OS.patch_end()