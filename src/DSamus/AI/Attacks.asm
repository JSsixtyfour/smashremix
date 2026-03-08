// This file contains this characters AI attacks

// Define input sequences
DSAMUS_DSP_FOLLOW:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_X(0);
AI.STICK_Y(0xB0);       // stick y down
AI.PRESS_B(1);          // press B, wait 1 frame
AI.UNPRESS_B(0);        // unpress B
AI.STICK_Y(0);          // stick y to neutral
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0x7F, 5);    // stick x towards opponent, wait 5f
AI.STICK_X(0, 0);       // stick x to neutral
AI.END();
AI.add_cpu_input_routine(DSAMUS_DSP_FOLLOW)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 4, 214, 610, 283, 404)
AI.add_attack_behaviour(USPG, 4, -180, 210, -80, 764) // used on a bob-omb in battlefield's platform to avoid far reach/overuse
AI.add_attack_behaviour(FTILT, 6, 30, 488, 276, 428)
AI.add_attack_behaviour(DTILT, 10, 285, 505, 15, 235)
AI.add_attack_behaviour(FSMASH, 10, 194, 757, 254, 420)
AI.add_attack_behaviour(USMASH, 14, -532, 522, 0, 948)
AI.add_attack_behaviour(GRAB, 20, 113, 1225, 188, 297)
AI.add_attack_behaviour(UTILT, 25, 0, 528, 70, 600) // aiming for the leg drop
AI.add_attack_behaviour(DSMASH, 25, -295, 435, 55, 275)
AI.add_attack_behaviour(NSPG, 15+14, 1200, 3000, 300, 400)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 370, 1164, 210, 339)
// we can add new grounded attacks here

AI.add_custom_attack_behaviour(AI.ROUTINE.DSAMUS_DSP_FOLLOW, 10, 3+400, 1397, 0, 127) // added X so she uses it more from a distance

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 3, -138, 138, 48, 423)
AI.add_attack_behaviour(DAIR, 4, -383, 358, -197, 485)
AI.add_attack_behaviour(UAIR, 6, -95, 262, 257, 619)
AI.add_attack_behaviour(USPA, 4, -190, 190, 140, 1285-500) // less range up to avoid far reach/overuse
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 7, -467, 5, 55, 320)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, -21, 592, 309, 690)
AI.add_attack_behaviour(DSPA, 10+8, 23+400, 1451-600, -886+300, 248-400) // done from a full hop. Removed range and added delay to avoid overuse
AI.add_attack_behaviour(NSPA, 20+14, 1200, 3000, 300, 400)
// we can add new aerial attacks here

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.DSAMUS, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.DSAMUS, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.DSAMUS, 0x4)
dw    	AI.PREVENT_ATTACK.ROUTINE.YOSHI_FALCON
OS.patch_end()