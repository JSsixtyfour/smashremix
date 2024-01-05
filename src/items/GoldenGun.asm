// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_item)
constant PICKUP_ITEM_INIT(0x801755FC)   // copied raygun
constant DROP_ITEM(0x80175780)          // copied raygun
constant THROW_ITEM(0x801756AC)         // copied raygun
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xFC0)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file
dw FILE_OFFSET                          // 0x08 - offset to item footer in file
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
dw 0x801754F0                           // 0x14 - ? spawn behavior? (using Maxim Tomato)
dw 0x80175550                           // 0x18 - ? ground collision? (using Maxim Tomato)
dw 0                                    // 0x1C - ?
dw 0, 0, 0, 0                           // 0x20 - 0x2C - ?

// @ Description
// Item state table
item_state_table:
// STATE 0 - PREPICKUP - GROUNDED
dw 0                                    // 0x00
dw 0x80175528                           // 0x04 grounded
dw 0                                    // 0x08
dw 0                                    // 0x0C
dw 0, 0, 0, 0                           // 0x10 - 0x1C

// STATE 1 - PREPICKUP - AERIAL
dw 0x801744C0                           // 0x20 (using Maxim Tomato)
dw 0x80174524                           // 0x24 (using Maxim Tomato)
dw 0, 0                                 // 0x28 - 0x2C
dw 0, 0, 0, 0                           // 0x30 - 0x3C

constant AMMO_COUNT(1)
constant PROJECTILE_DAMAGE(99)
constant KNOCKBACK_1(45)                // 
constant KNOCKBACK_2(0)                 // fixed
constant KNOCKBACK_3(130)               // base kb
constant KNOCKBACK_ANGLE(7)
constant PROJECTILE_SPEED(0x4396)       // 300
constant FRAME_SPEED_MULTIPLIER(0x3F00) // 0.5
constant ON_HIT_FGM(FGM.item.BAT)       // on hit fgm
constant PROJECTILE_ID(0x1009)

// @ Description
// I copied the original routine for raygun and modified it
scope stage_setting_: {
    addiu      sp, sp, -0x28
    sw         a2, 0x0030(sp)
    sw         a3, 0x0034(sp)
    lw         t6, 0x0034(sp)
    or         a2, a1, r0
    sw         a1, 0x002c(sp)
    sw         ra, 0x001c(sp)
    lw         a3, 0x0030(sp)
    li         a1, item_info_array
    jal        0x8016e174
    sw         t6, 0x0010(sp)
    beqz       v0, _end
    or         v1, v0, r0
    lw         a0, 0x0084(v0)
    addiu      t7, r0, AMMO_COUNT
    sh         t7, 0x033E(a0)       // save initial ammo count
    sw         v0, 0x0024(sp)
    jal        0x80018910
    sw         a0, 0x0020(sp)
    andi       t8, v0, 0x0001
    lw         v1, 0x0024(sp)
    beqz       t8, _branch
    lw         a0, 0x0020(sp)
    lui        at, 0x8019
    lwc1       f4, 0xcd00(at)
    lw         t9, 0x0074(v1)
    b          _branch_2
    swc1       f4, 0x0034(t9)
   
    _branch:   
    lui        at, 0x8019
    lwc1       f6, 0xcd04(at)
    lw         t0, 0x0074(v1)
    swc1       f6, 0x0034(t0)
   
    _branch_2: 
    lbu        t2, 0x02d3(a0)
    ori        t3, t2, 0x0004
    sb         t3, 0x02d3(a0)
    sw         a0, 0x0020(sp)
    jal        0x80111ec0
    sw         v1, 0x0024(sp)
    lw         a0, 0x0020(sp)
    lw         v1, 0x0024(sp)
    sw         v0, 0x0348(a0)
    _end:  
    lw         ra, 0x001c(sp)
    addiu      sp, sp, 0x28
   
    jr         ra
    or         v0, v1, r0   

}


// @ Description
// Main item pickup routine for cloaking device.
scope pickup_item: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

