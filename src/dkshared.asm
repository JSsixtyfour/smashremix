// dkshared.asm

// This file contains shared functions by DK Clones.

scope DKShared {

    // character ID check add for when Donkey Kong Clones are performing cargo hold
    scope cargo_hold_fix_1: {
        OS.patch_start(0xC5564, 0x8014AB24)
        j       cargo_hold_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _dkcargo_jump_1     // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _dkcargo_jump_1
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _dkcargo_jump_1
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _dkcargo_jump_1
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _dkcargo_jump_1:
        j       0x8014AB3C
        addiu   at, r0, 0x0010              // original line 2
    }

    // character ID check add for when Donkey Kong Clones are performing cargo hold
	// Performs action id check for Action.ThrowF
    scope cargo_hold_fix_2: {
        OS.patch_start(0xC4BCC, 0x8014A18C)
        j       cargo_hold_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _dkcargo_jump_2     // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _dkcargo_jump_2
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _dkcargo_jump_2
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _dkcargo_jump_2
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _dkcargo_jump_2:
        j       0x8014A1A4
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones are grabbing a barrel or box
    scope item_fix_1: {
        OS.patch_start(0xC0860, 0x80145E20)
        j       item_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_1        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_1
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_1
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_1
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_1:
        j       0x80145E38
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones are throwing an item
    scope item_fix_2: {
        OS.patch_start(0xC0E60, 0x80146420)
        j       item_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_2        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_2
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_2
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_2
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_2:
        j       0x80146438
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones are throwing a box or barrel
    scope item_fix_3: {
        OS.patch_start(0xC1488, 0x80146A48)
        j       item_fix_3
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_3        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_3
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_3
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_3
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_3:
        j       0x80146A60
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones getting hit while holding a box or barrel
    scope item_fix_4: {
        OS.patch_start(0x65B44, 0x800EA344)
        j       item_fix_4
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_4        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_4
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_4
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_4
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_4:
        j       0x800EA3CA
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones getting hit while holding a box or barrel
    scope item_fix_5: {
        OS.patch_start(0xBC3F4, 0x801419B4)
        j       item_fix_5
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_5        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_5
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_5
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_5
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_5:
        j       0x801419CC
        addiu   at, r0, 0x0010              // original line 2
    }

	// character ID check add for when Donkey Kong Clones getting hit while holding a box or barrel
    scope item_fix_6: {
        OS.patch_start(0xBB804, 0x80140DC4)
        j       item_fix_6
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _item_jump_6        // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, _item_jump_6
        addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v0, at, _item_jump_6
        addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v0, at, _item_jump_6
        nop
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _item_jump_6:
        j       0x80140DDC
        addiu   at, r0, 0x0010              // original line 2
    }

    // @ Description
    // Extends a check on ID that occurs when fully charged.
    scope fully_charged_check_: {
        OS.patch_start(0x66410, 0x800EAC10)
        jal     fully_charged_check_
        nop
        OS.patch_end()

        beq     v0, at, j_0x800EAC64        // original line 1, modified to use jump
        lli     at, Character.id.JDK        // at = JDK
        beq     v0, at, j_0x800EAC64        // if JDK, take DK branch
        nop

        jr      ra
        addiu   at, r0, 0x0003              // original line 2

        j_0x800EAC64:
        j       0x800EAC64
        nop
    }

    // @ Description
    // Extends check in end_overlay that allows a DK-powered Kirby to
    // retain the charged flashing effect when fully charged.
    scope kirby_power_check_flash_: {
        OS.patch_start(0x65200, 0x800E9A00)
        jal     kirby_power_check_flash_
        nop
        OS.patch_end()

        beq     v1, at, j_0x800E9A18        // original line 1, modified to use jump
        lli     at, Character.id.JDK        // at = JDK
        beq     v1, at, j_0x800E9A18        // if JDK, take DK branch
        nop

        jr      ra
        lli     at, Character.id.NDONKEY    // original line 2

        j_0x800E9A18:
        j       0x800E9A18
        nop
    }

    // @ Description
    // Extends a check on ID that occurs when Kirby absorbs or ejects a power.
    scope kirby_power_change_: {
        OS.patch_start(0xDC8FC, 0x80161EBC)
        j       kirby_power_change_
        nop
        _kirby_power_change_return:
        OS.patch_end()

        beq     v0, at, j_0x80161EF0        // original line 1, modified to use jump
        lli     at, Character.id.JDK        // at = JDK
        beq     v0, at, j_0x80161EF0        // if JDK, take DK branch
        nop

        j       _kirby_power_change_return
        addiu   at, r0, 0x0003              // original line 2

        j_0x80161EF0:
        j       0x80161EF0
        nop
    }

    // character ID check add for when Donkey Kong Clones CPUs are functioning
	// Performs action id check for Giant Punch
    scope giant_punch_fix_1: {
        OS.patch_start(0xB1670, 0x80136C30)
        j       giant_punch_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, check_action_giant_punch_ // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v0, at, check_action_giant_punch_
        nop
        j       _return                     // return
        addiu   at, r0, 0x0003              // original line 2

        check_action_giant_punch_:
        j       0x80136C48
        addiu   at, r0, 0x0003              // original line 2
    }

    // character ID check add for when Donkey Kong Clones CPUs are functioning
	// Performs action id check for Giant Punch and Cargo. Modified for Marina
    scope cpu_fix_2: {
        OS.patch_start(0xB39B8, 0x80138F78)
        j       cpu_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v1, at, _cpu_2              // modified original line 1
        addiu   at, r0, Character.id.JDK    // JDK ID
        beq     v1, at, _cpu_2
		addiu   at, r0, Character.id.MARINA // MARINA ID
        beq     v1, at, _marina				// Branch for Marina cpus
		addiu   at, r0, Character.id.NMARINA // NMARINA ID
        beq     v1, at, _marina				// Branch for Marina cpus
        lw		v0, 0x0024(a2)				// v0 = current action id
        j       _return                     // return
        addiu   at, r0, 0x0010              // original line 2

        _cpu_2:
        j       0x80138F90
        addiu   at, r0, 0x0010              // original line 2
	
		_marina:
        lw		v0, 0x0024(a2)				// v0 = current action id
		lli		at, Marina.Action.Cargo
		beq		at, v0, _marina_cargo
		lli		at, Marina.Action.CargoWalk1
		beq		at, v0, _marina_cargo
		lli		at, Marina.Action.CargoWalk2
		beq		at, v0, _marina_cargo
		lli		at, Marina.Action.CargoWalk3
		beq		at, v0, _marina_cargo
		lli		at, Marina.Action.CargoTurn
		beq		at, v0, _marina_cargo
		nop
		
		// if here, no marina cargo
		j		0x8013900C
		addiu	v1, a2, 0x01CC				// v1 = ai struct
		
		_marina_cargo:
        j       0x801392B8					// goto 0x801392B8
        addiu	v0, r0, 0x0000				// return 0
    }

    // character ID check add for when Characters use the barrel as a base for an entry object
    scope barrel_alternate: {
        OS.patch_start(0x7EC28, 0x80103428)
        j       barrel_alternate
        addiu   at, r0, Character.id.SONIC  // SONIC ID
        _return:
        OS.patch_end()

        lw      t6, 0x0008(s0)              // load character ID
        beq     t6, at, _sonic              // modified original line 1
        addiu   at, r0, Character.id.SSONIC // SSONIC ID
        bnel    t6, at, _end
        addiu   a0, a0, 0xE654              // original line 2

        _ssonic:
        addiu   at, r0, 0x0001
        lw      t6, 0x0044(s0)              // load character ID
        bne     t6, at, _ssonic_left        // if facing left, use left
        sw      r0, 0x0044(s0)              // clears out player facing
        li      a0, ssonic_entry_struct_right
        beq     r0, r0, _end
        nop

        _ssonic_left:
        li      a0, ssonic_entry_struct_left
        beq     r0, r0, _end
        nop

        _sonic:
        addiu   at, r0, 0x0001
        lw      t6, 0x0044(s0)              // load character ID
        bne     t6, at, _sonic_left                 // if facing left, use left
        sw      r0, 0x0044(s0)              // clears out player facing
        li      a0, sonic_entry_struct_right
        beq     r0, r0, _end
        nop

        _sonic_left:
        li      a0, sonic_entry_struct_left
        beq     r0, r0, _end
        nop

        _end:
        jal     0x800FDAFC                  // original line 1
        nop

        j       _return                     // return
        nop
    }


    sonic_entry_struct_right:
    // Entry Objects like the barrel have structs which are used to load them, similar to the Blue Falcon and others
    // Needs UPDATED whenever Tails file updated due to offsets
    dw  0x040A0000
    dw  Character.SONIC_file_8_ptr // pointer to pointer to Tails file
    dw  0x1C00001C
    dw  0x00000000
    dw  0x800FD568
    dw  0x80014038
    dw  0x00002A28          // offset
    dw  0x00000000
    dw  0x000068C8          // offset
    dw  0x00000000

    sonic_entry_struct_left:
    // Entry Objects like the barrel have structs which are used to load them, similar to the Blue Falcon and others
    // Needs UPDATED whenever Tails file updated due to offsets
    dw  0x040A0000
    dw  Character.SONIC_file_8_ptr // pointer to pointer to Tails file
    dw  0x1C00001C
    dw  0x00000000
    dw  0x800FD568
    dw  0x80014038
    dw  0x0000A5E8          // offset
    dw  0x00000000
    dw  0x000112AC          // offset
    dw  0x00000000

    ssonic_entry_struct_right:
    // Entry Objects like the barrel have structs which are used to load them, similar to the Blue Falcon and others
    // Needs UPDATED whenever Tails file updated due to offsets
    dw  0x040A0000
    dw  Character.SSONIC_file_8_ptr // pointer to pointer to Tails file
    dw  0x1C00001C
    dw  0x00000000
    dw  0x800FD568
    dw  0x80014038
    dw  0x00002A28          // offset
    dw  0x00000000
    dw  0x000068C8          // offset
    dw  0x00000000

    ssonic_entry_struct_left:
    // Entry Objects like the barrel have structs which are used to load them, similar to the Blue Falcon and others
    // Needs UPDATED whenever Tails file updated due to offsets
    dw  0x040A0000
    dw  Character.SSONIC_file_8_ptr // pointer to pointer to Tails file
    dw  0x1C00001C
    dw  0x00000000
    dw  0x800FD568
    dw  0x80014038
    dw  0x0000A5E8          // offset
    dw  0x00000000
    dw  0x000112AC          // offset
    dw  0x00000000
}
