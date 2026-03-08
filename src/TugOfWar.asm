// TugOfWar.asm
if !{defined __TUG_OF_WAR__} {
define __TUG_OF_WAR__()
print "included TugOfWar.asm\n"

// @ Description
// This file implements Tug of War mode in VS

scope TugOfWar {

    // @ Description
    // The stocks setting as set on CSS
    stocks:
    dw 3

    // @ Description
    // The teams setting as set on CSS
    teams:
    dw OS.FALSE

    // @ Description
    // The stockmode_table for Tug of War
    stockmode_table:
    dw 0, 0, 0, 0

    // @ Description
    // The stock_count_table values for Tug of War
    stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // The previous_stock_count_table values for Tug of War
    previous_stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // The last port_id to hit the given port on current stock, in order, or -1 if not hit
    // p1, p2, p3, p4
    last_hit_by_port:
    db -1, -1, -1, -1

    // @ Description
    // The player's team per port
    // p1, p2, p3, p4
    team_by_port:
    db -1, -1, -1, -1

    // @ Description
    // Boolean indicating if this is a 1v1
    is_1v1:
    dw OS.FALSE

    // @ Description
    // Runs when entering the CSS
    scope before_css_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, Global.vs.game_mode     // at = game_mode address
        lli     t0, 0x0003                  // t0 = TIMED STOCK
        sb      t0, 0x0000(at)              // set game mode to TIMED STOCK
        li      at, 0x8013BDAC              // at = game_mode address
        sw      t0, 0x0000(at)              // set game mode to TIMED STOCK

        li      at, Global.vs.stocks        // at = stocks address
        OS.read_word(stocks, t0)            // t0 = Tug of War stocks
        sb      t0, 0x0000(at)              // set stocks
        li      at, 0x8013BD80              // at = stocks address
        sw      t0, 0x0000(at)              // set stocks

        li      at, Global.vs.teams         // at = teams address
        OS.read_word(teams, t0)             // t0 = Tug of War teams
        sb      t0, 0x0000(at)              // set teams
        li      at, 0x8013BDA8              // at = teams address
        sw      t0, 0x0000(at)              // set teams

        li      at, 0x8013B7C8              // at = title offsets (first is ffa, second is teams)
        lli     t9, 0x30F0                  // t9 = offset to "Tug of War" image
        sw      t9, 0x0000(at)              // set ffa offset
        sw      t9, 0x0004(at)              // set teams offset

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, stockmode_table         // t1 = Tug of War stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = Tug of War stockmode_table p1
        sw      t0, 0x0000(at)              // set stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = Tug of War stockmode_table p2
        sw      t0, 0x0004(at)              // set stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = Tug of War stockmode_table p3
        sw      t0, 0x0008(at)              // set stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = Tug of War stockmode_table p4
        sw      t0, 0x000C(at)              // set stockmode_table p4

        li      at, StockMode.stock_count_table // at = stock_count_table address
        OS.read_word(stock_count_table, t0) // t0 = Tug of War stock_count_table
        sw      t0, 0x0000(at)              // set stock_count_table

        // only reset previous_stock_count_table if coming from menu
        OS.read_byte(Global.previous_screen, at) // at = current screen
        lli     t0, Global.screen.VS_GAME_MODE_MENU
        bne     at, t0, _end                // if not coming from menu, skip
        nop

        li      at, StockMode.previous_stock_count_table // at = previous_stock_count_table address
        OS.read_word(previous_stock_count_table, t0) // t0 = Tug of War previous_stock_count_table
        sw      t0, 0x0000(at)              // set previous_stock_count_table

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Runs before leaving the CSS and going back to VS Mode menu
    scope leave_css_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, 0x8013BD80              // at = stocks address
        lw      t0, 0x0000(at)              // t0 = stocks in css stocks picker
        li      t1, stocks
        sw      t0, 0x0000(t1)              // save Tug of War stocks

        li      at, 0x8013BDA8              // at = teams address
        lw      t0, 0x0000(at)              // t0 = teams in css
        li      t1, teams
        sw      t0, 0x0000(t1)              // save Tug of War teams

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, stockmode_table         // t1 = Tug of War stockmode_table address
        lw      t0, 0x0000(at)              // t0 = Tug of War stockmode_table p1
        sw      t0, 0x0000(t1)              // save stockmode_table p1
        lw      t0, 0x0004(at)              // t0 = Tug of War stockmode_table p2
        sw      t0, 0x0004(t1)              // save stockmode_table p2
        lw      t0, 0x0008(at)              // t0 = Tug of War stockmode_table p3
        sw      t0, 0x0008(t1)              // save stockmode_table p3
        lw      t0, 0x000C(at)              // t0 = Tug of War stockmode_table p4
        sw      t0, 0x000C(t1)              // save stockmode_table p4

        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table
        li      t1, stock_count_table
        sw      t0, 0x0000(t1)              // save Tug of War stock_count_table

        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table
        li      t1, previous_stock_count_table
        sw      t0, 0x0000(t1)              // save Tug of War previous_stock_count_table

        // Restore globals
        li      at, 0x8013BD80              // at = stocks address
        OS.read_word(VsRemixMenu.global_stocks, t0) // t0 = saved stocks
        sw      t0, 0x0000(at)              // restore stocks

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, VsRemixMenu.global_stockmode_table // t1 = global stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = global stockmode_table p1
        sw      t0, 0x0000(at)              // set stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = global stockmode_table p2
        sw      t0, 0x0004(at)              // set stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = global stockmode_table p3
        sw      t0, 0x0008(at)              // set stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = global stockmode_table p4
        sw      t0, 0x000C(at)              // set stockmode_table p4

        li      at, StockMode.stock_count_table // at = stock_count_table
        OS.read_word(VsRemixMenu.global_stock_count_table, t0) // t0 = saved global_stock_count_table
        sw      t0, 0x0000(at)              // restore global_stock_count_table

        li      at, StockMode.previous_stock_count_table // at = previous_stock_count_table
        OS.read_word(VsRemixMenu.global_previous_stock_count_table, t0) // t0 = saved global_previous_stock_count_table
        sw      t0, 0x0000(at)              // restore global_previous_stock_count_table

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Runs before leaving the CSS to start a match
    scope start_match_setup_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        li      at, 0x8013BD80              // at = stocks address
        li      t0, stocks
        lw      t1, 0x0000(at)              // t1 = stocks in css stocks picker
        sw      t1, 0x0000(t0)              // save stocks

        li      at, 0x8013BDA8              // at = teams address
        li      t0, teams
        lw      t1, 0x0000(at)              // t1 = teams in css
        sw      t1, 0x0000(t0)              // save teams

        li      at, 0x8013BDAC              // at = game_mode address
        lli     t0, 0x0003                  // t0 = TIMED STOCK
        sw      t0, 0x0000(at)              // set game mode to TIMED STOCK

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, stockmode_table         // t1 = Tug of War stockmode_table address
        lw      t0, 0x0000(at)              // t0 = Tug of War stockmode_table p1
        sw      t0, 0x0000(t1)              // save stockmode_table p1
        lw      t0, 0x0004(at)              // t0 = Tug of War stockmode_table p2
        sw      t0, 0x0004(t1)              // save stockmode_table p2
        lw      t0, 0x0008(at)              // t0 = Tug of War stockmode_table p3
        sw      t0, 0x0008(t1)              // save stockmode_table p3
        lw      t0, 0x000C(at)              // t0 = Tug of War stockmode_table p4
        sw      t0, 0x000C(t1)              // save stockmode_table p4

        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table
        li      t1, stock_count_table
        sw      t0, 0x0000(t1)              // save Tug of War stock_count_table

        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table
        li      t1, previous_stock_count_table
        sw      t0, 0x0000(t1)              // save Tug of War previous_stock_count_table

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Runs when a game starts and sets up Tug of War. Called from Render.asm.
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.TUG_OF_WAR
        bne     t0, t1, _end                // if not Tug of War, skip
        addiu   t5, r0, -0x0001             // t5 = 0xFFFFFFFF

        li      t1, last_hit_by_port
        sw      t5, 0x0000(t1)              // initialize last_hit_by_port
        li      t1, team_by_port
        sw      t5, 0x0000(t1)              // initialize team_by_port

        lui     t0, 0x8004
        lw      t0, 0x66FC(t0)              // t0 = first player object
        lli     at, 0x0000                  // at = player count
        addiu   t7, r0, -0x0001             // t7 = first active player's port
        addiu   t8, r0, -0x0001             // t8 = second active player's port

        _loop:
        lw      t2, 0x0084(t0)              // t2 = player struct
        sw      t5, 0x07D4(t2)              // initialize shield_player (fixes vanilla bug)
        lbu     t3, 0x000D(t2)              // t3 = port
        lbu     t2, 0x000C(t2)              // t2 = team
        addu    t4, t1, t3                  // t4 = team_by_port address for this player
        sb      t2, 0x0000(t4)              // save player_num
        bltzl   t7, _next                   // if not set yet, set first active player's port
        or      t7, t3, r0                  // t8 = first active player's port
        bltzl   t8, _next                   // if not set yet, set second active player's port
        or      t8, t3, r0                  // t8 = second active player's port

        _next:
        lw      t0, 0x0004(t0)              // t0 = next player object
        bnez    t0, _loop
        addiu   at, at, 0x0001              // at = number of players

        li      t2, is_1v1
        lli     t0, 0x0002                  // t0 = 2
        bne     t0, at, _end                // if more than 2 players, last hit by will get updated in another hook
        sw      r0, 0x0000(t2)              // set is1v1 to FALSE

        li      t0, last_hit_by_port        // t0 = last_hit_by_port
        addu    t1, t0, t7                  // t1 = first players last_hit_by_port address
        sb      t8, 0x0000(t1)              // set last_hit_by_port so all stocks get credited to second player
        addu    t1, t0, t8                  // t1 = second players last_hit_by_port address
        sb      t7, 0x0000(t1)              // set last_hit_by_port so all stocks get credited to first player
        lli     t0, OS.TRUE                  // t0 = TRUE
        sw      t0, 0x0000(t2)              // set is1v1 to TRUE

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // When a KO is attributed to another player, this will increase their stock count
    // unless they're on the same team
    scope credit_stock_to_koer_: {
        OS.patch_start(0xB6884, 0x8013BE44)
        jal     credit_stock_to_koer_
        lli     t1, VsRemixMenu.mode.TUG_OF_WAR
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t2) // t2 = vs_mode_flag
        bne     t2, t1, _end                // if not Tug of War, skip
        lw      a2, 0x0000(a3)              // original line 1 - a2 = gSCManagerBattleState

        // t8 is port_id of KOer
        addiu   t9, r0, -0x0001             // t9 = -1
        sw      t9, 0x07D4(s0)              // reinitialize shield_player (fixes vanilla bug)

        li      t9, team_by_port
        addu    t9, t9, t8                  // t9 = address of KOer team
        lbu     t9, 0x0000(t9)              // t9 = KOer team
        lbu     t2, 0x000C(s0)              // t2 = player team
        bne     t2, t9, _credit             // if not the same team, credit!
        li      t9, last_hit_by_port        // yes, delay slot
        addu    t9, t9, t2                  // t9 = address of player's last hit by
        lb      t8, 0x0000(t9)              // t8 = last attacker port
        bltz    t8, _not_hit                // if not hit at all, handle
        nop

        _credit:
        // t0 is 0x74, the size of the struct
        multu   t8, t0                      // mflo = offset to KOer struct
        mflo    t9                          // t9 = offset to KOer struct
        addu    t2, a2, t9                  // t2 = KOer struct
        lw      t1, 0x0078(t2)              // t1 = KOer player object
        lw      t1, 0x0084(t1)              // t1 = KOer player struct

        lb      t9, 0x0014(t1)              // t9 = stock count
        slti    t8, t9, 0xFF                // t8 = 1 if less than 255 stocks
        bnezl   t8, pc() + 8                // only increase stock count if within range
        addiu   t9, t9, 0x0001              // t9 = stock count plus 1
        sb      t9, 0x0014(t1)              // save updated stock count

        lb      t9, 0x002B(t2)              // t9 = KOer stocks remaining
        addiu   t9, t9, 0x0001              // t9 = stocks remaining plus 1
        sb      t9, 0x002B(t2)              // save updated stocks remaining

        li      t2, StockMode.previous_stock_count_table
        lbu     t8, 0x000D(t1)              // t8 = port
        addu    t2, t2, t8                  // t2 = address of previous stock count
        sb      t9, 0x0000(t2)              // save updated previous stock count

        bnez    t9, _check_1v1              // if stocks remaining didn't just increase to 1, skip respawn
        nop                                 // otherwise, trigger respawn

        OS.save_registers()
        jal     0x8013CF60                  // ftCommonRebirthDownSetStatus(GObj *this_gobj)
        lw      a0, 0x0004(t1)              // t1 = KOer player object
        jal     update_sIFCommonBattlePlace_ // be sure to fix the current place since we just brought someone back
        lw      a0, 0x0024(sp)              // a0 = KOer player struct
        OS.restore_registers()

        _check_1v1:
        OS.read_word(is_1v1, t1)            // t1 = is_1v1
        bnez    t1, _end                    // if 1v1, then don't clear last hit by
        lbu     t2, 0x000D(s0)              // t2 = port_id of player
        li      t8, last_hit_by_port
        addu    t8, t8, t2                  // t8 = address of port_id to last hit this player
        addiu   t9, r0, -0x0001             // t9 = -1
        sb      t9, 0x0000(t8)              // clear last hit by

        _end:
        jr      ra
        lb      t8, 0x001D(a2)              // original line 2 - is_show_score

        _not_hit:
        // if the player somehow SDs without being hit by an opponent...
        // ...find the closest opponent to credit?
        // TODO
        b       _end // change to _credit
        nop
    }

    // @ Description
    // When a KO is not attributed to another player, then credit a player whom is either:
    // - The last player to damage the player or break the player's shield this stock
    scope credit_stock_when_no_koer_: {
        OS.patch_start(0xB68C4, 0x8013BE84)
        jal     credit_stock_when_no_koer_
        lli     t1, VsRemixMenu.mode.TUG_OF_WAR
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t2) // t2 = vs_mode_flag
        bne     t2, t1, _end                // if not Tug of War, skip
        lbu     t3, 0x000D(s0)              // original line 1 - t3 = port_id of KO'd player

        OS.read_word(is_1v1, t1)            // t1 = is_1v1
        addiu   t9, r0, -0x0001             // t9 = -1
        sw      t9, 0x07D4(s0)              // reinitialize shield_player (fixes vanilla bug)
        li      t4, last_hit_by_port
        addu    t2, t4, t3                  // t2 = address of port_id to last hit this player
        lb      t4, 0x0000(t2)              // t4 = port_id of player who last hit this player, or -1
        beqzl   t1, pc() + 8                // if not 1v1, then clear last hit by
        sb      t9, 0x0000(t2)              // clear last hit by
        bltz    t4, _not_hit                // if not hit at all, handle
        nop

        _credit:
        lli     t0, 0x0074                  // t0 = size of the struct
        multu   t4, t0                      // mflo = offset to KOer struct
        mflo    t9                          // t9 = offset to KOer struct
        addu    t2, a2, t9                  // t2 = KOer struct
        lw      t1, 0x0078(t2)              // t1 = KOer player object
        lw      t1, 0x0084(t1)              // t1 = KOer player struct

        lb      t9, 0x0014(t1)              // t9 = stock count
        slti    t4, t9, 0xFF                // t4 = 1 if less than 255 stocks
        bnezl   t4, pc() + 8                // only increase stock count if within range
        addiu   t9, t9, 0x0001              // t9 = stock count plus 1
        sb      t9, 0x0014(t1)              // save updated stock count

        lb     t9, 0x002B(t2)               // t9 = KOer stocks remaining
        addiu   t9, t9, 0x0001              // t9 = stocks remaining plus 1
        sb      t9, 0x002B(t2)              // save updated stocks remaining

        li      t2, StockMode.previous_stock_count_table
        lbu     t4, 0x000D(t1)              // t4 = port
        addu    t2, t2, t4                  // t2 = address of previous stock count
        sb      t9, 0x0000(t2)              // save updated previous stock count

        bnez    t9, _end                    // if stocks remaining didn't just increase to 1, end
        nop                                 // otherwise, trigger respawn

        OS.save_registers()
        jal     0x8013CF60                  // ftCommonRebirthDownSetStatus(GObj *this_gobj)
        lw      a0, 0x0004(t1)              // t1 = KOer player object
        jal     update_sIFCommonBattlePlace_ // be sure to fix the current place since we just brought someone back
        lw      a0, 0x0024(sp)              // a0 = KOer player struct
        OS.restore_registers()

        _end:
        jr      ra
        sll     t4, t3, 0x0003              // original line 2

        _not_hit:
        // if the player somehow SDs without being hit...
        // ...find the closest opponent to credit?
        // TODO
        b       _end // change to _credit
        nop
    }

    // @ Description
    // Updates last_hit_by_port when a attacker causes damage or breaks shield
    scope update_last_hit_by_: {
        // damage
        OS.patch_start(0xBBF74, 0x80141534)
        jal     update_last_hit_by_._damage
        lw      v1, 0x0084(v0)              // original line 1 - v1 = attacker player struct
        OS.patch_end()
        // shield
        OS.patch_start(0xC3FC4, 0x80149584)
        jal     update_last_hit_by_._shield
        sw      r0, 0x0014(sp)              // original line 1
        OS.patch_end()

        _damage:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.TUG_OF_WAR
        bne     t0, t1, _end_damage         // if not Tug of War, skip
        lbu     t0, 0x000C(v1)              // t0 = attacker team

        OS.read_word(is_1v1, t1)            // t1 = is_1v1
        bnez    t1, _end_damage             // if 1v1, skip
        lbu     t1, 0x000C(s0)              // t1 = player team

        beq     t0, t1, _end_damage         // if on the same team, skip
        lbu     t0, 0x000D(s0)              // t0 = player port

        li      t1, last_hit_by_port
        addu    t0, t1, t0                  // t0 = address of last hit by port
        lbu     t1, 0x000D(v1)              // t1 = attacker port

        // safeguard for invalid attacker ports, which may not be necessary here, but just in case!
        slti    t2, t1, 0x0004              // t2 = 1 if attacker port is valid
        bnezl   t2, _end_damage             // if valid, update last hit by
        sb      t1, 0x0000(t0)              // update last hit by

        _end_damage:
        lhu     t0, 0x07B8(v1)              // original line 2 - t0 = attacker attack_count

        _end:
        jr      ra
        nop

        _shield:
        // a1 is shield_player
        bltz    a1, _end                    // if no shield_player, skip
        sw      r0, 0x0010(sp)              // original line 2
        slti    t1, a1, 0x0004              // t1 = 1 if player port is valid (can be 4 for items with no owner?)
        beqz    t1, _end                    // if not valid, skip
        lli     t1, VsRemixMenu.mode.TUG_OF_WAR

        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        bne     t0, t1, _end                // if not Tug of War, skip
        lbu     t1, 0x000C(s0)              // t1 = player team

        OS.read_word(is_1v1, t0)            // t0 = is_1v1
        bnez    t0, _end                    // if 1v1, skip
        li      t0, team_by_port            // yes, delay slot
        addu    t2, t0, a1                  // t2 = address of attacker team
        lbu     t0, 0x0000(t2)              // t0 = attacker team

        li      t1, last_hit_by_port
        beq     t0, t1, _end                // if on the same team, skip
        lbu     t0, 0x000D(s0)              // t0 = player port
        addu    t0, t1, t0                  // t0 = address of last hit by port
        b       _end
        sb      a1, 0x0000(t0)              // update last hit by
    }

    // @ Description
    // Updates the sIFCommonBattlePlace value which tracks the current place
    // of the next team/player to be eliminated.
    // Loosely based off of 0x8011388C (ifCommonBattleUpdateScoreStocks)
    // @ Arguments
    // a0 - resurrected player struct
    scope update_sIFCommonBattlePlace_: {
        OS.read_byte(Global.vs.teams, t1)   // t1 = 1 if teams
        beqz    t1, _fix_place              // if not teams, always fix place
        lbu     t1, 0x000C(a0)              // t1 = resurrected player team

        lui     t0, 0x8004
        lw      t0, 0x66FC(t0)              // t0 = first player object
        lli     at, 0x0000                  // at = teammate count

        _loop:
        lw      t2, 0x0084(t0)              // t2 = player struct
        beq     t2, a0, _next               // if this is the resurrected player, skip
        lbu     t3, 0x000C(t2)              // t3 = team
        bne     t3, t1, _next               // if not on the same team, skip
        lb      t9, 0x0014(t2)              // t9 = stock count
        bgezl   t9, _next                   // if teammate has stocks remaining, increment teammates
        addiu   at, at, 0x0001              // at = teammate count plus 1

        _next:
        lw      t0, 0x0004(t0)              // t0 = next player object
        bnez    t0, _loop                   // loop if there is a next player
        nop

        bgtz    at, _end                    // if teammate count is greater than 0, skip
        nop

        // if here, no other teammates remain so we need to fix

        _fix_place:
        li      t0, 0x801317F4              // t0 = address of sIFCommonBattlePlace
        lw      t1, 0x0000(t0)              // t1 = sIFCommonBattlePlace
        addiu   t1, t1, 0x0001              // sIFCommonBattlePlace++
        sw      t1, 0x0000(t0)              // write back sIFCommonBattlePlace

        _end:
        jr      ra
        nop
    }
}

} // __TUG_OF_WAR__
