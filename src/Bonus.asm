// Bonus.asm
if !{defined __BONUS__} {
define __BONUS__()
print "included Bonus.asm\n"

scope Bonus {
    constant NUM_BONUS_STAGES(31)

    // @ Description
    // Sets up CSS for alternate Bonus modes
    scope setup_: {
        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer mode flag
        beqz    t0, _begin                  // if Bonus 1/2, draw options - t0 = display on
        lli     t1, SinglePlayerModes.BONUS3_ID
        bne     t0, t1, _end                // if not Bonus 1/2/3, skip
        lli     t0, 0x0000                  // t0 = display on

        _begin:
        OS.save_registers()
        // 0x0020(sp) - display on/off

        Render.load_file(File.STOCK_ICONS, stock_icons_file)

        // Draw rectangle behind Option
        Render.draw_rectangle(0x22, 0x19, 175, 136, 144, 5, 0x576088FF, OS.FALSE)

        // Draw Option
        Render.draw_texture_at_offset(0x22, 0x19, 0x80137E0C, 0x1EC8, Render.NOOP, 0x43460000, 0x43010000, 0xAFB1CCFF, 0x000000FF, 0x3F800000)

        // Draw sideways U
        or      a0, r0, v0                  // a0 = object
        li      a1, 0x80137E0C              // a1 = file 0x17 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0x17 base address
        lli     t0, 0x1208                  // t0 = sideways U image footer offset
        addu    a1, a1, t0                  // t0 = sideways U image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x4312                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x430B                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x576088FF              // t0 = color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x01000500              // t0 = mirror flags?
        sw      t0, 0x0064(v0)              // save mirror flags
        li      t0, 0x00B80040              // t0 = more mirror flags?
        sw      t0, 0x0068(v0)              // save more mirror flags

        // Left Arrow - Mode
        Render.draw_texture_at_offset(0x22, 0x19, 0x80137DF8, 0xECE8, arrow_routine_, 0x43540000, 0x431D0000, 0xFFFFFFFF, 0x000000FF, 0x3F800000)
        sw      r0, 0x004C(v0)              // initialize blink timer
        li      t0, arrow_object
        sw      v0, 0x0000(t0)              // save reference to arrow object

        // Right Arrow - Mode
        or      a0, r0, v0                  // a0 = object
        li      a1, 0x80137DF8              // a1 = file 0x11 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0x11 base address
        lli     t0, 0xEDC8                  // t0 = mode right arrow image footer offset
        addu    a1, a1, t0                  // t0 = mode right arrow image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x438C                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x431D                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        // Left Arrow - Stage
        lw      a0, 0x0004(v0)              // a0 = object
        li      a1, 0x80137DF8              // a1 = file 0x11 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0x11 base address
        lli     t0, 0xECE8                  // t0 = stage left arrow image footer offset
        addu    a1, a1, t0                  // t0 = stage left arrow image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x4354                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4330                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        // Right Arrow - Stage
        lw      a0, 0x0004(v0)              // a0 = object
        li      a1, 0x80137DF8              // a1 = file 0x11 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0x11 base address
        lli     t0, 0xEDC8                  // t0 = stage right arrow image footer offset
        addu    a1, a1, t0                  // t0 = stage right arrow image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x438C                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4330                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        // Draw MODE and STAGE strings
        Render.draw_string(0x22, 0x19, string_mode, Render.NOOP, 0x43500000, 0x431C0000, 0xC5B6A7FF, 0x3F600000, Render.alignment.RIGHT)
        Render.draw_string(0x22, 0x19, string_stage, Render.NOOP, 0x43500000, 0x432F0000, 0xC5B6A7FF, 0x3F600000, Render.alignment.RIGHT)
        li      t0, arrow_object
        lw      t0, 0x0000(t0)              // t0 = arrow object
        sw      v0, 0x0048(t0)              // save reference to STAGE string
        li      t1, mode
        lw      t1, 0x0000(t1)              // t1 = mode index
        beqzl   t1, pc() + 8                // if Normal mode, hide STAGE string on init
        sw      r0, 0x0038(v0)              // turn off display

        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer mode flag
        bnezl   t0, pc() + 8                // if not Bonus 1/2, hide STAGE string on init
        sw      r0, 0x0038(v0)              // turn off display

        // Draw R button and Set Stage String
        Render.load_file(0xC5, Render.file_pointer_4)                 // load button images into file_pointer_4
        Render.draw_string(0x22, 0x1A, string_set_stage, Render.NOOP, 0x429D0000, 0x43590000, 0xFFFFFFFF, 0x3F500000, Render.alignment.LEFT)
        Render.draw_texture_at_offset(0x22, 0x1A, Render.file_pointer_4, Render.file_c5_offsets.R, Render.NOOP, 0x42770000, 0x43580000, 0x848484FF, 0x303030FF, 0x3F800000)

        // Draw selected MODE string
        Render.draw_string_pointer(0x22, 0x19, mode_pointer, Render.update_live_string_, 0x43790000, 0x431C0000, 0xE4BE41FF, 0x3F600000, Render.alignment.CENTER)
        li      t0, arrow_object
        lw      v1, 0x0000(t0)              // v1 = arrow object
        addiu   t0, v1, 0x0040              // t0 = address of mode string reference
        sw      v0, 0x0000(t0)              // save reference to mode string
        sw      t0, 0x0054(v0)              // save address storing object reference
        li      t1, mode
        lw      t1, 0x0000(t1)              // t1 = mode index
        sll     t1, t1, 0x0002              // t1 = offset to color
        li      t0, mode_color_table
        addu    t0, t0, t1                  // t0 = address of color
        lw      t0, 0x0000(t0)              // t0 = color
        sw      t0, 0x0040(v0)              // set color
        sw      r0, 0x0030(v0)              // clear current string address to trigger redraw

        // Draw selected stage icon(s)
        li      t1, stage
        lw      t1, 0x0000(t1)              // t1 = stage index
        sll     t2, t1, 0x0001              // t2 = offset to character id array
        li      t3, stock_icon_table
        addu    t3, t3, t2                  // t3 = character id array
        lbu     t4, 0x0000(t3)              // t4 = character id, stock icon 1
        sw      t3, 0x0050(v1)              // save reference to character id array

        lli     a0, 0x0022                  // a0 = room
        lli     a1, 0x0019                  // a1 = group
        li      a2, stock_icons_file
        lw      a2, 0x0000(a2)              // a2 = stock icons file
        li      a3, SinglePlayerModes.icon_offset_table
        sll     t4, t4, 0x0002              // t4 = offset to icon offset
        addu    a3, a3, t4                  // a3 = address of icon offset
        lw      a3, 0x0000(a3)              // a3 = icon offset
        addu    a2, a2, a3                  // a2 = address of stock icon 1
        lli     a3, 0x0000                  // a3 = routine = Render.NOOP
        lui     s1, 0x4375                  // s1 = ulx
        lui     s2, 0x4330                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale
        li      t0, arrow_object
        lw      v1, 0x0000(t0)              // v1 = arrow object
        sw      v0, 0x0044(v1)              // save reference to stock icon object

        li      t1, mode
        lw      t1, 0x0000(t1)              // t1 = mode index
        beqzl   t1, pc() + 8                // if Normal mode, skip rendering stock icon on init
        sw      r0, 0x0038(v0)              // turn off display

        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer mode flag
        bnezl   t0, pc() + 8                // if not Bonus 1/2, skip rendering stock icon on init
        sw      r0, 0x0038(v0)              // turn off display

        lw      t3, 0x0050(v1)              // t3 = character id array
        addiu   t3, t3, 0x0001              // t3 = address of stock icon 2 char_id
        lbu     t4, 0x0000(t3)              // t4 = character id, stock icon 2
        beqz    t4, _init_display           // if no stock icon 2, skip
        lui     t0, 0x4370                  // t0 = ulx, adjusted left
        lw      a1, 0x0074(v0)              // a1 = stock icon image 1 image struct
        sw      t0, 0x0058(a1)              // save ulx
        or      a0, v0, r0                  // a0 = stock icon object
        li      a1, stock_icons_file        // a1 = stock icons file base address pointer
        lw      a1, 0x0000(a1)              // a1 = stock icons file base address
        li      t0, SinglePlayerModes.icon_offset_table
        sll     t4, t4, 0x0002              // t4 = offset to icon offset
        addu    t0, t0, t4                  // t0 = address of icon offset
        lw      t0, 0x0000(t0)              // t0 = icon offset
        addu    a1, a1, t0                  // t0 = stock icon 2 image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x437A                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4330                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        _init_display:
        lw      a1, 0x0020(sp)              // a1 = display on/off
        jal     Render.toggle_group_display_
        lli     a0, 0x0019                  // a0 = group

        OS.restore_registers()

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This toggles the CSS objects when cycling between Bonus 1/2/3 accordingly
    scope handle_header_toggle_: {
        OS.patch_start(0x149388, 0x80133358)
        j       handle_header_toggle_
        swc1    f8, 0x0058(v0)              // original line 1
        _return:
        OS.patch_end()

        lli     a1, 0x0000                  // a1 = display off
        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer mode flag
        beqzl   t0, pc() + 8                // if Bonus 1/2, turn display on
        addiu   a1, r0, -0x0001             // a1 = display on

        li      t0, mode
        lw      t0, 0x0000(t0)              // t0 = mode (0 - Normal, 1 - Remix)
        beqzl   t0, pc() + 8                // if Normal, turn display off
        lli     a1, 0x0000                  // a1 = display off

        OS.read_word(0x80046754, t0)        // t0 = group 0x19 head
        li      t1, arrow_object
        beqzl   t0, _end                    // skip if not initialized
        sw      r0, 0x0000(t1)              // make sure arrow object is not set from before
        lw      t0, 0x0000(t1)              // t0 = arrow object
        beqz    t0, _end                    // skip if not created
        nop
        lw      t1, 0x0048(t0)              // t1 = STAGE string
        sw      a1, 0x0038(t1)              // set display
        lw      t1, 0x0044(t0)              // t1 = icons object
        sw      a1, 0x0038(t1)              // set display
        addiu   a1, a1, 0x0001
        sw      a1, 0x007C(t1)              // set display

        _end:
        j       _return
        swc1    f10, 0x005C(v0)             // original line 2
    }

    // @ Description
    // Gives the arrows blinking effects and controls when they are visible.
    // @ Arguments
    // a0 - arrow object
    scope arrow_routine_: {
        // implement blink
        lw      t0, 0x004C(a0)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   t2, t0, 0x000B              // t2 = 1 if timer < 11, 0 otherwise
        sltiu   at, t0, 0x0014              // at = 1 if timer < 20, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 20, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x004C(a0)              // update timer

        addiu   t1, r0, -0x0001             // t1 = display on
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display

        // show/hide arrows based on selections
        li      t2, mode
        lw      t2, 0x0000(t2)              // t2 = mode (0 - Normal, 1 - Remix)
        lw      t0, 0x0074(a0)              // t0 = mode left arrow image struct

        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0205                  // t1 = render flags (hide)
        sh      t1, 0x0024(t0)              // update render flags

        lw      t0, 0x0008(t0)              // t0 = mode right arrow image struct
        lli     t1, 0x0201                  // t1 = render flags (blur)
        lli     t3, 0x0001                  // t3 = max mode index
        beql    t2, t3, pc() + 8            // if last mode, update render flags so right arrow is not visible
        lli     t1, 0x0205                  // t1 = render flags (hide)
        sh      t1, 0x0024(t0)              // update render flags

        lw      t0, 0x0008(t0)              // t0 = stage left arrow image struct

        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if Normal, update render flags so stage arrows are not visible
        lli     t1, 0x0205                  // t1 = render flags (hide)

        li      t3, SinglePlayerModes.singleplayer_mode_flag
        lw      t3, 0x0000(t3)              // t3 = singleplayer mode flag
        bnezl   t3, pc() + 8                // if not Bonus 1/2, update render flags so stage arrows are not visible
        lli     t1, 0x0205                  // t1 = render flags (hide)

        sh      t1, 0x0024(t0)              // update render flags
        lw      t0, 0x0008(t0)              // t0 = stage right arrow image struct
        sh      t1, 0x0024(t0)              // update render flags

        jr      ra
        nop
    }

    // @ Description
    // Checks if R is pressed and updates stage accordingly
    // @ Arguments
    // a0 - button mask
    scope check_input_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // ~
        sw      a2, 0x0020(sp)              // ~
        sw      a3, 0x0024(sp)              // ~
        sw      v0, 0x0028(sp)              // ~

        li      t2, SinglePlayerModes.singleplayer_mode_flag
        lw      t2, 0x0000(t2)              // t0 = singleplayer mode flag
        bnezl   t2, _R_text                 // if not Bonus 1/2, skip
        lli     a1, 0x0001                  // a1 = display off

        li      t2, mode
        lw      t2, 0x0000(t2)              // t2 = mode (0 - Normal, 1 - Remix)
        beqzl   t2, _R_text                 // if Normal selected, skip checking for input
        lli     a1, 0x0001                  // a1 = display off

        lw      t2, 0x0054(t1)              // 0x0054(t1) = held token player index (port 0 - 3 or -1 if not holding a token)
        bltzl   t2, _R_text                 // if token not held, skip checking for input
        lli     a1, 0x0001                  // a1 = display off

        li      at, CharacterSelect.CSS_PLAYER_STRUCT_BONUS // at = Bonus CSS struct
        lw      v0, 0x0048(at)              // v0 = character id
        lli     at, Character.id.NONE
        beql    at, v0, _R_text             // if no character is selected, don't update stage
        lli     a1, 0x0001                  // a1 = display off

        andi    a0, a0, Joypad.R            // a0 = 0 if R not pressed
        beqzl   a0, _R_text                 // if not pressed, branch accordingly
        lli     a1, 0x0000                  // a1 = display on


        // should be able to always get the stage index from the BTT tables
        li      at, Character.BTT_TABLE
        addu    at, at, v0                  // at = address of stage id
        lbu     a0, 0x0000(at)              // a0 = stage id
        jal     get_bonus_stage_index_      // v0 = stage index
        lli     a1, 0x0000                  // a1 = BTT

        jal     update_stage_and_icons_
        or      a0, v0, r0                  // a0 = stage index

        jal     FGM.play_
        lli     a0, FGM.menu.SCROLL         // a0 = FGM.menu.SCROLL

        _R_text:
        // show/hide "R: Set Stage" text based on context
        lli     a0, 0x001A                  // a0 = group
        jal     Render.toggle_group_display_
        nop

        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // ~
        lw      a1, 0x001C(sp)              // ~
        lw      a2, 0x0020(sp)              // ~
        lw      a3, 0x0024(sp)              // ~
        lw      v0, 0x0028(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }


    // @ Description
    // Disables automatic start after selecting character (in Remix Mode)
    scope manual_remix_bonus_start_: {
        OS.patch_start(0x0014CABC, 0x80136A8C)
        jal     manual_remix_bonus_start_._check_mode
        lui     t2, 0x8013                        // original line 1
        OS.patch_end()

        _check_mode:
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)                    // t6 = singleplayer mode flag
        bnezl   t6, _return                       // if not Bonus 1/2, return
        addiu   t6, t5, 0xFFFF                    // original line 2
        li      t6, mode
        lw      t6, 0x0000(t6)                    // t6 = mode (0 - Normal, 1 - Remix)
        beqzl   t6, _return                       // if Remix not selected, start automatically
        addiu   t6, t5, 0xFFFF                    // original line 2
        lli     t6, 0x008C                        // t6 = 140

        _return:
        jr      ra
        nop
    }

    // @ Description
    // Checks if arrows are pressed and updates mode/stage accordingly
    // a0 - cursor object
    scope handle_arrow_press_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        li      t2, SinglePlayerModes.singleplayer_mode_flag
        lw      t2, 0x0000(t2)              // t0 = singleplayer mode flag
        beqz    t2, _begin                  // if Bonus 1/2, begin
        lli     a0, SinglePlayerModes.BONUS3_ID
        bne     t2, a0, _end                // if not Bonus 1/2/3, skip
        nop

        _begin:
        li      t2, mode
        lw      t2, 0x0000(t2)              // t2 = mode (0 - Normal, 1 - Remix)
        li      a1, arrow_object
        lw      a1, 0x0000(a1)              // a1 = arrow object
        sw      a1, 0x000C(sp)              // save reference to arrow object
        lw      a1, 0x0074(a1)              // a1 = mode left arrow image struct
        lui     a0, 0x8013
        beqz    t2, _mode_right_check       // if Normal selected, skip checking left
        lw      a0, 0x7648(a0)              // a0 = cursor object
        lli     a2, 0x0000                  // a2 = left padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lli     a3, 0x0008                  // a3 = right padding
        bnezl   v0, _mode_pressed           // if pressed, branch accordingly
        addiu   t6, r0, -0x0001             // t6 = -1 for left press

        _mode_right_check:
        li      t2, mode
        lw      t2, 0x0000(t2)              // t2 = mode (0 - Normal, 1 - Remix)
        lli     t3, 0x0001                  // t3 = max mode index
        beq     t2, t3, _stage_check        // if last mode, skip checking right
        lw      a1, 0x0008(a1)              // a1 = right arrow image footer struct
        lli     a2, 0x0008                  // a2 = left padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lli     a3, 0x0000                  // a3 = right padding
        beqz    v0, _end                    // if not pressed, skip
        lli     t6, 0x0001                  // t6 = +1 for right press

        _mode_pressed:
        li      t2, mode
        lw      t1, 0x0000(t2)              // t1 = mode (0 - Normal, 1 - Remix)
        addu    t1, t1, t6                  // t1 = updated mode
        sw      t1, 0x0000(t2)              // update mode

        sll     t1, t1, 0x0002              // t1 = offset to color
        li      t0, mode_color_table
        addu    t0, t0, t1                  // t0 = address of color
        lw      t0, 0x0000(t0)              // t0 = color
        lw      a1, 0x000C(sp)              // a1 = arrow object
        lw      v0, 0x0040(a1)              // v0 = mode string object
        sw      t0, 0x0040(v0)              // set color
        li      t0, mode_table
        addu    t0, t0, t1                  // t0 = address of mode string
        lw      t0, 0x0000(t0)              // t0 = mode string
        lw      v0, 0x0034(v0)              // v0 = mode_pointer
        sw      t0, 0x0000(v0)              // update string

        lw      v0, 0x0044(a1)              // v0 = stage icon object
        lli     t2, 0x0000                  // t2 = display off
        bnezl   t1, pc() + 8                // if not Normal, display icon object
        addiu   t2, r0, -0x0001             // t2 = display on

        li      a2, SinglePlayerModes.singleplayer_mode_flag
        lw      a2, 0x0000(a2)              // a2 = singleplayer mode flag
        bnezl   a2, pc() + 8                // if not Bonus 1/2, always set display off
        lli     t2, 0x0000                  // t2 = display off

        sw      t2, 0x0038(v0)              // turn display on/off
        addiu   t1, t2, 0x0001              // t1 = display flag for 0x7C
        sw      t1, 0x007C(v0)              // turn display on/off
        lw      v0, 0x0048(a1)              // v0 = STAGE string object
        b       _play_fgm
        sw      t2, 0x0038(v0)              // turn display on/off

        _stage_check:
        li      a2, SinglePlayerModes.singleplayer_mode_flag
        lw      a2, 0x0000(a2)              // a2 = singleplayer mode flag
        bnez    a2, _end                    // if not Bonus 1/2, skip stage checks
        nop

        lli     a2, 0x0008                  // a2 = left padding
        lli     a3, 0x0000                  // a3 = right padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0008(a1)              // a1 = stage left arrow image footer struct
        bnezl   v0, _stage_pressed          // if pressed, branch accordingly
        addiu   t6, r0, -0x0001             // t6 = -1 for left press

        lli     a2, 0x0008                  // a2 = left padding
        lli     a3, 0x0000                  // a3 = right padding
        jal     CharacterSelect.check_image_footer_press_ // v0 = 1 if button pressed, 0 if not
        lw      a1, 0x0008(a1)              // a1 = stage right arrow image footer struct
        beqz    v0, _end                    // if not pressed, skip
        lli     t6, 0x0001                  // t6 = +1 for right press

        _stage_pressed:
        li      t2, stage
        lw      t1, 0x0000(t2)              // t1 = stage
        addu    a0, t1, t6                  // a0 = updated stage

        lli     t3, NUM_BONUS_STAGES        // t3 = NUM_BONUS_STAGES = number of stages
        bltzl   a0, pc() + 8                // if less than 0, reset to max stage index
        addiu   a0, t3, -0x0001             // a0 = max stage index
        sltu    at, a0, t3                  // at = 0 if past max stage index
        beqzl   at, pc() + 8                // if past max stage index, reset to 0
        lli     a0, 0x0000                  // a0 = 0

        jal     update_stage_and_icons_
        nop

        _play_fgm:
        jal     FGM.play_
        lli     a0, FGM.menu.SCROLL         // a0 = FGM.menu.SCROLL

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Updates the stage index and refreshes the stock icons
    // @ Arguments
    // a0 - stage index
    scope update_stage_and_icons_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        li      a1, arrow_object
        lw      a1, 0x0000(a1)              // a1 = arrow object
        sw      a1, 0x000C(sp)              // save reference to arrow object

        li      t2, stage                   // t2 = stage
        sw      a0, 0x0000(t2)              // update stage

        jal     0x8000B760                  // destroy the stock icons
        lw      a0, 0x0044(a1)              // a0 = stock icon object

        lw      t4, 0x000C(sp)              // t4 = arrow object
        lw      a0, 0x0044(t4)              // a0 = stock icon object

        li      a1, stock_icons_file        // a1 = stock_icons_file base address pointer
        lw      a1, 0x0000(a1)              // a1 = stock_icons_file base address
        li      t1, stage
        lw      t1, 0x0000(t1)              // t1 = stage index
        sll     t2, t1, 0x0001              // t2 = offset to character id array
        li      t3, stock_icon_table
        addu    t3, t3, t2                  // t3 = character id array
        sw      t3, 0x0050(t4)              // save reference to character id array
        lbu     t4, 0x0000(t3)              // t4 = character id, stock icon 1
        li      t3, SinglePlayerModes.icon_offset_table
        sll     t4, t4, 0x0002              // t4 = offset to icon offset
        addu    t3, t3, t4                  // t3 = address of icon offset
        lw      t3, 0x0000(t3)              // t3 = icon offset
        addu    a1, a1, t3                  // a1 = address of stock icon 1
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x4375                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4330                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        lw      t4, 0x000C(sp)              // t4 = arrow object
        lw      t3, 0x0050(t4)              // t3 = character id array
        addiu   t3, t3, 0x0001              // t3 = address of stock icon 2 char_id
        lbu     t4, 0x0000(t3)              // t4 = character id, stock icon 2
        beqz    t4, _end                    // if no stock icon 2, skip
        lui     t0, 0x4370                  // t0 = ulx, adjusted left
        sw      t0, 0x0058(v0)              // save ulx
        lw      a0, 0x0004(v0)              // a0 = stock icon object
        li      a1, stock_icons_file        // a1 = stock icons file base address pointer
        lw      a1, 0x0000(a1)              // a1 = stock icons file base address
        li      t0, SinglePlayerModes.icon_offset_table
        sll     t4, t4, 0x0002              // t4 = offset to icon offset
        addu    t0, t0, t4                  // t0 = address of icon offset
        lw      t0, 0x0000(t0)              // t0 = icon offset
        addu    a1, a1, t0                  // t0 = stock icon 2 image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x437A                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4330                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Gets the stage index of the given stage_id
    // @ Arguments
    // a0 - stage_id
    // a1 - type (0 = BTT, 1 = BTP)
    scope get_bonus_stage_index_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~

        li      t0, btt_stage_table         // t0 = btt_stage_table
        bnezl   a1, pc() + 8                // if a platform stage, use btp_stage_table
        addiu   t0, btp_stage_table - btt_stage_table // t0 = btp_stage_table

        lli     v0, 0x0000                  // v0 = 0
        _loop:
        lbu     t1, 0x0000(t0)              // t1 = stage_id
        beq     a0, t1, _return             // if this is the stage, return v0
        addiu   t0, t0, 0x0001              // t0 = address of next stage_id
        sltiu   t1, v0, NUM_BONUS_STAGES - 1 // t1 = 0 if we didn't find it
        bnezl   t1, _loop                   // if we didn't find it yet, keep looking
        addiu   v0, v0, 0x0001              // v0 = next index

        // if we got here, let's return -1
        addiu   v0, r0, -0x0001             // v0 = -1

        _return:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // Strings!
    string_mode:; String.insert("MODE:")
    string_stage:; String.insert("STAGE:")
    string_mode_normal:; String.insert("NORMAL")
    string_mode_remix:; String.insert("REMIX")
    string_set_stage:; String.insert(": Set Stage")
    string_level:; String.insert("LEVEL:")
    string_level_very_easy:; String.insert("VERY EASY")
    string_level_easy:; String.insert("EASY")
    string_level_normal:; String.insert("NORMAL")
    string_level_hard:; String.insert("HARD")
    string_level_very_hard:; String.insert("VERY HARD")

    // Holds a reference to the custom stock icons file
    stock_icons_file:
    dw 0x0

    // Holds a reference to the object which renders the blinking arrows
    arrow_object:
    dw 0x0

    // The selected mode index
    mode:
    dw 0x0

    // Table which maps mode index to the mode string
    mode_table:
    dw string_mode_normal
    dw string_mode_remix

    // Table which maps mode index to the mode string color
    mode_color_table:
    dw 0xE4BE41FF // yellow
    dw 0xE44141FF // red

    // Points to the selected mode's string
    mode_pointer:
    dw string_mode_normal

    // The selected CPU level index
    level:
    dw 0x0

	// Table which maps CPU level index to the level string
    level_table:
    dw string_level_very_easy
    dw string_level_easy
    dw string_level_normal
    dw string_level_hard
    dw string_level_very_hard

    // Table which maps CPU level to the level string color
    level_color_table:
    dw 0x416FE4FF // blue
    dw 0x8DBB5AFF // green
    dw 0xE4BE41FF // yellow
    dw 0xE47841FF // orange
    dw 0xE44141FF // red

    // The selected stage index
    stage:
    dw 0x0

    // Maps BTT stage index to a BTT stage ID
    btt_stage_table:
    db Stages.id.BTT_MARIO
    db Stages.id.BTT_FOX
    db Stages.id.BTT_DONKEY_KONG
    db Stages.id.BTT_SAMUS
    db Stages.id.BTT_LUIGI
    db Stages.id.BTT_LINK
    db Stages.id.BTT_YOSHI
    db Stages.id.BTT_FALCON
    db Stages.id.BTT_KIRBY
    db Stages.id.BTT_PIKACHU
    db Stages.id.BTT_JIGGLYPUFF
    db Stages.id.BTT_NESS

    db Stages.id.BTT_FALCO
    db Stages.id.BTT_GND
    db Stages.id.BTT_YL
    db Stages.id.BTT_DRM
    db Stages.id.BTT_WARIO
    db Stages.id.BTT_DS
    db Stages.id.BTT_LUCAS
    db Stages.id.BTT_BOWSER
    db Stages.id.BTT_WOLF
    db Stages.id.BTT_CONKER
    db Stages.id.BTT_MTWO
    db Stages.id.BTT_MARTH
    db Stages.id.BTT_SONIC
    db Stages.id.BTT_SHEIK
    db Stages.id.BTT_MARINA
    db Stages.id.BTT_DEDEDE
    db Stages.id.BTT_GOEMON
    db Stages.id.BTT_BANJO

    db Stages.id.BTT_STG1
    OS.align(4)

    // Maps BTP stage index to a BTP stage ID
    btp_stage_table:
    db Stages.id.BTP_MARIO
    db Stages.id.BTP_FOX
    db Stages.id.BTP_DONKEY_KONG
    db Stages.id.BTP_SAMUS
    db Stages.id.BTP_LUIGI
    db Stages.id.BTP_LINK
    db Stages.id.BTP_YOSHI
    db Stages.id.BTP_FALCON
    db Stages.id.BTP_KIRBY
    db Stages.id.BTP_PIKACHU
    db Stages.id.BTP_JIGGLYPUFF
    db Stages.id.BTP_NESS

    db Stages.id.BTP_FALCO
    db Stages.id.BTP_GND
    db Stages.id.BTP_YL
    db Stages.id.BTP_DRM
    db Stages.id.BTP_WARIO
    db Stages.id.BTP_DS
    db Stages.id.BTP_LUCAS2
    db Stages.id.BTP_BOWSER
    db Stages.id.BTP_WOLF
    db Stages.id.BTP_CONKER
    db Stages.id.BTP_MTWO
    db Stages.id.BTP_MARTH
    db Stages.id.BTP_SONIC
    db Stages.id.BTP_SHEIK
    db Stages.id.BTP_MARINA
    db Stages.id.BTP_DEDEDE
    db Stages.id.BTP_GOEMON
    db Stages.id.BTP_BANJO

    db Stages.id.BTP_POLY
    OS.align(4)

    // Maps BTX stage index to character IDs corresponding to stock icons representing the BTX stage
    stock_icon_table:
    db Character.id.MARIO,      Character.id.METAL
    db Character.id.FOX,        Character.id.PEPPY
    db Character.id.DK,         0x0
    db Character.id.SAMUS,      0x0
    db Character.id.LUIGI,      Character.id.MLUIGI
    db Character.id.LINK,       0x0
    db Character.id.YOSHI,      0x0
    db Character.id.CAPTAIN,    Character.id.DRAGONKING
    db Character.id.KIRBY,      0x0
    db Character.id.PIKACHU,    0x0
    db Character.id.JIGGLYPUFF, 0x0
    db Character.id.NESS,       0x0

    db Character.id.FALCO,      Character.id.SLIPPY
    db Character.id.GND,        0x0
    db Character.id.YLINK,      0x0
    db Character.id.DRM,        0x0
    db Character.id.WARIO,      0x0
    db Character.id.DSAMUS,     0x0
    db Character.id.LUCAS,      0x0
    db Character.id.BOWSER,     Character.id.GBOWSER
    db Character.id.WOLF,       0x0
    db Character.id.CONKER,     0x0
    db Character.id.MTWO,       0x0
    db Character.id.MARTH,      0x0
    db Character.id.SONIC,      Character.id.SSONIC
    db Character.id.SHEIK,      0x0
    db Character.id.MARINA,     0x0
    db Character.id.DEDEDE,     0x0
    db Character.id.GOEMON,     Character.id.EBI
    db Character.id.BANJO,      0x0

    db Character.id.NMARIO,     Character.id.PIANO
    OS.align(4)

    // Set up high score table for Remix Bonus
    // Ordered by Stage index then Character ID.
    // In SRAM, we need to conserve space. The max time possible is 0x00034BBF, so we can get away with using 3 bytes.
    // 0x0000 - (byte) # Targets
    // 0x0001 - (3 bytes) Targets Time
    // 0x0004 - (byte) # Platforms
    // 0x0005 - (3 bytes) Platforms Time
    OS.align(16)
    constant REMIX_BONUS_HIGH_SCORE_TABLE_ORIGIN(origin() + 0x0010)
    REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK:; SRAM.block(NUM_BONUS_STAGES * Character.NUM_CHARACTERS * 0x6)

    // initialize high score table
    pushvar origin, base
    origin REMIX_BONUS_HIGH_SCORE_TABLE_ORIGIN

    // Targets: If 0x01 is 0x0A, then 0x02 is # of Targets, else the 3 bytes are the time
    // Platforms: If 0x01 is 0x0A, then 0x02 is # of Platforms, else the 3 bytes are the time
    remix_bonus_high_score_table:
    define s(0)
    while {s} < NUM_BONUS_STAGES {
        define c(0)
        while {c} < Character.NUM_CHARACTERS {
            db 0x0A, 0x00, 0x00               // Targets
            db 0x0A, 0x00, 0x00               // Platforms

            evaluate c({c} + 1)
        }

        evaluate s({s} + 1)
    }

    pullvar base, origin

    OS.align(16)
    constant REMIX_BONUS3_HIGH_SCORE_TABLE_ORIGIN(origin() + 0x0010)
    REMIX_BONUS3_HIGH_SCORE_TABLE_BLOCK:; SRAM.block(Character.NUM_CHARACTERS * 0x4)
    constant REMIX_BONUS3_HIGH_SCORE_TABLE(REMIX_BONUS3_HIGH_SCORE_TABLE_BLOCK + 0x0010)
}

} // __BONUS__
