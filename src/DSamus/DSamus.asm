// DSamus.asm

// This file contains file inclusions, action edits, and assembly for Dark Samus.

scope DSamus {
    // Insert Moveset files
    insert JUMP2, "moveset/JUMP2.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UP_SPECIAL_AIR, "moveset/UP_SPECIAL_AIR.bin"
    insert UP_SPECIAL_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    // insert ROLLF, "moveset/ROLLF.bin"
    // insert ROLLB, "moveset/ROLLB.bin"
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,     -1,                         FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,          0x435,                      DTILT,                      0x00180000)
    Character.edit_action_parameters(DSAMUS, Action.USmash,         -1,                         USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,         0x430,                      DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, 0xE3,                  -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, 0xE4,                  -1,                         UP_SPECIAL_AIR,             -1)
    
    // Modify Menu Action Parameters        // Action          // Animation                // Moveset Data             // Flags
    

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.DSAMUS, 0x4)
    float32 1.05
    OS.patch_end()
    
    // Set crowd chant FGM.
    
    // Load A Neutral Special Graphic from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012DFC4
    // @ Description
    // loads a different animation struct when Dark Samus uses the first graphic animation in his up special.
    // scope get_charge_anim_struct_: {
    //    OS.patch_start(0x7B570, 0x800FFD70)
    //    j       get_charge_anim_struct_
    //    nop
     //   _return:
     //   OS.patch_end()
        
        // v1 = player struct
    //    addiu   sp, sp,-0x0010              // allocate stack space
    //    sw      t1, 0x0004(sp)              // ~
    //    sw      t2, 0x0008(sp)              // store t0, t1
    //    lw      t1, 0x0008(t0)              // t0 = character id
    //    ori     t2, r0, Character.id.DSAMUS // t1 = id.DSAMUS
    //    li      a0, charge_anim_struct      // a0 = charge_anim_struct
    //    beq     t1, t2, _end                // end if character id = DSAMUS
    //    nop
    //    li      a0, 0x8012DFC4              // original line (load charge animation struct)
        
    //    _end:
   //     lw      t0, 0x0004(sp)              // ~
    //    lw      t1, 0x0008(sp)              // load t0, t1
    //    addiu   sp, sp, 0x0010              // deallocate stack space
    //    jal     0x800FDAFC
    //    nop
    //    j       _return                     // return
    //    nop
    }
    
    // Redirect hardcoding related to Dark Samus Down Special
    // @ Description
    // loads a Dark Samus file table, instead of Samus. If Dark Samus uses bombs.
     scope get_filetable_struct_: {
        OS.patch_start(0xE3D74, 0x80169334)
        j       get_filetable_struct_
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // store t0, t1
        lw      t1, 0x008C(sp)              // pull struct
        lw      t1, 0x0008(t1)              // current character ID
        ori     t2, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        li      a1, bomb_anim_struct        // a1 = file table
        beq     t1, t2, _end                // end if character id = DSAMUS
        nop
        li      a1, 0x80189070              // original line (load charge animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    
    // don't fully understand but an ID check at 800E73CC seems to allow dark samus to use charge shot
    
    // OS.align(16)
    // charge_anim_struct:
    // dw  0x020A0000
    // dw  File.DSAMUS_SECONDARY
    // OS.copy_segment(0xA97CC, 0x20)    
    
     OS.align(16)
     bomb_anim_struct:
     dw  0x00000000
     dw  0x00000003
     dw  Character.DSAMUS_file_1_ptr
     OS.copy_segment(0x103ABC, 0x28)  
    
    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 1, 2, 0)
    
    
}