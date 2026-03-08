// This file contains this characters AI attacks

// Define input sequences
BANJO_BACKWARDS_NSP:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_Y(0);
AI.STICK_X(0x81)        // stick away from opponent
AI.PRESS_B(1)           // press B, wait 1 frame
AI.UNPRESS_B(1);         // unpress B, wait 1 frame
AI.STICK_X(0x7F, 9)     // stick towards opponent, hold for 9 frames
AI.STICK_X(0)           // return stick to neutral
AI.END();
AI.add_cpu_input_routine(BANJO_BACKWARDS_NSP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 4, 61, 399, 227, 402)
AI.add_attack_behaviour(DTILT, 5, 114, 573, 28, 245)
AI.add_attack_behaviour(GRAB, 6, 244, 394, 118, 268)
AI.add_attack_behaviour(UTILT, 6, -482, 296, 31, 666)
AI.add_attack_behaviour(FTILT, 8, 67, 680, 140, 282)
AI.add_attack_behaviour(DSMASH, 10, -423, 423, 92, 568)
AI.add_attack_behaviour(USMASH, 12, -407, 340, 191, 848)
AI.add_attack_behaviour(FSMASH, 18, -141, 930, -79, 658)
AI.add_attack_behaviour(DSPG, 14, 430, 1446, 98, 256)
AI.add_attack_behaviour(NSPG, 14, 1200, 3000, 100, 200)
AI.add_custom_attack_behaviour(AI.ROUTINE.BANJO_BACKWARDS_NSP, 14, 800, 1500, 100, 300)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 302, 1318, 91, 221)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 5, -178, 325, 110, 546)
AI.add_attack_behaviour(DAIR, 6, -253, 200, -199, 282)
AI.add_attack_behaviour(UAIR, 7, -347, 340, -18, 610)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 9, 57, 465, 94, 384)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 12, -635, -31, 141, 282)
AI.add_attack_behaviour(NSPA, 14, 1200, 3000, 100, 200)
AI.add_custom_attack_behaviour(AI.ROUTINE.BANJO_BACKWARDS_NSP, 14, 800, 1500, -200, 100) // more range down because of the trajectory
AI.add_attack_behaviour(DSPA, 26 + 8, -177, 179, 106 - 100, 313) // added range down because of movement, added delay to compensate

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.BANJO, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.BANJO, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.MARIO
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.BANJO, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()