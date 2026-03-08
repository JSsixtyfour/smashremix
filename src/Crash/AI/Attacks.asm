// This file contains this characters AI attacks

// Define a input sequences
CRASH_DASH_NSP:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_X(0, 1) // reset stick X for 1 frame
AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
AI.CUSTOM(4); // wait for turnaround to finish if needed
AI.STICK_X(0x7F, 2) // dash towards opponent for more 3f (total: 4)
dh 0x0221 // press B
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.END();
AI.add_cpu_input_routine(CRASH_DASH_NSP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NSPG, 1, -205, 205, 140, 405)
AI.add_custom_attack_behaviour(AI.ROUTINE.CRASH_DASH_NSP, 3, 200, 1000, 140, 405) // dash NSP, custom attack
AI.add_attack_behaviour(JAB, 4, 88, 446, 107, 319)
AI.add_attack_behaviour(UTILT, 4, -99, 274, 30, 748)
AI.add_attack_behaviour(GRAB, 6, 131, 281, 181, 331)
AI.add_attack_behaviour(DTILT, 6, 293, 582, -32, 255)
AI.add_attack_behaviour(USMASH, 7, -250, 401, 136, 849)
AI.add_attack_behaviour(FTILT, 9, 62, 563, 110, 359)
AI.add_attack_behaviour(DSMASH, 10, -403, 367, 115, 508)
AI.add_attack_behaviour(FSMASH, 13+1, 156, 684, 76, 429)
AI.add_attack_behaviour(DSPG, 30 + 1 + 5, -288, 305, 152, 612)
AI.add_attack_behaviour(USPG, 6, -235+50, 235-50, 225, 335)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 552, 1212, 105, 291)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NSPA, 1, -205, 205, 140, 405)
AI.add_attack_behaviour(NAIR, 5, -159, 359, 31, 283) // kick 1
AI.add_attack_behaviour(NAIR, 15, -111, 388, 47, 308) // kick 2
AI.add_attack_behaviour(UAIR, 6, -344, 332, 74, 552)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 73, 554, 38, 311)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8+4, 73, 554, 38, 311)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -589, -118, -74, 378)
AI.add_attack_behaviour(DAIR, 12, -102, 127, -156, 266)
AI.add_attack_behaviour(DAIR, 12+4, -102, 127, -156, 266) // late hit
AI.add_attack_behaviour(DAIR, 12+8, -102, 127, -156, 266) // late hit
AI.add_attack_behaviour(USPA, 6, -235+50, 235-50, 225, 335)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.CRASH, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.CRASH, 0x4)
dw      AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()

// Custom recovery logic
scope recovery_logic: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    lw at, 0x24(a0) // at = action id
    lli t0, Action.JumpAerialF

    bne at, t0, _end // skip if not in JumpAerialF
    nop

    lw t0, 0x78(a0) // load location vector
    lwc1 f2, 0x0(t0) // f2 = location X
    lwc1 f4, 0x4(t0) // f4 = location Y

    mtc1 r0, f0 // guarantee f0 = 0

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

    lui at, 0x44FA
    mtc1 at, f22 // f22 = 2000.0

    abs.s f16, f14 // f16 = abs(x distance to ledge)

    c.le.s f22, f16 // if distance to ledge is lower than 2000.0
    nop
    bc1f _end // do not go for NSP if too close
    nop

    lw t6, 0x9C8(a0) // t6 = character attributes
    lwc1 f10, 0xB0(t6) // f10 = ledge grab Y
    add.s f12, f4, f10 // f12 = Y + ledge grab Y

    _execute_ai_command:
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
Character.table_patch_start(recovery_logic, Character.id.CRASH, 0x4)
dw recovery_logic; OS.patch_end()

scope cpu_attack_weight: {
    // s0 = character struct
    // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
    // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
    OS.routine_begin(0x20)

    lw t0, 0x0(s2) // t0 = input id
    addiu at, r0, AI.ATTACK_TABLE.NSPG.INPUT
    beq t0, at, _nsp
    addiu at, r0, AI.ROUTINE.CRASH_DASH_NSP
    beq t0, at, _nsp
    nop
    b _end // no attack matched
    nop

    _nsp:
    // do not nsp if the opponent is shielding
    lw t4, 0x1CC+0x6C(s0) // opponent struct
    lw t1, 0x24(t4) // opponent's current action
    addiu at, r0, Action.Shield
    beq t1, at, _shielding_continue
    addiu at, r0, Action.ShieldStun
    beq t1, at, _shielding_continue
    addiu at, r0, Action.ShieldOn
    beq t1, at, _shielding_continue
    nop
    b _end // opponent not shielding, skip
    nop
    _shielding_continue:
    b _end
    mtc1 r0, f2 // f2 = new weight (override)

    _end:
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_attack_weight, Character.id.CRASH, 0x4)
dw cpu_attack_weight; OS.patch_end()