// VsStats.asm
if !{defined __VSSTATS__} {
define __VSSTATS__()
print "included VsStats.asm\n"

// @ Description
// This file enables viewing match stats on the results screen.

include "Data.asm"
include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"
include "Toggles.asm"
include "VsCombo.asm"

scope VsStats {
    // @ Description
    // Boolean controlling stats screen visibility
    toggle_match_stats:
    db      0x00

    // @ Description
    // Player count
    player_count:
    db      0x00

    // @ Description
    // Boolean indicating if the current row should be striped
    stripe_on:
    db      0x00

    // @ Description
    // Strings used
    press_a:; db "PRESS A FOR MATCH STATS", 0x00
    p1:; db "P1", 0x00
    p2:; db "P2", 0x00
    p3:; db "P3", 0x00
    p4:; db "P4", 0x00
    damage_stats:; db "DAMAGE STATS", 0x00
    damage_dealt_to:; db "DEALT TO", 0x00
    total_damage_given:; db "TOTAL DEALT", 0x00
    total_damage_taken:; db "TOTAL TAKEN", 0x00
    highest_damage:; db "HIGHEST TAKEN", 0x00
    combo_stats:; db "COMBO STATS", 0x00
    max_combo_hits_vs:; db "LONGEST COMBO VS", 0x00
    max_combo_hits_taken:; db "MAX HITS TAKEN", 0x00
    max_combo_damage_taken:; db "MAX DAMAGE TAKEN", 0x00
    dash:; db "-", 0x00
    press_b:; db ":BACK", 0x00
    OS.align(4)

    // @ Description
    // This macro creates a stats struct for the given port
    macro stats_struct(port) {
        stats_struct_p{port}: {
            dw      0x00                                 // 0x0000 = player_port_active
            dw      0x00                                 // 0x0004 = damage_dealt_to_p1
            dw      0x00                                 // 0x0008 = damage_dealt_to_p2
            dw      0x00                                 // 0x000C = damage_dealt_to_p3
            dw      0x00                                 // 0x0010 = damage_dealt_to_p4
            dw      0x00                                 // 0x0014 = total_damage_taken
            dw      0x00                                 // 0x0018 = total_damage_given
            dw      0x00                                 // 0x001C = highest_damage
        }
    }

    // Create stats structs
    stats_struct(1)
    stats_struct(2)
    stats_struct(3)
    stats_struct(4)

    // @ Description
    // This initializes the stats struct for the match for the given port
    macro initialize_stats_struct(port) {
        li      t2, stats_struct_p{port}                 // t2 = stats_struct_p{port}
        sw      r0, 0x0000(t2)                           // player_port_active = 0
        sw      r0, 0x0004(t2)                           // damage_dealt_to_p1 = 0
        sw      r0, 0x0008(t2)                           // damage_dealt_to_p2 = 0
        sw      r0, 0x000C(t2)                           // damage_dealt_to_p3 = 0
        sw      r0, 0x0010(t2)                           // damage_dealt_to_p4 = 0
        sw      r0, 0x0014(t2)                           // total_damage_taken = 0
        sw      r0, 0x0018(t2)                           // total_damage_given = 0
        sw      r0, 0x001C(t2)                           // highest_damage = 0
    }

    // @ Description
    // This macro checks if the given port is a man/cpu and increments player count
    // accordingly. It then stores if the player is active in the stats struct.
    macro port_check(port, next) {
        // t0 = player_count address
        // t1 = player_count
        li      t2, Global.vs.p{port}                    // address of player struct
        lbu     t3, 0x0002(t2)                           // t3 = player type (0 = man, 1 = cpu, 2 = n/a)
        sltiu   t4, t3, 0x0002                           // t4 = 1 for man/cpu, 0 for n/a
        li      t5, stats_struct_p{port}                 // t5 = stats struct address
        sw      t4, 0x0000(t5)                           // store if this is an active port
        beqz    t4, {next}                               // if (p3 = man/cpu) then player_count++
        nop
        addu    t1, t1, t4                               // player_count++
        sb      t1, 0x0000(t0)                           // store player count
    }

    // @ Description
    // Simple helper to indent the line
    macro indent(amount) {
        addiu   t7, t7, {amount}                         // indents X coord
    }

    // @ Description
    // Simple helper to unindent the line
    macro unindent(amount) {
        addiu   t7, t7, -{amount}                        // unindents X coord
    }

    // @ Description
    // This macro draws a header (no player stats)
    macro draw_header(string, spacer) {
        addiu   t8, {spacer}                             // increment Y coord by specified spacer
        or      a0, r0, t7                               // a0 - ulx
        or      a1, r0, t8                               // a1 - uly
        li      a2, {string}                             // a2 - address of string
        jal     Overlay.draw_string_                     // draw
        nop
        addiu   t8, 000010                               // increment Y coord
    }

    // @ Description
    // This macro draws a line to act as an underline
    macro draw_underline(width) {
        lli     a0, Color.WHITE                          // a0 = color (white)
        jal     Overlay.set_color_                       // set fill color
        nop
        or      a0, r0, t7                               // a0 - ulx
        or      a1, r0, t8                               // a1 - uly
        lli     a2, {width}                              // a2 - width
        lli     a3, 0x0001                               // a3 - line height
        jal     Overlay.draw_rectangle_                  // draw line
        nop
        addiu   t8, 000004                               // increment Y coord
    }

    // @ Description
    // This macro draws a single player stat
    macro draw_line_stat(table, offset, port, urx) {
        // t6 = port of stat to skip
        lw      t0, 0x000(t{port})                       // t0 = 0 if passed in port is not active (not a cpu/man)
        beqz    t0, _end_draw_line_stat_{#}              // skip drawing the stat if port is not active
        nop                                              // ~
        li      t0, {table}{port}                        // t0 = address of table for port
        lw      a0, {offset}(t0)                         // a0 = value of stat
        li      t0, {port}                               // t0 = port
        bne     t6, t0, _convert_stat_{#}                // if (stat not applicable to port) then display a dash
        nop                                              // ~
        li      v0, dash                                 // v0 = address of dash string
        b       _draw_line_stat_{#}                      // skip to drawing stat
        nop                                              // ~
        _convert_stat_{#}:
        jal     String.itoa_                             // v0 = address of string (converted stat value)
        nop
        _draw_line_stat_{#}:
        lli     a0, {urx}                                // a0 - urx
        or      a1, r0, t8                               // a1 - ury
        move    a2, v0                                   // a2 - address of string
        jal     Overlay.draw_string_urx_                 // draw
        nop
        _end_draw_line_stat_{#}:
    }

    // @ Description
    // This macro draws a stat line
    macro draw_line(string, table, offset, na_port) {
        lbu     t6, 0x0000(t9)                           // t6 = stripe_on
        beqz    t6, _turn_on_stripe_{#}                  // if (stripe_on is 0) then don't strip this row
        nop                                              // otherwise, stripe this row
        lli     a0, Color.GREY                           // a0 = gray
        jal     Overlay.set_color_                       // set fill color
        nop
        lli     a0, 000023                               // a0 = ulx
        addiu   a1, t8, -0x0002                          // a1 = uly, adjusted
        lli     a2, 266                                  // a2 - width
        lli     a3, 0x0001                               // a3 - line height
        jal     Overlay.draw_rectangle_                  // draw line
        nop
        lli     a0, 0x190F                               // a0 = 19XX logo dark color
        jal     Overlay.set_color_                       // set fill color
        nop
        lli     a0, 000023                               // a0 = ulx
        addiu   a1, t8, -0x0001                          // a1 = uly, adjusted
        lli     a2, 266                                  // a2 - width
        lli     a3, 0x0009                               // a3 - line height
        jal     Overlay.draw_rectangle_                  // draw line
        nop
        lli     a0, Color.GREY
        jal     Overlay.set_color_                       // set fill color
        nop
        lli     a0, 000023                               // a0 = ulx
        addiu   a1, t8, 0x0008                           // a1 = uly, adjusted
        lli     a2, 266                                  // a2 - width
        lli     a3, 0x0001                               // a3 - line height
        jal     Overlay.draw_rectangle_                  // draw line
        nop
        lli     t6, 0x0000                               // t6 = 0 (stripe off)
        b       _draw_line_text_{#}                      // jump to drawing the line
        nop

        _turn_on_stripe_{#}:
        lli     t6, 0x0001                               // t6 = 1 (stripe on)

        _draw_line_text_{#}:
        sb      t6, 0x0000(t9)                           // store stripe on/off value for next row
        or      a0, r0, t7                               // a0 - ulx
        or      a1, r0, t8                               // a1 - uly
        li      a2, {string}                             // a2 - address of string
        jal     Overlay.draw_string_                     // draw
        nop

        lli     t6, {na_port}                            // t6 = port whose stat is not relevant for this row
        // draw the stat for each port:
        draw_line_stat({table}, {offset}, 1, 184)
        draw_line_stat({table}, {offset}, 2, 219)
        draw_line_stat({table}, {offset}, 3, 254)
        draw_line_stat({table}, {offset}, 4, 289)
        addiu   t8, 000011                               // increment Y coord
    }

    // @ Description
    // This macro collects stats for the given port at the end of a match
    macro collect_stats(port, offset) {
        li      t0, Global.vs.p{port}                    // t0 = match player struct

        // damage taken:
        lw      t5, 0x0038(t0)                           // t3 = total damage taken during match
        sw      t5, 0x0014(t{port})                      // store total damage taken
        lw      t5, 0x003C(t0)                           // t3 = total damage taken during match from p1
        sw      t5, {offset}(t1)                         // store total damage taken from p1
        lw      t5, 0x0040(t0)                           // t3 = total damage taken during match from p2
        sw      t5, {offset}(t2)                         // store total damage taken from p2
        lw      t5, 0x0044(t0)                           // t3 = total damage taken during match from p3
        sw      t5, {offset}(t3)                         // store total damage taken from p3
        lw      t5, 0x0048(t0)                           // t3 = total damage taken during match from p4
        sw      t5, {offset}(t4)                         // store total damage taken from p4

        // total damage given:
        lw      t5, 0x0034(t0)                           // t3 = total damage given during match
        sw      t5, 0x0018(t{port})                      // store total damage given
    }

    // @ Description
    // This macro collects stats for the given port during a match
    macro collect_stats_midmatch(port) {
        li      t0, stats_struct_p{port}                 // t0 = stats_struct_p{port} address
        lw      t1, 0x001C(t0)                           // t1 = highest_damage
        li      t2, Global.vs.p{port}                    // t2 = match player struct address
        lw      t3, 0x004C(t2)                           // t3 = current damage
        sltu    t4, t1, t3                               // if (current damage > highest damage) then store new highest damage
        beqz    t4, _end_collect_{port}                  // ~
        nop
        sw      t3, 0x001C(t0)                           // store new highest damage
        _end_collect_{port}:
    }

    // @ Description
    // This macro draws the P1, P2, etc. header for the given port
    macro draw_port_header(port, ulx) {
        lw      t6, 0x0000(t{port})                      // t6 = 1 if this port is active
        beqz    t6, _draw_port_header_end_{#}            // skip drawing if port is inactive
        nop
        lli     a0, {ulx}                                // a0 - x
        lli     a1, 000016                               // a1 - uly
        li      a2, p{port}                              // a2 - address of string
        jal     Overlay.draw_string_                     // draw
        nop
        lli     a0, {ulx}                                // a0 - x
        lli     a1, 000026                               // a1 - uly
        lli     a2, 000024                               // a2 - width
        lli     a3, 0x0001                               // a3 - line height
        jal     Overlay.draw_rectangle_                  // draw line
        nop
        _draw_port_header_end_{#}:
    }

    // @ Description
    // Shows the menu on the Results page (called by Overlay.asm)
    scope run_results_: {
        OS.save_registers()

        li      t0, toggle_match_stats                   // t0 = address of toggle_match_stats
        lbu     t0, 0x0000(t0)                           // t0 = toggle_match_stats
        bne     t0, r0, _match_status_up                 // if (match stats displayed) skip to _match_status_up
        nop                                              // ~

        // tell the user they can bring up the custom menu
        lli     a0, 000160                               // a0 - x
        lli     a1, 000220                               // a1 - uly
        li      a2, press_a                              // a2 - address of string
        jal     Overlay.draw_centered_str_               // draw custom menu instructions
        nop

        lli     a0, 000112                               // a0 - ulx
        lli     a1, 000217                               // a1 - uly
        li      a2, Data.a_button_info                   // a2 - a button texture address
        jal     Overlay.draw_texture_                    // draw a button texture
        nop

        // check for a press
        lli     a0, Joypad.A                             // a0 - button_mask
        lli     a1, 000069                               // a1 - whatever you like!
        lli     a2, Joypad.PRESSED                       // a2 - type
        jal     Joypad.check_buttons_all_                // v0 - bool a_pressed
        nop
        beqz    v0, _end                                 // if (!a_pressed), end
        nop
        lli     a0, FGM.menu.TOGGLE                      // a0 - fgm_id
        jal     FGM.play_                                // play menu toggle sound
        nop
        li      t0, toggle_match_stats                   // t0 = toggle_match_stats
        lli     t1, OS.TRUE                              // t1 = true
        sb      t1, 0x0000(t0)                           // toggle match stats = true

        b       _end                                     // skip to _end
        nop                                              // ~

        _match_status_up:
        // draw background
        lli     a0, Color.low.MENU_BG
        jal     Overlay.set_color_                       // set fill color
        nop
        lli     a0, 000001                               // a0 - ulx
        lli     a1, 000001                               // a1 - uly
        li      a2, 000320                               // a2 - width
        lli     a3, 000240                               // a3 - height
        jal     Overlay.draw_rectangle_                  // draw background rectangle
        nop

        li      t1, stats_struct_p1                      // t1 = stats_struct_p1 address
        li      t2, stats_struct_p2                      // t2 = stats_struct_p2 address
        li      t3, stats_struct_p3                      // t3 = stats_struct_p3 address
        li      t4, stats_struct_p4                      // t4 = stats_struct_p4 address

        // Draw table
        lli     a0, Color.WHITE                          // a0 = color (white)
        jal     Overlay.set_color_                       // set fill color
        nop
        draw_port_header(1, 160)                         // Draw P1 header
        draw_port_header(2, 195)                         // Draw P2 header
        draw_port_header(3, 230)                         // Draw P3 header
        draw_port_header(4, 265)                         // Draw P4 header

        collect_stats(1, 0x0004)                         // collect stats for port 1
        collect_stats(2, 0x0008)                         // collect stats for port 2
        collect_stats(3, 0x000C)                         // collect stats for port 3
        collect_stats(4, 0x0010)                         // collect stats for port 4

        // Tell the player how to go back
        lli     a0, 000024                               // a0 = ulx
        lli     a1, 000013                               // a1 = uly
        li      a2, Data.b_button_info                   // a2 = b button texture address
        jal     Overlay.draw_texture_                    // draw b button texture
        nop

        lli     a0, 000036                               // a0 = ulx
        lli     a1, 000016                               // a1 = uly
        li      a2, press_b                              // a2 = press b text address
        jal     Overlay.draw_string_                     // draw press b text
        nop

        // Draw lines
        lli     t7, 000024                               // t7 = X coord
        lli     t8, 000030                               // t8 = Y coord
        li      t9, stripe_on                            // t9 = stripe_on
        lli     t6, 0x0000                               // t6 = 0
        sb      t6, 0x0000(t9)                           // set stripe_on to 0 for first row always
        draw_header(damage_stats, 5)
        draw_underline(96)
        draw_header(damage_dealt_to, 0)
        indent(8)
        lw      t0, 0x0000(t1)                           // t0 = 0 if port 1 is inactive
        beqz    t0, _damage_taken_p2                     // if inactive, then skip drawing the line
        nop
        draw_line(p1, stats_struct_p, 0x0004, 1)
        _damage_taken_p2:
        lw      t0, 0x0000(t2)                           // t0 = 0 if port 2 is inactive
        beqz    t0, _damage_taken_p3                     // if inactive, then skip drawing the line
        nop
        draw_line(p2, stats_struct_p, 0x0008, 2)
        _damage_taken_p3:
        lw      t0, 0x0000(t3)                           // t0 = 0 if port 3 is inactive
        beqz    t0, _damage_taken_p4                     // if inactive, then skip drawing the line
        nop
        draw_line(p3, stats_struct_p, 0x000C, 3)
        _damage_taken_p4:
        lw      t0, 0x0000(t4)                           // t0 = 0 if port 4 is inactive
        beqz    t0, _damage_taken_end                    // if inactive, then skip drawing the line
        nop
        draw_line(p4, stats_struct_p, 0x0010, 4)
        _damage_taken_end:
        unindent(8)
        draw_line(total_damage_given, stats_struct_p, 0x0018, 0)
        draw_line(total_damage_taken, stats_struct_p, 0x0014, 0)
        draw_line(highest_damage, stats_struct_p, 0x001C, 0)
        b       _combo_stats_on_check
        nop

        _combo_stats_off:
        b       _b_check                                 // skip drawing combo stats if combo meter toggle is off
        nop

        _combo_stats_on_check:
        // If combo meter is off, skip to _end and don't draw combo stats section
        Toggles.guard(Toggles.entry_vs_mode_combo_meter, _combo_stats_off)
        draw_header(combo_stats, 5)
        draw_underline(88)
        draw_header(max_combo_hits_vs, 0)
        indent(8)
        lw      t0, 0x0000(t1)                           // t0 = 0 if port 1 is inactive
        beqz    t0, _combo_vs_p2                         // if inactive, then skip drawing the line
        nop
        draw_line(p1, VsCombo.combo_struct_p, 0x0024, 1)
        _combo_vs_p2:
        lw      t0, 0x0000(t2)                           // t0 = 0 if port 2 is inactive
        beqz    t0, _combo_vs_p3                         // if inactive, then skip drawing the line
        nop
        draw_line(p2, VsCombo.combo_struct_p, 0x0028, 2)
        _combo_vs_p3:
        lw      t0, 0x0000(t3)                           // t0 = 0 if port 3 is inactive
        beqz    t0, _combo_vs_p4                         // if inactive, then skip drawing the line
        nop
        draw_line(p3, VsCombo.combo_struct_p, 0x002C, 3)
        _combo_vs_p4:
        lw      t0, 0x0000(t4)                           // t0 = 0 if port 4 is inactive
        beqz    t0, _combo_vs_end                        // if inactive, then skip drawing the line
        nop
        draw_line(p4, VsCombo.combo_struct_p, 0x0030, 4)
        _combo_vs_end:
        unindent(8)
        draw_line(max_combo_hits_taken, VsCombo.combo_struct_p, 0x0004, 0)
        draw_line(max_combo_damage_taken, VsCombo.combo_struct_p, 0x0008, 0)

        // check for b press
        _b_check:
        lli     a0, Joypad.B                             // a0 - button_mask
        lli     a1, 000069                               // a1 - whatever you like!
        lli     a2, Joypad.PRESSED                       // a2 - type
        jal     Joypad.check_buttons_all_                // v0 - bool b_pressed
        nop
        beqz    v0, _end                                 // if (!b_pressed), end
        nop
        lli     a0, FGM.menu.TOGGLE                      // a0 - fgm_id
        jal     FGM.play_                                // play menu toggle sound
        nop
        li      t0, toggle_match_stats                   // t0 = toggle_match_stats
        lli     t1, OS.FALSE                             // ~
        sb      t1, 0x0000(t0)                           // toggle match stats = false

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Collects stats during a match (called by Overlay.asm)
    scope run_collect_: {
        OS.save_registers()

        li      t0, player_count                         // t0 = number of players
        lbu     t1, 0x0000(t0)                           // t1 = player_count
        bnez    t1, _collect                             // if (player_count > 0) skip setup
        nop

        // Sets up the stats structs. This is only run once per match.
        _setup:
        // Reset variables from previous match
        initialize_stats_struct(1)
        initialize_stats_struct(2)
        initialize_stats_struct(3)
        initialize_stats_struct(4)
        li      t2, toggle_match_stats                   // t2 = toggle_match_stats
        lli     t3, OS.FALSE                             // ~
        sb      t3, 0x0000(t2)                           // toggle match stats = false

        _p1:
        port_check(1, _p2)                               // check port 1

        _p2:
        port_check(2, _p3)                               // check port 2

        _p3:
        port_check(3, _p4)                               // check port 3

        _p4:
        port_check(4, _collect)                          // check port 4

        _collect:
        collect_stats_midmatch(1)                        // collect midmatch stats for p1
        collect_stats_midmatch(2)                        // collect midmatch stats for p2
        collect_stats_midmatch(3)                        // collect midmatch stats for p3
        collect_stats_midmatch(4)                        // collect midmatch stats for p4

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }
}

} // __VSSTATS__
