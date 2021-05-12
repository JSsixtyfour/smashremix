// @ Description
// These constants must be defined for a menu item.
define LABEL("Count")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.NUMERIC)
constant MIN_VALUE(0)
constant MAX_VALUE(98)
constant DEFAULT_VALUE(3)
constant APPLIES_TO(0b10000)

// @ Description
// Runs when the menu item value changes
scope onchange_handler: {
    jr      ra
    nop
}
