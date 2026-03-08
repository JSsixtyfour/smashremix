// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(DSPG, 1, -90, 90, 140, 320)
AI.add_attack_behaviour(JAB, 2, 226, 412, 85, 213)
AI.add_attack_behaviour(DTILT, 3, 17, 391, 8, 154)
AI.add_attack_behaviour(GRAB, 6, 176, 326, 126, 276)
AI.add_attack_behaviour(FTILT, 6, 162, 572, 194, 323)
AI.add_attack_behaviour(UTILT, 6, -188, 188, 79, 505)
AI.add_attack_behaviour(USMASH, 7, -137, 262, 303, 594)
AI.add_attack_behaviour(FSMASH, 12, 2, 882, 160, 339)
AI.add_attack_behaviour(DSMASH, 14, -286, 401, -46, 291)
AI.add_attack_behaviour(NSPG, 33, 800, 3000, 100, 400)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 3, 261, 1490, 148, 462)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 3, -51, 140, 107, 297)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, -28, 418, 38, 312)
AI.add_attack_behaviour(DAIR, 5, -90, 90, -128, 133)
AI.add_attack_behaviour(UAIR, 6, -195, 161, -74, 591)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 10, -424, 66, 109, 438)
AI.add_attack_behaviour(NSPA, 33, 800, 3000, 100, 400)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.SLIPPY, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.SLIPPY, 0x4)
dw      AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()