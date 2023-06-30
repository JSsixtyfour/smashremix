// @ Description
// These constants must be defined for a menu item.
define LABEL("Rand Char")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(1)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b100000)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(CharacterSelect.random_char_state_table)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_off
dw string_press_l

// @ Description
// Value labels
string_off:; String.insert("Off")
string_press_l:; String.insert("Press L")