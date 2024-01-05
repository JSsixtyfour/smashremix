
scope FootStool {

    // @ Description
    // dont reset jumps if jumping during jump squat
    scope num_jumps_no_reset: {
        OS.patch_start(0x5A6E4, 0x800DEEE4)
        j       num_jumps_no_reset
        lwc1    f6, 0x0024(t8)      // og line 1
        _return:
        OS.patch_end()
        
        lw      at, 0x9E4(a0)       // load current routine
        li      t0, footstool_air_collision_
        bne     at, t0, _normal     // branch if doing a normal jump
        nop
        
        // if here, footstooling opponent
        j       _return
        nop
        
        _normal:
        j       _return
        sb      t9, 0x0148(a0)      // og line 2 (reset num jumps)
    }
    // @ Description
    // if here, then player pressed JUMP while aerial
    scope aerial_jump_check: {
        OS.patch_start(0xBAD48, 0x80140308)
        jal     aerial_jump_check
        nop
        OS.patch_end()

        // at = 1 if valid jump
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0018(sp)
        sw      a1, 0x0010(sp)
        sw      at, 0x0014(sp)              // save argument

        jal     FootStool.foot_stool_check_
        lw      a0, 0x0004(a0)

        beqz    v0, _continue
        nop

        addiu   sp, sp, 0x0050
        j       0x80140324                  // if footstool jumped
        addiu   v0, r0, 0x0001

        _continue:
        lw      at, 0x0014(sp)              // save argument
        beqzl   at, _no_jump                // no jump if none left
        or      v0, r0, r0                  // return 0 (no jump button pressed)

        lw      ra, 0x001C(sp)
        lw      a0, 0x0018(sp)
        lw      a1, 0x0010(sp)
        jr      ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        
        _no_jump:
        j       0x80140324
        addiu   sp, sp, 0x0050
        
    }
    // @ Description
    // if here, then character is performing a mid-air jump
    scope foot_stool_check_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        OS.read_word(Toggles.entry_footstool + 0x4, at)   // at = footstool toggle
        beqzl   at, _end_2
        addiu   v0, r0, 0                   // return 0
        // save registers if here
        sw      s1, 0x0024(sp)              // ~
        sw      a0, 0x0018(sp)
        sw      a1, 0x0010(sp)              // save jump type
        sw      a2, 0x0014(sp)              // save a2
        sw      r0, 0x0030(sp)              // clear values
        sw      r0, 0x0034(sp)              // clear values
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      v0, 0x0020(sp)              // save player struct to sp

        lw      t0, 0x0024(v0)              // t0 = current action
        addiu   at, r0, Action.FallSpecial  // no footstool
        beql    t0, at, _end
        addiu   v0, r0, 0                   // return 0

        li      s1, 0x800466FC              // s1 = player object head
        lw      s1, 0x0000(s1)              // s1 = first player object

        // a1 = player object
        addiu   a1, a0, 0                   // a1 = player object
        _player_loop:
        beqz    s1, _player_loop_exit       // exit loop when s1 no longer holds an object pointer
        nop
        beql    s1, a1, _player_loop        // loop if current player and target object match...
        lw      s1, 0x0004(s1)              // ...and load next object into s1

        _team_check:
        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t0 = match info struct
        lbu     t1, 0x0002(t0)              // t1 = team battle flag
        beqz    t1, _action_check           // branch if team battle flag = FALSE
        lbu     t1, 0x0009(t0)              // t1 = team attack flag
        bnez    t1, _action_check           // branch if team attack flag != FALSE
        nop
        // if the match is a team battle with team attack disabled
        lw      t0, 0x0084(s1)              // t0 = target player struct
        lbu     t0, 0x000C(t0)              // t0 = target team
        lbu     t1, 0x000C(a1)              // t1 = player team
        beq     t0, t1, _player_loop_end    // skip if player and target are on the same team
        nop

        _action_check:
        lw      t0, 0x0084(s1)              // t0 = target player struct
        lw      t0, 0x0024(t0)              // t0 = target player action
        sltiu   at, t0, 0x0007              // at = 1 if action id < 7, else at = 0
        bnez    at, _player_loop_end        // skip if target action id < 7 (target is in a KO action)
        nop

        _target_check:
        lw      a0, 0x0020(sp)              // a0 = player
        lw      a1, 0x0074(s1)              // a1 = target top joint struct
        addiu   a3, sp, 0x0030              // a3 = target storage addr
        jal     check_target_               // check_target_
        or      a2, s1, r0                  // a2 = target object struct
        beqz    v0, _player_loop_end        // branch if no new target
        nop

        // if check_target_ returned a new valid target
        sw      v0, 0x0030(sp)              // store target object
        sw      v1, 0x0034(sp)              // store target X_DIFF

        _player_loop_end:
        lw      a0, 0x0020(sp)              // a0 = jumping player struct
        lw      a1, 0x0004(a0)              // a1 = jumping player object
        b       _player_loop                // loop
        lw      s1, 0x0004(s1)              // s1 = next object

        _player_loop_exit:
        lw      t0, 0x0030(sp)              // t0 = target object
        beqz    t0, _end
        addiu   v0, r0, 0                   // return 0

        // footstool activate
        lw      a0, 0x0020(sp)              // a0 = jumping player struct
        // lli     at, 0x0001
        // sb      at, 0x0148(a0)           // set current jumps to 1
        addiu   a0, t0, 0x0000              // a0 = player object

        jal     foot_stool_initial_         // sets victim into foot stool'd state
        addiu   a0, t0, 0x0000              // a0 = victim player object

        lw      a0, 0x0020(sp)              // a0 = jumping player struct
        lw      a1, 0x0010(sp)              // load jump type
        jal     foot_stool_jump_initial_    // make footstool player jump
        lw      a0, 0x0004(a0)              // a0 = jumping player object
        addiu   v0, r0, 0x0001

        _end:
        lw      a1, 0x0010(sp)              // load jump type
        lw      a0, 0x0018(sp)
        lw      a2, 0x0014(sp)              // load a2
        lw      s1, 0x0024(sp)              // ~
        _end_2:
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space

    }

    // @ Description
    // Checks if target is in range
    // a0 - footstooling player
    // a1 - target top joint struct
    // a2 - target object struct
    // a3 - stackspace address for known targets
    // returns
    // v0 - target object (NULL when no valid target)
    // v1 - target X_DIFF
    scope check_target_: {
        lw      t8, 0x0004(a0)              // t8 = footstooling player object
        // MASTER HAND CHECK
        lw      v1, 0x0004(a1)              // v1 = footstooled player obj
        lw      v1, 0x0084(v1)              // v1 = footstooled player struct
        lw      v0, 0x0008(v1)              // v0 = character ID
        addiu   at, r0, 0x000C              // at = MASTER HAND
        beql    at, v0, _end                // branch if Master hand
        or      v0, r0, r0                  // return 0 (no footstool)
        
        // ACTION CHECK
        lw      v0, 0x0024(v1)              // v0 = current action
        addiu   at, r0, Action.LandingHeavy // at = Action.LandingHeavy id
        beql    at, v0, _end                // branch if already in heavy land animation
        or      v0, r0, r0                  // return 0 (no footstool)

        // INVULNERABLE/INTANGIBILITY CHECK
        lw      t9, 0x05A4(v1)              // check if player is invulnerable from spawning
        bnezl   t9, _end                    // skip this player if they are still spawning
        or      v0, r0, r0                  // return 0 (no footstool)
        lw      t9, 0x05B0(v1)              // v0 = super star counter
        bnezl   t9, _end                    // skip this player if they are using a super star
        or      v0, r0, r0                  // return 0 (no footstool)
        addiu   at, r0, 3                   // at = intangible
        lw      t9, 0x05B8(v1)              // v0 = super star counter
        beql    at, t9, _end                // branch if already in heavy land animation
        or      v0, r0, r0                  // return 0 (no footstool)
        
        li      t9, footstooled_main        // t9 = footstooled interrupt routine
        lw      at, 0x09E4(v1)              // get interrupt routine
        beql    at, t9, _end                // branch if already footstooled
        or      v0, r0, r0                  // return 0 (no footstool)

        lw      at, 0x0074(t8)              // ~
        addiu   t8, at, 0x001C              // ~
        addiu   t9, a1, 0x001C              // t9 = target x/y/z coordinates

        // check if the target is within x range
        
        lw      at, 0x0084(a2)              // first get size multiplier
        lbu     at, 0x000D(at)              // at = player port
        li      v0, Size.multiplier_table
        sll     at, at, 2
        addu    at, v0, at
        lwc1    f14, 0x0000(at)             // f14 = entry in size multiplier table
        
        mtc1    r0, f0                      // f0 = 0
        lwc1    f2, 0x0000(t8)              // f2 = player x coordinate
        lwc1    f4, 0x0000(t9)              // f4 = target x coordinate
        sub.s   f10, f2, f4                 // f10 = X_DIFF (target x - player x)
        abs.s   f10, f10                    // f10 = absolute X diff
        lw      at, 0x09C8(v1)              // get players attributes pointer
        lw      at, 0x00A8(at)              // get BB width
        mtc1    at, f8                      // f8 = ^
        nop
        mul.s   f8, f8, f14                 // multiply BB width by size multiplier
        nop
        c.le.s  f10, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if MIN_X_RANGE =< X_DIFF
        or      v0, r0, r0                  // return 0 (no footstool)
        c.le.s  f0, f10                      // ~
        nop                                 // ~
        bc1fl   _end                        // end if X_DIFF =< 0
        or      v0, r0, r0                  // return 0 (no footstool)

        // check if there is a previous target
        lw      t0, 0x0000(a3)              // t0 = current target
        beq     t0, r0, _check_y            // branch if there is no current target
        lwc1    f8, 0x0004(a3)              // f8 = current target X_DIFF

        // compare X_DIFF to see if the previous target was within closer x proximity
        c.le.s  f10, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if prev X_DIFF =< current X_DIFF
        or      v0, r0, r0                  // return 0 (no footstool)

        _check_y:
        lwc1    f2, 0x0004(t8)              // f2 = player y coordinate
        lwc1    f4, 0x0004(t9)              // f4 = target y coordinate
        c.le.s  f4, f2                      // check if player is under target
        nop
        bc1fl   _end                        // end if player.y < target.y
        or      v0, r0, r0                  // return 0 (no footstool)
        sub.s   f12, f2, f4                 // f12 = Y_DIFF (target y - player y)
        lw      v0, 0x09C8(v1)              // get players attributes pointer
        lw      at, 0x009C(v0)              // get BB upper Y
        mtc1    at, f8                      // f8 = upper Y
        nop
        mul.s   f8, f8, f14                 // multiply BB width by size multiplier
        nop
        lui     t0, 0x3F00
        mtc1    t0, f6                      // f6 = 0.5
        mul.s   f6, f8, f6                  // f6 = height * 0.5
        nop
        add.s   f8, f8, f6                  // f8 = height + (height * 0.5)
        nop
        c.le.s  f12, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if Y_RANGE =< targets top y coord
        or      v0, r0, r0                  // return 0
        
        // see if above EBC height / 5
        lui     at, 0x3E4C                  // at = 0.2
        mtc1    at, f6                      // f6 = 0.2
        mul.s   f8, f8, f6                  // f8 = target upper y coord / 2
        c.le.s  f8, f12                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if Y_RANGE < targets middle y coord
        or      v0, r0, r0                  // return 0

        // if we're here then the target is the closest within range
        or      v0, a2, r0                  // v0 = target object
        mfc1    v1, f10                     // v1 = X_DIFF

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // The footstoolers initial routine
    // a0 = player obj
    scope foot_stool_jump_initial_: {
        addiu   sp, sp,-0x0030              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      a1, 0x002C(sp)              // ~
        lw      s0, 0x0084(a0)              // s0 = player struct

        // change player action to jumpsquat
        Action.change(Action.JumpSquat, -1)
        
        // change air collision routine so player stays aerial
        lw      a0, 0x0028(sp)              // a0 = jumping player object
        lw      a0, 0x0084(a0)              // a0 = jumping player struct
        li      at, footstool_air_collision_
        sw      at, 0x09E4(a0)              // overwrite air collision routine
        sw      r0, 0x09DC(a0)              // remove interrupt routine

        // copied logic from original jumpsquat setup
        lw      v0, 0x0028(sp)              // v0 = jumping player object
        lw      v0, 0x0084(v0)              // v0 = jumping player struct
        mtc1    r0, f8
        lb      t6, 0x01c3(v0)
        lbu     t9, 0x0192(v0)
        swc1    f8, 0x0b1c(v0)
        mtc1    t6, f4
        ori     t0, t9, 0x0080
        cvt.s.w f6, f4
        swc1    f6, 0x0b18(v0)
        lw      t7, 0x002C(sp)
        sw      r0, 0x0b24(v0)
        sb      t0, 0x0192(v0)
        sw      t7, 0x0b20(v0)
        
        // play funny sfx
        FGM.play(0x04B0)                    // play footstool FGM
        
        lw      ra, 0x0024(sp)
        lw      s0, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x30
    }

    constant FOOTSTOOL_FALL_SPEED(0xC1C8)   // player getting footstooled
    constant FOOTSTOOL_FSM(0x3F00)          // float 0.5 frame speed multiplier

    // @ Description
    // The footstool victims initial routine
    scope foot_stool_initial_: {
        addiu   sp, sp,-0x0030              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        lw      s0, 0x0084(a0)              // original logic

        lli     t9, Action.LandingSpecial
        lw      v1, 0x0024(s0)              // v1 = current action
        blt     v1, t9, _continue           // skip if current action > Action.LandingSpecial
        nop
        
        // if here, then action id > Action.LandingSpecial
        _kirby_check:
        lw      v0, 0x0008(s0)              // v0 = character id
        addiu   at, r0, Character.id.KIRBY
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.JKIRBY
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.NKIRBY
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.PUFF
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.JPUFF
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.EPUFF
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.NPUFF
        beq     v0, at, _kirby_puff_dedede_jump_check
        addiu   at, r0, Character.id.DEDEDE
        beq     v0, at, _kirby_puff_dedede_jump_check
        nop
        // TODO: polygon Dedede if added
        // addiu   at, r0, Character.id.NDEDEDE
        // beq     v0, at, _kirby_puff_dedede_jump_check
        b       _end
        addiu   v0, r0, r0
        
        _kirby_puff_dedede_jump_check:      // allows kirby to be footstooled when in their aerial jumping actions
        // v1 = current action
        slti    at, v1, Action.KIRBY.Jump2  // at = 0 if action id => Jump2
        bnez    at, _end                    // branch if action id < Jump2
        slti    at, v1, Action.KIRBY.Jump6 + 1  // at = 0 if action id > Jump6
        beqz    at, _end
        addiu   v0, r0, r0

        _continue:
        lli     t9, Action.Idle
        blt     v1, t9, _end                // skip if player is reviving
        nop

        lui     at, FOOTSTOOL_FALL_SPEED    //
        sw      at, 0x004C(s0)              // save new y velocity

        lw      at, 0x148(s0)               // at = kinetic state
        beqz    at, _branch                 // branch if grounded
        // this | grounded
        addiu   a1, r0, Action.LandingHeavy // action id = heavy landing
        // or | aerial
        addiu   a1, r0, Action.Tumble       // action id = tumble
        _branch:
        addiu   a2, r0, 0x0000              // a2 = set starting frame
        sw      r0, 0x0010(sp)              // argument 4 = 0 (idk what this is)
        jal     0x800E6F24                  // change action
        lui     a3, FOOTSTOOL_FSM           // animation speed = FOOTSTOOL_FSM

        lw      v0, 0x0028(sp)              // load player object
        lw      v0, 0x0084(v0)              // load player struct
        lw      at, 0x148(v0)               // at = kinetic state
        beqz    at, _end                    // branch to end if grounded

        // manually override routines here
        li      at, footstooled_main
        sw      at, 0x09E4(v0)              // overwrite interrupt routine
        li      at, footstooled_main_2
        sw      at, 0x09DC(v0)              // overwrite interrupt routine

        _end:
        lw      ra, 0x0024(sp)
        lw      s0, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x30
    }

   // @ Description
   // Subroutine which handles air collision for footstool jumpsquat
    scope footstool_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, footstool_air_to_ground_// a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }
    
    // @ Description
    // Subroutine which handles ground to air transition for footstool jumpsquat
    scope footstool_air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a1, r0, Action.JumpSquat    // a1 = equivalent ground action for current air action
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }
    
    // @ Description
    // Aerial. based on 0x801435B0, no teching allowed!
    scope footstooled_main: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001c(sp)
        sw      s0, 0x0018(sp)
        lw      t6, 0x0084(a0)
        or      s0, a0, r0
        jal     0x800de7d8
        sw      t6, 0x0024(sp)
        beqz    v0, _end_1
        nop
        lw      t7, 0x0024(sp)      // t7 = player struct
        lhu     t8, 0x00D2(t7)      // get button?
        andi    t9, t8, 0x3000
        beqz    t9, b1              // branch if no ledge collision
        nop

        //jal     0x80144C24          // ledge grab routine if here
        //or      a0, s0, r0
        b       _end_2
        lw      ra, 0x001C(sp)

        b1:
        // jal     0x80144760          // landing/tech routine?
        // or      a0, s0, r0
        // bnezl   v0, _end_2
        // lw      ra, 0x001C(sp)
        // jal     0x801446bc
        // or      a0, s0, r0
        // bnezl   v0, _end_2
        // lw      ra, 0x001C(sp)
        jal     0x80144498
        or      a0, s0, r0
        _end_1:
        lw      ra, 0x001C(sp)

        _end_2:
        lw      s0, 0x0018(sp)
        jr      ra
        addiu   sp, sp, 0x28
    }
    
    constant FOOTSTOOLED_JUMP_DELAY(40)    // 40 frames until footstooled player can jump from tumble

    // @ Description
    // Aerial. goes over 0x9DC in player struct
    scope footstooled_main_2: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001C(sp)
        sw      a0, 0x0018(sp)      // save player obj

        lw      v0, 0x0084(a0)      // v0 = player struct
        lw      v1, 0x001C(v0)      // v1 = num frames in tumble state
        slti    v1, v1, FOOTSTOOLED_JUMP_DELAY  // v1 = 0 if allowed to jump
        bnez    v1, _end
        nop
        
        jal     0x80143560          // original routine
        nop
        _end:
        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x028
    }
    
    scope kirby_jump_aerial_1_check: {
        OS.patch_start(0xBAC60, 0x80140220)
        jal     kirby_jump_aerial_1_check
        nop
        OS.patch_end()
        addiu   sp, sp, -0x28
        sw      a0, 0x001C(sp)
        sw      a1, 0x0020(sp)
        sw      ra, 0x0024(sp)

        jal     FootStool.foot_stool_check_
        lw      a0, 0x0004(a0)

        bnez    v0, _no_jump
        nop
        lw      a0, 0x001C(sp)
        lw      a0, 0x0004(a0)
        jal     0x8013FF38              // og line 1
        lw      a0, 0x0048(sp)          // og line 2 (modified)

        _no_jump:
        lw      a0, 0x001C(sp)
        lw      a1, 0x0020(sp)
        lw      ra, 0x0024(sp)
        jr      ra
        addiu   sp, sp, 0x028
        
    }
    
    scope kirby_jump_aerial_2_check: {
        OS.patch_start(0xBACCC, 0x8014028C)
        jal     kirby_jump_aerial_2_check
        nop
        OS.patch_end()
        addiu   sp, sp, -0x28
        sw      a0, 0x001C(sp)
        sw      a1, 0x0020(sp)
        sw      ra, 0x0024(sp)

        jal     FootStool.foot_stool_check_
        lw      a0, 0x0004(a0)

        bnez    v0, _no_jump
        nop
        lw      a0, 0x001C(sp)
        lw      a0, 0x0004(a0)
        jal     0x8013FF38              // og line 1
        lw      a0, 0x0048(sp)          // og line 2 (modified)

        _no_jump:
        lw      a0, 0x001C(sp)
        lw      a1, 0x0020(sp)
        lw      ra, 0x0024(sp)
        jr      ra
        addiu   sp, sp, 0x028
        
    }

    scope puff_jump_aerial_2_check: {
        OS.patch_start(0xBAD10, 0x801402D0)
        jal     puff_jump_aerial_2_check
        nop
        OS.patch_end()
        addiu   sp, sp, -0x28
        sw      a0, 0x001C(sp)
        sw      a1, 0x0020(sp)
        sw      ra, 0x0024(sp)

        jal     FootStool.foot_stool_check_
        lw      a0, 0x0004(a0)

        bnez    v0, _no_jump
        nop
        lw      a0, 0x001C(sp)
        lw      a0, 0x0004(a0)
        jal     0x8013FF38              // og line 1
        lw      a0, 0x0048(sp)          // og line 2 (modified)

        _no_jump:
        lw      a0, 0x001C(sp)
        lw      a1, 0x0020(sp)
        lw      ra, 0x0024(sp)
        jr      ra
        addiu   sp, sp, 0x028
    }
    
}