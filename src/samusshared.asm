// Samusshared.asm

// This file contains shared functions by Samus Clones.

scope SamusShared {

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
        lw      t1, 0x008C(sp)              // pull struct
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
        li      a1, charge_anim_struct      // a1 = file table
        beq     t1, t2, _end                // end if character id = DSAMUS
        nop
        ori     t2, r0, Character.id.JSAMUS // t2 = id.JSAMUS
        li      a1, charge_anim_struct_jsamus      // a1 = file table
        beq     t1, t2, _end                // end if character id = JSAMUS
        nop
        ori     t2, r0, Character.id.ESAMUS // t2 = id.ESAMUS
        li      a1, charge_anim_struct_esamus      // a1 = file table
        beq     t1, t2, _end                // end if character id = ESAMUS
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
        nop

        jr      ra
        lli     at, Character.id.NSAMUS     // original line 2

        j_0x800E99D4:
        j       0x800E99D4
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
        nop

        j       _kirby_power_change_return
        addiu   at, r0, 0x0007              // original line 2

        j_0x80161EE4:
        j       0x80161EE4
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
