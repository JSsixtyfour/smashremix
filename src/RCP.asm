// RCP.asm
if !{defined __RCP__} {
define __RCP__()
print "included RCP.asm\n"

// @ Description
// for use with f3dex2
// https://wiki.cloudmodding.com/oot/F3DZEX/Opcode_Details
// https://dragonminded.com/n64dev/Reality%20Coprocessor.pdf
// @ Note
// constants in this file do no follow the style guide

include "OS.asm"

scope RCP {

    // macros
    macro display_list_info(variable address, variable size) {
        dw address                          // 0x0000 - display list start address
        dw address                          // 0x0004 - display list current address
        dw size                             // 0x0008 - display list size 
    } 

    // commands
    constant G_NOOP(0x00)
    constant G_VTX(0x01)                    // unsupported
    constant G_MODIFYVTX(0x02)              // unsupported
    constant G_CULLDL(0x03)                 // unsupported
    constant G_BRANCH_Z(0x04)               // unsupported
    constant G_TRI1(0x05)                   // unsupported
    constant G_TRI2(0x06)                   // unsupported
    constant G_QUAD(0x07)                   // unsupported 
    constant G_LINE3D(0x08)                 // unsupported
    constant G_SPECIAL_3(0xD3)              // unsupported
    constant G_SPECIAL_2(0xD4)              // unsupported
    constant G_SPECIAL_1(0xD5)              // unsupported
    constant G_DMA_IO(0xD6)                 // unsupported
    constant G_TEXTURE(0xD7)                // unsupported
    constant G_POPMTX(0xD8)                 // unsupported
    constant G_GEOMETRYMODE(0xD9)           // unsupported
    constant G_MTX(0xDA)                    // unsupported
    constant G_MOVEWORD(0xDB)               // unsupported
    constant G_MOVEMEM(0xDC)                // unsupported
    constant G_LOAD_UCODE(0xDD)             // unsupported
    constant G_DL(0xDE)
    constant G_ENDDL(0xDF)
    constant G_SPNOOP(0xE0)                 // unsupported
    constant G_RDPHALF_1(0xE1)              // unsupported
    constant G_SETOTHERMODE_L(0xE2)         // unsupported
    constant G_SETOTHERMODE_H(0xE3)         // unsupported
    constant G_TEXRECT(0xE4)
    constant G_TEXRECTFLIP(0xE5)            // unsupported
    constant G_RDPLOADSYNC(0xE6)
    constant G_RDPPIPESYNC(0xE7)
    constant G_RDPTILESYNC(0xE8)
    constant G_RDPFULLSYNC(0xE9)
    constant G_SETKEYGB(0xEA)               // unsupported
    constant G_SETKEYR(0xEB)                // unsupported
    constant G_SETCONVERT(0xEC)             // unsupported
    constant G_SETSCISSOR(0xED)             // unsupported
    constant G_SETPRIMDEPTH(0xEE)           // unsupported
    constant G_RDPSETOTHERMODE(0xEF)
    constant G_LOADTLUT(0xF0)               // unsupported
    constant G_RDPHALF_2(0xF1)              // unsupported
    constant G_SETTILESIZE(0xF2)
    constant G_LOADBLOCK(0xF3)
    constant G_LOADTILE(0xF4)
    constant G_SETTILE(0xF5)
    constant G_FILLRECT(0xF6)
    constant G_SETFILLCOLOR(0xF7)
    constant G_SETFOGCOLOR(0xF8)            // unsupported
    constant G_SETBLENDCOLOR(0xF9)          // unsupported
    constant G_SETPRIMCOLOR(0xFA)           // unsupported
    constant G_SETENVCOLOR(0xFB)            // unsupported
    constant G_SETCOMBINE(0xFC)             // unsupported
    constant G_SETTIMG(0xFD)                // unsupported
    constant G_SETZIMG(0xFE)                // unsupported
    constant G_SETCIMG(0xFF)

    // image formats
    constant G_IM_FMT_RGBA(0x00)
    constant G_IM_FMT_YUV(0x01)
    constant G_IM_FMT_CI(0x02)
    constant G_IM_FMT_IA(0x03)
    constant G_IM_FMT_I(0x04)

    // image sizes
    constant G_IM_SIZ_4b(0x00)
    constant G_IM_SIZ_8b(0x01)
    constant G_IM_SIZ_16b(0x02)
    constant G_IM_SIZ_32b(0x03)

    // uninitialized display list info pointer
    display_list_info_p:
    dw 0x00000000

    // display list builder
    // @ Description
    // Adds to a display list by appending the given 64 bit command and updating the display list
    // pointer. This function will halt execution if (start address + size == address).
    // @ Arguments
    // a0 - upper half of command
    // a1 - lower half of command
    scope append_: {
        addiu   sp, sp,-0x0018              // allocate statck space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // save registers

        li      t0, display_list_info_p      // ~
        lw      t0, 0x0000(t0)              // ~
        lw      t1, 0x0000(t0)              // t1 = start address
        lw      t2, 0x0004(t0)              // t2 = curr address
        lw      t3, 0x0008(t0)              // t3 = size
        addu    t1, t1, t3                  // t1 = start address + size
        beq     t1, t2, _break              // if (curr address == max address), break execution
        nop
        sw      a0, 0x0000(t2)              // store upper half 
        sw      a1, 0x0004(t2)              // store lower half
        addiu   t2, t2, 0x0008              // t2 = curr address++
        sw      t2, 0x0004(t0)              // store new current address

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate statck space
        jr      ra
        nop

        _break:
        break                               // halt execution
    }

    // @ Description
    // Stalls the RDP for a few cycles (does nothing). Used for debugging.
    // @ Arguments
    // a0 - tag [t] (identification number, does nothing)
    // @ Bytefield
    // 00000000 tttttttt
    scope nop_: {
        or      a1, a0, r0                  // lower half
        lui     a0, (G_NOOP << 8)           // upper half
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // The j/jal equivalent of display lists.
    // @ Arguments
    // a0 - boolean is_branch [b] (if b = 0 then jal, if b = 1 then j)
    // a1 - RAM address [a] (address of next display list)
    // @ Bytefield
    // DEbb0000 aaaaaaaa
    scope branch_list_: {
        // a0 = 000000bb
        // a1 = aaaaaaaa (already fine)

        or      a0, a0, (G_DL << 8)         // a0 = upper = 0000DEbb
        sll     a0, a0, 000016              // a0 = upper = DEbb0000
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // The jr ra equivalent of display lists
    // @ Bytefield
    // DF000000 00000000
    scope end_list_: {
        lui     a0, (G_ENDDL << 8)          // a0 = upper
        lui     a1, 0x0000                  // a1 = lower
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // Draws a textured rectangle
    // @ Arguments
    // a0 - int ulx [X]
    // a1 - int uly [Y]
    // a2 - int lrx [x]
    // a3 - int lry [y]
    // texture index [i] = 0
    // s coodrdinate [s] = 0
    // t coodrdinate [t] = 0
    // dsdx [d] = 1 (why?)
    // dtdy [e] = 4 (why?)
    // @ Bytefield
    // E4xxxyyy 0iXXXYYY
    // E1000000 sssstttt
    // F1000000 ddddeeee
    // @ Note
    // The texture_rectangle_wh_ variant uses (a2 = width) and (a3 = height) to caculate lrx and lry
    scope texture_rectangle_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        or      t0, a0, r0                  // t0 = ulx
        or      t1, a1, r0                  // t1 = uly

        _first:
        lui     a0, (G_TEXRECT << 8)        // a0 = opcode
        sll     t2, a2, 0x0002              // t2 = (10.2) lrx
        sll     t2, t2, 0x000C              // t2 = ((10.2) lrx) << 12
        or      a0, a0, t2                  // a0 = opcode | lrx
        sll     t2, a3, 0x0002              // t2 = (10.2) lry
        or      a0, a0, t2                  // t2 = opcode | lrx | lry
        
        or      a1, r0, r0                  // a1 = 0
        sll     t2, t0, 0x0002              // t2 = (10.2) ulx
        sll     t2, t2, 0x000C              // t2 = ((10.2) ulx) << 12
        or      a1, a1, t2                  // a1 = ulx
        sll     t2, t1, 0x0002              // t2 = (10.2) uly
        or      a1, a1, t2                  // t2 = ulx | uly
        jal     append_                     // add to display list
        nop

        _second:
        lui     a0, 0xE100                  // upper = 0xE1000000
        lli     a1, 0x0000                  // lower = 0x00000000
        jal     append_                     // add to display list
        nop

        _third:
        lui     a0, 0xF100                  // upper = 0xE1000000
        li      a1, 0x10000400              // dsdx = 1, dtdy = 4
        jal     append_                     // add to display list
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~ 
        lw      ra, 0x0014(sp)              // retstore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    scope texture_rectangle_wh_: {
        add     a2, a0, a2                  // ~
        addiu   a2, a2,-0x0001              // calculate lrx
        add     a3, a1, a3                  // ~
        addiu   a3, a3,-0x0001              // calculate lry
        j       texture_rectangle_          // run regular texture_rectangle_
        nop
    }

    // @ Description
    // This forces a wait for a texture to load, in order to synchronize with pixel rendering. 
    // This ensures that loading a new texture won't disrupt the rendering of primitives mid-render.
    // @ Bytefield
    // E6000000 00000000
    scope load_sync_: {
        lui     a0, (G_RDPLOADSYNC << 8)    // a0 = upper
        lui     a1, 0x0000                  // a1 = lower
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // Waits for the RDP to finish rendering its currently-rendering primitive, before updating RDP 
    // attributes. This avoids altering the rendering of a primitive in the middle of its render.
    // @ Bytefield
    // E7000000 00000000
    scope pipe_sync_: {
        lui     a0, (G_RDPPIPESYNC << 8)    // a0 = upper
        lui     a1, 0x0000                  // a1 = lower
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // Forces a wait for rendering to finish before updating tile descriptor attributes, so as to 
    // not disrupt rendering of primitives mid-render.
    // @ Bytefield
    // E8000000 00000000
    scope tile_sync_: {
        lui     a0, (G_RDPTILESYNC << 8)    // a0 = upper
        lui     a1, 0x0000                  // a1 = lower
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // Generates an interrupt for the main CPU when the RDP has finished doing everything. 
    // This is typically the last opcode before the "end display list" opcode.
    // @ Bytefield
    // E9000000 00000000
    scope full_sync_: {
        lui     a0, (G_RDPFULLSYNC << 8)    // a0 = upper
        lui     a1, 0x0000                  // a1 = lower
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // Sets the other mode bitfield of the RDP.
    // @ Arguments
    // a0 - high [h]
    // a1 - low [l]
    // @ Bytefield
    // EFhhhhhh llllllll
    scope set_other_modes_: {
        mthi    t0                          // save t0
        lui     t0, (G_RDPSETOTHERMODE << 8)// t0 = opcode
        or      a0, a0, t0                  // a0 = upper
        mfhi    t0                          // restore t0
        j       append_                     // append dlist 
        nop
        break                               // execution not should return here
    }

    scope set_other_modes_fill_: {
        lui     a0, 0x0030                  // cycle type = fil
        lli     a1, 0x0000                  // ~
        j       set_other_modes_            // set other modes fill
        nop
    }

    scope set_other_modes_copy_: {
        lui     a0, 0x0020                  // cycle type = copy
        lli     a1, 0x0001                  // alpha compare enabled
        j       set_other_modes_            // set other modes copy
        nop
    }

    // @ Description
    // Sets the size of the texture for tile descriptor tile.
    // @ Arguments
    // a0 - width
    // a1 - height
    // int lrs [s] = width - 1
    // int lrs [t] = height - 1
    // int uls [S] = 0
    // int ult [T] = 0
    // dsdx [d] = 4
    // dtdy [e] = 1
    // @ Bytefield
    // E4sssttt 0iSSSTTT
    scope set_tile_size_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers
        or      t0, a0, r0                  // t0 = width
        or      t1, a1, r0                  // t1 = height

        lui     a0, (G_SETTILESIZE << 8)    // a0 = opcode
        lli     a1, 0                       // a1 = 0
        addiu   t0, t0,-0x0001              // t0 = width - 1 = lrs
        sll     t0, t0, 0x0002              // t0 = (10.2) lrs
        sll     t0, t0, 0x000C              // t0 = ((10.2) lrs) << 12
        or      a1, a1, t0                  // a0 = opcode | lrs
        addiu   t1, t1,-0x0001              // t1 = height - 1 = lrt
        sll     t1, t1, 0x0002              // t2 = (10.2) lrt
        or      a1, a1, t1                  // t2 = opcode | lrs | lrt
        jal     append_                     // append dlist
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Loads a texture into TMEM as one long line of data (texels + 1 bytes).
    // @ Arguments
    // a0 - width
    // a1 - height
    // uls [s] = 0
    // ult [t] = 0
    // texels [x] = width * height - 1
    // dxt [d] = 0
    // tile index [i] = 0
    // @ Bytefield
    // F3sssttt 0ixxxddd
    scope load_block_: {
        mult    a0, a1                      // ~
        mflo    a1                          // ~
        addiu   a1, a1,-0x0001              // texels = width * height - 1
        sll     a1, a1, 000012              // a1 = texels << 12
        lui     a0, (G_LOADBLOCK << 8)      // a0 = opcode
        j       append_                     // append dlist
        nop
        break                               // execution should not return here
    }

    // @ Description 
    // Draws a solid colored (or striped) rectangle.
    // @ Arguments
    // a0 - int ulx [X]
    // a1 - int uly [Y]
    // a2 - int lrx [x]
    // a3 - int lry [y]
    // @ Bytefield
    // F6xxxyyy 00XXXYYY
    // @ Note
    // The fill_rectangle_wh_ variant uses (a2 = width) and (a3 = height) to caculate lrx and lry
    scope fill_rectangle_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers
        or      t0, a0, r0                  // t0 = ulx
        or      t1, a1, r0                  // t1 = uly

        lui     a0, (G_FILLRECT << 8)       // a0 = opcode
        sll     t2, a2, 0x0002              // t2 = (10.2) lrx
        sll     t2, t2, 0x000C              // t2 = ((10.2) lrx) << 12
        or      a0, a0, t2                  // a0 = opcode | lrx
        sll     t2, a3, 0x0002              // t2 = (10.2) lry
        or      a0, a0, t2                  // t2 = opcode | lrx | lry
        or      a1, r0, r0                  // a1 = 0
        sll     t2, t0, 0x0002              // t2 = (10.2) ulx
        sll     t2, t2, 0x000C              // t2 = ((10.2) ulx) << 12
        or      a1, a1, t2                  // a1 = ulx
        sll     t2, t1, 0x0002              // t2 = (10.2) uly
        or      a1, a1, t2                  // t2 = ulx | uly
        jal     append_                     // add to display list
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~ 
        lw      ra, 0x0014(sp)              // retstore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    scope fill_rectangle_wh_: {
        add     a2, a0, a2                  // ~
        addiu   a2, a2,-0x0001              // calculate lrx
        add     a3, a1, a3                  // ~
        addiu   a3, a3,-0x0001              // calculate lry 
        j       fill_rectangle_             // run regular fill_rectangle_
        nop
    }

    // @ Description
    // Sets many different parameters for tile descriptors.
    // @ Arguments
    // a0 = width 
    // a1 = color format [f]
    // a2 = color size [i]
    // tile line size [i] (number of 64 bit values per row)
    // tmem address [m] = 0
    // tile [t] = 0
    // palette [p] = 0
    // cmT [c] = 0
    // maskT [a] = 0
    // shiftT [s] = 0
    // cmS [d] = 0
    // maskS [b] = 0
    // shiftS [u] = 0
    // @ Bitfield
    //    F    5
    // 1111 0101 fffi i0nn nnnn nnnm mmmm mmmm 0000 0ttt pppp ccaa aass ssdd bbbb uuuu
    scope set_tile_: {

        // for rgba5551
        // tls = width * 2 / 8
        // or
        // tls = (width << 1) >> 3

        // generally
        // tls = width * n / 8
        // or
        // tls = (width << (bytes_per_pixel)) >> 3

        // size will come as one of these
        // constant G_IM_SIZ_4b(0x0000)
        // constant G_IM_SIZ_8b(0x0001)
        // constant G_IM_SIZ_16b(0x0002)
        // constant G_IM_SIZ_32b(0x0003)

        // therefore
        // tls = (width << (size)) >> 4

        mthi    t0                          // save t0
        or      t0, a0, r0                  // t0 = a0 = width
        sllv    t0, t0, a2                  // ~
        srl     t0, t0, 0x0004              // t0 = tls 
        lui     a0, (G_SETTILE << 8)        // a0 = opcode
        sll     a1, a1, 000053              // shift format
        sll     a2, a2, 000051              // shift size
        sll     t0, t0, 000041              // shift tls
        or      a0, a0, a1                  // a0 = opcode | format
        or      a0, a0, a2                  // a0 = opcode | format | size
        or      a0, a0, t0                  // a0 = opcode | format | size | tls 
        lli     a1, 0x0000                  // a1 = 0
        mfhi    t0                          // restore t0
        j       append_                     // jump
        nop
        break                               // execution should not return here
    }

    // @ Description
    // Sets the fill color for use in fill mode, which allows clearing the current color buffer
    // @ Arguments
    // a0 - fill color [f]
    // @ Note
    // 16 bit colors (rgba5551) should be packed 11112222. Otherwise, the RDP will draw striped
    // rectangles.
    // @ Bytefield
    // F700000000 ffffffff
    scope set_fill_color_: {
        or      a1, a0, r0                  // a1 = a0
        lui     a0, (G_SETFILLCOLOR << 8)   // a0 = opcode
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

    // @ Description
    // This opcode sets the location in RAM of the image that will be used when using any of the 
    // texture loading opcodes.
    // @ Arguments
    // a0 - RAM address [a]
    // a1 - color format [f]
    // a2 - color size [s]
    // width = 0 (not used by us)
    // @ Bitfield
    //    F    D       
    // 1111 1101 fffs s000 0000 00ww wwww wwww aaaa aaaa aaaa aaaa aaaa aaaa aaaa aaaa
    scope set_texture_image_: {
        mthi    t0                          // save t0
        or      t0, a0, r0                  // t0 = a0
        lui     a0, (G_SETTIMG << 8)        // a0 = opcode
        sll     a1, a1, 000053              // shift format
        sll     a2, a2, 000051              // shift size
        or      a0, a0, a1                  // a0 = opcode | format
        or      a0, a0, a2                  // a0 = opcode | format | size
        or      a1, t0, r0                  // a1 = address
        mfhi    t0                          // restore t0
        j       append_                     // append dlist
        nop
        break                               // execution not should return here
    }

}

} // __RCP__