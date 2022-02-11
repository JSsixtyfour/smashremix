// Sandbag.asm

// This file contains file inclusions, action edits, and assembly for Sheik.

scope Sandbag {
    // Insert Moveset files


    // Modify Action Parameters             // Action                       // Animation                        // Moveset Data             // Flags
    Character.edit_action_parameters(SANDBAG, Action.DeadU,                   File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.ScreenKO,                File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Entry,                   File.SANDBAG_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, 0x006,                          File.SANDBAG_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Revive1,                 File.SANDBAG_DOWN_BOUNCE_D,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Revive2,                 File.SANDBAG_DOWN_STAND_D,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.ReviveWait,              File.SANDBAG_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Idle,                    File.SANDBAG_IDLE,                    0x800000000,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Fall,                    File.SANDBAG_FALL,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.FallAerial,              File.SANDBAG_FALL,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Teeter,                  File.SANDBAG_IDLE,                    0x800000000,                -1)
    Character.edit_action_parameters(SANDBAG, Action.TeeterStart,             File.SANDBAG_IDLE,                    0x800000000,                -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageHigh1,             File.SANDBAG_DAMAGE_HIGH_1,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageHigh2,             File.SANDBAG_DAMAGE_HIGH_2,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageHigh3,             File.SANDBAG_DAMAGE_HIGH_3,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageMid1,              File.SANDBAG_DAMAGE_MID_1,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageMid2,              File.SANDBAG_DAMAGE_MID_2,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageMid3,              File.SANDBAG_DAMAGE_MID_3,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageLow1,              File.SANDBAG_DAMAGE_LOW_1,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageLow2,              File.SANDBAG_DAMAGE_LOW_2,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageLow3,              File.SANDBAG_DAMAGE_LOW_3,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageAir1,              File.SANDBAG_DAMAGE_AIR_1,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageAir2,              File.SANDBAG_DAMAGE_AIR_2,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageAir3,              File.SANDBAG_DAMAGE_AIR_3,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageElec1,             File.SANDBAG_DAMAGE_LOW_2,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageElec2,             File.SANDBAG_DAMAGE_LOW_2,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageFlyHigh,           File.SANDBAG_DAMAGE_FLY_HIGH,         -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageFlyMid,            File.SANDBAG_DAMAGE_FLY_MID,          -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageFlyLow,            File.SANDBAG_DAMAGE_FLY_LOW,          -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageFlyTop,            File.SANDBAG_DAMAGE_FLY_TOP,          -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DamageFlyRoll,           File.SANDBAG_DAMAGE_FLY_ROLL,         -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.WallBounce,              File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Tumble,                  File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.Tornado,                 File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DownBounceD,             File.SANDBAG_DOWN_BOUNCE_D,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DownBounceU,             File.SANDBAG_DOWN_BOUNCE_U,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DownStandD,              File.SANDBAG_DOWN_STAND_D,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.DownStandU,              File.SANDBAG_DOWN_STAND_U,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.ShieldBreak,             File.SANDBAG_DAMAGE_FLY_TOP,          -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.ShieldBreakFall,         File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.StunLandD,               File.SANDBAG_DOWN_BOUNCE_D,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.StunLandU,               File.SANDBAG_DOWN_BOUNCE_U,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.StunStartD,              File.SANDBAG_DOWN_STAND_D,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.StunStartU,              File.SANDBAG_DOWN_STAND_U,            -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.CapturePulled,           File.SANDBAG_CAPTURED,                -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.InhalePulled,            File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.InhaleSpat,              File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.InhaleCopied,            File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.EggLayPulled,            File.SANDBAG_CAPTURED,                -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.EggLay,                  File.SANDBAG_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.FalconDivePulled,        File.SANDBAG_DAMAGE_HIGH_3,           -1,                         -1)
    Character.edit_action_parameters(SANDBAG, 0x0B4,                          File.SANDBAG_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(SANDBAG, Action.JumpF,                   -1,                                   0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.JumpB,                   -1,                                   0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.JumpAerialF,             -1,                                   0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.JumpAerialB,             -1,                                   0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Sleep,                   File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Stun,                    File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Walk1,                   File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Walk2,                   File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Walk3,                   File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Dash,                    File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, Action.Run,                     File.SANDBAG_IDLE,                    0x80000000,                 -1)
    Character.edit_action_parameters(SANDBAG, 0xE0,                           File.SANDBAG_HEADSTAND,               0x80000000,                 0x00000000)
    Character.edit_action_parameters(SANDBAG, Action.Taunt,                   -1,                                   0x80000000,                 -1)

    // Modify Actions            // Action              // Staling ID    // Main ASM          // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    Character.edit_action(SANDBAG, 0xE0,                0x01,            0x00000000,          0x8013E070,                     0x800D8BB4,                     0x800DDEE8)

    // Modify Menu Action Parameters             // Action      // Animation                // Moveset Data             // Flags

    Character.edit_menu_action_parameters(SANDBAG, 0x0,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x1,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x2,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x3,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x4,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x5,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0x9,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0xA,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0xD,           File.SANDBAG_IDLE,       0x80000000,                   -1)
    Character.edit_menu_action_parameters(SANDBAG, 0xE,           File.SANDBAG_IDLE,       0x80000000,                   -1)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(SANDBAG, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, NA, NA)

    // @ Description
    // Sandbag's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        //constant JabLoopStart(0x0DD)
        //constant JabLoop(0x0DE)
        //constant JabLoopEnd(0x0DF)
        constant HeadStand(0x0E0)
        //constant AppearAir(0x0E1)
        //constant BlueFalcon1(0x0E2)
        //constant BlueFalcon2(0x0E3)
        //constant FalconPunch(0x0E4)
        //constant FalconPunchAir(0x0E5)
        //constant FalconKick(0x0E6)
        //constant FalconKickFromGroundAir(0x0E7)
        //constant LandingFalconKick(0x0E8)
        //constant FalconKickEnd(0x0E9)
        //constant CollisionFalconKick(0x0EA)
        //constant FalconDive(0x0EB)
        //constant FalconDiveCatch(0x0EC)
        //constant FalconDiveEnd1(0x0ED)
        //constant FalconDiveEnd2(0x0EE)

        // strings!
        string_0x0E0:; String.insert("HeadStand")

        action_string_table:
        dw 0 //dw string_0x0DC
        dw 0 //dw string_0x0DD
        dw 0 //dw string_0x0DE
        dw 0 //dw string_0x0DF
        dw string_0x0E0
        dw 0 //dw string_0x0E1
        dw 0 //dw string_0x0E2
        dw 0 //dw string_0x0E3
        dw 0 //dw string_0x0E4
        dw 0 //dw string_0x0E5
        dw 0 //dw string_0x0E6
        dw 0 //dw string_0x0E7
        dw 0 //dw string_0x0E8
        dw 0 //dw string_0x0E9
        dw 0 //dw string_0x0EA
        dw 0 //dw string_0x0EB
        dw 0 //dw string_0x0EC
        dw 0 //dw string_0x0ED
        dw 0 //dw string_0x0EE
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.SANDBAG, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

	// @ Description
    // This adds a check to the Down Bounce routine so that Sandbag can land on his head or go to idle.
    scope sandbag_land: {
        // This allows us to land upright or upside down
        OS.patch_start(0xBEE0C, 0x801443CC)
        j       sandbag_land
        cvt.s.w f10, f8                     // original line 1
        _return:
        OS.patch_end()

        // This allows us to reset the damage multiplier to 1 when landing upright or upside down
        OS.patch_start(0xBEF3C, 0x801444FC)
        jal     sandbag_land._damage_multiplier
        lui     at, 0x3F00                  // original line 1 - at = 0.5
        OS.patch_end()

        lw      at, 0x0008(s0)              // at = character ID
		lli     t7, Character.id.SANDBAG    // t7 = id.SANDBAG
        bne     at, t7, _normal             // if not Sandbag, jump
        sub.s   f0, f0, f10                 // original line 2

        // The rotation angle goes from 0 to -2pi, with -pi being upside down
        // Land on head if between -.8pi and -1.2pi.
        // Land on feet if between 0 and -.2pi or -1.8pi and 2pi.
        // Take rotation and add pi: now it's between -pi and pi.
        // Take absolute value: now it's between 0 and pi.
        // If less than .2pi, then head. If greater than .8pi, then feet.

        lwc1    f6, 0x0030(t6)              // f6 = current rotation value
        li      at, 0x40490FD0              // at = pi
        mtc1    at, f4                      // f4 = pi
        add.s   f4, f6, f4                  // f4 = rotation adjusted by pi
        abs.s   f4, f4                      // f4 = rotation based on closer to head or feet

        li      at, 0x3F20d97C              // at = 0.2pi
        mtc1    at, f6                      // f6 = 0.2pi

        c.le.s  f4, f6                      // fp condition flag = true if we should land on head
        bc1tl   _special
        addiu   a1, r0, 0x00E0              // put in unique headstand action

        li      at, 0x4020D97C              // at = 0.8pi
        mtc1    at, f6                      // f6 = 0.8pi

        c.le.s  f6, f4                      // fp condition flag = true if we should land on feet
        bc1tl   _special
        addiu   a1, r0, Action.Idle         // a1 = idle action

        _normal:
        j       _return
        nop

        _special:
		j       0x801444E0                  // jump to code before change action
		nop

        _damage_multiplier:
        lw      a0, 0x0008(s0)              // a0 = character ID
        lli     t6, Character.id.SANDBAG    // t6 = id.SANDBAG
        bne     a0, t6, _end                // if not sandbag, skip
        lw      a0, 0x0024(s0)              // a0 = current action
        lli     t6, Action.Idle             // t6 = idle action
        beql    a0, t6, _end                // if idle, reset hitbox damage multiplier to 1
        lui     at, 0x3F80                  // at = 1
        lli     t6, Action.HeadStand        // t6 = headstand action
        beql    a0, t6, _end                // if headstand, reset hitbox damage multiplier to 1
        lui     at, 0x3F80                  // at = 1

        _end:
        jr      ra
        mtc1    at, f4                      // original line 2 - at = incoming hitbox damage multiplier
    }

    // @ Description
    // This lets Sandbag standup at the end of his movement
    scope sandbag_getup_: {
        OS.patch_start(0xBEC6C, 0x8014422C)
        jal     sandbag_getup_
        lli     t7, Character.id.SANDBAG
        OS.patch_end()

        // v0 = player struct
        lw      t6, 0x0008(v0)              // t6 = character ID
        bne     t6, t7, _end                // if not sandbag, proceed as normal
        lw      t6, 0x0B18(v0)              // original line 1

        lw      t7, 0x0054(v0)              // load x velocity
        beqzl   t7, _end                    // if x velocity is zero, then set it up so the timer runs out
        lli     t6, 0x0001                  // t7 = 1 = triggers get up

        _end:
        jr       ra
        addiu    t7, t6, 0xFFFF             // original line 2
    }

    // @ Description
    // This prevents decreasing X velocity (from knockback) for sandbag
    scope preserve_sandbag_momentum_: {
        OS.patch_start(0x5D93C, 0x800E213C)
        jal     preserve_sandbag_momentum_
        sub.s   f4, f10, f18                // original line 1 - f4 = new X velocity
        OS.patch_end()

        // s1 = player struct
        lw      v0, 0x0008(s1)              // v0 = character ID
        lli     at, Character.id.SANDBAG
        bnel    v0, at, pc() + 8            // if not sandbag, update X velocity
        swc1    f4, 0x0000(s0)              // original line 2 - update X velocity

        jr      ra
        nop
    }

}
