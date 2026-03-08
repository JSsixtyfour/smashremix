// This file contains this characters AI attacks
MARINA_DOUBLE_DSP:
AI.UNPRESS_A();
AI.UNPRESS_Z();
AI.STICK_Y(0xB0); // stick down
AI.STICK_X(0);
AI.UNPRESS_B(1); // unpress B, wait 1 frame
AI.PRESS_B(1) // press B, wait 1 frame
AI.UNPRESS_B(1); // unpress B, wait 1 frame
AI.PRESS_B(1) // press B, wait 1 frame
AI.UNPRESS_B(1); // unpress B, wait 1 frame
AI.STICK_Y(0); // return stick to neutral
AI.END();
AI.add_cpu_input_routine(MARINA_DOUBLE_DSP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 3, 132, 484, 192, 315)
AI.add_attack_behaviour(GRAB, 6, 233, 373, 202, 342)
AI.add_attack_behaviour(UTILT, 6, -304, 365, 167, 576)
AI.add_attack_behaviour(DTILT, 7, 54, 471, -13, 292)
AI.add_attack_behaviour(FTILT, 8, 161, 612, 121, 321)
AI.add_attack_behaviour(DSMASH, 8, -362, 354, 2, 199)
AI.add_attack_behaviour(USPG, 10, -21, 259, 315, 723) // frame 1 only
AI.add_attack_behaviour(USMASH, 12, -62, 208, 261, 715)
AI.add_attack_behaviour(FSMASH, 13, 379, 1206, -30, 340)
AI.add_attack_behaviour(NSPG, 19, 302, 1304, 146, 286)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 283, 1239, 74, 299)
// AI.add_attack_behaviour(DSPG)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 5, -95, 227, 70, 240)
AI.add_attack_behaviour(UAIR, 6, -8, 399, 114, 563)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 6, 9, 424, 53, 296)
AI.add_attack_behaviour(DAIR, 8, -123, 211, -211, 185)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 11, -470, 164, -245, 490)
AI.add_attack_behaviour(USPA, 10, -33, 241, 218, 629) // frame 1 only
AI.add_attack_behaviour(NSPA, 19, 266, 1096, 146, 286)
// AI.add_attack_behaviour(DSPA)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.MARINA, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.MARINA, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARINA_NSP
OS.patch_end()

