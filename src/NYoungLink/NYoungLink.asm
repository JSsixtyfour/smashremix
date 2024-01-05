// YoungLink.asm

// This file contains file inclusions, action edits, and assembly for Young Link.

scope NYoungLink {
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NYLINK, Action.JumpF,            -1,                        YoungLink.JUMP,                       -1)
    Character.edit_action_parameters(NYLINK, Action.JumpB,            -1,                        YoungLink.JUMP,                       -1)
    Character.edit_action_parameters(NYLINK, Action.JumpAerialF,      -1,                        YoungLink.JUMP2,                      -1)
    Character.edit_action_parameters(NYLINK, Action.JumpAerialB,      -1,                        YoungLink.JUMP2,                      -1)
    Character.edit_action_parameters(NYLINK, Action.Tech,             -1,                        YoungLink.TECHSTAND,                  -1)
    Character.edit_action_parameters(NYLINK, Action.CliffAttackQuick2,-1,                        YoungLink.EDGEATTACKF,                -1)
    Character.edit_action_parameters(NYLINK, Action.CliffAttackSlow2, -1,                        YoungLink.EDGEATTACKS,                -1)
    Character.edit_action_parameters(NYLINK, Action.Stun,             -1,                        YoungLink.STUN,                       -1)
    Character.edit_action_parameters(NYLINK, Action.Sleep,            -1,                        YoungLink.ASLEEP,                     -1)
    Character.edit_action_parameters(NYLINK, Action.Grab,             -1,                        YoungLink.GRAB,                       -1)
    Character.edit_action_parameters(NYLINK, Action.Grab,            File.YLINK_GRAB,           YoungLink.GRAB,                       0x10000000)
    Character.edit_action_parameters(NYLINK, Action.GrabPull,        File.YLINK_GRAB_PULL,      YoungLink.GRAB_PULL,                  0x10000000)
    Character.edit_action_parameters(NYLINK, Action.Teeter,           -1,                        YoungLink.TEETERING,                  -1)
    Character.edit_action_parameters(NYLINK, Action.Taunt,           File.YLINK_TAUNT,          YoungLink.TAUNT,                      -1)
    Character.edit_action_parameters(NYLINK, Action.Jab1,            -1,                         YoungLink.JAB_1,                      -1)
    Character.edit_action_parameters(NYLINK, Action.Jab2,            -1,                         YoungLink.JAB_2,                      -1)
    Character.edit_action_parameters(NYLINK, Action.DashAttack,      0x4B2,                      YoungLink.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NYLINK, Action.FTilt,           -1,                         YoungLink.FTILT,                      -1)
    Character.edit_action_parameters(NYLINK, Action.UTilt,           -1,                         YoungLink.UTILT,                      -1)
    Character.edit_action_parameters(NYLINK, Action.DTilt,           -1,                         YoungLink.DTILT,                      -1)
    Character.edit_action_parameters(NYLINK, Action.FSmash,          -1,                         YoungLink.FSMASH,                     -1)
    Character.edit_action_parameters(NYLINK, Action.USmash,          File.YLINK_USMASH,         YoungLink.USMASH,                     -1)
    Character.edit_action_parameters(NYLINK, Action.DSmash,          -1,                         YoungLink.DSMASH,                     -1)
    Character.edit_action_parameters(NYLINK, Action.AttackAirN,      -1,                         YoungLink.NAIR,                       -1)
    Character.edit_action_parameters(NYLINK, Action.AttackAirF,      -1,                         YoungLink.FAIR,                       -1)
    Character.edit_action_parameters(NYLINK, Action.AttackAirB,      -1,                         YoungLink.BAIR,                       -1)
    Character.edit_action_parameters(NYLINK, Action.AttackAirU,      -1,                         YoungLink.UAIR,                       -1)
    Character.edit_action_parameters(NYLINK, Action.AttackAirD,      -1,                         YoungLink.DAIR,                       -1)
    Character.edit_action_parameters(NYLINK, 0xDC,                   -1,                         YoungLink.JAB_3,                      -1)
    Character.edit_action_parameters(NYLINK, 0xE5,                   -1,                         YoungLink.NSP,                        -1)
    Character.edit_action_parameters(NYLINK, 0xE8,                   -1,                         YoungLink.NSP,                        -1)
    Character.edit_action_parameters(NYLINK, 0xE0,                   0x45B,                         0x80000000,                      0x00000000)
    Character.edit_action_parameters(NYLINK, 0xE1,                   0x45B,                         0x80000000,                      0x00000000)
    Character.edit_action_parameters(NYLINK, 0xE2,                   -1,                         YoungLink.USP_GROUND,                 -1)
    Character.edit_action_parameters(NYLINK, 0xE3,                   -1,                         YoungLink.USP_GROUND_END,             -1)
    Character.edit_action_parameters(NYLINK, 0xE4,                   -1,                         YoungLink.USP_AIR,                    -1)
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                     // Interrupt/Other ASM              // Movement/Physics ASM         // Collision ASM    
    Character.edit_action(NYLINK, 0xE0,              -1,              0x8013D994,                   0x00000000,                         0x00000000,                     0x00000000)
    Character.edit_action(NYLINK, 0xE1,              -1,              0x8013D994,                   0x00000000,                         0x00000000,                     0x00000000)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NYLINK, 0x1,               File.YL_VICTORY,            YoungLink.VICTORY_POSE_1,             -1)
    Character.edit_menu_action_parameters(NYLINK, 0x2,               -1,                         YoungLink.VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(NYLINK, 0x5,               -1,                         0x80000000,                           -1)
    Character.edit_menu_action_parameters(NYLINK, 0xD,               -1,                         YoungLink.POSE_1P,                    -1)
    Character.edit_menu_action_parameters(NYLINK, 0xE,               File.YLINK_1P_CPU_POSE,     0x80000000,                 -1)

    // @ Description
    // Polygon Young Link's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant JabLoopStart(0x0DD)
        constant JabLoop(0x0DE)
        constant JabLoopEnd(0x0DF)
        constant Appear1(0x0E0)
        constant Appear2(0x0E1)
        constant UpSpecial(0x0E2)
        constant UpSpecialEnd(0x0E3)
        constant UpSpecialAir(0x0E4)
        constant Boomerang(0x0E5)
        constant BoomerangCatch(0x0E6)
        constant BoomerangMiss(0x0E7)
        constant BoomerangAir(0x0E8)
        constant BoomerangCatchAir(0x0E9)
        constant BoomerangMissAir(0x0EA)
        constant Bomb(0x0EB)
        constant BombAir(0x0EC)
    }
    
    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NYLINK, 0x4)
    float32 1.05
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NYLINK, 0x4)
    dw  YoungLink.Action.action_string_table
    OS.patch_end()
    
    // Handles common things for Polygons
    Character.polygon_setup(NYLINK, YLINK)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NYLINK, 0x4)
    dw      YoungLink.CPU_ATTACKS
    OS.patch_end()
}
