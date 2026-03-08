// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_custom_attack_behaviour(AI.ROUTINE.MULTI_SHINE, 1, -100, 100, 159, 359)
AI.add_attack_behaviour(JAB, 3, -62, 497, 201, 571)
AI.add_attack_behaviour(DTILT, 4, 251, 564, -29, 160)
AI.add_attack_behaviour(UTILT, 5, -41, 240, 182, 788)
AI.add_attack_behaviour(GRAB, 6, 162, 292, 236, 366)
AI.add_attack_behaviour(FTILT, 7, 221, 506, 83, 240)
AI.add_attack_behaviour(DSMASH, 8, -437, 455, -66, 261)
AI.add_attack_behaviour(USMASH, 9, -385+100, 353-100, 175, 1006) // Reduced X range because from the ground he usually does dsmash anyways. This should improve anti-air upsmashes
AI.add_attack_behaviour(FSMASH, 12, 453, 779, 124, 326)
AI.add_attack_behaviour(USPG, 25, 1000, 1800, 400, 1500)
AI.add_attack_behaviour(NSPG, 33, 800, 3000, 200, 400) // Approximate. In this amount of frames it should be around the min X range
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 11, 573, 1266, 182, 387)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
// AI.add_attack_behaviour(DSPA, 1, -100, 100, 159, 359)
AI.add_attack_behaviour(NAIR, 4, -89, 307, 55, 244)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 4, 51, 488, 114, 681)
AI.add_attack_behaviour(UAIR, 5, -383, 304, 199, 717)
AI.add_attack_behaviour(DAIR, 7, -141, 120, -99, 316)
AI.add_attack_behaviour(NAIR, 4+4, -89, 307, 55, 244) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 9, -580, -79, 187, 409)
AI.add_attack_behaviour(USPA, 25, 1000, 1800, 400+1200, 1500+1200) // adding range up because he expects to be falling during startup
AI.add_attack_behaviour(NSPA, 33, 800, 3000, 200, 400) // Approximate. In this amount of frames it should be around the min X range

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.WOLF, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.WOLF, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.USP
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.WOLF, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // when performing USP, point towards target
    lw at, 0x24(a0) // at = action id
    lli t0, Wolf.Action.WolfFlashStartAir
    beq t0, at, usp_control
    lli t0, Wolf.Action.WolfFlashStart
    beq t0, at, usp_control
    nop

    // If going for USP when on stage, check if there's ground to land on
    lw t0, 0x1D4(a0) // t0 = ft_com->p_command
    li t1, AI.command_table // load command table base address

    lw at, AI.ATTACK_TABLE.NSPG.INPUT << 2(t1)
    beq t0, at, ground_check
    lw at, AI.ATTACK_TABLE.NSPA.INPUT << 2(t1)
    beq t0, at, ground_check
    nop

    b _end
    nop

    scope usp_control: {
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

        // check if above clipping (if using from stage, not as recovery)
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw t0, 0xEC(a0) // get current clipping below player
        beq at, t0, _hold_up // if not above clipping, go for the upwards version
        nop

        lw t0, 0x78(a0) // t0 = location vector
        lwc1 f2, 0x01CC+0x64(a0) // f2 = target Y
        lwc1 f4, 0x4(t0) // f4 = location Y
        sub.s f2, f2, f4 // f2 = target Y - location Y
        
        // if the opponent is very high compared to us, hold up
        lui at, 0x4489 // ~1100.0
        mtc1 at, f4
        c.lt.s f2, f4 // if constant < (target Y - location Y)
        nop
        bc1f _hold_up
        nop
        // if the opponent is not so high compared to us, go for neutral
        lui at, 0x442F // 700.0
        mtc1 at, f4
        c.lt.s f2, f4 // if (target Y - location Y) < constant
        nop
        bc1f _hold_neutral
        nop
        // else, hold down for a low hit
        _hold_down:
        addiu at, r0, 0xFFB0 // min stick Y value (down)
        b _end
        sb at, 0x01C9(a0) // save CPU stick y

        _hold_neutral:
        addiu at, r0, 0x0 // neutral stick Y value
        b _end
        sb at, 0x01C9(a0) // save CPU stick y

        _hold_up:
        addiu at, r0, 0x50 // max stick Y value (up)
        b _end
        sb at, 0x01C9(a0) // save CPU stick y
    }

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
Character.table_patch_start(cpu_post_process, Character.id.WOLF, 0x4)
dw cpu_post_process; OS.patch_end()