// @ Description
// These constants must be defined for a menu item.
define LABEL("Visibility")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(3)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(CharEnvColor.state_table)
constant ONCHANGE_HANDLER(onchange_handler)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_cloaked
dw string_none
dw string_dark

// @ Description
// Value labels
string_default:; String.insert("Default")
string_cloaked:; String.insert("Cloaked")
string_none:; String.insert("None")
string_dark:; String.insert("Dark")

// @ Description
// Runs when the menu item value changes
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
scope onchange_handler: {
	li      t0, CharEnvColor.override_table
	sll     t1, a1, 0x0002                  // t1 = offset to override value
	addu    t0, t0, t1                      // t0 = address of override value

	beqzl   a2, _end                        // if Default, clear override value
	lli     t1, 0x0000                      // t1 = 0

    lli     t1, CharEnvColor.state.NONE     // t1 = 2 (None)
    beql    a2, t1, _end                    // if None, set override value to 0xFFFFFF01
    addiu   t1, r0, -0x00FF                 // t1 = 0xFFFFFF00

    lli     t1, CharEnvColor.state.DARK     // t1 = 3 (Dark)
    beql    a2, t1, _end                    // if Dark, set override value to 0x000000FF
    addiu   t1, r0, 0x00FF                  // t1 = 0x000000FF

    // if we're here, the value is Cloaked, and I don't know how to do that yet!
    addiu   t1, r0, -0x00F0                 // t1 = 0xFFFFFF10

    _end:
    jr      ra
    sw      t1, 0x0000(t0)                  // set override value
}

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, CharEnvColor.state_table    // t0 = env color state of 1p address
	bnezl   a0, pc() + 8                    // don't clear if p1 is human
	sw      r0, 0x0000(t0)                  // clear env color state 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't clear if p2 is human
	sw      r0, 0x0004(t0)                  // clear env color state 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't clear if p3 is human
	sw      r0, 0x0008(t0)                  // clear env color state 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't clear if p4 is human
	sw      r0, 0x000C(t0)                  // clear env color state 4p

	// I'm being lazy, but I don't care
	li      t0, CharEnvColor.override_table // t0 = override value of 1p address
	bnezl   a0, pc() + 8                    // don't clear if p1 is human
	sw      r0, 0x0000(t0)                  // clear override value 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't clear if p2 is human
	sw      r0, 0x0004(t0)                  // clear override value 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't clear if p3 is human
	sw      r0, 0x0008(t0)                  // clear override value 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't clear if p4 is human
	sw      r0, 0x000C(t0)                  // clear override value 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
