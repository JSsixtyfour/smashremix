// jigglypuffkirbyshared.asm

// This file contains shared functions by Jigglypuff and Kirby Clones.

scope JigglypuffKirbyShared: {

	constant kirby_jump_multiplier_table(0x80188578)// NA, NA, 60.0, 52.0, 47.0, 40.0
	constant puff_jump_multiplier_table(0x80188588)	// NA, NA, 60.0, 40.0, 20.0, 0.0

    // character ID check add for when Jigglypuff Clones are doing 2+ jumps. This is the first of the double jump routines
    scope jump_fix_1: {
        OS.patch_start(0xBA9A8, 0x8013FF68)
        j       jump_fix_1
        addiu at, r0, 0x000A            // original line 1
        _return:
        OS.patch_end()

        beq     v0, at, _puff_jump_1       // modified original line 2
        addiu   at, r0, Character.id.DEDEDE   // Dedede ID
        beq     v0, at, _kirby_jump_1
        addiu   at, r0, Character.id.JPUFF    // JPuff ID
        beq     v0, at, _puff_jump_1
        addiu   at, r0, Character.id.EPUFF    // EPuff ID
        beq     v0, at, _puff_jump_1
        addiu   at, r0, Character.id.JKIRBY    // JKirby ID
        beq     v0, at, _kirby_jump_1
        addiu   at, r0, Character.id.NDEDEDE    // NDedede ID
        beq     v0, at, _kirby_jump_1
        nop
        j       _return                     // return
        nop

        _puff_jump_1:
        j       0x8013FF9C                  // routine for puff jumps
        nop

        _kirby_jump_1:
        j       0x8013FF8C                  // routine for puff jumps
        nop
    }

    // character ID check add for when Jigglypuff Clones are doing 3+ jumps
    scope jump_fix_2: {
        OS.patch_start(0xBAA8C, 0x8014004C)
        j       jump_fix_2
        addiu	t6, r0, 0x0050
        _return:
        OS.patch_end()

		// at = Character.id.PUFF
        beq     v0, at, _puff_jump_2            // modified original line 2
        addiu   at, r0, Character.id.DEDEDE     // Dedede ID
        beq     v0, at, _dedede_jump_2
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v0, at, _puff_jump_2
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v0, at, _puff_jump_2
        addiu   at, r0, Character.id.JKIRBY   // JKirby ID
        beq     v0, at, _kirby_jump_2
        addiu   at, r0, Character.id.NDEDEDE   // NDedede ID
        beq     v0, at, _dedede_jump_2
        nop
        j       _return                     // return
        nop

        _puff_jump_2:
		constant puff_jump_decay(0x42A0)	// 80.0
        j       0x801400A0                  // routine for puff jumps
        nop

        _kirby_jump_2:
		constant kirby_jump_decay(0x42A0)	// 80.0
        j       0x80140070                  // routine for kirby jumps
        nop

        _dedede_jump_2:
		mtc1	t4, f4						// move t4 to float
		lui		at, Dedede.jump_decay       // at - Dededes jump decay
		mtc1	at, f8						// move at to float
		cvt.s.w	f6, f4						// convert f6
		li		at, Dedede.jump_multiplier_table // at = Dededes jump multipler table
		sll		t5, v1, 2					// t5 = offset to current jump multipler
		addu	at, at, t5					// at = current index
		lwc1	f16, 0x0000(at)				// f16 = jump multipler for this jump
        j       0x80140090                  // goto the rest of the kirby extra jump routine
		nop
    }

    // character ID check add for when Jigglypuff Clones are jumping/in the air.
    scope jump_fix_3: {
        OS.patch_start(0xBAC20, 0x801401E0)
        j       jump_fix_3
        nop
        _return:
        OS.patch_end()

        beq     v1, at, _puff_jump_3            // modified original line 1
        addiu   at, r0, Character.id.DEDEDE     // Dedede ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.JKIRBY   // J Kirby ID
        beq     v1, at, _puff_jump_3
        addiu   at, r0, Character.id.NDEDEDE     // NDedede ID
        beq     v1, at, _puff_jump_3
        nop
        j       _return                     // return
        addiu   at, r0, 0x0018              // original line 2

        _puff_jump_3:
        j       0x801401F0                  // routine for puff jumps
        addiu   at, r0, 0x0018              // original line 2
    }

    // character ID check add for when Jigglypuff Clones are doing 2+ jumps. This is the second of the double jump routines.
    scope jump_fix_4: {
        OS.patch_start(0xBA6F0, 0x8013FCB0)
        j       jump_fix_4
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()

        beq     v0, at, _puff_jump_4            // modified original line 1
        addiu   at, r0, Character.id.DEDEDE     // Dedede ID
        beq     v0, at, _kirby_jump_4
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v0, at, _puff_jump_4
        addiu   at, r0, Character.id.EPUFF   // EPuff ID
        beq     v0, at, _puff_jump_4
        addiu   at, r0, Character.id.JKIRBY   // JKIRBY ID
        beq     v0, at, _kirby_jump_4
        addiu   at, r0, Character.id.NDEDEDE     // NDedede ID
        beq     v0, at, _kirby_jump_4
        nop
        j       _return                     // return
        nop

        _puff_jump_4:
        j       0x8013FD18                  // routine for puff jumps
        nop

        _kirby_jump_4:
        j       0x8013FCD4                  // routine for puff jumps
        addiu   at, r0, 0x000A
    }

    // character ID check add for when Jigglypuff Clones are jumping.
    scope jump_fix_5: {
        OS.patch_start(0xBAC78, 0x80140238)
        j       jump_fix_5
        nop
        _return:
        OS.patch_end()

        beq     v1, at, _puff_jump_5            // modified original line 1
        addiu   at, r0, Character.id.DEDEDE     // Dedede ID
        beq     v1, at, _kirby_jump_5
        addiu   at, r0, Character.id.JPUFF      // JPuff ID
        beq     v1, at, _puff_jump_5
        addiu   at, r0, Character.id.EPUFF      // EPuff ID
        beq     v1, at, _puff_jump_5
        addiu   at, r0, Character.id.JKIRBY     // JKIrby ID
        beq     v1, at, _kirby_jump_5
        addiu   at, r0, Character.id.NDEDEDE     // Dedede ID
        beq     v1, at, _kirby_jump_5
        nop
        j       _return                         // return
        addiu   at, r0, 0x0016

        _puff_jump_5:
        j       0x8014029C                      // routine for puff jumps
        addiu   at, r0, 0x0016

        _kirby_jump_5:
        j       0x80140258                      // routine for puff jumps
        addiu   at, r0, 0x000A
    }

    // character ID check add for when Kirby Clones receive their boomerang.
    scope kirby_boomerangfix_1: {
        OS.patch_start(0xE7DFC, 0x8016D3BC)
        j       kirby_boomerangfix_1
        addiu   at, r0, 0x0008                  // original line 1
        _return:
        OS.patch_end()

        beq     v1, at, _boomer_fix_1           // modified original line 2
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, at, _boomer_fix_1
        nop
        j       _return                         // return
        nop

        _boomer_fix_1:
        j       0x8016D3D0                      // routine for kirby bommerang
        nop
    }

    // character ID check add for when Kirby Clones receive their boomerang.
    scope kirby_boomerangfix_2: {
        OS.patch_start(0xE7D70, 0x8016D330)
        j       kirby_boomerangfix_2
        lw      a1, 0x0008(v1)                 // original line 1
        _return:
        OS.patch_end()

        beq     a1, at, _boomer_fix_2            // modified original line 2
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     a1, at, _boomer_fix_2
        nop
        j       _return                     // return
        nop

        _boomer_fix_2:
        j       0x8016D344                  // routine for kirby bommerang
        nop
    }

    // Kirby has a hardcoded projectile struct for his up special similar to Ness and Link. This code inserts a new pointer to the clones main file so the game doesn't crash.
    scope kirby_special_struct_fix: {
        OS.patch_start(0xE68E0, 0x8016BEA0)
        j       kirby_special_struct_fix
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t2, 0x0008(t6)                  // load character struct from t6
        addiu   t1, r0, Character.id.JKIRBY     // JKIRBY ID
        li      a1, upspecial_struct_jkirby    // JKirby File Pointer placed in correct location
        beq     t1, t2, _end
        nop

        lui     a1, 0x8019                 // original line 1
        addiu   a1, a1, 0x92A0             // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    // character ID check add for when Kirby Clones use their infinite.
    scope kirby_infinite_1: {
        OS.patch_start(0xC9C0C, 0x8014F1CC)
        j       kirby_infinite_1
        or      s0, a0, r0                 // original line 2
        _return:
        OS.patch_end()


        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     t6, at, _infinite_fix_1
        nop
        j       _return                     // return
        addiu   at, r0, 0x0008              // original line 1

        _infinite_fix_1:
        j       0x8014F1DC                  // routine for kirby infinite
        addiu   at, r0, 0x0008              // original line 1
    }

    // character ID check add for when Kirby Clones use forward throw.
    scope kirby_fthrow_1_fix: {
        OS.patch_start(0xC4C78, 0x8014A238)
        j       kirby_fthrow_1_fix
        or      a0, s0, r0                 // original line 2
        _return:
        OS.patch_end()



        beq     v0, at, _kirbyfthrow_1          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _kirbyfthrow_1
        nop
		addiu	t3, r0, 0x00E5					// Set correct action ID for bowser
		addiu   at, r0, Character.id.BOWSER     // BOWSER ID
		beq     v0, at, _kirbyfthrow_1
		addiu   at, r0, Character.id.GBOWSER    // GBOWSER ID
		beq     v0, at, _kirbyfthrow_1
        nop
        j       _return                     // return
        nop

        _kirbyfthrow_1:
        addiu   sp, sp, -0x0010
        sw      ra, 0x0004(sp)
        jal     PokemonAnnouncer.seismic_toss_announcement_
        nop
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0010
        j       0x8014A24C                  // routine for kirby fthrow
        nop                                 // original line 1
    }

    // character ID check add for when Kirby Clones use forward throw.
    scope kirby_fthrow_2_fix: {
        OS.patch_start(0xC4D8C, 0x8014A34C)
        j       kirby_fthrow_2_fix
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _kirbyfthrow_2          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _kirbyfthrow_2
        nop
        j       _return                     // return
        addiu   at, r0, 0x0016              // original line 2

        _kirbyfthrow_2:
        j       0x8014A358                  // routine for kirby fthrow
        addiu   at, r0, 0x0016              // original line 2
    }

    // character ID check add for when Kirby and Link Clones hit the blast wall.
    scope kirby_blast_fix_1: {
        OS.patch_start(0x531B0, 0x800D79B0)
        j       kirby_blast_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _kirbyblast_1          // modified original line 1
        addiu   at, r0, Character.id.JKIRBY    // JKIRBY ID
        beq     v0, at, _kirbyblast_1

        addiu   at, r0, Character.id.YLINK     // YLINK ID
        beq     v0, at, _linkblast_1
        addiu   at, r0, Character.id.ELINK     // ELINK ID
        beq     v0, at, _linkblast_1
        addiu   at, r0, Character.id.JLINK     // JLINK ID
        beq     v0, at, _linkblast_1
        addiu   at, r0, Character.id.BOWSER    // BOWSER ID
        bne     v0, at, _normal
        nop

        addiu   at, r0, 0x0014
        sh      at, 0x0ADE(v1)              // refill ammo

        _normal:
        j       _return                     // return
        addiu   at, r0, 0x0013              // original line 2

        _kirbyblast_1:
        j       0x800D79C8                  // routine for kirby blast wall
        addiu   at, r0, 0x0013              // original line 2

        _linkblast_1:
        j       0x800D79D8                  // routine for link blast wall
        addiu   at, r0, 0x0008              // original line 2
    }

    // character ID check add for loading Kirby with a hat.
    scope kirby_load_with_hat_fix_: {
        OS.patch_start(0x53654, 0x800D7E54)
        j       kirby_load_with_hat_fix_
        nop                                 // original line 2
        _return:
        OS.patch_end()

        beq     v0, t3, _kirby              // original line 1: bne v0, t3, 0x800D7F0C
        addiu   v0, r0, Character.id.JKIRBY // v0 = JKIRBY ID
        beq     v0, t3, _kirby
        nop

        _regular:
        j       0x800D7F0C                  // not Kirby, so perform branch from original line 1
        nop

        _kirby:
        j       _return                     // return
        nop                                 // original line 2
    }

    // character ID check add for when Kirby Clones use taunt. This ensures that he abandons his power.
    scope kirby_taunt_fix_1: {
        OS.patch_start(0xC9138, 0x8014E6F8)
        j       kirby_taunt_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v1, a1, _kirby_taunt_1            // modified original line 1, checking to see if the character is Kirby
        nop
        addiu   a1, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, a1, _kirby_taunt_1
        addiu   a1, r0, Character.id.KIRBY     // KIRBY ID
        j       _return                     // return
        nop                                 // original line 1 was orinally a beql

        _kirby_taunt_1:
        j       0x8014E70C                  // routine for kirby taunt
        lw      t6, 0x0ADC(v0)              // original line 2
    }

    // character ID check add for when Kirby Clones use taunt. This ensures that he abandons his power.
    // scope kirby_taunt_fix_2: {
    //    OS.patch_start(0xC914C, 0x8014E70C)
    //    j       kirby_taunt_fix_2
    //    nop
    //    _return:
    //    OS.patch_end()
    //
    //    beq     a1, t6, _kirby_taunt_2            // modified original line 1, this is actually checking if he currently has a power
    //    nop
    //    addiu   a1, r0, Character.id.JKIRBY     // JKIRBY ID
    //    beq     a1, t6, _kirby_taunt_2
    //    nop
    //    j       _return                     // return
    //    nop                                 // original line 1 was orinally a beql
    //
    //    _kirby_taunt_2:
    //    j       0x8014E738                  // routine for kirby taunt
    //    addiu   a1, r0, 0x00BD              // original line 2
    // }

    // character ID check add for when Pikachu and Jigglypuff Clones use spawn on stage.
    scope pokemon_spawn_fix: {
        OS.patch_start(0xB8480, 0x8013DA40)
        j       pokemon_spawn_fix
        nop
        _return:
        OS.patch_end()



        beq     v0, at, _pokeballflash          // modified original line 1 part 1

        addiu   at, r0, Character.id.JPUFF      // JPUFF ID
        beq     v0, at, _pokeballflash          // JPUFF Jump
        addiu   at, r0, Character.id.EPUFF      // EPUFF ID
        beq     v0, at, _pokeballflash          // EPUFF Jump

        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v0, at, _pokeballflash          // EPIKA Jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v0, at, _pokeballflash          // JPIKA Jump
        nop

        j       _return                     // return
        addiu   at, r0, 0x0017              // original line 2

        _pokeballflash:
        j       0x8013DA58                  // modified original line 1 part 2
        addiu   at, r0, 0x0017              // original line 2
    }

    // character ID check add for when Pikachu and Jigglypuff Clones wear hats.
    scope pokemon_hat_fix_1: {
        OS.patch_start(0x6D730, 0x800F1F30)
        j       pokemon_hat_fix_1
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.PIKACHU    // PIKA ID
        beq     t9, at, _pikachuhat             // PIKA Jump - original line 1 replacement
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     t9, at, _pikachuhat             // EPIKA Jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     t9, at, _pikachuhat             // JPIKA Jump
        nop

        j       _return                     // return
        addiu   at, r0, 0x000A              // replacing what at would normally be

        _pikachuhat:
        j       0x800F1F40                  // modified original line 1 part 2
        addiu   at, r0, 0x000A              // replacing what at would normally be

        j       _return                     // return
        nop                                 // replacing what at would normally be
    }

    // character ID check add for when Pikachu and Jigglypuff Clones wear hats.
    scope pokemon_hat_fix_2: {
        OS.patch_start(0x6D8E0, 0x800F20E0)
        j       pokemon_hat_fix_2
        or      a1, s1, r0                      // original line 2
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.JIGGLYPUFF     // PUFF ID
        beq     t9, at, _puffhat                    // PUFF Jump - original line 1 replacement
        addiu   at, r0, Character.id.EPUFF          // EPUFF ID
        beq     t9, at, _puffhat                    // EPUFF Jump
        addiu   at, r0, Character.id.JPUFF          // JPUFF ID
        beq     t9, at, _puffhat                    // JPUFF Jump
        nop

        j       _return                     // return
        addiu   at, r0, 0x0009              // replacing what at would normally be

        _puffhat:
        j       0x800F20F0                  // modified original line 1 part 2
        addiu   at, r0, 0x0009              // replacing what at would normally be

        j       _return                     // return
        nop                                 // replacing what at would normally be
    }

    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale: {
        OS.patch_start(0xB165C, 0x80136C1C)
        j       kirby_cpu_inhale
        nop
        _return:
        OS.patch_end()

        beq     v1, at, _kirby
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v1, at, _kirby
        addiu   at, r0, Character.id.DEDEDE     // DEDEDE ID
        beq     v1, at, _kirby
        nop
        j       0x80136C2C                  // modified line 1
        or      v0, r0, r0                  // original line 2

        _dedede:
        j       _return
        or      v0, v1, r0                  // original line 2

        _kirby:
        j       _return
        or      v0, v1, r0                  // original line 2
    }

    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_2: {
        OS.patch_start(0xB3948, 0x80138F08)
        j       kirby_cpu_inhale_2
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _kirby
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     v0, at, _kirby
        addiu   at, r0, Character.id.DEDEDE     // DEDEDE ID
        beq     v0, at, _kirby
        nop
        j       0x80138F18                  // modified line 1
        or      v1, v0, r0                  // original line 2

        _kirby:
        j       _return
        or      v1, v0, r0                  // original line 2
    }

    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_3: {
        OS.patch_start(0xB1B30, 0x801370F0)
        j       kirby_cpu_inhale_3
        nop
        _return:
        OS.patch_end()

        beq     at, a0, _kirby
        nop
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     at, a0, _kirby
        addiu   at, r0, Character.id.DEDEDE     // DEDEDE ID
        beq     at, a0, _dedede
        nop

        _end:
        j       0x80137160                  // modified line 1
        addiu   at, r0, 0x000B              // original line 2

		_dedede:
		lw		v0, 0x0024(a2)					// v0 = current action
		addiu	at, r0, Dedede.Action.NSP_IDLE_GROUND
		beq		at, v0, _dedede_spit
		addiu	at, r0, Dedede.Action.NSP_FALL
		beq		at, v0, _dedede_spit
		nop
        j       0x80137160                  // modified line 1
        addiu   at, r0, 0x000B              // original line 2

        _dedede_spit:
        or		a0, a2, r0
        jal		0x80132758
        lli		a1, AI.ROUTINE.NSP          // press B
        j		0x80137768
        or		v0, r0, r0

        _dedede_hat:
        lw		v0, 0x0024(a2)              // v0 = current action
        addiu	at, r0, Kirby.Action.DEDEDE_NSP_IDLE_GROUND
        beq		at, v0, _dedede_spit
        addiu	at, r0, Kirby.Action.DEDEDE_NSP_FALL
        beq		at, v0, _dedede_spit
        nop
        j       0x80137160                  // modified line 1
        addiu   at, r0, 0x000B              // original line 2

        _kirby:
        lb		at, 0x0980(a2)              // at = current hat ID
        sltiu	at, at, 0x0020              // v0 = dededes hat id
        beqz	at, _dedede_hat             // branch if dedede hat
        nop
        j       _return
        nop
    }

    // character ID check add for when Kirby Clones CPUs inhale an opponent.
    scope kirby_cpu_inhale_4: {
        OS.patch_start(0x5DBE8, 0x800E23E8)
        j       kirby_cpu_inhale_4
        nop
        _return:
        OS.patch_end()

        beq     t0, at, _kirby
        nop
        addiu   at, r0, Character.id.JKIRBY     // JKIRBY ID
        beq     at, t0, _kirby
        addiu   at, r0, Character.id.DEDEDE     // DEDEDE ID
        beq     at, t0, _kirby
        nop

        _end:
        j       0x800E23FC                  // modified line 1
        lw      v0, 0x09E8(s1)              // original line 2

        _kirby:
        j       _return
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when fully charged.
    scope fully_charged_check_: {
        OS.patch_start(0x66424, 0x800EAC24)
        jal     fully_charged_check_
        nop
        OS.patch_end()

        beq     v0, at, j_0x800EAC84        // original line 1, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v0, at, j_0x800EAC84        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        addiu   a3, sp, 0x003C              // original line 2

        j_0x800EAC84:
        j       0x800EAC84
        addiu   a3, sp, 0x003C              // original line 2
    }

    // @ Description
    // Extends a check on ID that occurs when a Kirby clone steals another Kirby clone's copied power.
    scope kirby_power_steal_check_: {
        OS.patch_start(0xDCB3C, 0x801620FC)
        jal     kirby_power_steal_check_
        sh      a0, 0x0B18(v0)              // original line 1
        OS.patch_end()

        beq     v1, at, j_0x80162110        // original line 2, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v1, at, j_0x80162110        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        nop

        j_0x80162110:
        j       0x80162110
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when a Kirby clone's copied power is stolen by another Kirby clone.
    scope kirby_power_stolen_check_: {
        OS.patch_start(0xC6A4C, 0x8014C00C)
        jal     kirby_power_stolen_check_
        addiu   at, r0, 0x0008              // original line 1 (at = Character.id.KIRBY)
        OS.patch_end()

        beq     v0, at, j_0x8014C020        // original line 2, modified to use jump
        lli     at, Character.id.JKIRBY     // at = JKIRBY
        beq     v0, at, j_0x8014C020        // if JKIRBY, take Kirby branch
        nop

        jr      ra
        nop

        j_0x8014C020:
        j       0x8014C020
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when Kirby absorbs or ejects a power.
    scope kirby_power_change_: {
        OS.patch_start(0xDC914, 0x80161ED4)
        j       kirby_power_change_
        nop
        _kirby_power_change_return:
        OS.patch_end()

        beq     v0, at, j_0x80161F04        // original line 1, modified to use jump
        lli     at, Character.id.JPUFF      // at = JPUFF
        beq     v0, at, j_0x80161F04        // if JPUFF, take Jigglypuff branch
        lli     at, Character.id.EPUFF      // at = EPUFF
        beq     v0, at, j_0x80161F04        // if EPUFF, take Jigglypuff branch
        nop

        j       _kirby_power_change_return
        nop

        j_0x80161F04:
        j       0x80161F04
        sw      r0, 0x0AF0(a0)              // original line 2
    }

    // @ Description
    // Fills Kirby's flame ammo after Bowser absorption
    scope kirby_ammo_: {
        OS.patch_start(0xDC9C0, 0x80161F80)
        jal     kirby_ammo_
        sw      v0, 0x0ADC(s0)              // original line 1 (saves Bowser ID to Kirby Power address in player struct)
        _return:
        OS.patch_end()

        ori     t3, r0, Character.id.BOWSER // Bowser ID in t3
        bne     t3, v0, _end
        ori     t3, r0, 0x0014              // max ammo

        sh      t3, 0xAE2(s0)               // save max ammo

        _end:
        j       _return
        addu    t3, v1, t2                  // original line 2
    }

    // Modifies J Kirby's rock form to have the same HP as he does in the J Version
    scope kirby_rock: {
        OS.patch_start(0xDBE64, 0x80161424)
        j       kirby_rock
        lw      v0, 0x0084(a0)                  // original line 1, load player struct
        _return:
        OS.patch_end()

        lli     t0, Character.id.JKIRBY         // at = JKIRBY
        lw      t7, 0x0008(v0)                  // t7 = character id
        beql    t0, t7, _end                    // take branch if J Kirby
        addiu   t9, r0, 0x32                    // 50 HP in hex, J version

        addiu   t9, r0, 0x26                    // original line 2, 38 HP in hex, U version

        _end:
        j       _return                         // return
        nop
    }

    // 80161368+C
    // Modifies J Kirby's rock form to apply a color overlay based on same remaining HP as J Version
    scope kirby_rock_2: {
        OS.patch_start(0xDBDB4, 0x80161374)
        j       kirby_rock_2
        lw      v1, 0x30(v0)                  // original line 1
        _return:
        OS.patch_end()

        lw      at, 0x0008(v0)                  // at = character id
        addiu   at, at, -Character.id.JKIRBY    // ~
        beqzl   at, _end                        // take branch if J Kirby
        slti    at, v1, 0x19                    // 25 HP in hex, J version

        slti    at, v1, 0x16                    // original line 2, 22 HP in hex, U version

        _end:
        j       _return                         // return
        nop
    }

    // 801614B4+30
    // Modifies J Kirby's rock form to have the same minimum aerial duration as he does in the J Version
    scope kirby_rock_3: {
        OS.patch_start(0xDBF24, 0x801614E4)
        j       kirby_rock_3
        lh      a0, 0x0B18(v1)                  // original line 1
        _return:
        OS.patch_end()

        lw      at, 0x0008(v1)                  // at = character id
        addiu   at, at, -Character.id.JKIRBY    // ~
        beqzl   at, _end                        // take branch if J Kirby
        slti    at, a0, 0x92                    // 160 - 14 frames in hex, J version

        slti    at, a0, 0x8E                    // original line 2, 160 - 18 frames in hex, U version

        _end:
        j       _return                         // return
        nop
    }

    // @ Description
    // Allows characters with slow/short aerial hops to make contact with the ledge better during recovering
    scope multi_jump_recovery_fix_: {
        OS.patch_start(0xAFBD8, 0x80135198)
        j     multi_jump_recovery_fix_
        nop
        _return:
        OS.patch_end()

        // v0 = character id
        // at = Jiggly character id
        beq      v0, at, _puff_kirby       // skip if PUFF
        addiu    at, r0, Character.id.JPUFF
        beq      v0, at, _puff_kirby       // skip if JPN PUFF
        addiu    at, r0, Character.id.MARINA
        beq      v0, at, _puff_kirby       // skip if MARINA
        addiu    at, r0, Character.id.DEDEDE
        beq      v0, at, _dedede           // skip if DEDEDE
        addiu    at, r0, Character.id.EPUFF
        beq      v0, at, _puff_kirby       // skip if E PUFF
        addiu    at, r0, Character.id.JKIRBY
        beq      t6, at, _puff_kirby       // skip if J KIRBY
        addiu    v0, r0, Character.id.NMARINA
        beq      v0, at, _puff_kirby       // skip if NMARINA
        addiu    at, r0, Character.id.NDEDEDE
        beq      v0, at, _dedede           // skip if NDEDEDE
        nop

        _normal:
        j       0x80135368                 // skip puff/kirby branch
        or      a0, s0, r0                 // og line 2 (delay slot)

		_dedede:
		lw		v0, 0x0024(s0)             // v0 = current action
		lli 	at, Dedede.Action.USP_MOVE        // at = USP_MOVE action ID
		bne		at, v0, _puff_kirby		   // continue normally if not already doing an up special
		nop
		j		0x80135B68                 // exit function if already doing USP
		lw		ra, 0x0024(sp)

        _puff_kirby:
        j       _return                    // take puff or kirbys branch
        nop

    }

    // @ Description
    // May prevent puff copies from doing an up special to an opponent while they are aerial
    // Hooks into check for vanilla puff
    scope remix_skip_offensive_usp_air_: {
        OS.patch_start(0xAE9B0, 0x80133F70)
        j     remix_skip_offensive_usp_air_
        nop
        OS.patch_end()

        // t6 = character id
        addiu    at, r0, Character.id.JIGGLYPUFF // original line 1
        beq      t6, at, _puff              // no usp if vanilla PUFF
        addiu    at, r0, Character.id.JPUFF
        beq      t6, at, _puff              // no usp if JPN PUFF
        addiu    at, r0, Character.id.EPUFF
        beq      t6, at, _puff              // no usp if E PUFF
        nop

        _usp_possible_attack:
        j       0x80133FB4                  // normal branch for other characters
        nop

        _puff:
        addiu   at, r0, 0x000D              // original logic, flag for Puff USP?
        j       0x80133F84                  // branch seems to prevent the cpu from using the attack
        lbu     t7, 0x0002(v1)              // original logic. affects next attack

    }

    OS.align(16)
    upspecial_struct_jkirby:
    dw 0x03000000
    dw 0x00000004
    dw Character.JKIRBY_file_1_ptr
    OS.copy_segment(0x103CEC, 0x40)

    // kirby shares hardcodings with various characters, check the other files to ensure updated

    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        // if currently doing NSP, hold UP
        lw at, 0x24(a0) // at = action id
        lli t0, Action.JIGGLY.PoundAir
        beq at, t0, _hold_up
        nop

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        mtc1 r0, f0 // guarantee f0 = 0

        // check closest ledge in X
        scope ledge_check: {
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x54(a0) // load nearest RIGHT ledge X

            sub.s f6, f6, f2
            abs.s f6, f6 // f6 = abs(distance) to left ledge

            sub.s f8, f8, f2
            abs.s f8, f8 // f8 = abs(distance) to right ledge

            c.le.s f6, f8
            nop
            bc1f _right
            nop

            _left:
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y
            
            b _check_end
            nop

            _right:
            lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
            lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

            _check_end:
        }

        sub.s f14, f6, f2 // f14 = x diff
        sub.s f12, f8, f4 // f12 = y diff

        // check if too close to use nsp
        lui at, 0x447A
        mtc1 at, f22 // f22 = 1000.0

        abs.s f16, f14 // f16 = abs(x distance to ledge)

        c.le.s f16, f22 // if distance to ledge is lower than 1000.0
        nop
        bc1t _end // do not go for NSP if already close to ledge
        nop

        // check if up high first
        // in this case, go for NSP
        lui at, 0xC4FA
        mtc1 at, f22 // f22 = -2000.0

        c.le.s f12, f22 // if 2000 units or more above ledge
        nop
        bc1t _nsp
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.JumpAerialF
        beq at, t0, _nsp
        lli t0, Action.JIGGLY.Jump2
        beq at, t0, _nsp
        lli t0, Action.JIGGLY.Jump3
        beq at, t0, _nsp
        lli t0, Action.JIGGLY.Jump4
        beq at, t0, _nsp
        lli t0, Action.JIGGLY.Jump5
        beq at, t0, _nsp
        // Skiping last jump since here we want to be able to grab the ledge
        // lli t0, Action.JIGGLY.Jump6
        // beq at, t0, _nsp
        nop

        b _end // no conditions matched, skip
        nop

        _nsp:
        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP_TOWARDS // arg1 = NSP

        b _end
        nop

        // when doing NSP, hold up and towards ledge
        _hold_up:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = NULL so our inputs are not overridden

        lli at, 0x50 // max stick Y value (up)
        sb at, 0x01C9(a0) // save CPU stick y

        c.lt.s f14, f0 // if x diff < 0
        nop
        bc1t _hold_left // if x diff < 0, hold left
        nop

        _hold_right:
        lli at, 0x50 // max stick X value (right)
        b _apply_x // apply X value
        nop
        
        _hold_left:
        addiu at, r0, 0xFFB0 // max stick X value (left)

        _apply_x:
        sb at, 0x01C8(a0) // save CPU stick x

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.JIGGLYPUFF, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JPUFF, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.EPUFF, 0x4)
    dw recovery_logic; OS.patch_end()

    scope cpu_post_process: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Apply only for lv10 CPUs
        lbu t0, 0x13(a0) // t0 = cpu level
        slti t0, t0, 10 // t0 = 0 if 10 or greater
        bnez t0, _end // skip if not lv10
        nop

        // If going for DSP
        lw t0, 0x1D4(a0) // t0 = ft_com->p_command
        li t1, AI.command_table // load command table base address

        lw at, AI.ATTACK_TABLE.DSPG.INPUT << 2(t1)
        beq t0, at, dsp_check
        lw at, AI.ATTACK_TABLE.DSPA.INPUT << 2(t1)
        beq t0, at, dsp_check
        nop

        b _end
        nop

        scope dsp_check: {
            lw at, 0x01FC(a0) // get target player object

            beqz at, _end // if no target object, skip
            nop

            lw at, 0x84(at) // at = target struct

            // skip if the opponent is in shield
            lw t0, 0x24(at) // t0 = target action id
            lli t1, Action.ShieldOn
            beq t0, t1, _no_input
            lli t1, Action.Shield
            beq t0, t1, _no_input
            lli t1, Action.ShieldStun
            beq t0, t1, _no_input
            nop

            // skip if target is below 30%
            lw t0, 0x2C(at) // t0 = target percentage
            lli at, 30
            blt t0, at, _no_input // if percentage < 30, no input
            nop

            b _end // all tests passed, use dsp
            nop

            _no_input:
            // skip DSP
            jal 0x80132758 // execute AI command
            lli a1, AI.ROUTINE.NULL // arg1 = NULL

            _end:
        }

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_post_process, Character.id.JIGGLYPUFF, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JPUFF, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.EPUFF, 0x4)
    dw cpu_post_process; OS.patch_end()

    scope cpu_post_process_kirby: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Apply only for lv10 CPUs
        lbu t0, 0x13(a0) // t0 = cpu level
        slti t0, t0, 10 // t0 = 0 if 10 or greater
        bnez t0, _end // skip if not lv10
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.KIRBY.Stone
        beq t0, at, _dsp_logic
        lli t0, Action.KIRBY.StoneFall
        beq t0, at, _dsp_logic
        lli t0, Action.KIRBY.StoneLanding
        beq t0, at, _dsp_logic
        lli t0, Action.KIRBY.StoneFall2
        beq t0, at, _dsp_logic
        nop
        b _end
        nop

        scope _dsp_logic: {
            addiu at, r0, -1 // at = 0xFFFFFFF
            lw t0, 0xEC(a0) // get current clipping below player
            beq at, t0, _cancel_dsp // cancel if no ground below
            nop

            lw t0, 0x14C(a0) // t0 = kinetic state
            beqz t0, _cancel_dsp // if grounded, cancel dsp
            nop

            jal Character.get_hitbox_collision_flags_ // v0 = collision flags for all active hitboxes
            nop

            andi v0, v0, 0x00F0 // v0 != 0 if hitbox collision has occured
            bnez v0, _cancel_dsp // if the move has hit something, cancel dsp
            nop

            b _end // all tests passed, do not cancel dsp yet
            nop

            _cancel_dsp:
            // mash B so we get out of DSP quickly
            li t5, Global.current_screen_frame_count // ~
            lw t5, 0x0000(t5) // t5 = global frame count
            andi t5, t5, 0x0001
            beqz t5, _dsp_mash_release
            lh at, 0x01C6(a0) // at = buttons pressed
            _dsp_mash_press:
            b _dsp_mash_apply
            ori at, at, 0x4000 // press B
            _dsp_mash_release:
            andi at, at, 0x0000 // release all buttons
            _dsp_mash_apply:
            sh at, 0x01C6(a0) // save press B mask

            jal 0x80132758 // execute AI command
            lli a1, AI.ROUTINE.NULL

            _end:
        }

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_post_process, Character.id.KIRBY, 0x4)
    dw cpu_post_process_kirby; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JKIRBY, 0x4)
    dw cpu_post_process_kirby; OS.patch_end()

    scope cpu_attack_weight: {
        // s0 = character struct
        // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
        // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
        OS.routine_begin(0x20)

        // Check CPU level
        lbu t0, 0x13(s0) // t0 = cpu level
        addiu t0, t0, -10 // t0 = 0 if level 10
        bnez t0, _end // if not lv10, perform original logic
        nop

        lw t0, 0x0(s2) // t0 = input id
        addiu at, r0, AI.ATTACK_TABLE.NSPG.INPUT
        beq t0, at, _nsp
        nop
        b _end // no attack matched
        nop

        _nsp:
        // NSP less often
        // Since it has a lot of startup, puff will spam it when trying to land a KO
        lui at, 0x3D80 // at = 0.0625
        mtc1 at, f4
        b _end
        mul.s f2, f2, f4 // f2 = new weight

        _end:
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_attack_weight, Character.id.JIGGLYPUFF, 0x4)
    dw cpu_attack_weight; OS.patch_end()
    Character.table_patch_start(cpu_attack_weight, Character.id.JPUFF, 0x4)
    dw cpu_attack_weight; OS.patch_end()
    Character.table_patch_start(cpu_attack_weight, Character.id.EPUFF, 0x4)
    dw cpu_attack_weight; OS.patch_end()

    scope cpu_attack_weight_kirby: {
        // s0 = character struct
        // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
        // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
        OS.routine_begin(0x20)

        // Check CPU level
        lbu t0, 0x13(s0) // t0 = cpu level
        addiu t0, t0, -10 // t0 = 0 if level 10
        bnez t0, _end // if not lv10, perform original logic
        nop

        lw t0, 0x0(s2) // t0 = input id
        addiu at, r0, AI.ATTACK_TABLE.NSPG.INPUT
        beq t0, at, _nsp
        nop
        b _end // no attack matched
        nop

        _nsp:
        // nsp more often vs shielding opponents
        lw t4, 0x1CC+0x6C(s0) // opponent struct
        lw t1, 0x24(t4) // opponent's current action
        addiu at, r0, Action.Shield
        beq t1, at, _nsp_continue
        addiu at, r0, Action.ShieldStun
        beq t1, at, _nsp_continue
        addiu at, r0, Action.ShieldOn
        beq t1, at, _nsp_continue
        nop
        b _end // opponent not shielding, skip
        nop
        _nsp_continue:
        lui at, 0x42C8 // at = 100.0
        b _end
        mtc1 at, f2 // f2 = new weight (override)

        _end:
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_attack_weight, Character.id.KIRBY, 0x4)
    dw cpu_attack_weight_kirby; OS.patch_end()
    Character.table_patch_start(cpu_attack_weight, Character.id.JKIRBY, 0x4)
    dw cpu_attack_weight_kirby; OS.patch_end()
}
