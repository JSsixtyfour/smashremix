// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(DTILT, 3, 43, 872, 170, 370)
AI.add_attack_behaviour(JAB, 5, -67, 766, 83, 285)
AI.add_attack_behaviour(GRAB, 6, 345, 520, 183, 358)
AI.add_attack_behaviour(UTILT, 6, -333, 463, 203, 906)
AI.add_attack_behaviour(FTILT, 7, -394, 814, -39, 855)
AI.add_attack_behaviour(DSMASH, 9, -640, 565, 26, 339)
AI.add_attack_behaviour(USMASH, 20, -706, 667, -86, 1067)
AI.add_attack_behaviour(FSMASH, 26, -399, 1082, 15, 1081)
AI.add_attack_behaviour(NSPG, 20, 260, 789, 104, 329)
AI.add_attack_behaviour(DSPG, 22, 400, 2000, -50, 500)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 22, 714, 1646, -18, 162)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 6, -124, 124, 106, 354)
AI.add_attack_behaviour(DAIR, 9, -290, 244, -339, 373)
AI.add_attack_behaviour(NAIR, 6+4, -124, 124, 106, 354) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 10, -176, 700, -95, 827)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -714, -92, 51, 267)
AI.add_attack_behaviour(UAIR, 11, 80, 280, 395, 955)
AI.add_attack_behaviour(NSPA, 20, 260, 789, 104, 329)
AI.add_attack_behaviour(DSPA, 22, 400, 2000, -100, 500)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.DEDEDE, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.DEDEDE, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.USP		// skip USP if unsafe
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.DEDEDE, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

// Custom custom long range action input
Character.table_patch_start(nsp_shoot_custom_move, Character.id.DEDEDE, 0x4)
dw    	AI.ROUTINE.DSP
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // if using DSP, check if we should charge a bit
    lw at, 0x24(a0) // at = action id
    lli t0, Dedede.Action.DSPG_CHARGE
    beq t0, at, charge_check
    lli t0, Dedede.Action.DSPA_CHARGE
    beq t0, at, charge_check
    nop

    b _end
    nop

    scope charge_check: {
        // if not above clipping, do not charge
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _unpress_b // do not charge if not above clipping
        nop

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        lw at, 0x01FC(a0) // get target player object

        beqz at, _end // if no target object, skip
        nop

        lw at, 0x84(at) // at = target struct

        lw t0, 0x78(at) // load target location vector
        lwc1 f6, 0x0(t0) // f6 = target X
        lwc1 f8, 0x4(t0) // f8 = target Y

        sub.s f14, f6, f2 // f14 = x diff
        sub.s f12, f8, f4 // f12 = y diff

        // Calculate distance to target into f20
        mul.s f20, f14, f14 // f20 = (x distance)^2
        mul.s f22, f12, f12 // f22 = (y distance)^2
        add.s f20, f20, f22 // f20 = (x distance)^2 + (y distance)^2
        sqrt.s f20, f20 // f20 = sqrt((x distance)^2 + (y distance)^2) = distance to target

        // if distance > 800, keep holding B
        lui at, 0x4448 // at = 800.0
        mtc1 at, f2
        c.le.s f2, f20 // if 800.0 <= distance
        nop
        bc1f _unpress_b // if distance < 800, unpress B
        nop

        _press_b:
        lh at, 0x01C6(a0) // at = buttons pressed
        ori at, at, 0x4000 // press B
        sh at, 0x01C6(a0) // save press B mask
        b _end
        nop

        _unpress_b:
        sh r0, 0x01C6(a0) // release all buttons

        _end:
    }
    b _end
    nop

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.DEDEDE, 0x4)
dw cpu_post_process; OS.patch_end()

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
    addiu at, r0, AI.ATTACK_TABLE.NSPG.INPUT
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
Character.table_patch_start(cpu_attack_weight, Character.id.DEDEDE, 0x4)
dw cpu_attack_weight; OS.patch_end()