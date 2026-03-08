// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(USPG, 5, -329, 329, 296, 544)
AI.add_attack_behaviour(USPG, 5+5, -675, 675, 296, 544) // full slide
AI.add_attack_behaviour(JAB, 18, 206, 1046, 132, 536)
AI.add_attack_behaviour(GRAB, 18, 435, 1085, 275, 525)
AI.add_attack_behaviour(DSPG, 8, 285, 515, 285, 515)
AI.add_attack_behaviour(DTILT, 24, 3, 1283, 7, 483)
AI.add_attack_behaviour(DTILT, 45, 344, 1315, 61, 593) // second hit
AI.add_attack_behaviour(DSMASH, 29, 235, 1091, -29, 470) // front hit
AI.add_attack_behaviour(DSMASH, 64, -1097, -185, 28, 457) // back hit
AI.add_attack_behaviour(UTILT, 27, 171, 1111, 416, 1374) // forward part
AI.add_attack_behaviour(UTILT, 27+5, -841, 449, 303, 1456) // back part
AI.add_attack_behaviour(FTILT, 24, 444, 1286, 187, 518)
AI.add_attack_behaviour(USMASH, 32, -136, 525, 330, 1660)
AI.add_attack_behaviour(FSMASH, 50, -365, 1752, 191, 1255)
AI.add_attack_behaviour(NSPG, 20+5, 800, 1400, 0, 600) // added time for fire travel distance
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 17, 329, 2617, 20, 868)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 14, -455, 802, -38, 694)
AI.add_attack_behaviour(NAIR, 14+4, -455, 802, -38, 694) // late hit
AI.add_attack_behaviour(NAIR, 14+8, -455, 802, -38, 694) // later hit
AI.add_attack_behaviour(DAIR, 13, -418, 375, -175, 175)
AI.add_attack_behaviour(DAIR, 13+4, -418, 375, -175, 175) // late hit
AI.add_attack_behaviour(DAIR, 13+8, -418, 375, -175, 175) // later hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 23, 116, 1172, 510, 1502) // upper hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 23+2, 40, 1372, -535, 1502) // full move
AI.add_attack_behaviour(UAIR, 13, 28, 995, 242, 1391) // headbutt
AI.add_attack_behaviour(UAIR, 27, -240, 240, 460, 940) // fire/explosion
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 20, -965, -215, -43, 605)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 20+4, -965, -215, -43, 605) // late hit
AI.add_attack_behaviour(DSPA, 24+8, -230, 230, -1791, 234)
AI.add_attack_behaviour(NSPA, 20+5, 800, 1400, 0, 600)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.GBOWSER, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.GBOWSER, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.GBOWSER
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
Character.table_patch_start(cpu_post_process, Character.id.GBOWSER, 0x4)
dw cpu_post_process; OS.patch_end()