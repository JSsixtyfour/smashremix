// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(spawn_custom_item_based_on_red_shell_)
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(prepickup_main_)
constant DROP_ITEM(0x801745FC)
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)


// @ Description
// These constants are written to the Blue Shells special item struct
constant DEATH_TIMER(0x3C0)                     // = 16 seconds
constant KNOCKBACK_ANGLE(90)                    // = 90 DEGREES
constant HURTBOX_FGM(0x02B7)                    // = none
constant HURTBOX_DAMAGE(30)                     // = 30 damage
constant BASE_KNOCKBACK(100)
constant KNOCKBACK_GROWTH(0x100)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xE30)                     // red shell default is 0x584
constant STATE_TABLE(item_info_array + 0x34)


// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                          // 0x00 - item ID(updated by Item.add_item)
dw 0x8018D040                                   // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                                  // 0x08 - offset to item footer in file 0xFB
dw 0                                            // 0x0C - ? 
dw 0                                            // 0x10 - ?
dw aerial_main_                                 // 0x14 - spawn behavior
dw idle_ground_collision_                       // 0x18 - ground collision
dw 0                                            // 0x1C - ?
dw 0, 0, 0, 0                                   // 0x20 - 0x2C - ?
dw idle_hurtbox_collision_                      // 0x30

// change item state @ 0x80172ec8
// STATE 0 - IDLE
dw 0                                            // 0x34
dw resting_main_                                // 0x38 - resting/pickup main
dw 0                                            // 0x3C
dw 0
dw 0, 0, 0                                      // 0x40 - 0x4C - ?
dw idle_hurtbox_collision_                      // 0x50

// state 1 - grounded
dw aerial_main_                                 // 0x54
dw idle_ground_collision_                       // 0x58 - ground collision
dw 0                                            // 0x5C
dw 0, 0, 0, 0                                   // 0x60 - 0x6C 
dw 0                                            // 0x70

// STATE 2 - PICKUP
dw 0, 0, 0, 0, 0, 0, 0, 0                       // 0x74 - 0x90

// STATE 3 - THROWN
dw aerial_main_                                 // 0x94 - main
dw air_to_ground_check_                         // 0x98
dw collide_with_player_                         // 0x9C
dw 0x8017B2F8                                   // 0xA0 - collide with shield
dw 0x801733E4                                   // 0xA4 - glance with shield
dw 0x8017B2F8                                   // 0xA8 - collide with shield
dw 0x8017B31C                                   // 0xAC - collide with reflector
dw idle_hurtbox_collision_                      // 0xB0

// STATE 4
dw aerial_main_                                 // 0xB4 - main
dw air_to_ground_check_                         // 0xB8 - collision check main 
dw collide_with_player_                         // 0xBC - collision main
dw 0x8017B2F8                                   // 0xC0 - collide with shield 
dw 0x801733E4                                   // 0xC4 - aerial glance with shield(using r.shell)
dw 0x8017B2F8                                   // 0xC8
dw 0x8017B31C                                   // 0xCC - aerial collide with reflector(using r.shell)
dw idle_hurtbox_collision_                      // 0xD0

// STATE 5 - ACTIVE GROUNDED
dw grounded_active_                             // 0xD4 - grounded subroutine (r.shell uses 0x8017AD7C)
dw grounded_check_collision_                    // 0xD8 - grounded gravity subroutine(using r.shell) original was 8017ADD4
dw collide_with_player_                         // 0xDC -
dw collide_with_shield_                         // 0xE0 - collide with shield
dw 0                                            // 0xE4 -
dw 0                                            // 0xE8 -
dw 0x8017B31C                                   // 0xEC - collide with reflector(using r.shell)
dw grounded_collide_with_hurtbox_               // 0xF0 - collide with hitbox

// STATE 6 - AIR-TO-GROUND 
dw aerial_main_                                 // 0xF4 - main
dw air_to_ground_check_                         // 0xF8 - aerial collision check main(using r.shell)
dw collide_with_player_                         // 0xFC - collision main collide with hurtbox
dw collide_with_player_                         // 0x100 - collision main(using r.shell)
dw 0                                            // 0x104 -
dw 0                                            // 0x108
dw 0x8017B31C                                   // 0x10C - collide with reflector(using r.shell)
dw idle_hurtbox_collision_                      // 0x110
dw 0                                            // 0x114
dw 0                                            // 0x118
dw 0                                            // 0x11C


// @ Description
// Spawns a throwable custom item based on shell. Based on 0x8017B1D8
scope spawn_custom_item_based_on_red_shell_: {
    // Update a1 to be the custom item's item info array.
    OS.copy_segment(0xEF064, 0x1C)
    // Look up item info array address using item ID
    li      a3, Item.item_info_array_table
    lw      t7, 0x0064(sp)              // t7 = item ID
    addiu   a1, t7, -0x002D             // a1 = index in item_info_array_table
    sll     a1, a1, 0x0002              // a1 = offset in item_info_array_table
    addu    a3, a3, a1                  // a3 = address of item info array pointer
    lw      a1, 0x0000(a3)              // a1 = item info array pointer
    lw      a3, 0x0048(sp)              // original line 9
    jal     0x8016E174                  // create item
    sw      t6, 0x0010(sp)
    beqz    v0, _end                    // skip if no item created

    OS.copy_segment(0xF5C4C, 0xD8)      // copy part of red shell routine @ 8017B20C

    // overwrite values in item special struct. Create a branch if adding more.
    _blue_shell:
    // a0 = item special struct
    addiu   v0, r0, BlueShell.HURTBOX_DAMAGE // v0 = ~
    sw      v0, 0x0110(a0)               // save
    addiu   v0, r0, 0x0048               // v0 = kb value
    sw      v0, 0x148(a0)                // save kb value
    addiu   v0, r0, BlueShell.HURTBOX_FGM // v0 = hurtbox FGM(none)
    sh      v0, 0x156(a0)                // save fgm value
    addiu   v0, r0, BlueShell.KNOCKBACK_ANGLE// v0 = knockback angle
    sw      v0, 0x013C(a0)               // save knockback angle
    sw      r0, 0x0180(a0)               // set 0x180 to 0
    addiu   v0, r0, BlueShell.DEATH_TIMER // v0 = death timer(16 seconds) while active(default = 8 seconds)
    sw      v0, 0x02C0(a0)               // save death timer	
    lli     at, BASE_KNOCKBACK           // at = base knockback
    sw      at, 0x0148(a0)               // overwrite bkb
    lli     at, KNOCKBACK_GROWTH         // at = knockback growth
    sw      at, 0x0140(a0)               // overwrite

    addiu   v0, r0, 0x0003               // v0 = electric damage type
    sw      v0, 0x011C(a0)               // damage type

    lw      v0, 0x0348(a0)               // restore v0(unsure if needed)
    _end:
    OS.copy_segment(0xF5D24, 0x14)       // deallocate sp + return
}

