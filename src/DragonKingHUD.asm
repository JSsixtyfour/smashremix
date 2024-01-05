// DragonKingHUD.asm
if !{defined __DRAGON_KING_HUD__} {
define __DRAGON_KING_HUD__()
print "included DragonKingHUD.asm\n"

// @ Description
// This file allows for the HUD to appear like the Dragon King demo footage

// TODO:
// - widths fix?

scope DragonKingHUD {

    // @ Description
    // Holds the table of offsets for the Dragon King numbers in file 00A4
    dragon_king_numbers:
    dw 0x17B8  // 0
    dw 0x1998  // 1
    dw 0x1C38  // 2
    dw 0x1ED8  // 3
    dw 0x2178  // 4
    dw 0x2418  // 5
    dw 0x26B8  // 6
    dw 0x2898  // 7
    dw 0x2A78  // 8
    dw 0x2C58  // 9
    dw 0x2EF8  // %
    dw 0x3198  // HP

    // @ Description
    // Holds the table of widths for the Dragon King numbers in file 00A4
    dragon_king_widths:
    dw 0x00000011 // 0
    dw 0x0000000C // 1
    dw 0x00000012 // 2
    dw 0x00000011 // 3
    dw 0x00000012 // 4
    dw 0x00000010 // 5
    dw 0x00000012 // 6
    dw 0x00000011 // 7
    dw 0x00000012 // 8
    dw 0x00000012 // 9
    dw 0x00000014 // %
    dw 0x00000017 // HP

    // @ Description
    // Changes the offsets table used to draw the player damage numbers
    scope set_damage_number_offsets_: {
        OS.patch_start(0x8A8D0, 0x8010F0D0)
        jal     set_damage_number_offsets_
        lui     s2, 0x8013                  // original line 1
        OS.patch_end()

        addiu   s2, s2, 0xEE64              // original line 2 - s2 = vanilla damage number offsets

        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end                // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beq     t7, t6, _dk                 // if on, use Dragon King position
        nop

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beq     t7, t6, _dk                 // if Dragon King, use Dragon King position
        lli     t6, Stages.id.DRAGONKING_REMIX
        bne     t7, t6, _end                // if not Dragon King Remix, skip
        nop

        _dk:
        li      s2, dragon_king_numbers     // s2 = Dragon King damage number offsets

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Changes the horizontal spacing of the damage numbers
    scope set_horizontal_spacing_: {
        OS.patch_start(0x8A368, 0x8010EB68)
        jal     set_horizontal_spacing_
        lw      a0, 0x0008(t7)              // original line 1
        OS.patch_end()

        addiu   a2, a2, 0xEBF0              // original line 2 - a2 = width table

        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end                // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beq     t7, t6, _dk                 // if on, use Dragon King position
        nop

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beq     t7, t6, _dk                 // if Dragon King, use Dragon King position
        lli     t6, Stages.id.DRAGONKING_REMIX
        bne     t7, t6, _end                // if not Dragon King Remix, skip
        nop

        _dk:
        li      a2, dragon_king_widths      // a2 = Dragon King damage number widths

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Changes the vertical position of the damage numbers and associated effects
    scope set_vertical_position_: {
        constant DRAGON_KING_Y_POS(0x0026)

        // training/vs
        OS.patch_start(0x8ABB0, 0x8010F3B0)
        j       set_vertical_position_
        addiu   t7, r0, 0x00D2              // original line 1 - t7 = Y position
        OS.patch_end()

        // bonus
        OS.patch_start(0x112D28, 0x8018E5E8)
        j       set_vertical_position_
        addiu   t7, r0, 0x00D2              // original line 1 - t7 = Y position
        OS.patch_end()

        // how to play
        OS.patch_start(0x18AA60, 0x8018D450)
        j       set_vertical_position_
        addiu   t7, r0, 0x0096              // original line 1 - t7 = Y position
        OS.patch_end()

        // 1p
        OS.patch_start(0x10CEAC, 0x8018E64C)
        j       set_vertical_position_._1p
        addiu   t5, r0, 0x00D2              // original line 1 - normal Y position
        _return_1p:
        OS.patch_end()

        sw      t6, 0x0008(v0)              // original line 2

        Toggles.read(entry_dragon_king_hud, t8) // t8 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t8, t6, _end                // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t8, t6, _end                // if on, use Dragon King position
        lli     t7, DRAGON_KING_Y_POS       // t7 = Dragon King vertical position

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t8)
        lbu     t8, 0x0001(t8)              // t8 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t8, t6, _end                // if Dragon King, use Dragon King position
        lli     t7, DRAGON_KING_Y_POS       // t9 = Dragon King vertical position
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t8, t6, _end                // if Dragon King Remix, use Dragon King position
        lli     t7, DRAGON_KING_Y_POS       // t9 = Dragon King vertical position

        _end:
        jr      ra                          // original line 3
        sh      t7, 0x000C(v0)              // original line 4

        _1p:
        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end_1p             // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t7, t6, _end_1p             // if on, use Dragon King position
        lli     t5, DRAGON_KING_Y_POS       // t5 = Dragon King vertical position

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t7, t6, _end_1p             // if Dragon King, use Dragon King position
        lli     t5, DRAGON_KING_Y_POS       // t5 = Dragon King vertical position
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t7, t6, _end_1p             // if Dragon King Remix, use Dragon King position
        lli     t7, DRAGON_KING_Y_POS       // t9 = Dragon King vertical position

        _end_1p:
        j       _return_1p
        lw      s4, 0x0028(sp)              // original line 2
    }

    // @ Description
    // Sets color to shield color
    scope set_damage_color_: {
        OS.patch_start(0x8A984, 0x8010F184)
        jal     set_damage_color_
        nop
        OS.patch_end()

        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t2, 0x0002                  // t2 = 2 = off always
        beq     t7, t2, _end                // if off, skip
        lli     t2, 0x0001                  // t2 = 1 = always on
        beq     t7, t2, _dk                 // if on, use shield color
        nop

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t2, Stages.id.DRAGONKING
        beq     t7, t2, _dk                 // if Dragon King, use shield color
        lli     t2, Stages.id.DRAGONKING_REMIX
        bne     t7, t2, _end                // if not Dragon King Remix, skip
        nop

        _dk:
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lw      a0, 0x0004(s0)              // a0 = object
        jal     Character.port_to_struct_   // v0 = player struct
        lw      a0, 0x0084(a0)              // a0 = port

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space

        li      t2, Global.match_info
        lw      t2, 0x0000(t2)              // t2 = match info struct
        addiu   t8, t2, 0x0002              // t8 = address of teams byte, if vs
        li      t2, Global.vs.teams         // t2 = pointer to teams byte
        bne     t2, t8, _cpu                // if not vs, skip
        lbu     t2, 0x0000(t2)              // t2 = teams
        beqz    t2, _cpu                    // if (!teams), skip
        nop
        li      t7, table_team
        b       _get_from_table             // ~
        lbu     a0, 0x000C(v0)              // a0 = team

        _cpu:
        lbu     t8, 0x0023(v0)              // t8 = type (player = 0, cpu = 1)
        beqz    t8, _human                  // if cpu, use white
        lli     a1, 0x00FF                  // a1 = 0xFF (G)

        lli     a0, 0x00FF                  // a1 = 0xFF (R)
        b       _end
        lli     a2, 0x00FF                  // a1 = 0xFF (B)

        _human:
        li      t7, table_ffa               // t7 = address of color table

        _get_from_table:
        sll     t8, a0, 0x0002              // t8 = offset to value
        addu    t7, t7, t8                  // t7 = color
        lbu     a0, 0x0000(t7)              // a0 = R value
        lbu     a1, 0x0001(t7)              // a1 = G value
        lbu     a2, 0x0002(t7)              // a2 = B value

        _end:
        sb      a0, 0x0028(s0)              // original line 1
        jr      ra
        sb      a1, 0x0029(s0)              // original line 2

        table_ffa:
        dw (0xFFFFFF00 & Color.dragon_king.RED)    // p1
        dw (0xFFFFFF00 & Color.dragon_king.BLUE)   // p2
        dw (0xFFFFFF00 & Color.dragon_king.YELLOW) // p3
        dw (0xFFFFFF00 & Color.dragon_king.GREEN)  // p4

        // Needs to be updated manually for added teams, like for yellow below
        table_team:
        dw (0xFFFFFF00 & Color.dragon_king.RED)    // red
        dw (0xFFFFFF00 & Color.dragon_king.BLUE)   // blue
        dw (0xFFFFFF00 & Color.dragon_king.GREEN)  // green
        dw (0xFFFFFF00 & Color.dragon_king.YELLOW) // yellow
    }

    // @ Description
    // Adjusts VS timer position if Dragon King HUD is enabled
    scope adjust_timer_position_: {
        constant LOWER_Y(0x4354)

        OS.patch_start(0x8E554, 0x80112D54)
        jal     adjust_timer_position_._digits
        lui     at, LOWER_Y                 // at = lower Y position
        OS.patch_end()

        OS.patch_start(0x8E888, 0x80113088)
        jal     adjust_timer_position_._colon
        addiu   a0, a0, 0x17C8              // original line 1
        OS.patch_end()

        _digits:
        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end_digits         // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t7, t6, _end_digits         // if on, use Dragon King position
        mtc1    at, f2                      // f2 = lower Y position

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t7, t6, _end_digits         // if Dragon King, use Dragon King position
        mtc1    at, f2                      // f2 = lower Y position
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t7, t6, _end_digits         // if Dragon King Remix, use Dragon King position
        mtc1    at, f2                      // f2 = lower Y position

        _end_digits:
        lui     at, 0x3F00                  // original line 1
        jr      ra
        lui     a2, 0x8013                  // original line 2

        _colon:
        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end_colon          // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t7, t6, _end_colon          // if on, use Dragon King position
        lui     at, LOWER_Y                 // at = Y position, lowered

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t7, t6, _end_colon          // if Dragon King, use Dragon King position
        lui     at, LOWER_Y                 // at = Y position, lowered
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t7, t6, _end_colon          // if Dragon King Remix, use Dragon King position
        lui     at, LOWER_Y                 // at = Y position, lowered

        _end_colon:
        jr      ra
        addiu   v1, r0, 0x000A              // original line 2
    }

    // @ Description
    // This hides series logos for Dragon King HUD
    scope hide_series_logo_: {
        OS.patch_start(0x8AD0C, 0x8010F50C)
        jal     hide_series_logo_
        lh      t2, 0x0014(v0)              // original line 1 - t2 = image width
        OS.patch_end()

        Toggles.read(entry_dragon_king_hud, t3) // t3 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t3, t6, _end                // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t3, t6, _end                // if on, use Dragon King position
        sh      r0, 0x0014(v0)              // set width to 0 to hide

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t3)
        lbu     t3, 0x0001(t3)              // t3 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t3, t6, _end                // if Dragon King, use Dragon King position
        sh      r0, 0x0014(v0)              // set width to 0 to hide
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t3, t6, _end                // if Dragon King Remix, use Dragon King position
        sh      r0, 0x0014(v0)              // set width to 0 to hide

        _end:
        jr      ra
        lui     a2, 0x8013                  // original line 2
    }

    // @ Description
    // Hide Score +1/-1 animation
    hide_score_sprite_: {
        OS.patch_start(0x90228, 0x80114A28)
        jal     hide_score_sprite_
        cvt.s.w f10, f8                     // original line 1
        OS.patch_end()

        Toggles.read(entry_dragon_king_hud, t3) // t3 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t3, t6, _normal             // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beq     t3, t6, _dk                 // if on, disable
        nop

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t3)
        lbu     t3, 0x0001(t3)              // t3 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beq     t3, t6, _dk                 // if Dragon King, disable
        lli     t6, Stages.id.DRAGONKING_REMIX
        bne     t3, t6, _normal             // if not Dragon King Remix, skip
        nop

        _dk:
        j       0x80114A38                  // skip animation
        nop

        _normal:
        jr      ra
        swc1    f6, 0x001C(sp)              // original line 2
    }

    // @ Description
    // Disable the animation that makes the damage numbers fall during KO
    // Really just speeds it up so it's not noticeable
    scope disable_ko_falling_damage_animation_: {
        constant FASTER_SPEED(0x4380)

        OS.patch_start(0x8AFB4, 0x8010F7B4)
        jal     disable_ko_falling_damage_animation_
        lui     at, 0xC120                  // original line 2
        OS.patch_end()

        Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
        lli     t6, 0x0002                  // t6 = 2 = off always
        beq     t7, t6, _end                // if off, skip
        lli     t6, 0x0001                  // t6 = 1 = always on
        beql    t7, t6, _end                // if on, use Dragon King speed
        lui     at, FASTER_SPEED            // at = Y speed, faster

        // if here, check if on a Dragon King stage
        OS.read_word(Global.match_info, t7)
        lbu     t7, 0x0001(t7)              // t7 = stage_id
        lli     t6, Stages.id.DRAGONKING
        beql    t7, t6, _end                // if Dragon King, use Dragon King speed
        lui     at, FASTER_SPEED            // at = Y speed, faster
        lli     t6, Stages.id.DRAGONKING_REMIX
        beql    t7, t6, _end                // if Dragon King Remix, use Dragon King speed
        lui     at, FASTER_SPEED            // at = Y speed, faster

        _end:
        jr      ra
        or      s1, r0, r0                  // original line 1
    }

    scope training_mode {
        // @ Description
        // Repositions Training HUD labels
        scope reposition_training_hud_labels_: {
            constant DRAGON_KING_Y_POS_DIFF(0xB0)

            OS.patch_start(0x114728, 0x8018DF08)
            jal     reposition_training_hud_labels_
            swc1    f6, 0x0058(v0)              // original line 1 - set X position
            OS.patch_end()

            // Only do for HUD, not pause menu
            lw      t7, 0x0014(sp)              // t7 = ra for routine
            li      t6, 0x8018DFC4              // t6 = ra if for HUD titles
            bnel    t7, t6, _end                // if not HUD titles, skip
            lli     t6, 0x0000                  // t6 = Y position difference

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beql    t7, t6, _end                // if off, skip
            lli     t6, 0x0000                  // t6 = Y position difference
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lli     t6, DRAGON_KING_Y_POS_DIFF  // t6 = Dragon King vertical position difference

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lli     t6, DRAGON_KING_Y_POS_DIFF  // t6 = Dragon King vertical position difference
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lli     t6, DRAGON_KING_Y_POS_DIFF  // t6 = Dragon King vertical position difference

            lli     t6, 0x0000                  // t6 = Y position difference

            _end:
            lh      t7, 0x0002(a2)              // original line 2 - get Y position
            jr      ra
            addu    t7, t7, t6                  // t7 = updated Y position if Dragon King
        }

        // @ Description
        // Repositions Training HUD damage
        scope reposition_training_hud_damage_: {
            constant DRAGON_KING_Y_POS(0x4344)

            OS.patch_start(0x114BB0, 0x8018E390)
            jal     reposition_training_hud_damage_
            lui     at, 0x41A0                  // original line 1 - at = Y position
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            _end:
            jr      ra
            mtc1    at, f20                     // original line 2
        }

        // @ Description
        // Repositions Training HUD combo
        scope reposition_training_hud_combo_: {
            constant DRAGON_KING_Y_POS(0x4354)

            OS.patch_start(0x114ECC, 0x8018E6AC)
            jal     reposition_training_hud_combo_
            lui     at, 0x4210                  // original line 1 - at = Y position
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            _end:
            jr      ra
            mtc1    at, f20                     // original line 2
        }

        // @ Description
        // Repositions Training HUD speed and enemy
        scope reposition_training_hud_speed_enemy_: {
            constant DRAGON_KING_Y_POS(0x4344)

            // speed
            OS.patch_start(0x115008, 0x8018E7E8)
            jal     reposition_training_hud_speed_enemy_
            lui     at, 0x41A0                  // original line 1 - at = Y position
            OS.patch_end()

            // enemy
            OS.patch_start(0x115104, 0x8018E8E4)
            jal     reposition_training_hud_speed_enemy_
            lui     at, 0x41A0                  // original line 1 - at = Y position
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            _end:
            jr      ra
            mtc1    at, f6                      // original line 2
        }

        // @ Description
        // Repositions Training HUD item
        scope reposition_training_hud_item_: {
            constant DRAGON_KING_Y_POS(0x4354)

            // ]
            OS.patch_start(0x11530C, 0x8018EAEC)
            jal     reposition_training_hud_item_
            lui     at, 0x4210                  // original line 1 - at = Y position
            OS.patch_end()

            // item
            OS.patch_start(0x115338, 0x8018EB18)
            lw      at, 0x0020(sp)              // at = saved Y position
            OS.patch_end()

            // [
            OS.patch_start(0x115360, 0x8018EB40)
            lw      at, 0x0020(sp)              // at = saved Y position
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            _end:
            sw      at, 0x0020(sp)              // save for later in free stack space
            jr      ra
            mtc1    at, f6                      // original line 2
        }
    }

    scope bonus {
        // @ Description
        // Moves the BTT targets and BTP platforms remaining down
        scope reposition_targets_: {
            constant DRAGON_KING_Y_POS(0xCE)

            // btt
            OS.patch_start(0x1125D0, 0x8018DE90)
            jal     reposition_targets_
            addiu   s5, r0, 0x001E             // original line 1 - s5 = y position (mid)
            OS.patch_end()

            // btp
            OS.patch_start(0x11272C, 0x8018DFEC)
            jal     reposition_targets_
            addiu   s5, r0, 0x001E             // original line 1 - s5 = y position (mid)
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lli     s5, DRAGON_KING_Y_POS       // s5 = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lli     s5, DRAGON_KING_Y_POS       // s5 = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lli     s5, DRAGON_KING_Y_POS       // s5 = Dragon King vertical position

            _end:
            jr      ra
            or      a0, s1, r0                 // original line 2
        }
    }

    scope single_player {
        // @ Description
        // Moves the enemy stock icons down
        scope reposition_multi_enemy_icons_: {
            constant DRAGON_KING_Y_POS(0xC4)

            OS.patch_start(0x10D510, 0x8018ECB0)
            j       reposition_multi_enemy_icons_
            addiu   t9, t8, 0x0014             // original line 1 - t9 = y position
            _return:
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            addiu   t9, t8, DRAGON_KING_Y_POS   // t9 = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            addiu   t9, t8, DRAGON_KING_Y_POS   // t9 = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            addiu   t9, t8, DRAGON_KING_Y_POS   // t9 = Dragon King vertical position

            _end:
            j       _return
            mtc1    t9, f8                      // original line 2
        }
    }

    scope vs_demo {
        scope move_name_down_: {
            constant DRAGON_KING_Y_POS(0x4348)

            OS.patch_start(0x18C8FC, 0x8018DBBC)
            jal     move_name_down_
            lui     at, 0x4248                  // original line 1 - at = y pos
            OS.patch_end()

            Toggles.read(entry_dragon_king_hud, t7) // t7 = 2 if off
            lli     t6, 0x0002                  // t6 = 2 = off always
            beq     t7, t6, _end                // if off, skip
            lli     t6, 0x0001                  // t6 = 1 = always on
            beql    t7, t6, _end                // if on, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            // if here, check if on a Dragon King stage
            OS.read_word(Global.match_info, t7)
            lbu     t7, 0x0001(t7)              // t7 = stage_id
            lli     t6, Stages.id.DRAGONKING
            beql    t7, t6, _end                // if Dragon King, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position
            lli     t6, Stages.id.DRAGONKING_REMIX
            beql    t7, t6, _end                // if Dragon King Remix, use Dragon King position
            lui     at, DRAGON_KING_Y_POS       // at = Dragon King vertical position

            _end:
            jr      ra
            mtc1    at, f24                     // original line 2
        }
    }

}

} // __DRAGON_KING_HUD__
