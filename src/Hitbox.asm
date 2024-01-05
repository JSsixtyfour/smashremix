// Hitbox.asm (by Fray)
if !{defined __HITBOX__} {
define __HITBOX__()
print "included Hitbox.asm\n"

// @ Description
// Hitbox display is implemented in this file

// TODO:
// - hide hitboxes/ecb when cloaking device active?

include "Toggles.asm"
include "OS.asm"

scope Hitbox {

    // @ Description
    // this is a hook into the function which loads the character's hitbox display state
    // by default the value (at 0x0B4C(s8)) will always be 0
    // v1 contains hitbox display state:
    // 0 = no hitbox display
    // 3 = ECB display
    // (all other values?) = hitbox display
    scope hitbox_mode_: {
        constant FIRST_ITEM_PTR(0x80046700)

        OS.patch_start(0x0006E3FC, 0x800F2BFC)
        j       hitbox_mode_
        swc1    f10, 0x0000(v0)             // original line 1
        _hitbox_mode_return:
        OS.patch_end()

        lli     v1, 0x0000                  // v1 = no hitbox display
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~

        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 1 if hitbox_mode, 2 if hitbox+model, 3 if ECB
        lli     t1, 0x0001                  // t1 = 1
        beql    t0, t1, _update_t3          // if (hitbox_mode), set v1
        lli     v1, 0x0001                  // v1 = normal hitbox display

        lli     t1, 0x0003                  // t1 = 3
        beql    t0, t1, _update_t3          // if (ecb_mode), set v1
        lli     v1, 0x0003                  // v1 = ecb display

        lli     t3, 0x0000                  // t3 = no hitbox display

        OS.read_word(kirby_cube_enabled, t2)
        beqz    t2, _update_player          // skip if Kirby cube not enabled
        lw      t2, 0x0008(s8)              // t2 = char_id
        lli     t1, Character.id.KIRBY
        beql    t2, t1, _update_player      // if Kirby, set hitbox display
        lli     v1, 0x0004                  // v1 = normal hitbox display because not 1 or 3
        lli     t1, Character.id.JKIRBY
        beql    t2, t1, _update_player      // if J Kirby, set hitbox display
        lli     v1, 0x0004                  // v1 = normal hitbox display because not 1 or 3

        _update_t3:
        or      t3, v1, r0                  // t3 = v1
        _update_player:
        sw      v1, 0x0B4C(s8)              // save hitbox display state

        or      t2, t3, r0                  // t2 = t3
        lli     t1, 0x0002                  // t1 = 2
        beql    t0, t1, _update_item        // if (hitbox+model), set t2 for items
        lli     t2, 0x0002                  // t2 = transparent hitbox display

        _update_item:
        li      t0, FIRST_ITEM_PTR          // t0 = FIRST_ITEM_PTR
        lw      t0, 0x0000(t0)              // t0 = address of first item object

        _loop:
        // t0 = object struct address
        beqz    t0, _exit_loop              // if t0 = NULL, exit loop
        nop
        lw      t1, 0x0084(t0)              // t1 = item struct address
        bnel    t1, r0, _loop_end           // ~
        sw      t2, 0x0374(t1)              // if t1 != NULL, update hitbox display state
        _loop_end:
        b       _loop                       // loop
        lw      t0, 0x0004(t0)              // t0 = next object struct

        _exit_loop:
        li      t6, _hitbox_mode_return     // t6 = normal return address

        OS.read_word(kirby_cube_enabled, t2)
        beqz    t2, _return                 // skip if Kirby cube not enabled
        lw      t2, 0x0008(s8)              // t2 = char_id
        lli     t1, Character.id.KIRBY
        beq     t2, t1, _check_cube_ecb     // if Kirby, check ecb
        lli     t1, Character.id.JKIRBY
        beq     t2, t1, _check_cube_ecb     // if J Kirby, check ecb
        nop

        _return:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        jr      t6
        addiu   sp, sp, 0x0020              // deallocate stack space

        _check_cube_ecb:
        bne     v1, at, _return             // if not ECB, skip
        nop
        li      t6, 0x800F330C              // forces hitbox display
        b       _return
        lui     t7, 0x8004                  // sets up t7 for 800F330C
    }

    // @ Description
    // this is a hook into the function which loads the display state for projectiles
    scope projectile_: {
        OS.patch_start(0x000E1F78, 0x80167538)
        j       projectile_
        nop
        _projectile_return:
        OS.patch_end()
        or      s0, a0, r0                  // original line 1
        lli     v1, 0x0000                  // v1 = no hitbox display

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~

        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 1 if hitbox_mode
        lli     t1, 0x0001                  // t1 = 1
        beql    t0, t1, _update_projectile  // if (hitbox_mode), set v1
        lli     v1, 0x0001                  // v1 = normal hitbox display
        lli     t1, 0x0002                  // t1 = 2
        beql    t0, t1, _update_projectile  // if (hitbox+model), set v1
        lli     v1, 0x0002                  // v1 = transparent hitbox display

        lli     t1, 0x0003                  // t1 = 3
        beql    t0, t1, _update_projectile  // if (ecb_mode), set v1
        lli     v1, 0x0003                  // v1 = ecb display

        _update_projectile:
        sw      v1, 0x02BC(v0)              // save projectile display state

        end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _projectile_return
        nop
    }

    // @ Description
    // When the Advanced Hurtbox Display is on, colors hurtboxes gray when in active armor frames and grab-immune hurtboxes cyan.
    scope grab_immunity_and_armor_frames_: {
        OS.patch_start(0x6DF9C, 0x800F279C)
        jal     grab_immunity_and_armor_frames_
        OS.patch_end()

        li      t3, Toggles.entry_advanced_hurtbox
        lw      t3, 0x0004(t3)              // t0 = 1 if advanced is on, 0 if not
        beqz    t3, _end                    // if not in advanced hurtbox mode, skip
        nop

        lw      t3, 0x0094(sp)              // t3 = player struct
        lh      t6, 0x018C(t3)              // t6 = current players flag
        andi    t6, t6, 0x0480              // t6 != 0 if reflecting or absorbing
        beqz    t6, _check_armor
		nop
        lui     t5, 0x00FF                  // t0 = RGBA32 CYAN
        b       _end
        ori     t5, t5, 0xFFFF              // ~

		_check_armor:
        lw      t3, 0x07E8(t3)              // t3 = non-zero if in armor frames
        li      t6, 0x606060FF              // t6 = dark gray for armor frames, if needed
        bnezl   t3, _end                    // if in armor frames, change color and skip grab immunity check
        or      t5, r0, t6                  // change color of hurtbox

        lw      t3, 0x0030(sp)              // t3 = hurtbox struct (from stack)
        lw      t3, 0x0010(t3)              // t3 = grab flag
        beql    t3, r0, _end                // branch and run next instruction if flag = 0 (not grabbable)
        srl     t5, t5, 0x0008              // change color of hurtbox

        _end:
        jr      ra                          // return
        ori     t5, t5, 0x00FF              // original line 1
    }

    // @ Description
    // Makes hurtboxes transparent in hitbox+model mode.
    scope make_hurtboxes_transparent_: {
        // players
        OS.patch_start(0x6E030, 0x800F2830)
        jal     make_hurtboxes_transparent_
        nop
        OS.patch_end()

        // items
        OS.patch_start(0xEC37C, 0x8017193C)
        j       make_hurtboxes_transparent_._items
        nop
        _items_return:
        OS.patch_end()

        // s2 = joint -> 0x0004 = player obj

        li      t6, Toggles.entry_special_model
        lw      t6, 0x0004(t6)              // t6 = 2 if hitbox+model
        addiu   t6, t6, -0x0002             // t6 = 0 if hitbox+model
        bnez    t6, _original
        nop

        // make them transparent by modifying the display list
        // first, update prim color to be env color
        // the setprimcolor command is always before the setenvcolor command right and was just set
        lw      t6, -0x0004(s0)             // t6 = env color
        sw      t6, -0x000C(s0)             // set env color in prim color command

        // next, add a command for setting blend color
        lui     t6, 0xF900                  // t6 = setblendcolor command
        sw      t6, 0x0000(s0)              // add to display list
        lli     t6, 0x00E0                  // t6 = blend color value (black with some alpha - it's what the hitboxes use)
        sw      t6, 0x0004(s0)              // add to display list
        addiu   s0, s0, 0x0008              // t3 = new display list end pointer

        // then update the display list for rendering the boxes
        li      t6, 0x8012C310              // t6 = alternative display list that allows rendering only the outline

        b       _end
        nop

        _original:
        // First make sure we're not rendering an item
        li      t6, 0x800F2838
        bne     t6, ra, _normal             // if an item, return normally
        nop
        // Check if Kirby cube
        lw      t6, 0x0004(s2)              // t6 = player object
        lw      t6, 0x0084(t6)              // t6 = player struct
        lw      t6, 0x0B4C(t6)              // t6 = 4 if Kirby cube (or 3 if ecb)
        addiu   t6, t6, -0x0003             // t4 >= 0 if Kirby cube
        bltz    t6, _normal                 // if not Kirby cube, do normal
        nop

        _kirby_cube:
        li      t6, kirby_cube_file_pointer
        lw      t6, 0x0000(t6)              // t6 = file start address
        jr      ra
        addiu   t6, t6, 0x0980              // t6 = display list start

        _normal:
        lui     t6, 0x8013                  // original line 1
        addiu   t6, t6, 0xC058              // original line 2

        _end:
        jr      ra
        nop

        _items:
        jal     make_hurtboxes_transparent_
        nop
        j       _items_return
        or      t1, t6, r0                  // the item code uses t1, not t6
    }

    // @ Description
    // Ensures hitboxes are transparent in hitbox+model mode.
    scope make_hitboxes_transparent_: {
        OS.patch_start(0x6EBB0, 0x800F33B0)
        jal     make_hitboxes_transparent_
        nop
        OS.patch_end()

        // the check is if t4 is 2, so we just need to get that from our toggle
        li      t4, Toggles.entry_special_model
        lw      t4, 0x0004(t4)              // t4 = 1 if hitbox_mode, 2 if hitbox+model, 3 if ECB

        jr      ra
        addiu   at, r0, 0x0002              // original line 2
    }

    // @ Description
    // Adds reflect/absorb hitboxes.
    scope add_reflect_absorb_hitboxes: {
        OS.patch_start(0x6EB58, 0x800F3358)
        jal     add_reflect_absorb_hitboxes
        lui     s5, 0x8004                  // original line 1
        OS.patch_end()

        // li      t4, Toggles.entry_special_model
        // lw      t4, 0x0004(t4)              // t4 = 1 if hitbox_mode, 2 if hitbox+model, 3 if ECB

        // s6 = player object
        lw      t3, 0x0084(s6)              // t3 = player struct
        lw      t0, 0x0850(t3)              // t0 = reflect/absorb struct
        beqz    t0, _end                    // skip if empty
        lw      t1, 0x018C(t3)              // t1 = flags
        lui     t2, 0x0480                  // t2 = reflect/absorb active flag
        and     t1, t1, t2                  // t1 = 0 if not active
        beqz    t1, _end                    // skip if not active
        lui     t1, 0x8004                  // t1 = 0x80040000

        lw      t2, 0x65B0(t1)              // t2 = end of current display list

        // first, we set up the matrix based on the joint the hurtbox should be attached to
        lw      at, 0x0004(t0)              // at = index of joint to use, starting at 0x08E8 in player struct
        sll     at, at, 0x0002              // at = offset of joint
        addu    at, t3, at                  // at = player struct addjusted for offset to joing
        lw      at, 0x08E8(at)              // at = address of joint

        lw      t4, 0x0074(s6)              // t4 = top joint
        lui     t5, 0xDA38                  // t5 = top part of G_MTX command
        lli     t7, 0x0000                  // t7 = default to pushing the first matrix

        _loop:
        or      t8, t5, t7                  // t8 = top part of G_MTX command
        sw      t8, 0x0000(t2)              // save G_MTX command first word
        lw      t6, 0x0058(t4)              // t6 = render struct for joint
        addiu   t6, t6, 0x0008              // t6 = translation matrix for joint
        sw      t6, 0x0004(t2)              // save G_MTX command second word
        addiu   t2, t2, 0x0008              // t2 = end of display list, updated
        lli     t7, 0x0001                  // t7 = don't push after the first matrix
        bne     at, t4, _loop               // if this isn't the target joint, get the next one and add another G_MTX command
        lw      t4, 0x0010(t4)              // t4 = next joint

        lli     t4, 0x0001                  // t4 = bottom half of G_MTX first word (tells it to push matrix)

        // Now we need to use the reflect/absorb struct to finish the matrix setup
        sw      t5, 0x0000(t2)              // save G_MTX command first word, offset matrix
        sw      t5, 0x0008(t2)              // save G_MTX command first word, scale matrix
        sh      t4, 0x000A(t2)              // update the last G_MTX command

        li      t4, 0x800465D8              // t4 = some sort of struct for allocation
        lw      a0, 0x000C(t4)              // a0 = current free space address
        addiu   t6, a0, 0x0040              // t6 = free space after 0x8001B9C4
        addiu   t7, t6, 0x0040              // t7 = free space after 0x8001B780
        sw      t7, 0x000C(t4)              // update free space address

        sw      a0, 0x0004(t2)              // save G_MTX command second word, offset matrix
        sw      t6, 0x000C(t2)              // save G_MTX command second word, scale matrix
        addiu   t2, t2, 0x0010              // t2 = new end of display list
        sw      t2, 0x65B0(t1)              // save end of display list

        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0014(sp)              // save registers
        sw      t0, 0x0018(sp)              // ~
        sw      t2, 0x001C(sp)              // ~
        sw      t6, 0x0020(sp)              // ~

        lw      a1, 0x0008(t0)              // a1 = X
        lw      a2, 0x000C(t0)              // a2 = Y
        jal     0x8001B9C4                  // create matrix
        lw      a3, 0x0010(t0)              // a3 = Z

        lw      a0, 0x0020(sp)              // a0 = free space address
        lui     at, 0x4170                  // at = scale adjuster
        mtc1    at, f0                      // f0 = scale adjuster
        lw      t0, 0x0018(sp)              // t0 = reflect/absorb struct
        lwc1    f16, 0x001C(t0)             // f16 = Z scale
        div.s   f18, f16, f0                // f18 = Z scale, adjusted
        lwc1    f8, 0x0018(t0)              // f8 = Y scale
        div.s   f10, f8, f0                 // f10 = Y scale, adjusted
        lwc1    f4, 0x0014(t0)              // f4 = X scale
        div.s   f6, f4, f0                  // f6 = X scale, adjusted
        mfc1    a3, f18                     // a3 = Z scale
        mfc1    a2, f10                     // a2 = Y scale
        mfc1    a1, f6                      // a1 = X scale
        jal     0x8001B780                  // create scale matrix
        nop

        lw      ra, 0x0014(sp)              // restore registers
        lw      t2, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0040              // restore stack space

        lui     t5, 0xE700                  // t5 = G_RDPPIPESYNC
        sw      t5, 0x0000(t2)              // save G_RDPPIPESYNC command
        sw      r0, 0x0004(t2)              // ~

        lui     t5, 0xF900                  // t5 = G_SETBLENDCOLOR
        sw      t5, 0x0008(t2)              // save G_SETBLENDCOLOR command
        lli     t5, 0x00E0                  // t5 = alpha
        sw      t5, 0x000C(t2)              // save alpha

        lui     t5, 0xFA00                  // t5 = G_SETPRIMCOLOR
        sw      t5, 0x0010(t2)              // save G_SETPRIMCOLOR command
        li      t5, 0xFF8040FF              // t5 = reflect color
        li      t4, 0xFF4080FF              // t4 = absorb color
        lw      t3, 0x0084(s6)              // t3 = player struct
        lw      t1, 0x018C(t3)              // t1 = flags
        lui     t6, 0x0080                  // t6 = absorb active flag
        and     t1, t1, t6                  // t1 = 0 if not absorb
        bnezl   t1, pc() + 8                // if absorb, adjust color
        or      t5, r0, t4                  // t5 = absorb color

        // hacky fix for Reflect.asm making absorb powers
        lw      t1, 0x0850(t3)              // t1 = absorb/reflect struct
        li      t6, MarinaDSP.absorb_struct // t6 = Marina's absorb struct
        beql    t1, t6, _save_color         // if Marina's absorb struct, then use absorb color
        or      t5, r0, t4                  // t5 = absorb color
        li      t6, DededeNSP.absorb_struct // t6 = Dedede's absorb struct
        beql    t1, t6, _save_color         // if Dedede's absorb struct, then use absorb color
        or      t5, r0, t4                  // t5 = absorb color

        _save_color:
        sw      t5, 0x0014(t2)              // save color

        lui     t5, 0xFB00                  // t5 = G_SETENVCOLOR
        sw      t5, 0x0018(t2)              // save G_SETENVCOLOR command
        addiu   t5, r0, -0x0001             // t5 = white
        sw      t5, 0x001C(t2)              // save white

        lui     t5, 0xDE00                  // t5 = G_DL
        sw      t5, 0x0020(t2)              // save G_DL command
        li      t5, 0x8012C310              // t5 = transparent hitbox display list
        sw      t5, 0x0024(t2)              // save display list

        li      t5, 0xD8380002              // t5 = G_POPMTX
        sw      t5, 0x0028(t2)              // save G_POPMTX command
        lli     t5, 0x0080                  // t5 = pop 2 matrixes (2 * 0x40)
        sw      t5, 0x002C(t2)              // save num matrixes to pop

        addiu   t2, t2, 0x0030              // t2 = end of display list
        lui     t1, 0x8004
        sw      t2, 0x65B0(t1)              // save end of display list

        _end:
        jr      ra
        addiu   s5, s5, 0x65D8              // original line 2
    }

    // @ Description
    // This prevents a dynamic buffer overflow on the CSS when rendering the hitbox display over the model.
    // VS
    OS.patch_start(0x139C48, 0x8013B9C8)
    dw      0x00003A98 + 0x4000             // original is 0x3A98
    OS.patch_end()
    // 1P
    OS.patch_start(0x140EC8, 0x80138CC8)
    dw      0x00004A38 + 0x4000             // original is 0x4A38
    OS.patch_end()

    // @ Description
    // This prevents a dynamic buffer overflow on the 1P VS title card when rendering the hitbox display over the model.
    OS.patch_start(0x12EEB0, 0x80135B70)
    dw      0x0000C350 + 0x10000            // original is 0xC350
    OS.patch_end()
    OS.patch_start(0x12EEC0, 0x80135B80)
    dw      0x00010000 + 0x11000            // original is 0x10000
    OS.patch_end()

    // @ Description
    // Enables rendering the hitbox display over the model.
    scope render_hitbox_plus_model_: {
        OS.patch_start(0x6E7D0, 0x800F2FD0)
        jal     render_hitbox_plus_model_
        nop
        OS.patch_end()

        li      v0, Toggles.entry_special_model
        lw      v0, 0x0004(v0)              // v0 = 2 if hitbox+model
        addiu   v0, v0, -0x0002             // v0 = 0 if hitbox+model
        bnez    v0, _original
        nop

        bnel    t7, at, _j_0x800F330C       // jump to hitbox rendering
        lui     t7, 0x8004                  // required first line

        jr      ra                          // if check fails, return
        nop

        _j_0x800F330C:
        j       0x800F330C                  // jump
        nop

        _original:
        bnel    t7, at, _j_0x800F364C       // original line 1 (modified to jump)
        lw      v0, 0x0020(s8)              // original line 2

        jr      ra                          // if check fails, return
        nop

        _j_0x800F364C:
        j       0x800F364C                  // jump
        nop
    }

    // @ Description
    // Enables rendering the hitbox display over projectiles.
    scope render_hitbox_plus_projectile_: {
        OS.patch_start(0xE1FB8, 0x80167578)
        jal     render_hitbox_plus_projectile_._projectile
        nop
        OS.patch_end()
        OS.patch_start(0xE1FEC, 0x801675AC)
        jal     render_hitbox_plus_projectile_._hitbox
        nop
        OS.patch_end()

        _projectile:
        li      t6, Toggles.entry_special_model
        lw      t6, 0x0004(t6)              // t6 = 2 if hitbox+model
        addiu   t6, t6, -0x0002             // t6 = 0 if hitbox+model
        beqz    t6, _j_0x8016758C           // if hitbox+model, jump to rendering projectile
        nop

        beqz    v1, _j_0x8016758C           // original line 1 (modified to jump)
        nop
        jr      ra                          // if check fails, return
        nop

        _j_0x8016758C:
        j       0x8016758C                  // jump
        nop

        _hitbox:
        li      t6, Toggles.entry_special_model
        lw      t6, 0x0004(t6)              // t6 = 2 if hitbox+model
        addiu   t6, t6, -0x0002             // t6 = 0 if hitbox+model
        bnez    t6, _j_0x801675C0           // if not hitbox+model, skip rendering hitbox
        nop

        jr      ra                          // otherwise, return so it renders the hitbox
        nop

        _j_0x801675C0:
        j       0x801675C0                  // original line 1 (modified to jump)
        lw      ra, 0x001C(sp)              // original line 2
    }

    // @ Description
    // Enables rendering the hitbox display over items.
    scope render_hitbox_plus_item_: {
        // Pokeball (at least)
        OS.patch_start(0xEC760, 0x80171D20)
        jal     render_hitbox_plus_item_
        lli     a0, 0x0000                  // a0 = render routine index
        OS.patch_end()

        // Beam Sword (at least)
        OS.patch_start(0xEC81C, 0x80171DDC)
        jal     render_hitbox_plus_item_
        lli     a0, 0x0001                  // a0 = render routine index
        OS.patch_end()

        // Bob-omb (at least)
        OS.patch_start(0xECA30, 0x80171FF0)
        jal     render_hitbox_plus_item_
        lli     a0, 0x0002                  // a0 = render routine index
        OS.patch_end()

        // Link bomb (at least)
        OS.patch_start(0xECD30, 0x801722F0)
        jal     render_hitbox_plus_item_
        lli     a0, 0x0003                  // a0 = render routine index
        OS.patch_end()

        // Clefairy (as rising Snorlax at least)
        OS.patch_start(0xFDEAC, 0x8018346C)
        jal     render_hitbox_plus_item_._clefairy_snorlax_rising
        lli     a0, 0x0000                  // a0 = render routine index
        OS.patch_end()

        // Snorlax rising
        OS.patch_start(0xF900C, 0x8017E5CC)
        jal     render_hitbox_plus_item_._clefairy_snorlax_rising
        lli     a0, 0x0000                  // a0 = render routine index
        OS.patch_end()

        // Clefairy as Snorlax falling
        OS.patch_start(0xFE008, 0x801835C8)
        jal     render_hitbox_plus_item_._clefairy_snorlax_falling
        lli     a0, 0x0000                  // a0 = render routine index
        OS.patch_end()

        // Snorlax falling
        OS.patch_start(0xF8C68, 0x8017E228)
        jal     render_hitbox_plus_item_._clefairy_snorlax_falling
        lli     a0, 0x0000                  // a0 = render routine index
        OS.patch_end()

        li      t6, Toggles.entry_special_model
        lw      t6, 0x0004(t6)              // t6 = 2 if hitbox+model
        addiu   t6, t6, -0x0002             // t6 = 0 if hitbox+model
        bnez    t6, _render_hitbox          // if not hitbox+model, skip drawing item
        sw      ra, 0x0010(sp)              // save ra

        beqz    a0, _draw_item_1            // branch to correct draw item routine if a0 = 0
        addiu   a0, a0, -0x0001             // a0--
        beqz    a0, _draw_item_2            // branch to correct draw item routine if a0 = 0
        addiu   a0, a0, -0x0001             // a0--
        beqz    a0, _draw_item_3            // branch to correct draw item routine if a0 = 0
        nop
        b       _draw_item_4
        nop

        _draw_item_1:
        jal     0x80014038                  // draw item
        or      a0, a1, r0                  // original line 2

        b       _render_hitbox              // render hitbox
        nop

        _draw_item_2:
        jal     0x80014768                  // draw item
        or      a0, a1, r0                  // original line 2

        b       _render_hitbox              // render hitbox
        nop

        _draw_item_3:
        jal     0x80171DF4                  // draw item
        or      a0, a1, r0                  // original line 2

        b       _render_hitbox              // render hitbox
        nop

        _draw_item_4:
        jal     0x80172008                  // draw item
        or      a0, a1, r0                  // original line 2

        // fall through to _render_hitbox

        _render_hitbox:
        jal     0x80171410                  // original line 1
        lw      a0, 0x0020(sp)              // a0 = item object

        lw      ra, 0x0010(sp)              // restore ra
        jr      ra
        nop

        _clefairy_snorlax_rising:
        li      t1, 0x00553078              // t1 = Mode bits
        b       _clefairy_snorlax_shared
        nop

        _clefairy_snorlax_falling:
        li      t1, 0x005041C8              // t1 = Mode bits
        _clefairy_snorlax_shared:
        li      t0, 0xE200001C              // t0 = Set Other Mode Lower command
        lw      v0, 0x0000(s0)              // v0 = display list end
        sw      t0, 0x0000(v0)              // save command
        sw      t1, 0x0004(v0)              // ~
        addiu   v0, v0, 0x0008              // v0 = display list end
        sw      v0, 0x0000(s0)              // update display list end
        lw      a1, 0x0028(sp)              // a1 = item object
        b       render_hitbox_plus_item_
        sw      a1, 0x0020(sp)              // save item object
    }

    // @ Description
    // This makes it so the hitbox display is positioned correctly on the CSS screens and the VS results screen.
    // I am doing it this way because I don't know if the positioning is important on other screens.
    // See https://github.com/tehzz/SSB64-Notes/blob/master/Universal/Model%20Display/Routine%20800F293C%20-%20renderCharModel.md#hurtbox-mooring
    scope fix_hitbox_position_: {
        OS.patch_start(0x6EB10, 0x800F3310)
        j       fix_hitbox_position_
        nop
        _fix_hitbox_position_return:
        OS.patch_end()

        li      at, Toggles.entry_special_model
        lw      at, 0x0004(at)              // at = 1 if hitbox_mode
        lli     t5, 0x0001                  // t5 = 1 (hitbox_mode)
        beq     at, t5, _check_screen       // if (hitbox_mode), check screen
        lli     t5, 0x0002                  // t5 = 2 (hitbox+model)
        beq     at, t5, _check_screen       // if (hitbox+model mode), check screen
        nop
        OS.read_word(kirby_cube_enabled, at)
        beqz    at, _original               // skip if Kirby cube not enabled
        nop

        _check_screen:
        li      at, Global.current_screen   // ~
        lb      at, 0x0000(at)              // at = screen id

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t5, at, 0x0010              // if (screen id < 0x10)...
        bnez    t5, _original               // ...then branch to original (not on a CSS)
        nop
        slti    t5, at, 0x0015              // if (screen id is between 0x10 and 0x14)...
        bnez    t5, _fix                    // ...then we're on a CSS
        nop
        addiu   t5, r0, 0x0018              // t5 = results screen id
        beq     t5, at, _fix                // if (screen id = results) then apply the fix
        nop
        addiu   t5, r0, 0x0030              // t5 = 1p leave in room screen id
        beq     t5, at, _fix                // if (screen id = results) then apply the fix
        nop                                 // ...otherwise just do the original:

        _original:
        addiu   at, r0, 0x03EA              // original line 1 - this is the key "mooring" value
        lw      t5, 0x0000(t7)              // original line 2
        j       _fix_hitbox_position_return  // return
        nop

        _fix:
        addiu   at, r0, 0x03EA              // original line 1 - this is the key "mooring" value
        addiu   t5, r0, 0x03EA              // intentionally set t5 equal to at
        j       _fix_hitbox_position_return  // return
        nop
    }

    // Fixes bug where star KO'd player stays indefinitely after last stock is lost when hitbox or ECB display is enabled
    OS.patch_start(0x6E1A0, 0x800F29A0)
    addu    t3, r0, r0
    OS.patch_end()

    // @ Description
    // Skips rendering hitboxes for Kirby Cube.
    scope skip_rendering_hitboxes_: {
        OS.patch_start(0x6EB6C, 0x800F336C)
        jal     skip_rendering_hitboxes_
        lw      t5, 0x0294(s6)              // original line 1
        OS.patch_end()

        lw      t3, 0x0B4C(s8)              // t3 = 4 if Kirby cube (or 3 if ecb)
        addiu   t3, t3, -0x0003             // t3 >= 0 if Kirby cube
        bgez    t3, _check_hitbox_mode      // if Kirby cube, check hitbox+
        addiu   s2, s6, 0x0294              // original line 2

        _normal:
        jr      ra
        addiu   s2, s6, 0x0294              // original line 2

        _check_hitbox_mode:
        OS.read_word(Toggles.entry_special_model + 4, v0) // v0 = 2 if hitbox+model
        addiu   v0, v0, -0x0002             // v0 = 0 if hitbox+model
        beqz    v0, _normal                 // if hitbox+, render normally
        nop

        _skip_rendering:
        j       0x800F3634                  // skip past rendering
        lw      t3, 0x0058(sp)              // original line 4
    }

    // Render ECB over hurtboxes for Kirby Cube
    scope render_ecb_over_hurtboxes_: {
        OS.patch_start(0x6EE48, 0x800F3648)
        jal     render_ecb_over_hurtboxes_
        OS.patch_end()

        // check if ecb and if so check if Kirby cube - still need to render ecb
        // OS.read_word(Toggles.entry_special_model + 4, v0) // v0 = 3 if ecb
        lw      v0, 0x0B4C(s8)              // v0 = model display mode
        addiu   v0, v0, -0x0003             // v0 = 0 if ecb
        bnez    v0, _end                    // skip if not ecb
        nop

        OS.read_word(kirby_cube_enabled, t2)
        beqz    t2, _end                    // skip if Kirby cube not enabled
        lw      t2, 0x0008(s8)              // t2 = char_id
        lli     t1, Character.id.KIRBY
        beql    t2, t1, _render_ecb         // if Kirby, set hitbox display
        lli     t1, Character.id.JKIRBY
        beql    t2, t1, _render_ecb         // if J Kirby, set hitbox display
        nop

        _end:
        jr      ra
        lw      v0, 0x0020(s8)              // original line 1

        _render_ecb:
        lli     t1, 0x0004                  // t1 = Kirby Cube
        lw      s6, 0x0004(s8)              // s6 = player object
        j       0x800F2FD8                  // jump to rendering ecb
        sw      v0, 0x0B4C(s8)              // set model display mode to Kirby Cube
    }

    // Loads Kirby Cube file if necessary
    scope setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, kirby_cube_enabled
        li      t0, CharacterSelectDebugMenu.PlayerTag.string_table + (8 * 4)
        lw      t0, 0x0000(t0)              // t0 = 8th tag
        lw      t0, 0x0000(t0)              // t0 = tag
        li      t1, 0x63756265
        bnel    t0, t1, _end                // if not equal, turn off Kirby Cube
        sw      r0, 0x0000(at)              // turn off Kirby Cube

        lli     t1, OS.TRUE                 // t1 = 1
        sw      t1, 0x0000(at)              // turn on Kirby Cube

        Render.load_file(File.KIRBY_CUBE, kirby_cube_file_pointer)

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    kirby_cube_enabled:
    dw OS.FALSE

    kirby_cube_file_pointer:
    dw 0
}

} // __HITBOX__
