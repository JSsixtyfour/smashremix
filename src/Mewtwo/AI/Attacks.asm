// This file contains this characters AI attacks

// Define input sequences

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB,    4, 143, 486, 244, 409)
AI.add_attack_behaviour(FTILT,  6, 85, 679, 38, 362)
AI.add_attack_behaviour(UTILT,  6, -515, 477, 202, 1015)
AI.add_attack_behaviour(DTILT,  5, 21, 654, 9, 287)
AI.add_attack_behaviour(FSMASH, 18, 296, 751, 179, 379)
AI.add_attack_behaviour(USMASH, 10, -105, 105, 267, 868)
AI.add_attack_behaviour(DSMASH, 14, 116, 466, 18, 341)
AI.add_attack_behaviour(NSPG,   24, 800, 3000, 100, 400)
AI.add_attack_behaviour(DSPG,   15, 100+200, 799, 317, 427)
AI.add_attack_behaviour(GRAB,   6, 260, 410, 222, 372)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 10, 331, 1576, 135, 275)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 5, -175, 100, -9, 381)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, -45, 420, -22, 398)
AI.add_attack_behaviour(UAIR, 6, -523, 538, -55, 801)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8, -654, 96, -107, 660)
AI.add_attack_behaviour(DAIR, 8, -397, 327, -308, 179)
AI.add_attack_behaviour(NAIR, 5+4, -175, 100, -9, 381) // late hit
AI.add_attack_behaviour(DSPA, 15, 100+200, 799, 252, 362)
AI.add_attack_behaviour(NSPA, 24, 800, 3000, 100, 400)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.MTWO, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.MTWO, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.MTWO, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // If going for DSP, check if the opponent is:
    // grounded, looking at us, not already dizzy
    lw t0, 0x1D4(a0) // t0 = ft_com->p_command
    li t1, AI.command_table // load command table base address

    lw at, AI.ATTACK_TABLE.DSPG.INPUT << 2(t1)
    beq t0, at, dsp_check
    lw at, AI.ATTACK_TABLE.DSPA.INPUT << 2(t1)
    beq t0, at, dsp_check
    nop

    b _end
    nop

    scope dsp_check: {
        lw at, 0x01FC(a0) // get target player object

        beqz at, _end // if no target object, skip
        nop

        lw at, 0x84(at) // at = target struct

        lw t0, 0x44(a0) // t0 = our facing direction
        lw t1, 0x44(at) // t1 = target facing direction

        beq t0, t1, _no_input // if facing same direction, don't use it
        nop

        lw t0, 0x14C(at) // t0 = target kinetic state
        bnez t0, _no_input // don't use it if opponent not grounded
        nop

        // skip if the opponent is in one of these states
        lw t0, 0x24(at) // t0 = target action id
        lli t1, Action.Stun
        beq t0, t1, _no_input
        lli t1, Action.Sleep
        beq t0, t1, _no_input
        nop

        b _end // all tests passed, use dsp
        nop

        _no_input:
        // skip DSP
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = NULL

        _end:
    }

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.MTWO, 0x4)
dw cpu_post_process; OS.patch_end()