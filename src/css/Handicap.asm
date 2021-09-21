// @ Description
// These constants must be defined for a menu item.
define LABEL("Handicap")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(9)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2]
constant APPLIES_TO(0b10100)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b01)
constant VALUE_ARRAY_POINTER(Handicap.override_table)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_1
dw string_2
dw string_3
dw string_4
dw string_5
dw string_6
dw string_7
dw string_8
dw string_9

// @ Description
// Value labels
string_default:; String.insert("Default")
string_1:; String.insert("1")
string_2:; String.insert("2")
string_3:; String.insert("3")
string_4:; String.insert("4")
string_5:; String.insert("5")
string_6:; String.insert("6")
string_7:; String.insert("7")
string_8:; String.insert("8")
string_9:; String.insert("9")