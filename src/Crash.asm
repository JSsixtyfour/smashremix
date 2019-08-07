// Crash.asm
if !{defined __CRASH__} {
define __CRASH__()
print "included Crash.asm\n"

scope Crash {
    // @ Description
    // These patches disable button checks for the debugger by changing the contents of a0 from 
    // random button masks to none.
    OS.patch_start(0x00024088, 0x80023488)
    lli     a0, 0x0000
    OS.patch_end()
    OS.patch_start(0x000240A0, 0x800234A0)
    lli     a0, 0x0000
    OS.patch_end()
    OS.patch_start(0x000240B8, 0x800234B8)
    lli     a0, 0x0000
    OS.patch_end()
    OS.patch_start(0x000240D0, 0x800234D0)
    lli     a0, 0x0000
    OS.patch_end()
    OS.patch_start(0x000240E8, 0x800234E8)
    lli     a0, 0x0000
    OS.patch_end()
}

} // __CRASH__