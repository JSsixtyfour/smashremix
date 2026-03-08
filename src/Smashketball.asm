// Smashketball.asm
if !{defined SMASHKETBALL} {
define SMASHKETBALL()
print "included Smashketball.asm\n"

// @ Description
// This file implements Smashketball mode in VS

// TODO:
// - In Game:
//   - AI not suck?

// Texture indexes for scoreboard
// Group 00 Array 02 Track 00 - Minute digit 1
// Group 00 Array 02 Track 01 - Minute digit 2
// Group 00 Array 02 Track 02 - Left score digit 1
// Group 00 Array 02 Track 03 - Left score digit 2
// Group 00 Array 02 Track 04 - Second digit 1
// Group 00 Array 02 Track 05 - Second digit 2
// Group 00 Array 02 Track 06 - Right score digit 1
// Group 00 Array 02 Track 07 - Right score digit 2
//
// Texture 1 Index on all digits:
// 0 = displays 0
// 1 = displays 1
// 2 = displays 2
// 3 = displays 3
// 4 = displays 4
// 5 = displays 5
// 6 = displays 6
// 7 = displays 7
// 8 = displays 8
// 9 = displays 9
// 10 = displays -

// 80046810
//  0x74
//   0x10
//    0x8 - scoreboard
//     0x80 - time minutes tens
//      0x0 - time minutes ones
//      0x0 - home tens
//      0x0 - home ones
//      0x0 - time seconds tens
//      0x0 - time seconds ones
//      0x0 - away tens
//      0x0 - away ones

scope Smashketball {

    scope type {
        constant BASKETBALL(0)
        constant SOCCER(1)
    }

    // @ Description
    // Type of Smashketball (Basketball/Soccer)
    type:
    dw type.BASKETBALL

    // @ Description
    // Boolean indicating if soccer ball should spawn golden
    spawn_golden:
    dw OS.FALSE

    // @ Description
    // The score setting as set on CSS
    winning_score:
    dw 10

    // @ Description
    // The winning score setting options
    score_value_array:
    dw 1, 2, 3, 4, 5, 6, 7, 10, 15, 20, 50, 99, 0x64

    // @ Description
    // Baskets for each player
    scores:
    dw 0, 0, 0, 0

    // @ Description
    // Baskets for each team
    team_scores:
    dw 0, 0, 0, 0

    // @ Description
    // Helps pick the correct winner:
    //  - If a player scores a valid FG, they increment 6 here.
    //  - If no player is attributed the FG, then each teammate gets an equal share of the 6.
    //    e.g. if there are 3 players, each get 2, if 2 players on the team, then each gets 3, and if 1 player, they get 6.
    winner_scores:
    dw 0, 0, 0, 0

    // @ Description
    // Holds the number of players per team
    teammates:
    db 0, 0, 0, 0

    // @ Description
    // Holds the score to assign for unattributed FGs based on number of teammates
    // First slot will hold score to assign if they player was attributed the FG
    winner_score_distribution:
    db 6 // score for attributted FG
    db 6 // score for unattributted FG if 1 player on team
    db 3 // score for unattributted FG if 2 players on team
    db 2 // score for unattributted FG if 3 players on team

    // @ Description
    // Array of colors for Teams
    team_colors:
    dw Color.tag.RED
    dw Color.tag.BLUE
    dw Color.tag.GREEN
    dw Color.tag.YELLOW

    // @ Description
    // Number of consecutive baskets for player
    consecutive_baskets:
    db 0, 0, 0, 0

    // @ Description
    // Scoreboard object
    scoreboard:
    dw 0

    // @ Description
    // Baskets joint
    baskets:
    dw 0

    // @ Description
    // Holds the player spawn for each player
    // See Spawn.asm for explanation
    player_spawns:
    db 2, 0, 0, 0

    // @ Description
    // Runs when entering the CSS
    scope before_css_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, Global.vs.game_mode     // at = game_mode address
        lli     t0, 0x0001                  // t0 = TIME
        sb      t0, 0x0000(at)              // set game mode to TIME
        li      at, 0x8013BDAC              // at = game_mode address
        sw      t0, 0x0000(at)              // set game mode to TIME

        li      at, Global.vs.time          // at = time address
        OS.read_word(winning_score, t0)     // t0 = SMASHKETBALL winning score
        sb      t0, 0x0000(at)              // set winning score
        li      at, 0x8013BD7C              // at = time address
        sw      t0, 0x0000(at)              // set winning score

        li      at, Global.vs.teams         // at = teams address
        lli     t0, OS.TRUE                 // t0 = TRUE
        sb      t0, 0x0000(at)              // set teams to TRUE
        li      at, 0x8013BDA8              // at = teams address
        sw      t0, 0x0000(at)              // set teams

        li      at, Global.vs.stage_select  // at = stage_select
        sb      r0, 0x0000(at)              // set stage_select to FALSE

        li      at, StockMode.stockmode_table // at = stockmode_table address
        sw      r0, 0x0000(at)              // clear stockmode_table p1
        sw      r0, 0x0004(at)              // clear stockmode_table p2
        sw      r0, 0x0008(at)              // clear stockmode_table p3
        sw      r0, 0x000C(at)              // clear stockmode_table p4

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Runs before leaving the CSS and going back to VS Mode menu
    scope leave_css_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, 0x8013BD7C              // at = time address
        OS.read_word(CharacterSelect.saved_nontime_value, t0) // t0 = saved non-time value
        OS.read_word(CharacterSelect.showing_time, t1)
        beqzl   t1, _save_score             // if not showing Time, use time in time picker
        lw      t0, 0x0000(at)              // t0 = time in css time picker
        // if we're here, Time (and not 'Score') is showing and we need to save it
        li      t1, VsRemixMenu.global_time // t1 = global_time address
        lw      at, 0x0000(at)              // at = selected time
        sw      at, 0x0000(t1)              // save time

        _save_score:
        li      t1, winning_score
        sw      t0, 0x0000(t1)              // save SMASHKETBALL winning score

        li      at, Global.vs.stage         // at = stage
        OS.read_word(VsRemixMenu.global_stage, t0) // t0 = saved stage
        sb      t0, 0x0000(at)              // restore stage

        // Restore globals
        li      at, 0x8013BD7C              // at = time address
        OS.read_word(VsRemixMenu.global_time, t0) // t0 = saved time
        sw      t0, 0x0000(at)              // restore time

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Runs before leaving the CSS to start a match
    scope start_match_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, 0x8013BD7C              // at = time address
        OS.read_word(CharacterSelect.showing_time, t0)
        beqzl   t0, _save_score             // if not showing Time, use time in time picker
        lw      t1, 0x0000(at)              // t1 = winning score in css time picker
        // if we're here, Time (and not 'Score') is showing and we need to save it
        li      t0, VsRemixMenu.global_time // t0 = global_time address
        lw      t1, 0x0000(at)              // t1 = selected time
        sw      t1, 0x0000(t0)              // save time
        OS.read_word(CharacterSelect.saved_nontime_value, t1) // t1 = saved non-time value

        _save_score:
        li      t0, winning_score
        sw      t1, 0x0000(t0)              // save time

        OS.read_word(VsRemixMenu.global_time, t1) // t1 = VS time value
        sw      t1, 0x0000(at)              // set time

        li      at, 0x800A4ADF              // at = stage
        lli     t0, Stages.id.SMASHKETBALL  // t0 = SMASHKETBALL stage_id
        OS.read_word(type, t1)              // t1 = type
        bnezl   t1, pc() + 8                // if soccer, use soccer stage
        lli     t0, Stages.id.SOCCER        // t0 = SOCCER stage_id
        sb      t0, 0x0000(at)              // restore stage

        // Set up spawns
        li      t0, player_spawns + 1       // t0 = player_spawns, but starting at p2 (p1 will always be 0)
        li      t6, spawn_table             // t6 = spawn_table
        lli     t7, 0x0000                  // t7 = position in spawn table for home (number of players on home team)
        lli     t8, 0x0003                  // t8 = position in spawn table for away (3 - number of players on away team)
        addiu   t9, r0, -0x0001             // t9 = home team (-1 when not set yet)

        // if present, p1 is always in S3
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + 0x84, t1) // t1 = p1 type
        sltiu   at, t1, 0x0002              // at = 1 if man/cpu
        beqz    at, _p2                     // skip if NA
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + 0x40, t1) // t1 = p1 team (yes, delay slot)
        or      t9, r0, t1                  // t9 = home team
        addiu   t7, t7, 0x0001              // t7 = count of home team players
        _p2:
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + 0xBC + 0x84, t1) // t1 = p2 type
        sltiu   at, t1, 0x0002              // at = 1 if man/cpu
        beqz    at, _p3                     // skip if NA
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + 0xBC + 0x40, t1) // t1 = p2 team (yes delay slot)
        bltzl   t9, pc() + 8                // if home team not set yet, set now
        or      t9, r0, t1                  // t9 = home team

        bne     t9, t1, _away_p2            // if away team, handle differently
        addu    t5, t6, t7                  // t5 = address of spawn for p2
        b       _set_spawn_p2
        addiu   t7, t7, 0x0001              // t7 = next spawn position address for home team

        _away_p2:
        addu    t5, t6, t8                  // t5 = address of spawn for p2
        addiu   t8, t8, -0x0001             // t8 = next spawn position address for away team

        _set_spawn_p2:
        lb      t5, 0x0000(t5)              // t5 = spawn for p2
        sb      t5, 0x0000(t0)              // set p2 spawn

        _p3:
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + (0xBC * 2) + 0x84, t1) // t1 = p3 type
        sltiu   at, t1, 0x0002              // at = 1 if man/cpu
        beqz    at, _p4                     // skip if NA
        addiu   t0, t0, 0x0001              // t0 = p3 spawn address
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + (0xBC * 2) + 0x40, t1) // t1 = p3 team
        bltzl   t9, pc() + 8                // if home team not set yet, set now
        or      t9, r0, t1                  // t9 = home team

        bne     t9, t1, _away_p3            // if away team, handle differently
        addu    t5, t6, t7                  // t5 = address of spawn for p3
        b       _set_spawn_p3
        addiu   t7, t7, 0x0001              // t7 = next spawn position address for home team

        _away_p3:
        addu    t5, t6, t8                  // t5 = address of spawn for p3
        addiu   t8, t8, -0x0001             // t8 = next spawn position address for away team

        _set_spawn_p3:
        lb      t5, 0x0000(t5)              // t5 = spawn for p3
        sb      t5, 0x0000(t0)              // set p3 spawn

        _p4:
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + (0xBC * 3) + 0x84, t1) // t1 = p4 type
        sltiu   at, t1, 0x0002              // at = 1 if man/cpu
        beqz    at, _end                    // skip if NA
        addiu   t0, t0, 0x0001              // t0 = p4 spawn address
        OS.read_word(CharacterSelect.CSS_PLAYER_STRUCT + (0xBC * 3) + 0x40, t1) // t1 = p4 team

        addu    t5, t6, t7                  // t5 = address of spawn for p4
        bnel    t9, t1, _set_spawn_p4       // if away team, handle differently
        addu    t5, t6, t8                  // t5 = address of spawn for p4

        _set_spawn_p4:
        lb      t5, 0x0000(t5)              // t5 = spawn for p4
        sb      t5, 0x0000(t0)              // set p4 spawn

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space

        // home team left to right: 2, 0, 1
        // away team right to left: 3, 1, 0
        spawn_table:
        db 2, 0, 1, 3
    }

    // @ Description
    // Runs when a game starts and sets up SMASHKETBALL. Called from Render.asm.
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      r0, 0x0008(sp)              // initialize Home Team
        sw      r0, 0x000C(sp)              // initialize Away Team

        li      t0, VsRemixMenu.vs_mode_flag
        lw      t0, 0x0000(t0)              // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        beq     t0, t1, _smashketball_mode  // if SMASKETBALL mode, do full setup
        sw      r0, 0x0010(sp)              // set time only flag to FALSE
        OS.read_byte(Global.vs.stage, t0)   // t0 = stage_id
        lli     t1, Stages.id.SMASHKETBALL
        bne     t0, t1, _end                // if not SMASHKETBALL stage, skip
        lli     t2, OS.TRUE
        b       _init_scoreboard            // just set up scoreboard time
        sw      t2, 0x0010(sp)              // set time only flag to TRUE

        _smashketball_mode:
        OS.read_byte(0x800A4AE0, t0)        // t0 = is_suddendeath
        bnez    t0, _initialize_teammates   // if sudden death, don't initialize scores
        li      t0, scores                  // yes, delay slot
        sw      r0, 0x0000(t0)              // initialize score to 0 (p1)
        sw      r0, 0x0004(t0)              // initialize score to 0 (p2)
        sw      r0, 0x0008(t0)              // initialize score to 0 (p3)
        sw      r0, 0x000C(t0)              // initialize score to 0 (p4)

        li      t0, team_scores
        sw      r0, 0x0000(t0)              // initialize score to 0 (red)
        sw      r0, 0x0004(t0)              // initialize score to 0 (blue)
        sw      r0, 0x0008(t0)              // initialize score to 0 (green)
        sw      r0, 0x000C(t0)              // initialize score to 0 (yellow)

        li      t0, winner_scores
        sw      r0, 0x0000(t0)              // initialize score to 0 (p1)
        sw      r0, 0x0004(t0)              // initialize score to 0 (p2)
        sw      r0, 0x0008(t0)              // initialize score to 0 (p3)
        sw      r0, 0x000C(t0)              // initialize score to 0 (p4)

        _initialize_teammates:
        li      t0, teammates
        sw      r0, 0x0000(t0)              // initialize teammates counts

        li      t0, consecutive_baskets
        sw      r0, 0x0000(t0)              // initialize consecutive_baskets for p1-p4

        li      t0, spawn_golden
        sw      r0, 0x0000(t0)              // initialize spawn_golden to FALSE

        Render.register_routine(basketball_main_)

        // Get the team for Home and Away and set up teammates
        addiu   v0, r0, -0x0001             // v0 = Home Team (unset)
        OS.read_word(Global.p_struct_head, at) // at = p1 player struct
        li      t0, teammates
        _loop:
        lw      t1, 0x0004(at)              // t1 = player object
        beqz    t1, _next                   // if no player object, get next player struct
        lbu     t3, 0x000C(at)              // t3 = team

        addu    t4, t0, t3                  // t4 = address of # of teammates for team
        lbu     t5, 0x0000(t4)              // t5 = current # of teammates for team
        addiu   t5, t5, 0x0001              // t5 = new # of teammates for team
        sb      t5, 0x0000(t4)              // update # of teammates

        bltzl   v0, _next                   // if Home not set, set and go to next
        or      v0, t3, r0                  // v0 = Home Team
        bnel    v0, t3, _next               // if current team is not the same as Home Team, set as Away Team
        or      v1, t3, r0                  // v1 = Away Team

        _next:
        lw      at, 0x0000(at)              // at = next player struct
        bnez    at, _loop                   // loop while there are more players to check
        nop

        _save_teams:
        sw      v0, 0x0008(sp)              // save Home Team
        sw      v1, 0x000C(sp)              // save Away Team

        _init_scoreboard:
        // Initialize scoreboard
        Render.register_routine(scoreboard_main_)
        li      t0, scoreboard
        sw      v0, 0x0000(t0)              // save ref to scoreboard object

        lw      at, 0x0010(sp)              // at = time only flag
        sw      at, 0x0084(v0)              // save ref to time only flag

        OS.read_word(0x80046810, t0)        // t0 = map object
        lw      t0, 0x0074(t0)              // t0 = top joint
        lw      t0, 0x0010(t0)              // t0 = joint 1
        lw      t0, 0x0008(t0)              // t0 = scoreboard
        lw      t0, 0x0080(t0)              // t0 = time minutes digit 1
        lw      t1, 0x0000(t0)              // t1 = time minutes digit 2
        lw      t4, 0x0000(t1)              // t4 = home digit 1
        lw      t5, 0x0000(t4)              // t5 = home digit 2
        lw      t2, 0x0000(t5)              // t2 = time seconds digit 1
        lw      t3, 0x0000(t2)              // t3 = time seconds digit 2
        lw      t6, 0x0000(t3)              // t6 = away digit 1
        lw      t7, 0x0000(t6)              // t7 = away digit 2

        sw      t0, 0x0040(v0)              // save ref to time minutes digit 1
        sw      t1, 0x0044(v0)              // save ref to time minutes digit 2
        sw      t2, 0x0048(v0)              // save ref to time seconds digit 1
        sw      t3, 0x004C(v0)              // save ref to time seconds digit 2

        sw      t4, 0x0050(v0)              // save ref to home digit 1
        sw      t5, 0x0054(v0)              // save ref to home digit 2
        sw      t6, 0x0058(v0)              // save ref to away digit 1
        sw      t7, 0x005C(v0)              // save ref to away digit 2

        beqz    at, _teams                  // if not time only mode, set up teams
        lli     t0, 10                      // t0 = index of dash

        // here, make the scores dashes
        sh      t0, 0x0080(t4)              // update home digit 1 to dash
        sh      t0, 0x0080(t5)              // update home digit 2 to dash
        sh      t0, 0x0080(t6)              // update away digit 1 to dash
        b       _end                        // skip the rest
        sh      t0, 0x0080(t7)              // update away digit 2 to dash

        _teams:
        lw      t0, 0x0008(sp)              // t0 = Home Team
        sw      t0, 0x0068(v0)              // save Home Team
        lw      t1, 0x000C(sp)              // t1 = Away Team
        sw      t1, 0x006C(v0)              // save Away Team
        sll     t0, t0, 0x0002              // t0 = offset to Home Team score
        sll     t1, t1, 0x0002              // t1 = offset to Away Team score
        li      at, team_scores
        addu    t3, at, t0                  // t3 = Home Team score address
        sw      t3, 0x0060(v0)              // save ref to Home Team score
        addu    t3, at, t1                  // t3 = Away Team score address
        sw      t3, 0x0064(v0)              // save ref to Away Team score

        li      at, team_colors
        addu    t0, at, t0                  // t0 = Home Team color address
        lw      t0, 0x0000(t0)              // t0 = Home Team color
        addu    t1, at, t1                  // t1 = Away Team color address
        lw      t1, 0x0000(t1)              // t1 = Away Team color
        sw      t0, 0x0058(t4)              // set home digit 1 color
        sw      t0, 0x0058(t5)              // set home digit 2 color
        sw      t1, 0x0058(t6)              // set away digit 1 color
        sw      t1, 0x0058(t7)              // set away digit 2 color

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Prevents the basketball from despawning when not picked up
    scope prevent_despawn: {
        OS.patch_start(0xEA004, 0x8016F5C4)
        jal     prevent_despawn
        lli     t2, VsRemixMenu.mode.SMASHKETBALL
        _return:
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t3)
        bne     t3, t2, _end                // if not Smashketball, skip
        addiu   t0, t9, 0xFFFF              // original line 1 - ip->pickup_wait--;

        lli     t2, Item.Basketball.id      // Basketball
        lw      t3, 0x000C(a2)              // t3 = item_id
        beql    t3, t2, _end                // if Basketball, don't decrement
        or      t0, t9, r0                  // t0 = use current pickup_wait value

        _end:
        jr      ra
        sll     t2, t0, 0x0004              // original line 2
    }

    // 8010BC54 + 4C0
    // this is at the bottom of cmManagerUpdateFollowEntities
    // this function just checked all players and all projectiles (with the camera follow flag)
    // so now we check all items. If we find the Basketball, add it to the camera follow logic
    scope camera_follow: {
        OS.patch_start(0x87914, 0x8010C114)
        jal     camera_follow
        nop
        _return:
        OS.patch_end()

        // In vanilla, projectiles followed by the camera use 1000.0 as padding
        constant CAMERA_PADDING(0x447A) // 1000.0f

        lli     t2, VsRemixMenu.mode.SMASHKETBALL
        OS.read_word(VsRemixMenu.vs_mode_flag, t3)
        bne     t3, t2, _end                // if not Smashketball, skip
        nop

        _get_item:
        OS.read_word(0x80046700, t0)        // t0 = item object linked list head
        beqz    t0, _end                    // if first item is already none, exit
        nop
        lli     t1, Item.Basketball.id      // Basketball

        _loop:
        lw      t2, 0x0084(t0)              // t2 = item struct
        lw      at, 0x000C(t2)              // at = item_id

        bne     at, t1, _loop_get_next      // if not Basketball, skip
        lw      t1, 0x01E8(t2)              // t1 = respawn flag

        bnez    t1, _end                    // if respawn flag is set, exit
        nop

        lw      t1, 0x0074(t0)              // t1 = item position struct
        addiu   t1, t1, 0x001C              // t1 = position array [x, y, z]
        nop

        x_check:
        lui     at, CAMERA_PADDING // at = CAMERA_PADDING
        mtc1    at, f2 // f2 = CAMERA_PADDING

        lwc1    f0, 0x0(t1) // ball X

        left_check:
        // left = f22
        sub.s   f4, f0, f2 // f4 = (ball X) - CAMERA_PADDING

        c.lt.s  f4, f22
        nop
        bc1fl   left_check_end
        nop

        mov.s   f22, f4
        left_check_end:

        right_end:
        // right = f24
        add.s   f4, f0, f2 // f4 = (ball X) + CAMERA_PADDING

        c.lt.s  f24, f4
        nop
        bc1fl   right_check_end
        nop

        mov.s   f24, f4
        right_check_end:

        y_check:
        lwc1    f0, 0x4(t1) // ball Y

        bottom_check:
        // bottom = f26
        // sub.s   f4, f0, f2 // f4 = (ball Y) - CAMERA_PADDING

        // for bottom, just make sure to always show the floor
        // we don't wanna track the ball going far down under the stage
        lui     at, 0xC47A
        mtc1    at, f4 // f4 = -1000

        c.lt.s  f4, f26
        nop
        bc1fl   bottom_check_end
        nop

        mov.s   f26, f4
        bottom_check_end:

        top_end:
        // top = f28
        add.s   f4, f0, f2 // f4 = (ball Y) + CAMERA_PADDING

        c.lt.s  f28, f4
        nop
        bc1fl   top_check_end
        nop

        mov.s   f28, f4
        top_check_end:

        _loop_get_next:
        lw      t0, 0x0004(t0)              // t0 = next item object
        bnez    t0, _loop                   // if next object exists, loop
        lli     t1, Item.Basketball.id      // Basketball

        _end:
        sub.s f10, f24, f22 // original line 1
        lui at, 0x3F00 // original line 2

        jr      ra
        nop
    }

    // @ Description
    // Ensures a basketball is always present
    scope basketball_main_: {
        constant HOOP_OFFSET(0x43858000)    // 267
        constant HOOP_MIN(0x455B)           // 3504
        // constant HOOP_MAX(0x4584)           // 4224

        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      r0, 0x000C(sp)              // indicates if we should initialize item

        OS.read_word(0x8003B6E4, t0)        // t0 = frames elapsed since screen load
        sltiu   t0, t0, 0x0135              // t0 = 1 if not ready to spawn the ball yet
        bnez    t0, _end                    // if not ready to spawn the ball, skip
        nop

        _get_item:
        OS.read_word(0x80046700, t0)        // t0 = item object linked list head
        _loop:
        beqz    t0, _create                 // if no basketball object, need to create one
        lli     t1, Item.Basketball.id      // Basketball
        lw      t2, 0x0084(t0)              // t2 = item struct
        lw      t2, 0x000C(t2)              // t2 = item_id
        beq     t2, t1, _check_initialize   // if Basketball, don't need to create
        nop
        b       _loop
        lw      t0, 0x0004(t0)              // t0 = next item object

        _create:
        // Spawn Basketball
        OS.read_word(0x801313F0, t0)        // t0 = pointer for barrels
        sw      t0, 0x0008(sp)              // save pointer

        lli     a1, 0                       // left side of platform
        lui     a2, 0x4500                  // above plat
        OS.read_word(spawn_golden, t7)      // t7 = 1 if soccer ball should spawn golden
        bnezl   t7, pc() + 8                // if spawning golden, set to higher y
        lui     a2, 0x45B0                  // high above plat
        lli     a0, Item.Basketball.id      // Basketball
        lli     a3, Stages.id.DREAM_LAND    // original stage ID
        lli     t1, 0x0000                  // no routine
        jal     Hazards.add_item_
        lli     t0, 0x0000                  // no hover effect

        li      t0, spawn_golden
        sw      r0, 0x0000(t0)              // reset spawn_golden to FALSE

        lli     t1, OS.TRUE
        sw      t1, 0x000C(sp)              // set to TRUE for initialize item

        lw      t0, 0x0008(sp)              // t0 = pointer for barrels
        lui     t1, 0x8013
        b       _get_item                   // it's dumb but works - need to get item obj
        sw      t0, 0x13F0(t1)              // restore pointer for barrels

        _check_initialize:
        sw      t0, 0x0010(sp)              // save item
        lw      t1, 0x000C(sp)              // t1 = initialize item?
        beqz    t1, _get_position           // if not just created, skip
        nop

        _get_position:
        lw      t1, 0x0040(t0)              // t1 = 0 if not passed through hoop yet
        bnez    t1, _end                    // if the ball has already been through the hoop, skip
        lw      at, 0x0084(t0)              // at = item special struct
        lw      t2, 0x0008(at)              // t2 = owner player object
        beqz    t2, _not_held               // if no owner, it's not being held
        lw      t1, 0x0074(t0)              // t1 = item position struct
        lw      t3, 0x0084(t2)              // t3 = player struct
        lw      t2, 0x084C(t3)              // t2 = held item
        bne     t2, t0, _not_held           // if the player is not still holding the item, skip
        sw      t3, 0x0014(sp)              // save player struct
        // if here, then we need to get the player's item joint's position
        sw      r0, 0x0020(sp)              // initialize x to 0 for position array
        sw      r0, 0x0024(sp)              // initialize y to 0 for position array
        sw      r0, 0x0028(sp)              // initialize z to 0 for position array

        lw      a0, 0x0084(t1)              // a0 = player's joint
        jal     0x800EDF24                  // gmCollisionGetFighterPartsWorldPosition
        addiu   a1, sp, 0x0020              // a1 = position array

        addiu   t1, sp, 0x0020              // t1 = position array, updated by gmCollisionGetFighterPartsWorldPosition
        lw      t3, 0x0014(sp)              // t3 = player struct
        b       _check_position
        lw      t0, 0x0010(sp)              // t0 = item

        _not_held:
        addiu   t1, t1, 0x001C              // t1 = position array [x, y, z]

        _check_position:
        OS.read_word(type, t5)              // t5 = type
        bnez    t5, _soccer                 // if soccer, go to goals detection
        sw      t1, 0x0014(sp)              // save position array

        // figure out if above or below the rim
        OS.read_word(baskets, t5)           // t5 = baskets joint
        lwc1    f4, 0x0020(t5)              // f4 = baskets y
        li      t4, HOOP_OFFSET
        mtc1    t4, f2                      // f2 = offset to hoop
        sub.s   f4, f4, f2                  // f4 = y when ball passes through hoop
        lwc1    f2, 0x0004(t1)              // f2 = ball y
        c.lt.s  f2, f4                      // check if ball is under the rim
        lli     t3, OS.FALSE                // t3 = FALSE = above the rim flag
        bc1fl   pc() + 8                    // if the ball isn't under the rim, then it's above
        lli     t3, OS.TRUE                 // t3 = TRUE = above the rim flag

        lw      t2, 0x0050(t0)              // t2 = prior frame above rim flag

        // if above -> below and under hoop, then score
        // if below -> above and not above hoop, then set above flag
        // else do nothing
        beq     t2, t3, _end                // if above rim flag didn't change, skip
        sw      t3, 0x0050(t0)              // update above rim flag
        lwc1    f0, 0x0000(t1)              // f0 = x = x2
        lwc1    f10, 0x0060(t0)             // f10 = previous x = x1
        lwc1    f12, 0x0064(t0)             // f12 = previous y = y1
        sub.s   f14, f0, f10                // f14 = x2 - x1
        mtc1    r0, f20                     // f20 = 0
        c.eq.s  f14, f20                    // check if x2 - x1 = 0
        sub.s   f16, f2, f12                // f16 = y2 - y1
        bc1tl   _compare_to_hoop_x          // if x2 - x1 = 0, then just use x2
        abs.s   f2, f0                      // f2 = |x|

        // otherwise calculate the inverse of the slope and plug and chug, baby!
        // we do the inverse so we can use mul.s instead of div.s (mul.s is faster)
        // (y2 - y1)
        // m (slope) = (y2 - y1) / (x2 - x1)
        // 1/m = (x2 - x1) / (y2 - y1)
        c.eq.s  f16, f20                    // check if y2 - y1 = 0
        nop
        bc1tl   _compare_to_hoop_x          // if y2 - y1 = 0, then just use x2
        abs.s   f2, f0                      // f2 = |x|
        div.s   f18, f14, f16               // f18 = 1/m = (x2 - x1) / (y2 - y1)
        // xhoop = (yhoop - y2)/m + x2
        sub.s   f6, f4, f2                  // f6 = yhoop - y2
        mul.s   f6, f6, f18                 // f6 = (yhoop - y2)/m
        add.s   f0, f6, f0                  // f0 = x at yhoop
        abs.s   f2, f0                      // f2 = |x|

        _compare_to_hoop_x:
        lui     t4, HOOP_MIN
        mtc1    t4, f4                      // f4 = hoop min x - ball must be past this
        c.lt.s  f2, f4                      // check if ball is passing through hoop
        lli     t4, OS.TRUE                 // t4 = TRUE = passing through hoop flag
        bc1tl   pc() + 8                    // if ball is not passing through hoop, skip
        lli     t4, OS.FALSE                // t4 = FALSE = passing through hoop flag

        beqz    t3, _check_if_below        // if lower than the rim, check if below hoop
        nop
        // here, ball is higher than the rim, so check if passed through the hoop
        bnezl   t4, _end                    // if ball passed through the hoop, set scoreable to FALSE
        sw      r0, 0x0068(t0)              // update scoreable flag to FALSE
        // here, ball did not pass through the hoop, so we can set scoreable to TRUE
        b       _end
        sw      t3, 0x0068(t0)              // update scoreable flag to TRUE

        _check_if_below:
        // here, ball is lower than the rim, so check if passed through the hoop
        beqz    t4, _end                    // if ball did not pass through the hoop, skip
        lw      t4, 0x0068(t0)              // t4 = scoreable flag

        // here, ball is under the hoop, so if it's scoreable, it's a score!
        bnez    t4, _scored                 // if scoreable, score!
        nop
        b       _end                        // no score, so skip
        nop

        _soccer:
        lwc1    f0, 0x0000(t1)              // f0 = x
        abs.s   f2, f0                      // f2 = |x|
        lui     t4, 0x4586                  // t4 = x if through goal
        mtc1    t4, f4                      // f2 = x if through goal
        c.le.s  f4, f2                      // check if through goal
        nop
        bc1f    _end                        // if ball is not passing through goal, skip
        nop
        // here, ball is through the goal, so it's a score!

        _scored:
        mtc1    r0, f4                      // f4 = 0
        c.lt.s  f0, f4                      // check if left hoop or right hoop
        lli     t4, 0x0001                  // t4 = 1 (right hoop)
        bc1tl   pc() + 8                    // if passed through left hoop, set t4 to -1
        addiu   t4, r0, -0x0001             // t4 = -1 (left hoop)

        sw      t4, 0x0040(t0)              // set scored hoop

        // now update team scores
        OS.read_word(scoreboard, t2)        // t2 = scoreboard object
        addiu   at, t2, 0x0060              // at = Home Score pointer
        bltzl   t4, pc() + 8                // if left hoop, use Away score
        addiu   at, at, 0x0004              // at = Away Score pointer
        lw      t4, 0x0008(at)              // t4 = team that scored
        lw      at, 0x0000(at)              // at = score address
        lw      t1, 0x0000(at)              // t1 = current score
        lli     a3, 0x0001                  // a3 = normal goal amount
        lw      t2, 0x005C(t0)              // t2 = is_golden flag
        bnezl   t2, pc() + 8                // if golden, goal amount is higher
        lli     a3, 0x0003                  // a3 = golden goal amount
        addu    t1, t1, a3                  // t1 = new score
        sw      t1, 0x0000(at)              // update score

        // determine if the FG is attributed to a player
        lw      t1, 0x0084(t0)              // t1 = item struct
        lw      t1, 0x0008(t1)              // t1 = owner, maybe
        beqz    t1, _update_winner_scores   // if no owner, not attributed
        nop
        lw      at, 0x0084(t1)              // t1 = player struct
        lbu     t2, 0x000C(at)              // t2 = team
        beq     t2, t4, _update_player_scores // if the right team, can be attributed
        nop                                 // so skip the unattributed score updates below

        _update_winner_scores:
        // This is an unattributed FG, so update winner scores for each port on the team that just scored
        OS.read_word(Global.p_struct_head, at) // at = p1 player struct
        li      t7, winner_scores
        li      a1, winner_score_distribution
        li      a2, teammates
        addu    a2, a2, t4                  // a2 = address of number of teammates
        lbu     a2, 0x0000(a2)              // a2 = number of teammates
        addu    a1, a1, a2                  // a1 = address of amount to increment
        lbu     a1, 0x0000(a1)              // a1 = amount to increment
        multu   a1, a3                      // mflo = amount to increment, accounting for golden
        mflo    a1                          // a1 = amount to increment
        _loop_winner_scores:
        lw      t1, 0x0004(at)              // t1 = player object
        beqz    t1, _next                   // if no player object, get next player struct
        lbu     t3, 0x000C(at)              // t3 = team

        bne     t3, t4, _next               // if not the team that scored, skip
        lbu     t3, 0x000D(at)              // t3 = port
        sll     t3, t3, 0x0002              // t3 = offset for port
        addu    t3, t7, t3                  // t3 = winner score address
        lw      t5, 0x0000(t3)              // t5 = current winner score
        addu    t5, t5, a1                  // t5 = winner score incremented
        sw      t5, 0x0000(t3)              // update winner score

        _next:
        lw      at, 0x0000(at)              // at = next player struct
        bnez    at, _loop_winner_scores     // loop while there are more players to check
        nop

        _update_player_scores:
        // update player score if they were the owner and score a point for their team
        lw      t1, 0x0084(t0)              // t1 = item struct
        lw      t1, 0x0008(t1)              // t1 = owner, maybe
        beqzl   t1, _gfx                    // if no owner, no scoring!
        sw      r0, 0x000C(sp)              // no crowd noise
        lw      at, 0x0084(t1)              // t1 = player struct
        lbu     t2, 0x000C(at)              // t2 = team
        lli     t1, 0x0267                  // t1 = crowd groan fgm_id
        bnel    t2, t4, _gfx                // if not the right team, skip
        sw      t1, 0x000C(sp)              // set crowd noise

        lli     t1, 0x0272                  // t1 = crowd cheer fgm_id
        sw      t1, 0x000C(sp)              // set crowd noise

        lbu     t1, 0x000D(at)              // t1 = port
        li      t0, consecutive_baskets
        addu    t3, t0, t1                  // t3 = address of consecutive_baskets for scoring player
        lbu     t4, 0x0000(t3)              // t4 = current consecutive baskets value
        sw      r0, 0x0000(t0)              // clear all consecutive baskets values
        addiu   t4, t4, 0x0001              // t4 = updated consecutive baskets value
        sb      t4, 0x0000(t3)              // update consecutive baskets value

        sll     t3, t1, 0x0002              // t3 = offset to score
        li      t0, scores
        addu    t0, t0, t3                  // t0 = address of score
        lw      t1, 0x0000(t0)              // t1 = current score
        addu    t1, t1, a3                  // t1 = score incremented
        sw      t1, 0x0000(t0)              // update score
        li      t0, winner_scores
        addu    t0, t0, t3                  // t0 = address of winner score
        lw      t1, 0x0000(t0)              // t1 = current score
        OS.read_byte(winner_score_distribution, t2) // t2 = amount to increment
        multu   t2, a3                      // mflo = amount to increment, accounting for golden
        mflo    t2                          // t2 = amount to increment
        addu    t1, t1, t2                  // t1 = score incremented
        sw      t1, 0x0000(t0)              // update score

        sltiu   t3, t4, 0x0003              // t3 = 0 if 3 or more consecutive baskets in a row
        bnez    t3, _gfx                    // if less than 3 consecutive baskets, skip
        lui     a1, 0x4320                  // a1 = 0x43200000 = 160.0F

        // Start chanting - since a1 >= 160.0F, crowd will chant
        // Note that a0 is not used in vanilla so we hijack it
        lli     a0, 0x1234                  // a0 = custom value indicating it's OK to force (see hook below)
        lw      a2, 0x0018(at)              // a2 = player number
        jal     0x80164AB0                  // ftPublicityTryStartChant(GObj *gobj, f32 knockback, s32 player_number)
        addiu   sp, sp, -0x0010             // allocate stack (it's not stack safe)
        addiu   sp, sp, 0x0010              // deallocate stack

        _gfx:
        lw      a0, 0x0014(sp)              // a0 = position array
        lw      t0, 0x0010(sp)              // t0 = item
        lw      t1, 0x0084(t0)              // t1 = item struct
        lw      t1, 0x0008(t1)              // t1 = owner
        OS.read_word(type, t5)              // t5 = type
        beqzl   t5, _create_gfx             // if basketball, use lower blastzone gfx
        lli     a2, 0x0000                  // a2 = type

        lw      t4, 0x0040(t0)              // t4 = scored hoop (-1 = left, 1 = right)
        lli     a2, 0x0002
        subu    a2, a2, t4                  // a2 = 3 if left, 1 if right

        _create_gfx:
        beqzl   t1, _create_gfx_for_real    // if no owner, use default gfx
        lli     a1, 0x0000                  // a1 = port = use port 0 for default

        lw      t1, 0x0084(t1)              // t1 = player struct
        lbu     a1, 0x000D(t1)              // a1 = port

        _create_gfx_for_real:
        jal     0x801021C0                  // efManagerDeadExplodeMakeEffect(Vec3f *pos, s32 player, u32 type)
        nop

        jal     0x800269C0                  // play sound
        lli     a0, 0x0118                  // a0 = target break sound

        lw      a0, 0x000C(sp)              // a0 = crowd noise fgm_id
        beqz    a0, _end                    // if no crowd noise set, skip
        nop
        jal     0x800269C0                  // play sound
        nop

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Ensures a scoreboard always displays correct time/score
    // 0x0040(v0) - time minutes digit 1
    // 0x0044(v0) - time minutes digit 2
    // 0x0048(v0) - time seconds digit 1
    // 0x004C(v0) - time seconds digit 2
    // 0x0050(v0) - home digit 1
    // 0x0054(v0) - home digit 2
    // 0x0058(v0) - away digit 1
    // 0x005C(v0) - away digit 2
    // 0x0060(v0) - home score
    // 0x0064(v0) - away score
    // 0x0084(v0) - time only flag
    scope scoreboard_main_: {
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        OS.read_byte(Global.vs.time, t0)    // t0 = time setting
        lli     t1, 100                     // t1 = infinity
        bne     t0, t1, _timer              // if not infinity, update timer
        lli     t0, 10                      // t0 = index of dash

        lw      t1, 0x0040(a0)              // t1 = minutes digit 1 image struct
        sh      t0, 0x0080(t1)              // update minutes digit 1
        lw      t1, 0x0044(a0)              // t1 = minutes digit 2 image struct
        sh      t0, 0x0080(t1)              // update minutes digit 2
        lw      t1, 0x0048(a0)              // t1 = seconds digit 1 image struct
        sh      t0, 0x0080(t1)              // update seconds digit 1
        lw      t1, 0x004C(a0)              // t1 = seconds digit 2 image struct
        b       _scores                     // update scores next
        sh      t0, 0x0080(t1)              // update seconds digit 2

        _timer:
        // Timer
        // Can't use sIFCommonTimerDigitsInterface because the scoreboard is drawn before it's updated
        // li      at, 0x801317C8              // at = sIFCommonTimerDigitsInterface[4]

        // So calculate it manually
        addiu   at, sp, 0x0010              // at = timerDigits[4]
        OS.read_word(0x800A50E8, t7)        // t7 = gSCManagerBattleState
        lw      v0, 0x0014(t7)              // v0 = time_remain not decremented yet
        addiu   v0, v0, -0x0001             // v0 = time_remain
        OS.read_word(0x801317E0, t5)        // t5 = sIFCommonTimerLimit
        li      a3, 0x8012EF38              // a3 = dIFCommonTimerDigitsUnitLengths[4]
        bnel    t5, v0, pc() + 8            // if time_remain != sIFCommonTimerLimit, add 59
        addiu   v0, v0, 0x003B              // v0 = time_remain

        lli     t2, 0x0000                  // t2 = 0
        _loop:
        lhu     t1, 0x0000(a3)              // t1 = dIFCommonTimerDigitsUnitLengths[i]
        div     v0, t1                      // mflo = digit = time_remain / dIFCommonTimerDigitsUnitLengths[i]
        mflo    t0                          // t0 = digit = time_remain / dIFCommonTimerDigitsUnitLengths[i]
        multu   t0, t1                      // mflo = digit * dIFCommonTimerDigitsUnitLengths[i]
        mflo    t8                          // t8 = digit * dIFCommonTimerDigitsUnitLengths[i]
        subu    v0, v0, t8                  // v0 = time_remain - (digit * dIFCommonTimerDigitsUnitLengths[i]) = new time_remain
        sb      t0, 0x0000(at)              // timerDigits[i] = digit
        addiu   t2, t2, 0x0001              // t2++
        sltiu   t0, t2, 0x0004              // t0 = 1 if more digits to do
        addiu   at, at, 0x0001              // at = next timerDigit address
        bnez    t0, _loop                   // if more digits, loop
        addiu   a3, a3, 0x0002              // a3 = next dIFCommonTimerDigitsUnitLength address

        addiu   at, sp, 0x0010              // at = timerDigits[4]
        lbu     t0, 0x0000(at)              // t0 = minutes digit 1
        lw      t1, 0x0040(a0)              // t1 = minutes digit 1 image struct
        sh      t0, 0x0080(t1)              // update minutes digit 1
        lbu     t0, 0x0001(at)              // t0 = minutes digit 2
        lw      t1, 0x0044(a0)              // t1 = minutes digit 2 image struct
        sh      t0, 0x0080(t1)              // update minutes digit 2
        lbu     t0, 0x0002(at)              // t0 = seconds digit 1
        lw      t1, 0x0048(a0)              // t1 = seconds digit 1 image struct
        sh      t0, 0x0080(t1)              // update seconds digit 1
        lbu     t0, 0x0003(at)              // t0 = seconds digit 2
        lw      t1, 0x004C(a0)              // t1 = seconds digit 2 image struct
        sh      t0, 0x0080(t1)              // update seconds digit 2

        _scores:
        // Scores
        lw      at, 0x0084(a0)              // at = time only flag
        bnez    at, _end                    // if time only mode, skip
        lw      t0, 0x0060(a0)              // t0 = Home Team score address
        lw      t0, 0x0000(t0)              // t0 = Home Team score
        sltiu   t1, t0, 100                 // t1 = 0 if score is >99
        bnez    t1, _get_home_score
        lli     t1, 9                       // t1 = 9
        mthi    t1                          // mfhi = 9 (Home digit 2)
        b       _set_home_score
        lli     t0, 9                       // t0 = 9 (Home digit 1)
        _get_home_score:
        lli     t1, 10                      // t1 = 10
        div     t0, t1                      // score divided by 10
        mflo    t0                          // t0 = Home digit 1
        _set_home_score:
        lw      t1, 0x0050(a0)              // t1 = Home digit 1 image struct
        sh      t0, 0x0080(t1)              // update Home digit 1
        mfhi    t0                          // t0 = Home digit 2
        lw      t1, 0x0054(a0)              // t1 = Home digit 2 image struct
        sh      t0, 0x0080(t1)              // update Home digit 2
        lw      t0, 0x0064(a0)              // t0 = Away Team score address
        lw      t0, 0x0000(t0)              // t0 = Away Team score
        sltiu   t1, t0, 100                 // t1 = 0 if score is >99
        bnez    t1, _get_away_score
        lli     t1, 9                       // t1 = 9
        mthi    t1                          // mfhi = 9 (Home digit 2)
        b       _set_away_score
        lli     t0, 9                       // t0 = 9 (Home digit 1)
        _get_away_score:
        lli     t1, 10                      // t1 = 10
        div     t0, t1                      // score divided by 10
        mflo    t0                          // t0 = Away digit 1
        _set_away_score:
        lw      t1, 0x0058(a0)              // t1 = Away digit 1 image struct
        sh      t0, 0x0080(t1)              // update Away digit 1
        mfhi    t0                          // t0 = Away digit 2
        lw      t1, 0x005C(a0)              // t1 = Away digit 2 image struct
        sh      t0, 0x0080(t1)              // update Away digit 2

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // This ends the match once a team reaches the score target
    scope check_match_end_: {
        OS.read_word(scoreboard, t0)        // t0 = scoreboard object
        beqz    t0, _normal                 // if not set yet, skip
        nop

        lw      t1, 0x0060(t0)              // t1 = Home score address
        lw      t1, 0x0000(t1)              // t1 = home score
        lw      t2, 0x0064(t0)              // t2 = Away score address

        OS.read_byte(0x800A4AE0, t0)        // t0 = is_suddendeath
        bnez    t0, _sudden_death           // if sudden death, do a different check
        lw      t2, 0x0000(t2)              // t2 = away score

        OS.read_word(winning_score, at)     // at = target score
        lli     t3, 100                     // t3 = infinity
        beq     at, t3, _no_winner          // if time is infinity, no winner EV-VER
        sltu    t3, t1, at                  // t3 = 0 if at or above target score
        beqz    t3, _winner                 // if Home reached target score, they win!
        sltu    t3, t2, at                  // t3 = 0 if at or above target score
        beqz    t3, _winner                 // if Away reached target score, they win!
        nop
        b       _no_winner                  // Otherwise, no winner yet
        nop

        _sudden_death:
        bne     t1, t2, _winner             // if the scores are no longer tied, someone won!
        nop                                 // Otherwise, no winner yet

        _no_winner:
        _normal:
        jr      ra
        nop

        _winner:
        li      t9, 0x80114C80              // t9 = GAMESET routine
        j       0x80113218                  // trigger match end
        nop
    }

    // @ Description
    // Plays buzzer at match end
    scope play_end_buzzer_: {
        OS.patch_start(0x8F040, 0x80113840)
        j       play_end_buzzer_
        sh      a0, 0x1808(at)              // original line 1 - store announcer fgm_id
        _return:
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t0)
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        bne     t0, t1, _end                // if not Smashketball, skip
        lli     t0, 0x0431                  // t0 = end buzzer fgm_id

        sh      t0, 0x180A(at)              // add end buzzer fgm_id to fgm queue
        addiu   v0, v0, 0x0001              // v0 = number of fgms to play, incremented for end buzzer

        _end:
        j       _return
        addiu   t9, v0, 0x0001              // original line 2 - t9 = number of fgms to play
    }

    // @ Description
    // Allows chants to play when a player scores 3+ in a row by skipping damage and wait checks
    scope force_chant_: {
        OS.patch_start(0xDF520, 0x80164AE0)
        jal     force_chant_
        lli     t7, 0x1234                  // t7 = custom value indicating it's OK to force
        OS.patch_end()

        lw      t6, 0x0018(sp)              // t6 = a0 value passed in to 0x80164AB0
        bne     t6, t7, _normal             // if not the custom value, then return normally
        lui     t7, 0x8019                  // original line 1

        lw      t8, 0x0020(sp)              // original line 7
        j       0x80164B14                  // skip damage and wait timer checks
        lui     t9, 0x8019                  // original line 8

        _normal:
        jr      ra
        lw      t6, 0x002C(v1)              // original line 2
    }

    // @ Description
    // Makes CPUs seek the ball a bit offset from their goal
    // ftComputerCheckFindTarget 8013295C+1E8
    scope ai_ball_behavior_: {
        OS.patch_start(0xAD584, 0x80132B44)
        jal     ai_ball_behavior_
        nop
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t5) // t5 = vs_mode_flag
        lli     t6, VsRemixMenu.mode.SMASHKETBALL
        bne     t5, t6, _end                // if not Smashketball, skip
        addiu   v1, s1, 0x01CC              // v1 = FTComputer struct

        // get ball coords
        OS.read_word(0x80046700, t0)        // t0 = item object linked list head
        _loop:
        beqz    t0, _end                    // if no basketball object, skip
        lli     t1, Item.Basketball.id      // Basketball
        lw      t3, 0x0084(t0)              // t3 = item struct
        lw      t2, 0x000C(t3)              // t2 = item_id
        beq     t2, t1, _get_coords         // if Basketball, get coords
        nop
        b       _loop
        lw      t0, 0x0004(t0)              // t0 = next item object

        _get_coords:
        lw      t1, 0x0074(t0)              // t1 = position struct
        lwc1    f22, 0x0020(t1)             // f22 = y
        swc1    f22, 0x0064(v1)             // set target_pos.y
        lwc1    f20, 0x001C(t1)             // f20 = x

        // using team, offset so the CPU seeks a position slightly behind/in front of the ball so attacks will
        // tend to move the ball in the preferred direction
        lbu     t0, 0x000C(s1)              // t0 = team
        lw      t3, 0x0068(t3)              // t3 = home team
        lui     t2, 0x43C8                  // t2 = 400
        beql    t0, t3, pc() + 8            // if home team, then need to go left instead of right
        lui     t2, 0xC3C8                  // t2 = -400
        mtc1    t2, f0                      // f0 = offset
        add.s   f20, f20, f0                // f20 = ball x + offset
        swc1    f20, 0x0060(v1)             // set target_pos.x

        // calculate distance
        sub.s   f0, f26, f20                // f0 = x distance
        sub.s   f2, f28, f22                // f2 = y distance
        mul.s   f18, f0, f0                 // f18 = (x distance)^2
        mul.s   f4, f2, f2                  // f4 = (y distance)^2
        add.s   f24, f18, f4                // distance = square_xy

        _end:
        mov.s   f12, f24                  // original line 1
        jr      ra
        ori     t0, t9, 0x40              // original line 2
    }

    // @ Description
    // Makes CPUs consider the ball as their target when checking attack ranges
    // The CPUs use the target's current speed and other factors to predict positions
    // and check which moves to use
    // 80132EC8 + 27C
    scope ai_ball_attack_range: {
        OS.patch_start(0xADB84, 0x80133144)
        j       ai_ball_attack_range
        lw      t9, 0x0(s2) // original line 1
        _return:
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.SMASHKETBALL
        bne     t0, t1, _end                // if not Smashketball, skip
        nop

        // get ball coords
        OS.read_word(0x80046700, t0)        // t0 = item object linked list head
        _loop:
        beqz    t0, _end                    // if no basketball object, skip
        lli     t1, Item.Basketball.id      // Basketball
        lw      t2, 0x0084(t0)              // t2 = item struct
        lw      t2, 0x000C(t2)              // t2 = item_id
        beq     t2, t1, _found_ball         // if Basketball, jump
        nop
        b       _loop
        lw      t0, 0x0004(t0)  // t0 = next item object

        _found_ball:
        lw      t2, 0x0084(t0) // t2 = item struct

        lui     t3, 4348 // 200.0
        sw      t3, 0x178(sp) // hurtbox_detect_width
        sw      t3, 0x174(sp) // hurtbox_detect_height

        lw      t1, 0x0074(t0)  // t1 = position struct
        lw      t3, 0x001C(t1) // t3 = x
        sw      t3, 0x194(sp) // target pos x
        lw      t3, 0x0020(t1) // f22 = y
        sw      t3, 0x190(sp) // target pos y

        lw      t3, 0x002C(t2) // f4 = x velocity
        sw      t3, 0x18c(sp) // target_vel_x
        lw      t3, 0x0030(t2) // f4 = y velocity
        sw      t3, 0x188(sp) // target_vel_y

        lui     t3, Item.Basketball.FALL_SPEED
        sw      t3, 0x184(sp) // target_fall_speed_max
        li      t3, Item.Basketball.GRAVITY
        sw      t3, 0x180(sp) // target_gravity

        _end:
        j       _return
        addiu   v0, r0, 0xFFFF // original line 2
    }

    // @ Description
    // Patches which enable overtime (sudden death)
    scope overtime {
        // @ Description
        // This ensures we use the main vs battle state in overtime
        scope allow_overtime_: {
            OS.patch_start(0x10B18C, 0x8018E29C)
            jal     allow_overtime_
            addiu   t1, t1, 0x4EF8          // original line 1
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t2) // t2 = vs_mode_flag
            lli     t4, VsRemixMenu.mode.SMASHKETBALL
            bnel    t2, t4, _end            // if not Smashketball, update battle state pointer
            sw      t1, 0x0000(v0)          // original line 2

            _end:
            jr      ra
            nop
        }

        // @ Description
        // This prevents setting damage to 300
        scope no_initial_damage_: {
            OS.patch_start(0x10AED0, 0x8018DFE0)
            jal     no_initial_damage_
            addiu   t0, r0, 0x012C          // t0 = 300 = initial damage
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t2) // t2 = vs_mode_flag
            lli     t6, VsRemixMenu.mode.SMASHKETBALL
            beql    t2, t6, _end            // if Smashketball, set initial damage to 0
            lli     t0, 0x0000              // t0 = 0 = initial damage

            _end:
            jr      ra
            sb      t5, 0x006B(sp)          // original line 2
        }

        // @ Description
        // This prevents reseting match data (KOs, TKOs, damage dealt, etc.)
        scope prevent_match_stats_reset_: {
            OS.patch_start(0x63468, 0x800E7C68)
            j       prevent_match_stats_reset_
            sll     v0, v0, 0x0002          // original line 1
            _return:
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t7) // t7 = vs_mode_flag
            lli     t8, VsRemixMenu.mode.SMASHKETBALL
            bne     t7, t8, _end                // if not Smashketball, return normally
            OS.read_byte(0x800A4AE0, t7)        // t7 = is_suddendeath (yes, delay slot)
            beqz    t7, _end                    // if not sudden death, return normally
            nop
            // If here, it's overtime and we don't want to reset most things, so jump ahead
            addiu   a2, r0, 0x0001              // line 0x800E7CF0 that we skip
            sll     a3, a2, 0x0002              // line 0x800E7CF4 that we skip
            sll     t3, a0, 0x0003              // line 0x800E7D48 that we skip
            subu    t3, t3, a0                  // line 0x800E7D4C that we skip
            sll     t3, t3, 0x0002              // line 0x800E7D58 that we skip
            addu    t3, t3, a0                  // line 0x800E7D5C that we skip
            sll     t3, t3, 0x0002              // line 0x800E7D6C that we skip
            addu    t8, t6, v0                  // t8 = gSCManagerBattleState->players[player]
            j       0x800E7D74
            or      t6, a1, r0                  // t6 = fighter object

            _end:
            j       _return
            sw      a1, 0x0004(sp)          // original line 2 - save player object to stack
        }
    }

    scope css {
        // @ Description
        // Enable toggling Smashketball type
        scope enable_toggling_mode_: {
            // toggle type
            OS.patch_start(0x1335FC, 0x8013537C)
            jal     enable_toggling_mode_
            sh      t3, 0x0004(t0)              // original line 1
            OS.patch_end()
            // get correct offset
            OS.patch_start(0x133680, 0x80135400)
            jal     enable_toggling_mode_._get_offset
            lw      t9, 0x0024(t9)              // original line 1 - t9 = offset
            OS.patch_end()
            // exit routine early (skip some teams stuff)
            OS.patch_start(0x133724, 0x801354A4)
            jal     enable_toggling_mode_._skip_to_end
            sb      t6, 0x002A(v0)              // original line 1
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t5) // t5 = vs_mode_flag
            lli     v0, VsRemixMenu.mode.SMASHKETBALL
            bne     t5, v0, _end                // if not Smashketball, skip
            nop
            li      a2, type                    // set a2 to type address so it gets toggled

            _end:
            jr      ra
            lw      t5, 0x0000(a2)              // original line 2 - t5 = is_teams

            _get_offset:
            OS.read_word(VsRemixMenu.vs_mode_flag, t5) // t5 = vs_mode_flag
            lli     v0, VsRemixMenu.mode.SMASHKETBALL
            bne     t5, v0, _end_get_offset     // if not Smashketball, skip
            li      t5, offsets                 // t5 = offsets for Smashketball (yes, delay slot)
            OS.read_word(type, v0)              // v0 = type
            sll     v0, v0, 0x0002              // v0 = offset to offset
            addu    t5, t5, v0                  // t5 = address of offset
            lw      t9, 0x0000(t5)              // t9 = offset

            _end_get_offset:
            jr      ra
            lw      a0, 0x0034(sp)                      // original line 2

            _skip_to_end:
            OS.read_word(VsRemixMenu.vs_mode_flag, t5) // t5 = vs_mode_flag
            lli     v0, VsRemixMenu.mode.SMASHKETBALL
            bne     t5, v0, _end_skip_to_end    // if not Smashketball, skip
            nop
            j       0x80135544                  // can safely skip rest of the routine
            nop

            _end_skip_to_end:
            jr      ra
            lw      t7, 0x0000(a2)              // original line 2

            // @ Description
            // Offsets for Smashketball titles
            offsets:
            dw 0x2C18 // "Smashketball 1"
            dw 0x2E88 // "Smashketball 2"
        }

        // @ Description
        // Displays the GOAL yellow picker image
        scope use_goal_yellow_picker_: {
            OS.patch_start(0x132258, 0x80133FD8)
            jal     use_goal_yellow_picker_
            lli     t2, VsRemixMenu.mode.SMASHKETBALL
            OS.patch_end()

            OS.read_word(CharacterSelect.showing_time, t3)
            bnezl   t3, _end                // if showing Time, use TIME offset
            lli     t0, 0x48B0              // original lines 1/2, optimized - t0 = offset to TIME bg

            li      t0, 0x00027FC8          // t0 = offset to GOAL bg
            OS.read_word(VsRemixMenu.vs_mode_flag, t3)
            beq     t3, t2, _end            // if Smashketball, use GOAL offset
            lli     t2, VsRemixMenu.mode.KOTH
            bnel    t3, t2, pc() + 8        // if not King of the Hill, use TIME offset
            lli     t0, 0x48B0              // original lines 1/2, optimized - t0 = offset to TIME bg

            _end:
            jr      ra
            nop
        }

        // @ Description
        // Prevent start unless exactly two teams
        scope prevent_start_unless_two_teams_: {
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers

            // Loop over each panel to get its team and ensure it's enabled
            // Then confirm exactly 2 teams
            li      at, CharacterSelect.CSS_PLAYER_STRUCT // at = css player struct
            li      t8, 0x0000                  // t8 = port_id
            lli     t5, Character.id.NONE
            sw      r0, 0x0008(sp)              // initialize team present array
            addiu   t7, sp, 0x0008              // t7 = team present array

            _loop:
            lw      t0, 0x0084(at)              // t0 = player type (0 - HMN, 1 - CPU, 2 - N/A)
            lli     t1, 0x0002                  // t1 = 2 = N/A
            beq     t0, t1, _next               // if N/A, skip
            lw      t0, 0x0048(at)              // t0 = char_id
            lli     t1, Character.id.NONE
            beq     t0, t1, _next               // skip if no char selected/hovered
            lw      t0, 0x0040(at)              // t0 = team
            addu    t1, t7, t0                  // t1 = team present address
            lli     t0, OS.TRUE                 // t0 = TRUE
            sb      t0, 0x0000(t1)              // mark team as present

            _next:
            addiu   at, at, 0x00BC              // at = next css player struct
            addiu   t8, t8, 0x0001              // t8 = next port_id
            sltiu   t0, t8, 0x0004              // t0 = 1 if more to loop over
            bnez    t0, _loop                   // loop over all css player structs
            nop

            lbu     t0, 0x0000(t7)              // t0 = red team present
            lbu     t1, 0x0001(t7)              // t1 = blue team present
            addu    t0, t0, t1                  // t0 = num teams present (so far)
            lbu     t1, 0x0002(t7)              // t1 = green team present
            addu    t0, t0, t1                  // t0 = num teams present (so far)
            lbu     t1, 0x0003(t7)              // t1 = yellow team present
            addu    t0, t0, t1                  // t0 = num teams present
            lli     t1, 0x0002                  // t1 = 2
            bnel    t0, t1, _end                // if not exactly 2 teams present, prevent start
            lli     v1, OS.FALSE                // v1 = FALSE

            _end:
            lw      ra, 0x0004(sp)              // load registers
            jr      ra
            addiu   sp, sp, 0x0010              // deallocate stack space
        }
    }
}

} // SMASHKETBALL