// @ Description
// based on red shell routine @ 0x8017A7C4
scope resting_main_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)

    li      a1, ground_to_air_          // a1 = routine to run if no longer grounded
    jal     0x801735a0                  // wall/ground detect routine
    nop

    lw      ra,     0x0014(sp)
    addiu   sp, sp, 0x18
    or      v0, r0, r0
    jr      ra
    nop
}

// @ Description
// based on red shell prepickup @ 8017AABC
scope prepickup_main_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    lw      t6, 0x0074 (a0)
    mtc1    r0, f4
    li      a1, STATE_TABLE             // a1 = item states
    addiu   a2, r0, 0x0002              // state table
    jal     0x80172ec8                  // change state
    swc1    f4, 0x0034 (t6)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// Based on 0x8017ADD4 for red shell
scope grounded_check_collision_: {
    addiu   sp, sp, -0x20                // begin
    sw      ra, 0x001c(sp)                // save registers
    sw      s0, 0x0018(sp)                // ~
    lw      s0, 0x0084(a0)

    // lui     a1, 0x8018                // original code, a1 = a red  
    // addiu   a1, a1,0xb1a4            // shells "set_aerial" routine
    li      a1, set_aerial                // a1 = set_aerial routine

    jal     0x801735a0                    // this routine will check if the item has left a platform
    sw      a0, 0x0020(sp)
    beqzl   v0, _end
    lw      ra, 0x001c(sp)
    lhu     t6, 0x008e(s0)
    andi    t7, t6,0x0021
    beqzl   t7, _end
    lw      ra, 0x001c(sp)
    lwc1    f4, 0x002c(s0)
    neg.s   f6, f4
    swc1    f6, 0x002c(s0)
    jal     0x80172508
    lw      a0, 0x0020(sp)
    jal     0x8017279c                    // unknown
    lw      a0, 0x0020(sp)
    lwc1    f8, 0x0358(s0)
    neg.s   f10, f8
    swc1    f10, 0x0358(s0)
    lw      ra, 0x001c(sp)

    _end:
    lw      s0, 0x0018(sp)                // end
    addiu   sp, sp,0x20
    jr      ra
    or      v0, r0, r0
}

// @ Description
// based on red shells ground to air transition routine @ 8017A984
scope ground_to_air_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      a0, 0x0084(a0)
    addiu   t9, r0, 0x0001
    lbu     t7, 0x02CE(a0)              // load pickup flag

    sw      t9, 0x0248(a0)
    andi    t8, t7, 0xFF7F
    jal     0x80173f78                  // changes unknown flag
    sb      t8, 0x02ce(a0)
    li      a1, STATE_TABLE             // a1 = item states
    lw      a0, 0x0018(sp)
    jal     0x80172ec8                  // change item state
    addiu   a2, r0, 0x0001
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// copied red shells ground to air transition routine @ 801735A0
// unused
scope ground_to_air_2: {
    addiu    sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    jal     0x8017356c                // unknown routine
    sw      a1, 0x001c(sp)
    bnez    v0, _set_flag
    lw      t9, 0x001c(sp)
    jalr    ra, t9
    lw      a0, 0x0018(sp)
    b       _end
    or      v0, r0, r0

    _set_flag:
    addiu   v0, r0, 0x0001

    _end:
    lw      ra, 0x0014 (sp)
    addiu   sp, sp,0x18
    jr      ra
    nop
}

// @ Description
// based on 0x8017A7EC
scope idle_ground_collision_: {
    addiu    sp, sp, -0x18
    sw      ra, 0x0014(sp)
    lw      v0, 0x0084(a0)
    lui     a1, 0x3e80
    lui     a2, 0x3f00              // a2 =  bounce multiplier
    lbu     t6, 0x0352(v0)
    li      a3, idle_grounded_initial_  // original = 0x8017A964

    bnez    t6, _skip
    nop

    jal     0x80173df4
    lui     a1, 0x3e80
    b       _end
    lw      ra, 0x0014(sp)

    _skip:
    jal     0x80173B24
    nop
    or      v0, r0, r0
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18

    _end:
    jr      ra
    nop
}

// @ Description
// passed as an argument in idle_ground_collision_. based on 0x8017A964
scope idle_grounded_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    jal     idle_grounded_initial_2_
    nop
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}



// @ Description
// based on 8017A83C
scope idle_grounded_initial_2_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x001c(sp)
    sw      s1, 0x0018(sp)
    sw      s0, 0x0014(sp)
    lw      s0, 0x0084(a0)
    or      s1, a0, r0
    jal     0x80173f54              // common, unknown subroutine - occurs when an item becomes grounded
    or      a0, s0, r0
    lwc1    f0, 0x002c(s0)
    mtc1    r0, f4
    lui     at, 0x4100
    mtc1    at, f6
    c.lt.s  f0, f4
    nop
    bc1fl   _branch_0
    mov.s   f2, f0

    b       _branch_0
    neg.s   f2, f0
    mov.s   f2, f0

    _branch_0:
    c.lt.s  f2, f6
    nop
    bc1fl   _grounded
    lbu     t7, 0x0353(s0)

    jal     0x80172e74              // ?
    or      a0, s1, r0
    mtc1    r0, f8
    sb      r0, 0x0353(s0)
    or      a0, s1, r0

    jal     0x8017279c              // subroutine seems to mark projectiles as dangerous to the user
    swc1    f8, 0x002c(s0)
    addiu   t6, r0, 0x0001
    sw      t6, 0x0248(s0)
    sw      r0, 0x010c(s0)
    jal     0x8017a734              // physics routine for r.shell
    or      a0, s1, r0
    li      a1, item_info_array + 0x34 // al = item info array
    or      a0, s1, r0
    jal     0x80172ec8              // change item state
    or      a2, r0, r0
    b       _end
    lw      ra, 0x001c(sp)
    lbu     t7, 0x0353(s0)

    _grounded:
    addiu   t8, r0, 0x0001
    or      a0, s1, r0
    beqz    t7, _branch2
    nop

    jal     0x8016f280              // looks like math
    sw      t8, 0x010c(s0)
    jal     set_grounded
    or      a0, s1, r0
    b       _end
    lw      ra, 0x001c(sp)

    _branch2:
    jal     0x80172e74              // ?
    or      a0, s1, r0
    mtc1    r0, f10
    or      a0, s1, r0
    jal     0x8017279c              // subroutine seems to mark projectiles as dangerous to the user
    swc1    f10, 0x002c(s0)
    addiu   t9, r0, 0x0001
    sw      t9, 0x0248(s0)
    sw      r0, 0x010c(s0)
    jal     0x8017a734              // commong physics routine for red shell
    or      a0, s1, r0
    li      a1, STATE_TABLE         // a1 = item info array + offset
    or      a0, s1, r0
    jal     0x80172ec8              // change item state
    or      a2, r0, r0
    lw      ra, 0x001c(sp)

    _end:
    lw      s0, 0x0014(sp)
    lw      s1, 0x0018(sp)
    jr      ra
    addiu   sp, sp, 0x20
}


