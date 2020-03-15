// Menu.asm
if !{defined __MENU__} {
define __MENU__()
print "included Menu.asm\n"

include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"

scope Menu {

    constant ROW_HEIGHT(000010)
    constant MAX_PER_PAGE(19)

    scope type {
        constant U8(0x0000)                 // 08 bit integer (unsigned)
        constant U16(0x0001)                // 16 bit integer (unsigned)
        constant U32(0x0002)                // 32 bit integer (unsigned)
        constant S8(0x0003)                 // 08 bit integer (signed, not supported) 
        constant S16(0x0004)                // 16 bit integer (signed, not supported)
        constant S32(0x0005)                // 32 bit integer (signed, not supported)
        constant BOOL(0x0006)               // bool
        constant TITLE(0x0007)              // has no value on the right
    }

    // @ Description
    // Struct for menu arguments.
    macro info(head, ulx, uly, rgba5551, width) {
        dw {head}                           // 0x0000 - address of menu head
        dw {ulx}                            // 0x0004 - ulx
        dw {uly}                            // 0x0008 - uly
        dw 0x00000000                       // 0x000C - selection
        dh {rgba5551}                       // 0x0010 - color of background
        dh {rgba5551}                       // ^
        dw {width}                          // 0x0014 - width of menu in chars
        dw {head}                           // 0x0018 - first entry currently displayed (default to head)
        dw {head}                           // 0x001C - last entry currently displayed (default to head)
    }

    // @ Description
    // Struct for menu entries
    macro entry(title, type, default, min, max, a_function, string_table, copy_address, next) {
        define address(pc())
        dw {type}                           // 0x0000 - type (int, bool, etc.)
        dw {default}                        // 0x0004 - current value
        dw {min}                            // 0x0008 - minimum value
        dw {max}                            // 0x000C - maximum value
        dw {a_function}                     // 0x0010 - if (!null), function ran when A is pressed
        dw {string_table}                   // 0x0014 - if (!null), use table of string pointers
        dw {copy_address}                   // 0x0018 - if (!null), copies curr_value to address
        dw {next}                           // 0x001C - if !(null), address of next entry
        db {title}                          // 0x0020 - title
        db 0x00
        OS.align(4)

        // @ Description
        // signed integers are not supproted yet!
        if {type} >= Menu.type.S8 {
            if {type} <= Menu.type.S32 {
                if {string_address} != OS.NULL {
                    warning "signed integers are not supported (yet)"
                }
            }
        }

        // @ Description
        // warning for strings with a negative index
        if {type} >= Menu.type.S8 {
            if {type} <= Menu.type.S32 {
                if {string_address} != OS.NULL {
                    warning "string index may be less than 0"
                }
            }
        }
    }

    bool_0:; db "OFF", 0x00
    bool_1:; db "ON", 0x00
    OS.align(4)

    bool_string_table:
    dw bool_0
    dw bool_1
    OS.align(4)

    macro entry_bool(title, default, next) {
        Menu.entry({title}, Menu.type.BOOL, {default}, 0, 1, OS.NULL, Menu.bool_string_table, OS.NULL, {next})
    }

    macro entry_title(title, a_function, next) {
        Menu.entry({title}, Menu.type.TITLE, 0, 0, 0, {a_function}, OS.NULL, OS.NULL, {next})
    }

    // @ Description
    // Draw a menu entry (title, on/off)
    // @ Arguments
    // a0 - address of entry
    // a1 - ulx
    // a2 - uly
    // a3 - address of info()
    scope draw_entry_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      t1, 0x0014(sp)              // ~
        sw      ra, 0x0018(sp)              // ~
        sw      a0, 0x001C(sp)              // ~
        sw      a1, 0x0020(sp)              // ~
        sw      a2, 0x0024(sp)              // ~
        sw      a3, 0x0028(sp)              // save registers

        move    s0, a0                      // s0 = entry
        move    s1, a1                      // s1 = ulx
        move    s2, a2                      // s2 = uly

        move    a0, s1                      // a1 - ulx
        move    a1, s2                      // a1 - uly
        addiu   a2, s0, 0x0020              // a2 - address of string (title = entry + 0x0020)
        jal     Overlay.draw_string_
        nop

        lli     t0, Menu.type.TITLE         // t0 = title type
        lw      t1, 0x0000(s0)              // t1 = type
        beq     t0, t1, _end                // if (type == title), end
        nop

        lw      t0, 0x0014(s0)              // at = entry.string_table
        bnez    t0, _string                 // if (entry.string_table != null), skip
        nop                                 // else, continue

        _number:
        lw      a0, 0x0004(s0)              // a0 - (int) current value
        jal     String.itoa_                // v0 = (string) current value
        nop
        lw      a0, 0x0028(sp)              // a0 = urx
        move    a1, s2                      // a1 - uly
        move    a2, v0                      // a2 - address of string
        jal     Overlay.draw_string_urx_    // draw value
        nop
        b       _end                        // skip draw string
        nop

        _string:
        lw      t1, 0x0004(s0)              // at =  (int) current value
        sll     t1, t1, 0x0002              // t1 = curr * sizeof(string pointer)
        addu    a2, t0, t1                  // ~
        lw      a2, 0x0000(a2)              // a2 - address of string
        lw      a0, 0x0028(sp)              // a0 = urx
        move    a1, s2                      // a1 - uly
        jal     Overlay.draw_string_urx_    // draw string
        nop

        _end:
        lw      s0, 0x0004(sp)              // ~
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      t1, 0x0014(sp)              // ~
        lw      ra, 0x0018(sp)              // ~
        lw      a0, 0x001C(sp)              // ~
        lw      a1, 0x0020(sp)              // ~
        lw      a2, 0x0024(sp)              // ~
        lw      a3, 0x0028(sp)              // srestore registers
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draw linked list of menu entries
    // @ Arguments
    // a0 - address of Menu.info()
    scope draw_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // ~
        sw      a3, 0x001C(sp)              // ~
        sw      t1, 0x0020(sp)              // ~
        sw      at, 0x0024(sp)              // save registers

        // draw rectangle
        lw      a0, 0x0010(a0)              // a0 - fill color
        beq     a0, r0, _draw_entries       // skip if fill color = 0
        nop
        jal     Overlay.set_color_          // set fill color
        nop
        lw      a0, 0x0010(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop
        lli     at, ROW_HEIGHT              // at = ROW_HEIGHT
        mult    v0, at                      // ~
        mflo    v0                          // v0 = num_entries * NUM_PIXELS
       
        lw      at, 0x0010(sp)              // at = address of info()
        lw      a0, 0x0004(at)              // ~
        addiu   a1, a1,-0x0002              // a0 - ulx
        lw      a1, 0x0008(at)              // ~
        addiu   a1, a1,-0x0002              // a1 - uly
        lw      a2, 0x0014(at)              // a2 = width
        sll     a2, a2, 0x0003              // a2 = (width) * NUM_PIXELS
        addiu   a2, a2, 0x0004              // a2 - (width) * NUM_PIXELS + 4
        move    a3, v0                      // ~
        addiu   a3, a3, 0x0004              // a3 - height
        jal     Overlay.draw_rectangle_     // draw rectangle
        nop

         _draw_entries:
        // draw first entry
        lw      at, 0x0010(sp)              // at = address of info()
        lw      a0, 0x0018(at)              // a0 - first entry
        lw      a1, 0x0004(at)              // a1 - ulx, unadjusted
        lw      a2, 0x0008(at)              // a2 - uly
        lw      a3, 0x0014(at)              // a3 = width
        sll     a3, a3, 0x0003              // a3 = urx_difference
        addu    a3, a3, a1                  // a3 - urx
        addiu   a1, a1, 0x0008              // a1 - ulx, adjusted
        jal     draw_entry_                 // draw first entry
        nop

        // draw following entries
        lw      a0, 0x0010(sp)              // a0 = address of info
        lw      s0, 0x0018(a0)              // s0 = head (aka current_entry)
        lw      t0, 0x0008(a0)              // t0 = uly

        _loop:
        lw      s0, 0x001C(s0)              // s0 = entry->next
        beqz    s0, _end                    // if (entry->next == NULL), end
        nop
        addiu   t0, t0, ROW_HEIGHT          // increment height
        slti    at, t0, 00217               // if we don't have enough room to draw any more entries, end
        beqz    at, _end                    // ~
        nop
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        move    a0, s0                      // a0 - entry
        sw      a0, 0x001C(at)              // update last entry displayed
        lw      a1, 0x0004(at)              // a1 - ulx, unadjusted
        move    a2, t0                      // a2 - uly
        lw      a3, 0x0014(at)              // a3 = width
        sll     a3, a3, 0x0003              // a3 = urx_difference
        addu    a3, a3, a1                  // a3 - urx
        addiu   a1, a1, 0x0008              // a1 - ulx, adjusted
        jal     draw_entry_
        nop
        b       _loop
        nop

        _end:
        // draw selection cursor
        lli     a0, 0x7DFF                  // a0 - fill color (cursor blue)
        jal     Overlay.set_color_          // set fill color
        nop
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lw      t0, 0x000C(at)              // t0 = selection
        addiu   t1, r0, MAX_PER_PAGE        // t1 = max rows per page
        div     t0, t1                      // divide selection by rows per page to get row
        mfhi    t0                          // t0 - row
        lli     s0, ROW_HEIGHT              // ~
        mult    t0, s0                      // ~
        mflo    a1                          // a1 = height of row
        lw      t0, 0x0008(at)              // t0 = menu uly
        addu    a1, a1, t0                  // a1 - uly
        addiu   a1, a1, 0x0002              // a1 - uly + 2
        lw      a0, 0x0004(at)              // a0 - menu ulx
        addiu   a0, a0, 0x0002              // a0 - ulx + 2
        lli     a2, 0x0004                  // a2 - cursor width
        lli     a3, 0x0004                  // a3 - cursor height
        jal     Overlay.draw_rectangle_     // draw cursor
        nop
        //  draw selection line
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lw      t0, 0x000C(at)              // t0 = selecion
        addiu   t1, r0, MAX_PER_PAGE        // t1 = max rows per page
        div     t0, t1                      // divide selection by rows per page to get row
        mfhi    t0                          // t0 - row
        lli     s0, ROW_HEIGHT              // ~
        mult    t0, s0                      // ~
        mflo    a1                          // a1 = height of row
        lw      t0, 0x0008(at)              // t0 = menu uly
        addu    a1, a1, t0                  // a1 - uly
        addiu   a1, a1, 0x0008              // a1 - uly + 8
        lw      a0, 0x0004(at)              // a0 - menu ulx
        addiu   a0, a0, 0x0002              // a0 - ulx + 2
        lw      a2, 0x0014(at)              // a2 - width
        sll     a2, a2, 0x0003              // a2 = (width) * NUM_PIXELS
        addiu   a2, a2,-0x0002              // a2 - line width ((width * NUM_PIXELS) - 2)
        lli     a3, 0x0001                  // a3 - line height
        jal     Overlay.draw_rectangle_     // draw line
        nop
        
        lw      s0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // ~
        lw      a3, 0x001C(sp)              // ~
        sw      t1, 0x0020(sp)              // ~
        lw      at, 0x0024(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Checks for various button presses and updates the menu accordingly
    // @ Arguments
    // a0 - address of info()
    scope update_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~ 
        sw      at, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~ 
        sw      a1, 0x0018(sp)              // save registers

        _down:
        lli     a0, Joypad.DOWN             // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_down            // if (down was pushed) then do update
        nop
        li      a0, Joypad.DD | Joypad.CD   // a0 - dpad/c down
        lli     a1, 00001                   // a1 - any
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = dpad/c down pressed
        nop
        beqz    v0, _up                     // if not pressed, check c-up
        nop
        _update_down:
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop        
        addiu   v0, v0,-0x0001              // v0 = num_entries - 1
        lw      t0, 0x0014(sp)              // t0 = address of info()
        addiu   t0, t0, 0x000C              // t0 = address of selection
        lw      t1, 0x0000(t0)              // t1 = selection
        sltu    at, t1, v0                  // ~
        beqz    at, _wrap_down              // if (selection == (num_entries - 1), wrap
        nop
        addiu   t1, t1, 0x0001              // t1 = selection++
        lli     a0, MAX_PER_PAGE            // a0 = MAX_PER_PAGE
        div     t1, a0                      // divide to get remainder
        mfhi    a0                          // a0 = t1 % 19
        bnez    a0, _update_down_finish     // if cursor is now on an entry not on this page, 
        nop                                 // then we need to adjust:
        addiu   t1, t1, -MAX_PER_PAGE       // t1 = selection corrected
        _update_down_finish:
        sw      t1, 0x0000(t0)              // update selection
        b       _copy                       // only allow one update
        nop

        _wrap_down:
        lli     a0, MAX_PER_PAGE            // a0 = MAX_PER_PAGE
        sltu    at, a0, t1                  // if not on the fist page
        bnez    at, _update_down_page_top   // then update to top of page
        nop                                 // otherwise update to 0:
        sw      r0, 0x0000(t0)              // update selection
        b       _copy                       // only allow one update
        nop

        _update_down_page_top:
        div     t1, a0                      // ~
        mflo    t1                          // t1 = t1 / 19 no remainder
        mult    t1, a0                      // ~
        mflo    t1                          // t1 = first row on page
        b       _update_down_finish         // update selection
        nop

        _up:
        lli     a0, Joypad.UP               // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_up              // if (up was pushed) then do update
        nop
        li      a0, Joypad.DU | Joypad.CU   // a0 - dpad/c up
        lli     a1, 00001                   // a1 - any
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = dpad/c up pressed
        nop
        beqz    v0, _right                  // if not pressed, check right
        nop
        _update_up:
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      at, 0x0014(sp)              // at = address of info()
        addiu   t0, at, 0x000C              // t0 = address of selection
        lw      t1, 0x0000(t0)              // t1 = selection
        lli     a0, MAX_PER_PAGE            // a0 = max_per_page
        div     t1, a0                      // ~
        mfhi    a0                          // a0 (row) = t1 % 19
        beqz    a0, _wrap_up                // if (row == 0), go to bottom option
        nop
        addiu   t1, t1,-0x0001              // t1 = selection--
        _wrap_up_finish:
        sw      t1, 0x0000(t0)              // update selection
        b       _copy                       // only allow one update
        nop

        _wrap_up:
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop
        addiu   v0, v0,-0x0001              // ~
        addiu   t1, t1, 00018               // t1 - last on page
        sltu    at, t1, v0                  // if the last entry is not higher than the number of entries
        bnez    at, _wrap_up_finish         // then we can use it
        nop                                 // otherwise:
        sw      v0, 0x0000(t0)              // update selection to bottom option
        b       _copy                       // only allow one update
        nop

        _right:
        lli     a0, Joypad.RIGHT            // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_right           // if (right was pushed) then do update
        nop
        li      a0, Joypad.DR | Joypad.CR   // a0 - dpad/c right
        lli     a1, 00001                   // a1 - any
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = dpad/c right pressed
        nop
        beqz    v0, _left                   // if not pressed, check left
        nop
        _update_right:
        lli     a0, FGM.menu.TOGGLE         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_selected_entry_         // v0 = selected entry
        nop
        lw      t0, 0x0004(v0)              // t0 = entry.current_value
        lw      t1, 0x000C(v0)              // t1 = entry.max_value
        sltu    at, t0, t1                  // if (entry.current_value < entry.max_value)
        beqz    at, _copy                   // then, skip
        nop                                 // else, continue
        addiu   t0, t0, 0x0001              // ~
        sw      t0, 0x0004(v0)              // entry.current_value++
        b       _copy                       // only allow one update
        nop

        _left:
        lli     a0, Joypad.LEFT             // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_left            // if (left was pushed) then do update
        nop
        li      a0, Joypad.DL | Joypad.CL   // a0 - dpad/c left
        lli     a1, 00001                   // a1 - any
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = dpad/c left pressed
        nop
        beqz    v0, _r                      // if not pressed, check R
        nop
        _update_left:
        lli     a0, FGM.menu.TOGGLE         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_selected_entry_         // v0 = selected entry
        nop
        lw      t0, 0x0004(v0)              // t0 = entry.current_value
        lw      t1, 0x0008(v0)              // t1 = entry.min_value
        sltu    at, t1, t0                  // if (entry.min_value < entry.curr_value)
        beqz    at, _copy                   // then, skip
        nop                                 // else, continue
        addiu   t0, t0,-0x0001              // ~
        sw      t0, 0x0004(v0)              // entry.current_value--
        b       _copy                       // only allow one update
        nop

        _r:
        li      a0, Joypad.R                // a0 - r button
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = r button pressed
        nop
        beqz    v0, _z                      // if not pressed, check Z
        nop
        _update_r:
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop
        lw      t0, 0x000C(a0)              // t0 - selection
        addiu   t0, t0, MAX_PER_PAGE        // t0 - selection on next page
        sw      t0, 0x000C(a0)              // update selection but maintain cursor row
        lw      t0, 0x001C(a0)              // t0 - last entry
        lw      t0, 0x001C(t0)              // t0 - next entry
        bnez    t0, _update_r_continued     // if (last entry) then go back to first page
        nop
        lw      t0, 0x000C(a0)              // t0 - selection
        lli     a2, MAX_PER_PAGE            // a2 - max_per_page
        div     t0, a2                      // ~
        mfhi    a2                          // a0 (row) = t1 % 19
        sw      a2, 0x000C(a0)              // store selection
        lw      t0, 0x0000(a0)              // t0 - head
        _update_r_continued:
        sw      t0, 0x0018(a0)              // update first entry
        sw      t0, 0x001C(a0)              // update last entry
        lw      t0, 0x000C(a0)              // t0 - selection
        addiu   v0, v0, -0x0001             // v0 - num_entries, 0 based
        sltu    at, v0, t0                  // if selection is not higher than the total number
        beqz    at, _copy                   // then we're done
        nop
        sw      v0, 0x000C(a0)              // otherwise set the total number as the selection
        b       _copy                       // only allow one update
        nop

        _z:
        // TODO: implement left pagination?

        _a:
        lli     a0, Joypad.A | Joypad.START // a0 - button_mask
        lli     a1, 0x0001                  // a1 - match any
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = someone pressed a?
        nop
        beqz    v0, _copy                   // if (a was pressed (p1/p2/p3/p4) == false), skip
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_selected_entry_         // v0 = selected entry
        nop
        lw      t0, 0x0010(v0)              // t0 = a_function address
        beqz    t0, _copy                   // if (a_function == null), skip
        nop
        jalr    t0                          // go to a_function address
        nop
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop

        _copy:
        // this block executes {function} FOR ALL (todo)
        lw      at, 0x0014(sp)              // at - address of info()
        lw      at, 0x0000(at)              // at = address of head

        _loop:
        beqz    at, _end                    // if (entry == null), end
        nop
        lw      t0, 0x0000(at)              // t0 = type
        sll     t0, t0, 0x0002              // t0 = type * 4 = offset
        li      t1, type_table              // t1 = type table
        addu    t1, t1, t0                  // t1 = type table + offset
        lw      t1, 0x0000(t1)              // t1 = type jump
        jr      t1                          // jump to function
        nop

        _u8:
        _s8:
        lw      t0, 0x0018(at)              // t0 = copy address
        beql    t0, r0, _loop               // if null, loop and at = entry->next
        lw      at, 0x001C(at)              // at = entry->next
        lw      t1, 0x0004(at)              // t1 = curr val
        sb      t1, 0x0003(t0)              // copy curr val
        b       _loop
        lw      at, 0x001C(at)              // at = entry->next

        _u16:
        _s16:
        lw      t0, 0x0018(at)              // t0 = copy address
        beql    t0, r0, _loop               // if null, loop and at = entry->next
        lw      at, 0x001C(at)              // at = entry->next
        lw      t1, 0x0004(at)              // t1 = curr val
        sh      t1, 0x0002(t0)              // copy curr val
        b       _loop
        lw      at, 0x001C(at)              // at = entry->next

        _u32:
        _s32:
        _bool:
        _title:
        lw      t0, 0x0018(at)              // t0 = copy address
        beql    t0, r0, _loop               // if null, loop and at = entry->next
        lw      at, 0x001C(at)              // at = entry->next
        lw      t1, 0x0004(at)              // t1 = curr val
        sw      t1, 0x0000(t0)              // copy curr val
        b       _loop
        lw      at, 0x001C(at)              // at = entry->next

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~ 
        lw      a1, 0x0018(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop

        type_table:
        dw _u8
        dw _u16
        dw _u32
        dw _s8
        dw _s16
        dw _s32
        dw _bool
        dw _title
    }

    // @ Description
    // Gets an entry based on selection. Helper function
    // @ Arguments
    // a0 - address of info()
    // @ Returns
    // v0 - address of entry
    scope get_selected_entry_: {
        addiu   sp, sp,-0x0010              // alloc stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      a0, 0x000C(sp)              // save registers

        // init
        lli     at, 0x0000                  // at = i = 0
        lw      t0, 0x000C(a0)              // t0 = selection
        lw      a0, 0x0000(a0)              // a0 = head

        _loop:
        beqz    a0, _fail                   // if (entry = null), end
        nop
        beq     at, t0, _end                // if (i == selection), end loop
        nop
        lw      a0, 0x001C(a0)              // a0 = entry->next
        addiu   at, at, 0x0001              // increment i 
        b       _loop                       // check again
        nop

        _end:
        move    v0, a0                      // v0 = entry
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop

        _fail:
        break                               // halt execution
    }

    // @ Description
    // This function will chnage the currently loaded SSB screen
    // @ Arguments
    // a0 - int next_screen
    scope change_screen_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.current_screen   // ~
        lb      t1, 0x0000(t0)              // t1 = current_screen
        sb      t1, 0x0001(t0)              // update previous_screen to current_screen
        sb      a0, 0x0000(t0)              // update current_screen to next_screen
        li      t0, Global.screen_interrupt // ~
        lli     t1, 0x0001                  // ~
        sw      t1, 0x0000(t0)              // generate screen_interrupt

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // allocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Returns the number of entries for a menu
    // @ Arguments
    // a0 - address of info
    // @ Returns
    // v0 - num_entries
    scope get_num_entries_: {
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      a0, 0x0004(sp)              // save a0

        lw      a0, 0x0000(a0)              // a0 = head
        lli     v0, 0x0000                  // ret = 0
        
        _loop:
        beqz    a0, _end                    // if (entry = null), end
        nop
        lw      a0, 0x001C(a0)              // a0 = entry->next
        addiu   v0, v0, 0x0001              // increment ret
        b       _loop                       // check again
        nop

        _end:
        lw      a0, 0x0004(sp)              // restore a0
        addiu   sp, sp, 0x0008              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Exports every entry of curr_value as a 32 bit value to SRAM block
    // a0 - address of head
    // a1 - address of block
    scope export_: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // save registers

        move    t0, a0                      // t0 = first entry
        addiu   a1, a1, 0x000C              // a1 = address of SRAM block data

        _loop:
        beqz    t0, _end                    // if (entry = null), end
        nop

        // skip exporting titles
        lli     t2, Menu.type.TITLE         // t2 = title type
        lw      t1, 0x0000(t0)              // t1 = type
        beq     t2, t1, _skip               // if (type == title), skip
        nop

        lw      t1, 0x0004(t0)              // t1 = entry.curr_value
        sw      t1, 0x0000(a1)              // export
        addiu   a1, a1, 0x0004              // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)              // t0 = entry->next
        b       _loop                       // check again
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a1, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Imports a set of given 32 bit values to each entry's curr_value 
    // a0 - address of head
    // a1 - address of block
    scope import_: {
        addiu   sp, sp,-0x0014              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // save registers

        move    t0, a0                      // t0 = first entry
        addiu   a1, a1, 0x000C              // a1 = address of SRAM block data
        
        _loop:
        beqz    t0, _end                    // if (entry = null), end
        nop

        // skip titles when importing
        lli     t2, Menu.type.TITLE         // t2 = title type
        lw      t1, 0x0000(t0)              // t1 = type
        beq     t2, t1, _skip               // if (type == title), skip
        nop

        lw      t1, 0x0000(a1)              // t1 = value at ram_address
        sw      t1, 0x0004(t0)              // update curr_value
        addiu   a1, a1, 0x0004              // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)              // t0 = entry->next
        b       _loop                       // check again
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a1, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }

}

} // __MENU__
