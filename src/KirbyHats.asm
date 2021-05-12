// KirbyHats.asm

// This file allows for adding Kirby "hats" without needing to modify Kirby's original files.
// (We do have to add a req file and pointer to the Kirby Character file, but that's it.)

scope KirbyHats {
    // @ Description
    // Number of new "hats" added
    variable new_hats(13)
    
    // @ Description
    // Used in add_hat to adjust offset
    variable current_custom_hat_id(0)

    // @ Description
    // Adds a special part for use as a Kirby "hat"
    macro add_hat(base_hat_id, dl_hi, images_hi, tracks_hi, dl_lo, images_lo, tracks_lo) {
        if (current_custom_hat_id + 1 > new_hats) {
            print "ERROR CREATING KIRBY HAT: You forgot to increase new_hats! \n"
        } else {
            pushvar base, origin
            origin EXTENDED_SPECIAL_PARTS_ORIGIN + (current_custom_hat_id * 0x20)
            dw     {base_hat_id}
            dw     {dl_hi}
            dw     {images_hi}
            dw     {tracks_hi}
            dw     {dl_lo}
            dw     {images_lo}
            dw     {tracks_lo}
            dw     0x0               // spacer
            pullvar origin, base

            global variable current_custom_hat_id(current_custom_hat_id + 1)
        }
    }

    // @ Description
    // Holds info for new special parts, which will override base special part if specified.
    // Offsets are relative to the file KIRBY_CUSTOM_HATS.
    // Size = 0x20:
    //   0x0000 - base special part (or -1 if not based on an existing one) - allows reuse of existing data
    //   0x0004 - offset to display list of part, high poly (or -1 if not overridden)
    //   0x0008 - offset to special images, high poly (or -1 if not overridden)
    //   0x000C - offset to special tracks 1, high poly (or -1 if not overridden)
    //   0x0010 - offset to display list of part, low poly (or -1 if not overridden)
    //   0x0014 - offset to special images, low poly (or -1 if not overridden)
    //   0x0018 - offset to special tracks 1, low poly (or -1 if not overridden)
    //   0x001C - spacer
    // Note: special tracks 2 is not supported as it is not necessary for Kirby
    extended_special_parts:
    constant EXTENDED_SPECIAL_PARTS_ORIGIN(origin())
    fill new_hats * 0x20

    // @ Description
    // This is what we'll use as a temporary array when switching parts
    temp_special_parts:
    fill 0x14

    // @ Description
    // This catches when Kirby copies a power and allows us to use custom "hats"
    scope use_extended_special_parts_copy_: {
        OS.patch_start(0x64774, 0x800E8F74)
        jal     use_extended_special_parts_copy_
        lw      s5, 0x0084(s1)              // original line 1
        OS.patch_end()

        // First check the special part index
        lli     t4, 0x0002                  // t4 = 2, the special part index for hats
        bne     s3, t4, _end                // if not the special part index for hats, exit
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // store registers
        sw      ra, 0x0008(sp)              // ~

        li      t0, _custom
        jal     use_extended_special_parts_
        nop

        lw      t0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra
        sll     t2, v1, 0x0002              // original line 2

        _custom:
        lw      t0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       0x800E8FAC                  // return to routine after s0 is set
        nop
    }

    // @ Description
    // This catches when the Kirby hat switches to high poly from low poly during a pause and allows us to use custom "hats".
    // Also runs when Kirby does Yoshi's NSP.
    scope use_extended_special_parts_pause_: {
        OS.patch_start(0x64504, 0x800E8D04)
        jal     use_extended_special_parts_pause_
        addu    t5, t4, a3                  // original line 1
        OS.patch_end()

        lw      v1, 0xFFF0(t5)              // original line 2

        // First check the special part index
        lli     t8, 0x0006                  // t8 = 6, the special part index for hats (not sure why this is different than when inhaling)
        beq     a1, t8, _swap               // if the special part index for hats proceed to swap code
        lli     t8, 0x0011                  // t8 = 11, the special part index for guns
        bne     a1, t8, _end                // if not the special part index for hats or guns, exit
        nop
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // store registers
        sw      t2, 0x0008(sp)              // ~
        sw      t6, 0x000C(sp)              // ~
        lb      t2, 0x0980(t0)              // load hat ID into t2
        addiu   t6, r0, 0x0019              // put Conker Hat ID into t6
        bne     t2, t6, _wolf
        addiu   t6, r0, 0x001A              // put Wolf Hat ID into t6
        
        // conker
        lw      t2, 0x0008(t0)              // Load Character ID
        addiu   t6, r0, Character.id.JKIRBY
        beq     t6, t2, _jkirby_conker
        nop
        li      t2, 0x80131078              // Kirby's File pointer to model file 
        beq     r0, r0, _load_address_conker
        nop
        
        _jkirby_conker:
        li      t2, Character.JKIRBY_file_4_ptr // J Kirby's File pointer to model file
        
        _load_address_conker:
        lw      t2, 0x0000(t2)              // load address of model file for kirby
        li      t6, 0x1D860                 // offset of special part struct for Conker's Catapult [UPDATE IF GUN MODEL CHANGED]
        beq     r0, r0, _gun_end            // jump to end of fox gun swapping
        addu    v1, t2, t6                  // add offset to file address
        
        _wolf:
        bne     t2, t6, _gun_end            // jump to end of fox gun swapping
        nop
        
        lw      t2, 0x0008(t0)              // Load Character ID
        addiu   t6, r0, Character.id.JKIRBY
        beq     t6, t2, _jkirby_wolf
        nop
        li      t2, 0x80131078              // Kirby's File pointer to model file 
        beq     r0, r0, _load_address_wolf
        nop
        
        _jkirby_wolf:
        li      t2, Character.JKIRBY_file_4_ptr // J Kirby's File pointer to model file
        
        _load_address_wolf:
        lw      t2, 0x0000(t2)              // load address of model file for kirby
        li      t6, 0x1D830                 // offset of special part struct for Wolf's Gun [UPDATE IF GUN MODEL CHANGED]
        addu    v1, t2, t6                  // add offset to file address
        
        _gun_end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t2, 0x0008(sp)              // ~
        lw      t6, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop

        _swap:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // store registers
        sw      ra, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      v1, 0x0010(sp)              // ~
        sw      t2, 0x0014(sp)              // ~
        sw      s2, 0x0018(sp)              // ~
        sw      t6, 0x001C(sp)              // ~
        sw      s0, 0x0020(sp)              // ~

        or      v0, v1, r0                  // v0 = special part table
        or      v1, t2, r0                  // v1 = hat_id
        or      s2, t0, r0                  // s2 = player struct

        li      t0, _custom
        jal     use_extended_special_parts_
        nop

        lw      t0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      v1, 0x0010(sp)              // ~
        lw      t2, 0x0014(sp)              // ~
        lw      s2, 0x0018(sp)              // ~
        lw      t6, 0x001C(sp)              // ~
        lw      s0, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra
        nop

        _custom:
        or      t3, t6, r0                  // t3 = display list pointer
        or      v0, s0, r0                  // v0 = special part array

        lw      t0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        // don't restore v0
        lw      v1, 0x0010(sp)              // ~
        lw      t2, 0x0014(sp)              // ~
        lw      s2, 0x0018(sp)              // ~
        lw      t6, 0x001C(sp)              // ~
        lw      s0, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        j       0x800E8D38                  // return to routine after s0 is set
        nop
    }

    // @ Description
    // This seems to be related to costume loading and initializing things to use the right special images/tracks.
    scope use_extended_special_parts_costume_init_: {
        OS.patch_start(0x64AFC, 0x800E92FC)
        jal     use_extended_special_parts_costume_init_
        lbu     t7, 0x000E(s5)              // original line 1
        OS.patch_end()

        or      a0, s1, r0                  // original line 2

        // First check the special part index
        lli     t8, 0x0002                  // t8 = 2, the special part index for hats
        bne     s2, t8, _end                // if not the special part index for hats, exit
        nop

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t4, 0x0004(sp)              // store registers
        sw      ra, 0x0008(sp)              // ~
        sw      v1, 0x000C(sp)              // ~
        sw      t7, 0x0010(sp)              // ~
        sw      s2, 0x0014(sp)              // ~
        sw      s0, 0x0018(sp)              // ~

        or      v0, v1, r0                  // v0 = special part table
        or      v1, t4, r0                  // v1 = hat_id
        or      s2, s5, r0                  // s2 = player struct

        li      t0, _custom
        jal     use_extended_special_parts_
        nop

        lw      t4, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        lw      v1, 0x000C(sp)              // ~
        lw      t7, 0x0010(sp)              // ~
        lw      s2, 0x0014(sp)              // ~
        lw      s0, 0x0018(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra
        nop

        _custom:
        or      v0, s0, r0                  // v0 = special part array
        lw      a1, 0x0004(v0)              // a1 = special images
        lw      a2, 0x0008(v0)              // a2 = special tracks 1
        lw      a3, 0x000C(v0)              // a3 = special tracks 2

        lw      ra, 0x0008(sp)              // restore registers
        lw      s2, 0x0014(sp)              // ~
        lw      s0, 0x0018(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        j       0x800E9334                  // return to routine after v0 is set
        nop
    }

    // @ Description
    // This allows us to use custom hats for Kirby.
    // It expects the following:
    //  v0 - special part table
    //  v1 - hat_id
    //  s2 - player struct
    //  t0 - address to jump to if custom hat is used
    // It spits out the following:
    //  t6 - display list pointer
    //  s0 - special index array
    scope use_extended_special_parts_: {
        lw      t2, 0x0008(s2)                 // t2 = character_id

        // If v0 is 0, we can skip... may not be necessary but doesn't hurt
        beqz    v0, _end                       // if v0 = 0, exit
        nop

        // Next, ensure we are doing a Kirby hat swap
        lli     t4, Character.id.KIRBY         // t4 = Character.id.KIRBY
        beq     t2, t4, _check_hat_id          // if Kirby, then check hat ID
        lli     t4, Character.id.JKIRBY        // t4 = Character.id.JKIRBY
        bne     t2, t4, _end                   // if not Kirby or J Kirby, exit
        nop

        _check_hat_id:
        sltiu   t2, v1, 0x000F                 // t2 = 1 if an original hat_id, 0 if an added hat_id
        bnez    t2, _end                       // if an original hat_id, exit
        nop                                    // otherwise we need to use our custom table

        // We'll set s0 to temp_special_parts and populate it with the correct values
        li      s0, temp_special_parts
        addiu   v1, v1, -0x000F                // v1 = custom_hat_id
        li      t4, extended_special_parts     // t4 = extended_special_parts
        sll     v1, v1, 0x0005                 // v1 = custom_hat_id * 0x20 (offset to special part)
        addu    t4, t4, v1                     // t4 = special part
        lbu     t5, 0x000E(s2)                 // t5 = 1 if high poly, 2 if low poly
        addiu   t5, t5, -0x0001                // t5 = hi/lo poly index
        lw      v1, 0x0000(t4)                 // v1 = base hat_id
        bltz    v1, _set_overrides             // if base hat_id = -1, then skip setting values
        lli     t2, 0x28                       // t2 = 0x28 (size of special part array)
        multu   t2, v1                         // t2 = offset in special part table
        mflo    t2                             // ~
        addu    t3, v0, t2                     // t3 = special part array (hi)
        bnezl   t5, pc() + 8                   // if lo poly, add offset
        addiu   t3, t3, 0x0014                 // t3 = special part array (lo)

        lw      t7, 0x0000(t3)                 // t7 = display list pointer
        sw      t7, 0x0000(s0)                 // set display list pointer
        lw      t7, 0x0004(t3)                 // t7 = special images pointer
        sw      t7, 0x0004(s0)                 // set special images pointer
        lw      t7, 0x0008(t3)                 // t7 = special tracks 1 pointer
        sw      t7, 0x0008(s0)                 // set special tracks 1
        lw      t7, 0x000C(t3)                 // t7 = special tracks 2
        sw      t7, 0x000C(s0)                 // set special tracks 2

        _set_overrides:
        addiu   t4, t4, 0x0004                 // t4 = hi poly array of custom special part overrides
        bnezl   t5, pc() + 8                   // if lo poly, add offset
        addiu   t4, t4, 0x000C                 // t4 = lo poly array of custom special part overrides
        li      t3, 0x80116E10                 // t3 = main character struct table
        lw      t5, 0x0008(s2)                 // t5 = character_id
        sll     t5, t5, 0x0002                 // t5 = a5 * 4 (offset in struct table)
        addu    t3, t3, t5                     // t3 = pointer to character struct
        lw      t3, 0x0000(t3)                 // t3 = character struct
        lw      t3, 0x0034(t3)                 // t3 = character file address pointer
        lw      t3, 0x0000(t3)                 // t3 = character file address
        li      t5, 0x0001D810                 // t5 = offset to custom hat file pointer
        addu    t3, t3, t5                     // t3 = address for custom hat file pointer
        lw      t3, 0x0000(t3)                 // t3 = base address of custom hat file

        addiu   t5, r0, -0x0001                // t5 = -1

        lw      t7, 0x0000(t4)                 // t7 = display list offset
        beq     t7, t5, pc() + 12              // if display list offset not defined, skip overriding
        addu    t6, t3, t7                     // t6 = ponter to display list
        sw      t6, 0x0000(s0)                 // override display list pointer

        lw      t7, 0x0004(t4)                 // t7 = special images offset
        beq     t7, t5, pc() + 12              // if special images offset not defined, skip overriding
        addu    t7, t3, t7                     // t7 = ponter to special images
        sw      t7, 0x0004(s0)                 // override special images pointer

        lw      t7, 0x0008(t4)                 // t7 = special tracks 1 offset
        beq     t7, t5, pc() + 12              // if special tracks 1 offset not defined, skip overriding
        addu    t7, t3, t7                     // t7 = ponter to special tracks 1
        sw      t7, 0x0008(s0)                 // override special tracks 1 pointer

        jr      t0                             // return to routine after s0 is set
        nop

        _end:
        jr      ra
        nop
    }

    // Wario hat_id: 0x0F
    add_hat(Character.kirby_hat_id.MARIO, 0x900, -1, -1, 0x1360, -1, -1)
    // Dr. Mario hat_id: 0x10
    add_hat(Character.kirby_hat_id.MARIO, 0x2080, -1, -1, 0x2B68, -1, -1)
    // Ganondorf hat_id: 0x11
    add_hat(Character.kirby_hat_id.FALCON, 0x3AA0, -1, -1, 0x4BA0, -1, -1)
    // Falco hat_id: 0x12
    add_hat(Character.kirby_hat_id.FOX, 0x6030, -1, -1, 0x6B28, -1, -1)
    // Dark Samus hat_id: 0x13
    add_hat(Character.kirby_hat_id.SAMUS, 0x7760, -1, -1, 0x7760, -1, -1)
    // Lucas hat_id: 0x14
    add_hat(Character.kirby_hat_id.NESS, 0x8580, -1, -1, 0x9088, -1, -1)
    // Bowser hat_id: 0x15
    add_hat(Character.kirby_hat_id.YOSHI, 0x9F20, -1, -1, 0xAFD0, -1, -1)
    // Bowser (mouth open) hat_id: 0x16
    add_hat(Character.kirby_hat_id.YOSHI_SWALLOW, 0xC1B8, -1, -1, 0xCF80, -1, -1)
    // Mad Piano hat_id: 0x17
    add_hat(Character.kirby_hat_id.MARIO, 0xE540, -1, -1, 0xF560, -1, -1)
    // Mad Piano hat_id: 0x18
    add_hat(Character.kirby_hat_id.YOSHI_SWALLOW, 0x10EC0, -1, -1, 0x11B20, -1, -1)
    // Conker hat_id: 0x19
    add_hat(Character.kirby_hat_id.FOX, 0x13600, -1, -1, 0x14640, -1, -1)
    // Wolf hat_id: 0x1A
    add_hat(Character.kirby_hat_id.FOX, 0x16010, -1, -1, 0x16E20, -1, -1)
}