// @ Description
// based on red shell throw routine @ 0x8017AAF0
scope throw_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      a0, 0x0084(a0)
    addiu   v0, r0, 0x0001
    addiu   t7, r0, 0x0010
    lbu     t8, 0x02ce(a0)
    sb      v0, 0x0352(a0)
    sb      v0, 0x0353(a0)
    andi    t9, t8, 0xfff1
    sb      t7, 0x0350(a0)
    jal     0x80173f78              // changes unknown flag
    sb      t9, 0x02ce(a0)
    nop

    // get player in first
    lw      a0, 0x0018(sp)
    lw      a0, 0x0084(a0)          // a0 = item object
    lui     s0, 0x8004
    jal     get_player_in_first_
    lw      s0, 0x66fc(s0)          // s0 = player 1 ptr

    sw      at, 0x180(a0)           // save player in first ptr to free space in item special struct

    li      a1, STATE_TABLE
    lw      a0, 0x0018(sp)
    jal     0x80172ec8              // change item state
    addiu   a2, r0, 0x0003          // state = 3(thrown)
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on redshell air to ground routine 0x8017ABA0
scope air_to_ground_check_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014(sp)

    lw      v1, 0x0084(a0)
    li         a3, set_grounded     // a3 = routine to use if collide with ground
    lui     a1, 0x3e80
    lui     a2, 0x3f00
    jal     0x80173c68              // checks collision with clipping, shared between red/green shell
    sw      v1, 0x001c(sp)
    beqz    v0, _end                // skip if item did not collide with ground clipping
    lw      v1, 0x001c(sp)

    // if here, item touched the ground
    lwc1           f4, 0x002c(v1)
    mtc1           r0, f6
    addiu          t6, r0, 0xffff
    addiu          t7, r0, 0x0001
    c.lt.s         f4, f6
    nop            
    bc1fl          _continue
    sw             t7, 0x0024(v1)

    b              _continue
    sw             t6, 0x0024(v1)

    // idk how you get here
    sw             t7, 0x0024(v1)

    _continue:
    lw             t8, 0x0024(v1)
    lui            at, 0xc100
    mtc1           at, f16
    mtc1           t8, f8
    lui            at, 0xc120
    mtc1           at, f4
    cvt.s.w        f10, f8
    lui            at, 0x8019
    lwc1           f8, 0xcda4(at)
    mul.s          f18, f10, f16
    add.s          f6, f18, f4
    mul.s          f10, f6, f8
    swc1           f10, 0x002c(v1)

    _end:
    lw             ra, 0x0014(sp)
    addiu          sp, sp, 0x20
    or             v0, r0, r0
    jr             ra
    nop
}

// @ Description
// based on 0x80173B24
scope aerial_stage_clipping_check_: {
    addiu          sp, sp, -0x30
    sw             ra, 0x001c(sp)
    sw             s0, 0x0018(sp)
    sw             a1, 0x0034(sp)
    sw             a2, 0x0038(sp)
    sw             a3, 0x003c(sp)
    lw             t6, 0x0084(a0)
    or             s0, a0, r0
    addiu          a1, r0, 0x0800
    jal            0x801737b8
    sw             t6, 0x002c(sp)
    sw             v0, 0x0024(sp)
    or             a0, s0, r0
    addiu          a1, r0, 0x0421
    lw             a2, 0x0034(sp)
    jal            0x801737ec
    or             a3, r0, r0
    beqzl          v0, _no_wall_collide    // branch if item did not hit a wall
    lw             t7, 0x0024(sp)

    // if here, then item hit a wall
    jal            0x80172508
    or             a0, s0, r0
    lw             t7, 0x0024(sp)

    _no_wall_collide:
    or             v0, r0, r0
    beqz           t7, _no_ground_collide  // branch if item did not hit a floor
    nop
    lw             v0, 0x002c(sp)
    addiu          a0, v0, 0x002c
    sw             a0, 0x0020(sp)
    jal            0x800c7b08
    addiu          a1, v0, 0x00b8
    lw             a0, 0x0020(sp)
    jal            0x800c7ae0
    lw             a1, 0x0038(sp)
    jal            0x80172508
    or             a0, s0, r0
    lw             v0, 0x003c(sp)
    beqz           v0, _no_ground_collide
    nop
    jalr           ra, v0
    or             a0, s0, r0

    _continue:
    b              _no_ground_collide    // ?
    addiu          v0, r0, 0x0001

    _no_ground_collide:
    lw             ra, 0x001c(sp)
    lw             s0, 0x0018(sp)
    addiu          sp, sp, 0x30
    jr             ra
    nop

}

// @ Description
// based on redshell aerial physics routine @ 0x8017A74C
scope aerial_main_: {
    addiu   sp, sp, -0x20           // allocate sp    
    sw      ra, 0x0014(sp)          // store registers
    sw      a0, 0x0020(sp)          // ~

    lw      a3, 0x0084(a0)          //
    lui     a1, 0x3f99              // a1 = gravity multiplier(1.2)
    ori     a1, a1, 0x999a          // ~
    lui     a2, 0x42c8              // a2 = base throw speed(100.0)
    or      a0, a3, r0              // a0 = item special struct
    jal     0x80172558              // apply gravity(seems to be a common physics subroutine)
    sw      a3, 0x001c(sp)          //
    lw      a3, 0x001c(sp)          //
    lw      a0, 0x0020(sp)          //
    lbu     v0, 0x0350(a3)          // v0 = throw timer

    bnezl   v0, _continue           // branch if throw timer != 0
    addiu   at, r0, 0xffff          // 

    // if here, make projectile damage the user
    jal     0x8017279c              // subroutine that marks projectiles as dangerous to the user
    sw      a3, 0x001c(sp)          //
    lw      a3, 0x001c(sp)          //
    addiu   t7, r0, 0x00ff          // t7 = FF
    andi    v0, t7, 0x00ff          //
    sb      t7, 0x0350(a3)          // throw timer = FF
    addiu   at, r0, 0xffff          //

    _continue:
    beq     v0, at, _end            //
    addiu   t8, v0, 0xffff          //
    sb      t8, 0x0350(a3)          //

    _end:
    lw      ra, 0x0014(sp)          // restore registers
    addiu   sp, sp, 0x20            // deallocate sp
    or      v0, r0, r0              // ~
    jr      ra                      // return
    nop                             // ~
}

