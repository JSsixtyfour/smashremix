// phantasm.asm
// by Fray
// (02/06/2019 - this code is rather old and will need to be rewritten in the future to prevent conflicts) 
// air ending data pointer 8015C750
// air movement data pointer 800D91EC
// air collision data pointer 80156358
// ground ending data pointer 800D94C4
constant phantasm_move_start(16)
constant phantasm_move_end(20)
constant phantasm_speed(0x43E6)		// float:460.0
constant phantasm_end_air(0x41F0) 	// float:30.0
constant phantasm_end_ground(0x4270)// float:60.0
constant phantasm_land_fsm(0x3EB3)	// float 0.35


scope action_sub: {
	// struct in a2
	// ground neutral special action = e1
	// air neutral special action = e2
	mtc1	r0, f14						// original line 1
	andi	t9, t8, 0x0001				// original line 2
	os_saveRegistersFull()				// save registers
	lbu		t0,	0x000B(a2)				// t0 = current char id
	ori		t1, r0, 0x0001				// t1 = chard id: fox
	bne		t0, t1, end					// skip if char != fox
	nop
	lw		t4, 0x001C(a2)				// t4 = action id frame count
	lw		t5, 0x0024(a2)				// t5 = current action id
	lbu		t0, 0x000D(a2)				// t0 = current player port
	li		t6, flag_phantasm_end		// t6 = flag_phantasm_end
	addu	t6, t6, t0					// t6 = flag_phantasm_end (port corrected offset)
	ori		t0, r0, 0x00E1				// t0 = ground nsp action id
	beq		t0, t5, ground_nsp
	ori		t0, r0, 0x00E2				// t0 = air nsp action id
	bne		t0, t5, end					// skip if action id != air nsp
	nop
	///////////////////////
	//AIR NEUTRAL SPECIAL//
	///////////////////////
	air_nsp:
	bnez	t4, air_nsp_move			// skip if action frame counter != 0
	nop
	air_nsp_initial:
	lbu		t0, 0x018D(a2)				// t0 = fast fall flag
	ori		t1, r0, 0x0007				// t1 = 0x7 (fast fall flag disabled)
	and		t0, t0, t1					// disable fast fall flag
	sb		t0, 0x018D(a2)				// store disabled fast fall flag
	sw		r0, 0x0048(a2)				// halt air momentum on frame 1
	sb		r0, 0x0000(t6)				// reset end flag on frame 1
	lui		t0, 0x42A0					// t0 = float:80
	sw		t0, 0x004C(a2)				// set y momentum to 80
	air_nsp_move:
	lbu		t0, 0x0000(t6)				// t0 = phantasm end flag value
	bnez	t0, freeze_y				// skip if t0 != 0 (end flag = true)
	// after the end flag has been checked, the action frame counter needs to be checked for movement values
	slti	t0, t4, phantasm_move_start	// t0 = 1 if action frame counter < phantasm_move_start, else t0 = 0
	bnez	t0, freeze_y				// skip if action frame counter < phantasm_move_start
	ori		t2, r0, phantasm_move_end	// t2 = phantasm_move_end
	slt		t0, t2, t4					// t0 = 1 if phantasm_move_end < action frame counter
	bnez	t0, freeze_y				// skip if phantasm_move_end < action frame counter
	nop
	lui		t3, phantasm_speed			// t3 = phantasm_speed
	// the player's facing direction is used to convert the speed value to a negative (if needed)
	lw		t0, 0x0044(a2)				// t0 = facing direction
	lui		t1, 0x8000					// t1 = 0x80000000 = most significant bit enabled
	and		t7, t0, t1					// t7 = 0x80000000 if facing direction = left, else t0 = null
	or		t3, t3, t7					// t3 = negative if player is facing left
	sw		t3, 0x0048(a2)				// write speed value to air momentum
	beq		t2, t4, air_nsp_end			// end if on final movement frame
	nop
	air_shorten:
	li		t1, button_press_buffer		// t1 = button_press_buffer
	lbu		t0, 0x000D(a2)				// t0 = current player port
	sll		t0, t0, 0x0001				// t0 = t0*2
	addu	t1, t1, t0					// t1 = button_press_buffer (port corrected offset)
	lh		t1, 0x0000(t1)				// t1 = button presses (previous frame)
	lh		t0, 0x01BE(a2)				// t0 = button presses (current frame)
	or		t0, t0, t1					// t0 = button presses (current frame + previous frame)
	ori		t1, r0, 0x4000				// t1 = 0x4000 (b press value)
	and		t0, t0, t1					// t0 = null if no b press is detected
	beq		t0, r0, freeze_y			// skip if no b press is detected
	nop
	air_nsp_end:
	lui		t3, phantasm_end_air		// t3 = phantasm_end_air
	or		t3, t3, t7					// t3 = negative if player is facing left
	sw		t3, 0x0048(a2)				// write speed value to air momentum
	ori		t0, r0, 0x0001				// t0 = 1
	sb		t0, 0x0000(t6)				// store phantasm end flag
	lw		a0, 0x0004(a2)				// load pointer
	addiu 	sp, sp,-0x000C				// store t6 and t7
	sw    	t6, 0x0004(sp)
	sw    	t7, 0x0008(sp)
	jal		0x800E8518					// end hitboxes
	nop
	lw    	t6, 0x0004(sp)				// load t6 and t7
	lw    	t7, 0x0008(sp)
	addiu 	sp, sp, 0x000C
	freeze_y:
	// when attempting to freeze the character's y momentum by setting it to 0 they will fall at a rate equal to their fall speed acceleration
	// therefore the character's fall speed acceleration value needs to be written to their y momentum instead of 0
	lbu		t0, 0x0000(t6)				// t0 = phantasm end flag value
	bnez	t0, slowfall_y				// branch if t0 != 0
	lw		t0, 0x09C8(a2)				// t0 = attribute pointer
	lw		t0, 0x0058(t0)				// t0 = fall speed acceleration
	beq		t4, r0, nsp_fsm				// skip updating if frame 1
	nop
	sw		t0, 0x004C(a2)				// overwrite y momentum with fall speed acceleration value
	b		nsp_fsm
	nop
	slowfall_y:
	// if the phantasm_end flag is returned as true, the current y momentum is reduced in order to slow the fall
	addiu	sp, sp,-0x000C				// store f0 and f1
	swc1	f0, 0x0004(sp)
	swc1	f1, 0x0008(sp)
	lui		t0, 0x3FCD					// t0 = float:1.6
	lw		t1, 0x004C(a2)				// t1 = y momentum
	mtc1	t0, f0						// f0 = t0
	mtc1	t1, f1						// f1 = t1
	add.s	f0, f1, f0					// f0 = f1 - f0 (momentum - 1.6)
	mfc1	t0, f0						// t0 = f0
	sw		t0, 0x004C(a2)				// store updated y momentum
	lwc1	f0, 0x0004(sp)				// load f0 and f1
	lwc1	f1, 0x0008(sp)
	addiu	sp, sp, 0x000C
	b		nsp_fsm
	nop
	//////////////////////////
	//GROUND NEUTRAL SPECIAL//
	//////////////////////////
	ground_nsp:
	// beql will only execute the instruction in the delay slot if the branch is taken
	// therefore this is the simplest way to only reset the ending flag on the first frame
	beql	t4, r0, ground_nsp_move		// branch if action frame counter = 0
	sb		r0, 0x0000(t6)				// reset end flag on frame 1
	ground_nsp_move:
	lbu		t0, 0x0000(t6)				// t0 = phantasm end flag value
	bnez	t0, nsp_fsm					// skip if t0 != 0 (end flag = true)
	// after the end flag has been checked, the action frame counter needs to be checked for movement values (currently FRAMES 17,18,19,20)
	slti	t0, t4, phantasm_move_start	// t0 = 1 if action frame counter < phantasm_move_start, else t0 = 0
	bnez	t0, nsp_fsm					// skip if action frame counter < phantasm_move_start(16)
	ori		t2, r0, phantasm_move_end	// t2 = phantasm_move_end
	slt		t0, t2, t4					// t0 = 1 if phantasm_move_end < action frame counter
	bnez	t0, nsp_fsm					// skip if phantasm_move_end(20) < action frame counter
	nop
	lui		t0, phantasm_speed			// t0 = phantasm_speed
	sw		t0, 0x0060(a2)				// write speed value to ground momentum
	beq		t2, t4, ground_nsp_end		// end if on final movement frame
	nop
	ground_shorten:
	li		t1, button_press_buffer		// t1 = button_press_buffer
	lbu		t0, 0x000D(a2)				// t0 = current player port
	sll		t0, t0, 0x0001				// t0 = t0*2
	addu	t1, t1, t0					// t1 = button_press_buffer (port corrected offset)
	lh		t1, 0x0000(t1)				// t1 = button presses (previous frame)
	lh		t0, 0x01BE(a2)				// t0 = button presses (current frame)
	or		t0, t0, t1					// t0 = button presses (current frame + previous frame)
	ori		t1, r0, 0x4000				// t1 = 0x4000 (b press value)
	and		t0, t0, t1					// t0 = null if no b press is detected
	beq		t0, r0, nsp_fsm				// skip if no b press is detected
	nop
	ground_nsp_end:
	lui		t1, phantasm_end_ground		// t3 = phantasm_end_ground
	sw		t1, 0x0060(a2)				// write speed value to ground momentum
	ori		t0, r0, 0x0001				// t0 = 1
	sb		t0, 0x0000(t6)				// store phantasm end flag
	lw		a0, 0x0004(a2)				// load pointer
	addiu 	sp, sp,-0x000C				// store t6 and t7
	sw    	t6, 0x0004(sp)
	sw    	t7, 0x0008(sp)
	jal		0x800E8518					// end hitboxes
	nop
	lw    	t6, 0x0004(sp)				// load t6 and t7
	lw    	t7, 0x0008(sp)
	addiu 	sp, sp, 0x000C
	/////////////
	//APPLY FSM//
	/////////////
	nsp_fsm:
	// fsm value in a1
	// 0.5x speed on frame 3
	ori		t0, r0, 0x0002				// t0 = 0x2
	beql	t0, t4, apply_fsm			// apply fsm if action frame counter = 0x2(frame 3)
	lui		a1, 0x3F00					// a1(fsm value) = float:0.5
	// 2x speed on frame 13
	ori		t0, r0, 0x000C				// t0 = 0xC
	beql	t0, t4, apply_fsm			// apply fsm if action frame counter = 0xC(frame 13)
	lui		a1, 0x4000					// a1(fsm value) = float:2.0
	// 1x speed on frame 18
	ori		t0, r0, 0x0011				// t0 = 0x11
	beql	t0, t4, apply_fsm			// apply fsm if action frame counter = 0x11(frame 18)
	lui		a1, 0x3F80					// a1(fsm value) = float:1.0
	//0.56x speed after frame 24
	ori		t0, r0, 0x0017				// t0 = 0x17
	beql	t0, t4, apply_fsm			// apply fsm if action frame counter = 0x17(frame 24)
	lui		a1, 0x3F10					// a1(fsm value) = float:0.5625
	b		end							// skip to end when no fsm change is needed
	nop
	apply_fsm:
	lw		a0, 0x0004(a2)				// load pointer
	jal		0x8000BB04					// run fsm subroutine
	nop
	////////////////
	//FUNCTION END//
	////////////////
	end:
	li		t1, button_press_buffer		// t1 = button_press_buffer
	lbu		t0, 0x000D(a2)				// t0 = current player port
	sll		t0, t0, 0x0001				// t0 = t0*2
	addu	t1, t1, t0					// t1 = button_press_buffer (port corrected offset)
	lh		t0, 0x01BE(a2)				// t0 = current button presses
	sh		t0, 0x0000(t1)				// store current button presses to buffer
	os_restoreRegistersFull()			// restore registers
	j	action_sub_return
	nop
	
	flag_phantasm_end:
	db	0x00							// p1
	db	0x00							// p2
	db	0x00							// p3
	db	0x00							// p4
	
	button_press_buffer:
	dh	0x0000							// p1
	dh	0x0000							// p2
	dh	0x0000							// p3
	dh	0x0000							// p4
}

