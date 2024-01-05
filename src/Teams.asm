// Teams.asm
if !{defined __TEAMS__} {
define __TEAMS__()
print "included Teams.asm\n"

// @ Description
// Extends teams to new colors.
// Really only works for yellow - more work would need to be done to support more colors.
// When adding new teams, need to update the following manually:
// - ComboMeter.team_offset_table
// - Shield.color_fix_.table_team
// - Spawn.valid_teams

scope Teams {
    // @ Description
    // Number of added teams and number of overall teams
    constant NUM_NEW_TEAMS(1)
    constant NUM_TEAMS(NUM_NEW_TEAMS + 3)

    // @ Description
    // Team button offset table extended with new team button offsets
    team_button_table:
    constant TEAM_BUTTON_TABLE_ORIGIN(origin())
    OS.copy_segment(0x139814, 0xC) // original table 0x8013B594
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Team panel color table extended with new team colors
    // NOTE: We would have do more work to get something beyond the original four panel colors
    team_panel_table:
    constant TEAM_PANEL_TABLE_ORIGIN(origin())
    OS.copy_segment(0x139A58, 0xC) // original table 0x8013B7D8
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Holds costume_ids by character for added teams
    new_costume_table:
    constant NEW_COSTUME_TABLE_ORIGIN(origin())
    fill Character.NUM_CHARACTERS * NUM_NEW_TEAMS
    OS.align(4)

    // @ Description
    // Team port color table extended with new team colors
    // I don't think it's possible to have a team where one player is gray, which is in the
    // original table, so I just don't copy that.
    // NOTE: We would have do more work to get something beyond the original four port colors
    team_port_color_table:
    constant TEAM_PORT_COLOR_TABLE_ORIGIN(origin())
    OS.copy_segment(0xAA740, 0x3) // original table 0x8012EF40
    fill NUM_NEW_TEAMS
    OS.align(4)

    // @ Description
    // Results screen team name string table
    team_name_table:
    constant TEAM_NAME_TABLE_ORIGIN(origin())
    OS.copy_segment(0x158720, 0xC) // original table 0x80139580
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Results screen team name x position table
    team_name_x_position_table:
    constant TEAM_NAME_X_POSITION_TABLE_ORIGIN(origin())
    OS.copy_segment(0x158744, 0xC) // original table 0x801395A4
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Results screen team name scale table
    // Fixes hard coded 1.0 for all teams
    team_name_scale_table:
    constant TEAM_NAME_SCALE_TABLE_ORIGIN(origin())
    float32 1.0
    float32 1.0
    float32 1.0
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Maps team_id to big text palette index
    team_name_palette_index_table:
    constant TEAM_NAME_PALETTE_INDEX_TABLE_ORIGIN(origin())
    db 0
    db 1
    db 2
    fill NUM_NEW_TEAMS
    OS.align(4)

    // @ Description
    // Team name color palette table extended with new team colors
    big_text_palette_table:
    constant BIG_TEXT_PALETTE_TABLE_ORIGIN(origin())
    OS.copy_segment(0x158634, 0x1E) // original table 0x80139494
    fill NUM_NEW_TEAMS * 6
    OS.align(4)

    // @ Description
    // Announcer team name fgm_id table
    team_name_fgm_table:
    constant TEAM_NAME_FGM_TABLE_ORIGIN(origin())
    dw FGM.announcer.team.RED
    dw FGM.announcer.team.BLUE
    dw FGM.announcer.team.GREEN
    fill NUM_NEW_TEAMS * 4

    // @ Description
    // Helper for add_team macro
    variable current_team_index(2)

    // @ Description
    // Team shadow colour array
    team_shadow_colors:
    dw 0x800000B4   // red team
    dw 0x000080B4   // green team
    dw 0x008000B4   // blue team
    dw 0x808000B4   // yellow team

    // @ Description
    // Replaces hard coded address with extended table
    OS.patch_start(0xB615C, 0x8013B71C)
    li      t6, team_shadow_colors
    OS.patch_end()

    // @ Description
    // Adds a new team
    macro add_team(team_name, button_offset, panel_offset, team_x_position, team_scale, team_name_prim_color, team_name_sec_color, fgm_id) {
        global variable current_team_index(current_team_index + 1)
        global evaluate TEAM_INDEX_{team_name}(current_team_index)

        OS.patch_start(TEAM_BUTTON_TABLE_ORIGIN + (current_team_index * 4), team_button_table + (current_team_index * 4))
        dw {button_offset}
        OS.patch_end()

        OS.patch_start(TEAM_PANEL_TABLE_ORIGIN + (current_team_index * 4), team_panel_table + (current_team_index * 4))
        dw {panel_offset}
        OS.patch_end()

        OS.patch_start(TEAM_PORT_COLOR_TABLE_ORIGIN + current_team_index, team_port_color_table + current_team_index)
        db {panel_offset}
        OS.patch_end()

        team_{team_name}_string:; db "{team_name}", 0
        OS.align(4)

        OS.patch_start(TEAM_NAME_TABLE_ORIGIN + (current_team_index * 4), team_name_table + (current_team_index * 4))
        dw team_{team_name}_string
        OS.patch_end()

        OS.patch_start(TEAM_NAME_X_POSITION_TABLE_ORIGIN + (current_team_index * 4), team_name_x_position_table + (current_team_index * 4))
        dw {team_x_position}
        OS.patch_end()

        OS.patch_start(TEAM_NAME_SCALE_TABLE_ORIGIN + (current_team_index * 4), team_name_scale_table + (current_team_index * 4))
        dw {team_scale}
        OS.patch_end()

        OS.patch_start(TEAM_NAME_PALETTE_INDEX_TABLE_ORIGIN + current_team_index, team_name_palette_index_table + current_team_index)
        db current_team_index + 2
        OS.patch_end()

        OS.patch_start(BIG_TEXT_PALETTE_TABLE_ORIGIN + ((current_team_index + 2) * 6), big_text_palette_table + ((current_team_index + 2) * 6))
        db {team_name_prim_color} >> 24           // red
        db ({team_name_prim_color} >> 16) & 0xFF // green
        db ({team_name_prim_color} >> 8) & 0xFF  // blue
        db {team_name_sec_color} >> 24            // red
        db ({team_name_sec_color} >> 16) & 0xFF  // green
        db ({team_name_sec_color} >> 8) & 0xFF   // blue
        OS.patch_end()

        OS.patch_start(TEAM_NAME_FGM_TABLE_ORIGIN + (current_team_index * 4), team_name_fgm_table + (current_team_index * 4))
        dw {fgm_id}
        OS.patch_end()

        print "\nAdded {team_name} team.\n"
    }

    // @ Description
    // Adds a team costume for the given character.
    // Can be used outside of file.
    // @ Arguments
    // team - the team name, e.g. YELLOW
    // char - the char name, e.g. MARIO
    // costume_id - the costume_id of the character to use
    macro add_team_costume(team, char, costume_id) {
        evaluate t({Teams.TEAM_INDEX_{team}} - 3)

        OS.patch_start(Teams.NEW_COSTUME_TABLE_ORIGIN + (Teams.NUM_NEW_TEAMS * Character.id.{char}) + {t}, Teams.new_costume_table + (Teams.NUM_NEW_TEAMS * Character.id.{char}) + {t})
        db {costume_id}
        OS.patch_end()
    }

    // Add new teams here
    //       name    btn      idx  x position  scale       prim color  sec color   fgm_id
    add_team(YELLOW, 0x1F648, 0x2, 0x41D00000, 0x3F600000, 0xFFBF0000, 0xFFFFFF00, FGM.announcer.team.YELLOW)

    // Add Vanilla char costumes here
    //               team    char        costume_id
    add_team_costume(YELLOW, MARIO,      0x7)
    add_team_costume(YELLOW, FOX,        0x6)
    add_team_costume(YELLOW, DK,         0x7)
    add_team_costume(YELLOW, SAMUS,      0x7)
    add_team_costume(YELLOW, LUIGI,      0x6)
    add_team_costume(YELLOW, LINK,       0x5)
    add_team_costume(YELLOW, YOSHI,      0x3)
    add_team_costume(YELLOW, FALCON,     0x6)
    add_team_costume(YELLOW, KIRBY,      0x1)
    add_team_costume(YELLOW, PIKACHU,    0x6)
    add_team_costume(YELLOW, JIGGLY,     0x6)
    add_team_costume(YELLOW, NESS,       0x1)
    // add_team_costume(YELLOW, BOSS,       0x2)
    add_team_costume(YELLOW, METAL,      0x4)
    add_team_costume(YELLOW, NMARIO,     0x6)
    add_team_costume(YELLOW, NFOX,       0x6)
    add_team_costume(YELLOW, NDONKEY,    0x6)
    add_team_costume(YELLOW, NSAMUS,     0x6)
    add_team_costume(YELLOW, NLUIGI,     0x6)
    add_team_costume(YELLOW, NLINK,      0x6)
    add_team_costume(YELLOW, NYOSHI,     0x6)
    add_team_costume(YELLOW, NCAPTAIN,   0x6)
    add_team_costume(YELLOW, NKIRBY,     0x6)
    add_team_costume(YELLOW, NPIKACHU,   0x6)
    add_team_costume(YELLOW, NJIGGLY,    0x6)
    add_team_costume(YELLOW, NNESS,      0x6)
    add_team_costume(YELLOW, GDONKEY,    0x7)

    // regional variants for ease here
    add_team_costume(YELLOW, JMARIO,     0x7)
    add_team_costume(YELLOW, JFOX,       0x6)
    add_team_costume(YELLOW, JDK,        0x7)
    add_team_costume(YELLOW, JSAMUS,     0x7)
    add_team_costume(YELLOW, ESAMUS,     0x7)
    add_team_costume(YELLOW, JLUIGI,     0x6)
    add_team_costume(YELLOW, JLINK,      0x5)
    add_team_costume(YELLOW, ELINK,      0x5)
    add_team_costume(YELLOW, JYOSHI,     0x3)
    add_team_costume(YELLOW, JFALCON,    0x6)
    add_team_costume(YELLOW, JKIRBY,     0x1)
    add_team_costume(YELLOW, JPIKA,      0x6)
    add_team_costume(YELLOW, EPIKA,      0x6)
    add_team_costume(YELLOW, JPUFF,      0x6)
    add_team_costume(YELLOW, EPUFF,      0x6)
    add_team_costume(YELLOW, JNESS,      0x1)

    // ***************************************************************************

    // @ Description
    // Use extended team button offset table
    scope use_extended_team_table_: {
        OS.patch_start(0x130A38, 0x801327B8)
        jal     use_extended_team_table_
        sll     t4, t3, 0x0002              // original line 1 - t4 = offset in table
        lw      t5, 0x0000(t5)              // t5 = offset
        OS.patch_end()

        li      t5, team_button_table       // t5 = team button offset table
        jr      ra
        addu    t5, t5, t4                  // t5 = address of offset
    }

   // @ Description
    // Use extended team panel color table
    scope use_extended_panel_table_: {
        // Handle button press
        OS.patch_start(0x133990, 0x80135710)
        jal     use_extended_panel_table_
        sll     t8, t7, 0x0002              // original line 1 - t8 = offset in table
        jal     0x801332AC                  // original line 3 - change panel color
        lw      a1, 0x0000(a1)              // original line 4, modified - a1 = panel color index
        OS.patch_end()

        // Handle screen load
        OS.patch_start(0x131AB4, 0x80133834)
        li      a1, team_panel_table        // a1 = team panel color table
        sll     at, v0, 0x0002              // at = offset in table
        addu    a1, a1, at                  // a1 = address of panel color index
        lw      a1, 0x0000(a1)              // a1 = panel color index
        OS.patch_end()

        // Handle FFA/Team Battle toggle
        OS.patch_start(0x13346C, 0x801351EC)
        li      s2, team_panel_table        // s2 = team panel color table
        lw      v0, 0x0040(s0)              // original line 2 - v0 = team_id
        sll     at, v0, 0x0002              // at = offset in table
        addu    a1, s2, at                  // a1 = address of panel color index
        lw      a1, 0x0000(a1)              // a1 = panel color index
        OS.patch_end()
        OS.patch_start(0x1334C8, 0x80135248)
        bne     s1, s4, 0x801351F4          // original line 1, modified to loop correctly based on above change
        OS.patch_end()

        // Handle HMN/CPU button
        OS.patch_start(0x134158, 0x80135ED8)
        li      a1, team_panel_table        // a1 = team panel color table
        sll     at, v0, 0x0002              // at = offset in table
        addu    a1, a1, at                  // a1 = address of panel color index
        lw      a1, 0x0000(a1)              // a1 = panel color index
        OS.patch_end()

        // Not sure - maybe when plugging in controller?
        OS.patch_start(0x134038, 0x80135DB8)
        li      a1, team_panel_table        // a1 = team panel color table
        sll     at, v0, 0x0002              // at = offset in table
        addu    a1, a1, at                  // a1 = address of panel color index
        lw      a1, 0x0000(a1)              // a1 = panel color index
        OS.patch_end()

        li      a1, team_panel_table        // a1 = team panel color table
        jr      ra
        addu    a1, a1, t8                  // a1 = address of panel color index
    }

    // @ Description
    // Allow selecting new team colors
    scope extend_button_click_: {
        OS.patch_start(0x133948, 0x801356C8)
        addiu   s2, r0, NUM_TEAMS - 1       // original line 1, modified - s2 = max team_id
        jal     extend_button_click_
        or      a0, s4, r0                  // original line 3 - s4 = a0
        beql    t6, t5, 0x80135778          // original line 4, modified to use t6 instead of s2 - skip if panel closed
        OS.patch_end()

        lli     t6, 0x0002                  // t6 = panel state closed
        jr      ra
        lw      t5, 0x0084(s1)              // original line 2 - t5 = panel state
    }

    // @ Description
    // Extend team costume getter
    scope get_team_costume_: {
        OS.patch_start(0x67904, 0x800EC104)
        j       get_team_costume_
        sll     t6, a0, 0x0003              // original line 1 - t6 = char_id * 8 = offset to char's default costume array
        _return:
        OS.patch_end()

        // a0 = char_id
        // a1 = team_id

        sltiu   t7, a1, 0x0003              // t7 = 1 if an original team_id
        bnez    t7, _normal                 // if an original team_id, do original code
        lli     t7, NUM_NEW_TEAMS

        multu   t7, a0                      // mflo = offset to team costume array for this char
        li      t7, new_costume_table
        addiu   t6, a1, -0x0003             // t6 = index in array
        addu    t7, t7, t6                  // t7 = new_costume_table adjusted for index
        mflo    t6                          // t6 = offset to team costume array for this char
        addu    t7, t7, t6                  // t7 = address of costume for this added team

        jr      ra                          // return from routine
        lbu     v0, 0x0000(t7)              // v0 = costume_id of new team

        // here, get from new table

        _normal:
        j       _return
        addu    t7, t6, a1                  // original line 2 - t7 = offset to costume_id
    }

    // @ Description
    // This fixes Classic Sonic's yellow team costume on VS CSS
    scope classic_sonic_costume_fix_: {
        // toggling from FFA to Team Battle
        OS.patch_start(0x1334A4, 0x80135224)
        j       classic_sonic_costume_fix_._team_battle_toggle
        nop
        nop
        _team_battle_return:
        OS.patch_end()

        // team button toggle
        OS.patch_start(0x1339C4, 0x80135744)
        j       classic_sonic_costume_fix_._team_button_toggle
        nop
        nop
        _team_button_return:
        OS.patch_end()

        // hovering over icon as cpu token/toggling from hmn to cpu
        OS.patch_start(0x132B54, 0x801348D4)
        j       classic_sonic_costume_fix_._cpu_select
        lw      a1, 0xBAC8(a1)              // original line 2 - a1 = team_id
        _cpu_select_return:
        OS.patch_end()

        _team_battle_toggle:
        // v0 = costume_id
        // s1 = port
        // a0 = char_id
        // a1 = team_id

        lli     at, Character.id.SONIC
        bne     a0, at, _team_battle_end    // if not Sonic, skip
        lli     at, 0x0003                  // at = yellow team_id
        bne     a1, at, _team_battle_end    // if not yellow team, skip
        // use delay slot for first half of li
        li      a0, Sonic.classic_table     // a0 = classic_table
        addu    a0, a0, s1                  // a0 = classic_table + port
        lbu     a0, 0x0000(a0)              // a0 = px is_classic
        bnezl   a0, _team_battle_end        // if classic Sonic, use different costume_id
        lli     v0, 0x0001                  // v0 = classic Sonic yellow team_id

        _team_battle_end:
        sw      v0, 0x004C(s0)              // original line 1 - save costume_id
        jal     0x80131B78                  // original line 2
        or      a0, s1, r0                  // original line 3 - a0 = port

        j       _team_battle_return
        nop

        _team_button_toggle:
        // v0 = costume_id
        // s0 = port
        // a0 = char_id
        // a1 = team_id

        lli     at, Character.id.SONIC
        bne     a0, at, _team_button_end    // if not Sonic, skip
        lli     at, 0x0003                  // at = yellow team_id
        bne     a1, at, _team_button_end    // if not yellow team, skip
        // use delay slot for first half of li
        li      a0, Sonic.classic_table     // a0 = classic_table
        addu    a0, a0, s0                  // a0 = classic_table + port
        lbu     a0, 0x0000(a0)              // a0 = px is_classic
        bnezl   a0, _team_button_end        // if classic Sonic, use different costume_id
        lli     v0, 0x0001                  // v0 = classic Sonic yellow team_id

        _team_button_end:
        sw      v0, 0x004C(s1)              // original line 1 - save costume_id
        jal     0x80131B78                  // original line 2
        or      a0, s0, r0                  // original line 3 - a0 = port

        j       _team_button_return
        nop

        _cpu_select:
        // a2 = port
        // a0 = char_id
        // a1 = team_id

        lli     at, Character.id.SONIC
        bne     a0, at, _normal             // if not Sonic, skip
        lli     at, 0x0003                  // at = yellow team_id
        bne     a1, at, _normal             // if not yellow team, skip
        // use delay slot for first half of li
        li      at, Sonic.classic_table     // at = classic_table
        addu    at, at, a2                  // at = classic_table + port
        lbu     at, 0x0000(at)              // at = px is_classic
        bnezl   at, _cpu_select_end         // if classic Sonic, use different costume_id
        lli     v0, 0x0001                  // v0 = classic Sonic yellow team_id

        _normal:
        jal     0x800EC104                  // original line 1 - get team costume_id
        nop

        _cpu_select_end:
        j       _cpu_select_return
        nop
    }

    // @ Description
    // Extend port color table
    // This is called when pressing start on CSS
    OS.patch_start(0x138920, 0x8013A6A0)
    li      t3, team_port_color_table
    OS.patch_end()

    // @ Description
    // Extend team name table
    OS.patch_start(0x153624, 0x80134484)
    sw      ra, 0x001C(sp)                  // original line 3
    jal     0x80132A2C                      // original line 28 - v0 = winning team_id
    nop
    sll     v1, v0, 0x0002                  // origingal line 30 - v1 = offset in table
    sw      v0, 0x006C(sp)                  // original line 31 - save winning team_id
    li      at, team_name_scale_table       // at = team_name_scale_table
    addu    at, at, v1                      // at = address of name scale
    lwc1    f4, 0x0000(at)                  // f4 = scale
    li      a0, team_name_table             // original lines 1/2, modified - a0 = extended team name table
    addu    a0, a0, v1                      // a0 = address of name string
    li      t0, team_name_x_position_table  // original line 35, modified - t0 = team_name_x_position_table
    addu    t0, t0, v1                      // t0 = address of x pos
    lw      a1, 0x0000(t0)                  // a1 = x pos
    b       0x80134518                      // jump to rest of routine
    lw      a0, 0x0000(a0)                  // a0 = name
    OS.patch_end()

    // @ Description
    // Results screen series logo color
    scope extend_results_screen_series_logo_color_index_: {
        OS.patch_start(0x151DE4, 0x80132C44)
        jal     extend_results_screen_series_logo_color_index_
        sll     t4, v0, 0x0002              // original line 1 - t4 = offset
        lw      t9, 0x0000(t9)              // original line 3, modified - t9 = series logo color index
        OS.patch_end()

        li      t9, team_panel_table        // we can reuse this table here
        jr      ra
        addu    t9, t9, t4                  // t9 = address of index
    }

    // @ Description
    // Results screen background palette index
    scope extend_results_screen_background_palette_index_: {
        OS.patch_start(0x1521FC, 0x8013305C)
        jal     extend_results_screen_background_palette_index_
        sll     t0, v0, 0x0002              // original line 1 - t0 = offset
        lw      t1, 0x0000(t1)              // original line 3, modified - t1 = background palette index
        OS.patch_end()

        li      t1, team_panel_table        // we can reuse this table here
        jr      ra
        addu    t1, t1, t0                  // t1 = address of index
    }

    // @ Description
    // Team name color
    scope extend_results_team_name_palette_: {
        // use palette index table
        OS.patch_start(0x1536B8, 0x80134518)
        jal     extend_results_team_name_palette_._index
        lui     a2, 0x4334                  //
        OS.patch_end()
        // use extended palette table
        OS.patch_start(0x153300, 0x80134160)
        jal     extend_results_team_name_palette_._palette
        sll     t7, t7, 0x0001              // original line 1 - t7 = offset to palette
        OS.patch_end()

        _index:
        li      a3, team_name_palette_index_table
        addu    a3, a3, v0                  // a3 = address of palette index
        jr      ra
        lbu     a3, 0x0000(a3)              // a3 = palette index

        _palette:
        li      t6, big_text_palette_table  // t6 = extended table
        jr      ra
        addu    s0, t7, t6                  // original line 2 - s0 = palette address
    }

    // @ Description
    // Results screen table column color
    scope extend_results_screen_column_color_index_: {
        OS.patch_start(0x1545F4, 0x80135454)
        j       extend_results_screen_column_color_index_
        sll     t2, t1, 0x0002              // original line 1 - t2 = offset
        _return:
        OS.patch_end()

        li      v1, team_panel_table        // we can reuse this table here
        j       _return
        addu    t3, v1, t2                  // original line 2 - t3 = address of index
    }

    // @ Description
    // Results screen announcer call
    scope extend_results_screen_announcer_: {
        OS.patch_start(0x1511BC, 0x8013201C)
        jal     extend_results_screen_announcer_
        sll     t6, v0, 0x0002              // original line 1 - t6 = offset
        jal     0x800269C0                  // original line 3 - play sfx
        lw      a0, 0x0000(a0)              // original line 4, modified - a0 = fgm_id
        OS.patch_end()

        li      a0, team_name_fgm_table     // a0 = team_name_fgm_table
        jr      ra
        addu    a0, a0, t6                  // original line 2, modified - a0 = address of fgm_id
    }

    // @ Description
    // Results screen winner calculation for teams
    // Note this would need to be modified to expand stack space if we added more teams
    OS.patch_start(0x1563E0, 0x80137240)
    slti    at, s1, 0x0003 + NUM_NEW_TEAMS
    OS.patch_end()
}

} // __TEAMS__