// @ Description
// based on red shell collision routine @ 0x8017AE48
scope collide_with_player_: {
    addiu   sp, sp, -0x20            // allocate stackspace
    sw      ra, 0x0014(sp)           // save return address
    lw      v1, 0x0084(a0)
    or      a1, a0, r0
    addiu   t9, r0, 0x0001           // t9 = 1
    lbu     t6, 0x0355(v1)           // load shells "hp" value?
    addiu   a0, r0, 0x0004
    addiu   t7, t6, 0xffff
    andi    t8, t7, 0x00ff
    
    // check if hit player was in first
    // lw      t9, 0x180(v1)           // t9 = player in first
    // lw      t3, 0x224(v1)           // t3 = hit object ptr 1
    // beq     t9, t3, _destroy_shell  // destroy if it is player first place
    // sb      t7, 0x0355(v1)
    // lw      t3, 0x22C(v1)           // t3 = hit object ptr 2
    // beq     t9, t3, _destroy_shell  // destroy if it is player first place
    // nop
    // lw      t3, 0x234(v1)           // t3 = hit object ptr 3
    // beq     t9, t3, _destroy_shell  // destroy if it is player first place
    // nop
    // lw      t3, 0x23C(v1)           // t3 = hit object ptr 4
    // beq     t9, t3, _destroy_shell  // destroy if it is player first place
    // nop

    // jal     FGM.play_               // play fgm
    // addiu   a0, r0, 0x0038          // a0 = shell FGM
    // // check if shells timer is out
    // bnez    t8,  _continue          // branch if shell still alive
    // sb      t7, 0x0355(v1)          //

    _destroy_shell:
    jal        hit_gfx_
    sw      v1, 0x001c(sp)
    jal        FGM.play_            // play fgm
    addiu   a0, r0, 0x0001          // a0 = explosion FGM
    b       _end                    // if here, branch to end
    addiu   v0, r0, 0x0001          // v0 = 1,(destroy object = TRUE)
        
    _continue:
    addiu   t3, r0, 0x0000          // restore t3
    addiu   t9, r0, 0x0001          // restore t9
    sw      t9, 0x0248(v1)
    sw      a1, 0x0020(sp)
    //jal     0x80018994              // unknown
    sw      v1, 0x001c(sp)
    lw      v1, 0x001c(sp)
    lui     at, 0x3f80              // on hit speed multiplier(default = bf80)
    mtc1    at, f6
    lw      t0, 0x0268(v1)
    lwc1    f4, 0x002c(v1)
    lui     at, 0xc100
    mtc1    t0, f16
    mul.s   f8, f4, f6
    mtc1    at, f10
    lw      a0, 0x0020(sp)
    lui     at, 0x8019
    sb      v0, 0x0352(v1)
    cvt.s.w f18, f16
    lwc1    f16, 0xcda8(at)
    mul.s   f4, f10, f18
    add.s   f6, f8, f4
    mul.s   f10, f6, f16
    jal     0x8017a734              // unknown

    swc1    f10, 0x002c(v1)
    lw      v1, 0x001c(sp)
    lw      a1, 0x0020(sp)
    lw      t1, 0x0108(v1)
    beqz    t1, _grounded           // branch if kinetic state == grounded
    nop       
    jal     set_idle_aerial_        // change state back to idle and adds bounce back
    or      a0, a1, r0
    b       _end                    // branch to end
    or      v0, r0, r0

    _grounded:
    jal     set_grounded            // changes state to grounded
    or      a0, a1, r0
    or      v0, r0, r0

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop
}


// @ Description
// based on red shell collision routine @ 0x8017AE48
scope collide_with_shield_: {
    addiu   sp, sp, -0x20           // allocate stackspace
    sw      ra, 0x0014(sp)          // save return address
    lw      v1, 0x0084(a0)
    or      a1, a0, r0
    addiu   t9, r0, 0x0001          // t9 = 1
    lbu     t6, 0x0355(v1)          // load shells "hp" value
    addiu   a0, r0, 0x0004
    addiu   t7, t6, 0xffff
    andi    t8, t7, 0x00ff
    
    jal        FGM.play_            // play fgm
    addiu   a0, r0, 0x0038          // a0 = shell FGM
    
    // check if shells timer is out
    bnez    t8,  _continue          // branch if shell still alive
    //sb      t7, 0x0355(v1)        //
    
    _destroy_shell:
    //jal        hit_gfx_    
    //sw      v1, 0x001c(sp)
    //jal        FGM.play_          // play fgm
    //addiu   a0, r0, 0x0001        // a0 = explosion FGM
    //b       _end                  // if here, branch to end
    //addiu   v0, r0, 0x0001        // v0 = 1,(destroy object = TRUE)
        
    _continue:
    addiu   t3, r0, 0x0000          // restore t3
    addiu   t9, r0, 0x0001          // restore t9
    sw         t9, 0x0248(v1)
    sw      a1, 0x0020(sp)
    //jal     0x80018994            // unknown
    sw      v1, 0x001c(sp)
    lw      v1, 0x001c(sp)
    lui     at, 0x3f00              // on hit speed multiplier(default = bf80)
    mtc1    at, f6
    lw      t0, 0x0268(v1)
    lwc1    f4, 0x002c(v1)
    lui     at, 0xc100
    mtc1    t0, f16
    mul.s   f8, f4, f6
    mtc1    at, f10
    lw      a0, 0x0020(sp)
    lui     at, 0x8019
    sb      v0, 0x0352(v1)
    cvt.s.w f18, f16
    lwc1    f16, 0xcda8(at)
    mul.s   f4, f10, f18
    add.s   f6, f8, f4
    mul.s   f10, f6, f16
    jal     0x8017a734              // physics routine
    swc1    f10, 0x002c(v1)
    lw      v1, 0x001c(sp)
    lw      a1, 0x0020(sp)
    lw      t1, 0x0108(v1)
    beqz    t1, _grounded           // branch if kinetic state == grounded
    nop
    jal     set_aerial              // changes state to aerial
    or      a0, a1, r0
    b       _end                    // branch to end
    or      v0, r0, r0

    _grounded:
    jal     set_grounded            // changes state to grounded
    or      a0, a1, r0
    or      v0, r0, r0

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop
}

// @ Description
// based on red shells set grounded routine @ 0x8017B0D4
scope set_grounded: {
    addiu   sp, sp, -0x18         // allocate stackspace
    sw      ra, 0x0014(sp)        // store registers

    jal     0x8017afec            // animate red shell
    sw      a0, 0x0018(sp)        // store a0
    li      a1, STATE_TABLE       // a1 = item info array offset
    lw      a0, 0x0018(sp)        // a0 = item special struct
    jal     0x80172ec8            // change item state
    addiu   a2, r0, 0x0005        // state = 5,(active_grounded)

    lw      ra, 0x0014(sp)        // restore registers
    addiu   sp, sp, 0x18          // deallocate stackspace
    jr      ra                    // return
    nop
}

// @ Description
// based on red shells aerial transition routine @ 0x8017B1A4
scope set_aerial: {
    addiu   sp, sp, -0x18          // allocate stackspace
    sw      ra, 0x0014(sp)         // store registers

    jal     0x8017b108             // stop animating red shell
    sw      a0, 0x0018(sp)         // store a0

    li      a1, STATE_TABLE        // a1 = item info array offset
    lw      a0, 0x0018(sp)         // a0 =  item special struct
    jal     0x80172ec8             // change item state
    addiu   a2, r0, 0x0006         // state = 6,(active_aerial)

    lw      ra, 0x0014(sp)         // restore registers
    addiu   sp, sp, 0x18           // deallocate stackspace
    jr      ra                     // return
    nop
}


