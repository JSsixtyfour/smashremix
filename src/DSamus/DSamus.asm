// DSamus.asm

// This file contains file inclusions, action edits, and assembly for Dark Samus.

scope DSamus {
    // Insert Moveset files
    insert ROLLSUB, "moveset/ROLLSUBROUTINE.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert FTILTUP, "moveset/FTILTUP.bin"
    insert FTILTMIDUP, "moveset/FTILTMIDUP.bin"
    insert FTILTMID, "moveset/FTILTMID.bin"
    insert FTILTDOWN, "moveset/FTILTDOWN.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert FSMASHUP, "moveset/FSMASHUP.bin"
    insert FSMASHMIDUP, "moveset/FSMASHMIDUP.bin"
    insert FSMASHMID, "moveset/FSMASHMID.bin"
    insert FSMASHMIDDOWN, "moveset/FSMASHMIDDOWN.bin"
    insert FSMASHDOWN, "moveset/FSMASHDOWN.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UP_SPECIAL_AIR, "moveset/UP_SPECIAL_AIR.bin"
    insert UP_SPECIAL_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    ROLLF:; Moveset.CONCURRENT_STREAM(ROLLSUB); insert "moveset/FROLL.bin"
    insert NEUTRAL1, "moveset/NEUTRAL1.bin"
    insert DASHATTACK, "moveset/DASH.bin"
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.Dash,           File.DSAMUS_DASH,           -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Run,            File.DSAMUS_RUN,            -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          ROLLF,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          ROLLSUB,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpF,          File.DSAMUS_JUMPF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpB,          File.DSAMUS_JUMPB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.Jab1,           -1,                         NEUTRAL1,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.DashAttack,     -1,                         DASHATTACK,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,     -1,                         FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltHigh,      -1,                         FTILTUP,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidHigh,   -1,                         FTILTMIDUP,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.FTilt,          -1,                         FTILTMID,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidLow,    -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltLow,       -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,          File.DSAMUS_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.USmash,         -1,                         USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,         File.DSAMUS_DSMASH,         DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashHigh,     -1,                         FSMASHUP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidHigh,  -1,                         FSMASHMIDUP,                -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmash,         -1,                         FSMASHMID,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidLow,   -1,                         FSMASHMIDDOWN,              -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashLow,      -1,                         FSMASHDOWN,                 -1)
    Character.edit_action_parameters(DSAMUS, 0xE3,                  -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, 0xE4,                  -1,                         UP_SPECIAL_AIR,             -1)
    
     // Modify Actions            // Action             // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    // Character.edit_action(DSAMUS, Action.FTiltHigh,     -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltMidHigh,  -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTilt,         -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltMidLow,   -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltLow,      -1,             -1,                         0x8014E6A0,                     -1,                             -1)

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

        OS.align(16)
        charge_anim_struct:
        dw  0x00000000
        dw  0x00000002
        dw  Character.DSAMUS_file_7_ptr
        OS.copy_segment(0x103A7C, 0x28)  
        
    // Prevents Dark Samus from losing a jump after using down special
    scope bomb_loss_prevention: {
        OS.patch_start(0xD8D34, 0x8015E2F4)
        j       bomb_loss_prevention
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // current character ID
        ori     t1, r0, Character.id.DSAMUS // t2 = id.DSAMUS
        beq     t1, t0, _end                // end if character id = DSAMUS
        nop
        sb      t9, 0x0148(s0)              // original code
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      ra, 0x0024(sp)              // original code
        j       _return                     // return
        nop
        }
        
    
    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 1, 2, 0)
    
    
}