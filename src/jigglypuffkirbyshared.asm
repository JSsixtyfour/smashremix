// jigglypuffkirbyshared.asm

// This file contains shared functions by Jigglypuff and Kirby Clones.

scope JigglypuffKirbyShared {

    // character ID check add for when Jigglypuff Clones are doing 2+ jumps. This is the first of the double jump routines
    scope jump_fix_1: {
        OS.patch_start(0xBA9A8, 0x8013FF68)
        j       jump_fix_1              
        addiu at, r0, 0x000A            // original line 1
        _return:
        OS.patch_end()
        
        beq     v0, at, _puff_jump_1       // modified original line 2
        addiu   at, r0, Character.id.JPUFF    // JPuff ID
        beq     v0, at, _puff_jump_1
        addiu   at, r0, Character.id.EPUFF    // EPuff ID
        beq     v0, at, _puff_jump_1
        addiu   at, r0, Character.id.JKIRBY    // JKirby ID
        beq     v0, at, _kirby_jump_1
        nop
        j       _return                     // return
        nop
        
        _puff_jump_1:
        j       0x8013FF9C                  // routine for puff jumps
        nop     

        _kirby_jump_1:
        j       0x8013FF8C                  // routine for puff jumps
        nop
    }
    
        // character ID check add for when Jigglypuff Clones are doing 3+ jumps
    scope jump_fix_2: {
        OS.patch_start(0xBAA8C, 0x8014004C)
        j       jump_fix_2              
        addiu	t6, r0, 0x0050
        _return:
        OS.patch_end()
        
        addiu   at, r0, 0x000A                  // Puff ID
        beq     v0, at, _puff_jump_2            // modified original line 2
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v0, at, _puff_jump_2
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v0, at, _puff_jump_2
        addiu   at, r0, Character.id.JKIRBY   // JKIRBY ID
        beq     v0, at, _kirby_jump_2
        nop
        j       _return                     // return
        nop
        
        _puff_jump_2:
        j       0x801400A0                  // routine for puff jumps
        nop   
        
        _kirby_jump_2:
        j       0x80140070                  // routine for puff jumps
        nop    
    }
    
        // character ID check add for when Jigglypuff Clones are jumping/in the air.
    scope jump_fix_3: {
        OS.patch_start(0xBAC20, 0x801401E0)
        j       jump_fix_3              
        nop
        _return:
        OS.patch_end()
        
        beq     v1, at, _puff_jump_3            // modified original line 1
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.JKIRBY   // J Kirby ID
        beq     v1, at, _puff_jump_3
        nop
        j       _return                     // return
        addiu   at, r0, 0x0018              // original line 2
        
        _puff_jump_3:
        j       0x801401F0                  // routine for puff jumps
        addiu   at, r0, 0x0018              // original line 2   
    }
    
        // character ID check add for when Jigglypuff Clones are doing 2+ jumps. This is the second of the double jump routines.
    scope jump_fix_4: {
        OS.patch_start(0xBA6F0, 0x8013FCB0)
        j       jump_fix_4              
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()
        
        beq     v0, at, _puff_jump_4            // modified original line 1
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v0, at, _puff_jump_4
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v0, at, _puff_jump_4
        addiu   at, r0, Character.id.JKIRBY   // JKIRBY ID
        beq     v0, at, _kirby_jump_4
        nop
        j       _return                     // return
        nop
        
        _puff_jump_4:
        j       0x8013FD18                  // routine for puff jumps
        nop    

        _kirby_jump_4:
        j       0x8013FCD4                  // routine for puff jumps
        addiu   at, r0, 0x000A 
    }
    
        // character ID check add for when Jigglypuff Clones are jumping.
    scope jump_fix_5: {
        OS.patch_start(0xBAC78, 0x80140238)
        j       jump_fix_5              
        nop
        _return:
        OS.patch_end()
        
        beq     v1, at, _puff_jump_5            // modified original line 1
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v1, at, _puff_jump_5
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v1, at, _puff_jump_5
        addiu   at, r0, Character.id.JKIRBY   // JKIrby ID
        beq     v1, at, _kirby_jump_5
        nop
        j       _return                     // return
        addiu   at, r0, 0x0016
        
        _puff_jump_5:
        j       0x8014029C                  // routine for puff jumps
        addiu   at, r0, 0x0016       
        
        _kirby_jump_5:
        j       0x80140258                  // routine for puff jumps
        addiu   at, r0, 0x000A  
    }
    
    // character ID check add for when Kirby Clones receive their boomerang.
    scope kirby_boomerangfix_1: {
        OS.patch_start(0xE7DFC, 0x8016D3BC)
        j       kirby_boomerangfix_1              
        addiu   at, r0, 0x0008                  // original line 1
        _return:
        OS.patch_end()
        
        beq     v1, at, _boomer_fix_1            // modified original line 2
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, at, _boomer_fix_1
        nop
        j       _return                     // return
        nop
        
        _boomer_fix_1:
        j       0x8016D3D0                  // routine for kirby bommerang
        nop                                                     
    }
    
    // character ID check add for when Kirby Clones receive their boomerang.
    scope kirby_boomerangfix_2: {
        OS.patch_start(0xE7D70, 0x8016D330)
        j       kirby_boomerangfix_2                      
        lw      a1, 0x0008(v1)                 // original line 1 
        _return:
        OS.patch_end()
        
        beq     a1, at, _boomer_fix_2            // modified original line 2
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     a1, at, _boomer_fix_2
        nop
        j       _return                     // return
        nop
        
        _boomer_fix_2:
        j       0x8016D344                  // routine for kirby bommerang
        nop                                                     
    }
    
    // Kirby has a hardcoded projectile struct for his up special similar to Ness and Link. This code inserts a new pointer to the clones main file so the game doesn't crash.
    scope kirby_special_struct_fix: {
        OS.patch_start(0xE68E0, 0x8016BEA0)
        j       kirby_special_struct_fix                      
        nop 
        _return:
        OS.patch_end()
             
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      t2, 0x0008(t6)                  // load character struct from t6
        addiu   t1, r0, Character.id.JKIRBY     // JKIRBY ID
        li      a1, upspecial_struct_jkirby    // JKirby File Pointer placed in correct location
        beq     t1, t2, _end
        nop
        
        lui     a1, 0x8019                 // original line 1 
        addiu   a1, a1, 0x92A0             // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        j       _return                     // return
        nop                                                  
    }
      
    // character ID check add for when Kirby Clones use their infinite.
    scope kirby_infinite_1: {
        OS.patch_start(0xC9C0C, 0x8014F1CC)
        j       kirby_infinite_1                      
        or      s0, a0, r0                 // original line 2
        _return:
        OS.patch_end()
        
        
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     t6, at, _infinite_fix_1
        nop
        j       _return                     // return
        addiu   at, r0, 0x0008              // original line 1   
        
        _infinite_fix_1:
        j       0x8014F1DC                  // routine for kirby infinite
        addiu   at, r0, 0x0008              // original line 1                                                    
    }
    
    // character ID check add for when Kirby Clones use forward throw.
    scope kirby_fthrow_1_fix: {
        OS.patch_start(0xC4C78, 0x8014A238)
        j       kirby_fthrow_1_fix                      
        or      a0, s0, r0                 // original line 2
        _return:
        OS.patch_end()
        
        beq     v0, at, _kirbyfthrow_1          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _kirbyfthrow_1
        nop
		addiu	t3, r0, 0x00E5					// Set correct action ID for bowser
		addiu   at, r0, Character.id.BOWSER     // BOWSER ID
		beq     v0, at, _kirbyfthrow_1
		addiu   at, r0, Character.id.GBOWSER    // GBOWSER ID
		beq     v0, at, _kirbyfthrow_1
        nop
        j       _return                     // return
        nop   
        
        _kirbyfthrow_1:
        j       0x8014A24C                  // routine for kirby fthrow
        nop                                 // original line 1                                                    
    }
    
    // character ID check add for when Kirby Clones use forward throw.
    scope kirby_fthrow_2_fix: {
        OS.patch_start(0xC4D8C, 0x8014A34C)
        j       kirby_fthrow_2_fix                      
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _kirbyfthrow_2          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _kirbyfthrow_2
        nop
        j       _return                     // return
        addiu   at, r0, 0x0016              // original line 2   
        
        _kirbyfthrow_2:
        j       0x8014A358                  // routine for kirby fthrow
        addiu   at, r0, 0x0016              // original line 2                                                    
    }
    
    // character ID check add for when Kirby and Link Clones hit the blast wall.
    scope kirby_blast_fix_1: {
        OS.patch_start(0x531B0, 0x800D79B0)
        j       kirby_blast_fix_1                      
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _kirbyblast_1          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY    // JKIRBY ID
        beq     v0, at, _kirbyblast_1
        
        addiu   at, r0, Character.id.YLINK     // YLINK ID
        beq     v0, at, _linkblast_1
        addiu   at, r0, Character.id.ELINK     // ELINK ID
        beq     v0, at, _linkblast_1
        addiu   at, r0, Character.id.JLINK     // JLINK ID
        beq     v0, at, _linkblast_1
        nop
        
        j       _return                     // return
        addiu   at, r0, 0x0013              // original line 2   
        
        _kirbyblast_1:
        j       0x800D79CB                  // routine for kirby blast wall
        addiu   at, r0, 0x0013              // original line 2 

        _linkblast_1:
        j       0x800D79D8                  // routine for link blast wall
        addiu   at, r0, 0x0008              // original line 2       
    }
    
    // character ID check add for when Kirby Clones hit the blast wall.
    scope kirby_blast_fix_2: {
        OS.patch_start(0x53654, 0x800D7E54)
        j       kirby_blast_fix_2                      
        nop
        _return:
        OS.patch_end()
        
        beq     v0, t3, _kirbyblast_2           // originally a BNE for Kirby
        addiu   v0, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, t3, _jkirbyblast_2
        nop
        
        _regular_blast_2:
        j       0x800D7F0C                      // routine for kirby blast wall
        nop 
        
        _kirbyblast_2:
        j       _return                     // return
        nop                                 // original line 2     

        _jkirbyblast_2:
        lw      t7, 0x0ADC(v1)
        li      t9, Character.JKIRBY_file_2_ptr
        lw      t9, 0x0000(t9)
        j       0x800D7E64                     // return
        nop 
    }
    
    // character ID check add for when Kirby Clones use taunt. This ensures that he abandons his power.
    scope kirby_taunt_fix_1: {
        OS.patch_start(0xC9138, 0x8014E6F8)
        j       kirby_taunt_fix_1                      
        nop
        _return:
        OS.patch_end()
        
        beq     v1, a1, _kirby_taunt_1            // modified original line 1, checking to see if the character is Kirby
        nop
        addiu   a1, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, a1, _kirby_taunt_1
        addiu   a1, r0, Character.id.KIRBY     // KIRBY ID
        j       _return                     // return
        nop                                 // original line 1 was orinally a beql  
        
        _kirby_taunt_1:
        j       0x8014E70C                  // routine for kirby taunt
        lw      t6, 0x0ADC(v0)              // original line 2                                                    
    }
    
    // character ID check add for when Kirby Clones use taunt. This ensures that he abandons his power.
    // scope kirby_taunt_fix_2: {
    //    OS.patch_start(0xC914C, 0x8014E70C)
    //    j       kirby_taunt_fix_2                      
    //    nop
    //    _return:
    //    OS.patch_end()
    //    
    //    beq     a1, t6, _kirby_taunt_2            // modified original line 1, this is actually checking if he currently has a power
    //    nop
    //    addiu   a1, r0, Character.id.JKIRBY     // JKIRBY ID
    //    beq     a1, t6, _kirby_taunt_2
    //    nop
    //    j       _return                     // return
    //    nop                                 // original line 1 was orinally a beql  
    //    
    //    _kirby_taunt_2:
    //    j       0x8014E738                  // routine for kirby taunt
    //    addiu   a1, r0, 0x00BD              // original line 2                                                    
    }
	
	// character ID check add for when Kirby Clones use taunt. This ensures that he abandons his power.
    scope kirby_unknown_fix: {
        OS.patch_start(0x5DBE8, 0x800E23E8)
        j       kirby_unknown_fix                      
        nop
        _return:
        OS.patch_end()
        
        beq     t0, at, _kirby_fix_1            // modified original line 1, this is actually checking if he currently has a power
        nop
        addiu   at, r0, Character.id.JKIRBY      // JKIRBY ID
		beq     t0, at, _kirby_fix_1
        nop
        j       0x800E23FC          		// modified original line 1, was a bnel for everyone but kirby
        lw		v0, 0x09E8(s1)                  // original line 2  
        
        _kirby_fix_1:
        j       _return                  // routine for kirby taunt
        nop                                               
    }
    
    
    // character ID check add for when Pikachu and Jigglypuff Clones use spawn on stage.
    scope pokemon_spawn_fix: {
        OS.patch_start(0xB8480, 0x8013DA40)
        j       pokemon_spawn_fix                      
        nop
        _return:
        OS.patch_end()
        
        
        
        beq     v0, at, _pokeballflash          // modified original line 1 part 1
        
        addiu   at, r0, Character.id.JPUFF      // JPUFF ID
        beq     v0, at, _pokeballflash          // JPUFF Jump
        addiu   at, r0, Character.id.EPUFF      // EPUFF ID
        beq     v0, at, _pokeballflash          // EPUFF Jump
        
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v0, at, _pokeballflash          // EPIKA Jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v0, at, _pokeballflash          // JPIKA Jump
        nop
        
        j       _return                     // return
        addiu   at, r0, 0x0017              // original line 2   
        
        _pokeballflash:
        j       0x8013DA58                  // modified original line 1 part 2
        addiu   at, r0, 0x0017              // original line 2                                                    
    }
    
    // character ID check add for when Pikachu and Jigglypuff Clones wear hats.
    scope pokemon_hat_fix_1: {
        OS.patch_start(0x6D730, 0x800F1F30)
        j       pokemon_hat_fix_1                      
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()
        
        addiu   at, r0, Character.id.PIKACHU    // PIKA ID
        beq     t9, at, _pikachuhat             // PIKA Jump - original line 1 replacement
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     t9, at, _pikachuhat             // EPIKA Jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     t9, at, _pikachuhat             // JPIKA Jump
        nop 
        
        j       _return                     // return
        addiu   at, r0, 0x000A              // replacing what at would normally be
        
        _pikachuhat:
        j       0x800F1F40                  // modified original line 1 part 2
        addiu   at, r0, 0x000A              // replacing what at would normally be   

        j       _return                     // return
        nop                                 // replacing what at would normally be
    }
    
    // character ID check add for when Pikachu and Jigglypuff Clones wear hats.
    scope pokemon_hat_fix_2: {
        OS.patch_start(0x6D8E0, 0x800F20E0)
        j       pokemon_hat_fix_2                      
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()
        
        addiu   at, r0, Character.id.JIGGLYPUFF     // PUFF ID
        beq     t9, at, _puffhat                    // PUFF Jump - original line 1 replacement
        addiu   at, r0, Character.id.EPUFF          // EPUFF ID
        beq     t9, at, _puffhat                    // EPUFF Jump
        addiu   at, r0, Character.id.JPUFF          // JPUFF ID
        beq     t9, at, _puffhat                    // JPUFF Jump
        nop 
        
        j       _return                     // return
        addiu   at, r0, 0x0009              // replacing what at would normally be
        
        _puffhat:
        j       0x800F20F0                  // modified original line 1 part 2
        addiu   at, r0, 0x0009              // replacing what at would normally be   

        j       _return                     // return
        nop                                 // replacing what at would normally be
    }
    
    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale: {
        OS.patch_start(0xB165C, 0x80136C1C)
        j       kirby_cpu_inhale                      
        nop
        _return:
        OS.patch_end()
        
        beq     v1, at, _end
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, at, _end
        nop
        j       0x80136C2C                  // modified line 1
        or      v0, v1, r0                  // original line 2   
        
        _end:
        j       _return
        or      v0, v1, r0                  // original line 2  
    }
    
    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_2: {
        OS.patch_start(0xB3948, 0x80138F08)
        j       kirby_cpu_inhale_2                      
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _end
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _end
        nop   
        j       0x80138F18                  // modified line 1
        or      v1, v0, r0                  // original line 2
        
        _end:
        j       _return
        or      v1, v0, r0                  // original line 2
    }
    
    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_3: {
        OS.patch_start(0xB1B30, 0x801370F0)
        j       kirby_cpu_inhale_3                      
        nop
        _return:
        OS.patch_end()
        
        beq     at, a0, _kirby
        nop
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID 
        beq     at, a0, _kirby
        nop      
        
        _end:
        j       0x80137160                  // modified line 1
        addiu   at, r0, 0x000B              // original line 2
        
        _kirby:
        j       _return
        nop
    }
    
    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_4: {
        OS.patch_start(0x5DBE8, 0x800E23E8)
        j       kirby_cpu_inhale_4                      
        nop
        _return:
        OS.patch_end()
        
        beq     t0, at, _kirby
        nop
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID 
        beq     at, a0, _kirby
        nop      
        
        _end:
        j       0x800E23FC                  // modified line 1
        lw      v0, 0x09E8(s1)              // original line 2
        
        _kirby:
        j       _return
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when fully charged.
    scope fully_charged_check_: {
        OS.patch_start(0x66424, 0x800EAC24)
        jal     fully_charged_check_
        nop
        OS.patch_end()

        beq     v0, at, j_0x800EAC84        // original line 1, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v0, at, j_0x800EAC84        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        addiu   a3, sp, 0x003C              // original line 2

        j_0x800EAC84:
        j       0x800EAC84
        addiu   a3, sp, 0x003C              // original line 2
    }

    // @ Description
    // Extends a check on ID that occurs when a Kirby clone steals another Kirby clone's copied power.
    scope kirby_power_steal_check_: {
        OS.patch_start(0xDCB3C, 0x801620FC)
        jal     kirby_power_steal_check_
        sh      a0, 0x0B18(v0)              // original line 1
        OS.patch_end()

        beq     v1, at, j_0x80162110        // original line 2, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v1, at, j_0x80162110        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        nop

        j_0x80162110:
        j       0x80162110
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when a Kirby clone's copied power is stolen by another Kirby clone.
    scope kirby_power_stolen_check_: {
        OS.patch_start(0xC6A4C, 0x8014C00C)
        jal     kirby_power_stolen_check_
        addiu   at, r0, 0x0008              // original line 1 (at = Character.id.KIRBY)
        OS.patch_end()

        beq     v0, at, j_0x8014C020        // original line 2, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v0, at, j_0x8014C020        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        nop

        j_0x8014C020:
        j       0x8014C020
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when Kirby absorbs or ejects a power.
    scope kirby_power_change_: {
        OS.patch_start(0xDC914, 0x80161ED4)
        j       kirby_power_change_
        nop
        _kirby_power_change_return:
        OS.patch_end()

        beq     v0, at, j_0x80161F04        // original line 1, modified to use jump
        lli     at, Character.id.JPUFF      // at = JPUFF
        beq     v0, at, j_0x80161F04        // if JPUFF, take Jigglypuff branch
        lli     at, Character.id.EPUFF      // at = EPUFF
        beq     v0, at, j_0x80161F04        // if EPUFF, take Jigglypuff branch
        nop

        j       _kirby_power_change_return
        nop

        j_0x80161F04:
        j       0x80161F04
        sw      r0, 0x0AF0(a0)              // original line 2
    }
    
    OS.align(16)
    upspecial_struct_jkirby:
    dw 0x03000000
    dw 0x00000004
    dw Character.JKIRBY_file_1_ptr
    OS.copy_segment(0x103CEC, 0x40)
    
    // kirby shares hardcodings with various characters, check the other files to ensure updated
    
    }
