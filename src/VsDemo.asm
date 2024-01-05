// VsDemo.asm
if !{defined __VS_DEMO__} {
define __VS_DEMO__()
print "included VsDemo.asm\n"

// @ Description
// This file allows for Remix chars in the VS Demo screen

scope VsDemo {

    // @ Description
    // This uses our custom 1p name table
    OS.patch_start(0x18C914, 0x8018DBD4)
    li      s4, SinglePlayer.name_texture_table  // original lines 1/3
    mtc1    at, f20                              // original line 2
    OS.patch_end()

    // @ Description
    // Fix the offsets (original table adds 0x10)
    scope fix_offset_: {
        OS.patch_start(0x18C948, 0x8018DC08)
        jal     fix_offset_
        addu    t1, s4, t0                       // original line 1 - t1 = address of offset
        OS.patch_end()

        lw      t2, 0x0000(t1)                   // original line 2 - t2 = offset
        jr      ra
        addiu   t2, t2, 0x0010                   // t2 = adjusted offset
    }

    // @ Description
    // Allows remix characters to be focused on
    scope enable_focused_remix_chars_: {
        OS.patch_start(0x11735C, 0x80131CDC)
        jal     enable_focused_remix_chars_
        lw      s0, 0x0018(sp)                   // original line 2
        lw      ra, 0x0024(sp)                   // original line 1
        OS.patch_end()

        sw      ra, 0x0018(sp)                   // save ra

        _get_random_1:
        jal     Global.get_random_int_           // v0 = random char_id
        lli     a0, Character.NUM_CHARACTERS

        li      t0, Character.variant_type.table
        addu    t0, t0, v0                       // t0 = address of variant type
        lbu     t0, 0x0000(t0)                   // t0 = variant type
        bnez    t0, _get_random_1                // if not variant_type.NA, get another random char_id
        li      t1, 0x800A4AD0                   // t1 = location of struct with demo char_ids
        sb      v0, 0x000D(t1)                   // save char_id for first slot

        _get_random_2:
        jal     Global.get_random_int_           // v0 = random char_id
        lli     a0, Character.NUM_CHARACTERS

        li      t0, Character.variant_type.table
        addu    t0, t0, v0                       // t0 = address of variant type
        lbu     t0, 0x0000(t0)                   // t0 = variant type
        bnez    t0, _get_random_2                // if not variant_type.NA, get another random char_id
        li      t1, 0x800A4AD0                   // t1 = location of struct with demo char_ids
        lbu     t0, 0x000D(t1)                   // t0 = first slot's char_id
        beq     t0, v0, _get_random_2            // if we got the same char_id, get a different one
        sb      v0, 0x000E(t1)                   // save char_id for second slot

        lw      ra, 0x0018(sp)                   // restore ra
        jr      ra
        lw      s1, 0x001C(sp)                   // original line 3
    }

    // @ Description
    // Allows remix characters to be in the non-focused slots
    scope enable_nonfocused_remix_chars_: {
        OS.patch_start(0x18C668, 0x8018D928)
        jal     enable_nonfocused_remix_chars_
        lui     t7, 0x8019                       // original line 1
        OS.patch_end()

        sw      ra, 0x001C(sp)                   // save ra

        _get_random:
        jal     Global.get_random_int_           // v0 = random char_id
        lli     a0, Character.NUM_CHARACTERS

        li      t0, Character.variant_type.table
        addu    t0, t0, v0                       // t0 = address of variant type
        lbu     t0, 0x0000(t0)                   // t0 = variant type
        bnez    t0, _get_random                  // if not variant_type.NA, get another random char_id
        li      t1, 0x800A4AD0                   // t1 = location of struct with demo char_ids
        lbu     t0, 0x000D(t1)                   // t0 = first focused slot's char_id
        beq     t0, v0, _get_random              // if we got the same char_id, get a different one
        lbu     t0, 0x000E(t1)                   // t0 = second focused slot's char_id
        beq     t0, v0, _get_random              // if we got the same char_id, get a different one
        lli     t0, 0x0003                       // t0 = 3
        bne     t0, s1, _end                     // if not getting port 4, end
        lbu     t0, 0x0023(t2)                   // t0 = port 3 char_id
        beq     t0, v0, _get_random              // if we got the same char_id, get a different one

        _end:
        lw      ra, 0x001C(sp)                   // restore ra
        jr      ra
        lhu     t7, 0xE4E4(t7)                   // original line 2
    }

    // @ Description
    // Allows remix stages to be used
    scope enable_remix_stages_: {
        OS.patch_start(0x18C760, 0x8018DA20)
        jal     enable_remix_stages_
        andi    t6, t0, 0x00FF                   // original line 2
        OS.patch_end()

        addiu   sp, sp, -0x0030                  // allocate stack space
        sw      ra, 0x0004(sp)                   // save registers
        sw      v1, 0x0008(sp)                   // ~
        sw      s2, 0x000C(sp)                   // ~
        sw      v0, 0x0010(sp)                   // ~
        sw      t0, 0x0014(sp)                   // ~
        sw      t7, 0x0018(sp)                   // ~
        sw      t6, 0x001C(sp)                   // ~

        _get_random:
        jal     Global.get_random_int_           // v0 = random char_id
        lli     a0, Stages.id.MAX_STAGE_ID
        // Uncomment these and the test lines below to be able to quickly test all stages in order
        // li      t0, test
        // lw      v0, 0x0000(t0)
        // addiu   t1, v0, 0x0001
        // sw      t1, 0x0000(t0)

        li      t0, Stages.class_table
        addu    t0, t0, v0                       // t0 = address of stage class
        lbu     t0, 0x0000(t0)                   // t0 = stage class
        bnez    t0, _get_random                  // if not class.BATTLE, get another random stage_id
        lli     t0, Stages.id.REST               // t0 = Rest Area stage_id
        beq     t0, v0, _get_random              // if Rest Area, get another random stage_id
        or      t3, v0, r0                       // t3 = stage_id

        lw      ra, 0x0004(sp)                   // restore registers
        lw      v1, 0x0008(sp)                   // ~
        lw      s2, 0x000C(sp)                   // ~
        lw      v0, 0x0010(sp)                   // ~
        lw      t0, 0x0014(sp)                   // ~
        lw      t7, 0x0018(sp)                   // ~
        lw      t6, 0x001C(sp)                   // ~
        jr      ra
        addiu   sp, sp, 0x0030                   // deallocate stack space

        // test:
        // dw 0
    }

}

} // __VS_DEMO__
