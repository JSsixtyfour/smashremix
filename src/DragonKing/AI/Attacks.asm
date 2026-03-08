// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 5, 77, 345, 324, 490)
AI.add_attack_behaviour(UTILT, 4, -265, 432, 121, 838)
AI.add_attack_behaviour(GRAB, 6, 221, 371, 196, 346)
AI.add_attack_behaviour(USMASH, 6, -346, 405, 305, 1023)
AI.add_attack_behaviour(FTILT, 8, 170, 692, 306, 436)
AI.add_attack_behaviour(DSMASH, 8, -268, 560, -2, 332)
AI.add_attack_behaviour(DTILT, 9, 145, 652, 3, 181)
AI.add_attack_behaviour(FSMASH, 15, 144, 579, 245, 425)
AI.add_attack_behaviour(USPG, 16, -35, 318, 209, 808)
AI.add_attack_behaviour(DSPG, 20, -588, 783, -100, 100)
AI.add_attack_behaviour(NSPG, 29, 300, 804, 290, 603)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 345, 998, 21, 155)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -58, 343, 148, 329)
AI.add_attack_behaviour(UAIR, 2, -504, 468, -132, 944)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 6, -70, 453, 85, 408)
AI.add_attack_behaviour(NAIR, 4+4, -58, 343, 148, 329) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 9, -605, -47, 172, 361)
AI.add_attack_behaviour(DAIR, 7, -142, 285, -212, 318)
AI.add_attack_behaviour(USPA, 16, -25, 337, 340, 857)
AI.add_attack_behaviour(USPA, 25, -37, 595, 319, 1369)
AI.add_attack_behaviour(DSPA, 17+20, -14+200, 764-500, -1527+1000, 52-300) // From a fullhop. Added delay to avoid overuse and compensate travel time
AI.add_attack_behaviour(NSPA, 29, 203, 706, 195, 506)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.DRAGONKING, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.DRAGONKING, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.YOSHI_FALCON
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
    addiu at, r0, AI.ATTACK_TABLE.USPG.INPUT
    beq t0, at, _usp
    nop
    b _end // no attack matched
    nop

    _usp:
    // do not usp if opponent is 100 units or more below us
    lw t4, 0x1CC+0x6C(s0) // opponent struct
    lw at, 0x78(s0) // at = location vector
    lwc1 f4, 0x4(at) // f4 = our Y position
    lw at, 0x78(t4) // at = opponent location vector
    lwc1 f6, 0x4(at) // f6 = opponent Y position
    sub.s f4, f6, f4 // f4 = opponent Y - our Y
    lui at, 0xC2C8 // at = -100.0
    mtc1 at, f6 // f6 = -100.0
    // if not allow, set f2 (odds) to 0 and skip to end
    c.le.s f6, f4 // if opponent is 100 units or more below us
    nop
    bc1t _usp_allow
    nop
    // if here, opponent is below us. Set odds to 0
    b _end
    mtc1 r0, f2 // f2 = 0.0

    _usp_allow:
    // usp more often vs shielding opponents
    lw t4, 0x1CC+0x6C(s0) // opponent struct
    lw t1, 0x24(t4) // opponent's current action
    addiu at, r0, Action.Shield
    beq t1, at, _usp_continue
    addiu at, r0, Action.ShieldStun
    beq t1, at, _usp_continue
    addiu at, r0, Action.ShieldOn
    beq t1, at, _usp_continue
    nop
    b _end // opponent not shielding, skip
    nop
    _usp_continue:
    lui at, 0x42C8 // at = 100.0
    b _end
    mtc1 at, f2 // f2 = new weight (override)

    _end:
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_attack_weight, Character.id.DRAGONKING, 0x4)
dw cpu_attack_weight; OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    lw at, 0x24(a0) // at = action id
    lli t0, 0x0EF // uspg
    beq t0, at, _point_to_target
    lli t0, 0x0F1 // uspa
    beq t0, at, _point_to_target
    nop
    b _end // no actions matched
    nop

    _point_to_target:
    addiu at, r0, -1 // at = 0xFFFFFFF
    lw v0, 0x00EC(a0) // get current clipping below player
    beq at, v0, _end // skip if not above clipping
    nop
    jal 0x80132758 // execute AI command
    lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.DRAGONKING, 0x4)
dw cpu_post_process; OS.patch_end()