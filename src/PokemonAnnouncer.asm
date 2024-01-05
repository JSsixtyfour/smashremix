// PokemonAnnouncer.asm [bit]
if !{defined __POKEMON_ANNOUNCER__} {
define __POKEMON_ANNOUNCER__()
print "included PokemonAnnouncer.asm\n"

// @ Description
// This file contains various functions for the Pokemon Stadium Announcer.

include "OS.asm"
include "Stages.asm"

scope PokemonAnnouncer {    
    
    // POKEMON STADIUM ANNOUNCER

    // @ Description
    // Replace Game Set with "There goes the battle"
    scope there_goes_: {
        OS.patch_start(0x90530, 0x80114D30)
        j       there_goes_
        addiu   a0, a0, 0x36A4              // original line 1
        return:
        OS.patch_end()

        addiu   sp, sp, -0x0010
        sw      v0, 0x0004(sp)
        jal     toggle_announcer_
        nop
        beqz    v0, _goes
        lw      v0, 0x0004(sp)
        addiu   sp, sp, 0x0010
        

        // normal
        j       return
        addiu   a2, r0, 0x01E8

        _goes:
        addiu   sp, sp, 0x0010
        j       return
        addiu   a2, r0, 0x045B              // THERE GOES THE BATTLE
    }

    // @ Description
    // Gives enough time before transition for announcer THERE GOES THE BATTLE TO PLAY
    scope delay_: {
        OS.patch_start(0x90538, 0x80114D38)
        j       delay_
        nop
        return:
        OS.patch_end()

        addiu   sp, sp, -0x0010
        sw      v0, 0x0004(sp)
        jal     toggle_announcer_
        nop
        beqz    v0, _goes
        lw      v0, 0x0004(sp)
        addiu   sp, sp, 0x0010


        _normal:
        jal     0x80114B80                  // battle end routines, original line 1
        addiu   a3, r0, 0x005A              // original line 2, amount of delay
        j       return
        nop

        _goes:
        addiu   sp, sp, 0x0010
        jal     0x80114B80                  // battle end routines, original line 1
        addiu   a3, r0, 0x0080              // original line 2 modified, amount of delay increased
        j       return
        nop
    }

    // @ Description
    // Gives each pokemon an announcer call
    scope pokemon_name_: {
        OS.patch_start(0xE9C80, 0x8016F240)
        j       pokemon_name_
        lw      t6, 0x001C(sp)              // original line 1, loads item ID
        return:
        OS.patch_end()

        addiu   sp, sp, -0x0020
        sw      ra, 0x0008(sp)
        jal     toggle_announcer_
        sw      v0, 0x0014(sp)
        
        bnezl   v0, _normal
        lw      v0, 0x0014(sp)


        _pokemon:       
        sw      a0, 0x0004(sp)              // save a0
        sw      a2, 0x000C(sp)
        sw      a3, 0x0010(sp)
        sw      v1, 0x0018(sp)
        jal     announcer_main_
        addiu   a0, r0, NAME
        
        bnez    v0, _end                    // don't use if too soon
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // get pokemon fgm ID
        
        _end:
        lw      a0, 0x0004(sp)              // load a0 back in
        lw      a2, 0x000C(sp)
        lw      a3, 0x0010(sp)
        lw      ra, 0x0008(sp)
        lw      v0, 0x0014(sp)
        lw      v1, 0x0018(sp)
        addiu   sp, sp, 0x0020
        lw      t6, 0x001C(sp)              // original line 1, loads item ID
        j       return
        lui     t9, 0x8019                  // original line 2
        
        _normal:
        lw      ra, 0x0008(sp)
        addiu   sp, sp, 0x0020
        j       return
        lui     t9, 0x8019                  // original line 2
    }

    // @ Description
    // Plays announcer clip with a character is KO'd
    scope pokemon_ko_sounds_: {
        addiu   sp, sp, -0x0030
        sw      ra, 0x0020(sp)
        jal     toggle_announcer_
        sw      v0, 0x0014(sp)
        bnez    v0, _normal
        nop

        _pokemon: 
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)
        sw      a3, 0x0010(sp)
        sw      v1, 0x0018(sp)
        sw      t8, 0x001C(sp)
        sw      t9, 0x0024(sp)
        sw      t6, 0x0028(sp)
        
        jal     announcer_main_
        addiu   a0, r0, KO
        
        _play_fgm:
        jal     0x800269C0                  // play fgm
        addu    a0, v1, r0                  // get fgm ID
        
        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        lw      a2, 0x000C(sp)
        lw      a3, 0x0010(sp)
        
        lw      v1, 0x0018(sp)
        lw      t8, 0x001C(sp)
        lw      t9, 0x0024(sp)
        lw      t6, 0x0028(sp)
        
        
        _normal:
        lw      ra, 0x0020(sp)
        lw      v0, 0x0014(sp)
        addiu   sp, sp, 0x0030
        jr      ra
        nop
    }
    
//    // Announcer comment at the beginning of a match
//    scope opening_comment: {
//        OS.patch_start(0x8DC18, 0x80112418)
//        j       opening_comment
//        nop
//        _return:
//        OS.patch_end()
//
//        addiu   sp, sp, -0x0020
//        sw      a0, 0x0004(sp)
//        sw      a1, 0x0008(sp)
//        sw      a2, 0x000C(sp)
//        sw      a3, 0x0010(sp)
//        sw      ra, 0x0014(sp)
//        sw      v0, 0x0018(sp)
//        sw      v1, 0x001C(sp)
//        
//        li      a0, Global.match_info
//        lw      a0, 0x0000(a0)              // a0 = match info
//        lbu     a0, 0x0001(a0)              // a0 = current stage IpokD
//        lli     a1, Stages.id.POKEMON_STADIUM         // a1 = Stages.id
//        beq     a0, a1, _pokemon               // if current stage is Pokemon stadium, go 
//        lli     a1, Stages.id.POKEMON_STADIUM_2       // t9 = Stages.id
//        bne     a1, a0, _normal           // if current stage is other, then skip pokemon call
//        nop
//
//        _pokemon:
//        jal     Global.get_random_int_  // get random integer
//        addiu   a0, r0, 0x0003          // decimal 3 possible integers
//        
//        addiu   a0, r0, 0x479           // base number of set
//        
//        jal     0x800269C0                  // play fgm
//        addu    a0, a0, v0                  // get announcement ID by adding item ID to t9
//
//        _normal:
//        lw      a0, 0x0004(sp)
//        lw      a1, 0x0008(sp)
//        lw      a2, 0x000C(sp)
//        lw      a3, 0x0010(sp)
//        lw      ra, 0x0014(sp)
//        lw      v0, 0x0018(sp)
//        lw      v1, 0x001C(sp)
//        addiu   sp, sp, 0x0020
//        j       0x80112444
//        nop
//    }
    
    // Announcer comment at the beginning of a match
    scope opening_comment: {
        addiu   sp, sp, -0x0020
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)
        sw      a3, 0x0010(sp)
        sw      ra, 0x0014(sp)
        sw      v0, 0x0018(sp)
        sw      v1, 0x001C(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x0003          // decimal 3 possible integers
        
        addiu   a0, r0, 0x479           // base number of set
        
        jal     0x800269C0                  // play fgm
        addu    a0, a0, v0                  // get announcement ID by adding item ID to t9

        _normal:
        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        lw      a2, 0x000C(sp)
        lw      a3, 0x0010(sp)
        lw      ra, 0x0014(sp)
        lw      v0, 0x0018(sp)
        lw      v1, 0x001C(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // Sleep announcements
    scope sleep_announcement_: {
        OS.patch_start(0xC43EC, 0x801499Ac)
        j       sleep_announcement_
        sw      a0, 0x0028(sp)              // original line 2, save player object to stack
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        sw      a2, 0x0018(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        li      a2, sleep_flag
        addiu   a0, r0, 0x0001
        sw      a0, 0x0000(a2)      // set sleep flag
        
        _normal: 
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        lw      a2, 0x0018(sp)
        addiu   sp, sp, 0x0020
        lw      a0, 0x0028(sp)          // replace player object address
        j       return
        lw      t6, 0x0084(a0)          // original line 1, load player struct
    }
    
    // Announcer comment after a longer combo
    scope pokemon_combo_: {
        lli     t1, 0x000A                  // t1 = 10
        bne     t1, a0, _end                // if (hit count != 10) then don't play sound effect
        nop 
        lw      t1, 0x000C(t5)              // t1 = current combo count previously
        beq     t1, a0, _end                // if (hit count already is 10) then don't play sound effect (because we already did)
        nop                                 // ~
        
        addiu   sp, sp, -0x0030
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)
        sw      a2, 0x000C(sp)
        sw      a3, 0x0010(sp)
        sw      ra, 0x0014(sp)
        sw      t4, 0x0018(sp)
        sw      t5, 0x001C(sp)
        sw      v0, 0x0020(sp)
        sw      v1, 0x0024(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        li      a2, combo_calls
        addiu   a1, r0, 0x0001
        jal     announcer_main_
        addiu   a0, r0, STANDARD
        
        bnez    v0, _normal
        nop
        
        jal     0x800269C0               // play fgm
        addu    a0, v1, r0               // fgm number

        _normal:
        lw      a0, 0x0004(sp)
        lw      a1, 0x0008(sp)
        lw      a2, 0x000C(sp)
        lw      a3, 0x0010(sp)
        lw      ra, 0x0014(sp)
        lw      t4, 0x0018(sp)
        lw      t5, 0x001C(sp)
        lw      v0, 0x0020(sp)
        lw      v1, 0x0024(sp)
        addiu   sp, sp, 0x0030
        
        _end:
        jr      ra
        nop
    }
    
    // Damage and Knockback announcements
    scope hit_announcement_: {
        OS.patch_start(0xBBFE8, 0x801415A8)
        j       hit_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      ra, 0x0004(sp)
        
        jal     toggle_announcer_
        sw      v0, 0x0008(sp)
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a0, 0x0010(sp)
        sw      t9, 0x0014(sp)
        sw      a2, 0x0018(sp)
        sw      a1, 0x001C(sp)
        sw      a3, 0x001C(sp)
        sw      at, 0x0020(sp)
        lw      v0, 0x0008(sp)          // load v0 back in
        
        lwc1    f4, 0x07E0(v0)          // load knockback amount
        lui     a3, 0x42e6              // 115   
        mtc1    a3, f12  
        c.lt.s  f4, f12                 // check if knockback is high enough for a knockback call
        lui     a3, 0x431b              // 155
        bc1t    _damage
        mtc1    a3, f12  
        c.lt.s  f4, f12                 // check if knockback is high enough for a high knockback call
        nop
        bc1t    _mid
        nop
        
        _knockback_high:
        addiu   a0, r0, STANDARD
        li      a2, knockback_high_calls
        jal     announcer_main_
        addiu   a1, r0, 0x0012          // decimal 12 possible integers
        
        beq     r0, r0, _play
        nop

        _mid:
        li      a2, knockback_mid_calls
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0006          // decimal 6 possible integers
        
        beq     r0, r0, _play
        nop
        
        _damage:
        lw      a3, 0x07F0(v0)          // load damage amount
        beqz    a3, _end                // if no damage, go to end
        addiu   t0, r0, 0x01            // Fire hitbox
        
        lw      a2, 0x07F8(v0)          // load attack type
        beq     a2, t0, _fire                // if fire, do burn
        nop
        
        slti    t0, a3, 0x04            // if less than 4%, light damage
        bnez    t0, _little_damage
        nop
        
        slti    a3, a3, 0x12            // if less than 18%, don't do call
        bnez    a3, _end                // see above
        nop
        
        li      a2, Global.vs.elapsed
        lw      a2, 0x0000(a2)
        addiu   a0, r0, 0x360           // 9 seconds
        slt     a1, a2, a0              // if less than 9 seconds in, set a1 to 1
        beqz    a1, _regular_damage     // if 9 seconds have transpired, do a normal sound
        addiu   a0, r0, STANDARD
        
        li      a2, damage_early_call
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        beq     r0, r0, _play
        nop
        
        _regular_damage:
        li      a2, damage_calls
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0004          // decimal 4 possible integers
        
        beq     r0, r0, _play
        nop
        
        _fire:
        li      a2, burn_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        beq     r0, r0, _play
        nop
        
        _little_damage:
        li      a2, little_damage_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
         _play:
         bnez    v0, _end
         nop
         
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding in v1
        
        _end:
        lw      t9, 0x0014(sp)
        lw      v1, 0x000C(sp)
        lw      a0, 0x0010(sp)
        lw      a2, 0x0018(sp)
        lw      a1, 0x001C(sp)
        lw      at, 0x0020(sp)

        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0030
        lw      a3, 0x07E0(v0)          // original line 2
        j       return
        lw      a2, 0x07F0(v0)          // original line 1
    }
    
    // Damage and Knockback announcements
    scope throw_hit_announcement_: {
        OS.patch_start(0xC5BE4, 0x8014B1A4)
        j       throw_hit_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      ra, 0x0004(sp)
        
        jal     toggle_announcer_
        sw      v0, 0x0008(sp)
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        swc1    f4, 0x0010(sp)
        sw      t9, 0x0014(sp)
        sw      a1, 0x0020(sp)
        sw      a3, 0x0024(sp)
        swc1    f12, 0x0018(sp)
        
        lui     a2, 0x42f0              // 120   
        mtc1    a3, f4                  // move knockback to f4
        mtc1    a2, f12  
        c.lt.s  f4, f12                 // check if knockback is high enough for a knockback call
        lui     a2, 0x432f              // 175
        bc1t    _damage
        mtc1    a2, f12  
        c.lt.s  f4, f12                 // check if knockback is high enough for a high knockback call
        nop
        bc1t    _mid
        nop
        li      a2, knockback_high_calls
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0012          // decimal 12 possible integers
        
        beq     r0, r0, _play
        nop

        _mid:
        li      a2, knockback_mid_calls
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0006          // decimal 6 possible integers
        
        beq     r0, r0, _play
        nop
        
        _damage:
        lw      a3, 0x0080(sp)          // load damage amount
        beqz    a3, _end                // if no damage, go to end
        nop
        
        slti    t0, a3, 0x04            // if less than 4%, light damage
        bnez    t0, _little_damage
        nop
        
        slti    a3, a3, 0x12            // if less than 18%, don't do call
        bnez    a3, _end                // see above
        nop
        
        li      a2, damage_calls
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0004          // decimal 4 possible integers
        
        beq     r0, r0, _play
        nop
        
        _little_damage:
        li      a2, little_damage_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        _play:
        bnez    v0, _end                // if not meant to play, skip
        nop
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding in v1
        
        _end:
        lw      t9, 0x0014(sp)
        lw      v1, 0x000C(sp)
        lwc1    f4, 0x0010(sp)
        lwc1    f12, 0x0018(sp)
        lw      a1, 0x0020(sp)
        lw      a3, 0x0024(sp)

        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0030
        lw      a0, 0x0068(sp)          // original line 1
        j       return
        lw      a2, 0x0010(sp)          // original line 2
    }

    // Thunder announcement
    // Thunder announcement
    scope thunder_g_announcement_: {
        OS.patch_start(0xCCA04, 0x80151FC4)
        jal     thunder_announcement_
        sw      r0, 0x0010(sp)          // original line 2
        return:
        OS.patch_end()
    }
    scope thunder_a_announcement_: {   
        OS.patch_start(0xCCA44, 0x80152004)
        jal     thunder_announcement_
        sw      r0, 0x0010(sp)          // original line 2
        return:
        OS.patch_end()
    }    
        
    scope thunder_announcement_: {
        sw      a0, 0x0020(sp)          // original line 1
        
        addiu   sp, sp, -0x0010        
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        
        li      a2, thunder_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get fgm ID
        
        _end:
        lw      v1, 0x000C(sp) 
        
        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0010
        
        jr      ra
        lw      a0, 0x0020(sp)          // original line 2
    }
    
    // Quick Attack announcement
    scope quick_g_announcement_: {
        OS.patch_start(0xCD3F0, 0x801529B0)
        jal       quick_announcement_
        mtc1    r0, f0          // original line 1
        return:
        OS.patch_end()
    }
    scope quick_a_announcement_: {   
        OS.patch_start(0xCD43C, 0x801529FC)
        jal     quick_announcement_
        mtc1    r0, f0          // original line 1
        return:
        OS.patch_end()
    }    
        
    scope quick_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        
        li      a2, quick_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get fgm ID
        
        _end:
        lw      v1, 0x000C(sp) 
        
        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0020
        
        jr      ra
        lw      a0, 0x0020(sp)          // original line 2
    }
    
    // Charging announcement
    scope charging_announcement_: {
        OS.patch_start(0xE3848, 0x80168E08)
        j       charging_announcement_
        addiu   a1, a1, 0x9030          // original line 1
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      a1, 0x000C(sp)
        sw      a0, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      t1, 0x0018(sp)
        sw      t6, 0x001C(sp)

        li      a2, charge_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get fgm ID
        
        _end:
        lw      a0, 0x0014(sp)       
        lw      v1, 0x0010(sp)
        lw      a1, 0x000C(sp)
        lw      t1, 0x0018(sp)
        lw      t6, 0x001C(sp)
        
        _normal:
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0020
        j       return
        or      a3, r0, r0          // original line 2
    }
    
    // Sing announcement
    scope sing_announcement_: {
        OS.patch_start(0x7D900, 0x80102100)
        j       sing_announcement_
        sw      s0, 0x0018(sp)          // original line 2
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      a1, 0x000C(sp)
        sw      a2, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      t1, 0x0018(sp)
        sw      t6, 0x001C(sp)

        li      a2, sing_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get fgm ID
        
        _end:      
        lw      v1, 0x0010(sp)
        lw      a2, 0x0014(sp)
        lw      a1, 0x000C(sp)
        lw      t1, 0x0018(sp)
        lw      t6, 0x001C(sp)
        
        _normal:
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0020
        j       return
        lui     a0, 0x8013          // original line 1
    }
    
    // Announcer comment after a disable
    scope disable_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)
        sw      a1, 0x0018(sp)
        
        li      a2, disable_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      v1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        lw      a1, 0x0018(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0020

        jr      ra
        lw      a0, 0x0020(sp)              // load a0
    }
    
    // Announcer comment after a teleport
    scope teleport_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x000C(sp)
        
        jal     toggle_announcer_
        nop

        bnez    v0, _normal
        nop

        _pokemon:
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)
        sw      v1, 0x0018(sp)
        
        li      a2, teleport_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        lw      v1, 0x0018(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x000C(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // Announcer comment after a Wolf Up Special
    scope slash_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x000C(sp)
        
        jal     toggle_announcer_
        nop

        bnez    v0, _normal
        nop

        _pokemon:
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)
        sw      v1, 0x0018(sp)
        sw      t6, 0x001C(sp)
        
        li      a2, slash_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        lw      v1, 0x0018(sp)
        lw      t6, 0x001C(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x000C(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // Announcer comment after a Bowser Neutral Special, Charizard Attack, or Fireflower
    scope flamethrower_announcement_: {
        addiu   sp, sp, -0x0030
        sw      ra, 0x0004(sp)
        sw      v0, 0x000C(sp)
        
        jal     toggle_announcer_
        nop

        bnez    v0, _normal
        nop

        _pokemon:
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)
        sw      v1, 0x0018(sp)
        sw      t6, 0x001C(sp)
        
        li      a2, flamethrower_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        lw      v1, 0x0018(sp)
        lw      t6, 0x001C(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x000C(sp)
        addiu   sp, sp, 0x0030
        jr      ra
        nop
    }
    
    // Hook for Fireflower Flamethrower call
    scope fireflower_: {
        OS.patch_start(0xF0998, 0x80175F58)
        jal       fireflower_
        sw      a2, 0x0040(sp)      // origina line 1
        return:
        OS.patch_end()
        
        jal     flamethrower_announcement_
        nop
        
        j       return
        lui     a1, 0x8019          // original line 2
    }
    
    // Hook for Charizard Flamethrower call
    scope charizard_: {
        OS.patch_start(0xFA688, 0x8017FC48)
        j       charizard_
        sw      a2, 0x0040(sp)      // origina line 1
        return:
        OS.patch_end()
        
        jal     flamethrower_announcement_
        nop
        
        j       return
        lui     a1, 0x8019          // original line 2
    }

    // Announcer comment after a Falcon Punch
    scope firepunch_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        
        sw      a2, 0x0008(sp)
        sw      a3, 0x000C(sp)
        sw      v1, 0x0010(sp)
        
        li      a2, firepunch_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu   a0, r0, v1               // fgm number
        
        _end:
        lw      a2, 0x0008(sp)
        lw      a3, 0x000C(sp)
        lw      v1, 0x0010(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // Announcer comment after a successful counter
    scope counter_announcement_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a0, 0x0010(sp)
        
        li      a2, counter_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      v1, 0x000C(sp)
        lw      a0, 0x0010(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0020

        jr      ra
        nop
    }

    // Rest announcement
    scope rest_g_announcement_: {
        OS.patch_start(0xCC22C, 0x801517EC)
        jal       rest_announcement_
        sw      a0, 0x0020(sp)          // original line 1
        return:
        OS.patch_end()
    }
    scope rest_a_announcement_: {   
        OS.patch_start(0xCC264, 0x80151824)
        jal       rest_announcement_
        sw      a0, 0x0020(sp)          // original line 1
        return:
        OS.patch_end()
    }    
        
    scope rest_announcement_: {
        sw      r0, 0x0010(sp)          // original line 2
        
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop
        
        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a0, 0x0010(sp)
        
        li      a2, rest_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0002          // decimal 1 possible integers
        
        bnez    v0, _end
        nop

        jal     0x800269C0               // play fgm
        addu    a0, r0, v1               // fgm number
        
        
        _end:   
        lw      v1, 0x000C(sp)
        lw      a0, 0x0010(sp)

        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    // Pound announcement
    scope pound_g_announcement_: {
        OS.patch_start(0xCBF4C, 0x8015150C)
        jal       pound_announcement_
        sw      a0, 0x0020(sp)          // original line 1
        return:
        OS.patch_end()
    }
    scope pound_a_announcement_: {   
        OS.patch_start(0xCBF0C, 0x801514CC)
        jal       pound_announcement_
        sw      a0, 0x0020(sp)          // original line 1
        return:
        OS.patch_end()
    }    
        
    scope pound_announcement_: {
        sw      r0, 0x0010(sp)          // original line 2
        
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop
        
        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a0, 0x0010(sp)

        li      a2, pound_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, v1, r0              // get fgm id
        
        _end:
        lw      v1, 0x000C(sp)
        lw      a0, 0x0010(sp)
        
        _normal: 
        lw      v0, 0x0008(sp)
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // Announcer comment after a disable
    scope seismic_toss_announcement_: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _normal
        nop

        _pokemon:
        sw      v1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)
        sw      a1, 0x0018(sp)
        sw      at, 0x0020(sp)
        sw      a0, 0x0024(sp)
        sw      t6, 0x0028(sp)
        sw      t7, 0x002C(sp)
        sw      t3, 0x0030(sp)
        sw      t4, 0x0034(sp)
        sw      t5, 0x0038(sp)
        sw      t8, 0x003C(sp)
        
        li      a2, seismic_toss_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0                  // play fgm
        addu    a0, r0, v1                  // fgm number
        
        _end:
        lw      v1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        lw      a1, 0x0018(sp)
        lw      at, 0x0020(sp)
        lw      a0, 0x0024(sp)
        lw      t6, 0x0028(sp)
        lw      t7, 0x002C(sp)
        lw      t3, 0x0030(sp)
        lw      t4, 0x0034(sp)
        lw      t5, 0x0038(sp)
        lw      t8, 0x003C(sp)
        
        _normal:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0040

        jr      ra
        nop
    }
    
    // Hung Tough announcement
    scope hung_tough_announcement_: {
        OS.patch_start(0xDF6C0, 0x80164C80)
        j       hung_tough_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      v1, 0x0010(sp)
        sw      a0, 0x0014(sp)
        sw      t1, 0x0018(sp)
        sw      t6, 0x001C(sp)
        sw      a2, 0x0020(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon:
        addiu   t1, r0, 0x0267      // cheer sound for when a player recovers
        lhu     a0, 0x004a(sp)      // load sound that will be used later
        bne     t1, a0, _end
        nop
        
        li      a2, tough_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _end
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding item ID to t9
        
        
        _end:
        lw      a0, 0x0014(sp)
        lw      v0, 0x0008(sp)
        lw      v1, 0x0010(sp)
        lw      ra, 0x0004(sp)
        lw      a1, 0x000C(sp)
        lw      t1, 0x0018(sp)
        lw      t6, 0x001C(sp)
        lw      a2, 0x0020(sp)
        addiu   sp, sp, 0x0030
        
        jal     0x800269C0          // play fgm     
        lhu     a0, 0x001a(sp)      // original line 2
        
        j       return
        nop
    }
    
    // It's restoring hp announcement
    scope recovery_announcement_: {
        OS.patch_start(0x65BD8, 0x800EA3D8)
        j       recovery_announcement_
        sw      ra, 0x0014(sp)      // original line 1
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop
        
        sw      a0, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      a1, 0x000C(sp)
        sw      t1, 0x0018(sp)

        _pokemon:       
        li      a2, recovery_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _no_sound
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding item ID to t9
        
        
        _no_sound:
        lw      a0, 0x0014(sp)
        lw      v1, 0x0010(sp)
        lw      a1, 0x000C(sp)
        lw      t1, 0x0018(sp)
        
        _end: 
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0030
        lw      ra, 0x0014(sp)      // load ra back
        j       return
        sw      a1, 0x001C(sp)      // original line 2
    }
    
    // It's restoring hp announcement, for psi magnet users
    scope recovery_announcement_magnet_: {
        OS.patch_start(0x5EBDC, 0x800E33DC)
        j       recovery_announcement_magnet_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      v0, 0x0008(sp)
        sw      ra, 0x000C(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop
        
        sw      a0, 0x0014(sp)
        sw      v1, 0x0010(sp)
        sw      a1, 0x001C(sp)
        sw      t1, 0x0018(sp)
        sw      a2, 0x0020(sp)

        _pokemon:       
        li      a2, recovery_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _no_sound
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding item ID to t9
        
        _no_sound:
        lw      a0, 0x0014(sp)
        lw      v1, 0x0010(sp)
        lw      a1, 0x001C(sp)
        lw      t1, 0x0018(sp)
        lw      a2, 0x0020(sp)
        
        _end:
        lw      v0, 0x0008(sp)
        lw      ra, 0x000C(sp)
        addiu   sp, sp, 0x0030
        lbu     t4, 0x000D(s0)          // original line 1
        j       return
        lui     t3, 0x800A              // original line 2
    }
    
    // "Head on collision" for clangs
    scope clang_announcement_: {
        OS.patch_start(0x5DED8, 0x800E26D8)
        j       clang_announcement_
        addiu   s2, r0, 0x0001      // original line 1
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0030
        sw      ra, 0x0004(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon: 
        ori     v0, r0, 0x0003              // ~
        bne     a3, v0, _end                // skip if contact type != clang
        nop
        
        sw      a0, 0x0014(sp)
        sw      a1, 0x000C(sp)
        sw      t1, 0x0018(sp)
        sw      a2, 0x0020(sp)
        
        li      a2, clang_call
        lbu     t1, 0x000C(a2)          // load usage
        bnez    t1, _no_sound           // if used in match, don't reuse  
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0001          // decimal 1 possible integers
        
        bnez    v0, _no_sound
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding item ID to t9
        
        _no_sound:
        lw      a0, 0x0014(sp)
        lw      a1, 0x000C(sp)
        lw      t1, 0x0018(sp)
        lw      a2, 0x0020(sp)
        
        _end:  
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0030
        
        
        j       return
        addiu   s3, r0, 0x0003      // original line 1
    }
    
    // Paralysis for stun action
    scope stun_announcement_: {
        OS.patch_start(0xC42E8, 0x801498A8)
        j       stun_announcement_
        sw      ra, 0x0024(sp)      // original line 1
        return:
        OS.patch_end()
        
        sw      s0, 0x0020(sp)      // original line 2
        
        addiu   sp, sp, -0x0030
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon:        
        sw      t1, 0x0018(sp)
        sw      a0, 0x0014(sp)
        
        li      a2, stun_call
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0002          // decimal 2 possible integers
        
        bnez    v0, _no_sound
        nop
        
        jal     0x800269C0              // play fgm
        addu    a0, r0, v1              // get announcement ID by adding item ID to t9
        
        _no_sound:
        lw      a0, 0x0014(sp)
        lw      t1, 0x0018(sp) 
        
        _end:  
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0030
        j       return
        lw      ra, 0x0024(sp)          // load ra
    }
    
    // Time Up announcement
    scope time_up_announcement_: {
        OS.patch_start(0x8EFC4, 0x801137C4)
        j       time_up_announcement_
        lui     s1, 0x8013          // original line 1
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0010
        sw      ra, 0x0004(sp)
        
        jal     toggle_announcer_
        addiu   s1, s1, 0x1808      // original line 2, normal time up ID loaded from here
        
        bnez    v0, _end
        nop

        _pokemon:
        addiu   v0, r0, 0x020F      // TIME UP! SFX
        lhu     a0, 0x0000(s1)      // load sound that will be used later
        bne     v0, a0, _end        // in case this routine is used for other sounds, skip if not TIME UP!
        nop

        jal     0x800269C0              // play fgm, uses v0, t6, a1, a0, t7, t8, t9, at
        addiu    a0, r0, 0x4AE          // announcer time up FGM
        
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0010
        j       0x801137D4          // skip over original call
        nop

        _end:
        lw      ra, 0x0004(sp)
        addiu   sp, sp, 0x0010
        
        j       return
        nop
    }
    
    // Team KO situation
    scope team_ko_announcement_: {
        OS.patch_start(0xB814C, 0x8013D70C)
        j       team_ko_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0040
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon:
        sw      a0, 0x000C(sp)
        sw      a1, 0x0010(sp)
        sw      a2, 0x0014(sp)
        sw      a3, 0x0018(sp)
        sw      t1, 0x001C(sp)
        sw      t2, 0x0020(sp)
        sw      t6, 0x0024(sp)
        sw      t7, 0x0028(sp)
        sw      t8, 0x002C(sp)
        sw      v1, 0x0030(sp)
        sw      at, 0x0034(sp)
        
        li      a2, team_ko_call
        lh      t1, 0x000C(a2)      // load if used
        lh      t2, 0x000C(a2)      // load if other used
        addu    t1, t1, t2
        bnez    t1, _skip           // if either used, skip
        nop
        
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0002          // decimal 2 possible integers
        
        bnez    v0, _skip           // if either used, skip
        nop

        jal     0x800269C0              // play fgm, uses v0, t6, a1, a0, t7, t8, t9, at
        addiu   a0, v1, r0              // team ko announce

        _skip:
        lw      a0, 0x000C(sp)
        lw      a1, 0x0010(sp)
        lw      a2, 0x0014(sp)
        lw      a3, 0x0018(sp)
        lw      t1, 0x001C(sp)
        lw      t2, 0x0020(sp)
        lw      t6, 0x0024(sp)
        lw      t7, 0x0028(sp)
        lw      t8, 0x002C(sp)
        lw      v1, 0x0030(sp)
        lw      at, 0x0034(sp)
        
        _end:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0040
        
        beq     v0, r0, _start_pressed  // modified original line 1
        addiu   t9, v0, 0xFFFF      // original line 2
        
        j       return
        nop
        
        _start_pressed:
        j       0x8013D750          // modified original line 1
        nop
    }
    
    // Aerial Special Announcements
    scope air_specials_announcement_: {
        OS.patch_start(0xCB978, 0x80150F38)
        j       air_specials_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0040
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon:
        sw      a0, 0x000C(sp)
        sw      a1, 0x0010(sp)
        sw      a2, 0x0014(sp)
        sw      a3, 0x0018(sp)
        sw      t1, 0x001C(sp)
        sw      t2, 0x0020(sp)
        sw      t6, 0x0024(sp)
        sw      t7, 0x0028(sp)
        sw      t8, 0x002C(sp)
        sw      t9, 0x0030(sp)
        sw      at, 0x0034(sp)
        
        jal     Global.get_random_int_          // get random integer
        addiu   a0, r0, 0x0014                  // call is a 5% chance
        
        bnez    v0, _skip
        nop

        li      a2, attack_calls       // load address
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0003          // decimal 3 possible integers
        
        bnez    v0, _skip               // if either used, skip
        nop

        jal     0x800269C0              // play fgm, uses v0, t6, a1, a0, t7, t8, t9, at
        addiu   a0, v1, r0              // attack announce

        _skip:
        lw      a0, 0x000C(sp)
        lw      a1, 0x0010(sp)
        lw      a2, 0x0014(sp)
        lw      a3, 0x0018(sp)
        lw      t1, 0x001C(sp)
        lw      t2, 0x0020(sp)
        lw      t6, 0x0024(sp)
        lw      t7, 0x0028(sp)
        lw      t8, 0x002C(sp)
        lw      t9, 0x0030(sp)
        lw      at, 0x0034(sp)
        
        _end:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0040
        
        jal     0x800F3794          // original line 1
        sw      a2, 0x0020(sp)      // original line 2
        
        j       return
        nop
    }
    
    // Ground Special Announcements
    scope ground_specials_announcement_: {
        OS.patch_start(0xCBB00, 0x801510C0)
        j       ground_specials_announcement_
        nop
        return:
        OS.patch_end()
        
        addiu   sp, sp, -0x0040
        sw      ra, 0x0004(sp)
        sw      v0, 0x0008(sp)
        
        jal     toggle_announcer_
        nop
        
        bnez    v0, _end
        nop

        _pokemon:
        sw      a0, 0x000C(sp)
        sw      a1, 0x0010(sp)
        sw      a2, 0x0014(sp)
        sw      a3, 0x0018(sp)
        sw      t2, 0x0020(sp)
        sw      t6, 0x0024(sp)
        sw      t7, 0x0028(sp)
        sw      t8, 0x002C(sp)
        sw      v1, 0x0030(sp)
        sw      at, 0x0034(sp)
        
        jal     Global.get_random_int_          // get random integer
        addiu   a0, r0, 0x0014                  // call is a 5% chance
        
        bnez    v0, _skip
        nop

        li      a2, attack_calls       // load address
        addiu   a0, r0, STANDARD
        jal     announcer_main_
        addiu   a1, r0, 0x0003          // decimal 3 possible integers
        
        bnez    v0, _skip               // if either used, skip
        nop

        jal     0x800269C0              // play fgm, uses v0, t6, a1, a0, t7, t8, t9, at
        addiu   a0, v1, r0              // attack announce

        _skip:
        lw      a0, 0x000C(sp)
        lw      a1, 0x0010(sp)
        lw      a2, 0x0014(sp)
        lw      a3, 0x0018(sp)
        lw      t2, 0x0020(sp)
        lw      t6, 0x0024(sp)
        lw      t7, 0x0028(sp)
        lw      t8, 0x002C(sp)
        lw      v1, 0x0030(sp)
        lw      at, 0x0034(sp)
        
        _end:
        lw      ra, 0x0004(sp)
        lw      v0, 0x0008(sp)
        addiu   sp, sp, 0x0040
        
        lw      t9, 0x0100(v0)      // original line 1
        sll     t1, t9, 0xE         // original line 2
        
        j       return
        nop
    }
    
    // UTILITY/OVERALL FUNCTIONALITY ROUTINES
    
    // Toggle Check for Announcer usage
    // outputs 0x0 into v0 if announcer is to be used and 0x1, if not
    scope toggle_announcer_: {
        addiu   sp, sp, -0x0010
        sw      ra, 0x0004(sp)
        sw      t1, 0x0008(sp)
        sw      t0, 0x000C(sp)
        
        li      t0, Toggles.entry_announcer_mode
        lw      t0, 0x0004(t0)              // t0 = announcer_mode
        addiu   t1, r0, 0x0002              // t1 = off
        
        beql    t1, t0, _end                // if off, set variable to 1
        addiu   v0, r0, 0x0001
        addiu   t1, r0, 0x0001              // t1 = all
        
        beql    t1, t0, _end                // if all, set variable to 0
        addiu   v0, r0, r0
        
        li      t1, Global.match_info
        lw      t1, 0x0000(t1)              // t1 = match info
        lbu     t1, 0x0001(t1)              // t1 = current stage
        lli     t0, Stages.id.POKEMON_STADIUM         // t1 = Stages.id
        beq     t1, t0, _end                // if current stage is Pokemon stadium, set variable to 0 
        addiu   v0, r0, r0                  // if a pokemon stadium stage, set variable to 0
        
        lli     t0, Stages.id.GYM_LEADER_CASTLE         // t1 = Stages.id
        beq     t1, t0, _end                // if current stage is Pokemon stadium, set variable to 0 
        addiu   v0, r0, r0                  // if a pokemon stadium stage, set variable to 0
        
        lli     t0, Stages.id.POKEMON_STADIUM_2       // t0 = Stages.id
        bnel    t1, t0, _end                // if current stage is other than pokemon stadium, set variable to
        addiu   v0, r0, 0x0001              // if not a Pokemon Stadium, set variable to 1      
        
        _end:
        lw      ra, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t0, 0x000C(sp)
        addiu   sp, sp, 0x0010
        jr      ra
        nop
    }
    
    // Timer Check for Announcer usage
    // outputs 0x0 into v0 if announcer is to be used and 0x1, if not
    // outputs FGM ID into v1
    // a0 = announcement type
    // a1 = amount of integers (if standard)
    // a2 = base address (if standard)
        constant NAME(0x0)
        constant KO(0x1)
        constant GENERAL(0x2)
        constant STANDARD(0x3)
    scope announcer_main_: {
        addiu   sp, sp, -0x0020
        sw      ra, 0x0004(sp)
        sw      t1, 0x0008(sp)
        sw      t0, 0x000C(sp)
        sw      t3, 0x0010(sp)
        sw      t2, 0x0014(sp)
        
        li      t1, announcer_timer_global      // global announcement timer
        lw      t1, 0x0000(t1)                  // load timer
        bnezl   t1, _end                        // if not enough time from last announcement globally, skip
        addiu   v0, r0, 0x0001                  // if timer not over, do not call
        
        beqz    a0, _name
        addiu   t1, r0, 0x0001
        beq     a0, t1, _ko
        addiu   t1, r0, 0x0002
        
        beq     a0, t1, _general
        addiu   t1, r0, 0x0003
        
        beq     a0, t1, _standard
        addiu   t1, r0, 0x0004
        
        _name:
        addiu   t1, t6, -0x20                   // subtract from item ID to get beginning of pokemon list
        sll     t1, t1, 0x0004                  // multiply to get offset
        li      t0, pokemon_calls               // pokemon calls address
        addu    t1, t1, t0                      // get address of pokemon call
        lw      t0, 0x0008(t1)                  // load timer
        bnezl   t0, _end
        addiu   v0, r0, 0x0001                  // if timer not over, do not call

        beq     r0, r0, _success
        nop
        
        _ko:
        li      at, Global.vs.elapsed
        lw      at, 0x0000(at)                  // load total elapsed time
        slti    at, at, 0x4B0                   // 20 seconds if quick k0
        bnez    at, _quick_ko                   // if less than 20 seconds, quick ko sound
        nop
        
        lw      at, 0x002C(s0)                  // load total percent
        addiu   a0, r0, 0x0096                  // load 150%
        slt     a0, a0, at                      // set on less than
        bnez    a0, _long_ko                    // if greater than 150%, do a long ko fgm
        nop
        
        _regular_ko:
        addiu   t3, r0, 0x3                     // set amount of attempts 
        li      t2, regular_ko_calls            // load address
        
        _regular_ko_loop:
        jal     Global.get_random_int_          // get random integer
        addiu   a0, r0, 0x0004                  // decimal 4 possible integers
        
        sll     t0, v0, 0x0004                  // multiply to get offset
        addu    t1, t2, t0                      // get announcer address
        lhu     t0, 0x0008(t1)                  // load timer
        bnez    t0, _retry_ko                   // try again if used recently
        nop
        
        _retry_ko:
        bnez    t3, _regular_ko_loop
        addiu   t3, t3, -0x0001
        
        beq     r0, r0, _success
        nop

        _long_ko:
        jal     Global.get_random_int_          // get random integer
        addiu   a0, r0, 0x0002                  // decimal 2 possible integers
        
        li      t1, long_ko_calls       // load address
        sll     t3, v0, 0x0004          // multiply to get offset
        addu    t1, t1, t3              // get announcer address
        lhu     t0, 0x0008(t1)          // load timer
        bnez    t0, _regular_ko
        nop
        
        beq     r0, r0, _success
        nop
        
        _quick_ko:
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x0002          // decimal 2 possible integers
        
        li      t1, quick_ko_calls      // load address
        sll     t3, v0, 0x0004          // multiply to get offset
        addu    t1, t1, t3              // get announcer address
        lhu     t0, 0x000C(t1)          // load usage
        bnez    t0, _regular_ko
        nop
        
        beq     r0, r0, _success
        nop
        
        _general:
        li      t0, Global.current_screen
        lbu     t0, 0x0000(t0)          // load current screen
        addiu   t1, r0, 0x0016          // vs mode
        bne     t1, t0, _unspecific
        nop
        
        li      t0, Global.vs.game_mode
        lbu     t0, 0x0000(t0)          // load current game mode
        slti    t0, t0, 0x0002          // set if less than 2
        bnez    t0, _unspecific         // if no stock or time/stock, skip
        nop
        
        li      t0, 0x801317CC          // load stock count
        lbu     t2, 0x0000(t0)          // load p1 stock count
        slti    t2, t2, 0x0002
        beqz    t2, _unspecific
        lbu     t2, 0x0001(t0)          // load p2 stock count
        slti    t2, t2, 0x0002
        beqz    t2, _unspecific
        lbu     t2, 0x0002(t0)          // load p3 stock count
        slti    t2, t2, 0x0002
        beqz    t2, _unspecific
        lbu     t2, 0x0003(t0)          // load p4 stock count
        slti    t2, t2, 0x0002
        beqz    t2, _unspecific         // if all players down to last stock or less, make close match announcement
        nop
        
        li      t1, close_match_call
        lbu     t0, 0x000C(t1)          // load usage
        beqz    t0, _success                // if unused in match, use
        nop
        
        _unspecific:
        li      t2, general_calls
        
        _unspecific_loop:
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x0008          // decimal 6 possible integers
        
        sll     t0, v0, 0x0004                  // multiply to get offset
        addu    t1, t2, t0                      // get announcer address
        lw      t0, 0x0008(t1)                  // load timer
        bnez    t0, _unspecific_loop            // try again if used recently
        nop
        
        beq     r0, r0, _success
        nop
        
        _standard:
        addiu   t3, a1, -0x001                    // set amount of attempts 
        
        _standard_loop:
        jal     Global.get_random_int_  // get random integer
        addiu   a0, a1, r0              // get amount of integers
        
        sll     t0, v0, 0x0004                  // multiply to get offset
        addu    t1, a2, t0                      // get announcer address
        
        lw      t0, 0x0008(t1)                  // load timer
        beqz    t0, _success
        nop

        bnez    t3, _standard_loop                  // if exhaust number of attempts, continue
        addiu   t3, t3, -0x001                    // count down amount of attempts 
        
        lbu     t3, 0x000F(t1)                    // load flag
        bnezl   t3, _end                          // if flag present, no fgm
        addiu   v0, r0, 0x0001
        
        beq     r0, r0, _success                  // just proceed if enough attempts at finding a fresh clip
        nop
        
        _success:
        // t1 = announcement sound struct
        addiu   v0, r0, r0              // set to usable
        lhu     v1, 0x0002(t1)          // load fgm ID
        lw      t0, 0x0004(t1)          // load timer
        sw      t0, 0x0008(t1)          // set timer
        addiu   t0, r0, 0x0001
        sh      t0, 0x000C(t1)          // set to used 
        li      t0, announcer_timer_global
        addiu   t1, r0, 0x78            // 3 seconds
        sw      t1, 0x0000(t0)          // set timer to prevent talking over himself
        
        _end:
        lw      ra, 0x0004(sp)
        lw      t1, 0x0008(sp)
        lw      t0, 0x000C(sp)
        lw      t3, 0x0010(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
    
    // This establishes Random statements by announcer
    scope announcer_setup_: {
        OS.save_registers()


        addiu   a2, r0, 0x0001              // group
        addiu   a0, r0, 0x03F2              // object id
        
        li      a1, announcer_constant_     // associated routine
        jal     Render.CREATE_OBJECT_       // create object
        lui     a3, 0x8000                  // unknown

        li      t1, announcer_timer_general // load announcer timer address
        sw      r0, 0x0000(t1)              // clear announcer timer address
        li      t1, announcer_timer_global  // load announcer timer address
        sw      r0, 0x0000(t1)              // clear announcer timer address
        li      t1, sleep_flag              // load sleep flag address
        sw      r0, 0x0000(t1)              // clear announcer timer address
        
        //      this portion refeshes timers
        li      t0, pokemon_calls        // beginning of announcer calls
        li      t2, announcer_fgm_count_address
        lw      t2, 0x0000(t2)          // load fgm count
        
        _loop:
        sw      r0, 0x0008(t0)          // save updated time
        sb      r0, 0x000C(t0)          // clear usage
        addiu   t2, t2, -0x0001         // subtract 1 from count
        bnezl   t2, _loop
        addiu   t0, t0, 0x10            // move to next call

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Code provides for more general announcements and statements made by the announcer
    // also responsible for counting down timers
    scope announcer_constant_: {
        addiu   sp, sp, -0x0030
        
        sw      ra, 0x0014(sp)
        sw      a0, 0x0000(sp)
        sw      s0, 0x0004(sp)
        
        // this counts down global timer
        li      t0, announcer_timer_global
        lw      t2, 0x0000(t0)          // load current count
        beqz    t2, _calls              // prevent talking over himself by checking if too recent from last
        addiu   t2, t2, -0x0001         // load reduce count
        sw      t2, 0x0000(t0)          // save updated count
        
        li      t0, sleep_flag
        lw      t0, 0x0000(t0)          // if meant to sleep announce, do now
        bnez    t0, _sleep_call
        nop
        
        //      this portion counts down usage of the FGMs
        _calls:
        li      t0, pokemon_calls       // beginning of announcer calls
        li      t2, announcer_fgm_count_address
        lw      t2, 0x0000(t2)          // load count
        addiu   t2, t2, -0x0001         // subtract 1 to end at 0
        
        _loop:
        lw      t1, 0x0008(t0)          // load timer
        beqz    t1, _skip               // if timer at 0, skip
        addiu   t1, t1, -0x0001         // subtract 1 from timer
        sw      t1, 0x0008(t0)          // save updated time
        
        _skip:
        addiu   t2, t2, -0x0001         // subtract 1 from count
        bnezl   t2, _loop
        addiu   t0, t0, 0x10            // move to next call
        
        //      checks to see if nearing end of match for specific vs timer call
        li      t0, Global.vs.timer     // load timer address
        addiu   t6, r0, 0xE09           // set to just less than 1 minute, this prevents the announcer from going haywire if you have a 1 minute match
        lw      t0, 0x0000(t0)          // load timer
        
        beql    t0, t6, _call           // timer call
        addiu   a0, r0, 0x4A1           // time running out announcement ID
        
        li      t0, Global.vs.elapsed
        lw      t0, 0x0000(t0)          // load total elapsed time
        addiu   t6, r0, 0x1E            // half second into match
        beq     t0, t6, _opening               // if 1 second, play opening
        nop

        //      deals with given general announcements about match ever 45 seconds to 1:30 minutes
        li      t0, announcer_timer_general     // load announcer timer address
        lw      t6, 0x0000(t0)          // load timer
        addiu   t2, t6, 0x0001          // add 1 to timer
        addiu   at, r0, 0x0960          // minimum timer amount for comments
        slt     t1, t6, at                  
        bnez    t1, _end                // if less than minimum, jump to end
        sw      t2, 0x0000(t0)          // save updated timer
        sw      t6, 0x0020(sp)          // save timer to stack
        
        jal     Global.get_random_int_  // get random integer
        addiu   a0, r0, 0x0960          // chance any frame gets an announcement
        
        lw      t6, 0x0020(sp)          // load timer from stack
        addiu   t4, r0, 0x0050          // place 50 as the random number to generate announcement
        beq     t4, v0, _announce       // if 50, announce
        addiu   t4, r0, 0x12C0          // put in max time before announcement
        bne     t4, t6, _end            // if not same as timer, skip animation
        nop
        
        _announce:
        jal     announcer_main_
        addiu   a0, r0, GENERAL
        
        bnez    v0, _end                // if not too early, jump to end
        addu    a0, v1, r0              // place fgm in a0
        
        li      t0, announcer_timer_general     // load announcer timer address
        sw      r0, 0x0000(t0)          // clear timer
        
        beq     r0, r0, _call
        nop
        
        _sleep_call:
        addiu   a1, r0, 0x0003              // sounds to go through
        li      a2, sleep_calls
        jal     announcer_main_           // get fgm
        addiu   a0, r0, STANDARD          // standard announcement
        
        bnez    v0, _end                // if not too early, jump to end
        addu    a0, v1, r0              // place fgm in a0
        
        li      t0, sleep_flag          // load sleep flag
        sw      r0, 0x0000(t0)          // clear timer
        
        beq     r0, r0, _call
        nop
        
        _opening:
        li      t1, Global.match_info
        lw      t1, 0x0000(t1)              // t1 = match info
        lbu     t1, 0x0001(t1)              // a0 = current stage ID
        lli     a1, Stages.id.GYM_LEADER_CASTLE         // a1 = Stages.id
        beql    t1, a1, _gym           // if current stage is GYM LEADER CASTLE, go 
        nop
        
        addiu   a1, r0, 0x0003            // sounds to go through
        li      a2, opening_calls
        jal     announcer_main_           // get fgm
        addiu   a0, r0, STANDARD          // standard announcement
        
        bnez    v0, _end                // if not too early, jump to end
        addu    a0, v1, r0              // place fgm in a0
        
        beq     r0, r0, _call
        nop
        
        
        _gym:
        addiu   a1, r0, 0x0002            // sounds to go through
        li      a2, gym_leader_call
        jal     announcer_main_           // get fgm
        addiu   a0, r0, STANDARD          // standard announcement
        
        bnez    v0, _end                // if not too early, jump to end
        addu    a0, v1, r0              // place fgm in a0
        
        beq     r0, r0, _call
        nop
        
        _call:
        jal     0x800269C0              // play fgm
        nop

        _end:
        lw      ra, 0x0014(sp)          // load ra
        lw      a0, 0x0000(sp)          // load object
        lw      s0, 0x0004(sp)
        addiu   sp, sp, 0x0030

        jr      ra
        nop
    }
    
    announcer_timer_general:
    dw  0x00000000
    announcer_timer_global:
    dw  0x00000000
    sleep_flag:
    dw  0x00000000

    variable announcer_fgm_count(0)

    macro add_announcement(announcer_id, fgm_id, timer_duration, flag) {
        global variable announcer_fgm_count(announcer_fgm_count + 1)
        dh ({announcer_id})         // custom announcer ID
        dh ({fgm_id})               // FGM ID
        dw ({timer_duration})       // Duration before sound should be usable again
        dw  0x00000000              // Spot for game to write timer
        dh  0x00                    // Spot for if sound has been used in the match
        dh ({flag})                 // special flag
    }

    // CALL STRUCTS

    pokemon_calls:
    add_announcement(0x0, 0x45C, 0x384, 0x0)        // ONIX
    add_announcement(0x1, 0x45D, 0x384, 0x0)        // SNORLAX
    add_announcement(0x2, 0x45E, 0x384, 0x0)        // GOLDEEN
    add_announcement(0x3, 0x45F, 0x384, 0x0)        // MEOWTH
    add_announcement(0x4, 0x460, 0x384, 0x0)        // CHARIZARD
    add_announcement(0x5, 0x461, 0x384, 0x0)        // BEEDRILL
    add_announcement(0x6, 0x462, 0x384, 0x0)        // BLASTOISE
    add_announcement(0x7, 0x463, 0x384, 0x0)        // CHANSEY
    add_announcement(0x8, 0x464, 0x384, 0x0)        // STARMIE
    add_announcement(0x9, 0x465, 0x384, 0x0)        // HITMONLEE
    add_announcement(0xA, 0x466, 0x384, 0x0)        // KOFFING
    add_announcement(0xB, 0x467, 0x384, 0x0)        // CLEFAIRY
    add_announcement(0xC, 0x468, 0x384, 0x0)        // MEW
    
    quick_ko_calls:
    add_announcement(0xD, 0x46D, 0x000, 0x0)        // Taken down on the word go
    add_announcement(0xE, 0x46E, 0x000, 0x0)        // That was quick, down already
    
    regular_ko_calls:
    add_announcement(0xF, 0x469, 0x4B0, 0x0)        // Oh, Is it down and out?
    add_announcement(0x10, 0x46A, 0x4B0, 0x0)       // Waa, Going Down
    add_announcement(0x11, 0x46B, 0x4B0, 0x0)       // Oh, It's down
    add_announcement(0x12, 0x46C, 0x4B0, 0x0)       // And it's down
    
    long_ko_calls:
    add_announcement(0x13, 0x476, 0x258, 0x0)        // It's finally taken down
    add_announcement(0x14, 0x477, 0x258, 0x0)        // It goes down after a good fight
    
    general_calls:
    add_announcement(0x15, 0x499, 0x3840, 0x0)        // What a furious battle
    add_announcement(0x16, 0x49A, 0x3840, 0x0)        // Neither one is conceding an inch
    add_announcement(0x17, 0x49B, 0x3840, 0x0)        // The Intense battle continues
    add_announcement(0x18, 0x49C, 0x3840, 0x0)        // The tense battle continues
    add_announcement(0x19, 0x49D, 0x3840, 0x0)        // This battle is still up in the air
    add_announcement(0x1A, 0x49E, 0x3840, 0x0)        // This battle is raging back and forth
    add_announcement(0x1A, 0x4BE, 0x3840, 0x0)        // This battle is raging back and forth
    add_announcement(0x1A, 0x4BF, 0x3840, 0x0)        // This battle is raging back and forth
    
    close_match_call:
    add_announcement(0x1B, 0x4A0, 0x000, 0x0)        // The battle is coming right down to the wire
    
    sleep_calls:
    add_announcement(0x1C, 0x47C, 0x708, 0x0)       // Oh no, it fell asleep
    add_announcement(0x1D, 0x47D, 0x708, 0x0)       // It's asleep on the job
    add_announcement(0x1F, 0x47F, 0x708, 0x0)       // Falling alseep is going to make this a one sided fight
    
    combo_calls:
    add_announcement(0x20, 0x480, 0x384, 0x1)       // The attack is still continuing
    
    knockback_high_calls:
    add_announcement(0x21, 0x482, 0x384, 0x0)       // Ooh, that's strong
    add_announcement(0x22, 0x483, 0x384, 0x0)       // Powerful Strike
    add_announcement(0x23, 0x484, 0x384, 0x0)       // Pow, that's an effective hit
    add_announcement(0x24, 0x485, 0x384, 0x0)       // Harsh Blow
    add_announcement(0x25, 0x486, 0x384, 0x0)       // That was brutal
    add_announcement(0x26, 0x487, 0x384, 0x0)       // Super Effective
    add_announcement(0x27, 0x488, 0x384, 0x0)       // Severe Hit
    add_announcement(0x28, 0x489, 0x384, 0x0)       // Savage Hit
    add_announcement(0x29, 0x48A, 0x384, 0x0)       // Woaaaahhh
    add_announcement(0x2A, 0x48B, 0x384, 0x0)       // Woooah that was overpowering
    add_announcement(0x2B, 0x48C, 0x384, 0x0)       // Devastating
    add_announcement(0x2C, 0x48D, 0x384, 0x0)       // Ground zero
    
    knockback_mid_calls:
    add_announcement(0x2D, 0x48E, 0x384, 0x0)       // Good Hit
    add_announcement(0x2E, 0x48F, 0x384, 0x0)       // Boom
    add_announcement(0x2F, 0x490, 0x384, 0x0)       // That's a good hit
    add_announcement(0x30, 0x491, 0x384, 0x0)       // Have that
    add_announcement(0x31, 0x492, 0x384, 0x0)       // Aaaah
    add_announcement(0x32, 0x493, 0x384, 0x0)       // Wow
    
    damage_calls:
    add_announcement(0x33, 0x495, 0x384, 0x0)       // Kapow Major Damage
    add_announcement(0x34, 0x496, 0x384, 0x0)       // Heavy Damage
    add_announcement(0x35, 0x497, 0x384, 0x0)       // Major Damage
    add_announcement(0x36, 0x498, 0x384, 0x0)       // That one hurt
    
    thunder_call:
    add_announcement(0x37, 0x4A2, 0x708, 0x1)       // Here it comes, Thunder
    
    quick_call:
    add_announcement(0x38, 0x4AB, 0x708, 0x1)       // There, quick attack
    
    charge_call:
    add_announcement(0x39, 0x4A6, 0x708, 0x1)       // It's building energy for the next attack
    
    disable_call:
    add_announcement(0x3A, 0x4A4, 0x708, 0x1)       // That's Disable
    
    teleport_call:
    add_announcement(0x3B, 0x4A3, 0x708, 0x1)       // It used teleport
    
    firepunch_call:
    add_announcement(0x3C, 0x4A5, 0x708, 0x1)       // Oh, fire punch!
    
    rest_call:
    add_announcement(0x3D, 0x4AC, 0x708, 0x1)       // It's catching some rest
    add_announcement(0x3E, 0x4AD, 0x708, 0x1)       // It's taking a quick rest
    
    pound_call:
    add_announcement(0x3F, 0x4AA, 0x708, 0x1)       // What a pound
    
    tough_call:
    add_announcement(0x40, 0x4A7, 0x708, 0x1)       // It hung tough
    
    counter_call:
    add_announcement(0x41, 0x4A8, 0x4B0, 0x1)       // Awesome Counter
    
    little_damage_call:
    add_announcement(0x42, 0x4A9, 0x708, 0x1)       // There's a little damage
    
    burn_call:
    add_announcement(0x43, 0x478, 0x1C20, 0x1)       // It Suffered a Burn
    add_announcement(0x44, 0x49F, 0x1C20, 0x1)       // Its got a Nasty Burn, can it tough it out?
    
    seismic_toss_call:
    add_announcement(0x45, 0x4AF, 0x708, 0x1)       // Seismic Toss
    
    recovery_call:
    add_announcement(0x46, 0x4B1, 0x708, 0x1)       // It's restoring HP
    
    clang_call:
    add_announcement(0x47, 0x4B2, 0x708, 0x1)       // It's a Head on Collision, power versus power
    
    stun_call:
    add_announcement(0x48, 0x4B3, 0x708, 0x1)       // Being unable to move hurts
    add_announcement(0x49, 0x4B4, 0x708, 0x1)       // It's paralyzed on the spot
    
    team_ko_call:
    add_announcement(0x4A, 0x4B9, 0x8708, 0x1)       // Will it erase the humiliation of its fallen comrade?
    add_announcement(0x4B, 0x4BA, 0x8708, 0x1)       // What will the otherside do
    
    slash_call:
    add_announcement(0x4C, 0x4B8, 0x708, 0x1)       // What a slash
    
    flamethrower_call:
    add_announcement(0x4D, 0x4B5, 0x708, 0x1)       // Flamethrower!
    
    gym_leader_call:
    add_announcement(0x4E, 0x4B6, 0x8708, 0x1)       // We bring you this battle live from gym leader castle
    
    opening_calls:
    add_announcement(0x4F, 0x4B7, 0x8708, 0x1)       // Let's get started
    add_announcement(0x4F, 0x4C0, 0x8708, 0x1)       // We're ready to roll
    add_announcement(0x4F, 0x4C1, 0x8708, 0x1)       // What kind of battle can we expect to see
    
    sing_call:
    add_announcement(0x1E, 0x47E, 0x708, 0x0)       // It's singing
    
    attack_calls:
    add_announcement(0x33, 0x4BB, 0x384, 0x0)       // Kapow Major Damage
    add_announcement(0x34, 0x4BC, 0x384, 0x0)       // Heavy Damage
    add_announcement(0x35, 0x4BD, 0x384, 0x0)       // Major Damage
    
    damage_early_call:
    add_announcement(0x4F, 0x494, 0x8708, 0x1)       // Major Blow from the Word Go
    
    OS.align(16)
    
    announcer_fgm_count_address:
    dw  announcer_fgm_count
    
// 801020F4 sing    
// add advantage fgm or abandon
// add throw coding
///final damage app 800EA248
// 801415AC

// 80141A38 801415AC 800E671C

} // __POKEMON_ANNOUNCER__