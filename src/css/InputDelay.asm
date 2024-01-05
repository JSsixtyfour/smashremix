// @ Description
// These constants must be defined for a menu item.
define LABEL("Delay")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(InputDelay.MAX_FRAMES)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(InputDelay.delay_table)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.FALSE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_none
define n(1)
while {n} <= MAX_VALUE {
    dw string_{n}_frame
    evaluate n({n}+1)
}

// @ Description
// Value labels
string_none:; String.insert("None")
define n(1)
while {n} <= MAX_VALUE {
    string_{n}_frame:
    if {n} == 1 {
        String.insert("{n} frame")
    } else {
        String.insert("{n} frames")
    }
    evaluate n({n}+1)
}

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, InputDelay.delay_table       // t0 = input delay of 1p address
	bnezl   a0, pc() + 8                    // don't clear if p1 is human
	sw      r0, 0x0000(t0)                  // clear input delay 1p
	lli     t1, 0x0001                      // t1 = 1 (p2)
	bnel    a0, t1, pc() + 8                // don't clear if p2 is human
	sw      r0, 0x0004(t0)                  // clear input delay 2p
	lli     t1, 0x0002                      // t1 = 2 (p3)
	bnel    a0, t1, pc() + 8                // don't clear if p3 is human
	sw      r0, 0x0008(t0)                  // clear input delay 3p
	lli     t1, 0x0003                      // t1 = 3 (p4)
	bnel    a0, t1, pc() + 8                // don't clear if p4 is human
	sw      r0, 0x000C(t0)                  // clear input delay 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
