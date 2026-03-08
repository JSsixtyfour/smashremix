// VsRemixMenu.asm
if !{defined __VS_REMIX_MENU__} {
define __VS_REMIX_MENU__()
print "included VsRemixMenu.asm\n"

// @ Description
// This file allows for a VS menu for Remix modes

scope VsRemixMenu {

    // Modes
    scope mode {
        constant DEFAULT(0x0)
        constant TWELVE_CB(0x1)
        constant TAG_TEAM(0x2)
        constant KOTH(0x3)
        constant SMASHKETBALL(0x4)
        constant TUG_OF_WAR(0x5)
    }

    page_flag:
    dw 0;

    // Flag for VS Modes
    vs_mode_flag:
    dw mode.DEFAULT;

    // @ Description
    // The game mode setting as set on VS Mode menu before entering CSS
    global_game_mode:
    dw 1

    // @ Description
    // The time setting as set on VS Mode menu before entering CSS
    global_time:
    dw 8

    // @ Description
    // The stocks setting as set on VS Mode menu before entering CSS
    global_stocks:
    dw 8

    // @ Description
    // The teams flag as set on VS Mode menu before entering CSS
    global_teams:
    dw OS.FALSE

    // @ Description
    // The stage select flag before entering CSS
    global_stage_select:
    dw OS.TRUE

    // @ Description
    // The stage value stored before entering CSS
    global_stage:
    dw Stages.id.PEACHS_CASTLE

    // @ Description
    // The stockmode_table values stored before entering CSS
    global_stockmode_table:
    dw 0, 0, 0, 0

    // @ Description
    // The stock_count_table values stored before entering CSS
    global_stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // The previous_stock_count_table values stored before entering CSS
    global_previous_stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // These tables help render the menu buttons.
    // Each row is size 0x10:
    // 0x00 = (word) routine to create button, or 0 if generic
    // 0x04 = (byte) screen to jump to
    // 0x05 = (byte) vs_mode_flag value to set when selected
    // 0x06 = (byte) page_flag value to set when selected
    // 0x07 = (byte) TwelveCharBattle.twelve_cb_flag value to set when selected
    // 0x08 = (hw) button text X, float (loaded with lui)
    // 0x0A = (hw) button text Y, float (loaded with lui)
    // 0x0C = (word) offset to button text texture
    menu_button_table:
    dw 0;           db 0x10, mode.DEFAULT,      0x0, 0x0; dh 0x4319, 0x4210; dw 0x000024C8 // VS Start
    dw 0x80132A4C;  db 0x00, mode.DEFAULT,      0x0, 0x0; dh 0x42D8, 0x4296; dw 0x00002748 // Rule
    dw 0x80132D04;  db 0x00, mode.DEFAULT,      0x0, 0x0; dh 0x42C2, 0x42E2; dw 0x00000000 // Time Stock
    dw 0;           db 0x0A, mode.DEFAULT,      0x0, 0x0; dh 0x428E, 0x4317; dw 0x00003828 // VS Options
    dw 0;           db 0x09, mode.DEFAULT,      0x1, 0x0; dh 0x4238, 0x433E; dw 0x000075B8 // Remix Modes
    constant PAGE_1_MAX(0x4)

    remix_menu_button_table:
    dw 0;           db 0x10, mode.TWELVE_CB,    0x1, 0x1; dh 0x4304, 0x4210; dw 0x00006760 // 12cb
    dw 0;           db 0x10, mode.TAG_TEAM,     0x1, 0x0; dh 0x4305, 0x4292; dw 0x00007D38 // Tag Team
    dw 0;           db 0x10, mode.KOTH,         0x1, 0x0; dh 0x42AA, 0x42E0; dw 0x000084B8 // King of the Hill
    dw 0;           db 0x10, mode.SMASHKETBALL, 0x1, 0x0; dh 0x428E, 0x4317; dw 0x00008C38 // Smashketball
    dw 0;           db 0x10, mode.TUG_OF_WAR,   0x1, 0x0; dh 0x4260, 0x433E; dw 0x000093B8 // Tug of War
    constant PAGE_2_MAX(0x4)

    // @ Description
    // The following patches enable a new button on the VS Game Mode menu (on page 1)
    scope add_button_: {
        // Adjust max index from 3 to 4 when pressing up
        OS.patch_start(0x124828, 0x80133E78)
        jal     add_button_._wrap_fix_up
        lw      v0, 0x0000(v1)              // original line 1 - v0 = cursor index
        OS.patch_end()
        // Adjust max index from 3 to 4 when pressing down
        OS.patch_start(0x124990, 0x80133FE0)
        jal     add_button_._wrap_fix_down
        lw      v0, 0x4948(v0)              // original line 1 - v0 = cursor index
        OS.patch_end()
        // Adjust scroll wrap pause time index check from 3 to 4 when pressing down
        OS.patch_start(0x12495C, 0x80133FAC)
        jal     add_button_._wrap_fix_down_timer
        lw      v0, 0x4948(v0)              // original line 1 - v0 = cursor index
        OS.patch_end()

        // This adds the new button's object pointer to the stack (makes GObj** buttons[/* */] be length 5 instead of length 4)
        OS.patch_start(0x12456C, 0x80133BBC)
        jal     add_button_
        lui     v1, 0x8013                  // original line 1
        OS.patch_end()

        li      t0, 0x80134940              // t0 = address of new button object pointer
        sw      t0, 0x0010(t6)              // save it to the stack

        jr      ra
        addiu   v1, v1, 0x4980              // original line 2

        _wrap_fix_up:
        jr      ra
        addiu   t7, r0, 0x0004              // t7 = 4 = max button index

        _wrap_fix_down:
        jr      ra
        addiu   at, r0, 0x0004              // at = 4 = max button index

        _wrap_fix_down_timer:
        jr      ra
        addiu   at, r0, 0x0003              // at = 4 = max button index
    }

    // @ Description
    // Overwrite button creation routine starting at 0x80132154 and ending at 0x80132238, as well as 0x80132EBC - 0x80132FD8.
    // This saves RAM space.
    OS.patch_start(0x122B04, 0x80132154)
        button_positions:
        dh 0x42F0, 0x41F8; // 1
        dh 0x42C2, 0x428C; // 2
        dh 0x4294, 0x42DA; // 3
        dh 0x424C, 0x4314; // 4
        dh 0x41E0, 0x433B; // 5

        // Re-write the 1P Game button creation routine to be generic.
        // It starts at 0x80131E34 (ROM 0x11DF44).
        // @ Arguments
        // a0 - index in menu_button_table
        scope create_menu_button_: {
            addiu   sp, sp, -0x0028             // allocate stack space
            sw      ra, 0x001C(sp)              // save ra
            sw      a0, 0x0020(sp)              // save index in menu_button_table

            sll     t6, a0, 0x0004              // t6 = offset in menu_button_table
            li      at, menu_button_table
            li      a0, page_flag
            lw      a0, 0x0000(a0)              // a0 = page_flag
            bnezl   a0, pc() + 8                // if page_flag = 0, use remix modes button table
            addiu   at, remix_menu_button_table - menu_button_table
            addu    at, at, t6                  // at = menu_button_table entry
            sw      at, 0x0018(sp)              // save menu_button_table entry address in stack

            lw      at, 0x0000(at)              // at = button creation routine, or 0
            beqz    at, _generic_creation       // if no button routine, use generic creation routine
            nop

            jalr    at                          // call button routine
            nop

            b       _finish                     // skip the rest of the routine
            nop

            _generic_creation:
            j       create_button_generic_
            nop

            _finish:
            lw      ra, 0x001C(sp)              // restore ra
            jr      ra
            addiu   sp, sp, 0x0028              // deallocate stack space
        }
    OS.patch_end()
    OS.patch_start(0x12386C, 0x80132EBC)
        // @ Description
        // Had to split things up
        scope create_button_generic_: {
            or      a0, r0, r0                  // a0 = Global Object ID
            or      a1, r0, r0                  // a1 = routine to run every frame (none)
            addiu   a2, r0, 0x0004              // a2 = group
            jal     Render.CREATE_OBJECT_       // v0 = button object
            lui     a3, 0x8000                  // a3 = display order

            sw      v0, 0x0024(sp)              // save v0

            lw      t6, 0x0020(sp)              // t6 = index in menu_button_table
            sll     t6, t6, 0x0002              // t6 = offset in menu button object array
            li      at, 0x80134930              // at = menu button object array start
            addu    at, at, t6                  // at = address to store menu button object reference
            sw      v0, 0x0000(at)              // store menu button object reference
            lw      at, 0x0018(sp)              // at = menu_button_table entry address
            sw      at, 0x0084(v0)              // save menu_button_table entry address on object

            or      a0, v0, r0                  // a0 = object
            li      a1, Render.TEXTURE_RENDER_  // a1 = texture render routine
            addiu   a2, r0, 0x0002              // a2 = room
            addiu   t6, r0, 0xFFFF              // t6 = -1
            sw      t6, 0x0010(sp)              // 0x0010(sp) = -1
            jal     Render.DISPLAY_INIT_        // initialize display object
            lui     a3, 0x8000                  // a3 = display order

            li      at, button_positions        // at = button_positions
            lw      t6, 0x0020(sp)              // t6 = index in button_positions
            sll     t6, t6, 0x0002              // t6 = offset inbutton_positions
            addu    at, at, t6                  // at = address in button_positions
            lw      a0, 0x0024(sp)              // a0 = button object

            lhu     a1, 0x0000(at)              // a1 = button X, unshifted
            sll     a1, a1, 0x0010              // a1 = button X
            lhu     a2, 0x0002(at)              // a2 = button Y, unshifted
            sll     a2, a2, 0x0010              // a2 = button Y
            jal     0x80132024                  // mnVSModeMakeButton()
            addiu   a3, r0, 0x0011              // a3 = width

            lui     t7, 0x8013
            lw      t7, 0x4948(t7)              // t7 = cursor index
            lw      a0, 0x0020(sp)              // a0 = index in menu_button_table
            or      a1, r0, r0                  // a1 = button_status (0 = default; 1 = highlighted; 2 = selected)
            beql    t7, a0, pc() + 8            // if this button should be highlighed, then set it
            lli     a1, 0x0001                  // a1 = button_status highlighed
            jal     0x80131F4C                  // mnVSModeUpdateButton()
            lw      a0, 0x0024(sp)              // a0 = button object

            lw      a0, 0x0024(sp)              // a0 = button object
            lui     t8, 0x8013
            lw      t8, 0x4A4C(t8)              // t8 = file 0x006 start
            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lw      t9, 0x000C(at)              // t9 = button text offset
            jal     Render.TEXTURE_INIT_        // draw button text texture
            addu    a1, t8, t9                  // a1 = address of text texture

            lli     t2, 0x0201                  // t2 = image flags
            sh      t2, 0x0024(v0)              // update image flags

            lw      at, 0x0018(sp)              // at = menu_button_table entry
            lhu     t9, 0x0008(at)              // t9 = button text X, unshifted
            sll     t9, t9, 0x0010              // t9 = button text X
            sw      t9, 0x0058(v0)              // save X
            lhu     t9, 0x000A(at)              // t9 = button text Y, unshifted
            sll     t9, t9, 0x0010              // t9 = button text Y
            sw      t9, 0x005C(v0)              // save Y
            lli     t2, 0x00FF                  // t2 = 0x000000FF (black)

            j       create_menu_button_._finish
            sw      t2, 0x0028(v0)              // update color
        }
    OS.patch_end()

    // @ Description
    //  Renders the menu buttons
    scope render_menu_buttons_: {
        OS.patch_start(0x1250A0, 0x801346F0)
        j       render_menu_buttons_
        nop
        _return:
        jal     create_menu_button_
        lli     a0, 0x0004                  // a0 = 5 (Remix Modes)
        // only draw on first page
        OS.read_word(page_flag, a0)         // a0 = page_flag
        bnez    a0, _finish                 // if on the 2nd page, don't draw
        nop
        jal     0x80132238                  // mnVSModeMakeRuleValue()
        nop
        jal     0x80132BA0                  // mnVSModeMakeTimeStockValue()
        nop
        _finish:
        OS.patch_end()

        jal     create_menu_button_
        lli     a0, 0x0000                  // a0 = 0 (VS Start/12cb)
        jal     create_menu_button_
        lli     a0, 0x0001                  // a0 = 1 (Rule/?)
        jal     create_menu_button_
        lli     a0, 0x0002                  // a0 = 2 (Time Stock/?)
        jal     create_menu_button_
        lli     a0, 0x0003                  // a0 = 3 (VS Options/?)

        j       _return
        nop
    }

    // @ Description
    // Checks the page to make sure we go back to page 1 from the Remix Modes page.
    // Make sure to exit the main function to avoid a crash.
    scope page_2_exit: {
        OS.patch_start(0x12474C, 0x80133D9C)
        jal     page_2_exit
        addiu   t6, r0, 0x0007                  // original line 2 - t6 = main menu screen ID
        jal     0x80005C74                      // original line 4 - syTaskmanSetLoadScene()
        sb      t5, 0x0001(v0)                  // original line 5 - set prev screen_id
        b       0x801345B4                      // exit main function early
        OS.patch_end()

        li      t5, page_flag
        lw      t0, 0x0000(t5)                  // t0 = page_flag
        sll     t0, t0, 0x0001                  // t0 = 2 if page 2, 0 is page 1
        addu    t6, t0, t6                      // t6 = main menu if coming from page 1, VS Mode menu if coming from page 2
        sw      r0, 0x0000(t5)                  // set to page 1
        lbu     t5, 0x0000(v0)                  // original line 1
        jr      ra
        sb      t6, 0x0000(v0)                  // original line 3 - set screen_id
    }

    // @ Description
    // Fixes a crash when pressing a button on the VS Mode menu due to the function
    // not being exited.
    scope fix_a_button_crash_: {
        OS.patch_start(0x1245FC, 0x80133C4C)
        b       0x80133C08                      // branch to a jal to 0x80005C74 that properly exits after
        OS.patch_end()
    }

    // @ Description
    // Overwrite button click handler code starting at 0x80133CD0 and ending at 0x80133D7C.
    // This saves RAM space.
    OS.patch_start(0x124680, 0x80133CD0)
    // v0 = button index
    sll     at, v0, 0x0002                  // at = offset to button object
    lui     a0, 0x8013
    addu    a0, a0, at                      // adjust for offset
    lw      a0, 0x4930(a0)                  // a0 = button object

    lw      at, 0x0084(a0)                  // at = menu_button_table entry or 0 if not a generic button
    beqz    at, 0x80133D7C                  // skip if not a generic button
    sw      at, 0x0018(sp)                  // save to stack

    jal     0x80131F4C                      // mnVSModeUpdateButton()
    addiu   a1, r0, 0x0002                  // a1 = highlight type clicked

    jal     0x800269C0                      // play FGM
    addiu   a0, r0, 0x009E

    jal     0x801337B8                      // mnVSModeSaveSettings()
    nop

    lli     t1, 0x0001                      // t1 = TRUE
    lui     at, 0x8013
    sw      t1, 0x4974(at)                  // sMNVSModeExitInterrupt = TRUE

    lw      at, 0x0018(sp)                  // at = menu_button_table entry
    lbu     a0, 0x0005(at)                  // a0 = value to set vs_mode_flag to
    li      v0, vs_mode_flag
    sw      a0, 0x0000(v0)                  // update vs_mode_flag
    lbu     t1, 0x0006(at)                  // t1 = value to set page_flag to
    li      v0, page_flag
    sw      t1, 0x0000(v0)                  // update page_flag
    lbu     t1, 0x0007(at)                  // t1 = value to set TwelveCharBattle.twelve_cb_flag to
    li      v0, TwelveCharBattle.twelve_cb_flag
    sw      t1, 0x0000(v0)                  // update TwelveCharBattle.twelve_cb_flag

    lui     v0, 0x800A
    addiu   v0, v0, 0x4AD0                  // v0 = address of current screen
    lbu     t9, 0x0000(v0)                  // t9 = current screen
    lbu     t0, 0x0004(at)                  // t0 = screen to jump to
    sb      t0, 0x0000(v0)                  // update next screen
    sb      t9, 0x0001(v0)                  // update prev screen

    jal     save_global_settings_           // save globals
    nop

    b       0x801345B4                      // finish
    nop
    OS.patch_end()

    // @ Description
    // Saves global values before leaving VS Mode menu
    // @ Arguments
    // a0 - vs_mode_flag
    scope save_global_settings_: {
        li      at, Global.vs.game_mode     // at = game_mode address
        lbu     t0, 0x0000(at)              // t0 = game_mode
        li      t1, global_game_mode
        sw      t0, 0x0000(t1)              // save game mode

        li      at, Global.vs.time          // at = time address
        lbu     t0, 0x0000(at)              // t0 = time
        li      t1, global_time
        sw      t0, 0x0000(t1)              // save time

        li      at, Global.vs.stocks        // at = stocks address
        lbu     t0, 0x0000(at)              // t0 = stocks
        li      t1, global_stocks
        sw      t0, 0x0000(t1)              // save stocks

        li      at, Global.vs.teams         // at = teams address
        lbu     t0, 0x0000(at)              // t0 = teams
        li      t1, global_teams
        sw      t0, 0x0000(t1)              // save teams

        li      at, Global.vs.stage_select  // at = stage_select address
        lbu     t0, 0x0000(at)              // t0 = stage_select
        li      t1, global_stage_select
        sw      t0, 0x0000(t1)              // save stage_select

        li      at, Global.vs.stage         // at = stage address
        lbu     t0, 0x0000(at)              // t0 = stage
        li      t1, global_stage
        sw      t0, 0x0000(t1)              // save stage

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, global_stockmode_table  // t1 = global stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = global stockmode_table p1
        sw      t0, 0x0000(at)              // set stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = global stockmode_table p2
        sw      t0, 0x0004(at)              // set stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = global stockmode_table p3
        sw      t0, 0x0008(at)              // set stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = global stockmode_table p4
        sw      t0, 0x000C(at)              // set stockmode_table p4

        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table address
        li      t1, global_stock_count_table // t1 = global stock_count_table
        sw      t0, 0x0000(t1)              // save stock_count_table

        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table address
        li      t1, global_previous_stock_count_table // t1 = global previous_stock_count_table
        sw      t0, 0x0000(t1)              // save previous_stock_count_table

        // This should run to sync costumes when it's going to be teams
        OS.read_word(vs_mode_flag, t0)      // t0 = vs_mode_flag
        lli     t1, mode.SMASHKETBALL
        beq     t0, t1, _apply_teams_costumes // always apply teams costumes for Smashketball
        OS.read_word(global_teams, at)      // at = default VS teams flag (yes, delay slot)
        beqz    t0, _check_teams            // if default VS, use at
        lli     t1, mode.KOTH
        OS.read_word(KingOfTheHill.teams, at) // at = KOTH teams flag
        beq     t0, t1, _check_teams        // if KOTH, check teams
        lli     t1, mode.TUG_OF_WAR
        bne     t0, t1, _end                // if not TUG_OF_WAR, skip
        OS.read_word(TugOfWar.teams, at)    // at = TUG_OF_WAR teams flag, yes, delay slot
        _check_teams:
        beqz    at, _end                    // if not teams, skip
        nop

        _apply_teams_costumes:
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        // force team colors to be used when calling mnVSModeSetCostumesAndShades
        li      at, 0x8013494C              // at = rule value
        lli     t0, 0x0003                  // t0 = stock team
        sw      t0, 0x0000(at)              // t0 = game mode

        jal     0x80133A8C                  // mnVSModeSetCostumesAndShades()
        nop

        lw      ra, 0x0004(sp)              // save ra
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Mode-specific setup when entering CSS (in mnBattleLoadMatchInfo())
    scope mode_specific_setup_: {
        OS.patch_start(0x1391CC, 0x8013AF4C)
        jal     mode_specific_setup_
        addiu   s1, s1, 0xBA88              // original line 1
        OS.patch_end()

        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      t0, CharacterSelect.showing_time
        sw      r0, 0x0000(t0)              // initialize showing_time to FALSE

        OS.read_word(vs_mode_flag, a0)      // a0 = vs_mode_flag

        li      t0, mode_setup_table
        sll     t1, a0, 0x0002              // t1 = offset to setup routine
        addu    t0, t0, t1                  // t0 = routine address
        lw      t0, 0x0000(t0)              // t0 = routine, or 0
        bnez    t0, _specific_routine       // if specific routine necessary, do it
        or      s0, r0, r0                  // original line 2

        // Normal VS stuff
        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, global_stockmode_table  // t1 = global_stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = global_stockmode_table p1
        sw      t0, 0x0000(at)              // set stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = global_stockmode_table p2
        sw      t0, 0x0004(at)              // set stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = global_stockmode_table p3
        sw      t0, 0x0008(at)              // set stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = global_stockmode_table p4
        sw      t0, 0x000C(at)              // set stockmode_table p4

        li      at, StockMode.stock_count_table // at = stock_count_table address
        OS.read_word(global_stock_count_table, t0) // t0 = global_stock_count_table
        sw      t0, 0x0000(at)              // set stock_count_table

        // only reset previous_stock_count_table if coming from menu
        OS.read_byte(Global.previous_screen, at) // at = current screen
        lli     t0, Global.screen.VS_GAME_MODE_MENU
        bne     at, t0, _end                // if not coming from menu, skip
        nop

        li      at, StockMode.previous_stock_count_table // at = previous_stock_count_table address
        OS.read_word(global_previous_stock_count_table, t0) // t0 = global_previous_stock_count_table
        b       _end
        sw      t0, 0x0000(at)              // set previous_stock_count_table

        _specific_routine:
        jalr    t0                          // call mode-specific routine
        nop

        _end:
        lbu     t2, 0x0010(s2)              // restore t2
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space

        mode_setup_table:
        dw 0                                // default
        dw TwelveCharBattle.before_css_setup_ // 12cb
        dw TagTeam.before_css_setup_        // Tag Team
        dw KingOfTheHill.before_css_setup_  // KOTH
        dw Smashketball.before_css_setup_   // Smashketball
        dw TugOfWar.before_css_setup_       // Tug of War
    }

    // @ Description
    // Mode-specific setup when returning from CSS
    scope mode_specific_setup_returning_: {
        OS.patch_start(0x136388, 0x80138108)
        addiu   t7, r0, 0x0009              // original line 1 - VS Mode screen_id
        sb      t7, 0x0000(v0)              // original line 2 - set screen_id
        jal     mode_specific_setup_returning_
        sb      t6, 0x0001(v0)              // original line 4 - set prev screen_id
        OS.patch_end()

        _screen_id_done:
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        OS.read_word(vs_mode_flag, a0)      // a0 = vs_mode_flag

        li      t0, mode_setup_returning_table
        sll     t1, a0, 0x0002              // t1 = offset to setup routine
        addu    t0, t0, t1                  // t0 = routine address
        lw      t0, 0x0000(t0)              // t0 = routine, or 0
        bnez    t0, _specific_routine       // if specific routine necessary, do it
        nop

        // Normal VS stuff
        li      at, VsRemixMenu.global_teams // at = saved teams address
        OS.read_word(0x8013BDA8, t0)        // t0 = teams
        sw      t0, 0x0000(at)              // restore teams

        li      at, global_stockmode_table  // at = global_stockmode_table address
        li      t1, StockMode.stockmode_table // t1 = stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = stockmode_table p1
        sw      t0, 0x0000(at)              // set global_stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = stockmode_table p2
        sw      t0, 0x0004(at)              // set global_stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = stockmode_table p3
        sw      t0, 0x0008(at)              // set global_stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = stockmode_table p4
        sw      t0, 0x000C(at)              // set global_stockmode_table p4

        li      at, global_stock_count_table // at = global_stock_count_table address
        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table address
        sw      t0, 0x0000(at)              // set global_stock_count_table

        li      at, global_previous_stock_count_table // at = global_previous_stock_count_table address
        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table
        b       _end
        sw      t0, 0x0000(at)              // set global_previous_stock_count_table

        _specific_routine:
        jalr    t0                          // call mode-specific routine
        nop

        _end:
        li      at, 0x8013BDAC              // at = game_mode address
        OS.read_word(global_game_mode, t0)  // t0 = saved game_mode
        sw      t0, 0x0000(at)              // restore game mode

        li      at, Global.vs.stage_select  // at = stage_select
        OS.read_word(global_stage_select, t0) // t0 = saved stage_select
        sb      t0, 0x0000(at)              // restore stage_select

        _return:
        jal     0x8013A664                  // original line 3 - mnBattleSaveMatchInfo()
        nop

        li      at, Global.vs.teams         // at = teams address
        OS.read_word(VsRemixMenu.global_teams, t0) // t0 = saved teams
        sb      t0, 0x0000(at)              // restore teams

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space

        mode_setup_returning_table:
        dw 0                                // default
        dw TwelveCharBattle.leave_css_setup_ // 12cb
        dw TagTeam.leave_css_setup_         // Tag Team
        dw KingOfTheHill.leave_css_setup_   // KOTH
        dw Smashketball.leave_css_setup_    // Smashketball
        dw TugOfWar.leave_css_setup_        // Tug of War
    }

    // @ Description
    // Mode-specific setup when starting match
    scope mode_specific_setup_start_: {
        OS.patch_start(0x138CC0, 0x8013AA40)
        jal     mode_specific_setup_start_
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        OS.read_word(vs_mode_flag, a0)      // a0 = vs_mode_flag

        li      t0, mode_setup_start_table
        sll     t1, a0, 0x0002              // t1 = offset to setup routine
        addu    t0, t0, t1                  // t0 = routine address
        lw      t0, 0x0000(t0)              // t0 = routine, or 0
        bnez    t0, _specific_routine       // if routine necessary, do specific routine
        nop

        // Normal VS stuff
        li      at, global_stockmode_table  // at = global_stockmode_table address
        li      t1, StockMode.stockmode_table // t1 = stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = stockmode_table p1
        sw      t0, 0x0000(at)              // set global_stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = stockmode_table p2
        sw      t0, 0x0004(at)              // set global_stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = stockmode_table p3
        sw      t0, 0x0008(at)              // set global_stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = stockmode_table p4
        sw      t0, 0x000C(at)              // set global_stockmode_table p4

        li      at, 0x8013BDAC              // at = game_mode address
        OS.read_word(global_game_mode, t0)  // t0 = saved game_mode
        b       _end
        sw      t0, 0x0000(at)              // restore game mode

        _specific_routine:
        jalr    t0                          // call mode-specific routine
        nop

        _end:
        jal     0x8013A664                  // original line 1 - mnBattleSaveMatchInfo()
        nop                                 // original line 2
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space

        mode_setup_start_table:
        dw 0                                // default
        dw TwelveCharBattle.start_match_setup_ // 12cb
        dw TagTeam.start_match_setup_       // Tag Team
        dw KingOfTheHill.start_match_setup_ // KOTH
        dw Smashketball.start_match_setup_  // Smashketball
        dw TugOfWar.start_match_setup_      // Tug of War
    }

    // @ Description
    // Allows us to control start conditions
    scope control_match_start_: {
        OS.patch_start(0x1388D4, 0x8013A654)
        j       control_match_start_
        addiu   sp, sp, 0x0020              // original line 1
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        beqz    v1, _end                    // if not ready with normal checks, then skip
        lli     t3, VsRemixMenu.mode.TAG_TEAM
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        beq     t0, t3, _squad_strike       // if Tag Team, prevent start with empty slots
        lli     t3, VsRemixMenu.mode.SMASHKETBALL
        bne     t0, t3, _end
        nop

        _smashketball:
        jal     Smashketball.css.prevent_start_unless_two_teams_
        nop
        b       _end
        nop

        _squad_strike:
        jal     TagTeam.css.prevent_start_with_empty_slots_
        nop

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        or      v0, v1, r0                  // original line 2
    }

    // @ Description
    // Provides a way to change game end conditions
    scope check_match_end_: {
        OS.patch_start(0x8E980, 0x80113180)
        j       check_match_end_
        lbu     t2, 0x0006(a0)              // original line 1 - t2 = Global.vs.time
        _return:
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, at) // at = vs_mode_flag
        lli     t3, VsRemixMenu.mode.KOTH
        beq     at, t3, _koth               // if KOTH, do KOTH check
        lli     t3, VsRemixMenu.mode.SMASHKETBALL
        beq     at, t3, _smashketball       // if Smashketball, do Smashketball check
        nop

        _normal:
        lbu     t2, 0x0006(a0)              // original line 1 - t2 = Global.vs.time
        j       _return
        addiu   at, r0, 0x0064              // original line 2 - at = infinity

        _koth:
        jal     KingOfTheHill.check_match_end_
        nop
        b       _normal
        nop

        _smashketball:
        jal     Smashketball.check_match_end_
        nop
        b       _normal
        nop
    }

    // @ Description
    // Skip Rule/TimeStock arrow stuff on page 2
    scope page_2_no_arrows_: {
        // up check
        OS.patch_start(0x124874, 0x80133EC4)
        addiu   t2, r0, 0x0001              // original line 3
        lui     at, 0x8013                  // original line 4
        sw      t2, 0x4978(at)              // original line 5
        jal     page_2_no_arrows_._up_check
        lui     v0, 0x8013                  // original line 1
        OS.patch_end()
        // down check
        OS.patch_start(0x1249E8, 0x80134038)
        addiu   t9, r0, 0x0002              // original line 3
        lui     at, 0x8013                  // original line 4
        sw      t9, 0x4978(at)              // original line 5
        jal     page_2_no_arrows_._down_check
        lui     v0, 0x8013                  // original line 1
        OS.patch_end()
        // l/r check
        OS.patch_start(0x124A44, 0x80134094)
        jal     page_2_no_arrows_._lr_check
        lui     v0, 0x8013                  // original line 1
        OS.patch_end()

        _up_check:
        OS.read_word(page_flag, t2)         // t2 = page_flag
        beqz    t2, _normal                 // if first page, return normally
        nop

        j       0x80133F20                  // otherwise, skip
        nop

        _down_check:
        OS.read_word(page_flag, t2)         // t2 = page_flag
        beqz    t2, _normal                 // if first page, return normally
        nop

        j       0x801345B8                  // otherwise, skip (also skips l/r checks)
        lw      ra, 0x0014(sp)              // restore ra

        _lr_check:
        OS.read_word(page_flag, t2)         // t2 = page_flag
        beqz    t2, _normal                 // if first page, return normally
        nop

        j       0x801345B8                  // otherwise, skip
        lw      ra, 0x0014(sp)              // restore ra

        _normal:
        jr      ra
        lw      v0, 0x4948(v0)              // original line 2 - v0 = cursor index
    }

    // @ Description
    // Set cursor index correctly when returning from CSS.
    scope set_cursor_index_: {
        OS.patch_start(0x124064, 0x801336B4)
        j       set_cursor_index_
        lui     v1, 0x800A                      // original line 2
        _return:
        OS.patch_end()

        // ensure pointers are correct for other CSS screens
        li      t0, CharacterSelect.id_table_pointer
        li      t1, CharacterSelect.id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_id_table_pointer
        li      t1, CharacterSelect.portrait_id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_offset_table_pointer
        li      t1, CharacterSelect.portrait_offset_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_x_position_pointer
        li      t1, CharacterSelect.portrait_x_position
        sw      t1, 0x0000(t0)

        lli     at, 0x0009                      // at = VS Mode screen ID
        beq     t6, at, _check_page             // if coming from the same screen, check page
        nop
        OS.read_word(vs_mode_flag, at)          // at = vs_mode_flag
        bnez    at, _custom                     // if returning from a custom mode, handle differently
        nop                                     // otherwise, continue with original logic
        j       _return
        addiu   at, r0, 0x000A                  // original line 1

        _check_page:
        OS.read_word(page_flag, at)             // at = page_flag
        beqzl   at, _finish                     // if on page 1, then set cursor to Remix Modes
        lli     t7, PAGE_1_MAX                  // t7 = Remix Modes index
        j       _return                         // otherwise, continue with original logic
        nop

        _custom:
        addiu   t7, at, -0x0001                 // t7 = button index

        _finish:
        lui     at, 0x8013
        sw      t7, 0x4948(at)                  // set cursor index
        j       0x801336DC                      // return to rest of routine
        addiu   v1, v1, 0x4D08                  // original line 4
    }

    // @ Description
    // This changes the options for time on the CSS depending on mode
    scope change_time_options {
        // Number of options in the picker
        constant ARRAY_LENGTH(13)

        // Change default options to 1/2/3/5/8/10/12/15/20/30/60/99/∞
        // This is possible in place because the game duplicates the vanilla array
        OS.patch_start(0x139BBC, 0x8013B93C)
        dw 1, 2, 3, 5, 8, 10, 12, 15, 20, 30, 60, 99, 0x64
        OS.patch_end()

        // mnBattleGetNextTimerValue()
        scope get_next_value {
            OS.patch_start(0x138D80, 0x8013AB00)
            // a0 = current value
            // t7 = default array
            lli     t8, mode.KOTH
            OS.read_word(CharacterSelect.showing_time, t9) // t9 = showing_time flag
            bnez    t9, _continue               // if in Time mode, keep using default array
            nop

            OS.read_word(VsRemixMenu.vs_mode_flag, t9) // t9 = vs_mode_flag
            beq     t9, t8, _koth               // if KOTH, use KOTH array
            lli     t8, mode.SMASHKETBALL
            beq     t9, t8, _smashketball       // if SMASHKETBALL, use SMASHKETBALL array
            nop
            b       _continue                   // Otherwise, keep using default array
            nop

            _koth:
            li      t7, KingOfTheHill.time_value_array // t7 = KOTH time values
            b       _continue
            nop

            _smashketball:
            li      t7, Smashketball.score_value_array // t7 = SMASHKETBALL values

            _continue:
            or      v1, t7, r0                  // v1 = array
            lli     t0, 0                       // t0 = loop index
            _loop:
            lw      v0, 0x0000(v1)              // v0 = next value, maybe
            sltu    at, a0, v0                  // at = 1 if current value is less than this value
            bnez    at, _return                 // if current value is less, take this as next value
            addiu   t0, t0, 0x0001              // t0 = loop index + 1
            sltiu   at, t0, ARRAY_LENGTH        // at = 1 if more looping to do
            bnez    at, _loop                   // loop if more to do
            addiu   v1, v1, 0x0004              // v1 = next element address

            // if here, then it was the last one so set to first one
            lw      v0, 0x0000(t7)              // v0 = next value

            _return:
            jr      ra
            nop
            OS.patch_end()
        }

        // mnBattleGetPrevTimerValue()
        scope get_prev_value {
            OS.patch_start(0x138E5C, 0x8013ABDC)
            // a0 = current value
            li      t7, 0x8013B93C              // t7 = default array
            lli     t8, mode.KOTH
            OS.read_word(CharacterSelect.showing_time, t9) // t9 = showing_time flag
            bnez    t9, _continue               // if in Time mode, keep using default array
            nop

            OS.read_word(VsRemixMenu.vs_mode_flag, t9) // t9 = vs_mode_flag
            beq     t9, t8, _koth               // if KOTH, use KOTH array
            lli     t8, mode.SMASHKETBALL
            beq     t9, t8, _smashketball       // if SMASHKETBALL, use SMASHKETBALL array
            nop
            b       _continue                   // Otherwise, keep using default array
            nop

            _koth:
            li      t7, KingOfTheHill.time_value_array // t7 = KOTH time values
            b       _continue
            nop

            _smashketball:
            li      t7, Smashketball.score_value_array // t7 = SMASHKETBALL values

            _continue:
            addiu   v1, t7, (ARRAY_LENGTH - 1) * 4 // v1 = last element address
            or      t7, v1, r0                  // t7 = last element address
            lli     t0, ARRAY_LENGTH - 1        // t0 = index
            _loop:
            lw      v0, 0x0000(v1)              // v0 = prev value, maybe
            sltu    at, v0, a0                  // at = 1 if this value is less than current value
            bnez    at, _return                 // if current value is less, take this as next value
            addiu   t0, t0, -0x0001             // t0 = index - 1
            bgez    t0, _loop                   // loop if not past first element
            addiu   v1, v1, -0x0004             // v1 = prev element address

            // if here, then it was the first one so set to last one
            lw      v0, 0x0000(t7)              // v0 = last value

            _return:
            jr      ra
            nop
            OS.patch_end()
        }
    }

    // @ Description
    // Disables Free-for-all/Team Battle toggling
    scope disable_mode_toggle_: {
        OS.patch_start(0x1334F0, 0x80135270)
        j       disable_mode_toggle_
        nop
        _return:
        OS.patch_end()

        OS.read_word(vs_mode_flag, at)      // at = vs_mode_flag
        lli     v0, mode.TWELVE_CB
        beq     at, v0, _end                // if 12cb, don't allow toggling
        lui     at, 0x41A0                  // original line 2

        _normal:
        j       _return
        lw      v0, 0x0074(a0)              // original line 1

        _end:
        jr      ra
        or      v0, r0, r0                  // return 0 for v0 to signal no click
    }

    // @ Description
    // Modify the announcer clip when toggling FFA/Team Battle
    scope update_announcer_on_toggle_: {
        OS.patch_start(0x13363C, 0x801353BC)
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        bnez    t0, _skip_announcer         // if Tag Team, KOTH, Smashketball or Tug of War, skip announcer call
        lli     a0, FGM.announcer.css.FREE_FOR_ALL
        bnezl   t6, pc() + 8                // if teams, use teams call
        lli     a0, FGM.announcer.css.TEAM_BATTLE
        jal     0x800269C0                  // original line 3
        nop
        _skip_announcer:
        OS.patch_end()
    }

    // @ Description
    // Adds Time to the results screen for KOTH
    // Adds Score to the results screen for Smasketball
    scope add_row_to_results_: {
        // delay drawing place until after new row
        OS.patch_start(0x1554D8, 0x80136338)
        j       add_row_to_results_._delay_place
        lw      ra, 0x0014(sp)              // original line 2
        _return_delay_place:
        OS.patch_end()
        // push down place line to make room for new row
        OS.patch_start(0x1554E0, 0x80136340)
        j       add_row_to_results_._move_place
        addiu   a0, r0, 0x007C              // original line 2 - a0 = y
        _return_move_place:
        OS.patch_end()
        // instead of drawing "KOs", draw alt texture
        OS.patch_start(0x154878, 0x801356D8)
        jal     add_row_to_results_._draw_alt_texture
        sdc1    f20, 0x0038(sp)             // original line 2
        OS.patch_end()
        // instead of drawing kos, draw times
        OS.patch_start(0x154930, 0x80135790)
        jal     add_row_to_results_._draw_times
        sb      a0, 0x002A(t5)              // original line 1
        OS.patch_end()
        // instead of drawing kos, draw goals
        OS.patch_start(0x15481C, 0x8013567C)
        j       add_row_to_results_._draw_goals
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        _return_draw_goals:
        OS.patch_end()
        // allows results screen to show tens if 0 for seconds display
        OS.patch_start(0x153D80, 0x80134BE0)
        jal     add_row_to_results_._show_seconds_tens_digit_
        lw      t3, 0x0028(sp)
        OS.patch_end()
        // ensures Teams uses the FFA routine we modify (it's the same in vanilla!)
        OS.patch_start(0x1558AC, 0x8013670C)
        jal     add_row_to_results_._change_teams_routine
        lui     t1, 0x8014                  // original line 1
        OS.patch_end()
        // add new row to no contest screen results screen
        OS.patch_start(0x1556E0, 0x80136540)
        addiu   sp, sp, -0x0018             // original line 3
        sw      ra, 0x0014(sp)              // original line 5
        lui     v0, 0x8014                  // original line 1
        j       add_row_to_results_._no_contest_new_row
        lw      v0, 0x9B78(v0)              // original line 4
        _return_no_contest_new_row:
        OS.patch_end()

        _delay_place:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        beq     t0, t1, _do_delay_place     // if KOTH, do delay
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        bne     t0, t1, _normal             // if not Smashketball, do normal check
        nop

        _do_delay_place:
        // Check if we should display new row yet
        bne     v0, at, _normal             // if not time for new row, skip
        addiu   at, at, 20                  // at = frames elapsed (place row delayed)

        li      t0, new_row
        lli     t1, OS.TRUE                 // t1 = TRUE
        sw      t1, 0x0000(t0)              // set helper to true

        // Display new row
        jal     0x8013569C                  // create new row by hijacking create KOs row routine
        lli     a0, 124                     // a0 = y

        li      t0, new_row
        sw      r0, 0x0000(t0)              // set helper to false

        _normal:
        bne     v0, at, _j_8013634C         // original line 1, modified
        nop

        j       _return_delay_place
        nop

        _j_8013634C:
        j       0x8013634C                 // jump instead of branch
        nop

        _move_place:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        beql    t0, t1, pc() + 8            // if KOTH, push down
        addiu   a0, a0, 16                  // a0 = y
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        beql    t0, t1, pc() + 8            // if Smashketball, push down
        addiu   a0, a0, 16                  // a0 = y

        jal     0x80136100                  // Draw Place line
        nop

        j       _return_move_place
        nop

        _draw_alt_texture:
        OS.read_word(VsRemixMenu.vs_mode_flag, a0) // a0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        bne     a0, t1, _check_smashketball_alt_texture // if not KOTH, skip
        OS.read_word(new_row, t1)           // t1 = 1 if we're drawing new row
        bnezl   t1, _end_draw_alt_texture   // if drawing time row, use different offset
        lli     t0, 0xE648                  // t0 = "Times" image offset

        _check_smashketball_alt_texture:
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        bne     a0, t1, _end_draw_alt_texture // if not Smashketball, skip
        OS.read_word(new_row, t1)           // t1 = 1 if we're drawing new row
        bnezl   t1, _end_draw_alt_texture   // if drawing time row, use different offset
        lli     t0, 0xE9E0                  // t0 = "FGs" image offset

        _end_draw_alt_texture:
        jr      ra
        addu    t1, t9, t0                  // original line 1

        _draw_times:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        bne     t0, t1, _end_draw_times     // if not KOTH, skip
        OS.read_word(new_row, t1)           // t1 = 1 if we're drawing time row
        beqz    t1, _end_draw_times         // if not drawing time row, skip
        lli     t0, 0x0000                  // t0 = port

        // draw time values
        _loop:
        sw      t6, 0x0030(sp)              // save t6 to free stack space
        lw      t6, 0x9BD0(t6)              // gMNResultsIsPresent[i]
        beqz    t6, _next                   // if not present, go to next
        sw      t0, 0x0034(sp)              // save port to free stack space

        jal     0x801352FC                  // mnResultsGetColumnX
        lw      a0, 0x0034(sp)              // a0 = port
        mov.s   f20, f0                     // f20 = x

        li      t0, KingOfTheHill.scores
        lw      a0, 0x0034(sp)              // a0 = port
        sll     t1, a0, 0x0002              // t0 = offset to score
        addu    t0, t0, t1                  // t0 = address of score
        lw      t0, 0x0000(t0)              // t0 = score (frames)
        lli     t1, 60                      // t1 = 60
        divu    t0, t1                      // mflo = seconds
        mflo    s0                          // s0 = seconds

        jal     0x801353F4                  // mnResultsGetNumberColorIndex
        lw      a0, 0x0034(sp)              // a0 = port
        sw      v0, 0x0010(sp)              // save color index

        // seconds
        li      t0, new_row
        lli     t1, OS.TRUE                 // t1 = TRUE
        sw      t1, 0x0000(t0)              // set helper bool
        lw      a0, 0x005C(sp)              // a0 = row_gobj
        mfc1    a1, f20                     // a1 = x
        lw      a2, 0x004C(sp)              // a2 = y
        lli     t1, 60                      // t1 = 60
        divu    s0, t1                      // mfhi = seconds
        jal     0x80134AC4                  // mnResultsDrawNumber
        mfhi    a3                          // a3 = number

        // minutes
        li      t0, new_row
        sw      r0, 0x0000(t0)              // set helper bool to false
        lw      a0, 0x005C(sp)              // a0 = row_gobj
        lui     a1, 0x41A0                  // a1 = 20
        mtc1    a1, f0                      // f0 = 20
        sub.s   f20, f20, f0                // f20 = minutes x
        mfc1    a1, f20                     // a1 = x
        lw      a2, 0x004C(sp)              // a2 = y
        lli     t1, 60                      // t1 = 60
        divu    s0, t1                      // mflo = minutes
        jal     0x80134AC4                  // mnResultsDrawNumber
        mflo    a3                          // a3 = number

        OS.read_word(0x8013A05C, t9)        // t9 = file 0x24
        addiu   a1, t9, 0x08D8              // a1 = colon offset
        jal     0x800CCFDC                  // add :
        lw      a0, 0x005C(sp)              // a0 = row_gobj

        lui     a1, 0x41F8                  // a1 = 31
        mtc1    a1, f0                      // f0 = 31
        add.s   f20, f20, f0                // f20 = colon x
        mfc1    a1, f20                     // a1 = x
        sw      a1, 0x0058(v0)              // set x
        lw      t0, 0x004C(sp)              // t0 = y
        sw      t0, 0x005C(v0)              // set y
        lli     t0, 0x0201                  // t0 = flags
        sh      t0, 0x0024(v0)              // set flags

        or      a0, v0, r0                  // a0 = colon
        jal     0x80134770                  // mnResultsSetNumberColor
        lw      a1, 0x0010(sp)              // a1 = color index

        _next:
        lw      t6, 0x0030(sp)              // t6 = gMNResultsIsPresent upper
        lw      t0, 0x0034(sp)              // t0 = port
        addiu   t0, t0, 0x0001              // t0 = next port
        sltiu   at, t0, 0x0004              // at = 0 if at end of array
        bnez    at, _loop                   // if more to check, keep looping
        addiu   t6, t6, 0x0004              // next entry

        j       0x801358B0                  // skip to end of routine
        nop

        _end_draw_times:
        jr      ra
        lw      t6, 0x9BD0(t6)              // original line 2 - gMNResultsIsPresent[0]

        _draw_goals:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        bne     t0, t1, _end_draw_goals     // if not Smaskhetball, use KOs
        lw      v1, 0x9B80(v1)              // original line 1

        OS.read_word(new_row, t1)           // t1 = 1 if we're drawing new row
        beqz    t1, _end_draw_goals         // if not drawing time row, use KOs
        nop

        li      v1, Smashketball.scores
        addu    v1, v1, t6                  // v1 = address of goals for port
        lw      v1, 0x0000(v1)              // v1 = goals

        _end_draw_goals:
        j       _return_draw_goals
        slti    at, v1, 0x03E8              // original line 2

        _show_seconds_tens_digit_:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        bne     t0, t1, _normal_check       // if not KOTH, do normal check
        nop

        // So it's KOTH, check if we should display time row
        OS.read_word(new_row, t0)          // t0 = 1 if time row
        beqz    t0, _normal_check           // if not time row, do normal check
        nop

        jr      ra                          // return to draw tens digit
        nop

        _normal_check:
        beqz    t3, _j_80134C18             // original line 2, modified
        lui     at, 0x4180                  // original line 3

        jr      ra                          // return to draw tens digit
        nop

        _j_80134C18:
        j       0x80134C18
        nop

        _change_teams_routine:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t2, VsRemixMenu.mode.KOTH
        beq     t0, t2, _set_routine        // if KOTH, change routine
        lw      t2, 0x96E4(t1)              // t2 = FFA routine
        lli     t2, VsRemixMenu.mode.SMASHKETBALL
        beq     t0, t2, _set_routine        // if Smashketball, change routine
        lw      t2, 0x96E4(t1)              // t2 = FFA routine

        b       _end_change_teams_routine   // don't change routine (probably wouldn't hurt, though)
        nop

        _set_routine:
        sw      t2, 0x96EC(t1)              // set as Teams routine

        _end_change_teams_routine:
        jr      ra
        addiu   t1, t1, 0x96E4              // original line 2

        _no_contest_new_row:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.KOTH
        beq     t0, t1, _do_add_no_contest_new_row // if KOTH, add new row
        lli     at, 100                     // at = 100 (frames elapsed to show new row)
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        bne     t0, t1, _end_no_contest_new_row // if not Smashketball, skip new row
        lli     at, 100                     // at = 100 (frames elapsed to show new row)

        _do_add_no_contest_new_row:
        // Check if we should display new row
        bne     v0, at, _end_no_contest_new_row // if not time for new row, skip
        nop

        li      t0, new_row
        lli     t1, OS.TRUE                 // t1 = TRUE
        sw      t1, 0x0000(t0)              // set helper to true

        // Display new row
        jal     0x8013569C                  // create new row by hijacking create KOs row routine
        lli     a0, 96                      // a0 = y

        li      t0, new_row
        sw      r0, 0x0000(t0)              // set helper to false

        _end_no_contest_new_row:
        j       _return_no_contest_new_row
        addiu   at, r0, 0x001E              // original line 4

        // Helps with display
        new_row:
        dw 0
    }

}

} // __VS_REMIX_MENU__
