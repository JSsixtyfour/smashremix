// Training.asm (functions by Fray, menu implementation by Cyjorg)
if !{defined __TRAINING__} {
define __TRAINING__()
print "included Training.asm\n"

// @ Description
// This file contains functions and defines structs intended to assist training mode modifications.

include "Character.asm"
include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "Joypad.asm"
include "Menu.asm"
include "OS.asm"
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

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      t4, 0x0018(sp)              // ~
        sw      t5, 0x001C(sp)              // ~
        sw      t6, 0x0020(sp)              // store ra, t0-t6

        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t1 = match info address
        li      t1, reset_counter           // t1 = reset counter
        lw      t1, 0x0000(t1)              // t1 = reset counter value
        li      t6, Sonic.classic_table     // t6 = classic_table
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
        lli     t2, 0x0000                  // t2 = color_id (port_id for HMN, 4 for CPU)
        bnezl   t1, pc() + 8                // if not human, then use CPU color
        lli     t2, 0x0004                  // t2 = color_id
        sb      t2, 0x0008(t0)              // store tag color
        sb      t2, 0x000A(t0)              // store tag type (1P, 2P, 3P, 4P, CPU) (same as color_id)
        li      t1, struct.port_1.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 1 costume
        sb      t1, 0x0006(t0)              // store costume

        lli     t5, Character.id.SONIC      // t5 = Character.id.SONIC
        lb      t2, 0x0003(t0)              // t2 = char id
        bne     t2, t5, _load_p2            // if not Sonic, skip
        sltiu   t2, t1, 0x0006              // t2 = 0 if Classic Sonic costume NOTE: this is hardcoded costume count
        bnez    t2, _load_p2                // skip if not a Classic Sonic costume
        sb      r0, 0x0000(t6)              // p1 is_classic = FALSE
        lli     t2, OS.TRUE                 // ~
        sb      t2, 0x0000(t6)              // p1 is_classic = TRUE
        addiu   t1, t1, -0x0006             // t1 = adjusted costume ID for Classic Sonic
        sb      t1, 0x0006(t0)              // store costume for Classic Sonic

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
        lli     t2, 0x0001                  // t2 = color_id (port_id for HMN, 4 for CPU)
        bnezl   t1, pc() + 8                // if not human, then use CPU color
        lli     t2, 0x0004                  // t2 = color_id
        sb      t2, 0x0008(t0)              // store tag color
        sb      t2, 0x000A(t0)              // store tag type (1P, 2P, 3P, 4P, CPU) (same as color_id)
        li      t1, struct.port_2.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 2 costume
        sb      t1, 0x0006(t0)              // store costume

        lli     t5, Character.id.SONIC      // t5 = Character.id.SONIC
        lb      t2, 0x0003(t0)              // t2 = char id
        bne     t2, t5, _load_p3            // if not Sonic, skip
        sltiu   t2, t1, 0x0006              // t2 = 0 if Classic Sonic costume NOTE: this is hardcoded costume count
        bnez    t2, _load_p3                // skip if not a Classic Sonic costume
        sb      r0, 0x0001(t6)              // p2 is_classic = FALSE
        lli     t2, OS.TRUE                 // ~
        sb      t2, 0x0001(t6)              // p2 is_classic = TRUE
        addiu   t1, t1, -0x0006             // t1 = adjusted costume ID for Classic Sonic
        sb      t1, 0x0006(t0)              // store costume for Classic Sonic

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
        lli     t2, 0x0002                  // t2 = color_id (port_id for HMN, 4 for CPU)
        bnezl   t1, pc() + 8                // if not human, then use CPU color
        lli     t2, 0x0004                  // t2 = color_id
        sb      t2, 0x0008(t0)              // store tag color
        sb      t2, 0x000A(t0)              // store tag type (1P, 2P, 3P, 4P, CPU) (same as color_id)
        li      t1, struct.port_3.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 3 costume
        sb      t1, 0x0006(t0)              // store costume

        lli     t5, Character.id.SONIC      // t5 = Character.id.SONIC
        lb      t2, 0x0003(t0)              // t2 = char id
        bne     t2, t5, _load_p4            // if not Sonic, skip
        sltiu   t2, t1, 0x0006              // t2 = 0 if Classic Sonic costume NOTE: this is hardcoded costume count
        bnez    t2, _load_p4                // skip if not a Classic Sonic costume
        sb      r0, 0x0002(t6)              // p3 is_classic = FALSE
        lli     t2, OS.TRUE                 // ~
        sb      t2, 0x0002(t6)              // p3 is_classic = TRUE
        addiu   t1, t1, -0x0006             // t1 = adjusted costume ID for Classic Sonic
        sb      t1, 0x0006(t0)              // store costume for Classic Sonic

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
        lli     t2, 0x0003                  // t2 = color_id (port_id for HMN, 4 for CPU)
        bnezl   t1, pc() + 8                // if not human, then use CPU color
        lli     t2, 0x0004                  // t2 = color_id
        sb      t2, 0x0008(t0)              // store tag color
        sb      t2, 0x000A(t0)              // store tag type (1P, 2P, 3P, 4P, CPU) (same as color_id)
        li      t1, struct.port_4.costume   // ~
        lw      t1, 0x0000(t1)              // t1 = port 4 costume
        sb      t1, 0x0006(t0)              // store costume

        lli     t5, Character.id.SONIC      // t5 = Character.id.SONIC
        lb      t2, 0x0003(t0)              // t2 = char id
        bne     t2, t5, _end                // if not Sonic, skip
        sltiu   t2, t1, 0x0006              // t2 = 0 if Classic Sonic costume NOTE: this is hardcoded costume count
        bnez    t2, _end                    // skip if not a Classic Sonic costume
        sb      r0, 0x0003(t6)              // p4 is_classic = FALSE
        lli     t2, OS.TRUE                 // ~
        sb      t2, 0x0003(t6)              // p4 is_classic = TRUE
        addiu   t1, t1, -0x0006             // t1 = adjusted costume ID for Classic Sonic
        sb      t1, 0x0006(t0)              // store costume for Classic Sonic
        b       _end                        // go to end
        sb      t5, 0x0003(t0)              // save char id

        _initialize_p1:
        li      t4, char_id_to_entry_id     // t4 = char_id_to_entry_id table address
        addiu   t0, Global.vs.P_OFFSET      // t0 = p1 info
        lbu     t1, 0x0003(t0)              // t1 = char id
        addu    t5, t1, t4                  // t5 = address of training char id
        lb      t5, 0x0000(t5)              // t5 = training char id
        li      t2, struct.port_1.ID        // t2 = struct id address
        bnel    t1, t3, pc() + 8            // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_1.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        lli     t2, Character.id.SONIC      // t2 = Character.id.SONIC
        lbu     t5, 0x0003(t0)              // t5 = char id
        bne     t2, t5, pc() + 16           // skip if character isn't Sonic
        lbu     t5, 0x0000(t6)              // t5 = p1 is_classic
        bnezl   t5, pc() + 8                // if Classic Sonic, adjust costume_id
        addiu   t1, t1, 0x0006              // t1 = costume id adjusted
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
        bnel    t1, t3, pc() + 8            // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_2.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        lli     t2, Character.id.SONIC      // t2 = Character.id.SONIC
        lbu     t5, 0x0003(t0)              // t5 = char id
        bne     t2, t5, pc() + 16           // skip if character isn't Sonic
        lbu     t5, 0x0001(t6)              // t5 = p2 is_classic
        bnezl   t5, pc() + 8                // if Classic Sonic, adjust costume_id
        addiu   t1, t1, 0x0006              // t1 = costume id adjusted
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
        bnel    t1, t3, pc() + 8            // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_3.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        lli     t2, Character.id.SONIC      // t2 = Character.id.SONIC
        lbu     t5, 0x0003(t0)              // t5 = char id
        bne     t2, t5, pc() + 16           // skip if character isn't Sonic
        lbu     t5, 0x0002(t6)              // t5 = p3 is_classic
        bnezl   t5, pc() + 8                // if Classic Sonic, adjust costume_id
        addiu   t1, t1, 0x0006              // t1 = costume id adjusted
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
        bnel    t1, t3, pc() + 8            // ~
        sw      t5, 0x0000(t2)              // if id != NONE, store in struct
        lbu     t1, 0x0002(t0)              // t1 = type
        li      t2, struct.port_4.type      // t2 = struct type address
        sw      t1, 0x0000(t2)              // store type in struct
        lbu     t1, 0x0006(t0)              // t1 = costume id
        lli     t2, Character.id.SONIC      // t2 = Character.id.SONIC
        lbu     t5, 0x0003(t0)              // t5 = char id
        bne     t2, t5, pc() + 16           // skip if character isn't Sonic
        lbu     t5, 0x0003(t6)              // t5 = p4 is_classic
        bnezl   t5, pc() + 8                // if Classic Sonic, adjust costume_id
        addiu   t1, t1, 0x0006              // t1 = costume id adjusted
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
        lw      t5, 0x001C(sp)              // ~
        lw      t6, 0x0020(sp)              // load t0-t6
        jal     0x801906D0                  // original line 1
        nop                                 // original line 2
        lw      ra, 0x0004(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        add     t2, t0, t1                  // t2 = struct table + offset
        lw      t2, 0x0000(t2)              // t2 = port struct address
        lw      t0, 0x0010(t2)              // ~
        slti    t0, t0, 0x4                 // t0 = 1 if spawn_id >= 0x4; else t0 = 0
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
    // Obey CP state for all CPU characters loaded
    scope obey_cp_state_: {
        OS.patch_start(0x116A14, 0x801901F4)
        j       obey_cp_state_
        lui     v1, 0x8019                  // original line 1
        OS.patch_end()

        addiu   v1, v1, 0x0B58              // original line 2
        lui     t6, 0x800A                  // original line 3
        lw      t6, 0x50E8(t6)              // original line 4

        lli     t7, 0x0000                  // t7 = 0 / port_id / loop index
        lli     t8, Global.vs.P_DIFF        // t8 = size of struct

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // store registers

        _loop:
        multu   t7, t8
        mflo    t9                          // t9 = offset to match player struct
        addu    t9, t6, t9                  // t9 = match player struct
        lbu     t0, 0x0022(t9)              // t0 = player type (0 = man, 1 = cpu, 2 = n/a)
        addiu   t0, t0, -0x0001             // t0 = 0 if CPU
        bnez    t0, _next                   // skip if not CPU
        nop

        jal     0x80190220                  // call the original routine
        nop

        _next:
        sltiu   at, t7, 0x0003              // at = 1 if still more ports to check
        bnez    at, _loop                   // if not done, continue looping
        addiu   t7, t7, 0x0001              // t7++

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Disable movement/control of extra characters during pause
    scope disable_during_pause_: {
        // 18 lines to replace
        OS.patch_start(0x11398C, 0x8018D16C)
        lli     t7, 0x0000                  // t7 = 0 / port_id / loop index

        _loop:
        lli     t8, Global.vs.P_DIFF        // t8 = size of struct
        lui     t6, 0x800A
        lw      t6, 0x50E8(t6)              // t6 = match struct
        multu   t7, t8
        mflo    t9                          // t9 = offset to match player struct
        addu    t9, t6, t9                  // t9 = match player struct
        lbu     t0, 0x0022(t9)              // t0 = player type (0 = man, 1 = cpu, 2 = n/a)
        addiu   t0, t0, -0x0002             // t0 = 0 if NA
        beqz    t0, _next                   // skip if NA
        nop

        jal     0x800E7F14                  // call the routine that disables movement/control
        lw      a0, 0x0078(t9)              // a0 = player object

        _next:
        sltiu   at, t7, 0x0003              // at = 1 if still more ports to check
        bnez    at, _loop                   // if not done, continue looping
        addiu   t7, t7, 0x0001              // t7++
        nop
        nop
        OS.patch_end()
    }

    // @ Description
    // Enable movement/control of extra characters during unpause
    scope enable_during_unpause_: {
        // 19 lines to replace
        OS.patch_start(0x113A7C, 0x8018D25C)
        lli     t5, 0x0000                  // t5 = 0 / port_id / loop index

        _loop:
        lli     t8, Global.vs.P_DIFF        // t8 = size of struct
        lui     t6, 0x800A
        lw      t6, 0x50E8(t6)              // t6 = match struct
        multu   t5, t8
        mflo    t9                          // t9 = offset to match player struct
        addu    t9, t6, t9                  // t9 = match player struct
        lbu     t1, 0x0022(t9)              // t1 = player type (0 = man, 1 = cpu, 2 = n/a)
        addiu   t1, t1, -0x0002             // t1 = 0 if NA
        beqz    t1, _next                   // skip if NA
        addiu   t1, t1, 0x0002              // t1 = 0 if man

        lw      a0, 0x0078(t9)              // a0 = player object

        bnez    t1, _enable                 // if not human, skip updating prior bitmask
        lw      t0, 0x0018(sp)              // t0 = button mask address
        lhu     t1, 0x0002(t0)              // t1 = button mask
        andi    t3, t1, 0x4000              // t3 = 0 if B not pressed
        beqz    t3, _enable                 // if B not pressed, skip updating prior bitmask
        lw      v0, 0x0084(a0)              // v0 = player struct
        lhu     t2, 0x01BC(v0)              // t2 = prior button mask
        ori     t4, t2, 0x4000              // t4 = prior button mask with B
        sh      t4, 0x01BC(v0)              // update prior button mask

        _enable:
        jal     0x800E7F68                  // call the routine that enables movement/control
        nop

        _next:
        sltiu   at, t5, 0x0003              // at = 1 if still more ports to check
        bnez    at, _loop                   // if not done, continue looping
        addiu   t5, t5, 0x0001              // t5++
        nop
        nop
        nop
        nop
        addiu   a1, r0, 0x7800              // original line 23 (sets volume to full)
        OS.patch_end()
    }

    // @ Description
    // Prevents exiting Training Mode unless A is held.
    scope hold_to_exit_: {
        constant NUM_FRAMES(33)             // visual fill needs extra frame (32+1)

        // runs when over Exit
        OS.patch_start(0x114078, 0x8018D858)
        jal     hold_to_exit_
        or      v0, r0, r0                  // original line 1
        OS.patch_end()
        // runs when menu is up
        OS.patch_start(0x11414C, 0x8018D92C)
        jal     hold_to_exit_._reset
        lui     t6, 0x8019                  // original line 1
        OS.patch_end()

        // t6 = port
        // t7 = offset to controller input

        li      t9, Toggles.entry_hold_to_exit_training
        lw      t9, 0x0004(t9)              // t9 = 1 if hold to exit training mode is enabled, else 0
        beqzl   t9, _return                 // if hold to exit disabled, return normally
        andi    t9, t8, 0x8000              // original line 2

        lui     t8, 0x8004                  // t8 = controller input for the human port from previous frame
        addu    t8, t8, t7                  // ~
        lhu     t8, 0x5228(t8)              // ~
        andi    t8, t8, 0x8000              // original line 2, modified

        li      t7, held_frames
        lli     t9, OS.FALSE                // t9 = OS.FALSE = don't exit

        beqzl   t8, _end                    // if not held, reset count
        lli     t6, 0x0000                  // t6 = 0

        lw      t6, 0x0000(t7)              // t6 = current held count
        addiu   t6, t6, 0x0001              // t6++
        sltiu   t9, t6, NUM_FRAMES          // t9 = 0 if we should exit, 1 otherwise
        xori    t9, t9, 0x0001              // t9 = 1 if we should exit, 0 otherwise
        bnezl   t9, _end                    // if we should exit, reset count
        lli     t6, 0x0000                  // t6 = 0

        _end:
        sw      t6, 0x0000(t7)              // update held count

        _return:
        jr      ra
        nop

        _reset:
        lw      t6, 0x0B58(t6)              // original line 2 - t6 = cursor index
        lli     t9, 0x0005                  // t9 = Exit cursor index
        beq     t6, t9, _return             // if on exit, don't reset held frames
        nop                                 // otherwise, reset it
        li      t9, held_frames
        jr      ra
        sw      r0, 0x0000(t9)              // reset held frames

        held_frames:
        dw 0
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

        li      t0, player_shield_status    // t0 = player_shield_status
        sw      r0, 0x0000(t0)              // reset player_shield_status value

        li      t0, action_control_object
        sw      r0, 0x0000(t0)              // clear action & frame control object pointer

        li      t0, special_model_display
        li      t1, Toggles.entry_special_model
        lw      t1, 0x0004(t1)              // t1 = special model value
        sw      t1, 0x0000(t0)              // remember special model display when starting

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

        li      t0, action_control_object
        sw      r0, 0x0000(t0)              // clear action & frame control object pointer

        li      t0, reset_counter           // t0 = reset_counter
        lw      t1, 0x0000(t0)              // t1 = reset_counter value
        addiu   t1, t1, 0x00001             // t1 = reset counter value + 1
        sw      t1, 0x0000(t0)              // store reset_counter value

        li      t0, player_shield_status    // t0 = player_shield_status
        sw      r0, 0x0000(t0)              // reset player_shield_status value

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

    //init_struct_p1:; fill 0x40
    //init_struct_p2:; fill 0x40
    //init_struct_p3:; fill 0x40
    //init_struct_p4:; fill 0x40

    //// @ Description
    //// This hook copies the init_struct when a character is initialized in training mode.
    //// The struct is not fully understood, but contains things like character, port, spawn
    //// position and direction, HMN/CPU status, and other match info.
    //// The copied struct is then used for quick resets.
    //// 0x800D7F3C is the function which initializes a player.
    //scope copy_init_struct_: {
    //    OS.patch_start(0x116CAC, 0x8019048C)
    //    j   copy_init_struct_
    //    sb  t5, 0x007B(sp)                  // original line 2
    //    _return:
    //    OS.patch_end()
    //
    //    // a0 = init_struct
    //    // s0 = player port
    //    sll     t5, s0, 0x6                 // t5 = port * 0x40 (struct size)
    //    ori     t6, r0, 0x40                // t6 = transfer size (0x40)
    //    li      t7, init_struct_p1          // ~
    //    addu    t7, t7, t5                  // t7 = init_struct_px
    //    or      t8, a0, r0                  // t8 = current init_struct
    //
    //    _loop:
    //    // transfer 0x40 bytes from current init_struct to init_struct_px
    //    lw      t5, 0x0000(t8)              // ~
    //    sw      t5, 0x0000(t7)              // transfer 0x4 bytes
    //    addiu   t6, t6,-0x0004              // decrement transfer size
    //    addiu   t7, t7, 0x0004              // ~
    //    addiu   t8, t8, 0x0004              // increment init_struct position
    //    bnez    t6, _loop                   // loop if transfer size !0
    //    nop
    //
    //    _exit_loop:
    //    jal     0x800D7F3C                  // original line 1
    //    nop
    //    j       _return                     // return
    //    nop
    //}

    allow_reset:
    dw  0

    skip_advance:
    dw  0

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
        li      t0, skip_advance
        sw      v0, 0x0000(t0)              // save skip_advance value for later use
        _check_dl:
        // check if reset is allowed
        li      t0, allow_reset             // ~
        lw      t1, 0x0000(t0)              // t1 = current allow_reset flag
        lli     t2, OS.TRUE                 // t2 = TRUE
        bne     t1, t2, _check_dd           // if allow_reset != TRUE, skip
        sw      t2, 0x0000(t0)              // allow_reset = TRUE
        // check for a DPAD LEFT press, reset if detected
        lli     a0, Joypad.DL               // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool dd_pressed
        nop
        beqz    v0, _check_dd               // if (!dl_pressed), skip
        nop

        _quick_reset:
        // play the reset sound effect
        lli     a0, 0xA2                    // ~
        jal     FGM.play_                   // play reset fgm
        nop
        // set allow_reset to FALSE
        li      t0, allow_reset             // ~
        sw      r0, 0x0000(t0)              // allow_reset = FALSE
        // generate an interrupt
        lli     t1, 0x0001                  // t1 = 0x0001
        lui     t0, 0x8019                  // ~
        sb      t1, 0x0C2A(t0)              // set this to 1 for reset instead of exit
        li      t0, Global.screen_interrupt // ~
        sw      t1, 0x0000(t0)              // generate screen_interrupt

        // TODO: Experimental quick reset function, disabled since it's not stable for now.
        // TODO: If you run this function while a player is dead, their percent will no longer be drawn.
        // It is unclear how stable this function will be on hardware etc.
        // this loop destroys all of the GFX objects (type 1011)
        // logic based on the inner loop of a "destroys all object" function at 0x8000B7E8
        //constant FIRST_GFX_PTR(0x80046708)
        // li      s0, FIRST_GFX_PTR           // s0 = FIRST_GFX_PTR
        // lw      s0, 0x0000(s0)              // s0 = address of first GFX object
        // _gfx_loop:
        // beq     s0, r0, _gfx_loop_end       // if s0 = NULL, exit loop
        // nop
        // lw      s1, 0x0004(s0)              // s1 = next GFX object
        // jal     0x80009A84                  // this function permanently destroys a given object
        // or      a0, s0, r0                  // a0 = current FGX object
        // b       _gfx_loop                   // ~
        // or      s0, s1, r0                  // s0 = address of next GFX object
        //
        // _gfx_loop_end:
        // // after mercilessly destroying all of the GFX objects, we need to rebuild the object list
        // // this function seems to be used to build the inital GFX object list while a screen loads,
        // // I'm not sure if calling it here has any other side effects but it seems to be fine.
        // jal     0x800FD300                  // this function builds the initial GFX object list
        // nop
        //
        // // this loop resets the position of all players
        // _reset_players:
        // li      t9, Global.p_struct_head    // t9 = pointer to player struct linked list
        // lw      t9, 0x0000(t9)              // t9 = 1p player struct address
        // addiu   sp, sp,-0x0018              // allocate stack space
        // swc1    f4, 0x0010(sp)              // ~
        // swc1    f6, 0x0014(sp)              // store f4, f6
        //
        // _loop:
        // beqz    t9, _exit_loop              // if t9 is zero, then player structs not initialized or we reached the end of the linked list, so exit the loop
        // nop
        // lw      a0, 0x0004(t9)              // a0 = player object struct
        // beqz    a0, _end_loop               // if a0 is zero, then this player struct is not linked to an active object, so check the next player struct instead
        // sw      t9, 0x0008(sp)              // store t9
        //
        // // if we reach this point, reset the current player
        // lbu     t0, 0x000D(t9)              // t0 = port
        // sll     t1, t0, 0x6                 // t1 = port * 0x40 (struct size)
        // li      t2, init_struct_p1          // ~
        // addu    t2, t2, t1                  // t2 = init_struct_px
        // move    a0, t0                      // a0 = port
        // addiu   a1, t2, 0x0004              // a1 = spawn position in init_struct_px
        // jal     0x800FAF64                  // this function sets up the spawn position in the initial struct
        // sw      t2, 0x000C(sp)              // save init_struct_px
        // lw      t9, 0x0008(sp)              // load t9
        // lw      a1, 0x000C(sp)              // a1 = init_struct_px
        // // replicate original logic to determine facing position
        // lwc1    f4, 0x0004(a1)              // f4 = spawn_x
        // mtc1    r0, f6                      // f6 = 0
        // addiu   t0, r0, 0x0001              // t0 = 1 (face right)
        // addiu   t1, r0, 0xFFFF              // t1 = -1 (face left)
        // c.le.s  f6, f4                      // fp compare
        // nop
        // bc1fl   _custom_spawn_dir           // branch if spawn_x < 0
        // sw      t0, 0x0010(a1)              // spawn_dir = 1 (face right)
        // // if spawn_x >= 0
        // sw      t1, 0x0010(a1)              // spawn_dir = -1 (face left)
        //
        // _custom_spawn_dir:
        // // update facing position if the spawn point is custom
        // li      t0, struct.table            // t0 = struct table
        // lbu     t1, 0x000D(t9)              // ~
        // sll     t1, t1, 0x2                 // t1 = offset (player port * 4)
        // add     t2, t0, t1                  // t2 = struct table + offset
        // lw      t2, 0x0000(t2)              // t2 = port struct address
        // lw      t0, 0x0010(t2)              // ~
        // slti    t0, t0, 0x4                 // t0 = 1 if spawn_id >= 0x4; else t0 = 0
        // bnez    t0, _apply_reset            // skip if spawn_id != custom
        // nop
        // lw      t0, 0x001C(t2)              // t1 = custom spawn_dir
        // sw      t0, 0x0010(a1)              // spawn_dir = custom
        //
        // _apply_reset:
        // jal     0x800D79F0                  // this function moves the player to their spawn position and initalizes their properties
        // lw      a0, 0x0004(t9)              // a0 = player object struct
        // lw      t9, 0x0008(sp)              // load t9
        // jal     0x800DEE54                  // this function sets the player's initial action
        // lw      a0, 0x0004(t9)              // a0 = player object struct
        //
        // _end_loop:
        // lw      t9, 0x0008(sp)              // load t9
        // b       _loop                       // loop over all player structs
        // lw      t9, 0x0000(t9)              // t9 = next player struct address
        // _exit_loop:
        // lwc1    f4, 0x0010(sp)              // ~
        // lwc1    f6, 0x0014(sp)              // load f4, f6
        // addiu   sp, sp, 0x0018              // deallocate stack space

        _check_dd:
        // check for a DPAD DOWN press, cycles through special model display if detected
        lli     a0, Joypad.DD               // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool dd_pressed
        nop
        beqz    v0, _check_frame_advance    // if (!dd_pressed), skip
        nop
        li      t1, Toggles.entry_special_model
        lw      t0, 0x0004(t1)              // t0 = 0 for off, 1 for hitbox_mode, 2 for hitbox+model, 3 for ecb
        addiu   t0, t0, 0x0001              // t0 = 1, 2, 3, or 4
        lli     t2, 0x0004                  // t2 = 4
        beql    t0, t2, _update_model_display
        addu    t0, r0, r0                  // turn off special model display

        _update_model_display:
        sw      t0, 0x0004(t1)              // store updated model display

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
        sw      ra, 0x006C(sp)              // save ra
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
        sw      ra, 0x006C(sp)              // save ra
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
        sw      ra, 0x006C(sp)              // save ra

        _end:
        sw      r0, 0x0000(t2)              // du_pressed = false
        sw      r0, 0x0000(t3)              // dr_pressed = false

        _skip:
        li      t0, Global.screen_interrupt // ~
        lw      t1, 0x0000(t0)              // generate screen_interrupt
        bnez    t1, _finish                 // skip custom menu updates if currently resetting
        nop

        // if frame advance is off, the joystick also won't get updated correctly, so call that here
        li      t1, freeze                  // t1 = freeze
        lw      t0, 0x0000(t1)              // t0 = bool freeze
        beqz    t0, _run                    // if (!freeze), finish
        nop
        jal     Joypad.update_stick_
        nop

        _run:
        jal     run_
        nop

        // if frame advance is off, then we need to call Render.update_live_string_ for the entry currently selected
        li      t1, freeze                  // t1 = freeze
        lw      t0, 0x0000(t1)              // t0 = bool freeze
        beqz    t0, _finish                 // if (!freeze), finish
        nop

        li      a0, info                    // a0 = menu info
        jal     Menu.get_selected_entry_    // v0 = selected entry
        nop
        lw      a0, 0x0020(v0)              // a0 = label object
        beqz    a0, _finish                 // skip if no label object (shouldn't happen)
        nop
        lw      a0, 0x006C(a0)              // a0 = value object
        beqz    a0, _finish                 // skip if no value object (can happen for titles)
        nop
        jal     Render.update_live_string_
        nop

        // we may have just updated the bgm name, so update that too
        li      t0, bgm_name_object
        lw      a0, 0x0000(t0)              // a0 = bgm name object
        beqz    a0, _finish                 // skip if no bgm name object (shouldn't happen)
        nop
        jal     Render.update_live_string_
        nop

        _finish:
        OS.restore_registers()
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
    // This hook runs after the call to run object routines while in training mode.
    // This allows for our hooks to always run even if in freeze mode,
    // and always after those routines if they are run.
    scope run_after_object_routines_: {
        OS.patch_start(0x114270, 0x8018DA50)
        j   run_after_object_routines_
        nop
        OS.patch_end()

        // Update action & frame strings
        jal     update_actions_
        nop

        j       0x8018DA60                    // original line 1, modified to jump
        nop                                   // original line 2
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
    // a1 - address of player's custom spawn entry
    scope set_custom_spawn_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // save registers

        // set custom spawn
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

        // set spawn type to custom
        lli     t1, 0x0004                  // t1 = spawn_id: CUSTOM
        sw      t1, 0x0004(a1)              // save spawn_id to tail_px

        // update the string displayed
        jal     Menu.update_pointer_
        or      v0, r0, a1                  // v0 = custom spawn entry

        // when freeze is on, need to force update
        lw      t0, 0x0020(a1)              // t0 = label object
        jal     Render.update_live_string_
        lw      a0, 0x006C(t0)              // a0 = value object

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
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
    // This mirrors the Toggles.entry_special_model value when entering Training.
    // Initially set to -1 to signify it hasn't been initialized
    special_model_display:
    dw -1

    // @ Description
    // Renders the frame to the training menu modal for our custom menu.
    // Reuses the routine at 8018EBB4.
    // @ Arguments
    // a0 - address of display object
    scope draw_modal_frame_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        OS.copy_segment(0x1153E0, 0x20)     // save registers

        lli     a0, 0x0000                  // a0 = routine (Render.NOOP)
        li      a1, Render.TEXTURE_RENDER_  // a1 = display list routine
        lli     a2, 0x17                    // a2 = room
        jal     Render.create_display_object_
        lli     a3, 0x16                    // a3 = group

        or      s6, v0, r0                  // s6 = object reference
        li      s7, 0x80190B58              // s7 = table of image data

        j       0x8018EC28                  // jump to original routine which will end up jr ra'ing for us
        lli     s0, 0x0030                  // s0 = offset in table to modal border start
    }

    // @ Description
    // Create action & frame strings for the given port
    // @ Arguments
    // a0 - port (0-3)
    // a1 - action & frame control object
    // a2 - room
    scope create_action_strings_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~

        li      t0, Render.display_order_room
        lui     t1, 0x4000                  // t1 = 0x40000000 (render after 0x80000000)
        sw      t1, 0x0000(t0)              // update display order within rooms for our draw_texture calls

        lli     t0, 26                      // t0 = # of pixels between action string blocks
        multu   a0, t0                      // t0 = # of pixels to offset for port
        mflo    t0                          // ~
        sw      t0, 0x0010(sp)              // save # of pixels to offset for port

        sll     a0, a0, 0x0002              // a0 = offset for port
        sw      a0, 0x0014(sp)              // save offset

        addu    t2, a1, a0                  // t2 =  & frame routine object, offset for port
        lw      t2, 0x0060(t2)              // t2 = current frame string object
        beqz    t2, _create_frame_string    // if no object, skip destroying
        nop                                 // otherwise we do have to destroy it
        lw      t3, 0x007C(t2)              // t3 = current display state
        sw      t3, 0x0018(sp)              // save display state
        jal     Render.DESTROY_OBJECT_
        or      a0, t2, r0                  // a0 = object

        lw      a1, 0x0008(sp)              // a1 = action & frame control object
        lw      t0, 0x0010(sp)              // t0 = # of pixels to offset for port
        lw      a0, 0x0014(sp)              // a0 = offset for port

        _create_frame_string:
        addiu   a2, a1, 0x040               // a2 = number, not offset for port
        addu    a2, a2, a0                  // a2 = number, offset for port
        lli     t1, 66                      // t1 = y position, unadjusted for port
        addu    t1, t1, t0                  // t1 = y position, adjusted for port
        mtc1    t1, f0                      // f0 = y position
        cvt.s.w f0, f0                      // f0 = y position, floating point
        mfc1    s2, f0                      // s2 = y position
        lw      a0, 0x000C(sp)              // a0 = room
        Render.draw_number(0xFF, 0x17, 0xFFFFFFFF, Render.NOOP, 0x41A00000, 0xFFFFFFFF, 0xFFFFFFFF, 0x3F400000, Render.alignment.LEFT, OS.FALSE)
        lw      t0, 0x0008(sp)              // t0 = action & frame control object
        lw      t1, 0x0014(sp)              // t1 = offset for port
        addu    t0, t0, t1                  // t0 = action & frame control object offset by port
        addiu   t0, t0, 0x0060              // t0 = address of reference to frame string object
        sw      v0, 0x0000(t0)              // save reference to frame string object
        sw      t0, 0x0054(v0)              // save object pointer reference
        lw      t3, 0x0018(sp)              // t3 = display state
        sw      t3, 0x007C(v0)              // update display state

        lw      a0, 0x0014(sp)              // a0 = offset for port
        lw      t0, 0x0008(sp)              // t0 = action & frame control object
        addu    t0, t0, a0                  // t0 = action & frame control object, offset for port
        lw      t0, 0x0050(t0)              // t0 = current action string object
        beqz    t0, _create_action_string   // if no object, skip destroying
        nop                                 // otherwise we do have to destroy it
        lw      t3, 0x007C(t0)              // t3 = current display state
        sw      t3, 0x0018(sp)              // save display state
        jal     Render.DESTROY_OBJECT_
        or      a0, t0, r0                  // a0 = object

        _create_action_string:
        li      a2, p1_action_pointer       // a2 = action pointer, unadjusted for port
        lw      t0, 0x0014(sp)              // t0 = offset for port
        addu    a2, a2, t0                  // a2 = action pointer, adjusted for port
        lw      t0, 0x0010(sp)              // t0 = # of pixels to offset for port
        lli     t1, 55                      // t1 = y position, unadjusted for port
        addu    t1, t1, t0                  // t1 = y position, adjusted for port
        mtc1    t1, f0                      // f0 = y position
        cvt.s.w f0, f0                      // f0 = y position, floating point
        mfc1    s2, f0                      // s2 = y position
        lw      a0, 0x000C(sp)              // a0 = room
        Render.draw_string_pointer(0xFF, 0x17, 0xFFFFFFFF, Render.NOOP, 0x41A00000, 0xFFFFFFFF, 0xFFFFFFFF, 0x3F400000, Render.alignment.LEFT, OS.FALSE)
        lw      t0, 0x0008(sp)              // t0 = action & frame control object
        lw      t1, 0x0014(sp)              // t1 = offset for port
        addu    t0, t0, t1                  // t0 = action & frame control object offset by port
        addiu   t0, t0, 0x0050              // t0 = address of reference to action string object
        sw      v0, 0x0000(t0)              // save reference to action string object
        sw      t0, 0x0054(v0)              // save object pointer reference
        lw      t3, 0x0018(sp)              // t3 = display state
        sw      t3, 0x007C(v0)              // update display state

        li      t0, Render.display_order_room
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order with default

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Sets up the custom objects for the custom menu
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        Render.load_font()
        Render.load_file(0xC5, Render.file_pointer_1)                 // load button images into file_pointer_1
        Render.load_file(File.CSS_IMAGES, Render.file_pointer_2)      // load CSS images into file_pointer_2 (for dpad image)

        li      a0, info                    // a0 - info
        sw      r0, 0x0008(a0)              // clear cursor object reference on page load
        sw      r0, 0x000C(a0)              // reset cursor to top

        Render.draw_string(0x17, 0xE, press_z, Render.NOOP, 0x43200000, 0x42480000, 0xFFFFFFFF, 0x3F800000, Render.alignment.CENTER, OS.FALSE)
        Render.draw_texture_at_offset(0x17, 0xE, Render.file_pointer_1, Render.file_c5_offsets.Z, Render.NOOP, 0x42EB0000, 0x42440000, 0x848484FF, 0x303030FF, 0x3F800000)

        // cleanup
        li      t0, hold_A_rect_object      // t0 = address of hold_A_rect_object
        sw      r0, 0x0000(t0)              // hold_A_rect_object = 0
        li      s1, hold_A_rect_width       // s1 = address of hold_A_rect_width
        sw      r0, 0x0000(s1)              // hold_A_rect_width = 0

        li      t9, Toggles.entry_hold_to_exit_training
        lw      t9, 0x0004(t9)              // t9 = 1 if hold to exit training mode is enabled, else 0
        beqzl   t9, _no_hold_A_text         // if hold to exit is disabled, skip
        nop

        Render.draw_string(0x17, 0xF, hold_A_text, Render.NOOP, 0x43290000, 0x43260000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_texture_at_offset(0x17, 0xF, Render.file_pointer_1, Render.file_c5_offsets.A, Render.NOOP, 0x434A0000, 0x43250000, 0x50A8FFFF, 0x303030FF, 0x3F700000)

        // based on Render.draw_rectangle() macro
        lli     a0, 0x17                    // a0 = room
        lli     a1, 0xF                     // a1 = group
        lli     s1, 73                      // s1 = ulx
        lli     s2, 179                     // s2 = uly
        move    s3, r0                      // s3 = width
        lli     s4, 2                       // s4 = height
        li      s5, 0x0088FFFF              // s5 = color
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha
        li      s1, hold_A_rect_object      // s1 = address of hold_A_rect_object
        sw      v0, 0x0000(s1)              // hold_A_rect_object = v0, the return value of Render.draw_rectangle_
        li      s1, hold_A_rect_width       // s1 = address of hold_A_rect_width
        sw      r0, 0x0000(s1)              // hold_A_rect_width = 0

        _no_hold_A_text:
        // Reset counter
        Render.draw_string(0x17, 0x15, reset_string, Render.NOOP, 0x42C70000, 0x41C80000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_number(0x17, 0x15, reset_counter, Render.NOOP, 0x435D0000, 0x41C80000, 0xFFFFFFFF, 0x3F800000, Render.alignment.RIGHT, OS.FALSE)

        // Dpad images
        Render.draw_texture_at_offset(0x17, 0x15, Render.file_pointer_2, 0x0218, Render.NOOP, 0x42350000, 0x43480000, 0x848484FF, 0x303030FF, 0x3F800000)
        Render.draw_texture_at_offset(0x17, 0x15, Render.file_pointer_2, 0x0218, Render.NOOP, 0x42350000, 0x43570000, 0x848484FF, 0x303030FF, 0x3F800000)
        Render.draw_texture_at_offset(0x17, 0x15, Render.file_pointer_2, 0x0218, Render.NOOP, 0x43200000, 0x43480000, 0x848484FF, 0x303030FF, 0x3F800000)
        Render.draw_texture_at_offset(0x17, 0x15, Render.file_pointer_2, 0x0218, Render.NOOP, 0x43200000, 0x43570000, 0x848484FF, 0x303030FF, 0x3F800000)
        Render.draw_rectangle(0x17, 0x15, 52, 203, 2, 2, Color.high.YELLOW, OS.FALSE)
        Render.draw_rectangle(0x17, 0x15, 48, 222, 2, 2, Color.high.YELLOW, OS.FALSE)
        Render.draw_rectangle(0x17, 0x15, 171, 207, 2, 2, Color.high.YELLOW, OS.FALSE)
        Render.draw_rectangle(0x17, 0x15, 167, 226, 2, 2, Color.high.YELLOW, OS.FALSE)
        Render.draw_string(0x17, 0x15, dpad_pause, Render.NOOP, 0x427D0000, 0x434A0000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_string(0x17, 0x15, dpad_reset, Render.NOOP, 0x427D0000, 0x43590000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_string(0x17, 0x15, dpad_frame, Render.NOOP, 0x43320000, 0x434A0000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_string(0x17, 0x15, dpad_model, Render.NOOP, 0x43320000, 0x43590000, 0xFFFFFFFF, 0x3F800000, Render.alignment.LEFT, OS.FALSE)

        // Action legend
        Render.draw_texture_at_offset(0x17, 0x15, Render.file_pointer_1, Render.file_c5_offsets.L, Render.NOOP, 0x41A00000, 0x41800000, 0x848484FF, 0x303030FF, 0x3F600000)
        Render.draw_string(0x17, 0x15, action_legend_1, Render.NOOP, 0x41A00000, 0x41DA0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT, OS.FALSE)
        Render.draw_string(0x17, 0x15, action_legend_2, Render.NOOP, 0x41A00000, 0x421A0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT, OS.FALSE)

        // Transparent background and frame
        Render.draw_rectangle(0x16, 0x16, 66, 45, 189, 154, 0x0064FF64, OS.TRUE)
        jal     draw_modal_frame_
        nop

        // BGM name
        Render.draw_string_pointer(0x17, 0x16, bgm_pointer, Render.update_live_string_, 0x43200000, 0x43380000, 0xFFFFFFFF, 0x3F5C0000, Render.alignment.CENTER, OS.FALSE)
        li      t0, bgm_name_object
        sw      v0, 0x0000(t0)              // save reference to bgm name object
        sw      t0, 0x0054(v0)              // store address of reference to bgm name object
        lli     a1, 162                     // a1 = max width
        jal     Render.apply_max_width_     // apply max width
        or      a0, v0, r0                  // a0 = bgm name object

        // Action & Frame strings
        // Create a room to use for these strings that shows up behind the pause menu
        Render.create_room(0x39, 0x1C, 0x20)

        // The update_frame_counts_ routine should run after character actions change,
        // so we will use REGISTER_OBJECT_ROUTINE to do that.
        // To ensure it runs after character damage action changes, set group to 0xD.
        Render.register_routine(Render.NOOP, 0xD, 0x8000)
        sw      r0, 0x0030(v0)              // clear previous actionID for p1
        sw      r0, 0x0034(v0)              // clear previous actionID for p2
        sw      r0, 0x0038(v0)              // clear previous actionID for p3
        sw      r0, 0x003C(v0)              // clear previous actionID for p4
        sw      r0, 0x0040(v0)              // clear frame count for p1
        sw      r0, 0x0044(v0)              // clear frame count for p2
        sw      r0, 0x0048(v0)              // clear frame count for p3
        sw      r0, 0x004C(v0)              // clear frame count for p4
        sw      r0, 0x0050(v0)              // clear action string object for p1
        sw      r0, 0x0054(v0)              // clear action string object for p2
        sw      r0, 0x0058(v0)              // clear action string object for p3
        sw      r0, 0x005C(v0)              // clear action string object for p4
        sw      r0, 0x0060(v0)              // clear frame string object for p1
        sw      r0, 0x0064(v0)              // clear frame string object for p2
        sw      r0, 0x0068(v0)              // clear frame string object for p3
        sw      r0, 0x006C(v0)              // clear frame string object for p4
        sw      v0, 0x0010(sp)              // save object reference
        li      t0, action_control_object
        sw      v0, 0x0000(t0)              // t0 = action & frame control object

        or      a0, v0, r0                  // a0 = object
        li      a1, update_frame_counts_    // a1 = routine
        lli     a2, 0x0001                  // a2 = ?
        lli     a3, 0x0000                  // a3 = last group to run
        jal     Render.REGISTER_OBJECT_ROUTINE_
        addiu   sp, sp, -0x0030             // create stack space
        addiu   sp, sp, 0x0030              // restore stack

        li      t0, struct.port_1.type
        lw      t0, 0x0000(t0)              // t0 = port 1 type
        lli     t1, 0x0002                  // t1 = 2 (type N/A)
        beq     t0, t1, _check_port_2       // if not a CPU or HMN, skip port
        lli     a0, 0x0000
        lw      a1, 0x0010(sp)              // a1 = object reference
        jal     create_action_strings_
        lli     a2, 0x0017                  // a2 = room when pause menus are down

        _check_port_2:
        li      t0, struct.port_2.type
        lw      t0, 0x0000(t0)              // t0 = port 2 type
        lli     t1, 0x0002                  // t1 = 2 (type N/A)
        beq     t0, t1, _check_port_3       // if not a CPU or HMN, skip port
        lli     a0, 0x0001
        lw      a1, 0x0010(sp)              // a1 = object reference
        jal     create_action_strings_
        lli     a2, 0x0017                  // a2 = room when pause menus are down

        _check_port_3:
        li      t0, struct.port_3.type
        lw      t0, 0x0000(t0)              // t0 = port 3 type
        lli     t1, 0x0002                  // t1 = 2 (type N/A)
        beq     t0, t1, _check_port_4       // if not a CPU or HMN, skip port
        lli     a0, 0x0002
        lw      a1, 0x0010(sp)              // a1 = object reference
        jal     create_action_strings_
        lli     a2, 0x0017                  // a2 = room when pause menus are down

        _check_port_4:
        li      t0, struct.port_4.type
        lw      t0, 0x0000(t0)              // t0 = port 4 type
        lli     t1, 0x0002                  // t1 = 2 (type N/A)
        beq     t0, t1, _draw_menu          // if not a CPU or HMN, skip port
        lli     a0, 0x0003
        lw      a1, 0x0010(sp)              // a1 = object reference
        jal     create_action_strings_
        lli     a2, 0x0017                  // a2 = room when pause menus are down

        _draw_menu:
        li      a0, info                    // a0 - address of Menu.info()
        jal     Menu.draw_                  // draw menu
        nop

        lli     a0, 0x000E                  // a0 = normal menu group (added objects)
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x0015                  // a0 = custom pause group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x0016                  // a0 = custom menu group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x000F                  // a0 = Hold A text
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        li      t0, run_.show_action
        lw      a1, 0x0000(t0)              // a1 = show action flag
        xori    a1, a1, 0x0001              // a1 = initial display state
        jal     Render.toggle_group_display_
        lli     a0, 0x0017                  // a0 = action & frame group

        // Ensure BGM volume is correct level.
        // Fixes bug where music is quiet if you do a quick reset while paused.
        // Do it here so the music doesn't get loud again before restarting.
        lli     a0, 0x0000                  // a0 = 0 (signifies bgm?)
        lli     a1, 0x7800                  // a1 = 0x7800 (signifies full volume?)
        jal     0x80020B38                  // reset volume
        addiu   sp, sp, -0x0010             // allocate stack space (unsafe routine)
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Runs every frame to correctly update the menu
    scope run_: {
        OS.save_registers()

        li      t0, toggle_menu             // t0 = address of toggle_menu
        lbu     t0, 0x0000(t0)              // t0 = toggle_menu

        li      t2, hold_to_exit_.held_frames

        lli     t1, BOTH_DOWN               // t1 = both menus are down
        beql    t0, t1, _both_down          // branch accordingly
        sw      r0, 0x0000(t2)              // reset held frames for hold to exit

        // check if the ssb menu is up
        lli     t1, SSB_UP                  // t1 = ssb menu is up
        beq     t0, t1, _ssb_up             // branch accordingly
        nop

        // check if the custom menu is up
        lli     t1, CUSTOM_UP               // t1 = custom menu is up
        beql    t0, t1, _custom_up          // branch accordingly
        sw      r0, 0x0000(t2)              // reset held frames for hold to exit

        // otherwise skip
        b       _end
        nop

        _custom_up:
        li      t0, skip_advance
        lw      t0, 0x0000(t0)              // t0 = 0 if we should check for menu updates
        bnez    t0, _check_b                // if not on a frame where we should check menu updates, skip
        nop

        _update_menu:
        // update menu
        li      a0, info                    // a0 - address of Menu.info()
        jal     Menu.update_                // check for updates
        nop

        li      t0, entry_music             // t0 - music menu entry address
        lw      t0, 0x0004(t0)              // t0 - string_table_music index
        sll     t0, t0, 0x0002              // t0 - string_table_music offset
        li      t1, string_table_music      // t1 - address of music string table
        addu    t1, t1, t0                  // t1 - address of BGM name string pointer
        lw      t1, 0x0000(t1)              // t1 - address of BGM name string
        li      t0, bgm_pointer             // t0 - bgm_pointer
        sw      t1, 0x0000(t0)              // save address of BGM name string

        // the first option in the custom training menu has it's next pointer modified for the
        // rest of the option based on the value it holds. this block updates the next pointer
        li      a0, info                    // a0 = info
        lw      t0, 0x0000(a0)              // t0 = address of head (entry)
        lw      t1, 0x0004(t0)              // t1 = entry.curr
        addiu   t1, t1,-0x0001              // t1 = entry.curr-- (p1 = 0, p2 = 1 etc.)
        sll     t1, t1, 0x0002              // t1 = offset
        li      t2, tail_table              // t2 = address of tail_table
        addu    t2, t2, t1                  // t2 = address of tail_table + offset
        lw      a1, 0x0000(t2)              // a1 = address of tail
        lw      t1, 0x001C(t0)              // t1 = current entry.next
        bne     t1, a1, _redraw             // if they are not the same, then update and redraw the menu
        lw      t0, 0x0004(t1)              // t0 = character entry_id

        li      t4, entry_id_to_char_id     // t4 = entry_id_to_char_id table address
        addu    t4, t4, t0                  // t4 = address of char_id
        lbu     t6, 0x0000(t4)              // t6 = char_id

        li      t5, Costumes.select_.num_costumes
        add     t5, t5, t6                  // t5 = num_costumes + offset
        lb      t5, 0x0000(t5)              // t5 = number of original costumes char has (0-based)
        li      t2, Costumes.extra_costumes_table
        sll     at, t6, 0x0002              // at = offset in extra_costumes_table
        addu    t2, t2, at                  // t2 = extra_costumes_table + offset
        lw      t2, 0x0000(t2)              // t2 = extra costumes table, or 0
        lli     t3, 0x0000                  // t2 = costumes to skip
        beqz    t2, _update_max_costume     // if no extra costumes parts table exists, skip getting number of extra costumes
        or      t4, t5, r0                  // t4 = max costume ID
        lbu     t3, 0x0003(t2)              // t3 = costumes to skip
        lbu     t2, 0x0000(t2)              // t2 = number of extra costumes
        addu    t4, t2, t3                  // t4 = number of extra costumes + costumes to skip
        addu    t4, t5, t4                  // t4 = original max costume ID + number of extra costumes + costumes to skip

        _update_max_costume:
        lw      t0, 0x001C(t1)              // t0 = next entry, which is costume
        lw      t1, 0x0004(t0)              // t1 = current costume ID

        lli     at, Character.id.SONIC      // at = Character.id.SONIC
        beql    t6, at, pc() + 8            // if Sonic, assume Classic Sonic has the same number of costumes
        addiu   t4, t4, 0x0006              // t4 = max costume ID for Sonic NOTE: this is hardcoded

        sw      t4, 0x000C(t0)              // save new max
        sltu    at, t1, t4                  // at = 0 if current costume ID >= max ID
        bnez    at, _check_b                // if current costume ID < max ID, then don't redraw
        nop                                 // otherwise, we'll update the values and redraw
        sw      t4, 0x0004(t0)              // change current value to the new max ID in the menu object
        lw      at, 0x0018(t0)              // at = address of struct.port_x.costume
        b       _redraw                     // redraw if here
        sw      t4, 0x0000(at)              // change current value to the new max ID in the port_x struct

        _redraw:
        jal     Menu.destroy_rendered_objects_
        lw      a0, 0x0018(a0)              // a0 = address of first entry currently displayed

        li      a0, info                    // a0 = info
        lw      t0, 0x0000(a0)              // t0 = address of head (entry)
        sw      a1, 0x001C(t0)              // entry.next = address of head

        // redraw menu
        li      a0, info                    // a0 - address of Menu.info()
        jal     Menu.redraw_                // check for updates
        lw      a1, 0x0018(a0)              // a1 - first entry

        _check_b:
        // check for b press
        lli     a0, Joypad.B                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool b_pressed
        nop
        bnez    v0, _close_custom_menu      // if (b_pressed), close custom menu
        nop
        // check for z press
        lli     a0, Joypad.Z                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool b_pressed
        nop
        beqz    v0, _check_l                // if (!z_pressed), jump to L check
        nop
        _close_custom_menu:
        li      t0, toggle_menu             // t0 = toggle_menu
        lli     t1, SSB_UP                  // ~
        sb      t1, 0x0000(t0)              // toggle menu = SSB_UP

        lli     a0, 0x0016                  // a0 = custom menu group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x000E                  // a0 = normal menu group
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                  // a1 = display on

        b       _check_l                    // jump to L check
        nop

        _ssb_up:

        lli     a0, 0x0015                  // a0 = custom pause group
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                  // a1 = display on

        // check for z press
        lli     a0, Joypad.Z                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        lli     a2, Joypad.PRESSED          // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool z_pressed
        nop
        beqz    v0, _check_l                // if (!z_pressed), jump to L check
        nop
        lli     a0, 0x0116                  // a0 - fgm_id
        jal     FGM.play_                   // play training menu start sound
        nop
        li      t0, toggle_menu             // t0 = toggle_menu
        lli     t1, CUSTOM_UP               // ~
        sb      t1, 0x0000(t0)              // toggle menu = CUSTOM_UP

        // draw menu
        lli     a0, 0x0016                  // a0 = custom menu group
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                  // a1 = display on

        lli     a0, 0x000E                  // a0 = normal menu group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x000F                  // a0 = Hold A text
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        _check_l:
        lli     a0, Joypad.L                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        jal     Joypad.check_buttons_all_   // v0 - bool l_pressed
        lli     a2, Joypad.PRESSED          // a2 - type
        beqz    v0, _check_A_held           // if (!l_pressed), skip
        nop
        li      t0, show_action             // t0 = show action flag address
        lw      a1, 0x0000(t0)              // a1 = show action flag (will use for display flag below)
        xori    t2, a1, 0x0001              // t2 = flip flag
        sw      t2, 0x0000(t0)              // update flag
        jal     Render.toggle_group_display_
        lli     a0, 0x0017                  // a0 = action & frame group

        _check_A_held:
        li      t9, Toggles.entry_hold_to_exit_training
        lw      t9, 0x0004(t9)              // t9 = 1 if hold to exit training mode is enabled, else 0
        beqzl   t9, _end                    // if hold to exit disabled
        nop

        li      t0, toggle_menu             // t0 = address of toggle_menu
        lbu     t0, 0x0000(t0)              // t0 = toggle_menu
        lli     t1, SSB_UP                  // t1 = ssb menu is up
        bne     t0, t1, _no_rect            // if menus are down, don't draw rectangle
        nop

        li      t1, 0x80190B58              // t1 = address of cursor index
        lw      t1, 0x0000(t1)              // t1 = cursor index
        lli     t2, 0x0005                  // t2 = 5 (EXIT)
        beq     t1, t2, _cursor_on_exit     // if on the EXIT option, show 'Hold A' text
        nop

        lli     a0, 0x000F                  // a0 = Hold A text
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off
        b       _no_rect                    // if not on the EXIT option, don't draw rectangle
        nop

        _cursor_on_exit:
        lli     a0, 0x000F                  // a0 = Hold A text
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                  // a1 = display on

        lli     a0, Joypad.A                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        jal     Joypad.check_buttons_all_   // v0 - bool a_pressed
        lli     a2, Joypad.HELD             // a2 - type
        move    s3, r0
        beqz    v0, _check_A_up             // if (!a_pressed), skip
        nop

        li      s4, hold_A_rect_width       // s4 = address of hold_A_rect_width
        lw      s3, 0x0000(s4)              // s3 = hold_A_rect_width
        li      s5, 64                      // s5 = maximum width of red bar (and therefore also our blue rect)
        bltul   s3, s5, _hold_A_rect_grew   // only increment rect width if has not reached maximum width
        addiu   s3, s3, 2                   // increment rect width

        _hold_A_rect_grew:
        sw      s3, 0x0000(s4)              // hold_A_rect_width = s3

        _check_A_up:
        li      s4, hold_A_rect_object      // s4 = address of hold_A_rect_object pointer
        lw      s5, 0x0000(s4)              // s5 = hold_A_rect_object pointer
        sw      s3, 0x0038(s5)              // set width of hold_A_rect_object to s3

        lli     a0, Joypad.A                // a0 - button_mask
        lli     a1, 000069                  // a1 - whatever you like!
        jal     Joypad.check_buttons_all_   // v0 - bool a_pressed
        lli     a2, Joypad.RELEASED         // a2 - type
        beqz    v0, _end                    // if (!a_released), keep rect
        nop

        // placeholder - find a suitable sound effect(?)
        //lli     a0, FGM.item.BEAM_SWORD_HEAVY
        //jal     FGM.play_
        //nop
        b       _no_rect
        nop

        _end:
        OS.restore_registers()
        jr      ra
        nop

        _both_down:
        lli     a0, 0x0015                  // a0 = custom pause group
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        lli     a0, 0x000F                  // a0 = Hold A text
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = display off

        li      t9, Toggles.entry_hold_to_exit_training
        lw      t9, 0x0004(t9)              // t9 = 1 if hold to exit training mode is enabled, else 0
        beqzl   t9, _end                    // if hold to exit disabled
        nop

        _no_rect:
        li      s4, hold_A_rect_object      // s4 = address of hold_A_rect_object pointer
        lw      s5, 0x0000(s4)              // s5 = hold_A_rect_object pointer
        sw      r0, 0x0038(s5)              // set width of hold_A_rect_object to 0
        li      s4, hold_A_rect_width       // s4 = address of hold_A_rect_width
        sw      r0, 0x0000(s4)              // hold_A_rect_width = 0
        b       _end
        nop

        show_action:
        dw OS.FALSE
    }

    // @ Description
    // Control object for action and frame strings
    action_control_object:
    dw 0

    // @ Description
    // Runs every frame advance in order to frame count
    // @ Arguments
    // a0 - action & frame control object
    scope update_frame_counts_: {
        // 0x0030(a0) - previous actionID for p1
        // 0x0034(a0) - previous actionID for p2
        // 0x0038(a0) - previous actionID for p3
        // 0x003C(a0) - previous actionID for p4
        // 0x0040(a0) - frame count for p1
        // 0x0044(a0) - frame count for p2
        // 0x0048(a0) - frame count for p3
        // 0x004C(a0) - frame count for p4
        // 0x0050(a0) - action string object for p1
        // 0x0054(a0) - action string object for p2
        // 0x0058(a0) - action string object for p3
        // 0x005C(a0) - action string object for p4
        // 0x0060(a0) - frame string object for p1
        // 0x0064(a0) - frame string object for p2
        // 0x0068(a0) - frame string object for p3
        // 0x006C(a0) - frame string object for p4

        li      t0, Global.p_struct_head
        lw      t0, 0x0000(t0)              // t0 = 1st player struct

        _loop:
        lw      t1, 0x0004(t0)              // t1 = player object
        beqz    t1, _next                   // if no player object, skip
        lbu     t1, 0x000D(t0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset for port
        addu    t2, a0, t1                  // t2 = address of control object offset by port
        lw      t3, 0x0030(t2)              // t3 = previous actionID
        lw      t4, 0x0024(t0)              // t4 = current actionID
        sw      t4, 0x0030(t2)              // update previous actionID
        lw      t5, 0x0040(t2)              // t5 = frame count
        lw      t6, 0x0040(t0)              // t6 = hit lag frames remaining
        beqzl   t6, pc() + 8                // if not in hit lag, increment frame count
        addiu   t5, t5, 0x0001              // t5++
        bnel    t3, t4, pc() + 8            // if action changed, reset frame count
        lli     t5, 0x0001                  // t5 = 1
        sw      t5, 0x0040(t2)              // update frame count

        _next:
        lw      t0, 0x0000(t0)              // t0 = next player struct
        bnez    t0, _loop                   // go to next player if there is one
        nop

        jr      ra
        nop
    }

    // @ Description
    // Runs every frame (even in frame advance mode) in order to update action & frame strings
    scope update_actions_: {
        li      a0, action_control_object
        lw      a0, 0x0000(a0)              // a0 = action & frame control object

        // 0x0030(a0) - previous actionID for p1
        // 0x0034(a0) - previous actionID for p2
        // 0x0038(a0) - previous actionID for p3
        // 0x003C(a0) - previous actionID for p4
        // 0x0040(a0) - frame count for p1
        // 0x0044(a0) - frame count for p2
        // 0x0048(a0) - frame count for p3
        // 0x004C(a0) - frame count for p4
        // 0x0050(a0) - action string object for p1
        // 0x0054(a0) - action string object for p2
        // 0x0058(a0) - action string object for p3
        // 0x005C(a0) - action string object for p4
        // 0x0060(a0) - frame string object for p1
        // 0x0064(a0) - frame string object for p2
        // 0x0068(a0) - frame string object for p3
        // 0x006C(a0) - frame string object for p4

        OS.save_registers()
        // 0x0010(sp) = action & frame control object

        lli     t8, 0x0039                  // t8 = room for strings when menu is up

        li      t0, toggle_menu             // t0 = address of toggle_menu
        lbu     t0, 0x0000(t0)              // t0 = toggle_menu
        lli     t1, BOTH_DOWN               // t1 = both menus are down
        beql    t0, t1, pc() + 8            // if both menus are down, then use a different room
        lli     t8, 0x0017                  // t8 = room for strings when menu is down
        sw      t8, 0x0040(sp)              // save room

        li      t0, Global.p_struct_head
        lw      t0, 0x0000(t0)              // t0 = 1st player struct

        _loop:
        lw      t1, 0x0004(t0)              // t1 = player object
        beqz    t1, _next                   // if no player object, skip
        lbu     t1, 0x000D(t0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset for port
        addu    t2, a0, t1                  // t2 = address of control object offset by port
        lw      t4, 0x0024(t0)              // t4 = current actionID

        // First,update the string pointers
        li      t6, p1_action_pointer       // t6 = first action pointer
        addu    t6, t6, t1                  // t6 = action pointer for port
        sltiu   at, t4, 0x00DC              // at = 0 if not a shared action
        beqzl   at, _unique                 // if not a shared action, skip to unique
        lw      t5, 0x0008(t0)              // t5 = char_id

        li      t7, Action.shared_action_string_table
        sll     t4, t4, 0x0002              // t4 = offset to string pointer
        addu    t7, t7, t4                  // t7 = address of string pointer
        b       _update
        lw      t7, 0x0000(t7)              // t7 = string pointer

        _unique:
        li      t7, Character.action_string.table
        sll     t5, t5, 0x0002              // t5 = offset to character action string table
        addu    t7, t7, t5                  // t7 = address of action string table pointer
        lw      t7, 0x0000(t7)              // t7 = action string table pointer
        beqz    t7, _update                 // if no action string table, show no string
        addiu   t4, t4, -0x00DC             // t4 = index in action string table
        sll     t4, t4, 0x0002              // t4 = offset to string pointer
        addu    t7, t7, t4                  // t7 = address of string pointer
        lw      t7, 0x0000(t7)              // t7 = string pointer

        _update:
        sw      t7, 0x0000(t6)              // update action string pointer

        // Here, check if the action strings should be displayed
        li      t7, run_.show_action
        lw      t7, 0x0000(t7)              // t7 = show action flag
        beqz    t7, _next                   // skip of actions are not displayed
        nop

        // Strings should be displayed, so check if the strings exist
        lw      t6, 0x0050(t2)              // t6 = action string object
        beqz    t6, _create_strings         // if strings don't exist, create them
        nop
        //   Check the room and if it is not correct, recreate the strings
        lbu     t7, 0x000D(t6)              // t7 = current room
        lw      t8, 0x0040(sp)              // t8 = correct room
        bne     t7, t8, _create_strings     // if not in the correct room, recreate in the correct room
        nop
        sw      t0, 0x0020(sp)              // save player struct
        sw      t2, 0x0028(sp)              // save t2

        // Since we didn't register the events on the objects, we need to run update_live_string_ now
        jal     Render.update_live_string_
        or      a0, t6, r0                  // a0 = action string object

        lw      t2, 0x0028(sp)              // t2 = address of control object offset by port
        jal     Render.update_live_string_
        lw      a0, 0x0060(t2)              // a0 = frame count string object

        lw      t0, 0x0020(sp)              // restore player struct

        b       _next
        nop

        _create_strings:
        sw      t0, 0x0020(sp)              // save player struct

        srl     a0, t1, 0x0002              // a0 = port
        lw      a1, 0x0010(sp)              // a1 = object reference
        jal     create_action_strings_
        lw      a2, 0x0040(sp)              // a2 = room

        lw      t0, 0x0020(sp)              // restore player struct

        _next:
        lw      t0, 0x0000(t0)              // t0 = next player struct
        bnez    t0, _loop                   // go to next player if there is one
        lw      a0, 0x0010(sp)              // a0 = action & frame control object

        OS.restore_registers()

        jr      ra
        nop
    }

    // @ Description
    // This hook allows us to play custom music instead of the standard training mode music
    scope play_custom_music_: {
        OS.patch_start(0x116994, 0x80190174)
        jal     play_custom_music_
        nop
        OS.patch_end()

        // addiu   a1, r0, 0x002A              // original line 1

        li      at, entry_music             // at = address of music menu entry
        lw      at, 0x0004(at)              // at = bgm_table index
        li      t7, bgm_table               // t7 = address of bgm_table
        addu    a1, at, t7                  // a1 = address of bgm_id
        lbu     a1, 0x0000(a1)              // a1 = bgm_id

        sw      a1, 0x0000(v0)              // original line 2

        jr      ra                          // return
        nop
    }

    // @ Description
    // This holds each player's shield status as a single byte
    player_shield_status:
    db      0, 0, 0, 0

    // @ Description
    // Forces CPUs to shield until hit and they can perform a move again
    // Work in progress, but functional
    scope shield_break_mode_: {
        constant SHIELD(0x0000)
        constant STUN(0x0001)
        constant OOS_FRAME_1(0x0002)
        constant OOS_FRAME_2(0x0003)

        OS.patch_start(0x5CC2C, 0x800E142C)
        jal     shield_break_mode_
        lb      v1, 0x0006(v0)              // original line 2 (keep - this line is branched to)
        OS.patch_end()

        // a2 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        swc1    f0, 0x0004(sp)              // ~
        swc1    f2, 0x0008(sp)              // store f0, f2

        li      v1, Global.current_screen   // ~
        lbu     v1, 0x0000(v1)              // v1 = screen_id
        addiu   v1, v1, -0x0036             // v1 = 0 if training
        bnez    v1, _original               // skip if screen_id != training mode
        nop

        li      v1, entry_shield_break_mode
        lw      v1, 0x0004(v1)              // v1 = shield break mode
        beqz    v1, _original               // skip if shield break mode off
        nop

        lbu     v1, 0x000D(a2)              // v1 = player index (0 - 3)
        li      t3, player_shield_status
        addu    t3, t3, v1                  // t3 = address of shield status for this player
        lbu     at, 0x0000(t3)              // at = shield status
        lli     v1, SHIELD                  // v1 = SHIELD
        beq     at, v1, _shielding          // if player isn't being attacked, force shield
        lli     v1, STUN                    // v1 = STUN
        beq     at, v1, _in_shield_stun     // if player is being attacked, allow shield damage but continue to force shield
        lli     v1, OOS_FRAME_2             // v1 = OOS_FRAME_2
        beq     at, v1, _end_oos            // if player has executed their OOS option, reset shield status
        nop

        _oos:
        // if we're here, then the player can execute their OOS option
        lli     t7, OOS_FRAME_1             // t7 = OOS_FRAME_1
        beql    at, t7, pc() + 8            // if already in OOS_FRAME_1, set to OOS_FRAME_2
        lli     t7, OOS_FRAME_2             // t7 = OOS_FRAME_2

        // for NAir and DSP, we'll wait until jumpsquat is over before advancing to "frame 2"
        lli     at, 0x0006                  // at = OOS index for dsp
        li      a3, entry_oos_option
        lw      a3, 0x0004(a3)              // a3 = OOS option
        beq     a3, at, pc() + 12           // if dsp, continue checking action
        lli     at, 0x0007                  // at = OOS index for nair
        bne     a3, at, _oos_input          // if not nair, skip checking action
        lw      at, 0x0024(a2)              // at = current action
        lli     a3, Action.ShieldJumpSquat  // a3 = ShieldJumpSquat
        bne     at, a3, _oos_input          // if no longer in jumpsquat, move to frame 2
        lw      at, 0x09C8(a2)              // at = player attributes
        lwc1    f4, 0x0034(at)              // f4 = jumpsquat frames, floating point
        trunc.w.s f4, f4                    // f4 = jumpsquat frames, decimal
        mfc1    a3, f4                      // a3 = jumpsquat frames
        lw      at, 0x001C(a2)              // at = current frame
        bnel    at, a3, pc() + 8            // if not in last frame of jumpsquat, pretend we're still in frame 1
        lli     t7, OOS_FRAME_1             // t7 = OOS_FRAME_1

        _oos_input:
        sb      t7, 0x0000(t3)              // update shield status to OOS_FRAME_1/2
        li      a3, entry_oos_option
        lw      a3, 0x0004(a3)              // a3 = OOS option
        sll     t7, a3, 0x0002              // t7 = offset to button mask/stick value
        lbu     at, 0x0000(t3)              // at = shield status (OOS_FRAME_1 or OOS_FRAME_2)
        li      a3, oos_inputs_frame_1
        beql    at, v1, pc() + 8            // if shield status is OOS_FRAME_2, then use frame 2 table
        addiu   a3, a3, oos_inputs_frame_2 - oos_inputs_frame_1
        addu    t7, a3, t7                  // t7 = button mask address
        lh      a3, 0x0000(t7)              // a3 = button mask for OOS option
        sh      a3, 0x0002(v0)              // store button press
        lh      t7, 0x0002(t7)              // t7 = stick value
        sh      t7, 0x0006(v0)              // store stick value
        lli     t7, Joypad.Z
        b       _original                   // don't continue holding shield on this frame
        sh      t7, 0x0004(v0)              // store shield button release

        _end_oos:
        sb      r0, 0x0000(t3)              // reset shield status to SHIELD
        li      t7, entry_oos_option
        lw      t7, 0x0004(t7)              // t7 = OOS option
        sll     t7, t7, 0x0002              // t7 = offset to button mask
        li      a3, oos_inputs_frame_2
        addu    t7, a3, t7                  // t7 = button mask address
        lh      a3, 0x0000(t7)              // a3 = button mask for OOS option
        sh      a3, 0x0004(v0)              // store button release
        lh      t7, 0x0002(t7)              // t7 = stick value
        sh      t7, 0x0006(v0)              // store stick release
        b       _force_shield               // start holding shield on this frame
        nop

        _shielding:
        // let's first check if we're being hit - the character will be in the ShieldStun action while being hit
        lw      v1, 0x0024(a2)              // a1 = current action
        lli     at, Action.ShieldStun       // at = Action.ShieldStun
        lli     t7, STUN                    // t7 = STUN
        beql    v1, at, _force_shield       // if in shield stun, change shield status and allow damage but still force shield
        sb      t7, 0x0000(t3)              // store new shield status

        // until hit, force shield to stay 100% charged
        lli     v1, 0x0037                  // v1 = max shield value, unstale
        b       _force_shield
        sw      v1, 0x0034(a2)              // force max shield

        _in_shield_stun:
        // check if the character is still in the ShieldStun action, update status to SHIELD if they are not
        lw      v1, 0x0024(a2)              // a1 = current action
        lli     at, Action.ShieldStun       // at = Action.ShieldStun
        bnel    v1, at, _original           // if not in shield stun, change shield status back to SHIELD
        sb      r0, 0x0000(t3)              // update shield status to SHIELD

        // check if shield stun is on final frame and input OOS option
        lwc1    f0, 0x0B34(a2)              // f0 = shield stun (float)
        lui     at, 0x3F80                  // ~
        mtc1    at, f2                      // ~
        sub.s   f0, f0, f2                  // ~
        mfc1    v1, f0                      // v1 = shield stun -1
        blez    v1, _oos                    // if shield stun is less than 1, perform OOS option
        nop                                 // otherwise, CPU should keep shielding

        _force_shield:
        lli     a3, Joypad.Z                // force CPU to shield

        _original:
        sh      a3, 0x0000(v0)              // original line 1


        lwc1    f0, 0x0004(sp)              // ~
        lwc1    f2, 0x0008(sp)              // store f0, f2
        addiu   sp, sp, 0x0010              // allocate stack space
        jr      ra
        lb      v1, 0x0006(v0)              // original line 2
    }

	// @ Description
	// Fixes a crash if there are less than two players in Sector Z
	scope fix_sector_z_crashes_: {
		OS.patch_start(0x82FFC, 0x801077FC)
		j		fix_sector_z_crashes_
		nop
		_return:
		OS.patch_end()

		bnezl	a0, _normal
		lw		v0, 0x0084(a0)			// original line 1

		_exit:
		j		0x80107900				// skip to end
		lw		ra, 0x001C(sp)

		_normal:
		j		_return
		addiu	at, t0, 0xFFFF			// original line 2
	}

    // @ Description
    // Hooks to avoid crashes due to Pokemon opponent targeting when no other ports loaded
    scope fix_pokemon_crashes_: {
        // hitmonlee
        OS.patch_start(0xFD2A0, 0x80182860)
        sw      ra, 0x001C(sp)              // original line 3
        jal     fix_pokemon_crashes_._hitmonlee
        nop
        OS.patch_end()

        // starmie
        OS.patch_start(0xFCB38, 0x801820F8)
        jal     fix_pokemon_crashes_._starmie
        lw      s2, 0x0084(a0)              // original line 1 - s2 = item special struct
        OS.patch_end()

        // blastoise
        OS.patch_start(0xFB614, 0x80180BD4)
        jal     fix_pokemon_crashes_._blastoise
        lw      s2, 0x0084(a0)              // original line 1 - s2 = item special struct
        OS.patch_end()

        _hitmonlee:
        // a0 - item object
        // a1 - opponent player object, or 0... if 0, we'll need to replace with the throwing player's object

        bnez    a1, _end_hitmonlee          // if there is an opponent, return normally
        lw      t6, 0x0084(a0)              // t6 = item struct
        lw      a1, 0x0008(t6)              // a1 = throwing player's object

        _end_hitmonlee:
        sw      a1, 0x0054(sp)              // original line 1
        jr      ra
        lw      t6, 0x0054(sp)              // original line 2

        _starmie:
        // 0x006C(sp) is garbage when there is no other player, so we set it to the throwing player's object

        lw      s4, 0x0008(s2)              // s4 = throwing player's object
        sw      s4, 0x006C(sp)              // save in stack

        jr      ra
        lw      s4, 0x0074(a0)              // original line 2

        _blastoise:
        // 0x0074(sp) is garbage when there is no other player, so we set it to the throwing player's object

        lw      s4, 0x0008(s2)              // s4 = throwing player's object
        sw      s4, 0x0074(sp)              // save in stack

        jr      ra
        lw      s4, 0x0074(a0)              // original line 2
    }

    // @ Description
    // This allows us to not hear the crowd cheer when entering/reseting Training Mode
    scope skip_crowd_cheer_: {
        OS.patch_start(0x116D68, 0x80190548)
        j       skip_crowd_cheer_
        nop
        _return:
        OS.patch_end()

        li      a0, Toggles.entry_skip_training_start_cheer
        lw      a0, 0x0004(a0)              // a0 = 1 if skip crowd noise is enabled, else 0
        bnez    a0, _end                    // if skip crowd noise is enabled, skip crowd noise lol
        nop

        jal     0x800269C0                  // original line 1 - play fgm
        addiu   a0, r0, 0x0272              // original line 2 - a0 = crowd cheer fgm_id

        _end:
        j       _return
        nop
    }

    // @ Description
    // Strings used to explain advance_frame_ shortcuts
    dpad_pause:; db "Toggle Pause", 0x00
    dpad_frame:; db "Frame Advance", 0x00
    dpad_model:; db "Model Display", 0x00
    dpad_reset:; db "Quick Reset", 0x00

    // @ Description
    // Message/visual indicator to hold A to exit training (displayed if hold to exit is enabled)
    hold_A_text:; db "(Hold --)", 0x00

    // @ Description
    // String used for reset counter which appears while the training menu is up
    reset_string:; db "Reset Count:", 0x00

    // @ Description
    // Message/visual indicator to press Z for custom menu
    press_z:; db "Press    for Custom Menu", 0x00

    // @ Description
    // Type strings
    type_1:; db "Human", 0x00
    type_2:; db "CPU", 0x00
    type_3:; db "Disabled", 0x00

    // @ Description
    // String used for L button legend
    action_legend_1:; db "Show", 0x00
    action_legend_2:; db "Action", 0x00

    // @ Description
    // Out of Shield Options
    oos_jump:; db "Jump", 0x00
    oos_roll_left:; db "Roll Left", 0x00
    oos_roll_right:; db "Roll Right", 0x00
    oos_grab:; db "Grab", 0x00
    oos_upsmash:; db "Up Smash", 0x00
    oos_usp:; db "Up Special", 0x00
    oos_dsp:; db "Down Special", 0x00
    oos_nair:; db "Neutral Air", 0x00
    oos_shield_drop:; db "Shield Drop", 0x00
    oos_shield_drop_dsp:; db "S. Drop DSP", 0x00
    oos_shield_drop_nair:; db "S. Drop NAir", 0x00

    OS.align(4)

    string_table_type:
    dw type_1
    dw type_2
    dw type_3

    string_table_oos_options:
    dw oos_jump
    dw oos_roll_left
    dw oos_roll_right
    dw oos_grab
    dw oos_upsmash
    dw oos_usp
    dw oos_dsp
    dw oos_nair
    dw oos_shield_drop
    dw oos_shield_drop_dsp
    dw oos_shield_drop_nair
    constant OOS_MAX(10)

    // @ Description
    // Holds button masks and stick values for the first 2 frames after shied stun ends in shield break mode
    oos_inputs_frame_1:
    // button mask          stick value
    dh Joypad.Z,            0x0035      // jump
    dh Joypad.Z,            0xB000      // roll left
    dh Joypad.Z,            0x5000      // roll right
    dh Joypad.Z | Joypad.A, 0x0000      // grab
    dh Joypad.Z,            0x0035      // usmash (enter jumpsquat first)
    dh Joypad.Z,            0x0035      // usp (enter jumpsquat first)
    dh Joypad.Z,            0x0035      // dsp (enter jumpsquat first)
    dh Joypad.Z,            0x0035      // nair (enter jumpsquat first)
    dh Joypad.Z,            0x00B0      // shield drop
    dh Joypad.Z,            0x00B0      // shield drop dsp
    dh Joypad.Z,            0x00B0      // shield drop nair

    oos_inputs_frame_2:
    // button mask          stick value
    dh Joypad.Z,            0x0035      // jump
    dh Joypad.Z,            0xB000      // roll left
    dh Joypad.Z,            0x5000      // roll right
    dh Joypad.Z | Joypad.A, 0x0000      // grab
    dh Joypad.A,            0x0050      // usmash
    dh Joypad.B,            0x0050      // usp
    dh Joypad.B,            0x00B0      // dsp
    dh Joypad.A,            0x0000      // nair
    dh Joypad.Z,            0x00B0      // shield drop
    dh Joypad.B,            0x00B0      // shield drop dsp
    dh Joypad.A,            0x0000      // shield drop nair

    // @ Description
    // Character Strings
    string_mario:; string_Mario:; char_0x00:; db "Mario" , 0x00
    string_fox:; char_0x01:; db "Fox", 0x00
    string_dk:; char_0x02:; db "DK", 0x00
    string_samus:; char_0x03:; db "Samus", 0x00
    string_luigi:; char_0x04:; db "Luigi", 0x00
    string_link:; char_0x05:; db "Link", 0x00
    string_yoshi:; char_0x06:; db "Yoshi", 0x00
    string_cfalcon:; char_0x07:; db "C. Falcon", 0x00
    string_kirby:; char_0x08:; db "Kirby", 0x00
    string_pikachu:; char_0x09:; db "Pikachu", 0x00
    string_jigglypuff:; char_0x0A:; db "Jigglypuff", 0x00
    string_ness:; char_0x0B:; db "Ness", 0x00
    //string_boss:; char_0x0C:; db "Master Hand", 0x00
    string_metal:; char_0x0D:; db "Metal Mario", 0x00
    string_nmario:; char_0x0E:; db "Poly Mario", 0x00
    string_nfox:; char_0x0F:; db "Poly Fox", 0x00
    string_ndk:; char_0x10:; db "Poly DK", 0x00
    string_nsamus:; char_0x11:; db "Poly Samus", 0x00
    string_nluigi:; char_0x12:; db "Poly Luigi", 0x00
    string_nlink:; char_0x13:; db "Poly Link", 0x00
    string_nyoshi:; char_0x14:; db "Poly Yoshi", 0x00
    string_nfalcon:; char_0x15:; db "Poly Falcon", 0x00
    string_nkirby:; char_0x16:; db "Poly Kirby", 0x00
    string_npikachu:; char_0x17:; db "Poly Pikachu", 0x00
    string_npuff:; char_0x18:; db "Poly Puff", 0x00
    string_nness:; char_0x19:; db "Poly Ness", 0x00
    string_nwario:; char_Px02:; db "Poly Wario", 0x00
    string_nlucas:; char_Px03:; db "Poly Lucas", 0x00
    string_nbowser:; char_Px04:; db "Poly Bowser", 0x00
    string_nwolf:; char_Px05:; db "Poly Wolf", 0x00
    string_ndrmario:; char_Px01:; db "Poly Dr. Mario", 0x00
    string_nsonic:; char_Px06:; db "Poly Sonic", 0x00
    string_nsheik:; char_Px07:; db "Poly Sheik", 0x00
    string_nmarina:; char_Px08:; db "Poly Marina", 0x00
    string_gdk:; char_0x1A:; db "Giant DK", 0x00
    //char_0x1B:; db "NONE", 0x00
    //char_0x1C:; db "NONE", 0x00
    string_falco:; char_0x1D:; db "Falco", 0x00
    string_ganondorf:; char_0x1E:; db "Ganondorf", 0x00
    string_younglink:; char_0x1F:; db "Young Link", 0x00
    string_drmario:; char_0x20:; db "Dr. Mario", 0x00
    string_wario:; char_0x21:; db "Wario", 0x00
    string_dsamus:; char_0x22:; db "Dark Samus", 0x00
    string_elink:; char_0x23:; db "E Link", 0x00
    string_jsamus:; char_0x24:; db "J Samus", 0x00
    string_jness:; char_0x25:; db "J Ness", 0x00
    string_lucas:; char_0x26:; db "Lucas", 0x00
    string_jlink:; char_0x27:; db "J Link", 0x00
    string_jfalcon:; char_0x28:; db "J Falcon", 0x00
    string_jfox:; char_0x29:; db "J Fox", 0x00
    string_jmario:; char_0x2A:; db "J Mario", 0x00
    string_jluigi:; char_0x2B:; db "J Luigi", 0x00
    string_jdk:; char_0x2C:; db "J DK", 0x00
    string_epikachu:; char_0x2D:; db "E Pikachu", 0x00
    string_purin:; char_0x2E:; db "Purin", 0x00
    string_ejigglypuff:; char_0x2F:; db "E Jigglypuff", 0x00
    string_jkirby:; char_0x30:; db "J Kirby", 0x00
    string_jyoshi:; char_0x31:; db "J Yoshi", 0x00
    string_jpikachu:; char_0x32:; db "J Pikachu", 0x00
    string_esamus:; char_0x33:; db "E Samus", 0x00
    string_bowser:; char_0x34:; db "Bowser", 0x00
	string_gbowser:; char_0x35:; db "Giga Bowser", 0x00
    string_piano:; char_0x36:; db "Mad Piano", 0x00
	string_wolf:; char_0x37:; db "Wolf", 0x00
    string_conker:; char_0x38:; db "Conker", 0x00
    string_mewtwo:; char_0x39:; db "Mewtwo", 0x00
    string_marth:; char_0x3A:; db "Marth", 0x00
    string_sonic:; char_0x3B:; db "Sonic", 0x00
    string_sandbag:; char_0x3C:; db "Sandbag", 0x00
    string_ssonic:; char_0x3D:; db "Super Sonic", 0x00
    string_sheik:; char_0x3E:; db "Sheik", 0x00
    string_marina:; char_0x3F:; db "Marina", 0x00
    string_dedede:; char_0x40:; db "Dedede", 0x00
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
    dw char_0x21            // WARIO
    dw char_0x22            // DARK SAMUS
    dw char_0x26            // LUCAS
	dw char_0x34            // BOWSER
	dw char_0x37            // WOLF
    dw char_0x38            // CONKER
    dw char_0x39            // MEWTWO
    dw char_0x3A            // MARTH
    dw char_0x3B            // SONIC
    dw char_0x3E            // SHEIK
    dw char_0x3F            // MARINA
    dw char_0x40            // DEDEDE

    dw char_0x2A            // J MARIO
    dw char_0x29            // J FOX
    dw char_0x2C            // J DK
    dw char_0x24            // J SAMUS
    dw char_0x2B            // J LUIGI
    dw char_0x27            // J LINK
    dw char_0x31            // J YOSHI
    dw char_0x28            // J FALCON
    dw char_0x30            // J KIRBY
    dw char_0x32            // J PIKA
    dw char_0x2E            // PURIN
    dw char_0x25            // J NESS

    dw char_0x33            // E SAMUS
    dw char_0x23            // E LINK
    dw char_0x2D            // E PIKACHU
    dw char_0x2F            // E JIGGLYPUFF

    dw char_0x0D            // METAL MARIO
    dw char_0x1A            // GIANT DK
	dw char_0x35            // GIGA BOWSER
    dw char_0x36            // PIANO
    dw char_0x3D            // SUPER SONIC
    dw char_0x3C            // SANDBAG
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
    dw char_Px01            // POLYGON DRM
    dw char_Px02            // POLYGON WARIO
    dw char_Px03            // POLYGON LUCAS
    dw char_Px04            // POLYGON BOWSER
    dw char_Px05            // POLYGON WOLF
    dw char_Px06            // POLYGON SONIC
    dw char_Px07            // POLYGON SHEIK
    dw char_Px08            // POLYGON MARINA

    // @ Description
    // Training character id is really the order they are displayed in
    // constant names are loosely based on the debug names for characters
    scope id {
        // original cast
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

        // custom characters
        constant FALCO(0x0C)
        constant GND(0x0D)
        constant YLINK(0x0E)
        constant DRM(0x0F)
        constant WARIO(0x10)
        constant DSAMUS(0x11)
        constant LUCAS(0x12)
		constant BOWSER(0x13)
		constant WOLF(0x14)
        constant CONKER(0x15)
        constant MTWO(0x16)
        constant MARTH(0x17)
        constant SONIC(0x18)
        constant SHEIK(0x19)
        constant MARINA(0x1A)
        constant DEDEDE(0x1B)

        // Increment JMARIO after adding more characters above
        // j characters
        constant JMARIO(0x1C)
        constant JFOX(JMARIO + 0x01)
        constant JDK(JMARIO + 0x02)
        constant JSAMUS(JMARIO + 0x03)
        constant JLUIGI(JMARIO + 0x04)
        constant JLINK(JMARIO + 0x05)
        constant JYOSHI(JMARIO + 0x06)
        constant JFALCON(JMARIO + 0x07)
        constant JKIRBY(JMARIO + 0x08)
        constant JPIKA(JMARIO + 0x09)
        constant JPUFF(JMARIO + 0x0A)
        constant JNESS(JMARIO + 0x0B)
        // e characters
        constant ESAMUS(JMARIO + 0x0C)
        constant ELINK(JMARIO + 0x0D)
        constant EPIKA(JMARIO + 0x0E)
        constant EPUFF(JMARIO + 0x0F)
        // bosses and polygons
        constant METAL(JMARIO + 0x10)
        constant GDONKEY(JMARIO + 0x11)
        constant GBOWSER(JMARIO + 0x12)
        constant PIANO(JMARIO + 0x13)
        constant SSONIC(JMARIO + 0x14)
        constant SANDBAG(JMARIO + 0x15)
		constant NMARIO(JMARIO + 0x16)
        constant NFOX(JMARIO + 0x17)
        constant NDONKEY(JMARIO + 0x18)
        constant NSAMUS(JMARIO + 0x19)
        constant NLUIGI(JMARIO + 0x1A)
        constant NLINK(JMARIO + 0x1B)
        constant NYOSHI(JMARIO + 0x1C)
        constant NCAPTAIN(JMARIO + 0x1D)
        constant NKIRBY(JMARIO + 0x1E)
        constant NPIKACHU(JMARIO + 0x1F)
        constant NJIGGLY(JMARIO + 0x20)
        constant NNESS(JMARIO + 0x21)
        constant NDRM(JMARIO + 0x22)
        constant NWARIO(JMARIO + 0x23)
        constant NLUCAS(JMARIO + 0x24)
        constant NBOWSER(JMARIO + 0x25)
        constant NWOLF(JMARIO + 0x26)
        constant NSONIC(JMARIO + 0x27)
        constant NSHEIK(JMARIO + 0x28)
        constant NMARINA(JMARIO + 0x29)
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
    db Character.id.WARIO
    db Character.id.DSAMUS
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

    db Character.id.JMARIO
    db Character.id.JFOX
    db Character.id.JDK
    db Character.id.JSAMUS
    db Character.id.JLUIGI
    db Character.id.JLINK
    db Character.id.JYOSHI
    db Character.id.JFALCON
    db Character.id.JKIRBY
    db Character.id.JPIKA
    db Character.id.JPUFF
    db Character.id.JNESS

    db Character.id.ESAMUS
    db Character.id.ELINK
    db Character.id.EPIKA
    db Character.id.EPUFF

    db Character.id.METAL
    db Character.id.GDONKEY
	db Character.id.GBOWSER
    db Character.id.PIANO
    db Character.id.SSONIC
    db Character.id.SANDBAG
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
    db Character.id.NDRM
    db Character.id.NWARIO
    db Character.id.NLUCAS
    db Character.id.NBOWSER
    db Character.id.NWOLF
    db Character.id.NSONIC
    db Character.id.NSHEIK
    db Character.id.NMARINA

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
    db id.WARIO
    db id.DSAMUS
    db id.ELINK
    db id.JSAMUS
    db id.JNESS
    db id.LUCAS
    db id.JLINK
    db id.JFALCON
    db id.JFOX
    db id.JMARIO
    db id.JLUIGI
    db id.JDK
    db id.EPIKA
    db id.JPUFF
    db id.EPUFF
    db id.JKIRBY
    db id.JYOSHI
    db id.JPIKA
    db id.ESAMUS
	db id.BOWSER
	db id.GBOWSER
    db id.PIANO
	db id.WOLF
    db id.CONKER
    db id.MTWO
    db id.MARTH
    db id.SONIC
    db id.SANDBAG
    db id.SSONIC
    db id.SHEIK
    db id.MARINA
    db id.DEDEDE
	// ADD NEW CHARACTERS Here

	// REMIX POLYGONS
    db id.NWARIO
    db id.NLUCAS
    db id.NBOWSER
    db id.NWOLF
    db id.NDRM
    db id.NSONIC
    db id.NSHEIK
    db id.NMARINA

    // @ Description
    // Spawn Position Strings
    spawn_1:; db "Port 1", 0x00
    spawn_2:; db "Port 2", 0x00
    spawn_3:; db "Port 3", 0x00
    spawn_4:; db "Port 4", 0x00
    spawn_5:; db "Custom", 0x00
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
        jal     Character.port_to_struct_   // v0 = address of player struct
        nop
        beqz    v0, _skip_spawn_{player}    // skip if no player struct is returned
        nop
        move    a0, v0                      // a0 = player pointer
        li      a1, entry_spawn_p{player}
        jal     set_custom_spawn_
        nop

        _skip_spawn_{player}:
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

    scope set_percent_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        // v0 = menu item
        // 0x0024(v0) = player (p1 = 0, p4 = 3)

        jal     Character.port_to_struct_   // v0 = address of player struct
        lw      a0, 0x0024(v0)              // a0 = player (p1 = 0, p4 = 3)
        beqz    v0, _skip_percent           // skip if no player struct is returned
        nop
        jal     reset_percent_              // reset percent
        or      a0, v0, r0                  // a0 = player pointer

        lw      v0, 0x000C(sp)              // menu item
        lw      v0, 0x0024(v0)              // v0 = player (p1 = 0, p4 = 3)
        li      a1, struct.table
        sll     v0, v0, 0x0002              // v0 = offset to struct.port_{player}
        addu    a1, a1, v0                  // a1 = address of struct.port_{player}
        lw      a1, 0x0000(a1)              // a1 = struct.port_{player}
        jal     Character.add_percent_
        lw      a1, 0x000C(a1)              // a1 = percent to add

        _skip_percent:
        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    macro tail_px(player) {
        define character(Training.struct.port_{player}.ID)
        define costume(Training.struct.port_{player}.costume)
        define type(Training.struct.port_{player}.type)
        define spawn_id(Training.struct.port_{player}.spawn_id)
        define spawn_func(Training.spawn_func_{player}_)
        define percent(Training.struct.port_{player}.percent)

        Menu.entry("Character:", Menu.type.U8, 0, 0, char_id_to_entry_id - entry_id_to_char_id - 1, OS.NULL, OS.NULL, string_table_char, {character}, entry_costume_p{player})
        entry_costume_p{player}:; Menu.entry("Costume:", Menu.type.U8, 0, 0, 5, OS.NULL, OS.NULL, OS.NULL, {costume}, entry_type_p{player})
        entry_type_p{player}:; Menu.entry("Type:", Menu.type.U8, 2, 0, 2, OS.NULL, OS.NULL, string_table_type, {type}, entry_spawn_p{player})
        entry_spawn_p{player}:; Menu.entry("Spawn:", Menu.type.U8, 0, 0, 4, OS.NULL, OS.NULL, string_table_spawn, {spawn_id}, entry_set_custom_spawn_p{player})
        entry_set_custom_spawn_p{player}:; Menu.entry_title("Set Custom Spawn", {spawn_func}, entry_percent_p{player})
        entry_percent_p{player}:; Menu.entry("Percent:", Menu.type.U16, 0, 0, 999, set_percent_, {player} - 1, OS.NULL, {percent}, entry_percent_toggle_p{player})
        entry_percent_toggle_p{player}:; Menu.entry_bool("Reset Sets Percent:", OS.TRUE, entry_shield_break_mode)
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
    Menu.info(head, 68, 50, 0x17, 0x16, 23, Color.high.RED, Color.high.WHITE, Color.high.WHITE, 0x3F6C0000, 0xE, 12, OS.FALSE, OS.FALSE)

    head:
    entry_port_x:
    Menu.entry("Port:", Menu.type.U8, 1, 1, 4, OS.NULL, OS.NULL, OS.NULL, OS.NULL, tail_p1)

    string_training_mode:; String.insert("Training Mode")


    string_table_music:
    dw       string_training_mode
    dw       Toggles.entry_random_music_bonus + 0x28
    dw       Toggles.entry_random_music_congo_jungle + 0x28
    dw       Toggles.entry_random_music_credits + 0x28
    dw       Toggles.entry_random_music_data + 0x28
    dw       Toggles.entry_random_music_dream_land + 0x28
    dw       Toggles.entry_random_music_duel_zone + 0x28
    dw       Toggles.entry_random_music_final_destination + 0x28
    dw       Toggles.entry_random_music_how_to_play + 0x28
    dw       Toggles.entry_random_music_hyrule_castle + 0x28
    dw       Toggles.entry_random_music_meta_crystal + 0x28
    dw       Toggles.entry_random_music_mushroom_kingdom + 0x28
    dw       Toggles.entry_random_music_peachs_castle + 0x28
    dw       Toggles.entry_random_music_planet_zebes + 0x28
    dw       Toggles.entry_random_music_saffron_city + 0x28
    dw       Toggles.entry_random_music_sector_z + 0x28
    dw       Toggles.entry_random_music_yoshis_island + 0x28
    evaluate total(17)
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            evaluate total({total}+1)
            dw       Toggles.entry_random_music_{n} + 0x28
        }
        evaluate n({n}+1)
    }

    bgm_table:
    db      BGM.special.TRAINING
    db      BGM.menu.BONUS
    db      BGM.stage.CONGO_JUNGLE
    db      BGM.menu.CREDITS
    db      BGM.menu.DATA
    db      BGM.stage.DREAM_LAND
    db      BGM.stage.DUEL_ZONE
    db      BGM.stage.FINAL_DESTINATION
    db      BGM.stage.HOW_TO_PLAY
    db      BGM.stage.HYRULE_CASTLE
    db      BGM.stage.META_CRYSTAL
    db      BGM.stage.MUSHROOM_KINGDOM
    db      BGM.stage.PEACHS_CASTLE
    db      BGM.stage.PLANET_ZEBES
    db      BGM.stage.SAFFRON_CITY
    db      BGM.stage.SECTOR_Z
    db      BGM.stage.YOSHIS_ISLAND
    evaluate n(0x2F)
    while {n} < MIDI.midi_count {
        evaluate can_toggle({MIDI.MIDI_{n}_TOGGLE})
        if ({can_toggle} == OS.TRUE) {
            db       {n}
        }
        evaluate n({n}+1)
    }
    OS.align(4)

    // @ Description
    // Allows A button to play selected music entry
    scope play_bgm_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        // v0 = menu item
        // 0x0004(v0) = index in bgm_table to bgm_id
        li      a0, bgm_table
        lw      a1, 0x0004(v0)              // a1 = index in bgm_table to bgm_id
        addu    a1, a0, a1                  // a1 = address of bgm_id
        lbu     a1, 0x0000(a1)              // a1 = bgm_id

        jal     BGM.play_
        lli     a0, 0x0000

        lw      a0, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    entry_shield_break_mode:; Menu.entry_bool("Shield Break Mode:", OS.FALSE, entry_oos_option)
    entry_oos_option:; Menu.entry("OOS Action:", Menu.type.U8, 0, 0, OOS_MAX, OS.NULL, OS.NULL, string_table_oos_options, OS.NULL, entry_music)
    entry_music:; Menu.entry("Music:", Menu.type.U8, 0, 0, {total} - 1, play_bgm_, OS.NULL, OS.NULL, OS.NULL, OS.NULL)

    // @ Description
    // Holds the initial value of the special model display toggle
    initial_model_display:
    dw      0x00000000

    // @ Description
    // Pointer to the address of the BGM name object
    bgm_name_object:
    dw      0x00000000

    // @ Description
    // Pointer to the address of the BGM string
    bgm_pointer:
    dw      0x00000000

    // @ Description
    // Pointers to the addresses of the Action strings
    p1_action_pointer:; dw 0x00000000
    p2_action_pointer:; dw 0x00000000
    p3_action_pointer:; dw 0x00000000
    p4_action_pointer:; dw 0x00000000

    hold_A_rect_object:
    dw 0

    hold_A_rect_width:
    dw 0

}

} // __TRAINING__
