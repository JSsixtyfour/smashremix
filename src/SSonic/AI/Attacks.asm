// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(DSPG, 1, -275, 275, 142, 267)
AI.add_attack_behaviour(JAB, 2, 56, 349, 139, 285)
AI.add_attack_behaviour(UTILT, 4, -321, 345, 49, 571)
AI.add_attack_behaviour(DTILT, 4, -84, 385, 1, 162)
AI.add_attack_behaviour(USMASH, 4, -202, 228, 267, 655)
AI.add_attack_behaviour(FTILT, 5, -84, 381, 35, 333)
AI.add_attack_behaviour(GRAB, 6, 110, 240, 158, 288)
AI.add_attack_behaviour(DSMASH, 6, -365, 369, -32, 274)
AI.add_attack_behaviour(FSMASH, 12, 139, 525, 96, 232)
AI.add_custom_attack_behaviour(AI.ROUTINE.NSP_TOWARDS, 18, 1200, 3000, -200, 800)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 95, 1423, 95, 245)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 3, -47, 257, -4, 242)
AI.add_attack_behaviour(UAIR, 3, -301, 288, -27, 648)
AI.add_attack_behaviour(DAIR, 3, -190, 211, -55, 268)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4, -455, -17, 99, 326)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, -87, 263, 32, 490)
AI.add_attack_behaviour(DSPA, 1, -275, 275, 142, 267)
AI.add_custom_attack_behaviour(AI.ROUTINE.NSP_TOWARDS, 18, 1200, 3000, -800, 800)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.SSONIC, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.SSONIC, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()