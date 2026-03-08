// Accessibility.asm (code by goombapatrol)
if !{defined __ACCESSIBILITY__} {
define __ACCESSIBILITY__()
print "included Accessibility.asm\n"

// This file includes several accessibility-related toggles.
// May help with photosensitivity and/or motion sickness by reducing flashes and camera shake.

scope Accessibility {

    // @ Description
    // Reimplements the unused 'Anti-Flash' feature.
    // This disables certain screen flashes (hard hits, Zebes acid, barrel etc)
    // Vanilla reads value stored at 0x800A4930 which is always 1 (no option to toggle)
    // Note: included checks in DekuNut.asm and Flashbang.asm for '0x80131A40' screen flashes
    //       included checks in Lighting.asm as well
    scope flash_guard: {
        OS.patch_start(0x91610, 0x80115E10)
        j       flash_guard
        addiu   a0, r0, 0x03F8              // original line 2
        _return:
        OS.patch_end()

        li      t6, Toggles.entry_flash_guard
        lw      t6, 0x0004(t6)              // t5 = 1 if Flash Guard is enabled
        xori    t6, t6, 1                   // 0 -> 1 or 1 -> 0 (flip bool)

        _end:
        //// lbu     t6, 0x4930(t6)         // original line 1
        j       _return                     // return
        nop
    }

    // @ Description
    // Store structure for use later
    scope ParamMakeEffect: {
        OS.patch_start(0x663F4, 0x800EABF4)
        j       ParamMakeEffect.save_gobj
        or      v1, r0, r0                  // original line 2
        _return_1:
        OS.patch_end()
        OS.patch_start(0x66B88, 0x800EB388)
        j       ParamMakeEffect.clear_gobj
        lw      ra, 0x001C(sp)              // original line 1
        _return_2:
        OS.patch_end()

        save_gobj:
        li      at, ParamMakeEffect.gobj    // store struct (t7)
        sw      t7, 0x0000(at)              // ~
        j       _return_1                   // return
        addiu   at, r0, 0x0049              // original line 1

        clear_gobj:
        li      s0, ParamMakeEffect.gobj    // clear stored struct
        sw      r0, 0x0000(s0)              // ~
        j       _return_2                   // return
        lw      s0, 0x0018(sp)              // original line 2

        gobj:
        dw  0
    }

    // @ Description
    // This handles screenshake intensity, which can be lowered or turned off altogether.
    scope screenshake_toggle: {
        OS.patch_start(0x7C164, 0x80100964)
        j       screenshake_toggle
        nop
        _return:
        OS.patch_end()

        // v1 = severity (0 = light, 1 = moderate, 2 = heavy, 3 = POW block)

        // skip offscreen CPUs shaking screen in Remix RTTF
        li      a0, Global.match_info       // a0 = address of match info
        lw      a0, 0x0000(a0)              // a0 = match info start
        lbu     a0, 0x0001(a0)              // a0 = stage_id
        addiu   a0, a0, -Stages.id.REMIX_RTTF  // a0 = REMIX_RTTF Stage ID
        bnez    a0, _check_toggle           // skip if stage is not Remix RTTF
        nop
        li      a0, ParamMakeEffect.gobj    // load stored struct
        lw      a0, 0x0000(a0)              // ~
        beqz    a0, _check_toggle           // skip if no stored struct
        nop
        lh      t7, 0x018C(a0)              // get player state flags?
        andi    t7, t7, 0x0004              // !0 if off screen
        bnez    t7, _no_screenshake         // don't shake if off screen
        nop

        _check_toggle:
        li      a0, Toggles.entry_screenshake
        lw      a0, 0x0004(a0)              // t5 = 0 if 'DEFAULT', 1 if 'LIGHT', 2 if 'OFF'
        beqzl   a0, _end                    // branch accordingly
        lw      v1, 0x0030(sp)              // original line 1
        sltiu   a0, a0, 2                   // a0 = 1 if 'LIGHT'
        bnezl   a0, _end                    // branch accordingly
        or      v1, r0, r0                  // v1 = 0 (force all shakes to be Light)
        // if we're here, screenshake is set to 'OFF'
        _no_screenshake:
        addiu   v1, r0, -0x0001             // v1 = -1 (invalid intensity, so it doesn't take any shake branches)

        _end:
        or      a0, s0, r0                  // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Handle the Blast Zone explosion graphic effect
    scope blastzone_explode_gfx: {
        OS.patch_start(0x7D9C4, 0x801021C4)
        j       blastzone_explode_gfx.check_toggle
        nop
        _return:
        OS.patch_end()

        check_toggle:
        // li      t7, Toggles.entry_puff_sing_anim         // placeholder (Toggles.entry_blastzone_gfx)
        li      t7, Toggles.entry_blastzone_gfx
        lw      t7, 0x0004(t7)              // t7 = 0 if 'DEFAULT', 1 if 'OFF', 2 if 'REDUCED'
        addiu   t7, t7, -1                  // t7 = 0 if 'OFF'
        beqz    t7, _skip_gfx               // branch accordingly
        andi    t7, a2, 0x0001              // original line 1
        j       _return                     // return
        sll     t8, t7, 2                   // original line 2

        _skip_gfx:
        j       0x801023C8                  // skip to the end of the function
        nop

        // @ Description
        // Handle the Blast Zone explosion graphic scaling
        OS.patch_start(0x7DACC, 0x801022CC)
        j       blastzone_explode_gfx.check_toggle_scale_env
        lw      a0, 0x0074(v0)              // original line 1 (a0 = effect obj struct)
        _scale_env_return:
        OS.patch_end()

        check_toggle_scale_env:
        li      at, Toggles.entry_blastzone_gfx
        lw      at, 0x0004(at)              // at = 0 if 'DEFAULT', 1 if 'OFF', 2 if 'REDUCED'
        addiu   at, at, -2                  // at = 0 if 'REDUCED'
        bnez    at, _scale_env_end          // branch accordingly
        nop

        // default scale = 0x3F800000 (1.00)
        li      at, 0x3F23D70A              // scale = 0.64
        mtc1    at, f4
        swc1    f4,0x40(a0)                 // scale x
        swc1    f4,0x44(a0)                 // scale y
        // li      at, 0x3F800000              // scale = 1.0
        // mtc1    at, f4
        // swc1    f4,0x48(a0)                 // scale z

        _scale_env_end:
        j       _scale_env_return
        lui     at, 0x8013                  // original line 1

        // @ Description
        // Handle the Blast Zone explosion particles scaling
        // Note: alternatively, can skip 0x801021FC to not make stars (lbParticleMakeScriptID)
        // v0 = particle struct
        OS.patch_start(0x7DA18, 0x80102218)
        j       blastzone_explode_gfx.check_toggle_scale_prts
        nop
        _scale_prts_return:
        OS.patch_end()

        check_toggle_scale_prts:
        beqz    v0, _j_0x80102290           // original line 1, modified to jump
        lw      a0, 0x0028(sp)              // original line 2

        li      a0, Toggles.entry_blastzone_gfx
        lw      a0, 0x0004(a0)              // a0 = 0 if 'DEFAULT', 1 if 'OFF', 2 if 'REDUCED'
        addiu   a0, a0, -2                  // a0 = 0 if 'REDUCED'
        bnez    a0, _scale_prts_end         // branch accordingly
        nop

        // default scale of star particles = 0x3F800000 (1.00)
        li      a0, 0x3F400000              // scale = 0.75
        mtc1    a0, f4
        swc1    f4,0x1C(v0)                 // scale x
        swc1    f4,0x20(v0)                 // scale y
        // li      a0, 0x3F800000              // scale = 1.0
        // mtc1    a0, f4
        // swc1    f4,0x24(v0)                 // scale z

        _scale_prts_end:
        j       _scale_prts_return
        lw      a0, 0x0028(sp)              // original line 2

        _j_0x80102290:
        j       0x80102290                  // jump
        nop

    }
} // __ACCESSIBILITY__
