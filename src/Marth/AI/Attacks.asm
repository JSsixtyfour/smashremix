// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 4, 107, 658, 0, 723)
AI.add_attack_behaviour(UTILT, 5, -27, 596, 81, 892)
AI.add_attack_behaviour(GRAB, 6, 186, 460, 220, 391)
AI.add_attack_behaviour(DTILT, 6, 69, 755, -17, 220)
AI.add_attack_behaviour(DSMASH, 6, 0, 719, -51, 297)
AI.add_attack_behaviour(NSPG, 6, 208, 746, 44, 774)
AI.add_attack_behaviour(FTILT, 7, 179, 851, -12, 732)
AI.add_attack_behaviour(USPG, 8, 79, 200, 49, 800) // not using the top hitbox to avoid the CPU from using it too much as a sourspot anti-air
AI.add_attack_behaviour(UTILT, 10, -193, 0, 81, 892)
AI.add_attack_behaviour(USMASH, 12, -61, 211, 265, 934)
AI.add_attack_behaviour(FSMASH, 14, 300, 955, -7, 795)
AI.add_attack_behaviour(DSMASH, 21, -593, 0, -51, 297) // back hit
AI.add_attack_behaviour(DSPG, 6, -100, -100, -100, 100)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 13, 723, 1298, -23, 413)
// we can add new grounded attacks here
AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 4, 200, 571, -157, 678)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 5, -605, -200, -94, 697)
AI.add_attack_behaviour(NAIR, 5, 100, 493, 106, 437)
AI.add_attack_behaviour(UAIR, 5, -100, 413, 256, 827)
AI.add_attack_behaviour(DAIR, 6, -513, 495, -266, 511)
AI.add_attack_behaviour(UAIR, 8, -525, 0, 256, 827) // back hit
AI.add_attack_behaviour(DAIR, 9, -513, 0, -266, 511) // back hit
AI.add_attack_behaviour(NAIR, 16, -449, 0, 200, 667) // back hit
AI.add_attack_behaviour(NAIR, 19, 0, 493, 21, 600) // 2nd forward hit
// AI.add_attack_behaviour(NSPA, 0, 0, 0, 0, 0) // no attack
// AI.add_attack_behaviour(USPA, 8, 0, 100, 54, 100) // using low range forwards and upwards for him to only use it when really close
// AI.add_attack_behaviour(DSPA, 0, 0, 0, 0, 0) // no attack
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.MARTH, 0x4)
dw CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.MARTH, 0x4)
dw AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.MARTH, 0x4)
dw AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // if using NSP, use a custom logic to continue the move
    lw at, 0x24(a0) // at = action id
    lli t0, Marth.Action.NSPG_1
    beq t0, at, nsp_logic
    lli t0, Marth.Action.NSPG_2_High
    beq t0, at, nsp_logic
    lli t0, Marth.Action.NSPG_2_Mid
    beq t0, at, nsp_logic
    lli t0, Marth.Action.NSPG_2_Low
    beq t0, at, nsp_logic
    nop

    b _end
    nop

    scope nsp_logic: {
        lw t0, 0x01FC(a0) // t0 = target player object
        beqz t0, _end // if no target object, skip
        nop
        lw t0, 0x84(t0) // t0 = target struct

        lw at, 0x40(a0) // at = hitlag
        beqz at, _end // if we're not in hitlag, the move didn't hit. Skip
        nop

        // if already in step 2, do the 3rd one in the same direction
        lw at, 0x24(a0) // at = action id
        lli t1, Marth.Action.NSPG_2_High
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.USPG.INPUT
        lli t1, Marth.Action.NSPG_2_Mid
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.NSPG.INPUT
        lli t1, Marth.Action.NSPG_2_Low
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.DSPG.INPUT

        lw t1, 0x24(t0) // opponent's state
        lli at, Action.Shield
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.DSPG.INPUT // if hitting shield, go for the low variation for shield damage
        lli at, Action.ShieldStun
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.DSPG.INPUT // if hitting shield, go for the low variation for shield damage

        // otherwise, decide direction
        _decide_direction:
        // at low %, go for downwards for damage
        lw t1, 0x2C(t0) // t1 = target percentage
        lli at, 30
        blt t1, at, _goto_next
        lli a1, AI.ATTACK_TABLE.DSPG.INPUT

        // at high %, go for neutral for KOs
        lw t1, 0x2C(t0) // t1 = target percentage
        lli at, 100
        bgt t1, at, _goto_next
        lli a1, AI.ATTACK_TABLE.NSPG.INPUT

        // otherwise, just randomize it
        jal Global.get_random_int_  // v0 = (random value)
        lli a0, 0x3 // v0 = 0-2
        lw a0, 0x10(sp) // restore player struct

        lli at, 0
        beq v0, at, _goto_next
        lli a1, AI.ATTACK_TABLE.NSPG.INPUT
        lli at, 1
        beq v0, at, _goto_next
        lli a1, AI.ATTACK_TABLE.USPG.INPUT
        lli a1, AI.ATTACK_TABLE.DSPG.INPUT

        _goto_next:
        jal 0x80132758 // execute AI command
        nop // command is already in a1
        lli at, 0xF
        sb at, 0x1D3(a0) // add higher input_wait so the timing works

        _end:
    }

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.MARTH, 0x4)
dw cpu_post_process; OS.patch_end()