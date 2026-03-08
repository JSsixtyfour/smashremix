// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 8, 360, 1179, 218, 386)
AI.add_attack_behaviour(UTILT, 8, 28, 453, 274, 1109)
AI.add_attack_behaviour(USMASH, 10, -225, 535, 174, 1086)
AI.add_attack_behaviour(FTILT, 12, 235, 986, 185, 360)
AI.add_attack_behaviour(DTILT, 12, 255, 1024, 5, 293)
AI.add_attack_behaviour(DSMASH, 12, -778, 736, 29, 535)
AI.add_attack_behaviour(GRAB, 20, 228, 1219, 228, 394)
AI.add_attack_behaviour(FSMASH, 20, 291, 1161, 130, 357)
AI.add_attack_behaviour(NSPG, 10, 1600, 3000, 200, 300) // made up values to force use from a distance
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, -40, 1997, 133, 1059)
AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(UAIR, 4, -67, 308, 215, 726)
AI.add_attack_behaviour(NAIR, 8, -526, 644, -341, 906)
AI.add_attack_behaviour(DAIR, 10, -30, 331, -272, 146)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 14, -1158, -292, 58, 438)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 16, 247, 955, -129, 304)
AI.add_attack_behaviour(NSPA, 10, 1600, 3000, 200, 300) // made up values to force use from a distance
AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.LANKY, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.LANKY, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.LANKY, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()