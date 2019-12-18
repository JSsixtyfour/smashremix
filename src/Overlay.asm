// Overlay.asm
if !{defined __OVERLAY__} {
define __OVERLAY__()
print "included Overlay.asm\n"

// @ Description
// The framebuffer overlay is implemented in this file.
// @ Note
// This file only supports rgba5551

include "Data.asm"
include "Global.asm"
include "Joypad.asm"
include "OS.asm"
include "RCP.asm"
include "String.asm"
include "Texture.asm"

scope Overlay {

    OS.align(16)
    texture_font:
    Texture.info(8, 8)
    insert "../textures/font.rgba5551"

    // @ Description
    // This function highjacks the SSB display list right before the full sync occurs. This allows
    // devolpers to overlay their own display list built using Overlay.draw_* functions in this
    // file. Insert functions below "HOOKS GO HERE."

    macro highjack_(return_address, original_line_2_hex) {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      a3, 0x0014(sp)              // ~
        sw      ra, 0x0018(sp)              // ~
        sw      t1, 0x001C(sp)              // save registers

        // init
        li      t0, RCP.display_list_info_p // t0 = display list info pointer 
        li      t1, display_list_info       // t1 = address of display list info
        sw      t1, 0x0000(t0)              // update display list info pointer

        // reset
        li      t0, display_list            // t0 = address of display_list
        li      t1, display_list_info       // t1 = address of display_list_info 
        sw      t0, 0x0000(t1)              // ~
        sw      t0, 0x0004(t1)              // update display list address each frame

        // highjack
        li      t0, 0xDE010000              // ~
        sw      t0, 0x0000(v0)              // ~
        li      t0, display_list            // ~ 
        sw      t0, 0x0004(v0)              // highjack ssb display list

        // HOOKS GO HERE
        lli     a0, Joypad.DEADZONE         // a0 - min coordinate (deadzone)
        jal     Joypad.update_stick_        // update stick
        nop

        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = screen id

        // OPTION screen
        lli     t1, 0x0039                  // t1 = OPTION screen
        bne     t0, t1, _training           // if (screen_id != OPTION), skip
        nop
        jal     Toggles.run_
        nop

        // training mode
        _training:
        lli     t1, 0x0036
        bne     t0, t1, _vs                 // if (screen_id != training), skip
        nop
        jal     Training.run_
        nop        

        _vs:
        lli     t1, 0x0016
        bne     t0, t1, _results            // if (screen_id != vs mode), skip
        nop
        jal     VsCombo.run_
        nop
        jal     VsStats.run_collect_
        nop

        _results:
        lli     t1, 0x0018
        bne     t0, t1, _sss                // if (screen_id != results), skip
        nop
        jal     VsStats.run_results_
        nop

        _sss:
        lli     t1, 0x0015                  // t1 = stage select screen
        bne     t0, t1, _finish             // if (screen_id != stage_select), skip
        nop
        jal     Stages.run_                 //
        nop
        
        // Need this so that the combo meter correctly differentiates singles
        li      t1, VsCombo.player_count    // t1 = address of number of players
        sw      r0, 0x0000(t1)              // Set player_count to 0
        // Need this so that the match stats correctly resets each match (can't rely on VsCombo having run since it's a toggle)
        li      t1, VsStats.player_count    // t1 = address of number of players
        sb      r0, 0x0000(t1)              // Set player_count to 0

        _finish:
        jal     end_                        // end display list
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      a3, 0x0014(sp)              // ~
        lw      ra, 0x0018(sp)              // ~
        lw      t1, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
//      sw      t3, 0x0000(v0)              // original line 1
        dw      {original_line_2_hex}       // original line 2
        j       {return_address}            // return
        nop
    }
    
    scope highjack_1_: {
        OS.patch_start(0x00006150, 0x80005550)
        j        highjack_1_
        nop
        _highjack_1_return:
        OS.patch_end()

        highjack_(_highjack_1_return, 0x8E020000)
    }

    scope highjack_2_: {
        OS.patch_start(0x000062A4, 0x800056A4)
        j       highjack_2_
        nop
        _highjack_2_return:
        OS.patch_end()

        highjack_(_highjack_2_return, 0x8E020004)
    }

    // @ Description
    // Adds f3dex2 to draw a solid rectangle to the framebuffer (of current fill color).
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - width 
    // a3 - height
    scope draw_rectangle_: {
        addiu   sp, sp, -0x0018             // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      s0, 0x0008(sp)              // ~
        sw      s1, 0x000C(sp)              // ~
        sw      s2, 0x0010(sp)              // ~
        sw      s3, 0x0014(sp)              // save registers

        or      s0, a0, r0                  // ~
        or      s1, a1, r0                  // ~
        or      s2, a2, r0                  // ~
        or      s3, a3, r0                  // sx = ax

        jal     RCP.set_other_modes_fill_   // cycle type = fill
        nop
        or      a0, s0, r0                  // a0 - ulx
        or      a1, s1, r0                  // a1 - uly
        or      a2, s2, r0                  // a2 - width 
        or      a3, s3, r0                  // a3 - height
        jal     RCP.fill_rectangle_wh_      // draw rectangle
        nop
        jal     RCP.pipe_sync_              // sync
        nop

        lw      ra, 0x0004(sp)              // ~
        lw      s0, 0x0008(sp)              // ~
        lw      s1, 0x000C(sp)              // ~
        lw      s2, 0x0010(sp)              // ~
        lw      s3, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Adds f3dex2 to draw a textured rectangle to the framebuffer.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - address of texture struct 
    // @ Note
    // This can only handle textures <= 4096 bytes in size
    scope draw_texture_: {
        // order from SSB
        // 1. set other modes copy
        // 2. set texture image
        // 3. set tile
        // 4. load sync
        // 5. load block 
        // 6. pipe sync
        // 7. set tile
        // 8. set tile size
        // 9. texture rectangle
        // 0. pipe sync

        addiu   sp, sp,-0x0028              // allocate stack space
        sw      s0, 0x0004(sp)              // ~
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // ~ 
        sw      a2, 0x001C(sp)              // ~ 
        sw      a3, 0x0020(sp)              // save registers

        or      s0, a0, r0                  // s0 = copy of a0
        or      s1, a1, r0                  // s1 = copy of a1
        or      s2, a2, r0                  // s2 = copy of a2

        jal     RCP.set_other_modes_copy_   // append dlist
        nop

        lw      a0, 0x0008(s2)              // a0 - RAM address [a]
        li      a1, RCP.G_IM_FMT_RGBA       // a1 - color format [f]
        li      a2, RCP.G_IM_SIZ_16b        // a2 - color size [s]
        jal     RCP.set_texture_image_      // append dlist
        nop

        lw      a0, 0x0000(s2)              // a0 = width 
        li      a1, RCP.G_IM_FMT_RGBA       // a1 - color format [f]
        li      a2, RCP.G_IM_SIZ_16b        // a2 - color size [s]
        jal     RCP.set_tile_               // append dlist
        nop

        jal     RCP.load_sync_              // append dlist
        nop

        lw      a0, 0x0000(s2)              // a0 - width
        lw      a1, 0x0004(s2)              // a1 - height
        jal     RCP.load_block_             // append dlist
        nop

        jal     RCP.pipe_sync_              // append dlist
        nop

        lw      a0, 0x0000(s2)              // a0 = width 
        li      a1, RCP.G_IM_FMT_RGBA       // a1 - color format [f]
        li      a2, RCP.G_IM_SIZ_16b        // a2 - color size [s]
        jal     RCP.set_tile_               // append dlist
        nop

        lw      a0, 0x0000(s2)              // a0 - width
        lw      a1, 0x0004(s2)              // a1 - height
        jal     RCP.set_tile_size_          // append dlist
        nop

        or      a0, s0, r0                  // a0 - ulx
        or      a1, s1, r0                  // a1 - uly
        lw      a2, 0x0000(s2)              // a2 - width
        lw      a3, 0x0004(s2)              // a3 - height
        jal     RCP.texture_rectangle_wh_    // append dlist
        nop

        jal     RCP.pipe_sync_              // sync
        nop

        lw      s0, 0x0004(sp)              // ~
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      a1, 0x0018(sp)              // ~ 
        lw      a2, 0x001C(sp)              // ~ 
        lw      a3, 0x0020(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Adds f3dex2 to draw multiple textured rectangles (for one texture) to the framebuffer.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - address of texture struct 
    scope draw_texture_big_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      t4, 0x0018(sp)              // ~
        sw      at, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // save registers

        li      t0, texture                 // t0 = address of local texture struct
        lw      t1, 0x0000(a2)              // ~
        sw      t1, 0x0000(t0)              // copy width to local texture struct
        lw      t2, 0x0008(a2)              // ~
        sw      t2, 0x0008(t0)              // copy data_pointer to local texture struct
        lw      t3, 0x0004(a2)              // t3 = toatal_height (height_left)
        li      a2, texture                 // a2 - address of local texture struct 

        _loop:
        sltiu   at, t3, 0x0004              // if (t3 < 4), at = 1
        bne     at, r0, _draw_last          // ...and draw rectangle with height of 3 or less
        nop
        lli     t4, 0x0004                  // t4 = 4
        sw      t4, 0x0004(t0)              // texture.height = 0

        _draw:
//      or      a0, a0, r0                  // a0 = ulx 
//      or      a1, a1, r0                  // a1 = uly
        li      a2, texture                 // a2 - address of local texture struct 
        jal     draw_texture_               // draw chunk
        nop

        _increment:
        addiu   a1, a1, 0x0004              // increment uly by 4
        mult    t1, t4                      // ~
        mflo    at                          // at = width * 4
        sll     at, at, 0x0001              // at = width * 4 * sizeof(rgba5551)
        addu    t2, t2, at                  // t2 = data_pointer + offset
        sw      t2, 0x0008(t0)              // store new data_pointer to local texture struct
        addiu   t3, t3,-0x0004              // t3 = height_left - 4
        b       _loop                       // prepart to draw next chunk
        nop

        _draw_last:
        sw      t3, 0x0004(t0)              // store height_left to local to local texture struct
//      or      a0, a0, r0                  // a0 = ulx 
//      or      a1, a1, r0                  // a1 = uly
//      li      a2, texture                 // a2 - address of local texture struct         
        jal     draw_texture_               // draw last chunk
        nop

        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      t4, 0x0018(sp)              // ~
        lw      at, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space 
        jr      ra                          // return
        nop

        texture:
        Texture.info(0, 0)                  // blank texture struct
    }

    // @ Description
    // Adds f3dex2 to draw characters.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - char
    scope draw_char_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, texture_font            // ~
        lw      t0, 0x0008(t0)              // t0 = address of image_data
        sll     t1, a2, 0x0007              // t1 = char * width * height * 2 (or char * 128)
        addu    t0, t0, t1                  // t0 = address of char_data
        li      t1, texture                 // ~
        sw      t0, 0x0008(t1)              // texture.data = char_data
//      or      a0, a0, r0                  // a0 - ulx
//      or      a1, a1, r0                  // a2 - uly
        li      a2, texture                 // a2 - texture data
        jal     draw_texture_
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        texture:
        Texture.info(8, 8)
    }

    // @ Description
    // Draws a null terminated string.
    // @ Arguments
    // a0 - ulx
    // a1 - uly
    // a2 - address of string
    scope draw_string_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      s2, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        or      s2, a2, r0                  // s2 = copy of a2 (address of string)

        _loop:
        lb      t0, 0x0000(s2)              // t0 = char
        beq     t0, r0, _end                // if (t0 == 0x00), end
        nop
//      or      a0, a0, r0                  // ulx
//      or      a1, a1, r0                  // uly
        or      a2, t0, 0x000               // a2 = char
        jal     draw_char_                  // draw character
        nop
        addiu   s2, s2, 0x0001              // s2++
        addiu   a0, a0, 0x0008              // a0 = (ulx + 8)
        b       _loop                       // draw next char
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      s2, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Draws a null terminated string based on urx instead of ulx. Good for aligning left strings
    // @ Arguments
    // a0 - urx
    // a1 - uly
    // a2 - address of string
    scope draw_string_urx_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // save registers

        move    a0, a2                      // a0 - address of string
        jal     String.length_              // v0 = length of string
        nop
        sll     v0, v0, 0x0003              // v0 = length of string * char_pixels

        lw      a0, 0x0008(sp)              // ~
        sub     a0, a0, v0                  // a0 - ulx
        lw      a1, 0x000C(sp)              // a1 - uly
        lw      a2, 0x0010(sp)              // a2 - address of string
        jal     draw_string_
        nop

        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Draws a null terminated string centered on x.
    // @ Arguments
    // a0 - x
    // a1 - uly
    // a2 - address of string
    scope draw_centered_str_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // save registers

        move    a0, a2                      // a0 - address of string
        jal     String.length_              // v0 = length of string
        nop
        sll     v0, v0, 0x0002              // v0 = length of string * (char_pixels / 2)

        lw      a0, 0x0008(sp)              // ~
        sub     a0, a0, v0                  // a0 - ulx
        lw      a1, 0x000C(sp)              // a1 - uly
        lw      a2, 0x0010(sp)              // a2 - address of string
        jal     draw_string_
        nop

        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Adds f3dex2 to end a display list.
    scope end_: {
        addiu   sp, sp, -0x0008             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        jal     RCP.full_sync_              // sync
        nop
        jal     RCP.end_list_               // end list
        nop
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0008              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Sets fill color
    // @ Arguments
    // a0 - rgba5551 color
    scope set_color_: {
        addiu   sp, sp,-0x000C              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // save registers
        or      at, a0, r0                  // ~
        sll     a0, a0, 000016              // ~
        or      a0, a0, at                  // a0 = packed color
        jal     RCP.set_fill_color_         // set fill color
        nop
        lw      at, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // save registers
        addiu   sp, sp, 0x000C              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Custom display list goes here.
    OS.align(16)
    display_list:
    fill 0x20000

    display_list_info:
    RCP.display_list_info(display_list, 0x20000)
}

} // __OVERLAY__
