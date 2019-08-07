// Spawn.asm
if !{defined __SPAWN__} {
define __SPAWN__()
print "included Spawn.asm\n"

// @ Description
// This file alters spawn position for different circumstances such as Neutral Spawns.

include "Global.asm"
include "OS.asm"
//include "Toggles.asm"
include "Stages.asm"

scope Spawn {

    // @ Description
    // hook to load respawn point. This fixes the lack of respawn points on the beta stages.
    scope load_respawn_point_: {
        OS.patch_start(0x000780B0, 0x800FC8B0)
        j       load_respawn_point_
        nop
        _load_respawn_point_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // save registers

        // this block gets stage_id (mode dependent)
        li      at, Global.match_info       // ~
        lw      at, 0x0000(at)              // at = address of match info
        lbu     at, 0x0001(at)              // at = stage_id

        // this block checks for dream land beta 1 and 2
        lli     t0, Stages.id.DREAM_LAND_BETA_1
        beq     t0, at, _fix
        nop
        lli     t0, Stages.id.DREAM_LAND_BETA_2
        beq     t0, at, _fix
        nop

        _original:
        lh      t8, 0x0002(t7)              // original line 1
        mtc1    r0, f16                     // original line 2
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _load_respawn_point_return  // return
        nop

        _fix:
        sw      r0, 0x0000(a1)              // update x
        li      t0, 0x451DE000              // t0 = (float) 2526, from dream land
        sw      t0, 0x0004(a1)              // update y
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // scrap the rest of the function
        nop
    }
    
    // Currently only used for temporary How to Play fix
    scope load_spawn_: {
        // a0 holds player
        // a1 holds table
        // 0x0000(a1) holds x
        // 0x0004(a1) holds y

        OS.patch_start(0x00076764, 0x800FAF64)
        j       Spawn.load_spawn_
        nop
        _load_spawn_return:
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      v0, 0x0018(sp)              // ~
        sw      ra, 0x001C(sp)              // save registers

        li      t0, Global.vs.stage         // ~
        lbu     t0, 0x0000(t0)              // get the current stage
        lli     t1, Stages.id.HOW_TO_PLAY   // if the current stage is not how to play
        bne     t0, t1, _original_method    // use original function for spawning
        nop

        _new_method:
        li      t0, how_to_play_spawns      // t0 = spawn table
        sll     t1, a0, 0x0003              // t1 = spawn table offset
        addu    t0, t0, t1                  // t1 = spawn table + offset      
        lw      t1, 0x0000(t0)              // t1 = xpos
        sw      t1, 0x0000(a1)              // update xpos
        lw      t1, 0x0004(t0)              // t1 = xpos
        sw      t1, 0x0004(a1)              // update ypos
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return (we scrap the original function)

        _original_method:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        lui     t6, 0x8013                  // original line 1
        lw      t6, 0x1368(t6)              // original line 2
        j       _load_spawn_return          // use in game method for everything but VS. and training
        nop

        how_to_play_spawns:
        // float32 xpos, ypos
        float32  0660,  0000
        float32  1440,  0000
        float32 -0660,  0000
        float32 -1440,  0000
    }

} // __SPAWN__