// Toggles.asm
if !{defined __TOGGLES__} {
define __TOGGLES__()
print "included Toggles.asm\n"

include "Color.asm"
include "Menu.asm"
include "MIDI.asm"
include "OS.asm"
include "SRAM.asm"
include "Stages.asm"

scope Toggles {

    // @ Description
    // Allows function
    macro guard(entry_address, exit_address) {
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      at, 0x0004(sp)              // save at

        define toggleAddress(0x00000000)
        evaluate toggleAddress({entry_address} + 0x04)
        OS.read_word({toggleAddress}, at) // at = toggle value
        bnez    at, pc() + 24               // if (is_enabled), _continue
        nop

        // _end:
        lw      at, 0x0004(sp)              // restore at
        addiu   sp, sp, 0x0008              // deallocate stack space

        // foor hook vs. function
        if ({exit_address} == 0x00000000) {
            jr      ra
        } else {
            j       {exit_address}
        }
        nop

        // _continue:
        lw      at, 0x0004(sp)              // restore at
        addiu   sp, sp, 0x0008              // deallocate stack space
    }

    // @ Description
    // based on toggles.guard. uses default value if mode is 1p, btt, btp, rttf, hrc or any other single player mode.
    // uses logical shift to find out if on a single player mode by looking at pointer @ Global.match_info
    macro single_player_guard(entry_address, exit_address) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0004(sp)              // save at
        sw      v0, 0x0008(sp)              // save v0

        OS.read_word(Global.match_info, at) // at = current match info struct
        lbu     v0, 0x0000(at)
        lli     at, Global.GAMEMODE.BONUS
        beq     at, v0, pc() + 36          // dont use toggle if BONUS
        lli     at, Global.GAMEMODE.CLASSIC
        beq     at, v0, pc() + 28          // dont use toggle if 1P/RTTF
        nop

        // if here, use toggle
        define toggleAddress(0x00000000)
        evaluate toggleAddress({entry_address} + 0x04)
        OS.read_word({toggleAddress}, at)   // at = toggle value
        bnez    at, pc() + 24               // if (is_enabled), _continue
        nop

        // _end:
        lw      at, 0x0004(sp)              // restore at
        lw      v0, 0x0008(sp)              // restore v0
        addiu   sp, sp, 0x0010              // deallocate stack space

        // foor hook vs. function
        if ({exit_address} == 0x00000000) {
            jr      ra
        } else {
            j       {exit_address}
        }
        nop

        // _continue:
        lw      at, 0x0004(sp)              // restore at
        lw      v0, 0x0008(sp)              // restore v0
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // This patch disables functionality on the OPTION screen.
    scope disable_options_functionality_: {
        OS.patch_start(0x0012060C, 0x80132E5C)
        jal     disable_options_functionality_
        addiu   t7, t7, 0x36EC              // original line 1
        OS.patch_end()

        li      t9, normal_options          // t9 = normal options flag
        lbu     t9, 0x0000(t9)              // t9 = 1 if custom toggles
        beqz    t9, _custom                 // if custom toggles, skip
        nop
        jr      ra                          // return as normal
        lw      t9, 0x0000(t7)              // original line 2

        _custom:
        lw      ra, 0x0014(sp)              // ra = original ra
        jr      ra                          // exit original routine
        addiu   sp, sp, 0x0038              // restore stack
    }

    // @ Description
    // The following patches enable a new button on the Mode Select menu
    scope add_mode_select_remix_button_: {
        // Adjust max index from 3 to 4
        OS.patch_start(0x11D942, 0x801329B2)
        dh      0x0004
        OS.patch_end()
        OS.patch_start(0x11D962, 0x801329D2)
        dh      0x0004
        OS.patch_end()
        OS.patch_start(0x11D866, 0x801328D6)
        dh      0x0004
        OS.patch_end()

        // Adjust X position by 19 for all buttons
        OS.patch_start(0x11CB30, 0x80131BA0)
        lui     at, 0x433C              // original was 0x4329
        OS.patch_end()
        OS.patch_start(0x11CB8C, 0x80131BFC)
        lui     at, 0x433C              // original was 0x4329
        OS.patch_end()
        OS.patch_start(0x11CC50, 0x80131CC0)
        lui     at, 0x4313              // original was 0x4300
        OS.patch_end()
        OS.patch_start(0x11CCB0, 0x80131D20)
        lui     at, 0x4313              // original was 0x4300
        OS.patch_end()
        OS.patch_start(0x11CD74, 0x80131DE4)
        lui     at, 0x42D4              // original was 0x42AE
        OS.patch_end()
        OS.patch_start(0x11CDD4, 0x80131E44)
        lui     at, 0x42D4              // original was 0x42AE
        OS.patch_end()
        OS.patch_start(0x11CE98, 0x80131F08)
        lui     at, 0x4282              // original was 0x4238
        OS.patch_end()
        OS.patch_start(0x11CEF8, 0x80131F68)
        lui     at, 0x4282              // original was 0x4238
        OS.patch_end()

        // Adjust X position by 12 for all button labels
        OS.patch_start(0x11CFA4, 0x80132014)
        lui     at, 0x436C              // original was 0x4360
        OS.patch_end()
        OS.patch_start(0x11CFFC, 0x8013206C)
        lui     at, 0x4343              // original was 0x4337
        OS.patch_end()
        OS.patch_start(0x11D054, 0x801320C4)
        lui     at, 0x431A              // original was 0x430E
        OS.patch_end()
        OS.patch_start(0x11D0AC, 0x8013211C)
        lui     at, 0x42E4              // original was 0x42CC
        OS.patch_end()

    }

    // @ Description
    // Flag to indicate if we should show the custom toggles or the normal options page
    // TRUE = normal options, FALSE = custom toggles
    normal_options:
    db OS.TRUE
    OS.align(4)

    // @ Description
    // Keeps track of what menu we're on.
    // 0 = Super Menu
    // 1 = Remix Settings
    // 2 = Gameplay Settings
    // 3 = Music Settings
    // 4 = Stage Settings
    // 5 = Pokemon Settings
    // 6 = Player Tags
    // 7 = Other Screens
    menu_index:
    db 0x0000

    OS.align(4)

    // @ Description
    // Pointer to current submenu header string
    page_title_pointer:
    dw 0x00000000

    // @ Description
    // Pointer to current profile string
    profile_pointer:
    dw 0x00000000

    // @ Description
    // Flag used to reset menu music when exiting custom menu
    reset_menu_music:
    dw OS.FALSE

    // @ Description
    // Helper routine to set the settings button's visibility based on the selected button index
    scope set_settings_button_display_: {
        lui     t0, 0x8013               // t1 = index
        lw      t1, 0x2C88(t0)           // ~
        lli     t2, 0x0004               // t2 = 4 (index of new button)
        lw      t3, 0x2CA8(t0)           // t3 = object struct of new button, unselected
        lw      t4, 0x2CAC(t0)           // t4 = object struct of new button, selected
        lli     t5, 0x0001               // t5 = 1 (display off)
        sw      t5, 0x007C(t3)           // turn of display
        sw      t5, 0x007C(t4)           // turn of display
        beql    t1, t2, pc() + 12        // based on the index, turn the appropriate button on
        sw      r0, 0x007C(t4)
        sw      r0, 0x007C(t3)

        jr      ra
        nop
    }

    // @ Description
    // Shrinks the buttons and text on the mode select screen to make a 5th button fit
    scope rescale_mode_select_buttons_: {
        constant SCALE(0x3F68)
        // Down scroll
        OS.patch_start(0x11D984, 0x801329F4)
        jal     rescale_mode_select_buttons_
        nop
        OS.patch_end()
        // Up scroll
        OS.patch_start(0x11D89C, 0x8013290C)
        jal     rescale_mode_select_buttons_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        jal     0x801324D8                  // original line 1
        nop                                 // original line 2

        jal     rescale_mode_select_buttons_._rescale
        nop

        jal     set_settings_button_display_
        nop

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

        _rescale:
        li      t0, Render.GROUP_TABLE      // t0 = group pointer table
        lw      t0, 0x000C(t0)              // t0 = group 3's first object address
        lui     t1, SCALE                   // t1 = scale

        _loop:
        lw      t2, 0x0074(t0)              // t2 = image struct
        sw      t1, 0x0018(t2)              // set X scale
        sw      t1, 0x001C(t2)              // set Y scale
        lw      t0, 0x0004(t0)              // t0 = next object
        bnez    t0, _loop                   // if there is a next object, loop
        nop                                 // otherwise we're done

        jr      ra
        nop
    }

    // @ Description
    // Overwrites the original routine to allow a 5th button to be used when A/Start is pressed on Mode Select screen.
    scope mode_select_screen_change_: {
        OS.patch_start(0x11D668, 0x801326D8)
        // v0 = index of selected button
        li      t5, SinglePlayerModes.singleplayer_mode_flag    // load single player mode flag address
        sw      r0, 0x0000(t5)              // clear this flag out so nothing carries over to VS
        li      t5, SinglePlayerModes.singleplayer_mode_flag    // load 1p menu page flag address
        sw      r0, 0x0000(t5)              // clear this flag out always start on first page when coming from mode select
        beqzl   v0, _change
        addiu   t5, r0, 0x0008              // 1P Game Mode menu
        lli     at, 0x0001
        beql    v0, at, _change
        addiu   t5, r0, 0x0009              // VS Game Mode menu
        lli     at, 0x0002
        beql    v0, at, _change
        addiu   t5, r0, 0x0039              // Options
        lli     at, 0x0003
        beql    v0, at, _change
        addiu   t5, r0, 0x003A              // Data
        lli     at, 0x0004
        beql    v0, at, _change
        addiu   t5, r0, 0x0039              // Settings

        // probably not necessary, but a catch-all
        j       0x80132A00
        lw      ra, 0x0014(sp)

        _change:
        sltiu   at, at, 0x0004              // 0 if custom options should be displayed
        li      v1, normal_options          // v1 = normal options flag
        sb      at, 0x0000(v1)              // set normal options flag
        li      v1, Global.current_screen
        lbu     t4, 0x0000(v1)              // t4 = current screen
        sb      t4, 0x0001(v1)              // set previous screen to current value
        sb      t5, 0x0000(v1)              // set next screen
        jal     0x800269C0                  // play sound
        addiu   a0, r0, 0x009E
        jal     0x80005C74
        nop
        j       0x80132A00
        lw      ra, 0x0014(sp)
        OS.patch_end()
    }

    // @ Description
    // Sets the correct index when coming from options
    OS.patch_start(0x11D4F8, 0x80132568)
    beq     v0, at, 0x801325C0              // original line 1, altered to jump to 0x801325C0
    lli     t8, 0x0000                      // t8 = 0 (index)
    lli     at, 0x0009                      // original line 2
    beq     v0, at, 0x801325C0              // original line 3, altered to jump to 0x801325C0
    lli     t8, 0x0001                      // t8 = 1 (index)
    lli     at, 0x0039                      // original line 5
    beq     v0, at, _options                // original line 6, altered to jump to _options
    lli     t8, 0x0002                      // t8 = 1 (index)
    lli     at, 0x003A                      // original line 8
    beq     v0, at, 0x801325C0              // original line 9, altered to jump to 0x801325C0
    lli     t8, 0x0003                      // t8 = 1 (index)
    b       0x801325C0                      // original line 11, altered to jump to 0x801325C0
    lli     t8, 0x0000                      // t8 = 0 (index)
    _options:
    li      at, normal_options              // at = normal options flag
    lbu     at, 0x0000(at)                  // ~
    beqzl   at, 0x801325C0                  // if normal options flag was false,
    lli     t8, 0x0004                      // then use new button index
    b       0x801325C0                      // continue to where t8 is stored as index
    nop
    OS.patch_end()

    // @ Description
    // Creates the custom objects for the mode select screen (5th button)
    scope mode_select_setup_: {
        constant SETTINGS_OFFSET(0x9748)
        constant SETTINGS_OFFSET_SELECTED(0x9080)
        constant SETTINGS_LABEL_OFFSET(0x99B0)

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        // Render unselected icon
        Render.draw_texture_at_offset(1, 3, 0x80132D6C, SETTINGS_OFFSET, Render.NOOP, 0x41C00000, 0x432E0000, 0x969696FF, 0x00000000, 0x3F800000)
        lui     t0, 0x8013
        sw      v0, 0x2CA8(t0)              // store object pointer in free memory
        Render.draw_texture_at_offset(1, 3, 0x80132D6C, SETTINGS_OFFSET_SELECTED, Render.NOOP, 0x41C00000, 0x432E0000, 0xFFFFFFFF, 0x00000000, 0x3F800000)
        lui     t0, 0x8013
        sw      v0, 0x2CAC(t0)              // store object pointer in free memory
        Render.draw_texture_at_offset(1, 3, 0x80132D6C, SETTINGS_LABEL_OFFSET, Render.NOOP, 0x42900000, 0x43470000, 0xFF0000FF, 0x00000000, 0x3F800000)

        // rescale all the buttons on load
        jal     rescale_mode_select_buttons_._rescale
        nop

        // update display state of each new button icon
        jal     set_settings_button_display_
        nop

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Increases the available object heap space on the options screen.
    // This is necessary to support when there are lots of long strings.
    // Can probably reduce how much is added, but shouldn't hurt anything.
    OS.patch_start(0x120EE0, 0x80134944)
    dw      0x0000EA60 + 0x2000                 // pad object heap space (0x0000EA60 is original amount)
    OS.patch_end()

    // @ Description
    // Sets up the custom objects for the custom settings menu
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      t9, normal_options          // t9 = normal options flag
        lbu     t9, 0x0000(t9)              // t9 = 0 if custom toggles
        bnez    t9, _end                    // skip if not custom
        nop

        li      t0, reset_menu_music
        sw      r0, 0x0000(t0)              // initialize flag for resetting menu music

        Render.load_font()
        Render.load_file(0x4E, Render.file_pointer_1)                 // load option images
        Render.load_file(File.REMIX_MENU_BG, Render.file_pointer_2)   // load remix menu bg
        Render.load_file(0xC5, Render.file_pointer_3)                 // load button images into file_pointer_3
        Render.load_file(File.CSS_IMAGES, Render.file_pointer_4)      // load CSS images into file_pointer_4

        Render.draw_rectangle(3, 0, 10, 10, 300, 220, 0x000000FF, OS.FALSE)

        Render.draw_texture_at_offset(3, 12, Render.file_pointer_1, 0xB40, Render.NOOP, 0x41C00000, 0x41880000, 0x5F5846FF, 0x00000000, 0x3F800000)
        Render.draw_rectangle(3, 12, 43, 24, 60, 16, 0x000000FF, OS.FALSE)
        Render.draw_string(3, 12, settings, Render.NOOP, 0x42320000, 0x41E40000, 0x5F5846FF, 0x3F600000, Render.alignment.LEFT)
        Render.draw_string_pointer(3, 12, page_title_pointer, Render.update_live_string_, 0x43900000, 0x41A80000, 0xF2C70DFF, 0x3FB00000, Render.alignment.RIGHT)
        Render.draw_texture_at_offset(3, 19, Render.file_pointer_3, Render.file_c5_offsets.R, Render.NOOP, 0x43830000, 0x42180000, 0x848484FF, 0x303030FF, 0x3F700000)
        Render.draw_texture_at_offset(3, 19, 0x801338B0, 0xDD90, Render.NOOP, 0x438C0000, 0x42240000, 0xFFAE00FF, 0x00000000, 0x3F2F0000)
        Render.draw_texture_at_offset(3, 19, 0x801338B0, 0xDE30, Render.NOOP, 0x43700000, 0x42240000, 0xFFAE00FF, 0x00000000, 0x3F2F0000)
        Render.draw_string(3, 19, slash, Render.NOOP, 0x43800000, 0x42180000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT)
        Render.draw_texture_at_offset(3, 19, Render.file_pointer_3, Render.file_c5_offsets.Z, Render.NOOP, 0x43780000, 0x42180000, 0x848484FF, 0x303030FF, 0x3F480000)

        Render.draw_texture_at_offset(3, 13, Render.file_pointer_2, 0x20718, Render.NOOP, 0x41200000, 0x41200000, 0xFFFFFFFF, 0x00000000, 0x3F800000)
        Render.draw_string(3, 13, current_profile, Render.NOOP, 0x432D0000, 0x434D0000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.RIGHT)
        Render.draw_string_pointer(3, 13, profile_pointer, Render.update_live_string_, 0x43530000, 0x434D0000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.CENTER)

        Render.draw_string(3, 14, toggles_note_line_1, Render.NOOP, 0x43200000, 0x432E0000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.CENTER)
        Render.draw_string(3, 14, toggles_note_line_2, Render.NOOP, 0x43200000, 0x433C0000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.CENTER)
        Render.draw_texture_at_offset(3, 14, Render.file_pointer_3, Render.file_c5_offsets.A, Render.NOOP, 0x42B40000, 0x432E0000, 0x50A8FFFF, 0x0010FFFF, 0x3F800000)

        Render.draw_string(3, 21, l_shortcut_note_line_1, Render.NOOP, 0x43200000, 0x433C0000, 0xFFFFFFFF, 0x3F400000, Render.alignment.CENTER)
        Render.draw_texture_at_offset(3, 21, Render.file_pointer_3, Render.file_c5_offsets.L, Render.NOOP, 0x42B80000, 0x433C0000, 0x848484FF, 0x303030FF, 0x3F400000)

        Render.draw_texture_at_offset(3, 15, Render.file_pointer_3, Render.file_c5_offsets.A, Render.NOOP, 0x433F0000, 0x42180000, 0x50A8FFFF, 0x0010FFFF, 0x3F700000)
        Render.draw_string(3, 15, preview_track, Render.NOOP, 0x434A0000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)

        Render.draw_texture_at_offset(3, 16, Render.file_pointer_3, Render.file_c5_offsets.A, Render.NOOP, 0x431A0000, 0x42180000, 0x50A8FFFF, 0x0010FFFF, 0x3F700000)
        Render.draw_string(3, 16, toggle_all, Render.NOOP, 0x43250000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)

        Render.draw_texture_at_offset(3, 17, Render.file_pointer_3, Render.file_c5_offsets.A, Render.NOOP, 0x43100000, 0x42180000, 0x50A8FFFF, 0x0010FFFF, 0x3F700000)
        Render.draw_string(3, 17, load_profile, Render.NOOP, 0x431B0000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)

        // edit legend
        Render.draw_texture_at_offset(3, 18, Render.file_pointer_3, Render.file_c5_offsets.Z, Render.NOOP, 0x42FC0000, 0x42180000, 0x848484FF, 0x303030FF, 0x3F480000)
        Render.draw_string(3, 18, cancel, Render.update_live_string_, 0x43060000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)
        Render.draw_texture_at_offset(3, 18, Render.file_pointer_3, Render.file_c5_offsets.R, Render.NOOP, 0x433C0000, 0x42180000, 0x848484FF, 0x303030FF, 0x3F700000)
        Render.draw_string(3, 18, change_case, Render.update_live_string_, 0x434C0000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)

        li      t0, Render.display_order_room
        lui     t1, 0x7000
        sw      t1, 0x0000(t0)

        Render.draw_rectangle(3, 18, 40, 60, 240, 120, 0x000000FF, OS.FALSE) // background
        evaluate n(0)
        while {n} <= 10 {
            evaluate h(98)
            evaluate y(82)
            if ({n} == 0) || ({n} == 10) {
                evaluate h(122)
                evaluate y(58)
            }
            Render.draw_rectangle(3, 18, 38 + ({n} * 24), {y}, 2, {h}, 0xFFFFFFFF, OS.FALSE) // vertical line
            if {n} <= 5 {
                Render.draw_rectangle(3, 18, 38, 58 + ({n} * 24), 242, 2, 0xFFFFFFFF, OS.FALSE) // horizontal line
            }
            evaluate n({n} + 1)
        }

        Render.draw_rectangle(3, 18, 38, 82, 26, 26, 0xF2C70DFF, OS.FALSE)
        li      t0, Menu.keyboard_struct
        sw      v0, 0x0000(t0)              // save cursor rectangle 1
        Render.draw_rectangle(3, 18, 40, 84, 22, 22, 0x000000FF, OS.FALSE)
        li      t0, Menu.keyboard_struct
        sw      v0, 0x0004(t0)              // save cursor rectangle 2
        li      t0, Menu.keyboard_cursor_index
        sw      r0, 0x0000(t0)              // reset cursor x and y

        li      t0, Menu.keyboard_set
        lw      t0, 0x0000(t0)              // t0 = keyboard set
        li      t1, Menu.keyboard_sets
        sll     t0, t0, 0x0002              // t0 = offset to keyboard set
        addu    t1, t1, t0                  // t1 = keyboard set pointer address
        lw      a2, 0x0000(t1)              // t0 = keyboard set

        Render.draw_string(3, 18, 0xFFFFFFFF, Render.NOOP, 0x42240000, 0x42F40000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.TRUE)
        li      t0, Menu.keyboard_struct + 0x0008
        sw      v0, 0x0000(t0)              // save keyboard chars string object
        sw      t0, 0x0054(v0)              // save reference to string object

        jal     Menu.align_keyboard_chars_
        or      a0, v0, r0                  // a0 = string object

        // Space key
        Render.draw_rectangle(3, 18, 38 + 6 * 24 + 5, 82 + 3 * 24 + 18, 16, 2, 0xFFFFFFFF, OS.FALSE)
        Render.draw_rectangle(3, 18, 38 + 6 * 24 + 6, 82 + 3 * 24 + 18, 14, 1, 0x000000FF, OS.FALSE)

        // Backspace key
        Render.draw_texture_at_offset(3, 18, Render.file_pointer_3, Render.file_c5_offsets.B, Render.NOOP, 0x43530000, 0x431F8000, 0x00D040FF, 0x00D040FF, 0x3FA00000)
        Render.draw_string(3, 18, Menu.string_del, Render.NOOP, 0x435A8000, 0x43230000, 0xFFFFFFFF, 0x3F400000, Render.alignment.CENTER, OS.TRUE)

        // Keyboard Set key
        Render.draw_texture_at_offset(3, 18, Render.file_pointer_3, Render.file_c5_offsets.B, Render.NOOP, 0x436B0000, 0x431F8000, 0xC0CC00FF, 0xC0CC00FF, 0x3FA00000)
        Render.draw_string_pointer(3, 18, Menu.keyboard_set_button, Render.update_live_string_, 0x4372C000, 0x43230000, 0xFFFFFFFF, 0x3F400000, Render.alignment.CENTER, OS.TRUE)

        // OK key
        Render.draw_texture_at_offset(3, 18, Render.file_pointer_3, Render.file_c5_offsets.B, Render.NOOP, 0x43818000, 0x431F8000, 0xFF0000FF, 0xFF0000FF, 0x3FA00000)
        Render.draw_string(3, 18, Menu.string_ok, Render.NOOP, 0x43858000, 0x43230000, 0xFFFFFFFF, 0x3F400000, Render.alignment.CENTER, OS.TRUE)

        Render.draw_string(3, 18, Menu.keyboard_input_string, Render.update_live_string_, 0x42300000, 0x42810000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.TRUE)
        li      t0, Menu.keyboard_struct + 0x000C
        sw      v0, 0x0000(t0)              // save keyboard chars string object
        sw      t0, 0x0054(v0)              // save reference to string object

        lli     a1, 232                     // a1 = max width
        jal     Render.apply_max_width_
        or      a0, v0, r0                  // a0 = string object

        li      t0, Render.display_order_room
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)

        Render.draw_texture_at_offset(3, 20, Render.file_pointer_3, Render.file_c5_offsets.A, Render.NOOP, 0x433F0000, 0x42180000, 0x50A8FFFF, 0x0010FFFF, 0x3F700000)
        Render.draw_string(3, 20, edit, Render.NOOP, 0x434A0000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)
        Render.draw_texture_at_offset(3, 20, Render.file_pointer_3, Render.file_c5_offsets.L, Render.NOOP, 0x42D80000, 0x42180000, 0x848484FF, 0x303030FF, 0x3F700000)
        Render.draw_string(3, 20, clear_tag, Render.NOOP, 0x42F40000, 0x42180000, 0xC0C0C0FF, 0x3F600000, Render.alignment.LEFT)

        li      a0, info                    // a0 - info
        sw      r0, 0x0008(a0)              // clear cursor object reference on page load

        li      a1, Global.current_screen   // a1 = address of current_screen
        lbu     a1, 0x0001(a1)              // a0 = stored previous_screen (VS_CSS or TRAINING_CSS)
        addiu   a1, a1, 0 - Global.screen.CONGRATULATIONS
        bnezl   a1, pc() + 8                // only reset cursor if not coming back from Gallery
        sw      r0, 0x000C(a0)              // reset cursor to top
        jal     Menu.draw_                  // draw menu
        nop
        // ensure Profiles text is hidden when first opening menu
        lli     a0, 14                      // a0 = group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = 1 (display off)
        // ensure edit legend is hidden when first opening menu
        lli     a0, 18                      // a0 = group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = 1 (display off)

        Render.register_routine(run_)

        // Make sure we setup things correctly if going directly to the Other Screens menu
        OS.read_byte(menu_index, t0)
        lli     t1, 0x0007                  // t1 = Other Screens menu index
        bne     t0, t1, _end                // if not Other Screens menu, skip
        nop
        li      a0, info                    // a0 = address of info
        lw      t1, 0x000C(a0)              // t1 = cursor index
        sw      t1, 0x0008(sp)              // remember cursor index
        li      v0, entry_other_screens     // v0 = Other Screens entry
        jal     show_other_screens_
        nop
        li      a0, info                    // a0 = address of info
        lw      a1, 0x0018(a0)              // a1 = 1st displayed currently
        lw      t0, 0x0008(sp)              // t0 = cursor index
        jal     Menu.redraw_                // lazy me doing this to avoid resetting cursor
        sw      t0, 0x000C(a0)              // restore cursor index

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Runs every frame to correctly update the menu
    scope run_: {
        OS.save_registers()

        li      a0, info
        jal     Menu.update_                // check for updates
        nop

        li      t0, menu_index              // t0 - address of menu index
        lbu     t0, 0x0000(t0)              // t0 = menu index (0 if super menu)
        bnez    t0, _check_b                // if (not in super menu), skip
        nop                                 //

        jal     get_current_profile_        // v0 - current profile
        nop
        li      a2, string_table_profile    // a2 - profile string table address
        sll     v1, v0, 0x0002              // v1 - offset to profile string address
        addu    a2, a2, v1                  // a2 - address of string address
        lw      a2, 0x0000(a2)              // a2 - address of string
        li      t0, profile_pointer         // t0 = profile_pointer
        sw      a2, 0x0000(t0)              // save updated address

        // draw toggles note
        li      a0, info                    // a0 - address of info
        lw      t1, 0x000C(a0)              // t1 - cursor... 0 if Load Profile is selected
        lli     a1, 0x0001                  // a1 = 1 (display off)
        bnezl   t1, _set_notes_display      // if (Load Profile is not selected), then don't display it
        lli     t3, 0x0000                  // t3 = flag if we should show 'Hold L' help text (display on)
        or      s0, v0, r0                  // s0 = current profile
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        lw      t0, 0x0004(v0)              // t0 = entry.current_value
        beql    t0, s0, _set_notes_display  // if (current profile is not the selected profile), then don't display it
        or      t3, r0, r0                  // t3 = 0 (display on)
        lli     t3, 0x0001                  // t3 = 1 (display off)
        li      t0, notes_blink_timer
        lw      t1, 0x0000(t0)              // t0 = current blink timer value
        addiu   t1, t1, 0x0001              // increment timer
        sw      t1, 0x0000(t0)              // ~
        lli     t2, 0x001E                  // t2 = 0x1E
        sltu    a1, t2, t1                  // if timer is less than 0x1E, then show it: a1 = 0 (display on)
        sltiu   t2, t1, 0x0028              // reset timer if we reach 0x28
        beqzl   t2, _set_notes_display
        sw      r0, 0x0000(t0)

        _set_notes_display:
        jal     Render.toggle_group_display_
        lli     a0, 14                      // a0 = group

        // ensure 'Hold L' help text is hidden/shown accordingly
        li      t0, shortcut_stored_screens // t0 = shortcut_stored_screens
        lbu     t0, 0x0000(t0)              // t0 = 0 if we didn't use 'L' shortcut
        // show regardless of using shortcut?
        // bnezl   t0, pc() + 8                // if we used shortcut, then no need to display help text
        // lli     t3, 0x0001                  // t3 = 1 (display off)
        or      a1, t3, r0                  // a1 = display
        jal     Render.toggle_group_display_
        lli     a0, 21                      // a0 = group

        // check for exit
        _check_b:
        li      a0, info                    // a0 = address of info
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        lli     t3, Menu.type.INPUT         // t3 = input type
        lw      t1, 0x0000(v0)              // t1 = type
        bne     t3, t1, _do_check_b         // if (type != input), check b
        lw      t3, 0x0004(v0)              // t3 = edit mode (if input)
        bnez    t3, _check_l                // if in edit mode, don't exit sub menu
        nop

        // if exit mode should be exited, the following logic avoids exiting the menu the same frame
        li      t0, back_blocked
        lw      t1, 0x0000(t0)              // t1 = 0 if back not blocked
        lli     t2, 0x0000                  // t2 = 0
        bgtzl   t1, pc() + 8                // if > 0, decrement
        addiu   t2, t1, -0x0001             // t2 = t1 - 1
        bnez    t1, _check_l                // if back blocked, skip checking for B
        sw      t2, 0x0000(t0)              // update back_blocked for next frame

        _do_check_b:
        lli     a0, Joypad.B                // a0 - button_mask
        lli     a2, Joypad.PRESSED          // a2 - types
        jal     Joypad.check_buttons_all_   // check if B pressed
        nop
        beqz    v0, _check_l                // nop
        nop

        li      a0, info                    // a0 = address of info

        li      t1, menu_index              // t1 = menu_index
        lbu     t0, 0x0000(t1)              // t0 = menu index
        beqz    t0, _exit_super_menu        // if (in super menu), exit
        sb      r0, 0x0000(t1)              // restore cursor when returning from sub menu

        _exit_sub_menu:
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        li      t1, info                    // t1 = address of info
        sw      t0, 0x000C(t1)              // restore cursor
        jal     show_super_menu_            // bring up super menu
        nop
        // li      t0, reset_menu_music
        // lw      t0, 0x0000(t0)              // t0 = reset menu music flag
        // beqz    t0, _end                    // if we don't need to reset the menu music, skip
        // nop
        li      t0, Toggles.entry_play_music
        lw      t0, 0x0004(t0)              // t0 = 0 if music is toggled off
        beqz    t0, _reset_menu_music       // reset music if music is toggled off
        nop
        lui     t1, 0x800A
        lw      t1, 0xD974(t1)              // t1 = address of current bgm_id
        lw      t1, 0x0000(t1)              // t1 = current bgm_id (-1 if not playing)
        bltz    t1, _reset_menu_music       // reset music if no music was playing
        nop
        li      t0, Toggles.entry_menu_music
        lw      a0, 0x0004(t0)              // a0 = value of menu_music
        sltiu   t0, a0, menu_music.MAX_VALUE - 1 // t0 = 1 unless menu music is set to 'OFF' or 'RANDOM ALL'
        bnez    t0, _end                    // don't reset music unless menu music is set to 'OFF' or 'RANDOM ALL'
        addiu   t0, r0, menu_music.MAX_VALUE// t0 = max value of menu music (OFF)
        beq     a0, t0, _reset_menu_music   // reset music if menu music is set to 'OFF'
        nop
        // if we've reached this point then it is set to 'RANDOM ALL'...
        // ...and need to check if we should restart track (only if current playing bgm_id is still a normal menu song)
        _check_if_menu_track:
        lli     a0, BGM.menu.MAIN
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MELEE
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_BRAWL
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MENU2
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_GOLDENEYE
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MARIOTENNIS
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_FILESELECT_SM64
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_BLASTCORPS
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_DKR
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MK64
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_SBK
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MARIOPARTY
        beq     t1, a0, _reset_menu_music
        lli     a0, BGM.menu.MAIN_MARIOARTIST
        bne     t1, a0, _end
        nop

        _reset_menu_music:
        jal     play_menu_music_            // reset menu music
        lli     v0, 0x0000                  // forces a reset

        b       _end                        // end menu execution
        nop

        _check_l:
        lli     a0, Joypad.L                // a0 - button_mask
        jal     Joypad.check_buttons_all_   // check if B pressed
        lli     a2, Joypad.PRESSED          // a2 - types
        beqz    v0, _end                    // if not pressed, skip
        nop

        jal     clear_tag_
        nop

        b       _end
        nop

        _exit_super_menu:
        jal     save_                       // save toggles
        nop
        // check if we got here by using the 'L' shortcut, and retrieve current_screen if so
        li      t3, shortcut_stored_screens    // t3 = shortcut_stored_screens
        lbu     a0, 0x0000(t3)                 // a0 = 0 if we didn't use 'L' shortcut
        beqzl   a0, _exit_super_change_screen  // based on the value, set the appropriate screen
        lli     a0, Global.screen.MODE_SELECT  // a0 = screen_id (main menu)

        lli     t4, Global.screen.STAGE_SELECT // t4 = screen_id (stage select)
        bne     t4, a0, _load_stored_screen_id // if we're returning to a CSS, we don't want to overwrite current_screen...
        nop                                    // ...since CSS music doesn't autoplay if stored current_screen was SSS

        // if we're here, we need to spoof the 'current_screen' value (to return to either VS or Training SSS)
        li      t4, Global.current_screen   // t4 = address of current_screen
        lbu     a0, 0x0001(t3)              // a0 = stored previous_screen (VS_CSS or TRAINING_CSS)
        sb      a0, 0x0000(t4)              // overwrite current_screen id

        jal     BGM.handle_sss_shortcut     // refresh song if using 64 menu music
        nop

        _load_stored_screen_id:
        li      t3, shortcut_stored_screens // t3 = shortcut_stored_screens
        lbu     a0, 0x0000(t3)              // a0 = stored current_screen (CSS or SSS)
        sh      r0, 0x0000(t3)              // clear shortcut_stored_screens
        li      t4, Toggles.shortcut_L_timer
        sw      r0, 0x0000(t4)              // clear all port timers if L held is met

        _exit_super_change_screen:
        jal     Menu.change_screen_         // exit to main menu (or Shortcut screen)
        nop

        _end:
        li      a0, info                    // a0 = address of info
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop

        lli     t3, 0x0001                  // t3 = display off
        lli     t4, 0x0001                  // t4 = display off
        lli     t5, 0x0001                  // t5 = display off
        lli     t6, 0x0001                  // t6 = display off
        lw      t1, 0x0010(v0)              // t1 = a_function routine
        li      t2, play_menu_music_        // t2 = play_menu_music_
        beql    t1, t2, pc() + 8            // if on the menu music entry, display Play legend
        lli     t3, 0x0000                  // t3 = display on
        li      t2, preview_bgm_            // t2 = preview_bgm_
        beql    t1, t2, pc() + 8            // if on a track entry, display Play legend
        lli     t3, 0x0000                  // t3 = display on
        li      t2, toggle_all_             // t2 = toggle_all_
        beql    t1, t2, pc() + 8            // if on a toggle all entry, display Toggle legend
        lli     t4, 0x0000                  // t4 = display on
        li      t2, load_sub_profile_       // t2 = load_sub_profile_
        beql    t1, t2, pc() + 8            // if on a load profile entry, display Load legend
        lli     t5, 0x0000                  // t4 = display on
        li      t2, toggle_edit_mode_       // t2 = toggle_edit_mode_
        beql    t1, t2, pc() + 8            // if on an editable entry, display edit/clear legend
        lw      t6, 0x0004(v0)              // t4 = edit flag = display state

        // ensure play legend is hidden/shown accordingly
        lli     a0, 15                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t3, r0                  // a1 = display

        // ensure toggle all legend is hidden/shown accordingly
        lli     a0, 16                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t4, r0                  // a1 = display

        // ensure toggle all legend is hidden/shown accordingly
        lli     a0, 17                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t5, r0                  // a1 = display

        // ensure edit/clear legend is hidden/shown accordingly
        lli     a0, 20                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t6, r0                  // a1 = display

        OS.restore_registers()
        jr      ra
        nop

        notes_blink_timer:
        dw 0x00000000
    }

    // @ Description
    // Save toggles to SRAM
    scope save_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      t0, 0                       // t0 = 0 (offset)

        _loop:
        sw      t0, 0x0018(sp)              // save offset
        li      a0, block_head_table
        addu    a0, a0, t0                  // a0 = address of head pointer
        lw      a0, 0x0000(a0)              // a0 - address of head
        beqz    a0, _end                    // if no more, end
        li      a1, sram_block_table
        addu    a1, a1, t0                  // a1 = address of block poiner
        jal     Menu.export_                // export data
        lw      a1, 0x0000(a1)              // a1 - address of block

        lw      t0, 0x0018(sp)              // t0 = offset
        li      a0, sram_block_table
        addu    a0, a0, t0                  // a0 = address of block poiner
        jal     SRAM.save_                  // save data
        lw      a0, 0x0000(a0)              // a0 - address of block

        lw      t0, 0x0018(sp)              // t0 = offset
        b       _loop                       // do loop
        addiu   t0, t0, 0x0004              // t0 = offset for next index

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Loads toggles from SRAM
    scope load_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      t0, 0                       // t0 = 0 (offset)

        _loop:
        sw      t0, 0x0018(sp)              // save offset
        li      a0, sram_block_table
        addu    a0, a0, t0                  // a0 = address of block poiner
        lw      a0, 0x0000(a0)              // a0 - address of block
        beqz    a0, _end                    // if no more, end
        nop
        jal     SRAM.load_                  // load data
        nop

        lw      t0, 0x0018(sp)              // t0 = offset
        li      a0, block_head_table
        addu    a0, a0, t0                  // a0 = address of head pointer
        lw      a0, 0x0000(a0)              // a0 - address of head
        li      a1, sram_block_table
        addu    a1, a1, t0                  // a1 = address of block poiner
        jal     Menu.import_                // export data
        lw      a1, 0x0000(a1)              // a1 - address of block

        lw      t0, 0x0018(sp)              // t0 = offset
        b       _loop                       // do loop
        addiu   t0, t0, 0x0004              // t0 = offset for next index

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    macro set_info_head(address_of_head, menu_index) {
        // a0 = address of info()
        // v0 = selected entry
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // save t0
        sw      t1, 0x0008(sp)              // save t1
        sw      ra, 0x000C(sp)              // save ra

        li      t0, menu_index              // t0 = menu_index
        lli     t1, {menu_index}            // t1 = menu index being opened
        sb      t1, 0x0000(t0)              // save menu index

        li      t0, info                    // t0 = info
        li      t1, {address_of_head}       // t1 = address of head
        sw      t1, 0x0000(t0)              // update info->head
        if {menu_index} > 0 {
            sw      r0, 0x000C(t0)          // update info.selection on sub menus
        }
        lw      a1, 0x0018(t0)              // a1 = 1st displayed currently
        sw      t1, 0x0018(t0)              // update info->1st displayed
        sw      t1, 0x001C(t0)              // update info->last displayed
        li      t0, page_title_pointer      // t0 = page_title pointer
        if {menu_index} > 0 {
            addiu   t1, v0, 0x0028          // t1 = selected entry's title
            sw      t1, 0x0000(t0)          // set the page title
        } else {
            sw      r0, 0x0000(t0)          // clear the page title
        }

        jal     Menu.redraw_                // redraw menu
        nop

        lli     a0, 13                      // a0 = group 13
        jal     Render.toggle_group_display_
        if {menu_index} > 0 {
            lli     a1, OS.TRUE             // a1 = hide main menu elements
        } else {
            lli     a1, OS.FALSE            // a1 = show main menu elements
        }
        // ensure 'Hold L' help text is hidden/shown along with main menu elements
        jal     Render.toggle_group_display_
        lli     a0, 21                      // a0 = group 21

        lw      t0, 0x0004(sp)              // restore t0
        lw      t1, 0x0008(sp)              // restore t1
        lw      ra, 0x000C(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    info:
    Menu.info(head_super_menu, 30, 50, 3, 0, 32, 0xF2C70DFF, Color.high.WHITE, Color.high.WHITE)

    // @ Description
    // Functions to change the menu currently displayed.
    show_super_menu_:; set_info_head(head_super_menu, OS.FALSE)
    show_remix_settings_:; set_info_head(head_remix_settings, 1)
    show_gameplay_settings_:; set_info_head(head_gameplay_settings, 2)
    show_music_settings_:; set_info_head(head_music_settings, 3)
    show_stage_settings_:; set_info_head(head_stage_settings, 4)
    show_pokemon_settings_:; set_info_head(head_pokemon_settings, 5)
    show_player_tags_:; set_info_head(head_player_tags, 6)
    show_other_screens_:; set_info_head(head_other_screens_, 7)

    variable num_toggles(0)
    variable block_size(0)

    // @ Description
    // This updates the current block size, making sure to not stretch values across words
    macro update_block_size(entry_size) {
        evaluate before(block_size/32)
        global variable block_size(block_size + {entry_size})
        evaluate after(block_size/32)

        if {before} != {after} {
            global variable block_size(((block_size/32) * 32) + {entry_size})
        }
    }

    // @ Description
    // This updates the current block size, making sure to not stretch values across words
    macro update_block_size_based_on_max(max) {
         if {max} <= 1 {
            update_block_size(1)
        } else if {max} <= 3 {
            update_block_size(2)
        } else if {max} <= 7 {
            update_block_size(3)
        } else if {max} <= 15 {
            update_block_size(4)
        } else if {max} <= 31 {
            update_block_size(5)
        } else if {max} <= 64 {
            update_block_size(6)
        } else if {max} <= 127 {
            update_block_size(7)
        } else if {max} <= 255 {
            update_block_size(8)
        } else if {max} <= 511 {
            update_block_size(9)
        } else if {max} <= 1023 {
            update_block_size(10)
        }
    }

    // @ Description
    // Wrapper for Menu.entry_bool()
    macro entry_bool(title, default_ce, default_te, default_ne, default_jp, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_NE({default_ne})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        update_block_size(1)
        Menu.entry_bool_with_extra({title}, {default_ce}, {n}, {next})
    }

    // @ Description
    // Wrapper for Menu.entry_bool()
    macro entry_bool_with_a(title, default_ce, default_te, default_ne, default_jp, a_function, extra, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_NE({default_ne})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        update_block_size_based_on_max(1)
        Menu.entry({title}, Menu.type.BOOL, {default_ce}, 0, 1, {a_function}, {extra}, Menu.bool_string_table, OS.NULL, {next})
    }

    // @ Description
    // Wrapper for Menu.entry()
    macro entry(title, type, default_ce, default_te, default_ne, default_jp, min, max, a_function, string_table, copy_address, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_NE({default_ne})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        update_block_size_based_on_max({max})
        Menu.entry({title}, {type}, {default_ce}, {min}, {max}, {a_function}, OS.NULL, {string_table}, {copy_address}, {next})
    }

    // @ Description
    // Wrapper for Menu.entry()
    macro entry(title, type, default_ce, default_te, default_ne, default_jp, min, max, a_function, extra, string_table, copy_address, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_NE({default_ne})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        update_block_size({max})
        Menu.entry({title}, {type}, {default_ce}, {min}, {max}, {a_function}, {extra}, {string_table}, {copy_address}, {next})
    }

    // @ Description
    // Write defaults for the passed in profile
    // profile - CE, TE, NE or JP
    macro write_defaults_for(profile) {
        evaluate n(1)
        while {n} <= num_toggles {
            dw      {TOGGLE_{n}_DEFAULT_{profile}}
            evaluate n({n}+1)
        }
    }

    scope profile {
        constant CE(0)
        constant TE(1)
        constant NE(2)
        constant JP(3)
        constant CUSTOM(4)
    }

    // @ Description
    // Profile strings
    profile_ce:; db "Community", 0x00
    profile_te:; db "Tournament", 0x00
    profile_ne:; db "Netplay", 0x00
    profile_jp:; db "Japanese", 0x00
    profile_custom:; db "Custom", 0x00
    profile_semicomp:; db "Semi-Competitive", 0x00
    current_profile:; db "Current Profile: ", 0x00
    toggles_note_line_1:; db "Press     to load selected profile,", 0x00
    toggles_note_line_2:; db "which will affect all settings.", 0x00
    l_shortcut_note_line_1:; db "Tip: Hold     on CSS or SSS to access this menu.", 0x00
    preview_track:; db ": Play", 0x00
    toggle_all:; db ": All On/Off", 0x00
    load_profile:; db ": Load Profile", 0x00
    settings:; db "SETTINGS", 0x00
    slash:; db "/", 0x00
    off:; db "OFF", 0x00
    normal:; db "NORMAL", 0x00
    default:; db "DEFAULT", 0x00
    cancel:; db ": Cancel", 0x00
    change_case:; db ": Change Case", 0x00
    edit:; db ": Edit", 0x00
    clear_tag:; db ": Clear Tag", 0x00
    OS.align(4)

    string_table_profile:
    dw profile_ce
    dw profile_te
    dw profile_ne
    dw profile_jp
    dw profile_custom

    // @ Description
    // Z-Cancel strings
    disabled:; db "DISABLED", 0x00
    melee_7:; db "MELEE (7 frames)", 0x00
    auto:; db "AUTO", 0x00
    glide:; db "GLIDE MODE", 0x00
    OS.align(4)

    string_table_z_cancel_opts:
    dw default
    dw disabled
    dw melee_7
    dw auto
    dw glide

    // @ Description
    // Failed Z-Cancel strings
    _7:; db "7% Damage", 0x00
    lava:; db "Lava Floor", 0x00
    shield_break:; db "Shield-Break", 0x00
    instant_ko:; db "Instant K.O.", 0x00
    taunt:; db "Force Taunt", 0x00
    bury:; db "Bury", 0x00
    laugh_track:; db "Laugh Track", 0x00
    egg:; db "Egg", 0x00
    _random:; db "Random", 0x00
    OS.align(4)

    string_table_failed_z_cancel:
    dw off
    dw _7
    dw lava
    dw shield_break
    dw instant_ko
    dw taunt
    dw bury
    dw laugh_track
    dw egg
    dw _random

    // @ Description
    // Air Dodge Strings
    _melee:; db "Melee", 0x00
    _ultimate:; db "Ultimate", 0x00
    _air_dash:; db "Air Dash", 0x00
    OS.align(4)

    string_table_air_dodge:
    dw off
    dw _melee
    dw _ultimate
    dw _air_dash

    // @ Description
    // Item Container Strings
    no_explode:; db "NEVER EXPLODE", 0x00
    only_explode:; db "ALWAYS EXPLODE", 0x00
    OS.align(4)

    string_table_item_containers:
    dw default
    dw off
    dw no_explode
    dw only_explode

    // @ Description
    // FPS strings
    fps_overclocked:; db "OVERCLOCKED", 0x00
    OS.align(4)

    string_table_fps:
    dw off
    dw normal
    dw fps_overclocked

    // @ Description
    // Special Model Display strings
    model_hitbox:; db "HITBOX", 0x00
    model_hitbox_plus:; db "HITBOX+", 0x00
    model_ecb:; db "ECB", 0x00
    OS.align(4)

    string_table_model:
    dw off
    dw model_hitbox
    dw model_hitbox_plus
    dw model_ecb

    // @ Description
    // Model Display strings
    model_poly_high:; db "HIGH POLY", 0x00
    model_poly_low:; db "LOW POLY", 0x00
    OS.align(4)

    string_table_poly:
    dw default
    dw model_poly_high
    dw model_poly_low

    // @ Description
    // Salty Runback strings
    salty_default:; db "A+B+Z+R+START", 0x00
    salty_alt:; db "A+B+Z+R+Dpad-Right", 0x00
    OS.align(4)

    string_table_salty:
    dw off
    dw salty_default
    dw salty_alt

    // @ Description
    // Disable HUD strings
    disable_hud_pause:; db "PAUSE", 0x00
    disable_hud_all:; db "ALL", 0x00
    OS.align(4)

    string_table_disable_hud:
    dw off
    dw disable_hud_pause
    dw disable_hud_all

    // @ Description
    // Tripping strings
    tripping_low:; db "LOW", 0x00
    tripping_high:; db "HIGH", 0x00
    tripping_brawl:; db ""BRAWL"", 0x00
    OS.align(4)

    string_table_tripping:
    dw off
    dw tripping_low
    dw tripping_high
    dw tripping_brawl
    // @ Description
    // Default/Always/Never frequency strings (used multiple times)
    frequency_always:; db "ALWAYS", 0x00
    frequency_never:; db "NEVER", 0x00
    OS.align(4)

    string_table_frequency:
    dw default
    dw frequency_always
    dw frequency_never

    // @ Description
    // Menu Music strings
    menu_music_64:; db "64", 0x00
    menu_music_melee:; db "MELEE", 0x00
    menu_music_menu2:; db "MELEE MENU 2", 0x00
    menu_music_brawl:; db "BRAWL", 0x00
    menu_music_goldeneye:; db "GOLDENEYE 007", 0x00
    menu_music_tennis:; db "MARIO TENNIS", 0x00
    menu_music_fileselect_sm64:; db "SUPER MARIO 64", 0x00
    menu_music_blastcorps:; db "BLAST CORPS", 0x00
    menu_music_dkr:; db "DIDDY KONG RACING", 0x00
    menu_music_mk64:; db "MARIO KART 64", 0x00
    menu_music_sbk:; db "SNOWBOARD KIDS", 0x00
    menu_music_marioparty:; db "MARIO PARTY", 0x00
    menu_music_marioartist:; db "MARIO ARTIST: TALENT STUDIO", 0x00
    menu_music_random_menu:; db "RANDOM", 0x00
    menu_music_random_classics:; db "RANDOM CLASSICS", 0x00
    menu_music_random_all:; db "RANDOM ALL", 0x00
    menu_music_off:; db "OFF", 0x00
    OS.align(4)

    string_table_menu_music:
    dw default
    dw menu_music_64
    dw menu_music_melee
    dw menu_music_menu2
    dw menu_music_brawl
    dw menu_music_goldeneye
    dw menu_music_tennis
    dw menu_music_fileselect_sm64
    dw menu_music_blastcorps
    dw menu_music_dkr
    dw menu_music_mk64
    dw menu_music_sbk
    dw menu_music_marioparty
    dw menu_music_marioartist
    dw menu_music_random_menu
    dw menu_music_random_classics
    dw menu_music_random_all
    dw menu_music_off

    // Update this when we add a menu track
    scope menu_music {
        constant MAX_VALUE(17)
    }

    // @ Description
    // Used when selecting a random song with Menu Music value 'RANDOM ALL'
    // Flag is -1 if currently active and forcing update
    menu_randomizing_all:
    dw 0

    // @ Description
    // SSS Layout strings
    sss_layout_tournament:; db "TOURNAMENT", 0x00
    OS.align(4)

    string_table_sss_layout:
    dw normal
    dw sss_layout_tournament

    scope sss {
        constant NORMAL(0)
        constant TOURNAMENT(1)
    }

    // @ Description
    // Hazard Mode strings
    hazard_mode_hazards_off:; db "HAZARDS OFF", 0x00
    hazard_mode_movement_off:; db "MOVEMENT OFF", 0x00
    hazard_mode_all_off:; db "ALL OFF", 0x00
    OS.align(4)

    string_table_hazard_mode:
    dw normal
    dw hazard_mode_hazards_off
    dw hazard_mode_movement_off
    dw hazard_mode_all_off

    scope hazard_mode {
        constant NORMAL(0)
        constant HAZARDS_OFF(1)
        constant MOVEMENT_OFF(2)
        constant ALL_OFF(3)
    }

    // @ Description
    // Whispy strings
    japanese:; db "JAPANESE", 0x00
    super:; db "SUPER", 0x00
    hyper:; db "HYPER", 0x00
    OS.align(4)

    string_table_whispy_mode:
    dw normal
    dw japanese
    dw super
    dw hyper

    scope whispy_mode {
        constant NORMAL(0)
        constant JAPANESE(1)
        constant SUPER(2)
        constant HYPER(3)
    }

    // @ Description
    // Saffron Pokemon rate strings
    quick_attack:; db "QUICK ATTACK", 0x00
    OS.align(4)

    string_table_saffron_poke_rate:
    dw normal
    dw super
    dw hyper
    dw quick_attack

    string_table_pokemon_voices:
    dw default
    dw japanese
    dw menu_music_random_menu

    // @ Description
    // Default CPU level strings
    num_1:; db "1", 0x00
    num_2:; db "2", 0x00
    num_3:; db "3", 0x00
    num_4:; db "4", 0x00
    num_5:; db "5", 0x00
    num_6:; db "6", 0x00
    num_7:; db "7", 0x00
    num_8:; db "8", 0x00
    num_9:; db "9", 0x00
    num_10:; db "10", 0x00
    OS.align(4)

    string_table_cpu_levels:
    dw default
    dw num_1
    dw num_2
    dw num_3
    dw num_4
    dw num_5
    dw num_6
    dw num_7
    dw num_8
    dw num_9
    dw num_10


    string_table_screenshake:
    dw default
    dw light
    dw off

    // @ Description
    // Screenshake strings
    light:; db "LIGHT", 0x00
    OS.align(4)

    // @ Description
    // Pokemon Stadium Announcer strings
    announcer_mode_pokemon:; db "STADIUM", 0x00
    announcer_mode_all:; db "ALL STAGES", 0x00
    announcer_mode_off:; db "OFF", 0x00
    OS.align(4)

    string_table_announcer_mode:
    dw announcer_mode_pokemon
    dw announcer_mode_all
    dw announcer_mode_off

    scope announcer_mode {
        constant POKEMON(0)
        constant ALL(1)
        constant OFF(2)
    }

    // @ Description
    // Dragon King HUD strings
    dragon_king_hud_default:; db "DRAGON KING", 0x00
    dragon_king_hud_all:; db "ALL STAGES", 0x00
    dragon_king_hud_off:; db "OFF", 0x00
    OS.align(4)

    string_table_dragon_king_hud:
    dw dragon_king_hud_default
    dw dragon_king_hud_all
    dw dragon_king_hud_off

    scope dragon_king_hud {
        constant DEFAULT(0)
        constant ALL(1)
        constant OFF(2)
    }

    // @ Description
    // Hitlag strings
    melee:; db "MELEE", 0x00
    none:; db "NONE", 0x00
    OS.align(4)

    string_table_hitlag:
    dw normal
    dw japanese
    dw melee
    dw none

    // @ Description
    // Hitstun strings

    string_table_hitstun:
    dw normal
    dw melee

    // @ Description
    // Blast Zone strings
    warp_LR:; db "LEFT/RIGHT", 0x00
    warp_TD:; db "TOP/BOTTOM", 0x00
    warp_all:; db "ALL", 0x00
    OS.align(4)

    string_table_blast_zone:
    dw off
    dw warp_LR
    dw warp_TD
    dw warp_all

    // @ Description
    // 'Punish on failed z cancel' Soundboard Easter Egg
    // Allows A button presses on the toggle to play conditional FGM SFX
    scope punish_fgm_: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        // 0 if off, 1 if '7% Damage', 2 if 'Lava Floor', 3 if 'Shield-Break', 4 if 'Instant K.O.', 5 if 'Force Taunt', 6 if 'Bury', 7 if 'Laugh Track', 8 if 'Egg', 9 if 'Random'
        li      t0, Toggles.entry_punish_on_failed_z_cancel
        lw      t0, 0x0004(t0)
        addiu   a0, r0, 1                   // a0 = (7% damage)
        beql    a0, t0, _play
        lli     a0, 0x1AB                   // a0 - fgm_id
        addiu   a0, r0, 2                   // a0 = (lava floor)
        beql    a0, t0, _play
        lli     a0, 0x1A4                   // a0 - fgm_id
        addiu   a0, r0, 3                   // a0 = (shield break)
        beql    a0, t0, _play
        lli     a0, 0x339                   // a0 - fgm_id
        addiu   a0, r0, 4                   // a0 = (Instant K.O)
        beql    a0, t0, _play
        lli     a0, 0x4E5                   // a0 - fgm_id
        addiu   a0, r0, 5                   // a0 = (force taunt)
        beql    a0, t0, _play
        lli     a0, 0x151                   // a0 - fgm_id
        addiu   a0, r0, 6                   // a0 = (bury)
        beql    a0, t0, _play
        lli     a0, 0x437                   // a0 - fgm_id
        addiu   a0, r0, 7                   // a0 = (Laugh Track)
        beql    a0, t0, _play               // it's a secret to everybody
        lli     a0, 0x312                   // a0 - fgm_id
        addiu   a0, r0, 8                   // a0 = (Egg)
        beql    a0, t0, _play
        lli     a0, 0x24B                   // a0 - fgm_id
        addiu   a0, r0, 9                   // a0 = (random)
        beql    a0, t0, _play
        lli     a0, 0x3A                    // a0 - fgm_id
        bnez    t0, _end                    // safety branch
        nop
        // if we're here, then it's set to 'OFF'
        li      t0, Toggles.entry_menu_music
        lw      t0, 0x0004(t0)              // t0 = 0 if DEFAULT, 1 if 64, 2 if MELEE, 3 if MENU 2, 4 if BRAWL, 5 if GOLDENEYE, 6 if MARIOTENNIS, 7 if FILESELECT_SM64, 8 if BLASTCORPS, 9 if DKR, 10 if MK64, 11 if SBK, 12 if MARIOPARTY, 13 if MARIOARTIST
        lli     a0, 0x0008                  // t1 = 8 (BLASTCORPS)
        bne     a0, t0, _end                // don't play SFX unless menu track is BLASTCORPS
        lli     a0, 0x537                   // a0 - fgm_id (Time to get Moving!)


        _play:
        jal     FGM.play_                   // play menu sound
        nop

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Allows A button to play selected menu music preference
    scope play_menu_music_: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, Toggles.entry_menu_music
        lw      t0, 0x0004(t0)              // t0 = 0 if DEFAULT, 1 if 64, 2 if MELEE, 3 if MENU 2, 4 if BRAWL, 5 if GOLDENEYE, 6 if MARIOTENNIS, 7 if FILESELECT_SM64, 8 if BLASTCORPS, 9 if DKR, 10 if MK64, 11 if SBK, 12 if MARIOPARTY, 13 if MARIOARTIST

        _check_bgm:
        lli     t1, 0x0007                  // t1 = 7 (FILESELECT_SM64)
        beql    t1, t0, _sm64_trap_check    // if FILESELECT_SM64, then use FILESELECT_SM64 BGM (...maybe)
        addiu   a1, r0, BGM.menu.MAIN_FILESELECT_SM64
        // if we're here, a song other than FILESELECT_SM64 was pressed
        li      t1, Toggles.itsatrap        // t1 = itsatrap counter address
        sw      r0, 0x0000(t1)              // clear itsatrap counter
        lli     t1, 0x0001                  // t1 = 1 (64)
        beql    t1, t0, _play               // if 64, then use 64 BGM
        addiu   a1, r0, BGM.menu.MAIN
        lli     t1, 0x0002                  // t1 = 2 (MELEE)
        beql    t1, t0, _play               // if MELEE, then use MELEE BGM
        addiu   a1, r0, BGM.menu.MAIN_MELEE
        lli     t1, 0x0003                  // t1 = 3 (MENU2)
        beql    t1, t0, _play               // if MENU2, then use MENU2 BGM
        addiu   a1, r0, BGM.menu.MAIN_MENU2
        lli     t1, 0x0004                  // t1 = 4 (BRAWL)
        beql    t1, t0, _play               // if BRAWL, then use BRAWL BGM
        addiu   a1, r0, BGM.menu.MAIN_BRAWL
        lli     t1, 0x0005                  // t1 = 5 (GOLDENEYE)
        beql    t1, t0, _play               // if GOLDENEYE, then use GOLDENEYE BGM
        addiu   a1, r0, BGM.menu.MAIN_GOLDENEYE
        lli     t1, 0x0006                  // t1 = 6 (MARIOTENNIS)
        beql    t1, t0, _play               // if MARIOTENNIS, then use MARIOTENNIS BGM
        addiu   a1, r0, BGM.menu.MAIN_MARIOTENNIS
        lli     t1, 0x0008                  // t1 = 8 (BLASTCORPS)
        beql    t1, t0, _play               // if BLASTCORPS, then use BLASTCORPS BGM
        addiu   a1, r0, BGM.menu.MAIN_BLASTCORPS
        lli     t1, 0x0009                  // t1 = 9 (DKR)
        beql    t1, t0, _play               // if DKR, then use DKR BGM
        addiu   a1, r0, BGM.menu.MAIN_DKR
        lli     t1, 0x000A                  // t1 = 10 (MK64)
        beql    t1, t0, _play               // if MK64, then use MK64 BGM
        addiu   a1, r0, BGM.menu.MAIN_MK64
        lli     t1, 0x000B                  // t1 = 11 (SBK)
        beql    t1, t0, _play               // if SBK, then use SBK BGM
        addiu   a1, r0, BGM.menu.MAIN_SBK
        lli     t1, 0x000C                  // t1 = 12 (MARIOPARTY)
        beql    t1, t0, _play               // if MARIOPARTY, then use MARIOPARTY BGM
        addiu   a1, r0, BGM.menu.MAIN_MARIOPARTY
        lli     t1, 0x000D                  // t1 = 13 (MARIOARIST)
        beql    t1, t0, _play               // if MARIOARIST, then use MARIOARIST BGM
        addiu   a1, r0, BGM.menu.MAIN_MARIOARTIST
        lli     t1, menu_music.MAX_VALUE - 3 // t1 = max value of menu music - 3 (RANDOM)
        beq     t0, t1, _random_menu_song    // if RANDOM, then use random music
        lli     t1, menu_music.MAX_VALUE - 2 // t1 = max value of menu music - 2 (RANDOM CLASSICS)
        beq     t0, t1, _random_menu_song_classics // if RANDOM, then use random music
        lli     t1, menu_music.MAX_VALUE - 1 // t1 = max value of menu music - 1 (RANDOM All)
        beq     t0, t1, _random_song        // if RANDOM, then use random music
        lli     t1, menu_music.MAX_VALUE    // t1 = max value of menu music (OFF)

        beq     t0, t1, _stop               // if OFF, then stop music
        nop

        // v0 is the entry if we got here by pressing A button on the menu music entry
        // if v0 is 0, then we got here by calling it manually in order to reset the menu music
        bnez    v0, _finish                 // if DEFAULT, then let's let the current track keep playing
        lli     a1, BGM.menu.MAIN           // otherwise, restart the normal menu music

        _play:
        lli     a0, 0x0000
        jal     BGM.play_
        nop
        b _finish
        nop

        _random_menu_song:
        lli     a0, Toggles.menu_music.MAX_VALUE - 4 // a0 - range (0, N-1) Menu Music values (excluding DEFAULT / RANDOM / RANDOM CLASSICS / RANDOM ALL / OFF)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        b       _check_bgm                  // loop back and check again
        addiu   t0, v0, 1                   // t0++

        _random_menu_song_classics:
        lli     a0, Toggles.menu_music.MAX_VALUE - 4 // a0 - range (0, N-1) Menu Music values (excluding DEFAULT / RANDOM / RANDOM CLASSICS / RANDOM ALL / OFF)
        addiu   a0, a0, -4                  // also exclude MAIN / MAIN_MELEE / MAIN_BRAWL / MAIN_MENU2
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        addiu   v0, v0, 4                   // if we're here, we need to apply offset
        b       _check_bgm                  // loop back and check again
        addiu   t0, v0, 1                   // t0++

        _random_song:
        li      a0, Toggles.menu_randomizing_all   // a0 = menu_randomizing_all
        addiu   t0, r0, 0xFFFF              // t0 = -1 (force)
        sw      t0, 0x0000(a0)              // update menu_randomizing_all
        jal     BGM.random_music_           // get random bgm_id (stored in menu_randomizing_all)
        nop
        lw      a1, 0x0000(a0)              // a1 = random track (-1 if no songs are ON)
        bgez    a1, _play                   // play if any songs are ON
        sw      r0, 0x0000(a0)              // clear menu_randomizing_all flag
        // Easter Egg to handle if there were no songs to pick from
        jal     Global.get_random_int_alt_  // v0 = (0, N-1)
        addiu   a0, r0, 4                   // a0 = number of hidden Gameboy songs
        addiu   a1, v0, 0xA2                // a1 = random bgm_id + offset to Gameboy songs
        b       _play                       // play
        nop

        _sm64_trap_check:
        li      t0, Toggles.itsatrap        // t0 = itsatrap counter address
        lw      a0, 0x0000(t0)              // a0 = count (-1 if using trap variant)
        addiu   a0, a0, 1                   // a0++
        beqzl   a0, pc() + 8                // if a0 is now 0, increment again (correct trap variant offset)
        addiu   a0, a0, 1                   // a0++

        sw      a0, 0x0000(t0)              // update counter
        sltiu   a0, a0, 4                   // a0 = 1 (until we press FILESELECT_SM64 enough times)
        bnez    a0, _play                   // if we haven't pressed FILESELECT_SM64 enough times, then use FILESELECT_SM64 BGM...
        nop
        lli     a1, BGM.menu.MAIN_TRAP_SM64 // ...otherwise, play trap variant
        addiu   a0, r0, 0xFFFF              // a0 = -1
        b       _play
        sw      a0, 0x0000(t0)              // update counter (-1 = active)

        _stop:
        jal     BGM.stop_
        nop

        _finish:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }

    itsatrap:
    dw 0

    // @ Description
    // Allows A button to preview selected random music entry
    scope preview_bgm_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        li      t0, reset_menu_music
        lli     t1, OS.TRUE                 // t1 = TRUE
        sw      t1, 0x0000(t0)              // set flag for resetting menu music

        // v0 = menu item
        // 0x0024(v0) = bgm_id

        lli     a0, 0x0000
        jal     BGM.play_
        lw      a1, 0x0024(v0)              // a1 = bgm_id

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Allows A button to toggle on/off all subsequent toggles.
    // Used for random stage/music toggles.
    scope toggle_all_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        // v0 = menu item
        lw      t0, 0x001C(v0)              // t0 = next entry
        lw      t1, 0x0004(t0)              // t1 = value
        xori    t1, t1, 0x0001              // t1 = opposite of first value

        _loop:
        sw      t1, 0x0004(t0)              // update value
        lw      t0, 0x001C(t0)              // t0 = next entry
        bnez    t0, _loop                   // if there is a next entry, keep looping
        nop                                 // otherwise we're done!

        li      a0, info
        jal     Menu.redraw_                // redraw menu to update the toggle values
        lw      a1, 0x0018(a0)              // a1 = 1st displayed entry

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Allows A button to load a profile for random stage/music toggles.
    scope load_sub_profile_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        // v0 = menu item
        lw      t0, 0x001C(v0)              // t0 = next entry (title)
        lw      t0, 0x001C(t0)              // t0 = next entry (first toggle)
        lw      t1, 0x0004(v0)              // t1 = profile to load
        li      t2, info                    // t2 = address of info
        lw      t2, 0x0000(t2)              // t2 = address of head
        li      t3, head_music_settings     // t3 = head_music_settings
        li      t4, music_profiles
        beq     t2, t3, _begin              // if in music settings, use music table
        nop                                 // otherwise, use stage table
        li      t4, stage_profiles

        _begin:
        sll     t1, t1, 0x0002              // t1 = offset to profile defaults
        addu    t2, t4, t1                  // t2 = address of profile defaults pointer
        lw      t2, 0x0000(t2)              // t2 = profile defaults address

        _loop:
        lw      t1, 0x0000(t2)              // t1 = default value
        sw      t1, 0x0004(t0)              // update value
        lw      t0, 0x001C(t0)              // t0 = next entry
        bnez    t0, _loop                   // if there is a next entry, keep looping
        addiu   t2, t2, 0x0004              // t2 = next default value address

        li      a0, info
        jal     Menu.redraw_                // redraw menu to update the toggle values
        lw      a1, 0x0018(a0)              // a1 = 1st displayed entry

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Loads the given screen
    scope view_screen_: {
        // v0 = menu item
        // 0x0024(v0) = screen_id

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      a0, info                    // a0 = info
        jal     show_super_menu_            // bring up super menu
        sw      v0, 0x0010(sp)              // save v0

        lw      v0, 0x0010(sp)              // restore v0
        jal     Menu.change_screen_
        lw      a0, 0x0024(v0)              // a0 = screen_id

        // clear inputs so How to Play doesn't think it should be the Title screen
        // shouldn't hurt other screens we use this for, either
        lui     t0, 0x8004
        sh      r0, 0x522A(t0)              // clear input mask for p1
        sh      r0, 0x5234(t0)              // clear input mask for p2
        sh      r0, 0x523E(t0)              // clear input mask for p3
        sh      r0, 0x5248(t0)              // clear input mask for p4

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0020              // allocate stack space
    }

    // @ Description
    // Loads the credits screen, setting the port
    scope view_credits_: {
        // v0 = menu item
        // 0x0024(v0) = screen_id

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // save registers

        lli     a0, Joypad.A | Joypad.START // a0 = button_mask

        li      t0, Joypad.struct
        lhu     t1, 0x0002(t0)              // t1 = pressed button mask, p1
        and     t1, t1, a0                  // t1 = zero if no buttons pressed
        bnezl   t1, _set_1p_port            // if pressed, use p1
        lli     t1, 0x0000                  // t1 = p1

        lhu     t1, 0x000C(t0)              // t1 = pressed button mask, p2
        and     t1, t1, a0                  // t1 = zero if no buttons pressed
        bnezl   t1, _set_1p_port            // if pressed, use p2
        lli     t1, 0x0001                  // t1 = p2

        lhu     t1, 0x0016(t0)              // t1 = pressed button mask, p3
        and     t1, t1, a0                  // t1 = zero if no buttons pressed
        bnezl   t1, _set_1p_port            // if pressed, use p3
        lli     t1, 0x0002                  // t1 = p3

        // otherwise, must be p4
        lli     t1, 0x0003                  // t1 = p4

        _set_1p_port:
        lui     t0, 0x800A
        sb      t1, 0x4AE3(t0)              // set 1p port

        li      a0, info                    // a0 = info
        jal     show_super_menu_            // bring up super menu
        sw      v0, 0x0010(sp)              // save v0

        lw      v0, 0x0010(sp)              // restore v0
        jal     Menu.change_screen_
        lw      a0, 0x0024(v0)              // a0 = screen_id

        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0020              // allocate stack space

        jr      ra
        nop
    }

    string_table_gallery:
    dw mario
    dw dk
    dw link
    dw samus
    dw yoshi
    dw kirby
    dw fox
    dw pikachu
    dw luigi
    dw falcon
    dw ness
    dw jigglypuff
    dw ganondorf
    dw young_link
    dw dr_mario
    dw falco
    dw dark_samus
    dw wario
    dw lucas
    dw bowser
    dw wolf
    dw conker
    dw mewtwo
    dw marth
    dw sonic
    dw sheik
    dw marina
    dw dedede
    dw goemon
    dw banjo
    dw slippy_peppy
    dw ebi
    dw remix

    // @ Description
    // Gallery strings
    mario:; db "Mario", 0x00
    dk:; db "DK", 0x00
    link:; db "Link", 0x00
    samus:; db "Samus", 0x00
    yoshi:; db "Yoshi", 0x00
    kirby:; db "Kirby", 0x00
    fox:; db "Fox", 0x00
    pikachu:; db "Pikachu", 0x00
    luigi:; db "Luigi", 0x00
    falcon:; db "Captain Falcon", 0x00
    ness:; db "Ness", 0x00
    jigglypuff:; db "Jigglypuff", 0x00
    ganondorf:; db "Ganondorf", 0x00
    young_link:; db "Young Link", 0x00
    dr_mario:; db "Dr. Mario", 0x00
    falco:; db "Falco", 0x00
    dark_samus:; db "Dark Samus", 0x00
    wario:; db "Wario", 0x00
    lucas:; db "Lucas", 0x00
    bowser:; db "Bowser", 0x00
    wolf:; db "Wolf", 0x00
    conker:; db "Conker", 0x00
    mewtwo:; db "Mewtwo", 0x00
    marth:; db "Marth", 0x00
    sonic:; db "Sonic", 0x00
    sheik:; db "Sheik", 0x00
    marina:; db "Marina", 0x00
    dedede:; db "Dedede", 0x00
    goemon:; db "Goemon", 0x00
    banjo:; db "Banjo", 0x00
    slippy_peppy:; db "Slippy & Peppy", 0x00
    ebi:; db "Ebisumaru", 0x00
    remix:; db "Remix", 0x00
    OS.align(4)

    // @ Description
    // View Character Gallery
    scope view_gallery: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, Toggles.entry_view_gallery // selected gallery character
        lw      t0, 0x0004(t0)                 // t0 = selected character

        li      t1, Gallery.status             // t1 = status
        sb      t0, Gallery.status.index(t1)   // store updated gallery index

        addiu   t0, r0, 1                      // t0 = 1 (active)
        sb      t0, Gallery.status.active(t1)  // set flag that gallery is active
        sb      r0, Gallery.status.music_index(t1) // set music_index to 0
        sb      r0, Gallery.status.idle(t1)    // set flag that gallery idle mode is off

        lli     t0, Global.screen.OPTION       // t0 = Toggles screen_id
        sb      t0, Gallery.status.previous_screen(t1) // set previous screen_id

        jal     Menu.change_screen_         // generate screen_interrupt
        lli     a0, Global.screen.CONGRATULATIONS // a0 = Victory screen ID

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Contains list of submenus.
    head_super_menu:
    Menu.entry("Load Profile:", Menu.type.INT, OS.FALSE, 0, 3, load_profile_, OS.NULL, string_table_profile, OS.NULL, entry_remix_settings)
    entry_remix_settings:; Menu.entry_title("Remix Settings", show_remix_settings_, entry_gameplay_settings)
    entry_gameplay_settings:; Menu.entry_title("Gameplay Settings", show_gameplay_settings_, entry_music_settings)
    entry_music_settings:; Menu.entry_title("Music Settings", show_music_settings_, entry_stage_settings)
    entry_stage_settings:; Menu.entry_title("Stage Settings", show_stage_settings_, entry_pokemon_settings)
    entry_pokemon_settings:; Menu.entry_title("Pokemon Settings", show_pokemon_settings_, entry_player_tags)
    entry_player_tags:; Menu.entry_title("Player Tags", show_player_tags_, entry_other_screens)
    entry_other_screens:; Menu.entry_title("Other Screens", show_other_screens_, OS.NULL)

    // @ Description
    // Miscellaneous Toggles
    head_remix_settings:
    entry_skip_results_screen:;         entry_bool("Skip Results Screen", OS.FALSE, OS.FALSE, OS.TRUE, OS.FALSE, entry_hold_to_pause)
    entry_hold_to_pause:;               entry_bool("Hold To Pause", OS.FALSE, OS.TRUE, OS.TRUE, OS.FALSE, entry_css_panel_menu)
    entry_css_panel_menu:;              entry_bool("CSS Panel Menu", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_practice_overlay)
    entry_practice_overlay:;            entry_bool("Color Overlays", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_cinematic_entry)
    entry_cinematic_entry:;             entry("Cinematic Entry", Menu.type.INT, 0, 0, 0, 0, 0, 2, OS.NULL, string_table_frequency, OS.NULL, entry_flash_on_z_cancel)
    entry_flash_on_z_cancel:;           entry_bool("Flash On Z-Cancel", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_fps)
    entry_fps:;                         entry("FPS Display *BETA", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 2, OS.NULL, string_table_fps, OS.NULL, entry_model_display)
    entry_model_display:;               entry("Model Display", Menu.type.INT, 0, 0, 1, 0, 0, 2, OS.NULL, string_table_poly, OS.NULL, entry_special_model)
    entry_special_model:;               entry("Special Model Display", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 3, OS.NULL, string_table_model, OS.NULL, entry_advanced_hurtbox)
    entry_advanced_hurtbox:;            entry_bool("Advanced Hurtbox Display", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_hold_to_exit_training)
    entry_hold_to_exit_training:;       entry_bool("Hold To Exit Training", OS.FALSE, OS.TRUE, OS.FALSE, OS.FALSE, entry_improved_combo_meter)
    entry_improved_combo_meter:;        entry_bool("Improved Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_tech_chase_combo_meter)
    entry_tech_chase_combo_meter:;      entry_bool("Tech Chase Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_combo_meter)
    entry_combo_meter:;                 entry_bool("Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_1v1_combo_meter_swap)
    entry_1v1_combo_meter_swap:;        entry_bool("1v1 Combo Meter Swap", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_neutral_spawns)
    entry_neutral_spawns:;              entry_bool("Neutral Spawns", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_salty_runback)
    entry_salty_runback:;               entry("Salty Runback", Menu.type.INT, 1, 0, 1, 1, 0, 2, OS.NULL, string_table_salty, OS.NULL, entry_widescreen)
    entry_widescreen:;                  entry_bool("Widescreen", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_stereo_fix)
    entry_stereo_fix:;                  entry_bool("Stereo Fix for Hit SFX", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_variant_random)
    entry_variant_random:;              entry_bool("Random Select With Variants", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_disable_hud)
    entry_disable_hud:;                 entry("Disable HUD", Menu.type.INT, 0, 0, 0, 0, 0, 2, OS.NULL, string_table_disable_hud, OS.NULL, entry_disable_aa)
    entry_disable_aa:;                  entry_bool("Disable Anti-Aliasing", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_full_results)
    entry_full_results:;                entry_bool("Always Show Full Results", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_skip_training_start_cheer)
    entry_skip_training_start_cheer:;   entry_bool("Skip Training Start Cheer", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_default_cpu_level)
    entry_default_cpu_level:;           entry("Default CPU LVL (V.S.)", Menu.type.INT, 0, 10, 0, 0, 0, 10, OS.NULL, string_table_cpu_levels, OS.NULL, entry_puff_sing_anim)
    entry_puff_sing_anim:;              entry_bool("Jigglypuff Sing GFX Anims", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_l_random_char)
    entry_l_random_char:;               entry_bool("'L' Selects Random Character", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_dpad_css_control)
    entry_dpad_css_control:;            entry_bool("Dpad CSS Cursor Control", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_pk_thunder_reflect_crash_fix)
    entry_pk_thunder_reflect_crash_fix:;entry_bool("PK Thunder Reflect Crash Fix", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_flash_guard)
    entry_flash_guard:;                 entry_bool("Flash Guard", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_screenshake)
    entry_screenshake:;                 entry("Screenshake", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 2, OS.NULL, string_table_screenshake, OS.NULL, OS.NULL)

    evaluate num_remix_toggles(num_toggles)
    evaluate remix_toggles_block_size(block_size)
    global variable block_size(0)

    // @ Description
    // Gameplay Toggles
    head_gameplay_settings:
    entry_hitstun:;                     entry("Hitstun", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 1, OS.NULL, string_table_hitstun, OS.NULL, entry_hitlag)
    entry_hitlag:;                      entry("Hitlag", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, 0, 3, OS.NULL, string_table_hitlag, OS.NULL, entry_japanese_di)
    entry_japanese_di:;                 entry_bool("Japanese DI", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_japanese_sounds)
    entry_japanese_sounds:;             entry("Japanese Sounds", Menu.type.INT, 0, 0, 0, 1, 0, 2, OS.NULL, string_table_frequency, OS.NULL, entry_momentum_slide)
    entry_momentum_slide:;              entry_bool("Momentum Slide", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_japanese_shieldstun)
    entry_japanese_shieldstun:;         entry_bool("Japanese Shield Stun", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_z_cancel_opts)
    entry_z_cancel_opts:;               entry("Z-Cancel", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 4, OS.NULL, string_table_z_cancel_opts, OS.NULL, entry_punish_on_failed_z_cancel)
    entry_punish_on_failed_z_cancel:;   entry("Punish Failed Z-Cancel", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 9, punish_fgm_, string_table_failed_z_cancel, OS.NULL, entry_improved_ai)
    entry_improved_ai:;                 entry_bool("Improved AI", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_tripping)
    entry_tripping:;                    entry("Tripping", Menu.type.INT, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_tripping, OS.NULL, entry_footstool)
    entry_footstool:;                   entry_bool("Footstool Jumping", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_air_dodge)
    entry_air_dodge:;                   entry("Air Dodging", Menu.type.INT, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_air_dodge, OS.NULL, entry_jab_lock)
    entry_jab_lock:;                    entry_bool("Jab Locking", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_ledge_jump)
    entry_ledge_jump:;                  entry_bool("Edge C-Jumping", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_perfect_shield)
    entry_perfect_shield:;              entry_bool("Perfect Shielding", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_spot_dodge)
    entry_spot_dodge:;                  entry_bool("Spot Dodging", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_fast_fall_aerials)
    entry_fast_fall_aerials:;           entry_bool("Fast Fall Aerials", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_ledge_trump)
    entry_ledge_trump:;                 entry_bool("Ledge Trumping", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_wall_teching)
    entry_wall_teching:;                entry_bool("Wall Teching", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_charged_smashes)
    entry_charged_smashes:;             entry_bool("Charged Smash Attacks", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_item_containers)
    entry_item_containers:;             entry("Item Containers", Menu.type.INT, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_item_containers, OS.NULL, entry_blastzone_warp)
    entry_blastzone_warp:;              entry("BlastZone Warp *BETA", Menu.type.INT, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_blast_zone, OS.NULL, OS.NULL)

    evaluate num_gameplay_toggles(num_toggles - {num_remix_toggles})
    evaluate gameplay_toggles_block_size(block_size)
    global variable block_size(0)

    // @ Description
    // Random Music Toggles
    head_music_settings:
    entry_play_music:;                      entry_bool("Play Music", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_random_music)
    entry_random_music:;                    entry_bool("Random Music", OS.FALSE, OS.FALSE, OS.TRUE, OS.FALSE, entry_preserve_salty_song)
    entry_preserve_salty_song:;             entry_bool("Salty Runback Preserves Song", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_menu_music)
    entry_menu_music:;                      entry("Menu Music", Menu.type.INT, 0, 0, 1, 0, 0, menu_music.MAX_VALUE, play_menu_music_, string_table_menu_music, OS.NULL, entry_show_music_title)
    entry_show_music_title:;                entry_bool("Music Title at Match Start", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_load_profile_music)
    evaluate LOAD_PROFILE_MUSIC_ENTRY_ORIGIN(origin())
    entry_load_profile_music:;              entry("Load Profile:", Menu.type.INT, 0, 0, 0, 0, 0, 0, load_sub_profile_, num_toggles, string_table_music_profile, OS.NULL, entry_random_music_title)
    entry_random_music_title:;              Menu.entry_title("Random Music Toggles:", toggle_all_, entry_random_music_bonus)
    evaluate first_music_toggle(num_toggles)
    entry_random_music_bonus:;              entry_bool_with_a("Bonus", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.menu.BONUS, entry_random_music_congo_jungle)
    entry_random_music_congo_jungle:;       entry_bool_with_a("Congo Jungle", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.CONGO_JUNGLE, entry_random_music_credits)
    entry_random_music_credits:;            entry_bool_with_a("Credits", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.menu.CREDITS, entry_random_music_data)
    entry_random_music_data:;               entry_bool_with_a("Data", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.menu.DATA, entry_random_music_dream_land)
    entry_random_music_dream_land:;         entry_bool_with_a("Dream Land", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.DREAM_LAND, entry_random_music_duel_zone)
    entry_random_music_duel_zone:;          entry_bool_with_a("Duel Zone", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.DUEL_ZONE, entry_random_music_final_destination)
    entry_random_music_final_destination:;  entry_bool_with_a("Final Destination", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.FINAL_DESTINATION, entry_random_music_how_to_play)
    entry_random_music_how_to_play:;        entry_bool_with_a("How To Play", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.HOW_TO_PLAY, entry_random_music_hyrule_castle)
    entry_random_music_hyrule_castle:;      entry_bool_with_a("Hyrule Castle", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.HYRULE_CASTLE, entry_random_music_meta_crystal)
    entry_random_music_meta_crystal:;       entry_bool_with_a("Meta Crystal", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.META_CRYSTAL, entry_random_music_mushroom_kingdom)
    entry_random_music_mushroom_kingdom:;   entry_bool_with_a("Mushroom Kingdom", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.MUSHROOM_KINGDOM, entry_random_music_peachs_castle)
    entry_random_music_peachs_castle:;      entry_bool_with_a("Peach's Castle", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.PEACHS_CASTLE, entry_random_music_planet_zebes)
    entry_random_music_planet_zebes:;       entry_bool_with_a("Planet Zebes", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.PLANET_ZEBES, entry_random_music_saffron_city)
    entry_random_music_saffron_city:;       entry_bool_with_a("Saffron City", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.SAFFRON_CITY, entry_random_music_sector_z)
    entry_random_music_sector_z:;           entry_bool_with_a("Sector Z", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.SECTOR_Z, entry_random_music_yoshis_island)
    entry_random_music_yoshis_island:;      entry_bool_with_a("Yoshi's Island", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, BGM.stage.YOSHIS_ISLAND, entry_random_music_first_custom)

    entry_random_music_first_custom:
    // Add custom MIDIs
    define last_toggled_custom_MIDI(0)
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            evaluate last_toggled_custom_MIDI({n})
        }
        evaluate n({n}+1)
    }

    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        entry_random_music_{n}:                                        // always create the label even if we don't create the entry
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            if ({n} == {last_toggled_custom_MIDI}) {
                evaluate next(OS.NULL)
            } else {
                evaluate m({n}+1)
                evaluate next(entry_random_music_{m})
            }
            evaluate music_toggle_{MIDI.MIDI_{n}_FILE_NAME}(num_toggles - {first_music_toggle})
            entry_bool_with_a({MIDI.MIDI_{n}_NAME}, OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, preview_bgm_, {n}, {next})
        }
        evaluate n({n}+1)
    }
    evaluate last_music_toggle(num_toggles)
    evaluate num_music_toggles(num_toggles - {num_remix_toggles} - {num_gameplay_toggles})
    evaluate music_toggles_block_size(block_size)
    global variable block_size(0)

    // @ Description
    // Stage Toggles
    head_stage_settings:
    entry_sss_layout:;                          entry("Stage Select Layout", Menu.type.INT, sss.NORMAL, sss.TOURNAMENT, sss.NORMAL, sss.NORMAL, 0, 1, OS.NULL, string_table_sss_layout, OS.NULL, entry_hazard_mode)
    entry_hazard_mode:;                         entry("Hazard Mode", Menu.type.INT, hazard_mode.NORMAL, hazard_mode.NORMAL, hazard_mode.NORMAL, hazard_mode.NORMAL, 0, 3, OS.NULL, string_table_hazard_mode, OS.NULL, entry_whispy_mode)
    entry_whispy_mode:;                         entry("Whispy Mode", Menu.type.INT, whispy_mode.NORMAL, whispy_mode.NORMAL, whispy_mode.NORMAL, whispy_mode.JAPANESE, 0, 3, OS.NULL, string_table_whispy_mode, OS.NULL, entry_saffron_poke_rate)
    entry_saffron_poke_rate:;                   entry("Saffron Pokemon Rate", Menu.type.INT, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_saffron_poke_rate, OS.NULL, entry_announcer_mode)
    entry_announcer_mode:;                      entry("Pokemon Announcer", Menu.type.INT, announcer_mode.POKEMON, announcer_mode.OFF, announcer_mode.POKEMON, announcer_mode.OFF, 0, 2, OS.NULL, string_table_announcer_mode, OS.NULL, entry_dragon_king_hud)
    entry_dragon_king_hud:;                     entry("Dragon King HUD", Menu.type.INT, dragon_king_hud.DEFAULT, dragon_king_hud.OFF, dragon_king_hud.DEFAULT, dragon_king_hud.DEFAULT, 0, 2, OS.NULL, string_table_dragon_king_hud, OS.NULL, entry_camera_mode)
    entry_camera_mode:;                         entry("Camera Mode", Menu.type.INT, Camera.type.NORMAL, Camera.type.NORMAL, Camera.type.NORMAL, Camera.type.NORMAL, 0, 3, OS.NULL, Camera.type_string_table, OS.NULL, entry_yi_clouds)
    entry_yi_clouds:;                           entry_bool("Yoshi's Island Cloud Anims", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_load_profile_stage)
    evaluate LOAD_PROFILE_STAGE_ENTRY_ORIGIN(origin())
    entry_load_profile_stage:;                  entry("Load Profile:", Menu.type.INT, 0, 1, 2, 0, 0, 2, load_sub_profile_, num_toggles, string_table_stage_profile, OS.NULL, entry_random_stage_title)
    entry_random_stage_title:;                  Menu.entry_title("Random Stage Toggles:", toggle_all_, entry_random_stage_congo_jungle)
    evaluate first_stage_toggle(num_toggles)
    entry_random_stage_congo_jungle:;           entry_bool("Congo Jungle", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_dream_land)
    entry_random_stage_dream_land:;             entry_bool("Dream Land", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_random_stage_dream_land_beta_1)
    entry_random_stage_dream_land_beta_1:;      entry_bool("Dream Land Beta 1", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_random_stage_dream_land_beta_2)
    entry_random_stage_dream_land_beta_2:;      entry_bool("Dream Land Beta 2", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_random_stage_duel_zone)
    entry_random_stage_duel_zone:;              entry_bool("Duel Zone", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_final_destination)
    entry_random_stage_final_destination:;      entry_bool("Final Destination", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_how_to_play)
    entry_random_stage_how_to_play:;            entry_bool("How to Play", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_random_stage_hyrule_castle)
    entry_random_stage_hyrule_castle:;          entry_bool("Hyrule Castle", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_meta_crystal)
    entry_random_stage_meta_crystal:;           entry_bool("Meta Crystal", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_mushroom_kingdom)
    entry_random_stage_mushroom_kingdom:;       entry_bool("Mushroom Kingdom", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_peachs_castle)
    entry_random_stage_peachs_castle:;          entry_bool("Peach's Castle", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_planet_zebes)
    entry_random_stage_planet_zebes:;           entry_bool("Planet Zebes", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_saffron_city)
    entry_random_stage_saffron_city:;           entry_bool("Saffron City", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_sector_z)
    entry_random_stage_sector_z:;               entry_bool("Sector Z", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_yoshis_island)
    entry_random_stage_yoshis_island:;          entry_bool("Yoshi's Island", OS.TRUE, OS.FALSE, OS.FALSE, OS.TRUE, entry_random_stage_mini_yoshis_island)
    entry_random_stage_mini_yoshis_island:;     entry_bool("Mini Yoshi's Island", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_random_stage_first_custom)

    entry_random_stage_first_custom:
    // Add custom stages
    define last_toggled_custom_stage(0)
    evaluate n(0x29)
    while {n} <= Stages.id.MAX_STAGE_ID {
        evaluate can_toggle({Stages.STAGE_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            evaluate last_toggled_custom_stage({n})
        }
        evaluate n({n}+1)
    }

    map 0x7E, 0x7F, 1 // temporarily make ~ be Omega
    evaluate n(0x29)
    while {n} <= Stages.id.MAX_STAGE_ID {
        entry_random_stage_{n}:                                        // always create the label even if we don't create the entry
        evaluate can_toggle({Stages.STAGE_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            if ({n} == {last_toggled_custom_stage}) {
                evaluate next(OS.NULL)
            } else {
                evaluate m({n}+1)
                evaluate next(entry_random_stage_{m})
            }
            evaluate stage_toggle_{Stages.STAGE_{n}_NAME}(num_toggles - {first_stage_toggle})
            entry_bool({Stages.STAGE_{n}_TITLE}, OS.TRUE, {Stages.STAGE_{n}_TE}, {Stages.STAGE_{n}_NE}, OS.TRUE, {next})
        }
        evaluate n({n}+1)
    }
    map 0, 0, 256 // restore string mappings
    evaluate last_stage_toggle(num_toggles)
    evaluate num_stage_toggles(num_toggles - {num_remix_toggles} - {num_gameplay_toggles} - {num_music_toggles})
    evaluate stage_toggles_block_size(block_size)
    global variable block_size(0)

    print "*******************************\n{num_remix_toggles}, {num_gameplay_toggles}, {num_stage_toggles}, {num_music_toggles}\n"

    // @ Description
    // Pokemon Toggles
    head_pokemon_settings:
    entry_pokemon_voices:;                 entry("Pokemon SFX", Menu.type.INT, 0, 0, 0, 1, 0, 2, OS.NULL, string_table_pokemon_voices, OS.NULL, entry_pokemon_toggle_all)
    entry_pokemon_toggle_all:;             Menu.entry_title("Toggle:", toggle_all_, entry_pokemon_onix)
    entry_pokemon_onix:;                   entry_bool("Onix", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_snorlax)
    entry_pokemon_snorlax:;                entry_bool("Snorlax", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_goldeen)
    entry_pokemon_goldeen:;                entry_bool("Goldeen", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_meowth)
    entry_pokemon_meowth:;                 entry_bool("Meowth", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_charizard)
    entry_pokemon_charizard:;              entry_bool("Charizard", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_beedrill)
    entry_pokemon_beedrill:;               entry_bool("Beedrill", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_blastoise)
    entry_pokemon_blastoise:;              entry_bool("Blastoise", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_chansey)
    entry_pokemon_chansey:;                entry_bool("Chansey", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_starmie)
    entry_pokemon_starmie:;                entry_bool("Starmie", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_hitmonlee)
    entry_pokemon_hitmonlee:;              entry_bool("Hitmonlee", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_koffing)
    entry_pokemon_koffing:;                entry_bool("Koffing", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_clefairy)
    entry_pokemon_clefairy:;               entry_bool("Clefairy", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_pokemon_mew)
    entry_pokemon_mew:;                    entry_bool("Mew", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, OS.NULL)

    evaluate num_pokemon_toggles(num_toggles - {num_remix_toggles} - {num_gameplay_toggles} - {num_music_toggles} - {num_stage_toggles})
    evaluate pokemon_toggles_block_size(block_size)
    global variable block_size(0)

    // @ Description
    // Player Tags
    head_player_tags:
    evaluate MAX_TAGS(20)
    evaluate n(0)
    while {n} < {MAX_TAGS} {
        evaluate m({n}+1)
        if ({m} == {MAX_TAGS}) {
            evaluate next(OS.NULL)
        } else {
            evaluate next(entry_player_tags_{m})
        }
        entry_player_tags_{n}:; Menu.entry_input(toggle_edit_mode_, {n}, {next})
        evaluate n({n}+1)
    }

    // @ Description
    // Show Other Screens
    head_other_screens_:
    entry_debug:;          Menu.entry_title_with_extra("Debug", view_screen_, 0x0003, entry_view_intro)
    entry_view_intro:;     Menu.entry_title_with_extra("View Intro", view_screen_, 0x001C, entry_view_htp)
    entry_view_htp:;       Menu.entry_title_with_extra("View How to Play", view_screen_, 0x003C, entry_view_credits)
    entry_view_credits:;   Menu.entry_title_with_extra("View Credits", view_credits_, 0x0038, entry_view_gallery)
    entry_view_gallery:;   entry("View Gallery", Menu.type.INT, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 32, view_gallery, string_table_gallery, OS.NULL, OS.NULL)

    // @ Description
    // Frames to block B from triggering exiting submenu
    back_blocked:
    dw 0

    // @ Description
    // Toggles edit mode for inputs
    scope toggle_edit_mode_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        // v0 = menu item
        lw      t1, 0x0004(v0)              // t1 = current edit mode flag
        xori    t0, t1, 0x0001              // t0 = new edit mode (0 -> 1, 1 -> 0)
        sw      t0, 0x0004(v0)              // set edit mode

        // ensure edit legend is hidden/shown accordingly
        lli     a0, 18                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t1, r0                  // a1 = display

        // ensure pagination legend is hidden/shown accordingly
        lli     a0, 19                      // a0 = group
        jal     Render.toggle_group_display_
        or      a1, t0, r0                  // a1 = display

        lli     t8, 0x0000                  // t8 = display on

        li      t4, Menu.keyboard_struct
        lw      t4, 0x000C(t4)              // t4 = keyboard tag string object
        lw      t5, 0x0034(t4)              // t5 = string address

        lli     t1, 0x000A                  // t1 = 10
        li      t2, back_blocked
        bnez    t0, _edit_mode              // if entering edit mode, go to _edit_mode
        sw      t1, 0x0000(t2)              // block B from exiting submenu

        // if here, we're exiting edit mode
        li      t6, Menu.cancel_edit        // t6 = address of cancel_edit flag
        lb      t2, 0x0000(t6)              // t2 = cancel_edit value
        bnezl   t2, _cancel                 // if canceling, don't save
        sb      r0, 0x0000(t6)              // clear cancel flag

        lbu     t6, 0x0000(t5)              // t6 = first character
        beqz    t6, _clear_tag              // if saving an empty string, clear the tag
        addiu   t2, v0, 0x0028              // t2 = address of string
        lw      t3, 0x0020(v0)              // t3 = label object
        sw      t2, 0x0034(t3)              // update string address
        addiu   t0, r0, -0x0001             // t0 = 0xFFFFFFFF = WHITE
        sw      t0, 0x0040(t3)              // set color to white

        // copy characters from menu entry
        lw      t6, 0x0000(t5)              // t6 = first 4 chars
        sw      t6, 0x0028(v0)              // save first 4 chars
        lw      t6, 0x0004(t5)              // t6 = next 4 chars
        sw      t6, 0x002C(v0)              // save next 4 chars
        lw      t6, 0x0008(t5)              // t6 = next 4 chars
        sw      t6, 0x0030(v0)              // save next 4 chars
        lw      t6, 0x000C(t5)              // t6 = next 4 chars
        sw      t6, 0x0034(v0)              // save next 4 chars
        lw      t6, 0x0010(t5)              // t6 = last 4 chars
        sw      t6, 0x0038(v0)              // save last 4 chars
        sw      r0, 0x0030(t3)              // clear pointer to force redraw

        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.TOGGLE         // a0 - fgm_id

        b       _end
        nop

        _clear_tag:
        jal     clear_tag_
        nop
        b       _end
        nop

        _cancel:
        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id
        b       _end
        nop

        _edit_mode:
        addiu   t2, v0, 0x0028              // t2 = address of string

        // copy characters from menu entry
        lw      t6, 0x0000(t2)              // t6 = first 4 chars
        sw      t6, 0x0000(t5)              // save first 4 chars
        lw      t6, 0x0004(t2)              // t6 = next 4 chars
        sw      t6, 0x0004(t5)              // save next 4 chars
        lw      t6, 0x0008(t2)              // t6 = next 4 chars
        sw      t6, 0x0008(t5)              // save next 4 chars
        lw      t6, 0x000C(t2)              // t6 = next 4 chars
        sw      t6, 0x000C(t5)              // save next 4 chars
        lw      t6, 0x0010(t2)              // t6 = last 4 chars
        sw      t6, 0x0010(t5)              // save last 4 chars
        sw      r0, 0x0030(t4)              // clear pointer to force redraw

        lli     t1, 0x0000                  // t1 = 0 = char_index
        _loop:
        lbu     t6, 0x0000(t2)              // t6 = char
        addiu   t2, t2, 0x0001              // t2 = next char address
        bnezl   t6, _loop                   // if char is not null, keep looping
        addiu   t1, t1, 0x0001              // t1 = char_index

        li      t0, Menu.char_index
        sb      t1, 0x0000(t0)              // reset char index to last char + 1

        lli     t8, 0x0001                  // t8 = display off

        _end:
        li      t0, info                    // t0 = menu info
        lw      t0, 0x0008(t0)              // t0 = cursor object
        lw      t0, 0x0084(t0)              // t0 = underline object
        sw      t8, 0x007C(t0)              // update display of underline object

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // allocate stack space
    }

    // @ Description
    // Clears a player tag
    scope clear_tag_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      a0, info                    // a0 = address of info
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        lw      t1, 0x0010(v0)              // t1 = a_function routine
        li      t2, toggle_edit_mode_       // t2 = toggle_edit_mode_
        bne     t1, t2, _end                // if not on an editable entry, skip
        lw      t1, 0x0004(v0)              // t1 = edit mode if editable entry
        bnez    t1, _end                    // if in edit mode, don't allow clearing
        addiu   t0, v0, 0x0028              // t0 = address of string

        sw      r0, 0x0028(v0)              // clear string
        sw      r0, 0x002C(v0)              // ~
        sw      r0, 0x0030(v0)              // ~
        sw      r0, 0x0034(v0)              // ~
        sw      r0, 0x0038(v0)              // ~

        // Clear player tag from port if selected
        lli     t2, 0x0000                  // t2 = port
        li      t4, PlayerTag.enable_for_port
        li      t6, CharacterSelectDebugMenu.PlayerTag.string_table

        _loop_port:
        sll     t3, t2, 0x0002              // t3 = offset to port
        addu    t1, t4, t3                  // t1 = address of port flag
        lw      t5, 0x0000(t1)              // t5 = >=1 if enabled, 0 if not
        beqz    t5, _next_port              // if not enabled, skip
        sll     t5, t5, 0x0002              // t5 = offset to custom string pointer
        addu    t5, t6, t5                  // t5 = address of custom string pointer
        lw      t5, 0x0000(t5)              // t5 = custom string address
        beql    t5, t0, _next_port          // if this one was selected, clear it
        sw      r0, 0x0000(t1)              // clear port flag
        _next_port:
        sltiu   t5, t2, 0x0003              // t5 = 1 if we haven't gotten to last port yet
        bnez    t5, _loop_port              // if more ports to check, keep looping
        addiu   t2, t2, 0x0001              // t2 = next port

        lw      t0, 0x0020(v0)              // t0 = string object
        li      t1, 0x808080FF              // t1 = set color to gray when not set
        sw      t1, 0x0040(t0)              // set color to gray
        li      t1, Menu.string_not_set
        sw      t1, 0x0034(t0)              // set string to Menu.string_not_set

        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.TOGGLE         // a0 - fgm_id

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // allocate stack space
    }

    // @ Description
    // SRAM blocks for toggle saving.
    OS.align(16)
    block_remix:; SRAM.block((({remix_toggles_block_size} / 32) + 1) * 4)
    OS.align(16)
    block_gameplay:; SRAM.block((({gameplay_toggles_block_size} / 32) + 1) * 4)
    OS.align(16)
    block_music:; SRAM.block((({music_toggles_block_size} / 32) + 1) * 4)
    OS.align(16)
    block_stages:; SRAM.block((({stage_toggles_block_size} / 32) + 1) * 4)
    OS.align(16)
    block_pokemon:; SRAM.block((({pokemon_toggles_block_size} / 32) + 1) * 4)
    OS.align(16)
    block_tags:; SRAM.block({MAX_TAGS} * 20) // 20 characters per tag

    sram_block_table:
    dw block_remix
    dw block_gameplay
    dw block_music
    dw block_stages
    dw block_pokemon
    dw block_tags
    dw 0 // leave blank to end

    block_head_table:
    dw head_remix_settings
    dw head_gameplay_settings
    dw head_music_settings
    dw head_stage_settings
    dw head_pokemon_settings
    dw head_player_tags
    dw 0 // leave blank for last

    profile_defaults_CE:; write_defaults_for(CE)
    profile_defaults_TE:; write_defaults_for(TE)
    profile_defaults_NE:; write_defaults_for(NE)
    profile_defaults_JP:; write_defaults_for(JP)

    profiles:
    dw profile_defaults_CE
    dw profile_defaults_TE
    dw profile_defaults_NE
    dw profile_defaults_JP

    variable num_music_profiles(0)
    variable num_stage_profiles(0)

    // @ Description
    // Adds a music profile
    // @ Arguments
    // profile - ID of profile
    // display_text - text to display in the Settings menu
    macro add_music_profile(profile, display_text) {
        evaluate n(num_music_profiles)
        global variable num_music_profiles(num_music_profiles + 1)
        global define music_profile_{profile}({n})

        music_profile_defaults_{n}:
        evaluate o(origin())
        global define MUSIC_PROFILE_DEFAULTS_{n}_ORIGIN({o})
        evaluate i({first_music_toggle})
        while {i} < {last_music_toggle} {
            dw OS.FALSE                       // don't include by default
            evaluate i({i} + 1)
        }

        music_profile_defaults_{n}_string:; String.insert({display_text})

        // now update the max value for the entry
        pushvar origin, base

        origin {LOAD_PROFILE_MUSIC_ENTRY_ORIGIN} + 0x000C // max value of load profile entry
        dw ({n} + 1) // since we always include community

        pullvar base, origin
    }

    // @ Description
    // Constants for the vanilla music toggles
    evaluate music_toggle_BONUS(0)
    evaluate music_toggle_CONGO_JUNGLE(1)
    evaluate music_toggle_CREDITS(2)
    evaluate music_toggle_DATA(3)
    evaluate music_toggle_DREAM_LAND(4)
    evaluate music_toggle_DUEL_ZONE(5)
    evaluate music_toggle_FINAL_DESTINATION(6)
    evaluate music_toggle_HOW_TO_PLAY(7)
    evaluate music_toggle_HYRULE_CASTLE(8)
    evaluate music_toggle_META_CRYSTAL(9)
    evaluate music_toggle_MUSHROOM_KINGDOM(10)
    evaluate music_toggle_PEACHS_CASTLE(11)
    evaluate music_toggle_PLANET_ZEBES(12)
    evaluate music_toggle_SAFFRON_CITY(13)
    evaluate music_toggle_SECTOR_Z(14)
    evaluate music_toggle_YOSHIS_ISLAND(15)

    // @ Description
    // Adds a track to a music profile
    // @ Arguments
    // profile - ID of profile
    // track - ID of track
    macro add_to_music_profile(profile, track) {
        pushvar origin, base

        define n({music_toggle_{track}})

        origin {MUSIC_PROFILE_DEFAULTS_{music_profile_{profile}}_ORIGIN} + ({n} * 4)
        dw OS.TRUE

        pullvar base, origin
    }

    // @ Description
    // Adds a stage profile
    // @ Arguments
    // profile - ID of profile
    // display_text - text to display in the Settings menu
    macro add_stage_profile(profile, display_text) {
        evaluate n(num_stage_profiles)
        global variable num_stage_profiles(num_stage_profiles + 1)
        global define stage_profile_{profile}({n})

        stage_profile_defaults_{n}:
        evaluate o(origin())
        global define STAGE_PROFILE_DEFAULTS_{n}_ORIGIN({o})
        evaluate i({first_stage_toggle})
        while {i} < {last_stage_toggle} {
            dw OS.FALSE                       // don't include by default
            evaluate i({i} + 1)
        }

        stage_profile_defaults_{n}_string:; String.insert({display_text})

        // now update the max value for the entry
        pushvar origin, base

        origin {LOAD_PROFILE_STAGE_ENTRY_ORIGIN} + 0x000C // max value of load profile entry
        dw ({n} + 3) // since we always include community, tournament and netplay

        pullvar base, origin
    }

    // @ Description
    // Constants for the vanilla stage toggles
    evaluate stage_toggle_congo_jungle(0)
    evaluate stage_toggle_dream_land(1)
    evaluate stage_toggle_dream_land_beta_1(2)
    evaluate stage_toggle_dream_land_beta_2(3)
    evaluate stage_toggle_duel_zone(4)
    evaluate stage_toggle_final_destination(5)
    evaluate stage_toggle_how_to_play(6)
    evaluate stage_toggle_hyrule_castle(7)
    evaluate stage_toggle_meta_crystal(8)
    evaluate stage_toggle_mushroom_kingdom(9)
    evaluate stage_toggle_peachs_castle(10)
    evaluate stage_toggle_planet_zebes(11)
    evaluate stage_toggle_saffron_city(12)
    evaluate stage_toggle_sector_z(13)
    evaluate stage_toggle_yoshis_island(14)
    evaluate stage_toggle_mini_yoshis_island(15)

    // @ Description
    // Adds a track to a stage profile
    // @ Arguments
    // profile - ID of profile
    // stage - ID of track
    macro add_to_stage_profile(profile, stage) {
        pushvar origin, base

        define n({stage_toggle_{stage}})

        origin {STAGE_PROFILE_DEFAULTS_{stage_profile_{profile}}_ORIGIN} + ({n} * 4)
        dw OS.TRUE

        pullvar base, origin
    }

    // Include music profiles here
    include "/music/profiles/vanilla.asm"
    include "/music/profiles/classics.asm"
    include "/music/profiles/intobattle.asm"
    include "/music/profiles/positivevibes.asm"
    include "/music/profiles/slappers.asm"
    include "/music/profiles/freshjams.asm"
    include "/music/profiles/staff.asm"

    // Include stage profiles here
    include "/stages/profiles/competitive.asm"
    include "/stages/profiles/vanilla.asm"
    include "/stages/profiles/dreamlandonly.asm"
    include "/stages/profiles/no_omega.asm"
    include "/stages/profiles/no_variant.asm"
    include "/stages/profiles/staff.asm"

    music_profiles:
    dw profile_defaults_CE + ({first_music_toggle} * 4)
    evaluate n(0)
    while {n} < num_music_profiles {
        dw music_profile_defaults_{n}
        evaluate n({n} + 1)
    }

    string_table_music_profile:
    dw profile_ce
    evaluate n(0)
    while {n} < num_music_profiles {
        dw music_profile_defaults_{n}_string
        evaluate n({n} + 1)
    }

    stage_profiles:
    dw profile_defaults_CE + ({first_stage_toggle} * 4)
    dw profile_defaults_TE + ({first_stage_toggle} * 4)
    dw profile_defaults_NE + ({first_stage_toggle} * 4)
    evaluate n(0)
    while {n} < num_stage_profiles {
        dw stage_profile_defaults_{n}
        evaluate n({n} + 1)
    }

    string_table_stage_profile:
    dw profile_ce
    dw profile_te
    dw profile_semicomp
    evaluate n(0)
    while {n} < num_stage_profiles {
        dw stage_profile_defaults_{n}_string
        evaluate n({n} + 1)
    }

    profile_head_table:
    dw head_remix_settings
    dw head_gameplay_settings
    dw head_music_settings
    dw head_stage_settings
    dw head_pokemon_settings
    dw 0 // leave blank for last

    // @ Description
    // This function will load toggle settings based on the selected profile
    scope load_profile_: {
        addiu   sp, sp,-0x0020                 // allocate stack space
        sw      ra, 0x0004(sp)                 // ~
        sw      t0, 0x0008(sp)                 // ~
        sw      t1, 0x000C(sp)                 // ~
        sw      t2, 0x0010(sp)                 // ~
        sw      t3, 0x0014(sp)                 // ~
        sw      t4, 0x0018(sp)                 // save registers

        li      t0, head_super_menu            // t0 = address of menu entry
        lw      t0, 0x0004(t0)                 // t0 = selected profile
        li      t1, profiles
        sll     t2, t0, 0x0002                 // t2 = offset to profile defaults
        addu    t1, t1, t2                     // t1 = address of profile defaults
        lw      t2, 0x0000(t1)                 // t2 = address of profile defaults
        li      t3, profile_head_table         // t3 = address of first head pointer
        lw      t0, 0x0000(t3)                 // t0 = first remix setting entry address

        _begin:
        addiu   t3, t3, 0x0004                 // t3 = address of next head pointer

        _loop:
        beqz    t0, _next                      // if (entry = null), go to next
        nop

        // skip titles
        lli     t4, Menu.type.TITLE            // t4 = title type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t4, t1, _skip                  // if (type == title), skip
        nop

        // skip inputs
        lli     t4, Menu.type.INPUT            // t4 = input type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t4, t1, _skip                  // if (type == input), skip
        nop

        lw      t1, 0x0000(t2)                 // t1 = default profile value
        sw      t1, 0x0004(t0)                 // store default value as current value
        addiu   t2, t2, 0x0004                 // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)                 // t0 = entry->next
        b       _loop                          // check again
        nop

        _next:
        lw      t0, 0x0000(t3)                 // t0 = next head entry address
        bnez    t0, _begin                     // if more blocks, do loop
        nop                                    // ~

        _end:
        lw      ra, 0x0004(sp)                 // ~
        lw      t0, 0x0008(sp)                 // ~
        lw      t1, 0x000C(sp)                 // ~
        lw      t2, 0x0010(sp)                 // ~
        lw      t3, 0x0014(sp)                 // ~
        lw      t4, 0x0018(sp)                 // restore registers
        addiu   sp, sp, 0x0020                 // deallocate stack sapce
        jr      ra                             // return
        nop
    }

    // @ Description
    // This function will figure out the current profile based on the current toggle values
    // @ Returns
    // v0 - current profile_id
    scope get_current_profile_: {
        addiu   sp, sp,-0x0020                 // allocate stack space
        sw      ra, 0x0004(sp)                 // ~
        sw      t0, 0x0008(sp)                 // ~
        sw      t1, 0x000C(sp)                 // ~
        sw      t2, 0x0010(sp)                 // ~
        sw      t3, 0x0014(sp)                 // ~
        sw      t4, 0x0018(sp)                 // ~
        sw      t5, 0x001C(sp)                 // save registers

        lli     v0, profile.CE                 // v0 = CE

        _load:
        sll     t5, v0, 0x0002                 // t5 = offset to profile defaults pointer
        li      t2, profiles
        addu    t2, t2, t5                     // t2 = address of defaults pointer
        lw      t2, 0x0000(t2)                 // t2 = defaults
        li      t4, profile_head_table         // t4 = address of first head pointer
        lw      t0, 0x0000(t4)                 // t0 = first remix setting entry address

        _begin:
        addiu   t4, t4, 0x0004                 // t4 = next head pointer address

        _loop:
        beqz    t0, _next                      // if (entry = null), go to next
        nop

        // skip titles when importing
        lli     t3, Menu.type.TITLE            // t3 = title type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t3, t1, _skip                  // if (type == title), skip
        nop

        // skip inputs when importing
        lli     t3, Menu.type.INPUT            // t3 = input type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t3, t1, _skip                  // if (type == input), skip
        nop

        lw      t1, 0x0000(t2)                 // t1 = default profile value
        lw      t3, 0x0004(t0)                 // t3 = current value
        bne     t1, t3, _next_profile          // if (default value != current value) then this profile isn't loaded
        nop
        addiu   t2, t2, 0x0004                 // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)                 // t0 = entry->next
        b       _loop                          // check again
        nop

        _next:
        lw      t3, 0x0000(t4)                 // t3 = next head entry address
        bnezl   t3, _begin                     // if more blocks, do loop
        or      t0, r0, t3                     // t0 = next head entry address

        _next_profile:
        beqz    t0, _end                       // if (entry = null), then we have the correct profile in v0
        nop
        sltiu   t5, v0, profile.CUSTOM - 1     // t5 = 1 if we haven't reached the end of profiles
        bnez    t5, _load                      // if more profiles to check, load the next one
        addiu   v0, v0, 0x0001                 // v0 = next profile index

        // if we made it here, it's not one of our profiles, and v0 = CUSTOM

        _end:
        lw      ra, 0x0004(sp)                 // ~
        lw      t0, 0x0008(sp)                 // ~
        lw      t1, 0x000C(sp)                 // ~
        lw      t2, 0x0010(sp)                 // ~
        lw      t3, 0x0014(sp)                 // ~
        lw      t4, 0x0018(sp)                 // ~
        lw      t5, 0x001C(sp)                 // restore registers
        addiu   sp, sp, 0x0020                 // deallocate stack sapce
        jr      ra                             // return
        nop
    }

    // @ Description
    // Reads the value of a given toggle
    macro read(toggle_name, output_register) {
            OS.read_word(Toggles.{toggle_name} + 0x4, {output_register})
    }

    // @ Description
    // Flag to indicate if we got here via 'L' Shortcut on Character or Stage Select Screen (and which screen we should return to)
    // Store current and previous screen as separate bytes
    shortcut_stored_screens:
    db 0, 0
    OS.align(4)

    // @ Description
    // Holds 'L' Shortcut timer per port
    shortcut_L_timer:
    db 0, 0, 0, 0

    // @ Description
    // Handles 'L' Shortcut to quickly access Settings page from CSS or SSS
    // @ Returns
    // a0 - (bool) changed_screen?
    scope settings_shortcut: {
        addiu   sp, sp,-0x0010              // allocate stack sapce
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        _check_L_held:
        // a1 = player index (port 0 - 3)
        li      a0, Joypad.L                // a0 - button mask
        li      a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_       // v0 = L pressed?
        nop
        li      a0, Toggles.shortcut_L_timer
        addu    a0, a0, a1                  // a0 = address of port's buffer
        beqzl   v0, _no_screen_change       // if L not pressed, skip
        sb      r0, 0x0000(a0)              // clear timer if L not held
        lb      t1, 0x0000(a0)              // t1 = timer for settings shortcut
        addiu   t1, t1, 1                   // t1++
        sb      t1, 0x0000(a0)              // save updated timer
        sltiu   t1, t1, 60                  // wait 60 frames
        bnez    t1, _no_screen_change
        nop

        // save CSS selections for when we come back
        _save_css:
        // check which type of CSS and use the appropriate routine
        li      v0, Global.current_screen   // v0 = address of current_screen (note: keep v0 for routine)
        lbu     a0, 0x0000(v0)              // a0 = current screens
        addiu   t1, r0, Global.screen._1P_CSS
        li      t0, 0x80137F5C              // t0 = 1P routine
        beq     a0, t1, _save_css_routine_1p
        addiu   t1, r0, Global.screen.VS_CSS
        li      t0, 0x8013A664              // t0 = VS routine
        beq     a0, t1, _save_css_routine
        addiu   t1, r0, Global.screen.TRAINING_CSS
        li      t0, 0x801375D8              // t0 = Training routine
        beq     a0, t1, _save_css_routine
        addiu   t1, r0, Global.screen.BONUS_1_CSS
        beq     a0, t1, _remember_bonus_type
        addiu   t1, r0, Global.screen.BONUS_2_CSS
        beq     a0, t1, _remember_bonus_type
        nop
        // if we're here, the CSS doesn't need saving
        b       _screen_change              // branch
        nop

        // remember which Bonus mode we were on (since the screen_id doesn't update if we switch modes)
        _remember_bonus_type:
        li      t0, 0x80137714              // t0 = bonus mode flag
        lw      a0, 0x0000(t0)              // a0 = value of bonus mode flag (0 if BTT, 1 if BTP, 2 if RTTF)
        beqzl   a0, pc() + 12               // use appropriate screen_id
        addiu   t1, r0, Global.screen.BONUS_1_CSS
        addiu   t1, r0, Global.screen.BONUS_2_CSS
        li      a0, Global.current_screen   // a0 = address of current_screen
        sb      t1, 0x0000(a0)              // set current_screen to appropriate value
        b       _screen_change              // branch
        nop

        _save_css_routine_1p:
        li      a0, 0x80138EE8              // a0 = address of currently selected 1P character
        _save_css_routine:
        jalr    t0                          // call save css routine
        nop

        _screen_change:
        li      a0, Toggles.shortcut_L_timer
        sw      r0, 0x0000(a0)              // clear all port timers if L held is met
        li      a0, Global.current_screen   // a0 = address of current_screen
        lhu     a0, 0x0000(a0)              // a0 = current_screen + previous_screen
        li      v0, shortcut_stored_screens // v0 = shortcut_stored_screens
        sh      a0, 0x0000(v0)              // store current_screen + previous_screen id
        li      v0, Toggles.normal_options  // v0 = normal_options flag
        sb      r0, 0x0000(v0)              // normal_options = FALSE
        lli     a0, Global.screen.OPTION    // a0 = screen_id (options)
        jal     Menu.change_screen_         // generate screen_interrupt
        nop

        jal     BGM.handle_sss_shortcut     // refresh song if using 64 menu music
        nop

        b       _end
        lli     a0, OS.TRUE                 // a0 = true

        _no_screen_change:
        lli     a0, OS.FALSE                // a0 = false

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack sapce
        jr      ra                          // return
        nop
    }

}


} // __TOGGLES__