// @ Description
// based on green shells bounce back routine @ 80178C6C
// if blue shell is thrown at a player, it re-enters idle state similar to green shell
scope set_idle_aerial_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014 (sp)
    sw      a0, 0x0020 (sp)
    lw      v1, 0x0084 (a0)
    addiu   t7, r0, 0x0001
    addiu   a0, r0, 0x0004
    sw      t7, 0x0248 (v1)
    // jal     0x80018994             // math that crashes
    sw      v1, 0x001c (sp)
    lw      v1, 0x001c (sp)
    lui     at, 0x4218
    mtc1    at, f4
    sb      v0, 0x0352 (v1)
    // jal     0x80018948            // common routine that items use
    swc1    f4, 0x0030 (v1)
    lw      v1, 0x001c (sp)
    lui     at, 0x3e00
    mtc1    at, f10
    lwc1    f6, 0x002c (v1)
    neg.s   f8, f6
    mul.s   f16, f8, f10
    nop
    mul.s   f18, f0, f16
    swc1    f18, 0x002c (v1)
    jal     0x8017279c             // unknown
    lw      a0, 0x0020 (sp)
    jal     0x80178704             // unknown
    lw      a0, 0x0020 (sp)
    jal     set_idle_aerial_2      // changes state. Based on 0x80178930
    lw      a0, 0x0020 (sp)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x20
    or      v0, r0, r0
    jr      ra
    nop
}
// @ Description
// based on 0x80178930
scope set_idle_aerial_2: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      a0, 0x0084(a0)
    lbu     t7, 0x02ce(a0)
    sw      r0, 0x0248(a0)
    sw      r0, 0x010c(a0)
    andi    t8, t7, 0xff7f
    jal     0x80173f78             // common subroutine changes kinetic state flag to aerial
    sb      t8, 0x02ce(a0)
    li      a1, STATE_TABLE        // a1 = item info array offset
    lw      a0, 0x0018(sp)
    jal     0x80172ec8             // change item state
    addiu   a2, r0, 0x0001         // state = 1
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}


// @ Description
// based on red shell grounded routine @ 0x8017AD7C
scope grounded_active_: {
    addiu   sp, sp, -0x20                // allocate stackspace
    sw      ra, 0x0014(sp)               // store registers
    lw      t6, 0x0084(a0)               // ~
    sw      a0, 0x0020(sp)               // ~

    jal     grounded_gfx_                // smoke trail graphics, default is 0x8017a610
    sw      t6, 0x001c(sp)
    jal     target_player_               // subroutine determines what direction shell goes. default is 0x8017A534
    lw      a0, 0x0020(sp)
    
    lw      a0, 0x0020(sp)				// a0 = item object
    lw      v1, 0x0084(a0)				// v1 = item struct
    lw      v0, 0x02C0(v1)               // check death flag

    //li    a0, 0x00F0
    //blt   v0, a0, _edge_detect_skip    // skip edge detect function if shell has a few seconds left
    //nop
    
    jal     0x8017ac84                   // edge detect function
    _edge_detect_skip:
    lw      a0, 0x0020(sp)
    lw      v1, 0x001c(sp)               // v1 = item special struct
    lw      v0, 0x02c0(v1)               // check death flag
    bnez    v0, _continue                // branch if item needs to die
    addiu   t7, v0, 0xffff

    // if here, destroy blue shell
    b       _end
    addiu   v0, r0, 0x0001            // v0 = 1(destroys blue shell)

    _continue:
    sw      t7, 0x02c0(v1)
    or      v0, r0, r0

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop
	}
			
// @ Description
// based on red shells grounded gfx routine 0x8017a610, calls smoke gfx @ 0x800FF048
scope grounded_gfx_: {
    addiu   sp, sp, -0x30            // allocate sp
    sw      ra, 0x0014(sp)           // store registers
    lw      v0, 0x0084(a0)           //
    lw      a3, 0x0074(a0)           //
    lbu     v1, 0x0351(v0)           // v1 = gfx timer
    bnezl   v1, _end                 // branch if timer != 0
    addiu   t1, v1, 0xffff

	// every 8 frames, create smoke and remove owner  
	sw      r0, 0x0008(v0)			// remove owner	
	lw      t7, 0x001c(a3)
    addiu   a0, sp, 0x001c
    lui     a2, 0x4f80
    sw      t7, 0x0000(a0)
    lw      t6, 0x0020(a3)
    sw      t6, 0x0004(a0)
    lw      t7, 0x0024(a3)
    sw      t7, 0x0008(a0)
    lw      t8, 0x02d4(v0)
    lwc1    f4, 0x0020(sp)
    lh      t9, 0x002e(t8)
    mtc1    t9, f6
    nop     
    cvt.s.w f8, f6
    add.s   f10, f4, f8             // changes y offset of graphic
    swc1    f10, 0x0020(sp)
    lw      a1, 0x0024(v0)
    jal     custom_smoke_           // default = 0x800ff048
    sw      v0, 0x002c(sp)
    lw      v0, 0x002c(sp)
    addiu   t0, r0, 0x0008          // magic number. gfx routine will run again in 8 frames
    andi    v1, t0, 0x00ff
    sb      t0, 0x0351(v0)
    addiu   t1, v1, 0xffff
    
    _end:
    sb     t1, 0x0351(v0)
    lw     ra, 0x0014(sp)
    addiu  sp, sp, 0x30
    jr     ra
    nop
}

