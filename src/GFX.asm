// GFX.asm
if !{defined __GFX__} {
define __GFX__()
print "included GFX.asm\n"

// @ Description
// This file allows new GFX (graphics effects) to be created.

include "OS.asm"

scope GFX {
    variable new_gfx_count(0)                            // Number of new graphics effects added

    // @ Description
    // Modifies the routine that maps GFX IDs in moveset commands to GFX routines so that we can use an extended table
    scope extend_gfx_command_jump_table_: {
        OS.patch_start(0x666A4, 0x800EAEA4)
        j       extend_gfx_command_jump_table_
        nop
        OS.patch_end()

        slti    at, t8, 0x005C                           // check if ID is less than 0x5C, which means it's an original GFX ID
        beqz    at, _new_gfx_id                          // if it is a new GFX ID, then branch
        nop                                              // else return to original routine:
        sll     t8, t8, 0x2                              // original line 1
        lui     at, 0x8013                               // original line 2
        j       0x800EAEAC                               // return to original routine
        nop

        _new_gfx_id:
        li      at, extended_gfx_command_jump_table      // at = address of extended table
        addiu   t8, t8, -0x005C                          // t8 = slot in extended table
        sll     t8, t8, 0x2                              // t8 = offset in extended table
        addu    at, at, t8                               // at = address of address of GFX routine
        lw      t8, 0x0000(at)                           // t8 = address of GFX routine
        jr      t8                                       // jump to GFX routine
        nop                                              // ~
    }

    // @ Description
    // Modifies the routine that maps GFX Instruction IDs to GFX instructions so that we can use an extended table
    scope extend_gfx_instructions_map_: {
        OS.patch_start(0x4A0D0, 0x800CE6F0)
        j       extend_gfx_instructions_map_
        nop
        OS.patch_end()

        addu    t8, t8, v1                               // original line 1
        slti    at, t6, 0x0077                           // check if ID is less than 0x77, which means it's an original GFX_INSTRUCTIONS_ID
        beqz    at, _new_gfx_instructions_id             // if it is a new GFX_INSTRUCTIONS_ID, then branch
        nop                                              // else return to original routine:
        addiu   at, r0, 0x0001                           // set at to 1
        j       0x800CE6F8                               // return to original routine
        nop

        _new_gfx_instructions_id:
        li      at, extended_gfx_instructions_map        // at = address of extended table
        addiu   t6, t6, -0x0077                          // t6 = slot in extended table
        sll     t6, t6, 0x2                              // t6 = offset in extended table
        addu    at, at, t6                               // at = address of address of GFX instructions
        lw      v0, 0x0000(at)                           // v0 = address of GFX instructions
        j       0x800CE71C                               // return after v0 is originally set
        nop

        _normal:
        addiu   at, r0, 0x0001                           // set at to 1 always (maybe shouldn't do this)
        j       0x800CE6F8                               // return
        nop                                              // ~
    }

    // @ Description
    // This routine is a copy of the first part of the explosion gfx instructions loader modified to accept
    // the gfx_instructions_id as an argument. Then we piggyback off of the rest of the explosion code.
    scope gfx_instructions_loader_: {
        // a3 = gfx_instructions_id to load

        // The next several lines are the first commands from the explosion gfx instructions loader (73)
        addiu   sp, sp, 0xFFD8                           // original line 1
        sw      a0, 0x0028(sp)                           // original line 2
        lui     a0, 0x8013                               // original line 3
        lw      a0, 0x13C4(a0)                           // original line 4
        sw      ra, 0x001C(sp)                           // original line 5
        sw      s0, 0x0018(sp)                           // original line 6

        addu    a1, r0, a3                               // this is usually hard-coded, but we are reusing this block thus use a3

        // Now let's go back to the original line that explosion uses
        // This may need to change in the future if any of the stuff at this address isn't relevant for a new gfx
        j       0x8010049C
        nop

    }

    // @ Description
    // Adds a new GFX
    // name - Used for display only
    macro add_gfx(name) {
        global variable new_gfx_count(new_gfx_count + 1) // increment new_gfx_count
        evaluate n(new_gfx_count)
        print " - Added GFX_ID 0x"; OS.print_hex(0x5B + new_gfx_count); print " (Command ID "; OS.print_hex((0x5B + new_gfx_count) * 4); print "): {name}\n"

        gfx_assembly_{n}:
        lli     a3, 0x76 + {n}                           // this creates a new unique GFX_INSTRUCTION_ID
        jal     gfx_instructions_loader_                 // send new GFX_INSTRUCTION_ID to our standard instructions block
        // The next several lines are commands from the jump address for the explosion gfx (0x800EB17C - 0x800EB184)
        or      a0, s0, r0                               // original line 1
        j       0x800EB388                               // modified from branch to jump
        or      v1, v0, r0                               // original line 3

        gfx_instructions_{n}:
        // TODO: load this from a file?
        dw      0x0000002D // texture id... TODO: allow for additional textures
        dw      0x00010022 // second halfword is number of frames
        dw      0x00000000 // setting to FFFFFFFF makes the gfx stay on screen forever
                           // setting to 11111111 makes it disintegrate and fall to the ground
		                   // setting to 22222222 squishes horizontally and duplicates to the left
		                   // last digit is falling/disintegrating, can be 0-3
		                   // 2nd to last digit mirrors gfx on various axes
		                   // 3rd to last digit pixelizes gfx and makes it stay on the screen forever when 8 or higher
        dw      0x3F800000
        dw      0x3F800000
        dw      0x00000000
        dw      0x00000000
        dw      0x00000000
        dw      0x00000000
        dw      0x00000000
        dw      0xBF800000
        dw      0x43700000
        dw      0xA0004316
        dw      0x0000A01A // last byte controls size
        dw      0x43AF0000 // 2nd byte controls size
        dw      0xC700FFFF // last halfword controls color
        dw      0xFF430043 // this looks like frame data
        dw      0x01430243 // this looks like frame data
        dw      0x04eF04eF // this looks like frame data
        dw      0x05440644 // this looks like frame data
        dw      0x074208A0 // this looks like frame data
        dw      0x1B434800 // this looks like frame data
        dw      0x00FF0000
    }

    // @ Description
    // Finalizes adding new GFX
    macro write_gfx() {
        extended_gfx_command_jump_table:
        define n(1)
        while {n} <= new_gfx_count {
            dw       gfx_assembly_{n}
            evaluate n({n}+1)
        }

        extended_gfx_instructions_map:
        define n(1)
        while {n} <= new_gfx_count {
            dw       gfx_instructions_{n}
            evaluate n({n}+1)
        }

        // Increase the size of the GFX command jump table size check
        pushvar base, origin
        origin  0x6669B
        db      0x5C + new_gfx_count
        pullvar origin, base
    }

    // ADD NEW GFX HERE
    add_gfx(Explosion Duplicate)

    write_gfx()                                          // writes new GFX to ROM

}

} // __GFX__
