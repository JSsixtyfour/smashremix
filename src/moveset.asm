// Moveset.asm (Fray)

// This file adds support for reading moveset data from a pointer, and contains other moveset data
// related constants and macros.

scope Moveset {
    // @ Description
    // by default, 0x0004(t2) is an offset added to the base moveset file address
    // by default, a value of 0x80000000 is used to indicate no moveset data
    // new functionality will treat any value greater than 0x80000000 as a pointer to moveset data
    scope get_cmd_address_: {
        OS.patch_start(0x63140, 0x800E7940)
        j       get_cmd_address_
        nop
        origin  0x6316C
        base    0x800E796C
        _return:
        OS.patch_end()
        // s1 = player struct
        // v0 = moveset data address
        // t2 = action parameter struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // store t0
        sw      t1, 0x0008(sp)              // store t1

        _check_pointer:
        lw      t0, 0x0004(t2)              // t0 = moveset data offset/pointer
        bgez    t0, _end                    // skip if t0 is between 0x00000000 and 0x7FFFFFFF (offset)
        nop
        _check_none:
        lui     t1, 0x8000                  // t1 = 0x80000000
        beq     t0, t1, _end                // skip if t0 = 0x80000000 (no moveset data)
        nop
        or      v0, t0, r0                  // overwrite moveset data address

        _end:
        sw      t0, 0x0004(sp)              // load t0
        lw      t1, 0x0008(sp)              // load t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        sw      v0, 0x08AC(s1)              // store pointer
        sw      v0, 0x086C(s1)              // original line (store pointer)
        j       _return                     // return
        nop
    }

    // @ Description
    // adds a GO_TO moveset command
    macro GO_TO(address) {
        dw 0x90000000                       // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a LOOP moveset command
    macro LOOP(count) {
        dh 0x8000                       // command
        dh {count}                      // loop interations
    }
    
    // @ Description
    // adds a END_LOOP moveset command
    macro END_LOOP() {
        dw 0x84000000                       // command
    }

    // @ Description
    // adds a THROW_DATA moveset command
    macro THROW_DATA(address) {
        dw 0x30000000                       // command
        dw {address}                        // pointer
    }

    // @ Description
    // adds a WAIT moveset command
    macro WAIT(time) {
        dh 0x0400
        dh {time}
    }

    // @ Description
    // adds a AFTER moveset command
    macro AFTER(time) {
        dh 0x0800
        dh {time}
    }

    // @ Description
    // adds a HITBOX moveset command
    // bone_id - Bone ID to append hitbox to
    // ID_1 - ?
    // ID_2 - ?
    // x - offset x coordinate of hitbox
    // y - offset y coordinate of hitbox
    // z - offset z coordinate of hitbox
    // size - size of hitbox
    // hit_ground - TRUE if can hit grounded opponents
    // hit_air - TRUE if can hit aerial opponents
    // damage - hitbox damage amount
    // shield_damage - add or subtract damage if it hits a shield
    // damage_type - hitbox damage type (punch, kick, coin, burn)
    // clang - TRUE if hitbox clangs off other hitboxes
    // base_kb - hitbox base knockback
    // fixed_kb - hitbox fixed knockback
    // kb_scaling - hitbox knockback scaling
    // kb_angle - hitbox knockback angle
    // sfx_type - on-hit sfx to play
    // sfx_level - 0 = low, 1 = medium, 2 = high
    macro HITBOX(bone_id, ID_1, ID_2, x, y, z, size, hit_ground, hit_air, damage, shield_damage, damage_type, clang, base_kb, fixed_kb, kb_scaling, kb_angle, sfx_type, sfx_level) {
        dh  0x0C00 + (0x{ID_1}00 >> 1) + ({bone_id} >> 3)
        dh ({bone_id} << 13) + ({damage} << 5) + ({damage_type}) + ({clang} << 4)
        dh ({size} << 1)
        dh {x}
        dh {y}
        dh {z}
        dh ({kb_angle} << 6 ) + ({kb_scaling} >> 4)
        dh ({kb_scaling} << 12) + ({fixed_kb} << 2) + ({hit_ground} << 1) + ({hit_air})
        dh ({shield_damage} << 8) + ({sfx_level} << 5) + ({sfx_type} << 1)
        dh ({base_kb} << 7)
    }

    // @ Description
    // adds a END_HITBOXES moveset command
    macro END_HITBOXES() {
        dw  0x18000000
    }

    // @ Description
    // adds a HURTBOX_RESET moveset command
    // sets a single hurtbox to a specific state (1 = Vulnerable, 2 = Invincible, 3 = Intangible)
    macro HURTBOX_RESET() {
        dw  0x6C000000
    }

    // @ Description
    // adds a HURTBOX moveset command
    // sets a single hurtbox to a specific state (1 = Vulnerable, 2 = Invincible, 3 = Intangible)
    macro HURTBOX(bone_id, state) {
        dh  0x7000 + ({bone_id} << 3)
        dh {state}
    }

    // @ Description
    // adds a HURTBOXES moveset command
    // sets all hurtboxes to a specific state. (1 = Vulnerable, 2 = Invincible, 3 = Intangible)
    macro HURTBOXES(state) {
        dh 0x7400
        dh {state}
    }

    // @ Description
    // adds a CONCURRENT_STREAM moveset command
    macro CONCURRENT_STREAM(address) {
        dw 0xB8000000                       // command
        dw {address}                        // pointer
    }

    // @ Description
    // adds a SUBROUTINE moveset command
    macro SUBROUTINE(address) {
        dw 0x88000000                       // command
        dw {address}                        // pointer
    }

    // @ Description
    // adds a RETURN moveset command
    macro RETURN() {
        dw 0x8C000000                       // command
    }
    
    // @ Description
    // adds a END moveset command
    macro END() {
        dw 0x00000000                       // command
    }
    
    // @ Description
    // adds a CREATE_GFX command
    macro CREATE_GFX(bone, id, x1, y1, z1, x2, y2, z2) {
        dw 0x98000000 | (({bone} & 0xFF) << 19) | (({id} & 0xFF) << 10)  // command
        dh {x1}; dh {y1}; dh {z1}           // X/Y/Z (offset)
        dh {x2}; dh {y2}; dh {z2}           // X/Y/Z (range)
    }

    // @ Description
    // adds a RANDOM SFX moveset command
    macro RANDOM_SFX(chance_fgm, type, array_size, address) {
        db 0xD6 ; db {chance_fgm} ; db {type} ; db {array_size} // command
        dw {address}                        // pointer
    }

    // @ Description
    // adds a GO_TO_FILE command
    macro GO_TO_FILE(offset) {
        dh 0xDB00 ; dh {offset}
    }
    
    // @ Description
    // adds a SFX moveset command
    macro SFX(fgm_id) {
        dh 0x3800
        dh {fgm_id}
    }

    // @ Description
    // adds a VOICE moveset command
    macro VOICE(fgm_id) {
        dh 0x4400
        dh {fgm_id}
    }
    
    // @ Description
    // Alternate VOICE moveset command
    // Stops playing voice on action change
    macro VOICE_2(fgm_id) {
        dh 0x4800
        dh {fgm_id}
    }

    // @ Description
    // adds a ATTACK_VOICE moveset command
    // Uses a random attack voice from the Characters main file.
    macro ATTACK_VOICE() {
        dw 0x50000000
    }

    // @ Description
    // adds a SCREEN_SHAKE moveset command
    // intensity. 0 = low, 1 = medium, 2 = high
    macro SCREEN_SHAKE(intensity) {
        dh 0x9800
        if {intensity} == 0 {
            dh 0x8000 
        }
        if {intensity} == 1 {
            dh 0x8400 
        }
        if {intensity} == 2 {
            dh 0x8800 
        }
        dw 0, 0, 0;
    }



    // @ Description
    // adds a HIDE_ITEM moveset command
    macro HIDE_ITEM() {
        dw 0xC0000000;
    }

    // @ Description
    // adds a SHOW_ITEM moveset command
    macro SHOW_ITEM() {
        dw 0xC0000001;
    }
    
    // @ Description
    // adds a SET_FLAG moveset command
    // Sets variable 0x17C, 0x180, or 0x184 in player struct to TRUE
    macro SET_FLAG(id) {
        if {id} == 0 {
            dh  0x5400
        }
        if {id} == 1 {
            dh  0x5800
        }
        if {id} == 2 {
            dh  0x5C00
        }

        dh 0x0001;  // set flag to TRUE
    }

    // @ Description
    // Shared moveset files
    scope shared {
        insert BEAMSWORD_JAB,"moveset/BEAMSWORD_JAB.bin"
        insert BEAMSWORD_TILT,"moveset/BEAMSWORD_TILT.bin"
        insert BEAMSWORD_SMASH,"moveset/BEAMSWORD_SMASH.bin"
        insert BEAMSWORD_DASH,"moveset/BEAMSWORD_DASH.bin"
        insert BAT_JAB,"moveset/BAT_JAB.bin"
        insert BAT_TILT,"moveset/BAT_TILT.bin"
        insert BAT_SMASH,"moveset/BAT_SMASH.bin"
        insert BAT_DASH,"moveset/BAT_DASH.bin"
        insert FAN_JAB,"moveset/FAN_JAB.bin"
        insert FAN_TILT,"moveset/FAN_TILT.bin"
        insert FAN_SMASH,"moveset/FAN_SMASH.bin"
        insert FAN_DASH,"moveset/FAN_DASH.bin"
        insert STARROD_JAB,"moveset/STARROD_JAB.bin"
        insert STARROD_TILT,"moveset/STARROD_TILT.bin"
        insert STARROD_SMASH,"moveset/STARROD_SMASH.bin"
        insert STARROD_DASH,"moveset/STARROD_DASH.bin"
		insert DOWN_BOUNCE,"moveset/DOWN_BOUNCE.bin"
		insert CLIFF_CATCH,"moveset/CLIFF_CATCH.bin"
		insert CLIFF_WAIT,"moveset/CLIFF_WAIT.bin"

    }
}
