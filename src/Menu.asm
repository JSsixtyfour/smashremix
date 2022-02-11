// Menu.asm
if !{defined __MENU__} {
define __MENU__()
print "included Menu.asm\n"

include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "OS.asm"
include "String.asm"

scope Menu {

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
    macro info(head, ulx, uly, room, group, width, cursor_color, label_color, value_color, scale, row_height, max_per_page, blur, dpad) {
        dw {head}                           // 0x0000 - address of menu head
        dh {ulx}                            // 0x0004 - ulx
        dh {uly}                            // 0x0006 - uly
        dw 0x00000000                       // 0x0008 - object reference for cursor
        dw 0x00000000                       // 0x000C - selection
        dh {room}                           // 0x0010 - room
        dh {group}                          // 0x0012 - group
        dw {width}                          // 0x0014 - width of menu in chars
        dw {head}                           // 0x0018 - first entry currently displayed (default to head)
        dw {head}                           // 0x001C - last entry currently displayed (default to head)
        dw {cursor_color}                   // 0x0020 - cursor color
        dw {label_color}                    // 0x0024 - label color
        dw {value_color}                    // 0x0028 - value color
        dw {scale}                          // 0x002C - scale
        dh {row_height}                     // 0x0030 - row height
        dh {max_per_page}                   // 0x0032 - max rows per page
        dh {blur}                           // 0x0034 - blur
        dh {dpad}                           // 0x0036 - allow dpad control
    }

    // @ Description
    // Struct for menu arguments, dpad control on.
    macro info(head, ulx, uly, room, group, width, cursor_color, label_color, value_color, scale, row_height, max_per_page, blur) {
        info({head}, {ulx}, {uly}, {room}, {group}, {width}, {cursor_color}, {label_color}, {value_color}, {scale}, {row_height}, {max_per_page}, {blur}, OS.TRUE)
    }

    // @ Description
    // Struct for menu arguments using default scale, blur and dpad control.
    macro info(head, ulx, uly, room, group, width, cursor_color, label_color, value_color) {
        Menu.info({head}, {ulx}, {uly}, {room}, {group}, {width}, {cursor_color}, {label_color}, {value_color}, Render.FONTSIZE_DEFAULT, 0x0E, 12, 0x0001, OS.TRUE)
    }

    // @ Description
    // Struct for menu entries
    macro entry(title, type, default, min, max, a_function, extra, string_table, copy_address, next) {
        define address(pc())
        dw {type}                           // 0x0000 - type (int, bool, etc.)
        dw {default}                        // 0x0004 - current value
        dw {min}                            // 0x0008 - minimum value
        dw {max}                            // 0x000C - maximum value
        dw {a_function}                     // 0x0010 - if (!null), function ran when A is pressed
        dw {string_table}                   // 0x0014 - if (!null), use table of string pointers
        dw {copy_address}                   // 0x0018 - if (!null), copies curr_value to address
        dw {next}                           // 0x001C - if !(null), address of next entry
        dw 0x00000000                       // 0x0020 - will store reference to string object of label
        dw {extra}                          // 0x0024 - extra space useful for a_function
        db {title}                          // 0x0028 - title
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
        Menu.entry({title}, Menu.type.BOOL, {default}, 0, 1, OS.NULL, OS.NULL, Menu.bool_string_table, OS.NULL, {next})
    }

    macro entry_title(title, a_function, next) {
        Menu.entry({title}, Menu.type.TITLE, 0, 0, 0, {a_function}, OS.NULL, OS.NULL, OS.NULL, {next})
    }

    macro entry_title_with_extra(title, a_function, extra, next) {
        Menu.entry({title}, Menu.type.TITLE, 0, 0, 0, {a_function}, {extra}, OS.NULL, OS.NULL, {next})
    }

    // @ Description
    // Updates the string object with the correct value
    // @ Arguments
    // v0 - address of entry
    scope update_pointer_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // ~

        // v0 = selected entry
        lw      t0, 0x0020(v0)              // t0 = label object
        beqz    t0, _end                    // if not defined, skip
        nop
        lw      t0, 0x0030(t0)              // t0 = value object
        beqz    t0, _end                    // if not defined, skip
        nop
        lw      t1, 0x004C(t0)              // t1 = string_type
        srl     t1, t1, 0x0001              // t1 = 1 if number, 0 if not
        bnez    t1, _end                    // if a number, skip
        nop

        lw      t1, 0x0004(v0)              // t1 = current value
        lw      at, 0x0014(v0)              // at = entry.string_table
        sll     t1, t1, 0x0002              // t1 = curr * sizeof(string pointer)
        addu    t1, at, t1                  // ~
        lw      t1, 0x0000(t1)              // a2 - address of string
        sw      t1, 0x0034(t0)              // update current value in object

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draw a menu entry (title, on/off)
    // @ Arguments
    // a0 - address of entry
    // a1 - ulx
    // a2 - uly
    // a3 - urx
    // t0 - room
    // t1 - group
    // t2 - label color
    // t3 - value color
    // t4 - scale
    // t5 - blur
    scope draw_entry_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      t1, 0x0014(sp)              // ~
        sw      ra, 0x0018(sp)              // ~
        sw      a0, 0x001C(sp)              // ~
        sw      a1, 0x0020(sp)              // ~
        sw      a2, 0x0024(sp)              // ~
        sw      a3, 0x0028(sp)              // ~
        sw      t2, 0x002C(sp)              // ~
        sw      t3, 0x0030(sp)              // ~
        sw      t4, 0x0034(sp)              // ~
        sw      t5, 0x0038(sp)              // save registers

        lw      s0, 0x001C(sp)              // s0 = entry

        lwc1    f0, 0x0020(sp)              // f0 = ulx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x0024(sp)              // f0 = uly
        cvt.s.w f0, f0                      // ~
        mfc1    s2, f0                      // s2 = uly

        lw      a0, 0x0010(sp)              // a0 = room
        lw      a1, 0x0014(sp)              // a1 = group
        addiu   a2, s0, 0x0028              // a2 - address of string (title = entry + 0x0028)
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      s3, 0x002C(sp)              // s3 = color
        or      s4, r0, t4                  // s4 = scale
        lli     s5, Render.alignment.LEFT
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lw      t8, 0x0038(sp)              // t8 = blur

        lw      s0, 0x001C(sp)              // s0 = entry
        sw      v0, 0x0020(s0)              // save reference to label object
        // 0x0030(v0) will be the value string object, if applicable

        lli     t0, Menu.type.TITLE         // t0 = title type
        lw      t1, 0x0000(s0)              // t1 = type
        beql    t0, t1, _end                // if (type == title), end
        sw      r0, 0x0030(v0)              // clear reference to value string object

        lw      t0, 0x0014(s0)              // at = entry.string_table
        bnez    t0, _string                 // if (entry.string_table != null), skip
        nop                                 // else, continue

        _number:
        addiu   a2, s0, 0x0004              // a0 - pointer to value
        lli     s6, Render.string_type.NUMBER
        lli     s7, 0x0000                  // s7 = adjust amount = 0
        b       _draw_value                 // skip draw string
        nop

        _string:
        lw      t1, 0x0004(s0)              // at = (int) current value
        sll     t1, t1, 0x0002              // t1 = curr * sizeof(string pointer)
        addu    a2, t0, t1                  // ~
        lw      a2, 0x0000(a2)              // a2 - address of string
        lli     s6, Render.string_type.TEXT

        _draw_value:
        lwc1    f0, 0x0028(sp)              // f0 = urx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lwc1    f0, 0x0024(sp)              // f0 = uly
        cvt.s.w f0, f0                      // ~
        mfc1    s2, f0                      // s2 = uly

        lw      a0, 0x0010(sp)              // a0 = room
        lw      a1, 0x0014(sp)              // a1 = group
        li      a3, Render.update_live_string_ // a3 = routine
        lw      s3, 0x0030(sp)              // s3 = color
        lw      s4, 0x0034(sp)              // s4 = scale
        lli     s5, Render.alignment.RIGHT
        jal     Render.draw_string_
        lw      t8, 0x0038(sp)              // t8 = blur
        lw      s0, 0x001C(sp)              // s0 = entry
        lw      t0, 0x0020(s0)              // t0 = reference to label object
        sw      v0, 0x0030(t0)              // save reference to value object
        addiu   t0, t0, 0x0030              // t0 = address of reference to value object
        sw      t0, 0x0054(v0)              // store address of reference to value object

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
        lw      a3, 0x0028(sp)              // ~
        lw      t2, 0x002C(sp)              // ~
        lw      t3, 0x0030(sp)              // ~
        lw      t4, 0x0034(sp)              // ~
        lw      t5, 0x0038(sp)              // restore registers
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Destroys rendered menu entries
    // @ Arguments
    // a0 - address of first entry currently displayed
    scope destroy_rendered_objects_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      s0, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~

        _loop:
        lw      a0, 0x0020(a0)              // a0 = label object for this entry
        beqz    a0, _end                    // skip if no object
        nop
        jal     Render.DESTROY_OBJECT_
        nop
        lw      a1, 0x0008(sp)              // a1 = address of current entry
        lw      a1, 0x0020(a1)              // a1 = label object for this entry
        lw      a0, 0x0030(a1)              // a0 = value object for this entry
        beqz    a0, _continue               // skip if no object
        sw      r0, 0x0030(a1)              // clear value object reference
        jal     Render.DESTROY_OBJECT_
        nop

        _continue:
        lw      a1, 0x0008(sp)              // a1 = address of current entry
        sw      r0, 0x0020(a1)              // clear object reference
        lw      a0, 0x001C(a1)              // a0 = address of next entry
        bnez    a0, _loop                   // loop if there is a next entry
        sw      a0, 0x0008(sp)              // save address of next entry

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      s0, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Redraw linked list of menu entries
    // @ Arguments
    // a0 - address of Menu.info()
    // a1 - address of first entry currently displayed
    scope redraw_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      s0, 0x0010(sp)              // ~

        jal     destroy_rendered_objects_
        or      a0, r0, a1                  // a0 = address of first entry currently displayed
        jal     draw_
        lw      a0, 0x0008(sp)              // a0 = address of Menu.info()
        jal     update_cursor_
        lw      a0, 0x0008(sp)              // a0 = address of Menu.info()

        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      s0, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draw linked list of menu entries
    // @ Arguments
    // a0 - address of Menu.info()
    scope draw_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // ~
        sw      a3, 0x001C(sp)              // ~
        sw      t1, 0x0020(sp)              // ~
        sw      at, 0x0024(sp)              // save registers

        // PJ64K has some weird memory issues, so we save a lot of info to the stack instead of using info() in the loop
        lw      at, 0x0010(sp)              // at = address of info()
        lw      s0, 0x0018(at)              // s0 = head (aka current_entry)
        lhu     a1, 0x0004(at)              // a1 - ulx, unadjusted
        lw      a3, 0x0014(at)              // a3 = width
        sll     a3, a3, 0x0003              // a3 = urx_difference
        addu    a3, a3, a1                  // a3 - urx
        addiu   a1, a1, 0x0008              // a1 - ulx, adjusted
        lhu     a2, 0x0006(at)              // a2 - uly
        sh      a1, 0x0028(sp)              // save adjusted ulx
        sh      a2, 0x002A(sp)              // save uly
        sh      a3, 0x002C(sp)              // save urx
        lhu     t0, 0x0030(at)              // t0 = row_height
        lhu     t1, 0x0032(at)              // t1 = max_per_page
        multu   t0, t1
        mflo    t0                          // t0 = row_height * max_per_page
        addu    t0, t0, a2                  // t0 = max height
        sh      t0, 0x002E(sp)              // save max height
        lhu     t0, 0x0010(at)              // t0 = room
        sh      t0, 0x0030(sp)              // save room
        lhu     t1, 0x0012(at)              // t1 = group
        sh      t1, 0x0032(sp)              // save group
        lw      t2, 0x0024(at)              // t2 = label color
        sw      t2, 0x0034(sp)              // save label color
        lw      t3, 0x0028(at)              // t3 = value color
        sw      t3, 0x0038(sp)              // save value color
        lw      t4, 0x002C(at)              // t4 = scale
        sw      t4, 0x003C(sp)              // save scale
        lhu     t5, 0x0034(at)              // t5 = blur
        sw      t5, 0x0040(sp)              // save blur

        _loop:
        lhu     t0, 0x002A(sp)              // t0 = current uly
        lhu     at, 0x002E(sp)              // at = max height
        sltu    at, t0, at                  // if we don't have enough room to draw any more entries, end
        beqz    at, _end                    // ~
        nop
        move    a0, s0                      // a0 - entry
        lw      at, 0x0010(sp)              // at = address of info()
        sw      a0, 0x001C(at)              // update last entry displayed
        lhu     a1, 0x0028(sp)              // a1 - ulx
        move    a2, t0                      // a2 - uly
        lhu     t1, 0x0030(at)              // t1 = height of row, unadjusted
        mtc1    t1, f0                      // f0 = height of row, unadjusted
        cvt.s.w f0, f0                      // ~
        li      t2, Render.default_font_size
        lw      t2, 0x0000(t2)              // t2 = normal scale
        mtc1    t2, f2                      // f2 = normal scale
        lwc1    f4, 0x003C(sp)              // f4 = scale
        div.s   f4, f4, f2                  // f4 = multiplier
        mul.s   f0, f4, f0                  // f0 = height of row, adjusted
        trunc.w.s f0, f0                    // ~
        mfc1    t1, f0                      // s0 = height of row, adjusted
        addu    t0, t0, t1                  // increment height
        sh      t0, 0x002A(sp)              // save height
        lhu     a3, 0x002C(sp)              // a3 = urx
        lhu     t0, 0x0030(sp)              // t0 = room
        lhu     t1, 0x0032(sp)              // t1 = group
        lw      t2, 0x0034(sp)              // t2 = label color
        lw      t3, 0x0038(sp)              // t3 = value color
        lw      t4, 0x003C(sp)              // t4 = scale
        jal     draw_entry_
        lw      t5, 0x0040(sp)              // t5 = blur
        lw      s0, 0x001C(s0)              // s0 = entry->next
        bnez    s0, _loop                   // if (entry->next != NULL), loop
        nop

        _end:
        // draw selection cursor
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lw      t0, 0x0008(at)              // t0 = reference to cursor object
        bnez    t0, _update_cursor          // if the cursor object exists, update it
        nop                                 // otherwise, create it

        lhu     a0, 0x0010(at)              // a0 = room
        lhu     a1, 0x0012(at)              // a1 = group
        lhu     s1, 0x0004(at)              // s1 = menu ulx
        addiu   s1, s1, 0x0002              // s1 = ulx + 2
        lli     s2, 0                       // s2 = uly (temporary)
        lli     s3, 0x0004                  // s3 = width
        lli     s4, 0x0004                  // s4 = height
        lw      s5, 0x0020(at)              // s5 = color
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        sw      v0, 0x0008(at)              // save reference to cursor object

        //  draw selection line
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lhu     a0, 0x0010(at)              // a0 = room
        lhu     a1, 0x0012(at)              // a1 = group
        lhu     s1, 0x0004(at)              // s1 = menu ulx
        addiu   s1, s1, 0x0002              // s1 = ulx + 2
        lli     s2, 0                       // s2 = uly (temporary)
        lw      s3, 0x0014(at)              // s3 = width
        sll     s3, s3, 0x0003              // s3 = (width) * NUM_PIXELS
        addiu   s3, s3,-0x0002              // s3 = line width ((width * NUM_PIXELS) - 2)
        lli     s4, 0x0001                  // s4 = line height
        lw      s5, 0x0020(at)              // s5 = color
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lw      t0, 0x0008(at)              // t0 = reference to cursor object
        sw      v0, 0x0084(t0)              // save reference to underline

        _update_cursor:
        jal     update_cursor_
        or      a0, at, r0                  // a0 = Menu.info()

        _finish:
        lw      s0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // ~
        lw      a3, 0x001C(sp)              // ~
        sw      t1, 0x0020(sp)              // ~
        lw      at, 0x0024(sp)              // restore registers
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Updates cursor position
    // @ Arguments
    // a0 - address of info()
    scope update_cursor_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      v0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      s0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // save registers

        lw      v0, 0x0008(a0)              // v0 = reference to cursor object
        lw      t0, 0x000C(a0)              // t0 = selection
        lhu     t1, 0x0032(a0)              // t1 = max rows per page
        div     t0, t1                      // divide selection by rows per page to get row
        mfhi    t0                          // t0 - row
        lhu     s0, 0x0030(a0)              // s0 = height of row, unadjusted
        mtc1    s0, f0                      // f0 = height of row, unadjusted
        cvt.s.w f0, f0                      // ~
        li      a1, Render.default_font_size
        lw      a1, 0x0000(a1)              // a1 = normal scale
        mtc1    a1, f2                      // f2 = normal scale
        lwc1    f4, 0x002C(a0)              // f4 = scale
        div.s   f4, f4, f2                  // f4 = multiplier
        mul.s   f0, f4, f0                  // f0 = height of row, adjusted
        trunc.w.s f0, f0                    // ~
        mfc1    s0, f0                      // s0 = height of row, adjusted
        mult    t0, s0                      // ~
        mflo    a1                          // a1 = height of row
        lhu     t0, 0x0006(a0)              // t0 = menu uly
        addu    a1, a1, t0                  // a1 - uly
        addu    t1, a1, s0                  // t1 - uly of next
        addiu   t1, t1, -0x0001             // t1 - uly of underline
        addiu   a1, t1, -0x0006             // a1 - uly of cursor
        sw      a1, 0x0034(v0)              // update cursor y
        addiu   a1, a1, 0x0006              // a1 - uly + 6
        lw      v0, 0x0084(v0)              // v0 = underline object
        sw      t1, 0x0034(v0)              // update underline y

        lw      v0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      s0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lw      t0, 0x0014(sp)              // t0 = info()
        lhu     t0, 0x0036(t0)              // t0 = allow dpad
        lli     a0, Joypad.DD | Joypad.CD   // a0 - dpad/c down
        beqzl   t0, pc() + 8                // if dpad not allowed, just check C
        lli     a0, Joypad.CD               // a0 - c down
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
        lhu     a0, 0x0032(t0)              // a0 = MAX_PER_PAGE
        addiu   t0, t0, 0x000C              // t0 = address of selection
        lw      t1, 0x0000(t0)              // t1 = selection
        sltu    at, t1, v0                  // ~
        beqz    at, _wrap_down              // if (selection == (num_entries - 1), wrap
        nop
        addiu   t1, t1, 0x0001              // t1 = selection++
        div     t1, a0                      // divide to get remainder
        mfhi    a1                          // a1 = t1 % 18
        bnez    a1, _update_down_finish     // if cursor is now on an entry not on this page,
        nop                                 // then we need to adjust:
        subu    t1, t1, a0                  // t1 = selection corrected
        _update_down_finish:
        sw      t1, 0x0000(t0)              // update selection
        jal     update_cursor_
        lw      a0, 0x0014(sp)              // a0 - address of info()
        b       _copy                       // only allow one update
        nop

        _wrap_down:
        sltu    at, a0, t1                  // if not on the fist page
        bnez    at, _update_down_page_top   // then update to top of page
        nop                                 // otherwise update to 0:
        sw      r0, 0x0000(t0)              // update selection
        jal     update_cursor_
        lw      a0, 0x0014(sp)              // a0 - address of info()
        b       _copy                       // only allow one update
        nop

        _update_down_page_top:
        div     t1, a0                      // ~
        mflo    t1                          // t1 = t1 / 18 no remainder
        mult    t1, a0                      // ~
        mflo    t1                          // t1 = first row on page
        b       _update_down_finish         // update selection
        nop

        _up:
        lli     a0, Joypad.UP               // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_up              // if (up was pushed) then do update
        lw      t0, 0x0014(sp)              // t0 = info()
        lhu     t0, 0x0036(t0)              // t0 = allow dpad
        li      a0, Joypad.DU | Joypad.CU   // a0 - dpad/c up
        beqzl   t0, pc() + 8                // if dpad not allowed, just check C
        lli     a0, Joypad.CU               // a0 - c up
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
        lhu     a0, 0x0032(at)              // a0 = max_per_page
        div     t1, a0                      // ~
        mfhi    a0                          // a0 (row) = t1 % 18
        beqz    a0, _wrap_up                // if (row == 0), go to bottom option
        nop
        addiu   t1, t1,-0x0001              // t1 = selection--
        _wrap_up_finish:
        sw      t1, 0x0000(t0)              // update selection
        jal     update_cursor_
        lw      a0, 0x0014(sp)              // a0 - address of info()
        b       _copy                       // only allow one update
        nop

        _wrap_up:
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop
        addiu   v0, v0,-0x0001              // ~
        lw      at, 0x0014(sp)              // at = address of info()
        lhu     a0, 0x0032(at)              // a0 = max_per_page
        addu    t1, t1, a0                  // t1 - last on page
        addiu   t1, t1, -0x0001             // ~
        sltu    at, t1, v0                  // if the last entry is not higher than the number of entries
        bnez    at, _wrap_up_finish         // then we can use it
        nop                                 // otherwise:
        sw      v0, 0x0000(t0)              // update selection to bottom option
        jal     update_cursor_
        lw      a0, 0x0014(sp)              // a0 - address of info()
        b       _copy                       // only allow one update
        nop

        _right:
        lli     a0, Joypad.RIGHT            // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_right           // if (right was pushed) then do update
        lw      t0, 0x0014(sp)              // t0 = info()
        lhu     t0, 0x0036(t0)              // t0 = allow dpad
        li      a0, Joypad.DR | Joypad.CR   // a0 - dpad/c right
        beqzl   t0, pc() + 8                // if dpad not allowed, just check C
        lli     a0, Joypad.CR               // a0 - c right
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
        sltu    at, t0, t1                  // at = 1 if entry.current_value < entry.max_value
        bnez    at, _update_right_save      // if (entry.current_value < entry.max_value)...
        addiu   t0, t0, 0x0001              // ...then update to next value
        // otherwise, set to min
        lw      t0, 0x0008(v0)              // t1 = entry.min_value
        _update_right_save:
        sw      t0, 0x0004(v0)              // entry.current_value++
        jal     update_pointer_
        nop
        b       _copy                       // only allow one update
        nop

        _left:
        lli     a0, Joypad.LEFT             // a1 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = boolean
        nop
        bnez    v0, _update_left            // if (left was pushed) then do update
        lw      t0, 0x0014(sp)              // t0 = info()
        lhu     t0, 0x0036(t0)              // t0 = allow dpad
        li      a0, Joypad.DL | Joypad.CL   // a0 - dpad/c left
        beqzl   t0, pc() + 8                // if dpad not allowed, just check C
        lli     a0, Joypad.CL               // a0 - c left
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
        sltu    at, t1, t0                  // at = 1 if entry.min_value < entry.curr_value
        bnez    at, _update_left_save       // if (entry.min_value < entry.curr_value)...
        addiu   t0, t0, -0x0001             // ...then update to previous value
        // otherwise, set to max
        lw      t0, 0x000C(v0)              // t1 = entry.max_value
        _update_left_save:
        sw      t0, 0x0004(v0)              // entry.current_value--
        jal     update_pointer_
        nop
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
        lhu     a2, 0x0032(a0)              // a2 = max_per_page
        addu    t0, t0, a2                  // t0 - selection on next page
        sw      t0, 0x000C(a0)              // update selection but maintain cursor row
        lw      t0, 0x001C(a0)              // t0 - last entry
        lw      t0, 0x001C(t0)              // t0 - next entry
        bnez    t0, _update_r_continued     // if (last entry) then go back to first page
        nop
        lw      t0, 0x000C(a0)              // t0 - selection
        div     t0, a2                      // ~
        mfhi    a2                          // a2 (row) = t0 % max_per_page
        sw      a2, 0x000C(a0)              // store selection
        lw      t0, 0x0000(a0)              // t0 - head
        _update_r_continued:
        lw      a1, 0x0018(a0)              // a1 = first entry
        sw      t0, 0x0018(a0)              // update first entry
        sw      t0, 0x001C(a0)              // update last entry
        lw      t0, 0x000C(a0)              // t0 - selection
        addiu   v0, v0, -0x0001             // v0 - num_entries, 0 based
        sltu    at, v0, t0                  // if selection is not higher than the total number
        beqz    at, _redraw                 // then we're done
        nop
        sw      v0, 0x000C(a0)              // otherwise set the total number as the selection

        _redraw:
        jal     redraw_
        nop
        b       _copy                       // only allow one update
        nop

        _z:
        li      a0, Joypad.Z                // a0 - z button
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = z button pressed
        nop
        beqz    v0, _a                      // if not pressed, check a
        nop
        _update_z:
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id
        jal     FGM.play_                   // play menu sound
        nop
        lw      a0, 0x0014(sp)              // a0 - address of info()
        jal     get_num_entries_            // v0 = num_entries
        nop
        addiu   v0, v0, -0x0001             // v0 = num_entries, 0 based
        sh      v0, 0x001C(sp)              // temporarily save number of entries in free space
        lhu     a2, 0x0032(a0)              // a2 = max_per_page
        divu    v0, a2                      // t1 = number of pages, 0 based
        mflo    t1                          // ~
        beqz    t1, _a                      // if only one page, skip
        lw      t0, 0x000C(a0)              // t0 - selection
        div     t0, a2                      // ~
        mfhi    at                          // at (row) = t0 % max_per_page
        sw      at, 0x001C(a0)              // temporarily store row
        subu    t0, t0, a2                  // t0 - selection on previous page
        bltz    t0, _get_first_entry        // if there is not a previous page, then get last page
        nop                                 // otherwise, we have to get the previous page
        div     t0, a2                      // t1 = page
        mflo    t1                          // ~
        _get_first_entry:
        lli     at, 0x0000                  // at = loop index
        lli     v0, 0x0000                  // v0 = row
        lw      t0, 0x0000(a0)              // t0 = very first menu entry
        _z_loop:
        beq     at, t1, _found_first_entry  // this will trip if we are going to the first page
        nop
        lw      t0, 0x001C(t0)              // t0 = next entry
        addiu   v0, v0, 0x0001              // v0++
        bne     v0, a2, _z_loop             // loop until we get the next page's first entry
        nop
        addiu   at, at, 0x0001              // at++ (page)
        bnel    at, t1, _z_loop             // if not on the target page, continue looping
        lli     v0, 0x0000                  // reset v0 to first row
        _found_first_entry:
        multu   t1, a2
        mflo    t1                          // t1 = selection of first row
        lw      at, 0x001C(a0)              // at = current row
        addu    t1, t1, at                  // t1 = selection
        sw      t1, 0x000C(a0)              // update selection

        lw      a1, 0x0018(a0)              // a1 = first entry
        sw      t0, 0x0018(a0)              // update first entry
        sw      t0, 0x001C(a0)              // update last entry
        lw      t0, 0x000C(a0)              // t0 = row
        lh      v0, 0x001C(sp)              // v0 = num_entries, 0 based
        sltu    at, v0, t0                  // if selection is not higher than the total number
        beqz    at, _redraw                 // then we're done
        nop
        b       _redraw
        sw      v0, 0x000C(a0)              // otherwise set the total number as the selection

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
    // This function will change the currently loaded SSB screen
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
