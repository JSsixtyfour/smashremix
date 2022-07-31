// PlayerTag.asm
if !{defined __PLAYER_TAG__} {
define __PLAYER_TAG__()
print "included PlayerTag.asm\n"

// @ Description
// Customized player tag display is implemented in this file.
scope PlayerTag {
    constant MAX_WIDTH(0x0060)

    // @ Description
    // Holds value of custom tag switch per port
    enable_for_port:
    dw 0, 0, 0, 0                           // turn off by default for p1 - p4

    // @ Description
    // This hook conditionally replaces the default player tag image with a custom arrow image
    scope use_custom_tag_image_: {
        // in game
        OS.patch_start(0x8D49C, 0x80111C9C)
        jal     use_custom_tag_image_
        addu    t4, s7, t3                  // original line 1 - t4 = address of tag image offset in file 0x26
        OS.patch_end()

        // results screen - human
        OS.patch_start(0x152EF0, 0x80133D50)
        jal     use_custom_tag_image_._results_human
        lw      t8, 0x0028(t8)              // original line 1 - t8 = tag image offset in file 0x26
        OS.patch_end()

        // results screen - cpu
        OS.patch_start(0x152F78, 0x80133DD8)
        jal     use_custom_tag_image_._results_cpu
        addiu   t8, t1, 0x0CD8              // original line 2 modified to use t8 - t8 = tag image offset in file 0x26
        jal     0x800CCFDC                  // original line 3 - TEXTURE_INIT_
        addu    a1, t0, t8                  // original line 4 modified to use t8 - a1 = image address
        OS.patch_end()

        // s2 = port
        li      t5, enable_for_port
        sll     t3, s2, 0x0002              // t3 = offset to port
        addu    t5, t5, t3                  // t5 = address of port flag
        lw      t5, 0x0000(t5)              // t5 = 1 if enabled, 0 if not
        beqzl   t5, _end                    // if not enabled, skip
        lw      t5, 0x0000(t4)              // original line 2 - t5 = offset of tag image in file

        lli     t5, 0x1158                  // t5 = arrow only indicator offset

        _end:
        jr      ra
        nop

        _results_cpu:
        lw      t0, 0xA04C(t0)              // original line 1 - t0 = file 0x26 address

        _results_human:
        // v0 = port
        li      t5, enable_for_port
        sll     t3, v0, 0x0002              // t3 = offset to port
        addu    t5, t5, t3                  // t5 = address of port flag
        lw      t5, 0x0000(t5)              // t5 = 1 if enabled, 0 if not
        bnezl   t5, _end                    // if enabled, use arrow only indicator
        lli     t8, 0x1158                  // t8 = arrow only indicator offset
        jr      ra
        nop
    }

    // @ Description
    // This hook conditionally adds a custom string to the player indicator object
    scope create_custom_tag_: {
        // in game
        OS.patch_start(0x8D51C, 0x80111D1C)
        jal     create_custom_tag_
        sb      t5, 0x0062(v0)              // original line 1 - set value in image struct
        OS.patch_end()

        // results screen
        OS.patch_start(0x153000, 0x80133E60)
        jal     create_custom_tag_._results
        lw      a1, 0x0058(sp)              // original line 2 - a1 = port
        OS.patch_end()

        // s2 = port
        li      t5, enable_for_port
        sll     t3, s2, 0x0002              // t3 = offset to port
        addu    t5, t5, t3                  // t5 = address of port flag
        lw      t5, 0x0000(t5)              // t5 = >=1 if enabled, 0 if not
        beqz    t5, _end                    // if not enabled, skip
        sll     t5, t5, 0x0002              // t5 = offset to custom string pointer
        li      t3, CharacterSelectDebugMenu.PlayerTag.string_table
        addu    t5, t5, t3                  // t5 = address of custom string pointer
        lw      t5, 0x0000(t5)              // t5 = custom string address

        addiu   sp, sp, -0x0040             // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~
        sw      s5, 0x0018(sp)              // ~
        sw      s6, 0x001C(sp)              // ~
        sw      s7, 0x0020(sp)              // ~
        sw      s8, 0x0024(sp)              // ~
        sw      v0, 0x0028(sp)              // ~
        sw      ra, 0x002C(sp)              // ~
        sw      t5, 0x0030(sp)              // save registers

        Render.load_font()                  // load font since this runs before our normal screen check hook

        lw      v0, 0x0028(sp)              // v0 = player tag image struct

        // Because I'm lazy, I'll use Render.draw_string_ to create a string object, then destroy it, then
        // update character image linked list to be on the player tag object.
        lli     a0, 0x0017                  // a0 = room
        lli     a1, 0x000B                  // a1 = group
        lw      a2, 0x0030(sp)              // a2 = address of string
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      s1, 0x0058(v0)              // s1 = ulx
        lw      s2, 0x005C(v0)              // s2 = uly
        lli     s3, 0x00FF                  // s3 = color (BLACK)
        lui     s4, 0x3F80                  // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = align center
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, 0x0001                  // t8 = blur on

        lw      t0, 0x0074(v0)              // t0 = string images struct linked list
        beqz    t0, _destroy_and_end        // if nothing, this is just spaces, so skip
        or      a0, v0, r0                  // a0 = string object

        jal     Render.apply_max_width_
        lli     a1, MAX_WIDTH               // a1 = max width

        lw      t0, 0x0028(sp)              // t0 = player tag object image struct
        lw      t3, 0x0004(t0)              // t3 = player tag object
        lw      t1, 0x0074(v0)              // t1 = string linked list
        sw      r0, 0x0074(v0)              // disassociate from the string object
        sw      t1, 0x0008(t0)              // append linked list with string
        lui     t2, 0x40E0                  // t2 = 7 (fp) = offset for X
        mtc1    t2, f2                      // f2 = 7
        lui     t2, 0xBFD0                  // t2 = -1.65 (fp) = offset for Y
        mtc1    t2, f6                      // f2 = -1.65
        lui     t4, 0x3FA0                  // t4 = scale multiplier = 1.25
        mtc1    t4, f10                     // f10 = scale multiplier
        lwc1    f12, 0x0018(t1)             // f12 = X scale of string
        mul.s   f10, f12, f10               // f10 = X scale
        _loop_black:
        sw      t3, 0x0004(t1)              // update object pointer for character
        lwc1    f4, 0x0058(t1)              // f4 = X offset to use when calculating position, unadjusted
        add.s   f4, f4, f2                  // f4 = X offset to use when calculating position, adjusted
        lwc1    f8, 0x005C(t1)              // f8 = Y offset to use when calculating position, unadjusted
        add.s   f8, f8, f6                  // f8 = Y offset to use when calculating position, adjusted
        lw      t2, 0x0008(t1)              // t2 = next character image struct address
        swc1    f4, 0x0048(t1)              // save X offset in unused image struct space
        swc1    f8, 0x004C(t1)              // save Y offset in unused image struct space
        swc1    f10, 0x0018(t1)             // update X scale
        sw      t4, 0x001C(t1)              // update Y scale
        bnezl   t2, _loop_black             // if more characters, keep looping
        or      t1, t2, r0                  // t1 = next character image struct address

        sw      t1, 0x0034(sp)              // save last character image struct

        jal     Render.DESTROY_OBJECT_
        or      a0, v0, r0                  // a0 = string object created

        lw      v0, 0x0028(sp)              // v0 = player tag image struct

        // Because I'm lazy, I'll use Render.draw_string_ to create a string object, then destroy it, then
        // update character image linked list to be on the player tag object.
        lli     a0, 0x0017                  // a0 = room
        lli     a1, 0x000B                  // a1 = group
        lw      a2, 0x0030(sp)              // a2 = address of string
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      s1, 0x0058(v0)              // s1 = ulx
        lw      s2, 0x005C(v0)              // s2 = uly
        lw      s3, 0x0028(v0)              // s3 = color
        lui     s4, 0x3F80                  // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = align center
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, 0x0001                  // t8 = blur on

        or      a0, v0, r0                  // a0 = string object
        jal     Render.apply_max_width_
        lli     a1, MAX_WIDTH               // a1 = max width

        lw      t0, 0x0034(sp)              // t0 = last character image struct
        lw      t3, 0x0004(t0)              // t3 = player tag object
        lw      t1, 0x0074(v0)              // t1 = string linked list
        sw      r0, 0x0074(v0)              // disassociate from the string object
        sw      t1, 0x0008(t0)              // append linked list with string
        lui     t2, 0x4100                  // t2 = 8 (fp) = offset for X
        mtc1    t2, f2                      // f2 = 8
        _loop:
        sw      t3, 0x0004(t1)              // update object pointer for character
        lwc1    f4, 0x0058(t1)              // f4 = X offset to use when calculating position, unadjusted
        add.s   f4, f4, f2                  // f4 = X offset to use when calculating position, adjusted
        lw      t2, 0x0008(t1)              // t2 = next character image struct address
        swc1    f4, 0x0048(t1)              // save X offset in unused image struct space
        sw      r0, 0x004C(t1)              // save 0 for Y offset in unused image struct space
        bnez    t2, _loop                   // if more characters, keep looping
        or      t1, t2, r0                  // t1 = next character image struct address

        _destroy_and_end:
        jal     Render.DESTROY_OBJECT_
        or      a0, v0, r0                  // a0 = string object created

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0014(sp)              // ~
        lw      s5, 0x0018(sp)              // ~
        lw      s6, 0x001C(sp)              // ~
        lw      s7, 0x0020(sp)              // ~
        lw      s8, 0x0024(sp)              // ~
        lw      v0, 0x0028(sp)              // ~
        lw      ra, 0x002C(sp)              // ~
        addiu   sp, sp, 0x0040              // deallocate stack space

        _end:
        jr      ra
        sw      s2, 0x0084(s1)              // original line 2 - save player port as tag object special struct

        _results:
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      s2, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      s1, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // save registers

        lw      v0, 0x000C(sp)              // v0 = player tag image struct
        lw      s2, 0x0010(sp)              // s2 = port
        jal     create_custom_tag_          // create custom tag
        lw      s1, 0x0004(v0)              // s1 = tag indicator object

        lw      a0, 0x0018(sp)              // a0 = tag indicator object
        jal     0x801339F4                  // original line 1 - position tag
        lw      a1, 0x0010(sp)              // a1 = port

        lw      v0, 0x000C(sp)              // v0 = player tag image struct
        lw      t0, 0x0008(v0)              // t0 = first character image struct, if using custom tag name
        beqz    t0, _end_results            // skip if no custom tag name
        lwc1    f4, 0x0058(v0)              // f4 = X of indicator image

        lwc1    f8, 0x005C(v0)              // f8 = Y of indicator image
        lbu     t1, 0x002B(v0)              // t1 = alpha of indicator image

        _loop_results:
        lwc1    f6, 0x0048(t0)              // f6 = X offset for this character
        add.s   f6, f4, f6                  // f6 = X for this character
        lwc1    f2, 0x004C(t0)              // f2 = Y offset for this character
        add.s   f0, f2, f8                  // f0 = Y for this character
        swc1    f6, 0x0058(t0)              // update X
        swc1    f0, 0x005C(t0)              // update Y
        sb      t1, 0x002B(t0)              // update alpha
        lw      t0, 0x0008(t0)              // t0 = next character image struct
        bnez    t0, _loop_results           // loop while there are more characters to reposition
        nop

        _end_results:

        lw      ra, 0x0004(sp)              // restore registers
        lw      s2, 0x0008(sp)              // ~
        lw      s1, 0x0014(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // This hook modifies the render routine for the player indicator to reposition a custom tag string, if present
    scope position_custom_tag_: {
        OS.patch_start(0x8D3CC, 0x80111BCC)
        j       position_custom_tag_
        swc1    f16, 0x005C(v0)             // original line 2 - set Y position of player indicator image
        _return:
        OS.patch_end()

        // v0 = image struct of indicator image
        lw      t0, 0x0008(v0)              // t0 = first character image struct, if using custom tag name
        beqz    t0, _end                    // skip if no custom tag name
        lwc1    f4, 0x0058(v0)              // f4 = X of indicator image

        lwc1    f8, 0x005C(v0)              // f8 = Y of indicator image
        lbu     t1, 0x002B(v0)              // t1 = alpha of indicator image

        _loop:
        lwc1    f6, 0x0048(t0)              // f6 = X offset for this character
        add.s   f6, f4, f6                  // f6 = X for this character
        lwc1    f2, 0x004C(t0)              // f2 = Y offset for this character
        add.s   f0, f2, f8                  // f0 = Y for this character
        swc1    f6, 0x0058(t0)              // update X
        swc1    f0, 0x005C(t0)              // update Y
        sb      t1, 0x002B(t0)              // update alpha
        lw      t0, 0x0008(t0)              // t0 = next character image struct
        bnez    t0, _loop                   // loop while there are more characters to reposition
        nop

        _end:
        jal     0x800CCF00                  // original line 1 - standard render routine for images
        nop

        j       _return
        nop
    }

    // @ Description
    // This hook makes the player indicator always display when using a custom tag
    scope always_display_custom_tag_: {
        OS.patch_start(0x8D28C, 0x80111A8C)
        jal     always_display_custom_tag_
        lw      t5, 0x0174(v1)              // original line 1 - t5 = indicator display countdown
        OS.patch_end()

        // v0 = port
        li      at, enable_for_port
        sll     t6, v0, 0x0002              // t6 = offset to port
        addu    at, at, t6                  // at = address of port flag
        lw      at, 0x0000(at)              // at = >=1 if enabled, 0 if not
        beqzl   at, _end                    // if not enabled, skip
        addiu   at, r0, 0x0001              // original line 2 - at = 1

        or      at, t5, r0                  // at = t5 so the indicator display countdown check always passes

        _end:
        jr      ra
        nop
    }
}
}
