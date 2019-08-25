// Stages.asm
if !{defined __STAGES__} {
define __STAGES__()
print "included Stages.asm\n"

// @ Description
// This file expands the stage select screen.

include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"
include "Texture.asm"

// list of instructions that read from the stage id (A press on versus stage select screen)
// they're in order (you're welcome)

scope Stages {

    // DONE
    // 800FC298 - reads from table at 0x8012C520, (stage file #, stage type #)
    // solution: change li @ 0x800FC29C to custom table by stage id
    // 800FC2CC - same as above
    // solution: same as above
    // 800FC2F0 - same as above
    // solution: same as above

    // DONE
    // 80104C14 - checks if this is a BTT/BTP stage or not
    // solution: add check for > than 28
    scope id_fix_1_: {
        OS.patch_start(0x00080424, 0x80104C24)
        j       id_fix_1_
        nop
        OS.patch_end()

        // Stage ID (v0) is greater than id.BTX_FIRST, check if it is less than
        // BTX_LAST as well to account for new stage IDs.
        sltiu   at, v0, id.BTX_LAST + 1      // ~
        beqz    at, _corrected               // adjust path as necessary
        nop

        _original:
        jal     0x801048F8                  // original line 1
        nop                                 // original line 2
        j       0x80104C2C                  // take original path back
        nop

        _corrected:
        j       0x80104C34                  // take corrected path
        nop
    }

    // DONE
    // 8010DA90 - check for id.PLANET_ZEBES (later followed by check for id.MUSHROOM_KINGDOM)
    // soltuion: do nothing, there's a default later

    // DONE
    // 801056D0 - this is actually of importance (lol), this is what function runs for each stage < 9
    //            (ie what you can access on the stage select screen by default) so "multiplayer"
    //            stages with function. jalr based on this
    // solution: either enforce hyrule id here copy the function table somewhere else
    scope id_fix_2_: {
        OS.patch_start(0x00080ED4, 0x801056D4)
        j       id_fix_2_
        nop
        _id_fix_2_return:
        OS.patch_end()

        OS.patch_start(0x00080EEC, 0x801056EC)
        lw      t9, 0x0000(t9)
        OS.patch_end()


        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // save t0

        li      t9, function_table          // original line 1 (modified)
        slti    at, v1, 0x0009              // original line 2
        slti    t0, v1, id.BTX_LAST + 1     // check upper bound
        bnez    t0, _return                 // if (stage id is NOT a new stage), skip
        nop
        lli     at, OS.TRUE                 // set at

        _return:
        lw      t0, 0x0004(sp)              // restore t0
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _id_fix_2_return            // return
        nop
    }

    // something something function funciton
    function_table:
    dw function.PEACHS_CASTLE
    dw function.SECTOR_Z
    dw function.CONGO_JUNGLE
    dw function.PLANET_ZEBES
    dw function.HYRULE_CASTLE
    dw function.YOSHIS_ISLAND
    dw function.DREAM_LAND
    dw function.SAFFRON_CITY
    dw function.MUSHROOM_KINGDOM

    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)
    dw OS.NULL                              // (handled elsewhere)

    dw function.CLONE                       // Deku Tree
    dw function.CLONE                       // First Destination
    dw function.CLONE                       // Ganon's Tower
    dw function.CLONE                       // Kalos Pokemon League
    dw function.CLONE                       // Pokemon Stadium
    dw function.CLONE                       // Skyloft
    dw function.CLONE                       // Smashville
    dw function.CLONE                       // WarioWare
    dw function.CLONE                       // Battlefield
    dw function.CLONE                       // Corneria City
    dw function.CLONE                       // Dr. Mario
	dw function.CLONE						// Cool Cool Mountain
	dw function.CLONE						// Dragon King
	dw function.CLONE						// Great Bay
	dw function.CLONE						// Fray' Stage
	dw function.CLONE						// Tower of Heaven
	

    // TODO
    // 80116AE0 - i have NO idea (v hacky memory access)
    // solution: probably enforce hyrule id, look more into this

    // TODO
    // 80116B84 - stage id shifted (as per usual) and then added to some parameter in a0
    //            this calculated value is stored at 0x18(a1) right before this
    // solution: enforce hyrule id(?)

    // TODO
    // 80116B98 - same as above except calculated value is not stored at 0x18(a1). lw t0, 0x8(t9) where t9
    //            is the calculated value. some arithmetic is then used on t0 which is stored at 0x0014(a1)
    // soltuion: enforce hyrule id(?)

    // ALSO: figure out what the fuck A1 is in the last two notes
    // ok so it looks to be a function specific to each stage (on DL it renders the background chars)

    // DONE
    // 80114C9C - checks if we're playing on a board the platforms stage (greater than 10) to see
    //            if gameset or failure should happen
    // solution: add check for greater than last btx as well
    scope id_fix_5_: {
        OS.patch_start(0x0009049C, 0x80114C9C)
        j       id_fix_5_
        nop
        nop
        _id_fix_5_return:
        OS.patch_end()


        slti    at, t6, 0x0011              // original line 1
        bnez    at, _take_branch            // original line 2 (modified)
        lui     a1, 0x8011                  // original line 3

        slti    at, t6, id.BTX_LAST + 1     // ~
        beqz    at, _take_branch            // account for new stage ids
        nop

        _continue:
        j       _id_fix_5_return            // don't take branch
        nop

        _take_branch:
        j       0x80114CC8                  // branch to take
        nop
    }

    // DONE    
    // 8013C2BC - same as above except does not alter gameset/failure. unsure of what this does
    // solution: same as above, probably won't hurt
    scope id_fix_6_: {
        OS.patch_start(0x000B6F90, 0x8013C2C0)
        j       id_fix_6_
        nop
        nop
        _id_fix_6_return:
        OS.patch_end()


        slti    at, v0, 0x0011              // original line 1
        bnez    at, _take_branch            // original line 2 (modified)
        nop 

        slti    at, v0, id.BTX_LAST + 1     // ~
        beqz    at, _take_branch            // account for new stage ids
        nop

        _continue:
        slti    at, v0, 0x001D              // original line 3
        j       _id_fix_6_return            // don't take branch
        nop

        _take_branch:
        slti    at, v0, 0x001D              // original line 3
        j       0x8013C2D0                  // branch to take
        nop
    }

    // @ Description
    // Textures for the SSS icons

    // default stages
    insert icon_peachs_castle,          "../textures/icon_peachs_castle.rgba5551"
    insert icon_sector_z,               "../textures/icon_sector_z.rgba5551"
    insert icon_congo_jungle,           "../textures/icon_congo_jungle.rgba5551"
    insert icon_planet_zebes,           "../textures/icon_planet_zebes.rgba5551"
    insert icon_hyrule_castle,          "../textures/icon_hyrule_castle.rgba5551"
    insert icon_yoshis_island,          "../textures/icon_yoshis_island.rgba5551"
    insert icon_dream_land,             "../textures/icon_dream_land.rgba5551"
    insert icon_saffron_city,           "../textures/icon_saffron_city.rgba5551"
    insert icon_mushroom_kingdom,       "../textures/icon_mushroom_kingdom.rgba5551"
    insert icon_dream_land_beta_1,      "../textures/icon_dream_land_beta_1.rgba5551"
    insert icon_dream_land_beta_2,      "../textures/icon_dream_land_beta_2.rgba5551"
    insert icon_how_to_play,            "../textures/icon_how_to_play.rgba5551"
    insert icon_mini_yoshis_island,     "../textures/icon_yoshis_island.rgba5551"
    insert icon_meta_crystal,           "../textures/icon_meta_crystal.rgba5551"
    insert icon_duel_zone,              "../textures/icon_duel_zone.rgba5551"
    insert icon_final_destination,      "../textures/icon_final_destination.rgba5551"
    insert icon_random,                 "../textures/icon_random.rgba5551"
    insert icon_btx,                    "../textures/icon_btx.rgba5551"

    // new stages
    insert icon_deku_tree,              "../textures/icon_deku_tree.rgba5551"
    insert icon_first_destination,      "../textures/icon_first_destination.rgba5551"
    insert icon_ganons_tower,           "../textures/icon_ganons_tower.rgba5551"
    insert icon_kalos_pokemon_league,   "../textures/icon_kalos_pokemon_league.rgba5551"
    insert icon_pokemon_stadium_2,      "../textures/icon_pokemon_stadium_2.rgba5551"
    insert icon_skyloft,                "../textures/icon_skyloft.rgba5551"
    insert icon_smashville,             "../textures/icon_smashville.rgba5551"
    insert icon_warioware,              "../textures/icon_warioware.rgba5551"
    insert icon_battlefield,            "../textures/icon_battlefield.rgba5551"
    insert icon_corneria_city,          "../textures/icon_corneria_city.rgba5551"
    insert icon_dr_mario,               "../textures/icon_dr_mario.rgba5551"
	insert icon_cool_cool_mountain,		"../textures/icon_cool_cool_mountain.rgba5551"
	insert icon_dragon_king,			"../textures/icon_dragon_king.rgba5551"
	insert icon_great_bay,				"../textures/icon_great_bay.rgba5551"
	insert icon_frays_stage,			"../textures/icon_frays_stage.rgba5551"
	insert icon_toh,					"../textures/icon_toh.rgba5551"
    

    // @ Description
    // Stage ID's. Used in various loading sequences.
    scope id {
        // original stages
        constant PEACHS_CASTLE(0x00)
        constant SECTOR_Z(0x01)
        constant CONGO_JUNGLE(0x02)
        constant PLANET_ZEBES(0x03)
        constant HYRULE_CASTLE(0x04)
        constant YOSHIS_ISLAND(0x05)
        constant DREAM_LAND(0x06)
        constant SAFFRON_CITY(0x07)
        constant MUSHROOM_KINGDOM(0x08)
        constant DREAM_LAND_BETA_1(0x09)
        constant DREAM_LAND_BETA_2(0x0A)
        constant HOW_TO_PLAY(0x0B)
        constant MINI_YOSHIS_ISLAND(0x0C)
        constant META_CRYSTAL(0x0D)
        constant DUEL_ZONE(0x0E)
        constant RACE_TO_THE_FINISH(0x0F)
        constant FINAL_DESTINATION(0x10)
        constant BTX_FIRST(0x11)
        constant BTT_MARIO(0x11)
        constant BTT_FOX(0x12)
        constant BTT_DONKEY_KONG(0x13)
        constant BTT_SAMUS(0x14)
        constant BTT_LUIGI(0x15)
        constant BTT_LINK(0x16)
        constant BTT_YOSHI(0x17)
        constant BTT_FALCON(0x18)
        constant BTT_KIRBY(0x19)
        constant BTT_PIKACHU(0x1A)
        constant BTT_JIGGLYPUFF(0x1B)
        constant BTT_NESS(0x1C)
        constant BTP_MARIO(0x1D)
        constant BTP_FOX(0x1E)
        constant BTP_DONKEY_KONG(0x1F)
        constant BTP_SAMUS(0x20)
        constant BTP_LUIGI(0x21)
        constant BTP_LINK(0x22)
        constant BTP_YOSHI(0x23)
        constant BTP_FALCON(0x24)
        constant BTP_KIRBY(0x25)
        constant BTP_PIKACHU(0x26)
        constant BTP_JIGGLYPUFF(0x27)
        constant BTP_NESS(0x28)
        constant BTX_LAST(0x28)

        // new stages
        constant DEKU_TREE(0x29)
        constant FIRST_DESTINATION(0x2A)
        constant GANONS_TOWER(0x2B)
        constant KALOS_POKEMON_LEAGUE(0x2C)
        constant POKEMON_STADIUM_2(0x2D)
        constant SKYLOFT(0x2E)
        constant SMASHVILLE(0x2F)
        constant WARIOWARE(0x30)
        constant BATTLEFIELD(0x31)
        constant CORNERIA_CITY(0x32)
        constant DR_MARIO(0x33)
		constant COOLCOOL(0x34)
		constant DRAGONKING(0x35)
		constant GREAT_BAY(0x36)
		constant FRAYS_STAGE(0x37)
		constant TOH(0x38)

        // not an actual id, some arbitary number Sakurai picked(?)
        constant RANDOM(0xDE)
    }


    // @ Description
    // type controls a branch that executes code for single player modes when 0x00 or skips that
    // entirely for 0x14. This branch can be found at 0x(TODO). (pulled from table @ 0xA7D20)
    scope type {
        constant PEACHS_CASTLE(0x14)
        constant SECTOR_Z(0x14)
        constant CONGO_JUNGLE(0x14)
        constant PLANET_ZEBES(0x14)
        constant HYRULE_CASTLE(0x14)
        constant YOSHIS_ISLAND(0x14)
        constant DREAM_LAND(0x14)
        constant SAFFRON_CITY(0x14)
        constant MUSHROOM_KINGDOM(0x14)
        constant DREAM_LAND_BETA_1(0x14)
        constant DREAM_LAND_BETA_2(0x14)
        constant HOW_TO_PLAY(0x00)
        constant MINI_YOSHIS_ISLAND(0x14)
        constant META_CRYSTAL(0x14)
        constant DUEL_ZONE(0x14)
        constant RACE_TO_THE_FINISH(0x00)
        constant FINAL_DESTINATION(0x00)
        constant BTP(0x00)
        constant BTT(0x00)
        constant CLONE(0x14)
    }

    // @ Descirption
    // Header file id for each stage (pulled from table @ 0xA7D20)
    scope header {
        // original stages
        constant PEACHS_CASTLE(0x0103)
        constant SECTOR_Z(0x0106)
        constant CONGO_JUNGLE(0x0105)
        constant PLANET_ZEBES(0x0101)
        constant HYRULE_CASTLE(0x0109)
        constant YOSHIS_ISLAND(0x0107)
        constant DREAM_LAND(0x00FF)
        constant SAFFRON_CITY(0x0108)
        constant MUSHROOM_KINGDOM(0x104)
        constant DREAM_LAND_BETA_1(0x0100)
        constant DREAM_LAND_BETA_2(0x0102)
        constant HOW_TO_PLAY(0x010B)
        constant MINI_YOSHIS_ISLAND(0x010E)
        constant META_CRYSTAL(0x10D)
        constant DUEL_ZONE(0x010C)
        constant RACE_TO_THE_FINISH(0x0127)
        constant FINAL_DESTINATION(0x010A)
        constant BTT_MARIO(0x010F)
        constant BTT_FOX(0x0110)
        constant BTT_DONKEY_KONG(0x0111)
        constant BTT_SAMUS(0x0112)
        constant BTT_LUIGI(0x0113)
        constant BTT_LINK(0x0114)
        constant BTT_YOSHI(0x0115)
        constant BTT_FALCON(0x0116)
        constant BTT_KIRBY(0x0117)
        constant BTT_PIKACHU(0x0118)
        constant BTT_JIGGLYPUFF(0x0119)
        constant BTT_NESS(0x011A)
        constant BTP_MARIO(0x011B)
        constant BTP_FOX(0x011C)
        constant BTP_DONKEY_KONG(0x011D)
        constant BTP_SAMUS(0x011E)
        constant BTP_LUIGI(0x011F)
        constant BTP_LINK(0x0120)
        constant BTP_YOSHI(0x0121)
        constant BTP_FALCON(0x0122)
        constant BTP_KIRBY(0x0123)
        constant BTP_PIKACHU(0x0124)
        constant BTP_JIGGLYPUFF(0x0125)
        constant BTP_NESS(0x0126)

        // new stages
        constant DEKU_TREE(0x0874)
        constant FIRST_DESTINATION(0x0877)
        constant GANONS_TOWER(0x087A)
        constant KALOS_POKEMON_LEAGUE(0x087D)
        constant POKEMON_STADIUM_2(0x0880)
        constant SKYLOFT(0x0883)
        constant SMASHVILLE(0x0886)
        constant WARIOWARE(0x0889)
        constant BATTLEFIELD(0x0871)
        constant CORNERIA_CITY(0x088C)
        constant DR_MARIO(0x088F)
		constant COOLCOOL(0x892)
		constant DRAGONKING(0x895)
		constant GREAT_BAY(0x89B)
		constant FRAYS_STAGE(0x898)
		constant TOH(0x89E)
    }

    scope function {
        constant PEACHS_CASTLE(0x8010B4AC)
        constant SECTOR_Z(0x80107FCC)
        constant CONGO_JUNGLE(0x80109FB4)
        constant PLANET_ZEBES(0x80108448)
        constant HYRULE_CASTLE(0x8010AB20)
        constant YOSHIS_ISLAND(0x80108C80)
        constant DREAM_LAND(0x801066D4)
        constant SAFFRON_CITY(0x8010B2EC)
        constant MUSHROOM_KINGDOM(0x80109C0C)


        // jal ra, t9 immediately to jr ra lol
        constant CLONE(0x801056F8)
    }

    constant ICON_WIDTH(48)
    constant ICON_HEIGHT(36)

    // Layout
    // Page 1
    // [00] [01] [02] [03] [04]
    // [05] [06] [07] [08] [09]
    //
    // Page 2
    // [0A] [0B] [0C] [0D] [0E]
    // [0F] [10] [11] [12] [13]
    //
    // Page 3
    // [14] [15] [16] [17] [18]
    // [19] [1A] [1B] [1C] [1D]
	// Page 4
	// [1E] [1F] [20] [21] [22]
    // [23] [24] [25] [26] [27]

    constant NUM_ROWS(2)
    constant NUM_COLUMNS(5)
    constant NUM_ICONS(NUM_ROWS * NUM_COLUMNS)

    // @ Description
    // Stage IDs in order
    // Viable Stage (Most Viable at the Top)
    stage_table:
    // page 1 (original stages)
    db id.PEACHS_CASTLE                     // 00
    db id.CONGO_JUNGLE                      // 01
    db id.HYRULE_CASTLE                     // 02
    db id.PLANET_ZEBES                      // 03
    db id.MUSHROOM_KINGDOM                  // 04
    db id.YOSHIS_ISLAND                     // 05
    db id.DREAM_LAND                        // 06
    db id.SECTOR_Z                          // 07
    db id.SAFFRON_CITY                      // 08
    db id.RANDOM                            // 09

    // page 2 (custom stages)
    db id.DEKU_TREE                         // 0A
    db id.GANONS_TOWER                      // 0B
    db id.KALOS_POKEMON_LEAGUE              // 0C
    db id.POKEMON_STADIUM_2                 // 0D
    db id.SKYLOFT                           // 0E
    db id.SMASHVILLE                        // 0F
    db id.WARIOWARE                         // 10
    db id.CORNERIA_CITY                     // 11
    db id.DR_MARIO                          // 12
    db id.RANDOM                            // 13

    // page 3 (custom and better 1P Stages)
    db id.FIRST_DESTINATION                 // 14
    db id.BATTLEFIELD                       // 15
	db id.COOLCOOL							// 16
	db id.DRAGONKING						// 17
	db id.GREAT_BAY							// 18
	db id.FRAYS_STAGE						// 19
	db id.TOH								// 1A
    db id.FINAL_DESTINATION                 // 1B
    db id.MINI_YOSHIS_ISLAND                // 1C
    db id.RANDOM                            // 1D
	
	// page 4 (the bad stages)
	db id.META_CRYSTAL                      // 1E
	db id.DUEL_ZONE                         // 1F
	db id.DREAM_LAND_BETA_1                 // 20
    db id.DREAM_LAND_BETA_2                 // 21
    db id.HOW_TO_PLAY                       // 22
	db id.RANDOM                            // 23
	
    OS.align(4)

    // @ Description
    // Coordinates of stage icons in vanilla Super Smash Bros.
    position_table:
    // row 0
    dw 035, 020                             // 00
    dw 085, 020                             // 01
    dw 135, 020                             // 02
    dw 185, 020                             // 03
    dw 235, 020                             // 04

    // row 2
    dw 035, 058                             // 05
    dw 085, 058                             // 06
    dw 135, 058                             // 07
    dw 185, 058                             // 08
    dw 235, 058                             // 0A

    // sorted by stage id
    icon_table:
    dw icon_peachs_castle                   // Peach's Castle
    dw icon_sector_z                        // Sector Z
    dw icon_congo_jungle                    // Congo Jungle
    dw icon_planet_zebes                    // Planet Zebes
    dw icon_hyrule_castle                   // Hyrule Castle
    dw icon_yoshis_island                   // Yoshi's Island
    dw icon_dream_land                      // Dream Land
    dw icon_saffron_city                    // Saffron City
    dw icon_mushroom_kingdom                // Musrhoom Kingdom
    dw icon_dream_land_beta_1               // Dream Land Beta 1
    dw icon_dream_land_beta_2               // Dream Land Beta 2
    dw icon_how_to_play                     // How to Play
    dw icon_mini_yoshis_island              // Mini Yoshi's Island
    dw icon_meta_crystal                    // Meta Crystal
    dw icon_duel_zone                       // Duel Zone
    dw icon_btx                             // Race to the Finish
    dw icon_final_destination               // Final Destination
    dw icon_btx                             // BTT Mario
    dw icon_btx                             // BTT Fox
    dw icon_btx                             // BTT DK
    dw icon_btx                             // BTT Samus
    dw icon_btx                             // BTT Luigi
    dw icon_btx                             // BTT Link
    dw icon_btx                             // BTT Yoshi
    dw icon_btx                             // BTT Falcon
    dw icon_btx                             // BTT Kirby
    dw icon_btx                             // BTT Pikachu
    dw icon_btx                             // BTT Jigglypuff
    dw icon_btx                             // BTT Ness
    dw icon_btx                             // BTP Mario
    dw icon_btx                             // BTP Fox
    dw icon_btx                             // BTP DK
    dw icon_btx                             // BTP Samus
    dw icon_btx                             // BTP Luigi
    dw icon_btx                             // BTP Link
    dw icon_btx                             // BTP Yoshi
    dw icon_btx                             // BTP Falcon
    dw icon_btx                             // BTP Kirby
    dw icon_btx                             // BTP Pikachu
    dw icon_btx                             // BTP Jigglypuff
    dw icon_btx                             // BTP Ness
    dw icon_deku_tree                       // Deku Tree
    dw icon_first_destination               // First Destination
    dw icon_ganons_tower                    // Ganon's Tower
    dw icon_kalos_pokemon_league            // Kalos Pokemon League
    dw icon_pokemon_stadium_2               // Pokemon Stadium 2
    dw icon_skyloft                         // Skyloft
    dw icon_smashville                      // Smashville
    dw icon_warioware                       // WarioWare
    dw icon_battlefield                     // Batlefield
    dw icon_corneria_city                   // Corneria City
    dw icon_dr_mario                        // Dr. Mario
	dw icon_cool_cool_mountain				// Cool Cool Mountain
	dw icon_dragon_king						// Dragon King
	dw icon_great_bay						// Great Bay
	dw icon_frays_stage						// Fray's Stage
	dw icon_toh								// Tower of Heaven

    // @ Description
    // Row the cursor is on
    row:
    dw 0

    // @ Description
    // column the cursor is on
    column:
    dw 0

    // @ Description
    // Toggle for frozen mode.
    frozen_mode:
    dw OS.FALSE

    // @ Description
    // Page number for the CSS
    page_number:
    dw 0x00000000

    constant NUM_PAGES(0x04)

    // @ Description
    // Disable original L and R button behavior [bit]
    OS.patch_start(0x0014FC54, 0x801340E4)
    lli     a0, 0x0202
    OS.patch_end()

    OS.patch_start(0x0014FD58, 0x801341E8)
    lli     a0, 0x0101
    OS.patch_end()

    // @ Description
    // Prevents series logo from being drawn on wood circle
    OS.patch_start(0x0014E418, 0x801328A8)
    jr      ra                              // return immediately
    nop
    OS.patch_end()

    // @ Description
    // Prevents the drawing of defaults icons
    OS.patch_start(0x0014E098, 0x80132528)
    jr      ra                              // return
    nop
    OS.patch_end()

    // @ Descirption
    // Prevents "Stage Select" texture from being drawn.
    OS.patch_start(0x0014DDF8, 0x80132288)
    jr      ra                              // return immediately
    nop
    OS.patch_end()

    // @ Descirption
    // Prevents the wooden circle from being drawn.
    OS.patch_start(0x0014DBB8, 0x80132048)
//  jr      ra                              // return immediately
//  nop
    OS.patch_end()

    // @ Description
    // Prevents stage name text from being drawn.
    OS.patch_start(0x0014E2A8, 0x80132738)
    jr      ra                              // return immediately
    nop
    OS.patch_end()

    // Modifies the x/y position of the models on the stage select screen.
    OS.patch_start(0x0014F514, 0x801339A4)
//  lwc1    f16,0x0000(v0)                  // original line 1 (f16 = (float) x)
//  swc1    f16,0x0048(a0)                  // original line 2
//  lwc1    f18,0x0004(v0)                  // original line 3 (f18 = (float) y)
//  swc1    f18,0x004C(a0)                  // original line 4
    lui     t8, 0x44C8                      // t8 = (float) 1600S
    sw      t8, 0x0048(a0)                  // x = 1600
    sw      t8, 0x004C(a0)                  // y = 1600
    nop
    OS.patch_end()

    // @ Description
    // These following functions are designed to fix get_header_ for RANDOM.
    scope random_fix_1_: {
        OS.patch_start(0x0014EF2C, 0x801333BC)
        j       random_fix_1_
        nop
        _random_fix_1_return:
        OS.patch_end()

        addiu   at, r0, 0x00DE                  // original line 1
        or      s0, a0, r0                      // original line 2

        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      v0, 0x0004(sp)                  // ~
        sw      ra, 0x0008(sp)                  // restore registers

        jal     get_stage_id_                   // v0 = stage_id
        nop
        move    a0, v0                          // a0 = stage_id

        lw      v0, 0x0004(sp)                  // ~
        lw      ra, 0x0008(sp)                  // restore registers
        addiu   sp, sp, 0x0010                  // deallocate stack space
        j       _random_fix_1_return            // return
        nop
    }

    scope random_fix_2_: {
        OS.patch_start(0x0014EFA4, 0x80133434)
        j       random_fix_2_
        nop
        _random_fix_2_return:
        OS.patch_end()

//      lli     at, 0x00DE                      // original line 1
//      beq     s0, at, 0x80133464              // original line 2

        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      ra, 0x0004(sp)                  // ~
        sw      v0, 0x0008(sp)                  // save registers

        jal     get_stage_id_                   // v0 = stage_id
        nop
        lli     at, 0x00DE
        beq     at, v0, _take_branch
        nop

        _default:
        lw      ra, 0x0004(sp)                  // ~
        lw      v0, 0x0008(sp)                  // restore registers
        addiu   sp, sp, 0x0010                  // deallocate stack
        j       _random_fix_2_return
        nop

        _take_branch:
        lw      ra, 0x0004(sp)                  // ~
        lw      v0, 0x0008(sp)                  // restore registers
        addiu   sp, sp, 0x0010                  // deallocate stack
        j       0x80133464                      // (from original line 2)
        nop
    }

    scope random_fix_3_: {
        OS.patch_start(0x0014E950, 0x80132DE0)
        j       random_fix_3_
        nop
        _random_fix_3_return:
        OS.patch_end()

//      bne     v1, at, 0x80132E18              // original line 1
//      lui     t0, 0x8013                      // original line 2

        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      ra, 0x0004(sp)                  // ~
        sw      v0, 0x0008(sp)                  // save registers

        jal     get_stage_id_                   // v0 = stage_id
        nop
        bne     at, v0, _take_branch
        nop

        _default:
        lw      ra, 0x0004(sp)                  // ~
        lw      v0, 0x0008(sp)                  // restore registers
        addiu   sp, sp, 0x0010                  // deallocate stack
        j       _random_fix_3_return            // return
        nop

        _take_branch:
        lw      ra, 0x0004(sp)                  // ~
        lw      v0, 0x0008(sp)                  // restore registers
        addiu   sp, sp, 0x0010                  // deallocate stack
        j       0x80132E18                      // (from original line 1)
        nop
    }

    // @ Description
    // Modifies the zoom of the model previews.
    scope set_zoom_: {
        OS.patch_start(0x0014ECE4, 0x80133174)
//      lwc1    f4, 0x0000(v1)              // original line 1
        j       set_zoom_
        or      v0, s0, r0                  // original line 2
        _set_zoom_return:
        OS.patch_end()

        addiu   sp, sp,-0x00010             // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // save registesr

        jal     get_stage_id_               // v0 = stage_id
        nop
        sll     v0, v0, 0x0002              // v0 = stage_id * sizeof(word)
        li      t0, zoom_table              // ~
        addu    t0, t0, v0                  // t0 = address of zoom
        lw      t0, 0x0000(t0)              // t0 = zoom
        mtc1    t0, f4                      // f4 = zoom
        swc1    f4, 0x0000(v1)              // update all zoom

        lw      ra, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _set_zoom_return
        nop
    }

    // @ Description
    // This functions modifies which header file is drawn based on stage_table
    scope get_header_: {
        OS.patch_start(0x0014E708, 0x80132B98)
        j       get_header_
        nop
        _get_header_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      ra, 0x0004(sp)                  // ~
        sw      t0, 0x0008(sp)                  // ~
        sw      v0, 0x000C(sp)                  // save registers

        jal     get_stage_id_                   // v0 = stage_id
        nop
        sll     v0, v0, 0x0003                  // t0 = offset << 3 (offset * 8)
        li      t0, stage_file_table            // ~
        addu    t0, v0, t0                      // t0 = address of header file

        addu    v1, t6, t7                      // original line 1
//      lw      a0, 0x0000(v1)                  // original line 2
        lw      a0, 0x0000(t0)                  // a0 - file header id

        lw      ra, 0x0004(sp)                  // ~
        lw      t0, 0x0008(sp)                  // ~
        lw      v0, 0x000C(sp)                  // resore registers
        addiu   sp, sp, 0x0010                  // deallocate stack space
        j       _get_header_return              // return
        nop
    }

    // @ Description
    // This functions modifies which preview type is used based on stage_table
    scope get_type_: {
        OS.patch_start(0x0014E720, 0x80132BB0)
        j       get_type_
        nop
        _get_type_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      ra, 0x0004(sp)                  // ~
        sw      t0, 0x0008(sp)                  // ~
        sw      v0, 0x000C(sp)                  // save registers

        jal     get_stage_id_                   // v0 = stage_id
        nop
        sll     v0, v0, 0x0003                  // t0 = offset << 3 (offset * 8)
        li      t0, stage_file_table            // ~
        addu    t0, v0, t0                      // t0 = address of header file
        addiu   t0, t0, 0x0004                  // t0 = address of type
        lw      t8, 0x0000(t0)                  // t8 = type

        lw      ra, 0x0004(sp)                  // ~
        lw      t0, 0x0008(sp)                  // ~
        lw      v0, 0x000C(sp)                  // resore registers
        addiu   sp, sp, 0x0010                  // deallocate stack space
        lui     at, 0x8013                      // original line 1
//      lw      t8, 0x0004(v1)                  // original line 2
        j       _get_type_return                // return
        nop
    }

    // @ Descirption
    // Draw stage icons to the screen
    scope draw_icons_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      t4, 0x0014(sp)              // ~
        sw      ra, 0x0018(sp)              // ~
        sw      at, 0x001C(sp)              // ~
        sw      t5, 0x0020(sp)              // ~
        sw      t6, 0x0024(sp)              // save registers

        _setup:
        lli     at, NUM_ICONS               // at = number of icons to draw
        li      t0, icon_table              // t0 = address of icon_table
        li      t1, position_table          // t1 = address of position_table
        lli     t2, 0x0000                  // t2 = index
        li      t3, stage_table             // t3 = address of stage_table
        lli     t5, NUM_ICONS               // ~
        li      t6, page_number             // ~
        lw      t6, 0x0000(t6)              // ~
        mult    t5, t6                      // ~
        mflo    t6                          // t6 = stage_table page offset
        addu    t3, t3, t6                  // t3 = stage_table + page offset

        _draw_icon:
        sltiu   at, t2, NUM_ICONS           // ~
        beqz    at, _end                    // check to stop drawing stage icons
        nop
        lw      a0, 0x0000(t1)              // a0 - ulx
        lw      a1, 0x0004(t1)              // a1 - uly
        addu    t4, t3, t2                  // t4 = address of stage_table[index]
        lbu     t4, 0x0000(t4)              // t4 = stage_id

        // this intereupts flow to check for random
        lli     at, id.RANDOM               // at = id.RANDOM
        bne     t4, at, _not_random         // if (stage_id != id.RANDOM), skip
        nop
        li      t4, icon_random             // ~
        b       _continue
        nop

        _not_random:
        sll     t4, t4, 0x0002              // t4 = stage_id * 4 (aka stage_id * sizeof(u32))
        addu    t4, t0, t4                  // t4 = address of icon_table + offset
        lw      t4, 0x0000(t4)              // t4 = address of image data

        _continue:
        li      a2, info                    // a2 - address of texture struct
        sw      t4, 0x00008(a2)             // update info image data
        jal     Overlay.draw_texture_       // draw icon
        nop

        _increment:
        addiu   t1, t1, 0x0008              // increment position_table
        addiu   t2, t2, 0x0001              // increment index
        b       _draw_icon                  // draw next icon
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      t4, 0x0014(sp)              // ~
        lw      ra, 0x0018(sp)              // ~
        lw      at, 0x001C(sp)              // ~
        lw      t5, 0x0020(sp)              // ~
        lw      t6, 0x0024(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop

        info:
        Texture.info(ICON_WIDTH, ICON_HEIGHT)
    }

    // @ Description
    // This replaces the previous the original draw cursor function. The new function draws based on
    // the Stages.row and Stages.column variables as well as the position_table. It also replaces
    // the cursor itself with a filled rectangle
    scope draw_cursor_: {

        // @ Descirption
        // Set original cursor position.
        OS.patch_start(0x0014E5C8, 0x80132A58)
        // not used, for documentation only
        OS.patch_end()

        // @ Descirption
        // (part of set cursor position)
        OS.patch_start(0x0014E5F4, 0x80132A84)
//      lui     at, 0x41B8                  // original line (at = (float cursor y))
        lui     at, 0xC800                  // at =  a very negative float
        OS.patch_end()

        // @ Descirption
        // (part of set cursor position)
        OS.patch_start(0x0014E62C, 0x80132ABC)
//      lui     at, 0x4274                  // original line (at = (float cursor y))
        lui     at, 0xC800                  // at =  a very negative float
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // save registesr

        // this block gets the position
        jal     get_index_                  // v0 = index
        nop
        sll     v0, v0, 0x0003              // v0 = index *= sizeof(position_table entry) = offset
        li      t0, position_table          // ~
        addu    t0, t0, v0                  // t0 = position_table + offset

        // this block selects color based of rectangle (based on frozen mode)
        li      at, frozen_mode             // ~
        lw      at, 0x0000(at)              // t0 = frozen mode
        beqz    at, _skip
        lli     a0, Color.low.RED           // a0 - fill color
        lli     a0, Color.low.BLUE          // a0 - fill color

        _skip:
        // this block draws the cursor (with a border of 2)
        jal     Overlay.set_color_          // fill color = RED
        nop
        lw      a0, 0x0000(t0)              // a0 - ulx
        addiu   a0, a0,-0x0002              // decrement ulx
        lw      a1, 0x0004(t0)              // a1 - uly
        addiu   a1, a1,-0x0002              // decrement uly
        lli     a2, ICON_WIDTH + 4          // a2 - width
        lli     a3, ICON_HEIGHT + 4         // a3 - height
        jal     Overlay.draw_rectangle_     // draw curso
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack sapce
        jr      ra                          // return
        nop
    }

    // @ Description
    // Temporary. Draws names of stages where the stage text usually appears.
    scope draw_names_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        // this block draws "19XX <version>"
        lli     a0, 232                     // a0 - ulx
        lli     a1, 130                     // a1 - uly
        li      a2, string_title            // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw string
        nop

        // this block draws "<stage_name>"
        jal     get_stage_id_               // v0 = stage_id
        nop
        lli     a0, id.RANDOM               // a0 = random
        beq     a0, v0, _end                // don't draw RANDOM
        nop
        sll     v0, v0, 0x0002              // v0 = offset = stage_id * 4
        lli     a0, 232                     // a0 - x
        lli     a1, 195                     // a1 - uly
        li      a2, string_table            // a2 = address of string_table
        addu    a2, a2, v0                  // a2 = address of string_table + offset
        lw      a2, 0x0000(a2)              // a2 - adress of string
        jal     Overlay.draw_centered_str_  // draw string
        nop

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        string_title:
        String.insert("Smash Remix")
    }

    scope draw_page_number_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        // this block draws ""<< Z Page   R >>""
        lli     a0, 160                     // a0 - x
        lli     a1, 100                     // a1 - uly
        li      a2, string_page             // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw string
        nop

        // TODO:
        // this block draws page number 
        li      a0, page_number             // ~
        lw      a0, 0x0000(a0)              // a0 - (int) page_number
        addiu   a0, a0, 0x0001              // make it normie readable
        jal     String.itoa_                // v0 = (string) page_number
        nop
        lli     a0, 160                     // a0 - x
        lli     a1, 100                     // a1 - uly
        move    a2, v0                      // a2 - address of string
