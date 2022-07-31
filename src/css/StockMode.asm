// @ Description
// These constants must be defined for a menu item.
define LABEL("Stock")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(2)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b100000)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(StockMode.stockmode_table)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_last
dw string_manual

// @ Description
// Value labels
string_default:; String.insert("Default")
string_last:; String.insert("Last")
string_manual:; String.insert("Manual")

// @ Description
// Runs when the menu item value changes
scope onchange_handler: {
    jr      ra
    nop
}
