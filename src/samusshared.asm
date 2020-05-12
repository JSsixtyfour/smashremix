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