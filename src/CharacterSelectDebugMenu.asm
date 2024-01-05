// Character.asm
if !{defined __CHARACTER_SELECT_DEBUG_MENU__} {
define __CHARACTER_SELECT_DEBUG_MENU__()
print "included CharacterSelectDebugMenu.asm\n"

// @ Description
// This file contains modifications to the Character Select screen to support a menu which
// provides greater control over characters and gameplay.

// TODO:
// - CPU Level stuff flashes sometimes when debug menu is on when CPU is selected
// - Team button flashes sometimes when debug menu is on when Team Battle is toggled

include "Global.asm"
include "OS.asm"

scope CharacterSelectDebugMenu {
    // @ Description
    // This points to the object that holds the debug button and menu objects
    debug_control_object:
    dw 0x00000000

    // @ Description
    // Creates the debug menu control object
    // @ Arguments
    // a0 - offset in CharacterSelect.css_player_structs
    scope init_debug_menu_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        // Create a control object which runs the debug menu code every frame.
        Render.register_routine(update_debug_menu_)
        li      a0, debug_control_object
        sw      v0, 0x0000(a0)              // save control object reference for outside routine
        lw      a0, 0x0008(sp)              // a0 = offset in css_player_structs
        sw      a0, 0x0044(v0)              // save offset in css_player_structs
        li      a1, CharacterSelect.css_player_structs // a1 = css_player_structs
        addu    a1, a1, a0                  // a1 = pointer to player struct address
        lw      a1, 0x0000(a1)              // a1 = player struct start
        sw      a1, 0x0040(v0)              // save player struct start address
        li      a1, menu_arrays             // a1 = menu_arrays
        lli     t0, 0x0004                  // t0 = 4 = 1p
        bne     a0, t0, _get_menu_array     // if not 1p, don't need to check single player mode
        sll     t0, a0, 0x0001              // t0 = offset to menu array pointers address
        li      t1, SinglePlayerModes.singleplayer_mode_flag
        lw      t1, 0x0000(t1)              // t1 = 5 if allstar
        lli     t2, SinglePlayerModes.ALLSTAR_ID
        beql    t1, t2, _get_menu_array     // if allstar, set to that menu array offset
        lli     t0, 0x0028                  // t0 = offset to menu array pointers address for allstar

        _get_menu_array:
        addu    a1, a1, t0                  // a1 = pointer to menu array pointers address
        sw      a1, 0x0048(v0)              // save menu array address
        sw      r0, 0x0030(v0)              // 0 out panel reference slots we may not need
        sw      r0, 0x0034(v0)              // 0 out panel reference slots we may not need
        sw      r0, 0x0038(v0)              // 0 out panel reference slots we may not need
        sw      r0, 0x003C(v0)              // 0 out panel reference slots we may not need

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This is the main routine for the debug menu
    // @ Arguments
    // a0 - debug control object
    // 0x30(a0) - reference to debug button object p1
    // 0x34(a0) - reference to debug button object p2
    // 0x38(a0) - reference to debug button object p3
    // 0x3C(a0) - reference to debug button object p4
    // 0x40(a0) - address of css player struct
    // 0x44(a0) - offset in css_player_structs
    // 0x48(a0) - address of menu array
    scope update_debug_menu_: {
        OS.save_registers()
        // a0 => 0x0010(sp)

        li      a1, CharacterSelect.css_settings
        lw      s4, 0x0044(a0)              // s4 = offset to CSS settings
        addu    a1, a1, s4                  // a1 = address of CSS settings
        lbu     s0, 0x0000(a1)              // s0 = number of panels
        lw      s1, 0x0040(a0)              // s1 = address of CSS player struct
        lw      s2, 0x0030(a0)              // s2 = debug button object for 1p, if non-zero
        lli     s3, 0x00B8                  // s3 = size of CSS panel array
        beqzl   s4, pc() + 8                // if VS, size is 0xBC
        lli     s3, 0x00BC                  // s3 = size of CSS panel array
        or      s5, r0, s0                  // s5 = number of panels (does not change in loop below)
        lli     t9, 0x0000                  // t9 = loop index

        lli     t0, 0x0008                  // t0 = offset to CSS settings for Training
        beql    t0, s4, pc() + 8            // if training, loop 4 times (there are 4 CSS panel structs)
        lli     s0, 0x0004                  // s0 = number of panels

        li      t0, Render.display_order_room
        lui     t1, 0x4000                  // t1 = 0x40000000 (render after 0x80000000)
        sw      t1, 0x0000(t0)              // update display order within rooms for our draw_texture calls

        _loop:
        lli     t2, 0x0001                  // t2 = 1 = number of panels for 1P/Bonus
        beql    t2, s5, pc() + 12           // if 1P/Bonus, then token object is in different spot
        lw      t0, 0x0028(s1)              // t0 = token object
        lw      t0, 0x0004(s1)              // t0 = token object
        beqz    t0, _next                   // if no token object, skip
        nop

        // on VS, check if panel is active by determining if doors are open all the way
        bnez    s4, _check_button_created   // skip if not on VS
        lli     t1, 0x0001                  // t1 = debug button press state (1 = enabled, 0 = disabled)
        beqz    s2, _check_button_created   // if the debug button object does not exist, skip
        lw      t0, 0x00A4(s1)              // t0 = 0 if panel all the way open
        sw      r0, 0x0050(s2)              // disable button presses
        beqzl   t0, _check_button_created   // if panel is open, ok to allow button presses
        sw      t1, 0x0050(s2)              // enable button presses

        _check_button_created:
        // check if debug button object is created
        bnez    s2, _set_display_state      // if debug button object exists, skip creating it
        nop                                 // otherwise we have to create it

        beql    t2, s5, pc() + 12           // if 1P/Bonus, then panel object is in different spot
        lw      t0, 0x003C(s1)              // t0 = panel object
        lw      t0, 0x0018(s1)              // t0 = panel object

        // create debug button object
        // 0x30(x) - reference to pagination renderer
        // 0x34(x) - reference to reset to defaults button
        // 0x40(x) - reference to panel struct
        // 0x44(x) - debug menu display state (0 = disabled, 1 = active)
        // 0x48(x) - debug menu previous display state (0 = disabled, 1 = active)
        // 0x4C(x) - flag for 1P/Bonus (0 = Not 1P/Bonus, 1 = 1P/Bonus)
        // 0x50(x) - flag for button press (0 = disabled, 1 = enabled)
        // 0x54(x) - panel index
        // 0x58(x) - dpad button index for render_control_object
        // 0x5C(x) - current page
        // 0x60(x) - reference to menu item 1
        // 0x64(x) - reference to menu item 2
        // 0x68(x) - reference to menu item 3
        // 0x6C(x) - reference to menu item 4
        // 0x70(x) - reference to menu renderer
        // 0x84(x) - max menu page, 0-based
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~
        sw      s5, 0x0018(sp)              // ~
        sw      t9, 0x001C(sp)              // ~
        // skip 0x0020 intentionally (used below)
        sw      t0, 0x0024(sp)              // ~

        li      a2, Render.file_pointer_2   // a2 = pointer to CSS images file start address
        lw      a2, 0x0000(a2)              // a2 = base file address
        addiu   a2, a2, 0x1208              // a2 = pointer to debug button footer
        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lui     at, 0x4080                  // at = left padding (4)
        mtc1    at, f2                      // f2 = left padding
        add.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, 0x4302                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F40                  // s5 = scale

        sw      v0, 0x0020(sp)              // save created object address

        li      t0, Toggles.entry_css_panel_menu
        lw      t0, 0x0004(t0)              // t0 = 0 if CSS panel menu disabled, 1 if enabled
        xori    t0, t0, 0x0001              // t0 = 1 if disabled (hide), 0 if enabled (show)
        sw      t0, 0x007C(v0)              // set display state of button

        // create reset to defaults button
        lw      t0, 0x0024(sp)              // t0 = panel object
        li      a2, Render.file_pointer_2   // a2 = pointer to CSS images file start address
        lw      a2, 0x0000(a2)              // a2 = base file address
        addiu   a2, a2, 0x1828              // a2 = pointer to reset to defaults button footer
        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lui     at, 0x41A0                  // at = left padding (20)
        mtc1    at, f2                      // f2 = left padding
        add.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, 0x4302                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F40                  // s5 = scale

        lw      at, 0x0020(sp)              // at = debug button object
        sw      v0, 0x0034(at)              // save reference to reset to defaults button
        lli     at, 0x0001                  // at = display off
        sw      at, 0x007C(v0)              // hide reset to defaults button by default

        Render.register_routine(render_menu_page_)
        lw      at, 0x0020(sp)              // at = debug button object
        sw      v0, 0x0070(at)              // save reference to menu renderer in debug button object
        sw      r0, 0x0030(v0)              // initialize
        sw      r0, 0x0034(v0)              // initialize
        sw      r0, 0x0038(v0)              // initialize
        sw      r0, 0x003C(v0)              // initialize
        sw      r0, 0x0040(v0)              // initialize
        sw      r0, 0x0044(v0)              // initialize
        sw      r0, 0x0048(v0)              // initialize
        sw      r0, 0x004C(v0)              // initialize
        sw      r0, 0x0050(v0)              // initialize
        sw      r0, 0x0054(v0)              // initialize
        sw      r0, 0x0058(v0)              // initialize
        sw      r0, 0x005C(v0)              // initialize
        sw      r0, 0x0060(v0)              // initialize
        sw      r0, 0x0064(v0)              // initialize
        sw      r0, 0x0068(v0)              // initialize
        sw      r0, 0x006C(v0)              // initialize
        sw      at, 0x0070(v0)              // save reference to debug button object in menu renderer

        Render.register_routine(render_pagination_)
        lw      at, 0x0020(sp)              // at = debug button object
        sw      v0, 0x0030(at)              // save reference to pagination renderer in debug button object
        sw      r0, 0x0030(v0)              // initialize page number string
        sw      r0, 0x0034(v0)              // initialize left arrow
        sw      r0, 0x0038(v0)              // initialize right arrow
        lw      a1, 0x0024(sp)              // a1 = panel object
        sw      a1, 0x003C(v0)              // save panel object reference
        sw      at, 0x0070(v0)              // save reference to debug button object in pagination renderer

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0014(sp)              // ~
        lw      s5, 0x0018(sp)              // ~
        lw      t9, 0x001C(sp)              // ~
        lw      v0, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        lw      a0, 0x0010(sp)              // a0 = debug control object
        sll     t0, t9, 0x0002              // t9 = offset to debug button object
        addu    a0, a0, t0                  // a0 = debug control object offset for debug button location
        sw      v0, 0x0030(a0)              // save reference to debug button object
        or      s2, v0, r0                  // s2 = debug button object
        sw      s1, 0x0040(v0)              // save reference to panel struct in debug button object
        sw      r0, 0x0044(v0)              // set debug menu display state to hidden
        sw      r0, 0x0048(v0)              // set debug menu previous display state to hidden
        sw      r0, 0x005C(v0)              // set current page to first page
        sw      r0, 0x0060(v0)              // clear reference to menu item 1
        sw      r0, 0x0064(v0)              // clear reference to menu item 2
        sw      r0, 0x0068(v0)              // clear reference to menu item 3
        sw      r0, 0x006C(v0)              // clear reference to menu item 4
        sltiu   t0, s5, 0x0002              // t0 = 1 for 1P/Bonus, 0 otherwise
        sw      t0, 0x004C(v0)              // set flag for 1P/Bonus
        lli     t2, 0x0001                  // t2 = 1 for button press enabled, 0 for disabled
        beqzl   s4, pc() + 8                // if on VS, initialize button as disabled
        lli     t2, 0x0000                  // t2 = 0 (disabled)
        sw      t2, 0x0050(v0)              // set flag for button press (0 = disabled, 1 = enabled)
        sw      t9, 0x0054(v0)              // save port index for training/vs
        lui     t2, 0x800A
        lbu     t2, 0x4AE3(t2)              // t2 = port index for 1p/bonus
        bnezl   t0, pc() + 8                // if 1p/bonus, save port index
        sw      t2, 0x0054(v0)              // save port index for 1p/bonus
        lli     t0, 0x0008                  // t0 = offset to CSS settings for Training
        bne     t0, s4, _set_display_state  // if not training, skip
        sw      t9, 0x0058(v0)              // save dpad button index for render_control_object
        // For Training, the CPU comes first in the css player struct if the human is not port 1
        sltiu   t2, t9, 0x0002              // t2 = 0 if port is > 2, which means we should save 0 as the index
        beqzl   t2, _set_display_state      // if port > 2, save 0 as the index since the human one is stored first in render_control_object
        sw      r0, 0x0058(v0)              // save dpad button index for render_control_object
        // if we're here, then we need to swap ports if the CPU is port 1
        lui     t0, 0x8014                  // t0 = port index of CPU
        lw      t0, 0x8898(t0)              // ~
        xori    t2, t9, 0x0001              // t2 = 1 if t9 is 0, 0 if t9 is 1
        beqzl   t0, _set_display_state      // if CPU is port 1, then swap the port index
        sw      t2, 0x0058(v0)              // save dpad button index for render_control_object

        _set_display_state:
        // s2 = debug button object
        jal     set_panel_display_          // set display state
        or      a0, r0, s2                  // a0 = debug button object

        _next:
        addiu   t9, t9, 0x0001              // t9++ (increment loop index)
        addu    s1, s1, s3                  // s1 = next css player struct
        lw      a0, 0x0010(sp)              // a0 = debug control object
        sll     t0, t9, 0x0002              // t9 = offset to debug button object
        addu    a0, a0, t0                  // a0 = debug control object offset for debug button location
        lw      s2, 0x0030(a0)              // s2 = next debug button object
        addiu   s0, s0, -0x0001             // s0--
        bnez    s0, _loop                   // if more panels, continue looping
        nop

        _end:
        li      t0, Render.display_order_room
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order with default

        OS.restore_registers()

        jr      ra
        nop
    }

    // @ Description
    // Sets display state of panel elements
    // @ Arguments
    // a0 - debug button object
    scope set_panel_display_: {
        lw      t0, 0x0040(a0)              // t0 = CSS panel struct
        lw      at, 0x0044(a0)              // at = display state (0 = hidden, 1 = active)
        lw      t2, 0x0048(a0)              // t2 = previous display state (0 = hidden, 1 = active)
        addiu   t3, at, -0x0001             // t3 = -1 if menu is hidden, 0 if not
        lw      t4, 0x004C(a0)              // t4 = 1 if 1P/Bonus, 0 otherwise

        bnez    t4, _1p_bonus               // if 1P/Bonus, will use different offsets
        nop

        lw      t1, 0x0014(t0)              // t1 = panel doors object, or 0
        beqz    t1, _check_if_state_changed // if no panel doors, skip
        lw      t1, 0x00A4(t0)              // t1 = panel door state (0 if completely open)

        // The panel door should always be open all the way when the debug menu is open, unless
        // the controller was just unplugged.

        beqz    t1, _check_if_state_changed // if the doors are open, skip
        nop
        beqz    at, _check_if_state_changed // if the menu is hidden, skip
        nop

        // If here, the doors aren't open but the debug menu is showing, which is bad... so fix!
        lli     at, 0x0000                  // at = display state = hidden
        sw      at, 0x0044(a0)              // update display state

        _check_if_state_changed:
        beq     t2, at, _run_every_frame    // skip the things that only need to change when toggling state
        sw      at, 0x0048(a0)              // update previous display state

        lw      t1, 0x000C(t0)              // t1 = HMN/CPU/NA button object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      at, 0x007C(t1)              // show/hide HMN/CPU/NA button

        lw      t1, 0x0008(t0)              // t1 = player object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide player

        xori    t1, at, 0x0001              // t1 = reset to defaults button display state
        lw      t5, 0x0034(a0)              // t5 = reset to defaults button object
        sw      t1, 0x007C(t5)              // hide/show reset to defaults button object

        _run_every_frame:
        // this one needs to be here instead of only once per toggle since controller unplugs can mess it up
        lw      t1, 0x0010(t0)              // t1 = name and series logo object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide name and series logo

        lw      t1, 0x001C(t0)              // t1 = Team button object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      at, 0x007C(t1)              // show/hide Team button
        lw      t1, 0x0030(t0)              // t1 = 1P/2P/3P/4P/CP texture object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      at, 0x007C(t1)              // show/hide 1P/2P/3P/4P/CP texture
        lw      t1, 0x0020(t0)              // t1 = handicap/cpu level texture object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      at, 0x007C(t1)              // show/hide handicap/cpu level texture
        lw      t1, 0x0028(t0)              // t1 = handicap/cpu level value texture object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      at, 0x007C(t1)              // show/hide handicap/cpu level value texture
        lw      t1, 0x0024(t0)              // t1 = flashing arrows object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide flashing arrows

        li      t1, CharacterSelect.render_control_object
        lw      t1, 0x0000(t1)              // t1 = render control object

        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb
        bnez    t0, _12cb                   // skip to 12cb if on 12cb CSS
        nop

        lw      t2, 0x0058(a0)              // t2 = dpad object index
        sll     t5, t2, 0x0004              // t2 = offset to stock icon and count indicators object
        sll     t2, t2, 0x0002              // t2 = offset to dpad object
        lw      t4, 0x0044(t1)              // t4 = stock icon and count indicators object
        beqz    t4, _dpad                   // if no stock icon and count indicators object, skip
        addu    t4, t4, t5                  // t4 = offset by panel
        lw      t0, 0x0030(t4)              // t0 = stock icon and count indicators object
        bnezl   t0, pc() + 8                // only run the next line if t0 is not 0
        sw      t3, 0x0038(t0)              // show/hide stock icon and count indicators

        _dpad:
        addu    t1, t1, t2                  // t1 = render control object offset by panel
        lw      t0, 0x0030(t1)              // t0 = dpad object
        beqz    t0, _end                    // skip if no dpad object
        nop
        sw      t3, 0x0038(t0)              // show/hide dpad texture
        lw      t1, 0x0034(t0)              // t1 = variant icons object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide variant icons
        lw      t1, 0x0040(t0)              // t1 = panel regional flag object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide panel regional flag texture
        lw      t1, 0x0030(t0)              // t1 = yellow square object
        beqz    t1, _end                    // only run the next lines if t1 is not 0
        nop
        sb      t3, 0x0043(t1)              // show/hide yellow square via alpha channel
        b       _end
        sw      at, 0x0044(t1)              // toggle alpha rendering

        _12cb:
        lw      t4, 0x0030(t1)              // t4 = variant indicators object
        lw      t2, 0x0054(a0)              // t2 = port index
        sll     t2, t2, 0x0002              // t2 = offset to variant indicators object
        addu    t4, t4, t2                  // t4 = offset by panel
        lw      t0, 0x0030(t4)              // t0 = variant indicators object
        bnezl   t0, pc() + 8                // only run the next line if t0 is not 0
        sw      t3, 0x0038(t0)              // show/hide variant indicators

        lw      t4, 0x0034(t1)              // t4 = stock icon and count indicators object
        sll     t5, t2, 0x0002              // t2 = offset to stock icon and count indicators object
        addu    t4, t4, t5                  // t4 = offset by panel
        lw      t0, 0x0030(t4)              // t0 = stock icon and count indicators object
        bnezl   t0, pc() + 8                // only run the next line if t0 is not 0
        sw      t3, 0x0038(t0)              // show/hide stock icon and count indicators
        lw      t0, 0x003C(t4)              // t0 = left rectangle object, if it exists
        beqz    t0, _custom_portrait_indicators // if 0, then no rectangles so skip
        xori    t5, at, 0x0001              // t5 = width = 1 if menu hidden, 0 if active
        sw      t5, 0x0038(t0)              // save width
        lw      t0, 0x006C(t0)              // t0 = right rectangle object
        sw      t5, 0x0038(t0)              // save width

        _custom_portrait_indicators:
        lw      t4, 0x0038(t1)              // t4 = custom portrait indicators object
        addu    t4, t4, t2                  // t1 = render control object offset by panel
        lw      t0, 0x0030(t4)              // t0 = custom portrait indicators object
        beqz    t0, _end                    // only run the next lines if t0 is not 0
        nop
        sw      t3, 0x0038(t0)              // show/hide custom portrait indicators

        b       _end
        nop

        _1p_bonus:
        beq     t2, at, _run_every_frame_1p // skip the things that only need to change when toggling state
        sw      at, 0x0048(a0)              // update previous display state

        lw      t1, 0x0030(t0)              // t1 = player object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide player
        lw      t1, 0x0034(t0)              // t1 = name and series logo object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide name and series logo

        xori    t1, at, 0x0001              // t1 = reset to defaults button display state
        lw      t5, 0x0034(a0)              // t5 = reset to defaults button object
        sw      t1, 0x007C(t5)              // hide/show reset to defaults button object

        _run_every_frame_1p:
        lw      t1, 0x003C(t0)              // t1 = panel object
        lw      t1, 0x0074(t1)              // t1 = panel object image struct
        lw      t1, 0x0008(t1)              // t1 = 1P/2P/3P/4P/CP texture object
        lw      t4, 0x0044(t1)              // t4 = pointer to image footer
        lh      t4, 0x0014(t4)              // t4 = width
        bnezl   at, pc() + 8                // if menu is active, then set width to 0
        lli     t4, 0x0000                  // t4 = 0 (0 width will effectively hide it)
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sh      t4, 0x0014(t1)              // show/hide 1P/2P/3P/4P/CP texture

        li      t1, CharacterSelect.render_control_object
        lw      t1, 0x0000(t1)              // t1 = render control object
        lw      t2, 0x0058(a0)              // t2 = dpad object index
        sll     t2, t2, 0x0002              // t2 = offset to dpad object
        addu    t1, t1, t2                  // t1 = render control object offset by panel
        lw      t0, 0x0030(t1)              // t0 = dpad object
        beqz    t0, _end                    // skip if no dpad object
        nop
        sw      t3, 0x0038(t0)              // show/hide dpad texture
        lw      t1, 0x0034(t0)              // t1 = variant icons object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide variant icons
        lw      t1, 0x0040(t0)              // t1 = panel regional flag object
        bnezl   t1, pc() + 8                // only run the next line if t1 is not 0
        sw      t3, 0x0038(t1)              // show/hide panel regional flag texture
        lw      t1, 0x0030(t0)              // t1 = yellow square object
        beqz    t1, _end                    // only run the next lines if t1 is not 0
        nop
        sb      t3, 0x0043(t1)              // show/hide yellow square via alpha channel
        sw      at, 0x0044(t1)              // toggle alpha rendering

        _end:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     setup_menu_page_
        nop

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr        ra
        nop
    }

    // @ Description
    // Manages menu items on a menu page.
    // @ Arguments
    // a0 - debug button object
    scope setup_menu_page_: {
        // The menu renderer pointer is stored at 0x70 in the debug button object.
        // Menu item pointers will be stored at 0x60, 0x64, 0x68 and 0x6C in the debug button object.
        // If the debug menu is active, then these pointers will be loaded for the current page.
        // If the debug menu is disabled, then these pointers will be removed.
        // When pagination occurs, these pointers will be updated.
        // Only 0x60, 0x64 and 0x68 are rendered - 0x6C's purpose is to know if there is a next page.

        // Check if active
        lw      at, 0x0044(a0)              // at = display state (0 = hidden, 1 = active)
        beqz    at, _clear                  // if hidden, skip to clearing the pointers
        nop

        lw      at, 0x0060(a0)              // at = first menu pointer
        bnez    at, _end                    // skip if menu pointer is already populated
        nop
        li      t0, debug_control_object
        lw      t0, 0x0000(t0)              // t0 = debug control object
        lw      at, 0x0048(t0)              // at = menu arrays
        lw      t1, 0x004C(a0)              // t1 = 1 if 1P/Bonus, 0 if not
        bnezl   t1, _get_max_pages          // if 1P/Bonus, then always use human array
        lw      at, 0x0000(at)              // at = human menu array

        lw      t1, 0x0040(a0)              // t1 = CSS panel struct
        lw      t0, 0x0044(t0)              // t0 = offset to CSS settings: 0 if VS
        beqzl   t0, _check_cpu              // if VS, use VS offset, otherwise use training offset
        lw      t0, 0x0084(t1)              // t0 = type: 0 if HMN, 1 if CPU, 2 if NA
        lw      t0, 0x0080(t1)              // t0 = type: 0 if HMN, 1 if CPU, 2 if NA
        _check_cpu:
        bnezl   t0, _get_max_pages          // if CPU, use CPU array
        lw      at, 0x0004(at)              // at = cpu menu array
        // otherwise use human array
        lw      at, 0x0000(at)              // at = human menu array

        _get_max_pages:
        lw      t0, -0x0004(at)             // t0 = number of menu items
        beqz    t0, _get_current_page       // if no menu items, use 0 as number of pages
        lli     t1, 0x0003                  // t1 = 3 (number of menu items per page)
        divu    t0, t1                      // t0 = max page
        mflo    t0                          // ~
        mfhi    t1                          // t1 = 0 if menu items divisible by 3
        beqzl   t1, _get_current_page       // if perfectly divisible, then adjust by 1 page
        addiu   t0, t0, -0x0001             // t0 = max page

        _get_current_page:
        sw      t0, 0x0084(a0)              // save max pages
        lw      t1, 0x005C(a0)              // t1 = current page
        sltu    t0, t0, t1                  // t0 = 1 if current page > max pages
        beqz    t0, _get_menu_items         // if current page <= max pages, skip
        lw      t0, 0x0084(a0)              // t0 = max pages
        sw      t0, 0x005C(a0)              // save max pages as current page
        or      t1, t0, r0                  // t1 = current page, updated

        _get_menu_items:
        lli     t0, 12                      // t0 = 12 (size of 3 pointers)
        multu   t0, t1                      // t1 = offset to first menu item pointer for page
        mflo    t1                          // ~
        addu    at, at, t1                  // at = address of first menu item pointer for page
        lw      t0, 0x0000(at)              // t0 = first menu item address
        beqz    t0, _clear                  // if there is no first item, then assure rest of page is cleared
        nop

        sw      t0, 0x0060(a0)              // save first menu item address
        lw      t0, 0x0004(at)              // t0 = second menu item address
        beqz    t0, _clear + 4              // if no second item, clear the rest
        sw      t0, 0x0064(a0)              // save second menu item address
        lw      t0, 0x0008(at)              // t0 = third menu item address
        beqz    t0, _clear + 8              // if no third item, clear the rest
        sw      t0, 0x0068(a0)              // save third menu item address
        lw      t0, 0x000C(at)              // t0 = fourth menu item address
        sw      t0, 0x006C(a0)              // save fourth menu item address

        b       _end                        // skip to end
        nop

        _clear:
        sw      r0, 0x0060(a0)              // clear pointer for menu item 1
        sw      r0, 0x0064(a0)              // clear pointer for menu item 2
        sw      r0, 0x0068(a0)              // clear pointer for menu item 3
        sw      r0, 0x006C(a0)              // clear pointer for menu item 4

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Renders a menu page.
    // @ Arguments
    // a0 - menu renderer object
    scope render_menu_page_: {
        // 0x0030(a0) - label item 1
        // 0x0034(a0) - label item 2
        // 0x0038(a0) - label item 3
        // 0x003C(a0) - label item 4
        // 0x0040(a0) - value item 1
        // 0x0044(a0) - value item 2
        // 0x0048(a0) - value item 3
        // 0x004C(a0) - value item 4
        // 0x0050(a0) - left arrow item 1
        // 0x0054(a0) - left arrow item 2
        // 0x0058(a0) - left arrow item 3
        // 0x005C(a0) - left arrow item 4
        // 0x0060(a0) - right arrow item 1
        // 0x0064(a0) - right arrow item 2
        // 0x0068(a0) - right arrow item 3
        // 0x006C(a0) - right arrow item 4
        // 0x0070(a0) - debug button object

        lw      a1, 0x0070(a0)              // a1 = debug button object

        lli     t0, 0x0000                  // t0 = row
        lw      t2, 0x0040(a1)              // t2 = address of CSS player struct

        lw      t1, 0x0004(t2)              // t1 = token object
        lw      at, 0x0018(t2)              // at = panel object

        lw      t3, 0x004C(a1)              // t3 = 1 if 1P/Bonus, 0 if not
        beqz    t3, pc() + 16               // if not 1P/Bonus, skip
        nop                                 // ...otherwise panel object and token object are in different spot
        lw      t1, 0x002C(t2)              // t1 = token object
        lw      at, 0x003C(t2)              // at = panel object

        lw      t1, 0x0084(t1)              // t1 = port index

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      at, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // intentionally store twice
        sw      t1, 0x0020(sp)              // ~

        _loop:
        // first, check menu item
        lw      a2, 0x0060(a1)              // a2 = menu item address
        beqz    a2, _inactive               // if no menu item, do any clean up necessary
        lw      t1, 0x0030(a0)              // t1 = label object

        bnez    t1, _next                   // if label object exists, skip creating
        nop                                 // otherwise, create the label

        lw      a1, 0x0014(sp)              // a1 = panel object
        lli     at, 24                      // at = row height
        multu   t0, at                      // at = variable top padding based on row
        mflo    at                          // ~
        mtc1    at, f0                      // f0 = variable top padding based on row
        cvt.s.w f0, f0                      // f0 = variable top padding based on row, floating point
        jal     create_item_label_
        mfc1    a3, f0                      // a3 = variable top padding based on row

        jal     create_item_value_
        lw      at, 0x0020(sp)              // at = port index

        jal     create_item_arrows_
        nop

        b       _next
        nop

        _active:
        lli     t2, 12                      // t2 = 12 (show everything from 0x30 through 0x5C)
        addiu   t3, a0, 0x0030              // t3 = first object pointer address
        lli     t5, 0x0000                  // t5 = 0 (render off)
        lli     t6, 0x0001                  // t6 = 1 (display off)

        _inactive:
        beqz    t1, _next                   // if no label object exists, then skip hiding
        lli     t2, 3                       // t2 = 3 (3 objects to destroy)
        addiu   t3, a0, 0x0030              // t3 = first object pointer address
        lli     t5, 0x0000                  // t5 = 0 (render off)
        lli     t6, 0x0001                  // t6 = 1 (display off)

        _update_loop:
        beqz    t1, _update_next            // if no object, skip
        //nop
        sw      r0, 0x0000(t3)              // clear the pointer to the object we are about to destroy

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // save registers
        sw      t2, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)              // ~

        jal     Render.DESTROY_OBJECT_
        or      a0, r0, t1                  // a0 = object to destroy

        lw      t1, 0x0004(sp)              // restore registers
        lw      t2, 0x0008(sp)              // ~
        lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        b _update_next
        nop

        sw      t5, 0x0038(t1)              // turn rendering on/off for object
        sltiu   t4, t2, 8                   // t4 = 0 if arrow object
        beqzl   t4, pc() + 8                // if arrow object, turn display on/off (this enables/disables pressing)
        sw      t6, 0x007C(t1)              // turn display off

        _update_next:
        addiu   t2, t2, -0x0001             // t2--
        addiu   t3, t3, 0x0010              // t3 = next object pointer address
        bnezl   t2, _update_loop
        lw      t1, 0x0000(t3)              // t1 = next object

        _next:
        lw      a0, 0x0018(sp)              // a0 = debug button object, offset for current menu item
        lw      a1, 0x001C(sp)              // a1 = menu renderer object, offset for current menu item
        addiu   a0, a0, 0x0004              // a0 = menu renderer object, offset for next menu item
        addiu   a1, a1, 0x0004              // a1 = debug button object, offset for next menu item
        sw      a0, 0x0018(sp)              // update debug button object, offset for current menu item
        sw      a1, 0x001C(sp)              // update menu renderer object, offset for current menu item
        lw      t0, 0x0010(sp)              // t0 = row
        sltiu   t1, t0, 0x0002              // t1 = 0 if we've run the loop 3 times
        addiu   t0, t0, 0x0001              // t0 = ++row
        bnez    t1, _loop                   // keep looping if necessary
        sw      t0, 0x0010(sp)              // save row

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Creates the item's label string object.
    // @ Arguments
    // a0 - menu renderer object address, offset by 0x4 based on menu item row
    // a1 - panel object
    // a2 - menu item
    // a3 - top padding
    scope create_item_label_: {
        OS.save_registers()
        // 0x0010(sp) - menu renderer object, offset by 0x4 based on menu item row
        // 0x0014(sp) - panel object
        // 0x0018(sp) - menu item
        // 0x001C(sp) - top padding

        or      t0, r0, a1                  // t0 = panel object

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      a2, 0x0000(a2)              // a2 = string
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lui     at, 0x4080                  // at = left padding (4)
        mtc1    at, f2                      // f2 = left padding
        add.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x4190                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mtc1    a3, f2                      // f2 = variable top padding based on row
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        li      s3, 0xD0D0D0FF              // s3 = color
        li      s4, 0x3F600000              // s4 = scale
        lli     s5, Render.alignment.LEFT   // s5 = alignment
        lli     s6, Render.string_type.TEXT // s6 = string type
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        jal     Render.draw_string_
        lli     t8, 0x0001                  // t8 = blur (on)

        lw      t0, 0x0014(sp)              // t0 = panel object
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lh      at, 0x0014(t1)              // at = panel width
        addiu   a1, at, -0x0008             // a1 = max width
        jal     Render.apply_max_width_
        or      a0, v0, r0                  // a0 = string object

        lw      a0, 0x0010(sp)              // a0 = menu renderer object, offset by 0x4 based on menu item row
        sw      v0, 0x0030(a0)              // save reference to label object

        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Creates the item's value object.
    // @ Arguments
    // a0 - menu renderer object address, offset by 0x4 based on menu item row
    // a1 - panel object
    // a2 - menu item
    // a3 - top padding
    // at - port index
    scope create_item_value_: {
        OS.save_registers()
        // 0x0010(sp) - menu renderer object, offset by 0x4 based on menu item row
        // 0x0014(sp) - panel object
        // 0x0018(sp) - menu item
        // 0x001C(sp) - top padding
        // 0x0004(sp) - port index

        or      t0, r0, a1                  // t0 = panel object

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lh      at, 0x0014(t1)              // at = panel width
        mtc1    at, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        lui     at, 0x3F00                  // at = .5, floating point
        mtc1    at, f4                      // f4 = 2
        mul.s   f2, f2, f4                  // f2 = padding
        add.s   f0, f0, f2                  // f0 = ucx
        mfc1    s1, f0                      // s1 = ucx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x41F0                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mtc1    a3, f2                      // f2 = variable top padding based on row
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        addiu   s3, r0, -0x0001             // s3 = color (white)
        li      s4, 0x3F600000              // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = alignment
        li      a3, Render.update_live_string_ // a3 = routine
        lli     t8, 0x0001                  // t8 = blur (on)

        lw      t1, 0x0004(sp)              // t1 = port index
        lhu     s6, 0x0004(a2)              // s6 = value type
        lli     at, value_type.NUMERIC
        bne     at, s6, _text               // if not numeric, jump to text
        sll     t1, t1, 0x0002              // t1 = port index * 4
        lw      a2, 0x001C(a2)              // a2 = value array address
        addu    a2, a2, t1                  // a2 = address of value for port
        jal     Render.draw_string_
        lli     s7, 0x0000                  // s7 = adjustment (none)

        b       _end
        nop

        _text:
        lw      at, 0x001C(a2)              // at = value array address
        addu    t1, at, t1                  // t1 = value address for port
        lw      at, 0x0000(t1)              // at = index in string table
        sll     at, at, 0x0002              // at = offset in string table
        lw      a2, 0x0014(a2)              // a2 = string table
        addu    a2, a2, at                  // a2 = pointer to string
        jal     Render.draw_string_
        lw      a2, 0x0000(a2)              // a2 = string

        _end:
        lw      t0, 0x0014(sp)              // t0 = panel object
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lh      at, 0x0014(t1)              // at = panel width
        addiu   a1, at, -0x0018             // a1 = max width
        jal     Render.apply_max_width_
        or      a0, v0, r0                  // a0 = string object

        lw      a0, 0x0010(sp)              // a0 = menu renderer object, offset by 0x4 based on menu item row
        sw      v0, 0x0040(a0)              // save reference to value object
        addiu   t1, a0, 0x0040              // t1 = address of reference to value object
        sw      t1, 0x0054(v0)              // save address of reference to value object in value object (so update_live_string_ works)

        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Creates the item's left and right arrow objects.
    // @ Arguments
    // a0 - menu renderer object address, offset by 0x4 based on menu item row
    // a1 - panel object
    // a2 - menu item
    // a3 - top padding
    // at - port index
    // 0x000C(sp) - debug button object
    scope create_item_arrows_: {
        OS.save_registers()
        // 0x0010(sp) - menu renderer object, offset by 0x4 based on menu item row
        // 0x0014(sp) - panel object
        // 0x0018(sp) - menu item
        // 0x001C(sp) - top padding
        // 0x0004(sp) - port index
        // 0x007C(sp) - debug button object

        // we want to ensure blinking arrows are always drawn on top, even after recreated via update_live_string_
        li      t0, Render.display_order_room
        lui     t1, 0x4000                  // t1 = 0x40000000 (render after 0x80000000)
        sw      t1, 0x0000(t0)              // update display order for room for draw_texture_

        // first, draw left arrow (I could make this a loop but I'm too lazy)

        or      t0, r0, a1                  // t0 = panel object

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lui     at, 0x4000                  // at = left padding (2)
        mtc1    at, f2                      // f2 = left padding
        add.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x4200                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mtc1    a3, f2                      // f2 = variable top padding based on row
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        li      s3, 0xFF0000FF              // s3 = color
        li      s4, 0x303030FF              // s4 = pallette
        lui     s5, 0x3F20                  // s5 = scale
        // file 0x11 is always the first file loaded
        li      a2, file_table              // a2 = file_table
        lw      a2, 0x0004(a2)              // a2 = base file 0x11 address
        lli     a3, 0xECE8                  // a3 = offset to left arrow
        addu    a2, a2, a3                  // a2 = address of left arrow image footer
        li      a3, arrow_state_routine_    // a3 = routine
        jal     Render.draw_texture_
        nop

        lw      a0, 0x0010(sp)              // a0 = menu renderer object, offset by 0x4 based on menu item row
        sw      v0, 0x0050(a0)              // save reference to left arrow object
        lw      t1, 0x0004(sp)              // t1 = port index
        sw      t1, 0x0040(v0)              // save port index in arrow object
        lw      t1, 0x0018(sp)              // t1 = menu item
        sw      t1, 0x0044(v0)              // save menu item in arrow object
        lw      t1, 0x007C(sp)              // t1 = debug button object
        lw      t1, 0x0030(t1)              // t1 = page renderer object
        lw      t1, 0x0034(t1)              // t1 = left page arrow object
        beqzl   t1, _right                  // if no page arrow object, initialize blink timer to 0
        sw      r0, 0x004C(v0)              // initialize blink timer
        lw      t1, 0x004C(t1)              // t1 = current blink timer value
        sw      t1, 0x004C(v0)              // initialize blink timer

        _right:
        // now draw right arrow
        or      a0, r0, v0                  // a0 = left arrow object
        // file 0x11 is always the first file loaded
        li      a1, file_table              // a1 = file_table
        lw      a1, 0x0004(a1)              // a1 = base file 0x11 address
        lli     t0, 0xEDC8                  // t0 = offset to right arrow
        addu    a1, a1, t0                  // a1 = address of right arrow image footer
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      t0, 0x0014(sp)              // a1 = panel object
        lw      a3, 0x001C(sp)              // a3 = top padding
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lh      at, 0x0014(t1)              // at = panel width
        mtc1    at, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx of panel
        lui     at, 0x40A0                  // at = right padding (5)
        mtc1    at, f2                      // f2 = right padding
        sub.s   f0, f0, f2                  // f0 = ulx
        mfc1    t0, f0                      // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x4200                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mtc1    a3, f2                      // f2 = variable top padding based on row
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    t0, f0                      // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lui     t0, 0x3F20                  // t0 = scale
        sw      t0, 0x0018(v0)              // save x scale
        sw      t0, 0x001C(v0)              // save y scale
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        li      t0, Render.display_order_room
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order with default

        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Gives the arrows blinking effects as well as controls when visible.
    // @ Arguments
    // a0 - arrow object
    scope arrow_state_routine_: {
        // 0x0040(a0) - port index
        // 0x0044(a0) - menu item
        // 0x0048(a0) - direction (+1 for right, -1 for left)
        // 0x004C(a0) - blink timer

        // implement blink
        lw      t0, 0x004C(a0)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   t2, t0, 0x000B              // t2 = 1 if timer < 60, 0 otherwise
        sltiu   at, t0, 0x0014              // at = 1 if timer < 90, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 90, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x004C(a0)              // update timer

        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0205                  // t1 = render flags (hide)

        lw      t0, 0x0074(a0)              // t0 = left arrow image struct
        sh      t1, 0x0024(t0)              // update render flags
        lw      t0, 0x0008(t0)              // t0 = right arrow image struct
        sh      t1, 0x0024(t0)              // update render flags

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Renders page number and arrows to control page.
    // @ Arguments
    // a0 - pagination renderer object
    scope render_pagination_: {
        // 0x0030(a0) - number string
        // 0x0034(a0) - left arrow
        // 0x0038(a0) - right arrow
        // 0x003C(a0) - panel object
        // 0x0070(a0) - debug button object

        lw      a1, 0x0070(a0)              // a1 = debug button object
        lw      at, 0x0044(a1)              // at = debug menu display state (0 = disabled, 1 = active)
        lw      t0, 0x0034(a0)              // t0 = left arrow object, if it exists

        beqz    at, _update_display         // if debug menu disabled, hide objects
        lli     t1, 0x0001                  // t1 = 1 (display off)

        lw      t2, 0x0030(a0)              // t2 = page number object, if it exists
        bnez    t2, _update_display         // if already page number object, skip creating objects
        lli     t1, 0x0000                  // t1 = 0 (display on)

        OS.save_registers()
        // 0x0010(sp) - pagination renderer object

        // Create number string
        lw      t0, 0x003C(a0)              // t0 = panel object
        addiu   a2, a1, 0x005C              // a2 = location of current page

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lh      at, 0x0014(t1)              // at = panel width
        mtc1    at, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx of panel
        lui     at, 0x4128                  // at = right padding (10.5)
        mtc1    at, f2                      // f2 = right padding
        sub.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x4080                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        addiu   s3, r0, -0x0001             // s3 = color (white)
        li      s4, 0x3F600000              // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = alignment
        lli     s6, Render.string_type.NUMBER // s6 = type
        li      a3, Render.update_live_string_ // a3 = routine
        lli     t8, 0x0001                  // t8 = blur (on)
        jal     Render.draw_string_
        lli     s7, 0x0001                  // s7 = adjustment (make 1-based, not 0-based)

        lw      a0, 0x0010(sp)              // a0 = pagination renderer
        sw      v0, 0x0030(a0)              // save reference to page number string object
        addiu   t8, a0, 0x0030              // t8 = address of object reference
        sw      t8, 0x0054(v0)              // save address storing object reference

        lw      a1, 0x0070(a0)              // a1 = debug button object
        lw      t8, 0x0084(a1)              // t8 = number of pages
        beqzl   t8, _finish_create          // if only 1 page, skip creating pagination buttons
        sw      r0, 0x0038(v0)              // and disable display of page number

        // next, draw left arrow (I could make this a loop but I'm too lazy)
        lw      t0, 0x003C(a0)              // t0 = panel object

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lh      at, 0x0014(t1)              // at = panel width
        mtc1    at, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx of panel
        lui     at, 0x41A0                  // at = right padding (20)
        mtc1    at, f2                      // f2 = right padding
        sub.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x40C0                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        li      s3, 0xFF0000FF              // s3 = color
        li      s4, 0x303030FF              // s4 = pallette
        lui     s5, 0x3F20                  // s5 = scale
        // file 0x11 is always the first file loaded
        li      a2, file_table              // a2 = file_table
        lw      a2, 0x0004(a2)              // a2 = base file 0x11 address
        lli     a3, 0xECE8                  // a3 = offset to left arrow
        addu    a2, a2, a3                  // a2 = address of left arrow image footer
        li      a3, page_arrow_routine_     // a3 = routine
        jal     Render.draw_texture_
        nop

        lw      a0, 0x0010(sp)              // a0 = pagination renderer
        sw      v0, 0x0034(a0)              // save reference to left arrow object
        lw      t1, 0x0070(a0)              // t1 = debug button object
        sw      t1, 0x0040(v0)              // save reference to debug button object in arrow object
        addiu   t1, r0, -0x0001             // t1 = -1 for left
        sw      t1, 0x0048(v0)              // save -1 in arrow object
        sw      r0, 0x004C(v0)              // initialize blink timer

        // now draw right arrow
        lw      t0, 0x003C(a0)              // t0 = panel object

        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lw      t1, 0x0074(t0)              // t1 = panel image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx of panel
        lh      at, 0x0014(t1)              // at = panel width
        mtc1    at, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx of panel
        lui     at, 0x40A0                  // at = right padding (5)
        mtc1    at, f2                      // f2 = right padding
        sub.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x005C(t1)              // f0 = uly of panel
        lui     at, 0x40C0                  // at = top padding
        mtc1    at, f2                      // f2 = top padding
        add.s   f0, f0, f2                  // f0 = uly
        mfc1    s2, f0                      // s2 = uly
        li      s3, 0xFF0000FF              // s3 = color
        li      s4, 0x303030FF              // s4 = pallette
        lui     s5, 0x3F20                  // s5 = scale
        // file 0x11 is always the first file loaded
        li      a2, file_table              // a2 = file_table
        lw      a2, 0x0004(a2)              // a2 = base file 0x11 address
        lli     a3, 0xEDC8                  // a3 = offset to right arrow
        addu    a2, a2, a3                  // a2 = address of right arrow image footer
        li      a3, page_arrow_routine_     // a3 = routine
        jal     Render.draw_texture_
        nop

        lw      a0, 0x0010(sp)              // a0 = pagination renderer
        sw      v0, 0x0038(a0)              // save reference to right arrow object
        lw      t1, 0x0070(a0)              // t1 = debug button object
        sw      t1, 0x0040(v0)              // save reference to debug button object in arrow object
        addiu   t1, r0, 0x0001              // t1 = +1 for right
        sw      t1, 0x0048(v0)              // save +1 in arrow object
        sw      r0, 0x004C(v0)              // initialize blink timer

        _finish_create:
        OS.restore_registers()
        b       _end
        nop

        _update_display:
        // t0 = left arrow object
        // t1 = display on/off
        beqz    t0, _end                    // skip showing/hiding if it doesn't exist
        nop

        lw      t2, 0x007C(t0)              // t2 = current display state (0 = on, 1 = off)
        beq     t2, t1, _end                // if current matches new display state, skip setting
        nop

        sw      t1, 0x007C(t0)              // update display state for left arrow
        lw      t0, 0x0030(a0)              // t0 = page number string
        sw      t1, 0x007C(t0)              // update display state for page number string
        lw      t0, 0x0038(a0)              // t0 = right arrow
        sw      t1, 0x007C(t0)              // update display state for right arrow

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Gives the arrows blinking effects.
    // @ Arguments
    // a0 - arrow object
    scope page_arrow_routine_: {
        // 0x0040(a0) - debug button object
        // 0x0048(a0) - direction (+1 for right, -1 for left)
        // 0x004C(a0) - blink timer

        // implement blink
        lw      t0, 0x004C(a0)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   t2, t0, 0x000B              // t2 = 1 if timer < 60, 0 otherwise
        sltiu   at, t0, 0x0014              // at = 1 if timer < 90, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 90, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x004C(a0)              // update timer

        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0205                  // t1 = render flags (hide)

        lw      t0, 0x0074(a0)              // t0 = arrow image struct
        sh      t1, 0x0024(t0)              // update render flags

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Catches when A is pressed if all other built-in A checks fail
    scope press_a_handler_: {
        // VS
        OS.patch_start(0x136768, 0x801384E8)
        jal     press_a_handler_._vs
        lw      t5, 0x0024(sp)              // original line 2 (can't change - branched to)
        OS.patch_end()
        // Training
        OS.patch_start(0x144FA8, 0x801359C8)
        jal     press_a_handler_._training
        sw      s0, 0x0028(sp)              // save port index to unused stack to match VS
        OS.patch_end()
        // 1P
        OS.patch_start(0x13F07C, 0x80136E7C)
        jal     press_a_handler_._1p
        nop
        OS.patch_end()
        // Bonus
        OS.patch_start(0x14BA1C, 0x801359EC)
        jal     press_a_handler_._bonus
        nop
        OS.patch_end()

        _1p:
        sw      ra, 0x0028(sp)              // save ra
        jal     0x80136A84                  // original line 1
        lw      a0, 0x0038(sp)              // original line 2
        lw      ra, 0x0028(sp)              // restore ra

        // a0 - cursor object
        lw      a0, 0x0038(sp)              // cursor object
        // port index is always 0, so save 0 to unused stack to match VS
        sw      r0, 0x0028(sp)              // save port index
        // now we can carry on like other screens
        b       _common
        nop

        _bonus_return:
        jr      ra
        nop

        _bonus:
        // if v0 is 1, then we need to return, otherwise we need to adjust ra
        bnez    v0, _bonus_return           // if v0 is 1, return
        nop
        jal     Bonus.handle_arrow_press_
        lw      a0, 0x0040(sp)              // a0 = cursor object

        li      ra, 0x80135A04              // adjust ra so we return after the last button check code
        lw      t1, 0x0024(sp)              // original line 2
        // port index is always 0, so save 0 to unused stack to match VS
        sw      r0, 0x0028(sp)              // save port index
        // now we can carry on like other screens
        b       _common
        lw      a0, 0x0040(sp)              // a0 = cursor object

        _training_return:
        jr      ra
        nop

        _training:
        // if v0 is 1, then we need to return, otherwise we need to adjust ra
        bnez    v0, _training_return        // if v0 is 1, return
        nop
        li      ra, 0x801359E4              // adjust ra so we return after the last button check code
        sll     t1, s0, 0x0002              // original line 2
        // now we can carry on like other screens
        b       _common
        lw      a0, 0x0040(sp)              // a0 = cursor object

        _vs:
        // 0x0040(sp) - cursor object
        // 0x0028(sp) - panel index

        lw      a0, 0x0040(sp)              // a0 = cursor object

        // Rather than sprinkle in new hooks, let's check for stock mode's indicator arrows here

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t5, 0x000C(sp)              // ~

        // a0 will be preserved
        li      a1, press_a_handler_._end   // a1 = ra if there is a press, past other custom button handler checks
        jal     CharacterSelect.check_manual_stock_arrow_press_
        nop

        lw      t5, 0x000C(sp)              // ~
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        _common:
        li      t0, debug_control_object
        lw      t0, 0x0000(t0)              // t0 = debug control object

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t5, 0x000C(sp)              // ~
        sw      t1, 0x0010(sp)              // ~

        // a0 is preserved for all the following routines

        li      a1, hold_a_handler_._ra     // a1 = ra for hold routine
        beq     ra, a1, _arrow_checks       // if holding, only do arrow checks
        nop

        jal     handle_debug_button_press_
        lw      a1, 0x0030(t0)              // a1 = debug button object (1)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_debug_button_press_
        lw      a1, 0x0034(t0)              // a1 = debug button object (2)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_debug_button_press_
        lw      a1, 0x0038(t0)              // a1 = debug button object (3)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_debug_button_press_
        lw      a1, 0x003C(t0)              // a1 = debug button object (4)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_reset_button_press_
        lw      a1, 0x0030(t0)              // a1 = debug button object (1)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_reset_button_press_
        lw      a1, 0x0034(t0)              // a1 = debug button object (2)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_reset_button_press_
        lw      a1, 0x0038(t0)              // a1 = debug button object (3)

        lw      t0, 0x0008(sp)              // t0 = debug control object
        jal     handle_reset_button_press_
        lw      a1, 0x003C(t0)              // a1 = debug button object (4)

        _arrow_checks:
        jal     handle_item_arrow_press_
        lw      a1, 0x0008(sp)              // a1 = debug control object

        jal     handle_page_arrow_press_
        lw      a1, 0x0008(sp)              // a1 = debug control object

        _end:
        lw      t1, 0x0010(sp)              // ~
        lw      t5, 0x000C(sp)              // ~
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        lw      a1, 0x0028(sp)              // original line 1
    }

    // @ Description
    // Checks if A is being held
    scope hold_a_handler_: {
        constant BUFFER(15)      // frames to wait until holding enabled
        constant FASTBUFFER(90)  // frames to wait until no timer is used
        constant TIMER(6)        // frames to wait between applying press handler
        constant FGM_BUFFER(3)   // frames to wait between playing sfx for pressing

        // VS
        OS.patch_start(0x136598, 0x80138318)
        jal     hold_a_handler_._vs
        lhu     t9, 0x0000(t8)              // t9 = held button mask
        OS.patch_end()
        // Training
        OS.patch_start(0x00144F58, 0x80135978)
        jal     hold_a_handler_._training
        andi    t9, t8, 0x8000              // original line 2
        OS.patch_end()
        // 1P
        OS.patch_start(0x13EF8C, 0x80136D8C)
        jal     hold_a_handler_._1p
        lhu     t9, 0x0000(t8)              // t9 = held button mask
        lw      a0, 0x0038(sp)              // original line 3
        lui     a2, 0x8014                  // original line 4
        lw      a1, 0x0020(sp)              // restore a1
        OS.patch_end()
        // Bonus
        OS.patch_start(0x0014B9B8, 0x80135988)
        jal     hold_a_handler_._bonus
        lhu     t9, 0x0000(t8)              // t9 = held button mask
        lw      a0, 0x0040(sp)              // original line 2
        or      a1, s0, r0                  // original line 3
        OS.patch_end()

        _training:
        lw      t8, 0x0020(sp)              // t8 = controller input array (saved in CharacterSelect.check_variant_input_)
        li      t0, press_a_handler_._common
        sw      t0, 0x0010(sp)              // save routine start to unused stack space
        sw      s0, 0x0028(sp)              // save port index

        b       _common
        lhu     t9, 0x0000(t8)              // t9 = held button state

        _1p:
        sw      r0, 0x0028(sp)              // save port index
        li      t0, press_a_handler_._1p
        sw      t0, 0x0010(sp)              // save routine start to unused stack space

        b       _common
        nop

        _bonus:
        sw      r0, 0x0028(sp)              // save port index
        li      t0, press_a_handler_._common
        sw      t0, 0x0010(sp)              // save routine start to unused stack space

        b       _common
        lw      a0, 0x0040(sp)              // a0 = cursor object

        _vs:
        li      t0, press_a_handler_._vs
        sw      t0, 0x0010(sp)              // save routine start to unused stack space

        _common:
        li      t0, fgm_buffer              // t0 = fgm buffer address
        lw      t1, 0x0000(t0)              // t1 = fgm buffer
        addiu   t1, t1, -0x0001             // t1--
        bgezl   t1, pc() + 8                // if t1 >= 0, update buffer
        sw      t1, 0x0000(t0)              // update buffer

        lw      a1, 0x0028(sp)              // a1 = port
        li      t1, held_buffer             // t1 = held buffer table

        andi    t0, t9, Joypad.A            // t0 = 0 if A not held
        bnez    t0, _is_held                // if held, do custom checks
        addu    t1, t1, a1                  // t1 = address of port's buffer

        // otherwise, return normally
        sb      r0, 0x0000(t1)              // reset held_buffer
        li      t1, held_timer              // t1 = held time table
        addu    t1, t1, a1                  // t1 = address of port's held timer
        sb      r0, 0x0000(t1)              // reset held_timer

        _normal:
        lhu     t9, 0x0002(t8)              // original line 1-vs, 2-1p - t9 = pressed button mask
        andi    t0, t9, Joypad.A            // original line 2-vs, 5-1p - t0 = 0 if A not pressed
        jr      ra
        or      t9, t0, r0                  // Training needs this

        _is_held:
        li      t0, curr_port_buffer_addr   // t0 = curr_port_buffer_addr
        sw      t1, 0x0000(t0)              // store address of port's held buffer
        lbu     t0, 0x0000(t1)              // t0 = held buffer
        addiu   t2, t0, 0x0001              // t2 = held buffer incremented
        sltiu   t0, t2, FASTBUFFER          // t2 = 0 if we've reached fast buffer time
        bnezl   t0, pc() + 8                // if we we haven't reach fast buffer, then update held buffer
        sb      t2, 0x0000(t1)              // update held buffer
        sltiu   t1, t2, BUFFER              // t1 = 0 if we've reached buffer
        bnez    t1, _normal                 // if below buffer, treat as normal
        li      t1, held_timer              // t1 = held time table (yes, use delay slot for 1st instruction)

        addu    t1, t1, a1                  // t1 = address of port's held timer
        lbu     t0, 0x0000(t1)              // t0 = held timer
        addiu   t0, t0, 0x0001              // t0++
        sb      t0, 0x0000(t1)              // update held timer
        sltiu   t2, t2, FASTBUFFER          // t2 = 0 if we've reached fast buffer time
        beqz    t2, _apply                  // if fast buffer, skip timer check
        sltiu   t0, t0, TIMER               // t0 = 0 if we've reached timer
        bnez    t0, _normal                 // if below timer, treat as normal
        nop

        _apply:
        // otherwise, reset the timer and apply the press handler
        sb      r0, 0x0000(t1)              // reset timer
        sw      ra, 0x0008(sp)              // save ra to unused stack space
        lw      t0, 0x0010(sp)              // t0 = routine start in press_a_handler_
        jalr    t0
        nop
        _ra:
        lw      ra, 0x0008(sp)              // restore ra
        jr      ra
        lli     t0, 0x0000                  // t0 = 0 for A press check

        // Frames per port A is held
        held_buffer:
        db 0, 0, 0, 0

        // Helps control speed of scroll
        held_timer:
        db 0, 0, 0, 0

        // Prevents playing sound every frame
        fgm_buffer:
        dw 0

        // Address of current port's buffer
        curr_port_buffer_addr:
        dw 0
    }

    // @ Description
    // Checks if debug button is pressed and updates debug menu state
    // a0 - cursor object
    // a1 - debug button object
    scope handle_debug_button_press_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        li      v0, Toggles.entry_css_panel_menu
        lw      v0, 0x0004(v0)              // v0 = 0 if CSS panel menu disabled
        beqz    v0, _end                    // if not enabled, skip
        nop

        jal     CharacterSelect.check_image_press_ // v0 = 1 if button pressed, 0 if not
        nop
        beqz    v0, _end                    // if not pressed, skip
        nop

        lw      at, 0x0050(a1)              // at = button press state (1 = enabled, 0 = disabled)
        beqz    at, _end                    // skip if button pressing not allowed
        nop

        li      at, press_a_handler_._end   // at = new ra, past other custom button handler checks
        sw      at, 0x0004(sp)              // set new ra

        // update display state
        lw      at, 0x0044(a1)              // at = debug menu display state (0 = on, 1 = off)
        xori    at, at, 0x0001              // at = new display state (0 -> 1, 1 -> 0)
        sw      at, 0x0044(a1)              // save display state

        jal     set_panel_display_
        or      a0, r0, a1                  // a0 = debug button object

        // play FGM
        jal     0x800269C0
        lli     a0, FGM.menu.TOGGLE         // a0 = FGM.menu.TOGGLE

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Checks if a reset to defaults button is pressed and updates debug menu state
    // a0 - cursor object
    // a1 - debug button object
    scope handle_reset_button_press_: {
        beqz    a1, _return                 // if no debug button object, skip
        nop

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~

        jal     CharacterSelect.check_image_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0034(a1)              // a1 = reset to defaults button object

        beqz    v0, _end                    // if not pressed, skip
        nop

        lw      at, 0x007C(a1)              // at = button press state (0 = enabled, 1 = disabled)
        bnez    at, _end                    // skip if button pressing not allowed
        nop

        li      at, press_a_handler_._end   // at = new ra, past other custom button handler checks
        sw      at, 0x0004(sp)              // set new ra

        // update all menu items to default values
        li      at, debug_control_object
        lw      at, 0x0000(at)              // at = debug control object
        lw      at, 0x0048(at)              // at = menu array
        lw      t0, 0x0000(at)              // t0 = human menu array
        lw      a1, 0x000C(sp)              // a1 = debug button object
        lw      t4, 0x0054(a1)              // t4 = port index
        sll     t4, t4, 0x0002              // t4 = offset in value string array
        lli     t5, 0x0001                  // t5 = loop counter

        _loop:
        lw      t1, 0x0000(t0)              // t1 = menu item
        beqz    t1, _next                   // if no more menu items, exit loop
        nop
        lw      t2, 0x0010(t1)              // t2 = default value
        lw      t3, 0x001C(t1)              // t3 = value array
        addu    t3, t3, t4                  // t3 = value address
        sw      t2, 0x0000(t3)              // set to default

        // call change handler
        lw      t6, 0x0018(t1)              // t6 = change handler routine
        beqzl   t6, _loop                   // if no change handler, skip calling change handler
        addiu   t0, t0, 0x0004              // t0 = next menu item address

        sw      at, 0x0014(sp)              // save menu arrays
        sw      t0, 0x0018(sp)              // save menu array
        sw      t1, 0x001C(sp)              // save menu item
        sw      t2, 0x0020(sp)              // save updated value
        sw      t5, 0x0024(sp)              // save loop counter
        sw      t4, 0x0028(sp)              // save offset in value string array

        or      a0, r0, t1                  // a0 = menu item
        lw      a3, 0x0040(a1)              // a3 = panel struct
        lw      t0, 0x004C(a1)              // t0 = 1 if 1P/Bonus, 0 otherwise
        beqzl   t0, pc() + 12               // if not 1p/bonus...
        lw      a3, 0x0008(a3)              // ...then player object is here...
        lw      a3, 0x0030(a3)               // ...otherwise it's here
        lw      a1, 0x0054(a1)              // a1 = port index
        jalr    t6
        or      a2, r0, t2                  // a2 = new value

        lw      at, 0x0014(sp)              // restore menu arrays
        lw      t0, 0x0018(sp)              // restore menu array
        lw      t1, 0x001C(sp)              // restore menu item
        lw      t2, 0x0020(sp)              // restore updated value
        lw      t5, 0x0024(sp)              // restore loop counter
        lw      t4, 0x0028(sp)              // restore offset in value string array
        lw      a1, 0x000C(sp)              // restore debug button object

        b       _loop
        addiu   t0, t0, 0x0004              // t0 = next menu item address

        _next:
        beqz    t5, _refresh                // if done looping, skip ahead
        lw      t0, 0x0004(at)              // t0 = cpu menu array
        bnez    t0, _loop                   // reset cpu menu array, if it exists
        addiu   t5, t5, -0x0001             // t5--

        _refresh:
        addiu   t3, a1, 0x0060              // t3 = pointer to first menu item
        lw      t5, 0x0070(a1)              // t5 = menu renderer
        lw      t0, 0x0040(t5)              // t0 = first menu item value object
        beqz    t0, _set_high_scores_flag   // if no menu item yet (pressed same frame as toggle on), then skip
        nop

        _refresh_loop:
        lw      t1, 0x0000(t3)              // t1 = menu item
        lhu     t6, 0x0004(t1)              // t6 = value type
        lli     at, value_type.NUMERIC
        beq     at, t6, _refresh_next       // if numeric, skip text stuff
        lw      t6, 0x0014(t1)              // t6 = string table
        sll     t7, t2, 0x0002              // t7 = offset in string table
        addu    t7, t6, t7                  // t7 = pointer to string
        lw      t7, 0x0000(t7)              // t7 = string
        sw      t7, 0x0034(t0)              // update string address
        _refresh_next:
        addiu   t5, t5, 0x0004              // t5 = menu renderer, offset
        lw      t0, 0x0040(t5)              // t0 = next menu item value object
        bnez    t0, _refresh_loop           // loop if there is an item value object
        addiu   t3, t3, 0x0004              // t3 = next menu item pointer

        _set_high_scores_flag:
        li      t0, debug_control_object
        lw      t0, 0x0000(t0)              // t0 = debug control object
        lw      a0, 0x0044(t0)              // a0 = offset in css_player_structs = 4 for 1P, >=0xC for Bonus
        sltiu   t0, a0, 0x000C              // t0 = 0 if Bonus
        beqz    t0, _check_high_scores_flag // if Bonus, skip to check high scores flag
        lli     t0, 0x0004                  // t0 = 4 for 1p
        bne     a0, t0, _play_fgm           // if not 1p, skip
        nop

        _check_high_scores_flag:
        jal     check_high_scores_enabled
        nop

        li      t0, SinglePlayer.high_score_enabled
        sw      v0, 0x0000(t0)              // set high scores enabled flag

        _play_fgm:
        // play FGM
        jal     0x800269C0
        lli     a0, FGM.menu.TOGGLE         // a0 = FGM.menu.TOGGLE

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _return:
        jr      ra
        nop
    }

    // @ Description
    // Checks if menu item arrows are pressed and updates menu item values
    // a0 - cursor object
    // a1 - debug control object
    scope handle_item_arrow_press_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x0028(sp)              // ~

        // Iterate through each debug button object's menu renderer's arrow objects, if they exist

        addiu   t0, a1, 0x0030              // t0 = address of first debug button object
        lli     t9, 0x0003                  // t9 = loop counter

        _loop:
        sw      t0, 0x000C(sp)              // save address of debug button object
        sw      t9, 0x0010(sp)              // save loop counter
        lw      t1, 0x0000(t0)              // t1 = debug button object
        beqz    t1, _next                   // if no debug object, skip
        nop

        lw      t2, 0x0070(t1)              // t2 = menu renderer
        addiu   t2, t2, 0x0050              // t2 = address of first left arrow object
        lli     t8, 0x0003                  // t8 = loop counter

        _loop_arrow:
        sw      t2, 0x0014(sp)              // save address of arrow object
        sw      t8, 0x0018(sp)              // save loop counter
        lw      t3, 0x0000(t2)              // t3 = arrow object
        beqz    t3, _next_arrow             // if no arrow object, skip
        nop

        // We have an arrow object, so check for left arrow press
        lli     a2, 0x0000                  // a2 = left padding
        lli     a3, 0x0008                  // a3 = right padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0074(t3)              // a1 = left arrow image footer struct
        bnez    v0, _pressed                // if pressed, branch accordingly
        addiu   t6, r0, -0x0001             // t6 = -1 for left press
        lli     a2, 0x0008                  // a2 = left padding
        lli     a3, 0x0000                  // a3 = right padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0008(a1)              // a1 = right arrow image footer struct
        beqz    v0, _next_arrow             // if not pressed, skip
        lli     t6, 0x0001                  // t6 = +1 for right press

        _pressed:
        // Check if enabled
        lw      a1, 0x0004(a1)              // a1 = arrow object
        lw      t4, 0x007C(a1)              // t4 = 1 if disabled, 0 if enabled
        bnez    t4, _next_arrow             // if not enabled, skip
        nop

        li      at, press_a_handler_._end   // at = new ra, past other custom button handler checks
        sw      at, 0x0004(sp)              // set new ra

        sw      t6, 0x0048(a1)              // save direction

        _update_value:
        // Update value
        // 0x0040(a1) - port index
        // 0x0044(a1) - menu item
        // 0x0048(a1) - direction (-1 for left, 1 for right)
        lw      t4, 0x0040(a1)              // t4 = port index
        lw      t5, 0x0044(a1)              // t5 = menu item

        lw      t7, 0x001C(t5)              // t7 = value array address
        sll     t4, t4, 0x0002              // t4 = offset to value
        addu    t4, t7, t4                  // t4 = value address for port
        lw      t7, 0x0000(t4)              // t7 = value
        addu    t7, t7, t6                  // t7 = new value
        lw      t6, 0x0008(t5)              // t6 = min value
        slt     at, t7, t6                  // at = 1 if new value is less than min value (which is bad)
        bnezl   at, pc() + 8                // if less than the min value, set to max value
        lw      t7, 0x000C(t5)              // t7 = new value (max value)
        lw      t6, 0x000C(t5)              // t6 = max value
        slt     at, t6, t7                  // at = 1 if max value is less than new value (which is bad)
        bnezl   at, pc() + 8                // if higher than max value, set to min value
        lw      t7, 0x0008(t5)              // t7 = new value (min value)

        sw      t7, 0x0000(t4)              // update value

        // call change handler
        lw      t6, 0x0018(t5)              // t6 = change handler routine
        beqz    t6, _set_high_scores_flag   // if no change handler, skip calling change handler
        sw      a1, 0x0024(sp)              // save arrow object

        sw      t5, 0x001C(sp)              // save menu item
        sw      t7, 0x0020(sp)              // save updated value

        lw      t0, 0x000C(sp)              // t0 = address of debug button object
        lw      t1, 0x0000(t0)              // t1 = debug button object
        lw      t0, 0x004C(t1)              // t0 = 1 if 1P/Bonus, 0 otherwise
        lw      a3, 0x0040(t1)              // a3 = panel struct
        beqzl   t0, pc() + 12               // if not 1p/bonus...
        lw      a3, 0x0008(a3)              // ...then player object is here...
        lw      a3, 0x0030(a3)               // ...otherwise it's here

        or      a0, r0, t5                  // a0 = menu item
        lw      a1, 0x0040(a1)              // a1 = port index
        jalr    t6
        or      a2, r0, t7                  // a2 = new value

        lw      t5, 0x001C(sp)              // restore menu item
        lw      t7, 0x0020(sp)              // restore updated value
        lw      a1, 0x0024(sp)              // restore arrow object

        _set_high_scores_flag:
        lw      t0, 0x0028(sp)              // t0 = debug control object
        lw      a0, 0x0044(t0)              // a0 = offset in css_player_structs = 4 for 1P, >=0xC for Bonus
        sltiu   t0, a0, 0x000C              // t0 = 0 if Bonus
        beqz    t0, _check_high_scores_flag // if Bonus, skip to check high scores flag
        lli     t0, 0x0004                  // t0 = 4 for 1p
        bne     a0, t0, _check_string_update // if not 1p, skip
        nop

        _check_high_scores_flag:
        jal     check_high_scores_enabled
        nop

        li      t0, SinglePlayer.high_score_enabled
        sw      v0, 0x0000(t0)              // set high scores enabled flag

        _check_string_update:
        // for text, we also have to update the string
        lhu     t6, 0x0004(t5)              // t6 = value type
        lli     at, value_type.NUMERIC
        beq     at, t6, _play_fgm           // if numeric, skip text stuff
        lw      t6, 0x0014(t5)              // t6 = string table
        sll     t7, t7, 0x0002              // t7 = offset in string table
        addu    t7, t6, t7                  // t7 = pointer to string
        lw      t7, 0x0000(t7)              // t7 = string
        lbu     t2, 0x0000(t7)              // t2 = first character
        beqz    t2, _skip_value             // if this is blank, skip the value
        lw      t2, 0x0014(sp)              // t2 = address of arrow object
        addiu   t2, t2, -0x0010             // t2 = address of value object
        lw      t2, 0x0000(t2)              // t2 = value object
        sw      t7, 0x0034(t2)              // update string address

        _play_fgm:
        li      a0, hold_a_handler_.fgm_buffer
        lw      t0, 0x0000(a0)              // t0 = fgm buffer
        bnezl   t0, _end                    // make sure we don't play every frame when being held
        lw      a0, 0x0008(sp)              // a0 = cursor object

        lli     t0, hold_a_handler_.FGM_BUFFER // t0 = fgm buffer
        OS.read_word(0x800451A0, t1)        // t1 = number of plugged in controllers
        multu   t0, t1                      // mflo = fgm buffer * num controllers
        mflo    t0                          // ~
        sw      t0, 0x0000(a0)              // save fgm buffer

        // play FGM
        jal     0x800269C0
        lli     a0, FGM.menu.TOGGLE         // a0 = FGM.menu.TOGGLE
        lw      a0, 0x0008(sp)              // a0 = cursor object

        b       _end                        // we can stop checking if other arrows were pressed by this cursor
        nop

        _skip_value:
        lw      a1, 0x0024(sp)              // a1 = arrow object
        b       _update_value               // loop until we find the next one
        lw      t6, 0x0048(a1)              // t6 = direction

        _next_arrow:
        lw      t2, 0x0014(sp)              // t2 = address of current arrow object
        addiu   t2, t2, 0x0004              // t2 = address of next arrow object
        lw      t8, 0x0018(sp)              // t8 = loop counter
        bnezl   t8, _loop_arrow             // loop until t9 is 0
        addiu   t8, t8, -0x0001             // t8--

        _next:
        lw      t0, 0x000C(sp)              // t0 = address of current debug button object
        addiu   t0, t0, 0x0004              // t0 = address of next debug button object
        lw      t9, 0x0010(sp)              // t9 = loop counter
        bnezl   t9, _loop                   // loop until t9 is 0
        addiu   t9, t9, -0x0001             // t9--

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Checks if pagination arrows are pressed and updates page number accordingly
    // a0 - cursor object
    // a1 - debug control object
    scope handle_page_arrow_press_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        // Iterate through each debug button object, checking its pagination renderer's arrow objects, if they exist

        addiu   t0, a1, 0x0030              // t0 = address of first debug button object
        lli     t9, 0x0003                  // t9 = loop counter

        _loop:
        sw      t0, 0x000C(sp)              // save address of debug button object
        sw      t9, 0x0010(sp)              // save loop counter
        lw      t1, 0x0000(t0)              // t1 = debug button object
        beqz    t1, _next                   // if no debug object, skip
        nop

        lw      t2, 0x0030(t1)              // t2 = pagination renderer
        sw      t2, 0x0014(sp)              // save pagination renderer
        lw      a1, 0x0034(t2)              // a1 = left arrow object
        beqz    a1, _next                   // if no arrow object, skip
        lli     a2, 0x0000                  // a2 = 0 (no left padding)

        // We have an arrow object, so check for button press
        lli     a3, 0x0003                  // a3 = 3 (right padding)
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0074(a1)              // a1 = image footer
        bnez    v0, _update_page            // if pressed, update page
        nop

        lw      t2, 0x0014(sp)              // t2 = pagination renderer
        lli     a2, 0x0004                  // a2 = 4 (left padding)
        lli     a3, 0x0000                  // a3 = 0 (no right padding)
        lw      a1, 0x0038(t2)              // a1 = right arrow object
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0074(a1)              // a1 = image footer
        beqz    v0, _next                   // if not pressed, skip
        nop

        _update_page:
        // limit scroll speed for pagination arrows
        li      t4, hold_a_handler_.curr_port_buffer_addr // t4 = curr_port_buffer_addr
        lw      t4, 0x0000(t4)              // t4 = Address of current port's held buffer
        sb      r0, 0x0000(t4)              // reset held_buffer

        // Check if enabled
        lw      a1, 0x0004(a1)              // a1 = arrow image object
        lw      t4, 0x007C(a1)              // t4 = 1 if disabled, 0 if enabled
        bnez    t4, _next                   // if not enabled, skip
        nop

        li      at, press_a_handler_._end   // at = new ra, past other custom button handler checks
        sw      at, 0x0004(sp)              // set new ra

        // Update value
        // 0x0048(a1) - direction (-1 for left, 1 for right)
        lw      t2, 0x0014(sp)              // t2 = pagination renderer
        lw      t2, 0x0070(t2)              // t2 = debug button object
        lw      t6, 0x0048(a1)              // t6 = direction

        lw      t7, 0x005C(t2)              // t7 = current page
        addu    t7, t7, t6                  // t7 = new value
        lli     t6, 0x0000                  // t6 = min value
        slt     at, t7, t6                  // at = 1 if new value is less than min value (which is bad)
        bnezl   at, pc() + 8                // if less than the min value, set to max value
        lw      t7, 0x0084(t2)              // t7 = new value (max value)

        lw      t6, 0x0084(t2)              // t6 = max value
        slt     at, t6, t7                  // at = 1 if max value is less than new value (which is bad)
        bnezl   at, pc() + 8                // if higher than the max value, set to min value
        lli     t7, 0x0000                  // t7 = new value (min value)

        sw      t7, 0x005C(t2)              // update value

        // clear out menu item array
        sw      r0, 0x0060(t2)              // clear pointer for menu item 1
        sw      r0, 0x0064(t2)              // clear pointer for menu item 2
        sw      r0, 0x0068(t2)              // clear pointer for menu item 3
        sw      r0, 0x006C(t2)              // clear pointer for menu item 4
        // then destroy the objects
        jal     render_menu_page_
        lw      a0, 0x0070(t2)              // a0 = menu renderer object
        // then setup the menu item array
        lw      t2, 0x0014(sp)              // t2 = pagination renderer
        jal     setup_menu_page_
        lw      a0, 0x0070(t2)              // a0 = debug button object
        // then recreate the menu page
        lw      t2, 0x0014(sp)              // t2 = pagination renderer
        lw      t2, 0x0070(t2)              // a0 = debug button object
        jal     render_menu_page_
        lw      a0, 0x0070(t2)              // a0 = menu renderer object

        // play FGM
        li      a0, hold_a_handler_.fgm_buffer
        lw      t0, 0x0000(a0)              // t0 = fgm buffer
        bnez    t0, _end                    // make sure we don't play every frame when being held
        lli     t0, hold_a_handler_.FGM_BUFFER // t0 = fgm buffer
        OS.read_word(0x800451A0, t1)        // t1 = number of plugged in controllers
        multu   t0, t1                      // mflo = fgm buffer * num controllers
        mflo    t0                          // ~
        sw      t0, 0x0000(a0)              // save fgm buffer

        jal     0x800269C0
        lli     a0, FGM.menu.TOGGLE         // a0 = FGM.menu.TOGGLE

        b       _end                        // we can stop checking if other arrows were pressed by this cursor
        nop

        _next:
        lw      a0, 0x0008(sp)              // a0 = cursor object
        lw      t0, 0x000C(sp)              // t0 = address of current debug button object
        addiu   t0, t0, 0x0004              // t0 = address of next debug button object
        lw      t9, 0x0010(sp)              // t9 = loop counter
        bnezl   t9, _loop                   // loop until t9 is 0
        addiu   t9, t9, -0x0001             // t9--

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Moves Team buttons to the right 5 pixels
    OS.patch_start(0x130A6C, 0x801327EC)
    addiu   t9, t8, 0x0027                  // original: addiu   t9, t8, 0x0022
    OS.patch_end()

    // @ Description
    // Disables HMN/CPU/NA button and right/left arrow press detection when the debug menu is displayed
    scope disable_panel_buttons_: {
        // HMN/CPU/NA button
        OS.patch_start(0x133D38, 0x80135AB8)
        lui     at, 0x8013
        j       disable_panel_buttons_
        ori     at, at, 0x5AC4              // at = return address
        OS.patch_end()
        // CPU Level/Handicap right arrow button
        OS.patch_start(0x133B78, 0x801358F8)
        lui     at, 0x8013
        j       disable_panel_buttons_
        ori     at, at, 0x5904              // at = return address
        OS.patch_end()
        // CPU Level/Handicap left arrow button
        OS.patch_start(0x133C58, 0x801359D8)
        lui     at, 0x8013
        j       disable_panel_buttons_
        ori     at, at, 0x59E4              // at = return address
        OS.patch_end()
        // Team button
        OS.patch_start(0x1337D4, 0x80135554)
        lui     at, 0x8013
        j       disable_panel_buttons_
        ori     at, at, 0x5560              // at = return address
        OS.copy_segment(0x1337E0, 0x0008)
        addiu   t6, v1, 0x0027              // original line 6: addiu   t6, v1, 0x0022
        OS.patch_end()

        // a1 - port index

        li      t6, debug_control_object
        lw      t6, 0x0000(t6)              // t6 = debug control object
        sll     t7, a1, 0x0002              // t7 = port index * 4
        addu    t6, t6, t7                  // t6 = debug control object, adjusted for port
        lw      t6, 0x0030(t6)              // t6 = debug button object
        beqz    t6, _normal                 // if the debug button is not present, continue normally
        nop
        lw      t6, 0x0044(t6)              // t6 = display state (0 = hidden, 1 = active)
        beqz    t6, _normal                 // if the debug menu is hidden, continue normally
        nop

        jr      ra                          // otherwise, exit the routine and return 0 for no press
        or      v0, r0, r0                  // v0 = 0

        _normal:
        sll     v1, a1, 0x0004              // original line 1
        addu    v1, v1, a1                  // original line 2
        jr      at
        sll     v1, v1, 0x0002              // original line 3
    }

    // @ Description
    // Ensures the player model is hidden when the debug menu is displayed
    scope prevent_player_model_display_: {
        // VS
        OS.patch_start(0x132E00, 0x80134B80)
        jal     prevent_player_model_display_
        lw      t0, 0x0020(sp)              // original line 1
        OS.patch_end()
        // Training
        OS.patch_start(0x142E8C, 0x801338AC)
        jal     prevent_player_model_display_
        lw      v1, 0x0020(sp)              // original line 1
        OS.patch_end()
        // 1P
        OS.patch_start(0x13D330, 0x80135130)
        lli     a1, 0x0000                  // a1 = 0 (port index)
        jal     prevent_player_model_display_._1p
        lui     at, 0x8014                  // original line 1
        OS.patch_end()
        // Bonus
        OS.patch_start(0x14A208, 0x801341D8)
        lli     a1, 0x0000                  // a1 = 0 (port index)
        jal     prevent_player_model_display_._bonus
        lui     at, 0x8013                  // original line 1
        OS.patch_end()

        // v0 - player object
        lw      a1, 0x006C(sp)              // a1 = port index

        _common:
        li      t6, debug_control_object
        lw      t6, 0x0000(t6)              // t6 = debug control object
        beqz    t6, _end                    // if debug control object is not initialized, skip (can happen in training)
        sll     t7, a1, 0x0002              // t7 = port index * 4
        addu    t6, t6, t7                  // t6 = debug control object, adjusted for port
        lw      t6, 0x0030(t6)              // t6 = debug button object
        beqz    t6, _end                    // if the debug button is not present, continue normally
        nop
        lw      t6, 0x0044(t6)              // t6 = debug menu display state (0 = hidden, 1 = active)
        bnezl   t6, _end                    // if the debug menu is active...
        sw      r0, 0x0038(v0)              // ...then hide the player model

        _end:
        jr      ra
        lui     a1, 0x8013                  // original line 2

        _1p:
        b       _common                     // just needed an extra line to set a1
        sw      v0, 0x8EF0(at)              // original line 3

        _bonus:
        b       _common                     // just needed an extra line to set a1
        sw      v0, 0x7650(at)              // original line 3
    }

    // @ Description
    // Ensures the series logo and name object is hidden when the debug menu is displayed
    scope prevent_series_logo_and_name_display_: {
        // VS
        OS.patch_start(0x130CAC, 0x80132A2C)
        jal     prevent_series_logo_and_name_display_
        or      a3, a2, r0                  // original line 1
        OS.patch_end()
        // Training
        OS.patch_start(0x141BCC, 0x801325EC)
        jal     prevent_series_logo_and_name_display_
        or      a3, a2, r0                  // original line 1
        OS.patch_end()

        // a0 - series logo and name object
        // a1 - port index

        li      t6, debug_control_object
        lw      t6, 0x0000(t6)              // t6 = debug control object
        beqz    t6, _end                    // if debug control object is not initialized, skip (can happen in training)
        sll     t5, a1, 0x0002              // t5 = port index * 4
        addu    t6, t6, t5                  // t6 = debug control object, adjusted for port
        lw      t6, 0x0030(t6)              // t6 = debug button object
        beqz    t6, _end                    // if the debug button is not present, continue normally
        nop
        lw      t6, 0x0044(t6)              // t6 = debug menu display state (0 = hidden, 1 = active)
        bnezl   t6, _end                    // if the debug menu is active...
        sw      r0, 0x0038(a0)              // ...then hide the name and series logo object

        _end:
        jr      ra
        addiu   t0, t7, 0x0060              // original line 2
    }

    // @ Description
    // Ensures the white circle is hidden when the debug menu is displayed
    scope prevent_white_circle_display_: {
        // VS
        OS.patch_start(0x137E24, 0x80139BA4)
        j       prevent_white_circle_display_._vs
        or      t9, a1, r0                  // original line 2
        _return_vs:
        OS.patch_end()
        // Training
        OS.patch_start(0x1465BC, 0x80136FDC)
        j       prevent_white_circle_display_._training
        or      t9, a1, r0                  // original line 2
        _return_training:
        OS.patch_end()
        // 1P
        OS.patch_start(0x13FC44, 0x80137A44)
        j       prevent_white_circle_display_._1p
        or      t9, v0, r0                  // original line 2
        _return_1p:
        OS.patch_end()
        // Bonus
        OS.patch_start(0x14C528, 0x801364F8)
        j       prevent_white_circle_display_._bonus
        or      t9, v0, r0                  // original line 2
        _return_bonus:
        OS.patch_end()

        _vs:
        // a0 - white circle object
        // v0 - port index
        li      t8, _return_vs              // setup return register
        b       _common                     // branch to common routine
        or      t0, v0, r0                  // t0 = port index

        _training:
        // a0 - white circle object
        // v0 - port index
        li      t8, _return_training        // setup return register
        b       _common                     // branch to common routine
        or      t0, v0, r0                  // t0 = port index

        _1p:
        // a0 - white circle object
        li      t8, _return_1p              // setup return register
        b       _common                     // branch to common routine
        lli     t0, 0x0000                  // t0 = port index (always 0)

        _bonus:
        // a0 - white circle object
        li      t8, _return_bonus           // setup return register
        lli     t0, 0x0000                  // t0 = port index (always 0)

        _common:
        addiu   t5, r0, -0x0001             // t5 = -1 (render on)
        sw      t5, 0x0038(a0)              // turn on

        li      t5, debug_control_object
        lw      t5, 0x0000(t5)              // t5 = debug control object
        beqz    t5, _end                    // if debug control object is not initialized, skip (can happen in training)
        sll     t7, t0, 0x0002              // t7 = port index * 4
        addu    t5, t5, t7                  // t5 = debug control object, adjusted for port
        lw      t5, 0x0030(t5)              // t5 = debug button object
        beqz    t5, _end                    // if the debug button is not present, continue normally
        nop
        lw      t5, 0x0044(t5)              // t5 = debug menu display state (0 = hidden, 1 = active)
        bnezl   t5, _end                    // if the debug menu is active...
        sw      r0, 0x0038(a0)              // ...then hide the white circle

        _end:
        jr      t8
        addiu   t0, t6, 0x0030              // original line 1
    }

    // Clear debug menu settings that shouldn't be applied before 1P, Bonus 3 and Multimans.
    scope clear_debug_menu_settings_for_1p_: {
        OS.patch_start(0x52068, 0x800D6868)
        jal     clear_debug_menu_settings_for_1p_
        lbu     v0, 0x0013(s2)              // original line 1
        OS.patch_end()

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~

        jal     Size.clear_settings_for_1p_
        or      a0, r0, v0                  // a0 = human port

        jal     Visibility.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     Skeleton.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     Knockback.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     Shield.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     Handicap.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     InputDelay.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     ModelDisplay.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     StartWith.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     TauntItem.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     TauntButton.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     InputDisplay.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     PlayerTag.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     KirbyHat.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     Damage.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        jal     PoisonDmg.clear_settings_for_1p_
        lw      a0, 0x000C(sp)              // a0 = human port

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        addiu   s5, r0, 0x0074              // original line 2
    }

    // @ Description
    // Determines if there are any settings enabled that should disable saving high scores
    scope check_high_scores_enabled: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~

        lli     v0, OS.TRUE                 // v0 = true: high scores enabled
        li      t0, debug_control_object
        lw      t0, 0x0000(t0)              // t0 = debug control object
        lw      t0, 0x0048(t0)              // t0 = menu arrays
        lw      t0, 0x0000(t0)              // t0 = human menu array

        _loop:
        lw      t1, 0x0000(t0)              // t1 = menu item
        beqz    t1, _check_toggles          // if empty, then exit loop
        addiu   t0, t0, 0x0004              // t0 = next menu item pointer address
        lhu     t2, 0x0006(t1)              // t2 = 1 if this menu item can disabled high scores
        beqz    t2, _loop                   // if this menu item doesn't affect high scores, skip
        lw      t2, 0x0010(t1)              // t2 = default value
        lw      t1, 0x001C(t1)              // t1 = value array
        lui     v0, 0x800A                  // v0 = human player port
        lbu     v0, 0x4AE3(v0)              // ~
        sll     v0, v0, 0x0002              // v0 = offset to port's value
        addu    t1, t1, v0                  // t1 = address of port's value
        lw      t1, 0x0000(t1)              // t1 = port's value
        bnel    t1, t2, _end                // if not the default value, then can't save high scores!
        lli     v0, OS.FALSE                // v0 = FALSE = can't save high scores
        b       _loop                       // continue loop
        lli     v0, OS.TRUE                 // reset v0

        _check_toggles:
        li      t0, Toggles.block_gameplay
        lw      t1, 0x0010(t0)              // t1 = current Gameplay toggles values, word 1
        li      t2, 0xFFFF7FCF              // t2 = 0xFFFF7FCF = mask to ignore improved AI and J sounds (make sure to update this if Gameplay toggles changed)
        and     t1, t1, t2                  // t1 = current Gameplay toggles values, ignoring J sounds (make sure to update this if Gameplay toggles changed)
        lli     t2, 0x0000                  // t2 = default values (make sure to update this if Gameplay toggles changed)
        bnel    t1, t2, _end                // if current values don't match the defaults, then can't save high scores!
        lli     v0, OS.FALSE                // v0 = FALSE = can't save high scores
        lw      t1, 0x0014(t0)              // t1 = current Gameplay toggles values, word 2 (default is 0)
        bnezl   t1, _end                    // if current values don't match the defaults, then can't save high scores!
        lli     v0, OS.FALSE                // v0 = FALSE = can't save high scores

        li      t0, Toggles.block_pokemon
        lw      t1, 0x0010(t0)              // t1 = current Pokemon toggles values
        andi    t1, t1, 0xFFFC              // t1 = current Pokemon toggles values, ignoring sfx (make sure to update this if Gameplay toggles changed)
        lli     t2, 0x7FFC                  // t2 = default values (make sure to update this if Pokemon toggles changed)
        bnel    t1, t2, _end                // if current values don't match the defaults, then can't save high scores!
        lli     v0, OS.FALSE                // v0 = FALSE = can't save high scores

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // This prevents memory overflow on the CSS when rendering all panels' debug menus.
    OS.patch_start(0x139C38, 0x8013B9B8)
    dw      0x000055F0 + 0x4000             // original is 0x55F0
    OS.patch_end()

    // @ Description
    // Points to menu arrays for each CSS
    // 0x0000 - human array
    // 0x0004 - CPU array
    menu_arrays:
    dw menu_array_vs,       menu_array_vs_cpu
    dw menu_array_1p,       0
    dw menu_array_training, menu_array_training_cpu
    dw menu_array_bonus,    0
    dw menu_array_bonus,    0
    dw menu_array_allstar,  0

    // @ Description
    // Variables used for tracking counts
    variable menu_item_count(0)
    variable menu_item_count_vs(0)
    variable menu_item_count_vs_cpu(0)
    variable menu_item_count_1p(0)
    variable menu_item_count_training(0)
    variable menu_item_count_training_cpu(0)
    variable menu_item_count_bonus(0)
    variable menu_item_count_allstar(0)

    // @ Description
    // Constants for value type
    scope value_type {
        constant NUMERIC(Render.string_type.NUMBER)
        constant STRING(Render.string_type.TEXT)
    }

    // @ Description
    // Creates a menu item and ensures it will be added to the indicated menu arrays
    // @ Arguments
    // label - label for menu item
    // value_type - see value_type scope for possible values
    // min_value - minimum value
    // max_value - maximum value
    // default_value - default value
    // string_table - table containing pointers to strings to be displayed instead of the index value, if value_type = STRING
    // onchange_handler - routine to run when value is changed, or 0 if not necessary
    // applies_to - bitmask for which menu arrays to append... ex: 0b101000 means add to vs and training, 0b010110 means add to 1p and bonus 1 and 2
    // applies_to_hmn_cpu - bitmask for whether the menu item applies to humans, cpus or both... ex: 0b10 means humans only, 0b01 means cpus only, 0b11 means both
    // value_array_pointer - if provided, a pointer to external value array pointer... if 0, value array will be created
    // disables_high_scores - boolean indicating if this value causes high scores to be disabled when not set to default value
    macro add_menu_item(label, value_type, min_value, max_value, default_value, string_table, onchange_handler, applies_to, applies_to_hmn_cpu, value_array_pointer, disables_high_scores) {
        evaluate i(menu_item_count)
        global variable menu_item_count(menu_item_count + 1)

        // Insert label string
        menu_item_{i}_label:; String.insert({label})

        // Create menu item struct
        menu_item_{i}:
        dw menu_item_{i}_label          // 0x00 - pointer to label string
        dh {value_type}                 // 0x04 - value type
        dh {disables_high_scores}       // 0x06 - disables high scores flag
        dw {min_value}                  // 0x08 - min value
        dw {max_value}                  // 0x0C - max value
        dw {default_value}              // 0x10 - default value
        dw {string_table}               // 0x14 - string table
        dw {onchange_handler}           // 0x18 - routine to run on change

        if ({value_array_pointer} == 0) {
            dw pc() + 4                 // 0x1C - pointer to value array
            // value array
            dw {default_value}          // 0x20 - current value 1p
            dw {default_value}          // 0x24 - current value 2p
            dw {default_value}          // 0x28 - current value 3p
            dw {default_value}          // 0x2C - current value 4p
        } else {
            dw {value_array_pointer}    // 0x1C - pointer to value array
        }

        // If applies to VS, setup for adding to VS menu item array
        if ({applies_to} & 0b100000) > 0 {
            // human
            if ({applies_to_hmn_cpu} & 0b10) > 0 {
	            evaluate n(menu_item_count_vs)
	            global evaluate MENU_ITEM_VS_{n}(menu_item_{i})
	            global variable menu_item_count_vs(menu_item_count_vs + 1)
	        }
	        // cpu
            if ({applies_to_hmn_cpu} & 0b01) > 0 {
	            evaluate n(menu_item_count_vs_cpu)
	            global evaluate MENU_ITEM_VS_CPU_{n}(menu_item_{i})
	            global variable menu_item_count_vs_cpu(menu_item_count_vs_cpu + 1)
	        }
        }

        // If applies to 1P, setup for adding to 1P menu item array
        if ({applies_to} & 0b010000) > 0 {
            evaluate n(menu_item_count_1p)
            global evaluate MENU_ITEM_1P_{n}(menu_item_{i})
            global variable menu_item_count_1p(menu_item_count_1p + 1)
        }

        // If applies to Training, setup for adding to Training menu item array
        if ({applies_to} & 0b001000) > 0 {
            // human
            if ({applies_to_hmn_cpu} & 0b10) > 0 {
	            evaluate n(menu_item_count_training)
	            global evaluate MENU_ITEM_TRAINING_{n}(menu_item_{i})
	            global variable menu_item_count_training(menu_item_count_training + 1)
	        }
	        // cpu
            if ({applies_to_hmn_cpu} & 0b01) > 0 {
	            evaluate n(menu_item_count_training_cpu)
	            global evaluate MENU_ITEM_TRAINING_CPU_{n}(menu_item_{i})
	            global variable menu_item_count_training_cpu(menu_item_count_training_cpu + 1)
	        }
        }

        // If applies to Bonus, setup for adding to Bonus menu item array
        if ({applies_to} & 0b000110) > 0 {
            evaluate n(menu_item_count_bonus)
            global evaluate MENU_ITEM_BONUS_{n}(menu_item_{i})
            global variable menu_item_count_bonus(menu_item_count_bonus + 1)
        }

        // If applies to Allstar, setup for adding to Allstar menu item array
        if ({applies_to} & 0b000001) > 0 {
            evaluate n(menu_item_count_allstar)
            global evaluate MENU_ITEM_ALLSTAR_{n}(menu_item_{i})
            global variable menu_item_count_allstar(menu_item_count_allstar + 1)
        }
    }

    // @ Description
    // Adds a menu item from a scope name.
    // (Can be thought of as implementing a MenuItem interface.)
    // @ Arguments
    // item - the name of the scope containing the required constants and routines
    macro add_menu_item(item) {
        // make string_table default to 0 unless value_type is STRING
        evaluate string_table(0)
        if {item}.VALUE_TYPE == value_type.STRING {
            evaluate string_table({item}.string_table)
        }

        add_menu_item({{item}.LABEL}, {item}.VALUE_TYPE, {item}.MIN_VALUE, {item}.MAX_VALUE, {item}.DEFAULT_VALUE, {string_table}, {item}.ONCHANGE_HANDLER, {item}.APPLIES_TO, {item}.APPLIES_TO_HUMAN_CPU, {item}.VALUE_ARRAY_POINTER, {item}.DISABLES_HIGH_SCORES)
    }

    // @ Description
    // Writes menu items to ROM
    macro write_menu_items() {
        menu_array_vs_info:
        dw menu_item_count_vs
        define n(0)
        menu_array_vs:
        while {n} < menu_item_count_vs {
            dw {MENU_ITEM_VS_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_vs_cpu_info:
        dw menu_item_count_vs_cpu
        define n(0)
        menu_array_vs_cpu:
        while {n} < menu_item_count_vs_cpu {
            dw {MENU_ITEM_VS_CPU_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_1p_info:
        dw menu_item_count_1p
        menu_array_1p:
        define n(0)
        while {n} < menu_item_count_1p {
            dw {MENU_ITEM_1P_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_training_info:
        dw menu_item_count_training
        menu_array_training:
        define n(0)
        while {n} < menu_item_count_training {
            dw {MENU_ITEM_TRAINING_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_training_cpu_info:
        dw menu_item_count_training_cpu
        menu_array_training_cpu:
        define n(0)
        while {n} < menu_item_count_training_cpu {
            dw {MENU_ITEM_TRAINING_CPU_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_bonus_info:
        dw menu_item_count_bonus
        menu_array_bonus:
        define n(0)
        while {n} < menu_item_count_bonus {
            dw {MENU_ITEM_BONUS_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        menu_array_allstar_info:
        dw menu_item_count_allstar
        menu_array_allstar:
        define n(0)
        while {n} < menu_item_count_allstar {
            dw {MENU_ITEM_ALLSTAR_{n}}
            evaluate n({n}+1)
        }
        dw 0 // terminator

        print "Total menu items: ", menu_item_count, "\n"
        print "Total VS menu items: HMN=", menu_item_count_vs, " CPU=", menu_item_count_vs_cpu, "\n"
        print "Total 1p menu items: ", menu_item_count_1p, "\n"
        print "Total Training menu items: HMN=", menu_item_count_training, " CPU=", menu_item_count_training_cpu, "\n"
        print "Total Bonus menu items: ", menu_item_count_bonus, "\n"
        print "Total Allstar menu items: ", menu_item_count_allstar, "\n"
    }

    // Include menu item files, scoped
    scope StockMode {
        include "css/StockMode.asm"
    }
    scope Size {
        include "css/Size.asm"
    }
    scope Visibility {
        include "css/Visibility.asm"
    }
    scope Skeleton {
        include "css/Skeleton.asm"
    }
    scope Knockback {
        include "css/Knockback.asm"
    }
    scope Shield {
        include "css/Shield.asm"
    }
    scope InputDelay {
        include "css/InputDelay.asm"
    }
    scope Handicap {
        include "css/Handicap.asm"
    }
    scope ModelDisplay {
        include "css/ModelDisplay.asm"
    }
    scope StartWith {
        include "css/StartWith.asm"
    }
    scope TauntItem {
        include "css/TauntItem.asm"
    }
    scope TauntButton {
        include "css/TauntButton.asm"
    }
    scope InputDisplay {
        include "css/InputDisplay.asm"
    }
    scope Practice_1P {
        include "css/Practice_1P.asm"
    }
    scope PlayerTag {
        include "css/PlayerTag.asm"
    }
    scope KirbyHat {
        include "css/KirbyHat.asm"
    }
    scope DpadFunctions {
        include "css/DpadFunctions.asm"
    }
    scope DpadControl {
        include "css/DpadControl.asm"
    }
    scope Damage {
        include "css/Damage.asm"
    }

    scope PoisonDmg {
        include "css/PoisonDmg.asm"
    }

    // Add Menu Items
    add_menu_item(Shield)
    add_menu_item(PlayerTag)
    add_menu_item(Visibility)
    add_menu_item(Skeleton)
    add_menu_item(ModelDisplay)
    add_menu_item(InputDisplay)
    add_menu_item(Size)
    add_menu_item(StockMode)
    add_menu_item(Knockback)
    add_menu_item(InputDelay)
    add_menu_item(Handicap)
    add_menu_item(StartWith)
    add_menu_item(TauntItem)
    add_menu_item(TauntButton)
    add_menu_item(KirbyHat)
    add_menu_item(DpadFunctions)
    add_menu_item(DpadControl)
    add_menu_item(Damage)
    add_menu_item(PoisonDmg)
    add_menu_item(Practice_1P)

    // Write Menu Items
    write_menu_items()
}

} // __CHARACTER_SELECT_DEBUG_MENU__
