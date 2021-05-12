// BGM.asm
if !{defined __BGM__} {
define __BGM__()
print "included BGM.asm\n"

// @ Description
// This file allows BGM (background music) to be played and stopped.

include "Global.asm"
include "Midi.asm"
include "Toggles.asm"
include "OS.asm"

scope BGM {

    // @ Description
    // Plays background music until play_ is called again or stop_ is called.
    // @ Arguments
    // a0 - unknown, set to 0
    // a1 - BGM ID
    constant play_(0x80020AB4)

    // @ Description
    // Stops background music.
    constant stop_(0x80020A74)

    // @ Description
    // This function replaces a1 with alternate ids defined for the stage, sometimes.
    // a1 holds BGM_ID.
    // The alternate BGM_ID could be replaced by a random one if that toggle is on.
    // There can be up to 3 songs defined for a stage:
    // - Main: plays most of the time
    // - Occasional: plays sometimes
    // - Rare: plays rarely
    scope alternate_music_: {
        // @ Description
        // These constants determine alternate music chances
        constant CHANCE_MAIN(67)
        constant CHANCE_OCCASIONAL(20)
        constant CHANCE_RARE(13)

        OS.patch_start(0x000216E8, 0x80020AE8)
        j       alternate_music_
        nop
        _alternate_music_return:
        OS.patch_end()

        lw      t1, 0xD974(t1)              // original line 1
        sll     t2, a0, 0x0002              // original line 2

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = current_screen
        lli     v0, 0x0034                  // v0 = 1P_SCREEN
        beq     t0, v0, _alternate          // if 1p, allow alternate music to play
        lli     v0, 0x0035                  // v0 = BONUS_SCREEN
        beq     t0, v0, _alternate          // if Bonus, allow alternate music to play
        lli     v0, 0x0016                  // v0 = FIGHT_SCREEN
        bne     t0, v0, _end                // if not fight screen, end
        nop
        
        _alternate:
        // check if starting to play hammer/star music
        // if so, skip getting alternate music
        lli     v0, special.HAMMER          // v0 = hammer bgm_id
        beq     v0, a1, _end                // skip if playing the hammer music
        nop
        lli     v0, special.INVINCIBLE      // v0 = invincible (star) bgm_id
        beq     v0, a1, _end                // skip if playing the invincible (star) music
        nop

        // check if just finished playing hammer/star music
        // if so, restore original bgm_id
        li      a0, current_bgm_id          // a0 = address of current_bgm_id
        addu    t0, t1, t2                  // t0 = address of previous bgm_id
        lw      t0, 0x0000(t0)              // t0 = previous bgm_id
        lli     v0, special.HAMMER          // v0 = hammer bgm_id
        beql    v0, t0, _end                // if just finished playing the hammer music,
        lh      a1, 0x0000(a0)              // then skip and load saved bgm_id
        lli     v0, special.INVINCIBLE      // v0 = invincible/star bgm_id
        beql    v0, t0, _end                // if just finished playing the invincible/star music,
        lh      a1, 0x0000(a0)              // then skip and load saved bgm_id

        // check for held buttons to force alternate music: CU - Default, CL - Occasional, CR - Rare
        addu    t0, r0, a1                  // t0 = bgm_id
        lli     a0, Joypad.CU               // a0 - button masks
        lli     a1, OS.TRUE                 // a1 - ignore other buttons
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = bool
        nop
        addu    a1, t0, r0                  // a1 = bgm_id
        bnez    v0, _save                   // if CU pressed, then use default
        nop

        addu    t0, r0, a1                  // t0 = bgm_id
        lli     a0, Joypad.CL               // a0 - button masks
        lli     a1, OS.TRUE                 // a1 - ignore other buttons
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = bool
        nop
        addu    a1, t0, r0                  // a1 = bgm_id
        bnez    v0, _get_bgm_id             // if CL pressed,
        ori     a0, r0, 0x0000              // then use the Occasional song

        addu    t0, r0, a1                  // t0 = bgm_id
        lli     a0, Joypad.CR               // a0 - button masks
        lli     a1, OS.TRUE                 // a1 - ignore other buttons
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = bool
        nop
        addu    a1, t0, r0                  // a1 = bgm_id
        bnez    v0, _get_bgm_id             // if CR pressed,
        ori     a0, r0, 0x0002              // then use the Occasional song

        // otherwise, alt music will play by chance
        lli     a0, 100                     // a0 - range (0, N-1)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        sltiu   t0, v0, CHANCE_MAIN
        bnez    t0, _save                   // if we should play the Main song, skip to end
        nop                                 // else, check to see which other song to play

        sltiu   t0, v0, CHANCE_MAIN + CHANCE_OCCASIONAL
        beql    t0, r0, _get_bgm_id         // if (v0 > main + occasional chances)
        ori     a0, r0, 0x0002              // then we'll use the Rare song
        ori     a0, r0, 0x0000              // otherwise we'll use the Occasional song

        _get_bgm_id:
        li      t0, Global.match_info       // t0 = pointer to match info
        lw      t0, 0x0000(t0)              // load address of match info
        lbu     v0, 0x0001(t0)              // v0 = stage_id
        li      t0, Stages.alternate_music_table   // t0 = address of alternate music table
        sll     v0, v0, 0x0002              // v0 = offset to stage's alt music
        addu    t0, t0, v0                  // t0 = address of alt music options for stage (0x0 = Occasional, 0x2 = Rare)
        addu    t0, t0, a0                  // t0 = address of bgm_id to use
        lh      v0, 0x0000(t0)              // v0 = bgm_id to use, maybe
        addiu   t0, r0, 0xFFFF              // t0 = -1 - means there is no alt BGM_ID for this stage
        beq     v0, t0, _save               // if (there is no alt BGM_ID) for this stage, skip to end
        nop
        addu    a1, r0, v0                  // a1 = bgm_id to use

        _save:
        // remember bgm_id
        li      a0, current_bgm_id          // a0 = address of current_bgm_id
        sh      a1, 0x0000(a0)              // store bgm_id as current_bgm_id

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        j       _alternate_music_return     // return
        nop
    }

    // @ Descirption
    // Adds a song to the random list if it's toggled on.
    // @ Arguments
    // a0 - address of entry (random music entry)
    // a1 - bgm_id to add
    // @ Returns
    // v0 - bool was_added?
    // v1 - num_songs
    scope add_song_to_random_list_: {
        addiu   sp, sp,-0x0010              // allocate stack sapce
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        // this block checks to see if a song should be added to the table. 
        _check_add:
        lw      t0, 0x0004(a0)              // t0 = curr_value
        lli     v0, OS.FALSE                // v0 = false
        li      v1, random_count            // ~
        lh      v1, 0x0000(v1)              // v1 = random_count
        beqz    t0, _end                    // end, return false and count
        nop

        // if the song should be added, it is added here. count is also incremented here
        li      t0, random_count            // t0 = address of random_count
        lh      v1, 0x0000(t0)              // v1 = random_count
        sll     t1, v1, 0x0002              // t1 = offset = random_count * 4
        addiu   v1, v1, 0x0001              // v1 = random_count++
        sh      v1, 0x0000(t0)              // update random_count
        li      t0, random_table            // t0 = address of random_table
        addu    t0, t0, t1                  // t0 = random_table + offset
        sw      a1, 0x0000(t0)              // add song
        or      v0, OS.TRUE                 // v0 = true

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack sapce
        jr      ra                          // return
        nop
    }

    // @ Descirption
    // Macro to (maybe) add a song to the random list.
    macro add_to_list(entry, bgm_id) {
        li      a0, {entry}                 // a0 - address of entry
        lli     a1, {bgm_id}                // a1 - bgm_id to add
        jal     add_song_to_random_list_    // add song
        nop
    }

    // @ Descirption
    // Table of bgm_id (as words, 32 bit values)
    random_table:
    fill 4 * MIDI.midi_count                // allows for space for all songs, which is actually more than we need

    // @ Description
    // number of stages in random_table.
    random_count:
    dh 0

    // @ Description
    // the bgm_id used at the start of the current match
    current_bgm_id:
    dh 0

    // @ Descirption
    // This function is an implementation of a play music tooggle
    scope play_music_: {
        OS.patch_start(0x000216B4, 0x80020AB4)
        j       play_music_._guard
        nop
        _play_music_return:
        OS.patch_end()

        _toggle_off:
        addiu   sp, sp,-0x0004              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     stop_                       // let's make sure to stop any lingering track from playing
        nop

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0004              // deallocate stack space

        jr      ra
        nop

        _guard:
        Toggles.guard(Toggles.entry_play_music, _toggle_off)

        lui     t6, 0x800A                  // original line 1
        lw      t6, 0xD95C(t6)              // original line 2

        j       _play_music_return
        nop
    }

    // @ Description
    // a1 holds BGM_id. This function replaces a1 with a random id from the table
    scope random_music_: {
        OS.patch_start(0x000216F0, 0x80020AF0)
        j       random_music_
        nop
        _random_music_return:
        OS.patch_end()

        or      v0, a1, r0                  // original line 1
        addu    t3, t1, t2                  // original line 2
        Toggles.guard(Toggles.entry_random_music, _random_music_return)

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = current_screen
        lli     v0, 0x0016                  // v0 = FIGHT_SCREEN
        bne     t0, v0, _end                // if not fight screen, end
        nop

        // check if starting to play hammer/star music
        // if so, skip getting random music
        lli     v0, special.HAMMER          // v0 = hammer bgm_id
        beq     v0, a1, _end                // skip if playing the hammer music
        nop
        lli     v0, special.INVINCIBLE      // v0 = invincible (star) bgm_id
        beq     v0, a1, _end                // skip if playing the invincible (star) music
        nop

        // check if just finished playing hammer/star music
        // if so, skip getting random music (alternate music routine already took care of restoring a1)
        lw      t0, 0x0000(t3)              // t0 = previous bgm_id
        lli     v0, special.HAMMER          // v0 = hammer bgm_id
        beq     v0, t0, _end                // if just finished playing the hammer music, then skip
        nop                                 // ~
        lli     v0, special.INVINCIBLE      // v0 = invincible/star bgm_id
        beql    v0, t0, _end                // if just finished playing the invincible/star music, then skip
        nop                                 // ~

        // reset count each time so we don't grow the list too large
        li      v1, random_count            // v1 = random_count address
        sh      r0, 0x0000(v1)              // set random_count to 0

        // this block builds the list of stages available in the random list (using macro above)
        sw      a1, 0x0014(sp)              // save a1 (default bgm_id)

        add_to_list(Toggles.entry_random_music_peachs_castle, stage.PEACHS_CASTLE)
        add_to_list(Toggles.entry_random_music_sector_z, stage.SECTOR_Z)
        add_to_list(Toggles.entry_random_music_congo_jungle, stage.CONGO_JUNGLE)
        add_to_list(Toggles.entry_random_music_planet_zebes, stage.PLANET_ZEBES)
        add_to_list(Toggles.entry_random_music_hyrule_castle, stage.HYRULE_CASTLE)
        add_to_list(Toggles.entry_random_music_yoshis_island, stage.YOSHIS_ISLAND)
        add_to_list(Toggles.entry_random_music_dream_land, stage.DREAM_LAND)
        add_to_list(Toggles.entry_random_music_saffron_city, stage.SAFFRON_CITY)
        add_to_list(Toggles.entry_random_music_mushroom_kingdom, stage.MUSHROOM_KINGDOM)
        add_to_list(Toggles.entry_random_music_duel_zone, stage.DUEL_ZONE)
        add_to_list(Toggles.entry_random_music_final_destination, stage.FINAL_DESTINATION)
        add_to_list(Toggles.entry_random_music_how_to_play, stage.HOW_TO_PLAY)
        add_to_list(Toggles.entry_random_music_data, menu.DATA)
        add_to_list(Toggles.entry_random_music_bonus, menu.BONUS)
        add_to_list(Toggles.entry_random_music_credits, menu.CREDITS)

        // Add custom MIDIs
        define n(0x2F)
        evaluate n({n})
        while {n} < MIDI.midi_count {
            evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
            if ({can_toggle} == OS.TRUE) {
                add_to_list(Toggles.entry_random_music_{n}, {n})
            }
            evaluate n({n}+1)
        }

        lw      a1, 0x0014(sp)              // restore a1 (default bgm_id)
        beqz    v1, _end                    // if there were no valid entries in the random table, then use default bgm_id
        nop

        // this block loads from the random list using a random int
        move    a0, v1                      // a0 - range (0, N-1)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        li      t0, random_table            // t0 = random_table
        sll     v0, v0, 0x0002              // v0 = offset = random_int * 4
        addu    t0, t0, v0                  // t0 = random_table + offset
        lw      a1, 0x0000(t0)              // a1 = bgm_id

        // remember bgm_id
        li      a0, current_bgm_id          // a0 = address of current_bgm_id
        sh      a1, 0x0000(a0)              // store bgm_id as current_bgm_id

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers 
        addiu   sp, sp, 0x0018              // deallocate stack space
        j       _random_music_return        // return
        nop
    }

    // @ Description
    // Allows for alternate music when on the menu
    scope alt_menu_music_: {
        // @ Description
        // These constants determine alternate menu music chances
        constant CHANCE_64(90)
        constant CHANCE_MELEE(5)
        constant CHANCE_BRAWL(5)

        // From title screen
        OS.patch_start(0x11DAAC, 0x80132B1C)
        jal     alt_menu_music_
        addiu   a1, r0, menu.MAIN           // original line 2
        OS.patch_end()
        // From 1p/training/bonus CSS
        OS.patch_start(0x11F118, 0x80133008)
        jal     alt_menu_music_
        addiu   a1, r0, menu.MAIN           // original line 2
        OS.patch_end()
        // From screen adjust
        OS.patch_start(0x120D58, 0x801335A8)
        jal     alt_menu_music_
        addiu   a1, r0, menu.MAIN           // original line 2
        OS.patch_end()
        // From sound test
        OS.patch_start(0x1222F8, 0x80132EA8)
        jal     alt_menu_music_
        addiu   a1, r0, menu.MAIN           // original line 2
        OS.patch_end()
        // From VS CSS
        OS.patch_start(0x1250F0, 0x80134740)
        jal     alt_menu_music_
        addiu   a1, r0, menu.MAIN           // original line 2
        OS.patch_end()

        // VS CSS
        OS.patch_start(0x139578, 0x8013B2F8)
        jal     alt_menu_music_
        addiu   a1, r0, menu.CHARACTER_SELECT // original line 2
        OS.patch_end()
        // 1p CSS
        OS.patch_start(0x140734, 0x80138534)
        jal     alt_menu_music_
        addiu   a1, r0, menu.CHARACTER_SELECT // original line 2
        OS.patch_end()
        // Training CSS
        OS.patch_start(0x1474B4, 0x80137ED4)
        jal     alt_menu_music_
        addiu   a1, r0, menu.CHARACTER_SELECT // original line 2
        OS.patch_end()
        // Bonus CSS
        OS.patch_start(0x14CF08, 0x80136ED8)
        jal     alt_menu_music_
        addiu   a1, r0, menu.CHARACTER_SELECT // original line 2
        OS.patch_end()

        // The following prevent calls to stop_
        // Back from VS CSS
        OS.patch_start(0x1363A0, 0x80138120)
        jal     alt_menu_music_._prevent_stop
        OS.patch_end()
        // Back from 1p CSS
        OS.patch_start(0x13EEDC, 0x80136CDC)
        jal     alt_menu_music_._prevent_stop
        OS.patch_end()
        // Back from Training CSS
        OS.patch_start(0x144DD0, 0x801357F0)
        jal     alt_menu_music_._prevent_stop
        OS.patch_end()
        // Back from Bonus CSS
        OS.patch_start(0x14B7B4, 0x80135784)
        jal     alt_menu_music_._prevent_stop
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~

        li      t0, Toggles.entry_menu_music
        lw      t0, 0x0004(t0)              // t0 = 0 if DEFAULT, 1 if 64, 2 if MELEE, 3 if BRAWL
        lli     t1, 0x0001                  // t1 = 1 (64)
        beq     t1, t0, _original           // if 64, then use 64 BGM
        nop
        lli     t1, 0x0002                  // t1 = 2 (MELEE)
        beql    t1, t0, _check_current_track// if MELEE, then use MELEE BGM
        addiu   a1, r0, menu.MAIN_MELEE
        lli     t1, 0x0003                  // t1 = 3 (BRAWL)
        beql    t1, t0, _check_current_track// if BRAWL, then use BRAWL BGM
        addiu   a1, r0, menu.MAIN_BRAWL

        // otherwise, alt menu music will play by chance - unless we already are playing MELEE or BRAWL
        lui     t0, 0x800A
        lw      t0, 0xD974(t0)              // t0 = address of current bgm_id
        lw      t0, 0x0000(t0)              // t0 = current bgm_id
        lli     t1, menu.MAIN_MELEE         // t1 = menu.MAIN_MELEE
        beq     t0, t1, _check_music_toggle // if playing MELEE, then don't restart it
        nop
        lli     t1, menu.MAIN_BRAWL         // t1 = menu.MAIN_BRAWL
        beq     t0, t1, _check_music_toggle // if playing BRAWL, then don't restart it
        nop

        // alt menu music will play by chance if we are coming from Title screen
        li      a0, 0x80132B1C + 8          // a0 = ra for title screen hook
        bne     a0, ra, _original           // if not coming from title screen, then use original
        nop                                 // otherwise, calculate random integer for alt music chance
        lli     a0, 100                     // a0 - range (0, N-1)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        sltiu   t0, v0, CHANCE_64
        bnez    t0, _original               // if we should play the 64 track, skip to end
        nop                                 // else, check to see which other track to play

        sltiu   t0, v0, CHANCE_64 + CHANCE_MELEE
        beql    t0, r0, _original           // if (v0 > 64 + MELEE chances)
        addiu   a1, r0, menu.MAIN_BRAWL     // then we'll use the BRAWL track
        b       _original
        addiu   a1, r0, menu.MAIN_MELEE     // otherwise we'll use the MELEE track

        _check_current_track:
        // if the current track is the one we want to play, then don't restart it
        lui     t0, 0x800A
        lw      t0, 0xD974(t0)              // t0 = address of current bgm_id
        lw      t0, 0x0000(t0)              // t0 = current bgm_id
        bne     t0, a1, _original           // if current track is not the one we want, then need to call play_
        nop                                 // otherwise we need to check the play music toggle

        _check_music_toggle:
        li      t0, Toggles.entry_play_music
        lw      t0, 0x0004(t0)              // t0 = 0 if music is off
        bnez    t0, _finish                 // if music is on, then we can finish
        nop                                 // otherwise, we have to call stop_

        jal     BGM.stop_                   // stop current track
        nop
        b       _finish                     // skip to _finish
        nop

        _original:
        lw      a0, 0x0010(sp)              // restore a0

        jal     BGM.play_                   // original line 1
        nop

        _finish:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // restore a0
        lw      v0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop

        _prevent_stop:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~

        // if the current track is one of the alt menu tracks, then don't stop it
        lui     t0, 0x800A
        lw      t0, 0xD974(t0)              // t0 = address of current bgm_id
        lw      t0, 0x0000(t0)              // t0 = current bgm_id

        lli     t1, menu.MAIN_MELEE         // t1 = menu.MAIN_MELEE
        beq     t0, t1, _done               // if playing MELEE, then don't stop it
        nop
        lli     t1, menu.MAIN_BRAWL         // t1 = menu.MAIN_BRAWL
        beq     t0, t1, _done               // if playing BRAWL, then don't stop it
        nop

        jal     BGM.stop_                   // original line 1
        nop                                 // original line 2

        _done:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop

    }

    scope stage {
        constant DREAM_LAND(0)
        constant PLANET_ZEBES(1)
        constant MUSHROOM_KINGDOM(2)
        constant MUSHROOM_KINGDOM_FAST(3)
        constant SECTOR_Z(4)
        constant CONGO_JUNGLE(5)
        constant PEACHS_CASTLE(6)
        constant SAFFRON_CITY(7)
        constant YOSHIS_ISLAND(8)
        constant HYRULE_CASTLE(9)
        constant MASTER_HAND_0(23)
        constant MASTER_HAND_1(24)
        constant MASTER_HAND_2(25)
        constant FINAL_DESTINATION(25)
        constant HOW_TO_PLAY(34)
        constant TUTORIAL(34)
        constant KIRBY_BETA_1(34)
        constant FIGHT_POLYGON_STAGE(36)
        constant DUEL_ZONE(36)
        constant METAL_MARIO(37)
        constant META_CRYSTAL(37)
    }

    scope win {
        constant MARIO(12)
        constant LUIGI(12)
        constant SAMUS(13)
        constant DK(14)
        constant KIRBY(15)
        constant FOX(16)
        constant NESS(17)
        constant YOSHI(18)
        constant FALCO(19)
        constant PIKACHU(20)
        constant JIGGLYPUFF(20)
        constant LINK(21)
    }

    scope menu {
        constant CHARACTER_SELECT(10)
        constant RESULTS(22)
        constant BONUS(26)
        constant STAGE_CLEAR(27)
        constant STAGE_CLEAR_BONUS(28)
        constant STAGE_CLEAR_MASTER_HAND(29)
        constant STAGE_CLEAR_BOSS(29)
        constant STAGE_FAIL(30)
        constant CONTINUE(31)
        constant GAME_OVER(32)
        constant INTRO(33)
        constant SINGLEPLAYER(35)
        constant GAME_COMPLETE(38)
        constant CREDITS(39)
        constant SECRET(40)
        constant HIDDEN_CHARACTER(41)
        constant DATA(43)
        constant MAIN(44)
        constant MAIN_MELEE(71) // TODO: update when we have
        constant MAIN_BRAWL(108) // TODO: update when we have
    }

    scope special {
        constant UNKNOWN(11)
        constant TRAINING(42)
        constant HAMMER(45)
        constant INVINCIBLE(46)
    }

}

} // __BGM__
