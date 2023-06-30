// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0x00000000)

// @ Description
// Offset to item in file.
constant FILE_OFFSET(0xC0)

OS.align(16)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x00000000                           // 0x00 - item ID (will be updated by Item.add_item
dw 0x801313F4                           // 0x04 - address of file pointer (this is a hardcoded address that leads to Onett Header)
dw FILE_OFFSET                          // 0x08 - offset to item footer
dw 0x1C000000                           // 0x0C - render routine indexes - 0x1C considers scale
dw 0x00000000                           // 0x10 - ?

item_states:
// state 0 - aerial
dw main_                                // 0x14 - state 0 main
dw 0x00000000                           // 0x18 - state 0 collision
dw 0x00000000                           // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0x00000000                           // 0x20 - state 0 hitbox collision w/ shield
dw 0x00000000                           // 0x24 - state 0 hitbox collision w/ shield edge
dw 0x00000000                           // 0x28 - state 0 unknown (maybe absorb)
dw 0x00000000                           // 0x2C - state 0 hitbox collision w/ reflector
dw 0x00000000                           // 0x30 - state 0 hurtbox collision w/ hitbox
// state 1 - collided with a wall
dw main_                                // 0x34 - state 1 main
dw 0x00000000                           // 0x38 - state 1 collision
dw 0x00000000                           // 0x3C - state 1 hitbox collision w/ hurtbox
dw 0x00000000                           // 0x40 - state 1 hitbox collision w/ shield
dw 0x00000000                           // 0x44 - state 1 hitbox collision w/ shield edge
dw 0x00000000                           // 0x48 - state 1 unknown (maybe absorb)
dw 0x00000000                           // 0x4C - state 1 hitbox collision w/ reflector
dw 0x00000000                           // 0x50 - state 1 hurtbox collision w/ hitbox
// state 2 - exploding
dw 0x8017D298                           // 0xD4 - state 2 main
dw 0                                    // 0xD8 - state 2 collision
dw 0                                    // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0                                    // 0xE0 - state 2 hitbox collision w/ shield
dw 0                                    // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0                                    // 0xE8 - state 2 unknown (maybe absorb)
dw 0                                    // 0xEC - state 2 hitbox collision w/ reflector
dw 0                                    // 0xF0 - state 2 hurtbox collision w/ hitbox