scope phantasm_land: {
	// struct in v1
	lui		a2, 0x3E8F					// original line 1
	andi	t9, t8, 0x3000				// original line 2
	addiu 	sp, sp,-0x000C				// store t0 and t1
	sw    	t0, 0x0004(sp)
	sw    	t1, 0x0008(sp)
	lbu		t0,	0x000B(v1)				// t0 = current char id
	ori		t1, r0, 0x0001				// t1 = chard id: fox
	beql	t0, t1, end					// execute the next instruction ONLY if current char id = fox
	lui		a2, phantasm_land_fsm		// a2 = phantasm_land_fsm
	end:
	lw    	t0, 0x0004(sp)				// load t0 and t1
	lw    	t1, 0x0008(sp)
	addiu 	sp, sp, 0x000C
	j		phantasm_land_return
	nop
}

scope action_frame_count: {
	// struct in a2
	// to ensure the side b functions properly the action frame counter needs to be paused during hitlag
	lw		v0, 0x018C(a2)				// original line 1
	addiu	t8, t7, 0x0001				// original line 2
	addiu 	sp, sp,-0x000C				// store t0 and t1
	sw    	t0, 0x0004(sp)
	sw    	t1, 0x0008(sp)
	lbu		t0,	0x000B(a2)				// t0 = current char id
	ori		t1, r0, 0x0001				// t1 = chard id: fox
	bne		t0, t1, end					// end if character is not fox
	lw		t0, 0x0024(a2)				// t0 = current action id
	ori		t1, r0, 0x00E1				// t1 = ground nsp action id
	beq		t0, t1, overwrite			// overwrite if action id = ground nsp
	ori		t1, r0, 0x00E2				// t1 = air nsp action id
	bne		t0, t1, end					// skip if action id != air nsp
	nop
	overwrite:
	lw		t0, 0x0040(a2)				// t0 = current hitlag frames
	slti	t0, t0, 0x0002				// t0 = 1 if hitlag frames < 2, else t0 = null
	bnez	t0, end						// skip if current hitlag frames > 1	
	nop
	or		t8, t7, r0					// t8 = t7 (pause action frame counter)
	end:
	lw    	t0, 0x0004(sp)				// load t0 and t1
	lw    	t1, 0x0008(sp)
	addiu 	sp, sp, 0x000C
	j		action_frame_count_return
	nop
}

