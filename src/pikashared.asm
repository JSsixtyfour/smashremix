// Pikashared.asm

// This file contains shared functions by Pika Clones.

scope PikaShared {

    // Custom recovery logic for lv10 Pikachu
    scope recovery_logic: {
        OS.routine_begin(0x20)

        // Apply only for lv10 CPUs
        lbu     t0, 0x13(a0) // t0 = cpu level
        slti    t0, t0, 10 // t0 = 0 if 10 or greater
        bnez    t0, _end // skip if not lv10
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.PIKACHU.QuickAttackStartAir
        beq t0, at, _usp_zip1
        lli t0, Action.PIKACHU.QuickAttackAir
        beq t0, at, _usp_zip2
        lli t0, Action.PIKACHU.QuickAttackEndAir
        beq t0, at, _usp_zip2
        nop

        b _end // no actions matched
        nop

        scope _usp_zip1: {
            // During QuickAttackStartAir, set target to a point
            // that is the angle towards ledge shifted up by a few degrees
            // so that the 2nd zip can come out
            // FTPIKACHU_QUICKATTACK_ANGLE_DIFF_MIN = 42.0F degrees = 0.7330383F radians
            addiu sp, sp, -0x30 // allocate memory
            sw a0, 0x14(sp)
            sw a1, 0x18(sp)

            lw t0, 0x78(a0) // load location vector
            lwc1 f2, 0x0(t0) // f2 = location X
            lwc1 f4, 0x4(t0) // f4 = location Y

            addiu t0, a0, 0x1cc // t0 = ftcomputer struct
            lwc1 f6, 0x60(t0) // target x
            lwc1 f8, 0x64(t0) // target y

            sub.s f14, f6, f2 // f14 = x diff
            swc1 f14, 0x8(sp) // save xdiff for later use when checking recovery direction
            sub.s f12, f8, f4 // f12 = y diff

            // Calculate distance to ledge. If too small, go directly to it instead
            mul.s f20, f14, f14 // f20 = (x distance)^2
            mul.s f22, f12, f12 // f22 = (y distance)^2
            add.s f20, f20, f22 // f20 = (x distance)^2 + (y distance)^2
            sqrt.s f20, f20 // f20 = sqrt((x distance)^2 + (y distance)^2) = distance to ledge

            lui at, 0x44FA
            mtc1 at, f22 // f22 = 2000.0 (approximately how much Pikachu moves with one zip)

            c.le.s f20, f22 // if distance to ledge is lower than 2000.0
            nop
            bc1t _execute_ai_command // skip this whole thing, just point to ledge
            nop

            jal 0x8001863C // f0 = atan2(f12,f14) (in radians)
            nop

            // FTPIKACHU_QUICKATTACK_ANGLE_DIFF_MIN = 42.0F degrees = 0.7330383F radians
            // All in all it depends on the distance we're from the ledge. Using 25 here
            li at, 0x3EDF66F3 // deviation = 25deg = 0.436332313rad
            mtc1 at, f10

            // Angle deviation: Going left: subtract/Going right: add = First zip is always upwards
            lwc1 f2, 0x8(sp) // f2 = xdiff
            mtc1 r0, f4 // f4 = 0
            // if going left, angle gets subtracted
            c.lt.s f2, f4 // if xdiff < 0 (going left)
            nop
            bc1f _add_angle
            add.s f12, f0, f10 // f12 = angle towards ledge + deviation < if the branch happens, this gets executed. Otherwise it's skipped!
            sub.s f12, f0, f10 // f12 = angle towards ledge - deviation < if the branch didn't happen, this will be executed instead
            _add_angle:
            swc1 f12, 0x10(sp) // save new angle to 0x10(sp)

            // now set the target to a point from Pikachu's location with this new angle
            // ultra64 cosf function
            jal 0x80035CD0 // f0 = cos(f12)
            lwc1 f12, 0x10(sp) // load new angle from 0x10(sp)

            lui at, 0x447A // 1000.0f
            mtc1 at, f6 // f6 = constant

            lw t0, 0x78(a0) // load location vector
            lwc1 f2, 0x0(t0) // f2 = location X
            mul.s f0, f0, f6 // f0 = cos(angle) * constant
            add.s f2, f2, f0 // f2 = location X + target offset
            addiu t0, a0, 0x1cc // t0 = ftcomputer struct
            swc1 f2, 0x60(t0) // save new target x

            // ultra64 sinf function
            jal 0x800303F0 // f0 = sin(f12)
            lwc1 f12, 0x10(sp) // load new angle from 0x10(sp)

            lui at, 0x447A // 1000.0f
            mtc1 at, f6 // f6 = constant

            lw t0, 0x78(a0) // load location vector
            lwc1 f4, 0x4(t0) // f4 = location Y
            mul.s f0, f0, f6 // f0 = sin(angle) * constant
            add.s f4, f4, f0 // f4 = location Y + target offset
            addiu t0, a0, 0x1cc // t0 = ftcomputer struct
            swc1 f4, 0x64(t0) // save new target y

            _execute_ai_command:
            lw a0, 0x14(sp)
            lw a1, 0x18(sp)

            jal 0x80132758 // execute AI command
            lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

            addiu sp, sp, 0x30 // deallocate memory

            b _end
            nop
        }

        _usp_zip2: {
            jal 0x80132758 // execute AI command
            lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target
            b _end
            nop
        }

        _end:
        OS.routine_end(0x20)
    }
    // Assign custom recovery logic to all Pikas
    Character.table_patch_start(recovery_logic, Character.id.PIKACHU, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.EPIKA, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JPIKA, 0x4)
    dw recovery_logic; OS.patch_end()

    scope cpu_post_process: {
        OS.routine_begin(0x20)

        // Apply only for lv10 CPUs
        lbu     t0, 0x13(a0) // t0 = cpu level
        slti    t0, t0, 10 // t0 = 0 if 10 or greater
        bnez    t0, _end // skip if not lv10
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.PIKACHU.QuickAttackStart
        beq t0, at, _usp_zip_down
        lli t0, Action.PIKACHU.QuickAttack
        beq t0, at, _usp_zip_down
        lli t0, Action.PIKACHU.QuickAttackEnd
        beq t0, at, _usp_zip_down
        lli t0, Action.PIKACHU.QuickAttackStartAir
        beq t0, at, _usp_zip_down
        lli t0, Action.PIKACHU.QuickAttackAir
        beq t0, at, _usp_zip_down
        lli t0, Action.PIKACHU.QuickAttackEndAir
        beq t0, at, _usp_zip_down
        nop

        b _end // no actions matched
        nop

        _usp_zip_down:
        // check if Pikachu is above clipping
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // skip if not above clipping
        nop

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = point to target

        addiu at, r0, 0xFFB0 // min stick Y value (down)
        sb at, 0x01C9(a0) // save CPU stick y

        sb r0, 0x01C8(a0) // CPU stick x = 0

        _end:
        OS.routine_end(0x20)
    }
    // Assign custom recovery logic to all Pikas
    Character.table_patch_start(cpu_post_process, Character.id.PIKACHU, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.EPIKA, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JPIKA, 0x4)
    dw cpu_post_process; OS.patch_end()

    // character ID check add for when Pika Clones perform rapid jab
    scope rapid_jab_fix_1: {
        OS.patch_start(0xC93B4, 0x8014E974)
        j       rapid_jab_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _rapid_jump             // modified original line 1
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v0, at, _rapid_jump
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v0, at, _rapid_jump
        nop
        j       _return                         // return
        addiu   at, r0, 0x0017                  // original line 2

        _rapid_jump:
        j       0x8014E984
        addiu   at, r0, 0x0017                  // original line 2
    }

    // character ID check add for when Pika Clones perform rapid jab
    scope rapid_jab_fix_2: {
        OS.patch_start(0xC921C, 0x8014E7DC)
        j       rapid_jab_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v1, at, _rapid_jump_2             // modified original line 1
        addiu   at, r0, Character.id.EPIKA      // EPIKA ID
        beq     v1, at, _rapid_jump_2
        addiu   at, r0, Character.id.JPIKA      // JPIKA ID
        beq     v1, at, _rapid_jump_2
        nop
        j       _return                         // return
        addiu   at, r0, 0x0017                  // original line 2

        _rapid_jump_2:
        j       0x8014E7EC
        addiu   at, r0, 0x0017                  // original line 2
    }

// character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_1: {
        OS.patch_start(0xCA898, 0x8014FE58)
        j       forward_smash_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _fsmash_jump          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump
        nop
        j       _return                     // return
        addiu   at, r0, 0x000B              // original line 2

        _fsmash_jump:
        j       0x8014FE80
        addiu   at, r0, 0x000B              // original line 2
    }

    // character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_2: {
        OS.patch_start(0xCABB0, 0x80150170)
        j       forward_smash_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _fsmash_jump_2          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump_2
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump_2
        nop
        j       _return                     // return
        addiu   t0, t0, 0x9C8C              // original line 2

        _fsmash_jump_2:
        j       0x801501A0
        addiu   t0, t0, 0x9C8C              // original line 2
    }

    // character ID check add for when Pika Clones perform Forward Smash
    scope forward_smash_fix_3: {
        OS.patch_start(0xCAB54, 0x80150114)
        j       forward_smash_fix_3
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _fsmash_jump_3          // modified original line 1
        addiu   at, r0, Character.id.EPIKA    // EPIKA ID
        beq     v0, at, _fsmash_jump_3
        addiu   at, r0, Character.id.JPIKA    // JPIKA ID
        beq     v0, at, _fsmash_jump_3
        nop
        j       _return                     // return
        lui    a3, 0x3F80              // original line 2

        _fsmash_jump_3:
        j       0x80150140
        lui    a3, 0x3F80              // original line 2
    }

    // establishes a pointer to the character struct that can be used for a character id check during
    // pikachu's down special.
    scope get_thunder_playerstruct1_: {
        OS.patch_start(0xE00C4, 0x80165684)
        j       get_thunder_playerstruct1_
        nop
        _return:
        OS.patch_end()

        lw      t2, 0x00DC(sp)              // load playerstruct into t2 for thunder
        sw      t2, 0x007C(s0)              // save playerstruct into projectile struct for thunder

        lw      t2, 0x0020(sp)              // load playerstruct into t2 for thunder jolt
        lw      t3, 0x0008(t2)              // load character ID from player struct

        lli     t4, Character.id.KIRBY      // t4 = id.KIRBY
        beql    t3, t4, pc() + 8            // if Kirby, get held power character_id
        lw      t3, 0x0ADC(t2)              // t3 = character id of copied power
        lli     t4, Character.id.JKIRBY     // t4 = id.JKIRBY
        beql    t3, t4, pc() + 8            // if J Kirby, get held power character_id
        lw      t3, 0x0ADC(t2)              // t3 = character id of copied power

        sw      t3, 0x0078(s0)              // save character id into projectile struct for thunder jolt

        lw      t2, 0x0080(sp)              // original line 1

        j       _return                     // return
        lw      v0, 0x0084(t2)              // original line 2
    }

    // establishes a pointer to the character struct that can be used for a character id check during
    // pikachu's down special.
    scope get_thunder_playerstruct2_: {
        OS.patch_start(0xE015C, 0x8016571C)
        j       get_thunder_playerstruct2_
        lw      v0, 0x0084(t0)              // original line 1
        _return:
        OS.patch_end()

        lw      t1, 0x007C(v0)              // load from parent struct for thunder
        sw      t1, 0x007C(s0)              // save to projectile struct 2 for thunder

        lw      t1, 0x0078(v0)              // load from parent struct for thunderjolt
        sw      t1, 0x0078(s0)              // save to projectile struct 2 for thunderjolt

        j       _return                     // return
        lw      t1, 0x0008(v0)              // original line 2
    }

    // loads in anim struct for Pika Clones for Thunder
    scope get_thunder_anim_struct_: {
        OS.patch_start(0x7D3A0, 0x80101BA0)
        j       get_thunder_anim_struct_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x0094(sp)              // load from projectile struct from stack
        lw      t1, 0x007C(t1)              // load player struct from projectile struct
        lw      t1, 0x0008(t1)              // load character ID from player struct

        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a0, thunder_anim_struct     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a0, thunder_anim_struct_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a0, 0x8013
        addiu   a0, a0, 0xE224              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        jal     0x800FDAFC                  // original line 1
        nop

        j       _return                     // return
        nop
    }

    // loads in anim struct for Pika Clones for Thunder Jolt
    scope get_thunder_jolt_anim_struct_: {
        OS.patch_start(0x7D448, 0x80101C48)
        j       get_thunder_jolt_anim_struct_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x0078(s0)              // load character ID from projectile struct from stack

        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a0, thunder_jolt_anim_struct_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a0, 0x8013
        addiu   a0, a0, 0xE24C              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        jal     0x800FDAFC                  // original line 1
        nop

        j       _return                     // return
        nop
    }

    // loads in special struct for pika clones for thunder jolt
    scope get_thunder_jolt_special_struct_1: {
        OS.patch_start(0xE4038, 0x801695F8)
        j       get_thunder_jolt_special_struct_1
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x0008(s1)              // load character ID from player struct

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power

        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_jolt_special_struct_1_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x90B0              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    // loads in special struct for pika clones for thunder jolt
    scope get_thunder_jolt_special_struct_2: {
        OS.patch_start(0xE4E94, 0x8016A454)
        j       get_thunder_jolt_special_struct_2
        ori     a3, a3, 0x0002              // original line 1
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x0078(s1)              // load character ID from projectile struct

        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_jolt_special_struct_2_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a1, 0x8019                  //
        addiu   a1, a1, 0x90E4              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    // loads in special struct for pika clones for thunder
    scope get_thunder_special_struct_1: {
        OS.patch_start(0xE5260, 0x8016A820)
        j       get_thunder_special_struct_1
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x006C(sp)              // load player struct from stack
        lw      t1, 0x0008(t1)              // load character ID from player struct

        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a1, thunder_special_struct_1     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_special_struct_1_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x9120              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

     // loads in special struct for pika clones for thunder
    scope get_thunder_special_struct_2: {
        OS.patch_start(0xE53D0, 0x8016A990)
        j       get_thunder_special_struct_2
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t1, 0x007C(t0)              // load player struct from projectile struct
        lw      t1, 0x0008(t1)              // load character ID from player struct

        ori     t2, r0, Character.id.EPIKA  // t2 = id.EPIKA
        li      a1, thunder_special_struct_2     // a0 = thunder_struct
        beq     t1, t2, _end                // end if character id = EPIKA
        ori     t2, r0, Character.id.JPIKA  // t2 = id.JPIKA
        li      a1, thunder_special_struct_2_jpika     // a0 = thunder_struct_jpika
        beq     t1, t2, _end                // end if character id = JPIKA
        nop

        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x9154              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    // EPIKA

    OS.align(16)
    thunder_anim_struct:
    dw  0x020F0000
    dw  Character.EPIKA_file_4_ptr
    OS.copy_segment(0xA9A2C, 0x20)

    OS.align(16)
    thunder_special_struct_1:
    dw 0x02000000
    dw 0x0000000B
    dw Character.EPIKA_file_1_ptr
    OS.copy_segment(0x103B6C, 0x40)

    OS.align(16)
    thunder_special_struct_2:
    dw 0x02000000
    dw 0x0000000C
    dw Character.EPIKA_file_1_ptr
    OS.copy_segment(0x103BA0, 0x40)

    // JPIKA

    OS.align(16)
    thunder_anim_struct_jpika:
    dw  0x020F0000
    dw  Character.JPIKA_file_4_ptr
    OS.copy_segment(0xA9A2C, 0x20)

    OS.align(16)
    thunder_special_struct_1_jpika:
    dw 0x02000000
    dw 0x0000000B
    dw Character.JPIKA_file_1_ptr
    OS.copy_segment(0x103B6C, 0x40)

    OS.align(16)
    thunder_special_struct_2_jpika:
    dw 0x02000000
    dw 0x0000000C
    dw Character.JPIKA_file_1_ptr
    OS.copy_segment(0x103BA0, 0x40)

    OS.align(16)
    thunder_jolt_anim_struct_jpika:
    dw  0x040F0000
    dw  Character.JPIKA_file_8_ptr
    OS.copy_segment(0xA9A54, 0x20)

    OS.align(16)
    thunder_jolt_special_struct_1_jpika:
    dw 0x00000000
    dw 0x00000009
    dw Character.JPIKA_file_6_ptr
    OS.copy_segment(0x103AFC, 0x40)

    OS.align(16)
    thunder_jolt_special_struct_2_jpika:
    dw 0x03000000
    dw 0x0000000A
    dw Character.JPIKA_file_6_ptr
    OS.copy_segment(0x103B30, 0x40)

    // Pikachu shares hardcodings with Jigglypuff and some of his hardcodings are in jigglypuffkirbyshared.asm

    }
