// boot.asm

// this file runs extra functions after the initial DMA

scope boot_: {
    li      a0, Fireball.Capsule.graphic// a0 = capsule graphic address
    ori     a1, r0, 0x00D8              // a1 = capsule graphic initial pointer offset
    li      a2, Fireball.Capsule.graphic// a2 = capsule graphic base
    jal     assign_pointers_            // assign pointers for capsule graphic file
    nop
    li      a0, Fireball.Capsule.data   // a0 = capsule data address
    or      a1, r0, r0                  // a1 = capsule data initial pointer offset
    li      a2, Fireball.Capsule.graphic// a2 = capsule data base
    jal     assign_pointers_            // assign pointers for capsule data file
    nop
    j       0x8000063C                  // return to DMA hook
    nop
}

// @ Description
// This function assigns pointers to a binary file using the original ssb format.
// Format - XXXXYYYY
// XXXX * 4 = offset of next pointer from start of file
// YYYY * 4 = offset of data from start of file
// @ Arguments
// a0 - file address
// a1 - initial pointer offset
// a2 - base address

scope assign_pointers_: {

    addiu   sp, sp,-0x0018              // allocate stack space
    sw      t0, 0x0008(sp)              // ~
    sw      t1, 0x0008(sp)              // ~
    sw      t2, 0x000C(sp)              // ~
    sw      t3, 0x0010(sp)              // store t0-t3
    ori     t3, r0, 0xFFFF              // t3 = end value (0xFFFF)
    addu    a1, a0, a1                  // a1 = current pointer address
    
    _assign:
    lhu     t0, 0x0002(a1)              // t0 = data value (YYYY)
    sll     t0, t0, 0x2                 // t0 = data offset (YYYY * 4)
    lhu     t1, 0x0000(a1)              // t1 = next pointer value (XXXX)
    sll     t2, t1, 0x2                 // t2 = next pointer offset (XXXX * 4)
    addu    t0, a2, t0                  // t0 = pointer (base + data offset)
    sw      t0, 0x0000(a1)              // assign pointer
    bne     t1, t3, _assign             // loop if t1 != end (next pointer value != 0xFFFF)
    addu    a1, a0, t2                  // a1 = next pointer address (file address + next pointer offset)
    
    _end:
    lw      t0, 0x0008(sp)              // ~
    lw      t1, 0x0008(sp)              // ~
    lw      t2, 0x000C(sp)              // ~
    lw      t3, 0x0010(sp)              // load t0-t3
    addiu   sp, sp, 0x0018              // deallocate stack space
    jr      ra                          // return
    nop
}