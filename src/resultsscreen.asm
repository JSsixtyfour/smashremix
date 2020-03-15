// ResultsScreen.asm (Fray)
// thanks to tehzz for providing documentation
// this file is most likely temporary

include "OS.asm"
include "Global.asm"

scope ResultsScreen {
    // @ Description
    // Patch which changes the results screen loading routine, loads the files for the characters
    // present in the match, rather than all character files.
    scope load_character_files_: {
        OS.patch_start(0x157DF8, 0x80138C58)
        j       load_character_files_
        nop
        nop
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()
        
        li      s0, Global.vs.p1            // ~
        jal     0x800D786C                  // load character
        lbu     a0, 0x0003(s0)              // a0 = p1 character
        li      s0, Global.vs.p2            // ~
        jal     0x800D786C                  // load character
        lbu     a0, 0x0003(s0)              // a0 = p2 character
        li      s0, Global.vs.p3            // ~
        jal     0x800D786C                  // load character
        lbu     a0, 0x0003(s0)              // a0 = p3 character
        li      s0, Global.vs.p4            // ~
        jal     0x800D786C                  // load character
        lbu     a0, 0x0003(s0)              // a0 = p4 character
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Patch which substitutes working character/opponent ids (0-11) for vs records.
    scope vs_record_fix_: {
        // get character id
        OS.patch_start(0x150DD4, 0x80131C34)
        jal     _character
        nop
        or      s4, at, r0                  // update character id
        OS.patch_end()
        // get opponent id
        OS.patch_start(0x150F08, 0x80131D68)
        jal     _opponent
        nop
        or      v0, at, r0                  // update character id
        OS.patch_end()
        
        _character:
        addu    t5, r0, ra                  // save ra
        lbu     s4, 0x0023(v0)              // s4 = character id (original line 1)
        divu    t7, at                      // original line 2
        jal     _get_id                     // get id
        or      at, s4, r0                  // at = character id
        or      s4, at, r0                  // update character id
        addu    ra, r0, t5                  // restore ra
        jr      ra
        sll     t5, s4, 0x2                 // original line 3
        
        _opponent:
        lbu     v0, 0x0023(v1)              // v0 = opponent id (original line 1)
        sll     t6, s1, 0x2                 // original line 2
        addu    t0, t7, t6                  // original line 3
        or      at, v0, r0                  // at = opponent id
       
        _get_id:
        sll     at, at, 0x0002              // at = id * 4
        li      t6, Character.vs_record.table
        addu    t6, t6, at                  // t6 = vs_record.table + (id * 4)
        lw      at, 0x0000(t6)              // at = new id
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Patch which gets the FGM id for the winning character from an extended table.
    scope get_winner_fgm_: {
        OS.patch_start(0x00151164, 0x80131FC4)
        j       get_winner_fgm_
        nop
        _return:
        jal     0x800269C0                  // play FGM (original line 3)
        nop
        OS.patch_end()

        sll     t7, v0, 0x0002              // t7 = character_id * 4 (original line 1)
        li      a0, Character.winner_fgm.table
        addu    a0, a0, t7                  // a0 = winner_fgm.table + (id * 4)
        lw      a0, 0x0000(a0)              // a0 = FGM id for winning character
        j       _return
        nop
    }
    
    // @ Description
    // Extends the series logo offset table so we can use more than the original character logos
    scope winner_logo_fix_: {
        OS.patch_start(0x151E18, 0x80132C78)
        jal     winner_logo_fix_
        nop
        OS.patch_end()

        // v1 is offset in table (character id * 4)

        li      t7, series_logo_offset_table  // t7 = series_logo_offset_table address
        addu    t7, t7, v1                    // t7 = address of logo offset
        lw      t7, 0x0000(t7)                // t7 = logo offset

        jr      ra                            // return
        nop
    }

    // @ Description
    // Extends the series logo offset table so we can use more than the original character logos
    scope winner_logo_color_fix_: {
        OS.patch_start(0x151E64, 0x80132CC4)
        jal     winner_logo_color_fix_
        nop
        OS.patch_end()

        // t8 is offset in table (character id * 4)

        li      t5, series_logo_color_table   // t5 = series_logo_offset_table address
        addu    t5, t5, t8                    // t5 = address of logo offset
        lw      t5, 0x0000(t5)                // t5 = logo offset

        jr      ra                            // return
        nop
    }

    // @ Description
    // Extends the series logo offset table so we can use more than the original character logos
    scope winner_logo_zoom_fix_: {
        OS.patch_start(0x151E88, 0x80132CE8)
        jal     winner_logo_zoom_fix_
        nop
        OS.patch_end()

        // t1 is offset in table (character id * 4)

        li      t3, series_logo_zoom_table    // t3 = series_logo_offset_table address
        addu    t3, t3, t1                    // t3 = address of logo offset
        lw      t3, 0x0000(t3)                // t3 = logo offset

        jr      ra                            // return
        nop
    }

    // @ Description
    // Patch which substitutes a working character id for determining the player label height.
    // TODO: add support for extending the label height tables, rather than using id substitution
    scope label_height_fix_: {
        // get character id (2 player match?)
        OS.patch_start(0x152D00, 0x80133B60)
        jal     label_height_fix_
        sw      v1, 0x0028(sp)              // original line 2
        OS.patch_end()
        // get character id (3+ player match?)
        OS.patch_start(0x152D58, 0x80133BB8)
        jal     label_height_fix_
        sw      v1, 0x0028(sp)              // original line 2
        OS.patch_end()
        // get character id (no contest)
        OS.patch_start(0x152DB0, 0x80133C10)
        jal     label_height_fix_
        sw      v1, 0x0028(sp)              // original line 2
        OS.patch_end()
        
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      ra, 0x0004(sp)              // store ra
        jal     0x80133148                  // Result.getCharFromPlayer (original line 1)
        nop
        sll     v0, v0, 0x0002              // v0 = character id * 4
        li      t6, Character.label_height.table
        addu    t6, t6, v0                  // t6 = label_height.table + (id * 4)
        lw      v0, 0x0000(t6)              // v0 = new character id
        lw      ra, 0x0004(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0008              // deallocate stack space
    }
    
    // @ Description
    // Patch which gets the "WINS" string left x position for the winner from an extended table.
    scope get_str_wins_lx_: {
        OS.patch_start(0x1534DC, 0x8013433C)
        j       get_str_wins_lx_
        nop
        _return:
        OS.patch_end()
        
        li      t6, Character.str_wins_lx.table
        addu    t6, t6, t4                  // t6 = str_win_lx.table + (id * 4)
        lw      a1, 0x0000(t6)              // a1 = left x position of "WINS" string
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Patch which gets the string pointer, left x position, and x scaling for the winning
    // character's name string from extended tables.
    scope get_str_winner_info_: {
        OS.patch_start(0x1535E0, 0x80134440)
        j       get_str_winner_info_
        nop
        nop
        nop
        nop
        nop
        _return:
        OS.patch_end()
        
        // v1 = id * 4
        li      t5, Character.str_winner_scale.table
        addu    t5, t5, v1                  // t5 = str_winner_scale.table + (id * 4)
        lwc1    f4, 0x0000(t5)              // f4 = string x scale
        li      t5, Character.str_winner_lx.table
        addu    t5, t5, v1                  // t5 = str_winner_lx.table + (id * 4)
        lw      a1, 0x0000(t5)              // a1 = string left x position
        li      t5, Character.str_winner_ptr.table
        addu    t5, t5, v1                  // t5 = str_winner_ptr.table + (id * 4)
        lw      a0, 0x0000(t5)              // a0 = string pointer
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Patch which adjusts the max number of characters in the bgm jump table, and loads the
    // victory bgm address from an extended table.
    scope get_victory_bgm_: {
        OS.patch_start(0x1578CC, 0x8013872C)
        constant UPPER(Character.winner_bgm.table >> 16)
        constant LOWER(Character.winner_bgm.table & 0xFFFF)
        sltiu   at, v0, Character.NUM_CHARACTERS
        beq     at, r0, 0x80138818          // original line 2
        or      a0, r0, r0                  // original line 3
        sll     t6, v0, 0x2                 // original line 4
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)       // modified original line 5
        } else {
            lui     at, UPPER               // modified original line 5
        }
        addu    at, at, t6                  // original line 6
        lw      t6, LOWER(at)               // original line 7
        OS.patch_end()
    }
    
    // @ Description
    // Adds a victory bgm routine for winner_bgm.table
    macro add_victory_bgm(bgm) {
        or      a0, r0, r0                  // original line 1
        jal     0x80020AB4                  // play bgm (original line 2)
        ori     a1, r0, {bgm}               // a1 = bgm id (modified original line 3)
        j       0x80138824                  // original line 4
        lw      ra, 0x0014(sp)              // original line 5
    }

    // @ Description
    // Logo offsets in file 0x23
    scope series_logo: {
        constant MARIO_BROS(0x0990)
        constant STARFOX(0x21D0)
        constant DONKEY_KONG(0x1348)
        constant METROID(0x1860)
        constant ZELDA(0x2520)
        constant YOSHI(0x2F10)
        constant FZERO(0x3828)
        constant KIRBY(0x3E68)
        constant POKEMON(0x4710)
        constant EARTHBOUND(0x5A00)
        constant SMASH(0x5E10)
        constant DR_MARIO(0x6420)
    }

    // @ Description
    // logo color offsets
    scope series_logo_color: {
        constant MARIO_BROS(0x0000)
        constant STARFOX(0x1940)
        constant DONKEY_KONG(0x0B00)
        constant METROID(0x1470)
        constant ZELDA(0x22B0)
        constant YOSHI(0x2690)
        constant FZERO(0x2FF0)
        constant KIRBY(0x3900)
        constant POKEMON(0x3F40)
        constant EARTHBOUND(0x4840)
        constant SMASH(POKEMON)
        constant DR_MARIO(MARIO_BROS)
    }

    // @ Description
    // logo zoom offsets
    scope series_logo_zoom: {
        constant MARIO_BROS(0x0A14)
        constant STARFOX(0x2254)
        constant DONKEY_KONG(0x13CC)
        constant METROID(0x18E4)
        constant ZELDA(0x25A4)
        constant YOSHI(0x2F94)
        constant FZERO(0x38AC)
        constant KIRBY(0x3EEC)
        constant POKEMON(0x4794)
        constant EARTHBOUND(0x5A84)
        constant SMASH(POKEMON)
        constant DR_MARIO(0x64A4)
    }

    // @ Description
    // extended logo offset table
    series_logo_offset_table:
    constant series_logo_offset_table_origin(origin())
    dw series_logo.MARIO_BROS               // Mario
    dw series_logo.STARFOX                  // Fox
    dw series_logo.DONKEY_KONG              // Donkey Kong
    dw series_logo.METROID                  // Samus
    dw series_logo.MARIO_BROS               // Luigi
    dw series_logo.ZELDA                    // Link
    dw series_logo.YOSHI                    // Yoshi
    dw series_logo.FZERO                    // Captain Falcon
    dw series_logo.KIRBY                    // Kirby
    dw series_logo.POKEMON                  // Pikachu
    dw series_logo.POKEMON                  // Jigglypuff
    dw series_logo.EARTHBOUND               // Ness
    dw series_logo.SMASH
    dw series_logo.MARIO_BROS
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.SMASH
    dw series_logo.DONKEY_KONG
    dw 0x00000000
    dw 0x00000000
    // add space for new characters
    fill (series_logo_offset_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    // @ Description
    // extended logo color table
    series_logo_color_table:
    constant series_logo_color_table_origin(origin())
    dw series_logo_color.MARIO_BROS               // Mario
    dw series_logo_color.STARFOX                  // Fox
    dw series_logo_color.DONKEY_KONG              // Donkey Kong
    dw series_logo_color.METROID                  // Samus
    dw series_logo_color.MARIO_BROS               // Luigi
    dw series_logo_color.ZELDA                    // Link
    dw series_logo_color.YOSHI                    // Yoshi
    dw series_logo_color.FZERO                    // Captain Falcon
    dw series_logo_color.KIRBY                    // Kirby
    dw series_logo_color.POKEMON                  // Pikachu
    dw series_logo_color.POKEMON                  // Jigglypuff
    dw series_logo_color.EARTHBOUND               // Ness
    dw series_logo_color.SMASH
    dw series_logo_color.MARIO_BROS
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.SMASH
    dw series_logo_color.DONKEY_KONG
    dw 0x00000000
    dw 0x00000000
    // add space for new characters
    fill (series_logo_color_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    // @ Description
    // extended logo zoom table
    series_logo_zoom_table:
    constant series_logo_zoom_table_origin(origin())
    dw series_logo_zoom.MARIO_BROS               // Mario
    dw series_logo_zoom.STARFOX                  // Fox
    dw series_logo_zoom.DONKEY_KONG              // Donkey Kong
    dw series_logo_zoom.METROID                  // Samus
    dw series_logo_zoom.MARIO_BROS               // Luigi
    dw series_logo_zoom.ZELDA                    // Link
    dw series_logo_zoom.YOSHI                    // Yoshi
    dw series_logo_zoom.FZERO                    // Captain Falcon
    dw series_logo_zoom.KIRBY                    // Kirby
    dw series_logo_zoom.POKEMON                  // Pikachu
    dw series_logo_zoom.POKEMON                  // Jigglypuff
    dw series_logo_zoom.EARTHBOUND               // Ness
    dw series_logo_zoom.SMASH                    // Boss
    dw series_logo_zoom.MARIO_BROS
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.SMASH
    dw series_logo_zoom.DONKEY_KONG
    dw 0x00000000
    dw 0x00000000
    // add space for new characters
    fill (series_logo_zoom_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    // @ Description
    // Adds results screen parameters for a character.
    // @ Arguments
    // id - character id to modify
    // fgm - announcer voice FGM id
    // logo - series logo to use
    // label_y - character id to copy label height from (0-11)
    // wins_lx - float32 left x position of "WINS!" string
    // string - character name string
    // str_lx - float32 left x position of name string
    // str_scale - float32 x scaling of name string
    // bgm - victory BGM id
    macro add_to_results_screen(id, fgm, logo, label_y, wins_lx, string, str_lx, str_scale, bgm) {
        evaluate n({id})

        // add announcer FGM
        Character.table_patch_start(winner_fgm, {id}, 0x4)
        dw  {fgm}
        OS.patch_end()

        pushvar base, origin

        // add logo offset
        origin series_logo_offset_table_origin + ({id} * 0x4)
        define logo_offset(series_logo.{logo})
        dw  {logo_offset}

        // add logo color
        origin series_logo_color_table_origin + ({id} * 0x4)
        define logo_color(series_logo_color.{logo})
        dw  {logo_color}

        // add logo zoom
        origin series_logo_zoom_table_origin + ({id} * 0x4)
        define logo_zoom(series_logo_zoom.{logo})
        dw  {logo_zoom}

        pullvar origin, base

        // add player label height
        Character.table_patch_start(label_height, {id}, 0x4)
        dw  {label_y}
        OS.patch_end()

        // add "WINS!" string lx
        Character.table_patch_start(str_wins_lx, {id}, 0x4)
        float32 {wins_lx}
        OS.patch_end()

        // add character name string
        string_character_{n}:
        db  "{string}"; db 0x00
        OS.align(4)

        // add name string pointer, lx, scale
        Character.table_patch_start(str_winner_ptr, {id}, 0x4)
        dw  string_character_{n}
        OS.patch_end()
        Character.table_patch_start(str_winner_lx, {id}, 0x4)
        float32 {str_lx}
        OS.patch_end()
        Character.table_patch_start(str_winner_scale, {id}, 0x4)
        float32 {str_scale}
        OS.patch_end()

        // add victory bgm routine
        bgm_character_{n}:
        add_victory_bgm({bgm})

        // add bgm routine pointer
        Character.table_patch_start(winner_bgm, {id}, 0x4)
        dw  bgm_character_{n}
        OS.patch_end()
    }

    // ADD CHARACTERS TO RESULTS SCREEN
                          // id                  fgm                                         logo         label_y               wins_lx  string        str_lx  str_scale  bgm
    add_to_results_screen(Character.id.METAL,    FGM.announcer.names.METAL_MARIO,            MARIO_BROS,  Character.id.MARIO,   185,     METAL MARIO,  20,     0.55,      0x0C)
    add_to_results_screen(Character.id.NMARIO,   FGM.announcer.names.POLYGON_MARIO,          SMASH,       Character.id.MARIO,   185,     POLY MARIO,   20,     0.6,       0x0B)
    add_to_results_screen(Character.id.NFOX,     FGM.announcer.names.POLYGON_FOX,            SMASH,       Character.id.MARIO,   185,     POLY FOX,     20,     0.8,       0x0B)
    add_to_results_screen(Character.id.NDONKEY,  FGM.announcer.names.POLYGON_DONKEY_KONG,    SMASH,       Character.id.MARIO,   180,     POLY DK,      25,     0.85,      0x0B)
    add_to_results_screen(Character.id.NSAMUS,   FGM.announcer.names.POLYGON_SAMUS,          SMASH,       Character.id.MARIO,   185,     POLY SAMUS,   20,     0.6,       0x0B)
    add_to_results_screen(Character.id.NLUIGI,   FGM.announcer.names.POLYGON_LUIGI,          SMASH,       Character.id.MARIO,   185,     POLY LUIGI,   20,     0.75,      0x0B)
    add_to_results_screen(Character.id.NLINK,    FGM.announcer.names.POLYGON_LINK,           SMASH,       Character.id.MARIO,   185,     POLY LINK,    20,     0.8,       0x0B)
    add_to_results_screen(Character.id.NYOSHI,   FGM.announcer.names.POLYGON_YOSHI,          SMASH,       Character.id.MARIO,   185,     POLY YOSHI,   20,     0.65,      0x0B)
    add_to_results_screen(Character.id.NCAPTAIN, FGM.announcer.names.POLYGON_CAPTAIN_FALCON, SMASH,       Character.id.MARIO,   185,     POLY FALCON,  20,     0.55,      0x0B)
    add_to_results_screen(Character.id.NKIRBY,   FGM.announcer.names.POLYGON_KIRBY,          SMASH,       Character.id.MARIO,   185,     POLY KIRBY,   20,     0.7,       0x0B)
    add_to_results_screen(Character.id.NPIKACHU, FGM.announcer.names.POLYGON_PIKACHU,        SMASH,       Character.id.MARIO,   185,     POLY PIKACHU, 20,     0.55,      0x0B)
    add_to_results_screen(Character.id.NJIGGLY,  FGM.announcer.names.POLYGON_JIGGLYPUFF,     SMASH,       Character.id.MARIO,   185,     POLY PUFF,    20,     0.75,      0x0B)
    add_to_results_screen(Character.id.NNESS,    FGM.announcer.names.POLYGON_NESS,           SMASH,       Character.id.MARIO,   185,     POLY NESS,    20,     0.75,      0x0B)
    add_to_results_screen(Character.id.GDONKEY,  FGM.announcer.names.GDK,                    DONKEY_KONG, Character.id.DK,      185,     GIANT DK,     20,     0.8,       0x0E)

    add_to_results_screen(Character.id.FALCO,    FGM.announcer.names.FALCO,                  STARFOX,     Character.id.FOX,     170,     FALCO,        30,     1,         0x45)
    add_to_results_screen(Character.id.GND,      FGM.announcer.names.GANONDORF,              ZELDA,       Character.id.CAPTAIN, 185,     GANONDORF,    20,     0.6,       0x43)
    add_to_results_screen(Character.id.YLINK,    FGM.announcer.names.YOUNG_LINK,             ZELDA,       Character.id.LINK,    185,     YOUNG LINK,   20,     0.65,      0x44)
    add_to_results_screen(Character.id.DRM,      FGM.announcer.names.DR_MARIO,               DR_MARIO,    Character.id.MARIO,   185,     DR. MARIO,    20,     0.75,      0x46)
    add_to_results_screen(Character.id.DSAMUS,   FGM.announcer.names.DSAMUS,                 METROID,     Character.id.SAMUS,   185,     DARK SAMUS,   20,     0.6,       0x52)
    add_to_results_screen(Character.id.WARIO,    FGM.announcer.names.WARIO,                  MARIO_BROS,  Character.id.MARIO,   175,     WARIO,        25,     1,         0x5C)
    add_to_results_screen(Character.id.ELINK,    FGM.announcer.names.ELINK,                  ZELDA,       Character.id.LINK,    170,     E LINK,       30,     1,         0x15)
    add_to_results_screen(Character.id.JSAMUS,   FGM.announcer.names.SAMUS,                  METROID,     Character.id.SAMUS,   185,     J SAMUS,      30,     0.75,      0x0D)
    add_to_results_screen(Character.id.JNESS,    FGM.announcer.names.NESS,                   EARTHBOUND,  Character.id.NESS,    170,     J NESS,       20,     1,         0x11)
    add_to_results_screen(Character.id.LUCAS,    FGM.announcer.names.NESS,                   EARTHBOUND,  Character.id.NESS,    170,     LUCAS,        20,     1,         0x11)
}
