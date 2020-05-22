// JFox.asm

// This file contains file inclusions, action edits, and assembly for JFox.

scope JFox {
    // Insert Moveset files
    insert USP_GROUND_MOVE,"moveset/UP_SPECIAL_GROUND_MOVE.bin" // no end command, transitions into USP_LOOP
    insert USP_LOOP,"moveset/UP_SPECIAL_LOOP.bin"; Moveset.GO_TO(USP_LOOP)
    insert USP_AIR_MOVE,"moveset/UP_SPECIAL_AIR_MOVE.bin"; Moveset.GO_TO(USP_LOOP)
    insert NEUTRAL_INF,"moveset/NEUTRAL_INF.bin"; Moveset.GO_TO(NEUTRAL_INF)
    insert DSMASH,"moveset/DSMASH.bin"
    insert DTILT,"moveset/DTILT.bin"
    UPSPECIALMID:; Moveset.CONCURRENT_STREAM(UPSPECIALMIDCONCURRENT); insert "moveset/UPSPECIALMID.bin"
    insert UPSPECIALMIDCONCURRENT,"moveset/UPSPECIALMIDCONCURRENT.bin"
    insert VICTORY_POSE_1, "moveset/VICTORY_POSE_1.bin"
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JFOX, 0xE7,                   -1,                         USP_GROUND_MOVE,            -1)
    Character.edit_action_parameters(JFOX, 0xE8,                   -1,                         USP_AIR_MOVE,               -1)
    Character.edit_action_parameters(JFOX, 0xDD,                   -1,                         NEUTRAL_INF,                -1)
    Character.edit_action_parameters(JFOX, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(JFOX, Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(JFOX, 0xE5,                   -1,                         UPSPECIALMID,               -1)
    Character.edit_action_parameters(JFOX, 0xE6,                   -1,                         UPSPECIALMID,               -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    
    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(JFOX, 0x2,               -1,                         VICTORY_POSE_1,             -1)
    
    // Set crowd chant FGM.
     Character.table_patch_start(crowd_chant_fgm, Character.id.JFOX, 0x2)
     dh  0x031A
     OS.patch_end()
	 
	 
    // @ Description
    // loads a different special struct when JFox uses his up special.
    scope get_laser_special_struct_: {
        OS.patch_start(0xE34C4, 0x80168A84)
        j       get_laser_special_struct_
        addiu	a1, a1, 0x8ED0
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
		lw		t0, 0x0074(sp)				// load player struct
		lw		t0, 0x0008(t0)				// load player id
		ori     t1, r0, Character.id.JFOX  	// t1 = id.FOX
		bne		t1, t0, _end
		nop
        li      a1, laser_special_struct  		// a1 = laser_special_struct
                
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        lw		a2, 0x0024(sp)
    }
    
	OS.align(16)
    laser_special_struct:
    dw 0x00000000
    dw 0x00000001
    dw Character.JFOX_file_6_ptr
    OS.copy_segment(0x10391C, 0x28)

}