// Training.asm (functions by Fray, menu implementation by Cyjorg)
if !{defined __TRAINING__} {
define __TRAINING__()
print "included Training.asm\n"

// @ Description
// This file contains functions and defines structs intended to assist training mode modifications.

include "Character.asm"
include "Color.asm"
include "Data.asm"
include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "Menu.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"
include "Toggles.asm"

scope Training {
    // @ Description
    // Byte, determines whether the player is able to control the training mode menu, regardless of
    // if it is currently being displayed. 01 = disable control, 02 = enable control
    constant toggle_menu(0x80190979)
    constant BOTH_DOWN(0x01)
    constant SSB_UP(0x02)
    constant CUSTOM_UP(0x03)
    
    // @ Description
    // Byte, contains the training mode stage id
    constant stage(0x80190969)
    
    // @ Description
    // Contains game settings, as well as information and properties for each port.
    // PORT STRUCT INFO
    // @ ID         [read/write]
    // Contains character ID, see character.asm for list.
    // @ type       [read/write]
    // 0x00 = MAN, 0x01 = COM, 0x02 = NOT
    // @ costume    [read/write]
    // Contains the costume ID.
    // @ percent    [read/write]
    // Contains the percentage to be applied to the character through custom menu functions.
    // @ spawn_id    [read/write]
    // Contains the player's spawn id.
    // 0x00 = port 1, 0x01 = port 2, 0x02 = port 3, 0x03 = port 4, 0x04 = custom
    // @ spawn_pos
    // Contains custom spawn position.
    // float32 xpos, float32 ypos
    // @ spawn_dir
    // Contains custom spawn direction.
    constant FACE_LEFT(0xFFFFFFFF)
    constant FACE_RIGHT(0x00000001)
    // 0xFFFFFFFF = left, 0x00000001 = right
    scope struct {
        scope port_1: {
            ID:
            dw 0
            type:
            dw 2
            costume:
            dw 0
            percent:
            dw 0
            spawn_id:
            dw 0
            spawn_pos:
            float32 0,0
            spawn_dir:
            dw FACE_LEFT
        }
        scope port_2: {
            ID:
            dw 0
            type:
            dw 2
            costume:
            dw 0
            percent:
            dw 0
            spawn_id:
            dw 0
            spawn_pos:
            float32 0,0
            spawn_dir:
            dw FACE_LEFT
        }
        scope port_3: {
            ID:
            dw 0
            type:
            dw 2
            costume:
            dw 0
            percent:
            dw 0
            spawn_id:
            dw 0
            spawn_pos:
            float32 0,0
            spawn_dir:
            dw FACE_LEFT
        }
        scope port_4: {
            ID:
            dw 0
            type:
            dw 2
            costume:
            dw 0
            percent:
            dw 0
            spawn_id:
            dw 0
            spawn_pos:
            float32 0,0
            spawn_dir:
            dw FACE_LEFT
        }
        
        // @ Description
        // table of pointers to each port struct
        table:
        dw port_1
        dw port_2
        dw port_3
        dw port_4
    }

    // @ Description
    // This hook loads various character properties when training mode is loaded
    scope load_character_: {
        OS.patch_start(0x00116AA0, 0x80190280)
        jal load_character_
        nop
        OS.patch_end()
        
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      t4, 0x0018(sp)              // ~
        sw      t5, 0x001C(sp)              // store ra, t0-t5
        
        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t1 = match info address
        li      t1, reset_counter           // t1 = reset counter
        lw      t1, 0x0000(t1)              // t1 = reset counter value
        beq     t1, r0, _initialize_p1      // initialize values if load from sss is detected
        ori     t3, r0, Character.id.NONE   // t3 = character id: NONE
        li      t4, entry_id_to_char_id     // t4 = entry_id_to_char_id table address
        
        _load_p1:
        addiu   t0, Global.vs.P_OFFSET      // t0 = p1 info
        li      t1, struct.port_1.ID        // ~
        lw      t1, 0x0000(t1)              // t1 = port 1 training char id
        addu    t1, t1, t4                  // t1 = address of char id
        lb      t1, 0x0000(t1)              // t1 = char id
        sb      t1, 0x0003(t0)              // store char id
        li      t1, struct.port_1.type      // ~
        lw      t1, 0x0000(t1)              // t1 = port 1 type
        sb      t1, 0x0002(t0)              // store type
        li      t1, struct.port_1.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 1 costume
        sb      t1, 0x0006(t0)              // store costume
        _load_p2:
        addiu   t0, Global.vs.P_DIFF        // t0 = p2 info
        li      t1, struct.port_2.ID        // ~
        lw      t1, 0x0000(t1)              // t1 = port 2 training char id
        addu    t1, t1, t4                  // t1 = address of char id
        lb      t1, 0x0000(t1)              // t1 = char id
        sb      t1, 0x0003(t0)              // store char id
        li      t1, struct.port_2.type      // ~
        lw      t1, 0x0000(t1)              // t1 = port 2 type
        sb      t1, 0x0002(t0)              // store type
        li      t1, struct.port_2.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 2 costume
        sb      t1, 0x0006(t0)              // store costume
        _load_p3:
        addiu   t0, Global.vs.P_DIFF        // t0 = p3 info
        li      t1, struct.port_3.ID        // ~
        lw      t1, 0x0000(t1)              // t1 = port 3 training char id
        addu    t1, t1, t4                  // t1 = address of char id
        lb      t1, 0x0000(t1)              // t1 = char id
        sb      t1, 0x0003(t0)              // store char id
        li      t1, struct.port_3.type      // ~
        lw      t1, 0x0000(t1)              // t1 = port 3 type
        sb      t1, 0x0002(t0)              // store type
        li      t1, struct.port_3.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 3 costume
        sb      t1, 0x0006(t0)              // store costume
        _load_p4:
        addiu   t0, Global.vs.P_DIFF        // t0 = p4 info
        li      t1, struct.port_4.ID        // ~
        lw      t1, 0x0000(t1)              // t1 = port 4 training char id
        addu    t1, t1, t4                  // t1 = address of char id
        lb      t1, 0x0000(t1)              // t1 = char id
        sb      t1, 0x0003(t0)              // store char id
        li      t1, struct.port_4.type      // ~
        lw      t1, 0x0000(t1)              // t1 = port 4 type
        sb      t1, 0x0002(t0)              // store type
        li      t1, struct.port_4.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 4 costume
        sb      t1, 0x0006(t0)              // store costume
        j       _end                        // jump to end
        nop
        
        _initialize_p1:
        li      t4, char_id_to_entry_id     // t4 = char_id_to_entry_id table address
        addiu   t0, Global.vs.P_OFFSET      // t0 = p1 info
        lbu     t1, 0x0003(t0)              // t1 = char id
        addu    t5, t1, t4                  // t5 = address of training char id
        lb      t5, 0x0000(t5)              // t5 = training char id
        li      t2, struct.port_1.ID        // t2 = struct id address
        bnel    t1, t3, _initialize_p1+0x24 // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_1.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        li      t2, struct.port_1.costume   // t2 = struct costume address
        sw      t1, 0x0000(t2)              // store costume id in struct
        li      t2, struct.port_1.percent   // t2 = struct percent address
        sw      r0, 0x0000(t2)              // reset percent
        _initialize_p2:
        addiu   t0, Global.vs.P_DIFF        // t0 = p2 info
        lbu     t1, 0x0003(t0)              // t1 = char id
        addu    t5, t1, t4                  // t5 = address of training char id
        lb      t5, 0x0000(t5)              // t5 = training char id
        li      t2, struct.port_2.ID        // t2 = struct id address
        bnel    t1, t3, _initialize_p2+0x20 // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_2.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        li      t2, struct.port_2.costume   // t2 = struct costume address
        sw      t1, 0x0000(t2)              // store costume id in struct
        li      t2, struct.port_2.percent   // t2 = struct percent address
        sw      r0, 0x0000(t2)              // reset percent
        _initialize_p3:
        addiu   t0, Global.vs.P_DIFF        // t0 = p3 info
        lbu     t1, 0x0003(t0)              // t1 = char id
        addu    t5, t1, t4                  // t5 = address of training char id
        lb      t5, 0x0000(t5)              // t5 = training char id
        li      t2, struct.port_3.ID        // t2 = struct id address
        bnel    t1, t3, _initialize_p3+0x20 // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_3.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        li      t2, struct.port_3.costume   // t2 = struct costume address
        sw      t1, 0x0000(t2)              // store costume id in struct
        li      t2, struct.port_3.percent   // t2 = struct percent address
        sw      r0, 0x0000(t2)              // reset percent
        _initialize_p4:
        addiu   t0, Global.vs.P_DIFF        // t0 = p4 info
        lbu     t1, 0x0003(t0)              // t1 = char id
        addu    t5, t1, t4                  // t5 = address of training char id
        lb      t5, 0x0000(t5)              // t5 = training char id
        li      t2, struct.port_4.ID        // t2 = struct id address
        bnel    t1, t3, _initialize_p4+0x20 // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_4.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        li      t2, struct.port_4.costume   // t2 = struct costume address
        sw      t1, 0x0000(t2)              // store costume id in struct
        li      t2, struct.port_4.percent   // t2 = struct percent address
        sw      r0, 0x0000(t2)              // reset percent
        
        jal     struct_to_tail_             // update menu
        nop
        
        _end:
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      t4, 0x0018(sp)              // ~
        lw      t5, 0x001C(sp)              // load t0-t5
        jal     0x801906D0                  // original line 1
        nop                                 // original line 2
        lw      ra, 0x0004(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }    
    
    // @ Description
    // Initializes character properties on death/reset. This hook runs in all modes.
   scope init_character_: {
      OS.patch_start(0x0005321C, 0x800D7A1C)
//      beq     t8, at, 0x800D7A4C          // original line 1
//      sw      t7, 0x0008(v1)              // original line 2
        j       init_character_
        nop
        OS.patch_end()

        // t7 holds player percent
        // 0x000D(v1) player port
        // v1 holds player struct

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // store registers

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen_id
        ori     t1, r0, 0x0036              // ~
        bne     t0, t1, _end                // skip if screen_id != training mode
        nop
        li      t1, 0x800D86B4              // ~
        bne     ra, t1, _end                // skip if ra != 800D86B4
        nop

        _update_spawn_dir:
        li      t0, struct.table            // t0 = struct table
        lbu     t1, 0x000D(v1)              // ~
        sll     t1, t1, 0x2                 // t1 = offset (player port * 4)
        add     t2, t0, t1                  // t0 = struct table + offset
        lw      t2, 0x0000(t2)              // t0 = port struct address
        lw      t0, 0x0010(t2)              // ~
        slti    t0, t0, 0x4                 // t1 = 1 if spawn_id > 0x4; else t1 = 0
        bnez    t0, _update_percent         // skip if spawn_id != custom
        nop
        lw      t0, 0x001C(t2)              // t1 = spawn_dir
        sw      t0, 0x0044(v1)              // player facing direction = spawn_dir
        
        _update_percent:
        li      t0, toggle_table            // t0 = toggle table
        add     t0, t0, t1                  // t0 = toggle table + offset
        lw      t0, 0x0000(t0)              // t0 = entry_percent_toggle_px
        lw      t1, 0x0004(t0)              // t1 = is_enabled
        bnel    t1, r0, _end                // ~
        lw      t7, 0x000C(t2)              // if (is_enabled), t7 = updated percent

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        beq     t8, at, _take_branch        // original line 1
        sw      t7, 0x002C(v1)              // original line 2
        j       0x800D7A24                  // return (don't take branch)
        nop

        _take_branch:
        j       0x800D7A4C                  // return (take branch)
        nop
    }
      
    // @ Description
    // This hook runs when training is loaded from stage select, but not when reset is used
    scope load_from_sss_: {
        OS.patch_start(0x00116E20, 0x80190600)
        j   load_from_sss_
        nop
        _load_from_sss_return:
        OS.patch_end()
        
        addiu   t6, t6, 0x5240              // original line 1
        addiu   a0, a0, 0x0870              // original line 2
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        li      t0, reset_counter           // t0 = reset_counter
        sw      r0, 0x0000(t0)              // reset reset_counter value
        
        _initialize_spawns:
        li      t0, struct.port_1.spawn_id  // t0 = port 1 spawn id address
        or      t1, r0, r0                  // t1 = port 1 id
        sw      t1, 0x0000(t0)              // save port id as spawn id
        li      t0, struct.port_2.spawn_id  // t0 = port 2 spawn id address
        addiu   t1, t1, 0x0001              // t1 = port 2 id
        sw      t1, 0x0000(t0)              // save port id as spawn id
        li      t0, struct.port_3.spawn_id  // t0 = port 3 spawn id address
        addiu   t1, t1, 0x0001              // t1 = port 3 id
        sw      t1, 0x0000(t0)              // save port id as spawn id
        li      t0, struct.port_4.spawn_id  // t0 = port 4 spawn id address
        addiu   t1, t1, 0x0001              // t1 = port 4 id
        sw      t1, 0x0000(t0)              // save port id as spawn id

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _load_from_sss_return
        nop
    }
    
    // @ Description
    // This hook runs when training is loaded from reset, but not from the stage select screen
    // it also runs when training mode exit is used
    scope load_from_reset_: {
        OS.patch_start(0x00116E88, 0x80190668)
        j   load_from_reset_
        nop
        _exit_game:
        OS.patch_end()
        
        // the original code: resets the game when the branch is taken, exits otherwise
        // bnez    t2, 0x80190654           // original line 1
        // nop                              // original line 2
        
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        
        li      t0, reset_counter           // t0 = reset_counter
        lw      t1, 0x0000(t0)              // t1 = reset_counter value
        addiu   t1, t1, 0x00001             // t1 = reset counter value + 1
        sw      t1, 0x0000(t0)              // store reset_counter value
        li      t1, advance_frame_.freeze   // ~
        sw      r0, 0x0000(t1)              // freeze = false
        bnez    t2, _reset_game             // modified original branch
        nop
        
        sw      r0, 0x0000(t0)              // reset reset_counter value
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _exit_game
        nop
        
        _reset_game:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       0x80190654
        nop
    }
    
    // @ Description
    // This hook replaces a branch which determines whether the in-game advance frame
    // function should be called while in training mode.
    // Additionally, contains a shortcut for toggling hitbox mode.
    scope advance_frame_: {
        OS.patch_start(0x00114260, 0x8018DA40)
        j   advance_frame_
        nop
        _advance_frame_return:
        OS.patch_end()
        
        // the original code: skips the frame advance function if the branch is taken
        // bnez    v0, 0x8018DA58           // original line 1
        // lui     a0, 0x8013               // original line 2
        // v0 = bool skip_advance
        lui     a0, 0x8013                  // original line 2
        OS.save_registers()
        move    t6, v0                      // t6 = bool skip_advance
        _check_dl:
        // check for a DPAD DOWN press, toggles hitbox mode if detected
        lli     a0, Joypad.DD               // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool dd_pressed
        nop
        beqz    v0, _check_frame_advance    // if (!dd_pressed), skip
        nop
        li      t1, Toggles.entry_hitbox_mode
        lw      t0, 0x0004(t1)              // t0 = bool hitbox_mode
        xori    t0, t0, 0x0001              // 0 -> 1 or 1 -> 0 (flip bool)
        sw      t0, 0x0004(t1)              // store bool hitbox_mode
        
        _check_frame_advance:
        li      t1, freeze                  // t1 = freeze
        li      t2, du_pressed              // t2 = du_pressed
        li      t3, dr_pressed              // t3 = dr_pressed
        lw      t4, 0x0000(t2)              // t4 = bool du_pressed
        lw      t5, 0x0000(t3)              // t5 = bool dr_pressed
        or      t0, t4, t5                  // ~
        bnez    t0, _skip_input             // if (du_pressed) or (dr_pressed), skip checking for inputs
        nop
        
        _check_du:
        // check for a DPAD UP press and store the result
        lli     a0, Joypad.DU               // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool du_pressed
        nop
        sw      v0, 0x0000(t2)              // store bool du_pressed
        
        _check_dr:
        // check for a DPAD RIGHT press and store the result
        lli     a0, Joypad.DR               // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.TURBO            // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool dr_pressed
        nop
        sw      v0, 0x0000(t3)              // store bool dr_pressed
        
        _skip_input:
        // replicate the original branch if skip_advance = true
        li      ra, 0x8018DA58              // return value - skip
        bnez    t6, _skip                   // if (skip_advance), skip
        nop
        
        _load_du:
        // toggle freeze if a dpad up input is given
        lw      t4, 0x0000(t2)              // t4 = bool du_pressed
        beqz    t4, _load_dr                // if (!du_pressed), load_dr
        nop
        lw      t0, 0x0000(t1)              // t0 = bool freeze
        xori    t0, t0, 0x0001              // 0 -> 1 or 1 -> 0 (flip bool)
        sw      t0, 0x0000(t1)              // store bool freeze
       
        _load_dr:
        // advance one frame and freeze if a dpad right input is given
        li      ra, _advance_frame_return   // return value - advance frame
        lw      t5, 0x0000(t3)              // t5 = bool dr_pressed
        beqz    t5, _check_freeze           // if !(dr_pressed), check freeze
        nop
        lli     t0, 0x0001                  // ~
        sw      t0, 0x0000(t1)              // freeze = true
        b       _end                        // force advance frame
        nop
        
        _check_freeze:
        lw      t0, 0x0000(t1)              // t0 = bool freeze
        beqz    t0, _end                    // if (!freeze), end
        nop
        li      ra, 0x8018DA50              // return value - freeze
        
        _end:
        sw      r0, 0x0000(t2)              // du_pressed = false
        sw      r0, 0x0000(t3)              // dr_pressed = false
        _skip:
        lw      at, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      v1, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // ~
        lw      a3, 0x001C(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // ~
        lw      t2, 0x0028(sp)              // ~
        lw      t3, 0x002C(sp)              // ~
        lw      t4, 0x0030(sp)              // ~
        lw      t5, 0x0034(sp)              // ~
        lw      t6, 0x0038(sp)              // ~
        lw      t7, 0x003C(sp)              // ~
        lw      t8, 0x0040(sp)              // ~
        lw      t9, 0x0044(sp)              // ~
        lw      s0, 0x0048(sp)              // ~
        lw      s1, 0x004C(sp)              // ~
        lw      s2, 0x0050(sp)              // ~
        lw      s3, 0x0054(sp)              // ~
        lw      s4, 0x0058(sp)              // ~
        lw      s5, 0x005C(sp)              // ~
        lw      s6, 0x0060(sp)              // ~
        lw      s7, 0x0064(sp)              // ~
        lw      s8, 0x0068(sp)              // restore registers (excluding ra)
        addiu   sp, sp, 0x0070              // deallocate stack space
        jr      ra
        nop 

        freeze:
        dw OS.FALSE
        
        du_pressed:
        dw OS.FALSE
        
        dr_pressed:
        dw OS.FALSE
    }
    
    // @ Description
    // This function will reset the player's % to 0
    // @ Arguments
    // a0 - address of the player struct
    scope reset_percent_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a1, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // store a1, ra

        lw      a1, 0x002C(a0)              // a1 = percentage
        sub     a1, r0, a1                  // a1 = 0 - percentage
        jal     Character.add_percent_      // subtract current percentage from itself
        nop

        lw      a1, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // load a1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This function will copy the player's current position to Training.struct.port_x.spawn_pos
    // as well as copying the player's facing direction to Training.struct.port_x.spawn_dir
    // @ Arguments
    // a0 - address of the player struct
    scope set_custom_spawn_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // store t0-t2
        lw      t0, 0x0024(a0)              // t0 = current action id
        ori     t1, r0, 0x000A              // t1 = standing action id
        bne     t0, t1, _end                // skip if current action id != standing
        nop
        
        li      t2, struct.table            // t2 = struct table address
        lbu     t0, 0x000D(a0)              // ~
        sll     t0, t0, 0x2                 // t0 = offset (player port * 4)
        add     t2, t2, t0                  // t2 = struct table + offset
        lw      t2, 0x0000(t2)              // t2 = port struct address
        lw      t0, 0x0078(a0)              // t0 = player position address
        lw      t1, 0x0000(t0)              // t1 = player x position
        sw      t1, 0x0014(t2)              // save player x position to struct
        lw      t1, 0x0004(t0)              // t1 = player y position
        sw      t1, 0x0018(t2)              // save player y position to struct
        lw      t1, 0x0044(a0)              // t1 = player facing direction
        sw      t1, 0x001C(t2)              // save player facing direction to struct
    
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // load t0-t2
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // A counter that tracks how many times the current training mode session has been reset.
    // This could be displayed on-screen, but is also useful for differentiating between loads from
    // stage select and loads from the reset function
    reset_counter:
    dw 0

    // @ Description
    // Runs the menu
    scope run_: {
        OS.save_registers()

        li      t0, toggle_menu             // t0 = address of toggle_menu
        lbu     t0, 0x0000(t0)              // t0 = toggle_menu
        
        lli     t1, BOTH_DOWN               // t1 = both menus are down
        beq     t0, t1, _end                // branch accordingly
        nop
        
        // draw advance_frame_ instructions
        lli     a0, 000160                  // a0 - x
        lli     a1, 000203                  // a1 - uly
        li      a2, dpad_up                 // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw shortcut instructions
        nop
        lli     a0, 000160                  // a0 - x
        lli     a1, 000212                  // a1 - uly
        li      a2, dpad_right              // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw shortcut instructions
        nop
        lli     a0, 000160                  // a0 - x
        lli     a1, 000221                  // a1 - uly
        li      a2, dpad_down               // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw shortcut instructions
        nop
        
        
        // draw reset counter
        lli     a0, 000098                  // a0 - ulx
        lli     a1, 000025                  // a1 - uly
        li      a2, reset_string            // a2 - address of string
        jal     Overlay.draw_string_        // draw "reset counter" string
        nop
        li      a2, reset_counter           // a2 = reset_count
        lw      a0, 0x0000(a2)              // a2 = (int) reset count
        jal     String.itoa_                // v0 = (string) reset count
        nop
        lli     a0, 000222                  // a0 - urx
        lli     a1, 000025                  // a1 - uly
        move    a2, v0                      // a2 - address of string
        jal     Overlay.draw_string_urx_    // draw reset count number
        nop
        
        // check if the ssb menu is up
        lli     t1, SSB_UP                  // t1 = ssb menu is up
        beq     t0, t1, _ssb_up             // branch accordingly
        nop
        
        // check if the custom menu is up
        lli     t1, CUSTOM_UP               // t1 = custom menu is up
        beq     t0, t1, _custom_up          // branch accordingly
        nop

        // otherwise skip
        b       _end
        nop

        _custom_up:
        // the first option in the custom training menu has it's next pointer modified for the
        // rest of the option based on the value it holds. this block updates the next pointer
        li      t0, info                    // t0 = info
        lw      t0, 0x0000(t0)              // t0 = address of head (entry)
        lw      t1, 0x0004(t0)              // t1 = entry.curr
        addiu   t1, t1,-0x0001              // t1 = entry.curr-- (p1 = 0, p2 = 1 etc.)
        sll     t1, t1, 0x0002              // t1 = offset
        li      t2, tail_table              // t2 = address of tail_table
        addu    t2, t2, t1                  // t2 = address of tail_table + offset
        lw      t2, 0x0000(t2)              // t2 = address of tail
        sw      t2, 0x001C(t0)              // entry.next = address of head

        // draw background
        lli     a0, Color.low.MENU_BG
        jal     Overlay.set_color_          // set fill color
        nop
        lli     a0, 000062                  // a0 - ulx
        lli     a1, 000043                  // a1 - uly
        lli     a2, 000196                  // a2 - width
        lli     a3, 000159                  // a3 - height
        jal     Overlay.draw_rectangle_     // draw background rectangle
        nop
        
        // update menu
        li      a0, info                    // a0 - address of Menu.info()
        jal     Menu.update_                // check for updates
        nop

        // draw menu
        li      a0, info                    // a0 - address of Menu.inf()
        jal     Menu.draw_                  // draw menu
        nop

        // check for b press
        lli     a0, Joypad.B                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool b_pressed
        nop
        beqz    v0, _end                    // if (!b_pressed), end
        nop
        li      t0, toggle_menu             // t0 = toggle_menu
        lli     t1, SSB_UP                  // ~
        sb      t1, 0x0000(t0)              // toggle menu = SSB_UP
        b       _end                        // end execution
        nop

        _ssb_up:
        // tell the user they can bring up the custom menu
        lli     a0, 000161                  // a0 - x
        lli     a1, 000050                  // a1 - uly
        li      a2, press_z                 // a2 - address of string
        jal     Overlay.draw_centered_str_  // draw custom menu instructions
        nop

        // check for z press
        lli     a0, Joypad.Z                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool z_pressed
        nop
        beqz    v0, _end                    // if (!z_pressed), end
        nop
        lli     a0, 0x0116                  // a0 - fgm_id
        jal     FGM.play_                   // play training menu start sound
        nop
        li      t0, toggle_menu             // t0 = toggle_menu
        lli     t1, CUSTOM_UP               // ~
        sb      t1, 0x0000(t0)              // toggle menu = CUSTOM_UP

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }
    // @ Description
    // Strings used to explain advance_frame_ shortcuts
    dpad_up:; db "DPAD UP - PAUSE AND RESUME", 0x00
    dpad_right:; db "DPAD RIGHT - FRAME ADVANCE", 0x00
    dpad_down:; db "DPAD DOWN - HITBOX DISPLAY", 0x00
    OS.align(4)
    
    // @ Description
    // String used for reset counter which appears while the training menu is up
    reset_string:; db "RESET COUNT", 0x00
    OS.align(4)
    
    
    // @ Description
    // Message/visual indicator to press Z for custom menu
    press_z:; db "PRESS Z FOR CUSTOM MENU", 0x00

    // @ Description
    // Type strings
    type_1:; db "HUMAN", 0x00
    type_2:; db "CPU", 0x00
    type_3:; db "DISABLED", 0x00
    OS.align(4)

    string_table_type:
    dw type_1
    dw type_2
    dw type_3

    // @ Description
    // Character Strings
    char_0x00:; db "MARIO" , 0x00
    char_0x01:; db "FOX", 0x00
    char_0x02:; db "DK", 0x00
    char_0x03:; db "SAMUS", 0x00
    char_0x04:; db "LUIGI", 0x00
    char_0x05:; db "LINK", 0x00
    char_0x06:; db "YOSHI", 0x00
    char_0x07:; db "C. FALCON", 0x00
    char_0x08:; db "KIRBY", 0x00
    char_0x09:; db "PIKACHU", 0x00
    char_0x0A:; db "JIGGLYPUFF", 0x00
    char_0x0B:; db "NESS", 0x00
    //char_0x0C:; db "MASTER HAND", 0x00
    char_0x0D:; db "METAL MARIO", 0x00
    char_0x0E:; db "POLY MARIO", 0x00
    char_0x0F:; db "POLY FOX", 0x00
    char_0x10:; db "POLY DK", 0x00
    char_0x11:; db "POLY SAMUS", 0x00
    char_0x12:; db "POLY LUIGI", 0x00
    char_0x13:; db "POLY LINK", 0x00
    char_0x14:; db "POLY YOSHI", 0x00
    char_0x15:; db "POLY FALCON", 0x00
    char_0x16:; db "POLY KIRBY", 0x00
    char_0x17:; db "POLY PIKACHU", 0x00
    char_0x18:; db "POLY PUFF", 0x00
    char_0x19:; db "POLY NESS", 0x00
    char_0x1A:; db "GIANT DK", 0x00
    //char_0x1B:; db "NONE", 0x00
    //char_0x1C:; db "NONE", 0x00
    char_0x1D:; db "FALCO", 0x00
    char_0x1E:; db "GANONDORF", 0x00
    char_0x1F:; db "YOUNG LINK", 0x00
    char_0x20:; db "DR. MARIO", 0x00
    //char_0x21:; db "LUCAS", 0x00
    char_0x22:; db "DARK SAMUS", 0x00
    OS.align(4)

    string_table_char:
    dw char_0x00            // MARIO
    dw char_0x01            // FOX
    dw char_0x02            // DK
    dw char_0x03            // SAMUS
    dw char_0x04            // LUIGI
    dw char_0x05            // LINK
    dw char_0x06            // YOSHI
    dw char_0x07            // CAPTAIN
    dw char_0x08            // KIRBY
    dw char_0x09            // PIKACHU
    dw char_0x0A            // JIGGLYPUFF
    dw char_0x0B            // NESS
    dw char_0x1D            // FALCO
    dw char_0x1E            // GANONDORF
    dw char_0x1F            // YOUNG LINK
    dw char_0x20            // DR MARIO
    //dw char_0x21            // LUCAS
    dw char_0x22            // DARK SAMUS
    dw char_0x0D            // METAL MARIO
    dw char_0x1A            // GIANT DK
    dw char_0x0E            // POLYGON MARIO
    dw char_0x0F            // POLYGON FOX
    dw char_0x10            // POLYGON DK
    dw char_0x11            // POLYGON SAMUS
    dw char_0x12            // POLYGON LUIGI
    dw char_0x13            // POLYGON LINK
    dw char_0x14            // POLYGON YOSHI
    dw char_0x15            // POLYGON CAPTAIN
    dw char_0x16            // POLYGON KIRBY
    dw char_0x17            // POLYGON PIKACHU
    dw char_0x18            // POLYGON JIGGLYPUFF
    dw char_0x19            // POLYGON NESS

    // @ Description
    // Training character id is really the order they are displayed in
    // constant names are loosely based on the debug names for characters
    scope id {
        constant MARIO(0x00)
        constant FOX(0x01)
        constant DK(0x02)
        constant SAMUS(0x03)
        constant LUIGI(0x04)
        constant LINK(0x05)
        constant YOSHI(0x06)
        constant CAPTAIN(0x07)
        constant KIRBY(0x08)
        constant PIKACHU(0x09)
        constant JIGGLYPUFF(0x0A)
        constant NESS(0x0B)

        constant FALCO(0x0C)
        constant GND(0x0D)
        constant YLINK(0x0E)
        constant DRM(0x0F)
        constant LUCAS(0x10)           // Not yet in use, update DSAMUS when it is
        constant DSAMUS(0x10)
        // Increment METAL after adding more characters here

        constant METAL(0x11)
        constant GDONKEY(METAL + 0x01)
        constant NMARIO(METAL + 0x02)
        constant NFOX(METAL + 0x03)
        constant NDONKEY(METAL + 0x04)
        constant NSAMUS(METAL + 0x05)
        constant NLUIGI(METAL + 0x06)
        constant NLINK(METAL + 0x07)
        constant NYOSHI(METAL + 0x08)
        constant NCAPTAIN(METAL + 0x09)
        constant NKIRBY(METAL + 0x0A)
        constant NPIKACHU(METAL + 0x0B)
        constant NJIGGLY(METAL + 0x0C)
        constant NNESS(METAL + 0x0D)
    }


    entry_id_to_char_id:
    db Character.id.MARIO
    db Character.id.FOX
    db Character.id.DK
    db Character.id.SAMUS
    db Character.id.LUIGI
    db Character.id.LINK
    db Character.id.YOSHI
    db Character.id.CAPTAIN
    db Character.id.KIRBY
    db Character.id.PIKACHU
    db Character.id.JIGGLYPUFF
    db Character.id.NESS
    db Character.id.FALCO
    db Character.id.GND
    db Character.id.YLINK
    db Character.id.DRM
    //db Character.id.LUCAS
    db Character.id.DSAMUS
    db Character.id.METAL
    db Character.id.GDONKEY
    db Character.id.NMARIO
    db Character.id.NFOX
    db Character.id.NDONKEY
    db Character.id.NSAMUS
    db Character.id.NLUIGI
    db Character.id.NLINK
    db Character.id.NYOSHI
    db Character.id.NCAPTAIN
    db Character.id.NKIRBY
    db Character.id.NPIKACHU
    db Character.id.NJIGGLY
    db Character.id.NNESS

    char_id_to_entry_id:
    db id.MARIO
    db id.FOX
    db id.DK
    db id.SAMUS
    db id.LUIGI
    db id.LINK
    db id.YOSHI
    db id.CAPTAIN
    db id.KIRBY
    db id.PIKACHU
    db id.JIGGLYPUFF
    db id.NESS
    db Character.id.BOSS         // Not used
    db id.METAL
    db id.NMARIO
    db id.NFOX
    db id.NDONKEY
    db id.NSAMUS
    db id.NLUIGI
    db id.NLINK
    db id.NYOSHI
    db id.NCAPTAIN
    db id.NKIRBY
    db id.NPIKACHU
    db id.NJIGGLY
    db id.NNESS
    db id.GDONKEY
    db Character.id.NONE         // Not used
    db Character.id.NONE         // Not used
    db id.FALCO
    db id.GND
    db id.YLINK
    db id.DRM
    db id.LUCAS                  // Not used yet
    db id.DSAMUS

    // @ Description 
    // Spawn Position Strings
    spawn_1:; db "PORT 1", 0x00
    spawn_2:; db "PORT 2", 0x00
    spawn_3:; db "PORT 3", 0x00
    spawn_4:; db "PORT 4", 0x00
    spawn_5:; db "CUSTOM", 0x00
    OS.align(4)

    string_table_spawn:
    dw spawn_1
    dw spawn_2
    dw spawn_3
    dw spawn_4
    dw spawn_5

    // @ Description
    // macro to call set_custom_spawn.
    macro set_custom_spawn(player) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        lli     a0, {player} - 1            // a0 - player (p1 = 0, p4 = 3)
        jal     Character.get_struct_       // v0 = address of player struct
        nop
        move    a0, v0                      // a0 = player pointer
        jal     set_custom_spawn_
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // 
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    spawn_func_1_:; set_custom_spawn(1)
    spawn_func_2_:; set_custom_spawn(2)
    spawn_func_3_:; set_custom_spawn(3)
    spawn_func_4_:; set_custom_spawn(4)
    
    macro set_percent(player) {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers
    
        lli     a0, {player} - 1            // a0 - player (p1 = 0, p4 = 3)
        jal     Character.get_struct_       // v0 = address of player struct
        nop
        move    a0, v0                      // a0 = player pointer
        jal     reset_percent_              // reset percent
        nop
        li      a1, struct.port_{player}.percent
        lw      a1, 0x0000(a1)              // a1 = percent to add
        jal     Character.add_percent_
        nop
        
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }
        
    percent_func_1_:; set_percent(1)
    percent_func_2_:; set_percent(2)
    percent_func_3_:; set_percent(3)
    percent_func_4_:; set_percent(4)
    
    macro tail_px(player) {
        define character(Training.struct.port_{player}.ID)
        define costume(Training.struct.port_{player}.costume)
        define type(Training.struct.port_{player}.type)
        define spawn_id(Training.struct.port_{player}.spawn_id)
        define spawn_func(Training.spawn_func_{player}_)
        define percent(Training.struct.port_{player}.percent)
        define percent_func(Training.percent_func_{player}_)


        Menu.entry("CHARACTER", Menu.type.U8, 0, 0, char_id_to_entry_id - entry_id_to_char_id - 1, OS.NULL, string_table_char, {character}, pc() + 16)
        Menu.entry("COSTUME", Menu.type.U8, 0, 0, 5, OS.NULL, OS.NULL, {costume}, pc() + 12)
        Menu.entry("TYPE", Menu.type.U8, 2, 0, 2, OS.NULL, string_table_type, {type}, pc() + 12)
        Menu.entry("SPAWN", Menu.type.U8, 0, 0, 4, OS.NULL, string_table_spawn, {spawn_id}, pc() + 12)
        Menu.entry_title("SET CUSTOM SPAWN", {spawn_func}, pc() + 24)
        Menu.entry("PERCENT", Menu.type.U16, 0, 0, 999, OS.NULL, OS.NULL, {percent}, pc() + 12)
        Menu.entry_title("SET PERCENT", {percent_func}, entry_percent_toggle_p{player})
        entry_percent_toggle_p{player}:; Menu.entry_bool("RESET SETS PERCENT", OS.TRUE, OS.NULL)


    }

    tail_p1:; tail_px(1)
    tail_p2:; tail_px(2)
    tail_p3:; tail_px(3)
    tail_p4:; tail_px(4)

    tail_table:
    dw tail_p1
    dw tail_p2
    dw tail_p3
    dw tail_p4

    toggle_table:
    dw  entry_percent_toggle_p1
    dw  entry_percent_toggle_p2
    dw  entry_percent_toggle_p3
    dw  entry_percent_toggle_p4
    
    // @ Description
    // Updates tail_px struct with values Training.struct
    macro struct_to_tail(player) {
        li      t0, struct.port_{player}
        li      t1, tail_p{player}

        lw      t2, 0x0000(t0)              // t2 = struct.port_{player}.ID
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lw      t2, 0x0008(t0)              // t2 = struct.port_{player}.costume
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next

        lw      t2, 0x0004(t0)              // t2 = struct.port_{player}.type
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lw      t2, 0x0010(t0)              // t2 = struct.port_{player}.spawn_id
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lw      t2, 0x000C(t0)              // t2 = struct.port_{player}.percent
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lw      t1, 0x001C(t1)              // t1 = curr->next
        
        lli     t2, 0x0001                  // t2 = is_enabled
        sw      t2, 0x0004(t1)              // update curr_val
        lw      t1, 0x001C(t1)              // t1 = curr->next


    }

    scope struct_to_tail_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        struct_to_tail(1)
        struct_to_tail(2)
        struct_to_tail(3)
        struct_to_tail(4)

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    info:
    Menu.info(head, 62, 50, 0, 24)

    head:
    entry_port_x:
    Menu.entry("PORT", Menu.type.U8, 1, 1, 4, OS.NULL, OS.NULL, OS.NULL, tail_p1)
}

} // __TRAINING__
