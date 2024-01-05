// Surface.asm
if !{defined __SURFACE__} {
define __SURFACE__()
print "included Surface.asm\n"

// This file adds support for additional surface types.

scope Surface {   
    variable new_surface_count(0)           // number of new surface types
    variable new_knockback_struct_count(0)  // number of new knockback structs

    // @ Description
    // Add a new surface type.
    // name - surface name, used for display only
    // friction - friction value used by the surface, default = 4.0
    // bool_knockback - OS.FALSE = no knockback, OS.TRUE = apply knockback
    // knockback_type - not a well understood variable, usually determines FGM but has other uses
    // damage - parameter for knockback
    // knockback_angle - parameter for knockback
    // knockback_growth - parameter for knockback
    // fixed_knockback - parameter for knockback
    // base_knockback - parameter for knockback
    // effect - parameter for knockback
    // fgm_id - FGM id to use when applying knockback
    macro add_surface(name, friction, bool_knockback, knockback_type, damage, knockback_angle, knockback_growth, fixed_knockback, base_knockback, effect, fgm_id) {
        global variable new_surface_count(new_surface_count + 1)
        evaluate n(new_surface_count)
        // add surface parameters
        global define new_surface_{n}_name({name})
        global define new_surface_{n}_friction({friction})
        global define new_surface_{n}_struct(OS.NULL)
        // add knockback parameters
        if {bool_knockback} == OS.TRUE {
            global variable new_knockback_struct_count(new_knockback_struct_count + 1)
            evaluate m(new_knockback_struct_count)
            global define new_surface_{n}_struct(NEW_STRUCT_{m})
            
            global variable knockback_struct_{m}.type({knockback_type})
            global variable knockback_struct_{m}.damage({damage})
            global variable knockback_struct_{m}.angle({knockback_angle})
            global variable knockback_struct_{m}.growth({knockback_growth})
            global variable knockback_struct_{m}.fixed({fixed_knockback})
            global variable knockback_struct_{m}.base({base_knockback})
            global variable knockback_struct_{m}.effect({effect})
            global variable knockback_struct_{m}.fgm({fgm_id})
        }
        // print message
        print "Added Surface Type: {name} - ID is 0x" ; OS.print_hex(new_surface_count + 0xF) ; print "\n"
    }
    
    // @ Description
    // Move/extend the original 6 knockback structs
    macro move_original_structs() {
        constant ORIGINAL_ARRAY(0xA4530)
        evaluate n(1)
        while {n} <= 6 {
            // copy original struct
            constant ORIGINAL_STRUCT_{n}(pc())
            OS.copy_segment(ORIGINAL_ARRAY + (({n} - 1) * 0x1C), 0x1C)
            // add fgm override parameter
            dw -1
            // increment
            evaluate n({n}+1)
        }
    }
    
    // @ Description
    // Add new knockback structs
    macro add_new_structs() {
        evaluate n(1)
        while {n} <= new_knockback_struct_count {
            // add struct
            constant NEW_STRUCT_{n}(pc())
            dw  knockback_struct_{n}.type
            dw  knockback_struct_{n}.damage
            dw  knockback_struct_{n}.angle
            dw  knockback_struct_{n}.growth
            dw  knockback_struct_{n}.fixed
            dw  knockback_struct_{n}.base
            dw  knockback_struct_{n}.effect
            dw  knockback_struct_{n}.fgm
            // increment
            evaluate n({n}+1)
        }
    }
    
    // @ Description
    // Writes new surfaces to the ROM
    macro write_surfaces() {
        // Move/extend original knockback structs
        move_original_structs()
        
        // Add zebes acid struct
        zebes_acid_struct:
        dw 0x00000000
        dw 0x00000010
        dw 0x00000050
        dw 0x00000082
        dw 0x00000000
        dw 0x0000001E
        dw 0x00000001
        dw 0xFFFFFFFF
        
        // Add new knockback structs
        add_new_structs()
    
        // Define a table containing knockback struct pointers for surfaces.
        knockback_table:
        // define original knockback structs
        dw ORIGINAL_STRUCT_1                // surface 0x7
        dw ORIGINAL_STRUCT_2                // surface 0x8
        dw ORIGINAL_STRUCT_3                // surface 0x9
        dw ORIGINAL_STRUCT_4                // surface 0xA
        dw ORIGINAL_STRUCT_5                // surface 0xB
        dw OS.NULL                          // surface 0xC
        dw OS.NULL                          // surface 0xD
        dw OS.NULL                          // surface 0xE
        dw ORIGINAL_STRUCT_6                // surface 0xF
        // add new knockback structs
        evaluate n(1)
        while {n} <= new_surface_count {
            // add struct pointer to table
            dw  {new_surface_{n}_struct}
            // increment
            evaluate n({n}+1)
        }
        
        // Define a table containing friction values for surfaces.
        friction_table:
        // copy original table
        OS.copy_segment(0xA7CE0, 0x40)
        // add new surfaces
        evaluate n(1)
        while {n} <= new_surface_count {
            // add friction value to table
            float32  {new_surface_{n}_friction}
            // increment
            evaluate n({n}+1)
        }
    }
    
    
    // ADD NEW SURFACES HERE
    
    print "============================== SURFACE TYPES ============================== \n"
    
    // name - surface name, used for display only
    // friction - friction value used by the surface, default = 4.0
    // bool_knockback - OS.FALSE = no knockback, OS.TRUE = apply knockback
    // knockback_type - not a well understood variable, usually determines FGM but has other uses
    // damage - parameter for knockback
    // knockback_angle - parameter for knockback
    // knockback_growth - parameter for knockback
    // fixed_knockback - parameter for knockback
    // base_knockback - parameter for knockback
    // effect - parameter for knockback
    // fgm - FGM id to use when applying knockback
    
    add_surface(big_blue_surface_1, 4.0, OS.TRUE, 8, 4, 105, 5, 0, 125, 1, -1)
    add_surface(cool_cool_surface_1, 0.3, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(failed_z_cancel, 4.0, OS.TRUE, 0x00010008, 7, 90, 0, 0, 0x20, 0, 0x0038) // unused bit as override flag
    add_surface(big_blue_surface_2, 4.0, OS.TRUE, 8, 4, 90, 5, 0, 130, 1, -1)
    add_surface(corneria_surface_1, 4.0, OS.TRUE, 8, 60, 190, 20, 0, 130, 2, 0x3C)
    add_surface(corneria_surface_2, 4.0, OS.TRUE, 8, 30, 180, 20, 0, 130, 2, 0x16)
    add_surface(mute, 4.0, OS.TRUE, 20, 15, 90, 100, 0, 65, 0, 0x1F)
    add_surface(casino_left_diagonal, 4.0, OS.TRUE, 20, 10, 315, 100, 0, 65, 0, 0x3D6)
    add_surface(casino_left_top, 4.0, OS.TRUE, 20, 10, 100, 100, 0, 65, 0, 0x3D6)
    add_surface(casino_left_side, 4.0, OS.TRUE, 20, 10, 0, 100, 0, 65, 0, 0x3D6)
    add_surface(casino_right_diagonal, 4.0, OS.TRUE, 20, 10, 225, 100, 0, 65, 0, 0x3D6)
    add_surface(casino_right_top, 4.0, OS.TRUE, 20, 10, 100, 80, 0, 65, 0, 0x3D6)
    add_surface(casino_right_side, 4.0, OS.TRUE, 20, 10, 180, 0, 0, 65, 0, 0x3D6)
    add_surface(toadsturnpike_car, 4.0, OS.TRUE, 8, 20, 90, 100, 200, 0, 0, 0x11F)
    add_surface(failed_z_cancel_lava, 4.0, OS.TRUE, 0x00010005, 0xA, 90, 0x64, 0xC8, 0, 1, 0x11E) // unused bit as override flag
    add_surface(push_right_2, 4.0, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(push_left_2, 4.0, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(push_right_1, 4.0, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(push_left_1, 4.0, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)
    add_surface(acid, 4.0, OS.FALSE, 0, 0, 0, 0, 0, 0, 0, 0)

    
    // write surfaces to ROM
    write_surfaces()
    
    print "========================================================================== \n"
    
    // ASM PATCHES
    
    // @ Description
    // Modifies the 3 known functions which load the friction of a surface to load from an
    // extended friction table.
    scope get_friction_: {
        constant UPPER(friction_table >> 16)
        constant LOWER(friction_table & 0xFFFF)
        
        // this patch modifies the general grounded physics function which is used to load/apply friction most of the time
        OS.patch_start(0x543DC, 0x800D8BDC)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        OS.patch_end()
        
        // this patch modifies a function which loads from the friction table after a character has
        // taken low knockback?
        OS.patch_start(0x5D9DC, 0x800E21DC)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        OS.patch_end()
        
        // this patch modifies a physics subroutine of kirby's down special which uses the friction
        // table
        OS.patch_start(0xDC2BC, 0x8016187C)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t1
        lwc1    f8, LOWER(at)
        OS.patch_end()  
    }
    
    // @ Description
    // Revised version of in-game function which is used for loading a knockback struct for a
    // surface. Originally, a jump table was used, but it is replaced by an extended struct table.
    scope get_struct_: {
        OS.patch_start(0x61474, 0x800E5C74)
        // t0 = surface id - 7
        bltzl   t0, _end                    // skip if surface id < 7
        or      v0, r0, r0                  // v0 = 0 (disable knockback)		
        sll     t0, t0, 0x2                 // t0 = offset ((surface id - 7) * 0x4)
        li      at, knockback_table         // at = knockback_table
        addu    at, at, t0                  // at = knockback_table + offset
        lw      t0, 0x000(at)               // t0 = knockback struct address
        beql    t0, r0, _end                // branch if knockback struct = NULL
        or      v0, r0, r0                  // v0 = 0 (disable knockback)
        
        _struct:
		lh      at, 0x0000(t0)              // at = remix cruel surface flag
		bnez    at, _enable                 // use this surface if it is cruel
		
        li      at, Global.current_screen   // at = pointer to current screen
        lbu     at, 0x0000(at)              // at = current screen_id
        lli     v0, 0x0016                  // v0 = vs screen_id
        beq     at, v0, _check_hazard_mode  // if vs, check hazard mode
        lli     v0, 0x0036                  // v0 = training screen_id
        beq     at, v0, _check_hazard_mode  // if training, check hazard mode
        nop
        b       _enable                     // everywhere else, don't obey toggle
        nop

        _check_hazard_mode:
        li      at, Toggles.entry_hazard_mode
        lw      at, 0x0004(at)              // at = hazard_mode (hazards disabled when at = 1 or 3)
        andi    at, at, 0x0001              // at = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnezl   at, _end                    // branch if hazards are disabled
        or      v0, r0, r0                  // v0 = 0 (disable knockback)

        _enable:
        sw      t0, 0x0000(a1)              // store knockback struct
        ori     v0, r0, 0x0001              // v0 = 1 (enable knockback)
        
        _end:
        jr      ra                          // return
        nop
        
        fill 0x800E5D10 - pc()              // nop the rest of the original function
        OS.patch_end()
    }
    
    // @ Description
    // Patch which checks for a custom FGM id for surface knockback and redirects to a new routine
    // if an FGM id is present.
    scope fgm_override_: {
        OS.patch_start(0x5F538, 0x800E3D38)
        j       fgm_override_
        nop
        _return:
        OS.patch_end()
        
        lw      v1, 0x0034(sp)              // v1 = knockback struct
        lw      at, 0x001C(v1)              // at = FGM id
        bltz    at, _original               // branch if FGM id < 0
        nop
        
        _override:
        // TODO: figure out what this timer/variable is being used for..
        // My theory is that this timer disables knockback from the surface until it resets to 0.
        // If that is the case, it may be worth allowing a custom value to be set.
        ori     t8, r0, 0x0010              // ~
        sw      t8, 0x0170(a3)              // unknown timer (0x170 in player struct) = 0x10       
        jal     0x800269C0                  // play FGM
        or      a0, at, r0                  // move FGM id to a0
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // end subroutine using original logic
        nop
        
        _original:
        lw      v1, 0x0038(sp)              // original line 1
        sltiu   at, v1, 0x000A              // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Redirects the Zebes acid struct to a hard coded location where the struct has been extended.
    scope zebes_acid_fix_: {
        OS.patch_start(0x83A08, 0x80108208)
        li      t7, zebes_acid_struct       // t7 = zebes_acid_struct
        OS.patch_end()
    }
    
    conveyor_speed:
    dw  0x41A40000  // RTTF Remix, +20.5 units
    dw  0xC1C00000  // RTTF Remix, -24 units
    dw  0x41400000  // unused, placeholder +12 units
    dw  0xC1400000  // unused, placeholder -12 units

    scope fighter_apply_conveyor_surface: {
        OS.patch_start(0x5DBD8, 0x800E23D8)
        j       fighter_apply_conveyor_surface
        lw      t0, 0x014C(s1)              // t0 = kinetic state
        _fighter_apply_conveyor_surface_return:
        OS.patch_end()

        bnez    t0, _apply_push             // skip conveyor surface logic if aerial
        lb      t0, 0x00F7(s1)              // get clipping flag
        beqz    t0, _apply_push             // skip conveyor belt check if not on a hazardous surface
        nop

        // if grounded
        li      t1, conveyor_speed
        addiu   at, r0, 0x1F                // right moving clipping id
        beql    t0, at, _apply_conveyor_movement
        lw      t0, 0x0000(t1)              // load right moving speed
        addiu   at, r0, 0x20                // left moving clipping id (fast)
        beql     t0, at, _apply_conveyor_movement // skip conveyor if not a conveyor surface
        lw      t0, 0x0004(t1)              // load left moving speed
        addiu   at, r0, 0x21                // right moving clipping id (fast)
        beql    t0, at, _apply_conveyor_movement
        lw      t0, 0x0008(t1)              // load right moving speed
        addiu   at, r0, 0x22                // left moving clipping id (slow)
        beql     t0, at, _apply_conveyor_movement         // skip conveyor if not a conveyor surface
        lw      t0, 0x000C(t1)              // load left moving speed (slow)

        b       _apply_push
        nop

        _apply_conveyor_movement:
        sw      t0, 0x00A4(s1)

        _apply_push:
        jalr    ra, v0
        lw      a0, 0x0070(sp)
        j       _fighter_apply_conveyor_surface_return
        nop

    }
    
    scope item_apply_conveyor_surface: {
        OS.patch_start(0xEA324, 0x8016F8E4)
        j       item_apply_conveyor_surface
        lw      t0, 0x0108(a2)              // t0 = kinetic state
        _item_apply_conveyor_surface_return:
        OS.patch_end()
           
        bnez    t0, _continue               // skip conveyor surface logic if aerial
        nop
        // if grounded
        li      t0, Global.match_info       // ~ 0x800A50E8
        lw      t0, 0x0000(t0)              // t0 = match_info
        lbu     t0, 0x0001(t0)              // t0 = stage id
        addiu   at, r0, Stages.id.SAFFRON_CITY // at = SAFFRON CITY stage id
        beq     at, t0, _continue           // skip if the stage is saffron city ()
        nop
        jal     get_clipping_flag_
        lw      a0, 0x00AC(a2)              // get clipping id
        or      a0, s0, r0                  // restore a0
        sll     v0, v0, 24
        srl     v0, v0, 24
        beqzl   v0, _continue               // skip conveyor belt check if not on a hazardous surface
        lw      v0, 0x037C(a2)              // restore v0

        li      t1, conveyor_speed
        addiu   at, r0, 0x1F                // right moving clipping id
        beql    v0, at, _apply_conveyor_movement
        lw      t0, 0x0000(t1)              // load right moving speed
        addiu   at, r0, 0x20                // left moving clipping id
        beql    v0, at, _apply_conveyor_movement
        lw      t0, 0x0004(t1)              // load left moving speed
        addiu   at, r0, 0x21                // right moving clipping id (fast)
        beql    t0, at, _apply_conveyor_movement
        lw      t0, 0x0008(t1)              // load right moving speed
        addiu   at, r0, 0x22                // left moving clipping id (slow)
        beql    t0, at, _apply_conveyor_movement         // skip conveyor if not a conveyor surface
        lw      t0, 0x000C(t1)              // load left moving speed (slow)

        b       _continue           // skip conveyor if not a conveyor surface
        lw      v0, 0x037C(a2)              // restore v0

        _apply_conveyor_movement:
        sw      t0, 0x0064(a2)
        lw      v0, 0x037C(a2)              // restore v0

        _continue:
        jalr    ra, v0
        sh      t4, 0x008C(a2)
        j       _item_apply_conveyor_surface_return
        nop

    }

    // Collision Masks
    constant CEILING(0x0400)
    constant GROUND(0x0800)
    constant WALL(0x0021)
    constant WALL_RIGHT(0x0001)
    constant WALL_LEFT(0x0020)
    constant CLIFF(0x3000)
    constant CLIFF_RIGHT(0x1000)
    constant CLIFF_LEFT(0x2000)
	
	// @ Description
	// Returns flag of clipping.
	// A0 = clipping ID
	scope get_clipping_flag_: {
		// first, get offset to flag
		lui		at, 0x8013
		lw		t7, 0x1378(at)				// t7 = clipping struct 0
		sll		t3, a0, 2
		addu	a1, t7, t3
		lhu		v0, 0x0000(a1)
		sll		a0, v0, 1					// a0 = offset
		
		// then we get the clipping id
		lw		t1, 0x1374(at)				// t1 = clipping struct 1
		lw		t8, 0x1370(at)				// t8 = clipping struct 2
		addu	t2, t1, a0					// t2 = struct + offset
		lhu		t7, 0x0000(t2)				// t7 = another offset

		sll		at, t7, 3
		sll		t3, t7, 1
		subu	t3, at, t3
		addu	t4, t8, t3					// t4 = t8 + t3

		jr      ra                          // return
		lhu		v0, 0x0004(t4)				// v0 = clipping flag
	}

}
}
