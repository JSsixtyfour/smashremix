// This file contains this characters AI attacks

// Define input sequences

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(USPG, 5, -340+200, 340-200, 135, 279) // decrease range since the opponent can DI out of it
AI.add_attack_behaviour(GRAB, 6, 149, 299, 157, 307)
AI.add_attack_behaviour(JAB, 6, 16, 428, 9, 261)
AI.add_attack_behaviour(DTILT, 7, 156, 545, -7, 154)
AI.add_attack_behaviour(UTILT, 8, -75, 345, 196, 517) // 3 initial frames
AI.add_attack_behaviour(USMASH, 9, 13, 396, 144, 671) // 2 initial frames
AI.add_attack_behaviour(DSMASH, 9, 194, 554, 10, 144)
AI.add_attack_behaviour(FTILT, 10+1, 74, 450, -72, 215) // skipped 1 frame to ignore back hit
AI.add_attack_behaviour(UTILT, 12, -445, -37, -59, 538) // frame 4+
AI.add_attack_behaviour(USMASH, 12, -407, 340, 105, 546) // frame 3+
AI.add_attack_behaviour(FSMASH, 14+2, 53, 561, -24, 367) // skipped 2 frames to ignore back hit
AI.add_attack_behaviour(DSMASH, 20, -500, -61, 48, 263) // back hit
AI.add_attack_behaviour(NSPG, 30, 600, 2000, 0, 800) // around this min x location at this frame
// AI.add_attack_behaviour(DSPG, 44, 1000, 3000, 0, 1000) // trying to make him go for it sometimes
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 163, 1079, 73, 213)
// we can add new grounded attacks here

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -118, 230, 45, 242)
AI.add_attack_behaviour(UAIR, 5, -98, 89, 307, 539)
AI.add_attack_behaviour(DAIR, 5, -79, 140, -52, 223)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -385, -37, 99, 279)
AI.add_attack_behaviour(NAIR, 4+4, -118, 230, 45, 242) // late hit
AI.add_attack_behaviour(UAIR, 5+4, -98, 89, 307, 539) // late hit
AI.add_attack_behaviour(DAIR, 5+4, -79, 140, -52, 223) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 9, 156, 494, 141, 335)
AI.add_attack_behaviour(NAIR, 4+8, -118, 230, 45, 242) // later hit
AI.add_attack_behaviour(DAIR, 5+8, -79, 140, -52, 223) // later hit
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 17, -438, -71, 99, 298) // second kick
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 20, 156, 339, 48, 342) // second hit
// AI.add_attack_behaviour(USPA, 5, -340+200, 340-200, 135+200, 279+300) // adding a bit of range up, but not too much to avoid overuse
AI.add_attack_behaviour(NSPA, 30, 600, 2000, -800, 800) // around this min x location at this frame
// AI.add_attack_behaviour(DSPA, 44, 1000, 3000, -1000, 1000) // trying to make him go for it sometimes
// we can add new aerial attacks here

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.YLINK, 0x4)
dw AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

// Custom custom long range action input
Character.table_patch_start(nsp_shoot_custom_move, Character.id.YLINK, 0x4)
dw AI.ROUTINE.DSP
OS.patch_end()

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.YLINK, 0x4)
dw      CPU_ATTACKS
OS.patch_end()