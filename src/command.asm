// Command.asm (Fray)

// This file adds support for new commands in the moveset microcode

include "OS.asm"

scope Command {
    constant HITBOX_STRUCT_BASE(0x294)
    constant HITBOX_STRUCT_SIZE(0xC4)

    // @ Description
    // function which executes a custom moveset command (0xD0-0xFF) 
    // commands 0xD0-0xFF are usually unsupported, which means they can be used as custom commands
    scope load_command_: {
        // s2 = player struct
        // v0 = current commmand offset
        // 0x86C = current command in struct
        OS.save_registers()                 // full register save
        lbu     a3, 0x0000(v0)              // a3 = command byte
        addiu   t0, a3, -0x00D0             // ~
        bltz    t0, _skip                   // skip if command < 0xD0
        nop
        
        _load:
        sll     t1, t0, 0x2                 // t1 = offset ((command - 0xD0) * 4))
        li      t2, command_table           // t2 = command_table
        addu    t1, t1, t2                  // t1 = command_table + offset
        lw      t1, 0x0000(t1)              // t1 = command asm address
        beq     t1, r0, _end                // skip if t1 = NULL
        ori     t8, r0, 0x0004              // next command = 0x0004
        jalr    t1                          // jump to custom command
        nop
        
        _end:
        // t8 = next command offset/current command length
        // v0 = current command
        lw      v0, 0x0008(sp)              // ~
        lw      s0, 0x0048(sp)              // load v0, s0
        addu    v0, v0, t8                  // v0 = next command
        sw      v0, 0x0004(s0)              // store next command in player struct
        sw      v0, 0x0008(sp)              // store next command in stack
        
        _skip:
        OS.restore_registers()              // full register load
        lw      a3, 0x0000(v0)              // original line 1
        srl     a3, a3, 0x1A                // original line 2
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // function which executes a custom moveset command (0xD0-0xFF), excludes certain commands
    // commands 0xD0-0xFF are usually unsupported, which means they can be used as custom commands
    scope load_command_2_: {
        // s2 = player struct
        // v0 = current commmand offset
        // 0x86C = current command in struct
        OS.save_registers()                 // full register save
        lbu     a3, 0x0000(v0)              // a3 = command byte
        addiu   t0, a3, -0x00D0             // ~
        bltz    t0, _skip                   // skip if command < 0xD0
        nop
        
        _load:
        sll     t1, t0, 0x2                 // t1 = offset ((command - 0xD0) * 4))
        li      t2, command_table_2         // t2 = command_table
        addu    t1, t1, t2                  // t1 = command_table + offset
        lw      t1, 0x0000(t1)              // t1 = command asm address
        beq     t1, r0, _end                // skip if t1 = NULL
        ori     t8, r0, 0x0004              // next command = 0x0004
        jalr    t1                          // jump to custom command
        nop
        
        _end:
        // t8 = next command offset/current command length
        // v0 = current command
        lw      v0, 0x0008(sp)              // ~
        lw      s0, 0x0048(sp)              // load v0, s0
        addu    v0, v0, t8                  // v0 = next command
        sw      v0, 0x0004(s0)              // store next command in player struct
        sw      v0, 0x0008(sp)              // store next command in stack
        
        _skip:
        OS.restore_registers()              // full register load
        lw      a3, 0x0000(v0)              // original line 1
        srl     a3, a3, 0x1A                // original line 2
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // General purpose. Runs when a character changes actions.
    scope change_action_: {
        sw  s1, 0x0018(sp)                  // original line 1
        sw  s0, 0x0014(sp)                  // original line 2
        OS.save_registers()                 // full register save
        
        scope _reset_translation_multiplier: {
            lw      a0, 0x0010(sp)          // ~
            lw      t3, 0x0084(a0)          // t3 = player struct      
            li      t0, translation_multiplier_.multiplier_table
            lbu     t1, 0x000D(t3)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            lui     t2, 0x3F80              // t2 = 1.0
            sw      t2, 0x0000(t0)          // reset translation multiplier to 1.0
        }
        
        scope _reset_env_color: {            
            li      t0, CharEnvColor.moveset_table
            lw      t3, 0x0084(a0)          // t3 = player struct 
            lbu     t1, 0x000D(t3)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = offset to env color override value
            addu    t0, t0, t1              // t0 = address of env color override value
            sw      r0, 0x0000(t0)          // reset env color override
        }
        
        scope _reset_training_action_frame_count: {
            li      t0, Global.current_screen
            lbu     t0, 0x0000(t0)          // t0 = screen_id
            ori     t1, r0, 0x0036          // t1 = training mode screen id
            bne     t0, t1, _end            // skip if screen_id != training mode
            nop
            li      t0, Training.action_control_object
            lw      t0, 0x0000(t0)          // t0 = action control object
            beqz    t0, _end                // skip if no control object (first frame)
            lw      t3, 0x0084(a0)          // t3 = player struct
            lbu     t1, 0x000D(t3)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = offset
            addu    t0, t0, t1              // t0 = action control object, offset for port
            sw      r0, 0x0030(t0)          // clear previous action, which will trigger a frame count reset

            _end:
        }

        scope _respawn_with_item: {
            jal     Item.respawn_with_item_
            nop
        }

        OS.restore_registers()              // full register load
        j   _change_action_return           // return
        nop
    }

    // @ Description
    // patch which expands the existing end hitbox function to include resetting the directional override and FGM override
    scope end_hitbox_: {
        OS.patch_start(0x63D2C, 0x800E852C)
        j       end_hitbox_
        nop
        _return:
        OS.patch_end()
    
        // v0 = player struct
        addiu   sp, sp,-0x0010          // allocate stack space
        sw      t0, 0x0004(sp)          // store t0
        sw      t1, 0x0008(sp)          // store t1

        li      t0, hitbox_direction_.apply_direction_.hitbox_dir_table
        lbu     t1, 0x000D(v0)          // t1 = player port
        sll     t1, t1, 0x2             // ~
        addu    t0, t0, t1              // t0 = hitbox_dir_table + (port * 4))
        lw      t0, 0x0000(t0)          // t0 = px_hitbox_dir
        sw      r0, 0x0000(t0)          // ~
        sw      r0, 0x0004(t0)          // ~
        sw      r0, 0x0008(t0)          // ~
        sw      r0, 0x000C(t0)          // disable directional override for all hitboxes

        li      t0, set_hitbox_fgm_.apply_fgm_.hitbox_fgm_table
        addu    t0, t0, t1              // t0 = hitbox_fgm_table + (port * 4))
        lw      t0, 0x0000(t0)          // t0 = px_hitbox_fgm
        addiu   t1, r0, -0x0001         // t1 = -1 (0xFFFFFFFF)
        sw      t1, 0x0000(t0)          // disable fgm override for hitboxes 1 and 2
        sw      t1, 0x0004(t0)          // disable fgm override for hitboxes 3 and 4

        lw      t0, 0x0004(sp)          // ~
        lw      t1, 0x0008(sp)          // load t0, t1
        sw      r0, 0x04E0(v0)          // original line 1 (disable hitbox 4)
        sw      r0, 0x0294(v0)          // original line 2 (disable hitbox 1)
        addiu   sp, sp, 0x0010          // deallocate stack space
        j       _return                 // return
        nop
    }
    
    // @ Description
    // patch which expands the existing create hitbox function to include resetting the directional override and FGM override
    scope create_hitbox_: {
        OS.patch_start(0x5A9F0, 0x800DF1F0)
        j       create_hitbox_
        nop
        _return:
        OS.patch_end()
        
        // s1 = player struct
        // a1 = hitbox id
        addiu   sp, sp,-0x0010          // allocate stack space
        sw      t0, 0x0004(sp)          // store t0
        sw      t1, 0x0008(sp)          // store t1
        li      t0, hitbox_direction_.apply_direction_.hitbox_dir_table
        lbu     t1, 0x000D(s1)          // t1 = player port
        sll     t1, t1, 0x2             // ~
        addu    t0, t0, t1              // t0 = hitbox_dir_table + (port * 4))
        lw      t0, 0x0000(t0)          // t0 = px_hitbox_dir
        sll     t1, a1, 0x2             // ~
        addu    t0, t0, t1              // t0 = px_hitbox_dir + (hitbox id * 4)
        sw      r0, 0x0000(t0)          // reset directional override for current hitbox
        
        li      t0, set_hitbox_fgm_.apply_fgm_.hitbox_fgm_table
        lbu     t1, 0x000D(s1)          // t1 = player port
        sll     t1, t1, 0x2             // ~
        addu    t0, t0, t1              // t0 = hitbox_fgm_table + (port * 4))
        lw      t0, 0x0000(t0)          // t0 = px_hitbox_fgm
        sll     t1, a1, 0x1             // ~
        addu    t0, t0, t1              // t0 = px_hitbox_fgm + (hitbox id * 2)
        addiu   t1, r0, -0x0001         // t1 = -1 (0xFFFFFFFF)
        sh      t1, 0x0000(t0)          // reset FGM override for current hitbox
        
        lw      t0, 0x0004(sp)          // ~
        lw      t1, 0x0008(sp)          // load t0, t1
        addiu   sp, sp, 0x0010          // deallocate stack space
        multu   a1, t3                  // original line 1
        mflo    t6                      // original line 2
        j       _return                 // return
        nop
    }
    
    // @ Description
    // patch which causes the "Set Texture Form" command to not take effect for Metal Mario
    scope texture_form_fix_: {
        OS.patch_start(0x64E2C, 0x800E962C)
        j       texture_form_fix_
        nop
        _texture_form_fix_return:
        OS.patch_end()
        
        lw      v0, 0x0084(a0)              // original line 1 (v0 = player struct)
        sll     t8, a1, 0x2                 // original line 2
        lw      t6, 0x0008(v0)              // t6 = character id
        ori     t9, r0, Character.id.METAL  // t9 = id.METAL
        beq     t6, t9, _metal              // branch if id = METAL
        nop
        j       _texture_form_fix_return    // return normally
        nop
        
        _metal:
        jr      ra                          // end subroutine early
        nop
    }
    
    // CUSTOM COMMANDS
    // s2 = player struct
    // v0 = command offset
    // T8 MUST BE SET TO COMMAND LENGTH BEFORE RETURNING
    
    // @ Description
    // sets the frame speed multiplier to a given value
    // supports setting/not setting the command execution speed separately
    // CCYYXXXX
    // CC = command byte
    // YY = moveset data execution speed flag
    // XXXX0000 = fsm value 
    // 0x00 = set execution speed, 0x01 = don't set execution speed
    scope fsm_: {
        constant COMMAND_LENGTH(0x4)
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      ra, 0x0004(sp)              // store ra
        lbu     t0, 0x0001(v0)              // t0 = execution speed flag
        beq     t0, r0, _apply              // apply fsm normally if flag = 0
        lw      a0, 0x0004(s2)              // a0 = secondary player struct
        
        // The fsm function usually loads the bone struct head at 0x0074(a0). This is the only use
        // of a0 in the fsm function, so it's safe to skip writing to the first bone struct(which
        // contains the frame speed multiplier for moveset command execution speed) by replacing a0
        lw      t0, 0x0074(a0)              // t0 = first bone struct
        addiu   a0, t0,-0x0064              // 0x0074(a0) = pointer to second bone struct
        // The change action function determines whether the FSM should be reset by checking if
        // the frame speed multiplier in the first bone struct is not equal to 0x3F800000 (1.0)
        // Therefore, if this command is called with set execution speed disabled and the FSM
        // in the first bone struct = 1.0, it will be adjusted to 0x3F800001 so that the FSM
        // will be correctly returned to normal when the action ends.
        lw      t1, 0x0078(t0)              // t1 = execution frame speed multiplier
        li      t2, 0x3F800000              // t2 = 1.0
        bne     t1, t2, _apply              // skip if execution fsm != 1.0
        nop
        addiu   t1, t2, 0x0001              // ~
        sw      t1, 0x0078(t0)              // store updated execution speed fsm (0x3F800001)
        
        _apply:
        lhu     a1, 0x0002(v0)              // load fsm parameter value
        jal     0x8000BB04                  // fsm subroutine
        sll     a1, a1, 0x0010              // shift fsm value 2 bytes left 
        lw      ra, 0x0004(sp)              // load ra   
        addiu   sp, sp, 0x0008              // deallocate stack space
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop
    }    
    
    // @ Description
    // sets the character's armour value to a given value
    // armour is a floating point value which is subtracted from the knockback value on hit
    // CC00XXXX
    // XXXX0000 = armour value
    scope armour_: {
        constant COMMAND_LENGTH(0x4)
        lhu     t0, 0x0002(v0)              // t0 = armour parameter value
        sll     t0, t0, 0x0010              // shift armour value 2 bytes left
        sw      t0, 0x07E8(s2)              // store armour value
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // sets the character's aerial y velocity to a given value
    // CC00XXXX
    // XXXX0000 = y velocity value
    scope y_velocity_: {
        constant COMMAND_LENGTH(0x4)
        lhu     t0, 0x0002(v0)              // t0 = y velocity parameter value
        sll     t0, t0, 0x0010              // shift y velocity  value 2 bytes left
        sw      t0, 0x004C(s2)              // store y velocity  value
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // enables/disables fast fall flag
    // CC0000XX
    // 0x00 = no fast fall
    // 0x01 = fast fall
    scope fast_fall_: {
        constant COMMAND_LENGTH(0x4)
        lbu     t0, 0x0003(v0)              // t0 = parameter value
        bnez    t0, _ff                     // if !0, enable fast fall flag
        lbu     t0, 0x018D(s2)              // t0 = bit field (first bit is fast fall flag)
        _no_ff:
        andi    t1, t0, 0x0007              // t1 = bit field & 0111 (disable flag)
        b       _end                        // end
        sb      t1, 0x018D(s2)              // disable fast fall flag
        _ff:
        ori     t1, t0, 0x0008              // t1 = bit field | 1000 (enable flag)
        sb      t1, 0x018D(s2)              // enable fast fall flag
        _end:
        jr      ra                          // return
        ori     t8, r0, COMMAND_LENGTH      // set command length
    }
    
    // @ Description
    // Plays a random FGM from an array of halfwords containing FGM ids, where 0xFFFF = no sound
    // CCXXYYZZ
    // AAAAAAAA
    // XX = chance of sound being played (/100)
    // YY = sfx type (0x00 = sfx, 0x01 = voice fx)
    // ZZ = array size
    // AAAAAAAA = array pointer
    scope play_sfx_random_: {
        constant SFX(0x0)
        constant VFX(0x1)
        constant COMMAND_LENGTH(0x8)
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra
        sw      v0, 0x000C(sp)              // store v0
        
        // first, determine whether or not to play an fgm
        jal     Global.get_random_int_      // v0 = (0, 99)
        lli     a0, 0100                    // ~
        move    t0, v0                      // t0 = (0, 99)
        lw      v0, 0x000C(sp)              // v0 = command address
        lbu     t1, 0x0001(v0)              // t1 = chance_fgm
        sltu    t0, t0, t1                  // if t0 > t1...
        beqz    t0, _end                    // ...then skip
        nop
        
        // next, get the FGM id from the array
        jal     Global.get_random_int_      // v0 = (0, array_size - 1)
        lbu     a0, 0x0003(v0)              // a0 = array_size
        sll     t0, v0, 0x1                 // t0 = offset (return * 0x2)
        lw      v0, 0x000C(sp)              // v0 = command address
        lw      t1, 0x0004(v0)              // t1 = array pointer
        addu    t1, t1, t0                  // t1 = array pointer + offset
        lhu     t7, 0x0000(t1)              // t7 = FGM id
        
        // determine what sfx type to use.
        lbu     t0, 0x0002(v0)              // t0 = sfx type
        lli     t1, VFX                     // t1 = VFX
        beq     t0, t1, _voice_fx           // branch if type = VFX
        nop
        
        _default_sfx:
        jal     0x800269C0                  // play FGM
        or      a0, r0, t7                  // a0 = FGM id
        b       _end                        // nop
        nop
        
        _voice_fx:
        or      a0, r0, s2                  // a0 = player struct
        jal     0x800E80F0                  // play voice fx
        or      a1, r0, t7                  // a1 = FGM id
        
        _end:
        lw      ra, 0x0008(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        ori     t8, r0, COMMAND_LENGTH      // set command length
    }
    
    // @ Description
    // sets the character's kinetic (aerial/grounded) state
    // CC0000XX
    // 0x00 = on ground
    // 0x01 = in air
    scope set_kinetic_: {
        constant COMMAND_LENGTH(0x4)
        lbu     t0, 0x0003(v0)              // t0 = parameter value
        bnez    t0, _aerial                 // if !0, set kinetic state to aerial
        nop
        _grounded:
        sb      r0, 0x0148(s2)              // set jump value to 0
        sw      r0, 0x014C(s2)              // set kinetic state to 0(grounded)
        b       _end                        // end
        nop
        _aerial:
        ori     t0, r0, 0x0001              // t0 = 0x0001
        sb      t0, 0x0148(s2)              // set jump value to 1
        sw      t0, 0x014C(s2)              // set kinetic state to 1(aerial)
        _end:
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // reverses the character's facing direction
    // CC000000
    scope switch_direction_: {
        constant COMMAND_LENGTH(0x4)
        lw      t0, 0x0044(s2)              // t0 = DIRECTION
        addiu   t1, r0,-0x0002              // t1 = bitmask (FFFFFFFE)
        // direction is stored as a signed 32 bit int, represented by either 1 or -1
        // so flipping all but the bottom bit will reverse the direction
        xor     t0, t0, t1                  // t1 = DIRECTION ^ FFFFFFFE
        sw      t0, 0x0044(s2)              // store updated direction
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // forces a hitbox to knock opponents in a fixed direction
    // CC00XXYY
    // CC = command byte
    // XX = hitbox id (0-3 = hitbox 1-4)
    // YY = direction
    // 0x00 = don't override
    // 0x01 = force forward (no reverse hit)
    // 0x02 = force backward (reverse hit only)   
    scope hitbox_direction_: {
        constant COMMAND_LENGTH(0x4)
        constant FORCE_FORWARD(0x1)
        constant FORCE_BACKWARD(0x2)
        li      t0, apply_direction_.hitbox_dir_table
        lbu     t1, 0x000D(s2)              // t1 = player port
        sll     t1, t1, 0x2                 // ~
        addu    t0, t0, t1                  // a0 = hitbox_dir_table + (port * 4))
        lw      t0, 0x0000(t0)              // t0 = px_hitbox_dir
        lbu     t1, 0x0003(v0)              // t1 = direction
        lbu     t2, 0x0002(v0)              // t2 = hitbox id
        sll     t2, t2, 0x2                 // ~
        addu    t0, t0, t2                  // t2 = hitbox_dir
        sw      t1, 0x0000(t0)              // store directional override
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop
    
        // @ Description
        // overrides the direction an opponent is launched when colliding with a hitbox if the
        // hitbox direction parameter is set
        scope apply_direction_: {
            // s0 = hitbox struct
            // s1 = attacking player struct
            // s5 = hit player struct
            // 0x0044(s1) = attacker direction
            // 0x07FC(s5) = hit direction
            li      at, hitbox_dir_table    // at = hitbox_dir_table
            lbu     a0, 0x000D(s1)          // a0 = player port
            sll     a0, a0, 0x2             // ~
            addu    at, at, a0              // at = hitbox_dir_table + (port * 4)
            lw      at, 0x0000(at)          // at = px_hitbox_dir
            
            _get_hitbox_id:
            subu    a0, s0, s1              // a0 = hitbox struct offset
            subiu   a0, a0, HITBOX_STRUCT_BASE// a0 = hitbox struct offset - HITBOX_STRUCT_BASE
            ori     t8, r0, HITBOX_STRUCT_SIZE// t8 = HITBOX_STRUCT_SIZE
            divu    a0, t8                  // ~
            mflo    a0                      // a0 = hitbox id
            // hitbox id = ((hitbox struct address - player struct address) - HITBOX_STRUCT_BASE) / HITBOX_STRUCT_SIZE
            
            _get_direction:
            sll     a0, a0, 0x2             // ~
            addu    at, at, a0              // at = px_hitbox_dir + (hitbox id * 4)
            lw      a0, 0x0000(at)          // a0 = hitbox direction
            beq     a0, r0, _end            // skip if hitbox direction = 0 (don't override)
            nop
            lw      at, 0x0044(s1)          // at = direction
            ori     t8, r0, FORCE_BACKWARD  // t8 = FORCE_BACKWARD
            beql    a0, t8, _end            // end and force reverse hit if hitbox direction = FORCE_BACKWARD
            sw      at, 0x07FC(s5)          // store direction (reverse hit)
            ori     t8, r0, FORCE_FORWARD   // t8 = FORCE_FORWARD
            bne     a0, t8, _end            // skip if hitbox direction != FORCE_FORWARD
            nop
            addiu   t8, r0,-0x0002          // t8 = bitmask (0xFFFFFFFE)
            xor     at, at, t8              // at = direction (flipped)
            sw      at, 0x07FC(s5)          // store direction (forward hit)
            
            _end:
            lw      t8, 0x0018(s2)          // original line 1
            addiu   at, r0, 0xFBFF          // original line 2
            j       _apply_direction_return // return
            nop
            
            hitbox_dir_table:
            dw p1_hitbox_dir
            dw p2_hitbox_dir
            dw p3_hitbox_dir
            dw p4_hitbox_dir
            
            p1_hitbox_dir:
            dw 0; dw 0; dw 0; dw 0          // hitbox 1/2/3/4
            p2_hitbox_dir:
            dw 0; dw 0; dw 0; dw 0          // hitbox 1/2/3/4
            p3_hitbox_dir:
            dw 0; dw 0; dw 0; dw 0          // hitbox 1/2/3/4
            p4_hitbox_dir:
            dw 0; dw 0; dw 0; dw 0          // hitbox 1/2/3/4
            
            pushvar origin, base 
            // apply_direction_ hook
            origin  0x5FC6C
            base    0x800E446C
            j       apply_direction_
            nop
            _apply_direction_return:
            pullvar base, origin
        }
    }
    
    // @ Description
    // Sets a multiplier for animations which use topjoint translation (dash attacks, rolls, etc.)
    // Traditionally, this value is fixed as the character's size multiplier, but with this command
    // it can be set to any value.
    // CC00XXXX
    // XXXX0000 = multiplier
    scope translation_multiplier_: {
		constant POISON_MULT(0x3fcc)
        constant SUPER_MULT(0x3f19)
        constant COMMAND_LENGTH(0x4)
        li      t2, multiplier_table        // t2 = multiplier_table
        lbu     t1, 0x000D(s2)              // t1 = player port
        sll     t1, t1, 0x2                 // ~
        addu    t2, t2, t1                  // t2 = multiplier_table + (port * 4)
        lhu     t0, 0x0002(v0)              // t0 = translation multiplier parameter value
        sll     t0, t0, 0x0010              // shift multiplier value 2 bytes left
        sw      t0, 0x0000(t2)              // store translation multiplier value
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop
        
        scope apply_ground_z_: {
            OS.patch_start(0x5442C, 0x800D8C2C)
            j       apply_ground_z_
            nop
            _return:
            OS.patch_end()
            
            // v0 = player struct
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      t0, 0x0014(sp)          // ~
            sw      t1, 0x0018(sp)          // store t0, t1
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(v0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f10, 0x0048(t6)         // f10 = bone size multiplier (original line 1)
            lwc1    f4, 0x0000(t0)          // f4 = translation multiplier
            mul.s   f10, f10, f4            // apply translation multiplier
            
			li      t0, Size.multiplier_table    // t0 = size.multiplier_table
            lbu     t1, 0x000D(v0)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = index = port * 4
            addu    t0, t0, t1              // t0 = &multiplier_table[index]
            lwc1    f16, 0x0000(t0)         // f16 = size multiplier (s)
            lui     t1, 0x3f80              // t1= 1
			mtc1    t1, f4					// move 1(fp) to f4 register
			c.eq.s	f4, f16					// if size multiplier is 1 (ie. normal)
			bc1t	_end					// then jump to end
			lui		t1, SUPER_MULT			// load giant size multiplier
			c.le.s	f16, f4					// if less than 1
			bc1t	_poison					// use poison multiplier
			mtc1    t1, f4					// move 0.6(fp) to f4 register
			
			beq		r0, r0, _end
			mul.s   f10, f4, f10            // apply super multiplier
			
			_poison:
			lui		t1, POISON_MULT			// load poison size multiplier
			mtc1    t1, f4					// move 1.8(fp) to f4 register
			mul.s   f10, f4, f10            // apply poison multiplier
			
			_end:		
			lwc1    f4, 0x0024(v1)          // original line 2
            lw      t0, 0x0014(sp)          // ~
            lw      t1, 0x0018(sp)          // load t0, t1
            addiu   sp, sp, 0x0020          // deallocate stack space
            j       _return
            nop
        }
        
        scope apply_ground_x_: {
            OS.patch_start(0x54468, 0x800D8C68)
            j       apply_ground_x_
            nop
            _return:
            OS.patch_end()
            
            // v0 = player struct
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      t0, 0x0014(sp)          // ~
            sw      t1, 0x0018(sp)          // store t0, t1
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(v0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f18, 0x0040(t8)         // f18 = bone size multiplier (original line 1)
            lwc1    f16, 0x0000(t0)         // f16 = translation multiplier
            mul.s   f18, f18, f16           // apply translation multiplier
            
			li      t0, Size.multiplier_table    // t0 = size.multiplier_table
            lbu     t1, 0x000D(v0)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = index = port * 4
            addu    t0, t0, t1              // t0 = &multiplier_table[index]
            lwc1    f16, 0x0000(t0)         // f16 = size multiplier (s)
            lui     t1, 0x3f80              // t1= 1
			mtc1    t1, f4					// move 1(fp) to f4 register
			c.eq.s	f4, f16					// if size multiplier is 1 (ie. normal)
			bc1t	_end					// then jump to end
			lui		t1, SUPER_MULT			// load giant size multiplier
			c.le.s	f16, f4					// if less than 1
			bc1t	_poison					// use poison multiplier
			mtc1    t1, f4					// move 0.6(fp) to f4 register
			
			beq		r0, r0, _end
			mul.s   f18, f4, f18            // apply super multiplier
			
			_poison:
			lui		t1, POISON_MULT			// load poison size multiplier
			mtc1    t1, f4					// move 1.8(fp) to f4 register
			mul.s   f18, f4, f18            // apply poison multiplier
			
			_end:
			mul.s   f16, f6, f10            // original line 2
            lw      t0, 0x0014(sp)          // ~
            lw      t1, 0x0018(sp)          // load t0, t1
            addiu   sp, sp, 0x0020          // deallocate stack space
            j       _return
            nop
        }
        
        scope apply_air_z_: {
            OS.patch_start(0x54A94, 0x800D9294)
            j       apply_air_z_
            nop
            _return:
            OS.patch_end()
            
            // a0 = player struct
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      t0, 0x0014(sp)          // ~
            sw      t1, 0x0018(sp)          // store t0, t1
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f4, 0x0048(v1)          // f4 = bone size multiplier (original line 1)
            lwc1    f18, 0x0000(t0)         // f18 = translation multiplier
            mul.s   f4, f4, f18             // apply translation multiplier
            
			li      t0, Size.multiplier_table    // t0 = size.multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = index = port * 4
            addu    t0, t0, t1              // t0 = &multiplier_table[index]
            lwc1    f6, 0x0000(t0)          // f6 = size multiplier (s)
            lui     t1, 0x3f80              // t1= 1
			mtc1    t1, f18					// move 1(fp) to f4 register
			c.eq.s	f18, f6					// if size multiplier is 1 (ie. normal)
			bc1t	_end					// then jump to end
			lui		t1, SUPER_MULT			// load giant size multiplier
			c.le.s	f6, f18					// if less than 1
			bc1t	_poison					// use poison multiplier
			mtc1    t1, f18					// move 0.6(fp) to f4 register
			
			beq		r0, r0, _end
			mul.s   f4, f4, f18             // apply super multiplier
			
			_poison:
			lui		t1, POISON_MULT			// load poison size multiplier
			mtc1    t1, f18					// move 1.8(fp) to f4 register
			mul.s   f4, f4, f18             // apply poison multiplier
			
			_end:
			mul.s   f18, f8, f16            // original line 2
            lw      t0, 0x0014(sp)          // ~
            lw      t1, 0x0018(sp)          // load t0, t1
            addiu   sp, sp, 0x0020          // deallocate stack space
            j       _return
            nop
        }
        
        scope apply_air_y_: {
            OS.patch_start(0x54AB0, 0x800D92B0)
            j       apply_air_y_
            nop
            _return:
            OS.patch_end()
            
            // a0 = player struct
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      t0, 0x0014(sp)          // ~
            sw      t1, 0x0018(sp)          // store t0, t1
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f18, 0x0044(v1)         // f18 = bone size multiplier (original line 1)
            lwc1    f16, 0x0000(t0)         // f16 = translation multiplier
            mul.s   f18, f18, f16           // apply translation multiplier
            
			
			li      t0, Size.multiplier_table    // t0 = size.multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = index = port * 4
            addu    t0, t0, t1              // t0 = &multiplier_table[index]
            lwc1    f16, 0x0000(t0)         // f16 = size multiplier (s)
            lui     t1, 0x3f80              // t1= 1
			mtc1    t1, f4					// move 1(fp) to f4 register
			c.eq.s	f4, f16					// if size multiplier is 1 (ie. normal)
			bc1t	_end					// then jump to end
			lui		t1, SUPER_MULT			// load giant size multiplier
			c.le.s	f16, f4					// if less than 1
			bc1t	_poison					// use poison multiplier
			mtc1    t1, f4					// move 0.6(fp) to f4 register
			
			beq		r0, r0, _end
			mul.s   f18, f4, f18            // apply super multiplier
			
			_poison:
			lui		t1, POISON_MULT			// load poison size multiplier
			mtc1    t1, f4					// move 1.8(fp) to f4 register
			mul.s   f18, f4, f18            // apply poison multiplier
			
			_end:
			sub.s   f16, f10, f8            // original line 2
            lw      t0, 0x0014(sp)          // ~
            lw      t1, 0x0018(sp)          // load t0, t1
            addiu   sp, sp, 0x0020          // deallocate stack space
            j       _return
            nop
        }
        
        scope apply_air_x_: {
            OS.patch_start(0x54B64, 0x800D9364)
            j       apply_air_x_
            nop
            _return:
            OS.patch_end()
            
            // a0 = player struct
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      t0, 0x0014(sp)          // ~
            sw      t1, 0x0018(sp)          // store t0, t1
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f18, 0x0040(v1)         // f18 = bone size multiplier (original line 1)
            lwc1    f10, 0x0000(t0)         // f10 = translation multiplier
            mul.s   f18, f18, f10           // apply translation multiplier
            
			li      t0, Size.multiplier_table    // t0 = size.multiplier_table
            lbu     t1, 0x000D(a0)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = index = port * 4
            addu    t0, t0, t1              // t0 = &multiplier_table[index]
            lwc1    f16, 0x0000(t0)         // f16 = size multiplier (s)
            lui     t1, 0x3f80              // t1= 1
			mtc1    t1, f4					// move 1(fp) to f4 register
			c.eq.s	f4, f16					// if size multiplier is 1 (ie. normal)
			bc1t	_end					// then jump to end
			lui		t1, SUPER_MULT			// load giant size multiplier
			c.le.s	f16, f4					// if less than 1
			bc1t	_poison					// use poison multiplier
			mtc1    t1, f4					// move 0.6(fp) to f4 register
			
			beq		r0, r0, _end
			mul.s   f18, f4, f18            // apply super multiplier
			
			
			_poison:
			lui		t1, POISON_MULT			// load poison size multiplier
			mtc1    t1, f4					// move 1.8(fp) to f4 register
			mul.s   f18, f4, f18            // apply poison multiplier
			
			_end:
			cvt.s.w f10, f6                 // original line 2
            lw      t0, 0x0014(sp)          // ~
            lw      t1, 0x0018(sp)          // load t0, t1
            addiu   sp, sp, 0x0020          // deallocate stack space
            j       _return
            nop
        }
        
        multiplier_table:
        float32 1.0                         // p1 translation multiplier
        float32 1.0                         // p2 translation multiplier              
        float32 1.0                         // p3 translation multiplier
        float32 1.0                         // p4 translation multiplier
        
    }
    
    // @ Description
    // Enables using the given FGM instead of the one specified by the hitbox command when the hitbox makes contact
    // Also supports playing the given FGM simultaneously with the one specified by the hitbox command
    // CCXYZZZZ
    // CC   = command byte
    // X    = (boolean) if not 0, then hitbox id is ignored and the fgm_id is used for all hitboxes
    // Y    = hitbox id (0-3 = hitbox 1-4)
    // ZZZZ = fgm_id, enable highest bit to play both sounds instead of override
    scope set_hitbox_fgm_: {
        constant COMMAND_LENGTH(0x4)
        li      t0, apply_fgm_.hitbox_fgm_table
        lbu     t1, 0x000D(s2)              // t1 = player port
        sll     t1, t1, 0x2                 // ~
        addu    t0, t0, t1                  // a0 = hitbox_fgm_table + (port * 4))
        lw      t0, 0x0000(t0)              // t0 = px_hitbox_fgm
        lh      t1, 0x0002(v0)              // t1 = fgm_id
        lbu     t2, 0x0001(v0)              // t2 = hitbox flags
        srl     t3, t2, 0x4                 // t3 = X
        bnez    t3, _set_for_all            // if flagged to apply to all hitboxes, then do so
        nop                                 // otherwise figure out which hitbox to set it for (t2 = Y (hitbox id))
        sll     t2, t2, 0x1                 // ~
        addu    t0, t0, t2                  // t2 = hitbox_fgm
        sh      t1, 0x0000(t0)              // store fgm_id
        b       _end
        nop

        _set_for_all:
        sh      t1, 0x0000(t0)              // store fgm_id for hitbox 1
        sh      t1, 0x0002(t0)              // store fgm_id for hitbox 2
        sh      t1, 0x0004(t0)              // store fgm_id for hitbox 3
        sh      t1, 0x0006(t0)              // store fgm_id for hitbox 4

        _end:
        ori     t8, r0, COMMAND_LENGTH      // set command length
        jr      ra                          // return
        nop

        // @ Description
        // Overrides the FGM for a hitbox if the corresponding hitbox FGM parameter is set
        scope apply_fgm_: {
            OS.patch_start(0x5E4A8, 0x800E2CA8)
            j       apply_fgm_
            nop
            _apply_fgm_return:
            OS.patch_end()
            // s0 = hit player struct
            // a3 = attacking player struct
            // t7 = hitbox struct
            addiu   sp, sp,-0x0038          // allocate stack space
            li      t0, hitbox_fgm_table    // t0 = hitbox_fgm_table
            lbu     t1, 0x000D(a3)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = hitbox_fgm_table + (port * 4)
            lw      t0, 0x0000(t0)          // t0 = px_hitbox_fgm

            _get_hitbox_id:
            subu    t1, t7, a3              // t1 = hitbox struct offset
            subiu   t1, t1, HITBOX_STRUCT_BASE// t1 = hitbox struct offset - HITBOX_STRUCT_BASE
            ori     t8, r0, HITBOX_STRUCT_SIZE// t8 = HITBOX_STRUCT_SIZE
            divu    t1, t8                  // ~
            mflo    t1                      // t1 = hitbox id
            // hitbox id = ((hitbox struct address - player struct address) - HITBOX_STRUCT_BASE) / HITBOX_STRUCT_SIZE

            _get_fgm_id:
            sll     t1, t1, 0x1             // ~
            addu    t0, t0, t1              // t0 = px_hitbox_fgm + (hitbox id * 2)
            lh      t1, 0x0000(t0)          // t1 = hitbox fgm_id
            sw      t1, 0x0028(sp)          // 0x0028(sp) = fgm_id
            addiu   t0, r0, -0x0001         // t0 = -1
            beq     t1, t0, _original       // skip if hitbox fgm_id = -1 (don't override)
            andi    t0, t1, 0x8000          // t0 = 0 if play both flag = FALSE, else t0 = 0x8000
            bnez    t0, _play_both          // play fgm_id alongside original if flag is enabled
            nop
            
            _override:
            jal     0x800C8654              // original line 1
            addu    a0, r0, t1              // a0 = new fgm_id
            j       _apply_fgm_return       // return
            addiu   sp, sp, 0x0038          // deallocate stack space
            
            _play_both:
            sw      a1, 0x002C(sp)          // 0x002C(sp)
            jal     0x800C8654              // original line 1
            lhu     a0, 0x8D00(a0)          // original line 2
            lw      a1, 0x002C(sp)          // restore a1
            lw      a0, 0x0028(sp)          // a0 = fgm_id (with flag)
            jal     0x800C8654              // play an additional sound
            andi    a0, a0, 0x7FFF          // a0 = new fgm_id
            j       _apply_fgm_return       // return
            addiu   sp, sp, 0x0038          // deallocate stack space

            _original:
            jal     0x800C8654              // original line 1
            lhu     a0, 0x8D00(a0)          // original line 2
            j       _apply_fgm_return       // return
            addiu   sp, sp, 0x0038          // deallocate stack space

            hitbox_fgm_table:
            dw p1_hitbox_fgm
            dw p2_hitbox_fgm
            dw p3_hitbox_fgm
            dw p4_hitbox_fgm

            p1_hitbox_fgm:
            dh 0xFFFF                       // hitbox 1
            dh 0xFFFF                       // hitbox 2
            dh 0xFFFF                       // hitbox 3
            dh 0xFFFF                       // hitbox 4
            p2_hitbox_fgm:
            dh 0xFFFF                       // hitbox 1
            dh 0xFFFF                       // hitbox 2
            dh 0xFFFF                       // hitbox 3
            dh 0xFFFF                       // hitbox 4
            p3_hitbox_fgm:
            dh 0xFFFF                       // hitbox 1
            dh 0xFFFF                       // hitbox 2
            dh 0xFFFF                       // hitbox 3
            dh 0xFFFF                       // hitbox 4
            p4_hitbox_fgm:
            dh 0xFFFF                       // hitbox 1
            dh 0xFFFF                       // hitbox 2
            dh 0xFFFF                       // hitbox 3
            dh 0xFFFF                       // hitbox 4
        }
    }
    
    // @ Description
    // sets the character's envcolor
    // CC000000
    // XXXXXXXX
    // XXXXXXXX = EnvColor
    scope set_env_color_: {
        constant COMMAND_LENGTH(0x8)
        li      t0, CharEnvColor.moveset_table
        lbu     t1, 0x000D(s2)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset to env color override value
        addu    t0, t0, t1                  // t0 = address of env color override value
        lw      t1, 0x0004(v0)              // t1 = new env color
        sw      t1, 0x0000(t0)              // update env color
        _end:
        jr      ra                          // return
        ori     t8, r0, COMMAND_LENGTH      // set command length
    }
    
    // @ Description
    // jumps command execution to a relative offset in the parent moveset file
    // CC00XXXX
    // XXXX = offset
    scope jump_to_moveset_file_: {
        constant COMMAND_LENGTH(0x0)
        lw      t0, 0x09C4(s2)              // t0 = character struct
        lw      t0, 0x002C(t0)              // t0 = character file 2(moveset) pointer
        lw      t0, 0x0000(t0)              // t0 = moveset file address
        lhu     t1, 0x0002(v0)              // t1 = offset
        addu    v0, t0, t1                  // command address = moveset file address + offset
        sw      v0, 0x0008(sp)              // store next command in stack
        _end:
        jr      ra                          // return
        ori     t8, r0, COMMAND_LENGTH      // set command length
    }
    
    // @ Description
    // Blank command with size 0x8
    // TODO: find something better than this
    scope skip_size_8_: {
        constant COMMAND_LENGTH(0x8)
        jr      ra                          // return
        ori     t8, r0, COMMAND_LENGTH      // set command length
    }

    command_table:
    dw      fsm_                            // 0xD0 SET FRAME SPEED MULTIPLIER
    dw      armour_                         // 0xD1 SET ARMOUR
    dw      hitbox_direction_               // 0xD2 OVERRIDE HITBOX DIRECTION
    dw      translation_multiplier_         // 0xD3 TOPJOINT TRANSLATION MULTIPLIER
    dw      y_velocity_                     // 0xD4 SET Y VELOCITY
    dw      fast_fall_                      // 0xD5 FAST FALL
    dw      play_sfx_random_                // 0xD6 RANDOM SFX
    dw      set_kinetic_                    // 0xD7 SET KINETIC STATE
    dw      set_hitbox_fgm_                 // 0xD8 SET HITBOX FGM
    dw      set_env_color_                  // 0xD9 SET ENV COLOR
    dw      switch_direction_               // 0xDA SWITCH DIRECTION
    dw      jump_to_moveset_file_           // 0xDB GO TO MOVESET FILE
    dw      OS.NULL                         // 0xDC
    dw      OS.NULL                         // 0xDD
    dw      OS.NULL                         // 0xDE
    dw      OS.NULL                         // 0xDF
    dw      OS.NULL                         // 0xE0
    dw      OS.NULL                         // 0xE1
    dw      OS.NULL                         // 0xE2
    dw      OS.NULL                         // 0xE3
    dw      OS.NULL                         // 0xE4
    dw      OS.NULL                         // 0xE5
    dw      OS.NULL                         // 0xE6
    dw      OS.NULL                         // 0xE7
    dw      OS.NULL                         // 0xE8
    dw      OS.NULL                         // 0xE9
    dw      OS.NULL                         // 0xEA
    dw      OS.NULL                         // 0xEB
    dw      OS.NULL                         // 0xEC
    dw      OS.NULL                         // 0xED
    dw      OS.NULL                         // 0xEE
    dw      OS.NULL                         // 0xEF
    dw      OS.NULL                         // 0xF0
    dw      OS.NULL                         // 0xF1
    dw      OS.NULL                         // 0xF2
    dw      OS.NULL                         // 0xF3
    dw      OS.NULL                         // 0xF4
    dw      OS.NULL                         // 0xF5
    dw      OS.NULL                         // 0xF6
    dw      OS.NULL                         // 0xF7
    dw      OS.NULL                         // 0xF8
    dw      OS.NULL                         // 0xF9
    dw      OS.NULL                         // 0xFA
    dw      OS.NULL                         // 0xFB
    dw      OS.NULL                         // 0xFC
    dw      OS.NULL                         // 0xFD
    dw      OS.NULL                         // 0xFE
    dw      OS.NULL                         // 0xFF
    
    command_table_2:
    dw      fsm_                            // 0xD0 SET FRAME SPEED MULTIPLIER
    dw      armour_                         // 0xD1 SET ARMOUR
    dw      hitbox_direction_               // 0xD2 OVERRIDE HITBOX DIRECTION
    dw      translation_multiplier_         // 0xD3 TOPJOINT TRANSLATION MULTIPLIER
    dw      OS.NULL                         // 0xD4 SET Y VELOCITY (SKIPPED)
    dw      OS.NULL                         // 0xD5 FAST FALL (SKIPPED)
    dw      skip_size_8_                    // 0xD6 RANDOM SFX (SKIPPED)
    dw      set_kinetic_                    // 0xD7 SET KINETIC STATE
    dw      set_hitbox_fgm_                 // 0xD8 SET HITBOX FGM
    dw      skip_size_8_                    // 0xD9 SET ENV COLOR (SKIPPED)
    dw      OS.NULL                         // 0xDA SWITCH DIRECTION (SKIPPED)
    dw      jump_to_moveset_file_           // 0xDB GO TO MOVESET FILE
    dw      OS.NULL                         // 0xDC
    dw      OS.NULL                         // 0xDD
    dw      OS.NULL                         // 0xDE
    dw      OS.NULL                         // 0xDF
    dw      OS.NULL                         // 0xE0
    dw      OS.NULL                         // 0xE1
    dw      OS.NULL                         // 0xE2
    dw      OS.NULL                         // 0xE3
    dw      OS.NULL                         // 0xE4
    dw      OS.NULL                         // 0xE5
    dw      OS.NULL                         // 0xE6
    dw      OS.NULL                         // 0xE7
    dw      OS.NULL                         // 0xE8
    dw      OS.NULL                         // 0xE9
    dw      OS.NULL                         // 0xEA
    dw      OS.NULL                         // 0xEB
    dw      OS.NULL                         // 0xEC
    dw      OS.NULL                         // 0xED
    dw      OS.NULL                         // 0xEE
    dw      OS.NULL                         // 0xEF
    dw      OS.NULL                         // 0xF0
    dw      OS.NULL                         // 0xF1
    dw      OS.NULL                         // 0xF2
    dw      OS.NULL                         // 0xF3
    dw      OS.NULL                         // 0xF4
    dw      OS.NULL                         // 0xF5
    dw      OS.NULL                         // 0xF6
    dw      OS.NULL                         // 0xF7
    dw      OS.NULL                         // 0xF8
    dw      OS.NULL                         // 0xF9
    dw      OS.NULL                         // 0xFA
    dw      OS.NULL                         // 0xFB
    dw      OS.NULL                         // 0xFC
    dw      OS.NULL                         // 0xFD
    dw      OS.NULL                         // 0xFE
    dw      OS.NULL                         // 0xFF
    
    // write changes to rom
    // load_command_ hooks
    // TODO: understand these command threads better and implement something better than load_command_2_
    pushvar origin, base
    origin  0x5BB88
    base    0x800E0388
    jal     load_command_
    nop
    origin  0x5BD48
    base    0x800E0548
    jal     load_command_2_
    nop
    origin  0x5BF2C
    base    0x800E072C
    jal     load_command_2_
    nop
    // change_action_ hook
    origin  0x6272C
    base    0x800E6F2C
    j       change_action_
    nop
    _change_action_return:
    pullvar base, origin
}
    
