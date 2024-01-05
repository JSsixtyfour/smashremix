// @ Description
// These constants must be defined for a menu item.
define LABEL("Skeleton")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(1)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(Skeleton.enable_for_port)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.FALSE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_disabled
dw string_enabled

// @ Description
// Value labels
string_disabled:; String.insert("Disabled")
string_enabled:; String.insert("Enabled")

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, Skeleton.enable_for_port    // t0 = enable skeleton of 1p address
	bnezl   a0, pc() + 8                    // don't disable if p1 is human
	sw      r0, 0x0000(t0)                  // disable skeleton 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't disable if p2 is human
	sw      r0, 0x0004(t0)                  // disable skeleton 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't disable if p3 is human
	sw      r0, 0x0008(t0)                  // disable skeleton 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't disable if p4 is human
	sw      r0, 0x000C(t0)                  // disable skeleton 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
