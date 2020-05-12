// DL.asm
if !{defined __DL__} {
define __DL__()
print "included DL.asm\n"


// @ Description
// This file defines custom display lists.
// Display lists are clustered at the beginning of extension RAM to avoid console crashes.

include "RCP.asm"
include "OS.asm"

scope DL {
    // @ Description
    // Custom display list goes here.
    OS.align(16)
    display_list:
    fill 0x20000

    display_list_info:
    RCP.display_list_info(display_list, 0x20000)

    OS.align(16)
    // @ Description
    // Display list for portraits
    portrait_display_list:
    fill 0x8000

    portrait_display_list_info:
    RCP.display_list_info(portrait_display_list, 0x8000)

    OS.align(16)
    // @ Description
    // Display list for variant indicators
    // The size can probably be reduced further
    variant_indicator_display_list:
    fill 0x1000

    variant_indicator_display_list_info:
    RCP.display_list_info(variant_indicator_display_list, 0x1000)
}

} // __DL__
