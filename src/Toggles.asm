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

        OS.read_word(Global.match_info, at)	// at = current match info struct
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

    // @ Description
    // Keeps track of what menu we're on.
    // 0 = Super Menu
    // 1 = Remix Settings
    // 2 = Music Settings
    // 3 = Stage Settings
    // 4 = Player Tags
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
        bnez    t1, _set_notes_display      // if (Load Profile is not selected), then don't display it
        nop
        or      s0, v0, r0                  // s0 = current profile
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        lw      t0, 0x0004(v0)              // t0 = entry.current_value
        beq     t0, s0, _set_notes_display  // if (current profile is not the selected profile), then don't display it
        nop
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
        li      t0, reset_menu_music
        lw      t0, 0x0000(t0)              // t0 = reset menu music flag
        beqz    t0, _end                    // if we don't need to reset the menu music, skip
        nop
        // jal     play_menu_music_            // reset menu music
        // lli     v0, 0x0000                  // forces a reset

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
        lli     a0, 0x0007                  // a0 - screen_id (main menu)
        jal     Menu.change_screen_         // exit to main menu
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
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, head_remix_settings     // a0 - address of head
        li      a1, block_misc              // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_misc              // ~
        jal     SRAM.save_                  // save data
        nop

        li      a0, head_music_settings     // a0 - address of head
        li      a1, block_music             // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_music             // ~
        jal     SRAM.save_                  // save data
        nop

        li      a0, head_stage_settings
        li      a1, block_stages            // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_stages            // ~
        jal     SRAM.save_                  // save data
        nop

        li      a0, head_player_tags
        li      a1, block_tags              // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_tags              // ~
        jal     SRAM.save_                  // save data
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Loads toggles from SRAM
    scope load_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, block_misc              // a0 - address of block (misc)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_remix_settings     // a0 - address of head
        li      a1, block_misc              // a1 - address of block
        jal     Menu.import_
        nop

        li      a0, block_music             // a0 - address of block (music)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_music_settings     // a0 - address of head
        li      a1, block_music             // a1 - address of block
        jal     Menu.import_
        nop

        li      a0, block_stages            // a0 - address of block (stages)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_stage_settings
        li      a1, block_stages            // a1 - address of block
        jal     Menu.import_
        nop

        li      a0, block_tags              // a0 - address of block (stages)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_player_tags
        li      a1, block_tags              // a1 - address of block
        jal     Menu.import_
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
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
    show_music_settings_:; set_info_head(head_music_settings, 2)
    show_stage_settings_:; set_info_head(head_stage_settings, 3)
    show_player_tags_:; set_info_head(head_player_tags, 4)

    variable num_toggles(0)

    // @ Description
    // Wrapper for Menu.entry_bool()
    macro entry_bool(title, default_ce, default_te, default_ne, default_jp, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_NE({default_ne})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
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
    // Failed Z-Cancel strings
	
    _7:; db "7% Damage", 0x00
    lava:; db "Lava Floor", 0x00
    shield_break:; db "Shield-Break", 0x00
    instant_ko:; db "Instant K.O.", 0x00
	taunt:; db "Force Taunt", 0x00
	bury:; db "Bury", 0x00
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
	dw _random

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
    menu_music_brawl:; db "BRAWL", 0x00
    menu_music_off:; db "OFF", 0x00
    OS.align(4)

    string_table_menu_music:
    dw default
    dw menu_music_64
    dw menu_music_melee
    dw menu_music_brawl
    dw menu_music_off

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
    // Allows A button to play selected menu music preference
    scope play_menu_music_: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, Toggles.entry_menu_music
        lw      t0, 0x0004(t0)              // t0 = 0 if DEFAULT, 1 if 64, 2 if MELEE, 3 if BRAWL, 4 if OFF

        lli     t1, 0x0001                  // t1 = 1 (64)
        beql    t1, t0, _play               // if 64, then use 64 BGM
        addiu   a1, r0, BGM.menu.MAIN
        lli     t1, 0x0002                  // t1 = 2 (MELEE)
        beql    t1, t0, _play               // if MELEE, then use MELEE BGM
        addiu   a1, r0, BGM.menu.MAIN_MELEE
        lli     t1, 0x0003                  // t1 = 3 (BRAWL)
        beql    t1, t0, _play               // if BRAWL, then use BRAWL BGM
        addiu   a1, r0, BGM.menu.MAIN_BRAWL
        lli     t1, 0x0004                  // t1 = 4 (OFF)
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

        or      a1, ra, r0                  // save ra
        jal     Menu.change_screen_
        lw      a0, 0x0024(v0)              // a0 = screen_id
        or      ra, a1, r0                  // restore ra
        jr      ra
        nop
    }

    // @ Description
    // Loads the credits screen, setting the port
    scope view_credits_: {
        // v0 = menu item
        // 0x0024(v0) = screen_id

        addiu   sp, sp, -0x0010             // allocate stack space
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

        jal     Menu.change_screen_
        lw      a0, 0x0024(v0)              // a0 = screen_id

        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // allocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Contains list of submenus.
    head_super_menu:
    Menu.entry("Load Profile:", Menu.type.U8, OS.FALSE, 0, 3, load_profile_, OS.NULL, string_table_profile, OS.NULL, entry_remix_settings)
    entry_remix_settings:; Menu.entry_title("Remix Settings", show_remix_settings_, entry_music_settings)
    entry_music_settings:; Menu.entry_title("Music Settings", show_music_settings_, entry_stage_settings)
    entry_stage_settings:; Menu.entry_title("Stage Settings", show_stage_settings_, entry_player_tags)
    entry_player_tags:;    Menu.entry_title("Player Tags", show_player_tags_, entry_debug)
    entry_debug:;          Menu.entry_title_with_extra("Debug", view_screen_, 0x0003, entry_view_intro)
    entry_view_intro:;     Menu.entry_title_with_extra("View Intro", view_screen_, 0x001C, entry_view_credits)
    entry_view_credits:;   Menu.entry_title_with_extra("View Credits", view_credits_, 0x0038, OS.NULL)

    // @ Description
    // Miscellaneous Toggles
    head_remix_settings:
    entry_skip_results_screen:;         entry_bool("Skip Results Screen", OS.FALSE, OS.FALSE, OS.TRUE, OS.FALSE, entry_hold_to_pause)
    entry_hold_to_pause:;               entry_bool("Hold To Pause", OS.FALSE, OS.TRUE, OS.TRUE, OS.FALSE, entry_css_panel_menu)
    entry_css_panel_menu:;              entry_bool("CSS Panel Menu", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_practice_overlay)
    entry_practice_overlay:;            entry_bool("Color Overlays", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_cinematic_entry)
    entry_cinematic_entry:;             entry("Cinematic Entry", Menu.type.U8, 0, 0, 0, 0, 0, 2, OS.NULL, string_table_frequency, OS.NULL, entry_flash_on_z_cancel)
    entry_flash_on_z_cancel:;           entry_bool("Flash On Z-Cancel", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_punish_on_failed_z_cancel)
    entry_punish_on_failed_z_cancel:;   entry("Cruel Z-Cancel Mode", Menu.type.U8, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 7, OS.NULL, string_table_failed_z_cancel, OS.NULL, entry_fps)
    entry_fps:;                         entry("FPS Display *BETA", Menu.type.U8, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 2, OS.NULL, string_table_fps, OS.NULL, entry_model_display)
    entry_model_display:;               entry("Model Display", Menu.type.U8, 0, 0, 1, 0, 0, 2, OS.NULL, string_table_poly, OS.NULL, entry_special_model)
    entry_special_model:;               entry("Special Model Display", Menu.type.U8, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, 0, 3, OS.NULL, string_table_model, OS.NULL, entry_advanced_hurtbox)
    entry_advanced_hurtbox:;            entry_bool("Advanced Hurtbox Display", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_hold_to_exit_training)
    entry_hold_to_exit_training:;       entry_bool("Hold To Exit Training", OS.FALSE, OS.TRUE, OS.FALSE, OS.FALSE, entry_improved_combo_meter)
    entry_improved_combo_meter:;        entry_bool("Improved Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_tech_chase_combo_meter)
    entry_tech_chase_combo_meter:;      entry_bool("Tech Chase Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_combo_meter)
    entry_combo_meter:;                 entry_bool("Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_1v1_combo_meter_swap)
    entry_1v1_combo_meter_swap:;        entry_bool("1v1 Combo Meter Swap", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_improved_ai)
    entry_improved_ai:;                 entry_bool("Improved AI", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_neutral_spawns)
    entry_neutral_spawns:;              entry_bool("Neutral Spawns", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_salty_runback)
    entry_salty_runback:;               entry_bool("Salty Runback", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_widescreen)
    entry_widescreen:;                  entry_bool("Widescreen", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_japanese_hitlag)
    entry_japanese_hitlag:;             entry_bool("Japanese Hitlag", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_japanese_di)
    entry_japanese_di:;                 entry_bool("Japanese DI", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_japanese_sounds)
    entry_japanese_sounds:;             entry("Japanese Sounds", Menu.type.U8, 0, 0, 0, 1, 0, 2, OS.NULL, string_table_frequency, OS.NULL, entry_momentum_slide)
    entry_momentum_slide:;              entry_bool("Momentum Slide", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_japanese_shieldstun)
    entry_japanese_shieldstun:;         entry_bool("Japanese Shield Stun", OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, entry_stereo_fix)
    entry_stereo_fix:;                  entry_bool("Stereo Fix for Hit SFX", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_variant_random)
    entry_variant_random:;              entry_bool("Random Select With Variants", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_disable_hud)
    entry_disable_hud:;                 entry("Disable HUD", Menu.type.U8, 0, 0, 0, 0, 0, 2, OS.NULL, string_table_disable_hud, OS.NULL, entry_disable_aa)
    entry_disable_aa:;                  entry_bool("Disable Anti-Aliasing", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_full_results)
    entry_full_results:;                entry_bool("Always Show Full Results", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_skip_training_start_cheer)
    entry_skip_training_start_cheer:;   entry_bool("Skip Training Start Cheer", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_tripping)
    entry_tripping:;                    entry("Tripping", Menu.type.U8, 0, 0, 0, 0, 0, 3, OS.NULL, string_table_tripping, OS.NULL, OS.NULL)
    evaluate num_remix_toggles(num_toggles)

    // @ Description
    // Random Music Toggles
    head_music_settings:
    entry_play_music:;                      entry_bool("Play Music", OS.TRUE, OS.TRUE, OS.TRUE, OS.TRUE, entry_random_music)
    entry_random_music:;                    entry_bool("Random Music", OS.FALSE, OS.FALSE, OS.TRUE, OS.FALSE, entry_preserve_salty_song)
    entry_preserve_salty_song:;             entry_bool("Salty Runback Preserves Song", OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, entry_menu_music)
    entry_menu_music:;                      entry("Menu Music", Menu.type.U8, 0, 0, 1, 0, 0, 4, play_menu_music_, string_table_menu_music, OS.NULL, entry_show_music_title)
    entry_show_music_title:;                entry_bool("Music Title at Match Start", OS.TRUE, OS.FALSE, OS.TRUE, OS.TRUE, entry_load_profile_music)
    evaluate LOAD_PROFILE_MUSIC_ENTRY_ORIGIN(origin())
    entry_load_profile_music:;              entry("Load Profile:", Menu.type.U8, 0, 0, 0, 0, 0, 0, load_sub_profile_, num_toggles, string_table_music_profile, OS.NULL, entry_random_music_title)
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
    evaluate num_music_toggles(num_toggles - {num_remix_toggles})

    // @ Description
    // Stage Toggles
    head_stage_settings:
    entry_sss_layout:;                          entry("Stage Select Layout", Menu.type.U8, sss.NORMAL, sss.TOURNAMENT, sss.NORMAL, sss.NORMAL, 0, 1, OS.NULL, string_table_sss_layout, OS.NULL, entry_hazard_mode)
    entry_hazard_mode:;                         entry("Hazard Mode", Menu.type.U8, hazard_mode.NORMAL, hazard_mode.NORMAL, hazard_mode.NORMAL, hazard_mode.NORMAL, 0, 3, OS.NULL, string_table_hazard_mode, OS.NULL, entry_whispy_mode)
    entry_whispy_mode:;                         entry("Whispy Mode", Menu.type.U8, whispy_mode.NORMAL, whispy_mode.NORMAL, whispy_mode.NORMAL, whispy_mode.JAPANESE, 0, 3, OS.NULL, string_table_whispy_mode, OS.NULL, entry_camera_mode)
    entry_camera_mode:;                         entry("Camera Mode", Menu.type.U8, Camera.type.NORMAL, Camera.type.NORMAL, Camera.type.NORMAL, Camera.type.NORMAL, 0, 3, OS.NULL, Camera.type_string_table, OS.NULL, entry_load_profile_stage)
    evaluate LOAD_PROFILE_STAGE_ENTRY_ORIGIN(origin())
    entry_load_profile_stage:;                  entry("Load Profile:", Menu.type.U8, 0, 1, 2, 0, 0, 2, load_sub_profile_, num_toggles, string_table_stage_profile, OS.NULL, entry_random_stage_title)
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
    evaluate num_stage_toggles(num_toggles - {num_remix_toggles} - {num_music_toggles})

    print "*******************************\n{num_remix_toggles}, {num_stage_toggles}, {num_music_toggles}\n"

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
    block_misc:; SRAM.block({num_remix_toggles} * 4)
    block_music:; SRAM.block({num_music_toggles} * 4)
    block_stages:; SRAM.block({num_music_toggles} * 4)
    block_tags:; SRAM.block({MAX_TAGS} * 20) // 20 characters per tag

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

    // @ Description
    // This function will load toggle settings based on the selected profile
    scope load_profile_: {
        addiu   sp, sp,-0x001C                 // allocate stack space
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
        li      t0, head_remix_settings        // t0 = first remix setting entry address

        _begin:
        addu    t3, r0, t0                     // t3 = head

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
        li      t1, head_remix_settings        // t1 = first remix setting entry address
        li      t0, head_music_settings        // t0 = first music setting entry address
        beq     t3, t1, _begin                 // if (finished the remix block) then do the music block next
        nop                                    // ~
        or      t1, r0, t0                     // t1 = first music setting entry address
        li      t0, head_stage_settings        // t0 = first stage setting entry address
        beq     t3, t1, _begin                 // if (finished the music block) then do the random stage block next
        nop                                    // ~

        _end:
        lw      ra, 0x0004(sp)                 // ~
        lw      t0, 0x0008(sp)                 // ~
        lw      t1, 0x000C(sp)                 // ~
        lw      t2, 0x0010(sp)                 // ~
        lw      t3, 0x0014(sp)                 // ~
        lw      t4, 0x0018(sp)                 // restore registers
        addiu   sp, sp, 0x001C                 // deallocate stack sapce
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
        li      t0, head_remix_settings        // t0 = first remix setting entry address

        _begin:
        addu    t4, r0, t0                     // t4 = head

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
        or      t3, r0, t0                     // save t0
        li      t1, head_remix_settings        // t1 = first remix setting entry address
        li      t0, head_music_settings        // t0 = first music setting entry address
        beq     t4, t1, _begin                 // if (finished the remix block) then do the music block next
        nop                                    // ~
        or      t1, r0, t0                     // t1 = first music setting entry address
        li      t0, head_stage_settings        // t0 = first stage setting entry address
        beq     t4, t1, _begin                 // if (finished the music block) then do the random stage block next
        nop                                    // ~
        or      t0, r0, t3                     // restore t0

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
}


} // __TOGGLES__
