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
        li      at, 0x80136B68              // at = ra for 1p
        beql    at, ra, _1p_or_bonus        // if we're in 1p, then skip next part
        nop
        li      at, 0x80135608              // at = ra for bonus
        beq     at, ra, _1p_or_bonus        // if we're in bonus, then skip next part
        nop
        b       _go_to_function
        nop

        _1p_or_bonus:
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

        li      at, 0x80137F3C              // at = ra for vs
        bne     at, ra, _store_costume      // if we're not in vs, then skip next part
        nop
        lui     at, 0x8014
        lw      at, 0xBDA8(at)              // at = 0 if FFA, 1 for Team Battle
        bnezl   at, _store_costume          // if Team Battle,
        lw      v0, 0x004C(s0)              // then let's not allow updating the costume

        _store_costume:
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
        db 0x05                             // Metal Mario
        db 0x05                             // Polygon Mario
        db 0x05                             // Polygon Fox
        db 0x05                             // Polygon Donkey Kong
        db 0x05                             // Polygon Samus
        db 0x05                             // Polygon Luigi
        db 0x05                             // Polygon Link
        db 0x05                             // Polygon Yoshi
        db 0x05                             // Polygon Captain Falcon
        db 0x05                             // Polygon Kirby
        db 0x05                             // Polygon Pikachu
        db 0x05                             // Polygon Jigglypuff
        db 0x05                             // Polygon Ness
        db 0x04                             // Giant Donkey Kong
        db 0x00                             // (Placeholder)
        db 0x00                             // None (Placeholder)
        db 0x05                             // Falco
        db 0x05                             // Ganondorf
        db 0x05                             // Young Link
        db 0x05                             // Dr. Mario
        db 0x05                             // Wario
        db 0x05                             // Dark Samus
        db 0x03                             // E Link
        db 0x04                             // J Samus
        db 0x03                             // J Ness
        db 0x05                             // Lucas
        db 0x03                             // J Link
        db 0x05                             // J Falcon
        db 0x03                             // J Fox
        db 0x04                             // J Mario
        db 0x03                             // J Luigi
        db 0x04                             // J Donkey Kong
        db 0x03                             // E Pikachu
        db 0x04                             // J Jigglypuff
        db 0x04                             // E Jigglypuff
        db 0x04                             // J Kirby
        db 0x05                             // J Yoshi
        db 0x03                             // J Pikachu
        db 0x04                             // E Samus
		db 0x05                             // Bowser
		db 0x05                             // Giga Bowser
        db 0x05                             // Piano
		db 0x05                             // Wolf
        db 0x05                             // Conker
        OS.align(4)

        functions:
        dw _up
        dw _right
        dw _down
        dw _left
    }

    // @ Description
    // These prevent the costume/shade from being overwritten when selecting with C buttons or when in team battle.
    scope disable_update: {
        // vs
        OS.patch_start(0x001361EC, 0x80137F6C)
        nop                                 // sw v0, 0x0050(s0)
        lw      a0, 0x0008(s0)              // original line 2
        lw      a1, 0x0024(sp)              // original line 3
        nop                                 // jal update_
        OS.patch_end()

        // vs team battle - prevent skipping individual C-button checks
        OS.patch_start(0x0013679C, 0x8013851C)
        jal     disable_update
        sw      t8, 0x001C(sp)              // original line 2
        OS.patch_end()
        // vs team battle - prevent updating costume when teammate has same character
        OS.patch_start(0x00137D04, 0x80139A84)
        lw      v0, 0x0050(s0)              // original: sw      v0, 0x0050(s0)
        OS.patch_end()

        // training
        OS.patch_start(0x00144C28, 0x80135648)
        nop                                 // jal update_
        OS.patch_end()

        // original line 1: bnez t9, 0x80138650
        beqz    t9, _end                    // if not teams, go forth normally
        // (use delay slot below)

        // otherwise we'll only check C buttons if character is selected and not holding a CPU token
        lw      t0, 0x0088(t8)              // t0 = 1 if character selected
        beqz    t0, _j_0x80138650           // if character is not selected, skip c button checks
        lw      t0, 0x0080(t8)              // t0 = -1 if not holding a token
        bltz    t0, _end                    // if not holding a token, continue normally
        nop

        _j_0x80138650:
        // if here, then we should skip c button checks
        j       0x80138650
        nop

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Provides a way to force high/low poly models.
    scope force_hi_lo_poly_: {
        OS.patch_start(0x53850, 0x800D8050)
        jal     force_hi_lo_poly_
        nop
        OS.patch_end()

        li      t9, Toggles.entry_model_display
        lw      t9, 0x0004(t9)              // t9 = 1 if always high, 2 if always low, 0 if default
        bnezl   t9, pc() + 8                // if not set to default, use t9 as a0 (1 = high poly, 2 = low poly)
        or      a0, r0, t9                  // a0 = forced hi/lo

        sb      a0, 0x000F(v0)              // original line 1
        jr      ra
        sb      a0, 0x000E(v0)              // original line 2
    }

    // @ Description
    // Updates costume based on player struct
    // @ Arguments
    // a0 - 0x00008(player struct), ???
    // a1 - costume_id
    // a2 - shade_id
    constant update_(0x800E9248)
    
    // @ Description
    // Prevents illegal sound from playing when selecting the same costume
    scope prevent_illegal_sound_: {
        // Training - C buttons
        OS.patch_start(0x144C04, 0x80135624)
        // jal 0x80133350                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()

        // Training - C buttons
        OS.patch_start(0x141194, 0x80131BB4)
        // jal 0x80133350                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()

        // VS - C buttons
        OS.patch_start(0x12FF50, 0x80131CD0)
        // jal 0x80134674                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()
    }

    // @ Description
    // This allows multiple players to be the same color by bypassing the check.
    OS.patch_start(0x001361C8, 0x80137F48)
    b       0x80137F60
    OS.patch_end()

    // @ Description
    // Revises attribute location within main file to adjust for Polygon Characters and Metal Mario's new costumes
    
    // Polygon Mario
    pushvar origin, base
    origin 0x94490
    dw 0x000002B0
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NMARIO, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Fox
    pushvar origin, base
    origin 0x95A14
    dw 0x000002BC
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NFOX, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon DK
    pushvar origin, base
    origin 0x96FCC
    dw 0x000002B0
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NDONKEY, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Samus
    pushvar origin, base
    origin 0x98EF8
    dw 0x000003D4
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NSAMUS, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Luigi
    pushvar origin, base
    origin 0x9A310
    dw 0x000002B8
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NLUIGI, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Link
    pushvar origin, base
    origin 0x9B7F0
    dw 0x000002F0
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NLINK, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Yoshi
    pushvar origin, base
    origin 0x9CC70
    dw 0x000002D0
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NYOSHI, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Falcon
    pushvar origin, base
    origin 0x9E178
    dw 0x000002B4
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NCAPTAIN, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Kirby
    pushvar origin, base
    origin 0x9FADC
    dw 0x000002D8
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NKIRBY, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Pikachu
    pushvar origin, base
    origin 0xA0F8C
    dw 0x000002C0
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NPIKACHU, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Jigglypuff
    pushvar origin, base
    origin 0xA242C
    dw 0x000002B8
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NJIGGLY, 0, 1, 4, 5, 1, 3, 2)
    
    // Polygon Ness
    pushvar origin, base
    origin 0xA39D0
    dw 0x00000308
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NNESS, 0, 1, 4, 5, 1, 3, 2)
    
    // Metal Mario
    pushvar origin, base
    origin 0x93A80
    dw 0x000002BC
    pullvar base, origin
    
    // Set default costumes
    Character.set_default_costumes(Character.id.METAL, 0, 1, 4, 5, 1, 3, 2)
    
    
    
} // __COSTUMES__
