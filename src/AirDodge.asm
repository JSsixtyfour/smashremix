
    // @ Description
    // Subroutines used by AirDodge.
    scope AirDodge {
        constant MAX_SPEED(0x42A0) // float 80.0
        constant DEFAULT_ANGLE(0x3FC90FDB) // float 1.570796 rads
        constant LANDING_FSM(0x3F000000) // float 0.5
        constant ORIGINAL_ACTION(Action.DamageLow3)

        // normal air dodge
        moveset:
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.WAIT(4)
        dw 0x38000060
        dw 0x74000003
        dw 0x58000001
        Moveset.WAIT(2)
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.AFTER(20)
        dw 0x74000001
        Moveset.WAIT(3)
        dw 0xD0003EE0
        Moveset.END()

        // neutral air dodge
        neutral_moveset:
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.WAIT(4)
        dw 0x38000060
        dw 0x74000003
        dw 0x58000001
        Moveset.WAIT(2)
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.AFTER(28)
        dw 0x74000001
        Moveset.WAIT(3)
        dw 0xD0003EE0
        Moveset.END()

        moveset_air_dash:
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.WAIT(4)
        dw 0x38000060
        dw 0x74000003
        dw 0x58000001
        Moveset.WAIT(2)
        dw 0x98002C00, 0x00000000, 0x00000064, 0x00640064
        Moveset.AFTER(20)
        dw 0x74000001
        Moveset.END()
        
        // @ Description
        // tracks if players can't air dodge
        // see Stamina.asm where this value is reset on hit
        air_dash_player_port_array:
        dw 0
        
        special_air_dodge_flag:
        dw 0
        
        // @ Description
        // Resets air dash boolean for this player port when grounded script occurs
        // v0 = player struct
        scope reset_air_dash_grounded_: {
            OS.patch_start(0x59C20, 0x800DE420)
            j       reset_air_dash_grounded_
            lbu     t0, 0x000D(v0)              // t0 = player port
            _return:
            OS.patch_end()
            li      t1, air_dash_player_port_array // t1 = array
            addu    t0, t1, t0                  // t0 = entry
            sb      r0, 0x0000(t0)              // set to 0
            
            jr      t7          // og line 1
            nop
            j       _return
            nop
        }

        // @ Description
        // Resets air dash boolean for this player port when initial script occurs
        // v1 = player struct
        scope reset_air_dash_initial_: {
            OS.patch_start(0x535B4, 0x800D7DB4)
            j       reset_air_dash_initial_
            lbu     t0, 0x000D(v1)              // t0 = player port
            _return:
            OS.patch_end()

            li      t1, air_dash_player_port_array // t1 = array
            addu    t0, t1, t0                  // t0 = entry
            sb      r0, 0x0000(t0)              // set to 0
            
            jr      t4                          // og line 1
            nop
            j       _return
            nop
        }

        scope TYPE {
            constant OFF(0)
            constant MELEE(1)
            constant ULTIMATE(2)
            constant AIR_DASH(3)
        }

        // @ Description
        // Hook that is placed in routine that checks if player inputs a jump
        scope airdodge_check: {
            OS.patch_start(0xBABEC, 0x801401AC)
            j       airdodge_check
            sw      a2, 0x001C(sp)      // og line 2
            _return:
            OS.patch_end()
            // a1 = player obj
            // a2 = player struct
            lhu     at, 0x01B8(a2)      // at = shield press bitmask
            ori     at, at, 0x0010      // at = shield button + R bitmask
            lh      v0, 0x01BE(a2)      // v0 = buttons pressed
            and     v0, v0, at          // check if Shield or R pressed
            beqz    v0, _normal
            lw      v0, 0x0008(a2)      // v0 = character id

            // check if toggle enabled
            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            beqz    at, _normal
            addiu   at, r0, Character.id.BOSS
            
            // master hand check
            beq     at, v0, _normal     // skip air dodge if character = MASTER HAND
            // check if not already in special fall
            lw      v0, 0x0024(a2)      // v0 = current action
            addiu   at, r0, Action.FallSpecial
            beq     v0, at, _normal     // no air dodge if in special fall
            nop
        
            _do_air_dodge:
            jal     initial_
            nop

            _exit:
            j       0x80140328          // exit jump check routine
            lw      ra, 0x0014(sp)
            
            _normal:
            jal     0x800F3794          // og line 1
            lw      a2, 0x001C(sp)      // restore a2
            j       _return
            nop
        
        }
        
        scope initial_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x001C(sp)          // ~

            lw      t0, 0x0084(a0)
            lbu     t0, 0x000D(t0)              // t0 = port
            li      t1, air_dash_player_port_array // t1 = array
            addu    t0, t1, t0              // t0 = entry
            lb      t0, 0x0000(t0)
            bnez    t0, _end_2              // branch if can't air dash
            lw      ra, 0x001C(sp)          // load ra

            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            addiu   v0, r0, TYPE.AIR_DASH
            beq     at, v0, _air_dash       // branch if air dash
            nop

            // if here, air dodge
            jal     air_dodge_initial_
            nop
            j       _end_2
            lw      ra, 0x001C(sp)          // load ra

            _air_dash:
            // check if they can even air dash
            jal     air_dash_initial_
            nop

            _end:
            lw      ra, 0x001C(sp)          // ~
            _end_2:
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }

        // @ Description
        // Initial subroutine for AirDodge.
        scope air_dodge_initial_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x001C(sp)          // ~
            sw      a0, 0x0020(sp)          // ~
            sw      s0, 0x0024(sp)          // store ra, a0, s0
            lw      s0, 0x0084(a0)          // s0 = player struct
            sw      r0, 0x0180(s0)          // reset temp variable 2
            lbu     v1, 0x018D(s0)          // v1 = fast fall flag
            ori     t6, r0, 0x0007          // t6 = bitmask (01111111)
            and     v1, v1, t6              // ~
            jal     0x800E8044              // apply turnaround
            sb      v1, 0x018D(s0)          // disable fast fall flag

            lw      a0, 0x0020(sp)          // a0 = player object
            Action.change(ORIGINAL_ACTION, -1)
            jal     0x800E0830              // unknown common subroutine
            lw      a0, 0x0020(sp)          // a0 = player object

            // take mid-air jumps away at this point
            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            addiu   t0, r0, TYPE.ULTIMATE
            beq     t0, at, _apply_air_movement // dont remove jump if ultimate air dodge
            lw      t0, 0x09C8(s0)          // t0 = attribute pointer
            lw      t0, 0x0064(t0)          // t0 = max jumps
            sb      t0, 0x0148(s0)          // jumps used = max jumps

            _apply_air_movement:
            // apply air movement for air dash
            jal     apply_air_movement_
            addiu   a0, s0, 0x0000          // arg0 = player struct
            
            // set default air dodge action routines
            lw      a0, 0x0020(sp)          // ~
            lw      s0, 0x0084(a0)          // s0 = player struct
            
            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            addiu   v0, r0, TYPE.ULTIMATE
            bne     at, v0, _normal_melee   // branch if not Ultimate
            li      at, air_dash_main_
            sw      at, 0x09D4(s0)          // update main routine (transition to idle)
            li      at, special_air_dodge_flag
            OS.read_word(special_air_dodge_flag, t0) // t0 = special air dodge flag to see if neutral
            beqz    t0, _normal_moveset     // directional moveset if special flag = 0
            nop
            li      at, neutral_moveset

            b       _continue
            nop

            _normal_melee:
            li      at, main_
            sw      at, 0x09D4(s0)          // update main routine

            _normal_moveset:
            li      at, moveset

            _continue:
            sw      at, 0x086C(s0)          // update moveset pointer
            sw      at, 0x08AC(s0)          // update moveset pointer
            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            addiu   t0, r0, TYPE.ULTIMATE
            beq     t0, at, _collision      // skip updating movement routine if ULTIMATE
            nop
            _melee_movement:
            li      at, movement_
            sw      at, 0x09E0(s0)          // update movement routine
            _collision:
            li      at, collision_
            sw      at, 0x09E4(s0)          // update collision pointer
            sw      r0, 0x09DC(s0)          // remove interrupt routine

            // write air dash boolean TRUE
            lbu     t0, 0x000D(s0)          // t0 = port
            li      t1, air_dash_player_port_array // t1 = array
            addu    t0, t1, t0              // t0 = entry
            addiu   at, r0, 1               // at = TRUE
            sb      at, 0x0000(t0)          // set flag as player did an air dash

            _end:
            lw      ra, 0x001C(sp)          // ~
            lw      s0, 0x0024(sp)          // load ra, s0
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }
        
        // @ Description
        // Initial subroutine for AirDash.
        scope air_dash_initial_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x001C(sp)          // ~
            sw      a0, 0x0020(sp)          // ~
            sw      s0, 0x0024(sp)          // store ra, a0, s0
            lw      s0, 0x0084(a0)          // s0 = player struct
            sw      r0, 0x0180(s0)          // reset temp variable 2
            lbu     v1, 0x018D(s0)          // v1 = fast fall flag
            ori     t6, r0, 0x0007          // t6 = bitmask (01111111)
            and     v1, v1, t6              // ~
            jal     0x800E8044              // apply turnaround
            sb      v1, 0x018D(s0)          // disable fast fall flag

            lw      a0, 0x0020(sp)          // a0 = player object
            Action.change(ORIGINAL_ACTION, -1)
            jal     0x800E0830              // unknown common subroutine
            lw      a0, 0x0020(sp)          // a0 = player object
            
            jal     apply_air_movement_
            addiu   a0, s0, 0x0000          // arg0 = player struct
            
            lw      a0, 0x0020(sp)          // ~
            lw      s0, 0x0084(a0)          // s0 = player struct

            // set air dash action routines
            li      at, moveset_air_dash
            sw      at, 0x086C(s0)          // update moveset pointer
            sw      at, 0x08AC(s0)          // update moveset pointer
            li      at, air_dash_main_
            sw      at, 0x09D4(s0)          // update main routine
            li      at, movement_
            sw      at, 0x09E0(s0)          // update movement routine
            li      at, collision_
            sw      at, 0x09E4(s0)          // update collision pointer

            li      at, 0x8013F9A0
            sw      at, 0x09DC(s0)          // set interrupt routine if air dash

            // write air dash boolean TRUE
            lbu     t0, 0x000D(s0)          // t0 = port
            li      t1, air_dash_player_port_array // t1 = array
            addu    t0, t1, t0              // t0 = entry
            addiu   at, r0, 1               // at = TRUE
            sb      at, 0x0000(t0)          // set flag as player did an air dash

            _end:
            lw      ra, 0x001C(sp)          // ~
            lw      s0, 0x0024(sp)          // load ra, s0
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }
        
        constant DEADZONE(10)
        
        // @ Description
        // Applies air dash movement
        // a0 = player struct
        scope apply_air_movement_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x001C(sp)          // ~
            sw      a0, 0x0020(sp)          // ~
            sw      s0, 0x0024(sp)          // store ra, a0, s0

            li      at, special_air_dodge_flag // this flag will track if player is inputting a direction air dodge or not
            sw      r0, 0x0000(at)          // set the flag to 0

            // dead zone check
            lb      t0, 0x01C2(a0)          // t0 = stick_x
            slti    t3, t0, DEADZONE        // t3 = 0 if stick_x > DEADZONE
            beqz    t3, _not_neutral        // branch if stick_x > DEADZONE
            lb      t1, 0x01C3(a0)          // t1 = stick_y
            slti    t3, t1, DEADZONE        // t3 = 0 if stick_y > DEADZONE
            beqz    t3, _not_neutral        // branch if stick_y > DEADZONE

            addiu   at, r0, -DEADZONE       // at = -DEADZONE
            blt     t0, at, _not_neutral
            nop
            addiu   at, r0, -DEADZONE       // at = -DEADZONE
            blt     t1, at, _not_neutral
            nop
            b       _default_angle
            nop

            // if here, then not neutral
            _not_neutral:
            li      at, movement_
            sw      at, 0x09E0(a0)          // update movement routine
            lw      t2, 0x0044(a0)          // t2 = direction
            multu   t0, t2                  // ~
            mflo    t0                      // t0 = stick_x * direction
            mtc1    t1, f12                 // ~
            mtc1    t0, f14                 // ~
            cvt.s.w f12, f12                // f12 = stick y
            cvt.s.w f14, f14                // f14 = stick x * direction
            mul.s   f4, f12, f12             // ~
            mul.s   f6, f14, f14             // ~
            add.s   f4, f4, f6              // ~
            sqrt.s  f4, f4                  // f4 = absolute stick input
            lui     at, MAX_SPEED           // ~
            mtc1    at, f6                  // f6 = MAX_SPEED
            c.le.s  f6, f4                  // ~
            nop                             // ~
            bc1f    _get_angle              // branch if absolute stick input =< MAX_SPEED
            nop

            // if absolute stick input > MAX_SPEED
            mov.s   f4, f6                  // f4 = MAX_SPEED

            _get_angle:
            jal     0x8001863C              // f0 = atan2(f12,f14)
            swc1    f4, 0x0018(sp)          // 0x0018(sp) = SPEED
            b       _movement               // branch to movement
            swc1    f0, 0x0B20(a0)          // store movement angle

            _default_angle:
            OS.read_word(Toggles.entry_air_dodge + 0x4, at)   // at = toggle
            addiu   v0, r0, TYPE.MELEE
            beq     at, v0, _default_angle_continue // branch if Melee
            nop
            li      at, special_air_dodge_flag
            addiu   t5, r0, 0x0001          // t5 = 1
            sw      t5, 0x0000(at)          // write flag to indicate that this is a neutral air dodge
            li      at, 0x800D9160          // default aerial movement routine
            sw      at, 0x09E0(a0)          // update movement routine
            b       _end
            nop

            _default_angle_continue:
            li      t0, DEFAULT_ANGLE       // t0 = DEFAULT_ANGLE
            sw      t0, 0x0B20(a0)          // store DEFAULT_ANGLE
            sw      r0, 0x0018(sp)          // store SPEED (0)

            _movement:
            lwc1    f4, 0x0018(sp)          // f4 = SPEED
            lui     at, 0x3F98              // ~
            mtc1    at, f6                  // f6 = 1.1875
            mul.s   f4, f4, f6              // multiply SPEED by 1.1875
            swc1    f4, 0x0018(sp)          // update SPEED
            // ultra64 cosf function
            jal     0x80035CD0              // f0 = cos(f12)
            lwc1    f12, 0x0B20(a0)         // f12 = movement angle
            lwc1    f4, 0x0018(sp)          // f4 = SPEED
            mul.s   f4, f4, f0              // f4 = x velocity (SPEED * cos(angle))
            swc1    f4, 0x0028(sp)          // 0x0028(sp) = x velocity
            // ultra64 sinf function
            jal     0x800303F0              // f0 = sin(f12)
            lwc1    f12, 0x0B20(a0)         // f12 = movement angle
            lwc1    f4, 0x0018(sp)          // f4 = SPEED
            mul.s   f4, f4, f0              // f4 = y velocity (SPEED * sin(angle))
            lwc1    f0, 0x0044(a0)          // ~
            cvt.s.w f0, f0                  // f0 = direction
            lwc1    f2, 0x0028(sp)          // f2 = x velocity
            mul.s   f2, f2, f0              // f2 = x velocity * direction
            swc1    f2, 0x0048(a0)          // store updated x velocity
            swc1    f4, 0x004C(a0)          // store updated y velocity

            _end:
            lw      ra, 0x001C(sp)          // ~
            lw      s0, 0x0024(sp)          // load ra, s0
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }

        // @ Description
        // Main subroutine for AirDodge.
        // Transitions to special fall on animation end.
        scope main_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x0024(sp)          // ~
            sw      a0, 0x0028(sp)          // store a0, ra

            // checks the current animation frame to see if we've reached end of the animation
            lw      a0, 0x0028(sp)          // a0 = player object
            lwc1    f6, 0x0078(a0)          // ~
            mtc1    r0, f4                  // ~
            c.le.s  f6, f4                  // ~
            nop
            bc1fl   _end                    // skip if animation end has not been reached
            lw      ra, 0x0024(sp)          // restore ra

            // begin a special fall if the end of the animation has been reached
            lui     a1, 0x3F80              // a1 (air speed multiplier) = 1
            or      a2, r0, r0              // a2 (unknown) = 0
            lli     a3, 0x0001              // a3 (unknown) = 1
            sw      r0, 0x0010(sp)          // unknown argument = 0
            lli     at, OS.TRUE             // ~
            sw      at, 0x0018(sp)          // interrupt flag = TRUE
            li      t6, LANDING_FSM         // t6 = LANDING_FSM
            jal     0x801438F0              // begin special fall
            sw      t6, 0x0014(sp)          // store LANDING_FSM
            lw      ra, 0x0024(sp)          // restore ra

            _end:
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }

        // @ Description
        // Main subroutine for AirDodge.
        // Transitions to special fall on animation end.
        scope air_dash_main_: {
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      ra, 0x0024(sp)          // ~
            sw      a0, 0x0028(sp)          // store a0, ra

            // checks the current animation frame to see if we've reached end of the animation
            lw      a0, 0x0028(sp)          // a0 = player object
            lwc1    f6, 0x0078(a0)          // ~
            mtc1    r0, f4                  // ~
            c.le.s  f6, f4                  // ~
            nop
            bc1fl   _end                    // skip if animation end has not been reached
            lw      ra, 0x0024(sp)          // restore ra

            // begin a special fall if the end of the animation has been reached
            lui     a1, 0x3F80              // a1 (air speed multiplier) = 1
            or      a2, r0, r0              // a2 (unknown) = 0
            lli     a3, 0x0001              // a3 (unknown) = 1
            sw      r0, 0x0010(sp)          // unknown argument = 0
            lli     at, OS.TRUE             // ~
            sw      at, 0x0018(sp)          // interrupt flag = TRUE
            li      t6, LANDING_FSM         // t6 = LANDING_FSM
            jal     0x800DEE54                  // transition to idle
            sw      t6, 0x0014(sp)          // store LANDING_FSM
            lw      ra, 0x0024(sp)          // restore ra

            _end:
            jr      ra                      // return
            addiu   sp, sp, 0x0040          // deallocate stack space
        }

        // @ Description
        // Movement subroutine for AirDodge.
        scope movement_: {
            // 0x180 in player struct = temp variable 2
            addiu   sp, sp,-0x0030          // allocate stack space
            sw    	ra, 0x0014(sp)          // ra
            lw      t0, 0x0084(a0)          // t0 = player struct
            lw      t1, 0x0180(t0)          // t1 = temp variable 2
            beqz    t1, _end                // skip if temp variable 2 = 0
            nop

            _apply_drag:
            lui     at, 0x3F60              // ~
            mtc1    at, f2                  // f2 = 0.875
            lwc1    f4, 0x0048(t0)          // f4 = x velocity
            lwc1    f6, 0x004C(t0)          // f6 = y velocity
            mul.s   f4, f4, f2              // ~
            mul.s   f6, f6, f2              // ~
            swc1    f4, 0x0048(t0)          // ~
            swc1    f6, 0x004C(t0)          // multiply x/y velocity by 0.90625
            b       _end                    // end subroutine
            nop

            _end:
            lw      ra, 0x0014(sp)          //  ra
            jr      ra                      // return
            addiu 	sp, sp, 0x0030          // deallocate stack space
        }

        // @ Description
        // Collision subroutine for AirDodge.
        scope collision_: {
            addiu   sp, sp,-0x0018          // allocate stack space
            sw      ra, 0x0014(sp)          // store ra
            li      a1, begin_landing_      // a1(transition subroutine) = ground_charge_transition_
            jal     0x800DE6E4              // common air collision subroutine (transition on landing, no ledge grab)
            nop
            lw      ra, 0x0014(sp)          // load ra
            jr      ra                      // return
            addiu   sp, sp, 0x0018          // deallocate stack space
        }

        // @ Description
        // Subroutine which transitions into landing for AirDodge.
        scope begin_landing_: {
            addiu   sp, sp,-0x0018          // allocate stack space
            sw      ra, 0x0014(sp)          // store ra
            lli     a1, OS.TRUE             // interrupt flag = TRUE
            li      a2, LANDING_FSM         // a2 = LANDING_FSM
            jal     0x80142E3C              // begin landing animation
            nop
            lw      ra, 0x0014(sp)          // load ra
            jr      ra                      // return
            addiu   sp, sp, 0x0018          // deallocate stack space
        }
    }
