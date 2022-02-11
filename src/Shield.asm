// Shield.asm
if !{defined __SHIELD__} {
define __SHIELD__()
print "included Shield.asm\n"

// @ Description
// Thise file changes shield colors to match port colors.

include "OS.asm"
include "Global.asm"
include "Color.asm"
include "Character.asm"

scope Shield {

    scope color {
        constant DEFAULT(0x0000)
        constant NA(0x0000)

        constant RED(0x0001)
        constant ORANGE(0x0002)
        constant YELLOW(0x0003)
        constant LIME(0x0004)
        constant GREEN(0x0005)
        constant TURQUOISE(0x0006)
        constant CYAN(0x0007)
        constant AZURE(0x0008)
        constant BLUE(0x0009)
        constant PURPLE(0x000A)
        constant MAGENTA(0x000B)
        constant PINK(0x000C)
        constant BROWN(0x000D)
        constant BLACK(0x000E)
        constant WHITE(0x000F)

        constant VANILLA(0x0010)
        constant COSTUME(0x0011)
    }

    // @ Description
    // This function overwrites the logic to generate a shield color.
    // Vanilla smash has shield colors hardcoded by port: red, green, blue, gray
    // We "fix" this by assigning the same port colors used for series logos:
    // - ffa: red, blue, yellow, green; cpus: gray always
    // - teams: match team color
    // Or we allow selecting a custom shield color.
    scope color_fix_: {
        OS.patch_start(0x0007C8E8, 0x801010E8)
        j       color_fix_
        nop
        _color_fix_return:
        OS.patch_end()

        or      t6, t7, t5                  // original line 1
        // t8 needs to hold rgba32 color by end of function

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // save registers

        lw      t1, 0x0084(a0)              // t1 = shield object special struct
        lw      t0, 0x0004(t1)              // t0 = player object
        lw      t0, 0x0084(t0)              // t0 = player struct
        lw      t1, 0x0018(t1)              // t1 = port shielding
        sll     t2, t1, 0x0002              // t2 = port * 4
        li      t3, state_table             // ~
        addu    t2, t2, t3                  // t2 = state_table + (port * 4)
        lw      t2, 0x0000(t2)              // t2 = shield state
        beqz    t2, _teams_check            // branch if shield state is default(0)
        lli     t3, Shield.color.VANILLA    // t3 = Vanilla Smash
        beql    t2, t3, _return             // if Vanilla, use original color
        or      t8, t6, r0                  // t8 = original shield color
        lli     t3, Shield.color.COSTUME    // t3 = match costume
        bne     t2, t3, _custom             // if a custom color is selected, pull that color
        lw      t3, 0x0008(t0)              // t3 = char_id
        li      t8, Character.costume_shield_color.table
        sll     t2, t3, 0x0002              // t2 = offset for character's costume shield color array
        addu    t8, t8, t2                  // t8 = costume shield color array pointer for character
        lw      t8, 0x0000(t8)              // t8 = costume shield color array

        lli     t3, Character.id.SONIC      // t2 = id.SONIC
        beq     t2, t3, _get_shield_color   // if not Sonic, skip
        lbu     t3, 0x0010(t0)              // t3 = costume_id

        li      t2, Sonic.classic_table     // t2 = classic_table
        addu    t2, t2, t1                  // t2 = classic_table + port
        lbu     t2, 0x0000(t2)              // t2 = px is_classic
        bnezl   t2, _get_shield_color       // if classic Sonic, then adjust costume_id
        addiu   t3, t3, 0x0006              // t3 = adjusted costume_id

        _get_shield_color:
        addu    t8, t8, t3                  // t8 = address of shield color index
        lbu     t2, 0x0000(t8)              // t2 = shield color index

        _custom:
        // t2 is shield state
        sll     t2, t2, 0x2                 // t2 = shield state * 4
        li      t8, table_custom            // ~
        addu    t8, t8, t2                  // t8 = table_custom + (shield state * 4)
        b       _return                     // branch to end
        lw      t8, 0x0000(t8)              // t8 = shield color

        _teams_check:
        li      t2, Global.match_info
        lw      t2, 0x0000(t2)              // t2 = match info struct
        addiu   t3, t2, 0x0002              // t3 = address of teams byte, if vs
        li      t2, Global.vs.teams         // t2 = pointer to teams byte
        bne     t2, t3, _cpu                // if not vs, skip
        lbu     t2, 0x0000(t2)              // t2 = teams
        beqz    t2, _cpu                    // if (!teams), skip
        nop
        lbu     t1, 0x000C(t0)              // t1 = team

        // team 0 = red, team 1 = blue, team 2 green
        // green is in not in table[2], it's in table[3]
        // 0 = 0b00, 1 = 0b01, 2 = 0b10
        // *shift team right 1*
        // (0 >> 1) = 0b00, (1 >> 1) = 0b00, (2 >> 1) = 0b01
        // so t1 + (t1 >> 1) = team color

        srl     t2, t1, 0x0001              // t2 = (t1 >> 1)
        add     t1, t1, t2                  // t2 = correct team color
        b       _human_or_team              // ~
        nop

        _cpu:
        lbu     t0, 0x0023(t0)              // t6 = type (player = 0, cpu = 1)
        bne     t0, r0, _return             // branch to human/cpu
        ori     t8, r0, 0x00C0              // cpu shield = 0x000000C0

        _human_or_team:
        sll     t1, t1, 0x0002              // ~
        li      t8, table_default           // ~
        add     t8, t8, t1                  // ~
        lw      t8, 0x0000(t8)              // t8 = table_default[player_or_team]

        _return:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space
        j       _color_fix_return           // return
        ori     t8, t8, 0x00C0              // set alpha channel

        table_default:
        dw (0xFFFFFF00 & Color.high.RED)    // p1
        dw (0xFFFFFF00 & Color.high.BLUE)   // p2
        dw (0xFFFFFF00 & Color.high.YELLOW) // p3
        dw (0xFFFFFF00 & Color.high.GREEN)  // p4

        table_custom:
        dw 0                                // Default
        dw 0xFF000000                       // Red
        dw 0xFF800000                       // Orange
        dw 0xFFFF0000                       // Yellow
        dw 0x80FF0000                       // Lime (Chartreuse)
        dw 0x00FF0000                       // Green
        dw 0x00FF8000                       // Turquoise (Spring Green)
        dw 0x00FFFF00                       // Cyan
        dw 0x0080FF00                       // Azure
        dw 0x0000FF00                       // Blue
        dw 0x8000FF00                       // Purple (Violet)
        dw 0xFF00FF00                       // Magenta
        dw 0xFF008000                       // Pink (Rose)
        dw 0xA8402000                       // Brown
        dw 0x00000000                       // Black
        dw 0xA0A0A000                       // White
    }

    // @ Description
    // This holds each port's custom shield index
    state_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4

    // @ Description
    // This allows us to apply custom shield colors to Yoshi's egg shield
    scope alter_yoshi_egg_color_: {
        // Runs after shield object created
        OS.patch_start(0x7CBA8, 0x801013A8)
        jal     alter_yoshi_egg_color_._shield
        nop
        OS.patch_end()
        // Runs after shield object created for rolling
        OS.patch_start(0x7E98C, 0x8010318C)
        jal     alter_yoshi_egg_color_._shield_roll
        lw      a2, 0x0024(sp)              // original line 1 - a2 = player object
        OS.patch_end()
        // Runs after egg projectile created
        OS.patch_start(0xD9534, 0x8015EAF4)
        j       alter_yoshi_egg_color_._eggthrow
        lw      ra, 0x001C(sp)              // original line 2
        _return:
        OS.patch_end()
        // Runs before egg lay creates an egg
        OS.patch_start(0xC7AC0, 0x8014D080)
        jal     alter_yoshi_egg_color_._egglay_setup
        sw      t9, 0x09F0(s0)              // original line 2
        OS.patch_end()
        // Runs after egg lay successfully creates an egg
        OS.patch_start(0xC73C4, 0x8014C984)
        jal     alter_yoshi_egg_color_._egglay
        nop
        OS.patch_end()
        // Runs after entry animation successfully creates an egg
        OS.patch_start(0x7E75C, 0x80102F5C)
        jal     alter_yoshi_egg_color_._entry
        lw      v1, 0x0074(a0)              // original line 2 - v1 = egg object top joint
        OS.patch_end()

        _shield:
        // a0 = egg shield object
        // a2 = player struct

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~

        lw      a0, 0x0074(a0)              // a0 = RAM address of joint struct
        lw      v0, 0x0050(a0)              // v0 = egg shield display list
        lui     a1, 0xDE00                  // a1 = DE000000 = branch display list
        sw      a1, 0x0050(v0)              // replace load palette with branch
        lui     a1, 0x0E00                  // a1 = 0E000000 = what SSB normally does for image parts
        sw      a1, 0x0054(v0)              // set branch address

        li      a1, model_part_image        // a1 = RAM address of model part image
        jal     Render.MODEL_PART_IMAGE_INIT_ // v0 = RAM address of model part image struct
        addiu   sp, sp, -0x0030             // allocate stack space for MODEL_PART_IMAGE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a2, 0x000C(sp)              // a2 = player struct
        lbu     v1, 0x000D(a2)              // v1 = port
        sll     v1, v1, 0x0002              // v1 = port * 4
        li      a0, state_table             // ~
        addu    a0, a0, v1                  // a0 = state_table + (port * 4)
        lw      a0, 0x0000(a0)              // a0 = shield state

        lli     t7, Shield.color.VANILLA    // t7 = Vanilla Smash
        beql    a0, t7, _set_palette_shield // if Vanilla, use original color
        lli     a0, Shield.color.DEFAULT    // a0 = original color
        lli     t7, Shield.color.COSTUME    // t7 = match costume
        bne     a0, t7, _set_palette_shield // if a custom color is selected, pull that color
        lw      t7, 0x0008(a2)              // t7 = char_id
        li      v1, Character.costume_shield_color.table
        sll     t7, t7, 0x0002              // t7 = offset for character's costume shield color array pointer
        addu    v1, v1, t7                  // v1 = costume shield color array pointer for character
        lw      v1, 0x0000(v1)              // v1 = custume shield color array
        lbu     t7, 0x0010(a2)              // t7 = costume_id
        addu    v1, v1, t7                  // v1 = address of shield color index
        lbu     a0, 0x0000(v1)              // a0 = shield color index

        _set_palette_shield:
        mtc1    a0, f0                      // f0 = shield state
        cvt.s.w f0, f0                      // f0 = index of palette
        swc1    f0, 0x0088(v0)              // update palette

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lw      v1, 0x0084(a0)              // original line 1
        jr      ra
        lw      t7, 0x0028(sp)              // original line 2

        _shield_roll:
        // a2 = player struct
        lw      v0, 0x001C(sp)              // original line 2 - v0 = egg shield object

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a2, 0x0008(sp)              // ~

        lw      a0, 0x0074(v0)              // a0 = RAM address of joint struct
        lw      v0, 0x0050(a0)              // v0 = egg shield display list
        lui     a1, 0xDE00                  // a1 = DE000000 = branch display list
        sw      a1, 0x0050(v0)              // replace load palette with branch
        lui     a1, 0x0E00                  // a1 = 0E000000 = what SSB normally does for image parts
        sw      a1, 0x0054(v0)              // set branch address

        li      a1, model_part_image        // a1 = RAM address of model part image
        jal     Render.MODEL_PART_IMAGE_INIT_ // v0 = RAM address of model part image struct
        addiu   sp, sp, -0x0030             // allocate stack space for MODEL_PART_IMAGE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a2, 0x0008(sp)              // a2 = player struct
        lbu     v1, 0x000D(a2)              // v1 = port
        sll     v1, v1, 0x0002              // v1 = port * 4
        li      a0, state_table             // ~
        addu    a0, a0, v1                  // a0 = state_table + (port * 4)
        lw      a0, 0x0000(a0)              // a0 = shield state

        lli     at, Shield.color.VANILLA    // at = Vanilla Smash
        beql    a0, at, _set_palette_roll   // if Vanilla, use original color
        lli     a0, Shield.color.DEFAULT    // a0 = original color
        lli     at, Shield.color.COSTUME    // at = match costume
        bne     a0, at, _set_palette_roll   // if a custom color is selected, pull that color
        lw      at, 0x0008(a2)              // at = char_id
        li      v1, Character.costume_shield_color.table
        sll     at, at, 0x0002              // at = offset for character's costume shield color array pointer
        addu    v1, v1, at                  // v1 = costume shield color array pointer for character
        lw      v1, 0x0000(v1)              // v1 = costume shield color array
        lbu     at, 0x0010(a2)              // at = costume_id
        addu    v1, v1, at                  // v1 = address of shield color index
        lbu     a0, 0x0000(v1)              // a0 = shield color index

        _set_palette_roll:
        mtc1    a0, f0                      // f0 = shield state
        cvt.s.w f0, f0                      // f0 = index of palette
        swc1    f0, 0x0088(v0)              // update palette

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        lw      v0, 0x001C(sp)              // original line 2 - v0 = egg shield object

        _eggthrow:
        // v0 = egg object
        // s0 = player struct

        sw      v0, 0x0B18(s0)              // original line 1

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lw      a0, 0x0074(v0)              // a0 = RAM address of joint struct
        lw      v0, 0x0050(a0)              // v0 = egg shield display list
        lui     a1, 0xDE00                  // a1 = DE000000 = branch display list
        sw      a1, 0x0050(v0)              // replace load palette with branch
        lui     a1, 0x0E00                  // a1 = 0E000000 = what SSB normally does for image parts
        sw      a1, 0x0054(v0)              // set branch address

        li      a1, model_part_image        // a1 = RAM address of model part image
        jal     Render.MODEL_PART_IMAGE_INIT_ // v0 = RAM address of model part image struct
        addiu   sp, sp, -0x0030             // allocate stack space for MODEL_PART_IMAGE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lbu     a1, 0x000D(s0)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = port * 4
        li      a0, state_table             // ~
        addu    a0, a0, a1                  // a0 = state_table + (port * 4)
        lw      a0, 0x0000(a0)              // a0 = shield state

        lli     at, Shield.color.VANILLA    // at = Vanilla Smash
        beql    a0, at, _set_palette_eggthrow // if Vanilla, use original color
        lli     a0, Shield.color.DEFAULT    // a0 = original color
        lli     at, Shield.color.COSTUME    // at = match costume
        bne     a0, at, _set_palette_eggthrow // if a custom color is selected, pull that color
        lw      at, 0x0008(s0)              // at = char_id
        li      a1, Character.costume_shield_color.table
        sll     at, at, 0x0002              // at = offset for character's costume shield color array pointer
        addu    a1, a1, at                  // a1 = costume shield color array pointer for character
        lw      a1, 0x0000(a1)              // a1 = costume shield color array
        lbu     at, 0x0010(s0)              // at = costume_id
        addu    a1, a1, at                  // a1 = address of shield color index
        lbu     a0, 0x0000(a1)              // a0 = shield color index

        _set_palette_eggthrow:
        mtc1    a0, f0                      // f0 = shield state
        cvt.s.w f0, f0                      // f0 = index of palette
        swc1    f0, 0x0088(v0)              // update palette

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return
        nop

        _egglay_setup:
        // s0 = captured player struct

        lw      t1, 0x0844(s0)              // t1 = player.entity_captured_by
        sw      t1, 0x0028(sp)              // save into unused stack space
        jr      ra
        sw      r0, 0x0844(s0)              // original line 1

        _egglay:
        // v0 = egg object
        // v1 = captured player struct

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      v1, 0x0008(sp)              // ~

        lw      a0, 0x0074(v0)              // a0 = RAM address of joint struct
        lw      a0, 0x0010(a0)              // a0 = 2nd joint
        lw      a0, 0x0010(a0)              // a0 = 3rd joint
        lw      v0, 0x0050(a0)              // v0 = egg shield display list
        lui     a1, 0xDE00                  // a1 = DE000000 = branch display list
        sw      a1, 0x0058(v0)              // replace load palette with branch
        lui     a1, 0x0E00                  // a1 = 0E000000 = what SSB normally does for image parts
        sw      a1, 0x005C(v0)              // set branch address

        li      a1, model_part_image        // a1 = RAM address of model part image
        jal     Render.MODEL_PART_IMAGE_INIT_ // v0 = RAM address of model part image struct
        addiu   sp, sp, -0x0030             // allocate stack space for MODEL_PART_IMAGE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a0, 0x0058(sp)              // a0 = capturer player object
        lw      t9, 0x0084(a0)              // t9 = player struct
        lbu     v1, 0x000D(t9)              // v1 = port
        sll     v1, v1, 0x0002              // v1 = port * 4
        li      a0, state_table             // ~
        addu    a0, a0, v1                  // a0 = state_table + (port * 4)
        lw      a0, 0x0000(a0)              // a0 = shield state

        lli     t8, Shield.color.VANILLA    // t8 = Vanilla Smash
        beql    a0, t8, _set_palette_egglay // if Vanilla, use original color
        lli     a0, Shield.color.DEFAULT    // a0 = original color
        lli     t8, Shield.color.COSTUME    // t8 = match costume
        bne     a0, t8, _set_palette_egglay // if a custom color is selected, pull that color
        lw      t8, 0x0008(t9)              // t8 = char_id
        li      v1, Character.costume_shield_color.table
        sll     t8, t8, 0x0002              // t8 = offset for character's costume shield color array pointer
        addu    v1, v1, t8                  // v1 = costume shield color array pointer for character
        lw      v1, 0x0000(v1)              // v1 = costume shield color array
        lbu     t8, 0x0010(t9)              // t8 = costume_id
        addu    v1, v1, t8                  // v1 = address of shield color index
        lbu     a0, 0x0000(v1)              // a0 = shield color index

        _set_palette_egglay:
        mtc1    a0, f0                      // f0 = shield state
        cvt.s.w f0, f0                      // f0 = index of palette
        swc1    f0, 0x0088(v0)              // update palette

        lw      ra, 0x0004(sp)              // restore registers
        lw      v1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lbu     t8, 0x018F(v1)              // original line 1
        jr      ra
        ori     t9, t8, 0x0010              // original line 2

        _entry:
        // v1 = egg object top joint
        // s0 = player struct

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      v1, 0x000C(sp)              // ~

        lw      a0, 0x0010(v1)              // a0 = 2nd joint
        lw      v0, 0x0050(a0)              // v0 = egg display list
        lui     a1, 0xDE00                  // a1 = DE000000 = branch display list
        sw      a1, 0x0048(v0)              // replace load palette with branch
        li      a1, 0x0E000008              // a1 = 0E000008 = what SSB normally does for image parts (2nd since original has one)
        sw      a1, 0x004C(v0)              // set branch address

        lw      v0, 0x0080(a0)              // v0 = egg model image part
        li      a1, table_entry_palettes
        sw      a1, 0x0034(v0)              // set palette array
        lli     a1, 0x00A5                  // a1 = 0x00A1 (default value) & 0x0004 (palette)
        sh      a1, 0x0038(v0)              // update flags to include palette

        lbu     v1, 0x000D(s0)              // v1 = port
        sll     v1, v1, 0x0002              // v1 = port * 4
        li      a0, state_table             // ~
        addu    a0, a0, v1                  // a0 = state_table + (port * 4)
        lw      a0, 0x0000(a0)              // a0 = shield state

        lli     t6, Shield.color.VANILLA    // t6 = Vanilla Smash
        beql    a0, t6, _set_palette_entry  // if Vanilla, use original color
        lli     a0, Shield.color.DEFAULT    // a0 = original color
        lli     t6, Shield.color.COSTUME    // t6 = mt6ch costume
        bne     a0, t6, _set_palette_entry  // if a custom color is selected, pull tht6 color
        lw      t6, 0x0008(s0)              // t6 = char_id
        li      a1, Character.costume_shield_color.table
        sll     t6, t6, 0x0002              // t6 = offset for character's costume shield color array pointer
        addu    a1, a1, t6                  // a1 = costume shield color array pointer for character
        lw      a1, 0x0000(a1)              // a1 = costume shield color array
        lbu     t6, 0x0010(s0)              // t6 = costume_id
        addu    a1, a1, t6                  // a1 = address of shield color index
        lbu     a0, 0x0000(a1)              // a0 = shield color index

        _set_palette_entry:
        mtc1    a0, f0                      // f0 = shield state
        cvt.s.w f0, f0                      // f0 = index of palette
        swc1    f0, 0x0088(v0)              // update palette

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      v1, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        lw      t6, 0x0018(sp)              // original line 1

        // Most of these values aren't important - just the palette array pointer and flag
        model_part_image:
        dh 0x0000                           // ?
        dh 0x0202                           // Image 1 Type and Bitsize
        dw 0                                // Image Array Pointer
        // Tile 0
        dh 0x0020                           // Stretch
        dh 0x0000                           // Shared Offset
        dh 0x0020, 0x0020                   // Tile Width, Tile Height
        dw 0x00000000                       // Tile XShift
        dw 0x00000000                       // Tile YShift
        dw 0x00000000                       // ? Tile ZShift?
        // Tile
        dw 0x3F800000                       // Tile XScale
        dw 0x3F800000                       // Tile YScale
        dw 0x00000000                       // Halve?
        dw 0x3F800000                       // ?
        dw table_palettes                   // Palette Array Pointer
        dh 0x0004                           // Flags: 0x4 = palette array
        dh 0x0200                           // Image 2 Type and Bitsize
        // Tile 1
        dh 0x0010, 0x0020                   // Width, Height
        dh 0x0020, 0x0020                   // Tile Width, Tile Height
        dw 0x00000000                       // Tile XShift
        dw 0x00000000                       // Tile YShift
        dw 0x00000000                       // ? Tile ZShift?
        dw 0x00000000                       // ?

        dw 0x00002005                       // Unused Flag?
        dw 0xFFFFFFFF                       // Prim Color
        dw 0x00000000                       // LOD Fraction
        dw 0x000000FF                       // Env Color
        dw 0x00000000                       // Blend Color
        dw 0xFFFFFF00                       // Light Color
        dw 0x80808000                       // Shadow Color
        dw 0x00000000                       // unused
        dw 0x00000000                       // unused
        dw 0x00000000                       // unused
        dw 0x00000000                       // unused

        table_palettes:
        dw palette_default
        dw palette_red
        dw palette_orange
        dw palette_yellow
        dw palette_lime
        dw palette_green
        dw palette_turquoise
        dw palette_cyan
        dw palette_azure
        dw palette_blue
        dw palette_purple
        dw palette_magenta
        dw palette_pink
        dw palette_brown
        dw palette_black
        dw palette_white

        table_entry_palettes:
        dw palette_entry_default
        dw palette_entry_red
        dw palette_entry_orange
        dw palette_entry_yellow
        dw palette_entry_lime
        dw palette_entry_green
        dw palette_entry_turquoise
        dw palette_entry_cyan
        dw palette_entry_azure
        dw palette_entry_blue
        dw palette_entry_purple
        dw palette_entry_magenta
        dw palette_entry_pink
        dw palette_entry_brown
        dw palette_entry_black
        dw palette_entry_white

        // Palettes for shield, egg throw and egg lay
        palette_default:;   dh 0x0000, 0x2B0B, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD6F5, 0x3E8F, 0x6515, 0x8DA1, 0xC66F, 0x344D, 0xAEE5, 0x66D7, 0x86DD, 0x8CA3 // Default
        palette_red:;       dh 0x0000, 0x614B, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDEB5, 0xD1CF, 0xA299, 0xB423, 0xCDF1, 0x898D, 0xDCAB, 0xDAD9, 0xDBA1, 0x9463 // Red
        palette_orange:;    dh 0x0000, 0x6209, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDEB3, 0xDC4B, 0xA353, 0xB49F, 0xCDED, 0x8B0B, 0xDCE3, 0xE493, 0xDC9B, 0x9461 // Orange
        palette_yellow:;    dh 0x0000, 0x6309, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDEF3, 0xDF09, 0xAC91, 0xB55F, 0xCE2D, 0x9489, 0xE621, 0xE6D3, 0xE699, 0x94A1 // Yellow
        palette_lime:;      dh 0x0000, 0x4B47, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD6F3, 0x9747, 0x9551, 0xADDD, 0xCE6D, 0x64C7, 0xDF21, 0xB78F, 0xC757, 0x8CA1 // Lime (Chartreuse)
        palette_green:;     dh 0x0000, 0x2B0B, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD6F5, 0x3E8F, 0x6515, 0x8DA1, 0xC66F, 0x344D, 0xAEE5, 0x66D7, 0x86DD, 0x8CA3 // Green
        palette_turquoise:; dh 0x0000, 0x22D5, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD6F5, 0x3669, 0x551F, 0x7D67, 0xBE6F, 0x345D, 0x8EAB, 0x56AB, 0x76EB, 0x8CA3 // Turquoise (Spring Green)
        palette_cyan:;      dh 0x0000, 0x22D9, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xCEF7, 0x2679, 0x4569, 0x7DAD, 0xB671, 0x2425, 0x8733, 0x4EF9, 0x6737, 0x84A5 // Cyan
        palette_azure:;     dh 0x0000, 0x2269, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xCE77, 0x957F, 0x742D, 0x85B5, 0xC675, 0x3B6F, 0xD6FD, 0xAE7F, 0xC73F, 0x8425 // Azure
        palette_blue:;      dh 0x0000, 0x3119, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD677, 0x5177, 0x4A6B, 0x7BED, 0xB5F3, 0x3925, 0x8CB7, 0x6279, 0x6B39, 0x8C25 // Blue
        palette_purple:;    dh 0x0000, 0x50DB, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD677, 0xA8BD, 0x71ED, 0x93AF, 0xBDB3, 0x70E7, 0xA3FB, 0xA9FD, 0xA2FB, 0x8C25 // Purple (Violet)
        palette_magenta:;   dh 0x0000, 0x68D7, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDE77, 0xF0B3, 0xB1ED, 0xBBAF, 0xC5B3, 0x98E3, 0xD3FB, 0xF9B9, 0xF2BD, 0x9425 // Magenta
        palette_pink:;      dh 0x0000, 0x7997, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDE75, 0xFB6D, 0xB1E5, 0xBBAB, 0xCDB3, 0xC263, 0xF4BB, 0xFC33, 0xF4B5, 0x9423 // Pink (Rose)
        palette_brown:;     dh 0x0000, 0x41CB, 0xAD6B, 0xB569, 0xE739, 0x8421, 0xDEB3, 0x8B93, 0x72D5, 0x8BDD, 0xCDED, 0x5A4F, 0xA461, 0x9BD9, 0x9C1D, 0x9461 // Brown
        palette_black:;     dh 0x0000, 0x294B, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xDEF7, 0x6319, 0x4A53, 0x8421, 0xBDEF, 0x4211, 0xB5AD, 0x6319, 0x7BDF, 0x94A5 // Black
        palette_white:;     dh 0x0000, 0x529B, 0xAD6B, 0x6319, 0xE739, 0x8421, 0xD677, 0xBE39, 0x7C29, 0x9D2F, 0xD677, 0x7BE5, 0xD6F9, 0xCE79, 0xD6B9, 0x8C25 // White

        // Palettes for entry animation
        palette_entry_default:;   dh 0x7B9A, 0x2ACB, 0xBDEF, 0x5AD7, 0x5ED5, 0xF7BD, 0x2689, 0xDF37, 0x8C63, 0x8F21, 0x2C8B, 0xB7AB, 0x3E8D, 0x76DB, 0x2B8B, 0x6BD9 // Default
        palette_entry_red:;       dh 0x7B9A, 0x594B, 0xBDEF, 0x5AD7, 0xDA99, 0xF7BD, 0xD10B, 0xE6F7, 0x8C63, 0xE425, 0x914D, 0xF56D, 0xD191, 0xDB5F, 0x714B, 0x7B1B // Red
        palette_entry_orange:;    dh 0x7B9A, 0x5A0B, 0xBDEF, 0x5AD7, 0xDC95, 0xF7BD, 0xD409, 0xE6F7, 0x8C63, 0xE5A1, 0x930B, 0xF66B, 0xD40D, 0xDD1B, 0x728B, 0x7B19 // Orange
        palette_entry_yellow:;    dh 0x7B9A, 0x6307, 0xBDEF, 0x5AD7, 0xF70D, 0xF7BD, 0xEF81, 0xE735, 0x8C63, 0xF71B, 0xA505, 0xFFA7, 0xEF05, 0xEF15, 0x7BC7, 0x7B97 // Yellow
        palette_entry_lime:;      dh 0x7B9A, 0x4B47, 0xBDEF, 0x5AD7, 0x529B, 0xF7BD, 0x9747, 0xDF37, 0x8C63, 0xDF2F, 0x64C7, 0xCFAB, 0xB78F, 0xCF29, 0x5C09, 0x73D9 // Lime (Chartreuse)
        palette_entry_green:;     dh 0x7B9A, 0x2ACB, 0xBDEF, 0x5AD7, 0x5ED5, 0xF7BD, 0x2689, 0xDF37, 0x8C63, 0x8F21, 0x2C8B, 0xB7AB, 0x3E8D, 0x76DB, 0x2B8B, 0x6BD9 // Green
        palette_entry_turquoise:; dh 0x7B9A, 0x2AD3, 0xBDEF, 0x5AD7, 0x56EB, 0xF7BD, 0x26A7, 0xDF37, 0x8C63, 0x872F, 0x2C9D, 0xAFB5, 0x36A7, 0x6EED, 0x2B97, 0x63DB // Turquoise (Spring Green)
        palette_entry_cyan:;      dh 0x7B9A, 0x22D9, 0xBDEF, 0x5AD7, 0xA739, 0xF7BD, 0x2679, 0xDF39, 0x8C63, 0xAF37, 0x2425, 0xCFBD, 0x4EF9, 0xAEF5, 0x235D, 0x63DD // Cyan
        palette_entry_azure:;     dh 0x7B9A, 0x2269, 0xBDEF, 0x5AD7, 0xC73F, 0xF7BD, 0x957F, 0xDEF9, 0x8C63, 0xC73F, 0x3B6F, 0xDEFB, 0xAE7F, 0xCEBB, 0x32E9, 0x8425 // Azure
        palette_entry_blue:;      dh 0x7B9A, 0x3119, 0xBDEF, 0x5AD7, 0x6B39, 0xF7BD, 0x5177, 0xD677, 0x8C63, 0x8CB7, 0x3925, 0xB5F3, 0x6279, 0xA57B, 0x3921, 0x8421 // Blue
        palette_entry_purple:;    dh 0x7B9A, 0x4957, 0xBDEF, 0x5AD7, 0xA2B7, 0xF7BD, 0x9935, 0xDEF9, 0x8C63, 0xBC39, 0x7165, 0xD57D, 0x99B5, 0xAB77, 0x595D, 0x6B1F // Purple (Violet)
        palette_entry_magenta:;   dh 0x7B9A, 0x68D7, 0xBDEF, 0x5AD7, 0xDCBB, 0xF7BD, 0xF0B3, 0xEEBB, 0x8C63, 0xE6F9, 0x98E3, 0xDEB9, 0xF9B9, 0xDD79, 0x80DB, 0x731F // Magenta
        palette_entry_pink:;      dh 0x7B9A, 0x7997, 0xBDEF, 0x5AD7, 0xFCB3, 0xF7BD, 0xFBED, 0xDE75, 0x8C63, 0xFDB7, 0xC263, 0xFE79, 0xFC2F, 0xFD33, 0xA21D, 0x8421 // Pink (Rose)
        palette_entry_brown:;     dh 0x7B9A, 0x41CB, 0xBDEF, 0x5AD7, 0x9C1D, 0xF7BD, 0x8B93, 0xE6F7, 0x8C63, 0xCDED, 0x5A4F, 0xDEB3, 0x9BD9, 0xCDED, 0x520D, 0x739D // Brown
        palette_entry_black:;     dh 0x7B9A, 0x294B, 0xBDEF, 0x5AD7, 0x7BDF, 0xF7BD, 0x6319, 0xE739, 0x8C63, 0xB5AD, 0x4211, 0xD6B5, 0x6319, 0x6B5B, 0x318D, 0x7BDF // Black
        palette_entry_white:;     dh 0x7B9A, 0x529B, 0xBDEF, 0x5AD7, 0xD6F9, 0xF7BD, 0xBE39, 0xDF37, 0x8C63, 0xD6B9, 0x7BE5, 0xDEFB, 0xD6BB, 0xDEFB, 0x631D, 0x8421 // White
    }
}

} // __SHIELD__
