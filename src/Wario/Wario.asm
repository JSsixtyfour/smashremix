// Wario.asm

// This file contains file inclusions, action edits, and assembly for Wario.

scope Wario {
    // Insert Moveset files
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_DATA,"moveset/FORWARD_THROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FORWARD_THROW.bin"
    insert BTHROW_DATA,"moveset/BACK_THROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BACK_THROW.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_LOW.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP_RECOIL,"moveset/NEUTRAL_SPECIAL_RECOIL.bin"
    insert NSP_TRAIL,"moveset/NEUTRAL_SPECIAL_TRAIL.bin"
    NSP_GROUND:; Moveset.CONCURRENT_STREAM(NSP_TRAIL); insert "moveset/NEUTRAL_SPECIAL_GROUND.bin"
    NSP_AIR:; Moveset.CONCURRENT_STREAM(NSP_TRAIL); insert "moveset/NEUTRAL_SPECIAL_AIR.bin"
    insert USP,"moveset/UP_SPECIAL.bin"
    insert DSP_LANDING,"moveset/DOWN_SPECIAL_LANDING.bin"
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(WARIO, Action.Idle,            File.WARIO_IDLE,            -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.Crouch,          File.WARIO_CROUCH_BEGIN,    -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.CrouchIdle,      File.WARIO_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.CrouchEnd,       File.WARIO_CROUCH_END,      -1,                         -1)
    //Character.edit_action_parameters(WARIO, Action.RunBrake,        File.WARIO_RUNBRAKE,        -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.Grab,            File.WARIO_GRAB,            GRAB,                       -1)
    Character.edit_action_parameters(WARIO, Action.GrabPull,        File.WARIO_GRAB_PULL,       -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.ThrowF,          File.WARIO_FTHROW,          FTHROW,                     0x50000000)
    Character.edit_action_parameters(WARIO, Action.ThrowB,          File.WARIO_BTHROW,          BTHROW,                     0x50000000)
    Character.edit_action_parameters(WARIO, Action.Taunt,           File.WARIO_TAUNT,           -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.Jab1,            File.WARIO_JAB_1,           JAB_1,                      -1)
    Character.edit_action_parameters(WARIO, Action.Jab2,            File.WARIO_JAB_2,           JAB_2,                      -1)
    Character.edit_action_parameters(WARIO, Action.FTiltHigh,       File.WARIO_FTILT_HIGH,      FTILT_HI,                   -1)
    Character.edit_action_parameters(WARIO, Action.FTiltMidHigh,    0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FTilt,           File.WARIO_FTILT,           FTILT,                      -1)
    Character.edit_action_parameters(WARIO, Action.FTiltMidLow,     0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FTiltLow,        File.WARIO_FTILT_LOW,       FTILT_LO,                   -1)
    Character.edit_action_parameters(WARIO, Action.UTilt,           File.WARIO_UTILT,           UTILT,                      0)
    Character.edit_action_parameters(WARIO, Action.DTilt,           File.WARIO_DTILT,           DTILT,                      -1)
    Character.edit_action_parameters(WARIO, Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FSmashMidHigh,   0,                          0x80000000,                 0)  
    Character.edit_action_parameters(WARIO, Action.FSmash,          File.WARIO_FSMASH,          FSMASH,                     0x40000000)
    Character.edit_action_parameters(WARIO, Action.FSmashMidLow,    0,                          0x80000000,                 0) 
    Character.edit_action_parameters(WARIO, Action.FSmashLow,       0,                          0x80000000,                 0)  
    Character.edit_action_parameters(WARIO, Action.USmash,          File.WARIO_USMASH,          USMASH,                     -1)
    Character.edit_action_parameters(WARIO, Action.DSmash,          File.WARIO_DSMASH,          DSMASH,                     0x80000000)
    Character.edit_action_parameters(WARIO, Action.AttackAirN,      File.WARIO_NAIR,            NAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirF,      File.WARIO_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirB,      File.WARIO_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirU,      File.WARIO_UAIR,            UAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirD,      File.WARIO_DAIR,            DAIR,                       0)
    Character.edit_action_parameters(WARIO, 0xDC,                   File.WARIO_NSP_RECOIL,      NSP_RECOIL,                 -1)
    Character.edit_action_parameters(WARIO, 0xDF,                   File.WARIO_NSP_GROUND,      NSP_GROUND,                 -1)
    Character.edit_action_parameters(WARIO, 0xE0,                   File.WARIO_NSP_AIR,         NSP_AIR,                    -1)
    Character.edit_action_parameters(WARIO, 0xE1,                   File.WARIO_USP,             USP,                        0)
    Character.edit_action_parameters(WARIO, 0xE2,                   File.WARIO_DSP_LANDING,     DSP_LANDING,                0)
    Character.edit_action_parameters(WARIO, 0xE3,                   File.WARIO_DSP_GROUND,      DSP_GROUND,                 0)
    Character.edit_action_parameters(WARIO, 0xE4,                   File.WARIO_DSP_AIR,         DSP_AIR,                    0)
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(WARIO, 0xDC,              0x12,           0x800D94E8,                 WarioNSP.recoil_move_,          WarioNSP.recoil_physics_,       0x800DE99C)
    Character.edit_action(WARIO, 0xDF,              -1,             0x800D94C4,                 WarioNSP.ground_move_,          WarioNSP.ground_physics_,       WarioNSP.ground_collision_)
    Character.edit_action(WARIO, 0xE0,              -1,             0x800D94E8,                 WarioNSP.air_move_,             WarioNSP.air_physics_,          WarioNSP.air_collision_)
    Character.edit_action(WARIO, 0xE1,              -1,             0x8015C750,                 WarioUSP.change_direction_,     WarioUSP.movement_,             0x80156358)
    Character.edit_action(WARIO, 0xE2,              0x1E,           0x800D94C4,                 0,                              0x800D8BB4,                     0x800DDF44)
    Character.edit_action(WARIO, 0xE3,              -1,             0x800D94E8,                 WarioDSP.ground_move_,          WarioDSP.physics_,              WarioDSP.collision_)
    Character.edit_action(WARIO, 0xE4,              -1,             0x800D94E8,                 WarioDSP.air_move_,             WarioDSP.physics_,              WarioDSP.collision_)
    
    Character.table_patch_start(ground_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.WARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.WARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.WARIO, 0x4)
    dw      WarioDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.WARIO, 0x4)
    dw      WarioDSP.air_initial_
    OS.patch_end()
    
    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.WARIO, 0x4)
    float32 1.4
    OS.patch_end()
    
    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.WARIO, 0x2)
    dh  0x303
    OS.patch_end()
    
    // Set initial script.
    constant initial_script_(0x800DE448)
    Character.table_patch_start(initial_script, Character.id.WARIO, 0x4)
    dw  initial_script_
    OS.patch_end()
    
    // Set default costumes
    Character.set_default_costumes(Character.id.WARIO, 0, 1, 2, 3, 1, 2, 4)
    
    // @ Description
    // Subroutine which sets up special behaviours for Wario's neutral special hitbox.
    // Runs when a hitbox makes contact.
    // Sets temp variable 1 to 0x1 and plays an FGM if connecting with a hurtbox or shield.
    // Prevents hitbox from being disabled on clang.
    scope body_slam_hitbox_: {
        OS.patch_start(0x5DED0, 0x800E26D0)
        j       body_slam_hitbox_
        nop
        _return:
        OS.patch_end()
    
        // a0 = player struct
        // a3 = hitbox contact type (0 = hurtbox, 1 = shield, 2 = don't disable?, 3 = clang)
        // s0-s3 are safe
        lw      s0, 0x0008(a0)              // s0 = character id
        ori     s1, r0, Character.id.WARIO  // s1 = id.WARIO
        bne     s0, s1, _end                // if id != WARIO, skip
        nop
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, 0x00DF              // s1 = action id: NSP_GROUND
        beq     s0, s1, _body_slam          // branch if current action = ground neutral special
        nop
        ori     s1, r0, 0x00E0              // s1 = action id: NSP_AIR
        bne     s0, s1, _end                // skip if current action != aerial neutral special
        nop
        
        _body_slam:
        ori     s2, r0, 0x0001              // s2 = 0x1
        beql    a3, r0, _contact            // branch if contact type = hurtbox
        sw      s2, 0x017C(a0)              // temp variable 1 = 0x1 (on branch)
        beql    a3, s2, _contact            // branch if contact type = shield
        sw      s2, 0x017C(a0)              // temp variable 1 = 0x1 (on branch)
        ori     s2, r0, 0x0002              // s2 = 0x2
        ori     s3, r0, 0x0003              // s3 = 0x3
        beql    a3, s3, _end                // branch if contact type = clang
        or      a3, s2, r0                  // contact type = don't disable (on branch)
        b       _end
        nop
        
        _contact:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // store a0, ra
        ori     a0, r0, 0x0117              // a0 = FGM ID
        jal     FGM.play_                   // play fgm
        nop
        lw      a0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // load a0, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        _end:
        or      s0, a2, r0                  // original line 1
        or      s1, a3, r0                  // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // When an opponent is grabbed by Wario, they will be put into the ThrownDK action (0xB8)
    // rather than the usual CapturePulled action (0xAB)
    scope capture_action_fix_: {
        OS.patch_start(0xC534C, 0x8014A90C)
        j       capture_action_fix_
        nop
        _return:
        OS.patch_end()
        
        // v0 = grabbing player struct
        ori     a1, r0, Character.id.WARIO  // a1 = id.WARIO
        lw      a2, 0x0008(v0)              // a2 = grabbing player character id
        bne     a1, a2, _end                // if id != WARIO, skip
        ori     a1, r0, Action.CapturePulled// original line 1
        // if id = WARIO
        ori     a1, r0, Action.ThrownDK     // captured player action = ThrownDK
        
        _end:
        addiu   a2, r0, 0x0000              // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Decription
    // Attempts to fix the position of the grabbed character on frame 1 of Wario's GrabPull action.
    // Not perfect, but a big improvement.
    scope capture_position_fix_: {
        OS.patch_start(0xC539C, 0x8014A95C)
        j       capture_position_fix_
        nop
        _return:
        OS.patch_end()
        
        lw      a0, 0x0044(sp)              // ~
        lw      a0, 0x0084(a0)              // v0 = grabbing player struct
        lw      a0, 0x0008(a0)              // a0 = grabbing player character id
        ori     a1, r0, Character.id.WARIO  // a1 = id.WARIO
        beq     a0, a1, _wario              // branch if id = WARIO
        nop
        // if id != WARIO
        jal     0x8014A6B4                  // original line 1
        or      a0, s1, r0                  // original line 2
        j       _return                     // return
        nop
        
        _wario:
        // Usually, 8014A6B4 is used to set the captured player's position on the first frame of
        // being grabbed, with 8014AB64 being used on subsequent frames.
        // If the grabbing character is Wario, 8014AB64 will be used on the first frame instead.
        jal     0x8014AB64                  // modified original line 1
        or      a0, s1, r0                  // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Modifies the subroutine which handles mashing/breaking out of the ThrownDK action.
    // Skips if the throwing character is Wario.
    scope capture_break_fix_: {
        OS.patch_start(0xC8F14, 0x8014E4D4)
        j       capture_break_fix_
        nop
        _return:
        OS.patch_end()
        
        lw      a2, 0x0084(a0)              // a2 = captured player struct
        lw      a2, 0x0844(a2)              // a2 = player.entity_captured_by
        lw      a2, 0x0084(a2)              // a2 = grabbing player struct
        lw      a2, 0x0008(a2)              // a2 = grabbing player character id
        ori     a3, r0, Character.id.WARIO  // a3 = id.WARIO
        beq     a2, a3, _wario              // branch if id = WARIO
        nop
        // if id != WARIO
        addiu   sp, sp, 0xFFD8              // original line 1
        sw      ra, 0x0014(sp)              // original line 2
        j       _return                     // return (and continue subroutine)
        nop
        
        _wario:
        jr      ra                          // end subroutine
        nop
    }
    
    // GRABPULL OPPONENT ACTION 8014A90C OR 8014AA6C
    // THROWNDKPULLED SUBROUTINE 8014E4D4
    // @8014A95C(good) or 8014A6D0(bad) - change to 0C052AD9
}