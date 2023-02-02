// Pause.asm (original by Fray)
if !{defined __PAUSE__} {
define __PAUSE__()
print "included Pause.asm\n"

// @ Description
// Hold to pause is implemented in this file.

include "Toggles.asm"
include "OS.asm"

scope Pause {

    // @ Description
    // number of frames pause needs to be held to pause
    constant NUM_FRAMES(30)

    // @ Description
    // This is a hook into the pause function. It increment input_table[player] until that value
    // reaches NUM_FRAMES. One NUM_FRAMES is reached, the function continues as normal.
    scope hold_: {
        OS.patch_start(0x0008F88C, 0x8011408C)
        j       Pause.hold_
        nop
        _hold_return:
        OS.patch_end()

        // s1 holds button pressed/held etc. struct
        // s3 holds port number checking for pause
        // t7 needs to hold 0 at the end of this function to prevent pause

        lhu     t6, 0x0002(s1)              // original line 1
        andi    t7, t6, 0x1000              // original line 2

        Toggles.guard(Toggles.entry_hold_to_pause, _hold_return)

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        li      t0, input_table             // t0 = input_table
        add     t0, t0, s3                  // t0 = input_table + offset
        lhu     t6, 0x0000(s1)              // original line 1 (modified)
        andi    t7, t6, 0x1000              // original line 2
        beqz    t7, _end                    // return
        or      t1, r0, r0                  // t1 = pX_frames = 0

        _held:
        lb      t1, 0x0000(t0)              // t1 = pX_frames
        addiu   t1, t1, 0x0001              // pX_frames++
        li      t2, NUM_FRAMES              // t2 = NUM_FRAMES
        slt     t7, t2, t1                  // t7 = 1 if NUM_FRAMES < pX_frames; else t7 = 0
        bnel    t7, r0, _end                // if t7 == 1, run next line
        or      t1, r0, r0                  // t1 = 0 (hitstun bug fix)

        _end:
        sb      t1, 0x0000(t0)              // set pX frames held
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _hold_return                // return
        nop

        input_table:
        db 0x00                             // p1
        db 0x00                             // p2
        db 0x00                             // p3
        db 0x00                             // p4
    }

    // @ Description
    // Disables the HUD on the VS pause screen
    scope disable_hud_: {
        OS.patch_start(0x0008F738, 0x80113F38)
        jal     Pause.disable_hud_
        lw      a0, 0x0024(sp)              // original line 2
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        jal     0x80113E04                  // original line 1
        nop

        li      a1, Toggles.entry_disable_hud
        lw      a1, 0x0004(a1)              // a1 = entry_disable_hud (0 if OFF, 1 if PAUSE, 2 if ALL)
        slt     a1, r0, a1                  // a1 = 1 if the HUD should be disabled, 0 else

        jal     Render.toggle_group_display_
        lli     a0, 0x000E                  // a0 = group of HUD

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // hook allows us to add additional button checks for pause screen
    scope extra_controls_: {
        OS.patch_start(0x0008FB20, 0x80114320)
        jal     extra_controls_
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0020         // allocate sp
        sw      ra, 0x0014(sp)          // store ra
        sw      a1, 0x000C(sp)          // store a1
        sw      a1, 0x0010(sp)          // store a2
        sw      a3, 0x0018(sp)          // store a3

        jal     set_alternate_music_
        sw      at, 0x001C(sp)          // store at

        lw      ra, 0x0014(sp)          // restore ra
        lw      a1, 0x000C(sp)          // restore a1
        lw      a1, 0x0010(sp)          // restore a2
        lw      a3, 0x0018(sp)          // restore a3
        lw      at, 0x001C(sp)          // restore at
        bne     a3, at, _no_camera_controls
        addiu   sp, sp, 0x0020          // deallocate sp

        _camera_controls:
        jr      ra                      // return
        lhu     a2, 0x0002(a1)          // original line 2

        _no_camera_controls:
        j       0x8011445C              // original branch line 1
        lhu     a2, 0x0002(a1)          // original line 2

    }

    // @ Description
    // hook allows us to add additional button checks for pause camera movement
    scope extra_camera_controls_: {
        OS.patch_start(0x0008FB28, 0x80114328)
        jal     extra_camera_controls_
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0020         // allocate sp
        sw      ra, 0x0014(sp)          // store ra
        sw      a1, 0x0018(sp)          // store a1

        jal     Camera.extended_movement_
        nop

        lw      a1, 0x0018(sp)          // restore a1
        lb      v0, 0x0008(a1)          // original line 1
        lb      a0, 0x0009(a1)          // original line 2
        lw      ra, 0x0014(sp)          // restore ra
        jr      ra
        addiu   sp, sp, 0x0020          // deallocate sp

    }

    // @ Description
    // Change to alternate music if paused and pressing dpad
    scope set_alternate_music_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)              // ~

        li      v0, Toggles.entry_play_music
        lw      v0, 0x0004(v0)              // v0 = 0 if music is off
        beqz    v0, _end                    // skip if music is toggled off
        nop

        lh      t0, 0x0000(a1)              // t0 = players current input
        andi    v0, t0, 0x0500              // bitflag for dpad right or down
        bnez    v0, _check_override_track
        nop

        // reset dpad cycle initial delay
        li      at, dpad_song_cycle_timer   // at = dpad_song_cycle_timer
        addiu   a0, r0, 2                   // a0 = 2
        sw      a0, 0x0000(at)              // save updated timer
        b      _end
        nop

        _check_override_track:
        li      t1, BGM.vanilla_current_track  // t1 = hardcoded spot for current track
        lw      at, 0x0000(t1)                 // at = current track id
        addiu   a0, r0, BGM.special.HAMMER     // a0 = hammer track
        beq     at, a0, _end                   // branch if hammer music is playing
        addiu   a0, r0, BGM.special.INVINCIBLE // a0 = starman track
        beq     at, a0, _end                   // branch if starman music is playing
        nop

        // count down dpad timer while it is held
        _check_dpad_held_timer:
        li      at, dpad_song_cycle_timer   // at = dpad_song_cycle_timer
        lw      a0, 0x0000(at)              // a0 = dpad_song_cycle_timer value
        addiu   a0, a0, -0x0001
        bnez    a0, _end                    // branch if timer has not yet reached zero
        sw      a0, 0x0000(at)              // save updated timer

        // check which dpad button we are holding and branch accordingly
        andi    v0, t0, 0x0100              // bitflag for dpad right
        bnez    v0, _stage_track            // stage's next song (if any) if dpad right pressed
        nop
        andi    v0, t0, 0x0400              // bitflag for dpad down
        bnez    v0, _random_track           // random song if dpad down pressed
        nop

        _random_track:
        // this block loads from the random list using a random int
        jal     BGM.random_music_
        nop
        beqz    v1, _to_default             // if there were no valid entries in the random table, then use default bgm_id
        nop
        move    a0, v1                      // a0 - range (0, N-1)

        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        li      t0, BGM.random_table        // t0 = random_table
        sll     v0, v0, 0x0002              // v0 = offset = random_int * 4
        addu    t0, t0, v0                  // t0 = random_table + offset
        lw      a1, 0x0000(t0)              // a1 = bgm_id
        b       _save
        nop

        _stage_track:
        li      t0, BGM.default_track       // t0 = address of default_track
        lw      t0, 0x0000(t0)              // t0 = default_track
        li      a0, BGM.current_track       // a0 = address of current_track
        lw      a0, 0x0000(a0)              // a0 = current_track
        beql    a0, t0, _get_bgm_id         // a0 = -1 if current track is default
        addiu   a0, r0, -0x0001

        _get_bgm_id:
        li      t0, Global.match_info       // t0 = pointer to match info
        lw      t0, 0x0000(t0)              // load address of match info
        lbu     v0, 0x0001(t0)              // v0 = stage_id
        li      t0, Stages.alternate_music_table   // t0 = address of alternate music table
        sll     v0, v0, 0x0002              // v0 = offset to stage's alt music
        addu    t0, t0, v0                  // t0 = address of alt music options for stage (0x0 = Occasional, 0x2 = Rare)

        bltzl   a0, _try_occasional_song    // branch if we are on default track
        addiu   a0, r0, 0x0000              // a0 = occasional music

        li      a0, BGM.current_track       // a0 = address of current_track
        lw      a0, 0x0000(a0)              // a0 = current_track
        lh      v0, 0x0002(t0)              // v0 = bgm_id of rare (if it exists)
        beq     a0, v0, _to_default         // branch if we are on rare track
        nop

        lh      v0, 0x0000(t0)              // v0 = bgm_id of occasional (if it exists)
        beql    a0, v0, _try_next_song      // branch if we are on occasional track
        addiu   a0, r0, 0x0002              // a0 = rare music

        // otherwise we are on a random track; set to default in this case
        b       _to_default
        nop

        _try_occasional_song:
        addu    t0, t0, a0                  // t0 = address of bgm_id to use
        lh      v0, 0x0000(t0)              // v0 = bgm_id to use, maybe
        addiu   a0, r0, 0xFFFF              // a0 = -1 - means there is no occasional BGM_ID for this stage
        bnel    v0, a0, _save               // if there is occasional BGM_ID for this stage, use it
        addu    a1, r0, v0                  // a1 = bgm_id to use
        addiu   a0, r0, 0x0002              // a0 = rare music (safety check to handle when there is a RARE track but no OCCASIONAL)

        _try_next_song:
        addu    t0, t0, a0                  // t0 = address of bgm_id to use
        lh      v0, 0x0000(t0)              // v0 = bgm_id to use, maybe
        addiu   a0, r0, 0xFFFF              // a0 = -1 - means there is no alt BGM_ID for this stage
        beq     v0, a0, _to_default         // if (no next alt BGM_ID) for this stage, use default
        nop
        addu    a1, r0, v0                  // a1 = bgm_id to use
        b       _save
        nop

        _to_default:
        li      t0, BGM.default_track       // t0 = address
        lw      a1, 0x0000(t0)              // a0 = default_track

        _save:
        li      a0, BGM.current_track       // a0 = address of current_track
        lw      at, 0x0000(a0)              // at = current track
        sw      a1, 0x0000(a0)              // store current_track
        li      t1, BGM.vanilla_current_track // t1 = hardcoded spot for current track
        sw      a1, 0x0000(t1)              // save as override track (vanilla)
        sw      a1, 0x0004(t1)              // save as stage music (vanilla)
        beql    at, a1, _update_timer       // don't change the music if it's the same track
        addiu   a0, r0, 2                   // a0 = 2 (reset dpad cycle initial delay)
        lui     a0, 0x8013
        lw      a0, 0x1300(a0)              // a0 = stage file
        sw      a1, 0x007C(a0)              // store bgm_id

        jal     BGM.play_                   // play music
        addiu   a0, r0, 0x0000

        FGM.play(0x009E)                    // play generic menu sfx

        // set dpad cycle repeat delay
        addiu   a0, r0, 30                  // a0 = 30

        _update_timer:
        li      at, dpad_song_cycle_timer   // at = dpad_song_cycle_timer
        sw      a0, 0x0000(at)              // save updated timer
        b      _end
        nop

        _end:
        lw      ra, 0x0014(sp)              // restore registers
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Timer for cycling song with held dpad to control speed of cycling.
    dpad_song_cycle_timer:
    dw  0x0002

}

} // __PAUSE__
