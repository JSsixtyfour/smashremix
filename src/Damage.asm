// Damage.asm
if !{defined __DAMAGE__} {
define __DAMAGE__()
print "included Damage.asm\n"

// This file adds support for new damage types. In most cases I can find, hitbox parameters use 4 bits for damage type, so a maximum of 16 is possible without far more intense revisions to the engine.
// Vanilla only uses 6 damage types (7 if you include the almost completely unfinished/removed "Ice" effect). So we should be able to add up to a maximum of 9 new types.
// If we somehow manage to find the need for more than 9 new damage types, then I would consider myself to have failed my duties in the role of "designer and gameplay developer".

scope Damage {
    variable new_dmg_type_count(0)       // number of new damage types

    // @ Description
    // Adds a new damage type.
    // name - damage type name, id.{name} will be created
    // on_hit_gfx - address of jump table routine which creates GFX on hit
    // on_hit_routine - address of jump table routine which starts a GFX Routine on hit
    macro add_damage_type(name, on_hit_gfx, on_hit_routine) {
        global variable new_dmg_type_count(new_dmg_type_count + 1)
        constant id.{name}(new_dmg_type_count + 0x6)
        pushvar origin, base
        // add to on hit GFX jump table
        origin on_hit_gfx.table_origin + (id.{name} * 4)
        dw {on_hit_gfx}
        // add to on hit GFX Routine jump table
        origin on_hit_routine.table_origin + (id.{name} * 4)
        dw {on_hit_routine}
        pullvar base, origin

        // print message
        print "Added Damage Type: {name} - ID is 0x" ; OS.print_hex(id.{name}) ; print "\n"
    }

    // ASM PATCHES

    // @ Description
    // Modifies an original routine (0x800E3EBC) to use a jump table rather than branches for each id.
    // The jump table will be extended to accommodate 16 effects.
    scope extend_on_hit_gfx_: {
        OS.patch_start(0x5F7C4, 0x800E3FC4)
        // v1 = damage type id
        sll     at, v1, 0x2                 // at = offset (id * 4)
        li      t6, on_hit_gfx.table        // ~
        addu    t6, t6, at                  // t6 = on_hit_gfx.table + offset
        lw      t6, 0x0000(t6)              // t6 = jump address for current damage type
        jr      t6                          // jump to routine for current damage type
        nop
        nop
        nop
        nop
        nop
        nop
        OS.patch_end()
    }

    // @ Description
    // Modifies an original routine (0x80140BCC) to use a jump table rather than branches for each id.
    // The jump table will be extended to accommodate 16 effects.
    scope extend_on_hit_routines_: {
        OS.patch_start(0xBB60C, 0x80140BCC)
        // a1 = damage type id
        // a2 = damage level (0-3)
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sll     at, a1, 0x2                 // at = offset (id * 4)
        li      t6, on_hit_routine.table    // ~
        addu    t6, t6, at                  // t6 = on_hit_routine.table + offset
        lw      t6, 0x0000(t6)              // t6 = jump address for current damage type
        or      a3, a2, r0                  // a3 = damage level
        or      a2, r0, r0                  // a2 = 0
        jr      t6                          // jump to routine for current damage type
        lli     a1, 0x0005                  // a1 = id for "normal" hit GFX Routine
        nop
        OS.patch_end()
    }

    // @ Description
    // Jump table routine for creating "normal" GFX on hit
    scope create_normal_gfx_: {
        j       0x800E4044                  // jump to original routine
        lui     at, 0x4334                  // original line
    }

    // @ Description
    // Jump table routine for creating "slash" GFX on hit
    scope create_slash_gfx_: {
        j       0x800E4024                  // jump to original routine
        or      a0, s1, r0                  // original line
    }

    // @ Description
    // Jump table routine for creating "shadow" GFX on hit
    scope create_shadow_gfx_: {
        li      t6, GFX.current_gfx_id      // t6 = current_gfx_id
        lli     at, 0x006C                  // at = dark cross id
        j       0x800E3FF4                  // jump to original fire effect
        sw      at, 0x0000(t6)              // set dark cross as current GFX id
    }


    // @ Description
    // Jump table for creating GFX on hit based on damage type.
    OS.align(16)
    scope on_hit_gfx {
        constant return(0x800E40D8)
        constant NORMAL(create_normal_gfx_)
        constant FIRE(0x800E3FF4)
        constant ELECTRIC(0x800E4004)
        constant SLASH(create_slash_gfx_)
        constant COIN(0x800E4014)
        constant SHADOW(create_shadow_gfx_)
        constant LASER(create_normal_gfx_)
        constant DEKU_STUN(create_normal_gfx_)
        constant BURY(create_normal_gfx_)
        constant FLASHBANG(create_normal_gfx_)
        table:
        constant table_origin(origin())
        dw NORMAL                           // 0x0 - normal
        dw FIRE                             // 0x1 - fire
        dw ELECTRIC                         // 0x2 - electric
        dw SLASH                            // 0x3 - slash
        dw COIN                             // 0x4 - coin
        dw NORMAL                           // 0x5 - ice (mostly unfinished/removed)
        dw NORMAL                           // 0x6 - sleep
        while pc() < (table + 0x40) {
            dw NORMAL                       // 0x7-0xF - normal by default
        }
    }

    // @ Description
    // Jump table routine for starting "shadow" GFX Routine on hit
    scope begin_shadow_gfx_routine_: {
        addiu   a1, a3, GFXRoutine.id.SHADOW_1 // a1 = base SHADOW effect id + damage level
        jal     0x800E9814                  // begin GFX routine
        or      a2, r0, r0                  // a2 = 0
        j       on_hit_routine.return       // return
        nop
    }

    // @ Description
    // Jump table routine for starting "laser" GFX Routine on hit
    scope begin_laser_gfx_routine_: {
        lli     a1, GFXRoutine.id.LASER     // a1 = LASER effect id
        jal     0x800E9814                  // begin GFX routine
        or      a2, r0, r0                  // a2 = 0
        j       on_hit_routine.return       // return
        nop
    }

    // @ Description
    // Jump table routine for starting "laser" GFX Routine on hit
    scope begin_deku_stun_gfx_routine_: {
        lli     a1, GFXRoutine.id.DEKU_STUN // a1 = DEKU_STUN effect id
        jal     0x800E9814                  // begin GFX routine
        or      a2, r0, r0                  // a2 = 0
        j       on_hit_routine.return       // return
        nop
    }

    // @ Description
    // Jump table for applying GFX Routines on hit based on damage type.
    OS.align(16)
    scope on_hit_routine {
        constant return(0x80140C38)
        constant NORMAL(0x80140C30)
        constant FIRE(0x80140BFC)
        constant ELECTRIC(0x80140C10)
        constant ICE(0x80140C20)
        constant SHADOW(begin_shadow_gfx_routine_)
        constant LASER(begin_laser_gfx_routine_)
        constant DEKU_STUN(begin_deku_stun_gfx_routine_)
        constant BURY(0x80140C30)
        table:
        constant table_origin(origin())
        dw NORMAL                           // 0x0 - normal
        dw FIRE                             // 0x1 - fire
        dw ELECTRIC                         // 0x2 - electric
        dw NORMAL                           // 0x3 - slash
        dw NORMAL                           // 0x4 - coin
        dw ICE                              // 0x5 - ice (mostly unfinished/removed)
        dw NORMAL                           // 0x6 - sleep
        dw NORMAL                           // 0x7 - stun (mewtwo)
        dw NORMAL                           // 0x8 - 
        dw NORMAL                           // 0x9 - 
        dw DEKU_STUN                        // 0xA - deku stun
        dw BURY                             // 0xB - bury
        dw NORMAL                           // 0xC - flashbang

        while pc() < (table + 0x18) {
            dw NORMAL                       // 0xB-0xF - normal by default
        }
    }

    // @ Description
    // Patch which adds a check for the "stun" damage type to put opponents into the Stun action.
    // If the character is already in the Stun action, acts like electric damage instead.
    // Modifies the routine which originally handles the action change for sleep.
    scope stun_damage_action_: {
        OS.patch_start(0xBBFCC, 0x8014158C)
        j       stun_damage_action_
        nop
        _return:
        constant _stun_return(0x8014159C)
        constant _branch_return(0x801415A8)
        OS.patch_end()

        // a0 = player object
        // v1 = damage type
        // at = damage.id.SLEEP

        bnel    v1, at, _stun_check         // skip if damage type != SLEEP
        nop
        // if damage type = SLEEP
        j       _return                     // return
        nop

        _stun_check:
        lli     at, Damage.id.FLASHBANG     // at = id.Stun
        beq     v1, at, _flashbang_branch             // skip if damage type != STUN (modified original line 1)
        lli     at, Damage.id.DEKU_STUN     // at = id.Deku_Stun
        beq     v1, at, _deku_stun_branch   // skip if damage type = DEKU_STUN
        lli     at, Damage.id.BURY     		// at = id.BURY
        beq     v1, at, _bury_branch   		// skip if damage type = BURY
        lli     at, Damage.id.STUN          // at = id.Stun
        bne     v1, at, _branch             // skip if damage type != STUN (modified original line 1)
        nop
        // if damage type = STUN
        lw      t9, 0x0084(a0)              // ~
        lw      t9, 0x0024(t9)              // t9 = current action id
        lli     at, Action.Stun             // at = Stun action id
        beq     at, t9, _branch             // skip/take original branch if action id = Stun
        nop
        // if current action != Stun
        lw      t9, 0x0084(a0)              // ~
        lw      at, 0x07FC(t9)              // at = hit direction
        lw      t8, 0x0044(v0)              // t8 = facing direction
        bne     at, t8, _branch             // skip/take original branch if hit direction != facing direction
        nop
        // if hit direction = facing direction
        lw      at, 0x014C(t9)              // at = kinetic state
        bnez    at, _branch                 // skip/take original branch if character is aerial (failsafe)
        nop
        
        jal     stun_initial_modified_      // initial subroutine for Stun action
        nop
        j       _stun_return                // return
        nop

        // if damage type = DEKU_STUN
        _deku_stun_branch:
        lw      t9, 0x0084(a0)              // ~
        lw      t9, 0x0024(t9)              // t9 = current action id
        lli     a1, Action.Stun             // a1 = Stun action id
        beql    a1, t9, _deku_stun_branch_2 // skip if action id = Stun
        addiu   a1, r0, 0x0000              // a1 = boolean that skips

        _deku_stun_branch_2:
        // if current action != Stun
        jal     deku_stun_initial_modified_ // initial subroutine for Stun action
        lw      t9, 0x0084(a0)              // ~
        j       _stun_return                // return
        nop
		
        // if damage type = BURY
        _bury_branch:
        lw      t9, 0x0084(a0)              // t9 = player struct
		// An action check would not work for bury so we compare the routines
		li		a1, buried_main_			// a1 = pointer to buried main routine
        lw      t9, 0x09D4(t9)              // t9 = current main action routine
		beql	a1, t9, _bury_branch_2		// branch if not buried
        addiu   a1, r0, 0x0000              // a1 = skip bury

        _bury_branch_2:
        jal     bury_or_plunge_initial_     // initial subroutine for Bury
        lw      t9, 0x0084(a0)              // ~
        j       _stun_return                // return
        nop

        // if damage type = DEKU_STUN
        _flashbang_branch:
        lw      t9, 0x0084(a0)              // ~
        lw      t9, 0x0024(t9)              // t9 = current action id
        lli     a1, Action.Stun             // a1 = Stun action id
        beql    a1, t9, _flashbang_branch_2 // skip if action id = Stun
        addiu   a1, r0, 0x0000              // a1 = boolean that skips

        _flashbang_branch_2:
        // if current action != Stun
        jal     flashbang_initial_modified_ // initial subroutine for Stun action
        lw      t9, 0x0084(a0)              // ~
        j       _stun_return                // return
        nop

        _branch:
        j       _branch_return              // return, taking original branch
        lw      t9, 0x07F4(v0)              // original line 2
    }

    // @ Description
    // Modified initial subroutine for stun action, sets argument 4 of the change action subroutine to 0.
    // This prevents a bug where Yoshi would be invisible after being stunned out of roll, and potentially other issues.
    scope stun_initial_modified_: {
        addiu   sp, sp,-0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        lw      s0, 0x0084(a0)              // original logic
        j       0x801498BC                  // return to original Stun initial subroutine
        sw      r0, 0x0010(sp)              // argument 4 = 0
    }

    // @ Description
    // Modified initial subroutine for stun action, sets argument 4 of the change action subroutine to 0.
    // This prevents a bug where Yoshi would be invisible after being stunned out of roll, and potentially other issues.
    scope deku_stun_initial_modified_: {
        addiu   sp, sp,-0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        beqz    a1, _end                    // skip action change if boolean was set to 0
        lw      s0, 0x0084(a0)              // original logic

        lw      at, 0x14C(s0)               // at = kinetic state
        beqz    at, _branch                 // branch if grounded
        // this | grounded
        addiu   a1, r0, 0x00A4              // action id = stun
        // or | aerial
        addiu   a1, r0, Action.ShieldBreakFall // action id = ShieldBreakFall
        _branch:
        addiu   a2, r0, 0x0000              // a2 = set starting frame
        sw      r0, 0x0010(sp)              // argument 4 = 0 (idk what this is)
        jal     0x800E6F24                  // change action
        lui     a3, 0x0000                  // animation speed = 0

        // I just kept having issues with gfx routine so I copied the return routine as a workaround.
        addiu   t9, r0, 0x001E
        bne     t7, at, branch_1
        or      a0, s0, r0
        addiu   t8, r0, 0x001E
        b       branch_2
        sw      t8, 0x0034(s0)

        branch_1:
        sw      t9, 0x0034(s0)

        branch_2:
        lw      t0, 0x002c (s0)
        addiu   t1, r0, 0x0190
        subu    a1, t1, t0
        bgtz    a1, branch_3
        nop
        or      a1, r0, r0

        branch_3:
        jal     0x8014e3ec
        addiu   a1, a1, 0x005a
        lw      a0, 0x0028 (sp)
        addiu   a1, r0, 0x006C       // argument = deku stun id
        jal     0x800e9814
        or      a2, r0, r0
		
        _end:
        lw      ra, 0x0024 (sp)
        lw      s0, 0x0020 (sp)
        jr      ra
        addiu   sp, sp, 0x28
    }
	
	
	// Based on melees bury time formula but 
	constant initial_buried_time(99)				// frames
	constant buried_percent_multiplier(0x3F333333)	// 0.7
	constant buried_action(Action.DownBounceU)

    // @ Description
    // Checks and buries or plunges an opponent.
    scope bury_or_plunge_initial_: {
        addiu   sp, sp,-0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        beqz    a1, _end                    // skip action change if boolean was set to 0
        lw      s0, 0x0084(a0)              // original logic
		
		// get buried timer
		lw		at, 0x002C(s0)				// s0 = players percent
		mtc1	at, f4
		cvt.s.w f4, f4						// f4 = players percent (float)
		li		at, buried_percent_multiplier
		mtc1	at, f6						// f6 = multiplier
		mul.s	f4, f6, f4					// f4 = player damage% * 0.7
		nop
		cvt.w.s f4, f4						// f4 = buried time(int)
		
		// set buried timer
		mfc1	at, f4						// at = buried time (int)
		addiu	at, at, initial_buried_time // at = inital time plus player percent thing
		sw		at, 0x026C(s0)				// save buried timer
		
		// check kinetic state
        lw      at, 0x14C(s0)               // at = kinetic state
        bnez    at, _aerial                 // skip bury if aerial
		nop
		
		// set buried
		jal		bury_player_
        lw      a0, 0x0028(sp)              // a0 = player object
		b		_end
        lw      a0, 0x0028(sp)
		
		_aerial:
		// set aerial plunge downward to bury
		jal		plunge_player_
        lw      a0, 0x0028(sp)              // a0 = player object
		b		_end
        lw      a0, 0x0028(sp)              // a0 = player object
		
        _end:
        lw      ra, 0x0024(sp)
        lw      s0, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x28
    }
    
    // @ Description
    // Buries an opponent.
    scope bury_initial_: {
        addiu   sp, sp,-0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        lw      s0, 0x0084(a0)              // original logic

        // get buried timer
        lw      at, 0x002C(s0)              // s0 = players percent
        mtc1    at, f4
        cvt.s.w f4, f4                      // f4 = players percent (float)
        li      at, buried_percent_multiplier
        mtc1    at, f6                      // f6 = multiplier
        mul.s   f4, f6, f4                  // f4 = player damage% * 0.7
        nop
        cvt.w.s f4, f4                      // f4 = buried time(int)
        
        // set buried timer
        mfc1    at, f4                      // at = buried time (int)
        addiu   at, at, initial_buried_time // at = inital time plus player percent thing
        sw      at, 0x026C(s0)              // save buried timer
        
 
        // set buried
        jal     bury_player_
        lw      a0, 0x0028(sp)              // a0 = player object
        lw      a0, 0x0028(sp)
        
        
        _end:
        lw      ra, 0x0024(sp)
        lw      s0, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x28
    }

    constant FLASHBANG_BASE_STUN_TIME(90)
    constant FLASHBANG_STUN_TIME_GROUNDED(150)  // additional stun time if grounded
    constant FLASHBANG_STUN_TIME_AERIAL(0)      // addition stun time if aerial
    constant FLASHBANG_AERIAL_STUN_Y_VELOCITY(0x4248)
    // frame count = 90 + extra stun time + player %.
    // can mash out

    // @ Description
    // Modified initial subroutine for stun action, sets argument 4 of the change action subroutine to 0.
    // This prevents a bug where Yoshi would be invisible after being stunned out of roll, and potentially other issues.
    scope flashbang_initial_modified_: {
        addiu   sp, sp,-0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        beqz    a1, _end                    // skip action change if boolean was set to 0
        lw      s0, 0x0084(a0)              // original logic

        lw      at, 0x14C(s0)               // at = kinetic state
        beqz    at, _change_action          // branch if grounded
        // this | grounded
        addiu   a1, r0, 0x00A4              // action id = stun
        // or | aerial
        addiu   a1, r0, Action.ShieldBreakFall // action id = ShieldBreakFall
        _change_action:
        addiu   a2, r0, 0x0000              // a2 = set starting frame
        sw      r0, 0x0010(sp)              // argument 4 = 0 (idk what this is)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // animation speed = 1
        
        addiu   a0, s0, 0
        lw      at, 0x14C(s0)               // at = kinetic state
        beqzl   at, _continue               // branch if grounded
        addiu   t1, r0, FLASHBANG_STUN_TIME_GROUNDED // initial stun timer (grounded)
        li      at, stun_main_aerial_
        sw      at, 0x09D4(s0)              // overwrite main routine so player can mash out
        addiu   t1, r0, FLASHBANG_STUN_TIME_AERIAL // initial stun timer (aerial)

        // retain current aerial velocity (thrown)
        // lui     at, FLASHBANG_AERIAL_STUN_Y_VELOCITY
        // sw      at, 0x0058(s0)              // overwrite air y velocity
        
        lui     at, 0x3F00
        mtc1    at, f6
        lwc1    f4, 0x0048(s0)              // f4 = x velocity
        mul.s   f4, f6
        nop
        swc1    f4, 0x0048(s0)              // x velocity / 2
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        mul.s   f4, f6
        nop
        
        swc1    f4, 0x004C(s0)              // y velocity / 2

        _continue:
        addiu   t9, r0, 0x001E
        sw      t9, 0x0034(s0)

        lw      t0, 0x002C(s0)              // t0 = current percent
        addu    a1, t1, t0                  // stun damage = initial stun time + current percent

        jal     0x8014E3EC                  // apply stun timer
        addiu   a1, a1, FLASHBANG_BASE_STUN_TIME // stun time += base stun time
        lw      a0, 0x0028(sp)
        addiu   a1, r0, 0x0025              // argument = stun overlay gfx
        jal     0x800E9814
        or      a2, r0, r0

        _end:
        lw      ra, 0x0024(sp)
        lw      s0, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x28
    }
    
    // @ Description
    // main routine for stunned players who are aerial (flashbang)
    scope stun_main_aerial_: {
        addiu   sp, sp, -0x20
        sw  ra, 0x0014(sp)
        sw  a0, 0x0020(sp)                  // store player object
        lw  a0, 0x0084(a0)                  // a0 = player struct
        
        lw      t6, 0x026C(a0)              // get stunned timer
        addiu   t7, t6, -1                  // -1
        sw      t7, 0x026C(a0)              // stunned--;
        sw      t7, 0x0018(sp)              // save stunned timer to sp
        jal     0x8014E400                  // get/apply mash inputs
        sw      a0, 0x001C(sp)              // save player struct to sp
        lw      a0, 0x001C(sp)              // load player struct
        lw      v0, 0x026C(a0)              // get stunned timer
        
        lw      t2, 0x0018(sp)              // get previous stunned timer
        subu    t3, v0, t2                  // wizard magic stuff from 0x80149874
        sll     t4, t3, 2                   // ~
        subu    t4, t4, t3                  // ~
        addu    t5, v0, t4                  // ~
        bgtz    v0, _end                    // branch if timer is not up
        sw      t5, 0x026C(a0)              // save timer again
        
        // unbury player if timer is up
        jal     0x8013F9E0                  // common routine set player to aerial idle
        lw      a0, 0x0020(sp)              // restore player object
        b       _end
        nop
        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x20
    }
    

    // @ Description
	// Buries a grounded player.
	// a0 = player object
	scope bury_player_: {
		addiu	sp, sp, -0x30
		sw		ra, 0x0014(sp)
        sw      a0, 0x0028(sp)              // save a0
        lw      v0, 0x0084(a0)              // v0 = player struct

		lh		at, 0x00F6(v0)				// at = current clipping flag (surface id)
		andi	t0, at, 0x4000				// t0 = second byte only
		beqz	t0, _continue               // skip if not a soft platform
		andi	t0, at, 0x00FF				// v0 = second byte only
		
        lw      at, 0x0024(v0)              // at = players current action
		addiu	t1, r0, PLUNGE_ACTION		// t1 = plunge action
		beq		t1, at, _continue			// continue normally if already aerial
		nop
		
		_soft_platform_aerial:
		jal		0x800DEEC8					// put player under the platform?
		move	a0, v0						// a0 = player struct
		jal		plunge_player_				// set the player into a plunge state
        lw      a0, 0x0028(sp)              // restore a0
        lw      a0, 0x0028(sp)              // restore a0
		lw		v1, 0x0074(a0)				// v1 = player position struct
		lui		at, 0x4120					// at = 10.0
		mtc1	at, f4
		lwc1	f6, 0x0020(v1)				// f6 = players y position
		sub.s	f4, f6, f4					// f4 = player.y - 10.0	
		swc1	f4, 0x0020(v1)				// put player underneath the platform
		b 		_end						
		nop
		
		_continue:
		bnez	t0, _hazard_platform_check
		nop
        
		_bury:
		lw		a0, 0x0084(a0)				// a0 = player struct
        lw      v0, 0x00EC(a0)              // v0 = clipping id of clipping cirectly under player
        addiu   at, r0, 0xFFFF              // at = -1 (no clipping)
        beq     at, v0, _end                // skip bury if player is not above a platform (keep plunging player)
        nop
		jal		0x800DEE98					// set grounded?
		nop
        lw      a0, 0x0028(sp)              // restore a0
		addiu   a1, r0, buried_action 		// action id = DownBounceU
        addiu   a2, r0, 0x0000              // a2 = set starting frame
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x0000                  // animation speed = 0
		
        lw      a0, 0x0028(sp)              // restore a0
        lw      v0, 0x0084(a0)              // v0 = player struct
		li		at, buried_main_
		sw 		r0, 0x0048(v0)				// set x velocity to 0
		sw		r0, 0x0060(v0)				// set ground x velocity to 0
		sw		at, 0x09D4(v0)				// overwrite main routines
		li		at, buried_interrupt_
		sw		at, 0x09D8(v0)				// overwrite interrupt routine
		sw		r0, 0x09E0(v0)				// remove physics routine
		li		at, buried_collision_
		sw		at, 0x09E4(v0)				// overwrite collision routine
		FGM.play(0x11F)						// play fgm that sounds good
		b		_end
		nop
		
		_hazard_platform_check:
        li      at, Toggles.entry_hazard_mode
        lw      at, 0x0004(at)              // at = hazard_mode (hazards disabled when at = 1 or 3)
        andi    at, at, 0x0001              // at = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnezl   at, _bury                   // bury if hazards are disabled
		nop
		
		_hazards_on:
        jal     0x800DEE54                  // transition player to to idle
        nop
		
		_end:
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x30
	}
	
	constant BURIED_Y_OFFSET(0xC240)
	
	// @ Description
	// main routine for bury
	// todo: make this a shared action
	scope buried_main_: {
		addiu	sp, sp, -0x20
		sw		ra, 0x0014(sp)
		sw		a0, 0x0020(sp)				// store player object
		lw		a0, 0x0084(a0)				// a0 = player struct
		
		lw		t6, 0x026C(a0)				// get stunned timer
		addiu	t7, t6, -1					// -1
		sw		t7, 0x026C(a0)				// stunned--;
		sw 		t7, 0x0018(sp)				// save stunned timer to sp
		jal		0x8014E400					// get/apply mash inputs
		sw		a0, 0x001C(sp)				// save player struct to sp
		lw		a0, 0x001C(sp)				// load player struct
		lw		v0, 0x026C(a0)				// get stunned timer
		
		lw		t2, 0x0018(sp)				// get previous stunned timer
		subu	t3, v0, t2					// wizard magic stuff from 0x80149874
		sll		t4, t3, 2					// ~
		subu	t4, t4, t3					// ~
		addu	t5, v0, t4					// ~
		bgtz	v0, _set_y_offset			// branch if timer is not up
		sw		t5, 0x026C(a0)				// save timer again
		
		// unbury player if timer is up
		jal 	unbury_player_				// common routine sets players state to jump
		lw		a0, 0x0020(sp)				// restore player object
		b		_end
		nop
		
		_set_y_offset:
		lw		a0, 0x001C(sp)				// load player struct from sp
		lw		v0, 0x08F8(a0)				// get player joint
		lui		at, BURIED_Y_OFFSET			// at = draw y offset
		mtc1	at, f6
		lwc1	f4, 0x0020(v0)				// f4 = current y
		add.s	f4, f4, f6					// f1 = current y - buried y offset
		nop
		swc1 	f4, 0x0020(v0)              // save new y offset
		
		_end:
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x20
	}
		
	// @ Description
	// interrupt routine for bury
	scope buried_interrupt_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)
		
		// idk what goes here
		
		_end:
		jr		ra
		addiu	sp, sp, 0x18
	}
	
	// @ Description
	// Sets player to jump if unburied
	scope buried_collision_: {
		addiu	sp, sp, -0x18	
		sw		ra, 0x0014(sp)
		sw		a0, 0x0008(sp)			// store a0
		li		a1, unbury_player_		// a1 = routine to run if aerial
		jal		0x800DDDDC				// runs a1 if aerial or touching a wall
		nop
		
		beqz	v0, _end				// branch if not aerial
		lw		a0, 0x0008(sp)			// restore a0
		
		lli		at, buried_action		// at = 
		lw		v1, 0x0084(a0)			// v1 = player struct
		lw		t0, 0x0024(v1)			// t0 = current action
		bne		at, t0, _end			// branch if action is not the same
		lw		t0, 0x00DC(v1)			// check if moving into a wall
		beqz	t0, _end				// branch if not moving towards a wall
		nop
		jal		unbury_player_			// unbury if moving into a wall.
		nop
		
		_end:
		lw		ra, 0x0014 (sp)	
		jr		ra				
		addiu	sp, sp, 0x18				
	}

	// @ Description
	// forces a player to short hop
	// a0 = player object
	scope unbury_player_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)

		// fake jump setup
		lw		v0, 0x0084(a0)				// v0 = player object
		sw		r0, 0x0B18(v0)				// stick jump = 0
		lli		at, 1						// set min. c jump height
		sw		at, 0x0B24(v0)				// ~
		lli		at, 2						// jump type = c jump
		jal 	0x8013F880					// common routine sets players state to jump
		sw		at, 0x0B20(v0)				// set temp var to short hop

		// FGM.play(0x437)					// play pitfall jump fgm
		// removed fgm so buried damage isn't always tied to animal crossing

		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x18
	}
	
	constant PLUNGE_ACTION(Action.ShieldBreakFall)
	
	constant INITIAL_PLUNGE_SPEED(0xC248)	// y speed -50
    // @ Description
	// plunges a aerial player downwards to be buried
	// todo: made this a shared action
	scope plunge_player_: {
		addiu	sp, sp, -0x30
		sw		ra, 0x0014(sp)
        sw      a0, 0x0028(sp)              // save a0

	    addiu   a1, r0, PLUNGE_ACTION	    // action id = PLUNGE_ACTION
        addiu   a2, r0, 0x0000              // a2 = set starting frame
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x0000                  // animation speed = 0
		
        lw      a0, 0x0028(sp)              // restore a0
		lui		at, INITIAL_PLUNGE_SPEED	// at = INITIAL_PLUNGE_SPEED
        lw      s0, 0x0084(a0)              // restore s0
		sw		r0, 0x0048(s0)				// x velocity = 0
		sw		r0, 0x0054(s0)				// air x velocity = 0
		sw		r0, 0x0058(s0)				// air y velocity = 0
		sw		r0, 0x0060(s0)				// ground x velocity = 0
		sw		at, 0x004C(s0)				// overwrite y velocity
		li		at, plunge_main_
		sw		at, 0x09D4(s0)				// overwrite main routine
		
		li		at, plunge_interrupt_
		sw		at, 0x09D8(s0)				// overwrite interrupt routine
		sw		r0, 0x09DC(s0)				// remove interrupt action routine
		
		li		at, plunge_collision_
		sw		at, 0x09E0(s0)				// overwrite collision routine
        
        // prevent stun transition
        li      at, 0x800DEDF0              // some routine that does not transition to stun?
        sw      at, 0x09E4(s0)              // overwrite current routine
        
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x30
	}
	
	// @ Description
	// main routine for plunge
	scope plunge_main_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)
		lw		v0, 0x0084(a0)
        
        lwc1    f4, 0x0090(v0)      // get y velocity
        lui     at, 0xC300          // minimum y velocity
        mtc1    at, f6
        c.lt.s  f4, f6
        nop
        bc1fl   _end
        nop

        // if here, cap y velocity
        swc1    f6, 0x0090(v0)

		_end:
		lw		ra, 0x0014(sp)
		jr		ra
		addiu	sp, sp, 0x18
	}
	
	// @ Description
	// interrupt routine for plunge
	scope plunge_interrupt_: {
		addiu	sp, sp, -0x18
		sw		ra, 0x0014(sp)
		
		// lw		v1, 0x0084(a0)		// v1 = player struct
		// lw		at, 0x014C(a0)		// get kinetic state
		// bnez	at, _end
		// nop
		
		// // set to buried if grounded

		_end:
		jr		ra
		addiu	sp, sp, 0x18
	}
	
	// @ Description
	// interrupt routine for plunge
	scope plunge_collision_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        OS.UPPER(a1, bury_player_)
        jal     0x800DE6E4     // subroutine runs a1 if grounded
        addiu   a1, a1, bury_player_
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x18
	}
	
	// @ Description
	// Don't allow buried fighters to be pushed by Whispy (DL)
	scope prevent_wind_push_while_buried: {
		OS.patch_start(0x63EB4, 0x800E86B4)
		j		prevent_wind_push_while_buried
		lw		v0, 0x0084(a0)			// original line 1
		_return:
		OS.patch_end()

		// check if fighter is buried
		li 		at, buried_main_
		lw		t7, 0x09D4(v0)			// t7 = current main action routine
		beq		at, t7, _skip_wind_push
		nop
		j		_return					// push player as normal if not buried
		lw 		t7, 0x0000(a1)			// original line 2
		
		_skip_wind_push:
		j		0x800E86CC				// skip to end of this routine
		lw		t7, 0x0008(a1)			// original line
	}

    // @ Description
    // Patch which adds a check for the "stun" damage type to put the opponents into DamageElec actions.
    // This is only used if the character is already in the Stun action.
    // Modifies the routine which originally loads action ids for electric damage.
    scope stun_electric_action_: {
        OS.patch_start(0xBBD28, 0x801412E8)
        j       stun_electric_action_
        nop
        _return:
        constant _branch_return(0x80141330)
        OS.patch_end()

        // t0 = damage type
        // at = damage.id.ELECTRIC

        beq     t0, at, _electric           // branch if damage type = ELECTRIC
        lli     at, Damage.id.BURY     		// at = id.BURY
        bne     t0, at, _bury               // skip if damage type != BURY (modified original line 1)
        lli     at, Damage.id.DEKU_STUN     // at = id.DEKU_STUN
        bne     t0, at, _deku_stun          // skip if damage type != DEKU_STUN (modified original line 1)
        lli     at, Damage.id.STUN          // at = id.STUN
        bne     t0, at, _stun               // skip if damage type != STUN (modified original line 1)
        lli     at, Damage.id.FLASHBANG     // at = id.FLASHBANG
        bne     t0, at, _stun               // skip if damage type != FLASHBANG (modified original line 1)
        nop

        _electric:
        // if damage type = ELECTRIC or STUN
        j       _return                     // return
        nop

        _flashbang:
        _bury:
        _deku_stun:
        _stun:
        j       _branch_return              // return, taking original branch
        lw      t4, 0x00A0(sp)              // original line 2

    }


    // ADD NEW DAMAGE TYPES HERE

    print "============================== DAMAGE TYPES ============================== \n"

    // name - damage type name, id.{name} will be created
    // on_hit_gfx - address of jump table routine which creates GFX on hit
    // on_hit_routine - address of jump table routine which starts a GFX Routine on hit
    add_damage_type(SHADOW, on_hit_gfx.SHADOW, on_hit_routine.SHADOW)
    add_damage_type(STUN, on_hit_gfx.ELECTRIC, on_hit_routine.ELECTRIC)
    add_damage_type(LASER, on_hit_gfx.LASER, on_hit_routine.LASER)
    add_damage_type(DEKU_STUN, on_hit_gfx.DEKU_STUN, on_hit_routine.DEKU_STUN)
    add_damage_type(BURY, on_hit_gfx.BURY, on_hit_routine.BURY)
    add_damage_type(FLASHBANG, on_hit_gfx.ELECTRIC, on_hit_routine.ELECTRIC)

    print "========================================================================== \n"

    // constants for original damage types
    scope id {
        constant NORMAL(0x0)
        constant FIRE(0x1)
        constant ELECTRIC(0x2)
        constant SLASH(0x3)
        constant COIN(0x4)
        constant SLEEP(0x6)
    }
}
}