OS.align(16)

    // @ Description
    // This establishes the hazard object
    scope initial_setup: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)

        // _check_hazard:
        li      t0, Toggles.entry_hazard_mode
        lw      t0, 0x0004(t0)              // t0 = hazard_mode (hazards disabled when t0 = 1 or 3)
        andi    t0, t0, 0x0001              // t0 = 1 if hazard_mode is 1 or 3, 0 otherwise
        //bnez    t0, _end                    // if hazard_mode enabled, skip original
        b _end
        nop

        li      t1, 0x80131300              // load the hardcoded address where header address (+14) is located
        lw      t1, 0x0000(t1)              // load aforemention address

        sw      r0, 0x0008(t1)              // clear spot used for timer

        addiu   t1, t1, -0x0014             // acquire address of header
        lw      t3, FILE_OFFSET(t1)         // load pointer to item
        addiu   t3, t3, -0x0740             // subtract offset amount to get to top of car file
        li      t2, 0x801313F0              // load hardcoded space used by hazards, generally for pointers
        sw      t3, 0x0000(t2)              // save car header address to first word of this struct, as pirhana plant does the same
        sw      t1, 0x0004(t2)              // save car header address to second word of this struct, as Pirhana Plant does the same

        sw      r0, 0x0054(sp)
        sw      r0, 0x0050(sp)
        sw      r0, 0x004C(sp)
        addiu   t6, r0, 0x0001
        sw      t6, 0x0010(sp)

        jal     get_random_spawn_location   // v0 = coordinate pointer address
        nop
        addiu   a2, v0, 0                   // a2 = coordinate pointer address
        sw      v0, 0x0018(sp)              // save pointer to stackspace
        addiu   a0, r0, 0x03F5              // set object ID
        lli     a1, Item.BulletBill.id      // set item id to car
        jal     0x8016EA78                  // spawn stage item
        addiu   a3, sp, 0x0050              // a3 = address of setup floats
        // v0 = stage item
        beqz    v0, _end                        // branch if no item created
        nop
        lw      a0, 0x0018(sp)              // load pointer from stackspace
        li      t0, bullet_shot             // t0 = address of car_honked flag
        sw      r0, 0x0000(t0)              // reset car_honked flag

        _end:
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0068
    }
    
    scope get_random_spawn_location: {
        OS.routine_begin(0x30)
        jal     Global.get_random_int_
        addiu   a0, num_possible_locations - 1
        sll     v0, v0, 5
        li      t0, Item.BulletBill.coordinates
        addu    v0, t0, v0                      // v0 = pointer to coordinates
        OS.routine_end(0x20)                    // return
    }

    constant blast_zone_left(-9800)     // -9800
    constant blast_zone_right(9800)     // 9800
    constant blast_zone_top(-3800)      // -3800
    constant blast_zone_bottom(8750)    // 8750
    constant middle_y(701)
    constant quarter_x(2200)
    constant x_speed(300)               // 300
    constant y_speed(250)               // 250

    constant num_possible_locations(7)

    // @ Description
    // Sets the object position, rotation and speed.
    // Seven possible places to spawn.
    coordinates:
    // middle left
    float32 blast_zone_left             // 0x00  x
    float32 middle_y                    // 0x04  y
    dw 0                                // 0x08  z
    float32 x_speed                     // 0x0C  x speed
    float32 0                           // 0x10  y speed
    float32 0                           // 0x14  x rotation
    float32 90                          // 0x18  z rotation
    dw      0                           // 0x01C reserved
    
    // diagonal top left
    float32 blast_zone_left
    float32 blast_zone_top
    dw 0                                // z
    float32 x_speed
    float32 -y_speed
    float32 0
    float32 45
    float32 90
    dw      0                           // reserved
    
    // downwards top left
    float32 -quarter_x
    float32 blast_zone_top
    dw 0                                // z
    float32 0
    float32 y_speed
    float32 90
    float32 90
    dw      0                           // reserved
    
    // downwards top middle
    float32 0
    float32 blast_zone_top
    dw 0                                // z
    float32 0
    float32 y_speed
    float32 90
    float32 90
    dw      0                           // reserved
    
    // middle right
    float32 blast_zone_right
    float32 middle_y
    dw 0                                // z
    float32 -x_speed
    float32 0
    float32 0
    float32 -90
    dw      0                           // reserved
    
    // diagonal top right
    float32 blast_zone_right
    float32 blast_zone_top
    dw 0                                // z
    float32 -x_speed
    float32 -y_speed
    float32 0
    float32 -45
    float32 90
    dw      0                           // reserved
    
    // downwards top right
    float32 quarter_x
    float32 blast_zone_top
    dw 0                                // z
    float32 0
    float32 y_speed
    float32 -90
    float32 90
    dw      0                           // reserved
    
    bullet_shot:
    dw 0

    // @ Description
    // main routine for car
    scope main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)

        sw      v1, 0x0024(sp)
        sw      a2, 0x0018(sp)              // save item special struct to stack

        li      t1, Global.current_screen   // ~
        lbu     t1, 0x0000(t1)              // t0 = screen_id
        ori     t2, r0, 0x0036              // ~
        beq     t2, t1, _skip_check         // skip if screen_id = training mode
        nop

        li      t6, Global.match_info       // ~
        lw      t6, 0x0000(t6)              // t6 = match info struct
        lw      t6, 0x0018(t6)              // t6 = time elapsed
        beqz    t6, _end                    // if match hasn't started, don't begin
        nop

        _skip_check:
        li      t5, 0x801313F0
        lw      t6, 0x0008(t5)          // load timer
        addiu   t7, t6, 0x0001          // add to timer

        li      t4, bullet_shot          // t4 = address of car_honked flag
        lw      at, 0x0000(t4)          // at = 1 if the car has honked, 0 otherwise
        beqz    at, _pre_shoot           // branch if the car hasn't honked yet
        nop
        sw      t7, 0x0008(t5)          // save updated timer
        slti    t8, t6, 0x0023          // wait 35 frames
        beqzl   t8, _spawn              // if 35 or greater, spawn
        sw      r0, 0x0000(t4)          // reset car_honked flag
        b       _end
        nop

        _pre_shoot:
        slti    t8, t6, 0x0A8C          // wait 2700 frames
        bne     t8, r0, _end            // if not 2700 or greater, skip to end, this is the initial check, car won't spawn until at least 484 frames
        sw      t7, 0x0008(t5)          // save updated timer
        sw      t6, 0x0010(sp)          // save original timer
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x00c8          // decimal 200 possible integers
        lw      a0, 0x0020(sp)          // load registers
        addiu   t4, r0, 0x0050          // place 50 as the random number to spawn car
        beq     t4, v0, _shot           // if 50, honk and prepare to spawn car
        addiu   t4, r0, 0x0E10          // put in max time before car, 3600 frames
        lw      t6, 0x0010(sp)          // load timer from stack
        blt     t4, t6, _end            // if not same as timer, skip honk
        nop

        _shot:
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 0x041C          // fgm id (car honk)
        li      t4, bullet_shot         // t4 = address of bullet_shot flag
        addiu   at, r0, 0x0001          // at = 1
        sw      at, 0x0000(t4)          // bullet_shot flag = true
        sw      r0, 0x0008(t5)          // restart timer
        b       _end
        nop

        // car is spawned
        _spawn:
        addiu   at, r0, 0x0001
        sw      at, 0x010C(a2)          // enable hitbox
        sw      at, 0x0038(s0)          // make bullet bill visible again
        sw      r0, 0x0008(t5)          // restart timer
        jal     0x800269C0              // play fgm
        addiu   a0, r0, 001013          // fgm id = 1013 (cannon shot)

        _end:
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        addu    v0, r0, r0
    }

    // @ Description
    // Subroutine which sets up initial properties.
    // a0 - no associated object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope stage_setting_: {
        addiu   sp, sp,-0x0070                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a1, 0x0038(sp)                  // 0x0038(sp) = unknown
        li      a1, Item.BulletBill.item_info_array
        sw      r0, 0x0040(sp)
        sw      r0, 0x0044(sp)
        sw      r0, 0x0048(sp)
        sw      r0, 0x004C(sp)
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        addiu   a3, sp, 0x0040                  // velocity settings
        addiu   t6, r0, 0x0001                  // unknown, used by pirhana plant
        jal     0x8016E174                      // create item
        sw      t6, 0x0010(sp)                  // argument 4(unknown) = 1
        beqz    v0, _end                        // end if no item was created
        or      a0, v0, r0                      // a0 = item object
        
        sw      v0, 0x0074(sp)                  // save new item object
        jal     get_random_spawn_location       // v0 = coordinate pointer address
        nop
        addiu   a2, v0, 0                       // a2 = x/y/z to set


        // item is created
        //sw      r0, 0x0038(v0)                // save to object struct to make car invisible
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      t9, 0x0074(v0)                  // load location struct 2
        lui     t2, 0x3f40
        sw      t2, 0x0040(t9)
        sw      t2, 0x0044(t9)
        sw      t2, 0x0048(t9)                  // reduce scale to 0.75
        
        // set coordinates
        addiu   t2, r0, 0x00B4                  // unknown flag used by pirhana
        sh      t2, 0x033E(v1)                  // save flag
        lw      t4, 0x0000(a2)
        sw      t4, 0x001C(t9)                  // save initial x coordinates
        lw      t4, 0x0004(a2)
        sw      t4, 0x0020(t9)                  // set initial y
        lw      t4, 0x0008(a2)
        sw      t4, 0x0024(t9)                  // set initial z

        // set rotation
        lw      t4, 0x0014(a2)
        sw      t4, 0x0030(t9)                  // save initial x rotation
        lw      t4, 0x0018(a2)
        sw      t4, 0x0038(t9)                  // set initial z rotation

        // set speed
        lw      t4, 0x000C(a2)
        sw      t4, 0x002C(v0)                  // save initial x speed
        lw      t4, 0x0030(a2)
        sw      t4, 0x0038(v0)                  // set initial y speed
        sw      r0, 0x0034(v0)                  // z speed = 0

        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag

        lui     at, 0x442F                      // 700 (fp)
        sw      at, 0x0138(v1)                  // save hitbox size
        addiu   t4, r0, 0x0014                  // hitbox damage set to 20
        sw      t4, 0x0110(v1)                  // save hitbox damage
        addiu   t4, r0, 0x0010                  // horizontal hit
        sw      t4, 0x013C(v1)                  // save hitbox angle to location
        lui     t4, 0xc42f
        sw      t4, 0x0124(v1)                  // save to hitbox y offset
        lui      t4, 0xc496
        sw      t4, 0x0128(v1)                  // save to hitbox z offset so it can hit players
        // 0x0118 damage multiplier
        addiu   t4, r0, 0x0000                  // slash effect id
        sw      t4, 0x011C(v1)                  // knockback effect - 0x0 = normal
        addiu   t4, r0, 0x011F                  // sound effect
        sh      t4, 0x0156(v1)                  // save hitbox sound
        addiu   t4, r0, 0x0080                  // put hitbox bkb at 140
        sw      t4, 0x0148(v1)                  // set hitbox bkb
        addiu   t4, r0, 0x0020                  // put hitbox kbs at 20
        sw      t4, 0x0140(v1)                  // set hitbox kbs

        lbu     t4, 0x02D3(v1)
        ori     t5, t4, 0x0008
        sb      t5, 0x02D3(v1)
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        sw      r0, 0x35C(v1)
        li      t1, blast_zone_                 // blast zone routine
        sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

        _end:
        or      v0, a0, r0                      // v0 = item object
        lw      s0, 0x0020(sp)                  // ~
        lw      s1, 0x0024(sp)                  // ~
        lw      ra, 0x0028(sp)                  // load s0, s1, ra
        jr      ra                              // return
        addiu   sp, sp, 0x0070                  // deallocate stack space
    }


    // @ Description
    // this routine gets run by whenever a projectile crosses the blast zone.
    scope blast_zone_: {
        j       0x8016F8C0                      // jump to address that bomb/grenade normally goes to
        nop
    }