// @ Description
// based on create smoke puff routine @ 0x800FF048, not documented well
scope custom_smoke_: {
    addiu          sp, sp, -0x38         // allocate stackspace
    sw             ra, 0x001c(sp)        // save registers
    sw             s0, 0x0018(sp)        // ~
    sw             a0, 0x0038(sp)        // ~
    sw             a1, 0x003c(sp)        // ~
    
    jal            0x800fd4b8            // common subroutine, returns address with variables related to smoke life
    sw             a2, 0x0040(sp)
    bnez           v0, _unknown_skip
    or             s0, v0, r0

    // never used?
    b              _end
    or             v0, r0, r0
    // ?
    
    _unknown_skip:
    addiu          a0, r0, 0x03f3
    or             a1, r0, r0
    addiu          a2, r0, 0x0006
    jal            0x80009968            // initializes textures for display(render.asm)
    lui            a3, 0x8000
    bnez           v0, continue_
    sw             v0, 0x0034(sp)
    jal            0x800fd4f8
    or             a0, s0, r0
    b              _end
    or             v0, r0, r0

    continue_:
    sw             s0, 0x0084(v0)
    lui            at, 0x4000
    mtc1           at, f6
    lwc1           f4, 0x0040(sp)
    lui            a0, 0x8013
    c.eq.s         f4, f6
    nop            
    bc1f           branch1
    nop            

    // ? this section was skipped
    lui            a0, 0x8013
    lw             a0, 0x13c4(a0)
    addiu          a1, r0, 0x00
    jal            0x800ce9e8
    ori            a0, a0, 0x0008

    b              branch2
    sw             v0, 0x0030(sp)
    // ? above was skipped

    branch1:
    lw        a0, 0x13c4(a0)            // loads unknown flag from 0x801313c4
    addiu   a1, r0, 0x008A              // 55 = smoke puff, 87 = pink smoke(custom)
    jal     0x800ce9e8                  // returns another address with coordinates
    ori     a0, a0, 0x0008
    sw      v0, 0x0030(sp)

    branch2:
    beqz    v0, _skip
    or      a0, r0, r0
    lw      a0, 0x0030(sp)
    jal     0x800ce1dc                  // this routine writes scaling values
    or      a1, r0, r0
    beqz    v0, branch3
    lw      a0, 0x0030(sp)
    lw      t6, 0x0034(sp)
    lui     t7, 0x8010
    addiu   t7, t7, 0xdb88
    sw      t7, 0x00b4(v0)
    sw      t6, 0x00bc(v0)
    sw      v0, 0x002c(sp)
    jal     0x800cea14                  // unknown, setting to nop seems to do nothing
    lw      a0, 0x0030(sp)
    lw      v1, 0x002c(sp)
    lui     a1, 0x8010
    addiu   a1, a1, 0xefe0
    lhu     t8, 0x002a(v1)
    lw      a0, 0x0034(sp)
    addiu   a2, r0, 0x0001
    bnez    t8, branch4                 // does not draw smoke if = 0
    addiu   a3, r0, 0x0003
    b       _end
    or      v0, r0, r0
    branch4:
    jal     0x80008188
    sw      v1, 0x002c(sp)
    lw      v1, 0x002c(sp)
    lui     at, 0x8013
    sw      v1, 0x0034(s0)
    lw      t9, 0x0038(sp)
    lw      t1, 0x0000(t9)
    sw      t1, 0x0004(v1)
    lw      t0, 0x0004(t9)
    sw      t0, 0x0008(v1)
    lw      t1, 0x0008(t9)
    lwc1    f8, 0x0008(v1)
    sw      t1, 0x000c(v1)
    lwc1    f10, 0x0974(at)
    add.s   f16, f8, f10
    jal     0x80018948
    swc1    f16, 0x0008(v1)
    lui     at, 0x8013
    lwc1    f18, 0x0978(at)             // loads a float from hard coded address 0x80130978
    lw      v1, 0x002c(sp)
    mul.s   f4, f0, f18
    jal     0x80018948
    swc1    f4, 0x0018(v1)
    lui     at, 0x8013
    lwc1    f6, 0x097c(at)
    lui     at, 0x8013
    lwc1    f10, 0x0980(at)
    mul.s   f8, f0, f6
    add.s   f12, f8, f10
    jal     0x80035cd0
    swc1    f12, 0x0024(sp)
    lui     at, 0x4210
    mtc1    at, f16
    addiu   at, r0, 0x0001
    mul.s   f18, f0, f16
    swc1    f18, 0x0018(s0)
    lw      t2, 0x003c(sp)
    bne     t2, at, branch5
    nop     
    lwc1    f4, 0x0018(s0)
    neg.s   f6, f4
    swc1    f6, 0x0018(s0)

    branch5:
    jal     0x800303f0
    lwc1    f12, 0x0024(sp)
    lui     at, 0x8013
    lwc1    f12, 0x0984(at)
    lui     at, 0x4210
    mtc1    at, f8
    lwc1    f10, 0x0018(s0)
    addiu   t3, r0, 0x0009
    mul.s   f2, f0, f8
    neg.s   f16, f10
    sw      t3, 0x0030(s0)
    mul.s   f18, f16, f12
    neg.s   f4, f2
    swc1    f2, 0x001c(s0)
    mul.s   f6, f4, f12
    swc1    f18, 0x0024(s0)
    b       branch6
    swc1    f6, 0x0028(s0)

    branch3:
    jal     0x800fdb3c
    lw      a1, 0x0034(sp)
    b       branch6
    sw      v0, 0x0030(sp)

    _skip:
    jal     0x800fdb3c
    lw      a1, 0x0034(sp)

    branch6:
    lw      v0, 0x0030(sp)

    _end:
    lw      ra, 0x001c(sp)
    lw      s0, 0x0018(sp)
    addiu   sp, sp, 0x38
    jr      ra
    nop
}

// @ Description
// based on red shells grounded gfx routine 0x8017a610
scope hit_gfx_: {
    addiu    sp, sp, -0x30              // allocate sp
    sw       ra, 0x0014(sp)             // store registers
    or        a0, r0, a1                // a0 = a1

    lw       v0, 0x0084(a0)
    lw       a3, 0x0074(a0)
    //addiu    t1, v1, 0xffff           // idk
    lw           t7, 0x001c(a3)
    addiu        a0, sp, 0x001c
    lui          a2, 0x4f80
    sw           t7, 0x0000(a0)
    lw           t6, 0x0020(a3)
    sw           t6, 0x0004(a0)
    lw           t7, 0x0024(a3)
    sw           t7, 0x0008(a0)
    lw           t8, 0x02d4(v0)
    lwc1         f4, 0x0020(sp)
    lh           t9, 0x002e(t8)
    mtc1         t9, f6
    nop
    cvt.s.w      f8, f6
    add.s        f10, f4, f8
    swc1         f10, 0x0020(sp)
    lw           a1, 0x0024(v0)
    jal          0x80101790                // big white spark gfx routine 
    sw           v0, 0x002c(sp)
    lw           v0, 0x002c(sp)
    addiu        t0, r0, 0x0008
    andi         v1, t0, 0x00ff
    sb           t0, 0x0351(v0)
    //addiu        t1, v1, 0xffff          // idk

    _end:
    sb          t1, 0x0351(v0)
    lw          ra, 0x0014(sp)
    jr          ra
    addiu       sp, sp, 0x30
}

