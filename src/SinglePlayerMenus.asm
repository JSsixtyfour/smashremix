// SinglePlayerMenus.asm
if !{defined __SINGLE_PLAYER_MENUS__} {
define __SINGLE_PLAYER_MENUS__()
print "included SinglePlayerMenus.asm\n"

// @ Description
// This contains the code for the revised Single Player Menu Screens

scope SinglePlayerMenus: {

// 1P MENU SCREEN / BUTTONS

    // @ Description
    // This removes the flag that identifies different 1p modes
    scope remove_flag: {
        OS.patch_start(0x11EBE8, 0x80132AD8)
        j		remove_flag
        nop 
        _return:
        OS.patch_end() 
        
        li      v0, SinglePlayerModes.singleplayer_mode_flag
        sw      r0, 0x0000(v0)
        lui     v0, 0x8013              // original line 1
        
        _end:
        j       _return
        lw      v0, 0x31B8(v0)
    }
    
// RENDERING
    
    // @ Description
    // Renders the Button graphics, including the additional buttons we have added
    // What gets loaded depends on page_id
    scope singleplayer_buttons: {
        OS.patch_start(0x11F0D8, 0x80132FC8)
        j       singleplayer_buttons                      
        nop 
        _return:
        OS.patch_end()
        
        li      at, SinglePlayerModes.page_flag
        lw      at, 0x0000(at)            // load Page Flag
        bnez    at, page_2                // Branch if on Page 2, so it renders other buttons
        nop
        
        jal     0x80131E34                // Render 1p button
        nop
        
        jal     0x80131F0C                // Render Training button
        nop
        
        jal     0x80131FE8                // Render Bonus 1 button
        nop
        
        jal     0x801320F8                // Render Bonus 2 Button
        nop
            
        jal     bonus3_button_render      // Render Bonus 3 Button
        nop	
        jal     remixmodes_button_render  // Render Remix Modes Button
        nop	
        
        _end:
        j       0x80132FE8                // jump to jump to last render routine (unknown)
        nop    
        
        page_2:
        li      t6, SinglePlayerModes.MENU_INDEX    // load index address
        lw      at, 0x0000(t6)            // load index id
        bnez    at, _from_css             // index will be set to 0 when coming from page 1, however, if coming back from a bonus stage, it is already set to correct id and we can skip the below
        nop
        addiu   at, r0, 0x0006            // if coming from page 1, we should set to Remix 1p Button
        sw      at, 0x0000(t6)            // Save remix 1p button id to index
        
        _from_css:
        jal     remix1p_button_render     // Render Remix 1p Button 
        nop
        jal     multi_man_button_render   // Render Multiman Button
        nop 
        jal     cruel_button_render       // Render Cruel Multiman Button
        nop
        j       0x80132FE8                // jump to jump to last render routine (unknown)
        nop
    }
    
    // @ Description
    //  This is the render routine for the Bonus 3 button, largely based on Bonus Button 2 at 801320F8
    scope bonus3_button_render: {
		
        OS.copy_segment(0x11E208, 0x1C)     // 801320F8
        
        lui     a1, 0x800D
        addiu   t6, r0, 0xFFFF
        li      at, bonus3_button_pointer   // load pointer for multiman
        sw      v0, 0x0000(at)              // save pointer to location
        
        OS.copy_segment(0x11E234, 0x3C)		// 801320F8
        
        lui     at, 0x4260                  // originally 0x4286, x location of button
        mtc1	at, f4
        lui     at, 0x430C                  // y location of button
        
        OS.copy_segment(0x11E27C, 0x28)     // 8013216C
        
        addiu	a2, r0, 0x0004              // new index
        xori	a1, a1, 0x0004              // new index, both are used to determine which to highlight when returning to option screen
        
        OS.copy_segment(0x11E2AC, 0x14)     // 8013219C
        
        addiu   t4, t4, 0x70A8              // loads in the Bonus 3 graphic offset
        lw      a0, 0x0024(sp)
        jal     0x800CCFDC
        addu    a1, t3, t4
        lhu     t5, 0x0024(v0)
        
        lui     at, 0x4296                  // originally 0x42AC, x location of text
        mtc1    at, f8
        lui     at, 0x430D                  // y location of text
        
        OS.copy_segment(0x11E2E0, 0x38)     // 801321D0
	}
    
    // @ Description
    //  This is the render routine for the Remix Modes button, largely based on Training Button at 80131F0C
    scope remixmodes_button_render: {
        
        OS.copy_segment(0x11E01C, 0x1C)     // 80131F0C
        
        lui     a1, 0x800D
        addiu   t6, r0, 0xFFFF
        li      at, remixmodes_button_pointer   // load pointer for remix modes button object
        sw      v0, 0x0000(at)              // save pointer to location
        
        OS.copy_segment(0x11E048, 0x20)     // 80131E60
        
        lui     a1, 0x4210                  // set button's x position
        lui     a2, 0x4328                  // set button's y position
        jal     0x80131D04
        addiu   a3, r0, 0x0010
        lui     a1, 0x8013
        lw      a1, 0x31B8(a1)
        lw      a0, 0x0024(sp)       
        addiu	a2, r0, 0x0005              // New Index
        xori	a1, a1, 0x0005              // new index, both are used to determine which to highlight when returning to option screen
        
        jal     0x80131B24
        sltiu   a1, a1, 0x0001
        lui     t7, 0x8013
        lw      t7, 0x3294(t7)
        lui     t8, 0x0000
        addiu   t8, t8, 0x7FB8              // load button graphic offset
        lw      a0, 0x0024(sp)
        jal     0x800CCFDC
        addu    a1, t7, t8
        lhu     t9, 0x0024(v0)
        
        lui     at, 0x424B                  // originally 0x4286, x location of text
        mtc1    at, f4
        lui     at, 0x4329                  // originall, 4314, y location of text
        
        OS.copy_segment(0x11E0C0, 0x38)     // 80131FB0
	}
	
    // @ Description
	//  This is the render routine for the Remix Modes button, largely based on Training Button at 80131F0C
    scope remix1p_button_render: {
		
        OS.copy_segment(0x11E01C, 0x1C)		// 80131F0C
        
        lui     a1, 0x800D
        addiu   t6, r0, 0xFFFF
        li      at, remix1p_button_pointer  // load pointer for remix 1p button object
        sw      v0, 0x0000(at)              // save pointer to location

        OS.copy_segment(0x11E048, 0x20)		// 80131E60
        
        lui     a1, 0x42F8                  // set button's x position
        lui     a2, 0x41B0                  // set button's y position
        jal     0x80131D04
        addiu   a3, r0, 0x0010
        lui     a1, 0x8013
        lw      a1, 0x31B8(a1)
        lw      a0, 0x0024(sp)       
        addiu	a2, r0, 0x0006              // new index
        xori	a1, a1, 0x0006              // new index, both are used to determine which to highlight when returning to option screen
		
        jal     0x80131B24
        sltiu   a1, a1, 0x0001
        lui     t7, 0x8013
        lw      t7, 0x3294(t7)
        lui     t8, 0x0000
        addiu   t8, t8, 0x7838              // load button graphic offset
        lw      a0, 0x0024(sp)
        jal     0x800CCFDC
        addu    a1, t7, t8
        lhu     t9, 0x0024(v0)
        
        lui     at, 0x431C                  // originally 0x4286, x location of text
        mtc1    at, f4
        lui     at, 0x41B8                  // originall, 4314, y location of text
        
        OS.copy_segment(0x11E0C0, 0x38)     // 80131FB0
	}
    
	// @ Description
	//  This is the render routine for the multiman button, largely based on Bonus Button 2 at 801320F8
    scope multi_man_button_render: {
		
        OS.copy_segment(0x11E208, 0x1C)     // 801320F8
        
        lui     a1, 0x800D
        addiu   t6, r0, 0xFFFF
        li      at, multiman_button_pointer // load pointer for multiman
        sw      v0, 0x0000(at)              // save pointer to location

		OS.copy_segment(0x11E234, 0x3C)     // 801320F8
		
        lui     at, 0x42C6                  // originally 0x4286, x location of button
		mtc1	at, f4
		lui     at, 0x4264                  // originall, 4314, y location of button
		
		OS.copy_segment(0x11E27C, 0x28)     // 8013216C
		
        addiu	a2, r0, 0x0007              // new index
		xori	a1, a1, 0x0007              // new index, both are used to determine which to highlight when returning to option screen
		
		OS.copy_segment(0x11E2AC, 0x14)     // 8013219C
		
        addiu   t4, t4, 0x67E8              // loads in the multiman graphic offset
		lw      a0, 0x0024(sp)
		jal     0x800CCFDC
		addu    a1, t3, t4
		lhu     t5, 0x0024(v0)
		
		lui		at, 0x42EC                  // originally 0x42AC, x location of text
		mtc1	at, f8
		lui	    at, 0x4266                  // y location of text
		
        OS.copy_segment(0x11E2E0, 0x38)     // 801321D0
	}
	
	// @ Description
	//  This is the render routine for the cruel multiman button, largely based on Bonus Button 2 at 801320F8
	scope cruel_button_render: {
		
        OS.copy_segment(0x11E208, 0x1C)     // 801320F8
        
        lui     a1, 0x800D
        addiu   t6, r0, 0xFFFF
        li      at, cruel_button_pointer // load pointer for multiman
        sw      v0, 0x0000(at)              // save pointer to location
		
        OS.copy_segment(0x11E234, 0x3C)		// 801320F8
		
        lui		at, 0x42AC					// originally 0x4286, x location of button
		mtc1	at, f4
		lui		at, 0x42A0					// y location of button
		
		OS.copy_segment(0x11E27C, 0x28)		// 8013216C
		
        addiu	a2, r0, 0x0008				// new index
		xori	a1, a1, 0x0008				// new index, both are used to determine which to highlight when returning to option screen
		
		OS.copy_segment(0x11E2AC, 0x14)		// 8013219C
		
        addiu	t4, t4, 0x6C48				// loads in the cruel multiman graphic offset
		lw		a0, 0x0024(sp)
		jal		0x800CCFDC
		addu	a1, t3, t4
		lhu     t5, 0x0024(v0)
		
		lui		at, 0x42D2					// originally 0x42AC, x location of text
		mtc1	at, f8
		lui		at, 0x42A2					// y location of text
		
		OS.copy_segment(0x11E2E0, 0x38)		// 801321D0
	}
	
    // @ Description
    // These patches allow movement of the x and y locations of the buttons and text for each original index slot/button
        
        // 1p
        OS.patch_start(0x11DF90, 0x80131E80)
        lui     a1, 0x42F8                  // originally 42F8
        lui     a2, 0x41B0                  // originally 4228
        OS.patch_end()     
        
        OS.patch_start(0x11DFD8, 0x80131EC8)
        lui     at, 0x4321                  // originally 4321
        mtc1    at, f4                  
        lui     at, 0x41C8                  // originally 4238
        OS.patch_end() 
        
        // Training
        OS.patch_start(0x11E068, 0x80131F58)
        lui     a1, 0x42C6                  // 42C6
        lui     a2, 0x4264                  // 42A8
        OS.patch_end()     
        
        OS.patch_start(0x11E0B4, 0x80131FA4)
        lui     at, 0x42D6                  // 42D6
        mtc1    at, f4
        lui     at, 0x426B                  // 42AE
        OS.patch_end()   
        
        // Bonus 1
        OS.patch_start(0x11E160, 0x80132050)
        lui     at, 0x429C                  // original x position 429C
        mtc1    at, f4                      
        lui     at, 0x42C0                  // 42FC
        OS.patch_end()  
        
        OS.patch_start(0x11E1C4, 0x801320B4)
        lui     at, 0x42C2                  // original x position 42C2
        mtc1    at, f8                  
        lui     at, 0x42C2                  // 42FE
        OS.patch_end()
        
        // Bonus 2
        OS.patch_start(0x11E270, 0x80132160)
        lui     at, 0x4282                  // original x position 4286
        mtc1    at, f4                      
        lui     at, 0x42EC                  // original y position 4314
        OS.patch_end()  
        
        OS.patch_start(0x11E2D4, 0x801321C4)
        lui     at, 0x42AC                  // original x position 42AC
        mtc1    at, f8                  
        lui     at, 0x42EE                  // original y position 4315
        OS.patch_end() 
    
// BUTTON POINTER LOCATIONS

    // @ Description
    // The game has certain reserved spaces for the buttons to put pointers. With the modes we've added, we ran out of alloted spaces. Therefore, I moved it here.
    onep_button_pointer_struct:
    dw  0x00000000      // 1p Game Button
    training_button_pointer:
    dw  0x00000000      // Training Button
    bonus1_button_pointer:
    dw  0x00000000      // Bonus 1 Practice Button
    bonus2_button_pointer:
    dw  0x00000000      // Bonus 2 Practice Button
    bonus3_button_pointer:
    dw  0x00000000      // Bonus 3 Practice Button
    remixmodes_button_pointer:
    dw  0x00000000      // Remix Modes Button
    remix1p_button_pointer:
    dw  0x00000000      // Remix 1p Game Button
    multiman_button_pointer:
    dw  0x00000000      // Multiman Button
    cruel_button_pointer:
    dw  0x00000000      // Cruel Multiman Button
    
    // @ Description
	// Inserts new pointer location.
    // This patch as well as all the subsequent patches revise were the game originally saved pointers relevant for highlighting the buttons
    scope pointer_1p_button: {
        OS.patch_start(0x11DF60, 0x80131E50)
        j       pointer_1p_button                      
        lui     a1, 0x800D                  // original line 2
        nop
        nop
        _return:
        OS.patch_end()
        
        addiu   t6, r0, 0xFFFF              // original line 3
        li      at, onep_button_pointer_struct     // load pointer for 1p, modified line 1
        j       _return                     // return
        sw      v0, 0x0000(at)              // save pointer to location, modified line 4
    }
    
    // @ Description
    // Inserts new pointer location.
    scope pointer_training_button: {
        OS.patch_start(0x11E038, 0x80131F28)
        j       pointer_training_button                      
        lui     a1, 0x800D                  // original line 2
        nop
        nop
        _return:
        OS.patch_end()
        
        addiu   t6, r0, 0xFFFF              // original line 3
        li      at, training_button_pointer // load pointer for 1p, modified line 1
        j       _return                     // return
        sw      v0, 0x0000(at)              // save pointer to location, modified line 4
    }
    
    // @ Description
    // Inserts new pointer location.
    scope pointer_bonus1_button: {
        OS.patch_start(0x11E114, 0x80132004)
        j       pointer_bonus1_button                      
        lui     a1, 0x800D                  // original line 2
        nop
        nop
        _return:
        OS.patch_end()
        
        addiu   t6, r0, 0xFFFF              // original line 3
        li      at, bonus1_button_pointer   // load pointer for 1p, modified line 1
        j       _return                     // return
        sw      v0, 0x0000(at)              // save pointer to location, modified line 4
    }
    
    // @ Description
    // Inserts new pointer location.
    scope pointer_bonus2_button: {
        OS.patch_start(0x11E224, 0x80132114)
        j       pointer_bonus2_button                      
        lui     a1, 0x800D                  // original line 2
        nop
        nop
        _return:
        OS.patch_end()
        
        addiu   t6, r0, 0xFFFF              // original line 3
        li      at, bonus2_button_pointer   // load pointer for 1p, modified line 1
        j       _return                     // return
        sw      v0, 0x0000(at)              // save pointer to location, modified line 4
    }
    
    // @ Description
    // Fixes 1p Mode selection routine to use new pointer locations for 1p Game.
    scope onep_button_selected: {
        OS.patch_start(0x11EC24, 0x80132B14)
        j       onep_button_selected
		nop
        _return:
        OS.patch_end()   
        
        li      a0, onep_button_pointer_struct    
        j       _return
        lw      a0, 0x0000(a0)
    }
    
    // @ Description
    // Fixes Training Mode Selection Routine to use new pointer locations for Training.
    scope training_button_selected: {
        OS.patch_start(0x11EC74, 0x80132B64)
        j       training_button_selected
		nop
        _return:
        OS.patch_end()   
        
        li      a0, training_button_pointer    
        j       _return
        lw      a0, 0x0000(a0)
    }
    
    // @ Description
    // Fixes Bonus 1 Selection Routine to use new pointer locations for Bonus 1.
    scope bonus1_button_selected: {
        OS.patch_start(0x11ECC4, 0x80132BB4)
        j       bonus1_button_selected
		nop
        _return:
        OS.patch_end()   
        
        li      a0, bonus1_button_pointer 
        j       _return
        lw      a0, 0x0000(a0)
    }
    
    // @ Description
	// Fixes Bonus 2 Selection Routine to use new pointer locations for Bonus 2.
    scope bonus2_button_selected: {
        OS.patch_start(0x11ED14, 0x80132C04)
        j       bonus2_button_selected
		nop
        _return:
        OS.patch_end()   
        
        li      a0, bonus2_button_pointer   
        j       _return
        lw      a0, 0x0000(a0)
    }
	
    // Loads in pointer addresses of added index objects and replacement address of originals
    // This routine is for removal of red highlighting from button that is being moved away from
    scope load_index_previous: {
        OS.patch_start(0x11EF18, 0x80132E08)
        j       load_index_previous
        addiu   t0, r0, 0x0000              // index id for 1p
        nop
        _return:
        OS.patch_end()         
        
        li      t1, onep_button_pointer_struct // insert ram address of pointer to index 0
        beq	    a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0001              // new index id 
        li      t1, training_button_pointer // insert ram address of pointer to index 1
        beq     a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0002              // new index id 
        li	    t1, bonus1_button_pointer   // insert ram address of pointer to index 2
        beq	    a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0003     			// new index id 
        li      t1, bonus2_button_pointer	// insert ram address of pointer to index 3
        beq	    a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0004     			// new index id 
        li	    t1, bonus3_button_pointer	// insert ram address of pointer to index 4
        beq	    a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0005     			// new index location 
        li	    t1, remixmodes_button_pointer	// insert ram address of pointer to index 0
        beq	    a2, t0, added_index
        
        addiu   t0, r0, 0x0006     			// new index location 
        li	    t1, remix1p_button_pointer	// insert ram address of pointer to index 6
        beq	    a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0007     			// new index location 
        li      t1, multiman_button_pointer	// insert ram address of pointer to index 7
        beq     a2, t0, added_index
        nop
        
        addiu   t0, r0, 0x0008     			// new index location 
        li      t1, cruel_button_pointer	// insert ram address of pointer to index 8
        beq	    a2, t0, added_index
        nop
        
        added_index:
        j       _return
        nop	
    }
    
    // @ Description
	// loads in pointer address of additional objects when pressing up
    // this removes red highlighting from the previous buttons
	 scope load_index_end_previous_up: {
        OS.patch_start(0x11EE10, 0x80132D00)
		j       load_index_end_previous_up
		addiu   t7, r0, 0x0000
		nop
		_return:
		OS.patch_end() 
		
        
        li      t8, onep_button_pointer_struct
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0001
        
        li      t8, training_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0002
        
        li      t8, bonus1_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0003
        
        li      t8, bonus2_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0004
        
        li      t8, bonus3_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0005
        
        li      t8, remixmodes_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0006
        
        li      t8, remix1p_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0007
        
        li      t8, multiman_button_pointer
        beq     a2, t7, _added_index
        addiu   t7, r0, 0x0008
        
        li      t8, cruel_button_pointer
        beq     a2, t7, _added_index
        nop
        
        _added_index:
        j       _return
        nop  
    }
    
    // @ Description
    // This is largely a copy of 80132BFC, it highlights Bonus 3 and forces Bonus 2 Screen
        index_4_selected: {
        jal     0x800269C0
        addiu   a0, r0, 0x009E
        li      a0, bonus3_button_pointer
        lw      a0, 0x0000(a0)                      // putting this pointer in highlights index 4 object
        
        OS.copy_segment(0x11ED1C, 0x38)             // 80132C0C
        
        j       0x80132E8C
        sw      t8, 0x31C0(at)
	}
    
    // @ Description
    // This is largely a copy of 80132BFC, it highlights Remix Modes Button, changes page and forces 1p Mode Screen
        index_5_selected: {
        jal	    0x800269C0
        addiu	a0, r0, 0x009E
        li      a0, remixmodes_button_pointer       // putting this pointer in highlights index 5 object
        lw		a0, 0x0000(a0)                      // putting this pointer in highlights index 5 object
        addiu   a1, r0, 0x0002
        jal     0x80131B24
        addiu   a2, r0, 0x0005
        
        OS.copy_segment(0x11ED28, 0x10)             // 80132C0C
        
        li      t5, SinglePlayerModes.page_flag     // load page flag address
        addiu   t7, r0, 0x0001                      // page 2 id
        sw      t7, 0x0000(t5)                      // set to page 2
        li      t5, 0x801331B8                      // load original menu id
        addiu   t7, r0, 0x0006                      // put in Remix 1p Menu ID
        sw      t7, 0x0000(t5)                      // save Remix 1p Menu ID to Menu ID location
        addiu   t5, r0, 0x0008                      // set screen to 1p Mode Menu
        
        OS.copy_segment(0x11ED3C, 0x18)				// 80132C0C
        
        j       0x80132E8C
        sw      t8, 0x31C0(at)
	}
	
    // @ Description
    // This is largely a copy of 80132BFC, it highlights Remix 1p and forces 1p Screen
        index_6_selected: {
        jal	    0x800269C0
        addiu   a0, r0, 0x009E
        li      a0, remix1p_button_pointer          // putting this pointer in highlights index 5 object
        lw      a0, 0x0000(a0)                      // putting this pointer in highlights index 5 object
        addiu   a1, r0, 0x0002
        jal     0x80131B24
        addiu   a2, r0, 0x0006
        
        OS.copy_segment(0x11ED28, 0x10)             // 80132C0C
        
        addiu   t5, r0, 0x0011                      // set screen to 1p CSS
      
        OS.copy_segment(0x11ED3C, 0x18)             // 80132C0C
        
        j       0x80132E8C
        sw      t8, 0x31C0(at)
	}
    
    // @ Description
    // This is largely a copy of 80132BFC, it highlights Multiman and forces Bonus 2 Screen
        index_7_selected: {
        jal	    0x800269C0
        addiu   a0, r0, 0x009E
        li      a0, multiman_button_pointer         // putting this pointer in highlights index 7 object
        lw		a0, 0x0000(a0)						// putting this pointer in highlights index 7 object
        
        OS.copy_segment(0x11ED1C, 0x38)				// 80132C0C
        
        j       0x80132E8C
        sw      t8, 0x31C0(at)
    }
    
    // @ Description
    // This is largely a copy of 80132BFC, it highlights Cruel Multiman and forces Bonus 2 Screen
        index_8_selected: {
        jal	    0x800269C0
        addiu   a0, r0, 0x009E
        li      a0, cruel_button_pointer            // putting this pointer in highlights index 8 object
        lw		a0, 0x0000(a0)						// putting this pointer in highlights index 8 object
        
        OS.copy_segment(0x11ED1C, 0x38)				// 80132C0C
        
        j       0x80132E8C
        sw      t8, 0x31C0(at)
	}

// INDEX AND LOOPING

    // @ Description
    // Fixes Highlighting for Training Style Buttons, such as Remix Mode Button, so that the whole button turns red, instead of a part.
    scope training_button_highlight: {
        OS.patch_start(0x11DCCC, 0x80131BBC)
        j       training_button_highlight
		addiu   v1, r0, 0x0001              // original line 2 
        _return:
        OS.patch_end()   
        
        beq     a2, at, _training_button
        addiu   at, r0, 0x0005
        beq     a2, at, _training_button
        addiu   at, r0, 0x0006
        beq     a2, at, _training_button
        addiu   at, r0, 0x0001
        
        j       0x80131BCC                  // modified original line 1
        nop
        
        _training_button:
        j       _return
        nop
    }
	
    // @ Description
    // extends loop of 1p option index for both pages when going down
    scope increase_index_previous: {
        OS.patch_start(0x11EF38, 0x80132E28)
        j       increase_index_previous
		nop 
        _return:
        OS.patch_end()   
        
        li      t4, SinglePlayerModes.page_flag
        lw      t4, 0x0000(t4)
        bnez    t4, _page_2                 // page check
        addiu	at, r0, 0x0008     			// modified original line 1, page 2
        
        addiu   at, r0, 0x0005              // modified original line 1, page 1
        
        _page_1:
        j		_return
        lui     t4, 0x8013                  // original line 1
        
        _page_2:
        bne     a2, at, _page_1
        nop
        addiu   t2, r0, 0x0006
        sw      t2, 0x0000(v0)
        j       0x80132E44
        lui     t4, 0x8013                  // original line 1
    }
	
	// @ Description
	// Modifies the path taken by index when moving downwards and extends it to work with new buttons.
    // This routine loads in the next button that will get red highlight
	 scope loop_continue_branch: {
        OS.patch_start(0x11EF58, 0x80132E48)
        j		loop_continue_branch
        addiu	at, r0, 0x0000              // insert index 4 for check / original line 1
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end() 
        
        sll     t5, a2, 0x2                 // original line 3
        addiu   t3, r0, 0x0014              // place 14 for timer setting for pause between button jumps
        beq	    a2, at, _index_0            // branch for index 0 button
                
        addiu   at, r0, 0x0001              // insert index 1
        beq     a2, at, _index_1            // branch for index 1 button
                    
        addiu   at, r0, 0x0002              // insert index 2
        beq	    a2, at, _index_2            // branch for index 2 button         
                    
        addiu   at, r0, 0x0003              // insert index 3
        beq	    a2, at, _index_3            // branch for index 3 button      
                    
        addiu   at, r0, 0x0004              // insert index 3
        beq	    a2, at, _index_4            // branch for index 4 button
                    
        addiu   at, r0, 0x0005              // insert index 5
        beq	    a2, at, _index_5            // branch for index 5 button, which is specialized for end of loop
                    
        addiu   at, r0, 0x0006              // insert index 6
        beq	    a2, at, _index_6            // modified original line 2
                    
        addiu   at, r0, 0x0008              // insert index 8
        beq	    a2, at, _index_8            // modified original line 2
        nop
        
        // index 7 routines
        li      t6, multiman_button_pointer // insert index 8 address
        lw      t4, 0x31C4(t4)				// original line 4
        
        j       0x80132E6C					// skip portion that loads address for originals
        nop
        
        _index_0:
        li      t6, onep_button_pointer_struct
        j       0x80132E6C                  // skip portion that loads address for originals
        nop
        
        _index_1:
        li      t6, training_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        nop
        
        _index_2:
        li      t6, bonus1_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        nop
        
        _index_3:
        li      t6, bonus2_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        nop
        
        _index_4:
        li      t6, bonus3_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        nop
        
        _index_5:
        lw      t4, 0x31C4(t4)              // original line 4
        lui     at, 0x8013                  // original line 5
        li      t6, remixmodes_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        sw      t3, 0x31C4(at)              // original line 6 
        
        _index_6:
        li      t6, remix1p_button_pointer
        j       0x80132E6C                  // skip portion that loads address for originals
        nop

        _index_8:
        li      t6, cruel_button_pointer
        lui     at, 0x8013					// original line 5
        j       0x80132E6C                  // skip portion that loads address for originals
        sw      t3, 0x31C4(at)				// original line 6  
    }
	
	// @ Description
	// extends loop of 1p option index when pressing up
	 scope increase_index_previous_up: {
        OS.patch_start(0x11EE30, 0x80132D20)
		j		increase_index_previous_up
		nop  
        _return:        
        OS.patch_end()       

        li      t1, SinglePlayerModes.page_flag
        lw      t1, 0x0000(t1)
        bnez    t1, _page_2                 // page check since pages end on different index IDs
        addiu	t9, r0, 0x0008     			// modified original line 1, page 2
        
        addiu   t9, r0, 0x0005              // modified original line 1, page 1
        
        _page_1:
        j       _return
        lui     t1, 0x8013                  // original line 1
        
        _page_2:
        addiu   t1, r0, 0x0006              // insert top of page 2 menu index ID
        bne     t1, a2, _page_1             // take normal route which subtracts one from index
        nop
        j       0x80132D30                  // take jump that end of index uses and instead inserts the 8 ID above
        lui     t1, 0x8013                  // original line 1
    }   
	
    // @ Description
    // loads in pointer address of index objects
    // this highlights the next button in red when moving upwards
    scope load_index_end_new_up: {
        OS.patch_start(0x11EE68, 0x80132D58)
        j       load_index_end_new_up
        addu    t3, sp, t4		            // original line 1  
        _return:                            
        OS.patch_end()                      
                                            
        addiu   t4, r0, 0x0000	            // insert index 0
        beq     t4, a2, _index_0            
        addiu   t4, r0, 0x0001	            // insert index 1
        beq     t4, a2, _index_1            
        addiu   t4, r0, 0x0002	            // insert index 2
        beq     t4, a2, _index_2            
        addiu   t4, r0, 0x0003	            // insert index 2
        beq     t4, a2, _index_3            
        addiu   t4, r0, 0x0004	            // insert index 4
        beq     t4, a2, _index_4            
        addiu   t4, r0, 0x0005	            // insert index 5
        beq     t4, a2, _index_5            
        addiu   t4, r0, 0x0006	            // insert index 6
        beq     t4, a2, _index_6            
        addiu   t4, r0, 0x0007	            // insert index 7
        beq     t4, a2, _index_7            
        addiu   t4, r0, 0x0008	            // insert index 8
        beq     t4, a2, _index_8            
        nop
        
        bne     t4, a2, _end                // skip index 8 ram insertion if not index 8
        lw      t3, 0x002C(t3)              // original line 2
        
        _index_0:
        li      t3, onep_button_pointer_struct   // insert ram address of pointer to index 1
        j       _end
        nop
        
        _index_1:
        li      t3, training_button_pointer // insert ram address of pointer to index 1
        j       _end
        nop
        
        _index_2:
        li      t3, bonus1_button_pointer   // insert ram address of pointer to index 1
        j		_end
        nop
        
        _index_3:
        li      t3, bonus2_button_pointer   // insert ram address of pointer to index 1
        j		_end
        nop
        
        _index_4:
        li      t3, bonus3_button_pointer   // insert ram address of pointer to index 1
        j		_end
        nop
        
        _index_5:
        li		t3, remixmodes_button_pointer // insert ram address of pointer to index 1
        j		_end
        nop
        
        _index_6:
        addiu   t2, r0, 0x0014               // place 0x14 for save to timer location
        li		t3, remix1p_button_pointer   // insert ram address of pointer to index 1
        lui     at, 0x8013
        j		_end
        sw      t2, 0x31C4(at)
        
        _index_7:
        li		t3, multiman_button_pointer   // insert ram address of pointer to index 1
        j		_end
        nop
        
        _index_8:
        li		t3, cruel_button_pointer   // insert ram address of pointer to index 1
        j		_end
        nop
        
        _end:
        j		_return
        nop
    }
	
	// @ Description
	// screen ID jump set for indexes
	// this determines what button gets the white "click" highlighting and which screen gets jumped to
	 scope index_4_screen_jump: {
        OS.patch_start(0x11EC0C, 0x80132AFC)
        j		index_4_screen_jump
        nop 
        _return:
        OS.patch_end() 
        
        beq	    v0, at, _index_3
        addiu   at, r0, 0x0004
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        beql    v0, at, _index_4
        addiu   at, r0, SinglePlayerModes.BONUS3_ID
        addiu   at, r0, 0x0005
        beql    v0, at, _index_5
        nop
        addiu   at, r0, 0x0006
        beql    v0, at, _index_6
        addiu   at, r0, SinglePlayerModes.REMIX_1P_ID
        addiu   at, r0, 0x0007
        beql    v0, at, _index_7
        addiu   at, r0, SinglePlayerModes.MULTIMAN_ID
        addiu   at, r0, 0x0008
        bne	    v0, at, _end
        addiu   at, r0, SinglePlayerModes.CRUEL_ID
        sw      at, 0x0000(t6)
        
        j       index_8_selected
        addiu   t6, r0, r0
        
        _end:
        j       _return
        nop
        
        _index_4:
        sw      at, 0x0000(t6)
        j       index_4_selected
        addiu   t6, r0, r0
        j       _return
        nop
        
        _index_5:
        sw      r0, 0x0000(t6)
        j       index_5_selected
        addiu   t6, r0, r0
        j       _return
        nop
        
        _index_6:
        sw      at, 0x0000(t6)
        j       index_6_selected
        addiu   t6, r0, r0
        j       _return
        nop
        
        _index_7:
        sw      at, 0x0000(t6)
        j       index_7_selected
        addiu   t6, r0, r0
        j       _return
        nop
        
        _index_3:
        li      at, SinglePlayerModes.singleplayer_mode_flag
        sw      r0, 0x0000(at)						// turn off any alternate css's
        j       0x80132BFC
        addiu   at, r0, 0x0003
    }
    
    // @ Description
	// screen ID jump set and page id set when backing out of page 2
	 scope page_2_exit: {
        OS.patch_start(0x11ED70, 0x80132C60)
        j       page_2_exit
        nop 
        _return:
        OS.patch_end() 
        
        li      t0, SinglePlayerModes.page_flag
        lw      t9, 0x0000(t0)
        bnez    t9, _page_2         // check to see if on page 2, this alters it so it does not change screens, just returns to page 1
        lbu     t9, 0x0000(v0)      // original line 1
        
        j       _return
        addiu   t0, r0, 0x0007      // Main menu screen ID - original line 2
        
        _page_2:
        sw      r0, 0x0000(t0)      // set to page 1
        j       _return
        addiu   t0, r0, 0x0008      // 1p Mode menu screen ID
    }
    
    // CSS SCREENS
	
    // @ Description
	// sets the correct index number when exiting out of css for all Modes, added and original
    // By setting the correct index number, the correct button will be highlighted when exiting
    // 80132970 hook for putting in the correct index number
	 scope css_exit: {
        OS.patch_start(0x11EA80, 0x80132970)
        j		css_exit
        lui		at, 0x8013                  // original line 1  
        _return:
        OS.patch_end() 
        
        li      t8, SinglePlayerModes.singleplayer_mode_flag       // at = SinglePlayer Mode Address
        lw      t8, 0x0000(t8)              // load in mode flag
        beqz    t8, _original               // if original, skip
        nop
        addiu   at, r0, 0x0001
        beq	    t8, at, _bonus3
        addiu   at, r0, 0x0002
        beq	    t8, at, _multiman
        addiu   at, r0, 0x0003
        beq     t8, at, _cruel
        addiu   at, r0, 0x0004
        beq     t8, at, _remix_1p 
        lui     at, 0x8013                  // original line 1
        
        _original:
        addiu   t8, r0, 0x0003
        j       _return
        sw      t8, 0x31B8(at)              // original line 2
        
        _bonus3:
        lui	    at, 0x8013                  // original line 1
        addiu   t8, r0, 0x0004
        j       _return
        sw      t8, 0x31B8(at)              // original line 2
        
        _multiman:
        lui     at, 0x8013                  // original line 1
        addiu   t8, r0, 0x0007
        j       _return
        sw      t8, 0x31B8(at)              // original line 2
        
        _cruel:
        lui     at, 0x8013                  // original line 1
        addiu   t8, r0, 0x0008
        j       _return
        sw      t8, 0x31B8(at)              // original line 2
        
        _remix_1p:
        addiu   t8, r0, 0x0006
        j       _return
        sw      t8, 0x31B8(at)              // original line 2
    }
    
	// @ Description
	//	Loading in the KO amount for the selected character in Multiman and Cruel Multiman Modes
	scope _ko_amount: {
        OS.patch_start(0x149B74, 0x80133B44)
        j	    _ko_amount
        addiu	t0, r0, SinglePlayerModes.MULTIMAN_ID   // insert multiman mode flag	
        _return:
        OS.patch_end()
        
        li      t9, SinglePlayerModes.singleplayer_mode_flag    // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        beq     t9, t0, _multiman           // if multiman, skip
        addiu   t0, r0, SinglePlayerModes.CRUEL_ID
        
        beq     t9, t0, _cruel              // if cruel multiman, skip
        addiu   t0, r0, 0x0001				// original line 2
        
        j       _return
        addiu	t9, r0, 0x0002				// original line 1, sets amount of digits
        
        _cruel:
        li      t9, Character.CRUEL_HIGH_SCORE_TABLE
        j       _cruel_2
        nop
        
        _multiman:
        li      t9, Character.MULTIMAN_HIGH_SCORE_TABLE
        _cruel_2:
        sll	    a0, a0, 0x0002				// a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
        addu    t9, t9, a0
        addiu   t0, r0, 0x0001				// original line 2
        lw      v0, 0x0000(t9)				// loads number of KO's the character has had
        j       _return
        addiu   t9, r0, 0x0005				// t9 sets the amount of digits at 5
        }
		
    // @ Description
    //	Loading in the finish time for the selected character
    scope load_bonus3_time: {
    OS.patch_start(0x14978C, 0x8013375C)
        j	    load_bonus3_time
        addiu   a2, r0, SinglePlayerModes.BONUS3_ID			// insert bonus 3 mode ID
        _return:
        OS.patch_end()
        
        li      a1, SinglePlayerModes.singleplayer_mode_flag       // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 1 if Bonus 3
        bne     a1, a2, _original           // if normal, skip
        nop
        
        li      a2, Character.BONUS3_HIGH_SCORE_TABLE
        sll     a0, a0, 0x0002              // a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
        addu    a2, a2, a0              
        lw      v0, 0x0000(a2)              // loads finish time the character has had
        lw      v1, 0x0000(a2)              // loads finish time the character has had
        
        _original:
        sw		v0, 0x0040(sp)				// original line 1
        j		_return
        or		a0, r0, r0
	}
	
    // @ Description
    //	Prevents a branch that is typically used to shift from platform counting to time display after completion 
	scope _timedisplay_skip: {
        OS.patch_start(0x149C14, 0x80133BE4)
        j	    _timedisplay_skip
        addiu	t9, r0, SinglePlayerModes.BONUS3_ID			
        _return:
        OS.patch_end()
        
        li      t7, SinglePlayerModes.singleplayer_mode_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if Bonus 3
        beq     t7, t9, _time_count         // jump to time if Bonus 3
        nop
        bnez    t7, _platform_count         // if multiman, skip
        nop
        
        beq     v0, r0, _platform_count     // modified original line 1
        nop
        
        _time_count:
        j       _return
        nop
        
        _platform_count:
        j       0x80133BFC                  // modified original line 1
        nop
	}
	
	// @ Description
	// This adds total KOs to the multiman screens.
	scope total_kos_: {
	    // The check on other bonus CSS screens for showing the total line
	    OS.patch_start(0x14CCC8, 0x80136C98)
	    jal     total_kos_._check
	    or      s0, r0, r0                  // original line 1
	    OS.patch_end()
	    // Just after the TOTAL texture is rendered
	    OS.patch_start(0x149D4C, 0x80133D1C)
	    jal     total_kos_._total_texture
	    sb      t5, 0x002A(v0)              // original line 1
	    OS.patch_end()

	    _check:
	    addiu   s1, r0, 0x000C              // original line 2

	    // let's always show the total for multiman, so return 1 for v0 in that case
	    li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw     	t6, 0x0000(t6)              // t0 = single player mode flag
        lli     at, SinglePlayerModes.MULTIMAN_ID
        beq     t6, at, _show_total         // if multiman mode, show total
        lli     at, SinglePlayerModes.CRUEL_ID
        beq     t6, at, _show_total         // if cruel multiman mode, show total
        nop
        jr      ra                          // otherwise continue normally
        nop

        _show_total:
        // jump to where they set v0 to 1
        j       0x80136CC0
        nop

        _total_texture:
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw     	t6, 0x0000(t6)              // t0 = single player mode flag
        lli     at, SinglePlayerModes.MULTIMAN_ID
        beq     t6, at, _multiman           // if multiman mode, draw total
        lli     at, SinglePlayerModes.CRUEL_ID
        beq     t6, at, _cruel              // if cruel multiman mode, draw total
        nop
        jr      ra
        swc1    f4, 0x005C(v0)              // original line 2

        _multiman:
        li      t0, Character.MULTIMAN_HIGH_SCORE_TABLE
        j       _draw_textures
        nop

        _cruel:
        li      t0, Character.CRUEL_HIGH_SCORE_TABLE

        _draw_textures:
        swc1    f6, 0x005C(v0)              // update y
        lli     at, 0x0018                  // at = new width
        sh      at, 0x0014(v0)              // update width (just will be "TOTAL")
        lui     at, 0x436B                  // at = new x position
        sw      at, 0x0058(v0)              // update x position

        // now draw number of kos
        or      a0, r0, s0                  // a0 = texture object
        lli     a1, 0x0000                  // a1 = total ko's
        lli     at, 0x0000                  // at = character ID

        _loop:
        sll     t1, at, 0x0002              // t1 = offset to next character ko count
        addu    t1, t0, t1                  // t1 = next ko count
        lw      t1, 0x0000(t1)              // t1 = ko count for character at index at
        li      t9, 0xAAAAAAAA              // TEMP FIX for how console writes AAAAAAAA to added SRAM spots and causes issues
        beql    t1, t9, _update
        addiu   t1, r0, r0
        _update:
        addu    a1, a1, t1                  // update total ko count
        addiu   at, at, 0x0001              // at++
        sltiu   t1, at, Character.NUM_CHARACTERS // t1 = 0 if we counted everyone
        bnez    t1, _loop                   // keep looking if we haven't counted everyone
        nop

        lui     a2, 0x4361                  // a2 = x position (right justified)
        lui     a3, 0x434D                  // a3 = y position
        addiu   t8, sp, 0x0034              // t8 = pointer to palette details
        sw      r0, 0x0000(t8)              // R = 0 for palette
        sw      r0, 0x0004(t8)              // G = 0 for palette
        sw      r0, 0x0008(t8)              // B = 0 for palette
        lli     at, 0x0007E                 // R = 7E for color
        sw      at, 0x000C(t8)              // ~
        lli     at, 0x0007C                 // G = 7C for color
        sw      at, 0x0010(t8)              // ~
        lli     at, 0x00077                 // B = 77 for color
        sw      at, 0x0014(t8)              // ~
        sw      t8, 0x0010(sp)              // save palette details pointer in stack (argument for 0x80131CEC)
        lli     t9, 0x0006                  // t9 = number of digits
        sw      t9, 0x0014(sp)              // save number of digits in stack (argument for 0x80131CEC)
        addiu   t0, r0, 0x0001				// t0 = ?
        jal     0x80131CEC                  // draw total ko count
        sw      t0, 0x0018(sp)              // save t0 in stack (argument for 0x80131CEC)

        j       0x80133F38                  // skip to end
        nop
	}
    
    // @ Description
    // This alters the image that is loaded besides what would normally be the amount of platforms (or targets)
	scope counter_graphic: {
        OS.patch_start(0x149B10, 0x80133AE0)
        j	    counter_graphic
        lw      t9, 0x7E0C(t9)              // original line 1
        _return:
        OS.patch_end()
        
        li      t0, SinglePlayerModes.singleplayer_mode_flag // t0 = multiman flag
        lw     	t0, 0x0000(t0)              // t0 = 1 if Bonus 3
        bnez    t0, _multiman               // if added mode, skip
        nop
        
        j       _return
        addiu   t0, r0, 0x1898              // modified original line 2
        
        _multiman:
        j       _return
        addiu   t0, r0, 0x34E8              // this moves the file offset so it loads the added KO image instead of platforms
	}
	
    // @ Description
    // This alters the image that is loaded as the header in Bonus CSS 2
    scope header_graphic: {
        OS.patch_start(0x1492CC, 0x8013329C)
        j	    header_graphic
        lw      t0, 0x7E04(t0)				// original line 1
        _return:
        OS.patch_end()
        
        li      t1, SinglePlayerModes.singleplayer_mode_flag       // t1 = multiman flag
        lw      t1, 0x0000(t1)              // t1 = 2 if multiman
        addiu   t6, r0, SinglePlayerModes.BONUS3_ID
        beq     t1, t6, _bonus3
        addiu   t6, r0, SinglePlayerModes.MULTIMAN_ID
        beq     t1, t6, _multiman
        addiu   t6, r0, SinglePlayerModes.CRUEL_ID
        beq     t1, t6, _cruel
        addiu   t6, r0, r0                  // clear our t6 in abundance of caution
                        
        j		_return             
        addiu   t1, r0, 0x1058              // modified original line 2
                    
        _bonus3:                
        j		_return             
        addiu	t1, r0, 0x1DD8              // this moves the file offset so it loads the added header image instead of original
                        
        _multiman:              
        j		_return             
        addiu	t1, r0, 0x14D8              // this moves the file offset so it loads the added header image instead of original
                        
        _cruel:             
        j		_return             
        addiu	t1, r0, 0x1958              // this moves the file offset so it loads the added header image instead of original
	}
    
    // @ Description
    // This alters the image that is loaded as the header in Remix 1p
    scope header_graphic_remix_1p: {
        OS.patch_start(0x13C5DC, 0x801343DC)
        j	    header_graphic_remix_1p
        addiu   t6, r0, SinglePlayerModes.REMIX_1P_ID         // Remix ID inserted
        _return:
        OS.patch_end()
        
        li      t0, SinglePlayerModes.singleplayer_mode_flag       // t0 = multiman flag
        lw     	t0, 0x0000(t0)              // t0 = 2 if multiman
        bne     t6, t0, _normal             // branch if not Remix 1p and should use standard 1p Game texture
        lui     t0, 0x0000                  // original line 1
        
        j       _return
        addiu	t0, t0, 0x3758				// this moves the file offset so it loads the added header image instead of original
        
        _normal:
        j       _return
        addiu	t0, t0, 0x0228				// original line 2, sets file offset to normal 1p Game texture
	}
	
	// @ Description
	// When entering a bonus css, this sets a new flag in the original bonus mode flag area so that proper header switching can take place
    scope set_original_flag: {
        OS.patch_start(0x14CC2C, 0x80136BFC)
        j		set_original_flag
        lui		at, 0x8013					// original line 1
        _return:
        OS.patch_end() 
        
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)
        li      t0, SinglePlayerModes.singleplayer_mode_flag       // at = added mode id
        lw      t0, 0x0000(t0)              // load in mode flag
        beql    t0, r0, _end                // if original, skip
        sw      t4, 0x7714(at)              // original line 2, saves to original flag location
                        
        addiu	t3, r0, SinglePlayerModes.BONUS3_ID
        addiu	t1, r0, 0x0002              
        beql	t0, t3, _end                // branch to end if going to Bonus 3
        sw      t1, 0x7714(at)              // save bonus 3 to original flag system
        addiu	t3, r0, 0x0003              
        beql	t0, t1, _end                // branch to end if going to Multiman
        sw      t3, 0x7714(at)              // save multiman to original flag system
        addiu	t1, r0, 0x0004              
        sw		t1, 0x7714(at)              // save cruel to original flag system

        _end: 
        lw      t0, 0x0004(sp)              
        lw      t1, 0x0008(sp)              
        lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop
	}
	
	// @ Description
	// When swapping modes this sets to the correct flag
	scope set_original_flag_swap: {
        OS.patch_start(0x14B91C, 0x801358EC)
        nop
        j       set_original_flag_swap
        nop
        _return:
        OS.patch_end() 
        
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw		t3, 0x000C(sp)
        
        beqz    t6, _end
        addiu   t0, r0, SinglePlayerModes.BONUS3_ID
        li      t3, SinglePlayerModes.singleplayer_mode_flag
        beq     t6, t0, _bonus2_to_bonus3	// since we're transitioning from 2 to 3, we take this branch
        nop
        
        lw      t0, 0x0000(t3)
        addiu   t1, r0, SinglePlayerModes.MULTIMAN_ID
        beq     t0, t1, _multiman_to_cruel
        addiu   t1, r0, SinglePlayerModes.CRUEL_ID
        
        beq     t1, t0, _cruel_to_multiman
        nop
        
        sw      r0, 0x0000(t3)              // since we're transition from bonus 3 to bonus 1, lets remove multiman flags
        j       _end
        sw      r0, 0x0000(v0)              // since we're transitioning from bonus 3, to bonus 1, lets restart the original index
        
        _multiman_to_cruel:
        addiu	t0, r0, 0x0004
        sw		t0, 0x0000(v0)              // save bonus 3 new index to original flag location
        addiu	t0, r0, SinglePlayerModes.CRUEL_ID
        j		_end
        sw		t0, 0x0000(t3)              // save cruel flag to multiman mode flag
        
        _cruel_to_multiman:
        addiu   t0, r0, 0x0003
        sw      t0, 0x0000(v0)              // save bonus 3 new index to original flag location
        addiu   t0, r0, SinglePlayerModes.MULTIMAN_ID
        j       _end
        sw      t0, 0x0000(t3)              // save multiman flag to multiman mode flag
        
        _bonus2_to_bonus3:
        addiu   t0, r0, 0x0002
        sw      t0, 0x0000(v0)              // save bonus 3 new index to original flag location
        addiu   t0, r0, SinglePlayerModes.BONUS3_ID
        sw      t0, 0x0000(t3)              // save bonus 3 flag to multiman mode flag
        
        _end:
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80009A84                  // original line 1
        lw      a0, 0x7718(a0)              // original line 2
        j       _return
        nop
	}
	
    //	skips the "BOARD THE PLATFORMS" FGM Call
    scope _BTP_FGM_skip: {
        OS.patch_start(0x149340, 0x80133310)
        j	    _BTP_FGM_skip
        addiu   t6, r0, SinglePlayerModes.BONUS3_ID				
        _return:
        OS.patch_end()
        
        li      a0, SinglePlayerModes.singleplayer_mode_flag       // a0 = multiman flag
        lw      a0, 0x0000(a0)              // a0 = 2 if multiman
        beq	    a0, t6, _bonus3
        nop
        bnez    a0, _multiman               // if multiman, cruel skip
        nop
        
        jal     0x800269C0					// original line 1
        addiu   a0, r0, 0x01DC				// original line 2
        
        _multiman:
        j       _return
        nop		
        
        _bonus3:
        jal	    0x800269C0					// original line 1
        addiu   a0, r0, 0x01EF				// replace original with Race to the Finish!
        j       _return
        nop	
	}
}
