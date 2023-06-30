// LedgeTrump.asm

scope LedgeTrump {

    // check right ledge = 800DB590
    // check left ledge = 800DB6F0
    
    constant PUSH_Y_VELOCITY(0x4248) // 50
    constant PUSH_X_VELOCITY(0x4248) // 50
    constant LAG_FRAMES(30)
    
    // temp value
    player_on_cliff:
    dw      0

    // @ Description
    // Adds a hook to the logic that does nothing if a player is trying to grab a ledge
    // s0 = aerial player (struct)
    // v0 = player on cliff (struct)
    scope ledge_check: {
        OS.patch_start(0x59E6C, 0x800DE66C)
        j       ledge_check
        nop
        OS.patch_end()

        Toggles.read(entry_ledge_trump, at)   // at = toggle
        beqz    at, _normal
        nop

        // if here, toggle is enabled
        addiu   at, r0, Action.CliffCatch
        lw      t0, 0x24(v0)            // current action of player on cliff
        beq     at, t0, _ledge_trump_continue
        addiu   at, r0, Action.CliffWait
        beq     at, t0, _ledge_trump_continue
        nop
        b       _ledge_trump_end
        nop
        
        _ledge_trump_continue:
        li      at, player_on_cliff
        sw      v1, 0x0000(at)              // store v1

        OS.save_registers()
        addiu   s0, a0, 0                   // s0 = player struct
        lw      a0, 0x0004(v0)              // a0 = player object

        Action.change(Action.DamageAir3, -1)    // set players action to tumble
        li      at, player_on_cliff
        lw      a0, 0x0000(at)              // a0 = player obj
        lw      a0, 0x0084(a0)              // a0 = player struct

        lui     at, PUSH_Y_VELOCITY
        sw      at, 0x004C(a0)              // save y velocity to player struct
        lui     at, PUSH_X_VELOCITY
        mtc1    at, f4
        lwc1    f6, 0x44(a0)                // player direction
        cvt.s.w f6, f6
        nop
        mul.s   f4, f4, f6                  // save speed * direction
        lui     at, 0xBF80                  // at = -1
        mtc1    at, f6
        mul.s   f4, f4, f6
        nop
        swc1    f4, 0x48(a0)                // save x velocity
        addiu   at, r0, LAG_FRAMES
        sw      at, 0xB18(a0)               // save lag frames to player struct
        OS.restore_registers()

        li      at, player_on_cliff
        lw      v1, 0x0000(at)          // restore v1
        _ledge_trump_end:
        j       0x800DE678              // return to end of routine
        lw      v1, 0x0004(v1)          // ~

        _normal:
        j       0x800DE69C              // og line 1 modified
        lw      v0, 0x0024(sp)          // og line 2

    }



}