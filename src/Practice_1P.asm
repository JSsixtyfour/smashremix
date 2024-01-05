// Practice_1P.asm
if !{defined __PRACTICE_1P__} {
define __PRACTICE_1P__()
print "included Practice_1P.asm\n"

// @ Description
// This file is used for storing 1P Practice Stages.

include "OS.asm"
include "Global.asm"

scope Practice_1P {
    // @ Description
    // Flag to indicate if Practice mode is active
    practice_active:
    dw OS.FALSE

    // @ Description
    // Practice mode for 1P and Remix 1P. Takes you straight to the stage specified, with a timer and retry.
    scope _1p_practice: {
        OS.patch_start(0x52128, 0x800D6928)
        jal     _1p_practice._check_mode
        nop
        OS.patch_end()

        _check_mode:
        li      t6, SinglePlayerModes.singleplayer_mode_flag    // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 1P mode (0 = standard, 4 = Remix)
        addiu   at, r0, SinglePlayerModes.REMIX_1P_ID
        beq     t6, at, pc() + 16           // proceed checking if Remix 1P
        nop
        bnez    t6, _return                 // if not 1P or Remix 1P, skip checking
        addiu   at, r0, 0x0000              // at = 0 (inactive)

        li      t6, SinglePlayerModes.reset_flag // load reset flag location
        lw      at, 0x0000(t6)              // at = 1 if we are resetting the match
        bnez    at, _reset                  // branch accordingly
        nop

        li      t6, stage_table
        lbu     at, 0x0013(s2)              // at = port
        sll     at, at, 0x0002              // at = port * 4 = offset to stage value
        addu    t6, t6, at                  // t6 = address of stage value
        lw      t6, 0x0000(t6)              // t6 = stage value

        beqz    t6, _return                 // if Practice mode is disabled, skip
        addiu   at, r0, 0x0000              // at = 0 (inactive)

        sltiu   at, t6, 0x0004              // set to zero if less than 4
        bnezl   at, set_practice_stage      // branch accordingly
        addiu   t6, t6, -0x0001             // subtract 1 from stage (Stage 1-3)
        sltiu   at, t6, 0x0007              // set to zero if less than 7
        bnez    at, set_practice_stage      // branch accordingly. no adjustment needed (Stage 4-6)
        sltiu   at, t6, 0x000A              // set to zero if less than 10
        bnezl   at, set_practice_stage      // branch accordingly
        addiu   t6, t6, 0x0001              // add 1 to stage (Stage 7-9)
        addiu   t6, t6, 0x0002              // add 2 to stage (Stage 10+)
        b       set_practice_stage
        nop

        _reset:
        li      t6, SinglePlayerModes.STAGE_FLAG // load current stage ID address
        lb      t6, 0x0000(t6)              // load stage ID

        // this fixes a bug that occurs if you retry after Master Hand is defeated but before the screen transitions
        // where all the sfx no longer play
        lli     a1, FGM.ORIGINAL_FGM_COUNT + FGM.new_fgm_count // a1 = total fgm count
        lui     at, 0x800A
        sh      a1, 0xEDF8(at)              // ensure FGM count has the correct value

        set_practice_stage:
        sb      t6, 0x0017(s2)              // save stage ID
        addiu   at, r0, 0x0001              // at = 1 (active)

        _return:
        li      t6, practice_active         // load practice flag location
        sw      at, 0x0000(t6)              // update active state
        addiu   t6, r0, 0x0000              // clear out register in abundance of caution

        lbu     a1, 0x0017(s2)              // original line 1
        slti    at, a1, 0x000E              // original line 2
        jr      ra
        nop
    }

    // @ Description
    // Runs while GAME SET is displayed in 1P mode and allows retrying during Practice
    // Also allows retrying in Bonus 1/2 and various Remix modes (with 'L: Retry')
    scope hold_l_to_retry_: {
        OS.patch_start(0x8FF24, 0x80114724)
        j       hold_l_to_retry_
        lui     v1, 0x8013                  // original line 1
        _return:
        OS.patch_end()

        li      t6, SinglePlayerModes.singleplayer_mode_flag // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 1P mode (0 = standard, 4 = Remix)
        li      t0, Global.current_screen
        lbu     t0, 0x0000(t0)              // t0 = screen id = 1 if 1p, 0x35 if Bonus, 0x77 if Remix Mode
        lli     t1, Global.screen.BONUS     // t1 = 0x35 (BONUS)
        beq     t0, t1, _check_bonus_not_1p  // if Bonus, check if not 1P
        lli     t1, Global.screen.REMIX_MODES // t1 = 0x77 (Remix Modes (other than Remix 1P) All-star, Multiman, HRC
        beq     t0, t1, _check_remix_not_allstar  // if Remix mode, first make sure it isn't All-star
        lli     t1, 0x0001                  // t1 = 1 = 1p screen id
        bne     t0, t1, _normal             // if not 1p, skip
        nop
        b       _check_1p_mode              // if we're here, it's a 1p mode
        nop

        _check_bonus_not_1p:
        // verify that the Bonus is not a non-Practice 1P
        li      t0, Global.previous_screen
        lbu     t0, 0x0000(t0)                    // t0 = previous screen id
        lli     t1, Global.screen.BONUS_1_CSS     // t1 = 0x13 (BONUS 1 CSS)
        beq     t0, t1, _check_for_l_press        // branch if BTT Practice
        lli     t1, Global.screen.BONUS_2_CSS     // t1 = 0x14 (BONUS 2 CSS)
        beq     t0, t1, _check_for_l_press        // branch if BTP Practice
        nop
        b       _check_practice                   // otherwise, check if 1P Practice mode is enabled
        nop


        _check_remix_not_allstar:
        lli     at, SinglePlayerModes.ALLSTAR_ID
        beq     t6, at, _normal             // skip if All-star
        nop
        b       _check_for_l_press          // otherwise, check for L press
        nop

        _check_1p_mode:
        beqz    t6, _check_practice         // if normal 1P, proceed
        lli     at, SinglePlayerModes.REMIX_1P_ID
        bne     t6, at, _normal             // skip if not Remix 1P
        nop

        _check_practice:
        lui     v0, 0x800A
        lbu     v0, 0x4AE3(v0)              // v0 = port
        li      t6, stage_table
        sll     at, v0, 0x0002              // at = port * 4 = offset to stage value
        addu    t6, t6, at                  // t6 = address of stage value
        lw      t6, 0x0000(t6)              // t6 = stage value
        beqz    t6, _normal                 // if Practice mode is disabled, skip
        nop

        _check_for_l_press:
        // check for L press while GAME SET is displayed
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        lli     a0, Joypad.L                // a0 - button mask
        lli     a1, OS.FALSE                // a1 - all must be pressed
        jal     Joypad.check_buttons_all_   // v0 = bool
        lli     a2, Joypad.HELD             // a2 - type

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space

        beqz    v0, _normal                 // if not held, skip
        nop

        li      t0, Global.current_screen
        lli     t1, 0x0002                  // t1 = 2 (Practice reset)
        sb      t1, 0x0012(t0)              // set flag to exit 1p to 2 for practice reset
        lli     t1, 0x0001                  // t1 = 1
        li      t0, SinglePlayerModes.reset_flag // load reset flag location
        sw      t1, 0x0000(t0)              // set reset flag
        li      t0, Global.screen_interrupt
        j       0x801147B4                  // exit GAME SET count down routine
        sw      t1, 0x0000(t0)              // force screen interrupt

        _normal:
        j       _return
        addiu   v1, v1, 0x17E6              // original line 2
    }

    // @ Description
    // Runs while STAGE CLEAR is displayed in 1P mode and allows retrying during Practice
    scope hold_l_to_retry_stage_clear_: {
        OS.patch_start(0x17DCE0, 0x80134A90)
        jal     hold_l_to_retry_stage_clear_
        nop
        OS.patch_end()

        li      t6, SinglePlayerModes.singleplayer_mode_flag // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 1P mode (0 = standard, 4 = Remix)
        beqz    t6, _check_practice         // if normal 1P, proceed
        lli     at, SinglePlayerModes.REMIX_1P_ID
        bne     t6, at, _normal             // skip if not Remix 1P
        nop

        _check_practice:
        lui     v0, 0x800A
        lbu     v0, 0x4AE3(v0)              // v0 = port
        li      t6, stage_table
        sll     at, v0, 0x0002              // at = port * 4 = offset to stage value
        addu    t6, t6, at                  // t6 = address of stage value
        lw      t6, 0x0000(t6)              // t6 = stage value
        beqz    t6, _normal                 // if Practice mode is disabled, skip
        nop

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      v1, 0x0008(sp)              // ~

        // check for L press while GAME SET is displayed

        lli     a0, Joypad.L                // a0 - button mask
        lli     a1, OS.FALSE                // a1 - all must be pressed
        jal     Joypad.check_buttons_all_   // v0 = bool
        lli     a2, Joypad.HELD             // a2 - type

        lw      ra, 0x0004(sp)              // restore registers
        lw      v1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        beqz    v0, _normal                 // if not held, skip
        nop

        // This is kind of hacky - hopefully it works well enough!!!!!!1111one
        li      t0, Global.current_screen
        lbu     t1, 0x0017(t0)              // t1 = stage
        addiu   t1, t1, -0x0001             // t1 = previous stage
        sb      t1, 0x0017(t0)              // update to previous stage
        sw      r0, 0x0020(t0)              // clear score/bonus stuff
        sw      r0, 0x0024(t0)              // clear score/bonus stuff
        sw      r0, 0x0028(t0)              // clear score/bonus stuff
        lui     t1, 0x800A
        lbu     t1, 0x493B(t1)              // t1 = initial stock value
        li      t0, Global.match_info
        lw      t0, 0x0000(t0)              // t0 = match info array
        // brute force rather than determine human port
        sb      t1, 0x002B(t0)              // reset stock value, p1
        sb      t1, 0x009F(t0)              // reset stock value, p2
        sb      t1, 0x0113(t0)              // reset stock value, p3
        sb      t1, 0x0187(t0)              // reset stock value, p4
        lli     t1, 0x0001                  // t1 = 1
        li      t0, SinglePlayerModes.reset_flag // load reset flag location
        sw      t1, 0x0000(t0)              // set reset flag
        li      t0, Global.screen_interrupt
        sw      t1, 0x0000(t0)              // force screen interrupt

        _normal:
        lui     v0, 0x8013                  // original line 1
        jr      ra
        lw      v0, 0x52D4(v0)              // original line 2
    }

    // @ Description
    // Required for Bonus Practice modes to allow retrying (retains current_screen)
    scope hold_l_to_retry_bonus_1: {
        OS.patch_start(0x113358, 0x8018EC18)
        j      hold_l_to_retry_bonus_1
        nop
        _return:
        OS.patch_end()
        // t3 is probably safe
        li      t3, SinglePlayerModes.reset_flag // load reset flag location
        lw      at, 0x0000(t3)              // at = 1 if we are resetting
        li      t6, Global.current_screen
        lbu     t6, 0x0000(t6)              // t6 = current screen id
        beqzl   at, _normal                 // retain current screen if reset_flag active
        addiu   t6, r0, 0x0013              // otherwise, original line 1 (BONUS_CSS 1)

        // if we're here, we want to skip setting 'Global.previous_screen' to '0x35'
        sw      r0, 0x0000(t3)              // reset reset flag
        j       0x8018ED58                  // modified jump (from 0x8018ED50)
        _normal:
        addiu   at, r0, 0x000A              // original line 2
        j       _return
        nop
    }
    scope hold_l_to_retry_bonus_2: {
        OS.patch_start(0x11345C, 0x8018ED1C)
        j      hold_l_to_retry_bonus_2
        nop
        _return:
        OS.patch_end()
        li      t3, SinglePlayerModes.reset_flag // load reset flag location
        lw      at, 0x0000(t3)              // at = 1 if we are resetting
        li      t2, Global.current_screen
        lbu     t2, 0x0000(t2)              // t2 = current screen id
        beqzl   at, _normal                 // retain current screen if reset_flag active
        addiu   t2, r0, 0x0014              // otherwise, original line 1 (BONUS_CSS 2)

        // if we're here, we want to skip setting 'Global.previous_screen' to '0x35'
        sw      r0, 0x0000(t3)              // reset reset flag
        j       0x8018ED58                  // modified jump (from 0x8018ED50)
        _normal:
        addiu   at, r0, 0x000A              // original line 2
        j       _return
        nop
    }

    constant STAGES(11)

    // @ Description
    // Holds stage values for each port
    stage_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4
}

} // __PRACTICE_1P__
