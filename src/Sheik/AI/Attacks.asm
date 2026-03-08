// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 3, 248, 605, 180, 325)
AI.add_attack_behaviour(DTILT, 4, 95, 540, 60, 308)
AI.add_attack_behaviour(FTILT, 5, 20, 610, 111, 693)
AI.add_attack_behaviour(UTILT, 5, -173, 537, 17, 712)
AI.add_attack_behaviour(DSMASH, 5, -383, 380, 17, 337)
AI.add_attack_behaviour(GRAB, 6, 213, 363, 213, 363)
AI.add_attack_behaviour(FSMASH, 12, 247, 943, 126, 469)
AI.add_attack_behaviour(USMASH, 12, -52, 98, 644, 795) // sweetspot only, got by using a bob-omb on a platform
AI.add_attack_behaviour(NSPG, 12, 1000, 2000, 200, 300)
AI.add_attack_behaviour(DSPG, 18, 400, 1550, 200, 700) // initial state moves Sheik about ~(1000, 600)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 467, 937, 1, 285)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -166, 313, -67, 226)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4, -465, 137, -61, 320)
AI.add_attack_behaviour(UAIR, 4, -66, 215, 244, 598)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, 58, 503, -49, 413)
AI.add_attack_behaviour(DAIR, 5, -150, 140, -83, 299)
AI.add_attack_behaviour(NAIR, 4+4, -166, 313, -67, 226) // late nair
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4+4, -465, 137, -61, 320) // late bair
AI.add_attack_behaviour(DAIR, 5+4, -150, 140, -83, 299) // late dair
AI.add_attack_behaviour(NSPA, 12, 800, 1800, 800, 1800)
AI.add_attack_behaviour(DSPA, 18, 400, 1550, 200, 700) // initial state moves Sheik about ~(1000, 600)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.SHEIK, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.SHEIK, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.SHEIK, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // if using USP and there's ground below, go down to land
    lw at, 0x24(a0) // at = action id
    lli t0, Sheik.Action.USPG_BEGIN
    beq t0, at, teleport_down
    lli t0, Sheik.Action.USPG_MOVE
    beq t0, at, teleport_down
    lli t0, Sheik.Action.USPA_BEGIN
    beq t0, at, teleport_down
    lli t0, Sheik.Action.USPA_MOVE
    beq t0, at, teleport_down
    // if using DSP, don't press B at all or press B when close to the target
    lli t0, Sheik.Action.DSP_BEGIN
    beq t0, at, dsp_control
    nop

    b _end
    nop

    scope teleport_down: {
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

    scope dsp_control: {
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

        // if distance <= 600.0F, press B
        lui at, 0x4416 // at = 600.0f
        mtc1 at, f2
        c.le.s f20, f2
        nop
        bc1f _press_nothing
        nop

        _press_b:
        lh at, 0x01C6(a0) // at = buttons pressed
        ori at, at, 0x4000 // press B
        sh at, 0x01C6(a0) // save press B mask
        b _end
        nop

        _press_nothing:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = NULL
        b _end
        nop

        _end:
    }
    b _end
    nop

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.SHEIK, 0x4)
dw cpu_post_process; OS.patch_end()