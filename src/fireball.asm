// fireball.asm

// This file allows for copies of Mario's fireball projectile to be generated.

include "OS.asm"
include "Global.asm"

scope Fireball: {
    constant FIREBALL_BASE(0x80188E30)    
    
    // @ Description
    // Macro to set up a struct for a cloned fireball
    macro struct(name, defaults, duration, max_speed, min_speed, gravity, bounce, rotation, angle_g, angle_a, init_speed, data_pointer, palette_idx) {
        // align
        while ((pc() - FIREBALL_BASE) % 0x30) {
            db 0x00                         
        }
        // constants
        constant {name}(pc())
        constant {name}_id((pc() - FIREBALL_BASE) / 0x30)
        if {defaults} > 0 {
            constant {name}_default_settings({defaults})
        }
        // struct
        dw      {duration}                  // 0x0000 - duration (int)
        float32 {max_speed}                 // 0x0004 - max speed    
        float32 {min_speed}                 // 0x0008 - min speed
        float32 {gravity}                   // 0x000C - gravity
        float32 {bounce}                    // 0x0010 - bounce multiplier
        float32 {rotation}                  // 0x0014 - rotation speed
        float32 {angle_g}                   // 0x0018 - initial angle (ground)
        float32 {angle_a}                   // 0x001C   initial angle (air)
        float32 {init_speed}                // 0x0020   initial speed
        dw      {data_pointer}              // 0x0024   projectile data pointer
        dw      0                           // 0x0028   unknown (default 0)
        float32 {palette_idx}               // 0x002C   palette index (0 = mario, 1 = luigi)
    }
    
    // @ Description
    // Updates the Fireball to use new GFX/SFX on hit when different damage types are used.
    scope hit_effect_: {
        // v1 = projectile struct
        // t7 = damage
        pushvar origin, base
        origin  0xE310C
        base    0x801686CC
        j       hit_effect_
        nop
        _hit_effect_return:
        origin  0xE3124
        base    0x801686E4
        _hit_effect_branch:
        pullvar base, origin
        
        OS.save_registers()
        lw      t0, 0x010C (v1)             // t0 = projectile type
        ori     t1, r0, Capsule.TYPE        // t1 = Capsule.TYPE
        beq     t0, t1, _capsule            // branch if type = Capsule.TYPE
        nop
        
        _fireball:
        jal     0x800269C0                  // play fgm (original line 1)
        or      a0, r0, r0                  // a0 = explosion FGM (original line 2)
        li      ra, _hit_effect_return      // load return address (default)
        sw      ra, 0x006C(sp)              // update ra and save to stack
        b       _end
        nop
        
        _capsule:
        jal     0x800269C0                  // play fgm
        ori     a0, r0, Capsule.FGM         // a0 = Capsule.FGM
        lw      t6, 0x0088(sp)              // ~
        lw      a0, 0x0074(t6)              // ~
        addiu   a0, a0, 0x001C              // modified original logic
        lw      t7, 0x003C(sp)              // t7 = damage
        or      a1, r0, r0                  // a1 = 0
        or      a2, t7, r0                  // a2 = damage           
        jal     0x800FDC04                  // create "normal hit" gfx
        or      a3, r0, r0                  // a3 = 0
        li      ra, _hit_effect_branch      // load return address (branch)
        sw      ra, 0x006C(sp)              // update ra and save to stack
        
        _end:
        OS.restore_registers()
        jr      ra                      // return
        nop
    }
    
    // @ Description
    // Updates the Fireball to use new GFX upon bouncing when different damage types are used.
    scope bounce_effect_: {
        pushvar origin, base
        origin  0xE30E0
        base    0x801686A0
        j       bounce_effect_
        addiu   a0, a0, 0x001C
        _bounce_effect_return:
        pullvar base, origin
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x010C (v0)             // t0 = projectile type
        ori     t1, r0, Capsule.TYPE        // t1 = Capsule.TYPE
        beq     t0, t1, _capsule            // branch if type = Capsule.TYPE
        nop
        
        _fireball:
        jal     0x80102DEC                  // create "fire dust" gfx (original line 1)
        nop
        b       _end
        nop
        
        _capsule:
        jal     0x800FF048                  // create "small smoke" gfx
        nop
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // allocate stack space
        j       _bounce_effect_return       // return
        nop
    }
    
    // @ Description
    // Setup for Dr. Mario's capsule.
    scope Capsule {
        constant FIREBALL_SUBROUTINE(0x80155E64)
        constant TYPE(0x4)                  // damage type to use for capsule effects
        constant FGM(0x1B5)                 // fgm to play when capsule hits an opponent
        constant DOC_ID(0x00)               // character id being used for Dr. Mario

        
        // @ Description
        // Subroutine which randomizes the palette index used by Dr. Mario's capsule when the
        // projectile is created.
        // Uses the moveset command 540000XX (orignally identified as "create prop" by toomai)
        // This command sets the value of temp variable 1, which is used to determine when
        // Mario's fireball should be created.
        scope capsule_subroutine_: {
            // v0 = player struct
            // 0x17C in player struct = temp variable 1
            addiu   sp, sp,-0x0010          // allocate stack space
            swc1    f0, 0x0004(sp)          // ~
            sw      ra, 0x0008(sp)          // store f0, ra
            OS.save_registers()
            lw      v0, 0x0084(a0)          // v0 = player struct
            lw      t0, 0x017C(v0)          // t0 = temp variable 1
            beq     t0, r0, _end            // end if temp variable 1 = 0
            nop
            li      t1, struct_capsule      // t1 = struct_capsule
            ori     a0, r0, 0x2             // ~
            jal     Global.get_random_int_  // v0 = (0-1)
            nop
            mtc1    v0, f0                  // ~
            cvt.s.w f0, f0                  // f0 = random palette index (0-1)
            swc1    f0, 0x002C(t1)          // store palette index
            
            _end:
            OS.restore_registers()
            jal     FIREBALL_SUBROUTINE     // original fireball subroutine
            nop
            lwc1    f0, 0x0004(sp)          // ~
            lw      ra, 0x0008(sp)          // load f0, ra
            addiu   sp, sp, 0x0010          // deallocate stack space 
            jr      ra                      // return
            nop
        }
        
        // @ Description
        // Subroutine which loads the struct id for Dr Mario's capsule.
        scope load_capsule_id_: {
            li      a0, struct_capsule_id   // a0 = capsule struct id
            sw      a0, 0x001C(sp)          // store struct id
            j       0x80155EE4              // return
            nop
        }
        
        // @ Description
        // Loads the capsule subroutine when Dr. Mario uses neutral special.
        scope load_capsule_subroutine_: {
            // v0 = player struct
            pushvar origin, base
            origin  0xD0A40
            base    0x80156000
            j       load_capsule_subroutine_
            nop
            _load_capsule_subroutine_return:
            pullvar base, origin
            
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      t0, 0x0004(sp)          // ~
            sw      t1, 0x0008(sp)          // store t0, t1

            li      t6, FIREBALL_SUBROUTINE // t6 = FIREBALL_SUBROUTINE (original lines 1&2)
            ori     t0, r0, DOC_ID          // t0 = DOC_ID
            lbu     t1, 0x000B(v0)          // t1 = current char id
            bne     t0, t1, _end            // skip if char id != DOC_ID
            nop
            li      t6, capsule_subroutine_ // t6 = capsule subroutine
            
            _end:
            lw      t0, 0x0004(sp)          // ~
            lw      t1, 0x0008(sp)          // load t0, t1
            addiu   sp, sp, 0x0010          // deallocate stack space
            j       _load_capsule_subroutine_return
            nop
        }    
            
        // Initialize capsule struct
        struct(struct_capsule, 0, 140, 60, 25, 1.5, 0.95, 0.3, -0.4, -0.4, 40, CAPSULE_DATA_POINTER, 0) 
        
        // Define CAPSULE_DATA_POINTER
        CAPSULE_DATA_POINTER:
        dw      data                        //CAPSULE_DATA_FILE pointer (TEMPORARY while reqlist issue is unsolved)
        
        // TEMPORARY: INSERT CAPSULE FILES WHILE REQLIST ISSUE IS UNRESOLVED
        insert data, "capsule/086F.bin"
        insert graphic, "capsule/0870.bin"

        // write changes to rom
        //constant CAPSULE_DATA_FILE(0x86F)
        //constant CAPSULE_GRAPHIC_FILE(0x870)
        
        pushvar origin, base
        // add CAPSULE_DATA_FILE and CAPSULE_DATA_POINTER to Mario's character struct (TEMPORARY)
        // NOTE: CAPSULE_DATA_FILE has also been temporarily added to Mario's req list.
        // EDIT: REMOVED WHILE REQLIST ISSUE IS UNRESOLVED
        //origin  0x93030
        //dw      CAPSULE_DATA_FILE           // check for this file when mario is loaded
        //origin  0x93058
        //dw      CAPSULE_DATA_POINTER        // write CAPSULE_DATA_FILE pointer to this address
        
        // change id subroutine for Mario
        origin  0x107070
        dw      load_capsule_id_
        
        pullvar base, origin
    }
}