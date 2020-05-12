// Toggles.asm
if !{defined __TOGGLES__} {
define __TOGGLES__()
print "included Toggles.asm\n"

include "Color.asm"
include "Data.asm"
include "Menu.asm"
include "MIDI.asm"
include "OS.asm"
include "SRAM.asm"
include "Stages.asm"

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
    //nop
    //nop
    //nop
    //nop
    OS.patch_end()

    press_r:; db ": NEXT PAGE", 0x00
    OS.align(4)

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

        li      a0, info                    // a0 = address of info
        jal     Menu.get_num_entries_       // v0 = number of entries
        nop
        slti    a0, v0, Menu.MAX_PER_PAGE+1 // if there is only one page
        bnez    a0, _draw_menu              // then don't draw pagination instructions
        nop

        // draw "R" button
        lli     a0, 000181                  // a0 - ulx
        lli     a1, 000011                  // a1 - uly
        li      a2, Data.r_button_info      // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw options text texture
        nop

        // tell the user they can bring up the custom menu
        lli     a0, 000199                  // a0 - ulx
        lli     a1, 000014                  // a1 - uly
        li      a2, press_r                 // a2 - address of string
        jal     Overlay.draw_string_        // draw custom menu instructions
        nop

        _draw_menu:
        // update menu
        li      a0, info
        jal     Menu.update_                // check for updates
        nop

        // draw menu
        li      a0, info                    // a0 - info
        jal     Menu.draw_                  // draw menu
        nop

        // draw current profile
        li      t0, info                    // t0 - address of info
        lw      t1, 0x0000(t0)              // t1 - address of head
        li      t2, head_super_menu         // t2 - address of head_super_menu
        bne     t1, t2, _check_b            // if (not in super menu), skip
        nop                                 // else, exit sub menu
        lli     a0, 000055                  // a0 - x
        lli     a1, 000221                  // a1 - uly
        li      a2, current_profile         // a2 - address of string
        jal     Overlay.draw_string_        // draw current profile label
        nop
        jal     get_current_profile_        // v0 - current profile
        nop
        li      a2, string_table_profile    // a2 - profile string table address
        sll     v0, v0, 0x0002              // v0 - offset to profile string address
        lli     a0, 000230                  // a0 - x
        lli     a1, 000221                  // a1 - uly
        addu    a2, a2, v0                  // a2 - address of string address
        lw      a2, 0x0000(a2)              // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw current profile
        nop

        // draw toggles note
        li      t0, info                    // t0 - address of info
        lw      t1, 0x000C(t0)              // t1 - cursor... 0 if Load Profile is selected
        bnez    t1, _check_b                // if (Load Profile not selected), skip
        nop                                 // else, exit sub menu
        lli     a0, 000160                  // a0 - x
        lli     a1, 000180                  // a1 - uly
        li      a2, toggles_note_line_1     // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw current profile label
        nop
        lli     a0, 000160                  // a0 - x
        lli     a1, 000190                  // a1 - uly
        li      a2, toggles_note_line_2     // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw current profile label
        nop

        // check for exit
        _check_b:
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

        // restore cursor when returning from sub menu
        li      t2, head_remix_settings     // t2 = head_remix_settings
        beql    t1, t2, _exit_sub_menu      // if (returning from remix settings)
        ori     t0, r0, 0x0001              // then set cursor accordingly
        li      t2, head_music_settings     // t2 = head_music_settings
        beql    t1, t2, _exit_sub_menu      // if (returning from music settings)
        ori     t0, r0, 0x0002              // then set cursor accordingly
        ori     t0, r0, 0x0003              // if (returning from random stage settings) then set cursor accordingly

        _exit_sub_menu:
        jal     set_info_1_                 // bring up super menu
        nop
        li      t1, info                    // t1 = address of info
        sw      t0, 0x000C(t1)              // restore cursor
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

        li      a0, head_stage_settings
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
        li      a0, head_stage_settings
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
        sw      t1, 0x0018(t0)              // update info->1st displayed
        sw      t1, 0x001C(t0)              // update info->last displayed

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
    set_info_4_:; set_info_head(head_stage_settings)

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

    variable num_toggles(0)

    // @ Description
    // Wrapper for Menu.entry_bool()
    macro entry_bool(title, default_ce, default_te, default_jp, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        Menu.entry_bool({title}, {default_ce}, {next})
    }

    // @ Description
    // Wrapper for Menu.entry()
    macro entry(title, type, default_ce, default_te, default_jp, min, max, a_function, string_table, copy_address, next) {
        global variable num_toggles(num_toggles + 1)
        evaluate n(num_toggles)
        global define TOGGLE_{n}_DEFAULT_CE({default_ce})
        global define TOGGLE_{n}_DEFAULT_TE({default_te})
        global define TOGGLE_{n}_DEFAULT_JP({default_jp})
        Menu.entry({title}, {type}, {default_ce}, {min}, {max}, {a_function}, {string_table}, {copy_address}, {next})
    }

    // @ Description
    // Write defaults for the passed in profile
    // profile - CE or TE
    macro write_defaults_for(profile) {
        evaluate n(1)
        while {n} <= num_toggles {
            dw      {TOGGLE_{n}_DEFAULT_{profile}}
            evaluate n({n}+1)
        }
    }

    scope profile {
        constant CE(0)
        constant TE(1)
        constant JP(2)
        constant CUSTOM(3)
    }

    // @ Description
    // Profile strings
    profile_ce:; db "Community", 0x00
    profile_te:; db "Tournament", 0x00
    profile_jp:; db "Japanese", 0x00
    profile_custom:; db "Custom", 0x00
    current_profile:; db "Current Profile: ", 0x00
    toggles_note_line_1:; db "Press A to load selected profile,", 0x00
    toggles_note_line_2:; db "which will affect all settings.", 0x00
    OS.align(4)

    string_table_profile:
    dw profile_ce
    dw profile_te
    dw profile_jp
    dw profile_custom

    // @ Description
    // FPS strings
    fps_off:; db "OFF", 0x00
    fps_normal:; db "NORMAL", 0x00
    fps_overclocked:; db "OVERCLOCKED", 0x00
    OS.align(4)

    string_table_fps:
    dw fps_off
    dw fps_normal
    dw fps_overclocked

    // @ Description
    // Special Model Display strings
    model_off:; db "OFF", 0x00
    model_hitbox:; db "HITBOX", 0x00
    model_skeleton:; db "SKELETON", 0x00
    model_ecb:; db "ECB", 0x00
    OS.align(4)

    string_table_model:
    dw model_off
    dw model_hitbox
    dw model_ecb
    dw model_skeleton

    // @ Description
    // SSS Layout strings
    sss_layout_normal:; db "NORMAL", 0x00
    sss_layout_tournament:; db "TOURNAMENT", 0x00
    OS.align(4)

    string_table_sss_layout:
    dw sss_layout_normal
    dw sss_layout_tournament

    scope sss {
        constant NORMAL(0)
        constant TOURNAMENT(1)
    }
    
    // @ Description
    // Contains list of submenus.
    head_super_menu:
    Menu.entry("Load Profile:", Menu.type.U8, OS.FALSE, 0, 2, load_profile_, string_table_profile, OS.NULL, pc() + 20)
    Menu.entry_title("Remix Settings", set_info_2_, pc() + 20)
    Menu.entry_title("Music Settings", set_info_3_, pc() + 20)
    Menu.entry_title("Stage Settings", set_info_4_, pc() + 20)
    Menu.entry_title("Screen Adjust", load_screen_adjust_, OS.NULL)

    // @ Description 
    // Miscellaneous Toggles
    head_remix_settings:
    entry_practice_overlay:;            entry_bool("Color Overlays", OS.FALSE, OS.FALSE, OS.FALSE, entry_disable_cinematic_camera)
    entry_disable_cinematic_camera:;    entry_bool("Disable Cinematic Camera", OS.FALSE, OS.FALSE, OS.FALSE, entry_flash_on_z_cancel)
    entry_flash_on_z_cancel:;           entry_bool("Flash On Z-Cancel", OS.FALSE, OS.FALSE, OS.FALSE, entry_fps)
    entry_fps:;                         entry("FPS Display *BETA", Menu.type.U8, OS.FALSE, OS.FALSE, OS.FALSE, 0, 2, OS.NULL, string_table_fps, OS.NULL, entry_special_model)
    entry_special_model:;               entry("Special Model Display", Menu.type.U8, OS.FALSE, OS.FALSE, OS.FALSE, 0, 3, OS.NULL, string_table_model, OS.NULL, entry_hold_to_pause)
    entry_hold_to_pause:;               entry_bool("Hold To Pause", OS.TRUE, OS.TRUE, OS.TRUE, entry_improved_combo_meter)
    entry_improved_combo_meter:;        entry_bool("Improved Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, entry_tech_chase_combo_meter)
    entry_tech_chase_combo_meter:;      entry_bool("Tech Chase Combo Meter", OS.TRUE, OS.FALSE, OS.TRUE, entry_vs_mode_combo_meter)
    entry_vs_mode_combo_meter:;         entry_bool("VS Mode Combo Meter *BETA", OS.FALSE, OS.FALSE, OS.FALSE, entry_1v1_combo_meter_swap)
    entry_1v1_combo_meter_swap:;        entry_bool("1V1 Combo Meter Swap *BETA", OS.FALSE, OS.FALSE, OS.FALSE, entry_improved_ai)
    entry_improved_ai:;                 entry_bool("Improved AI", OS.TRUE, OS.FALSE, OS.TRUE, entry_neutral_spawns)
    entry_neutral_spawns:;              entry_bool("Neutral Spawns", OS.TRUE, OS.TRUE, OS.TRUE, entry_skip_results_screen)
    entry_skip_results_screen:;         entry_bool("Skip Results Screen", OS.FALSE, OS.FALSE, OS.FALSE, entry_stereo_sound)
    entry_stereo_sound:;                entry_bool("Stereo Sound", OS.TRUE, OS.TRUE, OS.TRUE, entry_stock_handicap)
    entry_stock_handicap:;              entry_bool("Stock Handicap", OS.TRUE, OS.FALSE, OS.TRUE, entry_salty_runback)
    entry_salty_runback:;               entry_bool("Salty Runback", OS.TRUE, OS.FALSE, OS.TRUE, entry_widescreen)
    entry_widescreen:;                  entry_bool("Widescreen", OS.FALSE, OS.FALSE, OS.FALSE, entry_japanese_hitlag)
    entry_japanese_hitlag:;             entry_bool("Japanese Hitlag", OS.FALSE, OS.FALSE, OS.TRUE, entry_momentum_slide)
    entry_momentum_slide:;              entry_bool("Momentum Slide", OS.FALSE, OS.FALSE, OS.TRUE, entry_variant_random)
    entry_variant_random:;              entry_bool("Random Select With Variants", OS.FALSE, OS.FALSE, OS.FALSE, OS.NULL)

    // @ Description
    // Random Music Toggles
    head_music_settings:
    entry_play_music:;                      entry_bool("Play Music", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_music:;                    entry_bool("Random Music", OS.FALSE, OS.FALSE, OS.FALSE, pc() + 20)
    entry_random_music_bonus:;              entry_bool("Bonus", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 12)
    entry_random_music_congo_jungle:;       entry_bool("Congo Jungle", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_credits:;            entry_bool("Credits", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 12)
    entry_random_music_data:;               entry_bool("Data", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 12)
    entry_random_music_dream_land:;         entry_bool("Dream Land", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_music_duel_zone:;          entry_bool("Duel Zone", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_music_final_destination:;  entry_bool("Final Destination", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 24)
    entry_random_music_how_to_play:;        entry_bool("How To Play", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_music_hyrule_castle:;      entry_bool("Hyrule Castle", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_meta_crystal:;       entry_bool("Meta Crystal", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_mushroom_kingdom:;   entry_bool("Mushroom Kingdom", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 24)
    entry_random_music_peachs_castle:;      entry_bool("Peach's Castle", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_planet_zebes:;       entry_bool("Planet Zebes", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_saffron_city:;       entry_bool("Saffron City", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)
    entry_random_music_sector_z:;           entry_bool("Sector Z", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_music_yoshis_island:;      entry_bool("Yoshi's Island", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 20)

    // Add custom MIDIs
    define toggled_custom_MIDIs(0)
    define last_toggled_custom_MIDI(0)
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            evaluate last_toggled_custom_MIDI({n})
            evaluate toggled_custom_MIDIs({toggled_custom_MIDIs}+1)
        }
        evaluate n({n}+1)
    }

    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        entry_random_music_{n}:                                        // always create the label even if we don't create the entry
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            if ({n} == {last_toggled_custom_MIDI}) {
                evaluate next(OS.NULL)
            } else {
                evaluate m({n}+1)
                evaluate next(entry_random_music_{m})
            }
            entry_bool("{MIDI.MIDI_{n}_NAME}", OS.TRUE, OS.TRUE, OS.TRUE, {next})
        }
        evaluate n({n}+1)
    }

    // @ Description
    // Random Stage Toggles
    head_stage_settings:
    entry_sss_layout:;                          entry("Stage Select Layout", Menu.type.U8, sss.NORMAL, sss.TOURNAMENT, sss.NORMAL, 0, 1, OS.NULL, string_table_sss_layout, OS.NULL, entry_random_stage_title)
    entry_random_stage_title:;                  Menu.entry_title("Random Stage Toggles:", OS.NULL, entry_random_stage_congo_jungle)
    entry_random_stage_congo_jungle:;           entry_bool("Congo Jungle", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_dream_land:;             entry_bool("Dream Land", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 16)
    entry_random_stage_dream_land_beta_1:;      entry_bool("Dream Land Beta 1", OS.FALSE, OS.FALSE, OS.FALSE, pc() + 24)
    entry_random_stage_dream_land_beta_2:;      entry_bool("Dream Land Beta 2", OS.FALSE, OS.FALSE, OS.FALSE, pc() + 24)
    entry_random_stage_duel_zone:;              entry_bool("Duel Zone", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 16)
    entry_random_stage_final_destination:;      entry_bool("Final Destination", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 24)
    entry_random_stage_how_to_play:;            entry_bool("How to Play", OS.FALSE, OS.FALSE, OS.FALSE, pc() + 16)
    entry_random_stage_hyrule_castle:;          entry_bool("Hyrule Castle", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_meta_crystal:;           entry_bool("Meta Crystal", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_mushroom_kingdom:;       entry_bool("Mushroom Kingdom", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 24)
    entry_random_stage_peachs_castle:;          entry_bool("Peach's Castle", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_planet_zebes:;           entry_bool("Planet Zebes", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_saffron_city:;           entry_bool("Saffron City", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_sector_z:;               entry_bool("Sector Z", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 16)
    entry_random_stage_yoshis_island:;          entry_bool("Yoshi's Island", OS.TRUE, OS.FALSE, OS.TRUE, pc() + 20)
    entry_random_stage_mini_yoshis_island:;     entry_bool("Mini Yoshi's Island", OS.TRUE, OS.TRUE, OS.TRUE, pc() + 24)

    // Add custom stages
    define toggled_custom_stages(0)
    define last_toggled_custom_stage(0)
    evaluate n(0x29)
    while {n} <= Stages.id.MAX_STAGE_ID {
        evaluate can_toggle({Stages.STAGE_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            evaluate last_toggled_custom_stage({n})
            evaluate toggled_custom_stages({toggled_custom_stages}+1)
        }
        evaluate n({n}+1)
    }

    evaluate n(0x29)
    while {n} <= Stages.id.MAX_STAGE_ID {
        entry_random_stage_{n}:                                        // always create the label even if we don't create the entry
        evaluate can_toggle({Stages.STAGE_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            if ({n} == {last_toggled_custom_stage}) {
                evaluate next(OS.NULL)
            } else {
                evaluate m({n}+1)
                evaluate next(entry_random_stage_{m})
            }
            entry_bool({Stages.STAGE_{n}_TITLE}, OS.TRUE, {Stages.STAGE_{n}_LEGAL}, OS.TRUE, {next})
        }
        evaluate n({n}+1)
    }

    // @ Description
    // SRAM blocks for toggle saving.
    block_misc:; SRAM.block(20 * 4)
    block_music:; SRAM.block((18 + {toggled_custom_MIDIs}) * 4)
    block_stages:; SRAM.block((17 + {toggled_custom_stages}) * 4)

    profile_defaults_CE:; write_defaults_for(CE)
    profile_defaults_TE:; write_defaults_for(TE)
    profile_defaults_JP:; write_defaults_for(JP)

    // @ Description
    // This function will load toggle settings based on the selected profile
    scope load_profile_: {
        addiu   sp, sp,-0x001C                 // allocate stack space
        sw      ra, 0x0004(sp)                 // ~
        sw      t0, 0x0008(sp)                 // ~
        sw      t1, 0x000C(sp)                 // ~
        sw      t2, 0x0010(sp)                 // ~
        sw      t3, 0x0014(sp)                 // ~
        sw      t4, 0x0018(sp)                 // save registers

        li      t0, head_super_menu            // t0 = address of menu entry
        lw      t0, 0x0004(t0)                 // t0 = selected profile
        lli     t1, profile.CE                 // t1 = profile.CE
        li      t2, profile_defaults_CE        // t2 = address of CE defaults
        beq     t0, t1, _load                  // if (selected profile is CE), skip to _load
        nop                                    // otherwise apply CE defaults:
        lli     t1, profile.TE                 // t1 = profile.TE
        li      t2, profile_defaults_TE        // t2 = address of TE defaults
        beq     t0, t1, _load                  // if (selected profile is TE), skip to _load
        nop                                    // otherwise apply TE defaults:
        li      t2, profile_defaults_JP        // t2 = address of JP defaults

        _load:
        li      t0, head_remix_settings        // t0 = first remix setting entry address

        _begin:
        addu    t3, r0, t0                     // t3 = head

        _loop:
        beqz    t0, _next                      // if (entry = null), go to next
        nop

        // skip titles
        lli     t4, Menu.type.TITLE            // t4 = title type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t4, t1, _skip                  // if (type == title), skip
        nop

        lw      t1, 0x0000(t2)                 // t1 = default profile value
        sw      t1, 0x0004(t0)                 // store default value as current value
        addiu   t2, t2, 0x0004                 // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)                 // t0 = entry->next
        b       _loop                          // check again
        nop

        _next:
        li      t1, head_remix_settings        // t1 = first remix setting entry address
        li      t0, head_music_settings        // t0 = first music setting entry address
        beq     t3, t1, _begin                 // if (finished the remix block) then do the music block next
        nop                                    // ~
        or      t1, r0, t0                     // t1 = first music setting entry address
        li      t0, head_stage_settings        // t0 = first stage setting entry address
        beq     t3, t1, _begin                 // if (finished the music block) then do the random stage block next
        nop                                    // ~

        _end:
        lw      ra, 0x0004(sp)                 // ~
        lw      t0, 0x0008(sp)                 // ~
        lw      t1, 0x000C(sp)                 // ~
        lw      t2, 0x0010(sp)                 // ~
        lw      t3, 0x0014(sp)                 // ~
        lw      t4, 0x0018(sp)                 // restore registers
        addiu   sp, sp, 0x001C                 // deallocate stack sapce
        jr      ra                             // return
        nop
    }

    // @ Description
    // This function will figure out the current profile based on the current toggle values
    // @ Returns
    // v0 - current profile_id
    scope get_current_profile_: {
        addiu   sp, sp,-0x0020                 // allocate stack space
        sw      ra, 0x0004(sp)                 // ~
        sw      t0, 0x0008(sp)                 // ~
        sw      t1, 0x000C(sp)                 // ~
        sw      t2, 0x0010(sp)                 // ~
        sw      t3, 0x0014(sp)                 // ~
        sw      t4, 0x0018(sp)                 // ~
        sw      t5, 0x001C(sp)                 // save registers

        lli     v0, profile.CE                 // v0 = CE

        li      t2, profile_defaults_CE        // t2 = address of CE defaults

        _load:
        addu    t5, r0, t2                     // t5 = defaults table
        li      t0, head_remix_settings        // t0 = first remix setting entry address

        _begin:
        addu    t4, r0, t0                     // t4 = head

        _loop:
        beqz    t0, _next                      // if (entry = null), go to next
        nop

        // skip titles when importing
        lli     t3, Menu.type.TITLE            // t3 = title type
        lw      t1, 0x0000(t0)                 // t1 = type
        beq     t3, t1, _skip                  // if (type == title), skip
        nop

        lw      t1, 0x0000(t2)                 // t1 = default profile value
        lw      t3, 0x0004(t0)                 // t3 = current value
        bne     t1, t3, _next_profile          // if (default value != current value) then this profile isn't loaded
        nop
        addiu   t2, t2, 0x0004                 // increment ram_address

        _skip:
        lw      t0, 0x001C(t0)                 // t0 = entry->next
        b       _loop                          // check again
        nop

        _next:
        or      t3, r0, t0                     // save t0
        li      t1, head_remix_settings        // t1 = first remix setting entry address
        li      t0, head_music_settings        // t0 = first music setting entry address
        beq     t4, t1, _begin                 // if (finished the remix block) then do the music block next
        nop                                    // ~
        or      t1, r0, t0                     // t1 = first music setting entry address
        li      t0, head_stage_settings        // t0 = first stage setting entry address
        beq     t4, t1, _begin                 // if (finished the music block) then do the random stage block next
        nop                                    // ~
        or      t0, r0, t3                     // restore t0

        _next_profile:
        beqz    t0, _end                       // if (entry = null), then we have the correct profile in v0
        nop
        lli     v0, profile.TE                 // v0 = TE
        li      t1, profile_defaults_CE        // t1 = address of CE defaults
        li      t3, profile_defaults_TE        // t3 = address of TE defaults
        beql    t5, t1, _load                  // if (just confirmed not CE) then check if TE next
        or      t2, r0, t3                     // ~

        lli     v0, profile.JP                 // v0 = JP
        li      t1, profile_defaults_TE        // t1 = address of TE defaults
        li      t3, profile_defaults_JP        // t3 = address of JP defaults
        beql    t5, t1, _load                  // if (just confirmed not TE) then check if JP next
        or      t2, r0, t3                     // ~

        // if we made it here, it's not CE or TE
        lli     v0, profile.CUSTOM             // v0 = CUSTOM

        _end:
        lw      ra, 0x0004(sp)                 // ~
        lw      t0, 0x0008(sp)                 // ~
        lw      t1, 0x000C(sp)                 // ~
        lw      t2, 0x0010(sp)                 // ~
        lw      t3, 0x0014(sp)                 // ~
        lw      t4, 0x0018(sp)                 // ~
        lw      t5, 0x001C(sp)                 // restore registers
        addiu   sp, sp, 0x0020                 // deallocate stack sapce
        jr      ra                             // return
        nop
    }
}


} // __TOGGLES__
