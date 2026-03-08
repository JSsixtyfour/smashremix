if !{defined __VanillaLv10Attacks__} {
define __VanillaLv10Attacks__()
print "included VanillaLv10Attacks.asm\n"

scope VanillaLv10Attacks: {
    scope Mario: {
        // Create new cpu attack behaviours
        OS.align(4)
        MARIO:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 2, 221, 400, 87, 184)
        AI.add_attack_behaviour(GRAB, 6, 146, 291, 163, 308)
        AI.add_attack_behaviour(DSPG, 2, -218, 218, 274, 386)
        AI.add_attack_behaviour(USPG, 2, 200, 500, 350, 600)
        AI.add_attack_behaviour(UTILT, 5, -71, 436, 198, 634)
        AI.add_attack_behaviour(DTILT, 5, 160, 685, -22, 114)
        AI.add_attack_behaviour(USMASH, 7, -147, 291, 275, 591)
        AI.add_attack_behaviour(FTILT, 8, 106, 561, 20, 235)
        AI.add_attack_behaviour(DSMASH, 8, 0, 556, -124, 450)
        AI.add_attack_behaviour(FSMASH, 16, 119, 576, 78, 241)
        AI.add_attack_behaviour(DSMASH, 20, -466, 0, -124, 450) // back hit
        AI.add_attack_behaviour(NSPG, 35, 1000, 1200, 50, 250)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 345, 998, 21, 155)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(UAIR, 2, 57, 436, 74, 622) // front arch
        AI.add_attack_behaviour(DSPA, 2, -218, 218, 274, 386)
        AI.add_attack_behaviour(USPA, 2, 200, 500, 350, 600)
        AI.add_attack_behaviour(NAIR, 3, -141, 151, 40, 235)
        AI.add_attack_behaviour(UAIR, 8, -229, 67, 353, 618) // back hit
        AI.add_attack_behaviour(DAIR, 10, 42, 382, -231, 176)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -407, 90, 69, 343)
        AI.add_attack_behaviour(NAIR, 3+8, -141, 151, 40, 235) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 11, 1, 352, 27, 317)
        AI.add_attack_behaviour(DAIR, 10+8, 42, 382, -231, 176) // late hit
        AI.add_attack_behaviour(NSPA, 35, 1100, 1200, -200, 0) // after some time, it hits down below and away

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.MARIO, 0x4)
        dw MARIO
        OS.patch_end()
    }

    scope Link: {
        // Create new cpu attack behaviours
        OS.align(4)
        LINK:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 6, 33, 542, 29, 324)
        AI.add_attack_behaviour(UTILT, 8, 0, 441, 200, 686) // front hit
        AI.add_attack_behaviour(USPG, 8, -701, 713, 222, 381)
        AI.add_attack_behaviour(DSMASH, 9, 400, 709, 34, 329)
        AI.add_attack_behaviour(USMASH, 11, -406, 441, 152, 846)
        AI.add_attack_behaviour(DTILT, 12, 218, 693, 9, 183)
        AI.add_attack_behaviour(UTILT, 12, -566, -50, -64, 686) // back hit
        AI.add_attack_behaviour(FTILT, 15+1, 200, 567, -74, 550)
        AI.add_attack_behaviour(FSMASH, 16, 0, 714, -7, 815)
        AI.add_attack_behaviour(GRAB, 17, 269, 1161, 170, 322)
        AI.add_attack_behaviour(DSMASH, 21, -626, -200, 34, 329) // back hit
        AI.add_attack_behaviour(NSPG, 30, 600, 2000, 0, 800) // around this min x location at this frame
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 9, 510, 1214, 133, 366)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 4, -135, 281, 78, 296)
        AI.add_attack_behaviour(DAIR, 5, -19, 157, -11, 244)
        AI.add_attack_behaviour(UAIR, 5, -106, 96, 416, 674)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -480, -71, 153, 350)
        AI.add_attack_behaviour(NAIR, 4+2, -135, 281, 78, 296) // late hit
        AI.add_attack_behaviour(USPA, 8, 159, 655, 291, 411) // frame 1
        AI.add_attack_behaviour(DAIR, 5+5, -19, 157, -11, 244) // late hit
        AI.add_attack_behaviour(UAIR, 5+5, -106, 96, 416, 674) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 15, 100, 640, 100, 512)
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 26, 100, 340, -14, 400) // second spin
        AI.add_attack_behaviour(NSPA, 30, 600, 2000, -800, 800) // around this min x location at this frame

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.LINK, 0x4)
        dw LINK
        OS.patch_end()
    }

    scope Dk: {
        // Create new cpu attack behaviours
        OS.align(4)
        DK:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(USPG, 3, -536, 473, 80, 673)
        AI.add_attack_behaviour(UTILT, 4, -112, 476, 275, 804)
        AI.add_attack_behaviour(JAB, 5, 223, 631, 64, 381)
        AI.add_attack_behaviour(GRAB, 6, 268, 611, 205, 401)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_GRAB, 6+4, 268, 611, 205, 401)
        AI.add_attack_behaviour(DTILT, 11, 242, 706, -12, 178)
        AI.add_attack_behaviour(FTILT, 12, 291, 857, 261, 441)
        AI.add_attack_behaviour(DSMASH, 12, -513, 568, -32, 200)
        AI.add_attack_behaviour(UTILT, 4+10, -800, 0, 300, 804) // back hit
        AI.add_attack_behaviour(USMASH, 16, -155, 138, 605, 866)
        AI.add_attack_behaviour(NSPG, 6+10, -491, 889, 275, 665)
        AI.add_attack_behaviour(DSPG, 17, 600, 975, 0, 100) // big minx value for him to use it from far away
        AI.add_attack_behaviour(FSMASH, 27, 275, 985, 132, 386)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 3, -90, 877, 87, 494)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(UAIR, 3, 200, 484, 339, 599) // first frame
        AI.add_attack_behaviour(USPA, 3, -580, 554, 63, 584)
        AI.add_attack_behaviour(NAIR, 4, -569, 388, 146, 641)
        AI.add_attack_behaviour(DAIR, 6, -223, 29, -212, 177)
        AI.add_attack_behaviour(UAIR, 3+3, -400, 400, 300, 947) // top hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 0, 484, -18, 904)
        AI.add_attack_behaviour(NAIR, 4+4, -569, 388, 146, 641) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8, -548, -143, 103, 336)
        AI.add_attack_behaviour(DAIR, 6+6, -223, 29, -212, 177) // late hit
        AI.add_attack_behaviour(UAIR, 3+11, -783, -200, 177, 599) // back hit
        AI.add_attack_behaviour(NSPA, 6+10, -362, 827, 280, 821)

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.DK, 0x4)
        dw DK
        OS.patch_end()
    }

    scope Fox: {
        // Create new cpu attack behaviours
        OS.align(4)
        FOX:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_custom_attack_behaviour(AI.ROUTINE.MULTI_SHINE, 1, -90, 90, 150, 330)
        AI.add_attack_behaviour(JAB, 3, 233, 542, 194, 306)
        AI.add_attack_behaviour(GRAB, 6, 265, 395, 175, 305)
        AI.add_attack_behaviour(FTILT, 6, 161, 585, 195, 325)
        AI.add_attack_behaviour(UTILT, 6, -6, 183, 242, 664)
        AI.add_attack_behaviour(DTILT, 6, 196, 695, -89, 99)
        AI.add_attack_behaviour(USMASH, 6, 158, 347, 131, 271) // first frame
        AI.add_attack_behaviour(DSMASH, 6, -401, 407, -32, 118)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_GRAB, 6+4, 265+600, 395+600, 175, 305)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_USMASH, 6+4, 158, 347, 131, 271) // first frame
        AI.add_attack_behaviour(FSMASH, 12, 351, 683, 186, 391) // strong hit only
        AI.add_attack_behaviour(NSPG, 37, 2000, 2200, 300, 400)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 284, 1113, -77, 303)
        // AI.add_attack_behaviour(USPG, 3, -536, 473, 80, 673) // no usp attack
        // we can add new grounded attacks here

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 4, -53, 270, 101, 359)
        AI.add_attack_behaviour(DAIR, 4, -55, 186, 0, 251)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4, -391, 249, 103, 343)
        AI.add_attack_behaviour(UAIR, 6, -188, 175, -73, 612)
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 6, 46, 337, 130, 372)
        AI.add_attack_behaviour(NAIR, 8, -53, 270, 101, 359) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 4+4, -391, 249, 103, 343) // late hit
        AI.add_attack_behaviour(DAIR, 4+5, -55, 186, 0, 251) // late hit
        AI.add_attack_behaviour(NSPA, 26, 2000, 2200, 300, 400)
        // AI.add_attack_behaviour(USPA, 3, -580, 554, 63, 584) // no usp attack
        // AI.add_attack_behaviour(DSPA, 44, 1000, 3000, -1000, 1000) // no air dsp
        // we can add new aerial attacks here

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.FOX, 0x4)
        dw FOX
        OS.patch_end()
    }

    scope Captain: {
        // Create new cpu attack behaviours
        OS.align(4)
        CAPTAIN:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(USMASH, 4, -22, 368, 176, 909)
        AI.add_attack_behaviour(JAB, 5, 70, 450, 323, 466)
        AI.add_attack_behaviour(GRAB, 6, 244, 394, 217, 367)
        AI.add_attack_behaviour(DTILT, 8, 0, 497, -26, 207)
        AI.add_attack_behaviour(DSMASH, 8, 0, 607, -70, 220)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_USMASH, 4+4, -22+650, 368+650, 176, 909)
        AI.add_attack_behaviour(FTILT, 9, 52, 516, 318, 467)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_GRAB, 6+4, 244+650, 394+650, 217, 367)
        AI.add_attack_behaviour(DSPG, 18, 700, 1400, 19, 269)
        AI.add_attack_behaviour(UTILT, 19, 248, 644, -25, 720) // only using front hitting part so hit area is more specific
        AI.add_attack_behaviour(DSPG, 30, 1800, 2400, 19, 269)
        AI.add_attack_behaviour(FSMASH, 16, 316, 1080, 314, 507)
        AI.add_custom_attack_behaviour(AI.ROUTINE.SMASH_DOWN, 19, -580, 0, -70, 220) // back hit
        AI.add_attack_behaviour(NSPG, 42, 249, 983, 163, 380)
        AI.add_attack_behaviour(USPG, 13, -494, 494, 199, 349) // first frame
        AI.add_attack_behaviour(USPG, 20, -466, 466, 223+100, 1020) // decreasing upwards range so he does it less often
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 373, 1213, 219, 351)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 4, -84, 241, 189, 337)
        AI.add_attack_behaviour(NAIR, 4+4, -84, 241, 189, 337) // late hit
        AI.add_attack_behaviour(UAIR, 5, 185, 472, 193, 551) // frame 1
        AI.add_custom_attack_behaviour(AI.ROUTINE.UTILT, 5+1, -59, 503, 552, 1038) // front-top arch
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, 120, 532, 164, 386) // first kick
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 7, -559, -141, 181, 473)
        AI.add_attack_behaviour(DAIR, 7, -166, 110, -68, 379)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 7+2, -559, -141, 181, 473) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.UTILT, 5+5, -539, -35, 450, 939) // back hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.DTILT, 7+5, -166, 110, -68, 379) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.DTILT, 7+10, -166, 110, -68, 379) // later hit
        AI.add_attack_behaviour(USPA, 13, -494, 494, 199, 349) // first frame
        AI.add_attack_behaviour(USPA, 20, -405, 405, 223+100, 833+200)
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 21, 132, 536, 316, 436) // second kick
        AI.add_attack_behaviour(DSPA, 25, 300, 600, -1000, -700) // added delay to compensate movement and make him do it less often
        AI.add_attack_behaviour(NSPA, 42, 23, 896, 208, 484)
        // we can add new aerial attacks here

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.FALCON, 0x4)
        dw CAPTAIN
        OS.patch_end()
    }

    scope Pikachu: {
        // Create new cpu attack behaviours
        OS.align(4)
        PIKACHU:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 2, 25, 393, -4, 172)
        AI.add_attack_behaviour(FTILT, 5, 64, 420, 77, 308)
        AI.add_attack_behaviour(UTILT, 5, -290, 0, 169, 599) // back part
        AI.add_attack_behaviour(GRAB, 6, 240, 385, 155, 300)
        AI.add_attack_behaviour(DTILT, 6, 45, 389, -1, 206)
        AI.add_attack_behaviour(UTILT, 11, 0, 297, 169, 599) // front hit
        AI.add_attack_behaviour(USMASH, 10, 0, 350, 116, 608)
        AI.add_attack_behaviour(DSMASH, 10, 0, 370, -6, 293) // back hit
        AI.add_attack_behaviour(FSMASH, 21, 130, 793, 15, 175)
        AI.add_attack_behaviour(DSMASH, 25, -408, 0, -6, 293) // back hit
        // AI.add_attack_behaviour(NSPG, 42, 249, 983, 163, 380)
        AI.add_attack_behaviour(DSPG, 23+19, -175, 175, 110, 460)
        AI.add_attack_behaviour(DSPG, 23+15, -200, 200, 1200, 3000) // thunder coming down
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 125, 1040, -25, 353)
        // we can add new grounded attacks here

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 3, -187, 148, 92, 313)
        AI.add_attack_behaviour(UAIR, 3, -460, 0, 100, 659)
        AI.add_attack_behaviour(UAIR, 3+3, 0, 435, 41, 659)
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, -149, 362, 32, 352)
        AI.add_attack_behaviour(DAIR, 8, -201, 104, -184, 317)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -464, -12, 99, 310)
        AI.add_attack_behaviour(NAIR, 3+8, -187, 148, 92, 313) // late hit
        AI.add_attack_behaviour(DAIR, 8+5, -201, 104, -184, 317) // late hit
        AI.add_attack_behaviour(NSPA, 40, 600-300, 600+100, -600-100, -600+300) // after some time, it hits down below and away
        AI.add_attack_behaviour(NSPA, 60, 1200-300, 1200+100, -1200-100, -1200+300) // after some time, it hits down below and away
        AI.add_attack_behaviour(DSPA, 23+19, -175, 175, 110, 460)
        AI.add_attack_behaviour(DSPA, 23+15, -200, 200, 1200, 3000) // thunder coming down
        // we can add new aerial attacks here

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.PIKACHU, 0x4)
        dw PIKACHU
        OS.patch_end()
    }

    scope Samus: {
        // Create new cpu attack behaviours
        OS.align(4)
        SAMUS:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 4, 214, 610, 283, 404)
        AI.add_attack_behaviour(USPG, 4, -180, 300, -80, 600) // frame 1
        AI.add_attack_behaviour(FTILT, 7, 34, 490, 246, 427)
        AI.add_attack_behaviour(DTILT, 8, 209, 603, -13, 144)
        AI.add_attack_behaviour(DSMASH, 8, 0, 486, -33, 217)
        AI.add_attack_behaviour(DSPG, 8, -100, 100, 0, 300)
        AI.add_attack_behaviour(FSMASH, 12, 104, 608, 257, 398)
        AI.add_attack_behaviour(UTILT, 15, -309, 0, 500, 844)
        AI.add_attack_behaviour(USMASH, 17, -452, 351, 600, 865)
        AI.add_attack_behaviour(DSMASH, 19, -465, 0, -33, 217)
        AI.add_attack_behaviour(GRAB, 20, 113, 1225, 188, 297)
        AI.add_attack_behaviour(UTILT, 25, 0, 528, 70, 700)
        AI.add_attack_behaviour(NSPG, 15+20, 1000, 1200, 300, 400)
        AI.add_attack_behaviour(USPG, 14, -100, 415, 700, 1800) // reached top
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 370, 1164, 210, 339)
        // we can add new grounded attacks here

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 4, -69, 238, 181, 418)
        AI.add_attack_behaviour(DAIR, 4, -383, 358, -197, 485)
        AI.add_attack_behaviour(USPA, 4, -180, 300, -30, 600) // frame 1
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 5, 300, 517, 13, 641)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 5, -382, 20, 31, 400)
        AI.add_attack_behaviour(UAIR, 6, -85, 256, 257, 613)
        AI.add_attack_behaviour(NAIR, 4+4, -69, 238, 181, 418) // late hit
        AI.add_attack_behaviour(DSPA, 10, -100, 100, 0, 300)
        AI.add_attack_behaviour(NSPA, 15+20, 1000, 1200, 300, 400)
        AI.add_attack_behaviour(DSPA, 50, -100, 100, -300, 0)
        AI.add_attack_behaviour(USPA, 18, -100, 415, 700, 1200) // reached top
        // we can add new aerial attacks here

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.SAMUS, 0x4)
        dw SAMUS
        OS.patch_end()
    }

    scope Jigglypuff: {
        // Create new cpu attack behaviours
        OS.align(4)
        JIGGLYPUFF:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(DSPG, 1, -65, 65, 93, 223)
        AI.add_attack_behaviour(JAB, 5, 154, 452, 101, 217)
        AI.add_attack_behaviour(GRAB, 6, 247, 490, 192, 312)
        AI.add_attack_behaviour(UTILT, 7, -396, 163, 170, 686)
        AI.add_attack_behaviour(FTILT, 7, 105, 473, 139, 279)
        AI.add_attack_behaviour(DSMASH, 7, -568, 563, -37, 181)
        AI.add_attack_behaviour(USMASH, 8, -248, 342, 42, 457)
        AI.add_attack_behaviour(DTILT, 11, 80, 562, 73, 205)
        AI.add_attack_behaviour(FSMASH, 12, 378, 1047, 99, 270)
        AI.add_attack_behaviour(NSPG, 16, -179, 730, -41, 258)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 460, 1125, 93, 223)
        // AI.add_attack_behaviour(USPG, 28, -228, 257, 13, 471)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(DSPA, 1, -65, 65, 93, 223)
        AI.add_attack_behaviour(DAIR, 4, -27, 195, -216, 90)
        AI.add_attack_behaviour(NAIR, 6, -55, 401, -17, 185)
        AI.add_attack_behaviour(NAIR, 6+4, -55, 401, -17, 185) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 38, 286, 90, 225)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8, -286, 90, 47, 212)
        AI.add_attack_behaviour(DAIR, 4+4, -27, 195, -216, 90) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8+4, 38, 286, 90, 225) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8+4, -286, 90, 47, 212) // late hit
        AI.add_attack_behaviour(UAIR, 8, -179, 232, 181, 450)
        AI.add_attack_behaviour(NSPA, 16, -125, 848, -130, 117)
        // AI.add_attack_behaviour(USPA, 28, -228, 257, 13, 471)

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.JIGGLYPUFF, 0x4)
        dw JIGGLYPUFF
        OS.patch_end()
    }

    scope Luigi: {
        // Create new cpu attack behaviours
        OS.align(4)
        LUIGI:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(USPG, 2, 39, 332, -5, 226)
        AI.add_attack_behaviour(JAB, 2, 246, 424, 110, 211)
        AI.add_attack_behaviour(GRAB, 6, 146, 291, 163, 308)
        AI.add_attack_behaviour(DSPG, 1, -203, 203, 89, 371)
        AI.add_attack_behaviour(DTILT, 3, 8, 373, -24, 115)
        AI.add_attack_behaviour(UTILT, 5, -62, 452, 231, 669)
        AI.add_attack_behaviour(USMASH, 7, -198, 334, 297, 678)
        AI.add_attack_behaviour(FTILT, 8, 106, 545, 27, 230)
        AI.add_attack_behaviour(DSMASH, 8, 0, 556, -124, 450)
        AI.add_attack_behaviour(FSMASH, 16, 138, 595, 80, 267)
        AI.add_attack_behaviour(DSMASH, 20, -466, 0, -124, 450) // back hit
        AI.add_attack_behaviour(NSPG, 41, 1000, 1200, 150, 400)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 3, 231, 1257, 172, 398)

        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(DSPA, 1, -203, 203, 89, 371)
        AI.add_attack_behaviour(USPA, 2, 39, 332, -6, 225)
        AI.add_attack_behaviour(UAIR, 2, 57, 436, 74, 622)
        AI.add_attack_behaviour(NAIR, 3, -141, 151, 40, 233)
        AI.add_attack_behaviour(UAIR, 8, -229, 67, 353, 618) // back hit
        AI.add_attack_behaviour(DAIR, 10, 42, 382, -231, 176)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -407, 90, 69, 343)
        AI.add_attack_behaviour(NAIR, 3+8, -141, 151, 40, 233) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 11, 1, 352, 27, 317)
        AI.add_attack_behaviour(DAIR, 10+8, 42, 382, -231, 176) // late hit
        AI.add_attack_behaviour(NSPA, 41, 1000, 1200, 150, 400)

        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.LUIGI, 0x4)
        dw LUIGI
        OS.patch_end()
    }

    scope Yoshi: {
        // Create new cpu attack behaviours
        OS.align(4)
        YOSHI:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 3, 86, 561, 5, 377)
        AI.add_attack_behaviour(DSMASH, 6, 309, 620, -2, 165)
        AI.add_attack_behaviour(UTILT, 7, -146, 340, 164, 612)
        AI.add_attack_behaviour(FTILT, 8, 185, 580, 128, 321)
        AI.add_attack_behaviour(DTILT, 8, 186, 595, 13, 195)
        AI.add_attack_behaviour(USMASH, 9, -301, 346, 281, 817)
        AI.add_attack_behaviour(GRAB, 15, 346, 923, 93, 210)
        AI.add_attack_behaviour(FSMASH, 18, 204, 714, 79, 331)
        AI.add_attack_behaviour(NSPG, 18, 299, 989, 183, 336)
        AI.add_attack_behaviour(DSMASH, 21, -567, -300, -2, 165) // back hit
        AI.add_attack_behaviour(DSPG, 35, -115+920, 115+920, 61, 291+600)
        AI.add_attack_behaviour(USPG, 56, 600, 2000, 100, 2000)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 9, 386, 1474, 128, 268)
        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 5, -126, 198, 80, 293)
        AI.add_attack_behaviour(DAIR, 4, -129, 179, 22, 369)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -495, 88, 119, 344)
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 11, 16, 494, -46, 581)
        AI.add_attack_behaviour(UAIR, 9, -86, 102, 387, 734)
        AI.add_attack_behaviour(NAIR, 5+4, -126, 198, 80, 293) // late hit
        AI.add_attack_behaviour(DAIR, 4+4, -129, 179, 22, 369) // late hit
        AI.add_attack_behaviour(NSPA, 18, 299, 989, 183, 336)
        AI.add_attack_behaviour(DSPA, 24+2, -115, 115, 61-600, 291)
        // AI.add_attack_behaviour(USPA, 56, 600, 2000, 100, 2000)
        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.YOSHI, 0x4)
        dw YOSHI
        OS.patch_end()
    }

    scope Ness: {
        // Create new cpu attack behaviours
        OS.align(4)
        NESS:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 2, 191, 363, 75, 173)
        AI.add_attack_behaviour(DTILT, 4, 35, 380, -67, 102)
        AI.add_attack_behaviour(UTILT, 5, -160, 160, 307, 572)
        AI.add_attack_behaviour(GRAB, 6, 127, 282, 174, 329)
        AI.add_attack_behaviour(FTILT, 7, 267, 526, 122, 242)
        AI.add_attack_behaviour(UTILT, 5+4, -160, 160, 307, 572) // late hit
        AI.add_attack_behaviour(USMASH, 13, -50, 492, 58, 679) // front hit
        AI.add_attack_behaviour(DSMASH, 13, -632, 823, 22, 241) // back hit
        AI.add_attack_behaviour(FSMASH, 18, 125, 541, 10, 237)
        AI.add_attack_behaviour(USMASH, 19, -301, 50, 281, 817) // back hit
        AI.add_attack_behaviour(DSMASH, 27, -632, 823, 22, 241) // front hit
        AI.add_attack_behaviour(NSPG, 28, 600, 1500, 100, 300)
        AI.add_attack_behaviour(USPG, 40, 2000, 3000, -2000, 2000)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 8, 405, 1097, 77, 217)
        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(DAIR, 4, -49, 112, -112, 49)
        AI.add_attack_behaviour(NAIR, 5, -102, 160, -46, 129)
        AI.add_attack_behaviour(UAIR, 8, -232, 274, 69, 419)
        AI.add_attack_behaviour(DAIR, 4+4, -49, 112, -112, 49) // late hit
        AI.add_attack_behaviour(NAIR, 5+4, -102, 160, -46, 129) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 10, 112, 267, 69, 225)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 10, -385, 88, -32, 229)
        AI.add_attack_behaviour(NSPA, 28, 600, 1500, -800, -100)
        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.NESS, 0x4)
        dw NESS
        OS.patch_end()
    }

    scope Kirby: {
        // Create new cpu attack behaviours
        OS.align(4)
        KIRBY:
        // grounded attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(JAB, 3, 155, 432, 83, 197)
        AI.add_attack_behaviour(UTILT, 4, -435, 185, 132, 701)
        AI.add_attack_behaviour(DTILT, 4, 163, 639, -31, 155)
        AI.add_attack_behaviour(FTILT, 4, 52, 508, 85, 310)
        AI.add_attack_behaviour(GRAB, 6, 208, 447, 153, 283)
        AI.add_attack_behaviour(DSMASH, 7, -473, 480, -69, 129)
        AI.add_attack_behaviour(FSMASH, 10, 275, 1023, 59, 256)
        AI.add_attack_behaviour(USMASH, 14, -61, 390, 250, 776) // sweetspot part only
        AI.add_attack_behaviour(NSPG, 20, 110, 463, 128, 308)
        AI.add_attack_behaviour(USPG, 23, 145, 520, 88, 436)
        AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 5, 390, 984, 72, 202)
        AI.END_ATTACKS() // end of grounded attacks

        // aerial attacks
        // add_attack_behaviour(table, attack, hitbox_start_frame, min_x, max_x, min_y, max_y)
        AI.add_attack_behaviour(NAIR, 3, -55, 350, 22, 169)
        AI.add_attack_behaviour(DAIR, 4, -35, 186, -204, 90)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6, -313, -1, 42, 232)
        AI.add_attack_behaviour(NAIR, 3+4, -55, 350, 22, 169) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 1, 295, 42, 232)
        AI.add_attack_behaviour(DAIR, 4+4, -35, 186, -204, 90) // late hit
        AI.add_attack_behaviour(UAIR, 10, -69, 69, 67, 206)
        AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 6+4, -313, -1, 42, 232) // late hit
        AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8+4, 1, 295, 42, 232) // late hit
        AI.add_attack_behaviour(UAIR, 10+4, -69, 69, 67, 206) // late hit
        AI.add_attack_behaviour(NSPA, 20, 110, 463, 128, 308)
        AI.add_attack_behaviour(DSPA, 23+2, -100, 100, -1000, 100)
        AI.END_ATTACKS() // end of aerial attacks
        OS.align(16)
        // Set CPU behaviour
        Character.table_patch_start(lv10_ai_behaviour, Character.id.KIRBY, 0x4)
        dw KIRBY
        OS.patch_end()
    }
}