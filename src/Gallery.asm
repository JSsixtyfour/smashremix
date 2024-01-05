// Gallery.asm
if !{defined __GALLERY__} {
define __GALLERY__()
print "included Gallery.asm\n"

// @ Description
// This file sets up the "Gallery" screen.

scope Gallery {
    // @ Description
    // defining constants here
    constant FADE_LENGTH_NORMAL(45)
    constant FADE_LENGTH_QUICK(4)
    constant FADE_LENGTH_IDLE(100)
    constant IDLE_TIME(150)

    // @ Description
    // struct that will hold variables for the Gallery screen
    scope status: {
        db 0x00; constant active(0x0000)                    // 0x0000 - bool which tracks if the screen is active
        db 0x00; constant index(0x0001)                     // 0x0001 - holds the current index for Gallery images
        db FADE_LENGTH_NORMAL; constant fade_length(0x0002) // 0x0002 - holds the current fade length
        db 0x00; constant music_index(0x0003)               // 0x0003 - holds the current music index, if 0 play gallery bgm
        db 0x00; constant idle(0x0004)                      // 0x0004 - holds the current idle mode, 0 if idle is off
        db 0x00; constant idle_index(0x0005)                // 0x0005 - holds the current idle index
        dh 0x0000; constant idle_timer(0x0006)              // 0x0006 - holds the current idle timer
        db 0x0000; constant previous_screen(0x0008)         // 0x0008 - holds the previous screen_id for exiting the gallery
        OS.align(4)
    }

    // @ Description
    // Gallery id constants
    scope id {
        constant MARIO(0x00)
        constant DK(0x01)
        constant LINK(0x02)
        constant SAMUS(0x03)
        constant YOSHI(0x04)
        constant KIRBY(0x05)
        constant FOX(0x06)
        constant PIKACHU(0x07)
        constant LUIGI(0x08)
        constant FALCON(0x09)
        constant NESS(0x0A)
        constant JIGGLYPUFF(0x0B)
        constant GANONDORF(0x0C)
        constant YOUNG_LINK(0x0D)
        constant DR_MARIO(0x0E)
        constant FALCO(0x0F)
        constant DARK_SAMUS(0x10)
        constant WARIO(0x11)
        constant LUCAS(0x12)
        constant BOWSER(0x13)
        constant WOLF(0x14)
        constant CONKER(0x15)
        constant MEWTWO(0x16)
        constant MARTH(0x17)
        constant SONIC(0x18)
        constant SHEIK(0x19)
        constant MARINA(0x1A)
        constant DEDEDE(0x1B)
        constant GOEMON(0x1C)
        constant BANJO(0x1D)
        constant SLIPPY_PEPPY(0x1E)
        constant EBI(0x1F)
        constant REMIX(0x20)
    }

    // @ Description
    // table which holds pointers to BGM arrays
    bgm_table:
    dw bgm_mario                            // Mario
    dw bgm_dk                               // Donkey Kong
    dw bgm_link                             // Link
    dw bgm_samus                            // Samus
    dw bgm_yoshi                            // Yoshi
    dw bgm_kirby                            // Kirby
    dw bgm_fox                              // Fox
    dw bgm_pikachu                          // Pikachu
    dw bgm_luigi                            // Luigi
    dw bgm_falcon                           // Captain Falcon
    dw bgm_ness                             // Ness
    dw bgm_jigglypuff                       // Jigglypuff
    dw bgm_ganondorf                        // Ganondorf
    dw bgm_young_link                       // Young Link
    dw bgm_dr_mario                         // Dr. Mario
    dw bgm_falco                            // Falco
    dw bgm_dark_samus                       // Dark Samus
    dw bgm_wario                            // Wario
    dw bgm_lucas                            // Lucas
    dw bgm_bowser                           // Bowser
    dw bgm_wolf                             // Wolf
    dw bgm_conker                           // Conker
    dw bgm_mewtwo                           // Mewtwo
    dw bgm_marth                            // Marth
    dw bgm_sonic                            // Sonic
    dw bgm_sheik                            // Sheik
    dw bgm_marina                           // Marina
    dw bgm_dedede                           // Dedede
    dw bgm_goemon                           // Goemon
    dw bgm_banjo                            // Banjo
    dw bgm_slippy_peppy                     // Slippy & Peppy
    dw bgm_ebi                              // Ebisumaru
    dw bgm_remix                            // You Are Proud

    bgm_mario:
    dh 15                                   // number of BGM
    dh BGM.stage.PEACHS_CASTLE
    dh {MIDI.id.SMB3OVERWORLD}
    dh {MIDI.id.EASTON_KINGDOM}
    dh {MIDI.id.SMW_TITLECREDITS}
    dh {MIDI.id.SMW_ATHLETIC}
    dh {MIDI.id.FILESELECT_SM64}
    dh {MIDI.id.BOB}
    dh {MIDI.id.COOLCOOLMOUNTAIN}
    dh {MIDI.id.SLIDER}
    dh {MIDI.id.N64}
    dh {MIDI.id.WING_CAP}
    dh {MIDI.id.SMRPG_BATTLE}
    dh {MIDI.id.BEWARE_THE_FORESTS_MUSHROOMS}
    dh {MIDI.id.PAPER_MARIO_BATTLE}
    dh {MIDI.id.GHOSTGULPING}


    bgm_luigi:
    dh 12                                    // number of BGM
    dh BGM.stage.MUSHROOM_KINGDOM
    dh {MIDI.id.SMB2_MEDLEY}
    dh {MIDI.id.SNES_RAINBOW}
    dh {MIDI.id.RACEWAYS}
    dh {MIDI.id.TOADS_TURNPIKE}
    dh {MIDI.id.FRAPPE_SNOWLAND}
    dh {MIDI.id.RAINBOWROAD}
    dh {MIDI.id.MK64_CREDITS}
    dh {MIDI.id.PIRATELAND}
    dh {MIDI.id.WIDE_UNDERWATER}
    dh {MIDI.id.HORROR_LAND}
    dh {MIDI.id.STATUS}

    bgm_bowser:
    dh 8                                    // number of BGM
    dh {MIDI.id.BOWSERBOSS}
    dh {MIDI.id.BOWSERROAD}
    dh {MIDI.id.BOWSERFINAL}
    dh {MIDI.id.BIG_BOO}
    dh {MIDI.id.FIGHT_AGAINST_BOWSER}
    dh {MIDI.id.KING_OF_THE_KOOPAS}
    dh {MIDI.id.FORTRESS_BOSS}
    dh {MIDI.id.BABY_BOWSER}

    bgm_dr_mario:
    dh 4                                    // number of BGM
    dh {MIDI.id.DR_MARIO}
    dh {MIDI.id.CHILL}
    dh {MIDI.id.QUEQUE}
    dh {MIDI.id.TALENTSTUDIO}

    bgm_dk:
    dh 8                                    // number of BGM
    dh BGM.stage.CONGO_JUNGLE
    dh {MIDI.id.DKCTITLE}
    dh {MIDI.id.GANGPLANK}
    dh {MIDI.id.JUNGLEJAPES}
    dh {MIDI.id.SNAKEY_CHANTEY}
    dh {MIDI.id.FOREST_INTERLUDE}
    dh {MIDI.id.STICKERBRUSH_SYMPHONY}
    dh {MIDI.id.DK_RAP}

    bgm_link:
    dh 4                                    // number of BGM
    dh BGM.stage.HYRULE_CASTLE
    dh {MIDI.id.HYRULE_TEMPLE}
    dh {MIDI.id.FINALTEMPLE}
    dh {MIDI.id.LINKS_AWAKENING_MEDLEY}

    bgm_young_link:
    dh 4                                    // number of BGM
    dh {MIDI.id.KOKIRI_FOREST}
    dh {MIDI.id.SARIA}
    dh {MIDI.id.ASTRAL_OBSERVATORY}
    dh {MIDI.id.CLOCKTOWN}

    bgm_ganondorf:
    dh 4                                    // number of BGM
    dh {MIDI.id.GANONDORF_BATTLE}
    dh {MIDI.id.DARKWORLD}
    dh {MIDI.id.GANONMEDLEY}
    dh {MIDI.id.MAJORA_MIDBOSS}

    bgm_sheik:
    dh 2                                    // number of BGM
    dh {MIDI.id.BRAWL_OOT}
    dh {MIDI.id.GERUDO_VALLEY}

    bgm_samus:
    dh 3                                    // number of BGM
    dh BGM.stage.PLANET_ZEBES
    dh {MIDI.id.ZEBES_LANDING}
    dh {MIDI.id.CRATERIA_MAIN}

    bgm_dark_samus:
    dh 2                                   // number of BGM
    dh {MIDI.id.NORFAIR}
    dh {MIDI.id.VSRIDLEY}

    bgm_yoshi:
    dh 7                                    // number of BGM
    dh BGM.stage.YOSHIS_ISLAND
    dh {MIDI.id.FLOWER_GARDEN}
    dh {MIDI.id.OBSTACLE}
    dh {MIDI.id.YOSHI_SKA}
    dh {MIDI.id.YOSHI_TALE}
    dh {MIDI.id.TROPICALISLAND}
    dh {MIDI.id.YOSHI_GOLF}

    bgm_kirby:
    dh 5                                   // number of BGM
    dh BGM.stage.DREAM_LAND
    dh {MIDI.id.GREEN_GREENS}
    dh {MIDI.id.POP_STAR}
    dh {MIDI.id.BUMPERCROPBUMP}
    dh {MIDI.id.VS_MARX}

    bgm_dedede:
    dh 6                                   // number of BGM
    dh {MIDI.id.DEDEDE}
    dh {MIDI.id.NIGHTMARE}
    dh {MIDI.id.FOD}
    dh {MIDI.id.HILLTOPCHASE}
    dh {MIDI.id.MK_REVENGE}
    dh {MIDI.id.KIRBY_64_BOSS}

    bgm_fox:
    dh 2                                   // number of BGM
    dh BGM.stage.SECTOR_Z
    dh {MIDI.id.STARFOX_MEDLEY}

    bgm_falco:
    dh 2                                   // number of BGM
    dh {MIDI.id.CORNERIA}
    dh {MIDI.id.VENOM}

    bgm_wolf:
    dh 2                                   // number of BGM
    dh {MIDI.id.STAR_WOLF}
    dh {MIDI.id.SURPRISE_ATTACK}

    bgm_slippy_peppy:
    dh 2                                   // number of BGM
    dh {MIDI.id.AREA6}
    dh {MIDI.id.BOSS_E}

    bgm_pikachu:
    dh 4                                   // number of BGM
    dh BGM.stage.SAFFRON_CITY
    dh {MIDI.id.POKEMON_STADIUM}
    dh {MIDI.id.RBY_GYMLEADER}
    dh {MIDI.id.PIKA_CUP}

    bgm_jigglypuff:
    dh 4                                   // number of BGM
    dh {MIDI.id.GAME_CORNER}
    dh {MIDI.id.SS_AQUA}
    dh {MIDI.id.BATTLE_GOLD_SILVER}
    dh {MIDI.id.GOLDENROD_CITY}

    bgm_mewtwo:
    dh 3                                   // number of BGM
    dh {MIDI.id.POKEFLOATS}
    dh {MIDI.id.POKEMON_CHAMPION}
    dh {MIDI.id.KANTO_WILD_BATTLE}

    bgm_falcon:
    dh 4                                   // number of BGM
    dh {MIDI.id.MUTE_CITY}
    dh {MIDI.id.BIG_BLUE}
    dh {MIDI.id.FZERO_CLIMBUP}
    dh {MIDI.id.MACHRIDER}

    bgm_ness:
    dh 4                                   // number of BGM
    dh {MIDI.id.ONETT}
    dh {MIDI.id.POLLYANNA}
    dh {MIDI.id.BEIN_FRIENDS}
    dh {MIDI.id.DANGEROUS_FOE}

    bgm_lucas:
    dh 5                                   // number of BGM
    dh {MIDI.id.TAZMILY}
    dh {MIDI.id.UNFOUNDED_REVENGE}
    dh {MIDI.id.DCMC}
    dh {MIDI.id.SAMBA_DE_COMBO}
    dh {MIDI.id.EVEN_DRIER_GUYS}

    bgm_wario:
    dh 2                                   // number of BGM
    dh {MIDI.id.WL2_PERFECT}
    dh {MIDI.id.KITCHEN_ISLAND}

    bgm_conker:
    dh 5                                   // number of BGM
    dh {MIDI.id.CONKER_THE_KING}
    dh {MIDI.id.WINDY}
    dh {MIDI.id.SLOPRANO}
    dh {MIDI.id.OLE}
    dh {MIDI.id.ROCKSOLID}

    bgm_marth:
    dh 3                                   // number of BGM
    dh {MIDI.id.FIRE_EMBLEM}
    dh {MIDI.id.WITHMILASDIVINEPROTECTION}
    dh {MIDI.id.HYRULE_TEMPLE}

    bgm_sonic:
    dh 13                                   // number of BGM
    dh {MIDI.id.GREEN_HILL_ZONE}
    dh {MIDI.id.EMERALDHILL}
    dh {MIDI.id.CHEMICAL_PLANT}
    dh {MIDI.id.CASINO_NIGHT}
    dh {MIDI.id.SONIC2_BOSS}
    dh {MIDI.id.SONIC2_SPECIAL}
    dh {MIDI.id.STARDUST}
    dh {MIDI.id.METALLIC_MADNESS}
    dh {MIDI.id.SONICCD_SPECIAL}
    dh {MIDI.id.FLYINGBATTERY}
    dh {MIDI.id.GIANTWING}
    dh {MIDI.id.EVERYTHING}
    dh {MIDI.id.LIVE_AND_LEARN}

    bgm_marina:
    dh 3                                   // number of BGM
    dh {MIDI.id.TROUBLE_MAKER}
    dh {MIDI.id.MM_TITLE}
    dh {MIDI.id.ESPERANCE}


    bgm_goemon:
    dh 3                                   // number of BGM
    dh {MIDI.id.OEDO_EDO}
    dh {MIDI.id.MUSICAL_CASTLE}
    dh {MIDI.id.THE_ALOOF_SOLDIER}

    bgm_ebi:
    dh 1                                   // number of BGM
    dh {MIDI.id.KAI_HIGHWAY}

    bgm_banjo:
    dh 6                                   // number of BGM
    dh {MIDI.id.BANJO_MAIN}
    dh {MIDI.id.SPIRAL_MOUNTAIN}
    dh {MIDI.id.MADMONSTER}
    dh {MIDI.id.BK_FINALBATTLE}
    dh {MIDI.id.MRPATCH}
    dh {MIDI.id.VS_KLUNGO}

    bgm_remix:
    dh 11                                   // number of BGM
    dh BGM.menu.CREDITS
    dh BGM.stage.META_CRYSTAL
    dh BGM.stage.FINAL_DESTINATION
    dh BGM.stage.DUEL_ZONE
    dh BGM.menu.BONUS
    dh BGM.menu.RESULTS
    dh BGM.menu.DATA
    dh BGM.stage.HOW_TO_PLAY
    dh {MIDI.id.CREDITS_BRAWL}
    dh {MIDI.id.GALLERY}
    dh {MIDI.id.TARGET_TEST}
    OS.align(4)

    // @ Description
    // table which holds the character id for a given Gallery index
    id_table:
    constant id_table.SIZE(33)
    db Character.id.MARIO
    db Character.id.DK
    db Character.id.LINK
    db Character.id.SAMUS
    db Character.id.YOSHI
    db Character.id.KIRBY
    db Character.id.FOX
    db Character.id.PIKACHU
    db Character.id.LUIGI
    db Character.id.CAPTAIN
    db Character.id.NESS
    db Character.id.JIGGLYPUFF
    db Character.id.GND
    db Character.id.YLINK
    db Character.id.DRM
    db Character.id.FALCO
    db Character.id.DSAMUS
    db Character.id.WARIO
    db Character.id.LUCAS
    db Character.id.BOWSER
    db Character.id.WOLF
    db Character.id.CONKER
    db Character.id.MTWO
    db Character.id.MARTH
    db Character.id.SONIC
    db Character.id.SHEIK
    db Character.id.MARINA
    db Character.id.DEDEDE
    db Character.id.GOEMON
    db Character.id.BANJO
    db Character.id.SLIPPY
    db Character.id.EBI
    db Character.id.BOSS
    OS.align(4)

    // @ Description
    // table which will be filled with a shuffled list of gallery ids for idle mode
    idle_table:
    fill id_table.SIZE, 0xFF

    // @ Description
    // Adds a Gallery ID to bgm_to_gallery_table
    macro add_bgm_to_gallery(bgm_id, gallery_id) {
        pushvar origin, base

        origin  bgm_table_origin + {bgm_id}
        db      {gallery_id}

        pullvar base, origin
    }

    // @ Description
    // Gallery image IDs in order of BGM ID
    bgm_to_gallery_table:
    constant bgm_table_origin(origin())
    db id.KIRBY     // Dream Land
    db id.SAMUS     // Planet Zebes
    db id.LUIGI     // Mushroom Kingdom
    db id.LUIGI     // MK fast
    db id.FOX       // Sector Z
    db id.DK        // Congo Jungle
    db id.MARIO     // Peach's Castle
    db id.PIKACHU   // Saffron City
    db id.YOSHI     // Yoshi's Island
    db id.LINK      // Hyrule Castle
    db id.REMIX     // Character Select
    db id.REMIX     // beta fanfair
    db id.REMIX     // Mario/ Luigi victory
    db id.REMIX     // Samus victory
    db id.REMIX     // DK victory
    db id.REMIX     // Kirby victory
    db id.REMIX     // Fox victory
    db id.REMIX     // Ness victory
    db id.REMIX     // Yoshi victory
    db id.REMIX     // Falcon victory
    db id.REMIX     // Pikachu/Jigglypuff victory
    db id.REMIX     // Link victory
    db id.REMIX     // Results
    db id.REMIX     // Master Hand 1
    db id.REMIX     // Master Hand 2 (intro) - putting the title to avoid crash on FD
    db id.REMIX     // Final Destination
    db id.REMIX     // Bonus
    db id.REMIX     // Stage Clear
    db id.REMIX     // Stage Clear Bonus
    db id.REMIX     // Stage Clear Master Hand/Boss
    db id.REMIX     // Stage Fail
    db id.REMIX     // Continue
    db id.REMIX     // Game Over
    db id.REMIX     // Intro
    db id.REMIX     // How to Play
    db id.REMIX     // Singleplayer
    db id.REMIX     // Duel Zone
    db id.REMIX     // Meta Crystal
    db id.REMIX     // Game Complete
    db id.REMIX     // Credits
    db id.REMIX     // Secret
    db id.REMIX     // Hidden Character
    db id.REMIX     // Training Mode
    db id.REMIX     // Data
    db id.REMIX     // Main
    db id.REMIX     // Hammer
    db id.REMIX     // Invincible
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        db id.REMIX
        evaluate n({n}+1)
    }
    OS.align(4)

    add_bgm_to_gallery({MIDI.id.GANONDORF_BATTLE}, id.GANONDORF)
    add_bgm_to_gallery({MIDI.id.CORNERIA}, id.FALCO)
    add_bgm_to_gallery({MIDI.id.KOKIRI_FOREST}, id.YOUNG_LINK)
    add_bgm_to_gallery({MIDI.id.DR_MARIO}, id.DR_MARIO)
    add_bgm_to_gallery({MIDI.id.GAME_CORNER}, id.JIGGLYPUFF)
    add_bgm_to_gallery({MIDI.id.STONECARVING_CITY}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.COOLCOOLMOUNTAIN}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.GODDESSBALLAD}, id.SHEIK)
    add_bgm_to_gallery({MIDI.id.SARIA}, id.YOUNG_LINK)
    add_bgm_to_gallery({MIDI.id.FOD}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.MUDA}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.SPIRAL_MOUNTAIN}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.N64}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.MUTE_CITY}, id.FALCON)
    add_bgm_to_gallery({MIDI.id.MADMONSTER}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.GREEN_GREENS}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.NORFAIR}, id.DARK_SAMUS)
    add_bgm_to_gallery({MIDI.id.BOWSERBOSS}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.POKEMON_STADIUM}, id.PIKACHU)
    add_bgm_to_gallery({MIDI.id.BOWSERROAD}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.BOWSERFINAL}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.SMB3OVERWORLD}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.DELFINO}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.VS_KLUNGO}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.BIG_BLUE}, id.FALCON)
    add_bgm_to_gallery({MIDI.id.ONETT}, id.NESS)
    add_bgm_to_gallery({MIDI.id.ZEBES_LANDING}, id.SAMUS)
    add_bgm_to_gallery({MIDI.id.EASTON_KINGDOM}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.WING_CAP}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.RBY_GYMLEADER}, id.PIKACHU)
    add_bgm_to_gallery({MIDI.id.KITCHEN_ISLAND}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.DKCTITLE}, id.DK)
    add_bgm_to_gallery({MIDI.id.MACHRIDER}, id.FALCON)
    add_bgm_to_gallery({MIDI.id.POKEFLOATS}, id.MEWTWO)
    add_bgm_to_gallery({MIDI.id.GERUDO_VALLEY}, id.SHEIK)
    add_bgm_to_gallery({MIDI.id.POP_STAR}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.STAR_WOLF}, id.WOLF)
    add_bgm_to_gallery({MIDI.id.STARRING_WARIO}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.POKEMON_CHAMPION}, id.MEWTWO)
    add_bgm_to_gallery({MIDI.id.HYRULE_TEMPLE}, id.LINK)
    add_bgm_to_gallery({MIDI.id.POLLYANNA}, id.NESS)
    add_bgm_to_gallery({MIDI.id.SAMBA_DE_COMBO}, id.LUCAS)
    add_bgm_to_gallery({MIDI.id.DCMC}, id.LUCAS)
    add_bgm_to_gallery({MIDI.id.UNFOUNDED_REVENGE}, id.LUCAS)
    add_bgm_to_gallery({MIDI.id.BEIN_FRIENDS}, id.NESS)
    add_bgm_to_gallery({MIDI.id.SNAKEY_CHANTEY}, id.DK)
    add_bgm_to_gallery({MIDI.id.TAZMILY}, id.LUCAS)
    add_bgm_to_gallery({MIDI.id.YOSHI_GOLF}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.FINALTEMPLE}, id.LINK)
    add_bgm_to_gallery({MIDI.id.OBSTACLE}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.EVEN_DRIER_GUYS}, id.LUCAS)
    add_bgm_to_gallery({MIDI.id.FIRE_FIELD}, id.FALCON)
    add_bgm_to_gallery({MIDI.id.PEACH_CASTLE}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.BANJO_MAIN}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.GANGPLANK}, id.DK)
    add_bgm_to_gallery({MIDI.id.ASTRAL_OBSERVATORY}, id.YOUNG_LINK)
    add_bgm_to_gallery({MIDI.id.PAPER_MARIO_BATTLE}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.KING_OF_THE_KOOPAS}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.MRPATCH}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.SKERRIES}, id.DK)
    add_bgm_to_gallery({MIDI.id.BEWARE_THE_FORESTS_MUSHROOMS}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.FIGHT_AGAINST_BOWSER}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.VENOM}, id.FALCO)
    add_bgm_to_gallery({MIDI.id.SURPRISE_ATTACK}, id.WOLF)
    add_bgm_to_gallery({MIDI.id.BK_FINALBATTLE}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.OLE}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.WINDY}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.STARFOX_MEDLEY}, id.FOX)
    add_bgm_to_gallery({MIDI.id.MM_TITLE}, id.MARINA)
    add_bgm_to_gallery({MIDI.id.ESPERANCE}, id.MARINA)
    add_bgm_to_gallery({MIDI.id.SLOPRANO}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.NSMB}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.JUNGLEJAPES}, id.DK)
    add_bgm_to_gallery({MIDI.id.FOREST_INTERLUDE}, id.DK)
    add_bgm_to_gallery({MIDI.id.TOADS_TURNPIKE}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.FE_MEDLEY}, id.MARTH)
    add_bgm_to_gallery({MIDI.id.YOSHI_TALE}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.FLOWER_GARDEN}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.WILDLANDS}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.VS_MARX}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.SS_AQUA}, id.JIGGLYPUFF)
    add_bgm_to_gallery({MIDI.id.SLIDER}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.FIRE_EMBLEM}, id.MARTH)
    add_bgm_to_gallery({MIDI.id.KANTO_WILD_BATTLE}, id.MEWTWO)
    add_bgm_to_gallery({MIDI.id.SMB2OVERWORLD}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.PIRATELAND}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.TROPICALISLAND}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.FLYINGBATTERY}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.OPEN_YOUR_HEART}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.SONIC2_BOSS}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.CASINO_NIGHT}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.SONIC2_SPECIAL}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.SONICCD_SPECIAL}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.GIANTWING}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.EMERALDHILL}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.LIVE_AND_LEARN}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.STARDUST}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.GREEN_HILL_ZONE}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.CHEMICAL_PLANT}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.BABY_BOWSER}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.WIDE_UNDERWATER}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.METALLIC_MADNESS}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.EVERYTHING}, id.SONIC)
    add_bgm_to_gallery({MIDI.id.ROCKSOLID}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.RAINBOWROAD}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.MK64_CREDITS}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.RACEWAYS}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.LINKS_AWAKENING_MEDLEY}, id.YOUNG_LINK)
    add_bgm_to_gallery({MIDI.id.KIRBY_64_BOSS}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.WALUIGI_PINBALL}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.SMB2_MEDLEY}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.SMW_TITLECREDITS}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.DEDEDE}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.WARIOWARE}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.FROZEN_HILLSIDE}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.MK_REVENGE}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.TROUBLE_MAKER}, id.MARINA)
    add_bgm_to_gallery({MIDI.id.WL2_PERFECT}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.OEDO_EDO}, id.GOEMON)
    add_bgm_to_gallery({MIDI.id.BIS_THEGRANDFINALE}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.MAJORA_MIDBOSS}, id.GANONDORF)
    add_bgm_to_gallery({MIDI.id.KAI_HIGHWAY}, id.EBI)
    add_bgm_to_gallery({MIDI.id.SMW_ATHLETIC}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.CRATERIA_MAIN}, id.SAMUS)
    add_bgm_to_gallery({MIDI.id.SNES_RAINBOW}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.BRAWL_OOT}, id.SHEIK)
    add_bgm_to_gallery({MIDI.id.BOSS_E}, id.SLIPPY_PEPPY)
    add_bgm_to_gallery({MIDI.id.MUSICAL_CASTLE}, id.GOEMON)
    add_bgm_to_gallery({MIDI.id.BOB}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.AREA6}, id.SLIPPY_PEPPY)
    add_bgm_to_gallery({MIDI.id.HILLTOPCHASE}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.STATUS}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.FORTRESS_BOSS}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.HORROR_LAND}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.DARKWORLD}, id.GANONDORF)
    add_bgm_to_gallery({MIDI.id.FRAPPE_SNOWLAND}, id.LUIGI)
    add_bgm_to_gallery({MIDI.id.SMRPG_BATTLE}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.TRAVELING}, id.EBI)
    add_bgm_to_gallery({MIDI.id.CHILL}, id.DR_MARIO)
    add_bgm_to_gallery({MIDI.id.STICKERBRUSH_SYMPHONY}, id.DK)
    add_bgm_to_gallery({MIDI.id.WITHMILASDIVINEPROTECTION}, id.MARTH)
    add_bgm_to_gallery({MIDI.id.DK_RAP}, id.DK)
    add_bgm_to_gallery({MIDI.id.BATTLE_GOLD_SILVER}, id.JIGGLYPUFF)
    add_bgm_to_gallery({MIDI.id.BIG_BOO}, id.BOWSER)
    add_bgm_to_gallery({MIDI.id.GALLERY}, id.REMIX)
    add_bgm_to_gallery({MIDI.id.CLOCKTOWN}, id.YOUNG_LINK)
    add_bgm_to_gallery({MIDI.id.BUMPERCROPBUMP}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.VSRIDLEY}, id.DARK_SAMUS)
    add_bgm_to_gallery({MIDI.id.GANONMEDLEY}, id.GANONDORF)
    add_bgm_to_gallery({MIDI.id.NUTTY_NOON}, id.KIRBY)
    add_bgm_to_gallery({MIDI.id.QUEQUE}, id.DR_MARIO)
    add_bgm_to_gallery({MIDI.id.GHOSTGULPING}, id.MARIO)
    add_bgm_to_gallery({MIDI.id.FZERO_CLIMBUP}, id.FALCON)
    add_bgm_to_gallery({MIDI.id.YOSHI_SKA}, id.YOSHI)
    add_bgm_to_gallery({MIDI.id.NIGHTMARE}, id.DEDEDE)
    add_bgm_to_gallery({MIDI.id.THE_ALOOF_SOLDIER}, id.GOEMON)
    add_bgm_to_gallery({MIDI.id.DANGEROUS_FOE}, id.NESS)
    add_bgm_to_gallery({MIDI.id.PIKA_CUP}, id.PIKACHU)
    add_bgm_to_gallery({MIDI.id.ASHLEYS_THEME}, id.WARIO)
    add_bgm_to_gallery({MIDI.id.TALENTSTUDIO}, id.DR_MARIO)
    add_bgm_to_gallery({MIDI.id.FROSTY_VILLAGE}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.DKR_BOSS}, id.BANJO)
    add_bgm_to_gallery({MIDI.id.CRESCENT_ISLAND}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.WIZPIG}, id.CONKER)
    add_bgm_to_gallery({MIDI.id.GOLDENROD_CITY}, id.JIGGLYPUFF)

    // @ Description
    // Table which holds the 'L' and 'R' sound effects for drumming
    fgm_drum_kit:

    dh  0x020, 0x01F                     // Kicks
    dh  0x11F, 0x033                     // Stomp / Fan smack
    dh  0x117, 0x038                     // POW block / Koopa shell
    dh  0x03D, 0x02F                     // Gun shoot / Bumper
    dh  0x2C6, 0x2C7                     // Dr Mario Pills
    dh  0x567, 0x568                     // Meow / Woof
    dh  0x0EE, 0x0F7                     // Samus shot / bomb
    dh  0x0D9, 0x1B0                     // Mario Jump / BLJ
    dh  0x569, 0x56A                     // "D K"
    dh  0x180, 0x181                     // Kirby "Falcon Punch!"
    dh  0x256, 0x257                     // Yoshi
    dh  0x230, 0x234                     // Jigglypuff
    dh  0x52B, 0x52C                     // Kazooie Fair
    dh  0x523, 0x556                     // Ebi "Cha" / Camera
    dh  0x547, 0x549                     // DKing Hurt

    constant DRUM_KIT_ENTRY_COUNT(15)    // update this when we add sound effects

    drum_kit_index:
    dw  0
    OS.align(4)

    // @ Description
    // Initial hook for the gallery.
    // Runs once when the Congratulations screen loads.
    scope initial_: {
        OS.patch_start(0x17EA94, 0x80132084)
        j       initial_
        lui     t8, 0x800A                  // original line 1
        _return:
        OS.patch_end()

        li      t0, status                  // t0 = status

        // get the character id for the current index
        lb      t1, status.active(t0)       // t1 = bool active
        beqz    t1, _skip                   // skip if bool active = 0
        lbu     t1, status.index(t0)        // t1 = gallery index

        OS.save_registers()
        or      s0, t0, r0                  // s0 = status
        li      s1, id_table                // s1 = id_table
        addu    t2, s1, t1                  // t2 = id_table + index
        lbu     t1, 0x0000(t2)              // t1 = character id for current index
        lui     at, 0x8013                  // ~
        sw      t1, 0x22E0(at)              // store updated character id
        lbu     t0, status.idle(s0)         // t0 = idle status
        beqz    t0, _check_bgm              // skip if idle mode = FALSE
        lli     t1, 1                       // t1 = 1
        beq     t0, t1, _idle_mode_1        // branch if idle mode = 1
        nop

        // if idle mode 2 is active get a random bgm id
        _idle_mode_2:
        li      t0, BGM.random_count        // ~
        lw      a0, 0x0000(t0)              // a0 = random_count
        beqzl   a0, _random_bgm             // branch if random_count = 0...
        lli     a1, 0                       // ...and use default bgm id

        jal     Global.get_random_int_safe_ // v0 = (0, random_count - 1)
        lw      a0, 0x0000(t0)              // a0 = random_count

        li      t0, BGM.random_table        // t0 = random_table
        sll     v0, v0, 0x0002              // v0 = offset = random_int * 4
        addu    t0, t0, v0                  // t0 = random_table + offset
        lw      a1, 0x0000(t0)              // a1 = bgm_id

        _random_bgm:
        // now update gallery index and character id
        li      t0, bgm_to_gallery_table    // ~
        addu    t0, t0, a1                  // t0 = bgm_to_gallery_table + offset(bgm id)
        lbu     t0, 0x0000(t0)              // t0 = gallery id for current bgm
        sb      t0, status.index(s0)        // store updated gallery index
        lli     at, 1                       // ~
        sb      at, status.music_index(s0)  // set music index to 1
        jal     BGM.play_                   // play BGM
        lli     a0, 0                       // a0 = 0
        b       _end_idle_init              // end idle init
        nop

        // if idle mode 1 is active increment idle_index and update gallery index
        _idle_mode_1:
        lb      t0, status.idle_index(s0)   // t0 = idle_index
        addiu   t0, t0, 0x0001              // increment idle_index
        lli     t1, id_table.SIZE           // t1 = id_table.SIZE
        beql    t0, t1, pc() + 8            // if idle_index = id_table.SIZE...
        or      t0, r0, r0                  // ...reset idle_index
        sb      t0, status.idle_index(s0)   // store updated idle_index
        li      t1, idle_table              // t1 = idle_table
        addu    t1, t1, t0                  // t1 = idle_table + idle_index
        lbu     t0, 0x0000(t1)              // t0 = next gallery index
        sb      t0, status.index(s0)        // store updated gallery index

        // now randomize music_index and play BGM
        li      s2, bgm_table               // s2 = bgm_table
        lbu     t0, status.index(s0)        // t0 = current gallery index
        sll     t0, t0, 0x2                 // ~
        addu    s2, s2, t0                  // ~
        lw      s2, 0x0000(s2)              // s2 = bgm array for current victory image
        jal     Global.get_random_int_      // v0 = random array index = (0, bgm array size)
        lhu     a0, 0x0000(s2)              // a0 = bgm array size
        addiu   t0, v0, 1                   // t0 = music_index
        sb      t0, status.music_index(s0)  // store updsated music_index
        sll     t0, t0, 0x1                 // ~
        addu    t1, s2, t0                  // ~
        lhu     a1, 0x0000(t1)              // a1 = BGM id for music_index
        jal     BGM.play_                   // play BGM
        lli     a0, 0                       // a0 = 0


        _end_idle_init:
        // update the character id using the current gallery index
        lbu     t0, status.index(s0)        // t0 = gallery index
        addu    t2, s1, t0                  // t2 = id_table + index
        lbu     t0, 0x0000(t2)              // t0 = character id for current index
        lui     at, 0x8013                  // ~
        sw      t0, 0x22E0(at)              // store updated character id

        // run this function to keep music parameters updated?
        or      a0, r0, r0                  // a0 = unknown
        jal     0x80020B38                  // resets music parameters after fade out
        addiu   a1, r0, 0x7000              // a1 = unknown

        // and init idle timer
        lli     t0, IDLE_TIME * 60          // t0 = IDLE_TIME * 60
        sh      t0, status.idle_timer(s0)   // idle_timer = IDLE_TIME * 60

        _check_bgm:
        lbu     t0, status.music_index(s0)  // t0 = music_index
        bnez    t0, _end                    // skip if music_index != 0
        lli     a1, {MIDI.id.GALLERY}       // a1 = id.GALLERY

        // if music index is 0
        lui     t0, 0x800A                  // ~
        lw      t0, 0xD974(t0)              // ~
        lw      t0, 0x0000(t0)              // t0 = current BGM id?
        beq     t0, a1, _end                // skip if current BGM id = Gallery
        nop
        jal     BGM.play_                   // play Gallery BGM
        lli     a0, 0                       // a0 = 0
        // run this function to keep music parameters updated?
        or      a0, r0, r0                  // a0 = unknown
        jal     0x80020B38                  // resets music parameters after fade out
        addiu   a1, r0, 0x7000              // a1 = unknown

        _end:
        OS.restore_registers()

        _skip:
        j       _return                     // return
        lui     a0, 0x8013                  // original line 2
    }

    // @ Description
    // Main function for handling the Gallery.
    // Runs once per frame while on the Congratulations screen.
    // Fades the screen out when returning 1 in v0
    scope main_: {
        OS.patch_start(0x17E658, 0x80131C48)
        jal     main_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      s0, 0x0018(sp)              // store s0
        li      s0, status                  // s0 = status
        lbu     t8, status.active(s0)       // t8 = bool active
        beqz    t8, _end                    // end if Gallery isn't active
        sw      v0, 0x001C(sp)              // store v0

        // by default don't fade when in Gallery mode
        lli     v0, 0                       // v0 = 0 = don't fade
        sw      v0, 0x001C(sp)              // store v0

        // run this function to keep music parameters updated?
        or      a0, r0, r0                  // a0 = unknown
        jal     0x80020B38                  // resets music parameters after fade out
        addiu   a1, r0, 0x7000              // a1 = unknown

        // check if idle mode is active
        lbu     t8, status.idle(s0)         // t8 = idle status
        beqz    t8, _check_start_press      // branch if idle mode = FALSE
        lhu     t8, status.idle_timer(s0)   // t8 = idle_timer

        // if idle mode is active
        addiu   t8, t8,-0x0001              // t8 = idle_timer, decremented
        bnez    t8, _check_start_press      // branch if idle_timer != 0
        sh      t8, status.idle_timer(s0)       // store decremented idle_timer

        // if idle_timer has reached 0
        b       _begin_fade                 // begin a fade
        lli     v1, FADE_LENGTH_IDLE        // v1 = FADE_LENGTH_IDLE

        // check for START inputs to enter idle mode
        _check_start_press:
        lli     a0, Joypad.START            // a0 = Start
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        beqz    v0, _check_b_press          // branch if START was not pressed
        nop

        // if the START button was pressed begin or cycle
        jal     populate_idle_table_        // populate idle_table
        nop
        lbu     at, status.idle(s0)         // at = idle mode status
        lli     t8, 1                       // t8 = 1
        bnel    at, t8, _start_idle         // branch if idle mode != 1...
        lli     a0, FGM.menu.CONFIRM        // ...and a0 = fgm_id

        // if idle mode = 1, start idle mode 2 instead
        jal     BGM.random_music_           // build random music list
        nop
        lli     a0, FGM.menu.SELECT_STAGE   // a0 = fgm_id
        lli     t8, 2                       // t8 = 2

        _start_idle:
        sb      t8, status.idle(s0)         // set idle mode
        lli     at, -1                      // ~
        sb      at, status.idle_index(s0)   // idle_index = -1
        jal     FGM.play_                   // play sound
        nop
        b       _begin_fade                 // begin a fade
        lli     v1, FADE_LENGTH_IDLE        // v1 = FADE_LENGTH_IDLE

        // check for B inputs
        _check_b_press:
        lli     a0, Joypad.B                // a0 = B
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _leave_gallery          // branch if B was pressed
        nop

        // check for L and R inputs (for drumming)
        _check_l_press:
        lli     a0, Joypad.L                // a0 = R
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        beqz    v0, _check_r_press          // branch if R was not pressed
        nop
        b       _play_drum_kit              // branch
        or      a1, r0, 0                   // a1 = offset in table for 'L' instrument

        _check_r_press:
        lli     a0, Joypad.R                // a0 = R
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        beqz    v0, _check_z_press          // branch if R was not pressed
        addiu   a1, r0, 2                   // a1 = offset in table for 'R' instrument

        _play_drum_kit:
        li      v0, fgm_drum_kit            // v0 = address of fgm_drum_kit
        li      a0, drum_kit_index          // a0 = address of drum_kit_index
        lw      a0, 0x0000(a0)              // a0 = value of drum_kit_index
        sll     a0, a0, 0x0002              // a0 = offset
        addu    v0, a0, v0                  // v0 = fgm_drum_kit + offset
        addu    v0, v0, a1                  // v0 = fgm_drum_kit + L/R offset
        lh      a0, 0x0000(v0)              // a0 = 'R' or 'L' fgm_id

        jal     FGM.play_                   // play sound
        nop

        // check for Z inputs (cycle through drumming sound effects)
        _check_z_press:
        lli     a0, Joypad.Z                // a0 = Z
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        beqz    v0, _check_a_press          // branch if Z was not pressed
        nop

        li      a0, drum_kit_index          // a0 = address of drum_kit_index
        lw      a2, 0x0000(a0)              // a2 = value of drum_kit_index
        addiu   a2, a2, 1                   // a2++
        sltiu   a1, a2, DRUM_KIT_ENTRY_COUNT // a1 = 0 if drum_kit_index > max value...
        beqzl   a1, pc() + 8                // ...in which case we...
        or      a2, r0, r0                  // ...set drum_kit_index to 0
        sw      a2, 0x0000(a0)              // update value of drum_kit_index

        // check for A inputs
        _check_a_press:
        lli     a0, Joypad.A                // a0 = A
        li      a2, Joypad.PRESSED          // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        beqz    v0, _check_cycle            // branch if A was not pressed
        nop

        // check if Idle mode is active
        lbu     t8, status.idle(s0)         // t8 = idle status
        beqz    t8, _a_press_normal         // branch if idle mode = FALSE
        nop

        // if the A button was pressed during Idle mode go to the next track
        _a_press_idle:
        jal     FGM.play_                   // play sound
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id
        b       _begin_fade                 // begin a fade
        lli     v1, FADE_LENGTH_IDLE        // v1 = FADE_LENGTH_IDLE

        // if the A button was pressed begin playing music or cycle through BGM
        _a_press_normal:
        li      t1, bgm_table               // t1 = bgm_table
        lbu     t8, status.index(s0)        // t8 = current gallery index
        sll     t8, t8, 0x2                 // ~
        addu    t1, t1, t8                  // ~
        lw      t1, 0x0000(t1)              // t1 = bgm array for current victory image
        lbu     t8, status.music_index(s0)  // t8 = music_index
        lhu     t2, 0x0000(t1)              // t2 = max music_index for current victory image
        beql    t8, t2, pc() + 8            // if music_index = max value...
        or      t8, r0, r0                  // ...reset music_index
        addiu   t8, t8, 0x0001              // increment music_index
        sb      t8, status.music_index(s0)  // store updated music_index
        sll     t8, t8, 0x1                 // ~
        addu    t1, t1, t8                  // ~
        lhu     a1, 0x0000(t1)              // a1 = BGM id for music_index
        jal     BGM.play_                   // play BGM
        lli     a0, 0                       // a0 = 0
        jal     FGM.play_                   // play sound
        lli     a0, FGM.menu.CONFIRM        // a0 - fgm_id

        // check for Left/Right inputs to cycle through images
        _check_cycle:
        jal     check_sticks_               // v0 = 0 if not pressed
        nop

        lli     v1, FADE_LENGTH_NORMAL      // v1 = FADE_LENGTH_NORMAL
        bnezl   v0, _cycle_image            // if stick is pushed, cycle victory image...
        or      at, v0, r0                  // ...and at = stick direction
        lli     a0, Joypad.DL               // a0 = dpad left
        li      a2, Joypad.HELD             // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _quick_cycle            // if left was pushed, then change victory image
        addiu   at, r0, -0x0001             // at = -1
        lli     a0, Joypad.DR               // a0 = dpad right
        li      a2, Joypad.HELD             // a2 = type
        jal     Joypad.check_buttons_all_   // v0 = 0 if not pressed
        lli     a1, 00001                   // a1 = any
        bnez    v0, _quick_cycle            // if right was pushed, then change victory image
        addiu   at, r0, 0x0001              // at = +1

        b       _end                        // branch to end
        lw      v0, 0x001C(sp)              // load v0

        _quick_cycle:
        lli     v1, FADE_LENGTH_QUICK       // v1 = FADE_LENGTH_QUICK
        jal     FGM.play_                   // play sound
        lli     a0, FGM.menu.SCROLL         // a0 - fgm_id
        //lli     t6, 0x0001                  // ~
        //lui     t7, 0x8004                  // ~
        //sw      t6, 0x65D0(t7)              // generate intterupt (reload screen)

        _cycle_image:
        sb      r0, status.idle(s0)         // idle mode = FALSE
        lbu     t8, status.index(s0)        // t8 = current gallery index
        add     t8, t8, at                  // t8 = new index
        lli     at, id_table.SIZE           // at = id_table.SIZE
        // handle index wrapping when cycling the start/end of the list
        beql    t8, at, pc() + 8            // if updated index = SIZE...
        lli     t8, 0                       // ...then updated index = 0
        bltzl   t8, pc() + 8                // if updated index < 0...
        lli     t8, id_table.SIZE - 1       // ...then updated index = id.table.SIZE - 1
        sb      t8, status.index(s0)        // store updated gallery index

        _begin_fade:
        sb      v1, status.fade_length(s0)  // store fade length
        // check if music should fade out
        lbu     t8, status.music_index(s0)  // t8 = music_index
        beqz    t8, _end                    // skip if music_index = 0
        lli     v0, 0x0001                  // v0 = 1 = initiate a fade/screen change
        // fade the BGM if music_index != 0
        or      a0, r0, r0                  // ~
        or      a1, r0, r0                  // ~
        jal     0x80020BC0                  // fade BGM
        lbu     a2, status.fade_length(s0)  // a2 = fade_length
        b       _end
        lli     v0, 0x0001                  // v0 = 1 = initiate a fade/screen change

        // if we're here, we need to change screen and update Toggles value to sync with current index
        _leave_gallery:
        sb      r0, Gallery.status.active(s0)  // set flag that gallery is inactive
        lbu     a0, Gallery.status.previous_screen(s0) // a0 = previous screen_id
        lb      t1, Gallery.status.index(s0)   // gallery index
        li      t0, Toggles.entry_view_gallery // selected gallery character
        sw      t1, 0x0004(t0)                 // updated selected character
        li      t0, drum_kit_index             // t0 = address of drum_kit_index
        sw      r0, 0x0000(t0)                 // clear index

        li      t0, Toggles.normal_options  // t0 = normal_options flag
        jal     Menu.change_screen_         // generate screen_interrupt
        sb      r0, 0x0000(t0)              // normal_options = FALSE
        jal     BGM.stop_                   // stop BGM
        nop
        lli     a0, 0                       // a0 = 0
        jal     BGM.alt_menu_music_         // play menu music
        addiu   a1, r0, BGM.menu.MAIN       // original line 2

        _end:
        lw      ra, 0x0014(sp)              // load ra
        bnez    v0, _return                 // return normally if v0 != 0 (modified original line 1)
        addiu   sp, sp, 0x0030              // deallocate stack space

        // if v0 = 0, a branch would have been taken originally, so modify ra
        li      ra, 0x80131C94              // ra = original branch location

        _return:
        lw      s0, 0x0018(sp)              // load s0
        jr      ra                          // return
        addiu   a3, sp, 0x002C              // original line 2
    }

    // @ Description
    // shuffles the contents of idle_table
    scope populate_idle_table_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      s0, 0x0018(sp)              // ~
        sw      s1, 0x001C(sp)              // ~
        sw      s2, 0x0020(sp)              // store registers
        li      s1, idle_table              // s1 = idle_table
        addiu   s2, s1, id_table.SIZE       // s2 = loop end

        _clear_loop:
        lli     at, -1                      // at = -1
        sb      at, 0x0000(s1)              // store -1 in idle_table
        addiu   s1, s1, 1                   // increment idle_table
        bne     s1, s2, _clear_loop         // loop if loop end hasn't been reached yet
        nop

        // use get_random_int_safe_ the first time to increase randomness
        jal     Global.get_random_int_safe_ // v0 = random array index = (0, SIZE-1)
        lli     a0, id_table.SIZE           // ~

        lli     s0, 0                       // s0 = gallery id
        li      s1, idle_table              // s1 = idle_table
        b       _fill_loop + 8              // skip the loop's internal rng call
        lli     s2, id_table.SIZE - 1       // s2 = loop end

        _fill_loop:
        jal     Global.get_random_int_      // v0 = random array index = (0, SIZE-1)
        lli     a0, id_table.SIZE           // ~
        addu    t0, s1, v0                  // t0 = random position in idle_table
        lb      at, 0x0000(t0)              // at = id in idle_table
        bgez    at, _fill_loop              // if id is defined already try again
        nop
        sb      s0, 0x0000(t0)              // store current gallery id in idle_table
        bne     s0, s2, _fill_loop          // loop if loop end hasn't been reached yet
        addiu   s0, s0, 1                   // increment gallery_index

        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x0018(sp)              // ~
        lw      s1, 0x001C(sp)              // ~
        lw      s2, 0x0020(sp)              // load registers
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dallocate stack space
    }

    // @ Description
    // Custom function for checking stick inputs
    // @ Returns
    // v0 - 0 = none, 1 = right, -1 = left
    scope check_sticks_: {
        li      t0, Joypad.struct           // t0 = joypad.struct
        lli     t7, 0                       // loop count = 0
        lli     t8, 3                       // loop end = 3
        lli     v0, 0                       // return 0 initially

        _loop:
        lb      t1, 0x0008(t0)              // t1 = p1 x
        slti    at, t1, 40                  // at = 1 if p1 x < 40
        beqzl   at, _end                    // branch if p1 x >= 40...
        addiu   v0, r0, 1                   // ...and return 1
        slti    at, t1, -39                 // at = 1 if p1 x < -39
        bnezl   at, _end                    // branch if p1 x < -39...
        addiu   v0, r0, -1                  // ...and return -1

        // if we're here no stick input was found yet so loop to next player
        addiu   t0, t0, 10                  // t0 = next joypad struct
        bnez    t7, _loop                   // loop if end has not been reached
        addiu   t7, t7, 1                   // increment loop count

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Changes the screen id and resets BGM when cyling through the Gallery.
    scope screen_change_: {
        OS.patch_start(0x17E9D8, 0x80131FC8)
        j       screen_change_
        addiu   t1, r0, 0x0001              // original line 1
        _return:
        OS.patch_end()

        li      t2, status                  // t2 = status
        lbu     at, status.active(t2)       // at = bool active
        bnezl   at, pc() + 8                // if Gallery is active...
        lli     t1, Global.screen.CONGRATULATIONS // ...force CONGRATULATIONS screen id

        // reset the BGM if it's active
        lb      at, status.music_index(t2)  // at = music_index
        beqz    at, _end                    // end if music_index != 0
        nop
        // if music_index != 0
        OS.save_registers()
        jal     BGM.stop_                   // stop BGM
        sb      r0, status.music_index(t2)  // reset music_index
        OS.restore_registers()

        _end:
        j       _return                     // return
        sb      t1, 0x0000(v0)              // original line 2 (store screen id)
    }

    // @ Description
    // Use a custom fade length when cyling through the Gallery.
    scope get_fade_length_: {
        OS.patch_start(0x17E684, 0x80131C74)
        j       get_fade_length_
        addiu   t2, r0, 0x005A              // original line 1 (t2 = fade length)
        _return:
        OS.patch_end()

        li      t1, status                  // t1 = status
        lbu     at, status.active(t1)       // at = bool active
        bnezl   at, pc() + 8                // if Gallery is active...
        lbu     t2, status.fade_length(t1)  // ...then t2 = fade_length
        j       _return                     // return
        sw      t2, 0x0010(sp)              // original line 2
    }

    // @ Description
    // Prevents the "Congratulations" FGM while cyling through the Gallery.
    scope prevent_fgm_: {
        OS.patch_start(0x17E940, 0x80131F30)
        j       prevent_fgm_
        ori     at, at, 0x4240
        _return:
        OS.patch_end()

        li      t2, status                  // t2 = status
        lbu     t2, status.active(t2)       // t2 = bool active
        bnezl   t2, _gallery                // branch if Gallery is active...
        lw      ra, 0x003C(sp)              // ...and load retur naddress

        _original:
        j       _return                     // return
        sltu    at, t8, at                  // original line 2

        _gallery:
        jr      ra                          // end original function, skipping fgm
        addiu   sp, sp, 0x0078              // deallocate stack space in the delay slot
    }

    // Adds Gallery option to Data screen
    scope data_menu {
        // 80133060 - array of menu objects
        // 80133084 - number of menu objects (0-based)
        // 80133088 - cursor index
        // 80133164 - image file address

        scope add_button_: {
            OS.patch_start(0x1222C8, 0x80132E78)
            jal     add_button_
            nop                             // original line 2
            OS.patch_end()

            addiu   sp, sp,-0x0030          // allocate stack space
            sw      ra, 0x0014(sp)          // ~
            lw      t2, 0x0004(v0)          // t2 = Sound Test button object

            jal     0x80131FC8              // add Sound Test button again
            sw      t2, 0x0018(sp)          // save original Sound Test button address

            lui     t0, 0x8013
            lw      t2, 0x0004(v0)          // t2 = gallery button object
            sw      t2, 0x306C(t0)          // save to array
            lw      t1, 0x0018(sp)          // t1 = original Sound Test button address
            sw      t1, 0x3068(t0)          // save to array

            lli     t1, 0x0003              // t1 = 4 buttons
            sw      t1, 0x3084(t0)          // update number of buttons

            lui     t1, 0x4337              // t1 = y
            lw      v0, 0x0074(t2)          // v0 = image position struct for left part of button
            sw      t1, 0x005C(v0)          // update y
            lui     t3, 0x4214              // t3 = x
            sw      t3, 0x0058(v0)          // update x

            lw      v0, 0x0008(v0)          // v0 = image position struct for button middle
            sw      t1, 0x005C(v0)          // update y
            lui     t3, 0x4254              // t3 = x
            sw      t3, 0x0058(v0)          // update x

            lw      v0, 0x0008(v0)          // v0 = image position struct for right part of button
            sw      t1, 0x005C(v0)          // update y
            lui     t3, 0x4335              // t3 = x
            sw      t3, 0x0058(v0)          // update x

            lw      v0, 0x0008(v0)          // v0 = image position struct for text
            lui     t1, 0x433B              // t1 = y
            sw      t1, 0x005C(v0)          // update y
            lui     t3, 0x42A0              // t3 = x
            sw      t3, 0x0058(v0)          // update x
            OS.read_word(0x80133164, t1)    // t1 = file 0x0003 address
            addiu   t1, t1, 0x4EE8          // t1 = address of image footer
            sw      t1, 0x0044(v0)          // update image
            lli     t1, 0x0016              // t1 = height (22)
            sh      t1, 0x0016(v0)          // set height
            sh      t1, 0x003C(v0)          // set height
            sh      t1, 0x003E(v0)          // set height

            // now fix highlighting
            lw      a0, 0x0004(v0)          // a0 = Gallery button object
            lui     a1, 0x8013
            lw      a1, 0x3078(a1)          // a1 = cursor index
            xori    a1, a1, 0x0003          // a1 = 0 if selected
            jal     0x80131B4C              // update highlight
            sltiu   a1, a1, 0x0001          // a1 = 1 if selected

            jal     0x801320D4              // original line 1
            nop

            lw      ra, 0x0014(sp)          // ~
            jr      ra
            addiu   sp, sp, 0x0030          // deallocate stack space
        }

        scope cursor_: {
            // move down
            OS.patch_start(0x122154, 0x80132D04)
            lui     t2, 0x8013
            addu    t2, t2, t0              // adjust for cursor index
            jal     0x80131B4C              // original line 3
            lw      a0, 0x3060(t2)          // a0 = button object selected
            OS.patch_end()

            // wrap down
            OS.patch_start(0x122108, 0x80132CB8)
            lui     t5, 0x8013
            addu    t5, t5, t4              // adjust for cursor index
            jal     0x80131B4C              // original line 3
            lw      a0, 0x3060(t5)          // a0 = button object selected
            OS.patch_end()

            // move up
            OS.patch_start(0x121FE0, 0x80132B90)
            lui     t7, 0x8013
            addu    t7, t7, t6              // adjust for cursor index
            jal     0x80131B4C              // original line 3
            lw      a0, 0x3060(t7)          // a0 = button object selected
            OS.patch_end()

            // wrap up
            OS.patch_start(0x12202C, 0x80132BDC)
            lui     t3, 0x8013
            addu    t3, t3, t1              // adjust for cursor index
            jal     0x80131B4C              // original line 3
            lw      a0, 0x3060(t3)          // a0 = button object selected
            OS.patch_end()

            // set index on load
            OS.patch_start(0x121C10, 0x801327C0)
            sw      ra, 0x0014(sp)          // original line 3
            lli     at, 0x0019              // at = VS Records screen_id
            beql    v0, at, 0x801327F4      // if this screen, set index
            lli     t7, 0x0001              // t7 = index
            lli     at, 0x003B              // at = Sound Test screen_id
            beql    v0, at, 0x801327F4      // if this screen, set index
            lli     t7, 0x0002              // t7 = index
            lli     at, Global.screen.CONGRATULATIONS // at = Congratulations screen_id
            beql    v0, at, 0x801327F4      // if this screen, set index
            lli     t7, 0x0003              // t7 = index
            b       0x801327F4              // if none of the above, then set to 0
            lli     t7, 0x0000              // t7 = index
            OS.patch_end()

            // handle A press
            OS.patch_start(0x121DF8, 0x801329A8)
            beqzl   v0, 0x80132A1C          // original line 1 modified to branch to modified code
            lli     t0, 0x001A              // t0 = Characters screen
            beql    v0, at, 0x80132A1C      // original line 3 modified to branch to modified code
            lli     t0, 0x0019              // t0 = VS Record screen
            lli     at, 0x0002              // at = 2
            beql    v0, at, 0x80132A1C      // original line 5 modified to branch to modified code
            lli     t0, 0x003B              // t0 = Sound Test screen
            lli     at, 0x0003              // at = 2
            bne     v0, at, 0x80132AD0      // original line 7 modified to not catch Gallery button selected
            lli     t0, 0x0001              // t0 = 1 (active)
            li      t1, Gallery.status      // t1 = status
            sb      r0, Gallery.status.index(t1)  // start at Mario
            sb      t0, Gallery.status.active(t1) // set flag that gallery is active
            sb      r0, Gallery.status.music_index(t1) // set music_index to 0
            sb      r0, Gallery.status.idle(t1)   // set flag that gallery idle mode is off
            lli     t0, 0x003A              // t0 = Data screen_id
            sb      t0, Gallery.status.previous_screen(t1) // set previous screen_id
            b       0x80132A1C
            lli     t0, Global.screen.CONGRATULATIONS // t0 = Victory screen ID
            OS.patch_end()
            OS.patch_start(0x121E6C, 0x80132A1C)
            sw      t0, 0x0024(sp)          // save screen to transition to in stack
            OS.patch_end()
            OS.patch_start(0x121E88, 0x80132A38)
            lui     t7, 0x8013
            addu    t7, t7, t6              // adjust for cursor index
            jal     0x80131B4C              // original line 3
            lw      a0, 0x3060(t7)          // a0 = button object selected
            OS.patch_end()
            OS.patch_start(0x121EAC, 0x80132A5C)
            lw      t9, 0x0024(sp)          // t9 = screen to transition to in stack
            OS.patch_end()
        }
    }
} // __GALLERY__
