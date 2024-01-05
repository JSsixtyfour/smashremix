// Linkshared.asm

// This file contains shared functions by Link Clones.

scope LinkShared {

    // Link has a blastwall character ID check it shares with Kirby and is in jigglypuffkirbyshared.asm

    OS.align(16)
    up_special_struct:
    dw 0x03000000
    dw 0x00000008
    dw Character.YLINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)

    OS.align(16)
    boomerang_struct:
    dw 0x01000000
    dw 0x00000007
    dw Character.YLINK_file_6_ptr
    OS.copy_segment(0x103DEC, 0x34)

    OS.align(16)
    bomb_struct_elink:
    dw 0x00000015
    dw Character.ELINK_file_1_ptr
    OS.copy_segment(0x106108, 0xF8)

    OS.align(16)
    up_special_struct_elink:
    dw 0x03000000
    dw 0x00000008
    dw Character.ELINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)

    OS.align(16)
    boomerang_struct_elink:
    dw 0x01000000
    dw 0x00000007
    dw Character.ELINK_file_6_ptr
    OS.copy_segment(0x103DEC, 0x34)

    OS.align(16)
    bomb_struct_jlink:
    dw 0x00000015
    dw Character.JLINK_file_1_ptr
    OS.copy_segment(0x106108, 0xF8)

    OS.align(16)
    up_special_struct_jlink:
    dw 0x03000000
    dw 0x00000008
    dw Character.JLINK_file_1_ptr
    OS.copy_segment(0x103DAC, 0x34)

    OS.align(16)
    boomerang_struct_jlink:
    dw 0x01000000
    dw 0x00000007
    dw Character.JLINK_file_6_ptr
    OS.copy_segment(0x103DEC, 0x34)

    entry_anim_struct_1_YLINK:
    dw  0x040A0000
    dw  Character.YLINK_file_7_ptr
    OS.copy_segment(0xA9CEC, 0x20)

    entry_anim_struct_2_YLINK:
    dw  0x040A0000
    dw  Character.YLINK_file_7_ptr
    OS.copy_segment(0xA9D14, 0x20)

    entry_anim_struct_1_MARTH:
    dw  0x040A0000
    dw  Character.MARTH_file_8_ptr
    OS.copy_segment(0xA9CEC, 0x10)
	dw	0x00000110					        // Marth entry alters these
	dw  0x00000218
    dw  0x00000344
    dw  0x000003A0

    entry_anim_struct_2_MARTH:
    dw  0x040A0000
    dw  Character.MARTH_file_8_ptr
    OS.copy_segment(0xA9D14, 0x10)
	dw	0x00000638					        // Marth entry alters these
	dw  0x00000740
    dw  0x0000076C
    dw  0x000007B4

    entry_anim_struct_1_MARINA:
    dw  0x040A0000
    dw  Character.MARINA_file_9_ptr
    OS.copy_segment(0xA9CEC, 0x10)
	dw	0x00000150					        // Marina entry alters these
	dw  0x00000260
    dw  0x0000042C
    dw  0x00000458

    entry_anim_struct_2_MARINA:
    dw  0x040A0000
    dw  Character.MARINA_file_9_ptr
    OS.copy_segment(0xA9D14, 0x10)
	dw	0x00000628					        // Marina entry alters these
	dw  0x00000740
    dw  0x0000090C
    dw  0x00000940

    // entry_anim_struct_1_GOEMON:
    // dw  0x040A0000
    // dw  Character.GOEMON_file_9_ptr
    // OS.copy_segment(0xA9CEC, 0x10)
	// dw	0x00000240					        // Goemon entry alters these
	// dw  0x00000348
    // dw  0x00000668
    // dw  0x000006C4

    entry_anim_struct_2_GOEMON:
    dw  0x040A0000
    dw  Character.GOEMON_file_9_ptr
    OS.copy_segment(0xA9D14, 0x10)
	dw	0x00000990					        // Goemon entry alters these
	dw  0x00000A98
    dw  0x00000CA4
    dw  0x00000CEC

    entry_anim_struct_2_EBI:
    dw  0x040A0000
    dw  Character.EBI_file_9_ptr
    OS.copy_segment(0xA9D14, 0x10)
	dw	0x00000990					        // Ebisumaru entry alters these
	dw  0x00000A98
    dw  0x00000CA4
    dw  0x00000CEC

    entry_anim_struct_2_BANJO:
    dw  0x040A0000
    dw  Character.BANJO_file_8_ptr
    OS.copy_segment(0xA9CEC, 0x10)
	dw	0x00000240					        // Banjo entry alters these
	dw  0x00000348
    dw  0x00000378
    dw  0x000003D4

    entry_anim_struct_1_BANJO:
    dw  0x040A0000
    dw  Character.BANJO_file_8_ptr
    OS.copy_segment(0xA9D14, 0x10)
	dw	0x00000878					        // Banjo entry alters these
	dw  0x00000980
    dw  0x00000A54
    dw  0x00000A9C

    // @ Description
    // loads a different animation struct when Young Link or Marth use their entry animation.
    scope get_entry_anim_struct_1: {
        OS.patch_start(0x7E2E8, 0x80102AE8)
        j       get_entry_anim_struct_1
        sw      a0, 0x0018(sp)              // original line 1
        _return:
        OS.patch_end()

        // s0 = player struct
        sw      ra, 0x0014(sp)              // original line 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.MARTH  // t1 = id.MARTH
        li      a0, entry_anim_struct_1_MARTH       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Marth
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a0, entry_anim_struct_1_YLINK       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Young Link
        lli     t1, Character.id.MARINA     // t1 = id.MARINA
        li      a0, entry_anim_struct_1_MARINA // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Marina
        ori     t1, r0, Character.id.BANJO  // t1 = id.BANJO
        li      a0, entry_anim_struct_1_BANJO       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Banjo
        lli     t1, Character.id.GOEMON     // t1 = id.GOEMON
        beq     t0, t1, _skip               // branch if Goemon
        lli     t1, Character.id.EBI        // t1 = id.EBI
        beq     t0, t1, _skip               // branch if Ebisumaru
        lw      t0, 0x0004(sp)              // ~

        // normal path
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop

		_custom:
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       0x80102AFC                  // return
        nop

        _skip:
        lw      t1, 0x0008(sp)              // load t0, t1
        or      v0, r0, r0                  // pretend 0x800FDAFC returned no object
        j       0x80102AFC                  // return
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // loads a different animation struct when Young Link or Marth use their entry animation.
    scope get_entry_anim_struct_2: {
        OS.patch_start(0x7E344, 0x80102B44)
        j       get_entry_anim_struct_2
        sw      a0, 0x0018(sp)              // original line 1
        _return:
        OS.patch_end()

        // s0 = player struct
        sw      ra, 0x0014(sp)              // original line 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.MARTH  // t1 = id.MARTH
        li      a0, entry_anim_struct_2_MARTH       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Marth
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a0, entry_anim_struct_2_YLINK       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Young Link
        lli     t1, Character.id.MARINA     // t1 = id.MARINA
        li      a0, entry_anim_struct_2_MARINA // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Marina
        ori     t1, r0, Character.id.BANJO  // t1 = id.BANJO
        li      a0, entry_anim_struct_2_BANJO       // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if BANJO
        lli     t1, Character.id.GOEMON     // t1 = id.GOEMON
        li      a0, entry_anim_struct_2_GOEMON // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Goemon
        lli     t1, Character.id.EBI        // t1 = id.EBI
        li      a0, entry_anim_struct_2_EBI // a0 = entry_anim_struct
        beq     t0, t1, _custom             // branch if Ebisumaru
        lw      t0, 0x0004(sp)              // ~

        // normal path
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop

		_custom:
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       0x80102B58                  // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when a Link bomb is created
    // uses character id to determine which bomb struct to load
    // stores character id in an active item struct
    // uses a different render routine for Young Link
    scope create_bomb_: {
        OS.patch_start(0x100FE0, 0x801865A0)
        addiu   sp, sp,-0x0048              //modified original line 1
        or      a3, a2, r0                  // ~
        or      a2, a1, r0                  // ~
        sw      a1, 0x003C(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0038(sp)              // original code
        j       get_bomb_struct_
        nop
        _get_bomb_struct_return:
        OS.patch_end()

        OS.patch_start(0x101014, 0x801865D4)
        j       save_character_id_
        nop
        _save_character_id_return:
        OS.patch_end()

        OS.patch_start(0x10101C, 0x801865DC)
        j       render_routine_
        addiu   a1, r0, 0x002E              // original line 1 (render routine = 0x2E)
        _render_routine_return:
        OS.patch_end()

        OS.patch_start(0x101098, 0x80186658)
        addiu   sp, sp, 0x0048              // modified original final line
        OS.patch_end()

        get_bomb_struct_: {
            // v0 = player struct
            lw      a1, 0x0008(v0)              // a1 = character id
            sw      a1, 0x0040(sp)              // store character id
            addiu   sp, sp,-0x0010              // allocate stack space
            sw      t0, 0x0004(sp)              // ~
            sw      t1, 0x0008(sp)              // store t0, t1

            ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
            li      t0, YoungLinkDSP.item_info_array // t0 = YoungLinkDSP.item_info_array
            beq     t1, a1, _end                // end if character id = YLINK
            nop
            ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
            li      t0, bomb_struct_elink       // t0 = Elink.bomb_struct
            beq     t1, a1, _end                // end if character id = ELINK
            nop
            ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
            li      t0, bomb_struct_jlink       // t0 = Jlink.bomb_struct
            beq     t1, a1, _end                // end if character id = JLINK
            nop
            li      t0, 0x8018B6C0              // t0 = original bomb struct

            _end:
            or      a1, t0, r0                  // a0 = original bomb struct
            lw      t0, 0x0004(sp)              // ~
            lw      t1, 0x0008(sp)              // load t0, t1
            addiu   sp, sp, 0x0010              // deallocate stack space
            j       _get_bomb_struct_return     // return
            nop
        }

        save_character_id_: {
            lw      v1, 0x0084(v0)              // original line 1 (v1 = item special struct)
            lw      a0, 0x0040(sp)              // a0 = character id
            sw      a0, 0x0100(v1)              // store character id in item special struct (unused? segment)
            lli     at, Character.id.YLINK      // at = id.YLINK
            bnel    at, a0, _end_save_id        // end if character ~= YLINK
            lw      a0, 0x0074(v0)              // original line 2

            // set up a couple of values for Bombchu if the character is Young Link
            sw      r0, 0x01D0(v1)              // custom FGM pointer = 0
            li      a0, YoungLinkDSP.bombchu_blast_zone_
            sw      a0, 0x0398(v1)              // store custom blast zone routine
            lw      a0, 0x0074(v0)              // original line 2

            _end_save_id:
            j       _save_character_id_return   // return
            nop
        }

        render_routine_: {
            lw      a2, 0x0040(sp)              // a2 = character id
            lli     at, Character.id.YLINK      // at = id.YLINK
            beql    at, a2, pc() + 8            // if character = YLINK...
            lli     a1, 0x0048                  // ...a1(render routine) = 0x48
            j       _render_routine_return      // return
            or      a2, r0, r0                  // original line 2
        }
    }

    // @ Description
    // modifies a subroutine which runs when the bomb is flashing
    // loads character id from active item struct
    // uses character id to determine which bomb struct to load
    scope bomb_flash_: {
        OS.patch_start(0x10041C, 0x801859DC)
        j       bomb_flash_
        nop
        _return:
        OS.patch_end()

        lw      t7, 0x0100(v1)              // t7 = character id
        ori     a2, r0, Character.id.YLINK  // a2 = id.YLINK
        li      t6, YoungLinkDSP.item_info_array // t6 = YoungLinkDSP.item_info_array
        beq     t7, a2, _end                // end if character id = YLINK
        nop
        ori     a2, r0, Character.id.ELINK  // a2 = id.ELINK
        li      t6, bomb_struct_elink       // t6 = ELink.bomb_struct
        beq     t7, a2, _end                // end if character id = ELINK
        nop
        ori     a2, r0, Character.id.JLINK  // a2 = id.JLINK
        li      t6, bomb_struct_jlink       // t6 = JLink.bomb_struct
        beq     t7, a2, _end                // end if character id = JLINK
        nop
        li      t6, 0x8018B6C0              // t6 = original bomb struct
        _end:
        lw      t6, 0x0004(t6)              // t6 = file 1 pointer address
        lhu     a2, 0x0354(v1)              // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when the bomb explodes
    // loads character id from active item struct
    // uses character id to determine which bomb struct to load
    scope bomb_explosion_: {
        OS.patch_start(0x100DF0, 0x801863B0)
        j       bomb_explosion_
        nop
        _return:
        OS.patch_end()

        lw      t7, 0x0100(v0)              // t7 = character id
        ori     a1, r0, Character.id.YLINK  // a1 = id.YLINK
        li      t6, YoungLinkDSP.item_info_array // t6 = YoungLinkDSP.item_info_array
        beq     t7, a1, _end                // end if character id = YLINK
        nop
        ori     a1, r0, Character.id.ELINK  // a1 = id.ELINK
        li      t6, bomb_struct_elink       // t6 = ELink.bomb_struct
        beq     t7, a1, _end                // end if character id = ELINK
        nop
        ori     a1, r0, Character.id.JLINK  // a1 = id.JLINK
        li      t6, bomb_struct_jlink       // t6 = JLink.bomb_struct
        beq     t7, a1, _end                // end if character id = JLINK
        nop
        li      t6, 0x8018B6C0              // t6 = original bomb struct
        _end:
        lw      t6, 0x0004(t6)              // t6 = file 1 pointer address
        j       _return                     // return
        nop
    }

    // @ Description
    // adds a check for Young Link to 2 asm routines which are responsible for swapping Link's
    // shield between his hand and back when he starts and finishes holding an item
    scope item_shield_fix_: {
        OS.patch_start(0x63F0C, 0x800E870C)
        jal     item_shield_fix_
        nop
        OS.patch_end()

        OS.patch_start(0x63F60, 0x800E8760)
        jal     item_shield_fix_
        nop
        OS.patch_end()

        // v1 = character id
        // at = Link id
        beq     v1, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v1, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v1, at, _end                // end if id = YLINK
        nop
        ori     at, r0, Character.id.NYLINK  // at = NYLINK
        beq     v1, at, _end                // end if id = NYLINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v1, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v1, at, _end                // end if id = JLINK
        nop

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // adds a check for Young Link to an asm routine which is responsible for swapping Link's
    // shield between his hand and back when he grabs an opponent
    scope grab_shield_fix_: {
        OS.patch_start(0xC4A98, 0x8014A058)
        jal     grab_shield_fix_
        nop
        OS.patch_end()

        // v0 = character id
        // at = Link id
        beq     v0, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v0, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v0, at, _end                // end if id = YLINK
        nop
        ori     at, r0, Character.id.NYLINK  // at = NYLINK
        beq     v0, at, _end                // end if id = NYLINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v0, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v0, at, _end                // end if id = JLINK
        nop

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // adds a check for Young Link to 2 asm routines which are responsible for determining the
    // unique properties of Link's dair
    scope dair_fix_: {
        OS.patch_start(0xCB334, 0x801508F4)
        jal     dair_fix_
        nop
        OS.patch_end()

        OS.patch_start(0xCB3D4, 0x80150994)
        jal     dair_fix_
        nop
        OS.patch_end()

        // v1 = character id
        // at = Link id
        beq     v1, at, _end                // end if id = LINK
        nop
        ori     at, r0, Character.id.NLINK  // at = NLINK
        beq     v1, at, _end                // end if id = NLINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     v1, at, _end                // end if id = YLINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     v1, at, _end                // end if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     v1, at, _end                // end if id = JLINK
        nop
        ori     at, r0, Character.id.NYLINK  // at = NYLINK
        beq     v1, at, _end                // end if id = NYLINK
        nop

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // adds a check for Young Link to an asm routine which is responsible for updating the position
    // of and drawing(?) Link's sword trail
    scope sword_trail_fix_: {
        OS.patch_start(0x61F68, 0x800E6768)
        j       sword_trail_fix_
        nop
        _return:
        OS.patch_end()

        // t8 = character id
        // at = Link id
        beq     t8, at, _branch_end         // branch if id = LINK
        nop
        ori     at, r0, Character.id.YLINK  // at = YLINK
        beq     t8, at, _branch_end         // branch if id = YLINK
        nop
        ori     at, r0, Character.id.ELINK  // at = ELINK
        beq     t8, at, _branch_end         // branch if id = ELINK
        nop
        ori     at, r0, Character.id.JLINK  // at = JLINK
        beq     t8, at, _branch_end         // branch if id = JLINK
        nop

        _end:
        j       0x800E69B4                  // modified original line 1
        lw      ra, 0x0024(sp)              // original line 2

        _branch_end:
        j       _return                     // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine which up special struct to load
    // not 100% sure what this struct is for
    scope up_special_fix_: {
        OS.patch_start(0xE7594, 0x8016CB54)
        j       up_special_fix_
        nop
        _return:
        OS.patch_end()

        // s1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1

        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, up_special_struct       // a1 = YoungLink.up_special_struct
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
        li      a1, up_special_struct_elink // a1 = ELink.up_special_struct
        beq     t1, t0, _end                // end if character id = ELINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        li      a1, up_special_struct_jlink // a1 = JLink.up_special_struct
        beq     t1, t0, _end                // end if character id = JLINK
        nop
        li      a1, 0x80189360              // a1 = original up special struct (original line 1/2)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when Link uses neutral special
    // uses character id to determine which boomerang struct to load
    // not 100% sure what this struct is for
    scope boomerang_fix_: {
        OS.patch_start(0xE8500, 0x8016DAC0)
        j       boomerang_fix_
        nop
        _return:
        OS.patch_end()

        // s1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1

        lw      t0, 0x0008(s1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, boomerang_struct        // a1 = YoungLink.boomerang_struct
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        ori     t1, r0, Character.id.ELINK  // t1 = id.ELINK
        li      a1, boomerang_struct_elink  // a1 = ELink.boomerang_struct
        beq     t1, t0, _end                // end if character id = ELINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        li      a1, boomerang_struct_jlink  // a1 = JLink.boomerang_struct
        beq     t1, t0, _end                // end if character id = JLINK
        nop
        li      a1, 0x801893A0              // a1 = original boomerang struct (original line 1)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        add.s   f8, f4, f6                  // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine y velocity
    scope up_special_velocity_: {
        OS.patch_start(0xDEDC8, 0x80164388)
        j       up_special_velocity_
        nop
        _return:
        OS.patch_end()

        // v0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v0)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     at, 0x4250                  // at = float: 52
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        ori     t1, r0, Character.id.JLINK  // t1 = id.JLINK
        lui     at, 0x428E                  // at = float: 71
        beq     t1, t0, _end                // end if character id = JLINK
        nop
        lui     at, 0x428A                  // at = float: 69 (original line 1)

        _end:
        mtc1    at, f4                      // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

	// @ Description
	// Adds Link Variants to a Character ID check and pull out more bombs
	scope cpu_pull_out_bombs_: {
    OS.patch_start(0xB3444, 0x80138A04)
	    j 		cpu_pull_out_bombs_
	    lw		a0, 0x0008(a2)				// get character id. original line 1.
	    _return:
	    OS.patch_end()

	    // at = Character.id.LINK
	    beq		a0, at, _pull_bomb
	    addiu 	at, r0, Character.id.ELINK
	    beq		a0, at, _pull_bomb			// branch if ELink
	    addiu 	at, r0, Character.id.JLINK
	    beq		a0, at, _pull_bomb			// branch if JLink
	    addiu 	at, r0, Character.id.MARINA
	    beq		a0, at, _marina			    // branch if Marina
	    addiu 	at, r0, Character.id.YLINK
	    bne		a0, at, _normal				// branch if not YLink
	    nop

	    _pull_bomb:
	    j 		0x80138A24					// original branch location + 0x4
	    or		a0, a2, r0					// branch original line 1

		_marina:
		sw      v1, 0x0028(sp)				// original line so we can use v1
        lw      v1, 0x0ADC(s0)              // t6 = charge level
        lli     at, 1 						// at = 1
		beql    v1, at, _normal				// no pull if charge = 1
		lw      v1, 0x0028(sp)				// restore v1
		beql    v1, r0, _normal				// no pull if charge = 0
		lw      v1, 0x0028(sp)				// restore v1
	    j 		0x80138A24 + 0x4			// original branch location + 0x4
	    or		a0, a2, r0					// original line

	    _normal:
	    j		_return						// go to Ness check
	    nop

	}

    }
