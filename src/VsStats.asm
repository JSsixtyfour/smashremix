// VsStats.asm
if !{defined __VSSTATS__} {
define __VSSTATS__()
print "included VsStats.asm\n"

// @ Description
// This file enables viewing match stats on the results screen.

include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "OS.asm"
include "String.asm"
include "Toggles.asm"
include "ComboMeter.asm"

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
    press_a:; db "Press     for Match Stats", 0x00
    p1:; db "1P", 0x00
    p2:; db "2P", 0x00
    p3:; db "3P", 0x00
    p4:; db "4P", 0x00
    damage_stats:; db "Damage Stats", 0x00
    damage_dealt_to:; db "Dealt to", 0x00
    total_damage_given:; db "Total Dealt", 0x00
    total_damage_taken:; db "Total Taken", 0x00
    highest_damage:; db "Highest Taken", 0x00
    combo_stats:; db "Combo Stats", 0x00
    max_combo_hits_vs:; db "Longest Combo VS", 0x00
    max_combo_hits_taken:; db "Max Hits Taken", 0x00
    max_combo_damage_taken:; db "Max Damage Taken", 0x00
    dash:; db "-", 0x00
    press_b:; db ": Back", 0x00
    OS.align(4)

    // @ Description
    // Increases the available object heap space on the VS results screen.
    // This is necessary to support the stats being rendered.
    // Can probably reduce how much is added, but shouldn't hurt anything.
    OS.patch_start(0x1588E8, 0x80139748)
    dw      0x00004E20 + 0x10000                 // pad object heap space (0x00004E20 is original amount)
    OS.patch_end()

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
    constant STATS_STRUCT_SIZE(0x20)

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
    // This macro draws a line of the given width to act as an underline
    macro draw_underline(width) {
        jal     draw_underline_
        lli     a0, {width}
    }

    // @ Description
    // Draws an white line starting at a fixed left position
    // @ Arguments
    // a0 - width
    // a2 - y
    scope draw_underline_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a2, 0x0008(sp)              // ~

        or      s3, r0, a0                  // s3 = width
        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lli     s1, 24                      // s3 = ulx
        or      s2, r0, a2                  // s2 = uly
        lli     s4, 1                       // s4 = height
        addiu   s5, r0, -0x0001             // s5 = Color.high.WHITE
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha

        lw      a2, 0x0008(sp)              // restore registers
        addiu   a2, a2, 3                   // increment y
        lw      ra, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Draws a row with only a label
    // @ Arguments
    // label - address of the string to render
    macro draw_header(label) {
        draw_row({label}, 0, 0, 0, 0, -1, -1)
    }

    // @ Description
    // Draws a row
    // @ Arguments
    // label - address of the string to render
    // indent -
    // table - table of values
    // offset - offset of value in table of values
    // struct_size - size of the struct
    // port_to_skip - port to skip (0 - 3) when drawing the stats
    // ignore_port - ignore port - don't draw anything when this port is not active
    macro draw_row(label, indent, table, offset, struct_size, port_to_skip, ignore_port) {
        li      t4, {label}                 // t4 = address of label
        lli     t5, {indent}                // t5 = indent
        addiu   t6, r0, {ignore_port}       // t6 = ignore port
        li      a0, {table}                 // a0 = address of table
        addiu   a0, a0, {offset}            // a0 = address of value
        lli     a1, {struct_size}           // a1 = size of struct
        // a2 = y
        jal     draw_line_
        lli     a3, {port_to_skip}          // a3 = port to skip
    }

    // @ Description
    // This draws a line including the label and stats
    // @ Arguments
    // a0 - address of value
    // a1 - size of struct
    // a2 - ury
    // a3 - port to skip (0 - 3)
    // t4 - label address
    // t5 - indent amount for label
    // t6 - ignore port - don't do anything when this port is not active
    scope draw_line_: {
        li      t0, stats_struct_p1         // t0 = stats_struct_p1 address
        bltz    t6, _begin                  // if no ignore port (-1) then don't test for active port
        lli     t8, STATS_STRUCT_SIZE
        multu   t6, t8                      // otherwise, figure out the offset
        mflo    t6                          // t6 = offset to player struct for the ignore port
        addu    t6, t0, t6                  // t6 = player struct for the ignore port
        lw      t6, 0x0000(t6)              // t6 = 1 if this port is active
        bnez    t6, _begin                  // if the port is active, proceed
        nop                                 // otherwise, we'll abort
        jr      ra
        nop

        _begin:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      r0, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // save struct address
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // ~
        sw      a2, 0x001C(sp)              // ~
        sw      a3, 0x0020(sp)              // ~

        lli     t1, 184                     // t1 = start urx
        sw      t1, 0x0010(sp)              // save start urx

        mtc1    a2, f0                      // f0 = ury
        cvt.s.w f0, f0                      // ~
        swc1    f0, 0x0024(sp)              // save ury

        lw      a0, 0x0014(sp)              // a0 = address of value
        beqz    a0, _draw_header            // if no stats need to be drawn, skip striping
        nop
        li      t1, stripe_on               // t1 = stripe_on
        lbu     t2, 0x0000(t1)              // t2 = 1 if stripe should be rendered
        xori    t3, t2, 0x0001              // 0 -> 1 or 1 -> 0 (flip bool)
        beqz    t2, _draw_header
        sb      t3, 0x0000(t1)              // save flipped value

        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lli     s1, 23                      // s3 = ulx
        addiu   s2, a2, 0                   // s2 = uly
        lli     s3, 266                     // s3 = width
        lli     s4, 10                      // s4 = height
        li      s5, 0x40407040              // s5 = less transparent than overlay
        jal     Render.draw_rectangle_
        lli     s6, OS.TRUE                 // s6 = enable_alpha

        _draw_header:
        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        or      a2, r0, t4                  // a2 = label string address
        lli     a3, 0x0000                  // a3 = Render.NOOP
        lli     t0, 24                      // t0 = ulx
        addu    t0, t0, t5                  // t0 = ulx, indented (maybe)
        mtc1    t0, f0                      // f0 = ulx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lw      s2, 0x0024(sp)              // s2 = uly
        addiu   s3, r0, -0x0001             // s3 = color (Color.high.WHITE)
        lui     s4, 0x3F50                  // s4 = scale
        lli     s5, Render.alignment.LEFT   // s5 = alignment
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, OS.FALSE                // t8 = blur

        lw      a0, 0x0014(sp)              // a0 = address of value
        beqz    a0, _return                 // if nothing needs to be drawn, return
        lw      t0, 0x000C(sp)              // t0 = struct address

        _loop:
        lw      t1, 0x0000(t0)              // t1 = 1 if this port is active
        beqz    t1, _end                    // skip if this port is not active
        nop

        // draw stat
        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lw      a2, 0x0014(sp)              // a2 = value address
        lli     a3, 0x0000                  // a3 = Render.NOOP
        lw      t0, 0x0010(sp)              // t0 = urx
        mtc1    t0, f0                      // f0 = urx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = urx
        addiu   t0, t0, 35                  // t0 = next ulx
        sw      t0, 0x0010(sp)              // save next ulx
        lw      s2, 0x0024(sp)              // s2 = ury
        addiu   s3, r0, -0x0001             // s3 = color (Color.high.WHITE)
        lui     s4, 0x3F50                  // s4 = scale
        lw      t0, 0x0008(sp)              // t0 = port
        lw      t1, 0x0020(sp)              // t1 = port to skip
        bne     t0, t1, _draw               // if not skipping port, ready to draw
        lli     s6, Render.string_type.NUMBER // s6 = type

        // otherwise we have to draw a dash
        lli     s6, Render.string_type.TEXT // s6 = type
        li      a2, dash                    // a2 = dash string address

        _draw:
        lli     t8, OS.FALSE                // t8 = blur
        jal     Render.draw_string_
        lli     s5, Render.alignment.RIGHT  // s5 = alignment

        _end:
        lw      t2, 0x0008(sp)              // t2 = port (0 - 3)
        addiu   t2, t2, 0x0001              // t2++
        sw      t2, 0x0008(sp)              // save port
        sltiu   t1, t2, 0x0004              // t1 = 1 if not finished looping
        beqz    t1, _return                 // return if finished looping - otherwise, move to next struct and loop
        lw      t0, 0x000C(sp)              // t0 = stats struct of current port
        addiu   t0, t0, STATS_STRUCT_SIZE   // t0 = stats struct of next port
        sw      t0, 0x000C(sp)              // save stats struct of current port
        lw      t2, 0x0014(sp)              // t2 = value address
        lw      t1, 0x0018(sp)              // t1 = size of struct
        addu    t2, t2, t1                  // t2 = next value address
        b       _loop
        sw      t2, 0x0014(sp)              // save next value address

        _return:
        lw      a2, 0x001C(sp)              // restore registers
        addiu   a2, a2, 11                  // increment y
        lw      ra, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
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
    // This draws the 1P, 2P, etc. headers
    scope draw_port_headers_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      r0, 0x0008(sp)              // ~

        li      t0, stats_struct_p1         // t0 = stats_struct_p1 address
        sw      t0, 0x000C(sp)              // save struct address

        lli     t1, 158                     // t1 = start X
        sw      t1, 0x0010(sp)              // save start X

        li      t1, p1                      // t1 = p1 header string address
        sw      t1, 0x0014(sp)              // save string address

        li      t1, Global.vs.p1            // t1 = address of p1 player struct
        sw      t1, 0x0018(sp)              // save address of loaded character ids

        _loop:
        lw      t1, 0x0000(t0)              // t1 = 1 if this port is active
        beqz    t1, _end                    // skip if this port is not active
        nop

        // icons
        lw      t1, 0x0018(sp)              // t1 = address of player struct
        lbu     a1, 0x0003(t1)              // a1 = character id of this port
        lbu     t1, 0x0006(t1)              // t1 = color index
        sw      t1, 0x001C(sp)              // save color index
        li      t1, 0x80116E10              // t1 = main character struct table
        sll     t2, a1, 0x0002              // t2 = a1 * 4 (offset in struct table)
        addu    t1, t1, t2                  // t1 = pointer to character struct
        lw      t1, 0x0000(t1)              // t1 = character struct

        // Sonic costume check (player structs aren't loaded yet so we can't just use attribute data pointer)
        lli     a2, Character.id.SONIC      // a2 = Character.id.SONIC
        bne     a1, a2, _icon               // if not Sonic, use normal main file pointer
        lw      t2, 0x0028(t1)              // t2 = main character file address pointer

        li      a3, Sonic.classic_table     // a3 = classic_table
        lw      a2, 0x0008(sp)              // a2 = port (0 - 3)
        addu    a3, a3, a2                  // a3 = classic_table + port
        lbu     a3, 0x0000(a3)              // a3 = px is_classic
        bnezl   a3, _icon                   // if Classic Sonic, use Classic Sonic's main file
        lw      t2, 0x0040(t1)              // t2 = main character file address pointer

        _icon:
        lw      t2, 0x0000(t2)              // t2 = main character file address
        lw      t1, 0x0060(t1)              // t1 = offset to attribute data
        addu    t1, t2, t1                  // t1 = attribute data address
        lw      t1, 0x0340(t1)              // t1 = pointer to stock icon footer address
        lw      a2, 0x0000(t1)              // a2 = stock icon footer address
        lw      t1, 0x0004(t1)              // t1 = base palette address
        sw      t1, 0x0020(sp)              // save base palette address
        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lli     a3, 0x0000                  // a3 = Render.NOOP
        lwc1    f0, 0x0010(sp)              // f0 = ulx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, 0x4180                  // s2 = uly (16)
        addiu   s3, r0, -0x0001             // s3 = color (Color.high.WHITE)
        addiu   s4, r0, -0x0001             // s4 = pallette (Color.high.WHITE)
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

        // set correct icon palette
        lw      t0, 0x0020(sp)              // t0 = base palette address
        lw      t1, 0x001C(sp)              // t1 = color index
        sll     t1, t1, 0x0002              // t1 = offset to palette
        addu    t0, t0, t1                  // t0 = selected palette address
        lw      t0, 0x0000(t0)              // t0 = selected palette
        lw      t1, 0x0074(v0)              // t1 = icon image struct
        sw      t0, 0x0030(t1)              // update palette

        // draw
        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lw      a2, 0x0014(sp)              // a2 = string address
        lli     a3, 0x0000                  // a3 = Render.NOOP
        lw      t1, 0x0010(sp)              // t1 = ulx
        addiu   t1, t1, 26                  // adjust for right alignment
        mtc1    t1, f0                      // f0 = ulx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, 0x4180                  // s2 = uly (16)
        addiu   s3, r0, -0x0001             // s3 = color (Color.high.WHITE)
        lui     s4, 0x3F50                  // s4 = scale
        lli     s5, Render.alignment.RIGHT  // s5 = alignment
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, OS.FALSE                // t8 = blur

        lli     a0, 0x1F                    // a0 = room
        lli     a1, 0x0E                    // a1 = group
        lw      s1, 0x0010(sp)              // s1 = ulx
        addiu   t1, s1, 35                  // t1 = next ulx
        sw      t1, 0x0010(sp)              // save next ulx
        lli     s2, 26                      // s2 = uly
        lli     s3, 26                      // s3 = width
        lli     s4, 1                       // s4 = height
        addiu   s5, r0, -0x0001             // s5 = Color.high.WHITE
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha

        _end:
        lw      t2, 0x0008(sp)              // t2 = port (0 - 3)
        addiu   t2, t2, 0x0001              // t2++
        sw      t2, 0x0008(sp)              // save port
        sltiu   t1, t2, 0x0004              // t1 = 1 if not finished looping
        beqz    t1, _return                 // return if finished looping - otherwise, move to next struct and loop
        lw      t0, 0x000C(sp)              // t0 = stats struct of current port
        addiu   t0, t0, STATS_STRUCT_SIZE   // t0 = stats struct of next port
        sw      t0, 0x000C(sp)              // save stats struct of current port
        lw      a2, 0x0014(sp)              // t2 = string address
        addiu   t2, a2, 0x0003              // t2 = next string address
        sw      t2, 0x0014(sp)              // save next string address
        lw      t2, 0x0018(sp)              // t2 = current player struct
        addiu   t2, t2, Global.vs.P_DIFF    // t2 = next player struct
        b       _loop
        sw      t2, 0x0018(sp)              // save next loaded character id

        _return:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Runs every frame and checks if the stats menu should be displayed, and handles toggling display of rooms
    scope check_menu_toggle_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      t0, toggle_match_stats                   // t0 = address of toggle_match_stats
        lbu     t0, 0x0000(t0)                           // t0 = toggle_match_stats
        bne     t0, r0, _match_status_up                 // if (match stats displayed) skip to _match_status_up
        nop                                              // ~

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

        lli     a0, 0x0D                                 // a0 = group of menu instructions
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                               // a1 = 1 -> turn off this display list

        lli     a0, 0x16                                 // a0 = group of normal results stats
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                               // a1 = 1 -> turn off this display list

        lli     a0, 0x0E                                 // a0 = group of stats menu
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                               // a1 = 0 -> turn on this display list

        b       _end                                     // skip to _end
        nop                                              // ~

        _match_status_up:
        // check for b press
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

        lli     a0, 0x0D                                 // a0 = group of menu instructions
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                               // a1 = 0 -> turn on this display list

        lli     a0, 0x16                                 // a0 = group of normal results stats
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                               // a1 = 0 -> turn on this display list

        lli     a0, 0x0E                                 // a0 = group of stats menu
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                               // a1 = 1 -> turn off this display list

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // If the custom stats are displayed before the normal stats are finished rendering,
    // they will flash on and off which this patch will prevent.
    scope prevent_timed_row_flash_: {
        // FFA - stock
        OS.patch_start(0x1554EC, 0x8013634C)
        j       prevent_timed_row_flash_
        nop
        OS.patch_end()
        // FFA - timed?
        OS.patch_start(0x15557C, 0x801363DC)
        j       prevent_timed_row_flash_
        nop
        OS.patch_end()
        // Team Battle - stock
        OS.patch_start(0x155644, 0x801364A4)
        j       prevent_timed_row_flash_
        nop
        OS.patch_end()
        // Team Battle - timed?
        OS.patch_start(0x1556D4, 0x80136534)
        j       prevent_timed_row_flash_
        nop
        OS.patch_end()
        // No Contest?
        OS.patch_start(0x155748, 0x801365A8)
        j       prevent_timed_row_flash_
        nop
        OS.patch_end()

        // The normal results come in line by line - don't display them if match stats are displayed
        li      a1, toggle_match_stats      // a1 = address of toggle_match_stats
        lbu     a1, 0x0000(a1)              // a1 = toggle_match_stats
        jal     Render.toggle_group_display_
        lli     a0, 0x16                    // a0 = group of normal results stats

        lw      ra, 0x0014(sp)              // restore ra
        jr      ra                          // original line 2
        addiu   sp, sp, 0x0018              // original line 1
    }

    // @ Description
    // Sets up the custom display objects
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      t1, stats_struct_p1         // t1 = stats_struct_p1 address
        li      t2, stats_struct_p2         // t2 = stats_struct_p2 address
        li      t3, stats_struct_p3         // t3 = stats_struct_p3 address
        li      t4, stats_struct_p4         // t4 = stats_struct_p4 address

        collect_stats(1, 0x0004)            // collect stats for port 1
        collect_stats(2, 0x0008)            // collect stats for port 2
        collect_stats(3, 0x000C)            // collect stats for port 3
        collect_stats(4, 0x0010)            // collect stats for port 4

        Render.load_font()
        Render.load_file(0xC5, Render.file_pointer_1)    // load button images into file_pointer_1

        Render.register_routine(check_menu_toggle_, 0x0016, 0x7000) // run after all other routines so we don't show the dynamically added rows

        // Menu instructions
        Render.draw_string(0x1F, 0x0D, press_a, Render.NOOP, 0x43200000, 0x435A0000, 0xFFFFFFFF, 0x3F500000, Render.alignment.CENTER, OS.FALSE)
        Render.draw_texture_at_offset(0x1F, 0x0D, Render.file_pointer_1, Render.file_c5_offsets.A, Render.NOOP, 0x42FC0000, 0x43580000, 0x50A8FFFF, 0x0010FFFF, 0x3F800000)

        // Stats menu:

        // Transparent background
        Render.draw_rectangle(0x1F, 0x0E, 10, 10, 300, 220, 0x000000B0, OS.TRUE)

        // B: Back upper left
        Render.draw_string(0x1F, 0x0E, press_b, Render.NOOP, 0x420B0000, 0x417F0000, 0xFFFFFFFF, 0x3F500000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_texture_at_offset(0x1F, 0x0E, Render.file_pointer_1, Render.file_c5_offsets.B, Render.NOOP, 0x41B40000, 0x41600000, 0x00D040FF, 0x003000FF, 0x3F800000)

        // Player port headers
        jal     draw_port_headers_
        nop

        // Draw lines
        lli     a2, 30                      // a2 = start y
        draw_header(damage_stats)
        addiu   a2, a2, -1                  // adjust y for better underline
        draw_underline(75)
        draw_header(damage_dealt_to)
        draw_row(p1, 8, stats_struct_p1, 0x0004, 0x0020, 0, 0)
        draw_row(p2, 8, stats_struct_p1, 0x0008, 0x0020, 1, 1)
        draw_row(p3, 8, stats_struct_p1, 0x000C, 0x0020, 2, 2)
        draw_row(p4, 8, stats_struct_p1, 0x0010, 0x0020, 3, 3)
        draw_row(total_damage_given, 0, stats_struct_p1, 0x0018, 0x0020, -1, -1)
        draw_row(total_damage_taken, 0, stats_struct_p1, 0x0014, 0x0020, -1, -1)
        draw_row(highest_damage, 0, stats_struct_p1, 0x001C, 0x0020, -1, -1)

        b       _combo_stats_on_check
        nop

        _combo_stats_off:
        b       _end                        // skip drawing combo stats if combo meter toggle is off
        nop

        _combo_stats_on_check:
        // If combo meter is off, skip to _end and don't draw combo stats section
        Toggles.guard(Toggles.entry_combo_meter, _combo_stats_off)

        addiu   a2, a2, 5                   // adjust y for cleaner spacing
        draw_header(combo_stats)
        addiu   a2, a2, -1                  // adjust y for better underline
        draw_underline(68)
        draw_header(max_combo_hits_vs)
        draw_row(p1, 8, ComboMeter.combo_struct_p1, 0x0024, 0x0038, 0, 0)
        draw_row(p2, 8, ComboMeter.combo_struct_p1, 0x0028, 0x0038, 1, 1)
        draw_row(p3, 8, ComboMeter.combo_struct_p1, 0x002C, 0x0038, 2, 2)
        draw_row(p4, 8, ComboMeter.combo_struct_p1, 0x0030, 0x0038, 3, 3)
        draw_row(max_combo_hits_taken, 0, ComboMeter.combo_struct_p1, 0x0004, 0x0038, -1, -1)
        draw_row(max_combo_damage_taken, 0, ComboMeter.combo_struct_p1, 0x0008, 0x0038, -1, -1)

        _end:
        lli     a0, 0x0E                    // a0 = group of menu stats
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = 1 -> turn off this display list

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr     ra
        nop
    }

    // @ Description
    // Collects stats during a match (called by Render.asm)
    scope run_collect_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        li      t0, player_count            // t0 = number of players
        lbu     t1, 0x0000(t0)              // t1 = player_count
        bnez    t1, _collect                // if (player_count > 0) skip setup
        nop

        // Sets up the stats structs. This is only run once per match.
        _setup:
        // Reset variables from previous match
        initialize_stats_struct(1)
        initialize_stats_struct(2)
        initialize_stats_struct(3)
        initialize_stats_struct(4)
        li      t2, toggle_match_stats      // t2 = toggle_match_stats
        lli     t3, OS.FALSE                // ~
        sb      t3, 0x0000(t2)              // toggle match stats = false

        _p1:
        port_check(1, _p2)                  // check port 1

        _p2:
        port_check(2, _p3)                  // check port 2

        _p3:
        port_check(3, _p4)                  // check port 3

        _p4:
        port_check(4, _collect)             // check port 4

        _collect:
        collect_stats_midmatch(1)           // collect midmatch stats for p1
        collect_stats_midmatch(2)           // collect midmatch stats for p2
        collect_stats_midmatch(3)           // collect midmatch stats for p3
        collect_stats_midmatch(4)           // collect midmatch stats for p4

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }
}

} // __VSSTATS__
