// This file contains this characters AI attacks

// Create new cpu attack behaviours
OS.align(4)
CPU_ATTACKS:
// grounded attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(JAB, 2, 84, 385, 71, 252)
AI.add_attack_behaviour(GRAB, 6, 194, 334, 82, 222)
AI.add_attack_behaviour(UTILT, 6, -76, 241, 116, 727)
AI.add_attack_behaviour(DTILT, 6, 34, 508, 20, 154)
AI.add_attack_behaviour(FTILT, 7, -27, 400, 7, 194)
AI.add_attack_behaviour(FSMASH, 9, -228, 683, -6, 733)
AI.add_attack_behaviour(USMASH, 9, 86, 526, 109, 797)
AI.add_attack_behaviour(DSMASH, 9, -611, 611, -13, 238)
AI.add_attack_behaviour(DSPG, 17, 200, 1000, 0, 500)
AI.add_custom_attack_behaviour(AI.ROUTINE.SMASH_DSP, 17, 1000, 3000, 500, 1000)
AI.add_attack_behaviour(NSPG, 19, 1100, 1400, 100, 400)
AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 449, 1046, 123, 323)

AI.END_ATTACKS() // end of grounded attacks

// aerial attacks
// add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
AI.add_attack_behaviour(NAIR, 4, -97, 181, -21, 196)
AI.add_attack_behaviour(UAIR, 5, -347, 358, -12, 600)
AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 108, 522, -96, 151)
AI.add_attack_behaviour(DAIR, 9, 8, 270, -377, -24)
AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 12, -518, 15, -236, 631)
AI.add_attack_behaviour(NSPA, 19, 1100, 1400, 100, 400)
AI.add_custom_attack_behaviour(AI.ROUTINE.SMASH_DSP, 17, 1000, 3000, 500, 1000)
AI.add_attack_behaviour(DSPA, 17+10, 200, 1000, -500, 500) // added range down but increased startup so that the grenade can fall

AI.END_ATTACKS() // end of aerial attacks
OS.align(16)

// Set CPU behaviour
Character.table_patch_start(ai_behaviour, Character.id.CONKER, 0x4)
dw CPU_ATTACKS
OS.patch_end()

// Prevents Conker from using grenade when it can't be used
Character.table_patch_start(ai_attack_prevent, Character.id.CONKER, 0x4)
dw	AI.PREVENT_ATTACK.ROUTINE.CONKER_GRENADE
OS.patch_end()

// Set CPU NSP long range behaviour
Character.table_patch_start(ai_long_range, Character.id.CONKER, 0x4)
dw AI.LONG_RANGE.ROUTINE.NSP_SHOOT
OS.patch_end()