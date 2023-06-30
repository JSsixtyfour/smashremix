
    // @ Description
    // Subroutines used by AirDodge.
    scope LedgeJump {
    
        // @ Description
        // Initial routine that makes the player perform a jump
        scope jump_initial: {
            OS.routine_begin(0x20)
            lw      v0, 0x0084(a0)              // v0 = player object
            lui     at, 0x42A0                  // at = max stick jump height
            sw      at, 0x0B18(v0)              // save it
            sw      r0, 0x0B24(v0)              // ~
            lli     at, 1                       // jump type = stick jump
            jal     0x8013F880                  // common routine sets players state to jump
            sw      at, 0x0B20(v0)              // set temp var to short hop
            OS.routine_end(0x20)
        }
        
        // @ Description
        // Extend ledge hold input check to allow ledge jumping if the toggle is enabled.
        scope extend_ledge_input_check: {
            OS.patch_start(0xBF81C, 0x80144DDC)
            j       extend_ledge_input_check
            nop
            OS.patch_end()

            OS.read_word(Toggles.entry_ledge_jump + 0x4, at) // at = toggle value
            beqz    at, _normal     // skip c jump check
            nop
            
            // if here, toggle enabled
            jal     check_input     // check if c buttons pressed
            lw      a0, 0x0018(sp)  // a0 = player object

            bnezl   v0, _end
            lw      ra, 0x0014(sp)
            
            _normal:
            jal     0x80144E84      // check if time has run out on ledge (og line 1)
            lw      a0, 0x0018(sp)  // og line 2
            lw      ra, 0x0014(sp)

            _end:
            jr      ra
            addiu   sp, sp, 0x18
        }

        // @ Description
        // Routine that checks if player is pressing c while on ledge
        scope check_input: {
            OS.routine_begin(0x30)
            
            lw      v1, 0x0084(a0)      // v1 = player struct
            lh      t0, 0x01BE(v1)      // t0 = buttons pressed
            andi    t0, t0, Joypad.CL + Joypad.CR + Joypad.CU + Joypad.CD
            beqz    t0, _end
            addiu   v0, r0, 0           // return 0 (input not pressed)
            // if here, then a c button was pressed
            
            jal     0x80144FE8          // shared routine applies ledge getup value and changes action
            addiu   a1, r0, 0x0003      // made up value that lets them use our custom
            addiu   v0, r0, 1
            
            _end:
            OS.routine_end(0x30)
        }
        
        // @ Description
        // Jump if player is inputting a c jump while under 100 %
        scope extend_under_100_ledge_options: {
            OS.patch_start(0xBF964, 0x80144F24)
            j       extend_under_100_ledge_options
            nop
            OS.patch_end()
            
            jal     jump_initial
            nop
            
            _original:
            j       0x80144F58
            lw      ra, 0x0014(sp)
        }

        // @ Description
        // Jump if player is inputting a c jump while over 100 %
        scope extend_over_100_ledge_options: {
            OS.patch_start(0xBF9E8, 0x80144FA8)
            j       extend_over_100_ledge_options
            nop
            OS.patch_end()
            
            jal     jump_initial
            nop
            _original:
            j       0x80144FDC
            lw      ra, 0x0014(sp)
        }
        
    }