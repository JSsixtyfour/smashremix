// Reflect.asm

// This file allows us to use custom reflect routines for the reflecting player. Usually related to an action change or fgm/gfx

scope Reflect {

    // @ Description
    // Reflect type is found at half-byte 0x2 in a reflect hitbox struct
    scope reflect_type: {
        constant STARFOX(0x00)              // Fox's reflector (changes action, switches direction)
        constant NONE(0x01)                 // none
        constant BAT(0x02)                  // Ness's Bat, plays a sound
        constant CUSTOM(0x03)               // CUSTOM branch
    }

    // @ Description
    // Reflect type is found at half-byte 0x0 in a reflect hitbox struct
    scope custom_reflect_type: {
        constant FRANKLIN_BADGE(0x00)       // reflects without player being turned around
        constant MARINA(0x01)               // Marinas Absorb/Reflect
        constant DEDEDE(0x02)               // Dededes Absorb/Reflect
    }
	
	// @ Description
	// These characters can reflect projectiles
	// Used so character id checks don't take forever
    Character.table_patch_start(fighter_reflect, Character.id.WOLF, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.FALCO, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.JFOX, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.JNESS, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.LUCAS, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.NLUCAS, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.MARINA, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.DEDEDE, 0x1)
    db    	OS.TRUE;     OS.patch_end();
    Character.table_patch_start(fighter_reflect, Character.id.PIANO, 0x1)
    db    	OS.TRUE;     OS.patch_end();

	// @ Description
	// Hooks related to cpu behaviour with absorb and reflect
	scope AI: {
			
		// @ Description
		// Original routine does a character id check for Ness or Fox, and Kirby
		scope extend_reflect_absorb_character_check_: {
			OS.patch_start(0xAE290, 0x80133850)
			j		extend_reflect_absorb_character_check_
			addiu	at, r0, Character.id.NESS	// original line 1
			OS.patch_end()
		
			// A1 = character ID (self)
			// v1 = enemy character ID
			
			// check if enemy can reflect
			li		at, Character.fighter_reflect.table	// at = reflect table
			addu	at, at, v1							// at = fighters offset in table
			lb		at, 0x0000(at)						// at = fighters entry in table
			bnez	at, _dont_shoot						// branch if enemy fighter can't reflect\
			nop

			_kirby_check:
			addiu	at, r0, Character.id.KIRBY	// at = character ID
			beq		at, a1, _kirby_shoot		// branch if KIRBY
			addiu	at, r0, Character.id.JKIRBY	// at = character ID
			bnel	at, a1, _shoot				// branch if ~
			or		v0, a1, r0					// v0 = character id if not kirby
			
			_kirby_shoot:
			lw		v0, 0x0ADC(s0)				// get kirby copied power id
			_shoot:
			j		0x8013387C
			nop

			_dont_shoot:
			// todo: franklin badge check here
			j		0x801338A0					// dont shoot if the opponent can reflect or absorb
			lw		v1, 0x0008(s0)

		}

		// @ Description
		// Allows cpus with slow reflects or absorbs to react to the projectiles in time.
		scope set_projectile_detection_radius_: {
			OS.patch_start(0xB0680, 0x80135C40)
			j		set_projectile_detection_radius_
			lw		s6, 0x0008(s2)			// s6 = character ID
			_return:
			OS.patch_end()
			
			// s2 = player struct
			// s6, s4 is safe
			lli   	s4, Character.id.MARINA	// s4 = id.MARINA
			beq		s4, s6, _marina			// marina branch
			lli   	s4, Character.id.LUCAS	// s4 = id.LUCAS
			beq		s4, s6, _lucas			// lucas branch
			lli   	s4, Character.id.NLUCAS	// s4 = id.NLUCAS
			beq		s4, s6, _lucas			// lucas branch

			// if here, take original.
			lui		at, 0x4170				// original line 1 (float 15.0)
			mtc1	at, f26					// original line 2
			j		_return
			nop

			
			_marina:
			lui		at, 0x41C8				// modify line 1 (float 25.0)
			mtc1	at, f26					// original line 2
			j		_return
			nop
			
			_lucas:
			lui		at, 0x41C8				// modify line 1 (float 25.0)
			mtc1	at, f26					// original line 2
			j		_return
			nop
		}
		
		// @ Description
		// Allows cpus with slow reflects or absorbs to react to the projectiles in time.
		scope set_item_detection_radius_: {
			OS.patch_start(0xB0914, 0x80135ED4)
			j		set_item_detection_radius_
			lw		at, 0x0008(s2)			// at = character ID
			_return:
			OS.patch_end()
			
			// s2 = player struct
			// at, s7 is safe
			lli   	at, Character.id.MARINA	// s7 = id.MARINA
			beq		at, s7, _marina			// marina branch
			lli   	at, Character.id.LUCAS	// s7 = id.LUCAS
			beq		at, s7, _lucas			// lucas branch
			lli   	at, Character.id.NLUCAS	// s7 = id.NLUCAS
			beq		at, s7, _lucas			// lucas branch

			// if here, take original.
			lui		at, 0x4110				// original line 1 (float 15.0)
			j		_return
			lui		s7, 0x8004				// original line 2
			
			_marina:
			lui		at, 0x41C8				// modify line 1 (float 25.0)
			j		_return
			lui		s7, 0x8004				// original line 2
			
			_lucas:
			lui		at, 0x41C8				// modify line 1 (float 25.0)
			j		_return
			lui		s7, 0x8004				// original line 2
		}
		
		// @ Description
		// Sets the cpus reflect/absorb flag when a hazardous projectile is near
		scope extend_projectile_reflect_initial_: {
			OS.patch_start(0xB0B74, 0x80135E90)
			j     extend_projectile_reflect_initial_
			nop
			_return:
			OS.patch_end()

			// v0 = character id
			// a2 = player struct

			beq    v0, at, _ness_absorb       	// modified og line 1
			lli    at, Character.id.JFOX
			beq    at, v0, _fox_reflect       	// Fox branch if JFOX
			lli    at, Character.id.MARINA
			beq    at, v0, _marina            	// Fox branch if MARINA
			lli    at, Character.id.FALCO
			beq    at, v0, _fox_reflect       	// Fox branch if FALCO
			lli    at, Character.id.WOLF
			beq    at, v0, _fox_reflect       	// Fox branch if WOLF
			lli    at, Character.id.JNESS
			beq    at, v0, _ness_absorb       	// Ness branch if JNESS
			lli    at, Character.id.LUCAS
			beq    at, v0, _lucas       	  	// Lucas branch if LUCAS
			lli    at, Character.id.NLUCAS
			beq    at, v0, _lucas             	// Lucas branch if NLUCAS
			lli    at, Character.id.PIANO
			beq    at, v0, _ness_absorb       	// Ness branch if PIANO
			nop

			_normal:
			j 		0x80136174					// original line 1
			addiu	v0, r0, 0x0001				// original line 2
			
			_lucas:
			li		t0, last_known_hazard_direction
			lbu     at, 0x000D(s2)              // at = player.port
			lw      v0, 0x0074(s7)				// v0 = projectile position struct
			lwc1    f4, 0x001C(v0)				// f4 = projectile.x
			lw      v0, 0x0074(a0)				// v0 = player position struct
			lwc1    f6, 0x001C(v0)				// f6 = player.x
			addu    t0, t0, at                  // t3 = Lucas's entry in hazard_last_known_direction
			c.le.s	f4, f6
			lli 	at, 0x0000
			bc1fl	_lucas_continue				// set to 1 if projectile.x > player.x
			lli 	at, 0x0001
			_lucas_continue:
			lw      v0, 0x0044(s2)				// v0 = player direction
			beql	v0, at,	_lucas_apply_bat
			lli 	at, 0x0001					// attack forwards
			lli 	at, 0x0000					// or attack backwards
			_lucas_apply_bat:
			sb      at, 0x0000(t0)				// save last known direction
			j      0x80135E9C					// attempt to reflect
			lbu    t0, 0x0049(s1)             	// get cpu reflect flag

			_fox_reflect:
			j      0x80135E9C					// attempt to reflect
			lbu    t0, 0x0049(s1)             	// get cpu reflect flag

			_ness_absorb:
			// s7 = projectile object
			lw     v0, 0x0084(s7)             	// v0 = projectile struct
			lw     v0, 0x000C(v0)             	// v0 = projectile ID
			lli    at, 0x1003                 	// at = Sheiks projectile id
			beq    v0, at, _normal            	// don't absorb if Sheiks needle
			lli    at, 0x1001                 	// at = Conkers projectile id
			beq    v0, at, _normal            	// don't absorb if Conker's nut
			nop
			j      0x80135E9C					// attempt to absorb
			lbu    t0, 0x0049(s1)             	// get cpu reflect flag
			
			_marina:
			lw     v0, 0x084C(s2)         		// v0 = current item
			bnez   v0, _normal			 		// no clanpot if holding an item
			lw     v0, 0x0ADC(s2)      	     	// v0 = charge level
			lli    at, 4						// at = Marinas Max charge for Clanpot
			beq    at, v0, _normal				// no clanpot if at max charge
			nop
			j      0x80135E9C					// attempt to absorb
			lbu    t0, 0x0049(s1)            	// get cpu reflect flag
		}
		
		// @ Description
		// Sets the cpus reflect/absorb flag when a hazardous item is near
		scope extend_item_reflect_initial_: {
			OS.patch_start(0xB08D0, 0x80136134)
			j     extend_item_reflect_initial_
			nop
			_return:
			OS.patch_end()

			// v0 = character id
			// at = id.PolyNess
			
			// check if enemy can reflect
			li		at, Character.fighter_reflect.table	// at = reflect table
			addu	at, at, v0					// at = fighters offset in table
			lb		at, 0x0000(at)				// at = fighters entry in table
			bnez	at, _reflect				// branch if enemy fighter can't reflect
			nop

			_normal:
			j		0x80136148					// original line 1
			nop
			
			_lucas:
			li		t3, last_known_hazard_direction
			lbu     at, 0x000D(s2)              // at = player.port
			lw      v0, 0x0074(s7)				// v0 = item position struct
			lwc1    f4, 0x001C(v0)				// f4 = item.x
			lw      v0, 0x0074(a0)				// v0 = player position struct
			lwc1    f6, 0x001C(v0)				// f6 = player.x
			addu    t3, t3, at                  // t3 = Lucas's entry in hazard_last_known_direction
			c.le.s	f4, f6
			lli 	at, 0x0000
			bc1fl	_lucas_continue				// set to 1 if projectile.x > player.x
			lli 	at, 0x0001
			_lucas_continue:
			lw      v0, 0x0044(s2)				// v0 = player direction
			beql	v0, at,	_lucas_apply_bat
			lli 	at, 0x0001					// attack forwards
			lli 	at, 0x0000					// or attack backwards
			_lucas_apply_bat:
			sb      at, 0x0000(t3)				// save last known direction
			j      0x80135E9C					// attempt to reflect
			lbu    t0, 0x0049(s1)             	// get cpu reflect flag


			_reflect:
			// check special cases here
			lli		at, Character.id.MARINA
			beq		v0, at, _marina				// branch if id = MARINA
			lli		at, Character.id.LUCAS
			beq		v0, at, _lucas				// branch if id = LUCAS
			lli		at, Character.id.NLUCAS
			beq		v0, at, _lucas				// branch if id = NLUCAS
			nop
			j 		0x80136140					// original fox logic 1
			lbu		t3, 0x0049(s1)				// get reflect/absorb flag
				
			_marina:
			lw     v0, 0x084C(s2)         		// v0 = current item
			bnez   v0, _normal			 		// no clanpot if holding an item
			lw     v0, 0x0ADC(s2)      	     	// v0 = charge level
			lli    at, 4						// at = Marinas Max charge for Clanpot
			beq    at, v0, _normal				// no clanpot if at max charge
			nop
			// if here, do clanpot
			j 		0x80136140					// original fox logic 1
			lbu		t3, 0x0049(s1)				// get reflect/absorb flag
		}
		
		// @ Description
		// Used by Lucas so he can hit items/projectiles with bat
		last_known_hazard_direction:
		db	0, 0, 0, 0
		
		// @ Description
		// Applies reflect/absorb if flag was previously set for cpu players
		scope maintain_reflect_input_: {
			OS.patch_start(0xB226C, 0x8013782C)
			j     maintain_reflect_input_
			lli    at, Character.id.JFOX
			_return:
			OS.patch_end()

			// v0 = character id
			// a2 = player struct

			beq    at, v0, _fox_reflect       	// Fox branch if JFOX
			lli    at, Character.id.MARINA
			beq    at, v0, _marina_absorb     	// Marina branch if MARINA
			lli    at, Character.id.FALCO
			beq    at, v0, _fox_reflect       	// Fox branch if FALCO
			lli    at, Character.id.WOLF
			beq    at, v0, _fox_reflect       	// Fox branch if WOLF
			lli    at, Character.id.JNESS
			beq    at, v0, _ness_absorb       	// Ness branch if JNESS
			lli    at, Character.id.LUCAS
			beq    at, v0, _ness_absorb       	// Ness branch if LUCAS
			lli    at, Character.id.NLUCAS
			beq    at, v0, _ness_absorb       	// Ness branch if NLUCAS
			lli    at, Character.id.PIANO
			beq    at, v0, _piano_absorb      	// Piano branch if PIANO
			nop

			_normal:
			j      0x80137884                 	// og line 1
			lw     v0, 0x0024(a2)             	// og line 2

			_fox_reflect:
			j      0x80137838                 	// take Fox branch (dsp)
			lw     v0, 0x0024(a2)             	// v0 = current action id

			_ness_absorb:
			j      0x80137860                 	// take Ness branch (dsp)
			lw      v0, 0x0024(a2)            	// v0 = current action id
			
			_lucas:
			// Lucas will try using his Bat if grounded and idle
			lw		v0, 0x014C(a2)				// v0 = player kinetic state
			bnez	v0, _ness_absorb			// do normal absorb if aerial
			lw		v0, 0x0024(a2)				// v0 = player action
			lli		at, Action.Idle
			beq		v0, at, _bat				// do bat if not in idle
			lli		at, Action.Walk1
			beq		v0, at, _bat				// do bat if not in walk1
			lli		at, Action.Walk2
			beq		v0, at, _bat				// do bat if not in walk2
			lli		at, Action.Walk3
			bne		v0, at, _ness_absorb		// do normal absorb if not walk3
			nop
			
			_bat:
			bnez	v0, _ness_absorb			// do normal absorb if aerial
			li		v0, last_known_hazard_direction
			lbu     at, 0x000D(a2)              // at = player.port
			addu    v0, v0, at                  // v0 = Lucas's entry in last_known_hazard_direction
			lb      at, 0x0000(v0)				// get entry
			addiu	a1, r0, 0x0038				// a1 = custom routine. AI.FSMASH_REFLECT_RIGHT
			beqzl	at, _lucas_continue			// smash left if direction is so
			addiu	a1, r0, 0x0039				// a1 = custom routine. AI.FSMASH_REFLECT_LEFT
			_lucas_continue:
			jal		0x80132758					// set controller input
			nop
			j		0x80137A08					// branch to end
			or		v0, r0, r0					// branch to end

			_piano_absorb:
			lw      v0, 0x0024(a2)            	// v0 = current action id
			slti    at, v0, 0x00E5            	// min absorb action
			bnez    at, _normal               	// 
			slti    at, v0, 0x00EE            	// max absorb action
			beqz    at, _normal               	// 
			or      a0, a2, r0                	// 
			j       0x80137874                	// keep holding absorb
			nop

			_marina_absorb:
			lw      v0, 0x0024(a2)            	// v0 = current action id
			slti    at, v0, Marina.Action.DSPG_Begin// min absorb action
			bnez    at, _normal
			slti    at, v0, Marina.Action.DSPA_Pull_Fail // max absorb action
			beqz    at, _normal
			or      a0, a2, r0
			j       0x80137874                	// keep holding absorb
			nop
		}

		// @ Description
		// Applies reflect/absorb if flag was previously set for cpu players
		scope apply_reflect_input_: {
			OS.patch_start(0xB2A98, 0x80138058)
			j     apply_reflect_input_
			nop
			_return:
			OS.patch_end()

			// v0 = character id
			// a2 = player struct

			lli    at, Character.id.JFOX
			beq    at, v0, _fox_reflect       	// Fox branch if JFOX
			lli    at, Character.id.MARINA
			beq    at, v0, _marina_absorb     	// Marina branch if MARINA
			lli    at, Character.id.FALCO
			beq    at, v0, _fox_reflect       	// Fox branch if FALCO
			lli    at, Character.id.WOLF
			beq    at, v0, _fox_reflect       	// Fox branch if WOLF
			lli    at, Character.id.JNESS
			beq    at, v0, _ness_absorb       	// Ness branch if JNESS
			lli    at, Character.id.LUCAS
			beq    at, v0, _lucas             	// Lucas branch if LUCAS
			lli    at, Character.id.LUCAS
			beq    at, v0, _lucas             	// Lucas branch if NLUCAS
			lli    at, Character.id.PIANO
			beq    at, v0, _piano_absorb      	// Piano branch if PIANO
			lw     v0, 0x0024(a0)             	// v0 = current action id

			_normal:
			j      0x801380F8                 	// og line 1
			lw     ra, 0x0014(sp)             	// og line 2

			_fox_reflect:
			j      0x80138064
			lw     v0, 0x0024(a0)             	// v0 = current action id
			
			_lucas:
			// Lucas will try using his Bat if grounded
			lw		v0, 0x014C(a0)				// v0 = player kinetic state
			bnez	v0, _ness_absorb			// do normal absorb if aerial	
			li		v0, last_known_hazard_direction
			lbu     at, 0x000D(a0)              // at = player.port
			addu    v0, v0, at                  // v0 = Lucas's entry in last_known_hazard_direction
			lb      at, 0x0000(v0)				// get entry
			addiu	a1, r0, 0x0039				// a1 = custom routine. AI.FSMASH_REFLECT_RIGHT
			beqzl	at, _lucas_continue			// smash left if direction is so
			addiu	a1, r0, 0x0038				// a1 = custom routine. AI.FSMASH_REFLECT_LEFT
			_lucas_continue:
			jal		0x80132758					// set controller input
			nop
			j		0x801380F8					// branch to end
			lw    	ra, 0x0014(sp)             	// restore ra

			_ness_absorb:
			j      0x8013808C
			lw     v0, 0x0024(a0)             	// v0 = current action id

			_piano_absorb:
			lw     v0, 0x0024(a0)             	// v0 = current action id
			slti   at, v0, 0x00E5             	// original logic checks action
			bnez   at, _intiate_absorb
			slti   at, v0, 0x00EE             	// original logic
			j      0x80138098                 	// original logic checks action
			nop

			_marina_absorb:
			lw     v0, 0x0024(a0)                   // v0 = current action id
			slti   at, v0, Marina.Action.DSPG_Begin // check if already absorbing
			bnez   at, _intiate_absorb
			slti   at, v0, Marina.Action.DSPA_Pull_Fail // original logic
			j      0x80138098                       // original logic checks action
			nop

			_intiate_absorb:
			j      0x801380A0
			nop

		}
	
	}

    // @ Description
    // This hook allows samus bomb to be reflected if the reflect type is CUSTOM. also exits reflect if there is no reflect hb
    // also a good spot for chain chomp check
    scope override_reflectability_: {
        OS.patch_start(0x60AD0, 0x800E52D0)
        j       override_reflectability_
        nop
        _return:
        OS.patch_end()

        // s7 = reflecting entity (player)
        // s6 = projectile hitbox
        // s8 = projectile struct

        lw      t2, 0x0850(s7)              // t2 = pointer to reflect hitbox
        beqz    t2, _exit                   // skip entire reflect check if no reflect hitbox present
        addiu   at, r0, reflect_type.CUSTOM
        lh      t2, 0x0002(t2)              // t2 = reflect type
        bne     at, t2, _normal             // skip if reflect type != CUSTOM
        nop

        // if here, reflect type is CUSTOM
        lw      t2, 0x000C(s8)              // t2 = projectile id
        lli     at, 0x0003                  // at = samus bomb id
        beq     at, t2, _override           // force reflect if projectile id = samus bomb
        lli     at, 0x000B                  // at = pikachu thunder head id
        beq     at, t2, _override           // force reflect if projectile id = pikachu thunder head
        lli     at, 0x000C                  // at = pikachu thunder tail id
        beq     at, t2, _override           // force reflect if projectile id = pikachu thunder tail
        lli     at, 0x0017                  // at = onix rock id
        beq     at, t2, _override           // force reflect if projectile id = onix rock
        lli     at, 0x001B                  // at = blastoise shot id
        beq     at, t2, _override           // force reflect if projectile id = blastoise shot
        lli     at, 0x001D                  // at = koffing emission id
        beq     at, t2, _override           // force reflect if projectile id = koffing emission
        lli     at, 0x1005                  // at = pirate land cannonball id
        beq     at, t2, _override           // force reflect if projectile id = pirate land cannonball
        lli     at, 0x1006                  // at = robot bee laser id
        beq     at, t2, _override           // force reflect if projectile id = robot bee laser
        nop

        // this projectile's reflect behaviour shouldn't be overridden, so continue normally
        _normal:
        lw      t2, 0x0048(s6)              // original line 1, load flag from object hb
        j       _return
        sll     t4, t2, 5                   // original line 2, ~

        _override:
        j       0x800E52E0                  // jump to the rest of the reflect routine
        nop

        _exit:
        j       _return
        addiu   t4, r0, 0x0000               // t4 = 0 (skip reflect)
    }

    // @ Description
    // This hook allows us to run different player routines if the reflect type is CUSTOM. (good for action changes and sfx)
    scope extend_reflect_types: {
        OS.patch_start(0x61E3C , 0x800E663C)
        j       extend_reflect_types
        nop
        OS.patch_end()
        // s0 = reflecting entity (player)
        // t3 = reflect hitbox

        addiu   at, r0, reflect_type.CUSTOM
        lh      a1, 0x0002(t3)              // a1 = reflect type from reflect hitbox
        bne     at, a1, _end                // skip if not custom
        nop

        _custom:
        // if here, then we run a routine from the custom table
        li      a1, Reflect.custom_reflect_table // a1 = custom reflect table
        lh      at, 0x0000(t3)              // at = custom reflect id
        sll     at, at, 2                   // at = offset to routine in custom reflect routine table.
        addu    at, at, a1                  // add together, get pointer
        lw      t7, 0x0000(at)              // t7 = routine to run
        beqz    t7, _end                    // don't run routine if there is not one in table.
        nop
        lw      a0, 0x0004(s0)              // s0 = reflecting (player) object
        jalr    ra, t7
        nop
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        j     0x800E667C                    // original line 1 (sorta)
        lw    t6, 0x0098(sp)                // original line 2

    }

    // @ Description
    // This hook adds a check for the reflect type before the projectiles reflect routine is executed
    scope override_projectile_reflect_routine_: {
        OS.patch_start(0xE1794, 0x80166D54)
        j       override_projectile_reflect_routine_
        nop
        _return:
        OS.patch_end()

        // v1 = projectile struct
        // v0 = reflecting player struct

        sw      v1, 0x001C(sp)              // 0x001C(sp) = projectile struct
        lw      v0, 0x0084(a0)              // v0 = reflecting player struct (original line 2)
        addiu   at, r0, reflect_type.CUSTOM // at = custom reflect id
        lw      t6, 0x850(v0)               // t6 = reflect hb
        lh      t7, 0x0002(t6)              // t7 = current players reflect id
        bne     at, t7, _original           // branch to normal routine if not custom
        nop

        lh      t7, 0x0000(t6)              // t7 = custom reflect routine index
        beqz    t7, _original               // branch to normal routine if Franklin Badge
        addiu   at, r0, custom_reflect_type.MARINA
		beq		at, t7, _marina
        addiu   at, r0, custom_reflect_type.DEDEDE
		//beq		at, t7, _dedede
		beq		at, t7, _marina				// not suspending projectiles
		nop
		b		_original					// if here, then some other custom reflect type
		nop
		
		_dedede:
        lw      a1, 0x0020(sp)              // a1 = projectile object
		jal 	DededeNSP.suspend_projectile_
		move    a0, v0						// a0 = player struct
		bnezl	v0, _destroy				// destroy projectile if not suspended
		lw      v1, 0x001C(sp)              // v1 = projectile struct
		j 		0x80166DA8					// jump back to original routine (skips reflect logic)
        lw      v1, 0x001C(sp)              // v1 = projectile struct

		_marina:
        //_check_thunder:
        lw      t7, 0x000C(v1)              // t7 = projectile id
        lli     at, 0x000C                  // at = pikachu thunder tail id
        bne     t7, at, _check_absorb       // skip if projectile id != pikachu thunder tail
        nop

        // run a special absorb function for pikachu's thunder
        jal     pikachu_thunder_absorb_
        lw      a0, 0x0020(sp)              // a0 = projectile object
        j       0x80166DA8                  // jump back to original routine (skips reflect logic)
        lw      v1, 0x001C(sp)              // v1 = projectile struct

        _check_absorb:
        lw      a1, 0x0294(v1)              // a1 = absorb routine
        beqz    a1, _check_blast_zone       // skip if no absorb routine present
        nop
        jalr    ra, a1                      // run absorb routine
        lw      a0, 0x0020(sp)              // a0 = projectile object
        bnez    v0, _destroy                // end if absorb routine returned 1 (destroy object)
        nop

        _check_blast_zone:
        lw      a1, 0x0298(v1)              // a1 = blast zone destruction routine
        beqz    a1, _destroy                // skip if no blast zone routine present
        nop
        jalr    ra, a1                      // run blast zone routine
        lw      a0, 0x0020(sp)              // a0 = projectile object

        _destroy:
        lw      v1, 0x001C(sp)              // v1 = projectile struct
        j       0x80166DA8                  // jump back to original routine (skips reflect logic)
        lli     v0, 0x0001                  // return 1 (destroy object)

        _original:
        j       _return                     // return
        sw      a0, 0x0008(v1)              // update projectile ownership (original line 1)
    }

    // @ Description
    // This hook adds a check for the reflect type and either runs the reflect routine or does what we specify
    scope override_item_reflect_routine_: {
        OS.patch_start(0xEBCDC, 0x8017129C)
        j       override_item_reflect_routine_
        nop
        _return:
        OS.patch_end()

        // v1 = item struct
        // a1 = routine to run
        // v0 = reflecting player struct

        lw      v0, 0x0084(a0)              // v0 = reflecting player struct (original line 2)
        addiu   at, r0, reflect_type.CUSTOM // at = custom reflect id
        lw      t6, 0x850(v0)               // t6 = reflect hb
        lh      t7, 0x0002(t6)              // t7 = current players reflect id
        bne     at, t7, _original           // branch to normal routine if not custom
        nop

        lh      t7, 0x0000(t6)              // t7 = custom reflect routine index
        beqz    t7, _original               // branch and run reflect routine if Franklin Badge
        nop

        // if here, custom reflect type is 1. We can extend this to add more later
        lw      a1, 0x0398(v1)              // a1 = item blast zone routine
        beqz    a1, _destroy                // skip if no blast zone routine present
        nop
        jalr    ra, a1                      // run blast zone routine
        lw      a0, 0x0020(sp)              // a0 = item object

        _destroy:
        j       0x801712E8                  // jump back to original routine (skips reflect logic)
        lli     v0, 0x0001                  // return 1 (destroy object)

        _original:
        j       _return                     // return
        sw      a0, 0x0008(v1)              // update item ownership (original line 1)

    }

    // @ Description
    // Custom absorb function for Pikachu's down b thunder
    scope pikachu_thunder_absorb_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t0, 0x0084(a0)              // t0 = current projectile struct
        lw      t1, 0x0264(t0)              // t1 = current projectile instance id
        li      t2, 0x80046704              // t2 = projectile objects head
        lw      t2, 0x0000(t2)              // t2 = first projectile object

        _loop:
        beqz    t2, _end                    // exit loop if next projectile object doesn't exist
        nop
        beql    t2, a0, _loop               // loop if we're checking the current object...
        lw      t2, 0x0004(t2)              // ...and t2 = next projectile object
        lw      t3, 0x0084(t2)              // t3 = projectile struct
        lw      t4, 0x0264(t3)              // t4 = instance id
        bnel    t1, t4, _loop               // skip if instance id does not match...
        lw      t2, 0x0004(t2)              // ...and t2 = next projectile object
        lw      t4, 0x000C(t3)              // t4 = projectile id
        lli     at, 0x000B                  // pikachu thunder head id
        bnel    at, t4, _loop               // skip if projectile != pikachu thunder head...
        lw      t2, 0x0004(t2)              // ...and t2 = next projectile object

        // if we're here, then a thunder head projectile matching this instance id was found
        // so we'll have the thunder collide with the absorb hitbox
        sw      t2, 0x0018(sp)              // 0x0018(sp) = thunder head object
        lli     a1, 0x0001                  // unknown argument
        jal     0x8016A640                  // thunder collision routine
        lw      a0, 0x0018(sp)              // a0 = thunder head object
        jal     0x801008F4                  // screen shake
        lli     a0, 0x0001                  // screen shake intensity
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coordinates
        jal     0x800FE068                  // create electric hit gfx
        lli     a1, 00023                   // a1(gfx size) = 23
        jal     0x80009A84                  // destroy thunder head
        lw      a0, 0x0018(sp)              // a0 = thunder head object


        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        lli     v0, OS.FALSE                // return FALSE (don't destroy projectile)
    }

    // @ Description
    // asm hook in common routine that determines what direction a projectile will go after reflected
    // this routine is shared between pretty much all projectiles reflect routines
    scope projectile_direction_fix_custom_: {
        OS.patch_start(0xE2B2C, 0x801680EC)
        j      projectile_direction_fix_custom_
        addiu   at, r0, 0x1002              // at = sonic spring projectile id (sonic spring uses fox laser reflect routine)
        _return:
        OS.patch_end()

        // a1 = reflecting player struct
        // a0 = reflected object

        lw      t6, 0x000C(a0)               // t6 = projectile id
        beq     t6, at, _normal              // branch to normal routine if sonics spring
        nop
        lw      t6, 0x0850(a1)               // t6 = ptr to players reflect hitbox

        addiu   at, r0, reflect_type.CUSTOM  // at = custom reflect id
        lh      t6, 0x0002(t6)               // t6 = current players reflect id
        bne     at, t6, _normal              // branch to normal routine if not custom
        nop

        // if here, using custom (type 3) so just invert the x speed.
        // s3 = -1 (int)
        lw      t6, 0x0020(a0)               // t6 = projectiles current x speed
        srl     at, t6, 31                   // at = current direction (0 if left, 1 if right)
        beqz    at, _face_left               // branch if profectile is facing left
        nop

        // if here, projectile is facing right
        sll     t6, t6, 1                    // remove positive number bitflag in float
        b       _save_x_speed
        srl     t6, t6, 1                    // value *= -1

        _face_left:
        lui     at, 0x8000
        or     t6, at, t6                    // value *= -1

        _save_x_speed:
        sw      t6, 0x0020(a0)               // save speed

        jr      ra                           // skip the rest of the routine
        nop

        _normal:
        lw      t6, 0x0044(a1)               // t6 = player facing direction, original line 1
        j       _return
        lwc1    f0, 0x0020(a0)               // f0 = projectile horizontal direction, original line 2
    }

    // @ Description
    // asm hook in common routine that determines what direction a thrown item will go after being reflected
    // this routine is shared between pretty much all thrown item reflect routines
    scope item_direction_fix_custom_: {
        OS.patch_start(0xEDE74, 0x80173434)
        j      item_direction_fix_custom_
        lw     v0, 0x0084(a0)                // original line 1, v0 = item struct
        _return:
        OS.patch_end()

        mtc1    r0, f10                      // original line 2

        lw      t6, 0x0008(v0)               // t6 = reflecting player object
        lw      v1, 0x0084(t6)               // v1 = reflecting player struct

        lw      t7, 0x0850(v1)               // t7 = pointer to reflecting hb
        beqz    t7, _normal                  // branch to normal routine if no reflect hb

        addiu   at, r0, reflect_type.CUSTOM  // at = custom reflect id
        lh      t6, 0x0002(t7)               // t6 = current players reflect id
        bne     at, t6, _normal              // branch to normal routine if not custom
        nop

        // if here, using custom (type 3) so just invert the x speed.
        // s3 = -1 (int)
        lw      t6, 0x002C(v0)               // t6 = items current x speed
        beqz    t6, _branch_skip             // skip if the speed is 0
        srl     at, t6, 31                   // at = current direction (0 if left, 1 if right)
        beqz    at, _face_left               // branch if item is facing left
        nop

        // if here, item is facing right
        sll     t6, t6, 1                    // remove positive number bitflag in float
        b       _save_x_speed
        srl     t6, t6, 1                    // value *=-1

        _face_left:
        lui    at, 0x8000                    // at = negative value bitflag
        or     t6, at, t6                    // value *=-1

        _save_x_speed:
        sw      t6, 0x002C(v0)               // save speed
        _branch_skip:
        jr      ra                           // skip the rest of the routine
        or      v0, r0, r0                   // return 0

        _normal:
        j       _return
        nop

    }

    // @ Description
    // This table can be used if we add more player action reflect routines to run
    scope custom_reflect_table: {                // offset
        dw Item.FranklinBadge.reflect_initial_   // 0x00
        dw MarinaDSP.absorb_initial_             // 0x04
        dw DededeNSP.absorb_initial_             // 0x08
        dw 0
        // add more routines here
    }
}
