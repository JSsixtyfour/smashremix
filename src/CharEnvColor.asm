// CharEnvColor.asm
if !{defined __CHAR_ENV_COLOR__} {
define __CHAR_ENV_COLOR__()
print "included CharEnvColor.asm\n"


// @ Description
// Enables controlling environment color per player.

scope CharEnvColor {
    constant RENDER_MODE_DEFAULT(0xC4112078)
    constant RENDER_MODE_ALPHA(0xC41049D8)

    // @ Description
    // If not 0, these values override the default env color used when rendering character models.
    override_table:
    dw 0, 0, 0, 0                           // env color override values for p1 through p4
    // @ Description
    // If not 0, and no value is present in override_table, these values override the default env color used when rendering character models.
    moveset_table:
    dw 0, 0, 0, 0                           // env color override values for p1 through p4

    OS.align(16) // align so console is happy

    macro create_custom_display_list(render_mode) {
        dw 0xDE000000, 0x00000000           // branch to display list - will point to original part display list start
        dw 0xE200001C, {render_mode}        // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the 2nd half of original part display list
        dw 0xDF000000, 0x00000000           // end display list
    }

    // @ Description
    // Custom display lists to help fix model issues for specific characters
    custom_display_lists_falcon:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_gnd:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_wario:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_kirby_dk_hat_hi:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_kirby_dk_hat_lo:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_kirby_pika_hat_hi:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)
    custom_display_lists_kirby_pika_hat_lo:
    create_custom_display_list(RENDER_MODE_DEFAULT)
    create_custom_display_list(RENDER_MODE_ALPHA)

    // @ Description
    // This checks the override table before reading the default env color.
    scope override_env_color_: {
        // Battles
        OS.patch_start(0x781DC, 0x800FC9DC)
        j       override_env_color_._battle
        sw      t7, 0x0000(a1)              // original line 1
        _return_battle:
        OS.patch_end()
        // Menus
        // TODO: console crash on menu due to the custom display lists I think... so disabling this feature on the menu
        OS.patch_start(0x107B28, 0x80390548)
        //j       override_env_color_._menu
        //sw      t7, 0x0000(a1)              // original line 1
        _return_menu:
        OS.patch_end()

        // s8 = player struct

        _battle:
        li      t1, _return_battle
        b       _start
        addiu   a2, a2, 0x1388              // original line 2

        _menu:
        // TODO: console crash on menu due to the custom display lists I think... so disabling this feature on the menu
        //li      t1, _return_menu
        //addiu   a2, a2, 0x29E0              // original line 2

        _start:
        lli     t6, 0x0000                  // t6 = offset to custom display list: 0 = default display list command
       
        li      t9, override_table
        lbu     t2, 0x000D(s8)              // t2 = port
        sll     t2, t2, 0x0002              // t2 = offset to override value
        addu    t9, t9, t2                  // t9 = address of override value
        lw      t2, 0x0000(t9)              // t2 = override value
        bnez    t2, _override               // if !0, override
        nop
        li      t9, moveset_table
        lbu     t2, 0x000D(s8)              // t2 = port
        sll     t2, t2, 0x0002              // t2 = offset to override value
        addu    t9, t9, t2                  // t9 = address of moveset override value
        lw      t2, 0x0000(t9)              // t2 = moveset override value
        beqz    t2, _fix_parts              // if 0, don't override
        nop
        
        _override:
        or      a2, t9, r0                  // a2 = override value address
        lli     t6, 0x0020                  // t6 = offset to custom display list: 0x20 = override display list command

        _fix_parts:
        // fix Falcon's head
        lw      t2, 0x0008(s8)              // t2 = char_id
        lli     t9, Character.id.FALCON
        beq     t2, t9, _fix_falcon         // skip to fixing FALCON
        lli     t9, Character.id.JFALCON
        beq     t2, t9, _fix_falcon         // skip to fixing JFALCON
        lli     t9, Character.id.GND
        beq     t2, t9, _fix_ganondorf      // skip to fixing GND
        lli     t9, Character.id.WARIO
        beq     t2, t9, _fix_wario          // skip to fixing WARIO
        lli     t9, Character.id.KIRBY
        beq     t2, t9, _fix_kirby          // skip to fixing KIRBY
        lli     t9, Character.id.JKIRBY
        beq     t2, t9, _fix_kirby          // skip to fixing JKIRBY
        nop
        b       _return                     // skip if no fixing necessary
        nop

        _fix_falcon:
        // Falcon's high poly model has some places where it turns off alpha compare and has its own render mode.
        // When it resets the render mode, it's not right for alpha, so we use a custom display list to set the render mode.

        lbu     t2, 0x000F(s8)              // t2 = 1 if high poly, 2 if low poly
        sltiu   t2, t2, 0x0002              // t2 = 1 if high poly, 0 if low poly
        beqz    t2, _return                 // skip if lo poly
        nop
        li      t9, custom_display_lists_falcon
        lw      t2, 0x0004(t9)              // t2 = original part display list pointer, if initialized
        bnez    t2, _skip_init_falcon       // if already initialized, skip setup
        lw      t2, 0x0918(s8)              // t2 = part 0x08 address
        lw      t3, 0x0050(t2)              // t3 = part 0x08 display list
        sw      t3, 0x0004(t9)              // save original part display list start to custom display list
        sw      t3, 0x0024(t9)              // save original part display list start to custom display list for override
        lui     t0, 0xDF00                  // t0 = DF000000 (end display list)
        sw      t0, 0x0128(t3)              // split original display list into 2 by putting end display list here
        sw      r0, 0x012C(t3)              // ~
        addiu   t0, t3, 0x0130              // t0 = start of 2nd half of the original display list
        sw      t0, 0x0014(t9)              // save original part display list part 2 start to custom display list
        sw      t0, 0x0034(t9)              // save original part display list part 2 start to custom display list for override

        _skip_init_falcon:
        addu    t9, t9, t6                  // t9 = address of display list to use
        b       _return
        sw      t9, 0x0050(t2)              // save custom display list address as new part display list pointer

        _fix_ganondorf:
        // Ganondorf's high poly model has some places where it turns off alpha compare and has its own render mode.
        // When it resets the render mode, it's not right for alpha, so we use a custom display list to set the render mode.
        // TODO: update when model is updated to include low poly model (and also skip low poly if not an issue)
        li      t9, custom_display_lists_gnd
        lw      t2, 0x0004(t9)              // t2 = original part display list pointer, if initialized
        bnez    t2, _skip_init_ganondorf    // if already initialized, skip setup
        lw      t2, 0x0900(s8)              // t2 = part 0x02 address
        lw      t3, 0x0050(t2)              // t3 = part 0x02 display list
        sw      t3, 0x0004(t9)              // save original part display list start to custom display list
        sw      t3, 0x0024(t9)              // save original part display list start to custom display list for override
        lui     t0, 0xDF00                  // t0 = DF000000 (end display list)
        sw      t0, 0x01B8(t3)              // split original display list into 2 by putting end display list here
        sw      r0, 0x01BC(t3)              // ~
        addiu   t0, t3, 0x01C0              // t0 = start of 2nd half of the original display list
        sw      t0, 0x0014(t9)              // save original part display list part 2 start to custom display list
        sw      t0, 0x0034(t9)              // save original part display list part 2 start to custom display list for override

        _skip_init_ganondorf:
        addu    t9, t9, t6                  // t9 = address of display list to use
        b       _return
        sw      t9, 0x0050(t2)              // save custom display list address as new part display list pointer

        _fix_wario:
        // Wario's high poly model has some places where it turns off alpha compare and has its own render mode.
        // When it resets the render mode, it's not right for alpha, so we use a custom display list to set the render mode.
        // TODO: update when model is updated to include low poly model (and also skip low poly if not an issue)
        li      t9, custom_display_lists_wario
        lw      t2, 0x0004(t9)              // t2 = original part display list pointer, if initialized
        bnez    t2, _skip_init_wario        // if already initialized, skip setup
        lw      t2, 0x0918(s8)              // t2 = part 0x08 address
        lw      t3, 0x0050(t2)              // t3 = part 0x08 display list
        sw      t3, 0x0004(t9)              // save original part display list start to custom display list
        sw      t3, 0x0024(t9)              // save original part display list start to custom display list for override
        lui     t0, 0xDF00                  // t0 = DF000000 (end display list)
        sw      t0, 0x0368(t3)              // split original display list into 2 by putting end display list here
        sw      r0, 0x036C(t3)              // ~
        addiu   t0, t3, 0x0370              // t0 = start of 2nd half of the original display list
        sw      t0, 0x0014(t9)              // save original part display list part 2 start to custom display list
        sw      t0, 0x0034(t9)              // save original part display list part 2 start to custom display list for override

        _skip_init_wario:
        addu    t9, t9, t6                  // t9 = address of display list to use
        b       _return
        sw      t9, 0x0050(t2)              // save custom display list address as new part display list pointer

        lw      t2, 0x0918(s8)              // t2 = part 0x08 address
        b       _return
        lw      t2, 0x0050(t2)              // t2 = part 0x08 display list

        _fix_kirby:
        // Kirby's hat models for Pikachu and DK have some places where it turns off alpha compare and has its own render mode.
        // When it resets the render mode, it's not right for alpha, so we use a custom display list to set the render mode.
        // TODO: DK still has a pretty noticeable ring of opaqueness

        lbu     t2, 0x000F(s8)              // t2 = 1 if high poly, 2 if low poly
        sltiu   t0, t2, 0x0002              // t0 = 1 if high poly, 0 if low poly
        lbu     t2, 0x0981(s8)              // t2 = kirby_hat_id

        li      t9, custom_display_lists_kirby_dk_hat_hi
        beqzl   t0, pc() + 8                // if lo poly, adjust to custom_display_lists_kirby_dk_hat_lo
        addiu   t9, t9, 0x0040              // t9 = address of dk hat display list
        lli     t3, Character.kirby_hat_id.DK
        beql    t2, t3, _fix_hat            // if copying DK, need to fix
        lli     t4, 0x02B8                  // t4 = offset to render mode reset (238 lo)

        li      t9, custom_display_lists_kirby_pika_hat_hi
        beqzl   t0, pc() + 8                // if lo poly, adjust to custom_display_lists_kirby_pika_hat_lo
        addiu   t9, t9, 0x0040              // t9 = address of pika hat display list
        lli     t3, Character.kirby_hat_id.PIKACHU
        beql    t2, t3, _fix_hat            // if copying Pikachu, need to fix
        lli     t4, 0x0280                  // t4 = offset to render mode reset

        b       _return                     // otherwise skip
        nop

        _fix_hat:
        beqzl   t0, pc() + 8                // if lo poly, just so happens we adjust the offset the same amount for both DK and Pikachu
        addiu   t4, t4, -0x0080             // t4 = offset to render mode reset for the low poly display list
        lw      t2, 0x0004(t9)              // t2 = original part display list pointer, if initialized
        bnez    t2, _skip_init_kirby        // if already initialized, skip setup
        lw      t2, 0x0900(s8)              // t2 = part 0x02 address
        lw      t3, 0x0050(t2)              // t3 = part 0x02 display list
        sw      t3, 0x0004(t9)              // save original part display list start to custom display list
        sw      t3, 0x0024(t9)              // save original part display list start to custom display list for override
        addu    t3, t3, t4                  // t3 = end of first half of original display list
        lui     t0, 0xDF00                  // t0 = DF000000 (end display list)
        sw      t0, 0x0000(t3)              // split original display list into 2 by putting end display list here
        sw      r0, 0x0004(t3)              // ~
        addiu   t0, t3, 0x0010              // t0 = start of 2nd half of the original display list
        sw      t0, 0x0014(t9)              // save original part display list part 2 start to custom display list
        sw      t0, 0x0034(t9)              // save original part display list part 2 start to custom display list for override

        _skip_init_kirby:
        addu    t9, t9, t6                  // t9 = address of display list to use
        b       _return
        sw      t9, 0x0050(t2)              // save custom display list address as new part display list pointer

        _return:
        jr      t1                          // return
        nop
    }

    // @ Desription
    // Resets custom display lists during main character file loading.
    scope reset_custom_display_lists_: {
        OS.patch_start(0x52EA4, 0x800D76A4)
        sw      ra, 0x001C(sp)              // original line 3
        jal     reset_custom_display_lists_
        addu    s0, s0, t6                  // original line 1
        OS.patch_end()

        // a0 = char_id

        li      a1, custom_display_lists_falcon
        lli     a2, Character.id.FALCON
        beq     a0, a2, _clear              // if FALCON, clear FALCON's custom display lists
        nop
        lli     a2, Character.id.JFALCON
        beq     a0, a2, _clear              // if JFALCON, clear JFALCON's custom display lists
        nop
        li      a1, custom_display_lists_gnd
        lli     a2, Character.id.GND
        beq     a0, a2, _clear              // if GND, clear GND's custom display lists
        nop
        li      a1, custom_display_lists_wario
        lli     a2, Character.id.WARIO
        beq     a0, a2, _clear              // if WARIO, clear WARIO's custom display lists
        nop
        li      a1, custom_display_lists_kirby_dk_hat_hi
        lli     a2, Character.id.KIRBY
        beq     a0, a2, _clear_kirby        // if KIRBY, clear KIRBY's custom display lists
        nop
        lli     a2, Character.id.JKIRBY
        beq     a0, a2, _clear_kirby        // if JKIRBY, clear JKIRBY's custom display lists
        nop
        b       _end                        // otherwise, skip
        nop

        _clear_kirby:
        // clear extra display lists for Kirby
        // kirby DK hat, lo poly
        sw      r0, 0x0044(a1)              // clear out original part display list start pointer
        sw      r0, 0x0054(a1)              // clear out original part display list 2nd half start pointer
        sw      r0, 0x0064(a1)              // clear out original part display list start pointer
        sw      r0, 0x0074(a1)              // clear out original part display list 2nd half start pointer
        // kirby Pika hat, hi poly
        sw      r0, 0x0084(a1)              // clear out original part display list start pointer
        sw      r0, 0x0094(a1)              // clear out original part display list 2nd half start pointer
        sw      r0, 0x00A4(a1)              // clear out original part display list start pointer
        sw      r0, 0x00B4(a1)              // clear out original part display list 2nd half start pointer
        // kirby Pika hat, lo poly
        sw      r0, 0x00C4(a1)              // clear out original part display list start pointer
        sw      r0, 0x00D4(a1)              // clear out original part display list 2nd half start pointer
        sw      r0, 0x00E4(a1)              // clear out original part display list start pointer
        sw      r0, 0x00F4(a1)              // clear out original part display list 2nd half start pointer
        // kirby DK hat, hi poly is below

        _clear:
        sw      r0, 0x0004(a1)              // clear out original part display list start pointer
        sw      r0, 0x0014(a1)              // clear out original part display list 2nd half start pointer
        sw      r0, 0x0024(a1)              // clear out original part display list start pointer
        sw      r0, 0x0034(a1)              // clear out original part display list 2nd half start pointer

        _end:
        jr      ra
        lw      s0, 0x6E10(s0)              // original line 2
    }

    // @ Description
    // Updates player indicator to respect the env color's alpha.
    scope update_player_indicator_alpha_: {
        OS.patch_start(0x8D33C, 0x80111B3C)
        jal     update_player_indicator_alpha_
        lw      v0, 0x0074(a0)              // original line 1
        OS.patch_end()

        // a0 = player indicator object
        // v0 = player indicator position struct
        // 0x0084(a0) = port
        lli     t8, 0x00FF                  // t8 = full opaque (default)

        li      t9, override_table
        lw      t1, 0x0084(a0)              // t1 = port
        sll     t5, t1, 0x0002              // t5 = offset to override value
        addu    t9, t9, t5                  // t9 = address of override value
        lw      t7, 0x0000(t9)              // t7 = override value
        bnez    t7, _override               // if !0, override
        nop
        li      t9, moveset_table
        addu    t9, t9, t5                  // t9 = address of moveset override value
        lw      t7, 0x0000(t9)              // t7 = moveset override value
        beqz    t7, _end                    // if 0, don't override
        nop

        _override:
        lbu     t8, 0x0003(t9)              // t8 = custom alpha

        _end:
        sb      t8, 0x002B(v0)              // update player indicator alpha
        jr      ra
        lwc1    f6, 0x0034(sp)              // original line 2
    }
}

} // __CHAR_ENV_COLOR__
