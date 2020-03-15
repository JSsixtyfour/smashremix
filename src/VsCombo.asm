// VsCombo.asm
if !{defined __VSCOMBO__} {
define __VSCOMBO__()
print "included VsCombo.asm\n"

// @ Description
// This file adds combo meters to VS. matches.

include "Character.asm"
include "Data.asm"
include "FGM.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"
include "Toggles.asm"

scope VsCombo {

    // @ Description
    // Display constants for combo/hit meter positioning
    constant COMBO_METER_Y_COORD(167)
    constant P1_COMBO_METER_X_COORD(10)
    constant P2_COMBO_METER_X_COORD(80)
    constant P3_COMBO_METER_X_COORD(150)
    constant P4_COMBO_METER_X_COORD(220)

    // @ Description
    // Player hit count addresses
    constant P1_HIT_COUNT(0x800A4D7C)
    constant P2_HIT_COUNT(0x800A4DF0)
    constant P3_HIT_COUNT(0x800A4E64)
    constant P4_HIT_COUNT(0x800A4ED8)

    // @ Description
    // Default number of frames to keep a hit count displayed
    constant DEFAULT_FRAME_BUFFER(30)

    // @ Description
    // Player count
    player_count:
    dw 0x00

    // @ Description
    // This will hold the addresses of the combo text textures by port color
    // 0 = red (p1), 1 = blue (p2), 2 = yellow (p3), 3 = green (p4), 4 = silver (unattributed)
    // For teams, 1-4 will be set based on that player's team color
    combo_text_map:
    dw      Data.combo_text_r_info
    dw      Data.combo_text_b_info
    dw      Data.combo_text_y_info
    dw      Data.combo_text_g_info
    dw      Data.combo_text_s_info

    // @ Description
    // This will hold the addresses of the combo numbers textures by port color
    // 0 = red (p1), 1 = blue (p2), 2 = yellow (p3), 3 = green (p4), 4 = silver (unattributed)
    // For teams, 1-4 will be set based on that player's team color
    combo_numbers_map:
    dw      Data.combo_numbers_r_info
    dw      Data.combo_numbers_b_info
    dw      Data.combo_numbers_y_info
    dw      Data.combo_numbers_g_info
    dw      Data.combo_numbers_s_info

    // @ Description
    // This macro creates a combo struct for the given port
    macro combo_struct(port) {
        combo_struct_p{port}: {
            dw      0x00                        // 0x0000 = combo_meter_pointer
            dw      0x00                        // 0x0004 = max_combo_hits
            dw      0x00                        // 0x0008 = max_combo_damage
            dw      0x00                        // 0x000C = combo_count
            dw      0x00                        // 0x0010 = combo color index (display)
            dw      0x00                        // 0x0014 = combo color index (current)
            dw      0x00                        // 0x0018 = x_coord
            dw      0x00                        // 0x001C = frame_buffer
            dw      0x00                        // 0x0020 = player struct address
            dw      0x00                        // 0x0024 = highest_combo_vs_p1
            dw      0x00                        // 0x0028 = highest_combo_vs_p2
            dw      0x00                        // 0x002C = highest_combo_vs_p3
            dw      0x00                        // 0x0030 = highest_combo_vs_p4
            dw      0x00                        // 0x0034 = current_attribution_start_hit_count
        }
    }

    // Create combo structs
    combo_struct(1)
    combo_struct(2)
    combo_struct(3)
    combo_struct(4)

    // @ Description
    // If in teams, this will modify the color maps to point to the color of the given port's team
    macro set_color_by_team(port, offset) {
        li      t0, Global.vs.p{port}         // t0 = pointer to address of player struct for p{port}
        lbu     t0, 0x0004(t0)                // t0 = team (0 = red, 1 = blue, 2 = green)
        bnez    t0, _blue_or_green_p{port}    // if (t0 != 0) then check if blue or green
        nop                                   // otherwise set to red
        li      t0, Data.combo_text_r_info    // t0 = address of red combo text texture
        li      t1, Data.combo_numbers_r_info // t1 = address of red combo numbers texture
        b       _team_color_set_p{port}
        nop

        _blue_or_green_p{port}:
        addi    t0, -0x0001                   // t0 = 0 if blue, 1 if green
        bnez    t0, _green_p{port}            // if (t0 != 0) then set to green
        nop                                   // otherwise set to blue
        li      t0, Data.combo_text_b_info    // t0 = address of blue combo text texture
        li      t1, Data.combo_numbers_b_info // t1 = address of blue combo numbers texture
        b       _team_color_set_p{port}
        nop

        _green_p{port}:
        li      t0, Data.combo_text_g_info    // t0 = address of green combo text texture
        li      t1, Data.combo_numbers_g_info // t1 = address of green combo numbers texture

        _team_color_set_p{port}:
        sw      t0, {offset}(a0)                // set p{port} combo text color
        sw      t1, {offset}(a1)                // set p{port} combo numbers color
    }

    // @ Description
    // This initializes the combo structs for the match
    scope initialize_combo_structs_: {
        addiu   sp, sp,-0x0010                // allocate stack space
        sw      t0, 0x0004(sp)                // ~
        sw      t1, 0x0008(sp)                // ~
        sw      ra, 0x000C(sp)                // save registers

        li      a0, combo_struct_p1           // a0 = combo_struct_p1
        li      a1, combo_struct_p2           // a1 = combo_struct_p2
        li      a2, combo_struct_p3           // a2 = combo_struct_p3
        li      a3, combo_struct_p4           // a3 = combo_struct_p4

        // Set X coords
        lli     t0, P1_COMBO_METER_X_COORD    // t0 = p1 x coord
        sw      t0, 0x0018(a0)                // store x coord
        lli     t0, P2_COMBO_METER_X_COORD    // t0 = p2 x coord
        sw      t0, 0x0018(a1)                // store x coord
        lli     t0, P3_COMBO_METER_X_COORD    // t0 = p3 x coord
        sw      t0, 0x0018(a2)                // store x coord
        li      t0, P4_COMBO_METER_X_COORD    // t0 = p4 x coord
        sw      t0, 0x0018(a3)                // store x coord

        // Set combo meter addresses
        li      t0, P1_HIT_COUNT              // t0 = p1 hit count address
        sw      t0, 0x0000(a0)                // store hit count address
        li      t0, P2_HIT_COUNT              // t0 = p2 hit count address
        sw      t0, 0x0000(a1)                // store hit count address
        li      t0, P3_HIT_COUNT              // t0 = p3 hit count address
        sw      t0, 0x0000(a2)                // store hit count address
        li      t0, P4_HIT_COUNT              // t0 = p4 hit count address
        sw      t0, 0x0000(a3)                // store hit count address

        // Reset frame buffers (need to do this so prior match data is cleared)
        sw      r0, 0x001C(a0)                // set frame buffer to 0 for p1
        sw      r0, 0x001C(a1)                // set frame buffer to 0 for p2
        sw      r0, 0x001C(a2)                // set frame buffer to 0 for p3
        sw      r0, 0x001C(a3)                // set frame buffer to 0 for p4

        // Reset player struct addresses (need to do this so prior match data is cleared)
        sw      r0, 0x0020(a0)                // set player struct address to 0 for p1
        sw      r0, 0x0020(a1)                // set player struct address to 0 for p2
        sw      r0, 0x0020(a2)                // set player struct address to 0 for p3
        sw      r0, 0x0020(a3)                // set player struct address to 0 for p4

        // Reset combo stats
        sw      r0, 0x0004(a0)                // set max_combo_hits to 0 for p1
        sw      r0, 0x0004(a1)                // set max_combo_hits to 0 for p2
        sw      r0, 0x0004(a2)                // set max_combo_hits to 0 for p3
        sw      r0, 0x0004(a3)                // set max_combo_hits to 0 for p4
        sw      r0, 0x0008(a0)                // set max_combo_damage to 0 for p1
        sw      r0, 0x0008(a1)                // set max_combo_damage to 0 for p2
        sw      r0, 0x0008(a2)                // set max_combo_damage to 0 for p3
        sw      r0, 0x0008(a3)                // set max_combo_damage to 0 for p4
        sw      r0, 0x0024(a0)                // set highest_combo_vs_p1 to 0 for p1
        sw      r0, 0x0024(a1)                // set highest_combo_vs_p1 to 0 for p2
        sw      r0, 0x0024(a2)                // set highest_combo_vs_p1 to 0 for p3
        sw      r0, 0x0024(a3)                // set highest_combo_vs_p1 to 0 for p4
        sw      r0, 0x0028(a0)                // set highest_combo_vs_p2 to 0 for p1
        sw      r0, 0x0028(a1)                // set highest_combo_vs_p2 to 0 for p2
        sw      r0, 0x0028(a2)                // set highest_combo_vs_p2 to 0 for p3
        sw      r0, 0x0028(a3)                // set highest_combo_vs_p2 to 0 for p4
        sw      r0, 0x002C(a0)                // set highest_combo_vs_p3 to 0 for p1
        sw      r0, 0x002C(a1)                // set highest_combo_vs_p3 to 0 for p2
        sw      r0, 0x002C(a2)                // set highest_combo_vs_p3 to 0 for p3
        sw      r0, 0x002C(a3)                // set highest_combo_vs_p3 to 0 for p4
        sw      r0, 0x0030(a0)                // set highest_combo_vs_p4 to 0 for p1
        sw      r0, 0x0030(a1)                // set highest_combo_vs_p4 to 0 for p2
        sw      r0, 0x0030(a2)                // set highest_combo_vs_p4 to 0 for p3
        sw      r0, 0x0030(a3)                // set highest_combo_vs_p4 to 0 for p4

        // Set color maps
        li      t0, Global.vs.teams           // t0 = pointer to teams byte
        lbu     t0, 0x0000(t0)                // t0 = teams
        beqz    t0, _initialize_by_port       // if (!teams), initialize color by port
        nop                                   // otherwise we'll get each player's team and set accordingly

        // We'll now determine each player's team and set the color maps up accordingly.
        li      a0, combo_text_map            // a0 = address of combo text map
        li      a1, combo_numbers_map         // a1 = address of combo numbers map

        set_color_by_team(1, 0x0000)
        set_color_by_team(2, 0x0004)
        set_color_by_team(3, 0x0008)
        set_color_by_team(4, 0x000C)
        b       _end
        nop

        _initialize_by_port:
        li      a0, Data.combo_text_r_info    // a0 = p1 combo text color (red)
        li      a1, Data.combo_text_b_info    // a1 = p2 combo text color (blue)
        li      a2, Data.combo_text_y_info    // a2 = p3 combo text color (yellow)
        li      a3, Data.combo_text_g_info    // a3 = p4 combo text color (green)
        li      t0, combo_text_map            // t0 = address of combo text map
        sw      a0, 0x0000(t0)                // store p1 combo text color
        sw      a1, 0x0004(t0)                // store p2 combo text color
        sw      a2, 0x0008(t0)                // store p3 combo text color
        sw      a3, 0x000C(t0)                // store p4 combo text color
        li      a0, Data.combo_numbers_r_info // a0 = p1 combo text color (red)
        li      a1, Data.combo_numbers_b_info // a1 = p2 combo text color (blue)
        li      a2, Data.combo_numbers_y_info // a2 = p3 combo text color (yellow)
        li      a3, Data.combo_numbers_g_info // a3 = p4 combo text color (green)
        li      t0, combo_numbers_map         // t0 = address of combo numbers map
        sw      a0, 0x0000(t0)                // store p1 combo numbers color
        sw      a1, 0x0004(t0)                // store p2 combo numbers color
        sw      a2, 0x0008(t0)                // store p3 combo numbers color
        sw      a3, 0x000C(t0)                // store p4 combo numbers color

        _end:
        lw      t0, 0x0004(sp)                // ~
        lw      t1, 0x0008(sp)                // ~
        lw      ra, 0x000C(sp)                // save registers
        addiu   sp, sp, 0x0010                // deallocate stack space
        jr      ra                            // return
        nop
    }

    // @ Description
    // This draws the given hit count at the specified X coordinate
    scope draw_hit_count_: {
        // a0 = combo struct
        // a1 = player struct
        // a2 = port

        addiu   sp, sp,-0x0028                    // allocate stack space
        sw      t0, 0x0004(sp)                    // ~
        sw      t1, 0x0008(sp)                    // ~
        sw      t2, 0x000C(sp)                    // ~
        sw      t3, 0x0010(sp)                    // ~
        sw      t4, 0x0014(sp)                    // ~
        sw      t5, 0x0018(sp)                    // ~
        sw      t6, 0x001C(sp)                    // ~
        sw      t7, 0x0020(sp)                    // ~
        sw      ra, 0x0024(sp)                    // save registers

        move    t5, a0                            // t5 = player combo struct
        lw      t0, 0x0000(t5)                    // t0 = combo meter address
        lw      a0, 0x0000(t0)                    // a0 = hit count
        addiu   t0, -0x0004                       // t0 = combo damage address
        lw      t6, 0x0000(t0)                    // t6 = combo damage
        lw      t4, 0x0018(t5)                    // t4 = player_x_coord
        lw      t7, 0x0014(t5)                    // t7 = previous color index

        // Check if player struct address is 0 - if so, don't draw anything
        beqz    a1, _end                          // if (player struct address == 0) then skip to _end
        nop                                       // ~

        // Check if currently in a combo (hit count > 1)
        lli     t0, 0x0001                        // t0 = 1
        sltu    t1, t0, a0                        // if (hit count > 1) then update frame buffer
        bnez    t1, _in_combo                     // skip to _in_combo to update frame buffer
        nop

        // Sync colors
        beqz    a0, _check_frame_buffer           // if (hit count = 1), then set combo color index via port
        nop                                       // ~
        lw      t1, 0x0034(t5)                    // t1 = starting hit
        beq     t1, a0, _check_frame_buffer       // if we've already set the starting hit to 1, skip synching color
        nop
        lw      t1, 0x080C(a1)                    // t1 = port attributed with hit, or 4 if unattributed
        addiu   t2, r0, 0xFFFF                    // t2 = -1
        bne     t2, t1, _sync_color_first_hit     // if (current hit attribution = -1) then use 4 (silver)
        nop                                       // ~
        lli     t1, 0x0004                        // t1 = 4 (silver)
        _sync_color_first_hit:
        sw      t1, 0x0014(t5)                    // store current color index

        // Check if frame buffer is active (frame buffer > 0)
        _check_frame_buffer:
        sw      a0, 0x0034(t5)                    // store 1 as starting hit or reset to 0
        lw      t3, 0x001C(t5)                    // t3 = frame_buffer
        bnez    t3, _post_combo                   // if (frame buffer > 0) then frame_buffer-- and draw
        nop
        b       _end                              // don't draw - skip to end
        nop

        // Move hit count to display table and restore frame buffer
        _in_combo:
        lli     t3, DEFAULT_FRAME_BUFFER          // t3 = DEFAULT_FRAME_BUFFER
        sll     t1, a0, 0x0002                    // t1 = hit_count * 4
        sltiu   t2, t1, 0x0096                    // if (hit_count * 4 >= 150) then only add 150 frames
        bnez    t2, _continue_in_combo            // hit_count * 4 is ok to use as an additional frame buffer; skip
        nop
        lli     t1, 0x0096                        // Only add 150 frames

        _continue_in_combo:
        addu    t3, t3, t1                        // t3 = t3 + t1 (add more frames for higher combo values)
        sw      t3, 0x001C(t5)                    // frame buffer = DEFAULT_FRAME_BUFFER + additional frames

        lli     t1, 0x0014                        // t1 = 20
        bne     t1, a0, _max_hit_check            // if (hit count != 20) then don't play sound effect
        nop                                       // ~
        lw      t1, 0x000C(t5)                    // t1 = current combo count previously
        beq     t1, a0, _continue_in_combo2       // if (hit count already is 20) then don't play sound effect (because we already did)
        nop                                       // ~
        move    t1, a0                            // t1 = hit count
        li      a0, FGM.announcer.misc.INCREDIBLE // a0 - fgm_id for INCREDIBLE
        jal     FGM.play_                         // play INCREDIBLE sound effect
        nop
        move    a0, t1                            // a0 = hit count

        _max_hit_check:
        lw      t2, 0x0004(t5)                    // Load previous max_combo_hits
        slt     t3, t2, a0                        // if (combo count > max_combo_hits) then update max_combo_hits
        beqz    t3, _max_damage_check             // skip to max_damage_check if not a higher max_combo_hits
        nop                                       // ~
        sw      a0, 0x0004(t5)                    // store max_combo_hits

        _max_damage_check:
        lw      t2, 0x0008(t5)                    // Load previous max_combo_damage
        slt     t3, t2, t6                        // if (combo damage > max_combo_damage) then update max_combo_damage
        beqz    t3, _continue_in_combo2           // skip to team_check if not a higher max_combo_damage
        nop                                       // ~
        sw      t6, 0x0008(t5)                    // store max_combo_damage

        _continue_in_combo2:
        sw      a0, 0x000C(t5)                    // store current combo count
        lw      t3, 0x080C(a1)                    // color index for player attributed to current hit based on port
        addiu   t2, r0, 0xFFFF                    // t2 = -1
        beq     t2, t3, _use_previous_color       // if (current hit attribution reset to -1) then use previous value
        nop                                       // ~
        sltiu   t2, t3, 0x0004                    // if (current hit unattributed to player) then don't store it - use previous value
        beqz    t2, _use_previous_color           // ~
        nop
        sw      t3, 0x0014(t5)                    // store color index as current color index
        sw      t3, 0x0010(t5)                    // store color index as color index for display
        beq     t3, t7, _highest_combo_check      // if (previous color index != current color index) then set attribution start
        nop
        sw      a0, 0x0034(t5)                    // store hit count as starting hit
        b       _highest_combo_check              // skip to _highest_combo_check
        nop

        _use_previous_color:
        lw      t3, 0x0014(t5)                    // t3 = previously stored color index
        sw      t3, 0x0010(t5)                    // store color index as color index for display
        sltiu   t2, t3, 0x0004                    // if (current and previous hit unattributed to player) then don't do highest combo check
        beqz    t2, _draw                         // ~
        nop

        _highest_combo_check:
        lw      t0, 0x0034(t5)                    // t0 = starting hit
        subu    t1, a0, t0                        // t1 = current hit count - starting hit
        addiu   t1, t1, 0x0001                    // t1 = current combo hit count attributed to this player
        lli     t0, 0x0038                        // t0 = size of combo struct
        multu   t0, t3                            // t3 * t0 is the offset from combo_struct_p1 for the attacking player
        mflo    t0                                // t0 = t3 * t0
        li      t2, combo_struct_p1               // t2 = address of port 1 combo struct
        addu    t2, t2, t0                        // t2 = address of attacking player's combo struct (combo_struct_pX)
        lli     t0, 0x0004                        // t0 = size of word
        multu   t0, a2                            // a2 * t0 is the offset from highest_combo_vs_p1 for the defending player
        mflo    t0                                // t0 = a2 * t0
        addiu   t2, t2, 0x0020                    // t2 = word before highest_combo_vs_p1 for attacking player
        addu    t2, t2, t0                        // t2 = address of highest_combo_vs_pX for attacking player where X is the defending port
        lw      t0, 0x0000(t2)                    // t0 = highest_combo_vs_pX
        sltu    t0, t0, t1                        // if (current combo hit count > highest stored) then update
        beqz    t0, _draw                         // else skip to draw
        nop                                       // ~
        sw      t1, 0x0000(t2)                    // store highest_combo_vs_pX
        b       _draw                             // skip to draw
        nop

        // Decrease frame buffer
        _post_combo:
        addiu   t3, t3, -0x0001                   // frame_buffer--
        sw      t3, 0x001C(t5)                    // save new frame buffer
        lw      a0, 0x000C(t5)                    // get previous combo count

        // Draw combo meter
        _draw:
        jal     String.itoa_                      // v0 = (string) hit count
        nop
        move    a0, t4                            // a0 - ulx
        lli     a1, COMBO_METER_Y_COORD           // a1 - uly
        lw      t0, 0x0010(t5)                    // t0 - color index (0 = silver, 1 = p1, 2 = p2, 3 = p3, 4 = p4)
        sll     t1, t0, 0x0002                    // t1 = color index * 4 = offset in color maps
        li      t2, combo_text_map                // t2 = combo_text_map address
        addu    t2, t2, t1                        // t2 = address of texture struct address
        lw      a2, 0x0000(t2)                    // a2 = address of texture struct
        jal     Overlay.draw_texture_             // draw combo text texture
        nop
        addiu   a0, t4, 64                        // a0 = ulx + 64
        lli     a1, COMBO_METER_Y_COORD           // a1 = uly
        move    a2, v0                            // a2 = address of string
        li      t2, combo_numbers_map             // t2 = combo_numbers_map address
        addu    t2, t2, t1                        // t2 = address of font struct address
        lw      a3, 0x0000(t2)                    // a3 = address of font struct
        jal     draw_string_                      // draw current hit count
        nop

        _end:
        lw      t0, 0x0004(sp)                    // ~
        lw      t1, 0x0008(sp)                    // ~
        lw      t2, 0x000C(sp)                    // ~
        lw      t3, 0x0010(sp)                    // ~
        lw      t4, 0x0014(sp)                    // ~
        lw      t5, 0x0018(sp)                    // ~
        lw      t6, 0x001C(sp)                    // ~
        lw      t7, 0x0020(sp)                    // ~
        lw      ra, 0x0024(sp)                    // save registers
        addiu   sp, sp, 0x0028                    // deallocate stack space
        jr      ra                                // return
        nop
    }

    // @ Description
    // This macro draws the given port's combo meter
    macro draw_hit_count(port) {
        li      a0, combo_struct_p{port}    // a0 = combo_struct_pX address
        lw      a1, 0x0020(a0)              // a1 = player struct address
        lli     a2, {port}                  // a2 = port
        jal     VsCombo.draw_hit_count_     // draw combo meter
        nop
    }

    // @ Description
    // This macro checks if the given port is a man/cpu and increments player count
    // accordingly. Then it sets up the tables needed for swapping the combo meter
    // in singles and also stores the correct player struct address.
    macro port_check(port, next) {
        // t0 = player_count address
        // t1 = player_count
        // t8 = x_coord_table
        // t9 = combo_struct_table
        li      t2, Global.vs.p{port}            // address of player struct
        lbu     t3, 0x0002(t2)                   // t3 = player type (0 = man, 1 = cpu, 2 = n/a)
        sltiu   t4, t3, 0x0002                   // if (p3 = man/cpu) then player_count++
        beqz    t4, {next}                       // not man/cpu so skip
        nop
        or      a0, r0, t1                       // a0 = player struct index, (p1 = 0, p4 = 3)
        jal     Character.get_struct_            // v0 = player struct address
        nop
        addu    t1, t1, t4                       // player_count++
        li      t4, combo_struct_p{port}         // t4 = combo struct address for right/left port
        sw      v0, 0x0020(t4)                   // store address of player struct
        sw      t1, 0x0000(t0)                   // store player count
        sltiu   t5, t1, 0x0003                   // if (>=3 players) then not singles so don't set up swap tables
        beqz    t5, {next}                       // ~
        nop                                      // ~
        li      t5, P{port}_COMBO_METER_X_COORD  // t5 = x coord for left/right port
        sw      t5, 0x0000(t8)                   // store x coord for left/right port
        addiu   t8, t8, 0x0004                   // t8 = x_coord_table++
        sw      t4, 0x0000(t9)                   // store combo struct address for right/left port
        addiu   t9, t9, 0x0004                   // t9 = combo_struct_table++
    }

    // @ Description
    // Adds f3dex2 to draw characters.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - char
    // a3 - address of font
    scope draw_char_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      a3, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        lw      t0, 0x0008(a3)              // t0 = address of image_data


        addiu   a2, a2, -0x0030             // a2 = char - 48 (we only care about numbers, sprite not padded)
        sll     t1, a2, 0x0009              // t1 = char * width * height * 2 (or char * 512)
        addu    t0, t0, t1                  // t0 = address of char_data
        li      t1, texture                 // ~
        sw      t0, 0x0008(t1)              // texture.data = char_data
        li      a2, texture                 // a2 - texture data
        jal     Overlay.draw_texture_
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      a3, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        texture:
        Texture.info(16, 16)
    }

    // @ Description
    // Draws a null terminated string.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - address of string
    // a3 - address of font
    scope draw_string_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      s2, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        or      s2, a2, r0                  // s2 = copy of a2 (address of string)

        _loop:
        lb      t0, 0x0000(s2)              // t0 = char
        beq     t0, r0, _end                // if (t0 == 0x00), end
        nop
        or      a2, t0, 0x000               // a2 = char
        jal     draw_char_                  // draw character
        nop
        addiu   s2, s2, 0x0001              // s2++
        addiu   a0, a0, 0x0009              // a0 = (ulx + 9)
        b       _loop                       // draw next char
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      s2, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This is the entry for Overlay.asm
    scope run_: {
        b       _guard                      // check if toggle is on
        nop

        _toggle_off:
        b       _end                        // toggle is off, skip to end
        nop

        _swap_toggle_off:
        b       _draw_hit_counts            // 1v1 swap toggle is off, skip to _draw_hit_counts
        nop

        _guard:
        // If combo meter is off, skip to _end and don't draw hit counts
        Toggles.guard(Toggles.entry_vs_mode_combo_meter, _toggle_off)

        OS.save_registers()                 // save registers

        li      t0, player_count            // t0 = number of players
        lw      t1, 0x0000(t0)              // t1 = player_count
        bnez    t1, _draw_hit_counts        // if (player_count > 0) skip setup
        nop

        // We swap hit count meter location for 1v1, so the next few blocks check
        // how many players there are and set up tables for the left and right
        // player ports. This is only run once per match.
        _setup:
        li      t8, x_coord_table           // t8 = x_coord_table
        li      t9, combo_struct_table      // t9 = combo_struct_table
        jal     initialize_combo_structs_   // Reset variables from previous match
        nop

        _p1:
        port_check(1, _p2)                  // check port 1

        _p2:
        port_check(2, _p3)                  // check port 2

        _p3:
        port_check(3, _p4)                  // check port 3

        _p4:
        port_check(4, _check_singles)       // check port 4

        _check_singles:
        // If 1v1 swap is off, skip to _draw_hit_counts
        Toggles.guard(Toggles.entry_1v1_combo_meter_swap, _swap_toggle_off)

        lli     t5, 0x0002                  // t5 = 2
        bne     t1, t5, _draw_hit_counts    // if (player_count != 2) then not singles
        nop

        _swap_for_singles:
        li      t8, x_coord_table           // t8 = address of x_coord_table
        li      t9, combo_struct_table      // t9 = address of combo_struct_table
        lw      t0, 0x0000(t8)              // t0 = left player x_coord
        lw      t1, 0x0004(t9)              // t1 = left player combo_struct address
        sw      t0, 0x0018(t1)              // update combo_struct_pX with x coord for left player
        lw      t0, 0x0004(t8)              // t0 = right player x_coord
        lw      t1, 0x0000(t9)              // t1 = right player combo_struct address
        sw      t0, 0x0018(t1)              // update combo_struct_pX with x coord for right player

        // end of setup

        _draw_hit_counts:
        draw_hit_count(1)                   // draw combo meter for port 1
        draw_hit_count(2)                   // draw combo meter for port 2
        draw_hit_count(3)                   // draw combo meter for port 3
        draw_hit_count(4)                   // draw combo meter for port 4

        OS.restore_registers()              // restore registers

        _end:
        jr      ra                          // return
        nop

        x_coord_table:
        dw 0x00                             // left player x_coord (singles)
        dw 0x00                             // right player x_coord (singles)

        combo_struct_table:
        dw 0x00                             // right player combo struct address (singles)
        dw 0x00                             // left player combo struct address (singles)

    }
} // VsCombo
} // __VSCOMBO__
