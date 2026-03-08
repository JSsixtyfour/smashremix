// MIDI.asm (Fray)
if !{defined __MIDI__} {
define __MIDI__()

// This file extends the music table and defines macros for including new MIDI files.
// It also extends the instrument table and defines macros for including new instruments.
// For converting MIDI files, it's recommended to use GE Editor.
// Tools > Extra Tools > MIDI Tools > Convert Midi to GE Format and Loop

include "OS.asm"

scope MIDI {
    read32 MUSIC_TABLE, "../roms/original.z64", 0x3D768
    variable MUSIC_TABLE_END(MUSIC_TABLE + 0x17C)   // variable containing the current end of the music table
    constant MIDI_BANK(0x3000000)                   // defines the start of the additional MIDI bank
    global variable MIDI_BANK_END(MIDI_BANK)        // variable containing the current end of the MIDI bank
    // These 2 variables will be used in FGM.asm to calculate the correct RAM offset for numerous pointers
    variable midi_count(0x2F)                       // variable containing total number of MIDIs
    variable largest_midi(0)                        // variable containing the largest MIDI size

    variable game_count(0)                          // variable counting the number of games represented by midis

    // @ Description
    // moves the Dream Land midi to our new MIDI bank to clear space for expanding MUSIC_TABLE
    macro move_dream_land_midi() {
        pushvar origin, base

        // define a new offset for the Dream Land MIDI
        origin  MUSIC_TABLE + 0x4
        dw      MIDI_BANK_END - MUSIC_TABLE

        // remove the previous Dream Land MIDI
        origin  MUSIC_TABLE_END
        fill    0x1F40, 0x00

        // insert the Dream Land MIDI and update MIDI_BANK_END
        origin  MIDI_BANK_END
        insert  MIDI_Dream_Land, "../roms/original.z64", MUSIC_TABLE + 0x17C, 0x1F40
        global variable MIDI_BANK_END(origin())

        pullvar base, origin
    }

    // @ Description
    // Defines a game so we can associate midis with games
    // @ Arguments
    // name - name/id
    // title - game title for display
    macro add_game(name, title) {
        evaluate n(game_count)

        global define GAME_{name}({n})
        game_{n}_title:; db {title}, 0x0

        global variable game_count(game_count + 0x1)
    }

    // @ Description
    // adds a MIDI to our new MIDI bank, and the music table
    // @ Arguments
    // file_name - Name of MIDI file
    // random_te - (bool) Default value for Tournament profile
    // random_ne - (bool) Default value for Netplay profile
    // can_toggle - (bool) indicates if this should be toggleable
    // has_title - (bool) indicates if this track has a title string
    // track_title - Name of track
    // track_game - Name of game of origin for track (from add_game)
    // order - Order of the track
    macro insert_midi(file_name, random_te, random_ne, can_toggle, has_title, track_title, track_game, order) {
        pushvar origin, base

        // defines
        define path_MIDI_{file_name}(../src/music/{file_name}.bin)
        evaluate offset_MIDI_{file_name}(MIDI_BANK_END)
        evaluate MIDI_{file_name}_ID((MUSIC_TABLE_END - MUSIC_TABLE) / 0x8)

        global variable midi_count({MIDI_{file_name}_ID} + 0x1)
        global define MIDI_{MIDI_{file_name}_ID}_TE({random_te})
        global define MIDI_{MIDI_{file_name}_ID}_NE({random_ne})
        global define MIDI_{MIDI_{file_name}_ID}_TOGGLE({can_toggle})
        global define MIDI_{MIDI_{file_name}_ID}_TITLE({has_title})
        global define MIDI_{MIDI_{file_name}_ID}_FILE_NAME({file_name})
        global define MIDI_{MIDI_{file_name}_ID}_NAME({track_title})
        global define MIDI_{MIDI_{file_name}_ID}_GAME({track_game})
        global define MIDI_{MIDI_{file_name}_ID}_ORDER({order})
        global define id.{file_name}({MIDI_{file_name}_ID})

        // print message
        print "Added MIDI_{file_name}({path_MIDI_{file_name}}): ", {MIDI_{MIDI_{file_name}_ID}_NAME}, "\n"
        print "ROM Offset: 0x"; OS.print_hex({offset_MIDI_{file_name}}); print "\n"
        print "MIDI_{file_name}_ID: 0x"; OS.print_hex({MIDI_{file_name}_ID}); print "\n"
        print "Sound Test Music ID: ", midi_count, "\n\n"

        // add the new midi to the music table and update MUSIC_TABLE_END
        origin  MUSIC_TABLE_END
        dw      origin_MIDI_{file_name} - MUSIC_TABLE
        dw      MIDI_{file_name}.size
        global variable MUSIC_TABLE_END(origin())

        // insert the MIDI file and update MIDI_BANK_END
        origin  MIDI_BANK_END
        constant origin_MIDI_{file_name}(origin())
        insert  MIDI_{file_name}, "{path_MIDI_{file_name}}"
        OS.align(4)
        global variable MIDI_BANK_END(origin())

        // set the number of songs in MUSIC_TABLE
        origin  MUSIC_TABLE + 0x2
        dh      midi_count

        // update largest MIDI size
        if MIDI_{file_name}.size > largest_midi {
            global variable largest_midi(MIDI_{file_name}.size)
        }

        pullvar base, origin
    }

    // same as insert_midi but from external paths
    macro insert_external_midi(midi_id, file_name, random_te, random_ne, can_toggle, has_title, track_title, track_game, order) {
        pushvar origin, base

        // defines
        define path_MIDI_{midi_id}({file_name}.bin)
        evaluate offset_MIDI_{midi_id}(MIDI_BANK_END)
        evaluate MIDI_{midi_id}_ID((MUSIC_TABLE_END - MUSIC_TABLE) / 0x8)

        global variable midi_count({MIDI_{midi_id}_ID} + 0x1)
        global define MIDI_{MIDI_{midi_id}_ID}_TE({random_te})
        global define MIDI_{MIDI_{midi_id}_ID}_NE({random_ne})
        global define MIDI_{MIDI_{midi_id}_ID}_TOGGLE({can_toggle})
        global define MIDI_{MIDI_{midi_id}_ID}_TITLE({has_title})
        global define MIDI_{MIDI_{midi_id}_ID}_FILE_NAME({midi_id})
        global define MIDI_{MIDI_{midi_id}_ID}_NAME({track_title})
        global define MIDI_{MIDI_{midi_id}_ID}_GAME({track_game})
        global define MIDI_{MIDI_{midi_id}_ID}_ORDER({order})
        global define id.{midi_id}({MIDI_{midi_id}_ID})

        // print message
        print "Added MIDI_{midi_id}({path_MIDI_{midi_id}}): ", {MIDI_{MIDI_{midi_id}_ID}_NAME}, "\n"
        print "ROM Offset: 0x"; OS.print_hex({offset_MIDI_{midi_id}}); print "\n"
        print "MIDI_{midi_id}_ID: 0x"; OS.print_hex({MIDI_{midi_id}_ID}); print "\n"
        print "Sound Test Music ID: ", midi_count, "\n\n"

        // add the new midi to the music table and update MUSIC_TABLE_END
        origin  MUSIC_TABLE_END
        dw      origin_MIDI_{midi_id} - MUSIC_TABLE
        dw      MIDI_{midi_id}.size
        global variable MUSIC_TABLE_END(origin())

        // insert the MIDI file and update MIDI_BANK_END
        origin  MIDI_BANK_END
        constant origin_MIDI_{midi_id}(origin())
        insert  MIDI_{midi_id}, "{path_MIDI_{midi_id}}"
        OS.align(4)
        global variable MIDI_BANK_END(origin())

        // set the number of songs in MUSIC_TABLE
        origin  MUSIC_TABLE + 0x2
        dh      midi_count

        // update largest MIDI size
        if MIDI_{midi_id}.size > largest_midi {
            global variable largest_midi(MIDI_{midi_id}.size)
        }

        pullvar base, origin
    }

    // @ Description
    // adds a toggleable MIDI to our new MIDI bank, and the music table
    // file_name - Name of MIDI file
    // random_te - Default value for Tournament profile
    // random_ne - Default value for Netplay profile
    // track_title - Name of track
    // track_game - Game of origin for track
    macro insert_midi(file_name, random_te, random_ne, track_title, track_game, order) {
        insert_midi({file_name}, {random_te}, {random_ne}, OS.TRUE, OS.TRUE, {track_title}, {track_game}, {order})
    }

    // @ Description
    // adds an extra, unnamed MIDI to our new MIDI bank, and the music table
    // file_name - Name of MIDI file
    macro insert_extra_midi(file_name) {
        insert_midi({file_name}, OS.FALSE, OS.FALSE, OS.FALSE, OS.FALSE, -1, -1, -1)
    }

    // @ Description
    // adds an extra, named MIDI to our new MIDI bank, and the music table
    // file_name - Name of MIDI file
    macro insert_named_extra_midi(file_name, track_title, track_game, order) {
        insert_midi({file_name}, OS.FALSE, OS.FALSE, OS.FALSE, OS.TRUE, {track_title}, {track_game}, {order})
    }

    // define new MIDI bank
    print "=============================== MIDI FILES =============================== \n"
    // print music table offset
    evaluate music_table_offset(MUSIC_TABLE)
    print "Music Table: 0x"; OS.print_hex({music_table_offset}); print "\n"

    // move dream land midi
    move_dream_land_midi()

    // define games
    add_game(smb, "Super Mario Bros.")
    add_game(smb2, "Super Mario Bros. 2")
    add_game(smb3, "Super Mario Bros. 3")
    add_game(sml, "Super Mario Land")
    add_game(smw, "Super Mario World")
    add_game(sm64, "Super Mario 64")
    add_game(sunshine, "Super Mario Sunshine")
    add_game(nsmb, "New Super Mario Bros.")
    add_game(drm, "Dr. Mario")
    add_game(drm64, "Dr. Mario 64")
    add_game(smk, "Super Mario Kart")
    add_game(mk64, "Mario Kart 64")
    add_game(mkds, "Mario Kart DS")
    add_game(marioparty, "Mario Party")
    add_game(marioparty2, "Mario Party 2")
    add_game(mariogolf, "Mario Golf")
    add_game(mariotennis, "Mario Tennis")
    add_game(smrpg, "Super Mario RPG: Legend of the Seven Stars")
    add_game(papermario, "Paper Mario")
    add_game(mariohoops, "Mario Hoops 3-on-3")
    add_game(talentstudio, "Mario Artist: Talent Studio")
    add_game(marioluigi_bis, "Mario and Luigi: Bowser's Inside Story")
    add_game(ddrmm, "Dance Dance Revolution: Mario Mix")
    add_game(yoshis_island, "Super Mario World 2: Yoshi's Island")
    add_game(yoshis_story, "Yoshi's Story")
    add_game(yoshis_island_ds, "Yoshi's Island DS")
    add_game(warioland, "Wario Land: Super Mario Land 3")
    add_game(warioland2, "Wario Land II")
    add_game(warioshake, "Wario Land - Shake It!")
    add_game(warioworld, "Wario World")
    add_game(warioware, "WarioWare, Inc.: Mega Microgame$!")
    add_game(wwtouched, "WarioWare: Touched!")
    add_game(dkarc, "Donkey Kong/Donkey Kong Jr.")
    add_game(dkl, "Donkey Kong Land")
    add_game(dkc, "Donkey Kong Country")
    add_game(dkc2, "Donkey Kong Country 2")
    add_game(dk64, "Donkey Kong 64")
    add_game(dkr, "Diddy Kong Racing")
    add_game(zelda, "The Legend of Zelda")
    add_game(zelda2, "Zelda II: The Adventure of Link")
    add_game(lttp, "The Legend of Zelda: A Link to the Past")
    add_game(awakening, "The Legend of Zelda: Link's Awakening")
    add_game(ocarina, "The Legend of Zelda: Ocarina of Time")
    add_game(majora, "The Legend of Zelda: Majora's Mask")
    add_game(skyward, "The Legend of Zelda: Skyward Sword")
    add_game(metroid, "Metroid")
    add_game(supermetroid, "Super Metroid")
    add_game(metroidprime3, "Metroid Prime 3: Corruption")
    add_game(starfox, "Star Fox")
    add_game(starfox2, "Star Fox 2")
    add_game(starfox64, "Star Fox 64")
    add_game(pokemonred, "Pokemon Red & Blue")
    add_game(pokemongold, "Pokemon Gold & Silver")
    add_game(pokemonruby, "Pokemon Ruby & Sapphire")
    add_game(stadium, "Pokemon Stadium")
    add_game(heypika, "Hey You, Pikachu!")
    add_game(kirbydreamland, "Kirby's Dream Land")
    add_game(kirbyadventure, "Kirby's Adventure")
    add_game(kirbysuperstar, "Kirby Super Star")
    add_game(kirby64, "Kirby 64: The Crystal Shards")
    add_game(kirbyair, "Kirby Air Ride")
    add_game(kirbyreturn, "Kirby's Return to Dream Land")
    add_game(fzero, "F-Zero")
    add_game(fzero_x, "F-Zero X")
    add_game(fzero_gx, "F-Zero GX")
    add_game(earthbound, "EarthBound")
    add_game(earthboundb, "EarthBound Beginnings")
    add_game(mother3, "Mother 3")
    add_game(ssb, "Super Smash Bros.")
    add_game(ssbr, "Smash Remix")
    add_game(brawl, "Super Smash Bros. Brawl")
    add_game(melee, "Super Smash Bros. Melee")
    add_game(animal_crossing, "Animal Crossing")
    add_game(acww, "Animal Crossing: Wild World")
    add_game(acnewleaf, "Animal Crossing: New Leaf")
    add_game(machrider, "Mach Rider")
    add_game(mischiefmakers, "Mischief Makers")
    add_game(conker, "Conker's Bad Fur Day")
    add_game(banjokazooie, "Banjo-Kazooie")
    add_game(banjo2, "Banjo-Tooie")
    add_game(pd, "Perfect Dark")
    add_game(jetforce, "Jet Force Gemini")
    add_game(goldeneye, "GoldenEye 007")
    add_game(mlb, "Major League Baseball Featuring Ken Griffey Jr.")
    add_game(nbajam, "NBA Jam")
    add_game(mvc, "Marvel vs. Capcom")
    add_game(mvc2, "Marvel vs. Capcom 2")
    add_game(toh, "Tower of Heaven")
    add_game(persona, "Revelations: Persona")
    add_game(persona5, "Persona 5")
    add_game(fire_emblem, "Fire Emblem")
    add_game(fe6, "Fire Emblem: The Binding Blade")
    add_game(fe_gaiden, "Fire Emblem Gaiden")
    add_game(sonic1, "Sonic the Hedgehog")
    add_game(sonic2, "Sonic the Hedgehog 2")
    add_game(soniccd, "Sonic CD")
    add_game(sonic3, "Sonic the Hedgehog 3")
    add_game(sonicfighters, "Sonic the Fighters")
    add_game(sonicR, "Sonic R")
    add_game(sonicadventure, "Sonic Adventure")
    add_game(sonicadventure2, "Sonic Adventure 2")
    add_game(rhfever, "Rhythm Heaven Fever")
    add_game(chrono, "Chrono Trigger")
    add_game(xenogears, "Xenogears")
    add_game(dragonking, "Dragon King: The Fighting Game")
    add_game(castlevania, "Castlevania")
    add_game(castlevania_2, "Castlevania II: Simon's Quest")
    add_game(castlevania_bloodlines, "Castlevania: Bloodlines")
    add_game(castlevania_sotn, "Castlevania: Symphony of the Night")
    add_game(castlevania_dos, "Castlevania: Dawn of Sorrow")
    add_game(castlevania_rob, "Castlevania: Rondo of Blood")
    add_game(isoccer, "International Superstar Soccer 64")
    add_game(goemon, "Ganbare Goemon")
    add_game(mysticalninja, "Mystical Ninja Starring Goemon")
    add_game(gga, "Goemon's Great Adventure")
    add_game(goepachisuro, "Ganbare Goemon Pachisuro")
    add_game(waverace, "Wave Race 64")
    add_game(quest64, "Quest 64")
    add_game(ogrebattle64, "Ogre Battle 64: Person of Lordly Caliber")
    add_game(ff4, "Final Fantasy IV")
    add_game(ff5, "Final Fantasy V")
    add_game(jackbros, "Jack Bros.")
    add_game(smtif, "Shin Megami Tensei If...")
    add_game(smtiv, "Shin Megami Tensei IV")
    add_game(shantae, "Shantae")
    add_game(megamanbc, "Megaman: Battle & Chase")
    add_game(megamanscr, "Mega Man Soccer")
    add_game(doom, "DOOM")
    add_game(doom2, "DOOM II: Hell on Earth")
    add_game(dukenukem3d, "Duke Nukem 3D")
    add_game(cavestory, "Cave Story")
    add_game(sbk, "Snowboard Kids")
    add_game(sbk2, "Snowboard Kids 2")
    add_game(2hu6, "Touhou 6: Embodiment of Scarlet Devil")
    add_game(crash, "Crash Bandicoot")
    add_game(crash2, "Crash Bandicoot 2: Cortex Strikes Back")
    add_game(crash3, "Crash Bandicoot: Warped")
    add_game(crash_xs, "Crash Bandicoot: The Huge Adventure")
    add_game(crashbash, "Crash Bash")
    add_game(dinoplanet, "Dinosaur Planet")
    add_game(marathon2, "Marathon 2: Durandal")
    add_game(ut99, "Unreal Tournament")
    add_game(shovelknight, "Shovel Knight")
    add_game(snp, "Sin and Punishment")
    add_game(bomberman, "Bomberman 64")
    add_game(bombermanhero, "Bomberman Hero")
    add_game(kidicarus, "Kid Icarus")
    add_game(silversurfer, "Silver Surfer")
    add_game(balloonfight, "Balloon Fight")
    add_game(paneldepon, "Panel de Pon")
    add_game(dream, "Dream: Land of Giants")
    OS.align(4)

    // insert custom midi files
    insert_midi(GANONDORF_BATTLE, OS.TRUE, OS.TRUE, "Ganondorf Battle", ocarina, 111)
    insert_midi(CORNERIA, OS.TRUE, OS.TRUE, "Corneria", starfox, 54)
    insert_midi(KOKIRI_FOREST, OS.TRUE, OS.TRUE, "Kokiri Forest", ocarina, 140)
    insert_midi(DR_MARIO, OS.TRUE, OS.TRUE, "Fever", drm, 84)
    insert_midi(GAME_CORNER, OS.TRUE, OS.TRUE, "Game Corner", pokemongold, 108)
    insert_midi(SMASHVILLE, OS.TRUE, OS.TRUE, "Town Hall and Tom Nook's Store", acww, 258)
    insert_midi(STONECARVING_CITY, OS.TRUE, OS.TRUE, "Stonecarving City", warioshake, 238)
    insert_midi(FIRST_DESTINATION, OS.TRUE, OS.TRUE, "Final Destination (Melee)", melee, 90)
    insert_midi(COOLCOOLMOUNTAIN, OS.TRUE, OS.TRUE, "Snow Mountain", sm64, 224)
    insert_midi(GODDESSBALLAD, OS.TRUE, OS.TRUE, "Ballad of the Goddess", skyward, 12)
    insert_midi(SARIA, OS.TRUE, OS.TRUE, "Saria's Song", ocarina, 215)
    insert_midi(TOWEROFHEAVEN, OS.TRUE, OS.TRUE, "Luna Ascension", toh, 150)
    insert_midi(FOD, OS.TRUE, OS.TRUE, "Gourmet Race (Melee)", kirbysuperstar, 119)
    insert_midi(MUDA, OS.TRUE, OS.TRUE, "Muda Kingdom", sml, 168)
    insert_midi(MEMENTOS, OS.TRUE, OS.TRUE, "Last Surprise", persona5, 143)
    insert_midi(SPIRAL_MOUNTAIN, OS.TRUE, OS.TRUE, "Spiral Mountain", banjokazooie, 229)
    insert_midi(N64, OS.TRUE, OS.TRUE, "Dire, Dire Docks", sm64, 67)
    insert_midi(MUTE_CITY, OS.TRUE, OS.TRUE, "Mute City", fzero, 172)
    insert_midi(BATTLEFIELD, OS.TRUE, OS.TRUE, "Battlefield", brawl, 19)
    insert_midi(MADMONSTER, OS.TRUE, OS.TRUE, "Mad Monster Mansion", banjokazooie, 154)
    insert_extra_midi(GANON_VICTORY)
    insert_extra_midi(YOUNGLINK_VICTORY)
    insert_extra_midi(FALCO_VICTORY)
    insert_extra_midi(DRMARIO_VICTORY)
    insert_extra_midi(MELEE_MENU)
    insert_midi(GREEN_GREENS, OS.TRUE, OS.TRUE, "Green Greens", kirbydreamland, 123)
    insert_midi(NORFAIR, OS.TRUE, OS.TRUE, "Brinstar Depths", metroid, 36)
    insert_midi(BOWSERBOSS, OS.TRUE, OS.TRUE, "Koopa's Theme", sm64, 142)
    insert_midi(POKEMON_STADIUM, OS.TRUE, OS.TRUE, "Trainer Battle", pokemonred, 259)
    insert_midi(BOWSERROAD, OS.TRUE, OS.TRUE, "Koopa's Road", sm64, 141)
    insert_midi(BOWSERFINAL, OS.TRUE, OS.TRUE, "Ultimate Koopa", sm64, 265)
    insert_midi(SMB3OVERWORLD, OS.TRUE, OS.TRUE, "Super Mario Bros. 3 (Melee)", smb3, 243)
    insert_midi(DELFINO, OS.TRUE, OS.TRUE, "Delfino Plaza", sunshine, 66)
    insert_midi(VS_KLUNGO, OS.TRUE, OS.TRUE, "Vs. Klungo", banjo2, 274)
    insert_midi(BIG_BLUE, OS.TRUE, OS.TRUE, "Big Blue", fzero, 23)
    insert_extra_midi(DSAMUS_VICTORY)
    insert_midi(ONETT, OS.TRUE, OS.TRUE, "Onett", earthbound, 181)
    insert_midi(ZEBES_LANDING, OS.TRUE, OS.TRUE, "Upper Brinstar", supermetroid, 269)
    insert_midi(FROSTY_VILLAGE, OS.TRUE, OS.TRUE, "Frosty Village", dkr, 102)
    insert_midi(EASTON_KINGDOM, OS.TRUE, OS.TRUE, "Easton Kingdom", sml, 77)
    insert_midi(WING_CAP, OS.TRUE, OS.TRUE, "Powerful Mario", sm64, 196)
    insert_midi(RBY_GYMLEADER, OS.TRUE, OS.TRUE, "Gym Leader Battle", pokemonred, 126)
    insert_midi(KITCHEN_ISLAND, OS.TRUE, OS.TRUE, "Wario Land", warioland, 278)
    insert_midi(GLACIAL, OS.TRUE, OS.TRUE, "River Stage", mvc2, 208)
    insert_midi(DK_RAP, OS.TRUE, OS.TRUE, "DK Rap", dk64, 69)
    insert_extra_midi(WARIO_VICTORY)
    insert_midi(MACHRIDER, OS.TRUE, OS.TRUE, "Mach Rider (Melee)", machrider, 152)
    insert_midi(POKEFLOATS, OS.TRUE, OS.TRUE, "Red & Blue Medley", pokemonred, 203)
    insert_midi(GERUDO_VALLEY, OS.TRUE, OS.TRUE, "Gerudo Valley", ocarina, 112)
    insert_midi(POP_STAR, OS.TRUE, OS.TRUE, "Pop Star", kirby64, 194)
    insert_midi(STAR_WOLF, OS.TRUE, OS.TRUE, "Star Wolf", starfox64, 233)
    insert_midi(STARRING_WARIO, OS.TRUE, OS.TRUE, "Starring Wario!", ddrmm, 235)
    insert_extra_midi(LUCAS_VICTORY)
    insert_midi(POKEMON_CHAMPION, OS.TRUE, OS.TRUE, "Champion Battle", pokemonred, 44)
    insert_midi(ANIMAL_CROSSING, OS.TRUE, OS.TRUE, "Title Theme (Wild World)", acww, 255)
    insert_midi(HYRULE_TEMPLE, OS.TRUE, OS.TRUE, "Temple Theme (Melee)", zelda2, 248)
    insert_midi(POLLYANNA, OS.TRUE, OS.TRUE, "Pollyanna (Melee)", earthboundb, 193)
    insert_midi(SAMBA_DE_COMBO, OS.TRUE, OS.TRUE, "Samba de Combo", mother3, 214)
    insert_midi(PORKY_MEDLEY, OS.TRUE, OS.TRUE, "Master Porky Medley", mother3, 160)
    insert_midi(UNFOUNDED_REVENGE, OS.TRUE, OS.TRUE, "Unfounded Revenge", mother3, 268)
    insert_midi(THE_DAYS_WHEN_MY_MOTHER_WAS_THERE, OS.TRUE, OS.TRUE, "The Days When My Mother Was There", persona5, 250)
    insert_extra_midi(BRAWL)
    insert_midi(NBA_JAM, OS.TRUE, OS.TRUE, "NBA Jam Medley", nbajam, 174)
    insert_midi(KENGJR, OS.TRUE, OS.TRUE, "Call Me Jr.", mlb, 42)
    insert_midi(CLOCKTOWER, OS.TRUE, OS.TRUE, "Clock Tower", mvc2, 50)
    insert_midi(BEIN_FRIENDS, OS.TRUE, OS.TRUE, "Bein' Friends", earthboundb, 21)
    insert_midi(KK_RIDER, OS.TRUE, OS.TRUE, "Go K.K. Rider!", animal_crossing, 115)
    insert_midi(SNAKEY_CHANTEY, OS.TRUE, OS.TRUE, "Snakey Chantey", dkc2, 222)
    insert_midi(TAZMILY, OS.TRUE, OS.TRUE, "Mom's Hometown", mother3, 165)
    insert_midi(FLAT_ZONE, OS.TRUE, OS.TRUE, "Flat Zone", melee, 92)
    insert_midi(FLAT_ZONE_2, OS.TRUE, OS.TRUE, "Flat Zone II", brawl, 93)
    insert_midi(YOSHI_GOLF, OS.TRUE, OS.TRUE, "Yoshi's Island (Mario Golf)", mariogolf, 286)
    insert_midi(FINALTEMPLE, OS.TRUE, OS.TRUE, "Great Temple/Dark Link", zelda2, 121)
    insert_midi(OBSTACLE, OS.TRUE, OS.TRUE, "Obstacle Course", yoshis_island, 176)
    insert_midi(EVEN_DRIER_GUYS, OS.TRUE, OS.TRUE, "Even Drier Guys", mother3, 82)
    insert_midi(FZERO_MEDLEY, OS.TRUE, OS.TRUE, "F-Zero Medley", fzero, 105)
    insert_midi(PEACH_CASTLE, OS.TRUE, OS.TRUE, "Princess Peach's Castle (Melee)", smb, 197)
    insert_midi(BANJO_MAIN, OS.TRUE, OS.TRUE, "Main Title (Banjo-Kazooie)", banjokazooie, 157)
    insert_extra_midi(BOWSER_VICTORY)
    insert_midi(MULTIMAN, OS.TRUE, OS.TRUE, "Multi-Man Melee", melee, 169)
    insert_midi(TABUU, OS.TRUE, OS.TRUE, "Boss Battle Song 2", brawl, 32)
    insert_midi(GANGPLANK, OS.TRUE, OS.TRUE, "Gang-Plank Galleon", dkc, 109)
    insert_midi(FD_BRAWL, OS.TRUE, OS.TRUE, "Final Destination (Brawl)", brawl, 89)
    insert_midi(ASTRAL_OBSERVATORY, OS.TRUE, OS.TRUE, "Astral Observatory", majora, 8)
    insert_midi(ARIA_OF_THE_SOUL, OS.TRUE, OS.TRUE, "Aria of the Soul", persona, 6)
    insert_midi(PAPER_MARIO_BATTLE, OS.TRUE, OS.TRUE, "Battle Fanfare", papermario, 17)
    insert_midi(KING_OF_THE_KOOPAS, OS.TRUE, OS.TRUE, "King of the Koopas", papermario, 138)
    insert_midi(MRPATCH, OS.TRUE, OS.TRUE, "Mr. Patch", banjo2, 167)
    insert_midi(SKERRIES, OS.TRUE, OS.TRUE, "K. Rool's Acid Punk", dkl, 134)
    insert_midi(BEWARE_THE_FORESTS_MUSHROOMS, OS.TRUE, OS.TRUE, "Beware the Forest's Mushrooms", smrpg, 22)
    insert_midi(FIGHT_AGAINST_BOWSER, OS.TRUE, OS.TRUE, "Fight Against Bowser", smrpg, 85)
    insert_midi(DKR_BOSS, OS.TRUE, OS.TRUE, "Boss Challenges", dkr, 33)
    insert_midi(CRESCENT_ISLAND, OS.TRUE, OS.TRUE, "Crescent Island", dkr, 59)
    insert_extra_midi(CONKER_VICTORY)
    insert_midi(RITH_ESSA, OS.TRUE, OS.TRUE, "Rith Essa", jetforce, 207)
    insert_midi(TARGET_TEST, OS.TRUE, OS.TRUE, "Targets!", melee, 247)
    insert_midi(VENOM, OS.TRUE, OS.TRUE, "Venom", starfox, 271)
    insert_midi(SURPRISE_ATTACK, OS.TRUE, OS.TRUE, "Surprise Attack", starfox2, 245)
    insert_midi(BK_FINALBATTLE, OS.TRUE, OS.TRUE, "Final Battle (Banjo-Kazooie)", banjokazooie, 87)
    insert_extra_midi(MEWTWO_VICTORY)
    insert_midi(OLE, OS.TRUE, OS.TRUE, "Ole!", conker, 180)
    insert_midi(WINDY, OS.TRUE, OS.TRUE, "Windy and Co.", conker, 283)
    insert_midi(STARFOX_MEDLEY, OS.TRUE, OS.TRUE, "Star Fox Medley (Melee)", starfox, 232)
    insert_midi(DATADYNE, OS.TRUE, OS.TRUE, "dataDyne Central: Defection", pd, 62)
    insert_midi(INVESTIGATION_X, OS.TRUE, OS.TRUE, "dataDyne Central: Investigation X", pd, 63)
    insert_midi(CRADLE, OS.TRUE, OS.TRUE, "Antenna Cradle", goldeneye, 4)
    insert_midi(MM_TITLE, OS.TRUE, OS.TRUE, "Opening Title (Mischief Makers)", mischiefmakers, 184)
    insert_midi(ESPERANCE, OS.TRUE, OS.TRUE, "Esperance", mischiefmakers, 81)
    insert_midi(SLOPRANO, OS.TRUE, OS.TRUE, "Sloprano", conker, 221)
    insert_extra_midi(WOLF_VICTORY)
    insert_midi(NSMB, OS.TRUE, OS.TRUE, "Overworld Theme", nsmb, 188)
    insert_midi(JUNGLEJAPES, OS.TRUE, OS.TRUE, "Jungle Japes (Melee)", dkc, 133)
    insert_midi(FOREST_INTERLUDE, OS.TRUE, OS.TRUE, "Forest Interlude", dkc2, 97)
    insert_midi(TOADS_TURNPIKE, OS.TRUE, OS.TRUE, "Toad's Turnpike", mk64, 256)
    insert_midi(GB_MEDLEY, OS.TRUE, OS.TRUE, "Game Boy Medley", ssbr, 107)
    insert_named_extra_midi(BUBBLY, "Bubbly Clouds", kirbydreamland, 38)
    insert_named_extra_midi(ROADTOCERULEANCITY, "Road to Cerulean City", pokemonred, 209)
    insert_named_extra_midi(LEVEL1_WARIO, "Stage 1", warioland, 231)
    insert_named_extra_midi(MABE, "Mabe Village", awakening, 151)
    insert_named_extra_midi(REST, "Rest Area", ssbr, 205)
    insert_midi(FE_MEDLEY, OS.TRUE, OS.TRUE, "Fire Emblem Medley", fire_emblem, 91)
    insert_midi(YOSHI_TALE, OS.TRUE, OS.TRUE, "Yoshi's Tale", yoshis_story, 288)
    insert_midi(FLOWER_GARDEN, OS.TRUE, OS.TRUE, "Flower Garden", yoshis_island, 94)
    insert_midi(WILDLANDS, OS.TRUE, OS.FALSE, "Wildlands", yoshis_island_ds, 281)
    insert_midi(VS_MARX, OS.FALSE, OS.TRUE, "Vs. Marx", kirbysuperstar, 275)
    insert_extra_midi(MARTH_VICTORY)
    insert_midi(SS_AQUA, OS.TRUE, OS.TRUE, "S.S. Aqua", pokemongold, 213)
    insert_midi(METAL_BATTLE, OS.TRUE, OS.TRUE, "Metal Battle", melee, 162)
    insert_midi(SLIDER, OS.TRUE, OS.TRUE, "Slider", sm64, 220)
    insert_midi(MULTIMAN2, OS.TRUE, OS.TRUE, "Multi-Man Melee 2", melee, 170)
    insert_midi(FIRE_EMBLEM, OS.TRUE, OS.TRUE, "Together We Ride (Melee)", fire_emblem, 257)
    insert_midi(KANTO_WILD_BATTLE, OS.TRUE, OS.TRUE, "Kanto Wild Pokemon Battle", pokemongold, 136)
    insert_midi(SMB2OVERWORLD, OS.TRUE, OS.TRUE, "Super Mario Bros. 2 Overworld", smb2, 242)
    insert_midi(PIRATELAND, OS.TRUE, OS.TRUE, "Pirate Land", marioparty2, 191)
    insert_midi(TROPICALISLAND, OS.TRUE, OS.TRUE, "Yoshi's Tropical Island", marioparty, 289)
    insert_midi(FLYINGBATTERY, OS.TRUE, OS.TRUE, "Flying Battery", sonic3, 95)
    insert_midi(OPEN_YOUR_HEART, OS.TRUE, OS.TRUE, "Open Your Heart", sonicadventure, 182)
    insert_midi(SONIC2_BOSS, OS.TRUE, OS.TRUE, "Sonic 2 Boss", sonic2, 225)
    insert_extra_midi(SONIC_VICTORY)
    insert_midi(CASINO_NIGHT, OS.TRUE, OS.TRUE, "Casino Night Zone", sonic2, 43)
    insert_midi(MONKEY_WATCH, OS.TRUE, OS.TRUE, "Monkey Watch", rhfever, 166)
    insert_midi(SONIC2_SPECIAL, OS.TRUE, OS.TRUE, "Sonic 2 Special Stage", sonic2, 226)
    insert_midi(SONICCD_SPECIAL, OS.TRUE, OS.TRUE, "Sonic CD Special Stage", soniccd, 227)
    insert_midi(GIANTWING, OS.TRUE, OS.TRUE, "Giant Wing", sonicfighters, 114)
    insert_midi(EMERALDHILL, OS.TRUE, OS.TRUE, "Emerald Hill Zone", sonic2, 80)
    insert_midi(LIVE_AND_LEARN, OS.TRUE, OS.TRUE, "Live and Learn", sonicadventure2, 148)
    insert_midi(STARDUST, OS.TRUE, OS.TRUE, "Stardust Speedway B Mix", soniccd, 234)
    insert_midi(GREEN_HILL_ZONE, OS.TRUE, OS.TRUE, "Green Hill Zone", sonic1, 124)
    insert_midi(CHEMICAL_PLANT, OS.TRUE, OS.TRUE, "Chemical Plant Zone", sonic2, 46)
    insert_midi(BABY_BOWSER, OS.TRUE, OS.TRUE, "Baby Bowser", yoshis_island, 11)
    insert_midi(WIDE_UNDERWATER, OS.TRUE, OS.TRUE, "Ocean Medley", marioparty, 178)
    insert_midi(METALLIC_MADNESS, OS.TRUE, OS.TRUE, "Metallic Madness", soniccd, 163)
    insert_midi(EVERYTHING, OS.TRUE, OS.TRUE, "Everything (Super Sonic)", sonicfighters, 83)
    insert_midi(ROCKSOLID, OS.TRUE, OS.TRUE, "Rock Solid", conker, 210)
    insert_midi(RAINBOWROAD, OS.TRUE, OS.TRUE, "Rainbow Road", mk64, 201)
    insert_midi(MK64_CREDITS, OS.TRUE, OS.TRUE, "Victory Lap", mk64, 272)
    insert_midi(RACEWAYS, OS.TRUE, OS.TRUE, "Raceways", mk64, 199)
    insert_midi(LINKS_AWAKENING_MEDLEY, OS.TRUE, OS.TRUE, "Link's Awakening Medley", awakening, 145)
    insert_midi(CORRIDORS_OF_TIME, OS.TRUE, OS.TRUE, "Corridors of Time", chrono, 55)
    insert_midi(KIRBY_64_BOSS, OS.TRUE, OS.TRUE, "Kirby 64 Boss", kirby64, 139)
    insert_midi(WALUIGI_PINBALL, OS.TRUE, OS.TRUE, "Waluigi Pinball", mkds, 277)
    insert_extra_midi(MARINA_VICTORY)
    insert_extra_midi(SHEIK_VICTORY)
    insert_extra_midi(DEDEDE_VICTORY)
    insert_midi(SMB2_MEDLEY, OS.TRUE, OS.TRUE, "Super Mario Bros. 2 Medley", smb2, 241)
    insert_midi(SMW_TITLECREDITS, OS.TRUE, OS.TRUE, "Super Mario World Title/Credits", smw, 244)
    insert_named_extra_midi(DRAGONKING, "Dragon King", dragonking, 75)
    insert_midi(DEDEDE, OS.TRUE, OS.TRUE, "King Dedede's Theme", kirbydreamland, 137)
    insert_midi(DRACULAS_CASTLE, OS.TRUE, OS.TRUE, "Dracula's Castle", castlevania_sotn, 73)
    insert_midi(IRON_BLUE_INTENTION, OS.TRUE, OS.TRUE, "Iron-Blue Intention", castlevania_bloodlines, 132)
    insert_midi(DRACULAS_TEARS, OS.TRUE, OS.TRUE, "Dracula's Tears", castlevania_dos, 74)
    insert_midi(WARIOWARE, OS.TRUE, OS.TRUE, "WarioWare, Inc.", warioware, 279)
    insert_midi(BLOODY_TEARS, OS.TRUE, OS.TRUE, "Bloody Tears", castlevania_2, 26)
    insert_midi(FROZEN_HILLSIDE, OS.TRUE, OS.TRUE, "Frozen Hillside", kirbyair, 103)
    insert_midi(MK_REVENGE, OS.TRUE, OS.TRUE, "Meta Knight's Revenge", kirbysuperstar, 161)
    insert_midi(SOCCER_MENU, OS.TRUE, OS.TRUE, "Main Menu (ISS64)", isoccer, 155)
    insert_midi(TROUBLE_MAKER, OS.TRUE, OS.TRUE, "Trouble Maker", mischiefmakers, 262)
    insert_extra_midi(MAIN_MENU2)
    insert_midi(WL2_PERFECT, OS.TRUE, OS.TRUE, "Perfect!", warioland2, 189)
    insert_midi(CONTROL, OS.TRUE, OS.TRUE, "Control Center", goldeneye, 53)
    insert_midi(OEDO_EDO, OS.TRUE, OS.TRUE, "Edo Castle Medley", goemon, 78)
    insert_midi(BIS_THEGRANDFINALE, OS.TRUE, OS.TRUE, "In The Final", marioluigi_bis, 131)
    insert_extra_midi(GOEMON_VICTORY)
    insert_midi(MAJORA_MIDBOSS, OS.TRUE, OS.TRUE, "Middle Boss Battle", majora, 164)
    insert_extra_midi(WATCH_THEME)
    insert_midi(KAI_HIGHWAY, OS.TRUE, OS.TRUE, "Kai Highway", mysticalninja, 135)
    insert_midi(SMW_ATHLETIC, OS.TRUE, OS.TRUE, "Athletic Theme", smw, 9)
    insert_midi(CRATERIA_MAIN, OS.TRUE, OS.TRUE, "Crateria Surface", supermetroid, 57)
    insert_midi(SNES_RAINBOW, OS.TRUE, OS.TRUE, "Rainbow Road (SNES)", smk, 202)
    insert_midi(BRAWL_OOT, OS.TRUE, OS.TRUE, "Ocarina of Time Medley", ocarina, 177)
    insert_midi(BOSS_E, OS.TRUE, OS.TRUE, "Boss E", starfox64, 34)
    insert_midi(MARINE_FORTRESS, OS.TRUE, OS.TRUE, "Marine Fortress", waverace, 159)
    insert_midi(TWILIGHT_CITY, OS.TRUE, OS.TRUE, "Twilight City", waverace, 263)
    insert_midi(SOUTHERNISLAND, OS.TRUE, OS.TRUE, "Southern Island/Main Theme", waverace, 228)
    insert_midi(QUEST64_BATTLE, OS.TRUE, OS.TRUE, "Battle Theme (Quest 64)", quest64, 18)
    insert_midi(MUSICAL_CASTLE, OS.TRUE, OS.TRUE, "Gorgeous Musical Castle", mysticalninja, 118)
    insert_midi(DECISIVE, OS.TRUE, OS.TRUE, "Decisive", ogrebattle64, 65)
    insert_midi(BATTLEFIELDV2, OS.TRUE, OS.TRUE, "Battlefield Ver. 2", brawl, 20)
    insert_midi(BOB, OS.TRUE, OS.TRUE, "Main Theme (Super Mario 64)", sm64, 156)
    insert_midi(AREA6, OS.TRUE, OS.TRUE, "Area 6", starfox64, 5)
    insert_midi(HILLTOPCHASE, OS.TRUE, OS.TRUE, "Hilltop Chase", kirbysuperstar, 128)
    insert_midi(STATUS, OS.TRUE, OS.TRUE, "Status", mariotennis, 236)
    insert_midi(FF4BOSS, OS.TRUE, OS.TRUE, "Boss Encounter", ff4, 35)
    insert_midi(GRIMREAPERSCAVERN, OS.TRUE, OS.TRUE, "Grim Reaper's Cavern", jackbros, 125)
    insert_midi(WORLD_OF_ENVY, OS.TRUE, OS.TRUE, "Shitto Kai / World of Envy", smtif, 218)
    insert_midi(SHANTAEMEDLEY, OS.TRUE, OS.TRUE, "Day/Night Traveling", shantae, 64)
    insert_midi(BURNINGTOWN, OS.TRUE, OS.TRUE, "Burning Town", shantae, 40)
    insert_midi(SHANTAEBOSS, OS.TRUE, OS.TRUE, "Boss Battle (Shantae)", shantae, 30)
    insert_midi(FORTRESS_BOSS, OS.TRUE, OS.TRUE, "Fortress Boss", smw, 98)
    insert_midi(HORROR_LAND, OS.TRUE, OS.TRUE, "Horror Land", marioparty2, 130)
    insert_midi(AC_TITLE, OS.TRUE, OS.TRUE, "Animal Crossing Theme", animal_crossing, 3)
    insert_midi(DARKWORLD, OS.TRUE, OS.TRUE, "Dark World", lttp, 61)
    insert_extra_midi(FILESELECT_SM64)
    insert_extra_midi(ITSATRAP_SM64)
    insert_extra_midi(BANJO_VICTORY)
    insert_extra_midi(BLASTCORPS_MENU)
    insert_midi(FRAPPE_SNOWLAND, OS.TRUE, OS.TRUE, "Frappe Snowland", mk64, 100)
    insert_midi(SMRPG_BATTLE, OS.TRUE, OS.TRUE, "Fight Against Monsters", smrpg, 86)
    insert_midi(TRAVELING, OS.TRUE, OS.TRUE, "Traveling", goepachisuro, 260)
    insert_midi(CHILL, OS.TRUE, OS.TRUE, "Chill", drm, 47)
    insert_midi(ROLL, OS.TRUE, OS.TRUE, "Roll's Theme", megamanbc, 211)
    insert_midi(STICKERBRUSH_SYMPHONY, OS.TRUE, OS.TRUE, "Stickerbrush Symphony", dkc2, 237)
    insert_midi(DOOM1, OS.TRUE, OS.TRUE, "DOOM Medley", doom, 71)
    insert_midi(RUNNING_FROM_EVIL, OS.TRUE, OS.TRUE, "Running From Evil", doom2, 212)
    insert_extra_midi(CONKER_THE_KING)
    insert_midi(GRABBAG, OS.TRUE, OS.TRUE, "Grabbag", dukenukem3d, 120)
    insert_midi(WITHMILASDIVINEPROTECTION, OS.TRUE, OS.TRUE, "With Mila's Divine Protection", fe_gaiden, 284)
    insert_midi(DKCTITLE, OS.TRUE, OS.TRUE, "Opening (Donkey Kong)", dkc, 183)
    insert_midi(PLANTATION, OS.TRUE, OS.TRUE, "Plantation", cavestory, 192)
    insert_midi(BATTLE_GOLD_SILVER, OS.TRUE, OS.TRUE, "Gold & Silver Medley", pokemongold, 116)
    insert_midi(BIG_BOO, OS.TRUE, OS.TRUE, "Haunted House", sm64, 127)
    insert_extra_midi(DKING_VICTORY)
    insert_midi(7AM, OS.TRUE, OS.TRUE, "7AM", animal_crossing, 1)
    insert_extra_midi(DKROPTIONS)
    insert_extra_midi(GALLERY)
    insert_midi(QUEQUE, OS.TRUE, OS.TRUE, "Que Que", drm64, 198)
    insert_extra_midi(MK64MENU)
    insert_midi(GOLDENROD_CITY, OS.TRUE, OS.TRUE, "Goldenrod City", pokemongold, 117)
    insert_midi(CLOCKTOWN, OS.TRUE, OS.TRUE, "Clock Town", majora, 51)
    insert_midi(BUMPERCROPBUMP, OS.TRUE, OS.TRUE, "Bumper Crop Bump", kirby64, 39)
    insert_midi(VSRIDLEY, OS.TRUE, OS.TRUE, "Vs. Ridley", supermetroid, 276)
    insert_midi(GANONMEDLEY, OS.TRUE, OS.TRUE, "Ganon Battle Medley", zelda, 110)
    insert_midi(FUGUE, OS.TRUE, OS.TRUE, "Little Fugue", ssbr, 147)
    insert_midi(NUTTY_NOON, OS.TRUE, OS.TRUE, "Nutty Noon", kirbyreturn, 175)
    insert_midi(GHOSTGULPING, OS.TRUE, OS.TRUE, "Ghost Gulping", papermario, 113)
    insert_named_extra_midi(SMB2BOSS, "Super Mario Bros. 2 Boss", smb2, 240)
    insert_midi(FZERO_CLIMBUP, OS.TRUE, OS.TRUE, "Climb Up! And Get the Last Chance!", fzero_x, 49)
    insert_midi(JFG_SELECT, OS.TRUE, OS.TRUE, "Character Select (Jet Force Gemini)", jetforce, 45)
    insert_midi(YOSHI_SKA, OS.TRUE, OS.TRUE, "Yoshi's Song", yoshis_story, 287)
    insert_midi(BOARD_SHOP, OS.TRUE, OS.TRUE, "Board Shop", sbk, 28)
    insert_midi(FLANDRES_THEME, OS.TRUE, OS.TRUE, "U.N. Owen Was Her?", 2hu6, 264)
    insert_midi(NIGHTMARE, OS.TRUE, OS.TRUE, "Final Boss (Nightmare's Battle)", kirbyadventure, 88)
    insert_midi(THE_ALOOF_SOLDIER, OS.TRUE, OS.TRUE, "The Aloof Soldier", gga, 249)
    insert_midi(WENDYS_HOUSE, OS.TRUE, OS.TRUE, "Wendy's House", sbk2, 280)
    insert_midi(DANGEROUS_FOE, OS.TRUE, OS.TRUE, "Battle Against a Dangerous Foe", earthboundb, 14)
    insert_midi(BIG_SNOWMAN, OS.TRUE, OS.TRUE, "Big Snowman", sbk, 24)
    insert_midi(PIKA_CUP, OS.TRUE, OS.TRUE, "Pika Cup Battles 1-3", stadium, 190)
    insert_midi(ASHLEYS_THEME, OS.TRUE, OS.TRUE, "Ashley's Theme", wwtouched, 7)
    insert_midi(SILVER_MOUNTAIN, OS.TRUE, OS.TRUE, "Silver Mountain", sbk, 219)
    insert_midi(WIZPIG, OS.TRUE, OS.TRUE, "Wizpig Challenge", dkr, 285)
    insert_midi(TALENTSTUDIO, OS.TRUE, OS.TRUE, "Talent Studio Medley", talentstudio, 246)
    insert_midi(BATTLE_C1, OS.TRUE, OS.TRUE, "Battle C1", smtiv, 16)
    insert_extra_midi(PLAY_A_MINIGAME)
    insert_midi(CREDITS_BRAWL, OS.TRUE, OS.TRUE, "Credits (Brawl)", ssb, 58)
    insert_extra_midi(CRASH_VICTORY)
    insert_extra_midi(PD_PAUSE)
    insert_extra_midi(PEACH_VICTORY)
    insert_midi(PORKY, OS.TRUE, OS.TRUE, "Porky Means Business!", earthbound, 195)
    insert_midi(UNDERGROUND, OS.TRUE, OS.TRUE, "Underground Theme", smb, 266)
    insert_named_extra_midi(UNDERGROUND_HURRY, "Underground Theme (Hurry Up!)", smb, 267)
    insert_midi(CRASH3, OS.TRUE, OS.TRUE, "Time Twister", crash3, 253)
    insert_midi(NSANITYBEACH, OS.TRUE, OS.TRUE, "N. Sanity Beach", crash, 173)
    insert_extra_midi(CTR_MENU)
    insert_midi(DISCOVERYFALLS, OS.TRUE, OS.TRUE, "Discovery Falls", dinoplanet, 68)
    insert_named_extra_midi(CRASHBONUS, "Bonus", crash_xs, 29)
    insert_midi(DK_MEDLEY, OS.TRUE, OS.TRUE, "Donkey Kong Medley", dkarc, 70)
    insert_midi(SM64STAFF, OS.TRUE, OS.TRUE, "Staff Roll (Super Mario 64)", sm64, 230)
    insert_midi(BIG_BRIDGE, OS.TRUE, OS.TRUE, "Clash on the Big Bridge", ff5, 48)
    insert_midi(HOGWILD, OS.TRUE, OS.TRUE, "Hog Wild", crash, 129)
    insert_midi(MARATHON, OS.TRUE, OS.TRUE, "Marathon 2 Title Theme", marathon2, 158)
    insert_midi(FORGONE, OS.TRUE, OS.TRUE, "Foregone Destruction", ut99, 96)
    insert_midi(MORRIGAN, OS.TRUE, OS.TRUE, "Theme of Morrigan", mvc, 252)
    insert_midi(ELADARD, OS.TRUE, OS.TRUE, "Eladard", starfox2, 79)
    insert_midi(MADMAZEMAUL, OS.TRUE, OS.TRUE, "Mad Maze Maul", dk64, 153)
    insert_midi(ORANGSPRINT, OS.TRUE, OS.TRUE, "OrangSprint", dk64, 186)
    insert_midi(DRAKE_LAKE, OS.TRUE, OS.TRUE, "Drake Lake", waverace, 76)
    insert_midi(BUBBLEGUM_KK, OS.TRUE, OS.TRUE, "Bubblegum K.K.", acnewleaf, 37)
    insert_midi(FZEROX_MEDLEY, OS.TRUE, OS.TRUE, "F-Zero X Medley", fzero_x, 106)
    insert_midi(FREEZE, OS.TRUE, OS.TRUE, "Freeze!", papermario, 101)
    insert_midi(TITANIA, OS.TRUE, OS.TRUE, "Titania", starfox, 254)
    insert_midi(THEATER, OS.TRUE, OS.TRUE, "Theater", kirby64, 251)
    insert_extra_midi(ENEMYCARD)
    insert_midi(SHEVAT, OS.TRUE, OS.TRUE, "Shevat, the Wind is Calling", xenogears, 217)
    insert_midi(CORTEX, OS.TRUE, OS.TRUE, "Dr. Neo Cortex", crash2, 72)
    insert_midi(WILY_FIELD, OS.TRUE, OS.TRUE, "Wily's Field", megamanscr, 282)
    insert_midi(SMS_BOSS, OS.TRUE, OS.TRUE, "Boss Battle (Sunshine)", sunshine, 31)
    insert_midi(COBALT, OS.TRUE, OS.TRUE, "Cobalt Coast", heypika, 52)
    insert_midi(VS_DSAMUS, OS.TRUE, OS.TRUE, "Vs. Dark Samus", metroidprime3, 273)
    insert_midi(STRIKE_THE_EARTH, OS.TRUE, OS.TRUE, "Strike the Earth!", shovelknight, 239)
    insert_midi(VAMPIREKILLER, OS.TRUE, OS.TRUE, "Vampire Killer", castlevania, 270)
    insert_midi(KOOPA_BROS, OS.TRUE, OS.TRUE, "Attack of the Koopa Bros.", papermario, 10)
    insert_midi(REDIAL, OS.TRUE, OS.TRUE, "Redial", bombermanhero, 204)
    insert_midi(AGAVE, OS.TRUE, OS.TRUE, "Agave", snp, 2)
    insert_midi(RAIDBLUE, OS.TRUE, OS.TRUE, "Raid Blue", snp, 200)
    insert_midi(RISKNECK, OS.TRUE, OS.TRUE, "Risk One's Neck", snp, 206)
    insert_midi(SHERBETLAND, OS.TRUE, OS.TRUE, "Sherbet Land", mariohoops, 216)
    insert_midi(DEATH_MOUNTAIN, OS.TRUE, OS.TRUE, "Dark Mountain Forest", lttp, 60)
    insert_midi(BATTLE_AMONG_FRIENDS, OS.TRUE, OS.TRUE, "Battle Among Friends", kirby64, 15)
    insert_midi(BUTTER_BUILDING, OS.TRUE, OS.TRUE, "Butter Building", kirbyadventure, 41)
    insert_midi(MURASAKI, OS.TRUE, OS.TRUE, "Murasaki Forest", mother3, 171)
    insert_midi(SKYWORLD, OS.TRUE, OS.TRUE, "Overworld (Kid Icarus)", kidicarus, 187)
    insert_midi(FE6_MEDLEY, OS.TRUE, OS.TRUE, "Binding Blade Medley", fe6, 25)
    insert_named_extra_midi(SNOWGO, "Snow Go", crash2, 223)
    insert_named_extra_midi(FUTUREFRENZY, "Future Frenzy", crash3, 104)
    insert_extra_midi(LANKY_VICTORY)
    insert_midi(SILVERSURFER, OS.TRUE, OS.TRUE, "Level 1 (Silver Surfer)", silversurfer, 144)
    insert_midi(OPUS_13, OS.TRUE, OS.TRUE, "Opus 13", castlevania_rob, 185)
    insert_midi(FOURSIDE, OS.TRUE, OS.TRUE, "Fourside", earthbound, 99)
    insert_midi(BALLOONFIGHT, OS.TRUE, OS.TRUE, "Balloon Fight", balloonfight, 13)
    insert_midi(LIPS_THEME, OS.TRUE, OS.TRUE, "Lip's Theme", paneldepon, 146)
    insert_named_extra_midi(CRASHBASH_LOADING, "Crash Bash Loading Screen", crashbash, 56)
    insert_midi(TREASURE_TROVE_COVE, OS.TRUE, OS.TRUE, "Treasure Trove Cove", banjokazooie, 261)
    insert_extra_midi(STAGESELBM64)
    insert_midi(OLDKINGCOAL, OS.TRUE, OS.TRUE, "Old King Coal", banjo2, 179)
    insert_extra_midi(SONIC_R)
    insert_midi(GREENGARDEN, OS.TRUE, OS.TRUE, "Green Garden", bomberman, 122)
    insert_midi(BLUE_RESORT, OS.TRUE, OS.TRUE, "Blue Resort", bomberman, 27)
    insert_midi(LOST, OS.TRUE, OS.TRUE, "Lost", dream, 149)

    pushvar origin, base

    // Extend Sound Test Music numbers so we can test in game easier
    origin  0x1883BA
    dh      midi_count
    origin  0x188246
    dh      midi_count - 1
    origin  0x1883C2
    dh      midi_count - 1
    origin  0x1883CE
    dh      midi_count - 1

    pullvar base, origin

    // @ Description
    // Replaces the allocated space for loading music files with a fixed-size block in expansion ram.
    scope replace_midi_block_: {
        OS.patch_start(0x20304, 0x8001F704)
        // replaces a part of the memory allocation routine which calls subroutine 0x8001E5F4 to allocate a fixed-size block equivalent to the largest midi
        // instead of allocating a block of memory, we'll just set the address to midi_memory_block, which is our own fixed-size block that we allocated in expansion ram
        li      v0, midi_memory_block       // v0 = midi_memory_block, originally address of allocated block
        fill 0x8001F724 - pc()              // nop the original memory allocation
        OS.patch_end()
    }

    // @ Description
    // Modifies the routine that maps Sound Test screen choices to BGM IDs
    scope augment_sound_test_music_: {
        OS.patch_start(0x188530, 0x80132160)
        j       augment_sound_test_music_
        nop
        OS.patch_end()

        lui     t0, 0x8013                        // original line 1
        lw      t0, 0x4348(t0)                    // original line 2
        slti    a0, t0, 0x2D                      // check if this is one we added (so >= 0x2D)
        bnez    a0, _normal                       // if (original bgm_id) then skip to _normal
        nop
        // If we're here, then the music ID is > 0x2C which means it's
        // one we added. So we need to set up a1 as the extended music
        // table address and offset:
        li      a1, extended_music_map_table      // a1 = address of extended table
        addiu   t0, t0, -0x002D                   // t0 = slot in extended table
        sll     t1, t0, 0x2                       // t1 = offset for bgm_id in extended table
        addu    a1, a1, t1                        // a1 = adress for bgm_id
        lhu     a1, 0x0002(a1)                    // a1 = bgm_id
        jal     0x80020AB4                        // call play MIDI routine
        nop
        j       0x80132180                        // return
        nop

        _normal:
        j       0x80132168                        // continue with original line 3
        nop
    }

    extended_music_map_table:
    dw     0xA                                    // for some reason originally left of music test
    dw     0xB                                    // for some reason originally left of music test
    define n(0x2F)
    while {n} < midi_count {
        dw      {n}
        evaluate n({n}+1)
    }

    print "========================================================================== \n"

    print "=============================== INSTRUMENTS ============================== \n"

    // Constants and variables related to instruments
    read32 INST_CTL_TABLE, "../roms/original.z64", 0x3D75C                       // CTL_TABLE is the base for a lot of sound related offsets
    constant INST_CTL_TABLE_PC(0x800472D0)                                       // CTL_TABLE is loaded in RAM here
    read32 INST_BANK_MAP_OFFSET, "../roms/original.z64", INST_CTL_TABLE + 0x0004 // INST_BANK_MAP_OFFSET is the offset from CTL to the INST_BANK_MAP
    constant INST_BANK_MAP(INST_CTL_TABLE + INST_BANK_MAP_OFFSET)                // INST_BANK_MAP holds offsets to each instrument
    read32 INST_SAMPLE_DATA, "../roms/original.z64", 0x3D760                     // INST_SAMPLE_DATA is the raw sample data
    variable instrument_count(0x2A)                                              // variable containing the total number of added instruments
    variable current_instrument_sample_count(0)                                  // variable containing number of samples in the current instrument

    // @ Description
    // Adds an instrument sample to be used by the instrument created in the next add_instrument() call
    // name                        - Name of .aifc file of sample (and .bin of loop predictors file if present)
    // attack_time                 - (word) attack time
    // decay_time                  - (word) decay time
    // release_time                - (word) release time
    // attack_volume               - (byte) attack volume
    // decay_volume                - (byte) decay volume
    // vel_min                     - (byte) vel min
    // vel_max                     - (byte) vel max
    // key_min                     - (byte) key min
    // key_max                     - (byte) key max
    // key_base                    - (byte) key base
    // detune                      - (byte) detune
    // sample_pan                  - (byte) sample pan
    // sample_volume               - (byte) sample volume
    // loop_enabled                - (bool) if OS.FALSE, then loop is not enabled, if OS.TRUE then loop is enabled
    // loop_start                  - (word) loop start
    // loop_end                    - (word) loop end
    // loop_count                  - (word) loop count
    // loop_predictors_file_exists - (bool) if OS.TRUE, then loop predictors are in {name}.bin, if OS.FALSE then fill with 0
    macro add_instrument_sample(name, attack_time, decay_time, release_time, attack_volume, decay_volume, vel_min, vel_max, key_min, key_max, key_base, detune, sample_pan, sample_volume, loop_enabled, loop_start, loop_end, loop_count, loop_predictors_file_exists) {
        if current_instrument_sample_count == 0 {
            // increment instrument count
            global variable instrument_count(instrument_count + 1)
        }

        // increment current_instrument_sample_count
        global variable current_instrument_sample_count(current_instrument_sample_count + 1)
        evaluate inst_num(instrument_count)
        evaluate sample_num(current_instrument_sample_count)
        global define SAMPLE_NAME_{inst_num}_{sample_num}({name})
        // Sample length is 2 words too long
        read32 SAMPLE_LENGTH_{inst_num}_{sample_num}, "../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.aifc", 0xF4

        attack_delay_params_{inst_num}_{sample_num}:
        dw      {attack_time}
        dw      {decay_time}
        dw      {release_time}
        db      {attack_volume}
        db      {decay_volume}
        dh      0x0000 // ?

        vel_key_params_{inst_num}_{sample_num}:
        db      {vel_min}
        db      {vel_max}
        db      {key_min}
        db      {key_max}
        db      {key_base}
        db      {detune}
        dh      0x0000 // ?

        instrument_block_{inst_num}_{sample_num}:
        dw      attack_delay_params_{inst_num}_{sample_num} - INST_CTL_TABLE_PC
        dw      vel_key_params_{inst_num}_{sample_num} - INST_CTL_TABLE_PC
        dw      pc() + 0x8 - INST_CTL_TABLE_PC

        db      {sample_pan}
        db      {sample_volume}
        dh      0x0000 // ?

        // insert raw data
        pushvar origin, base
        origin  MIDI_BANK_END
        // I believe loop predictors will be at the end of the file, so I intentionally read a specific length
        constant SAMPLE_RAW_{inst_num}_{sample_num}_origin(origin())
        insert SAMPLE_RAW_{inst_num}_{sample_num}, "../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.aifc", 0x100, SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008
        global variable MIDI_BANK_END(origin())
        pullvar base, origin

        dw      SAMPLE_RAW_{inst_num}_{sample_num}_origin - INST_SAMPLE_DATA // pointer to raw data
        dw      SAMPLE_LENGTH_{inst_num}_{sample_num} - 0x0008               // length of raw data
        dw      0x0000 // ?

        if {loop_enabled} == OS.TRUE {
            dw  loop_params_{inst_num}_{sample_num} - INST_CTL_TABLE_PC
        } else {
            dw  0x0000
        }

        dw      predictors_{inst_num}_{sample_num} - INST_CTL_TABLE_PC

        dw      0x0000

        if {loop_enabled} == OS.TRUE {
            loop_params_{inst_num}_{sample_num}:
            dw  {loop_start}
            dw  {loop_end}
            dw  {loop_count}
            // loop predictors - I believe they should be at the end of the .aifc file, but haven't been able to produce a valid one yet
            // ...but n64 sound tool produces them
            if {loop_predictors_file_exists} == OS.TRUE {
                insert "../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.bin"
            } else {
                fill 0x20, 0x0
            }
            dw  0x0000
        }

        predictors_{inst_num}_{sample_num}:
        dw     0x00000002
        dw     0x00000004
        insert SAMPLE_PREDICTORS_{inst_num}_{sample_num}, "../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.aifc", 0x70, 0x80
    }

    // @ Description
    // Adds an instrument consisting of all the instrument samples added since the last add_instrument() call
    // name       - Name of the instrument (for display purposes only)
    // volume     - (byte) volume
    // pan        - (byte) pan
    // priority   - (byte) priority
    // bend_range - (hw) bend range
    // trem_type  - (byte) trem type
    // trem_rate  - (byte) trem rate
    // trem_depth - (byte) trem depth
    // trem_delay - (byte) trem delay
    // vib_type   - (byte) vib type
    // vib_rate   - (byte) vib rate
    // vib_depth  - (byte) vib depth
    // vib_delay  - (byte) vid delay
    macro add_instrument(name, volume, pan, priority, bend_range, trem_type, trem_rate, trem_depth, trem_delay, vib_type, vib_rate, vib_depth, vib_delay) {
        evaluate inst_num(instrument_count)
        global define INST_NAME_{inst_num}({name})
        print "Added {INST_NAME_{inst_num}}\nINST_ID: 0x"; OS.print_hex({inst_num}); print " (", {inst_num},")\nSamples:\n"

        instrument_parameters_{inst_num}:
        db      {volume}
        db      {pan}
        db      {priority}
        db      0x00                               // Gets set to 1 when processed
        db      {trem_type}
        db      {trem_rate}
        db      {trem_depth}
        db      {trem_delay}
        db      {vib_type}
        db      {vib_rate}
        db      {vib_depth}
        db      {vib_delay}
        dh      {bend_range}                       // 0x0064 for most (2 semitones?)
        dh      current_instrument_sample_count

        // pointers to instrument blocks
        define n(1)
        while {n} <= current_instrument_sample_count {
            dw       instrument_block_{inst_num}_{n} - INST_CTL_TABLE_PC
            print " - {SAMPLE_NAME_{inst_num}_{n}}\n"
            evaluate n({n}+1)
        }

        // This is necessary so the next instrument doesn't get jarbled
        OS.align(16)

        // reset current_instrument_sample_count
        global variable current_instrument_sample_count(0)
    }

    // @ Description
    // Moves the instrument bank map so it can be extended
    macro move_instrument_bank_map() {
        evaluate inst_num(instrument_count)

        // Move INST_BANK_MAP so it can be extended
        moved_inst_bank_map:
        global variable moved_inst_bank_map_origin(origin())
        OS.move_segment(INST_BANK_MAP, 0xB8)

        // extend using instrument_count
        define n(0x2B)
        evaluate n({n})
        while {n} <= {inst_num} {
            dw       instrument_parameters_{n} - INST_CTL_TABLE_PC
            evaluate n({n}+1)
        }

        pushvar origin, base

        // Update instrument count
        origin moved_inst_bank_map_origin
        dh      instrument_count + 1

        // Update INST_BANK_MAP_OFFSET to point to new location
        origin INST_CTL_TABLE + 0x0004
        dw      moved_inst_bank_map - INST_CTL_TABLE_PC

        pullvar base, origin
    }

    // This is necessary so the first instrument doesn't get jarbled
    OS.align(16)

    // Add instrument samples, then call add_instrument
    // TODO: Rock out with this organ!
    add_instrument_sample(rock_organ_m3_0, 0x0, 0x0, 66 * 250, 0x7F, 0x7F, 0x0, 0x7F, 0,  78,  67, 0x0, 0x3F, 0x7E, OS.TRUE, 6027, 16305, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(rock_organ_m3_1, 0x0, 0x0, 66 * 250, 0x7F, 0x7F, 0x0, 0x7F, 79,  91,  79, 0x0, 0x3F, 0x7E, OS.TRUE, 3014, 8153, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(rock_organ_m3_2, 0x0, 0x0, 66 * 250, 0x7F, 0x7F, 0x0, 0x7F, 80,  103,  91, 0x0, 0x3F, 0x7E, OS.TRUE, 3014, 8153, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Rock Organ, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Make some cool omninus sounding music with this, or cool backing vocals
    add_instrument_sample(choir_ahhs-0, 0x0, 0x0, 66 * 1754, 0x7F, 0x7F, 0x0, 0x7F,  0, 77, 65, 0x0, 0x3F, 0x7E, OS.TRUE, 3332, 27392, 0xFFFFFFFF, OS.TRUE)
    add_instrument(Choir Ahhs, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Make some cool omninus sounding music with this, or cool backing vocals
    add_instrument_sample(choir_oohs-0, 0x0, 0x0, 66 * 1754, 0x7F, 0x7F, 0x00, 0x7F, 0, 87, 75, 0x0, 0x3F, 0x7E, OS.TRUE, 1577, 23930, 0xFFFFFFFF, OS.TRUE)
    add_instrument(Choir Oohs, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Do some tasty licks with this one, though preferably with the other one
    add_instrument_sample(slap_bass_alt-0, 0x0, 0x0, 30000, 0x7F, 0x7F, 0x00, 0x7F,  0,  59, 48, 0x0, 0x3F, 0x7E, OS.TRUE, 14767, 17457, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(slap_bass_alt-1, 0x0, 0x0, 30000, 0x7F, 0x7F, 0x00, 0x7F, 60,  71, 60, 0x0, 0x3F, 0x7E, OS.TRUE, 7384, 8729, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(slap_bass_alt-2, 0x0, 0x0, 30000, 0x7F, 0x7F, 0x00, 0x7F, 72,  84, 72, 0x0, 0x3F, 0x7E, OS.TRUE, 3692, 4365, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Slap Bass Stock Alt, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(church_organ-1, 0x0, 0x0, 66 * 750, 0x7F, 0x7F, 0x0, 0x7F, 0,  71,  60, 0x0, 0x3F, 0x7E, OS.TRUE, 15104, 71862, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(church_organ-2, 0x0, 0x0, 66 * 750, 0x7F, 0x7F, 0x0, 0x7F, 72, 127, 72, 0x0, 0x3F, 0x7E, OS.TRUE, 5681,  29819, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Church Organ, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(steel_drum-0, 0x0, 0x004C4B40, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F,  0,  67,  67, 0x0, 0x3F, 0x7E, OS.TRUE, 17025, 23941, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(steel_drum-1, 0x0, 0x004C4B40, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 68, 127,  73, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 0, 0, OS.FALSE)
    add_instrument(Steel Drum, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Make any song that uses this instrument super awesome
    add_instrument_sample(distortion_guitar-1, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 0,   42, 40, 0x0, 0x3F, 0x7E, OS.TRUE, 0x3383, 0x677A, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-2, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 43,  48, 46, 0x0, 0x3F, 0x7E, OS.TRUE, 0x3333, 0x6686, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-3, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 49,  53, 52, 0x0, 0x3F, 0x7E, OS.TRUE, 0x3477, 0x684C, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-4, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 54,  56, 55, 0x0, 0x3F, 0x7E, OS.TRUE,  25240,  65462, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-5, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 57,  58, 57, 0x0, 0x3F, 0x7E, OS.TRUE,  21144,  48670, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-6, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 59,  63, 62, 0x0, 0x3F, 0x7E, OS.TRUE,  20292,  44855, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-7, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 64,  65, 64, 0x0, 0x3F, 0x7E, OS.TRUE,  24855,  49720, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-8, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 66,  70, 69, 0x0, 0x3F, 0x7E, OS.TRUE,  18279,  37962, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-9, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 71,  72, 71, 0x0, 0x3F, 0x7E, OS.TRUE,  11738,  37333, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-10, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 73,  77, 76, 0x0, 0x3F, 0x7E, OS.TRUE,  23164,  35483, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-11, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 78,  82, 81, 0x0, 0x3F, 0x7E, OS.TRUE,  14999,  37007, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(distortion_guitar-12, 0x0, 0x004C4B40, 66 * 450, 0x7F, 0x0, 0x0, 0x7F, 83,  95, 83, 0x0, 0x3F, 0x7E, OS.TRUE,  14439,  29101, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Distortion Guitar, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x80, 0xF1, 0x64, 0x01)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(saxophone-0, 0x0, 0x001E8480, 66 * 300, 0x7F, 0x0, 0x00, 0x7F,  0,  75, 64, 0x0, 0x3F, 0x7E, OS.TRUE, 6644, 8585, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(saxophone-1, 0x0, 0x001E8480, 66 * 300, 0x7F, 0x0, 0x00, 0x7F, 76, 127, 76, 0x0, 0x3F, 0x7E, OS.TRUE, 5264, 10014, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Saxophone, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Make any song that uses this instrument super awesome
    add_instrument_sample(overdriven_guitar-0, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 0,  59,  59, 0x0, 0x3F, 0x7E, OS.TRUE, 39088, 66074, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(overdriven_guitar-1, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 60, 64,  64, 0x0, 0x3F, 0x7E, OS.TRUE, 23395, 44703, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(overdriven_guitar-2, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 65, 70,  69, 0x0, 0x3F, 0x7E, OS.TRUE, 14699, 27490, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(overdriven_guitar-3, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 71, 74,  73, 0x0, 0x3F, 0x7E, OS.TRUE, 19841, 32444, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(overdriven_guitar-4, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 75, 78,  77, 0x0, 0x3F, 0x7E, OS.TRUE, 18937, 31235, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(overdriven_guitar-5, 0x0, 0x002DC6C0, 66 * 350, 0x7F, 0x0, 0x0, 0x7F, 79, 100, 88, 0x0, 0x3F, 0x7E, OS.TRUE, 10849, 18728, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Overdriven Guitar, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(jv_piano-1, 0x0, 800000, 66 * 1879, 0x7F, 0x20, 0x0, 0x7F, 0,  44,  40, 0x0, 0x3F, 0x7E, OS.TRUE, 9059, 18755, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(jv_piano-2, 0x0, 800000, 66 * 1879, 0x7F, 0x20, 0x0, 0x7F, 45, 57,  52, 0x0, 0x3F, 0x7E, OS.TRUE, 6457, 132493, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(jv_piano-3, 0x0, 800000, 66 * 1879, 0x7F, 0x20, 0x0, 0x7F, 58, 70, 64,  0x0, 0x3F, 0x7E, OS.TRUE, 6140, 12337, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(jv_piano-4, 0x0, 800000, 66 * 1879, 0x7F, 0x20, 0x0, 0x7F, 71, 81, 76,  0x0, 0x3F, 0x7E, OS.TRUE, 6441, 12930, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(jv_piano-5, 0x0, 800000, 66 * 1879, 0x7F, 0x20, 0x0, 0x7F, 82, 100, 88, 0x0, 0x3F, 0x7E, OS.TRUE, 9255, 13258, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Piano, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(slap_bass-1, 0x0, 0x0, 66 * 500, 0x7F, 0x7F, 0x0, 0x7F, 0,  39,  28, 0x0, 0x3F, 0x7E, OS.TRUE, 24607, 36249, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(slap_bass-2, 0x0, 0x0, 66 * 500, 0x7F, 0x7F, 0x0, 0x7F, 40, 51, 40, 0x0, 0x3F, 0x7E, OS.TRUE, 9445,  21094, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(slap_bass-3, 0x0, 0x0, 66 * 500, 0x7F, 0x7F, 0x0, 0x7F, 52, 64, 52, 0x0, 0x3F, 0x7E, OS.TRUE, 9445,  21094, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Slap Bass, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(orchestral_hit-1, 0x0, 0x000F4240, 66 * 3000, 0x7F, 0x0, 0x0, 0x7F, 0,  127,  72, 0x0, 0x3F, 0x7E, OS.TRUE, 12273, 18432, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Orchestral Hit, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(synth_alt-1, 0x0, 0x0, 66 * 150, 0x7F, 0x7F, 0x0, 0x7F, 0,  127,  84, 0x0, 0x3F, 0x7E, OS.TRUE, 2797, 4798, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Synth Alt, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: for these samples, make sure values are correct (assuming we keep this instrument)
    add_instrument_sample(square_25-1, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F,  0,  45,  36, 0x0, 0x3F, 0x7E, OS.TRUE,  8474, 38310, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(square_25-2, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F, 46,  57,  48, 0x0, 0x3F, 0x7E, OS.TRUE, 10667, 28738, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(square_25-3, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F, 58,  69,  60, 0x0, 0x3F, 0x7E, OS.TRUE,  3933, 22004, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(square_25-4, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F, 70,  81,  72, 0x0, 0x3F, 0x7E, OS.TRUE,  5321, 26994, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(square_25-5, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F, 82,  93,  84, 0x0, 0x3F, 0x7E, OS.TRUE, 10505, 23112, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(square_25-6, 0x0, 0x0, 66 * 30, 0x7F, 0x7F, 0x0, 0x7F, 94, 127,  96, 0x0, 0x3F, 0x7E, OS.TRUE,  5252, 11556, 0xFFFFFFFF, OS.FALSE)
    add_instrument(NES Square Wave 25P, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    add_instrument_sample(banjo_2_alt-0, 0x0, 0x0010C8E0, 25000, 0x7F, 0x00, 0x00, 0x7F,  0,  71, 60, 0x0, 0x3F, 0x7E, OS.TRUE, 8453, 11392, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(banjo_2_alt-1, 0x0, 0x0010C8E0, 25000, 0x7F, 0x00, 0x00, 0x7F, 72,  83, 72, 0x0, 0x3F, 0x7E, OS.TRUE, 4227, 5696, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(banjo_2_alt-2, 0x0, 0x0010C8E0, 25000, 0x7F, 0x00, 0x00, 0x7F, 84,  96, 84, 0x0, 0x3F, 0x7E, OS.TRUE, 2114, 2848, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Banjo 2 Alt, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Make some synthy sounding tracks
    add_instrument_sample(sawtoothK64_1, 0x0, 0x0, 66 * 200, 0x7F, 0x7F, 0x00, 0x7F, 0, 71, 60, -15, 0x3F, 0x7E, OS.TRUE, 12440, 26687, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(sawtoothK64_2, 0x0, 0x0, 66 * 200, 0x7F, 0x7F, 0x00, 0x7F, 72, 83, 72, -5, 0x3F, 0x7E, OS.TRUE, 12808, 27679, 0xFFFFFFFF, OS.FALSE)
    add_instrument_sample(sawtoothK64_3, 0x0, 0x0, 66 * 200, 0x7F, 0x7F, 0x00, 0x7F, 84, 127, 84, -10, 0x3F, 0x7E, OS.TRUE, 13329, 20767, 0xFFFFFFFF, OS.FALSE)
    add_instrument(Sawtooth Kirby 64, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: For big moments with guitars
    add_instrument_sample(guitar_slide-0, 0x0, 0x0, 66 * 200, 0x7F, 0x7F, 0x00, 0x7F, 0, 71, 60, -15, 0x3F, 0x7E, OS.TRUE, 12440, 26687, 0xFFFFFFFF, OS.FALSE)
    add_instrument(MOTHER 3 Shogo Sakai Guitar Slide, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Member loop predictors? I member.
    add_instrument_sample(oot_acoustic-1, 0x0, 0x002191C0, 32700, 0x7F, 0x50, 0x0, 0x7F, 0,  66,  56, 0x0, 0x3F, 0x7E, OS.TRUE, 21110, 29276, 0xFFFFFFFF, OS.TRUE)
    add_instrument_sample(oot_acoustic-2, 0x0, 0x002191C0, 32700, 0x7F, 0x50, 0x0, 0x7F, 67,  87,  75, 0x0, 0x3F, 0x7E, OS.TRUE, 16035, 19171, 0xFFFFFFFF, OS.TRUE)
    add_instrument(OOT Acoustic, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: For invoking lots of emotion
    add_instrument_sample(pizzicato_ffxi-1, 0x0, 0x004C4B40, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F,  0,  83,  72, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(pizzicato_ffxi-2, 0x0, 0x004C4B40, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 84,  95,  84, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(pizzicato_ffxi-3, 0x0, 0x004C4B40, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 96, 127,  96, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 0, 0, OS.FALSE)
    add_instrument(Pizzicato FFXI, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Rename to the "Jamie Jamieson"
    add_instrument_sample(jamisen-1, 0x0, 0x002625A0, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F,  0,  73,  67, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(jamisen-2, 0x0, 0x00249F00, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 74,  88,  79, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(jamisen-3, 0x0, 0x001B7740, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 89,  103,  91, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(Shamisen, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Cry about the fact this takes up 1.1MB of ROM space
    add_instrument_sample(herewego,  0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  0,  0,  12, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0000, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  1,  1,  13, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0001, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  2,  2,  14, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0002, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  3,  3,  15, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0003, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  4,  4,  16, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0004, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  5,  5,  17, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0005, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  6,  6,  18, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0006, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  7,  7,  19, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0007, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  8,  8,  20, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0008, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  9,  9,  21, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0009, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 10, 10,  22, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0010, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 11, 11,  23, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0011, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 12, 12,  24, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0012, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 13, 13,  25, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0013, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 14, 14,  26, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0014, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 15, 15,  27, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0015, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 16, 16,  28, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0016, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 17, 17,  29, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0017, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 18, 18,  30, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0018, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 19, 19,  31, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0019, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 20, 20,  32, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0020, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 21, 21,  33, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0021, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 22, 22,  34, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0022, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 23, 23,  35, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0023, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 24, 24,  36, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0024, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 25, 25,  37, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0025, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 26, 26,  38, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0026, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 27, 27,  39, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0027, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 28, 28,  40, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0028, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 29, 29,  41, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0029, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 30, 30,  42, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0030, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 31, 31,  43, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0031, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 32, 32,  44, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0032, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 33, 33,  45, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0033, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 34, 34,  46, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0034, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 35, 35,  47, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0035, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 36, 36,  48, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0036, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 37, 37,  49, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0037, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 38, 38,  50, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0038, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 39, 39,  51, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0039, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 40, 40,  52, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0040, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 41, 41,  53, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0041, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 42, 42,  54, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0042, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 43, 43,  55, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0043, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 44, 44,  56, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0044, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 45, 45,  57, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0045, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 46, 46,  58, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0046, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 47, 47,  59, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0047, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 48, 48,  60, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0048, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 49, 49,  61, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0049, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 50, 50,  62, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0050, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 51, 51,  63, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0051, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 52, 52,  64, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0052, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 53, 53,  65, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0053, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 54, 54,  66, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0054, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 55, 55,  67, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0055, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 56, 56,  68, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0056, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 57, 57,  69, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0057, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 58, 58,  70, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0058, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 59, 59,  71, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0059, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 60, 60,  72, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0060, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 61, 61,  73, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0061, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 62, 62,  74, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0062, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 63, 63,  75, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0063, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 64, 64,  76, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0064, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 65, 65,  77, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0065, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 66, 66,  78, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0067, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 67, 67,  79, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0068, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 68, 68,  80, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0069, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 69, 69,  81, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0070, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 70, 70,  82, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0071, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 71, 71,  83, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0072, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 72, 72,  84, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0073, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 73, 73,  85, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0074, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 74, 74,  86, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0075, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 75, 75,  87, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0076, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 76, 76,  88, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0077, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 77, 77,  89, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0078, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 78, 78,  90, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0079, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 79, 79,  91, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0080, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 80, 80,  92, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0081, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 81, 81,  93, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0082, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 82, 82,  94, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0083, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 83, 83,  95, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(lyric0084, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 84, 84,  96, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(sfx1,      0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 85, 85,  97, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(sfx2,      0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 86, 86,  98, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(sfx3,      0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 87, 87,  99, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(sfx4,      0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 88, 88, 100, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(DK_Rap, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)


    // TODO: be ecstatic its only 357k
    add_instrument_sample(roll-1, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  24,  24,  36, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-2, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  25,  25,  37, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-3, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  26,  26,  38, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-4, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  27,  27,  39, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-5, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  28,  28,  40, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-6, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  29,  29,  41, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-7, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  30,  30,  42, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-8, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  31,  31,  43, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-9, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  32,  32,  44, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-10, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  33,  33,  45, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-11, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  34,  34,  46, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-12, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  35,  35,  47, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-13, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  36,  36,  48, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-14, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  37,  37,  49, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-15, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  38,  38,  50, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-16, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  39,  39,  51, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-17, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  40,  40,  52, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-18, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  41,  41,  53, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-19, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  42,  42,  54, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-20, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  43,  43,  55, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-21, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  44,  44,  56, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-22, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  45,  45,  57, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-23, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  46,  46,  58, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-24, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  47,  47,  59, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-25, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  48,  48,  60, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-26, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  49,  49,  61, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-27, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  50,  50,  62, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(roll-28, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  51,  51,  63, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(Roll, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Eat Apples
    add_instrument_sample(yoshi1, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  0,  28,  36, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(yoshi2, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  29, 40,  48, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(yoshi3, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  41, 72,  60, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(Yoshis, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Marimba on these fools.
    add_instrument_sample(marimba-1, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F,  0,  64,  55, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(marimba-2, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 65,  77,  67, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(marimba-3, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 78,  91,  79, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(marimba-4, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 89,  103, 91, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(Marimba, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: Use these samples for a single song and never touch them again
    add_instrument_sample(DFChant1, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 60,  60,  72, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(DFChant2, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 61,  61,  73, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(DFChant3, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 62,  62,  74, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(DFChant4, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 63,  75,  75, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(DF_Chants, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

	// TODO: Oook ookie ook hoo hoo haa hoa and hoo ookie ook hoo
    add_instrument_sample(Monkey01, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 44,  44,  62, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey02, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 45,  45,  63, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey03, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 46,  50,  64, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey04, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 56,  56,  80, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey05, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 57,  57,  81, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey06, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 58,  58,  77, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey07, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 59,  59,  71, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey08, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 60,  60,  72, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey09, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 61,  61,  72, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument_sample(Monkey10, 0x0, 0x0, 66 * 1879, 0x7F, 0x7F, 0x0, 0x7F, 62,  80,  74, 0x0, 0x3F, 0x7E, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_instrument(Monkey, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: send John 1 million dollars
    add_instrument_sample(sine-1, 14000, 0x0, 7530, 0x7F, 0x7F, 0x0, 0x7F,  0, 95, 84, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 948, 0xFFFFFFFF, OS.TRUE)
    add_instrument_sample(sine-2, 14000, 0x0, 7530, 0x7F, 0x7F, 0x0, 0x7F,  96, 107, 96, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 1162, 0xFFFFFFFF, OS.TRUE)
    add_instrument_sample(sine-3, 14000, 0x0, 7530, 0x7F, 0x7F, 0x0, 0x7F,  108, 120, 108, 0x0, 0x3F, 0x7E, OS.TRUE, 0, 925, 0xFFFFFFFF, OS.TRUE)
    add_instrument(Sine Wave, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    // TODO: add a lil bit of blbldlldldldding to some bomberman music or something idk
    add_instrument_sample(harp-1, 0x0, 700000, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F,  0,  83,  74, 0x0, 0x3F, 0x7E, OS.TRUE, 10276, 15524, 0xFFFFFFFF, OS.TRUE)
    add_instrument_sample(harp-2, 0x0, 700000, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 84,  95,  86, 0x0, 0x3F, 0x7E, OS.TRUE, 5209, 9803, 0xFFFFFFFF, OS.TRUE)
    add_instrument_sample(harp-3, 0x0, 700000, 66 * 1879, 0x7F, 0x0, 0x0, 0x7F, 96, 127,  98, 0x0, 0x3F, 0x7E, OS.TRUE, 5100, 10312, 0xFFFFFFFF, OS.TRUE)
    add_instrument(Harp, 0x7E, 0x3F, 0x05, 1200, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0)

    move_instrument_bank_map()

    // @ Description
    // Loads the instrument bank map from ROM to RAM so that instrument data is properly processed at startup
    scope dmaCopy_moved_bank_map_: {
        OS.patch_start(0x20148, 0x8001F548)
        jal     dmaCopy_moved_bank_map_
        nop
        OS.patch_end()

        OS.save_registers()                             // save registers

        // reload bank table from ROM
        li      a0, moved_inst_bank_map_origin          // load rom address
        li      a1, moved_inst_bank_map                 // load ram address
        li      a2, 0x10 + (instrument_count * 4)       // load length of bank table
        jal     0x80002CA0                              // dmaCopy
        nop

        OS.restore_registers()                          // restore registers

        _end:
        j       0x8001E91C                              // original line 1
        or      a2, s0, r0                              // original line 2
    }

    print "========================================================================== \n"

    // @ Description
    // Adds a priority override for the given instrument/bgm combination.
    // Also creates a priority override array if it doesn't already exist.
    // bgm - id of bgm
    // instrument - id of instrument
    // priority - priority value to use for this track
    macro add_priority_override(bgm, instrument, priority) {
        evaluate bgm({bgm})

        // create an override array for this bgm if it doesn't exist
        if !{defined priority_override_{bgm}} {
            global define priority_override_{bgm}()

            priority_override_array_{bgm}:
            constant priority_override_array_{bgm}_origin(origin())
            fill instrument_count
            OS.align(16)

            pushvar origin, base
            origin priority_override_table_origin + ({bgm} * 0x4)
            dw  priority_override_array_{bgm}
            pullvar base, origin
        }

        // add the override value for this instrument
        pushvar origin, base
        origin priority_override_array_{bgm}_origin + {instrument}
        db  {priority}
        pullvar base, origin
    }

    // @ Description
    // Adds a bend range override for the given instrument/bgm combination.
    // Also creates a bend range override array if it doesn't already exist.
    // bgm - id of bgm
    // instrument - id of instrument
    // bend_range - bend_range value to use for this track
    macro add_bend_range_override(bgm, instrument, bend_range) {
        evaluate bgm({bgm})

        // create an override array for this bgm if it doesn't exist
        if !{defined bend_range_override_{bgm}} {
            global define bend_range_override_{bgm}()

            bend_range_override_array_{bgm}:
            constant bend_range_override_array_{bgm}_origin(origin())
            fill instrument_count * 2
            OS.align(16)

            pushvar origin, base
            origin bend_range_override_table_origin + ({bgm} * 0x4)
            dw  bend_range_override_array_{bgm}
            pullvar base, origin
        }

        // add the override value for this instrument
        pushvar origin, base
        origin bend_range_override_array_{bgm}_origin + ({instrument} * 2)
        dh  {bend_range}
        pullvar base, origin
    }

    // @ Description
    // Adds a master volume override for the given bgm.
    // bgm - id of bgm
    // volume - master volume value to use for this track
    macro add_master_volume_override(bgm, volume) {
        evaluate bgm({bgm})
        // add the override value for this bgm
        pushvar origin, base
        origin master_volume_override_table_origin + {bgm}
        if {volume} > 127 {
        print "WARNING: Max value for master volume override is 127 \n"
        db  127
        } else {
        db  {volume}
        }
        pullvar base, origin
    }

    // @ Description
    // Alternate version of subroutine 0x8002E2AC which seems to load instrument parameters.
    // Checks to see if the current BGM gives an alternate priority or bend range value for the given instrument.
    // a0 - unknown (original)
    // a1 - address of instrument parameters
    // a2 - unknown (original)
    scope override_instrument_parameters_: {
        OS.patch_start(0x2C820, 0x8002BC20)
        jal     override_instrument_parameters_
        OS.patch_end()

        lw      t6, 0x0068(a0)              // ~
        sll     v0, a2, 0x2                 // ~
        subu    v0, v0, a2                  // ~
        sll     v0, v0, 0x3                 // ~
        addu    t7, t6, v0                  // ~
        sw      a1, 0x0000(t7)              // ~
        lw      t9, 0x0068(a0)              // undocumented original logic

        _priority:
        li      t0, BGM.safe_id             // t0 = address of safe bgm_id
        lw      t0, 0x0000(t0)              // t0 = current bgm_id
        li      t1, priority_override_table // t1 = priority_override_table
        sll     t0, t0, 0x2                 // t0 = offset (bgm * 4)
        addu    t1, t1, t0                  // t1 = priority_override_table + offset
        lw      t1, 0x0000(t1)              // t1 = address of override array for current bgm
        beql    t1, r0, _bend_range         // skip if array pointer = NULL...
        lbu     t8, 0x0002(a1)              // ...and load original priority to t8

        // if there is a priority override array for the current bgm, check for an override value for the current instrument
        // fp/s8 is presumed to always contain the instrument id at this point, this is almost certainly safe because it's used for
        // a check for invalid instrument ids right before the function call we replace
        addu    t1, t1, s8                  // t1 = array pointer + offset(instrument id)
        lbu     t8, 0x0000(t1)              // t8 = priority override value
        beql    t8, r0, _bend_range         // if priority override = 0...
        lbu     t8, 0x0002(a1)              // ...load original priority to t8 instead

        _bend_range:
        // t0 = offset (bgm * 4)
        li      t1, bend_range_override_table // t1 = bend_range_override_table
        addu    t1, t1, t0                  // t1 = bend_range_override_table + offset
        lw      t1, 0x0000(t1)              // t1 = address of override array for current bgm
        beql    t1, r0, _continue           // skip if array pointer = NULL...
        lh      t1, 0x000C(a1)              // ...and load original bend range to t1 instead

        // if there is a bend range override array for the current bgm, check for an override value for the current instrument
        // fp/s8 is presumed to always contain the instrument id at this point, this is almost certainly safe because it's used for
        // a check for invalid instrument ids right before the function call we replace
        sll     t2, s8, 0x1                 // t2 = offset (instrument id * 2)
        addu    t1, t1, t2                  // t1 = array pointer + offset
        lh      t1, 0x0000(t1)              // t1 = bend range override value
        beql    t1, r0, _continue           // if bend rage override = 0...
        lh      t1, 0x000C(a1)              // ...load original bend range to t1 instead

        _continue:
        addu    t0, t9, v0                  // ~
        sb      t8, 0x0008(t0)              // store priority
        lw      t2, 0x0068(a0)              // ~
        addu    t3, t2, v0                  // ~
        sh      t1, 0x0004(t3)              // store bend range
        lw      t5, 0x0068(a0)              // ~
        lbu     t4, 0x0000(a1)              // ~
        addu    t6, t5, v0                  // ~
        jr      ra                          // ~
        sb      t4, 0x0011(t6)              // undocumented original logic
    }

    // @ Description
    // Overrides the vanilla master volume with a custom one if the track has it
    scope override_master_volume_: {
        OS.patch_start(0x302C0, 0x8002F6C0)
        j       override_master_volume_
        lbu     t7, 0x0078(a0)              // t7 = master volume (original line 2)
        _return:
        OS.patch_end()

        li      t0, BGM.safe_id             // t0 = address of safe bgm_id
        lw      t0, 0x0000(t0)              // t0 = current bgm_id
        li      t1, master_volume_override_table // t1 = master_volume_override_table
        addu    t1, t1, t0                  // t1 = master_volume_override_table + bgm_id
        lbu     t1, 0x0000(t1)              // t1 = master volume override for current bgm
        bnezl   t1, _end                    // if an override value is present...
        or      t7, t1, r0                  // t7 = new master volume value

        _end:
        j       _return
        lh      t6, 0x003A(a0)              // load other volume parameter (original line 2)
    }

    // @ Description
    // Can enable or disable MIDI channels. Bitflag located at 0x8003D31C
    // a0 = new channel bitflags to use (0x0000FFFF)
    scope toggle_channels: {
        lui     v0, 0x8004
        jr      ra
        sh      a0, 0xD31C(v0)              // v0 = current bitflags
    }

    OS.align(16)
    priority_override_table:
    constant priority_override_table_origin(origin())
    fill midi_count * 0x4
    OS.align(16)

    OS.align(16)
    bend_range_override_table:
    constant bend_range_override_table_origin(origin())
    fill midi_count * 0x4
    OS.align(16)

    OS.align(16)
    master_volume_override_table:
    constant master_volume_override_table_origin(origin())
    fill midi_count
    OS.align(16)

    // ADD PRIORITY OVERRIDES HERE
    // This can be used when MIDI cc16 fails to provide satisfactory results.
    // It should only be used in advanced cases and be used with care, as giving instruments extreme priority can cause FGMs to cut out or play back wrong.
    // bgm - id of bgm
    // instrument - id of instrument
    // priority - priority value to use for this track
    add_priority_override({MIDI.id.FOREST_INTERLUDE}, 7, 0x7F)
    add_priority_override({MIDI.id.FOREST_INTERLUDE}, 15, 0x7F)
    add_priority_override({MIDI.id.FOREST_INTERLUDE}, 28, 0x7F)
    add_priority_override({MIDI.id.FOREST_INTERLUDE}, 40, 0x7F)
    add_priority_override({MIDI.id.FOREST_INTERLUDE}, 55, 0x7F)

    add_priority_override({MIDI.id.DK_RAP}, 63, 0x7F)

    add_priority_override({MIDI.id.ROLL}, 64, 0x7F)

    add_priority_override({MIDI.id.YOSHI_TALE}, 65, 0x7F)

    add_priority_override({MIDI.id.TABUU}, 58, 0x7F)

    add_priority_override({MIDI.id.DISCOVERYFALLS}, 28, 0x7F)
    add_priority_override({MIDI.id.DISCOVERYFALLS}, 44, 0x7F)
    add_priority_override({MIDI.id.DISCOVERYFALLS}, 7, 0x7F)
    add_priority_override({MIDI.id.DISCOVERYFALLS}, 67, 0x7F)

    add_priority_override({MIDI.id.WIZPIG}, 58, 0x7F)
    add_priority_override({MIDI.id.WIZPIG}, 44, 0x7F)

    add_priority_override({MIDI.id.TOADS_TURNPIKE}, 2, 0x7F)
    add_priority_override({MIDI.id.TOADS_TURNPIKE}, 7, 0x7F)
    add_priority_override({MIDI.id.TOADS_TURNPIKE}, 44, 0x7F)

    add_priority_override({MIDI.id.FIRE_EMBLEM}, 34, 0x7F)

    add_priority_override({MIDI.id.ROCKSOLID}, 7, 0x7F)

    add_priority_override({MIDI.id.BIG_BRIDGE}, 34, 0x7F)

    add_priority_override({MIDI.id.TARGET_TEST}, 56, 0x7F)

    add_priority_override({MIDI.id.SS_AQUA}, 56, 0x7F)
    add_priority_override({MIDI.id.SS_AQUA}, 51, 0x7F)

    add_priority_override({MIDI.id.ELADARD}, 54, 0x7F)
    add_priority_override({MIDI.id.ELADARD}, 55, 0x7F)

    add_priority_override({MIDI.id.DRAKE_LAKE}, 1, 0x7F)

    add_priority_override({MIDI.id.BATTLE_AMONG_FRIENDS}, 28, 0x7F)

    add_priority_override({MIDI.id.MURASAKI}, 55, 0x7F)

    add_priority_override({MIDI.id.SKYWORLD}, 1, 0x7F)

    // ADD BEND RANGE OVERRIDES HERE
    // This can be used when default bend ranges fail to provide satisfactory results.
    // bgm - id of bgm
    // instrument - id of instrument
    // bend_range - bend_range value to use for this track

    add_bend_range_override({MIDI.id.YOSHI_TALE}, 2, 100) // sets vanilla organ to have a pitch bend of +/- 1 semitone instead of 0.1

    add_bend_range_override({MIDI.id.SLIDER}, 29, 1200)

    add_bend_range_override({MIDI.id.WILDLANDS}, 1, 200)

    add_bend_range_override({MIDI.id.OPUS_13}, 47, 100)

    add_bend_range_override({MIDI.id.FUTUREFRENZY}, 24, 1200)

    add_bend_range_override({MIDI.id.MUTE_CITY}, 41, 1200)

    add_bend_range_override({MIDI.id.SILVERSURFER}, 19, 1200)
    add_bend_range_override({MIDI.id.SILVERSURFER}, 20, 1200)

    add_bend_range_override({MIDI.id.TOWEROFHEAVEN}, 19, 1200)

    add_bend_range_override({MIDI.id.LIPS_THEME}, 19, 1200)
    add_bend_range_override({MIDI.id.LIPS_THEME}, 14, 1200)

    add_bend_range_override({MIDI.id.WALUIGI_PINBALL}, 12, 1200)
    add_bend_range_override({MIDI.id.WALUIGI_PINBALL}, 29, 1200)

    add_bend_range_override({MIDI.id.SONIC_R}, 13, 1200)

    add_bend_range_override({MIDI.id.RACEWAYS}, 11, 1200)

    add_bend_range_override({MIDI.id.BOWSERBOSS}, 5, 1200)

    add_bend_range_override({MIDI.id.BUBBLEGUM_KK}, 6, 1200)

    // ADD MASTER VOLUME OVERRIDES HERE
    // This can be used to adjust the overall volume of a track in-game.
    // bgm - id of bgm
    // volume - master volume to use for this track, 0-127, default is 100
    add_master_volume_override({MIDI.id.CORNERIA}, 93)
    add_master_volume_override({MIDI.id.DR_MARIO}, 90)
    add_master_volume_override({MIDI.id.GAME_CORNER}, 90)
    add_master_volume_override({MIDI.id.SMASHVILLE}, 110)
    add_master_volume_override({MIDI.id.STONECARVING_CITY}, 112)
    add_master_volume_override({MIDI.id.GODDESSBALLAD}, 115)
    add_master_volume_override({MIDI.id.TOWEROFHEAVEN}, 82)
    add_master_volume_override({MIDI.id.FOD}, 90)
    add_master_volume_override({MIDI.id.MEMENTOS}, 110)
    add_master_volume_override({MIDI.id.SPIRAL_MOUNTAIN}, 87)
    add_master_volume_override({MIDI.id.N64}, 104)
    add_master_volume_override({MIDI.id.BATTLEFIELD}, 95)
    add_master_volume_override({MIDI.id.MADMONSTER}, 90)
    add_master_volume_override({MIDI.id.GREEN_GREENS}, 95)
    add_master_volume_override({MIDI.id.POKEMON_STADIUM}, 83)
    add_master_volume_override({MIDI.id.SMB3OVERWORLD}, 90)
    add_master_volume_override({MIDI.id.DELFINO}, 110)
    add_master_volume_override({MIDI.id.ONETT}, 105)
    add_master_volume_override({MIDI.id.ZEBES_LANDING}, 95)
    add_master_volume_override({MIDI.id.EASTON_KINGDOM}, 83)
    add_master_volume_override({MIDI.id.WING_CAP}, 85)
    add_master_volume_override({MIDI.id.RBY_GYMLEADER}, 80)
    add_master_volume_override({MIDI.id.KITCHEN_ISLAND}, 90)
    add_master_volume_override({MIDI.id.DK_RAP}, 100)
    add_master_volume_override({MIDI.id.MACHRIDER}, 95)
    add_master_volume_override({MIDI.id.POKEFLOATS}, 82)
    add_master_volume_override({MIDI.id.GERUDO_VALLEY}, 90)
    add_master_volume_override({MIDI.id.POP_STAR}, 120)
    add_master_volume_override({MIDI.id.STAR_WOLF}, 83)
    add_master_volume_override({MIDI.id.POKEMON_CHAMPION}, 85)
    add_master_volume_override({MIDI.id.POLLYANNA}, 90)
    add_master_volume_override({MIDI.id.SAMBA_DE_COMBO}, 95)
    add_master_volume_override({MIDI.id.UNFOUNDED_REVENGE}, 90)
    add_master_volume_override({MIDI.id.KENGJR}, 86)
    add_master_volume_override({MIDI.id.BEIN_FRIENDS}, 90)
    add_master_volume_override({MIDI.id.KK_RIDER}, 95)
    add_master_volume_override({MIDI.id.SNAKEY_CHANTEY}, 95)
    add_master_volume_override({MIDI.id.TAZMILY}, 115)
    add_master_volume_override({MIDI.id.YOSHI_GOLF}, 88)
    add_master_volume_override({MIDI.id.FINALTEMPLE}, 88)
    add_master_volume_override({MIDI.id.OBSTACLE}, 90)
    add_master_volume_override({MIDI.id.EVEN_DRIER_GUYS}, 87)
    add_master_volume_override({MIDI.id.PEACH_CASTLE}, 105)
    add_master_volume_override({MIDI.id.BANJO_MAIN}, 95)
    add_master_volume_override({MIDI.id.GANGPLANK}, 108)
    add_master_volume_override({MIDI.id.FD_BRAWL}, 90)
    add_master_volume_override({MIDI.id.ARIA_OF_THE_SOUL}, 118)
    add_master_volume_override({MIDI.id.KING_OF_THE_KOOPAS}, 90)
    add_master_volume_override({MIDI.id.SKERRIES}, 95)
    add_master_volume_override({MIDI.id.BEWARE_THE_FORESTS_MUSHROOMS}, 95)
    add_master_volume_override({MIDI.id.TARGET_TEST}, 95)
    add_master_volume_override({MIDI.id.VENOM}, 80)
    add_master_volume_override({MIDI.id.BK_FINALBATTLE}, 107)
    add_master_volume_override({MIDI.id.OLE}, 92)
    add_master_volume_override({MIDI.id.WINDY}, 93)
    add_master_volume_override({MIDI.id.DATADYNE}, 90)
    add_master_volume_override({MIDI.id.INVESTIGATION_X}, 85)
    add_master_volume_override({MIDI.id.NSMB}, 105)
    add_master_volume_override({MIDI.id.JUNGLEJAPES}, 90)
    add_master_volume_override({MIDI.id.TOADS_TURNPIKE}, 92)
    add_master_volume_override({MIDI.id.GB_MEDLEY}, 90)
    add_master_volume_override({MIDI.id.FLOWER_GARDEN}, 110)
    add_master_volume_override({MIDI.id.WILDLANDS}, 125)
    add_master_volume_override({MIDI.id.VS_MARX}, 115)
    add_master_volume_override({MIDI.id.SS_AQUA}, 86)
    add_master_volume_override({MIDI.id.METAL_BATTLE}, 110)
    add_master_volume_override({MIDI.id.KANTO_WILD_BATTLE}, 85)
    add_master_volume_override({MIDI.id.PIRATELAND}, 90)
    add_master_volume_override({MIDI.id.FLYINGBATTERY}, 90)
    add_master_volume_override({MIDI.id.CASINO_NIGHT}, 90)
    add_master_volume_override({MIDI.id.SONIC2_SPECIAL}, 90)
    add_master_volume_override({MIDI.id.SONICCD_SPECIAL}, 95)
    add_master_volume_override({MIDI.id.GIANTWING}, 90)
    add_master_volume_override({MIDI.id.EMERALDHILL}, 90)
    add_master_volume_override({MIDI.id.LIVE_AND_LEARN}, 83)
    add_master_volume_override({MIDI.id.STARDUST}, 95)
    add_master_volume_override({MIDI.id.GREEN_HILL_ZONE}, 89)
    add_master_volume_override({MIDI.id.CHEMICAL_PLANT}, 87)
    add_master_volume_override({MIDI.id.BABY_BOWSER}, 85)
    add_master_volume_override({MIDI.id.METALLIC_MADNESS}, 85)
    add_master_volume_override({MIDI.id.EVERYTHING}, 80)
    add_master_volume_override({MIDI.id.RACEWAYS}, 90)
    add_master_volume_override({MIDI.id.KIRBY_64_BOSS}, 90)
    add_master_volume_override({MIDI.id.SMB2_MEDLEY}, 90)
    add_master_volume_override({MIDI.id.SMW_TITLECREDITS}, 90)
    add_master_volume_override({MIDI.id.DEDEDE}, 80)
    add_master_volume_override({MIDI.id.IRON_BLUE_INTENTION}, 90)
    add_master_volume_override({MIDI.id.DRACULAS_TEARS}, 80)
    add_master_volume_override({MIDI.id.WARIOWARE}, 110)
    add_master_volume_override({MIDI.id.FROZEN_HILLSIDE}, 95)
    add_master_volume_override({MIDI.id.SOCCER_MENU}, 90)
    add_master_volume_override({MIDI.id.TROUBLE_MAKER}, 90)
    add_master_volume_override({MIDI.id.WL2_PERFECT}, 85)
    add_master_volume_override({MIDI.id.CONTROL}, 90)
    add_master_volume_override({MIDI.id.OEDO_EDO}, 95)
    add_master_volume_override({MIDI.id.MAJORA_MIDBOSS}, 92)
    add_master_volume_override({MIDI.id.SMW_ATHLETIC}, 85)
    add_master_volume_override({MIDI.id.BRAWL_OOT}, 110)
    add_master_volume_override({MIDI.id.BOSS_E}, 80)
    add_master_volume_override({MIDI.id.MARINE_FORTRESS}, 75)
    add_master_volume_override({MIDI.id.TWILIGHT_CITY}, 95)
    add_master_volume_override({MIDI.id.SOUTHERNISLAND}, 90)
    add_master_volume_override({MIDI.id.QUEST64_BATTLE}, 83)
    add_master_volume_override({MIDI.id.DECISIVE}, 90)
    add_master_volume_override({MIDI.id.HILLTOPCHASE}, 110)
    add_master_volume_override({MIDI.id.FF4BOSS}, 89)
    add_master_volume_override({MIDI.id.GRIMREAPERSCAVERN}, 90)
    add_master_volume_override({MIDI.id.SHANTAEMEDLEY}, 91)
    add_master_volume_override({MIDI.id.BURNINGTOWN}, 87)
    add_master_volume_override({MIDI.id.SHANTAEBOSS}, 90)
    add_master_volume_override({MIDI.id.FORTRESS_BOSS}, 90)
    add_master_volume_override({MIDI.id.HORROR_LAND}, 94)
    add_master_volume_override({MIDI.id.DARKWORLD}, 88)
    add_master_volume_override({MIDI.id.FRAPPE_SNOWLAND}, 92)
    add_master_volume_override({MIDI.id.SMRPG_BATTLE}, 85)
    add_master_volume_override({MIDI.id.TRAVELING}, 90)
    add_master_volume_override({MIDI.id.CHILL}, 112)
    add_master_volume_override({MIDI.id.ROLL}, 90)
    add_master_volume_override({MIDI.id.STICKERBRUSH_SYMPHONY}, 93)
    add_master_volume_override({MIDI.id.DKCTITLE}, 93)
    add_master_volume_override({MIDI.id.PLANTATION}, 87)
    add_master_volume_override({MIDI.id.7AM}, 110)
    add_master_volume_override({MIDI.id.QUEQUE}, 87)
    add_master_volume_override({MIDI.id.VSRIDLEY}, 95)
    add_master_volume_override({MIDI.id.FLANDRES_THEME}, 90)
    add_master_volume_override({MIDI.id.THE_ALOOF_SOLDIER}, 90)
    add_master_volume_override({MIDI.id.WENDYS_HOUSE}, 90)
    add_master_volume_override({MIDI.id.DANGEROUS_FOE}, 90)
    add_master_volume_override({MIDI.id.PIKA_CUP}, 85)
    add_master_volume_override({MIDI.id.WIZPIG}, 90)
    add_master_volume_override({MIDI.id.BATTLE_C1}, 80)
    add_master_volume_override({MIDI.id.CREDITS_BRAWL}, 90)
    add_master_volume_override({MIDI.id.BATTLE_GOLD_SILVER}, 90)
    add_master_volume_override({MIDI.id.GOLDENROD_CITY}, 90)
    add_master_volume_override({MIDI.id.GANONMEDLEY}, 80)
    add_master_volume_override({MIDI.id.FUGUE}, 85)
    add_master_volume_override({MIDI.id.SILVER_MOUNTAIN}, 85)
    add_master_volume_override({MIDI.id.PORKY}, 80)
    add_master_volume_override({MIDI.id.NSANITYBEACH}, 93)
    add_master_volume_override({MIDI.id.DISCOVERYFALLS}, 90)
    add_master_volume_override({MIDI.id.DK_MEDLEY}, 90)
    add_master_volume_override({MIDI.id.BIG_BRIDGE}, 93)
    add_master_volume_override({MIDI.id.HOGWILD}, 88)
    add_master_volume_override({MIDI.id.MARATHON}, 91)
    add_master_volume_override({MIDI.id.FORGONE}, 95)
    add_master_volume_override({MIDI.id.ELADARD}, 90)
    add_master_volume_override({MIDI.id.FZEROX_MEDLEY}, 115)
    add_master_volume_override({MIDI.id.BUBBLEGUM_KK}, 93)
    add_master_volume_override({MIDI.id.MADMAZEMAUL}, 80)
    add_master_volume_override({MIDI.id.TITANIA}, 93)
    add_master_volume_override({MIDI.id.SHEVAT}, 115)
    add_master_volume_override({MIDI.id.CORTEX}, 115)
    add_master_volume_override({MIDI.id.WILY_FIELD}, 111)
    add_master_volume_override({MIDI.id.SMS_BOSS}, 87)
    add_master_volume_override({MIDI.id.VS_DSAMUS}, 85)
    add_master_volume_override({MIDI.id.STRIKE_THE_EARTH}, 80)
    add_master_volume_override({MIDI.id.VAMPIREKILLER}, 88)
    add_master_volume_override({MIDI.id.REDIAL}, 95)
    add_master_volume_override({MIDI.id.AGAVE}, 95)
    add_master_volume_override({MIDI.id.RAIDBLUE}, 111)
    add_master_volume_override({MIDI.id.RISKNECK}, 111)
    add_master_volume_override({MIDI.id.SHERBETLAND}, 86)
    add_master_volume_override({MIDI.id.DEATH_MOUNTAIN}, 95)
    add_master_volume_override({MIDI.id.BATTLE_AMONG_FRIENDS}, 95)
    add_master_volume_override({MIDI.id.NBA_JAM}, 106)
    add_master_volume_override({MIDI.id.MURASAKI}, 115)
    add_master_volume_override({MIDI.id.FE6_MEDLEY}, 111)
    add_master_volume_override({MIDI.id.FUTUREFRENZY}, 107)
    add_master_volume_override({MIDI.id.LANKY_VICTORY}, 127)
    add_master_volume_override({MIDI.id.LIPS_THEME}, 95)
    add_master_volume_override({MIDI.id.CRASHBASH_LOADING}, 95)
    add_master_volume_override({MIDI.id.TREASURE_TROVE_COVE}, 95)
    add_master_volume_override({MIDI.id.GREENGARDEN}, 105)
    add_master_volume_override({MIDI.id.BLUE_RESORT}, 127)
    add_master_volume_override({MIDI.id.DRMARIO_VICTORY}, 127)
    add_master_volume_override({MIDI.id.BOWSERBOSS}, 88)
    add_master_volume_override({MIDI.id.LOST}, 93)
}

} // __MIDI__
