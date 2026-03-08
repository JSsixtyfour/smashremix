// This file contains this characters AI attacks

// Define input sequences

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(DSPG, 1, -203, 203, -45, 522)
AI.add_attack_behaviour(JAB, 2, 237, 427, 106, 211)
AI.add_attack_behaviour(DTILT, 3, 8, 396, 10, 179)
AI.add_attack_behaviour(USPG, 5, 39, 331, -5, 227) // used on a bob-omb to get only frame 1 data
AI.add_attack_behaviour(GRAB, 6, 146, 291, 163, 308)
AI.add_attack_behaviour(UTILT, 6, -258, 357, 97, 626)
AI.add_attack_behaviour(FTILT, 7, 184, 556, 73, 229)
AI.add_attack_behaviour(USMASH, 7, -198, 334, 297, 678)
AI.add_attack_behaviour(DSMASH, 8, -466, 556, -124, 450)
AI.add_attack_behaviour(FSMASH, 17, 140, 598, 76, 260)
AI.add_attack_behaviour(NSPG, 35, 600, 3000, 50, 400) // around this min x location at this frame
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 3, 254, 1633, 79, 424)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(DSPA, 1, -203, 203, -45, 522)
AI.add_attack_behaviour(UAIR, 2, -229, 436, 74, 632)
AI.add_attack_behaviour(NAIR, 3, -141, 151, 38, 233)
AI.add_attack_behaviour(USPA, 5, 39, 331, -12, 220) // used on a bob-omb to get only frame 1 data
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, -9, 452, 6, 490)
AI.add_attack_behaviour(NAIR, 3+4, -141, 151, 38, 233) // late hit
AI.add_attack_behaviour(DAIR, 8, -130, 243, -115, 188)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -392, 90, 69, 378)
AI.add_attack_behaviour(NSPA, 35, 600, 3000, 50, 400) // around this min x location at this frame
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.DRL, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.DRL, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.DRL, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()