scope recovery_logic: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    mtc1 r0, f0 // guarantee f0 = 0

    lw t0, 0x78(a0) // load location vector
    lwc1 f2, 0x0(t0) // f2 = location X
    lwc1 f4, 0x4(t0) // f4 = location Y

    // check closest ledge in X
    scope ledge_check: {
        lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
        lwc1 f8, 0x01CC+0x54(a0) // load nearest RIGHT ledge X

        sub.s f6, f6, f2
        abs.s f6, f6 // f6 = abs(distance) to left ledge

        sub.s f8, f8, f2
        abs.s f8, f8 // f8 = abs(distance) to right ledge

        c.le.s f6, f8
        nop
        bc1f _right
        nop

        _left:
        lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
        lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y
        
        b _check_end
        nop

        _right:
        lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
        lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

        _check_end:
    }

    sub.s f14, f6, f2 // f14 = x diff
    sub.s f12, f8, f4 // f12 = y diff

    // skip if air speed is up (to not cut a jump short)
    lwc1 f20, 0x004C(a0) // f20 = y speed
    c.le.s f20, f0 // y speed < 0?
    nop
    bc1f _end // if so, skip
    nop

    // check if too close to use nsp
    lui at, 0x447A
    mtc1 at, f22 // f22 = 1000.0

    abs.s f16, f14 // f16 = abs(x distance to ledge)

    c.le.s f16, f22 // if distance to ledge is lower than 1000.0
    nop
    bc1t _end // do not go for NSP if already close to ledge
    nop

    // check if up high
    // in this case, go for NSP
    lui at, 0xC4FA
    mtc1 at, f22 // f22 = -2000.0

    c.le.s f12, f22 // if 2000 units or more above ledge
    nop
    bc1t _nsp
    nop

    b _end // no conditions matched, skip
    nop

    _nsp:
    swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
    swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

    jal 0x80132758 // execute AI command
    lli a1, AI.ROUTINE.NSP_TOWARDS // arg1 = NSP

    b _end
    nop

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(recovery_logic, Character.id.MARINA, 0x4)
dw recovery_logic; OS.patch_end()

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
Character.table_patch_start(cpu_attack_weight, Character.id.MARINA, 0x4)
dw cpu_attack_weight; OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // during a grab, pick different actions
    lw at, 0x24(a0) // at = action id
    lli t0, Marina.Action.NSPGroundPull
    beq t0, at, jet_snatch
    lli t0, Marina.Action.NSPAirPull
    beq t0, at, jet_snatch
    lli t0, Marina.Action.Cargo
    beq t0, at, cargo
    lli t0, 0xF1 //Marina.Action.CargoAir
    beq t0, at, cargo
    nop

    // check if we have DSP charge
    lw t0, 0x0ADC(a0)
    bnez t0, dsp_check
    nop

    // check if we can absorb a held item
    lw at, 0x84C(a0) // at = held item
    bnez at, item_absorb_check // branch to end if holding an item
    nop

    b _end
    nop

    scope jet_snatch: {
        _randomize:
        lw t0, 0x0ADC(a0) // t0 = current charge
        lli a0, 10 // randomize a number between 0 and 10
        jal Global.get_random_int_ // v0 = (random value)
        nop
        lw a0, 0x10(sp) // restore player struct

        // prioritize upthrow
        lli at, 0x0
        beq v0, at, _end // will throw forward
        lli at, 0x1
        beq v0, at, _end // will throw forward
        lli at, 0x2
        beq v0, at, _end // will throw forward
        lli at, 0x3
        beq v0, at, _back
        lli at, 0x4
        beq v0, at, _back
        nop

        // anything above 4, up throw
        _up:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL
        addiu at, r0, 0x50 // max stick Y value (up)
        sb at, 0x01C9(a0) // save CPU stick y
        sb r0, 0x01C8(a0) // CPU stick x = 0
        b _end
        nop
        
        _back:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X

        lw at, 0x01FC(a0) // get target player object
        beqz at, _end // if no target object, skip
        nop
        lw at, 0x84(at) // at = target struct

        lw t0, 0x78(at) // load target location vector
        lwc1 f6, 0x0(t0) // f6 = target X

        addiu t8, r0, 0x50 // t8 = 80
        c.lt.s f2, f6 // player X < target X
        nop
        bc1fl autofull_away_continue
        nop
        addiu t8, r0, 0xFFB0 // t8 = -80
        autofull_away_continue:
        sb t8,0x1C8(a0) // save cpu stick X
        sb r0, 0x01C9(a0) // CPU stick y = 0

        _end:
    }
    b _end
    nop

    scope cargo: {
        // if cargo release > 0x10, shake shake!
        lw at, 0x01FC(a0) // get target player object
        beqz at, _end // if no target object, skip
        nop
        lw at, 0x84(at) // at = target struct

        lw t0, 0x26C(at) // t0 = cargo release timer
        lli t1, 0x10
        blt t0, t1, _end // if timer <= 0x10, skip
        nop

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP

        _end:
    }
    b _end
    nop

    scope dsp_check: {
        // if not above clipping, do not pull item
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // do not pull item if not above clipping
        nop

        _check_distance:
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

        // if distance > 1000, we can consider using DSP
        lui at, 0x447A // at = 1000.0
        mtc1 at, f2
        c.le.s f2, f20 // if 1000.0 <= distance
        nop
        bc1f _end // if distance < 1000, skip
        nop

        _randomize:
        lw t0, 0x0ADC(a0) // t0 = current charge
        lli a0, 500 // 1 in 500 chance to dsp
        div a0, t0 // higher charge = higher chance
        mflo a0
        jal Global.get_random_int_ // v0 = (random value)
        nop
        lw a0, 0x10(sp) // restore player struct
        beqz v0, _dsp
        nop
        b _end // skipping dsp based on random
        nop

        _dsp:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.MARINA_DOUBLE_DSP // arg1 = DSP
        b _end
        nop

        _end:
    }
    b _end
    nop

    scope item_absorb_check: {
        // if not above clipping, do not absorb item
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // do not pull item if not above clipping
        nop

        lw at, 0x84C(a0) // at = held item

        _randomize:
        lli a0, 600 // 1 in 600 chance to dsp
        jal Global.get_random_int_ // v0 = (random value)
        nop
        lw a0, 0x10(sp) // restore player struct
        beqz v0, _dsp
        nop
        b _end // skipping dsp based on random
        nop

        _dsp:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.DSP // arg1 = DSP
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
Character.table_patch_start(cpu_post_process, Character.id.MARINA, 0x4)
dw cpu_post_process; OS.patch_end()