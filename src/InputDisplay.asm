// InputDisplay.asm
if !{defined __INPUT_DISPLAY__} {
define __INPUT_DISPLAY__()
print "included InputDisplay.asm\n"

// @ Description
// This file enables an input display in matches.

include "OS.asm"
include "Global.asm"

scope InputDisplay {
    // @ Description
    // Holds input display status for each port
    state_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4

    // @ Description
    // Sets up the input display objects
    scope setup_: {
        constant PERCENT_HUD_OBJECT_ARRAY(0x801315F8)

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        lli     s0, 0x0000                  // s0 = loop index (port)
        li      s1, state_table             // s1 = address of port input display state
        li      s2, PERCENT_HUD_OBJECT_ARRAY
        _loop:
        lw      a2, 0x0000(s1)              // a2 = 0 if off for port
        beqz    a2, _next                   // skip if off for port
        lw      at, 0x0000(s2)              // at = pointer to percent HUD object for port
        beqz    at, _next                   // skip if not turned on for port
        or      a1, s0, r0                  // a1 = port
        jal     create_input_display_objects_
        lw      a0, 0x0074(at)              // a0 = image position struct for series logo

        _next:
        sltiu   at, s0, 0x0003              // at = 1 if more ports to check
        addiu   s0, s0, 0x0001              // s0 = next port
        addiu   s1, s1, 0x0004              // s1 = address of port input display state for next port
        bnez    at, _loop
        addiu   s2, s2, 0x006C              // s2 = next port HUD object address

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Creates the input display objects using the image position struct as a positional reference
    // @ Arguments
    // a0 - image position struct for series logo of port percent HUD
    // a1 - port
    // a2 - position (1 = top, 2 = bottom)
    scope create_input_display_objects_: {
        addiu   a2, a2, -0x0001             // a2 = position (0 = top, 1 = bottom)

        li      at, Global.current_screen
        lbu     t0, 0x0000(at)              // t0 = current screen
        lli     at, 0x0035                  // at = bonus 1/2 screen_id
        lui     a3, 0x41A0                  // a3 = 20
        bnel    t0, at, pc() + 8            // if not bonus 1/2, don't adjust height
        lli     a3, 0x0000                  // a3 = 0
        bnezl   a2, pc() + 8                // if not position top, don't adjust height
        lli     a3, 0x0000                  // a3 = 0

        lli     at, 0x0016                  // at = VS screen_id
        beq     t0, at, _begin              // if on VS, continue
        lli     at, 0x0036                  // at = training screen_id
        beql    t0, at, _begin              // if training, always force bottom
        lli     a2, 0x0001                  // a2 = 1 (bottom)

        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer mode flag
        lli     at, SinglePlayerModes.MULTIMAN_ID
        beq     at, t0, _multiman           // if multiman, may need to adjust height
        lli     at, SinglePlayerModes.CRUEL_ID
        beq     at, t0, _multiman           // if cruel multiman, may need to adjust height
        lli     at, SinglePlayerModes.ALLSTAR_ID
        beq     at, t0, _allstar            // if allstar, may need to adjust height
        nop
        beqz    t0, _1p                     // if 1p, may need to adjust height
        lli     at, SinglePlayerModes.REMIX_1P_ID
        beq     at, t0, _1p                 // if remix 1p, may need to adjust height
        nop
        b       _begin
        nop

        _allstar:
        li      t0, SinglePlayerModes.STAGE_FLAG // t0 = stage ID address
        lb      t0, 0x0000(t0)              // t0 = current stage of 1p
        beqzl   t0, _begin                  // if Rest Area, always force bottom
        lli     a2, 0x0001                  // a2 = 1 (bottom)

        bnez    a2, _begin                  // if position is bottom, continue
        lli     at, 0x0001                  // at = Yoshi (or equivalent) team stage
        beql    t0, at, _begin              // if team stage, adjust
        lui     a3, 0x41F0                  // a3 = 30
        b       _begin
        nop

        _1p:
        bnez    a2, _begin                  // if position is bottom, continue
        nop
        li      t0, SinglePlayerModes.STAGE_FLAG // t0 = current stage address
        lbu     t0, 0x0000(t0)              // t0 = current stage
        lli     at, 0x0001                  // at = Yoshi (or equivalent) team stage
        beql    t0, at, _begin              // if team stage, adjust
        lui     a3, 0x41A0                  // a3 = 20
        lli     at, 0x0008                  // at = Kirby (or equivalent) team stage
        beql    t0, at, _begin              // if team stage, adjust
        lui     a3, 0x4160                  // a3 = 14
        lli     at, 0x000C                  // at = Polygon team stage
        beql    t0, at, _begin              // if team stage, adjust
        lui     a3, 0x41F0                  // a3 = 30
        b       _begin
        nop

        _multiman:
        beqzl   a2, _begin                  // if position is top, adjust height
        lui     a3, 0x4160                  // a3 = 14

        _begin:
        OS.save_registers()
        // 0x0010(sp) = image position struct for series logo of port percent HUD
        // 0x0014(sp) = port
        // 0x0018(sp) = position (0 = top, 1 = bottom)
        // 0x001C(sp) = offset top

        Render.load_file(0xC5, button_images_file_pointer)  // load button images
        Render.load_file(File.CSS_IMAGES, css_images_file_pointer)  // load css images for dpad and c buttons

        // The update_input_display_ routine should run after character actions change,
        // so we will use REGISTER_OBJECT_ROUTINE to do that.
        // We'll render L first... this object will be our control object.
        Render.draw_texture_at_offset(0x17, 0x0B, button_images_file_pointer, Render.file_c5_offsets.L, Render.NOOP, 0x41A00000, 0x41A80000, 0x8484844F, 0x303030FF, 0x3F200000)
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC190                  // at = -18
        mtc1    at, f4                      // f4 = -18
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        lw      at, 0x0074(v0)              // at = image struct of L button
        swc1    f0, 0x0058(at)              // update X position of L button
        sw      v0, 0x0004(sp)              // save reference to object (over at)

        lw      at, 0x0014(sp)              // at = port
        li      t0, Global.p_struct_head
        _loop:
        lw      t0, 0x0000(t0)              // t0 = player struct
        beqz    t0, _end                    // this should never happen, but if it does, abort
        nop
        lw      t1, 0x0004(t0)              // t1 = player object
        beqz    t1, _loop                   // if player not loaded, keep looping
        lbu     t1, 0x000D(t0)              // t1 = port
        bne     at, t1, _loop               // if not the port we're after, keep looping
        nop
        sw      t0, 0x0084(v0)              // save player struct in routine object
        sw      v0, 0x0004(sp)              // save reference to routine object (over at)

        lui     at, 0x41A8                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4322                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        lw      a2, 0x0074(v0)              // a2 = L button image position struct
        swc1    f2, 0x005C(a2)              // save Y position

        or      a0, v0, r0                  // a0 = object
        li      a1, update_input_display_   // a1 = routine
        lli     a2, 0x0001                  // a2 = ?
        lli     a3, 0x0000                  // a3 = last group to run
        jal     Render.REGISTER_OBJECT_ROUTINE_
        addiu   sp, sp, -0x0030             // create stack space
        addiu   sp, sp, 0x0030              // restore stack

        // R
        lw      a0, 0x0004(sp)              // a0 = control object
        li      a1, button_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = button images file address
        addiu   a1, a1, Render.file_c5_offsets.R
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41A8                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4322                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F20                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x8484844F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC0C0                  // at = -6
        mtc1    at, f4                      // f4 = -6
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position of R button
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0044(a0)              // save R button position struct reference in routine object

        // A
        li      a1, button_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = button images file address
        addiu   a1, a1, Render.file_c5_offsets.A
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x4204                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x432E                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F20                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x50A8FF4F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x41B0                  // at = 22
        mtc1    at, f4                      // f4 = 22
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0048(a0)              // save A button position struct reference in routine object

        // B
        li      a1, button_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = button images file address
        addiu   a1, a1, Render.file_c5_offsets.B
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41D8                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4328                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F20                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x00D0404F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x003000FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x4180                  // at = 16
        mtc1    at, f4                      // f4 = 16
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x004C(a0)              // save B button position struct reference in routine object

        // Z
        li      a1, button_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = button images file address
        addiu   a1, a1, Render.file_c5_offsets.Z
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41F0                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x432B                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F20                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x8484844F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC0C0                  // at = -6
        mtc1    at, f4                      // f4 = -6
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0034(a0)              // save Z button position struct reference in routine object

        // C-up
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1958
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41A0                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4321                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F00                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0xC0CC004F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x000000FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x41D8                  // at = 27
        mtc1    at, f4                      // f4 = 27
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0050(a0)              // save C-up button position struct reference in routine object

        // C-down
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x0688
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41E0                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4329                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F00                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0xC0CC004F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x000000FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x41D8                  // at = 27
        mtc1    at, f4                      // f4 = 27
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0054(a0)              // save C-down button position struct reference in routine object

        // C-left
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1A88
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41C0                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4325                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F00                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0xC0CC004F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x000000FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x41B8                  // at = 23
        mtc1    at, f4                      // f4 = 23
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0058(a0)              // save C-left button position struct reference in routine object

        // C-right
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1BB8
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41C0                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x4325                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F00                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0xC0CC004F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x000000FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x41F8                  // at = 31
        mtc1    at, f4                      // f4 = 31
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x005C(a0)              // save C-right button position struct reference in routine object

        // D-pad
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x2378
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     at, 0x41E8                  // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        bnezl   a2, pc() + 8                // if position is bottom, set Y position accordingly
        lui     at, 0x432A                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F20                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x8484844F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC190                  // at = -18
        mtc1    at, f4                      // f4 = -18
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object

        // D-pad up
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1958
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x432A4000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x41EA                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3EA8                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        sw      r0, 0x0028(v0)              // save button color
        sw      r0, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC173                  // at = -15.1875
        mtc1    at, f4                      // f4 = -15.1875
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0060(a0)              // save D-pad up button position struct reference in routine object

        // D-pad down
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x0688
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x432F8000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x420A                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3EA8                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        sw      r0, 0x0028(v0)              // save button color
        sw      r0, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC173                  // at = -15.1875
        mtc1    at, f4                      // f4 = -15.1875
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0064(a0)              // save D-pad down button position struct reference in routine object

        // D-pad left
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1A88
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x432CE000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x41FF                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3EA8                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        sw      r0, 0x0028(v0)              // save button color
        sw      r0, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC18F                  // at = -17.875
        mtc1    at, f4                      // f4 = -17.875
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0068(a0)              // save D-pad left button position struct reference in routine object

        // D-pad right
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x1BB8
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x432CE000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x41FF                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3EA8                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        sw      r0, 0x0028(v0)              // save button color
        sw      r0, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0xC148                  // at = -12.5
        mtc1    at, f4                      // f4 = -12.5
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x006C(a0)              // save D-pad right button position struct reference in routine object

        // Joystick gate
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x20B8
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x4326C000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x41CE                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F00                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0x8484844F              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x3F90                  // at = 1.125
        mtc1    at, f4                      // f4 = 1.125
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object

        // Joystick
        li      a1, css_images_file_pointer
        lw      a1, 0x0000(a1)              // a1 = css images file address
        addiu   a1, a1, 0x2218
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        li      at, 0x432BC000              // at = Y position
        lw      a2, 0x0018(sp)              // at = position (0 = top, 1 = bottom)
        beqzl   a2, pc() + 8                // if position is top, set Y position accordingly
        lui     at, 0x41F6                  // at = Y position
        mtc1    at, f2                      // f2 = Y position
        lwc1    f4, 0x001C(sp)              // f4 = offset top
        add.s   f2, f2, f4                  // f2 = Y position, adjusted
        swc1    f2, 0x005C(v0)              // save Y position
        lui     at, 0x3F08                  // at = scale
        sw      at, 0x0018(v0)              // update X scale
        sw      at, 0x001C(v0)              // update Y scale
        lli     at, 0x0201
        sh      at, 0x0024(v0)              // turn on blur
        li      at, 0xD4D4D4FF              // at = button color
        sw      at, 0x0028(v0)              // save button color
        li      at, 0x303030FF              // at = button text color
        sw      at, 0x0060(v0)              // save button text color
        lw      at, 0x0010(sp)              // at = image position struct for series logo of port percent HUD
        lwc1    f0, 0x0058(at)              // f0 = X position of series logo
        lui     at, 0x40A0                  // at = 5
        mtc1    at, f4                      // f4 = 5
        add.s   f0, f0, f4                  // f0 = X position of input display HUD
        swc1    f0, 0x0058(v0)              // update X position
        lw      a0, 0x0004(sp)              // a0 = control object
        sw      v0, 0x0030(a0)              // save joystick position struct reference in routine object
        swc1    f0, 0x003C(a0)              // save joystick centered X position
        swc1    f2, 0x0040(a0)              // save joystick centered Y position

        _end:
        OS.restore_registers()
        jr      ra
        nop

        button_images_file_pointer:
        dw 0

        css_images_file_pointer:
        dw 0
    }

    // @ Description
    // Runs for each port with an input display HUD active each frame
    // @ Arguments
    // 0x0030(a0) - joystick image position struct
    // 0x0034(a0) - Z button image position struct
    // 0x003C(a0) - joystick centered X position
    // 0x0040(a0) - joystick centered Y position
    // 0x0044(a0) - R button image position struct
    // 0x0048(a0) - A button image position struct
    // 0x004C(a0) - B button image position struct
    // 0x0050(a0) - C-up button image position struct
    // 0x0054(a0) - C-down button image position struct
    // 0x0058(a0) - C-left button image position struct
    // 0x005C(a0) - C-right button image position struct
    // 0x0060(a0) - Dpad-up button image position struct
    // 0x0064(a0) - Dpad-down button image position struct
    // 0x0068(a0) - Dpad-left button image position struct
    // 0x006C(a0) - Dpad-right button image position struct
    // 0x0074(a0) - L button image position struct
    // 0x0084(a0) - player struct
    scope update_input_display_: {
        lw      t0, 0x0084(a0)              // t0 = player struct
        lbu     t2, 0x0023(t0)              // t2 = player type (0 = man, 1 = cpu, 2 = n/a)
        bnez    t2, _get_cpu_inputs         // if CPU, get button mask from player struct instead
        lw      t1, 0x01B0(t0)              // t1 = raw button mask address
        lb      t2, 0x0008(t1)              // t2 = raw joystick X
        lb      t3, 0x0009(t1)              // t3 = raw joystick Y
        lhu     t1, 0x0000(t1)              // t1 = button mask

        slti    at, t2, 0x0051              // at = 0 if value too high
        beqzl   at, pc() + 8                // if X range past 0x0050, set to 0x0050
        lli     t2, 0x0050                  // t2 = max joystick X

        slti    at, t3, 0x0051              // at = 0 if value too high
        beqzl   at, pc() + 8                // if Y range past 0x0050, set to 0x0050
        lli     t3, 0x0050                  // t3 = max joystick Y

        slti    at, t2, 0xFFB0              // at = 1 if value too low
        bnezl   at, pc() + 8                // if X range past 0x0050, set to 0x0050
        addiu   t2, r0, 0xFFB0              // t2 = max joystick X

        slti    at, t3, 0xFFB0              // at = 1 if value too low
        bnezl   at, pc() + 8                // if Y range past 0x0050, set to 0x0050
        addiu   t3, r0, 0xFFB0              // t3 = max joystick Y

        b       _update_joystick
        nop

        _get_cpu_inputs:
        lhu     t1, 0x01BC(t0)              // t1 = button mask
        lb      t2, 0x01C2(t0)              // t2 = joystick X
        lb      t3, 0x01C3(t0)              // t3 = joystick Y

        _update_joystick:
        mtc1    t2, f0                      // f0 = joystick X
        mtc1    t3, f2                      // f2 = joystick Y
        cvt.s.w f0, f0                      // f0 = joystick X, floating point
        cvt.s.w f2, f2                      // f2 = joystick Y, floating point
        li      at, 0x3D75C28F              // at = 0.06
        mtc1    at, f4                      // f4 = 0.06
        li      at, 0xBD75C28F              // at = -0.06
        mtc1    at, f6                      // f6 = -0.06
        mul.s   f0, f0, f4                  // f0 = pixels from center, X axis
        mul.s   f2, f2, f6                  // f2 = pixels from center, Y axis

        lwc1    f4, 0x0040(a0)              // f4 = centered Y
        add.s   f2, f4, f2                  // f2 = updated Y
        lw      t4, 0x0030(a0)              // joystick position struct
        swc1    f2, 0x005C(t4)              // set Y
        lwc1    f4, 0x003C(a0)              // f4 = centered X
        add.s   f0, f4, f0                  // f0 = updated X
        swc1    f0, 0x0058(t4)              // set X
        lli     t6, 0x00FF                  // t6 = not centered alpha
        lli     t5, 0x008F                  // t5 = centered alpha

        lw      t8, 0x0070(a0)              // t8 = joystick cooldown value
        bnezl   t2, _set_joystick_alpha     // if not centered, use not centered alpha
        or      t5, t6, r0                  // t5 = not centered alpha
        bnezl   t3, _set_joystick_alpha     // if not centered, use not centered alpha
        or      t5, t6, r0                  // t5 = not centered alpha
        bltzl   t8, _set_joystick_alpha     // if not centered recently, use not centered alpha
        or      t5, t6, r0                  // t5 = not centered alpha

        _set_joystick_alpha:
        sb      t5, 0x002B(t4)              // set joystick button alpha

        lw      t4, 0x000C(t4)              // t4 = joystick gate image position struct
        lli     t6, 0x00AF                  // t6 = not centered alpha
        lli     t5, 0x004F                  // t5 = centered alpha
        bnezl   t2, _set_gate_alpha         // if not centered, use not centered alpha
        addiu   t8, r0, -0x0006             // set joystick cooldown
        bnezl   t3, _set_gate_alpha         // if not centered, use not centered alpha
        addiu   t8, r0, -0x0006             // set joystick cooldown
        bltzl   t8, _set_gate_alpha         // if not centered recently, use not centered alpha
        addiu   t8, t8, 0x0001              // t8 = joystick cooldown - 1
        or      t6, t5, r0                  // t6 = centered alpha

        _set_gate_alpha:
        sb      t6, 0x002B(t4)              // set joystick gate alpha
        sw      t8, 0x0070(a0)              // store joystick cooldown value

        andi    at, t1, Joypad.L            // at = 0 if not pressed
        lw      t4, 0x0074(a0)              // L button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        li      t6, 0x8484844F              // t6 = not pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set L button color

        andi    at, t1, Joypad.R            // at = 0 if not pressed
        lw      t4, 0x0044(a0)              // R button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set R button color

        andi    at, t1, Joypad.Z            // at = 0 if not pressed
        lw      t4, 0x0034(a0)              // Z button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set Z button color

        andi    at, t1, Joypad.A            // at = 0 if not pressed
        lw      t4, 0x0048(a0)              // A button image position struct
        li      t5, 0x50A8FFFF              // t5 = pressed color
        li      t6, 0x50A8FF4F              // t6 = not pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set A button color

        andi    at, t1, Joypad.B            // at = 0 if not pressed
        lw      t4, 0x004C(a0)              // B button image position struct
        li      t5, 0x00D040FF              // t5 = pressed color
        li      t6, 0x00D0404F              // t6 = not pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set B button color

        andi    at, t1, Joypad.CU           // at = 0 if not pressed
        lw      t4, 0x0050(a0)              // C-up button image position struct
        li      t5, 0xC0CC00FF              // t5 = pressed color
        li      t6, 0xC0CC004F              // t6 = not pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set C-up button color

        andi    at, t1, Joypad.CD           // at = 0 if not pressed
        lw      t4, 0x0054(a0)              // C-down button image position struct
        li      t5, 0xC0CC00FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set C-down button color

        andi    at, t1, Joypad.CL           // at = 0 if not pressed
        lw      t4, 0x0058(a0)              // C-left button image position struct
        li      t5, 0xC0CC00FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set C-left button color

        andi    at, t1, Joypad.CR           // at = 0 if not pressed
        lw      t4, 0x005C(a0)              // C-right button image position struct
        li      t5, 0xC0CC00FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, t6, r0                  // t5 = not pressed color
        sw      t5, 0x0028(t4)              // set C-right button color

        andi    at, t1, Joypad.DU           // at = 0 if not pressed
        lw      t4, 0x0060(a0)              // C-up button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, r0, r0                  // t5 = not pressed color (0x00000000)
        sw      t5, 0x0028(t4)              // set C-up button color

        andi    at, t1, Joypad.DD           // at = 0 if not pressed
        lw      t4, 0x0064(a0)              // C-down button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, r0, r0                  // t5 = not pressed color (0x00000000)
        sw      t5, 0x0028(t4)              // set C-down button color

        andi    at, t1, Joypad.DL           // at = 0 if not pressed
        lw      t4, 0x0068(a0)              // C-left button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, r0, r0                  // t5 = not pressed color (0x00000000)
        sw      t5, 0x0028(t4)              // set C-left button color

        andi    at, t1, Joypad.DR           // at = 0 if not pressed
        lw      t4, 0x006C(a0)              // C-right button image position struct
        li      t5, 0x848484FF              // t5 = pressed color
        beqzl   at, pc() + 8                // if not pressed, use not pressed color
        or      t5, r0, r0                  // t5 = not pressed color (0x00000000)
        sw      t5, 0x0028(t4)              // set C-right button color

        jr      ra
        nop
    }

    // @ Description
    // Adjusts VS timer position if 4p has input display HUD positioned at top
    scope adjust_timer_position_: {
        OS.patch_start(0x8E54C, 0x80112D4C)
        jal     adjust_timer_position_._digits
        lui     at, 0x41F0                  // original line 1 - at = Y position
        OS.patch_end()

        OS.patch_start(0x8E880, 0x80113080)
        jal     adjust_timer_position_._colon
        lui     at, 0x41F0                  // original line 1 - at = Y position
        OS.patch_end()

        _digits:
        li      a2, state_table
        lw      a2, 0x000C(a2)              // a2 = 4p input display HUD state
        beqz    a2, _end_digits             // if disabled, skip
        addiu   a2, a2, -0x0001             // a2 = 0 if top, 1 if bottom
        beqzl   a2, _end_digits             // if top, reposition lower
        lui     at, 0x4250                  // at = Y position, lowered

        _end_digits:
        jr      ra
        mtc1    at, f2                      // original line 2 - f2 = Y position

        _colon:
        li      a0, state_table
        lw      a0, 0x000C(a0)              // a0 = 4p input display HUD state
        beqz    a0, _end_colon              // if disabled, skip
        addiu   a0, a0, -0x0001             // a0 = 0 if top, 1 if bottom
        beqzl   a0, _end_colon              // if top, reposition lower
        lui     at, 0x4250                  // at = Y position, lowered

        _end_colon:
        jr      ra
        lui     a0, 0x8013                  // original line 2
    }
}

} // __INPUT_DISPLAY__
