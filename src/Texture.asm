// Texture.asm
if !{defined __TEXTURE__} {
define __TEXTURE__()
print "included Texture.asm\n"

include "OS.asm"

scope Texture {
    macro info(variable width, variable height) {
        dw width                            // 0x0000 - width of texture
        dw height                           // 0x0004 - height of texture
        dw pc() + 8                         // 0x0008 - pointer to image data
        dw 0x1000000 + pc() - 0x80380000 + 4// 0x000C - ROM address (base calculation)
    }
}

} // __TEXTURE__