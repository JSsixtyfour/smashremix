// ZCancel.asm
if !{defined __ZCancel__} {
define __ZCancel__()

include "Color.asm"
include "Global.asm"
include "OS.asm"
include "String.asm"
include "Toggles.asm"

// @ Description
// Z Cancel stuff
scope ZCancel {

    // @ Description
    // An optional toggle to spice things up
    scope _cruel_z_cancel: {
        scope CRUEL_Z_CANCEL_MODE: {
			constant OFF(0)
			constant ON(1)
			constant LAVA(2)
			constant SHIELD_BREAK(3)
			constant INSTANT_KO(4)
			constant FORCE_TAUNT(5)
			constant BURY(6)
			constant RANDOM(7)
		}
	
		OS.patch_start(0xCB488, 0x80150A48)
		j       _cruel_z_cancel
		lw      t7, 0x09C4(v1)           // original line 1
		_cruel_z_cancel_return:
		OS.patch_end()

		OS.read_word(Toggles.entry_punish_on_failed_z_cancel + 0x4, t8) // t8 = failed z cancel toggle
		beqz    t8, _end                 // branch if no extra punishment
		lw      t9, 0x0028(v1)           // original line 2
		li		at, _last_known_speed_value
		sw		v0, 0x0000(at)			// save last known landing speed (in case invulnerable)
		
		_get_entry:
		li		at, jump_table
		sll		t8, t8, 2
		addu	t8, at, t8				// t8 = entry in jump table
		lw		t8, -0x0004(t8)			// ~
		jr		t8
		nop
		
		jump_table:
		dw	_on
		dw	_lava
		dw	_shield_break
		dw	_instant_ko
		dw	_force_taunt
		dw	_bury
		dw	_random

		_on:
		lli     t8, 0x0012               // t8 =  custom surface flag (damage, minimal KB)
		li		at, _last_known_speed_value
		lw		v0, 0x0000(at)			 // load last known landing speed
		sh      t8, 0x00F6(v1)           // overwrite surface flag to bring pain to this player

		_end:
		j      _cruel_z_cancel_return + 0x4  // return
		lw     t8, 0x0064(t7)            // original line 3

		_lava:
		lli     t8, 0x001E               // t8 =  cruel lava flag (damage + KB)
		li		at, _last_known_speed_value
		lw		v0, 0x0000(at)			 // load last known landing speed (in case invulnerable)
		j       _cruel_z_cancel_return   // return
		sh      t8, 0x00F6(v1)           // overwrite surface flag to bring pain to this player

		_force_taunt:
		jal     0x8014E6E0               // set to taunt action
		nop
		j       0x80150AF0 + 0x4         // and skip to end
		lw      ra, 0x0014(sp)
		
		_bury:
		jal     Damage.bury_initial_     // bury player
		addiu   a1, r0, 0x0001			 // a1 = bury this player
		j       0x80150AF0 + 0x4         // and skip to end
		lw      ra, 0x0014(sp)
		
		_random:
        lli     a0, CRUEL_Z_CANCEL_MODE.RANDOM - 1 // arg0 = max value - 1
        jal     Global.get_random_int_      // returns a random value from 1 to CRUEL_Z_CANCEL_MODE.RANDOM
        nop
		addiu   v0, v0, 1					// increase value by 1 so we don't get no punishment
		lw      v1, 0x001C(sp)           	// restore
		lw		a0, 0x0020(sp)				// ~
		beqz	v0, _end
		lw      t9, 0x0028(v1)           	// original line 2
		b		_get_entry					// do punishment
		or		t8, v0, r0					// t8 = random punishment
		

		_shield_break:
		jal     0x80149488               // set to shield break action
		nop
		lw      v1, 0x001C(sp)           // v1 = player struct
		lui     at, 0x4280               // overwrite vertical velocity
		sw      at, 0x004C(v1)           // ~

		j       0x80150AF0 + 0x4         // and skip to end
		lw      ra, 0x0014(sp)

		_instant_ko:
		jal     0x8013C1C4               // set to shield break action
		nop
		j       0x80150AF0 + 0x4         // and skip to end
		lw      ra, 0x0014(sp)
	
		
		_last_known_speed_value:
		dw 0
	}

}

}
