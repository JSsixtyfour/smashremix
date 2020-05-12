// captainshared.asm

// This file contains shared functions by Captain Falcon Clones.    

scope CaptainShared {  
    kick_anim_struct:
    dw  0x060F0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x20)
    
    punch_anim_struct:
    dw  0x020F0000
    dw  Character.GND_file_8_ptr
    OS.copy_segment(0xA9AF4, 0x20)
    
    entry_anim_struct:
    dw  0x060A0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)
    
    kick_anim_struct_JFALCON:
    dw  0x060F0000
    dw  Character.JFALCON_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x20)
    
    punch_anim_struct_JFALCON:
    dw  0x020F0000
    dw  Character.JFALCON_file_8_ptr
    OS.copy_segment(0xA9AF4, 0x20)
    
    entry_anim_struct_JFALCON:
    dw  0x060A0000
    dw  Character.JFALCON_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his down special.
    scope get_kick_anim_struct_: {
        OS.patch_start(0x7D6E4, 0x80101EE4)
        j       get_kick_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()
        
        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, kick_anim_struct        // a0 = kick_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      a0, kick_anim_struct_JFALCON        // a0 = kick_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        
        li      a0, 0x8012E2C4              // original line 1/3 (load falcon kick animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his neutral special.
    scope get_punch_anim_struct_: {
        OS.patch_start(0x7D790, 0x80101F90)
        j       get_punch_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()
        
        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, punch_anim_struct       // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      a0, punch_anim_struct_JFALCON       // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        li      a0, 0x8012E2EC              // original line 1/3 (load falcon punch animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his entry animation.
    scope get_entry_anim_struct_: {
        OS.patch_start(0x7EDA0, 0x801035A0)
        j       get_entry_anim_struct_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, entry_anim_struct       // a0 = entry_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON
        li      a0, entry_anim_struct_JFALCON       // a0 = entry_anim_struct_JFALCON
        beq     t0, t1, _end                // end if character id = JFALCON
        nop
        li      a0, 0x8012E6A4              // original line 1/3 (load entry animation struct?)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads the correct file pointer when Ganondorf uses his entry animation.
    scope get_entry_file_ptr_: {
        OS.patch_start(0x7EDBC, 0x801035BC)
        j       get_entry_file_ptr_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      s2, Character.GND_file_7_ptr // a0 = Character.GND_file_7_ptr
        beq     t0, t1, _end                // end if character id = GND
        nop
        ori     t1, r0, Character.id.JFALCON    // t1 = id.JFALCON  
        li      s2, Character.JFALCON_file_7_ptr // a0 = Character.JFALCON _file_7_ptr
        beq     t0, t1, _end                // end if character id = JFALCON  
        nop
        li      s2, 0x8013103C              // original line 1/2 (load falcon file 7 ptr)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // @ Description
    // adds a check for Ganondorf to a routine which determines which bone the punch graphic is
    // attached to
    scope get_punch_bone_: {
         OS.patch_start(0x7D7C8, 0x80101FC8)
        j       get_punch_bone_
        nop
        nop
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()
        
        // a1 = character id
        // at = id.CAPTAIN
        beq     a1, at, _end                // end if character id = CAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.NCAPTAIN
        beq     a1, at, _end                // end if character id = NCAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.GND
        beq     a1, at, _end                // end if character id = GND
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.JFALCON
        beq     a1, at, _end                // end if character id = JFALCON
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        
        lw      v1, 0x0960(a0)              // v1 = other bone struct (used for kirby presumably)
        
        _end:
        j       _return
        nop
    }
    }