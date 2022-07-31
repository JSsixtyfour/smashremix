// @ Description
// These constants must be defined for a menu item.
define LABEL("Shield")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(17)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(Shield.state_table)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_red
dw string_orange
dw string_yellow
dw string_lime
dw string_green
dw string_turquoise
dw string_cyan
dw string_azure
dw string_blue
dw string_purple
dw string_magenta
dw string_pink
dw string_brown
dw string_black
dw string_white
dw string_vanilla
dw string_costume

// @ Description
// Value labels
string_default:; String.insert("Default")
string_red:; String.insert("Red")
string_orange:; String.insert("Orange")
string_yellow:; String.insert("Yellow")
string_lime:; String.insert("Lime")
string_green:; String.insert("Green")
string_turquoise:; String.insert("Turquoise")
string_cyan:; String.insert("Cyan")
string_azure:; String.insert("Azure")
string_blue:; String.insert("Blue")
string_purple:; String.insert("Purple")
string_magenta:; String.insert("Magenta")
string_pink:; String.insert("Pink")
string_brown:; String.insert("Brown")
string_black:; String.insert("Black")
string_white:; String.insert("White")
string_vanilla:; String.insert("Vanilla")
string_costume:; String.insert("Costume")

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, Shield.state_table          // t0 = shield state of 1p address
	bnezl   a0, pc() + 8                    // don't disable if p1 is human
	sw      r0, 0x0000(t0)                  // default shield 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't disable if p2 is human
	sw      r0, 0x0004(t0)                  // default shield 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't disable if p3 is human
	sw      r0, 0x0008(t0)                  // default shield 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't disable if p4 is human
	sw      r0, 0x000C(t0)                  // default shield 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
