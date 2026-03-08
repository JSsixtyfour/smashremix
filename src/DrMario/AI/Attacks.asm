// This file contains this characters AI attacks

// Define input sequences

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 2, 210, 400, 83, 184)
AI.add_attack_behaviour(UTILT, 5, -71, 436, 198, 634)
AI.add_attack_behaviour(DTILT, 5, 160, 685, -22, 114)
AI.add_attack_behaviour(GRAB, 6, 146, 291, 163, 308)
AI.add_attack_behaviour(USPG, 6, 5, 330, -9, 216) // used on a bob-omb to get only frame 1 data
AI.add_attack_behaviour(FTILT, 7, 130, 573, 68, 234)
AI.add_attack_behaviour(USMASH, 7, -147, 291, 275, 591)
AI.add_attack_behaviour(DSMASH, 8, -466, 556, -124, 450)
AI.add_attack_behaviour(FSMASH, 17, 122, 580, 76, 236)
AI.add_attack_behaviour(DSPG, 1, -203, 203, -45, 522)
AI.add_attack_behaviour(NSPG, 30, 600, 3000, 0, 400) // around this min x location at this frame
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 335, 1035, 25, 169)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(UAIR, 2, -229, 436, 74, 632)
AI.add_attack_behaviour(NAIR, 3, -141, 151, 38, 233)
AI.add_attack_behaviour(USPA, 6, 5, 330, -9, 216) // used on a bob-omb to get only frame 1 data
AI.add_attack_behaviour(NAIR, 3+4, -141, 151, 38, 233) // late hit
AI.add_attack_behaviour(DAIR, 8, -158, 211, -138, 195)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -392, 90, 69, 378)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 13, -217, 347, -29, 435)
AI.add_attack_behaviour(DSPA, 1, -203, 203, -45, 522)
AI.add_attack_behaviour(NSPA, 30, 600, 3000, -400, 0) // around this min x location at this frame
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.DRM, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.DRM, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.DRM, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()