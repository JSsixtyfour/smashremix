scope Zoom {

    // offset_y:
    // dw 0x0

    // // 80172CA4+EC
    // scope hat_test: {
        // OS.patch_start(0xED7D0, 0x80172D90)
        // j hat_test
        // nop
        // _return:
        // OS.patch_end()

        // // v1 = bone index to attach to
        // // s2 = fighter struct

        // _loop_prepare:
        // or t0, r0, r0 // i
        // addiu t1, s2, 0x5BC // first hurtbox definition address

        // _loop:
        // lw t2, 0xC(t1) // t2 = hit type
        // lli at, 0x2
        // beq at, t2, _loop_end // found hit type = 2, exit loop
        // nop
        // _loop_goto_next:
        // addiu t0, t0, 0x1 // i += 1
        // b _loop
        // addiu t1, t1, 0x2C // point to next entry (entry size: 2C)
        // _loop_end:

        // lw t0, 0x4(t1) // t0 = attach bone id
        // or v1, r0, t0 // attach bone = head bone we found

        // // size is at 20, 24, 28
        // lw at, 0x24(t1) // load size y
        // mtc1 at, f2
        // lw at, 0x18(t1) // load offset y
        // mtc1 at, f4
        // add.s f2, f2, f4
        // li t0, offset_y
        // swc1 f2, 0x0(t0) // save offset Y for later
        
        // _original:
        // sll t3, v1, 0x2
        // addu v0, s2, t3

        // j       _return
        // nop
    // }

    // // 80172CA4+138
    // scope hat_test_2: {
        // OS.patch_start(0xED81C, 0x80172DDC)
        // j hat_test_2
        // nop
        // _return:
        // OS.patch_end()

        // li t0, offset_y
        // lwc1 f2, 0x0(t0) // load offset

        // lw at, 0x74(s1) // load item's first bone
        // lw at, 0x10(at) // a0 = item second joint (joint 1)
        
        // // pos = 1C, 20, 24
        // lwc1 f4, 0x20(at) // load current offset
        // add.s f4, f4, f2
        // swc1 f4, 0x20(at) // save new offset

        // _original:
        // addu v0, v0, t8
        // lw v0, 0x95D0(v0)

        // j       _return
        // nop
    // }


    constant ZOOM_DURATION(0x0028)

    zoom_timer:
    dw 0x0000

    zoom_type:
    dw 0x0000

    decisive_stock_flag:
    dw 0x0000

    magnify_display_save:
    db 0x0000 // to save/restore previous magnify display value
    OS.align(4)
    zoomed_in_gobj_save:
    dw 0x00000000 // to save/restore previous zoom player value
    camera_mode_save:
    db 0x0000 // to save/restore previous camera mode value
    OS.align(4)

    zoom_offset:
    dw  0x00000000                                  // x offset
    dw  0x00000000                                  // y offset
    OS.align(4)

    zoom_background_file:; dw 0x00000000
    zoom_background_object:; dw 0x00000000

    // This is the function where the final knockback is set to a character
    // Here, we will check if the knockback will result in a KO
    // 80140EE4 + 600 = 801414E4
    scope final_knockback_was_set: {
        OS.patch_start(0xBBF24, 0x801414E4)
        j       final_knockback_was_set
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_special_zoom, t0)      // t0 = Special Zoom toggle
        beqz    t0, _original              // branch if toggle is disabled
        nop

        // Check if we're in a valid game mode
        check_gamemode:
        li      at, Global.current_screen
        lbu     at, 0x0000(at) // at = current screen
        addiu   t0, r0, Global.screen.VS_BATTLE
        beq     t0, at, check_gamemode_2
        addiu   t0, r0, Global.screen.TRAINING_MODE
        beq     t0, at, check_gamemode_2
        addiu   t0, r0, Global.screen.REMIX_MODES
        beq     t0, at, check_gamemode_2
        addiu   t0, r0, Global.screen.TITLE_AND_1P
        beq     t0, at, check_gamemode_2
        nop

        b _original // if not in any of the battle screens, skip
        nop

        check_gamemode_2:
        // stamina mode check: disable on stamina battles
        li      t0, Stamina.VS_MODE
        lbu     t0, 0x0000(t0) // load mode
        addiu   at, r0, Stamina.STAMINA_MODE // stamina mode
        beq     t0, at, _original // if stamina mode, skip
        nop

        update_decisive_stock_flag:
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      t7, 0x000C(sp)              // ~
        sw      v1, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // ~
        sw      a3, 0x001C(sp)              // ~
        or      a0, r0, s0
        jal     CheckDecisiveStock
        nop
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // restore a0
        lw      t7, 0x000C(sp)              // restore t7
        lw      v1, 0x0010(sp)              // restore v1
        lw      a1, 0x0014(sp)              // restore a1
        lw      a2, 0x0018(sp)              // restore a2
        lw      a3, 0x001C(sp)              // restore a3
        addiu   sp, sp, 0x0028              // deallocate stack space

        // Update zoom offset
        update_offset_pos:
        jal update_offset
        nop

        Toggles.read(entry_special_zoom, t0)      // t0 = Special Zoom toggle

        branch_toggle_value:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0000(sp)              // ~
        sw      t7, 0x0004(sp)              // ~

        lli     t1, 0x2
        beq     t0, t1, check_knockback          // if toggle == 2, always go for it
        nop
        lli     t1, 0x1
        beq     t0, t1, check_decisive_stock     // if toggle == 1, check if we're in a decisive stock
        nop

        b       _end
        nop

        check_decisive_stock:
        lli     t1, 0x1
        li      t0, decisive_stock_flag // t0 = decisive_stock_flag address
        lw      t0, 0x0000(t0) // t0 = decisive_stock_flag value
        beq     t0, t1, check_knockback // if in a decisive stock, continue to knockback check
        nop
        b       special_zoom_check // else, KO check but still go for special zoom check
        nop

        // KNOCKBACK CHECK START
        check_knockback:
        jal check_ko
        nop

        // if ko is true, skip special move check (ko overrides special zoom)
        bnez    v0, set_zoom
        nop

        special_zoom_check:
        jal     check_special_zoom
        nop

        // if flag is zero, original behavior
        beqz    v0, _end
        nop

        // if flag is not zero, apply zoom
        set_zoom:
        jal     apply_zoom
        nop

        _end:
        lw      ra, 0x0000(sp)              // ~
        lw      t7, 0x0004(sp)              // restore t7
        addiu   sp, sp, 0x0020              // deallocate stack space

        _original:
        ori     t6, t7, 0x1   // original lines
        sb      t6, 0x18F(s0)

        j       _return
        nop
    }

    // cmManager_MakeWallpaperCamera: function that creates the background room/camera
    // 8010DB54 + BC = 8010DC10
    scope create_zoom_camera: {
        OS.patch_start(0x89410, 0x8010DC10)
        j       create_zoom_camera
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_special_zoom, t0)      // t0 = Special Zoom toggle
        beqz    t0, _original              // branch if toggle is disabled
        nop

        // load background effect
        // background: 0042 0x03050 0x3FFFC - Intro Fighters Clash Object
        Render.load_file(0x04B, Zoom.zoom_background_file)

        // Reset zoom timer
        // Needed to not carry slow-mo when training mode is reset
        li      t0, zoom_timer     // t0 = zoom_timer address
        sw      r0, 0x0000(t0)

        // Reset zoom type
        li      t0, zoom_type     // t0 = zoom_type address
        sw      r0, 0x0000(t0)

        // Also clear background object pointer on training mode reset
        li      t0, Zoom.zoom_background_object
        sw      r0, 0x0(t0)

        // create camera/room for the background effect
        addiu       sp,sp,-0x58
        sw          ra,0x44(sp)
        sw          s1,0x40(sp)
        sw          s0,0x3c(sp)

        li          v0,0x80017EC0
        li          t6,0x3C
        li          t8,0
        li          t9,0x20
        li          t7,1
        li          t0,1
        li          t1,1
        li          t2,1

        sw          t2,0x30(sp)
        sw          t1,0x28(sp)
        sw          t0,0x24(sp)
        sw          t7,0x20(sp)
        sw          t9,0x1c(sp)
        sw          t8,0x18(sp)
        sw          t6,0x14(sp)
        sw          v0,0x10(sp)
        sw          v0,0x4c(sp)
        sw          r0,0x2c(sp)
        sw          r0,0x34(sp)
        li          a0,0x3EF
        or          a1,r0,r0
        li          a2,0x9
        jal         0x8000B93C
        lui         a3,0x8000
        lui         s1,0x8013
        addiu       s1,s1,0x14B0
        lw          t3,0x20(s1)
        lw          t4,0x24(s1)
        lw          t5,0x28(s1)
        lw          t6,0x2C(s1)
        mtc1        t3,f4
        mtc1        t4,f6
        mtc1        t5,f8
        mtc1        t6,f10
        cvt.s.w     f4,f4
        lw          s0,0x74(v0)
        addiu       a0,s0,0x8
        cvt.s.w     f6,f6
        mfc1        a1,f4
        cvt.s.w     f8,f8
        mfc1        a2,f6
        cvt.s.w     f16,f10
        mfc1        a3,f8
        jal         0x80007080
        swc1        f16,0x10(sp)
        lw          t8,0x28(s1)
        lw          t9,0x20(s1)
        lw          t0,0x2c(s1)
        lw          t1,0x24(s1)
        subu        t7,t8,t9
        mtc1        t7,f18
        subu        t2,t0,t1
        mtc1        t2,f6
        cvt.s.w     f4,f18
        mtc1        r0,f0
        lw          t3,0x80(s0)
        lui         at,0x44FA
        mtc1        at,f16
        cvt.s.w     f8,f6
        ori         t4,t3,0x0004
        sw          t4,0x80(s0)
        swc1        f0,0x50(s0)
        swc1        f0,0x4c(s0)
        swc1        f0,0x48(s0)
        div.s       f10,f4,f8
        swc1        f0,0x40(s0)
        swc1        f0,0x3c(s0)
        swc1        f16,0x44(s0)

        swc1        f10,0x24(s0)

        lw      ra,0x44(sp)
        lw      s1,0x40(sp)
        lw      s0,0x3c(sp)
        addiu   sp,sp,0x58
        // create camera end

        _original:
        lw      ra,0x3c(sp) // original line 1
        lw      v0,0x44(sp) // original line 2

        j       _return
        nop
    }

    // 8010C960 + 5C = 8010C9BC
    // 58:    swc1    $f8,0x34(sp)
    // 5c:    lui     v1,%hi(D_ovl2_801314B0) -> position = character position + cam offset Y
    // add extra offsets from here
    scope zoomed_in_camera_offset: {
        OS.patch_start(0x881BC, 0x8010C9BC)
        j       zoomed_in_camera_offset
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_special_zoom, t0)      // t0 = Special Zoom toggle
        beqz    t0, _original                     // branch if toggle is disabled
        nop

        li      t0, zoom_timer     // t0 = zoom_timer address
        lw      t0, 0x0000(t0)     // t1 = zoom timer

        blez    t0, _original
        nop

        li      t0, zoom_offset // t0 = zoom_offset address

        _check_max_offset:
        lui     at, 0x4416      // 600.0
        mtc1    at, f2          // f2 = max offset

        lwc1    f0, 0x00(t0)    // f0 = zoom offset X
        abs.s   f0, f0
        nop
        c.lt.s  f0, f2          // is abs(value) <= max_offset?
        nop
        bc1fl   _original       // if not, skip
        nop

        lwc1    f0, 0x04(t0)    // f0 = zoom offset Y
        abs.s   f0, f0
        nop
        c.lt.s  f0, f2          // is abs(value) <= max_offset?
        nop
        bc1fl   _original       // if not, skip
        nop

        _apply_offset:
        lwc1    f0, 0x30(sp)     // f0 = camera focus X
        lwc1    f2, 0x00(t0)     // f2 = zoom offset X
        add.s   f0, f0, f2       // camera focus X += zoom offset X
        swc1    f0, 0x30(sp)

        lwc1    f0, 0x34(sp)     // f0 = camera focus Y
        lwc1    f2, 0x04(t0)     // f2 = zoom offset Y
        add.s   f0, f0, f2       // camera focus Y += zoom offset Y
        swc1    f0, 0x34(sp)

        _original:
        lui     v1, 0x8013
        addiu   v1, v1, 0x14B0

        j       _return
        nop
    }

    // 0x8000A5E4
    scope objects_update: {
        OS.patch_start(0xB1EC, 0x8000A5EC)
        j       objects_update
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_special_zoom, t0)      // t0 = Special Zoom toggle
        beqz    t0, _original              // branch if toggle is disabled
        nop

        or      t2, r0, at // save at

        li      t0, zoom_timer     // t0 = zoom_timer address
        lw      t1, 0x0000(t0)     // t1 = zoom timer

        li      t8, Global.current_screen   // ~
        lbu     t8, 0x0000(t8)              // t8 = current screen
        addiu   t3, r0, Global.screen.VS_BATTLE
        beq     t3, t8, battle_scene
        addiu   t3, r0, Global.screen.TRAINING_MODE
        beq     t3, t8, battle_scene
        addiu   t3, r0, Global.screen.REMIX_MODES
        beq     t3, t8, battle_scene
        addiu   t3, r0, Global.screen.TITLE_AND_1P
        beq     t3, t8, battle_scene
        nop

        b non_battle_scene          // if not in any of the battle screens, skip to standard
        nop

        non_battle_scene:
        li      t0, zoom_timer     // t0 = zoom_timer address
        sw      r0, 0x0000(t0)     // set zoom timer to 0
        b       _original          // ignore this patch
        or      at, r0, t2         // restore at

        battle_scene:
        bgt     t1, r0, _cancel_update_check
        nop

        b   _original
        or      at, r0, t2 // restore at

        _cancel_update_check:
        slow_mo:
        // Every 16 frames we run the original update function once, effectively
        // implementing a slow-mo effect similar to training mode's 1/4 speed
        ori         t3, r0, 0x000F  // % 16

        // Using t3 in the "and" working as a "mod" operation (division remainder)
        li      t5, Global.current_screen_frame_count // ~
        lw      t5, 0x0000(t5)           // t5 = global frame count

        and     t7, t5, t3
        beqz    t7, _original // perform original update function on objects
        or      at, r0, t2 // restore at

        addiu sp, sp, 0x28 // deallocate what the original function did earlier

        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a1, 0x001C(sp)              // save a1
        sw      a2, 0x0020(sp)              // save a2
        sw      s0, 0x0024(sp)              // save s0
        sw      t6, 0x0028(sp)              // save t6
        // The camera never gets frozen, update it
        lui a0, 0x8013
        lw  a0, 0x1460(a0) // get camera

        scope camera_update: {
            // If in training mode, just continue and ignore pause status
            li      t0, Global.current_screen               // ~
            lbu     t0, 0x0000(t0)                          // t0 = screen_id
            subiu   t0, t0, Global.screen.TRAINING_MODE     // t0 = 0 if training
            beqz    t0, _update_camera                     // if in training mode, always update camera
            nop

            // If not in training mode, check if the game is paused
            li      t0, Global.match_info
            lw      t0, 0x0000(t0)              // t0 = match info
            lbu     t0, 0x0011(t0)              // t0 = pause state is 0 or 1 if not paused
            sltiu   t0, t0, 2                   // t0 = 1 if unpaused()
            beqz    t0, _end                    // if paused, skip and do not count zoom timer frames
            nop

            // If using a special camera mode, do not run camera update
            li      t0, Toggles.entry_camera_mode
            lw      t0, 0x0004(t0) // t0 = camera type toggle value
            bnez    t0, _decrease_timer // skip zoom if camera type != NORMAL
            nop

            // If zoomed out (Time Twister), do not run camera update
            li      t0, 0x801314B0              // t0 = camera struct
            li      t1, 0x8010CCC0              // t1 = camera routine if zoomed to max
            lw      t0, 0x000C(t0)              // t0 = current camera routine
            beq     t1, t0, _decrease_timer     // skip zoom if zoomed out
            nop

            _update_camera:
            jal     0x8010CECC // camera update
            nop

            _decrease_timer:
            // Decrease zoom_timer by 1
            li      t0, zoom_timer     // t0 = zoom_timer address
            lw      t1, 0x0000(t0)     // t1 = zoom timer

            addiu   t1, t1, -1

            sw      t1, 0x0000(t0)

            beq     t1, r0, became_zero
            nop

            b       _end
            nop

            // Zoom timer became zero
            became_zero:
            addiu   sp, sp, -0x20
            sw      ra, 0x0004(sp)
            jal     end_zoom
            nop
            lw      ra, 0x0004(sp)
            addiu   sp, sp, 0x20

            _end:
        }

        // Load the background object
        li      t6, Zoom.zoom_background_object
        lw      a0, 0x0(t6)

        // if the background object doesn't exist, skip
        beqz    a0, after_background_obj
        nop

        // if the background object exists, update it once every 2 frames
        ori     t3, r0, 0x0001  // % 1

        // Using t3 in the "and" working as a "mod" operation (division remainder)
        li      t5, Global.current_screen_frame_count // ~
        lw      t5, 0x0000(t5)           // t5 = global frame count

        and     t7, t5, t3
        beqz    t7, after_background_obj
        nop

        jal     0x8000DF34
        nop

        after_background_obj:
        lw      ra, 0x0004(sp)              // restore ra
        lw      a1, 0x001C(sp)              // restore a1
        lw      a2, 0x0020(sp)              // restore a2
        lw      s0, 0x0024(sp)              // restore s0
        lw      t6, 0x0028(sp)              // restore t6
        addiu   sp, sp, 0x0030              // allocate stack space

        jr ra
        nop

        _original:
        sw      r0, 0x6A64(at)              // original line 1
        lui     at, 0x8004                  // original line 2

        j       _return
        nop
    }

    // This function calculates the knockback trajectory
    // For all frames hitstun is active
    // s0 = player struct
    // Result ends in v0 (0 if no KO, 1 if KO)
    scope check_ko: {
        OS.routine_begin(0x80)

        sw      r0, 0x0(sp)
        //lw    s1, 0x0004(s0) // s1 = player object

        lw      t3, 0x0078(s0) // t3 = player position vector
        lw      t1, 0x0000(t3) // t1 = player x
        lw      t2, 0x0004(t3) // t2 = player y

        lw      t3, 0xB18(s0) // t3 = histsun timer

        sw      r0, 0x4(sp)   // using 0x4(sp) as gravity accumulator

        lw      t4, 0x54(s0) // vel_damage_air->x(t4);
        lw      t5, 0x58(s0) // vel_damage_air->y(t5);

        // damage_angle(f0) = atan2f(vel_damage_air->y, vel_damage_air->x);
        lwc1    f12, 0x58(s0)
        jal     0x8001863C // atan2f(f12, f14), result ends in f0
        lwc1    f14, 0x54(s0)

        mov.s   f12, f0     // f12 = damage_angle
        swc1    f0, 0x8(sp) // 0x8(sp) = damage angle

        // save max y value for KOs at the top
        sw      t2, 0xC(sp) // 0xC(sp) = max y value = initial y

        kb_loop:
        li      t8, 0x3FD9999A  // t8 = 1.7F
        mtc1    t8, f8          // f8 = 1.7F

        lw      t6, 0x58(s0) // vel_damage_new.x(t5) = vel_damage_air->y;
        lw      t7, 0x54(s0) // vel_damage_new.y(t6) = vel_damage_air->x;

        // vel_damage_air->x -= (1.7F * cosf(damage_angle));
        lwc1    f12, 0x8(sp) // f12 = 0x8(sp) = damage angle
        jal     0x80035CD0              // f0 = cos(f12)(damage_angle)
        nop

        mtc1    t4, f4      // f4 = vel_damage_air->x
        mtc1    t8, f8      // f8 = 1.7F
        mul.s   f0, f0, f8  // f0 = 1.7F * cosf(damage_angle)
        nop
        sub.s   f4, f4, f0
        mfc1    t4, f4      // save back to vel_damage_air->x

        mtc1    t1, f10         // f10 = t1 = player x
        add.s   f10, f10, f4    // topn_translate->x += vel_damage_air->x;
        mfc1    t1, f10         // save back to player x

        // vel_damage_air->y -= (1.7F * __sinf(damage_angle));
        lwc1    f12, 0x8(sp) // f12 = 0x8(sp) = damage angle
        jal     0x800303F0              // f0 = sin(f12)(damage_angle)
        nop

        mtc1    t5, f4      // f4 = vel_damage_air->y
        mtc1    t8, f8      // f8 = 1.7F
        mul.s   f0, f0, f8  // f0 = 1.7F * sinf(damage_angle)
        nop
        sub.s   f4, f4, f0
        mfc1    t5, f4      // save back to vel_damage_air->y

        mtc1    t2, f10         // f10 = t2 = player y

        add.s   f10, f10, f4    // topn_translate->y += vel_damage_air->y;

        lw      t0, 0x9C8(s0)  // t0 = attribute pointer
        lw      t0, 0x58(t0)   // t0 = gravity

        mtc1    t0, f4         // f4 = t0 = gravity
        lwc1    f6, 0x4(sp)    // f6 = 0x4(sp) = gravity accumulator
        add.s   f4, f4, f6     // add to accumulator

        lw      t0, 0x9C8(s0)  // t0 = attribute pointer
        lw      t0, 0x5C(t0)   // t0 = max fall speed
        mtc1    t0, f6         // f6 = t0 = max fall speed

        c.lt.s  f4, f6         // is accumulator(f4) < max fall speed(f6)?
        nop
        bc1tl   after_gravity_clamp
        nop

        mov.s   f4, f6          // clamp fall speed

        after_gravity_clamp:
        swc1    f4, 0x4(sp)    // save back to accumulator

        sub.s   f10, f10, f4   // topn_translate->y += vel_damage_air->y;

        mfc1    t2, f10         // save back to player y

        max_y_check:
        lwc1    f4, 0xC(sp) // f4 = max y position

        c.lt.s  f4, f10     // max y position(f4) < current y position(f10)?
        nop
        bc1fl   max_y_check_end
        nop

        swc1    f10, 0xC(sp) // max y position = current y position

        max_y_check_end:

        // loop end logic
        subi    t3, 0x1    // hitstun-based counter -= 1

        bgtz    t3, kb_loop
        nop
        kb_loop_end:

        // here, t1 = final x pos; t2 = final y pos
        li      v1, 0x80131300 // base for blastzone positions
        lw      v1, 0x0(v1)

        // top blastzone
        lh      t0, 0x0074(v1) // top blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = top blastzone (float)

        lwc1    f10, 0xC(sp)  // f10 = max player y position

        c.le.s  f18, f10      // is top blastzone <= player y? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // side blastzones
        mtc1 t1, f10  // f10 = final player x position

        // left
        lh      t0, 0x007A(v1) // left blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = left blastzone (float)

        c.le.s  f10, f18      // is player x <= left blastzone? f10 <= 18?
        nop
        bc1tl   set_zoom_flag1
        nop

        // right
        lh      t0, 0x0078(v1) // right blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = right blastzone (float)

        c.le.s  f18, f10      // is right blastzone <= player x? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // bottom blastzone
        lw      t0, 0xEC(s0)    // t0 = clipping id cpu is above (0xFFFF if none)
        addiu   at, r0, 0xFFFF
        bne     at, t0, set_zoom_flag0  // branch ground below
        nop

        lh      t0, 0x0076(v1) // bottom blastzone
        mtc1    t0, f18
        cvt.s.w f18, f18 // f18 = bottom blastzone (float)

        mtc1 t2, f10  // f10 = final player y position

        c.le.s  f10, f18      // is player y <= bottom blastzone? f18 <= 10?
        nop
        bc1tl   set_zoom_flag1
        nop

        // default (no zoom)
        b set_zoom_flag0
        nop

        set_zoom_flag1:
        or      t0, t0, r0
        lli     t0, 0x1
        sw      t0, 0x0(sp)

        b check_knockback_end
        nop

        set_zoom_flag0:
        or      t0, t0, r0
        lli     t0, 0x0
        sw      t0, 0x0(sp)

        b check_knockback_end
        nop

        check_knockback_end:
        // note: check 0x800E2048 for knockback stuff

        lw      v0, 0x0(sp) // load result into v0

        _end:
        OS.routine_end(0x80)
    }

    // v0 should be the zoom flag
    // 1 -> KO zoom
    // 2 -> special move zoom
    scope apply_zoom: {
        OS.routine_begin(0x80)

        li      t0, zoom_timer     // t0 = zoom_timer address
        lw      t1, 0x0000(t0)     // t1 = zoom timer

        // if not currently in zoom, skip cleanup
        blez    t1, _after_cleanup
        nop

        li      t0, zoom_type     // t0 = zoom_type address
        lw      t1, 0x0000(t0)    // t1 = zoom type

        // here we check the current zoom's type
        // if the current zoom is KO and we're applying a special move zoom, skip
        // so we don't overwrite it
        li      t0, 0x1         // t0 = KO ZOOM (1)
        bne     t0, t1, _clean_previous_zoom // continue if previous zoom is not KO zoom
        nop

        li      t0, 0x2         // t0 = Special Move Zoom (2)
        bne     t0, v0, _clean_previous_zoom // continue if not setting special zoom
        nop

        // If we reached here, previous zoom is KO and current zoom is Special Move zoom
        // Drop the whole thing
        b       _end
        nop

        _clean_previous_zoom:
        jal     end_zoom
        nop
        _after_cleanup:
        sw      v0, 0x4(sp) // save zoom flag in 0x4(sp)

        // s0 = fighter struct
        lw      a0, 0x4(s0) // a0 = fighter object

        li      t0, zoom_type     // t0 = zoom_type address
        sw      v0, 0x0000(t0)    // update zoom type

        // load current magnify display value
        lui     t1, 0x8013                          // t1 = ram location
        lb      t6, 0x1580(t1)                      // load magnifying glass value
        // save current state for restoring later if we zoom
        li      t0, magnify_display_save            // t1 = magnify_display_save address
        sb      t6, 0x0000(t0)                      // save magnify display value

        // Here, check in case we have more than 2 players and a special move zoom
        // In this case, we don't zoom in
        lli     t1, 0x2                             // t1 = 2 (special move zoom)
        bne     v0, t1, set_camera_zoom_in_mode     // if not special move zoom, move on with zoom
        nop

        addiu   sp, sp, -0x20
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        jal     CheckPlayersInMatch
        nop
        or      t0, v0, r0                          // load function result into t0
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x20

        lli     t1, 0x2                             // t1 = 2
        beq     t0, t1, set_camera_zoom_in_mode     // if number of players is 2, move on with zoom
        nop
        b       set_camera_zoom_in_mode_end         // otherwise, we skip zoom
        nop

        set_camera_zoom_in_mode:
        _save_current_zoomed_in_gobj:
        // this is for training mode, since if we're using the zoomed-in mode we have to restore
        // the zoom on P1. zoom object is in the camera struct's 0x44
        li      t1, Camera.camera_struct // t1 = camera_mode_save address
        lw      t0, 0x44(t1)              // load current camera zoomed-in gobj
        li      t1, zoomed_in_gobj_save // t1 = zoomed_in_gobj_save address
        sw      t0, 0x0000(t1)           // save zoomed-in gobj value

        // func_ovl2_8010CF44(fighter_gobj, 0.0F, 0.0F, ftGetStruct(fighter_gobj)->attributes->closeup_cam_zoom, 0.1F, 28.0F);
        addiu   sp,sp,-0x70

        // save current camera mode
        li      t1, Camera.camera_struct // t1 = camera_mode_save address
        lw      t0, 0x4(t1)              // load current camera mode
        li      t1, camera_mode_save     // t1 = camera_mode_save address
        sb      t0, 0x0000(t1)           // save camera mode value

        or      a1, r0, r0
        or      a2, r0, r0
        li      a3, 0x44FA0000              // Dist = 2000

        li      t0, 0x3DCCCCCD
        sw      t0, 0x0010(sp)              // argument 4

        li      t0, 0x41E00000
        sw      t0, 0x0014(sp)              // argument 5

        // set camera mode to 1 = training mode zoomed-in mode
        jal     0x8010CF44
        nop

        addiu   sp,sp,0x70

        // gPlayerCommonInterface.is_ifmagnify_display = FALSE;
        // set magnify display to 0 (don't show offscreen characters during zoom)
        lui     t1, 0x8013                      // t1 = ram location
        sb      r0, 0x1580(t1)                  // set magnifying glass value to FALSE

        set_camera_zoom_in_mode_end:

        lli     t0, ZOOM_DURATION
        li      t1, zoom_timer     // t1 = zoom_timer address
        sw      t0, 0x0000(t1)     // update zoom timer

        // Hide stage
        hide_stage:
        lw      t0, 0x4(sp) // load flag value
        lli     t1, 0x1
        bne     t0, t1, hide_stage_end // if not = 1 (KO), don't hide the stage
        nop

        ori     a0, r0, 0x1
        lli     a1, 0x1
        jal     temp_toggle_group_display_
        nop

        ori     a0, r0, 0x2
        lli     a1, 0x1
        jal     temp_toggle_group_display_
        nop

        FGM.play(152)
        FGM.play(187)

        hide_stage_end:
        // BG todo? reducing opacity may make this more tolerable, for now we skip GFX
        li      t6, Toggles.entry_flash_guard
        lw      t6, 0x0004(t6)         // t6 = 1 if Flash Guard is enabled
        bnez    t6, _end               // don't display background effect if Flash Guard is enabled
        nop

        // spawn gfx logic
        create_gfx: {
            // load background graphic into t6
            li      t6, Zoom.zoom_background_file
            lw      t6, 0x0(t6)

            addiu   sp,sp,-0x60

            addiu   sp, sp, -0x0030             // allocate stack space
            sw      ra, 0x0004(sp)              // save ra
            sw      a1, 0x001C(sp)              // save a1
            sw      a2, 0x0020(sp)              // save a2
            sw      s0, 0x0024(sp)              // save s0

            addiu   a0,r0,0x03F0
            or      a1,r0,r0
            addiu   a2,r0,0x000D
            jal     Render.CREATE_OBJECT_ // 0x80009968
            lui     a3,0x8000

            li      t6, Zoom.zoom_background_object
            sw      v0, 0x0(t6) // save background object

            // if the object creation failed, skip the rest
            beqz    v0, _restore_registers
            nop

            // lui     t6,(UPPER + 0x1)
            // lw      t6,LOWER(t6) // original
            li      t6, Zoom.zoom_background_file
            lw      t6, 0x0(t6)

            lui     t7,0x0000
            addiu   t7,t7,0x35F8
            or      s0,v0,r0
            or      a0,v0,r0
            or      a2,r0,r0
            jal     0x8000F120
            addu    a1,t6,t7
            lui     a1,0x8001
            addiu   t8,r0,-1
            sw      t8,0x10(sp)
            addiu   a1,a1,0x4038 // RAM address of ASM for creating the display list
            or      a0,s0,r0 // object address (v0 from 0x80009968)
            addiu   a2,r0,0x5 // room
            jal     Render.DISPLAY_INIT_ // 0x80009DF4
            lui     a3,0x8000 // order

            // lui     at,0x8013
            // lwc1    f0,0x2700(at) // original
            li      at, 0x40F33333 // scale = 7.6
            mtc1    at, f0

            lui     at,0x4470
            mtc1    at,f4
            lui     at,0x43B4
            mtc1    at,f6

            lw      t1,0x74(s0) // load location vector

            lui     at,0x0
            mtc1    at,f8
            swc1    f8,0x1C(t1) // location x

            lui     at,0x0
            mtc1    at,f8
            swc1    f8,0x20(t1) // location y

            lui     at,0xC5FA // -8000
            mtc1    at,f8
            swc1    f8,0x24(t1) // location z

            // lui     t6,(UPPER + 0x1) // original
            li      t6, Zoom.zoom_background_file
            lw      t6, 0x0(t6)
            srl     t6, t6, 16
            sll     t6, t6, 16

            lui     at,0x8013

            lw      t2,0x74(s0)
            lwc1    f10,0x2704(at)


            // addiu   t7,t7,LOWER // original
            lui     t7,0x0000
            addiu   t7,0x2AA8
            // li      t7, Zoom.zoom_background_file
            // lw      t7, 0x0(t7)
            // andi    t7, t7, 0xFFFF

            swc1    f10,0x34(t2)
            lw      t3,0x74(s0)
            or      a0,s0,r0
            swc1    f0,0x40(t3) // scale x
            lw      t4,0x74(s0)
            swc1    f0,0x44(t4) // scale y
            lw      t5,0x74(s0)
            swc1    f0,0x48(t5) // scale z

            // lw      t6,LOWER(t6) // original
            li      t6, Zoom.zoom_background_file
            lw      t6, 0x0(t6)

            jal     0x8000F8F4
            addu    a1,t6,t7

            // lui     t8,(UPPER + 0x1)
            // lw      t8,LOWER(t8) // original
            li      t8, Zoom.zoom_background_file
            lw      t8, 0x0(t8)

            lui     t9,0x0000
            addiu   t9,t9,0x3700
            or      a0,s0,r0
            addiu   a2,r0,0
            jal     0x8000BE28
            addu    a1,t8,t9
            li      a1,0x8000DF34 // render routine
            or      a0,s0,r0 // object
            addiu   a2,r0,1 // room
            addiu   a3,r0,1 // group order (0-5)
            jal     Render.REGISTER_OBJECT_ROUTINE_ // 0x80008188
            addiu   sp, sp, -0x0030
            addiu   sp, sp, 0x0030

            jal     0x8000DF34
            or      a0,s0,r0 // object

            _restore_registers:
            lw      a2, 0x0020(sp)              // restore a2
            lw      a1, 0x001C(sp)              // restore a1
            lw      s0, 0x0024(sp)              // restore s0
            lw      ra, 0x0004(sp)              // restore ra
            addiu   sp, sp, 0x0030              // deallocate stack space

            addiu   sp,sp,0x60
        }

        _end:
        OS.routine_end(0x80)
    }

    scope end_zoom: {
        OS.routine_begin(0x20)

        li      at, zoom_type     // t0 = zoom_type address
        lw      at, 0x0000(at)    // t0 = zoom type
        beqz    at, _end          // if no zoom, skip
        nop

        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a0, 0x0008(sp)              // save a1
        sw      a1, 0x001C(sp)              // save a1
        sw      a2, 0x0020(sp)              // save a2
        sw      s0, 0x0024(sp)              // save s0
        sw      t6, 0x0028(sp)              // save t6
        sw      v0, 0x002C(sp)              // save v0

        // Reset camera mode
        li      t1, camera_mode_save // t1 = camera_mode_save address
        lb      a0, 0x0000(t1)       // load saved camera mode value
        jal     0x8010CEF4           // cmManager_SetCameraStatus(s32 status_id)
        nop

        _restore_zoomed_in_gobj:
        // just set the 0x44 value to the saved gobj
        li     t0, zoomed_in_gobj_save // t0 = zoomed_in_gobj_save address
        lw     t1, 0x0000(t0)           // load saved zoomed-in gobj
        li     t0, Camera.camera_struct // t0 = camera_mode_save address
        sw     t1, 0x44(t0)              // save zoomed-in gobj

        // gPlayerCommonInterface.is_ifmagnify_display = (magnify_display_save saved value);
        _restore_magnify_display:
        li      t1, magnify_display_save // t1 = magnify_display_save address
        lb      t0, 0x0000(t1)           // load magnify display value
        lui     t1, 0x8013               // t1 = ram location
        sb      t0, 0x1580(t1)           // save magnifying glass value

        // Enable stage display
        enable_stage_display:
        li      t0, zoom_type     // t0 = zoom_type address
        lw      t0, 0x0(t0)       // load flag value
        lli     t1, 0x1
        bne     t0, t1, enable_stage_display_end // if not = 1 (KO), skip
        nop

        ori     a0, r0, 0x1
        lli     a1, 0x0
        jal     temp_toggle_group_display_
        nop

        ori     a0, r0, 0x2
        lli     a1, 0x0
        jal     temp_toggle_group_display_
        nop
        enable_stage_display_end:

        li      t6, Zoom.zoom_background_object
        lw      a0, 0x0(t6) // load background object pointer address
        beqz    a0, after_destroy
        nop

        // destroy ko background
        addiu   sp, sp, -0x0020     // allocate stack space
        sw      ra, 0x0004(sp)      // save registers
        sw      t0, 0x000C(sp)      // ~
        sw      t5, 0x0010(sp)      // ~
        sw      t6, 0x0014(sp)      // ~
        sw      t8, 0x0018(sp)      // ~
        sw      v1, 0x001C(sp)      // ~
        jal     Render.DESTROY_OBJECT_             // destroy the object
        nop
        lw      ra, 0x0004(sp)      // restore registers
        lw      t0, 0x000C(sp)      // ~
        lw      t5, 0x0010(sp)      // ~
        lw      t6, 0x0014(sp)      // ~
        lw      t8, 0x0018(sp)      // ~
        lw      v1, 0x001C(sp)      // ~
        addiu   sp, sp, 0x0020      // deallocate stack space
        //

        sw      r0, 0x0(t6)

        after_destroy:
        lw      ra, 0x0004(sp)              // restore ra
        lw      a0, 0x0008(sp)              // restore a1
        lw      a1, 0x001C(sp)              // restore a1
        lw      a2, 0x0020(sp)              // restore a2
        lw      s0, 0x0024(sp)              // restore s0
        lw      t6, 0x0028(sp)              // restore t6
        lw      v0, 0x002C(sp)              // restore v0
        addiu   sp, sp, 0x0030              // allocate stack space

        li      t0, zoom_timer              // t0 = zoom_timer address
        sw      r0, 0x0000(t0)

        li      t0, zoom_type               // t0 = zoom_type address
        sw      r0, 0x0000(t0)

        _end:
        OS.routine_end(0x20)
    }

    // If the attacker is present, offset = (player XY - attacker XY) / 2.0F
    // Otherwise, offset = 0
    // This is for the zoom-in to focus in-between both players
    scope update_offset: {
        OS.routine_begin(0x20)

        jal     0x800E7ED4 // get v0 = attacker_object
        lw      a0,0xC0(sp) // original: a0(sp). a0 + 20 = C0

        beqz    v0, _reset_offset // if null, reset offset
        nop

        _set_offset:
        li      t3, zoom_offset // t3 = zoom_offset address
        lw      v0, 0x84(v0)    // v0 = attacker struct

        // X
        lw      t0, 0x0078(v0)  // t0 = attacker position vector
        lwc1    f0, 0x0000(t0)  // f0 = attacker position X

        lw      t0, 0x0078(s0)  // t0 = player position vector
        lwc1    f2, 0x0000(t0)  // f2 = player position X

        sub.s   f0, f0, f2      // f0 = (attacker_x - player_x)

        lui     t0, 0x3F00      // t0 = 0.5
        mtc1    t0, f2          // f2 = 0.5
        mul.s   f0, f0, f2      // f0 = (attacker_x - player_x) * 0.5 (divide by 2)
        nop

        swc1    f0, 0x0000(t3)  // save X offset

        // Y
        lw      t0, 0x0078(v0)  // t0 = attacker position vector
        lwc1    f0, 0x0004(t0)  // f0 = attacker position Y

        lw      t0, 0x0078(s0)  // t0 = player position vector
        lwc1    f2, 0x0004(t0)  // f2 = player position Y

        sub.s   f0, f0, f2      // f0 = (attacker_y - player_y)

        lui     t0, 0x3F00      // t0 = 0.5
        mtc1    t0, f2          // f2 = 0.5
        mul.s   f0, f0, f2      // f0 = (attacker_y - player_y) * 0.5 (divide by 2)
        nop

        swc1    f0, 0x0004(t3)  // save Y offset

        b _end
        nop

        _reset_offset:
        li      t0, zoom_offset // t0 = zoom_offset address
        sw      r0, 0x0000(t0)  // x = 0
        sw      r0, 0x0004(t0)  // y = 0

        _end:
        OS.routine_end(0x20)
    }

    // Returns v0 = 0 if no special zoom, returns 2 if we should apply special zoom
    // Using 2 as true here so it sets a unique value for later checks
    scope check_special_zoom: {
        OS.routine_begin(0x80)

        jal     0x800E7ED4 // get v0 = attacker_object
        lw      a0,0x140(sp) // original: a0(sp). a0 + 20 + 80 = 140

        beqz    v0, attacker_special_move_check_end // if null, skip
        nop

        lw      v1, 0x84(v0)    // v1 = attacker struct
        lw      t0, 0x0008(v1)  // t0 = character id
        lw      t1, 0x0024(v1)  // t1 = current action

        // if attacker is not in hitlag, skip
        // this fixes the zoom being applied when a pokémon is hitting instead of the character for example
        // and the attacker happens to be using a specific move from this list at the same time
        // Edit: this makes it so the zoom is not applied to a lower port character as characters are processed in order
        // lw      at, 0x40(v1) // at = attacker hitlag
        // beqz    at, attacker_special_move_check_end
        // nop

        ori     t2, r0, Character.id.CAPTAIN
        beq     t0, t2, attacker_special_move_captain
        nop

        ori     t2, r0, Character.id.JFALCON
        beq     t0, t2, attacker_special_move_captain
        nop

        ori     t2, r0, Character.id.GND
        beq     t0, t2, attacker_special_move_gnd
        nop

        ori     t2, r0, Character.id.JIGGLYPUFF
        beq     t0, t2, attacker_special_move_jigglypuff
        nop

        ori     t2, r0, Character.id.JPUFF
        beq     t0, t2, attacker_special_move_jigglypuff
        nop

        ori     t2, r0, Character.id.EPUFF
        beq     t0, t2, attacker_special_move_jigglypuff
        nop

        ori     t2, r0, Character.id.DK
        beq     t0, t2, attacker_special_move_dk
        nop

        ori     t2, r0, Character.id.JDK
        beq     t0, t2, attacker_special_move_dk
        nop

        ori     t2, r0, Character.id.LUIGI
        beq     t0, t2, attacker_special_move_luigi
        nop

        ori     t2, r0, Character.id.JLUIGI
        beq     t0, t2, attacker_special_move_luigi
        nop

        ori     t2, r0, Character.id.MLUIGI
        beq     t0, t2, attacker_special_move_luigi
        nop

        ori     t2, r0, Character.id.NESS
        beq     t0, t2, attacker_special_move_ness
        nop

        ori     t2, r0, Character.id.JNESS
        beq     t0, t2, attacker_special_move_ness
        nop

        ori     t2, r0, Character.id.LUCAS
        beq     t0, t2, attacker_special_move_lucas
        nop

        ori     t2, r0, Character.id.ROY
        beq     t0, t2, attacker_special_move_roy
        nop

        ori     t2, r0, Character.id.KIRBY
        beq     t0, t2, attacker_special_move_kirby
        nop

        ori     t2, r0, Character.id.JKIRBY
        beq     t0, t2, attacker_special_move_kirby
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_captain:
        lli    t0, Action.CAPTAIN.FalconPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.CAPTAIN.FalconPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_dk:
        lli    t0, Action.DK.GiantPunchFullyCharged
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.DK.GiantPunchFullyChargedAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_luigi:
        // Check if frame == 1
        // The move's strong hit is active for frame 1 only. If we're after that, skip.
        lw      t2, 0x001C(v1)                              // t2 = current animation frame
        lli     t3, 0x1                                     // t3 = 1
        bne     t2, t3, attacker_special_move_check_end     // if current frame != first frame, skip
        nop

        lli    t0, Action.LUIGI.SuperJumpPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_gnd:
        lli    t0, Ganondorf.Action.WarlockPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Ganondorf.Action.WarlockPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.UTilt
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_jigglypuff:
        lli    t0, Action.JIGGLY.Rest
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.JIGGLY.RestAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_ness:
        lli    t0, Action.NESS.PKTA
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.NESS.PKTAAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_lucas:
        lli    t0, Lucas.Action.PKTA
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Lucas.Action.PKTAAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_roy:
        lli    t0, Roy.Action.DSP_Ground_Strong_End
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Roy.Action.DSP_Air_Strong_End
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_kirby:
        lli    t0, Action.KIRBY.FalconPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.KIRBY.FalconPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.KIRBY.WarlockPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.KIRBY.WarlockPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.KIRBY.FullyChargedPunch
        beq    t0, t1, attacker_special_move_set_flag
        nop

        lli    t0, Action.KIRBY.FullyChargedPunchAir
        beq    t0, t1, attacker_special_move_set_flag
        nop

        b attacker_special_move_check_end
        nop

        attacker_special_move_set_flag:
        lli     v0, 0x2

        b   _end
        nop

        attacker_special_move_check_end:
        lli     v0, 0x0

        _end:
        OS.routine_end(0x80)
    }

    // a0 = player struct
    // Updates decisive_stock_flag
    scope CheckDecisiveStock: {
        check_no_teammates_left:
        // 0x8011388C
        // void ifPlayer_BattleStats_UpdateScoreStocks(ftStruct *fp)
        // This part checks how many players are in the current team = t4
        OS.copy_segment(0x8F08C, 0x4 * 36)

        lli     t4, 0x1
        bne     t0, t4, set_false   // continue only if there's just 1 player in this team
        sw      a3, 0x0018(sp)  // original line

        check_only_2_active_teams:
        lui     t7, 0x8013
        addiu   t7, t7, 0x17F4      // t7 = gBattlePlacement address
        lw      t7, 0x0(t7)         // t7 = gBattlePlacement value
        lli     t0, 0x1

        // gBattlePlacement = [ active_teams - 1 ]
        // Which means if gBattlePlacement == 1 there are only 2 active teams
        bne     t7, t0, set_false   // Skip if gBattlePlacement != 1
        nop

        check_player_last_stock:
        // Check if player is in their last stock
        lw      a0, 0x20(sp)        // restore a0 = player struct
        lb      t7, 0x14(a0)        // t7 = remaining stocks

        // Here, t7 holds the number of extra stocks remaining for this player
        // So if t7 == 0, it means we're on last stock
        // Manage our flag
        beqz    t7, set_true // if number of extra stocks == 0, jump
        nop

        set_false:
        li      t0, decisive_stock_flag // t0 = decisive_stock_flag address
        sw      r0, 0x0000(t0) // decisive_stock_flag = FALSE
        b       _end
        nop

        set_true:
        li      t0, decisive_stock_flag // t0 = decisive_stock_flag address
        lli     t1, 0x1
        sw      t1, 0x0000(t0)  // decisive_stock_flag = TRUE

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x20
        jr      ra
        nop
    }

    scope CheckPlayersInMatch: {
        OS.routine_begin(0x80)
        sw      t2, 0x4(sp)

        _init:
        or      v0, r0, r0              // v0 = 0 (players in match)
        or      t3, r0, r0              // t3 = 0 (loop counter)

        li      t4, Global.match_info       // ~ 0x800A50E8
        lw      t4, 0x0000(t4)              // t4 = match_info
        lb      t4, 0x0003(t4)              // t4 = match gametype (1 = time, 2 = stock, 3 = both)

        li      t0, Global.match_info       // ~ 0x800A50E8
        lw      t0, 0x0000(t0)              // t0 = match_info
        addiu   t0, t0, 0x0020              // t0 = first player match struct

        // loop
        iter_player:
        lw      at, 0x0058(t0)              // at = player pointer (if = 0, then we need to skip this port)
        beqz    at, _skip_player            // skip if value = 0
        nop

        lli     at, 0x1                 // at = 1 (time mode)
        beq     at, t4, _count_player   // If in time mode, the player is always there. Count player
        nop

        stock_match:
        lb      t2, 0x000B(t0)          // t2 = stock count
        bltz    t2, _skip_player        // if stocks <= 0, skip player
        nop

        _count_player:
        // else, count player
        addiu   v0, v0, 0x1             // count valid player

        _skip_player:
        lli     t2, 0x3                 // t2 = 3
        beq     t3, t2, _loop_end       // if t3 (loop counter) == 3, end loop

        // else, continue loop
        addiu   t3, t3, 0x1             // increment loop counter
        addiu   t0, t0, 0x0074          // t1 = next player struct pointer

        b iter_player
        nop

        _loop_end:

        _end:
        lw      t2, 0x4(sp)
        OS.routine_end(0x80)
    }

    // @ Description
    // Sets the display of a linked list of display items we call a group
    // Here, when we're hiding objects we "save" the previous display state by shifting the value to the left
    // Then when setting them to display again (restore), we just shift them to the right
    // @ Arguments
    // a0 - group id
    // a1 - hide? 1 = hide, 0 = show
    scope temp_toggle_group_display_: {
        addiu   sp, sp, -0x0014             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~

        li      t0, Render.GROUP_TABLE      // t0 = start of group head list
        sll     a0, 0x0002                  // a0 = offset in group head list
        addu    a0, t0, a0                  // a0 = address of first object's address in given group
        lw      a0, 0x0000(a0)              // a0 = first object's address in given group
        beqz    a0, _end                    // if no object, end
        nop
        _loop:

        lw      t1, 0x007C(a0)              // load current display state to t1
        // if we're setting state to hide, we shift one bit left to save the previous bit
        // to restore, we simply move it back to place
        beqz    a1, _display
        nop
        _hide:
        sll     t1, t1, 0x0010              // shift left to temporarily save
        or      t1, t1, a1                  // set the rightmost bit to 1
        b _continue
        nop
        _display:
        srl     t1, t1, 0x0010              // shift right to restore
        _continue:
        sw      t1, 0x007C(a0)              // update first object
        lw      a0, 0x0004(a0)              // a0 = next object
        bnez    a0, _loop                   // if there is another object ahead, loop
        nop

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0014              // deallocate stack space
        jr      ra
        nop
    }
}