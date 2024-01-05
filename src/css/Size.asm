// @ Description
// These constants must be defined for a menu item.
define LABEL("Size")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(2)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(Size.state_table)
constant ONCHANGE_HANDLER(onchange_handler)
constant DISABLES_HIGH_SCORES(OS.TRUE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_giant
dw string_tiny

// @ Description
// Value labels
string_default:; String.insert("Default")
string_giant:; String.insert("Giant")
string_tiny:; String.insert("Tiny")

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~
    sw      t2, 0x000C(sp)                  // ~

	li      t0, Size.state_table            // t0 = size state of 1p address
	lw      t1, 0x0000(t0)                  // t1 = size state 1p
	sw      t1, 0x0010(t0)                  // initialize match size state
	lw      t1, 0x0004(t0)                  // t1 = size state 2p
	sw      t1, 0x0014(t0)                  // initialize match size state
	lw      t1, 0x0008(t0)                  // t1 = size state 3p
	sw      t1, 0x0018(t0)                  // initialize match size state
	lw      t1, 0x000C(t0)                  // t1 = size state 4p
	sw      t1, 0x001C(t0)                  // initialize match size state

	li      t0, Size.match_state_table      // t0 = size state of 1p address
	bnezl   a0, pc() + 8                    // don't clear if p1 is human
	sw      r0, 0x0000(t0)                  // clear 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't clear if p2 is human
	sw      r0, 0x0004(t0)                  // clear 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't clear if p3 is human
	sw      r0, 0x0008(t0)                  // clear 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't clear if p4 is human
	sw      r0, 0x000C(t0)                  // clear 4p

	// Really only need to do this for bonus 1/2 since the character loads before this runs
	li      t0, Size.multiplier_table       // t0 = size multiplier of 1p address
	lui     t2, 0x3F80                      // t2 = 1 (float)
	bnezl   a0, pc() + 8                    // don't clear if p1 is human
	sw      t2, 0x0000(t0)                  // clear 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't clear if p2 is human
	sw      t2, 0x0004(t0)                  // clear 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't clear if p3 is human
	sw      t2, 0x0008(t0)                  // clear 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't clear if p4 is human
	sw      t2, 0x000C(t0)                  // clear 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    lw      t2, 0x000C(sp)                  // ~
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}

// @ Description
// Runs when the menu item value changes
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
// a3 - player object
scope onchange_handler: {
    li      t0, Size.state_table            // t0 = size state of 1p address
	sll     t1, a1, 0x0002                  // t1 = offset to port
	addu    t0, t0, t1                      // t0 = address of size state
	lw      t1, 0x0000(t0)                  // t1 = size state
	sw      t1, 0x0010(t0)                  // initialize match size state

    _end:
    jr      ra
    nop
}

// @ Description
// Runs when a CSS is loaded to ensure the match_state_table is in sync with state_table
// They can really only get out of sync in 1p modes
scope sync_match_state_table_: {
	li      t0, Size.state_table            // t0 = size state of 1p address
	lw      t1, 0x0000(t0)                  // t1 = size state 1p
	sw      t1, 0x0010(t0)                  // initialize match size state
	lw      t1, 0x0004(t0)                  // t1 = size state 2p
	sw      t1, 0x0014(t0)                  // initialize match size state
	lw      t1, 0x0008(t0)                  // t1 = size state 3p
	sw      t1, 0x0018(t0)                  // initialize match size state
	lw      t1, 0x000C(t0)                  // t1 = size state 4p
    jr      ra
	sw      t1, 0x001C(t0)                  // initialize match size state
}