scope moveset_data: {
	// struct in s1
	// the moveset data pointer in v0 will be adjusted to load custom data for phantasm
	addiu 	sp, sp,-0x000C				// store t0 and t1
	sw    	t0, 0x0004(sp)
	sw    	t1, 0x0008(sp)
	lbu		t0,	0x000B(s1)				// t0 = current char id
	ori		t1, r0, 0x0001				// t1 = chard id: fox
	bne		t0, t1, end					// end if character is not fox
	lw		t0, 0x0024(s1)				// t0 = current action id
	ori		t1, r0, 0x00E1				// t1 = ground nsp action id
	beq		t0, t1, ground				// branch if current action = ground nsp
	ori		t1, r0, 0x00E2				// t1 = air nsp action id
	bne		t0, t1, end					// skip if action id != air nsp
	nop
	air:
	li		v0, phantasm_data_air		// v0(moveset data pointer) = phantasm_data_air
	b		end							// jump to end
	nop
	ground:
	li		v0, phantasm_data_ground	// v0(moveset data pointer) = phantasm_data_ground
	end:
	lw    	t0, 0x0004(sp)				// load t0 and t1
	lw    	t1, 0x0008(sp)
	addiu 	sp, sp, 0x000C
	sw		v0, 0x08AC(s1)				// store pointer
	sw		v0, 0x086C(s1)				// original line (store pointer)
	j		moveset_data_return
	nop
}

insert phantasm_data_ground, "phantasm_data_ground.bin"
insert phantasm_data_air, "phantasm_data_air.bin"


