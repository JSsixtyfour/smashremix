// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 5, 52, 497, 312, 501)
AI.add_attack_behaviour(GRAB, 6, 278, 428, 247, 397)
AI.add_attack_behaviour(DTILT, 8, -89, 544, -24, 223)
AI.add_attack_behaviour(FTILT, 10, 61, 564, 356, 506)
AI.add_attack_behaviour(DSMASH, 16, 300, 841, -76, 300)
AI.add_attack_behaviour(DSPG, 16, 31, 2701, 27, 291)
AI.add_attack_behaviour(USMASH, 19, -129, 487, 130, 1237)
AI.add_attack_behaviour(FSMASH, 24, 0, 1008, -56, 896)
AI.add_attack_behaviour(UTILT, 34, 341, 541, 45, 245)
AI.add_attack_behaviour(DSMASH, 34, -764, 0, -76, 300) // back hit
AI.add_attack_behaviour(USPG, 15, 157, 257, 253, 353) // first frame
AI.add_attack_behaviour(USPG, 24, 159, 450, 252+100, 1071)
AI.add_attack_behaviour(NSPG, 47, 335, 1098, 186, 389)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 436, 1342, 248, 381)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(UAIR, 7, -588, 581, 431, 1140)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 7, -610, -162, 206, 516)
AI.add_attack_behaviour(NAIR, 8, -28, 583, 85, 424) // kick 1
AI.add_attack_behaviour(NAIR, 24, 137, 584, 306, 482) // kick 2
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, -333, 270, 351, 700) // 3 initial frames: back hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 11, -62, 560, 7, 634) // forward arch
AI.add_attack_behaviour(DAIR, 14, -139, 95, -51, 414)
AI.add_attack_behaviour(DAIR, 14+4, -139, 95, -51, 414) // late hit
AI.add_attack_behaviour(DAIR, 14+8, -139, 95, -51, 414) // later hit
AI.add_attack_behaviour(USPA, 20, 159, 539, 227, 377)
AI.add_attack_behaviour(USPA, 16, 159, 539, 225, 375) // first frame
AI.add_attack_behaviour(USPA, 24, 159, 543, 227+100, 1006+200)
AI.add_attack_behaviour(NSPA, 47, 89, 980, 237, 512)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.GND, 0x4)
dw CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.GND, 0x4)
dw AI.PREVENT_ATTACK.ROUTINE.YOSHI_FALCON
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
Character.table_patch_start(cpu_attack_weight, Character.id.GND, 0x4)
dw cpu_attack_weight; OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    lw at, 0x24(a0) // at = action id
    lli t0, Ganondorf.Action.WarlockDive
    beq t0, at, _point_to_target
    lli t0, Ganondorf.Action.WarlockDiveEnd2
    beq t0, at, _point_to_target
    nop
    b _end // no actions matched
    nop

    _point_to_target:
    // if recovering with usp, skip this logic
    addiu at, r0, -1 // at = 0xFFFFFFF
    lw v0, 0x00EC(a0) // get current clipping below player
    beq at, v0, _end // skip if not above clipping to not mess up recovery
    nop

    // here, if we're not facing the opponent we hold the correct direction for a turnaround
    // otherwise just point towards the opponent to chase
    lw t0, 0x44(a0) // t0 = facing direction

    lwc1 f6, 0x01CC+0x60(a0) // f6 = target X
    lw at, 0x78(a0) // load location vector
    lwc1 f2, 0x0(at) // f2 = location X

    sub.s f14, f6, f2 // f14 = x diff

    mtc1 r0, f0 // guarantee f0 = 0
    c.lt.s f14, f0 // if x diff < 0
    nop
    bc1t _opponent_left // if x diff < 0, opponent is to the left
    nop

    _opponent_right:
    bgtz t0, _facing_opponent // if facing right already, just point to target
    lli at, 0x50 // max stick X value (right)
    b _apply_x // apply X value
    nop
    
    _opponent_left:
    bltz t0, _facing_opponent // if facing left already, just point to target
    addiu at, r0, 0xFFB0 // min stick X value (left)

    _apply_x:
    sb at, 0x01C8(a0) // save CPU stick x
    sb r0, 0x01C9(a0) // CPU stick y = 0
    jal 0x80132758 // execute AI command
    lli a1, AI.ROUTINE.NULL // arg1 = NULL so our inputs are not overridden
    b _end
    nop

    _facing_opponent:
    jal 0x80132758 // execute AI command
    lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.GND, 0x4)
dw cpu_post_process; OS.patch_end()