//      jal     Overlay.draw_centered_str_  // draw string
        nop

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        string_page:
        String.insert("Previous Page: Z, Next Page: R")
    }

    // @ Descirption
    // Returns an index based on column and row
    // @ Returns
    // v0 - index
    scope get_index_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        li      t0, row                     // ~
        lw      t0, 0x0000(t0)              // t0 = row
        li      t1, column                  // ~
        lw      t1, 0x0000(t1)              // t1 = column
        lli     t2, NUM_COLUMNS             // t2 = NUM_COLUMNS
        multu   t0, t2                      // ~
        mflo    v0                          // v0 = row * NUM_COLUMNS
        addu    v0, v0, t1                  // v0 = row * NUM_COLUMNS + column

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // restre registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // returns a stage id based on cursor position
    // @ Returns
    // v0 - stage_id
    scope get_stage_id_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // save registers

        jal     get_index_                  // v0 = index
        nop
        li      t1, page_number             // ~
        lw      t1, 0x0000(t1)              // ~
        lli     t2, NUM_ICONS               // ~
        mult    t1, t2                      // multiply NUM_ICONS by page
        mflo    t1                          // ~
        addu    v0, v0, t1                  // add additional offset
        li      t0, stage_table             // t0 = address of stage table
        addu    t0, t0, v0                  // t0 = address of stage table + offset
        lbu     v0, 0x0000(t0)              // v0 = ret = stage_id

        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This is what Overlay.HOOKS_GO_HERE_ calls. It is the main() of Stages.asm
    scope run_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~
        sw      t0, 0x0018(sp)              // ~
        sw      t1, 0x001C(sp)              // ~
        sw      at, 0x0020(sp)              // save registers

        // TODO: reimplemnt frozen mode (?)
        // check for z/r press to toggle frozen mode
