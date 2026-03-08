// This file contains this characters AI attacks

// Define input sequences

// Charges DSP a few times, jumps out of it to prevent SDs. Might follow up from it?
SONIC_CHARGED_DSP:
AI.UNPRESS_A();
AI.UNPRESS_B();
AI.UNPRESS_Z();
AI.STICK_X(0);
AI.STICK_Y(0xB0);       // stick y down
AI.PRESS_B(2);          // press B, wait 2 frames
AI.UNPRESS_B(2);        // unpress B, wait 2 frames
AI.PRESS_B(2);          // press B, wait 2 frames
AI.UNPRESS_B(2);        // unpress B, wait 2 frames
AI.PRESS_B(2);          // press B, wait 2 frames
AI.UNPRESS_B(2);        // unpress B, wait 2 frames
AI.PRESS_B(2);          // press B, wait 2 frames
AI.UNPRESS_B(2);        // unpress B, wait 2 frames
AI.STICK_Y(0);          // stick y to neutral
// now wait a bit and then jump to get out of the attack
AI.UNPRESS_B(5);        // unpress B, wait 5 frames
AI.UNPRESS_B(5);        // unpress B, wait 5 frames
AI.UNPRESS_B(5);        // unpress B, wait 5 frames
AI.UNPRESS_B(5);        // unpress B, wait 5 frames
AI.CUSTOM(1);           // press C
AI.UNPRESS_B(1);        // unpress B, wait 1 frame
AI.CUSTOM(2);           // unpress C
AI.END();
AI.add_cpu_input_routine(SONIC_CHARGED_DSP)

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 3, 56, 352, 131, 279)
AI.add_attack_behaviour(DTILT, 5, -32, 386, -12, 219)
AI.add_attack_behaviour(GRAB, 6, 110, 240, 158, 288)
AI.add_attack_behaviour(UTILT, 6, -296, 323, 51, 555)
AI.add_attack_behaviour(USMASH, 6, -217, 228, 267, 656)
AI.add_attack_behaviour(FTILT, 7, -84, 381, 35, 333)
AI.add_attack_behaviour(DSMASH, 8, -365, 369, -32, 274)
AI.add_custom_attack_behaviour(AI.ROUTINE.SONIC_CHARGED_DSP, 12, 400, 1500, 0, 300)
AI.add_attack_behaviour(FSMASH, 17, 20, 525, 97, 351)
AI.add_custom_attack_behaviour(AI.ROUTINE.NSP_TOWARDS, 20, 1200, 2000, -600, 600)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 91, 1297, 105, 235)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -49, 257, -10, 243)
AI.add_attack_behaviour(UAIR, 4, -306, 289, 25, 648)
AI.add_attack_behaviour(DAIR, 4, -192, 220, -58, 292)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -429, -44, 143, 316)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, -132, 262, 23, 490)
AI.add_attack_behaviour(NAIR, 4+4, -49, 257, -10, 243) // late hit
AI.add_custom_attack_behaviour(AI.ROUTINE.NSP_TOWARDS, 20, 1200, 2000, -600, 600)

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.SONIC, 0x4)
dw      CPU_ATTACKS
OS.patch_end()

// Set CPU SD prevent routine
Character.table_patch_start(ai_attack_prevent, Character.id.SONIC, 0x4)
dw      AI.PREVENT_ATTACK.ROUTINE.SONIC_DSP
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.SONIC, 0x4)
dw    	AI.LONG_RANGE.ROUTINE.NONE
OS.patch_end()