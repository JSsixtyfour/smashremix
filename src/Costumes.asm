// Costumes.asm
if !{defined __COSTUMES__} {
define __COSTUMES__()
print "included Costumes.asm\n"

// @ Description
// This file makes all SSB costumes usable in versus and training.
// TODO: Shades don't work in 1p, Bonus or Training - once you leave the CSS, the shade resets to default

include "OS.asm"

scope Costumes {

    // @ Description
    // This function replaces the original costume selection in favor of the 19XX style selection.
    // CLeft and Cright will now cycle through colors while CUp and CDown cycle through shades.
    // @ Warning
    // This is not a function that should be called. It is a patch/hook. 
    scope select_: {
        // vs
        OS.patch_start(0x001361B4, 0x80137F34)
        jal     Costumes.select_
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x00144BF8, 0x80135618)
        jal     Costumes.select_
        nop
        OS.patch_end()

        // 1P
        OS.patch_start(0x13ED5C, 0x80136B5C)
        sw      s0, 0x001C(sp)              // store s0
        jal     Costumes.select_
        addu    s0, v1, r0                  // s0 = player struct
        lw      s0, 0x001C(sp)              // restore s0
        sw      v0, 0x001C(sp)              // original line 2
        nop
        OS.patch_end()

        // Bonus
        OS.patch_start(0x14B628, 0x801355F8)
        li      s0, 0x80137648              // s0 = player struct
        jal     Costumes.select_
        nop
        addu    s0, r0, r0                  // restore s0
        sw      v0, 0x001C(sp)              // original line 2
        OS.patch_end()

        // a0 holds character id (until original line 2)
        // a1 holds direction pressed (up = 0, right = 1, down = 2, left = 3)

        addiu   sp, sp,-0x0028              // allocate stack space
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
        li      t1, num_costumes            // t1 = num_costumes Table
        add     t1, t1, a0                  // t1 = num_costumes + offset
        lb      t1, 0x0000(t1)              // t1 = number of costumes char has

        li      at, 0x80135620              // at = ra for training
        beq     at, ra, _training           // if we're in training, then skip next part
        nop
        lw      t2, 0x0050(s0)              // t2 = current shade_id
        li      at, 0x80136B6C              // at = ra for 1p
        beq     at, ra, _1p                 // if we're in 1p, then skip next part
        nop
        b       _go_to_function
        nop

        _1p:
        jr      t0                          // go to function
        lw      v0, 0x0024(s0)              // v0 = current costume_id

        _training:
        li      at, Global.p_struct_head    // Global player struct head
        lw      at, 0x0000(at)              // 1st loaded player struct
        li      v0, Global.P_STRUCT_LENGTH  // v0 = Global.P_STRUCT_LENGTH
        lb      t2, 0x000D(at)              // t2 = 0 if human, 1 if CPU
        multu   t2, v0                      // Get offset of human player (human will be loaded 2nd sometimes)
        mflo    t2                          // t2 = offset
        addu    at, at, t2                  // at = human player struct
        lb      t2, 0x0011(at)              // t2 = current shade_id

        _go_to_function:
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

        _1p_2:
        sw      v0, 0x0024(s0)              // store updated costume_id
        sw      t2, 0x0050(s0)              // store updated shade_id
        lw      a0, 0x0008(s0)              // a0 = (?)
        b       _finish
        nop

        _end:
        lw      a0, 0x0008(s0)              // a0 = (?)
        addu    a1, v0, r0                  // a1 = costume_id

        li      at, 0x80136B6C              // at = ra for 1p
        beq     at, ra, _1p_2               // if we're in 1p, then skip next part
        nop

        sw      v0, 0x004C(s0)              // store updated costume_id

        li      at, 0x80135620              // at = ra for training
        beq     at, ra, _finish             // if we're in training, then skip next part
        nop

        sw      t2, 0x0050(s0)              // store updated shade_id

        _finish:
        or      a2, t2, r0                // a2 = shade_id
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
        addiu   sp, sp, 0x0028              // deallocate stack space
        
        sw      v0, 0x0024(sp)              // original line 1
        lw      a0, 0x0048(s0)              // original line 2  

        jr      ra                          // return
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
        db 0x05                             // Falco
        db 0x05                             // Ganondorf
        db 0x05                             // Young Link
        db 0x04                             // Dr. Mario
        db 0x04                             // Wario
        db 0x05                             // Dark Samus
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
        // vs
        OS.patch_start(0x001361EC, 0x80137F6C)
        nop                                 // sw v0, 0x0050(s0)
        lw      a0, 0x0008(s0)              // original line 2
        lw      a1, 0x0024(sp)              // original line 3
        nop                                 // jal update_
        OS.patch_end()

        // training
        OS.patch_start(0x00144C28, 0x80135648)
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

    
    // TODO: this is temporary (until stock icon palettes can be integrated into character files)
    // However, the general concept could be applied to a more developed system for patching
    // character files upon character load.
    // @ Description
    // Patch which overrides the icon palette array pointer with a hard coded array if a pointer is
    // present in icon_palette_table. Runs when a character finishes loading.
    scope icon_override_: {
        OS.patch_start(0x530A8, 0x800D78A8)
        j       icon_override_
        nop
        OS.patch_end()
        
        lw      a0, 0x0018(sp)              // a0 = character id
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // store t0 - t2
        
        sll     t0, a0, 0x3                 // t0 = character id * 8
        li      t1, icon_palette_table      // t1 = icon_palette_table
        addu    t1, t1, t0                  // t1 = icon_palette_table + id * 8
        lw      t0, 0x0004(t1)              // t0 = icon palette array pointer for {character}
        beq     t0, r0, _end                // end if t0 = NULL
        nop
        sll     t0, a0, 0x2                 // t0 = character id * 4
        li      t2, 0x80116E10              // t2 = character struct table
        addu    t2, t2, t0                  // t2 = character struct table + id * 4
        lw      t2, 0x0000(t2)              // t2 = struct for {character}
        lw      t2, 0x0028(t2)              // t2 = main file pointer address for {character}
        lw      t2, 0x0000(t2)              // t2 = main file address for {character}
        lw      t0, 0x0000(t1)              // t0 = icon palette array offset
        addu    t2, t2, t0                  // t2 = main file address + offset
        lw      t0, 0x0004(t1)              // t0 = icon palette array pointer for {character}
        sw      t0, 0x0000(t2)              // store updated icon palette array pointer
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // load t0 - t2
        addiu   sp, sp, 0x0028              // deallocate stack space + original line 1
        jr      ra                          // original line 2
        nop
    }
    
    // @ Description
    // Table of pointers to icon palette arrays, when a pointer is present it will override the
    // default array and load from the one in this table instead.
    // Format:
    // XXXXXXXX YYYYYYYY
    // XXXXXXXX = offset of palette array pointer in main file
    // YYYYYYYY = pointer to new palette array
    icon_palette_table:
    constant icon_palette_table_origin(origin())
    fill Character.NUM_CHARACTERS * 0x8
    
    // @ Description
    // Adds a hard coded icon palette array for a given character.
    // @ Arguments
    // id - character id to modify costumes for
    // offset - offset of palette array pointer in main file
    // array - pointer to new palette array
    macro add_icon_palette_array(id, offset, array) {
        pushvar origin, base
        origin Costumes.icon_palette_table_origin + ({id} * 8)
        dw  {offset}
        dw  {array}
        pullvar base, origin
    }
    
} // __COSTUMES__
