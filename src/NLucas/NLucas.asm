// NLucas.asm

// This file contains file inclusions, action edits, and assembly for Polygon Lucas.

scope NLucas {
    // Insert Moveset files

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NLUCAS, Action.Jab1,            File.LUCAS_JAB1,            Lucas.JAB1,                       0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.Jab2,            File.LUCAS_JAB2,            Lucas.JAB2,                       0x00000000)
    Character.edit_action_parameters(NLUCAS, 0xDC,                   File.LUCAS_JAB3,            Lucas.JAB3,                       0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.AttackAirN,      File.LUCAS_NAIR,            Lucas.NAIR,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.AttackAirF,      File.LUCAS_FAIR,            Lucas.FAIR,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.AttackAirB,      File.LUCAS_BAIR,            Lucas.BAIR,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.AttackAirU,      File.LUCAS_UAIR,            Lucas.UAIR,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.AttackAirD,      File.LUCAS_DAIR,            Lucas.DAIR,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.FTilt,           File.LUCAS_FTILT_MID,       Lucas.FTILT_MID,                  0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.FTiltHigh,       File.LUCAS_FTILT_HIGH,      Lucas.FTILT_HIGH,                 0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.FTiltLow,        File.LUCAS_FTILT_LOW,       Lucas.FTILT_LOW,                  0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.UTilt,           File.LUCAS_UTILT,           Lucas.UTILT,                      -1)
    Character.edit_action_parameters(NLUCAS, Action.DTilt,           File.LUCAS_DTILT,           Lucas.DTILT,                         -0x80000000)
    Character.edit_action_parameters(NLUCAS, Action.USmash,          File.LUCAS_USMASH,          Lucas.USMASH,                     0x80000000)
    Character.edit_action_parameters(NLUCAS, Action.DSmash,          File.LUCAS_DSMASH,          Lucas.DSMASH,                     0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.Grab,            File.LUCAS_GRAB,            Lucas.GRAB,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.GrabPull,        File.LUCAS_GRAB_PULL,       Lucas.GRAB_PULL,                  -1)
    Character.edit_action_parameters(NLUCAS, Action.ThrowF,          File.LUCAS_FTHROW,          Lucas.FTHROW,                     -1)
    Character.edit_action_parameters(NLUCAS, Action.FSmash,          -1,                         Lucas.FSMASH,                     -1)
    Character.edit_action_parameters(NLUCAS, Action.DashAttack,      File.LUCAS_DASHATTACK,      Lucas.DASHATTACK,                 -1)
    Character.edit_action_parameters(NLUCAS, Action.JumpF,           -1,          		Lucas.JUMP1,                         -1)
    Character.edit_action_parameters(NLUCAS, Action.JumpB,           -1,          		Lucas.JUMP1,                         -1)
    Character.edit_action_parameters(NLUCAS, Action.Taunt,           File.LUCAS_TAUNT,           Lucas.TAUNT,                      0x00000000)
    Character.edit_action_parameters(NLUCAS, Action.CliffAttackQuick2, -1,                       Lucas.EDGE_ATTACK_F,              -1)
    Character.edit_action_parameters(NLUCAS, Action.CliffAttackSlow2, -1,                        Lucas.EDGE_ATTACK_S,              -1)
    Character.edit_action_parameters(NLUCAS, Action.Stun,            -1,                         Lucas.STUN_LOOP,                  -1)
    Character.edit_action_parameters(NLUCAS, Action.TechF,            -1,                        Lucas.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NLUCAS, Action.TechB,            -1,                        Lucas.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NLUCAS, Action.Tech,             -1,                        Lucas.TECH,                       -1)
    Character.edit_action_parameters(NLUCAS, Action.ShieldBreak,      -1,                        Lucas.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NLUCAS, Action.Sleep,            -1,                        Lucas.ASLEEP,                     -1)
    Character.edit_action_parameters(NLUCAS, Action.Teeter,           -1,                        Lucas.TEETER,                     -1)
    Character.edit_action_parameters(NLUCAS, Action.JumpAerialF,        -1,             Lucas.JUMP2,                      -1)
    Character.edit_action_parameters(NLUCAS, Action.JumpAerialB,        -1,                             Lucas.JUMP2,                      -1)


    Character.edit_action_parameters(NLUCAS, 0xE2,                   File.LUCAS_PKFIREGROUNDANI, Lucas.PKFIREGROUND,               0x40000000)
    Character.edit_action_parameters(NLUCAS, 0xE3,                   File.LUCAS_PKFIREAIRANI,    Lucas.PKFIREAIR,                  -1)
    Character.edit_action_parameters(NLUCAS, 0xED,                   File.LUCAS_MAGNETSTARTGR,   Lucas.DOWN_SPECIAL_INITIATE,      -1)
    Character.edit_action_parameters(NLUCAS, 0xEE,                   File.LUCAS_MAGNETHOLDGR,    Lucas.DOWN_SPECIAL_WAIT,          -1)
	Character.edit_action_parameters(NLUCAS, 0xEF,                   File.LUCAS_MAGNETHOLDGR,    Lucas.DOWN_SPECIAL_ABSORB,        -1)
    Character.edit_action_parameters(NLUCAS, 0xF0,                   File.LUCAS_MAGNETRELEASEGR, Lucas.DOWN_SPECIAL_END,           -1)
    Character.edit_action_parameters(NLUCAS, 0xF1,                   File.LUCAS_MAGNETSTARTAIR,  Lucas.DOWN_SPECIAL_INITIATE,      -1)
    Character.edit_action_parameters(NLUCAS, 0xF2,                   File.LUCAS_MAGNETHOLDAIR,   Lucas.DOWN_SPECIAL_WAIT,          -1)
	Character.edit_action_parameters(NLUCAS, 0xF3,                   File.LUCAS_MAGNETHOLDAIR,   Lucas.DOWN_SPECIAL_ABSORB,        -1)
    Character.edit_action_parameters(NLUCAS, 0xF4,                   File.LUCAS_MAGNETRELEASEAIR, Lucas.DOWN_SPECIAL_END,          -1)
    Character.edit_action_parameters(NLUCAS, Action.FallSpecial,     File.LUCAS_SFALL,           -1,                         -1)
    Character.edit_action_parameters(NLUCAS, 0xE4,                   File.LUCAS_PKTHUNDERSTARTGR, Lucas.UP_SPECIAL_INTIATE,        -1)
    Character.edit_action_parameters(NLUCAS, 0xE5,                   File.LUCAS_PKTHUNDERHOLDGR, -1,                         -1)
    Character.edit_action_parameters(NLUCAS, 0xE6,                   File.LUCAS_PKTHUNDERRELEASEGR, -1,                      -1)
    Character.edit_action_parameters(NLUCAS, 0xE8,                   File.LUCAS_PKTHUNDERSTARTAIR, Lucas.UP_SPECIAL_INTIATE,       -1)
    Character.edit_action_parameters(NLUCAS, 0xE9,                   File.LUCAS_PKTHUNDERHOLDAIR, -1,                        -1)
    Character.edit_action_parameters(NLUCAS, 0xEA,                   File.LUCAS_PKTHUNDERRELEASEAIR, -1,                     -1)
    Character.edit_action_parameters(NLUCAS, 0xEC,                   File.LUCAS_PKTHUNDER2,      Lucas.UP_SPECIAL_2,               -1)
    Character.edit_action_parameters(NLUCAS, 0xE7,                   File.LUCAS_PKTHUNDER2,      Lucas.UP_SPECIAL_2,               -1)
    Character.edit_action_parameters(NLUCAS, 0xDD,                   0x680,         0x80000000,                      0x00000000)
    Character.edit_action_parameters(NLUCAS, 0xDE,                   0x680,         0x80000000,                      0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NLUCAS, 0xE2,              -1,             -1,                         -1,                             0x800D8CCC,                       -1)
    Character.edit_action(NLUCAS, 0xE3,              -1,             -1,                         LucasNSP.air_move_,             -1,                               -1)
    Character.edit_action(NLUCAS, 0xF1,              -1,             -1,                         -1,                             -1,                             0x800DE99C)
    Character.edit_action(NLUCAS, 0xF2,              -1,             -1,                         -1,                             -1,                             0x800DE99C)
    Character.edit_action(NLUCAS, 0xDD,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NLUCAS, 0xDE,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NLUCAS, 0x2,               File.LUCAS_SELECTED,        Lucas.SELECTED,                           -1)
	Character.edit_menu_action_parameters(NLUCAS, 0xD,               File.LUCAS_1P,        		 Lucas.ONEP,                               -1)
    Character.edit_menu_action_parameters(NLUCAS, 0xE,               File.LUCAS_1P_CPU_POSE,     0x80000000,                         -1)
	Character.edit_menu_action_parameters(NLUCAS, 0x1,               File.LUCAS_NEEDLE_ANIM,     Lucas.NEEDLE,                             0x10000000)
	Character.edit_menu_action_parameters(NLUCAS, 0x3,               File.LUCAS_PKVICTORY,       Lucas.PKVICTORY,                          -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NLUCAS, 0x2)
    dh  0x0338
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NLUCAS, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove gfx routine ending script.
    Character.table_patch_start(gfx_routine_end, Character.id.NLUCAS, 0x4)
    dw  0x800E9A60                          // skips overlay ending script
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.NLUCAS, 0xC)
    dh 0x08
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.NLUCAS, 0, 1, 4, 5, 1, 3, 2)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NLUCAS, 0x4)
    dw      Lucas.CPU_ATTACKS
    OS.patch_end()

    // Shield colors for costume matching
    Character.set_costume_shield_colors(NLUCAS, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)

    // @ Description
    // Polygon Lucas's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        //constant Appear1(0x0DF)
        //constant Appear2(0x0E0)
        //constant AppearEnd(0x0E1)
        constant PKFire(0x0E2)
        constant PKFireAir(0x0E3)
        constant PKThunderStart1(0x0E4)
        constant PKThunderStart2(0x0E5)
        constant PKThunderEnd(0x0E6)
        constant PKTA(0x0E7)
        constant PKThunderStartAir(0x0E8)
        constant PKThunderAir(0x0E9)
        constant PKThunderEndAir(0x0EA)
        constant ClashingPKTA(0x0EB)
        constant PKTAAir(0x0EC)
        constant PsiMagnetStart(0x0ED)
        constant PsiMagnet(0x0EE)
        constant Healing(0x0EF)
        constant PsiMagnetEnd(0x0F0)
        constant PsiMagnetStartAir(0x0F1)
        constant PsiMagnetAir(0x0F2)
        constant HealingAir(0x0F3)
        constant PsiMagnetEndAir(0x0F4)

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0 //dw string_0x0DF
        dw 0 //dw string_0x0E0
        dw 0 //dw string_0x0E1
        dw Action.NESS.string_0x0E2
        dw Action.NESS.string_0x0E3
        dw Action.NESS.string_0x0E4
        dw Action.NESS.string_0x0E5
        dw Action.NESS.string_0x0E6
        dw Action.NESS.string_0x0E7
        dw Action.NESS.string_0x0E8
        dw Action.NESS.string_0x0E9
        dw Action.NESS.string_0x0EA
        dw Action.NESS.string_0x0EB
        dw Action.NESS.string_0x0EC
        dw Action.NESS.string_0x0ED
        dw Action.NESS.string_0x0EE
        dw Action.NESS.string_0x0EF
        dw Action.NESS.string_0x0F0
        dw Action.NESS.string_0x0F1
        dw Action.NESS.string_0x0F2
        dw Action.NESS.string_0x0F3
        dw Action.NESS.string_0x0F4
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NLUCAS, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

}