// @ Description
// runs if shell hits another shell based on @ 0x8017AF18
// lots of copy and paste, indented were lines added
scope grounded_collide_with_hurtbox_: {
    addiu          sp, sp, -0x18
    sw             ra, 0x0014(sp)
    lw             v0, 0x0084(a0)    // v0 = item object
    lui            at, 0x4100
    lbu            t6, 0x0355(v0)
    addiu          t7, t6, 0xffff
    andi           t8, t7, 0x00ff
    
    bnez           t8, _continue
    sb             t7, 0x0355(v0)

    b              _end
    addiu          v0, r0, 0x0001

    _continue:
    // before continue, be sure player in 1st ptr is updated
    sw      a0, 0x0010(sp)          // store registers
    sw      s0, 0x0008(sp)          // ~
    move    a0, v1                  // a0 = item struct
    lui     s0, 0x8004
    jal     get_player_in_first_    // update player in 1st pointer in shells struct
    lw      s0, 0x66fc(s0)          // s0 = player 1 ptr
    lw      a0, 0x0010(sp)          // restore registers
    lw      s0, 0x0008(sp)          // ~
    lw      ra, 0x0014(sp)          // ~

    sw             a0, 0x0010(sp)

    lw             t9, 0x0298(v0)
    lw             t0, 0x02a4(v0)
    lwc1           f18, 0x002c(v0)
    mtc1           t9, f4
    subu           t1, r0, t0
    mtc1           t1, f8
    cvt.s.w        f0, f4
    addiu          t2, r0, 0x0001
    cvt.s.w        f10, f8
    mtc1           r0, f8
    add.s          f6, f0, f0
    mul.s          f16, f6, f10
    mtc1           at, f6
    add.s          f4, f18, f16
    swc1           f4, 0x002c(v0)
    lwc1           f2, 0x002c(v0)
    c.lt.s         f2, f8
    nop
    bc1fl          _grounded
    mov.s          f0, f2
    b              _grounded
    neg.s          f0, f2
    mov.s          f0, f2
    
    _grounded:
    c.lt.s         f6, f0
    nop
    bc1fl          _end
    sw             r0, 0x010c(v0)
    sw             t2, 0x010c(v0)
    jal            0x8016f280                // looks like math
    sw             a0, 0x0018(sp)
    jal            0x801727bc                // writes values to item. would be interesting to look at
    lw             a0, 0x0018(sp)
    jal            set_grounded              // set grounded
    lw             a0, 0x0018(sp)
    b              _end        
    or             v0, r0, r0
    sw             r0, 0x010c(v0)

    _end:
    or             v0, r0, r0
    lw             ra, 0x0014(sp)
    jr             ra
    addiu          sp, sp, 0x18

}


// @ Description
// runs if shell hits another shell based on @ 0x8017A9D0
// a0 = item object, a1 = 
scope idle_hurtbox_collision_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014(sp)
    sw      s0, 0x0008(sp)          // store s0
    lw      v0, 0x0084(a0)
    lui     at, 0x4120
    mtc1    at, f8
    lw      t6, 0x0298(v0)
	
    lw      t7, 0x02a4(v0)
    mtc1    r0, f2
    mtc1    t6, f4
    subu    t8, r0, t7
    mtc1    t8, f16
    cvt.s.w f6, f4
    lui     at, 0x4100
    mtc1    at, f4
    addiu   t9, r0, 0x0001
    addiu   t0, r0, 0x0001
    cvt.s.w f18, f16
    mul.s   f10, f6, f8
    nop
    mul.s   f0, f10, f18
    c.lt.s  f0, f2
    swc1    f0, 0x002c(v0)
    bc1f    _branch_0
    nop

    lwc1    f0, 0x002c(v0)
    b       branch_1
    neg.s   f0, f0

    _branch_0:
    lwc1    f0, 0x002c(v0)

    branch_1:
    c.lt.s  f4, f0

    nop
    bc1fl   _end
    swc1    f2, 0x002c(v0)

    sb      t9, 0x0353(v0)
    sw      t0, 0x010c(v0)
    sw      a0, 0x0020(sp)
    jal     0x8016f280                // looks like math
    sw      v0, 0x001c(sp)
    jal     0x801727bc                // writes values to item
    lw      a0, 0x0020(sp)
    lw      v0, 0x001c(sp)
    lw      a0, 0x0020(sp)
    lw      t1, 0x0108(v0)
    beqz    t1, _grounded
    nop

    jal     set_aerial
    nop
    b       _end2
    lw      ra, 0x0014(sp)

    _grounded:
    jal     set_grounded
    nop

    b       _end2
    lw      ra, 0x0014(sp)
    swc1    f2, 0x002c(v0)

    _end:
    sw      r0, 0x010c(v0)
    lw      ra, 0x0014(sp)

    _end2:
    lw      a0, 0x0020(sp)			// restore item object
	lw      a0, 0x0084(a0)			// a0 = item struct
	
	// update player owner
	lw      at, 0x02A8(a0)			// at = player who hit the shell
	sw      at, 0x0008(a0)			// write player owner
	
	// set gfx counter to 0x10
	lli     at, 0x10				// 16 frames until it can damage owner
	sb      at, 0x0351(a0)			// overwrite gfx counter (is normally 8)

    // now that shell is active, check and see who is in first place
    lui     s0, 0x8004
    jal     get_player_in_first_
    lw      s0, 0x66fc(s0)          // s0 = player 1 ptr

    lw      a0, 0x0020(sp)          // restore registers
    lw      s0, 0x0008(sp)          // ~
    lw      ra, 0x0014(sp)          // ~
    addiu   sp, sp, 0x20
    jr      ra
    or      v0, r0, r0
}

// @ Description    
// based on 0x8017A534(red shell target player)
scope target_player_: {
    addiu   sp, sp, -0x68               // allocate stackspace
    sw      s0, 0x001c(sp)              // store registers
    lui     s0, 0x8004
    lw      s0, 0x66fc(s0)
    sw      ra, 0x002c(sp)
    sw      s3, 0x0028(sp)              // store registers
    sw      s2, 0x0024(sp)              // ~
    sw      s1, 0x0020(sp)              // ~
    sw      r0, 0x005c(sp)				// clear this space

    beqz    s0, _apply_speed            // skip if no valid player
    or      s1, r0, r0                  // s1(i) = 0
	
	lw      v0, 0x0084(a0)				// v0 = item struct
	lb      v1, 0x0351(v0)				// v1 = shell gfx timer
    addiu   at, r0, 0x0007              // at = 7
    bnel    at, v1, _end_target_loop    // run check only 1/8 frames
    lw      s0, 0x180(v0)               // s0 = last known player ptr

    // if here, loop through players
    jal     get_player_in_first_        // routine gets ptr of the player in first (returned as at)
    nop
    addiu   s0, at, 0x0000              // s0 = at
    sw      s0, 0x180(v0)               // save player in first ptr to free space in item special struct

    _end_target_loop:
    sdc1    f20, 0x0010(sp)
    sw      a0, 0x0068(sp)              // save a0 to sp
    lw      v0, 0x0074(a0)              // v0 = item object

    beqz    s0, _apply_speed            // skip if no player found
    nop
    lw      at, 0x0074(s0)              // a1 = player location struct
    beqz    at, _apply_speed            // failsafe, use current speed if no player coords
    nop
    or      a1, at, r0                  // if here, a1 = player location struct

    lwc1    f20, 0x0048(sp)             // f20 = 0
    addiu   s3, sp, 0x003c              // s3 = some pointer in sp
    addiu   s2, v0, 0x001c              // s2 = item object.x

    or      a0, s3, r0                  //
    or      a2, s2, r0                  //
    jal     0x8001902c                  // common calcuation subroutine
    addiu   a1, a1, 0x001c              //

    lwc1    f2, 0x003c(sp)
    mul.s   f4, f2, f2
    lwc1    f12, 0x0040(sp)
    mul.s   f6, f12, f12
    add.s   f20, f4, f6
    lwc1    f2, 0x003c(sp)
    lwc1    f12, 0x0040(sp)
    mul.s   f8, f2, f2
    nop
    mul.s   f10, f12, f12
    add.s   f0, f8, f10
    c.le.s  f0, f20
    mov.s   f20, f0                    // applies speed
    sw      s0, 0x005c(sp)
    lw      a1, 0x0074(s0)
    swc1    f20, 0x0048(sp)

    _apply_speed:
	lw      a1, 0x005c(sp)
	beqz    a1, _end					// skip adding speed if no player is found
	nop
    jal     0x8017a3a0                 // apply speed
    lw      a0, 0x0068(sp)

	_end:
    lw      ra, 0x002c(sp)
    ldc1    f20, 0x0010(sp)
    lw      s0, 0x001c(sp)
    lw      s1, 0x0020(sp)
    lw      s2, 0x0024(sp)
    lw      s3, 0x0028(sp)
    jr      ra
    addiu   sp, sp, 0x68
}

