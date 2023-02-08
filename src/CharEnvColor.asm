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

    // @ Description
    // These state values are used to force a character into a predefined env color state through the match.
    // See state scope below.
    state_table:
    dw 0, 0, 0, 0                           // state for p1 through p4

    // @ Description
    // State constants
    scope state {
    	constant NORMAL(0)
    	constant CLOAKED(1)
    	constant NONE(2)
    	constant DARK(3)
    }

    OS.align(16) // align so console is happy

    macro create_custom_display_list(render_mode) {
        dw 0xDE000000, 0x00000000           // branch to display list - will point to original part display list start
        dw 0xE200001C, {render_mode}        // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the 2nd half of original part display list
        dw 0xDF000000, 0x00000000           // end display list
    }

    macro create_custom_display_list(render_mode1, render_mode2) {
        dw 0xDE000000, 0x00000000           // branch to display list - will point to original part display list start
        dw 0xE200001C, {render_mode1}       // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the 2nd third of original part display list
        dw 0xE200001C, {render_mode2}       // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the last third of original part display list
        dw 0xDF000000, 0x00000000           // end display list
    }

    macro create_custom_display_list(render_mode1, render_mode2, render_mode3) {
        dw 0xDE000000, 0x00000000           // branch to display list - will point to original part display list start
        dw 0xE200001C, {render_mode1}       // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the 2nd fourth of original part display list
        dw 0xE200001C, {render_mode2}       // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the 3rd fourth of original part display list
        dw 0xE200001C, {render_mode3}       // set render mode
        dw 0xDE000000, 0x00000000           // branch to display list - will point to the last fourth of original part display list
        dw 0xDF000000, 0x00000000           // end display list
    }

    // @ Description
    // Custom display lists to help fix model issues for specific characters
    scope custom_display_lists_struct_falcon: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0918       // 0x000C: offset to part 0x08 in player struct
        dh 0x0038       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0128       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw 0x0          // 0x0018: pointer to default custom lo poly display list, or 0
        dw 0x0          // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0918       // 0x0020: offset to part 0x08 in player struct
        dh 0xFFFF       // 0x0022: offset to 1st set render mode command for high poly
        dh 0xFFFF       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113078, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_gnd: {
        // TODO: update when model is updated to include low poly model (and also skip low poly if not an issue)
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0900       // 0x000C: offset to part 0x02 in player struct
        dh 0x0118       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x01B8       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0x03E8       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw hi_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw hi_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0900       // 0x0020: offset to part 0x02 in player struct
        dh 0x0118       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x01B8       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0x03E8       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT, 0xC4113878)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_wario: {
        // TODO: update when model is updated to include low poly model (and also skip low poly if not an issue)
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0918       // 0x000C: offset to part 0x08 in player struct
        dh 0x02B0       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0398       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw hi_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw hi_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0918       // 0x0020: offset to part 0x08 in player struct
        dh 0x02B0       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0398       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_ssonic_0: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0918       // 0x000C: offset to part 0x08 in player struct
        dh 0x0338       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0420       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw hi_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw hi_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0918       // 0x0020: offset to part 0x08 in player struct
        dh 0x0338       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0420       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_ssonic_1: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0918       // 0x000C: offset to part 0x08 in player struct
        dh 0x0478       // 0x000E: offset to 1st set render mode command for high poly
        dh 0xFFFF       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw hi_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw hi_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0918       // 0x0020: offset to part 0x08 in player struct
        dh 0x0478       // 0x0022: offset to 1st set render mode command for high poly
        dh 0xFFFF       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_sheik: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0918       // 0x000C: offset to part 0x08 in player struct
        dh 0x0048       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0120       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw hi_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw hi_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0918       // 0x0020: offset to part 0x08 in player struct
        dh 0x0048       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0120       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_ylink: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0914       // 0x000C: offset to part 0x07 in player struct
        dh 0x0148       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0220       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw lo_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw lo_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0914       // 0x0020: offset to part 0x07 in player struct
        dh 0x0118       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x01F0       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
        lo_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        lo_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_dk_hat: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0900       // 0x000C: offset to part 0x02 in player struct
        dh 0x0120       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x02B8       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw lo_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw lo_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0900       // 0x0020: offset to part 0x02 in player struct
        dh 0x0100       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0238       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113078, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
        lo_default:; create_custom_display_list(0xC4113078, RENDER_MODE_DEFAULT)
        lo_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_pika_hat: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0900       // 0x000C: offset to part 0x02 in player struct
        dh 0x01E8       // 0x000E: offset to 1st set render mode command for high poly
        dh 0x0280       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw lo_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw lo_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0900       // 0x0020: offset to part 0x02 in player struct
        dh 0x0160       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0200       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113078, RENDER_MODE_DEFAULT)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
        lo_default:; create_custom_display_list(0xC4113078, RENDER_MODE_DEFAULT)
        lo_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_sonic_hat: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0900       // 0x000C: offset to part 0x02 in player struct
        dh 0x03E8       // 0x000E: offset to 1st set render mode command for high poly
        dh 0xFFFF       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw lo_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw lo_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0900       // 0x0020: offset to part 0x02 in player struct
        dh 0x0188       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x0278       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA)
        lo_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        lo_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

    scope custom_display_lists_struct_sheik_hat: {
        dw OS.FALSE     // 0x0000: initialized flag, high poly
        dw hi_default   // 0x0004: pointer to default custom hi poly display list, or 0
        dw hi_alpha     // 0x0008: pointer to alpha custom hi poly display list, or 0
        dh 0x0900       // 0x000C: offset to part 0x02 in player struct
        dh 0x0580       // 0x000E: offset to 1st set render mode command for high poly
        dh 0xFFFF       // 0x0010: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0012: offset to 3rd set render mode command for high poly, or -1
        dw OS.FALSE     // 0x0014: initialized flag, low poly
        dw lo_default   // 0x0018: pointer to default custom lo poly display list, or 0
        dw lo_alpha     // 0x001C: pointer to alpha custom lo poly display list, or 0
        dh 0x0900       // 0x0020: offset to part 0x02 in player struct
        dh 0x0388       // 0x0022: offset to 1st set render mode command for high poly
        dh 0x04B0       // 0x0024: offset to 2nd set render mode command for high poly, or -1
        dh 0xFFFF       // 0x0026: offset to 3rd set render mode command for high poly, or -1
        hi_default:; create_custom_display_list(0xC4113878)
        hi_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA)
        lo_default:; create_custom_display_list(0xC4113878, RENDER_MODE_DEFAULT)
        lo_alpha:;   create_custom_display_list(RENDER_MODE_ALPHA, RENDER_MODE_ALPHA)
    }

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
        OS.patch_start(0x107B28, 0x80390548)
        j       override_env_color_._menu
        sw      t7, 0x0000(a1)              // original line 1
        _return_menu:
        OS.patch_end()

        // s8 = player struct

        _battle:
        li      t1, _return_battle
        b       _start
        addiu   a2, a2, 0x1388              // original line 2

        _menu:
        li      t1, _return_menu
        addiu   a2, a2, 0x29E0              // original line 2

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

        andi    t2, t2, 0x00FF              // t2 = alpha value
        lli     t9, 0x00FF                  // t9 = fully opaque
        bnel    t2, t9, _fix_parts          // if not fully opaque, use custom display list
        lli     t6, 0x0020                  // t6 = offset to custom display list: 0x20 = override display list command

        _fix_parts:
        lw      t2, 0x0008(s8)              // t2 = char_id
        lli     t9, Character.id.FALCON
        li      v0, custom_display_lists_struct_falcon
        beq     t2, t9, _fix                // skip to fixing FALCON
        lli     t9, Character.id.JFALCON
        beq     t2, t9, _fix                // skip to fixing JFALCON
        lli     t9, Character.id.GND
        li      v0, custom_display_lists_struct_gnd
        beq     t2, t9, _fix                // skip to fixing GND
        lli     t9, Character.id.WARIO
        li      v0, custom_display_lists_struct_wario
        beq     t2, t9, _fix                // skip to fixing WARIO
        lli     t9, Character.id.SHEIK
        li      v0, custom_display_lists_struct_sheik
        beq     t2, t9, _fix                // skip to fixing SHEIK
        lli     t9, Character.id.YLINK
        li      v0, custom_display_lists_struct_ylink
        beq     t2, t9, _fix_ylink          // skip to fixing YLINK
        lli     t9, Character.id.SSONIC
        li      v0, custom_display_lists_struct_ssonic_0
        beq     t2, t9, _fix_ssonic         // skip to fixing SSONIC
        lli     t9, Character.id.KIRBY
        beq     t2, t9, _fix_kirby          // skip to fixing KIRBY
        lli     t9, Character.id.JKIRBY
        beq     t2, t9, _fix_kirby          // skip to fixing JKIRBY
        nop
        b       _return                     // skip if no fixing necessary
        nop

        _fix_ssonic:
        // Check which part is being displayed
        lbu     t2, 0x098D(s8)              // t2 = ssonic head part_id
        beqz    t2, _fix                    // if 0, then already have correct v0
        nop                                 // otherwise, get other struct
        li      v0, custom_display_lists_struct_ssonic_1
        b       _fix
        nop

        _fix_ylink:
        // Check which part is being displayed
        lbu     t2, 0x098B(s8)              // t2 = link sword part_id
        beqz    t2, _fix                    // if 0, then already have correct v0
        nop                                 // otherwise, don't fix
        b       _return
        nop

        _fix_kirby:
        lbu     t2, 0x0981(s8)              // t2 = kirby_hat_id
        lli     t3, Character.kirby_hat_id.DK
        li      v0, custom_display_lists_struct_dk_hat
        beq     t2, t3, _fix                // if copying DK, need to fix
        lli     t3, Character.kirby_hat_id.PIKACHU
        li      v0, custom_display_lists_struct_pika_hat
        beq     t2, t3, _fix                // if copying Pikachu, need to fix
        lli     t3, 0x001E                  // t3 = Sheik hat ID
        li      v0, custom_display_lists_struct_sheik_hat
        beq     t2, t3, _fix                // if copying Sheik, need to fix
        lli     t3, 0x001D                  // t3 = Sonic hat ID
        li      v0, custom_display_lists_struct_sonic_hat
        bne     t2, t3, _return             // if not copying Sonic, skip
        nop                                 // otherwise, need to fix

        _fix:
        // v0 = custom_display_lists_struct
        lbu     t2, 0x000E(s8)              // t2 = 1 if high poly, 2 if low poly
        sltiu   t2, t2, 0x0002              // t2 = 1 if high poly, 0 if low poly
        beqzl   t2, pc() + 8                // if low poly, get low poly default custom display list address
        addiu   v0, v0, 0x0014              // v0 = custom_display_lists_struct offset to low poly info
        lw      t8, 0x0004(v0)              // t8 = default custom display list address
        beqz    t8, _return                 // skip if nothing to fix
        lhu     t4, 0x000C(v0)              // t4 = offset to part pointer
        addu    t4, s8, t4                  // t4 = part pointer address
        lw      t2, 0x0000(t4)              // t2 = part address
        lw      t3, 0x0050(t2)              // t3 = part display list
        beqz    t3, _return                 // if original part is hidden, skip
        lw      t7, 0x0000(v0)              // t7 = initialized flag
        bnez    t7, _skip_init              // if already initialized, skip setup
        lli     t7, OS.TRUE                 // t7 = OS.TRUE
        beq     t3, t8, _skip_init          // if display list is the default custom display list, skip (probably loaded a variant)
        sw      t7, 0x0000(v0)              // set initialized
        lw      t9, 0x0008(v0)              // t9 = alpha custom display list address
        beq     t3, t9, _skip_init          // if display list is the alpha custom display list, skip (probably loaded a variant)
        lui     t0, 0xDF00                  // t0 = DF000000 (end display list)
        sw      t3, 0x0004(t8)              // save original part display list start to default custom display list
        sw      t3, 0x0004(t9)              // save original part display list start to alpha custom display list

        lh      t4, 0x000E(v0)              // t4 = offset to 1st set render mode command
        addu    t4, t3, t4                  // t4 = 1st set render mode command address
        sw      t0, 0x0000(t4)              // put end display list command here, overwriting set render mode command
        sw      r0, 0x0004(t4)              // ~
        addiu   t4, t4, 0x0008              // t4 = start of 2nd display list part
        sw      t4, 0x0014(t8)              // save original part display list part 2 start to default custom display list
        sw      t4, 0x0014(t9)              // save original part display list part 2 start to alpha custom display list

        lh      t4, 0x0010(v0)              // t4 = offset to 2nd set render mode command
        bltz    t4, _skip_init              // if not relevant, skip
        addu    t4, t3, t4                  // t4 = 2nd set render mode command address
        sw      t0, 0x0000(t4)              // put end display list command here, overwriting set render mode command
        sw      r0, 0x0004(t4)              // ~
        addiu   t4, t4, 0x0008              // t4 = start of 3rd display list part
        sw      t4, 0x0024(t8)              // save original part display list part 3 start to default custom display list
        sw      t4, 0x0024(t9)              // save original part display list part 3 start to alpha custom display list

        lh      t4, 0x0012(v0)              // t4 = offset to 3rd set render mode command
        bltz    t4, _skip_init              // if not relevant, skip
        addu    t4, t3, t4                  // t4 = 3rd set render mode command address
        sw      t0, 0x0000(t4)              // put end display list command here, overwriting set render mode command
        sw      r0, 0x0004(t4)              // ~
        addiu   t4, t4, 0x0008              // t4 = start of 4th display list part
        sw      t4, 0x0034(t8)              // save original part display list part 4 start to default custom display list
        sw      t4, 0x0034(t9)              // save original part display list part 4 start to alpha custom display list

        _skip_init:
        // t8 = default custom display list address
        bnezl   t6, pc() + 8                // if in alpha mode, use alpha custom display list
        lw      t8, 0x0008(v0)              // t8 = alpha custom display list address
        sw      t8, 0x0050(t2)              // save custom display list address as new part display list pointer

        _return:
        jr      t1                          // return
        nop
    }

    // @ Description
    // Resets custom display lists during main character file loading.
    scope reset_custom_display_lists_: {
        OS.patch_start(0x52EA4, 0x800D76A4)
        sw      ra, 0x001C(sp)              // original line 3
        jal     reset_custom_display_lists_
        addu    s0, s0, t6                  // original line 1
        OS.patch_end()

        // a0 = char_id

        li      a1, custom_display_lists_struct_falcon
        lli     a2, Character.id.FALCON
        beq     a0, a2, _clear              // if FALCON, clear FALCON's custom display lists
        nop
        lli     a2, Character.id.JFALCON
        beq     a0, a2, _clear              // if JFALCON, clear JFALCON's custom display lists
        nop
        li      a1, custom_display_lists_struct_gnd
        lli     a2, Character.id.GND
        beq     a0, a2, _clear              // if GND, clear GND's custom display lists
        nop
        li      a1, custom_display_lists_struct_wario
        lli     a2, Character.id.WARIO
        beq     a0, a2, _clear              // if WARIO, clear WARIO's custom display lists
        nop
        li      a1, custom_display_lists_struct_sheik
        lli     a2, Character.id.SHEIK
        beq     a0, a2, _clear              // if SHEIK, clear SHEIK's custom display lists
        nop
        li      a1, custom_display_lists_struct_ylink
        lli     a2, Character.id.YLINK
        beq     a0, a2, _clear              // if YLINK, clear YLINK's custom display lists
        nop
        li      a1, custom_display_lists_struct_ssonic_0
        lli     a2, Character.id.SSONIC
        beq     a0, a2, _clear_ssonic       // if SSONIC, clear SSONIC's custom display lists
        nop
        li      a1, custom_display_lists_struct_dk_hat
        lli     a2, Character.id.KIRBY
        beq     a0, a2, _clear_kirby        // if KIRBY, clear KIRBY's custom display lists
        nop
        lli     a2, Character.id.JKIRBY
        beq     a0, a2, _clear_kirby        // if JKIRBY, clear JKIRBY's custom display lists
        nop
        b       _end                        // otherwise, skip
        nop

        _clear_ssonic:
        // clear extra display lists for Super Sonic
        // normal head
        sw      r0, 0x0000(a1)              // clear high poly initialized flag
        sw      r0, 0x0014(a1)              // clear low poly initialized flag

        // damage head
        li      a1, custom_display_lists_struct_ssonic_1
        b       _clear
        nop

        _clear_kirby:
        // clear extra display lists for Kirby
        // kirby DK hat
        sw      r0, 0x0000(a1)              // clear high poly initialized flag
        sw      r0, 0x0014(a1)              // clear low poly initialized flag

        // kirby Pika hat
        li      a1, custom_display_lists_struct_pika_hat
        sw      r0, 0x0000(a1)              // clear high poly initialized flag
        sw      r0, 0x0014(a1)              // clear low poly initialized flag

        // kirby Sheik hat
        li      a1, custom_display_lists_struct_sheik_hat
        sw      r0, 0x0000(a1)              // clear high poly initialized flag
        sw      r0, 0x0014(a1)              // clear low poly initialized flag

        // kirby Sonic hat
        li      a1, custom_display_lists_struct_sonic_hat

        _clear:
        sw      r0, 0x0000(a1)              // clear high poly initialized flag
        sw      r0, 0x0014(a1)              // clear low poly initialized flag

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

    // @ Description
    // Populates our override table when initializing the character based on state.
    scope initialize_override_table_: {
        OS.patch_start(0x534BC, 0x800D7CBC)
        jal     initialize_override_table_
        swc1    f0, 0x0048(t3)              // original line 2
        OS.patch_end()

        // v1 = player struct
        li      t4, override_table          // t4 = override_table
        lbu     t9, 0x000D(v1)              // t9 = port
        sll     t9, t9, 0x0002              // t9 = index = port * 4
        addu    t4, t4, t9                  // t4 = &override[index]
        lw      t9, 0x0020(t4)              // t9 = state
        beqzl   t9, _return                 // if in NORMAL state, clear override
        lli     t9, 0x0000                  // t9 = 0 (no override)

        li      t3, Global.current_screen
        lbu     t3, 0x0000(t3)              // t3 = current screen
        lli     t9, 0x0077                  // t9 = the screen_id assigned to the bonus 3 and multiman mode screens in SinglePlayerModes.asm
        beq     t3, t9, _override           // if on the bonus 3 and multiman mode screens, keep override value
        lw      t9, 0x0020(t4)              // t9 = state
        sltiu   t3, t3, 0x003C              // t3 = 1 if not 0x3C (how to play screen id) or 0x3D (demo vs battle screen id)
        beqzl   t3, _return                 // if on how to play or demo vs battle screen, clear override
        lli     t9, 0x0000                  // t9 = 0 (no override)

        _override:
        lli     t3, state.NONE              // t3 = NONE
        beql    t9, t3, _return             // if in NONE state, use NONE override value
        addiu   t9, r0, -0x00FF             // t9 = 0xFFFFFF00

        lli     t3, state.DARK              // t3 = DARK
        beql    t9, t3, _return             // if in DARK state, use DARK override value
        addiu   t9, r0, 0x00FF              // t9 = 0x000000FF

        // if we're here, the value is Cloaked, and I don't know how to do that yet!
        addiu   t9, r0, -0x00F0

        _return:
        sw      t9, 0x0000(t4)              // initialize size multiplier
        jr      ra
        addiu   t4, v1, 0x00F8              // original line 1
    }
}

} // __CHAR_ENV_COLOR__
