// String.asm
if !{defined __STRING__} {
define __STRING__()
print "included String.asm\n"

// @ Description
// Implementation of a few string.h functions.

include "OS.asm"

scope String {

    // @ Description
    // Inserts a null terminated, 32 bit aligned string
    macro insert(str) {
        db {str}, 0x00
        OS.align(4)
    }

    // @ Description
    // This function populates a string buffer from an integer in base 10.
    // @ Arguments
    // a0 - int to convert
    // @ Returns
    // v0 - address of character buffer
    scope itoa_: {
        addiu   sp, sp,-0x0020      // allocate stack space
        sw      t0, 0x0004(sp)      // ~
        sw      t1, 0x0008(sp)      // ~
        sw      t2, 0x000C(sp)      // ~
        sw      t3, 0x0010(sp)      // ~
        sw      t4, 0x0014(sp)      // ~
        sw      t5, 0x0018(sp)      // ~
        sw      at, 0x001C(sp)      // save registers

        _start:
        or      t0, a0, r0          // t0 = (int) num
        li      t1, buffer          // t1 = buffer
        lli     t2, 000010          // t2 = base 10

        _zero_check:
        bnez    t0, _write_string   // if zero, make a zero string
        nop
        lli     at, 0x0030          // t0 = zero ascii value
        sb      at, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        b       _reverse_setup      // next
        addiu   t1, t1, 0x0001      // increment buffer pointer

        _write_string:
        beqz    t0, _reverse_setup  // while (num != 0)
        nop
        divu    t0, t2              // t0 div t2
        mfhi    t3                  // t3 = t0 % t2
        addiu   t3, t3, '0'         // t3 = char (rem + '0')
        sb      t3, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        mflo    t0                  // t0 = t0 / t2
        b       _write_string       // loop
        addiu   t1, t1, 0x0001      // increment buffer pointer

        _reverse_setup:
        addiu   t1, t1,-0x0001      // t1 = end of buffer (not including null terminator)
        li      t3, buffer          // t3 = start of buffer

        _reverse_loop:
        sub     at, t1, t3          // original pointer - currrent pointer  
        slti    at, at, 0x0001      // set if 0 or less (should be 0 or -1)
        bnez    at, _end            // if set, end
        nop
        lb      t4, 0x0000(t3)      // ~
        lb      t5, 0x0000(t1)      // ~
        sb      t4, 0x0000(t1)      // ~
        sb      t5, 0x0000(t3)      // swap start and end chars
        addiu   t1, t1,-0x0001      // decrement end
        addiu   t3, t3, 0x0001      // increment start
        b       _reverse_loop       // loop
        nop

        _end:
        lw      t0, 0x0004(sp)      // ~
        lw      t1, 0x0008(sp)      // ~
        lw      t2, 0x000C(sp)      // ~
        lw      t3, 0x0010(sp)      // ~
        lw      t4, 0x0014(sp)      // ~
        lw      t5, 0x0018(sp)      // ~
        lw      at, 0x001C(sp)      // restore registers
        addiu   sp, sp, 0x0020      // deallocate stack space
        li      v0, buffer          // return buffer address
        jr      ra                  // return
        nop

        buffer:
        fill 0x0010
    }

    // @ Description
    // Returns the length of a null terminated string of characters
    // @ Arguments
    // a0 - address of string
    // @ Returns
    // v0 - length
    scope length_: {
        addiu   sp, sp,-0x0010      // allocate stack space
        sw      t0, 0x0004(sp)      // ~
        sw      at, 0x0008(sp)      // save registers

        lli     v0, 0x0000          // v0 = length = 0
        move    t0, a0              // t0 = address of string

        _loop:
        lbu     at, 0x0000(t0)      // at = char
        beqz    at, _end            // if (char == '\0'), return
        nop
        addiu   v0, v0, 0x0001      // length++
        addiu   t0, t0, 0x0001      // increment string address
        b       _loop
        nop

        _end:
        lw      t0, 0x0004(sp)      // ~
        lw      at, 0x0008(sp)      // restore registers
        addiu   sp, sp, 0x0010      // deallocate stack space
        jr      ra                  // return
        nop
    }
}

} // __STRING__