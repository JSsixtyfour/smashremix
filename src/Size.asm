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
    // These state values are used to force a character into a predefined size through the match.
    // This always corresponds to the menu's values.
    // See state scope below.
    state_table:
    dw 0, 0, 0, 0                           // state for p1 through p4

    // @ Description
    // These state values are used to force a character into a predefined size through the match.
    // See state scope below.
    match_state_table:
    dw 0, 0, 0, 0                           // state for p1 through p4

    // @ Description
    // State constants
    scope state {
        constant NORMAL(0)
        constant GIANT(1)
        constant TINY(2)
    }

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
    weight_multiplier:;                     float32 -0.24

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
    // Adjusts the size of the player's shadow.
    scope adjust_player_shadow_: {
        OS.patch_start(0xB5B84, 0x8013B144)
        jal     adjust_player_shadow_
        lwc1    f2, 0x007C(t9)              // original line 1 - f2 = shadow radius
        OS.patch_end()

        // t8 - player struct

        li      a0, multiplier_table        // a0 = multiplier_table
        lbu     a1, 0x000D(t8)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = index = port * 4
        addu    a0, a0, a1                  // a0 = &multiplier_table[index]
        lwc1    f4, 0x0000(a0)              // f4 = multiplier
        mul.s   f2, f2, f4                  // f2 = multiplier * radius = new radius

        jr      ra
        mtc1    r0, f4                      // original line 2
    }

    // @ Description
    // Provides player with passive armor. Passive armor is typically set as a character is initially loaded in a match at 0x07E4 in their struct.
    // This functions by having the routine that reads this location check if the multiplier is above 1, if so, it sets passive armor to 48 (same as GDK)
    scope passive_armor_: {
        OS.patch_start(0x61B24, 0x800E6324)
        jal     passive_armor_
        lwc1    f12, 0x07E4(s0)             // original line 1 (loads passive armor amount)
        OS.patch_end()

        addiu   sp, sp, -0x0010
        sw      ra, 0x0004(sp)
        jal     Stamina.stamina_armor_fix_  // jump to code relevant to stamina and armor
        nop
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0010

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
    // This is also a good spot to set the multiplier table values.
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

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      at, 0x0004(sp)              // save registers

        // hijack this routine to clear KirbyHats.magic_hat_on and taunt_loses_power :E
        li      a2, KirbyHats.spawn_with_hat
        addu    a2, a2, t9                  // a2 = address of port's spawn_with_hat
        lw      at, 0x0000(a2)              // t6 = spawn_with_hat
        lli     a2, CharacterSelectDebugMenu.KirbyHat.MAX_VALUE - 1 // a2 = 2nd to last kirby hat entry ('???')
        bnel    at, a2, pc() + 12           // if not magic hat, then don't set to on
        lli     t6, OS.FALSE                // t6 = FALSE
        lli     t6, OS.TRUE                 // t6 = TRUE
        li      a2, KirbyHats.magic_hat_on  // a2 = magic_hat_on
        addu    a2, a2, t9                  // a2 = address of port's magic_hat_on
        sw      t6, 0x0000(a2)              // set magic_hat_on

        li      a2, KirbyHats.taunt_loses_power // a2 = taunt_loses_power
        addu    a2, a2, t9                  // a2 = address of port's taunt_loses_power
        beqzl   at, pc() + 12               // if not spawning with a hat, then set to true
        lli     t6, OS.TRUE                 // t6 = TRUE
        lli     t6, OS.FALSE                // t6 = FALSE
        sw      t6, 0x0000(a2)              // set taunt_loses_power to true if not spawning with hat

        lw      at, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        addiu   t4, t4, 0x0020              // t4 = &match_state_table[index]
        lw      t9, 0x0000(t4)              // t9 = state
        addiu   t4, t4, -0x0030             // t4 = &multiplier_table[index]
        beqzl   t9, _return                 // if in NORMAL state, use 1 as size multiplier
        lui     t9, 0x3F80                  // t9 = 1 (float)

        li      a2, Global.current_screen
        lbu     a2, 0x0000(a2)              // a2 = current screen
        lli     t6, 0x0077                  // t6 = Justin's magic screen
        beq     a2, t6, _apply              // if on Justin's magic screen, don't reset to 1
        nop
        sltiu   a2, a2, 0x003C              // a2 = 1 if not 0x3C (how to play screen id) or 0x3D (demo vs battle screen id)
        beqzl   a2, _return                 // if on how to play or demo vs battle screen, use 1 as size multiplier
        lui     t9, 0x3F80                  // t9 = 1 (float)

        _apply:
        lli     a2, state.GIANT             // a2 = GIANT
        beql    t9, a2, _return             // if in GIANT state, use giant size multiplier
        lui     t9, 0x4010                  // t9 = 2.25 (float)
        // otherwise, we're in TINY state so use tiny size multiplier
        lui     t9, 0x3F00                  // t9 = 0.5 (float)

        _return:
        sw      t9, 0x0000(t4)              // initialize size multiplier
        jr      ra
        addiu   a2, v1, 0x00F0              // original line 2
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
        lbu     t1, 0x000D(s1)              // t1 = port
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
    scope fix_size_: {
        OS.patch_start(0x5AB94, 0x800DF394)
        jal     fix_size_._create_hitbox
        lhu     t9, 0x0000(t6)              // t9 = size        (original line 1)
        OS.patch_end()

        OS.patch_start(0x5AEAC, 0x800DF6AC)
        jal     fix_size_._change_hitbox_size
        srl     t8, t7, 16                  // t8 = size        (original line 1)
        OS.patch_end()

        _create_hitbox:
        mtc1    t9, f16                     // f16 = (int) size (original line 2)
        adjust_hitbox(f16)
        jr      ra                          // return
        nop

        _change_hitbox_size:
        mtc1    t8, f8                      // f8 = (int) size (original line 2)
        adjust_hitbox(f8)
        jr      ra                          // return
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

        Toggles.read(entry_charged_smashes, t9)
        beqz    t9, _continue               // branch if charged smash attacks aren't allowed.
        // if here, charged smash attacks enabled.
        lw      t9, 0x24(s1)                // load action ID
        slti    t5, t9, Action.FSmashHigh   // t5 = 0 if actionID is => FSmashHigh
        bnez    t5, _check_item_smash       // branch if actionID is < FSmashHigh
        slti    t5, t9, Action.AttackAirN   // t5 = 0 if actionID is > DSmash
        beqz    t5, _continue               // branch if actionID is > DSmash
        nop
        b       _smash_attack
        nop
        _check_item_smash:
        lw      t5, 0x084C(s1)              // held item
        beqz    t5, _continue               // branch to end if not holding an item
        addiu   t5, r0, Action.BeamSwordSmash
        beq     t5, t9, _smash_attack
        // addiu   t5, r0, Action.BatSmash
        // beq     t5, t9, _smash_attack
        addiu   t5, r0, Action.FanSmash
        beq     t5, t9, _smash_attack
        addiu   t5, r0, Action.StarRodSmash
        bne     t5, t9, _continue     // branch if not doing a smash attack

        // if here, see if a charged smash
        _smash_attack:
        li      t9, ChargeSmashAttacks.charged_smash_fighter_array        // t9 = charged_smash_fighter_array
        sll     t5, t8, 3                   // t5 = offset in table
        addu    t9, t9, t5
        lw      t9, 0x0000(t9)              // load charged smash value

        beqz    t9, _continue               // continue normally if not a charged smash
        nop

        // if here, multiply damage amount by charged smash multiplier
        mtc1    t9, f14                     // move charge smash amount to fp
        cvt.s.w f14, f14                    // convert to fp
        li      t9, 0x3BDA740E              // t9 = 0.4 / 60
        mtc1    t9, f16                     // move to fp
        mul.s   f16, f14, f16               // f16 = charge time * 0.4
        lui     t9, 0x3F80
        mtc1    t9, f14                     // f14 = 1.0
        add.s   f16, f14, f16               // f16 = charged smash damage multiplier.
        mtc1    t7, f6                      // ~
        cvt.s.w f6, f6                      // f6 = current damage amount (fp)
        nop
        mul.s   f6, f6, f16                 // multiply current damage by charged smash multiplier
        nop
        cvt.w.s f6, f6                      // f6 = current damage amount (fp)
        nop

        mfc1    t7, f6                      // replace current damage value

        _continue:
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        li      t9, multiplier_table        // t9 = multiplier_table
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
        add.s   f4, f4, f6                  // add 1 frame to jump squat for giant characters

        _end:
        j       _return
        c.le.s  f4, f18                     // original line 2
    }

    // @ Description
    // Adjusts jumping height multiplier and base jumping height for first jump.
    scope adjust_jumping_height_multiplier_1: {
        OS.patch_start(0xBA38C, 0x8013F94C)
        jal     adjust_jumping_height_multiplier_1
        lwc1    f16, 0x003C(v0)             // original line 1 (jumping height multiplier)
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
        mul.s   f8, f8, f6                  // f8 = multiplier * 2nd jumping height multiplier

        // adjust height of pwing jumps
        _check_pwing:
        // s0 = player struct
        lbu     t6, 0x000D(s0)              // t6 = port
        li      at, Item.Pwing.pwing_jump_flag
        addu    at, at, t6                  // at = address of pwing jump flag for this player
        lb      at, 0x0000(at)              // at = 1 if we are currently jumping with pwing
        beqz    at, _end                    // branch accordingly
        nop

        li      at, 0x3F4CCCCD              // at = 0.8
        mtc1    at, f6                      // f6 = 0.8
        mul.s   f8, f8, f6                  // f8 = multiplier * 2nd jumping height multiplier

        _end:
        jr      ra
        nop
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


    // @ Description
    // Adjusts weight for knockbacks from player's normals and such.
    scope adjust_player_weight_1: {
        OS.patch_start(0x5F788, 0x800E3F88)
        j       adjust_player_weight_1
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s5)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(s7)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 2, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight. Used by Projectiles.
    scope adjust_player_weight_2: {
        OS.patch_start(0x5F920, 0x800E4120)
        j       adjust_player_weight_2
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s5)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(s7)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 2, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight. Used by items.
    scope adjust_player_weight_3: {
        OS.patch_start(0x5FA44, 0x800E4244)
        j       adjust_player_weight_3
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s5)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(s7)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 2, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight for tornado, stage hazards.
    scope adjust_player_weight_4: {
        OS.patch_start(0xBE770, 0x80143D30)
        j       adjust_player_weight_4
        sw      t4, 0x001C(sp)              // original line 2
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s0)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(t3)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 3, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight for back throws.
    scope adjust_player_weight_5: {
        OS.patch_start(0xC5AC4, 0x8014B084)
        j       adjust_player_weight_5
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s1)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(t3)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 2, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight. Getting hit while grabbing?
    scope adjust_player_weight_6: {
        OS.patch_start(0xC5E30, 0x8014B3F0)
        j       adjust_player_weight_6
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t1 = multiplier_table
        lbu     t2, 0x000D(s0)              // t2 = port
        sll     t2, t2, 0x0002              // t2 = index = port * 4
        addu    t1, t1, t2                  // t1 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(t7)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 2, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight for cargo hold
    scope adjust_player_weight_7: {
        OS.patch_start(0xC904C, 0x8014E60C)
        j       adjust_player_weight_7
        or      a3, r0, r0                 // original line 2
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s2)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f6, 0x0068(t9)              // original line 1, load weight
        mul.s   f6, f6, f20                 // f6 = multiplier * weight
        swc1    f6, 0x0038(sp)              // original line 3, save new weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // Adjusts weight used by mushroom kingdom objects.
    scope adjust_player_weight_8: {
        OS.patch_start(0x845E8, 0x80108DE8)
        j       adjust_player_weight_8
        addu    t9, s3, t8                 // original line 2
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      t1, 0x0004(sp)
        sw      t2, 0x0008(sp)
        swc1    f6, 0x000C(sp)
        swc1    f22, 0x0010(sp)
        swc1    f20, 0x0014(sp)

        li      t1, multiplier_table        // t7 = multiplier_table
        lbu     t2, 0x000D(s0)              // t8 = port
        sll     t2, t2, 0x0002              // t8 = index = port * 4
        addu    t1, t1, t2                  // t7 = &multiplier_table[index]
        lwc1    f6, 0x0000(t1)              // f6 = size multiplier (s)
        lui     t1, 0x3F80                  // t1 = 1
        mtc1    t1, f22                     // f22 = 1
        sub.s   f6, f6, f22                 // f22 = s - 1

        li      t2, weight_multiplier
        lwc1    f20, 0x0000(t2)             // f20 = weight multiplier (m)
        mul.s   f20, f20, f6                // f20 = m * (s - 1)
        add.s   f20, f22, f20               // f20 = multiplier = 1 + m * (s - 1)
        lwc1    f4, 0x0068(t7)              // original line 1, load weight
        mul.s   f4, f4, f20                 // f6 = multiplier * weight

        lw      t1, 0x0004(sp)
        lw      t2, 0x0008(sp)
        lwc1    f6, 0x000C(sp)
        lwc1    f22, 0x0010(sp)
        lwc1    f20, 0x0014(sp)
        addiu   sp, sp, 0x0020

        j       _return
        nop
    }

    // @ Description
    // Adjusts default camera zoom multiplier based on size.
    scope adjust_camera_zoom_: {
        OS.patch_start(0x8739C, 0x8010BB9C)
        j       adjust_camera_zoom_
        lbu     t7, 0x000D(a0)              // t7 = port
        _return:
        OS.patch_end()

        // a0 = player struct
        li      at, multiplier_table        // at = multiplier_table
        sll     t7, t7, 0x0002              // t7 = index = port * 4
        addu    at, at, t7                  // at = &multiplier_table[index]
        lwc1    f6, 0x0000(at)              // f6 = size multiplier = s
        lui     at, 0x3F80                  // at = (fp) 1
        mtc1    at, f0                      // f0 = 1
        sub.s   f4, f6, f0                  // f4 = s - 1
        lui     at, 0x3F00                  // at = (fp) .5
        mtc1    at, f8                      // f8 = .5
        mul.s   f4, f4, f8                  // f4 = (s - 1) / 2
        add.s   f6, f4, f0                  // f6 = 1 + (s - 1) / 2 = camera zoom multiplier for size
        mul.s   f12, f12, f6                // f12 = zoom adjusted

        lwc1    f4, 0x0860(a0)              // original line 1 - f4 = default camera zoom multiplier
        j       _return
        lwc1    f6, 0x0864(a0)              // original line 2 - f6 = extra camera zoom multiplier
    }

    // @ Description
    // Adjusts default camera zoom multiplier when View is set to Close-up in Training based on size.
    scope adjust_camera_zoom_multiplier_: {
        // This patch runs every frame when View is set to Close-up in Training
        OS.patch_start(0x881C4, 0x8010C9C4)
        jal     adjust_camera_zoom_multiplier_
        lwc1    f10, 0x0050(v1)             // original line 1 - f10 = pause zoom height or width?
        OS.patch_end()

        li      at, multiplier_table        // at = multiplier_table
        lw      t7, 0x0044(v1)              // t7 = player object
        lw      t7, 0x0084(t7)              // t7 = player struct
        lbu     t7, 0x000D(t7)              // t7 = port
        sll     t7, t7, 0x0002              // t7 = index = port * 4
        addu    at, at, t7                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f10, f8, f10                // f10 = adjusted zoom height or width?

        jr      ra
        lw      a2, 0x0054(v1)              // original line 2
    }

    // @ Description
    // Adjusts the camera center point y offset of the character based on size.
    scope adjust_camera_center_point_: {
        OS.patch_start(0x87578, 0x8010BD78)
        jal     adjust_camera_center_point_._1
        lwc1    f6, 0x008C(t7)              // original line 1 - f6 = camera center y offset
        OS.patch_end()

        OS.patch_start(0x6E25C, 0x800F2A5C)
        jal     adjust_camera_center_point_._2
        lwc1    f6, 0x008C(t6)              // original line 1 - f6 = camera center y offset
        OS.patch_end()

        OS.patch_start(0x6E280, 0x800F2A80)
        jal     adjust_camera_center_point_._3
        lwc1    f10, 0x008C(t8)             // original line 1 - f10 = camera center y offset
        OS.patch_end()

        OS.patch_start(0x6E29C, 0x800F2A9C)
        jal     adjust_camera_center_point_._4
        lw      t9, 0x09C8(s8)              // original line 1 - t9 = player attributes struct
        jal     0x800190B0                  // original line 3
        or      a0, s0, r0                  // original line 2
        OS.patch_end()

        OS.patch_start(0x881AC, 0x8010C9AC)
        jal     adjust_camera_center_point_._5
        lwc1    f6, 0x008C(t0)              // original line 1 - f6 = camera center y offset
        OS.patch_end()

        _1:
        // v0 = player struct
        li      at, multiplier_table        // at = multiplier_table
        lbu     t8, 0x000D(v0)              // t8 = port
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    at, at, t8                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f6, f6, f8                  // f6 = adjusted camera center y offset

        jr      ra
        addiu   at, r0, 0x0005              // original line 2

        _2:
        // s8 = player struct
        li      at, multiplier_table        // at = multiplier_table
        lbu     t8, 0x000D(s8)              // t8 = port
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    at, at, t8                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f6, f6, f8                  // f6 = adjusted camera center y offset

        jr      ra
        add.s   f8, f4, f6                  // original line 2

        _3:
        // s8 = player struct
        li      at, multiplier_table        // at = multiplier_table
        lbu     t8, 0x000D(s8)              // t8 = port
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    at, at, t8                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f10, f10, f8                // f10 = adjusted camera center y offset

        jr      ra
        c.lt.s  f10, f0                     // original line 2

        _4:
        // s8 = player struct
        lwc1    f10, 0x008C(t9)             // f10 = camera center y offset - original line 4 sets this to a1
        li      at, multiplier_table        // at = multiplier_table
        lbu     t8, 0x000D(s8)              // t8 = port
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    at, at, t8                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f10, f10, f8                // f10 = adjusted camera center y offset

        jr      ra
        mfc1    a1, f10                     // a1 = adjusted camera center y offset - setting to a1 like original line 4

        _5:
        // a1 = player struct
        li      at, multiplier_table        // at = multiplier_table
        lbu     t8, 0x000D(a1)              // t8 = port
        sll     t8, t8, 0x0002              // t8 = index = port * 4
        addu    at, at, t8                  // at = &multiplier_table[index]
        lwc1    f8, 0x0000(at)              // f8 = size multiplier = s
        mul.s   f6, f6, f8                  // f6 = adjusted camera center y offset

        jr      ra
        add.s   f8, f4, f6                  // original line 2
    }

    // @ Description
    // These patches adjust Yoshi's egg
    scope yoshi_egg {
        scope adjust_size_egg_shield_: {
            // Renders egg during shield and roll
            OS.patch_start(0x7C9A4, 0x801011A4)
            jal     adjust_size_egg_shield_
            mtc1    r0, f2                  // original line 1
            OS.patch_end()

            // a0 = egg shield object
            // v1 = player struct

            lui     t0, 0x3FC0              // t0 = normal scale
            mtc1    t0, f4                  // f4 = normal scale

            li      t0, Size.multiplier_table
            lbu     t9, 0x000D(v1)          // t9 = port
            sll     t9, t9, 0x0002          // t9 = port * 4 = offset to multiplier
            addu    t0, t0, t9              // t0 = size multiplier address
            lwc1    f6, 0x0000(t0)          // f6 = size multiplier
            mul.s   f4, f4, f6              // f4 = adjusted egg size
            lw      t0, 0x0074(a0)          // t0 = egg position struct top joint
            swc1    f4, 0x0040(t0)          // update x scale
            swc1    f4, 0x0044(t0)          // update y scale
            swc1    f4, 0x0048(t0)          // update z scale

            jr      ra
            lui     at, 0x432E              // original line 2
        }

        scope adjust_size_egg_lay_: {
            // runs every frame that the captured player is in the egg
            OS.patch_start(0xC73D4, 0x8014C994)
            j       adjust_size_egg_lay_
            lw      t6, 0x0B18(v1)          // t6 = egg object (if it exists)
            OS.patch_end()

            // v1 = captured player struct

            beqz    t6, _end                // if no egg object, skip
            lw      t9, 0x0008(v1)          // t9 = char_id

            li      t0, Character.yoshi_egg.table
            sll     t4, t9, 0x0003          // t4 = char_id * 8
            subu    t4, t4, t9              // t4 = char_id * 7
            sll     t4, t4, 0x0002          // t4 = char_id * 28 = char_id * 0x1C = offset to yoshi_egg entry
            addu    t0, t0, t4              // t0 = yoshi_egg entry
            lwc1    f4, 0x0000(t0)          // f4 = default egg size for this character

            li      t0, Size.multiplier_table
            lbu     t9, 0x000D(v1)          // t9 = port
            sll     t9, t9, 0x0002          // t9 = port * 4 = offset to multiplier
            addu    t0, t0, t9              // t0 = size multiplier address
            lwc1    f0, 0x0000(t0)          // f0 = size multiplier
            mul.s   f4, f4, f0              // f4 = adjusted egg size

            lw      t6, 0x0074(t6)          // t6 = egg position struct top joint
            swc1    f4, 0x0040(t6)          // update x scale
            swc1    f4, 0x0044(t6)          // update y scale
            swc1    f4, 0x0048(t6)          // update z scale

            _end:
            jr      ra                      // original line 2
            addiu   sp, sp, 0x0020          // original line 1
        }

        scope adjust_size_egg_entry_: {
            // Runs after entry animation successfully creates an egg
            OS.patch_start(0x7E764, 0x80102F64)
            jal     adjust_size_egg_entry_
            or      v0, a0, r0              // original line 1 - v0 = egg object
            OS.patch_end()

            // v1 = egg object top joint
            // s0 = player struct

            lwc1    f4, 0x0040(v1)          // f4 = original x scale

            li      t8, Size.multiplier_table
            lbu     t7, 0x000D(s0)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            mul.s   f4, f4, f6              // f4 = adjusted egg size
            swc1    f4, 0x0040(v1)          // update x scale
            swc1    f4, 0x0044(v1)          // update y scale
            swc1    f4, 0x0048(v1)          // update z scale

            jr      ra
            lw      t8, 0x0000(t6)          // original line 2
        }
    }

    // @ Description
    // This patch adjusts the ground gfx that appears for DK dsp, Samus charge, Link dair, etc.
    scope ground_gfx {
        // store a reference to the player struct in the gfx object
        scope save_player_struct_: {
            // moveset - grounded
            OS.patch_start(0x668E8, 0x800EB0E8)
            jal     save_player_struct_._grounded
            addiu   a1, r0, 0x0004          // original line 2
            OS.patch_end()
            // moveset - aerial
            OS.patch_start(0x668F8, 0x800EB0F8)
            jal     save_player_struct_._aerial
            addiu   a1, r0, 0x0004          // original line 2
            OS.patch_end()
            // wall bounce
            OS.patch_start(0xBC580, 0x80141B40)
            jal     save_player_struct_._wall_bounce
            addiu   a1, r0, 0x0004          // original line 2
            OS.patch_end()
            // ness pk thunder wall bounce
            OS.patch_start(0xCFBFC, 0x801551BC)
            jal     save_player_struct_._wall_bounce
            addiu   a1, r0, 0x0004          // original line 2
            OS.patch_end()
            // kirby star clipping collide (when opponent is spit out as a star and collides w/clipping)
            OS.patch_start(0xC6E4C, 0x8014C40C)
            jal     save_player_struct_._kirby_star_clipping_collide
            addiu   a1, r0, 0x0004          // original line 2
            OS.patch_end()

            _kirby_star_clipping_collide:
            li      at, 0x800FFD58          // at = create gfx object routine
            b       _assign
            lw      t0, 0x003C(sp)          // t0 = player struct

            _wall_bounce:
            li      at, 0x800FFD58          // at = create gfx object routine
            b       _assign
            or      t0, s0, r0              // t0 = player struct

            _grounded:
            li      at, 0x800FFD58          // at = create gfx object routine
            b       _assign
            lw      t0, 0x0054(sp)          // t0 = player struct

            _aerial:
            li      at, 0x800FFDE8          // at = create gfx object routine aerial
            lw      t0, 0x0054(sp)          // t0 = player struct

            _assign:
            addiu   sp, sp,-0x0020          // allocate stack space
            sw      ra, 0x0014(sp)          // save registers
            sw      t0, 0x0018(sp)          // ~

            jalr    at                      // original line 1, modified - create ground gfx object
            nop

            lw      ra, 0x0014(sp)          // restore registers
            lw      t0, 0x0018(sp)          // ~
            addiu   sp, sp, 0x0020          // deallocate stack space

            beqz    v0, _end                // if no gfx object was created, skip
            nop

            sw      t0, 0x0040(v0)          // save reference to player struct in gfx object

            _end:
            jr      ra
            nop
        }

        // replace update routine with a wrapper that adjusts the size
        OS.patch_start(0xA97C4 + 0x10, 0x8012DFC4 + 0x10)
        dw update_routine_
        OS.patch_end()

        // @ Description
        // This is the wrapper for the original update routine used.
        // @ Arguments
        // a0 - gfx object
        scope update_routine_: {
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      ra, 0x0004(sp)          // save registers
            sw      a0, 0x0008(sp)          // ~

            jal     0x800FFCA4              // call original update routine
            nop

            lw      a0, 0x0008(sp)          // a0 = gfx object
            lw      t3, 0x0074(a0)          // t3 = gfx position struct top joint

            li      t8, Size.multiplier_table
            lw      t7, 0x0040(a0)          // t7 = player special struct
            lbu     t7, 0x000D(t7)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            lwc1    f0, 0x0040(t3)          // f0 = x
            mul.s   f0, f0, f6              // f0 = updated x
            lwc1    f2, 0x0044(t3)          // f2 = y
            mul.s   f2, f2, f6              // f2 = updated y
            lwc1    f4, 0x0048(t3)          // f4 = z
            mul.s   f4, f4, f6              // f4 = updated z
            swc1    f0, 0x0040(t3)          // update x scale
            swc1    f2, 0x0044(t3)          // update y scale
            swc1    f4, 0x0048(t3)          // update z scale

            lw      ra, 0x0004(sp)          // restore registers
            jr      ra
            addiu   sp, sp, 0x0010          // deallocate stack space
        }
    }

    // @ Description
    // This patch adjusts Samus's gun blast gfx
    scope samus_gun_blast {
        // replace render routine with a wrapper that adjusts the size
        OS.patch_start(0xA98B4 + 0x14, 0x8012E0B4 + 0x14)
        dw render_routine_
        OS.patch_end()

        // @ Description
        // This is the wrapper for the original render routine used.
        // @ Arguments
        // a0 - gfx object
        scope render_routine_: {
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      ra, 0x0004(sp)          // save registers

            lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
            lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

            li      t8, Size.multiplier_table
            lw      t7, 0x0084(a0)          // t7 = projectile special struct
            lw      t7, 0x0004(t7)          // t7 = player object
            lw      t7, 0x0084(t7)          // t7 = player special struct
            lbu     t7, 0x000D(t7)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            lui     t7, 0x4320              // t7 = original y
            mtc1    t7, f4                  // f4 = original y
            mul.s   f4, f4, f6              // f4 = updated y
            swc1    f6, 0x0040(t3)          // update x scale
            swc1    f6, 0x0044(t3)          // update y scale
            swc1    f6, 0x0048(t3)          // update z scale
            swc1    f4, 0x0020(t4)          // update y

            jal     0x800CB4B0              // call original render routine
            nop

            lw      ra, 0x0004(sp)          // restore registers
            jr      ra
            addiu   sp, sp, 0x0010          // deallocate stack space
        }
    }

    scope kirby {
        scope nsp {
            scope adjust_suck_gfx_: {
                OS.patch_start(0x7FA9C, 0x8010429C)
                j       adjust_suck_gfx_
                lbu     t1, 0x000D(t1)      // t1 = port
                _return:
                OS.patch_end()

                // v1 = gfx position struct

                li      t8, Size.multiplier_table
                sll     t1, t1, 0x0002      // t1 = port * 4 = offset to multiplier
                addu    t8, t8, t1          // t8 = size multiplier address
                lwc1    f8, 0x0000(t8)      // f8 = size multiplier
                mul.s   f6, f6, f8          // f6 = updated y offset
                mul.s   f10, f10, f8        // f10 = updated x offset
                swc1    f8, 0x001C(v1)      // update x scale
                swc1    f8, 0x0020(v1)      // update y scale
                swc1    f8, 0x0024(v1)      // update z scale

                j       _return
                add.s   f8, f4, f6          // original line 2 - f8 = y position
            }
        }

        scope usp {
            // The following patches replace render routines with wrappers that adjust the size

            // USP sword twirl gfx, bottom
            OS.patch_start(0xA9B7C + 0x14, 0x8012E37C + 0x14)
            dw render_routine_
            OS.patch_end()
            // USP sword twirl gfx, top
            OS.patch_start(0xA9BA4 + 0x14, 0x8012E3A4 + 0x14)
            dw render_routine_
            OS.patch_end()
            // USP sword descend gfx
            OS.patch_start(0xA9BF4 + 0x14, 0x8012E3F4 + 0x14)
            dw render_routine_descend_
            OS.patch_end()

            // @ Description
            // This is the wrapper for the original render routine used for Kirby's USP sword gfx.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers

                lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
                lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                swc1    f6, 0x0040(t3)          // update x scale
                swc1    f6, 0x0044(t3)          // update y scale
                swc1    f6, 0x0048(t3)          // update z scale

                jal     0x80014038              // call original render routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }

            // @ Description
            // This is the wrapper for the original render routine used for Kirby's USP descending sword trail gfx.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_descend_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers

                lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
                lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                li      t7, 0x358637BD          // t7 = original x
                mtc1    t7, f2                  // f2 = original x
                mul.s   f2, f2, f6              // f2 = updated x
                lui     t7, 0x4396              // t7 = original y
                mtc1    t7, f4                  // f4 = original y
                mul.s   f4, f4, f6              // f4 = updated y
                li      t7, 0xC170000D          // t7 = original z
                mtc1    t7, f0                  // f0 = original z
                mul.s   f0, f0, f6              // f0 = updated z
                swc1    f6, 0x0040(t3)          // update x scale
                swc1    f6, 0x0044(t3)          // update y scale
                swc1    f6, 0x0048(t3)          // update z scale
                swc1    f2, 0x001C(t3)          // update x
                swc1    f4, 0x0020(t3)          // update y
                swc1    f0, 0x0024(t3)          // update z

                jal     0x80014768              // call original render routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }
        }
    }

    // @ Description
    // These patches adjust Falcon's Punch and Kick gfx
    scope falcon {
        scope punch {
            // @ Description
            // This is the wrapper for the original render routine used.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers

                lw      t3, 0x0074(a0)          // t3 = gfx position struct top joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                swc1    f6, 0x0040(t3)          // update x scale
                swc1    f6, 0x0044(t3)          // update y scale
                swc1    f6, 0x0048(t3)          // update z scale

                jal     0x800CB4B0              // call original render routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }
        }

        scope kick {
            // @ Description
            // This is the wrapper for the original update routine used.
            // @ Arguments
            // a0 - gfx object
            scope update_routine_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                sw      a0, 0x0008(sp)          // ~

                jal     0x800FD5D8              // call original update routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                lw      a0, 0x0008(sp)          // a0 = gfx object
                addiu   sp, sp, 0x0010          // deallocate stack space

                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t3, 0x0010(t7)          // t3 = some sort of flag
                srl     t3, t3, 0x001F          // t3 = 1 if in hitlag
                bnez    t3, _end                // if in hitlag, don't apply scale
                lw      t7, 0x0004(t7)          // t7 = player object

                _apply_scale:
                lw      t3, 0x0074(a0)          // t3 = gfx position struct top joint
                lw      t3, 0x0010(t3)          // t3 = gfx 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                lwc1    f0, 0x0040(t3)          // f0 = x
                mul.s   f0, f0, f6              // f0 = updated x
                lwc1    f2, 0x0044(t3)          // f2 = y
                mul.s   f2, f2, f6              // f2 = updated y
                lwc1    f4, 0x0048(t3)          // f4 = z
                mul.s   f4, f4, f6              // f4 = updated z

                swc1    f0, 0x0040(t3)          // update x scale
                li      t7, 0x43A20002          // t7 = original z offset
                mtc1    t7, f0                  // f0 = original z offset
                mul.s   f0, f0, f6              // f0 = updated z offset
                swc1    f2, 0x0044(t3)          // update y scale
                swc1    f4, 0x0048(t3)          // update z scale
                swc1    f0, 0x0024(t3)          // update z offset

                _end:
                jr      ra
                nop
            }
        }
    }

    // @ Description
    // These patches adjust Link's USP
    scope link {
        // This runs after grounded usp projectile is created.
        // The render routine is replaced with a wrapper that adjusts the size.
        scope adjust_usp_projectile_size_: {
            OS.patch_start(0xDE860, 0x80163E20)
            jal     adjust_usp_projectile_size_
            lw      v1, 0x0084(v0)          // original line 1 - v1 = projectile special struct
            OS.patch_end()

            // v0 = projectile object
            // s1 = player struct

            li      t3, render_routine_     // t3 = render routine wrapper
            sw      t3, 0x002C(v0)          // update render routine

            jr      ra
            sw      r0, 0x0100(v1)          // original line 2

            // @ Description
            // This is the wrapper for the original render routine used.
            // @ Arguments
            // a0 - projectile object
            scope render_routine_: {
                addiu   sp, sp,-0x0010      // allocate stack space
                sw      ra, 0x0004(sp)      // save registers

                lw      t3, 0x0074(a0)      // t3 = projectile position struct top joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)      // t7 = projectile special struct
                lw      t7, 0x0008(t7)      // t7 = player object
                lw      t7, 0x0084(t7)      // t7 = player special struct
                lbu     t7, 0x000D(t7)      // t7 = port
                sll     t7, t7, 0x0002      // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7          // t8 = size multiplier address
                lw      t8, 0x0000(t8)      // t8 = size multiplier
                sw      t8, 0x0040(t3)      // update x scale
                sw      t8, 0x0044(t3)      // update y scale
                sw      t8, 0x0048(t3)      // update z scale

                jal     0x8016763C          // call original render routine
                nop

                lw      ra, 0x0004(sp)      // restore registers
                jr      ra
                addiu   sp, sp, 0x0010      // deallocate stack space
            }
        }

        // This runs after grounded usp gfx is created.
        // The render routine is replaced with a wrapper that adjusts the size.
        scope adjust_usp_gfx_size_: {
            OS.patch_start(0xDE818, 0x80163DD8)
            jal     adjust_usp_gfx_size_
            lbu     t9, 0x018F(s1)          // original line 1
            OS.patch_end()

            // v0 = gfx object
            // s1 = player struct

            li      t3, render_routine_     // t3 = render routine wrapper
            sw      t3, 0x002C(v0)          // update render routine

            jr      ra
            ori     t0, t9, 0x0010          // original line 2

            // @ Description
            // This is the wrapper for the original render routine used.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_: {
                addiu   sp, sp,-0x0010      // allocate stack space
                sw      ra, 0x0004(sp)      // save registers

                lw      t3, 0x0074(a0)      // t3 = gfx position struct top joint
                lw      t3, 0x0010(t3)      // t3 = gfx 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)      // t7 = projectile special struct
                lw      t7, 0x0004(t7)      // t7 = player object
                lw      t7, 0x0084(t7)      // t7 = player special struct
                lbu     t7, 0x000D(t7)      // t7 = port
                sll     t7, t7, 0x0002      // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7          // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)      // f6 = size multiplier
                lui     t7, 0x4396          // t7 = original y
                mtc1    t7, f4              // f4 = original y
                mul.s   f4, f4, f6          // f4 = updated y
                swc1    f6, 0x0040(t3)      // update x scale
                swc1    f6, 0x0044(t3)      // update y scale
                swc1    f6, 0x0048(t3)      // update z scale
                swc1    f4, 0x0020(t3)      // update y

                jal     0x80014768          // call original render routine
                nop

                lw      ra, 0x0004(sp)      // restore registers
                jr      ra
                addiu   sp, sp, 0x0010      // deallocate stack space
            }
        }
    }

    // @ Description
    // This patch adjusts Pikachu's DSP gfx
    scope pikachu {
        // @ Description
        // This modifies the routine that creates the DSP connect gfx and applies our size multiplier
        scope adjust_gfx_size_: {
            OS.patch_start(0x7CC6C, 0x8010146C)
            jal     adjust_gfx_size_
            sw      t9, 0x0004(v1)          // original line 1 - set y
            OS.patch_end()

            // s1 = player struct
            // v1 = gfx position struct

            li      t9, Size.multiplier_table
            lbu     t8, 0x000D(s1)          // t8 = port
            sll     t8, t8, 0x0002          // t8 = port * 4 = offset to multiplier
            addu    t9, t9, t8              // t9 = size multiplier address
            lw      t9, 0x0000(t9)          // t9 = size multiplier
            sw      t9, 0x001C(v1)          // update x scale
            sw      t9, 0x0020(v1)          // update y scale

            jr      ra
            lw      t8, 0x0004(t7)          // original line 2 - get z
        }
    }

    // @ Description
    // These patches adjust Ness's NSP, DSP and USP gfx
    scope ness {
        scope nsp {
            // @ Description
            // This modifies the starting position of the PK fire projectile
            scope adjust_pkfire_position_: {
                OS.patch_start(0xCE3F4, 0x801539B4)
                jal     adjust_pkfire_position_
                lwc1    f6, 0x002C(sp)          // original line 1 - get player y
                mul.s   f10, f4, f8             // original line 3 - f10 = x offset, adjusted for direction
                mul.s   f4, f12, f18            // f4 = scaled y offset
                OS.patch_end()

                // v0 = player struct

                li      t9, Size.multiplier_table
                lbu     t8, 0x000D(v0)          // t8 = port
                sll     t8, t8, 0x0002          // t8 = port * 4 = offset to multiplier
                addu    t9, t9, t8              // t9 = size multiplier address
                lwc1    f18, 0x0000(t9)         // f18 = size multiplier
                mul.s   f4, f4, f18             // f4 = scaled x multiplier

                swc1    f0, 0x0030(sp)          // original line 2 - set pkfire z (to 0)

                jr      ra
                mtc1    at, f12                 // original line 4, modified to place in f12 instead of f4 - f12 = y offset
            }
        }

        scope usp {
            // The following patch replaces the update routine with a wrapper that adjusts the size
            // of the USP head gfx.
            OS.patch_start(0xA9C94 + 0x10, 0x8012E494 + 0x10)
            dw update_routine_._update
            OS.patch_end()

            // this runs right after the USP head gfx object is created
            OS.patch_start(0x7E23C, 0x80102A3C)
            jal     update_routine_._initialize
            sw      t7, 0x0004(a0)              // original line 1 - save player object in gfx special struct
            OS.patch_end()

            // @ Description
            // This is the wrapper for the original update routine used for Ness's USP head gfx.
            // @ Arguments
            // a0 - gfx object
            scope update_routine_: {
                _initialize:
                lw      t9, 0x0074(v1)          // original line 2
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                b       _scale
                sw      v1, 0x0008(sp)          // ~

                _update:
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                sw      a0, 0x0008(sp)          // ~

                jal     0x8000DF34              // call original update routine
                nop

                _scale:
                lw      t0, 0x0008(sp)          // t0 = gfx object
                lw      t4, 0x0074(t0)          // t4 = gfx position struct top joint
                lw      t4, 0x0010(t4)          // t4 = gfx 2nd joint
                lw      t3, 0x0010(t4)          // t3 = gfx 3rd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(t0)          // t7 = gfx object special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                swc1    f6, 0x0040(t3)          // update x scale, 3rd joint
                swc1    f6, 0x0044(t3)          // update y scale, 3rd joint
                swc1    f6, 0x0048(t3)          // update z scale, 3rd joint
                lwc1    f0, 0x0024(t4)          // f0 = original z offset, 2nd joint
                mul.s   f0, f0, f6              // f0 = updated z offset
                lwc1    f2, 0x0020(t4)          // f2 = original y offset, 2nd joint
                mul.s   f2, f2, f6              // f2 = updated y offset
                swc1    f0, 0x0024(t4)          // update z offset, 2nd joint
                swc1    f2, 0x0020(t4)          // update y offset, 2nd joint

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }
        }

        scope dsp {
            // The following patches allow scaling the DSP gfx.
            // replace update routine with a wrapper that adjusts the size
            OS.patch_start(0xA9C1C + 0x10, 0x8012E41C + 0x10)
            dw update_routine_._update
            OS.patch_end()

            // this runs right after the DSP gfx object is created
            OS.patch_start(0x7DE0C, 0x8010260C)
            jal     update_routine_._initialize
            lw      t6, 0x0084(a2)              // original line 2
            OS.patch_end()

            // @ Description
            // This is the wrapper for the original update routine used.
            // @ Arguments
            // a0 - gfx object
            scope update_routine_: {
                _initialize:
                sw      a2, 0x0004(a0)          // original line 1
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                sw      v1, 0x0008(sp)          // ~
                b       _scale
                sw      v1, 0x000C(sp)          // set initialize flag to non-zero

                _update:
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                sw      a0, 0x0008(sp)          // ~
                sw      r0, 0x000C(sp)          // set initialize flag to zero

                jal     0x8000DF34              // call original update routine
                nop

                _scale:
                lw      t0, 0x0008(sp)          // t0 = gfx object
                lw      t3, 0x0074(t0)          // t3 = gfx position struct top joint
                lw      t3, 0x0010(t3)          // t3 = gfx position struct 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(t0)          // t7 = gfx object special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                lwc1    f0, 0x0040(t3)          // f0 = x
                mul.s   f0, f0, f6              // f0 = updated x
                lwc1    f2, 0x0044(t3)          // f2 = y
                mul.s   f2, f2, f6              // f2 = updated y
                lwc1    f4, 0x0048(t3)          // f4 = z
                mul.s   f4, f4, f6              // f4 = updated z
                swc1    f0, 0x0040(t3)          // update x scale
                swc1    f2, 0x0044(t3)          // update y scale
                swc1    f4, 0x0048(t3)          // update z scale
                lw      t8, 0x000C(sp)          // t8 = non-zero if we need to initialize x/y offsets
                beqz    t8, _end                // if not initializing, skip
                lwc1    f0, 0x001C(t3)          // f0 = original x offset
                mul.s   f0, f0, f6              // f0 = updated x offset
                lwc1    f2, 0x0020(t3)          // f2 = original y offset
                mul.s   f2, f2, f6              // f2 = updated y offset
                swc1    f0, 0x001C(t3)          // update x offset
                swc1    f2, 0x0020(t3)          // update y offset

                _end:
                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }
        }
    }

    // @ Description
    // This patch adjusts Jigglypuff's sing gfx
    scope jigglypuff {
        // replace update routine with a wrapper that adjusts the size
        OS.patch_start(0xA9B14 + 0x10, 0x8012E314 + 0x10)
        dw update_routine_
        OS.patch_end()

        // @ Description
        // This is the wrapper for the original update routine used.
        // Originally, the sing gfx was animated to scale but the scaling was disabled.
        // The Gameshark code to enable it is: 8010212B 002E.
        // I'm going to preserve being able to use the GS code.
        // @ Arguments
        // a0 - gfx object
        scope update_routine_: {
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      ra, 0x0004(sp)          // save registers
            sw      a0, 0x0008(sp)          // ~

            jal     0x800FD568              // call original update routine
            nop

            lw      a0, 0x0008(sp)          // a0 = gfx object
            lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
            lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

            // Override this value always
            lw      t7, 0x005C(t3)          // t7 = some sort of animation/vertext struct
            lli     t8, 0x002E              // t8 = routine index which respects rotation and scale
            sb      t8, 0x0004(t7)          // override routine index

            // Here, we'll check the USP routine's hardcode, which could be changed via Gameshark.
            // If it's 0x2E, then the GS code is active and we'll use the animation's scale values.
            // If it's 0x46, then the GS code is not active, so we'll just set the scale to 1x.
            lui     t7, 0x8010              // t7 = hardcoded routine index which respects rotation and scale
            lbu     t7, 0x212B(t7)          // ~
            beq     t7, t8, _end            // if GS code is active, don't set scale values
            lui     t7, 0x3F80              // t7 = 1.0

            // We also have a toggle, so if that's turned on then skip setting scale
            OS.read_word(Toggles.entry_puff_sing_anim + 0x04, t7) // t7 = 1 if on, 0 if off
            bnez    t7, _end                // if anim is on, don't set scale values
            lui     t7, 0x3F80              // t7 = 1.0

            sw      t7, 0x0040(t3)          // update x scale
            sw      t7, 0x0044(t3)          // update y scale
            sw      t7, 0x0048(t3)          // update z scale

            _end:
            lw      ra, 0x0004(sp)          // restore registers
            jr      ra
            addiu   sp, sp, 0x0010          // deallocate stack space
        }
    }

    scope dragonking {
        scope nsp {
            // The following patch replaces the render routine with a wrapper that adjust the size

            OS.patch_start(0xA99D4 + 0x14, 0x8012E1D4 + 0x14)
            dw render_routine_
            OS.patch_end()

            // @ Description
            // This is the wrapper for the original render routine used for Dragon King's NSP ball gfx.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t4, 0x0004(t7)          // t4 = player special struct
                lbu     t7, 0x000D(t4)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier

                lw      t8, 0x0008(t4)          // t8 = current character ID
                lli     t3, Character.id.KIRBY  // t3 = id.KIRBY
                beql    t8, t3, _calc_scale     // if Kirby, load alternate scale
                lui     t3, 0x3F00              // t3 = scale
                lli     t3, Character.id.JKIRBY // t3 = id.JKIRBY
                beql    t8, t3, _calc_scale     // if J Kirby, load alternate scale
                lui     t3, 0x3F00              // t3 = scale

                lui     t3, 0x3F40              // t3 = default scale

                _calc_scale:
                mtc1    t3, f8                  // f8 = scale
                mul.s   f6, f6, f8              // f6 = new scale

                lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
                lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

                swc1    f6, 0x0040(t3)          // update x scale
                swc1    f6, 0x0044(t3)          // update y scale
                swc1    f6, 0x0048(t3)          // update z scale

                jal     0x80014038              // call original render routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }

            // @ Description
            // This is the wrapper for the original render routine used for Kirby's USP descending sword trail gfx.
            // @ Arguments
            // a0 - gfx object
            scope render_routine_descend_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers

                lw      t4, 0x0074(a0)          // t4 = gfx position struct top joint
                lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0084(a0)          // t7 = projectile special struct
                lw      t7, 0x0004(t7)          // t7 = player object
                lw      t7, 0x0084(t7)          // t7 = player special struct
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier
                li      t7, 0x358637BD          // t7 = original x
                mtc1    t7, f2                  // f2 = original x
                mul.s   f2, f2, f6              // f2 = updated x
                lui     t7, 0x4396              // t7 = original y
                mtc1    t7, f4                  // f4 = original y
                mul.s   f4, f4, f6              // f4 = updated y
                li      t7, 0xC170000D          // t7 = original z
                mtc1    t7, f0                  // f0 = original z
                mul.s   f0, f0, f6              // f0 = updated z
                swc1    f6, 0x0040(t3)          // update x scale
                swc1    f6, 0x0044(t3)          // update y scale
                swc1    f6, 0x0048(t3)          // update z scale
                swc1    f2, 0x001C(t3)          // update x
                swc1    f4, 0x0020(t3)          // update y
                swc1    f0, 0x0024(t3)          // update z

                jal     0x80014768              // call original render routine
                nop

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }
        }
    }

    scope arwing {
        // The following patch replaces the update routine with a wrapper that adjusts the size
        // of the Arwing.
        OS.patch_start(0xA9EF4 + 0x10, 0x8012E6F4 + 0x10)
        dw update_routine_._update
        OS.patch_end()

        // this runs right after Arwing object is created
        OS.patch_start(0x7F0F0, 0x801038F0)
        jal     update_routine_._initialize
        sw      t3, 0x0020(s0)              // original line 1 - set y
        OS.patch_end()

        // @ Description
        // This is the wrapper for the original update routine used for Ness's USP head gfx.
        // @ Arguments
        // a0 - gfx object
        scope update_routine_: {
            // this saves a reference to the player struct so we can reference later.
            // We don't need to scale first frame since it's so far away.
            _initialize:
            lw      t4, 0x0018(sp)          // t4 = player struct
            lw      t0, 0x0004(s0)          // t0 = Arwing gfx obj
            sw      t4, 0x0040(t0)          // save reference to player struct
            jr      ra
            lw      t4, 0x0008(t2)          // original line 2

            _update:
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      ra, 0x0004(sp)          // save registers
            sw      a0, 0x0008(sp)          // ~

            jal     0x80103780              // call original update routine
            nop

            _scale:
            lw      t0, 0x0008(sp)          // t0 = gfx object
            lw      t4, 0x0074(t0)          // t4 = gfx position struct top joint
            lw      t3, 0x0010(t4)          // t3 = gfx 2nd joint

            li      t8, Size.multiplier_table
            lw      t7, 0x0040(t0)          // t7 = player special struct
            lbu     t7, 0x000D(t7)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            lwc1    f0, 0x0040(t3)          // f0 = original x scale
            mul.s   f0, f0, f6              // f0 = updated x scale
            lwc1    f2, 0x0044(t3)          // f2 = original y scale
            mul.s   f2, f2, f6              // f2 = updated y scale
            lwc1    f4, 0x0048(t3)          // f4 = original z scale
            mul.s   f4, f4, f6              // f4 = updated z scale
            swc1    f0, 0x0040(t3)          // update x scale
            swc1    f2, 0x0044(t3)          // update y scale
            swc1    f4, 0x0048(t3)          // update z scale

            lw      ra, 0x0004(sp)          // restore registers
            jr      ra
            addiu   sp, sp, 0x0010          // deallocate stack space
        }
    }

    // @ Description
    // These patches adjust entry animations
    scope entry {
        // This changes the scaling of entry animation x/y/z movement.
        // Only going to do this for Mario Bros.
        scope animation_: {
            OS.patch_start(0xB856C, 0x8013DB2C)
            j       animation_
            lw      v0, 0x0084(a0)          // original line 1 - v0 = player struct
            _return_init:
            OS.patch_end()

            lw      a1, 0x0008(v0)          // a1 = char_id
            lli     at, Character.id.MARIO
            beq     a1, at, _apply_scale    // apply scale if Mario
            lli     at, Character.id.LUIGI
            beq     a1, at, _apply_scale    // apply scale if Luigi
            lli     at, Character.id.DRM
            beq     a1, at, _apply_scale    // apply scale if Dr. Mario
            lli     at, Character.id.JMARIO
            beq     a1, at, _apply_scale    // apply scale if J Mario
            lli     at, Character.id.JLUIGI
            beq     a1, at, _apply_scale    // apply scale if J Luigi
            lli     at, Character.id.METAL
            beq     a1, at, _apply_scale    // apply scale if Metal Mario
            lli     at, Character.id.CONKER
            beq     a1, at, _apply_scale    // apply scale if Conker
            nop

            j       _return_init
            lw      a1, 0x08EC(v0)          // original line 2 - animated joint

            _apply_scale:
            li      at, Size.multiplier_table
            lbu     a1, 0x000D(v0)          // a1 = port
            sll     a1, a1, 0x0002          // a1 = port * 4 = offset to multiplier
            addu    at, at, a1              // at = size multiplier address
            lwc1    f6, 0x0000(at)          // f6 = size multiplier
            lw      a1, 0x08EC(v0)          // original line 2 - animated joint
            lwc1    f0, 0x001C(a1)          // f0 = original x offset
            mul.s   f0, f0, f6              // f0 = updated x offset
            lwc1    f2, 0x0020(a1)          // f2 = original y offset
            mul.s   f2, f2, f6              // f2 = updated y offset
            lwc1    f4, 0x0024(a1)          // f4 = original z offset
            mul.s   f4, f4, f6              // f4 = updated z offset
            swc1    f0, 0x001C(a1)          // update x offset
            swc1    f2, 0x0020(a1)          // update y offset
            j       _return_init
            swc1    f4, 0x0024(a1)          // update z offset
        }

        // These patches change the size of the gfx objects used during entry
        scope gfx_: {
            // This changes the size of the pipe (Mario, Luigi, etc.)
            OS.patch_start(0x7EF68, 0x80103768)
            jal     gfx_._top_joint
            lw      t0, 0x0008(t8)          // original line 1 - t0 = z offset
            OS.patch_end()

            // This changes the size of the barrel (or any entry object based on it) (DK, GDK, Sonic, etc.)
            OS.patch_start(0x7EC5C, 0x8010345C)
            jal     gfx_._top_joint
            lw      t0, 0x0008(t6)          // original line 1, modified (was t8) - t0 = z
            OS.patch_end()

            // This changes the size of Samus's portal
            OS.patch_start(0x7ECB8, 0x801034B8)
            jal     gfx_._top_joint
            lw      t0, 0x0008(t6)          // original line 1 - t0 = z offset
            OS.patch_end()

            // This changes the size of Link's portal ground gfx
            OS.patch_start(0x7E328, 0x80102B28)
            jal     gfx_._link_ground_gfx
            lw      t0, 0x0008(t6)          // original line 1 - t0 = z offset
            OS.patch_end()

            // This changes the size of Link's portal shaft gfx
            OS.patch_start(0x7E384, 0x80102B84)
            jal     gfx_._entry_shaft
            lw      t0, 0x0008(t6)          // original line 1 - t0 = z offset
            OS.patch_end()

            // This changes the size of Kirby's star
            OS.patch_start(0x7E410, 0x80102C10)
            jal     gfx_._2nd_joint
            lw      t0, 0x0008(t8)          // original line 1 - t0 = z offset
            OS.patch_end()

            // This changes the size of Blue Falcon, Bowser's Clown Car and Conker hand
            OS.patch_start(0x7EE70, 0x80103670)
            jal     gfx_._blue_falcon
            sw      t4, 0x0024(s5)          // original line 1 - set z
            OS.patch_end()

            // TODO:
            // - Arwing?

            _entry_shaft:
            sw      t0, 0x0024(v1)          // original line 2 - set z offset
            lw      t7, 0x0008(s0)          // t7 = char_id
            lli     t8, Character.id.LINK
            beq     t7, t8, _top_joint_no_y // if Link, scale top joint without y
            lli     t8, Character.id.JLINK
            beq     t7, t8, _top_joint_no_y // if J Link, scale top joint without y
            lli     t8, Character.id.ELINK
            beq     t7, t8, _top_joint_no_y // if E Link, scale top joint without y
            lli     t8, Character.id.YLINK
            beq     t7, t8, _top_joint_no_y // if Young Link, scale top joint without y
            lli     t8, Character.id.MARINA
            beq     t7, t8, _link_ground_gfx // if Marina, scale like ground gfx
            lli     t8, Character.id.GOEMON
            beq     t7, t8, _render_override  // if Goemon, update render routine
            lli     t8, Character.id.BANJO
            beq     t7, t8, _2nd_joint  // if Banjo, update 2nd joint
            lli     t8, Character.id.EBI
            bne     t7, t8, _top_joint      // if not Ebisumaru, scale top joint
            nop                             // otherwise we'll update the render routine

            // Goemon beam
            _render_override:
            li      t7, scaled_render_routine_
            lbu     t8, 0x000D(s0)          // t8 = port
            sw      t8, 0x0040(v0)          // set port on object
            jr      ra
            sw      t7, 0x002C(v0)          // set render routine

            _top_joint_no_y:
            li      t8, Size.multiplier_table
            lbu     t7, 0x000D(s0)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            swc1    f6, 0x0040(v1)          // update x scale

            jr      ra
            swc1    f6, 0x0048(v1)          // update z scale

            _2nd_joint:
            sw      t0, 0x0024(v1)          // original line 2 - set z offset
            b       _common
            lw      v1, 0x0010(v1)          // v1 = 2nd joint

            _top_joint:
            sw      t0, 0x0024(v1)          // original line 2 - set z offset

            // s0 = player struct

            _common:
            li      t8, Size.multiplier_table
            lbu     t7, 0x000D(s0)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier
            swc1    f6, 0x0040(v1)          // update x scale
            swc1    f6, 0x0044(v1)          // update y scale

            jr      ra
            swc1    f6, 0x0048(v1)          // update z scale

            _blue_falcon:
            lw      t5, 0x0020(sp)          // t5 = player struct
            li      t8, Size.multiplier_table
            lbu     t7, 0x000D(t5)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier

            lw      t7, 0x0008(t5)          // t7 = char_id
            lw      t5, 0x0010(s5)          // t5 = 2nd joint
            lli     t8, Character.id.FALCON
            beq     t7, t8, _scale_object   // if Falcon, scale Blue Falcon
            lli     t8, Character.id.JFALCON
            beq     t7, t8, _scale_object   // if J Falcon, scale Blue Falcon
            lli     t8, Character.id.CONKER
            beq     t7, t8, _conker         // if Conker, reposition
            lli     t8, Character.id.BOWSER
            beq     t7, t8, _bowser         // if Bowser, reposition
            nop

            // Will only get here if we add a new entry based on Blue Falcon and don't address in char checks above
            b       _end_blue_falcon
            nop

            _conker:
            b       _scale_object
            or      t5, s5, r0              // t5 = 1st joint

            _bowser:
            lwc1    f4, 0x0020(s5)          // f4 = y
            lui     t5, 0x4410              // t5 = h = 576
            mtc1    t5, f2                  // f2 = h
            mul.s   f0, f2, f6              // f0 = h * multiplier
            sub.s   f2, f2, f0              // f2 = h - h * multiplier = y offset
            add.s   f4, f4, f2              // f4 = new y
            swc1    f4, 0x0020(s5)          // update y
            lw      t5, 0x0010(s5)          // t5 = 2nd joint

            _scale_object:
            swc1    f6, 0x0040(t5)          // update x scale
            swc1    f6, 0x0044(t5)          // update y scale
            swc1    f6, 0x0048(t5)          // update z scale

            _end_blue_falcon:
            jr      ra
            lw      t5, 0x0044(sp)          // original line 2

            _link_ground_gfx:
            sw      t0, 0x0024(v1)          // original line 2 - set z offset

            // This one's a bit complicated... the update routine is set to 800FD714, which
            // registers a routine on the gfx object: 800FD524. I give the gfx a special struct
            // which allows me to override the update routine, which allows me to wrap 800FD524.
            addiu   t0, a0, 0x0040          // t0 = unused space in gfx object
            sw      t0, 0x0084(a0)          // set special struct as unused space in gfx object
            li      t1, update_routine_     // t1 = wrapper for 800FD524
            sw      t1, 0x0014(t0)          // store new update routine
            jr      ra
            sw      s0, 0x0040(a0)          // save reference to player struct

            // @ Description
            // This is the wrapper for the original update routine used for Link's portal ground gfx.
            // @ Arguments
            // a0 - gfx object
            scope update_routine_: {
                addiu   sp, sp,-0x0010          // allocate stack space
                sw      ra, 0x0004(sp)          // save registers
                sw      a0, 0x0008(sp)          // ~

                jal     0x800FD524              // call original update routine
                nop

                lw      a0, 0x0008(sp)          // a0 = gfx object
                lw      t3, 0x0074(a0)          // t3 = gfx position struct top joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0040(a0)          // t7 = player special struct

                lw      t0, 0x0008(t7)          // t0 = char_id
                lbu     t7, 0x000D(t7)          // t7 = port
                sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7              // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)          // f6 = size multiplier

                lli     t1, Character.id.BANJO
                bne     t0, t1, _continue       // if not Banjo, don't adjust y offset
                lwc1    f8, 0x0024(t3)          // f8 = y offset, unadjusted

                mul.s   f8, f8, f6              // f8 = y offset, adjusted

                _continue:
                lwc1    f0, 0x0040(t3)          // f0 = x
                mul.s   f0, f0, f6              // f0 = updated x
                lwc1    f2, 0x0044(t3)          // f2 = y
                mul.s   f2, f2, f6              // f2 = updated y
                lwc1    f4, 0x0048(t3)          // f4 = z
                mul.s   f4, f4, f6              // f4 = updated z
                swc1    f0, 0x0040(t3)          // update x scale
                swc1    f2, 0x0044(t3)          // update y scale
                swc1    f4, 0x0048(t3)          // update z scale
                swc1    f8, 0x0024(t3)          // update y offset

                lw      ra, 0x0004(sp)          // restore registers
                jr      ra
                addiu   sp, sp, 0x0010          // deallocate stack space
            }

            // @ Description
            // This is the wrapper for the original render routine used for animating the entry gfx.
            // Goemon/Ebi beam and Banjo platform.
            // @ Arguments
            // a0 - projectile object
            scope scaled_render_routine_: {
                addiu   sp, sp,-0x0010      // allocate stack space
                sw      ra, 0x0004(sp)      // save registers

                lw      t3, 0x0074(a0)      // t3 = position struct top joint

                li      t8, Size.multiplier_table
                lw      t7, 0x0040(a0)      // t7 = port
                sll     t7, t7, 0x0002      // t7 = port * 4 = offset to multiplier
                addu    t8, t8, t7          // t8 = size multiplier address
                lwc1    f6, 0x0000(t8)      // f6 = size multiplier
                lwc1    f0, 0x0040(t3)      // f0 = x
                mul.s   f0, f0, f6          // f0 = updated x
                lwc1    f4, 0x0048(t3)      // f4 = z
                mul.s   f4, f4, f6          // f4 = updated z
                swc1    f0, 0x0040(t3)      // update x scale

                jal     0x80014768          // call original render routine
                swc1    f4, 0x0048(t3)      // update z scale

                lw      ra, 0x0004(sp)      // restore registers
                jr      ra
                addiu   sp, sp, 0x0010      // deallocate stack space
            }
        }
    }

    // @ Description
    // This patch adjusts item size and ECB
    // Currently only used for Goemon's cloud
    scope item {
        // @ Description
        // This allows animations to have size applied.
        // Will only check for Goemon cloud for now.
        scope apply_size_to_animation_: {
            // First, update jump table for X, Y and Z scale
            OS.patch_start(0x3EA5C, 0x8003DE5C)
            dw apply_size_to_animation_._set_x_scale
            dw apply_size_to_animation_._set_y_scale
            dw apply_size_to_animation_._set_z_scale
            OS.patch_end()

            _apply_scale:
            // a3 = joint
            // f26 = new scale value
            lw      t0, 0x0004(a3)          // t0 = object
            lw      t1, 0x0000(t0)          // t1 = object type ID
            lli     t2, 0x03F5              // t2 = item type ID
            bne     t1, t2, _return         // skip if not an item
            lw      t0, 0x0084(t0)          // t0 = special struct
            lw      t1, 0x000C(t0)          // t1 = item ID
            lli     t2, Item.Cloud.id       // t2 = Goemon cloud item ID
            bne     t1, t2, _return         // skip if not Goemon cloud
            lw      t2, 0x0008(t0)          // t2 = player object
            beqz    t2, _return             // skip if not set
            li      t1, Size.multiplier_table
            lw      t2, 0x0084(t2)          // t2 = player special struct
            lbu     t2, 0x000D(t2)          // t2 = port
            sll     t2, t2, 0x0002          // t2 = port * 4 = offset to multiplier
            addu    t1, t1, t2              // t1 = size multiplier address
            lwc1    f0, 0x0000(t1)          // f0 = size multiplier
            jr      ra
            mul.s   f26, f26, f0            // f26 = updated scale value

            _return:
            jr      ra
            nop

            _set_x_scale:
            jal     _apply_scale
            nop
            j       0x8000CF0C              // jump to rest of routine
            swc1    f26, 0x0040(a3)         // set x scale

            _set_y_scale:
            jal     _apply_scale
            nop
            j       0x8000CF0C              // jump to rest of routine
            swc1    f26, 0x0044(a3)         // set y scale

            _set_z_scale:
            jal     _apply_scale
            nop
            j       0x8000CF0C              // jump to rest of routine
            swc1    f26, 0x0048(a3)         // set z scale
        }

        // @ Description
        // This is the wrapper for the original render routine used, which updates ecb scale.
        // @ Arguments
        // a0 - item object
        scope render_routine_: {
            addiu   sp, sp,-0x0010          // allocate stack space
            sw      ra, 0x0004(sp)          // save registers

            jal     0x80171F4C              // call original render routine
            nop

            lw      a0, 0x0000(sp)          // a0 = item object
            lw      t3, 0x0074(a0)          // t3 = item position struct top joint

            li      t8, Size.multiplier_table
            lw      t4, 0x0084(a0)          // t4 = item special struct
            lw      t7, 0x0008(t4)          // t7 = player object
            lw      t7, 0x0084(t7)          // t7 = player special struct
            lbu     t7, 0x000D(t7)          // t7 = port
            sll     t7, t7, 0x0002          // t7 = port * 4 = offset to multiplier
            addu    t8, t8, t7              // t8 = size multiplier address
            lwc1    f6, 0x0000(t8)          // f6 = size multiplier

            lw      t3, 0x02D4(t4)          // t3 = item attributes
            lh      t0, 0x002A(t3)          // t0 = ecb top
            mtc1    t0, f0                  // f0 = ecb top
            lh      t1, 0x002C(t3)          // t1 = ecb center
            mtc1    t1, f2                  // f2 = ecb center
            lh      t2, 0x002E(t3)          // t2 = ecb bottom
            mtc1    t2, f4                  // f4 = ecb bottom
            lh      t5, 0x0030(t3)          // t5 = ecb width
            mtc1    t5, f8                  // f8 = ecb width

            cvt.s.w f0, f0                  // f0 = ecb top, fp
            cvt.s.w f2, f2                  // f2 = ecb center, fp
            cvt.s.w f4, f4                  // f4 = ecb bottom, fp
            cvt.s.w f8, f8                  // f8 = ecb width, fp
            mul.s   f0, f0, f6              // f0 = updated ecb top
            mul.s   f2, f2, f6              // f2 = updated ecb center
            mul.s   f4, f4, f6              // f4 = updated ecb bottom
            mul.s   f8, f8, f6              // f8 = updated ecb width
            swc1    f0, 0x0070(t4)          // update ecb top
            swc1    f2, 0x0074(t4)          // update ecb center
            swc1    f4, 0x0078(t4)          // update ecb bottom
            swc1    f8, 0x007C(t4)          // update ecb width

            _end:
            lw      ra, 0x0004(sp)          // restore registers
            jr      ra
            addiu   sp, sp, 0x0010          // deallocate stack space
        }
    }
}
} // __SIZE__
