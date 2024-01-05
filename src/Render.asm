// Render.asm
if !{defined __RENDER__} {
define __RENDER__()
print "included Render.asm\n"

// @ Description
// This file is used for loading default tournament settings on boot.

include "OS.asm"
include "Global.asm"

scope Render {
    // @ Description
    // The routine that creates objects
    // @ Arguments
    // a0 - Global Object ID
    // a1 - routine to run every frame
    // a2 - group: linked list to append (starting at 0x800466F0)
    // a3 - unknown - usually 0x80000000
    // @ Returns
    // v0 - address of created object
    constant CREATE_OBJECT_(0x80009968)

    // @ Description
    // The routine that initializes objects for display
    // @ Arguments
    // a0 - object address (v0 from 0x80009968)
    // a1 - RAM address of ASM for creating the display list
    // a2 - room: controls whether it renders on top or below other graphics depending on the room's layer positioning
    // a3 - order - higher than 0x8000 will make it render before most objects, lower will make it render after... usually 0x8000
    // 0x0010(sp) - unknown - usually 0xFFFFFFFF
    constant DISPLAY_INIT_(0x80009DF4)

    // @ Description
    // The routine that initializes textures for display
    // a0 - object address (v0 from 0x80009968)
    // a1 - RAM address of image footer data to copy
    // @ Returns
    // v0 - address of image footer data created
    constant TEXTURE_INIT_(0x800CCFDC)

    // @ Description
    // The routine used to render textures - passed as a1 to 0x80009DF4
    constant TEXTURE_RENDER_(0x800CCF00)

    // @ Description
    // The routine that initializes stage objects for display based off joints
    // a0 - object address (v0 from 0x80009968)
    // a1 - RAM address of joint array
    // a2 - ?
    // a3 - some sort of index for how to render the joint
    // 0x0010(sp) - ?
    // 0x0014(sp) - ?
    // @ Returns
    // v0 - address of object joint data created
    constant STAGE_OBJECT_INIT_(0x8000F590)

    // @ Description
    // The routine used to render stage objects - passed as a1 to 0x80009DF4
    constant STAGE_OBJECT_RENDER_(0x800CB4B0)

    // @ Description
    // The routine that adds a model part image to a model part
    // a0 - model part
    // a1 - model part image
    // @ Returns
    // v0 - address of model part image struct created
    constant MODEL_PART_IMAGE_INIT_(0x800090DC)

    // @ Description
    // The routine that adds associates a routine with an object
    // a0 - object
    // a1 - routine
    // a2 - ? 1
    // a3 - group/order (0-5)
    constant REGISTER_OBJECT_ROUTINE_(0x80008188)

    // @ Description
    // No operation - used when no routine is necessary
    constant NOOP(0x00000000)

    // @ Description
    // The routine that destroys objects
    // **NOTE**: objects must be destroyed in the order they were created on the same frame.
    // a0 - object address (v0 from 0x80009968)
    constant DESTROY_OBJECT_(0x80009A84)

    // @ Description
    // Converts RGBA from 32 to 16 bits, doubled.
    // @ Arguments
    // a0 - 32 bit RBGA [rrrrrrrr bbbbbbbb gggggggg aaaaaaaa]
    // @ Returns
    // v1 - 16 bit RGBA [rrrrrbbb bbggggga rrrrrbbb bbggggga]
    constant CONVERT_RGBA_16_(0x80006D70)

    // @ Description
    // The address for pointers to the first object in each room starts here
    constant ROOM_TABLE(0x80046800)

    // @ Description
    // The address for pointers to the first object in each group starts here
    constant GROUP_TABLE(0x800466F0)

    // @ Description
    // Constants used for aligning strings
    scope alignment: {
        constant LEFT(0x0000)
        constant RIGHT(0x0001)
        constant CENTER(0x0002)
    }

    // @ Description
    // Constants used for defining strings
    // Bit logic: [p s n r]
    // r - pointer? 1 if yes, 0 if no
    // n - number? 1 if yes, 0 if no
    // s - signed? 1 if yes, 0 if no
    // p - show + prefix? 1 if yes, 0 if on
    scope string_type: {
        // text
        constant TEXT(0b0000)
        constant TEXT_POINTER(0b0001)
        // unsigned
        constant NUMBER(0b0010)
        constant NUMBER_POINTER(0b0011)
        // signed (no plus sign)
        constant NUMBER_SIGNED(0b0110)
        constant NUMBER_SIGNED_POINTER(0b0111)
        // signed (always plus sign)
        constant NUMBER_SIGNED_WITH_PREFIX(0b1110)
        constant NUMBER_SIGNED_WITH_PREFIX_POINTER(0b1111)
    }

    // @ Description
    // Useful offset for file C5 to help with rendering button images
    scope file_c5_offsets: {
        constant A(0x0958)
        constant B(0x0A88)
        constant L(0x18C8)
        constant R(0x0CF8)
        constant Z(0x0BD8)
        constant PLUS(0x04D8)
        constant L_THIN(0x1B10)
    }

    constant FONTSIZE_DEFAULT(0x3F800000)

    // @ Description
    // Pointer to font file if loaded in memory
    font_file_address:
    dw 0x00000000

    // @ Description
    // Pointer to character offsets for font file
    character_offsets_address:
    dw 0x00000000

    // @ Description
    // Holds default font size for loaded font
    default_font_size:
    dw 0x00000000

    // @ Description
    // Pointers to arbitrary file loaded in memory depending on screen
    file_pointer_1:; dw 0x00000000
    file_pointer_2:; dw 0x00000000
    file_pointer_3:; dw 0x00000000
    file_pointer_4:; dw 0x00000000

    // @ Description
    // Hold the display order values so that we can control this without making it be an argument,
    // since 99% of the time we want it to stay 0x80000000.
    // We will lui this value.
    constant DISPLAY_ORDER_DEFAULT(0x8000)
    display_order_room:; dh DISPLAY_ORDER_DEFAULT; dh 0x0
    display_order_group:; dh DISPLAY_ORDER_DEFAULT; dh 0x0

    // @ Description
    // Contains offsets to characters in the font file arranged in ASCII order.
    // First word contains dimension details
    // Second word contains the offset in the font file
    character_offsets_custom:
    constant CHARACTER_OFFSETS_CUSTOM_ORIGIN(origin())
    // skip characters 0x0 - 0x19
    dw 0x03000000; dw 0x00000000              // space
    define n(0)
    define offset(0x160)
    define first(0x118)
    // first we'll just create all slots, then we'll go back and update widths
    while {n} < 96 {
        evaluate x({first} + ({offset} * {n}))
        dw 0x070E0000
        dw {x}
        evaluate n({n}+1)
    }
    // now fix widths
    pushvar origin, base
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('!' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('\d' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('&' - 0x20)); db 0x09
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('\s' - 0x20)); db 0x02
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('(' - 0x20)); db 0x03
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * (')' - 0x20)); db 0x03
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('*' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * (',' - 0x20)); db 0x02
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('-' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('.' - 0x20)); db 0x02
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * (':' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('\b' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('?' - 0x20)); db 0x06
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('@' - 0x20)); db 0x0B
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('A' - 0x20)); db 0x09
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('C' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('D' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('G' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('H' - 0x20)); db 0x09
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('I' - 0x20)); db 0x05
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('J' - 0x20)); db 0x06
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('K' - 0x20)); db 0x09
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('L' - 0x20)); db 0x06
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('M' - 0x20)); db 0x0B
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('N' - 0x20)); db 0x0A
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('O' - 0x20)); db 0x0A
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('P' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('Q' - 0x20)); db 0x0A
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('U' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('V' - 0x20)); db 0x09
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('X' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('W' - 0x20)); db 0x0B
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('Z' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('[' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * (']' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('_' - 0x20)); db 0x0A
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('`' - 0x20)); db 0x02
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('c' - 0x20)); db 0x06
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('d' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('f' - 0x20)); db 0x05
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('h' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('i' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('j' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('k' - 0x20)); db 0x06
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('l' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('m' - 0x20)); db 0x0B
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('p' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('q' - 0x20)); db 0x08
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('r' - 0x20)); db 0x05
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('s' - 0x20)); db 0x05
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('t' - 0x20)); db 0x05
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('w' - 0x20)); db 0x0A
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('{' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('|' - 0x20)); db 0x02
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('}' - 0x20)); db 0x04
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('~' + 1 - 0x20)); db 0x09 // Omega
    origin  CHARACTER_OFFSETS_CUSTOM_ORIGIN + (8 * ('~' + 2 - 0x20)); db 0x09 // Music Note
    pullvar base, origin

    // @ Description
    // Contains offsets to characters in the credits screen's font file arranged in ASCII order.
    // First word contains dimension details
    // Second word contains the offset in the font file
    character_offsets_c3:
    // skip characters 0x0 - 0x19
    dw 0x03000000; dw 0x00000000              // space
    fill 0x8                                  // !
    OS.copy_segment(0x187A48 + 0x218, 0x1); db 0xE; OS.copy_segment(0x187A48 + 0x21A, 0x6) // " (adjusted so it will appear at top)
    fill 0x8 * 3                              // #$%
    OS.copy_segment(0x187A48 + 0x210, 0x8)    // &
    OS.copy_segment(0x187A48 + 0x228, 0x1); db 0xE; OS.copy_segment(0x187A48 + 0x22A, 0x6) // ' (adjusted so it will appear at top)
    OS.copy_segment(0x187A48 + 0x238, 0x10)   // ()
    fill 0x8 * 2                              // *+
    OS.copy_segment(0x187A48 + 0x208, 0x8)    // ,
    OS.copy_segment(0x187A48 + 0x200, 0x1); db 0x8; OS.copy_segment(0x187A48 + 0x202, 0x6) // - (adjusted so it will appear vertically centered)
    OS.copy_segment(0x187A48 + 0x1F8, 0x8)    // .
    OS.copy_segment(0x187A48 + 0x220, 0x8)    // /
    OS.copy_segment(0x187A48 + 0x1F0, 0x8)    // 0
    OS.copy_segment(0x187A48 + 0x1E8, 0x8)    // 1
    OS.copy_segment(0x187A48 + 0x1E0, 0x8)    // 2
    OS.copy_segment(0x187A48 + 0x1D8, 0x8)    // 3
    OS.copy_segment(0x187A48 + 0x1D0, 0x8)    // 4
    OS.copy_segment(0x187A48 + 0x1C8, 0x8)    // 5
    OS.copy_segment(0x187A48 + 0x1C0, 0x8)    // 6
    OS.copy_segment(0x187A48 + 0x1B8, 0x8)    // 7
    OS.copy_segment(0x187A48 + 0x1B0, 0x8)    // 8
    OS.copy_segment(0x187A48 + 0x1A8, 0x8)    // 9
    OS.copy_segment(0x187A48 + 0x1A0, 0x8)    // :
    fill 0x8 * (0x3E - 0x3B + 1)              // ;<=>
    OS.copy_segment(0x187A48 + 0x230, 0x8)    // ?
    fill 0x8                                  // @
    OS.copy_segment(0x187A48, 0xD0)           // A - Z
    fill 0x8 * (0x60 - 0x5B + 1)              // [\]^_`
    OS.copy_segment(0x187A48 + 0xD0, 0x30)    // a - f
    OS.copy_segment(0x187A48 + 0x100, 0x1); db 0xA; OS.copy_segment(0x187A48 + 0x102, 0x6) // g (adjusted so it goes slightly lower like a g should)
    OS.copy_segment(0x187A48 + 0x108, 0x10)   // h - i
    OS.copy_segment(0x187A48 + 0x118, 0x1); db 0xB; OS.copy_segment(0x187A48 + 0x11A, 0x6) // j (adjusted so it goes slightly lower like a g should)
    OS.copy_segment(0x187A48 + 0x120, 0x28)   // k - o
    OS.copy_segment(0x187A48 + 0x148, 0x1); db 0xA; OS.copy_segment(0x187A48 + 0x14A, 0x6) // p (adjusted so it goes slightly lower like a g should)
    OS.copy_segment(0x187A48 + 0x150, 0x1); db 0xA; OS.copy_segment(0x187A48 + 0x152, 0x6) // q (adjusted so it goes slightly lower like a g should)
    OS.copy_segment(0x187A48 + 0x158, 0x38)   // r - x
    OS.copy_segment(0x187A48 + 0x190, 0x1); db 0xA; OS.copy_segment(0x187A48 + 0x192, 0x6) // y (adjusted so it goes slightly lower like a g should)
    OS.copy_segment(0x187A48 + 0x198, 0x8)    // z
    fill 0x8 * (0x7E - 0x7B + 1)              // {|}~

    // @ Description
    // Creates an object that will run the given function every frame
    // @ Arguments
    // functionAddress - pointer to routine to run (a0 will be object address)
    // order - higher than 0x8000 will make it run before most objects, lower will make it run after... usually 0x8000
    // @ Returns
    // v0 - pointer to object created
    macro register_routine(functionAddress, group, order) {
        addiu   sp, sp, -0x0010             // allocate stack space
        addiu   a0, r0, 0x0400              // a0 = Global Object ID (custom)
        li      a1, {functionAddress}       // a1 = routine to run every frame
        addiu   a2, r0, {group}             // a2 = group
        jal     Render.CREATE_OBJECT_       // create the object
        lui     a3, {order}
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Creates an object that will run the given function every frame
    // @ Arguments
    // functionAddress - pointer to routine to run (a0 will be object address)
    // @ Returns
    // v0 - pointer to object created
    macro register_routine(functionAddress) {
        Render.register_routine({functionAddress}, 0x0001, 0x8000)
    }

    // @ Description
    // Adds a pipe sync to the display list at dl
    // @ Arguments
    // dl - display list register
    // fr - free register
    macro pipe_sync(dl, fr) {
        lui     {fr}, 0xE700
        sw      {fr}, 0x0000({dl})
        sw      r0, 0x0004({dl})
        addiu   {dl}, {dl}, 0x0008              // {dl} = {dl} + 8 (move display list forward)
    }

    // @ Description
    // Sets the fill color for the display list at dl
    // @ Arguments
    // dl - display list register
    // fr - free register
    // color - register holding 16-bit RGBA value for color
    macro set_fill_color(dl, fr, color) {
        lui     {fr}, 0xF700
        sw      {fr}, 0x0000({dl})
        sw      {color}, 0x0004({dl})
        addiu   {dl}, {dl}, 0x0008              // {dl} = {dl} + 8 (move display list forward)
    }

    // @ Description
    // Sets the primary color for the display list at dl
    // @ Arguments
    // dl - display list register
    // fr - free register
    // color - register holding RRGGBBAA hex value for color
    macro set_prim_color(dl, fr, color) {
        lui     {fr}, 0xFA00
        sw      {fr}, 0x0000({dl})
        sw      {color}, 0x0004({dl})
        addiu   {dl}, {dl}, 0x0008              // {dl} = {dl} + 8 (move display list forward)
    }

    // @ Description
    // Adds a rectangle to the display list at dl
    // @ Arguments
    // dl - display list register
    // fr1 - free register 1
    // fr2 - free register 2
    // ulx - Upper left X register
    // uly - Upper left Y register
    // lrx - Lower right X register
    // lry - Lower right Y register
    macro fill_rectangle(dl, fr1, fr2, ulx, uly, lrx, lry) {
        lui     {fr1}, 0xF600
        sll     {fr2}, {lrx}, 0x0002            // {fr2} = lrx * 4
        sll     {fr2}, {fr2}, 0x000C            // {fr2} = lrx << 12
        or      {fr1}, {fr1}, {fr2}             // {fr1} = opcode | lrx
        sll     {fr2}, {lry}, 0x0002            // {fr2} = lry * 4
        or      {fr1}, {fr1}, {fr2}             // {fr1} = opcode | lrx | lry
        sw      {fr1}, 0x0000({dl})
        sll     {fr1}, {ulx}, 0x0002            // {fr1} = ulx * 4
        sll     {fr1}, {fr1}, 0x000C            // {fr1} = ulx << 12
        sll     {fr2}, {uly}, 0x0002            // {fr2} = uly * 4
        or      {fr1}, {fr1}, {fr2}             // {fr1} = ulx | uly
        sw      {fr1}, 0x0004({dl})
        addiu   {dl}, {dl}, 0x0008              // {dl} = {dl} + 8 (move display list forward)
    }

    // @ Description
    // Draws a rectangle
    // @ Arguments
    // room - room
    // group - linked list to append
    // ulx - upper left X coordinate for rectangle [10, 310]
    // uly - upper left Y coordinate for rectangle [10, 230]
    // width - width of rectangle
    // height - height of rectangle
    // color - color and alpha for rectangle: 0xRRGGBBAA
    // enable_alpha - if OS.TRUE, then the rectangle supports transparency
    // @ Returns
    // v0 - pointer to object created
    macro draw_rectangle(room, group, ulx, uly, width, height, color, enable_alpha) {
        lli     a0, {room}
        lli     a1, {group}
        lli     s1, {ulx}
        lli     s2, {uly}
        lli     s3, {width}
        lli     s4, {height}
        li      s5, {color}
        jal     Render.draw_rectangle_
        lli     s6, {enable_alpha}
    }

    // @ Description
    // Draws a texture
    // @ Arguments
    // room - room
    // group - linked list to append
    // footer - pointer to image footer
    // routine - routine to run every frame
    // ulx - upper left X coordinate for texture
    // uly - upper left Y coordinate for texture
    // color - color and alpha for texture if supported for type: 0xRRGGBBAA
    // palette - color and alpha for texture palette if supported for type: 0xRRGGBBAA
    // scale - scale
    // @ Returns
    // v0 - pointer to object created
    macro draw_texture(room, group, footer, routine, ulx, uly, color, palette, scale) {
        lli     a0, {room}
        lli     a1, {group}
        li      a2, {footer}
        li      a3, {routine}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {color}
        li      s4, {palette}
        li      s5, {scale}
        jal     Render.draw_texture_
        nop
    }

    // @ Description
    // Draws a texture at an offset of the given pointer
    // @ Arguments
    // room - room
    // group - linked list to append
    // file - pointer to file
    // offset - offset in file to footer
    // routine - routine to run every frame
    // ulx - upper left X coordinate for texture
    // uly - upper left Y coordinate for texture
    // color - color and alpha for texture if supported for type: 0xRRGGBBAA
    // palette - color and alpha for texture palette if supported for type: 0xRRGGBBAA
    // scale - scale
    // @ Returns
    // v0 - pointer to object created
    macro draw_texture_at_offset(room, group, file, offset, routine, ulx, uly, color, palette, scale) {
        lli     a0, {room}
        lli     a1, {group}
        li      a2, {file}
        lw      a2, 0x0000(a2)            // load the pointer to get base file
        li      a3, {offset}
        addu    a2, a2, a3                // add offset
        li      a3, {routine}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {color}
        li      s4, {palette}
        li      s5, {scale}
        jal     Render.draw_texture_
        nop
    }

    // @ Description
    // Draws a texture
    // @ Arguments
    // room - room
    // group - linked list to append
    // array - pointer to array of pointers to image footers
    // routine - routine to run every frame
    // flags - image type flags
    // ulx - upper left X coordinate for texture
    // uly - upper left Y coordinate for texture
    // color - color and alpha for texture if supported for type: 0xRRGGBBAA
    // palette - color and alpha for texture palette if supported for type: 0xRRGGBBAA
    // image_count - number of images in grid
    // max_columns - max columns per row
    // padding - padding
    // @ Returns
    // v0 - pointer to object created
    macro draw_texture_grid(room, group, array, routine, flags, ulx, uly, color, palette, image_count, max_columns, padding) {
        lli     a0, {room}
        lli     a1, {group}
        li      a2, {array}
        li      a3, {routine}
        li      s0, {flags}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {color}
        li      s4, {palette}
        li      s5, {image_count}
        li      s6, {max_columns}
        li      s7, {padding}
        jal     Render.draw_texture_grid_
        nop
    }

    // @ Description
    // Loads the given file
    // @ Arguments
    // file_number - file number
    // file_address - pointer to start of file
    macro load_file(file_number, file_address) {
        li      a1, {file_address}          // a1 = file_address
        jal     Render.load_file_
        lli     a0, {file_number}           // a0 = file number
    }

    // @ Description
    // Loads a custom font file (Kabel)
    // @ Returns
    // font_file_address - pointer to start of font file
    // character_offsets_address - pointer to character offsets for the font file
    macro load_font() {
        Render.load_file(File.CUSTOM_FONT, Render.font_file_address)
        li      t0, Render.character_offsets_address
        li      t1, Render.character_offsets_custom
        sw      t1, 0x0000(t0)
        li      t0, Render.default_font_size
        lui     t1, 0x3F80
        sw      t1, 0x0000(t0)
    }

    // @ Description
    // Loads font file C3, the font file from credits screen
    // @ Returns
    // font_file_address - pointer to start of font file
    // character_offsets_address - pointer to character offsets for the font file
    macro load_font_2() {
        Render.load_file(0xC3, Render.font_file_address)
        li      t0, Render.character_offsets_address
        li      t1, Render.character_offsets_c3
        sw      t1, 0x0000(t0)
        li      t0, Render.default_font_size
        lui     t1, 0x3F20
        sw      t1, 0x0000(t0)
    }

    // @ Description
    // Draws a string
    // @ Arguments
    // room - room
    // group - linked list to append
    // string - pointer to string data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // @ Returns
    // v0 - pointer to object created
    macro draw_string(room, group, string, routine, ulx, uly, color, scale, alignment, blur) {
        lli     a0, {room}
        lli     a1, {group}
        evaluate str({string})
        if {str} != 0xFFFFFFFF {
            li      a2, {string}
        }
        li      a3, {routine}
        if {ulx} != 0xFFFFFFFF {
            li      s1, {ulx}
        }
        if {uly} != 0xFFFFFFFF {
            li      s2, {uly}
        }
        li      s3, {color}
        li      s4, {scale}
        lli     s5, {alignment}
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lli     t8, {blur}
    }

    // @ Description
    // Draws a string with blur set
    // @ Arguments
    // room - room
    // group - linked list to append
    // string - pointer to string data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // @ Returns
    // v0 - pointer to object created
    macro draw_string(room, group, string, routine, ulx, uly, color, scale, alignment) {
        Render.draw_string({room}, {group}, {string}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, 0x0001)
    }

    // @ Description
    // Draws a string using a pointer
    // @ Arguments
    // room - room
    // group - linked list to append
    // string - pointer to pointer to string data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // @ Returns
    // v0 - pointer to object created
    macro draw_string_pointer(room, group, string, routine, ulx, uly, color, scale, alignment, blur) {
        if {room} != 0xFF {
            lli     a0, {room}
        }
        lli     a1, {group}
        evaluate str({string})
        if {str} != 0xFFFFFFFF {
            li      a2, {string}
        }
        li      a3, {routine}
        if {ulx} != 0xFFFFFFFF {
            li      s1, {ulx}
        }
        if {uly} != 0xFFFFFFFF {
            li      s2, {uly}
        }
        li      s3, {color}
        li      s4, {scale}
        lli     s5, {alignment}
        lli     s6, Render.string_type.TEXT_POINTER
        jal     Render.draw_string_
        lli     t8, {blur}
    }

    // @ Description
    // Draws a string using a pointer with blur set
    // @ Arguments
    // room - room
    // group - linked list to append
    // string - pointer to pointer to string data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // @ Returns
    // v0 - pointer to object created
    macro draw_string_pointer(room, group, string, routine, ulx, uly, color, scale, alignment) {
        Render.draw_string_pointer({room}, {group}, {string}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, 0x0001)
    }

    // @ Description
    // Draws a number as a string
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // decimals - number of decimals (e.g. if 1, 14 would become 1.4)
    // @ Returns
    // v0 - pointer to object created
    macro draw_number(room, group, number, routine, ulx, uly, color, scale, alignment, blur, decimals) {
        if {room} != 0xFF {
            lli     a0, {room}
        }
        lli     a1, {group}
        if {number} != 0xFFFFFFFF {
            li      a2, {number}
        }
        li      a3, {routine}
        if {ulx} != 0xFFFFFFFF {
            li      s1, {ulx}
        }
        if {uly} != 0xFFFFFFFF {
            li      s2, {uly}
        }
        li      s3, {color}
        li      s4, {scale}
        lli     s5, {alignment}
        lli     s6, Render.string_type.NUMBER | ({decimals} << 4)
        lli     s7, 0x0000
        jal     Render.draw_string_
        lli     t8, {blur}
    }

    // @ Description
    // Draws a number as a string with no decimals
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // @ Returns
    // v0 - pointer to object created
    macro draw_number(room, group, number, routine, ulx, uly, color, scale, alignment, blur) {
        Render.draw_number({room}, {group}, {number}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, {blur}, 0)
    }

    // @ Description
    // Draws a number as a string with no decimals and with blur set
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // @ Returns
    // v0 - pointer to object created
    macro draw_number(room, group, number, routine, ulx, uly, color, scale, alignment) {
        Render.draw_number({room}, {group}, {number}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, 0x0001, 0)
    }

    // @ Description
    // Draws a number as a string, adjusted by the given value
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // amount - amount to add to number (can be negative)
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // @ Returns
    // v0 - pointer to object created
    macro draw_number_adjusted(room, group, number, amount, routine, ulx, uly, color, scale, alignment, blur) {
        lli     a0, {room}
        lli     a1, {group}
        li      a2, {number}
        li      a3, {routine}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {color}
        li      s4, {scale}
        lli     s5, {alignment}
        lli     s6, Render.string_type.NUMBER
        lli     s7, {amount}
        jal     Render.draw_string_
        lli     t8, {blur}
    }

    // @ Description
    // Draws a number as a string, adjusted by the given value with blur set
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // amount - amount to add to number (can be negative)
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // @ Returns
    // v0 - pointer to object created
    macro draw_number_adjusted(room, group, number, amount, routine, ulx, uly, color, scale, alignment) {
        Render.draw_number_adjusted({room}, {group}, {number}, {amount}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, 0x0001)
    }

    // @ Description
    // Draws a number as a signed string, always prefixed with + or -
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // blur - whether or not to respect the alpha and blur the edges (antialiasing?)
    // @ Returns
    // v0 - pointer to object created
    macro draw_number_signed_with_prefix(room, group, number, routine, ulx, uly, color, scale, alignment, blur) {
        lli     a0, {room}
        lli     a1, {group}
        li      a2, {number}
        li      a3, {routine}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {color}
        li      s4, {scale}
        lli     s5, {alignment}
        lli     s6, Render.string_type.NUMBER_SIGNED_WITH_PREFIX
        lli     s7, 0x0000
        jal     Render.draw_string_
        lli     t8, {blur}
    }

    // @ Description
    // Draws a number as a signed string, always prefixed with + or -, with blur set
    // @ Arguments
    // room - room
    // group - linked list to append
    // number - pointer to number data
    // routine - routine to run every frame
    // ulx - upper left X coordinate for string
    // uly - upper left Y coordinate for string
    // color - color for string if supported for type: 0xRRGGBBFF
    // scale - scale the font size
    // alignment - alignment of string
    // @ Returns
    // v0 - pointer to object created
    macro draw_number_signed_with_prefix(room, group, number, routine, ulx, uly, color, scale, alignment) {
        Render.draw_number_signed_with_prefix({room}, {group}, {number}, {routine}, {ulx}, {uly}, {color}, {scale}, {alignment}, 0x0001)
    }

    // @ Description
    // Creates a room
    // @ Arguments
    // room - room
    // group - linked list to append
    // z_index - z-index of room
    // ulx - upper left X coordinate for rendered area
    // uly - upper left Y coordinate for rendered area
    // lrx - lower left X coordinate for rendered area
    // lry - lower left Y coordinate for rendered area
    // @ Returns
    // v0 - pointer to object created
    macro create_room(room, group, z_index, ulx, uly, lrx, lry) {
        lli     a0, {room}
        lli     a1, {group}
        lli     a2, {z_index}
        li      s1, {ulx}
        li      s2, {uly}
        li      s3, {lrx}
        jal     Render.create_room_
        li      s4, {lry}
    }

    // @ Description
    // Creates a room with a full viewport
    // @ Arguments
    // room - room
    // group - linked list to append
    // z_index - z-index of room
    // @ Returns
    // v0 - pointer to object created
    macro create_room(room, group, z_index) {
        lli     a0, {room}
        lli     a1, {group}
        lli     a2, {z_index}
        lui     s1, 0x4120
        lui     s2, 0x4120
        lui     s3, 0x439B
        jal     Render.create_room_
        lui     s4, 0x4366
    }

    // @ Description
    // Loads a file
    // @ Arguments
    // a0 - file ID to load
    // a1 - address for storing pointer to file
    scope load_file_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a1, 0x0008(sp)              // save a1

        li      a2, temp_file_ID            // a2 = pointer to file ID of file
        sw      a0, 0x0000(a2)              // set file ID to load
        or      a0, a2, r0                  // a0 = pointer to file ID of file
        jal     0x800CDEEC                  // v0 = length of file
        addiu   a1, r0, 0x0001              // a1 = 1 (number of files in array)

        or      a0, v0, r0                  // a0 = length of file
        jal     0x80004980                  // allocate heap space (malloc)
        addiu   a1, r0, 0x0010              // a1 = align to 0x10

        li      a0, temp_file_ID            // a2 = pointer to file ID of file
        lw      a2, 0x0008(sp)              // a2 = file RAM address to use for later referencing
        or      a3, v0, r0                  // a3 = address to load file to
        jal     0x800CDE04                  // load file
        addiu   a1, r0, 0x0001              // a1 = 1 (number of files in array)

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        temp_file_ID:
        dw      0x00000000
    }

    // @ Description
    // Creates an object used to render a display list
    // @ Arguments
    // a0 - pointer to routine to run every frame (a0 will be object address)
    // a1 - pointer to routine for creating the display list
    // a2 - room
    // a3 - group - linked list to append
    // @ Returns
    // v0 - pointer to object created
    scope create_display_object_: {
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a1, 0x001C(sp)              // save a1
        sw      a2, 0x0020(sp)              // save a2

        addu    a1, r0, a0                  // a1 = routine to run every frame
        addiu   a0, r0, 0x0401              // a0 = Global Object ID (custom)
        addu    a2, r0, a3                  // a2 = group - linked list to append
        addiu   sp, sp, -0x0030             // allocate stack space for CREATE_OBJECT_
        li      a3, display_order_group
        jal     CREATE_OBJECT_              // create the object
        lw      a3, 0x0000(a3)              // a3 = display order (usually just 0x80000000)
        addiu   sp, sp, 0x0030              // deallocate stack space
        sw      v0, 0x0024(sp)              // save v0

        lw      a2, 0x0020(sp)              // a2 = room
        lw      a1, 0x001C(sp)              // a1 = RAM address of display list render routine to use
        addiu   sp, sp, -0x0030             // allocate stack space for DISPLAY_INIT_
        addiu   a0, r0, 0xFFFF              // a0 = -1
        sw      a0, 0x0010(sp)              // 0x0010(sp) = -1 (not sure why)
        addu    a0, r0, v0                  // a0 = RAM address of object block
        li      a3, display_order_room
        jal     DISPLAY_INIT_               // initialize display object
        lw      a3, 0x0000(a3)              // a3 = display order (usually just 0x80000000)
        addiu   sp, sp, 0x0030              // deallocate stack space

        lw      ra, 0x0004(sp)              // restore ra
        lw      v0, 0x0024(sp)              // restore v0
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Creates a room.
    // Based highly on existing native code, which actually seems to have been a macro.
    // @ Arguments
    // a0 - room
    // a1 - group
    // a2 - z-index (0x0 - 0x64 where higher draws under and lower draws over)
    // s1 - ulx of view port (anything positioned left of this will not render)
    // s2 - uly of view port (anything positioned above this will not render)
    // s3 - lrx of view port (anything positioned right of this will not render)
    // s4 - lry of view port (anything positioned below this will not render)
    // @ Returns
    // v0 - pointer to object created
    scope create_room_: {
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      s1, 0x0004(sp)              // save ulx
        sw      s2, 0x0008(sp)              // save uly
        sw      s3, 0x000C(sp)              // save lrx
        sw      s4, 0x0010(sp)              // save lry

        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x003C(sp)              // save ra

        addiu   a0, a0, -0x0001             // adjust a0

        // TODO: The logic below is basically right, but probably doesn't handle 0x20 right, 0x0 too probably.
        // if room > 0x1F, t8 = 2 << (room - 0x21), t9 = 0
        // if room < 0x20, t8 = 0, t9 = 2 << room
        lli     t8, 0x0000
        lli     t9, 0x0000
        lli     t1, 0x0002
        sltiu   t0, a0, 0x0020
        bnezl   t0, _setup                  // if room < 0x20,
        sllv    t9, t1, a0                  // then t9 = 2 << room

        addiu   a0, a0, -0x0020             // else,
        sllv    t8, t1, a0                  // t8 = 2 << (room - 0x21)

        _setup:
        // set up parameters on stack - much of these are not well understood
        li      t6, 0x800CD2CC              // routine that renders the room
        lli     t0, -0x0001
        lli     t1, 0x0001
        lli     t2, 0x0001
        sw      t2, 0x0030(sp)
        sw      t1, 0x0028(sp)
        sw      t0, 0x0020(sp)
        sw      t9, 0x001C(sp)              // room lower
        sw      t8, 0x0018(sp)              // room upper
        sw      a2, 0x0014(sp)              // z-index
        sw      t6, 0x0010(sp)
        sw      r0, 0x0024(sp)
        sw      r0, 0x002C(sp)
        sw      r0, 0x0034(sp)

        lli     a0, 0x0401                  // global obj ID for room
        or      a2, r0, a1                  // group
        lli     a1, 0x0000                  // routine to run
        jal     0x8000B93C                  // create room object
        lui     a3, 0x8000                  // order in group

        sw      v0, 0x0054(sp)              // save reference to object

        lw      v1, 0x0074(v0)
        addiu   a0, v1, 0x0008
        lw      a1, 0x0044(sp)              // a1 = ulx
        lw      a2, 0x0048(sp)              // a2 = uly
        lw      a3, 0x004C(sp)              // a3 = lrx
        lwc1    f4, 0x0050(sp)              // f4 = lry
        jal     0x80007080
        swc1    f4, 0x0010(sp)              // 0x0010(sp) = lry

        lw      ra, 0x003C(sp)              // restore ra
        lw      v0, 0x0054(sp)
        addiu   sp, sp, 0x0040              // deallocate stack space

        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Creates a rectangle
    // @ Arguments
    // a0 - room
    // a1 - group - linked list to append
    // s1 - ulx
    // s2 - uly
    // s3 - width
    // s4 - height
    // s5 - color (0xRRGGBBAA)
    // s6 - alpha on?
    // @ Returns
    // v0 - pointer to object created
    scope draw_rectangle_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        or      a2, r0, a0
        or      a3, r0, a1
        lli     a0, 0x0000
        li      a1, draw_rectangle_._render
        jal     create_display_object_
        nop
        sw      s1, 0x0030(v0)              // s1 = ulx
        sw      s2, 0x0034(v0)              // s2 = uly
        sw      s3, 0x0038(v0)              // s3 = width
        sw      s4, 0x003C(v0)              // s4 = height
        sw      s5, 0x0040(v0)              // s5 = color
        sw      s6, 0x0044(v0)              // s6 = alpha on?

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        _render:
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~
        sw      s5, 0x0018(sp)              // ~
        sw      s6, 0x001C(sp)              // ~

        // a0 - object struct
        lw      s1, 0x0030(a0)              // s1 = ulx
        lw      s2, 0x0034(a0)              // s2 = uly
        lw      s3, 0x0038(a0)              // s3 = width
        addu    s3, s1, s3                  // s3 = lrx
        lw      s4, 0x003C(a0)              // s4 = height
        addu    s4, s2, s4                  // s4 = lry
        lw      s5, 0x0040(a0)              // s5 = color
        lw      s6, 0x0044(a0)              // s6 = alpha on?
        li      t0, 0x800465B0              // t0 = pointer to current end of display list
        lw      v1, 0x0000(t0)              // v1 = current end of display list

        pipe_sync(v1, t1)

        // Set Other Modes High
        lui     t1, 0xE300
        ori     t1, t1, 0x0A01              // gDPSetCycleType(glistp++, G_CYC_1CYCLE);
        lli     t2, 0x0000                  // ~
        beqzl   s6, pc() + 8                // use different settings if alpha is off
        lui     t2, 0x0030                  // gDPSetTextureConvert(glistp++, G_TC_FILT)?
        sw      t1, 0x0000(v1)
        sw      t2, 0x0004(v1)
        addiu   v1, v1, 0x00008

        beqz    s6, _set_other_modes_low    // skip combiner if alpha off
        nop

        // Set Primary Color
        set_prim_color(v1, t1, s5)

        // Set Combine
        li      t1, 0xFCFFFFFF              // gsDPSetCombineLERP(0, 0, 0, PRIMITIVE,  0, 0, 0, PRIMITIVE,  0, 0, 0, PRIMITIVE,  0, 0, 0, PRIMITIVE)
        li      t2, 0xFFFDF6FB              // ~
        sw      t1, 0x0000(v1)
        sw      t2, 0x0004(v1)
        addiu   v1, v1, 0x00008

        _set_other_modes_low:
        // Set Other Modes Low
        li      t1, 0xE200001C
        li      t2, 0x00504340
        beqzl   s6, pc() + 8                // use different settings if alpha is off
        lli     t2, 0x0000
        sw      t1, 0x0000(v1)
        sw      t2, 0x0004(v1)
        addiu   v1, v1, 0x00008

        bnez    s6, _fill_rectangle         // skip fill color and width/height adjustment if alpha on
        nop

        // Set Fill Color
        sw      v1, 0x0020(sp)              // save v1
        sw      t0, 0x0024(sp)              // save t0
        jal     CONVERT_RGBA_16_
        or      a0, s5, r0
        lw      v1, 0x0020(sp)              // restore v1
        lw      t0, 0x0024(sp)              // restore t0
        set_fill_color(v1, t1, v0)

        // decrease width and height by 1
        addiu   s3, s3, -0x0001
        addiu   s4, s4, -0x0001

        _fill_rectangle:
        // Fill Rectangle
        fill_rectangle(v1, t1, t2, s1, s2, s3, s4)

        pipe_sync(v1, t1)

        // Clear out previous texture settings.
        // The game seems to use the memory addresses cleared by this routine to track RDP state.
        // The next time the texture rendering routine is called, it will set up the RDP from scratch accordingly.
        jal     0x800CCEAC
        nop

        sw      v1, 0x0000(t0)              // update pointer to end of display list

        lw      ra, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0014(sp)              // ~
        lw      s5, 0x0018(sp)              // ~
        lw      s6, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draws a texture
    // @ Arguments
    // a0 - room
    // a1 - group - linked list to append
    // a2 - pointer to image footer struct
    // a3 - routine to run every frame
    // s1 - X position
    // s2 - Y position
    // s3 - color
    // s4 - palette
    // s5 - scale
    // @ Returns
    // v0 - pointer to object created
    scope draw_texture_: {
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a2, 0x0008(sp)              // save a2
        sw      s1, 0x000C(sp)              // save s1
        sw      s2, 0x0010(sp)              // save s2
        sw      s3, 0x0014(sp)              // save s3
        sw      s4, 0x0018(sp)              // save s4
        sw      s5, 0x001C(sp)              // save s5

        or      a2, r0, a0                  // room
        or      a0, r0, a3                  // routine
        or      a3, r0, a1                  // group
        li      a1, TEXTURE_RENDER_
        jal     create_display_object_
        nop

        sw      v0, 0x0020(sp)              // save v0
        addu    a0, r0, v0                  // a0 = RAM address of object block
        lw      a1, 0x0008(sp)              // a1 = RAM address of image footer struct
        jal     TEXTURE_INIT_               // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a1, 0x000C(sp)              // a1 = X position
        sw      a1, 0x0058(v0)              // set X position
        lw      a1, 0x0010(sp)              // a1 = Y position
        sw      a1, 0x005C(v0)              // set Y position
        // TODO: do we need this? should it be an argument?
        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur
        lw      a1, 0x0014(sp)              // a1 = color
        sw      a1, 0x0028(v0)              // set color
        lw      a1, 0x0018(sp)              // a1 = palette
        sw      a1, 0x0060(v0)              // set palette
        lw      a1, 0x001C(sp)              // a1 = scale
        sw      a1, 0x0018(v0)              // set X scale
        sw      a1, 0x001C(v0)              // set Y scale

        lw      ra, 0x0004(sp)              // restore ra
        lw      v0, 0x0020(sp)              // restore v0
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draws a texture tied to stage coordinates.
    // Currently, it will only work with RGBA5551 textures, and expects 0x32 x 0x32 dimensions.
    // Will need to modify this routine if we need to draw anything else.
    // @ Arguments
    // a0 - room
    // a1 - group - linked list to append
    // a2 - pointer to image
    // a3 - routine to run every frame
    // s1 - x
    // s2 - y
    // s3 - z
    // s4 - alpha (0x00 - 0xFF)
    // @ Returns
    // v0 - pointer to object created
    scope draw_stage_texture_: {
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a2, 0x0008(sp)              // save a2
        sw      s4, 0x000C(sp)              // save s4

        li      t0, model_part              // t0 = RAM address of model part
        sw      s1, 0x0008(t0)              // update x
        sw      s2, 0x000C(t0)              // update y
        sw      s3, 0x0010(t0)              // update z



        or      a2, r0, a0                  // room
        or      a0, r0, a3                  // routine
        or      a3, r0, a1                  // group
        li      a1, STAGE_OBJECT_RENDER_
        jal     create_display_object_
        nop

        lw      s4, 0x000C(sp)              // s4 = alpha
        li      t0, model_part_image        // t0 = RAM address of model part image
        sb      s4, 0x0053(t0)              // update alpha

        lw      a2, 0x0008(sp)              // a2 = image pointer
        sw      a2, 0x0040(v0)              // save image pointer
        sw      r0, 0x0044(v0)              // terminate image array with a 0
        addiu   t1, v0, 0x0040              // t1 = image array address
        sw      t1, 0x0004(t0)              // save reference to image array

        sw      v0, 0x0020(sp)              // save v0
        addiu   sp, sp, -0x0030             // allocate stack space for STAGE_OBJECT_INIT_
        addu    a0, r0, v0                  // a0 = RAM address of object block
        li      a1, model_part              // a1 = RAM address of model part
        lli     a2, 0x0000                  // ?
        li      a3, 0x001C                  // ?
        sw      r0, 0x0010(sp)              // ?
        jal     STAGE_OBJECT_INIT_          // v0 = RAM address of joint struct
        sw      r0, 0x0014(sp)              // ?
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a0, 0x0020(sp)              // a0 = object
        lw      a0, 0x0074(a0)              // a0 = RAM address of joint struct
        li      a1, model_part_image        // a1 = RAM address of model part image
        jal     MODEL_PART_IMAGE_INIT_      // v0 = RAM address of model part image struct
        addiu   sp, sp, -0x0030             // allocate stack space for MODEL_PART_IMAGE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      ra, 0x0004(sp)              // restore ra
        lw      v0, 0x0020(sp)              // restore v0
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop

        model_part:
        dh 0x0000                           // joint flag (can control on top/always facing you)
        dh 0x0000                           // joint (matrix depth)
        dw part_display_list                // pointer to display list
        float32 0                           // x position
        float32 0                           // y position
        float32 0                           // z position
        float32 0                           // x rotation
        float32 0                           // y rotation
        float32 0                           // z rotation
        float32 1                           // x scale
        float32 1                           // y scale
        float32 1                           // z scale

        dh 0x0000
        dh 0x0012                           // signifies end of model part array

        OS.align(8)
        vertex_data:
        dw 0x00C8FF38, 0x00000000, 0x04000400, 0xFFFFFF00
        dw 0xFF38FF38, 0x00000000, 0x00000400, 0xFFFFFF00
        dw 0xFF3800C8, 0x00000000, 0x00000000, 0xFFFFFF00
        dw 0x00C800C8, 0x00000000, 0x04000000, 0xFFFFFF00

        part_display_list:
        dw 0xD9DDFFFB, 0x00000000           //
        dw 0xDE000000, 0x0E000008           // branch display list to dynamic display list created by part image (set prim color)
        dw 0xD7000002, 0xFFFFFFFF           //
        dw 0xF9000000, 0x00000008           //
        dw 0xE7000000, 0x00000000           // pipe sync
        dw 0xD9FFFFFF, 0x00000004           //
        dw 0xE2001E01, 0x00000001           //
        dw 0xFC121624, 0xFF2FFFFF           // set combiner ()
        dw 0xF5100000, 0x07014050           //
        dw 0xF5101000, 0x00094250           //
        dw 0xF2000000, 0x0007C07C           //
        dw 0xDE000000, 0x0E000000           // branch display list to dynamic display list created by part image (load texture)
        dw 0xE6000000, 0x00000000           //
        dw 0xF3000000, 0x073FF000           //
        dw 0xE7000000, 0x00000000           // pipe sync
        dw 0x01004008, vertex_data          // g_vtx
        dw 0x06060402, 0x00000602           //
        dw 0xE7000000, 0x00000000           // pipe sync
        dw 0xD9FFFFFF, 0x00220000           //
        dw 0xE2001E01, 0x00000000           //
        dw 0xDF000000, 0x00000000           // end display list

        // getting a lot of these descriptions from GE Setup Edtior
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
        dw 0x00000000                       // Palette Array Pointer
        dh 0x0201                           // Flags: 0x1 = image array, 0x200 = prim color
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
    }

    // @ Description
    // Draws a texture grid
    // @ Arguments
    // a0 - room
    // a1 - group - linked list to append
    // a2 - pointer to pointer to image footer struct array
    // a3 - routine to run every frame
    // s0 - image type flags
    // s1 - X position
    // s2 - Y position
    // s3 - color
    // s4 - palette
    // s5 - number of images in grid
    // s6 - max columns
    // s7 - padding
    // @ Returns
    // v0 - pointer to object created
    scope draw_texture_grid_: {
        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a2, 0x0008(sp)              // save a2
        sw      s1, 0x000C(sp)              // save s1
        sw      s2, 0x0010(sp)              // save s2
        sw      s3, 0x0014(sp)              // save s3
        sw      s4, 0x0018(sp)              // save s4
        sw      s5, 0x001C(sp)              // save s5
        sw      s6, 0x0020(sp)              // save s6
        sw      s7, 0x0024(sp)              // save s7
        sw      s0, 0x0030(sp)              // save s0

        or      a2, r0, a0
        or      a0, r0, a3
        or      a3, r0, a1
        li      a1, TEXTURE_RENDER_
        jal     create_display_object_
        nop

        sw      v0, 0x0028(sp)              // save v0
        sw      r0, 0x002C(sp)              // current count

        // store arguments in object struct for future reference outside this routine
        lw      a0, 0x000C(sp)              // ~
        sw      a0, 0x0058(v0)              // save original X position (0x0038 can't be used)
        lw      a0, 0x0010(sp)              // ~
        sw      a0, 0x003C(v0)              // save original Y position
        lw      a0, 0x0014(sp)              // ~
        sw      a0, 0x0040(v0)              // save color
        lw      a0, 0x0018(sp)              // ~
        sw      a0, 0x0044(v0)              // save palette
        lw      a0, 0x001C(sp)              // ~
        sw      a0, 0x0048(v0)              // save number of images in grid
        lw      a1, 0x0020(sp)              // ~
        sw      a1, 0x004C(v0)              // save max columns
        lw      a1, 0x0024(sp)              // ~
        sw      a1, 0x0050(v0)              // save padding
        lw      a1, 0x0030(sp)              // ~
        sw      a1, 0x0054(v0)              // save image type flags

        lw      a0, 0x0008(sp)              // ~
        sw      a0, 0x0034(v0)              // save pointer to pointer to RAM address of image footer struct array
        bnezl   a0, pc() + 8                // skip loading if pointer is empty!
        lw      a0, 0x0000(a0)              // a0 = pointer to RAM address of image footer struct array
        sw      a0, 0x0030(v0)              // save pointer to RAM address of image footer struct array
        sw      a0, 0x0008(sp)              // save pointer to RAM address of image footer struct array

        _add_texture:
        addu    a0, r0, v0                  // a0 = RAM address of object block
        lw      a1, 0x0008(sp)              // a1 = pointer to RAM address of image footer struct
        bnezl   a1, pc() + 8                // skip loading if pointer is empty!
        lw      a1, 0x0000(a1)              // a1 = RAM address of image footer struct
        jal     TEXTURE_INIT_               // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      s6, 0x0020(sp)              // s6 = max columns
        lw      s7, 0x0024(sp)              // s7 = padding
        lw      a0, 0x002C(sp)              // a0 = current image count
        divu    a0, s6                      // mfhi = column, mflo = row
        addiu   a0, a0, 0x0001              // ~
        sw      a0, 0x002C(sp)              // save current image count
        mfhi    t0                          // t0 = column
        mflo    t1                          // t1 = row
        lhu     t2, 0x0014(v0)              // t2 = image width
        addu    t2, t2, s7                  // t2 = image width + padding
        lhu     t3, 0x0016(v0)              // t3 = image height
        addu    t3, t3, s7                  // t3 = image height + padding
        multu   t0, t2                      // t0 = X offset
        mflo    t0                          // ~
        multu   t1, t3                      // t1 = Y offset
        mflo    t1                          // ~
        mtc1    t0, f0                      // f0 = X offset
        cvt.s.w f0, f0                      // ~
        mtc1    t1, f2                      // f2 = Y offset
        cvt.s.w f2, f2                      // ~
        lwc1    f4, 0x000C(sp)              // f4 = X position
        add.s   f4, f0, f4                  // f4 = X position, adjusted
        swc1    f4, 0x0058(v0)              // set X position
        lwc1    f4, 0x0010(sp)              // f4 = Y position
        add.s   f4, f2, f4                  // f4 = Y position, adjusted
        swc1    f4, 0x005C(v0)              // set Y position
        lw      a1, 0x0030(sp)              // a1 = image type flags
        sh      a1, 0x0024(v0)              // set image type flags
        lw      a1, 0x0014(sp)              // a1 = color
        sw      a1, 0x0028(v0)              // set color
        lw      a1, 0x0018(sp)              // a1 = palette
        sw      a1, 0x0060(v0)              // set palette

        lw      a0, 0x001C(sp)              // a0 = image count
        lw      a1, 0x002C(sp)              // a1 = images processed
        beq     a0, a1, _end                // if we've reached the end, skip to _end
        nop

        lw      a1, 0x0008(sp)              // a1 = RAM address of image footer struct
        addiu   a1, a1, 0x0004              // a1 = RAM address of next image footer struct
        sw      a1, 0x0008(sp)              // save RAM address of next image footer struct
        b       _add_texture
        lw      v0, 0x0028(sp)              // v0 = object struct

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        lw      v0, 0x0028(sp)              // restore v0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Draws a string
    // @ Arguments
    // a0 - room
    // a1 - group - linked list to append
    // a2 - pointer to string data
    // a3 - routine to run every frame
    // s1 - X position
    // s2 - Y position
    // s3 - color
    // s4 - scale
    // s5 - alignment
    // s6 - string_type
    // s7 - amount to adjust number, if number
    // t8 - blur
    // @ Returns
    // v0 - pointer to object created
    scope draw_string_: {
        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a2, 0x0008(sp)              // save a2
        sw      s1, 0x000C(sp)              // save s1
        sw      s2, 0x0010(sp)              // save s2
        sw      s3, 0x0014(sp)              // save s3
        sw      s4, 0x0018(sp)              // save s4
        sw      s5, 0x001C(sp)              // save s5
        sw      s6, 0x0020(sp)              // save s6
        sw      s7, 0x0024(sp)              // save s7
        sw      t8, 0x0030(sp)              // save t8

        or      a2, r0, a0
        or      a0, r0, a3
        or      a3, r0, a1
        li      a1, TEXTURE_RENDER_
        jal     create_display_object_
        nop

        sw      v0, 0x0028(sp)              // save v0 (RAM address of object block)

        // store arguments in object struct for future reference outside this routine
        lw      a0, 0x000C(sp)              // ~
        sw      a0, 0x0058(v0)              // save original X position (0x0038 can't be used)
        lw      a0, 0x0010(sp)              // ~
        sw      a0, 0x003C(v0)              // save original Y position
        lw      a0, 0x0014(sp)              // ~
        sw      a0, 0x0040(v0)              // save color
        lw      a0, 0x0018(sp)              // ~
        sw      a0, 0x0044(v0)              // save scale
        lw      a0, 0x001C(sp)              // ~
        sw      a0, 0x0048(v0)              // save alignment
        lw      a0, 0x0030(sp)              // ~
        sw      a0, 0x005C(v0)              // save blur
        lw      a0, 0x0008(sp)              // ~
        sw      a0, 0x0034(v0)              // save pointer to string data
        sw      a0, 0x0030(v0)              // save string data
        lw      a1, 0x0020(sp)              // ~
        sw      a1, 0x004C(v0)              // save string_type
        sw      r0, 0x0054(v0)              // clear out address used to point to this object in update_live_string_
        li      t0, display_order_room
        lw      t0, 0x0000(t0)              // t0 = display_order_room
        sw      t0, 0x0060(v0)              // save display_order_room at object creation
        li      t0, display_order_group
        lw      t0, 0x0000(t0)              // t0 = display_order_group
        sw      t0, 0x0064(v0)              // save display_order_group at object creation
        sw      r0, 0x0068(v0)              // set to no max width
        sw      r0, 0x006C(v0)              // clear extra space for use outside this routine
        sw      r0, 0x0070(v0)              // clear extra space for use outside this routine
        sw      r0, 0x0074(v0)              // clear extra space for use outside this routine
        sw      r0, 0x0078(v0)              // clear extra space for use outside this routine
        andi    a1, a1, 0x0001              // a1 = 1 if pointer, 0 if not
        beqz    a1, _check_number           // if not a pointer, skip
        nop                                 // otherwise, a0 is actually a pointer
        bnezl   a0, pc() + 8                // if pointer is 0, don't read!
        lw      a0, 0x0000(a0)              // ~
        sw      a0, 0x0030(v0)              // save RAM address of string/number
        sw      a0, 0x0008(sp)              // save RAM address of string/number

        _check_number:
        lw      a1, 0x0020(sp)              // a1 = string_type
        srl     a1, a1, 0x0001              // a1 = 1 if number, 0 if not
        beqz    a1, _align                  // if not a number, skip
        nop

        bnezl   a0, pc() + 8                // if pointer is 0, don't read!
        lw      a0, 0x0000(a0)              // ~
        lw      a1, 0x0024(sp)              // ~
        sw      a1, 0x0050(v0)              // save number adjust amount
        addu    a0, a0, a1                  // a0 = number, adjusted
        lw      a2, 0x0020(sp)              // a2 = string_type
        srl     a3, a2, 0x0004              // a3 = number of decimal places
        andi    a1, a2, 0b0100              // a1 = 1 if signed
        andi    a2, a2, 0b1000              // a2 = 1 if always show + prefix
        jal     String.itoa_                // v0 = pointer to string
        sw      a0, 0x0030(v0)              // save current value
        sw      v0, 0x0008(sp)              // save v0 as pointer to string data

        _align:
        lw      s1, 0x0008(sp)              // s1 = pointer to string data
        beqz    s1, _end_loop               // if no pointer, skip to end
        lli     s2, 0x0000                  // s2 = length of string = 0 to start
        lw      s5, 0x001C(sp)              // s5 = alignment
        beqz    s5, _loop                   // if (alignment = LEFT) then start X is fine, so skip
        nop                                 // otherwise, we'll need to recalculate start X
        _length_loop:
        lbu     a1, 0x0000(s1)              // a1 = character
        beqz    a1, _end_length_loop        // if a1 = 0x00, end loop
        nop
        sll     a1, a1, 0x0003              // a1 = a1 * 8 = offset in character_offsets table + 0x0100
        addiu   a1, a1, -0x0100             // a1 = corrected offset in character_offsets table
        li      a0, character_offsets_address
        lw      a0, 0x0000(a0)              // a0 = character_offsets
        addu    a0, a0, a1                  // a0 = character offset entry for this character
        lbu     a0, 0x0000(a0)              // a0 = width of this character
        addiu   a0, a0, 0x0001              // a0 = width of this character + padding
        addu    s2, s2, a0                  // s2 = width of string up through this character
        b       _length_loop                // continue loop
        addiu   s1, s1, 0x0001              // s1 = next character

        _end_length_loop:
        lw      s1, 0x0008(sp)              // s1 = pointer to string data
        mtc1    s2, f0                      // f0 = width of string
        cvt.s.w f0, f0                      // ~
        lwc1    f4, 0x0018(sp)              // f4 = scale
        mul.s   f0, f0, f4                  // f0 = width of string, scaled
        // if center: X' = X - f0/2
        // if right: X' = X - f0
        mtc1    s5, f2                      // f2 = 1 if left, 2 if center alignment
        cvt.s.w f2, f2                      // ~
        div.s   f0, f0, f2                  // f0 = negative offset for X
        lwc1    f2, 0x000C(sp)              // f2 = X position
        sub.s   f0, f2, f0                  // f0 = X position, aligned
        swc1    f0, 0x000C(sp)              // set X position

        _loop:
        lbu     a1, 0x0000(s1)              // a1 = character
        beqz    a1, _end_loop               // if a1 = 0x00, end loop
        lli     a2, 0x0020                  // a2 = 0x20 (space)

        beq     a1, a2, _space              // if space, we'll just increase X
        nop

        sll     a1, a1, 0x0003              // a1 = a1 * 8 = offset in character_offsets table + 0x0100
        addiu   a1, a1, -0x0100             // a1 = corrected offset in character_offsets table
        li      a0, character_offsets_address
        lw      a0, 0x0000(a0)              // a0 = character_offsets
        addu    a0, a0, a1                  // a0 = character offset entry for this character
        sw      a0, 0x002C(sp)              // save a0
        lw      a1, 0x0004(a0)              // a1 = offset in font file
        li      a0, font_file_address       // a0 = font_file_address
        lw      a0, 0x0000(a0)              // a0 = RAM address of font file
        addu    a1, a0, a1                  // a1 = RAM address of image footer struct
        lw      a0, 0x0028(sp)              // a0 = RAM address of object block
        jal     TEXTURE_INIT_               // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a0, 0x002C(sp)              // a0 = character offset entry for this character

        // X position
        lbu     a2, 0x0000(a0)              // a2 = width of character
        addiu   a2, a2, 0x0001              // a2 = width of character + padding
        mtc1    a2, f0                      // f0 = width of character + padding
        cvt.s.w f0, f0                      // ~
        lwc1    f4, 0x0018(sp)              // f4 = scale
        mul.s   f0, f0, f4                  // f0 = width of charater + padding, scaled
        swc1    f4, 0x0018(v0)              // set X scale
        lw      a1, 0x000C(sp)              // a1 = X position
        sw      a1, 0x0058(v0)              // set X position of character texture
        mtc1    a1, f2                      // f2 = X position
        add.s   f2, f0, f2                  // f2 = next X position
        mfc1    a1, f2                      // a1 = next X position
        sw      a1, 0x000C(sp)              // store X position

        // Y position
        lbu     a2, 0x0001(a0)              // a2 = height of character
        ori     a3, r0, 0x000E              // a3 = max height
        subu    a2, a3, a2                  // a2 = max height - height of character = top padding
        mtc1    a2, f0                      // f0 = top padding
        cvt.s.w f0, f0                      // ~
        lwc1    f4, 0x0018(sp)              // f4 = scale
        mul.s   f0, f0, f4                  // f0 = top padding, scaled
        swc1    f4, 0x001C(v0)              // set Y scale
        lw      a1, 0x0010(sp)              // a1 = Y position
        mtc1    a1, f2                      // f2 = Y position
        add.s   f2, f0, f2                  // f2 = adjusted Y position
        mfc1    a1, f2                      // a1 = adjusted Y position
        sw      a1, 0x005C(v0)              // set Y position

        lli     a1, 0x0201                  // a1 = flags for texture rendering settings: this tells it to add antialiasing/blur
        lw      t8, 0x0030(sp)              // t8 = 1 if we should do blur, 0 otherwise
        bnez    t8, _set_color               // if we shouldn't blur,
        nop
        addiu   a1, a1, -0x0001             // then turn off blur
        li      a0, 0x30303030              // for now, hard code a blend color TODO: argument?
        sw      a0, 0x0060(v0)              // set blend color
        _set_color:
        sh      a1, 0x0024(v0)              // set texture rendering flags
        lw      a1, 0x0014(sp)              // a1 = color
        sw      a1, 0x0028(v0)              // set color
        b       _loop                       // continue loop
        addiu   s1, s1, 0x0001              // s1 = next character

        _end_loop:
        lw      ra, 0x0004(sp)              // restore ra
        lw      v0, 0x0028(sp)              // restore v0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop

        _space:
        lli     a2, 0x0004                  // a2 = width of space
        mtc1    a2, f0                      // f0 = width of space
        cvt.s.w f0, f0                      // ~
        lwc1    f4, 0x0018(sp)              // f4 = scale
        mul.s   f0, f0, f4                  // f0 = width of space, scaled
        lw      a1, 0x000C(sp)              // a1 = X position
        mtc1    a1, f2                      // f2 = X position
        add.s   f2, f0, f2                  // f2 = new X position
        mfc1    a1, f2                      // a1 = new X position
        sw      a1, 0x000C(sp)              // store X position
        b       _loop                       // continue loop
        addiu   s1, s1, 0x0001              // s1 = next character
    }

    // @ Description
    // Scales a string if it is too long
    // @ Arguments
    // a0 - string object
    // a1 - max width
    // @ Returns
    // v0 - string object
    scope apply_max_width_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~

        // calculate length
        lw      t0, 0x0074(a0)              // t0 = image struct (first character)
        beqz    t0, _end                    // skip if no image struct
        sw      a1, 0x0068(a0)              // save max width value on string object
        lwc1    f0, 0x0058(t0)              // f0 = startX
        _loop_calc:
        lw      t1, 0x0008(t0)              // t1 = next character image struct
        bnezl   t1, _loop_calc              // if not the last character, keep looping
        or      t0, t1, r0                  // t0 = next character image struct
        lwc1    f2, 0x0018(t0)              // f2 = x scale
        lhu     t1, 0x0014(t0)              // t1 = width
        mtc1    t1, f4                      // f4 = width
        cvt.s.w f4, f4                      // f4 = width, fp
        mul.s   f2, f4, f2                  // f2 = actual width
        lwc1    f4, 0x0058(t0)              // f4 = startX of last char
        add.s   f2, f2, f4                  // f2 = endX
        sub.s   f4, f2, f0                  // f4 = endX - startX = width
        mtc1    a1, f6                      // a1 = maxWidth
        cvt.s.w f6, f6                      // f6 = maxWidth, fp
        div.s   f8, f6, f4                  // f8 = maxWidth / width (div.s takes 37 cycles, so do it early)
        c.lt.s  f6, f4                      // check if maxWidth < width
        bc1f    _end                        // if maxWidth >= width, then nothing needs to change so end
        nop

        // I'm lazy, so the fastest way is to call update_live_string_ with a new scale then update y scale after
        lwc1    f6, 0x0044(a0)              // f6 = original scale
        swc1    f6, 0x000C(sp)              // save original scale
        mul.s   f8, f8, f6                  // f8 = new X scale, adjusted per original scale
        mfc1    t0, f8                      // t0 = new X scale
        sw      r0, 0x0030(a0)              // clear pointer so string is recreated
        sw      r0, 0x0068(a0)              // clear max width to avoid infinite loop
        jal     update_live_string_         // v0 = new string object
        sw      t0, 0x0044(a0)              // update X scale in object

        lw      t0, 0x0008(sp)              // t0 = max width value
        sw      t0, 0x0068(v0)              // save max width value

        lw      t0, 0x0074(v0)              // t0 = image struct (first character)
        lw      t1, 0x000C(sp)              // t1 = original Y scale
        sw      t1, 0x0044(v0)              // update scale in object
        _loop_update:
        sw      t1, 0x001C(t0)              // update Y scale
        lw      t0, 0x0008(t0)              // t0 = next character
        bnez    t0, _loop_update            // if more characters, keep looping
        or      a0, v0, r0                  // a0 = new string object

        _end:
        or      v0, a0, r0                  // v0 = string object
        lw      ra, 0x0004(sp)              // restore registers
        jr      ra
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Creates an array of addresses at the specified location given a base address and offset array.
    // @ Arguments
    // a0 - base RAM address
    // a1 - address of offset array
    // a2 - size of offset array
    // a3 - RAM address to start the array
    scope create_address_array_: {
        lw      at, 0x0000(a1)               // at = offset
        addu    at, a0, at                   // at = address (base address + offset)
        sw      at, 0x0000(a3)               // save address
        addiu   a2, a2, -0x0001              // a2 = a2 - 1
        beqz    a2, _end                     // if no more items in array, skip to end
        addiu   a1, a1, 0x0004               // a1 = next offset address
        b       create_address_array_        // increment and loop
        addiu   a3, a3, 0x0004               // a3 = next array address

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This is a helper for draw_string functions.
    // When used as the routine, the string will check its pointer for updates and redraw the string accordingly.
    scope update_live_string_: {
        // a0 = object struct address
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        or      v0, a0, r0                  // v0 = object address

        lw      t0, 0x004C(a0)              // t0 = string_type
        andi    t2, t0, 0x0001              // t2 = 1 if pointer, 0 if not
        srl     t0, t0, 0x0001              // t0 = 1 if number, 0 if not
        beqz    t0, _not_number             // if not a number, skip treating as number
        nop

        lw      t0, 0x0030(a0)              // t0 = current value displayed
        lw      t1, 0x0034(a0)              // t1 = pointer to value
        beqz    t1, _compare_number         // if pointer is 0, don't read!
        nop
        bnezl   t2, pc() + 8                // if t2 = 1, then t1 is a pointer
        lw      t1, 0x0000(t1)              // so use it to get value
        beqz    t1, _compare_number         // if pointer is 0, don't read!
        nop
        lw      t1, 0x0000(t1)              // t1 = new (maybe) value
        lw      t2, 0x0050(a0)              // t2 = amount to adjust
        addu    t1, t1, t2                  // t1 = new (maybe) value, adjusted
        _compare_number:
        beq     t0, t1, _end                // if still showing the correct value, skip
        nop
        b       _destroy
        nop

        _not_number:
        lw      t0, 0x0030(a0)              // t0 = current RAM address of string
        lw      t1, 0x0034(a0)              // t1 = pointer to string
        beqz    t1, _compare_text           // if pointer is 0, don't read!
        nop
        bnezl   t2, pc() + 8                // if t2 = 1, then t1 is a pointer
        lw      t1, 0x0000(t1)              // so use it to get value
        _compare_text:
        beq     t0, t1, _end                // if still showing the correct string, skip
        nop

        _destroy:
        OS.save_registers()

        jal     DESTROY_OBJECT_             // destroy the object
        nop

        or      v0, r0, a0

        // save possible object reference address for use after draw_string_
        lw      a0, 0x0010(sp)              // a0 = original object address
        lw      a1, 0x0054(a0)              // a1 = address storing object reference
        addiu   sp, sp, -0x0020             // allocate some more stack space
        sw      a1, 0x0004(sp)              // save object reference
        lw      t0, 0x007C(v0)              // t0 = current display value
        sw      t0, 0x0008(sp)              // save current display value

        li      t1, display_order_room
        lw      t2, 0x0000(t1)              // t2 = current display_order_room
        sw      t2, 0x000C(sp)              // save display_order_room
        lw      t2, 0x0060(a0)              // t2 = display_order_room
        sw      t2, 0x0000(t1)              // update display_order_room

        li      t1, display_order_group
        lw      t2, 0x0000(t1)              // t2 = current display_order_group
        sw      t2, 0x0010(sp)              // save display_order_group
        lw      t2, 0x0064(a0)              // t2 = display_order_group
        sw      t2, 0x0000(t1)              // update display_order_group

        lw      t0, 0x0018(v0)              // t0 = REGISTER_OBJECT_ROUTINE_ info block
        sw      t0, 0x0014(sp)              // save info block

        lw      t0, 0x0068(v0)              // t0 = max width value
        sw      t0, 0x0018(sp)              // save max width

        lbu     a0, 0x000D(v0)              // a0 = room
        lbu     a1, 0x000C(v0)              // a1 = group
        lw      a2, 0x0034(v0)              // a2 = pointer
        lw      a3, 0x0014(v0)              // a3 = routine
        lw      s1, 0x0058(v0)              // s1 = ulx
        lw      s2, 0x003C(v0)              // s2 = uly
        lw      s3, 0x0040(v0)              // s3 = color
        lw      s4, 0x0044(v0)              // s4 = scale
        lw      s5, 0x0048(v0)              // s5 = alignment
        lw      s6, 0x004C(v0)              // s6 = string_type
        lw      s7, 0x0050(v0)              // s7 = number adjust amount
        jal     draw_string_
        lw      t8, 0x005C(v0)              // t8 = blur

        lw      a1, 0x0004(sp)              // a1 = address storing object reference
        bnezl   a1, pc() + 8                // if there is an address, update with new object address
        sw      v0, 0x0000(a1)              // update reference to the recreated object
        sw      a1, 0x0054(v0)              // update address storing object reference
        lw      t0, 0x0008(sp)              // t0 = display value
        sw      t0, 0x007C(v0)              // update display value

        sw      v0, 0x0008(sp)              // save reference so this routine returns the new address in v0

        li      t1, display_order_room
        lw      t2, 0x0000(t1)              // t2 = current display_order_room
        sw      t2, 0x0060(v0)              // t2 = display_order_room
        lw      t2, 0x000C(sp)              // load saved display_order_room
        sw      t2, 0x0000(t1)              // restore display_order_room

        li      t1, display_order_group
        lw      t2, 0x0000(t1)              // t2 = current display_order_group
        sw      t2, 0x0064(v0)              // t2 = display_order_group
        lw      t2, 0x0010(sp)              // load saved display_order_group
        sw      t2, 0x0000(t1)              // restore display_order_group

        lw      t0, 0x0014(sp)              // t0 = REGISTER_OBJECT_ROUTINE_ info block
        beqz    t0, _check_max_width        // if 0, skip
        nop
        or      a0, v0, r0                  // a0 = object
        lw      a1, 0x001C(t0)              // a1 = routine
        lbu     a2, 0x0014(t0)              // a2 = ?
        lw      a3, 0x0010(t0)              // a3 = REGISTER_OBJECT_ROUTINE_ group
        jal     REGISTER_OBJECT_ROUTINE_
        addiu   sp, sp, -0x0030
        addiu   sp, sp, 0x0030

        _check_max_width:
        lw      a1, 0x0018(sp)              // a1 = max width value
        beqz    a1, _finish                 // if max width not set, skip
        lw      a0, 0x0008(sp)              // v0 = string object
        jal     apply_max_width_
        nop

        _finish:
        addiu   sp, sp, 0x0020              // deallocate stack space

        OS.restore_registers()

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // This is a helper for draw_grid_.
    // When used as the routine, the grid will check its pointer for updates and redraw the grid accordingly.
    scope update_live_grid_: {
        // a0 = object struct address
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra

        lw      t0, 0x0030(a0)              // t0 = current pointer to RAM address of image footer struct
        lw      t1, 0x0034(a0)              // t1 = pointer to pointer to RAM address of image footer struct
        bnezl   t1, pc() + 8                // don't read if 0!
        lw      t1, 0x0000(t1)              // t1 = new pointer to RAM address of image footer struct
        beq     t0, t1, _end                // if still showing the correct grid, skip
        nop

        _destroy:
        OS.save_registers()

        jal     DESTROY_OBJECT_             // destroy the object
        nop

        or      v0, r0, a0
        lbu     a0, 0x000D(v0)              // a0 = room
        lbu     a1, 0x000C(v0)              // a1 = group
        lw      a2, 0x0034(v0)              // a2 = pointer
        lw      a3, 0x0014(v0)              // a3 = routine
        lw      s1, 0x0058(v0)              // s1 = ulx
        lw      s2, 0x003C(v0)              // s2 = uly
        lw      s3, 0x0040(v0)              // s3 = color
        lw      s4, 0x0044(v0)              // s4 = palette
        lw      s5, 0x0048(v0)              // s5 = number of images in grid
        lw      s6, 0x004C(v0)              // s6 = max columns
        lw      s7, 0x0050(v0)              // s7 = padding
        lw      s0, 0x0054(v0)              // s0 = image type flags
        jal     draw_texture_grid_
        nop

        OS.restore_registers()

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Sets the display of a linked list of display items we call a room
    // @ Arguments
    // a0 - room id
    // a1 - hide? 1 = hide, 0 = show
    scope toggle_room_display_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        li      t0, ROOM_TABLE             // t0 = start of room head list
        sll     a0, 0x0002                  // a0 = offset in room head list
        addu    a0, t0, a0                  // a0 = address of first object's address in given room
        lw      a0, 0x0000(a0)              // a0 = first object's address in given room
        beqz    a0, _end                    // if no object, end
        nop
        _loop:
        sw      a1, 0x007C(a0)              // update first object
        lw      a0, 0x0010(a0)              // a0 = next object
        bnez    a0, _loop                   // if there is another object ahead, loop
        nop

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Sets the display of a linked list of display items we call a group
    // @ Arguments
    // a0 - group id
    // a1 - hide? 1 = hide, 0 = show
    scope toggle_group_display_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        li      t0, GROUP_TABLE             // t0 = start of group head list
        sll     a0, 0x0002                  // a0 = offset in group head list
        addu    a0, t0, a0                  // a0 = address of first object's address in given group
        lw      a0, 0x0000(a0)              // a0 = first object's address in given group
        beqz    a0, _end                    // if no object, end
        nop
        _loop:
        sw      a1, 0x007C(a0)              // update first object
        lw      a0, 0x0004(a0)              // a0 = next object
        bnez    a0, _loop                   // if there is another object ahead, loop
        nop

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // This hook is right before the screen is run, after all setup.
    // It is the perfect place to append our own custom objects for rendering.
    scope setup_: {
        OS.patch_start(0x000073B4, 0x800067B4)
        jal     setup_
        nop
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        OS.save_registers()                 // free up all registers

        // update stick every frame
        register_routine(Joypad.update_stick_)

        jal     FPS.setup_
        nop

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current screen

        // 1P
        li      t1, SinglePlayerModes.singleplayer_mode_flag       // t1 = Single Player Mode flag address
        lw      t1, 0x0000(t1)              // t1 = 1 if bonus 3
        beqz    t1, _vs_check               // if not multiman or allstar modes, skip
        nop
        addiu   t2, r0, 0x0004              // Remix 1p Flag
        beq     t2, t1, _vs_check           // if Remix 1p, skip
        nop


        lli     t1, 0x0077                  // t1 = 1P mode screen_id
        beq     t0, t1, _multiman           // if (screen_id = multiman mode/allstar), jump to _multiman mode
        nop

        // VS
        _vs_check:
        lli     t1, 0x0016                  // t1 = vs mode screen_id
        beq     t0, t1, _vs                 // if (screen_id = vs mode), jump to _vs
        nop

        // CSS
        // screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t1, t0, 0x0010              // t1 = 1 if not CSS
        bnez    t1, _low_screens            // if (screen_id != css), go to _low_screens
        nop
        slti    t1, t0, 0x0015              // t1 = 1 if CSS
        bnez    t1, _css                    // if (screen_id = css), go to _css
        nop

        // SSS
        lli     t1, 0x0015                  // t1 = sss screen_id
        beq     t0, t1, _sss                // if (screen_id = sss mode), jump to _sss
        nop

        // VS Results
        lli     t1, 0x0018                  // t1 = vs results screen_id
        beq     t0, t1, _vs_results         // if (screen_id = vs results mode), jump to _vs_results
        nop

        // Training
        lli     t1, 0x0036                  // t1 = training screen_id
        beq     t0, t1, _training           // if (screen_id = training), jump to _training
        nop

        // Options
        lli     t1, 0x0039                  // t1 = options screen_id
        beq     t0, t1, _options            // if (screen_id = options), jump to _options
        nop

        // Bonus
        lli     t1, 0x0035                  // t1 = bonus 1/2 screen_id
        beq     t0, t1, _bonus              // if (screen_id = bonus), jump to _bonus
        nop

        _low_screens:
        // Mode Select
        lli     t1, 0x0007                  // t1 = Mode Select screen_id
        beq     t0, t1, _mode_select        // if (screen_id = Mode Select), jump to _mode_select
        nop

        // 1P Pose
        lli     t1, 0x000E                  // t1 = 1P player vs cpu pose screen_id
        beq     t0, t1, _1p_pose            // if (screen_id = 1p pose), jump to _1p_pose
        nop

        // VS Game Mode
        lli     t1, 0x0009                  // t1 = VS Game Mode screen_id
        beq     t0, t1, _vs_game_mode       // if (screen_id = VS Game Mode), jump to _vs_game_mode
        nop

        // VS Options Item Switch
        lli     t1, 0x000B                  // t1 = VS Options Item Switch screen_id
        beq     t0, t1, _item_switch        // if (screen_id = VS Options Item Switch), jump to _item_switch
        nop

        // Title
        // screen_id = 0x1 AND first file loaded = 0xA7
        lli     t1, 0x0001                  // t1 = Title screen (shared with other screens - at least 1p mode battle)
        bne     t0, t1, _end                // if (screen_id != TITLE), skip
        nop
        jal     Item.clear_active_custom_items_ // clear custom items to prevent crash during intro/demo
        nop
        jal     GFXRoutine.port_override.clear_gfx_override_table_ // clear gfx override that franklin badge uses
        nop
        li      a0, Global.files_loaded     // ~
        lw      a0, 0x0000(a0)              // a0 = address of loaded files list
        lw      a0, 0x0000(a0)              // a0 = first loaded file
        lli     t1, 0x00A7                  // t1 = 0xA7
        beq     a0, t1, _title              // if (first file loaded = 0xA7 Hole Image), jump to _title
        lli     t1, 0x004F                  // t1 = 0x4F
        beq     a0, t1, _end                // if (first file loaded = 0x4F Continue Image), skip to end (continue screen)
        lli     t1, 0x0027                  // t1 = 0x27
        // debug transitions load as screen 1 with files 0x27 - 0x33 loaded first, so if not those files, assume 1p
        // note files 0x27 and 0x2F were not originally used in the transition table at 800D5D60 but they have been restored in Transitions.asm
        blt     a0, t1, _1p                 // if (first file loaded < 0x28), skip to 1p
        lli     t1, File.TRANSITION_SMASH_LOGO
        beq     a0, t1, _end                // if (first file loaded = new transition), skip to end (debug screen transition tests)
        lli     t1, 0x0033                  // t1 = 0x33
        ble     a0, t1, _end                // if (first file loaded between 0x28 and 0x33), skip to end (debug screen transition tests)
        nop

        _1p:
        jal     BGM.setup_                  // load font file if necessary for music titles
        nop
        jal     InputDisplay.setup_
        nop
        jal     Hitbox.setup_
        nop
        jal     ZCancel.setup_
        nop
        jal     ComboMeter.setup_              // Setup the Combo Meter
        nop

        _end:
        OS.restore_registers()              // restore all registers

        lui     a0, 0x8004                  // original line 1
        jal     0x80005DA0                  // original line 2
        addiu   a0, a0, 0x65F8              // original line 3

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        _multiman:
        jal     SinglePlayerModes.setup_    // Setup the KO counter
        nop
        jal     ComboMeter.setup_              // Setup the Combo Meter
        nop

        b       _end
        nop

        _vs:
        jal     ComboMeter.setup_              // Setup the Combo Meter
        nop

        // Collect VS stats
        li      t1, VsStats.player_count    // t1 = address of number of players
        sb      r0, 0x0000(t1)              // Set player_count to 0
        register_routine(VsStats.run_collect_)

        jal     TwelveCharBattle.game_setup_ // Setup 12cb functionality
        nop
        jal     Item.clear_active_custom_items_
        nop
        jal     GFXRoutine.port_override.clear_gfx_override_table_
        nop
        jal     BGM.setup_                  // load font file if necessary for music titles
        nop
        jal     InputDisplay.setup_
        nop
        jal     Hitbox.setup_
        nop
        jal     ZCancel.setup_
        nop

        b       _end
        nop

        _css:
        // Always clear 1P practice active flag
        li      t9, Practice_1P.practice_active // t9 = practice flag location
        sw      r0, 0x0000(t9)              // set state inactive
        li      a0, TwelveCharBattle.twelve_cb_flag
        lw      a0, 0x0000(a0)              // a0 = 1 if 12cb mode, 0 otherwise
        beqz    a0, _normal_css             // if not 12cb, then do normal css setup
        nop
        jal     TwelveCharBattle.setup_
        addu    a0, r0, t0                  // a0 = screen_id
        jal     Hitbox.setup_
        nop
        b       _end
        nop

        _normal_css:
        jal     CharacterSelect.setup_
        addu    a0, r0, t0                  // a0 = screen_id
        jal     Item.clear_active_custom_items_
        nop
        jal     GFXRoutine.port_override.clear_gfx_override_table_
        nop
        jal     Hitbox.setup_
        nop

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x0011                  // t1 = 1p CSS screen_id
        beq     t0, t1, _1p_css             // if 1p CSS, do setup


        lli     t1, 0x0013                  // t1 = Bonus 1 screen_id
        beq     t0, t1, _bonus_css          // if Bonus 1, do setup
        lli     t1, 0x0014                  // t1 = Bonus 2 screen_id
        bne     t0, t1, _end                // if not Bonus 1/2, end
        nop

        _bonus_css:
        jal     Bonus.setup_
        nop

        b       _end
        nop

        _1p_css:
        jal     SinglePlayerEnemy.setup_
        nop

        b       _end
        nop

        _sss:
        jal     Stages.setup_
        nop

        b       _end
        nop

        _vs_results:
        jal     VsStats.setup_
        nop
        jal     Item.clear_active_custom_items_
        nop
        jal     GFXRoutine.port_override.clear_gfx_override_table_
        nop
        jal     Hitbox.setup_
        nop

        b       _end
        nop

        _training:
        jal     Training.setup_
        nop
        jal     Item.clear_active_custom_items_
        nop
        jal     Item.start_with_item_
        nop
        jal     InputDisplay.setup_
        nop
        jal     GFXRoutine.port_override.clear_gfx_override_table_
        nop
        // jal     CharacterSelectDebugMenu.DpadFunctions.clear_settings_for_training_
        // nop
        // jal     CharacterSelectDebugMenu.DpadControl.force_settings_for_training_
        // nop
        jal     Hitbox.setup_
        nop
        jal     ZCancel.setup_
        nop

        b       _end
        nop

        _options:
        jal     Toggles.setup_
        nop

        b       _end
        nop

        _bonus:
        lui     v0, 0x800A
        jal     CharacterSelectDebugMenu.clear_debug_menu_settings_for_1p_
        lbu     v0, 0x4AE3(v0)              // v0 = port of human player

        jal     InputDisplay.setup_
        nop
        jal     Hitbox.setup_
        nop
        jal     ZCancel.setup_
        nop

        b       _end
        nop

        _mode_select:
        li      t0, SinglePlayerModes.page_flag // safeguard clear 1P page_flag if on from Main menu...
        sw      r0, 0x0000(t0)                  // ...this is to handle non-standard cases of leaving Remix 1P (e.g. Credits)
        jal     Toggles.mode_select_setup_
        nop

        _1p_pose:
        jal     GFXRoutine.port_override.clear_gfx_override_table_
        nop

        b       _end
        nop

        _vs_game_mode:
        jal     TwelveCharBattle.vs_game_mode_setup_
        nop

        b       _end
        nop

        _item_switch:
        jal     Item.item_switch_setup_
        nop

        b       _end
        nop

        _title:
        jal     Boot.draw_version_on_title_screen_
        nop

        b       _end
        nop
    }

}

} // __RENDER__
