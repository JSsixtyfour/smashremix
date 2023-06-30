
scope PerfectShield {

    constant REFLECT_MULTIPLIER(0x3F00) // 0.5

    reflect_hitbox_struct:
    dh 0x0000                         // index to custom reflect routine table. Reflect.custom_reflect_table
    dh Reflect.reflect_type.CUSTOM    // reflect type. Custom value of 4.  ( fox = 0, ??? = 1, bat = 2 )
    dw 0x00000004                     // joint
    dw 0x00000000                     // x offset (local)
    dw 0x42700000                     // y offset (local)
    dw 0x00000000                     // z offset (local)
    dw 0x43AF0000                     // x size = 512 (local)
    dw 0x43AF0000                     // y size = 512 (local)
    dw 0x43AF0000                     // z size = 512 (local)
    dw 0x18000000                     // ? hp value

    // @ Description
    // Don't change players action to shield stun
    scope shield_stun_action_change_skip: {
        OS.patch_start(0x61CD8, 0x800E64D8)
        j       shield_stun_action_change_skip
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_perfect_shield, at)      // at = Perfect shield toggle
        beqz    at, _original                       // branch if toggle is disabled
        addiu   at, r0, Action.ShieldOn             // at = shield player action
        // if here, check for a perfect shield
        lw      v0, 0x0024(s0)                      // v0 = current players action
        bne     v0, at, _original                   // branch if not shielding
        nop
        // if here, perfect shield
        sw      r0, 0x0040(s0)                      // remove hitstun
        sw      r0, 0x07CC(s0)                      // remove shield damage
        sw      r0, 0x0098(sp)                      // remove damage from stack
        jal     fighter_gfx
        lw      a0, 0x0004(s0)

        j       _return
        sw       r0, 0x07C8(s0)                     // incoming damage = 0

        _original:
        jal     0x80149108                          // og line1, set action to shield stun
        lw      a0, 0x00A0(sp)                      // og line2, a0 = player
        j       _return + 0x4
        lw      t2, 0x07C8(s0)                      // og line3
    }
    
    
    // @ Description
    // Reflect projectiles if under 3 frames
    scope shield_reflect_projectiles: {
        OS.patch_start(0xE16BC, 0x80166C7C)
        j       shield_reflect_projectiles
        nop
        _return:
        OS.patch_end()
        // v1 = projectile struct
        
        Toggles.read(entry_perfect_shield, t0)      // t0 = Perfect shield toggle
        beqz    t0, _original_logic                 // branch if toggle is disabled
        nop
        
        // initial loop setup variables
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t3, v1, 0x0214                      // t3 = pointer to first hit object
        addiu   t4, r0, 0                           // t4 = loop count
        addiu   t5, r0, 4                           // t5 = max loop count

        _loop_start:
        lw      t0, 0x0000(t3)                      // t0 = hit object pointer

        _loop_start_2:
        beq     t0, t1, _check_shield
        nop
        lw      t1, 0x0004(t1)                        // t1 = next player object
        bnez    t1, _loop_start_2
        nop

        // increment loop after looping through each player object
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t4, t4, 1                           // loop count +=1
        beq     t4, t5, _original_logic             // exit loop if no player object found
        addiu   t3, t3, 0x0008                      // t3 = next hit object

        b       _loop_start
        nop

        _check_shield:
        lw      t0, 0x0084(t0)                      // ~
        lw      t1, 0x0024(t0)                      // t1 = shielding player action
        addiu   t2, r0, Action.ShieldOn             // t2 = shield on action
        bne     t1, t2, _original_logic             // branch if not in shield on pose
        lw      t1, 0x001C(t0)                      // t1 = shielding player action frame count
        slti    t1, t1, 2                           // t1 = 0 if can't reflect
        beqz    t1, _original_logic
        
        // if here, perfect shield
        sw      r0, 0x0214(v1)                      // reset hit object ptr 1
        sw      r0, 0x021C(v1)                      // reset hit object ptr 2
        sw      r0, 0x0224(v1)                      // reset hit object ptr 3
        sw      r0, 0x022C(v1)                      // reset hit object ptr 4
        li      t1, reflect_hitbox_struct
        sw      t1, 0x0850(t0)                      // overwrite current reflect struct
        lw      t0, 0x0004(t0)                      // t0 = shielding player object
        sw      t0, 0x0008(v1)                      // overwrite player owner
        
        lui     t1, REFLECT_MULTIPLIER
        mtc1    t1, f4
        lw      t1, 0x0108(v1)                      // load current damage multiplier
        mtc1    t1, f6
        mul.s   f6, f4, f6                          // divide damage by 2
        nop
        c.le.s  f6, f4
        nop
        bc1fl   _apply_reflect
        swc1    f4, 0x0108(v1)                      // save new damage multipler as 0.5
        swc1    f6, 0x0108(v1)                      // save new damage multipler

        _apply_reflect:
        j       0x80166CB0
        lw      v0, 0x0290(v1)                      // v0 = reflect routine

        _original_logic:
        bc1fl   _original_branch                    // og line 1 modified
        lw      v0, 0x0284(v1)                      // og line 2 (v0 = shield collision routine)

        j       _return + 0x4
        lwc1    f6, 0xCA74(at)                      // og line 3

        _original_branch:
        j       0x80166CE0 + 0x4                    // og branch location
        lw      a0, 0x0020(sp)                      // og branch line 1

    }

    // @ Description
    // Reflect items if under 3 frames
    scope shield_reflect_items: {
        OS.patch_start(0xEBBFC, 0x801711BC)
        j       shield_reflect_items
        nop
        _return:
        OS.patch_end()
        // v1 = item struct

        Toggles.read(entry_perfect_shield, t0)      // t0 = Perfect shield toggle
        beqz    t0, _original_logic                 // branch if toggle is disabled
        nop

        // if here, check for perfect shield

        // initial loop setup variables
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t3, v1, 0x0224                      // t3 = pointer to first hit object
        addiu   t4, r0, 0                           // t4 = loop count
        addiu   t5, r0, 4                           // t5 = max loop count

        _loop_start:
        lw      t0, 0x0000(t3)                      // t0 = hit object pointer

        _loop_start_2:
        beq     t0, t1, _check_shield
        nop
        lw      t1, 0x0004(t1)                      // t1 = next player object
        bnez    t1, _loop_start_2
        nop

        // increment loop after looping through each player object
        OS.read_word(0x800466FC, t1)                // t1 = player object head
        addiu   t4, t4, 1                           // loop count +=1
        beq     t4, t5, _original_logic             // exit loop if no player object found
        addiu   t3, t3, 0x0008                      // t3 = next hit object

        b       _loop_start
        nop

        _check_shield:
        lw      t3, 0x0084(t0)                      // ~
        lw      t1, 0x0024(t3)                      // t1 = shielding player action
        addiu   t2, r0, Action.ShieldOn             // t2 = shield on action
        bne     t1, t2, _original_logic             // branch if not in shield on pose       
        lw      t1, 0x001C(t3)                      // t1 = shielding player action frame count
        slti    t1, t1, 2                           // t1 = 0 if can't reflect
        beqz    t1, _original_logic

        // if here, perfect shield
        sw      r0, 0x0224(v1)                      // reset hit object pointer 1
        sw      r0, 0x022C(v1)                      // reset hit object pointer 2
        sw      r0, 0x0234(v1)                      // reset hit object pointer 3
        sw      r0, 0x023C(v1)                      // reset hit object pointer 4
        li      t1, reflect_hitbox_struct
        sw      t1, 0x0850(t3)                      // overwrite current reflect struct
        
        addiu   t1, r0, Hazards.standard.POKEBALL   // t1 = pokeball id
        lw      t0, 0x000C(v1)                      // t0 = current item id
        beq     t0, t1, _skip_ownership_update      // dont update ownership if its a pokeball

        lw      t0, 0x0004(t3)                      // t0 = shielding player object
        sw      t0, 0x0008(v1)                      // overwrite player owner

        _skip_ownership_update:
        lui     t1, REFLECT_MULTIPLIER
        mtc1    t1, f4
        lw      t1, 0x0118(v1)                      // load current damage multiplier
        mtc1    t1, f6
        mul.s   f6, f4, f6                          // divide damage by 2
        nop
        c.le.s  f6, f4
        nop
        bc1fl   _apply_reflect
        swc1    f4, 0x0118(v1)                      // save new damage multipler as 0.5
        
        swc1    f6, 0x0118(v1)                      // save new damage multipler as current multiplier / 2
        
        _apply_reflect:
        j       0x80171228
        lw      v0, 0x0390(v1)                      // v0 = reflect routine

        _original_logic:
        bc1fl   _original_branch                    // og line 1 modified
        lw      v0, 0x0384(v1)                      // og line 2 (v0 = shield collision routine)

        j       _return + 0x4
        lwc1    f6, 0xCC5C(at)                      // og line 3

        _original_branch:
        j       0x80171228 + 0x4                    // og branch location
        lw      a0, 0x0020(sp)                      // og branch line 1

    }
    
    // a0 = player object
    scope fighter_gfx: {
        OS.save_registers()

        addiu   sp, sp, -0x30

        mtc1    r0, f0               // move 0 to floating point register
        addiu   a1, sp, 0x0018       // place 0x18 address of stack in a1
        swc1    r0, 0x0018(sp)       // save 0 to stack struct
        swc1    r0, 0x001C(sp)       // save 0 to stack struct
        swc1    r0, 0x0020(sp)       // save 0 to stack struct

        sw      a0, 0x0010(sp)
        lw      v0, 0x0084(a0)       // v0 = player struct

        jal     0x800EDF24           // determine origin point of projectiles
        lw      a0, 0x08F4(v0)       // load player shield joint

        addiu   a0, sp, 0x0018       // put stack struct location in a0
        lw      s1, 0x0010(sp)
        jal     0x80101500           // yellow swirl gfx (same as grab)
        lw      s1, 0x0084(s1)       // s1 = player struct (scaling)
        
        addiu   sp, sp, 0x30
        
        OS.restore_registers()
        jr      ra
        nop
    }

}
