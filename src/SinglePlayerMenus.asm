// SinglePlayerMenus.asm
if !{defined __SINGLE_PLAYER_MENUS__} {
define __SINGLE_PLAYER_MENUS__()
print "included SinglePlayerMenus.asm\n"

// @ Description
// This contains the code for the revised Single Player Menu Screens

scope SinglePlayerMenus: {

// 1P MENU SCREEN / BUTTONS

    // @ Description
    // This removes the flag that identifies different 1p modes
    scope remove_flag: {
        OS.patch_start(0x11EBE8, 0x80132AD8)
        j        remove_flag
        nop
        _return:
        OS.patch_end()

        li      v0, SinglePlayerModes.singleplayer_mode_flag
        sw      r0, 0x0000(v0)
        li      v0, SinglePlayerEnemy.enemy_port
        sw      r0, 0x0000(v0)          // clears port
        li      v0, SinglePlayerEnemy.enemy_selected
        sw      r0, 0x0000(v0)          // clears port
        lui     v0, 0x8013              // original line 1

        _end:
        j       _return
        lw      v0, 0x31B8(v0)
    }

    // @ Description
    // This stops music from restarting when changing pages in 1p Mode Menu
    scope stop_restart: {
        OS.patch_start(0x11F110, 0x80133000)
        j        stop_restart
        nop
        _return:
        OS.patch_end()

        beq     t4, at, _music_continues // modified original line 1
        addiu   at, r0, 0x0008           // insert 1p mode menu screen
        beq     t4, at, _music_continues // continue music if on 1p mode menu screen
        nop
        j       _return
        nop

        _music_continues:
        j       0x80133014              // modified original line 1
        lw      ra, 0x001C(sp)          // original line 2
    }

    // RENDERING
    // We replace a bunch of original menu rendering code by making things more generic.

    // @ Description
    // Constants for defining menu button type
    scope button_type {
        constant BIG(0)
        constant SMALL(1)
    }

    // @ Description
    // Overwrite button creation routines starting at 0x80131E34 and ending at 0x80132204.
    // This saves RAM space.
    OS.patch_start(0x11DF44, 0x80131E34)
        // @ Description
        // These tables help render the menu buttons.
        // Each row is size 0x10:
        // 0x00 = (byte) type - see button_type
        // 0x01 = (byte) screen_id to jump to
        // 0x02 = (byte) singleplayer_mode_flag value to set when selected
        // 0x03 = (byte) page_flag value to set when selected
        // 0x04 = (hw) button X, float (loaded with lui)
        // 0x06 = (hw) button Y, float (loaded with lui)
        // 0x08 = (hw) button text X, float (loaded with lui)
        // 0x0A = (hw) button text Y, float (loaded with lui)
        // 0x0C = (word) offset to button text texture
        menu_button_table:
        db button_type.BIG,   0x11, 0x0,                           0x0; dh 0x42F8, 0x41B0, 0x4321, 0x41D0; dw 0x00002A28 // 1P Game
        db button_type.BIG,   0x12, 0x0,                           0x0; dh 0x42C6, 0x4264, 0x42D6, 0x4270; dw 0x00005AC8 // Training
        db button_type.SMALL, 0x13, 0x0,                           0x0; dh 0x429C, 0x42C0, 0x42C2, 0x42C2; dw 0x00005F28 // Bonus 1
        db button_type.SMALL, 0x14, 0x0,                           0x0; dh 0x4282, 0x42EC, 0x42AC, 0x42EE; dw 0x00006388 // Bonus 2
        db button_type.SMALL, 0x14, SinglePlayerModes.BONUS3_ID,   0x0; dh 0x4260, 0x430C, 0x4296, 0x430D; dw 0x000070A8 // Bonus 3
        db button_type.BIG,   0x08, 0x0,                           0x1; dh 0x4210, 0x4328, 0x4248, 0x432B; dw 0x00007FB8 // Remix Modes
        constant PAGE_1_MAX(0x5)

        remix_menu_button_table:
        db button_type.BIG,   0x11, SinglePlayerModes.REMIX_1P_ID, 0x1; dh 0x42F8, 0x41B0, 0x4320, 0x41C8; dw 0x00007838 // Remix 1P
        db button_type.BIG,   0x11, SinglePlayerModes.ALLSTAR_ID,  0x1; dh 0x42C6, 0x4264, 0x42DE, 0x4270; dw 0x00008738 // All-Star
        db button_type.SMALL, 0x14, SinglePlayerModes.MULTIMAN_ID, 0x1; dh 0x429C, 0x42C0, 0x42C2, 0x42C2; dw 0x000067E8 // Multiman
        db button_type.SMALL, 0x14, SinglePlayerModes.CRUEL_ID,    0x1; dh 0x4282, 0x42EC, 0x42AC, 0x42EE; dw 0x00006C48 // Cruel Multiman
        db button_type.SMALL, 0x14, SinglePlayerModes.HRC_ID,      0x1; dh 0x4260, 0x430C, 0x4296, 0x430D; dw 0x00008B88 // HRC
        constant PAGE_2_MAX(0x4)

        // Re-write the 1P Game button creation routine to be generic.
        // It starts at 0x80131E34 (ROM 0x11DF44).
        // @ Arguments
        // a0 - index in menu_button_table
        scope create_menu_button_: {
            addiu   sp, sp, -0x0028             // allocate stack space
            sw      ra, 0x001C(sp)              // save ra
            sw      a0, 0x0020(sp)              // save index in menu_button_table

            or      a0, r0, r0                  // a0 = Global Object ID
            or      a1, r0, r0                  // a1 = routine to run every frame (none)
            addiu   a2, r0, 0x0004              // a2 = group
            jal     Render.CREATE_OBJECT_       // v0 = button object
            lui     a3, 0x8000                  // a3 = display order

            sw      v0, 0x0024(sp)              // save v0

            lw      t6, 0x0020(sp)              // t6 = index in menu_button_table
            sll     t6, t6, 0x0002              // t6 = offset in menu button object array
            li      at, 0x801331A0              // at = menu button object array start
            addu    at, at, t6                  // at = address to store menu button object reference
            sw      v0, 0x0000(at)              // store menu button object reference
            sll     t6, t6, 0x0002              // t6 = offset in menu_button_table
            li      at, menu_button_table
            li      a0, SinglePlayerModes.page_flag
            lw      a0, 0x0000(a0)              // a0 = page_flag
            bnezl   a0, pc() + 8                // if page_flag = 0, use remix modes button table
            addiu   at, remix_menu_button_table - menu_button_table
            addu    at, at, t6                  // at = menu_button_table entry
            sw      at, 0x0018(sp)              // save menu_button_table entry address in stack
            sw      at, 0x0084(v0)              // save menu_button_table entry address on object

            or      a0, v0, r0                  // a0 = object
            li      a1, Render.TEXTURE_RENDER_  // a1 = texture render routine
            addiu   a2, r0, 0x0002              // a2 = room
            addiu   t6, r0, 0xFFFF              // t6 = -1
            sw      t6, 0x0010(sp)              // 0x0010(sp) = -1
            jal     Render.DISPLAY_INIT_        // initialize display object
            lui     a3, 0x8000                  // a3 = display order

            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lbu     t6, 0x0000(at)              // t6 = button_type (0 = big, 1 = small)
            bnez    t6, _small                  // if button_type is small, draw the small button
            lw      a0, 0x0024(sp)              // a0 = button object

            lhu     a1, 0x0004(at)              // a1 = button X, unshifted
            sll     a1, a1, 0x0010              // a1 = button X
            lhu     a2, 0x0006(at)              // a2 = button Y, unshifted
            sll     a2, a2, 0x0010              // a2 = button Y
            jal     0x80131D04                  // init button texture
            addiu   a3, r0, 0x0010              // a3 = ?

            b       _set_button_color
            nop

            _small:
            lui     t7, 0x8013
            lw      t7, 0x3294(t7)              // t7 = button texture file start
            addiu   a1, t7, 0x1108              // a1 = small button texture
            jal     Render.TEXTURE_INIT_        // init small button texture
            lw      a0, 0x0024(sp)              // a0 = button object

            lli     t2, 0x0201                  // t2 = image flags
            sh      t2, 0x0024(v0)              // update image flags

            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lhu     t9, 0x0004(at)              // t9 = button X, unshifted
            sll     t9, t9, 0x0010              // t9 = button X
            sw      t9, 0x0058(v0)              // save X
            lhu     t9, 0x0006(at)              // t9 = button Y, unshifted
            sll     t9, t9, 0x0010              // t9 = button Y
            sw      t9, 0x005C(v0)              // save Y

            _set_button_color:
            lw      a0, 0x0024(sp)              // a0 = button object
            lli     a1, 0x0000                  // a1 = is_selected false
            lui     t7, 0x8013
            lw      t7, 0x31B8(t7)              // t7 = selected button index
            lw      t6, 0x0020(sp)              // t6 = button index
            beql    t6, t7, pc() + 8            // if this button is selected, set is_selected = true
            lli     a1, 0x0001                  // a1 = is_selected true
            jal     0x80131B24                  // set button color
            lw      a2, 0x0020(sp)              // a2 = index

            lw      a0, 0x0024(sp)              // a0 = button object
            lui     t7, 0x8013
            lw      t7, 0x3294(t7)              // t7 = button text texture file start
            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lw      t8, 0x000C(at)              // t8 = offset to menu button text texture
            jal     Render.TEXTURE_INIT_        // init button text texture
            addu    a1, t7, t8                  // at = address of menu button text texture

            lli     t2, 0x0201                  // t2 = image flags
            sh      t2, 0x0024(v0)              // update image flags
            lli     t2, 0x00FF                  // t2 = 0x000000FF (black)
            sw      t2, 0x0028(v0)              // update color

            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lhu     t9, 0x0008(at)              // t9 = button text X, unshifted
            sll     t9, t9, 0x0010              // t9 = button text X
            sw      t9, 0x0058(v0)              // save X
            lhu     t9, 0x000A(at)              // t9 = button text Y, unshifted
            sll     t9, t9, 0x0010              // t9 = button text Y
            sw      t9, 0x005C(v0)              // save Y

            lw      ra, 0x001C(sp)              // restore ra
            jr      ra
            addiu   sp, sp, 0x0028              // deallocate stack space
        }

        // @ Description
        //  Renders the menu buttons
        scope render_menu_buttons_: {
            OS.patch_start(0x11F0D8, 0x80132FC8)
            j       render_menu_buttons_
            nop
            nop
            nop
            nop
            nop
            nop
            nop
            _return:
            OS.patch_end()

            jal     create_menu_button_
            lli     a0, 0x0000                  // a0 = 0 (1P Game/Remix 1P)
            jal     create_menu_button_
            lli     a0, 0x0001                  // a0 = 1 (Training/All-Star)
            jal     create_menu_button_
            lli     a0, 0x0002                  // a0 = 2 (Bonus 1/Multi-man)
            jal     create_menu_button_
            lli     a0, 0x0003                  // a0 = 3 (Bonus 2/Cruel Multi-man)
            jal     create_menu_button_
            lli     a0, 0x0004                  // a0 = 4 (Bonus 3/HRC)

            // only draw on first page
            li      a0, SinglePlayerModes.page_flag
            lw      a0, 0x0000(a0)              // a0 = page_flag
            bnez    a0, _finish                 // if on the 2nd page, don't draw
            nop

            jal     create_menu_button_
            lli     a0, 0x0005                  // a0 = 5 (Remix Modes)

            _finish:
            j       _return
            nop
        }

        // @ Description
        // Modifies cursor wrapping code so that we can select scroll all buttons.
        scope fix_cursor_wrap_: {
            // expand cursor index check, down
            OS.patch_start(0x11EF34, 0x80132E24)
            jal     fix_cursor_wrap_._down
            addiu   at, r0, PAGE_1_MAX              // increase check for wrap
            OS.patch_end()
            OS.patch_start(0x11EF54, 0x80132E44)
            jal     fix_cursor_wrap_._down
            addiu   at, r0, PAGE_1_MAX              // increase check for timer
            OS.patch_end()

            // expand cursor index check, up
            OS.patch_start(0x11EE2C, 0x80132D1C)
            jal     fix_cursor_wrap_._up
            addiu   t9, r0, PAGE_1_MAX              // increase max ID
            OS.patch_end()

            _down:
            li      t5, SinglePlayerModes.page_flag
            lw      t5, 0x0000(t5)                  // t5 = page_flag
            bnezl   t5, pc() + 8                    // if on remix modes, max ID is 0x4
            lli     at, PAGE_2_MAX                  // at = max ID

            jr      ra
            lw      a2, 0x0000(v0)                  // original line 1

            _up:
            li      t5, SinglePlayerModes.page_flag
            lw      t5, 0x0000(t5)                  // t5 = page_flag
            bnezl   t5, pc() + 8                    // if on remix modes, max ID is 0x4
            lli     t9, PAGE_2_MAX                  // t9 = max ID

            jr      ra
            lw      a2, 0x0000(v0)                  // original line 1

        }

        // @ Description
        // Set cursor index correctly when returning from CSS.
        scope set_cursor_index_: {
            OS.patch_start(0x11EA20, 0x80132910)
            j       set_cursor_index_
            lui     v0, 0x800A                      // original line 1
            _return:
            OS.patch_end()

            lbu     v0, 0x4AD1(v0)                  // original line 2 - v0 = previous screen

            lli     t6, 0x0008                      // t6 = 1P Mode screen ID
            beq     t6, v0, _check_page             // if coming from the same screen, check page
            nop
            li      at, SinglePlayerModes.singleplayer_mode_flag
            lw      at, 0x0000(at)                  // at = singleplayer_mode_flag
            bnez    at, _custom                     // if returning from a custom mode, handle differently
            nop                                     // otherwise, continue with original logic
            j       _return
            nop

            _check_page:
            li      at, SinglePlayerModes.page_flag
            lw      at, 0x0000(at)                  // at = page_flag
            beqzl   at, _finish                     // if on page 1, then set cursor to Remix Modes
            lli     t6, PAGE_1_MAX                  // t6 = Remix Modes index
            j       _return                         // otherwise, continue with original logic
            nop

            _custom:
            lli     t6, 0x0000                      // t6 = Remix 1P index
            lli     t7, SinglePlayerModes.REMIX_1P_ID
            beq     at, t7, _finish                 // if Remix 1P, set
            lli     t7, SinglePlayerModes.ALLSTAR_ID
            lli     t6, 0x0001                      // t6 = All-star index
            beq     at, t7, _finish                 // if All-star, set
            lli     t7, SinglePlayerModes.MULTIMAN_ID
            lli     t6, 0x0002                      // t6 = Multi-man index
            beq     at, t7, _finish                 // if Multi-man, set
            lli     t7, SinglePlayerModes.CRUEL_ID
            lli     t6, 0x0003                      // t6 = Cruel Multi-man index
            beq     at, t7, _finish                 // if Cruel Multi-man, set
            nop
            lli     t6, 0x0004                      // t6 = HRC index

            _finish:
            lui     at, 0x8013
            j       0x80132978                      // return to rest of routine
            sw      t6, 0x31B8(at)                  // set cursor index
        }

        // @ Description
        // Checks the page to make sure we go back to page 1 from the Remix Modes page
         scope page_2_exit: {
            OS.patch_start(0x11ED70, 0x80132C60)
            jal     page_2_exit
            addiu   t0, r0, 0x0007                  // original line 2 - t0 = main menu screen ID
            OS.patch_end()

            li      t9, SinglePlayerModes.page_flag
            lw      t6, 0x0000(t9)                  // t6 = page_flag
            addu    t0, t0, t6                      // t0 = main menu if coming from page 1, 1P mode if coming from page 2
            sw      r0, 0x0000(t9)                  // set to page 1
            jr      ra
            lbu     t9, 0x0000(v0)                  // original line 1
        }
    OS.patch_end()

    // @ Description
    // These stop pulling button pointers from the stack, allowing us to extend the original array by 2
    OS.patch_start(0x11EF1C, 0x80132E0C)
    lui     t1, 0x8013
    addu    t1, t1, t0                      // apply offset for index
    jal     0x80131B24                      // original line 3
    lw      a0, 0x31A0(t1)                  // a0 = button object
    OS.patch_end()
    OS.patch_start(0x11EF74, 0x80132E64)
    lui     t6, 0x8013
    addu    t6, t6, t5                      // apply offset for index
    addiu   a1, r0, 0x0001                  // original line 3
    jal     0x80131B24                      // original line 4
    lw      a0, 0x31A0(t6)                  // a0 = button object
    OS.patch_end()
    OS.patch_start(0x11EE68, 0x80132D58)
    lui     t3, 0x8013
    addu    t3, t3, t4                      // apply offset for index
    addiu   a1, r0, 0x0001                  // original line 3
    jal     0x80131B24                      // original line 4
    lw      a0, 0x31A0(t3)                  // a0 = button object
    OS.patch_end()
    OS.patch_start(0x11EE14, 0x80132D04)
    lui     t8, 0x8013
    addu    t8, t8, t7                      // apply offset for index
    jal     0x80131B24                      // original line 3
    lw      a0, 0x31A0(t8)                  // a0 = button object
    OS.patch_end()

    // @ Description
    // Fixes cursor highlight check to be based off type rather than index.
    OS.patch_start(0x11DCC0, 0x80131BB0)
    or      a1, r0, r0                      // original line 2
    lw      at, 0x0084(a3)                  // at = menu_button_table entry
    lbu     at, 0x0000(at)                  // at = button_type
    lli     v1, 0x0003                      // v1 = 3 when button_type is BIG
    bnezl   at, pc() + 8                    // if button_type is not BIG, then use SMALL
    lli     v1, 0x0001                      // v1 = 1 when button_type is SMALL
    nop
    OS.patch_end()

    // @ Description
    // Overwrite button click handler routine starting at 0x80132AE0 and ending at 0x80132C48.
    // This saves RAM space.
    OS.patch_start(0x11EBF0, 0x80132AE0)
    // v0 = button index
    sll     at, v0, 0x0002                  // at = offset to button object
    lui     a0, 0x8013
    addu    a0, a0, at                      // adjust for offset
    lw      a0, 0x31A0(a0)                  // a0 = button object

    lw      at, 0x0084(a0)                  // at = menu_button_table entry
    sw      at, 0x002C(sp)                  // save to stack

    addiu   a1, r0, 0x0002                  // a1 = highlight type clicked
    jal     0x80131B24                      // update button highlight
    or      a2, r0, v0                      // a2 = button index

    jal     0x800269C0                      // play FGM
    addiu   a0, r0, 0x009E

    lw      at, 0x002C(sp)                  // at = menu_button_table entry
    lbu     t1, 0x0002(at)                  // t1 = value to set singleplayer_mode_flag to
    li      v0, SinglePlayerModes.singleplayer_mode_flag
    sw      t1, 0x0000(v0)                  // update singleplayer_mode_flag
    lbu     t1, 0x0003(at)                  // t1 = value to set page_flag to
    li      v0, SinglePlayerModes.page_flag
    sw      t1, 0x0000(v0)                  // update page_flag

    lui     v0, 0x800A
    lw      t1, 0x0024(sp)
    addiu   v0, v0, 0x4AD0                  // v0 = address of current screen
    lbu     t9, 0x0000(v0)                  // t9 = current screen
    lbu     t0, 0x0001(at)                  // t0 = screen to jump to
    addiu   t2, t1, 0xFFFF
    sb      t0, 0x0000(v0)                  // update next screen
    sb      t2, 0x0013(v0)
    addiu   t3, r0, 0x0001
    lui     at, 0x8013
    sb      t9, 0x0001(v0)                  // update prev screen
    b       0x80132E8C                      // finish
    sw      t3, 0x31C0(at)
    OS.patch_end()

    // @ Description
    // Loads in the KO amount for the selected character in Multiman and Cruel Multiman Modes
    // or distance (ft) for HRC
    scope _ko_amount_or_feet: {
        OS.patch_start(0x149B74, 0x80133B44)
        j        _ko_amount_or_feet
        addiu    t0, r0, SinglePlayerModes.MULTIMAN_ID   // insert multiman mode flag
        _return:
        OS.patch_end()

        li      t9, SinglePlayerModes.singleplayer_mode_flag    // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        beq     t9, t0, _multiman           // if multiman, skip
        addiu   t0, r0, SinglePlayerModes.CRUEL_ID

        beq     t9, t0, _cruel              // if cruel multiman, skip
        addiu   t0, r0, SinglePlayerModes.HRC_ID

        beq     t9, t0, _hrc                // if HRC, skip
        addiu   t0, r0, 0x0001              // original line 2

        j       _return
        addiu    t9, r0, 0x0002             // original line 1, sets amount of digits

        _cruel:
        li      t9, Character.CRUEL_HIGH_SCORE_TABLE
        j       _cruel_2
        nop

        _multiman:
        li      t9, Character.MULTIMAN_HIGH_SCORE_TABLE
        _cruel_2:
        sll     a0, a0, 0x0002              // a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
        addu    t9, t9, a0
        addiu   t0, r0, 0x0001              // original line 2
        lw      v0, 0x0000(t9)              // loads number of KO's the character has had
        j       _return
        addiu   t9, r0, 0x0005              // t9 sets the amount of digits at 5

        _hrc:
        li      t9, Character.HRC_HIGH_SCORE_TABLE
        sll     a0, a0, 0x0002              // a0 = offset to high score for character
        addu    t9, t9, a0                  // t9 = address of high score
        addiu   t0, r0, 0x0001              // original line 2
        lw      v0, 0x0000(t9)              // loads total feet for the character
        j       _return
        addiu   t9, r0, 0x0007              // t9 sets the amount of digits at 7
    }

    // @ Description
    //    Loading in the finish time for the selected character
    scope load_bonus3_time: {
    OS.patch_start(0x14978C, 0x8013375C)
        j        load_bonus3_time
        addiu   a2, r0, SinglePlayerModes.BONUS3_ID            // insert bonus 3 mode ID
        _return:
        OS.patch_end()

        li      a1, SinglePlayerModes.singleplayer_mode_flag   // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 1 if Bonus 3
        bne     a1, a2, _original           // if normal, skip
        nop

        li      a2, Character.BONUS3_HIGH_SCORE_TABLE
        li      v1, Bonus.REMIX_BONUS3_HIGH_SCORE_TABLE
        OS.read_word(Bonus.mode, v0)        // v0 = 0 if Normal, 1 if Remix
        bnezl   v0, pc() + 8                // if Remix, use Remix table
        or      a2, v1, r0                  // a2 = remix table

        sll     a0, a0, 0x0002              // a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
        addu    a2, a2, a0
        lw      v0, 0x0000(a2)              // loads finish time the character has had
        lw      v1, 0x0000(a2)              // loads finish time the character has had

        _original:
        sw        v0, 0x0040(sp)            // original line 1
        j        _return
        or        a0, r0, r0
    }

    // @ Description
    //    Prevents a branch that is typically used to shift from platform counting to time display after completion
    scope _timedisplay_skip: {
        OS.patch_start(0x149C14, 0x80133BE4)
        j        _timedisplay_skip
        addiu    t9, r0, SinglePlayerModes.BONUS3_ID
        _return:
        OS.patch_end()

        li      t7, SinglePlayerModes.singleplayer_mode_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if Bonus 3
        beq     t7, t9, _time_count         // jump to time if Bonus 3
        nop
        bnez    t7, _platform_count         // if multiman, skip
        nop

        beq     v0, r0, _platform_count     // modified original line 1
        nop

        _time_count:
        j       _return
        nop

        _platform_count:
        j       0x80133BFC                  // modified original line 1
        nop
    }

    // @ Description
    // This adds total KOs to the multiman screens, or total feet to the HRC screen.
    scope total_kos_or_feet_: {
        // The check on other bonus CSS screens for showing the total line
        OS.patch_start(0x14CCC8, 0x80136C98)
        jal     total_kos_or_feet_._check
        or      s0, r0, r0                  // original line 1
        OS.patch_end()
        // Just after the TOTAL texture is rendered
        OS.patch_start(0x149D4C, 0x80133D1C)
        jal     total_kos_or_feet_._total_texture
        sb      t5, 0x002A(v0)              // original line 1
        OS.patch_end()

        _check:
        addiu   s1, r0, 0x000C              // original line 2

        // let's always show the total for multiman, so return 1 for v0 in that case
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw         t6, 0x0000(t6)           // t0 = single player mode flag
        lli     at, SinglePlayerModes.MULTIMAN_ID
        beq     t6, at, _show_total         // if multiman mode, show total
        lli     at, SinglePlayerModes.CRUEL_ID
        beq     t6, at, _show_total         // if cruel multiman mode, show total
        lli     at, SinglePlayerModes.HRC_ID
        beq     t6, at, _show_total         // if HRC, show total
        nop
        jr      ra                          // otherwise continue normally
        nop

        _show_total:
        // jump to where they set v0 to 1
        j       0x80136CC0
        nop

        _total_texture:
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)              // t0 = single player mode flag
        lli     at, SinglePlayerModes.MULTIMAN_ID
        beq     t6, at, _multiman           // if multiman mode, draw total
        lli     at, SinglePlayerModes.CRUEL_ID
        beq     t6, at, _cruel              // if cruel multiman mode, draw total
        lli     at, SinglePlayerModes.HRC_ID
        beq     t6, at, _hrc                // if HRC, draw total
        nop
        jr      ra
        swc1    f4, 0x005C(v0)              // original line 2

        _multiman:
        li      t0, Character.MULTIMAN_HIGH_SCORE_TABLE
        j       _draw_textures
        lli     t9, 0x0006                  // t9 = number of digits

        _hrc:
        li      t0, Character.HRC_HIGH_SCORE_TABLE
        j       _draw_textures
        lli     t9, 0x0008                  // t9 = number of digits

        _cruel:
        li      t0, Character.CRUEL_HIGH_SCORE_TABLE
        lli     t9, 0x0006                  // t9 = number of digits

        _draw_textures:
        swc1    f6, 0x005C(v0)              // update y
        lli     at, 0x0018                  // at = new width
        sh      at, 0x0014(v0)              // update width (just will be "TOTAL")
        lui     at, 0x436B                  // at = new x position
        sw      at, 0x0058(v0)              // update x position

        // now draw number of kos
        or      a0, r0, s0                  // a0 = texture object
        lli     a1, 0x0000                  // a1 = total ko's/feet
        lli     at, 0x0000                  // at = character ID

        _loop:
        sll     t1, at, 0x0002              // t1 = offset to next character ko count
        addu    t1, t0, t1                  // t1 = next ko count/feet
        lw      t1, 0x0000(t1)              // t1 = ko count/feet for character at index at
        li      t8, 0xAAAAAAAA              // TEMP FIX for how console writes AAAAAAAA to added SRAM spots and causes issues
        beql    t1, t8, _update
        addiu   t1, r0, r0
        _update:
        addu    a1, a1, t1                  // update total ko count/feet
        addiu   at, at, 0x0001              // at++
        sltiu   t1, at, Character.NUM_CHARACTERS // t1 = 0 if we counted everyone
        bnez    t1, _loop                   // keep looking if we haven't counted everyone
        nop

        lui     a2, 0x4361                  // a2 = x position (right justified)
        lui     a3, 0x434D                  // a3 = y position
        addiu   t8, sp, 0x0034              // t8 = pointer to palette details
        sw      r0, 0x0000(t8)              // R = 0 for palette
        sw      r0, 0x0004(t8)              // G = 0 for palette
        sw      r0, 0x0008(t8)              // B = 0 for palette
        lli     at, 0x0007E                 // R = 7E for color
        sw      at, 0x000C(t8)              // ~
        lli     at, 0x0007C                 // G = 7C for color
        sw      at, 0x0010(t8)              // ~
        lli     at, 0x00077                 // B = 77 for color
        sw      at, 0x0014(t8)              // ~
        sw      t8, 0x0010(sp)              // save palette details pointer in stack (argument for 0x80131CEC)
        sw      t9, 0x0014(sp)              // save number of digits in stack (argument for 0x80131CEC)
        addiu   t0, r0, 0x0001              // t0 = ?
        jal     0x80131CEC                  // draw total ko count/feet
        sw      t0, 0x0018(sp)              // save t0 in stack (argument for 0x80131CEC)

        j       0x80133F38                  // skip to end
        nop
    }

    // @ Description
    // This displays HRC high scores to the tenth of a foot
    scope draw_hrc_high_score_decimal_: {
       OS.patch_start(0x149BA4, 0x80133B74)
       j       draw_hrc_high_score_decimal_
       lli     at, SinglePlayerModes.HRC_ID
       OS.patch_end()

       OS.patch_start(0x149F74, 0x80133F44)
       j       draw_hrc_high_score_decimal_
       lli     at, SinglePlayerModes.HRC_ID
       OS.patch_end()

       li      t0, SinglePlayerModes.singleplayer_mode_flag
       lw      t0, 0x0000(t0)                // t0 = singleplayer_mode_flag
       bne     t0, at, _end                  // if not singleplayer mode, skip
       nop

       // a0 = position struct of score label, or 0
       beqz    a0, _end                      // if a0 is not a position struct, skip
       lui     t1, 0x4080                    // t1 = 4, floating point
       mtc1    t1, f2                        // f2 = 4
       lw      at, 0x0004(a0)                // at = object
       lw      at, 0x0074(at)                // at = label position struct
       lw      at, 0x0008(at)                // at = last digit position struct
       lwc1    f0, 0x0058(at)                // t0 = X position
       add.s   f0, f0, f2                    // f0 = shifted X position
       swc1    f0, 0x0058(at)                // update X position

       // now draw decimal point
       addiu   sp, sp, -0x0030               // allocate stack space
       sw      ra, 0x0004(sp)                // save ra
       li      a1, 0x80137DF8                // a1 = pointer to array of file pointers
       lw      a1, 0x0024(a1)                // a1 = numbers file pointer
       addiu   a1, a1, 0x08D8                // a1 = RAM address for colon
       jal     Render.TEXTURE_INIT_
       lw      a0, 0x0004(a0)                // a0 = high score object
       lw      ra, 0x0004(sp)                // restore ra
       addiu   sp, sp, 0x0030                // restore stack space

       li      t0, 0x7E7C77FF                // t0 = color
       sw      t0, 0x0028(v0)                // set color
       lli     t0, 0x0201                    // t0 = render flags (blur)
       sh      t0, 0x0024(v0)                // set render flags
       lui     t0, 0x4358                    // t0 = X position
       sw      t0, 0x0058(v0)                // set X position
       lw      t0, 0x000C(v0)                // t0 = previously drawn digit
       lwc1    f0, 0x005C(t0)                // f0 = Y position, unadjusted
       lui     t0, 0x40A0                    // t0 = 5, floating point
       mtc1    t0, f2                        // f2 = 5
       add.s   f0, f0, f2                    // f0 = shifted Y position
       swc1    f0, 0x005C(v0)                // set Y position
       lli     t0, 0x0005                    // t0 = 5
       sh      t0, 0x003C(v0)                // set height so we get a period instead of a colon

       _end:
       jr      ra                            // original line 1
       nop                                   // original line 2
    }

    // @ Description
    // This alters the image that is loaded besides what would normally be the amount of platforms (or targets)
    scope counter_graphic: {
        OS.patch_start(0x149B10, 0x80133AE0)
        j        counter_graphic
        lw      t9, 0x7E0C(t9)              // original line 1
        _return:
        OS.patch_end()

        li      t0, SinglePlayerModes.singleplayer_mode_flag // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 1 if Bonus 3
        lli     a1, SinglePlayerModes.HRC_ID
        beql    t0, a1, _alt_image          // if HRC, load different image
        addiu   t0, r0, 0x3C08              // this moves the file offset so it loads the added KO image instead of platforms
        bnezl   t0, _alt_image              // if multiman or cruel multiman, load different image
        addiu   t0, r0, 0x34E8              // this moves the file offset so it loads the added KO image instead of platforms

        j       _return
        addiu   t0, r0, 0x1898              // modified original line 2

        _alt_image:
        j       _return
        nop
    }

    // @ Description
    // This alters the image that is loaded as the header in Bonus CSS 2
    scope header_graphic: {
        OS.patch_start(0x1492CC, 0x8013329C)
        j        header_graphic
        lw      t0, 0x7E04(t0)                // original line 1
        _return:
        OS.patch_end()

        li      t1, SinglePlayerModes.singleplayer_mode_flag       // t1 = multiman flag
        lw      t1, 0x0000(t1)              // t1 = 2 if multiman
        addiu   t6, r0, SinglePlayerModes.BONUS3_ID
        beq     t1, t6, _bonus3
        addiu   t6, r0, SinglePlayerModes.MULTIMAN_ID
        beq     t1, t6, _multiman
        addiu   t6, r0, SinglePlayerModes.CRUEL_ID
        beq     t1, t6, _cruel
        addiu   t6, r0, SinglePlayerModes.HRC_ID
        beq     t1, t6, _hrc
        addiu   t6, r0, r0                  // clear our t6 in abundance of caution

        j        _return
        addiu   t1, r0, 0x1058              // modified original line 2

        _bonus3:
        j        _return
        addiu    t1, r0, 0x1DD8             // this moves the file offset so it loads the added header image instead of original

        _multiman:
        j        _return
        addiu    t1, r0, 0x14D8             // this moves the file offset so it loads the added header image instead of original

        _cruel:
        j       _return
        addiu   t1, r0, 0x1958              // this moves the file offset so it loads the added header image instead of original

        _hrc:
        j       _return
        addiu   t1, r0, 0x24C8              // this moves the file offset so it loads the added header image instead of original
    }

    // @ Description
    // This alters the image that is loaded as the header in Remix 1p
    scope header_graphic_remix_1p: {
        OS.patch_start(0x13C5DC, 0x801343DC)
        j       header_graphic_remix_1p
        addiu   t6, r0, SinglePlayerModes.ALLSTAR_ID         // Remix ID inserted
        _return:
        OS.patch_end()

        li      t0, SinglePlayerModes.singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 2 if multiman
        beq     t6, t0, _allstar            // branch if Allstar and should use custom texture
        addiu   t6, r0, SinglePlayerModes.REMIX_1P_ID         // Remix ID inserted
        bne     t6, t0, _normal             // branch if not Remix 1p and should use standard 1p Game texture
        lui     t0, 0x0000                  // original line 1

        j       _return
        addiu    t0, t0, 0x3758             // this moves the file offset so it loads the added header image instead of original

        _normal:
        j       _return
        addiu    t0, t0, 0x0228             // original line 2, sets file offset to normal 1p Game texture

        _allstar:
        lui     t0, 0x0000                  // original line 1
        j       _return
        addiu    t0, t0, 0x39C8             // this moves the file offset so it loads the added header image instead of original
    }

    // @ Description
    // When entering a bonus css, this sets a new flag in the original bonus mode flag area so that proper header switching can take place
    scope set_original_flag: {
        OS.patch_start(0x14CC2C, 0x80136BFC)
        j       set_original_flag
        lui     at, 0x8013                 // original line 1
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)
        li      t0, SinglePlayerModes.singleplayer_mode_flag       // at = added mode id
        lw      t0, 0x0000(t0)              // load in mode flag
        beql    t0, r0, _end                // if original, skip
        sw      t4, 0x7714(at)              // original line 2, saves to original flag location

        addiu   t3, r0, SinglePlayerModes.BONUS3_ID
        addiu   t1, r0, 0x0002
        beql    t0, t3, _end                // branch to end if going to Bonus 3
        sw      t1, 0x7714(at)              // save bonus 3 to original flag system
        addiu   t3, r0, 0x0003
        beql    t0, t1, _end                // branch to end if going to Multiman
        sw      t3, 0x7714(at)              // save multiman to original flag system
        addiu   t1, r0, 0x0004
        sw      t1, 0x7714(at)              // save cruel to original flag system

        _end:
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop
    }

    // @ Description
    // When swapping modes this sets to the correct flag
    scope set_original_flag_swap: {
        OS.patch_start(0x14B91C, 0x801358EC)
        nop
        j       set_original_flag_swap
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)

        beqz    t6, _end
        addiu   t0, r0, SinglePlayerModes.BONUS3_ID
        li      t3, SinglePlayerModes.singleplayer_mode_flag
        beq     t6, t0, _bonus2_to_bonus3    // since we're transitioning from 2 to 3, we take this branch
        nop

        lw      t0, 0x0000(t3)
        addiu   t1, r0, SinglePlayerModes.MULTIMAN_ID
        beq     t0, t1, _multiman_to_cruel
        addiu   t1, r0, SinglePlayerModes.CRUEL_ID
        beq     t1, t0, _cruel_to_multiman
        addiu   t1, r0, SinglePlayerModes.HRC_ID
        beq     t1, t0, _hrc
        nop

        sw      r0, 0x0000(t3)              // since we're transition from bonus 3 to bonus 1, lets remove multiman flags
        j       _end
        sw      r0, 0x0000(v0)              // since we're transitioning from bonus 3, to bonus 1, lets restart the original index

        _hrc:
        // if we're here, let's not toggle anything
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t3, 0x000C(sp)              // ~
        j       0x80135940                  //
        addiu   sp, sp, 0x0010              // deallocate stack space

        _multiman_to_cruel:
        addiu    t0, r0, 0x0004
        sw        t0, 0x0000(v0)            // save bonus 3 new index to original flag location
        addiu    t0, r0, SinglePlayerModes.CRUEL_ID
        j        _end
        sw        t0, 0x0000(t3)            // save cruel flag to multiman mode flag

        _cruel_to_multiman:
        addiu   t0, r0, 0x0003
        sw      t0, 0x0000(v0)              // save bonus 3 new index to original flag location
        addiu   t0, r0, SinglePlayerModes.MULTIMAN_ID
        j       _end
        sw      t0, 0x0000(t3)              // save multiman flag to multiman mode flag

        _bonus2_to_bonus3:
        addiu   t0, r0, 0x0002
        sw      t0, 0x0000(v0)              // save bonus 3 new index to original flag location
        addiu   t0, r0, SinglePlayerModes.BONUS3_ID
        sw      t0, 0x0000(t3)              // save bonus 3 flag to multiman mode flag

        _end:
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80009A84                  // original line 1
        lw      a0, 0x7718(a0)              // original line 2
        j       _return
        nop
    }

    // Changes the "BOARD THE PLATFORMS" FGM Call
    scope _BTP_FGM_alter: {
        OS.patch_start(0x149340, 0x80133310)
        j        _BTP_FGM_alter
        addiu   t6, r0, SinglePlayerModes.BONUS3_ID
        _return:
        OS.patch_end()

        li      at, SinglePlayerModes.singleplayer_mode_flag       // a0 = multiman flag
        lw      at, 0x0000(at)              // a0 = 2 if multiman

        beq     at, t6, _announce
        addiu   a0, r0, 0x01EF              // replace original with Race to the Finish!

        addiu   t6, r0, SinglePlayerModes.MULTIMAN_ID
        beq     at, t6, _announce           // if multiman jump
        addiu   a0, r0, 0x03C7              // replace original with Multiman

        addiu   t6, r0, SinglePlayerModes.CRUEL_ID
        beq     at, t6, _announce           // if multiman jump
        addiu   a0, r0, 0x03C8              // replace original with Multiman

        addiu   t6, r0, SinglePlayerModes.HRC_ID
        beq     at, t6, _announce           // if HRC jump
        addiu   a0, r0, FGM.announcer.css.HRC // replace original with HRC

        // load call as normal if do not take other branches
        addiu   a0, r0, 0x01DC              // original line 2

        _announce:
        jal     0x800269C0                  // original line 1
        nop
        j       _return
        nop
    }

    //  Changes the "CHOOSE YOUR CHARACTER" FGM Call
    scope _1P_FGM_alter: {
        OS.patch_start(0x14073C, 0x8013853C)
        j        _1P_FGM_alter
        addiu   t6, r0, SinglePlayerModes.ALLSTAR_ID
        _return:
        OS.patch_end()

        li      at, SinglePlayerModes.singleplayer_mode_flag       // a0 = multiman flag
        lw      at, 0x0000(at)              // a0 = 2 if multiman

        beq     at, t6, _announce
        addiu   a0, r0, FGM.announcer.css.ALLSTAR // replace original with ALLSTAR

        // load call as normal if do not take other branches
        addiu   a0, r0, 0x01DF              // original line 2

        _announce:
        jal     0x800269C0                  // original line 1
        nop
        j       _return
        nop
    }

    scope _1P_unplugged_b_handler: {
        // 1P Mode
        OS.patch_start(0x13EF30, 0x80136D30)
        jal         _1P_unplugged_b_handler
        nop
        OS.patch_end()
        // Training
        OS.patch_start(0x144E24, 0x80135844)
        jal        _1P_unplugged_b_handler
        nop
        OS.patch_end()
        // Bonus
        OS.patch_start(0x14B808, 0x801357D8)
        jal        _1P_unplugged_b_handler
        nop
        OS.patch_end()

        // a0 = current player in 1P CSS
        li      t9, 0x800451A4              // t9 = address of port states
                                            // note: this value shifts dynamically, with active ports in order on left...
                                            // ...so we need to check them all (unplugged ports have value -1)
        lb      t8, 0x0000(t9)              // t8 = -1 if no ports are plugged in; otherwise it is first active slot number
        bltz    t8, _end                    // branch if no ports to check
        nop
        beq     t8, a0, _end                // branch if current player's port is plugged in
        lb      t8, 0x0001(t9)              // ~
        beq     t8, a0, _end                // branch if current player's port is plugged in
        lb      t8, 0x0002(t9)              // ~
        beq     t8, a0, _end                // branch if current player's port is plugged in
        lb      t8, 0x0003(t9)              // ~
        beq     t8, a0, _end                // branch if current player's port is plugged in
        nop

        // if we're here, it is unplugged, so we check to see if any players are pressing B
        or      t9, r0, r0                  // clear t9
        _check_b_loop:
        slti    t8, t9, 0x1F                // t8 = 1 if less than 31 (port 4)
        beqz    t8, _end                    // branch if no more ports to check
        lui     t8, 0x8004                  // original line above 1 (in SinglePlayerEnemy.asm)
        addu    t8, t8, t9                  // t8 = t8 + offset
        lhu     t8, 0x522A(t8)              // original line 1 (t8 = pressed button mask)
        andi    t8, t8, 0x4000              // original line 2 (t9 = 0 if B is not pressed)
        bnez    t8, _end_alt                // branch if B was pressed
        nop
        b       _check_b_loop               // loop
        addiu   t9, t9, 0x0A                // t9 = offset to next port

        // if we're here, proceed as normal
        _end:
        lui     t8, 0x8004                  // original line above 1 (in SinglePlayerEnemy.asm)
        addu    t8, t8, t7                  // original line above 2 ~
        lhu     t8, 0x522A(t8)              // original line 1 (t8 = pressed button mask)
        andi    t9, t8, 0x4000              // original line 2 (t9 = 0 if B is not pressed)
        jr      ra
        nop

        _end_alt:
        lui     t8, 0x8004                  // restore registers as they normally would be, just to be safe
        addu    t8, t8, t7                  // ~
        lhu     t8, 0x522A(t8)              // ~
        addiu   t9, r0, 1                   // t9 = 1 (pressed B is true)
        jr      ra
        nop
    }
}
