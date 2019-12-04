// Toggles.asm
if !{defined __TOGGLES__} {
define __TOGGLES__()
print "included Toggles.asm\n"

include "Color.asm"
include "Data.asm"
include "Menu.asm"
include "OS.asm"
include "SRAM.asm"

scope Toggles {

    // @ Description
    // Allows function 
    macro guard(entry_address, exit_address) {
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      at, 0x0004(sp)              // save at
        li      at, {entry_address}         // ~
        lw      at, 0x0004(at)              // at = is_enabled
        bnez    at, pc() + 24               // if (is_enabled), _continue
        nop

        // _end:
        lw      at, 0x0004(sp)              // restore at
        addiu   sp, sp, 0x0008              // deallocate stack space

        // foor hook vs. function
        if ({exit_address} == 0x00000000) {
            jr      ra
        } else {
            j       {exit_address}
        }
        nop

        // _continue:
        lw      at, 0x0004(sp)              // restore at
        addiu   sp, sp, 0x0008              // deallocate stack space
    }

    // @ Description
    // This patch disables functionality on the OPTION screen.
    OS.patch_start(0x001205FC, 0x80132E4C)
    jr      ra
    nop
    OS.patch_end()

    // @ Description
    // This patch disables back (press B) on Main Menu
    OS.patch_start(0x0011D768, 0x801327D8)
    nop
    nop
    nop
    nop
    OS.patch_end()

    scope run_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      a3, 0x0014(sp)              // ~
        sw      t0, 0x0018(sp)              // ~
        sw      t1, 0x001C(sp)              // save registers

        // draw logo
        lli     a0, 000010                  // a0 - ulx
        lli     a1, 000010                  // a1 - uly
        li      a2, Data.menu_bg_info     // a2 - address of texture struct
        jal     Overlay.draw_texture_big_   // draw logo texture
        nop

        // draw "options" text
        lli     a0, 000026                  // a0 - ulx
        lli     a1, 000011                  // a1 - uly
        li      a2, Data.options_text_info  // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw options text texture
        nop

        // update menu
        li      a0, info
        jal     Menu.update_                // check for updates
        nop

        // draw menu
        li      a0, info                    // a0 - info
        jal     Menu.draw_                  // draw menu
        nop

        // check for exit
        lli     a0, Joypad.B                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // check if B pressed
        nop 
        beqz    v0, _end                    // nop
        nop
        li      t0, info                    // t0 = address of info
        lw      t1, 0x0000(t0)              // t1 = address of head
        li      t2, head_super_menu         // t2 = address of head_super_menu
        beq     t1, t2, _exit_super_menu    // if (in super menu), exit
        nop                                 // else, exit sub menu

        _exit_sub_menu:
        jal     set_info_1_                 // bring up super menu
        nop
        b       _end                        // end menu execution
        nop

        _exit_super_menu:
        jal     save_                       // save toggles
        nop
        lli     a0, 0x0007                  // a0 - screen_id (main menu)
        jal     Menu.change_screen_         // exit to main menu
        nop

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      a3, 0x0014(sp)              // ~
        lw      t0, 0x0018(sp)              // ~
        lw      t1, 0x001C(sp)              // restore registers
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Save toggles to SRAM
    scope save_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, head_remix_settings     // a0 - address of head
        li      a1, block_misc              // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_misc              // ~
        jal     SRAM.save_                  // save data
        nop

        li      a0, head_music_settings     // a0 - address of head
        li      a1, block_music             // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_music             // ~
        jal     SRAM.save_                  // save data
        nop

        li      a0, head_random_stage_settings
        li      a1, block_stages            // a1 - address of block
        jal     Menu.export_                // export data
        nop
        li      a0, block_stages            // ~
        jal     SRAM.save_                  // save data
        nop
    
        jal     SRAM.mark_saved_            // mark save file present
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Loads toggles from SRAM
    scope load_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, block_misc              // a0 - address of block (misc)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_remix_settings     // a0 - address of head
        li      a1, block_misc              // a1 - address of block
        jal     Menu.import_
        nop

        li      a0, block_music             // a0 - address of block (music)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_music_settings     // a0 - address of head 
        li      a1, block_music             // a1 - address of block
        jal     Menu.import_
        nop

        li      a0, block_stages            // a0 - address of block (stages)
        jal     SRAM.load_                  // load data
        nop
        li      a0, head_random_stage_settings
        li      a1, block_stages            // a1 - address of block
        jal     Menu.import_
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    macro set_info_head(address_of_head) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // save t0
        sw      t1, 0x0008(sp)              // save t1

        li      t0, info                    // t0 = info
        li      t1, {address_of_head}       // t1 = address of head
        sw      t1, 0x0000(t0)              // update info->head
        sw      r0, 0x000C(t0)              // update info.selection

        lw      t0, 0x0004(sp)              // restore t0
        lw      t1, 0x0008(sp)              // restore t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    } 

    info:
    Menu.info(head_super_menu, 30, 35, 0, 32)

    // @ Description
    // Functions to change the menu currently displayed.
    set_info_1_:; set_info_head(head_super_menu)
    set_info_2_:; set_info_head(head_remix_settings)
    set_info_3_:; set_info_head(head_music_settings)
    set_info_4_:; set_info_head(head_random_stage_settings)

    // @ Description
    // This function will transition to "SCREEN ADJUST"
    scope load_screen_adjust_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // save registers

        // this block resets the arrow to 0
        li      t0, info                    // t0 = info
        sw      r0, 0x000C(t0)              // update info.selection

        // this block changes screens
        lli     a0, 0x000F                  // a0 - int next_screen
        jal     Menu.change_screen_         // go to SCREEN ADJUST
        nop

        lw      ra, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack sapce
        jr      ra                          // return 
        nop
    }


    // @ Description
    // Contains list of submenus.
    head_super_menu:
    Menu.entry_title("REMIX SETTINGS", set_info_2_, pc() + 20)
    Menu.entry_title("MUSIC SETTINGS", set_info_3_, pc() + 20)
    Menu.entry_title("RANDOM STAGE SETTINGS", set_info_4_, pc() + 28)
    Menu.entry_title("SCREEN ADJUST", load_screen_adjust_, OS.NULL)

    // @ Description 
    // Miscellaneous Toggles
    head_remix_settings:
    entry_practice_overlay:;            Menu.entry_bool("COLOR OVERLAYS", OS.FALSE, entry_disable_cinematic_camera)
    entry_disable_cinematic_camera:;    Menu.entry_bool("DISABLE CINEMATIC CAMERA", OS.FALSE, entry_flash_on_z_cancel)
    entry_flash_on_z_cancel:;           Menu.entry_bool("FLASH ON Z-CANCEL", OS.FALSE, entry_hitbox_mode)
    entry_hitbox_mode:;                 Menu.entry_bool("HITBOX DISPLAY", OS.FALSE, entry_hold_to_pause)
    entry_hold_to_pause:;               Menu.entry_bool("HOLD TO PAUSE", OS.TRUE, entry_improved_combo_meter)
    entry_improved_combo_meter:;        Menu.entry_bool("IMPROVED COMBO METER", OS.TRUE, entry_tech_chase_combo_meter)
    entry_tech_chase_combo_meter:;      Menu.entry_bool("TECH CHASE COMBO METER", OS.FALSE, entry_vs_mode_combo_meter)
    entry_vs_mode_combo_meter:;         Menu.entry_bool("VS MODE COMBO METER", OS.TRUE, entry_1v1_combo_meter_swap)
    entry_1v1_combo_meter_swap:;        Menu.entry_bool("1V1 COMBO METER SWAP", OS.FALSE, entry_improved_ai)
    entry_improved_ai:;                 Menu.entry_bool("IMPROVED AI", OS.TRUE, entry_neutral_spawns)
    entry_neutral_spawns:;              Menu.entry_bool("NEUTRAL SPAWNS", OS.TRUE, entry_skip_results_screen)
    entry_skip_results_screen:;         Menu.entry_bool("SKIP RESULTS SCREEN", OS.FALSE, entry_stereo_sound)
    entry_stereo_sound:;                Menu.entry_bool("STEREO SOUND", OS.TRUE, entry_stock_handicap)
    entry_stock_handicap:;              Menu.entry_bool("STOCK HANDICAP", OS.TRUE, entry_salty_runback)
    entry_salty_runback:;               Menu.entry_bool("SALTY RUNBACK", OS.TRUE, entry_widescreen)
    entry_widescreen:;                  Menu.entry_bool("WIDESCREEN", OS.FALSE, OS.NULL)

    // @ Description
    // Random Music Toggles
    head_music_settings:
    entry_play_music:;                      Menu.entry_bool("PLAY MUSIC", OS.TRUE, pc() + 16)
    entry_random_music:;                    Menu.entry_bool("RANDOM MUSIC", OS.FALSE, pc() + 20)
    entry_random_music_battlefield:;        Menu.entry_bool("BATTLEFIELD", OS.FALSE, pc() + 16)
    entry_random_music_congo_jungle:;       Menu.entry_bool("CONGO JUNGLE", OS.FALSE, pc() + 20)
    entry_random_music_data:;               Menu.entry_bool("DATA", OS.FALSE, pc() + 12)
    entry_random_music_dream_land:;         Menu.entry_bool("DREAM LAND", OS.FALSE, pc() + 16)
    entry_random_music_final_destination:;  Menu.entry_bool("FINAL DESTINATION", OS.FALSE, pc() + 24)
    entry_random_music_how_to_play:;        Menu.entry_bool("HOW TO PLAY", OS.FALSE, pc() + 16)
    entry_random_music_hyrule_castle:;      Menu.entry_bool("HYRULE CASTLE", OS.FALSE, pc() + 20)
    entry_random_music_meta_crystal:;       Menu.entry_bool("META CRYSTAL", OS.FALSE, pc() + 20)
    entry_random_music_mushroom_kingdom:;   Menu.entry_bool("MUSHROOM KINGDOM", OS.FALSE, pc() + 24)
    entry_random_music_peachs_castle:;      Menu.entry_bool("PEACH'S CASTLE", OS.FALSE, pc() + 20)
    entry_random_music_planet_zebes:;       Menu.entry_bool("PLANET ZEBES", OS.FALSE, pc() + 20)
    entry_random_music_saffron_city:;       Menu.entry_bool("SAFFRON CITY", OS.FALSE, pc() + 20)
    entry_random_music_sector_z:;           Menu.entry_bool("SECTOR Z", OS.FALSE, pc() + 16)
    entry_random_music_yoshis_island:;      Menu.entry_bool("YOSHI'S ISLAND", OS.TRUE, OS.NULL)

    // @ Description
    // Random Stage Toggles
    head_random_stage_settings:
    entry_random_stage_battlefield:;            Menu.entry_bool("BATTLEFIELD", OS.TRUE, pc() + 16)
    entry_random_stage_congo_jungle:;           Menu.entry_bool("CONGO JUNGLE", OS.TRUE, pc() + 20)
    entry_random_stage_dream_land:;             Menu.entry_bool("DREAM LAND", OS.TRUE, pc() + 16)
    entry_random_stage_dream_land_beta_1:;      Menu.entry_bool("DREAM LAND BETA 1", OS.TRUE, pc() + 24)
    entry_random_stage_dream_land_beta_2:;      Menu.entry_bool("DREAM LAND BETA 2", OS.TRUE, pc() + 24)
    entry_random_stage_final_destination:;      Menu.entry_bool("FINAL DESTINATION", OS.TRUE, pc() + 24)
    entry_random_stage_how_to_play:;            Menu.entry_bool("HOW TO PLAY", OS.TRUE, pc() + 16)
    entry_random_stage_hyrule_castle:;          Menu.entry_bool("HYRULE CASTLE", OS.TRUE, pc() + 20)
    entry_random_stage_meta_crystal:;           Menu.entry_bool("META CRYSTAL", OS.TRUE, pc() + 20)
    entry_random_stage_mushroom_kingdom:;       Menu.entry_bool("MUSHROOM KINGDOM", OS.TRUE, pc() + 24)
    entry_random_stage_peachs_castle:;          Menu.entry_bool("PEACH'S CASTLE", OS.TRUE, pc() + 20)
    entry_random_stage_planet_zebes:;           Menu.entry_bool("PLANET ZEBES", OS.TRUE, pc() + 20)
    entry_random_stage_saffron_city:;           Menu.entry_bool("SAFFRON CITY", OS.TRUE, pc() + 20)
    entry_random_stage_sector_z:;               Menu.entry_bool("SECTOR Z", OS.TRUE, pc() + 16)
    entry_random_stage_yoshis_island:;          Menu.entry_bool("YOSHI'S ISLAND", OS.TRUE, pc() + 20)
    entry_random_stage_mini_yoshis_island:;     Menu.entry_bool("YOSHI'S ISLAND MINI", OS.TRUE, OS.NULL) 

    // @ Description
    // SRAM blocks for toggle saving.
    block_misc:; SRAM.block(16 * 4)
    block_music:; SRAM.block(16 * 4)
    block_stages:; SRAM.block(16 * 4)
}


} // __TOGGLES__
