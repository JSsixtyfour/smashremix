// SpotDodge.asm

scope SpotDodge {
    
    // @ Description
    // Hook into shield routine that checks for shield drops
    scope check_input: {
        OS.patch_start(0xBC9DC, 0x80141F9C)
        j       check_input
        nop
        _return:
        OS.patch_end()

        // if here, then player has input down
        Toggles.read(entry_spot_dodge, at)      // at = toggle

        bnez    at, _plat_drop_check_modified
        nop

        _normal:
        jal     0x80141E60                      // check if stick slammed down
        sw      a0, 0x001C(sp)                  // og line 2

        beqz    v0, _end                        // original logic
        nop

        _plat_drop:
        j       0x80141FAC + 4
        lhu     t7, 0x01BC(a0)

        _end:
        j       0x80141FD0                      // go to end of routine
        lw      a0, 0x001C(sp)                  // restore a0


        _plat_drop_check_modified:
        or      v0, r0, r0                      // v0 = 0
        lb      t6, 0x01C3(a0)                  // t6 = stick y
        slti    at, t6, -32                     // at = 0 if stick x is above -32
        lbu     t7, 0x0269(a0)                  // t7 = num frames stick_y below 0
        beqz    at, _end                        // branch if stick is above -32
        slti    at, t7, 0x0004                  // check if stick slammed down
        beqz    at, _end                        // branch if stick is above -32
        
        // if here, then stick y is below -32
        lw      t8, 0x00F4(a0)                  // check if on a soft platform
        andi    t9, t8, 0x4000                  // ~

        beqz    t9, _spot_dodge_check           // branch if not on a soft platform
        slti    at, t6, -32

        // if here, soft platform
        slti    at, t6, -52                     // at = 0 if stick is above -52
        bnez    at, _spot_dodge                 // do spot dodge if stick is below -52
        nop
        // if here, perform platform drop
        j       0x80141FAC + 4
        lhu     t7, 0x01BC(a0)

        _spot_dodge_check:
        beqz    at, _end
        nop

        _spot_dodge:
        lhu     t7, 0x01BC(a0)              // idk lol
        lhu     t8, 0x01B8(a0)
        and     t9, t7, t8
        beqzl   t9, _end
        or      v0, r0, v0                  // return 0
        
        lw      a0, 0x0004(a0)
        
        // initiate spot dodge
        Action.change(Action.DamageHigh2, -1)
        
        lw      a0, 0x001C(sp)          // restore a0
        li      at, moveset
        sw      at, 0x086C(a0)          // update moveset pointer
        sw      at, 0x08AC(a0)          // update moveset pointer
        sw      r0, 0x09DC(a0)          // remove routine
        li      at, 0x800DDF44          // same collision routine as dash attack
        sw      at, 0x09E4(a0)          // update collision routine

        j       0x80141FD4
        addiu   v0, r0, 1               // return 1
    }

        moveset:
        Moveset.WAIT(2)
        dw 0x74000003   // intangible
        dw 0x04000010   // wait 16 frames
        dw 0x74000001
        dw 0x00000000
    
}