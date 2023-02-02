scope SinglePlayerModes: {
    // 8018F7B4 - 1p stage/rttf init
    // 8018E5F8 - 1p targets/platforms init
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
    // 0x0001 = Bonus 3
    // 0x0002 = Multiman
    // 0x0003 = Cruel Multiman
    // 0x0004 = Remix
    // 0x0005 = All Star
    // 0x0006 = HRC
    // 0x0000 = standard
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

    // @ Description
    // This is how we keep track of which character we have progressed to
    allstar_progress:
    dw OS.FALSE
    OS.align(4)

    // @ Description
    // This is how we keep track of hearts used
    allstar_hearts:
    dw OS.FALSE
    OS.align(4)

    // @ Description
    // This is how we keep track of percent of the character
    allstar_percent:
    dw OS.FALSE
    OS.align(4)

    // @ Description
    // Set if allstar can end
    end_game_flag:
    dw OS.FALSE
    OS.align(4)

    // @ Description
    // Set if allstar is ongoing or not
    match_begin_flag:
    dw OS.FALSE
    OS.align(4)

    // @ Description
    // Set if allstar is ongoing or not
    allstar_limbo:
    dw OS.FALSE
    OS.align(4)

// CONSTANTS

    constant KO_AMOUNT_POINTER(0x801936A0)
    constant TIME_SAVE_POINTER(0x800A4B30)
    constant HRC_ID(0x6)
    constant ALLSTAR_ID(0x5)
    constant REMIX_1P_ID(0x4)
    constant CRUEL_ID(0x3)
    constant MULTIMAN_ID(0x2)
    constant BONUS3_ID(0x1)
    constant MENU_INDEX(0x801331B8)
    constant STAGE_FLAG(0x800A4AE7)
    constant PLAYER_PERCENT(0x800A4B84)

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
        li      at, singleplayer_mode_flag  // at = singleplayer mode flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        beq     at, t1, _bonus3
        addiu   t1, r0, REMIX_1P_ID
        beq     at, t1, _1p
        addiu   t1, r0, ALLSTAR_ID
        beq     at, t1, _1p
        addiu   t1, r0, HRC_ID
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

        li      t6, singleplayer_mode_flag    // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)                // t6 = 1 if multiman
        addiu   at, r0, REMIX_1P_ID
        beq     t6, at, _1p                   // NORMAL 1P IF REMIX 1P
        addiu   at, r0, ALLSTAR_ID
        beq     t6, at, _1p                   // NORMAL 1P IF ALLSTAR
        addiu   at, r0, HRC_ID
        beq     t6, at, _1p                   // NORMAL 1P IF HRC
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

        li        t4, singleplayer_mode_flag  // t4 = singleplayer mode flag
        lw        t4, 0x0000(t4)            // t4 = 1 if multiman
        beq       t4, t5, _bonus3
        addiu     t5, r0, REMIX_1P_ID

        beq       t4, t5, _1p
        addiu     t5, r0, ALLSTAR_ID

        beq       t4, t5, _1p
        addiu     t5, r0, HRC_ID

        beq       t4, t5, _hrc
        nop
        bnez      t4, _multiman             // if multiman, skip
        nop

        _1p:
        lbu       t4, 0x0001(s7)            // original line 1
        lw        t5, 0x0000(s6)            // original line 2
        j        _return
        nop

        _multiman:
        addiu    t4, r0, 0x000E             // load in Duel Zone
        lw       t5, 0x0000(s6)             // original line 2
        j        _return
        nop

        _hrc:
        lli      t4, Stages.id.HRC          // load in HRC
        lw       t5, 0x0000(s6)             // original line 2
        j        _return
        nop

        _bonus3:
        addiu    t4, r0, 0x000F             // load in RTF
        lw       t5, 0x0000(s6)             // original line 2
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

        li      t7, singleplayer_mode_flag      // t7 = singleplayer mode flag
        lw      t7, 0x0000(t7)                  // t7 = 2 if multiman
        beq     t7, t8, _bonus3
        addiu   t8, r0, REMIX_1P_ID             // Remix 1p Mode Flag
        beq     t7, t8, _1p
        addiu   t8, r0, ALLSTAR_ID              // Allstar Flag
        beq     t7, t8, _1p
        addiu   t8, r0, HRC_ID                  // HRC Flag
        beq     t7, t8, _1p
        nop

        bnez    t7, _multiman                   // if multiman, skip
        nop

        _1p:
        lw      t7, 0x0000(s6)                  // original line 1
        j       _return
        sb      t6, 0x0009(t7)                  // original line 2

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

        li      t6, singleplayer_mode_flag      // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)                  // t6 = 2 if multiman

        addiu   t4, r0, REMIX_1P_ID
        beq     t4, t6, _1p
        addiu   t4, r0, ALLSTAR_ID
        beq     t4, t6, _1p
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

        li      t6, singleplayer_mode_flag      // t6 = singleplayer mode flag
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

        li      t8, singleplayer_mode_flag      // t8 = singleplayer mode flag
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

        li      t4, singleplayer_mode_flag      // t4 = singleplayer mode flag
        lw      t4, 0x0000(t4)                  // t4 = 1 if multiman
        beq     t4, at, _bonus3
        lui     at, 0x8019                      // original line 2
        addiu   at, r0, REMIX_1P_ID
        beq     t4, at, _1p
        lui     at, 0x8019                      // original line 2
        addiu   at, r0, ALLSTAR_ID
        beq     t4, at, _1p
        lui     at, 0x8019                      // original line 2
        addiu   at, r0, HRC_ID
        beq     t4, at, _1p
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
        addiu   t5, r0, ALLSTAR_ID
        beq     t8, t5, _1p
        addiu   t5, r0, HRC_ID
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

        li      t7, singleplayer_mode_flag      // t7 = singleplayer mode flag
        lw      t7, 0x0000(t7)                  // t7 = 1 if multiman
        addiu   t8, r0, REMIX_1P_ID
        beq     t7, t8, _1p
        addiu   t8, r0, ALLSTAR_ID
        beq     t7, t8, _1p
        addiu   t8, r0, HRC_ID
        beq     t7, t8, _hrc
        nop
        bnez    t7, _multiman                   // if multiman, skip
        nop

        _1p:
        j       _return
        lbu     t7, 0x0009(t6)                  // original line 1

        _hrc:
        j       _return
        lli     t7, Character.id.SANDBAG        // set as sandbag

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

        li      at, Practice_1P.practice_active // load practice flag location
        lw      at, 0x0000(at)
        bnez    at, _infinite_time              // if Practice mode is active, set to infinite time
        nop

        li      at, singleplayer_mode_flag      // at = SingePlayer Mode flag
        lw      at, 0x0000(at)                  // at = 0 if original 1p

        addiu   t8, r0, ALLSTAR_ID              // allstar ID
        beq     t8, at, _allstar                // branch if allstar
        addiu   t8, r0, REMIX_1P_ID             // remix ID
        beq     t8, at, _1p                     // branch if Remix 1p
        addiu   t8, r0, HRC_ID                  // HRC ID
        beq     t8, at, _1p                     // branch if HRC
        nop
        bnez    at, _infinite_time              // if multiman or Bonus 3, set to infinite time
        nop

        beq     r0, r0, _1p                     // if Remix or regular 1p, proceed as normal
        nop

        _allstar:
        li      at, STAGE_FLAG                  // load current stage address
        lb      at, 0x0000(at)                  // load current stage
        beqz    at, _infinite_time              // if rest stage, have infinite time
        nop


        _1p:
        sltiu   at, t9, 0x0007
        beq     at, r0, _branch
        sll     t9, t9, 0x2
        lui     at, 0x8019
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

        _infinite_time:
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

        li      t6, singleplayer_mode_flag      // t9 = singleplayer mode flag
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
        addiu   t0, r0, ALLSTAR_ID              // Allstar ID entered

        beq     t6, t0, _allstar                // Branch if Remix 1p
        addiu   t0, r0, HRC_ID                  // HRC ID entered

        beq     t6, t0, _bonus3                 // Branch if HRC
        nop

        bnez    t6, _multiman                   // if a multiman mode, branch
        nop
        beq     r0, r0, _1p                     // if all other checks fail, go to original 1p coding
        lw      t0, 0x0004(sp)                  // ~

        _allstar:
        li      t0, 0x800A4AE7
        lbu     t0, 0x0000(t0)                  // load from current progress of 1p ID
        bnez    t0, _1p
        lw      t0, 0x0004(sp)                  // ~

        addiu   sp, sp, 0x0010                  // deallocate stack space
        li      t6, 0x8018EB30                  // load normal spawn
        j        _return
        nop

        _remix_1p:
        li      t0, 0x800A4AE7
        lbu     t0, 0x0000(t0)                  // load from current progress of 1p ID
        addiu   t6, r0, 0x000D
        beq     t0, t6, _giga
        lw      t0, 0x0004(sp)                  // ~

        _1p:
        addiu   sp, sp, 0x0010                  // deallocate stack space
        j        _return
        lw       t6, 0x2EE0(at)                // original line 2

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
    //  Initial Screen Transition Setting in 1p, this is used for multiman and allstar in order to skip the title card screen
    scope _initial_screen_set: {
        OS.patch_start(0x12DC90, 0x80134950)
        j       _initial_screen_set
        addiu   t9, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      at, singleplayer_mode_flag  // at = singleplayer mode flag
        lw      at, 0x0000(at)              // at = 1 if bonus 3
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
        sb       t9, 0x0000(v0)             // original line 2, this was causing an issue with rendering the correct objects on the right screen
    }

    // @ Description
    // This makes the reset button graphic appear in Bonus 3, Multiman, and Cruel
    scope _reset_button: {
        OS.patch_start(0x8F668, 0x80113E68)
        j       _reset_button
        addiu   at, r0, 0x0077              // Bonus 3, Multiman, Cruel Man "screen" (fake screen)
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x10
        sw      t8, 0x0004(sp)
        sw      t5, 0x0008(sp)
        li      t8, singleplayer_mode_flag
        lw      t8, 0x0000(t8)
        addiu   t5, r0, ALLSTAR_ID
        beq     t8, t5, _normal
        lw      t5, 0x0008(sp)
        beq     t7, at, _reset
        nop
        li      t8, Practice_1P.practice_active // load practice flag location
        lw      t8, 0x0000(t8)
        bnez    t8, _reset                  // if Practice mode is active, show reset
        addiu   at, r0, 0x0035              // original check
        bne     t7, at, _normal             // original line 1 modified
        nop

        _reset:
        lw      t8, 0x0004(sp)
        addiu   sp, sp, 0x10
        j       _return                     // path taken to show Reset Button
        nop

        _normal:
        lw      t8, 0x0004(sp)
        addiu   sp, sp, 0x10
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

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)
        sw      t1, 0x0008(sp)
        li      t0, singleplayer_mode_flag
        lw      t0, 0x0000(t0)
        addiu   t1, r0, ALLSTAR_ID
        beql    t0, t1, _normal             // do normal version if Allstar Mode
        addiu   at, r0, 0x0035              // set screen ID under normal circumstances
        beq     t9, at, _multiman           // Branch if on fake screen
        addiu   at, r0, 0x0035              // set screen ID under normal circumstances
        bne     t9, at, _normal             // modified original line 1
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        j       _return
        addiu   sp, sp, 0x0010              // allocate stack space

        _multiman:
        li      t0, reset_flag              // load reset flag location
        addiu   t1, r0, 0x0001              // save a one to it so that it is set to reset
        sw      t1, 0x0000(t0)              // ~
        lw      t0, 0x0004(sp)
        lw      t1, 0x0008(sp)
        addiu   sp, sp, 0x0010              // allocate stack space
        j       _return
        nop

        _normal:
        lw      t1, 0x0008(sp)
        addiu   sp, sp, 0x0010              // allocate stack space

        li      t0, Practice_1P.practice_active
        lw      t0, 0x0000(t0)              // t0 = practice mode active flag
        bnez    t0, _practice               // if Practice mode is active, reset
        nop
        j       0x80114560                  // otherwise, skip resetting
        nop

        _practice:
        li      t0, reset_flag              // load reset flag location
        addiu   t1, r0, 0x0001              // save a one to it so that it is set to reset
        sw      t1, 0x0000(t0)
        li      t0, Global.current_screen
        lli     t1, 0x0002                  // t1 = 2 (Practice reset)
        sb      t1, 0x0012(t0)              // set flag to exit 1p to 2 for practice reset
        lli     t1, 0x0001                  // t1 = 1
        li      t0, Global.screen_interrupt
        j       0x80114560
        sw      t1, 0x0000(t0)              // force screen interrupt
    }

    // @ Description
    // Loads the Bonus 3 version of timer
    scope _load_timer: {
        OS.patch_start(0x10E558, 0x8018FCF8)
        j       _load_timer
        addiu   at, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag  // t9 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t9 = 1 if multiman
        beql    t6, at, _bonus3             // if Bonus 3, skip
        addiu   t6, r0, 0x0000              // clear out register in abundance of caution
        lli     at, HRC_ID                  // at = HRC ID
        beq     t6, at, _bonus3             // if HRC, skip
        addiu   t6, r0, 0x0000              // clear out register in abundance of caution

        li      t6, STAGE_FLAG              // load current stage ID address
        lb      t6, 0x0000(t6)              // load stage ID
        // don't need this check if using INF time
        // addiu   at, r0, 0x000B              // stage 11 - RTTF
        // beq     t6, at, _normal             // do normal loading if on 1P RTTF
        // addiu   t6, r0, 0x0000              // clear out register in abundance of caution

        li      t6, Practice_1P.practice_active // load practice flag location
        lw      t6, 0x0000(t6)
        bnez    t6, _bonus3                 // if Practice mode is active, skip
        addiu   t6, r0, 0x0000              // clear out register in abundance of caution

        _normal:
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
        dw      0x470CA000
        dw      0x45610000
        dw      0x44160000
        dw      0x42700000
        dw      0x40C00000
        dw      0x3F0DD2F2
        bonus3_timer_struct:
        dw      0x000000CF
        dw      0x000000DE
        dw      0x000000F0
        dw      0x000000FF
        dw      0x00000111
        dw      0x00000120

        // routine responsible for updating the timer throughout the match
        update_routine:
        li      t6, 0x800A4B18                    // this replaces a pointer being loaded from a hardcoded location to find a stage information struct that includes current time

        li      at, 0x00034BC0
        lw      v0, 0x0018(t6)

        // If HRC, count down from 10 seconds
        li      v1, singleplayer_mode_flag
        lw      v1, 0x0000(v1)                    // v1 = singleplayer_mode_flag
        lli     a1, HRC_ID                        // a1 = HRC ID
        bne     v1, a1, _update_routine_continue  // if not HRC, skip
        lli     v1, 0x0258                        // v1 = 10 seconds

        subu    v0, v1, v0                        // v0 = time remaining
        bgez    v0, _update_routine_continue      // if time remaining, continue
        nop                                       // if time is up, return
        jr      ra
        nop

        _update_routine_continue:
        OS.copy_segment(0x112868, 0x0C)

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
        lw      t4, 0x004C(sp)              // original line 2
        _return:
        OS.patch_end()

        li      t3, singleplayer_mode_flag  // t3 = singleplayer mode flag
        lw      t3, 0x0000(t3)              // t3 = 2 if multiman
        addiu   t2, r0, REMIX_1P_ID
        beq     t3, t2, _1p                 // if multiman, skip
        addiu   t2, r0, ALLSTAR_ID
        beq     t3, t2, _1p
        nop
        bnez    t3, _multiman               // if multiman, skip
        nop

        _1p:
        lbu     t3, 0x0012(s2)              // refresh t3
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

        li      t8, singleplayer_mode_flag      // t8 = singleplayer mode flag
        lw      t8, 0x0000(t8)                  // t8 = 2 if multiman
        beq     t8, at, _multiman               // if multiman, skip
        addiu   at, r0, CRUEL_ID                // insert check
        beq     t8, at, _cruel                  // if multiman, skip
        addiu   at, r0, ALLSTAR_ID              // insert check
        bne     t8, at, _normal                 // if not allstar, branch
        nop
        li      at, allstar_limbo
        sw      t8, 0x0000(at)                  // set limbo to true

        _normal:
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

        li      t8, KO_AMOUNT_POINTER
        lw      t8, 0x0000(t8)
        li      at, Character.MULTIMAN_HIGH_SCORE_TABLE
        lw      a0, 0x0008(s0)
        sll     a0, a0, 0x0002
        addu    a1, at, a0
        lw      a0, 0x0000(a1)
        ble     t8, a0,    _end
        nop
        li      a0, Character.MULTIMAN_HIGH_SCORE_TABLE_BLOCK

        jal     SRAM.save_
        sw      t8, 0x0000(a1)

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0018              // deallocate stack space
        lb      t8, 0x002B(a2)              // original line 1
        j       _return
        addiu   at, r0, 0xFFFF              // original line 2
    }

    // @ Description
    //    This saves the time to SRAM block when the Player Character completes race to the finish
    scope _time_save: {
        OS.patch_start(0x90564, 0x80114D64)
        j        _time_save
        addiu    a1, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      a0, SinglePlayerEnemy.enemy_port
        lw      a0, 0x0000(a0)              // a0 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnez    a0, _skip                   // skip if 1p control active
        sw      ra, 0x0014(sp)              // original line 1

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t4, 0x0004(sp)              // ~
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        li      a0, singleplayer_mode_flag  // a0 = singleplayer mode flag
        lw      a0, 0x0000(a0)              // a0 = 1 if bonus 3
        beq     a0, a1, _bonus3             // if bonus 3, do save check
        lli     a1, HRC_ID                  // a1 = HRC_ID
        bne     a0, a1, _original           // if not hrc, skip
        nop

        _hrc:
        li      a3, Character.HRC_HIGH_SCORE_TABLE        // high score table start loaded in
        li      t7, Character.HRC_HIGH_SCORE_TABLE_BLOCK
        li      a1, HRC.distance                          // distance address loaded in
        lw      a0, 0x0008(t9)                            // a0 = character ID
        b       _save_check
        lli     t8, OS.TRUE                               // t8 = TRUE = is HRC

        _bonus3:
        li      a3, Character.BONUS3_HIGH_SCORE_TABLE     // high score table start loaded in
        li      t7, Character.BONUS3_HIGH_SCORE_TABLE_BLOCK
        li      a1, TIME_SAVE_POINTER                     // time address loaded in
        lli     t8, OS.FALSE                              // t8 = FALSE = not HRC
        lw      a0, 0x0008(v0)                            // character ID loaded in

        _save_check:
        sll     a0, a0, 0x0002                            // shifted left to find character's word
        addu    a3, a0, a3                                // character's save location address put in a3
        lw      t2, 0x0000(a3)                            // load in current record
        beq     t2, r0, _no_previous_record               // if there is no record, skip next check and new record sound effect function
        lw      t4, 0x0000(a1)                            // finish time/distance loaded in
        li      t0, 0xAAAAAAAA
        beq     t2, t0, _no_previous_record               // console fix
        nop

        sltu    t1, t2, t4                                // t1 = 1 if distance is farther, 0 if shorter
        beqzl   t8, _check_new_record                     // if bonus 3, check if time is faster (less than)
        sltu    t1, t4, t2                                // t1 = 1 if time is slower, 0 if quicker

        _check_new_record:
        beqz    t1, _original                             // if record is a quicker time/farther distance, do not save new time
        nop

        li      t0, new_record_flag
        addiu   t1, r0, 0x0001
        sw      t1, 0x0000(t0)

        _no_previous_record:
        or      a0, t7, r0                  // a0 = high score table block
        sw      t4, 0x0000(a3)
        lw      t4, 0x0000(sp)              // ~
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     SRAM.save_
        nop
        j       _return
        lui     a0, 0x8011                  // original line 2

        _original:
        lw      t4, 0x0000(sp)              // ~
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        _skip:
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

        li      t9, SinglePlayerEnemy.enemy_port
        lw      t9, 0x0000(t9)                  // a0 = 0 for off/cpu, 1 for 1p, 2 for 2p, 3 for 3p, and 4 for 4p
        bnez    t9, _end                        // skip if 1p control active
        nop

        li       t9, singleplayer_mode_flag     // a0 = singleplayer mode flag
        lw       t9, 0x0000(t9)                 // a0 = 1 if bonus 3
        beq      at, t9, _do_new_record         // if Bonus 3, do new record
        lli      at, HRC_ID                     // at = HRC_ID
        bne      at, t9, _end                   // if not HRC, skip
        nop

        _do_new_record:
        li       t9, new_record_flag            // load new record flag address
        lw       at, 0x0000(t9)                 // load current flag
        beq      at, r0, _end                   // if not a new record, proceed as normal
        addiu    at, r0, 0x01CB                 // insert the Complete! sound id into at
        bne      at, a0, _end                   // if a0 does not equal Complete! sound, skip
        sw       r0, 0x0000(t9)                 // return new record flag to 0
        addiu    a0, r0, 0x1D0                  // insert new record sound ID into a0 for later saving

        _end:
        lui     at, 0x8013                      // original line 1
        j       _return
        addu    at, at, t8                      // original line 2
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

        li      t8, singleplayer_mode_flag    // t8 = singleplayer mode flag
        lw      t8, 0x0000(t8)                // t8 = 1 if multiman
        beq     t5, t8, _bonus3
        addiu   t5, r0, REMIX_1P_ID
        beq     t5, t8, _1p
        addiu   t5, r0, HRC_ID
        beq     t5, t8, _1p
        addiu   t5, r0, ALLSTAR_ID
        beq     t5, t8, _allstar
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

        _allstar:
        li      t5, STAGE_FLAG                // load current stage ID address
        lb      t5, 0x0000(t5)                // load stage ID
        addiu   t8, r0, 0x0005                // stage 5 - Triple Battle
        bne     t5, t8, _1p                   // do normal loading if not on triple
        addiu   t8, r0, 0x0000                // behavior set to standard
        j       _return
        sb      t8, 0x2FF8(at)                // original line 2
    }

    // @ Description
    //    Prevents a counter from changing so that spawns may continue indefinitely
    scope _infinite_spawn_1: {
    OS.patch_start(0x10CBEC, 0x8018E38C)
        j        _infinite_spawn_1
        sw        v1, 0x000C(a3)                // original line 1
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag      // t4 = singleplayer mode flag
        lw      t7, 0x0000(t7)                  // t4 = 1 if multiman
        addiu   at, r0, REMIX_1P_ID
        beq     at, t7, _1p
        addiu   at, r0, ALLSTAR_ID
        beq     at, t7, _1p
        nop

        bnez    t7, _multiman                   // if multiman, skip
        nop

        _1p:
        j        _return
        addiu    t7, v0, 0x0001                 // original line 2

        _multiman:
        j        _return
        addiu    t7, v0, r0                     // prevent change to spawn counter 1
        }

    // @ Description
    //    Prevents of branch from being taken that occassionally leads to crashes and serves no purpose
    scope _death_crash: {
    OS.patch_start(0x10D8B4, 0x8018F054)
        j        _death_crash
        nop
        _return:
        OS.patch_end()

        li      t9, singleplayer_mode_flag      // t9 = singleplayer mode flag
        lw      t9, 0x0000(t9)
        addiu   at, r0, REMIX_1P_ID
        beq     at, t9, _1p
        addiu   at, r0, 0x0005                  // original line 2
        addiu   at, r0, ALLSTAR_ID
        beq     at, t9, _1p
        addiu   at, r0, 0x0005                  // original line 2
        bnez    t9, _multiman                   // if multiman, skip
        nop

        _1p:
        j        _return
        lbu        t9, 0x0011(a3)               // original line 2

        _multiman:
        j        _return
        addiu    t9, r0, 0x0001                 // set to safe number that won't take branch
        }

    // @ Description
    //    Prevents a counter from changing so that spawns may continue indefinitely
    scope _infinite_spawn_2: {
    OS.patch_start(0x10CA2C, 0x8018E1CC)
        j        _infinite_spawn_2
        addiu    t8, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag       // t7 = singleplayer mode flag
        lw      t7, 0x0000(t7)              // t7 = 1 if multiman
        beq     t7, t8, _1p
        addiu   t8, r0, ALLSTAR_ID
        beq     t7, t8, _1p
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

        li      t9, singleplayer_mode_flag       // t9 = singleplayer mode flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        addiu   t3, r0, REMIX_1P_ID
        beq     t3, t9, _1p
        addiu   t3, r0, ALLSTAR_ID
        beq     t3, t9, _1p
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

        li      at, singleplayer_mode_flag  // at = singleplayer mode flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        beq     at, t7, _1p
        nop
        bnez    at, _multiman               // if multiman or allstar, skip
        nop

        _1p:
        li      at, Practice_1P.practice_active // load practice flag location
        lw      at, 0x0000(at)
        beqz    at, _dont_skip              // if Practice mode is not active, don't check for reset
        nop
        li      t7, reset_flag              // load reset flag location
        lw      at, 0x0000(t7)              // at = 1 if we are resetting the match
        bnezl   at, _multiman               // if Practice reset, skip
        sw      r0, 0x0000(t7)              // save 0 to reset_flag location so future matches don't automatically reset

        _dont_skip:
        sltiu   at, v0, 0x003C              // reinsert at
        bnel    at, r0, _branch             // modified original line 1
        lw      ra, 0x0014(sp)              // original line 2

        j        _return
        nop

        _branch:
        j        0x801349EC
        nop

        j        _return
        nop

        _multiman:
        sltiu   at, v0, 0x003C              // reinsert at
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

        li      a1, singleplayer_mode_flag  // a1 = singleplayer mode flag
        lw      a1, 0x0000(a1)              // a1 = 1 if multiman
        addiu   t6, r0, REMIX_1P_ID
        beq     a1, t6, _1p
        nop
        bnez    a1, _multiman               // if multiman, skip
        nop

        _1p:
        li      a1, Practice_1P.practice_active // load practice flag loca1ion
        lw      a1, 0x0000(a1)
        beqz    a1, _dont_skip              // if Practice mode is not active, don't check for reset
        nop
        li      t6, reset_flag              // load reset flag loca1ion
        lw      a1, 0x0000(t6)              // a1 = 1 if we are resetting the ma1ch
        bnez    a1, _multiman               // if Practice reset, skip
        nop                                 // don't clear reset_flag yet

        _dont_skip:
        jal     0x80020AB4
        addiu   a1, r0, 0x0023

        j       _return
        nop

        _multiman:
        j        _return
        addiu    a1, r0, r0                 // clear a1 just in case
    }

    // @ Description
    // Skips a c flag function which delays music change
    scope skip_cflag_music_function: {
        OS.patch_start(0x10E514, 0x8018FCB4)
        j        skip_cflag_music_function
        addiu    at, r0, MULTIMAN_ID        // multiman mode check placed in
        _return:
        OS.patch_end()

        li      v0, singleplayer_mode_flag  // v0 = singleplayer mode flag
        lw      v0, 0x0000(v0)              // v0 = 2 if multiman
        beq     v0, at, _multiman           // if multiman, skip
        addiu   at, r0, CRUEL_ID            // multiman mode check placed in
        beq     v0, at, _multiman           // if cruel multiman, skip
        addiu   at, r0, HRC_ID              // HRC check placed in
        beq     v0, at, _multiman           // if cruel multiman, skip
        addiu   at, r0, REMIX_1P_ID         // REMIX 1p ID check placed in
        bne     v0, at, _normal
        nop

        li      v0, STAGE_FLAG              // load from current progress of 1p ID
        lb      v0, 0x0000(v0)              // load current progress in 1p
        addiu   at, r0, 0x000A              // Boss Stage ID entered
        beq     v0, at, _multiman           // prevents from going to a routine that prevents forcing stage music
        nop

        _normal:
        lui     v0, 0x800A                  // original line 1
        j       _return
        lbu     v0, 0x4AE7(v0)              // original line 2

        _multiman:
        lui     v0, 0x800A                  // original line 1
        j       0x8018FCE8                  // return
        lbu     v0, 0x4AE7(v0)              // original line 2
    }

    // @ Description
    // Forces a specific song to play
    scope set_bgm: {
        OS.patch_start(0x10E548, 0x8018FCE8)
        j        set_bgm
        addiu    a1, r0, MULTIMAN_ID        // multiman mode check placed in
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag  // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 2 if multiman
        beq     t6, a1, _multiman           // if multiman, skip
        addiu   a1, r0, 0x007E              // places multiman music ID into argument
        addiu   a1, r0, CRUEL_ID            // cruel mode check placed in
        beq     t6, a1, _cruel_multiman     // if multiman, skip
        addiu   a1, r0, 0x007F              // places cruel multiman music ID into argument
        addiu   a1, r0, HRC_ID              // HRC check placed in
        beq     t6, a1, _cruel_multiman     // if HRC, use Targets!
        addiu   a1, r0, 0x008E              // a1 = Targets! BGM ID
        addiu   a1, r0, REMIX_1P_ID         // Remix 1p Mode Check in
        bne     a1, t6, _normal             // take normal route if not Remix 1p

        li      t6, STAGE_FLAG              // load from current progress of 1p ID
        lb      t6, 0x0000(t6)              // load current progress in 1p
        addiu   a1, r0, 0x000D              // Final Stage ID entered
        beq     t6, a1, _cruel_multiman
        addiu   a1, r0, 0x004D              // insert Ultimate Bowser

        addiu   a1, r0, 0x000A              // Final Stage ID entered
        bne     a1, t6, _normal             // if not Mad Piano/Super Sonic Stage, do as normal
        nop
        li      t6, Global.match_info       // load match info pointer
        lw      t6, 0x0000(t6)              // load address
        lbu     t6, 0x0001(t6)              // load stage
        ori     a1, r0, Stages.id.CASINO
        beql    t6, a1, _super_sonic
        addiu   a1, r0, {MIDI.id.OPEN_YOUR_HEART}  // insert Open Your Heart
        ori     a1, r0, Stages.id.GHZ
        beql    t6, a1, _super_sonic
        addiu   a1, r0, {MIDI.id.OPEN_YOUR_HEART}  // insert Open Your Heart
        ori     a1, r0, Stages.id.MMADNESS
        beql    t6, a1, _super_sonic
        addiu   a1, r0, {MIDI.id.OPEN_YOUR_HEART}  // insert Open Your Heart

        beq     r0, r0, _normal             // if Mad Piano Stage, do as normal
        nop

        _super_sonic:
        addiu   sp, sp, -0x20
        sw      at, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      v0, 0x000C(sp)
        sw      v1, 0x0010(sp)
        jal     Global.get_random_int_      // random number to determine which song
        addiu   a0, r0, 0x0003              // 3 potential songs
        addiu   at, r0, 0x0002
        beql    v0, at, _restore            // if 2, play Everything
        addiu   a1, r0, {MIDI.id.EVERYTHING} // insert Live and Learn ID
        beqzl   v0, _restore                // if 0, then use Live and Learn
        addiu   a1, r0, {MIDI.id.LIVE_AND_LEARN} // insert Live and Learn ID

        beq     r0, r0, _restore            // if get 1, then use Open Your Heart
        nop

        _multiman:
        addiu   sp, sp, -0x20
        sw      at, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      v0, 0x000C(sp)
        sw      v1, 0x0010(sp)
        jal     Global.get_random_int_      // random number to determine which song
        addiu   a0, r0, 0x0002              // 2 potential songs
        beqzl   v0, _restore                // if get 1, then use normal multiman
        addiu   a1, r0, {MIDI.id.MULTIMAN2} // insert multiman 2 ID

        _restore:
        lw      at, 0x0004(sp)
        lw      a0, 0x0008(sp)
        lw      v0, 0x000C(sp)
        lw      v1, 0x0010(sp)
        addiu   sp, sp, 0x20

        _cruel_multiman:
        lui       t6, 0x8013
        lw        t6, 0x1300(t6)            // t6 = stage header info
        sw        a1, 0x007C(t6)            // update stage bgm_id

        _normal:
        jal        0x800FC3E8
        nop
        j       _return                     // return
        nop
    }

    // @ Description
    // Skips a c flag function which starts new music at end of traffic light
    scope skip_cflag_music_function_2: {
        OS.patch_start(0x10B9C0, 0x8018D160)
        j       skip_cflag_music_function_2
        addiu    at, r0, MULTIMAN_ID             // multiman mode check placed in
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag       // v0 = singleplayer mode flag
        lw      t6, 0x0000(t6)                   // v0 = 2 if multiman
        beq     t6, at, _multiman                // if multiman, skip
        addiu   at, r0, CRUEL_ID                 // cruel multiman mode check placed in
        beq     t6, at, _multiman                // if cruel multiman, skip
        addiu   at, r0, HRC_ID                   // HRC check placed in
        beq     t6, at, _multiman                // if HRC, skip
        addiu   at, r0, REMIX_1P_ID              // Remix 1p check placed in

        bne     t6, at, _normal                  // if not remix 1p, do the normal things
        addiu   at, r0, 0x000A                   // stage A = Mad Piano

        lui     t6, 0x800A                       //
        lbu     t6, 0x4AE7(t6)                   // load current progress

        beq     at, t6, _multiman                // if at Piano/ Super Sonic, skip routine
        nop

        _normal:
        lui        v0, 0x800A                    // original line 1
        j        _return
        lbu        v0, 0x4AE7(v0)                // original line 2

        _multiman:
        j       _return                          // return
        addiu    v0, r0, r0
    }

    // @ Description
    // loads in the amount of stocks for multiman mode
    scope load_player_stocks: {
    OS.patch_start(0x520C4, 0x800D68C4)
        j        load_player_stocks
        sb        r0, 0x002C(a0)            // original line 2
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)

        li      t1, singleplayer_mode_flag  // t1 = singleplayer mode flag
        lw      t1, 0x0000(t1)              // t1 = 1 if multiman
        addiu   t2, r0, REMIX_1P_ID
        beq     t2, t1, _1p
        addiu   t2, r0, ALLSTAR_ID
        beq     t2, t1, _1p
        nop
        bnez    t1, _multiman               // if multiman, skip
        nop



        _1p:
        lw      t1, 0x0004(sp)              // load t1
        lw      t2, 0x0008(sp)              // load t2
        addiu   sp, sp, 0x0010              // deallocate stack space

        j        _return
        lbu      t9, 0x493B(t9)           // original line 2



        _multiman:
        lw      t1, 0x0004(sp)              // load t1
        lw      t2, 0x0008(sp)              // load t2
        addiu   sp, sp, 0x0010              // deallocate stack space
        j        _return
        addiu    t9, r0, 0x0000             // set stock amount to 1
    }

    // @ Description
    // loads in diffuculty of a 1p based mode
    scope load_1p_difficulty_1: {
    OS.patch_start(0x10BD54, 0x8018D4F4)
        j        load_1p_difficulty_1
        addiu    t8, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag  // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 2 if multiman
        beq     t6, t8, _bonus3             // if bonus 3, skip
        addiu    t8, r0, MULTIMAN_ID

        beq     t6, t8, _multiman           // if multiman, skip
        addiu    t8, r0, CRUEL_ID
        beq     t6, t8, _cruel              // if cruel multiman, skip
        lui        t8, 0x8013               // original line 2

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

        li      t6, singleplayer_mode_flag       // t6 = singleplayer mode flag
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
    // Opponent CPU Level difficulty level
    scope _opponent_cpu: {
    OS.patch_start(0x10BD64, 0x8018D504)
        j        _opponent_cpu
        addiu    t1, r0, BONUS3_ID
        _return:
        OS.patch_end()

        li      v0, singleplayer_mode_flag  // v0 = singleplayer mode flag
        lw      v0, 0x0000(v0)              // v0 = 1 if multiman
        beq     v0, t1, _level9             // if bonus3, skip
        addiu   t1, r0, MULTIMAN_ID
        beq     v0, t1, _multiman           // if multiman, skip
        addiu   t1, r0, CRUEL_ID
        beq     v0, t1, _level9             // if cruel multiman, skip
        lui     t1, 0x800A                  // original line 2

        j       _return
        lbu     v0, 0x0002(t7)              // original line 1

        _multiman:
        lui      t1, 0x800A                 // original line 2
        j        _return
        addiu    v0, r0, 0x0004             // set opponent cpu to what it is on normal

        _level9:
        lui        t1, 0x800A               // original line 2
        j        _return
        addiu    v0, r0, 0x0009             // set opponent cpu to max
        }

    // @ Description
    // Prevents strange crash from happening when over 30 KOs are reached.
    scope crash_prevent: {
        OS.patch_start(0x10D938, 0x8018F0D8)
        j       crash_prevent
        nop
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag       // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 1 if multiman
        addiu   t5, r0, REMIX_1P_ID
        beq     t6, t5, _1p
        addiu   t5, r0, ALLSTAR_ID
        beq     t6, t5, _1p
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

        li      v0, singleplayer_mode_flag       // v0 = singleplayer mode flag
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

        li      t8, singleplayer_mode_flag      // t8 = singleplayer mode flag
        lw      t8, 0x0000(t8)                  // t8 = 2 if multiman
        beq     t8, t9, _multiman               // if multiman, skip
        addiu   t9, r0, CRUEL_ID
        beq     t8, t9, _multiman               // if cruel multiman, skip
        nop

        beq        t7, r0, _branch              // modified original line 1
        nop                                     // original line 2
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

        li          t5, singleplayer_mode_flag      // t5 = singleplayer mode flag
        lw          t5, 0x0000(t5)                  // t5 = 1 if multiman
        beq         t5, v0, _multiman               // if multiman, skip
        addiu       v0, r0, CRUEL_ID
        bne         t5, v0, _normal                 // if multiman, skip
        nop

        _multiman:
        addiu       sp, sp,-0x0010                  // allocate stack space
        sw          a0, 0x0004(sp)                  // save registers
        sw          t6, 0x0008(sp)                  // save registers
        sw          t0, 0x000C(sp)                  // save registers

        jal         Global.get_random_int_
        addiu       a0, r0, 0x000C

        addiu       t4, v0, 0x000E
        lw          a0, 0x0004(sp)                  // load registers
        lw          t6, 0x0008(sp)                  // load registers
        lw          t0, 0x000C(sp)                  // load registers
        addiu       sp, sp, 0x0010                  // deallocate stack space

        _normal:
        addu        t5, t6, t0                      // original line 1

        j           _return
        lui         v0, 0x8019                      // original line 2
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

        li      t0, singleplayer_mode_flag       // t0 = singleplayer mode flag
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
        sw      t0, 0x0008(sp)
        sw      t1, 0x000C(sp)
        addiu   t0, r0, BONUS3_ID
        li      t1, singleplayer_mode_flag  // t1 = singleplayer mode flag
        lw      t1, 0x0000(t1)              // t1 = 1 if Bonus 2
        beq     t1, t0, _finish             // if Bonus 3, skip
        addiu   t0, r0, REMIX_1P_ID
        beq     t1, t0, _finish             // if Remix 1p, skip
        addiu   t0, r0, ALLSTAR_ID
        beq     t1, t0, _allstar            // if Allstar, skip
        nop

        Render.load_font()                                        // load font for strings
        Render.load_file(0x19, Render.file_pointer_1)             // load button images into file_pointer_1

        li      t1, singleplayer_mode_flag
        lw      t1, 0x0000(t1)              // t1 = singleplayer mode flag
        lli     t0, HRC_ID                  // t0 = HRC ID
        beq     t1, t0, _hrc                // if HRC, skip
        nop

        // draw icons
        Render.draw_texture_at_offset(0x17, 0x0B, Render.file_pointer_1, 0x80, Render.NOOP, 0x41f00000, 0x41a00000, 0x848484FF, 0x303030FF, 0x3F800000)            // renders polygon stock icon
        Render.draw_texture_at_offset(0x17, 0x0B, 0x80130D50, 0x828, Render.NOOP, 0x421C0000, 0x41900000, 0x848484FF, 0x303030FF, 0x3F800000)            // renders X
        Render.draw_number(0x17, 0x0B, KO_AMOUNT_POINTER, Render.update_live_string_, 0x42480000, 0x41900000, 0xFFFFFFFF, 0x3f666666, Render.alignment.LEFT)    // renders counter

        b       _finish
        nop

        _hrc:
        li      at, HRC.distance
        sw      r0, 0x0000(at)                    // initialize distance to 0
        li      at, HRC.warp_distance
        sw      r0, 0x0000(at)                    // initialize warp distance to 0
        lli     t0, HRC.COMPLETE_TIMER_START
        li      at, HRC.complete_timer
        sw      t0, 0x0000(at)                    // initialize complete timer

        lui     at, 0x8004
        lw      at, 0x6800(at)                    // at = background image object
        li      t0, HRC.CLOUD_START               // t0 = initial X position
        sw      t0, 0x0040(at)                    // save X position in object
        sw      r0, 0x0044(at)                    // initialize scoll speed
        li      t0, 0x400EF007                    // t0 = original X scale doubled = 2.2334
        sw      t0, 0x0048(at)                    // initialize X scale

        // Spawn bat
        li      a1, HRC.BAT_SPAWN                 // left side of platform
        lui     a2, 0x4380                        // slightly above plat
        lli     a0, Hazards.standard.HOME_RUN_BAT // HOME_RUN_BAT
        lli     a3, Stages.id.DREAM_LAND          // original stage ID
        lli     t1, 0x0000                        // no routine
        jal     Hazards.add_item_
        lli     t0, 0x0000                        // no hover effect

        // Draw distance counter and label
        constant DISTANCE(HRC.distance)
        Render.draw_number(0x17, 0x0B, DISTANCE,    Render.update_live_string_, 0x438B0000, 0x42300000, 0xFFFFFFFF, 0x3F666666, Render.alignment.RIGHT, OS.TRUE, 1) // renders counter
        li      at, HRC.counter_string
        sw      v0, 0x0000(at)                    // save reference
        sw      at, 0x0054(v0)                    // save object reference address in object
        Render.draw_string(0x17, 0x0B, string_feet, Render.update_live_string_, 0x438D0000, 0x423C0000, 0xFFFFFFFF, 0x3F200000, Render.alignment.LEFT)
        li      at, HRC.metric_string
        sw      v0, 0x0000(at)                    // save reference
        sw      at, 0x0054(v0)                    // save object reference address in object

        Render.register_routine(HRC.main_)
        sw      r0, 0x0040(v0)                    // clear animaiton X speed
        jal     HRC.initialize_signs_
        or      a0, v0, r0                        // a0 = HRC main object

        b       _finish
        nop

        string_feet:; String.insert("FT.")

        _allstar:
        jal     BGM.setup_
        nop

        _finish:
        jal     InputDisplay.setup_
        nop

        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)
        lw      t1, 0x000C(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

    }

    //  REMIX 1P

    // @ Description
    // Settings that replace normally loaded hard codes used in Standard Remix 1p

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

    //  Tiny Team
    dw  0x01030103
    dw  0x04060909
    dw  0x09090909
    dw  0x01010101
    dw  0x01090909
    dh  0x0909

    //  Mad Piano // Super Sonic
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

    // Tiny Team
    dw  0xFF070000
    dw  0xFFFFFFFF
    dw  0x03090903
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
    dw  0x00000000                      // flag
    db  Character.id.DRM                // Character ID
    db  Stages.id.DR_MARIO              // Stage Option 1
    db  Stages.id.DR_MARIO              // Stage Option 2
    db  Stages.id.DR_MARIO              // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    // Ganondorf match settings
    dw  0x00000000                      // flag
    db  Character.id.GND                // Character ID
    db  Stages.id.GANONS_TOWER          // Stage Option 1
    db  Stages.id.GANONS_TOWER          // Stage Option 2
    db  Stages.id.GANONS_TOWER          // Stage Option 3
    dw  SinglePlayer.name_texture.GND + 0x10    // name texture
    dw  0x000002C5                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x000159C0                      // Progress Icon

    // Young Link match settings
    dw  0x00000000                      // flag
    db  Character.id.YLINK              // Character ID
    db  Stages.id.DEKU_TREE             // Stage Option 1
    db  Stages.id.TALTAL                // Stage Option 2
    db  Stages.id.GREAT_BAY             // Stage Option 3
    dw  SinglePlayer.name_texture.YLINK + 0x10    // name texture
    dw  0x000002E5                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015880                      // Progress Icon

    // Wolf match settings
    dw  0x00000000                      // flag
    db  Character.id.WOLF               // Character ID
    db  Stages.id.CORNERIA2             // Stage Option 1
    db  Stages.id.VENOM                 // Stage Option 2
    db  Stages.id.CORNERIACITY          // Stage Option 3
    dw  SinglePlayer.name_texture.WOLF + 0x10    // name texture
    dw  0x000003AA                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015740                      // Progress Icon

    // Wario match settings
    dw  0x00000000                      // flag
    db  Character.id.WARIO              // Character ID
    db  Stages.id.WARIOWARE             // Stage Option 1
    db  Stages.id.MUDA                  // Stage Option 2
    db  Stages.id.KITCHEN               // Stage Option 3
    dw  SinglePlayer.name_texture.WARIO + 0x10    // name texture
    dw  0x00000304                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015600                      // Progress Icon

    // Dark Samus match settings
    dw  0x00000000                      // flag
    db  Character.id.DSAMUS             // Character ID
    db  Stages.id.NORFAIR               // Stage Option 1
    db  Stages.id.ZLANDING              // Stage Option 2
    db  Stages.id.NORFAIR               // Stage Option 3
    dw  SinglePlayer.name_texture.DSAMUS + 0x10    // name texture
    dw  0x000002EC                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015100                      // Progress Icon

    // Bowser match settings
    dw  0x00000000                        // flag
    db  Character.id.BOWSER                // Character ID
    db  Stages.id.BOWSERS_KEEP            // Stage Option 1
    db  Stages.id.BOWSERB                // Stage Option 2
    db  Stages.id.BOWSERS_KEEP            // Stage Option 3
    dw  SinglePlayer.name_texture.BOWSER + 0x10    // name texture
    dw  0x00000372                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014D40                      // Progress Icon

    // Lucas match settings
    dw  0x00000000                      // flag
    db  Character.id.LUCAS              // Character ID
    db  Stages.id.ONETT                 // Stage Option 1
    db  Stages.id.NPC                   // Stage Option 2
    db  Stages.id.NPC                   // Stage Option 3
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

    // Mewtwo match settings
    dw  0x00000000                      // flag
    db  Character.id.MTWO               // Character ID
    db  Stages.id.POKEMON_STADIUM_2     // Stage Option 1
    db  Stages.id.KALOS_POKEMON_LEAGUE  // Stage Option 2
    db  Stages.id.SAFFRON_DL            // Stage Option 3
    dw  SinglePlayer.name_texture.MTWO + 0x10    // name texture
    dw  0x000003B0                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015C40                      // Progress Icon

    // Marth match settings
    dw  0x00000000                      // flag
    db  Character.id.MARTH              // Character ID
    db  Stages.id.CSIEGE                // Stage Option 1
    db  Stages.id.CSIEGE                // Stage Option 2
    db  Stages.id.CSIEGE                // Stage Option 3
    dw  SinglePlayer.name_texture.MARTH + 0x10    // name texture
    dw  0x00000360                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015D80                      // Progress Icon

    // Sonic match settings
    dw  0x00000000                      // flag
    db  Character.id.SONIC              // Character ID
    db  Stages.id.GHZ                   // Stage Option 1
    db  Stages.id.CASINO                // Stage Option 2
    db  Stages.id.MMADNESS              // Stage Option 3
    dw  SinglePlayer.name_texture.SONIC + 0x10    // name texture
    dw  0x000003D4                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00015EC0                      // Progress Icon

    // Sheik match settings
    dw  0x00000000                      // flag
    db  Character.id.SHEIK              // Character ID
    db  Stages.id.GERUDO                // Stage Option 1
    db  Stages.id.GERUDO                // Stage Option 2
    db  Stages.id.GERUDO                // Stage Option 3
    dw  SinglePlayer.name_texture.SHEIK + 0x10    // name texture
    dw  0x00000409                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00016140                      // Progress Icon

    // Marina match settings
    dw  0x00000000                      // flag
    db  Character.id.MARINA             // Character ID
    db  Stages.id.CLANCER               // Stage Option 1
    db  Stages.id.CLANCER               // Stage Option 2
    db  Stages.id.CLANCER               // Stage Option 3
    dw  SinglePlayer.name_texture.MARINA + 0x10    // name texture
    dw  0x0000041F                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00016280                      // Progress Icon

    // Dedede match settings
    dw  0x00000000                      // flag
    db  Character.id.DEDEDE             // Character ID
    db  Stages.id.MT_DEDEDE             // Stage Option 1
    db  Stages.id.MT_DEDEDE             // Stage Option 2
    db  Stages.id.MT_DEDEDE             // Stage Option 3
    dw  SinglePlayer.name_texture.DEDEDE + 0x10    // name texture
    dw  0x00000451                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x000163C0                      // Progress Icon

    // Add entry here if a new variant.type.NA character is added UPDATE

    // ALLSTAR ONLY

    //  Mario match settings
    dw  0x00000000                      // flag
    db  Character.id.MARIO              // Character ID
    db  Stages.id.MUDA                  // Stage Option 1
    db  Stages.id.GOOMBA_ROAD           // Stage Option 2
    db  Stages.id.GOOMBA_ROAD           // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Fox match settings
    dw  0x00000000                      // flag
    db  Character.id.FOX                // Character ID
    db  Stages.id.CORNERIACITY          // Stage Option 1
    db  Stages.id.VENOM                 // Stage Option 2
    db  Stages.id.CORNERIA2             // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Donkey Kong match settings
    dw  0x00000000                      // flag
    db  Character.id.DK                 // Character ID
    db  Stages.id.FALLS                 // Stage Option 1
    db  Stages.id.FALLS                 // Stage Option 2
    db  Stages.id.FALLS                 // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Samus match settings
    dw  0x00000000                      // flag
    db  Character.id.SAMUS              // Character ID
    db  Stages.id.ZLANDING              // Stage Option 1
    db  Stages.id.ZLANDING              // Stage Option 2
    db  Stages.id.NORFAIR               // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Luigi match settings
    dw  0x00000000                      // flag
    db  Character.id.LUIGI              // Character ID
    db  Stages.id.PEACH2                // Stage Option 1
    db  Stages.id.SUBCON                // Stage Option 2
    db  Stages.id.SUBCON                // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Link match settings
    dw  0x00000000                      // flag
    db  Character.id.LINK               // Character ID
    db  Stages.id.DEKU_TREE             // Stage Option 1
    db  Stages.id.TALTAL                // Stage Option 2
    db  Stages.id.GREAT_BAY             // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Yoshi match settings
    dw  0x00000000                      // flag
    db  Character.id.YOSHI              // Character ID
    db  Stages.id.YOSHI_STORY_2         // Stage Option 1
    db  Stages.id.YOSHI_STORY_2         // Stage Option 2
    db  Stages.id.YOSHIS_ISLAND_II      // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Captain Falcon match settings
    dw  0x00000000                      // flag
    db  Character.id.CAPTAIN            // Character ID
    db  Stages.id.MUTE                  // Stage Option 1
    db  Stages.id.MUTE                  // Stage Option 2
    db  Stages.id.MUTE                  // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Kirby match settings
    dw  0x00000000                      // flag
    db  Character.id.KIRBY              // Character ID
    db  Stages.id.DREAM_LAND            // Stage Option 1
    db  Stages.id.FOD                   // Stage Option 2
    db  Stages.id.FOD                   // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Pikachu match settings
    dw  0x00000000                      // flag
    db  Character.id.PIKACHU            // Character ID
    db  Stages.id.POKEMON_STADIUM_2     // Stage Option 1
    db  Stages.id.KALOS_POKEMON_LEAGUE  // Stage Option 2
    db  Stages.id.SAFFRON_DL            // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Jigglypuff match settings
    dw  0x00000000                      // flag
    db  Character.id.JIGGLYPUFF         // Character ID
    db  Stages.id.POKEMON_STADIUM_2     // Stage Option 1
    db  Stages.id.KALOS_POKEMON_LEAGUE  // Stage Option 2
    db  Stages.id.SAFFRON_DL     // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Ness match settings
    dw  0x00000000                      // flag
    db  Character.id.NESS               // Character ID
    db  Stages.id.ONETT                 // Stage Option 1
    db  Stages.id.ONETT                 // Stage Option 2
    db  Stages.id.NPC                   // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

    //  Falco match settings
    dw  0x00000000                      // flag
    db  Character.id.FALCO              // Character ID
    db  Stages.id.CORNERIACITY          // Stage Option 1
    db  Stages.id.VENOM                 // Stage Option 2
    db  Stages.id.CORNERIA2             // Stage Option 3
    dw  SinglePlayer.name_texture.DRM + 0x10    // name texture
    dw  0x000002E6                      // Announcer Call
    dw  0x00006F80                      // Model Scale
    dw  0x00014FC0                      // Progress Icon

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
    dw  0x00007B00          // Tiny Team
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
        li      at, singleplayer_mode_flag  // at = singleplayer mode flag
        lw      at, 0x0000(at)              // at = 4 if Remix 1p
        addiu   t2, r0, ALLSTAR_ID
        bne     at, t2, _remix              // if not Remix 1p, skip
        nop
        jal     SinglePlayerModes.allstar_randomization
        nop
        beq     r0, r0, _normal
        nop
        _remix:
        addiu   t2, r0, REMIX_1P_ID
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

        li      t9, remix_kirby_pool        // load pool address
        li      t7, remix_kirby_hat_pointer // hat pointer
        li      t2, remix_kirby_pointer

        addiu   t4, r0, 0x0007              // total slots
        addiu   t1, r0, 0x000C              // size of each hat slot
        addiu   t8, r0, 0x0001              // for flags

        kirby_loop:
        jal     Global.get_random_int_      // generate number based on total number of character pool
        addiu   a0, r0, NUM_REMIX_HATS      // place current number of kirby power pool in a0
        multu   t1, v0                      // multiply output by slot size
        mflo    t0                          // total offset for character
        addu    t0, t9, t0                  // add to pool address
        lw      t5, 0x0008(t0)              // load flag
        bnez    t5, kirby_loop              // branch to beginning of loop if character already used
        nop
        sw      t8, 0x0008(t0)              // save flag so character will not be used again
        lw      t3, 0x0000(t0)              // load power ID
        sb      t3, 0x0000(t2)              // save power slot
        lw      t3, 0x0004(t0)              // load hat ID
        sw      t3, 0x0000(t7)              // save hat ID
        addiu   t2, t2, 0x0001              // move to next slot
        addiu   t7, t7, 0x0004              // move to next slot
        bnezl   t4, kirby_loop              // continue loop until all slots filled
        addiu   t4, t4, -0x0001             // subtract from slots
        addiu   t4, r0, 0x0007              // total slots

        clear_kirby_loop:
        sw      r0, 0x0008(t9)              // clear flags
        addiu   t9, t9, 0x000C              // add to get new character slot
        bnezl   t4, clear_kirby_loop
        addiu   t4, t4, -0x0001             // subtract slot

        li      t9, MATCH_SETTINGS_PART1
        addiu   t0, r0, 0x0005              // slot countdown (currently six random slots to fill)
        addiu   t1, r0, 0x0018              // jump multiplier for match pool
        li      t5, match_pool              // load match pool address
        li      t7, match_slots             // load match slots address
        li      t2, title_card_1_struct

        _assignment_loop:
        jal     Global.get_random_int_     // generate number based on total number of character pool
        addiu   a0, r0, Character.NUM_REMIX_FIGHTERS - 1 // place current number of character pool in a0

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

        //_standard:
        lw      t4, 0x000C(t3)              // load name call of character
        //_unique:
        addiu   a0, r0, 0x0024              // Tiny Team Slot inserted
        beq     a0, v0, _tiny_skip          // check if on tiny team slot, if so, skip because always calls out tiny team
        nop
        li      a0, announcer_calls         // load announcer call
        addu    a0, a0, v0                  // get location of current character
        sw      t4, 0x0000(a0)              // save name call to correct location

        _tiny_skip:
        addiu   a0, r0, 0x0004              // Team Slot inserted
        beq     a0, v0, _team_skip          // check if on team slot, if so, skip scale because they all use the default scale
        nop

        //addiu   a0, r0, 0x0005              // Tiny Team slot inserted
        //beq     a0, v0, _team_skip          // check if on team slot, if so, skip scale because they all use the default scale
        //nop

        li      a0, model_scale             // load model scale
        addu    a0, a0, v0                  // get location of current character
        lw      t4, 0x0010(t3)              // load model scale of character
        sw      t4, 0x0000(a0)              // save model scale to correct location

        _team_skip:
        lbu     t4, 0x0004(t3)              // load character ID into t4

        // get stage ID
        _stage_id:
        jal     Global.get_random_int_      // generate number based on total number of stage pool for character
        addiu   a0, r0, 0x0003              // place current number of stage pool in a0
        addiu   v0, v0, 0x0001              // add 1 to output to account for character portion of word
        addu    t3, t3, v0                  // add v0 amount to get stage id
        lbu     t3, 0x0004(t3)              // load stage ID in t3
        ori     t6, r0, Stages.id.CORNERIA2 // place corneria in t6
        beql    t6, t3, _slot
        ori     t3, r0, Stages.id.VENOM     // change stage to Venom if Wolf gets Corneria

        // save settings
        _slot:
        sub     t8, t7, t0                  // work backwards from final slot by subtracting slot counter
        lbu     t8, 0x0000(t8)              // load additive amount for match settings slot
        addu    t8, t9, t8                  // place match settings slot address into t8

        sb      t3, 0x0001(t8)              // save stage ID to match settings slot
        sb      t4, 0x0009(t8)              // save character ID to match settings slot
        bne     t0, r0, _no_tiny            // check if tiny team stage
        nop
        sb      t4, 0x000A(t8)              // save character ID to match settings slot
        sb      t4, 0x000B(t8)              // save character ID to match settings slot

        _no_tiny:
        li      t6, title_slots
        sub     t8, t6, t0                  // work backwards from final slot by subtracting slot counter
        lbu     v0, 0x0000(t8)              // load slot
        addu    t8, t2, v0                  // add slot amount to title card pointer
        sw      t4, 0x0000(t8)              // save character ID to title card spot

        bnez    t0, _assignment_loop
        addiu   t0, t0, -0x0001

        addiu   t9, r0, 0x000F              // clear character flag, THIS NEEDS UPDATED WHEN CHARACTER ADDED OR MORE THINGS ADDED TO MATCH POOL
        _clear_loop:
        sw      r0, 0x0000(t5)
        addiu   t5, t5, 0x0018
        bnez    t9, _clear_loop
        addiu   t9, t9, 0xFFFF

        jal     Global.get_random_int_      // generate number based on total number of character pool
        addiu   a0, r0, 0x0002              // place current number of boss characters in

        beqz    v0, _mad_piano              // if 0, do mad piano
        nop

        li      t9, MATCH_SETTINGS_PART1
        addiu   t9, t9, 0xA0                // get to Boss character location
        ori     t0, r0, Character.id.SSONIC // place Super Sonic ID in t0
        sb      t0, 0x0009(t9)              // replace Mad Piano

        jal     Global.get_random_int_      // generate number based on total number of stages
        addiu   a0, r0, 0x0003              // place current number of stages in
        beqzl   v0, _ss_stage               // if 0, do Green Hill Zone
        ori     t1, r0, Stages.id.GHZ

        addiu   t1, r0, 0x0002

        beql    v0, t1, _ss_stage           // if 2, do Green Hill Zone
        ori     t1, r0, Stages.id.GHZ

        ori     t1, r0, Stages.id.CASINO    // if 1, do Casino Night Zone

        _ss_stage:
        sb      t1, 0x0001(t9)              // replace Mad Monster Mansion

        li      t9, progress_icon_struct
        li      t1, 0x00016000              // load alternate progess icon
        sw      t1, 0x0028(t9)              // replace mad piano icon

        li      t9, title_card_1_struct
        ori     t1, r0, Character.id.SSONIC // load SSONIC
        sw      t1, 0x0028(t9)              // replace mad piano title card

        li      t9, name_textures
        ori     t1, r0, SinglePlayer.name_texture.SSONIC + 0x10              // load alternate name texture
        sw      t1, 0x0028(t9)              // replace mad piano texture

        li      t9, announcer_calls         // load announcer call
        ori     t1, r0, 0x03FE              // load alternate announcement
        sw      t1, 0x0028(t9)              // replace mad piano announcement

        li      t9, model_scale             // load model scale
        ori     t1, r0, 0x6F80              // load alternate model scale
        sw      t1, 0x0028(t9)              // replace mad piano scale

        b       _normal
        nop

        _mad_piano:
        li      t9, MATCH_SETTINGS_PART1
        addiu   t9, t9, 0xA0                // get to Boss character location
        ori     t0, r0, Character.id.PIANO  // place Mad Piano ID in t0
        sb      t0, 0x0009(t9)              // set Mad Piano

        ori     t1, r0, Stages.id.MADMM
        sb      t1, 0x0001(t9)              // set Mad Monster Mansion

        li      t9, progress_icon_struct
        li      t1, 0x00015240              // load Piano progess icon
        sw      t1, 0x0028(t9)              // set mad piano icon

        li      t9, title_card_1_struct
        ori     t1, r0, Character.id.PIANO  // load PIANO
        sw      t1, 0x0028(t9)              // set mad piano title card

        li      t9, name_textures
        ori     t1, r0, SinglePlayer.name_texture.PIANO + 0x10              // load alternate name texture
        sw      t1, 0x0028(t9)              // set mad piano texture

        li      t9, announcer_calls         // load announcer call
        ori     t1, r0, 0x03C6              // load piano announcement
        sw      t1, 0x0028(t9)              // set mad piano announcement

        li      t9, model_scale             // load model scale
        ori     t1, r0, 0x7070              // load alternate model scale
        sw      t1, 0x0028(t9)              // set mad piano icon

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
    // Polygon Character ID in chronological order
    polygon_id_table:
    dw Character.id.NDRM                    // Polygon Dr. Mario
    dw Character.id.NWARIO                  // Polygon Wario
    dw Character.id.NLUCAS                  // Polygon Lucas
    dw Character.id.NBOWSER                 // Polygon Bowser
    dw Character.id.NWOLF                   // Polygon Wolf
    dw Character.id.NSONIC                  // Polygon Sonic
    dw Character.id.NSHEIK                  // Polygon Sheik
    dw Character.id.NMARINA                 // Polygon Marina

    // @ Description
    // Changes polygon match selection to be Remix Polygons
    scope polygon_selection_match: {
        OS.patch_start(0x10C510, 0x8018DCB0)
        j       polygon_selection_match
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // save registers
        sw      a0, 0x000C(sp)              // save registers
        sw      v0, 0x0010(sp)              // save registers
        sw      t6, 0x0014(sp)              // save registers
        sw      at, 0x0018(sp)              // save registers
        sw      ra, 0x001C(sp)              // save registers

        addiu   t1, r0, REMIX_1P_ID         // Remix ID
        li      t0, singleplayer_mode_flag  // t0 = singleplayer mode flag
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p
        bnel    t0, t1, _end                // if not Remix 1p, skip
        addiu   t7, v1, 0x000E              // original line 1

        jal     Global.get_random_int_      // generate number based on total number of character pool
        addiu   a0, r0, Character.NUM_POLYGONS // place current number of boss characers in

        sll     v0, v0, 0x0002              // multiply by 4 for table
        li      t0, polygon_id_table        // load polygon ID table
        addu    t0, v0, t0                  // address of polygon ID
        lw      t7, 0x0000(t0)              // load Remix 1p Polygon ID

        _end:
        lw      t0, 0x0004(sp)              // load registers
        lw      t1, 0x0008(sp)              // load registers
        lw      a0, 0x000C(sp)              // load registers
        lw      v0, 0x0010(sp)              // load registers
        lw      t6, 0x0014(sp)              // load registers
        lw      at, 0x0018(sp)              // load registers
        lw      ra, 0x001C(sp)              // load registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        j        _return
        andi    s2, s2, 0xFFFF              // original line 2
        }

    // @ Description
    // Changes polygon file loading to be Remix Polygons
    scope polygon_file_loading: {
        OS.patch_start(0x10E21C, 0x8018F9BC)
        j       polygon_file_loading
        addiu   t6, r0, REMIX_1P_ID         // Remix ID
        _return:
        OS.patch_end()

        li      a0, singleplayer_mode_flag  // a0 = singleplayer mode flag
        lw      a0, 0x0000(a0)              // a0 = 4 if Remix 1p
        bnel    a0, t6, _normal             // if not Remix 1p, skip
        or      a0, s1, r0                  // original line 2

        addiu   sp, sp, -0x0010             // allocate stack space
        addiu   t7, r0, (Character.NUM_POLYGONS - 1)

        _remix_loop:

        sll     t8, t7, 0x0002              // id multiplied by 4
        li      t6, polygon_id_table        // load polygon ID table
        addu    a0, t8, t6                  // address of polygon ID
        lw      a0, 0x0000(a0)              // load ID

        jal     0x800D786C                  // original line 1, load character file routine
        sw      t7, 0x0004(sp)              // save to stack space

        lw      t7, 0x0004(sp)              // save to stack space

        bnez    t7, _remix_loop
        addiu   t7, t7, 0xFFFF              // next polygon ID

        addiu   sp, sp, 0x0010              // deallocate stack space

        j       0x8018F9D4                  // skip original code
        nop

        _normal:
        jal     0x800D786C                  // original line 1, load character file routine
        nop
        j        _return
        nop
    }


    // @ Description
    // Changes polygon file loading to be Remix Polygons
    scope polygon_allocation: {
        OS.patch_start(0x10E234, 0x8018F9D4)
        j       polygon_allocation
        addiu   v0, r0, REMIX_1P_ID         // Remix ID
        _return:
        OS.patch_end()

        li      a1, singleplayer_mode_flag  // a0 = singleplayer mode flag
        lw      a1, 0x0000(a1)              // a0 = 4 if Remix 1p
        bne     a1, v0, _normal             // if not Remix 1p, skip
        nop

        addiu   t7, r0, (Character.NUM_POLYGONS - 1)
        li      t6, polygon_id_table        // load polygon ID table
        li      v0, 0x80116E10              // character struct hardcoded location
        or      a1, r0, r0                  // clear a1

        _character_loop:
        sll     t8, t7, 0x0002              // count multiplied by 4 to get offset
        addu    a0, t8, t6                  // get address of polygon ID
        lw      a0, 0x0000(a0)              // load ID


        sll     at, a0, 0x0002              // times id by 4 to get offset
        addu    at, at, v0                  // address of polygon's character struct

        lw      at, 0x0000(at)              // load the character struct
        lw      v1, 0x0074(at)              // load allocation
        sltu    at, a1, v1                  // set at if new allocation is bigger

        beqzl   at, _branch_1               // if new amount is smaller, branch
        nop

        or      a1, v1, r0                  // set a1 to new largest allocation

        _branch_1:
        bnez    t7,_character_loop
        addiu   t7, t7, 0xFFFF              // next polygon ID

        addu    a0, a1, r0                  // set a0 to max allocation

        j       0x8018FA10                  // skip original code
        nop

        _normal:
        lui     v0, 0x8011                  // original line 1
        j        _return
        lui     a1, 0x8011                  // original line 2
    }


    // @ Description
    // Changes address used for character name text
    scope title_card_text_name: {
        OS.patch_start(0x12B834, 0x801324F4)
        j       title_card_text_name
        addiu    t6, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      t0, singleplayer_mode_flag       // t0 = singleplayer mode flag
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

        li      t1, singleplayer_mode_flag  // t0 = singleplayer mode flag
        lw      t1, 0x0000(t1)              // t0 = 4 if Remix 1p
        bne     t1, t6, _normal               // if not Remix 1p, skip
        nop

        beq     a2, at, _end                // do a normal character text load if at Pikachu Stage
        addiu   at, r0, 0x0006              // insert giant stage

        beq     a2, at, _giant              // take jump if giant stage
        addiu   at, r0, 0x0001              // insert team stage

        beq     a2, at, _team               // take jump if team stage
        addiu   at, r0, 0x0009              // insert Samus stage

        beq     a2, at, _tiny               // do a tiny team text load if at Samus Stage
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

        // Change Marina Liteyears to Marina
        lw      a2, 0x0068(sp)              // a2 = some sort of index for the character name texture
        sll     t6, a2, 0x0002              // t6 = offset
        addu    t8, sp, t6                  // t8 = stack position adjusted
        lw      t8, 0x0024(t8)              // t8 = name texture offset
        lli     t6, SinglePlayer.name_texture.MARINA + 0x10
        bne     t8, t6, _adjust_footer_team // if not Marina, skip
        lli     t6, 0x002A                  // t6 = width of "Marina"
        sh      t6, 0x0014(v0)              // set width

        _adjust_footer_team:
        lhu     t4, 0x0024(v0)
        andi    t0, t4, 0xFFDF
        addiu   v1, r0, 0x00FF
        sh      t0, 0x0024(v0)
        ori     t7, t0, 0x0001
        sh      t7, 0x0024(v0)
        sb      v1, 0x0028(v0)
        sb      v1, 0x0029(v0)
        sb      v1, 0x002A(v0)
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

        // Change Marina Liteyears to Marina
        lw      a2, 0x0068(sp)              // a2 = some sort of index for the character name texture
        sll     t6, a2, 0x0002              // t6 = offset
        addu    t8, sp, t6                  // t8 = stack position adjusted
        lw      t8, 0x0024(t8)              // t8 = name texture offset
        lli     t6, SinglePlayer.name_texture.MARINA + 0x10
        bne     t8, t6, _done_giant         // if not Marina, skip
        lli     t6, 0x002A                  // t6 = width of "Marina"
        sh      t6, 0x0014(v0)              // set width

        _done_giant:
        j       0x80132604
        addiu   v1, r0, 0x00FF

        _tiny:
        lw      t9, 0x0004(a3)
        lli     a1, 0x9548                  // a1 = "Tiny Team" offset
        addu    a1, a1, t9                  // a1 = Tiny Team image foooter
        jal     0x800CCFDC                  // load texture
        nop
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

        li      v0, singleplayer_mode_flag  // v0 = singleplayer mode flag
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
        lui     v0, 0x8004
        lw      v0, 0x501C(v0)              // load frame count into v0
        sw      v0, 0x0000(at)              // set flag to frame count as giant has been said

        _post_giant:
        jal     0x8000092C                  // routine which loads frame count into v0
        nop

        addiu   t3, r0, 0x002B              // set amount of frames between "GIANT" and CPU Name
        li      t4, _giant_flag
        lw      t4, 0x0000(t4)              // load frame count when giant was said
        addu    t4, t3, t4                  // add set frame count for giant announce and when giant was announced
        sltu    at, t4, v0                  // v0 contains total frame count, compare t4 to see if time to announce player name after giant

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
        li      v0, singleplayer_mode_flag  // v0 = singleplayer mode flag
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

        li      at, singleplayer_mode_flag  // v0 = singleplayer mode flag
        lw      at, 0x0000(at)              // v0 = 4 if Remix 1p
        bne     t8, at, _normal             // if not Remix 1p, skip
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
//     li      t0, singleplayer_mode_flag       // t0 = singleplayer mode flag
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

        li      t1, singleplayer_mode_flag       // t0 = singleplayer mode flag
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

        li      t0, singleplayer_mode_flag       // t0 = singleplayer mode flag
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

        li      t0, singleplayer_mode_flag       // t0 = singleplayer mode flag
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

        li      t0, singleplayer_mode_flag    // t0 = singleplayer mode flag
        lw      t0, 0x0000(t0)                // t0 = 4 if Remix 1p
        bne     t0, t9, _normal               // if not Remix 1p, skip
        or      s0, a0, r0                    // original line 2

        li        t6, title_card_1_struct
        j       _return
        nop

        _normal:
        j        _return
        addiu   t6, t6, 0x5B00                // original line 1
        }

    // @ Description
    // Changes pointer to part1 pointer which establishes the stage settings of 1p for Remix 1p and Allstar
    scope remix_1p_pointer_part1: {
        OS.patch_start(0x10BE90, 0x8018D630)
        j       remix_1p_pointer_part1
        addiu    t7, t7, 0x29BC                // original line 1
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag    // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)                // t6 = 4 if Remix 1p
        addiu   s7, r0, REMIX_1P_ID

        beq     t6, s7, _remix_1p             // if Remix 1p, branch
        addiu   s7, r0, ALLSTAR_ID

        bne     t6, s7, _normal               // if not Remix 1p or Allstar, skip
        nop

        li      t7, ALLSTAR_MATCH_SETTINGS_PART1
        beq     r0, r0, _normal             // jump to end
        nop

        _remix_1p:
        li      t7, MATCH_SETTINGS_PART1

        _normal:
        j        _return
        sll     t6, v0, 0x4                    // original line 2
        }

    // @ Description
    // Changes pointer to part2 pointer which establishes the stage settings of 1p for Remix 1p
    scope remix_1p_pointer_part2: {
        OS.patch_start(0x10BEE0, 0x8018D680)
        j       remix_1p_pointer_part2
        addiu    t9, t9, 0x2830               // original line 1
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag    // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)                // t6 = 4 if Remix 1p
        addiu   t3, r0, REMIX_1P_ID
        beq     t6, t3, _remix_1p             // if Remix 1p, branch
        addiu   t3, r0, ALLSTAR_ID

        bne     t6, t3, _normal               // if not Allstar or Remix, skip
        nop
        li      t9, ALLSTAR_MATCH_SETTINGS_PART2      // load address of Remix Match Settings Part 2
        beq     r0, r0, _normal               // Jump to End
        nop

        _remix_1p:
        li      t9, MATCH_SETTINGS_PART2      // load address of Remix Match Settings Part 2


        _normal:
        j        _return
        sb      t4, 0x0001(t5)                // original line 2
        }

    // @ Description
    // Changes pointer in which progess icons are pulled from to the Remix versions
    scope remix_icon_pointer: {
        OS.patch_start(0x12B518, 0x801321D8)
        j       remix_icon_pointer
        addiu    s0, r0, REMIX_1P_ID            // Remix ID put into s0
        _return:
        OS.patch_end()

        li      s6, singleplayer_mode_flag       // s6 = singleplayer mode flag
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

        li      t7, singleplayer_mode_flag  // t7 = singleplayer mode flag
        lw      t7, 0x0000(t7)              // t7 = 4 if Remix 1p
        bne     t7, v0, _normal             // if not Remix 1p, skip
        nop

        li      t7, Size.state_table
        sll     v0, a2, 0x0002              // v0 = offset to size state (port already in a2)
        addu    t4, v0, t7                  // t4 = address of size state

        li      v0, 0x800A4AD0              // load hardcoded address that has current stage
        lbu     v0, 0x0017(v0)              // load current stage
        addiu   t7, r0, 0x0006              // check for giant stage
        beq     t7, v0, _giant              // jump if giant stage
        addiu   t7, r0, 0x0009              // check for tiny stage
        bne     t7, v0, _other              // jump if neither
        nop

        lli     v0, Size.state.TINY         // v0 = tiny state
        b       _normal                     // jump to original lines
        sw      v0, 0x0000(t4)              // save size state to make character tiny

        _giant:
        lli     v0, Size.state.GIANT        // v0 = giant state
        b       _normal                     // jump to original lines
        sw      v0, 0x0000(t4)              // save size state to make character a giant

        _other:
        li      t7, Size.state_table
        sw      r0, 0x0000(t7)              // reset size state to normal
        sw      r0, 0x0004(t7)              // reset size state to normal
        sw      r0, 0x0008(t7)              // reset size state to normal
        sw      r0, 0x000C(t7)              // reset size state to normal

        _normal:
        addu    v0, t9, t5                  // original line 1
        j       _return
        addiu   t7, s3, 0x0025              // original line 2
    }

    // @ Description
    // Remix Kirby Pool
     OS.align(16)
     remix_kirby_pool:

     dw     0x0000001E      // Ganon ID
     dw     0x00000011      // Ganon Hat ID
     dw     0x00000000      // Flag

     dw     0x0000001F      // Young Link ID
     dw     0x0000000A      // Young Link Hat ID
     dw     0x00000000      // Flag

     dw     0x0000001D      // Falco ID
     dw     0x00000012      // Falco Hat ID
     dw     0x00000000      // Flag

     dw     0x00000020      // Doctor Mario ID
     dw     0x00000010      // Doctor Mario Hat ID
     dw     0x00000000      // Flag

     dw     0x00000022      // Dark Samus ID
     dw     0x00000013      // Dark Samus Hat ID
     dw     0x00000000      // Flag

     dw     0x00000021      // Wario ID
     dw     0x0000000F      // Wario Hat ID
     dw     0x00000000      // Flag

     dw     0x00000026      // Lucas ID
     dw     0x00000014      // Lucas Hat ID
     dw     0x00000000      // Flag

     dw     0x00000034      // Bowser ID
     dw     0x00000015      // Bowser Hat ID
     dw     0x00000000      // Flag

     dw     0x00000037      // Conker ID
     dw     0x00000019      // Conker Hat ID
     dw     0x00000000      // Flag

     dw     0x00000038      // Wolf ID
     dw     0x0000001A      // Wolf Hat ID
     dw     0x00000000      // Flag

     dw     0x00000039      // Mewtwo ID
     dw     0x0000001B      // Mewtwo Hat ID
     dw     0x00000000      // Flag

     dw     0x0000003A      // Marth ID
     dw     0x0000001C      // Marth Hat ID
     dw     0x00000000      // Flag

     dw     0x0000003B      // Sonic ID
     dw     0x0000001D      // Sonic Hat ID
     dw     0x00000000      // Flag

     dw     0x0000003E      // Sheik ID
     dw     0x0000001E      // Sheik Hat ID
     dw     0x00000000      // Flag

     dw     0x0000003F      // Marina ID
     dw     0x0000001F      // Marina Hat ID
     dw     0x00000000      // Flag

     dw     0x00000040      // Dedede ID
     dw     0x00000020      // Dedede Hat ID
     dw     0x00000000      // Flag

     constant NUM_REMIX_HATS(0x10) // UPDATE if adding a hat
     OS.align(16)

    // @ Description
    // remix kirby order which replaces hardcoded location for original Kirby power in match
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
    // remix kirby order which replaces hardcoded location for original Kirby hats in CSS
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

        li      s3, singleplayer_mode_flag  // s3 = singleplayer mode flag
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
        addiu   t8, r0, ALLSTAR_ID         // insert Remix 1p ID
        _return:
        OS.patch_end()

        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        beq     at, t8, _shade
        addiu   t8, r0, REMIX_1P_ID         // insert Remix 1p ID
        bne     t8, at, _normal             // if not Remix 1p, skip
        nop
        _shade:
        addiu   t6, r0, 0x0001              // insert 0x1 into register
        li      t8, end_game_flag           // load end game flag address
        sw      t6, 0x0000(t8)              // allow game to be able to be ended
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
        addiu   t9, r0, ALLSTAR_ID         // insert Allstar 1p ID
        _return:
        OS.patch_end()


        li      at, singleplayer_mode_flag  // at = singleplayer flag address
        lw      at, 0x0000(at)              // at = 4 if remix
        beq     t9, at, _shade              // if Allstar, check costume
        addiu   t9, r0, REMIX_1P_ID         // insert Remix 1p ID
        bne     t9, at, _normal             // if not Remix 1p, skip
        nop
        _shade:
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
    // Spawns 3 tiny opponents for tiny team
    // much is taken from 80133B58, yoshi team loading routine
    scope tiny_team_screen_card: {
        OS.patch_start(0x12DF64, 0x80134C24)
        jal     tiny_team_screen_card._set_num_chars
        lui     s2, 0x8013                  // original line 1
        OS.patch_end()

        OS.patch_start(0x12D04C, 0x80133D0C)
        j       tiny_team_screen_card._load
        addiu   a0, r0, REMIX_1P_ID         // insert Remix 1p ID
        nop
        _return:
        OS.patch_end()

        _set_num_chars:
        // 80135A30 is a table holding the number of characters to load for each stage

        li      t0, singleplayer_mode_flag  // t0 = singleplayer flag address
        lw      t0, 0x0000(t0)              // t0 = 4 if remix
        lli     t1, REMIX_1P_ID             // t1 = REMIX_IP_ID
        bne     t0, t1, _set_num_chars_end  // if not Remix 1p, skip
        lli     t0, 0x0004                  // t0 = 4 (number of characters to load)
        sw      t0, 0x5A54(s2)              // set number of characters to load for tiny team stage

        _set_num_chars_end:
        jr      ra
        addiu   s2, s2, 0x5C28              // original line 2

        _load:
        li      a1, singleplayer_mode_flag  // at = singleplayer flag address
        lw      a1, 0x0000(a1)              // at = 4 if remix
        bne     a0, a1, _normal             // if not Remix 1p, skip
        nop

        li      a1, STAGE_FLAG              // load stage ID address
        lb      a1, 0x0000(a1)              // load current stage of 1p
        addiu   a0, r0, 0x0009              // Samus Match/Progress
        bne     a0, a1, _normal             // if not Samus Match (normal = Link/Hyrule, allstar= Rest Area), jump to normal
        nop

        or      a0, s5, r0                  // original line 1

        jal     0x8013376C                  // original line 2
        addiu   a1, r0, 0x0020              // original line 3
        // 80133D0C regular path for title card loading
        // 80134B38 branch with deals with fighter structs for title cards
        // 80134C90 branch for allocation space for each title card fighter struct
        sll            t9, s5, 2
        addu           s0, s1, t9
        lui            s1, 0x8013
        lui            s4, 0x8013
        addiu          s4, s4, 0x5cc8
        addiu          s1, s1, 0x5c3c
        addiu          s6, r0, 0x0003       // set loop amount
        lw             s3, 0x0000(s0)       // loads character ID
        or             s0, r0, r0           // set to 0, so it can count upwards to loop

        _loop:
        addiu          t2, r0, 0x0020
        sw             t2, 0x0010 (sp)      // save 0x0020 to stack
        or             a0, s3, r0           // sets character ID
        or             a1, s5, r0           // unknown, seems to always be 1
        or             a2, r0, r0           // set frame of animation to zero

        jal            0x80133398           // generic 1p cpu character loading routine
        or             a3, s1, r0           // loads struct

        div            s0, s3
        lw             t3, 0x0004 (s4)
        or             s2, v0, r0

        bnez           s3, _branch_3
        nop

        break          0x01c00

        _branch_3:
        addiu          at, r0, 0xffff

        bne            s3, at, _branch_4
        lui            at, 0x8000

        bne            s0, at, _branch_4
        nop
        break          0x01800

        _branch_4:
        mfhi           a1
        or             a0, s2, r0


        beq            r0, r0, _branch_2        // skip shade stuff for now
        nop

        bne            t3, a1, _branch_2
        nop

        lw             t4, 0x0000 (s4)
        addiu          a2, r0, 0x0001

        bne            s3, t4, _branch_2
        nop

        jal            0x800e9248
        or             a0, s2, r0

        b              _branch_1
        addiu          s0, s0, 0x0001

        _branch_2:
        jal            0x800e9248
        or             a2, r0, r0

        addiu          s0, s0, 0x0001

        _branch_1:
        // s2 = player object
        lw      t0, 0x0074(s2)              // t0 = player top joint
        lui     t1, 0x3ecc                  // t1 = tiny size multiplier
        sw      t1, 0x0040(t0)              // set X scale
        sw      t1, 0x0044(t0)              // set Y scale
        sw      t1, 0x0048(t0)              // set Z scale
        lui     t1, 0x437A                  // t1 = y offset
        sw      t1, 0x0020(t0)              // set y offset
        addiu   t1, s0, -0x0001             // t1 = index in positions table
        sll     t1, t1, 0x0002              // t1 = offset in positions table
        li      t2, positions
        addu    t2, t2, t1                  // t2 = address of x offset
        lw      t1, 0x0000(t2)              // t1 = x offset
        sw      t1, 0x001C(t0)              // set x offset

        bne            s0, s6, _loop
        addiu          s1, s1, 0x0004

        j              0x80133EBC
        lw             ra, 0x003C(sp)

        _normal:
        or      a0, s5, r0                  // original line 1
        jal     0x8013376C                  // original line 2
        addiu   a1, r0, 0x0020              // original line 3

        j       _return
        nop

        positions:
        dw 0x437A0000 // closest model
        dw 0xC2C80000 // middle model
        dw 0xC4030000 // farthest model
    }

    // @ Description
    // Changes Mario to Falco for Mario Bros. Title Card
    scope doubles_card_1: {
        OS.patch_start(0x12D148, 0x80133E08)
        j       doubles_card_1
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      a1, singleplayer_mode_flag  // a1 = singleplayer mode flag
        lw      a1, 0x0000(a1)              // a1 = 4 if Remix 1p
        bne     a1, a0, _normal             // if not Remix 1p, skip
        or      a0, r0, r0                  // original line 1, set id to mario

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

        li      a1, singleplayer_mode_flag  // a1 = singleplayer mode flag
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
    // Allows Luigi to be his normal color against Team Star Fox and forces Fox to be an alternate color
    // Basically after an ally is randomly generated, it checks to see if the ally is Luigi, then takes a branch based on that
    scope starfox_costume: {
        OS.patch_start(0x521D4, 0x800D69D4)
        j       starfox_costume
        addiu   at, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      t7, singleplayer_mode_flag  // t7 = singleplayer mode flag
        lw      t7, 0x0000(t7)              // t7 = 4 if Remix 1p
        bne     t7, at, _normal             // if not Remix 1p, proceed as normal
        addiu   at, r0, 0x0004              // original line 1, set id to Luigi

        bne     v0, at, _skip
        nop
        addiu   v0, r0, Character.id.DK   // If Luigi is selected change to DK as both surprise fun and also because I cannot fix the stupid costume for Fox
        addiu   t8, r0, Character.id.DK
        addiu   v1, r0, Character.id.DK   // If Luigi is selected change to DK as both surprise fun and also because I cannot fix the stupid costume for Fox
        _skip:
        addiu   at, r0, 0x0001              // set ID to Fox
        j       _return                     // return
        multu   t6, s5                      // original line 2

        _normal:
        j        _return
        multu    t6, s5                      // original line 2
        }

    // @ Description
    // Loads the correct files for the Mario Bros/Doubles Stage of 1p
    scope doubles_file_loading: {
        OS.patch_start(0x12DE00, 0x80134AC0)
        j       doubles_file_loading
        addiu    a0, r0, REMIX_1P_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag  // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        bne     t6, a0, _normal             // if not Remix 1p, skip
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
        j        _return                    // return
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

        li      t6, singleplayer_mode_flag  // t6 = singleplayer mode flag
        lw      t6, 0x0000(t6)              // t6 = 4 if Remix 1p
        bne     t6, a0, _normal             // if not Remix 1p, skip
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
        j        _return                    // return
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

        li      a2, singleplayer_mode_flag  // a2 = singleplayer mode flag
        lw      a2, 0x0000(a2)              // a2 = 4 if Remix 1p
        bne     a2, a0, _normal             // if not Remix 1p, skip
        addiu   a0, r0, 0x0002              // original line 1, insert DK ID for Character routine

        li      a0, MATCH_SETTINGS_PART1
        j       _return
        lbu     a0, 0x0069(a0)              // load remix character from Match Settings

        _normal:
        j        _return                    // return
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

        li      t8, singleplayer_mode_flag  // t8 = singleplayer mode flag
        lw      t8, 0x0000(t8)              // t8 = 4 if remix
        bne     t8, t7, _normal             // if not Remix 1p, skip
        nop

        li      t6, remix_kirby_hat_pointer // load address of remix address
        j       _return
        lw      t8, 0x0000(t6)              // original line 2

        _normal:
        addiu    t6, t6, 0x4FD8             // original line 1
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

        li      t9, singleplayer_mode_flag  // t9 = singleplayer mode flag
        lw      t9, 0x0000(t9)              // t9 = 1 if multiman
        bne     t9, t4, _normal             // if not Remix 1p, skip
        nop

        li      t5, remix_kirby_pointer
        addu    t5, v0, t5
        j       _return
        lbu     t5, 0x0000(t5)

        _normal:
        addu    t5, t5, v0                  // original line 1
        j       _return
        lbu     t5, 0x2800(t5)              // original line 2
        }

    // @ Description
    // Changes a branch that would typically be used by the game to put a random kirby with on of the unlockable characters
    scope remix_kirby_skip: {
        OS.patch_start(0x10CBA4, 0x8018E344)
        j       remix_kirby_skip
        nop
        _return:
        OS.patch_end()

        li      v1, singleplayer_mode_flag  // v1 = singleplayer mode flag
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

        li      t5, singleplayer_mode_flag    // t9 = singleplayer mode flag
        lw      t5, 0x0000(t5)                // t9 = 1 if multiman
        bne     t5, t4, _end                  // if not Remix 1p, skip
        nop

        li      s5, remix_kirby_pointer       // set s5, the pointer to the list of kirby powers, to remix version

        _end:
        sll        t9, s4, 0x5                // original line 1
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

        li      s0, singleplayer_mode_flag  // s0 = singleplayer mode flag
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
        li      at, singleplayer_mode_flag  // at = singleplayer mode flag
        lw      at, 0x0000(at)              // at = 1 if multiman
        addiu   t5, r0, REMIX_1P_ID         // insert Remix 1p ID
        beq     t5, at, _standard           // do a standard spawn if Remix 1p
        nop

        j       0x8018D844
        addiu   t5, r0, 0x0001              // original line 2
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
        addiu   t2, r0, Character.id.GBOWSER // GIGA Bowser ID inserted

        beq     at, t2, _cpu_check          // got to cpu check as this is Giga Bowser
        addiu   t2, r0, Character.id.BOWSER // Bowser ID inserted

        bne     at, t2, _standard           // do dsp as normal, as it is not giga bowser or bowser
        nop


        _cpu_check:
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

        beq     at, t2, _cpu_check          // take jump to cpu check as is GIGA Bowser
        addiu   t2, r0, Character.id.BOWSER // Bowser ID inserted

        beq     at, t2, _cpu_check          // take jump to cpu check as is Bowser
        addiu   t2, r0, Character.id.PIANO  // Mad Piano ID inserted

        beq     at, t2, _cpu_check          // take jump to cpu check as is Mad Piano
        addiu   t2, r0, Character.id.FOX    // FOX ID inserted

        beq     at, t2, _cpu_check          // take jump to cpu check as is Mad Piano
        addiu   t2, r0, Character.id.FALCO  // FALCO ID inserted

        bne     at, t2, _standard           // do usp as normal, as it is not a selected character
        nop

        _cpu_check:
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

        li      at, Size.state_table
        sw      r0, 0x0000(at)              // reset size state to normal
        sw      r0, 0x0004(at)              // reset size state to normal
        sw      r0, 0x0008(at)              // reset size state to normal
        sw      r0, 0x000C(at)              // reset size state to normal

        li      at, page_flag               // at = page flag address

        jr      ra                          // original line 1
        sw      r0, 0x0000(at)              // clear page flag
    }

// ALLSTAR

// Total characters: 26
    // @ Description
    // Randomly generates a list of characters and stages for the matches
    // This only gets run after a player presses start on the 1p CSS screen
    scope allstar_randomization: {

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      r0, 0x0004(sp)
        sw      ra, 0x0008(sp)
        li      t8, 0x8003B6E4              // ~
        lw      t8, 0x0000(t8)              // t8 = frame count for current screen
        andi    t8, t8, 0x003F              // t8 = frame count % 64

        _loop:
        // advances rng between 1 - 64 times based on frame count when entering stage selection
        jal     0x80018910                  // this function advances the rng seed
        nop
        bnez    t8, _loop                   // loop if t8 != 0
        addiu   t8, t8,-0x0001              // subtract 1 from t8

        li      t0, allstar_hearts
        sw      r0, 0x0000(t0)              // clear out allstar hearts
        li      t0, allstar_progress
        sw      r0, 0x0000(t0)              // clear out allstar stage
        li      t0, allstar_percent
        sw      r0, 0x0000(t0)              // clear out allstar percent
        li      t0, allstar_limbo
        sw      r0, 0x0000(t0)              // clear out allstar limbo
        li      t0, end_game_flag
        sw      r0, 0x0000(t0)              // clear out end game flag
        li      t0, 0x800A4AF0
        sw      r0, 0x0000(t0)              // clear out game score
        li      t0, match_begin_flag
        sw      r0, 0x0000(t0)              // clear match begin flag

        addiu   t0, r0, 0x001B              // slot countdown (currently 27 character slots to fill), UPDATE when new character added
        addiu   t1, r0, 0x0018              // jump multiplier for match pool
        li      t5, match_pool              // load match pool address
        li      t7, allstar_character_order // load character slots address
        li      t2, allstar_stage_order     // load stage slots address
        addiu   t6, r0, r0                  // clear out t6 and establish slot spacer

        _assignment_loop:
        jal     Global.get_random_int_      // generate number based on total number of character pool
        addiu   a0, r0, 0x001C              // place current number of character pool in a0, UPDATE when new character added

        // get character ID
        mult    v0, t1                      // random number multiplied by jump multiplier
        mflo    v0
        addu    t3, t5, v0                  // add multiplier to match pool address, to get character's address
        lw      t4, 0x0000(t3)              // load flag to see if character has already been assigned
        bnez    t4, _assignment_loop        // restart if character already assigned
        addiu   t4, r0, 0x0001
        sw      t4, 0x0000(t3)              // save 1 to flag to mark the character as already used

        // get stage ID
        _assign_stage:
        jal     Global.get_random_int_      // generate number based on total number of stage pool for character
        addiu   a0, r0, 0x0003              // place current number of stage pool in a0

        addiu   v0, v0, 0x0001              // add 1 to output to account for character portion of word
        addu    t8, t3, v0                  // add v0 amount to get stage id
        lbu     t8, 0x0004(t8)              // load stage ID
        li      at, all_star_stage_used_table
        addu    at, at, t8                  // at = address of stage used flag
        lbu     t4, 0x0000(at)              // t4 = stage used flag
        bnez    t4, _assign_stage           // if the stage is used, try to get a different one
        lli     t4, OS.TRUE                 // t4 = TRUE (for next line where we mark it used)
        sb      t4, 0x0000(at)              // mark the stage as used

        // save settings
        _save_settings:
        lbu     t4, 0x0004(t3)              // load character ID
        lw      t6, 0x0004(sp)              // load slot spacer
        addu    at, t7, t6                  // add slot spacer to character slot address
        sh      t4, 0x0000(at)              // save character ID to character settings slot
        addu    at, t2, t6                  // add slot spacer to stage slot address
        sh      t8, 0x0000(at)              // save stage ID to stage slot

        _skip_stage:
        addiu   t6, t6, 0x0002              // add 2 to character slot spacer
        sw      t6, 0x0004(sp)              // save slot spacer
        bnez    t0, _assignment_loop
        addiu   t0, t0, -0x0001
        addiu   t0, r0, 0x001B              // total character count, UPDATE

        _clear_loop:
        sw      r0, 0x0000(t5)              // clear character flag 1
        addiu   t5, t5, 0x0018              // add 18 to current address to clear next character flag
        bnez    t0, _clear_loop             // continue clearing used character flags until all are cleared
        addiu   t0, t0, -0x0001             // subtract 1 from total character amount

        li      at, all_star_stage_used_table
        lli     t0, Stages.id.MAX_STAGE_ID
        addu    at, at, t0                  // at = address of last stage used flag
        _clear_stage_used_loop:
        sb      r0, 0x0000(at)              // clear flag
        addiu   at, at, -0x0001             // at--
        bnez    t0, _clear_stage_used_loop  // if more stages to clear, loop
        addiu   t0, t0, -0x0001             // t0--

        lw      ra, 0x0008(sp)
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return to remix_1p_randomization
        nop
    }
    OS.align(16)
    allstar_character_order:                // character order for allstar run
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000

    OS.align(16)
    allstar_stage_order:                     // stage order for allstar run
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000
    dw        0x00000000
    dw        0x00000000

    dw        0x00000000
    dw        0x00000000

    OS.align(16)
    ALLSTAR_MATCH_SETTINGS_PART2:

    //  Rest Stage
    dw  0x01000101
    dw  0x01010109
    dw  0x09090909
    dw  0x01010101
    dw  0x01090909
    dh  0x0909

    ALLSTAR_FINAL_MATCH_PART2:
    dw  0x00030305
    dw  0x0607090B
    dw  0x0C0D0E10
    dw  0x01010101
    dw  0x01090909
    dh  0x0909

    ALLSTAR_SINGLE_MATCH_PART2:
    dw  0x01030305
    dw  0x06070909
    dw  0x09090909
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

    ALLSTAR_DOUBLE_MATCH_PART2:
    dw  0x01030304
    dw  0x05070909
    dw  0x09090909
    dw  0x01010101
    dw  0x01090909
    dh  0x0909

    ALLSTAR_TRIPLE_MATCH_PART2:
    dw  0x01030103
    dw  0x04060909
    dw  0x09090909
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

    OS.align(16)

    ALLSTAR_MATCH_SETTINGS_PART1:
    //  Rest Stage
    dw  0xFF8B0000
    dw  0xFFFFFFFF
    dw  0x01051C00
    dw  0x00000000

    ALLSTAR_FINAL_MATCH_PART1:
    dw  0x800C0000
    dw  0xFFFFFFFF
    dw  0x19061C03
    dw  0x00000000

    ALLSTAR_SINGLE_MATCH_PART1:
    dw  0xFF010000
    dw  0xFFFFFFFF
    dw  0x01011C00
    dw  0x00000000

    //  Targets
    dw  0xFF000000
    dw  0xFFFFFFFF
    dw  0x011C1C00
    dw  0x00000000

    ALLSTAR_DOUBLE_MATCH_PART1:
    dw  0xFF460000
    dw  0xFFFFFFFF
    dw  0x02011D05
    dw  0x00000000

    ALLSTAR_TRIPLE_MATCH_PART1:
    dw  0xFF070000
    dw  0xFFFFFFFF
    dw  0x03090903
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

    // @ Description
    // Holds booleans for each stage by stage ID to indicate if it's been assigned a slot
    all_star_stage_used_table:
    fill (Stages.id.MAX_STAGE_ID + 1)

    OS.align(16)

   // @ Description
   // Sets player percent in allstar
   scope player_percent: {
       OS.patch_start(0x53210, 0x800D7A10)
       j       player_percent
       addiu   t7, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       // s0 and a2 are safe registers
       li      s0, singleplayer_mode_flag  // s0 = singleplayer flag address
       lw      s0, 0x0000(s0)              // s0 = 4 if remix
       bne     s0, t7, _normal             // if not Allstar, proceed as normal
       lw      t7, 0x0024(a1)              // original line 1 loads percent

       lw      s0, 0x0020(v1)              // load player type (if cpu or hmn)
       bnez    s0, _normal
       nop

       li      a2, SinglePlayerEnemy.enemy_port
       lw      a2, 0x0000(a2)              // a2 = player enemy (0 = none, 1 = port 1, 2 = port 2 etc.)
       beqz    a2, _apply_allstar_percent  // apply percent if no enemy player
       nop

       lui     a2, 0x800A                  // a2 = port index of primary human player
       lbu     a2, 0x4AE3(a2)              // ~

       addiu   s0, r0, 0x0003              //
       beql    a2, s0, _next               // branch if player is player 4
       addiu   a2, r0, r0                  // enemy is player 1

       addiu   a2, a2, 0x0001              // if ports 1-3, enemy will always be next port up

       _next:
       lbu     s0, 0x000D(v1)              // load port of current character

       beq     s0, a2, _normal             // branch if enemy player
       nop

       _apply_allstar_percent:
       li      t7, allstar_percent         // load player percent address
       lw      t7, 0x0000(t7)              // load player percent for allstar mode

       _normal:
       j       _return                     // return
       or      s0, a0, r0                  // original line 2
    }

   // @ Description
   // Clear player percent in allstar when player gets KO'd
   scope clear_percent: {
       OS.patch_start(0xB6990, 0x8013BF50)
       j       clear_percent
       addiu   a0, r0, ALLSTAR_ID
       _return:
       OS.patch_end()


       li      a1, singleplayer_mode_flag  // at = singleplayer flag address
       lw      a1, 0x0000(a1)              // at = 4 if remix
       bne     a1, a0, _normal             // if not Allstar, proceed as normal
       sb      t5, 0x002B(v0)              // original line 1, saves new stock amount

       lw      a0, 0x0020(s0)              // load if cpu or hmn
       bnez    a0, _normal                 // if cpu, branch
       nop

       li      a1, allstar_percent         // load allstar percent address
       sw      r0, 0x0000(a1)              // clear out percent amount, as character has been KO'd

       _normal:
       j       _return                     // return
       lbu     a1, 0x0015(s0)              // original line 2
    }

   // @ Description
   // Clear player percent in allstar when player has to continue
   scope clear_percent_continue: {
       OS.patch_start(0x17A6A8, 0x80133C48)
       j       clear_percent_continue
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t7, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t7, 0x0000(t7)              // at = 4 if remix
       bne     t7, at, _normal             // if not Allstar, proceed as normal
       lui     at, 0x800A                  // original line 1

       li      t7, allstar_percent         // load percent address
       sw      r0, 0x0000(t7)              // clear out percent
       li      t7, allstar_limbo           // load limbo address
       sw      r0, 0x0000(t7)              // clear out limbo

       _normal:
       j       _return                     // return
       sw      t3, 0x4AF0(at)              // original line 2
    }

// // @ Description
// // Sets Double VS Stage (over Mario Bros) to not load an ally
// scope ally_remove: {
//     OS.patch_start(0x10C0D4, 0x8018D874)
//     j       ally_remove
//     addiu   t7, r0, ALLSTAR_ID
//     _return:
//     OS.patch_end()
//
//
//     li      at, singleplayer_mode_flag  // at = singleplayer flag address
//     lw      at, 0x0000(at)              // at = 4 if remix
//     bne     at, t7, _normal             // if not Allstar, proceed as normal
//     lbu     t7, 0x000C(s7)              // original line 1 (loads the amount of allies)
//
//     li      at, STAGE_FLAG              // load stage ID address
//     lb      at, 0x0000(at)              // load current stage of 1p
//     addiu   t7, r0, 0x0004              // Doubles / Mario Bros Stage ID
//     bne     at, t7, _normal             // if not the right stage, jump to normal
//     lbu     t7, 0x000C(s7)              // original line 1 (loads the amount of allies)
//     addiu   t7, r0, 0x0000              // set amount of allies to 0
//
//     _normal:
//     j       _return                     // return
//     lui     v0, 0x800A                  // original line 2
// }

    // @ Description
    // Sets Rest Area CPU to not spawn and HRC CPU to not move
    scope rest_area_and_hrc_spawning: {
        OS.patch_start(0x10BE4C, 0x8018D5EC)
        j       rest_area_and_hrc_spawning
        addiu   t7, r0, ALLSTAR_ID
        _return:
        OS.patch_end()

        li      t5, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t5, 0x0000(t5)              // at = 4 if remix
        beq     t5, t7, _allstar            // if Allstar, branch
        lli     t7, HRC_ID                  // t7 = HRC ID
        beql    t5, t7, _normal             // if HRC, override character type
        lli     t3, 0x0005                  // t3 = 5 means the CPU will not move

        _normal:
        addu    t7, t9, v1                  // original line 1
        j       _return
        sb      t3, 0x0022(t7)              // original line 2

        _allstar:
        li      t5, STAGE_FLAG              // load stage ID address
        lb      t5, 0x0000(t5)              // load current stage of 1p
        bne     t5, r0, _normal             // if not stage zero (normal = Link/Hyrule, allstar= Rest Area), jump to normal
        nop
        b       _normal
        addiu   t3, r0, 0x0002              // set t3 to t2, which is the character type = none
    }

    // @ Description
    // Fixes a crashes with spawning like above
    scope rest_area_and_hrc_spawning_fix: {
        OS.patch_start(0x10CE20, 0x8018e5c0)
        j       rest_area_and_hrc_spawning_fix
        addiu   t7, r0, HRC_ID
        _return:
        OS.patch_end()

        li      t6, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t6, 0x0000(t6)              // at = 4 if remix
        beq     t6, t7, _set_flag           // if HRC, set flag to avoid crash as well
        addiu   t7, r0, ALLSTAR_ID
        bne     t6, t7, _normal             // if Allstar, branch
        nop

        _allstar:
        li      t6, STAGE_FLAG              // load stage ID address
        lb      t6, 0x0000(t6)              // load current stage of 1p
        bne     t6, r0, _normal             // if not stage zero (normal = Link/Hyrule, allstar= Rest Area), jump to normal
        nop

        _set_flag:
        addiu   t7, r0, 0x0001              // set flag to 1 to prevent a crash
        sb      t7, 0x0005(v1)

        _normal:
        lbu     t7, 0x0005(v1)              // original line 1
        j       _return
        lbu     t6, 0x0004(v1)              // original line 2
    }

    // @ Description
    // Sets Rest Area players to spawn instantly, like RTF. This is done by setting a 0x10 in the spawning struct to 0x1.
    // This is later picked up prior to character establishment and sets 0x1F of the character establishment struct to the correct ID
    // This ID thereby sets the characters initial action to "idle" instead of "Entry" thereby allowing movement. It also sets the player to be visible
    scope instant_spawn: {
        OS.patch_start(0x10C084, 0x8018D824)
        j       instant_spawn
        nop
        _return:
        OS.patch_end()

        beq     a3, at, _rtf_spawn_style    // modified original line 1
        addiu   at, r0, ALLSTAR_ID

        li      a1, singleplayer_mode_flag  // at = singleplayer flag address
        lw      a1, 0x0000(a1)              // at = 4 if remix
        bne     a1, at, _normal             // if not Allstar, proceed as normal
        nop



        beq     a3, r0, _rtf_spawn_style    // if at the rest stage (same as Hyrule in normal 1p), use rtf style spawning
        nop


        _normal:
        j       _return                     // modified original line 1
        or      a1, a3, r0                  // original line 2

        _rtf_spawn_style:
        j       0x8018D840                  // modified original line 1
        or      a1, a3, r0                  // original line 2
    }

    // @ Description
    // Clears out limbo flag, which is the time period between player ko and when they spawn and have their percent returned to zero
    scope limbo_clear: {
        OS.patch_start(0x5324C, 0x800D7A4C)
        j       limbo_clear
        lw      t7, 0x0008(v1)          // original line 1
        _return:
        OS.patch_end()

        ori     at, r0, Character.id.KIRBY
        beq     t7, at, _kirby
        ori     at, r0, Character.id.JKIRBY
        beq     t7, at, _kirby
        ori     at, r0, Character.id.BOWSER

        bne     t7, at, _allstar_check
        addiu   at, r0, 0x0014          // refill ammo when spawned
        beq     r0, r0, _allstar_check
        sh      at, 0x0ADE(v1)          // save ammo to ammo location

        _kirby:
        lw      a0, 0x0ADC(v1)          // load current power
        ori     at, r0, 0x0034          // bowser power id
        bne     a0, at, _allstar_check  // if not spawning with hat, ignore
        addiu   at, r0, 0x0014          // refill ammo when spawned
        sh      at, 0x0AE2(v1)          // save ammo to ammo location


        _allstar_check:
        li      at, allstar_limbo       // load limbo
        sw      r0, 0x0000(at)          // clear flag
        j       _return                 // return
        addiu   at, r0, 0x0006          // original line 2
    }

   // @ Description
   // Skips spawning the "GO" object and sound effect at beginning of Rest Area
   scope skip_go: {
       OS.patch_start(0x10D1C4, 0x8018E964)
       j       skip_go
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t6, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t6, 0x0000(t6)              // at = 5 if allstar
       bne     t6, at, _normal             // if not Allstar, proceed as normal
       nop

       li      t6, STAGE_FLAG              // load stage ID address
       lb      t6, 0x0000(t6)              // load current stage of 1p
       bne     t6, r0, _normal             // if not stage zero (normal = Link/Hyrule, allstar= Rest Area), jump to normal
       nop


       j       0x8018E97C                  // skip Go sound and object
       nop

       _normal:
       jal     0x801120D4                  // original line 1
       nop                                 // original line 2

       j       _return                     // return
       nop
   }

    // @ Description
    // Offsets to the icon image footers in the Stock Icons file.
    // The size of each block is 0xE0, so Mario's flash would be at icon_offsets.MARIO + 0xE0 for example.
    scope icon_offsets: {
        // original
        constant MARIO(0x00000088 + 0x10)
        constant FOX(0x00000168 + 0x10)
        constant DONKEY(0x00000248 + 0x10)
        constant SAMUS(0x00000328 + 0x10)
        constant LUIGI(0x00000408 + 0x10)
        constant LINK(0x000004E8 + 0x10)
        constant YOSHI(0x000005C8 + 0x10)
        constant CAPTAIN(0x000006A8 + 0x10)
        constant KIRBY(0x00000788 + 0x10)
        constant PIKACHU(0x00000868 + 0x10)
        constant JIGGLYPUFF(0x00000948 + 0x10)
        constant NESS(0x00000A28 + 0x10)

        // special
        constant METAL(0x00000B08 + 0x10)
        constant POLY(0x00000BE8 + 0x10)
        constant GBOWSER(0x000013C8 + 0x10)
        constant PIANO(0x000014A8 + 0x10)

        // custom
        constant FALCO(0x00000CC8 + 0x10)
        constant GND(0x00000DA8 + 0x10)
        constant YLINK(0x00000E88 + 0x10)
        constant DRM(0x00000F68 + 0x10)
        constant DSAMUS(0x00001128 + 0x10)
        constant WARIO(0x00001048 + 0x10)
        constant LUCAS(0x00001208 + 0x10)
        constant BOWSER(0x000012E8 + 0x10)
        constant WOLF(0x00001588 + 0x10)
        constant CONKER(0x00001668 + 0x10)
        constant MTWO(0x00001748 + 0x10)
        constant MARTH(0x00001828 + 0x10)
        constant SONIC(0x00001908 + 0x10)
        constant SSONIC(0x000019E8 + 0x10)
        constant SHEIK(0x00001AC8 + 0x10)
        constant MARINA(0x00001BA8 + 0x10)
        constant DEDEDE(0x00001C88 + 0x10)
    }

    // @ Description
    // Icon offsets by character ID
    icon_offset_table:
    dw icon_offsets.MARIO                    // Mario
    dw icon_offsets.FOX                      // Fox
    dw icon_offsets.DONKEY                   // Donkey Kong
    dw icon_offsets.SAMUS                    // Samus
    dw icon_offsets.LUIGI                    // Luigi
    dw icon_offsets.LINK                     // Link
    dw icon_offsets.YOSHI                    // Yoshi
    dw icon_offsets.CAPTAIN                  // Captain Falcon
    dw icon_offsets.KIRBY                    // Kirby
    dw icon_offsets.PIKACHU                  // Pikachu
    dw icon_offsets.JIGGLYPUFF               // Jigglypuff
    dw icon_offsets.NESS                     // Ness
    dw icon_offsets.POLY                     // Master Hand
    dw icon_offsets.METAL                    // Metal Mario
    dw icon_offsets.POLY                     // Polygon Mario
    dw icon_offsets.POLY                     // Polygon Fox
    dw icon_offsets.POLY                     // Polygon Donkey Kong
    dw icon_offsets.POLY                     // Polygon Samus
    dw icon_offsets.POLY                     // Polygon Luigi
    dw icon_offsets.POLY                     // Polygon Link
    dw icon_offsets.POLY                     // Polygon Yoshi
    dw icon_offsets.POLY                     // Polygon Captain Falcon
    dw icon_offsets.POLY                     // Polygon Kirby
    dw icon_offsets.POLY                     // Polygon Pikachu
    dw icon_offsets.POLY                     // Polygon Jigglypuff
    dw icon_offsets.POLY                     // Polygon Ness
    dw icon_offsets.DONKEY                   // Giant Donkey Kong
    dw 0x00000000
    dw 0x00000000
    dw icon_offsets.FALCO                    // Falco
    dw icon_offsets.GND                      // Ganondorf
    dw icon_offsets.YLINK                    // Young Link
    dw icon_offsets.DRM                      // Dr. Mario
    dw icon_offsets.WARIO                    // Wario
    dw icon_offsets.DSAMUS                   // Dark Samus
    dw icon_offsets.LINK                     // E Link
    dw icon_offsets.SAMUS                    // J Samus
    dw icon_offsets.NESS                     // J Ness
    dw icon_offsets.LUCAS                    // Lucas
    dw icon_offsets.LINK                     // J Link
    dw icon_offsets.CAPTAIN                  // J Captain Falcon
    dw icon_offsets.FOX                      // J Fox
    dw icon_offsets.MARIO                    // J Mario
    dw icon_offsets.LUIGI                    // J Luigi
    dw icon_offsets.DONKEY                   // J Donkey Kong
    dw icon_offsets.PIKACHU                  // E Pikachu
    dw icon_offsets.JIGGLYPUFF               // J Jigglypuff
    dw icon_offsets.JIGGLYPUFF               // E Jigglypuff
    dw icon_offsets.KIRBY                    // J Kirby
    dw icon_offsets.YOSHI                    // J Yoshi
    dw icon_offsets.PIKACHU                  // J Pikachu
    dw icon_offsets.SAMUS                    // E SAMUS
    dw icon_offsets.BOWSER                   // Bowser
    dw icon_offsets.GBOWSER                  // Giga Bowser
    dw icon_offsets.PIANO                    // Mad Piano
    dw icon_offsets.WOLF                     // Wolf
    dw icon_offsets.CONKER                   // Conker
    dw icon_offsets.MTWO                     // Mewtwo
    dw icon_offsets.MARTH                    // Marth
    dw icon_offsets.SONIC                    // Sonic
    dw 0                                     // Sandbag
    dw icon_offsets.SSONIC                   // Super Sonic
    dw icon_offsets.SHEIK                    // Sheik
    dw icon_offsets.MARINA                   // Marina
    dw icon_offsets.DEDEDE                   // Dedede
    // ADD NEW CHARACTERS HERE

    // REMIX POLYGONS
    dw icon_offsets.POLY                     // Polygon Wario
    dw icon_offsets.POLY                     // Polygon Lucas
    dw icon_offsets.POLY                     // Polygon Bowser
    dw icon_offsets.POLY                     // Polygon Wolf
    dw icon_offsets.POLY                     // Polygon Dr. Mario
    dw icon_offsets.POLY                     // Polygon Sonic
    dw icon_offsets.POLY                     // Polygon Sheik
    dw icon_offsets.POLY                     // Polygon Marina

    // @ Description
    // This establishes Rest Area functions such as portraits and heart spawns
    scope rest_area_setup: {
        addiu   sp, sp, -0x0068
        sw      ra, 0x0014(sp)
        addiu   t2, r0, 0x0001
        li      t1, match_begin_flag
        sw      t2, 0x0000(t1)                  // match has begun and thus flag should be set
        addiu   a0, r0, 0x03F2
        or      a1, r0, r0
        addiu   a2, r0, 0x0001
        jal     0x80009968
        lui     a3, 0x8000
        li      a1, rest_area_routine
        or      a0, v0, r0
        addiu   a2, r0, 0x0001
        jal     0x80008188
        addiu   a3, r0, 0x0004

        li      t1, end_game_flag               // load end allstar flag address
        sw      r0, 0x0000(t1)
        li      t1, allstar_limbo               // load limbo address
        sw      r0, 0x0000(t1)

        li      t1, allstar_hearts
        lw      t1, 0x0000(t1)
        sw      t1, 0x0018(sp)                  // save hearts used to stack

        // Before we create hearts, clear out the player struct array head pointer so we don't get an error
        // trying to figure out if the sound effect should be Japanese
        lui     t2, 0x8013
        sw      r0, 0x0D84(t2)                  // clear pointer

        sltiu   t2, t1, 0x0001                  // set to zero is less than 1
        beqz    t2, _heart_2

        addu    a0, r0, r0                      // clear object ID
        addiu   a1, r0, Hazards.standard.HEART  // set item ID
        addiu   a3, sp, 0x0050                  // a3 = address of setup floats
        addiu   a2, a3, 0x000C                  // a2 = address of floats
        sw      r0, 0x0000(a3)                  // floating point register that needs to be cleared
        sw      r0, 0x0004(a3)                  // floating point register that needs to be cleared
        lui     at, 0xc496                      // -1200(fp)
        sw      at, 0x0000(a2)                  // set x
        lui     at, 0x4396                      // 300(fp)
        sw      at, 0x0004(a2)                  // set y
        jal     0x8016EA78                      // create item
        sw      r0, 0x0008(a2)                  // set z

        _heart_2:
        lw      t1, 0x0018(sp)                  // load allstar hearts used
        sltiu   t2, t1, 0x0002                  // set to zero is less than 2
        beqz    t2, _heart_3

        addu    a0, r0, r0                      // clear object ID
        addiu   a1, r0, Hazards.standard.HEART  // set item ID
        addiu   a3, sp, 0x0050                  // a3 = address of setup floats
        addiu   a2, a3, 0x000C                  // a2 = address of floats
        sw      r0, 0x0000(a3)                  // floating point register that needs to be cleared
        sw      r0, 0x0004(a3)                  // floating point register that needs to be cleared
        lui     at, 0xc448                      // -800(fp)
        sw      at, 0x0000(a2)                  // set x
        lui     at, 0x4396                      // 300(fp)
        sw      at, 0x0004(a2)                  // set y
        jal     0x8016EA78                      // create item
        sw      r0, 0x0008(a2)                  // set z

        _heart_3:
        lw      t1, 0x0018(sp)                  // load allstar hearts used
        sltiu   t2, t1, 0x0003                  // set to zero is less than 2
        beqz    t2, _icons                      // jump to portraits if all hearts used

        addu    a0, r0, r0                      // clear object ID
        addiu   a1, r0, Hazards.standard.HEART  // set item ID
        addiu   a3, sp, 0x0050                  // a3 = address of setup floats
        addiu   a2, a3, 0x000C                  // a2 = address of floats
        sw      r0, 0x0000(a3)                  // floating point register that needs to be cleared, presumably velocity related
        sw      r0, 0x0004(a3)                  // floating point register that needs to be cleared
        lui     at, 0xc3c8                      // -400(fp)
        sw      at, 0x0000(a2)                  // set x
        lui     at, 0x4396                      // 300(fp)
        sw      at, 0x0004(a2)                  // set y
        jal     0x8016EA78                      // create item
        sw      r0, 0x0008(a2)                  // set z

        _icons:
        addiu   t3, r0, FINAL_STAGE_AMOUNT
        li      t1, allstar_progress
        lw      t1, 0x0000(t1)              // load current progress
        subu    t3, t3, t1                  // determine amount of loops necessary
        li      t2, allstar_character_order // load address of character order
        addiu   t4, r0, 0x2
        mult    t1, t4                      // multiply current progress ID by 2
        mflo    t1                          // place product in t1
        addu    t6, t2, t1                  // add to get address of primary character
        addiu   t9, r0, r0                  // clear out t9

        _loop_icons:
        lhu     t2, 0x0000(t6)              // load character id of next character
        addiu   t4, r0, 0x4
        mult    t2, t4                      // multiply character ID by 4
        mflo    t2                          // place product in t2
        li      t5, icon_offset_table       // load address of offset table
        addu    t5, t5, t2                  // add to get address of offset
        lw      t5, 0x0000(t5)              // load characters offset

        lli     a0, 0x18                    // a0 = room
        lli     a1, 0x00                    // a1 = group
        li      a2, 0x80131300              // a2 = hardcoded struct
        lw      a2, 0x0000(a2)              // a2 = address that has pointer to header + 0x14
        lw      a2, 0x00D0(a2)              // a2 = address of file 0xD8B(icons)
        addu    a2, a2, t5                  // a2= character portrait location

        lli     a3, 0x0000                  // a3 = (no) routine


        addiu   at, r0, 0x000A              // divide by 10, so there are 10 icons per row
        divu    t9, at
        mflo    t7                          // quotient (current row)
        addi    at, r0, 0xFFA6              // place 90 for each row, which should take to starting point
        mult    t7, at                      // multiply by amount of rows
        mflo    t8                          // place product in t8
        li      s1, 0x41c00000              // s1 = ulx starting point (30)
        mtc1    s1, f10
        addiu   at, r0, 0x0009              // place multiplier of 9 in at
        mult    t9, at                      // multiply loop count by 9
        mflo    at                          // get product
        add     at, at, t8                  // subtract amount to return to zero
        mtc1    at, f8                      // move difference to float
        cvt.s.w f8, f8                      // convert to floating point
        add.s   f8, f8, f10
        mfc1    s1, f8

        li      s2, 0x41c00000              // s2 = uly (30)

        addiu   at, r0, 0x000B              // place 0B in at
        mult    t7, at                      // multiply by current row
        mflo    at                          // addition lowness for icon
        mtc1    at, f6
        cvt.s.w  f6, f6                     // convert integer to floating point
        mtc1    s2, f10
        add.s   f6, f6, f10                 // add 11 for each row after first
        mfc1    s2, f6
        li      s3, 0xFFFFFFFF              // s3 = color
        li      s4, 0x00000000              // s4 = palette
        sw      t6, 0x0064(sp)              // save address of current character loading
        sw      t3, 0x0060(sp)              // save amount of loops remaining
        sw      t9, 0x005C(sp)              // save loop count
        //sw
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

        lw      t6, 0x0064(sp)              // load address of current character loading
        addiu   t6, t6, 0x0002              // add two to get next character
        lw      t3, 0x0060(sp)              // load amount of loops remaining
        lw      t9, 0x005C(sp)              // load loop count
        addiu   t9, 0x0001                  // add 1 to loop count
        bnez    t3, _loop_icons
        addiu   t3, t3, -0x0001             // subtract one loop

        _portrait:
        li      t1, allstar_progress
        lw      t1, 0x0000(t1)              // load current progress

        addiu   t6, r0, DOUBLE_STAGE_AMOUNT
        slt     t7, t1, t6
        bnez    t7, _load_portrait          // if progress is below double stage amount, set loops to 0, as you only face one character
        addu    t8, r0, r0                  // set loop to 0

        addiu   t6, r0, TRIPLE_STAGE_AMOUNT
        slt     t7, t1, t6
        bnez    t7, _load_portrait           // if progress fewer than Triple stage amount, set loops to 1, as you will face two characters
        addiu   t8, r0, 0x0001

        addiu   t6, r0, FINAL_STAGE_AMOUNT
        slt     t7, t1, t6
        bnez    t7, _load_portrait
        addiu   t8, r0, 0x0002              // if progress fewer than final stage amount, let loops to 2, as you will face three characters

        addiu   t8, r0, 0x0000              // if at final stage, set loops to 0 as you only face one character

        _load_portrait:
        li      t2, allstar_character_order // load address of character order
        addiu   t4, r0, 0x2
        mult    t1, t4                      // multiply coming stage by 2
        mflo    t1                          // place product in t1
        addu    t2, t2, t1                  // add to get address of primary character


        _loop:
        sw      t2, 0x0064(sp)              // save address of current character loading
        sw      t8, 0x0060(sp)              // save amount of loops remaining
        lhu     t2, 0x0000(t2)              // load character id of next character
        addiu   t4, r0, 0x4
        mult    t2, t4                      // multiply character ID by 4
        mflo    t2                          // place product in t2
        li      t3, CharacterSelect.portrait_offset_by_character_table  // load address of offset table
        addu    t3, t3, t2                  // add to get address of offset
        lw      t3, 0x0000(t3)              // load characters offset


        lli     a0, 0x04                    // a0 = room
        lli     a1, 0x00                    // a1 = group
        li      a2, 0x80131300              // a2 = hardcoded struct
        lw      a2, 0x0000(a2)              // a2 = address that has pointer to header + 0x14
        lw      a2, 0x00CC(a2)              // a2 = address of file 0xA05(portraits)
        addu    a2, a2, t3                  // a2 = character portrait image footer
        lw      a2, 0x0034(a2)              // a2 = character portrait image data array
        lw      a2, 0x0008(a2)              // a2 = character portrait image location
        lli     a3, 0x0000                  // a3 = (no) routine

        beqz    t8, _slot_1                 // if loop on 0, set to the first spot
        addiu   t9, r0, 0x0001

        beq     t8, t9, _slot_2             // if loop is on 1, place character in second slot
        nop

        _slot_3:
        beq     r0, r0, _render
        lui      s1, 0xc47a                 // s1 = ulx (-1000)

        _slot_2:
        beq     r0, r0, _render
        lui      s1, 0xc416                 // s1 = ulx (-600)

        _slot_1:
        lui      s1, 0xC348                 // s1 = ulx (-200)


        _render:
        li      s2, 0x447a0000              // s2 = uly
        li      s3, 0xc1a00000              // s2 = ulz
        lli     s4, 0x00A0                  // s4 = alpha
        jal     Render.draw_stage_texture_
        nop
        lw      t2, 0x0064(sp)
        addiu   t2, t2, 0x0002              // add 2 to address to load next character if loading
        lw      t8, 0x0060(sp)              // load amount of loops remaining
        bnez    t8, _loop
        addiu   t8, t8, -0x0001

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0068
        jr      ra
        nop
    }

    // @ Description
    // This establishes Rest Area functions such as portraits and heart spawns
    // UPDATE when character added
    constant DOUBLE_STAGE_AMOUNT(0x8)       // amount of character progress to have 1v2
    constant TRIPLE_STAGE_AMOUNT(0x12)       // amount of character progress to have 1v3
    constant FINAL_STAGE_AMOUNT(0x1B)       // amount of character progress to have yoshi team style battle

    scope rest_area_routine: {
        lui     t7, 0x800A
        lbu     t7, 0x4AE3(t7)
        lui     t6, 0x800A
        lw      t6, 0x50E8(t6)
        sll     t8, t7, 0x3
        subu    t8, t8, t7
        sll     t8, t8, 0x2
        addiu   sp, sp, -0x0018
        addu    t8, t8, t7
        sll     t8, t8, 0x2
        sw      ra, 0x0014(sp)
        sw      a0, 0x0018(sp)
        addu    t9, t6, t8
        lw      t0, 0x0078(t9)      // load player object address
        lw      v0, 0x0084(t0)      // load player struct address
        lw      t1, 0x014C(v0)      // load player kinetic state (ground v. aerial)
        bnel    t1, r0, _end        // jump to end if player is in the air
        lw      ra, 0x0014(sp)
        lw      t2, 0x00F4(v0)      // load surface id
        lui     at, 0xFFFF
        ori     at, at, 0x00FF
        and     t3, t2, at
        addiu   at, r0, 0x000E      // insert stage ending clipping ID
        bnel    t3, at, _end        // skip to end if not over 0xE clipping ID
        lw      ra, 0x0014(sp)
        li      t0, 0x800465D0      // load screen interrupt flag
        addiu   at, r0, 0x0001
        sw      at, 0x0000(t0)      // set interrupt flag
        li      t1, 0x800A4AD0      // load screen struct address

        addiu   t2, r0, 0x0034      // title card screen ID
        sb      t2, 0x0000(t1)      // save title card screen ID to next screen address
        sb      at, 0x0012(t1)      // save 1 to flag address which skips loading score results and loads next screen

        li      t5, allstar_progress   // load current progress address
        lw      t6, 0x0000(t5)      // load current progress
        li      t3, STAGE_FLAG      // load current stage flag address
        addiu   t4, r0, DOUBLE_STAGE_AMOUNT
        li      t7, allstar_character_order
        li      t8, allstar_stage_order
        slt     t9, t6, t4           // set to 1 if progress is less than 1v2 match progress
        bnez    t9, _singles
        nop
        addiu   t4, r0, TRIPLE_STAGE_AMOUNT
        slt     t9, t6, t4          // set to 1 if progress is less than 1v3 match progress
        bnez    t9, _doubles
        nop
        addiu   t4, r0, FINAL_STAGE_AMOUNT
        slt     t9, t6, t4          // set to 1 if progress is less than 1v3 match progress
        bnez    t9, _triples
        nop

        // final stage character set up
        addiu   at, r0, 0x0001      // set to yoshi team stage ID
        sb      at, 0x0000(t3)      // save yoshi team flag ID to stage
        addiu   at, r0, 0x0002
        mult    t6, at              // multiply progress times 0x2 to get offset
        mflo    at
        addu    t0, t7, at          // add offset to get character address
        addu    t1, t8, at          // add offset to get stage address
        lhu     t2, 0x0000(t0)      // load character ID
        li      at, ALLSTAR_FINAL_MATCH_PART1 // load final match struct
        sb      t2, 0x0009(at)      // save character ID
        lhu     t3, 0x0000(t1)      // load stage ID
        beq     r0, r0, _end        // finish setting up final stage
        sb      t3, 0x0001(at)      // save stage ID

        _singles:
        addiu   at, r0, 0x0002      // set to fox stage ID
        sb      at, 0x0000(t3)      // save fox stage ID to stage
        mult    t6, at              // multiply progress times 0x2 to get offset
        mflo    at
        addu    t0, t7, at          // add offset to get character address
        addu    t1, t8, at          // add offset to get stage address
        lhu     t2, 0x0000(t0)      // load character ID
        li      at, ALLSTAR_SINGLE_MATCH_PART1 // load singles match struct
        sb      t2, 0x0009(at)      // save character ID
        lhu     t3, 0x0000(t1)      // load stage ID
        beq     r0, r0, _end        // finish setting up final stage
        sb      t3, 0x0001(at)      // save stage ID

        _doubles:
        addiu   at, r0, 0x0004      // set to mario bros stage ID
        sb      at, 0x0000(t3)      // save mario bros stage ID to stage
        addiu   at, r0, 0x0002
        mult    t6, at              // multiply progress times 0x2 to get offset
        mflo    at
        addu    t0, t7, at          // add offset to get character address
        addu    t1, t8, at          // add offset to get stage address
        lhu     t2,  0x0000(t0)     // load character ID 1
        li      at, ALLSTAR_DOUBLE_MATCH_PART1 // load final match struct
        sb      t2, 0x0009(at)      // save character 1 ID
        lhu     t2, 0x0002 (t0)     // load character ID 2
        sb      t2, 0x000A(at)      // save character 2 ID

        lhu     t3, 0x0000(t1)      // load stage ID
        beq     r0, r0, _end        // finish setting up final stage
        sb      t3, 0x0001(at)      // save stage ID

        _triples:
        addiu   at, r0, 0x0005      // set to pikachu stage ID
        sb      at, 0x0000(t3)      // save pikachu stage ID to stage
        addiu   at, r0, 0x0002
        mult    t6, at              // multiply progress times 0x2 to get offset
        mflo    at
        addu    t0, t7, at          // add offset to get character address
        addu    t1, t8, at          // add offset to get stage address
        lhu     t2,  0x0000(t0)     // load character ID 1
        li      at, ALLSTAR_TRIPLE_MATCH_PART1 // load final match struct
        sb      t2, 0x0009(at)          // save character 1 ID
        lhu     t2, 0x0002(t0)          // load character ID 2
        sb      t2, 0x000A(at)          // save character 2 ID
        lhu     t2, 0x0004(t0)          // load character ID 3
        sb      t2, 0x000B(at)          // save character 3 ID

        lhu     t3, 0x0000(t1)      // load stage ID
        sb      t3, 0x0001(at)      // save stage ID

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

            //lbu     t4, 0x0000(t3)      // load current stage
        //beql    t4, _end            // if at rest stage, skip to end


        //sw      r0, 0x0000(t3)      // set stage ID to 0 (return to rest area as the player was in a match)

        //addiu   t6, t6, 0x0001      // add 1 to current progress as you have won the match

    // @ Description
    // Prevents hearts from fading in allstar mode, uses a generic routine which determines when items begin to fade and get destroyed
    // a2=active item struct
    scope heart_persist: {
        OS.patch_start(0xE9FFC, 0x8016F5BC)
        j       heart_persist
        addiu   v0, r0, ALLSTAR_ID
        _return:
        OS.patch_end()


        li      t9, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t9, 0x0000(t9)              // at = 5 if allstar
        bne     t9, v0, _normal             // if not Allstar, proceed as normal
        nop

        li      t9, STAGE_FLAG
        lb      t9, 0x0000(t9)              // load current stage progress

        bnez    t9, _normal                 // If not at stage 0 aka Rest, skip
        addiu   v0, r0, Hazards.standard.HEART

        lw      t9, 0x000C(a2)              // load item ID from active item struct

        bne     t9, v0, _normal             // if not a heart, skip
        nop
        beq     r0, r0, _rest
        addiu   v0, r0, 0x5785              // sets hearts to be permanently at max in rest area, so they never begin to fade

        _normal:
        lhu     v0, 0x02D2(a2)              // original line 1, loads a timer of sorts for destruction of items
        _rest:
        j       _return                     // modified original line 1
        srl     t9, v0, 0x4                 // original line 2
    }

    // @ Description
    // Changes traditional 1p stage/ progress for allstar mode (this does not advance allstar progress)
    scope progress_advancement: {
        OS.patch_start(0x52530, 0x800D6D30)
        j       progress_advancement
        addiu   t2, r0, ALLSTAR_ID
        _return:
        OS.patch_end()


        li      t3, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t3, 0x0000(t3)              // at = 5 if allstar
        bne     t3, t2, _normal             // if not Allstar, proceed as normal
        nop

        li      t3, STAGE_FLAG
        lb      t3, 0x0000(t3)              // load current stage progress

        addiu   t2, r0, 0x000E              // check for end of game
        beq     t3, t2, _normal             // branch if game is over
        addiu   t2, r0, 0x000D              // check for end of game
        beq     t3, t2, _normal             // branch if game is over
        nop

        bnel    t3, r0, _normal             // If not at stage 0 aka Rest, set to Rest Stage aka Link Stage
        addiu   t9, r0, r0                  // set stage to 0

        addiu   t9, t9, -0x0001             // subtract 1 from stage (it has been advanced, which we don't want, so we are undoing that

        _normal:
        bnez    at, _0x800D6958             // modified original line 1
        sb      t9, 0x0017(s2)              // original line 2, saves id to current standard 1p progress/ stage ID

        j       _return                     // return
        nop

        _0x800D6958:
        j       0x800D6958                  // modified original line 1
        nop
    }

    // @ Description
    // Screen setting at end of 1p match that prevents game from setting screen to 1p menu screen
    scope screen_set_end: {
        OS.patch_start(0x523E8, 0x800D6BE8)
        j       screen_set_end
        addiu   s0, r0, ALLSTAR_ID
        _return:
        OS.patch_end()


        li      s1, singleplayer_mode_flag  // at = singleplayer flag address
        lw      s1, 0x0000(s1)              // at = 5 if allstar
        bne     s1, s0, _normal             // if not Allstar, proceed as normal
        nop

        j       0x800D6FAC                  // modified original line 1
        nop

        _normal:
        // if t3 = 2, then we did a Practice reset, so set screen to 0x34 to restart the practice match
        sltiu   t3, t3, 0x0002              // t3 = 0 if Practice reset
        beqzl   t3, pc() + 8                // if Practice reset, then change screen id
        lli     t2, 0x0034                  // t2 = 1p screen id
        j       0x800D6FAC                  // modified original line 1
        sb      t2, 0x0000(s2)              // original line 2, saves screen id to be 1p menu
    }

    // @ Description
    // Counts the amount of hearts used in Rest area by saving to allstar_hearts for each one used, which gets pulled by Rest Area's hazard routine to determine how many hearts to spawn
    scope heart_counter: {
        OS.patch_start(0xC06E4, 0x80145CA4)
        j       heart_counter
        addiu   a1, r0, ALLSTAR_ID
        _return:
        OS.patch_end()


        li      t6, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t6, 0x0000(t6)              // at = 5 if allstar
        bne     t6, a1, _normal             // if not Allstar, proceed as normal
        nop

        li      t6, STAGE_FLAG
        lb      t6, 0x0000(t6)              // load current stage progress

        bnez    t6, _normal                 // If not at stage 0 aka Rest, skip
        nop

        li      a1, allstar_hearts          // load hearts counter
        lw      t6, 0x0000(a1)
        addiu   t6, t6, 0x0001              // load current heart usage
        sw      t6, 0x0000(a1)              // save usage

        _normal:
        addiu   a1, r0, 0x03E7              // original line 1,
        j       _return                     // return
        sw      a2, 0x0018(sp)              // original line 2
    }

    // @ Description
    // Advances Allstar Progress
    scope advance_allstar: {
        OS.patch_start(0x17DF18, 0x80134CC8)
        j       advance_allstar
        addiu   t7, r0, ALLSTAR_ID          // insert allstar mode ID
        _return:
        OS.patch_end()


        li      t6, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t6, 0x0000(t6)              // at = 5 if allstar
        bne     t6, t7, _normal             // if not Allstar, proceed as normal
        nop

        li      t6, allstar_progress        // load current progress address
        lw      t0, 0x0000(t6)              // load current progress
        addiu   t7, r0, DOUBLE_STAGE_AMOUNT
        slt     t8, t0, t7                  // set to 1 if progress is less than 1v2 match progress
        bnez    t8, _set
        addiu   t8, r0, 0x0001              // advance progress by 1 if defeat single opponent
        addiu   t7, r0, TRIPLE_STAGE_AMOUNT
        slt     t8, t0, t7                  // set to 1 if progress is less than 1v3 match progress
        bnez    t8, _set
        addiu   t8, r0, 0x0002              // advance progress by 2 if defeat two opponents

        addiu   t8, r0, 0x0003              // advance progress by 3 if defeat three opponents

        _set:
        addu    t8, t0, t8                  // add progress amount to current progress
        sw      t8, 0x0000(t6)              // save new progress to progress address

        _normal:
        lui     t6, 0x001B                  // original line 1,
        j       _return                     // return
        lui     t7, 0x0000                  // original line 2
    }

    // @ Description
    // Due to a shared function that sets the screen in 1p, I had to find a new spot to set the screen when exiting Allstar out of pause
    // the routine I'm hooking into only runs when exiting out of pause (I think). It sets a flag which determines certain behaviors of 1p (including pausing in the first place)
    scope pause_exit: {
        OS.patch_start(0x8FAC4, 0x801142C4)
        j       pause_exit
        addiu   t7, r0, REMIX_1P_ID         // insert allstar mode ID
        _return:
        OS.patch_end()


        li      t6, singleplayer_mode_flag  // at = singleplayer flag address
        lw      t6, 0x0000(t6)              // at = 5 if allstar
        beq     t6, t7, _remix              // if Remix 1p, clear size status
        addiu   t7, r0, ALLSTAR_ID          // insert allstar mode ID
        bne     t6, t7, _normal             // if not Allstar, proceed as normal
        nop

        li      t6, 0x800A4AD0              // load screen address
        addiu   t7, r0, 0x0008              // Set to 1p Menu ID
        beq     r0, r0, _normal             // branch
        sb      t7, 0x0000(t6)              // Save to next screen ID address

        _remix:
        li      t7, Size.state_table
        sw      r0, 0x0000(t7)              // reset size state to normal
        sw      r0, 0x0004(t7)              // reset size state to normal
        sw      r0, 0x0008(t7)              // reset size state to normal
        sw      r0, 0x000C(t7)              // reset size state to normal

        _normal:
        lui     t7, 0x800A                  // original line 1,
        j       _return                     // return
        lw      t7, 0x50E8(t7)              // original line 2
    }

   // @ Description
   // Displays percent
   scope display_percent: {
       OS.patch_start(0x10D158, 0x8018E8f8)
       j       display_percent
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t7, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t7, 0x0000(t7)              // at = 5 if allstar
       bne     t7, at, _normal             // if not Allstar, proceed as normal
       nop

       li      t7, STAGE_FLAG              // load stage ID address
       lb      t7, 0x0000(t7)              // load current stage of 1p
       bne     t7, r0, _normal             // if not stage zero (normal = Link/Hyrule, allstar= Rest Area), jump to normal
       nop


       jal     0x8010e690                  // display percent
       nop

       _normal:
       lui      t7, 0x800A                 // original line 1
       j       _return                     // return
       lbu      t7, 0x4AE3(t7)             // original line 2
   }

   // Records percent at end of match by using the Heavy Damage Bonus check to determine percent
   scope record_percent: {
       OS.patch_start(0x10EC20, 0x801903C0)
       j       record_percent
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t6, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t6, 0x0000(t6)              // at = 5 if allstar
       bne     t6, at, _normal             // if not Allstar, proceed as normal
       lw      t6, 0x006C(t9)              // original line 1, loads percent

       li      at, allstar_percent         // load address of percent
       sw      t6, 0x0000(at)              // save new percent
       li      at, allstar_limbo           // load limbo
       lw      at, 0x0000(at)              // load limbo
       beqz    at, _normal                 // if not in limbo
       nop
       li      at, allstar_percent
       sw      r0, 0x0000(at)             // save 0 to allstar percent, if in limbo

       _normal:
       j       _return                     // return
       slti    at, t6, 0x00C8              // original line 2, shift logically to determine if percent is 200 or more
    }

   // Change stage ID to 0xD so game ends after final stage in allstar
   scope end_allstar: {
       OS.patch_start(0x10F768, 0x80190F08)
       j       end_allstar
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t1, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t1, 0x0000(t1)              // at = 5 if allstar
       bne     t1, at, _normal             // if not Allstar, proceed as normal
       nop

       li      at, end_game_flag
       lw      at, 0x0000(at)              // load flag to see if can end allstar
       beqz    at, _normal                 // if not stage 0x5, normal
       addiu   t1, r0, 0x000D              // place final stage ID into register
       sb      t1, 0x0017(v1)              // save final stage ID to stage ID address

       _normal:
       lbu     t1, 0x0017(v1)              // original line 1, load current stage id
       j       _return                     // return
       addiu   at, r0, 0x000B              // original line 2
   }

   // Prevents score from being erased
   scope prevent_erase: {
       OS.patch_start(0x520CC, 0x800D68CC)
       j       prevent_erase
       addiu   t3, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t2, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t2, 0x0000(t2)              // at = 5 if allstar
       beq     t2, t3, _allstar            // if not Allstar, proceed as normal
       nop
       _normal:
       sw     r0, 0x0020(s2)               // original line 1, clears score at beginning of 1p
       _allstar:
       j       _return                     // return
       sw     r0, 0x0024(s2)               // original line 2
   }

   // Prevents stock from being reset
   scope stock_prevent: {
       OS.patch_start(0x520d8, 0x800D68D8)
       j       stock_prevent
       addiu   t3, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t2, singleplayer_mode_flag  // t2 = singleplayer flag address
       lw      t2, 0x0000(t2)              // t2 = 5 if allstar
       bne     t2, t3, _normal             // if not Allstar, proceed as normal
       nop

       li      t2, match_begin_flag
       lw      t2, 0x0000(t2)
       bnez    t2, _allstar
       nop

       _normal:
       sb     t9, 0x002B(a0)               // original line 1, sets character's stocks
       _allstar:
       j       _return                     // return
       sb     r0, 0x0D64(at)               // original line 2
    }

   // Prevents total accumulated damage from being reset
   scope damage_prevent: {
       OS.patch_start(0x520E8, 0x800D68E8)
       j       damage_prevent
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      a0, singleplayer_mode_flag  // a0 = singleplayer flag address
       lw      a0, 0x0000(a0)              // a0 = 5 if allstar
       bne     at, a0, _normal             // if not Allstar, proceed as normal
       lui     at, 0x8013                  // original line 1

       li      a0, match_begin_flag
       lw      a0, 0x0000(a0)
       bnez    a0, _allstar                // check to see if allstar has already begun
       nop

       _normal:
       sw       r0, 0x0D6C(at)             // original line 2, clears total damage amount in 1p

       _allstar:
       j       _return                     // return
       nop
    }

   // Reduces costume option so all vanilla characters work
   scope costume_fix: {
       OS.patch_start(0x10C350, 0x8018DAf0)
       j       costume_fix
       addiu   t5, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t7, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t7, 0x0000(t7)              // at = 5 if allstar
       bne     t5, t7, _original           // if not Allstar, proceed as normal
       nop

       lbu     t7, 0x0009(s7)              // load character id
       slti    t7, t7, Character.id.BOSS   // if less than master hand, set to 1
       beqz    t7, _original               // if a Remix character, function as normal
       nop
       slti     t7, v0, 0x4                 // if higher than 4th costume, select another
       bnez     t7, _original               // branch if not less than 0
       nop
       addiu    sp, sp,-0x0010              // allocate stack space
       sw       a0, 0x0004(sp)              // save registers
       sw       t6, 0x0008(sp)              // save registers
       sw       a1, 0x000C(sp)              // save registers
       jal      Global.get_random_int_
       addiu    a0, r0, 0x0004
       lw       a0, 0x0004(sp)              // load registers
       lw       t6, 0x0008(sp)              // load registers
       lw       a1, 0x000C(sp)              // load registers
       addiu    sp, sp, 0x0010              // deallocate stack space

       _original:
       addiu    t5, r0, 0x0001              // original line 1
       j        _return                     // return
       addiu    s0, s0, 0x0001              // original line 2
    }

   // Prevents No Miss Points from being awarded
   scope no_miss: {
       OS.patch_start(0x10EC88, 0x80190428)
       j       no_miss
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t7, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t7, 0x0000(t7)              // at = 5 if allstar
       bne     at, t7, _normal             // if not Allstar, proceed as normal
       nop

       addiu   a2, r0, 0x0001             // Prevents no miss clear
       j       0x80190444                 // jump skipping no miss code
       lbu     t8, 0x0013(t2)             // original line 2

       _normal:
       bnel    a2, r0, _stock_loss        // modified original line 1
       lbu     t8, 0x0013(t2)             // original line 2

       j        _return
       nop

       _stock_loss:
       j       0x80190444                  // take branch taken if you lose a stock
       nop
    }

   // Prevents No Miss Points from being awarded
   scope no_miss_2: {
       OS.patch_start(0x10ECB4, 0x80190454)
       j       no_miss_2
       addiu   at, r0, ALLSTAR_ID
       _return:
       OS.patch_end()

       li      t7, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t7, 0x0000(t7)              // at = 5 if allstar
       bne     at, t7, _normal             // if not Allstar, proceed as normal
       nop

       j       0x80190498                 // jump skipping no miss code
       lw      t8, 0x006C(t5)             // original line 2

       _normal:
       bnel    t6, r0, _stock_loss        // modified original line 1
       lw      t8, 0x006C(t5)             // original line 2

       j        _return
       nop

       _stock_loss:
       j       0x80190498                  // take branch taken if you lose a stock
       nop
    }

    // Prevents Brothers Calamity Points from being awarded
    scope no_calamity: {
       OS.patch_start(0x10F448, 0x80190BE8)
       j       no_calamity
       nop
       _return:
       OS.patch_end()

       li      t8, singleplayer_mode_flag  // at = singleplayer flag address
       lw      t8, 0x0000(t8)              // at = 5 if allstar
       beqz    t8, _normal                 // if 1p, proceed as normal
       lui     t8, 0x8019                  // original line 1

       j       _return                     // return
       addiu   t8, r0, r0                  // clear out preventing bros calamity

       _normal:
       j       _return                     // return
       lw      t8, 0x36A4(t8)              // original line 2
    }

}
