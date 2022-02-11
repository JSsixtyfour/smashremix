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
        table:
        constant table_origin(origin())
        dw NORMAL                           // 0x0 - normal
        dw FIRE                             // 0x1 - fire
        dw ELECTRIC                         // 0x2 - electric
        dw NORMAL                           // 0x3 - slash
        dw NORMAL                           // 0x4 - coin
        dw ICE                              // 0x5 - ice (mostly unfinished/removed)
        dw NORMAL                           // 0x6 - sleep
        while pc() < (table + 0x40) {
            dw NORMAL                       // 0x7-0xF - normal by default
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
        lw      t9, 0x0044(v0)              // t8 = facing direction
        bne     at, t9, _branch             // skip/take original branch if hit direction != facing direction
        nop
        // if hit direction = facing direction
        jal     stun_initial_modified_      // initial subroutine for Stun action
        nop
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
        lli     at, Damage.id.STUN          // at = id.STUN
        bne     t0, at, _branch             // skip if damage type != STUN (modified original line 1)
        nop

        _electric:
        // if damage type = ELECTRIC or STUN
        j       _return                     // return
        nop

        _branch:
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