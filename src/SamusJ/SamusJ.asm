// SamusJ.asm

// This file contains file inclusions, action edits, and assembly for J Samus.

scope SamusJ {
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
    insert DAIR, "moveset/DAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert LANDING_NAIR, "moveset/LANDING_NAIR.bin"
    insert VICTORY1, "moveset/VICTORY1.bin"
    insert SELECT, "moveset/SELECT.bin"
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.Dash,           File.DSAMUS_DASH,           -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Walk3,          File.DSAMUS_WALK3,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.Run,            File.DSAMUS_RUN,            -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          ROLLF,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          ROLLSUB,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpF,          File.DSAMUS_JUMPF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpB,          File.DSAMUS_JUMPB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,    0x8E6,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,    0x8E7,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.Jab1,           -1,                         NEUTRAL1,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.DashAttack,     -1,                         DASHATTACK,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     File.DSAMUS_NAIR,           NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.LandingAirN,    0x3CC,                      LANDING_NAIR,               -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,     File.DSAMUS_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirB,     File.DSAMUS_BAIR,           BAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirD,     -1,                         DAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltHigh,      -1,                         FTILTUP,                    -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidHigh,   -1,                         FTILTMIDUP,                 -1)
    Character.edit_action_parameters(DSAMUS, Action.FTilt,          -1,                         FTILTMID,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltMidLow,    -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FTiltLow,       -1,                         FTILTDOWN,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,          File.DSAMUS_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.USmash,         File.DSAMUS_UPSMASH,        USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,         File.DSAMUS_DSMASH,         DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashHigh,     -1,                         FSMASHUP,                   -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidHigh,  -1,                         FSMASHMIDUP,                -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmash,         -1,                         FSMASHMID,                  -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashMidLow,   -1,                         FSMASHMIDDOWN,              -1)
    Character.edit_action_parameters(DSAMUS, Action.FSmashLow,      -1,                         FSMASHDOWN,                 -1)
    Character.edit_action_parameters(DSAMUS, 0xE3,                  -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, 0xE4,                  -1,                         UP_SPECIAL_AIR,             -1)
    
     // Modify Actions            // Action             // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
       Character.edit_action(DSAMUS, 0xE4,                 -1,             -1,                         0x80160370,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltHigh,     -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltMidHigh,  -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTilt,         -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltMidLow,   -1,             -1,                         0x8014E6A0,                     -1,                             -1)
    // Character.edit_action(DSAMUS, Action.FTiltLow,      -1,             -1,                         0x8014E6A0,                     -1,                             -1)

    // Modify Menu Action Parameters                // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(DSAMUS,   0x1,               File.DSAMUS_VICTORY1,       VICTORY1,                    -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x2,               File.DSAMUS_VICTORY1,       VICTORY1,                    -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x3,               File.DSAMUS_VICTORY1,       VICTORY1,                    -1)
    Character.edit_menu_action_parameters(DSAMUS,   0x4,               File.DSAMUS_SELECT,         SELECT,                      -1)
    
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
        
    // Prevents Dark Samus from losing a jump after using air down special
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
        
    // Prevents Dark Samus from losing a jump after using ground down special
    scope ground_bomb_loss_prevention: {
        OS.patch_start(0xD8C04, 0x8015E1C4)
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
    
        // Loads an alternate animation for Dark Samus bomb explosion if explodes via timer
    scope alt_bomb_explosion: {
        OS.patch_start(0xE3A04, 0x80168FC4)
        jal       alt_bomb_explosion
        addiu   a0, a0, 0x001C              // original line
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x010C (a2)             // t0 = projectile type
        ori     t1, r0, TYPE                // t1 = Electric type
        beq     t0, t1, _dsbombgraphic      // branch if type = Electric
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j     0x801005C8                    // original line modified
        nop
        
        _dsbombgraphic:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        addiu   sp, sp, 0xFFD8              // original line
        sw      a0, 0x0028(sp)              // original line
        lui     a0, 0x8013                  // original line
        lw      a0, 0x13C4(a0)              // original line
        sw      ra, 0x001C(sp)              // original line
        sw      s0, 0x0018(sp)              // original line
        addiu   a1, r0, 0x0078              // place new graphic ID
        lui     ra, 0x8010                  // set to original return address
        addiu   ra, ra, 0x05EC              // set to original return address
        j       0x800CE9E8                  // jump to "Create GFX"
        ori     a0, a0, 0x0008
        j       _return                     // return
        nop
    }
    
    // Loads an alternate animation for Dark Samus bomb explosion if explodes via connecting with an opponent
    // active projectile struct is in 0x34(sp)
    scope alt_bomb_explosion_connect: {
        OS.patch_start(0xE3C58, 0x80169218)
        jal     alt_bomb_explosion_connect
        addiu   a0, a0, 0x001C              // original line
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0044(sp)              // load active projectile struct
        lw      t0, 0x010C (t0)             // t0 = projectile type
        ori     t1, r0, TYPE                // t1 = Electric type
        beq     t0, t1, alt_bomb_explosion._dsbombgraphic      // branch if type = Electric
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j     0x801005C8                    // original line modified
        nop
    }
    
    constant TYPE(0x2)                  // electric type damage used in Dark Samus down special in contrast to Samus (Fire type 0x1)
        
     // Loads an the ball graphic used by Samus at then end of her grab
     scope throw_ball_graphic: {
        OS.patch_start(0xC4654, 0x80149C14)
        jal       throw_ball_graphic
        andi    t8, t7, 0xFFFB              // original line 
        _return:
        OS.patch_end()
        
        addiu   at, r0, 0x0022
        beq     v0, at, _darksamusballgraphic
        nop
        addiu   at, r0, 0x0003              // original line
        j       _return                     // return
        nop
        
        _darksamusballgraphic:
        jr      ra                          // return
        nop
        }   
     
     // temporary dark samus charge shot patch
        OS.patch_start(0x6643C, 0x800EAC3C)
        nop
        OS.patch_end()
    
    
    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 1, 2, 0)
    
    
}
