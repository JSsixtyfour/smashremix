// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 3, 217, 499, 162, 273)
AI.add_attack_behaviour(DTILT, 4, 208, 483, -24, 150)
AI.add_attack_behaviour(GRAB, 6, 217, 357, 139, 279)
AI.add_attack_behaviour(FTILT, 6, 148, 530, 178, 304)
AI.add_attack_behaviour(UTILT, 6, -32, 264, 102, 627)
AI.add_attack_behaviour(USMASH, 6, -289, 316, 101, 646)
AI.add_attack_behaviour(DSMASH, 6, -376, 381, -36, 111)
AI.add_attack_behaviour(FSMASH, 14, 303, 705, 69, 336)
AI.add_attack_behaviour(DSPG, 18, 1500, 3000, -200, 800) // DSP at long range
AI.add_attack_behaviour(NSPG, 6+28, 1000, 3000, 200, 300)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 6, 221, 1118, 118, 299)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -53, 252, 64, 336)
AI.add_attack_behaviour(UAIR, 4, -286, 358, 14, 585)
AI.add_attack_behaviour(DAIR, 4, -63, 180, -15, 233)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4, -333, 153, 44, 353)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, -13, 374, 134, 365)
AI.add_attack_behaviour(DSPA, 18, 1500, 3000, -500, 0) // DSP at long range
AI.add_attack_behaviour(NSPA, 6+28, 1000, 3000, 200, 300)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.PEPPY, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.PEPPY, 0x4)
dw      AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()