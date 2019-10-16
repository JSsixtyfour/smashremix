// Command.asm (Fray)

// This file adds support for new commands in the moveset microcode

include "OS.asm"

scope Command {
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
    // General purpose. Runs when a character changes actions.
    scope change_action_: {
        sw  s1, 0x0018(sp)                  // original line 1
        sw  s0, 0x0014(sp)                  // original line 2
        OS.save_registers()                 // full register save
        
        scope _reset_translation_multiplier: {
            lw      a0, 0x0010(sp)          // ~
            lw      t2, 0x0074(a0)          // t2 = first bone struct
            lw      t2, 0x0048(t2)          // t2 = translation multiplier (bone 1 size multiplier)
            lw      t3, 0x0084(a0)          // t3 = player struct      
            li      t0, translation_multiplier_.multiplier_table
            lbu     t1, 0x000D(t3)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            sw      t2, 0x0000(t0)          // store default translation multiplier
        }
        
        scope _check_destroy_display_lists: {
            li      t0, previous_screen     // ~
            lw      t0, 0x0000(t0)          // t0 = previous_screen
            li      t1, Global.current_screen
            lbu     t1, 0x0000(t1)          // t1 = current_screen
            beq     t0, t1, _skip           // skip if previous_screen = current_screen
            nop
            
            // destroy saved display lists for p1
            jal     destroy_saved_display_lists_
            ori     a0, r0, 0x0000
            // destroy saved display lists for p2
            jal     destroy_saved_display_lists_
            ori     a0, r0, 0x0001
            // destroy saved display lists for p3
            jal     destroy_saved_display_lists_
            ori     a0, r0, 0x0002
            // destroy saved display lists for p4
            jal     destroy_saved_display_lists_
            ori     a0, r0, 0x0003

            _skip:
        }
        
        scope _reset_saved_display_lists: {
            lw      a0, 0x0010(sp)          // ~
            lw      t0, 0x0084(a0)          // t0 = player struct
            li      t1, model_part.table_save
            lbu     t2, 0x000D(t0)          // ~
            sll     t2, t2, 0x3             // t2 = player port * 8
            addu    t1, t1, t2              // t1 = table_save + (port * 8)
            lw      t1, 0x0000(t1)          // t1 = table_temp_px
            addiu   t2, t0, 0x08E8          // t2 = bone_table
            ori     t3, r0, model_part.TABLE_SIZE
            or      t4, r0, r0              // t4 = table_current
            
            _loop:
            beq     t3, t4, _exit_loop      // exit loop if table_current = TABLE_SIZE
            nop
            lw      t5, 0x0000(t1)          // t5 = saved dlist
            beq     t5, r0, _loop_end       // skip if t5 = NULL
            nop
            lw      t6, 0x0000(t2)          // t6 = bone struct
            sw      t5, 0x0050(t6)          // store dlist
            sw      r0, 0x0000(t1)          // reset saved dlist
            
            
            _loop_end:
            addiu   t1, t1, 0x0004          // increment table_temp_px
            addiu   t2, t2, 0x0004          // increment bone_table
            addiu   t4, t4, 0x0001          // increment table_current
            b       _loop
            nop
            
            _exit_loop:
        }
        
        scope _update_screen: {
            li      t0, previous_screen     // t0 = previous_screen address
            li      t1, Global.current_screen
            lbu     t1, 0x0000(t1)          // t1 = current_screen
            sw      t1, 0x0000(t0)          // update previous_screen
        }
        
        OS.restore_registers()              // full register load
        j   _change_action_return           // return
        nop
        
        // holds the screen id from the previous change_action_
        previous_screen:
        dw 0
    }
    
    // @ Description
    // Erases all saved display lists for a given player.
    // @ Arguments
    // a0 - player (p1 = 0, p4 = 3)
    scope destroy_saved_display_lists_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // store t0-t3
        li      t0, model_part.table_save   // ~
        sll     t1, a0, 0x3                 // ~
        addu    t1, t1, t0                  // t1 = table_save + (player * 8)
        lw      t0, 0x0000(t1)              // t0 = table_temp_px
        lw      t1, 0x0004(t1)              // t1 = table_perm_px
        ori     t2, r0, model_part.TABLE_SIZE
        or      t3, r0, r0                  // t2 = table_current
        
        _loop:
        beq     t2, t3, _exit_loop          // exit loop if table_current = TABLE_SIZE
        nop
        sw      r0, 0x0000(t0)              // destroy table_temp_px dlist
        sw      r0, 0x0000(t1)              // destroy table_perm_px dlist
        addiu   t0, t0, 0x0004              // increment table_temp_px
        addiu   t1, t1, 0x0004              // increment table_perm_px
        addiu   t3, t3, 0x0001              // increment table_current
        b       _loop
        nop

        _exit_loop:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // load t0-t3
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
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
    // sets the character's armour value to a given value.
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
            constant HITBOX_STRUCT_BASE(0x294)
            constant HITBOX_STRUCT_SIZE(0xC4)
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
        
        // @ Description
        // expands the existing end hitbox function to include resetting the directional override
        scope end_hitbox_: {
            // v0 = player struct
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            sw      t1, 0x0008(sp)          // store t1
            li      t0, apply_direction_.hitbox_dir_table
            lbu     t1, 0x000D(v0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // a0 = hitbox_dir_table + (port * 4))
            lw      t0, 0x0000(t0)          // t0 = px_hitbox_dir
            sw      r0, 0x0000(t0)          // ~
            sw      r0, 0x0004(t0)          // ~
            sw      r0, 0x0008(t0)          // ~
            sw      r0, 0x000C(t0)          // disable directional override for all hitboxes
            lw      t0, 0x0004(sp)          // ~
            lw      t1, 0x0008(sp)          // load t0, t1
            sw      r0, 0x04E0(v0)          // original line 1 (disable hitbox 4)
            sw      r0, 0x0294(v0)          // original line 2 (disable hitbox 1)
            addiu   sp, sp, 0x0010          // deallocate stack space
            j       _end_hitbox_return      // return
            nop
            
            pushvar origin, base 
            // end_hitbox_ hook
            origin  0x63D2C
            base    0x800E852C
            j       end_hitbox_
            nop
            _end_hitbox_return:
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
        
        apply_multiplier_: {
            // v0 = player struct
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      t0, 0x0004(sp)          // ~
            sw      t1, 0x0008(sp)          // ~
            sw      t2, 0x000C(sp)          // store t0-t2
            li      t0, multiplier_table    // t0 = multiplier_table
            lbu     t1, 0x000D(v0)          // t1 = player port
            sll     t1, t1, 0x2             // ~
            addu    t0, t0, t1              // t0 = multiplier_table + (port * 4)
            
            _load_multiplier:
            lwc1    f10, 0x0000(t0)         // f10 = translation multiplier
            mul.s   f16, f8, f10            // original line 1
            mtc1    t7, f8                  // original line 2
            lw      t0, 0x0004(sp)          // ~
            lw      t1, 0x0008(sp)          // ~
            lw      t2, 0x000C(sp)          // load t0-t2
            addiu   sp, sp, 0x0010          // deallocate stack space
            j       _apply_multiplier_return
            nop
            
            pushvar origin, base 
            // apply_multiplier_ hook
            origin	0x54444
            base	0x800D8C44
            j		apply_multiplier_
            nop
            _apply_multiplier_return:
            pullvar base, origin
        }
        
        
        multiplier_table:
        float32 0                           // p1 translation multiplier
        float32 0                           // p2 translation multiplier              
        float32 0                           // p3 translation multiplier
        float32 0                           // p4 translation multiplier
        
    }
    
    
    // @ Description
    // Commands used to save, load, and set display lists for model parts.
    // A table of bone structs can be found in the player struct at 0x8E8.
    // The display list pointer can be found in a bone struct at 0x50.
    scope model_part {
        constant TABLE_SIZE(0x24)
        // @ Description
        // Save a display list pointer for a given bone struct.
        // CCXXYYYY
        // XX = ID for bone struct table (0x00 - 0x23)
        // YYYY = save type: 0x0000 = temporary, !0x0000 = permanent
        scope save_: {
            constant COMMAND_LENGTH(0x4)
            addiu   t0, s2, 0x8E8           // t0 = bone_table
            lbu     t3, 0x0001(v0)          // ~
            sll     t3, t3, 0x2             // t3 = bone ID * 4
            addu    t0, t0, t3              // t0 = bone struct pointer (bone_table + bone ID * 4)
            lw      t0, 0x0000(t0)          // t0 = bone struct
            beq     t0, r0, _end            // skip if bone struct pointer = NULL
            nop
            lw      t2, 0x0050(t0)          // t2 = display list pointer
            beq     t2, r0, _end            // skip if display list pointer = NULL
            nop
            
            _get_table:
            li      t0, table_save          // t0 = table_save
            lbu     t1, 0x000D(s2)          // ~  
            sll     t1, t1, 0x3             // t1 = player port * 8
            addu    t0, t0, t1              // t0 = table_save + (port * 8)
            lhu     t1, 0x0002(v0)          // t1 = save type
            beq     t1, r0, _store          // branch if save type = temporary
            nop
            addiu   t0, t0, 0x0004          // table_perm offset
            
            _store:
            lw      t0, 0x0000(t0)          // ~
            addu    t0, t0, t3              // t0 = table + bone ID * 4
            lw      t1, 0x0000(t0)          // t1 = saved display list
            bnez    t1, _end                // skip if saved display list != NULL
            nop
            sw      t2, 0x0000(t0)          // store display list
            
            _end:
            ori     t8, r0, COMMAND_LENGTH  // set command length
            jr      ra                      // return
            nop
        }
        
        // @ Description
        // Load a display list pointer for a given bone struct.
        // CCXXYYYY
        // XX = ID for bone struct table (0x00 - 0x23)
        // YYYY = load type: 0x0000 = temporary, !0x0000 = permanent
        scope load_: {
            constant COMMAND_LENGTH(0x4)
            li      t0, table_save          // t0 = table_save
            lbu     t1, 0x000D(s2)          // ~  
            sll     t1, t1, 0x3             // t1 = player port * 8
            addu    t0, t0, t1              // t0 = table_save + (port * 8)
            lhu     t1, 0x0002(v0)          // t1 = save type
            beq     t1, r0, _load           // branch if save type = temporary
            nop
            addiu   t0, t0, 0x0004          // table_perm offset
            
            _load:
            lbu     t3, 0x0001(v0)          // ~
            sll     t3, t3, 0x2             // t3 = bone ID * 4
            lw      t0, 0x0000(t0)          // ~
            addu    t0, t0, t3              // t0 = table + bone ID * 4
            lw      t2, 0x0000(t0)          // t2 = saved display list
            beq     t2, r0, _end            // skip if saved display list = NULL
            nop
            
            _store:
            sw      r0, 0x0000(t0)          // reset saved display list
            addiu   t0, s2, 0x8E8           // t0 = bone_table
            addu    t0, t0, t3              // t0 = bone struct pointer (bone_table + bone ID * 4)
            lw      t0, 0x0000(t0)          // t0 = bone struct
            beq     t0, r0, _end            // skip if bone struct pointer = NULL
            nop
            sw      t2, 0x0050(t0)          // restore saved display list
            
            _end:
            ori     t8, r0, COMMAND_LENGTH  // set command length
            jr      ra                      // return
            nop
        }
        
        // @ Description
        // Set the display list pointer for a given bone struct.
        // CCXXYYYY
        // XX = ID for bone struct table (0x00 - 0x23)
        // YYYY = ID for display list table (0x0000 = NULL)
        scope set_: {
            constant COMMAND_LENGTH(0x4)
            addiu   t0, s2, 0x8E8           // t0 = bone_table
            lbu     t3, 0x0001(v0)          // ~
            sll     t3, t3, 0x2             // t3 = bone ID * 4
            addu    t0, t0, t3              // t0 = bone struct pointer (bone_table + bone ID * 4)
            lw      t2, 0x0000(t0)          // t2 = bone struct
            beq     t2, r0, _end            // skip if bone struct pointer = NULL
            nop
            
            _get_dlist:
            li      t0, table_dlist         // t0 = table_dlist
            lhu     t1, 0x0002(v0)          // ~
            sll     t1, 0x2                 // t1 = dlist ID * 4
            addu    t0, t0, t1              // t0 = table_dlist + dlist ID * 4
            lw      t0, 0x0000(t0)          // t0 = dlist pointer
            sw      t0, 0x0050(t2)          // store dlist pointer
            
            _end:
            ori     t8, r0, COMMAND_LENGTH  // set command length
            jr      ra                      // return
            nop
        }
        
        table_save:
        dw  table_temp_p1
        dw  table_perm_p1
        dw  table_temp_p2
        dw  table_perm_p2
        dw  table_temp_p3
        dw  table_perm_p3
        dw  table_temp_p4
        dw  table_perm_p4
        
        table_temp_p1:                      // temporary save table (reset on action change)
        fill TABLE_SIZE * 4
        table_temp_p2:                      // temporary save table (reset on action change)
        fill TABLE_SIZE * 4
        table_temp_p3:                      // temporary save table (reset on action change)
        fill TABLE_SIZE * 4
        table_temp_p4:                      // temporary save table (reset on action change)
        fill TABLE_SIZE * 4
        
        table_perm_p1:                      // permanent save table (don't reset on action change)
        fill TABLE_SIZE * 4
        table_perm_p2:                      // permanent save table (don't reset on action change)
        fill TABLE_SIZE * 4
        table_perm_p3:                      // permanent save table (don't reset on action change)
        fill TABLE_SIZE * 4
        table_perm_p4:                      // permanent save table (don't reset on action change)
        fill TABLE_SIZE * 4
        
        table_dlist:                        // table of pointers to custom display lists
        constant DLIST_SPEAR(0x8040C830)
		constant DLIST_DRMPILLHAND(0x804262A0)
        constant DLIST_YLINKBOTTLEHAND(0x80427848)
        dw  OS.NULL                         // 0x00 - NULL
        dw  DLIST_SPEAR                     // 0x01 - Ganondorf's Spear/Trident
		dw	DLIST_DRMPILLHAND				// 0x02 - Doctor Mario's Pill Hand
        dw  DLIST_YLINKBOTTLEHAND           // 0x03 - Young Link's Bottle Hand
        
    }
    
    command_table:
    dw      fsm_                            // 0xD0 SET FRAME SPEED MULTIPLIER
    dw      armour_                         // 0xD1 SET ARMOUR
    dw      hitbox_direction_               // 0xD2 OVERRIDE HITBOX DIRECTION
    dw      translation_multiplier_         // 0xD3 TOPJOINT TRANSLATION MULTIPLIER
    dw      model_part.save_                // 0xD4 MODEL PART SAVE
    dw      model_part.set_                 // 0xD5 MODEL PART SET
    dw      model_part.load_                // 0xD6 MODEL PART LOAD
    dw      OS.NULL                         // 0xD7
    dw      OS.NULL                         // 0xD8
    dw      OS.NULL                         // 0xD9
    dw      OS.NULL                         // 0xDA
    dw      OS.NULL                         // 0xDB
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
    pushvar origin, base
    origin  0x5BB88
    base    0x800E0388
    jal     load_command_
    nop
    origin  0x5BD48
    base    0x800E0548
    jal     load_command_
    nop
    origin  0x5BF2C
    base    0x800E072C
    jal     load_command_
    nop
    // change_action_ hook
    origin  0x6272C
    base    0x800E6F2C
    j       change_action_
    nop
    _change_action_return:
    pullvar base, origin
}
    