// Skeleton.asm
if !{defined __SKELETON__} {
define __SKELETON__()
print "included Skeleton.asm\n"

// @ Description
// Skeleton display is implemented in this file

include "Toggles.asm"
include "OS.asm"

scope Skeleton {

    macro apply_skeleton_mode(register, value) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store registers

        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 2 if skeleton_mode
        lli     t1, 0x0002                  // t1 = 2
        bne     t0, t1, _end                // if not skeleton mode, skip
        nop
        
        lui     {register}, {value}         // apply skeleton mode
        
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

        apply_skeleton_mode(v1, 0x0A88)
    }
    
    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_2_: {
        OS.patch_start(0x5C8D8, 0x800E10D8)
        jal     skeleton_mode_2_
        nop
        OS.patch_end()

        lw      v0, 0x0060(s1)              // original line 1
        srl     t9, v0, 0x1F                // original line 2
        
        apply_skeleton_mode(v0, 0x0060)
    }
        
    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_3_: {
        OS.patch_start(0x6E42C, 0x800F2C2C)
        jal     skeleton_mode_3_
        nop
        OS.patch_end()
        
        lw      t8, 0x0A88(s8)              // original line 1
        sll     t3, t8, 0x1                 // original line 2
        
        apply_skeleton_mode(t8, 0x0A88)
    }

    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_4_: {
        OS.patch_start(0x6E520, 0x800F2D20)
        jal     skeleton_mode_4_
        nop
        OS.patch_end()
        
        lw      t7, 0x0A88(s8)              // original line 1
        sll     t9, t7, 0x2                 // original line 2
        
        apply_skeleton_mode(t7, 0x0A88)
    }
        
    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_5_: {
        OS.patch_start(0x6DA28, 0x800F2228)
        jal     skeleton_mode_5_
        nop
        OS.patch_end()
        
        lw      t7, 0x0A88(t4)              // original line 1
        sll     t3, v1, 0x3                 // original line 2
        
        apply_skeleton_mode(t7, 0x0A88)
    }
}
}
