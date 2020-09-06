scope multi_man: {

	// 80192FA1 - counts down KOs
	// 801938C8 - counts down KOs
	// camera stuff is a mystery
	// platforms and amount on css: 80133A9C
		// 80133AE0 specifically platforms and not targets
	// Bonus 2 CSS Header: 80133260
	
	// 80133B38 gets platform number
	// 80133B64 platform loading routine
	//80131CEC is a number loading subroutine called on different css screens
		// a1= number in hex
		// a2= x position
		// a3= y position

	

// GENERAL

	constant KO_AMOUNT_POINTER(0x801936A0)
	constant TIME_SAVE_POINTER(0x800A4B30)

	// This removes the flag that identifies different 1p modes
	 scope remove_flag: {
        OS.patch_start(0x11EBE8, 0x80132AD8)
		j		remove_flag
		nop 
		_return:
		OS.patch_end() 
		
		li		v0, multiman_css_flag
		sw		r0, 0x0000(v0)
		lui		v0, 0x8013				// original line 1
		
		_end:
		j		_return
		lw		v0, 0x31B8(v0)
    }
	
    // @ Description
    // Flag to indicate if we should screen 14 (aka Bonus Stage 2 CSS) should function as Multiman or as standard
    // 0x0001 = Bonus 3, 0x0002 = Multiman, 0x0003 = Cruel Multiman, 0x0000 = standard
    multiman_css_flag:
    db OS.FALSE
    OS.align(4)
	
	// @ Description
    // Flag to indicate if we should reset the match or return to css menu
    // TRUE = Reset, FALSE = CSS
    reset_flag:
    db OS.FALSE
    OS.align(4)
	
	// @ Description
    // Flag to indicate if we should play the New Record Sound at the end of a match
    // TRUE = Play Sound, FALSE = Normal
    new_record_flag:
    db OS.FALSE
    OS.align(4)

// 1P MENU SCREEN / BUTTONS

	// @ Description
	// Inserts additional button graphics.
    scope add_multi_man_button: {
        OS.patch_start(0x11F0F0, 0x80132FE0)
        j       add_multi_man_button                      
        nop 
        _return:
        OS.patch_end()
        
		jal		0x801320F8
		nop
		jal		multi_man_button_render
		nop
		jal		cruel_button_render
		nop	
		jal		bonus3_button_render
		nop	
           
        _end:
        j       _return                     // return
        nop                                                  
    }
	
	// @ Description
	//  This is the render routine for the Bonus 3 button, largely based on Bonus Button 2 at 801320F8
	scope bonus3_button_render: {
		OS.copy_segment(0x11E208, 0x28)		// 801320F8
		sw		v0, 0x319C(at)				// saving to pointer address location
		OS.copy_segment(0x11E234, 0x3C)		// 801320F8
		lui		at, 0x4260					// originally 0x4286, x location of button
		mtc1	at, f4
		lui		at, 0x430C					// y location of button
		
		OS.copy_segment(0x11E27C, 0x28)		// 8013216C
		addiu	a2, r0, 0x0004				// new index
		xori	a1, a1, 0x0004				// new index, both are used to determine which to highlight when returning to option screen
		
		OS.copy_segment(0x11E2AC, 0x14)		// 8013219C
		addiu	t4, t4, 0x70A8				// loads in the Bonus 3 graphic offset
		lw		a0, 0x0024(sp)
		jal		0x800CCFDC
		addu	a1, t3, t4
		lhu		t5, 0x0024(v0)
		
		lui		at, 0x4296					// originally 0x42AC, x location of text
		mtc1	at, f8
		lui		at, 0x430D					// y location of text
		
		OS.copy_segment(0x11E2E0, 0x38)		// 801321D0
	}
	
	// @ Description
	//  This is the render routine for the multiman button, largely based on Bonus Button 2 at 801320F8
	scope multi_man_button_render: {
		OS.copy_segment(0x11E208, 0x28)		// 801320F8
		sw		v0, 0x31B0(at)				// saving to pointer address location
		OS.copy_segment(0x11E234, 0x3C)		// 801320F8
		lui		at, 0x4210					// originally 0x4286, x location of button
		mtc1	at, f4
		lui		at, 0x4328					// originall, 4314, y location of button
		
		OS.copy_segment(0x11E27C, 0x28)		// 8013216C
		addiu	a2, r0, 0x0005				// new index
		xori	a1, a1, 0x0005				// new index, both are used to determine which to highlight when returning to option screen
		
		OS.copy_segment(0x11E2AC, 0x14)		// 8013219C
		addiu	t4, t4, 0x67E8				// loads in the multiman graphic offset
		lw		a0, 0x0024(sp)
		jal		0x800CCFDC
		addu	a1, t3, t4
		lhu		t5, 0x0024(v0)
		
		lui		at, 0x425C					// originally 0x42AC, x location of text
		mtc1	at, f8
		lui		at, 0x4329					// y location of text
		
		OS.copy_segment(0x11E2E0, 0x38)		// 801321D0
	}
	
	// @ Description
	//  This is the render routine for the cruel multiman button, largely based on Bonus Button 2 at 801320F8
	scope cruel_button_render: {
		OS.copy_segment(0x11E208, 0x28)		// 801320F8
		sw		v0, 0x31B4(at)				// saving to pointer address location
		OS.copy_segment(0x11E234, 0x3C)		// 801320F8
		lui		at, 0x41C8					// originally 0x4286, x location of button
		mtc1	at, f4
		lui		at, 0x433E					// y location of button
		
		OS.copy_segment(0x11E27C, 0x28)		// 8013216C
		addiu	a2, r0, 0x0006				// new index
		xori	a1, a1, 0x0006				// new index, both are used to determine which to highlight when returning to option screen
		
		OS.copy_segment(0x11E2AC, 0x14)		// 8013219C
		addiu	t4, t4, 0x6C48				// loads in the cruel multiman graphic offset
		lw		a0, 0x0024(sp)
		jal		0x800CCFDC
		addu	a1, t3, t4
		lhu		t5, 0x0024(v0)
		
		lui		at, 0x4230					// originally 0x42AC, x location of text
		mtc1	at, f8
		lui		at, 0x433F					// y location of text
		
		OS.copy_segment(0x11E2E0, 0x38)		// 801321D0
	}
	
	// these allow movement of the x and y locations of the buttons and text for each original index slot
        
		// 1p
		OS.patch_start(0x11DF90, 0x80131E80)
        lui		a1, 0x42F8						// originally 42F8
		lui     a2, 0x41B0						// originally 4228
        OS.patch_end()     

		OS.patch_start(0x11DFD8, 0x80131EC8)
        lui  	at, 0x4321						// originally 4321
		mtc1	at, f4
		lui		at, 0x41C8						// originally 4238
        OS.patch_end() 

		// Training
		OS.patch_start(0x11E068, 0x80131F58)
		lui		a1, 0x42C6		// 42C6
		lui     a2, 0x4264		// 42A8
        OS.patch_end()     

		OS.patch_start(0x11E0B4, 0x80131FA4)
        lui  	at, 0x42D6		// 42D6
		mtc1	at, f4
		lui		at, 0x426B		// 42AE
        OS.patch_end()   
		
		// Bonus 1
		OS.patch_start(0x11E160, 0x80132050)
        lui  	at, 0x429C					// original x position 429C
		mtc1	at, f4
		lui		at, 0x42C0					// 42FC
        OS.patch_end()  

		OS.patch_start(0x11E1C4, 0x801320B4)
        lui  	at, 0x42C2					// original x position 42C2
		mtc1	at, f8
		lui		at, 0x42C2					// 42FE
        OS.patch_end()

		// Bonus 2
		OS.patch_start(0x11E270, 0x80132160)
        lui  	at, 0x4282					// original x position 4286
		mtc1	at, f4
		lui		at, 0x42EC					// original y position 4314
        OS.patch_end()  

		OS.patch_start(0x11E2D4, 0x801321C4)
        lui  	at, 0x42AC					// original x position 42AC
		mtc1	at, f8
		lui		at, 0x42EE					// original y position 4315
        OS.patch_end() 
	
	// loads in pointer addresses of added index objects
	 scope load_index_previous: {
        OS.patch_start(0x11EF18, 0x80132E08)
        j		load_index_previous
		addiu	t0, r0, 0x0004     			// new index location      
		nop
		_return:
        OS.patch_end()         
		
		lui		t1, 0x8013					// insert ram address of pointer to index 4 part 1
		beq		a2, t0, added_index
		addiu	t1, t1, 0x319C				// insert ram address of pointer to index 4 part 2
		
		addiu	t0, r0, 0x0005     			// new index location 
		lui		t1, 0x8013					// insert ram address of pointer to index 4 part 1
		beq		a2, t0, added_index
		addiu	t1, t1, 0x31B0				// insert ram address of pointer to index 4 part 2
		
		addiu	t0, r0, 0x0006     			// new index location 
		lui		t1, 0x8013					// insert ram address of pointer to index 4 part 1
		beq		a2, t0, added_index
		addiu	t1, t1, 0x31B4				// insert ram address of pointer to index 4 part 2
		
		sll		t0, a2, 0x2					// original line 1
		addu	t1, sp, t0					// original line 2
		lw		t1, 0x002C(t1)				// original line 3
		
		added_index:
		j		_return
		nop	
    }
	
	// @ Description
	// extends loop of 1p option index
	 scope increase_index_previous: {
        OS.patch_start(0x11EF38, 0x80132E28)
		addiu	at, r0, 0x0006     			// new index location      
        OS.patch_end()         
    }
	
	// @ Description
	// modifies the path taken by index when moving downwards and extends it to work with new buttons
	 scope loop_continue_branch: {
        OS.patch_start(0x11EF58, 0x80132E48)
		j		loop_continue_branch
		addiu	at, r0, 0x0004				// insert index 4 for check / original line 1
		nop
		nop
		nop
		nop
		_return:
		OS.patch_end() 
		
		sll		t5, a2, 0x2					// original line 3
		
		beq		a2, at, _index_4			// branch for index 4 button
		lui		t6, 0x8013				    // first part of ram address for added index pointers
		
		addiu	at, r0, 0x0005				// insert index 5
		beq		a2, at, _index_5			// branch for index 5 button
		lui		t6, 0x8013				    // first part of ram address for added index pointers
		
		addiu	at, r0, 0x0006				// insert index 6 and end of loop
		bne		a2, at, _original_index		// modified original line 2
		nop
		
		addiu	t6, t6, 0x31B4				// insert ram address of pointer to index 6
		lw		t4, 0x31C4(t4)				// original line 4
		lui		at, 0x8013					// original line 5
		j		0x80132E6C					// skip portion that loads address for originals
		sw		t3, 0x31C4(at)				// original line 6  
		
		_index_4:
		j		0x80132E6C					// skip portion that loads address for originals
		addiu	t6, t6, 0x319C				// insert ram address of pointer to index 5 part 2

		_index_5:
		j		0x80132E6C					// skip portion that loads address for originals
		addiu	t6, t6, 0x31B0				// insert ram address of pointer to index 5 part 2
		
		_original_index:
		j		0x80132E64					// jumps to place the original bne did
		nop
    }
	
	// @ Description
	// loads in pointer address of additional objects when pressing up
	 scope load_index_end_previous_up: {
        OS.patch_start(0x11EE10, 0x80132D00)
		j		load_index_end_previous_up
		lui		t8, 0x8013     			    // insert ram address of pointer 
		nop
		_return:
		OS.patch_end() 
		
		addiu	t7, r0, 0x0004				// index 4 placed in for check
		beql	a2, t7, _added_index		// branch for index for
		addiu	t8, t8, 0x319C				// insert ram address of pointer to last index object
		
		addiu	t7, r0, 0x0005				// index 5 placed in for check
		beql	a2, t7, _added_index		// branch for index for
		addiu	t8, t8, 0x31B0				// insert ram address of pointer to last index object
		
		addiu	t7, r0, 0x0006				// index 6 placed in for check
		beql	a2, t7, _added_index		// branch for index for
		addiu	t8, t8, 0x31B4				// insert ram address of pointer to last index object
		
		sll		t7, a2, 0x2					// original line 1
		addu	t8, sp, t7					// original line 2
		lw		t8, 0x002C(t8)				// original line 3
		
		_added_index:
		j		_return
		nop  
    }	
	
	// @ Description
	// extends loop of 1p option index when pressing up
	 scope increase_index_previous_up: {
        OS.patch_start(0x11EE30, 0x80132D20)
		addiu	t9, r0, 0x0006     			// new index location      
        OS.patch_end()         
    }   
	
	// @ Description
	// loads in pointer address of index 4 object
	 scope load_index_end_new_up: {
        OS.patch_start(0x11EE68, 0x80132D58)
		j		load_index_end_new_up
		addu	t3, sp, t4					// original line 1  
		_return:
		OS.patch_end() 
		
		addiu	t4, r0, 0x0004				// insert index 4
		beq		t4, a2, _index_4
		addiu	t4, r0, 0x0005				// insert index 5
		beq		t4, a2, _index_5
		addiu	t4, r0, 0x0006				// insert index 6
		beq		t4, a2, _index_6
		nop
		
		bne		t4, a2, _end				// skip index 6 ram insertion if not index 6
		lw		t3, 0x002C(t3)				// original line 2
		
		_index_4:
		lui		t3, 0x8013     			    // insert ram address of pointer to index 4 part 1
		j		_end
		addiu	t3, t3, 0x319C				// insert ram address of pointer to index 4 part 2
		
		_index_5:
		lui		t3, 0x8013     			    // insert ram address of pointer to index 4 part 1
		j		_end
		addiu	t3, t3, 0x31B0				// insert ram address of pointer to index 4 part 2
		
		_index_6:
		lui		t3, 0x8013     			    // insert ram address of pointer to index 5 part 1
		addiu	t3, t3, 0x31B4				// insert ram address of pointer to index 5 part 2
		
		_end:
		j		_return
		nop
    }
	
	// @ Description
	// screen ID jump set for index 4
	// this determines what button gets the white "click" highlighting and which screen gets jumped to
	 scope index_4_screen_jump: {
        OS.patch_start(0x11EC0C, 0x80132AFC)
		j		index_4_screen_jump
		nop 
		_return:
		OS.patch_end() 
		
		beq		v0, at, _index_3
		addiu	at, r0, 0x0004
		li      t6, multiman_css_flag
		beql	v0, at, _index_4
		addiu   at, r0, 0x0001
		addiu   at, r0, 0x0005
		beql	v0, at, _index_5
		addiu   at, r0, 0x0002
		addiu   at, r0, 0x0006
        bne		v0, at, _end
		addiu   at, r0, 0x0003
		sw      at, 0x0000(t6)
       
		j		index_6_selected
		addiu   t6, r0, r0
		
		_end:
		j		_return
		nop
		
		_index_4:
		sw      at, 0x0000(t6)
		j		index_4_selected
		addiu   t6, r0, r0
		j		_return
		nop
		
		_index_5:
		sw      at, 0x0000(t6)
		j		index_5_selected
		addiu   t6, r0, r0
		j		_return
		nop
		
		_index_3:
        li      at, multiman_css_flag
        sw      r0, 0x0000(at)						// turn off any alternate css's
		j		0x80132BFC
		addiu	at, r0, 0x0003
    }
	
	// This is largely a copy of 80132BFC, it highlights Multiman and forces Bonus 2 Screen
	index_4_selected: {
	jal		0x800269C0
	addiu	a0, r0, 0x009E
	lui		a0, 0x8013							// object pointer address
	lw		a0, 0x319C(a0)						// putting this pointer in highlights index 4 object
	OS.copy_segment(0x11ED1C, 0x38)				// 80132C0C
	j		0x80132E8C
	sw		t8, 0x31C0(at)
	}
	
	// This is largely a copy of 80132BFC, it highlights Multiman and forces Bonus 2 Screen
	index_5_selected: {
	jal		0x800269C0
	addiu	a0, r0, 0x009E
	lui		a0, 0x8013							// object pointer address
	lw		a0, 0x31B0(a0)						// putting this pointer in highlights index 5 object
	OS.copy_segment(0x11ED1C, 0x38)				// 80132C0C
	j		0x80132E8C
	sw		t8, 0x31C0(at)
	}
	
	// This is largely a copy of 80132BFC, it highlights Multiman and forces Bonus 2 Screen
	index_6_selected: {
	jal		0x800269C0
	addiu	a0, r0, 0x009E
	lui		a0, 0x8013							// object pointer address
	lw		a0, 0x31B4(a0)						// putting this pointer in highlights index 6 object
	OS.copy_segment(0x11ED1C, 0x38)				// 80132C0C
	j		0x80132E8C
	sw		t8, 0x31C0(at)
	}
	
	// CSS SCREEN
	
	// @ Description
	// sets the correct index number when exiting out of css
	 scope css_exit: {
        OS.patch_start(0x11EA80, 0x80132970)
		j		css_exit
		lui		at, 0x8013					// original line 1  
		_return:
		OS.patch_end() 
		
		li      t8, multiman_css_flag       // at = multiman flag
        lw      t8, 0x0000(t8)              // load in mode flag
        beqz    t8, _original               // if original, skip
        nop
		addiu	at, r0, 0x0001
		beq		t8, at, _bonus3
		addiu	at, r0, 0x0002
		beq		t8, at, _multiman
		addiu	at, r0, 0x0003
		beq		t8, at, _cruel
		lui		at, 0x8013					// original line 1
		
		_original:
		addiu	t8, r0, 0x0003
		j		_return
		sw		t8, 0x31B8(at)				// original line 2

		_bonus3:
		lui		at, 0x8013					// original line 1
		addiu	t8, r0, 0x0004
		j		_return
		sw		t8, 0x31B8(at)				// original line 2
		
		_multiman:
		lui		at, 0x8013					// original line 1
		addiu	t8, r0, 0x0005
		j		_return
		sw		t8, 0x31B8(at)				// original line 2
		
		_cruel:
		addiu	t8, r0, 0x0006
		j		_return
		sw		t8, 0x31B8(at)				// original line 2
    }
	
	// 80132970 hook for putting in the correct index number
    
	// @ Description
	//	Loading in the KO amount for the selected character
	scope _ko_amount: {
	OS.patch_start(0x149B74, 0x80133B44)
		j	    _ko_amount
        addiu	t0, r0, 0x0002				// insert multiman mode flag	
		_return:
        OS.patch_end()
		
		li      t9, multiman_css_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        beq     t9, t0, _multiman               // if multiman, skip
        addiu	t0, r0, 0x0003
		
		beq     t9, t0, _cruel                  // if multiman, skip
		addiu	t0, r0, 0x0001				// original line 2
		
		j		_return
		addiu	t9, r0, 0x0002				// original line 1, sets amount of digits
		
		_cruel:
		li 		t9, Character.CRUEL_HIGH_SCORE_TABLE
		j		_cruel_2
		nop
		
		_multiman:
		li		t9, Character.MULTIMAN_HIGH_SCORE_TABLE
		_cruel_2:
		sll		a0, a0, 0x0002				// a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
		addu	t9, t9, a0
		addiu	t0, r0, 0x0001				// original line 2
		lw		v0, 0x0000(t9)				// loads number of KO's the character has had
		j		_return
		addiu	t9, r0, 0x0005				// t9 sets the amount of digits at 5
		}
		
	// @ Description
	//	Loading in the finish time for the selected character
	scope load_bonus3_time: {
	OS.patch_start(0x14978C, 0x8013375C)
		j	    load_bonus3_time
        addiu	a2, r0, 0x0001				// insert multiman mode flag	
		_return:
        OS.patch_end()
		
		li      a1, multiman_css_flag       // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 1 if Bonus 3
        bne     a1, a2, _original           // if normal, skip
        nop
		
		li		a2, Character.BONUS3_HIGH_SCORE_TABLE
		sll		a0, a0, 0x0002				// a0 always has character ID due to prior subroutine, this shifts it so it can be used to load character's KO total
		addu	a2, a2, a0
		lw		v0, 0x0000(a2)				// loads finish time the character has had
		lw		v1, 0x0000(a2)				// loads finish time the character has had
		
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
        addiu	t9, r0, 0x0001			
		_return:
        OS.patch_end()
		
		li      t7, multiman_css_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if multiman
        beq		t7, t9, _time_count			// jump to time
		nop
		bnez    t7, _platform_count         // if multiman, skip
        nop
		
		beq		v0, r0, _platform_count			// modified original line 1
		nop
		
		_time_count:
		j		_return
		nop
		
		_platform_count:
		j		0x80133BFC					// modified original line 1
		nop
		}
	
	// @ Description
	// This alters the image that is loaded besides what would normally be the amount of platforms (or targets)
	scope counter_graphic: {
	OS.patch_start(0x149B10, 0x80133AE0)
		j	    counter_graphic
        lw		t9, 0x7E0C(t9)				// original line 1
		_return:
        OS.patch_end()
		
		li      t0, multiman_css_flag       // t0 = multiman flag
        lw     	t0, 0x0000(t0)              // t0 = 1 if multiman
        bnez    t0, _multiman               // if multiman, skip
        nop
		
		j		_return
		addiu	t0, r0, 0x1898				// modified original line 2
	
		_multiman:
		j		_return
		addiu	t0, r0, 0x34E8				// this moves the file offset so it loads the added KO image instead of platforms
	}
	
	// @ Description
	// This alters the image that is loaded as the header in Bonus CSS 2
	scope header_graphic: {
	OS.patch_start(0x1492CC, 0x8013329C)
		j	    header_graphic
        lw		t0, 0x7E04(t0)				// original line 1
		_return:
        OS.patch_end()
		
		li      t1, multiman_css_flag       // t1 = multiman flag
        lw     	t1, 0x0000(t1)              // t1 = 1 if multiman
        addiu	t6, r0, 0x0001
		beq     t1, t6, _bonus3
		addiu	t6, r0, 0x0002
		beq     t1, t6, _multiman
		addiu	t6, r0, 0x0003
		beq     t1, t6, _cruel
		addiu	t6, r0, r0					// clear our t6 in abundance of caution
		
		j		_return
		addiu	t1, r0, 0x1058				// modified original line 2
	
		_bonus3:
		j		_return
		addiu	t1, r0, 0x1DD8				// this moves the file offset so it loads the added header image instead of original
		
		_multiman:
		j		_return
		addiu	t1, r0, 0x14D8				// this moves the file offset so it loads the added header image instead of original
		
		_cruel:
		j		_return
		addiu	t1, r0, 0x1958				// this moves the file offset so it loads the added header image instead of original
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
		sw		t3, 0x000C(sp)
		li      t0, multiman_css_flag       // at = multiman flag
        lw      t0, 0x0000(t0)              // load in mode flag
        beql    t0, r0, _end               		// if original, skip
        sw		t4, 0x7714(at)				// original line 2, saves to original flag location
		
		addiu	t3, r0, 0x0001
		addiu	t1, r0, 0x0002
		beql	t0, t3, _end				// branch to end if going to Bonus 3
		sw		t1, 0x7714(at)				// save bonus 3 to original flag system
		addiu	t3, r0, 0x0003
		beql	t0, t1, _end				// branch to end if going to Multiman
		sw		t3, 0x7714(at)				// save multiman to original flag system
		addiu	t1, r0, 0x0004				
		sw		t1, 0x7714(at)				// save cruel to original flag system
		
		_end:
		lw		t0, 0x0004(sp)
		lw		t1, 0x0008(sp)
		lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		j		_return
		nop
	}
	
	// @ Description
	// When swapping modes this sets to the correct flag
	scope set_original_flag_swap: {
        OS.patch_start(0x14B91C, 0x801358EC)
		nop
		j		set_original_flag_swap
		nop
		_return:
		OS.patch_end() 
		
		addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
		sw      t1, 0x0008(sp)              // ~
		sw		t3, 0x000C(sp)
		
		beqz	t6, _end
		addiu	t0, r0, 0x0001
		li		t3, multiman_css_flag
		beq		t6, t0, _bonus2_to_bonus3	// since we're transitioning from 2 to 3, we take this branch
		nop
		lw		t0, 0x0000(t3)
		addiu	t1, r0, 0x0002
		beq		t0, t1, _multiman_to_cruel
		addiu	t1, r0, 0x0003
		beq		t1, t0, _cruel_to_multiman
		nop
		
		sw		r0, 0x0000(t3)				// sense we're transition from bonus 3 to bonus 1, lets remove multiman flags
		j		_end
		sw		r0, 0x0000(v0)				// sense w're transitioning from bonus 3, to bonus 1, lets restart the original index
		
		_multiman_to_cruel:
		addiu	t0, r0, 0x0004
		sw		t0, 0x0000(v0)				// save bonus 3 new index to original flag location
		addiu	t0, r0, 0x0003
		j		_end
		sw		t0, 0x0000(t3)				// save cruel flag to multiman mode flag
		
		_cruel_to_multiman:
		addiu	t0, r0, 0x0003
		sw		t0, 0x0000(v0)				// save bonus 3 new index to original flag location
		addiu	t0, r0, 0x0002
		j		_end
		sw		t0, 0x0000(t3)				// save multiman flag to multiman mode flag
		
		_bonus2_to_bonus3:
		addiu	t0, r0, 0x0002
		sw		t0, 0x0000(v0)				// save bonus 3 new index to original flag location
		addiu	t0, r0, 0x0001
		sw		t0, 0x0000(t3)				// save bonus 3 flag to multiman mode flag
		
		_end:
		lw		t0, 0x0004(sp)
		lw		t1, 0x0008(sp)
		lw      t3, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		jal		0x80009A84					// original line 1
		lw		a0, 0x7718(a0)				// original line 2
		j		_return
		nop
	}
	
	//	skips the "BOARD THE PLATFORMS" FGM Call
	scope _BTP_FGM_skip: {
	OS.patch_start(0x149340, 0x80133310)
		j	    _BTP_FGM_skip
        addiu	t6, r0, 0x0001				
		_return:
        OS.patch_end()
		
		li      a0, multiman_css_flag       // a0 = multiman flag
        lw      a0, 0x0000(a0)              // a0 = 1 if multiman
        beq	    a0, t6, _bonus3
		nop
		bnez    a0, _multiman               // if multiman, cruel skip
        nop
		
		jal		0x800269C0					// original line 1
		addiu	a0, r0, 0x01DC				// original line 2
		
		_multiman:
		j		_return
		nop		
		
		_bonus3:
		jal		0x800269C0					// original line 1
		addiu	a0, r0, 0x01EF				// replace original with Race to the Finish!
		j		_return
		nop	
	}
	
	// BONUS GAME FUNCTIONALITY
	
	 scope bonus2_css_2_1p: {
        OS.patch_start(0x14CAF8, 0x80136AC8)		
        j	    bonus2_css_2_1p
        lui		v0, 0x800A				// original line 1
		_return:
        OS.patch_end()
		
		addiu	v0, v0, 0x4AD0			// original line 2
		li      t5, multiman_css_flag
		lw		t5, 0x0000(t5)
		bnez	t5, _1p_load
		nop

		j		_return
		nop


		_1p_load:
		lbu		t3, 0x0000(v0)
		addiu	t5, r0, 0x0034
		sb		t5, 0x0000(v0)				// sets screen to 1p
		jal		_1p_stage_setting			// refreshes 1p and sets the stage for it
		sb		t3, 0x0001(v0)
		jal		0x80005C74
		nop
		beq		r0, r0, end
		lw		ra, 0x0014(sp)

		end:
		addiu	sp, sp, 0x0018
		jr		ra
		nop
		
		// based on 0x80137F10, 0x140118
		_1p_stage_setting:
		addiu	t6,	r0, 0x0005			// unclear what this 5 is for
		lui		v0, 0x800A
		addiu	v0, v0, 0x4AD0
		lui		t7, 0x8013
		lw		t7, 0x76F8(t7)			//	load port ID
		sb		t6, 0x0016(v0)
		addiu	t8, r0, 0x0002			// set to normal difficulty for now
		lui		a0, 0x8014
		addiu	a0, a0, 0x8EE8
		sb		r0, 0x0017(v0)			// unknown
		lui		v1, 0x800A
		sb		t7, 0x0013(v0)
		addiu	v1, v1, 0x44E0
		addiu	t0, r0, 0x0001			// unknown purpose
		// sb		t8, 0x0454(v1) 		// this sets the difficulty, but causes a conflict out of bonus 2 that leads to sram issues
		addiu	t9, r0, 0x0000			// stocks set 1
		addiu	sp, sp, 0xFFE8
		sw		ra, 0x0014(sp)		
		beq		t0, r0, _skip1
		// sb		t9, 0x045B(v1)		// this sets the stocks, but causes a conflict out of bonus 2 that leads to sram issues
		nop
		
		lui		t1, 0x8013
		addiu	t1, t1, 0x7668
		lw		t1,	0x0000(t1)			// loads character ID of selected character in Bonus 2 CSS
		beq		r0, r0, _skip2
		sb		t1, 0x0014(v0)
		
		_skip1:
		addiu	t2, r0, 0x001C
		sb		t2, 0x0014(v0)

		_skip2:
		li		t3,	0x8013766C
		lw		t3, 0x0000(t3)
		jal		0x800D45F4
		sb		t3, 0x0015(v0)
	
		lw		ra, 0x0014(sp)
		addiu	sp, sp, 0x0018
		jr		ra
		nop
		
		// t6 is 5, t7 is port ID), t8 is difficulty, t0 is 1, t9 is stocks, t3 is 0, one of the unknown ones is probably used for a check to refresh
		
		
		// 80137F98
		
		
	}
	
	// setting polygon loading ram address
	// 	8018 +
	//	D874 = (Normal) Opponent 1/2 (allies only work on this) (a third opponent is a random character if added)
	//	DAC0 = Opponent 1 x3 (all six costumes)
	//	DC64 = Fighting Polygon Team x3
	//	DDD0 = Opponent 1 x2 (single costume only)
	//	DEEC = Fighting Polygon Team x3 (no on-screen appearance)
	
	scope opponent_type: {
	OS.patch_start(0x10C0C4, 0x8018D864)
		j	    opponent_type
        nop						// original line 2
		_return:
        OS.patch_end()
		addiu   sp, sp, -0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // ~
		addiu	t1, r0, 0x0001
		li      at, multiman_css_flag       // at = multiman flag
        lw     	at, 0x0000(at)              // at = 1 if multiman
        beq		at, t1, _bonus3
		nop
		bnez    at, _multiman               // if multiman, skip
        nop
		lui		at, 0x8019
		addu	at, at, t6					// original line 1
		lw		t6, 0x2E84(at)				// original line 2
        lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		
		j		_return
		nop
	
		_multiman:
		lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		
		li		t6, 0x8018DC64
		j		_return
		nop
		
		_bonus3:
		lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		
		li		t6, 0x8018DEEC
		j		_return
		nop	
	}
	
	// loads in the Style of battle FF (normal) vs. 80 (horde)
	scope battle_style: {
	OS.patch_start(0x10E18C, 0x8018F92C)
		j	    battle_style
        nop						
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 1 if multiman
        bnez    t6, _multiman               // if multiman, skip
        nop
		
		jal		0x80115DE8					// original line 1
		lbu		a0, 0x29BC(a0)				// original line 2
		j		_return
		nop
		
		_multiman:
		jal		0x80115DE8					// original line 1
		addiu	a0, r0, 0x0080
		j		_return
		nop	
	}
	
	//	loads the stage in 1p
	scope _1p_stage: {
	OS.patch_start(0x10BEC4, 0x8018D664)
		j	    _1p_stage
        addiu	t5, r0, 0x0001						
		_return:
        OS.patch_end()
		
		li      t4, multiman_css_flag       // t4 = multiman flag
        lw      t4, 0x0000(t4)              // t4 = 1 if multiman
        beq		t4, t5, _bonus3
		nop
		
		bnez    t4, _multiman               // if multiman, skip
        nop
		
		lbu		t4, 0x0001(s7)				// original line 1
		lw		t5, 0x0000(s6)				// original line 2
		j		_return
		nop
		
		_multiman:
		addiu	t4, r0, 0x000E				// load in Duel Zone
		lw		t5, 0x0000(s6)				// original line 2
		j		_return
		nop
		
		_bonus3:
		addiu	t4, r0, 0x000F				// load in RTF
		lw		t5, 0x0000(s6)				// original line 2
		j		_return
		nop
		}
		
	//	set team attack or not
	scope _team_attack: {
	OS.patch_start(0x10BEF0, 0x8018D690)
		j	    _team_attack
        addiu	t8, r0, 0x0001				// Bonus 3 Mode Flag			
		_return:
        OS.patch_end()
		
		li      t7, multiman_css_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 2 if multiman
		beq		t7, t8, _bonus3
		nop
        bnez    t7, _multiman               // if multiman, skip
        nop
		
		lw		t7, 0x0000(s6)				// original line 1
		j		_return
		sb		t6, 0x0009(t7)				// original line 2
		
		_multiman:
		lw		t7, 0x0000(s6)				// original line 1
		addiu	t6, r0, 0x0000				// set team attack off
		j		_return
		sb		t6, 0x0009(t7)				// original line 2
		
		_bonus3:
		lw		t7, 0x0000(s6)				// original line 1
		addiu	t6, r0, 0x0001				// set team attack on
		j		_return
		sb		t6, 0x0009(t7)				// original line 2
		}
	

	//	Set Item Spawn rate
	scope _item_spawn: {
	OS.patch_start(0x10BF64, 0x8018D704)
		j	    _item_spawn
        addiu	a1, a1, 0x2FA1				// original line 2						
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 2 if multiman
        bnez    t6, _multiman               // if multiman, skip
        nop
		
		j		_return
		lbu		t6, 0x0001(t3)
		
		_multiman:
		j		_return
		addiu	t6, r0, 0x0000				// set item spawn rate to none
		}	
	
	// Set player handicap/knockback ratio
	scope _hmn_knockback: {
	OS.patch_start(0x5209C, 0x800D689C)
		j	    _hmn_knockback
        addiu	a0, r0, 0x0003						
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 3 if cruel multiman
        bne     t6, a0, _end              	// if multiman, skip
        mflo	t6							// original line 1
		
		addiu	a3, r0, 0x0016
		
		_end:	
		j		_return
		addu	a0, s4, t6					// original line 2
		}
	
	//	Opponent CPU knockback ratio
	scope _opponent_knockback: {
	OS.patch_start(0x10BDAC, 0x8018D54C)
		j	    _opponent_knockback
        addu	t5, t9, v1					// original line 2						
		_return:
        OS.patch_end()
		
		li      t8, multiman_css_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 1 if multiman
		addiu	t5, r0, 0x0001
        beq     t8, t5, _bonus3             // if multiman, skip
		addiu	t5, r0, 0x0002
        beq     t8, t5, _multiman           // if multiman, skip
        addiu	t5, r0, 0x0003
		beq     t8, t5, _cruel              // if cruel multiman, skip
		addu	t5, t9, v1					// original line 2	
		
		j		_return
		lbu		t8, 0x0007(t7)				// original line 1
		
		_bonus3:
		addu	t5, t9, v1					// original line 2	
		j		_return
		addiu	t8, r0, 0x0009				// set opponent knockback to what it is on RTF on very hard
		
		_multiman:
		addu	t5, t9, v1					// original line 2	
		j		_return
		addiu	t8, r0, 0x0015				// set opponent knockback to what it is on easy
		
		_cruel:
		j		_return
		addiu	t8, r0, 0x0018				// set opponent knockback to what it is on very hard
		}	
	
	//	Loads number of opponents
	scope _opponent_number_1: {
	OS.patch_start(0x10BF74, 0x8018D714)
		j	    _opponent_number_1
        addiu	at, r0, 0x0001						
		_return:
        OS.patch_end()
		
		li      t4, multiman_css_flag       // t4 = multiman flag
        lw      t4, 0x0000(t4)              // t4 = 1 if multiman
        beq		t4, at, _bonus3
		lui		at, 0x8019					// original line 2
		bnez    t4, _multiman               // if multiman, skip
        nop
		
		j		_return
		lbu		t4, 0x0008(s7)				// original line 1
		
		_multiman:
		j		_return
		addiu	t4, r0, 0x0006				// set opponent number to 6 for no real reason
		
		_bonus3:
		j		_return
		addiu	t4, r0, 0x0003				// set opponent number to 3 as is normally done
		}	
		
	//	Loads opponent number
	scope _opponent_number_2: {
	OS.patch_start(0x10C234, 0x8018D9D4)
		j	    _opponent_number_2
        nop				
		_return:
        OS.patch_end()
		
		li      t8, multiman_css_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 1 if multiman
        bnez    t8, _multiman               // if multiman, skip
        lbu		t8, 0x0008(s7)				// refresh
		
		blezl	t8, branch					// original line 1
		lw		t5, 0x0000(s6)				// original line 2
		j		_return
		nop
		
		_multiman:
		j		_return
		addiu	t8, r0, 0x0004				// set to polygon number
		
		branch:
		j		0x8018FFF4
		nop
		j		_return
		nop
		}

	//	Loads opponent 2
	scope _opponent_2: {
	OS.patch_start(0x10BDC0, 0x8018D560)
		j	    _opponent_2
        addiu	t5, r0, 0x0003				// original line 2						
		_return:
        OS.patch_end()
		
		li      t7, multiman_css_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if multiman
        bnez    t7, _multiman               // if multiman, skip
        nop
		
		j		_return
		lbu		t7, 0x0009(t6)				// original line 1
		
		_multiman:
		j		_return
		addiu	t7, r0, 0x001C				// set to empty or random
		}
	
	//	Sets time limit routine by loading in ram address
	scope _time_limit: {
	OS.patch_start(0x10BF04, 0x8018D6A4)
		j	    _time_limit
        nop		
		nop
		nop
		nop
		_return:
        OS.patch_end()
		
		li      at, multiman_css_flag       // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        bnez    at, _multiman               // if multiman, skip
        nop
		
		sltiu	at, t9, 0x0007
		beq		at, r0, _branch
		sll		t9, t9, 0x2
		lui		at, 0x8019
		addu	at, at, t9
		j		_return
		lw		t9, 0x2E68(at)
		
		_branch:
		j		0x8018D6E0
		nop
		lui		at, 0x8019
		addu	at, at, t9
		j		_return
		lw		t9, 0x2E68(at)
		
		_multiman:
		li		t9, 0x8018D6D0				// infinite time
		j		_return
		nop
		}
	
	// @ Description
	//	Stops strange glitch which messes up position of percents during the transition from 34 to 35 KOs
	scope _percent_fix: {
	OS.patch_start(0x10D930, 0x8018F0D0)
		j	    _percent_fix
        addiu	t4, t4, 0x33D0				// original line 1
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t9 = multiman flag
        lw      t6, 0x0000(t6)              // t9 = 1 if multiman
        addiu	t5, r0, 0x0002
		beq     t6, t5, _multiman               // if multiman, skip
        addiu	t5, r0, 0x0003
		beq     t6, t5, _multiman               // if multiman, skip
		nop
		
		_standard:
		j		_return
		addu	v0, t3, t4					// original line 2
		
		_multiman:
		addiu	t6, r0, 0x04E0
		bne		t6, t3, _standard
		nop
		li		v0, 0x80193400				// load in alternate safe address
		j		_return
		nop									
	}
		
	//	Loads in routine which sets up how cpus spawn
	scope _spawning_style: {
	OS.patch_start(0x10D360, 0x8018EB00)
		j	    _spawning_style
        addu	at, at, t6					// original line 1						
		_return:
        OS.patch_end()
		addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
		addiu	t0, r0, 0x0001
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 1 if multiman
        beq		t6, t0, _bonus3
		nop
		
		bnez    t6, _multiman               // if multiman, skip
        nop
		
		lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		j		_return
		lw		t6, 0x2EE0(at)				// original line 2
		
		_multiman:
		lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		li		t6, 0x8018EB20
		j		_return
		nop
		
		_bonus3:
		lw      t0, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
		li		t6, 0x8018EB30
		j		_return
		nop
	}
	
	//	Initial Screen Transition Setting in 1p
	scope _initial_screen_set: {
	OS.patch_start(0x12DC90, 0x80134950)
		j	    _initial_screen_set
        nop					
		_return:
        OS.patch_end()
		
		li      t9, multiman_css_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        bnez    t9, _multiman               // if multiman, skip
        addiu	t9, r0, 0x0001				// original line 1
		
		j		_return
		sb		t9, 0x0000(v0)				// original line 2
		
		_multiman:
		
		
		addiu	t9, r0, 0x0077				// set to an unused screen for purposes of the odd mechanics of 1p screens and loading custom renders
		j		_return
		sb		t9, 0x0000(v0)				// original line 2, this was causing an issue with rendering the correct objects on the right screen
	}
	
	//	This makes the reset button graphic appear
	scope _reset_button: {
	OS.patch_start(0x8F668, 0x80113E68)
		j	    _reset_button
        addiu	at, r0, 0x0077				// Bonus 3, Multiman, Cruel Man "screen" (fake screen)
		_return:
        OS.patch_end()
		
		beq		t7, at, _reset
		addiu	at, r0, 0x0035				// original check
		bne 	t7, at, _normal		        // original line 1	modified
		nop
		
		_reset:
		j		_return
		nop
		
		_normal:
		j		0x80113EA0
		lw		ra, 0x0024(sp)				// original line 2
	}
	
	//	This sets adds the reset feature present in other bonus modes by tweaking a branch and also sets the reset flag to 1
	scope _reset: {
	OS.patch_start(0x8FD28, 0x80114528)
		j	    _reset
        addiu	at, r0, 0x0077				// Bonus 3, Multiman, Cruel Man "screen" (fake screen)				
		_return:
        OS.patch_end()
		
		
		beq		t9, at, _multiman				
		addiu	at, r0, 0x0035				// set screen ID under normal circumstances
		bne		t9, at, _normal				// modified original line 1
		nop
		j		_return
		nop
		
		_multiman:
		addiu   sp, sp,-0x0010              // allocate stack space
		sw		t0, 0x0004(sp)
		sw		t1, 0x0008(sp)
		li		t0, reset_flag				// load reset flag location
		addiu	t1, r0, 0x0001				// save a one to it so that it is set to reset
		sw		t1, 0x0000(t0)				// ~
		lw		t0, 0x0004(sp)
		lw		t1, 0x0008(sp)
		addiu   sp, sp, 0x0010              // allocate stack space
		j		_return
		nop		
		
		_normal:
		j		0x80114560
		nop
	}
	
	//	loads the Bonus 3 version of timer
	scope _load_timer: {
	OS.patch_start(0x10E558, 0x8018FCF8)
		j	    _load_timer
        addiu	at, r0, 0x0001				  		
		_return:
        OS.patch_end()

		li      t6, multiman_css_flag       // t9 = multiman flag
        lw      t6, 0x0000(t6)              // t9 = 1 if multiman
        beq     t6, at, _bonus3             // if multiman, skip
        addiu	t6, r0, 0x0000				// clear out in abundance of caution
		
		jal		0x8018F1F8
		nop
		j		_return
		nop
		
		_bonus3:
		jal	    bonus3_timer
		nop
		j		0x8018FD08
		nop
	}

	scope bonus3_timer: {
		addiu	sp, sp, 0xFFB8
		OS.copy_segment(0x112A94, 0x20)		    // 8018E344 in Bonus
		sdc1	f20, 0x0018(sp)
		jal		0x80113398						// may want to skip, used for function of timer
		or		a0, r0, r0						// may want to skip, used for function of timer
		// skip some Bonus stuff that isn't relevant
		OS.copy_segment(0x112AC4, 0x44)		    // 8018E384 to C4 in Bonus, identical to normal version
		lui		at, 0x41F0
		mtc1	at, f22
		lui		at, 0x3F00
		lui		s3, 0x0000
		li		s1, bonus3_timer_struct			// replacement for normal hardcoding that isn't present in 1p
		li		s0, timer_free_space
		addiu	s5, r0, 0x0006
		addu	s5, s0, s5
		lui		s2, 0x8013
		mtc1	at, f20
		addiu	s2, s2, 0x0D40
		addiu	s3, s3, 0x0138
		lw		t8, 0x000C(s2)
		or		a0, s4, r0
		jal		0x800CCFDC
		addu	a1, t8, s3
		OS.copy_segment(0x112B50, 0x114)		    // 8018E410 to 8018e520
		li		a1, update_routine				    // replaces hardcoded subroutine that is put into action by 0x80008188 below
		cvt.s.w	f6, f10
		
		OS.copy_segment(0x112C70, 0x58)		        // 8018e530, probably relates to animation tracks
		jal		0x80008188							// starts update subroutine
		swc1	f8, 0x005C(v0)
		lw		ra, 0x0044(sp)						
		// skip some Bonus stuff that isn't relevant
		OS.copy_segment(0x112CF0, 0x28)		        // 8018E5B0, end of subroutine
		
		bonus3_timer_struct_2:
		dw		0x470CA000
		dw		0x45610000
		dw 		0x44160000
		dw		0x42700000
		dw		0x40C00000
		dw		0x3F0DD2F2
		bonus3_timer_struct:
		dw		0x000000CF
		dw		0x000000DE
		dw		0x000000F0
		dw		0x000000FF
		dw		0x00000111
		dw		0x00000120
		
		// routine responsible for updating the timer throughout the match
		update_routine:
		li		t6, 0x800A4B18						// this replaces a pointer being loaded from a hardcoded location to find a stage information struct that includes current time
		OS.copy_segment(0x11285C, 0x18)		    // 8018E11C to 8018E294
		li		a2, bonus3_timer_struct_2
		bnez	at, _branch1
		nop
		lui		v0, 0x0003
		ori		v0, v0, 0x4BBF
		_branch1:
		mtc1	v0, f4
		OS.copy_segment(0x11288C, 0x24)

		
		li		a3, timer_free_space
		li		t2, timer_free_space
		addiu	t4, r0, 0x0006
		addu	t4, t2, t4
		li		t1, bonus3_timer_struct
		lui		t0, 0x8013
		lui		a0, 0x8013
		mtc1	at, f12
		addiu	a0, a0, 0xEE94
		addiu	t0, t0, 0x0D40
		addiu	t3, r0, 0xFFFB
		OS.copy_segment(0x1128E8, 0xF0)		    // 8018E11C to 8018E294
		
		timer_free_space:
		dw		0x00000000
		dw		0x00000000
		dw		0x00000000
		dw		0x00000000
		}
	
	//	This sets it so that at the end of a added 1p mode match, it returns to the bonus 2 css screen. This is used when character dies or when match cancelled
	scope _end_match_screen: {
	OS.patch_start(0x523D4, 0x800D6BD4)
		j	    _end_match_screen
        lw		t4, 0x004C(sp)				// original line 2					
		_return:
        OS.patch_end()
		
		li      t3, multiman_css_flag       // t3 = multiman flag
        lw      t3, 0x0000(t3)              // t3 = 2 if multiman
        bnez    t3, _multiman               // if multiman, skip
        nop
		
		lbu		t3, 0x0012(s2)				// refresh t3	
		j		_return
		addiu	t2, r0, 0x0008				// original line 2
		
				
		_multiman:
		li		t2, reset_flag
		lw		t3, 0x0000(t2)
		bne		t3, r0, _reset
		addiu	t3, r0, 0x0001				// set to take correct branch
		j		_return
		addiu	t2, r0, 0x0014				// set to Bonus 2 CSS Screen
		
		_reset:
		sw		r0, 0x0000(t2)				// save 0 to reset_flag location so future matches don't automatically reset
		j		_return
		addiu	t2, r0, 0x0034				// set to Bonus 2 CSS Screen
	}
	
	// @ Description
	//	This saves the amount of KOs to SRAM block when the Player Character loses their stock
	scope _ko_save: {
	OS.patch_start(0x10D8A4, 0x8018F044)
		j	    _ko_save
        addiu	at, r0, 0x0002				// insert check
		_return:
        OS.patch_end()
		
		li      t8, multiman_css_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 2 if multiman
        beq     t8, at, _multiman           // if multiman, skip
        addiu	at, r0, 0x0003				// insert check
		beq     t8, at, _cruel              // if multiman, skip
		nop
		
		lb		t8, 0x002B(a2)				// original line 1
		j		_return
		addiu	at, r0, 0xFFFF				// original line 2
		
		
		_cruel:
		addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
		
		li		t8, KO_AMOUNT_POINTER
		lw		t8, 0x0000(t8)
		li		at, Character.CRUEL_HIGH_SCORE_TABLE
		lw		a0, 0x0008(s0)
		sll		a0, a0, 0x0002
		addu	a1, at, a0
		lw		a0, 0x0000(a1)
		ble		t8, a0,	_end
		nop
		li		a0, Character.CRUEL_HIGH_SCORE_TABLE_BLOCK
			
		jal		SRAM.save_
		sw		t8, 0x0000(a1)
		
		j		_end
		nop
		
		_multiman:
		addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
		
		li		t8, KO_AMOUNT_POINTER
		lw		t8, 0x0000(t8)
		li		at, Character.MULTIMAN_HIGH_SCORE_TABLE
		lw		a0, 0x0008(s0)
		sll		a0, a0, 0x0002
		addu	a1, at, a0
		lw		a0, 0x0000(a1)
		ble		t8, a0,	_end
		nop
		li		a0, Character.MULTIMAN_HIGH_SCORE_TABLE_BLOCK
			
		jal		SRAM.save_
		sw		t8, 0x0000(a1)
		
		_end:
		lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0018              // deallocate stack space
		lb		t8, 0x002B(a2)				// original line 1
		j		_return
		addiu	at, r0, 0xFFFF				// original line 2
	}
	
	// @ Description
	//	This saves the time to SRAM block when the Player Character complete race to the finish
	scope _time_save: {
	OS.patch_start(0x90564, 0x80114D64)
		j	    _time_save
        addiu	a1, r0, 0x0001
		_return:
        OS.patch_end()
		
	
		sw		ra, 0x0014(sp)		      // original line 1
		addiu   sp, sp,-0x0010              // allocate stack space
		sw      t4, 0x0004(sp)              // ~
		sw      t0, 0x0004(sp)              // ~
		sw      t1, 0x0008(sp)              // ~
		sw      t2, 0x000C(sp)              // ~
		li      a0, multiman_css_flag     // a0 = multiman flag
        lw      a0, 0x0000(a0)            // a0 = 1 if bonus 3
        bne     a0, a1, _original         // if multiman, skip
        nop
		
		
		li		a1, TIME_SAVE_POINTER					// time address loaded in
		li		a3, Character.BONUS3_HIGH_SCORE_TABLE	// high score table start loaded in
		lw		a0, 0x0008(v0)							// character ID loaded in
		sll		a0, a0, 0x0002							// shifted left to find character's word
		addu	a3, a0, a3								// character's save location address put in a3
		lw	 	t2, 0x0000(a3)							// load in current record
		beq		t2, r0, _no_previous_record				// if there is no record, skip next check and new record sound effect function
		lw		t4, 0x0000(a1)							// finish time loaded in
		li		t0, 0xAAAAAAAA
		beq		t2, t0, _no_previous_record				// console fix
		nop
		//li		t0, 0x00034BC0
		//sltu	t1, t2, t0
		//blez	t1, _no_previous_record				// fail safe
		//nop
		
		sltu	t1, t4, t2           					
		beq		t1, r0, _original						// if record is a quicker time, do not save new time
		nop
		
		li		t0, new_record_flag
		addiu	t1, r0, 0x0001
		sw		t1, 0x0000(t0)
		
		_no_previous_record:
		li		a0, Character.BONUS3_HIGH_SCORE_TABLE_BLOCK
		sw  	t4, 0x0000(a3)
		lw  	t4, 0x0000(sp)				// ~
		lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw  	t2, 0x000C(sp)				// ~
        addiu   sp, sp, 0x0010              // deallocate stack space	
		jal		SRAM.save_
		nop
		j		_return
		lui		a0, 0x8011				// original line 2
		
		_original:
		lw  	t4, 0x0000(sp)				// ~
		lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw	    t2, 0x000C(sp)				// ~
		addiu   sp, sp, 0x0010              // deallocate stack space
		j		_return
		lui		a0, 0x8011				// original line 2
	}
	
	// @ Description
	//	This saves the time to SRAM block when the Player Character complete race to the finish
	scope _new_record: {
	OS.patch_start(0x8F038, 0x80113838)
		j	    _new_record
        addiu	at, r0, 0x0001
		_return:
        OS.patch_end()
		
		li      t9, multiman_css_flag     // a0 = multiman flag
        lw      t9, 0x0000(t9)            // a0 = 1 if bonus 3
        bne     at, t9, _end              // if not Bonus 3, skip
        nop
			
		li		t9, new_record_flag			// load new record flag address
		lw		at, 0x0000(t9)				// load current flag
		beq		at, r0, _end				// if not a new record, proceed as normal
		addiu	at, r0, 0x01CB				// insert the Complete! sound id into at
		bne		at, a0, _end				// if a0 does not equal Complete! sound, skip
		sw		r0, 0x0000(t9)				// return new record flag to 0
		addiu	a0, r0, 0x1D0				// insert new record sound ID into a0 for later saving
			
		_end:
		lui		at, 0x8013				// original line 1
		j		_return
		addu	at, at, t8				// original line 2
	}
	
	// @ Description
	//	This sets opponent behavior to polygon style
	// 0 = normal
	// 1 = Link Style (initial pause)
	// 2 = Yoshi Team Style
	// 3 = Kirby Team Style
	// 4 = Fighting Polygon Team Style
	// 5 = Mario Bros Style
	// 6 = Giant Donkey Kong Style
	// 8 = Race to the Finish Style
	
	scope _opponent_behavior: {
	OS.patch_start(0x10BE54, 0x8018D5F4)
		j	    _opponent_behavior
        addiu	t5, r0, 0x0001					
		_return:
        OS.patch_end()
		
		li      t8, multiman_css_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 1 if multiman
        beq		t5, t8, _bonus3
		nop
		bnez    t8, _multiman               // if multiman, skip
        nop
		
		lbu		t8, 0x000B(a0)				// original line 1
		j		_return
		sb		t8, 0x2FF8(at)				// original line 2
		
		_multiman:
		addiu	t8, r0, 0x0004				// set opponent behavior ID
		j		_return
		sb		t8, 0x2FF8(at)				// original line 2
		
		_bonus3:
		addiu	t8, r0, 0x0008				// set opponent behavior ID
		j		_return
		sb		t8, 0x2FF8(at)				// original line 2
	}
	
	// @ Description
	//	Prevents a counter from changing so that spawns may continue indefinitely
	scope _infinite_spawn_1: {
	OS.patch_start(0x10CBEC, 0x8018E38C)
		j	    _infinite_spawn_1
        sw		v1, 0x000C(a3)					// original line 1						
		_return:
        OS.patch_end()
		
		li      t7, multiman_css_flag       // t4 = multiman flag
        lw      t7, 0x0000(t7)              // t4 = 1 if multiman
        bnez    t7, _multiman               // if multiman, skip
        nop
		
		j		_return
		addiu	t7, v0, 0x0001				// original line 2
		
		_multiman:
		j		_return
		addiu	t7, v0, r0					// prevent change to spawn counter 1
		}	
		
	// @ Description
	//	Prevents of branch from being taken that occassionally leads to crashes and serves no purpose
	scope _death_crash: {
	OS.patch_start(0x10D8B4, 0x8018F054)
		j	    _death_crash
        addiu	at, r0, 0x0005				// original line 1						
		_return:
        OS.patch_end()
		
		li      t9, multiman_css_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // 
        bnez    t9, _multiman               // if multiman, skip
        nop
		
		
		j		_return
		lbu		t9, 0x0011(a3)				// original line 2
		
		_multiman:
		j		_return
		addiu	t9, r0, 0x0001			    // set to safe number that won't take branch
		}
		
	// @ Description
	//	Prevents a counter from changing so that spawns may continue indefinitely
	scope _infinite_spawn_2: {
	OS.patch_start(0x10CA2C, 0x8018E1CC)
		j	    _infinite_spawn_2
        nop					
		_return:
        OS.patch_end()
		
		li      t7, multiman_css_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if multiman
        bnez    t7, _multiman               // if multiman, skip
        nop
		
		addiu	t7, v0, 0xFFFF				// original line 1
		j		_return
		sb		t7, 0x0000(v1)				// original line 2
		
		_multiman:
		j		_return
		nop
		}
		
	// @ Description
	//	Prevents a counter from changing so that match never ends due to KOs of opponents
	scope _infinite_ko: {
	OS.patch_start(0x10D910, 0x8018F0B0)
		j	    _infinite_ko
        nop					
		_return:
        OS.patch_end()
		
		li      t9, multiman_css_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        bnez    t9, _multiman               // if multiman, skip
        or		t9, t5, t8					// original line 2
		
		
		j		_return
		sb		t4, 0x0000(a2)				// original line 1
		
		_multiman:
		j		_return
		nop									// does save lowered KO countdown
	}
	
	// @ Description
	//	automatically skips preview in multiman by skipping timer and button press checks
	scope _preview_skip: {
	OS.patch_start(0x12DC64, 0x80134924)
		j	    _preview_skip
        nop					
		_return:
        OS.patch_end()
		
		li      at, multiman_css_flag       // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        bnez    at, _multiman               // if multiman, skip
        sltiu	at, v0, 0x003C				// reinsert at
		
		bnel	at, r0, _branch				// modified original line 1
		lw		ra, 0x0014(sp)				// original line 2
				
		j		_return
		nop		
		
		_branch:
		j		0x801349EC
		nop
		
		j		_return
		nop
		
		_multiman:
		j		0x80134934
		nop
		j		_return
		nop							
	}
	
	// @ Description
	//	automatically skips preview song in multiman by skipping a jal
	scope _preview_song_skip: {
	OS.patch_start(0x12E0B0, 0x80134D70)
		j	    _preview_song_skip
        nop					
		_return:
        OS.patch_end()
		
		li      a1, multiman_css_flag       // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 1 if multiman
        bnez    a1, _multiman               // if multiman, skip
        nop
		
		jal		0x80020AB4
		addiu	a1, r0, 0x0023
		
		j		_return
		nop
		
		_multiman:
		j		_return
		addiu	a1, r0, r0					// clear a1 just in case				
	}
	
	// @ Description
	// Skips a c flag function which delays music change
    scope skip_cflag_music_function: {
        OS.patch_start(0x10E514, 0x8018FCB4)
		j       skip_cflag_music_function                      
        addiu	at, r0, 0x0002				// multiman mode check placed in
        _return:
        OS.patch_end()
        
		li      v0, multiman_css_flag       // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 2 if multiman
        beq     v0, at, _multiman           // if multiman, skip
		addiu	at, r0, 0x0003				// multiman mode check placed in
		beq     v0, at, _multiman           // if cruel multiman, skip
        nop

		lui		v0, 0x800A					// original line 1
		j		_return
		lbu		v0, 0x4AE7(v0)				// original line 2

		_multiman:
        lui		v0, 0x800A					// original line 1
		j       0x8018FCE8                  // return
        lbu		v0, 0x4AE7(v0)				// original line 2
    }
	
	// @ Description
	// Forces a specific song to play
    scope set_bgm: {
        OS.patch_start(0x10E548, 0x8018FCE8)
		j       set_bgm                      
        addiu	a1, r0, 0x0002								// multiman mode check placed in
        _return:
        OS.patch_end()
        
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 2 if multiman
        beq     t6, a1, _multiman               // if multiman, skip
        addiu	a1, r0, 0x007E				// places multiman music ID into argument
		addiu	a1, r0, 0x0003				// places multiman music ID into argument
		beq     t6, a1, _multiman               // if multiman, skip
        addiu	a1, r0, 0x007F				// places cruel multiman music ID into argument

		jal		0x800FC3E8
		nop
        j       _return                     // return
        nop

		_multiman:
		jal		_multiman_midi
		nop
        j       _return                     // return
        nop
		
		_multiman_midi:						// based on 0x800FC3E8
		lui		t6, 0x8013
		lw		t6, 0x1300(t6)
		addiu	sp, sp, 0xFFE8
		sw		ra, 0x0014(sp)
		
		OS.copy_segment(0x77BFC, 0x30)		// 800FC3FC
    }
	
	// @ Description
	// Skips a c flag function which starts new music at end of traffic light
    scope skip_cflag_music_function_2: {
        OS.patch_start(0x10B9C0, 0x8018D160)
		j       skip_cflag_music_function_2                     
        addiu	at, r0, 0x0002				// multiman mode check placed in
        _return:
        OS.patch_end()
        
		li      t6, multiman_css_flag       // v0 = multiman flag
        lw      t6, 0x0000(t6)              // v0 = 2 if multiman
        beq     t6, at, _multiman           // if multiman, skip
		addiu	at, r0, 0x0003				// multiman mode check placed in
		beq     t6, at, _multiman           // if cruel multiman, skip
        nop

		lui		v0, 0x800A					// original line 1
		j		_return
		lbu		v0, 0x4AE7(v0)				// original line 2

		_multiman:
		j       _return                  	// return
        addiu	v0, r0, r0
    }
	
	// @ Description
	// loads in the amount of stocks for multiman mode
	scope load_player_stocks: {
	OS.patch_start(0x520C4, 0x800D68C4)
		j	    load_player_stocks
        sb		r0, 0x002C(a0)				// original line 2
		_return:
        OS.patch_end()
		
		addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
		
		li      t1, multiman_css_flag       // t1 = multiman flag
        lw     	t1, 0x0000(t1)              // t1 = 1 if multiman
        bnez    t1, _multiman               // if multiman, skip
        nop
		
		lw      t1, 0x0004(sp)              // load t1
        addiu   sp, sp, 0x0010              // deallocate stack space
		
		j		_return
		lbu		t9, 0x493B(t9)				// original line 2
	
		_multiman:
		lw      t1, 0x0004(sp)              // load t1
        addiu   sp, sp, 0x0010              // deallocate stack space
		j		_return
		addiu	t9, r0, 0x0000					// set stock amount to 1
	}
	
	scope load_1p_difficulty_1: {
	OS.patch_start(0x10BD54, 0x8018D4F4)
		j	    load_1p_difficulty_1
        addiu	t8, r0, 0x0001
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw     	t6, 0x0000(t6)              // t6 = 1 if multiman
        beq     t6, t8, _bonus3             // if bonus 3, skip
        addiu	t8, r0, 0x0002
		
		beq     t6, t8, _multiman           // if multiman, skip
        addiu	t8, r0, 0x0003
		beq     t6, t8, _cruel              // if cruel multiman, skip
		lui		t8, 0x8013					// original line 2
		
		j		_return
		lbu		t6, 0x045A(t0)				// original line 1
	
		_bonus3:
		lui		t8, 0x8013					// original line 2
		j		_return
		addiu	t6, r0, 0x0004				// set difficulty to very hard
	
		_multiman:
		lui		t8, 0x8013					// original line 2
		j		_return
		addiu	t6, r0, 0x0001				// set difficulty to easy
		
		_cruel:
		j		_return
		addiu	t6, r0, 0x0004				// set difficulty to very hard
	}
	
	scope load_1p_difficulty_2: {
	OS.patch_start(0x10BD9C, 0x8018D53C)
		j	    load_1p_difficulty_2
        addiu	t9, r0, 0x0001
		_return:
        OS.patch_end()
		
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw     	t6, 0x0000(t6)              // t6 = 1 if multiman
        beq     t6, t9, _veryhard           //
        addiu	t9, r0, 0x0002
		
		beq     t6, t9, _multiman           // if multiman, skip
        addiu	t9, r0, 0x0003
		beq     t6, t9, _veryhard           
		lw		t9, 0x0000(t1)				// original line 2
		j		_return
		lbu		t6, 0x045A(t0)				// original line 1
	
		_multiman:
		lw		t9, 0x0000(t1)				// original line 2
		j		_return
		addiu	t6, r0, 0x0001				// set difficulty to easy
		
		_veryhard:
		lw		t9, 0x0000(t1)				// original line 2
		j		_return
		addiu	t6, r0, 0x0004				// set difficulty to very hard
	}

	// @ Description
	//	Opponent CPU Level difficulty level
	scope _opponent_cpu: {
	OS.patch_start(0x10BD64, 0x8018D504)
		j	    _opponent_cpu
        addiu	t1, r0, 0x0001						
		_return:
        OS.patch_end()
		
		li      v0, multiman_css_flag       // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 1 if multiman
		beq     v0, t1, _level9             // if bonus3, skip
        addiu	t1, r0, 0x0002	
		beq     v0, t1, _multiman           // if multiman, skip
        addiu	t1, r0, 0x0003	
		beq     v0, t1, _level9             // if cruel multiman, skip
		lui		t1, 0x800A					// original line 2
		
		j		_return
		lbu		v0, 0x0002(t7)				// original line 1
		
		_multiman:
		lui		t1, 0x800A					// original line 2
		j		_return
		addiu	v0, r0, 0x0004				// set opponent cpu to what it is on normal
		
		_level9:
		lui		t1, 0x800A					// original line 2
		j		_return
		addiu	v0, r0, 0x0009				// set opponent cpu to max
		}	
		
	// @ Description
	// Prevents strange crash from happening when over 30 KOs are reached.
    scope crash_prevent: {
        OS.patch_start(0x10D938, 0x8018F0D8)
        j       crash_prevent                   
        nop 
        _return:
        OS.patch_end()
        
		li      t6, multiman_css_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 1 if multiman
        bnez    t6, _multiman               // if multiman, skip
        nop
		
        sw		t7, 0x0000(v0)				// original line 1
        j       _return                     // return
        lw		t6, 0x0024(v1)              // original line 2       

		_multiman:
		lw		t6, 0x0024(v1)              // original line 2
		addiu	a3, r0, 0x0004
		lw		t8, 0x0820(v1)
		lw		t9, 0x0824(v1)
		lhu		t3, 0x0828(v1)
		lhu		t4, 0x082A(v1)
		j		0x8018F110
		nop
		
    }
	
	// Sets Multiman to C Flag Mode and Bonus 3 to B Flag Mode, flags various functions, includiing loading new characters over a
	// cpu slot and displaying icons that remove as defeated, camera, can affect spawns, and other things. There are other modes, perhaps one for each stage
	scope stage_flag: {
	OS.patch_start(0x52324, 0x800D6B24)
        j       stage_flag                   
        addiu	at, r0, 0x0001 
        _return:
        OS.patch_end()
        
		li      v0, multiman_css_flag       // t8 = multiman flag
        lw      v0, 0x0000(v0)              // t8 = 2 if multiman
		beq     v0, at, _bonus3             // if bonus 3, skip
        addiu	at, r0, 0x0002
		beq     v0, at, _multiman           // if multiman, skip
        addiu	at, r0, 0x0003
		bne     v0, at, _normal             // if normal, skip
		nop
		
		_multiman:
		addiu	at, r0, 0x000C					// load flag in at
		sb		at, 0x0017(s2)				// save to flag location so it sets to C flag for various functions
		
		_normal:
        lbu		v0, 0x0017(s2)      		// original line 1
		j		_return
		addiu	at, r0, 0x0003				// original line 2
		
		_bonus3:
		addiu	at, r0, 0x000B				// load flag in at
		j		_normal
		sb		at, 0x0017(s2)				// save to flag location so it sets to C flag for various functions
		}
	
	// Prevents the display of polygon icons used in 1p mode
	scope icon_removal: {
        OS.patch_start(0x10D4D0, 0x8018EC70)
        j       icon_removal                   
        addiu	t9, r0, 0x0002
        _return:
        OS.patch_end()
        
		li      t8, multiman_css_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 2 if multiman
		beq     t8, t9, _multiman           // if multiman, skip
        addiu	t9, r0, 0x0003
		beq     t8, t9, _multiman           // if cruel multiman, skip
		nop
		
        beq		t7, r0, _branch      		// modified original line 1
		nop									// original line 2
		j		_return
		nop

		_multiman:
		j		0x8018EE24
		nop
		
		_branch:
		j		0x8018EC88
		nop
		}
	
	// Revises the original selection of polygon characters so that it works indefinetly and is more random
	scope multiman_random: {
	OS.patch_start(0x10CB6C, 0x8018E30C)
        j       multiman_random                   
        addiu	v0, r0, 0x0002
        _return:
        OS.patch_end()
        
		li      t5, multiman_css_flag       // t5 = multiman flag
        lw      t5, 0x0000(t5)              // t5 = 1 if multiman
		beq     t5, v0, _multiman           // if multiman, skip
        addiu	v0, r0, 0x0003
		bne     t5, v0, _normal             // if multiman, skip
		nop
		
		_multiman:
		addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
		sw      t6, 0x0008(sp)              // save registers
		sw      t0, 0x000C(sp)              // save registers
		jal		Global.get_random_int_
		addiu	a0, r0, 0x000C
		addiu	t4, v0, 0x000E
		lw		a0, 0x0004(sp)				// load registers
		lw		t6, 0x0008(sp)				// load registers
		lw		t0, 0x000C(sp)				// load registers
        addiu   sp, sp, 0x0010              // deallocate stack space
		
		_normal:
		addu	t5, t6, t0					// original line 1
		j		_return
		lui		v0, 0x8019					// original line 2	
		}
    
	// Sets up custom display
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
		sw		t0, 0x0008(sp)
		sw		t1, 0x000C(sp)
		addiu	t0, r0, 0x0001
		li      t1, multiman_css_flag       // t6 = multiman flag
        lw      t1, 0x0000(t1)              // t6 = 1 if multiman
        beq     t1, t0, _bonus3                 // if multiman, skip
        nop

        Render.load_font()                                        // load font for strings
        Render.load_file(0x19, Render.file_pointer_1)             // load button images into file_pointer_1

        // draw icons
        Render.draw_texture_at_offset(0x17, 0x0B, Render.file_pointer_1, 0x80, Render.NOOP, 0x41f00000, 0x41a00000, 0x848484FF, 0x303030FF, 0x3F800000)			// renders polygon stock icon
		
		Render.draw_texture_at_offset(0x17, 0x0B, 0x80130D50, 0x828, Render.NOOP, 0x421C0000, 0x41900000, 0x848484FF, 0x303030FF, 0x3F800000)			// renders X
		
		Render.draw_number(0x17, 0x0B, KO_AMOUNT_POINTER, Render.update_live_string_, 0x42480000, 0x41900000, 0xFFFFFFFF, 0x3f666666, Render.alignment.LEFT)	// renders counter
    

        lw      ra, 0x0004(sp)              // restore registers
		lw		t0, 0x0008(sp)
		lw		t1, 0x000C(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
		
		_bonus3:
        lw      ra, 0x0004(sp)              // restore registers
		lw		t0, 0x0008(sp)
		lw		t1, 0x000C(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
	
    }
	}

	