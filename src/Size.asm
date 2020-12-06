// Size.asm
if !{defined __SIZE__} {
define __SIZE__()
print "included Size.asm\n"

include "Global.asm"

scope Size {
    // shoutout Isotarge (https://github.com/Isotarge/ScriptHawk/blob/master/games/smash64.lua)
    
    // @ Description
    // Size multipliers
    multiplier_table:
    float32 1, 1, 1, 1                      // custom multiplier for p1 through p4

    base_multiplier_table:
    float32 1, 1, 1, 1                      // clone of body size multiplier for p1 through p4, only useful for Kirby

    // @ Description
    // Additional multipliers for attributes that make sense to change when size changes.
    // The formula will be:
    //  x = 1 + m * (s - 1)
    // where:
    //  - x: desired multiplier
    //  - m: values below
    //  - s: size multiplier from multiplier_table
    walking_speed_multiplier:;              float32 0.45
    brake_force_multiplier:;                float32 -0.04712
    dashing_speed_multiplier:;              float32 0.4
    dash_decel_multiplier:;                 float32 0.45172
    running_speed_multiplier:;              float32 0.36664
    jumping_height_multiplier:;             float32 0.3234
    base_jumping_height_multiplier:;        float32 0.0727
    second_jumping_height_multiplier:;      float32 0.0395604

    // @ Description
    // Adjusts the height of the player label.
    scope adjust_player_label_: {
        OS.patch_start(0x8D304, 0x80111B04)
        jal     adjust_player_label_
        lwc1    f10, 0x0098(t1)             // original line 1
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(v1)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f16, 0x0000(t0)             // f16 = multiplier
        mul.s   f10, f10, f16               // f10 = multiplier * height

        jr      ra
        add.s   f16, f8, f10                // original line 2
    }
    
    // @ Description
    // Provides player with passive armor. Passive armor is typically set as a character is initially loaded in a match at 0x07E4 in their struct.
    // This functions by having the routine that reads this location check if the multiplier is above 1, if so, it sets passive armor to 48 (same as GDK)
    scope passive_armor_: {
        OS.patch_start(0x61B24, 0x800E6324)
        jal     passive_armor_
        lwc1    f12, 0x07E4(s0)             // original line 1 (loads passive armor amount)
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(s0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f0, 0x0000(t0)              // f0 = multiplier
        lui     t1, 0x3f80                  // t1= 1
        mtc1    t1, f2
        c.le.s  f0, f2
        bc1f    _set_armor
        lwc1    f0, 0x07E0(s0)              // original line 2
        jr      ra
        lwc1    f2, 0x07E8(s0)              // refresh f2

        _set_armor:
        lui     t1, 0x4240
        mtc1    t1, f2
        add.s   f12, f12, f2
        jr      ra
        lwc1    f2, 0x07E8(s0)              // refresh f2
    }

    // @ Description
    // Modifies the ECB when displayed.
    scope adjust_ecb_display_: {
        OS.patch_start(0x6E804, 0x800F3004)
        jal     adjust_ecb_display_._lower_y
        lwc1    f16, 0x00A4(t6)             // original line 1
        OS.patch_end()

        OS.patch_start(0x6E858, 0x800F3058)
        jal     adjust_ecb_display_._center_y_and_width
        lwc1    f8, 0x00A0(t5)              // original line 1
        OS.patch_end()

        OS.patch_start(0x6E8F0, 0x800F30F0)
        jal     adjust_ecb_display_._center_y
        lwc1    f18, 0x00A0(t3)             // original line 1
        OS.patch_end()

        OS.patch_start(0x6E948, 0x800F3148)
        jal     adjust_ecb_display_._center_y_upper_y_and_width
        lwc1    f10, 0x009C(t7)             // original line 1
        OS.patch_end()

        _lower_y:
        li      a2, multiplier_table        // a2 = multiplier_table
        lbu     a1, 0x000D(s8)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = index = port * 4
        addu    a1, a2, a1                  // a1 = &multiplier_table[index]
        lwc1    f10, 0x0000(a1)             // f10 = multiplier
        mul.s   f16, f16, f10               // f16 = multiplier * lower_y

        jr      ra
        or      s3, a0, r0                  // original line 2

        _center_y_and_width:
        lwc1    f4, 0x00A8(t5)              // original line 2
        li      a2, multiplier_table        // a2 = multiplier_table
        lbu     a1, 0x000D(s8)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = index = port * 4
        addu    a1, a2, a1                  // a1 = &multiplier_table[index]
        lwc1    f10, 0x0000(a1)             // f10 = multiplier
        mul.s   f8, f8, f10                 // f8 = multiplier * upper_y
        mul.s   f4, f4, f10                 // f4 = multiplier * width

        jr      ra
        nop

        _center_y:
        li      a2, multiplier_table        // a2 = multiplier_table
        lbu     a1, 0x000D(s8)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = index = port * 4
        addu    a1, a2, a1                  // a1 = &multiplier_table[index]
        lwc1    f16, 0x0000(a1)             // f16 = multiplier
        mul.s   f18, f18, f16               // f16 = multiplier * center_y

        jr      ra
        or      s3, a0, r0                  // original line 2

        _center_y_upper_y_and_width:
        lwc1    f6, 0x00A8(t7)              // original line 2
        li      a2, multiplier_table        // a2 = multiplier_table
        lbu     a1, 0x000D(s8)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = index = port * 4
        addu    a1, a2, a1                  // a1 = &multiplier_table[index]
        lwc1    f18, 0x0000(a1)             // f18 = multiplier
        mul.s   f10, f10, f18               // f10 = multiplier * upper_y
        mul.s   f16, f16, f18               // f16 = multiplier * center_y
        mul.s   f6, f6, f18                 // f6 = multiplier * width

        jr      ra
        nop
    }

    // @ Description
    // Adjusts top joint, ECB and ledge grab box used for calculating collisions.
    // Modifying the top joint's scale is fine except for Kirby's aerial up special, which must be accounted for.
    // As far as I can tell, modifying the ECB is fine.
    scope adjust_top_joint_and_ecb_: {
        OS.patch_start(0x5D868, 0x800E2068)
        jal     adjust_top_joint_and_ecb_
        addiu   t9, s1, 0x0080              // original line 1
        OS.patch_end()

        // s1 = player struct
        li      t8, multiplier_table        // t8 = multiplier_table
        lbu     t3, 0x000D(s1)              // t3 = port
        sll     t3, t3, 0x0002              // t3 = index = port * 4
        addu    t2, t8, t3                  // t2 = &multiplier_table[index]
        lwc1    f20, 0x0000(t2)             // f20 = multiplier

        // Rather than pull from player constants, use our cloned body size table.
        // This table is updated for the big Kirby glitch.
        li      t8, base_multiplier_table   // t8 = base_multiplier_table
        addu    t2, t8, t3                  // t2 = &base_multiplier_table[index]
        lwc1    f0, 0x0000(t2)              // f0 = body size multiplier

        // apply custom body size multiplier
        mul.s   f0, f0, f20                 // f0 = body size multiplier, adjusted
        lw      t3, 0x08E8(s1)              // t3 = top joint pointer
        swc1    f0, 0x0040(t3)              // update top joint x scale
        swc1    f0, 0x0044(t3)              // update top joint y scale
        swc1    f0, 0x0048(t3)              // update top joint z scale

        // modify ECB
        lw      t8, 0x09C8(s1)              // t8 = player constants struct
        lwc1    f0, 0x009C(t8)              // f0 = ecb upper y height
        mul.s   f0, f0, f20                 // f0 = ecb upper y height, adjusted
        swc1    f0, 0x00B0(s1)              // update ecb upper y height
        lwc1    f0, 0x00A0(t8)              // f0 = ecb center y height
        mul.s   f0, f0, f20                 // f0 = ecb center y height, adjusted
        swc1    f0, 0x00B4(s1)              // update ecb center y height
        lwc1    f0, 0x00A4(t8)              // f0 = ecb lower y height
        mul.s   f0, f0, f20                 // f0 = ecb lower y height, adjusted
        swc1    f0, 0x00B8(s1)              // update ecb lower y height
        lwc1    f0, 0x00A8(t8)              // f0 = ecb width
        mul.s   f0, f0, f20                 // f0 = ecb width, adjusted
        swc1    f0, 0x00BC(s1)              // update ecb width
        lwc1    f0, 0x00AC(t8)              // f0 = ledge grab x
        mul.s   f0, f0, f20                 // f0 = ledge grab x, adjusted
        swc1    f0, 0x00C4(s1)              // update ledge grab x
        lwc1    f0, 0x00B0(t8)              // f0 = ledge grab y
        mul.s   f0, f0, f20                 // f0 = ledge grab y, adjusted
        swc1    f0, 0x00C8(s1)              // update ledge grab y

        jr      ra
        sw      t9, 0x002C(sp)              // original line 2
    }

    // @ Description
    // Address Kirby aerial up special, the only known move to change body size multiplier.
    scope kirby_ausp_: {
        OS.patch_start(0xDB974, 0x80160F34)
        jal     kirby_ausp_._first
        lwc1    f4, 0xC9C0(at)              // original line 1 - Kirby's custom multiplier
        OS.patch_end()
        OS.patch_start(0xDB9A0, 0x80160F60)
        jal     kirby_ausp_._second
        mtc1    at, f6                      // original line 1 - Kirby's custom multiplier (hard-coded to 1.0)
        OS.patch_end()

        _first:
        // s0 = player struct
        li      t6, multiplier_table        // t6 = multiplier_table
        lbu     t7, 0x000D(s0)              // t7 = port
        sll     t7, t7, 0x0002              // t7 = index = port * 4
        addu    t6, t6, t7                  // t6 = &multiplier_table[index]
        lwc1    f0, 0x0000(t6)              // f0 = multiplier

        li      t6, base_multiplier_table   // t6 = base_multiplier_table
        addu    t6, t6, t7                  // t6 = &base_multiplier_table[index]
        swc1    f4, 0x0000(t6)              // update our cloned body size multiplier

        mul.s   f4, f4, f0                  // f4 = Kirby's custom multiplier, adjusted

        jr      ra
        lw      t6, 0x08E8(s0)              // original line 2

        _second:
        // s0 = player struct
        li      t6, multiplier_table        // t6 = multiplier_table
        lbu     t7, 0x000D(s0)              // t7 = port
        sll     t7, t7, 0x0002              // t7 = index = port * 4
        addu    t6, t6, t7                  // t6 = &multiplier_table[index]
        lwc1    f0, 0x0000(t6)              // f0 = multiplier

        li      t6, base_multiplier_table   // t6 = base_multiplier_table
        addu    t6, t6, t7                  // t6 = &base_multiplier_table[index]
        swc1    f6, 0x0000(t6)              // update our cloned body size multiplier

        mul.s   f6, f6, f0                  // f6 = Kirby's custom multiplier, adjusted

        jr      ra
        lw      t8, 0x08E8(s0)              // original line 2
    }

    // @ Description
    // Populates our base multiplier table when initializing the character.
    // This enables us to update it for the big Kirby glitch.
    scope initialize_base_multiplier_table_: {
        OS.patch_start(0x534B4, 0x800D7CB4)
        jal     initialize_base_multiplier_table_
        lwc1    f0, 0x0000(a2)              // original line 1 - body size multiplier
        OS.patch_end()

        // v1 = player struct
        li      t4, base_multiplier_table   // t4 = base_multiplier_table
        lbu     t9, 0x000D(v1)              // t9 = port
        sll     t9, t9, 0x0002              // t9 = index = port * 4
        addu    t4, t4, t9                  // t4 = &base_multiplier_table[index]
        swc1    f0, 0x0000(t4)              // update our cloned body size multiplier

        jr      ra
        addiu   a2, v1, 0x00F0              // original line 2
    }

    // @ Description
    // Scales size by given amount
    // @ Arguments
    // a0 - player
    // a1 - scaler
    scale_size_by_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      f0, 0x0010(sp)              // save registers
        
        li      t1, multiplier_table        // t2 = &multiplier_table[0]
        sll     t2, a0, 0x0002              // t2 = player_index
        addu    t1, t1, t2                  // t2 = &multiplier_table[player]

        mtc1    a1, f0                      // f0 = scaler
        lwc1    f2, 0x0000(t1)              // f2 = multiplier_table[player]
        mul.s   f0, f0, f2                  // f0 = scaler * multiplier_table[player]
        swc1    f0, 0x0000(t1)              // update size modifier
        
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      f0, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // dllocate stack space
        jr      ra
        nop
    }

    // @ Arguments
    // a0 - player
    reset_size_: {
        OS.save_registers()
        li      t0, multiplier_table
        li      t1, 0x3F800000              // float 1.0
        sll     t2, a0, 0x0002              // player * 4
        addu    t0, t0, t2
        sw      t1, 0x0000(t0)              // ~
        OS.restore_registers()
        jr      ra
        nop
    }

    macro adjust_hitbox(fpr) {
        // allocate
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        swc1    f0, 0x0010(sp)              // save t0 - t2, f0

        // get multiplier from port
        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(a0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t1 = &multiplier_table[index]
        lwc1    f0, 0x0000(t0)              // f0 = multiplier

        // this line changes
        cvt.s.w {fpr}, {fpr}                // {fpr} = (float) {fpr}
        mul.s   {fpr}, {fpr}, f0            // {fpr} = {fpr} * multiplier
        trunc.w.s {fpr}, {fpr}              // {fpr} = (int) {fpr}

        // deallocate
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lwc1    f0, 0x0010(sp)              // save t0 - t2, f0
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // The following patches change the size and location of hitboxes
    // based on an additional Smash Remix body size multiplier.
    // @ Note
    // Changing x/y/z positions does not help but the code remains for
    // documentation purposes
    scope fix_size_: {
        OS.patch_start(0x5AB94, 0x800DF394)
        j       fix_size_
        nop
        _return:
        OS.patch_end()

        lhu     t9, 0x0000(t6)              // t9 = size        (original line 1)
        mtc1    t9, f16                     // f16 = (int) size (original line 2)
        adjust_hitbox(f16)
        j       _return                     // return
        nop   
    }

    scope fix_x_: {
        OS.patch_start(0x5ABC8, 0x800DF3C8)
//      j       fix_x_
//      nop
        _return:
        OS.patch_end()

        lhu     t5, 0x0002(t8)              // t5 = x       (original line 1)
        mtc1    t5, f8                      // f8 = (int) x (original line 2)
        adjust_hitbox(f8)
        j       _return                     // return
        nop   
    }

    scope fix_y_: {
        OS.patch_start(0x5ABE8, 0x800DF3E8)
//      j       fix_y_
//      nop
        _return:
        OS.patch_end()

        lhu     t8, 0x0000(t7)              // t8 = y        (original line 1)
        mtc1    t8, f10                     // f10 = (int) y (original line 2)
        adjust_hitbox(f10)
        j       _return                     // return
        nop   
    }

    scope fix_z_: {
        OS.patch_start(0x5AC00, 0x800DF400)
//      j       fix_z_
//      nop
        _return:
        OS.patch_end()

        lhu     t6, 0x0002(t5)              // t6 = z       (original line 1)
        mtc1    t6, f6                      // f6 = (int) z (original line 2)
        adjust_hitbox(f6)
        j       _return                     // return
        nop   
    }
    
    // @ Description
    // The following patches change the amount of damage a hitbox does
    // based on an additional Smash Remix body size multiplier.
    scope fix_damage_: {
        OS.patch_start(0x5AB4C, 0x800DF34C)
        j       fix_damage_
        lbu     t8, 0x000D(a0)              // t8 = port
        _return:
        OS.patch_end()
        
        li      t9, multiplier_table        // t9 = multiplier_table
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    t9, t9, t8                  // t9 = &multiplier_table[index]
        lwc1    f16, 0x0000(t9)             // f16 = multiplier
        lui     t8, 0x3f80                  // t1= 1
        mtc1    t8, f6
        c.eq.s  f16, f6                     // compare multiplier against 1
        bc1t    _end                        // if multiplier is equal to 1 (standard size), jump to end
        nop        
        c.le.s  f16, f6                     // if multiplier is less than 1, jump to poison branch
        bc1t    _poison
        lui     t8, 0x3f33                  // load hitbox damage multiplier for poison (0.7 in floating point)
        lui     t8, 0x3fa6                  // load hitbox damage multiplier for giant (1.3 in floating point)

        _poison:
        mtc1    t7, f6                      // convert standard damage amount to floating point
        mtc1    t8, f16                     // move multiplier to floatinig point
        cvt.s.w f6, f6                      // convert damage (int) to floating point
        mul.s   f6, f16, f6                 // multiply normal damage amount by multiplier
        cvt.w.s f6, f6                      // convert enhanced damage amount to integer
        j       _end
        mfc1    t7, f6                      // move new damage amount to t7
        
        _end:
        lw      t8, 0x0004(s0)              // original line 2
        j       _return                     // return
        sw      t7, 0x000C(t0)              // original line 1, saves damage to hitbox struct   
    }

    // Additional attributes

    // @ Description
    // Adjusts player walking speed and brake force.
    scope adjust_player_walking_speed_: {
        OS.patch_start(0x54274, 0x800D8A74)
        j       adjust_player_walking_speed_
        mtc1    a1, f12                     // original line 1 moves walking speed to floating point register
        _return:
        OS.patch_end()
 
        mtc1    a2, f14                     // original line 2 moves brake force to floating point register

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(a0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f4, 0x0000(t0)              // f4 = size multiplier (s)
        lui     t0, 0x3F80                  // t0 = 1
        mtc1    t0, f2                      // f2 = 1
        sub.s   f4, f4, f2                  // f4 = s - 1

        li      t0, walking_speed_multiplier
        lwc1    f6, 0x0000(t0)              // f6 = walking speed multiplier (m)
        mul.s   f6, f6, f4                  // f6 = m * (s - 1)
        add.s   f6, f2, f6                  // f6 = multiplier = 1 + m * (s - 1)
        mul.s   f12, f12, f6                // f12 = multiplier * walking speed

        li      t0, brake_force_multiplier
        lwc1    f6, 0x0000(t0)              // f4 = brake force multiplier (m)
        mul.s   f6, f6, f4                  // f6 = m * (s - 1)
        add.s   f6, f2, f6                  // f6 = multiplier = 1 + m * (s - 1)
        mul.s   f14, f14, f6                // f14 = multiplier * brake force

        j       _return
        nop
    }

    // @ Description
    // Adjusts initial dash speed.
    scope adjust_player_initial_dash_speed_: {
        OS.patch_start(0xB9780, 0x8013ED40)
        jal     adjust_player_initial_dash_speed_
        lwc1    f4, 0x0028(t6)              // original line 1 moves initial dash speed to f4
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(v0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f2, 0x0000(t0)              // f2 = size multiplier (s)
        lui     t0, 0x3F80                  // t0 = 1
        mtc1    t0, f8                      // f8 = 1
        sub.s   f2, f2, f8                  // f2 = s - 1

        li      t0, dashing_speed_multiplier
        lwc1    f6, 0x0000(t0)              // f6 = initial dash speed multiplier (m)
        mul.s   f6, f6, f2                  // f6 = m * (s - 1)
        add.s   f6, f8, f6                  // f6 = multiplier = 1 + m * (s - 1)
        mul.s   f4, f4, f6                  // f4 = multiplier * initial dash speed

        jr      ra
        sb      t7, 0x0268(v0)              // original line 2
    }

    // @ Description
    // Adjusts dash deceleration.
    scope adjust_player_dash_deceleration_: {
        OS.patch_start(0x5417C, 0x800D897C)
        j       adjust_player_dash_deceleration_
        mtc1    a1, f12                     // original line 2 moves dash deceleration to f12
        _return:
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(a0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f4, 0x0000(t0)              // f4 = size multiplier (s)
        lui     t0, 0x3F80                  // t0 = 1
        mtc1    t0, f8                      // f8 = 1
        sub.s   f4, f4, f8                  // f4 = s - 1

        li      t0, dash_decel_multiplier
        lwc1    f6, 0x0000(t0)              // f6 = dash deceleration multiplier (m)
        mul.s   f6, f6, f4                  // f6 = m * (s - 1)
        add.s   f6, f8, f6                  // f6 = multiplier = 1 + m * (s - 1)
        mul.s   f12, f12, f6                // f12 = multiplier * dash deceleration

        j       _return
        lwc1    f0, 0x0060(a0)              // original line 1
    }

    // @ Description
    // Adjusts running speed.
    scope adjust_player_running_speed_: {
        OS.patch_start(0xB9954, 0x8013EF14)
        jal     adjust_player_running_speed_
        lwc1    f4, 0x0030(t6)              // original line 1 moves running speed to f4
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(v0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f2, 0x0000(t0)              // f2 = size multiplier (s)
        lui     t0, 0x3F80                  // t0 = 1
        mtc1    t0, f8                      // f8 = 1
        sub.s   f2, f2, f8                  // f2 = s - 1

        li      t0, running_speed_multiplier
        lwc1    f6, 0x0000(t0)              // f6 = running speed multiplier (m)
        mul.s   f6, f6, f2                  // f6 = m * (s - 1)
        add.s   f6, f8, f6                  // f6 = multiplier = 1 + m * (s - 1)
        mul.s   f4, f4, f6                  // f4 = multiplier * running speed

        jr      ra
        swc1    f4, 0x0060(v0)              // original line 2
    }
	
	// @ Description
    // Adjusts jump squat.
    scope adjust_player_jump_squat_: {
        OS.patch_start(0xB9D48, 0x8013F308)
        j      adjust_player_jump_squat_
        nop
        _return:
        OS.patch_end()

        li      t0, multiplier_table        // t0 = multiplier_table
        lbu     t1, 0x000D(v0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t0, t0, t1                  // t0 = &multiplier_table[index]
        lwc1    f4, 0x0000(t0)              // f4 = multiplier
        lui     t1, 0x3f80                  // t1= 1
        mtc1    t1, f6
        c.le.s  f4, f6
        bc1t    _end
        lwc1    f4, 0x0034(v1)              // original line 1
		add.s	f4, f4, f6					// add 1 frame to jump squat for giant characters
        
        _end:
        j       _return
        c.le.s  f4, f18                     // original line 2
   // }
	
	// @ Description
    // Adjusts jumping height multiplier and base jumping height for first jump.
    scope adjust_jumping_height_multiplier_1: {
        OS.patch_start(0xBA38C, 0x8013F94C)
        jal     adjust_jumping_height_multiplier_1
        lwc1	f16, 0x003C(v0)				// original line 1 (jumping height multiplier)
        OS.patch_end()

        li      t8, multiplier_table        // t8 = multiplier_table
        lbu     t1, 0x000D(s0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = index = port * 4
        addu    t8, t8, t1                  // t8 = &multiplier_table[index]
        lwc1    f6, 0x0000(t8)              // f6 = size multiplier (s)
        lui     t8, 0x3F80                  // t8 = 1
        mtc1    t8, f18                     // f18 = 1
        sub.s   f6, f6, f18                 // f6 = s - 1

        li      t8, jumping_height_multiplier
        lwc1    f10, 0x0000(t8)             // f10 = size jumping height multiplier (m)
        mul.s   f10, f10, f6                // f10 = m * (s - 1)
        add.s   f10, f18, f10               // f10 = multiplier = 1 + m * (s - 1)
        mul.s   f16, f16, f10               // f16 = multiplier * jumpin height multiplier
        lwc1    f4, 0x0040(v0)              // original line 2, base jumping height
        li      t8, base_jumping_height_multiplier
        lwc1    f10, 0x0000(t8)             // f10 = size base jumping height multiplier (m)
        mul.s   f10, f10, f6                // f10 = m * (s - 1)
        add.s   f10, f18, f10               // f10 = multiplier = 1 + m * (s - 1)
        
        jr      ra
        mul.s   f4, f4, f10                 // f4 = multiplier * base jumpin height multiplier
        
    }

	// @ Description
    // Adjusts jumping height multiplier and base jumping height for second jump.
    scope adjust_jumping_height_multiplier_2: {
        OS.patch_start(0xBA8A4, 0x8013FE64)
        jal     adjust_jumping_height_multiplier_2
        lbu     t6, 0x000D(s0)              // t6 = port
        OS.patch_end()

        li      at, multiplier_table        // at = multiplier_table
        sll     t6, t6, 0x0002              // t1 = index = port * 4
        addu    at, at, t6                  // at = &multiplier_table[index]
        lwc1    f6, 0x0000(at)              // f6 = size multiplier (s)
        lui     at, 0x3F80                  // at = 1
        mtc1    at, f18                     // f18 = 1
        sub.s   f6, f6, f18                 // f6 = s - 1

        // jumping height multiplier
        li      at, jumping_height_multiplier
        lwc1    f10, 0x0000(at)             // f10 = size running speed multiplier (m)
        mul.s   f10, f10, f6                // f10 = m * (s - 1)
        add.s   f10, f18, f10               // f10 = multiplier = 1 + m * (s - 1)
        mul.s   f16, f16, f10               // f16 = multiplier * jumpin height multiplier
        
        
        // base jumping height
        li      at, base_jumping_height_multiplier
        lwc1    f10, 0x0000(at)             // f10 = size base jumping height multiplier (m)
        mul.s   f10, f10, f6                // f10 = m * (s - 1)
        add.s   f10, f18, f10               // f10 = multiplier = 1 + m * (s - 1)
        mul.s   f4, f4, f10                 // f4 = multiplier * base jumpin height multiplier
        
        // 2nd jump multiplier
        li      at, second_jumping_height_multiplier
        lwc1    f10, 0x0000(at)             // f10 = size 2nd jumping height multiplier (m)
        mul.s   f10, f10, f6                // f10 = m * (s - 1)
        add.s   f6, f18, f10                // f6 = multiplier = 1 + m * (s - 1)
        cvt.s.w f10, f8                     // original line 1
        lwc1    f8, 0x0048(t0)              // original line 2, load 2nd jump multiplier
        
        jr      ra
        mul.s   f8, f8, f6                  // f8 = multiplier * 2nd jumpin height multiplier
    }
    
    // @ Description
    // Adjusts jumping height multiplier and base jumping height for kirby second jump.
    scope adjust_jumping_height_multiplier_kirby: {
        OS.patch_start(0xBAA54, 0x80140014)
        jal     adjust_jumping_height_multiplier_kirby
        lbu     t3, 0x000D(s0)              // t3 = port
        OS.patch_end()

        li      at, multiplier_table        // at = multiplier_table
        sll     t3, t3, 0x0002              // t3 = index = port * 4
        addu    at, at, t3                  // at = &multiplier_table[index]
        lwc1    f6, 0x0000(at)              // f6 = size multiplier (s)
        lui     at, 0x3F80                  // at = 1
        mtc1    at, f10                     // f10 = 1
        sub.s   f6, f6, f10                 // f6 = s - 1

        // jumping height multiplier
        li      at, jumping_height_multiplier
        lwc1    f18, 0x0000(at)             // f18 = size running speed multiplier (m)
        mul.s   f18, f18, f6                // f18 = m * (s - 1)
        add.s   f18, f10, f18               // f18 = multiplier = 1 + m * (s - 1)
        mul.s   f4, f4, f18                 // f4 = multiplier * jumpin height multiplier
        
        
        // base jumping height
        li      at, base_jumping_height_multiplier
        lwc1    f18, 0x0000(at)             // f18 = size base jumping height multiplier (m)
        mul.s   f18, f18, f6                // f18 = m * (s - 1)
        add.s   f18, f10, f18               // f18 = multiplier = 1 + m * (s - 1)
        mul.s   f8, f8, f18                 // f8 = multiplier * base jumpin height multiplier
        
        // 2nd jump multiplier
        li      at, second_jumping_height_multiplier
        lwc1    f18, 0x0000(at)             // f18 = size 2nd jumping height multiplier (m)
        mul.s   f18, f18, f6                // f18 = m * (s - 1)
        add.s   f6, f10, f18                // f6 = multiplier = 1 + m * (s - 1)
        cvt.s.w f18, f16                    // original line 1
        lwc1    f16, 0x0048(t0)             // original line 2, load 2nd jump multiplier
        
        jr      ra
        mul.s   f16, f16, f6                  // f8 = multiplier * 2nd jumpin height multiplier
    }
    
}

} // __SIZE__
