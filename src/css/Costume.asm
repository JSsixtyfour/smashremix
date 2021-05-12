// @ Description
// These constants must be defined for a menu item.
define LABEL("Costume")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.NUMERIC)
constant MIN_VALUE(0)
constant MAX_VALUE(5)
constant DEFAULT_VALUE(0)
constant APPLIES_TO(0b10100)

// @ Description
// Runs when the menu item value changes
scope onchange_handler: {
    jr      ra
    nop
}
