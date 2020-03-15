// Lucas.asm

// This file contains file inclusions, action edits, and assembly for Lucas.

scope Lucas {
    // Insert Moveset files
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert DAIR, "moveset/DAIR.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert FSMASH, "moveset/FSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert PKFIREGROUND, "moveset/PKFIREGROUND.bin"
    insert PKFIREAIR, "moveset/PKFIREAIR.bin"
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(LUCAS, Action.Jab1,            File.LUCAS_JAB1,            -1,                         0x00000000)
    Character.edit_action_parameters(LUCAS, Action.Jab2,            File.LUCAS_JAB2,            -1,                         0x00000000)
    Character.edit_action_parameters(LUCAS, 0xDC,                   File.LUCAS_JAB3,            -1,                         0x00000000)
    Character.edit_action_parameters(LUCAS, Action.AttackAirN,      File.LUCAS_NAIR,            -1,                         -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirF,      File.LUCAS_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirB,      File.LUCAS_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirD,      File.LUCAS_DAIR,            DAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.FTilt,           File.LUCAS_FTILT_MID,       -1,                         0x00000000)
    Character.edit_action_parameters(LUCAS, Action.FTiltHigh,       File.LUCAS_FTILT_HIGH,       -1,                        0x00000000)
    Character.edit_action_parameters(LUCAS, Action.FTiltLow,        File.LUCAS_FTILT_LOW,       -1,                         0x00000000)
    Character.edit_action_parameters(LUCAS, Action.UTilt,           File.LUCAS_UTILT,           UTILT,                      -1)
    Character.edit_action_parameters(LUCAS, Action.USmash,          File.LUCAS_USMASH,          USMASH,                     0x80000000)
    Character.edit_action_parameters(LUCAS, Action.DSmash,          File.LUCAS_DSMASH,          DSMASH,                     0x00000000)
    // Character.edit_action_parameters(LUCAS, Action.Catch,           -1,                         GRAB,                       -1)
    Character.edit_action_parameters(LUCAS, Action.FSmash,          -1,                         FSMASH,                     -1)
    Character.edit_action_parameters(LUCAS, Action.DashAttack,      File.LUCAS_DASHATTACK,      -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE2,                   File.LUCAS_PKFIREGROUNDANI, PKFIREGROUND,               0x40000000)
    Character.edit_action_parameters(LUCAS, 0xE3,                   File.LUCAS_PKFIREAIRANI,    PKFIREAIR,                  -1)
    Character.edit_action_parameters(LUCAS, 0xED,                   File.LUCAS_MAGNETSTARTGR,   -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xEE,                   File.LUCAS_MAGNETHOLDGR,    -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xF0,                   File.LUCAS_MAGNETRELEASEGR, -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xF1,                   File.LUCAS_MAGNETSTARTAIR,  -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xF2,                   File.LUCAS_MAGNETHOLDAIR,   -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xF4,                   File.LUCAS_MAGNETRELEASEAIR, -1,                        -1)
    Character.edit_action_parameters(LUCAS, Action.FallSpecial,     File.LUCAS_SFALL,           -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE4,                   File.LUCAS_PKTHUNDERSTARTGR, -1,                        -1)
    Character.edit_action_parameters(LUCAS, 0xE5,                   File.LUCAS_PKTHUNDERHOLDGR, -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE6,                   File.LUCAS_PKTHUNDERRELEASEGR, -1,                      -1)
    Character.edit_action_parameters(LUCAS, 0xE8,                   File.LUCAS_PKTHUNDERSTARTAIR, -1,                       -1)
    Character.edit_action_parameters(LUCAS, 0xE9,                   File.LUCAS_PKTHUNDERHOLDAIR, -1,                        -1)
    Character.edit_action_parameters(LUCAS, 0xEA,                   File.LUCAS_PKTHUNDERRELEASEAIR, -1,                     -1)
    Character.edit_action_parameters(LUCAS, 0xEC,                   File.LUCAS_PKTHUNDER2,      -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE7,                   File.LUCAS_PKTHUNDER2,      -1,                         -1)
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(LUCAS, 0xE2,              -1,             -1,                         -1,                             0x800D8CCC,                       -1)
    Character.edit_action(LUCAS, 0xE3,              -1,             -1,                         LucasNSP.air_move_,             -1,                               -1)
    
    // Modify Menu Action Parameters        // Action          // Animation                // Moveset Data             // Flags
    
    
    // Set crowd chant FGM.
        
    
    // Set default costumes
    Character.set_default_costumes(Character.id.LUCAS, 0, 1, 2, 4, 5, 2, 3)
    
    // Forces Lucas' pk fire to stay horizontal when in the air
    // @ Description
    // essentially a binary BNE, if 0, player is on the ground and will skip diagonal command. If in the air, 
    // then it will be 1 and will proceed to go diagonal. A character check is done, player struct in s1 and v0.
    // If lucas, the number will be changed to 0
    scope pkfire_horizontal: {
        OS.patch_start(0xCE414, 0x801539D4)
        j       pkfire_horizontal
        nop
        _return:
        OS.patch_end()
        
        swc1    f18, 0x0028(sp)             // original line 1
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t1, 0x0008(v0)              // load character ID
        ori     t2, r0, Character.id.LUCAS  // t1 = id.LUCAS
        addiu   t9, r0, r0                  // set LUCAS as if grounded always
        beq     t1, t2, _end                
        nop
        lw      t9, 0x14C(v0)               // original line 2 - load Ness current position, grounded (0) or air (1)
        
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }    
    
    // Set initial script.
    constant initial_script_(0x800DE448)
    Character.table_patch_start(initial_script, Character.id.LUCAS, 0x4)
    dw  initial_script_
    OS.patch_end()

    // Changes PK FIRE's after effect for Lucas
    // @ Description
    // the normal path it takes to spawn the pk fire2 object is swapped out with the explosion graphic
    scope pkfire_explosion: {
        OS.patch_start(0xE55A8, 0x8016AB68)
        j       pkfire_explosion
        nop
        _return:
        OS.patch_end()
        
        swc1    f18, 0x0030(sp)             // original line 2
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t1, 0x0078(v0)              // load player struct from projectile struct as placed in previously by pkfire1pointer
        lw      t1, 0x0008(t1)              // load character ID
        ori     t2, r0, Character.id.LUCAS  // t1 = id.JNESS
        beq     t1, t2, lucas_explosion_
        nop
       
        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80185824                  // original line 1 - modified
        nop
        j       _return                     // return
        nop
        
        lucas_explosion_:
        addiu   a0, a1, 0x0000
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80100480                  // jump to explosion process
        nop
        j       _return                     // return
        nop
    }    

}