// for toggles related to Japanese features

// Japan.asm
if !{defined __JAPAN__} {
define __JAPAN__()
print "included Japan.asm\n"

// @ Description
// This file expands the stage select screen.

include "Color.asm"
include "FGM.asm"
include "Global.asm"
include "OS.asm"
include "Overlay.asm"
include "String.asm"
include "Texture.asm"

// @ Description
    // Toggle for Japanese Style Hitlag.
    // The hitlag percentage is identical for the American and Japanese versions, it is present at 
    // 8012FF50. However, the calculation changes very slightly in a way that increases hitlag in the
    // US Version, thus allowing for greater DI
    scope japanese_hitlag_: {
        OS.patch_start(0x000659D0, 0x800EA1D0)
        j       japanese_hitlag_
        nop
        japanese_hitlag_end_:
        OS.patch_end()
        
        
        lui     at, 0x40A0                  // original line 1
        mtc1    at, f16                     // original line 2
        Toggles.guard(Toggles.entry_japanese_hitlag, japanese_hitlag_end_)
        lui     at, 0x4080                  // Japanese style, this adds less to the hitlag calculation thus decreasing hitlag
        mtc1    at, f16                     // original line 2
        
        j      japanese_hitlag_end_          // return
        nop
    }
    
// @ Description
    // Toggle for the Momentum Sliding Glitch present in the Japanese version.
    // A very straightforward fix was added to the international version of Smash
    // Duing a momentum slide input it checks the current velocity of the character against character's max run speed
    // If current velocity is higher, then velocity is overwritten to max run speed
    // 8013F14C is where it stores the updated x velocity
    // Player's current velocity is stored at 8027E988
    // f4 = current x velocity
    // f0 = max run speed
    scope momentum_slide_: {
        OS.patch_start(0x000B9B74, 0x8013F134)
        j     momentum_slide_
        nop
        momentum_slide_end_:
        OS.patch_end()
        
        lwc1    f4, 0x0060(v1)              // original line 1
        lwc1    f0, 0x0030(t6)              // original line 1
        Toggles.guard(Toggles.entry_momentum_slide, momentum_slide_end_)
        j       0x8013F150
        nop
 
        _end:
        j       momentum_slide_end_                          // return
        nop
    }