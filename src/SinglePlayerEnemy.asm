// SinglePlayerEnemy.asm
if !{defined __SINGLE_PLAYER_ENEMY__} {
define __SINGLE_PLAYER_ENEMY__()
print "included SinglePlayerEnemy.asm\n"

// @ Description
// This file allows other ports to play as opponent character in 1p Modes.

include "OS.asm"

scope SinglePlayerEnemy {

    // A flag to prevent spamming master hand
    enemy_selected:
    dw 0x0
    
    // The selected port, this is 0 by default, which allows CPU to control
    enemy_port:
    dw 0x0
    
    // Holds a reference to the custom stock icons file
    stock_icons_file:
    dw 0x0


    // Sets it so CPU 1 is set to a HMN player when toggle is on
    scope onep_control_port: {
       OS.patch_start(0x10E350, 0x8018FAF0)
       j        onep_control_port
       lw       t4, 0x0000(s0)          // load spawn ID
       _return:
       OS.patch_end()

       addiu    a0, r0, 0x0025          // place spawn ID of Computer 1 in a0
       bne      t4, a0, _normal         // if not setting up Computer 1, perform normal actions
       lbu      a0, 0x0023(v1)          // original line 2, loads in character id
       
       li       t6, SinglePlayerModes.singleplayer_mode_flag  // t6 = singleplayer flag address
       lw       t6, 0x0000(t6)          // t6 = 6 if HRC
       addiu    t4, r0, SinglePlayerModes.HRC_ID
       beq      t6, t4, _normal         // if HRC, proceed as normal
       nop
       
       li       t4, enemy_port
       lw       t4, 0x0000(t4)          // t4 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
       beqz     t4, _normal
       addiu    t4, t4, 0xFFFF          // subtract one to get correct port ID
       
       addiu    t6, r0, 0x0074          // place multiplier for each struct
       multu    t6, s1                  // multiply 0x0074 by actual port
       mflo     t6
       lw       at, 0x0000(s3)          // load relevant struct for different port/spawn information
       addu     t6, at, t6              // add offset to CPU 1 struct
       sb       t4, 0x0028(t6)          // save so that player tag identifies correct port color
       sb       t4, 0x002A(t6)          // save so that player tag identifies correct port id
       
       sll      t6, t4, 0x0002
       addu     t6, t6, t4
       sll      t6, t6, 0x1
       addu     t4, t6, t7              // get correct address of port inputs based on port using as opponent
       
       j        _return                 // return
       sb       r0, 0x0022(v1)          // set to be a HMN instead of CPU

       _normal:
       j        _return                 // return
       addu     t4, t2, t7              // original line 1, calculates port
    }

    // Sets it so CPU 1 is set to correct port when respawing in team modes
    scope onep_control_respawn: {
       OS.patch_start(0x10CD88, 0x8018E528)
       j        onep_control_respawn
       lw       t3, 0x0000(a3)          // load spawn ID
       _return:
       OS.patch_end()

       addiu    at, r0, 0x0025          // place spawn ID of Computer 1 in a0
       bne      t3, at, _normal         // if not setting up Computer 1, perform normal actions
       nop
              
       li       t3, enemy_port
       lw       t3, 0x0000(t3)          // t4 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
       beqz     t3, _normal
       addiu    t3, t3, 0xFFFF          // subtract one to get correct port ID
       
       
       sll      at, t3, 0x0002
       addu     at, at, t3
       sll      at, at, 0x1
       lui      t3, 0x8004
       addiu    t3, t3, 0x5228          // place hardcoded address for ports into t3
       addu     at, at, t3              // get correct address of port inputs based on port using as opponent
       sw       at, 0x002C(a0)          // save correct port to newly spawned team opponent

       _normal:
       ori      t3, t2, 0x0040          // original line 1
       j        _return                 // return
       sb       t3, 0x0063(sp)          // original line 2
    }   

    // Sets it so CPU 1 is set to have correct shield color
    scope onep_control_shield: {
       OS.patch_start(0x7C964, 0x80101164)
       j        onep_control_shield
       sw       r0, 0x001C(v1)          // original line 2
       _return:
       OS.patch_end()
       
       // a1 = player struct
       
       addiu        sp, sp, -0x0010        // allocate stack space
       sw           at, 0x0004(sp)         // ~
       sw           t6, 0x0008(sp)         // ~
       sw           t7, 0x000C(sp)         // ~
       
       li           t3, Global.current_screen   // ~
       lbu          t3, 0x0000(t3)              // t0 = current screen
       addiu        at, r0, 0x0001              // 1p screen id
       bnel         t3, at, _end
       lbu          t3, 0x000D(a1)          // original line 1, load port   
          
       li           t3, enemy_port
       lw           t3, 0x0000(t3)          // t4 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
       beqzl        t3, _end
       lbu          t3, 0x000D(a1)          // original line 1, load port
       
       lbu          t3, 0x0023(a1)          // load if hmn/cpu
       bnez         t3, _end
       lbu          t3, 0x000D(a1)          // original line 1, load port
 
       lui          t7, 0x8004
       addiu        t7, t7, 0x5228          // place hardcoded address for ports into t7
       lw           t6, 0x01B0(a1)          // load pointer to player's port
       sub          t6, t6, t7              // subtract from base to get offset

       bnez         t6, _calculate          // protects against a divide by 0 situation
       nop
       
       bnel         t6, t3, _end            // if the controlling port and player struct port do not equal, branch
       addu         t3, t6, r0              // set color to be aligned with controlling port
       
       beq          r0, r0, _end
       nop
       
       _calculate:
       addiu        t7, r0, 0x000A
       divu         t6, t7
       mflo         t6                      // these calculations reverse calculate the port that is controlling the character
       
       bnel         t6, t3, _end            // if the controlling port and player struct port do not equal, branch
       addu         t3, t6, r0              // set color to be aligned with controlling port

       _end:
       lw           at, 0x0004(sp)          // ~
       lw           t6, 0x0008(sp)          // ~
       lw           t7, 0x000C(sp)          // ~
       addiu        sp, sp, 0x0010          // allocate stack space
       j        _return                     // return
       nop
    }
    
    
    string_enemy:;  String.insert("Enemy Player")
    string_start:;  String.insert("Press Z")
    // @ Description
    // Adds Enemy Options to 1p CSS
    scope setup_: {

        OS.save_registers()
        
        Render.load_font()                                        // load font for strings

        // Press
        Render.draw_string(0x1E, 0x8, string_enemy, enemy_routine_, 0x42d80000, 0x43020000, 0xFFFFFFFF, 0x3F000000, Render.alignment.LEFT)
        sw      r0, 0x004C(v0)              // initialize blink timer

        Render.draw_string(0x1E, 0x8, string_start, enemy_routine_, 0x42d80000, 0x430c0000, 0xFFFFFFFF, 0x3F000000, Render.alignment.LEFT)
        sw      r0, 0x004C(v0)              // initialize blink timer
        
        Render.draw_texture_at_offset(0x1E, 0x8, 0x801396A0, 0x878, onep_routine_, 0x42d80000, 0x43020000, 0x8c161600, 0xFFFFFFFF, 0x3F800000)            // renders 1p
        nop
        
        Render.draw_texture_at_offset(0x1E, 0x8, 0x801396A0, 0xA58, twop_routine_, 0x42d80000, 0x43020000, 0x5c8ef200, 0xFFFFFFFF, 0x3F800000)            // renders 1p
        nop
        
        Render.draw_texture_at_offset(0x1E, 0x8, 0x801396A0, 0xC38, threep_routine_, 0x42d80000, 0x43020000, 0xbfb41d00, 0xFFFFFFFF, 0x3F800000)            // renders 1p
        nop
        
        Render.draw_texture_at_offset(0x1E, 0x8, 0x801396A0, 0xE18, fourp_routine_, 0x42d80000, 0x43020000, 0x24964300, 0xFFFFFFFF, 0x3F800000)            // renders 1p
        nop
        
        OS.restore_registers()

        _end:
        jr      ra
        nop
    }
    
    // @ Description
    // Gives the text blinking effects and controls when they are visible.
    // @ Arguments
    // a0 - enemy text object
    scope enemy_routine_: {
        // implement blink
        lw      t0, 0x004C(a0)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   t2, t0, 0x0029              // t2 = 1 if timer < 41, 0 otherwise
        sltiu   at, t0, 0x0050              // at = 1 if timer < 80, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 80, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x004C(a0)              // update timer

        addiu   t1, r0, -0x0001             // t1 = display on
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0000                  // t1 = display off
        beqz    t1, _end
        sw      t1, 0x0038(a0)              // update display

        // show/hide text based on selections
        li      t2, enemy_port
        lw      t2, 0x0000(t2)              // t2 = mode (0 - Normal, 1 - Selected)
        addiu   t1, r0, -0x0001             // t1 = display on
        bnezl   t2, pc() + 8                // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display
        
        _end:
        jr      ra
        nop
    }
    
    // @ Description
    // Make 1p appear/disappear
    // @ Arguments
    // a0 - enemy text object
    scope onep_routine_: {
        // show/hide text based on selections
        addiu   t1, r0, -0x0001             // t1 = display on
        li      t2, enemy_port
        lw      t2, 0x0000(t2)              // t2 = port
        addiu   t3, r0, 0x0001              // t1 = port 1
        bnel    t2, t3, pc() + 8            // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display
        
        _end:
        jr      ra
        nop
    }
    
    // @ Description
    // Make 2p appear/disappear
    // @ Arguments
    // a0 - enemy text object
    scope twop_routine_: {
        // show/hide text based on selections
        addiu   t1, r0, -0x0001             // t1 = display on
        li      t2, enemy_port
        lw      t2, 0x0000(t2)              // t2 = port
        addiu   t3, r0, 0x0002              // t1 = port 2
        bnel    t2, t3, pc() + 8            // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display
        
        _end:
        jr      ra
        nop
    }
    
    // @ Description
    // Make 3p appear/disappear
    // @ Arguments
    // a0 - enemy text object
    scope threep_routine_: {
        // show/hide text based on selections
        addiu   t1, r0, -0x0001             // t1 = display on
        li      t2, enemy_port
        lw      t2, 0x0000(t2)              // t2 = port
        addiu   t3, r0, 0x0003              // t1 = port 3
        bnel    t2, t3, pc() + 8            // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display
        
        _end:
        jr      ra
        nop
    }
    
    // @ Description
    // Make 4p appear/disappear
    // @ Arguments
    // a0 - enemy text object
    scope fourp_routine_: {
        // show/hide text based on selections
        addiu   t1, r0, -0x0001             // t1 = display on
        li      t2, enemy_port
        lw      t2, 0x0000(t2)              // t2 = port
        addiu   t3, r0, 0x0004              // t1 = port 4
        bnel    t2, t3, pc() + 8            // if Normal, update render flags so left arrow is not visible
        lli     t1, 0x0000                  // t1 = display off
        sw      t1, 0x0038(a0)              // update display
        
        _end:
        jr      ra
        nop
    }
    
    // Checks for z button press to set to HMN enemy control
    scope z_button: {
       OS.patch_start(0x14029C, 0x8013809C)
       j        z_button
       nop
       _return:
       OS.patch_end()

       jal      0x8039076C              // routine that checks for a button press and will output v0 0x1=port 1, 0x2=port2, ect.
       addiu    a0, r0, 0x2000          // z button mask
       
       li       t6, 0x80138FA8          // hard coded address for port selection
       lw       t6, 0x0000(t6)          // load port
       addiu    t6, t6, 0x1             // add one to match output
       beq      t6, v0, _check_start    // if the playing character presses z, ignore
       nop
       
       
       beqz     v0, _check_start        // if no port select
       nop
       
       li       t6, enemy_port          // load port address
       sw       v0, 0x0000(t6)          // save new port to location
       
       li       t7, enemy_selected      // load flag for selection
       lw       t6, 0x0000(t7)          // load if already selected HMN control
       
       bnez     t6, _check_start        // skip if already selected
       addiu    t6, r0, 0x0001
       sw       t6, 0x0000(t7)
       
       jal     0x800269C0               // play fgm
       addiu   a0, r0, 0x01ED           // place "Master Hand Laugh" FGM ID in a0
       
       
       _check_start:
       jal      0x8039076C              // original line 1, routine that checks for a button press and will output v0 0x1=port 1, 0x2=port2, ect.
       addiu    a0, r0, 0x1000          // original line 2, start button mask
       
       j        _return                 // return
       nop
    }
    
    // Checks for b button press to remove HMN enemy control
    scope b_button: {
       OS.patch_start(0x13EF28, 0x80136D28)
       j        b_button
       nop
       _return:
       OS.patch_end()

       addiu    sp, sp, -0x0018
       sw       t0, 0x0004(sp)
       sw       t1, 0x0008(sp)
       sw       t2, 0x000C(sp)
       sw       t3, 0x0010(sp)
       addiu    t2, r0, 0x0004          // set for loop for each port
       lui      t8, 0x8004              // original line 1
       addu     t8, t8, t7              // original line 2
       
       lui      t0, 0x8004              // load first part of hardcoded address for button presses
       li       t3, enemy_port          // load enemy port address
       
       _loop:
       beq      t0, t8, _skip
       nop
       lhu      t1, 0x522A(t0)          // load inputs
       andi     t1, t1, 0x4000          // b button mask
       bnezl    t1, _pressed            // if b is pressed, jump to pressed and clear port
       sw       r0, 0x0000(t3)          // clear port
       
       _skip:
       addiu    t2, t2, 0xFFFF          // add -1 to loop
       bnez     t2, _loop               // if haven't seen all ports, loop
       addiu    t0, t0, 0x000A          // get next ports inputs
       
       beq      r0, r0, _end
       nop
       
       _pressed:
       li       t1, enemy_selected
       sw       r0, 0x0000(t1)          // clear selection
       
       _end:
       lw       t0, 0x0004(sp)
       lw       t1, 0x0008(sp)
       lw       t2, 0x000C(sp)
       lw       t3, 0x0010(sp)
       addiu    sp, sp, 0x0018
       j        _return                 // return
       nop
    }

} // __SINGLE_PLAYER_ENEMY__