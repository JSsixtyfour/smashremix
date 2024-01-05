// @ Description
// These constants must be defined for a menu item.
define LABEL("Poison Dmg")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(4)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b110111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b11)
constant VALUE_ARRAY_POINTER(state_table)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.TRUE)

state_table:
dw DEFAULT_VALUE, DEFAULT_VALUE, DEFAULT_VALUE, DEFAULT_VALUE

// @ Description
// Holds pointers to value labels
string_table:
dw string_default
dw string_1
dw string_2
dw string_3
dw string_4

// @ Description
// Value labels
string_default:; String.insert("None")
string_1:; String.insert("Low")
string_2:; String.insert("Medium")
string_3:; String.insert("High")
string_4:; String.insert("Heal")

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
    sw      r0, 0x0000(t0)                  // clear damage 1p
    lli     t1, 0x0001                      // t1 = 1 (p2)
    bnel    a0, t1, pc() + 8                // don't clear if p2 is human
    sw      r0, 0x0004(t0)                  // clear damage 2p
    lli     t1, 0x0002                      // t1 = 2 (p3)
    bnel    a0, t1, pc() + 8                // don't clear if p3 is human
    sw      r0, 0x0008(t0)                  // clear damage 3p
    lli     t1, 0x0003                      // t1 = 3 (p4)
    bnel    a0, t1, pc() + 8                // don't clear if p4 is human
    sw      r0, 0x000C(t0)                  // clear damage 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}

scope apply_damage: {
        // a2 is player struct
        // t5, t6 should be safe

        _check_timer:
        li      t5, Global.match_info    // t5 = pointer to match info
        lw      t5, 0x0000(t5)           // load address of match info
        lw      t5, 0x0018(t5)           // t5 = elapsed time
        beqz    t5, _return
        andi    t5, t5, 0x007F           // damage every two seconds
        bnez    t5, _return
        nop

        lw      t5, 0x05B0(a2)           // t5 = super star counter
        bnez    t5, _return              // skip if using a super star
        lw      t5, 0x0024(a2)           // t5 = current action
        slti    t5, t5, Action.Idle      // t5 = 1 if respawning
        bnez    t5, _return
        nop

        li      t5, CharacterSelectDebugMenu.PoisonDmg.state_table
        lb      at, 0x000D(a2)          // at = player port
        sll     t6, at, 0x0002          // t6 = offset
        addu    t5, t5, t6              // t5 = address of state_table
        lw      t6, 0x0000(t5)          // t6 = players value in table

        beqz    t6, _return             // skip if disabled
        nop

        // check if type is 'Heal'
        lli     t5, 4                   // t5 = 4 (Heal)
        beql    t6, t5, _anti_venom
        addiu   v1, r0, 2               // v1 = amount to heal (normally retrieved from '0x0818')
        // check if player is Cloaked, in which case we skip applying damage
        li      t5, Item.CloakingDevice.cloaked_players
        addu    t5, t5, at              // t5 = players entry in table
        lbu     t5, 0x0000(t5)
        bnez    t5, _return             // skip if player is cloaked
        nop
        // check which type and use its respective dmg % value
        lli     t5, 1                   // t5 = 1 (Low)
        beql    t6, t5, _apply_damage
        addiu   t6, r0, 1               // % damage
        lli     t5, 2                   // t5 = 2 (Medium)
        beql    t6, t5, _apply_damage
        addiu   t6, r0, 2               // % damage
        lli     t5, 3                   // t5 = 3 (High)
        beql    t6, t5, _apply_damage
        addiu   t6, r0, 4               // % damage
        // safety branch
        b       _return
        nop

        _apply_damage:
        lw      t5, 0x002C(a2)          // t5 = current hp
        addu    t5, t5, t6              // t5 = hp + added damage
        // ensure that new hp caps at max percent
        sltiu   at, t5, 1000            // at = 0 if hp > 999
        beqzl   at, pc() + 8            // if hp would be greater than 999, keep it at 999
        lli     t5, 999                 // ~

        // stamina mode check
        li      t6, Stamina.VS_MODE
        lbu     t6, 0x0000(t6)          // load mode
        addiu   at, r0, Stamina.STAMINA_MODE    // stamina mode
        bne     t6, at, _stamina_checked
        nop
        li      at, Stamina.TOTAL_HP    // load total hitpoints address
        lw      at, 0x0000(at)          // load total hitpoints amount
        beq     at, t5, _stamina
        slt     t6, t5, at              // if total hitpoints are less than total percent set t6
        bnez    t6, _stamina_checked    // proceed normally if won't go below stamina point
        nop

        _stamina:
        addu    t5, r0, at              // save HP value

        _stamina_checked:
        sw      t5, 0x002C(a2)          // save HP value
        j       0x800E1850              // apply hp / damage?
        nop

        _anti_venom:
        j       0x800E1828              // continue to healing portion of routine
        nop

        _return:
        j       Poison.poison_hook._poison_check    // return to Poison.asm
        nop

}
