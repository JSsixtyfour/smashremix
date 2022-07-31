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
        constant DESTROY(0x01)              // destroys the entity
    }

    // @ Description
    // This hook allows samus bomb to be reflected if the reflect type is CUSTOM. also exits reflect if there is no reflect hb
    // also a good spot for chain chomp check
    scope override_reflectability: {
        OS.patch_start(0x60AD0, 0x800E52D0)
        j       override_reflectability
        _return:
        nop
        OS.patch_end()

        // s7 = reflecting entity (player)
        // s6 = projectile hitbox

        lw      t2, 0x0850(s7)               // t2 = pointer to reflect hitbox
        beqz    t2, _exit                    // skip entire reflect check if no reflect hitbox present
        addiu   at, r0, reflect_type.CUSTOM
        lh      t2, 0x0002(t2)               // t2 = reflect type
        bne     at, t2, _normal              // skip if reflect type != CUSTOM
        nop

        // if here, reflect type is CUSTOM
        addiu   at, r0, 0x1007               // at = chain chomp projectile id
        addiu   t2, s6, -0x100               // t2 = projectile struct
        lw      t2, 0x000C(t2)               // t2 = projectile id
        beq     at, t2, _exit                // exit reflect if this is the chain chomp
        nop
        j       0x800E52E0                   // jump to the rest of the reflect routine

        _normal:
        lw      t2, 0x0048(s6)               // original line 1, load flag from object hb
        j       _return
        sll     t4, t2, 5                    // original line 2, ~

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
        OS.patch_start(0xE17E0, 0x80166DA0)
        j       override_projectile_reflect_routine_
        _return:
        nop
        OS.patch_end()
        
        // v1 = projectile struct
        // a1 = routine to run
        // v0 = reflecting player struct

        sw      v1, 0x001C(sp)               // original line 2, save item struct to sp
        addiu   at, r0, reflect_type.CUSTOM  // at = custom reflect id
        lw      v1, 0x850(v0)                // v1 = reflect hb
        lh      t7, 0x0002(v1)               // t7 = current players reflect id
        bne     at, t7, _run_routine         // branch to normal routine if not custom
        nop

        lh      t7, 0x0000(v1)               // t7 = custom reflect routine index
        beqz    t7, _run_routine             // branch and run reflect routine if Franklin Badge
        nop

        // if here, custom reflect type is 1. We can extend this to add more later
        _destroy:
        lw      v1, 0x001C(sp)               // v1 = projectile struct
        lw      a1, 0x0294(v1)               // a1 = absorb routine
        bnez    a1, _run_routine             // run absorb routine if present
        nop
        lw      a1, 0x0298(v1)               // a1 = blast zone destruction routine
        b       _run_routine                 // run blast zone destruction routine
        nop

        _run_routine:
        jalr    ra, a1                       // original line 1, run reflect routine
        lw      v1, 0x001C(sp)               // v1 = projectile struct
        j       0x80166DA8                   // jump back to original routine
        nop

    }

    // @ Description
    // This hook adds a check for the reflect type and either runs the reflect routine or does what we specify
    scope override_item_reflect_routine_: {
        OS.patch_start(0xEBD20, 0x801712E0)
        j       override_item_reflect_routine_
        _return:
        nop
        OS.patch_end()

        // v1 = item struct
        // a1 = routine to run
        // v0 = reflecting player struct

        sw      v1, 0x001C(sp)               // original line 2, save item struct to sp
        addiu   at, r0, reflect_type.CUSTOM  // at = custom reflect id
        lw      v1, 0x850(v0)                // v1 = reflect hb
        lh      t7, 0x0002(v1)               // t7 = current players reflect id
        bne     at, t7, _run_routine         // branch to normal routine if not custom
        nop

        lh      t7, 0x0000(v1)               // t7 = custom reflect routine index
        beqz    t7, _run_routine             // branch and run reflect routine if Franklin Badge
        nop

        // if here, custom reflect type is 1. We can extend this to add more later
        b       _end                         // skip reflect routine, item is always destroyed for some reason.
        nop

        _run_routine:
        jalr    ra, a1                       // original line 1, run reflect routine
        _end:
        lw      v1, 0x001C(sp)               // original line 2, save item struct to sp
        j       0x801712E8                   // jump back to original routine
        nop

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
        dw 0x00000000                            // 0x04
        // add more routines here
    }
}
