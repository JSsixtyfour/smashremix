// Pikashared.asm

// This file contains shared functions by Pika Clones.

scope PikaShared {

// character ID check add for when Pika Clones perform rapid jab
    scope rapid_jab_fix_1: {
        OS.patch_start(0xC93B4, 0x8014E974)
        j       rapid_jab_fix_1
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _rapid_jump             // modified original line 1
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v0, at, _rapid_jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v0, at, _rapid_jump
        nop
        j       _return                         // return
        addiu   at, r0, 0x0017                  // original line 2
        
        _rapid_jump:
        j       0x8014E984
        addiu   at, r0, 0x0017                  // original line 2
    }
    
    // character ID check add for when Pika Clones perform rapid jab
    scope rapid_jab_fix_2: {
        OS.patch_start(0xC921C, 0x8014E7DC)
        j       rapid_jab_fix_2
        nop
        _return:
        OS.patch_end()
        
        beq     v1, at, _rapid_jump_2             // modified original line 1
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v1, at, _rapid_jump_2
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v1, at, _rapid_jump_2
        nop
        j       _return                         // return
        addiu   at, r0, 0x0017                  // original line 2
        
        _rapid_jump_2:
        j       0x8014E7EC
        addiu   at, r0, 0x0017                  // original line 2
    }

// character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_1: {
        OS.patch_start(0xCA898, 0x8014FE58)
        j       forward_smash_fix_1
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _fsmash_jump          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump
        nop
        j       _return                     // return
        addiu   at, r0, 0x000B              // original line 2
        
        _fsmash_jump:
        j       0x8014FE80
        addiu   at, r0, 0x000B              // original line 2
    }
    
    // character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_2: {
        OS.patch_start(0xCABB0, 0x80150170)
        j       forward_smash_fix_2
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _fsmash_jump_2          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump_2
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump_2
        nop
        j       _return                     // return
        addiu   t0, t0, 0x9C8C              // original line 2
        
        _fsmash_jump_2:
        j       0x801501A0
        addiu   t0, t0, 0x9C8C              // original line 2
    }
    
    // character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_3: {
        OS.patch_start(0xCAB54, 0x80150114)
        j       forward_smash_fix_3
        nop
        _return:
        OS.patch_end()
        
        beq     v0, at, _fsmash_jump_3          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump_3
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump_3
        nop
        j       _return                     // return
        lui    a3, 0x3F80              // original line 2
        
        _fsmash_jump_3:
        j       0x80150140
        lui    a3, 0x3F80              // original line 2
    }
    
    // establishes a pointer to the character struct that can be used for a character id check during
    // pikachu's down special.
    scope get_thunder_playerstruct1_: {
        OS.patch_start(0xE00C4, 0x80165684)
        j       get_thunder_playerstruct1_
        nop
        _return:
        OS.patch_end()
        
        lw      t2, 0x00DC(sp)              // load playerstruct into t2 for thunder
        sw      t2, 0x007C(s0)              // save playerstruct into projectile struct for thunder
        
        lw      t2, 0x0020(sp)              // load playerstruct into t2 for thunder jolt
        sw      t2, 0x0078(s0)              // save playerstruct into projectile struct for thunder jolt
        
        lw      t2, 0x0080(sp)              // original line 1
              
        j       _return                     // return
        lw      v0, 0x0084(t2)              // original line 2    
    }
    
    // establishes a pointer to the character struct that can be used for a character id check during
    // pikachu's down special.
    scope get_thunder_playerstruct2_: {
        OS.patch_start(0xE015C, 0x8016571C)
        j       get_thunder_playerstruct2_
        lw      v0, 0x0084(t0)              // original line 1
        _return:
        OS.patch_end()
        
        lw      t1, 0x007C(v0)              // load from parent struct for thunder
        sw      t1, 0x007C(s0)              // save to projectile struct 2 for thunder
        
        lw      t1, 0x0078(v0)              // load from parent struct for thunderjolt
        sw      t1, 0x0078(s0)              // save to projectile struct 2 for thunderjolt
              
        j       _return                     // return
        lw      t1, 0x0008(v0)              // original line 2    
    }
    
    // loads in anim struct for Pika Clones for Thunder
    scope get_thunder_anim_struct_: {
        OS.patch_start(0x7D3A0, 0x80101BA0)
        j       get_thunder_anim_struct_
        nop                                
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      t1, 0x0094(sp)              // load from projectile struct from stack
        lw      t1, 0x007C(t1)              // load player struct from projectile struct
        lw      t1, 0x0008(t1)              // load character ID from player struct      
        
        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a0, thunder_anim_struct     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a0, thunder_anim_struct_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a0, 0x8013                  
        addiu   a0, a0, 0xE224              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        jal     0x800FDAFC                  // original line 1
        nop
        
        j       _return                     // return
        nop
    }
    
    // loads in anim struct for Pika Clones for Thunder Jolt
    scope get_thunder_jolt_anim_struct_: {
        OS.patch_start(0x7D448, 0x80101C48)
        j       get_thunder_jolt_anim_struct_
        nop                                
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      a0, 0x0078(s0)              // load from projectile struct from stack
        lw      t1, 0x0008(a0)              // load character ID from player struct
        
        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(a0)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(a0)              // t1 = character id of copied power

        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a0, thunder_jolt_anim_struct_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a0, 0x8013                  
        addiu   a0, a0, 0xE24C              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        jal     0x800FDAFC                  // original line 1
        nop
        
        j       _return                     // return
        nop
    }
    
    // loads in special struct for pika clones for thunder jolt
    scope get_thunder_jolt_special_struct_1: {
        OS.patch_start(0xE4038, 0x801695F8)
        j       get_thunder_jolt_special_struct_1
        nop                                 
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      t1, 0x0008(s1)              // load character ID from player struct      
        
        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power

        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_jolt_special_struct_1_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a1, 0x8019                  // original line 1       
        addiu   a1, a1, 0x90B0              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
             
        j       _return                     // return
        nop
    }
    
    // loads in special struct for pika clones for thunder jolt
    scope get_thunder_jolt_special_struct_2: {
        OS.patch_start(0xE4E94, 0x8016A454)
        j       get_thunder_jolt_special_struct_2
        ori     a3, a3, 0x0002              // original line 1                       
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      a1, 0x0078(s1)              // load player struct from projectile struct
        lw      t1, 0x0008(a1)              // load character ID from player struct

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(a1)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(a1)              // t1 = character id of copied power
        
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_jolt_special_struct_2_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a1, 0x8019                  //      
        addiu   a1, a1, 0x90E4              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
             
        j       _return                     // return
        nop
    }
    
    // loads in special struct for pika clones for thunder
    scope get_thunder_special_struct_1: {
        OS.patch_start(0xE5260, 0x8016A820)
        j       get_thunder_special_struct_1
        nop                                 
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      t1, 0x006C(sp)              // load player struct from stack
        lw      t1, 0x0008(t1)              // load character ID from player struct      
        
        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a1, thunder_special_struct_1     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_special_struct_1_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a1, 0x8019                  // original line 1       
        addiu   a1, a1, 0x9120              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
             
        j       _return                     // return
        nop
    }
    
     // loads in special struct for pika clones for thunder
    scope get_thunder_special_struct_2: {
        OS.patch_start(0xE53D0, 0x8016A990)
        j       get_thunder_special_struct_2
        nop                                 
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        
        lw      t1, 0x007C(t0)              // load player struct from projectile struct
        lw      t1, 0x0008(t1)              // load character ID from player struct      
        
        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a1, thunder_special_struct_2     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_special_struct_2_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop
        
        lui     a1, 0x8019                  // original line 1       
        addiu   a1, a1, 0x9154              // original line 2
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        j       _return                     // return
        nop
    }
    
    // EPIKA
    
    OS.align(16)
    thunder_anim_struct:
    dw  0x020F0000
    dw  Character.EPIKA_file_4_ptr
    OS.copy_segment(0xA9A2C, 0x20)
    
    OS.align(16)
    thunder_special_struct_1:
    dw 0x02000000
    dw 0x0000000B
    dw Character.EPIKA_file_1_ptr
    OS.copy_segment(0x103B6C, 0x40)
    
    OS.align(16)
    thunder_special_struct_2:
    dw 0x02000000
    dw 0x0000000C
    dw Character.EPIKA_file_1_ptr
    OS.copy_segment(0x103BA0, 0x40)
    
    // JPIKA
    
    OS.align(16)
    thunder_anim_struct_jpika:
    dw  0x020F0000
    dw  Character.JPIKA_file_4_ptr
    OS.copy_segment(0xA9A2C, 0x20)
    
    OS.align(16)
    thunder_special_struct_1_jpika:
    dw 0x02000000
    dw 0x0000000B
    dw Character.JPIKA_file_1_ptr
    OS.copy_segment(0x103B6C, 0x40)
    
    OS.align(16)
    thunder_special_struct_2_jpika:
    dw 0x02000000
    dw 0x0000000C
    dw Character.JPIKA_file_1_ptr
    OS.copy_segment(0x103BA0, 0x40)
    
    OS.align(16)
    thunder_jolt_anim_struct_jpika:
    dw  0x040F0000
    dw  Character.JPIKA_file_8_ptr
    OS.copy_segment(0xA9A54, 0x20)
    
    OS.align(16)
    thunder_jolt_special_struct_1_jpika:
    dw 0x00000000
    dw 0x00000009
    dw Character.JPIKA_file_6_ptr
    OS.copy_segment(0x103AFC, 0x40)
    
    OS.align(16)
    thunder_jolt_special_struct_2_jpika:
    dw 0x03000000
    dw 0x0000000A
    dw Character.JPIKA_file_6_ptr
    OS.copy_segment(0x103B30, 0x40)
    
    // Pikachu shares hardcodings with Jigglypuff and some of his hardcodings are in jigglypuffkirbyshared.asm
    
    }
