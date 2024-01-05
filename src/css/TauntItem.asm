// @ Description
// These constants must be defined for a menu item.
define LABEL("Taunt Itm.")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(Item.taunt_item_random_entry)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(Item.taunt_spawn_item)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.TRUE)

// @ Description
// Holds pointers to value labels
string_table:
dw StartWith.string_none
//dw StartWith.string_tomato
//dw StartWith.string_heart
//dw StartWith.string_star
dw StartWith.string_beam_sword
dw StartWith.string_home_run_bat
dw StartWith.string_fan
dw StartWith.string_star_rod
dw StartWith.string_ray_gun
dw StartWith.string_fire_flower
dw StartWith.string_hammer
dw StartWith.string_motion_sensor_bomb
dw StartWith.string_bobomb
dw StartWith.string_bumper
dw StartWith.string_green_shell
dw StartWith.string_red_shell
dw StartWith.string_pokeball
//dw StartWith.string_cloaking_device
//dw StartWith.string_super_mushroom
//dw StartWith.string_poison_mushroom
dw StartWith.string_blue_shell
dw StartWith.string_deku_nut
dw StartWith.string_pit_fall
dw StartWith.string_golden_gun
dw StartWith.string_random

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, VALUE_ARRAY_POINTER         // t0 = address
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
    lw      t1, 0x0008(sp)                  // ~
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}
