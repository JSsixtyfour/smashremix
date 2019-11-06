// Lucas.asm

// This file contains file inclusions, action edits, and assembly for Lucas.

scope Lucas {
    // Insert Moveset files
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    
    
    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.LUCAS, 0x4)
    float32 1.05
    OS.patch_end()
    
    // Set crowd chant FGM.

    // Load Up Special from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012E494
    // @ Description
    // loads a different animation struct when Lucas uses his up special.
    scope get_pkthunder_anim_struct_: {
        OS.patch_start(0x7E208, 0x80102A08)
        j       get_pkthunder_anim_struct_
        nop
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
        beq     t0, t1, _end                // end if character id = GND
        nop
        li      a0, 0x8013E494              // original line 1/3 (load pk thunder animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        sw      a1, 0x001C(sp)              // original line 3
        j       _return                     // return
        nop
    }
    
    pkthunder_anim_struct:
    dw  0x060F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C9C, 0x20)
    
    // Set default costumes
    Character.set_default_costumes(Character.id.LUCAS, 0, 1, 2, 4, 1, 2, 0)
    
    
}