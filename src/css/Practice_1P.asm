// @ Description
// These constants must be defined for a menu item.
define LABEL("Practice")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(Practice_1P.STAGES)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b010000)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(Practice_1P.stage_table)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.TRUE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_none
define n(1)
while {n} < MAX_VALUE {
    dw string_stage_{n}
    evaluate n({n}+1)
}
dw string_stage_final

// @ Description
// Value labels
string_none:; String.insert("OFF")
define n(1)
while {n} < MAX_VALUE {
    string_stage_{n}:
    if {n} == 1 {
        String.insert("Stage {n}")
    } else {
        String.insert("Stage {n}")
    }
    evaluate n({n}+1)
}
string_stage_final:; String.insert("Final Stage")
