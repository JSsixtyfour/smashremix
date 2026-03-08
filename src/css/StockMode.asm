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
constant ONCHANGE_HANDLER(onchange_handler)
constant DISABLES_HIGH_SCORES(OS.FALSE)

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
// @ Arguments
// a0 - menu item
// a1 - port index
// a2 - new value
// a3 - player object
scope onchange_handler: {
    OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
    beqz    t0, _check_reset            // if normal vs mode, check if resetting
    lli     t1, VsRemixMenu.mode.TWELVE_CB
    beq     t0, t1, _check_reset        // if 12cb mode, check if resetting
    lli     t1, VsRemixMenu.mode.TUG_OF_WAR
    beq     t0, t1, _check_reset        // if Tug of War mode, check if resetting
    lli     t1, VsRemixMenu.mode.TAG_TEAM
    beq     t0, t1, _tag_team           // if Tag Team, handle
    nop

    // if here, prevent the value from being changed from Default
    lw      t0, 0x001C(a0)              // t0 = menu item value array
    sll     t1, a1, 0x0002              // t1 = offset to value for port
    addu    t0, t0, t1                  // t0 = address of value for port
    sw      r0, 0x0000(t0)              // set value to 0 (Default)
    b       _check_reset
    sw      r0, 0x0020(sp)              // set value in caller stack to 0 (Default) ** This is dangerous but I don't anyone will mess it up **

    _tag_team:
    // if resetting, then set the stock count to -1
    li      t0, CharacterSelectDebugMenu.handle_reset_button_press_._reset_return
    bne     t0, ra, _icon_refresh       // if not resetting, skip
    nop

    li      t0, StockMode.stock_count_table
    addu    t0, t0, a1                  // t0 = address of stock count for port
    addiu   t1, r0, -0x0001             // t1 = -1
    sb      t1, 0x0000(t0)              // set stock count to -1
    li      t0, StockMode.previous_stock_count_table
    addu    t0, t0, a1                  // t0 = address of previous stock count for port
    sb      t1, 0x0000(t0)              // set previous stock count to -1

    _icon_refresh:
    OS.read_word(CharacterSelect.render_control_object, t0) // t0 = render control object
    lw      t0, 0x0044(t0)              // t0 = remaining stocks control object
    addiu   t0, t0, 0x0030              // t0 = address of first stocks remaining object
    sll     t1, a1, 0x0004              // t1 = offset to stocks remaining object for port
    addu    a0, t0, t1                  // t0 = stocks remaining object for port address
    li      t2, StockMode.stock_count_table
    addu    a2, t2, a1                  // a2 = stocks remaining address
    j       CharacterSelect.update_remaining_stocks_
    lli     a3, 0x0000                  // a3 = 0 = delta (just triggering a refresh)

    _check_reset:
    // if resetting, then set the stock count to -1
    li      t0, CharacterSelectDebugMenu.handle_reset_button_press_._reset_return
    bne     t0, ra, _end                // if not resetting, skip
    nop

    li      t0, StockMode.stock_count_table
    addu    t0, t0, a1                  // t0 = address of stock count for port
    addiu   t1, r0, -0x0001             // t1 = -1
    sb      t1, 0x0000(t0)              // set stock count to -1
    li      t0, StockMode.previous_stock_count_table
    addu    t0, t0, a1                  // t0 = address of previous stock count for port
    sb      t1, 0x0000(t0)              // set previous stock count to -1

    // NOTE: could handle 12cb differently here, but I think it's probably fine!
    // It may be a bit weird that changing the count while in manual mode then changing
    // it back to default will result in the manual stock count being used, but
    // I think that's fine. 12cb is a bit different anyway.

    _end:
    jr      ra
    nop
}
