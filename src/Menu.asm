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
        constant TITLE(0x0000)              // has no value on the right
        constant MAX1(0x0001)               // 01 bit integer
        constant BOOL(MAX1)                 // bool (01 bit integer)
        constant MAX3(0x0002)               // 02 bit integer
        constant MAX7(0x0003)               // 03 bit integer
        constant MAX15(0x0004)              // 04 bit integer
        constant MAX31(0x0005)              // 05 bit integer
        constant MAX63(0x0006)              // 06 bit integer
        constant MAX127(0x0007)             // 07 bit integer
        constant MAX255(0x0008)             // 08 bit integer
        constant MAX511(0x0009)             // 09 bit integer
        constant MAX1023(0x000A)            // 10 bit integer
        constant INPUT(0x000B)              // has no value on the right, has edit mode
        constant INT(0x000C)                // generic integer (size determined when saved to SRAM)
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
        if {type} == Menu.type.INT {
            if {max} <= 1 {
                dw Menu.type.MAX1           // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 3 {
                dw Menu.type.MAX3           // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 7 {
                dw Menu.type.MAX7           // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 15 {
                dw Menu.type.MAX15          // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 31 {
                dw Menu.type.MAX31          // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 64 {
                dw Menu.type.MAX63          // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 127 {
                dw Menu.type.MAX127         // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 255 {
                dw Menu.type.MAX255         // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 511 {
                dw Menu.type.MAX511         // 0x0000 - type (int, bool, etc.)
            } else if {max} <= 1023 {
                dw Menu.type.MAX1023        // 0x0000 - type (int, bool, etc.)
            }
        } else {
            dw {type}                       // 0x0000 - type (int, bool, etc.)
        }
        dw {default}                        // 0x0004 - current value (edit mode flag for type.INPUT)
        dw {min}                            // 0x0008 - minimum value
        dw {max}                            // 0x000C - maximum value
        dw {a_function}                     // 0x0010 - if (!null), function ran when A is pressed
        dw {string_table}                   // 0x0014 - if (!null), use table of string pointers
        dw {copy_address}                   // 0x0018 - if (!null), copies curr_value to address
        dw {next}                           // 0x001C - if !(null), address of next entry
        dw 0x00000000                       // 0x0020 - will store reference to string object of label
        dw {extra}                          // 0x0024 - extra space useful for a_function
        if {type} == Menu.type.INPUT {
            fill {max}                      // 0x0028 - title
        } else {
            db {title}                      // 0x0028 - title
            db 0x00
        }
        OS.align(4)
    }

    // @ Description
    // Aligns characters in a char set string with the keyboard layout
    // @ Arguments
    // a0 - char set string object
    scope align_keyboard_chars_: {
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      t0, 0x0014(sp)              // ~
        sw      t1, 0x0018(sp)              // ~
        sw      t2, 0x001C(sp)              // ~
        sw      t8, 0x0020(sp)              // ~
        sw      v0, 0x0024(sp)              // ~

        or      v0, a0, r0                  // v0 = string object

        lw      t0, 0x0074(v0)              // t0 = first char image struct
        lw      a0, 0x0030(v0)              // a0 = first char address
        li      a1, Render.character_offsets_custom
        lli     t8, 0x0000                  // t8 = index
        lui     at, 0x3F00                  // at = .5, fp
        mtc1    at, f0                      // f0 = .5
        lui     at, 0x41C0                  // at = 24, fp
        mtc1    at, f4                      // f4 = 24 = width of each column / height of each row
        lui     at, 0x4248                  // at = 50, fp
        mtc1    at, f6                      // f6 = 50 = first column mid point
        mtc1    at, f16                     // f16 = 50 = first column mid point
        lui     at, 0x42B2                  // at = 89, fp
        mtc1    at, f8                      // f6 = 89 = first row start

        _keyboard_set_loop:
        lbu     t1, 0x0000(a0)              // t1 = char
        beqz    t1, _end_keyboard_setup     // if no more chars, end loop
        addiu   t1, t1, -0x0020             // t1 = index in character_offsets_custom
        sll     t1, t1, 0x0003              // t1 = offset in character_offsets_custom
        addu    a2, a1, t1                  // a2 = address of width
        lbu     t2, 0x0000(a2)              // t2 = width
        mtc1    t2, f2                      // f2 = width, decimal
        cvt.s.w f2, f2                      // f2 = width, fp
        mul.s   f2, f2, f0                  // f2 = width/2
        sub.s   f2, f6, f2                  // f2 = x to use
        swc1    f2, 0x0058(t0)              // set x
        swc1    f8, 0x005C(t0)              // set y
        add.s   f6, f6, f4                  // f6 = next column mid point
        lli     t2, 9
        bne     t2, t8, _keyboard_next      // if not the last one, continue
        addiu   t8, t8, 0x0001              // index++
        mov.s   f6, f16                     // f6 = first column mid point
        add.s   f8, f8, f4                  // f8 = next row start
        lli     t8, 0x0000                  // reset index

        _keyboard_next:
        lw      t0, 0x0008(t0)              // t0 = next char image struct
        bnez    t0, _keyboard_set_loop      // if there is another char image, keep looping
        addiu   a0, a0, 0x0001              // a0 = next char address

        _end_keyboard_setup:
        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      t0, 0x0014(sp)              // ~
        lw      t1, 0x0018(sp)              // ~
        lw      t2, 0x001C(sp)              // ~
        lw      t8, 0x0020(sp)              // ~
        lw      v0, 0x0024(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Holds the keyboard set index in keyboard_sets below
    keyboard_set:
    dw 0

    // @ Description
    // Holds address of keyboard set strings.
    // Setting it up as lower, upper makes it so case is preserved when changing back to alphanumeric from symbol
    keyboard_sets:
    dw keyboard_set_lower, keyboard_set_upper
    dw keyboard_set_symbol, keyboard_set_symbol

    // @ Description
    // Points to the string used for the change keyboard set button
    keyboard_set_button:
    dw string_sym

    // @ Description
    // Maps the keyboard set to the string used for the change keyboard set button
    keyboard_set_buttons:
    dw string_sym, string_sym
    dw string_abc, string_abc

    // @ Description
    // Holds references to the rectangle objects used for keyboard cursor
    keyboard_struct:
    dw 0                    // 0x0000 - cursor outline rectangle
    dw 0                    // 0x0004 - cursor inner rectangle
    dw 0                    // 0x0008 - keyboard chars string object
    dw 0                    // 0x000C - keyboard tag string object

    // @ Description
    // column, row of cursor
    keyboard_cursor_index:
    dh 0, 0

    // @ Description
    // Strings used to render the keyboard
    keyboard_set_lower:; db "0123456789abcdefghijklmnopqrstuvwxyz", 0
    keyboard_set_upper:; db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
    keyboard_set_symbol:; db "!@#$%^&*()<>{}[]+-=_,.:;\s\d", 0x5C, "/?`|~", '~' + 1, '~' + 2, "??", 0
    OS.align(4)

    // @ Description
    // This holds the string being edited
    keyboard_input_string:
    fill 24

    // @ Description
    // This keeps track of the cursor when editing
    char_index:
    db 0x0

    // @ Description
    // Flag used to check if canceling edit mode
    cancel_edit:
    db 0x0

    bool_0:; db "OFF", 0x00
    bool_1:; db "ON", 0x00
    string_not_set:; db "-- Not Set --", 0x00
    string_ok:; db "OK", 0x00
    string_del:; db "DEL", 0x00
    string_sym:; db "SYM", 0x00
    string_abc:; db "ABC", 0x00
    OS.align(4)

    bool_string_table:
    dw bool_0
    dw bool_1

    macro entry_bool(title, default, next) {
        Menu.entry({title}, Menu.type.BOOL, {default}, 0, 1, OS.NULL, OS.NULL, Menu.bool_string_table, OS.NULL, {next})
    }

    macro entry_bool_with_extra(title, default, extra, next) {
        Menu.entry({title}, Menu.type.BOOL, {default}, 0, 1, OS.NULL, {extra}, Menu.bool_string_table, OS.NULL, {next})
    }

    macro entry_title(title, a_function, next) {
        Menu.entry({title}, Menu.type.TITLE, 0, 0, 0, {a_function}, OS.NULL, OS.NULL, OS.NULL, {next})
    }

    macro entry_title_with_extra(title, a_function, extra, next) {
        Menu.entry({title}, Menu.type.TITLE, 0, 0, 0, {a_function}, {extra}, OS.NULL, OS.NULL, {next})
    }

    macro entry_input(a_function, extra, next) {
        Menu.entry("", Menu.type.INPUT, 0, 0, 20, {a_function}, {extra}, OS.NULL, OS.NULL, {next})
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
        lw      t0, 0x006C(t0)              // t0 = value object
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

        lw      s3, 0x002C(sp)              // s3 = color
        lw      a0, 0x0010(sp)              // a0 = room
        lw      a1, 0x0014(sp)              // a1 = group

        addiu   a2, s0, 0x0028              // a2 - address of string (title = entry + 0x0028)
        lli     t0, Menu.type.INPUT         // t0 = input type
        lw      t1, 0x0000(s0)              // t1 = type
        bne     t0, t1, _draw_label         // if (type != input), then use title text
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)

        li      a3, Render.update_live_string_ // a3 = routine

        lbu     t0, 0x0000(a2)              // t0 = first character
        bnez    t0, _draw_label             // if there is a title defined, use it
        nop

        // if here, display a default string and gray it out
        li      a2, string_not_set          // a2 = address of string to use when input not set
        li      s3, 0x808080FF              // s3 = set color to gray when not set

        _draw_label:
        or      s4, r0, t4                  // s4 = scale
        lli     s5, Render.alignment.LEFT
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lw      t8, 0x0038(sp)              // t8 = blur

        lw      s0, 0x001C(sp)              // s0 = entry
        sw      v0, 0x0020(s0)              // save reference to label object
        // 0x006C(v0) will be the value string object, if applicable
        addiu   t0, s0, 0x0020              // t0 = address of reference to label object
        sw      t0, 0x0054(v0)              // store address of reference to label object

        lli     t0, Menu.type.TITLE         // t0 = title type
        lw      t1, 0x0000(s0)              // t1 = type
        beql    t0, t1, _end                // if (type == title), end
        sw      r0, 0x006C(v0)              // clear reference to value string object

        lli     t0, Menu.type.INPUT         // t0 = input type
        lw      t1, 0x0000(s0)              // t1 = type
        beql    t0, t1, _end                // if (type == input), end
        sw      r0, 0x006C(v0)              // clear reference to value string object

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
        sw      v0, 0x006C(t0)              // save reference to value object
        addiu   t0, t0, 0x006C              // t0 = address of reference to value object
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
        lw      a0, 0x006C(a1)              // a0 = value object for this entry
        beqz    a0, _continue               // skip if no object
        sw      r0, 0x006C(a1)              // clear value object reference
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
        mtc1    t0, f0                      // f0 = row_height
        cvt.s.w f0, f0                      // f0 = row_height, fp
        lwc1    f2, 0x002C(at)              // f2 = scale
        mul.s   f0, f0, f2                  // f0 = row_height * scale
        trunc.w.s f0, f0                    // f0 = ~, decimal
        mfc1    t0, f0                      // t0 = ~, decimal
        lhu     t1, 0x0032(at)              // t1 = max_per_page
        multu   t0, t1
        mflo    t0                          // t0 = row_height * scale * max_per_page
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
        swc1    f2, 0x003C(sp)              // save scale
        lhu     t5, 0x0034(at)              // t5 = blur
        sw      t5, 0x0040(sp)              // save blur

        // clear any label object refs
        lw      at, 0x0000(at)              // at = head
        _clear_loop:
        sw      r0, 0x0020(at)              // clear label ref
        lw      at, 0x001C(at)              // at = next entry
        bnez    at, _clear_loop             // loop until no more entries
        nop

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

        lw      a0, 0x0020(s0)              // a0 = label object
        lw      t0, 0x006C(a0)              // t0 = value object if not 0
        sw      t0, 0x004C(sp)              // save value object reference
        lw      at, 0x0010(sp)              // at = address of Menu.info()
        lw      t0, 0x0014(at)              // t0 = width
        sll     a1, t0, 0x0003              // a1 = width * 8 = approx horizontal width
        srl     t1, t0, 0x0001              // t1 = width / 2
        subu    a1, a1, t0                  // a1 = 7/8 width
        jal     Render.apply_max_width_     // apply max width
        subu    a1, a1, t1                  // a1 = 13/16 width

        lw      t0, 0x004C(sp)              // t0 = value object
        beqz    t0, _next                   // if no value object, skip
        sw      t0, 0x006C(v0)              // save value object
        addiu   t1, v0, 0x006C              // t1 = address of reference to value object
        sw      t1, 0x0054(t0)              // save reference to value object in label object

        lw      a0, 0x0020(s0)              // a0 = label object
        lw      t1, 0x0074(a0)              // t1 = position struct
        _loop_chars:
        lw      t2, 0x0008(t1)              // t2 = next char, if exists
        bnezl   t2, _loop_chars             // loop until we are on last char
        or      t1, t2, r0                  // t1 = next char
        lwc1    f2, 0x0058(t1)              // f2 = x position of last char
        lui     at, 0x4180                  // at = buffer = 10
        mtc1    at, f4                      // f4 = buffer = 10
        add.s   f2, f2, f4                  // f2 = min x position of value string (w/o buffer)

        lhu     a3, 0x002C(sp)              // a3 = urx
        mtc1    a3, f4                      // f4 = urx
        cvt.s.w f4, f4                      // f4 = urx, floating point
        sub.s   f2, f4, f2                  // f2 = max width
        lw      a0, 0x004C(sp)              // a0 = value object
        trunc.w.s f2, f2                    // f2 = max width, decimal
        jal     Render.apply_max_width_     // apply max width
        mfc1    a1, f2                      // a1 = max width

        _next:
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

        jal     get_selected_entry_         // v0 = selected entry
        nop
        sw      v0, 0x001C(sp)              // save selected entry
        lw      t0, 0x0000(v0)              // t0 = type
        lli     t1, Menu.type.INPUT
        bne     t0, t1, _down               // if not an input, check normally
        lw      t0, 0x0004(v0)              // t0 = edit mode flag if input

        beqz    t0, _down                   // if not edit mode, check normally
        nop

        constant SELECT(Joypad.A)
        constant CHANGE_SET(Joypad.CU | Joypad.CD | Joypad.CL | Joypad.CR)
        constant CHANGE_CASE(Joypad.R)
        constant BACKSPACE(Joypad.B)
        constant SAVE(Joypad.START)
        constant CANCEL(Joypad.Z)

        jal     Joypad.check_stick_         // v0 = 0 if not pressed
        lli     a0, Joypad.UP               // a0 = up
        bnez    v0, _move_cursor_y          // if up was pushed, then change character
        addiu   at, r0, -0x0001             // at = -1
        lli     a0, Joypad.DU               // a0 = dpad up
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _move_cursor_y          // if up was pushed, then change character
        addiu   at, r0, -0x0001             // at = -1

        jal     Joypad.check_stick_         // v0 = 0 if not pressed
        lli     a0, Joypad.DOWN             // a0 = down
        bnez    v0, _move_cursor_y          // if down was pushed, then change character
        addiu   at, r0, 0x0001              // at = +1
        lli     a0, Joypad.DD               // a0 = dpad down
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _move_cursor_y          // if down was pushed, then change character
        addiu   at, r0, 0x0001              // at = +1

        jal     Joypad.check_stick_         // v0 = 0 if not pressed
        lli     a0, Joypad.LEFT             // a0 = left
        bnez    v0, _move_cursor_x          // if left was pushed, then change char index
        addiu   at, r0, -0x0001             // at = -1
        lli     a0, Joypad.DL               // a0 = dpad left
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _move_cursor_x          // if left was pushed, then change char index
        addiu   at, r0, -0x0001             // at = -1

        jal     Joypad.check_stick_         // v0 = 0 if not pressed
        lli     a0, Joypad.RIGHT            // a0 = right
        bnez    v0, _move_cursor_x          // if right was pushed, then change char index
        addiu   at, r0, 0x0001              // at = +1
        lli     a0, Joypad.DR               // a0 = dpad right
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _move_cursor_x          // if right was pushed, then change char index
        addiu   at, r0, 0x0001              // at = +1

        _check_buttons:
        lli     a0, SELECT                  // a0 = SELECT button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _select_char            // if pressed, select character
        nop

        lli     a0, BACKSPACE               // a0 = BACKSPACE button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _delete_char            // if pressed, delete current character
        lli     at, 0x0000                  // at = 0

        lli     a0, CHANGE_SET              // a0 = CHANGE_SET button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _change_set             // if pressed, jump to next keyboard set
        lli     at, 0x0001                  // at = 1

        lli     a0, CHANGE_CASE             // a0 = CHANGE_CASE button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _change_case            // if pressed, change case (if on alphabet keyboard)
        nop

        lli     a0, SAVE                    // a0 = SAVE button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _save                   // if pressed, save changes
        nop

        lli     a0, CANCEL                  // a0 = CANCEL button mask
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _cancel                 // if pressed, cancel changes
        nop

        b       _copy
        nop

        _move_cursor_y:
        or      t3, r0, at                  // t3 = delta row
        b       _move_cursor
        lli     t2, 0                       // t2 = delta column

        _move_cursor_x:
        or      t2, r0, at                  // t2 = delta column
        lli     t3, 0                       // t3 = delta row

        _move_cursor:
        li      t5, keyboard_cursor_index
        lhu     t6, 0x0000(t5)              // t6 = cursor column
        lhu     t7, 0x0002(t5)              // t7 = cursor row

        addu    t6, t6, t2                  // t6 = new column
        addu    t7, t7, t3                  // t7 = new row

        bltzl   t6, pc() + 8                // if column < 0, wrap to 9
        lli     t6, 9                       // t6 = 9

        bltzl   t7, pc() + 8                // if row < 0, wrap to 3
        lli     t7, 3                       // t7 = 3

        lli     at, 10                      // at = 10 (max columns + 1)
        beql    t6, at, pc() + 8            // if column > max, wrap to 0
        lli     t6, 0                       // t6 = 0

        lli     at, 4                       // at = 4 (max rows + 1)
        beql    t7, at, pc() + 8            // if row > max, wrap to 0
        lli     t7, 0                       // t6 = 0

        sh      t6, 0x0000(t5)              // update cursor column
        sh      t7, 0x0002(t5)              // update cursor row

        lli     at, 24                      // at = 24 = width/height
        multu   at, t6                      // mflo = x offset
        lli     t4, 38                      // t4 = x start
        mflo    t2                          // t2 = x offset

        multu   at, t7                      // mflo = y offset
        lli     t5, 82                      // t5 = y start
        addu    t4, t4, t2                  // t4 = new x
        mflo    t3                          // t3 = y offset
        addu    t5, t5, t3                  // t4 = new y

        li      t1, keyboard_struct
        lw      t0, 0x0000(t1)              // t0 = yellow cursor square
        lw      t1, 0x0004(t1)              // t1 = black cursor square

        sw      t4, 0x0030(t0)              // update x, yellow square
        addiu   t4, t4, 0x0002              // t4 = new x, black square
        sw      t4, 0x0030(t1)              // update x, black square
        sw      t5, 0x0034(t0)              // update y, yellow square
        addiu   t5, t5, 0x0002              // t5 = new y, black square
        sw      t5, 0x0034(t1)              // update y, black square

        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id

        b       _check_buttons
        nop

        _change_case:
        li      t8, Menu.keyboard_set
        lw      t0, 0x0000(t8)              // t0 = keyboard set

        sltiu   at, t0, 0x0002              // at = 1 if this is an alphanumeric keyboard
        beqz    at, _copy                   // if not an alphanumeric keyboard, skip
        xori    t1, t0, 0x0001              // t1 = new keyboard set (0 -> 1, 1 -> 0)

        b       _update_keyboard_set
        nop

        _select_char:
        li      t7, char_index
        lbu     t0, 0x0000(t7)              // t0 = char index
        li      t2, keyboard_struct
        lw      a1, 0x000C(t2)              // a1 = string object
        lw      t4, 0x0034(a1)              // t4 = first char address
        addiu   t1, t4, 19                  // t1 = last char address
        addu    v0, t4, t0                  // v0 = address of char
        li      t5, keyboard_cursor_index
        lhu     t6, 0x0002(t5)              // t6 = cursor row
        lhu     t5, 0x0000(t5)              // t5 = cursor column
        lli     t1, 10                      // t1 = 10
        multu   t6, t1                      // t1 = 10 * row
        mflo    t1                          // ~
        li      t2, keyboard_set
        lw      t2, 0x0000(t2)              // t2 = keyboard set
        li      t3, keyboard_sets
        addu    t1, t1, t5                  // t1 = index of char in char_set
        lli     t4, 36
        beql    t1, t4, _set_char           // if this square selected, use space
        lli     t1, ' '                     // t1 = space
        lli     t4, 37
        beq     t1, t4, _delete_char        // if this square selected, delete previous char
        lli     t4, 38
        beq     t1, t4, _change_set         // if this square selected, change keyboard set
        lli     t4, 39
        beq     t1, t4, _save               // if this square selected, save
        sll     t2, t2, 0x0002              // t2 = offset to keyboard set string address
        addu    t3, t3, t2                  // t3 = address of keyboard set string address
        lw      t3, 0x0000(t3)              // t3 = keyboard set string address
        addu    t3, t3, t1                  // t3 = address of selected char
        lbu     t1, 0x0000(t3)              // t1 = selected char

        _set_char:
        lli     t2, 20                      // t2 = max length
        sltu    t2, t0, t2                  // t2 = 0 if at max length
        beqzl   t2, _play_select_fgm        // if at max length, don't allow insert
        lli     a0, FGM.menu.ILLEGAL        // a0 - fgm_id

        sb      t1, 0x0000(v0)              // save char
        addiu   t0, t0, 0x0001              // t0++
        sb      t0, 0x0000(t7)              // save char index
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id
        sw      r0, 0x0030(a1)              // clear pointer to force redraw

        _play_select_fgm:
        jal     FGM.play_                   // play menu sound
        nop

        b       _copy
        nop

        _delete_char:
        li      t3, char_index
        lbu     t0, 0x0000(t3)              // t0 = char index
        beqzl   t0, _save                   // if trying to delete nothing, save
        sb      r0, 0x0000(t3)              // reset char index
        li      t2, keyboard_struct
        lw      t2, 0x000C(t2)              // t2 = string object
        lw      t4, 0x0034(t2)              // t4 = first char address
        addu    v0, t4, t0                  // v0 = address of char + 1
        sb      r0, 0xFFFF(v0)              // delete char
        sw      r0, 0x0030(t2)              // clear pointer to force redraw
        // here, we are deleting the previous char, which should move the cursor to the left unless it's already far left
        addiu   at, t0, -0x0001             // at = previous char index
        sb      at, 0x0000(t3)              // save char index
        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id

        b       _copy
        nop

        _cancel:
        li      a0, cancel_edit             // a0 = address of cancel_edit flag
        addiu   v0, r0, 0x0001              // v0 = 1
        sb      v0, 0x0000(a0)              // set flag for canceling edit mode

        _save:
        lw      a0, 0x0014(sp)              // a0 - address of info()
        lw      v0, 0x001C(sp)              // v0 = selected entry
        lw      t0, 0x0010(v0)              // t0 = a_function address
        jalr    t0                          // go to a_function address
        nop
        b       _copy
        nop

        _change_set:
        li      t8, Menu.keyboard_set
        lw      t0, 0x0000(t8)              // t0 = keyboard set

        sltiu   at, t0, 0x0002              // at = 1 if this is an alphanumeric keyboard
        addiu   t1, t0, 0x0002              // t1 = symbol set if alphanumeric
        beqzl   at, pc() + 8                // if not an alphanumeric keyboard, set to alphanumeric
        addiu   t1, t0, -0x0002             // t1 = symbol set if alphanumeric

        _update_keyboard_set:
        sw      t1, 0x0000(t8)              // update keyboard set

        sll     t0, t1, 0x0002              // t0 = offset to keyboard set
        li      t1, Menu.keyboard_sets
        addu    t1, t1, t0                  // t1 = keyboard set pointer address
        lw      a2, 0x0000(t1)              // t0 = keyboard set

        li      t1, Menu.keyboard_set_buttons
        addu    t1, t1, t0                  // t1 = keyboard set button string address pointer
        lw      t1, 0x0000(t1)              // t1 = keyboard set button string address

        li      t0, Menu.keyboard_set_button
        sw      t1, 0x0000(t0)              // update string pointer for keyboard set button

        li      t0, Menu.keyboard_struct
        lw      a0, 0x0008(t0)              // a0 = keyboard chars string object
        jal     Render.update_live_string_
        sw      a2, 0x0034(a0)              // update pointer to string data
        jal     Menu.align_keyboard_chars_
        or      a0, v0, r0                  // a0 = keyboard chars string object

        jal     FGM.play_                   // play menu sound
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id

        b       _copy
        nop

        // Non-Edit Mode checks
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
        addiu   t1, t1, -0x0001             // t1 = selection
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
        lw      v0, 0x001C(sp)              // v0 = selected entry
        lli     t0, type.INPUT              // t0 = type.INPUT
        lw      t1, 0x0000(v0)              // t1 = type of selected entry
        beq     t0, t1, _r                  // if input, skip left/right checks
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
        lw      v0, 0x001C(sp)              // v0 = selected entry
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
        lw      v0, 0x001C(sp)              // v0 = selected entry
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
        lw      v0, 0x001C(sp)              // v0 = selected entry
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

        _byte:
        _bool:
        lw      t0, 0x0018(at)              // t0 = copy address
        beql    t0, r0, _loop               // if null, loop and at = entry->next
        lw      at, 0x001C(at)              // at = entry->next
        lw      t1, 0x0004(at)              // t1 = curr val
        sb      t1, 0x0003(t0)              // copy curr val
        b       _loop
        lw      at, 0x001C(at)              // at = entry->next

        _hw:
        lw      t0, 0x0018(at)              // t0 = copy address
        beql    t0, r0, _loop               // if null, loop and at = entry->next
        lw      at, 0x001C(at)              // at = entry->next
        lw      t1, 0x0004(at)              // t1 = curr val
        sh      t1, 0x0002(t0)              // copy curr val
        b       _loop
        lw      at, 0x001C(at)              // at = entry->next

        _word:
        _title:
        _input:
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
        dw _title
        dw _byte
        dw _byte
        dw _byte
        dw _byte
        dw _byte
        dw _byte
        dw _byte
        dw _byte
        dw _hw
        dw _hw
        dw _input
        dw _word
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
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // save registers

        move    t0, a0                      // t0 = first entry
        addiu   a1, a1, 0x0010              // a1 = address of SRAM block data
        lli     t3, 0x0000                  // t3 = bits to shift left in word

        _loop:
        beqz    t0, _end                    // if (entry = null), end
        nop

        // skip exporting titles
        lli     t2, Menu.type.TITLE         // t2 = title type
        lw      t1, 0x0000(t0)              // t1 = type
        beq     t2, t1, _skip               // if (type == title), skip
        nop

        lli     t2, Menu.type.INPUT         // t2 = input type
        beq     t2, t1, _export_input       // if (type == input), handle differently
        addu    t2, t1, t3                  // t2 = highest bit used for this value

        sltiu   t2, t2, 32                  // t2 = 0 if we need to start a new word
        bnez    t2, _save_value             // if we don't need to start a new word, skip
        nop

        lli     t3, 0x0000                  // reset bit position
        addiu   a1, a1, 0x0004              // increment ram_address

        _save_value:
        lli     t2, 32                      // t2 = max number of bits to shift in word - 1
        subu    t1, t2, t1                  // t1 = number of bits to shift right
        addiu   t2, r0, -0x0001             // t2 = -1 = all bits are 1
        srlv    t2, t2, t1                  // t2 = bit mask, unshifted
        sllv    t1, t2, t3                  // t1 = bit mask to clear out exported value, almost
        addiu   t2, r0, -0x0001             // t2 = -1 = all bits are 1
        xor     t1, t1, t2                  // t1 = bit mask to clear out exported value
        lw      t2, 0x0000(a1)              // t2 = exported values in current word block
        and     t2, t2, t1                  // t2 = exported values in current word block, cleared out for bits t3 through t3 - t1

        lw      t1, 0x0004(t0)              // t1 = entry.curr_value
        sllv    t1, t1, t3                  // t1 = entry.curr_value adjusted to current exported bit block
        or      t1, t2, t1                  // t1 = exported values updated
        sw      t1, 0x0000(a1)              // export
        lw      t1, 0x0000(t0)              // t1 = type
        addu    t3, t3, t1                  // t3 = next bit position in word

        _next:
        _skip:
        b       _loop                       // check again
        lw      t0, 0x001C(t0)              // t0 = entry->next

        _export_input:
        // For inputs, we export the string, 20 characters.
        lw      t1, 0x0028(t0)              // t1 = first 4 characters
        sw      t1, 0x0000(a1)              // export
        lw      t1, 0x002C(t0)              // t1 = next 4 characters
        sw      t1, 0x0004(a1)              // export
        lw      t1, 0x0030(t0)              // t1 = next 4 characters
        sw      t1, 0x0008(a1)              // export
        lw      t1, 0x0034(t0)              // t1 = next 4 characters
        sw      t1, 0x000C(a1)              // export
        lw      t1, 0x0038(t0)              // t1 = last 4 characters
        sw      t1, 0x0010(a1)              // export
        b       _next
        addiu   a1, a1, 0x0014              // increment ram_address

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a1, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Imports a set of given 32 bit values to each entry's curr_value
    // a0 - address of head
    // a1 - address of block
    scope import_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // save registers

        move    t0, a0                      // t0 = first entry
        addiu   a1, a1, 0x0010              // a1 = address of SRAM block data
        lli     t3, 0x0000                  // t3 = bit position in word

        _loop:
        beqz    t0, _end                    // if (entry = null), end
        nop

        // skip titles when importing
        lli     t2, Menu.type.TITLE         // t2 = title type
        lw      t1, 0x0000(t0)              // t1 = type
        beq     t2, t1, _skip               // if (type == title), skip
        nop

        lli     t2, Menu.type.INPUT         // t2 = input type
        beq     t2, t1, _import_input       // if (type == input), handle differently
        addu    t2, t1, t3                  // t2 = highest bit used for this value

        sltiu   t2, t2, 32                  // t2 = 0 if we need to start a new word
        bnez    t2, _read_value             // if we don't need to start a new word, skip
        nop

        lli     t3, 0x0000                  // reset bit position
        addiu   a1, a1, 0x0004              // increment ram_address

        _read_value:
        lw      t1, 0x0000(t0)              // t1 = type
        lli     t2, 32
        subu    t2, t2, t1                  // t2 = number of bits to shift left
        lw      t1, 0x0000(a1)              // t1 = value at ram_address
        srlv    t1, t1, t3                  // t1 = value, shifted right
        sllv    t1, t1, t2                  // t1 = value, shift all the way left
        srlv    t1, t1, t2                  // t1 = value to import
        sw      t1, 0x0004(t0)              // update curr_value

        lw      t1, 0x0000(t0)              // t1 = type
        addu    t3, t3, t1                  // t3 = next bit position in word

        _next:
        _skip:
        b       _loop                       // check again
        lw      t0, 0x001C(t0)              // t0 = entry->next

        _import_input:
        // For inputs, we import the string, 20 characters.
        lw      t1, 0x0000(a1)              // t1 = first 4 characters
        sw      t1, 0x0028(t0)              // update
        lw      t1, 0x0004(a1)              // t1 = next 4 characters
        sw      t1, 0x002C(t0)              // export
        lw      t1, 0x0008(a1)              // t1 = next 4 characters
        sw      t1, 0x0030(t0)              // export
        lw      t1, 0x000C(a1)              // t1 = next 4 characters
        sw      t1, 0x0034(t0)              // export
        lw      t1, 0x0010(a1)              // t1 = last 4 characters
        sw      t1, 0x0038(t0)              // export
        b       _next
        addiu   a1, a1, 0x0014              // increment ram_address

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a1, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

}

} // __MENU__
