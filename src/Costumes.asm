// Costumes.asm
if !{defined __COSTUMES__} {
define __COSTUMES__()
print "included Costumes.asm\n"

// @ Description
// This file makes all SSB costumes usable in versus.

include "OS.asm"

scope Costumes {

    // @ Description
    // This function replaces the original costume selection in favor of the 19XX style selection.
    // CLeft and Cright will now cycle through colors while CUp and CDown cycle through shades.
    // @ Warning
    // This is not a function that should be called. It is a patch/hook. 
    scope select_: {
        OS.patch_start(0x0001361B4, 0x80137F34)
        j       Costumes.select_
        nop
        _select_return:
        OS.patch_end()

        // a0 holds character id (until original line 2)
        // a1 holds direction pressed (up = 0, right = 1, down = 2, left = 3)

        addiu   sp, sp,-0x0028              // allocate stack sapce
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // ~
        sw      a2, 0x001C(sp)              // ~
        sw      ra, 0x0020(sp)              // save registers
        
        li      t0, functions               // t0 = functions
        sll     t1, a1, 0x0002              // t1 = action * 4 = offset
        add     t0, t0, t1                  // t0 = functions + offset
        lw      t0, 0x0000(t0)              // t0 = function
        li      t1, num_costumes            // t0 = num_costumes Table
        add     t1, t1, a0                  // t0 = num_costumes + offset
        lb      t1, 0x0000(t1)              // t0 = number of costumes char has
        lw      t2, 0x0050(s0)              // a0 = current shade_id
        jr      t0                          // go to function
        lw      v0, 0x004C(s0)              // v0 = current costume_id          


        // change costume
        _right:
        or      t2, r0, r0                  // reset shade
        sltu    at, v0, t1                  // ~
        beql    at, r0, _end                // if (costume_id >= num_costumes)
        or      v0, r0, r0                  // then, v0 = 0
        addiu   v0, v0, 0x0001              // else, costume_id ++
        b       _end                        // end
        nop

        _left:
        or      t2, r0, r0                  // reset shade
        bgtz    v0, _end                    // if (costume_id =)
        addiu   v0, v0,-0x0001              // then, v0--
        or      v0, t1, r0                  // else, v0 = last costume_id
        b       _end                        // end
        nop

        // change tint
        _up:
        sltiu   at, t2, 0x0002              // ~
        beql    at, r0, _end                // if (shade < 2)
        or      t2, r0, r0                  // then, t2 = 0
        addiu   t2, t2, 0x0001              // else, shade_id++
        b       _end                        // end
        nop


        _down:
        bgtz    t2, _end                    // if (costume_id =)
        addiu   t2, t2,-0x0001              // then, t2--
        li      t2, 0x00000002              // else, t2 = 2
        b       _end                        // end
        nop


        _end:
        sw      v0, 0x004C(s0)              // store updated costume_id
        sw      t2, 0x0050(s0)              // store updated shade_id       

        lw      a0, 0x0008(s0)              // a0 = (?)
        lw      a1, 0x004C(s0)              // a1 = costume_id
        lw      a2, 0x0050(s0)              // a2 = shade_id

        addiu   sp, sp,-0x0008              // allocate stack space
        sw      v0, 0x0004(sp)              // save v0
        jal     Costumes.update_            // apply costume
        nop
        lw      v0, 0x0004(sp)              // restore v0
        addiu   sp, sp, 0x0008              // deallocate stack space

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      a1, 0x0018(sp)              // ~
        lw      a2, 0x001C(sp)              // ~
        lw      ra, 0x0020(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack sapce
        
        sw      v0, 0x0024(sp)              // original line 1
        lw      a0, 0x0048(s0)              // original line 2  

        j       _select_return              // return
        nop

        num_costumes:
        db 0x04                             // Mario
        db 0x03                             // Fox
        db 0x04                             // Donkey Kong
        db 0x04                             // Samus
        db 0x03                             // Luigi
        db 0x03                             // Link
        db 0x05                             // Yoshi
        db 0x05                             // Captain Falcon
        db 0x04                             // Kirby
        db 0x03                             // Pikachu
        db 0x04                             // Jigglypuff
        db 0x03                             // Ness
        db 0x00                             // Master Hand
        db 0x00                             // Metal Mario
        db 0x00                             // Polygon Mario
        db 0x00                             // Polygon Fox
        db 0x00                             // Polygon Donkey Kong
        db 0x00                             // Polygon Samus
        db 0x00                             // Polygon Luigi
        db 0x00                             // Polygon Link
        db 0x00                             // Polygon Yoshi
        db 0x00                             // Polygon Captain Falcon
        db 0x00                             // Polygon Kirby
        db 0x00                             // Polygon Pikachu
        db 0x00                             // Polygon Jigglypuff
        db 0x00                             // Polygon Ness
        db 0x00                             // Giant Donkey Kong
        db 0x00                             // (Placeholder)
        db 0x00                             // None (Placeholder)
        db 0x03                             // Falco
        db 0x05                             // Ganondorf
        db 0x00                             // Young Link
        db 0x04                             // Dr. Mario                
        OS.align(4)

        functions:
        dw _up
        dw _right
        dw _down
        dw _left
    }

    // @ Description
    // This is a bug fix to prevent the costume written to using CLeft and CRight from being updated.
    scope disable_update: {
        OS.patch_start(0x001361EC, 0x80137F6C)
        nop                                 // sw v0, 0x0050(s0)
        lw      a0, 0x0008(s0)              // original line 2
        lw      a1, 0x0024(sp)              // original line 3
        nop                                 // jal update_
        OS.patch_end()
    }

    // @ Description
    // Updates costume based on player struct
    // @ Arguments
    // a0 - 0x00008(player struct), ???
    // a1 - costume_id
    // a2 - shade_id
    constant update_(0x800E9248)


} // __COSTUMES__