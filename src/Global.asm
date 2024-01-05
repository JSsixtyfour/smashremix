// Global.asm
if !{defined __GLOBAL__} {
define __GLOBAL__()
print "included Global.asm\n"

// @ Description
// This file enumerates several of SSB's global variables.

scope Global {
    // @ Description
    // Original SSB function. It move nBytes from the given ROM address to the given RAM address
    // @ Arguments
    // a0 - ROM address | 0x00FFFFFF
    // a1 - RAM vAddress
    // a2 - nBytes
    constant dma_copy_(0x80002CA0)

    // @ Description
    // Writing 0x00000001 to this word will load the screen at current_screen.
    constant screen_interrupt(0x800465D0)

    // @ Description
    // Gets a random int from (0, N-1)
    // @ Arguments
    // a0 - N
    constant get_random_int_(0x80018994)

    // @ Description
    // Gets a random int from (0, N-1), perhaps a bit more random than get_random_int_
    // @ Arguments
    // a0 - N
    constant get_random_int_alt_(0x80018A30)

    // @ Description
    // Byte, Current screen value is here (CSS = 0x10, Debug = 0x03/0x04)
    constant current_screen(0x800A4AD0)

    // @ Description
    // Byte, previous screen value is here
    constant previous_screen(0x800A4AD1)

    // @ Description
    // Word, frame count for current screen
    constant current_screen_frame_count(0x8003B6E4)

    // @ Description
    // Screen IDs
    scope screen {
        constant NO_CONTROLLER(0x00)
        constant TITLE_AND_1P(0x01)    // Title, 1p game over screen, 1p battle, remix 1p battle
        constant BATTLE_DEBUG(0x02)    // Launches Peach's Castle if you select Mario
        constant DEBUG(0x03)
        constant BATTLE_DEBUG2(0x04)

        constant MODE_SELECT(0x07)
        constant _1P_GAME_MODE_MENU(0x08)
        constant VS_GAME_MODE_MENU(0x09)
        constant VS_OPTIONS(0x0A)
        constant VS_OPTIONS_ITEM_SWITCH(0x0B)
        constant UNLOCK(0x0C)          // The one with the exclamation point in a circle
        constant CHALLENGER_APPROACHING(0x0D)

        constant _1P_LOADING_SCREEN(0x0E)
        constant SCREEN_ADJUST(0x0F)
        constant VS_CSS(0x10)
        constant _1P_CSS(0x11)
        constant TRAINING_CSS(0x12)
        constant BONUS_1_CSS(0x13)
        constant BONUS_2_CSS(0x14)
        constant STAGE_SELECT(0x15)    // Applies to all modes
        constant VS_BATTLE(0x16)
        constant DEMO(0x17)            // Where the camera is close up on each character?
        constant RESULTS(0x18)
        constant DATA_VS_RECORD(0x19)
        constant DATA_CHARACTERS(0x1A)
        constant N64_LOGO(0x1B)        // Intro cutscene starts here
        constant INTRO_1(0x1C)         // Opening
        constant INTRO_2(0x1D)         // Portrait Flashing
        constant INTRO_3(0x1E)         // Mario closeup
        constant INTRO_4(0x1F)         // DK closeup
        constant INTRO_6(0x20)         // Samus closeup
        constant INTRO_9(0x21)         // Fox closeup
        constant INTRO_5(0x22)         // Link closeup
        constant INTRO_7(0x23)         // Yoshi closeup
        constant INTRO_10(0x24)        // Pikachu closeup
        constant INTRO_8(0x25)         // Kirby closeup
        constant INTRO_11(0x26)        // Running
        constant INTRO_15(0x27)        // Yoshi nest
        constant INTRO_12(0x28)        // Showdown Link closeup
        constant INTRO_17(0x29)        // Showdown Mario v Kirby
        constant INTRO_13(0x2A)        // Pikachu on Pokeball closeup
        constant INTRO_18(0x2B)        // 8 characters colliding w/ping
        constant INTRO_16(0x2C)        // Fox in Arwing closeup
        constant INTRO_14(0x2D)        // DK v Samus
        constant INTRO_19(0x2E)        // Unlockable 4 glimpse
        constant BACKUP_CLEAR(0x2F)
        constant OUTRO_SCENE(0x30)     // Character on table, camera slowly walks away, fade to white

        constant _1P_STAGE_CLEAR(0x32)
        constant _1P_RESULTS(0x33)      // Results after clearing a stage or bonus stage
        constant _1P_MATCH(0x34)        // ???
        constant BONUS(0x35)           // Bonus 1, Bonus 2, Bonus 3 (BTT/BTP/RTTF)
        constant TRAINING_MODE(0x36)
        constant CONGRATULATIONS(0x37)
        constant STAFF_ROLL(0x38)
        constant OPTION(0x39)
        constant DATA_MENU(0x3A)
        constant DATA_SOUND_TEST(0x3B)
        constant HOW_TO_PLAY(0x3C)
        constant DEMO_FIGHT(0x3D)      // 4 CPUs on dreamland or on planet zebes

        constant REMIX_MODES(0x77)     // Remix Modes (other than Remix 1P) All-star, Multiman, HRC
    }

    // @ Description
    scope vs {
        // @ Description
        // Byte, contains the versus stage stage id
        constant stage(0x800A4D09)

        // @ Description
        // Byte, boolean for if teams are enabled, 0 = off, 1 = on
        constant teams(0x800A4D0A)

        // @ Description
        // Byte, 1 = time, 2 = stock, 3 = both
        constant game_mode(0x800A4D0B)

        // @ Description
        // Byte, 2 = 2 min, 100 = infinite
        constant time(0x800A4D0E)

        // @ Description
        // Byte, 0 = 1 stock
        constant stocks(0x800A4D0F)

        // @ Description
        // Byte, 0 = off, 1 = on, 2 = auto
        constant handicap(0x800A4D10)

        // @ Description
        // Byte, 0 = off, 1 = on
        constant team_attack(0x800A4D11)

        // @ Description
        // Byte, 0 = off, 1 = on
        constant stage_select(0x800A4D12)

        // @ Description
        // Byte, 50 = 50%, 200 = 200%
        constant damage(0x800A4D13)

        // @ Description
        // Word, timer in seconds * 60 fps
        constant timer(0x800A4D1C)

        // @ Description
        // Word, time elapsed in seconds * 60 fps
        constant elapsed(0x800A4D20)

        // @ Description
        // Byte, 0 = none, 5 = high
        constant item_frequency(0x800A4D24)

        // @ Description
        // Pointer to player structs on versus screen
        constant P_OFFSET(0x20)
        constant P_DIFF(0x74)
        constant p1(0x800A4D28)
        constant p2(0x800A4D9C)
        constant p3(0x800A4E10)
        constant p4(0x800A4E84)
    }

    // @ Description
    // Pointer to match setting. For versus, (0x0000(this) == 0x800A4D08) which is the address of
    // the above vs scope.
    constant match_info(0x800A50E8)
    scope GAMEMODE: {
        // byte 0x00 of match_info
        constant DEMO(0x00)
        constant VS(0x01)
        constant BONUS(0x02)
        constant HOWTOPLAY(0x03)
        constant INTRO(0x04)
        constant CLASSIC(0x05)
        constant TRAINING(0x07)
    }


    // @ Description
    // list of files loaded in the game
    // @ Format
    // 0x0000 - file
    // 0x0004 - address
    constant files_loaded(0x800D6300)

    // @ Description
    // Puts a flashing overlay on a player (found by [bit])
    // @ Arguments
    // a0 - address of player struct
    // a1 - flash_id
    // a2 - 0 (?)
    constant flash_(0x800E9814)

    // @ Description
    // Engages the rumble pak
    // @ Arguments
    // a0 - port
    // a1 - rumble_id (0x0 - 0xA)
    // a2 - duration
    // NOTE: rumble_ids 0x2, 0x3 and 0x7 get their rumble disabled on action change regardless of duration
    constant rumble_(0x80115530)

    // @ Description
    // player struct list head
    constant p_struct_head(0x80130D84)
    constant P_STRUCT_LENGTH(0x0B50)

    // @ Description
    // hard-coded pointers and routine for dealing with clipping at runtime
    scope stage_clipping: {
        // pointers
        constant objects(0x80131304)
        constant info(0x8013136C)           // Entry size = 0x0A
        constant coordinates(0x80131370)    // Entry size = 0x14

        // routines
        constant disable_clipping(0x800FC604) // disables clipping, where a0 = the index.
    }

    // @ Description
    // A random int routine that is netplay safe and more random than Global.get_random_int_
    scope get_random_int_safe_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      at, 0x0008(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      v1, 0x0014(sp)              // store a0, at, v0, v1 (for safety)
        sw      ra, 0x0018(sp)              // save ra

        li      t8, 0x8003B6E4              // ~
        lw      t8, 0x0000(t8)              // t8 = frame count for current screen
        bnez    t8, _loop                   // if not first frame, continue
        andi    t8, t8, 0x003F              // t8 = frame count % 64

        // otherwise use count
        jal     0x80033490                  // osGetCount
        nop
        andi    t8, v0, 0x003F              // t8 = count % 64

        _loop:
        // advances rng between 1 - 64 times based on frame count
        jal     0x80018910                  // this function advances the rng seed
        nop
        bnez    t8, _loop                   // loop if t8 != 0
        addiu   t8, t8,-0x0001              // subtract 1 from t8

        lw      a0, 0x0004(sp)              // ~
        lw      at, 0x0008(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      v1, 0x0014(sp)              // load a0, at, v0, v1

        jal     get_random_int_             // Global.get_random_int_
        nop

        lw      ra, 0x0018(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

}

} // __GLOBAL__
