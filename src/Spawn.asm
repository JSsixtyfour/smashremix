// Spawn.asm
if !{defined __SPAWN__} {
define __SPAWN__()
print "included Spawn.asm\n"

// @ Description
// This file alters spawn position for different circumstances such as Neutral Spawns.

include "Global.asm"
include "OS.asm"
include "Toggles.asm"
include "Stages.asm"

scope Spawn {

    // @ Description
    // hook to load respawn point. This fixes the lack of respawn points on the beta stages.
    scope load_respawn_point_: {
        OS.patch_start(0x000780B0, 0x800FC8B0)
        j       load_respawn_point_
        nop
        _load_respawn_point_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // save registers

        // this block gets stage_id (mode dependent)
        li      at, Global.match_info       // ~
        lw      at, 0x0000(at)              // at = address of match info
        lbu     at, 0x0001(at)              // at = stage_id

        // this block checks for dream land beta 1 and 2
        lli     t0, Stages.id.DREAM_LAND_BETA_1
        beq     t0, at, _fix
        nop
        lli     t0, Stages.id.DREAM_LAND_BETA_2
        beq     t0, at, _fix
        nop
        lli     t0, Stages.id.SECTOR_Z_REMIX
        beq     t0, at, _sector_z_remix
        nop

        _original:
        lh      t8, 0x0002(t7)              // original line 1
        mtc1    r0, f16                     // original line 2
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _load_respawn_point_return  // return
        nop

        _fix:
        sw      r0, 0x0000(a1)              // update x
        li      t0, 0x451DE000              // t0 = (float) 2526, from dream land
        sw      t0, 0x0004(a1)              // update y
        sw      r0, 0x0008(a1)              // update z
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // scrap the rest of the function
        nop

        _sector_z_remix:
        li      t0, 0x45cda000              // t0 = (float) 6580
        sw      t0, 0x0000(a1)              // update x
        li      t0, 0x4544e000              // t0 = (float) 3150
        sw      t0, 0x0004(a1)              // update y
        sw      r0, 0x0008(a1)              // update z
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // scrap the rest of the function
        nop
    }

    // Neutral Spawns (2 or 3 plat stages)

    //                   ________
    //
    //        ___S1___             ___S2___
    //
    //  _________S3___________________S4_________
    //  \_______________________________________/


    // Neutral Spawns (other stages)

    //
    //
    //
    //
    //  ______S1______S3_________S4______S2______
    //  \_______________________________________/

    scope load_spawn_: {
        // a0 holds player
        // a1 holds table
        // 0x0000(a1) holds x
        // 0x0004(a1) holds y

        OS.patch_start(0x00076764, 0x800FAF64)
        j       Spawn.load_spawn_
        nop
        _load_spawn_return:
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      v0, 0x0018(sp)              // ~
        sw      ra, 0x001C(sp)              // save registers

        // this block checks if we're in training mode
        li      t0, Global.current_screen
        lbu     t0, 0x0000(t0)              // t0 = screen_id
        ori     t1, r0, 0x0036              // ~
        bne     t0, t1, _check_versus       // branch if screen_id != training mode
        nop

        // since we're in training mode, this block determines if we'll use original spawn
        // or the custom spawn in the training struct
        li      t0, Training.struct.table   // t0 = training mode struct table address
        sll     t1, a0, 0x2                 // t1 = offset (port * 4)
        add     t1, t1, t0                  // t1 = struct table + offset
        lw      t3, 0x0000(t1)              // t3 = port struct address
        lw      a0, 0x0010(t3)              // a0 = spawn_id
        slti    t2, a0, 0x4                 // t2 = 1 if spawn_id > 0x4; else t2 = 0
        li      t0, original_table          // t0 = spawn table
        li      t1, Training.stage          // t1 = training mode stage address
        bnez    t2, _load_spawn             // branch if t2 != 0 (load original spawn for training stage)
        nop
        addiu   t0, t3, 0x0014              // t0 = spawn_pos address
        j       _set_spawn                  // set spawn to spawn in table
        nop

        // at this point we know we're not in training mode
        // this block checks if we're in vs mode
        // if we're not in versus mode, we'll get an original spawn
        _check_versus:
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen_id
        ori     t1, r0, 0x0016              // ~
        bne     t0, t1, _original_method    // branch if screen_id != vs mode (use original method of finding spawns)
        nop

        // at this point, we are sure we are in versus or training
        // the following toggle guard determines whether or not there is
        // a chance of getting a neutral spawn
        // (the branch to _guard and _toggle_off label allows bass to jump
        // forward on failure)
        b       _guard
        nop
        _toggle_off:
        b       _load_original
        nop

        _guard:
        // Neutral spawns are always enabled in TE. They are toggleable in CE.
        Toggles.guard(Toggles.entry_neutral_spawns, _toggle_off)

        _setup:
        li      t0, team_table              // t0 = team_table
        li      t1, type_table              // t1 = typeTable

        // the following block get's the team of every player (if applicable)
        // as well as the type (0 = man, 1 = cpu, 2 = n/a) of each player
        // and stores them in a table
        _p1:
        li      t2, Global.vs.p1            // ~
        lb      t3, 0x0004(t2)              // t3 = team
        sb      t3, 0x0000(t0)              // store team
        lb      t3, 0x0002(t2)              // t3 = type
        sb      t3, 0x0000(t1)              // store type
        _p2:
        li      t2, Global.vs.p2            // ~
        lb      t3, 0x0004(t2)              // t3 = team
        sb      t3, 0x0001(t0)              // store team
        lb      t3, 0x0002(t2)              // t3 = type
        sb      t3, 0x0001(t1)              // store type
        _p3:
        li      t2, Global.vs.p3            // ~
        lb      t3, 0x0004(t2)              // t3 = team
        sb      t3, 0x0002(t0)              // store team
        lb      t3, 0x0002(t2)              // t3 = type
        sb      t3, 0x0002(t1)              // store type
        _p4:
        li      t2, Global.vs.p4            // ~
        lb      t3, 0x0004(t2)              // t3 = team
        sb      t3, 0x0003(t0)              // store team
        lb      t3, 0x0002(t2)              // t3 = type
        sb      t3, 0x0003(t1)              // store type

        // this block checks if we're in teams
        // if not, we skip all teams related functions
        _doubles:
        li      t0, Global.vs.teams         // ~
        lb      t0, 0x0000(t0)              // t0 = teams
        beqz    t0, _singles                // if (!teams), skip
        nop

        // setup for teams loop
        li      t0, valid_teams             // t0 = valid_teams table
        li      t1, team_table              // t1 = team_table
        lw      t1, 0x0000(t1)              // t1 = teams

        // this block loops through to see if a valid team combination
        // has been found. if so, we'll get a neutral spawn. otherwise,
        // we'll get an original spawn
        _teams_loop:
        lw      t2, 0x0000(t0)              // t2 = team_setup
        beqz    t2, _load_original          // exit if combo not found
        nop
        bnel    t1, t2, _teams_loop         // if (not a match), skip
        addiu   t0, t0, 0x0008              // t0 = team_table++
        add     t0, t0, a0                  // t0 = valid_team + playerOffset
        lb      a0, 0x0004(t0)              // a0 = update_player
        b       _load_neutral
        nop

        // setup for singles loop
        // it's only checking for active vs inactive (cpu/player not important)
        _singles:
        li      t0, valid_singles           // t0 = valid_singles table
        li      t1, type_table              // t1 = type_table
        lw      t1, 0x0000(t1)              // t1 = teams
        li      t2, 0x02020202              // ~
        and     t1, t1, t2                  // mask so 0 = 0, 1 = 0, 2 = 2

        // this block checks if we're in a 1v1
        // if not, we will just load an original spawn
        _singles_loop:
        lw      t2, 0x0000(t0)              // t2 = single_setup
        beqz    t2, _load_original          // exit if combo not found
        nop
        bnel    t1, t2, _singles_loop       // ~
        addiu   t0, t0, 0x0008              // ~
        add     t0, t0, a0                  // ~
        lb      a0, 0x0004(t0)              // a0 = updatedPlayer

        // load neutral spawn for versus stage
        _load_neutral:
        li      t0, neutral_table           // t0 = neutral_table
        li      t1, Global.vs.stage         // t1 = address of stageID

        // TODO: handle all stages, then remove the next 4 lines
                                     // ...then use the original spawn method
        b       _load_spawn                 // don't get original table
        nop

        // load neutral spawn for versus stage
        _load_original:
        li      t0, original_table          // t0 = original_table
        li      t1, Global.vs.stage         // t1 = address of stageId

        _load_spawn:
        lbu     t1, 0x0000(t1)              // t1 = stageID
        sll     t1, t1, 0x0005              // t0 = stage offset
        add     t0, t0, t1                  // t0 = table + stage offset
        sll     t1, a0, 0x0003              // t1 = player offset
        add     t0, t0, t1                  // t1 = spawn to load address

        _set_spawn:
        lw      t1, 0x0000(t0)              // t1 = (int) xpos
        sw      t1, 0x0000(a1)              // update xpos
        lw      t1, 0x0004(t0)              // t1 = (int) xpos
        sw      t1, 0x0004(a1)              // update ypos

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return (we scrap the original function)
        nop

        _original_method:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x1368(t6)              // original line 2
        j       _load_spawn_return          // use in game method for everything but VS. and training
        nop

        team_table:
        db 0x00                             // p1 team
        db 0x00                             // p2 team
        db 0x00                             // p3 team
        db 0x00                             // p4 team

        type_table:
        db 0x00                             // p1 type
        db 0x00                             // p2 type
        db 0x00                             // p3 type
        db 0x00                             // p4 type

        // All possible team combinations (assumes two teams)
        // 0000
        // 0001
        // 0010
        // 0011 (valid)
        // 0100
        // 0101 (valid)
        // 0110 (valid)
        // 0111
        // 1000
        // 1001 (valid)
        // 1010 (valid)
        // 1011
        // 1100 (valid)
        // 1101
        // 1110
        // 1111

        valid_teams:
        // team 0 = spawns 00 and 02
        // team 1 = spawns 01 and 03

        // red vs blue
        dw 0x00000101, 0x00020103
        dw 0x00010001, 0x00010203
        dw 0x00010100, 0x00010302
        dw 0x01010000, 0x00020103
        dw 0x01000100, 0x00010203
        dw 0x01000001, 0x00010302

        // red vs green
        dw 0x00000202, 0x00020103
        dw 0x00020002, 0x00010203
        dw 0x00020200, 0x00010302
        dw 0x02020000, 0x00020103
        dw 0x02000200, 0x00010203
        dw 0x02000002, 0x00010302

        // blue vs green
        dw 0x01010202, 0x00020103
        dw 0x01020102, 0x00010203
        dw 0x01020201, 0x00010302
        dw 0x02020101, 0x00020103
        dw 0x02010201, 0x00010203
        dw 0x02010102, 0x00010302

        // red vs yellow
        dw 0x00000303, 0x00020103
        dw 0x00030003, 0x00010203
        dw 0x00030300, 0x00010302
        dw 0x03030000, 0x00020103
        dw 0x03000300, 0x00010203
        dw 0x03000003, 0x00010302

        // blue vs yellow
        dw 0x01010303, 0x00020103
        dw 0x01030103, 0x00010203
        dw 0x01030301, 0x00010302
        dw 0x03030101, 0x00020103
        dw 0x03010301, 0x00010203
        dw 0x03010103, 0x00010302

        // green vs yellow
        dw 0x02020303, 0x00020103
        dw 0x02030203, 0x00010203
        dw 0x02030302, 0x00010302
        dw 0x03030202, 0x00020103
        dw 0x03020302, 0x00010203
        dw 0x03020203, 0x00010302

        // null terminator
        dw 0x00000000, 0x00000000

        valid_singles:
        // pX vs pY
        dw 0x00000202, 0x0001FFFF
        dw 0x00020002, 0x00FF01FF
        dw 0x00020200, 0x00FFFF01
        dw 0x02020000, 0xFFFF0001
        dw 0x02000200, 0xFF00FF01
        dw 0x02000002, 0xFF0001FF

        // null terminator
        dw 0x00000000, 0x00000000

    }



    original_table:
    // 00 - Peach's Castle
    float32 -0210,  1574
    float32  0765,  1563
    float32  0300,  1515
    float32 -0840,  1526

    // 01 - Sector Z
    float32 -3301,  1869
    float32 -2094,  1708
    float32 -0898,  1593
    float32  0296,  1739

    // 02 - Kongo Jungle
    float32 -1739,  0002
    float32 -0630, -0210
    float32  0630, -0210
    float32  1739,  0002

    // 03 - Planet Zebes
    float32 -2556,  0572
    float32 -1137,  0011
    float32  0000,  0314
    float32  1745, -0262

    // 04 - Hyrule Castle
    float32 -2400,  1042
    float32 -1110,  1039
    float32  0240,  1042
    float32  1500,  1042

    // 05 - Yoshi's Island
    float32  0629, -0096
    float32  0090,  2409
    float32  0756,  1513
    float32 -0990,  1032

    // 06 - Dream Land
    float32  0000,  0006
    float32 -1397,  0906
    float32  0001,  1545
    float32  1421,  0909

    // 07 - Saffron City
    float32  1200,  0810
    float32 -0660, -0270
    float32  0510,  0090
    float32 -1200, -0270

    // 08 - Classic Mushroom Kingdom
    float32 -1800,  1318
    float32  1500,  0962
    float32 -1500,  0152
    float32  1800,  1807

    // 09 - Dream Land Beta 1
    float32  0954,  0150
    float32  1006,  0930
    float32 -0892,  0927
    float32 -0912,  0150

    // 0A - Dream Land Beta 2
    float32 -0450,  0150
    float32  0450,  0150
    float32  0000,  1701
    float32  1522,  0930

    // 0B - How to Play Stage
    float32  0660,  0000
    float32  1440,  0000
    float32 -0660,  0000                    // missing from stage file
    float32 -1440,  0000                    // missing from stage file

    // 0C - Yoshi's Island (1P)
    float32  0629, -0180
    float32  0090,  2085
    float32  0900,  1140
    float32 -0990,  0828

    // 0D - Meta Crystal
    float32 -0960,  0135
    float32 -0330,  0045
    float32  0525,  0030
    float32  1545,  0315

    // 0E - Duel Zone
    float32  0000,  0003
    float32  0000,  1803
    float32 -1170,  1022
    float32  1200,  1022

    // 0F - Race to the Finish (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 10 - Final Destination
    float32 -1800,  0005
    float32  1800,  0005
    float32 -0900,  0005
    float32  0900,  0005

    // 11 - BTT_MARIO (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 12 - BTT_FOX (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 13 - BTT_DONKEY_KONG (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 14 - BTT_SAMUS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 15 - BTT_LUIGI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 16 - BTT_LINK (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 17 - BTT_YOSHI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 18 - BTT_FALCON (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 19 - BTT_KIRBY (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1A - BTT_PIKACHU (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1B - BTT_JIGGLYPUFF (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1C - BTT_NESS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1D - BTP_MARIO (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1E - BTP_FOX (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1F - BTP_DONKEY_KONG (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 20 - BTP_SAMUS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 21 - BTP_LUIGI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 22 - BTP_LINK (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 23 - BTP_YOSHI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 24 - BTP_FALCON (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 25 - BTP_KIRBY (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 26 - BTP_PIKACHU (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 27 - BTP_JIGGLYPUFF (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 28 - BTP_NESS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 29 - DEKU TREE
    dw 0xC4142124, 0x42F28475
    dw 0x44876690, 0xC30E8E34
    dw 0xC5057791, 0x44B10000
    dw 0x4445FBBA, 0x44C3093B

    // 2A - FIRST DESTINATION
    float32 -1600,  0018
    float32  1612,  0018
    float32 -0422,  0018
    float32  0768,  0018

    // 2B - GANONS TOWER
    float32 -2200,  1954
    float32  1996,  1954
    float32 -1076,  1042
    float32  0902,  1042

    // 2C - KALOS POKEMON LEAGUE
    float32 -2371,  0921
    float32  2371,  0921
    float32 -1510,  0025
    float32  1510,  0025

    // 2D - POKEMON STADIUM
    float32 -1222,  0805
    float32  1222,  0805
    float32 -1222,  0035
    float32  1222,  0035

    // 2E - TALTAL
    float32 -1825,  0884
    float32  1825,  0884
    float32  0000,  1520
    float32  0000,  0010

    // 2F - GLACIAL RIVER
    float32 -1647,  0130
    float32  1647,  0130
    float32 -0764,  0955
    float32  0764,  0955

    // 30 - WARIOWARE
    float32 -1172,  0783
    float32  1172,  0783
    float32 -1172,  0035
    float32  1172,  0035

    // 31 - BATTLEFIELD
    float32 -1262,  0752
    float32  1262,  0752
    float32  0000,  1470
    float32  0000,  0035

    // 32 - Flat Zone
    float32 -1568, -0844
    float32 -0708, -0844
    float32  0138, -0844
    float32  1043, -0844

    // 33 - Dr. Mario
    float32 -1640,  1040
    float32  1640,  1040
    float32 -1640,  0100
    float32  1640,  0100

    // 34 - Cool Cool Mountain
    float32 -1546,  2206
    float32  1789,  2102
    float32 -1571,  0813
    float32  1315,  0805

    // 35 - Dragon King
    float32 -0650,  0035
    float32  0650,  0035
    float32 -0450,  0035
    float32  0450,  0035

    // 36 - Great Bay
    float32 -1013,  0511
    float32  1190,  0511
    float32 -2162, -0563
    float32  2083, -0545

    // 37 - Fray's Stage
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 38 - Tower of Heaven
    float32 -1495,  0851
    float32  1399,  0851
    float32  0000,  1550
    float32  0000,  0010

    // 39 - Fountain of Dreams
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 3A - Muda
    float32 -1250, -0450
    float32  1869,  1500
    float32  0210,  0675
    float32  0000,  1825

    // 3B - Mementos
    float32 -1996,  0335
    float32  2324,  0025
    float32 -1581,  1080
    float32  0972,  0025

    // 3C - Showdown
    float32 -2000,  0035
    float32  2000,  0035
    float32 -1000,  0035
    float32  1000,  0035

    // 3D - Spiral Mountain
    float32 -2080,  0880
    float32  2080,  0880
    float32 -1161,  0035
    float32  1161,  0035

    // 3E - N64
    float32 -3447,  1998
    float32  2564,  1953
    float32 -1732,  1125
    float32  0853,  1114

    // 3F - Mute City DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 40 - Mad Monster Mansion
    float32 -1847, -0294
    float32  1947, -0294
    float32 -1148,  0719
    float32  1300,  0719

    // 41 - Super Mario Bros. DL
    float32 -1262,  0932
    float32  1262,  0932
    float32  0000,  1569
    float32  0000,  0035

    // 42 - Super Mario Bros. O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 43 - Bowser's Stadium
    float32 -2020,  0005
    float32  2020,  0005
    float32 -1010,  0005
    float32  1010,  0005

    // 44 - Peach's Castle II
    float32 -2600,  1080
    float32  2600,  1080
    float32 -1545,  0298
    float32  1545,  0298

    // 45 - Delfino
    float32 -0800,  0047
    float32  0800,  0047
    float32 -1600,  0047
    float32  1600,  0047

    // 46 - Corneria
    float32 -3339,  1400
    float32  0885,  1995
    float32 -2042,  1212
    float32 -0320,  1200

    // 47 - Kitchen
    float32 -1200,  2250
    float32  1200,  2250
    float32 -0600,  2250
    float32  0600,  2250

    // 48 - Big Blue
    float32 -1700,  2410
    float32  1834,  2102
    float32 -0238,  2150
    float32  0825,  2228

    // 49 - Onett
    float32 -2292,  2043
    float32  1792,  2413
    float32 -3144,  3017
    float32  1426,  3678

    // 4A - Zebes Landing
    float32 -2654,  0041
    float32  1124,  0033
    float32 -2153,  1121
    float32  -578,  1215

    // 4B - Frosty Village
    float32 -2439,  2426
    float32  1626,  1324
    float32 -0672,  1156
    float32  2953,  0117

    // 4C - SMASHVILLE
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0800,  0035
    float32  0800,  0035

    // 4D - BTT_DRM
    float32 -1657, -2638
    float32 -1657, -2638
    float32 -1657, -2638
    float32 -1657, -2638

    // 4E - BTT_GND
    float32  1705,  0661
    float32  1705,  0661
    float32  1705,  0661
    float32  1705,  0661

    // 4F - BTT_YL
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035

    // 50 - Battlefield DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 51 - BTT_DS
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035

    // 52 - BTT_STAGE 1
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 53 - BTT_FALCO
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 54 - BTT_WARIO
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 55 - HYRULE TEMPLE
    float32 -2799,  0496
    float32  2846, -0006
    float32 -0647,  2086
    float32  0665, -0731

    // 56 - BTT_LUCAS
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 57 - BTP_GND
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 58 - New Pork City
    float32 -1990,  0971
    float32  1990,  0971
    float32 -2575,  1772
    float32  2575,  1772

    // 59 - Dark Samus BTP
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 5A - Smashketball
    float32 -3042,  0005
    float32  3042,  0005
    float32 -1615,  0005
    float32  1615,  0005

    // 5B - BTP_DRM
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 5C - Norfair
    float32 -1645,  0709
    float32  1000,  0954
    float32 -1105, -0213
    float32  1775,  0111

	// 5D - CORNERIA CITY
    float32 -1685,  1700
    float32  1685,  1700
    float32 -0740,  1100
    float32  0740,  1100

	// 5E - Congo Falls
    float32 -1000,  0915
    float32  1000,  0915
    float32 -1000,  0125
    float32  1000,  0125

	// 5F - Osohe
    float32 -3443,  1358
    float32  3443,  1358
    float32 -1778,  0023
    float32  1778,  0023

	// 60 - Yoshi's Story II
    float32  1594,  0900
    float32 -1594,  0900
    float32  0000,  0035
    float32  0000,  1580

	// 61 - World 1-1
    float32 -1590, -1150
    float32  1590, -1150
	float32 -0530, -1150
    float32  0530, -1150

	// 62 - Flat Zone II
    float32 -1980, -1685
    float32  1980, -1685
    float32 -0660, -1685
    float32  0660, -1685

	// 63 - Gerudo Valley
    float32 -0484,  0915
    float32  1310,  1135
    float32  1310,  0020
    float32 -1310,  0020

	// 64 - Young Link Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 65 - Falco Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 66 - Polygon Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 67 - Hyrule Castle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 68 - Hyrule Castle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 69 - Congo Jungle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 6A - Congo Jungle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 6B - Peach's Castle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 6C - Peach's Castle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 6D - Wario Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 6E - Fray's Stage - Night
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

	// 6F - Goomba Road
    float32 -1400,  0005
    float32  1400,  0005
    float32 -1400,  1547
    float32  1400,  1547

	// 70 - Lucas Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 71 - Sector Z DL
    float32 -1400,  2656
    float32  1400,  2659
    float32  0000,  3295
    float32  0000,  1756

	// 72 - Saffron City DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

	// 73 - Yoshi's Island DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

	// 74 - Zebes DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

	// 75 - Sector Z Omega
    float32 -1831,  1785
    float32  1831,  1785
    float32 -0915,  1785
    float32  0915,  1785

	// 76 - Saffron City Omega
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 77 - Yoshi's Island Omega
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 78 - Dream Land Omega
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 79 - Planet Zebes Omega
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 7A - Bowser Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 7B - Bowser Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 7C - Bowser's Keep
    float32 -1470,  0550
    float32  1470,  0550
    float32 -2430,  1380
    float32  2430,  1380

    // 7D - Rith Essa
    float32 -3353,  1190
    float32  3722,  1190
    float32 -1723,  0066
    float32  2113,  0043

    // 7E - Venom
    float32 -1719,  1827
    float32  1719,  1827
    float32 -1719,  0283
    float32  1719,  0283

    // 7F - Wolf Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 80 - Wolf Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 81 - Conker Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 82 - Conker Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 83 - Windy
    float32 -2510,  2170
    float32  1480,  0720
    float32 -1380,  2170
    float32  0000,  0720

    // 84 - dataDyne
    float32 -0800, -0150
    float32  0800, -0150
    float32 -1700,  0660
    float32  1700,  0660

    // 85 - Planet Clancer
    float32 -1500,  0905
    float32  1500,  0905
    float32 -0750,  0005
    float32  0750,  0005

    // 86 - Jungle Japes
    float32 -2650,  0090
    float32  2650,  0090
    float32 -1035, -0240
    float32  1035, -0240

    // 87 - Marth Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 88 - Gameboy Land
    float32 -1250, -0450
    float32  1869,  1500
    float32  0210,  0675
    float32  0000,  1825

    // 89 - Mewtwo Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8A - Marth Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8B - Allstar Rest Area
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8C - Mewtwo Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8D - Castle Siege
    float32 -1100,  1580
    float32  1390,  1955
    float32 -1500,  0650
    float32  1000,  0940

    // 8E - Yoshi's Island II
    float32 -1605,  0140
    float32  1605,  0140
    float32 -0600,  0100
    float32  0600,  0100

    // 8F - Final Destination DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 90 - Final Destination Tent
    float32 -1800,  0005
    float32  1800,  0005
    float32 -0900,  0005
    float32  0900,  0005

    // 91 - Cool Cool Mountain Remix
    float32 -1400,  0930
    float32  1400,  0930
    float32 -1900,  2000
    float32  1900,  2000

    // 92 - Duel Zone DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 93 - Cool Cool Mountain DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 94 - Meta Crystal DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 95 - Dream Greens
    float32 -1231,  0909
    float32  1231,  0909
    float32 -3215,  0005
    float32  3215,  0005

    // 96 - Peach's Castle Beta
    float32 -0159,  0540
    float32  0471,  0540
    float32  0159,  0540
    float32 -0471,  0540

    // 97 - Hyrule Castle Remix
    float32 -1510,  1960
    float32  1510,  1960
    float32 -2150,  2875
    float32  2150,  2875

    // 98 - Sector Z Remix
    float32  4350,  0810
    float32  7840,  0940
    float32  5200,  0810
    float32  6400,  0940

    // 99 - Mute City
    float32 -1849,  2140
    float32  1819,  1721
    float32 -3289,  2140
    float32  3549,  1721

    // 9A - Home Run Contest
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 9B - Mushroom Kingdom Remix
    float32 -2850,  0035
    float32  2850,  0035
    float32 -3550,  1540
    float32  3550,  1540

    // 9C - Green Hill Zone
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0750,  0035
    float32  0750,  0035

    // 9D - Subcon
    float32 -0900,  0035
    float32  0900,  0035
    float32 -2850,  0950
    float32  2850,  0950

    // 9E - Pirate Land
    float32 -3400,  0125
    float32  2500,  0125
    float32 -3400,  0900
    float32  2500,  0900

    // 9F - Casino Night
    float32 -0925,  0500
    float32  0925,  0500
    float32 -3118,  0150
    float32  3118,  0150

    // A0 - Sonic Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A1 - Sonic Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A2 - Metallic Madness
    float32 -1250,  0001
    float32  1250,  0001
    float32 -0500,  0900
    float32  0500,  0900

    // A3 - Rainbow Road
    float32 -1800,  0035
    float32  1800,  0035
    float32 -0900,  0035
    float32  0900,  0035

    // A4 - POKEMON STADIUM 2
    float32 -1222,  0805
    float32  1222,  0805
    float32 -1222,  0035
    float32  1222,  0035

    // A5 - Norfair Remix
    float32 -0900,  0071
    float32  0900,  0071
    float32 -2000,  0970
    float32  2000,  0970

    // A6 - Toad's Turnpike
    float32 -0915, -0052
    float32  1925, -0052
    float32  0031, -0052
    float32  0978, -0052

    // A7 - Tal Tal Heights Remix
    float32 -1825,  0884
    float32  1825,  0884
    float32  0000,  1520
    float32  0000,  0010

    // A8 - Sheik Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A9 - Winter Dream Land
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // AA - Sheik Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AB - GLACIAL RIVER REMIX
    float32 -1647,  0130
    float32  1647,  0130
    float32 -0764,  0955
    float32  0764,  0955

    // AC - Marina Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AD - Dragon King Remix
    float32 -0650,  0035
    float32  0650,  0035
    float32 -0450,  0035
    float32  0450,  0035

    // AE - Marina Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AF - Dedede Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B0 - Draculas Castle
    float32  -1738, 1413
    float32  -337,  1413
    float32  -3327, 2379
    float32  3062,  1386

    // B1 - Reverse Castle
    float32  0159, 3642
    float32  1914, 3449
    float32  -830, 2267
    float32  0962, 1420

    // B2 - Dedede Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B3 - Mt. Dedede
    float32 -0900,  0380
    float32 -2950,  1720
    float32  0900,  0380
    float32  2950,  1720

    // B4 - Edo Town
    float32 -1000,  1170
    float32  1000,  1170
    float32 -1000,  0330
    float32  1000,  0330

    // B5 - Deku Tree DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // B6 - Crateria DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // B7 - Goemon Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B8 - First Destination Remix
    float32 -1253,  0945
    float32  1425,  1304
    float32  1837,  0031
    float32  0274,  0003

    // B9 - Goemon Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // BA - Twilight City
    float32 -1460,  0634
    float32  1460,  0634
    float32  -2407, 0634
    float32  2407,  0634

    // BB - Melrode
    float32 -1767,  0832
    float32  1767,  0832
    float32 -0568,  1421
    float32  0568,  1421

    // BC - Meta Crystal Remix
    float32 -1047,  0006
    float32  1047,  0006
    float32 -2008,  1915
    float32  2008,  1915
    
    // BD - Remix 1p Race to the Finish
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // BE - Grim Reapers Cavern
    float32  -1800, 0335
    float32  0900, 0025
    float32  -0450, 0226
    float32  2250, 0025

    // BF - Scuttle Town
    float32  -2920, 0468
    float32  0356, -0030
    float32  0881, 2198
    float32  2974, 0890

    // C0 - Big Boo's Haunt
    float32  -1400, 0002
    float32  1400,  0002
    float32 -0430, 0911
    float32  0610, 0880

    // C1 - Yoshis Island Melee (III)
    float32  -1050, 0035
    float32   1640, 0035
    float32  -2037, 0900
    float32   2907, 0900
    
    // C2 - Banjo Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // C3 - Spawned Fear
    float32  -3100,  0900
    float32  3100,  0900
    float32  -1800,  0900
    float32  1800,  0900

    // C4 - Smashville Remix
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0800,  0035
    float32  0800,  0035
    
    // C5 - Banjo Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    
    // C6 - Poke Floats
    float32 -1714, -1244
    float32  1305, -1661
    float32 -0498, -0118
    float32  0251, -0133
    
    // C7 - Ski Lifts
    float32 -3880,  1745
    float32  4095,  0645
    float32 -2090,  1745
    float32  2210,  0645

    neutral_table:
    // 00 - Peach's Castle
    float32 -1613,  1554
    float32  1613,  1412
    float32 -0665,  0662
    float32  0665,  0662

    // 01 - Sector Z
    float32 -3301,  1869
    float32  0296,  1739
    float32 -2094,  1708
    float32 -0898,  1593


    // 02 - Kongo Jungle
    float32 -1739,  0002
    float32  1739,  0002
    float32 -0630, -0210
    float32  0630, -0210


    // 03 - Planet Zebes
    float32 -2556,  0572
    float32  1745, -0262
    float32 -1137,  0011
    float32  0000,  0314


    // 04 - Hyrule Castle
    float32 -2400,  1042
    float32  1500,  1042
    float32 -1110,  1042
    float32  0240,  1042


    // 05 - Yoshi's Island
    float32  0629, -0096
    float32  0090,  2409
    float32  0756,  1513
    float32 -0990,  1032

    // 06 - Dream Land
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 07 - Saffron City
    float32  1200,  0810
    float32 -0660, -0270
    float32  0510,  0090
    float32 -1200, -0270

    // 08 - Classic Mushroom Kingdom
    float32 -1800,  1318
    float32  1500,  0962
    float32 -1500,  0152
    float32  1800,  1807

    // 09 - Dream Land Beta 1
    float32  0954,  0150
    float32  1006,  0930
    float32 -0892,  0927
    float32 -0912,  0150

    // 0A - Dream Land Beta 2
    float32 -0450,  0150
    float32  0450,  0150
    float32  0000,  1701
    float32  1522,  0930

    // 0B - How to Play Stage
    float32  0660,  0000
    float32  1440,  0000
    float32 -0660,  0000
    float32 -1440,  0000

    // 0C - Yoshi's Island (1P)
    float32 -1105, -0162
    float32  0986, -0156
    float32 -1257,  0726
    float32  1190,  0956

    // 0D - Meta Crystal
    float32 -1127,  0031
    float32  1769,  0263
    float32 -0431,  0036
    float32  0786,  0030

    // 0E - Duel Zone
    float32 -1200,  1025
    float32  1200,  1025
    float32 -1200,  0005
    float32  1200,  0005

    // 0F - Race to the Finish (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 10 - Final Destination
    float32 -1800,  0005
    float32  1800,  0005
    float32 -0900,  0005
    float32  0900,  0005

    // 11 - BTT_MARIO (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 12 - BTT_FOX (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 13 - BTT_DONKEY_KONG (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 14 - BTT_SAMUS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 15 - BTT_LUIGI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 16 - BTT_LINK (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 17 - BTT_YOSHI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 18 - BTT_FALCON (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 19 - BTT_KIRBY (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1A - BTT_PIKACHU (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1B - BTT_JIGGLYPUFF (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1C - BTT_NESS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1D - BTP_MARIO (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1E - BTP_FOX (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 1F - BTP_DONKEY_KONG (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 20 - BTP_SAMUS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 21 - BTP_LUIGI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 22 - BTP_LINK (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 23 - BTP_YOSHI (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 24 - BTP_FALCON (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 25 - BTP_KIRBY (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 26 - BTP_PIKACHU (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 27 - BTP_JIGGLYPUFF (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 28 - BTP_NESS (placeholder)
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 29 - DEKU TREE
    dw 0xC4142124, 0x42F28475
    dw 0x44876690, 0xC30E8E34
    dw 0xC5057791, 0x44B10000
    dw 0x4445FBBA, 0x44C3093B

    // 2A - FIRST DESTINATION
    float32 -1600,  0018
    float32  1612,  0018
    float32 -0422,  0018
    float32  0768,  0018

    // 2B - GANONS TOWER
    float32 -2200,  1954
    float32  1996,  1954
    float32 -2200,  1954
    float32  1996,  1954

    // 2C - KALOS POKEMON LEAGUE
    float32 -2371,  0921
    float32  2371,  0921
    float32 -1510,  0025
    float32  1510,  0025

    // 2D - POKEMON STADIUM
    float32 -1222,  0805
    float32  1222,  0805
    float32 -1222,  0035
    float32  1222,  0035

    // 2E - TALTAL
    float32 -1825,  0884
    float32  1825,  0884
    float32 -1825,  0035
    float32  1825,  0035

    // 2F - GLACIAL RIVER
    float32 -1647,  0130
    float32  1647,  0130
    float32 -0764,  0955
    float32  0764,  0955

    // 30 - WARIOWARE
    float32 -1172,  0783
    float32  1172,  0783
    float32 -1172,  0035
    float32  1172,  0035

    // 31 - BATTLEFIELD
    float32 -1262,  0752
    float32  1262,  0752
    float32 -1262,  0035
    float32  1262,  0035

    // 32 - Flat Zone
    float32 -1568, -0844
    float32 -0708, -0844
    float32  0138, -0844
    float32  1043, -0844

    // 33 - Dr. Mario
    float32 -1640,  1040
    float32  1640,  1040
    float32 -1640,  0100
    float32  1640,  0100

    // 34 - Cool Cool Mountain
    float32 -1546,  2206
    float32  1789,  2102
    float32 -1571,  0813
    float32  1315,  0805

    // 35 - Dragon King
    float32 -1740,  1355
    float32  1740,  1355
    float32 -1740,  0035
    float32  1740,  0035

    // 36 - Great Bay
    float32 -1013,  0511
    float32  1190,  0511
    float32 -2162, -0563
    float32  2083, -0545

    // 37 - Fray's Stage
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 38 - Tower of Heaven
    float32 -1495,  0851
    float32  1399,  0851
    float32 -1495,  0010
    float32  1399,  0010

    // 39 - Fountain of Dreams
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 3A - Muda
    float32 -1250, -0450
    float32  1869,  1500
    float32  0210,  0675
    float32  0000,  1825

    // 3B - Mementos
    float32 -1996,  0335
    float32  2324,  0025
    float32 -1581,  1080
    float32  0972,  0025

    // 3C - Showdown
    float32 -2000,  0035
    float32  2000,  0035
    float32 -1000,  0035
    float32  1000,  0035

    // 3D - Spiral Mountain
    float32 -2080,  0880
    float32  2080,  0880
    float32 -1161,  0035
    float32  1161,  0035

    // 3E - N64
    float32 -3447,  1998
    float32  2564,  1953
    float32 -1732,  1125
    float32  0853,  1114

    // 3F - Mute City DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 40 - Mad Monster Mansion
    float32 -1847, -0294
    float32  1947, -0294
    float32 -1148,  0719
    float32  1300,  0719

    // 41 - Super Mario Bros. DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 42 - Super Mario Bros. O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 43 - Bowser's Stadium
    float32 -2020,  0005
    float32  2020,  0005
    float32 -1010,  0005
    float32  1010,  0005

    // 44 - Peach's Castle II
    float32 -2600,  1080
    float32  2600,  1080
    float32 -1545,  0298
    float32  1545,  0298

    // 45 - Delfino
    float32 -0800,  0047
    float32  0800,  0047
    float32 -1600,  0047
    float32  1600,  0047

    // 46 - Corneria
    float32 -3339,  1400
    float32  0885,  1995
    float32 -2042,  1212
    float32 -0320,  1200

    // 47 - Kitchen
    float32 -1200,  2250
    float32  1200,  2250
    float32 -0600,  2250
    float32  0600,  2250

    // 48 - Big Blue
    float32 -1700,  2410
    float32  1834,  2102
    float32 -0238,  2150
    float32  0825,  2228

    // 49 - Onett
    float32 -2292,  2043
    float32  1792,  2413
    float32 -3144,  3017
    float32  1426,  3678

    // 4A - Zebes Landing
    float32 -2654,  0041
    float32  1124,  0033
    float32 -2153,  1121
    float32  -578,  1215

    // 4B - Frosty Village
    float32 -2439,  2426
    float32  1626,  1324
    float32 -0672,  1156
    float32  2953,  0117

    // 4C - SMASHVILLE
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0800,  0035
    float32  0800,  0035

    // 4D - BTT_DRM
    float32 -1657, -2638
    float32 -1657, -2638
    float32 -1657, -2638
    float32 -1657, -2638

    // 4E - BTT_GND
    float32  1705,  0661
    float32  1705,  0661
    float32  1705,  0661
    float32  1705,  0661

    // 4F - BTT_YL
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035

    // 50 - Battlefield DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // 51 - BTT_DS
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035
    float32  0000,  0035

    // 52 - BTT_STAGE 1
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 53 - BTT_FALCO
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 54 - BTT_WARIO
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 55 - HYRULE TEMPLE
    float32 -2799,  0496
    float32  2846, -0006
    float32 -0647,  2086
    float32  0665, -0731

    // 56 - BTT_LUCAS
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 57 - BTP_GND
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 58 - New Pork City
    float32 -1990,  0971
    float32  1990,  0971
    float32 -2575,  1772
    float32  2575,  1772

    // 59 - Dark Samus BTP
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 5A - Smashketball
    float32 -3042,  0005
    float32  3042,  0005
    float32 -1615,  0005
    float32  1615,  0005

	// 5B - BTP_DRM
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 5C - Norfair
    float32 -1645,  0709
    float32  1000,  0954
    float32 -1105, -0213
    float32  1775,  0111

	// 5D - CORNERIA CITY
    float32 -1685,  1700
    float32  1685,  1700
    float32 -1685,  0990
    float32  1685,  0990

	// 5E - Congo Falls
    float32 -1000,  0915
    float32  1000,  0915
    float32 -1000,  0125
    float32  1000,  0125

	// 5F - Osohe
    float32 -3443,  1358
    float32  3443,  1358
    float32 -1778,  0023
    float32  1778,  0023

	// 60 - Yoshi's Story II
    float32 -1594,  0900
    float32  1594,  0900
    float32 -1594,  0000
    float32  1594,  0000

	// 61 - World 1-1
    float32 -1590, -1150
    float32  1590, -1150
	float32 -0530, -1150
    float32  0530, -1150

	// 62 - Flat Zone II
    float32 -1980, -1685
    float32  1980, -1685
    float32 -0660, -1685
    float32  0660, -1685

	// 63 - Gerudo Valley
    float32 -0484,  0915
    float32  1310,  1135
    float32  1310,  0020
    float32 -1310,  0020

	// 64 - Young Link Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 65 - Falco Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 66 - Polygon Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 67 - Hyrule Castle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 68 - Hyrule Castle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 69 - Congo Jungle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 6A - Congo Jungle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 6B - Peach's Castle DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 6C - Peach's Castle O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

    // 6D - Wario Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 6E - Fray's Stage - Night
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

	// 6F - Goomba Road
    float32 -1400,  0005
    float32  1400,  0005
    float32 -1400,  1547
    float32  1400,  1547

	// 70 - Lucas Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 71 - Sector Z DL
    float32 -1400,  2656
    float32  1400,  2659
    float32 -1400,  1756
    float32  1400,  1756

	// 72 - Saffron City DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

	// 73 - Yoshi's Island DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

	// 74 - Zebes DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

	// 75 - Sector Z O
    float32 -1831,  1756
    float32  1831,  1756
    float32 -0915,  1756
    float32  0915,  1756

	// 76 - Saffron City O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 77 - Yoshi's Island O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 78 - Dream Land O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 79 - Planet Zebes O
    float32 -1831,  0035
    float32  1831,  0035
    float32 -0915,  0035
    float32  0915,  0035

	// 7A - Bowser Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 7B - Bowser Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

	// 7C - Bowser's Keep
    float32 -1470,  0550
    float32  1470,  0550
    float32 -2430,  1380
    float32  2430,  1380

    // 7D - Rith Essa
    float32 -3353,  1190
    float32  3722,  1190
    float32 -1723,  0066
    float32  2113,  0043

    // 7E - Venom
    float32 -1719,  1827
    float32  1719,  1827
    float32 -1719,  0283
    float32  1719,  0283

    // 7F - Wolf Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 80 - Wolf Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 81 - Conker Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 82 - Conker Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 83 - Windy
    float32 -2510,  2170
    float32  1480,  0720
    float32 -1380,  2170
    float32  0000,  0720

    // 84 - dataDyne
    float32 -0800, -0150
    float32  0800, -0150
    float32 -1700,  0660
    float32  1700,  0660

    // 85 - Planet Clancer
    float32 -1500,  0905
    float32  1500,  0905
    float32 -0750,  0005
    float32  0750,  0005

    // 86 - Jungle Japes
    float32 -2650,  0090
    float32  2650,  0090
    float32 -1035, -0240
    float32  1035, -0240

    // 87 - Marth Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 88 - Gameboy Land
    float32 -1250, -0450
    float32  1869,  1500
    float32  0210,  0675
    float32  0000,  1825

    // 89 - Mewtwo Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8A - Marth Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8B - Allstar Rest Area
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8C - Mewtwo Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 8D - Castle Siege
    float32 -1100,  1580
    float32  1390,  1955
    float32 -1500,  0650
    float32  1000,  0940

    // 8E - Yoshi's Island II
    float32 -1605,  0140
    float32  1605,  0140
    float32 -0600,  0100
    float32  0600,  0100

    // 8F - Final Destination DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 90 - Final Destination Tent
    float32 -1800,  0005
    float32  1800,  0005
    float32 -0900,  0005
    float32  0900,  0005

    // 91 - Cool Cool Mountain Remix
    float32 -1400,  0930
    float32  1400,  0930
    float32 -1900,  2000
    float32  1900,  2000

    // 92 - Duel Zone DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 93 - Cool Cool Mountain DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 94 - Meta Crystal DL
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // 95 - Dream Greens
    float32 -1231,  0909
    float32  1231,  0909
    float32 -3215,  0005
    float32  3215,  0005

    // 96 - Peach's Castle Beta
    float32 -0159,  0540
    float32  0471,  0540
    float32  0159,  0540
    float32 -0471,  0540

    // 97 - Hyrule Castle Remix
    float32 -1510,  1960
    float32  1510,  1960
    float32 -2150,  2875
    float32  2150,  2875

    // 98 - Sector Z Remix
    float32  4350,  0810
    float32  7840,  0940
    float32  5200,  0810
    float32  6400,  0940

    // 99 - Mute City
    float32 -1849,  2140
    float32  1819,  1721
    float32 -3289,  2140
    float32  3549,  1721

    // 9A - Home Run Contest
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // 9B - Mushroom Kingdom Remix
    float32 -2850,  0035
    float32  2850,  0035
    float32 -3550,  1540
    float32  3550,  1540

    // 9C - Green Hill Zone
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0750,  0035
    float32  0750,  0035

    // 9D - Subcon
    float32 -0900,  0035
    float32  0900,  0035
    float32 -2850,  0950
    float32  2850,  0950

    // 9E - Pirate Land
    float32 -3400,  0125
    float32  2500,  0125
    float32 -3400,  0900
    float32  2500,  0900

    // 9F - Casino Night
    float32 -0925,  0500
    float32  0925,  0500
    float32 -3118,  0150
    float32  3118,  0150

    // A0 - Sonic Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A1 - Sonic Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A2 - Metallic Madness
    float32 -1250,  0001
    float32  1250,  0001
    float32 -0500,  0900
    float32  0500,  0900

    // A3 - Rainbow Road
    float32 -1800,  0035
    float32  1800,  0035
    float32 -0900,  0035
    float32  0900,  0035

    // A4 - POKEMON STADIUM 2
    float32 -1222,  0805
    float32  1222,  0805
    float32 -1222,  0035
    float32  1222,  0035

    // A5 - Norfair Remix
    float32 -0900,  0071
    float32  0900,  0071
    float32 -2000,  0970
    float32  2000,  0970

    // A6 - Toad's Turnpike
    float32 -0915, -0052
    float32  1925, -0052
    float32  0031, -0052
    float32  0978, -0052

    // A7 - Tal Tal Heights Remix
    float32 -1825,  0884
    float32  1825,  0884
    float32  0000,  1520
    float32  0000,  0010

    // A8 - Sheik Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // A9 - Winter Dream Land
    float32 -1400,  0910
    float32  1400,  0910
    float32 -1400,  0005
    float32  1400,  0005

    // AA - Sheik Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AB - GLACIAL RIVER REMIX
    float32 -1647,  0130
    float32  1647,  0130
    float32 -0764,  0955
    float32  0764,  0955

    // AC - Marina Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AD - Dragon King Remix
    float32 -1740,  1355
    float32  1740,  1355
    float32 -2950,  2425
    float32  2950,  2425

    // AE - Marina Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // AF - Dedede Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B0 - Draculas Castle
    float32  -1738, 1413
    float32  -337,  1413
    float32  -3327, 2379
    float32  3062,  1386

    // B1 - Reverse Castle
    float32  159, 3642
    float32  1914,  3449
    float32  -830, 2267
    float32  962,  1420

    // B2 - Dedede Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B3 - Mt. Dedede
    float32 -0900,  0380
    float32 -2950,  1720
    float32  0900,  0380
    float32  2950,  1720

    // B4 - Edo Town
    float32 -1000,  1170
    float32  1000,  1170
    float32 -1000,  0330
    float32  1000,  0330

    // B5 - Deku Tree DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // B6 - Crateria DL
    float32 -1400,  0910
    float32  1400,  0910
    float32  0000,  1545
    float32  0000,  0005

    // B7 - BTT_GOEMON
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // B8 - First Destination Remix
    float32 -1253,  0945
    float32  1425,  1304
    float32  1837,  0031
    float32  0274,  0003

    // B9 - Goemon Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000

    // BA - Twilight City
    float32 -1460,  0634
    float32  1460,  0634
    float32  -2407, 0634
    float32  2407,  0634

    // BB - Melrode
    float32 -1767,  0832
    float32  1767,  0832
    float32 -0568,  1421
    float32  0568,  1421
    
    // BC - Meta Crystal Remix
    float32 -1047,  0006
    float32  1047,  0006
    float32 -2008,  1915
    float32  2008,  1915
    
    // BD - Remix 1p Race to the Finish
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    
    // BE - Grim Reapers Cavern
    float32  -1800, 0335
    float32  0900, 0025
    float32  -0450, 0226
    float32  2250, 0025

    // BF - Scuttle Town
    float32  -2920, 0468
    float32  0356, -0030
    float32  0881, 2198
    float32  2974, 0890

    // C0 - Big Boo's Haunt
    float32  -1400, 0002
    float32  1400,  0002
    float32 -0430, 0911
    float32  0610, 0880
    
    // C1 - Yoshis Island Melee (III)
    float32  -1050, 0035
    float32   1640, 0035
    float32  -2037, 0900
    float32   2907, 0900
    
    // C2 - Banjo Break the Targets
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    
    // C3 - Spawned Fear
    float32  -3100,  0900
    float32  3100,  0900
    float32  -1800,  0900
    float32  1800,  0900

    // C4 - Smashville Remix
    float32 -1500,  0035
    float32  1500,  0035
    float32 -0800,  0035
    float32  0800,  0035
    
    // C5 - Banjo Board the Platforms
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    float32  0000,  0000
    
    // C6 - Poke Floats
    float32 -1714, -1244
    float32  1305, -1661
    float32 -0498, -0118
    float32  0251, -0133
    
    // C7 - Ski Lifts
    float32 -3880,  1745
    float32  4095,  0645
    float32 -2090,  1745
    float32  2210,  0645
    
}

} // __SPAWN__
