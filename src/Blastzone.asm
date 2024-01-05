scope BlastZone: {

    // a0 = player obj
    scope set_aerial_from_grounded: {
        OS.routine_begin(0x30)
        sw      a0, 0x0020(sp)
        lw      v1, 0x0084(a0)      // v1 = player struct
        lw      v0, 0x09E4(v1)      // run player collision routine
        beqz    v0, _end
        nop
        jalr    v0
        nop
        _end:
        // jal     0x8013F9E0      // set aerial idle (used this before but crashes with barrels/crates)
        OS.routine_end(0x30)
    }

    // shared grab release check and ledge release check
    // a0 = player struct
    scope grab_release_check_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0020(sp)
        lw      v1, 0x840(a0)          // v1 = obj of captured player
        bnezl    v1, _release_player
        lw      a0, 0x0004(a0)          // a0 = player obj
        
        lw      a0, 0x844(a0)          // v1 = obj of capturing player
        beqz    a0, _ledge_check
        nop

        _release_player:
        jal     0x80149AC8                        // grab release
        nop
        
        b       _end
        nop
        
        _ledge_check:
        // make sure a player that is grabbing a ledge is released from it
        lw      a0, 0x0020(sp)          // restore player obj
        lw      v1, 0x0024(a0)          // current action
        slti    v0, v1, Action.CliffEscapeSlow2 // v0 = 0 if not grabbing ledge
        beqz    v0, _end
        nop
        addiu   at, r0, Action.CliffCatch
        blt     v1, at, _end            // branch if not hanging from ledge
        nop

        // if here, release from ledge
        jal     0x8013F9E0          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        _end:
        lw      a0, 0x0020(sp)

        OS.routine_end(0x30)
    }

    // skip bottom blast zone sound
    scope skip_bottom_blast_sfx: {
        OS.patch_start(0x5DB4C, 0x800E234C)
        j       skip_bottom_blast_sfx
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 2
        bnez    at, _skip           // skip sfx if blast zone top/bottom enabled
        nop

        jal     0x800269C0          // og line 1
        addiu   a0, r0, 0x0099      // og line 2

        _skip:
        j       _return
        nop

    }
    // hook over routine that KOS players on right side of screen
    scope loop_screen_right_: {
        OS.patch_start(0xB78DC, 0x8013CE9C)
        j        loop_screen_right_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 1
        beqz    at, _KO
        nop

        // get left blast zone
        lh      t9, 0x007A(v1)
        mtc1    t9, f10
        nop
        cvt.s.w f16, f10
        nop

        lw      t8, 0x0074(a0)      // t8 = player location struct
        swc1    f16, 0x001C(t8)     // update player x in location struct
        swc1    f16, 0x0000(a2)     // update player x in player struct

        jal     grab_release_check_
        addiu   a0, s1, 0           // a0 = player struct

        addiu   t8, s1, 0           // t8 = player struct
        lw      t9, 0x014C(t8)      // t9 = kinetic state
        bnez    t9, _skip_KO        // branch if aerial
        nop

        // if here, grounded
        lw      a1, 0x0004(s1)
        //jal     0x800DE45C          // update clipping under player if grounded
        //addiu   a0, t8, 0x0078
        jal     set_aerial_from_grounded          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        _skip_KO:
        j       0x8013CF44          // skip KO routine entirely
        nop

        _KO:
        jal     0x8013C30C          // original line - KO player (right blast zone)
        nop

        _end:
        j       _return
        nop
    }

    scope loop_screen_left_: {
        OS.patch_start(0xB790C,0x8013CECC)
        j        loop_screen_left_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 1
        beqz    at, _KO
        nop

        lw      t8, 0x0074(a0)      // t8 = player location struct
        swc1    f8, 0x001C(t8)      // update player x in location struct
        swc1    f8, 0x0000(a2)      // update player x in player struct

        jal     grab_release_check_
        addiu   a0, s1, 0           // a0 = player struct
        
        addiu   t8, s1, 0           // t8 = player struct
        lw      t9, 0x014C(t8)      // t9 = kinetic state
        bnez    t9, _skip_KO        // branch if aerial
        nop

        // if here, grounded

        lw      a1, 0x0004(s1)
        //jal     0x800DE45C          // update clipping under player if grounded
        //addiu   a0, t8, 0x0078
        jal     set_aerial_from_grounded          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        _skip_KO:
        j        0x8013CF44         // skip KO routine entirely
        nop

        _KO:
        jal        0x8013C454       // original line - KO player (left blast zone)
        nop

        _end:
        j        _return
        nop
    }

    // hook over routine that KOS players on top side of screen
    scope loop_screen_top_1_: {
        OS.patch_start(0xB7960, 0x8013CF20)
        j        loop_screen_top_1_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 2
        beqz    at, _KO
        nop

        // get bottom blast zone
        lui     v1, 0x8013
        lw      v1, 0x1300(v1)
        lh      t0, 0x0076(v1)
        mtc1    t0, f18
        cvt.s.w f4, f18
        swc1    f4, 0x0004(a2)          // overwrite players y coordinate
        lw      t0, 0x0004(s1)          // t0 = player obj
        lw      t0, 0x0074(t0)          // = location struct
        swc1    f4, 0x0020(t0)          // overwrite players y coordinate

        jal     grab_release_check_
        addiu   a0, s1, 0           // a0 = player struct

        addiu   t8, s1, 0           // t8 = player struct
        lw      t9, 0x014C(t8)      // t9 = kinetic state
        bnez    t9, _skip_KO        // branch if aerial
        nop

        // if here, grounded
        lw      a1, 0x0004(s1)
        //jal     0x800DE45C          // update clipping under player if grounded
        //addiu   a0, t8, 0x0078
        jal     set_aerial_from_grounded          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        _skip_KO:
        j        0x8013CF44             // skip KO routine entirely
        nop

        _KO:
        jal      0x8013CAAC             // original line - KO player
        nop

        _end:
        j        _return
        nop
    }

    // hook over routine that KOS players on top side of screen
    scope loop_screen_top_2_: {
        OS.patch_start(0xB7970, 0x8013CF30)
        j        loop_screen_top_2_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 2
        beqz    at, _KO
        nop

        // get bottom blast zone
        lui     v1, 0x8013
        lw      v1, 0x1300(v1)
        lh      t0, 0x0076(v1)
        mtc1    t0, f18
        cvt.s.w f4, f18
        swc1    f4, 0x0004(a2)          // overwrite players y coordinate
        lw      t0, 0x0004(s1)          // t0 = player obj
        lw      t0, 0x0074(t0)          // = location struct
        swc1    f4, 0x0020(t0)          // overwrite players y coordinate
        
        jal     grab_release_check_
        addiu   a0, s1, 0           // a0 = player struct

        addiu   t8, s1, 0           // t8 = player struct
        lw      t9, 0x014C(t8)      // t9 = kinetic state
        bnez    t9, _skip_KO        // branch if aerial
        nop

        // if here, grounded
        lw      a1, 0x0004(s1)
        //jal     0x800DE45C          // update clipping under player if grounded
        //addiu   a0, t8, 0x0078
        jal     set_aerial_from_grounded          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        _skip_KO:
        j        0x8013CF44             // skip KO routine entirely
        nop

        _KO:
        jal      0x8013C740             // original line - KO player (right blast zone)
        nop

        _end:
        j        _return
        nop
    }


    // hook before player is KO'd at bottom blast zone
    scope loop_screen_bottom_: {
        OS.patch_start(0xB78A8,0x8013CE68)
        j        loop_screen_bottom_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_blastzone_warp, at)      // at = toggle
        andi    at, at, 2
        beqz    at, _KO
        nop

        // get top blast zone
        lh      t0, 0x0074(v1)
        mtc1    t0, f18
        cvt.s.w f4, f18
        swc1    f4, 0x0004(a2)                    // overwrite players y coordinate
        lw      t0, 0x0004(s1)                    // t0 = player obj
        lw      t0, 0x0074(t0)                    // = location struct
        swc1    f4, 0x0020(t0)                    // overwrite players y coordinate

        addiu   sp, sp, -0x0028                   // allocate stack space
        sw      a1, 0x0004(sp)                    // save registers
        sw      a2, 0x0008(sp)                    // ~
        sw      a3, 0x000C(sp)                    // ~
        sw      v0, 0x0014(sp)                    // ~

        // s1 = player struct, a0 = player obj
        // check if we're in an action that would get us stuck, and change once enough frames have elapsed
        addiu   a1, r0, Action.Fall               // a1 = action to change to
        lw      v0, 0x0024(s1)                    // v0 = players current action

        lw      a3, 0x0008(s1)                    // a3 = character id
        lli     a2, Character.id.YOSHI            // ~
        bne     a3, a2, pc() + 12                 // ~
        addiu   at, r0, Action.YOSHI.GroundPoundDrop
        beq     v0, at, _check_frame              // ~
        lli     a2, Character.id.BOWSER           // ~
        beq     a3, a2, pc() + 16                 // ~
        lli     a2, Character.id.GBOWSER          // ~
        bne     a3, a2, _bowser_checked           // ~
        addiu   at, r0, Bowser.Action.BowserBombDrop
        beq     v0, at, _check_frame              // ~
        addiu   at, r0, Bowser.Action.BowserForwardThrow2
        beq     v0, at, _grab_release             // ~
        _bowser_checked:
        addiu   at, r0, Action.ShieldBreakFall    // check for Pitfall, Jigglypuff etc
        beq     v0, at, _check_frame              // ~
        lli     a2, Character.id.KIRBY            // ~
        bne     a3, a2, pc() + 12                 // ~
        addiu   at, r0, Action.KIRBY.ForwardThrowFall
        beq     v0, at, _grab_release             // ~
        nop

        jal     grab_release_check_
        addiu   a0, s1, 0           // a0 = player struct

        addiu   t8, s1, 0           // t8 = player struct
        lw      t9, 0x014C(t8)      // t9 = kinetic state
        bnez    t9, _skip_KO        // branch if aerial
        nop

        // if here, grounded
        lw      a1, 0x0004(s1)
        //jal     0x800DE45C          // update clipping under player if grounded
        //addiu   a0, t8, 0x0078
        jal     set_aerial_from_grounded          // set aerial idle
        lw      a0, 0x0004(s1)      // a0 = player obj

        b      _skip_KO                           // otherwise, checking frame number
        nop

        // release if Kirby, Bowser etc is throwing an opponent
        _grab_release:
        jal     0x80149AC8                        // grab release
        nop
        b      _skip_KO                           // otherwise, checking frame number
        nop

        _check_frame:
        lw      at, 0x001C(s1)                    // get current frame of current action
        sltiu   at, at, 250                       // at = 1 if action frame < 250
        bnez    at, _skip_KO                      // branch accordingly
        nop

        or      a2, r0, r0                        // a2(starting frame) = 0 (doesn't do anything here?)
        lui     a3, 0x3F80                        // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                        // change action
        sw      r0, 0x0010(sp)                    // argument 4 = 0

        _skip_KO:
        lw      a1, 0x0004(sp)                    // restore registers
        lw      a2, 0x0008(sp)                    // ~
        lw      a3, 0x000C(sp)                    // ~
        lw      v0, 0x0014(sp)                    // ~
        addiu   sp, sp, 0x0028                    // deallocate stack space
        j        0x8013CF44                       // skip KO routine entirely
        nop

        _KO:
        jal        0x8013C1C4                     // original line - KO player at bottom blast zone
        nop

        _end:
        j        _return
        nop
    }
}
