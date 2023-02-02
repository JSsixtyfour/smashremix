// SinglePlayer.asm
if !{defined __SINGLE_PLAYER__} {
define __SINGLE_PLAYER__()
print "included SinglePlayer.asm\n"

// @ Description
// This file allows new characters to use 1P and Bonus features.

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

        li      at, Bonus.mode
        lw      at, 0x0000(at)              // at = mode (0 - Normal, 1 - Remix)
        bnez    at, _remix                  // if Remix mode, get differently
        nop

        _normal:
        slti    at, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        // exclude some added characters from check
        li      at, Character.BTT_TABLE     // assume characters always have both BTT and BTP stage ids if legal
        addu    at, at, a0                  // at = address of BTX stage id
        lbu     v0, 0x0000(at)              // v0 = BTX stage id
        addiu   at, r0, 0x00FF              // at = 0x000000FF
        beq     at, v0, _return             // if not a valid stage id,
        addiu   v0, r0, 0x000A              // then set v0 to A in order to continue looping

        li      at, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
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

        _remix:
        li      t8, Bonus.stage
        lw      t8, 0x0000(t8)              // t8 = selected stage index
        li      at, Bonus.btt_stage_table   // at = btt_stage_table
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   at, at, Bonus.btp_stage_table - Bonus.btt_stage_table // at = btp_stage_table
        addu    at, at, t8                  // at = stage_id address
        lbu     v0, 0x0000(at)              // v0 = stage_id
        li      at, Character.BTT_TABLE     // at = BTT_TABLE
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   at, at, Character.BTP_TABLE - Character.BTT_TABLE // at = BTP_TABLE
        addu    at, at, a0                  // at = default stage_id address
        lbu     at, 0x0000(at)              // at = default stage_id
        beq     v0, at, _normal             // if the selected stage_id is the default one, get from normal tables
        lli     at, Character.NUM_CHARACTERS * 0x08
        multu   at, t8
        mflo    t8                          // t8 = offset to stage's high score table
        li      at, Bonus.remix_bonus_high_score_table
        addu    at, at, t8                  // at = high score table start
        sll     t8, a0, 0x0003              // t8 = offset to character's high score struct
        addu    at, at, t8                  // at = address of high score struct
        lbu     v0, 0x0000(at)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x0004(at)              // v0 = # of platforms
        b       _return
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

        li      t8, Bonus.mode
        lw      t8, 0x0000(t8)              // t8 = mode (0 - Normal, 1 - Remix)
        bnez    t8, _remix                  // if Remix mode, get differently
        nop

        _normal:
        slti    t8, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
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

        _remix:
        li      t8, Bonus.stage
        lw      t8, 0x0000(t8)              // t8 = selected stage index
        li      t7, Bonus.btt_stage_table   // t7 = btt_stage_table
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   t7, t7, Bonus.btp_stage_table - Bonus.btt_stage_table // t7 = btp_stage_table
        addu    t7, t7, t8                  // t7 = stage_id address
        lbu     v0, 0x0000(t7)              // v0 = stage_id
        li      t7, Character.BTT_TABLE     // t7 = BTT_TABLE
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   t7, t7, Character.BTP_TABLE - Character.BTT_TABLE // t7 = BTP_TABLE
        addu    t7, t7, a0                  // t7 = default stage_id address
        lbu     t7, 0x0000(t7)              // t7 = default stage_id
        beq     v0, t7, _normal             // if the selected stage_id is the default one, get from normal tables
        lli     t7, Character.NUM_CHARACTERS * 0x08
        multu   t7, t8
        mflo    t8                          // t8 = offset to stage's high score table
        li      t7, Bonus.remix_bonus_high_score_table
        addu    t7, t7, t8                  // t7 = high score table start
        sll     t8, a0, 0x0003              // t8 = offset to character's high score struct
        addu    t7, t7, t8                  // t7 = address of high score struct
        lbu     v0, 0x0000(t7)              // v0 = # of targets
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lbu     v0, 0x0004(t7)              // v0 = # of platforms
        b       _return
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

        li      t8, Bonus.mode
        lw      t8, 0x0000(t8)              // t8 = mode (0 - Normal, 1 - Remix)
        bnez    t8, _remix                  // if Remix mode, get differently
        nop

        _normal:
        slti    t8, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   t8, a0, -Character.id.BOSS  // t8 = index to character struct in extended table
        sll     t8, t8, 0x0005              // t8 = offset to character struct in extended table
        addu    t7, t7, t8                  // t7 = address of high score character struct
        lw      v1, 0x0010(t7)              // v1 = targets completion frame count
        bnel    t6, r0, _return             // if (t6 = 1) then get platforms instead:
        lw      v1, 0x0018(t7)              // v1 = platforms completion frame count
        _return:
        j       0x80133438                  // return to end of original routine
        nop

        _original:
        j       _extend_high_score_btx_time_return
        nop

        _remix:
        li      t8, Bonus.stage
        lw      t8, 0x0000(t8)              // t8 = selected stage index
        li      t7, Bonus.btt_stage_table   // t7 = btt_stage_table
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   t7, t7, Bonus.btp_stage_table - Bonus.btt_stage_table // t7 = btp_stage_table
        addu    t7, t7, t8                  // t7 = stage_id address
        lbu     v1, 0x0000(t7)              // v1 = stage_id
        li      t7, Character.BTT_TABLE     // t7 = BTT_TABLE
        bnezl   t6, pc() + 8                // if platforms, use btp_stage_table
        addiu   t7, t7, Character.BTP_TABLE - Character.BTT_TABLE // t7 = BTP_TABLE
        addu    t7, t7, a0                  // t7 = default stage_id address
        lbu     t7, 0x0000(t7)              // t7 = default stage_id
        beq     v1, t7, _normal             // if the selected stage_id is the default one, get from normal tables
        lli     t7, Character.NUM_CHARACTERS * 0x08
        multu   t7, t8
        mflo    t8                          // t8 = offset to stage's high score table
        li      t7, Bonus.remix_bonus_high_score_table
        addu    t7, t7, t8                  // t7 = high score table start
        sll     t8, a0, 0x0003              // t8 = offset to character's high score struct
        addu    t7, t7, t8                  // t7 = address of high score struct
        lw      v1, 0x0000(t7)              // v1 = targets completion frame count
        bnel    t6, r0, pc() + 8            // if (t6 = 1) then get platforms instead:
        lw      v1, 0x0004(t7)              // v1 = platforms completion frame count
        sll     v1, v1, 0x0008              // shift left to chop off first byte
        b       _return
        srl     v1, v1, 0x0008              // v1 = frame count
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

        li      at, SinglePlayerEnemy.enemy_port
        lw      at, 0x0000(at)              // at = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnezl   at, _j_0x8018EA74
        lw      ra, 0x0014(sp)              // original line 6

        li      at, Global.match_info
        lw      at, 0x0000(at)              // at = match info
        lbu     v0, 0x0001(at)              // v0 = stage_id
        li      at, Character.BTT_TABLE
        addu    at, at, a1                  // at = address of character's default BTT stage_id
        lbu     at, 0x0000(at)              // at = character's default BTT stage_id
        bne     at, v0, _remix              // if not the character's default stage, store in custom table
        slti    at, a1, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.BOSS  // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t8, t8, at                  // t8 = address of high score character struct
        addiu   t8, t8, 0x0014              // t8 = address of # of targets

        _update:
        lbu     v0, 0x0000(t8)              // v0 = # of targets
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6



        jal     0x800D45F4                  // original line 7
        sb      v1, 0x0000(t8)              // store new high score in extended table
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

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, v0, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0000                  // a1 = BTT

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     at, Character.NUM_CHARACTERS * 0x08
        multu   at, v0
        mflo    t8                          // t8 = offset to stage's high score table
        li      at, Bonus.remix_bonus_high_score_table
        addu    at, at, t8                  // at = high score table start
        sll     t8, a1, 0x0003              // t8 = offset to character's high score struct
        b       _update
        addu    t8, at, t8                  // t8 = address of # of targets
    }

    // @ Description
    // This extends the high score BTT success write code to allow for new characters
    scope extend_high_score_btt_time_write_: {
        OS.patch_start(0x11310C, 0x8018E9CC)
        j       extend_high_score_btt_time_write_
        nop
        _extend_high_score_btt_time_write_return:
        OS.patch_end()

        li      at, SinglePlayerEnemy.enemy_port
        lw      at, 0x0000(at)              // at = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnezl   at, _j_0x8018EA74
        lw      ra, 0x0014(sp)              // original line 14

        // t1 = character ID sll'd 0x0005
        srl     v0, t1, 0x0005              // v0 = character_id

        // a0 = match info
        lbu     t9, 0x0001(a0)              // t9 = stage_id
        li      t2, Character.BTT_TABLE
        addu    t2, t2, v0                  // t2 = address of character's default BTT stage_id
        lbu     t2, 0x0000(t2)              // t2 = character's default BTT stage_id
        bne     t2, t9, _remix              // if not the character's default stage, store in custom table
        slti    t2, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t2, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t2, t2, v0                  // t2 = address of high score character struct
        addiu   t3, r0, 0x000A              // original line 4
        sb      t3, 0x0014(t2)              // store target count (modified original line 5)
        addiu   t2, t2, 0x0010              // t2 = address of target frame count

        _update:
        lw      v1, 0x0018(a0)              // original line 6
        lw      t4, 0x0000(t2)              // original line 7 (modified)
        sltu    at, v1, t4                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10

        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0000(t2)              // store new high score in extended table
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

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, t9, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0000                  // a1 = BTT

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     t4, Character.NUM_CHARACTERS * 0x08
        multu   t4, v0
        mflo    t2                          // t2 = offset to stage's high score table
        li      t4, Bonus.remix_bonus_high_score_table
        addu    t4, t4, t2                  // t4 = high score table start
        srl     t3, t1, 0x0002              // t3 = offset to character's high score struct
        addu    t2, t4, t3                  // t2 = address of high score struct
        addiu   t3, r0, 0x000A              // original line 4
        sb      t3, 0x0000(t2)              // store target count (modified original line 5)

        lw      v1, 0x0018(a0)              // original line 6
        lw      t4, 0x0000(t2)              // original line 7 (modified)
        sll     t4, t4, 0x0008              // shift left to chop off first byte
        srl     t4, t4, 0x0008              // t4 = frame count
        sltu    at, v1, t4                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10
        sw      v1, 0x0000(t2)              // store new high score in extended table
        jal     0x800D45F4                  // original line 11
        sb      t3, 0x0000(t2)              // store target count again!
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14
    }

    // @ Description
    // This extends the high score BTT success new record check to allow for new characters
    scope extend_high_score_btt_new_record_check_: {
        OS.patch_start(0x111C9C, 0x8018D55C)
        j       extend_high_score_btt_new_record_check_
        nop
        _extend_high_score_btt_new_record_check_return:
        OS.patch_end()

        // t0 is character ID

        li      at, Global.match_info
        lw      at, 0x0000(at)              // at = match info
        lbu     v0, 0x0001(at)              // v0 = stage_id
        li      at, Character.BTT_TABLE
        addu    at, at, t0                  // at = address of character's default BTT stage_id
        lbu     at, 0x0000(at)              // at = character's default BTT stage_id
        bne     at, v0, _remix              // if not the character's default stage, store in custom table
        slti    t2, t0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t2, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, t0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    v0, t2, v0                  // v0 = address of high score character struct
        lbu     t3, 0x0014(v0)              // t3 = target count (modified original line 5)
        addiu   v0, v0, 0x0010              // v0 = address of best time

        _update:
        addiu   at, r0, 0x000A              // original line 6
        lui     t4, 0x800A                  // original line 7
        bne     t3, at, _j_0x8018D5A8       // original line 8 (modified to use jump)
        nop                                 // original line 9

        lw      t4, 0x50E8(t4)              // original line 10
        lw      t6, 0x0000(v0)              // t6 = current best time (modified original line 11)
        j       0x8018D588                  // return
        nop

        _original:
        lui     t2, 0x800A                  // original line 1
        addiu   t2, t2, 0x44E0              // original line 2

        j       _extend_high_score_btt_new_record_check_return
        nop

        _j_0x8018D5A8:
        j       0x8018D5A8                  // jump instead of branch
        nop

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, v0, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0000                  // a1 = BTT

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     t4, Character.NUM_CHARACTERS * 0x08
        multu   t4, v0
        mflo    t2                          // t2 = offset to stage's high score table
        li      t4, Bonus.remix_bonus_high_score_table
        addu    t4, t4, t2                  // t4 = high score table start
        sll     t3, t0, 0x0003              // t3 = offset to character's high score struct
        addu    v0, t4, t3                  // v0 = address of high score struct
        lbu     t3, 0x0000(v0)              // t3 = target count (modified original line 5)

        addiu   at, r0, 0x000A              // original line 6
        lui     t4, 0x800A                  // original line 7
        bne     t3, at, _j_0x8018D5A8       // original line 8 (modified to use jump)
        nop                                 // original line 9

        lw      t4, 0x50E8(t4)              // original line 10
        lw      t6, 0x0000(v0)              // t6 = current best time (modified original line 11)
        sll     t6, t6, 0x0008              // shift left to chop off first byte
        j       0x8018D588                  // return
        srl     t6, t6, 0x0008              // t6 = frame count
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

        li      at, SinglePlayerEnemy.enemy_port
        lw      at, 0x0000(at)              // at = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnezl   at, _j_0x8018EA74
        lw      ra, 0x0014(sp)              // original line 6

        li      at, Global.match_info
        lw      at, 0x0000(at)              // at = match info
        lbu     v0, 0x0001(at)              // v0 = stage_id
        li      at, Character.BTP_TABLE
        addu    at, at, a1                  // at = address of character's default BTP stage_id
        lbu     at, 0x0000(at)              // at = character's default BTP stage_id
        bne     at, v0, _remix              // if not the character's default stage, store in custom table
        slti    at, a1, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    at, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   at, a1, -Character.id.BOSS  // at = index to character struct in extended table
        sll     at, at, 0x0005              // at = offset to character struct in extended table
        addu    t5, t5, at                  // t5 = address of high score character struct
        addiu   t5, t5, 0x001C              // t5 = address of # of platforms

        _update:
        lbu     v0, 0x0000(t5)              // v0 = # of platforms
        lbu     v1, 0x0038(a3)              // original line 3
        slt     at, v0, v1                  // original line 4
        beql    at, r0, _j_0x8018EA74       // original line 5 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 6

        jal     0x800D45F4                  // original line 7
        sb      v1, 0x0000(t5)              // store new high score in extended table
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

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, v0, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0001                  // a1 = BTP

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     at, Character.NUM_CHARACTERS * 0x08
        multu   at, v0
        mflo    t5                          // t5 = offset to stage's high score table
        li      at, Bonus.remix_bonus_high_score_table
        addu    at, at, t5                  // at = high score table start
        sll     t5, a1, 0x0003              // t5 = offset to character's high score struct
        addu    at, at, t5                  // at = address of high score struct
        b       _update
        addiu   t5, at, 0x0004              // t5 = address of # of platforms
    }

    // @ Description
    // This extends the high score BTP success write code to allow for new characters
    scope extend_high_score_btp_time_write_: {
        OS.patch_start(0x113180, 0x8018EA40)
        j       extend_high_score_btp_time_write_
        nop
        _extend_high_score_btp_time_write_return:
        OS.patch_end()

        li      at, SinglePlayerEnemy.enemy_port
        lw      at, 0x0000(at)              // at = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnezl   at, _j_0x8018EA74
        lw      ra, 0x0014(sp)              // original line 14

        // t8 is character ID sll'd 0x0005
        srl     v0, t8, 0x0005              // v0 = character_id

        // a0 = match info
        lbu     t9, 0x0001(a0)              // t9 = stage_id
        li      t2, Character.BTP_TABLE
        addu    t2, t2, v0                  // t2 = address of character's default BTP stage_id
        lbu     t2, 0x0000(t2)              // t2 = character's default BTP stage_id
        bne     t2, t9, _remix              // if not the character's default stage, store in custom table
        slti    t2, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      t9, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, v0, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t9, t9, v0                  // t9 = address of high score character struct
        addiu   t0, r0, 0x000A              // original line 4
        sb      t0, 0x001C(t9)              // store platform count (modified original line 5)
        addiu   t9, t9, 0x0018              // t9 = address of platform frame count

        _update:
        lw      v1, 0x0018(a0)              // original line 6
        lw      t1, 0x0000(t9)              // original line 7 (modified)
        sltu    at, v1, t1                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10

        jal     0x800D45F4                  // original line 11
        sw      v1, 0x0000(t9)              // store new high score in extended table
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

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, t9, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0001                  // a1 = BTP

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     at, Character.NUM_CHARACTERS * 0x08
        multu   at, v0
        mflo    t9                          // t9 = offset to stage's high score table
        li      at, Bonus.remix_bonus_high_score_table
        addu    at, at, t9                  // at = high score table start
        srl     t0, t8, 0x0002              // t0 = offset to character's high score struct
        addu    t9, at, t0                  // t9 = address of high score struct
        addiu   t0, r0, 0x000A              // original line 4
        sb      t0, 0x0004(t9)              // store platform count (modified original line 5)

        lw      v1, 0x0018(a0)              // original line 6
        lw      t1, 0x0004(t9)              // original line 7 (modified)
        sll     t1, t1, 0x0008              // shift left to chop off first byte
        srl     t1, t1, 0x0008              // t1 = frame count
        sltu    at, v1, t1                  // original line 8
        beql    at, r0, _j_0x8018EA74       // original line 9 (modified to use jump)
        lw      ra, 0x0014(sp)              // original line 10

        sw      v1, 0x0004(t9)              // store new high score in extended table
        jal     0x800D45F4                  // original line 11
        sb      t0, 0x0004(t9)              // store platform count again!
        beq     r0, r0, _j_0x8018EA74       // return (modified line 13)
        lw      ra, 0x0014(sp)              // original line 14
    }

    // @ Description
    // This extends the high score BTP success new record check to allow for new characters
    scope extend_high_score_btp_new_record_check_: {
        OS.patch_start(0x112100, 0x8018D9C0)
        j       extend_high_score_btp_new_record_check_
        nop
        _extend_high_score_btp_new_record_check_return:
        OS.patch_end()

        // t2 is character ID

        li      at, Global.match_info
        lw      at, 0x0000(at)              // at = match info
        lbu     v0, 0x0001(at)              // v0 = stage_id
        li      at, Character.BTP_TABLE
        addu    at, at, t2                  // at = address of character's default BTP stage_id
        lbu     at, 0x0000(at)              // at = character's default BTP stage_id
        bne     at, v0, _remix              // if not the character's default stage, store in custom table
        slti    t4, t2, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t4, _original               // otherwise use original table
        nop                                 // ~

        li      t4, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, t2, -Character.id.BOSS  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    v0, t4, v0                  // v0 = address of high score character struct
        lbu     t5, 0x001C(v0)              // t5 = platform count (modified original line 5)
        addiu   v0, v0, 0x0018              // v0 = address of best time

        _update:
        addiu   at, r0, 0x000A              // original line 6
        lui     t6, 0x800A                  // original line 7
        bne     t5, at, _j_0x8018DA0C       // original line 8 (modified to use jump)
        nop                                 // original line 9

        lw      t6, 0x50E8(t6)              // original line 10
        lw      t8, 0x0000(v0)              // t8 = current best time (modified original line 11)
        j       0x8018D9EC                  // return
        nop

        _original:
        lui     t4, 0x800A                  // original line 1
        addiu   t4, t4, 0x44E0              // original line 2

        j       _extend_high_score_btp_new_record_check_return
        nop

        _j_0x8018DA0C:
        j       0x8018DA0C                  // jump instead of branch
        nop

        _remix:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        or      a0, v0, r0                  // a0 = stage_id
        jal     Bonus.get_bonus_stage_index_ // v0 = stage index
        lli     a1, 0x0001                  // a1 = BTP

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lli     t4, Character.NUM_CHARACTERS * 0x08
        multu   t4, v0
        mflo    at                          // at = offset to stage's high score table
        li      t4, Bonus.remix_bonus_high_score_table
        addu    t4, t4, at                  // t4 = high score table start
        sll     t5, t2, 0x0003              // t5 = offset to character's high score struct
        addu    t4, t4, t5                  // t4 = address of high score struct
        lbu     t5, 0x0004(t4)              // t5 = platform count (modified original line 5)
        addiu   v0, t4, 0x0004              // v0 = address of best time

        addiu   at, r0, 0x000A              // original line 6
        lui     t6, 0x800A                  // original line 7
        bne     t5, at, _j_0x8018DA0C       // original line 8 (modified to use jump)
        nop                                 // original line 9

        lw      t6, 0x50E8(t6)              // original line 10
        lw      t8, 0x0000(v0)              // t8 = current best time (modified original line 11)
        sll     t8, t8, 0x0008              // shift left to chop off first byte
        j       0x8018D9EC                  // return
        srl     t8, t8, 0x0008              // t8 = frame count
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
        OS.patch_start(0x149698, 0x80133668)
        j     extend_btx_tally_._ms_exclude_check
        nop
        _ms_exclude_check_return:
        OS.patch_end()
        OS.patch_start(0x14965C, 0x8013362C)
        j       extend_btx_tally_._s
        nop
        _extend_btx_tally_s_return:
        OS.patch_end()
        OS.patch_start(0x14962C, 0x801335FC)
        j       extend_btx_tally_._s_exclude_check
        nop
        _s_exclude_check_return:
        OS.patch_end()
        OS.patch_start(0x1495F0, 0x801335C0)
        j       extend_btx_tally_._m
        nop
        _extend_btx_tally_m_return:
        OS.patch_end()
        OS.patch_start(0x1495C0, 0x80133590)
        j       extend_btx_tally_._m_exclude_check
        nop
        _m_exclude_check_return:
        OS.patch_end()

        // This checks that all targets have been broken or all platforms have been boarded
        _check_counts:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_check          // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s1, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
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
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x80133668                       // jump to loop start
        nop

        _original_ms:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_ms_return      // return
        nop

        // This excludes illegal characters from the milliseconds tally
        _ms_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_ms_exclude         // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x8013368C            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_ms_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _ms_exclude_check_return         // return
        nop

        _j_0x8013368C:
        j       0x8013368C                       // jump since we can't branch
        nop

        // This tallies seconds
        _s:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_s              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x801335FC                       // jump to loop start
        nop

        _original_s:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_s_return       // return
        nop

        // This excludes illegal characters from the seconds tally
        _s_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_s_exclude          // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x80133620            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_s_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _s_exclude_check_return          // return
        nop

        _j_0x80133620:
        j       0x80133620                       // jump since we can't branch
        nop

        // This tallies minutes
        _m:
        addiu   v0, r0, 0x000C                   // v0 = 12
        bne     v0, s0, _original_m              // if (we are finished with new characters) then jump to original path
        nop                                      // otherwise set to new characters and loop some more:
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        addiu   s0, r0, Character.id.BOSS        // start after original cast
        j       0x80133590                       // jump to loop start
        nop

        _original_m:
        lw      ra, 0x0024(sp)                   // original line 1
        or      v0, s1, r0                       // original line 2

        j       _extend_btx_tally_m_return       // return
        nop

        // This excludes illegal characters from the minutes tally
        _m_exclude_check:
        slti    a0, s0, Character.id.BOSS        // if (it's not an original character) then we'll check BTT_TABLE
        bnez    a0, _original_m_exclude          // otherwise use original lines
        nop                                      // ~

        li      a0, Character.BTT_TABLE          // assume characters always have both BTT and BTP stage ids if legal
        addu    a0, a0, s0                       // a0 = address of BTX stage id
        lbu     v0, 0x0000(a0)                   // v0 = BTX stage id
        addiu   a0, r0, 0x00FF                   // a0 = 0x000000FF
        beq     a0, v0, _j_0x801335B4            // if not a valid stage id,
        nop                                      // then skip adding this to the highscore and continue

        _original_m_exclude:
        jal     0x801322BC                       // original line 1
        or      a0, s0, r0                       // original line 2

        j       _m_exclude_check_return          // return
        nop

        _j_0x801335B4:
        j       0x801335B4                       // jump since we can't branch
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

        li      t5, SinglePlayerModes.singleplayer_mode_flag // t5 = Single Player Mode Flag
        lw     	t5, 0x0000(t5)              // t5 = 4 if Remix 1p
        addiu	t1, r0, 0x0004              // Remix 1p Flag
        beq     t5, t1, _remix_1p
        nop

        li      t8, Bonus.mode
        lw      t8, 0x0000(t8)              // t8 = Bonus mode (0 = Normal, 1 = Remix)
        bnez    t8, _remix_mode             // if Remix mode, get selected stage
        nop

        // v0 is character ID
        slti    t8, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t8, _original               // otherwise use original table
        nop                                 // ~

        li      t8, Character.BTT_TABLE     // t8 = address of stage_id table
        addu    t8, t8, v0                  // t8 = address of stage_id, adjusted to 0 base
        j       _set_btt_stage_id_return    // return
        lb      t8, 0x0000(t8)              // t8 = stage_id

        _original:
        j       _set_btt_stage_id_return    // return
        addiu   t8, v0, 0x0011              // original line 2

        _remix_1p:
        li      t8, Character.REMIX_BTT_TABLE     // t8 = address of stage_id table
        addu    t8, t8, v0                  // t8 = address of stage_id, adjusted to 0 base
        j       _set_btt_stage_id_return    // return
        lb      t8, 0x0000(t8)              // t8 = stage_id

        _remix_mode:
        li      t8, Bonus.stage
        lw      t8, 0x0000(t8)              // t8 = stage index
        li      t1, Bonus.btt_stage_table
        addu    t1, t1, t8                  // t1 = address of stage_id to use
        j       _set_btt_stage_id_return    // return
        lbu     t8, 0x0000(t1)              // t8 = stage_id
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP so we can use new characters
    scope set_btp_stage_id_: {
        OS.patch_start(0x111964, 0x8018D224)
        j       set_btp_stage_id_
        nop
        _set_btp_stage_id_return:
        OS.patch_end()

        li      t4, SinglePlayerModes.singleplayer_mode_flag // t4 = Single Player Mode Flag
        lw     	t4, 0x0000(t4)              // t4 = 1 if multiman
        addiu	t1, r0, 0x0004              // Remix 1p Flag
        beq     t4, t1, _remix_1p
        nop

        li      t4, Bonus.mode
        lw      t4, 0x0000(t4)              // t4 = Bonus mode (0 = Normal, 1 = Remix)
        bnez    t4, _remix_mode             // if Remix mode, get selected stage
        nop

        // v0 is character ID
        slti    t4, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t4, _original               // otherwise use original table
        nop                                 // ~

        li      t4, Character.BTP_TABLE     // t4 = address of stage_id table
        addu    t4, t4, v0                  // t4 = address of stage_id, adjusted to 0 base
        lb      t4, 0x0000(t4)              // t4 = stage_id
        j       _set_btp_stage_id_return    // return
        sb      t4, 0x0001(t5)              // original line 2

        _original:
        addiu   t4, v0, 0x001D              // original line 1
        j       _set_btp_stage_id_return    // return
        sb      t4, 0x0001(t5)              // original line 2

        _remix_1p:
        li      t4, Character.REMIX_BTP_TABLE  // t4 = address of stage_id table
        addu    t4, t4, v0                  // t4 = address of stage_id, adjusted to 0 base
        lb      t4, 0x0000(t4)              // t4 = stage_id
        j       _set_btp_stage_id_return    // return
        sb      t4, 0x0001(t5)              // original line 2

        _remix_mode:
        li      t4, Bonus.stage
        lw      t4, 0x0000(t4)              // t4 = stage index
        li      t1, Bonus.btp_stage_table
        addu    t1, t1, t4                  // t1 = address of stage_id to use
        lbu     t4, 0x0000(t1)              // t8 = stage_id
        j       _set_btp_stage_id_return    // return
        sb      t4, 0x0001(t5)              // original line 2
    }

    // @ Description
    // This extends the 1P high score display code to allow for new characters
    scope extend_high_score_1p_: {
        OS.patch_start(0x13C958, 0x80134758)
        j       extend_high_score_1p_
        nop
        _extend_high_score_1p_return:
        OS.patch_end()

        li      v0, SinglePlayerModes.singleplayer_mode_flag // v0 = Single Player Mode Flag
        lw     	v0, 0x0000(v0)              // v0 = 4 if Remix 1p
        addiu	t6, r0, 0x0004              // Remix 1p Flag
        beq     v0, t6, _remix_1p
        // a0 is character ID
        slti    t6, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        addiu	t6, r0, 0x0005              // Allstar Flag
        beq     v0, t6, _allstar
        slti    t6, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.BOSS  // v0 = index to character struct in extended table
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

        _remix_1p:
        li      t6, Character.REMIX_1P_HIGH_SCORE_TABLE
        addiu   v0, a0, r0                  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0000(t6)              // v0 = high score
        jr      ra                          // return
        nop

        _allstar:
        li      t6, Character.ALLSTAR_HIGH_SCORE_TABLE
        addiu   v0, a0, r0                  // v0 = index to character struct in extended table
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0000(t6)              // v0 = high score
        jr      ra                          // return
        nop
    }

    // @ Description
    // This extends the 1P high score bonus count display code to allow for new characters
    scope extend_high_score_1p_bonus_count_: {
        OS.patch_start(0x13CB68, 0x80134968)
        j       extend_high_score_1p_bonus_count_
        nop
        _extend_high_score_1p_bonus_count_return:
        OS.patch_end()

        // a0 is character ID

        li      v0, SinglePlayerModes.singleplayer_mode_flag // v0 = Single Player Mode Flag
        lw     	v0, 0x0000(v0)              // v0 = 4 if Remix 1p
        addiu	t6, r0, 0x0004              // Remix 1p Flag
        beq     v0, t6, _remix_1p           // if Remix 1p, use Remix 1p high score table
        addiu	t6, r0, 0x0005              // Allstar Flag
        beq     v0, t6, _allstar            // if Allstar, use Allstar high score table
        slti    t6, a0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t6, _original               // otherwise use original table
        nop                                 // ~

        li      t6, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   v0, a0, -Character.id.BOSS  // v0 = index to character struct in extended table

        _custom:
        sll     v0, v0, 0x0005              // v0 = offset to character struct in extended table
        addu    t6, t6, v0                  // t6 = address of high score character struct
        lw      v0, 0x0008(t6)              // v0 = bonus count
        jr      ra                          // return
        nop

        _original:
        sll     t6, a0, 0x0005              // original line 1
        lui     v0, 0x800A                  // original line 2

        j       _extend_high_score_1p_bonus_count_return
        nop

        _remix_1p:
        li      t6, Character.REMIX_1P_HIGH_SCORE_TABLE
        b       _custom
        addiu   v0, a0, r0                  // v0 = index to character struct in extended table

        _allstar:
        li      t6, Character.ALLSTAR_HIGH_SCORE_TABLE
        b       _custom
        addiu   v0, a0, r0                  // v0 = index to character struct in extended table
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

        li      t5, SinglePlayerModes.singleplayer_mode_flag // v0 = Single Player Mode Flag
        lw     	t5, 0x0000(t5)              // t5 = 4 if Remix 1p
        addiu	t6, r0, 0x0004              // Remix 1p Flag
        beq     t5, t6, _remix_1p
        addiu	t6, r0, 0x0005              // Allstar Flag
        beq     t5, t6, _allstar
        slti    t5, t4, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a2, t4, -Character.id.BOSS  // a2 = index to character struct in extended table
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

        _remix_1p:
        li      t5, Character.REMIX_1P_HIGH_SCORE_TABLE
        addiu   a2, t4, r0                  // a2 = index to character struct in extended table
        sll     a2, a2, 0x0005              // a2 = offset to character struct in extended table
        addu    t5, t5, a2                  // t5 = address of high score character struct
        lbu     a2, 0x000C(t5)              // a2 = difficulty
        b       _return                     // return
        nop

        _allstar:
        li      t5, Character.ALLSTAR_HIGH_SCORE_TABLE
        addiu   a2, t4, r0                  // a2 = index to character struct in extended table
        sll     a2, a2, 0x0005              // a2 = offset to character struct in extended table
        addu    t5, t5, a2                  // t5 = address of high score character struct
        lbu     a2, 0x000C(t5)              // a2 = difficulty
        b       _return                     // return
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

        li      t2, SinglePlayerEnemy.enemy_port
        lw      t2, 0x0000(t2)              // t2 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnezl   t2, _skip
        nop
        li      t2, Practice_1P.practice_active // load practice flag location
        lw      t2, 0x0000(t2)              // t2 = Practice stage number (0 if OFF)
        bnezl   t2, _skip                   // if Practice mode is active, skip
        nop

        li      t2, SinglePlayerModes.singleplayer_mode_flag // v0 = Single Player Mode Flag
        lw     	t2, 0x0000(t2)              // t2 = 4 if Remix 1p
        addiu	t7, r0, 0x0004              // Remix 1p Flag
        beq     t2, t7, _remix_1p
        // t6 is character ID
        slti    t2, t6, Character.id.BOSS   // if (it's not an original character) then use extended table
        li      t2, SinglePlayerModes.singleplayer_mode_flag // v0 = Single Player Mode Flag
        lw     	t2, 0x0000(t2)              // t2 = 4 if Remix 1p
        addiu	t7, r0, 0x0005              // Allstar Flag
        beq     t2, t7, _allstar
        // t6 is character ID
        slti    t2, t6, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t2, _original               // otherwise use original table
        nop                                 // ~

        li      a3, Character.EXTENDED_HIGH_SCORE_TABLE
        addiu   a3, a3, -0x045C             // a3 = adjusted table base for extended table
        addiu   t6, t6, -Character.id.BOSS  // t6 = adjusted offset

        j       _extend_high_score_1p_write_return
        nop

        _original:
        lui     a3, 0x800A                  // original line 1
        addiu   a3, a3, 0x44E0              // original line 2

        j       _extend_high_score_1p_write_return
        nop

        _remix_1p:
        li      t7, SinglePlayerModes.page_flag               // load page flag
        sw      r0, 0x0000(t7)              // save page 1 ID, this is so at the end of a run it resets to the normal page
        li      a3, Character.REMIX_1P_HIGH_SCORE_TABLE
        addiu   a3, a3, -0x045C             // a3 = adjusted table base for extended table

        j       _extend_high_score_1p_write_return
        nop

        _allstar:
        li      t7, SinglePlayerModes.page_flag               // load page flag
        sw      r0, 0x0000(t7)              // save page 1 ID, this is so at the end of a run it resets to the normal page
        li      a3, Character.ALLSTAR_HIGH_SCORE_TABLE
        addiu   a3, a3, -0x045C             // a3 = adjusted table base for extended table

        j       _extend_high_score_1p_write_return
        nop

        _skip:
        j       0x800D45F4
        nop                                 // skips saving records when having a non-cpu player
    }

    // @ Description
    // This fixes an issue with 1p writing code that calculated the difficulty incorrectly
    // TEMP FIX, JOHN DECIDE HOW YOU WANT THIS TO LOOK
    scope extend_high_score_1p_write_difficulty: {
        OS.patch_start(0x51F54, 0x800D6754)
        j       extend_high_score_1p_write_difficulty
        lw      t8, 0x045C(v0)              // original line 1
        _extend_high_score_1p_write_difficulty_return:
        OS.patch_end()

        lui     a3, 0x800A                  //
        addiu   a3, a3, 0x44E0              // return a3 to original location which is relevant for difficulty

        j       _extend_high_score_1p_write_difficulty_return
        lw      v1, 0x0020(a1)              // original line 2
    }

    // @ Description
    // Modifies the tally loop for 1P to include new characters
    scope extend_1p_tally_: {
        // score
        OS.patch_start(0x13CD80, 0x80134B80)
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        OS.patch_end()
        // bonus count
        OS.patch_start(0x13CED4, 0x80134CD4)
        addiu   s2, r0, Character.NUM_CHARACTERS // end at last character
        OS.patch_end()
    }

    // @ Description
    // Modify the code that sets the stage ID for BTT during 1P so we can use new characters
    scope set_btt_stage_id_1p_: {
        OS.patch_start(0x1118E8, 0x8018D1A8)
        j       set_btt_stage_id_1p_
        lw      t8, 0x0000(a2)              // original line 2
        nop
        nop
        nop
        nop
        _set_btt_stage_id_1p_return:
        OS.patch_end()

        beq     t6, at, _skip_timer         // original line 1 (modified from beql)
        nop
        lw      t9, 0x0000(a2)              // original line 3
        sb      a3, 0x0006(t9)              // original line 4

        _skip_timer:
        // v0 is character ID
        li      t7, SinglePlayerModes.singleplayer_mode_flag // t4 = Single Player Mode Flag
        lw     	t7, 0x0000(t7)              // t4 = 1 if multiman
        addiu	t1, r0, 0x0004              // Remix 1p Flag
        beq     t7, t1, _remix_1p


        slti    t7, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t7, _original               // otherwise use original table
        nop                                 // ~

        li      t7, Character.BTT_TABLE     // t7 = address of stage_id table
        addu    t7, t7, v0                  // t7 = address of stage_id, adjusted to 0 base
        lb      t7, 0x0000(t7)              // t7 = stage_id
        j       _set_btt_stage_id_1p_return // return
        nop

        _original:
        addiu   t7, v0, 0x0011              // original line 2
        j       _set_btt_stage_id_1p_return // return
        nop

        _remix_1p:
        li      t7, Character.REMIX_BTT_TABLE     // t7 = address of stage_id table
        addu    t7, t7, v0                  // t7 = address of stage_id, adjusted to 0 base
        lb      t7, 0x0000(t7)              // t7 = stage_id
        j       _set_btt_stage_id_1p_return // return
        nop
    }

    // @ Description
    // Modify the code that sets the stage ID for BTP during 1P so we can use new characters
    scope set_btp_stage_id_1p_: {
        OS.patch_start(0x111910, 0x8018D1D0)
        j       set_btp_stage_id_1p_
        lw      t2, 0x0000(a2)              // original line 2
        nop
        nop
        nop
        nop
        _set_btp_stage_id_1p_return:
        OS.patch_end()

        beq     t3, at, _skip_timer         // original line 1 (modified from beql)
        nop
        lw      t4, 0x0000(a2)              // original line 3
        sb      a3, 0x0006(t4)              // original line 4

        _skip_timer:
        // v0 is character ID
        li      t5, SinglePlayerModes.singleplayer_mode_flag // t4 = Single Player Mode Flag
        lw     	t5, 0x0000(t5)              // t4 = 4 if Remix 1p
        addiu	t1, r0, 0x0004              // Remix 1p Flag
        beq     t5, t1, _remix_1p
        slti    t5, v0, Character.id.BOSS   // if (it's not an original character) then use extended table
        bnez    t5, _original               // otherwise use original table
        nop                                 // ~

        li      t5, Character.BTP_TABLE     // t5 = address of stage_id table
        addu    t5, t5, v0                  // t5 = address of stage_id, adjusted to 0 base
        lb      t5, 0x0000(t5)              // t5 = stage_id
        j       _set_btp_stage_id_1p_return // return
        nop

        _original:
        addiu   t5, v0, 0x001D              // original line 2
        j       _set_btp_stage_id_1p_return // return
        nop

        _remix_1p:
        li      t5, Character.REMIX_BTP_TABLE     // t5 = address of stage_id table
        addu    t5, t5, v0                  // t5 = address of stage_id, adjusted to 0 base
        lb      t5, 0x0000(t5)              // t5 = stage_id
        j       _set_btp_stage_id_1p_return // return
        nop
    }

    // @ Description
    // This piggybacks off the code that writes SSB data to SRAM to write our extended table as well
    scope write_extended_high_score_table_: {
        OS.patch_start(0x00050014, 0x800D4634)
        j       write_extended_high_score_table_
        nop
        _return:
        OS.patch_end()

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.REMIX_1P_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.ALLSTAR_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Bonus.REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        jal     Toggles.save_               // save all toggles and mark save file present
        nop                                 // we save all toggles so that things stay in sync

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        j       _return                     // return
        nop
    }

    // @ Description
    // This piggybacks off the code that loads SSB data from SRAM to load our extended table as well
    scope load_extended_high_score_table_: {
        OS.patch_start(0x000500C4, 0x800D46E4)
        j       load_extended_high_score_table_
        nop
        _return:
        OS.patch_end()

        mtlo    v0                          // save v0

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        li      a0, Character.MULTIMAN_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

		li      a0, Character.CRUEL_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

		li      a0, Character.BONUS3_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        li      a0, Character.REMIX_1P_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        li      a0, Character.ALLSTAR_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        li      a0, Character.HRC_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        li      a0, Bonus.REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.load_
        nop

        // TODO: check if necessary
        _initialize:
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
        slti    a1, a2, Character.NUM_CHARACTERS - 0xC
        bnez    a1, _loop                   // if (more characters to loop over) then loop
        nop

        mflo    v0                          // restore v0

        lw      ra, 0x0014(sp)              // original line 1
        addiu   sp, sp, 0x0018              // original line 2

        j       _return                     // return
        nop
    }

    // @ Description
    // Name texture offsets in file 0x000C* (non-adjusted - don't add 0x10 here for DF000000 00000000)
    // *MM and GDK are from file 0x000B
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
        constant METAL(0x00005318)            // file 0xB
        constant NMARIO(0x00001E68)
        constant NFOX(0x00002048)
        constant NDONKEY(0x00002228)
        constant NSAMUS(0x00002468)
        constant NLUIGI(0x00002888)
        constant NLINK(0x00002A68)
        constant NYOSHI(0x00002CA8)
        constant NCAPTAIN(0x00002EE8)
        constant NKIRBY(0x00003128)
        constant NPIKACHU(0x00003368)
        constant NJIGGLY(0x00003548)
        constant NNESS(0x00003728)
        constant GDONKEY(0x00005738)          // file 0xB

		// remix characters
        constant GND(0x000012C8)
        constant FALCO(0x00001448)
        constant YLINK(0x00001688)
        constant DRM(0x00001868)
        constant WARIO(0x000019E8)
        constant DSAMUS(0x00001C28)
        constant LUCAS(0x00003D88)
        constant BOWSER(0x000055E8)
        constant GBOWSER(0x00005828)
        constant PIANO(0x00005A08)
        constant WOLF(0x00005B28)
        constant CONKER(0x00006068)
        constant MTWO(0x00006408)
        constant MARTH(0x00006578)
        constant SONIC(0x000066E8)
        constant SSONIC(0x00006918)
        constant SHEIK(0x00006A38)
        constant MARINA(0x00006D38)
        constant DEDEDE(0x00009248)

		// remix polygons
        constant NWARIO(0x00006F78)
        constant NLUCAS(0x000071B8)
        constant NBOWSER(0x000073F8)
        constant NWOLF(0x00008358)
        constant NDRM(0x000085E8)
        constant NSONIC(0x00007638)
        constant NSHEIK(0x00007878)
        constant NCONKER(0x00007AB8)
        constant NFALCO(0x00007CF8)
        constant NMARINA(0x00007F38)
        constant NMARTH(0x00008178)
        constant NGND(0x00008888)
        constant NMTWO(0x00008B28)
        constant NYLINK(0x00008DC8)
        constant NDSAMUS(0x000090C8)
        constant UNUSED48W(0x000093B8)
        // TODO: update J names
        constant JSAMUS(0x00004268)
        constant JNESS(0x00004688)
        constant JLINK(0x000049E8)
        constant JFALCON(0x00003A88)
        constant JFOX(0x000040E8)
        constant JMARIO(0x00004568)
        constant JLUIGI(0x000043E8)
        constant JDK(0x00004E68)
        constant JPUFF(0x00004B68)
        constant JPIKA(0x00004868)
        constant JKIRBY(0x00003F08)
        constant JYOSHI(0x00003C08)
        // TODO: update E names
        constant ESAMUS(0x00005048)
        constant ELINK(0x000038A8)
        constant EPIKA(0x00005228)
        constant EPUFF(0x00005468)
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
    dw name_texture.METAL                   // Metal Mario
    dw name_texture.NMARIO                  // Polygon Mario
    dw name_texture.NFOX                    // Polygon Fox
    dw name_texture.NDONKEY                 // Polygon Donkey Kong
    dw name_texture.NSAMUS                  // Polygon Samus
    dw name_texture.NLUIGI                  // Polygon Luigi
    dw name_texture.NLINK                   // Polygon Link
    dw name_texture.NYOSHI                  // Polygon Yoshi
    dw name_texture.NCAPTAIN                // Polygon Captain Falcon
    dw name_texture.NKIRBY                  // Polygon Kirby
    dw name_texture.NPIKACHU                // Polygon Pikachu
    dw name_texture.NJIGGLY                 // Polygon Jigglypuff
    dw name_texture.NNESS                   // Polygon Ness
    dw name_texture.GDONKEY                 // Giant Donkey Kong
    dw name_texture.BLANK                   // (Placeholder)
    dw name_texture.BLANK                   // None (Placeholder)
    // new characters
    fill Character.NUM_CHARACTERS * 0x4

    // @ Description
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x000C)
    scope get_name_texture_: {
        OS.patch_start(0x12BA4C, 0x8013270C)
//      lw      t4, 0x0028(t4)                    // original line 1
        jal     get_name_texture_
        or      a0, s1, r0                        // original line 2
        OS.patch_end()

        // Default is File 0xC, but we can reuse MM and GDK from file 0xB
        lli     a1, Character.id.METAL            // a1 = Character.id.METAL
        beq     t2, a1, _use_file_b               // if Metal Mario, then use file 0xB
        nop
        lli     a1, Character.id.GDONKEY          // a1 = Character.id.GDONKEY
        beq     t2, a1, _use_file_b               // if Giant DK, then use file 0xB
        nop

        _get_offset:
        li      t4, name_texture_table            // t4 = texture offset table
        addu    t4, t4, t3                        // t4 = address of texture offset
        lw      t4, 0x0000(t4)                    // t4 = texture offset
        addiu   t4, t4, 0x0010                    // t4 = adjusted texture offset (+0x10 for DF000000 00000000)

        jr      ra                                // return
        nop

        _use_file_b:
        li      t4, Global.files_loaded           // t4 = pointer to file list
        lw      t4, 0x0000(t4)                    // t4 = file list
        lw      t5, 0x0004(t4)                    // t5 = pointer to file 0xB

        b       _get_offset                       // continue to getting offset
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
        constant METAL(0x00000024 + MARIO)
        constant POLYGON(0x00000028)
        constant NMARIO(POLYGON + MARIO)
        constant NFOX(POLYGON + FOX)
        constant NDONKEY(POLYGON + DONKEY_KONG)
        constant NSAMUS(POLYGON + SAMUS)
        constant NLUIGI(POLYGON + LUIGI)
        constant NLINK(POLYGON + LINK)
        constant NYOSHI(POLYGON + YOSHI)
        constant NCAPTAIN(POLYGON + CAPTAIN_FALCON)
        constant NKIRBY(POLYGON + KIRBY)
        constant NPIKACHU(POLYGON + PIKACHU)
        constant NJIGGLY(POLYGON + JIGGLYPUFF)
        constant NNESS(POLYGON + NESS)
        constant NWARIO(POLYGON + WARIO)
        constant NLUCAS(POLYGON + LUCAS)
        constant NBOWSER(POLYGON + BOWSER)
        constant NWOLF(POLYGON + WOLF)
        constant NDRM(POLYGON + DRM)
        constant NSONIC(POLYGON + SONIC)
        constant NSHEIK(POLYGON + SHEIK)
        constant NMARINA(POLYGON + MARINA)
        constant GDONKEY(0x00000024 + DONKEY_KONG)
        constant GND(0x00000046)
        constant FALCO(0x00000032)
        constant YLINK(0x00000046)
        constant DRM(0x00000048)
        constant WARIO(0x0000003C)
        constant DSAMUS(0x00000046)
        constant LUCAS(0x00000032)
        constant BOWSER(0x0000003C)
        constant GBOWSER(0x00000014 + BOWSER)
        constant PIANO(0x00000046)
        constant WOLF(0x00000028)
        constant CONKER(0x0000002C)
        constant MTWO(0x0000002C)
        constant MARTH(0x00000028)
        constant SONIC(0x0000002C)
        constant SSONIC(0x00000014 + SONIC)
        constant SHEIK(0x00000032)
        constant MARINA(0x00000032)
        constant DEDEDE(0x00000054)
        // TODO: make sure these are good
        constant JSAMUS(0x00000032)
        constant JNESS(0x00000032)
        constant JLINK(0x00000038)
        constant JFALCON(0x00000046)
        constant JFOX(0x00000032)
        constant JMARIO(0x00000032)
        constant JLUIGI(0x00000032)
        constant JDK(0x00000046)
        constant JPUFF(0x00000032)
        constant JPIKA(0x00000032)
        constant JKIRBY(0x00000032)
        constant JYOSHI(0x00000032)
        // TODO: make sure these are good
        constant ESAMUS(0x00000032)
        constant ELINK(0x00000038)
        constant EPIKA(0x00000032)
        constant EPUFF(0x00000032)
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
    dw name_delay.METAL                   // Metal Mario
    dw name_delay.NMARIO                  // Polygon Mario
    dw name_delay.NFOX                    // Polygon Fox
    dw name_delay.NDONKEY                 // Polygon Donkey Kong
    dw name_delay.NSAMUS                  // Polygon Samus
    dw name_delay.NLUIGI                  // Polygon Luigi
    dw name_delay.NLINK                   // Polygon Link
    dw name_delay.NYOSHI                  // Polygon Yoshi
    dw name_delay.NCAPTAIN                // Polygon Captain Falcon
    dw name_delay.NKIRBY                  // Polygon Kirby
    dw name_delay.NPIKACHU                // Polygon Pikachu
    dw name_delay.NJIGGLY                 // Polygon Jigglypuff
    dw name_delay.NNESS                   // Polygon Ness
    dw name_delay.GDONKEY                 // Giant Donkey Kong
    dw name_delay.PLACEHOLDER             // (Placeholder)
    dw name_delay.PLACEHOLDER             // None (Placeholder)
    // new characters
    fill Character.NUM_CHARACTERS * 0x4

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

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p vs preview.
    // TODO: better handle so this can be customized
    scope singleplayer_vs_preview_fix_: {
        OS.patch_start(0x12D67C, 0x8013433C)
        j       singleplayer_vs_preview_fix_
        lw      a0, 0x5CC8(a0)              // original line 1
        _singleplayer_vs_preview_fix_return:
        OS.patch_end()

        sll     a0, a0, 0x0002              // a0 = id * 4
        li      t7, Character.singleplayer_vs_preview.table
        addu    t7, t7, a0                  // t7 = vs_record.table + (id * 4)
        lw      a0, 0x0000(t7)              // a0 = new id

        jal     0x80133F90                  // original line 2
        nop

        j       _singleplayer_vs_preview_fix_return
        nop
    }

    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for the 1p vs preview when there are allies present.
    // TODO: better handle so this can be customized
    scope singleplayer_vs_preview_with_allies_fix_: {
        // with one ally
        OS.patch_start(0x12D620, 0x801342E0)
        jal     singleplayer_vs_preview_with_allies_fix_
        lui     a0, 0x8013                  // original line 1
        jal     0x80133F90                  // original line 3
        addiu   a1, r0, 0x0001              // original line 4
        OS.patch_end()

        // with two allies
        OS.patch_start(0x12D580, 0x80134240)
        jal     singleplayer_vs_preview_with_allies_fix_
        lui     a0, 0x8013                  // original line 1
        jal     0x80133F90                  // original line 3
        addiu   a1, r0, 0x0003              // original line 4
        OS.patch_end()

        lw      a0, 0x5CC8(a0)              // original line 2

        sll     a0, a0, 0x0002              // a0 = id * 4
        li      t7, Character.singleplayer_vs_preview.table
        addu    t7, t7, a0                  // t7 = vs_record.table + (id * 4)
        lw      a0, 0x0000(t7)              // a0 = new id

        jr      ra
        nop
    }

// I Think this can most likely be dispatched with as my fix to the zoom table patch eliminates its purpose
//  // @ Description
//  // Patch which substitutes working character/opponent ids (0-11) for the 1p gameover screen.
//  // TODO: better handle so this can be customized
//  scope singleplayer_gameover_fix_: {
//      OS.patch_start(0x178BE8, 0x80132188)
//      jal     singleplayer_gameover_fix_
//      lui     a1, 0x8013                  // original line 1
//      OS.patch_end()
//
//      lw      a1, 0x4348(a1)              // original line 2
//      sll     a1, a1, 0x0002              // a1 = id * 4
//      li      a0, Character.singleplayer_vs_preview.table
//      addu    a0, a0, a1                  // a0 = vs_record.table + (id * 4)
//      lw      a1, 0x0000(a0)              // a1 = new id
//
//      jr      ra
//      nop
//  }

    // @ Description
    // Patch which changes GDK's costume if human player is GDK
    // or polygon team's costume if human player is a purple polygon
    // on the VS preview screen
    scope singleplayer_gdk_polygon_team_costume_preview_fix_: {
        OS.patch_start(0x12C738, 0x801333F8)
        j       singleplayer_gdk_polygon_team_costume_preview_fix_
        sw      a0, 0x0070(sp)                 // original line 1
        _return:
        OS.patch_end()

        // check human costume_id to see if it's 0
        li      t7, 0x80135CCC                 // t7 = address of human costume_id
        lw      t7, 0x0000(t7)                 // t7 = human costume_id
        bnez    t7, _original                  // if costume_id != 0, then skip
        nop



        // check human character_id to see if it's GDK or a polygon
        li      t7, 0x80135CC8                 // t7 = address of human character_id
        lw      t7, 0x0000(t7)                 // t7 = human character_id
        sltiu   t6, t7, Character.id.NWARIO    // t6 = 1 if not a remix polygon character
        beqz    t6, _polygons                  // if a remix polygon character, check CPU to see if it's a polygon
        sltiu   t6, t7, Character.id.NMARIO    // t6 = 1 if not a polygon character
        bnez    t6, _original                  // skip if not GDK or a polygon character
        sltiu   t6, t7, Character.id.NNESS+1   // t6 = 1 if a polygon character
        bnez    t6, _polygons                  // if an original polygon character, check CPU to see if it's a polygon
        lli     t6, Character.id.GDONKEY       // t6 = Character.id.GDONKEY
        bne     t6, t7, _original              // if not GDK, skip
        nop

        // a0 = CPU character_id
        // a0 is Character.id.DK for GDK
        lli     t6, Character.id.DK            // t6 = Character.id.DK
        beql    t6, a0, _original              // if GDK, adjust costume - otherwise skip
        addiu   a1, r0, 0x0001                 // a1 = costume index 1 instead of 0

        b       _original
        nop

        _polygons:
        sltiu   t6, a0, Character.id.NMARIO    // t6 = 1 if not GDK or a polygon character
        bnez    t6, _original                  // skip if not GDK or a polygon character
        sltiu   t6, a0, Character.id.NNESS+1   // t6 = 1 if GDK or a polygon character
        beqz    t6, _original                  // skip if not GDK or a polygon character
        nop

        addiu   a1, r0, 0x0001                 // a1 = costume index 1 instead of 0

        _original:
        li      at, SinglePlayerModes.singleplayer_mode_flag      // at = singleplayer flag address
        lw      at, 0x0000(at)                  // at = 4 if remix
        addiu   t1, r0, 0x0004                  //
        bne     at, t1, _normal                 // if not Remix 1p, skip
        nop

        li      at, 0x800A4AE7                  // load stage ID ram address
        lbu     at, 0x0000(at)                  // load stage id
        addiu   t1, r0, 0x0006                  // Giant Stage ID
        bne     at, t1, _normal
        nop

        li      t1, 0x80135CCC                  // t1 = address of human costume_id
        lw      t1, 0x0000(t1)                  // t1 = human costume_id
        bnez    t1, _normal                     // if costume_id != 0, then skip
        nop

        li      t1, 0x80135CC8                  // t1 = address of human character_id
        lw      t1, 0x0000(t1)                  // t1 = human character_id
        bne     a0, t1, _normal                 // if Giant character and human are not the same, normal load
        nop

        addiu   a1, r0, 0x0001                  // set costume to alternate 1 for Giant CPU

        _normal:
        jal     0x800EC0EC
        nop
        j       _return
        nop
    }

    // @ Description
    // Patch which changes the polygon team's costume if human player is a purple polygon
    // in the match
    scope singleplayer_polygon_team_costume_fix_: {
        OS.patch_start(0x10BDF4, 0x8018D594)
        j       singleplayer_polygon_team_costume_fix_
        lw      t6, 0x0000(t1)                 // original line 2
        _singleplayer_polygon_team_costume_fix_return:
        OS.patch_end()

        // check human costume_id to see if it's 0
        li      t9, Global.match_info          // t9 = address of match info
        lw      t9, 0x0000(t9)                 // t9 = match info start
        addiu   t9, t9, Global.vs.P_OFFSET     // t9 = 1p player struct
        _loop:
        lbu     t7, 0x0006(t9)                 // t7 = costume_id of human
        lbu     t5, 0x0002(t9)                 // t5 = type (0 = man, 1 = cpu, 2 = none)
        bnezl   t5, _loop                      // if not human, go to next port
        addiu   t9, t9, Global.vs.P_DIFF       // t9 = next player struct

        bnezl   t7, _return                    // if costume_id != 0, then use purple costume
        sb      r0, 0x0026(t8)                 // original line 1

        // check if human is a polygon
        lbu     t7, 0x0003(t9)                 // t7 = character_id of human

        sltiu   t5, t7, Character.id.NWARIO    // t5 = 1 if not a remix polygon character
        beqz    t5, _polygon                   // if a Remix Polygon Character, do color checks
        sltiu   t5, t7, Character.id.NMARIO    // t5 = 1 if not a polygon character
        bnezl   t5, _return                    // if not a polygon character, then use original costume
        sb      r0, 0x0026(t8)                 // original line 1
        sltiu   t5, t7, Character.id.NNESS+1   // t5 = 1 if a polygon character
        beqzl   t5, _return                    // if not a polygon character, then use original costume
        sb      r0, 0x0026(t8)                 // original line 1

        // check if on polygon team or RTTF stage
        _polygon:
        li      t9, Global.match_info          // t9 = address of match info
        lw      t9, 0x0000(t9)                 // t9 = match info start
        lbu     t7, 0x0001(t9)                 // t7 = stage_id
        sltiu   t5, t7, Stages.id.DUEL_ZONE    // t5 = 1 if not a polygon stage
        bnezl   t5, _return                    // if not a polygon stage, then use original costume
        sb      r0, 0x0026(t8)                 // original line 1
        addiu   t5, r0, Stages.id.BATTLEFIELD  // t5 = BATTLEFIELD Stage ID
        beq     t5, t7, _polygon_stage         // if Battlefield, use costume fix
        nop
        sltiu   t5, t7, Stages.id.RACE_TO_THE_FINISH + 1   // t5 = 1 if a polygon character
        beqzl   t5, _return                    // if not a polygon stage, then use original costume
        sb      r0, 0x0026(t8)                 // original line 1

        // human is polygon, on a polygon stage, so use alt costume
        _polygon_stage:
        addiu   t7, r0, 0x0001                 // t7 = costume index 1 instead of 0
        sb      t7, 0x0026(t8)                 // store costume_id

        _return:
        j       _singleplayer_polygon_team_costume_fix_return
        nop
    }

    // @ Description
    // constants for defining the victory picture
    constant VICTORY_FILE_1(File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM)
    constant VICTORY_OFFSET_1(0x00020718)
    constant VICTORY_FILE_2(File.SINGLEPLAYER_VICTORY_IMAGE_TOP)
    constant VICTORY_OFFSET_2(0x00020718)
    constant SPLASH_FILE_1(File.SPLASH_IMAGE_BOTTOM)
    constant SPLASH_FILE_2(File.SPLASH_IMAGE_TOP)

    // @ Description
    // constants for a custom victory picture per custom character.
    // Assume next file will always be the top part of the image
    custom_victory_file_table:
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // BOSS
    dh 0xBA                                                 // METAL (same as Mario)
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NMARIO
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NFOX
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NDONKEY
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NSAMUS
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NLUIGI
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NLINK
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NYOSHI
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NCAPTAIN
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NKIRBY
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NPIKACHU
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NJIGGLY
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NNESS
    dh 0xB8                                                 // GDONKEY (same as DK)
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // PLACEHOLDER
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // PLACEHOLDER
    dh File.FALCO_VICTORY_IMAGE_BOTTOM                      // FALCO
    dh File.GANON_VICTORY_IMAGE_BOTTOM                      // GND
    dh File.YLINK_VICTORY_IMAGE_BOTTOM                      // YLINK
    dh File.DRM_VICTORY_IMAGE_BOTTOM                        // DRM
    dh File.WARIO_VICTORY_IMAGE_BOTTOM                      // WARIO
    dh File.DSAMUS_VICTORY_IMAGE_BOTTOM                     // DARK SAMUS
    dh 0xB2                                                 // ELINK
    dh 0xB0                                                 // JSAMUS
    dh 0xC0                                                 // JNESS
    dh File.LUCAS_VICTORY_IMAGE_BOTTOM                      // LUCAS
    dh 0xB2                                                 // JLINK
    dh 0xB6                                                 // JFALCON
    dh 0xBE                                                 // JFOX
    dh 0xBA                                                 // JMARIO
    dh 0xBC                                                 // JLUIGI
    dh 0xB8                                                 // JDK
    dh 0xAE                                                 // EPIKA
    dh 0xB4                                                 // JPUFF
    dh 0xB4                                                 // EPUFF
    dh 0xAA                                                 // JKIRBY
    dh 0xAC                                                 // JYOSHI
    dh 0xAE                                                 // JPIKA
    dh 0xB0                                                 // ESAMUS
    dh File.BOWSER_VICTORY_IMAGE_BOTTOM                     // BOWSER
    dh File.BOWSER_VICTORY_IMAGE_BOTTOM                     // GBOWSER (using Bowser)
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // PIANO
    dh File.WOLF_VICTORY_IMAGE_BOTTOM                       // WOLF
    dh File.CONKER_VICTORY_IMAGE_BOTTOM                     // CONKER
    dh File.MTWO_VICTORY_IMAGE_BOTTOM                       // MEWTWO
    dh File.MARTH_VICTORY_IMAGE_BOTTOM                      // MARTH
    dh File.SONIC_VICTORY_IMAGE_BOTTOM                      // SONIC
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // SANDBAG
    dh File.SONIC_VICTORY_IMAGE_BOTTOM                      // SUPER SONIC (using Sonic)
    dh File.SHEIK_VICTORY_IMAGE_BOTTOM                      // SHEIK
    dh File.MARINA_VICTORY_IMAGE_BOTTOM                     // MARINA
    dh File.DEDEDE_VICTORY_IMAGE_BOTTOM                     // DEDEDE
    // ADD NEW CHARACTERS HERE

    // ADD FOR REMIX POLYGONS HERE
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NWARIO
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NLUCAS
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NBOWSER
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NWOLF
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NDRM
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NSONIC
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NSHEIK
    dh File.SINGLEPLAYER_VICTORY_IMAGE_BOTTOM               // NMARINA


    OS.align(4)

    // @ Description
    // Patch which substitutes the victory picture with a custom one for all non-original characters.
    // There are a number of hardcodings addressed.
    scope replace_victory_image_: {
        OS.patch_start(0x17E824, 0x80131E14)
        jal     replace_victory_image_
        nop
        jal     0x800CDBD0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E850, 0x80131E40)
        jal     replace_victory_image_
        addu    t0, t2, r0                  // move t2 to t0 (character id)
        jal     0x800CDC88                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E870, 0x80131E60)
        jal     replace_victory_image_._2
        nop
        jal     0x800CCFDC                  // original line
        addu    a1, t6, v0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E8B4, 0x80131EA4)
        jal     replace_victory_image_._3
        nop
        jal     0x800CDBD0                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E8E0, 0x80131ED0)
        jal     replace_victory_image_._3
        addu    t9, t1, r0                  // move t1 to t9 (character id)
        jal     0x800CDC88                  // original line
        nop
        OS.patch_end()

        OS.patch_start(0x17E900, 0x80131EF0)
        jal     replace_victory_image_._4
        nop
        jal     0x800CCFDC                  // original line
        addu    a1, t5, v0                  // original line
        nop
        OS.patch_end()

        sltiu   a0, t0, 0x000C
        beqz    a0, _custom                 // if this is a new character,
        nop                                 // then we will load a custom image

        _original:
        lui     a0, 0x8013                  // original line
        sll     t1, t0, 0x0004              // original line
        addu    a0, a0, t1                  // original line
        lw      a0, 0x2100(a0)              // original line
        jr      ra
        nop

        _custom:
        lli     a0, Character.id.NONE       // a0 = Character.id.NONE
        beq     t0, a0, _splash_1           // if character id is NONE, then we're on the splash screen
        nop

        addiu   a0, t0, -Character.id.BOSS // a0 = character id - Boss id
        sll     a0, a0, 1                   // a0 = offset to characters entry in victory file table
        li      at, custom_victory_file_table
        addu    a0, at, a0                  // a0 = pointer to file 1
        jr      ra
        lh      a0, 0x0000(a0)              // a0 = pointer to bottom image

        _splash_1:
        lli     a0, SPLASH_FILE_1           // use custom file

        jr      ra
        nop

        _2:
        sltiu   t5, t4, 0x000C
        beqz    t5, _custom_2               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     t6, 0x8013                  // original line
        sll     t5, t4, 0x0004              // original line
        addu    t6, t6, t5                  // original line
        lw      t6, 0x2104(t6)              // original line
        jr      ra
        nop

        _custom_2:
        li      t6, VICTORY_OFFSET_1        // use custom offset

        jr      ra
        nop

        _3:
        sltiu   a0, t9, 0x000C
        beqz    a0, _custom_3               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     a0, 0x8013                  // original line
        sll     t0, t9, 0x0004              // original line
        addu    a0, a0, t0                  // original line
        lw      a0, 0x2108(a0)              // original line
        jr      ra
        nop

        _custom_3:
        lli     a0, Character.id.NONE       // a0 = Character.id.NONE
        beq     t9, a0, _splash_2           // if character id is NONE, then we're on the splash screen
        nop
        addiu   a0, t9, -Character.id.BOSS // a0 = character id - Boss id
        sll     a0, a0, 1                   // a0 = offset to characters entry in victory file table
        li      at, custom_victory_file_table
        addu    a0, at, a0                  // a0 = pointer to file 1
        lh      a0, 0x0000(a0)              // use custom tile
        jr      ra
        addiu   a0, a0, 0x0001              // argument = next image after characters image

        jr      ra
        nop

        _splash_2:
        lli     a0, SPLASH_FILE_2          // use custom file

        jr      ra
        nop

        _4:
        sltiu   t5, t3, 0x000C
        beqz    t5, _custom_4               // if this is a new character,
        nop                                 // then we will load a custom image

        lui     t5, 0x8013                  // original line
        sll     t4, t3, 0x0004              // original line
        addu    t5, t5, t4                  // original line
        lw      t5, 0x210C(t5)              // original line
        jr      ra
        nop

        _custom_4:
        li      t5, VICTORY_OFFSET_2        // use custom offset

        jr      ra
        nop
    }

    custom_lighting_1:
    dw 0x00000000 // RGB
    dw 0x44000000 // RGB
    dw 0x40000200 // Direction ([Signed] X, Y, Z)
    dw 0x00000000 // Pad
    custom_lighting_2:
    dw 0x00800000 // RGB
    dw 0x00800000 // RGB
    dw 0x01750000 // Direction ([Signed] X, Y, Z)
    dw 0x00000000 // Pad

    // @ Description
    // This is a hacky way of fixing the lack of env mapping for MM and polygons
    // on various screens by adding extra lighting commands. It is called too often,
    // so it may be worth trying to only call for certain characters, but it seems to be harmless as is.
    scope env_mapping_fix_: {
        OS.patch_start(0x17558, 0x80016958)
        j       env_mapping_fix_
        nop
        _return:
        OS.patch_end()

        // Only need to fix env mapping on some screens
        li      at, Global.current_screen   // ~
        lbu     at, 0x0000(at)              // at = screen id

        // vs preview screen = 0xE AND first file loaded = 0xB
        lli     t9, 0x000E                  // t9 = vs preview screen id
        bne     t9, at, _check_if_css       // if (screen id != 0xE), continue checking
        nop                                 // otherwise, check first file loaded:
        li      t9, Global.files_loaded     // ~
        lw      t9, 0x0000(t9)              // t9 = address of loaded files list
        lw      t9, 0x0000(t9)              // t9 = first loaded file
        lli     at, 0x000B                  // at = 0xB
        beq     t9, at, _add_lighting       // if (first file loaded = 0xB VS Image),
        nop                                 // then add custom lighting
        b       _original                   // otherwise we're not on a screen that needs updating
        nop

        _check_if_css:
        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t9, at, 0x0010              // if (screen id < 0x10)...
        bnez    t9, _check_gameover         // ...then skip (not on a CSS)
        nop
        slti    t9, at, 0x0015              // if (screen id is between 0x10 and 0x14)...
        bnez    t9, _add_lighting           // ...then we're on a CSS, so add custom lighting
        nop

        // results screen id: 0x18
        lli     t9, 0x0018                  // t9 = results screen id
        beq     t9, at, _add_lighting       // add custom lighting
        nop

        // 1p leave in room screen id: 0x30
        lli     t9, 0x0030                  // t9 = 1p leave in room screen id
        beq     t9, at, _add_lighting       // add custom lighting
        nop

        _check_gameover:
        // gameover screen = 0x1 AND first file loaded = 0x4F
        lli     t9, 0x0001                  // t9 = gameover screen id
        bne     t9, at, _original           // if not on 0x1, then skip adding lighting
        nop
        li      t9, Global.files_loaded     // ~
        lw      t9, 0x0000(t9)              // t9 = address of loaded files list
        lw      t9, 0x0000(t9)              // t9 = first loaded file
        lli     at, 0x004F                  // at = 0x4F
        beq     t9, at, _add_lighting       // if (first file loaded = 0x4F Continue Image),
        nop                                 // then add custom lighting

        _original:
        sw      t6, 0x0000(v0)              // original line 1
        sw      r0, 0x0004(v0)              // original line 2

        j       _return                     // return
        nop

        _add_lighting:
        li      t9, 0xDC08000A              // t9 = command MoveMem to G_MV_LIGHT
        sw      t9, 0x0000(v0)              // append display list
        li      t9, custom_lighting_1       // t9 = pointer to custom lighting (diffuse?)
        sw      t9, 0x0004(v0)              // append display list
        li      t9, 0xDC08030A              // t9 = command MoveMem to G_MV_LIGHT
        sw      t9, 0x0008(v0)              // append display list
        li      t9, custom_lighting_2       // t9 = pointer to custom lighting (ambient?)
        sw      t9, 0x000C(v0)              // append display list

        addiu   v1, v1, 0x0010              // make space for extra commands
        addiu   v0, v0, 0x0010              // make space for extra commands

        b       _original                   // return to original instructions
        nop
    }

    // @ Description
    // Stores the port index in the player structs on the VS title card screen,
    // game over screen and the doll drop room screen.
    // This is useful in Visibility.asm, at least.
    scope fix_port_index_: {
        // human and allies title card
        OS.patch_start(0x12C08C, 0x80132D4C)
        jal     fix_port_index_
        sb      r0, 0x004D(sp)              // original line 2
        OS.patch_end()
        // opponent(s) title card
        OS.patch_start(0x12C764, 0x80133424)
        jal     fix_port_index_._opponent
        sb      t3, 0x0044(sp)              // original line 1
        OS.patch_end()
        // gameover screen
        OS.patch_start(0x178BBC, 0x8013215C)
        jal     fix_port_index_._gameover_and_room_drop
        sw      t3, 0x0054(sp)              // original line 1
        OS.patch_end()
        // room doll drop screen
        OS.patch_start(0x177944, 0x80131FA4)
        jal     fix_port_index_._gameover_and_room_drop
        swc1    f4, 0x0020(sp)              // original line 1
        OS.patch_end()

        // a3 appears to be position
        // - 0 is default
        // - 1 is human position with 1 ally
        // - 3 is human posiiton with 2 allies
        // - 2, 4 and 5 are ally positions

        lui     t7, 0x800A                  // t7 = port index of human player
        lbu     t7, 0x4AE3(t7)              // ~
        beqz    a3, _set_human_or_ally_port
        lli     t6, 0x0001                  // t6 = 1 (position of human player w/1 ally)
        beq     a3, t6, _set_human_or_ally_port // if loading human player, use human port
        lli     t6, 0x0003                  // t6 = 3 (position of human player w/2 allies)
        beq     a3, t6, _set_human_or_ally_port // if loading human player, use human port
        nop                                 // otherwise, we have to use a different port
        beqzl   t7, _set_human_or_ally_port // if human is p1, then set port as p2
        lli     t7, 0x0001                  // t7 = 1 (p2)
        lli     t7, 0x0000                  // otherwise, set as p1

        _set_human_or_ally_port:
        sb      t7, 0x004D(sp)              // set port index

        jr      ra
        lw      t7, 0x0000(t9)              // original line 1

        _opponent:
        lui     t7, 0x800A                  // t7 = port index of human player
        lbu     t7, 0x4AE3(t7)              // ~
        beqzl   t7, _set_opponent_port      // if human is p1, then set port as p2
        lli     t7, 0x0001                  // t7 = 1 (p2)
        lli     t7, 0x0000                  // otherwise, set as p1

        _set_opponent_port:
        sb      t7, 0x003D(sp)              // set port index

        jr      ra
        sb      t4, 0x0045(sp)              // original line 2

        _gameover_and_room_drop:
        lui     t7, 0x800A                  // t7 = port index of human player
        lbu     t7, 0x4AE3(t7)              // ~
        sb      t7, 0x0031(sp)              // set port index

        jr      ra
        swc1    f6, 0x0024(sp)              // original line 2
    }

    // @ Description
    // Adds a character to single player mode
    // @ Arguments
    // character - character id
    // name_texture - name texture to use
    // name_delay - name delay to use
    macro add_to_single_player(character, name_texture, name_delay) {
        pushvar origin, base
        // add to name texture table
        origin name_texture_table_origin + ({character} * 4)
        dw  {name_texture}
        // add to name texture table
        origin name_delay_table_origin + ({character} * 4)
        dw  {name_delay}
        pullvar base, origin
    }

    // CUSTOM CHARS      character id          name texture          name delay
    add_to_single_player(Character.id.FALCO,   name_texture.FALCO,   name_delay.FALCO)
    add_to_single_player(Character.id.GND,     name_texture.GND,     name_delay.GND)
    add_to_single_player(Character.id.YLINK,   name_texture.YLINK,   name_delay.YLINK)
    add_to_single_player(Character.id.DRM,     name_texture.DRM,     name_delay.DRM)
    add_to_single_player(Character.id.WARIO,   name_texture.WARIO,   name_delay.WARIO)
    add_to_single_player(Character.id.DSAMUS,  name_texture.DSAMUS,  name_delay.DSAMUS)
    add_to_single_player(Character.id.LUCAS,   name_texture.LUCAS,   name_delay.LUCAS)
    add_to_single_player(Character.id.BOWSER,  name_texture.BOWSER,  name_delay.BOWSER)
    add_to_single_player(Character.id.GBOWSER, name_texture.GBOWSER, name_delay.GBOWSER)
    add_to_single_player(Character.id.PIANO,   name_texture.PIANO,   name_delay.PIANO)
    add_to_single_player(Character.id.WOLF,    name_texture.WOLF,    name_delay.WOLF)
    add_to_single_player(Character.id.CONKER,  name_texture.CONKER,  name_delay.CONKER)
    add_to_single_player(Character.id.MTWO,    name_texture.MTWO,    name_delay.MTWO)
    add_to_single_player(Character.id.MARTH,   name_texture.MARTH,   name_delay.MARTH)
    add_to_single_player(Character.id.SONIC,   name_texture.SONIC,   name_delay.SONIC)
    add_to_single_player(Character.id.SSONIC,  name_texture.SSONIC,  name_delay.SSONIC)
    add_to_single_player(Character.id.SHEIK,   name_texture.SHEIK,   name_delay.SHEIK)
    add_to_single_player(Character.id.MARINA,  name_texture.MARINA,  name_delay.MARINA)
    add_to_single_player(Character.id.DEDEDE,  name_texture.DEDEDE,  name_delay.DEDEDE)

	// REMIX POLYGONS    character id          name texture          name delay
    add_to_single_player(Character.id.NWARIO,  name_texture.NWARIO,  name_delay.NWARIO)
    add_to_single_player(Character.id.NLUCAS,  name_texture.NLUCAS,  name_delay.NLUCAS)
    add_to_single_player(Character.id.NBOWSER, name_texture.NBOWSER, name_delay.NBOWSER)
    add_to_single_player(Character.id.NWOLF,   name_texture.NWOLF,   name_delay.NWOLF)
    add_to_single_player(Character.id.NDRM,    name_texture.NDRM,    name_delay.NDRM)
    add_to_single_player(Character.id.NSONIC,  name_texture.NSONIC,  name_delay.NSONIC)
    add_to_single_player(Character.id.NSHEIK,  name_texture.NSHEIK,  name_delay.NSHEIK)
    add_to_single_player(Character.id.NMARINA, name_texture.NMARINA, name_delay.NMARINA)

    // J CHARS           character id          name texture          name delay
    add_to_single_player(Character.id.JSAMUS,  name_texture.JSAMUS,  name_delay.JSAMUS)
    add_to_single_player(Character.id.JNESS,   name_texture.JNESS,   name_delay.JNESS)
    add_to_single_player(Character.id.JLINK,   name_texture.JLINK,   name_delay.JLINK)
    add_to_single_player(Character.id.JFALCON, name_texture.JFALCON, name_delay.JFALCON)
    add_to_single_player(Character.id.JFOX,    name_texture.JFOX,    name_delay.JFOX)
    add_to_single_player(Character.id.JMARIO,  name_texture.JMARIO,  name_delay.JMARIO)
    add_to_single_player(Character.id.JLUIGI,  name_texture.JLUIGI,  name_delay.JLUIGI)
    add_to_single_player(Character.id.JDK,     name_texture.JDK,     name_delay.JDK)
    add_to_single_player(Character.id.JPUFF,   name_texture.JPUFF,   name_delay.JPUFF)
    add_to_single_player(Character.id.JPIKA,   name_texture.JPIKA,   name_delay.JPIKA)
    add_to_single_player(Character.id.JKIRBY,  name_texture.JKIRBY,  name_delay.JKIRBY)
    add_to_single_player(Character.id.JYOSHI,  name_texture.JYOSHI,  name_delay.JYOSHI)

    // E CHARS           character id          name texture          name delay
    add_to_single_player(Character.id.ESAMUS,  name_texture.ESAMUS,  name_delay.ESAMUS)
    add_to_single_player(Character.id.ELINK,   name_texture.ELINK,   name_delay.ELINK)
    add_to_single_player(Character.id.EPIKA,   name_texture.EPIKA,   name_delay.EPIKA)
    add_to_single_player(Character.id.EPUFF,   name_texture.EPUFF,   name_delay.EPUFF)
} // __SINGLE_PLAYER__
