// Item.asm
if !{defined __ITEM__} {
define __ITEM__()
print "included Item.asm\n"


// @ Description
// Allows the addition of custom items.

scope Item {
    // @ Description
    // Number of custom items
    constant NUM_ITEMS(26)

    // @ Description
    // Number of standard custom items
    constant NUM_STANDARD_ITEMS(11)

    // @ Description
    // Offsets to custom tables added to file 0xFE.
    constant TRAINING_MENU_IMAGE_TABLE(0x02A0)
    constant TRAINING_HUD_IMAGE_TABLE(0x0330)

    // @ Description
    // Holds routines for spawning custom items.
    extended_item_spawn_table:
    constant EXTENDED_ITEM_SPAWN_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds pointers to item info arrays for custom items.
    item_info_array_table:
    constant ITEM_INFO_ARRAY_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds routines for initializing item pickup.
    extended_item_pre_pickup_table:
    constant EXTENDED_ITEM_PRE_PICKUP_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds routines for handling item pickup.
    item_pickup_table:
    constant ITEM_PICKUP_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds routines for handling item drops when hit.
    item_drop_table:
    constant ITEM_DROP_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds routines for handling item collision with players.
    player_collision_table:
    constant PLAYER_COLLISION_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds routines for throwing custom items.
    extended_item_throw_table:
    constant ITEM_THROW_TABLE_ORIGIN(origin())
    fill NUM_ITEMS * 0x4

    // @ Description
    // Holds flags for determining if custom items should have the spawn gfx on spawn.
    spawn_gfx_table:
    constant SPAWN_GFX_TABLE_ORIGIN(origin())
    fill NUM_ITEMS
    OS.align(4)

    // @ Description
    // Keeps track of current custom item index for add_item macro.
    variable current_item(0)

    // @ Description
    // Macro for adding custom items.
    // @ Arguments
    // item - name of item
    // item_info_array - pc of item_info_array
    // item_info_array_origin - origin of item_info_array
    // spawn_routine - routine to run during item creation
    // show_gfx_when_spawned - flag whether to show gfx or not when spawned
    // main_pickup_routine - routine to run during item pickup
    // pre_pickup_routine - routine to run before item pickup
    // drop_routine - routine to run when item is dropped
    // throw_routine - toutine to run when item is thrown
    // collision_routine - routine to run during item collision (like star)
    macro add_item(item, item_info_array, item_info_array_origin, spawn_routine, show_gfx_when_spawned, main_pickup_routine, pre_pickup_routine, drop_routine, throw_routine, collision_routine) {
        evaluate n(current_item)
        evaluate item_id(current_item + 0x2D)

        constant {item}.id({item_id})

        pushvar origin, base

        // update item info array
        origin {item_info_array_origin}
        dw {item_id}

        // update spawn routine table
        origin EXTENDED_ITEM_SPAWN_TABLE_ORIGIN + (current_item * 0x4)
        dw {spawn_routine}

        // update item info table
        origin ITEM_INFO_ARRAY_TABLE_ORIGIN + (current_item * 0x4)
        dw {item_info_array}

        // update item pickup routine table
        origin ITEM_PICKUP_TABLE_ORIGIN + (current_item * 0x4)
        dw {main_pickup_routine}

        // update item drop routine table
        origin ITEM_DROP_TABLE_ORIGIN + (current_item * 0x4)
        dw {drop_routine}

        // update item throw routine table
        origin ITEM_THROW_TABLE_ORIGIN + (current_item * 0x4)
        dw {throw_routine}

        // update item player collision routine table
        origin PLAYER_COLLISION_TABLE_ORIGIN + (current_item * 0x4)
        dw {collision_routine}

        // update item pre-pickup routine table
        origin EXTENDED_ITEM_PRE_PICKUP_TABLE_ORIGIN + (current_item * 0x4)
        dw {pre_pickup_routine}

        // update spawn GFX table
        origin SPAWN_GFX_TABLE_ORIGIN + current_item
        db {show_gfx_when_spawned}

        pullvar base, origin

        global variable current_item(current_item + 1)
    }

    // @ Description
    // Adds an item from a scope name.
    // (Can be thought of as implementing an Item interface.)
    // @ Arguments
    // item - the name of the scope containing the required constants and routines
    macro add_item(item) {
        add_item({item}, {item}.item_info_array, {item}.ITEM_INFO_ARRAY_ORIGIN, {item}.SPAWN_ITEM, {item}.SHOW_GFX_WHEN_SPAWNED, {item}.PICKUP_ITEM_MAIN, {item}.PICKUP_ITEM_INIT, {item}.DROP_ITEM, {item}.THROW_ITEM, {item}.PLAYER_COLLISION)
    }

    // @ Description
    // Checks the item ID for a custom item during item creation.
    scope extend_item_spawn_: {
        OS.patch_start(0xE94C4, 0x8016EA84)
        j       extend_item_spawn_
        lui     t8, 0x8019                      // original line 1
        _extend_item_spawn_return:
        OS.patch_end()

        // t6 = item ID

        sltiu   t7, t6, 0x002D                  // t7 = 0 if custom item ID
        bnez    t7, _normal                     // if a vanilla item, continue normally
        nop

        li      t8, extended_item_spawn_table   // t8 = extended table
        j       _extend_item_spawn_return
        addiu   t6, t6, -0x002D                 // t6 = index in extended table

        _normal:
        j       _extend_item_spawn_return
        addiu   t8, t8, 0x946C                  // original line 2
    }

    // @ Description
    // Checks the item ID for a custom item during item creation to determine if it should show spawn gfx.
    scope extend_item_spawn_gfx_: {
        OS.patch_start(0xE9508, 0x8016EAC8)
        jal     extend_item_spawn_gfx_
        addiu   t0, t0, 0x94BC                  // original line 1
        OS.patch_end()

        // v0 = item object
        lw      t1, 0x0084(v0)                  // t1 = item special struct
        lw      t1, 0x000C(t1)                  // t1 = item ID
        sltiu   at, t1, 0x002D                  // at = 0 if custom item ID
        bnez    at, _normal                     // if a vanilla item, continue normally
        addiu   t1, t1, -0x002D                 // t1 = index in extended table
        li      at, spawn_gfx_table             // at = extended table
        addu    t1, at, t1                      // t1 = address of spawn gfx flag
        jr      ra
        lbu     at, 0x0000(t1)                  // at = 0 if do not spawn gfx, 1 if yes

        _normal:
        jr      ra
        sltu    at, v1, t0                      // original line 2
    }

    // @ Description
    // Checks the item ID for a custom item during the start of item pickup.
    scope extend_item_pre_pickup_table_: {
        OS.patch_start(0xED814, 0x80172DD4)
        j       extend_item_pre_pickup_table_
        lui     v0, 0x8019                      // original line 1
        _extend_item_pre_pickup_table_return_normal:
        addu    v0, v0, t8                      // original line 3
        lw      v0, 0x95D0(v0)                  // original line 4
        _extend_item_pre_pickup_table_return_custom:
        OS.patch_end()

        // t7 = item ID

        sltiu   t8, t7, 0x002D                  // t8 = 0 if custom item ID
        bnez    t8, _normal                     // if a vanilla item, continue normally
        nop

        li      v0, extended_item_pre_pickup_table   // v0 = extended table
        addiu   t8, t7, -0x002D                 // t8 = index in extended table
        sll     t8, t8, 2                       // t8 = offset in extended table
        addu    v0, v0, t8                      // original line 3
        j       _extend_item_pre_pickup_table_return_custom
        lw      v0, 0x0000(v0)                  // original line 4, modified

        _normal:
        j       _extend_item_pre_pickup_table_return_normal
        sll     t8, t7, 0x0002                  // original line 2
    }

    // @ Description
    // Checks the item ID for a custom item when being thrown.
    scope extend_item_throw_table: {
        OS.patch_start(0xED648, 0x80172C08)
        j       extend_item_throw_table
        sll     t3, t2, 2                       // original line
        _return_normal:
        _return:
        nop
        OS.patch_end()

        // t2 = item ID

        sltiu   t6, t2, 0x002D                  // t6 = 0 if custom item ID
        bnez    t6, _normal                     // if a vanilla item, continue normally
        nop

        li      v0, extended_item_throw_table   // t8 = extended table
        addiu   t2, t2, -0x002D                 // t2 = index in extended table
        sll     t3, t2, 2                       // original line 2
        addu    v0, v0, t3                      // v0 = pointer to throw routine

        j       _return
        lw      v0, 0x0000(v0)

        _normal:
        addu    v0, v0, t3                      // v0 = pointer to throw routine
        j       _return_normal
        lw      v0, 0x9578 (v0)                 // original line 3

    }

    // @ Description
    // Extends Training Mode Item menu.
    scope extend_training_mode_item_menu_: {
        evaluate maxIndex(0x0011 + NUM_STANDARD_ITEMS)

        // increase the index for the the Item menu
        OS.patch_start(0x113D50, 0x8018D530)
        addiu   a2, r0, {maxIndex}
        OS.patch_end()

        // fix item ID when selected
        OS.patch_start(0x113E54, 0x8018D634)
        jal     extend_training_mode_item_menu_._get_selected_item_id
        swc1    f0, 0x003C(sp)                  // original line 1
        OS.patch_end()

        // get custom item name for menu
        OS.patch_start(0x11586C, 0x8018F04C)
        j       extend_training_mode_item_menu_._get_custom_menu_image
        lw      t6, 0x005C(v1)                  // original line 1
        _return_get_custom_menu_image:
        OS.patch_end()

        _get_selected_item_id:
        // a1 = training menu index
        sltiu   t0, a1, 0x0011                  // t0 = 1 if vanilla item, 0 if custom
        beqzl   t0, pc() + 8                    // if a custom item, then adjust the ID
        addiu   a1, a1, 0x0019                  // adjust ID

        jr      ra
        addiu   a1, a1, 0x0003                  // original line 2

        _get_custom_menu_image:
        sltiu   t9, t8, 0x0011                  // t9 = 1 if vanilla item, 0 if custom
        bnezl   t9, _menu_image_return          // if a vanilla item, then return normally
        lw      t7, 0x0030(v1)                  // original line 1

        // We need to add a req file entry to the end of file 0xFE for each added item.
        // It will point to the custom item's menu name image, which is likely just going to be appended to file 0x1D.
        lw      t9, 0x0024(v1)                  // t9 = file 0xFE address
        addiu   t7, t9, TRAINING_MENU_IMAGE_TABLE // t7 = address of custom item name image table
        addiu   t8, t8, -0x0011                 // t8 = index in custom item name image table

        _menu_image_return:
        j       _return_get_custom_menu_image
        nop
    }

    // @ Description
    // Extends Training Mode HUD for held item.
    scope extend_training_mode_hud_: {
        // fix item ID check
        OS.patch_start(0x11522C, 0x8018EA0C)
        j       extend_training_mode_hud_._fix_item_id_check
        nop
        _return_fix_item_id_check:
        OS.patch_end()

        // get custom item name image
        OS.patch_start(0x115150, 0x8018E930)
        j       extend_training_mode_hud_._get_custom_image
        lw      v1, 0x0008(v0)                  // original line 2
        _return_get_custom_image:
        OS.patch_end()

        _fix_item_id_check:
        bnez    at, _less_than_4                // if at = 1, item ID < 4, so return
        slti    at, a1, 0x0014                  // original line 2

        bnez    at, _display_item_image         // if a vanilla item ID < 14, display item image
        sltiu   at, a1, Item.KlapTrap.id        // at = 0 if remix stage/character item

        beqz    at, _no_image                   // if a item ID > KlapTap, don't display item image
        sltiu   at, a1, 0x002D                  // at = 1 if vanilla item, 0 if custom

        beqz    at, _display_item_image         // if a custom item ID, display item image
        nop

        _no_image:
        j       0x8018EA48                      // jump here to not draw item image
        nop

        _display_item_image:
        j       0x8018EA40                      // jump here to draw item image
        nop

        _less_than_4:
        j       _return_fix_item_id_check
        nop

        _get_custom_image:
        // t9 = item_id - 3
        sltiu   t2, t9, 0x2A                    // t2 = 1 if vanilla item, 0 if custom
        bnezl   t2, _done                       // if vanilla item, then use original line
        lw      t2, 0x0028(t1)                  // original line 1

        // We need to add a req file entry to the end of file 0xFE for each added item.
        // It will point to the custom item's HUD name image, which is likely just going to be appended to file 0x1D.
        lw      t8, 0x0024(a0)                  // t8 = file 0xFE address
        addiu   t8, t8, TRAINING_HUD_IMAGE_TABLE // t8 = address of custom item name image table
        addiu   t0, t9, -0x002A                 // t0 = index in custom item name image table
        sll     t0, t0, 0x0002                  // t0 = offset to item name image
        addu    t1, t8, t0                      // t1 = address of item name image pointer
        lw      t2, 0x0000(t1)                  // t2 = custom item image footer

        _done:
        j       _return_get_custom_image
        nop
    }

    // @ Description
    // Spawns a custom item.
    // Heavily based off of Maxim Tomato and Heart spawn code.
    scope spawn_custom_item_based_on_tomato_: {
        // We just need to update a1 to be the custom item's item info array.

        OS.copy_segment(0xEF064, 0x1C)

        // Look up item info array address using item ID
        li      a3, item_info_array_table
        lw      t7, 0x0064(sp)                  // t7 = item ID
        addiu   a1, t7, -0x002D                 // a1 = index in item_info_array_table
        sll     a1, a1, 0x0002                  // a1 = offset in item_info_array_table
        addu    a3, a3, a1                      // a3 = address of item info array pointer
        lw      a1, 0x0000(a3)                  // a1 = item info array pointer

        lw      a3, 0x0048(sp)                  // original line 9
        OS.copy_segment(0xEF08C, 0xA4)
    }

    // @ Description
    // Hook into routine that checks if tomato or heart was picked up.
    // Enables us to put a custom item ID check.
    // This only runs when the item pickup type is 5. Check 0x10 in the item special struct (0x84 in item object).
    scope item_pickup_check_: {
        OS.patch_start(0xC0654, 0x80145C14)
        jal     item_pickup_check_
        or      a0, a3, r0                      // original line 2
        OS.patch_end()

        // v0 = item ID
        sltiu   at, v0, 0x002D                  // at = 0 if custom item ID
        bnez    at, _normal                     // if a vanilla item, continue normally
        addiu   at, v0, -0x002D                 // otherwise, we'll use the custom item index to get the routine to run

        li      a1, item_pickup_table
        sll     at, at, 0x0002                  // at = offset to pickup routine
        addu    a1, a1, at                      // a1 = address of pickup routine
        lw      at, 0x0000(a1)                  // at = routine to run

        // a0 = player struct
        // a2 = item object
        // a3 = player struct
        jr      at                              // jump to routine - note that the routine must handle where to return
        nop

        _normal:
        jr      ra
        addiu   at, r0, 0x0004                  // original line 1
    }

    // @ Description
    // Hook into routine that determines next action after any item pickup
    // This allows us to change the players action to up-throw upon picking up a custom "usable" item
    // To set an item to this type, set the pickup type to 0x1C in 0xFB. (local offset is 0x3E from beginning of item entry)
    scope extend_item_pickup_check_: {
        OS.patch_start(0xC08C4, 0x80145E84)
        j       extend_item_pickup_check_
        nop
        _return:
        OS.patch_end()

        // at = item type 5 (tomato)
        beq     t0, at, _edible
        nop

        addiu   at, r0, 0x0007
        beq     t0, at, _usable
        nop

        // if here, assign item as normal
        _hold:
        j       0x80145EC0
        nop

        _usable:
        // a0 = player object

        addiu   sp, sp, -0x28
        sw      ra, 0x0004(sp)

        li      a1, Action.ItemThrowU         // a1 = action id to transition to
        addiu   a2, r0, 0x0000                // a2(starting frame) = 0
        sw      r0, 0x0010(sp)                // ?
        lui     a3, 0x3F40                    // a3(frame speed multiplier) =

        sw      v0, 0x0024(sp)

        jal     0x800E6F24                    // change action
        addiu   v0, r0, 0x0001                // argument needs to be set to 1

        lw      v0, 0x0024(sp)

        lw      ra, 0x0014(sp)

        lw      a0, 0x0000(sp)                // restore a0
        jal     0x800E0830                    // unknown, common
        sw      a2, 0x001C(sp)                // save a2
        lw      a2, 0x001C(sp)                // restore a2

        jal     0x80146670                    // idk, related to throw or crash
        lw      a0, 0x0084(a0)                // a0 = player

        lw      a0, 0x0000(sp)                // restore a0
        lw      a2, 0x001C(sp)                // restore a2
        lw      v0, 0x0024(sp)                // restore v0

        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x28

        j       0x80145EC8                    // jump to normal end of this routine
        nop

        // jump back to routine as normal
        _edible:
        j        _return
        nop
    }

    // @ Description
    // Hook into routine that checks if tomato or heart was picked up.
    // Enables us to put a custom item ID check.
    // This only runs when the item pickup type is 5. Check 0x10 in the item special struct (0x84 in item object).
    scope extend_item_drop_check_: {
        OS.patch_start(0xED554, 0x80172B14)
        jal     extend_item_drop_check_
        lw      t0, 0x0084(v1)                  // original line 2
        OS.patch_end()

        // t6 = item ID
        sltiu   t7, t6, 0x002D                  // t7 = 0 if custom item ID
        bnez    t7, _normal                     // if a vanilla item, continue normally
        addiu   t7, t6, -0x002D                 // otherwise, we'll use the custom item index to get the routine to run

        li      t8, item_drop_table
        sll     t7, t7, 0x0002                  // t7 = offset to drop routine
        addu    t8, t8, t7                      // t8 = address of drop routine
        lw      a2, 0x0000(t8)                  // a2 = routine to run

        jr      ra                              // return
        nop

        _normal:
        jr      ra
        lw      a2, 0x9520(a2)                  // original line 1
    }

    // @ Description
    // Hook into routine that checks if player collided with a star.
    // Enables us to put a custom item ID check.
    scope extend_player_collision_check_: {
        OS.patch_start(0x5F218, 0x800E3A18)
        jal     extend_player_collision_check_
        addiu   v0, r0, 0x0001                  // original line 2
        OS.patch_end()

        // a2 = item ID
        sltiu   at, a2, 0x002D                  // at = 0 if custom item ID
        bnez    at, _normal                     // if a vanilla item, continue normally
        addiu   at, a2, -0x002D                 // otherwise, we'll use the custom item index to get the routine to run

        li      a1, player_collision_table
        sll     at, at, 0x0002                  // at = offset to collision routine
        addu    a1, a1, at                      // a1 = address of collision routine
        lw      at, 0x0000(a1)                  // at = routine to run
        beqz    at, _normal                     // if no routine defined, continue normally
        nop

        // a0 = player struct
        // a2 = item ID
        // s0 = item special struct
        jr      at                              // jump to routine - note that the routine must handle where to return
        sw      v0, 0x0264(s0)                  // set flag on object to destroy item object

        _normal:
        jr      ra
        addiu   at, r0, 0x0006                  // original line 1
    }

    // @ Description
    // Extends VS item spawning to include custom items.
    scope extend_vs_item_spawning_: {
        // extend item spawn - rate sum
        scope rate_sum_: {
            OS.patch_start(0xE96E4, 0x8016ECA4)
            jal     extend_vs_item_spawning_.rate_sum_
            srl     v0, v0, 0x0001                  // original line 2
            OS.patch_end()

            // at = 0 if custom item, 1 if vanilla item
            bnez    at, _loop_vanilla               // if vanilla item, loop normally
            sltiu   at, v1, 0x14 + NUM_ITEMS        // at = 1 if custom item, 0 if none left
            beqz    at, _exit_loop                  // if custom item, exit loop
            nop

            li      a0, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t0, NUM_ITEMS                   // t0 = NUM_ITEMS
            multu   at, t0                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    a0, a0, at                      // a0 = custom item rate array for this stage
            addiu   a0, a0, -0x0014                 // a0 = custom item rate array for this stage, adjusted

            _loop_vanilla:
            j       0x8016EC88                      // original line 1, modified to be a jump
            nop

            _exit_loop:
            jr      ra
            nop
        }

        // extend item spawn - item count
        scope item_count_: {
            OS.patch_start(0xE98A0, 0x8016EE60)
            jal     extend_vs_item_spawning_.item_count_
            srl     a0, a0, 0x0001                  // original line 2
            OS.patch_end()

            // at = 0 if custom item, 1 if vanilla item
            bnez    at, _loop_vanilla               // if vanilla item, loop normally
            sltiu   at, v1, 0x14 + NUM_ITEMS        // at = 1 if custom item, 0 if none left
            beqz    at, _exit_loop                  // if custom item, exit loop
            nop

            li      a3, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t5, NUM_ITEMS                   // t5 = NUM_ITEMS
            multu   at, t5                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    a3, a3, at                      // a3 = custom item rate array for this stage
            addiu   a3, a3, -0x0014                 // a3 = custom item rate array for this stage, adjusted

            _loop_vanilla:
            j       0x8016EE3C                      // original line 1, modified to be a jump
            nop

            _exit_loop:
            jr      ra
            lw      a3, 0x0084(t7)                  // restore original a3 (vanilla item rate array)
        }

        // extend item spawn - item IDs and rate ranges
        scope item_arrays_: {
            OS.patch_start(0xE9954, 0x8016EF14)
            jal     extend_vs_item_spawning_.item_arrays_
            srl     a0, a0, 1                       // original line 2
            OS.patch_end()

            bne     v1, t1, _loop_vanilla           // if valid item, loop normally
            lli     at, 0x0014                      // at = 0x0014, the original t1
            bne     at, t1, _exit_loop              // if v1 = at and at != 0x0014, then we are done with custom item looping so exit loop
            lli     t1, 0x002D + NUM_ITEMS          // update t1 so loop continues for custom items

            li      a3, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t5, NUM_ITEMS                   // t5 = NUM_ITEMS
            multu   at, t5                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    a3, a3, at                      // a3 = custom item rate array for this stage
            addiu   a3, a3, -0x002D                 // a3 = custom item rate array for this stage, adjusted

            lli     v1, 0x002D                      // v1 = first custom item ID

            _loop_vanilla:
            j       0x8016EED0                      // original line 1, modified to be a jump
            nop

            _exit_loop:
            jr      ra
            nop
        }

        // extend exploded crate/barrel/egg/capsule item generation - rate sum
        scope rate_sum_item_generators_: {
            OS.patch_start(0xE99EC, 0x8016EFAC)
            jal     extend_vs_item_spawning_.rate_sum_item_generators_
            srl     v0, v0, 0x0001                  // original line 2
            OS.patch_end()

            // at = 0 if custom item, 1 if vanilla item
            bnez    at, _loop_vanilla               // if vanilla item, loop normally
            sltiu   at, v1, 0x14 + NUM_ITEMS        // at = 1 if custom item, 0 if none left
            beqz    at, _exit_loop                  // if custom item, exit loop
            nop

            li      a1, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t0, NUM_ITEMS                   // t0 = NUM_ITEMS
            multu   at, t0                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    a1, a1, at                      // a1 = custom item rate array for this stage
            addiu   a1, a1, -0x0014                 // a1 = custom item rate array for this stage, adjusted

            _loop_vanilla:
            j       0x8016EF90                      // original line 1, modified to be a jump
            nop

            _exit_loop:
            jr      ra
            nop
        }

        // extend exploded crate/barrel/egg/capsule item generation - item count
        scope item_count_item_generators_: {
            OS.patch_start(0xE9A3C, 0x8016EFFC)
            jal     extend_vs_item_spawning_.item_count_item_generators_
            srl     a0, a0, 0x0001                  // original line 2
            OS.patch_end()

            // at = 0 if custom item, 1 if vanilla item
            bnez    at, _loop_vanilla               // if vanilla item, loop normally
            sltiu   at, v1, 0x14 + NUM_ITEMS        // at = 1 if custom item, 0 if none left
            beqz    at, _exit_loop                  // if custom item, exit loop
            nop

            li      t1, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t5, NUM_ITEMS                   // t5 = NUM_ITEMS
            multu   at, t5                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    t1, t1, at                      // t1 = custom item rate array for this stage
            addiu   t1, t1, -0x0014                 // t1 = custom item rate array for this stage, adjusted

            _loop_vanilla:
            j       0x8016EFD8                      // original line 1, modified to be a jump
            nop

            _exit_loop:
            jr      ra
            lw      t1, 0x0084(t3)                  // restore original t1 (vanilla item rate array)
        }

        // extend exploded crate/barrel/egg/capsule item generation - item IDs and rate ranges
        scope item_arrays_item_generators_: {
            OS.patch_start(0xE9BD0, 0x8016F190)
            jal     extend_vs_item_spawning_.item_arrays_item_generators_
            lw      t9, 0x000C(t0)                  // original line 1
            OS.patch_end()

            // here, loop over custom items and for any with non-zero rates and item switch on, add to arrays
            // t0 = item spawn struct for crate/barrel/egg/capsule
            // a3 = index of next ID in ID array
            // a1 = offset of previous item's rate upper bounds
            // a2 = running rate sum, currently holding what should be at a1

            li      t1, Stages.custom_item_spawn_rate_table
            li      at, Global.match_info
            lw      at, 0x0000(at)                  // at = match info
            lbu     at, 0x0001(at)                  // at = stage_id
            lli     t2, NUM_ITEMS                   // t2 = NUM_ITEMS
            multu   at, t2                          // at = offset to custom item rate array for this stage
            mflo    at                              // ~
            addu    t1, t1, at                      // t1 = custom item rate array for this stage
            addiu   t1, t1, -0x002D                 // t1 = custom item rate array for this stage, adjusted

            lli     v1, 0x002D                      // v1 = first custom item ID

            _loop:
            // first check if item is on
            andi    t8, a0, 0x0001                  // t8 = 1 if item is on
            beqz    t8, _next                       // skip if item is off

            // then check if item has a non-zero rate
            addu    v0, t1, v1                      // v0 = address of rate
            lbu     t7, 0x0000(v0)                  // t7 = rate
            beqz    t7, _next                       // skip if rate is 0
            lw      t4, 0x000C(t0)                  // t4 = item ID array
            addu    t6, t4, a3                      // t6 = address of this item ID
            sb      v1, 0x0000(t6)                  // set custom item ID

            lw      t5, 0x0014(t0)                  // t5 = rate range array
            addu    t8, t5, a1                      // t8 = address of rate range upper bound from previous item
            sh      a2, 0x0000(t8)                  // save previous item's upper bound
            addu    a2, a2, t7                      // a2 = updated upper bound

            addiu   a3, a3, 0x0001                  // a3++
            addiu   a1, a1, 0x0002                  // a1 += 2

            _next:
            addiu   v1, v1, 0x0001                  // v1++
            sltiu   t2, v1, 0x002D + NUM_ITEMS      // t2 = 1 if more items to loop over
            bnez    t2, _loop                       // if still more custom items to loop over, continue looping
            srl     a0, a0, 1                       // a0 = shifted bit mask for items on/off

            _exit_loop:
            jr      ra
            addiu   t4, r0, 0x0020                  // original line 2
        }

        // fix item ID checks for item generators
        scope fix_item_id_check_item_generators_: {
            // crate/barrel bust
            OS.patch_start(0xF3EC8, 0x80179488)
            jal     extend_vs_item_spawning_.fix_item_id_check_item_generators_._crate_barrel
            or      s6, v0, r0                      // original line 2
            OS.patch_end()

            // capsule/egg bust (maybe also sometimes crate/barrel?)
            OS.patch_start(0xEDB3C, 0x801730FC)
            jal     extend_vs_item_spawning_.fix_item_id_check_item_generators_._egg_capsule
            or      a1, v0, r0                      // original line 2
            OS.patch_end()

            _crate_barrel:
            // at = 0 if custom item (maybe), 1 if vanilla item
            bnez    at, _valid_item                 // if vanilla item, continue normally
            sltiu   at, v0, 0x002D                  // at = 1 = not a custom item (probably means a dud), 0 = custom item
            beqz    at, _valid_item                 // if custom item, treat as valid
            nop

            j       0x80179608
            nop

            _egg_capsule:
            // at = 0 if custom item (maybe), 1 if vanilla item
            bnez    at, _valid_item                 // if vanilla item, continue normally
            sltiu   at, v0, 0x002D                  // at = 1 = not a custom item (probably means a dud), 0 = custom item
            beqz    at, _valid_item                 // if custom item, treat as valid
            nop

            j       0x8017316C
            nop

            _valid_item:
            jr      ra
            nop
        }
    }

    // @ Description
    // Prevent custom items from spawning in 1P mode
    scope prevent_1p_custom_item_spawns_: {
        OS.patch_start(0x10BF5C, 0x8018D6FC)
        j       prevent_1p_custom_item_spawns_
        lw      t7, 0x0000(s6)                         // original line 2
        _return:
        OS.patch_end()

        // t6 is free
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)                         // t6 = singleplayer mode ID
        addiu   t6, t6, -SinglePlayerModes.ALLSTAR_ID  // t6 = 0 if Remix 1P
        beqz    t6, _allstar                           // if Allstar, prevent Heart and Tomato spawning
        nop                                            // otherwise, ensure vanilla 1P does not spawn custom items
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)                         // t6 = singleplayer mode ID
        addiu   t6, t6, -SinglePlayerModes.REMIX_1P_ID // t6 = 0 if Remix 1P
        beqz    t6, _end                               // if Remix 1P, allow custom items
        nop                                            // otherwise, ensure vanilla 1P does not spawn custom items

        li      t6, 0x000FFFFF                         // t6 = bitmask that keeps vanilla items but 0s out custom items
        beq     r0, r0, _end
        and     t4, t4, t6                             // t4 = item bitmask with custom items zeroed out

        _allstar:
        addiu   t6, r0, -0x0031                        // t6 = 0xFFFFFFCF = bitmask that keeps healing items out
        and     t4, t4, t6                             // t4 = item bitmask with healing items zeroed out

        _end:
        j       _return
        sw      t4, 0x000C(t5)                         // original line 1
    }

    // @ Description
    // Item Switch page - use free space
    constant ITEM_SWITCH_PAGE(0x80133470)

    // @ Description
    // Custom item list image pointer - use free space
    constant CUSTOM_ITEM_IMAGE(0x80133474)

    // @ Description
    // Custom item on/off value array - use free space
    constant CUSTOM_ON_OFF_ARRAY(0x80133478)

    // @ Description
    // Vanilla item on/off value array
    constant VANILLA_ON_OFF_ARRAY(0x80133424)

    // @ Description
    // Message/visual indicator to press L to toggle all items ON/OFF
    toggle_all_items:; db ": All On/Off", 0x00
    OS.align(4)

    // @ Description
    // Sets up the custom objects for the custom items and pagination legend
    scope item_switch_setup_: {
        addiu   sp, sp,-0x0030                      // allocate stack space
        sw      ra, 0x0004(sp)                      // ~

        Render.load_file(0x00, Render.file_pointer_1) // load main menu images into file_pointer_1
        Render.load_file(0xC5, Render.file_pointer_2) // load button images into file_pointer_2

        // R button and right arrow for pagination legend
        Render.draw_texture_at_offset(3, 12, Render.file_pointer_2, Render.file_c5_offsets.R, Render.NOOP, 0x43880000, 0x42190000, 0x848484FF, 0x303030FF, 0x3F400000)
        Render.draw_texture_at_offset(3, 12, Render.file_pointer_1, 0xDD90, Render.NOOP, 0x43900000, 0x42240000, 0xFFAE00FF, 0x00000000, 0x3F2F0000)

        // L button and text for toggling all items ON/OFF
        Render.load_font()
        Render.draw_texture_at_offset(3, 12, Render.file_pointer_2, Render.file_c5_offsets.L, Render.NOOP, 0x434A0000, 0x42190000, 0x848484FF, 0x303030FF, 0x3F400000)
        Render.draw_string(3, 12, toggle_all_items, Render.NOOP, 0x43560000, 0x421E0000, 0xC0C0C0FF, 0x3F2147AE, Render.alignment.LEFT)

        // Custom item list image
        Render.draw_texture_at_offset(3, 12, 0x80133530, 0xBD70, Render.NOOP, 0x42FA0000, 0x42400000, 0xFFFFFFFF, 0x0, 0x3F800000)
        li      at, CUSTOM_ITEM_IMAGE
        sw      v0, 0x0000(at)                      // save pointer
        lli     at, 0x0001                          // at = 1 (display off)
        sw      at, 0x007C(v0)                      // initialize display off

        lw      ra, 0x0004(sp)                      // restore ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Extends the item switch bitmask code to use custom items.
    scope extend_item_switch_bitmask_: {
        // initialize from bitmask
        scope initialize_: {
            OS.patch_start(0x128D48, 0x801327A8)
            j       extend_item_switch_bitmask_.initialize_
            addiu   v1, v1, 0x0010                      // original line 2
            OS.patch_end()

            bne     a1, a2, _continue_loop              // if still more addresses to process, continue original loop
            nop

            // here, loop over the bitmask for each remaining item, and store the values in free space
            // a0 = bitmask

            lli     t4, 0x0014                          // t4 = starting index of custom items in the bitmask
            lli     t1, 0x0001                          // t1 = 1
            li      a1, CUSTOM_ON_OFF_ARRAY             // a1 = address of custom item ON/OFF value array
            _loop:
            sllv    t7, t1, t4                          // t7 = bitmask for checking if current item is on
            and     t6, t7, a0                          // t6 = 0 if off, otherwise it's on
            lli     v0, 0x0001                          // v0 = 1 (on)
            beqzl   t6, pc() + 8                        // if item should be off, set v0 to 0
            lli     v0, 0x0000                          // v0 = 0 (off)
            sw      v0, 0x0000(a1)                      // save value
            addiu   a1, a1, 0x0004                      // a1++
            addiu   t4, t4, 0x0001                      // t4++
            sltiu   at, t4, NUM_STANDARD_ITEMS + 0x14            // at = 0 if done looping
            bnez    at, _loop
            nop

            jr      ra
            nop

            _continue_loop:
            j       0x80132714                          // original line 1, modified to jump
            nop
        }

        // save to bitmask
        scope save_: {
            OS.patch_start(0x129024, 0x80132A84)
            j       extend_item_switch_bitmask_.save_
            lw      ra, 0x0014(sp)                      // original line 1
            OS.patch_end()

            lw      a0, 0x000C(v0)                      // a0 = current bitmask

            // here, loop over custom item on/off values and update bitmask
            lli     t4, 0x0014                          // t4 = starting index of custom items in the bitmask
            lli     t1, 0x0001                          // t1 = 1
            li      a1, CUSTOM_ON_OFF_ARRAY             // a1 = address of custom item ON/OFF value array
            _loop:
            sllv    t7, t1, t4                          // t7 = bitmask if current item is on
            lw      t8, 0x0000(a1)                      // t8 = 1 if should be on, 0 if should be off
            beqz    t8, _off                            // if should be off, jump to _off
            nop                                         // otherwise, we just or it in
            b       _next
            or      a0, a0, t7                          // a0 = new bitmask
            _off:
            nor     t8, t7, r0                          // t8 = flipped mask
            and     a0, a0, t8                          // a0 = new bitmask
            _next:
            addiu   a1, a1, 0x0004                      // a1++
            addiu   t4, t4, 0x0001                      // t4++
            sltiu   at, t4, NUM_STANDARD_ITEMS + 0x14   // at = 0 if done looping
            bnez    at, _loop
            sw      a0, 0x000C(v0)                      // save mask

            lui     at, 0x8013                          // at = item frequency
            lw      at, 0x3420(at)                      // ~
            beqz    a0, _return                         // if 0, skip saving the frequency and adding containers
            nop
            sb      at, 0x001C(v0)                      // save frequency
            ori     a0, a0, 0x000F                      // enable barrels, capsules, etc.
            sw      a0, 0x000C(v0)                      // save mask

            _return:
            jr      ra                                  // original line 3
            addiu   sp, sp, 0x0018                      // original line 2
        }
    }

    // @ Description
    // Modifies cursor movement and enables pagination
    // Also allows L button to toggle all items ON/OFF
    scope item_switch_cursor_: {
        // disable default R button functionality
        OS.patch_start(0x129450, 0x80132EB0)
        addiu   a0, r0, 0x0101                      // original mask was 0x0111
        OS.patch_end()
        // disable default L button functionality
        OS.patch_start(0x129330, 0x80132D90)
        addiu   a0, r0, 0x0202                      // original mask was 0x0222
        OS.patch_end()
        // handle R or L press
        scope handle_r_l_: {
            OS.patch_start(0x129620, 0x80133080)
            j       item_switch_cursor_.handle_r_l_
            addiu   sp, sp, 0x0028                      // original line 2 (necessary to keep for jumps to this line)
            OS.patch_end()

            addiu   sp, sp, -0x0028                     // allocate stack space

            jal     0x8039076C
            addiu   a0, r0, Joypad.L                    // check for L press
            bnez    v0, _toggle_items_on_off            // if pressed, branch accordingly
            nop

            jal     0x8039076C
            addiu   a0, r0, Joypad.R                    // check for R press
            beqz    v0, _return                         // if not pressed, skip
            lui     a1, 0x8013
            lw      a1, 0x33D8(a1)                      // a1 = row

            li      at, ITEM_SWITCH_PAGE
            lw      t0, 0x0000(at)                      // t0 = page
            xori    t0, t0, 0x0001                      // t0 = 0 -> 1, 1 -> 0
            sw      t0, 0x0000(at)                      // update page

            beqz    t0, _default                        // if on page 0 now, draw original stuff
            nop

            // hide vanilla item list image
            li      t0, Render.GROUP_TABLE
            lw      t0, 0x000C(t0)                      // t0 = first object in group 3
            lw      t0, 0x0004(t0)                      // t0 = second object in group 3 = item list image
            lli     t1, 0x0001                          // t1 = 0x0001 (display off)
            sw      t1, 0x007C(t0)                      // hide

            // show custom image list
            li      at, CUSTOM_ITEM_IMAGE
            lw      at, 0x0000(at)                      // at = custom item image object
            sw      r0, 0x007C(at)                      // show

            // hide unneeded ON/OFF images
            li      t0, 0x801333E4                      // t0 = address of pointer to first ON/OFF object
            addiu   t2, t0, NUM_STANDARD_ITEMS * 4               // t2 = address of pointer to first ON/OFF object that should be hidden
            _loop:
            lw      t3, 0x0000(t2)                      // t3 = ON/OFF object to hide
            sw      t1, 0x007C(t3)                      // hide ON/OFF object
            addiu   t2, t2, 0x0004                      // t2 = address of pointer to next ON/OFF object to hide
            lbu     t3, 0x0000(t2)                      // t3 = 0 if we're at the values, 0x80 otherwise
            bnez    t3, _loop                           // loop while there is a next ON/OFF object
            nop

            // ensure cursor is not past last row
            sltiu   t1, a1, NUM_STANDARD_ITEMS + 1               // t1 = 1 if valid row
            beqzl   t1, pc() + 8                        // if not a valid row, set to last row
            lli     a1, NUM_STANDARD_ITEMS
            lui     t1, 0x8013
            sw      a1, 0x33D8(t1)                      // update row

            // initialize ON/OFF display
            li      a0, CUSTOM_ON_OFF_ARRAY             // a0 = address of first on/off value
            jal     initialize_on_off_display_
            nop

            b       _end
            nop

            _default:
            // show all vanilla images
            lli     a0, 0x0003                          // a0 = group 3
            jal     Render.toggle_group_display_
            lli     a1, 0x0000                          // a1 = show

            // hide custom image list
            li      at, CUSTOM_ITEM_IMAGE
            lw      at, 0x0000(at)                      // at = custom item image object
            lli     v0, 0x0001                          // v0 = 1 (display off)
            sw      v0, 0x007C(at)                      // hide

            // initialize ON/OFF display
            li      a0, 0x80133424                      // a0 = address of first on/off value
            jal     initialize_on_off_display_
            nop

            _end:
            // update cursor
            lui     a1, 0x8013
            lw      a1, 0x33D8(a1)                      // a1 = row
            lui     a0, 0x8013
            jal     0x8013212C
            lw      a0, 0x3460(a0)                      // a0 = cursor object

            // play sound
            jal     0x800269C0
            addiu   a0, r0, FGM.menu.SCROLL

            b       _return
            nop

            _toggle_items_on_off:
            li      t0, VANILLA_ON_OFF_ARRAY            // t0 = address of first on/off value
            lw      a1, 0x0000(t0)                      // a1 = 1 if on, 0 if off
            xori    a1, a1, 0x0001                      // a1 = 0 -> 1, 1 -> 0
            addiu   t3, r0, 0x000F                      // t3 = 15 (number of items per page)
            _loop_vanilla:
            sw      a1, 0x0000(t0)                      // store value
            addiu   t0, t0, 0x0004                      // t0 = address of next on/off value
            addiu   t3, t3, -0x0001                     // t3 = remaining items--
            bnez    t3, _loop_vanilla                   // loop if any items left on page
            nop
            li      t0, CUSTOM_ON_OFF_ARRAY             // t0 = address of first custom on/off value
            addiu   t3, r0, NUM_STANDARD_ITEMS          // t3 = number of standard custom items
            _loop_custom:
            sw      a1, 0x0000(t0)                      // store value
            addiu   t0, t0, 0x0004                      // t0 = address of next on/off value
            addiu   t3, t3, -0x0001                     // t3 = remaining items--
            bnez    t3, _loop_custom                    // loop if any items left on page
            nop

            // play sound
            jal     0x800269C0
            addiu   a0, r0, FGM.menu.TOGGLE

            // refresh list
            li      a0, VANILLA_ON_OFF_ARRAY            // a0 = address of first on/off value
            jal     initialize_on_off_display_
            nop

            _return:
            lw      ra, 0x0014(sp)                      // original line 1
            jr      ra                                  // original line 3
            addiu   sp, sp, 0x0028                      // original line 2

            // @ Description
            // Helper that sets the ON/OFF text to red based off given values.
            // @ Arguments
            // a0 - address of ON/OFF object array
            scope initialize_on_off_display_: {
                addiu   sp, sp, -0x0028                 // allocate stack space
                sw      a0, 0x001C(sp)                  // save registers
                lli     a0, 0x0001                      // ~
                sw      a0, 0x0020(sp)                  // ~
                sw      ra, 0x0024(sp)                  // ~

                _loop:
                lw      a1, 0x001C(sp)                  // a1 = address of on/off value
                lw      a0, 0x0020(sp)                  // a0 = row
                jal     0x80132A94                      // update on/off display
                lw      a1, 0x0000(a1)                  // t1 = on/off value

                lw      a1, 0x001C(sp)                  // a1 = address of on/off value
                addiu   a1, a1, 0x0004                  // address of next on/off value
                sw      a1, 0x001C(sp)                  // save a1
                lw      a0, 0x0020(sp)                  // a0 = row
                addiu   a0, a0, 0x0001                  // row++
                sltiu   a1, a0, 0x000F + 1           // a1 = 0 if we've reached the end
                // sltiu   a1, a0, NUM_STANDARD_ITEMS + 1  // a1 = 0 if we've reached the end
                bnez    a1, _loop                       // loop while still more to initialize
                sw      a0, 0x0020(sp)                  // save a0

                lw      a0, 0x001C(sp)                  // restore registers
                lw      ra, 0x0024(sp)                  // ~
                jr      ra                              // return
                addiu   sp, sp, 0x0028                  // deallocate stack space
            }
        }

        // restrict cursor on page 1
        scope restrict_cursor_: {
            // up
            OS.patch_start(0x1291E0, 0x80132C40)
            jal     restrict_cursor_._up
            lui     a0, 0x8013                          // original line 2
            OS.patch_end()

            // down
            OS.patch_start(0x1292C0, 0x80132D20)
            jal     restrict_cursor_._down
            lui     t8, 0x8013                          // original line 2
            OS.patch_end()

            _up:
            li      t8, ITEM_SWITCH_PAGE
            lw      t8, 0x0000(t8)                      // t8 = page
            beqzl   t8, _return                         // if normal list, use original line
            addiu   t8, r0, 0x000F                      // original line 1
            b       _return                             // otherwise use the number of custom items
            addiu   t8, r0, NUM_STANDARD_ITEMS                   // set max NUM_STANDARD_ITEMS

            _down:
            li      at, ITEM_SWITCH_PAGE
            lw      at, 0x0000(at)                      // at = page
            beqzl   at, _return                         // if normal list, use original line
            addiu   at, r0, 0x000F                      // original line 1
            b       _return                             // otherwise use the number of custom items
            addiu   at, r0, NUM_STANDARD_ITEMS                   // set max NUM_STANDARD_ITEMS

            _return:
            jr      ra
            nop
        }

        // handle ON/OFF updates for custom items
        scope handle_custom_item_values_: {
            // off
            OS.patch_start(0x129518, 0x80132F78)
            jal     handle_custom_item_values_._off
            sll     t5, a0, 0x0002                      // original line 1
            OS.patch_end()

            // on
            OS.patch_start(0x1293F4, 0x80132E54)
            jal     handle_custom_item_values_._on
            sll     t4, a0, 0x0002                      // original line 1
            OS.patch_end()

            // off pre-check
            OS.patch_start(0x1294EC, 0x80132F4C)
            jal     handle_custom_item_values_._precheck
            addu    t3, t3, t2                          // original line 1
            OS.patch_end()

            // on pre-check
            OS.patch_start(0x1293CC, 0x80132E2C)
            jal     handle_custom_item_values_._precheck
            addu    t3, t3, t2                          // original line 1
            OS.patch_end()

            // A button press
            OS.patch_start(0x1295F0, 0x80133050)
            jal     handle_custom_item_values_._a_button
            sll     t3, a2, 0x0002                      // original line 1
            OS.patch_end()

            _off:
            li      t4, ITEM_SWITCH_PAGE
            lw      t4, 0x0000(t4)                      // t4 = page
            bnezl   t4, pc() + 8                        // if not page 0, then adjust to store in free space
            addiu   t5, t5, CUSTOM_ON_OFF_ARRAY - VANILLA_ON_OFF_ARRAY

            jr      ra
            addu    at, at, t5                          // original line 2

            _on:
            li      t6, ITEM_SWITCH_PAGE
            lw      t6, 0x0000(t6)                      // t6 = page
            bnezl   t6, pc() + 8                        // if not page 0, then adjust to store in free space
            addiu   t4, t4, CUSTOM_ON_OFF_ARRAY - VANILLA_ON_OFF_ARRAY

            jr      ra
            addu    at, at, t4                          // original line 2

            _precheck:
            li      t6, ITEM_SWITCH_PAGE
            lw      t6, 0x0000(t6)                      // t6 = page
            bnezl   t6, pc() + 8                        // if not page 0, then adjust to store in free space
            addiu   t3, t3, CUSTOM_ON_OFF_ARRAY - VANILLA_ON_OFF_ARRAY

            jr      ra
            lw      t3, 0x3420(t3)                      // original line 2

            _a_button:
            li      t6, ITEM_SWITCH_PAGE
            lw      t6, 0x0000(t6)                      // t6 = page
            bnezl   t6, pc() + 8                        // if not page 0, then adjust to store in free space
            addiu   t3, t3, CUSTOM_ON_OFF_ARRAY - VANILLA_ON_OFF_ARRAY

            jr      ra
            addu    v1, t3, t5                          // original line 2
        }
    }

    // Include item files, scoped
    scope CloakingDevice {
        include "items/CloakingDevice.asm"
    }
    scope SuperMushroom {
        include "items/SuperMushroom.asm"
    }
    scope PoisonMushroom {
        include "items/PoisonMushroom.asm"
    }
    scope KlapTrap {
        include "items/KlapTrap.asm"
    }
    scope RobotBee {
        include "items/RobotBee.asm"
    }
    scope BlueShell {
        include "items/BlueShell.asm"
    }
    scope Lightning {
        include "items/Lightning.asm"
    }
    scope DekuNut {
        include "items/DekuNut.asm"
    }
    scope FranklinBadge {
        include "items/FranklinBadge.asm"
    }
    scope Pitfall {
        include "items/Pitfall.asm"
    }
    scope GoldenGun {
        include "items/GoldenGun.asm"
    }
    scope Dango {
        include "items/Dango.asm"
    }
    scope Car {
        include "items/Car.asm"
    }
    scope Gem {
        include "items/Gem.asm"
    }
    scope Shuriken {
        include "items/Shuriken.asm"
    }
    scope Boomerang {
        include "items/Boomerang.asm"
    }
    scope ClanBomb {
        include "items/ClanBomb.asm"
    }
    scope WaddleDee {
        include "items/WaddleDee.asm"
    }
    scope WaddleDoo {
        include "items/WaddleDoo.asm"
    }
    scope Gordo {
        include "items/Gordo.asm"
    }

    scope Cloud {
        include "items/Cloud.asm"
    }

    scope Flashbang {
        include "items/Flashbang.asm"
    }

    scope BulletBill {
        include "items/BulletBill.asm"
    }

    scope ScuttleMinion {
        include "items/ScuttleMinion.asm"
    }

    scope Cacodemon {
        include "items/Cacodemon.asm"
    }

    scope Pwing {
        include "items/Pwing.asm"
    }

    // Add items:
    // Standard Items
    add_item(CloakingDevice)       // 0x2D
    add_item(SuperMushroom)        // 0x2E
    add_item(PoisonMushroom)       // 0x2F
    add_item(BlueShell)            // 0x30
    add_item(Lightning)            // 0x31
    add_item(DekuNut)              // 0x32
    add_item(FranklinBadge)        // 0x33
    add_item(Pitfall)              // 0x34
    add_item(GoldenGun)            // 0x35
    add_item(Dango)                // 0x36
    add_item(Pwing)                // 0x37
    // Stage Items
    add_item(KlapTrap)             // 1
    add_item(RobotBee)             // 2
    add_item(Car)                  // 3
    add_item(BulletBill)           // 4
    add_item(ScuttleMinion)        // 5
    add_item(Cacodemon)            // 6
    // Pokemon
    // Character Items
    add_item(Gem)                  // 1
    add_item(Shuriken)             // 2
    add_item(Boomerang)            // 3
    add_item(ClanBomb)             // 4
    add_item(WaddleDee)            // 5
    add_item(WaddleDoo)            // 6
    add_item(Gordo)                // 7
    add_item(Cloud)                // 8
    add_item(Flashbang)            // 9

    // @ Description
    // Active item clean up.
    // Called when loading CSS, VS, Training and VS Results
    scope clear_active_custom_items_: {
        addiu   sp, sp, -0x0030                     // allocate stack space
        sw      ra, 0x0004(sp)                      // ~

        jal     CloakingDevice.clear_active_cloaking_devices_
        nop

        jal     SuperMushroom.clear_active_mushrooms_
        nop

        jal     Lightning.clear_active_lightning_routine_
        nop

        jal     FranklinBadge.clear_active_franklin_badges_
        nop

        jal     Pwing.clear_active_pwings_
        nop

        jal     Poison.clear_poison_
        nop

        lw      ra, 0x0004(sp)                      // restore ra
        jr      ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
    }

    // @ Description
    // This ensures custom items are cleared at the start of 1p matches.
    scope clear_items_in_1p_: {
        OS.patch_start(0x10E5A0, 0x8018FD40)
        j      clear_items_in_1p_._stage_rttf_init
        lw     s0, 0x0024(sp)              // original line 1
        _stage_rttf_init_return:
        OS.patch_end()

        OS.patch_start(0x113000, 0x8018E8C0)
        j      clear_items_in_1p_._btt_btp_init
        nop
        _btt_btp_init_return:
        OS.patch_end()

        _stage_rttf_init:
        // Ensure no custom items are still applied
        jal     Item.clear_active_custom_items_
        nop

        j      _stage_rttf_init_return
        lw     ra, 0x0034(sp)              // original line 2

        _btt_btp_init:
        // Ensure no custom items are still applied
        jal     Item.clear_active_custom_items_
        nop

        lw     ra, 0x0024(sp)              // original line 1
        j      _btt_btp_init_return
        addiu  sp, sp, 0x0088              // original line 2
    }

    // @ Description
    // Enables skipping item spawn gfx.
    scope skip_item_spawn_gfx_: {
        OS.patch_start(0xE9518, 0x8016EAD8)
        jal     skip_item_spawn_gfx_
        lw      a0, 0x0028(sp)             // original line 2
        OS.patch_end()

        li     t1, flag
        lw     t1, 0x0000(t1)              // t1 = 0 if don't skip
        bnez   t1, _end                    // if flag is set, skip
        nop

        addiu   sp, sp, -0x0030            // allocate stack space
        sw      ra, 0x0004(sp)             // save registers

        jal     0x801044B4                 // original line 1 - create spawn gfx
        nop

        lw      ra, 0x0004(sp)             // restore ra
        addiu   sp, sp, 0x0030             // deallocate stack space

        _end:
        jr     ra
        nop

        // flag to control skipping
        flag:
        dw OS.FALSE
    }

    // @ Description
    // Enables skipping item pick sound.
    scope skip_item_pickup_sound_: {
        OS.patch_start(0xED850, 0x80172E10)
        jal    skip_item_pickup_sound_
        addiu  a0, r0, 0x0031              // original line 2
        OS.patch_end()

        li     t1, flag
        lw     t1, 0x0000(t1)              // t1 = 0 if don't skip
        bnez   t1, _end                    // if flag is set, skip
        nop

        addiu   sp, sp, -0x0030            // allocate stack space
        sw      ra, 0x0004(sp)             // save registers

        jal     0x800269C0                 // original line 1 - play FGM
        nop

        lw      ra, 0x0004(sp)             // restore ra
        addiu   sp, sp, 0x0030             // deallocate stack space

        _end:
        jr     ra
        nop

        // flag to control skipping
        flag:
        dw OS.FALSE
    }

    start_with_table_:
    dw 0x00000000                                   // 0x00 = no item
    dw Hazards.standard.BEAM_SWORD                  // 0x01 = BEAM_SWORD(0x0007)
    dw Hazards.standard.HOME_RUN_BAT                // 0x02 = HOME_RUN_BAT(0x0008)
    dw Hazards.standard.FAN                         // 0x03 = FAN(0x0009)
    dw Hazards.standard.STAR_ROD                    // 0x04 = STAR_ROD(0x000A)
    dw Hazards.standard.RAY_GUN                     // 0x05 = RAY_GUN(0x000B)
    dw Hazards.standard.FIRE_FLOWER                 // 0x06 = FIRE_FLOWER(0x000C)
    dw Hazards.standard.HAMMER                      // 0x07 = HAMMER(0x000D)
    dw Hazards.standard.MOTION_SENSOR_BOMB          // 0x08 = MOTION_SENSOR_BOMB(0x000E)
    dw Hazards.standard.BOBOMB                      // 0x09 = BOBOMB(0x000F)
    dw Hazards.standard.BUMPER                      // 0x0A = BUMPER(0x0010)
    dw Hazards.standard.GREEN_SHELL                 // 0x0B = GREEN_SHELL(0x0011)
    dw Hazards.standard.RED_SHELL                   // 0x0C = RED_SHELL(0x0012)
    dw Hazards.standard.POKEBALL                    // 0x0D = POKEBALL(0x0013)
    dw Item.BlueShell.id                            // 0x0E = BLUE_SHELL(0x0030)
    dw Item.DekuNut.id                              // 0x0F = DEKU_NUT(0x0032)
    dw Item.Pitfall.id                              // 0x10 = PIT_FALL(0x0033)
    dw Item.GoldenGun.id                            // 0x11 = GOLDENGUN
    dw 0x0000FFFF                                   // 0x12 = random item, insert new entries above.

    constant start_with_random_entry(0x12)          // must update to same entry as random if adding new entries.

    start_with_item:
    dw 0, 0, 0, 0

    // @ Description
    // hook in routine that grants players control after "3, 2, 1 GO!". Runs for each player + port.
    // Allows us to add a custom item as soon as player begins match
    scope match_begin_with_item_: {
        OS.patch_start(0x8D9F4,0x801121F4)
        jal       match_begin_with_item_
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0030                     // allocate stack space
        sw      ra, 0x0024(sp)                      // save registers
        sw      t1, 0x0014(sp)
        sw      t2, 0x0018(sp)
        sw      t0, 0x001C(sp)
        sw      a1, 0x0020(sp)

        andi    t7, t6, 0xFFF0                      // original line 1
        sb      t7, 0x0191(s1)                      // original line 2, affects camera tracking of player

        li      t1, start_with_item
        sw      t1, 0x0008(sp)                      // save start_with_item address to stack
        addiu   t0, v0, 0x0000

        sw      t0, 0x000C(sp)                      // save player struct to stack
        lbu     t2, 0x000D(t0)                      // t2 = port
        sll     t2, t2, 0x0002                      // t2 = offset to port
        addu    t1, t1, t2                          // t1 = address of start with item_id
        lw      a1, 0x0000(t1)                      // a1 = table index
        beqz    a1, _next                           // if no item, skip this port
        lw      a0, 0x0004(t0)                      // a0 = player object
        beqz    a0, _next                           // if no player object, skip this port
        lli     t0, start_with_random_entry         // t0 = random entry index
        bne     a1, t0, _get_item_id                // branch if index != random
        sw      a0, 0x0010(sp)                      // save player object to stack

        // if here, get a random index
        _random:
        jal     Global.get_random_int_
        addiu   a0, t0, 0x0000                      // argument = table height
        beql    v0, r0, pc() + 0x08                 // increase v0 by 1 if it is 0
        addiu   v0, v0, 0x0001                      // ~
        addiu   a1, v0, 0x0000                      // t1 = new index to table

        _get_item_id:
        li      t2, start_with_table_               // t2 = pointer to "start_with_item_table_"
        sll     a1, a1, 0x0002                      // a1 = offset to item id
        addu    t2, t2, a1                          // t2 = pointer to item id
        lw      a1, 0x0000(t2)                      // a1 = item id
        sw      a1, 0x0028(sp)                      // save item id to stack
        lw      a0, 0x0010(sp)                      // save player object to stack
        lw      t0, 0x000C(sp)                      // restore t0

        _create:
        lli     a2, OS.TRUE                         // a2 = skip spawn gfx
        lli     a3, OS.TRUE                         // a3 = skip pickup sfx
        jal     create_and_assign_item_
        lw      a0, 0x0010(sp)                      // a0 = player object

        _next:
        lw      ra, 0x0024(sp)                      // restore ra
        lw      t1, 0x0014(sp)
        lw      t2, 0x0018(sp)
        lw      t0, 0x001C(sp)
        lw      a1, 0x0020(sp)
        jr      ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
    }


    // @ Description
    // Allows players to start with items (in non-vs modes)
    scope start_with_item_: {
        addiu   sp, sp, -0x0030                     // allocate stack space
        sw      ra, 0x0004(sp)                      // save registers

        lui     t0, 0x8013
        lw      t0, 0x0D84(t0)                      // t0 = first player struct
        li      t1, start_with_item
        sw      t1, 0x0008(sp)                      // save start_with_item address to stack

        _loop:
        sw      t0, 0x000C(sp)                      // save player struct to stack
        lbu     t2, 0x000D(t0)                      // t2 = port
        sll     t2, t2, 0x0002                      // t2 = offset to port
        addu    t1, t1, t2                          // t1 = address of start with item_id
        lw      a1, 0x0000(t1)                      // a1 = table index
        beqz    a1, _next                           // if no item, skip this port
        lw      a0, 0x0004(t0)                      // a0 = player object
        beqz    a0, _next                           // if no player object, skip this port
        lli     t0, start_with_random_entry         // t0 = random entry index
        bne     a1, t0, _get_item_id                // branch if index != random
        sw      a0, 0x0010(sp)                      // save player object to stack

        // if here, get a random index
        _random:
        jal     Global.get_random_int_
        addiu   a0, t0, 0x0000                      // argument = table height
        beql    v0, r0, pc() + 0x08                 // increase v0 by 1 if it is 0
        addiu   v0, v0, 0x0001                      // ~
        addiu   a1, v0, 0x0000                      // t1 = new index to table

        _get_item_id:
        li      t2, start_with_table_               // t2 = pointer to "start_with_item_table_"
        sll     a1, a1, 0x0002                      // a1 = offset to item id
        addu    t2, t2, a1                          // t2 = pointer to item id
        lw      a1, 0x0000(t2)                      // a1 = item id
        sw      a1, 0x0028(sp)                      // save item id to stack
        lw      a0, 0x0010(sp)                      // load player object
        lw      t0, 0x000C(sp)                      // restore t0

        _create:
        lli     a2, OS.TRUE                         // a2 = skip spawn gfx
        lli     a3, OS.TRUE                         // a3 = skip pickup sfx
        jal     create_and_assign_item_
        lw      a0, 0x0010(sp)                      // a0 = player object

        _next:
        lw      t0, 0x000C(sp)                      // t0 = player struct
        lw      t0, 0x0000(t0)                      // t0 = next player struct
        bnez    t0, _loop                           // if more players, keep looping
        lw      t1, 0x0008(sp)                      // t1 = start_with_item

        lw      ra, 0x0004(sp)                      // restore ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Allows players to respawn with items.
    // @ Arguments
    // a0 - player object
    // a1 - action ID
    scope respawn_with_item_: {
        addiu   sp, sp, -0x0030                     // allocate stack space
        sw      ra, 0x0004(sp)                      // save registers

        lli     t0, Action.Revive1
        bne     a1, t0, _end                        // if not respawning, skip
        nop

        lw      t0, 0x0084(a0)                      // t0 = player struct
        li      t1, start_with_item
        lbu     t2, 0x000D(t0)                      // t2 = port

        sll     t2, t2, 0x0002                      // t2 = offset to port
        addu    t1, t1, t2                          // t1 = address of start with item_id
        lw      a1, 0x0000(t1)                      // a1 = item_id
        sw      a1, 0x0028(sp)                      // save item id to stack
        beqz    a1, _end                            // if no item, skip this port
        li      t0, start_with_random_entry         // t0 = random entry index
        bne     a1, t0, _continue                   // branch if index != random
        sw      a0, 0x0010(sp)                      // save player object to stack

        // if here, get a random number, then convert to a valid item_id
        _random:
        jal     Global.get_random_int_
        addiu   a0, t0, 0x0000                      // argument = table height
        beql    v0, r0, pc() + 0x08                 // increase v0 by 1 if it is 0
        addiu   v0, v0, 0x0001                      // ~
        addiu   a1, v0, 0x0000                      // t1 = new index to table

        _continue:
        li      t2, start_with_table_               // t2 = pointer to "start_with_item_table_"
        sll     a1, a1, 0x0002                      // a1 = offset to item id
        addu    t2, t2, a1                          // t2 = pointer to item id
        lw      a1, 0x0000(t2)                      // a1 = item id
        sw      a1, 0x0028(sp)                      // save item id to stack
        lw      a0, 0x0010(sp)                      // a0 = player object

        _create:
        lli     a2, OS.TRUE                         // a2 = skip spawn gfx
        lli     a3, OS.TRUE                         // a3 = skip pickup sfx
        jal     create_and_assign_item_
        lw      a0, 0x0010(sp)                      // a0 = player object

        _end:
        lw      ra, 0x0004(sp)                      // restore ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Holds adjusted item_id to spawn during taunt per port
    taunt_item_table_:
    dw 0x00000000                                   // 0x00 = no item
    dw Hazards.standard.BEAM_SWORD                  // 0x01 = BEAM_SWORD(0x0007)
    dw Hazards.standard.HOME_RUN_BAT                // 0x02 = HOME_RUN_BAT(0x0008)
    dw Hazards.standard.FAN                         // 0x03 = FAN(0x0009)
    dw Hazards.standard.STAR_ROD                    // 0x04 = STAR_ROD(0x000A)
    dw Hazards.standard.RAY_GUN                     // 0x05 = RAY_GUN(0x000B)
    dw Hazards.standard.FIRE_FLOWER                 // 0x06 = FIRE_FLOWER(0x000C)
    dw Hazards.standard.HAMMER                      // 0x07 = HAMMER(0x000D)
    dw Hazards.standard.MOTION_SENSOR_BOMB          // 0x08 = MOTION_SENSOR_BOMB(0x000E)
    dw Hazards.standard.BOBOMB                      // 0x09 = BOBOMB(0x000F)
    dw Hazards.standard.BUMPER                      // 0x0A = BUMPER(0x0010)
    dw Hazards.standard.GREEN_SHELL                 // 0x0B = GREEN_SHELL(0x0011)
    dw Hazards.standard.RED_SHELL                   // 0x0C = RED_SHELL(0x0012)
    dw Hazards.standard.POKEBALL                    // 0x0D = POKEBALL(0x0013)
    dw Item.BlueShell.id                            // 0x0E = BLUE_SHELL(0x0030)
    dw Item.DekuNut.id                              // 0x0F = DEKU_NUT(0x0032)
    dw Item.Pitfall.id                              // 0x10 = PIT_FALL(0x0033)
    dw Item.GoldenGun.id                            // 0x11 = GOLDENGUN
    dw 0x0000FFFF                                   // 0x12 = random item

    constant taunt_item_random_entry(0x12)

    taunt_spawn_item:
    dw 0, 0, 0, 0

    // @ Description
    // Allows players to spawn items via taunt.
    scope taunt_spawn_item_: {
        OS.patch_start(0xC918C, 0x8014E74C)
        jal     taunt_spawn_item_
        lw      v0, 0x0024(sp)                      // original line 1 - v0 = player struct
        OS.patch_end()

        sw      r0, 0x0180(v0)                      // original line 2

        addiu   sp, sp, -0x0030                     // allocate stack space
        sw      ra, 0x0004(sp)                      // save registers

        li      t1, taunt_spawn_item
        sw      t1, 0x0008(sp)                      // save start_with_item address to stack
        addiu   t0, v0, 0x0000

        sw      t0, 0x000C(sp)                      // save player struct to stack
        lbu     t2, 0x000D(t0)                      // t2 = port
        sll     t2, t2, 0x0002                      // t2 = offset to port
        addu    t1, t1, t2                          // t1 = address of start with item_id
        lw      a1, 0x0000(t1)                      // a1 = table index
        beqz    a1, _end                            // if no item, skip this port
        lw      a0, 0x0004(t0)                      // a0 = player object
        beqz    a0, _end                            // if no player object, skip this port
        lli     t0, taunt_item_random_entry         // t0 = random entry index
        bne     a1, t0, _get_item_id                // branch if index != random
        sw      a0, 0x0010(sp)                      // save player object to stack

        // if here, get a random index
        _random:
        jal     Global.get_random_int_
        addiu   a0, t0, 0x0000                      // argument = table height
        beql    v0, r0, pc() + 0x08                 // increase v0 by 1 if it is 0
        addiu   v0, v0, 0x0001                      // ~
        addiu   a1, v0, 0x0000                      // a1 = new index to table

        _get_item_id:
        li      t2, taunt_item_table_               // t2 = pointer to "taunt_item_table_"
        sll     a1, a1, 0x0002                      // a1 = offset to item id
        addu    t2, t2, a1                          // t2 = pointer to item id
        lw      a1, 0x0000(t2)                      // a1 = item id
        sw      a1, 0x0028(sp)                      // save item id to stack
        lw      a0, 0x0010(sp)                      // save player object to stack
        lw      t0, 0x000C(sp)                      // restore t0

        _create:
        lli     a2, OS.TRUE                         // a2 = skip spawn gfx
        lli     a3, OS.TRUE                         // a3 = skip pickup sfx
        jal     create_and_assign_item_
        lw      a0, 0x0010(sp)                      // a0 = player object

        _end:
        lw      ra, 0x0004(sp)                      // restore ra
        jr      ra
        addiu   sp, sp, 0x0030                      // deallocate stack space
    }

    // @ Description
    // Creates and assigns the item to a player.
    // Does not work with hammers :(
    // @ Arguments
    // a0 - player object
    // a1 - item ID
    // a2 - show spawn gfx
    // a3 - play pickup sfx
    scope create_and_assign_item_: {
        lw      t0, 0x0084(a0)                      // t0 = player struct
        lw      t0, 0x084C(t0)                      // t0 = player held pointer
        bnez    t0, _end                            // if player is holding an item, skip
        nop

        li      t0, skip_item_spawn_gfx_.flag
        sw      a2, 0x0000(t0)                      // update override flag to skip showing spawn gfx

        li      t0, skip_item_pickup_sound_.flag
        sw      a3, 0x0000(t0)                      // update override flag to skip playing pickup sfx

        addiu   sp, sp, -0x0010                     // allocate stack space
        sw      ra, 0x0004(sp)                      // save registers
        sw      a0, 0x0008(sp)                      // ~

        addiu   sp, sp, -0x0030                     // allocate stack space (0x8016EA78 is unsafe)
        lw      t1, 0x0074(a0)                      // t1 = top joint
        or      a0, r0, r0
        addiu   a2, t1, 0x001C                      // a2 = location of coordinates (use player position)
        addiu   a3, sp, 0x0020                      // a3 = address of setup floats
        lli     t3, 0x0001                          // t3 = 1
        sw      t3, 0x0010(sp)                      // 0x0010(sp) = 1
        sw      r0, 0x0000(a3)                      // set up float 1
        lui     t3, 0x41F0
        sw      t3, 0x0004(a3)                      // set up float 2
        jal     0x8016EA78                          // create item ?
        sw      r0, 0x0008(a3)                      // set up float 3
        addiu   sp, sp, 0x0030                      // deallocate stack space

        beqz    v0, _finish                         // if no item spawned, don't try to assign it!
        or      a0, v0, r0                          // a0 = item object
        lw      a1, 0x0008(sp)                      // a1 = player object
        jal     0x80172CA4                          // initiate item pickup
        addiu   sp, sp, -0x0030                     // allocate stack space (0x80172CA4 is unsafe)
        addiu   sp, sp, 0x0030                      // deallocate stack space

        lw      a0, 0x0008(sp)                      // a0 = player object
        lw      t0, 0x0084(a0)                      // a1 = player struct


        lw      t1, 0x0038(sp)                      // load item id from stack
        addiu   at, r0, Hazards.standard.HAMMER     // at = hammer.id
        bne     t1, at, _finish                     // branch if not hammer
        nop

        // if here, item is hammer
        addiu   at, r0, 0x02D0                      // at = default hammer timer
        sw      at, 0x0B14(t0)                      // save hammer timer to player struct.
        jal     0x800F3938                          // initiate hammer
        nop
        jal     0x800E7AFC                          // play midi
        addiu   a0, r0, 0x002D                      // argument = hammer midi ?
        lw      a0, 0x0008(sp)                      // a0 = player object
        lw      t0, 0x0084(a0)                      // a1 = player struct

        _finish:
        li      t0, skip_item_spawn_gfx_.flag
        sw      r0, 0x0000(t0)                      // clear skip gfx flag

        li      t0, skip_item_pickup_sound_.flag
        sw      r0, 0x0000(t0)                      // clear skip sfx flag

        lw      ra, 0x0004(sp)                      // restore ra
        addiu   sp, sp, 0x0010                      // deallocate stack space

        _end:
        jr      ra
        nop
    }


    // @ Description
    // Hard-coded pointer to file 0xFB
    constant info_struct(0x8018D040)

    scope Crate {
        // constant item_info_array()
        // constant SPAWN_ITEM()
        constant id(0x0)
    }

    scope Barrel {
        // constant item_info_array()
        // constant SPAWN_ITEM()
        constant id(0x1)
    }

    scope Capsule {
        // constant item_info_array()
        // constant SPAWN_ITEM()
        constant id(0x2)
    }

    scope Egg {
        // constant item_info_array()
        // constant SPAWN_ITEM()
        constant id(0x3)
    }

    scope Tomato {
        constant item_info_array(0x80189730)
        constant SPAWN_ITEM(0x80174624)
        constant id(0x4)
        constant PICKUP_ITEM_MAIN(0x800EA3D4)
    }

    scope Heart {
        constant item_info_array(0x801897D0)
        constant SPAWN_ITEM(0x80174850)
        constant id(0x5)
    }

    scope Star {
        constant item_info_array(0x80189870)
        constant SPAWN_ITEM(0x80174A18)
        constant id(0x6)
    }

    scope BeamSword {
        constant item_info_array(0x801898B0)
        constant SPAWN_ITEM(0x80174DA0)
        constant id(0x7)
    }

    scope HomeRunBat {
        constant item_info_array(0x80189990)
        constant SPAWN_ITEM(0x801750B8)
        constant id(0x8)
    }

    scope Fan {
        constant item_info_array(0x80189490)
        constant SPAWN_ITEM(0x80175460)
        constant id(0x9)
    }

    scope StarRod {
        constant item_info_array(0x8018A0F0)
        constant SPAWN_ITEM(0x80178134)
        constant id(0xA)
    }

    scope RayGun {
        constant item_info_array(0x80189B50)
        constant SPAWN_ITEM(0x80175800)
        constant id(0xB)
    }

    scope FireFlower {
        constant item_info_array(0x80189C60)
        constant SPAWN_ITEM(0x80175D60)
        constant id(0xC)
    }

    scope Hammer {
        constant item_info_array(0x80189D70)
        constant SPAWN_ITEM(0x801763C8)
        constant id(0xD)
    }

    scope MotionSensorBomb {
        constant item_info_array(0x80189E50)
        constant SPAWN_ITEM(0x80176F60)
        constant id(0xE)
    }

    scope Bobomb {
        constant item_info_array(0x80189F98)
        constant SPAWN_ITEM(0x80177D9C)
        constant id(0xF)
    }

    scope Bumper {
        constant item_info_array(0x8018A690)
        constant SPAWN_ITEM(0x8017BF8C)
        constant id(0x10)
    }

    scope GreenShell {
        constant item_info_array(0x8018A200)
        constant SPAWN_ITEM(0x80178FDC)
        constant id(0x11)
    }

    scope RedShell {
        constant item_info_array(0x8018A570)
        constant SPAWN_ITEM(0x8017B1D8)
        constant id(0x12)
    }

    scope Pokeball {
        constant item_info_array(0x8018A890)
        constant SPAWN_ITEM(0x8017CE0C)
        constant id(0x13)
    }

    scope PkFirePillar {
        //constant item_info_array()
        constant id(0x14)
    }

    scope Bomb {
    // Links bomb
    // constant item_info_array()
        constant id(0x15)
    }

    scope FloatingBumper {
        constant item_info_array(0x8018AA50)
        constant id(0x16)
    }

    // @ Description
    // Item Types, value is present at 0x10 in item struct
    scope TYPE {
        constant MELEE(0x1)         // sword, bat
        constant SHOOT(0x2)         // raygun, f.flower
        constant THROW(0x3)         // MSB, pokeball
        constant COLLISION(0x4)     // star, shrooms
        constant OTHER(0x5)         // hammer, tomato
    }

    // @ Description
    // Offsets in item Special Struct
    scope STRUCT {
        constant OBJECT(0x4)
        constant OWNER(0x8)
        constant TYPE(0x10)
        constant ID(0xC)
        constant OWNER_PORT(0x15)   // byte
        constant PERCENT_DAMAGE(0x1C)
        constant DIRECTION(0x24)
        constant X_SPEED(0x2C)
        constant Y_SPEED(0x30)
        constant Z_SPEED(0x34)
        constant ASYNC_TIMER(0x94)
        scope HITBOX: {
            constant ENABLED(0x10C)
            constant DAMAGE(0x110)
            constant DAMAGE_MULTIPLIER(0x118)
            constant TYPE(0x11C)
            constant X_OFFSET(0x120)
            constant Y_OFFSET(0x124)
            constant Z_OFFSET(0x128)
            constant SIZE(0x138)
            constant KNOCKBACK1(0x140)
            constant KNOCKBACK2(0x144)
            constant KNOCKBACK3(0x148)
            constant ANGLE(0x13C)
        }
        scope HURTBOX {
            constant ENABLED(0x248)
        }
        constant DURATION(0x2C0)

        constant MAIN_ROUTINE(0x378)
        scope COLLISION {
            constant CLIPPING(0x37C)
            constant HURTBOX(0x380)
            constant SHIELD(0x384)
            constant SHIELD_EDGE(0x388)
            constant HITBOX(0x38C)
            constant REFLECTOR(0x390)
            constant ABSORB(0x394)
            constant BLAST_WALL(0x398)
        }

        constant APPLY_DAMAGE(0x800E39B0)   // This routine is called when an item collides with a player


    }

    // @ Description
    // Pokemon item menu gate
    // Handles Pokeball selecting Pokemon type (respecting ON/OFF values)
    scope whos_that_pokemon: {
        OS.patch_start(0xEDCA0, 0x80173260)
        jal     whos_that_pokemon
        nop
        OS.patch_end()

            or      t9, r0, r0                  // t9 is used to count number of total Pokemon ON
            or      a0, r0, r0                  // a0 is loop index
            sanity_check:
            li      t1, pokemon_table           // t1 = address of pokemon_table
            sll     v0, a0, 2                   // v0 = offset * 4
            add     t1, t1, v0                  // t1 = pokemon_table + incrementing offset
            lw      t1, 0x0000(t1)              // t1 = Toggle address in table
            lw      t1, 0x0004(t1)              // t1 = Toggle value (0 if OFF, 1 if ON)
            addiu   a0, a0, 1                   // a0++
            add     t9, t9, t1                  // t9 = t9 + t1
            sltiu   t1, a0, POKEMON_COUNT - 1   // t1 = 1 if a0 < 12
            bnez    t1, sanity_check
            nop

            li      a0, Toggles.entry_pokemon_mew  // a0 = entry_pokemon_mew
            lw      a0, 0x0004(a0)                 // a0 = Toggle value (0 if OFF, 1 if ON)
            li      t1, pokem_on                   // t1 = address of pokem_on
            sw      t9, 0x0000(t1)                 // store value of how pokemon are ON (we don't count MEW)
            bnez    t9, random_mew                 // if any pokemon (other than MEW) are enabled, we need to roll
            nop
            // if we're here, no other pokemon is ON; check for MEW and branch if he's the only one
            bnezl   a0, _mew_selected              // skip if MEW is not ON
            lli     a1, Hazards.pokemon.MEW        // a1 = 0x2C (MEW)
            // othewise we return an empty Pokeball
            b       _return
            lli     v0, 0x0000                     // v0 = 0 (no pokemon object)

            random_mew:
            beqz    a0, no_mew            // skip if MEW is not ON
            // original lines 1 and 2
            addiu   a0, r0, 0x0097        // a0 = 151 (probability of getting Mew)
            jal     Global.get_random_int_// v0 = (0, N-1)
            sw      t2, 0x0054(sp)
            bnez    v0, no_mew            // branch (likely)
            lw      t2, 0x0054(sp)
            li      t0, POKEMON_SLOTS     // t0 = POKEMON_SLOTS address
            lbu     v1, 0x0000(t0)        // v1 = last pokemon value
            addiu   t1, r0, Hazards.pokemon.MEW
            beq     t1, v1, no_mew        // branch if last pokemon was MEW
            nop
            lbu     t9, 0x0001(t0)        // branch if second to last pokemon was MEW
            beq     t1, t9, no_mew        // if we don't take either branch here, we get MEW
            nop
            b       _mew_selected         // branch with MEW
            or      a1, t1, r0            // a1 = Hazards.pokemon.MEW
            no_mew:
            li      t0, POKEMON_SLOTS     // t0 = POKEMON_SLOTS address
            addiu   t1, r0, 0x0020 + POKEMON_COUNT - 1 // t1 = max value for pokemon, excluding Mew (0x20 to 0x2B)
            addiu   v1, r0, 0x0020        // v1 = 0x20
            addiu   v0, r0, 0x0020        // v0 = 0x20
            lbu     t3, 0x0000(t0)        // t3 = last selected pokemon

            loop_to_get_poke:
            // check if our value matches one of the recent picks
            beql    v0, t3, try_again     // branch if loop index = last selected pokemon
            addiu   v0, v0, 0x0001        // ...and pokemon number ++
            lbu     t4, 0x0001(t0)        // t4 = second to last pokemon
            addu    t5, t0, v1            // t5 = address of second to last pokemon + 1 (next slot over)
            beql    v0, t4, try_again     // branch if pokemon number = second to last selected pokemon
            addiu   v0, v0, 0x0001        // ...and pokemon number ++

            check_slots:
            // li      t3, pokemon_table    // t3 = address of pokemon_table
            // add     t3, t3, v0           // pokemon_table + offset
            // addiu   t3, t3, -0x0020      // offset adjusted
            // lb      t3, 0x0000(t3)       // t3 = value in table (0 if OFF, 1 if ON)
            // slti    t6, t3, 3            // t6 = 1 if t3 < 3

            li      t3, pokemon_table    // t3 = address of pokemon_table
            addiu   t6, v0, -0x0020      // t6 = offset adjusted
            sll     t6, t6, 2            // t6 = offset * 4
            add     t3, t3, t6           // t3 = pokemon_table + offset
            lw      t3, 0x0000(t3)       // t3 = Toggle address in table
            lw      t3, 0x0004(t3)       // t3 = Toggle value (0 if OFF, 1 if ON)
            addiu   a0, a0, 1            // a0++

            beqzl   t3, pc() + 12        // branch accordingly if OFF or ON
            sb      r0, 0xFFE2(t5)       // store 0 for this pokemon slot
            sb      v0, 0xFFE2(t5)       // saves current pokemon number to this slot

            addiu   v1, v1, 0x0001       // v1++
            addiu   v0, v0, 0x0001       // v0++
            try_again:
            bnel    v0, t1, loop_to_get_poke // branch until we get to 0x2C (max value of pokemon)
            lbu     t3, 0x0000(t0)       // t3 = last selected pokemon
            lbu     a0, 0x002E(t0)       // a0 = total number of pokemon (starts at 0x0C)
            get_pokemon_random_offset:
            jal     Global.get_random_int_   // v0 = (0, N-1)
            sw      t2, 0x0054(sp)
            li      t0, POKEMON_SLOTS    // t0 = POKEMON_SLOTS address
            addu    t6, t0, v0           // t6 = t0 + v0 (random offset of pokemon slot)
            lbu     a1, 0x0002(t6)       // a1 = pokemon that was chosen (or forced)

            li      a2, pokem_on         // a2 = address of pokem_on
            lw      a2, 0x0000(a2)       // load value of how pokemon are ON
            slti    a2, a2, 3            // a2 = 1 if total number of Pokemon is 1 or 2
            bnezl   a2, pc() + 12        // based on the number of enabled Pokemon, use full or normal range
            lli     a0, 0x0C             // set a0 to allow for max range (since 'recent' pokemon check is being ignored)
            lbu     a0, 0x002E(t0)       // a0 = total number of pokemon in range (starts at 0x0C)
            beqzl   a1, get_pokemon_random_offset // loop until we get a non-zero
            nop

            lbu     v1, 0x0000(t0)        // v1 = last pokemon value
            lw      t2, 0x0054(sp)
            _mew_selected:
            lbu     v0, 0x002E(t0)        // v0 = total number of pokemon (starts at 0x0C)
            addiu   at, r0, 0x000A        // at = 10
            addiu   a3, sp, 0x0030
            beq     v0, at, done_lowering_slot_count // branch if v0 = 10 (can't go lower than that)
            lui     t9, 0x8000
            addiu   t7, v0, 0xFFFF        // t7 = v0 - 1
            sb      t7, 0x002E(t0)        // store total number of pokemon slots to update
            done_lowering_slot_count:
            lw      a0, 0x0058(sp)
            li      a2, pokem_on          // a2 = address of pokem_on
            lw      a2, 0x0000(a2)        // load value of how pokemon are ON
            sltiu   a2, a2, 3             // a2 = 1 if a2 < 3
            bnezl   a2, pc() + 16         // this routine has a logic check to avoid picking the same pokemon in a row...
            nop                           // ...if too few are enabled to satisfy that, we skip saving 'recent' pokemon
            sb      v1, 0x0001(t0)        // store second to last pokemon
            sb      a1, 0x0000(t0)        // a1 = store last pokemon (current one we're getting)
            lw      a2, 0x0074(a0)
            ori     t9, t9, 0x0003
            sw      t9, 0x0010(sp)
            sw      t2, 0x0054(sp)
            jal     0x8016F238            // a1 = pokemon number to spawn
            addiu   a2, a2, 0x001C

            _return:
            j        0x80173348          // jump to end of routine
            nop
        }

        // This is where the game keeps track of Pokemon to pick from (and the two most recent)
        constant POKEMON_SLOTS(0x8018D060)

        // Total number of Pokemon Types
        constant POKEMON_COUNT(13)

        // Counter of how many Pokemon are ON
        pokem_on:
        dw 0

        // Table that stores Pokemon ON/OFF states
        pokemon_table:
        dw Toggles.entry_pokemon_onix
        dw Toggles.entry_pokemon_snorlax
        dw Toggles.entry_pokemon_goldeen
        dw Toggles.entry_pokemon_meowth
        dw Toggles.entry_pokemon_charizard
        dw Toggles.entry_pokemon_beedrill
        dw Toggles.entry_pokemon_blastoise
        dw Toggles.entry_pokemon_chansey
        dw Toggles.entry_pokemon_starmie
        dw Toggles.entry_pokemon_hitmonlee
        dw Toggles.entry_pokemon_koffing
        dw Toggles.entry_pokemon_clefairy
        dw Toggles.entry_pokemon_mew
        OS.align(4)

    // @ Description
    // Handles Pokemon regional variant Japanese Voices
    scope pokemon_variant_sfx: {
        // 0x137 Snorlax 1
        OS.patch_start(0xF8D14, 0x8017E2D4)
        jal     pokemon_variant_sfx
        addiu   a0, r0, 0x0137              // original line 2
        OS.patch_end()
        // 0x138 Snorlax 2
        OS.patch_start(0xF91B4, 0x8017E774)
        jal     pokemon_variant_sfx
        sw      v1, 0x002C(sp)              // original line 2
        OS.patch_end()
        // 0x143 Goldeen
        OS.patch_start(0xF9290, 0x8017E850)
        jal     pokemon_variant_sfx
        sw      a3, 0x0018(sp)              // original line 2
        OS.patch_end()
        // 0x139 Blastoise
        OS.patch_start(0xFB3CC, 0x8018098C)
        jal     pokemon_variant_sfx
        sw      a3, 0x0018(sp)              // original line 2
        OS.patch_end()
        // 0x13A Chansey
        OS.patch_start(0xFBC10, 0x801811D0)
        jal     pokemon_variant_sfx
        sw      a3, 0x0018(sp)              // original line 2
        OS.patch_end()
        // 0x135 Koffing
        OS.patch_start(0xFD934, 0x80182EF4)
        jal     pokemon_variant_sfx
        addiu   a0, r0, 0x0135              // original line 2
        OS.patch_end()
        // 0x13C Clefairy
        OS.patch_start(0xFE1B4, 0x80183774)
        jal     pokemon_variant_sfx
        addiu   a0, r0, 0x013C              // original line 2
        OS.patch_end()
        // 0x229 Saffron Venusaur
        OS.patch_start(0xFEB7C, 0x8018413C)
        jal     pokemon_variant_sfx
        sw      a3, 0x002C(sp)              // original line 2
        OS.patch_end()
        // 0x228 Saffron Charmander
        OS.patch_start(0xFF240, 0x80184800)
        jal     pokemon_variant_sfx
        sw      a3, 0x002C(sp)              // original line 2
        OS.patch_end()
        // 0x22A Saffron Chansey
        OS.patch_start(0xF70AC, 0x8017C66C)
        jal     pokemon_variant_sfx
        sw      v1, 0x0024(sp)              // original line 2
        OS.patch_end()

        // v0 and t6 are safe, a0 = current pokemon's fgm_id

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      t6, Toggles.entry_pokemon_voices
        lw      t6, 0x0004(t6)              // t6 = 0 if DEFAULT, 1 if JAPANESE, 2 if RANDOM
        beqz    t6, _play_poke_voice        // if DEFAULT, then use original sound
        sltiu   t6, t6, 2                   // t6 = 1 if JAPANESE
        bnez    t6, _japanize               // branch accordingly
        nop
        // if we're here, it is set to 'RANDOM'
        li      t6, 0x800A0578              // t6 = address of RNG value (used by 'get_random_int_alt_')
        lw      t6, 0x0000(t6)              // t6 = RNG value (ends in 0 or 8)
        andi    t6, t6, 0x8                 // ~
        beqz    t6, _play_poke_voice        // 50% chance of remaining English
        nop

        _japanize:
        // if we're here, we swap for the corresponding Japanese SFX
        lli     t6, FGM.pokemon.u.SNORLAX_1       // t6 = SNORLAX_1 U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.SNORLAX_1       // a0 = SNORLAX_1 J fgm_id
        lli     t6, FGM.pokemon.u.SNORLAX_2       // t6 = SNORLAX_2 U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.SNORLAX_2       // a0 = SNORLAX_2 J fgm_id
        lli     t6, FGM.pokemon.u.GOLDEEN         // t6 = GOLDEEN U fgm_id (0x143)
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.GOLDEEN         // a0 = GOLDEEN J fgm_id
        lli     t6, FGM.pokemon.u.BLASTOISE       // t6 = BLASTOISE U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.BLASTOISE       // a0 = BLASTOISE J fgm_id
        lli     t6, FGM.pokemon.u.CHANSEY         // t6 = CHANSEY U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.CHANSEY         // a0 = CHANSEY J fgm_id
        lli     t6, FGM.pokemon.u.KOFFING         // t6 = KOFFING U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.KOFFING         // a0 = KOFFING J fgm_id
        lli     t6, FGM.pokemon.u.CLEFAIRY        // t6 = CLEFAIRY U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.CLEFAIRY        // a0 = CLEFAIRY J fgm_id
        lli     t6, FGM.pokemon.u.SAF_VENUSAUR    // t6 = SAF_VENUSAUR U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.SAF_VENUSAUR    // a0 = SAF_VENUSAUR J fgm_id
        lli     t6, FGM.pokemon.u.SAF_CHARMANDER  // t6 = SAF_CHARMANDER U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.SAF_CHARMANDER  // a0 = SAF_CHARMANDER J fgm_id
        lli     t6, FGM.pokemon.u.SAF_CHANSEY     // t6 = SAF_CHANSEY U fgm_id
        beql    t6, a0, _play_poke_voice
        lli     a0, FGM.pokemon.j.CHANSEY         // a0 = CHANSEY J fgm_id

        _play_poke_voice:
        jal     0x800269C0                  // original line 1 (play fgm)
        nop

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Item Containers Spawn
    // Handles disabling item containers (Crates, Barrels, Capsules)
    // Note: Eggs are (almost) always enabled for Chansey
    // container bit of mask is crate (1) + barrel (2) + capsule (4) + egg (8)
    scope item_containers_spawn_toggle: {
        OS.patch_start(0xE99A4, 0x8016EF64)
        j       item_containers_spawn_toggle
        lw      a2, 0x000C(t2)              // original line 1
        _return:
        OS.patch_end()

        // a2 = item mask, t2 is nearby address of item mask, v0 is safe
        li      a3, Global.current_screen   // a3 = address of current screen
        lbu     a3, 0x0000(a3)              // a3 = current screen
        addiu   a3, a3, -Global.screen.VS_BATTLE // a3 = 0 if vs mode
        bnezl   a3, _end                    // skip if screen_id != vs mode
        nop
        beqzl   a2, _end                    // safety branch if vs item mask is empty (shouldn't happen)
        nop

        li      t3, Toggles.entry_item_containers
        lw      t3, 0x0004(t3)              // t3 = entry_item_containers (0 if DEFAULT, 1 if OFF, 2 if NO_EXPLODE, 3 if ALL_EXPLODE)
        beqzl   t3, _update_mask            // branch if DEFAULT
        ori     t3, a2, 0x000F              // enable barrels, capsules, etc.
        slti    t3, t3, 2                   // t3 = 0 if not OFF
        beqzl   t3, _update_mask            // based on the value, use appropriate container mask
        ori     t3, a2, 0x000F              // enable barrels, capsules, etc.

        andi    t3, a2, 0xFFFF0             // disable barrels, capsules, etc.
        // check if current stage is a Yoshi Island variant, which use eggs instead of capsules
        li      a2, Global.match_info
        lw      a2, 0x0000(a2)              // a2 = match info
        lbu     a2, 0x0001(a2)              // a2 = current stage ID
        lli     v0, Stages.id.YOSHIS_ISLAND // a2 = Stages.id.YOSHIS_ISLAND
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.YOSHI_ISLAND_DL
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.YOSHI_ISLAND_O
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.MINI_YOSHIS_ISLAND
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.YOSHI_STORY_2
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.YOSHIS_ISLAND_II
        beq     a2, v0, _update_mask
        lli     v0, Stages.id.YOSHIS_ISLAND_MELEE
        beq     a2, v0, _update_mask
        nop

        // if we're here, include eggs (current stage is not Yoshi Island)
        ori     t3, t3, 0x00008             // egg (8) is left enabled

        _update_mask:
        sh      t3, 0x000E(t2)              // save updated mask

        _end:
        lui     t3, 0x8013                  // original line 2
        j       _return                     // return
        lw      a2, 0x000C(t2)              // original line 1
    }

    // @ Description
    // Item Containers Explosion Toggle
    // Handles random explosiveness of item containers (Crates, Barrels, Capsules, Eggs)
    // Note: the contents of the containers don't change, just whether or not they blow up
    // 0 if DEFAULT, 1 if OFF, 2 if NO_EXPLODE, 3 if ALL_EXPLODE
    scope item_containers_explosions: {
        OS.patch_start(0xF40EC, 0x801796AC)
        j       item_containers_explosions.crate_hit
        nop
        OS.patch_end()
        // a0, at are safe
        crate_hit:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x801796B4                // return (no explode)
        nop
        j       0x801796BC                // original line 1, modified to jump (explode)
        nop

        OS.patch_start(0xF4290, 0x80179850)
        j       item_containers_explosions.crate_throw
        nop
        OS.patch_end()
        crate_throw:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x80179858                // return (no explode)
        nop
        j       0x80179860                // original line 1, modified to jump (explode)
        nop

        // @ Description
        // Allow crates to play explosion SFX when thrown
        // Note: normally they don't blow up without collision? (or it just doesn't play)
        OS.patch_start(0xF4038, 0x801795F8)
        j       item_containers_explosions.crate_throw_sfx
        nop
        crate_throw_sfx_return:
        OS.patch_end()

        crate_throw_sfx:
        li      a0, Toggles.entry_item_containers
        lw      a0, 0x0004(a0)            // a0 = entry_item_containers (0 if DEFAULT, 1 if OFF, 2 if NO_EXPLODE, 3 if ALL_EXPLODE)
        slti    a0, a0, 3                 // at = 1 if not ALL_EXPLODE
        beqzl   a0, pc() + 12             // based on the toggle, pick the appropriate sound effect
        addiu   a0, r0, 0x0001            // a0 = explode fgm_id
        addiu   a0, r0, 0x003C            // original line 2 (crate open 2 fgm_id)
        jal     0x800269C0                // original line 1 (play sound)
        nop
        j       crate_throw_sfx_return
        nop

        OS.patch_start(0xEEA44, 0x80174004)
        j       item_containers_explosions.capsule_hit
        nop
        OS.patch_end()
        capsule_hit:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x8017400C                // return (no explode)
        nop
        j       0x80174014                // original line 1, modified to jump (explode)
        nop

        OS.patch_start(0xEEBC4, 0x80174184)
        j       item_containers_explosions.capsule_throw
        nop
        OS.patch_end()
        capsule_throw:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x8017418C                // return (no explode)
        nop
        j       0x80174194                // original line 1, modified to jump (explode)
        nop

        OS.patch_start(0xF468C, 0x80179C4C)
        j       item_containers_explosions.barrel_roll
        nop
        OS.patch_end()

        barrel_roll:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x80179C54                // return (no explode)
        nop
        j       0x80179C5C                // original line 1, modified to jump (explode)
        nop

        OS.patch_start(0xFC090, 0x80181650)
        j       item_containers_explosions.egg_hit
        lw      a1, 0x0018(sp)            // original line 2
        OS.patch_end()
        egg_hit:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x80181658                // return (no explode)
        nop
        j       0x8018166C                // original line 1, modified to jump (explode)
        nop

        OS.patch_start(0xFC25C, 0x8018181C)
        j       item_containers_explosions.egg_toss
        lw      t6, 0x0018(sp)            // original line 2
        OS.patch_end()
        egg_toss:
        jal     _check_container_toggle
        nop
        // check the explosion flag and branch accordingly
        beqz    v0, pc() + 16             // if v0 = 0, the container explodes
        nop
        j       0x80181824                // return (no explode)
        nop
        j       0x80181838                // original line 1, modified to jump (explode)
        nop

        // shared toggle check function to save some lines of code
        _check_container_toggle:
        li      a0, Toggles.entry_item_containers
        lw      a0, 0x0004(a0)              // a0 = entry_item_containers (0 if DEFAULT, 1 if OFF, 2 if NO_EXPLODE, 3 if ALL_EXPLODE)
        slti    at, a0, 2                   // at = 1 if DEFAULT or OFF...
        bnez    at, _check_return           // ...in which case we follow original logic
        nop
        // otherwise we force it to explode or not explode based on the toggle
        andi    a0, a0, 1                   // v0 = 1 (triggers explosion) or 0 (does not explode)
        xori    v0, a0, 1                   // flip flag
        _check_return:
        jr      ra                          // return
        nop
    }

}

} // __ITEM__
