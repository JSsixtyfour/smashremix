// This file contains this characters AI attacks

// Define input sequences
WARIO_NSP_TOWARDS:
AI.STICK_X(0x7F, 0) // stick towards opponent
AI.STICK_Y(0, 0)
// Wait 40 frames so he never jumps during it
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.STICK_X(0, 0)
AI.UNPRESS_B(0)
AI.END()
AI.add_cpu_input_routine(WARIO_NSP_TOWARDS)

WARIO_NSP_TOWARDS_JUMP:
AI.STICK_X(0x7F, 0) // stick towards opponent
AI.STICK_Y(0, 0)
// Wait 10 frames then jump
AI.PRESS_B(5)
AI.PRESS_B(5)
AI.STICK_X(0, 0)
AI.UNPRESS_B(0)
AI.STICK_Y(0x78, 1) // stick up
AI.STICK_Y(0)
AI.END()
AI.add_cpu_input_routine(WARIO_NSP_TOWARDS_JUMP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 5, 45, 428, 37, 270)
AI.add_attack_behaviour(DTILT, 5, 165, 542, 43, 210)
AI.add_attack_behaviour(GRAB, 6, 211, 361, 103, 253)
AI.add_attack_behaviour(USPG, 6, -200, 200, 300, 600) // decreasing upwards range so he does it less often as a reaching anti-air
AI.add_attack_behaviour(UTILT, 7, -197, 197, 121, 594)
AI.add_attack_behaviour(FTILT, 10, 270, 634, 102, 253)
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS, 11, 95, 235, 175, 315) // frame 1 hit
AI.add_attack_behaviour(FSMASH, 12, 9, 918, 173, 360)
AI.add_attack_behaviour(USMASH, 14, 2, 269, 190, 762)
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS, 18, 95+500, 235+500, 175, 315)
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS_JUMP, 18, 95+500, 235+500, 152+400, 333+400)
AI.add_attack_behaviour(DSMASH, 22, -348, 497, -44, 293)
AI.add_attack_behaviour(DSPG, 26+10, 503, 678, 128, 1183-400) // added some delay so he aims for the frames where it will usually hit a grounded opponent
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 6, 117, 1079, 62, 187)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 5, -38, 153, 55, 245)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, -40, 361, 27, 255)
AI.add_attack_behaviour(UAIR, 7, -32, 227, 212, 507)
AI.add_attack_behaviour(DAIR, 7, -90, 90, -140, 147)
AI.add_attack_behaviour(NAIR, 5+4, -38, 153, 55, 245) // late nair
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5+4, -40, 361, 27, 255) // late fair
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -230, -51, 88, 247)
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS, 11, 95, 235, 175, 315) // frame 1 hit
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS, 18, 95+500, 235+500, 175-200, 315-200)
AI.add_custom_attack_behaviour(AI.ROUTINE.WARIO_NSP_TOWARDS_JUMP, 18, 111+200, 1816-400, -46+200+400, 469+400)
AI.add_attack_behaviour(DSPA, 26+10, -88, 88, -1219+400, 156) // done from a fullhop. Added some delay so he aims for lower frames and does it less often

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.WARIO, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.WARIO, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // If going for NSP when on stage, check if not going offstage with it
    // this is to avoid him going offstage when the opponent is offstage and getting reverse edgeguarded
    lw t0, 0x1D4(a0) // t0 = ft_com->p_command
    li t1, AI.command_table // load command table base address

    lw at, AI.ROUTINE.WARIO_NSP_TOWARDS << 2(t1)
    beq t0, at, ground_check
    lw at, AI.ROUTINE.WARIO_NSP_TOWARDS_JUMP << 2(t1)
    beq t0, at, ground_check
    nop

    b _end
    nop

    scope ground_check: {
        addiu sp, sp, -0x20
        sw a0, 0x18(sp)

        lli v0, 0x1 // default to safe

        // check if above clipping (if using from stage, not as recovery)
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw t0, 0xEC(a0) // get current clipping below player
        beq at, t0, _ground_check_end // skip if not above clipping
        nop

        // create vec3 at sp+0x4
        // based on position + fixed value in the x axis towards target direction
        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        swc1 f2, 0x4(sp) // vec3.x = location X
        lwc1 f2, 0x4(t0) // f2 = location Y
        swc1 f2, 0x8(sp) // vec3.y = location Y
        lwc1 f2, 0x8(t0) // f2 = location Z
        swc1 f2, 0xC(sp) // vec3.z = location Z

        lui at, 0x44FA // at = 2000.0F
        mtc1 at, f6

        lwc1 f2, 0x01CC+0x60(a0) // f2 = target X
        lwc1 f4, 0x0(t0) // f2 = location X
        sub.s f2, f4, f2 // f2 = location X - target X
        mtc1 r0, f0
        c.lt.s f2, f0 // if (location X - target X) < 0
        nop
        bc1fl _ground_check_continue
        neg.s f6, f6
        _ground_check_continue:
        lwc1 f2, 0x4(sp) // vec3.x
        add.s f2, f2, f6 // vec3.x += fixed value towards target
        swc1 f2, 0x4(sp) // store back

        jal 0x800F8FFC
        addiu a0, sp, 0x4 // position vector to check

        _ground_check_end:
        lw a0, 0x18(sp)
        addiu sp, sp, 0x20
    }
    // if not safe to land, clear inputs to avoid SDing
    beqz v0, _no_input
    nop
    b _end
    nop

    _no_input:
    jal 0x80132758 // execute AI command
    lli a1, AI.ROUTINE.NULL // arg1 = NULL
    b _end
    nop

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.WARIO, 0x4)
dw cpu_post_process; OS.patch_end()