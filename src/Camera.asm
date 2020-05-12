// Camera.asm
if !{defined __CAMERA__} {
define __CAMERA__()
print "included Camera.asm\n"


// @ Description
// This file includes Camera related toggles and fixes.

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

// 80131470 - camera

scope Camera {

    // @ Description
    // This replaces a call to Global.get_random_int. Usually, when 0 is returned, the cinematic entry
    // does not play. Here, v0 is always set to 0. 
    scope disable_cinematic_: {
        OS.patch_start(0x0008E250, 0x80112A50)
        j       disable_cinematic_
        nop
        _disable_cinematic_return:
        OS.patch_end()

        jal     Global.get_random_int_      // original line 1
        lli     a0, 0x0003                  // original line 2
        Toggles.guard(Toggles.entry_disable_cinematic_camera, _disable_cinematic_return)

        lli     v0, OS.FALSE                // v0 = not cinematic camera
        j       _disable_cinematic_return   // return
        nop

    }

    // @ Description
    // Allows 360 control over the camera by changing the floats to check against
    // inspired by [Gaudy (Emudigital)] 
    OS.patch_start(0x000AC494, 0x80130C94)
    float32 100                             // x limit
    dw 0x39AE9681                           // x increment
    float32 -100                            // x limit
    float32 100                             // y limit
    dw 0x39AE9681                           // y increment
    float32 -100                            // y limit
    OS.patch_end()
    
    // @ Description
    // Subroutine which freezes the camera on the World 1-1 stage.
    // Replaces a JAL to subroutine to 0x80018FBC which is used to update the camera's position.
    scope frozen_camera_: {
    
        OS.patch_start(0x87DA8, 0x8010C5A8)
        jal     frozen_camera_
        OS.patch_end()
        
        OS.patch_start(0x87E58, 0x8010C658)
        jal     frozen_camera_
        OS.patch_end()
        
        OS.patch_start(0x87EC8, 0x8010C6C8)
        jal     frozen_camera_
        OS.patch_end()
        
        OS.patch_start(0x880AC, 0x8010C8AC)
        jal     frozen_camera_
        OS.patch_end()
        
        // Function
        addiu   sp, sp,-0x0018             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // store t0 - t2, ra
        
        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t0 = match_info
        lbu     t0, 0x0001(t0)              // t0 = stage id
        li      t1, frozen_world1           // t1 = frozen camera parameters for WORLD1
        ori     t2, r0, Stages.id.WORLD1    // t2 = id.WORLD1
        beq     t0, t2, _frozen             // use frozen camera if stage = WORLD1
        nop
		li      t1, Toggles.entry_hazard_mode
        lw      t1, 0x0004(t1)              // t1 = hazard_mode (hazards disabled when t1 = 1 or 3)
        andi    t1, t1, 0x0001              // t1 = 1 if hazard_mode is 1 or 3, 0 otherwise
        bnez    t1, _normal                // if hazard_mode enabled, skip frozen camera for flat zones
        nop
        li      t1, frozen_flat_zone_2      // t1 = frozen camera parameters for FLAT_ZONE_2
		ori     t2, r0, Stages.id.FLAT_ZONE_2 // t1 = id.FLAT_ZONE_2
        beq     t0, t2, _frozen             // use frozen camera if stage = FLAT_ZONE_2
        nop
		li      t1, frozen_flat_zone      // t1 = frozen camera parameters for FLAT_ZONE
		ori     t2, r0, Stages.id.FLAT_ZONE // t1 = id.FLAT_ZONE_2
        beq     t0, t2, _frozen             // use frozen camera if stage = FLAT_ZONE
        nop
        
        _normal:
        // if we reach this point, update camera as normal
        jal     0x80018FBC                  // original JAL
        nop
        b       _end                        // end subroutine
        nop
        
		_frozen:
        // if we reach this point, update camera position with fixed camera parameters
        // t1 = frozen camera parameters
		li      t0, struct.pointer          // ~
        lw      t0, 0x0000(t0)              // t0 = camera struct
        lw      t2, 0x0000(t1)              // ~
        sw      t2, struct.x(t0)            // update camera x
        lw      t2, 0x0004(t1)              // ~
        sw      t2, struct.y(t0)            // update camera y
        lw      t2, 0x0008(t1)              // ~
        sw      t2, struct.z(t0)            // update camera z
        lw      t2, 0x000C(t1)              // ~
        sw      t2, struct.focal_x(t0)      // update camera focal x
        lw      t2, 0x0010(t1)              // ~
        sw      t2, struct.focal_y(t0)      // update camera focal y
        lw      t2, 0x0014(t1)              // ~
        sw      t2, struct.focal_z(t0)      // update camera focal z
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // load t0 - t2, ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Frozen camera parameters for WORLD1
    frozen_world1:
    float32 0                               // camera x position
    float32 -100                            // camera y position
    float32 6600                            // camera z position
    float32 0                               // camera focal x position
    float32 -100                            // camera focal y position
    float32 0                               // camera focal z position
	
	// @ Description
    // Frozen camera parameters for FLAT_ZONE_2
    frozen_flat_zone_2:
    float32 0                               // camera x position
    float32 0                               // camera y position
    float32 8000                            // camera z position
    float32 0                               // camera focal x position
    float32 0                            // camera focal y position
    float32 0                               // camera focal z position
	
	// @ Description
    // Frozen camera parameters for FLAT_ZONE
    frozen_flat_zone:
    float32 0                               // camera x position
    float32 -100                            // camera y position
    float32 6600                            // camera z position
    float32 0                               // camera focal x position
    float32 -100                            // camera focal y position
    float32 0                               // camera focal z position
    
    // @ Description
    // camera struct constants
    scope struct {
        constant pointer(0x80131460)
        constant x(0xC4)
        constant y(0xC8)
        constant z(0xCC)
        constant focal_x(0xD0)
        constant focal_y(0xD4)
        constant focal_z(0xD8)
    }
}

} // __CAMERA__