//      li      a0, Joypad.Z                // a0 - button mask
//      li      a2, Joypad.PRESSED          // a2 - type
//      jal     Joypad.check_buttons_all_   // v0 = l/r pressed
//      nop
//      beqz    v0, _draw                   // if not pressed, skip
//      nop
//      li      t0, frozen_mode             // t0 = address of frozen mode
//      lw      t1, 0x0000(t0)              // t1 = frozen_mode
//      xori    t1, t1, 0x0001              // 0 -> 1 or 1 -> 0
//      sw      t1, 0x0000(t0)
//      lli     a0, FGM.menu.TOGGLE         // a0 - fgm_id
//      jal     FGM.play_                   // play menu sound
//      nop

        jal     update_up_
        nop

        jal     update_down_
        nop

        jal     update_left_
        nop

        jal     update_right_
        nop

        jal     check_page_switch_
        nop

        _draw:
        jal     draw_cursor_                // draw selection cursor
        nop

        jal     draw_icons_                 // draw stage icons
        nop

        jal     draw_names_                 // draw stage names
        nop

        jal     draw_page_number_           // draw page number
        nop

        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // ~
        lw      t0, 0x0018(sp)              // ~
        lw      t1, 0x001C(sp)              // ~
        lw      at, 0x0020(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Switch Page (maybe)
    scope check_page_switch_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~
        sw      t0, 0x0018(sp)              // ~
        sw      t1, 0x001C(sp)              // ~
        sw      at, 0x0020(sp)              // save registers

        // check for R press (increment page)
        _page_up:
        li      a0, Joypad.R                // a0 - button mask
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = R pressed?
        nop
        beqz    v0, _page_down              // if r not pressed, skip
        nop
        li      t0, page_number             // ~
        lw      t1, 0x0000(t0)              // t1 = page number
        addiu   t1, t1, 0x0001              // increment page
        lli     at, NUM_PAGES               // ~
        beq     at, t1, _up_warp            // if page is too high, handle case with warp
        nop
        sw      t1, 0x0000(t0)              // store page (next page)
        b       _end_update                // don't check multiple page switches per frame
        nop

        _up_warp:
        sw      r0, 0x0000(t0)              //  reset to first page
        b       _end_update                 //  don't check multiple page switches per frame
        nop

        // check for Z press (decrement page)
        _page_down:
        li      a0, Joypad.Z                // a0 - button mask
        li      a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = z pressed?
        nop
        beqz    v0, _end                   // if z not pressed, skip
        nop
        li      t0, page_number             // ~
        lw      t1, 0x0000(t0)              // t1 = page number
        beqz    t1, _down_warp              // if page_number == 0, handle special case
        nop
        addiu   t1, t1,-0x0001              // decrement page
        sw      t1, 0x0000(t0)              // store page
        b       _end_update                 // skip _down_warp
        nop

        _down_warp:
        lli     t1, NUM_PAGES - 1           // ~
        sw      t1, 0x0000(t0)              // store page

        _end_update:
        li      t0, preview_is_outdated     // ~
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x0000(t0)              // mark previw as outdated

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // ~
        lw      t0, 0x0018(sp)              // ~
        lw      t1, 0x001C(sp)              // ~
        lw      at, 0x0020(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra
        nop
    }


    // @ Description
    // This boolean controls the drawing of previews (only drawn when out of date)
    preview_is_outdated:
    dw OS.FALSE

    // @ Description
    // Each of these is a former update_right_ funcitons by Sakurai. They are all disabled
    // except for update_right_ which has been modified to update stage preview when 
    // preview_is_outdated_ == OS.TRUE

    // right
    scope check_update_preview_: {
        OS.patch_start(0x0014FD70, 0x80134200)
        j       check_update_preview_
        nop
        _check_update_preview_return:
        lui     a1, 0x8013                  // original line 3
        addiu   a1, a1, 0x4BD8              // original line 4
//      lw      v1, 0x0000(a1)              // original line 5
        lli     v1, 0x0001                  // original line 5 (modified, v1 = spoofed cursor id)
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

//      beq     v0, r0, 0x801342F4          // original line 1
//      sw      v0, 0x0020(sp)              // original line 2
        li      t0, preview_is_outdated     // ~
        lw      t1, 0x0000(t0)              // ~
        beqz    t1, _skip_return            // branch based on preview_is_outdated
        sw      r0, 0x0000(t0)              // mark preview as updated

        _continue_return:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _check_update_preview_return
        nop

        _skip_return:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       0x801342F4
        nop
    }

    // left
    OS.patch_start(0x0014FC6C, 0x801340FC)
    b       0x801341E4                      // original line 1 (no longer a conditional branch)
    sw      v0, 0x0020(sp)                  // original line 2
    OS.patch_end()

    // down
    OS.patch_start(0x0014FB9C, 0x8013402C)
    b       0x801340E0                      // original line 1 (no longer a conditional branch)
    sw      v0, 0x0020(sp)                  // original line 2
    OS.patch_end()

    // up
    OS.patch_start(0x0014FAD0, 0x80133F60)
    b       0x80134010                      // original line 1 (no longer a conditional branch)
    sw      v0, 0x0020(sp)                  // original line 2
    OS.patch_end()

    // @ Description
    // The following update_<direction>_ functions update Stages.row/Stages.column. They also set
    // preview_is_outdated to OS.TRUE
    scope update_right_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      v0, 0x0018(sp)              // save registers

        // check for right on the stick
        lli     a0, Joypad.RIGHT             // a0 - enum left/right/down/up
        jal     Joypad.check_stick_          // v0 = right was pushed
        nop
        beqz    v0, _end                     // skip update
        nop

        li      t0, preview_is_outdated     // ~
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x0000(t0)              // mark preview outdated

        // check bounds
        li      t0, column                  // ~
        lw      t1, 0x0000(t0)              // t1 = column
        slti    at, t1, NUM_COLUMNS - 1     // if (column < NUM_COLUMNS - 1)
        bnez    at, _normal                 // then go to next colum
        nop

        // update cursor (go to first column)
        sw      r0, 0x0000(t0)              // else go to first column
        b       _end                        // skip to end
        nop

        // update cursor (go right one)
        _normal:
        addi    t1, t1, 0x0001              // t1 = column++
        sw      t1, 0x0000(t0)              // update column

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack sapce
        jr      ra                          // return
        nop
    }

    scope update_left_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // save registers

        // check for left  on the stick
        lli     a0, Joypad.LEFT             // a0 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = left was pushed
        nop
        beqz    v0, _end                    // skip update
        nop

        li      t0, preview_is_outdated     // ~
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x0000(t0)              // mark preview outdated


        // check bounds
        li      t0, column                  // ~
        lw      t1, 0x0000(t0)              // t1 = column
        bnez    t1, _normal                 // if (!first_column)
        nop

        // update cursor (go to last column)
        lli     t1, NUM_COLUMNS - 1         // ~
        sw      t1, 0x0000(t0)              // else go to last column
        b       _end                        // skip to end
        nop

        // update cursor (go left one)
        _normal:
        addi    t1, t1,-0x0001              // t1 = column--
        sw      t1, 0x0000(t0)              // update column

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack sapce
        jr      ra
        nop
    }

    scope update_down_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // save registers

        // check for down on the stick
        lli     a0, Joypad.DOWN             // a0 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = down was pushed
        nop
        beqz    v0, _end                    // skip update
        nop

        li      t0, preview_is_outdated     // ~
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x0000(t0)              // mark preview outdated

        // check bounds
        li      t0, row                     // ~
        lw      t1, 0x0000(t0)              // t1 = row
        slti    at, t1, NUM_ROWS - 1        // if (row < NUM_ROWS - 1)
        bnez    at, _normal                 // then go to next colum
        nop

        // update cursor (go to first row)
        sw      r0, 0x0000(t0)              // else go to first column
        b       _end                        // skip to end
        nop

        // update cursor (go down one)
        _normal:
        addi    t1, t1, 0x0001              // t1 = row++
        sw      t1, 0x0000(t0)              // update row

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack sapce
        jr      ra
        nop
    }

    scope update_up_: {
        OS.patch_start(0x0014FAD0, 0x80133F60)
        //j       update_up_
        //nop
        //_update_up_return:
        OS.patch_end()

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // save registers

        // check for up on the stick
        lli     a0, Joypad.UP               // a0 - enum left/right/down/up
        jal     Joypad.check_stick_         // v0 = up was pushed
        nop
        beqz    v0, _end                    // skip update
        nop

        li      t0, preview_is_outdated     // ~
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x0000(t0)              // mark preview outdated

        // check bounds
        li      t0, row                     // ~
        lw      t1, 0x0000(t0)              // t1 = row
        bnez    t1, _normal                 // if (!first_row)
        nop

        // update cursor (go to last row)
        lli     t1, NUM_ROWS - 1            // ~
        sw      t1, 0x0000(t0)              // else go to last row
        b       _end                        // skip to end
        nop

        // update cursor (go up one)
        _normal:
        addi    t1, t1,-0x0001              // t1 = row--
        sw      t1, 0x0000(t0)              // update row

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack sapce
        jr      ra                          // return 
        nop

    }

    // @ Description
    // Adds a stage to the random list if it's toggled on.
    // @ Arguments
    // a0 - address of entry (random stage entry)
    // a1 - stage id to add
    // @ Returns
    // v0 - bool was_added?
    // v1 - num_stages
    scope add_stage_to_random_list_: {
        addiu   sp, sp,-0x0010              // allocate stack sapce
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        // this block checks to see if a stage should be added to the table.
        _check_add:
        lli     v0, OS.FALSE                // v0 = false
        beqz    a0, _continue               // if entry is NULL, add stage
        lli     t0, OS.TRUE                 // set curr_value to true
        lw      t0, 0x0004(a0)              // t0 = curr_value

        _continue:
        li      v1, random_count            // ~
        lw      v1, 0x0000(v1)              // v1 = random_count
        beqz    t0, _end                    // end, return false and count
        nop

        // if the stage should be added, it is added here. count is also incremented here
        li      t0, random_count            // t0 = address of random_count
        lw      v1, 0x0000(t0)              // v1 = random_count
        sll     t1, v1, 0x0002              // t1 = offset = random_count * 4
        addiu   v1, v1, 0x0001              // v1 = random_count++
        sw      v1, 0x0000(t0)              // update random_count
        li      t0, random_table            // t0 = address of random_table
        addu    t0, t0, t1                  // t0 = random_table + offset
        sw      a1, 0x0000(t0)              // add stage
        lli     v0, OS.TRUE                 // v0 = true

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack sapce
        jr      ra                          // return
        nop
    }

    // @ Description
    // Macro to (maybe) add a stage to the random list.
    macro add_to_list(entry, stage_id) {
        li      a0, {entry}                 // a0 - address of entry
        lli     a1, {stage_id}              // a1 - stage id to add
        jal     add_stage_to_random_list_   // add stage
        nop
    }

    // @ Description
    // This function replaces the logic to convert the default cursor_id to a stage_id.
    // @ Returns
    // v0 - stage_id
    scope swap_stage_: {
        OS.patch_start(0x0014F774, 0x80133C04)
//      jal     0x80132430                  // original line 1
//      nop                                 // original line 2
        jal     swap_stage_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // save registers

        jal     get_stage_id_               // v0 = stage_id
        nop

        // this block checks if random is selected (if not stage_id is returned)
        // TODO: reimplement random
        _check_random:
        lli     t0, id.RANDOM               // t0 = id.RANDOM
        bne     v0, t0, _end                // if (stage_id != id.RANDOM), end
        nop

        li      t0, random_count            // ~
        lw      v1, 0x0000(t0)              // v1 = random count

        // TODO: reimplement random stage switch
//      sw      r0, 0x0000(t0)              // reset count
//      add_to_list(Toggles.entry_random_stage_peachs_castle, id.PEACHS_CASTLE)
//      add_to_list(Toggles.entry_random_stage_sector_z, id.SECTOR_Z)
//      add_to_list(Toggles.entry_random_stage_congo_jungle, id.CONGO_JUNGLE)
//      add_to_list(Toggles.entry_random_stage_planet_zebes, id.PLANET_ZEBES)
//      add_to_list(Toggles.entry_random_stage_hyrule_castle, id.HYRULE_CASTLE)
//      add_to_list(Toggles.entry_random_stage_yoshis_island, id.YOSHIS_ISLAND)
//      add_to_list(Toggles.entry_random_stage_dream_land, id.DREAM_LAND)
//      add_to_list(Toggles.entry_random_stage_saffron_city, id.SAFFRON_CITY)
//      add_to_list(Toggles.entry_random_stage_mushroom_kingdom, id.MUSHROOM_KINGDOM)
//      add_to_list(Toggles.entry_random_stage_duel_zone, id.DUEL_ZONE)
//      add_to_list(Toggles.entry_random_stage_final_destination, id.FINAL_DESTINATION)
//      add_to_list(Toggles.entry_random_stage_dream_land_beta_1, id.DREAM_LAND_BETA_1)
//      add_to_list(Toggles.entry_random_stage_dream_land_beta_2, id.DREAM_LAND_BETA_2)
//      add_to_list(Toggles.entry_random_stage_how_to_play, id.HOW_TO_PLAY)
//      add_to_list(Toggles.entry_random_stage_mini_yoshis_island, id.MINI_YOSHIS_ISLAND)
//      add_to_list(Toggles.entry_random_stage_meta_crystal, id.META_CRYSTAL)

        // this block loads from the random list using a random int
        move    a0, v1                      // a0 - range (0, N-1)
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        li      t0, random_table            // t0 = random_table
//      sll     v0, v0, 0x0002              // v0 = offset = random_int * 4
        addu    t0, t0, v0                  // t0 = random_table + offset
//      lw      v0, 0x0000(t0)              // v0 = stage_id
        lbu     v0, 0x0000(t0)              // v0 = stage_id
        b       _end                        // get a new stage id based off of random offset
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // TODO: reimplement random stage switch
    // @ Descirption
    // Table of stage IDs (as words, 32 bit values)
    //random_table:
    //fill 4 * 32                             // assumes there will never be more than 32 stages

    random_table:
    db id.PEACHS_CASTLE                     // 00
    db id.CONGO_JUNGLE                      // 01
    db id.HYRULE_CASTLE                     // 02
    db id.PLANET_ZEBES                      // 03
    db id.MUSHROOM_KINGDOM                  // 04
    db id.YOSHIS_ISLAND                     // 05
    db id.DREAM_LAND                        // 06
    db id.SECTOR_Z                          // 07
    db id.SAFFRON_CITY                      // 08

    // page 2 (custom stages)
    db id.DEKU_TREE                         // 0A
    db id.GANONS_TOWER                      // 0B
    db id.KALOS_POKEMON_LEAGUE              // 0C
    db id.POKEMON_STADIUM_2                 // 0D
    db id.SKYLOFT                           // 0E
    db id.SMASHVILLE                        // 0F
    db id.WARIOWARE                         // 10
    db id.CORNERIA_CITY                     // 11
    db id.DR_MARIO                          // 12

    // page 3 (custom and better 1P Stages)
    db id.FIRST_DESTINATION                 // 13
    db id.BATTLEFIELD                       // 14
	db id.COOLCOOL							// 15
	db id.DRAGONKING						// 16
	db id.GREAT_BAY							// 17
	db id.FRAYS_STAGE						// 18
	db id.TOH								// 19
    db id.FINAL_DESTINATION                 // 1A
    db id.MINI_YOSHIS_ISLAND                // 1B
	
	// page 4 (the bad stages)
	db id.META_CRYSTAL                      // 1C
	db id.DUEL_ZONE                         // 1D
	db id.DREAM_LAND_BETA_1                 // 1E
    db id.DREAM_LAND_BETA_2                 // 1F
    db id.HOW_TO_PLAY                       // 20
	
    OS.align(4)

    // @ Description
    // number of stages in random_table.
    //random_count:
    //dw 0
    
    random_count:
    dw 27

    // @ Description
    // This function fixes a bug that does not allow single player stages to be loaded in training.
    // SSB typically uses *0x800A50E8 to get the stage id. The stage id is then used to find the bg
    // file. This function switches gets a working stage id based on *0x800A50E8 and stores it in
    // expansion memory. That value is read from in two places
    scope training_id_fix_: {
        OS.patch_start(0x001145D0, 0x8018DDB0)
        addiu   sp, sp, 0xFFE8              // original line 3
        sw      ra, 0x0014(sp)              // original line 4
        jal     training_id_fix_
        nop
        OS.patch_end()

        OS.patch_start(0x0011462C, 0x8018DE0C)
        jal     training_id_fix_
        nop
        lui     t5, 0x8019                  // original line 3
        lui     t7, 0x8019                  // original line 4
        lbu     t3, 0x0001(t6)              // original line 5 modified
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        li      t0, 0x800A50E8              // ~
        lw      t0, 0x0000(t0)              // t0 = dereference 0x800A50E8
        lbu     t0, 0x0001(t0)              // t0 =  stage id
        li      t1, background_table        // t1 = stage id table (offset)
        addu    t1, t1, t0                  // t1 = stage id table + offset
        lbu     t0, 0x0000(t1)              // t0 = new working stage id
        li      t2, id                      // t2 = id
        sb      t0, 0x0000(t2)              // update stage id to working stage id

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        li      t6, id - 1                  // original line 1/2 modified
        jr      ra                          // return
        nop

        id:
        db 0x00                             // holds new stage id
        OS.align(4)
    }

    zoom_table:
    float32 0.4                         // Peach's Castle
    float32 0.2                         // Sector Z
    float32 0.5                         // Congo Jungle
    float32 0.4                         // Planet Zebes
    float32 0.3                         // Hyrule Castle
    float32 0.5                         // Yoshi's Island
    float32 0.4                         // Dream Land
    float32 0.4                         // Saffron City
    float32 0.2                         // Musrhoom Kingdom
    float32 0.5                         // Dream Land Beta 1
    float32 0.3                         // Dream Land Beta 2
    float32 0.5                         // How to Play
    float32 0.5                         // Mini Yoshi's Island
    float32 0.5                         // Meta Crystal
    float32 0.5                         // Duel Zone
    float32 0.5                         // Race to the Finish (Placeholder)
    float32 0.5                         // Final Deestination
    float32 0.5                         // BTT Mario
    float32 0.5                         // BTT Fox
    float32 0.5                         // BTT DK
    float32 0.5                         // BTT Samus
    float32 0.5                         // BTT Luigi
    float32 0.5                         // BTT Link
    float32 0.5                         // BTT Yoshi
    float32 0.5                         // BTT Falcon
    float32 0.5                         // BTT Kirby
    float32 0.5                         // BTT Pikachu
    float32 0.5                         // BTT Jigglypuff
    float32 0.5                         // BTT Ness
    float32 0.5                         // BTP Mario
    float32 0.5                         // BTP Fox
    float32 0.5                         // BTP DK
    float32 0.5                         // BTP Samus
    float32 0.5                         // BTP Luigi
    float32 0.5                         // BTP Link
    float32 0.5                         // BTP Yoshi
    float32 0.5                         // BTP Falcon
    float32 0.5                         // BTP Kirby
    float32 0.5                         // BTP Pikachu
    float32 0.5                         // BTP Jigglypuff
    float32 0.5                         // BTP Ness
    float32 0.5                         // Deku Tree
    float32 0.5                         // First Destination
    float32 0.2                         // Ganon's Tower
    float32 0.5                         // Kalos Pokemon League
    float32 0.5                         // Pokemon Stadium
    float32 0.5                         // Skyloft
    float32 0.5                         // Smashville
    float32 0.5                         // WarioWare
    float32 0.5                         // Batlefield
    float32 0.5                         // Corneria City
    float32 0.5                         // Dr. Mario
    float32 0.5                         // Cool Cool Mountain
    float32 0.5                         // Dragon King
	float32 0.5                         // Great Bay
    float32 0.5                         // Fray's Stage
	float32 0.5                         // Tower of Heaven

    background_table:
    db id.PEACHS_CASTLE                 // Peach's Castle
    db id.SECTOR_Z                      // Sector Z
    db id.CONGO_JUNGLE                  // Congo Jungle
    db id.PLANET_ZEBES                  // Planet Zebes
    db id.HYRULE_CASTLE                 // Hyrule Castle
    db id.YOSHIS_ISLAND                 // Yoshi's Island
    db id.DREAM_LAND                    // Dream Land
    db id.SAFFRON_CITY                  // Saffron City
    db id.MUSHROOM_KINGDOM              // Mushroom Kingdom
    db id.DREAM_LAND                    // Dream Land Beta 1
    db id.DREAM_LAND                    // Dream Land Beta 2
    db id.DREAM_LAND                    // How to Play
    db id.YOSHIS_ISLAND                 // Yoshi's Island (1P)
    db id.SECTOR_Z                      // Meta Crystal
    db id.SECTOR_Z                      // Batlefield
    db id.SECTOR_Z                      // Race to the Finish (Placeholder)
    db id.SECTOR_Z                      // Final Destination
    db id.SECTOR_Z                      // BTT Mario
    db id.SECTOR_Z                      // BTT Fox
    db id.SECTOR_Z                      // BTT DK
    db id.SECTOR_Z                      // BTT Samus
    db id.SECTOR_Z                      // BTT Luigi
    db id.SECTOR_Z                      // BTT Link
    db id.SECTOR_Z                      // BTT Yoshi
    db id.SECTOR_Z                      // BTT Falcon
    db id.SECTOR_Z                      // BTT Kirby
    db id.SECTOR_Z                      // BTT Pikachu
    db id.SECTOR_Z                      // BTT Jigglypuff
    db id.SECTOR_Z                      // BTT Ness
    db id.SECTOR_Z                      // BTP Mario
    db id.SECTOR_Z                      // BTP Fox
    db id.SECTOR_Z                      // BTP DK
    db id.SECTOR_Z                      // BTP Samus
    db id.SECTOR_Z                      // BTP Luigi
    db id.SECTOR_Z                      // BTP Link
    db id.SECTOR_Z                      // BTP Yoshi
    db id.SECTOR_Z                      // BTP Falcon
    db id.SECTOR_Z                      // BTP Kirby
    db id.SECTOR_Z                      // BTP Pikachu
    db id.SECTOR_Z                      // BTP Jigglypuff
    db id.SECTOR_Z                      // BTP Ness
    db id.PEACHS_CASTLE                 // Deku Tree
    db id.PEACHS_CASTLE                 // First Destination
    db id.SECTOR_Z                      // Ganon's Tower
    db id.SECTOR_Z                      // Kalos Pokemon League
    db id.SECTOR_Z                      // Pokemon Stadium
    db id.PEACHS_CASTLE                 // Skyloft
    db id.PEACHS_CASTLE                 // Smashville
    db id.SECTOR_Z                      // WarioWare
    db id.PEACHS_CASTLE                 // Battlefield
    db id.PEACHS_CASTLE                 // Corneria City
    db id.PEACHS_CASTLE                 // Dr. Mario
	db id.PEACHS_CASTLE                 // Cool Cool Mountain
	db id.PEACHS_CASTLE                 // Dragon King
	db id.PEACHS_CASTLE                 // Great Bay
	db id.PEACHS_CASTLE                 // Fray's Stage
	db id.SECTOR_Z						// Tower of Heaven
    OS.align(4)

    // @ Description
    // This instruction loads a hardcoded table. That table has been expanded below.
    OS.patch_start(0x00077A9C, 0x800FC29C)
    li      s0, stage_file_table
    OS.patch_end()

    stage_file_table:
    // header file, type
    dw header.PEACHS_CASTLE,          type.PEACHS_CASTLE
    dw header.SECTOR_Z,               type.SECTOR_Z
    dw header.CONGO_JUNGLE,           type.CONGO_JUNGLE
    dw header.PLANET_ZEBES,           type.PLANET_ZEBES
    dw header.HYRULE_CASTLE,          type.HYRULE_CASTLE
    dw header.YOSHIS_ISLAND,          type.YOSHIS_ISLAND
    dw header.DREAM_LAND,             type.DREAM_LAND
    dw header.SAFFRON_CITY,           type.SAFFRON_CITY
    dw header.MUSHROOM_KINGDOM,       type.MUSHROOM_KINGDOM
    dw header.DREAM_LAND_BETA_1,      type.DREAM_LAND_BETA_1
    dw header.DREAM_LAND_BETA_2,      type.DREAM_LAND_BETA_2
    dw header.HOW_TO_PLAY,            type.HOW_TO_PLAY
    dw header.MINI_YOSHIS_ISLAND,     type.MINI_YOSHIS_ISLAND
    dw header.META_CRYSTAL,           type.META_CRYSTAL
    dw header.DUEL_ZONE,              type.DUEL_ZONE
    dw header.RACE_TO_THE_FINISH,     type.RACE_TO_THE_FINISH
    dw header.FINAL_DESTINATION,      type.FINAL_DESTINATION
    dw header.BTT_MARIO,              type.BTT
    dw header.BTT_FOX,                type.BTT
    dw header.BTT_DONKEY_KONG,        type.BTT
    dw header.BTT_SAMUS,              type.BTT
    dw header.BTT_LUIGI,              type.BTT
    dw header.BTT_LINK,               type.BTT
    dw header.BTT_YOSHI,              type.BTT
    dw header.BTT_FALCON,             type.BTT
    dw header.BTT_KIRBY,              type.BTT
    dw header.BTT_PIKACHU,            type.BTT
    dw header.BTT_JIGGLYPUFF,         type.BTT
    dw header.BTT_NESS,               type.BTT
    dw header.BTP_MARIO,              type.BTP
    dw header.BTP_FOX,                type.BTP
    dw header.BTP_DONKEY_KONG,        type.BTP
    dw header.BTP_SAMUS,              type.BTP
    dw header.BTP_LUIGI,              type.BTP
    dw header.BTP_LINK,               type.BTP
    dw header.BTP_YOSHI,              type.BTP
    dw header.BTP_FALCON,             type.BTP
    dw header.BTP_KIRBY,              type.BTP
    dw header.BTP_PIKACHU,            type.BTP
    dw header.BTP_JIGGLYPUFF,         type.BTP
    dw header.BTP_NESS,               type.BTP
    dw header.DEKU_TREE,              type.CLONE
    dw header.FIRST_DESTINATION,      type.CLONE
    dw header.GANONS_TOWER,           type.CLONE
    dw header.KALOS_POKEMON_LEAGUE,   type.CLONE
    dw header.POKEMON_STADIUM_2,      type.CLONE
    dw header.SKYLOFT,                type.CLONE
    dw header.SMASHVILLE,             type.CLONE
    dw header.WARIOWARE,              type.CLONE
    dw header.BATTLEFIELD,            type.CLONE
    dw header.CORNERIA_CITY,          type.CLONE
    dw header.DR_MARIO,               type.CLONE
    dw header.COOLCOOL,				  type.CLONE
    dw header.DRAGONKING,             type.CLONE
	dw header.GREAT_BAY,              type.CLONE
    dw header.FRAYS_STAGE,            type.CLONE
	dw header.TOH,                    type.CLONE


    string_peachs_castle:;          String.insert("Peach's Castle")
    string_sector_z:;               String.insert("Sector Z")
    string_congo_jungle:;           String.insert("Congo Jungle")
    string_planet_zebes:;           String.insert("Planet Zebes")
    string_hyrule_castle:;          String.insert("Hyrule Castle")
    string_yoshis_island:;          String.insert("Yoshi's Island")
    string_dream_land:;             String.insert("Dream Land")
    string_saffron_city:;           String.insert("Saffron City")
    string_mushroom_kingdom:;       String.insert("Mushroom Kingdom")
    string_dream_land_beta_1:;      String.insert("Dream Land Beta 1")
    string_dream_land_beta_2:;      String.insert("Dream Land Beta 2")
    string_how_to_play:;            String.insert("How to Play")
    string_mini_yoshis_island:;     String.insert("Mini Yoshi's Island")
    string_meta_crystal:;           String.insert("Meta Crystal")
    string_duel_zone:;              String.insert("Duel Zone")
    string_final_destination:;      String.insert("Final Destination")
    string_btp:;                    String.insert("Board the Platforms")
    string_btt:;                    String.insert("Break the Targets")
    string_deku_tree:;              String.insert("Deku Tree")
    string_first_destination:;      String.insert("First Destination")
    string_ganons_tower:;           String.insert("Ganon's Tower")
    string_kalos_pokemon_league:;   String.insert("Kalos Pokemon League")
    string_pokemon_stadium_2:;      String.insert("Pokemon Stadium II")
    string_skyloft:;                String.insert("Skyloft")
    string_smashville:;             String.insert("Smashville")
    string_warioware:;              String.insert("WarioWare, Inc.")
    string_battlefield:;            String.insert("Battlefield")
    string_corneria_city:;          String.insert("Corneria City")
    string_dr_mario:;               String.insert("Dr. Mario")
	string_cool_cool_mountain:;		String.insert("Cool Cool Mountain")
	string_dragon_king:;			String.insert("Dragon King")
	string_great_bay:;				String.insert("Great Bay")
	string_frays_stage:;			String.insert("Fray's Stage")
	string_toh:;					String.insert("Tower of Heaven")

    string_table:
    dw string_peachs_castle
    dw string_sector_z
    dw string_congo_jungle
    dw string_planet_zebes
    dw string_hyrule_castle
    dw string_yoshis_island
    dw string_dream_land
    dw string_saffron_city
    dw string_mushroom_kingdom
    dw string_dream_land_beta_1
    dw string_dream_land_beta_2
    dw string_how_to_play
    dw string_mini_yoshis_island
    dw string_meta_crystal
    dw string_duel_zone
    dw string_dream_land                    // Race to the Finish (Placeholder)
    dw string_final_destination
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btt
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_btp
    dw string_deku_tree
    dw string_first_destination
    dw string_ganons_tower
    dw string_kalos_pokemon_league
    dw string_pokemon_stadium_2
    dw string_skyloft
    dw string_smashville
    dw string_warioware
    dw string_battlefield
    dw string_corneria_city
    dw string_dr_mario
	dw string_cool_cool_mountain
	dw string_dragon_king
	dw string_great_bay
	dw string_frays_stage
	dw string_toh

}

} // __STAGES__