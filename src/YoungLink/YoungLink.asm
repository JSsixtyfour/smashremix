// YoungLink.asm

// This file contains file inclusions, action edits, and assembly for Young Link.

scope YoungLink {
    // Insert Moveset files
    insert JUMP, "moveset/JUMP.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert EDGEATTACKF, "moveset/EDGEATTACKF.bin"
    insert EDGEATTACKS, "moveset/EDGEATTACKS.bin"
    insert TECHSTAND, "moveset/TECHSTAND.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert JAB_3,"moveset/JAB_3.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP, "moveset/NEUTRAL_SPECIAL.bin"
    insert USP_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    insert USP_GROUND_END, "moveset/UP_SPECIAL_GROUND_END.bin"
    insert USP_AIR, "moveset/UP_SPECIAL_AIR.bin"
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(YLINK, Action.JumpF,            -1,                        JUMP,                       -1)
    Character.edit_action_parameters(YLINK, Action.JumpB,            -1,                        JUMP,                       -1)
    Character.edit_action_parameters(YLINK, Action.JumpAerialF,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(YLINK, Action.JumpAerialB,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(YLINK, Action.Catch,            -1,                        GRAB,                       -1)
    Character.edit_action_parameters(YLINK, Action.Taunt,           File.YLINK_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(YLINK, Action.Jab1,            -1,                         JAB_1,                      -1)
    Character.edit_action_parameters(YLINK, Action.Jab2,            -1,                         JAB_2,                      -1)
    Character.edit_action_parameters(YLINK, Action.DashAttack,      0x4B2,                      DASH_ATTACK,                -1)
    Character.edit_action_parameters(YLINK, Action.FTilt,           -1,                         FTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.UTilt,           -1,                         UTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.FSmash,          -1,                         FSMASH,                     -1)   
    Character.edit_action_parameters(YLINK, Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(YLINK, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirN,      -1,                         NAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirF,      -1,                         FAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(YLINK, 0xDC,                   -1,                         JAB_3,                      -1)
    Character.edit_action_parameters(YLINK, 0xE5,                   -1,                         NSP,                        -1)
    Character.edit_action_parameters(YLINK, 0xE8,                   -1,                         NSP,                        -1)
    Character.edit_action_parameters(YLINK, 0xE2,                   -1,                         USP_GROUND,                 -1)
    Character.edit_action_parameters(YLINK, 0xE3,                   -1,                         USP_GROUND_END,             -1)
    Character.edit_action_parameters(YLINK, 0xE4,                   -1,                         USP_AIR,                    -1)
    
    
    // @ Description
    // Subroutine for Young Link's up special, allows a direction change with the command 58000002
    scope up_special_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(YLINK, 0xE4,              -1,             -1,                         up_special_direction_,          -1,                             -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.YLINK, 0x4)
    float32 1.15
    OS.patch_end()
    
    // Set default costumes
    // TODO: update this when Young Link has costumes)
    Character.set_default_costumes(Character.id.YLINK, 0, 0, 0, 0, 0, 0, 0)
    
    up_special_landing_fsm:
    float32 0.33                // 25 frames of landing lag
    
    OS.align(16)
    bomb_struct:
    dw 0x00000015
    dw Character.YLINK_file_1_ptr
    //TODO: figure out how long this struct actually is
    OS.copy_segment(0x106108, 0xF8)
    
    OS.align(16)
    up_special_struct:
    dw 0x03000000
    dw 0x00000008
    dw Character.YLINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)
    
    OS.align(16)
    boomerang_struct:
    dw 0x01000000
    dw 0x00000007
    dw Character.YLINK_file_6_ptr
    OS.copy_segment(0x103DEC, 0x34)  
    
    // @ Description
    // modifies a subroutine which runs when a Link bomb is created
    // uses character id to determine which bomb struct to load
    // stores character id in an active item struct
    scope create_bomb_: {
        OS.patch_start(0x100FE0, 0x801865A0)
        addiu   sp, sp,-0x0048              //modified original line 1
        or      a3, a2, r0                  // ~
        or      a2, a1, r0                  // ~
        sw      a1, 0x003C(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0038(sp)              // original code
        j       _get_bomb_struct                
        nop
        _get_bomb_struct_return:
        OS.patch_end()
        OS.patch_start(0x101014, 0x801865D4)
        j       _save_character_id
        nop
        _save_character_id_return:
        OS.patch_end()
        OS.patch_start(0x101098, 0x80186658)
        addiu   sp, sp, 0x0048              // modified original final line
        OS.patch_end()
        
        _get_bomb_struct:
        // v0 = player struct
        lw      a1, 0x0008(v0)              // a1 = character id
        sw      a1, 0x0040(sp)              // store character id
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      t0, bomb_struct             // t0 = YoungLink.bomb_struct
        beq     t1, a1, _end                // end if character id = YLINK
        nop
        li      t0, 0x8018B6C0              // t0 = original bomb struct
        
        _end:
        or      a1, t0, r0                  // a0 = original bomb struct
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _get_bomb_struct_return     // return
        nop
        
        _save_character_id:
        lw      v1, 0x0084(v0)              // original line 1 (v1 = projectile struct)
        lw      a0, 0x0040(sp)              // a0 = character id
        sw      a0, 0x0100(v1)              // store character id in projectile struct (unused? segment)
        lw      a0, 0x0074(v0)              // original line 2
        j       _save_character_id_return   // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which runs when the bomb is flashing
    // loads character id from active item struct
    // uses character id to determine which bomb struct to load
    scope bomb_flash_: {
        OS.patch_start(0x10041C, 0x801859DC)
        j       bomb_flash_
        nop
        _return:
        OS.patch_end()

        lw      t7, 0x0100(v1)              // t7 = character id
        ori     a2, r0, Character.id.YLINK  // a2 = id.YLINK
        li      t6, bomb_struct             // t6 = YoungLink.bomb_struct
        beq     t7, a2, _end                // end if character id = YLINK
        nop
        li      t6, 0x8018B6C0              // t6 = original bomb struct
        _end:
        lw      t6, 0x0004(t6)              // t6 = file 1 pointer address
        lhu     a2, 0x0354(v1)              // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which runs when the bomb explodes
    // loads character id from active item struct
    // uses character id to determine which bomb struct to load
    scope bomb_explosion_: {
        OS.patch_start(0x100DF0, 0x801863B0)
        j       bomb_explosion_
        nop
        _return:
        OS.patch_end()

        lw      t7, 0x0100(v0)              // t7 = character id
        ori     a1, r0, Character.id.YLINK  // a1 = id.YLINK
        li      t6, bomb_struct             // t6 = YoungLink.bomb_struct
        beq     t7, a1, _end                // end if character id = YLINK
        nop
        li      t6, 0x8018B6C0              // t6 = original bomb struct
        _end:
        lw      t6, 0x0004(t6)              // t6 = file 1 pointer address
        j       _return                     // return
        nop
    }
    
    // @ Description
    // adds a check for Young Link to 2 asm routines which are responsible for swapping Link's
    // shield between his hand and back when he starts and finishes holding an item
    scope item_shield_fix_: {
        OS.patch_start(0x63F0C, 0x800E870C)
        jal     item_shield_fix_
        nop
        OS.patch_end()
        
        OS.patch_start(0x63F60, 0x800E8760)
        jal     item_shield_fix_
        nop
        OS.patch_end()
        
        // v1 = character id
        // at = Link id
        beq     v1, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v1, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v1, at, _end                // end if id = YINK
        nop
        
        _end:
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // adds a check for Young Link to an asm routine which is responsible for swapping Link's
    // shield between his hand and back when he grabs an opponent
    scope grab_shield_fix_: {
        OS.patch_start(0xC4A98, 0x8014A058)
        jal     grab_shield_fix_
        nop
        OS.patch_end()
        
        // v0 = character id
        // at = Link id
        beq     v0, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v0, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v0, at, _end                // end if id = YINK
        nop
        
        _end:
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // adds a check for Young Link to 2 asm routines which are responsible for determining the
    // unique properties of Link's dair
    scope dair_fix_: {
        OS.patch_start(0xCB334, 0x801508F4)
        jal     dair_fix_
        nop
        OS.patch_end()
        
        OS.patch_start(0xCB3D4, 0x80150994)
        jal     dair_fix_
        nop
        OS.patch_end()
        
        // v1 = character id
        // at = Link id
        beq     v1, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v1, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v1, at, _end                // end if id = YINK
        nop
        
        _end:
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // adds a check for Young Link to an asm routine which is responsible for updating the position
    // of and drawing(?) Link's sword trail
    scope sword_trail_fix_: {
        OS.patch_start(0x61F68, 0x800E6768)
        j       sword_trail_fix_
        nop
        _return:
        OS.patch_end()
        
        // t8 = character id
        // at = Link id
        beq     t8, at, _branch_end         // branch if id = LINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     t8, at, _branch_end         // branch if id = YLINK
        nop
        
        _end:
        j       0x800E69B4                  // modified original line 1
        lw      ra, 0x0024(sp)              // original line 2
        
        _branch_end:
        j       _return                     // return
        nop       
    }
    
    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine which up special struct to load
    // not 100% sure what this struct is for
    scope up_special_fix_: {
        OS.patch_start(0xE7594, 0x8016CB54)
        j       up_special_fix_
        nop
        _return:
        OS.patch_end()
        
        // s1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, up_special_struct       // a1 = YoungLink.up_special_struct
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        li      a1, 0x80189360              // a1 = original up special struct (original line 1/2)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which runs when Link uses neutral special
    // uses character id to determine which boomerang struct to load
    // not 100% sure what this struct is for
    scope boomerang_fix_: {
        OS.patch_start(0xE8500, 0x8016DAC0)
        j       boomerang_fix_
        nop
        _return:
        OS.patch_end()
        
        // s1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, boomerang_struct        // a1 = YoungLink.boomerang_struct
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        li      a1, 0x801893A0              // a1 = original boomerang struct (original line 1)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        add.s   f8, f4, f6                  // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which determines the speed of Link's boomerang
    // uses a different speed value if character is Young Link
    scope boomerang_speed_: {
        OS.patch_start(0xE8578, 0x8016DB38)
        j       _slow
        nop
        _slow_return:
        OS.patch_end()
        
        OS.patch_start(0xE859C, 0x8016DB5C)
        j       _fast
        nop
        _fast_return:
        OS.patch_end()
        
        _slow:
        or      a1, s1, r0                  // a1 = player struct (original line 1)
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        lw      t0, 0x0008(a1)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     a3, 0x428C                  // a3 = float: 65
        beq     t1, t0, _slow_end           // end if character id = YLINK
        nop
        lui     a3, 0x42AA                  // a3 = float: 85 (original line 2)
        
        _slow_end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _slow_return                // return
        nop
        
        _fast:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        lw      t0, 0x0008(a1)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     a3, 0x42C6                  // a3 = float: 99
        beq     t1, t0, _fast_end           // end if character id = YLINK
        nop
        lui     a3, 0x42E4                  // a3 = float: 114 (original line 2)
        
        _fast_end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x8016D914                  // original line 1
        nop
        j       _fast_return                // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine y velocity
    scope up_special_velocity_: {
        OS.patch_start(0xDEDC8, 0x80164388)
        j       up_special_velocity_
        nop
        _return:
        OS.patch_end()

        // v0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v0)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     at, 0x4240                  // at = float: 48
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        lui     at, 0x428A                  // at = float: 69 (original line 1)
        
        _end:
        mtc1    at, f4                      // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine special fall landing speed
    scope up_special_landing_: {
        OS.patch_start(0xDEA30, 0x80163FF0)
        j       up_special_landing_
        nop
        _return:
        OS.patch_end()
        lw      a0, 0x0028(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(a0)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, up_special_landing_fsm  // ~
        lwc1    f8, 0x0000(a1)              // f8 = YLINK landing fsm value
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        li      a1, 0x8018CA28              // ~
        lwc1    f8, 0x0000(a1)              // f8 = LINK landing fsm value (modified original logic)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
}