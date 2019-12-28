// SinglePlayer.asm
if !{defined __SINGLE_PLAYER__} {
define __SINGLE_PLAYER__()
print "included SinglePlayer.asm\n"

// @ Description
// This file allows new characters to use 1P and Bonus features.

// TODO
// 1p mode
// - battle preview model not appearing
//   --> look at 80134B38 during battle preview, break on 80134C84
// - battle preview name file needs to be extended
// - continue?/gameover model not appearing
// - final picture/crash
// - possible overwrite of platform data after beating MH
// - DK stock icon missing
// - Falco crashes after pressing start on CSS

include "OS.asm"

scope SinglePlayer {

    // @ Description
    // This extends the high score BTT/BTP code that checks if all targets/platforms are achieved
    // to allow for new characters.
    scope extend_high_score_btx_count_check_: {
        OS.patch_start(0x149BAC, 0x80133B7C)
        j       extend_high_score_btx_count_check_
        nop
        _extend_high_score_btx_count_check_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    at, a0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      at, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.FALCO // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    at, at, t8                  // at = address of high score character struct
        lbu     v0, 0x0014(at)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x001C(at)              // v0 = # of platforms
        _return:
        addiu   at, r0, 0x000A              // original line 6
        j       0x80133BB0                  // return
        nop

        _original:
        j       _extend_high_score_btx_count_check_return
        nop
    }

    // @ Description
    // This extends the high score BTT/BTP display code to allow for new characters
    scope extend_high_score_btx_count_: {
        OS.patch_start(0x1499C0, 0x80133990)
        j       extend_high_score_btx_count_
        nop
        _extend_high_score_btx_count_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    t8, a0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.FALCO // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    t7, t7, t8                  // t7 = address of high score character struct
        lbu     v0, 0x0014(t7)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x001C(t7)              // v0 = # of platforms
        _return:
        jr      ra                          // return
        nop

        _original:
        j       _extend_high_score_btx_count_return
        nop
    }

    // @ Description
    // This extends the high score BTT/BTP time display code to allow for new characters
    scope extend_high_score_btx_time_: {
        OS.patch_start(0x149440, 0x80133410)
        j       extend_high_score_btx_time_
        nop
        _extend_high_score_btx_time_return:
        OS.patch_end()

        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x7714(t6)              // original line 2

        // a0 is character ID
        slti    t8, a0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.FALCO // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    t7, t7, t8                  // t7 = address of high score character struct
        lw      v1, 0x0010(t7)              // v0 = targets completion frame count
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lw      v1, 0x0018(t7)              // v0 = platforms completion frame count
        _return:
        j       0x80133438                  // return to end of original routine
        nop

        _original:
        j       _extend_high_score_btx_time_return
        nop
    }

    // @ Description
    // This extends the high score BTT failure write code to allow for new characters
    scope extend_high_score_btt_count_write_: {
        OS.patch_start(0x1130E4, 0x8018E9A4)
        j       extend_high_score_btt_count_write_
        nop
        _extend_high_score_btt_count_write_return:
        OS.patch_end()

        // a1 is character ID
        slti    at, a1, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.FALCO // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t8, t8, at                  // t8 = address of high score character struct
        lbu     v0, 0x0014(t8)              // v0 = # of targets
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6
        jal     0x800D45F4                  // original line 7
        sb      v1, 0x0014(t8)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 8)
        lw      ra, 0x0014(sp)              // original line 10

        _original:
        addu    v0, t8, t9                  // original line 1
        lbu     t0, 0x0470(v0)              // original line 2

        j       _extend_high_score_btt_count_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTT success write code to allow for new characters
    scope extend_high_score_btt_time_write_: {
        OS.patch_start(0x11310C, 0x8018E9CC)
        j       extend_high_score_btt_time_write_
        nop
        _extend_high_score_btt_time_write_return:
        OS.patch_end()

        // t1 is character ID sll'd 0x0005
        srl     v0, t1, 0x0005              // v0 = character_id
        slti    t2, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t2, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.FALCO // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t2, t2, v0                  // t2 = address of high score character struct
        addiu   t3, r0, 0x000A              // original line 4
        sb      t3, 0x0014(t2)              // store target count (modified original line 5)
        lw      v1, 0x0018(a0)              // original line 6
        lw      t4, 0x0010(t2)              // original line 7 (modified)
        sltu    at, v1, t4                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10
        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0010(t2)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14

        _original:
        lui     t2, 0x800A                  // original line 1
        addiu   t2, t2, 0x44E0              // original line 2

        j       _extend_high_score_btt_time_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTP failure write code to allow for new characters
    scope extend_high_score_btp_count_write_: {
        OS.patch_start(0x113158, 0x8018EA18)
        j       extend_high_score_btp_count_write_
        nop
        _extend_high_score_btp_count_write_return:
        OS.patch_end()

        // a1 is character ID
        slti    at, a1, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.FALCO // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t5, t5, at                  // t5 = address of high score character struct
        lbu     v0, 0x001C(t5)              // v0 = # of platforms
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6
        jal     0x800D45F4                  // original line 7
        sb      v1, 0x001C(t5)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 8)
        lw      ra, 0x0014(sp)              // original line 10

        _original:
        addu    v0, t5, t6                  // original line 1
        lbu     t7, 0x0478(v0)              // original line 2

        j       _extend_high_score_btp_count_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // This extends the high score BTP success write code to allow for new characters
    scope extend_high_score_btp_time_write_: {
        OS.patch_start(0x113180, 0x8018EA40)
        j       extend_high_score_btp_time_write_
        nop
        _extend_high_score_btp_time_write_return:
        OS.patch_end()

        // t8 is character ID sll'd 0x0005
        srl     v0, t8, 0x0005              // v0 = character_id
        slti    t2, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t9, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.FALCO // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t9, t9, v0                  // t9 = address of high score character struct
        addiu   t0, r0, 0x000A              // original line 4
        sb      t0, 0x001C(t9)              // store platform count (modified original line 5)
        lw      v1, 0x0018(a0)              // original line 6
        lw      t1, 0x0018(t9)              // original line 7 (modified)
        sltu    at, v1, t1                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10
        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0018(t9)              // store new high score in extended table
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14

        _original:
        lui     t9, 0x800A                  // original line 1
        addiu   t9, t9, 0x44E0              // original line 2

        j       _extend_high_score_btp_time_write_return
        nop

        _j_0x8018EA74:
        j       0x8018EA74                  // jump instead of branch
        nop
    }

    // @ Description
    // Modifies the tally loop for BTT/BTP to include new characters
    scope extend_btx_tally_: {
        OS.patch_start(0x14CCE8, 0x80136CB8)
        j       extend_btx_tally_._check_counts
        nop
        _extend_btx_tally_check_counts_return:
        OS.patch_end()
        OS.patch_start(0x1496C8, 0x80133698)
        j       extend_btx_tally_._ms
        nop
        _extend_btx_tally_ms_return:
        OS.patch_end()
        OS.patch_start(0x14965C, 0x8013362C)
        j       extend_btx_tally_._s
        nop
        _extend_btx_tally_s_return:
        OS.patch_end()
        OS.patch_start(0x1495F0, 0x801335C0)
        j       extend_btx_tally_._m
        nop
        _extend_btx_tally_m_return:
        OS.patch_end()

        // This checks that all targets have been broken or all platforms have been boarded
        _check_counts:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_check          // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s1, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.FALCO       // start at first new character
        _j_80136CA0:
        j       0x80136CA0                       // jump to loop start
        nop

        _original_check:
        bne     s0, s1, _j_80136CA0              // original line 1
        nop                                      // original line 2

        j       _extend_btx_tally_check_counts_return
        nop

        // This tallies milliseconds
        _ms:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_ms             // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.FALCO       // start at first new character
        j       0x80133668                       // jump to loop start
        nop

        _original_ms:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_ms_return      // return
        nop

        // This tallies seconds
        _s:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_s              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.FALCO       // start at first new character
        j       0x801335FC                       // jump to loop start
        nop

        _original_s:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_s_return       // return
        nop

        // This tallies seconds
        _m:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_m              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.FALCO       // start at first new character
        j       0x80133590                       // jump to loop start
        nop

        _original_m:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_m_return       // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTT so we can use new characters
    scope set_btt_stage_id_: {
        OS.patch_start(0x111950, 0x8018D210)
        j       set_btt_stage_id_
        nop
        _set_btt_stage_id_return:
        OS.patch_end()

        lw      t3, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t8, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.BTT_TABLE     // t8 = address of stage_id table
        addu    t8, t8, v0                  // ~
        addiu   t8, t8, -0x1D               // t8 = address of stage_id, adjusted to 0 base
        lb      t8, 0x0000(t8)              // t8 = stage_id
        j       _set_btt_stage_id_return    // return
        nop

        _original:
        addiu   t8, v0, 0x0011              // original line 2
        j       _set_btt_stage_id_return    // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP so we can use new characters
    scope set_btp_stage_id_: {
        OS.patch_start(0x111964, 0x8018D224)
        j       set_btp_stage_id_
        nop
        _set_btp_stage_id_return:
        OS.patch_end()

        // v0 is character ID
        slti    t4, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t4, _original               // otherwise use original table
        nop                                 // ~

        li      t4, Character.BTP_TABLE     // t4 = address of stage_id table
        addu    t4, t4, v0                  // ~
        addiu   t4, t4, -0x1D               // t4 = address of stage_id, adjusted to 0 base
        lb      t4, 0x0000(t4)              // t4 = stage_id
        sb      t4, 0x0001(t5)              // original line 2
        j       _set_btp_stage_id_return    // return
        nop

        _original:
        addiu   t4, v0, 0x001D              // original line 1
        sb      t4, 0x0001(t5)              // original line 2
        j       _set_btp_stage_id_return    // return
        nop
    }

    // @ Description
    // This extends the 1P high score display code to allow for new characters
    scope extend_high_score_1p_: {
        OS.patch_start(0x13C958, 0x80134758)
        j       extend_high_score_1p_
        nop
        _extend_high_score_1p_return:
        OS.patch_end()

        // a0 is character ID
        slti    t6, a0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.FALCO // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0000(t6)              // v0 = high score
        jr      ra                          // return
        nop

        _original:
        sll     t6, a0, 0x0005              // original line 1
        lui     v0, 0x800A                  // original line 2

        j       _extend_high_score_1p_return
        nop
    }

    // @ Description
    // This extends the 1P high score stock count display code to allow for new characters
    scope extend_high_score_1p_stock_count_: {
        OS.patch_start(0x13CB68, 0x80134968)
        j       extend_high_score_1p_stock_count_
        nop
        _extend_high_score_1p_stock_count_return:
        OS.patch_end()

        // a0 is character ID
        slti    t6, a0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.FALCO // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0008(t6)              // v0 = stock count
        jr      ra                          // return
        nop

        _original:
        sll     t6, a0, 0x0005              // original line 1
        lui     v0, 0x800A                  // original line 2

        j       _extend_high_score_1p_stock_count_return
        nop
    }
    
    // @ Description
    // This extends the 1P high score difficulty display code to allow for new characters
    scope extend_high_score_1p_difficulty_: {
        OS.patch_start(0x13CAD8, 0x801348D8)
        j       extend_high_score_1p_difficulty_
        nop
        _extend_high_score_1p_difficulty_return:
        OS.patch_end()

        // t4 is character ID
        slti    t5, t4, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a2, t4, -Character.id.FALCO // a2 = index to character struct in extended table
        sll     a2, a2, 0x0005              // a2 = offset to character struct in extended table
        addu    t5, t5, a2                  // t5 = address of high score character struct
        lbu     a2, 0x000C(t5)              // a2 = difficulty
        b       _return                     // return
        nop

        _original:
        sll     t5, t4, 0x0005              // original line 0 (line before line 1)
        addu    a2, a2, t5                  // original line 1
        lbu     a2, 0x4948(a2)              // original line 2

        _return:
        j       _extend_high_score_1p_difficulty_return
        nop
    }

    // @ Description
    // This extends the high score 1P write code to allow for new characters
    scope extend_high_score_1p_write_: {
        OS.patch_start(0x51F44, 0x800D6744)
        j       extend_high_score_1p_write_
        nop
        _extend_high_score_1p_write_return:
        OS.patch_end()

        // t6 is character ID
        slti    t2, t6, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      a3, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a3, a3, -0x045C             // a3 = adjusted table base for extended table
        addiu   t6, t6, -Character.id.FALCO // t6 = adjusted offset

        j       _extend_high_score_1p_write_return
        nop

        _original:
        lui     a3, 0x800A                  // original line 1
        addiu   a3, a3, 0x44E0              // original line 2

        j       _extend_high_score_1p_write_return
        nop
    }

    // @ Description
    // Modifies the tally loop for 1P to include new characters
    scope extend_1p_tally_: {
        OS.patch_start(0x13CD90, 0x80134B90)
        j       extend_1p_tally_
        nop
        _extend_1p_tally_return:
        OS.patch_end()

        addiu   a0, r0, 0x000C                   // a0 = 12
        bne     a0, s0, _original_check          // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.FALCO       // start at first new character
        _j_80134B84:
        j       0x80134B84                       // jump to loop start
        nop

        _original_check:
        bne     s0, s2, _j_80134B84              // original line 1
        addu    s1, s1, v0                       // original line 2

        j       _extend_1p_tally_return          // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTT during 1P so we can use new characters
    scope set_btt_stage_id_1p_: {
        OS.patch_start(0x1118F8, 0x8018D1B8)
        j       set_btt_stage_id_1p_
        nop
        _set_btt_stage_id_1p_return:
        OS.patch_end()

        lw      t8, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t7, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t7, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.BTT_TABLE     // t7 = address of stage_id table
        addu    t7, t7, v0                  // ~
        addiu   t7, t7, -0x1D               // t7 = address of stage_id, adjusted to 0 base
        lb      t7, 0x0000(t7)              // t7 = stage_id
        j       _set_btt_stage_id_1p_return // return
        nop

        _original:
        addiu   t7, v0, 0x0011              // original line 2
        j       _set_btt_stage_id_1p_return // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP during 1P so we can use new characters
    scope set_btp_stage_id_1p_: {
        OS.patch_start(0x111920, 0x8018D1E0)
        j       set_btp_stage_id_1p_
        nop
        _set_btp_stage_id_1p_return:
        OS.patch_end()

        lw      t2, 0x0000(a2)              // original line 1

        // v0 is character ID
        slti    t5, v0, Character.id.FALCO  // if (it's an added character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.BTP_TABLE     // t5 = address of stage_id table
        addu    t5, t5, v0                  // ~
        addiu   t5, t5, -0x1D               // t5 = address of stage_id, adjusted to 0 base
        lb      t5, 0x0000(t5)              // t5 = stage_id
        j       _set_btp_stage_id_1p_return // return
        nop

        _original:
        addiu   t5, v0, 0x001D              // original line 2
        j       _set_btp_stage_id_1p_return // return
        nop
    }

    // @ Description
    // This piggybacks off the code that writes SSB data to SRAM to write our extended table as well
    scope write_extended_high_score_table_: {
        OS.patch_start(0x00050014, 0x800D4634)
        jal     write_extended_high_score_table_
        nop
        OS.patch_end()

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        jr      ra                          // return
        nop
    }

    // @ Description
    // This piggybacks off the code that loads SSB data from SRAM to load our extended table as well
    scope load_extended_high_score_table_: {
        OS.patch_start(0x000500C4, 0x800D46E4)
        jal     load_extended_high_score_table_
        nop
        OS.patch_end()

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        // make sure times are correctly initialized
        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE
        lli     a2, 0x0000
        li      a3, 0x00034BC0
        _loop:
        lw      a1, 0x0010(a0)              // a1 = btt time
        beql    a1, r0, pc() + 8            // if (btt time = 0)
        sw      a3, 0x0010(a0)              // then set to default time
        lw      a1, 0x0018(a0)              // a1 = btp time
        beql    a1, r0, pc() + 8            // if (btp time = 0)
        sw      a3, 0x0018(a0)              // then set to default time
        addiu   a0, 0x0020                  // increment a0 to next character
        addiu   a2, 0x0001                  // increment a2 to next character
        slti    a1, a2, Character.ADD_CHARACTERS
        bnez    a1, _loop                   // if (more new characters to loop over) then loop
        nop

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        jr      ra                          // return
        nop
    }

    // @ Description
    // Name texture offsets in file 0x000C (non-adjusted - don't add 0x10 here for DF000000 00000000)
    scope name_texture {
        constant MARIO(0x00000128)
        constant FOX(0x00000248)
        constant DONKEY_KONG(0x00000368)
        constant SAMUS(0x000004E8)
        constant LUIGI(0x00000608)
        constant LINK(0x00000728)
        constant YOSHI(0x00000848)
        constant CAPTAIN_FALCON(0x00000A28)
        constant KIRBY(0x00000BA8)
        constant PIKACHU(0x00000D28)
        constant JIGGLYPUFF(0x00000F68)
        constant NESS(0x00001088)
        // TODO: update file and these offsets
        constant GND(0x00000A28)
        constant FALCO(0x00000248)
        constant YLINK(0x00000728)
        constant DRM(0x00000128)
        constant WARIO(0x00000128)
        constant DSAMUS(0x000004E8)
        constant BLANK(0x0)
    }

    name_texture_table:
    constant name_texture_table_origin(origin())
    dw name_texture.MARIO                   // Mario
    dw name_texture.FOX                     // Fox
    dw name_texture.DONKEY_KONG             // Donkey Kong
    dw name_texture.SAMUS                   // Samus
    dw name_texture.LUIGI                   // Luigi
    dw name_texture.LINK                    // Link
    dw name_texture.YOSHI                   // Yoshi
    dw name_texture.CAPTAIN_FALCON          // Captain Falcon
    dw name_texture.KIRBY                   // Kirby
    dw name_texture.PIKACHU                 // Pikachu
    dw name_texture.JIGGLYPUFF              // Jigglypuff
    dw name_texture.NESS                    // Ness
    dw name_texture.BLANK                   // Master Hand
    dw name_texture.BLANK                   // Metal Mario
    dw name_texture.BLANK                   // Polygon Mario
    dw name_texture.BLANK                   // Polygon Fox
    dw name_texture.BLANK                   // Polygon Donkey Kong
    dw name_texture.BLANK                   // Polygon Samus
    dw name_texture.BLANK                   // Polygon Luigi
    dw name_texture.BLANK                   // Polygon Link
    dw name_texture.BLANK                   // Polygon Yoshi
    dw name_texture.BLANK                   // Polygon Captain Falcon
    dw name_texture.BLANK                   // Polygon Kirby
    dw name_texture.BLANK                   // Polygon Pikachu
    dw name_texture.BLANK                   // Polygon Jigglypuff
    dw name_texture.BLANK                   // Polygon Ness
    dw name_texture.BLANK                   // Giant Donkey Kong
    dw name_texture.BLANK                   // (Placeholder)
    dw name_texture.BLANK                   // None (Placeholder)
    // new characters
    dw name_texture.FALCO                   // Falco
    dw name_texture.GND                     // Ganondorf
    dw name_texture.YLINK                   // Young Link
    dw name_texture.DRM                     // Dr. Mario
    dw name_texture.WARIO                   // Wario
    dw name_texture.DSAMUS                  // Dark Samus

    // @ Description
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x000C)
    scope get_name_texture_: {
        OS.patch_start(0x12BA4C, 0x8013270C)
//      lw      t4, 0x0028(t4)                    // original line 1
        jal     get_name_texture_
        or      a0, s1, r0                        // original line 2
        OS.patch_end()

        li      t4, name_texture_table            // t4 = texture offset table
        addu    t4, t4, t3                        // t4 = address of texture offset
        lw      t4, 0x0000(t4)                    // t4 = texture offset
        addiu   t4, t4, 0x0010                    // t4 = adjusted texture offset (+0x10 for DF000000 00000000)
        jr      ra                                // return
        nop
    }

    // @ Description
    // Changes the load from fgm_table instead of the original function table
    scope get_fgm_: {
        OS.patch_start(0x12DA2C, 0x801346EC)
//      sll     t7, t8, 0x0002                // original line 1
//      addu    a0, sp, t7                    // original line 2
        jal     get_fgm_
        nop
        jal     0x800269C0                    // original line 3
//      lhu     a0, 0x008A(a0)                // original line 4
        nop
        OS.patch_end()

        li      a0, CharacterSelect.fgm_table // a0 = fgm_table
        sll     t7, t8, 0x0001                // ~
        addu    a0, a0, t7                    // a0 = fgm_table + char offset
        lhu     a0, 0x0000(a0)                // a0 = fgm id
        jr      ra                            // return
        nop
    }

    // @ Description
    // Represents the amount of time the announcer waits between saying the name and saying "VS"
    scope name_delay {
        constant MARIO(0x00000032)
        constant FOX(0x00000032)
        constant DONKEY_KONG(0x00000046)
        constant SAMUS(0x00000032)
        constant LUIGI(0x00000032)
        constant LINK(0x00000032)
        constant YOSHI(0x00000032)
        constant CAPTAIN_FALCON(0x00000046)
        constant KIRBY(0x00000032)
        constant PIKACHU(0x00000032)
        constant JIGGLYPUFF(0x00000032)
        constant NESS(0x00000032)
        constant GND(0x00000046)
        constant FALCO(0x00000032)
        constant YLINK(0x00000046)
        constant DRM(0x00000052)
        constant WARIO(0x00000032)
        constant DSAMUS(0x00000046)
        constant PLACEHOLDER(0x00000032)
    }

    name_delay_table:
    constant name_delay_table_origin(origin())
    dw name_delay.MARIO                   // Mario
    dw name_delay.FOX                     // Fox
    dw name_delay.DONKEY_KONG             // Donkey Kong
    dw name_delay.SAMUS                   // Samus
    dw name_delay.LUIGI                   // Luigi
    dw name_delay.LINK                    // Link
    dw name_delay.YOSHI                   // Yoshi
    dw name_delay.CAPTAIN_FALCON          // Captain Falcon
    dw name_delay.KIRBY                   // Kirby
    dw name_delay.PIKACHU                 // Pikachu
    dw name_delay.JIGGLYPUFF              // Jigglypuff
    dw name_delay.NESS                    // Ness
    dw name_delay.PLACEHOLDER             // Master Hand
    dw name_delay.PLACEHOLDER             // Metal Mario
    dw name_delay.PLACEHOLDER             // Polygon Mario
    dw name_delay.PLACEHOLDER             // Polygon Fox
    dw name_delay.PLACEHOLDER             // Polygon Donkey Kong
    dw name_delay.PLACEHOLDER             // Polygon Samus
    dw name_delay.PLACEHOLDER             // Polygon Luigi
    dw name_delay.PLACEHOLDER             // Polygon Link
    dw name_delay.PLACEHOLDER             // Polygon Yoshi
    dw name_delay.PLACEHOLDER             // Polygon Captain Falcon
    dw name_delay.PLACEHOLDER             // Polygon Kirby
    dw name_delay.PLACEHOLDER             // Polygon Pikachu
    dw name_delay.PLACEHOLDER             // Polygon Jigglypuff
    dw name_delay.PLACEHOLDER             // Polygon Ness
    dw name_delay.PLACEHOLDER             // Giant Donkey Kong
    dw name_delay.PLACEHOLDER             // (Placeholder)
    dw name_delay.PLACEHOLDER             // None (Placeholder)
    // new characters
    dw name_delay.FALCO                   // Falco
    dw name_delay.GND                     // Ganondorf
    dw name_delay.YLINK                   // Young Link
    dw name_delay.DRM                     // Dr. Mario
    dw name_delay.WARIO                   // Wario
    dw name_delay.DSAMUS                  // Dark Samus

    // @ Description
    // Allows for custom entries of name delays (time from when announcer says name to when he says "VS")
    scope get_name_delay_: {
        OS.patch_start(0x12D9DC, 0x8013469C)
//      lw      t3, 0x0000(t1)                    // original line 1
//      addiu   t4, t3, 0x0001                    // original line 2
        jal     get_name_delay_
        nop
        OS.patch_end()

        // t2 is offset in table
        li      t4, name_delay_table              // t4 = delay table
        addu    t4, t4, t2                        // t4 = address of delay
        lw      t4, 0x0000(t4)                    // t4 = delay
        jr      ra                                // return
        nop
    }

} // __SINGLE_PLAYER__
