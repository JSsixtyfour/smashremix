// NessJ.asm

// This file contains file inclusions, action edits, and assembly for J Ness

scope NessJ {
    // Insert Moveset files
    insert UTILT, "moveset/UTILT.bin"
    
	// examples
	// insert DSMASH, "moveset/DSMASH.bin"
    // insert USMASH, "moveset/USMASH.bin"
    // insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    // GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    
    // -1 means no change from the character from which this one was cloned
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(LUCAS, Action.AttackAirN,      -1,                         NAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirF,      -1,                         FAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.UTilt,           -1,                         UTILT,                      -1)
    Character.edit_action_parameters(LUCAS, Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(LUCAS, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(LUCAS, Action.Catch,           -1,                         GRAB,                       -1)
    
    // Modify Menu Action Parameters        // Action          // Animation                // Moveset Data             // Flags
    

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.LUCAS, 0x4)
    float32 1.05
    OS.patch_end()
    
    // Set crowd chant FGM.

    // Load Up Special from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012E494
    // @ Description
    // loads a different animation struct when Lucas uses the first graphic animation in his up special.
    scope get_pkthunder_anim_struct_: {
        OS.patch_start(0x7E208, 0x80102A08)
        j       get_pkthunder_anim_struct_
        nop
        _return:
        OS.patch_end()
        
        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a0, pkthunder_anim_struct   // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = LUCAS
        nop
        li      a0, 0x8012E494              // original line 1/3 (load pk thunder animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // Load Up Special from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012E444
    // @ Description
    // loads a different animation struct when Lucas uses the third graphic animation in his up special.
    scope get_pkthunder_anim_struct3_: {
        OS.patch_start(0x7E058, 0x80102858)
        j       get_pkthunder_anim_struct3_
        nop
        _return:
        OS.patch_end()
        
        // t7 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(t7)              // t0 = character id
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a0, pkthunder_anim_struct3  // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = LUCAS
        nop
        li      a0, 0x8012E444              // original line (load pk thunder animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // Load Up Special Functionality from different struct
    // Location of original subroutine 801655C8
    // @ Description
     // loads a different special struct1 when Lucas uses his up special.
     scope get_pkthunder_special_struct1_: {
        OS.patch_start(0xE5D1C, 0x8016B2DC)
        j       get_pkthunder_special_struct1_
        nop
        _return:
        OS.patch_end()
        
        // 0x0050(sp) = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0084(a0)
        lw      t0, 0x0008(t0)
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_special_struct1  // a1 = pkthunder_special_struct
        beq     t1, t0, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019              // original line
        addiu   a1, a1, 0x91D0           // original line
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        sw      a0, 0x0018(sp)              // original line
        j       _return                     // return
        nop
    }
    
    // Load Up Special Functionality from different struct
    // Location of original subroutine 801655C8
    // @ Description
    // loads a different special struct2 when Lucas uses his up special.
     scope get_pkthunder_special_struct2_: {
        OS.patch_start(0xE5FD8, 0x8016B598)
        j       get_pkthunder_special_struct2_
        nop
        _return:
        OS.patch_end()
        
        // 0x0050(sp) = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t2, 0x01B4(t0)            // load player struct from projectile struct
        lw      t2, 0x0008(t2)
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_special_struct2  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019                  // original line
        addiu   a1, a1, 0x9204              // original line
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // 8016B598
    
    OS.align(16)
    pkthunder_anim_struct:
    dw  0x060F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C9C, 0x20)
    
    OS.align(16)
    pkthunder_anim_struct3:
    dw  0x020F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C4C, 0x20)
    
    OS.align(16)
    pkthunder_special_struct1:
    dw 0x03000000
    dw 0x0000000E
    dw Character.LUCAS_file_1_ptr
    OS.copy_segment(0x103C1C, 0x28)
    
    OS.align(16)
    pkthunder_special_struct2:
    dw 0x02000000
    dw 0x0000000F
    dw Character.LUCAS_file_1_ptr
    OS.copy_segment(0x103C50, 0x28)
   
    
    // establishes a pointer to the character struct that cam be used for a character id check during
    // special_struct3.
    scope get_pkthunder_playerstruct1_: {
        OS.patch_start(0xE597C, 0x8016AF3C)
        j       get_pkthunder_playerstruct1_
        nop
        _return:
        OS.patch_end()
        sw      a2, 0x01B4(a3)              // save playerstruct to unused space in projectile struct
        jal     0x8016AE64                  // original code
        sw      a3, 0x0054(sp)              // original code
        j       _return                     // return
        nop    
    
    // establishes a pointer to the character struct that cam be used for a character id check during
    // special_struct3.
     scope get_pkthunder_playerstruct2_: {
        OS.patch_start(0xE5E10, 0x8016B3D0)
        j       get_pkthunder_playerstruct2_
        nop
        _return:
        OS.patch_end()
        sw      a0, 0x01B4(a2)              // save player struct to unused space in projectile struct
        sll     t1, t0, 1                   // original code
        lw      t9, 0x0AE0(a0)
        j       _return                     // return
        nop
        
    
    // Set default costumes
    Character.set_default_costumes(Character.id.LUCAS, 0, 1, 2, 4, 1, 2, 0)
    
    
}