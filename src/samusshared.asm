// Samusshared.asm

// This file contains shared functions by Samus Clones.

scope SamusShared {

// NOTE: Samus white flicker is removed via a moveset command: b0bc0000

// Redirect hardcoding related to Dark Samus Down Special
    // @ Description
    // loads a Dark Samus instruction set, instead of Samus. If Dark Samus uses bombs.
     scope get_bombinstructions_struct_: {
        OS.patch_start(0xE3D74, 0x80169334)
        j       get_bombinstructions_struct_
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // store t0, t1
        lw      t1, 0x0084(a0)              // pull struct from player object
        lw      t1, 0x0008(t1)              // current character ID
        ori     t2, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        li      a1, bomb_anim_struct        // a1 = instructions
        beq     t1, t2, _end                // end if character id = DSAMUS
        nop
        ori     t2, r0, Character.id.JSAMUS // t2 = id.JSAMUS
        li      a1, bomb_anim_struct_jsamus // a1 = instructions
        beq     t1, t2, _end                // end if character id = JSAMUS
        nop
        ori     t2, r0, Character.id.ESAMUS // t2 = id.ESAMUS
        li      a1, bomb_anim_struct_esamus // a1 = instructions
        beq     t1, t2, _end                // end if character id = ESAMUS
        nop
        li      a1, 0x80189070              // original line (load charge animation struct)
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
        
    // Redirect hardcoding related to Dark Samus Neutral Special
    // @ Description
    // loads a Dark Samus instruction set, instead of Samus'. If Dark Samus uses charge shot.
     scope get_chargeinstructions_struct_: {
        OS.patch_start(0xE3854, 0x80168E14)
        j       get_chargeinstructions_struct_
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // store t0, t1
        lw      t1, 0x0008(t6)              // current character ID

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(t6)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(t6)              // t1 = character id of copied power

        ori     t2, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        li      a1, charge_anim_struct      // a1 = projectile struct
        beq     t1, t2, _end                // end if character id = DSAMUS
        nop
        ori     t2, r0, Character.id.JSAMUS // t2 = id.JSAMUS
        li      a1, charge_anim_struct_jsamus      // a1 = projectile struct
        beq     t1, t2, _end                // end if character id = JSAMUS
        nop
        ori     t2, r0, Character.id.ESAMUS // t2 = id.ESAMUS
        li      a1, charge_anim_struct_esamus      // a1 = projectile struct
        beq     t1, t2, _end                // end if character id = ESAMUS
        nop
        ori     t2, r0, Character.id.MTWO   // t2 = id.MTWO
        li      a1, MewtwoNSP.projectile_struct     // a1 = projectile struct
        beq     t1, t2, _end                // end if character id = MTWO
        nop
        li      a1, 0x80189030              // original line (load charge animation struct)
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x801655C8
        sw      a0, 0x0028(sp)
        j       _return                     // return
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when fully charged.
    scope fully_charged_check_: {
        OS.patch_start(0x66418, 0x800EAC18)
        jal     fully_charged_check_
        nop
        OS.patch_end()

        beq     v0, at, j_0x800EAC44        // original line 1, modified to use jump
        lli     at, Character.id.DSAMUS     // at = DSAMUS
        beq     v0, at, j_0x800EAC44        // if DSAMUS, take Samus branch
        lli     at, Character.id.JSAMUS     // at = JSAMUS
        beq     v0, at, j_0x800EAC44        // if JSAMUS, take Samus branch
        lli     at, Character.id.ESAMUS     // at = ESAMUS
        beq     v0, at, j_0x800EAC44        // if ESAMUS, take Samus branch
        lli     at, Character.id.MTWO       // at = MTWO
        beq     v0, at, j_0x800EAC44        // if MTWO, take Samus branch
        nop

        jr      ra
        addiu   a3, sp, 0x003C              // original line 2

        j_0x800EAC44:
        j       0x800EAC44
        addiu   a3, sp, 0x003C              // original line 2
    }

    // @ Description
    // Extends check in end_overlay that allows a Samus-powered Kirby to
    // retain the charged flashing effect when fully charged.
    // Also handles Kirby's Mewtwo charge effect.
    scope kirby_power_check_flash_: {
        OS.patch_start(0x651C4, 0x800E99C4)
        jal     kirby_power_check_flash_
        nop
        OS.patch_end()

        beq     v1, at, j_0x800E99D4        // original line 1, modified to use jump
        lli     at, Character.id.DSAMUS     // at = DSAMUS
        beq     v1, at, j_0x800E99D4        // if DSAMUS, take Samus branch
        lli     at, Character.id.JSAMUS     // at = JSAMUS
        beq     v1, at, j_0x800E99D4        // if JSAMUS, take Samus branch
        lli     at, Character.id.ESAMUS     // at = ESAMUS
        beq     v1, at, j_0x800E99D4        // if ESAMUS, take Samus branch
        lli     at, Character.id.MTWO       // at = MTWO
        beq     v1, at, _mewtwo             // if MTWO, take Mewtwo branch
        lli     at, Character.id.SHEIK      // at = SHEIK
        beq     v1, at, _sheik              // if SHEIK, take Mewtwo branch
        lli     at, Character.id.DEDEDE     // at = DEDEDE
        beq     v1, at, _dedede             // if DEDEDE, take Mewtwo branch
        nop

        jr      ra
        lli     at, Character.id.NSAMUS     // original line 2

        j_0x800E99D4:
        j       0x800E99D4
        nop
        
        _dedede:
        lw      t0, 0x0AE4(a3)              // ~
        addiu   at, r0, 0x0002              // ~
        lw      a0, 0x0020(sp)              // ~
        bne     t0, at, j_0x800E99FC        // original logic, skips if charge level != 7
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id
        
        // return to Samus branch with alternate GFX Routine ID
        j       0x800E99E8                  
        nop 
        
        _sheik:
        lw      t0, 0x0AE0(a3)              // ~
        addiu   at, r0, 0x0006              // ~
        lw      a0, 0x0020(sp)              // ~
        bne     t0, at, j_0x800E99FC        // original logic, skips if charge level != 7
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id
        
        // return to Samus branch with alternate GFX Routine ID
        j       0x800E99E8                  
        nop 
        
        _mewtwo:
        lw      t0, 0x0AE0(a3)              // ~
        addiu   at, r0, 0x0007              // ~
        lw      a0, 0x0020(sp)              // ~
        bne     t0, at, j_0x800E99FC        // original logic, skips if charge level != 7
        lli     a1, GFXRoutine.id.KIRBY_MTWO_CHARGE // a1 = KIRBY_MTWO_CHARGE id
        
        // return to Samus branch with alternate GFX Routine ID
        j       0x800E99E8                  
        nop
        
        j_0x800E99FC:
        j       0x800E99FC
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when Kirby absorbs or ejects a power.
    scope kirby_power_change_: {
        OS.patch_start(0xDC904, 0x80161EC4)
        j       kirby_power_change_
        nop
        _kirby_power_change_return:
        OS.patch_end()

        beq     v0, at, j_0x80161EE4        // original line 1, modified to use jump
        lli     at, Character.id.DSAMUS     // at = DSAMUS
        beq     v0, at, j_0x80161EE4        // if DSAMUS, take Samus branch
        lli     at, Character.id.JSAMUS     // at = JSAMUS
        beq     v0, at, j_0x80161EE4        // if JSAMUS, take Samus branch
        lli     at, Character.id.ESAMUS     // at = ESAMUS
        beq     v0, at, j_0x80161EE4        // if ESAMUS, take Samus branch
        lli     at, Character.id.MTWO       // at = MTWO
        beq     v0, at, j_0x80161EE4        // if MTWO, take Samus branch (Mewtwo uses 0xAE0 as well)
        lli     at, Character.id.MARTH      // at = MARTH
        beq     v0, at, j_0x80161EE4        // if MARTH, take Samus branch (Marth uses 0xAE0 as well)
        lli     at, Character.id.SHEIK      // at = SHEIK
        beq     v0, at, j_0x80161EE4        // if SHEIK, take Samus branch (Sheik uses 0xAE0 as well)
        nop

        j       _kirby_power_change_return
        addiu   at, r0, 0x0007              // original line 2

        j_0x80161EE4:
        j       0x80161EE4
        nop
    }
    
    // Loads an the ball graphic used by Samus at then end of her grab
    scope throw_ball_graphic: {
        OS.patch_start(0xC4654, 0x80149C14)
        jal       throw_ball_graphic
        andi      t8, t7, 0xFFFB              // original line 
        _return:
        OS.patch_end()
        
        addiu   at, r0, Character.id.DSAMUS
        beq     v0, at, _samusballgraphic
        nop
        addiu   at, r0, Character.id.JSAMUS
        beq     v0, at, _samusballgraphic
        nop
        addiu   at, r0, Character.id.ESAMUS
        beq     v0, at, _samusballgraphic
        nop
        addiu   at, r0, 0x0003              // original line
        j       _return                     // return
        nop
        
        _samusballgraphic:
        jr      ra                          // return
        nop
    }   
    
    // Loads an the ball graphic used by Samus at then end of her grab
    scope throw_ball_graphic_2: {
        OS.patch_start(0xC4D1C, 0x8014A2DC)
        j       throw_ball_graphic_2
        sw      r0, 0x0180(s0)              // original line 2
        _return:
        OS.patch_end()
        
        beq     v0, at, _samusballgraphic
        addiu   at, r0, Character.id.DSAMUS
        beq     v0, at, _samusballgraphic
        addiu   at, r0, Character.id.JSAMUS
        beq     v0, at, _samusballgraphic
        addiu   at, r0, Character.id.ESAMUS
        beq     v0, at, _samusballgraphic
        nop
        j       _return                     // return
        nop
        
        _samusballgraphic:
        j      0x8014A2F0                          // return
        nop
    }   
     
     
    // Dark Samus
    
    OS.align(16)
    bomb_anim_struct:
    dw  0x00000000
    dw  0x00000003
    dw  Character.DSAMUS_file_1_ptr
    OS.copy_segment(0x103ABC, 0x28)

    OS.align(16)
    charge_anim_struct:
    dw  0x00000000
    dw  0x00000002
    dw  Character.DSAMUS_file_7_ptr
    OS.copy_segment(0x103A7C, 0x28)

    // J Samus

    OS.align(16)
    bomb_anim_struct_jsamus:
    dw  0x00000000
    dw  0x00000003
    dw  Character.JSAMUS_file_1_ptr
    OS.copy_segment(0x103ABC, 0x28)

    OS.align(16)
    charge_anim_struct_jsamus:
    dw  0x00000000
    dw  0x00000002
    dw  Character.JSAMUS_file_7_ptr
    OS.copy_segment(0x103A7C, 0x28)
        
    // E Samus

    OS.align(16)
    bomb_anim_struct_esamus:
    dw  0x00000000
    dw  0x00000003
    dw  Character.ESAMUS_file_1_ptr
    OS.copy_segment(0x103ABC, 0x28)

    OS.align(16)
    charge_anim_struct_esamus:
    dw  0x00000000
    dw  0x00000002
    dw  Character.ESAMUS_file_7_ptr
    OS.copy_segment(0x103A7C, 0x28)

}
