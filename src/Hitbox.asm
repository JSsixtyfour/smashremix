// Hitbox.asm (by Fray)
if !{defined __HITBOX__} {
define __HITBOX__()
print "included Hitbox.asm\n"

// @ Description
// Hitbox display is implemented in this file

include "Toggles.asm"
include "OS.asm"

scope Hitbox {
    
    // @ Description
    // this is a hook into the function which loads the character's hitbox display state
    // by default the value (at 0x0B4C(s8)) will always be 0
    // v1 contains hitbox display state:
    // 0 = no hitbox display
    // 3 = ECB display
    // (all other values?) = hitbox display
    scope hitbox_mode_: {
        OS.patch_start(0x0006E3FC, 0x800F2BFC)
        j       hitbox_mode_
        nop
        _hitbox_mode_return:
        OS.patch_end()
        
        swc1    f10, 0x0000(v0)             // original line 1
        lli     v1, 0x0000                  // v1 = no hitbox display
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // store t0 - t2
        
        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 1 if hitbox_mode, 3 if ECB
        lli     t1, 0x0001                  // t1 = 1
        beql    t0, t1, _update_player      // if (hitbox_mode), set v1
        lli     v1, 0x0001                  // v1 = hitbox display

        lli     t1, 0x0003                  // t1 = 3
        beql    t0, t1, _update_player      // if (ecb_mode), set v1
        lli     v1, 0x0003                  // v1 = ecb display
        
        _update_player:
        sw      v1, 0x0B4C(s8)              // save hitbox display state
        
        _update_item:
        li      t2, item_.buffer            // t2 = item_buffer
        
        _loop:
        lw      t1, 0x0000(t2)              // t1 = item pointer
        beqz    t1, _exit_loop              // if t1 = NULL, exit loop
        nop
        sw      v1, 0x0374(t1)              // save hitbox display state
        addiu   t2, t2, 0x0004              // increment buffer pointer
        b       _loop                       // loop
        nop
        
        _exit_loop:
        li      t0, item_.saved_struct      // ~
        sw      r0, 0x0000(t0)              // reset saved struct
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // load t0 - t2
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        j       _hitbox_mode_return
        nop
    }
    
    // @ Description
    // this hook generates a list of item struct pointers every time a frame advance occurs,
    // intended to provide a simpler method of managing the hitbox display state for all items
    // some stage hazards are also affected by this function
    scope item_: {
        // s7 - curr_struct
        // comparing against the player struct ensures the buffer is not filled twice
    
        OS.patch_start(0x00060E28, 0x800E5628)
        j       item_
        nop
        _item_return:
        OS.patch_end()
        lui     a1, 0x800A                  // original line 1
        lw      s8, 0x0084(t8)              // original line 2 
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // store t0 - t2
        
        _compare_struct:
        li      t2, saved_struct            // t2 = saved_struct
        li      t1, buffer_pointer          // t1 = buffer_pointer address
        lw      t0, 0x0000(t2)              // t0 = saved struct address
        beq     t0, s7, _continue           // if saved_struct = curr_struct, skip
        nop
        li      t0, buffer                  // t0 = buffer address
        sw      t0, 0x0000(t1)              // reset buffer_pointer
        
        _continue:
        li      t0, buffer                  // t0 = buffer address
        addiu   t0, t0, 0x0078              // t0 = buffer + 0x78
        lw      t1, 0x0000(t1)              // t1 = buffer_pointer
        slt     t0, t0, t1                  // ~
        bnez    t0, _end                    // skip if buffer end has been reached
        nop
        move    t0, t1                      // t0 = buffer_pointer
        sw      s8, 0x0000(t0)              // store pointer
        sw      r0, 0x0004(t0)              // store null terminator
        li      t1, buffer_pointer          // t1 = buffer_pointer address
        addiu   t0, t0, 0x0004              // ~
        sw      t0, 0x0000(t1)              // increment buffer pointer
        
        _end:
        lw      t0, 0x0000(t2)              // t0 = saved struct address
        sw      s7, 0x0000(t2)              // saved_struct = curr_struct
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // load t0 - t2
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _item_return
        nop
        
        buffer_pointer:
        dw  buffer
        
        buffer:
        fill 0x0080
        
        saved_struct:
        dw OS.NULL
    }
    
    // @ Description
    // this is a hook into the function which loads the display state for projectiles
    
    scope projectile_: {
        OS.patch_start(0x000E1F78, 0x80167538)
        j       projectile_
        nop
        _projectile_return:
        OS.patch_end()
        or      s0, a0, r0                  // original line 1
        lli     v1, 0x0000                  // v1 = no hitbox display
        
        addiu   sp, sp, -0x000C             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 1 if hitbox_mode
        lli     t1, 0x0001                  // t1 = 1
        beql    t0, t1, _update_projectile  // if (hitbox_mode), set v1
        lli     v1, 0x0001                  // v1 = hitbox display

        lli     t1, 0x0003                  // t1 = 3
        beql    t0, t1, _update_projectile  // if (ecb_mode), set v1
        lli     v1, 0x0003                  // v1 = ecb display
        
        _update_projectile:
        sw      v1, 0x02BC(v0)              // save projectile display state
        
        end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x000C              // deallocate stack space
        j       _projectile_return
        nop
    }

    // @ Description
    // This makes it so the hitbox display is positioned correctly on the CSS screens and the VS results screen.
    // I am doing it this way because I don't know if the positioning is important on other screens.
    // See https://github.com/tehzz/SSB64-Notes/blob/master/Universal/Model%20Display/Routine%20800F293C%20-%20renderCharModel.md#hurtbox-mooring
    scope fix_hitbox_position_: {
        OS.patch_start(0x6EB10, 0x800F3310)
        j       fix_hitbox_position_
        nop
        _fix_hitbox_position_return:
        OS.patch_end()

        li      at, Toggles.entry_special_model
        lw      at, 0x0004(at)              // at = 1 if hitbox_mode
        lli     t5, 0x0001                  // t5 = 1
        bne     at, t5, _original           // if (!hitbox_mode), skip
        nop
        li      at, Global.current_screen   // ~
        lb      at, 0x0000(at)              // at = screen id

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t5, at, 0x0010              // if (screen id < 0x10)...
        bnez    t5, _original               // ...then branch to original (not on a CSS)
        nop
        slti    t5, at, 0x0015              // if (screen id is between 0x10 and 0x14)...
        bnez    t5, _fix                    // ...then we're on a CSS
        nop
        addiu   t5, r0, 0x0018              // t5 = results screen id
        beq     t5, at, _fix                // if (screen id = results) then apply the fix
        nop                                 // ...otherwise just do the original:

        _original:
        addiu   at, r0, 0x03EA              // original line 1 - this is the key "mooring" value
        lw      t5, 0x0000(t7)              // original line 2
        j       _fix_hitbox_position_return  // return
        nop

        _fix:
        addiu   at, r0, 0x03EA              // original line 1 - this is the key "mooring" value
        addiu   t5, r0, 0x03EA              // intentionally set t5 equal to at
        j       _fix_hitbox_position_return  // return
        nop

    }
}

} // __HITBOX__
