// ComboMeter.asm
if !{defined __COMBO_METER__} {
define __COMBO_METER__()
print "included ComboMeter.asm\n"

// @ Description
// This file adds combo meters to VS. matches.

include "Character.asm"
include "FGM.asm"
include "OS.asm"
include "Toggles.asm"

scope ComboMeter {

    // @ Description
    // Display constants for combo/hit meter positioning
    constant X_COORDS_POINTER(0x80131588)
    constant COMBO_METER_X_OFFSET(0xC234)        // -45
    constant COMBO_METER_Y_COORD(0x4327)         // 167
    constant COMBO_METER_NUMBERS_OFFSET(0x4280)  // 64
    constant COMBO_METER_NUMBER_OFFSET(0x4110)   // 9

    // @ Description
    // Offsets in the ComboMeterTexture file to the "COMBO +" textures for each color
    constant TEXT_OFFSET_R(0x0818)
    constant TEXT_OFFSET_B(0x1078)
    constant TEXT_OFFSET_Y(0x18D8)
    constant TEXT_OFFSET_G(0x2138)
    constant TEXT_OFFSET_S(0x2998)

    // @ Description
    // Offsets in the ComboMeterTexture file to the 0 texture for each color
    // Subsequent numbers are offset at 0x260 in order
    constant NUMBER_OFFSET_R(0x2BF8)
    constant NUMBER_OFFSET_B(0x43B8)
    constant NUMBER_OFFSET_Y(0x5B78)
    constant NUMBER_OFFSET_G(0x7338)
    constant NUMBER_OFFSET_S(0x8AF8) // note this is over 0x8000, so we'll have to treat differently
    constant NUMBER_OFFSET(0x0260)

    // @ Description
    // Default number of frames to keep a hit count displayed
    constant DEFAULT_FRAME_BUFFER(30)

    //@ Description
    // Will be populated with base address of combo textures file which is loaded at match start
    file_address:
    dw      0x00000000

    // @ Description
    // This will hold the addresses of the combo text textures by port color
    // 0 = red (p1), 1 = blue (p2), 2 = yellow (p3), 3 = green (p4), 4 = silver (unattributed)
    // For teams, 1-4 will be set based on that player's team color
    combo_text_map:
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000

    // @ Description
    // This will hold the addresses of the combo numbers textures by port color
    // 0 = red (p1), 1 = blue (p2), 2 = yellow (p3), 3 = green (p4), 4 = silver (unattributed)
    // For teams, 1-4 will be set based on that player's team color
    combo_numbers_map:
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000

    // @ Description
    // This holds the combo meter struct for the port based on order of X coordinate
    combo_struct_map:
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000
    dw      0x00000000

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
            dw      0x00                        // 0x0018 = x_coord in setup_, object address in run_
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
        addiu   t0, a2, TEXT_OFFSET_R - 0x10  // t0 = address of red combo text texture
        addiu   t1, a2, NUMBER_OFFSET_R - 0x10// t1 = address of red combo numbers texture
        b       _team_color_set_p{port}
        nop

        _blue_or_green_p{port}:
        addi    t0, -0x0001                   // t0 = 0 if blue, 1 if green
        bnez    t0, _green_p{port}            // if (t0 != 0) then set to green
        nop                                   // otherwise set to blue
        addiu   t0, a2, TEXT_OFFSET_B - 0x10  // t0 = address of blue combo text texture
        addiu   t1, a2, NUMBER_OFFSET_B - 0x10// t1 = address of blue combo numbers texture
        b       _team_color_set_p{port}
        nop

        _green_p{port}:
        addiu   t0, a2, TEXT_OFFSET_G - 0x10  // t0 = address of green combo text texture
        addiu   t1, a2, NUMBER_OFFSET_G - 0x10// t1 = address of green combo numbers texture

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

        li      t0, combo_struct_map
        sw      a0, 0x0000(t0)                // initialize p1
        sw      a1, 0x0004(t0)                // initialize p2
        sw      a2, 0x0008(t0)                // initialize p3
        sw      a3, 0x000C(t0)                // initialize p4

        // Set X coords
        lui     t1, COMBO_METER_X_OFFSET      // t1 = COMBO_METER_X_OFFSET
        mtc1    t1, f2                        // f2 = COMBO_METER_X_OFFSET
        li      t0, X_COORDS_POINTER
        lw      t0, 0x0000(t0)                // t0 = port X coords array
        lw      t1, 0x0000(t0)                // t1 = X coord, p1
        beqz    t1, _store_p1_x               // if 0, skip
        mtc1    t1, f0                        // f0 = X coord, or 0
        cvt.s.w f0, f0                        // f0 = X coord, floating point
        add.s   f0, f0, f2                    // f0 = combo meter x coord
        _store_p1_x:
        swc1    f0, 0x0018(a0)                // store x coord
        lw      t1, 0x0004(t0)                // t1 = X coord, p2
        beqz    t1, _store_p2_x               // if 0, skip
        mtc1    t1, f0                        // f0 = X coord, or 0
        cvt.s.w f0, f0                        // f0 = X coord, floating point
        add.s   f0, f0, f2                    // f0 = combo meter x coord
        _store_p2_x:
        swc1    f0, 0x0018(a1)                // store x coord
        lw      t1, 0x0008(t0)                // t1 = X coord, p3
        beqz    t1, _store_p3_x               // if 0, skip
        mtc1    t1, f0                        // f0 = X coord, or 0
        cvt.s.w f0, f0                        // f0 = X coord, floating point
        add.s   f0, f0, f2                    // f0 = combo meter x coord
        _store_p3_x:
        swc1    f0, 0x0018(a2)                // store x coord
        lw      t1, 0x000C(t0)                // t1 = X coord, p4
        beqz    t1, _store_p4_x               // if 0, skip
        mtc1    t1, f0                        // f0 = X coord, or 0
        cvt.s.w f0, f0                        // f0 = X coord, floating point
        add.s   f0, f0, f2                    // f0 = combo meter x coord
        _store_p4_x:
        swc1    f0, 0x0018(a3)                // store x coord

        // Set combo meter addresses
        li      t0, Global.match_info
        lw      t0, 0x0000(t0)                // t0 = match info
        addiu   t0, t0, 0x0074                // t0 = p1 hit count address
        sw      t0, 0x0000(a0)                // store hit count address
        addiu   t0, t0, 0x0074                // t0 = p2 hit count address
        sw      t0, 0x0000(a1)                // store hit count address
        addiu   t0, t0, 0x0074                // t0 = p3 hit count address
        sw      t0, 0x0000(a2)                // store hit count address
        addiu   t0, t0, 0x0074                // t0 = p4 hit count address
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
        li      t0, Global.current_screen
        lbu     t0, 0x0000(t0)                // t0 = current screen
        lli     t1, 0x0016                    // t1 = VS screen ID
        bne     t0, t1, _initialize_by_port   // if not VS, always initialize by port
        li      t0, Global.vs.teams           // t0 = pointer to teams byte
        lbu     t0, 0x0000(t0)                // t0 = teams
        beqz    t0, _initialize_by_port       // if (!teams), initialize color by port
        nop                                   // otherwise we'll get each player's team and set accordingly

        // We'll now determine each player's team and set the color maps up accordingly.
        li      a0, combo_text_map            // a0 = address of combo text map
        li      a1, combo_numbers_map         // a1 = address of combo numbers map
        li      a2, file_address              // a2 = pointer to RAM address of loaded textures file
        lw      a2, 0x0000(a2)                // a2 = RAM address of loaded textures file

        set_color_by_team(1, 0x0000)
        set_color_by_team(2, 0x0004)
        set_color_by_team(3, 0x0008)
        set_color_by_team(4, 0x000C)

        addiu   t0, a2, TEXT_OFFSET_S - 0x10  // t0 = address of silver combo text texture
        addiu   t1, a2, NUMBER_OFFSET_S - 0x1010 // t1 = address of silver combo numbers texture, minus 0x1000 to avoid subtraction
        addiu   t1, t1, 0x1000                // t1 = address of silver combo numbers texture, addjusted for 0x1000 subtracted above
        sw      t0, 0x0010(a0)                // set unattributed combo text color
        sw      t1, 0x0010(a1)                // set unattributed combo numbers color
        b       _end
        nop

        _initialize_by_port:
        li      t1, file_address              // t1 = pointer to RAM address of loaded textures file
        lw      t1, 0x0000(t1)                // t1 = RAM address of loaded textures file
        addiu   a0, t1, TEXT_OFFSET_R - 0x10  // a0 = p1 combo text color (red)
        addiu   a1, t1, TEXT_OFFSET_B - 0x10  // a1 = p2 combo text color (blue)
        addiu   a2, t1, TEXT_OFFSET_Y - 0x10  // a2 = p3 combo text color (yellow)
        addiu   a3, t1, TEXT_OFFSET_G - 0x10  // a3 = p4 combo text color (green)
        li      t0, combo_text_map            // t0 = address of combo text map
        sw      a0, 0x0000(t0)                // store p1 combo text color
        sw      a1, 0x0004(t0)                // store p2 combo text color
        sw      a2, 0x0008(t0)                // store p3 combo text color
        sw      a3, 0x000C(t0)                // store p4 combo text color
        addiu   a0, t1, TEXT_OFFSET_S - 0x10  // a0 = unattributed combo text color (silver)
        sw      a0, 0x0010(t0)                // store unattributed combo text color
        addiu   a0, t1, NUMBER_OFFSET_R - 0x10// a0 = p1 combo text color (red)
        addiu   a1, t1, NUMBER_OFFSET_B - 0x10// a1 = p2 combo text color (blue)
        addiu   a2, t1, NUMBER_OFFSET_Y - 0x10// a2 = p3 combo text color (yellow)
        addiu   a3, t1, NUMBER_OFFSET_G - 0x10// a3 = p4 combo text color (green)
        li      t0, combo_numbers_map         // t0 = address of combo numbers map
        sw      a0, 0x0000(t0)                // store p1 combo numbers color
        sw      a1, 0x0004(t0)                // store p2 combo numbers color
        sw      a2, 0x0008(t0)                // store p3 combo numbers color
        sw      a3, 0x000C(t0)                // store p4 combo numbers color
        addiu   a0, t1, NUMBER_OFFSET_S - 0x1010 // a0 = unattributed combo text color (silver), minus 0x1000 to avoid subtraction
        addiu   a0, a0, 0x1000                // a0 = unattributed combo text color (silver), addjusted for 0x1000 subtracted above
        sw      a0, 0x0010(t0)                // store unattributed combo text color

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
        lw      t4, 0x0018(t5)                    // t4 = object struct
        lw      t7, 0x0014(t5)                    // t7 = previous color index

        // Check if player struct address is 0 - if so, don't draw anything
        beqz    a1, _end                          // if (player struct address == 0) then skip to _end
        nop                                       // ~

        // always toggle off the display list - we will turn it back on below if necessary
        lli     t0, 0x0001                        // t0 = 1
        sw      t0, 0x007C(t4)                    // turn off display list render

        // Check if currently in a combo (hit count > 1)
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
        // make sure the display list is set to render
        sw      r0, 0x007C(t4)

        // set up texture data pointers
        lw      t0, 0x0010(t5)                    // t0 - color index (0 = silver, 1 = p1, 2 = p2, 3 = p3, 4 = p4)
        sll     t1, t0, 0x0002                    // t1 = color index * 4 = offset in color maps
        li      t2, combo_text_map                // t2 = combo_text_map address
        addu    t2, t2, t1                        // t2 = address of texture address
        lw      a2, 0x0000(t2)                    // a2 = combo text texture address
        li      t2, combo_numbers_map             // t2 = combo_numbers_map address
        addu    t2, t2, t1                        // t2 = address of numbers texture address
        lw      at, 0x0000(t2)                    // at = address of numbers texture
        lw      t0, 0x0074(t4)                    // t0 = address of combo text image struct
        sw      a2, 0x0044(t0)                    // set combo text image address
        lw      t0, 0x0008(t0)                    // t0 = address of combo number image struct, 1st digit
        sltiu   t6, a0, 1000                      // t6 = 1 if hitcount <= 999
        beqzl   t6, pc() + 8                      // if hitcount > 999, then stay at 999
        lli     a0, 999                           // a0 = 999
        lli     t6, 0x000A                        // t6 = 10
        div     a0, t6                            // divide hitcount by 10
        mfhi    t2                                // t2 = last digit
        mflo    t3                                // t3 = 0 if < 10
        div     t3, t6                            // divide hitcount by 100, essentially
        mfhi    t3                                // t3 = 2nd digit
        mflo    t4                                // t4 = 1st digit

        lli     t5, NUMBER_OFFSET                 // t5 = NUMBER_OFFSET

        multu   t4, t5                            // calculate offset in texture file of first digit
        mflo    t6                                // t6 = offset
        addu    a1, at, t6                        // a1 = address of 1st digit's texture
        multu   t3, t5                            // calculate offset in texture file of second digit
        mflo    t6                                // t6 = offset
        addu    a2, at, t6                        // a1 = address of 2nd digit's texture
        multu   t2, t5                            // calculate offset in texture file of third digit
        mflo    t6                                // t6 = offset
        addu    a3, at, t6                        // a2 = address of 3rd digit's texture

        bnez    t4, _set_number_textures          // if > 100, go ahead and draw
        nop                                       // otherwise, last digit should be hidden and the others shifted left
        or      a1, r0, a2                        // 2nd digit -> 1st digit
        or      a2, r0, a3                        // 3rd digit -> 2nd digit
        or      a3, r0, r0                        // don't display 3rd digit

        bnez    t3, _set_number_textures          // if > 10, go ahead and draw
        nop                                       // otherwise, 2nd digit should be hidden and the others shifted left
        or      a1, r0, a2                        // 2nd digit -> 1st digit
        or      a2, r0, r0                        // don't display 2nd digit

        _set_number_textures:
        sw      a1, 0x0044(t0)                    // set combo number image address
        lw      t1, 0x0008(t0)                    // t1 = address of combo number image struct, 2nd digit
        sw      a2, 0x0044(t1)                    // set combo number image address
        lw      t1, 0x0008(t1)                    // t1 = address of combo number image struct, 3rd digit
        sw      a3, 0x0044(t1)                    // set combo number image address

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
        jal     ComboMeter.draw_hit_count_     // draw combo meter
        nop
    }

    // @ Description
    // This macro checks if the given port is a man/cpu and increments player count
    // accordingly. Then it sets up the tables needed for swapping the combo meter
    // in singles and also stores the correct player struct address.
    macro port_check(port, next) {
        // t1 = player_count
        // t8 = x_coord_table
        // t9 = combo_struct_table
        li      t2, Global.match_info
        lw      t2, 0x0000(t2)                   // t2 = match info
        lli     a0, {port} - 1                   // a0 = player struct index, (p1 = 0, p4 = 3)
        lli     t3, 0x0074                       // t3 = size of struct
        multu   a0, t3
        mflo    t3                               // t3 = offset for this port
        addu    t2, t2, t3                       // t2 = address of player match struct
        lbu     t3, 0x0022(t2)                   // t3 = player type (0 = man, 1 = cpu, 2 = n/a)
        sltiu   t4, t3, 0x0002                   // t4 = 1 if man/cpu
        beqz    t4, {next}                       // if not man/cpu then skip
        nop
        jal     Character.port_to_struct_        // v0 = player struct address
        nop
        addu    t1, t1, t4                       // player_count++
        li      t4, combo_struct_p{port}         // t4 = combo struct address for right/left port
        sw      v0, 0x0020(t4)                   // store address of player struct
        sltiu   t5, t1, 0x0003                   // if (>=3 players) then not singles so don't set up swap tables
        beqz    t5, {next}                       // ~
        nop                                      // ~
        lw      t5, 0x0018(t4)                   // t5 = x coord for left/right port
        sw      t5, 0x0000(t8)                   // store x coord for left/right port
        addiu   t8, t8, 0x0004                   // t8 = x_coord_table++
        sw      t4, 0x0000(t9)                   // store combo struct address for right/left port
        lli     a0, {port} - 1                   // a0 = player struct index, (p1 = 0, p4 = 3)
        sw      a0, 0x0008(t9)                   // store port address for left/right port
        addiu   t9, t9, 0x0004                   // t9 = combo_struct_table++
    }

    // @ Description
    // This runs every once per match and sets up the display lists and combo structs
    scope setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        b       _guard                      // check if toggle is on
        nop

        _toggle_off:
        b       _end                        // toggle is off, skip to end
        nop

        _swap_toggle_off:
        b       _register_textures          // swap toggle is off, skip to _register_textures
        nop

        _guard:
        // If combo meter is off, skip to _end and don't draw hit counts
        Toggles.guard(Toggles.entry_combo_meter, _toggle_off)

        // First, load the combo textures file
        li      a1, file_address            // a1 = file_address (array of file RAM addresses to use for later referencing)
        jal     Render.load_file_
        lli     a0, File.VS_COMBO_METER_TEXTURES // a0 = file containing combo meter textures

        lli     t1, 0x0000                  // t1 = player_count

        // We swap hit count meter location for 1v1, so the next few blocks check
        // how many players there are and set up tables for the left and right
        // player ports. This is only run once per match.
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
        // If 1v1 swap is off, skip to _register_textures
        Toggles.guard(Toggles.entry_1v1_combo_meter_swap, _swap_toggle_off)

        lli     t5, 0x0002                  // t5 = 2
        bne     t1, t5, _register_textures  // if (player_count != 2) then not singles
        nop

        _swap_for_singles:
        li      t8, x_coord_table           // t8 = address of x_coord_table
        li      t9, combo_struct_table      // t9 = address of combo_struct_table
        li      t2, combo_struct_map        // t2 = address of combo_struct_map
        lw      t0, 0x0000(t8)              // t0 = left player x_coord
        lw      t1, 0x0004(t9)              // t1 = left player combo_struct address
        sw      t0, 0x0018(t1)              // update combo_struct_pX with x coord for left player
        lw      t0, 0x0008(t9)              // t0 = left player port
        sll     t0, t0, 0x0002              // t0 = offset in combo_struct_map
        addu    t0, t2, t0                  // t0 = address in combo_struct_map
        sw      t1, 0x0000(t0)              // save swapped combo_struct_pX in combo_struct_map
        lw      t0, 0x0004(t8)              // t0 = right player x_coord
        lw      t1, 0x0000(t9)              // t1 = right player combo_struct address
        sw      t0, 0x0018(t1)              // update combo_struct_pX with x coord for right player
        lw      t0, 0x000C(t9)              // t0 = right player port
        sll     t0, t0, 0x0002              // t0 = offset in combo_struct_map
        addu    t0, t2, t0                  // t0 = address in combo_struct_map
        sw      t1, 0x0000(t0)              // save swapped combo_struct_pX in combo_struct_map

        _register_textures:
        // loop over combo struct and set up linked lists for combo textures
        lli     s0, 0x0001                  // s0 = port
        li      s1, combo_struct_p1         // s1 = combo_struct address
        li      s2, run_                    // s2 = run_ (will get set on first registered object)

        _loop:
        lw      t0, 0x0020(s1)              // t0 = player struct address
        beqz    t0, _next                   // if no player struct, skip
        nop

        addiu   a0, r0, 0x03FE              // a0 = unique ID for this linked list
        addiu   a2, r0, 0x000B              // a2 = linked list to append? this ensures the meter is not rendered during pause
        or      a1, r0, s2                  // a1 = routine to run every frame
        jal     0x80009968
        lui     a3, 0x8000

        addu    s3, v0, r0                  // save RAM location of object struct

        // Set up object struct
        addiu   sp, sp, -0x0020             // allocate stack space
        addiu   a0, r0, 0xFFFF              // a0 = -1
        sw      a0, 0x0010(sp)              // 0x0010(sp) = -1 (not sure why)
        addu    a0, r0, s3                  // a0 = RAM address of object block
        addiu   a2, r0, 0x0018              // a2 = room? z-index? set high to render on top of other elements
        li      a1, 0x800CCF00              // a1 = RAM address of display list render routine to use
        jal     0x80009DF4
        lui     a3, 0x8000
        addiu   sp, sp, 0x0020              // deallocate stack space

        // Only register run_ to run every frame once
        lli     s2, 0x0000

        // Copy combo text image footer data into struct
        addu    a0, r0, s3                  // a0 = RAM address of object block
        li      a1, file_address            // a1 = pointer to RAM address of custom image file
        lw      a1, 0x0000(a1)              // a1 = RAM address of custom image file
        addiu   a1, a1, TEXT_OFFSET_R       // a1 = RAM address of image footer struct plus 0x10
        jal     0x800CCFDC                  // v0 = RAM address of texture struct
        nop

        lw      a1, 0x0018(s1)              // a1 = P{s0}_COMBO_METER_X_COORD
        sw      a1, 0x0058(v0)              // set X position
        lui     a1, COMBO_METER_Y_COORD
        sw      a1, 0x005C(v0)              // set Y position
        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur

        // Copy combo number image footer data into struct (1st digit)
        addu    a0, r0, s3                  // a0 = RAM address of object block
        li      a1, file_address            // a1 = pointer to RAM address of custom image file
        lw      a1, 0x0000(a1)              // a1 = RAM address of custom image file
        addiu   a1, a1, NUMBER_OFFSET_R     // a1 = RAM address of image footer struct plus 0x10
        jal     0x800CCFDC
        nop

        lw      a1, 0x0018(s1)              // a1 = P{s0}_COMBO_METER_X_COORD
        mtc1    a1, f4                      // f4 = a1
        lui     a1, COMBO_METER_NUMBERS_OFFSET
        mtc1    a1, f6                      // f6 = COMBO_METER_NUMBERS_OFFSET
        add.s   f4, f4, f6                  // f4 = P{s0}_COMBO_METER_X_COORD + COMBO_METER_NUMBERS_OFFSET
        mfc1    s4, f4                      // s4 = X position
        sw      s4, 0x0058(v0)              // set X position
        lui     a1, COMBO_METER_Y_COORD
        sw      a1, 0x005C(v0)              // set Y position
        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur

        // Copy combo number image footer data into struct (2nd digit)
        addu    a0, r0, s3                  // a0 = RAM address of object block
        li      a1, file_address            // a1 = pointer to RAM address of custom image file
        lw      a1, 0x0000(a1)              // a1 = RAM address of custom image file
        addiu   a1, a1, NUMBER_OFFSET_R     // a1 = RAM address of image footer struct plus 0x10
        jal     0x800CCFDC
        nop

        mtc1    s4, f4                      // f4 = X position of 1st digit
        lui     a1, COMBO_METER_NUMBER_OFFSET
        mtc1    a1, f6                      // f6 = COMBO_METER_NUMBER_OFFSET
        add.s   f4, f4, f6                  // f4 = X position of 1st digit + COMBO_METER_NUMBER_OFFSET
        mfc1    s4, f4                      // s4 = X position
        sw      s4, 0x0058(v0)              // set X position
        lui     a1, COMBO_METER_Y_COORD
        sw      a1, 0x005C(v0)              // set Y position
        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur

        // Copy combo number image footer data into struct (3rd digit)
        addu    a0, r0, s3                  // a0 = RAM address of object block
        li      a1, file_address            // a1 = pointer to RAM address of custom image file
        lw      a1, 0x0000(a1)              // a1 = RAM address of custom image file
        addiu   a1, a1, NUMBER_OFFSET_R     // a1 = RAM address of image footer struct plus 0x10
        jal     0x800CCFDC
        nop

        mtc1    s4, f4                      // f4 = X position of 1st digit
        lui     a1, COMBO_METER_NUMBER_OFFSET
        mtc1    a1, f6                      // f6 = COMBO_METER_NUMBER_OFFSET
        add.s   f4, f4, f6                  // f4 = X position of 1st digit + COMBO_METER_NUMBER_OFFSET
        mfc1    s4, f4                      // s4 = X position
        sw      s4, 0x0058(v0)              // set X position
        lui     a1, COMBO_METER_Y_COORD
        sw      a1, 0x005C(v0)              // set Y position
        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur

        // store object address for easy display toggling
        sw      s3, 0x0018(s1)

        // turn off display initially
        lli     t0, 0x0001                  // t0 = 1
        sw      t0, 0x007C(s3)              // turn off display list render

        _next:
        sltiu   t0, s0, 0x0004              // t0 = 1 if s0 less than 4
        addiu   s1, s1, 0x0038              // s1 = combo_struct_p{s0 + 1}
        bnez    t0, _loop                   // if not through all yet, increment and loop
        addiu   s0, s0, 0x0001              // s0++

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        x_coord_table:
        dw 0x00                             // left player x_coord (singles)
        dw 0x00                             // right player x_coord (singles)

        combo_struct_table:
        dw 0x00                             // right player combo struct address (singles)
        dw 0x00                             // left player combo struct address (singles)

        port_table:
        dw 0x00                             // left player port
        dw 0x00                             // right player port
    }

    // @ Description
    // This runs every frame and will draw the combo meter if appropriate
    scope run_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        lui     v0, 0x8004
        lw      v0, 0x671C(v0)              // v0 = pointer to start of linked list of HUD when not paused
        lw      v0, 0x007C(v0)              // v0 = 1 when paused, 0 when not paused
        bnez    v0, _end                    // if paused, then skip drawing combo meters
        nop

        _draw_hit_counts:
        draw_hit_count(1)                   // draw combo meter for port 1
        draw_hit_count(2)                   // draw combo meter for port 2
        draw_hit_count(3)                   // draw combo meter for port 3
        draw_hit_count(4)                   // draw combo meter for port 4

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // This hides the combo meter when SCORE +/-1 is displayed for a port
    scope hide_for_score_sprite_: {
        OS.patch_start(0x901D8, 0x801149D8)
        jal     hide_for_score_sprite_
        lui     v1, 0x8013                  // original line 1
        OS.patch_end()

        // v0 = port
        OS.read_word(Toggles.entry_combo_meter + 0x4, t0) // t0 = combo meter boolean
        beqz    t0, _end                    // if combo meter not active, skip
        lli     t1, 0x0016                  // t1 = VS screen_id
        OS.read_byte(Global.current_screen, t0) // t0 = current screen_id
        bne     t0, t1, _end                // skip if not VS
        sll     t1, v0, 0x0002              // t1 = offset to combo struct
        li      t0, combo_struct_map
        addu    t0, t0, t1                  // t0 = combo struct address
        lw      t0, 0x0000(t0)              // t0 = combo struct
        sw      r0, 0x001C(t0)              // clear frame buffer

        _end:
        jr      ra
        addiu   v1, v1, 0x1580              // original line 2
    }
} // ComboMeter
} // __COMBO_METER__
