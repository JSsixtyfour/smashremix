// FD.asm
if !{defined __FD__} {
define __FD__()
print "included FD.asm\n"

// @ Description
// This file makes Final Destination playable in VS. mode.

include "OS.asm"
include "Global.asm"

scope FD {

    // @ Description
    // Makes Final Destination playables in VS. mode by skipping a jal to code only available in 
    // in singleplayer
    scope fix_: {
        OS.patch_start(0x00080484 , 0x80104C84)
//      jal     0x80192764                  // original line 1
        j       fix_
        nop
        _fix_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current_screen
        lli     t1, 0x0001                  // t1 = singleplayer fight screen
        beq     t0, t1, _singleplayer       // if (current_screen == singleplayer)
        nop

        _else:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _fix_return                 // execution return (skip jal)
        nop


        // this block executes for everything but singleplayer FD
        _singleplayer: 
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80192764                  // original line 1
        nop
        j       _fix_return
        nop

    }


    // @ Description
    // Sets track to FD battle music after the intro in VS
    scope music_fix_: {
        OS.patch_start(0x8E960, 0x80113160)
        jal     music_fix_
        lw      t8, 0x0018(a0)              // original line 1
        _music_fix_return:
        OS.patch_end()

        li      t0, Global.vs.stage         // t0 = address of stage_id
        lbu     t0, 0x0000(t0)              // t0 = stage_id
        lli     t9, Stages.id.FINAL_DESTINATION
        bne     t0, t9, _end                // if not FD, then skip to end
        nop

        li      t0, Global.vs.elapsed       // t0 = address of time elapsed
        lw      t0, 0x0000(t0)              // t0 = time elapsed
        addiu   t9, r0, 0x01C0              // t9 = length of intro
        bne     t0, t9, _end                // if not the exact end of intro, then skip to end
        nop

        lui     t0, 0x800A
        lw      t0, 0xD974(t0)              // t0 = pointer to previous bgm_id
        lw      t0, 0x0000(t0)              // t0 = previous bgm_id
        lli     t9, BGM.stage.MASTER_HAND_1 // t9 = FD intro music
        bne     t0, t9, _end                // if we didn't just play the FD intro music, then skip
        nop

        addiu   sp, sp,-0x0014              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t8, 0x0010(sp)              // save registers

        lli     a1, BGM.stage.FINAL_DESTINATION
        jal     BGM.play_                   // play FD battle music
        addu    a0, r0, r0

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t8, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0014              // deallocate stack space

        _end:
        addu    t9, t8, a1                  // original line 2

        j       _music_fix_return           // return
        nop
    }
}

} // __FD__
