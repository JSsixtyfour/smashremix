// ResultsScreen.asm (Fray)
// thanks to tehzz for providing documentation
// this file is most likely temporary

include "os.asm"

scope ResultsScreen {
    pushvar origin, base
    // change FOX to FALCO
    origin  0x158658
    float32 170                             // name rx
    origin  0x158694
    dw string_falco                         // pointer to name string 
    origin  0x1586C4
    float32 30                              // name lx
    
    // change C.FALCON to GANONDORF
    origin  0x158670
    float32 185                             // name rx
    origin  0x1586AC
    dw string_ganondorf                     // pointer to name string
    origin  0x1586DC
    float32 20                              // name lx
    origin  0x15870C
    float32 0.6                             // name x scaling
    
    // change LINK to YOUNG LINK
    origin  0x158668
    float32 185                             // name rx
    origin  0x1586A4
    dw string_ylink                         // pointer to name string
    origin  0x1586D4
    float32 20                              // name lx
    origin  0x158704
    float32 0.65                            // name x scaling
    pullvar base, origin
    
    // insert falco's text name
    string_falco:
    db  "FALCO"; db 0x00
    OS.align(4)
    string_ganondorf:
    // insert ganondorf's text name
    db  "GANONDORF"; db 0x00
    OS.align(4)
    string_ylink:
    db  "YOUNG LINK"; db 0x00
    OS.align(4)
}