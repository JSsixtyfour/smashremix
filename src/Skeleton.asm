// Skeleton.asm
if !{defined __SKELETON__} {
define __SKELETON__()
print "included Skeleton.asm\n"

// @ Description
// Skeleton display is implemented in this file

include "Toggles.asm"
include "OS.asm"

scope Skeleton {
    // @ Description
    // Holds value of Skeleton mode switch per port
    enable_for_port:
    dw 0, 0, 0, 0                           // turn off by default for p1 - p4

    macro apply_skeleton_mode(register, player_struct) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store registers

        lbu     t1, 0x000D({player_struct}) // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset in enable_for_port
        li      t0, enable_for_port         // t0 = enable_for_port
        addu    t0, t0, t1                  // t0 = address of enable value
        lw      t0, 0x0000(t0)              // t0 = 1 if skeleton mode enabled, 0 if disabled
        bnezl   t0, _end                    // if enabled, update register value
        lui     {register}, 0x0800          // {register} = 0x0800 (show skeleton)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_1_: {
        OS.patch_start(0x6DCB0, 0x800F24B0)
        jal     skeleton_mode_1_
        nop
        OS.patch_end()

        lw      v1, 0x0A88(a1)              // original line 1
        lw      a3, 0x09C8(a1)              // original line 2

        apply_skeleton_mode(v1, a1)
    }

    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_2_: {
        OS.patch_start(0x6DA28, 0x800F2228)
        jal     skeleton_mode_2_
        nop
        OS.patch_end()
        
        lw      t7, 0x0A88(t4)              // original line 1
        sll     t3, v1, 0x3                 // original line 2
        
        apply_skeleton_mode(t7, t4)
    }
}
}
