// This file contains this characters AI attacks

// Define input sequences
BOWSER_SHORTHOP_FIREBREATH:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_Y(0);
AI.CUSTOM(1);           // press C
AI.STICK_X(0x7F, 1);    // stick x towards opponent, wait 1 frame
AI.CUSTOM(2);           // unpress C
AI.STICK_X(0, 7);       // stick x to neutral, wait 7 frames
AI.STICK_X(0, 7);       // stick x to neutral, wait 7 frames
AI.PRESS_B(1);          // press B, wait 1 frame
AI.UNPRESS_B();         // unpress B
AI.STICK_X(0x7F, 9);    // stick x towards opponent, wait 9 frames
AI.STICK_X(0);          // stick x to neutral
AI.END();
AI.add_cpu_input_routine(BOWSER_SHORTHOP_FIREBREATH)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(USPG, 5, -273, 273, 167, 287)
AI.add_attack_behaviour(GRAB, 6, 227, 593, 141, 291)
AI.add_attack_behaviour(JAB, 6, 108, 579, 64, 295)
AI.add_attack_behaviour(DTILT, 7, 8, 687, 10, 255)
AI.add_attack_behaviour(DSPG, 8, 101, 331, 101, 331)
AI.add_attack_behaviour(UTILT, 8, 87, 603, 231, 855) // front hit
AI.add_attack_behaviour(DSMASH, 8, 129, 585, -11, 251)
AI.add_attack_behaviour(USPG, 5+4, -429, 429, 167, 287) // full slide
AI.add_attack_behaviour(FTILT, 12, 278, 815, 67, 309)
AI.add_attack_behaviour(USMASH, 15, -72, 266, 145, 881)
AI.add_attack_behaviour(DTILT, 20, 192, 700, 32, 314) // second hit
AI.add_attack_behaviour(UTILT, 8+14, -438, 156, 233, 842) // back hit
AI.add_attack_behaviour(NSPG, 20+5, 600, 1000, 0, 400) // added time for fire travel distance
AI.add_attack_behaviour(FSMASH, 26, -202, 697, 91, 695)
AI.add_attack_behaviour(DSMASH, 36, -586, -113, 19, 242) // back hit
// we can add new grounded attacks here
AI.add_custom_attack_behaviour(AI.ROUTINE.BOWSER_SHORTHOP_FIREBREATH, 20+5, 500, 1500, 0, 500) // added time for shorthop wait, fire travel distance
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 13, 174, 1398, 18, 463)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -239, 427, -15, 367)
AI.add_attack_behaviour(UAIR, 7, 22, 531, 135, 746) // headbutt
AI.add_attack_behaviour(DAIR, 8, -216, 193, -85, 85)
AI.add_attack_behaviour(NAIR, 4+4, -239, 427, -15, 367) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 9, 68, 656, 184, 749) // 3 initial frames (upper)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -576, -123, -16, 320)
AI.add_attack_behaviour(NAIR, 4+8, -239, 427, -15, 367) // later hit
AI.add_attack_behaviour(DAIR, 8+4, -216, 193, -85, 85) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 9+4, 226, 566, -101, 285) // remaining frames (lower)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10+4, -576, -123, -16, 320) // late hit
AI.add_attack_behaviour(DAIR, 8+8, -216, 193, -85, 85) // later hit
AI.add_attack_behaviour(NSPA, 20 + 5, 600, 1000, 0, 400)
AI.add_attack_behaviour(UAIR, 21, -113, 113, 455, 680) // fire
AI.add_attack_behaviour(DSPA, 24 + 8, -115, 115, 101 - 150, 331) // added range down because of movement, added delay to compensate
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.BOWSER, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.BOWSER, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.BOWSER_USP_DSP	// no risky down or up specials
OS.patch_end()

scope cpu_post_process: {
    OS.routine_begin(0x20)
    sw a0, 0x10(sp)

    // when performing grounded USP, point towards target
    lw at, 0x24(a0) // at = action id
    lli t0, Bowser.Action.WhirlingFortress
    beq t0, at, usp_control
    nop
    b _end
    nop

    scope usp_control: {
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target
    }

    _end:
    lw a0, 0x10(sp)
    OS.routine_end(0x20)
}
Character.table_patch_start(cpu_post_process, Character.id.BOWSER, 0x4)
dw cpu_post_process; OS.patch_end()