OS.align(16)
golden_bullet_projectile_struct:
dw 0x00000000              // unknown
dw PROJECTILE_ID           // projectile id
dw projectile_info_pointer // address of display / hitbox file
dw 0x00000000              // offset to hitbox
dw 0x1C000000              // Rendering routine
dw 0x801758BC              // main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
dw 0x80175914              // collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
dw 0                       // collides with a hurtbox. (og = 0x80175958)
dw 0                       // collides with a shield. (og = 0x80175958)
dw 0x80175988              // collides with edges of a shield and bounces off
dw 0                       // collides/clangs with a hitbox. (og = 0x80175958)
dw 0x80175A00              // collides with Fox's reflector (default 0x80168748)
dw 0                       // collides with Ness's psi magnet (og = 0x80175958)
dw 0, 0, 0                 // empty

OS.align(16)
projectile_info:
dw projectile_display_list
dw 0x00000000, 0x00000000, 0x00000000
dw 0x00000000, 0x0000FFFB, 0x00000000, 0x000A0000
dw 0xFFF6000A, 0x00781180, 0x0A028800, 0xF880113C
dw 0x0C800000, 0x00000000, 0x00000000, 0x00000000

OS.align(16)
// display list
projectile_display_list:
dw 0xE7000000, 0x00000000
dw 0xE2001E01, 0x00000001
dw 0xFC30FE61, 0x55FEF379
dw 0xFA000000, 0xFFFFFFFF
dw 0xFB000000, 0xFFD700FF  // set env colour to GOLD
dw 0xF9000000, 0x00000008
dw 0xF5900000, 0x07010040, 0xF5800200, 0x000D0340
dw 0xD7000002, 0xFFFFFFFF, 0xF2000000, 0x0007C07C
dw 0xFD900000, projectile_image
dw 0xE6000000, 0x00000000
dw 0xF3000000, 0x0703F800, 0xE7000000, 0x00000000
dw 0xD9FDFBFB, 0x00000000, 0x01004008, vertex_buffer
dw 0x06060402, 0x00000602, 0xE7000000, 0x00000000
dw 0xD9FFFFFF, 0x00020404, 0xE2001E01, 0x00000000
dw 0xDF000000, 0x00000000, 0x00000000, 0x00000000

OS.align(16)
// image data
projectile_image:
dw 0x00000000, 0x00000000, 0x00000000, 0x00000111
dw 0x00000000, 0x00112222, 0x00000000, 0x11223344
dw 0x00000001, 0x23344555, 0x00000012, 0x34456667
dw 0x00000123, 0x45667788, 0x00001234, 0x56788999
dw 0x00012345, 0x6789BDEF, 0x00013456, 0x78ADFFFF
dw 0x00123467, 0x8AEFFFFF, 0x00124568, 0x9DFFFFFF
dw 0x00234678, 0xBFFFFFFF, 0x01235679, 0xDFFFFFFF
dw 0x01245689, 0xEFFFFFFF, 0x01245789, 0xFFFFFFFF

OS.align(16)
// mesh data
vertex_buffer:
dw 0x00090031, 0x00000000, 0x04000400, 0xFFFFFF00
dw 0x0009FFCB, 0x00000000, 0x03FF0000, 0xFFFFFF00
dw 0xFFEBFFCB, 0x00000000, 0x00000000, 0xFFFFFF00
dw 0xFFEB0031, 0x00000000, 0x00000400, 0xFFFFFF00

projectile_info_pointer:
dw  projectile_info

scope projectile_struct_fix: {
    OS.patch_start(0xF04AC, 0x80175A6C)
    j       projectile_struct_fix
    lw      a1, 0x084C(s0)      // a1 = held item obj (temp)
    _return:
    OS.patch_end()

    // goldengun
    lw      a1, 0x0084(a1)      // a1 = held item struct
    lw      a1, 0x000C(a1)      // a1 = item id
    addiu   at, r0, Item.GoldenGun.id
    bne     at, a1, _original
    nop

    li      a1, golden_bullet_projectile_struct
    j       _return
    nop

    _original:
    lui     a1, 0x8019                  // og line 1
    j       _return
    addiu   a1, a1, 0x9c24              // og line 2

}

