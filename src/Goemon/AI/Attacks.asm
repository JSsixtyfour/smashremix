// This file contains this characters AI attacks

// Define input sequences
GOEMON_HELD_NSP:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_Y(0);
AI.STICK_X(0x7F)        // stick towards opponent
// hold for 35 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.PRESS_B(5)           // press B, wait 5 frames
AI.UNPRESS_B(0);         // unpress B
AI.STICK_X(0)           // return stick to neutral
AI.END();
AI.add_cpu_input_routine(GOEMON_HELD_NSP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 3, 77, 437, 75, 454)
AI.add_attack_behaviour(UTILT, 5, -251, 281, 237, 605)
AI.add_attack_behaviour(DTILT, 5, -129, 415, -25, 444)
AI.add_attack_behaviour(GRAB, 6, 161, 311, 116, 266)
AI.add_attack_behaviour(DSMASH, 7, -547, 493, -53, 226)
AI.add_attack_behaviour(FSMASH, 9, -458, 587, -16, 595)
AI.add_attack_behaviour(FTILT, 12, 241, 851, 112, 231)
AI.add_attack_behaviour(USMASH, 12, -196, 196, 93, 542)
AI.add_attack_behaviour(DSPG, 20+6, 1000, 1683, 33, 181) // adding range and delay to make him use from a distance
AI.add_attack_behaviour(NSPG, 34, 1300, 3600, 50, 220)
AI.add_custom_attack_behaviour(AI.ROUTINE.GOEMON_HELD_NSP, 35+10+8, 1000, 3600, 50, 250) // time: charge+release+travel time
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 319, 1196, 42, 167)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 3, -87, 170, 12, 221)
AI.add_attack_behaviour(UAIR, 6, -178, 232, 79, 518)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, 79, 456, -19, 535)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -487, 206, -80, 457)
AI.add_attack_behaviour(DAIR, 10, -66, 96, -331, 40)
AI.add_attack_behaviour(DSPA, 20+6, 1000, 1683, 33, 181) // adding range and delay to make him use from a distance
AI.add_attack_behaviour(NSPA, 34, 1300, 3600, 50, 220)
AI.add_custom_attack_behaviour(AI.ROUTINE.GOEMON_HELD_NSP, 35+10+8, 1000, 3600, 50, 250) // time: charge+release+travel time

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.GOEMON, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.GOEMON, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()