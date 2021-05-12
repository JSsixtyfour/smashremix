scope SinglePlayerModes: {

    // 80192FA1 - counts down KOs
    // 801938C8 - counts down KOs
    // camera stuff is a mystery
    // platforms and amount on css: 80133A9C
        // 80133AE0 specifically platforms and not targets
    // Bonus 2 CSS Header: 80133260

    // 80133B38 gets platform number
    // 80133B64 platform loading routine
    // 80131CEC is a number loading subroutine called on different css screens
        // a1= number in hex
        // a2= x position
        // a3= y position

//  FLAGS

    // @ Description
    // Flag used for various purposes in the added Modes of Remix
    // 0x0001 = Bonus 3, 0x0002 = Multiman, 0x0003 = Cruel Multiman, 0x0000 = standard
    singleplayer_mode_flag:
    db OS.FALSE
    OS.align(4)

    // @ Description
    // Flag to indicate if we should reset the match or return to css menu
    // TRUE = Reset, FALSE = CSS
    reset_flag:
    db OS.FALSE
    OS.align(4)

    // @ Description
    // Flag to indicate if we should play the New Record Sound at the end of a match
    // TRUE = Play Sound, FALSE = Normal
    new_record_flag:
    db OS.FALSE
    OS.align(4)
    
    // @ Description
    // Flag to indicate if we are on page 1 or 2 of Singeplayer Menu (ie. Standard Modes vs. Remix Modes
    page_flag:
    db OS.FALSE
    OS.align(4)
    
    // @ Description
    // Flag to indicate if the player has been KO'd
    // 0 = alive, 1 = KO
    player_ko:
    db OS.FALSE
    OS.align(4)

// CONSTANTS

    constant KO_AMOUNT_POINTER(0x801936A0)
    constant TIME_SAVE_POINTER(0x800A4B30)
    constant REMIX_1P_ID(0x4)
    constant CRUEL_ID(0x3)
    constant MULTIMAN_ID(0x2)
    constant BONUS3_ID(0x1)
    constant MENU_INDEX(0x801331B8)
    constant STAGE_FLAG(0x800A4AE7)

// SHARED FUNCTIONS

    // @ Description
    // This changes the Bonus 2 screen to function so that it goes to 1p screen and generally sets up Multiman and Bonus 3
    // Essentially its setting the basic "1p settings" to work properly in these modes which get set at the beginning of 1p (difficulty, character, ect.)
    // It also handles seed advancement (to get different polygon characters on 1st load)
    scope bonus2_css_2_1p: {
        OS.patch_start(0x14CAF8, 0x80136AC8)
        j       bonus2_css_2_1p
        lui     v0, 0x800A                 // original line 1
        _return:
        OS.patch_end()

        addiu   v0, v0, 0x4AD0               // original line 2
        li      t5, singleplayer_mode_flag
        lw      t5, 0x0000(t5)
        addiu   t6, r0, REMIX_1P_ID
        
        bnez    t5, _1p_load
        nop
        
        _1p:
        j       _return
        nop


        _1p_load:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      at, 0x0008(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      v1, 0x0014(sp)              // store a0, at, v0, v1 (for safety)
        
        li      t3, 0x8003B6E4              // ~
        lw      t3, 0x0000(t3)              // t3 = frame count for current screen
        andi    t3, t3, 0x003F              // t3 = frame count % 64
        
        _loop:
        // advances rng between 1 - 64 times based on frame count when entering stage selection
        jal     0x80018910                  // this function advances the rng seed
        nop
        bnez    t3, _loop                   // loop if t8 != 0
        addiu   t3, t3,-0x0001              // subtract 1 from t8
        
        _end_seed:
        lw      a0, 0x0004(sp)              // ~
        lw      at, 0x0008(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      v1, 0x0014(sp)              // load a0, at, v0, v1
        addiu   sp, sp, 0x0020              // deallocate stack space
        
        li      t5, singleplayer_mode_flag
        lw      t5, 0x0000(t5)
        addiu   t6, r0, REMIX_1P_ID
        beq     t6, t5, _1p                 // proceed as normal if Remix 1p
        nop       
        
        lbu     t3, 0x0000(v0)
        addiu   t5, r0, 0x0034
        sb      t5, 0x0000(v0)              // sets screen to 1p
        jal     _1p_stage_setting           // refreshes 1p and sets the stage for it
        sb      t3, 0x0001(v0)
        jal     0x80005C74
        nop
        beq     r0, r0, end
        lw      ra, 0x0014(sp)
        
        end:
        addiu   sp, sp, 0x0018
        jr      ra
        nop
        
        // based on 0x80137F10, 0x140118
        // t6 is 5, t7 is port ID), t8 is difficulty, t0 is 1, t9 is stocks, t3 is 0, one of the unknown ones is probably used for a check to refresh
        // 80137F98
        _1p_stage_setting:
        addiu   t6, r0, 0x0005          // unclear what this 5 is for
        lui     v0, 0x800A
        addiu   v0, v0, 0x4AD0
        lui     t7, 0x8013
        lw      t7, 0x76F8(t7)          // load port ID
        sb      t6, 0x0016(v0)
        addiu   t8, r0, 0x0002          // set to normal difficulty for now
        lui     a0, 0x8014
        addiu   a0, a0, 0x8EE8
        sb      r0, 0x0017(v0)          // unknown
        lui     v1, 0x800A
        sb      t7, 0x0013(v0)
        addiu   v1, v1, 0x44E0
        addiu   t0, r0, 0x0001          // unknown purpose
        // sb       t8, 0x0454(v1)      // this sets the difficulty, but causes a conflict out of bonus 2 that leads to sram issues
        addiu   t9, r0, 0x0000          // stocks set 1
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)
        beq     t0, r0, _skip1
        // sb       t9, 0x045B(v1)      // this sets the stocks, but causes a conflict out of bonus 2 that leads to sram issues
        nop
        
        lui     t1, 0x8013
        addiu   t1, t1, 0x7668
        lw      t1, 0x0000(t1)          // loads character ID of selected character in Bonus 2 CSS
        beq     r0, r0, _skip2
        sb      t1, 0x0014(v0)
        
        _skip1:
        addiu   t2, r0, 0x001C
        sb      t2, 0x0014(v0)
        
        _skip2:
        li      t3, 0x8013766C
        lw      t3, 0x0000(t3)
        jal     0x800D45F4
        sb      t3, 0x0015(v0)
        
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    // @ Description
    // The game has hardcoded RAM addresses for opponent types in a 1p match, this establishes those used in the added modes
    // setting polygon loading ram address
    //     8018 +
    //    D874 = (Normal) Opponent 1/2 (allies only work on this) (a third opponent is a random character if added)
    //    DAC0 = Opponent 1 x3 (all six costumes)
    //    DC64 = Fighting Polygon Team x3
    //    DDD0 = Opponent 1 x2 (single costume only)
    //    DEEC = Fighting Polygon Team x3 (no on-screen appearance)
    scope opponent_type: {
        OS.patch_start(0x10C0C4, 0x8018D864)
        j       opponent_type
        nop                                 // original line 2
        _return:
        OS.patch_end()
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t1, 0x0004(sp)              // ~
        addiu   t1, r0, BONUS3_ID
        li      at, singleplayer_mode_flag  // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        beq     at, t1, _bonus3
        addiu   t1, r0, REMIX_1P_ID
        beq     at, t1, _1p
        nop
        bnez    at, _multiman               // if multiman, skip
        nop
        
        _1p:
        lui     at, 0x8019
        addu    at, at, t6                  // original line 1
        lw      t6, 0x2E84(at)              // original line 2
        lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        j       _return
        nop
        
        _multiman:
        lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        li      t6, 0x8018DC64
        j       _return
        nop
        
        _bonus3:
        lw      t1, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        
        li      t6, 0x8018DEEC
        j       _return
        nop
    }

    // @ Description
    // loads in the Style of battle FF (normal) vs. 80 (horde)
    scope battle_style: {
    OS.patch_start(0x10E18C, 0x8018F92C)
        j        battle_style
        nop
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag    // t6 = multiman flag
        lw      t6, 0x0000(t6)                // t6 = 1 if multiman
        addiu   at, r0, REMIX_1P_ID
        beq     t6, at, _1p                   // NORMAL 1P IF REMIX 1P
        nop
        bnez    t6, _multiman                 // if multiman, skip
        nop

        _1p:
        jal     0x80115DE8                    // original line 1
        lbu     a0, 0x29BC(a0)                // original line 2
        j       _return
        nop

        _multiman:
        jal     0x80115DE8                    // original line 1
        addiu   a0, r0, 0x0080
        j       _return
        nop
    }

    // @ Description
    //  loads the stage in 1p
    scope _1p_stage: {
        OS.patch_start(0x10BEC4, 0x8018D664)
        j        _1p_stage
        addiu   t5, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      t4, singleplayer_mode_flag  // t4 = multiman flag
        lw      t4, 0x0000(t4)              // t4 = 1 if multiman
        beq        t4, t5, _bonus3
        addiu    t5, r0, REMIX_1P_ID
        
        beq        t4, t5, _1p
        nop
        
        bnez    t4, _multiman               // if multiman, skip
        nop
        
        _1p:
        lbu        t4, 0x0001(s7)           // original line 1
        lw        t5, 0x0000(s6)            // original line 2
        j        _return
        nop
        
        _multiman:
        addiu    t4, r0, 0x000E             // load in Duel Zone
        lw        t5, 0x0000(s6)            // original line 2
        j        _return
        nop
        
        _bonus3:
        addiu    t4, r0, 0x000F             // load in RTF
        lw        t5, 0x0000(s6)            // original line 2
        j        _return
        nop
    }
    
    // @ Description
    //  Set team attack or not
    scope _team_attack: {
        OS.patch_start(0x10BEF0, 0x8018D690)
        j        _team_attack
        addiu    t8, r0, BONUS3_ID              // Bonus 3 Mode Flag
        _return:
        OS.patch_end()
        
        li      t7, singleplayer_mode_flag      // t7 = multiman flag
        lw      t7, 0x0000(t7)                  // t7 = 2 if multiman
        beq        t7, t8, _bonus3
        addiu    t8, r0, REMIX_1P_ID            // Remix 1p Mode Flag
        
        beql    t7, t8, _1p
        nop
        
        bnez    t7, _multiman                   // if multiman, skip
        nop
        
        _1p:
        lw        t7, 0x0000(s6)                // original line 1
        j        _return
        sb        t6, 0x0009(t7)                // original line 2
        
        _multiman:
        lw        t7, 0x0000(s6)                // original line 1
        addiu    t6, r0, 0x0000                 // set team attack off
        j        _return
        sb        t6, 0x0009(t7)                // original line 2
        
        _bonus3:
        lw        t7, 0x0000(s6)                // original line 1
        addiu    t6, r0, 0x0001                 // set team attack on
        j        _return
        sb        t6, 0x0009(t7)                // original line 2
        }
        
    //  @ Description
    //  Set Item Spawn rate
    scope _item_spawn: {
        OS.patch_start(0x10BF64, 0x8018D704)
        j        _item_spawn
        addiu    a1, a1, 0x2FA1                 // original line 2
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag      // t6 = multiman flag
        lw      t6, 0x0000(t6)                  // t6 = 2 if multiman
        
        addiu t4, r0, REMIX_1P_ID
        beq        t4, t6, _1p
        nop
        
        bnez    t6, _multiman                   // if multiman, skip
        nop
        
        _1p:
        j       _return 
        lbu     t6, 0x0001(t3)                  // original line 1
                        
        _multiman:              
        j       _return             
        addiu   t6, r0, 0x0000                  // set item spawn rate to none
        }
    
    // @ Description
    // Set player handicap/knockback ratio
    scope _hmn_knockback: {
        OS.patch_start(0x5209C, 0x800D689C)
        j        _hmn_knockback
        addiu   a0, r0, CRUEL_ID
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag      // t6 = multiman flag
        lw      t6, 0x0000(t6)                  // t6 = 3 if cruel multiman
        bne     t6, a0, _end                    // if not Cruel Multiman, skip to end
        nop
        
        addiu   a3, r0, 0x0016
        
        _end:
        mflo    t6                              // original line 1
        j       _return
        addu    a0, s4, t6                      // original line 2
    }

    // @ Description
    //    Set Opponent CPU knockback ratio
    scope _opponent_knockback: {
        OS.patch_start(0x10BDAC, 0x8018D54C)
        j        _opponent_knockback
        addu    t5, t9, v1                      // original line 2
        _return:
        OS.patch_end()
        
        li      t8, singleplayer_mode_flag      // t8 = multiman flag
        lw      t8, 0x0000(t8)                  // t8 = 1 if multiman
        addiu   t5, r0, BONUS3_ID
        beq     t8, t5, _bonus3                 // if multiman, skip
        addiu   t5, r0, MULTIMAN_ID
        beq     t8, t5, _multiman               // if multiman, skip
        addiu   t5, r0, CRUEL_ID
        beq     t8, t5, _cruel                  // if cruel multiman, skip
        addu    t5, t9, v1                      // original line 2
        
        j       _return
        lbu     t8, 0x0007(t7)                  // original line 1
        
        _bonus3:
        addu    t5, t9, v1                      // original line 2
        j       _return
        addiu   t8, r0, 0x0009                  // set opponent knockback to what it is on RTF on very hard
        
        _multiman:
        addu    t5, t9, v1                      // original line 2
        j       _return
        addiu   t8, r0, 0x0015                  // set opponent knockback to what it is on easy
        
        _cruel:
        j       _return
        addiu   t8, r0, 0x0018                  // set opponent knockback to what it is on very hard
        }
    
    // @ Description    
    //  Loads number of opponents
    scope _opponent_number_1: {
        OS.patch_start(0x10BF74, 0x8018D714)
        j        _opponent_number_1
        addiu   at, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      t4, singleplayer_mode_flag      // t4 = multiman flag
        lw      t4, 0x0000(t4)                  // t4 = 1 if multiman
        beq     t4, at, _bonus3
        lui     at, 0x8019                      // original line 2
        addiu   at, r0, REMIX_1P_ID
        beq        t4, at, _1p
        lui     at, 0x8019                      // original line 2
        bnez    t4, _multiman                   // if multiman, skip
        nop
        
        _1p:
        j       _return
        lbu     t4, 0x0008(s7)                  // original line 1
        
        _multiman:
        j       _return
        addiu   t4, r0, 0x0006                  // set opponent number to 6 for no real reason
        
        _bonus3:
        j        _return
        addiu    t4, r0, 0x0003                 // set opponent number to 3 as is normally done
        }
    
    // @ Description     
    //    Loads opponent number
    scope _opponent_number_2: {
        OS.patch_start(0x10C234, 0x8018D9D4)
        j        _opponent_number_2
        nop
        _return:
        OS.patch_end()

        li      t8, singleplayer_mode_flag      // t8 = SinglePlayerMode flag
        lw      t8, 0x0000(t8)                  // t8 = 0 if original 1p

        addiu   t5, r0, REMIX_1P_ID
        beq     t8, t5, _1p
        nop
        bnez    t8, _multiman                   // if multiman, skip
        nop

        _1p:
        lbu     t8, 0x0008(s7)                  // refresh
        blezl   t8, branch                      // original line 1
        lw      t5, 0x0000(s6)                  // original line 2
        j       _return
        nop

        _multiman:
        j       _return
        addiu   t8, r0, 0x0004                  // set to polygon number

        branch:
        j       0x8018FFF4
        nop
        j       _return
        nop
        }

    // @ Description  
    //  Loads opponent 2
    scope _opponent_2: {
        OS.patch_start(0x10BDC0, 0x8018D560)
        j        _opponent_2
        addiu   t5, r0, 0x0003                  // original line 2
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag      // t7 = multiman flag
        lw      t7, 0x0000(t7)                  // t7 = 1 if multiman
        addiu    t8, r0, REMIX_1P_ID
        beq        t7, t8, _1p
        nop
        bnez    t7, _multiman                   // if multiman, skip
        nop

        _1p:
        j        _return
        lbu        t7, 0x0009(t6)               // original line 1

        _multiman:
        j       _return
        addiu   t7, r0, 0x001C                  // set to empty or random
        }

    // @ Description  
    //    Sets time limit routine by loading in hardcoded ram address
    scope _time_limit: {
        OS.patch_start(0x10BF04, 0x8018D6A4)
        j        _time_limit
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()

        li      at, singleplayer_mode_flag      // at = SingePlayer Mode flag
        lw      at, 0x0000(at)                  // at = 0 if original 1p
        addiu    t8, r0, REMIX_1P_ID
        beq        t8, at, _1p
        nop
        bnez    at, _multiman                   // if multiman or Bonus 3, skip
        nop

        _1p:
        sltiu   at, t9, 0x0007
        beq        at, r0, _branch
        sll        t9, t9, 0x2
        lui        at, 0x8019
        addu    at, at, t9
        j       _return
        lw      t9, 0x2E68(at)

        _branch:
        j       0x8018D6E0
        nop
        lui     at, 0x8019
        addu    at, at, t9
        j       _return
        lw      t9, 0x2E68(at)

        _multiman:
        li      t9, 0x8018D6D0                  // infinite time
        j       _return
        nop
        }

    // @ Description
    //    Stops strange glitch which messes up position of percents during the transition from 34 to 35 KOs
    scope _percent_fix: {
        OS.patch_start(0x10D930, 0x8018F0D0)
        j        _percent_fix
        addiu   t4, t4, 0x33D0                  // original line 1
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag      // t9 = multiman flag
        lw      t6, 0x0000(t6)                  // t9 = 1 if multiman
        addiu    t5, r0, MULTIMAN_ID
        beq     t6, t5, _multiman               // if multiman, skip
        addiu    t5, r0, CRUEL_ID
        beq     t6, t5, _multiman               // if multiman, skip
        nop

        _standard:
        j        _return
        addu    v0, t3, t4                      // original line 2

        _multiman:
        addiu    t6, r0, 0x04E0
        bne        t6, t3, _standard
        nop
        li        v0, 0x80193400                // load in alternate safe address
        j        _return
        nop
    }

    // @ Description
    // Loads in routine which sets up how cpus spawn and how the camera works
    scope _spawning_style: {
    OS.patch_start(0x10D360, 0x8018EB00)
        j       _spawning_style
        addu    at, at, t6                      // original line 1
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      t0, 0x0004(sp)                  // ~
        addiu   t0, r0, BONUS3_ID
        li      t6, singleplayer_mode_flag      // t6 = multiman flag
        lw      t6, 0x0000(t6)                  // t6 = 1 if multiman
        beq     t6, t0, _bonus3                 // branch if Bonus 3
        addiu   t0, r0, REMIX_1P_ID             // Remix 1p ID entered

        beq     t6, t0, _remix_1p               // Branch if Remix 1p
        nop

        bnez    t6, _multiman                   // if a multiman mode, branch
        nop
        beq     r0, r0, _1p                     // if all other checks fail, go to original 1p coding
        lw      t0, 0x0004(sp)                  // ~
        
        _remix_1p:
        li      t0, 0x800A4AE7
        lbu     t0, 0x0000(t0)                  // load from current progress of 1p ID
        addiu   t6, r0, 0x000D
        beq     t0, t6, _giga
        lw      t0, 0x0004(sp)                  // ~
        
        _1p:
        addiu   sp, sp, 0x0010                  // deallocate stack space
        j        _return
        lw        t6, 0x2EE0(at)                // original line 2
        
        _giga:
        addiu   sp, sp, 0x0010                  // deallocate stack space
        li      t6, 0x8018EB10                  // load normal spawn
        j        _return
        nop

        _multiman:
        lw      t0, 0x0004(sp)                  // ~
        addiu   sp, sp, 0x0010                  // deallocate stack space
        li        t6, 0x8018EB20
        j        _return
        nop

        _bonus3:
        lw      t0, 0x0004(sp)                  // ~
        addiu   sp, sp, 0x0010                  // deallocate stack space
        li      t6, 0x8018EB30
        j       _return
        nop
    }

    // @ Description
    //  Initial Screen Transition Setting in 1p, this is used for multiman in order to skip the title card screen
    scope _initial_screen_set: {
        OS.patch_start(0x12DC90, 0x80134950)
        j       _initial_screen_set
        addiu   t9, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      at, singleplayer_mode_flag  // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        beq     t9, at, _1p
        addiu   t9, r0, 0x0001              // original line 1
        
        bnez    at, _multiman               // if multiman, skip
        nop
        
        _1p:
        j       _return
        sb      t9, 0x0000(v0)              // original line 2
        
        _multiman:
        addiu    t9, r0, 0x0077             // set to an unused screen for purposes of the odd mechanics of 1p screens and loading custom renders
        j        _return
        sb        t9, 0x0000(v0)            // original line 2, this was causing an issue with rendering the correct objects on the right screen
    }

    // @ Description
    // This makes the reset button graphic appear in Bonus 3, Multiman, and Cruel
    scope _reset_button: {
        OS.patch_start(0x8F668, 0x80113E68)
        j       _reset_button
        addiu   at, r0, 0x0077              // Bonus 3, Multiman, Cruel Man "screen" (fake screen)
        _return:
        OS.patch_end()
        
        beq     t7, at, _reset
        addiu   at, r0, 0x0035              // original check
        bne     t7, at, _normal             // original line 1 modified
        nop
        
        _reset:
        j       _return                     // path taken to show Reset Button
        nop
        
        _normal:
        j       0x80113EA0
        lw      ra, 0x0024(sp)              // original line 2
    }

    // @ Description
    // This sets adds the reset feature present in other bonus modes by tweaking a branch and also sets the reset flag to 1
    scope _reset: {
        OS.patch_start(0x8FD28, 0x80114528)
        j        _reset
        addiu    at, r0, 0x0077             // Bonus 3, Multiman, Cruel Man "screen" (fake screen)
        _return:
        OS.patch_end()
        
        
        beq     t9, at, _multiman           // Branch if one fake screen 
        addiu   at, r0, 0x0035              // set screen ID under normal circumstances
        bne     t9, at, _normal             // modified original line 1
        nop
        j       _return
        nop
        
        _multiman:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)
        sw      t1, 0x0008(sp)
        li      t0, reset_flag              // load reset flag location
        addiu   t1, r0, 0x0001              // save a one to it so that it is set to reset
        sw      t1, 0x0000(t0)              // ~
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        j       _return
        nop
        
        _normal:
        j       0x80114560
        nop
    }

    // @ Description
    // Loads the Bonus 3 version of timer
    scope _load_timer: {
        OS.patch_start(0x10E558, 0x8018FCF8)
        j       _load_timer
        addiu   at, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag  // t9 = multiman flag
        lw      t6, 0x0000(t6)              // t9 = 1 if multiman
        beq     t6, at, _bonus3             // if Bonus 3, skip
        addiu   t6, r0, 0x0000              // clear out register in abundance of caution
        
        jal     0x8018F1F8
        nop
        j       _return
        nop
        
        _bonus3:
        jal     bonus3_timer
        nop
        j       0x8018FD08
        nop
    }
    
    // @ Description
    //  Sets up custom timer for Bonus 3 that works within existing infrastructure, used by _load_timer. This is a modified version of code used on Bonus screens (we actually use 1p Screen)
    scope bonus3_timer: {
        addiu    sp, sp, 0xFFB8
        
        OS.copy_segment(0x112A94, 0x20)             // 8018E344 in Bonus
        
        sdc1    f20, 0x0018(sp)
        jal     0x80113398                          // may want to skip, used for function of timer
        or      a0, r0, r0                          // may want to skip, used for function of timer
        
        // skip some Bonus stuff that isn't relevant
      
        OS.copy_segment(0x112AC4, 0x44)             // 8018E384 to C4 in Bonus, identical to normal version
        
        lui     at, 0x41F0
        mtc1    at, f22
        lui     at, 0x3F00
        lui     s3, 0x0000
        li      s1, bonus3_timer_struct             // replacement for normal hardcoding that isn't present in 1p
        li      s0, timer_free_space
        addiu   s5, r0, 0x0006
        addu    s5, s0, s5
        lui     s2, 0x8013
        mtc1    at, f20
        addiu   s2, s2, 0x0D40
        addiu   s3, s3, 0x0138
        lw      t8, 0x000C(s2)
        or      a0, s4, r0
        jal     0x800CCFDC
        addu    a1, t8, s3
        
        OS.copy_segment(0x112B50, 0x114)            // 8018E410 to 8018e520
        
        li      a1, update_routine                  // replaces hardcoded subroutine that is put into action by 0x80008188 below
        cvt.s.w f6, f10
        
        OS.copy_segment(0x112C70, 0x58)             // 8018e530, probably relates to animation tracks
        
        jal     0x80008188                          // starts update subroutine
        swc1    f8, 0x005C(v0)
        lw      ra, 0x0044(sp)
        
        // skip some Bonus stuff that isn't relevant
        
        OS.copy_segment(0x112CF0, 0x28)             // 8018E5B0, end of subroutine
        
        bonus3_timer_struct_2:
        dw        0x470CA000
        dw        0x45610000
        dw         0x44160000
        dw        0x42700000
        dw        0x40C00000
        dw        0x3F0DD2F2
        bonus3_timer_struct:
        dw        0x000000CF
        dw        0x000000DE
        dw        0x000000F0
        dw        0x000000FF
        dw        0x00000111
        dw        0x00000120
        
        // routine responsible for updating the timer throughout the match
        update_routine:
        li        t6, 0x800A4B18                    // this replaces a pointer being loaded from a hardcoded location to find a stage information struct that includes current time
        
        OS.copy_segment(0x11285C, 0x18)             // 8018E11C to 8018E294
        
        li      a2, bonus3_timer_struct_2
        bnez    at, _branch1
        nop
        lui     v0, 0x0003
        ori     v0, v0, 0x4BBF
        _branch1:
        mtc1    v0, f4
        
        OS.copy_segment(0x11288C, 0x24)
        
        li      a3, timer_free_space
        li      t2, timer_free_space
        addiu   t4, r0, 0x0006
        addu    t4, t2, t4
        li      t1, bonus3_timer_struct
        lui     t0, 0x8013
        lui     a0, 0x8013
        mtc1    at, f12
        addiu   a0, a0, 0xEE94
        addiu   t0, t0, 0x0D40
        addiu   t3, r0, 0xFFFB
        
        OS.copy_segment(0x1128E8, 0xF0)            // 8018E11C to 8018E294
        
        timer_free_space:
        dw        0x00000000
        dw        0x00000000
        dw        0x00000000
        dw        0x00000000
    }

    // @ Description
    //  This sets it so that at the end of a Multiman or Bonus 3 mode match, it returns to the bonus 2 css screen. This is used when character dies or when match cancelled
    scope _end_match_screen: {
        OS.patch_start(0x523D4, 0x800D6BD4)
        j       _end_match_screen
        lw      t4, 0x004C(sp)                // original line 2
        _return:
        OS.patch_end()
        
        li      t3, singleplayer_mode_flag       // t3 = multiman flag
        lw      t3, 0x0000(t3)              // t3 = 2 if multiman
        addiu   t2, r0, REMIX_1P_ID
        beq     t3, t2, _1p               // if multiman, skip
        nop
        bnez    t3, _multiman               // if multiman, skip
        nop
        
        _1p:
        lbu     t3, 0x0012(s2)                // refresh t3
        j       _return
        addiu   t2, r0, 0x0008                // original line 2
                
        _multiman:
        li      t2, reset_flag
        lw      t3, 0x0000(t2)
        bne     t3, r0, _reset
        addiu   t3, r0, 0x0001                // set to take correct branch
        j       _return
        addiu   t2, r0, 0x0014                // set to Bonus 2 CSS Screen
        
        _reset:
        sw      r0, 0x0000(t2)                // save 0 to reset_flag location so future matches don't automatically reset
        j       _return
        addiu   t2, r0, 0x0034                // set to Bonus 2 CSS Screen
    }

    // @ Description
    // This saves the amount of KOs to SRAM block when the Player Character loses their stock
    scope _ko_save: {
        OS.patch_start(0x10D8A4, 0x8018F044)
        j        _ko_save
        addiu    at, r0, MULTIMAN_ID            // insert check
        _return:
        OS.patch_end()
        
        li      t8, singleplayer_mode_flag      // t8 = multiman flag
        lw      t8, 0x0000(t8)                  // t8 = 2 if multiman
        beq     t8, at, _multiman               // if multiman, skip
        addiu   at, r0, CRUEL_ID                // insert check
        beq     t8, at, _cruel                  // if multiman, skip
        nop
        
        lb      t8, 0x002B(a2)                  // original line 1
        j       _return
        addiu   at, r0, 0xFFFF                  // original line 2
        
        
        _cruel:
        addiu   sp, sp,-0x0018                  // allocate stack space
        sw      a0, 0x0004(sp)                  // ~
        sw      a1, 0x0008(sp)                  // ~
        sw      a2, 0x000C(sp)                  // ~
        sw      ra, 0x0010(sp)                  // ~
        
        li      t8, KO_AMOUNT_POINTER
        lw      t8, 0x0000(t8)
        li      at, Character.CRUEL_HIGH_SCORE_TABLE
        lw      a0, 0x0008(s0)
        sll     a0, a0, 0x0002
        addu    a1, at, a0
        lw      a0, 0x0000(a1)
        ble     t8, a0, _end
        nop
        li      a0, Character.CRUEL_HIGH_SCORE_TABLE_BLOCK
            
        jal     SRAM.save_
        sw      t8, 0x0000(a1)
        
        j       _end
        nop
        
        _multiman:
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        
        li        t8, KO_AMOUNT_POINTER
        lw        t8, 0x0000(t8)
        li        at, Character.MULTIMAN_HIGH_SCORE_TABLE
        lw        a0, 0x0008(s0)
        sll        a0, a0, 0x0002
        addu    a1, at, a0
        lw        a0, 0x0000(a1)
        ble        t8, a0,    _end
        nop
        li        a0, Character.MULTIMAN_HIGH_SCORE_TABLE_BLOCK
            
        jal        SRAM.save_
        sw        t8, 0x0000(a1)
        
        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0018              // deallocate stack space
        lb        t8, 0x002B(a2)                // original line 1
        j       _return
        addiu    at, r0, 0xFFFF                // original line 2
    }

    // @ Description
    //    This saves the time to SRAM block when the Player Character complete race to the finish
    scope _time_save: {
        OS.patch_start(0x90564, 0x80114D64)
        j        _time_save
        addiu    a1, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        
        sw        ra, 0x0014(sp)            // original line 1
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t4, 0x0004(sp)              // ~
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        li      a0, singleplayer_mode_flag     // a0 = multiman flag
        lw      a0, 0x0000(a0)            // a0 = 1 if bonus 3
        bne     a0, a1, _original         // if multiman, skip
        nop
        
        
        li        a1, TIME_SAVE_POINTER                    // time address loaded in
        li        a3, Character.BONUS3_HIGH_SCORE_TABLE    // high score table start loaded in
        lw        a0, 0x0008(v0)                            // character ID loaded in
        sll        a0, a0, 0x0002                            // shifted left to find character's word
        addu    a3, a0, a3                                // character's save location address put in a3
        lw         t2, 0x0000(a3)                            // load in current record
        beq        t2, r0, _no_previous_record                // if there is no record, skip next check and new record sound effect function
        lw        t4, 0x0000(a1)                            // finish time loaded in
        li        t0, 0xAAAAAAAA
        beq        t2, t0, _no_previous_record                // console fix
        nop
        //li        t0, 0x00034BC0
        //sltu    t1, t2, t0
        //blez    t1, _no_previous_record                // fail safe
        //nop
        
        sltu    t1, t4, t2
        beq        t1, r0, _original                        // if record is a quicker time, do not save new time
        nop
        
        li        t0, new_record_flag
        addiu    t1, r0, 0x0001
        sw        t1, 0x0000(t0)
        
        _no_previous_record:
        li        a0, Character.BONUS3_HIGH_SCORE_TABLE_BLOCK
        sw      t4, 0x0000(a3)
        lw      t4, 0x0000(sp)                // ~
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)                // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal        SRAM.save_
        nop
        j        _return
        lui        a0, 0x8011                  // original line 2
        
        _original:
        lw      t4, 0x0000(sp)                // ~
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw        t2, 0x000C(sp)                // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        lui     a0, 0x8011                  // original line 2
    }

    // @ Description
    //    This saves the time to SRAM block when the Player Character complete race to the finish
    scope _new_record: {
        OS.patch_start(0x8F038, 0x80113838)
        j        _new_record
        addiu    at, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      t9, singleplayer_mode_flag     // a0 = multiman flag
        lw      t9, 0x0000(t9)            // a0 = 1 if bonus 3
        bne     at, t9, _end              // if not Bonus 3, skip
        nop
            
        li        t9, new_record_flag            // load new record flag address
        lw        at, 0x0000(t9)                // load current flag
        beq        at, r0, _end                // if not a new record, proceed as normal
        addiu    at, r0, 0x01CB                // insert the Complete! sound id into at
        bne        at, a0, _end                // if a0 does not equal Complete! sound, skip
        sw        r0, 0x0000(t9)                // return new record flag to 0
        addiu    a0, r0, 0x1D0                // insert new record sound ID into a0 for later saving
            
        _end:
        lui        at, 0x8013                // original line 1
        j       _return
        addu    at, at, t8                // original line 2
    }

    // @ Description
    // This sets opponent behavior to polygon style
    // 0 = normal
    // 1 = Link Style (initial pause)
    // 2 = Yoshi Team Style
    // 3 = Kirby Team Style
    // 4 = Fighting Polygon Team Style
    // 5 = Mario Bros Style
    // 6 = Giant Donkey Kong Style
    // 8 = Race to the Finish Style
    scope _opponent_behavior: {
        OS.patch_start(0x10BE54, 0x8018D5F4)
        j        _opponent_behavior
        addiu    t5, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      t8, singleplayer_mode_flag    // t8 = multiman flag
        lw      t8, 0x0000(t8)                // t8 = 1 if multiman
        beq     t5, t8, _bonus3
        addiu   t5, r0, REMIX_1P_ID
        beq     t5, t8, _1p
        nop
        bnez    t8, _multiman                 // if multiman, skip
        nop
        
        _1p:
        lbu     t8, 0x000B(a0)                // original line 1
        j       _return
        sb      t8, 0x2FF8(at)                // original line 2
        
        _multiman:
        addiu   t8, r0, 0x0004                // set opponent behavior ID
        j       _return
        sb      t8, 0x2FF8(at)                // original line 2
        
        _bonus3:
        addiu   t8, r0, 0x0008                // set opponent behavior ID
        j       _return
        sb      t8, 0x2FF8(at)                // original line 2
    }

    // @ Description
    //    Prevents a counter from changing so that spawns may continue indefinitely
    scope _infinite_spawn_1: {
    OS.patch_start(0x10CBEC, 0x8018E38C)
        j        _infinite_spawn_1
        sw        v1, 0x000C(a3)                    // original line 1
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag       // t4 = multiman flag
        lw      t7, 0x0000(t7)              // t4 = 1 if multiman
        addiu    at, r0, REMIX_1P_ID
        beq        at, t7, _1p
        nop

        bnez    t7, _multiman               // if multiman, skip
        nop

        _1p:
        j        _return
        addiu    t7, v0, 0x0001                // original line 2

        _multiman:
        j        _return
        addiu    t7, v0, r0                    // prevent change to spawn counter 1
        }

    // @ Description
    //    Prevents of branch from being taken that occassionally leads to crashes and serves no purpose
    scope _death_crash: {
    OS.patch_start(0x10D8B4, 0x8018F054)
        j        _death_crash
        nop
        _return:
        OS.patch_end()

        li      t9, singleplayer_mode_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // 
        addiu    at, r0, REMIX_1P_ID
        beq        at, t9, _1p
        addiu    at, r0, 0x0005                // original line 2
        bnez    t9, _multiman               // if multiman, skip
        nop

        _1p:
        j        _return
        lbu        t9, 0x0011(a3)                // original line 2

        _multiman:
        j        _return
        addiu    t9, r0, 0x0001                // set to safe number that won't take branch
        }

    // @ Description
    //    Prevents a counter from changing so that spawns may continue indefinitely
    scope _infinite_spawn_2: {
    OS.patch_start(0x10CA2C, 0x8018E1CC)
        j        _infinite_spawn_2
        addiu    t8, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag       // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 1 if multiman
        beq        t7, t8, _1p
        nop
        bnez    t7, _multiman               // if multiman, skip
        nop

        _1p:
        addiu    t7, v0, 0xFFFF                // original line 1
        j        _return
        sb        t7, 0x0000(v1)                // original line 2

        _multiman:
        j        _return
        nop
        }

    // @ Description
    //    Prevents a counter from changing so that match never ends due to KOs of opponents
    scope _infinite_ko: {
    OS.patch_start(0x10D910, 0x8018F0B0)
        j        _infinite_ko
        nop
        _return:
        OS.patch_end()

        li      t9, singleplayer_mode_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        addiu    t3, r0, REMIX_1P_ID
        beq        t3, t9, _1p
        nop

        bnez    t9, _multiman               // if multiman, skip
        nop

        _1p:
        or        t9, t5, t8                    // original line 2
        j        _return
        sb        t4, 0x0000(a2)                // original line 1

        _multiman:
        j        _return
        or        t9, t5, t8                    // original line 2                                // does save lowered KO countdown
    }

    // @ Description
    //    automatically skips preview in multiman by skipping timer and button press checks
    scope _preview_skip: {
    OS.patch_start(0x12DC64, 0x80134924)
        j        _preview_skip
        addiu    t7, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      at, singleplayer_mode_flag       // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        beq        at, t7, _1p
        nop

        bnez    at, _multiman               // if multiman, skip
        _1p:
        sltiu    at, v0, 0x003C                // reinsert at
        bnel    at, r0, _branch                // modified original line 1
        lw        ra, 0x0014(sp)                // original line 2

        j        _return
        nop

        _branch:
        j        0x801349EC
        nop

        j        _return
        nop

        _multiman:
        j        0x80134934
        nop
        j        _return
        nop
    }

    // @ Description
    //    automatically skips preview song in multiman by skipping a jal
    scope _preview_song_skip: {
    OS.patch_start(0x12E0B0, 0x80134D70)
        j        _preview_song_skip
        nop
        _return:
        OS.patch_end()

        li      a1, singleplayer_mode_flag       // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 1 if multiman
        addiu    t6, r0, REMIX_1P_ID
        beq        a1, t6, _1p
        nop
        bnez    a1, _multiman               // if multiman, skip
        nop

        _1p:
        jal        0x80020AB4
        addiu    a1, r0, 0x0023

        j        _return
        nop

        _multiman:
        j        _return
        addiu    a1, r0, r0                    // clear a1 just in case
    }

    // @ Description
    // Skips a c flag function which delays music change
    scope skip_cflag_music_function: {
        OS.patch_start(0x10E514, 0x8018FCB4)
        j       skip_cflag_music_function
        addiu    at, r0, MULTIMAN_ID            // multiman mode check placed in
        _return:
        OS.patch_end()
        
        li      v0, singleplayer_mode_flag       // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 2 if multiman
        beq     v0, at, _multiman           // if multiman, skip
        addiu    at, r0, CRUEL_ID            // multiman mode check placed in
        beq     v0, at, _multiman           // if cruel multiman, skip
        nop

        lui        v0, 0x800A                    // original line 1
        j        _return
        lbu        v0, 0x4AE7(v0)                // original line 2

        _multiman:
        lui        v0, 0x800A                    // original line 1
        j       0x8018FCE8                  // return
        lbu        v0, 0x4AE7(v0)                // original line 2
    }

    // @ Description
    // Forces a specific song to play
    scope set_bgm: {
        OS.patch_start(0x10E548, 0x8018FCE8)
        j       set_bgm
        addiu    a1, r0, MULTIMAN_ID                                // multiman mode check placed in
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 2 if multiman
        beq     t6, a1, _multiman           // if multiman, skip
        addiu    a1, r0, 0x007E                // places multiman music ID into argument
        addiu    a1, r0, CRUEL_ID            // cruel mode check placed in
        beq     t6, a1, _multiman           // if multiman, skip
        addiu    a1, r0, 0x007F                // places cruel multiman music ID into argument
        addiu    a1, r0, REMIX_1P_ID            // Remix 1p Mode Check in
        bne     a1, t6, _normal             // take normal route if not Remix 1p
        addiu   a1, r0, 0x000D              // Final Stage ID entered
        li      t6, STAGE_FLAG              // load from current progress of 1p ID
        lb      t6, 0x0000(t6)
        beq     a1, t6, _multiman           // branch if on final stage
        addiu   a1, r0, 0x004D              // insert Ultimate Bowser

        _normal:
        jal        0x800FC3E8
        nop
        j       _return                     // return
        nop

        _multiman:
        jal        _multiman_midi
        nop
        j       _return                     // return
        nop

        _multiman_midi:                        // based on 0x800FC3E8
        lui        t6, 0x8013
        lw        t6, 0x1300(t6)
        addiu    sp, sp, 0xFFE8
        sw        ra, 0x0014(sp)

        OS.copy_segment(0x77BFC, 0x30)        // 800FC3FC
    }

    // @ Description
    // Skips a c flag function which starts new music at end of traffic light
    scope skip_cflag_music_function_2: {
        OS.patch_start(0x10B9C0, 0x8018D160)
        j       skip_cflag_music_function_2
        addiu    at, r0, MULTIMAN_ID                // multiman mode check placed in
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // v0 = multiman flag
        lw      t6, 0x0000(t6)              // v0 = 2 if multiman
        beq     t6, at, _multiman           // if multiman, skip
        addiu    at, r0, CRUEL_ID                // cruel multiman mode check placed in
        beq     t6, at, _multiman           // if cruel multiman, skip
        nop

        lui        v0, 0x800A                    // original line 1
        j        _return
        lbu        v0, 0x4AE7(v0)                // original line 2

        _multiman:
        j       _return                      // return
        addiu    v0, r0, r0
    }

    // @ Description
    // loads in the amount of stocks for multiman mode
    scope load_player_stocks: {
    OS.patch_start(0x520C4, 0x800D68C4)
        j        load_player_stocks
        sb        r0, 0x002C(a0)                // original line 2
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw        t2, 0x0008(sp)

        li      t1, singleplayer_mode_flag       // t1 = multiman flag
        lw         t1, 0x0000(t1)              // t1 = 1 if multiman
        addiu    t2, r0, REMIX_1P_ID
        beq        t2, t1, _1p
        nop
        bnez    t1, _multiman               // if multiman, skip
        nop

        _1p:
        lw      t1, 0x0004(sp)              // load t1
        lw      t2, 0x0008(sp)              // load t2
        addiu   sp, sp, 0x0010              // deallocate stack space

        j        _return
        lbu        t9, 0x493B(t9)                // original line 2

        _multiman:
        lw      t1, 0x0004(sp)              // load t1
        lw      t2, 0x0008(sp)              // load t2
        addiu   sp, sp, 0x0010              // deallocate stack space
        j        _return
        addiu    t9, r0, 0x0000                    // set stock amount to 1
    }

    // @ Description
    // loads in diffuculty of a 1p based mode
    scope load_1p_difficulty_1: {
    OS.patch_start(0x10BD54, 0x8018D4F4)
        j        load_1p_difficulty_1
        addiu    t8, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw         t6, 0x0000(t6)              // t6 = 1 if multiman
        beq     t6, t8, _bonus3             // if bonus 3, skip
        addiu    t8, r0, MULTIMAN_ID

        beq     t6, t8, _multiman           // if multiman, skip
        addiu    t8, r0, CRUEL_ID
        beq     t6, t8, _cruel              // if cruel multiman, skip
        lui        t8, 0x8013                    // original line 2

        j        _return
        lbu        t6, 0x045A(t0)                // original line 1

        _bonus3:
        lui        t8, 0x8013                    // original line 2
        j        _return
        addiu    t6, r0, 0x0004                // set difficulty to very hard

        _multiman:
        lui        t8, 0x8013                    // original line 2
        j        _return
        addiu    t6, r0, 0x0001                // set difficulty to easy

        _cruel:
        j        _return
        addiu    t6, r0, 0x0004                // set difficulty to very hard
    }

    // @ Description
    // loads in diffuculty of a 1p based mode again
    scope load_1p_difficulty_2: {
    OS.patch_start(0x10BD9C, 0x8018D53C)
        j        load_1p_difficulty_2
        addiu    t9, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw         t6, 0x0000(t6)              // t6 = 1 if multiman
        beq     t6, t9, _veryhard           //
        addiu    t9, r0, MULTIMAN_ID

        beq     t6, t9, _multiman           // if multiman, skip
        addiu    t9, r0, CRUEL_ID
        beq     t6, t9, _veryhard
        lw        t9, 0x0000(t1)                // original line 2
        j        _return
        lbu        t6, 0x045A(t0)                // original line 1

        _multiman:
        lw        t9, 0x0000(t1)                // original line 2
        j        _return
        addiu    t6, r0, 0x0001                // set difficulty to easy

        _veryhard:
        lw        t9, 0x0000(t1)                // original line 2
        j        _return
        addiu    t6, r0, 0x0004                // set difficulty to very hard
    }

    // @ Description
    //    Opponent CPU Level difficulty level
    scope _opponent_cpu: {
    OS.patch_start(0x10BD64, 0x8018D504)
        j        _opponent_cpu
        addiu    t1, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      v0, singleplayer_mode_flag       // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 1 if multiman
        beq     v0, t1, _level9             // if bonus3, skip
        addiu    t1, r0, MULTIMAN_ID
        beq     v0, t1, _multiman           // if multiman, skip
        addiu    t1, r0, CRUEL_ID
        beq     v0, t1, _level9             // if cruel multiman, skip
        lui        t1, 0x800A                    // original line 2

        j        _return
        lbu        v0, 0x0002(t7)                // original line 1

        _multiman:
        lui        t1, 0x800A                    // original line 2
        j        _return
        addiu    v0, r0, 0x0004                // set opponent cpu to what it is on normal

        _level9:
        lui        t1, 0x800A                    // original line 2
        j        _return
        addiu    v0, r0, 0x0009                // set opponent cpu to max
        }

    // @ Description
    // Prevents strange crash from happening when over 30 KOs are reached.
    scope crash_prevent: {
        OS.patch_start(0x10D938, 0x8018F0D8)
        j       crash_prevent                   
        nop 
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 1 if multiman
        addiu    t5, r0, REMIX_1P_ID
        beq        t6, t5, _1p
        nop
        bnez    t6, _multiman               // if multiman, skip
        nop

        _1p:
        sw        t7, 0x0000(v0)                // original line 1
        j       _return                     // return
        lw        t6, 0x0024(v1)              // original line 2

        _multiman:
        lw        t6, 0x0024(v1)              // original line 2
        addiu    a3, r0, 0x0004
        lw        t8, 0x0820(v1)
        lw        t9, 0x0824(v1)
        lhu        t3, 0x0828(v1)
        lhu        t4, 0x082A(v1)
        j        0x8018F110
        nop
    }

    // @ Description
    // Sets Multiman to C Flag Mode and Bonus 3 to B Flag Mode, flags various functions, includiing loading new characters over a
    // cpu slot and displaying icons that remove as defeated, camera, can affect spawns, and other things. There are other modes, perhaps one for each stage
    scope stage_flag: {
        OS.patch_start(0x52324, 0x800D6B24)
        j       stage_flag                   
        addiu    at, r0, BONUS3_ID
        _return:
        OS.patch_end()
        
        li      v0, singleplayer_mode_flag       // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 2 if multiman
        beq     v0, at, _bonus3             // if bonus 3, skip
        addiu    at, r0, MULTIMAN_ID
        beq     v0, at, _multiman           // if multiman, skip
        addiu    at, r0, CRUEL_ID
        bne     v0, at, _normal             // if normal, skip
        nop

        _multiman:
        addiu    at, r0, 0x000C                    // load flag in at
        sb        at, 0x0017(s2)                // save to flag location so it sets to C flag for various functions

        _normal:
        lbu        v0, 0x0017(s2)              // original line 1
        j        _return
        addiu    at, r0, 0x0003                // original line 2

        _bonus3:
        addiu    at, r0, 0x000B                // load flag in at
        j        _normal
        sb        at, 0x0017(s2)                // save to flag location so it sets to C flag for various functions
        }

    // @ Description
    // Prevents the display of polygon icons used in 1p mode
    scope icon_removal: {
        OS.patch_start(0x10D4D0, 0x8018EC70)
        j       icon_removal                   
        addiu    t9, r0, MULTIMAN_ID
        _return:
        OS.patch_end()
        
        li      t8, singleplayer_mode_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 2 if multiman
        beq     t8, t9, _multiman           // if multiman, skip
        addiu    t9, r0, CRUEL_ID
        beq     t8, t9, _multiman           // if cruel multiman, skip
        nop

        beq        t7, r0, _branch              // modified original line 1
        nop                                    // original line 2
        j        _return
        nop

        _multiman:
        j        0x8018EE24
        nop

        _branch:
        j        0x8018EC88
        nop
        }


    // @ Description
    // Revises the original selection of polygon characters so that it works indefinetly and is more random
    scope multiman_random: {
    OS.patch_start(0x10CB6C, 0x8018E30C)
        j       multiman_random                   
        addiu    v0, r0, MULTIMAN_ID
        _return:
        OS.patch_end()
        
        li      t5, singleplayer_mode_flag       // t5 = multiman flag
        lw      t5, 0x0000(t5)              // t5 = 1 if multiman
        beq     t5, v0, _multiman           // if multiman, skip
        addiu    v0, r0, CRUEL_ID
        bne     t5, v0, _normal             // if multiman, skip
        nop

        _multiman:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      t6, 0x0008(sp)              // save registers
        sw      t0, 0x000C(sp)              // save registers
        jal        Global.get_random_int_
        addiu    a0, r0, 0x000C
        addiu    t4, v0, 0x000E
        lw        a0, 0x0004(sp)                // load registers
        lw        t6, 0x0008(sp)                // load registers
        lw        t0, 0x000C(sp)                // load registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _normal:
        addu    t5, t6, t0                    // original line 1
        j        _return
        lui        v0, 0x8019                    // original line 2
        }
    
    // @ Description
    // Adds a check to KO Counter to see if player has been KO'd and therefore should stop counting in multiman
    scope multiman_ko_count_stop: {
    OS.patch_start(0x10D97C, 0x8018F11C)
        j       multiman_ko_count_stop                   
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // save registers
        sw      t2, 0x000C(sp)              // save registers

        li      t0, singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 1 if multiman
        addiu   t1, r0, MULTIMAN_ID         // insert multiman ID
        beq     t0, t1, _multiman           // if multiman, skip
        addiu    t1, r0, CRUEL_ID
        bne     t0, v0, _normal             // if multiman, skip
        nop

        _multiman:
        li      t2, player_ko               // load player KO address
        lw      t2, 0x0000(t2)              // load player KO flag (1=KO'd)
        bnez    t2, _ko                     // if KO'd skip saving new number
        nop

        _normal:
        sw      t6, 0x0000(a0)              // original line 2, save new KO amount
        
        _ko:
        lw        t0, 0x0004(sp)                // load registers
        lw        t1, 0x0008(sp)                // load registers
        lw        t2, 0x000C(sp)                // load registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        bne     a3, t5, _branch             // take branch of unknown purpose, modified original line 1 part 1
        nop
        
        j        _return
        nop
        
        _branch:
        j       0x8018F19C                  // modified original line 1, part 2
        nop
        }
    
    // @ Description    
    // This refreshes the player KO flag for every new match
    scope player_ko_refresh: {
    OS.patch_start(0x10C914, 0x8018E0B4)
        j       player_ko_refresh                   
        sw      r0, 0x36A0(at)              // original line 1
        _return:
        OS.patch_end()
        
        li      at, player_ko               // load player ko address
        sw      r0, 0x0000(at)              // set to 0
        j        _return
        lui     at, 0x8019                  // original line 2
        }

    // @ Description
    // Sets up custom display used by Multiman Modes
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw        t0, 0x0008(sp)
        sw        t1, 0x000C(sp)
        addiu    t0, r0, BONUS3_ID
        li      t1, singleplayer_mode_flag       // t6 = multiman flag
        lw      t1, 0x0000(t1)              // t6 = 1 if multiman
        beq     t1, t0, _bonus3                 // if multiman, skip
        addiu    t0, r0, REMIX_1P_ID
        beq     t1, t0, _bonus3                 // if multiman, skip
        nop

        Render.load_font()                                        // load font for strings
        Render.load_file(0x19, Render.file_pointer_1)             // load button images into file_pointer_1

        // draw icons
        Render.draw_texture_at_offset(0x17, 0x0B, Render.file_pointer_1, 0x80, Render.NOOP, 0x41f00000, 0x41a00000, 0x848484FF, 0x303030FF, 0x3F800000)            // renders polygon stock icon

        Render.draw_texture_at_offset(0x17, 0x0B, 0x80130D50, 0x828, Render.NOOP, 0x421C0000, 0x41900000, 0x848484FF, 0x303030FF, 0x3F800000)            // renders X

        Render.draw_number(0x17, 0x0B, KO_AMOUNT_POINTER, Render.update_live_string_, 0x42480000, 0x41900000, 0xFFFFFFFF, 0x3f666666, Render.alignment.LEFT)    // renders counter
    

        lw      ra, 0x0004(sp)              // restore registers
        lw        t0, 0x0008(sp)
        lw        t1, 0x000C(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

        _bonus3:
        lw      ra, 0x0004(sp)              // restore registers
        lw        t0, 0x0008(sp)
        lw        t1, 0x000C(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

    }
    
//  REMIX 1P

    // @ Description
    // Settings that replace normally loaded hard codes used in Standard Remix 1p
    // insert MATCH_SETTINGS_PART2,"1p/Match_Settings_part2.bin"
    
    MATCH_SETTINGS_PART2:
    
    //  First Remix Standard Match
    dw  0x01020306 
    dw  0x08090909
    dw  0x09091A1B 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Remix Team Match
    dw  0x00030406
    dw  0x0809090C
    dw  0x0D0E0F10
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Second Remix Standard Match
    dw  0x01030507 
    dw  0x09090909 
    dw  0x09091B1C 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Targets
    dw  0x01000101
    dw  0x01010109
    dw  0x09090909
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Starfox
    dw  0x01030507 
    dw  0x09090909 
    dw  0x09091B1C 
    dw  0x05040201 
    dw  0x01090909 
    dh  0x0909
    
    //  Third Remix Standard Match
    dw  0x01030507
    dw  0x09090909
    dw  0x09091C1D
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Giant Remix
    dw  0x01010607 
    dw  0x0809091B 
    dw  0x1C1D1E1F 
    dw  0x04030201 
    dw  0x01070707 
    dh  0x0707
    
    //  Platforms
    dw  0x01000101
    dw  0x01010109
    dw  0x09090909
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Remix Kirby Team
    dw  0x00010506 
    dw  0x07080911 
    dw  0x12131313 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Fourth Remix Standard Match
    dw  0x00030809
    dw  0x09090928
    dw  0x1D1E1F20
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Mad Piano
    dw  0x01010406 
    dw  0x0809091F 
    dw  0x20212122 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Race to the Finish
    dw  0x00000909
    dw  0x09090905
    dw  0x0709281A
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    // Fighting Polygon Team
    dw  0x00010405 
    dw  0x07080916 
    dw  0x17180F10 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Giga Bowser
    dw  0x00000909      // byte 1 team attack, byte 2 item spawn, byte 3 very easy cpu level, byte 4 easy cpu level
    dw  0x0909091E      // byte 1 normal cpu level, byte 2 hard cpu level, byte 3 very hard cpu level, byte 4 opponent knockback ratio very easy
    dw  0x1F1F2022      // byte 1 opponent easy knockback ratio, byte 2 opponent normal knockback ratio, byte 3 opponent hard knockback ratio, byte 4 opponent very hard knockback ratio
    dw  0x01010101      // byte 1 ally cpu level very easy, ally cpu level easy, ally cpu level normal, ally cpu level hard, 
    dw  0x01090909      // byte 1 ally cpu level very hard, ally kb ratio very easy, ally kb ratio easy, ally kb ratio normal
    dh  0x0909          // byte 1 ally kb ratio hard, ally kb ratio very hard
    //  Luigi Unlock Battle
    dw  0x01000607 
    dw  0x07080906 
    dw  0x06060606 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Ness Unlock Battle
    dw  0x01000607
    dw  0x07080906
    dw  0x06060606
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    //  Jigglypuff Unlock Battle
    dw  0x01000607 
    dw  0x07080906 
    dw  0x06060606 
    dw  0x01010101 
    dw  0x01090909 
    dh  0x0909
    
    //  Captain Falcon Unlock Battle
    dw  0x01000607
    dw  0x07080906
    dw  0x06060606
    dw  0x01010101
    dw  0x01090909
    dh  0x0909
    
    MATCH_SETTINGS_PART1:
    // Standard Remix Match 1
    dw  0xFF040000 
    dw  0xFFFFFFFF 
    dw  0x01051C00 
    dw  0x00000000 
    
    // Remix Team
    dw  0x800C0000 
    dw  0xFFFFFFFF 
    dw  0x12061C02 
    dw  0x00000000 
    
    // Standard Remix Match 2
    dw  0xFF010000 
    dw  0xFFFFFFFF 
    dw  0x01011C00 
    dw  0x00000000 
    
    //  Targets
    dw  0xFF000000 
    dw  0xFFFFFFFF 
    dw  0x011C1C00 
    dw  0x00000000 
    
    //  Starfox
    dw  0xFF460000 
    dw  0xFFFFFFFF 
    dw  0x02011D05 
    dw  0x01090000 
    
    // Standard Remix Match 3
    dw  0xFF070000 
    dw  0xFFFFFFFF 
    dw  0x01091C00 
    dw  0x00000000 
    
    //  Giant Remix
    dw  0xFF020000 
    dw  0xFFFFFFFF 
    dw  0x011A1C06 
    dw  0x02090000 
    
    //  Platforms
    dw  0xFF000000 
    dw  0xFFFFFFFF 
    dw  0x011C1C00 
    dw  0x00000000 
    
    //  Remix Kirby Team
    dw  0x80390000 
    dw  0xFFFFFFFF 
    dw  0x08081C03 
    dw  0x00000000 
    
    // Standard Remix Match 4
    dw  0xFF030000 
    dw  0xFFFFFFFF 
    dw  0x01031C00 
    dw  0x00000000 
    
    //  Mad Piano
    dw  0xFF400000 
    dw  0xFFFFFFFF 
    dw  0x01361C00 
    dw  0x00000000 
    
    //  Race to the Finish
    dw  0xFF0F0000 
    dw  0xFFFFFFFF 
    dw  0x031C1C08 
    dw  0x00000000 
    
    //  Fighting Polygon Team
    dw  0x80310000 
    dw  0xFFFFFFFF 
    dw  0x1E1C1C04 
    dw  0x00000000 
    
    //  Giga Bowser
    dw  0xFF100000 
    dw  0xFFFFFFFF 
    dw  0x01351C00 
    dw  0x00000000 
    
    //  Luigi Unlock Battle
    dw  0xFF000000 
    dw  0xFFFFFFFF 
    dw  0x01041C00 
    dw  0x00000000 
    
    //  Ness Unlock Battle
    dw  0xFF060000 
    dw  0xFFFFFFFF 
    dw  0x010B1C00 
    dw  0x00000000 
    
    //  Jigglypuff Unlock Battle
    dw  0xFF070000 
    dw  0xFFFFFFFF 
    dw  0x010A1C00 
    dw  0x00000000 
    
    //  Captain Falcon Unlock Battle
    dw  0xFF030000 
    dw  0xFFFFFFFF 
    dw  0x01071C00 
    dw  0x00000000
    
    insert announcer_calls,"1p/announcer_calls.bin"
    insert model_scale,"1p/model_scale.bin"
    insert name_textures,"1p/name_textures.bin"
    
    // @ Description
    // These are the settings for each individuals character that can be fought in Remix 1p, this will be pulled from by remix_1p_randomization
    // Line 1 is a flag used to determine if the character has been selected for a spot in the Remix 1p Path
    // Line 2 is their character ID
    // Line 3-5 are the 3 randomly selected stages for the character
    // Line 6 is the Characters 1p Name Texture Offset
    // Line 7 is their announce Call ID
    // Line 8 is the model scale, I generally make them all the same as these are finicky
    // Line 9 is their progress Icon Offset
    
    OS.align(16)
    match_pool:
    // every stage added to this list needs to have all 3 solo mode computer spawns, 5 yoshi/kirby spawns, regular ally spawn, congo jungle ally spawn
    // Dr. Mario match settings
    dw    0x00000000                        // flag
    db    Character.id.DRM                // Character ID
    db    Stages.id.DR_MARIO                // Stage Option 1
    db    Stages.id.DR_MARIO                // Stage Option 2
    db    Stages.id.DR_MARIO                // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture 
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon
    
    // Ganondorf match settings
    dw    0x00000000                        // flag
    db    Character.id.GND                // Character ID
    db    Stages.id.GANONS_TOWER            // Stage Option 1
    db    Stages.id.GERUDO                // Stage Option 2
    db    Stages.id.HTEMPLE                // Stage Option 3
    dw  SinglePlayer.name_texture.GND + 0x10    // name texture 
    dw  0x000002C5                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x000159C0                      // Progress Icon
    
    // Young Link match settings
    dw    0x00000000                        // flag
    db    Character.id.YLINK                // Character ID
    db    Stages.id.DEKU_TREE                // Stage Option 1
    db    Stages.id.SKYLOFT                // Stage Option 2
    db    Stages.id.GREAT_BAY                // Stage Option 3
    dw  SinglePlayer.name_texture.YLINK + 0x10    // name texture 
    dw  0x000002E5                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015880                      // Progress Icon 
    
    // Wolf match settings
    dw    0x00000000                        // flag
    db    Character.id.WOLF                // Character ID
    db    Stages.id.VENOM                    // Stage Option 1
    db    Stages.id.VENOM                    // Stage Option 2
    db    Stages.id.CORNERIACITY            // Stage Option 3
    dw  SinglePlayer.name_texture.WOLF + 0x10    // name texture 
    dw  0x000003AA                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015740                      // Progress Icon
    
    // Wario match settings
    dw    0x00000000                        // flag
    db    Character.id.WARIO                // Character ID
    db    Stages.id.WARIOWARE                // Stage Option 1
    db    Stages.id.MUDA                    // Stage Option 2
    db    Stages.id.KITCHEN               // Stage Option 3
    dw  SinglePlayer.name_texture.WARIO + 0x10    // name texture 
    dw  0x00000304                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015600                      // Progress Icon 
    
    // Dark Samus match settings
    dw    0x00000000                        // flag
    db    Character.id.DSAMUS                // Character ID
    db    Stages.id.NORFAIR                // Stage Option 1
    db    Stages.id.ZLANDING                // Stage Option 2
    db    Stages.id.NORFAIR                // Stage Option 3
    dw  SinglePlayer.name_texture.DSAMUS + 0x10    // name texture 
    dw  0x000002EC                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015100                      // Progress Icon 
    
    // Bowser match settings
    dw    0x00000000                        // flag
    db    Character.id.BOWSER                // Character ID
    db    Stages.id.BOWSERS_KEEP            // Stage Option 1
    db    Stages.id.BOWSERB                // Stage Option 2
    db    Stages.id.BOWSERS_KEEP            // Stage Option 3
    dw  SinglePlayer.name_texture.BOWSER + 0x10    // name texture 
    dw  0x00000372                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014D40                      // Progress Icon
    
    // Lucas match settings
    dw    0x00000000                        // flag
    db    Character.id.LUCAS                // Character ID
    db    Stages.id.ONETT                    // Stage Option 1
    db    Stages.id.OSOHE                    // Stage Option 2
    db    Stages.id.NPC                    // Stage Option 3
    dw  SinglePlayer.name_texture.LUCAS + 0x10    // name texture 
    dw  0x00000348                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015B00                      // Progress Icon
    
    // Conker match settings
    dw  0x00000000                      // flag
    db  Character.id.CONKER             // Character ID
    db  Stages.id.WINDY                 // Stage Option 1
    db  Stages.id.WINDY                 // Stage Option 2
    db  Stages.id.WINDY                 // Stage Option 3
    dw  SinglePlayer.name_texture.CONKER + 0x10    // name texture 
    dw  0x000003C4                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014E80                      // Progress Icon
    
    // @ Description
    // These are the slots//offsets that random characters will replace in Match Settings by 1p Randomization code
    // Random slots
    db  0x00
    db  0x10
    db  0x20
    db  0x50
    db  0x60
    match_slots:
    db  0x90
    OS.align(16)
    
    // @ Description
    // These get overwritten via the 1p randomization Code
    // This replaces a struct originally used by the game for the title card characters
    // Character Title Card List
    title_card_1_struct:
    dw  0x00000005          // Link
    dw  0x00000006          // Yoshi
    dw  0x00000001          // Fox
    dw  0x00000000          // Targets
    dw  0x00000000          // Mario Bros
    dw  0x00000009          // Pikachu
    dw  0x00000002          // DK
    dw  0x00000000          // Platforms
    dw  0x00000008          // Kirby
    dw  0x00000003          // Samus
    dw  0x00000036          // Mad Piano
    dw  0x00000000          // 
    dw  0x00000000          // 
    dw  0x00000035          // Giga Bowser
    OS.align(16)
    
    // @ Description
    // These are used to determine which of the above slots can be replaced by Random Characters
    // Random slots
    // title card slots
    db  0x00
    db  0x04
    db  0x08
    db  0x14
    db  0x18
    title_slots:
    db  0x24
    OS.align(16)
    
    // @ Description
    // These are used to get the offset of the progress icon from file 0xB, some get overwritten in randomization process
    progress_icon_struct:
    dw  0x000071D0          // 1st Remix Standard
    dw  0x00007320          // Remix Team
    dw  0x00007470          // 2nd Remix Standard
    dw  0x00007F40          // Targets
    dw  0x000154C0          // Star Fox
    dw  0x00007710          // 3rd Remix Standard
    dw  0x00007860          // Giant Remix
    dw  0x00007F40          // Platforms
    dw  0x000079B0          // Remix Kirby Team
    dw  0x00007B00          // 4th Remix Standard
    dw  0x00015240          // Mad Piano
    dw  0x00007F40          // Race to the Finish
    dw  0x00007D60          // Fighting Polygon Team
    dw  0x00015380          // Giga Bowser
    dw  0x00000000          // empty
    OS.align(16)
    
    // @ Description
    // Randomly generates a new path for 1p by writing over portions of match settings
    // This only gets run after a player presses start on the 1p CSS screen
    scope remix_1p_randomization: {
        OS.patch_start(0x1402E8, 0x801380E8)
        j       remix_1p_randomization                 
        nop
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // save registers
        sw      t3, 0x000C(sp)              // save registers
        sw      v0, 0x0010(sp)              // save registers
        sw      t4, 0x0014(sp)              // save registers
        sw      t5, 0x0018(sp)              // save registers
        sw      t6, 0x001C(sp)              // save registers
        sw      t7, 0x0020(sp)              // save registers
        sw      t8, 0x0024(sp)              // save registers
        sw      t9, 0x0028(sp)              // save registers
        li      at, singleplayer_mode_flag  // at = multiman flag
        lw      at, 0x0000(at)              // at = 4 if Remix 1p
        addiu    t2, r0, REMIX_1P_ID
        bne     at, t2, _normal             // if not Remix 1p, skip
        nop
               
        li      t8, 0x8003B6E4              // ~
        lw      t8, 0x0000(t8)              // t8 = frame count for current screen
        andi    t8, t8, 0x003F              // t8 = frame count % 64
        
        _loop:
        // advances rng between 1 - 64 times based on frame count when entering stage selection
        jal     0x80018910                  // this function advances the rng seed
        nop
        bnez    t8, _loop                   // loop if t8 != 0
        addiu   t8, t8,-0x0001              // subtract 1 from t8

        li      t9, MATCH_SETTINGS_PART1
        addiu   t0, r0, 0x0005              // slot countdown (currently six random slots to fill)
        addiu   t1, r0, 0x0018              // jump multiplier for match pool
        li      t5, match_pool              // load match pool address
        li      t7, match_slots             // load match slots address
        li      t2, title_card_1_struct
        
        _assignment_loop:
        jal        Global.get_random_int_   // generate number based on total number of character pool
        addiu    a0, r0, 0x0009             // place current number of character pool in a0
        
        // get character ID
        mult    v0, t1                      // random number multiplied by jump multiplier
        mflo    v0
        addu    t3, t5, v0                  // add multiplier to match pool address
        lw      t4, 0x0000(t3)              // load flag to see if character has already been assigned
        bnez    t4, _assignment_loop        // restart if character already assigned
        addiu   t4, r0, 0x0001
        sw      t4, 0x0000(t3)              // save 1 to flag to mark the character as already used
        
        li      t6, title_slots
        sub     t8, t6, t0                  // work backwards from final slot by subtracting slot counter
        lbu     v0, 0x0000(t8)              // load slot
        
        li      a0, progress_icon_struct
        addu    a0, a0, v0                  // add slot to struct address
        lw      t4, 0x0014(t3)              // load icon location in file
        sw      t4, 0x0000(a0)              // save icon location to correct place in struct
        
        li      a0, name_textures       
        lw      t4, 0x0008(t3)              // load name texture of character
        addu    a0, a0, v0                  // get location of current character
        sw      t4, 0x0000(a0)              // save name texture to correct location
        
        
        //addiu   t4, r0, 0x0014            // load slot of Giant Character
        //bne     t4, v0, _team_check
        //nop
        //j       _unique
        //lw      t4, 0x0018(t3)          // load name call of character
        
        //_team_check:
        //addiu   t4, r0, 0x0004          // load slot of Team Character
        //bne     t4, v0, _standard 
        //nop
        //j       _unique
        //lw      t4, 0x0014(t3)          // load name call of character
        
        //_standard:
        lw      t4, 0x000C(t3)              // load name call of character
        //_unique:
        li      a0, announcer_calls         // load announcer call
        addu    a0, a0, v0                  // get location of current character
        sw      t4, 0x0000(a0)              // save name call to correct location
        
        addiu   a0, r0, 0x0004              // Team Slot inserted
        beq     a0, v0, _team_skip          // check if on team slot, if so, skip scale because they all use the default scale
        nop
        
        li      a0, model_scale             // load model scale
        addu    a0, a0, v0                  // get location of current character
        lw      t4, 0x0010(t3)              // load model scale of character
        sw      t4, 0x0000(a0)              // save model scale to correct location
        
        _team_skip:
        lbu     t4, 0x0004(t3)              // load character ID into t4
        
        // get stage ID
        jal     Global.get_random_int_      // generate number based on total number of stage pool for character
        addiu   a0, r0, 0x0003              // place current number of stage pool in a0
        addiu   v0, v0, 0x0001              // add 1 to output to account for character portion of word
        addu    t3, t3, v0                  // add v0 amount to get stage id
        lbu     t3, 0x0004(t3)              // load stage ID in t7
        
        // save settings
        
        sub     t8, t7, t0                  // work backwards from final slot by subtracting slot counter
        lbu     t8, 0x0000(t8)              // load additive amount for match settings slot
        addu    t8, t9, t8                  // place match settings slot address into t8
        
        sb      t3, 0x0001(t8)              // save stage ID to match settings slot
        sb      t4, 0x0009(t8)              // save character ID to match settings slot
        li      t6, title_slots
        sub     t8, t6, t0                  // work backwards from final slot by subtracting slot counter
        lbu     v0, 0x0000(t8)              // load slot
        addu    t8, t2, v0                  // add slot amount to title card pointer
        sw      t4, 0x0000(t8)              // save character ID to title card spot
        
        bnez    t0, _assignment_loop
        addiu   t0, t0, -0x0001
        sw      r0, 0x0000(t5)              // clear character flag 1, THESE NEED UPDATED WHEN CHARACTER ADDED OR MOST THINGS ADDED TO MATCH POOL
        sw      r0, 0x0018(t5)              // clear character flag 2
        sw      r0, 0x0030(t5)              // clear character flag 3
        sw      r0, 0x0048(t5)              // clear character flag 4
        sw      r0, 0x0060(t5)              // clear character flag 5
        sw      r0, 0x0078(t5)              // clear character flag 6
        sw      r0, 0x0090(t5)              // clear character flag 7
        sw      r0, 0x00A8(t5)              // clear character flag 8
        sw      r0, 0x00C0(t5)              // clear character flag 9
        
        
        _normal:
        lw      t0, 0x0004(sp)              // load registers
        lw      t1, 0x0008(sp)              // load registers
        lw      t3, 0x000C(sp)              // load registers
        lw      v0, 0x0010(sp)              // load registers
        lw      t4, 0x0014(sp)              // load registers
        lw      t5, 0x0018(sp)              // load registers
        lw      t6, 0x001C(sp)              // load registers
        lw      t7, 0x0020(sp)              // load registers
        lw      t8, 0x0024(sp)              // load registers
        lw      t9, 0x0028(sp)              // load registers
        addiu   sp, sp, 0x0030              // deallocate stack space
        addiu   t2, r0, 0x0001              // original line 1
        j       _return
        lui     at, 0x8014                  // original line 2
        }
    
    // @ Description
    // Changes address used for character name text
    scope title_card_text_name: {
        OS.patch_start(0x12B834, 0x801324F4)
        j       title_card_text_name                  
        addiu    t6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t0, singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
        bne     t0, t6, _normal               // if not Remix 1p, skip
        sw      ra, 0x001C(sp)                // original line 2

        li        t7, name_textures
        j       _return
        nop

        _normal:
        j        _return
        addiu   t7, t7, 0x4F24              // original line 1
        }
    
    // @ Description
    // Changes the process by which textures are added to the text object in title card mode to add team, giant, and other various tweaks
    scope title_card_text_routine: {
        OS.patch_start(0x12B904, 0x801325C4)
        j       title_card_text_routine                  
        addiu    t6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t1, singleplayer_mode_flag  // t0 = multiman flag
        lw      t1, 0x0000(t1)              // t0 = 4 if Remix 1p
        bne     t1, t6, _normal               // if not Remix 1p, skip
        nop

        beq     a2, at, _end                // do a normal character text load if at Pikachu Stage
        addiu   at, r0, 0x0006              // insert giant stage
        
        beq     a2, at, _giant              // take jump if giant stage
        addiu   at, r0, 0x0001              // insert team stage
        
        beq     a2, at, _team               // take jump if team stage
        addiu   at, r0, 0x0009              // insert Samus stage
        
        beq     a2, at, _end                // do a normal character text load if at Samus Stage
        addiu   at, r0, 0x000A              // insert Metal Mario stage   
   
        beq     a2, at, _end                // do a normal character text load if at Metal Mario Stage
        addiu   at, r0, 0x0002              // insert Fox McCloud stage
        
        beq     a2, at, _end                // do a normal character text load if at Fox McCloud
        addiu   at, r0, 0x0004              // insert original stage, Pikachu
        
        beq     a2, at, _end                // do a normal character text load if at Mario Brothers Stage
        addiu   at, r0, 0x000D              // insert original stage, Pikachu
        
        beq     a2, at, _end                // do a normal character text load if at Final Stage
        addiu   at, r0, 0x0005              // insert original stage, Pikachu
        
        bne     a2, at, _1p_specialized     // Do 1p specialized otherwise
        nop
        
        _team:
        sll     t6, a2, 0x2
        addu    t8, sp, t6
        lw      t8, 0x0024(t8)
        lw      t9, 0x0004(a3)
        jal     0x800CCFDC
        addu    a1, t8, t9                  // load name texture footer
        lhu     t4, 0x0024(v0)
        andi    t0, t4, 0xFFDF
        addiu   v1, r0, 0x00FF
        sh      t0, 0x0024(v0)
        ori     t7, t0, 0x0001
        sh      t7, 0x0024(v0)
        sb      v1, 0x0028(v0)
        sb      v1, 0x0029(v0)
        sb      v1, 0x002A(v0)
        lw      a2, 0x0068(sp)
        li      a3, 0x80136058
        lui     t2, 0x8013
        addiu   t2, t2, 0x6058
        lw      t2, 0x0004(t2)
        addiu   a1, t2, 0x5EF8              // load "Team" offset
        jal     0x800CCFDC
        lw      a0, 0x0064(sp)              // load object ID
                
        j       0x80132604
        addiu   v1, r0, 0x00FF
        
        _giant:
        sll     t6, a2, 0x2
        addu    t8, sp, t6
        lw      t9, 0x0004(a3)              
        addiu   a1, t9, 0x5CB8              // load "Giant" offset
        //lw      t9, 0x0024(a3)
        
        jal     0x800CCFDC
        nop
        lhu     t4, 0x0024(v0)
        andi    t0, t4, 0xFFDF
        addiu   v1, r0, 0x00FF
        sh      t0, 0x0024(v0)
        ori     t7, t0, 0x0001
        sh      t7, 0x0024(v0)
        sb      v1, 0x0028(v0)
        sb      v1, 0x0029(v0)
        sb      v1, 0x002A(v0)
        lw      a2, 0x0068(sp)
        li      a3, 0x80136058
        
        sll     t6, a2, 0x2
        addu    t8, sp, t6
        lw      t8, 0x0024(t8)
        lw      t9, 0x0004(a3)
        addu    a1, t8, t9                  // load name texture footer
        jal     0x800CCFDC
        lw      a0, 0x0064(sp)              // load object ID
        
        j       0x80132604
        addiu   v1, r0, 0x00FF

        _normal:
        bne        a2, at, _1p_specialized     // modified original line 1
        nop
       
        _end:
        j       _return
        sll     t1, a2, 0x2                 // original line 2
       
        _1p_specialized:
        j       0x801325EC
        sll     t1, a2, 0x2                 // original line 2
       }
   
    // @ Description
    // Changes positioning of Overall Text in Giant and Team Modes
    scope title_card_text_position: {
        OS.patch_start(0x12BC54, 0x80132914)
        j       title_card_text_position
        lw      t9, 0x0008(t8)              // next image footer, if it exists
        OS.patch_end()

        // There will be a 3rd image if we are in remix 1p on Giant and Team battle

        beqz    t9, _end                    // if no additional image footer, skip
        nop
        lhu     t9, 0x0014(t9)              // t9 = width of additional image
        addu    v0, v0, t9                  // v0 = updated width

        _end:
        jr      ra                          // original line 1 (exit subroutine)
        addiu   v0, v0, 0x000A              // original line 2
   }
    
   // @ Description
   // adds positioning for giant and team text in battles of remix 1p, this is relative to cpu name and Giant or Team text, not overall placement, which is above
   scope title_card_text_location_routine: {
        OS.patch_start(0x12BE18, 0x80132AD8)
        j       title_card_text_location_routine                 
        addiu    t8, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t9, singleplayer_mode_flag  // t9 = singleplayermode flag address
        lw      t9, 0x0000(t9)              // t9 = 4 if Remix 1p
        bne     t9, t8, _normal               // if not Remix 1p, skip
        nop
        
        lw      t8, 0x0028(sp)              // load in current 1p stage progress I
        addiu   t9, r0, 0x0006              // insert giant stage
        
        beq     t8, t9, _giant              // take jump if giant stage
        addiu   t9, r0, 0x0001              // insert team stage
        
        beq     t8, t9, _team               // take jump if team stage
        nop
        
        b       _normal                     // Do normal otherwise
        nop
        
        _team:
        lw      t8, 0x0008(t6)              // load texture struct of team text
        lh      t9, 0x0014(t6)              // load width of character name texture
        mtc1    t9, f18                     // move width to fp registers
        cvt.s.w f18, f18                    // convert width to floating point
        add.s   f18, f4, f18                // add width to floating point location
        lui     t9, 0x4080                  // put spacer of 4 in
        mtc1    t9, f20                     // move to floating point register
        add.s   f18, f18, f20               // add spacer to end of character name texture to get x location of "team"
        swc1    f18, 0x0058(t8)             // save x location to "team" (or cpu name if giant) texture struct
        li      t9, 0x4343C000
        b       _normal
        sw      t9, 0x005C(t8)              // save y location to be same as standard character name, adjusted up some

        _giant:
        lw      t8, 0x0008(t6)              // load texture struct of team text
        lh      t9, 0x0014(t6)              // load width of character name texture
        mtc1    t9, f18                     // move width to fp registers
        cvt.s.w f18, f18                    // convert width to floating point
        add.s   f18, f4, f18                // add width to floating point location
        lui     t9, 0xC110                  // put spacer of -9 in
        mtc1    t9, f20                     // move to floating point register
        add.s   f18, f18, f20               // add spacer to end of character name texture to get x location of "team"
        swc1    f18, 0x0058(t8)             // save x location to "team" (or cpu name if giant) texture struct
        li      t9, 0x43448000              // t9 = y position for character name
        sw      t9, 0x005C(t8)              // save y location to be slightly lower

        _normal:
        swc1    f4, 0x0058(t6)              // original line 1
        j       _return
        lw      t8, 0x0028(sp)              // original line 2
       }
   
    _giant_flag:
    dw  0x00000000
    
    _team_flag:
    dw  0x00000000
    
    _cpu_flag:
    dw  0x00000000

    // @ Description
    // Changes first part of every cpu to "giant" in giant stage ands team to end in Yoshi Team Stage
    scope title_card_giant_announce: {
        OS.patch_start(0x12DAC0, 0x80134780)
        j       title_card_giant_announce                  
        addiu    t6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      v0, singleplayer_mode_flag  // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 4 if Remix 1p
        bne     v0, t6, _normal             // if not Remix 1p, skip
        nop
        
        lui     v0, 0x8013
        lw      v0, 0x5C28(v0)              // load from current progress of 1p ID
        addiu   t6, r0, 0x0006              // Put in Giant Stage ID
        bne     v0, t6, _normal             // Do normal sound loading if not on Giant Stage
        nop
        
        li      t9, _giant_flag             // load flag which designates if giant has been played yet
        lw      t9, 0x0000(t9)
        bnel    t9, r0, _post_giant
        lw      ra, 0x0014(sp)
        
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03AF              // place "GIANT" FGM ID in a0
        
        li      at, _giant_flag             // load flag which designates if giant has been played yet
        addiu   t1, r0, 0x0001              // load one to set flag
        sw      t1, 0x0000(at)              // set flag as giant has been said
        
        _post_giant:
        jal     0x8000092C
        nop
        
        addiu   t3, r0, 0x002B              // set amount of frames between "GIANT" and CPU Name
        addiu   t4, t3, 0x006F
        sltu    at, t4, v0
        
        beql    at, r0, _end_loop           
        lw      ra, 0x0014(sp)
        lui     t0, 0x8013
        lw      t0, 0x5C28(t0)
        sll     t8, t0, 0x2
        addu    a0, sp, t8
        

        _normal:
        li      v0, _cpu_flag               // load flag which designates if cpu has been played yet
        lw      v0, 0x0000(v0)
        bnel    v0, r0, _team
        lw      ra, 0x0014(sp)
        
        li      at, _cpu_flag               // load flag which designates if cpu has been played yet
        addiu   t1, r0, 0x0001              // load one to set flag
        sw      t1, 0x0000(at)              // set flag as cpu has been said
        
        jal     0x800269C0                  // original line 1, play fgm
        lhu     a0, 0x0052(a0)              // original line 2, load CPU announce id
        
        _team:       
        addiu    t6, r0, REMIX_1P_ID
        li      v0, singleplayer_mode_flag  // v0 = multiman flag
        lw      v0, 0x0000(v0)              // v0 = 4 if Remix 1p
        bne     v0, t6, _end                   // if not Remix 1p, skip
        nop
        
        lui     v0, 0x8013
        lw      v0, 0x5C28(v0)              // load from current progress of 1p ID
        addiu   t6, r0, 0x0001              // Put in Yoshi Stage ID
        bne     v0, t6, _end                // Do normal sound loading if not on Yoshi Stage
        nop
        
        li      t9, _team_flag              // load flag which designates if team has been played yet
        lw      t9, 0x0000(t9)
        bnel    t9, r0, _end          
        lw      ra, 0x0014(sp)
        
        jal     0x80000092C                 // put frame counter into v0
        nop
        
        li      at, SinglePlayer.name_delay_table
        li      t3, MATCH_SETTINGS_PART1
        lbu     t3, 0x0019(t3)              // t3 = CPU char_id
        sll     t3, t3, 0x0002              // t3 = offset to CPU name delay
        addu    at, at, t3                  // at = address of CPU name delay
        lw      t3, 0x0000(at)              // t3 = CPU name delay
        lw      t4, 0x001C(sp)              // t4 = human name delay
        addu    t3, t3, t4                  // t3 = human name delay + CPU name delay
        addiu   t4, t3, 0x003C              // t4 = human name delay + VS delay + CPU name delay
        sltu    at, t4, v0
        beql    at, r0, _end                // skip to end if not at frame
        lw      ra, 0x0014(sp)
        
        li      at, _team_flag              // load flag which designates if team has been played yet
        addiu   t1, r0, 0x0001              // load one to set flag
        sw      t1, 0x0000(at)              // set flag as giant has been said
        
        jal     0x800269C0                  // play fgm
        addiu   a0, r0, 0x03AE              // place "TEAM" FGM ID in a0
        
        _end:
        j        _return
        nop
        
        _end_loop:
        j       0x80134804
        nop
    }
    
    // @ Description
    // Skips a check thats normally used for cpu name if on Remix
    scope title_card_yoshi_team_skip: {
        OS.patch_start(0x12DAAC, 0x8013476C)
        j       title_card_yoshi_team_skip                 
        addiu    t8, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      at, singleplayer_mode_flag       // v0 = multiman flag
        lw      at, 0x0000(at)              // v0 = 4 if Remix 1p
        bne     t8, at, _normal               // if not Remix 1p, skip
        nop
        
        lui     at, 0x8013
        lw      at, 0x5C28(at)              // load from current progress of 1p ID
        addiu   t8, r0, 0x0001              // Put in Yoshi Stage ID
        bne     t8, at, _normal             // Do normal sound loading if not on Yoshi Stage
        nop
        
        j       _return
        nop
        
        _normal:
        bnel    t9, r0, _cpu_called         // branch taken if cpu has been called, modified original line 1
        lw      ra, 0x0014(sp)              // original line 2
        j       _return
        nop
        
        _cpu_called:
        j       0x80134804                  // jump if cpu already called in normal match, modified original line 1
        nop
        }
    
    // @ Description    
    // Refreshes the Giant, CPU, and Team Flag
    scope title_card_flag_refresh: {
        OS.patch_start(0x12DE60, 0x80134B20)
        j       title_card_flag_refresh                 
        lw      s0, 0x0014(sp)              // original line 1
        _return:
        OS.patch_end()
        
        li      s1, _giant_flag
        sw      r0, 0x0000(s1)              // clear giant flag
        sw      r0, 0x0004(s1)              // clear team flag
        sw      r0, 0x0008(s1)              // clear cpu flag
        
        j       _return
        lw      s1, 0x0018(sp)              // original line 2

        }
        
//  // Changes address used for ally name announcement
// scope title_card_voice_name: {
//      OS.patch_start(0x12D914, 0x801345D4)
//      j       title_card_voice_name                  
//      addiu    t6, r0, REMIX_1P_ID
//      _return:
//      OS.patch_end()
//      
//     li      t0, singleplayer_mode_flag       // t0 = multiman flag
//      lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
//     bne     t0, t6, _normal               // if not Remix 1p, skip
//      sw      ra, 0x0014(sp)                // original line 2
//
//     li        t7, announcer_calls
//      j       _return
//      nop
//
//     _normal:
//      j        _return
//     addiu   t7, t7, 0x5A68              // original line 1
//     }

    // Changes address used for character name announcement
    scope title_card_voice_name: {
        OS.patch_start(0x12D950, 0x80134610)
        j       title_card_voice_name                  
        addiu    t5, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t1, singleplayer_mode_flag       // t0 = multiman flag
        lw      t1, 0x0000(t1)              // t0 = 4 if Remix 1p
        bne     t1, t5, _normal               // if not Remix 1p, skip
        nop

        li        t2, announcer_calls
        j       _return
        addiu   t5, t2, 0x0030                // original line 2

        _normal:
        addiu   t2, t2, 0x5A98              // original line 1
        j        _return
        addiu   t5, t2, 0x0030                // original line 2
        }
    
    // @ Description   
    // Changes address used for character model scale
    scope title_card_model_scale: {
        OS.patch_start(0x12CAB8, 0x80133778)
        j       title_card_model_scale                  
        addiu    t6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t0, singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
        bne     t0, t6, _normal               // if not Remix 1p, skip
        or      s0, a1, r0                  // original line 2

        li        t7, model_scale
        j       _return
        nop

        _normal:
        j        _return
        addiu   t7, t7, 0x5180              // original line 1
        }
    
    // @ Description
    // Changes address used for title card character loading 1
    scope title_card_1: {
        OS.patch_start(0x12CE1C, 0x80133ADC)
        j       title_card_1                  
        addiu    t9, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t0, singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
        bne     t0, t9, _normal               // if not Remix 1p, skip
        or      s5, a0, r0                    // original line 2

        li        t6, title_card_1_struct
        j       _return
        nop

        _normal:
        j        _return
        addiu   t6, t6, 0x51B8              // original line 1
        }
    
    // @ Description
    // Changes address used for title card character loading 1
    scope title_card_2: {
        OS.patch_start(0x12DD4C, 0x80134A0C)
        j       title_card_2                  
        addiu    t9, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t0, singleplayer_mode_flag       // t0 = multiman flag
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
        bne     t0, t9, _normal               // if not Remix 1p, skip
        or      s0, a0, r0                    // original line 2

        li        t6, title_card_1_struct
        j       _return
        nop

        _normal:
        j        _return
        addiu   t6, t6, 0x5B00              // original line 1
        }

    // @ Description
    // Changes pointer to part1 pointer which establishes the stage settings of 1p for Remix 1p
    scope remix_1p_pointer_part1: {
        OS.patch_start(0x10BE90, 0x8018D630)
        j       remix_1p_pointer_part1                  
        addiu    t7, t7, 0x29BC                // original line 1
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        addiu   s7, r0, REMIX_1P_ID
        bne     t6, s7, _normal               // if not Remix 1p, skip
        sll     t6, v0, 0x4                    // original line 2

        li      t7, MATCH_SETTINGS_PART1

        _normal:
        j        _return
        nop
        }

    // @ Description
    // Changes pointer to part2 pointer which establishes the stage settings of 1p for Remix 1p
    scope remix_1p_pointer_part2: {
        OS.patch_start(0x10BEE0, 0x8018D680)
        j       remix_1p_pointer_part2                 
        addiu    t9, t9, 0x2830                // original line 1
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        addiu    t3, r0, REMIX_1P_ID
        bne     t6, t3, _normal               // if not Remix 1p, skip
        sb        t4, 0x0001(t5)                    // original line 2

        li        t9, MATCH_SETTINGS_PART2    // load address of Remix Match Settings Part 2

        _normal:
        j        _return
        nop
        }
    
    // @ Description    
    // Changes pointer in which progess icons are pulled from to the Remix versions
    scope remix_icon_pointer: {
        OS.patch_start(0x12B518, 0x801321D8)
        j       remix_icon_pointer                 
        addiu    s0, r0, REMIX_1P_ID            // Remix ID put into s0
        _return:
        OS.patch_end()
        
        li      s6, singleplayer_mode_flag       // s6 = multiman flag
        lw      s6, 0x0000(s6)              // s6 = 4 if Remix 1p
        bne     s6, s0, _normal               // if not Remix 1p, skip
        lui        s0, 0x8000                    // original line 1

        li        t6, progress_icon_struct    // load address of Remix Progress Icons
        j       _return
        nop

        _normal:
        j        _return
        addiu   t6, t6, 0x4E78              // original line 2
        }

    // @ Description
    // Makes CPU 1 a giant in Remix 1P
    scope remix_1p_giant: {
        OS.patch_start(0x10C2A8, 0x8018DA48)
        j       remix_1p_giant                 
        addiu    v0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t7, singleplayer_mode_flag  // t7 = multiman flag
        lw      t7, 0x0000(t7)              // t7 = 4 if Remix 1p
        bne     t7, v0, _normal             // if not Remix 1p, skip
        nop

        li      t7, Size.state_table
        sll     v0, a2, 0x0002              // v0 = offset to size state (port already in a2)
        addu    t4, v0, t7                  // t4 = address of size state

        li      v0, 0x800A4AD0              // load hardcoded address that has current stage
        lbu     v0, 0x0017(v0)              // load current stage
        addiu   t7, r0, 0x0006              // check for giant stage
        bne     t7, v0, _other              // jump if not giant stage
        nop
        
        lli     v0, Size.state.GIANT        // v0 = giant state
        b       _normal                     // jump to original lines
        sw      v0, 0x0000(t4)              // save size state to make character a giant
        
        _other:
        sw      r0, 0x0000(t4)              // reset size state to normal

        _normal:
        addu    v0, t9, t5                  // original line 1
        j       _return
        addiu   t7, s3, 0x0025              // original line 2
    }

    // @ Description
    // remix kirby order which replaces hardcoded location for original Kirby hats in match
     OS.align(16)
     remix_kirby_pointer:
     db     0x1E        // Ganon
     db     0x1F        // Young Link
     db     0x1D        // Falco
     db     0x20        // Doctor Mario
     db     0x22        // Dark Samus
     db     0x21        // Wario
     db     0x26        // Lucas
     db     0x34        // Bowser
     OS.align(16)
     
    // @ Description
    // remix kirby order which replaces hardcoded location for original Kirby hats in match
     OS.align(16)
     remix_kirby_hat_pointer:
     dw     0x00000011        // Ganon
     dw     0x0000000A        // Young Link
     dw     0x00000012        // Falco
     dw     0x00000010        // Doctor Mario
     dw     0x00000015        // Bowser
     dw     0x0000000F        // Wario
     dw     0x00000014        // Lucas
     dw     0x00000013        // Dark Samus
     OS.align(16)
    
    
    // @ Description
    // Allows another character to appear in Yoshi's Title Card
    scope remix_yoshi_card: {
        OS.patch_start(0x12CEB8, 0x80133B78)
        j       remix_yoshi_card               
        addiu    s6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      s3, singleplayer_mode_flag  // s3 = multiman flag
        lw      s3, 0x0000(s3)              // s3 = 4 if remix
        bne     s3, s6, _normal             // if not Remix 1p, skip
        addiu   s6, r0, 0x0012              // original line 1

        li      s3, MATCH_SETTINGS_PART1
        j       _return
        lbu     s3, 0x0019(s3)              // load remix character from Match Settings

        _normal:
        j       _return
        addiu   s3, r0, 0x0006              // original line 2, load Yoshi
        }

    // @ Description
    // Skips a routine that normally sets shades if Yoshi Player
    scope remix_yoshi_card_shade_skip: {
        OS.patch_start(0x12CF14, 0x80133BD4)
        j       remix_yoshi_card_shade_skip             
        addiu    a2, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        beq     a2, at, _normal_yoshi_load  // if Remix 1p, do the normal yoshi load
        nop
        
        _normal:
        bne     t3, a1, _normal_yoshi_load                  // original line 1, branches to location where yoshi is loaded as normal (instead of changing shade)
        nop
        
        j       _return                                     // return for additional checks that normally change Yoshi shade
        nop       

        _normal_yoshi_load:
        j       0x80133BFC
        nop
        } 

    // @ Description
    // Fixes odd Costume Color choices for Team Colors
    scope remix_yoshi_card_costumes: {
        OS.patch_start(0x12CF3C, 0x80133BFC)
        j       remix_yoshi_card_costumes              
        addiu    a2, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        bnel    a2, at, _normal             // if not Remix 1p, skip
        addiu   a2, r0, r0                  // original line 2, sets shade for Yoshi when not same color as player
        
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      a0, 0x0004(sp)
        sw      v0, 0x0008(sp)
        sw      v1, 0x000C(sp)              // save cpu character struct
        jal     Global.get_random_int_      // generate number based on total number of character pool
        addiu   a0, r0, 0x0005              // place number of costumes for all Remix Characters
        addu    a1, v0, r0                  // put randomly selected costume ID into a1 for assignment to character
        
        lw      a0, 0x0000(s4)              // load player character ID
        lw      v1, 0x000C(sp)              // load cpu player struct
        lw      v0, 0x0008(v1)              // load currently loading CPU character ID
        bnel    a0, v0, _end                // if different characters, jump to end and don't change shade
        addiu   a2, r0, r0
        
        lw      a0, 0x0004(s4)              // load player character costume
        bnel    a0, a1, _end                // if different costumes, jump to end and don't change shade
        addiu   a2, r0, r0
        
        addiu   a2, r0, 0x0001              // change to light shade because players are the same character and costume
        
        _end:
        lw      a0, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0010              // remove stack space


        _normal:
        jal     0x800E9248                  // original line 1, sets costume ID and shade for character, amongst various other things
        nop
        
        j       _return
        nop        
    }

    // @ Description
    // Sets same colored cpu to be shaded in match
    scope remix_team_shade_start: {
        OS.patch_start(0x10C440, 0x8018DBE0)
        j       remix_team_shade_start         
        addiu   t8, r0, REMIX_1P_ID         // insert Remix 1p ID
        _return:
        OS.patch_end()
        
        
        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        bne     t8, at, _normal             // if not Remix 1p, skip
        nop
        lw      t6, 0x0000(s6)              // load offset
        addu    a0, t6, s0                  // load address of cpu's info struct
        lbu     t8, 0x0023(a0)              // load spawning character
        
        bne     t5, t8, _standard           // if not the same character as opponent, skip checks
        lbu     t8, 0x0026(a0)              // load cpu costume
        lbu     at, 0x0015(s8)              // load player costume
        
        bne     t8, at, _normal             // if cpu and player don't share the same costume skip setting shade
        addiu   t8, r0, 0x0001              // shade ID for white

        j       0x8018DC18                  // jump to location past where shade is set
        sb      t8, 0x0027(a0)              // save shade id
        
        _normal:
        addiu   at, r0, 0x0006              // reinsert yoshi ID
        bnel    t5, at, _standard           // modified original line 1, compares player's character ID to yoshi's to determine if it should apply shade
        lw      t6, 0x0000(s6)              // original line 2       
        
        j       _return
        nop 
        
        _standard:
        j       0x8018DC10                  // modified original line 1, skips checks for yoshi team colors in regular 1p
        nop     
    } 
    
    // @ Description
    // Sets same colored cpu to be shaded during match after KO
    scope remix_team_shade_ko: {
        OS.patch_start(0x10CAD8, 0x8018E278)
        j       remix_team_shade_ko         
        addiu   t9, r0, REMIX_1P_ID         // insert Remix 1p ID
        _return:
        OS.patch_end()
        
        
        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        bne     t9, at, _normal             // if not Remix 1p, skip
        nop
        lw      t6, 0x0000(t1)              // load offset
        addu    t5, t6, t0                  // load address of cpu's info struct
        lbu     at, 0x0023(t5)              // load spawning character
        
        bne     at, t8, _standard           // if not the same character as opponent, skip checks
        lbu     t9, 0x0026(t5)              // load cpu costume
        lbu     at, 0x0015(a0)              // load player costume
        
        bne     t9, at, _normal             // if cpu and player don't share the same costume skip setting shade
        addiu   t9, r0, 0x0001              // shade ID for white

        j       0x8018E2B0                  // jump to location past where shade is set
        sb      t9, 0x0027(t5)              // save shade id
        
        _normal:
        addiu   at, r0, 0x0006              // reinsert yoshi ID
        bnel    t8, at, _standard           // modified original line 1, compares player's character ID to yoshi's to determine if it should apply shade
        lw      t6, 0x0000(t1)              // original line 2       
        
        j       _return
        nop 
        
        _standard:
        j       0x8018E2A8                  // modified original line 1, skips checks for yoshi team colors in regular 1p
        nop     
    } 
    
    // @ Description
    // Changes Mario to Falco for Mario Bros. Title Card
    scope doubles_card_1: {
        OS.patch_start(0x12D148, 0x80133E08)
        j       doubles_card_1                  
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      a1, singleplayer_mode_flag       // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 4 if Remix 1p
        bne     a1, a0, _normal               // if not Remix 1p, skip
        or      a0, r0, r0                    // original line 1, set id to mario

        addiu   a0, r0, 0x001D
        //addiu   s3, r0, 0x0001
        //lui     a3, 0x8013
        //addiu   a3, a3, 0x5C3C
        //addiu   a1, r0, 0x0001
        //addu    s5, a1, r0

        _normal:
        j        _return
        or      a1, s5, r0                  // original line 2
        }
    
    // @ Description    
    // Changes Luigi to Fox for Mario Bros. Title Card
    scope doubles_card_2: {
        OS.patch_start(0x12D1B4, 0x80133E74)
        j       doubles_card_2                  
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      a1, singleplayer_mode_flag  // a1 = multiman flag
        lw      a1, 0x0000(a1)              // a1 = 4 if Remix 1p
        bne     a1, a0, _normal             // if not Remix 1p, skip
        addiu   a0, r0, 0x0004              // original line 1, set id to Luigi

        addiu   a0, r0, 0x0001
        addiu   s3, r0, 0x0001

        _normal:
        j        _return
        or      a1, s5, r0                  // original line 2
        }
    
    // @ Description    
    // Loads the correct files for the Mario Bros/Doubles Stage of 1p
    scope doubles_file_loading: {
        OS.patch_start(0x12DE00, 0x80134AC0)
        j       doubles_file_loading                  
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        bne     t6, a0, _normal               // if not Remix 1p, skip
        nop

        jal     0x800D786C                  // file loading routine for characters
        addiu   a0, r0, 0x0001              // insert Fox ID
        
        jal     0x800D786C                  // file loading routine for characters
        addiu   a0, r0, 0x001D              // insert Falco ID
        
        j       0x80134AD0                  // skip over luigi loading routine
        nop

        _normal:
        jal     0x800D786C                  // original line 1
        or      a0, r0, r0                  // original line 2 (Mario ID inserted)
        j        _return                     // return
        nop
        }
    
    // @ Description    
    // Loads the correct files for the Giant Stage of 1p
    scope giant_file_loading: {
        OS.patch_start(0x12DDE8, 0x80134AA8)
        j       giant_file_loading                  
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t6, singleplayer_mode_flag       // t6 = multiman flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        bne     t6, a0, _normal               // if not Remix 1p, skip
        nop

        sll     t1, s0, 0x2
        addu    t2, s1, t1
        jal     0x800D786C                  // file loading routine for characters
        lw      a0, 0x0000(t2)              // load character ID
        
        j       _return                     // return
        nop

        _normal:
        jal     0x800D786C                  // original line 1
        addiu   a0, r0, 0x0002              // original line 2 (DK ID inserted)
        j        _return                     // return
        nop
        }
    
    // @ Description
    // Sets correct Model for CPU Player
    scope giant_card: {
        OS.patch_start(0x12D114, 0x80133DD4)
        j       giant_card                  
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      a2, singleplayer_mode_flag       // a2 = multiman flag
        lw      a2, 0x0000(a2)              // a2 = 4 if Remix 1p
        bne     a2, a0, _normal               // if not Remix 1p, skip
        addiu   a0, r0, 0x0002              // original line 1, insert DK ID for Character routine

        li      a0, MATCH_SETTINGS_PART1
        j       _return
        lbu     a0, 0x0069(a0)              // load remix character from Match Settings

        _normal:
        j        _return                     // return
        or      a1, s5, r0                  // original line 2
        }
    
    // @ Description
    // Revises the selection of kirby hats to use remix characters for title card
    scope remix_kirby_card: {
        OS.patch_start(0x12C3CC, 0x8013308C)
        j       remix_kirby_card                   
        addiu    t7, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t8, singleplayer_mode_flag       // t8 = multiman flag
        lw      t8, 0x0000(t8)              // t8 = 4 if remix
        bne     t8, t7, _normal             // if not Remix 1p, skip
        nop

        li      t6, remix_kirby_hat_pointer     // load address of remix address
        j       _return
        lw      t8, 0x0000(t6)              // original line 2

        _normal:
        addiu    t6, t6, 0x4FD8                // original line 1
        j        _return
        lw      t8, 0x0000(t6)              // original line 2
        }
    
    // @ Description
    // Revises the selection of kirby powers to use remix characters
    scope remix_kirby_selection: {
        OS.patch_start(0x10CBD0, 0x8018E370)
        j       remix_kirby_selection                   
        addiu    t4, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t9, singleplayer_mode_flag       // t9 = multiman flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        bne     t9, t4, _normal             // if not Remix 1p, skip
        nop

        li      t5, remix_kirby_pointer
        addu    t5, v0, t5
        j       _return
        lbu     t5, 0x0000(t5)

        _normal:
        addu    t5, t5, v0                    // original line 1
        j        _return
        lbu        t5, 0x2800(t5)                    // original line 2
        }
    
    // @ Description
    // Changes a branch that would typically be used by the game to put a random kirby with on of the unlockable characters
    scope remix_kirby_skip: {
        OS.patch_start(0x10CBA4, 0x8018E344)
        j       remix_kirby_skip                   
        nop
        _return:
        OS.patch_end()
        
        li      v1, singleplayer_mode_flag  // v1 = multiman flag
        lw      v1, 0x0000(v1)              // v1 = 1 if multiman
        beqz    v1, _normal                 // if not added mode, skip
        or      v1, v0, r0                  // original line 2

        regular_kirby:
        j       0x8018E36C                  // always load from standard kirby list
        nop

        _normal:
        bne     v0, at, regular_kirby       // original line 1, modified
        nop
        
        j       _return                     // this path is taken to load a random unlockable character kirby normally
        nop
        }
    
    // @ Description
    // Revises the initial selection of kirby powers to use remix characters
    scope remix_kirby_selection_initial: {
        OS.patch_start(0x10C6F4, 0x8018DE94)
        j       remix_kirby_selection_initial                 
        addiu   t4, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
        
        li      t5, singleplayer_mode_flag       // t9 = multiman flag
        lw      t5, 0x0000(t5)              // t9 = 1 if multiman
        bne     t5, t4, _end                // if not Remix 1p, skip
        nop

        li      s5, remix_kirby_pointer     // set s5, the pointer to the list of kirby powers, to remix version

        _end:
        sll        t9, s4, 0x5                    // original line 1
        j        _return
        addu    t4, s5, v1                    // original line 2
        }
    
    // @ Description
    // Makes it so the Kirby Stage of Remix 1p loads a file which will load all necessary files for his powers
    scope remix_1p_kirby_load: {
        OS.patch_start(0x10E1D0, 0x8018F970)
        j       remix_1p_kirby_load                 
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()
      
        li      s0, singleplayer_mode_flag  // s0 = multiman flag
        lw      s0, 0x0000(s0)              // s0 = 4 if Remix 1p
        bne     s0, a0, _normal             // if not Remix 1p, skip
        lui     s0, 0x8011                  // original line 1

        j       _return
        addiu   s1, s1, 0x0C1B              // load in Remix version of Kirby Stage File (which loads in various character files

        _normal:
        j       _return
        addiu   s1, s1, 0x00E6              // original line 2
      }
    
    // @ Description
    //  Skips a function that partially deals with unique spawning on Master Hand Stage
    scope _final_stage_spawn: {
        OS.patch_start(0x10C08C, 0x8018D82C)
        j        _final_stage_spawn
        nop
        _return:
        OS.patch_end()

        beq     a1, s1, _final              // modified original line 1
        nop
        _standard:
        j       _return                     // if not final stage, return as usual
        nop

        _final:
        li      at, singleplayer_mode_flag  // at = multiman flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        addiu   t5, r0, REMIX_1P_ID         // insert Remix 1p ID
        beq        t5, at, _standard           // do a standard spawn if Remix 1p
        nop
        
        j        0x8018D844
        addiu   t5, r0, 0x0001                // original line 2
    }
    
    // @ Description
    //  Prevents Giga Bowser from using Grounded Down Special
    //  This hook is in the generic function that determines the initial routine for a dsp. Skipping it, prevents move from starting
    scope _giga_dsp_prevent: {
        OS.patch_start(0xCBC4C, 0x8015120C)
        j       _giga_dsp_prevent
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0000(sp)
        sw      t2, 0x0004(sp)
        addiu   t2, r0, REMIX_1P_ID         // insert Remix 1p ID
        li      at, singleplayer_mode_flag  // t0 = Single Player Mode Flag address
        lw      at, 0x0000(at)              // t0 = 4 if remix 1p
        
        bne     at, t2, _standard           // do dsp as normal
        nop
        
        lw      at, 0x0008(v0)              // load player ID
        addiu   t2, r0, Character.id.GBOWSER    // GIGA Bowser ID inserted
        
        bne     at, t2, _standard           // do dsp as normal, as it is not giga bowser
        lbu     at, 0x0023(v0)              // load player types
        
        beqz    at, _standard               // if player type = 0, then its a human player and it should proceed as normal
        nop
        
        addiu   t1, r0, r0                  // set t1 to 0, so it takes branch that skips function     
        
        
        _standard:
        lw      at, 0x0000(sp)
        lw      t2, 0x0004(sp)
        addiu   sp, sp, 0x0010              // deallocate stack space
        bgezl   t1, _skip_move              // modified original line 1
        or      v0, r0, r0                  // modified original line 2
        
        j        _return                    // return as move should function
        nop
        
        _skip_move:
        j       0x8015124C                  // path taken when skipping move function
        nop
    }
    
    // @ Description
    //  Prevents Giga Bowser from using Grounded Up Special
    //  This hook is in the generic function that determines the initial routine for a usp. Skipping it, prevents move from starting
    scope _giga_usp_prevent: {
        OS.patch_start(0xCBBC8, 0x80151188)
        j       _giga_usp_prevent
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0000(sp)
        sw      t2, 0x0004(sp)
        addiu   t2, r0, REMIX_1P_ID         // insert Remix 1p ID
        li      at, singleplayer_mode_flag  // t0 = Single Player Mode Flag address
        lw      at, 0x0000(at)              // t0 = 4 if remix 1p
        
        bne     at, t2, _standard           // do usp as normal
        nop
        
        lw      at, 0x0008(v0)              // load player ID
        addiu   t2, r0, Character.id.GBOWSER    // GIGA Bowser ID inserted
        bne     at, t2, _standard           // do usp as normal, as it is not giga bowser
        lbu     at, 0x0023(v0)              // load player types
        beqz    at, _standard               // if player type = 0, then its a human player and it should proceed as normal
        nop
        addiu   t0, r0, r0                  // set t1 to 0, so it takes branch that skips function     
        
        
        _standard:
        lw      at, 0x0000(sp)
        lw      t2, 0x0004(sp)
        addiu   sp, sp, 0x0010              // deallocate stack space
        bgezl   t0, _skip_move              // modified original line 1
        or      v0, r0, r0                  // modified original line 2
        
        j        _return                    // return as move should function
        nop
        
        _skip_move:
        j       0x801511C8                  // path taken when skipping move function
        nop
    }

    // @ Description
    // Makes it so after gameover, that page is set to 0/ normal
    scope game_over_end: {
        OS.patch_start(0x17A3F0, 0x80133990)
        j       game_over_end                
        nop                                 // original line 2
        _return:
        OS.patch_end()
      
        li      at, page_flag               // at = page flag address

        jr      ra                          // original line 1
        sw      r0, 0x0000(at)              // clear page flag
    }
    
}
