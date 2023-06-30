// @ Description
// Optional toggle for a "Jab Lock" mechanic.
scope JabLock {
    // @ Description
    // When the character begins the DownBounceD or DownBounceU action, set the lock bool to FALSE
    scope down_initial_: {
        OS.patch_start(0xBEF44, 0x80144504)
        j       down_initial_
        sw      r0, 0x0B18(s0)              // original line 1
        _return:
        OS.patch_end()

        // check if toggle enabled
        OS.read_word(Toggles.entry_jab_lock + 0x4, at) // at = toggle
        beqz    at, _end                    // skip if toggle is disabled
        nop

        sw      r0, 0x0B28(s0)              // lock bool = FALSE

        _end:
        j       _return                     // return
        or      a0, s0, r0                  // original line 2
    }

    // @ Description
    // If the character gets hit by a low knockback hitbox while in DownBounceD or DownBounceU,
    // restart that action rather than using a damage action.
    scope handle_lock_: {
        OS.patch_start(0xBBDDC, 0x8014139C)
        j       handle_lock_
        lw      a1, 0x0058(sp)              // a1 = damage action (original line 1)
        _return:
        OS.patch_end()

        // check if toggle enabled
        OS.read_word(Toggles.entry_jab_lock + 0x4, at) // at = toggle
        beqz    at, _end                    // skip if toggle is disabled
        nop

        lw      a2, 0x0084(a0)              // a2 = player struct
        lw      a3, 0x0024(a2)              // a3 = current action
        lli     at, Action.DownBounceD      // at = DownBounceD
        beq     a3, at, _lock               // branch if current action = DownBounceD
        lli     at, Action.DownBounceU      // at = DownBounceU
        bnel    a3, at, _end                // skip if current action != DownBounceU
        nop

        _lock:
        // if the current action is DownBounceD or DownBounceU
        sltiu   at, a1, Action.DamageElec2  // at = 1 if current action is pre-knockdown damage, else at = 0
        beqz    at, _end                    // skip if damage action = knockdown damage
        nop
        // if the damage action is pre-knockdown, restart current action instead
        or      a1, a3, r0                  // a1 = current action
        lli     at, OS.TRUE                 // ~
        sw      at, 0x0B28(a2)              // lock bool = TRUE

        _end:
        j       _return                     // return
        addiu   a2, r0, 0x0000              // original line 2
    }

    // @ Description
    // If the character reaches the end of DownBounceD/DownBounceU and the lock bool is set,
    // force the character into DownStandD/DownStandU
    scope handle_reset_: {
        OS.patch_start(0xBF38C, 0x8014494C)
        j       handle_reset_
        lw      v0, 0x0084(a0)              // v0 = player struct (original line 1)
        _return:
        OS.patch_end()

        // check if toggle enabled
        OS.read_word(Toggles.entry_jab_lock + 0x4, at) // at = toggle
        beqz    at, _skip                   // skip if toggle is disabled
        nop

        lw      t6, 0x0B28(v0)              // t6 = lock bool
        beqz    t6, _skip                   // skip if lock bool = FALSE
        nop

        // if lock bool = TRUE
        jal     0x80144580                  // begin DownStandD/DownStandU
        nop
        j       0x8014498C                  // end original function
        lli     v0, OS.TRUE                 // return TRUE (action change occurred)

        _skip:
        j       _return                     // return
        lw      t6, 0x0B18(v0)              // original line 2
    }
}