// Linkshared.asm

// This file contains shared functions by Link Clones.

scope LinkShared {

    // Link has a blastwall character ID check it shares with Kirby and is in jigglypuffkirbyshared.asm
    
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
    
    OS.align(16)
    bomb_struct_elink:
    dw 0x00000015
    dw Character.ELINK_file_1_ptr
    OS.copy_segment(0x106108, 0xF8)

    OS.align(16)
    up_special_struct_elink:
    dw 0x03000000
    dw 0x00000008
    dw Character.ELINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)
    
    OS.align(16)
    boomerang_struct_elink:
    dw 0x01000000
    dw 0x00000007
    dw Character.ELINK_file_6_ptr
    OS.copy_segment(0x103DEC, 0x34)  
    
    OS.align(16)
    bomb_struct_jlink:
    dw 0x00000015
    dw Character.JLINK_file_1_ptr
    OS.copy_segment(0x106108, 0xF8)

    OS.align(16)
    up_special_struct_jlink:
    dw 0x03000000
    dw 0x00000008
    dw Character.JLINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)
    
    OS.align(16)
    boomerang_struct_jlink:
    dw 0x01000000
    dw 0x00000007
    dw Character.JLINK_file_6_ptr
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
        ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
        li      t0, bomb_struct_elink       // t0 = Elink.bomb_struct
        beq     t1, a1, _end                // end if character id = ELINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        li      t0, bomb_struct_jlink       // t0 = Jlink.bomb_struct
        beq     t1, a1, _end                // end if character id = JLINK
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
        ori     a2, r0, Character.id.ELINK  // a2 = id.ELINK
        li      t6, bomb_struct_elink       // t6 = ELink.bomb_struct
        beq     t7, a2, _end                // end if character id = ELINK
        nop
        ori     a2, r0, Character.id.JLINK  // a2 = id.JLINK
        li      t6, bomb_struct_jlink       // t6 = JLink.bomb_struct
        beq     t7, a2, _end                // end if character id = JLINK
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
        ori     a1, r0, Character.id.ELINK  // a1 = id.ELINK
        li      t6, bomb_struct_elink       // t6 = ELink.bomb_struct
        beq     t7, a1, _end                // end if character id = ELINK
        nop
        ori     a1, r0, Character.id.JLINK  // a1 = id.JLINK
        li      t6, bomb_struct_jlink       // t6 = JLink.bomb_struct
        beq     t7, a1, _end                // end if character id = JLINK
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
        beq     v1, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v1, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v1, at, _end                // end if id = JLINK
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
        beq     v0, at, _end                // end if id = YLINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v0, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v0, at, _end                // end if id = JLINK
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
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v1, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v1, at, _end                // end if id = JLINK
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
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     t8, at, _branch_end         // branch if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     t8, at, _branch_end         // branch if id = JLINK
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
        ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
        li      a1, up_special_struct_elink // a1 = ELink.up_special_struct
        beq     t1, t0, _end                // end if character id = ELINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        li      a1, up_special_struct_jlink // a1 = JLink.up_special_struct
        beq     t1, t0, _end                // end if character id = JLINK
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

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, boomerang_struct        // a1 = YoungLink.boomerang_struct
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
        li      a1, boomerang_struct_elink  // a1 = ELink.boomerang_struct
        beq     t1, t0, _end                // end if character id = ELINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        li      a1, boomerang_struct_jlink  // a1 = JLink.boomerang_struct
        beq     t1, t0, _end                // end if character id = JLINK
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
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        lui     at, 0x428E                  // at = float: 71
        beq     t1, t0, _end                // end if character id = JLINK
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
    
    }
