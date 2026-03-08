// This file contains this characters AI attacks

// Define input sequences

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_custom_attack_behaviour(AI.ROUTINE.MULTI_SHINE, 1, -90, 90, 160, 340)
AI.add_attack_behaviour(JAB, 3, 244, 562, 204, 316)
AI.add_attack_behaviour(FTILT, 6, 170, 606, 205, 336)
AI.add_attack_behaviour(UTILT, 6, -218, 257, 176, 701)
AI.add_attack_behaviour(DTILT, 6, 25, 447, -37, 123)
AI.add_attack_behaviour(FSMASH, 14, 380, 826, 100, 384)
AI.add_attack_behaviour(USMASH, 6, -345, 367, 139, 760)
AI.add_attack_behaviour(DSMASH, 6, -414, 420, -31, 120)
AI.add_attack_behaviour(NSPG, 20, 600, 1976, 151, 266)
AI.add_attack_behaviour(GRAB, 6, 273, 413, 180, 320)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 297, 1156, -78, 313)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -53, 279, 107, 371)
AI.add_attack_behaviour(DAIR, 4, -54, 193, 3, 260)
AI.add_attack_behaviour(UAIR, 6, -82, 179, 172, 633)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 6, 51, 347, 138, 383)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -373, 257, 109, 351)
AI.add_attack_behaviour(NAIR, 4+4, -53, 279, 107, 371) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6+4, -373, 257, 109, 351) // late hit
AI.add_attack_behaviour(NSPA, 20, 350, 1842, 145, 260)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.FALCO, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.FALCO, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.FALCO_NSP
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.FALCO, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // if using USP and there's ground below, go down to land
    lw at, 0x24(a0) // at = action id
    lli t0, Falco.Action.FireBirdStart
    beq t0, at, firefox_down
    lli t0, Falco.Action.FireBirdStartAir
    beq t0, at, firefox_down
    lli t0, Falco.Action.ReadyingFireBird
    beq t0, at, firefox_down
    lli t0, Falco.Action.ReadyingFireBirdAir
    beq t0, at, firefox_down
    lli t0, Falco.Action.FireBird
    beq t0, at, firefox_down
    lli t0, Falco.Action.FireBirdAir
    beq t0, at, firefox_down
    nop

    // If going for aerial NSP when on stage, check if not going offstage with it
    lw t0, 0x1D4(a0) // t0 = ft_com->p_command
    li t1, AI.command_table // load command table base address

    lw at, AI.ATTACK_TABLE.NSPA.INPUT << 2(t1)
    beq t0, at, ground_check
    nop

    b _end
    nop

    scope firefox_down: {
        // check if already above clipping
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // skip if not above clipping
        nop

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = point to target

        addiu at, r0, 0xFFB0 // min stick Y value (down)
        sb at, 0x01C9(a0) // save CPU stick y

        sb r0, 0x01C8(a0) // CPU stick x = 0
    }
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
Character.table_patch_start(cpu_post_process, Character.id.FALCO, 0x4)
dw cpu_post_process; OS.patch_end()