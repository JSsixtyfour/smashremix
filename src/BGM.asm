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
    // This hook runs right after the stage file is loaded.
    // This contains the default stage bgm_id, so this hook let's us override with alt/random music.
    scope apply_alt_or_random_music_: {
        OS.patch_start(0x77B14, 0x800FC314)
        jal     apply_alt_or_random_music_
        sw      t9, 0x0000(a1)              // original line 1
        OS.patch_end()

        sw      ra, 0x0014(sp)              // save ra in free stack space

        // t9 is never touched in the following routines, so not saving to stack

        jal     alternate_music_
        nop

        jal     random_music_
        nop

        lw      ra, 0x0014(sp)              // restore ra
        jr      ra                          // return
        lw      v1, 0x0040(t9)              // original line 2
    }
	
	default_track:
	dw	0
	

    // @ Description
    // This function replaces the stage's default bgm_id with alternate ids defined for the stage, sometimes.
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

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // save registers

        lui     a0, 0x8013
        lw      a0, 0x1300(a0)              // a0 = stage file
        lw      a1, 0x007C(a0)              // a1 = default stage bgm_id
	
        // check if there is an override
		// TODO: Make sure this works
        // li      t0, Global.match_info       // ~
        // lw      t0, 0x0000(t0)              // t0 = match_info
        // lbu     t0, 0x0001(t0)              // t0 = current stage id
        // sll		t0, t0, 1					// t0 = offset in music override table
        // li		at, Stages.default_music_track_table
        // addu 	t0, t0, at					// t0 = stages entry in music override table
        // lh		t0, 0x0000(t0)				// t0 = stages override
        // beqz    t0, _set_default_track		// branch if no override value
        // nop
        // addiu   t0, t0, -1					// correct track id
        // move	a1, t0						// replace a1 with override value
        // sw      t0, 0x007C(a0)              // set default bgm_id
	
        // _set_default_track:
        li		at, default_track			// at = address we use to store stages default track
        sw		a1, 0x0000(at)				// save default track id

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
        ori     a0, r0, 0x0002              // then use the Rare song

        // check for salty song preservation
        li      t0, Toggles.entry_preserve_salty_song
        lw      t0, 0x0004(t0)              // t0 = 0 if OFF, 1 if ON
        li      a0, current_track           // a0 = address of current_track
        beqz    t0, alt_music               // branch accordingly
        li      t0, GameEnd.is_salty_runback// t0 = salty runback flag
        lw      t0, 0x0000(t0)              // t0 = 1 if salty runback
        bnezl   t0, _save                   // branch accordingly
        lw      a1, 0x0000(a0)              // a1 = current_track

        alt_music:
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
        bnel    v0, t0, _save               // if (there is alt BGM_ID) for this stage, use it
        addu    a1, r0, v0                  // a1 = bgm_id to use

        _save:
        // remember bgm_id
        li      a0, current_track           // a0 = address of current_track
        sw      a1, 0x0000(a0)              // store current_track
        lui     a0, 0x8013
        lw      a0, 0x1300(a0)              // a0 = stage file
        sw      a1, 0x007C(a0)              // store bgm_id

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
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
        lw      v1, 0x0000(v1)              // v1 = random_count
        beqz    t0, _end                    // end, return false and count
        nop

        // if the song should be added, it is added here. count is also incremented here
        li      t0, random_count            // t0 = address of random_count
        lw      v1, 0x0000(t0)              // v1 = random_count
        sll     t1, v1, 0x0002              // t1 = offset = random_count * 4
        addiu   v1, v1, 0x0001              // v1 = random_count++
        sw      v1, 0x0000(t0)              // update random_count
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

    // @ Description
    // Macro to (maybe) add a song to the random list.
    macro add_to_list(entry, bgm_id) {
        li      a0, {entry}                 // a0 - address of entry
        lli     a1, {bgm_id}                // a1 - bgm_id to add
        jal     add_song_to_random_list_    // add song
        nop
    }

    // @ Description
    // Table of bgm_id (as words, 32 bit values)
    random_table:
    fill 4 * MIDI.midi_count                // allows for space for all songs, which is actually more than we need

    // @ Description
    // number of stages in random_table.
    random_count:
    dw 0

    // @ Description
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
    // This function replaces the stage's default bgm_id with a random id from the table.
    scope random_music_: {
        // check for pause dpad music randomization (toggle is disregarded here)
        li      t2, Pause.dpad_song_cycle_timer   // t2 = dpad_song_cycle_timer
        lw      t2, 0x0000(t2)              // t2 = 0 if true
        beqz    t2, _build_random_list      // branch accordingly (sneak past guard)
        nop
        Toggles.guard(Toggles.entry_random_music, 0x00000000)

        _build_random_list:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~

        // reset count each time so we don't grow the list too large
        li      v1, random_count            // v1 = random_count address
        sw      r0, 0x0000(v1)              // set random_count to 0

        // this block builds the list of stages available in the random list (using macro above)
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

        li      t0, Pause.dpad_song_cycle_timer   // t0 = dpad_song_cycle_timer
        lw      t0, 0x0000(t0)              // t0 = 0 if true
        beqz    t0, _end                    // if we are doing pause dpad music randomization, skip to end
        nop
        beqz    v1, _end                    // if there were no valid entries in the random table, then use default bgm_id
        nop

        // check for salty song preservation
        li      t0, Toggles.entry_preserve_salty_song
        lw      t0, 0x0004(t0)              // t0 = 0 if OFF, 1 if ON
        li      s3, current_track           // s3 = address of current_track
        beqz    t0, randomize_music         // branch accordingly
        lw      v0, 0x0000(s3)              // v0 = current_track
        li      t0, GameEnd.is_salty_runback// t0 = salty runback flag
        lw      t0, 0x0000(t0)              // t0 = 1 if salty runback
        bnez    t0, load_random_track       // branch accordingly
        nop

        randomize_music:
        // this block loads from the random list using a random int
        move    a0, v1                      // a0 - range (0, N-1)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        sw      v0, 0x0000(s3)              // store v0 as current random track

        load_random_track:
        li      t0, random_table            // t0 = random_table
        sll     v0, v0, 0x0002              // v0 = offset = random_int * 4
        addu    t0, t0, v0                  // t0 = random_table + offset
        lw      a1, 0x0000(t0)              // a1 = bgm_id

        // remember bgm_id
        sw      a1, 0x007C(t9)              // store bgm_id as default stage bgm_id

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
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
        lli     t1, 0x0004                  // t1 = 4 (OFF)
        beq     t1, t0, _menu_music_off     // if OFF, then stop music
        nop

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

        _menu_music_off:
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

    // @ Description
    // Sets up music title stuff
    scope setup_: {
        li      t0, show_music_title_.music_title_rectangle_object
        sw      r0, 0x0000(t0)              // clear music title rectangle object pointer

        li      t0, show_music_title_.music_title_object
        sw      r0, 0x0000(t0)              // clear music title object pointer

        li      t0, show_music_title_.music_game_title_object
        sw      r0, 0x0000(t0)              // clear music game title object pointer

        // Need to load font for music title
        li      t0, Toggles.entry_show_music_title
        lw      t0, 0x0004(t0)              // t0 = 0 if showing titles is toggled off
        beqz    t0, _end                    // skip loading font if showing titles is toggled off
        nop

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        Render.load_font()

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Shows the title of the current track on VS start
    scope show_music_title_: {
        // 8011268C is where GO lights are created
        OS.patch_start(0x8E00C, 0x8011280C)
        j       show_music_title_
        nop
        OS.patch_end()
        // 801120D4 is where GO! text is created
        OS.patch_start(0x8D900, 0x80112100)
        j       show_music_title_._destroy
        nop
        _destroy_return:
        OS.patch_end()

        li      t0, Toggles.entry_show_music_title
        lw      t0, 0x0004(t0)              // t0 = 0 if showing titles is toggled off
        beqz    t0, _end                    // skip if showing titles is toggled off
        nop
        li      t0, Toggles.entry_play_music
        lw      t0, 0x0004(t0)              // t0 = 0 if music is toggled off
        beqz    t0, _end                    // skip if music is toggled off
        nop

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~
        sw      s5, 0x0018(sp)              // ~
        sw      s6, 0x001C(sp)              // ~

        // Draw transparent rectangle
        Render.draw_rectangle(0x17, 0xB, 1, 156, 320, 28, 0x34343494, OS.TRUE)

        li      t0, music_title_rectangle_object
        sw      v0, 0x0000(t0)              // save music title rectangle object pointer

        // Use space in the rectangle object to create our string.
        // We're going to use 0x48 as the start, and we're clear until 0x7C I think
        lli     t1, 0x8020                  // t1 = musical note + space
        sh      t1, 0x0048(v0)              // store string start
        addiu   t2, v0, 0x004A              // t2 = start of music title string
        addiu   a2, v0, 0x0048              // a2 = start of music title string with music note

        // Get BGM ID
        lui     t0, 0x8013
        lw      t0, 0x1300(t0)
        lw      t0, 0x007C(t0)              // t0 = bgm_id

        // Get title
        li      t1, string_table
        sll     t0, t0, 0x0003              // t0 = offset to title pointer array
        addu    t0, t1, t0                  // t0 = address of title pointer array
        sw      t0, 0x0020(sp)              // save address of title pointer array
        lw      t0, 0x0004(t0)              // a2 = track title pointer

        _loop:
        lbu     t1, 0x0000(t0)              // t1 = character
        beqz    t1, _exit_loop              // if string is done, exit loop
        sb      t1, 0x0000(t2)              // copy character to our string buffer
        addiu   t0, t0, 0x0001              // t0++
        b       _loop                       // continue looping
        addiu   t2, t2, 0x0001              // t2 ++

        _exit_loop:
        lli     t1, 0x0020                  // t1 = space
        sb      t1, 0x0000(t2)              // store space
        addiu   t2, t2, 0x0001              // t2 ++
        lli     t1, 0x0080                  // t1 = musical note
        sb      t1, 0x0000(t2)              // store musical note
        addiu   t2, t2, 0x0001              // t2 ++
        lli     t1, 0x0000                  // t1 = null to terminate string
        sb      t1, 0x0000(t2)              // store null to terminate string

        // Display title
        lli     a0, 0x0017                  // a0 = room
        lli     a1, 0x000B                  // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lui     s1, 0x4320                  // s1 = ulx
        lui     s2, 0x431E                  // s2 = uly
        addiu   s3, r0, -0x0001             // s3 = color (WHITE)
        lui     s4, 0x3F80                  // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = align center
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, 0x0001                  // t8 = blur on

        li      t0, music_title_object
        sw      v0, 0x0000(t0)              // save music title object pointer

        // Display game title
        lw      a2, 0x0020(sp)              // a2 = address of title pointer array
        lw      a2, 0x0000(a2)              // a2 = game title pointer

        lli     a0, 0x0017                  // a0 = room
        lli     a1, 0x000B                  // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lui     s1, 0x4320                  // s1 = ulx
        lui     s2, 0x432C                  // s2 = uly
        addiu   s3, r0, -0x0001             // s3 = color (WHITE)
        lui     s4, 0x3F40                  // s4 = scale
        lli     s5, Render.alignment.CENTER // s5 = align center
        lli     s6, Render.string_type.TEXT // s6 = type
        jal     Render.draw_string_
        lli     t8, 0x0001                  // t8 = blur on

        li      t0, music_game_title_object
        sw      v0, 0x0000(t0)              // save music game title object pointer

        _restore_stack:
        lw      ra, 0x0004(sp)              // ~
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0010(sp)              // ~
        lw      s5, 0x0010(sp)              // ~
        lw      s6, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra                          // original line 1
        addiu   sp, sp, 0x0030              // original line 2

        _destroy:
        li      t0, Toggles.entry_show_music_title
        lw      t0, 0x0004(t0)              // t0 = 0 if showing titles is toggled off
        beqz    t0, _end_destroy            // skip if showing titles is toggled off
        nop
        li      t0, Toggles.entry_play_music
        lw      t0, 0x0004(t0)              // t0 = 0 if music is toggled off
        beqz    t0, _end_destroy            // skip if music is toggled off
        nop

        li      t0, music_game_title_object
        lw      a0, 0x0000(t0)              // a0 = music game title object pointer
        beqz    a0, _end_destroy            // if not defined, skip destroying
        nop
        jal     Render.DESTROY_OBJECT_
        sw      r0, 0x0000(t0)              // clear pointer

        li      t0, music_title_object
        lw      a0, 0x0000(t0)              // a0 = music title object pointer
        beqz    a0, _end_destroy            // if not defined, skip destroying
        nop
        jal     Render.DESTROY_OBJECT_
        sw      r0, 0x0000(t0)              // clear pointer

        li      t0, music_title_rectangle_object
        lw      a0, 0x0000(t0)              // a0 = music title rectangle object pointer
        beqz    a0, _end_destroy            // if not defined, skip destroying
        nop
        jal     Render.DESTROY_OBJECT_
        sw      r0, 0x0000(t0)              // clear pointer

        _end_destroy:
        addiu   a0, r0, 0x03F8              // original line 1
        j       _destroy_return
        or      a1, r0, r0                  // original line 2

        music_title_rectangle_object:
        dw      0x0

        music_title_object:
        dw      0x0

        music_game_title_object:
        dw      0x0
    }

    // @ Description
    // Pointers to BGM titles and game of origin in order of BGM ID
    string_table:
    // game                                        // track
    dw MIDI.game_{MIDI.GAME_kirbysuperstar}_title, Toggles.entry_random_music_dream_land + 0x28
    dw MIDI.game_{MIDI.GAME_metroid}_title,        Toggles.entry_random_music_planet_zebes + 0x28
    dw MIDI.game_{MIDI.GAME_smb}_title,            Toggles.entry_random_music_mushroom_kingdom + 0x28
    dw 0x0,                                        0x0                                                    // MK fast
    dw MIDI.game_{MIDI.GAME_starfox64}_title,      Toggles.entry_random_music_sector_z + 0x28
    dw MIDI.game_{MIDI.GAME_dkc}_title,            Toggles.entry_random_music_congo_jungle + 0x28
    dw MIDI.game_{MIDI.GAME_smb}_title,            Toggles.entry_random_music_peachs_castle + 0x28
    dw MIDI.game_{MIDI.GAME_pokemonred}_title,     Toggles.entry_random_music_saffron_city + 0x28
    dw MIDI.game_{MIDI.GAME_yoshis_story}_title,   Toggles.entry_random_music_yoshis_island + 0x28
    dw MIDI.game_{MIDI.GAME_zelda}_title,          Toggles.entry_random_music_hyrule_castle + 0x28
    dw 0x0,                                        0x0                                                    // Character Select
    dw 0x0,                                        0x0                                                    // beta fanfair
    dw 0x0,                                        0x0                                                    // Mario/ Luigi victory
    dw 0x0,                                        0x0                                                    // Samus victory
    dw 0x0,                                        0x0                                                    // DK victory
    dw 0x0,                                        0x0                                                    // Kirby victory
    dw 0x0,                                        0x0                                                    // Fox victory
    dw 0x0,                                        0x0                                                    // Ness victory
    dw 0x0,                                        0x0                                                    // Yoshi victory
    dw 0x0,                                        0x0                                                    // Falcon victory
    dw 0x0,                                        0x0                                                    // Pikachu/Jigglypuff victory
    dw 0x0,                                        0x0                                                    // Link victory
    dw 0x0,                                        0x0                                                    // Results
    dw 0x0,                                        0x0                                                    // Master Hand 1
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_final_destination + 0x28    // Master Hand 2 (intro) - putting the title to avoid crash on FD
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_final_destination + 0x28
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_bonus + 0x28
    dw 0x0,                                        0x0                                                    // Stage Clear
    dw 0x0,                                        0x0                                                    // Stage Clear Bonus
    dw 0x0,                                        0x0                                                    // Stage Clear Master Hand/Boss
    dw 0x0,                                        0x0                                                    // Stage Fail
    dw 0x0,                                        0x0                                                    // Continue
    dw 0x0,                                        0x0                                                    // Game Over
    dw 0x0,                                        0x0                                                    // Intro
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_how_to_play + 0x28
    dw 0x0,                                        0x0                                                    // Singleplayer
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_duel_zone + 0x28
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_meta_crystal + 0x28
    dw 0x0,                                        0x0                                                    // Game Complete
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_credits + 0x28
    dw 0x0,                                        0x0                                                    // Secret
    dw 0x0,                                        0x0                                                    // Hidden Character
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Training.string_training_mode
    dw MIDI.game_{MIDI.GAME_ssb}_title,            Toggles.entry_random_music_data + 0x28
    dw 0x0,                                        0x0                                                    // Main
    dw 0x0,                                        0x0                                                    // Hammer
    dw 0x0,                                        0x0                                                    // Invincible
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            dw MIDI.game_{MIDI.GAME_{MIDI.MIDI_{n}_GAME}}_title, Toggles.entry_random_music_{n} + 0x28
        } else {
            dw 0x0, 0x0
        }
        evaluate n({n}+1)
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
        constant FALCON(19)
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
        constant MAIN_MELEE(71)
        constant MAIN_BRAWL(108)
    }

    scope special {
        constant UNKNOWN(11)
        constant TRAINING(42)
        constant HAMMER(45)
        constant INVINCIBLE(46)
    }

    current_track:
    dw -1
	
	// @ Description
	// Location where current track is written in vanilla.
	constant vanilla_current_track(0x8013139C)

}

} // __BGM__
