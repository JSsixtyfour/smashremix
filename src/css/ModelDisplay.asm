// @ Description
// These constants must be defined for a menu item.
define LABEL("Model")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(2)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(Costumes.model_display_for_port)
constant ONCHANGE_HANDLER(onchange_handler)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_high_poly
dw string_low_poly

// @ Description
// Value labels
string_default:; String.insert("Default")
string_high_poly:; String.insert("Hi Poly")
string_low_poly:; String.insert("Lo Poly")

// @ Description
// Runs when the menu item value changes
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
// a3 - player object
scope onchange_handler: {
    // if character selected, reload model
    beqz    a3, _end                        // if player object not loaded, skip
    nop

    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      ra, 0x0008(sp)                  // save ra (0x0004(sp) is unsafe)

    or      a1, a2, r0                      // a1 = hi/lo poly (1 = high, 2 = low)
    beqzl   a1, pc() + 8                    // if model display set to default, use high poly
    lli     a1, 0x0001                      // a1 = high poly
    jal     0x800E9198                      // reload model
    or      a0, a3, r0                      // a0 = player object

    lw      ra, 0x0008(sp)                  // restore ra
    addiu   sp, sp, 0x0010                  // deallocate stack space

    _end:
    jr      ra
    nop
}

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, VALUE_ARRAY_POINTER         // t0 = model display of 1p address
	bnezl   a0, pc() + 8                    // don't change if p1 is human
	sw      r0, 0x0000(t0)                  // use default model display for 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't change if p2 is human
	sw      r0, 0x0004(t0)                  // use default model display for 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't change if p3 is human
	sw      r0, 0x0008(t0)                  // use default model display for 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't change if p4 is human
	sw      r0, 0x000C(t0)                  // use default model display for 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
