// @ Description
// These constants must be defined for a menu item.
define LABEL("Taunt Btn.")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(8)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(Joypad.taunt_mask_per_port)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_L
dw string_CU
dw string_CD
dw string_CL
dw string_CR
dw string_DU
dw string_DD
dw string_DL
dw string_DR

// @ Description
// Value labels
string_L:; String.insert("L")
string_CU:; String.insert("C-Up")
string_CD:; String.insert("C-Down")
string_CL:; String.insert("C-Left")
string_CR:; String.insert("C-Right")
string_DU:; String.insert("D-Up")
string_DD:; String.insert("D-Down")
string_DL:; String.insert("D-Left")
string_DR:; String.insert("D-Right")

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, VALUE_ARRAY_POINTER         // t0 = 1p address
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

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
