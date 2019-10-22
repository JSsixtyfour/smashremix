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
        lbu     s4, 0x0023(v0)              // s4 = character id (original line 1)
        divu    t7, at                      // original line 2
        sll     t5, s4, 0x2                 // original line 3
        b       _get_id                     // get id
        or      at, s4, r0                  // at = character id
        
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
    // Patch which substitutes a working character id for drawing the series character logo.
    // TODO: add support for extending the logo tables, rather than using id substitution
    scope winner_logo_fix_: {
        // get character id (FFA)
        OS.patch_start(0x151DA8, 0x80132C08)
        jal     winner_logo_fix_
        nop
        OS.patch_end()
        // get character id (team battle)
        OS.patch_start(0x151DD4, 0x80132C34)
        jal     winner_logo_fix_
        nop
        OS.patch_end()
        
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      ra, 0x0004(sp)              // store ra
        jal     0x80133148                  // Result.getCharFromPlayer (original line 1)
        or      a0, v0, r0                  // original line 2
        sll     v0, v0, 0x0002              // v0 = character id * 4
        li      t6, Character.winner_logo.table
        addu    t6, t6, v0                  // t6 = winner_logo.table + (id * 4)
        lw      v0, 0x0000(t6)              // v0 = new character id
        lw      ra, 0x0004(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0008              // deallocate stack space
    }
    
    // @ Description
    // Temporary replacement subroutine which makes Falco refuse to clap.
    // TODO: remove this patch once menu arrays are added for custom characters.
    scope falco_clap_fix_: {
        OS.patch_start(0x15266C, 0x801334CC)
        j       falco_clap_fix_
        nop
        OS.patch_end()
        
        lui     v0, 0x0001                  // original line 1
        ori     t6, r0, Character.id.FALCO  // t6 = id.FALCO
        bne     t6, a0, _return_clap        // if id != id.FALCO, _return_clap
        sw      a0, 0x0000(sp)              // original line 2 (useless?)
        jr      ra                          // return
        ori     v0, v0, 0x0004              // v0 = character selected action
        _return_clap:
        jr      ra                          // return (original line 3)
        ori     v0, v0, 0x0005              // v0 = clap action (original line 4)
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
    // Adds results screen parameters for a character.
    // @ Arguments
    // id - character id to modify
    // fgm - announcer voice FGM id
    // logo - character id to copy logo from (0-11)
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
        
        // add logo character id
        Character.table_patch_start(winner_logo, {id}, 0x4)
        dw  {logo}
        OS.patch_end()
        
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
    add_to_results_screen(Character.id.FALCO, 0x2D6, Character.id.FOX, Character.id.FOX, 170, FALCO, 30, 1, 0x45)
    add_to_results_screen(Character.id.GND, 0x2C5, Character.id.LINK, Character.id.CAPTAIN, 185, GANONDORF, 20, 0.6, 0x43)
    add_to_results_screen(Character.id.YLINK, 0x2E5, Character.id.LINK, Character.id.LINK, 185, YOUNG LINK, 20, 0.65, 0x44)
    // TODO: doc announcer voice
    add_to_results_screen(Character.id.DRM, 0x1F3, Character.id.MARIO, Character.id.MARIO, 185, DR. MARIO, 20, 0.75, 0x46)
}