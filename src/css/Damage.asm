// @ Description
// These constants must be defined for a menu item.
define LABEL("Initial Damage")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.NUMERIC)
constant MIN_VALUE(0)
constant MAX_VALUE(999)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b110110)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(state_table)
constant ONCHANGE_HANDLER(onchange_handler)
constant DISABLES_HIGH_SCORES(OS.TRUE)

state_table:
dw DEFAULT_VALUE, DEFAULT_VALUE, DEFAULT_VALUE, DEFAULT_VALUE

// @ Description
// Runs before 1p modes to ensure settings aren't applied.
// @ Arguments
// a0 - port of human player
scope clear_settings_for_1p_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

    li      t0, state_table                 // t0 = damage of 1p address
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

// @ Description
// Hook to set damage on character init
scope char_init_: {
    OS.patch_start(0x53214, 0x800D7A14)
    jal     char_init_
    or      s0, a0, r0                  // original line 1
    OS.patch_end()

    // t7 holds player damage
    // 0x000D(v1) player port
    // v1 holds player struct
    // 0x800D86B4 is ra for char load (as opposed to respawn)

    bnez    t7, _end                    // if damage is already non-zero, skip! (Sudden Death fix)
    li      t4, Global.current_screen   // ~
    lbu     t4, 0x0000(t4)              // t0 = screen_id
    ori     t3, r0, Global.screen.VS_BATTLE
    beq     t4, t3, _check_respawn      // if screen_id == vs battle, apply custom damage
    ori     t3, r0, Global.screen.TITLE_AND_1P
    beq     t4, t3, _check_respawn      // if screen_id == 1p, apply custom damage
    ori     t3, r0, Global.screen.REMIX_MODES
    beq     t4, t3, _check_respawn      // if screen_id == rttf/multiman/hrc, apply custom damage
    ori     t3, r0, Global.screen.BONUS
    bne     t4, t3, _end                // if screen_id != bonus, skip
    nop

    _check_respawn:
    OS.read_word(SinglePlayerModes.singleplayer_mode_flag, t4)
    lli     t3, 0x0005                  // t3 = All Star
    beq     t4, t3, _end                // If All Star, skip
    lw      t4, 0x0024(sp)              // t4 = ra for char init routine
    li      t3, 0x800D86B4              // t3 = ra inside char load routine
    bne     t4, t3, _end                // skip if respawning
    lbu     t4, 0x000D(v1)              // t4 = port

    li      t3, state_table
    sll     t4, t4, 0x0002              // t4 = offset to player's initial damage
    addu    t3, t3, t4                  // t3 = address of player's initial damage
    lw      t7, 0x0000(t3)              // t7 = player's initial damage

    _end:
    jr      ra
    lw      a2, 0x09C8(v1)              // original line 2
}

// @ Description
// Ensures damage can't be higher than H.P. value in stamina mode
scope restrict_damage_for_stamina_: {
    // Make sure we're on the VS CSS
    OS.read_byte(Global.current_screen, t1) // t1 = screen_id
    lli     t0, Global.screen.VS_CSS
    bne     t1, t0, _end                // If not VS CSS, skip
    lui     t1, 0x8014

    // Then make sure we're in stamina mode
    lw      t1, 0xBDAC(t1)              // t1 = 1 if time, 3 if stock, 5 if stamina
    lli     t0, Stamina.STAMINA_MODE    // t0 = stamina mode
    bne     t0, t1, _end                // if not stamina, skip
    nop

    li      at, Stamina.TOTAL_HP        // at = max damage
    lw      at, 0x0000(at)              // ~
    li      t0, state_table             // t0 = state_table
    lli     t2, 0x0004                  // t2 = num ports (for loop)

    _loop:
    lw      t1, 0x0000(t0)              // t1 = px damage
    sltu    t1, at, t1                  // t1 = 1 if damage > max
    bnezl   t1, pc() + 8                // if damage > max, then set to max
    sw      at, 0x0000(t0)              // set damage to max
    addiu   t2, t2, -0x0001             // t2 = decrement counter
    bnezl   t2, _loop                   // loop until we've reached last port
    addiu   t0, t0, 0x0004              // t0 = next port damage address

    _end:
    jr      ra
    nop
}

// @ Description
// Runs when the menu item value changes
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
// a3 - player object
scope onchange_handler: {
    // Need to make sure the value doesn't violate H.P. constraints in Stamina mode.

    // Make sure we're on the VS CSS
    OS.read_byte(Global.current_screen, t1) // t1 = screen_id
    lli     t0, Global.screen.VS_CSS
    bne     t1, t0, _end                // If not VS CSS, skip
    lui     t1, 0x8014

    // Then make sure we're in stamina mode
    lw      t1, 0xBDAC(t1)              // t1 = 1 if time, 3 if stock, 5 if stamina
    lli     t0, Stamina.STAMINA_MODE    // t0 = stamina mode
    bne     t0, t1, _end                // if not stamina, skip
    nop

    li      at, Stamina.TOTAL_HP        // at = max damage
    lw      at, 0x0000(at)              // ~
    sltu    t0, at, a2                  // t0 = 1 if damage > max
    beqz    t0, _end                    // if damage <= max, then skip
    sll     t1, a1, 0x0002              // t1 = offset in state_table

    li      t0, state_table             // t0 = state_table
    addu    t0, t0, t1                  // t0 = address of port's damage value

    lw      t1, 0x0024(sp)              // t1 = arrow object
    lw      t1, 0x0048(t1)              // t1 = direction (-1 for left, +1 for right)
    bgtzl   t1, _end                    // if right arrow was pressed, cycle to 0
    sw      r0, 0x0000(t0)              // set initial damage to 0

    // otherwise, cycle to max value
    sw      at, 0x0000(t0)              // set initial damage to max

    _end:
    jr      ra
    nop
}