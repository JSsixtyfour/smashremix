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
    // a1 - signed?
    // a2 - show + for signed value?
    // a3 - how many decimal places (e.g. if set to 1, 100 would become 10.0)
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

        // if signed, then check if negative
        beqz    a1, _zero_check     // if unsigned, skip
        nop
        slti    t3, t0, 0x0000      // t3 = 1 if negative
        bnezl   t3, _write_string   // if negative, negate a0
        subu    t0, r0, t0          // t0 = -a0

        _zero_check:
        bnez    t0, _write_string   // if zero, make a zero string
        or      t4, a3, r0          // t4 = number of decimals
        lli     at, '0'             // at = zero ascii value
        _zero_check_loop:
        sb      at, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        beqz    t4, _reverse_setup  // if enough digits for decimals, next
        addiu   t1, t1, 0x0001      // increment buffer pointer
        b       _zero_check_loop    // loop
        addiu   t4, t4, -0x0001     // t4--

        _write_string:
        beqz    t0, _check_zeros    // while (num != 0)
        nop
        divu    t0, t2              // t0 div t2
        mfhi    t3                  // t3 = t0 % t2
        addiu   t3, t3, '0'         // t3 = char (rem + '0')
        sb      t3, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        mflo    t0                  // t0 = t0 / t2
        b       _write_string       // loop
        addiu   t1, t1, 0x0001      // increment buffer pointer

        _check_zeros:
        li      t3, buffer          // t3 = buffer
        subu    t2, t3, t1          // t2 = length of string, including null pointer
        addiu   t2, t2, -0x0001     // t2 = length of string
        or      t4, t1, r0          // t4 = address of null pointer
        _zero_loop:
        sltu    t0, a3, t2          // t0 = 0 if not enough digits for decimal
        bnez    t0, _check_minus    // if enough digits, skip
        lli     at, '0'             // at = 0 zero ascii value
        sb      at, 0x0000(t4)      // store 0
        sb      r0, 0x0001(t4)      // store null terminator
        addiu   t4, t4, 0x0001      // t2++
        b       _zero_loop          // loop
        addiu   t2, t2, 0x0001      // t2++

        _check_minus:
        beqz    a1, _reverse_setup  // if unsigned, skip
        nop
        slti    t3, a0, 0x0000      // t3 = 1 if negative
        beqz    t3, _check_plus     // if non-negative, check if we should show + sign
        nop
        lli     at, '-'             // at = minus ascii value
        sb      at, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        b       _reverse_setup
        addiu   t1, t1, 0x0001      // increment buffer pointer

        _check_plus:
        beqz    a2, _reverse_setup  // if never show + sign, skip
        nop
        lli     at, '+'             // at = plus ascii value
        sb      at, 0x0000(t1)      // store char
        sb      r0, 0x0001(t1)      // store null terminator
        addiu   t1, t1, 0x0001      // increment buffer pointer

        _reverse_setup:
        addiu   t1, t1,-0x0001      // t1 = end of buffer (not including null terminator)
        li      t3, buffer          // t3 = start of buffer
        or      t2, t1, r0          // t2 = last char address

        _reverse_loop:
        sub     at, t1, t3          // original pointer - current pointer
        slti    at, at, 0x0001      // set if 0 or less (should be 0 or -1)
        bnez    at, _check_decimal  // if set, exit loop
        nop
        lb      t4, 0x0000(t3)      // ~
        lb      t5, 0x0000(t1)      // ~
        sb      t4, 0x0000(t1)      // ~
        sb      t5, 0x0000(t3)      // swap start and end chars
        addiu   t1, t1,-0x0001      // decrement end
        addiu   t3, t3, 0x0001      // increment start
        b       _reverse_loop       // loop
        nop

        _check_decimal:
        beqz    a3, _end            // if no decimals to show, end
        or      t5, a3, r0          // t5 = number of decimals to show
        sub     t1, t2, t5          // t1 = address of decimal place
        addiu   t1, t1, 0x0001      // ~
        lli     at, '.'             // at = period ascii value
        addu    t4, t2, t5          // t4 = new address for last char
        sb      r0, 0x0001(t4)      // store null terminator
        _decimal_loop:
        lb      t0, 0x0000(t2)      // t0 = char
        addu    t4, t2, t5          // t4 = new address for char
        sb      t0, 0x0000(t4)      // shift char right
        beql    t1, t2, _end        // if at the decimal point, store it and exit
        sb      at, 0x0000(t2)      // store decimal point
        b       _decimal_loop       // otherwise keep looping
        addiu   t2, t2, -0x0001     // t2--

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

        dw 0x0000                   // this is important for decimals
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