scope projectile_shoot_fgm_fix: {
    OS.patch_start(0xC1B74, 0x80147134)
    j       projectile_shoot_fgm_fix
    lw      a0, 0x084C(s0)      // a0 = held item obj
    _return:
    OS.patch_end()
    
    lw      a0, 0x0084(a0)      // a0 = held item struct
    lw      t0, 0x000C(a0)      // t0 = item id
    addiu   at, r0, Item.GoldenGun.id
    bnel    t0, at, _play_sfx
    addiu   a0, r0, 0x003D      // raygun shoot fgm id (og line 2)

    // goldengun set shoot fgm
    addiu   a0, r0, 0x04C2      // arg0 = goldengun shoot fgm id

    _play_sfx:
    jal     0x800269C0          // play FGM. og line 1
    nop
    j       _return             // return to og routine
    nop
}

scope projectile_properties_fix: {
    OS.patch_start(0xF04CC, 0x80175A8C)
    j       projectile_properties_fix
    lw      v0, 0x0084(v1)      // og line 1
    _return:
    OS.patch_end()
    
    lw      t0, 0x084C(s0)      // t0 = held item obj
    lw      t0, 0x0084(t0)      // t0 = held item struct
    lw      t0, 0x000C(t0)      // t0 = held item id
    addiu   at, r0, Item.GoldenGun.id
    bne     at, t0, _original   // branch if not goldengun
    nop
    
    _goldengun:    
    // set goldengun damage
    addiu   at, r0, PROJECTILE_DAMAGE // at = 100 damage
    sw      at, 0x0104(v0)      // set damage to PROJECTILE_DAMAGE
    sw      r0, 0x010C(v0)      // set damage type to normal
    addiu   at, r0, KNOCKBACK_1
    sw      at, 0x0130(v0)      // set KB1
    addiu   at, r0, KNOCKBACK_2
    sw      at, 0x0134(v0)      // set KB2
    addiu   at, r0, KNOCKBACK_3
    sw      at, 0x0138(v0)      // set KB3
    addiu   at, r0, KNOCKBACK_ANGLE
    sw      at, 0x012C(v0)
    addiu   at, r0, ON_HIT_FGM
    sh      at, 0x0146(v0)
    
    j       _return
    lui     at, PROJECTILE_SPEED // sets goldengun speed.

    _original:
    j       _return
    lui     at, 0x4396          // set raygun speed
    
}

scope projectile_no_ammo_fgm_fix: {
    OS.patch_start(0xC1BE0, 0x801471A0)
    j       projectile_no_ammo_fgm_fix
    lw      a0, 0x084C(s0)      // a0 = held item obj
    _return:
    OS.patch_end()
    
    lw      a0, 0x0084(a0)      // a0 = held item struct
    lw      t0, 0x000C(a0)      // t0 = item id
    addiu   at, r0, Item.GoldenGun.id
    bnel    t0, at, _play_sfx
    addiu   a0, r0, 0x003E      // raygun no ammo fgm id (og line 2)

    // goldengun
    addiu   a0, r0, 0x04C3      // goldengun no ammo fgm id

    _play_sfx:
    jal     0x800269C0          // play FGM. og line 1
    nop
    j       _return             // return to og routine
    nop

}

// @ Description
// 
// v1 = current item id
scope extend_grounded_shoot_item_id_check: {
    OS.patch_start(0xC22C8, 0x80147888)
    j       extend_grounded_shoot_item_id_check
    addiu   at, r0, Item.GoldenGun.id   // goldengun item id  
    OS.patch_end()

    beql    v1, at, _change_action      // branch if goldengun
    lui     a3, FRAME_SPEED_MULTIPLIER  // set fsm

    _normal:
    j       0x801478B0          // OG line 1
    sw      r0, 0x017C(s0)      // OG line 2

    _change_action:
    sw      r0, 0x017C(s0)      // OG line 2
    j       0x80147890
    addiu   t7, r0, 0x008E

}

// @ Description
// 
// v1 = current item id
scope extend_aerial_shoot_item_id_check: {
    OS.patch_start(0xC2370, 0x80147930)
    j       extend_aerial_shoot_item_id_check
    addiu   at, r0, Item.GoldenGun.id   // goldengun item id  
    OS.patch_end()

    beql    v1, at, _change_action
    lui     a3, FRAME_SPEED_MULTIPLIER  // set fsm

    _normal:
    j       0x80147958          // OG line 1
    sw      r0, 0x017C(s0)      // OG line 2

    _change_action:
    sw      r0, 0x017C(s0)      // OG line 2
    j       0x80147938
    addiu   t7, r0, 0x008F

}