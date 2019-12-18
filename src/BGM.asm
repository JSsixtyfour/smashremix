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
    // This function is not yet documented.
    constant stop_(0x00000000)

    // @ Description
    // This function implements the mono/stero toggle (boolean stereo_enabled - 0x8003CB24)
    scope get_type_: {
        OS.patch_start(0x00020F1C, 0x8002031C)
        j       get_type_
        nop
        _get_type_return:
        OS.patch_end()

        lw      t8, 0xCB24(t8)              // original line 1 (t8 = stereo_enabled, overwritten.)
        mfhi    s3                          // original line 2

        li      t8, Toggles.entry_stereo_sound // ~
        lw      t8, 0x0004(t8)              // t8 = custom stereo_enabled
        j       _get_type_return            // return
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

    // @ Descirption
    // number of stages in random_table.
    random_count:
    dw 0

    // @ Descirption
    // This function is an implementation of a play music tooggle
    scope play_music_: {
        OS.patch_start(0x000216B4, 0x80020AB4)
        j       play_music_
        nop
        _play_music_return:
        OS.patch_end()

        Toggles.guard(Toggles.entry_play_music, OS.NULL)
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

        // reset count each time so we don't grow the list too large
        li      v1, random_count            // v1 = random_count address
        sw      r0, 0x0000(v1)              // set random_count to 0

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
        add_to_list(Toggles.entry_random_music_battlefield, stage.BATTLEFIELD)
        add_to_list(Toggles.entry_random_music_final_destination, stage.FINAL_DESTINATION)
        add_to_list(Toggles.entry_random_music_how_to_play, stage.HOW_TO_PLAY)
        add_to_list(Toggles.entry_random_music_data, menu.DATA)
        add_to_list(Toggles.entry_random_music_meta_crystal, stage.META_CRYSTAL)

        // Add custom MIDIs
        define n(0x2F)
        evaluate n({n})
        while {n} < MIDI.midi_count {
            add_to_list(Toggles.entry_random_music_{n}, {n})
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

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers 
        addiu   sp, sp, 0x0018              // deallocate stack space
        j       _random_music_return        // return
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
        constant BATTLEFIELD(36)
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
    }

    scope special {
        constant UNKNOWN(11)
        constant TRAINING(42)
        constant HAMMER(45)
        constant INVINCIBLE(46)
    }

}

} // __BGM__
