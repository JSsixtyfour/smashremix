// @ Description
// These constants must be defined for a menu item.
define LABEL("Handicap")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(0x28)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b101000)
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
dw string_A
dw string_B
dw string_C
dw string_D
dw string_E
dw string_F
dw string_10
dw string_11
dw string_12
dw string_13
dw string_14
dw string_15
dw string_16
dw string_17
dw string_18
dw string_19
dw string_1A
dw string_1B
dw string_1C
dw string_1D
dw string_1E
dw string_1F
dw string_20
dw string_21
dw string_22
dw string_23
dw string_24
dw string_25
dw string_26
dw string_27
dw string_28

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
string_A:; String.insert("Yoshi V. Easy")
string_B:; String.insert("Yoshi Easy")
string_C:; String.insert("Yoshi Normal")
string_D:; String.insert("Yoshi Hard")
string_E:; String.insert("Yoshi V. Hard")
string_F:; String.insert("Kirby V. Easy")
string_10:; String.insert("Kirby Easy")
string_11:; String.insert("Kirby Normal")
string_12:; String.insert("Kirby Hard")
string_13:; String.insert("Kirby V. Hard")
string_14:; String.insert("Polygon V. Easy")
string_15:; String.insert("Polygon Easy")
string_16:; String.insert("Polygon Normal")
string_17:; String.insert("Polygon Hard")
string_18:; String.insert("Polygon V. Hard")
string_19:; String.insert("G. DK V. Easy")
string_1A:; String.insert("G. DK Easy")
string_1B:; String.insert("G. DK Normal")
string_1C:; String.insert("G. DK Hard")
string_1D:; String.insert("G. DK V. Hard")
string_1E:; String.insert("M. Mario V. Easy")
string_1F:; String.insert("M. Mario Easy")
string_20:; String.insert("M. Mario Normal")
string_21:; String.insert("M. Mario Hard")
string_22:; String.insert("M. Mario V. Hard")
string_23:; String.insert("MH V. Easy")
string_24:; String.insert("MH Easy")
string_25:; String.insert("MH Normal")
string_26:; String.insert("MH Hard")
string_27:; String.insert("MH V. Hard")
string_28:; String.insert("Samus")
