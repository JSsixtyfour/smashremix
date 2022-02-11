// fireball.asm

// This file allows for copies of Mario's fireball projectile to be generated.

include "OS.asm"
include "Global.asm"

scope Fireball: {
    constant FIREBALL_BASE(0x80188E30)
    constant NORMAL_HIT_GFX_INST_ID_ADDRESS(0x8012DF20)
    constant NORMAL_HIT_GFX_INST_ID(0x49)
    constant DR_MARIO_EFFECT_GFX_INST_ID(0x81)

    // @ Description
    // Macro to set up a struct for a cloned fireball
    macro struct(name, defaults, duration, max_speed, min_speed, gravity, bounce, rotation, angle_g, angle_a, init_speed, data_pointer, palette_idx) {
        // align
        while ((pc() - FIREBALL_BASE) % 0x30) {
            db 0x00
        }
        // constants
        constant {name}(pc())
        constant {name}_id((pc() - FIREBALL_BASE) / 0x30)
        if {defaults} > 0 {
            constant {name}_default_settings({defaults})
        }
        // struct
        dw      {duration}                  // 0x0000 - duration (int)
        float32 {max_speed}                 // 0x0004 - max speed
        float32 {min_speed}                 // 0x0008 - min speed
        float32 {gravity}                   // 0x000C - gravity
        float32 {bounce}                    // 0x0010 - bounce multiplier
        float32 {rotation}                  // 0x0014 - rotation speed
        float32 {angle_g}                   // 0x0018 - initial angle (ground)
        float32 {angle_a}                   // 0x001C   initial angle (air)
        float32 {init_speed}                // 0x0020   initial speed
        dw      {data_pointer}              // 0x0024   projectile data pointer
        dw      0                           // 0x0028   unknown (default 0)
        float32 {palette_idx}               // 0x002C   palette index (0 = mario, 1 = luigi)
    }

    // @ Description
    // Macro which changes the fireball struct for a given character.
    // @ Arguments
    // id - ID of the character to change the fireball struct for
    // struct - fireball struct to use
    evaluate patch_num(0)
    macro add_to_character(id, struct) {
        global evaluate patch_num({patch_num} + 1)
        // This creates a routine for the fireball jump table to load the ID for the given struct.
        scope id_patch_{patch_num}_: {
            li      a0, {struct}_id         // a0 = struct id
            sw      a0, 0x001C(sp)          // store struct id
            j       0x80155EE4              // return
            nop
        }

        // This patches the routine into the fireball jump table for the given character id.
        Character.table_patch_start(fireball, {id}, 0x4)
        dw      id_patch_{patch_num}_
        OS.patch_end()

        // This creates a routine for the kirby fireball jump table to load the ID for the given struct.
        scope id_patch_kirby_{patch_num}_: {
            li      a0, {struct}_id         // a0 = struct id
            sw      a0, 0x001C(sp)          // store struct id
            j       0x80156A54              // return
            nop
        }

        // This patches the routine into the fireball jump table for the given character id.
        Character.table_patch_start(kirby_fireball, {id}, 0x4)
        dw      id_patch_kirby_{patch_num}_
        OS.patch_end()
    }

    // @ Description
    // Updates the Fireball to use new GFX/SFX on hit when different damage types are used.
    scope hit_effect_: {
        // v1 = projectile struct
        pushvar origin, base
        origin  0xE310C
        base    0x801686CC
        j       hit_effect_
        nop
        _hit_effect_return:
        origin  0xE3124
        base    0x801686E4
        _hit_effect_branch:
        pullvar base, origin

        OS.save_registers()
        lw      t0, 0x010C (v1)             // t0 = projectile type
        ori     t1, r0, Capsule.TYPE        // t1 = Capsule.TYPE
        beq     t0, t1, _capsule            // branch if type = Capsule.TYPE
        ori     t1, r0, Book.TYPE           // t1 = Book.TYPE
        beq     t0, t1, _book               // branch if type = Book.TYPE
        nop

        _fireball:
        jal     0x800269C0                  // play fgm (original line 1)
        or      a0, r0, r0                  // a0 = explosion FGM (original line 2)
        li      ra, _hit_effect_return      // load return address (default)
        b       _end                        // end
        sw      ra, 0x006C(sp)              // update ra and save to stack

        _capsule:
        jal     0x800269C0                  // play fgm
        ori     a0, r0, Capsule.FGM         // a0 = Capsule.FGM
        lw      t6, 0x0088(sp)              // ~
        lw      a0, 0x0074(t6)              // ~
        addiu   a0, a0, 0x001C              // modified original logic
        li      a1, NORMAL_HIT_GFX_INST_ID_ADDRESS
        lli     a2, DR_MARIO_EFFECT_GFX_INST_ID
        sb      a2, 0x0000(a1)              // temporarilty update the GFX_INSTRUCTIONS_ID for "normal hit" gfx
        or      a1, r0, r0                  // a1 = 0
        lw      a2, 0x000C(sp)              // a2 = projectile struct
        lw      a2, 0x0234(a2)              // a2 = damage
        jal     0x800FDC04                  // create "normal hit" gfx
        or      a3, r0, r0                  // a3 = 0
        li      a1, NORMAL_HIT_GFX_INST_ID_ADDRESS
        lli     a2, NORMAL_HIT_GFX_INST_ID
        sb      a2, 0x0000(a1)              // restore the GFX_INSTRUCTIONS_ID for "normal hit" gfx
        li      ra, _hit_effect_branch      // load return address (branch)
        b       _end                        // end
        sw      ra, 0x006C(sp)              // update ra and save to stack

        _book:
        jal     0x800269C0                  // play fgm
        ori     a0, r0, Book.FGM            // a0 = Book.FGM
        lw      t6, 0x0088(sp)              // ~
        lw      a0, 0x0074(t6)              // ~
        addiu   a0, a0, 0x001C              // modified original logic
        lw      a1, 0x0084(t6)              // a1 = projectile struct
        jal     0x801003D0                  // create "dust" particle
        lw      a1, 0x0018(a1)              // a1 = projectile direction
        lw      t6, 0x0088(sp)              // ~
        lw      a0, 0x0074(t6)              // ~
        addiu   a0, a0, 0x001C              // modified original logic
        or      a1, r0, r0                  // a1 = 0
        lw      a2, 0x000C(sp)              // a2 = projectile struct
        lw      a2, 0x0234(a2)              // a2 = damage
        jal     0x800FDC04                  // create "normal hit" gfx
        or      a3, r0, r0                  // a3 = 0
        li      ra, _hit_effect_branch      // load return address (branch)
        sw      ra, 0x006C(sp)              // update ra and save to stack

        _end:
        OS.restore_registers()
        jr      ra                      // return
        nop
    }

    // @ Description
    // Updates the Fireball to use new GFX upon bouncing when different damage types are used.
    scope bounce_effect_: {
        pushvar origin, base
        origin  0xE30E0
        base    0x801686A0
        j       bounce_effect_
        addiu   a0, a0, 0x001C
        _bounce_effect_return:
        pullvar base, origin

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x010C (v0)             // t0 = projectile type
        ori     t1, r0, Capsule.TYPE        // t1 = Capsule.TYPE
        beq     t0, t1, _capsule            // branch if type = Capsule.TYPE
        ori     t1, r0, Book.TYPE           // t1 = Book.TYPE
        beq     t0, t1, _book               // branch if type = Book.TYPE
        nop

        _fireball:
        jal     0x80102DEC                  // create "fire dust" gfx (original line 1)
        nop
        b       _end
        nop

        _capsule:
        jal     0x800FF048                  // create "small smoke" gfx
        nop
        b       _end
        nop

        _book:
        jal     0x800FF048                  // create "small smoke" gfx
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // allocate stack space
        j       _bounce_effect_return       // return
        nop
    }

    // @ Description
    // Setup for Mad Piano's book.
    scope Book {
        constant TYPE(0x3)                  // damage type to use for book effects
        constant FGM(0x1F)                  // fgm to play when a book hits an opponent
        angle_info:
        float32 1.0472                      // 0x00 - Default Angle (60 degrees)
        float32 0.436332                    // 0x04 - Angle Spread (25 degrees)

        // @ Description
        // Subroutine used during the creation of the book projectile.
        // Randomizes the angle the book is shot at, and creates multiple books if the Piano has bonus ammo.
        scope create_: {
            // v0 = player struct
            // a3 = player object

            addiu   a1, sp, 0x0020          // a1 =  pointer to x/y/z coords
            addiu   sp, sp,-0x0040          // allocate stack space
            sw      a1, 0x0020(sp)          // 0x0020(sp) = x/y/z pointer
            sw      a3, 0x0024(sp)          // 0x0024(sp) = player object
            sw      v0, 0x0028(sp)          // 0x0028(sp) = player struct

            // first check if the character is Piano, if not then assume it's Kirby
            lw      t0, 0x0008(v0)          // t0 = character id
            lli     t1, Character.id.PIANO  // t1 = id.PIANO
            bnel    t0, t1, _begin_loop     // begin loop if character is not Piano...
            or      t9, r0, r0              // ...and set loop iteration count to 0 (don't loop)

            // if the character is Piano, check for bonus_ammo and create extra projectiles
            lwc1    f0, 0x0ADC(v0)          // f0 = bonus_ammo
            trunc.w.s f0, f0                // truncate bonus_ammo to int (rounding down to nearest int)
            mfc1    t0, f0                  // t0 = bonus_ammo
            beql    t0, r0, _begin_loop     // skip if bonus_ammo = 0...
            or      t9, r0, r0              // ...and set loop iteration count to 0 (don't loop)

            // if there is bonus ammunition, reset bonus_ammo and add loop iterations
            sw      r0, 0x0ADC(v0)          // reset bonus_ammo
            or      t9, t0, r0              // set loop iteration count to bonus_ammo

            _begin_loop:
            or      t8, r0, r0              // t8 = current loop iteration (0)

            _loop:
            // t8 = current loop iteration
            // t9 = loop iteration count
            // get a random multiplier between -0.5 and 0.5 for calculating the spread
            jal     Global.get_random_int_  // v0 = (0, 100)
            lli     a0, 0101                // ~
            addiu   t0, v0,-0050            // ~
            mtc1    t0, f0                  // ~
            cvt.s.w f0, f0                  // f0 = (-50, 50)
            li      t0, 0x3C23D70A          // ~
            mtc1    t0, f2                  // f2 = 0.01
            mul.s   f0, f0, f2              // f0 = spread multiplier (-0.5, 0.5)
            // increase the intensity of the spread multiplier by 25% for each loop iteration
            mtc1    t8, f2                  // ~
            cvt.s.w f2, f2                  // f2 = current iteration
            lui     t0, 0x3E80              // ~
            mtc1    t0, f4                  // f2 = 0.25
            mul.s   f2, f2, f4              // f2 = 0.25 * current iteration
            lui     t0, 0x3F80              // ~
            mtc1    t0, f4                  // f4 = 1
            add.s   f2, f2, f4              // f2 = intensity multiplier (1 + 0.25 per loop iteration)
            mul.s   f0, f0, f2              // f0 = final spread multiplier (spread multiplier * intensity multiplier)
            // apply the final spread multiplier to the default angle
            li      t0, angle_info          // t0 = angle_info
            lwc1    f2, 0x0004(t0)          // f2 = spread
            lwc1    f4, 0x0000(t0)          // f4 = default angle
            mul.s   f2, f2, f0              // f2 = spread angle (spread * spread multiplier)
            add.s   f2, f2, f4              // f2 = final angle (default angle + spread angle)
            li      t0, struct_book         // t0 = book fireball struct
            swc1    f2, 0x0018(t0)          // ~
            swc1    f2, 0x001C(t0)          // update projectile launch angle
            // create the projectile
            lw      a0, 0x0024(sp)          // a0(player) = player object
            lw      a1, 0x0020(sp)          // a1(coordinates) = pointer to x/y/z coords
            li      a2, struct_book_id      // a2(struct id) = struct_book_id
            sw      t8, 0x002C(sp)          // store t8
            jal     0x801687A0              // create fireball
            sw      t9, 0x0030(sp)          // store t9

            _end_loop:
            // exit the loop if the iteration count has not yet been reached
            lw      t8, 0x002C(sp)          // load t8 (current loop iteration)
            lw      t9, 0x0030(sp)          // load t9 (iteration count)
            bnel    t8, t9, _loop           // loop if current iteration < iteration count...
            addiu   t8, t8, 0x0001          // ...and increment current iteration

            _end:
            addiu   sp, sp, 0x0040          // deallocate stack space
            j       0x80155EF4              // return to the end of the fireball subroutine
            nop
        }

        // @ Description
        // Updates the joint used to get the initial position of the projectile when Kirby copies Piano's power.
        scope kirby_fix_: {
            OS.patch_start(0xD1448, 0x80156A08)
            j       kirby_fix_
            sw      a3, 0x0030(sp)          // original line 2
            _return:
            OS.patch_end()

            lw      a0, 0x092C(v0)          // a0 = part 0xD struct (original line 1)
            lw      t7, 0x0ADC(v0)          // t7 = character id of copied power
            lli     at, Character.id.PIANO  // at = id.PIANO
            beql    at, t7, _end            // branch if copied power = PIANO...
            lw      a0, 0x0904(v0)          // ...and replace a0 with part 0x3 struct

            _end:
            j       _return                 // return
            nop
        }
    }

    // @ Description
    // Setup for Dr. Mario's capsule.
    scope Capsule {
        constant FIREBALL_SUBROUTINE(0x80155E64)
        constant KIRBY_FIREBALL_SUBROUTINE(0x801569D4)
        constant TYPE(0x4)                  // damage type to use for capsule effects
        constant FGM(0x2C7)                 // fgm to play when capsule hits an opponent

        // @ Description
        // Subroutine which randomizes the palette index used by Dr. Mario's capsule when the
        // projectile is created.
        // Uses the moveset command 540000XX (orignally identified as "create prop" by toomai)
        // This command sets the value of temp variable 1, which is used to determine when
        // Mario's fireball should be created.
        scope capsule_subroutine_: {
            // v0 = player struct
            // 0x17C in player struct = temp variable 1
            addiu   sp, sp,-0x0010          // allocate stack space
            swc1    f0, 0x0004(sp)          // ~
            sw      ra, 0x0008(sp)          // store f0, ra
            lw      v0, 0x0084(a0)          // v0 = player struct
            OS.save_registers()
            lw      t0, 0x017C(v0)          // t0 = temp variable 1
            beq     t0, r0, _end            // end if temp variable 1 = 0
            nop
            li      t1, struct_capsule      // t1 = struct_capsule
            ori     a0, r0, 0x3             // ~
            jal     Global.get_random_int_  // v0 = (0-2)
            nop
            mtc1    v0, f0                  // ~
            cvt.s.w f0, f0                  // f0 = random palette index (0-2)
            swc1    f0, 0x002C(t1)          // store palette index

            _end:
            OS.restore_registers()
            li      at, FIREBALL_SUBROUTINE
            li      t7, KIRBY_FIREBALL_SUBROUTINE
            lw      t6, 0x0008(v0)          // t6 = char_id

            lli     a3, Character.id.KIRBY  // a3 = id.KIRBY
            beql    t6, a3, pc() + 8        // if Kirby, use KIRBY_FIREBALL_SUBROUTINE
            or      at, t7, r0              // at = KIRBY_FIREBALL_SUBROUTINE
            lli     a3, Character.id.JKIRBY // a3 = id.JKIRBY
            beql    t6, a3, pc() + 8        // if Kirby, use KIRBY_FIREBALL_SUBROUTINE
            or      at, t7, r0              // at = KIRBY_FIREBALL_SUBROUTINE

            jalr    ra, at                  // original fireball subroutine
            nop
            lwc1    f0, 0x0004(sp)          // ~
            lw      ra, 0x0008(sp)          // load f0, ra
            addiu   sp, sp, 0x0010          // deallocate stack space
            jr      ra                      // return
            nop
        }

        // @ Description
        // Loads the capsule subroutine when Dr. Mario uses neutral special.
        scope load_capsule_subroutine_: {
            // Character (Mario/Luigi/Dr. Mario/Piano/etc)
            OS.patch_start(0xD0A40, 0x80156000)
            j       load_capsule_subroutine_
            sw      r0, 0x017C(v0)          // original line 3
            OS.patch_end()
            // Kirby
            OS.patch_start(0xD15FC, 0x80156BBC)
            j       load_capsule_subroutine_
            sw      r0, 0x017C(v0)          // original line 3
            OS.patch_end()

            // v0 = player struct

            addiu   sp, sp,-0x0010          // allocate stack space
            sw      t0, 0x0004(sp)          // store registers
            sw      t1, 0x0008(sp)          // ~
            sw      t7, 0x000C(sp)          // ~

            li      t6, FIREBALL_SUBROUTINE // t6 = FIREBALL_SUBROUTINE (original lines 1&2)
            li      t7, KIRBY_FIREBALL_SUBROUTINE

            lbu     t1, 0x000B(v0)          // t1 = current char id

            lli     t0, Character.id.KIRBY  // t0 = id.KIRBY
            beql    t1, t0, _kirby          // if Kirby, get held power character_id
            lw      t1, 0x0ADC(v0)          // t1 = character id of copied power
            lli     t0, Character.id.JKIRBY // t0 = id.JKIRBY
            beql    t1, t0, _kirby          // if J Kirby, get held power character_id
            lw      t1, 0x0ADC(v0)          // t1 = character id of copied power

            _capsule_check:
            lli     t0, Character.id.DRM    // t0 = id.DRM
            bne     t0, t1, _end            // skip if char id != DRM
            nop
            li      t6, capsule_subroutine_ // t6 = capsule subroutine

            _end:
            lw      t0, 0x0004(sp)          // restore registers
            lw      t1, 0x0008(sp)          // ~
            lw      t7, 0x000C(sp)          // ~
            addiu   sp, sp, 0x0010          // deallocate stack space
            jr      ra                      // original line 4
            sw      t6, 0x09D8(v0)          // original line 5

            _kirby:
            li      t6, KIRBY_FIREBALL_SUBROUTINE // t6 = KIRBY_FIREBALL_SUBROUTINE (original lines 1&2)
            b       _capsule_check
            nop
        }
    }

    // Define fireball structs.
    struct(struct_capsule, 0, 140, 60, 25, 1.5, 0.95, 0.3, -0.4, -0.4, 40, Character.DRM_file_6_ptr, 0)
    struct(struct_jmario, 0, 140, 55, 30, 1.2, 0.85, 0.3490659, -0.08726647, -0.08726647, 50, Character.JMARIO_file_6_ptr, 0)
    struct(struct_jluigi, 0, 90, 55, 30, 0, 0.85, 0.4363323, 0, 0, 36, Character.JLUIGI_file_6_ptr, 1)
    struct(struct_book, 0, 120, 60, 25, 1.4, 0.55, 0.139626, 1.0472, 1.0472, 50, Character.PIANO_file_6_ptr, 0)

    // Add fireball structs to characters.
    add_to_character(Character.id.DRM, struct_capsule)
    add_to_character(Character.id.JMARIO, struct_jmario)
    add_to_character(Character.id.JLUIGI, struct_jluigi)
}
