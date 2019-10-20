// Ganondorf.asm

// This file contains file inclusions, action edits, and assembly for Ganondorf.

scope Ganondorf {
    // Insert Moveset files
    insert IDLE,"moveset/IDLE.bin"
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert JUMP2, "moveset/JUMP2.bin"
    insert TECHSTAND, "moveset/TECHSTAND.bin"
    insert TECHROLL, "moveset/TECHFROLL.bin"
    insert EDGEATTACKF, "moveset/EDGEATTACKF.bin"
    insert EDGEATTACKS, "moveset/EDGEATTACKS.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT_M_HI,"moveset/FORWARD_TILT_MID_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_M_LO,"moveset/FORWARD_TILT_MID_LOW.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_MID_LOW.bin"
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
    insert NSP_GROUND,"moveset/NEUTRAL_SPECIAL_GROUND.bin"
    insert NSP_AIR,"moveset/NEUTRAL_SPECIAL_AIR.bin"
    insert USP_GRAB,"moveset/UP_SPECIAL_GRAB.bin"
    insert USP_RELEASE,"moveset/UP_SPECIAL_RELEASE.bin"
    insert USP_THROW_DATA,"moveset/UP_SPECIAL_THROW_DATA.bin"
    USP_GROUND:; Moveset.THROW_DATA(USP_THROW_DATA); insert "moveset/UP_SPECIAL_GROUND.bin"
    USP_AIR:; Moveset.THROW_DATA(USP_THROW_DATA); insert "moveset/UP_SPECIAL_AIR.bin"
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_FLIP,"moveset/DOWN_SPECIAL_FLIP.bin"
    insert DSP_LAND,"moveset/DOWN_SPECIAL_LANDING.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"  

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(GND,   Action.Idle,            -1,                         IDLE,                       -1)
    Character.edit_action_parameters(GND,   Action.Run,             -1,                         RUN,                        -1)
    Character.edit_action_parameters(GND,   Action.JumpAerialF,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(GND,   Action.JumpAerialB,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(GND,   Action.TechF,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(GND,   Action.TechB,           -1,                         TECHROLL,                   -1)
    Character.edit_action_parameters(GND,   Action.Tech,            -1,                         TECHSTAND,                  -1)
    Character.edit_action_parameters(GND,   Action.CliffAttackQuick1, -1,                       EDGEATTACKF,                -1)
    Character.edit_action_parameters(GND,   Action.CliffAttackQuick2, -1,                       EDGEATTACKF,                -1)
    Character.edit_action_parameters(GND,   Action.CliffAttackSlow1, -1,                        EDGEATTACKS,                -1)
    Character.edit_action_parameters(GND,   Action.CliffAttackSlow2, -1,                        EDGEATTACKS,                -1)
    Character.edit_action_parameters(GND,   Action.Taunt,           File.GND_TAUNT,             TAUNT,                      -1)
    Character.edit_action_parameters(GND,   Action.Jab1,            -1,                         JAB_1,                      -1)
    Character.edit_action_parameters(GND,   Action.DashAttack,      -1,                         DASH_ATTACK,                -1)
    Character.edit_action_parameters(GND,   Action.FTiltHigh,       -1,                         FTILT_HI,                   -1)
    Character.edit_action_parameters(GND,   Action.FTiltMidHigh,    -1,                         FTILT_M_HI,                 -1)
    Character.edit_action_parameters(GND,   Action.FTilt,           -1,                         FTILT,                      -1)
    Character.edit_action_parameters(GND,   Action.FTiltMidLow,     -1,                         FTILT_M_LO,                 -1)
    Character.edit_action_parameters(GND,   Action.FTiltLow,        -1,                         FTILT_LO,                   -1)
    Character.edit_action_parameters(GND,   Action.UTilt,           -1,                         UTILT,                      -1)
    Character.edit_action_parameters(GND,   Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(GND,   Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(GND,   Action.FSmash,          0x64E,                      FSMASH,                     0)   
    Character.edit_action_parameters(GND,   Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(GND,   Action.USmash,          File.GND_USMASH,            USMASH,                     0) 
    Character.edit_action_parameters(GND,   Action.DSmash,          File.GND_DSMASH,            DSMASH,                     -1)
    Character.edit_action_parameters(GND,   Action.AttackAirN,      0x667,                      NAIR,                       -1)
    Character.edit_action_parameters(GND,   Action.AttackAirF,      File.GND_FAIR,              FAIR,                       -1)
    Character.edit_action_parameters(GND,   Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(GND,   Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(GND,   Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(GND,   Action.LandingAirN,     0x66B,                      0x1720,                     -1)
    Character.edit_action_parameters(GND,   Action.LandingAirF,     0,                          0x80000000,                 -1)
    Character.edit_action_parameters(GND,   0xE4,                   -1,                         NSP_GROUND,                 -1)
    Character.edit_action_parameters(GND,   0xE5,                   -1,                         NSP_AIR,                    -1)
    Character.edit_action_parameters(GND,   0xE6,                   -1,                         DSP_GROUND,                 -1)
    Character.edit_action_parameters(GND,   0xE7,                   -1,                         DSP_FLIP,                   -1)
    Character.edit_action_parameters(GND,   0xE8,                   -1,                         DSP_LAND,                   -1)
    Character.edit_action_parameters(GND,   0xE9,                   -1,                         DSP_AIR,                    -1)
    Character.edit_action_parameters(GND,   0xEB,                   -1,                         USP_GROUND,                 -1)
    Character.edit_action_parameters(GND,   0xEC,                   -1,                         USP_GRAB,                   -1)
    Character.edit_action_parameters(GND,   0xED,                   -1,                         USP_RELEASE,                -1)
    Character.edit_action_parameters(GND,   0xEE,                   -1,                         USP_AIR,                    -1)
    
    kick_anim_struct:
    dw  0x060F0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9ACC, 0x20)
    punch_anim_struct:
    dw  0x020F0000
    dw  Character.GND_file_8_ptr
    OS.copy_segment(0xA9AF4, 0x20)
    entry_anim_struct:
    dw  0x060A0000
    dw  Character.GND_file_7_ptr
    OS.copy_segment(0xA9EAC, 0x20)
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his down special.
    scope get_kick_anim_struct_: {
        OS.patch_start(0x7D6E4, 0x80101EE4)
        j       get_kick_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()
        
        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, kick_anim_struct        // a0 = kick_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        li      a0, 0x8012E2C4              // original line 1/3 (load falcon kick animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his neutral special.
    scope get_punch_anim_struct_: {
        OS.patch_start(0x7D790, 0x80101F90)
        j       get_punch_anim_struct_
        nop
        nop
        _return:
        OS.patch_end()
        
        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, punch_anim_struct       // a0 = punch_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        li      a0, 0x8012E2EC              // original line 1/3 (load falcon punch animation struct)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDB1C                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads a different animation struct when Ganondorf uses his entry animation.
    scope get_entry_anim_struct_: {
        OS.patch_start(0x7EDA0, 0x801035A0)
        j       get_entry_anim_struct_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      a0, entry_anim_struct       // a0 = entry_anim_struct
        beq     t0, t1, _end                // end if character id = GND
        nop
        li      a0, 0x8012E6A4              // original line 1/3 (load entry animation struct?)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x800FDAFC                  // original line 2
        nop
        j       _return                     // return
        nop
    }
    
    // @ Description
    // loads the correct file pointer when Ganondorf uses his entry animation.
    scope get_entry_file_ptr_: {
        OS.patch_start(0x7EDBC, 0x801035BC)
        j       get_entry_file_ptr_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.GND    // t1 = id.GND
        li      s2, Character.GND_file_7_ptr// a0 = Character.GND_file_7_ptr
        beq     t0, t1, _end                // end if character id = GND
        nop
        li      s2, 0x8013103C              // original line 1/2 (load falcon file 7 ptr)
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }
    
    // @ Description
    // adds a check for Ganondorf to a routine which determines which bone the punch graphic is
    // attached to
    scope get_punch_bone_: {
         OS.patch_start(0x7D7C8, 0x80101FC8)
        j       get_punch_bone_
        nop
        nop
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()
        
        // a1 = character id
        // at = id.CAPTAIN
        beq     a1, at, _end                // end if character id = CAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.NCAPTAIN
        beq     a1, at, _end                // end if character id = NCAPTAIN
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        ori     at, r0, Character.id.GND
        beq     a1, at, _end                // end if character id = GND
        lw      v1, 0x0928(a0)              // v1 = falcon hand bone struct
        
        lw      v1, 0x0960(a0)              // v1 = other bone struct (used for kirby presumably)
        
        _end:
        j       _return
        nop
    }
}