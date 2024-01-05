// @ Description
// These constants must be defined for a menu item.
define LABEL("Kirby Hat")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(0x00000024)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(KirbyHats.spawn_with_hat)
constant ONCHANGE_HANDLER(onchange_handler)
constant DISABLES_HIGH_SCORES(OS.TRUE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_none
dw Training.string_mario
dw Training.string_fox
dw Training.string_dk
dw Training.string_samus
dw Training.string_luigi
dw Training.string_link
dw Training.string_yoshi
dw Training.string_cfalcon
dw Training.string_pikachu
dw Training.string_jigglypuff
dw Training.string_ness
dw Training.string_falco
dw Training.string_ganondorf
dw Training.string_younglink
dw Training.string_drmario
dw Training.string_wario
dw Training.string_dsamus
dw Training.string_lucas
dw Training.string_bowser
dw Training.string_piano
dw Training.string_wolf
dw Training.string_conker
dw Training.string_mewtwo
dw Training.string_marth
dw Training.string_sonic
dw Training.string_sheik
dw Training.string_marina
dw Training.string_dedede
dw Training.string_goemon
dw Training.string_slippy
dw Training.string_peppy
dw Training.string_banjo
dw Training.string_ebi
dw Training.string_dragonking
dw string_magic
dw string_random

// @ Description
// Value labels
string_none:; String.insert("None")
string_magic:; String.insert("???")
string_random:; String.insert("Random")

// @ Description
// Runs when the menu item value changes
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
// a3 - player object
scope onchange_handler: {
    // if character selected, reload model
    beqz    a3, _end                        // if player object not loaded, skip
    nop

    lw      t1, 0x0084(a3)                  // t1 = player struct
    lw      at, 0x0008(t1)                  // at = char_id
    lli     t0, Character.id.KIRBY
    beq     at, t0, _do_swap                // if Kirby is selected, do hat swap
    lli     t0, Character.id.JKIRBY
    bne     at, t0, _end                    // if not Kirby or J Kirby, skip
    nop

    _do_swap:
    li      t2, KirbyHats.spawn_with_table_
    addu    t2, t2, a2                      // t2 = address of char_id
    lbu     t2, 0x0000(t2)                  // t2 = char_id
    sw      t2, 0x0ADC(t1)                  // save char_id in player struct

    li      t3, Character.kirby_inhale_struct.table
    sll     t4, t2, 0x0002                  // t4 = char_id * 4
    subu    t4, t4, t2                      // t4 = char_id * 3
    sll     t4, t4, 0x0002                  // t4 = char_id * 12 = offset to inhale array
    addu    t3, t3, t4                      // t3 = inhale array
    lh      a2, 0x0002(t3)                  // a2 = hat_id

    addiu   sp, sp, -0x0020                 // allocate stack space
    sw      ra, 0x0008(sp)                  // save ra (0x0004(sp) is unsafe)
    sw      a3, 0x000C(sp)                  // save a3

    lw      t0, 0x0900(t1)                  // t0 = part 2 (Kirby's head/body)
    lw      t0, 0x0080(t0)                  // t0 = part 2 special images struct
    lhu     t0, 0x0080(t0)                  // t0 = current index for face texture array
    sw      t0, 0x0010(sp)                  // save current index for face texture array

    or      a0, a3, r0                      // a0 = player object
    jal     0x800E8EAC                      // set part
    lli     a1, 0x0006                      // a1 = part ID (Kirby hat)

    jal     0x800E8ECC                      // swap part
    lw      a0, 0x000C(sp)                  // a0 = player object

    lw      t0, 0x0010(sp)                  // t0 = index for face texture array
    lw      a0, 0x000C(sp)                  // a0 = player object
    lw      t1, 0x0084(a0)                  // t1 = player struct
    lw      t2, 0x0900(t1)                  // t2 = part 2 (Kirby's head/body)
    lw      t2, 0x0080(t2)                  // t2 = part 2 special images struct
    sh      t0, 0x0080(t2)                  // set index for face texture array

    lw      ra, 0x0008(sp)                  // restore ra
    addiu   sp, sp, 0x0020                  // deallocate stack space

    _end:
    jr      ra
    nop
}

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

	li      t0, KirbyHats.spawn_with_hat    // t0 = kirby hat setting address
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
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}