// @ Description
// runs every 8 frames. returns pointer of player in first in at.
scope get_player_in_first_: {
    addiu   sp, sp, -0x38               // allocate sp
    sw      a1, 0x0004(sp)              // store registers
    sw      v0, 0x0008(sp)              // ~
    sw      s2, 0x000C(sp)              // ~
    sw      s3, 0x0010(sp)              // ~
    sw      s4, 0x0014(sp)              // ~
    sw      s5, 0x0018(sp)              // ~
    sw      s6, 0x0020(sp)              // ~
    sw      t1, 0x0024(sp)              // ~
    sw      s1, 0x0028(sp)              // ~
    sw      s0, 0x002C(sp)              // ~

    li      a1, Global.match_info       // ~ 0x800A50E8
    lw      a1, 0x0000(a1)              // a1 = match_info
    addiu   v0, a1, 0x0020              // v0 = first player match struct
    addiu   t1, v0, 0x0000              // t1 = pointer to first player struct

    lb      a1, 0x0003(a1)              // a1 = match gametype(1 = time, 2 = stock, 3 = both)
    addiu   s5, r0, 0x0000              // s5 is used to store players percent for ties
    addiu   s1, r0, 0x0000              // s1 = 0 (loop counter)

    // timed mode
    addiu   at, r0, 0x0001              // at = timed game mode
    beql    a1, at, _loop_initial       // branch if timed game mode
    addiu   a1, v0, 0x0014              // a1 = offset to KO count
    
    // stamina mode
    addiu   at, r0, 0x0005              // at = stamina game mode
    beql    a1, at, _loop_initial       // branch if stamina game mode
    addiu   a1, v0, 0x004C              // a1 = offset to HP value    

    // stock game mode
    addiu   a1, v0, 0x000B              // a1 = offset to stock count (byte)
    addiu   at, r0, 0x0004              // at = stock game mode

    _loop_initial:
    addiu   s4, at, 0x0000              // set s4 as current game mode
    addiu   s2, r0, 0x0000              // s2 = 0, used for tracking player index with highest score
    addiu   v0, r0, 0x0000              // v0 = 0, used for tracking highest score


    _get_first_place_player:
    addiu   at, r0, 0x0005              // at = stamina mode
    beql    s4, at, _check_if_greater   // branch if s4 = stamina mode
    lw      s3, 0x0000(a1)              // s3 = player score (word)

    addiu   at, r0, 0x0004              // at = stock mode
    beql    s4, at, _check_if_less      // branch if s4 = stock mode
    lb      s3, 0x0000(a1)              // s3 = player score (byte)

    lw      s3, 0x0000(a1)              // if not stamina or stock mode
    b       _check_if_less
    nop
    
    _check_if_greater:
    beqz    s1, _apply                  // apply if this is the first iteration of the loop
    nop
    bge     s3, v0, _increment_loop     // skip if hp is greater than players in first
    nop

    lw      at, 0x0058(t1)              // at = player pointer. (if = 0, then we need to skip this port)
    beqz    at, _increment_loop         // skip if value = 0 (stamina max hp)
    nop
    b       _continue
    nop

    _check_if_less:
    beqz    s1, _apply                  // apply if this is the first iteration of the loop
    nop
    blt     s3, v0, _increment_loop     // skip if score is less than player in first
    nop
    lw      at, 0x0058(t1)              // at = player pointer. (if = 0, then we need to skip this port)
    beqz    at, _increment_loop         // skip if value = 0 (stamina max hp)
    nop

    _continue:
    bne     s3, v0, _apply              // branch if the scores are not tied
    nop

    // if here, scores are tied and we need to compare percents
    lw      s6, 0x004C(t1)              // s6 = current players hp
    blt     s5, s6, _increment_loop     // skip if this players hp is greater
    nop

    _apply:
    // if here, we have a new 
    addiu   s2, s1, r0                  // s2 = player index with a higher score
    addiu   v0, s3, r0                  // v0 = current highest score
    lw      s5, 0x004C(t1)              // s5 = player percent (for dealing with ties)

    _increment_loop:
    addiu   a1, a1, 0x0074              // a1 = next players score
    addiu   t1, t1, 0x0074              // t1 = next player pointer
    addiu   s1, s1, 0x0001              // increment loop counter
    addiu   at, r0, 0x0004              // at = 4
    bne     s1, at, _get_first_place_player // loop again if counter is not 4
    nop

    // get_player_ptr:
    // s2 = port of player in first
    addiu   s3, r0, 0x0000              // s3 = 0
    addiu   s4, r0, 0x0004              // s4 = port 5

    _target_loop:
    beq     s3, s4, _end_target_loop    // end loop if index = 5
    nop

    // check if player port matches the one in first
    lw      a1, 0x0084(s0)              // a1 = pointer to player struct
    lb      a1, 0x000C(a1)              // a1 = player port
    beql    a1, s2, _end_target_loop    // end loop if we found the player in first
    nop
    
    lw      s1, 0x0004(s0)              // s1 = next player ptr
    beqz    s1, _end_target_loop        // end loop if player is invalid
    nop

    lw      s0, 0x0004(s0)              // s0 = next player ptr
    b       _target_loop                // loop
    addiu   s3, s3, 0x0001              // s3 += 1

    _end_target_loop:
    addiu   at, s0, 0x0000               // at = player in first

    lw      a1, 0x0004(sp)               // restore registers
    lw      v0, 0x0008(sp)               // ~
    lw      s2, 0x000C(sp)               // ~
    lw      s3, 0x0010(sp)               // ~
    lw      s4, 0x0014(sp)               // ~
    lw      s5, 0x0018(sp)               // ~
    lw      s6, 0x0020(sp)               // ~
    lw      t1, 0x0024(sp)               // ~
    lw      s1, 0x0028(sp)               // ~
    lw      s0, 0x002C(sp)               // ~
    jr      ra
    addiu   sp, sp, 0x38                 // deallocate sp
}
