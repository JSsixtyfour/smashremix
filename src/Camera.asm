// Camera.asm
if !{defined __CAMERA__} {
define __CAMERA__()
print "included Camera.asm\n"


// @ Description
// This file includes Camera related toggles and fixes.

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

// 80131470 - camera

scope Camera {

    // @ Description
    constant camera_struct(0x801314B0) // 0x000C =

    // @ Description
    // camera types used for toggles
    scope type {
        constant NORMAL(0)
        constant BONUS(1)        // camera tries to match global player x coordinates
        constant FIXED(2)
        constant SCENE(3)
    }

    type_string_table:
    dw string_normal
    dw string_bonus
    dw string_fixed
    dw string_scene

    string_normal:; String.insert("NORMAL")
    string_bonus:; String.insert("BONUS")
    string_fixed:; String.insert("FIXED")
    string_scene:; String.insert("SCENE")


    // @ Description
    // Hook in vanilla routine during camera set that sets the camera routine index (we're here if not Planet Zebes or Mushroom Kingdom)
    // Wide/Walk off stages tend to look better with this camera due to less skewing
    scope override_camera_type_: {
        OS.patch_start(0x892A4, 0x8010DAA4)
        j    override_camera_type_
        nop
        _return:
        OS.patch_end()

        // s0 = camera special struct
        // v0 = stage id

        addiu   at, r0, Stages.id.MK_REMIX
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.SUBCON
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.SECTOR_Z_REMIX
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.ONETT
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.BLUE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.MUTE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.HTEMPLE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.DRAGONKING_REMIX
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.DRAGONKING
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.PEACH2
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.MT_DEDEDE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.FIRST_REMIX
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.MELRODE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.SCUTTLE_TOWN
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.YOSHIS_ISLAND_MELEE
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.BIG_SNOWMAN
        beq     at, v0, mkingdom_camera
        addiu   at, r0, Stages.id.TOADSTURNPIKE
        bnel    at, v0, _end
		addiu   t0, r0, 0                           // if here, use default camera index (0)

		mkingdom_camera:
		ori     t0, r0, 3                           // t0 = MKingdom camera routine

        _end:
        j       0x8010DAC0                          // original line 1
        sw      t0, 0x0004(s0)                      // kinda original line 2, set match camera to default vs cam

    }

    // @ Description
    // allows us to immediately replace camera values upon camera creation. runs once.
    // TODO: replace with lookup table OR use bonus pause cam coordinates from editor (would have to add a check to see if the values != 0 first)
    scope set_initial_coordinates_: {
        OS.patch_start(0x8928C, 0x8010DA8C)
        j   set_initial_coordinates_
        nop
        _return:
        OS.patch_end()

        // first, clear the offsets in custom array that could affect battle entry camera/training "close-up" camera
        li      t9, camera_pan_offsets_
        sw      r0, 0x0000(t9)                      // clear custom x offset variable
        sw      r0, 0x0004(t9)                      // clear custom y offset variable
        sw      r0, 0x0008(t9)                      // clear custom z offset variable
        sw      r0, 0x000C(t9)                      // clear custom fov offset variable

        OS.read_word(Toggles.entry_camera_mode + 0x4, t9) // t9 = camera mode boolean
        beqz    t9, _end                            // branch to end if cam = NORMAL
        nop
        addiu   t0, r0, type.BONUS                  // at = type.BONUS
        beq     t0, t9, _bonus_cam                  // branch if camera mode = BONUS
        nop

        // check if training mode
        li      t0, Global.match_info               // ~ 0x800A50E8
        lw      t0, 0x0000(t0)                      // t0 = match_info
        lb      t0, 0x0000(t0)                      // t0 = match type
        ori     t2, r0, 0x0007                      // t2 = training id
        beq     t0, t2, _end                        // never use fixed/scene camera if in training mode
        nop

        addiu   t0, r0, type.FIXED                  // at = type.FIXED
        beq     t0, t9, _fixed_cam                  // branch if camera mode = FIXED
        nop

        // addiu   t0, r0, type.SCENE                  // at = type.SCENE
        // beq     t0, t9, _bonus_cam                  // branch if camera mode = SCENE
        // nop

        // if here, apply scene camera
        _scene_cam:
        li       t9, 0x8012EBB4                      // t9 = ptr to default camera routines (safe to overwrite)
        lw       t0, 0x0008(t9)                      // t0 = cinematic camera
        sw       t0, 0x0000(t9)                      // overwrite default vs camera routine
        sw       t0, 0x000C(t9)                      // overwrite mushroom kingdom camera routine
        sw       t0, 0x0018(t9)                      // overwrite planet zebes camera routine
        li       t9, 0x80131460                      // t9 = pointer to camera struct
        sw       t0, 0x005C(t9)                      // overwrite current camera routine with routine in t0
        b        _end                                // end
        nop

        _bonus_cam:
        li       t9, 0x8012EBB4                      // t9 = ptr to default camera routines (safe to overwrite)
        lw       t0, 0x000C(t9)                      // t0 = routine for mushroom kingdom camera
        sw       t0, 0x0000(t9)                      // overwrite current default vs match routine
        sw       t0, 0x0018(t9)                      // overwrite planet zebes camera routine
        li       t9, 0x80131460                      // t9 = pointer to camera struct
        sw       t0, 0x005C(t9)                      // overwrite current camera routine with BONUS routine
        b        _end                                // end
        nop

        _fixed_cam:
        // initial
        li      t0, Global.match_info               // ~ 0x800A50E8
        lw      t0, 0x0000(t0)                      // t0 = match_info
        lbu     t0, 0x0001(t0)                      // t0 = stage id

        // HRC check, skip if so
        ori     t2, r0, Stages.id.HRC               // t2 = id.HRC
        beq     t0, t2, _end                        // dont use custom/fixed camera if stage == HRC
        nop

        // OVERWRITE the "get camera" pointer with our custom routine
        li      t2, get_custom_camera_              // t2 = ptr to normal camera routine
        sw      t2, 0x0134 - 0x90(a0)               // overwrite routine

        li      t1, frozen_world1                   // t1 = frozen camera parameters for WORLD1
        ori     t2, r0, Stages.id.WORLD1            // t2 = id.WORLD1
        beq     t0, t2, _set_fixed_camera_values    // use frozen camera if stage = WORLD1
        nop

        li      t1, gb_land                         // t1 = frozen camera parameters for Gameboy Land
        ori     t2, r0, Stages.id.GB_LAND           // t2 = id.GB_LAND
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = GB_LAND
        nop
        li      t1, frozen_flat_zone_2              // t1 = frozen camera parameters for FLAT_ZONE_2
        ori     t2, r0, Stages.id.FLAT_ZONE_2       // t2 = id.FLAT_ZONE_2
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = FLAT_ZONE_2
        nop
        li      t1, frozen_flat_zone                // t1 = frozen camera parameters for FLAT_ZONE
        ori     t2, r0, Stages.id.FLAT_ZONE         // t2 = id.FLAT_ZONE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = FLAT_ZONE
        nop
        li      t1, fixed_pokefloats                // t1 = frozen camera parameters for POKEFLOATS
        ori     t2, r0, Stages.id.POKEFLOATS        // t2 = id.POKEFLOATS
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = POKEFLOATS
        nop

        // BTP/BTP
        li      t1, Global.current_screen           // ~
        lbu     t1, 0x0000(t1)                      // t3 = current screen
        addiu   t2, r0, 0x0035                      // t2 = Bonus mode screen ID
        beq     t2, t1, _set_fixed_bonus_cam_values // branch if bonus
        nop

        // RTTF
        li      t1, fixed_rttf                      // t1 = fixed camera parameters for RACE_TO_THE_FINISH
        ori     t2, r0, Stages.id.RACE_TO_THE_FINISH// t2 = id.RACE_TO_THE_FINISH
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop

        // ALL STAR RESTING AREA
        li      t1, fixed_rest                      // t1 = fixed camera parameters for REST
        ori     t2, r0, Stages.id.REST              // t2 = id.REST
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop

        // BATTLE STAGES
        // check for VS stages with increased camera.Y
        li      t1, fixed_increase_y                // t1 = fixed camera parameters for stages with a high y
        ori     t2, r0, Stages.id.PLANET_ZEBES      // t2 = id.PLANET_ZEBES
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.COOLCOOL          // t2 = id.COOLCOOL
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.COOLCOOL_REMIX    // t2 = id.COOLCOOL_REMIX
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.PEACHS_CASTLE     // t2 = id.PEACHS_CASTLE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.DRAGONKING        // t2 = id.DRAGONKING
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.NPC               // t2 = id.NPC (NEW PORK CITY)
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop

        // Sector Z has a higher y coordinate in order to align with Arwing paths
        li      t1, fixed_sector_z_dl_o             // t1 = fixed camera parameters for sector_z_dl/o
        ori     t2, r0, Stages.id.SECTOR_Z_DL       // t2 = id.SECTOR_Z_DL
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.SECTOR_Z_O        // t2 = id.SECTOR_Z_O
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop

        // stages that get more increased camera.Y
        li      t1, fixed_increase_y_more           // t1 = fixed camera parameters for stages with a higher y
        ori     t2, r0, Stages.id.GANONS_TOWER      // t2 = id.GANONS_TOWER
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = GANONS_TOWER
        nop
        ori     t2, r0, Stages.id.VENOM             // t2 = id.VENOM
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.HCASTLE_REMIX     // t2 = id.HCASTLE_REMIX
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.SECTOR_Z_DL       // t2 = id.SECTOR_Z_DL
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.SECTOR_Z_O        // t2 = id.SECTOR_Z_O
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.ONETT             // t2 = id.ONETT
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.KITCHEN           // t2 = id.KITCHEN
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.TOH               // t2 = id.TOH (TOWER OF HEAVEN)
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.MUTE              // t2 = id.MUTE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.BLUE              // t2 = id.BLUE (BIG BLUE)
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.CORNERIACITY      // t2 = id.CORNERIACITY
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.WINDY             // t2 = id.WINDY
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop
        ori     t2, r0, Stages.id.BOWSERS_KEEP      // t2 = id.BOWSERS_KEEP
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = ~
        nop

        // stages that need increased y and z
        li      t1, fixed_increase_y_and_z          // t1 = fixed camera parameters for stages with a higher y
        ori     t2, r0, Stages.id.OSOHE             // t2 = id.OSOHE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = OSOHE
        nop
        ori     t2, r0, Stages.id.RITH_ESSA         // t2 = id.RITH_ESSA
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = RITH_ESSA
        nop

        // stages with unique camera coordinates
        li      t1, fixed_showdown                  // zoom out a lot and raise cam
        ori     t2, r0, Stages.id.SHOWDOWN          // t2 = id.SHOWDOWN
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = SHOWDOWN
        nop
        li      t1, fixed_frosty_village            // shift left and raise cam
        ori     t2, r0, Stages.id.FROSTY            // t2 = id.FROSTY
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = FROSTY
        nop
        li      t1, fixed_hyrule_temple             // zoom out and z distance cam
        ori     t2, r0, Stages.id.HTEMPLE           // t2 = id.HTEMPLE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = HTEMPLE
        nop
        li      t1, fixed_hyrule_castle             // zoom out and z distance cam
        ori     t2, r0, Stages.id.HYRULE_CASTLE     // t2 = id.HYRULE_CASTLE
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = HYRULE_CASTLE
        nop
        li      t1, fixed_yoshis_island             // shift right a lot and zoom out cam
        ori     t2, r0, Stages.id.YOSHIS_ISLAND     // t2 = id.YOSHIS_ISLAND
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = YOSHIS_ISLAND
        nop
        li      t1, fixed_sector_z_sr               // shift right a lot and adjust zoom
        ori     t2, r0, Stages.id.SECTOR_Z_REMIX    // t2 = id.SECTOR_Z_REMIX
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = SECTOR_Z_REMIX
        nop
        li      t1, fixed_sector_z                  // zoom out and center cam
        ori     t2, r0, Stages.id.SECTOR_Z          // t2 = id.SECTOR_Z
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = SECTOR_Z
        nop
        li      t1, fixed_n64                       // shift to center and raise cam
        ori     t2, r0, Stages.id.N64               // t2 = id.N64
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = N64
        nop
        li      t1, fixed_saffron_city              // zoom out and shift cam left
        ori     t2, r0, Stages.id.SAFFRON_CITY      // t2 = id.SAFFRON_CITY
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = SAFFRON_CITY
        nop
        li      t1, fixed_mushroom_kingdom_sr       // zoom out cam
        ori     t2, r0, Stages.id.MK_REMIX          // t2 = id.MK_REMIX
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = MK_REMIX
        nop
        li      t1, fixed_smashketball              // smashketball special cam
        ori     t2, r0, Stages.id.SMASHKETBALL      // t2 = id.SMASHKETBALL
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = SMASHKETBALL
        nop
        li      t1, fixed_peach_2                   // t1 = fixed camera parameters for stages with a higher y
        ori     t2, r0, Stages.id.PEACH2            // t2 = id.PEACH2
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = GANONS_TOWER
        nop
        li      t1, fixed_great_bay                 // t1 = fixed camera parameters for stages with a higher y
        ori     t2, r0, Stages.id.GREAT_BAY         // t2 = id.GREAT_BAY
        beq     t0, t2, _set_fixed_camera_values    // fix fixed camera if stage = GANONS_TOWER
        nop

        // if here, use remixs default fixed camera parameters
        li      t1, fixed_default                   // t1 = default fixed camera value

        // update camera position with fixed camera parameters
        // t1 = frozen camera parameters
        // a0 = camera location struct (camera object + 0x90)
        _set_fixed_camera_values:
        lw      t2, 0x0000(t1)                      // ~
        sw      t2, struct.x - 0x90(a0)             // set initial camera x
        lw      t2, 0x0004(t1)                      // ~
        sw      t2, struct.y - 0x90(a0)             // set initial camera y
        lw      t2, 0x0008(t1)                      // ~
        sw      t2, struct.z - 0x90(a0)             // set initial camera z
        lw      t2, 0x000C(t1)                      // ~
        sw      t2, struct.focal_x - 0x90(a0)       // set initial camera focal x
        lw      t2, 0x0010(t1)                      // ~
        sw      t2, struct.focal_y - 0x90(a0)       // set initial camera focal y
        lw      t2, 0x0014(t1)                      // ~
        sw      t2, struct.focal_z - 0x90(a0)       // set initial camera focal z
        lw      t2, 0x0018(t1)                      // ~
        sw      t2, struct.zoom - 0x90(a0)          // set initial camera zoom
        b       _end
        nop

        // get bonus stage paused camera values from stage header
        // TODO: make all stages use this value (currently, only bonus stages use these values)
        _set_fixed_bonus_cam_values:
        li      t0, 0x80131300                      // t0 = ptr to pause camera array
        lw      t0, 0x0000(t0)                      // t0 = address to camera position

        // FOCAL X
        lh      t1, 0x009A(t0)                      // get "bonus pause" focal_x
        mtc1    t1, f16                             // move to to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.focal_x - 0x90(a0)      // set camera focal x

        // FOCAL_Y
        lh      t1, 0x009C(t0)                      // get "bonus pause" focal_y
        mtc1    t1, f16                             // move to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.focal_y - 0x90(a0)      // set camera focal_y

        // FOCAL_Z
        lh      t1, 0x009E(t0)                      // get "bonus pause" focal_z
        mtc1    t1, f16                             // move to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.focal_z - 0x90(a0)      // set camera z

        // CAMERA_X
        lh      t1, 0x00A0(t0)                      // get "bonus pause" x
        mtc1    t1, f16                             // move to to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.x - 0x90(a0)            // set camera x

        // CAMERA_Y
        lh      t1, 0x00A2(t0)                      // get "bonus pause" y
        mtc1    t1, f16                             // move to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.y - 0x90(a0)            // set camera y

        // CAMERA_Z
        lh      t1, 0x00A4(t0)                      // get "bonus pause" z
        mtc1    t1, f16                             // move to fp
        cvt.s.w f18, f16                            //
        swc1    f18, struct.z - 0x90(a0)            // set camera z

        _end:
        li      t0, 0x0000                          // t0 = 0
        li      t1, 0x0000                          // t1 = 0
        li      t2, 0x0000                          // t2 = 0
        lw      t3, 0x50E8 (t3)                     // original line 1
        lbu     v0, 0x0001 (t3)                     // original line 2
        j       _return
        nop

    }

    // @ Description
    // based on the default routine that sets gameplay camera. 0x8010CECC (small routine)
    // original routine gets the camera
    scope get_custom_camera_: {
        OS.read_word(_custom_cam, t9)       // t9 = custom camera
        j      0x8010CED4                   // jump to original routine
        nop

        // lui     t9, 0x8013               // original line 1
        // lw      t9, 0x14BC(t9)           // original line 2
    }

    // CUSTOM CAM ADDRESS - for now, it will only be for fixed_camera
    _custom_cam:
    dw  0x8010CC74

    // @ Description
    // skip cutscene from changing camera angle during master hands entry for fixed camera mode.
    scope fixed_camera_boss_: {
        OS.patch_start(0x883EC,0x8010CBEC)
        j       fixed_camera_boss_
        nop
        _return:
        OS.patch_end()

        // t6 should be safe
        OS.read_word(Toggles.entry_camera_mode + 0x4, t6) // t6 = am type toggle value
        addiu   at, r0, type.FIXED          // at = camera type.fixed
        beq     t6, at, _skip_cutscene      // branch if fixed_camera enabled
        nop

        // if here, continue as normal
        jal     0x80010580                  // original line 1

        _skip_cutscene:
        sw      a0, 0x0018(sp)              // original line 2
        j       0x8010CBF4                  // jump to original routine
        nop
    }

    // @ Description
    // This catches a call to Global.get_random_int and sets the result depending on the cinematic entry toggle value.
    scope cinematic_entry_: {
        OS.patch_start(0x0008E250, 0x80112A50)
        j       cinematic_entry_
        nop
        _cinematic_entry_return:
        OS.patch_end()

        jal     Global.get_random_int_      // original line 1
        lli     a0, 0x0003                  // original line 2

        // check if fixed camera toggle is enabled
        OS.read_word(Toggles.entry_camera_mode + 0x4, a0) // a0 = Cam type toggle value
        addiu   at, r0, type.FIXED          // at = camera type.fixed
        beq     a0, at, _disabled           // branch if fixed_camera enabled
        addiu   at, r0, type.SCENE          // at = camera type.scene
        beq     a0, at, _disabled           // branch if fixed_camera enabled
        nop

        OS.read_word(Toggles.entry_cinematic_entry + 0x4, a0) // a0 = 1 if always, 2 if never, 0 if default
        beqz    a0, _return                 // if set to default, use v0 returned from get_random_int_
        addiu   a0, a0, -0x0001             // a0 = 0 if always, 1 if never
        beqzl   a0, _return                 // if set to always, set v0 to 2
        lli     v0, 0x0002                  // force cinematic entry

        _disabled:
        // otherwise, its set to never
        lli     v0, 0x0000                  // force no cinematic entry

        _return:
        j       _cinematic_entry_return     // return
        nop
    }

    // @ Description
    // adds a patch-fix/hook into the pause routine that will force the pause camera to use the fixed camera
    scope fixed_camera_bonus_pause_fix_: {
        OS.patch_start(0x88814, 0x8010D014)
        j       fixed_camera_bonus_pause_fix_
        nop
        nop
        _return:
        OS.patch_end()

        // check fixed camera toggle
        OS.read_word(Toggles.entry_camera_mode + 0x4, a0) // a0 = Cam type toggle value
        addiu   at, r0, type.FIXED              // at = camera type.fixed
        beq     a0, at, _end                    // branch to end if fixed camera mode is on
        nop

        _normal:
        lui     a0, 0x8013                      // original line 1
        jal     0x8010CEF4                      // original line 2
        lw      a0, 0x14B8(a0)

        _end:
        j       _return
        nop
    }

    // @ Description
    // Allows 360 control over the camera by changing the floats to check against
    // inspired by [Gaudy (Emudigital)]
    OS.patch_start(0x000AC494, 0x80130C94)
    float32 100                             // x limit
    dw 0x39AE9681                           // x increment
    float32 -100                            // x limit
    float32 100                             // y limit
    dw 0x39AE9681                           // y increment
    float32 -100                            // y limit
    OS.patch_end()

    // @ Description
    // adds camera up/down/view distance/fov movement when player can control pause camera
    scope vs_pause_pan_: {
        OS.patch_start(0x000881CC, 0x8010C9CC)
        j       vs_pause_pan_
        nop
        _vs_pause_pan_return:
        OS.patch_end()

        // sp + 0x30 is where the current coordinates are stored.
        // v0 = player coordinates
        li      a0, camera_pan_offsets_         // a0 = pause cam offset table
        lwc1    f0, 0x0000(a0)                  // f0 = x offset
        lwc1    f2, 0x0030(sp)                  // f2 = player.x
        add.s   f0, f0, f2                      // f0 = new x coordinate
        nop
        swc1    f0, 0x0030(sp)                  // save new x coordinate

        lwc1    f0, 0x0004(a0)                  // f0 = y offset
        lwc1    f2, 0x0034(sp)                  // f2 = player.y
        add.s   f0, f0, f2                      // f0 = new y coordinate
        nop
        swc1    f0, 0x0034(sp)                  // save new y coordinate
        nop

        // move camera
        lwc1    f2, 0x0008(a0)                  // f2 = z offset from custom struct
        add.s   f10, f10, f2                    // original z offset + custom z offset
        nop

        lw      at, 0x000C(a0)                  // f2 = fov offset from custom struct
        beqz    at, _end                        // branch if fov is unchanged
        lwc1    f2, 0x000C(a0)                  // f2 = fov offset from custom struct
        add.s   f12, f12, f2                    // original fov += custom fov
        nop
        lui     t0, 0x8013
        swc1    f12, 0x14F0(t0)

        _end:
        or      a0, s0, r0                      // original line 1
        j       _vs_pause_pan_return            // jump to original routine
        addiu   a1, sp, 0x0030                  // original line 2

    }

    // @ Description
    // clears x,y,z offset values for custom vs camera panning
    scope pause_initial_: {
        OS.patch_start(0x0008F9B4, 0x801141B4)
        j       pause_initial_
        nop
        pause_initial_return_:
        OS.patch_end()

        addiu   sp, sp, -0x10                       // allocate stackspace
        sw      ra, 0x0008(sp)                      // save ra

        li      v0, camera_pan_offsets_
        sw      r0, 0x0000(v0)                      // clear x
        sw      r0, 0x0004(v0)                      // clear y
        sw      r0, 0x0008(v0)                      // clear z
        sw      r0, 0x000C(v0)                      // clear fov

        jal     0x8010CA7C                          // original line 1
        addiu   a0, a0, 0x001C                      // original line 2

        // Remove camera control for Fixed Camera Mode
        OS.read_word(Toggles.entry_camera_mode + 0x4, t6) // t6 = fixed cam boolean
        addiu   t7, r0, type.FIXED                  // t7 = camera type.fixed
        bne     t6, t7, _end
        li      t0, 0x80131828                       // bit determines if camera can be moved
        addiu   at, r0, 1
        sb      at, 0x0000(t0)

        _end:
        lw      ra, 0x0008(sp)                      // load ra
        j       pause_initial_return_               // return to original routine
        addiu   sp, sp, 0x10                        // deallocate stackspace

    }

    // @ Description
    // vs camera offset values for focal x,  focal y and cam.zoom
    camera_pan_offsets_:
    dw  0x00000000                                  // x offset
    dw  0x00000000                                  // y offset
    dw  0x00000000                                  // z offset
    dw  0x00000000                                  // fov offset

    constant max_zoom_offset(0xC480)
    constant min_fov(0xC1E0)
    constant max_fov(0x42F8)

    // @ Description
    // pause.asm runs this routine so we can move the camera around in pause
	// a1 = buttons pressed ptr
	scope extended_movement_: {
	    lh      a0, 0x0000(a1)                  // a0 = input flag (checking for A/B)
        sll     at, a0, 16                      // shift
        srl     at, at, 30                      // shift
        beqz    at, _check_pan                  // branch if not pressing A or B
        nop

        // if here, A or B pressed
        li      a0, Camera.camera_pan_offsets_  // a0 = camera offset array
        srl     at, at, 1                       // shift
        beqz    at, _apply_zoom                 // branch if not pressing B
        lui     v1, 0x3D4C                      // v1 = -speed for camera

        // if here, camera zoom+=speed
        lui     v1, 0xBD4C                      // v1 = +speed for camera
        lw      at, 0x0008(a0)                  // at = current zoom offset
        beqz    at, _check_pan                  // skip if value already is 0
        nop

        _apply_zoom:
        lwc1    f6, 0x0008(a0)                  // f6 = current zoom offset
        mtc1    v1, f12                         // f12 = zoom variable
        add.s   f3, f6, f12                     // f6 = new zoom offset
        nop
        swc1    f6, 0x0008(a0)                  // save new zoom offset

        _check_pan:
        // al = player input array
        lh      a0, 0x0000(a1)                  // a0 = input flag (checking for CPAD)
        sll     at, a0, 28                      // at = UD bitflags
        srl     at, at, 30                      // at = UD bitflags
        beqz    at, _check_CPAD_LR              // skip c-pad UD check if DPAD.UD not pressed
        nop

        // if here, up or down is pressed
        srl     at, at, 1                       // at = bitflag for DPAD.UP
        beqz    at, apply_y_speed               // branch if not pressing up
        lui     v1, 0xc200                      // v1 = -speed for camera

        // if here, camera y+=speed
        lui     v1, 0x4200                      // v1 = +speed for camera

        apply_y_speed:
        li      a0, Camera.camera_pan_offsets_  // a0 = camera offset array
        lwc1    f6, 0x0004(a0)                  // f6 = current y offset
        mtc1    v1, f12                         // f12 = y speed
        add.s   f6, f6, f12                     // f6 = new y offset
        nop
        swc1    f6, 0x0004(a0)                  // save new y coordinate

        _check_CPAD_LR:
        lh      a0, 0x0000(a1)                  // a0 = cpad input flag
        sll     at, a0, 30                      // at = LR bitflags
        srl     at, at, 30                      // at = LR bitflags
        beqz    at, _check_AB                   // skip c-pad LR check if DPAD.LR not pressed
        nop

        // if here, left or right is pressed
        srl     at, at, 1                       // at = bitflag for CPAD.UP
        beql    at, r0, apply_x_speed           // branch if not pressing up
        lui     v1, 0x4200                      // v1 = -speed for camera

        // if here, camera x-=speed
        lui     v1, 0xc200                      // v1 = +speed for camera

        apply_x_speed:
        li      a0, Camera.camera_pan_offsets_  // a0 = camera offset array
        lwc1    f6, 0x0000(a0)                  // f6 = current x offset
        mtc1    v1, f12                         // f12 = x speed
        add.s   f6, f6, f12                     // f6 = new x offset
        nop
        swc1    f6, 0x0000(a0)                  // save new x coordinate

        _check_AB:
        lh      a0, 0x0000(a1)                  // a0 = players current AB input
        beqz    a0, _end                        // skip if not button pressed

        andi    at, a0, Joypad.B                // check if B held
        bnezl   at, apply_z_distance            // branch if player pressing B
        lui     v1, 0x42A0                      // v1 = - camera distance

        andi    at, a0, Joypad.A
        beqz    at, _end                        // branch if player not pressing A
        lui     v1, 0xC2A0                      // v1 = + camera distance

        apply_z_distance:
        li      a0, Camera.camera_pan_offsets_  // a0 = camera offset array
        lh      t0, 0x0000(a1)                  // a0 = input flag (check for z press)
        andi    t0, t0, Joypad.Z                // t0 = 0 if z not pressed
        bnezl   t0, apply_fov                   // branch if z is down
        lwc1    f6, 0x0008(a0)                  // f6 = current fox offset
        lwc1    f6, 0x0008(a0)                  // f6 = current z offset
        mtc1    v1, f12                         // move camera distance value to float
        add.s   f6, f6, f12                     // f6 = amount to change z by + current z distance offset
        nop
        lui     v1, max_zoom_offset             // clamp zoom value
        mtc1    v1, f12                         // move to float
        c.le.s  f6, f12
        nop
        bc1tl   _end
        swc1    f12, 0x0008(a0)                 // save clamped camera distance
        b       _end
        swc1    f6, 0x0008(a0)                  // or save new camera distance

        apply_fov:
        li      a0, Camera.camera_pan_offsets_  // a0 = camera offset array
        lwc1    f6, 0x000C(a0)                  // f6 = current fov offset
        mtc1    v1, f12                         // move camera distance value to float

        lui     at, 0x3C23                      // at = some value
        mtc1    at, f4                          // move to float
        mul.s   f12, f12, f4                    // multiply amount so its not too fast
        nop
        add.s   f6, f6, f12                     // f6 = amount to change fov by + current fov offset
        nop
        lui     v1, min_fov                     // clamp fov value
        mtc1    v1, f12                         // move to float
        c.le.s  f6, f12
        nop
        bc1tl   _end
        swc1    f12, 0x000C(a0)                 // save clamped camera distance
        lui     v1, max_fov                     // clamp fov value
        mtc1    v1, f12                         // move to float
        c.le.s  f12, f6
        nop
        bc1tl   _end
        swc1    f12, 0x000C(a0)                 // save clamped camera distance
        swc1    f6, 0x000C(a0)                  // or save new camera distance

        b       _end
        nop

        _end:
        jr      ra
        nop

    }

    // @ Description
    // routine runs once when game is unpaused. Disables hud from drawing if camera mode = SCENE or entry_disable_hud = ALL
    scope unpause_camera_: {
        OS.patch_start(0x8FE38, 0x80114638)
        j       unpause_camera_
        nop
        return_:
        OS.patch_end()

        // Destroy the pause hud legend, if it exists
        lui     a0, 0x8004
        lw      a0, 0x672C(a0)                      // a0 = first object in group 0xF
        beqz    a0, _clear_camera_offsets           // if no object, skip destroying
        nop
        OS.save_registers()
        jal     0x800CB608                          // destroy all objects in group
        nop

        lui     a0, 0x8004
        lw      a0, 0x6730(a0)                      // a0 = first object in group 0x10
        beqz    a0, _finish_pause_hud_clear         // if no object, skip destroying
        nop
        jal     0x800CB608                          // destroy all objects in group
        nop
        _finish_pause_hud_clear:
        OS.restore_registers()

        _clear_camera_offsets:
        // since player is unpausing, we will clear camera offsets
        li      a0, camera_pan_offsets_
        sw      r0, 0x0000(a0)                      // clear x
        sw      r0, 0x0004(a0)                      // clear y
        sw      r0, 0x0008(a0)                      // clear z
        sw      r0, 0x000C(a0)                      // clear fov

        // v0 = TRUE
        // check if hud should be disabled
        OS.read_word(Toggles.entry_disable_hud + 0x4, a0) // a0 = entry_disable_hud (0 if OFF, 1 if PAUSE, 2 if ALL)
        andi    a0, a0, 0x0002                      // a0 = 1 if entry_disable_hud = 2
        bnez    a0, _disable_hud                    // branch if ALL hud disabled
        nop

        li      a0, Toggles.entry_camera_mode
        lw      a0, 0x0004(a0)                      // a0 = camera type toggle value
        addiu   at, r0, type.SCENE                  // at = camera type.scene
        bne     a0, at, _continue                   // branch if camera type != SCENE
        nop

        _disable_hud:
        jal     0x80113F74                          // subroutine disables drawing of game hud
        addiu   a0, r0, 0x0001                      // argument = don't draw
        addiu   v0, r0, 0x0000                      // v0 = FALSE
        _continue:
        lui     at, 0x8013                          // original line 1
        sb      v0, 0x1580(at)                      // original line 2, enable/disable magnifying glass
        addiu   v0, r0, 0x0001                      // restore v0
        j       return_                             // return to original routine
        or      a0, r0, r0                          // restore a0

    }

    // @ Description
    // Routine runs after "3, 2, 1 GO!". Disables HUD from drawing if entry_disable_hud = ALL
    scope disable_hud_: {
        OS.patch_start(0x8DA28 ,0x80112228)
        j       disable_hud_
        nop
        OS.patch_end()

        OS.read_word(Toggles.entry_disable_hud + 0x4, t0) // t0 = entry_disable_hud (0 if OFF, 1 if PAUSE, 2 if ALL)
        andi    t0, t0, 0x0002                  // t0 = 1 if entry_disable_hud = 2
        beqz    t0, _end                        // branch if not ALL hud disabled
        nop

        // disable drawing of hud
        jal     0x80113F74                      // subroutine disables drawing of game hud
        addiu   a0, r0, 0x0001                  // argument = don't draw
        lw      ra, 0x001C(sp)

        // disable off-screen magnifying glass for players
        addiu   v0, r0, 0x0000                  // v0 = FALSE
        lui     at, 0x8013                      // at = ram location

        _end:
        sb      v0, 0x1580(at)                  // original line 1, enable/disable magnifying glass
        jr      ra                              // original line 2
        addiu   sp, sp, 0x20                    // original line 3
        }

    // @ Description
    // Subroutine which freezes the camera
    // Replaces a JAL to subroutine to 0x80018FBC which is used to update the camera''s position.
    scope frozen_camera_: {

        OS.patch_start(0x87DA8, 0x8010C5A8)
        jal     frozen_camera_
        OS.patch_end()

        OS.patch_start(0x87E58, 0x8010C658)
        jal     frozen_camera_
        OS.patch_end()

        OS.patch_start(0x87EC8, 0x8010C6C8)
        jal     frozen_camera_
        OS.patch_end()

        OS.patch_start(0x880AC, 0x8010C8AC)
        jal     frozen_camera_
        OS.patch_end()

        // Function
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // store t0 - t2, ra

        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t0 = match_info
        lbu     t0, 0x0001(t0)              // t0 = stage id
        li      t1, frozen_world1           // t1 = frozen camera parameters for WORLD1
        ori     t2, r0, Stages.id.WORLD1    // t2 = id.WORLD1
        beq     t0, t2, _frozen             // use frozen camera if stage = WORLD1
        nop
        li      t1, hrc                     // t1 = frozen camera parameters for HRC
        ori     t2, r0, Stages.id.HRC       // t2 = id.HRC
        beq     t0, t2, _frozen             // use frozen camera if stage = HRC
        nop
        OS.read_word(Toggles.entry_hazard_mode + 0x4, t1) // t1 = 1 if hazard_mode is 1 or 3, 0 otherwise
        andi    t1, t1, 0x0001              // t1 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t1, _normal                 // if hazard_mode enabled, skip frozen camera for flat zones
        nop
        li      t1, gb_land                 // t1 = frozen camera parameters for Gameboy Land
        ori     t2, r0, Stages.id.GB_LAND   // t2 = id.GB_LAND
        beq     t0, t2, _frozen             // use frozen camera if stage = GB_LAND
        nop
        li      t1, fixed_pokefloats        // t1 = frozen camera parameters for POKEFLOATS
        ori     t2, r0, Stages.id.POKEFLOATS// t2 = id.POKEFLOATS
        beq     t0, t2, _frozen             // use frozen camera if stage = GB_LAND
        nop
        li      t1, frozen_flat_zone_2      // t1 = frozen camera parameters for FLAT_ZONE_2
        ori     t2, r0, Stages.id.FLAT_ZONE_2 // t2 = id.FLAT_ZONE_2
        beq     t0, t2, _frozen             // use frozen camera if stage = FLAT_ZONE_2
        nop
        li      t1, frozen_flat_zone        // t1 = frozen camera parameters for FLAT_ZONE
        ori     t2, r0, Stages.id.FLAT_ZONE // t2 = id.FLAT_ZONE
        beq     t0, t2, _frozen             // use frozen camera if stage = FLAT_ZONE
        nop

        _normal:
        // if we reach this point, update camera as normal
        jal     0x80018FBC                  // original JAL
        nop
        b       _end                        // end subroutine
        nop

        _frozen:
        // if we reach this point, update camera position with fixed camera parameters
        // t1 = frozen camera parameters
        li      t0, struct.pointer          // ~
        lw      t0, 0x0000(t0)              // t0 = camera struct
        lw      t2, 0x0000(t1)              // ~
        sw      t2, struct.x(t0)            // update camera x
        lw      t2, 0x0004(t1)              // ~
        sw      t2, struct.y(t0)            // update camera y
        lw      t2, 0x0008(t1)              // ~
        sw      t2, struct.z(t0)            // update camera z
        lw      t2, 0x000C(t1)              // ~
        sw      t2, struct.focal_x(t0)      // update camera focal x
        lw      t2, 0x0010(t1)              // ~
        sw      t2, struct.focal_y(t0)      // update camera focal y
        lw      t2, 0x0014(t1)              // ~
        sw      t2, struct.focal_z(t0)      // update camera focal z

        // Remove camera control for Fixed Camera Mode
        li      t0, 0x80131828                       // bit determines if camera can be moved
        addiu   at, r0, 1
        sb      at, 0x0000(t0)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // load t0 - t2, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Frozen camera parameters for WORLD1
    frozen_world1:
    float32 0                               // camera x position
    float32 -100                            // camera y position
    float32 6600                            // camera z position
    float32 0                               // camera focal x position
    float32 -100                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov (ignored)
    float32 0                               // unused

    // @ Description
    // Frozen camera parameters for FLAT_ZONE_2
    frozen_flat_zone_2:
    float32 0                               // camera x position
    float32 0                               // camera y position
    float32 8000                            // camera z position
    float32 0                               // camera focal x position
    float32 0                               // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov (ignored)
    float32 0                               // unused

    // @ Description
    // Frozen camera parameters for FLAT_ZONE
    frozen_flat_zone:
    float32 0                               // camera x position
    float32 -100                            // camera y position
    float32 6600                            // camera z position
    float32 0                               // camera focal x position
    float32 -100                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov (ignored)
    float32 0                               // unused

    // @ Description
    // Frozen camera parameters for GB_LAND
    gb_land:                                // Frozen camera parameters for GB_LAND
    float32 0                               // camera x position
    float32 1250                            // camera y position
    float32 7000                            // camera z position
    float32 0                               // camera focal x position
    float32 1250                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov (ignored)
    float32 0                               // unused

    // @ Description
    // Frozen camera parameters for HRC (not fixed camera)
    hrc:
    float32 -21312                          // camera x position
    float32 1536                            // camera y position
    float32 6112                            // camera z position
    float32 -21312                          // camera focal x position
    float32 -512                            // camera focal y position
    float32 -3584                           // camera focal z position
    float32 38                              // camera zoom/fov (unused)
    float32 0                               // unused

    // Fixed-camera mode routines below
    fixed_default:                         // for most vanilla/remix stages
    float32 0                              // camera x position
    float32 1850                           // camera y position
    float32 10000                          // camera z position
    float32 0                              // camera focal x position
    float32 942                            // camera focal y position
    float32 0                              // camera focal z position
    float32 38                             // camera zoom/fov
    float32 0                              // unused

    fixed_increase_y:                       // for most stages higher than default camera
    float32 0                               // 0 camera x position
    float32 2560                            // 0x4520 camera y position
    float32 10000                           // 0 camera z position
    float32 0                               // 0 camera focal x position
    float32 1328                            // camera focal y position
    float32 0                               // 0 camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_increase_y_more:                  // for most stages that be too high for default camera
    float32 0                               // 0 camera x position
    float32 2560                            // 0x4520 camera y position
    float32 10000                           // 0 camera z position
    float32 0                               // 0 camera focal x position
    float32 1968                            // camera focal y position
    float32 0                               // 0 camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_increase_y_and_z:
    float32 240                             // camera x position
    float32 1200                            // camera y position
    float32 12032                           // camera z position
    float32 240                             // camera focal x position
    float32 1608                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_showdown:
    float32 0                               // 0 camera x position
    float32 2560                            // 0x4520 camera y position
    float32 15000                           // 0 camera z position
    float32 0                               // 0 camera focal x position
    float32 1968                            // camera focal y position
    float32 0                               // 0 camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_sector_z:                         //
    float32 960                             // camera x position
    float32 2168                            // camera y position
    float32 11008                           // camera z position
    float32 960                             // camera focal x position
    float32 692                             // camera focal y position
    float32 0                               // camera focal z position
    float32 60                              // camera zoom/fov
    float32 0                               // unused

    fixed_sector_z_sr:
    float32 6656                            // camera x position
    float32 1250                            // camera y position
    float32 7000                            // camera z position
    float32 6656                            // camera focal x position
    float32 1250                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_sector_z_dl_o:
    float32 0                               // camera x position
    float32 3328                            // camera y position
    float32 10000                           // camera z position
    float32 0                               // camera focal x position
    float32 2656                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_yoshis_island:                    // off stage not visible
    float32 960                             // camera x position
    float32 1250                            // camera y position
    float32 11008                           // camera z position
    float32 1664.0                          // camera focal x position
    float32 1250                            // camera focal y position
    float32 0                               // camera focal z position
    float32 48                              // camera zoom/fov
    float32 0                               // unused

    fixed_hyrule_castle:                    // raise cam, move back 2, default fov
    float32 0                               // camera x position
    float32 2560                            // camera y position
    float32 11264                           // camera z position
    float32 0                               // camera focal x position
    float32 2048                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_hyrule_temple:
    float32 0                               // camera x position
    float32 960                             // camera y position
    float32 16144                           // camera z position
    float32 0                               // camera focal x position
    float32 128                             // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_frosty_village:                   // cam is too right
    float32 -416                            // camera x position
    float32 1328                            // camera y position
    float32 11024                           // camera z position
    float32 -480                            // camera focal x position
    float32 1968                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_n64:
    float32 -512                            // 0 camera x position
    float32 4096                            // camera y position
    float32 10000                           // 0 camera z position
    float32 -512                            // 0 camera focal x position
    float32 1024                            // camera focal y position
    float32 0                               // 0 camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_saffron_city:
    float32 0                               // camera x position
    float32 1200                            // camera y position
    float32 11024                           // camera z position
    float32 -96                             // camera focal x position
    float32 492                             // camera focal y position
    float32 -96                             // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_mushroom_kingdom_sr:
    float32 0                               // camera x position
    float32 1850                            // camera y position
    float32 11024                           // camera z position
    float32 0                               // camera focal x position
    float32 942                             // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_smashketball:
    float32 0                               // camera x position
    float32 960                             // camera y position
    float32 11392                           // camera z position
    float32 0                               // camera focal x position
    float32 235                             // camera focal y position
    float32 -11392                          // camera focal z position
    float32 32                              // camera zoom/fov
    float32 0                               // unused

    fixed_peach_2:
    float32 240                             // camera x position
    float32 1000                            // camera y position
    float32 12032                           // camera z position
    float32 240                             // camera focal x position
    float32 1408                            // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_great_bay:
    float32 2304                            // camera x position
    float32 1850                            // camera y position
    float32 10000                           // camera z position
    float32 2048                            // camera focal x position
    float32 942                             // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_rttf:                             // race to the finish
    float32 0                               // camera x position
    float32 3632                            // camera y position
    float32 21760                           // camera z position
    float32 0                               // camera focal x position
    float32 0                               // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    fixed_rest:                             // allstar rest area
    float32 0                               // camera x position
    float32 1850                            // camera y position
    float32 5632                            // camera z position
    float32 0                               // camera focal x position
    float32 942                             // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    // @ Description
    // Frozen camera parameters for Poke FLoats
    fixed_pokefloats:
    float32 0                               // camera x position
    float32 0                               // camera y position
    float32 7000                            // camera z position
    float32 0                               // camera focal x position
    float32 0                               // camera focal y position
    float32 0                               // camera focal z position
    float32 38                              // camera zoom/fov
    float32 0                               // unused

    // @ Description
    // camera struct constants
    scope struct {
        constant pointer(0x80131460)
        constant zoom(0xA8)
        constant horizontal_fov(0xAC)
        constant x(0xC4)
        constant y(0xC8)
        constant z(0xCC)
        constant focal_x(0xD0)
        constant focal_y(0xD4)
        constant focal_z(0xD8)
        constant draw_players_offscreen(0x120) // byte. = 0x01 while not paused
    }

    // @ Description
    // This pushes back the camera when playing on Venom or GB Land.
    scope camera_adjust_: {
        OS.patch_start(0x62A70, 0x800E7270)
        j       camera_adjust_
        nop
        _return:
        OS.patch_end()

        li      t8, Global.current_screen   // ~
        lbu     t8, 0x0000(t8)              // t8 = current screen
        addiu   at, r0, 0x0016              // Vs screen ID
        beq     at, t8, _stage_check        // stage check if in vs
        addiu   at, r0, 0x0036              // Training screen ID
        beq     at, t8, _stage_check        // stage check if in vs
        addiu   at, r0, 0x0077              // Special 1p screen ID used for Allstar and Multiman
        beq     at, t8, _stage_check        // stage check if in vs
        addiu   at, r0, 0x0001              // 1p screen ID
        bne     at, t8, _standard           // if not in any of the battle screens, skip to standard
        nop

        _stage_check:
        li      t8, Global.match_info       // ~
        lw      t8, 0x0000(t8)              // t8 = match_info
        lbu     t8, 0x0001(t8)              // t8 = stage id

        addiu   at, r0, Stages.id.GB_LAND   // insert venom stage ID
        beq     t8, at, _max_zoom           // branch if on Gameboy Land
        lui     at, 0x3FE0                  // load Venom Camera Distance

        addiu   at, r0, Stages.id.VENOM     // insert venom stage ID
        bne     t8, at, _standard           // branch if not on Venom
        lui     at, 0x3FE0                  // load Venom Camera Distance

        _max_zoom:
        j       _return                     // return
        mtc1    at, f4                      // original line 2

        _standard:
        lui     at, 0x3F80                  // load camera distance, original line 1
        j       _return                     // return
        mtc1    at, f4                      // original line 2

    }

    // @ Description
    // hook at routine that reads a flag to determine if player is off screen for pause routine.
    // if flag = 0, then analog stick doesnt draw on top of screen.
    scope pause_disable_control_flag_: {
        OS.patch_start(0x8FA30 ,0x80114230)
        j   pause_disable_control_flag_
        nop
        _return:
        OS.patch_end()

        // t5 = TRUE or FALSE for analog stick hud variable

        // check fixed camera toggle
        OS.read_word(Toggles.entry_camera_mode + 0x4, t6) // t6 = fixed cam boolean
        addiu   t7, r0, type.FIXED                  // t7 = camera type.fixed
        beq     t6, t7, _disable_control            // if fixed camera, branch to disable the control
        nop

        // get stage id
        li      t6, Global.match_info               // ~ 0x800A50E8
        lw      t6, 0x0000(t6)                      // t6 = match_info
        lbu     t6, 0x0001(t6)                      // t6 = stage id

        // flat zone hazard mode check
        li      t7, Toggles.entry_hazard_mode
        lw      t7, 0x0004(t7)                      // t7 = hazard_mode (hazards disabled when t1 = 1 or 3)
        andi    t7, t7, 0x0001                      // t7 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t7, _normal                         // if hazard_mode enabled, skip check for flat zones (otherwise camera will glitch)
        nop

        // flat zone checks start here
        ori     t7, r0, Stages.id.FLAT_ZONE_2       // at = id.FLAT_ZONE_2
        beq     t6, t7, _disable_control            // disable pause controls if stage = FLAT_ZONE_2
        nop
        ori     t7, r0, Stages.id.FLAT_ZONE         // at = id.FLAT_ZONE
        beq     t6, t7, _disable_control            // disable pause controls if stage = FLAT_ZONE
        nop

        _normal:
        ori     t7, r0, Stages.id.WORLD1            // at = id.WORLD1
        beq     t6, t7, _disable_control            // disable pause analog controls if stage = WORLD1
        nop
        ori     t7, r0, Stages.id.HRC               // at = id.HRC
        beq     t6, t7, _disable_control            // disable pause analog controls if stage = HRC (failsafe)
        nop
        ori     t7, r0, Stages.id.GB_LAND           // at = id.GB_LAND
        beq     t6, t7, _disable_control            // disable pause analog controls if stage = GB_LAND
        nop

        // if here, t5 == TRUE
        _end:
        sb      t5, 0x1828(at)                      // original line 1, writes t5
        j       _return
        lbu     t6, 0x000E(s2)                      // original line 2

        _disable_control:
        b       _end
        addiu   t5, r0, 0x0000                      // t5 = false
    }
}

} // __CAMERA__
