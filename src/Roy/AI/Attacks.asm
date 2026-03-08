// This file contains this characters AI attacks

ROY_DSP_HELD_10F:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_Y(-0x38)       // stick down, wait 0 frames
// hold B for the initial 11 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(6)           // press B, wait 5 frames
// here onwards we're actually charging the move
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.UNPRESS_B(0);        // unpress B, wait 9 frames
AI.STICK_X(0)           // return stick to neutral
AI.STICK_Y(0)           // return stick to neutral
AI.END();
AI.add_cpu_input_routine(ROY_DSP_HELD_10F)

ROY_DSP_HELD_20F:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_Y(-0x38)       // stick down, wait 0 frames
// hold B for the initial 11 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(6)           // press B, wait 5 frames
// here onwards we're actually charging the move
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.UNPRESS_B(0);        // unpress B, wait 9 frames
AI.STICK_X(0)           // return stick to neutral
AI.STICK_Y(0)           // return stick to neutral
AI.END();
AI.add_cpu_input_routine(ROY_DSP_HELD_20F)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// Editor note: Some move ranges will have reduced range to make him go for sweetspots.
// The original range is kept for reference.

// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 4, 110, 440-50, 105, 586)
AI.add_attack_behaviour(NSPG, 3, 197, 715, 40, 741)
AI.add_attack_behaviour(UTILT, 5, -372+100, 423-100, 190, 851-100)
AI.add_attack_behaviour(GRAB, 6, 175, 443, 208, 377)
AI.add_attack_behaviour(DTILT, 6, 64, 722-100, -18, 212)
AI.add_attack_behaviour(DSMASH, 6, 0, 689-150, -77, 285)
AI.add_attack_behaviour(FTILT, 7, 91, 737-100, -13, 701)
AI.add_attack_behaviour(USPG, 8, 108, 694, 37, 871) // got by upBing into a bob-omb on Battlefield platform, which interrupted the move
AI.add_attack_behaviour(FSMASH, 14, 205, 913-150, -9, 761)
AI.add_attack_behaviour(USMASH, 15, -91, 213, 244, 908)
AI.add_attack_behaviour(DSPG, 11+4, 200, 717-400, -23, 733-400)
AI.add_attack_behaviour(DSMASH, 21, -581+150, 0, -77, 285)
AI.add_custom_attack_behaviour(AI.ROUTINE.ROY_DSP_HELD_10F, 11+10+4, 200, 717-400, -23, 733-400)
AI.add_custom_attack_behaviour(AI.ROUTINE.ROY_DSP_HELD_20F, 11+20+4, 200, 717-400, -23, 733-400)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 10, 582, 1179, -48, 609)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 4, -49, 574-50, -152, 649)
AI.add_attack_behaviour(UAIR, 5, -503, 397, 242, 792-100)
AI.add_attack_behaviour(NAIR, 5, -431, 473-50, 17, 639)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 5, -580, 7, -91, 667)
AI.add_attack_behaviour(DAIR, 6, -492, 475, -256+50, 490)
AI.add_attack_behaviour(DSPA, 11+4, 200, 721-400, -23, 690-400)
AI.add_custom_attack_behaviour(AI.ROUTINE.ROY_DSP_HELD_10F, 11+10+4, -165+300, 721-300, -23, 690-400) // removing this since he spams it too much
AI.add_custom_attack_behaviour(AI.ROUTINE.ROY_DSP_HELD_20F, 11+20+4, -165, 721-100, -23, 690-100) // removing this since he spams it too much

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.ROY, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.ROY, 0x4)
dw      AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.ROY, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // if using NSP, use a custom logic to continue the move
    lw at, 0x24(a0) // at = action id
    lli t0, Roy.Action.NSPG_1
    beq t0, at, nsp_logic
    lli t0, Roy.Action.NSPG_2_High
    beq t0, at, nsp_logic
    lli t0, Roy.Action.NSPG_2_Mid
    beq t0, at, nsp_logic
    lli t0, Roy.Action.NSPG_2_Low
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
        lli t1, Roy.Action.NSPG_2_High
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.USPG.INPUT
        lli t1, Roy.Action.NSPG_2_Mid
        beq at, t1, _goto_next
        lli a1, AI.ATTACK_TABLE.NSPG.INPUT
        lli t1, Roy.Action.NSPG_2_Low
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
Character.table_patch_start(cpu_post_process, Character.id.ROY, 0x4)
dw cpu_post_process; OS.patch_end()