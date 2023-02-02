// GFXRoutine.asm
if !{defined __GFXROUTINE__} {
define __GFXROUTINE__()
print "included GFXRoutine.asm\n"

// This file adds support for additional gfx routines.  These are called by function 0x800E974C (wrapped version for players is 0x800E9814)
// They can also be called with the moveset command BXXXYYYY, XXX = gfx routine index, YYYY = duration

scope GFXRoutine {
    variable new_gfx_routine_count(0)       // number of new gfx routines

    // COMMANDS
    // 0400XXXX - synchronous timer, wait X frames)
    // 08000000 XXXXXXXX - goto, jump to address X
    // 0C00XXXX - begin loop, X iterations
    // 10000000 - close loop
    // 14000000 XXXXXXXX - begin subroutine, jump to address X and set return address
    // 18000000 - end subroutine, jump to return address
    // 20000000 - clear overlay colour
    // 24000000 RRGGBBAA - overlay RGBA8888 colour onto character
    // 2800XXXX RRGGBBAA - shift to RGBA8888 colour over X frames, has weird effects if colour is not set by something else after timer runs out
    // 30000000 - unknown
    // 34AABB00 XXXXYYYY ZZZZXXXX YYYYZZZZ create GFX, works like the moveset command (AA = bone, BB = id, first XYZ = offset, second XYZ = random range)
    // 38000000 - unknown, seems like maybe copy of create GFX?
    // 3CXXYYZZ - use custom light, offset light position by XX/YY/ZZ (s16)
    // 40000000 - unknown, usually at the end of non-looping routines? maybe clears light?

    // @ Description
    // adds an END command
    macro END() {
        dw 0x00000000                       // command
    }

    // @ Description
    // adds a WAIT command
    macro WAIT(frames) {
        dw 0x04000000 + {frames}            // command
    }
    // @ Description
    // adds a GO_TO command
    macro GO_TO(address) {
        dw 0x08000000                       // command
        dw {address}                        // pointer
    }
    // @ Description
    // adds a BEGIN_LOOP command
    macro BEGIN_LOOP(count) {
        dw 0x0C000000 + {count}             // command
    }
    // @ Description
    // adds a END_LOOP command
    macro END_LOOP() {
        dw 0x10000000                       // command
    }
    // @ Description
    // adds a SUBROUTINE command
    macro SUBROUTINE(address) {
        dw 0x14000000                       // command
        dw {address}                        // pointer
    }
    // @ Description
    // adds a RETURN command
    macro RETURN() {
        dw 0x18000000                       // command
    }
    // @ Description
    // adds a CLEAR_OVERLAY command
    macro CLEAR_OVERLAY() {
        dw 0x20000000                       // command
    }
    // @ Description
    // adds an OVERLAY command
    macro OVERLAY(rgba) {
        dw 0x24000000                       // command
        dw {rgba}                           // RGBA32
    }
    // @ Description
    // adds an OVERLAY command
    macro OVERLAY_SHIFT(rgba, frames) {
        dw 0x28000000 + {frames}            // command
        dw {rgba}                           // RGBA32
    }
    // @ Description
    // adds a CREATE_GFX command
    macro CREATE_GFX(bone, id, x1, y1, z1, x2, y2, z2) {
        dw 0x34000000 | (({bone} & 0xFF) << 19) | (({id} & 0xFF) << 10)  // command
        dh {x1}; dh {y1}; dh {z1}           // X/Y/Z (offset)
        dh {x2}; dh {y2}; dh {z2}           // X/Y/Z (range)
    }
    // @ Description
    macro SET_LIGHT(x,y,z) {
        dw 0x3C000000 | (({x} & 0xFF) << 16) | (({y} & 0xFF) << 8) | ({z} & 0xFF) // command
    }


    // @ Description
    // Adds a gfx routine from a binary file.
    // name - gfx routine name, id.{name} will be created
    // filename - file containing commands
    // priority - the priority this routine has relative to others, higher/equal priority will override an active routine
    // bool_action - TRUE = end routine when changing actions, FALSE = continue routine when changing actions
    macro add_gfx_routine_file(name, filename, priority, bool_action) {
        global variable new_gfx_routine_count(new_gfx_routine_count + 1)
        evaluate n(new_gfx_routine_count)
        // define gfx routine parameters
        global define gfx_routine_{n}_name({name})
        constant id.{name}(new_gfx_routine_count + 0x55)
        global define gfx_routine_{n}_filename({filename})
        global define gfx_routine_{n}_priority({priority})
        global define gfx_routine_{n}_bool_action({bool_action})
        // print message
        print "Added GFX Routine: {name} - Moveset command is 0x" ; OS.print_hex(0xB000 + (id.{name} << 2)) ;; print "0000, ID is 0x" ; OS.print_hex(id.{name}) ; print "\n"
    }

    // @ Description
    // Adds a gfx routine with a given address.
    // name - gfx routine name, id.{name} will be created
    // address - pointer to commands
    // priority - the priority this routine has relative to others, higher/equal priority will override an active routine
    // bool_action - TRUE = end routine when changing actions, FALSE = continue routine when changing actions
    macro add_gfx_routine(name, address, priority, bool_action) {
        global variable new_gfx_routine_count(new_gfx_routine_count + 1)
        evaluate n(new_gfx_routine_count)
        // define gfx routine parameters
        global define gfx_routine_{n}_name({name})
        constant id.{name}(new_gfx_routine_count + 0x55)
        global define gfx_routine_{n}_address({address})
        global define gfx_routine_{n}_priority({priority})
        global define gfx_routine_{n}_bool_action({bool_action})
        // print message
        print "Added GFX Routine: {name} - Moveset command is 0x" ; OS.print_hex(0xB000 | (id.{name} << 2)) ;; print "0000, ID is 0x" ; OS.print_hex(id.{name}) ; print "\n"
    }

    // @ Description
    // Writes gfx routines to the ROM, creates and populates gfx_routine_table_extended
    macro write_gfx_routines() {
        // add files
        evaluate n(1)
        while {n} <= new_gfx_routine_count {
            if {defined gfx_routine_{n}_filename} {
                // add file if one is given
                OS.align(4)
                gfx_routine_{n}:
                insert "{gfx_routine_{n}_filename}"
            }
            // increment
            evaluate n({n}+1)
        }

        // Define a table containing new gfx routine effects
        OS.align(16)
        gfx_routine_table_extended:                      // 0x01
        // add new gfx routines
        evaluate n(1)
        while {n} <= new_gfx_routine_count {
            // add struct pointer to table
            if {defined gfx_routine_{n}_filename} {
                // use file pointer if one was given
                dw gfx_routine_{n}
            } else {
                // use given address
                dw {gfx_routine_{n}_address}
            }
            db {gfx_routine_{n}_priority}; db {gfx_routine_{n}_bool_action}; dh 0x0000
            // increment
            evaluate n({n}+1)
        }
    }

    // ADD NEW GFX ROUTINES HERE

    print "============================= GFX ROUTINES =============================== \n"

    insert MEWTWO_NAIR, "gfx/routines/MEWTWO_NAIR.bin"; GO_TO(MEWTWO_NAIR) // loops
    insert MEWTWO_FLAME_HAND, "gfx/routines/MEWTWO_FLAME_HAND.bin"; GO_TO(MEWTWO_FLAME_HAND) // loops
    insert MEWTWO_CHARGE, "gfx/routines/MEWTWO_CHARGE.bin"; GO_TO(MEWTWO_CHARGE) // loops
    insert KIRBY_MTWO_CHARGE, "gfx/routines/KIRBY_MTWO_CHARGE.bin"; GO_TO(KIRBY_MTWO_CHARGE) // loops
    SHADOW_SUBROUTINE:; CREATE_GFX(-1, 0x6D, 0, 0, 0, 0, 0, 0); OVERLAY(0xD078FFAA); WAIT(1); OVERLAY(0x7E1E8C96); WAIT(1); RETURN()
    SMOKE_SUBROUTINE:; CREATE_GFX(-1, 0x7, 0, 0, 0, 0, 0, 0); BEGIN_LOOP(2); OVERLAY(0x7400A464); WAIT(1); OVERLAY(0x300030D2); WAIT(1); END_LOOP(); RETURN()
    SHADOW_1:; BEGIN_LOOP(4); SUBROUTINE(SHADOW_SUBROUTINE); END_LOOP(); BEGIN_LOOP(4); SUBROUTINE(SMOKE_SUBROUTINE); END_LOOP(); END()
    SHADOW_2:; BEGIN_LOOP(8); SUBROUTINE(SHADOW_SUBROUTINE); END_LOOP(); BEGIN_LOOP(8); SUBROUTINE(SMOKE_SUBROUTINE); END_LOOP(); END()
    SHADOW_3:; BEGIN_LOOP(16); SUBROUTINE(SHADOW_SUBROUTINE); END_LOOP(); BEGIN_LOOP(16); SUBROUTINE(SMOKE_SUBROUTINE); END_LOOP(); END()
    SHADOW_4:; BEGIN_LOOP(24); SUBROUTINE(SHADOW_SUBROUTINE); END_LOOP(); BEGIN_LOOP(20); SUBROUTINE(SMOKE_SUBROUTINE); END_LOOP(); END()
    MARTH_RED_FLASH:;   OVERLAY(0xFF000080); WAIT(2); OVERLAY_SHIFT(0xFF000000, 16); WAIT(16); CLEAR_OVERLAY(); END()
    MARTH_BLUE_FLASH:;  OVERLAY(0x0000FF80); WAIT(2); OVERLAY_SHIFT(0x0000FF00, 16); WAIT(16); CLEAR_OVERLAY(); END()
    MARTH_GREEN_FLASH:; OVERLAY(0x00FF0080); WAIT(2); OVERLAY_SHIFT(0x00FF0000, 16); WAIT(16); CLEAR_OVERLAY(); END()
    MARTH_GREEN_FLASH_FAST:; OVERLAY(0x00FF0060); WAIT(2); OVERLAY_SHIFT(0x00FF0000, 8); WAIT(8); CLEAR_OVERLAY(); END()
    MARTH_COUNTER_FLASH:; OVERLAY(0xFFFFFFC0); WAIT(1); BEGIN_LOOP(4); OVERLAY(0xFFFFFF50); WAIT(2); OVERLAY(0xC030FF50); WAIT(2); CLEAR_OVERLAY(); WAIT(2); END_LOOP(); END()
    PHANTASM_BLUE:; OVERLAY(0x00F0FFE0); WAIT(4); END()
    FLASH_PINK:; OVERLAY(0xFF80DFE0); WAIT(5); END()
    MARTH_ENTRY:; OVERLAY(0xFFFFFFFF); WAIT(4); OVERLAY_SHIFT(0xFFE8A0FF, 10); WAIT(10); OVERLAY_SHIFT(0xFFE8A000, 60); WAIT(60); CLEAR_OVERLAY(); END()
    STAMINA_KO:;   OVERLAY(0xFF000080); WAIT(2); OVERLAY_SHIFT(0xFF000000, 16); WAIT(16); CLEAR_OVERLAY(); GO_TO(STAMINA_KO)
    SONIC_NSP_CHARGE:;  OVERLAY(0x00A0FF0A); OVERLAY_SHIFT(0x80C0FFA0, 22); WAIT(22); BEGIN_LOOP(8); OVERLAY(0x80C0FF80); WAIT(2); OVERLAY(0xF0FFFFD0); WAIT(2); END_LOOP(); END()
    SONIC_NSP_ATTACK:;  OVERLAY(0xF0FFFFD0); OVERLAY_SHIFT(0x40A0FF00, 18); WAIT(18); CLEAR_OVERLAY(); END()
    SSONIC_NSP_CHARGE:;  OVERLAY(0xfff9000A); OVERLAY_SHIFT(0xf5ff62A0, 22); WAIT(22); BEGIN_LOOP(8); OVERLAY(0xf5ff6280); WAIT(2); OVERLAY(0xfaf8abD0); WAIT(2); END_LOOP(); END()
    SSONIC_NSP_ATTACK:;  OVERLAY(0xfaf8abD0); OVERLAY_SHIFT(0xfaff0000, 18); WAIT(18); CLEAR_OVERLAY(); END()
    LASER:;  BEGIN_LOOP(4); OVERLAY(0xFF0000A0); WAIT(2); OVERLAY(0x0000FFA0); WAIT(2); END_LOOP(); BEGIN_LOOP(4); OVERLAY(0xFF000060); WAIT(2); OVERLAY(0x0000FF60); WAIT(2); END_LOOP(); BEGIN_LOOP(4); OVERLAY(0xFF000030); WAIT(2); OVERLAY(0x0000FF30); WAIT(2); END_LOOP(); CLEAR_OVERLAY(); END()
    DEKU_STUN:; OVERLAY(0x0000FF8E);  WAIT(1); GO_TO(DEKU_STUN); END()
    insert SHEIK_CHARGE, "gfx/routines/SHEIK_CHARGE.bin"; GO_TO(SHEIK_CHARGE)
    SHEIK_DSP:; OVERLAY(0xdb03fc80); WAIT(2); OVERLAY_SHIFT(0xdb03fc00, 16); WAIT(16); CLEAR_OVERLAY(); END()
    SHEIK_SHOOT:; OVERLAY(0xFFFFFF49); WAIT(0x1); CLEAR_OVERLAY(); WAIT(0x2); END();
    insert FRANKLIN_BADGE, "gfx/routines/FRANKLIN_BADGE.bin"; GO_TO(FRANKLIN_BADGE)
    SHEIK_USP_END:; OVERLAY(0xDE240A80); WAIT(1); CLEAR_OVERLAY(); WAIT(1); OVERLAY(0xDE240A80); WAIT(1); CLEAR_OVERLAY(); WAIT(1); OVERLAY(0xDE240A80); WAIT(1); CLEAR_OVERLAY(); END();
    insert MARINA_CHARGE, "gfx/routines/MARINA_CHARGE.bin"; GO_TO(MARINA_CHARGE)

    // name - gfx routine effect name, used for display only
    // filename - file containing gfx routine commands
    // priority - the priority this routine has relative to others, higher/equal priority will override an active routine
    // priority values used in vanilla are 1, 10, 11, 12 15, 30, 60, 100
    // bool_action - TRUE = end routine when changing actions, FALSE = continue routine when changing actions
    // Generally 60 is used for character/moveset gfx routines, 100 is used for damage related effects, and other lower values are used for less common specific scenarios
    // In order to maintain these conventions, we should generally be using 60 for new character gfx routines, or 100 for effects that are important enough that they should always appear

    add_gfx_routine(MEWTWO_NAIR, MEWTWO_NAIR, 100, OS.TRUE)
    add_gfx_routine(MEWTWO_FLAME_HAND, MEWTWO_FLAME_HAND, 100, OS.TRUE)
    add_gfx_routine(MEWTWO_CHARGE, MEWTWO_CHARGE, 10, OS.FALSE)
    add_gfx_routine(SHADOW_1, SHADOW_1, 100, OS.FALSE)
    add_gfx_routine(SHADOW_2, SHADOW_2, 100, OS.FALSE)
    add_gfx_routine(SHADOW_3, SHADOW_3, 100, OS.FALSE)
    add_gfx_routine(SHADOW_4, SHADOW_4, 100, OS.FALSE)
    add_gfx_routine(MARTH_RED_FLASH, MARTH_RED_FLASH, 60, OS.TRUE)
    add_gfx_routine(MARTH_BLUE_FLASH, MARTH_BLUE_FLASH, 60, OS.TRUE)
    add_gfx_routine(MARTH_GREEN_FLASH, MARTH_GREEN_FLASH, 60, OS.TRUE)
    add_gfx_routine(MARTH_GREEN_FLASH_FAST, MARTH_GREEN_FLASH_FAST, 60, OS.TRUE)
    add_gfx_routine(MARTH_COUNTER_FLASH, MARTH_COUNTER_FLASH, 60, OS.TRUE)
    add_gfx_routine(PHANTASM_BLUE, PHANTASM_BLUE, 100, OS.TRUE)
    add_gfx_routine(FLASH_PINK, FLASH_PINK, 100, OS.TRUE)
    add_gfx_routine(KIRBY_MTWO_CHARGE, KIRBY_MTWO_CHARGE, 10, OS.FALSE)
    add_gfx_routine(MARTH_ENTRY, MARTH_ENTRY, 60, OS.TRUE)
    add_gfx_routine(STAMINA_KO, STAMINA_KO, 101, OS.FALSE)
    add_gfx_routine(SONIC_NSP_CHARGE, SONIC_NSP_CHARGE, 60, OS.TRUE)
    add_gfx_routine(SONIC_NSP_ATTACK, SONIC_NSP_ATTACK, 60, OS.TRUE)
    add_gfx_routine(SSONIC_NSP_CHARGE, SSONIC_NSP_CHARGE, 60, OS.TRUE)
    add_gfx_routine(SSONIC_NSP_ATTACK, SSONIC_NSP_ATTACK, 60, OS.TRUE)
    add_gfx_routine(LASER, LASER, 100, OS.FALSE)
    add_gfx_routine(DEKU_STUN, DEKU_STUN, 100, OS.TRUE)
    add_gfx_routine(SHEIK_CHARGE, SHEIK_CHARGE, 10, OS.FALSE)
    add_gfx_routine(SHEIK_DSP, SHEIK_DSP, 60, OS.TRUE)
    add_gfx_routine(SHEIK_SHOOT, SHEIK_SHOOT, 60, OS.TRUE)
    add_gfx_routine(FRANKLIN_BADGE, FRANKLIN_BADGE, 100, OS.FALSE)
    add_gfx_routine(SHEIK_USP_END, SHEIK_USP_END, 60, OS.FALSE)
    add_gfx_routine(MARINA_CHARGE, MARINA_CHARGE, 10, OS.FALSE)

    // write gfx routines to ROM
    write_gfx_routines()

    print "========================================================================== \n"

    // ASM PATCHES

    // @ Description
    // Modifies the original routine (0x800E974C) to use the extended gfx routine table when a new id is used.
    scope extend_gfx_routine_table_: {
        OS.patch_start(0x64F60, 0x800E9760)
        j       extend_gfx_routine_table_
        nop
        _return:
        OS.patch_end()

        // v1 = original table
        // a1 = new gfx routine id
        // t8 = current gfx routine id
        li      t7, gfx_routine_table_extended // t7 = gfx_routine_table_extended
        addiu   t7, t7,-0x02B0              // decrement base table address by the size of the original table (this means the first new id maps to the first extended table entry)

        sltiu   at, t8, 0x0056              // at = 1 if current gfx routine id is original, 0 otherwise
        bnez    at, _continue               // branch if current id is original...
        addu    t0, v1, t9                  // ...and add offset to original table (original line 1)

        addu    t0, t7, t9                  // if the id is new, add use the extended table instead

        _continue:
        sltiu   at, a1, 0x0056              // at = 1 if new gfx routine id is original, 0 otherwise
        bnez    at, _end                    // branch if current id is original...
        addu    v0, v1, t6                  // ...and add offset to original table (original line 2)

        addu    v0, t7, t6                  // if the id is new, add use the extended table instead

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Patch which adds the extended routine table to the check which occurs on action changes.
    scope action_change_fix_: {
        OS.patch_start(0x62898, 0x800E7098)
        j       action_change_fix_
        nop
        nop
        nop
        _return:
        OS.patch_end()

        // t7 = current gfx routine id
        li      t9, 0x8012DBD0              // t9 = original table address
        sltiu   at, t7, 0x0056              // at = 1 if new gfx routine id is original, 0 otherwise
        bnez    at, _end                    // branch if current id is original
        sll     t8, t7, 0x0003              // t8 = offset (id * 8)

        // if id is new
        li      t9, gfx_routine_table_extended // t9 = gfx_routine_table_extended
        addiu   t9, t9,-0x02B0              // decrement base table address by the size of the original table (this means the first new id maps to the first extended table entry)

        _end:
        addu    t9, t9, t8                  // t9 = table + offset
        j       _return                     // return
        lbu     t9, 0x0005(t9)              // t9 = bool_action
    }

    // @ Description
    // This allows us to set the players gfx routine similar to how super star item overrides it.
    scope port_override: {

        // @ Description
        // This allows us to set the players gfx routine similar to how super star item overrides it.
        override_table:
        dw 0, 0, 0, 0

        // @ Description
        // Patch which extends the check for a characters gfx routine which occurs when a players gfx routine ends
        scope extend_gfx_check_: {
            OS.patch_start(0x652E4, 0x800E9AE4)
            j       extend_gfx_check_
            lw      a3, 0x001C(sp)          // a3 = player struct
            _return:
            OS.patch_end()

            define _table(override_table)
            OS.lui_table({_table}, at)      // v0 = first half of table address
            lbu     t1, 0x000D(a3)          // t1 = port
            sll     t1, t1, 0x0002          // t1 = offset to player entry
            addu    at, at, t1              // at = offset of player
            OS.table_read_word({_table}, at, a1) // v0 = players entry in table
            beqz    a1, _end                // end if no override value
            nop

            // if here, there is an override value.
            // a1 = gfx routine id
            lw      a0, 0x0020(sp)          // a0 must be player object
            jal     0x800E9814              // get routine from table
            or      a2, r0, r0              // arg_2 = noone
            lw      a0, 0x0020(sp)          // ~

            jal     0x800F37CC              // apply routine to player
            lw      a0, 0x0020(sp)          // arg_0 = player object

            _end:
            lw      ra, 0x0014(sp)          // original line 1
            j       _return
            addiu   sp, sp, 0x20            // original line 2
        }

        // @ Description
        // Clean up gfx routine overrides for all ports
        // Called when loading CSS, VS, Training and VS Results
        scope clear_gfx_override_table_: {
            addiu   sp, sp, -0x0030         // allocate stack space
            sw      ra, 0x0004(sp)          // ~

            li      t8, override_table      // t8 = array to clear
            sw      r0, 0x0000(t8)          // clear ptrs
            sw      r0, 0x0004(t8)          // ~
            sw      r0, 0x0008(t8)          // ~
            sw      r0, 0x000C(t8)          // ~

            lw      ra, 0x0004(sp)          // restore ra
            jr      ra
            addiu   sp, sp, 0x0030          // deallocate stack space
        }
    }
}
}