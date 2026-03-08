// TagTeam.asm
if !{defined __TAG_TEAM__} {
define __TAG_TEAM__()
print "included TagTeam.asm\n"

// @ Description
// This file implements Tag Team mode in VS

scope TagTeam {

    // @ Description
    // The stocks setting as set on CSS
    stocks:
    dw 3

    // @ Description
    // The teams setting as set on CSS
    teams:
    dw OS.FALSE

    // @ Description
    // The stockmode_table for Tag Team
    stockmode_table:
    dw 0, 0, 0, 0

    // @ Description
    // The stock_count_table values for Tag Team
    stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // The previous_stock_count_table values for Tag Team
    previous_stock_count_table:
    db -1, -1, -1, -1

    // @ Description
    // Holds the selections for char_id, costume_id and shade per slot per port
    // 6 slots per port
    character_queues:
    // char_id, costume_id, shade, char_id if Random / is_classic flag if Sonic
    // p1
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    // p2
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    // p3
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    // p4
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0
    db Character.id.NONE, 0, 0, 0

    // @ Description
    // Current slot being selected, for each port
    current_slot:
    db 0, 0, 0, 0

    // @ Description
    // Caches stock icon texture and palette info so we don't have to load all chars or the stock icons file
    // Texture first (0x50), then palette (0x28), then image struct with pointer to texture (0x10)
    // Then, annoyingly, we have to get 5 palettes in order to handle toggling teams/ffa:
    // - Team palettes: Red, Blue, Green, Yellow
    // - Default palettes: 0, 1, 2, 3 (select the first available costume when toggling to ffa)
    // So size of each slot is 0x1C8
    constant ICON_TEXTURE_SIZE(0x80)
    constant ICON_PALETTE_SIZE(0x28)
    constant ICON_IMAGE_CHUNK_SIZE(0x10)
    constant ICON_PALETTE_OFFSET(ICON_TEXTURE_SIZE)
    constant ICON_IMAGE_CHUNK_OFFSET(ICON_TEXTURE_SIZE + ICON_PALETTE_SIZE)
    constant ICON_DEFAULT_PALETTES_OFFSET(ICON_IMAGE_CHUNK_OFFSET + ICON_IMAGE_CHUNK_SIZE)
    constant ICON_CACHE_SLOT_SIZE((ICON_TEXTURE_SIZE + ICON_PALETTE_SIZE + ICON_IMAGE_CHUNK_SIZE + (ICON_PALETTE_SIZE * 8)))
    constant ICON_CACHE_PORT_SIZE(ICON_CACHE_SLOT_SIZE * 6)
    OS.align(0x10)
    icon_cache:
    // slots 1 - 6, p1 - p4
    fill ICON_CACHE_PORT_SIZE * 4

    // @ Description
    // Holds number of times a stock has been stolen during the match
    stolen_count:
    db 0, 0, 0, 0

    // @ Description
    // Holds queue slot address of the stock that has been stolen
    stolen_stocks:
    dw 0, 0, 0, 0

    // @ Description
    // Holds address of the stock icon image chunk and palette that has been stolen
    stolen_icons:
    // image chunk, palette
    dw 0, 0 // p1
    dw 0, 0 // p2
    dw 0, 0 // p3
    dw 0, 0 // p4

    // @ Description
    // Maps files that need to be preloaded to characters.
    // We need to preload files that are either make the character too big, or
    // that can persist after the player is destroyed - namely projectiles and items
    preload_map:
    constant PRELOAD_MAP_ORIGIN(origin())
    fill Character.NUM_CHARACTERS * 4

    // @ Description
    // Adds a file to the preload map for a character
    // @ Arguments
    // a0 - char_id
    // a1 - file_id
    macro add_preload(char_id, file_id) {
        evaluate c({char_id})
        if !{defined preload_{c}_0} {
            global variable preload_{c}_count(0)
        }
        evaluate f(preload_{c}_count)
        global evaluate preload_{c}_{f}({file_id})
        global variable preload_{c}_count(preload_{c}_count + 1)
    }

    // @ Description
    // Creates preload arrays
    macro process_preloads() {
        define char_id(0)
        while {char_id} < Character.NUM_CHARACTERS {
            if {defined preload_{char_id}_0} {
                preload_{char_id}:
                define n(0)
                while {n} < preload_{char_id}_count {
                    dh {preload_{char_id}_{n}}
                    evaluate n({n}+1)
                }
                dh 0
                OS.align(4)

                pushvar base, origin
                origin PRELOAD_MAP_ORIGIN + ({char_id} * 4)
                dw preload_{char_id}
                pullvar origin, base
            }

            evaluate char_id({char_id}+1)
        }
    }

    // Kirby is too big for the custom heap with the custom hats files included, so always preload
    add_preload(Character.id.KIRBY, File.KIRBY_CUSTOM_HATS)
    add_preload(Character.id.KIRBY, File.KIRBY_CUSTOM_HATS_2)
    add_preload(Character.id.JKIRBY, File.KIRBY_CUSTOM_HATS)
    add_preload(Character.id.JKIRBY, File.KIRBY_CUSTOM_HATS_2)
    // These can persist after the character is destroyed, so preload them so they don't get destroyed and cause crashes
    add_preload(Character.id.KIRBY, 0xE6) // do this so all vanilla Kirby powers work
    add_preload(Character.id.JKIRBY, 0xE6) // do this so all vanilla Kirby powers work
    add_preload(Character.id.KIRBY, File.REMIX_1P_KIRBY) // do this so all remix Kirby powers work
    add_preload(Character.id.JKIRBY, File.REMIX_1P_KIRBY) // do this so all remix Kirby powers work
    add_preload(Character.id.MARIO, 0xCC) // Mario Fireball Hitbox
    add_preload(Character.id.METAL, 0xCC) // Mario Fireball Hitbox
    add_preload(Character.id.JMARIO, File.JMARIO_PROJECTILE_HITBOX)
    add_preload(Character.id.FOX, 0xD2) // Fox Laser Hitbox
    add_preload(Character.id.JFOX, File.JFOX_PROJECTILE) // Fox Laser Hitbox
    add_preload(Character.id.FOX, 0x13B) // Fox Blaster
    add_preload(Character.id.JFOX, 0x13B) // Fox Blaster
    add_preload(Character.id.KIRBY, 0x13B) // Fox Blaster
    add_preload(Character.id.JKIRBY, 0x13B) // Fox Blaster
    add_preload(Character.id.JFOX, 0x13B) // Fox Blaster
    add_preload(Character.id.SAMUS, 0xDA) // Samus Charge Shot Hitbox
    add_preload(Character.id.JSAMUS, 0xDA) // Samus Charge Shot Hitbox
    add_preload(Character.id.ESAMUS, 0xDA) // Samus Charge Shot Hitbox
    add_preload(Character.id.SAMUS, 0x15D) // Samus Grapple
    add_preload(Character.id.JSAMUS, 0x15D) // Samus Grapple
    add_preload(Character.id.ESAMUS, 0x15D) // Samus Grapple
    add_preload(Character.id.LUIGI, 0xDE) // Luigi Fireball Hitbox
    add_preload(Character.id.MLUIGI, 0xDE) // Luigi Fireball Hitbox
    add_preload(Character.id.JLUIGI, File.JLUIGI_PROJECTILE_HITBOX)
    add_preload(Character.id.LINK, 0xE1) // Link Main File (for bomb)
    add_preload(Character.id.LINK, 0xE2) // Link Boomerang Hitbox
    add_preload(Character.id.JLINK, File.JLINK_MAIN) // for bomb
    add_preload(Character.id.JLINK, 0xE2) // Link Boomerang Hitbox
    add_preload(Character.id.ELINK, File.ELINK_MAIN) // for bomb
    add_preload(Character.id.ELINK, 0xE2) // Link Boomerang Hitbox
    add_preload(Character.id.YOSHI, 0x153) // Yoshi Laid Egg
    add_preload(Character.id.JYOSHI, 0x153) // Yoshi Laid Egg
    add_preload(Character.id.BOWSER, 0x153) // Yoshi Laid Egg (Need this so Z-Cancel Egg doesn't crash)
    add_preload(Character.id.GBOWSER, 0x153) // Yoshi Laid Egg (Need this so Z-Cancel Egg doesn't crash)
    add_preload(Character.id.NBOWSER, 0x153) // Yoshi Laid Egg (Need this so Z-Cancel Egg doesn't crash)
    add_preload(Character.id.PIKACHU, 0xF4) // Pikachu Projectile
    add_preload(Character.id.JPIKA, File.JPIKA_PROJECTILE)
    add_preload(Character.id.EPIKA, 0xF4) // Pikachu Projectile
    add_preload(Character.id.NESS, 0xF0) // Ness PK Fire
    add_preload(Character.id.NESS, 0x14F) // for Ness PK Thunder when reflected
    add_preload(Character.id.JNESS, File.JNESS_PKFIRE)
    add_preload(Character.id.JNESS, 0x14F) // for Ness PK Thunder when reflected
    add_preload(Character.id.LUCAS, File.LUCAS_PKFIRE)
    add_preload(Character.id.LUCAS, File.LUCAS_CHARACTER) // for Lucas PK Thunder when reflected
    add_preload(Character.id.YLINK, File.YLINK_BOOMERANG_HITBOX)
    add_preload(Character.id.YLINK, File.YLINK_MAIN) // for Bombchu
    add_preload(Character.id.DRM, File.DRM_PROJECTILE_DATA)
    add_preload(Character.id.DRL, File.DRM_PROJECTILE_DATA)
    add_preload(Character.id.DSAMUS, File.DSAMUS_SECONDARY) // charge shot hitbox
    add_preload(Character.id.PIANO, File.PIANO_PROJECTILE_HITBOX)
    add_preload(Character.id.WOLF, File.WOLF_PROJECTILE_HITBOX)
    add_preload(Character.id.CONKER, File.CONKER_GRENADE_PROJECTILE_HITBOX)
    add_preload(Character.id.CONKER, File.CONKER_NUT_PROJECTILE_HITBOX)
    add_preload(Character.id.MTWO, File.MTWO_SBALL_PROJECTILE_HITBOX)
    add_preload(Character.id.SHEIK, File.SHEIK_PROJECTILE_HITBOX)
    add_preload(Character.id.MARINA, File.MARINA_GEM_HITBOX)
    add_preload(Character.id.DEDEDE, File.WADDLE_DEE_INFO)
    add_preload(Character.id.GOEMON, File.GOEMON_RYO_HITBOX)
    add_preload(Character.id.GOEMON, File.GOEMON_CLOUD_INFO)
    add_preload(Character.id.BANJO, File.KAZOOIE_EGG_INFO)
    add_preload(Character.id.SLIPPY, File.SLIPPY_LASER_HITBOX)
    add_preload(Character.id.PEPPY, File.PEPPY_LASER_HITBOX)
    add_preload(Character.id.PEPPY, File.PEPPY_GRENADE_HITBOX)
    add_preload(Character.id.DRAGONKING, 0x15B) // Pikachu FSMash GFX & Dragon Ball GFX
    add_preload(Character.id.PIKACHU, 0x15B) // Pikachu FSMash GFX & Dragon Ball GFX
    add_preload(Character.id.NPIKACHU, 0x15B) // Pikachu FSMash GFX & Dragon Ball GFX
    add_preload(Character.id.JPIKA, 0x15B) // Pikachu FSMash GFX & Dragon Ball GFX
    add_preload(Character.id.EPIKA, 0x15B) // Pikachu FSMash GFX & Dragon Ball GFX
    add_preload(Character.id.PEACH, File.PEACH_TURNIP_INFO)
    add_preload(Character.id.LANKY, File.LANKY_PROJECTILE_HITBOX)
    add_preload(Character.id.SONIC, File.SONIC_SPRING_HITBOX)
    add_preload(Character.id.SSONIC, File.SONIC_SPRING_HITBOX)
    // These can cause crashes when characters share move set/gfx files
    // Mario-based characters
    add_preload(Character.id.MARIO, 0x0CA) // Mario move set
    add_preload(Character.id.JMARIO, 0x0CA) // Mario move set
    add_preload(Character.id.NMARIO, 0x0CA) // Mario move set
    add_preload(Character.id.METAL, 0x0CA) // Mario move set
    add_preload(Character.id.DRM, 0x0CA) // Mario move set
    add_preload(Character.id.NDRM, 0x0CA) // Mario move set
    add_preload(Character.id.WARIO, 0x0CA) // Mario move set
    add_preload(Character.id.NWARIO, 0x0CA) // Mario move set
    add_preload(Character.id.PIANO, 0x0CA) // Mario move set
    add_preload(Character.id.GOEMON, 0x0CA) // Mario move set
    add_preload(Character.id.NGOEMON, 0x0CA) // Mario move set
    add_preload(Character.id.CRASH, 0x0CA) // Mario move set
    add_preload(Character.id.NCRASH, 0x0CA) // Mario move set
    add_preload(Character.id.LANKY, 0x0CA) // Mario move set
    // DK-based characters
    add_preload(Character.id.DK, 0x0D4) // DK move set
    add_preload(Character.id.JDK, 0x0D4) // DK move set
    add_preload(Character.id.NDK, 0x0D4) // DK move set
    add_preload(Character.id.GDK, 0x0D4) // DK move set
    // Fox-based characters
    add_preload(Character.id.FOX, 0x0D0) // Fox move set
    add_preload(Character.id.NFOX, 0x0D0) // Fox move set
    add_preload(Character.id.JFOX, 0x0D0) // Fox move set
    add_preload(Character.id.FALCO, 0x0D0) // Fox move set
    add_preload(Character.id.NFALCO, 0x0D0) // Fox move set
    add_preload(Character.id.WOLF, 0x0D0) // Fox move set
    add_preload(Character.id.NWOLF, 0x0D0) // Fox move set
    add_preload(Character.id.CONKER, 0x0D0) // Fox move set
    add_preload(Character.id.NCONKER, 0x0D0) // Fox move set
    add_preload(Character.id.SONIC, 0x0D0) // Fox move set
    add_preload(Character.id.NSONIC, 0x0D0) // Fox move set
    add_preload(Character.id.SSONIC, 0x0D0) // Fox move set
    add_preload(Character.id.PEPPY, 0x0D0) // Fox move set
    add_preload(Character.id.SLIPPY, 0x0D0) // Fox move set
    add_preload(Character.id.PEACH, 0x0D0) // Fox move set
    add_preload(Character.id.NPEACH, 0x0D0) // Fox move set
    add_preload(Character.id.FOX, 0x15A) // Fox Reflector GFX
    add_preload(Character.id.JFOX, 0x15A) // Fox Reflector GFX
    add_preload(Character.id.FALCO, 0x15A) // Fox Reflector GFX
    // add_preload(Character.id.NFALCO, 0x15A) // Fox Reflector GFX (not used)
    add_preload(Character.id.PEPPY, 0x15A) // Fox Reflector GFX
    // Samus-based characters
    add_preload(Character.id.SAMUS, 0x0D8) // Samus move set
    add_preload(Character.id.ESAMUS, 0x0D8) // Samus move set
    add_preload(Character.id.JSAMUS, 0x0D8) // Samus move set
    add_preload(Character.id.DSAMUS, 0x0D8) // Samus move set
    add_preload(Character.id.NDSAMUS, 0x0D8) // Samus move set
    // Luigi-based characters
    add_preload(Character.id.LUIGI, 0x0DC) // Luigi move set
    add_preload(Character.id.JLUIGI, 0x0DC) // Luigi move set
    add_preload(Character.id.NLUIGI, 0x0DC) // Luigi move set
    add_preload(Character.id.MLUIGI, 0x0DC) // Luigi move set
    add_preload(Character.id.DRL, 0x0DC) // Luigi move set
    // Link-based characters
    add_preload(Character.id.LINK, 0x0E0) // Link move set
    add_preload(Character.id.JLINK, 0x0E0) // Link move set
    add_preload(Character.id.ELINK, 0x0E0) // Link move set
    add_preload(Character.id.YLINK, 0x0E0) // Link move set
    add_preload(Character.id.NYLINK, 0x0E0) // Link move set
    // Yoshi-based characters
    add_preload(Character.id.YOSHI, 0x0F6) // Yoshi move set
    add_preload(Character.id.NYOSHI, 0x0F6) // Yoshi move set
    add_preload(Character.id.JYOSHI, 0x0F6) // Yoshi move set
    add_preload(Character.id.BOWSER, 0x0F6) // Yoshi move set
    add_preload(Character.id.NBOWSER, 0x0F6) // Yoshi move set
    add_preload(Character.id.GBOWSER, 0x0F6) // Yoshi move set
    add_preload(Character.id.MTWO, 0x0F6) // Yoshi move set
    add_preload(Character.id.NMTWO, 0x0F6) // Yoshi move set
    // Captain Falcon-based characters
    add_preload(Character.id.FALCON, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NFALCON, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.JFALCON, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.GND, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NGND, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.MARTH, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NMARTH, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.SANDBAG, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.SHEIK, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NSHEIK, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.MARINA, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NMARINA, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.DEDEDE, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NDEDEDE, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.BANJO, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.NBANJO, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.DRAGONKING, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.ROY, 0x0EB) // Captain Falcon move set
    add_preload(Character.id.FALCON, 0x14D) // Captain Falcon punch gfx
    add_preload(Character.id.JFALCON, 0x14D) // Captain Falcon punch gfx
    // add_preload(Character.id.DRAGONKING, 0x14D) // Captain Falcon punch gfx (not used)
    // add_preload(Character.id.SANDBAG, 0x14D) // Captain Falcon punch gfx (not used)
    add_preload(Character.id.FALCON, 0x15E) // Captain Falcon kick gfx
    add_preload(Character.id.JFALCON, 0x15E) // Captain Falcon kick gfx
    // add_preload(Character.id.DRAGONKING, 0x15E) // Captain Falcon kick gfx (not used)
    // add_preload(Character.id.SANDBAG, 0x15E) // Captain Falcon kick gfx (not used)
    add_preload(Character.id.GND, File.GND_PUNCH_GRAPHIC) // Ganondorf punch gfx
    // add_preload(Character.id.NGND, File.GND_PUNCH_GRAPHIC) // Ganondorf punch gfx (not used, so covered by GND)
    add_preload(Character.id.GND, File.GND_ENTRY_KICK) // Ganondorf kick gfx
    // add_preload(Character.id.NGND, File.GND_ENTRY_KICK) // Ganondorf kick gfx (not used, so covered by GND)
    // Kirby-based characters
    add_preload(Character.id.KIRBY, 0x0E4) // Kirby move set
    add_preload(Character.id.NKIRBY, 0x0E4) // Kirby move set
    add_preload(Character.id.JKIRBY, 0x0E4) // Kirby move set
    add_preload(Character.id.KIRBY, 0x15C) // Kirby USP gfx
    add_preload(Character.id.JKIRBY, 0x15C) // Kirby USP gfx
    // Pikachu-based characters
    add_preload(Character.id.PIKACHU, 0x0F2) // Pikachu move set
    add_preload(Character.id.NPIKACHU, 0x0F2) // Pikachu move set
    add_preload(Character.id.JPIKA, 0x0F2) // Pikachu move set
    add_preload(Character.id.EPIKA, 0x0F2) // Pikachu move set
    add_preload(Character.id.PIKACHU, 0x156) // Pikachu lightning
    add_preload(Character.id.JPIKA, 0x156) // Pikachu lightning
    add_preload(Character.id.EPIKA, 0x156) // Pikachu lightning
    // Jigglypuff-based characters
    add_preload(Character.id.PUFF, 0x0E8) // Jigglypuff move set
    add_preload(Character.id.NPUFF, 0x0E8) // Jigglypuff move set
    add_preload(Character.id.EPUFF, 0x0E8) // Jigglypuff move set
    add_preload(Character.id.JPUFF, 0x0E8) // Jigglypuff move set
    add_preload(Character.id.PUFF, 0x15F) // Jigglypuff sing gfx
    add_preload(Character.id.EPUFF, 0x15F) // Jigglypuff sing gfx
    add_preload(Character.id.JPUFF, 0x15F) // Jigglypuff sing gfx
    // Ness-based characters
    add_preload(Character.id.NESS, 0x0EE) // Ness move set
    add_preload(Character.id.NNESS, 0x0EE) // Ness move set
    add_preload(Character.id.JNESS, 0x0EE) // Ness move set
    add_preload(Character.id.LUCAS, 0x0EE) // Ness move set
    add_preload(Character.id.NLUCAS, 0x0EE) // Ness move set
    add_preload(Character.id.NESS, 0x160) // Ness Psy Magnet
    add_preload(Character.id.JNESS, 0x160) // Ness Psy Magnet
    add_preload(Character.id.LUCAS, 0x160) // Ness Psy Magnet
    // add_preload(Character.id.NLUCAS, 0x160) // Ness Psy Magnet (not used)

    process_preloads()

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
        OS.read_word(stocks, t0)            // t0 = Tag Team stocks
        sb      t0, 0x0000(at)              // set stocks
        li      at, 0x8013BD80              // at = stocks address
        sw      t0, 0x0000(at)              // set stocks

        li      at, Global.vs.teams         // at = teams address
        OS.read_word(teams, t0)             // t0 = Tag Team teams
        sb      t0, 0x0000(at)              // set teams
        li      at, 0x8013BDA8              // at = teams address
        sw      t0, 0x0000(at)              // set teams

        li      at, 0x8013B7C8              // at = title offsets (first is ffa, second is teams)
        lli     t9, 0x2738                  // t9 = offset to "Tag Team" image
        sw      t9, 0x0000(at)              // set ffa offset
        sw      t9, 0x0004(at)              // set teams offset

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, stockmode_table         // t1 = Tag Team stockmode_table address
        lw      t0, 0x0000(t1)              // t0 = Tag Team stockmode_table p1
        sw      t0, 0x0000(at)              // set stockmode_table p1
        lw      t0, 0x0004(t1)              // t0 = Tag Team stockmode_table p2
        sw      t0, 0x0004(at)              // set stockmode_table p2
        lw      t0, 0x0008(t1)              // t0 = Tag Team stockmode_table p3
        sw      t0, 0x0008(at)              // set stockmode_table p3
        lw      t0, 0x000C(t1)              // t0 = Tag Team stockmode_table p4
        sw      t0, 0x000C(at)              // set stockmode_table p4

        li      at, StockMode.stock_count_table // at = stock_count_table address
        OS.read_word(stock_count_table, t0) // t0 = Tag Team stock_count_table
        sw      t0, 0x0000(at)              // set stock_count_table

        // only reset previous_stock_count_table if coming from menu
        OS.read_byte(Global.previous_screen, at) // at = current screen
        lli     t0, Global.screen.VS_GAME_MODE_MENU
        bne     at, t0, _set_chars          // if not coming from menu, skip
        nop

        li      at, StockMode.previous_stock_count_table // at = previous_stock_count_table address
        OS.read_word(previous_stock_count_table, t0) // t0 = Tag Team previous_stock_count_table
        sw      t0, 0x0000(at)              // set previous_stock_count_table

        _set_chars:
        li      at, CharacterSelect.random_char_flag_vs
        sw      r0, 0x0000(at)              // clear the random_char_flag_vs (we rely on the queues)
        // s2 = VS match info
        li      t8, current_slot
        li      t7, character_queues
        or      t5, s2, r0                  // t5 = VS match info
        lli     at, 0x0000                  // at = port_id
        lli     t6, 0x0002                  // t6 = player type NA
        _loop:
        lli     t4, Character.id.NONE
        addu    t2, t8, at                  // t2 = address of current slot
        lbu     t1, 0x0000(t2)              // t1 = current slot
        jal     css.get_stock_count_        // v0 = stock count for port
        or      a0, at, r0
        slt     a0, v0, t1                  // a0 = 1 if stock count is lower than current slot
        bnezl   a0, pc() + 8                // if stock count is lower than current slot, update current slot
        or      t1, v0, r0                  // t1 = updated current slot
        sb      t1, 0x0000(t2)              // update current slot
        sll     t1, t1, 0x0002              // t1 = offset to slot
        addu    t2, t7, t1                  // t2 = slot
        lbu     t3, 0x0022(t5)              // t3 = player type (0 - HMN, 1 - CPU, 2 - NA)
        beq     t3, t6, _set_na_to_none     // if NA, don't set char_id
        lbu     t3, 0x0000(t2)              // t3 = current slot's char_id
        sb      t3, 0x0023(t5)              // set char_id
        bne     t3, t4, _set_costume        // if char_id is not NONE, set costume and shade
        lbu     t3, 0x0022(t5)              // t3 = player type (0 - HMN, 1 - CPU, 2 - NA)
        bnezl   t3, _next                   // if not HMN, set it to NA
        sb      t6, 0x0022(t5)              // set to NA

        _set_costume:
        lbu     t3, 0x0000(t2)              // t3 = current slot's char_id
        lli     t4, Character.id.PLACEHOLDER // t4 = RANDOM
        bne     t3, t4, _set_costume_from_slot // if not RANDOM, then update from slot
        nop                                 // otherwise set costume and shade to default for RANDOM
        sb      r0, 0x0026(t5)              // set default costume
        b       _next
        sb      r0, 0x0027(t5)              // set default shade

        _set_costume_from_slot:
        lbu     t3, 0x0001(t2)              // t3 = current slot's costume_id
        sb      t3, 0x0026(t5)              // set costume_id
        lbu     t3, 0x0002(t2)              // t3 = current slot's shade
        b       _next
        sb      t3, 0x0027(t5)              // set shade

        _set_na_to_none:
        sb      t4, 0x0023(t5)              // set char_id to NONE when type is NA

        _next:
        sltiu   t0, at, 0x0003              // t0 = 1 if more players to loop over
        addiu   t5, t5, 0x0074              // t5 = next match info player block
        addiu   t7, t7, 0x0018              // t7 = next character queue
        bnez    t0, _loop                   // loop over all players
        addiu   at, at, 0x0001              // at = next port_id

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
        sw      t0, 0x0000(t1)              // save Tag Team stocks

        li      at, 0x8013BDA8              // at = teams address
        lw      t0, 0x0000(at)              // t0 = teams in css
        li      t1, teams
        sw      t0, 0x0000(t1)              // save Tag Team teams

        li      at, StockMode.stockmode_table // at = stockmode_table address
        li      t1, stockmode_table         // t1 = Tag Team stockmode_table address
        lw      t0, 0x0000(at)              // t0 = Tag Team stockmode_table p1
        sw      t0, 0x0000(t1)              // save stockmode_table p1
        lw      t0, 0x0004(at)              // t0 = Tag Team stockmode_table p2
        sw      t0, 0x0004(t1)              // save stockmode_table p2
        lw      t0, 0x0008(at)              // t0 = Tag Team stockmode_table p3
        sw      t0, 0x0008(t1)              // save stockmode_table p3
        lw      t0, 0x000C(at)              // t0 = Tag Team stockmode_table p4
        sw      t0, 0x000C(t1)              // save stockmode_table p4

        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table
        li      t1, stock_count_table
        sw      t0, 0x0000(t1)              // save Tag Team stock_count_table

        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table
        li      t1, previous_stock_count_table
        sw      t0, 0x0000(t1)              // save Tag Team previous_stock_count_table

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
        addiu   sp, sp, -0x0020             // allocate stack space
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
        li      t1, stockmode_table         // t1 = Tag Team stockmode_table address
        lw      t0, 0x0000(at)              // t0 = Tag Team stockmode_table p1
        sw      t0, 0x0000(t1)              // save stockmode_table p1
        lw      t0, 0x0004(at)              // t0 = Tag Team stockmode_table p2
        sw      t0, 0x0004(t1)              // save stockmode_table p2
        lw      t0, 0x0008(at)              // t0 = Tag Team stockmode_table p3
        sw      t0, 0x0008(t1)              // save stockmode_table p3
        lw      t0, 0x000C(at)              // t0 = Tag Team stockmode_table p4
        sw      t0, 0x000C(t1)              // save stockmode_table p4

        OS.read_word(StockMode.stock_count_table, t0) // t0 = stock_count_table
        li      t1, stock_count_table
        sw      t0, 0x0000(t1)              // save Tag Team stock_count_table

        OS.read_word(StockMode.previous_stock_count_table, t0) // t0 = previous_stock_count_table
        li      t1, previous_stock_count_table
        sw      t0, 0x0000(t1)              // save Tag Team previous_stock_count_table

        // Loop over all character slots and set randomized char_id for any Randoms
        li      at, character_queues
        li      t8, character_queues + (0x4 * 6 * 4) // end of character_queues
        sw      t8, 0x0008(sp)              // save character_queues end
        lli     t1, Character.id.PLACEHOLDER
        lli     t7, 0x0000                  // t7 = slot counter
        lli     t6, 0x0000                  // t6 = port_id
        li      t5, CharacterSelect.CSS_PLAYER_STRUCT

        _loop:
        sw      t7, 0x0010(sp)              // save slot counter
        sw      t6, 0x0014(sp)              // save port_id
        sw      t5, 0x0018(sp)              // save css player struct
        lbu     t0, 0x0000(at)              // t0 = char_id
        bne     t0, t1, _next               // if not Random, skip
        sw      at, 0x000C(sp)              // save current slot

        li      a0, CharacterSelect._recent_randoms_lookup.placeholder_port
        sw      t6, 0x0000(a0)              // store port in flag

        jal     CharacterSelect.get_random_char_id_
        nop

        lw      at, 0x000C(sp)              // at = current slot
        sb      v0, 0x0003(at)              // set randomized char_id

        // randomize costume
        jal     Costumes.get_random_legal_costume_ // v0 = costume_id
        or      a0, v0, r0                  // a0 = char_id

        lw      at, 0x000C(sp)              // at = current slot
        sb      v0, 0x0001(at)              // set randomized costume_id
        lw      t6, 0x0014(sp)              // t6 = port_id

        OS.read_word(teams, t0)             // t0 = teams
        beqz    t0, _next                   // if not teams, skip
        lw      t5, 0x0018(sp)              // t5 = css player struct

        // check team and set team costume
        lb      a0, 0x0003(at)              // a0 = char_id
        jal     0x800EC104                  // ftParamGetCostumeTeamID(s32 ft_kind, s32 color)
        lw      a1, 0x0040(t5)              // t0 = team_index

        lw      at, 0x000C(sp)              // at = current slot
        sb      v0, 0x0001(at)              // set costume_id
        lw      t6, 0x0014(sp)              // t6 = port_id
        lw      t5, 0x0018(sp)              // t5 = css player struct

        // in Teams, we need to adjust shade if a teammate in a previous port has the same char_id
        lli     a0, 0x0000                  // a0 = loop counter
        lli     t1, 0x0000                  // t1 = shade to use
        or      a1, at, r0                  // a1 = current slot address
        lw      v0, 0x0040(t5)              // v0 = team index
        lbu     t0, 0x0003(at)              // t0 = char_id

        _teams_loop:
        beql    a0, t6, _next               // if we've reached our port, use the shade
        sb      t1, 0x0002(at)              // set shade
        lbu     t4, -0x0018(a1)             // t4 = previous port's char_id
        lli     t7, Character.id.PLACEHOLDER
        beql    t4, t7, pc() + 8            // if Random, get randomized char_id
        lbu     t4, -0x0015(a1)             // t4 = previous port's char_id
        addiu   a0, a0, 0x0001              // increment loop counter
        bne     t4, t0, _teams_next         // if not the same char_id, skip
        addiu   t5, t5, -0x00BC             // t5 = previous port's panel struct

        lw      t4, 0x0040(t5)              // t4 = previous port's team index
        beql    t4, v0, _teams_next         // if the same team, increment shade
        addiu   t1, t1, 0x0001              // t1 = next shade

        _teams_next:
        b       _teams_loop
        addiu   a1, a1, -0x0018             // a1 = previous port's slot

        _next:
        lw      t8, 0x0008(sp)              // t8 = character_queues end
        lw      t7, 0x0010(sp)              // t7 = slot counter
        lw      t5, 0x0018(sp)              // t5 = css player struct
        addiu   t7, t7, 0x0001              // t7 = next slot counter
        sltiu   t1, t7, 0x0006              // t1 = 0 if we need to move to next port
        bnez    t1, _do_loop                // if not at 6th slot, skip
        addiu   at, at, 0x0004              // at = next slot

        addiu   t5, t5, 0x00BC              // t5 = next css player struct
        addiu   t6, t6, 0x0001              // t6 = next port_id
        lli     t7, 0x0000                  // t7 = slot counter

        _do_loop:
        bne     at, t8, _loop               // loop over all slots
        lli     t1, Character.id.PLACEHOLDER

        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Loads when a match is starting (during scBattle_StartStockBattle)
    // and allows us to use the character queues' first slots.
    // Also sets up dynamic heap slots
    scope use_character_queues_on_load_: {
        OS.patch_start(0x10A2FC, 0x8018D40C)
        jal     use_character_queues_on_load_
        addiu   t3, t3, 0x5228              // original line 1
        OS.patch_end()

        // resets the alt heap after the files are loaded
        OS.patch_start(0x10A314, 0x8018D424)
        jal     use_character_queues_on_load_._reset_alt_heap
        or      a0, s0, r0                  // original line 2
        OS.patch_end()

        // resets the alt heap after all chars are loaded to be safe
        OS.patch_start(0x10A3E4, 0x8018D4F4)
        j       use_character_queues_on_load_._reset_alt_heap_safeguard
        nop
        _return:
        OS.patch_end()

        // s0 = port_id
        // 0x0023(v1) = char_id
        // 0x0026(v1) = costume_id
        // 0x0027(v1) = shade

        OS.read_word(VsRemixMenu.vs_mode_flag, t9) // t9 = vs_mode_flag
        lli     t4, VsRemixMenu.mode.TAG_TEAM
        bne     t9, t4, _end                // if not Tag Team, skip
        sll     t9, s0, 0x0003              // t9 = port_id * 0x08
        sll     t4, s0, 0x0004              // t4 = port_id * 0x10
        addu    t9, t9, t4                  // t9 = port_id * 0x18 = offset to character queue
        li      t4, character_queues
        addu    t6, t4, t9                  // t6 = character queue

        // check if Stock Mode is LAST
        // initial_stock_count_table values aren't set yet, though
        li      t9, StockMode.stockmode_table
        sll     t0, s0, 0x0002              // t0 = offset to stock mode for panel
        addu    t9, t9, t0                  // t9 = address of stock mode for panel
        lw      t9, 0x0000(t9)              // t0 = stock mode
        lli     t0, StockMode.mode.LAST
        bne     t9, t0, _set_values         // if Stock Mode != LAST, skip
        li      t9, StockMode.previous_stock_count_table // yes, delay slot
        addu    t9, t9, s0                  // t9 = previous stock count address
        lb      t9, 0x0000(t9)              // t9 = previous stock count
        bltz    t9, _set_values             // if out of stocks, skip
        OS.read_byte(Global.vs.stocks, t0)  // t0 = global stocks setting
        subu    t9, t0, t9                  // t9 = skipped stocks
        sll     t9, t9, 0x0002              // t9 = offset to slot
        addu    t6, t6, t9

        _set_values:
        lbu     t9, 0x0000(t6)              // t9 = char_id
        lli     t0, Character.id.PLACEHOLDER
        beql    t9, t0, pc() + 8            // if Random, get the randomized char_id
        lbu     t9, 0x0003(t6)              // t9 = char_id
        sb      t9, 0x0023(v1)              // set char_id
        lbu     t5, 0x0001(t6)              // t5 = costume_id
        sb      t5, 0x0026(v1)              // set costume_id
        lbu     t5, 0x0002(t6)              // t5 = shade
        sb      t5, 0x0027(v1)              // set shade

        // Also, let's clear the stolen counts here
        li      t4, stolen_count
        sw      r0, 0x0000(t4)              // reset stolen count

        // ...and stolen stocks
        li      t4, stolen_stocks
        sw      r0, 0x0000(t4)              // reset stolen stocks p1
        sw      r0, 0x0004(t4)              // reset stolen stocks p2
        sw      r0, 0x0008(t4)              // reset stolen stocks p3
        sw      r0, 0x000C(t4)              // reset stolen stocks p4

        // ...and stolen icons
        li      t4, stolen_icons
        sw      r0, 0x0000(t4)              // reset stolen icon image chunk p1
        sw      r0, 0x0004(t4)              // reset stolen icon palette p1
        sw      r0, 0x0008(t4)              // reset stolen icon image chunk p2
        sw      r0, 0x000C(t4)              // reset stolen icon palette p2
        sw      r0, 0x0010(t4)              // reset stolen icon image chunk p2
        sw      r0, 0x0014(t4)              // reset stolen icon palette p2
        sw      r0, 0x0018(t4)              // reset stolen icon image chunk p2
        sw      r0, 0x001C(t4)              // reset stolen icon palette p2

        lli     t0, Character.id.SONIC
        bne     t9, t0, _init_heaps         // if not Sonic, skip
        lbu     t9, 0x0003(t6)              // t9 = is_classic

        lli     t4, OS.TRUE
        bnel    t9, t4, pc() + 8            // if not true, set to false (it could be randomized sonic)
        lli     t4, OS.FALSE

        li      t9, Sonic.classic_table
        addu    t9, t9, s0                  // t9 = px is_classic
        sb      t4, 0x0000(t9)              // set is_classic

        _init_heaps:
        // Need to save: at, t1, t2, t3, v1, s0, s1, s2, s3, s4
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      at, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      v1, 0x0018(sp)              // ~
        sw      s2, 0x001C(sp)              // ~

        bnez    s0, _set_heap               // only init on first loop interation
        nop

        // Initialize the heap structs
        li      a0, CharacterSelect.dynamic_css.heap_struct_0
        lli     s2, 0x0004                  // s2 = loop index

        // Make sure custom_heap_address is above or equal to default heap space current address
        li      at, 0x800465E8              // at = main heap struct
        lw      t0, 0x000C(at)              // t0 = current free memory address
        li      at, custom_heap_address     // at = custom_heap_address
        lw      a2, 0x0000(at)              // a2 = current custom free memory address
        sltu    a1, a2, t0                  // a1 = 1 if default heap has surpassed custom heap
        bnezl   a1, pc() + 8                // if it has surpassed, then update custom heap address
        sw      t0, 0x0000(at)              // update custom_heap_address

        _loop:
        lw      a1, 0x0000(a0)              // a1 = debug ID
        li      at, custom_heap_address     // at = custom_heap_address
        lw      a2, 0x0000(at)              // a2 = current free memory address = initial floor of heap
        li      a3, 0x0004C000              // a3 = size of heap
        addu    t0, a2, a3                  // t0 = new main heap struct free memory address
        jal     0x80006D54                  // reset heap
        sw      t0, 0x0000(at)              // update main heap struct free memory address

        addiu   s2, s2, -0x0001             // s2 = loop index++
        bnez    s2, _loop                   // loop until all custom heap structs initialized
        addiu   a0, a0, 0x0010              // heap_struct++

        // If the default heap was already moved to expansion ram, set it to the current custom heap address
        li      at, 0x800465E8              // at = main heap struct
        lw      t0, 0x0008(at)              // t0 = main heap ceiling
        lui     t1, 0x8080                  // t1 = ceiling if moved to expansion ram
        bne     t0, t1, _clear_heap_slots   // skip if not expansion ram yet
        OS.read_word(custom_heap_address, t1) // t1 = current free memory address (yes, delay slot)
        sw      t1, 0x000C(at)              // update main heap current free memory address

        _clear_heap_slots:
        // Next, clear characters from the heap slots
        li      at, CharacterSelect.dynamic_css.heap_slot_0.character_id
        lli     t0, Character.id.NONE
        lli     s2, 0x0008                  // s2 = loop index
        _loop_2:
        sw      t0, 0x0000(at)              // save NONE for slot X char_id
        sb      t0, 0x0004(at)              // save NONE for slot X additional_char_ids[0]
        sb      t0, 0x0005(at)              // save NONE for slot X additional_char_ids[1]
        sb      t0, 0x0006(at)              // save NONE for slot X additional_char_ids[2]
        sb      t0, 0x0007(at)              // save NONE for slot X additional_char_ids[3]

        addiu   s2, s2, -0x0001             // s2 = loop index++
        bnez    s2, _loop_2                 // loop until all custom heap slots initialized
        addiu   at, at, 0x0010              // heap_slot_x++

        addiu   s2, r0, -0x0001             // s2 = -1
        li      at, CharacterSelect.dynamic_css.slot_used_by_port
        sw      s2, 0x0000(at)              // clear previous slot used by port
        sw      s2, 0x0004(at)              // clear current slot used by port

        // We need to load some files separately to avoid overflows (Kirby) and crashes (projectiles/items/movesets).
        // So, check for each potentially loaded char if any files should be preloaded outside the custom heap slots.
        li      at, character_queues
        _preload_loop:
        li      t1, preload_map
        lli     t4, Character.id.PLACEHOLDER
        lbu     t0, 0x0000(at)              // t0 = char_id
        beql    t0, t4, pc() + 8            // if Random, get the randomized char_id
        lbu     t0, 0x0003(at)              // t9 = char_id
        sll     t0, t0, 0x0002              // t0 = offset to preload map
        addu    t0, t1, t0                  // t0 = preload map pointer
        lw      t0, 0x0000(t0)              // t0 = preload map, or 0
        beqz    t0, _preload_next           // if no preload map, skip
        sw      at, 0x0020(sp)              // save slot address

        _preload_load_loop:
        lhu     a0, 0x0000(t0)              // a0 = file number
        beqz    a0, _preload_next           // if end of file list, continue outer loop
        lw      at, 0x0020(sp)              // at = slot address

        li      a1, pointer                 // a1 = file_address
        jal     Render.load_file_
        sw      t0, 0x0024(sp)              // save address of file_id to load

        lw      t0, 0x0024(sp)              // t0 = address of file_id just loaded
        b       _preload_load_loop          // loop
        addiu   t0, t0, 0x0002              // t0 = address of next file_id to load

        // Will use this for loading the file pointer (we don't reference it)
        pointer:; dw 0

        _preload_next:
        li      t3, character_queues + 24 * 4 // t3 = end address
        addiu   at, at, 0x0004              // at = next slot
        bne     at, t3, _preload_loop       // loop if not at end
        nop

        _set_heap:
        lw      v1, 0x0018(sp)              // restore v1
        lbu     t4, 0x0022(v1)              // t4 = player type (0 - HMN, 1 - CPU, 2 - NA)
        addiu   t4, t4, -0x0002             // t4 = 0 if NA
        beqz    t4, _finish                 // if NA, skip alt heap load
        nop
        jal     CharacterSelect.get_heap_slot_for_char_id_ // v0 = heap slot ID, or -1 if char not loaded
        lbu     a0, 0x0023(v1)              // a0 = char_id
        bltz    v0, _use_this_heap          // if char is not loaded, use this heap
        sltiu   t4, v0, 0x0004              // v0 = 1 if valid heap slot in game
        bnez    t4, _finish                 // if heap slot found, then char is loaded so skip alt heap load
        nop

        _use_this_heap:
        li      t4, CharacterSelect.dynamic_css.heap_slot_0
        sll     t9, s0, 0x0004              // t9 = offset to heap slot
        addu    t1, t4, t9                  // t1 = heap slot
        lbu     t9, 0x0023(v1)              // t9 = char_id
        sw      t9, 0x0004(t1)              // assign char_id to heap slot
        lw      t4, 0x0000(t1)              // t4 = heap struct
        li      t9, CharacterSelect.dynamic_css.alt_heap_pointer
        sw      t4, 0x0000(t9)              // set alt heap
        li      t9, load_all_files_.always_load
        lli     t4, OS.TRUE
        sw      t4, 0x0000(t9)              // set always_load to TRUE
        li      t4, 0x800D62E0              // t4 = file manager struct
        lw      t9, 0x0018(t4)              // t9 = total files loaded
        sw      t9, 0x000C(t1)              // save total files loaded before

        _finish:
        lw      ra, 0x0004(sp)              // load registers
        lw      at, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      v1, 0x0018(sp)              // ~
        lw      s2, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra
        sll     t2, t2, 0x0001              // original line 2

        _reset_alt_heap:
        OS.read_word(VsRemixMenu.vs_mode_flag, t9) // t9 = vs_mode_flag
        lli     t4, VsRemixMenu.mode.TAG_TEAM
        bne     t9, t4, _end_reset_alt_heap // if not Tag Team, skip
        sll     t9, s0, 0x0004              // t9 = offset to heap slot

        // Load variants
        addiu   sp, sp, -0x0010             // allocate stack
        sw      ra, 0x0004(sp)              // save ra
        sw      a0, 0x0008(sp)              // ~

        li      t4, CharacterSelect.dynamic_css.heap_slot_0
        jal     load_variants_in_same_slot_
        addu    a0, t4, t9                  // a0 = heap slot

        lw      ra, 0x0004(sp)              // restore ra
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack

        sll     t9, s0, 0x0004              // t9 = offset to heap slot
        li      t4, CharacterSelect.dynamic_css.heap_slot_0
        addu    t4, t4, t9                  // t4 = heap slot
        li      t1, 0x800D62E0              // t1 = file manager struct
        lw      t6, 0x0018(t1)              // t6 = total files loaded after
        lw      t5, 0x000C(t4)              // t5 = total files loaded before
        subu    t6, t6, t5                  // t6 = total files loaded in heap
        sw      t6, 0x000C(t4)              // save total files loaded in heap

        li      t0, load_all_files_.always_load
        sw      r0, 0x0000(t0)              // set always_load to FALSE
        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer
        sw      r0, 0x0000(t0)              // reset alt_heap_pointer

        _end_reset_alt_heap:
        jr      ra
        lw      t4, 0x0000(s2)              // original line 1

        _reset_alt_heap_safeguard:
        li      t0, load_all_files_.always_load
        sw      r0, 0x0000(t0)              // set always_load to FALSE
        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer
        jal     0x800D782C                  // original line 1 - ftManagerSetupFilesPlayablesAll()
        sw      r0, 0x0000(t0)              // reset alt_heap_pointer
        j       _return
        nop
    }

    // @ Description
    // This hijacks 0x8013CF60 ftCommonRebirthDownSetStatus(GObj *this_gobj) so that we can
    // load a different character
    scope load_next_char_: {
        OS.patch_start(0xB79A0, 0x8013CF60)
        addiu   sp, sp, -0x0090             // original line 1
        sw      ra, 0x0024(sp)              // original line 4
        jal     load_next_char_
        sw      s0, 0x001C(sp)              // original line 2
        OS.patch_end()

        addiu   sp, sp, -0x00B8             // allocate stack space
        sw      a0, 0x00AC(sp)              // save player object
        sw      a0, 0x0008(sp)              // save original player object

        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.TAG_TEAM
        bne     t0, t1, _end                // if not Tag Team, skip
        sw      ra, 0x00B0(sp)              // save ra

        lw      a1, 0x0084(a0)              // a1 = player struct
        lbu     t0, 0x000D(a1)              // t0 = port_id

        li      at, StockMode.initial_stock_count_table
        addu    at, at, t0                  // at = initital stock count for port address
        lbu     at, 0x0000(at)              // at = stocks setting

        // Get next char_id
        sll     t1, t0, 0x0003              // t1 = port_id * 0x08
        sll     t2, t0, 0x0004              // t2 = port_id * 0x10
        addu    t1, t1, t2                  // t1 = port_id * 0x18 = offset to character queue
        li      t8, character_queues
        addu    t8, t8, t1                  // t8 = character queue

        lbu     s0, 0x0014(a1)              // s0 = stocks remaining

        subu    at, at, s0                  // at = stocks setting - stocks remaining = queue index
        li      t2, stolen_stocks
        sll     t1, t0, 0x0002              // t1 = offset to stolen stock
        addu    t2, t2, t1                  // t2 = stolen stock address
        lw      t2, 0x0000(t2)              // t2 = stolen stock
        bnezl   t2, _get_char_id            // if this is a stolen stock, use the stolen stock details
        or      t8, t2, r0                  // t8 = stolen stock character slot

        li      t2, stolen_count
        addu    t2, t2, t0                  // t2 = address of stolen count
        lbu     t2, 0x0000(t2)              // t2 = stolen count
        subu    at, at, t2                  // at = real queue index

        // check if Stock Mode is LAST
        li      t2, StockMode.stockmode_table
        sll     t1, t0, 0x0002              // t1 = offset to stock mode for panel
        addu    t2, t2, t1                  // t2 = address of stock mode for panel
        lw      t2, 0x0000(t2)              // t0 = stock mode
        lli     t1, StockMode.mode.LAST
        bne     t2, t1, _get_slot           // if Stock Mode != LAST, skip
        li      t2, StockMode.initial_stock_count_table // yes, delay slot
        addu    t2, t2, t0                  // t2 = initial stock count address
        lbu     t2, 0x0000(t2)              // t2 = initial stock count
        OS.read_byte(Global.vs.stocks, t1)  // t1 = global stocks setting
        subu    t2, t1, t2                  // t2 = skipped stocks
        addu    at, at, t2                  // at = real queue index

        _get_slot:
        sll     at, at, 0x0002              // at = offset to slot
        addu    t8, t8, at                  // t8 = character slot

        _get_char_id:
        lbu     t1, 0x0000(t8)              // t1 = char_id
        lli     t2, Character.id.PLACEHOLDER
        beql    t1, t2, pc() + 8            // if Random, get the randomized char_id
        lbu     t1, 0x0003(t8)              // t1 = char_id
        lbu     t3, 0x0002(t8)              // t3 = shade

        // check if Sonic
        lli     t7, Character.id.SONIC
        bne     t1, t7, _check_char_id      // if not Sonic, skip
        lbu     t7, 0x0003(t8)              // t7 = is_classic

        lli     t4, OS.TRUE
        bnel    t7, t4, pc() + 8            // if not true, set to false (it could be randomized sonic)
        lli     t4, OS.FALSE

        li      t9, Sonic.classic_table
        addu    t9, t9, t0                  // t9 = px is_classic
        lbu     t7, 0x0000(t9)              // t7 = current is_classic value
        sb      t4, 0x0000(t9)              // set is_classic
        bne     t4, t7, _load               // if is_classic changed, then we will have to load
        lbu     t2, 0x0001(t8)              // t2 = costume_id

        _check_char_id:
        lw      t2, 0x0008(a1)              // t2 = current char_id
        beq     t1, t2, _update_costume     // if already the right character, just update costume/shade
        lbu     t2, 0x0001(t8)              // t2 = costume_id

        _load:
        // Clear out flags for CharEnvColor stuff to avoid DISASTROUS CONSEQUENCES
        jal     CharEnvColor.reset_custom_display_lists_
        lw      a0, 0x0008(a1)              // a0 = char_id

        lw      a0, 0x00AC(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct

        addiu   t8, sp, 0x005C              // t8 = player_spawn address
        li      t5, 0x80116DD0              // t5 = dFTManagerDefaultFighterDesc
        addiu   t9, t5, 0x003C              // t9 = end of dFTManagerDefaultFighterDesc struct

        // the following loop is: player_spawn = dFTManagerDefaultFighterDesc;
        _loop:
        lw      t7, 0x0000(t5)
        addiu   t5, t5, 0x000C
        addiu   t8, t8, 0x000C
        sw      t7, 0xFFF4(t8)
        lw      t6, 0xFFF8(t5)
        sw      t6, 0xFFF8(t8)
        lw      t7, 0xFFFC(t5)
        bne     t5, t9, _loop
        sw      t7, 0xFFFC(t8)
        lw      t7, 0x0000(t5)
        sw      t7, 0x0000(t8)

        // copy values from current player to player_spawn
        sw      t1, 0x005C(sp)              // player_spawn.ft_kind = char_id
        lbu     t7, 0x000C(a1)              // t7 = team
        sb      t7, 0x0070(sp)              // player_spawn.team = team
        sb      t0, 0x0071(sp)              // player_spawn.player = port_id
        lbu     t7, 0x000E(a1)              // t7 = hi/lo poly
        sb      t7, 0x0072(sp)              // player_spawn.detail = hi/lo poly
        sb      t2, 0x0073(sp)              // player_spawn.costume = costume_id
        sb      t3, 0x0074(sp)              // player_spawn.shade = shade
        lbu     t7, 0x0012(a1)              // t7 = handicap
        sb      t7, 0x0075(sp)              // player_spawn.handicap = handicap
        lbu     t7, 0x0013(a1)              // t7 = cp_level
        sb      t7, 0x0076(sp)              // player_spawn.cp_level = cp_level
        sb      s0, 0x0077(sp)              // player_spawn.stock_count = stock_count
        lli     t7, 0x00C0                  // player_spawn.is_skip_shadow_setup = TRUE and player_spawn.is_skip_entry = TRUE
        sb      t7, 0x007B(sp)              // player_spawn.is_skip_shadow_setup = TRUE and player_spawn.is_skip_entry = TRUE
        sw      r0, 0x0080(sp)              // player_spawn.damage = 0
        lw      t7, 0x0020(a1)              // t7 = pl_kind
        sw      t7, 0x0084(sp)              // player_spawn.pl_kind = pl_kind
        lw      t7, 0x01B0(a1)              // t7 = controller
        sw      t7, 0x0088(sp)              // player_spawn.controller = controller

        // reuse the heap slot
        lw      t7, 0x09D0(a1)              // t7 = anim_heap
        sw      t7, 0x0094(sp)              // player_spawn.anim_heap = anim_heap

        lw      t7, 0x0000(a1)              // t7 = next player struct

        jal     0x800D78E8                  // ftManagerDestroyFighter(GObj *fighter_gobj)
        sw      t7, 0x00B4(sp)              // save next player struct

        lw      a0, 0x00AC(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      t7, 0x00B4(sp)              // t7 = next player struct
        sw      t7, 0x0000(a1)              // restore next player struct

        jal     CharacterSelect.get_heap_slot_for_char_id_ // v0 = heap slot ID, or -1 if char not loaded
        lw      a0, 0x005C(sp)              // a0 = char_id
        bltz    v0, _get_free_heap          // if char is not loaded, need to load into a free heap
        sltiu   t4, v0, 0x0004              // v0 = 1 if valid heap slot in game
        bnez    t4, _spawn                  // if heap slot found, then char is loaded so skip loading
        nop

        _get_free_heap:
        // update match struct's char_id so it's easier to tell if a heap is free
        lw      a0, 0x00AC(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        lbu     t0, 0x000D(a1)              // t0 = port_id
        li      t6, Global.vs.p1
        lli     t8, Global.vs.P_DIFF        // t8 = size of struct
        multu   t0, t8
        mflo    t7                          // t7 = offset to match player struct
        addu    t6, t6, t7                  // t6 = match player struct
        lw      t1, 0x005C(sp)              // t1 = char_id
        sb      t1, 0x0003(t6)              // update char_id

        // now get free heap slot
        li      at, CharacterSelect.dynamic_css.heap_slot_0
        lli     t0, Character.id.NONE
        lli     t5, 0x0000                  // t5 = heap slot
        OS.read_byte(Global.vs.p1 + 0x0003, t1) // t1 = port 1 char_id
        OS.read_byte(Global.vs.p2 + 0x0003, t2) // t2 = port 2 char_id
        OS.read_byte(Global.vs.p3 + 0x0003, t3) // t3 = port 3 char_id
        OS.read_byte(Global.vs.p4 + 0x0003, t4) // t4 = port 4 char_id

        _heap_loop:
        lw      t6, 0x0004(at)              // t6 = heap slot X character_id
        addiu   t7, at, 0x0008              // t7 = heap slot X additional_char_ids address
        lli     t8, 4                       // t8 = size of additional_char_ids array

        beql    t0, t6, _use_heap           // if no character assigned, use this
        or      v0, at, r0                  // v0 = heap_slot_X

        _heap_loop_2:
        beq     t6, t1, _heap_next          // if p1 is using this char, go to next heap
        nop
        beq     t6, t2, _heap_next          // if p2 is using this char, go to next heap
        nop
        beq     t6, t3, _heap_next          // if p3 is using this char, go to next heap
        nop
        beq     t6, t4, _heap_next          // if p4 is using this char, go to next heap
        nop

        // Also need to check the additional char_ids loaded in this slot, so loop some more!
        addiu   t8, t8, -0x0001             // t8--
        bltz    t8, _use_heap_after_reset   // if done checking all additional char_ids, then can use
        lb      t6, 0x0000(t7)              // t6 = next additional_char_id to check
        bne     t0, t6, _heap_loop_2        // if we didn't reach the end of the array, confirm the additional char_id is not in use
        addiu   t7, t7, 0x0001              // t7 = next additional_char_ids element address

        _use_heap_after_reset:
        // if here, this heap slot can be used, but needs to be reset
        jal     CharacterSelect.reset_heap_slot_ // v0 = heap slot
        or      a0, t5, r0                  // a0 = heap index

        // adjust the file table so it's as if the files were never loaded
        li      t3, 0x800D62E0              // t3 = file manager struct
        lw      t6, 0x0018(t3)              // t6 = total files loaded
        sll     t5, t6, 0x0003              // t5 = size of files loaded list
        li      t0, file_table
        addu    t5, t0, t5                  // t5 = end of loaded files address
        lw      at, 0x0000(v0)              // at = heap struct
        lw      t1, 0x0004(at)              // t1 = heap start RAM
        addiu   t2, r0, 0xFFF0              // t2 = 0xFFFFFFF0
        addiu   t1, t1, 0x000F              // t1 = heap start RAM plus 0xF
        and     t1, t1, t2                  // t1 = heap start RAM aligned to 0x10
        lw      t2, 0x0008(at)              // t2 = heap end RAM
        lli     t7, 0x0000                  // t7 = start address
        lw      t8, 0x000C(v0)              // t2 = total files in heap
        subu    t6, t6, t8                  // t6 = files loaded after
        sw      t6, 0x0018(t3)              // update total files loaded

        _file_loop:
        beq     t0, t5, _file_loop_end      // if at the end of files loaded, finish
        lw      t3, 0x0004(t0)              // t3 = RAM address of file
        beql    t3, t1, _file_loop_end      // if file RAM address is heap start, we have it!
        or      t7, t0, r0                  // t7 = start address

        b       _file_loop                  // loop
        addiu   t0, t0, 0x0008              // t0 = next file address

        _file_loop_end:
        sll     t1, t8, 0x0003              // t1 = size of file table space to overwrite
        addu    a0, t7, t1                  // a0 = start of space to copy
        subu    a2, t5, a0                  // a2 = size of space to copy
        beqz    a2, _use_heap               // if the heap was at the end of the file list, skip copying lol
        or      at, v0, r0                  // at = heap slot

        sw      v0, 0x0004(sp)              // save heap slot
        jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
        or      a1, t7, r0                  // a1 = start address of heap's loaded files

        b       _use_heap
        lw      at, 0x0004(sp)              // at = heap slot

        _heap_next:
        addiu   at, at, 0x0010              // at = next heap_slot character_id address
        addiu   t5, t5, 0x0001              // t5++ = increment heap index
        bnez    t5, _heap_loop              // loop until t5 is 0
        nop

        _use_heap:
        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer
        lw      t1, 0x0000(at)              // t1 = heap struct
        sw      t1, 0x0000(t0)              // set alt heap
        lw      a0, 0x005C(sp)              // a0 = char_id
        sw      a0, 0x0004(at)              // set char_id in heap
        li      t0, load_all_files_.always_load
        lli     t1, OS.TRUE
        sw      t1, 0x0000(t0)              // set always_load to TRUE
        li      t1, 0x800D62E0              // t1 = file manager struct
        lw      t6, 0x0018(t1)              // t6 = total files loaded
        sw      t6, 0x000C(at)              // save total files loaded before
        sw      at, 0x0004(sp)              // save heap slot

        jal     0x800D786C                  // ftManagerSetupFilesAllKind
        lw      a0, 0x005C(sp)              // a0 = char_id

        // Here, we will load in any variants as well. This avoids having to preload them outside
        // the custom heaps, saving space. I could be more efficient, but this shouldn't add too
        // much overhead.
        jal     load_variants_in_same_slot_
        lw      a0, 0x0004(sp)              // a0 = heap slot

        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer
        sw      r0, 0x0000(t0)              // reset alt_heap_pointer
        li      t0, load_all_files_.always_load
        sw      r0, 0x0000(t0)              // set always_load to FALSE
        lw      at, 0x0004(sp)              // at = heap slot
        li      t1, 0x800D62E0              // t1 = file manager struct
        lw      t6, 0x0018(t1)              // t6 = total files loaded after
        lw      t5, 0x000C(at)              // t5 = total files loaded before
        subu    t6, t6, t5                  // t6 = total files loaded in heap
        sw      t6, 0x000C(at)              // save total files loaded in heap

        // This is probably inefficient, but we need to be sure the file pointers for the char and it's parent are set
        jal     0x800D782C                  // ftManagerSetupFilesPlayablesAll
        nop

        _spawn:
        jal     0x800D7F3C                  // v0 = ftManagerMakeFighter(ftCreateDesc *ft_desc)
        addiu   a0, sp, 0x005C              // a0 = player_spawn

        or      a0, v0, r0                  // a0 = new player object
        jal     0x800E7F68                  // ftParamUnlockPlayerControl
        sw      a0, 0x00AC(sp)              // save player object

        lw      a0, 0x00AC(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        sw      r0, 0x0ADC(a1)              // clear space commonly used for tracking various ammo
        lbu     t0, 0x000D(a1)              // t0 = port_id

        // Change damage series icon
        li      t7, 0x80131598              // t7 = sIFCommonPlayerDamageInterface[]
        lli     t8, 0x006C                  // t8 = size of entry
        multu   t0, t8
        mflo    t0                          // t0 = offset to port's damage interface struct
        addu    t7, t7, t0                  // t7 = port's damage interface struct
        lw      t7, 0x0060(t7)              // t7 = damage indicator object
        lw      t7, 0x0074(t7)              // t7 = damage series icon struct
        lw      t0, 0x09C8(a1)              // t0 = attributes struct
        lw      t0, 0x0340(t0)              // t0 = ftSprites struct address
        lw      t8, 0x0008(t0)              // t8 = series icon footer address
        lw      t0, 0x0034(t8)              // t0 = series icon address
        sw      t0, 0x0044(t7)              // update series icon

        // Fix position of series icon
        lh      t1, 0x0014(t7)              // t1 = old sprite width
        mtc1    t1, f2                      // f2 = old sprite width
        cvt.s.w f2, f2                      // f2 = old sprite width, float
        lh      t0, 0x0016(t7)              // t0 = old sprite height
        mtc1    t0, f4                      // f4 = old sprite height
        cvt.s.w f4, f4                      // f4 = old sprite height, float
        lh      t0, 0x0004(t8)              // t0 = new sprite width
        // To account for Dragon King HUD, don't update width if DK HUD set it to 0
        bnezl   t1, pc() + 8                // if old sprite width was not 0, then update sprite width
        sh      t0, 0x0014(t7)              // update sprite width
        beqzl   t1, pc() + 8                // if old sprite width was 0 (DK HUD), then clear out X scale to remove artifacts
        sw      r0, 0x0018(t7)              // update sprite width
        mtc1    t0, f12                     // f12 = new sprite width
        cvt.s.w f12, f12                    // f12 = new sprite width, float
        lh      t0, 0x0006(t8)              // t0 = new sprite height
        sh      t0, 0x0016(t7)              // update sprite height
        mtc1    t0, f14                     // f14 = new sprite height
        cvt.s.w f14, f14                    // f14 = new sprite height, float
        lui     t0, 0x3F00                  // t0 = 0.5F
        mtc1    t0, f6                      // f6 = 0.5F
        sub.s   f2, f2, f12                 // f2 = old width - new width
        sub.s   f4, f4, f14                 // f4 = old height - new height
        mul.s   f2, f2, f6                  // f2 = delta width
        mul.s   f4, f4, f6                  // f4 = delta height
        lwc1    f12, 0x0058(t7)             // f12 = current x
        lwc1    f14, 0x005C(t7)             // f14 = current y
        add.s   f2, f12, f2                 // f2 = new x
        add.s   f4, f14, f4                 // f4 = new y
        swc1    f2, 0x0058(t7)              // update x
        swc1    f4, 0x005C(t7)              // update y
        lw      t0, 0x002C(t8)              // t0 = old sprite heights
        sw      t0, 0x003C(t7)              // update sprite heights

        _redraw_icons:
        // Trigger redraw of stock icons
        li      t7, 0x801317CC
        lw      a0, 0x00AC(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        lbu     t0, 0x000D(a1)              // t0 = port_id
        addu    t7, t7, t0                  // t7 = holds number of icons per port
        sb      r0, 0x0000(t7)              // trigger redraw

        // update match struct
        li      t6, Global.vs.p1
        lli     t8, Global.vs.P_DIFF        // t8 = size of struct
        multu   t0, t8
        mflo    t7                          // t7 = offset to match player struct
        addu    t6, t6, t7                  // t6 = match player struct
        sw      a0, 0x0058(t6)              // update player object
        lw      t1, 0x005C(sp)              // t1 = char_id
        sb      t1, 0x0003(t6)              // update char_id
        lbu     t2, 0x0073(sp)              // t2 = costume_id
        sb      t2, 0x0006(t6)              // update costume_id
        lbu     t3, 0x0074(sp)              // t3 = shade
        sb      t3, 0x0007(t6)              // update shade

        // Reset any owned items/projectiles
        lw      t0, 0x0008(sp)              // t0 = original player object
        OS.read_word(0x80046700, at)        // at = item object linked list head
        _item_loop:
        beqz    at, _item_loop_end          // if no item, end
        nop
        lw      t1, 0x0084(at)              // t1 = item struct
        beqz    t1, _item_loop_next         // if no item struct (can this happen?), skip
        nop
        lw      t2, 0x0008(t1)              // t2 = owner
        beql    t2, t0, pc() + 8            // if the owner is the old player object, update it
        sw      a0, 0x0008(t1)              // update owner

        // Blue Shell stores a pointer to the player object
        lw      t2, 0x0180(t1)              // t2 = player object
        beql    t2, t0, pc() + 8            // if the player object is the old player object, update it
        sw      a0, 0x0180(t1)              // update player object

        // Flashbang, Waddle Dee, Waddle Doo and Gordo store a pointer to the player object
        lw      t2, 0x01C4(t1)              // t2 = player object
        beql    t2, t0, pc() + 8            // if the player object is the old player object, update it
        sw      a0, 0x01C4(t1)              // update player object

        _item_loop_next:
        b       _item_loop
        lw      at, 0x0004(at)              // at = next item

        _item_loop_end:

        OS.read_word(0x80046838, at)        // at = projectile linked list head
        _projectile_loop:
        beqz    at, _end                    // if no projectile, end
        nop
        lw      t1, 0x0084(at)              // t1 = projectile struct
        beqz    t1, _projectile_loop_next   // if no projectile struct (can this happen?), skip
        nop
        lw      t2, 0x0008(t1)              // t2 = owner
        beql    t2, t0, pc() + 8            // if the owner is the old player object, update it
        sw      a0, 0x0008(t1)              // update owner

        _projectile_loop_next:
        b       _projectile_loop
        lw      at, 0x0020(at)              // at = next projectile

        _end:
        lw      ra, 0x00B0(sp)              // restore ra
        addiu   sp, sp, 0x00B8              // deallocate stack space
        jr      ra
        lui     t7, 0x8011                  // original line 3

        _update_costume:
        sw      t1, 0x005C(sp)              // save char_id
        sb      t2, 0x0073(sp)              // save costume_id
        sb      t3, 0x0074(sp)              // save shade

        // a0 = player object
        sw      a0, 0x00AC(sp)              // save player object
        or      a1, t2, r0                  // a2 = costume_id
        jal     0x800E9248                  // update costume/shade (ftParamInitModelTexturePartsAll)
        or      a2, t3, r0                  // a2 = shade

        b       _redraw_icons               // redraw icons in case this was a random slot
        nop
    }

    // @ Description
    // Loads any variants of the given heap slot's char_id into the heap slot
    // @ Params
    // a0 - heap slot
    scope load_variants_in_same_slot_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        or      at, a0, r0                  // at = heap slot
        lw      t1, 0x0004(at)              // t1 = char_id
        li      t0, Character.variants_with_same_model.table
        sll     t1, t1, 0x0002              // t1 = offset to char
        addu    t0, t0, t1                  // t0 = address of variants with same model array
        lb      a0, 0x0000(t0)              // a0 = 1st variant with same model
        lli     t0, Character.id.NONE
        beq     a0, t0, _done_loading_files // if end of array, done loading
        nop
        // otherwise, load the char
        jal     0x800D786C                  // ftManagerSetupFilesAllKind
        sb      a0, 0x0008(at)              // save to additional_chars_ids array

        lw      at, 0x0008(sp)              // at = heap slot
        lw      t1, 0x0004(at)              // t1 = char_id
        li      t0, Character.variants_with_same_model.table
        sll     t1, t1, 0x0002              // t1 = offset to char
        addu    t0, t0, t1                  // t0 = address of variants with same model array
        lb      a0, 0x0001(t0)              // a0 = 2nd variant with same model
        lli     t0, Character.id.NONE
        beq     a0, t0, _done_loading_files // if end of array, done loading
        nop
        // otherwise, load the char
        jal     0x800D786C                  // ftManagerSetupFilesAllKind
        sb      a0, 0x0009(at)              // save to additional_chars_ids array

        lw      at, 0x0008(sp)              // at = heap slot
        lw      t1, 0x0004(at)              // t1 = char_id
        li      t0, Character.variants_with_same_model.table
        sll     t1, t1, 0x0002              // t1 = offset to char
        addu    t0, t0, t1                  // t0 = address of variants with same model array
        lb      a0, 0x0002(t0)              // a0 = 3rd variant with same model
        lli     t0, Character.id.NONE
        beq     a0, t0, _done_loading_files // if end of array, done loading
        nop
        // otherwise, load the char
        jal     0x800D786C                  // ftManagerSetupFilesAllKind
        sb      a0, 0x000A(at)              // save to additional_chars_ids array

        lw      at, 0x0008(sp)              // at = heap slot
        lw      t1, 0x0004(at)              // t1 = char_id
        li      t0, Character.variants_with_same_model.table
        sll     t1, t1, 0x0002              // t1 = offset to char
        addu    t0, t0, t1                  // t0 = address of variants with same model array
        lb      a0, 0x0003(t0)              // 4th = 1st variant with same model
        lli     t0, Character.id.NONE
        beq     a0, t0, _done_loading_files // if end of array, done loading
        nop
        // otherwise, load the char
        jal     0x800D786C                  // ftManagerSetupFilesAllKind
        sb      a0, 0x000B(at)              // save to additional_chars_ids array

        _done_loading_files:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Ensures all required files are loaded for a character in their heap slot by
    // ignoring files loaded in other heap slots.
    scope load_all_files_: {
        OS.patch_start(0x4903C, 0x800CD65C)
        j       load_all_files_
        lw      t0, 0x0004(a1)              // t0 = RAM address of found file
        _return:
        OS.patch_end()

        OS.read_word(always_load, t1)       // t1 = 1 if always load is enabled
        beqz    t1, _end                    // if always load is not enabled, use the found file address
        nop

        li      t1, CharacterSelect.dynamic_css.heap_struct_0
        lw      t1, 0x0004(t1)              // t1 = start of first heap
        blt     t0, t1, _end                // if found file is before first heap, it's ok
        li      t1, CharacterSelect.dynamic_css.heap_struct_3 // yes, delay slot
        lw      t1, 0x0008(t1)              // t1 = end of last heap
        ble     t1, t0, _end                // if found file is after last heap, it's ok

        // the current value of alt_heap_pointer holds the heap struct we're loading into
        OS.read_word(CharacterSelect.dynamic_css.alt_heap_pointer, t2)
        lw      t1, 0x0004(t2)              // t1 = start of heap
        blt     t0, t1, _force_not_found    // if found file is outside current heap, it is not ok
        lw      t2, 0x0008(t2)              // t2 = end of heap
        blt     t0, t2, _end                // if found file is inside current heap, it is ok
        nop
        // if here, it's loaded in a higher heap and is not ok

        _force_not_found:
        j       _return                     // continue iterating through file list
        lli     at, OS.TRUE                 // force loop

        _end:
        jr      ra
        or      v0, t0, r0                  // v0 = RAM address of found file

        // @ Description
        // Flag to indicate if we should always load files
        always_load:
        dw OS.FALSE
    }

    // @ Description
    // Prevents particle bank stuff getting loaded inside custom heaps
    scope load_particle_bank_stuff_in_normal_heap: {
        OS.patch_start(0x9126C, 0x80115A6C)
        jal     load_particle_bank_stuff_in_normal_heap._before_malloc
        addiu   a1, r0, 0x0008              // original line 1
        OS.patch_end()

        OS.patch_start(0x91298, 0x80115A98)
        jal     load_particle_bank_stuff_in_normal_heap._after_malloc
        sw      v0, 0x0038(sp)              // original line 1
        OS.patch_end()

        _before_malloc:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.TAG_TEAM
        bne     t0, t1, _end_before         // if not Tag Team, skip
        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer // yes, delay slot
        lw      t1, 0x0000(t0)              // t1 = alt heap pointer
        sw      t1, 0x0010(sp)              // save alt heap pointer value in free stack space
        sw      r0, 0x0000(t0)              // clear alt heap pointer temporarily

        _end_before:
        jr      ra
        subu    a0, t7, t8                  // original line 2

        _after_malloc:
        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        lli     t1, VsRemixMenu.mode.TAG_TEAM
        bne     t0, t1, _end_after          // if not Tag Team, skip
        lw      t1, 0x0010(sp)              // t1 = alt heap pointer
        li      t0, CharacterSelect.dynamic_css.alt_heap_pointer
        sw      t1, 0x0000(t0)              // restore alt heap pointer

        _end_after:
        jr      ra
        lw      a0, 0x0040(sp)              // original line 2
    }

    // @ Description
    // Ensures that we use the largest animation size as the heap size for Tag Team mode
    // instead of the one for the character being created. This way we can reuse the anim
    // heap slot.
    scope use_largest_anim_heap_: {
        OS.patch_start(0x10A3B4, 0x8018D4C4)
        j       use_largest_anim_heap_
        lli     t1, VsRemixMenu.mode.TAG_TEAM
        _return:
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
        bne     t0, t1, _normal             // if not Tag Team, get heap size normally
        OS.read_word(0x80130D9C, a0)        // a0 = size of biggest animation (yes, delay slot)

        addiu   sp, sp, -0x0018             // allocate stack space
        jal     0x80004980                  // malloc - allocate memory for anim heap
        addiu   a1, r0, 0x0010              // a1 = align to 0x10
        addiu   sp, sp, 0x0018              // deallocate stack space

        j       _return
        nop

        _normal:
        jal     0x800D78B4                  // original line 1 - ftManagerAllocAnimHeapKind
        lbu     a0, 0x0023(v1)              // original line 2 - a0 = char_id

        j       _return
        nop
    }

    // @ Description
    // Shows all the icons like on the CSS but in reverse
    scope show_all_icons_: {
        OS.patch_start(0x8B0B0, 0x8010F8B0)
        jal     show_all_icons_._get_falls
        lb      s1, 0x002B(v0)              // original line 1 - s1 = remaining stocks
        OS.patch_end()

        // set texture/palette
        OS.patch_start(0x8B190, 0x8010F990)
        jal     show_all_icons_._set_icon
        sw      t5, 0x0030(v0)              // original line 1 - set palette
        OS.patch_end()

        _get_falls:
        lw      t9, 0x0030(v0)              // t9 = falls
        sw      t9, 0x0054(sp)              // save falls to unused stack
        jr      ra
        lw      t9, 0x0078(v0)              // original line 2

        _set_icon:
        // v0 = image struct
        // a2 = player struct
        // v1 = slot
        // t2 = port_id
        // s1 = remaining stocks

        OS.read_word(VsRemixMenu.vs_mode_flag, t7) // t7 = vs_mode_flag
        lli     t8, VsRemixMenu.mode.TAG_TEAM
        bne     t7, t8, _end                // if not Tag Team, skip
        subu    t9, s1, v1                  // t9 = remaining stocks - slot + 1
        addiu   t9, t9, -0x0001             // t9 = remaining stocks - slot
        lw      t8, 0x0054(sp)              // t8 = falls
        addu    t9, t9, t8                  // t9 = icon index in queue

        // check if Stock Mode is LAST
        li      t7, StockMode.stockmode_table
        sll     t5, t2, 0x0002              // t5 = offset to stock mode for panel
        addu    t7, t7, t5                  // t7 = address of stock mode for panel
        lw      t7, 0x0000(t7)              // t0 = stock mode
        lli     t5, StockMode.mode.LAST
        bne     t7, t5, _check_last         // if Stock Mode != LAST, skip
        li      t7, StockMode.initial_stock_count_table // yes, delay slot
        addu    t7, t7, t2                  // t7 = initial stock count address
        lbu     t7, 0x0000(t7)              // t7 = initial stock count
        OS.read_byte(Global.vs.stocks, t5)  // t5 = global stocks setting
        subu    t7, t5, t7                  // t7 = skipped stocks
        addu    t9, t9, t7                  // t9 = real icon index

        _check_last:
        bne     t9, t8, _use_slot           // if not the last icon, use slot icon
        lli     t8, ICON_CACHE_PORT_SIZE

        // check if it's a stolen stock
        li      t7, stolen_icons
        sll     t8, t2, 0x0003              // t8 = offset to stolen icon info
        addu    t7, t7, t8                  // t7 = stolen icon info
        lw      t8, 0x0004(t7)              // t8 = stolen icon palette, if exists
        // I'm not sure why I did this below, but I don't think it's needed
        // bnez    t8, _update_icon            // if it exists, use it!
        // lw      t7, 0x0000(t7)              // t7 = stolen icon image chunk
        bnez    t8, _end                    // if it exists, use loaded char's stock icon
        nop

        // it is the last icon, so check if the loaded char matches the slot char_id
        li      t7, character_queues
        sll     t5, t2, 0x0004              // t5 = port_id * 0x10
        sll     t8, t2, 0x0003              // t8 = port_id * 0x08
        addu    t5, t5, t8                  // t5 = offset to queue
        addu    t7, t7, t5                  // t7 = queue
        sll     t8, t9, 0x0002              // t8 = offset to slot
        addu    t7, t7, t8                  // t7 = slot

        lbu     t5, 0x0000(t7)              // t5 = char_id
        lli     t8, Character.id.PLACEHOLDER
        beql    t5, t8, pc() + 8            // if Random, get the randomized char_id
        lbu     t5, 0x0003(t7)              // t5 = char_id
        lw      t8, 0x0008(a2)              // t8 = current char_id
        bne     t5, t8, _use_slot           // if the right character is not loaded, use slot
        lbu     t5, 0x0001(t7)              // t5 = costume_id

        // check costume too
        lbu     t8, 0x0010(a2)              // t8 = current costume_id
        bne     t5, t8, _use_slot           // if not the same costume, use slot
        lli     t8, Character.id.SONIC

        // check if Sonic
        lw      t5, 0x0008(a2)              // t5 = current char_id
        bne     t5, t8, _end                // if not Sonic, skip (use loaded char's icon)
        lbu     t5, 0x0003(t7)              // t5 = is_classic

        // it's Sonic, so check is_classic
        lli     t7, OS.TRUE
        bnel    t5, t7, pc() + 8            // if not true, set to false (it could be randomized sonic)
        lli     t7, OS.FALSE

        li      t8, Sonic.classic_table
        addu    t8, t8, t2                  // t8 = px is_classic
        lbu     t8, 0x0000(t8)              // t8 = current is_classic value

        beq     t7, t8, _end                // if is_classic matches, skip (use loaded char's icon)
        nop

        _use_slot:
        lli     t8, ICON_CACHE_PORT_SIZE
        mflo    t5                          // save mflo
        li      t7, icon_cache
        multu   t8, t2                      // mflo = offset to port's icon cache
        mflo    t8                          // t8 = offset to port's icon cache
        addu    t7, t7, t8                  // t7 = port's icon cache
        lli     t8, ICON_CACHE_SLOT_SIZE
        multu   t8, t9                      // mflo = offset to port's icon cache slot
        mflo    t8                          // t8 = offset to port's icon cache slot
        addu    t7, t7, t8                  // t7 = port's icon cache slot
        addiu   t8, t7, ICON_PALETTE_OFFSET // t8 = address of palette
        addiu   t7, t7, ICON_IMAGE_CHUNK_OFFSET // t8 = address of image chunk
        mtlo    t5                          // restore mflo

        _update_icon:
        sw      t8, 0x0030(v0)              // set palette
        sw      t7, 0x0044(v0)              // set image chunk

        _end:
        lli     t7, 0x0201                  // t7 = flags
        sh      t7, 0x0024(v0)              // ensure proper flags are set
        jr      ra
        lw      t7, 0x0008(a1)              // original line 2
    }

    // @ Description
    // Handles stock stealing in teams
    scope handle_stock_stealing_: {
        OS.patch_start(0x8BBC0, 0x801103C0)
        jal     handle_stock_stealing_
        sw      t4, 0x0030(v1)              // original line 1 - set palette
        OS.patch_end()

        OS.read_word(VsRemixMenu.vs_mode_flag, t7) // t7 = vs_mode_flag
        lli     t8, VsRemixMenu.mode.TAG_TEAM
        bne     t7, t8, _end                // if not Tag Team, skip
        nop

        // Need to set this to the icon that got stolen
        lw      a0, 0x0034(sp)              // a0 = stolen port_id
        li      t4, icon_cache
        lli     a2, ICON_CACHE_PORT_SIZE
        multu   a2, a0                      // mflo = offset to icon cache for stolen port
        mflo    t7                          // t7 = offset to icon cache for stolen port
        addu    t4, t4, t7                  // t4 = icon cache for stolen port
        // current_slot should be correct, unless this port was stolen from previously
        li      a2, stolen_count
        addu    a2, a2, a0                  // a2 = address of stolen count
        lbu     t7, 0x0000(a2)              // t7 = number of times the port had a stock stolen
        addiu   a1, t7, 0x0001              // a1 = new stolen count
        sb      a1, 0x0000(a2)              // update stolen count
        li      a2, current_slot
        addu    a2, a2, a0                  // a2 = address of current slot
        lbu     a0, 0x0000(a2)              // a0 = current slot
        subu    a0, a0, t7                  // a0 = current slot - stolen count = icon index
        lli     a2, ICON_CACHE_SLOT_SIZE
        multu   a2, a0                      // mflo = offset to icon slot to use
        mflo    a2                          // a2 = offset to icon slot to use
        addu    t4, t4, a2                  // t4 = icon to use
        addiu   t7, t4, ICON_IMAGE_CHUNK_OFFSET // t7 = image chunk
        sw      t7, 0x0044(v1)              // set image chunk
        addiu   t7, t4, ICON_PALETTE_OFFSET // t7 = palette
        sw      t7, 0x0030(v1)              // set palette

        // Now update stolen_stocks
        lw      a2, 0x0034(sp)              // a2 = stolen port_id
        li      a1, character_queues
        sll     t7, a2, 0x0003              // t7 = index * 0x08
        sll     a2, a2, 0x0004              // a2 = index * 0x10
        addu    a2, a2, t7                  // a2 = offset to character queue
        addu    a1, a1, a2                  // a1 = character queue
        sll     a0, a0, 0x0002              // a0 = offset to slot
        addu    a0, a1, a0                  // a0 = character slot

        li      a2, stolen_stocks
        lw      a1, 0x0030(sp)              // a1 = thief port_id
        sll     a1, a1, 0x0002              // a1 = offset to stolen stock pointer
        addu    a2, a2, a1                  // a2 = stolen stock pointer
        sw      a0, 0x0000(a2)              // set stolen stock pointer

        // Now update stolen_icons
        li      a2, stolen_icons
        lw      a1, 0x0030(sp)              // a1 = thief port_id
        sll     a1, a1, 0x0003              // a1 = offset to stolen icon info
        addu    a2, a2, a1                  // a2 = stolen icon info
        lw      t7, 0x0044(v1)              // t7 = image chunk
        sw      t7, 0x0000(a2)              // set image chunk
        lw      t7, 0x0030(v1)              // t7 = palette
        sw      t7, 0x0004(a2)              // set palette

        _end:
        jr      ra
        lh      t4, 0x0014(v1)              // original line 2
    }

    scope css {
        // @ Description
        // Updates character queues after selected characters change in some way
        scope update_queue_: {
            // Runs after selecting a player with the token
            OS.patch_start(0x130030, 0x80131DB0)
            j       update_queue_._select_with_token
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            _return_select_with_token:
            lw      ra, 0x001C(sp)              // original line 1
            OS.patch_end()

            // Updates queue on costume change
            OS.patch_start(0x00136208, 0x80137F88)
            j       update_queue_._costume_change
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            _return_costume_change:
            OS.patch_end()

            // Updates queue when syncing fighter on panel
            OS.patch_start(0x1343E0, 0x80136160)
            sw      a0, 0x0014(sp)              // save a0 for later (replace nop in delay slot)
            OS.patch_end()
            OS.patch_start(0x00134468, 0x801361E8)
            j       update_queue_._fighter_sync
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            _return_fighter_sync:
            OS.patch_end()

            // Updates queue when toggling from teams to ffa
            OS.patch_start(0x1333FC, 0x8013517C)
            jal     update_queue_._toggle_to_ffa_check
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            OS.patch_end()
            OS.patch_start(0x133438, 0x801351B8)
            j       update_queue_._toggle_to_ffa
            addiu   s0, s0, 0x00BC              // original line 2
            _return_toggle_to_ffa:
            OS.patch_end()
            // Updates queue when toggling from ffa to teams
            OS.patch_start(0x133494, 0x80135214)
            jal     update_queue_._toggle_to_teams_check
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            OS.patch_end()
            OS.patch_start(0x1334B0, 0x80135230)
            lw      a0, 0x0008(s0)              // original line 2
            lw      a1, 0x004C(s0)              // original line 3
            jal     0x800E9248                  // original line 4
            or      a2, v0, r0                  // original line 5
            j       update_queue_._toggle_to_teams
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            _return_toggle_to_teams:
            OS.patch_end()

            // Updates queue when changing team
            OS.patch_start(0x1339B4, 0x80135734)
            jal     update_queue_._toggle_team_check
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            OS.patch_end()
            OS.patch_start(0x1339DC, 0x8013575C)
            j       update_queue_._toggle_team
            nop
            _return_toggle_team:
            OS.patch_end()


            _select_with_token:
            // s0 = gMnBattlePanels[held_port_id]
            // s1 = held_port_id
            // 0x0024(sp) = gMnBattlePanels[port_id]

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            bne     t0, t1, _end_select_with_token // if not Tag Team, skip
            nop

            or      a0, s0, r0                  // a0 = gMnBattlePanels[held_port_id]
            jal     update_slot_
            or      a1, s1, r0                  // a1 = held_port_id

            _end_select_with_token:
            lw      s0, 0x0014(sp)              // original line 2
            j       _return_select_with_token
            lw      s1, 0x0018(sp)              // original line 3

            _costume_change:
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            bne     t0, t1, _end_costume_change // if not Tag Team, skip
            nop

            or      a0, s0, r0                  // a0 = gMnBattlePanels[port_id]
            jal     update_slot_
            lw      a1, 0x0028(sp)              // a1 = port_id

            _end_costume_change:
            lw      ra, 0x001C(sp)              // original line 1
            j       _return_costume_change
            lw      s0, 0x0018(sp)              // original line 2

            _fighter_sync:
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            bne     t0, t1, _end_fighter_sync   // if not Tag Team, skip
            nop

            or      a0, s0, r0                  // a0 = gMnBattlePanels[port_id]
            jal     update_slot_
            lw      a1, 0x0014(sp)              // a1 = port_id
            lw      ra, 0x001C(sp)              // restore ra

            _end_fighter_sync:
            lw      s0, 0x0018(sp)              // original line 1
            j       _return_fighter_sync
            addiu   sp, sp, 0x0020              // original line 2

            _toggle_to_ffa_check:
            // do original check of checking a char_id is selected
            bne     s3, a0, _end_toggle_to_ffa_check // if not Character.id.NONE, then check costumes (modified original line 1)
            nop
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            beql    t0, t1, _toggle_to_ffa      // if Tag Team, always update costumes but skip updating selected char model
            addiu   s0, s0, 0x00BC              // need this since we branch from here instead of 0x801351B8
            // if here, then we apply the delay slot in the original beql and update ra to the branch's target address
            li      ra, 0x801351BC              // ra = target branch address in original line 1
            addiu   s1, s1, 0x0001              // original line 2

            _end_toggle_to_ffa_check:
            jr      ra
            nop

            _toggle_to_ffa:
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t1, _end_toggle_to_ffa   // if not Tag Team, skip
            nop

            addiu   a0, s0, -0x00BC             // a0 = gMnBattlePanels[port_id]
            jal     update_slot_
            or      a1, s1, r0                  // a1 = port_id

            addiu   a0, s0, -0x00BC             // a0 = gMnBattlePanels[port_id]
            or      a1, s1, r0                  // a1 = port_id
            jal     update_previous_icons_
            lli     a2, OS.FALSE                // a2 = is_teams = FALSE

            _end_toggle_to_ffa:
            j       _return_toggle_to_ffa
            addiu   s1, s1, 0x0001              // original line 1

            _toggle_to_teams_check:
            // do original check of checking a char_id is selected
            bne     s3, a0, _end_toggle_to_teams_check // if not Character.id.NONE, then check costumes (modified original line 1)
            nop
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            beq     t0, t1, _toggle_to_teams    // if Tag Team, always update costumes but skip updating selected char model
            nop
            // if here, then we apply the delay slot in the original beql and update ra to the branch's target address
            li      ra, 0x80135248              // ra = target branch address in original line 1
            addiu   s1, s1, 0x0001              // original line 2

            _end_toggle_to_teams_check:
            jr      ra
            nop

            _toggle_to_teams:
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            bne     t0, t1, _end_toggle_to_teams // if not Tag Team, skip
            nop

            or      a0, s0, r0                  // a0 = gMnBattlePanels[port_id]
            jal     update_slot_
            or      a1, s1, r0                  // a1 = port_id

            or      a0, s0, r0                  // a0 = gMnBattlePanels[port_id]
            or      a1, s1, r0                  // a1 = port_id
            jal     update_previous_icons_
            lli     a2, OS.TRUE                 // a2 = is_teams = TRUE

            _end_toggle_to_teams:
            j       _return_toggle_to_teams
            addiu   s1, s1, 0x0001              // original line 6

            _toggle_team_check:
            // do original check of checking a char_id is selected
            bne     a0, at, _end_toggle_team_check // if not Character.id.NONE, then check costumes (modified original line 1)
            lw      a1, 0x004C(s1)              // need this since we branch to _toggle_team
            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            beql    t0, t1, _toggle_team        // if Tag Team, always update costumes but skip updating selected char model
            lw      a0, 0x0008(s1)              // need this since we branch to _toggle_team
            // if here, then we apply the delay slot in the original beql and update ra to the branch's target address
            li      ra, 0x80135764              // ra = target branch address in original line 1

            _end_toggle_team_check:
            jr      ra
            nop

            _toggle_team:
            jal     0x800E9248                  // original line 1
            or      a2, v0, r0                  // original line 2

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t1, _end_toggle_team    // if not Tag Team, skip
            nop

            or      a0, s1, r0                  // a0 = gMnBattlePanels[port_id]
            jal     update_slot_
            or      a1, s0, r0                  // a1 = port_id

            or      a0, s1, r0                  // a0 = gMnBattlePanels[port_id]
            or      a1, s0, r0                  // a1 = port_id
            jal     update_previous_icons_
            lli     a2, OS.TRUE                 // a2 = is_teams = TRUE

            _end_toggle_team:
            j       _return_toggle_team
            nop
        }

        // @ Description
        // Updates a slot with the current selected character info
        // @ Arguments
        // a0 - gMnBattlePanels[port_id]
        // a1 - port_id
        scope update_slot_: {
            addiu   sp, sp, -0x0030             // allocate stack space
            sw      ra, 0x0028(sp)              // save registers
            sw      a0, 0x002C(sp)              // ~

            lw      t0, 0x0048(a0)              // t0 = char_id
            sw      t0, 0x001C(sp)              // save char_id
            lw      t1, 0x004C(a0)              // t1 = costume_id
            lw      t2, 0x0050(a0)              // t2 = shade_id

            li      v1, current_slot
            addu    v1, v1, a1                  // v1 = current slot address
            lbu     t3, 0x0000(v1)              // t3 = current slot

            li      at, character_queues
            sll     t4, a1, 0x0004              // t4 = port_id * 0x10
            sll     t5, a1, 0x0003              // t5 = port_id * 0x08
            addu    t4, t4, t5                  // t4 = offset to queue for port
            addu    at, at, t4                  // at = character queue for port
            sll     t4, t3, 0x0002              // t4 = offset to slot
            addu    at, at, t4                  // at = address of current slot

            sb      t0, 0x0000(at)              // set char_id
            sb      t1, 0x0001(at)              // set costume_id
            sb      t2, 0x0002(at)              // set shade_id

            lli     t4, Character.id.NONE
            beq     t0, t4, _end                // if no char, skip
            lli     t4, Character.id.SONIC
            bne     t0, t4, _update_icon_cache  // if not Sonic, skip
            li      t4, Sonic.classic_table     // yes, delay slot
            addu    t4, t4, a1                  // t4 = px is_classic
            lbu     t4, 0x0000(t4)              // t4 = is_classic
            sb      t4, 0x0003(at)              // update is_classic

            _update_icon_cache:
            // Now, cache the stock icon and palette
            li      at, icon_cache
            lli     t4, ICON_CACHE_PORT_SIZE    // t4 = ICON_CACHE_PORT_SIZE
            multu   t4, a1                      // mflo = ICON_CACHE_PORT_SIZE * port_id
            mflo    t5                          // t5 = offset to icon cache slots for port
            lli     t4, ICON_CACHE_SLOT_SIZE    // t4 = ICON_CACHE_SLOT_SIZE
            multu   t4, t3                      // mflo = offset to icon cache slot
            mflo    t4                          // t4 = offset to icon cache slot within block
            addu    t4, t5, t4                  // t4 = offset to icon cache slot
            addu    a1, at, t4                  // a1 = address of icon cache
            sw      a1, 0x0020(sp)              // save address of icon cache
            addiu   t4, a1, ICON_IMAGE_CHUNK_OFFSET // t4 = address of image chunk

            lw      t0, 0x0008(a0)              // t0 = player object
            lw      t0, 0x0084(t0)              // t0 = player struct
            lw      t0, 0x09C8(t0)              // t0 = attributes struct
            lw      t8, 0x0340(t0)              // t8 = ftSprites struct address
            lw      t0, 0x0000(t8)              // t0 = stock icon footer address
            lw      t0, 0x0034(t0)              // t0 = stock icon address
            lw      t1, 0x0000(t0)              // t1 = dimensions
            sw      t1, 0x0000(t4)              // save dimensions
            lw      t1, 0x0004(t0)              // t1 = ?
            sw      t1, 0x0004(t4)              // save ?
            sw      a1, 0x0008(t4)              // save pointer to texture
            lw      t1, 0x000C(t0)              // t1 = ?
            sw      t1, 0x000C(t4)              // save ?
            lw      a0, 0x0008(t0)              // a0 = stock icon texture address
            sw      t8, 0x0024(sp)              // save ftSprites struct address
            jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
            lli     a2, ICON_TEXTURE_SIZE       // a2 = size of stock icon texture

            lw      t8, 0x0024(sp)              // t8 = ftSprites struct address
            lw      t0, 0x0004(t8)              // t0 = palette array for stock icon
            lw      a0, 0x002C(sp)              // a0 = gMnBattlePanels[port_id]
            lw      t1, 0x004C(a0)              // t1 = costume_id
            sll     t1, t1, 0x0002              // t1 = offset to palette
            addu    t0, t0, t1                  // t0 = address of palette pointer
            lw      a0, 0x0000(t0)              // a0 = address of palette
            lw      a1, 0x0020(sp)              // a1 = address of icon cache
            addiu   a1, a1, ICON_PALETTE_OFFSET // a1 = address of icon cache palette
            jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
            lli     a2, ICON_PALETTE_SIZE       // a2 = size of stock icon palette

            // Find costume array in Character.default_costume.table for this char_id
            // Loop from 0 to 6 over the costume_ids in the array and bcopy the palettes
            li      at, Character.default_costume.table
            lw      t0, 0x001C(sp)              // t0 = char_id
            sll     t1, t0, 0x0003              // t1 = offset to default_costume array
            addu    at, at, t1                  // at = default_costume array
            lw      a1, 0x0020(sp)              // a1 = address of icon cache
            addiu   a1, a1, ICON_DEFAULT_PALETTES_OFFSET // a1 = address of first costume palette
            lli     t0, 0x0000                  // t0 = loop counter

            _loop:
            sw      t0, 0x0014(sp)              // save loop counter
            sw      at, 0x0018(sp)              // save default_costume array
            sw      a1, 0x0020(sp)              // save address of first costume palette
            lw      t8, 0x0024(sp)              // t8 = ftSprites struct address
            lw      t0, 0x0004(t8)              // t0 = palette array for stock icon
            lbu     t1, 0x0000(at)              // t1 = costume_id
            sll     t1, t1, 0x0002              // t1 = offset to palette
            addu    t0, t0, t1                  // t0 = address of palette pointer
            lw      a0, 0x0000(t0)              // a0 = address of palette
            jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
            lli     a2, ICON_PALETTE_SIZE       // a2 = size of stock icon palette
            lw      t0, 0x0014(sp)              // t0 = loop counter
            sltiu   t1, t0, 0x0006              // t1 = 1 if we aren't done looping
            beqz    t1, _yellow_costume         // if done looping, break out of loop
            lw      at, 0x0018(sp)              // at = default_costume address
            addiu   at, at, 0x0001              // at = next default_costume address
            lw      a1, 0x0020(sp)              // a1 = address of costume palette
            addiu   a1, a1, ICON_PALETTE_SIZE   // a1 = next costume palette address
            b       _loop
            addiu   t0, t0, 0x0001              // increment loop counter

            // Then find costume_id for yellow team last
            _yellow_costume:
            li      at, Teams.new_costume_table
            lw      t0, 0x001C(sp)              // t0 = char_id
            addu    at, at, t0                  // at = address of yellow team costume
            lbu     t1, 0x0000(at)              // t1 = costume_id, yellow team
            sll     t1, t1, 0x0002              // t1 = offset to palette
            lw      t8, 0x0024(sp)              // t8 = ftSprites struct address
            lw      t0, 0x0004(t8)              // t0 = palette array for stock icon
            addu    t0, t0, t1                  // t0 = address of palette pointer
            lw      a0, 0x0000(t0)              // a0 = address of palette
            lw      a1, 0x0020(sp)              // a1 = address of costume palette
            addiu   a1, a1, ICON_PALETTE_SIZE   // a1 = next costume palette address
            jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
            lli     a2, ICON_PALETTE_SIZE       // a2 = size of stock icon palette

            _end:
            lw      ra, 0x0028(sp)              // restore ra
            jr      ra
            addiu   sp, sp, 0x0030              // deallocate stack space
        }

        // @ Description
        // Updates previously selected slots' icons
        // @ Arguments
        // a0 - gMnBattlePanels[port_id]
        // a1 - port_id
        // a2 - is_teams
        scope update_previous_icons_: {
            addiu   sp, sp, -0x0030             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~
            sw      a1, 0x000C(sp)              // ~
            sw      a2, 0x0010(sp)              // ~

            li      v1, current_slot
            addu    v1, v1, a1                  // v1 = current slot address
            lbu     v1, 0x0000(v1)              // v1 = current slot
            sw      v1, 0x0014(sp)              // save current slot
            lli     t7, 0x0000                  // t7 = first slot
            _loop:
            beq     v1, t7, _end                // if at current slot, skip
            sw      t7, 0x0018(sp)              // save slot

            li      at, character_queues
            sll     t4, a1, 0x0004              // t4 = port_id * 0x10
            sll     t5, a1, 0x0003              // t5 = port_id * 0x08
            addu    t4, t4, t5                  // t4 = offset to queue for port
            addu    at, at, t4                  // at = character queue for port
            sll     t4, t7, 0x0002              // t4 = offset to slot
            addu    at, at, t4                  // at = address of current slot
            lbu     t0, 0x0000(at)              // t0 = char_id

            addiu   t2, r0, -0x0004             // t2 = default costume_id index minus 4
            bnezl   a2, pc() + 8                // if teams, use team as costume_id index
            lw      t2, 0x0040(a0)              // t2 = team_index
            lli     t3, 0x0003                  // t3 = yellow team index
            beq     t2, t3, _get_yellow_costume // if yellow team, use custom logic
            addiu   t2, t2, 0x0004              // t2 = costume_id index
            li      t4, Character.default_costume.table
            sll     t3, t0, 0x0003              // t3 = offset to default costume array
            addu    t4, t4, t3                  // t4 = default costume array
            b       _set_palette
            addu    t4, t4, t2                  // t4 = address of costume_id

            _get_yellow_costume:
            li      t4, Teams.new_costume_table
            addu    t4, t4, t0                  // t4 = address of costume_id

            _set_palette:
            lbu     t1, 0x0000(t4)              // t1 = costume_id
            bnezl   a2, _shade_adjust           // if teams, costume_id is good but need to adjust shade
            sb      t1, 0x0001(at)              // set costume_id

            // in FFA, shade is 0 and we need to adjust costume if a previous port has the same char_id
            sb      r0, 0x0002(at)              // set shade
            lli     t5, 0x0000                  // t5 = loop counter
            or      a2, at, r0                  // a2 = current slot address
            _ffa_loop:
            beql    t5, a1, _icons              // if we've reached our port, use the costume
            sb      t1, 0x0001(at)              // set costume_id
            lbu     a0, -0x0018(a2)             // a0 = previous port's char_id
            bne     a0, t0, _ffa_next           // if not the same char_id, skip
            addiu   t5, t5, 0x0001              // increment loop counter

            addiu   t4, t4, 0x0001              // t4 = address of next costume_id
            addiu   t2, t2, 0x0001              // t2 = next costume_id

            _ffa_next:
            addiu   a2, a2, -0x0018             // at = previous port's slot
            b       _ffa_loop
            lbu     t1, 0x0000(t4)              // t1 = costume_id

            _shade_adjust:
            // in Teams, we need to adjust shade if a teammate in a previous port has the same char_id
            lli     t5, 0x0000                  // t5 = loop counter
            lli     t1, 0x0000                  // t1 = shade to use
            or      a2, at, r0                  // a2 = current slot address
            lw      t6, 0x0040(a0)              // t6 = team index

            _teams_loop:
            beql    t5, a1, _icons              // if we've reached our port, use the shade
            sb      t1, 0x0002(at)              // set shade
            lbu     t4, -0x0018(a2)             // t4 = previous port's char_id
            addiu   t5, t5, 0x0001              // increment loop counter
            bne     t4, t0, _teams_next         // if not the same char_id, skip
            addiu   a0, a0, -0x00BC             // a0 = previous port's panel struct

            lw      t4, 0x0040(a0)              // t4 = previous port's team index
            beql    t4, t6, _teams_next         // if the same team, increment shade
            addiu   t1, t1, 0x0001              // t1 = next shade

            _teams_next:
            b       _teams_loop
            addiu   a2, a2, -0x0018             // a2 = previous port's slot

            _icons:
            li      at, icon_cache
            lli     t4, ICON_CACHE_PORT_SIZE    // t4 = ICON_CACHE_PORT_SIZE
            multu   t4, a1                      // mflo = ICON_CACHE_PORT_SIZE * port_id
            mflo    t5                          // t5 = offset to icon cache slots for port
            lli     t4, ICON_CACHE_SLOT_SIZE    // t4 = ICON_CACHE_SLOT_SIZE
            multu   t4, t7                      // mflo = offset to icon cache slot
            mflo    t4                          // t4 = offset to icon cache slot within block
            addu    t4, t5, t4                  // t4 = offset to icon cache slot
            addu    a1, at, t4                  // a1 = address of icon cache
            addiu   a0, a1, ICON_DEFAULT_PALETTES_OFFSET // a0 = address of palettes
            lli     t4, ICON_PALETTE_SIZE       // t4 = palette size
            multu   t4, t2                      // mflo = offset to palette to copy
            mflo    t4                          // t4 = offset to palette to copy
            addu    a0, a0, t4                  // a0 = address of palette to copy
            addiu   a1, a1, ICON_PALETTE_OFFSET // a1 = address of palette used for display
            jal     0x80035430                  // bcopy - copy from a0 to a1, size a2
            lli     a2, ICON_PALETTE_SIZE       // a2 = size of stock icon palette

            lw      a0, 0x0008(sp)              // a0 = gMnBattlePanels[port_id]
            lw      a1, 0x000C(sp)              // a1 = port_id
            lw      a2, 0x0010(sp)              // a2 = is_teams
            lw      v1, 0x0014(sp)              // v1 = current slot
            lw      t7, 0x0018(sp)              // t7 = slot
            b       _loop
            addiu   t7, t7, 0x0001              // increment slot

            _end:
            lw      ra, 0x0004(sp)              // restore ra
            jr      ra
            addiu   sp, sp, 0x0030              // deallocate stack space
        }

        // @ Description
        // Gets the stock count for the given port
        // @ Arguments
        // a0 - port_id
        // @ Returns
        // v0 - stock count
        scope get_stock_count_: {
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t0, 0x0004(sp)              // save registers
            sw      t1, 0x0008(sp)              // ~
            sw      t2, 0x000C(sp)              // ~

            OS.read_word(0x8013BD80, v0)        // v0 = stocks

            li      t0, StockMode.stockmode_table
            sll     t1, a0, 0x0002              // t1 = offset to stock mode for panel
            addu    t0, t0, t1                  // t0 = address of stock mode for panel
            lw      t0, 0x0000(t0)              // t0 = stock mode
            beqz    t0, _end                    // if stock mode is DEFAULT, then use stocks value from picker
            lli     t1, StockMode.mode.LAST
            li      t2, StockMode.stock_count_table // t2 = table with stock count
            beq     t0, t1, _end                // if Stock Mode == LAST, then use stocks value from picker
            addu    t0, t2, a0                  // a2 = address of stock count
            lbu     t0, 0x0000(t0)              // t0 = stock count
            sltu    t2, v0, t0                  // t2 = 1 if manual stock count is too high
            beqzl   t2, _end                    // if manual stock count is not too high, use it
            or      v0, t0, r0                  // v0 = stock count

            _end:
            lw      t0, 0x0004(sp)              // restore registers
            lw      t1, 0x0008(sp)              // ~
            lw      t2, 0x000C(sp)              // ~
            jr      ra
            addiu   sp, sp, 0x0010              // deallocate stack space
        }

        // @ Description
        // Moves the current_slot up 1
        // @ Arguments
        // a0 - port_id
        scope move_to_next_slot_: {
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~

            jal     get_stock_count_            // v0 = stocks
            nop

            lw      a0, 0x0008(sp)              // a0 = port_id
            li      at, current_slot
            addu    at, at, a0                  // v1 = current slot address
            lbu     t3, 0x0000(at)              // t3 = current slot

            beq     t3, v0, _end                // if on the last slot, skip incrementing slot
            sltu    t7, t3, v0                  // t7 = 1 if we're good to increment
            beqzl   t7, pc() + 8                // if we're past the last slot, set to last slot
            addiu   t3, v0, -0x0001             // t3 = last slot minus 1 (next line increments)
            addiu   t3, t3, 0x0001              // t3 = next slot
            sb      t3, 0x0000(at)              // update current slot

            _end:
            lw      ra, 0x0004(sp)              // restore registers
            jr      ra
            addiu   sp, sp, 0x0010              // deallocate stack space
        }

        // @ Description
        // Moves the current_slot up 1 when picking up the token
        scope move_to_next_slot_on_pickup: {
            OS.patch_start(0x1358BC, 0x8013763C)
            jal     move_to_next_slot_on_pickup
            addu    v0, v1, t6
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t3, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t3, _end                // if not Tag Team, skip
            lw      t0, 0x005C(v0)              // t0 = is_recalling
            bnez    t0, _end                    // if recalling, skip
            nop

            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~
            sw      v0, 0x000C(sp)              // ~

            jal     move_to_next_slot_
            or      a0, a1, r0                  // a0 = port_id

            lw      ra, 0x0004(sp)              // restore registers
            lw      a0, 0x0008(sp)              // ~
            lw      v0, 0x000C(sp)              // ~
            addiu   sp, sp, 0x0010              // deallocate stack space

            _end:
            jr      ra
            sw      a0, 0x007C(v0)              // original line 2
        }

        // @ Description
        // Checks for B button press when holding a token and removes the current slot's selection and moves back a slot
        // Also checks for A button press for recalling token
        // Runs after checking for B button press recall
        scope clear_slot_and_go_to_previous_slot_: {
            OS.patch_start(0x136920, 0x801386A0)
            j       clear_slot_and_go_to_previous_slot_
            lw      a1, 0x0028(sp)              // original line 1 - a1 = port_id
            _return:
            OS.patch_end()

            // t6 = panel info

            OS.read_word(VsRemixMenu.vs_mode_flag, v1) // v1 = vs_mode_flag
            lli     t4, VsRemixMenu.mode.TAG_TEAM
            bne     v1, t4, _end                // if not Tag Team, skip
            sw      t6, 0x002C(sp)              // save register
            lw      t4, 0x0024(sp)              // t4 = controller
            lhu     v1, 0x0002(t4)              // v1 = pressed button mask
            andi    t5, v1, Joypad.A            // t5 = 0 if A not pressed
            bnez    t5, _check_recall_with_a    // if A pressed, do recall check
            andi    t5, v1, Joypad.B            // t5 = 0 if B not pressed
            beqz    t5, _end                    // if B not pressed, skip
            lw      t4, 0x0080(t6)              // t4 = held port, or -1 if not holding
            bltz    t4, _end                    // if not holding a token, skip
            lli     t0, 0x00BC                  // t0 = size of player struct

            // if here, holding a token
            // need to make sure held token's panel is not disabled
            multu   t0, t4
            mflo    t0
            li      at, CharacterSelect.CSS_PLAYER_STRUCT
            addu    at, at, t0                  // at = held token css struct
            lw      t0, 0x0084(at)              // t0 = player type (0 - HMN, 1 - CPU, 2 - N/A)
            sltiu   t0, t0, 0x0002              // t0 = 1 if HMN or CPU
            beqz    t0, _end                    // if panel is disabled, skip
            nop

            li      t0, current_slot
            addu    t0, t0, t4                  // t0 = address of current slot
            lbu     t5, 0x0000(t0)              // t5 = current slot
            addiu   v1, t5, -0x0001             // v1 = previous slot
            bnezl   t5, _clear_slot             // if not at the first slot, decrement and clear
            sb      v1, 0x0000(t0)              // update current slot

            b       _end                        // if on first slot, no need to clear
            nop

            _clear_slot:
            sw      at, 0x0024(sp)              // save gMnBattlePanels[held_port_id]
            lui     v1, 0x1C00                  // v1 = 0x1C000000 = default slot value
            sll     at, t4, 0x0003              // at = held_token_id * 0x08
            sll     t0, t4, 0x0004              // t0 = held_token_id * 0x10
            addu    at, at, t0                  // at = held_token_id * 0x18 = offset to character queue
            li      t0, character_queues
            addu    t0, t0, at                  // t0 = character queue
            sll     at, t5, 0x0002              // at = offset to character slot
            addu    t0, t0, at                  // t0 = character slot
            sw      v1, 0x0000(t0)              // clear character slot

            lw      a0, 0x0024(sp)              // a0 = gMnBattlePanels[held_port_id]
            jal     update_slot_
            or      a1, t4, r0                  // a1 = held_port_id

            jal     FGM.play_                   // play sfx
            lli     a0, FGM.menu.CONFIRM

            _end:
            lw      t6, 0x002C(sp)              // restore registers
            lw      a1, 0x0028(sp)              // ~
            j       _return
            lw      v0, 0x005C(t6)              // original line 2

            _check_recall_with_a:
            jal     check_recall_with_a_
            or      a0, t6, r0                  // a0 = panel info
            b       _end
            nop
        }

        // @ Description
        // Checks if we can recall the token and recalls and advances the slot if so
        // @ Arguments
        // a0 - panel info
        // a1 - port_id
        scope check_recall_with_a_: {
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~
            sw      a1, 0x000C(sp)              // ~

            jal     0x80137F9C                  // mnIsHumanWithCharacterSelected(port_id)
            lw      a0, 0x000C(sp)              // a0 = port_id
            beqz    v0, _end                    // skip if not a human with a character selected
            lw      a0, 0x0008(sp)              // a0 = panel info
            lw      t0, 0x0054(a0)              // t0 = cursor state (0 if pointer, 1 if holding, 2 if not holding)
            lli     t1, 0x0002                  // t1 = not holding token state (happens when over portraits only)
            bne     t0, t1, _end                // if not hovering portraits with no token, skip
            lw      t0, 0x0060(a0)              // t0 = min_frames_elapsed_until_recall
            OS.read_word(0x8013BDCC, t1)        // t1 = frames elapsed
            slt     t0, t1, t0                  // t0 = 1 if just placed
            bnez    t0, _end                    // skip if just placed
            nop
            jal     move_to_next_slot_          // go to next slot
            lw      a0, 0x000C(sp)              // a0 = port_id
            jal     0x80137FF8                  // mnRecallToken(port_id)
            lw      a0, 0x000C(sp)              // a0 = port_id

            _end:
            lw      ra, 0x0004(sp)              // restore registers
            jr      ra
            addiu   sp, sp, 0x0010              // deallocate stack space
        }

        // @ Description
        // Adjusts current_slot for any ports with it set above the stock count when stock count changes
        scope adjust_current_slot_on_stock_count_change_: {
            OS.patch_start(0x132418, 0x80134198)
            j       adjust_current_slot_on_stock_count_change_
            addiu   sp, sp, -0x0038             // original line 1
            _return:
            lui     a0, 0x8014                  // original line 3
            lw      a0, 0xBD78(a0)              // original line 4
            nop
            OS.patch_end()

            sw      a0, 0x0038(sp)              // original line 2
            sw      ra, 0x0034(sp)              // original line 5

            // a0 - stock count

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t3, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t3, _end                // if not Tag Team, skip
            lli     t0, 0x0000                  // t0 = port
            li      at, current_slot
            li      t8, character_queues
            _loop:
            addu    t1, at, t0                  // t1 = current_slot address
            lbu     t3, 0x0000(t1)              // t3 = current slot
            sw      t3, 0x001C(sp)              // save current slot
            sltu    t2, t3, a0                  // t2 = 1 if we're not on a too high slot
            bnez    t2, _next                   // if we're not on a too high slot, skip
            lui     t2, 0x1C00                  // t2 = 0x1C000000 = default slot value

            sb      a0, 0x0000(t1)              // update current slot to stock count
            _inner_loop:
            beq     a0, t3, _next               // skip if we're on the max slot
            sll     t1, t3, 0x0002              // t1 = offset to slot to be cleared
            addu    t1, t8, t1                  // t1 = slot to be cleared
            sw      t2, 0x0000(t1)              // clear slot
            addiu   t3, t3, -0x0001             // t3 = previous slot
            bne     t3, a0, _inner_loop         // loop until we've reached the new current slot
            nop

            _next:
            sw      at, 0x0010(sp)              // save registers
            sw      t0, 0x0014(sp)              // ~
            sw      t8, 0x0018(sp)              // ~

            addu    t1, at, t0                  // t1 = current_slot address
            lbu     t3, 0x0000(t1)              // t3 = current slot
            lw      a0, 0x001C(sp)              // a0 = previous current slot value
            sltu    a0, t3, a0                  // a0 = 1 if the slot went down
            beqz    a0, _next_check_loop        // if the slot didn't go down, don't sync
            nop

            jal     0x80136128                  // mnBattleSyncFighterDisplay()
            or      a0, t0, r0                  // a0 = port

            _next_check_loop:
            lw      a0, 0x0038(sp)              // a0 = stock count
            lw      at, 0x0010(sp)              // load registers
            lw      t0, 0x0014(sp)              // ~
            lw      t8, 0x0018(sp)              // ~

            sltiu   t2, t0, 0x0003              // t2 = 1 if more to loop over
            addiu   t8, t8, 0x0018              // t8 = next character queue
            bnez    t2, _loop                   // loop over all ports
            addiu   t0, t0, 0x0001              // t0 = next port

            _end:
            j       _return
            nop
        }

        // @ Description
        // Prevent start without all slots filled in
        scope prevent_start_with_empty_slots_: {
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers

            // Loop over each panel and ensure it's enabled
            // Then loop over that port's character queues to make sure none are NONE, up to stock count
            li      at, CharacterSelect.CSS_PLAYER_STRUCT // at = css player struct
            li      t8, 0x0000                  // t8 = port_id
            li      t7, character_queues
            lli     t5, Character.id.NONE

            _loop:
            lw      t0, 0x0084(at)              // t0 = player type (0 - HMN, 1 - CPU, 2 - N/A)
            lli     t1, 0x0002                  // t1 = 2 = N/A
            beq     t0, t1, _next               // if N/A, skip
            nop

            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~
            sw      v0, 0x000C(sp)              // ~

            jal     get_stock_count_
            or      a0, t8, r0                  // a0 = port_id
            or      t6, v0, r0                  // t6 = stocks

            lw      ra, 0x0004(sp)              // restore registers
            lw      a0, 0x0008(sp)              // ~
            lw      v0, 0x000C(sp)              // ~
            addiu   sp, sp, 0x0010              // deallocate stack space

            sll     t6, t6, 0x0002              // t6 = offset to last slot
            addu    t0, t7, t6                  // t0 = last slot

            // We can trust that if the last slot is set, they all are
            lbu     t0, 0x0000(t0)              // t0 = last slot's char_id
            beql    t0, t5, _end                // if not set, exit with FALSE
            lli     v1, OS.FALSE                // v1 = FALSE

            _next:
            addiu   at, at, 0x00BC              // at = next css player struct
            addiu   t8, t8, 0x0001              // t8 = next port_id
            sltiu   t0, t8, 0x0004              // t0 = 1 if more to loop over
            bnez    t0, _loop                   // loop over all css player structs
            addiu   t7, t7, 0x0018              // at = next character_queue

            _end:
            lw      ra, 0x0004(sp)              // load registers
            jr      ra
            addiu   sp, sp, 0x0010              // deallocate stack space
        }

        // @ Description
        // Updates the stock icons above each panel
        // @ Arguments
        // a0 - icon object
        scope slot_icon_update_routine_: {
            lw      at, 0x0084(a0)              // at = css player struct
            lli     t1, 0x0001                  // t1 = 1 = hide
            lw      t0, 0x0084(at)              // t0 = player type (0 - HMN, 1 - CPU, 2 - N/A)
            sltiu   t0, t0, 0x0002              // t0 = 0 if N/A
            beqzl   t0, _end                    // if disabled, hide completely
            sw      t1, 0x007C(a0)              // hide
            sw      r0, 0x007C(a0)              // otherwise ensure it's shown

            // if here, not disabled, so hide any past stock value and set any icons that should be set
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers
            sw      a0, 0x0008(sp)              // ~

            jal     get_stock_count_
            lw      a0, 0x0050(a0)              // a0 = port_id

            lw      ra, 0x0004(sp)              // restore registers
            lw      a0, 0x0008(sp)              // ~
            addiu   sp, sp, 0x0010              // deallocate stack space

            lw      t1, 0x0074(a0)              // t1 = first icon image struct
            lli     t2, 0x0202                  // t2 = display on
            addiu   t3, r0, -0x0001             // t3 = icon index, minus 1
            _loop:
            slt     t4, t3, v0                  // t4 = 1 if still displayed
            beqzl   t4, pc() + 8                // if not still displayed, turn display off
            lli     t2, 0x0205                  // t2 = display off
            sh      t2, 0x0064(t1)              // update display

            lw      t7, 0x0068(a0)              // t7 = character queue
            addiu   t3, t3, 0x0001              // increment icon index
            sll     t5, t3, 0x0002              // t5 = offset to slot
            addu    t7, t7, t5                  // t7 = character slot
            lbu     t5, 0x0000(t7)              // t5 = char_id
            lui     t6, 0x3F80                  // t6 = 1.0F = default scale
            lli     t7, Character.id.NONE
            beql    t5, t7, _use_default        // if no character set, use default icon
            lw      t5, 0x0060(a0)              // t5 = default palette address
            lli     t7, Character.id.BOSS
            beql    t5, t7, pc() + 8            // if Master Hand, use smaller scale
            lui     t6, 0x3F20                  // t6 = 0.625F

            lw      t8, 0x0054(t1)              // t8 = icon cache
            addiu   t5, t8, ICON_PALETTE_OFFSET // t5 = cache palette address
            b       _set_icon
            addiu   t7, t8, ICON_IMAGE_CHUNK_OFFSET // t7 = cache image chunk address

            _use_default:
            lw      t7, 0x0064(a0)              // t7 = default image chunk address

            _set_icon:
            sw      t5, 0x0030(t1)              // set palette
            sw      t7, 0x0044(t1)              // set image chunk
            lh      t5, 0x0000(t7)              // t5 = width
            sh      t5, 0x0014(t1)              // set width
            lh      t5, 0x000C(t7)              // t5 = effective height
            sh      t5, 0x0016(t1)              // set height
            sh      t5, 0x003C(t1)              // set effective height
            sw      t6, 0x0018(t1)              // set scale x
            sw      t6, 0x001C(t1)              // set scale y

            lw      t1, 0x0008(t1)              // t1 = next icon image struct
            bnez    t1, _loop                   // loop over all icons
            nop

            _end:
            jr      ra
            nop
        }

        // @ Description
        // Makes token pickup faster to make things less clunky
        scope speed_up_token_pickup_: {
            OS.patch_start(0x135488, 0x80137208)
            jal     speed_up_token_pickup_
            addiu   v0, r0, 0x0001              // original line 2
            OS.patch_end()

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t1, _end                // if not Tag Team, skip
            lli     t3, 0x001E                  // t3 = original frames to wait before pickup

            lli     t3, 0x0002                  // t3 = frames to wait before pickup - FAST

            _end:
            jr      ra
            addu    t3, t2, t3                  // original line 1, modified to addu
        }

        // @ Description
        // Runs after CharacterSelect.setup_ and sets up Tag Team slot indicators
        scope setup_: {
            addiu   sp, sp, -0x0030             // allocate stack space
            sw      ra, 0x0004(sp)              // save registers

            OS.read_word(VsRemixMenu.vs_mode_flag, t0) // t0 = vs_mode_flag
            lli     t1, VsRemixMenu.mode.TAG_TEAM
            bne     t0, t1, _end                // if not Tag Team, skip
            nop

            Render.load_file(0x0019, file_0019_pointer) // load file with stock icon image used on 1p CSS into file_0019_pointer

            li      at, CharacterSelect.CSS_PLAYER_STRUCT // at = css player struct
            li      t7, character_queues
            li      t8, icon_cache
            sw      r0, 0x0018(sp)              // store port_id

            lui     s2, 0x42EA                  // s2 = y = 117
            sw      s2, 0x0008(sp)              // save y

            _loop:
            sw      at, 0x000C(sp)              // save css player struct address
            sw      t7, 0x002C(sp)              // save character_queues address
            sw      t8, 0x0028(sp)              // save icon_cache address
            lw      t0, 0x0018(at)              // t0 = panel object
            lw      t1, 0x0074(t0)              // t1 = panel image struct

            lli     a0, 0x1C                    // room
            lli     a1, 0x10                    // group
            OS.read_word(file_0019_pointer, a2)
            addiu   a2, a2, 0x0080              // a2 = image footer address
            li      a3, slot_icon_update_routine_ // routine
            lwc1    f0, 0x0058(t1)              // f0 = panel x
            lui     t2, 0x40A0                  // t2 = left padding (5)
            mtc1    t2, f2                      // f2 = left padding
            add.s   f0, f0, f2                  // f0 = ulx
            mfc1    s1, f0                      // s1 = ulx
            sw      s1, 0x0010(sp)              // save ulx
            lw      s2, 0x0008(sp)              // uly
            lbu     t1, 0x000C(at)              // t1 = team
            addiu   s3, r0, -0x0001             // color (WHITE)
            lli     s4, 0x00FF                  // shadow (BLACK)
            jal     Render.draw_texture_
            lui     s5, 0x3F80                  // scale

            lw      at, 0x000C(sp)              // at = css player struct address
            sw      at, 0x0084(v0)              // store in object
            lw      t7, 0x002C(sp)              // t7 = character_queues address
            sw      t7, 0x0068(v0)              // store in object
            lw      t0, 0x0074(v0)              // t0 = image struct
            lw      t8, 0x0028(sp)              // t8 = icon_cache address
            sw      t8, 0x0054(t0)              // store in image struct
            lw      t1, 0x0030(t0)              // t1 = palette address
            lw      t2, 0x0044(t0)              // t2 = texture chunk address
            sw      t1, 0x0060(v0)              // save default palette address
            sw      t2, 0x0064(v0)              // save default texture chunk address
            lw      t0, 0x0018(sp)              // t0 = port_id
            sw      t0, 0x0050(v0)              // save port_id

            or      a0, r0, v0                  // a0 = object
            sw      r0, 0x0014(sp)              // initialize loop counter

            _inner_loop:
            OS.read_word(file_0019_pointer, a1)
            addiu   a1, a1, 0x0080              // a1 = image footer address
            jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
            addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
            addiu   sp, sp, 0x0030              // restore stack space

            lw      t0, 0x000C(v0)              // t0 = previous icon
            lwc1    f0, 0x0058(t0)              // f0 = previous x
            lui     t2, 0x4120                  // t2 = left padding (10)
            mtc1    t2, f2                      // f2 = left padding
            add.s   f0, f0, f2                  // f0 = ulx
            swc1    f0, 0x0058(v0)              // set x
            lw      t1, 0x005C(t0)              // t1 = y
            sw      t1, 0x005C(v0)              // set y
            sw      r0, 0x0068(v0)              // for some reason this isn't zero'd out, but needs to be when we toggle off the icons
            lw      t0, 0x0054(t0)              // t0 = previous icon_cache slot
            addiu   t0, t0, ICON_CACHE_SLOT_SIZE // t0 = icon_cache slot
            sw      t0, 0x0054(v0)              // save icon_cache slot
            lli     t0, 0x0201                  // t0 = flags
            sh      t0, 0x0024(v0)              // set flags

            lw      t0, 0x0014(sp)              // t0 = loop counter
            addiu   t0, t0, 0x0001              // t0++
            sltiu   t1, t0, 0x0005              // t1 = 1 if we should continue looping
            sw      t0, 0x0014(sp)              // update loop counter
            bnez    t1, _inner_loop             // loop until 6 stock icons created
            lw      a0, 0x0004(v0)              // a0 = object

            jal     slot_icon_update_routine_   // update before first render
            nop

            lw      at, 0x000C(sp)              // at = css player struct address
            lw      t7, 0x002C(sp)              // t7 = character_queues address
            lw      t8, 0x0028(sp)              // t8 = icon_cache address

            _next:
            lw      t0, 0x0018(sp)              // t0 = port_id
            addiu   t1, t0, 0x0001              // t1 = next port_id
            addiu   at, at, 0x00BC              // at = next css player struct
            addiu   t7, t7, 0x0018              // at = next character_queue
            addiu   t8, t8, ICON_CACHE_PORT_SIZE // at = next icon_cache
            li      t0, CharacterSelect.CSS_PLAYER_STRUCT + (0xBC * 4)
            bne     at, t0, _loop               // loop over all css player structs
            sw      t1, 0x0018(sp)              // save port_id


            _end:
            lw      ra, 0x0004(sp)              // restore registers
            jr      ra
            addiu   sp, sp, 0x0030              // deallocate stack space
        }

        file_0019_pointer:
        dw 0
    }
}

} // __TAG_TEAM__
