// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 2, 77, 429, 92, 454)
AI.add_attack_behaviour(UTILT, 5, -316, 285, 12, 462)
AI.add_attack_behaviour(DTILT, 5, -129, 415, -25, 444)
AI.add_attack_behaviour(GRAB, 6, 161, 311, 116, 266)
AI.add_attack_behaviour(DSMASH, 7, -547, 493, -53, 226)
AI.add_attack_behaviour(FTILT, 9, -42, 456, 16, 380)
AI.add_attack_behaviour(FSMASH, 9, -458, 587, -16, 595)
AI.add_attack_behaviour(USMASH, 12, -196, 196, 93, 542)
AI.add_attack_behaviour(USPG, 15, 157, 531, 253, 600)
AI.add_attack_behaviour(DSPG, 15, -90, 87, 4, 343)
AI.add_attack_behaviour(NSPG, 20, -350, 489, 41, 570)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, -4, 1250, 42, 337)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 3, -187, 167, -17, 326)
AI.add_attack_behaviour(USPA, 3, -399, 394, -3, 391)
AI.add_attack_behaviour(UAIR, 6, -178, 232, 79, 518)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, 79, 459, -36, 535)
AI.add_attack_behaviour(DAIR, 10, -66, 96, -331, 40)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -207, -33, 62, 221)
AI.add_attack_behaviour(NSPA, 20, -350, 489, 41, 570)
AI.add_attack_behaviour(DSPA, 16+4, -90, 87, 4-200, 343-400)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.EBI, 0x4)
dw CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.EBI, 0x4)
dw AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()