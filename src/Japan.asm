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
include "String.asm"

scope Japan {
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
        Toggles.single_player_guard(Toggles.entry_japanese_hitlag, japanese_hitlag_end_)
        lui     at, 0x4080                  // Japanese style, this adds less to the hitlag calculation thus decreasing hitlag
        mtc1    at, f16                     // original line 2
        
        j      japanese_hitlag_end_          // return
        nop
    }
    
    // @ Description
    // Toggle for Japanese Style DI.
    // The percent effect of DI is different in the international vs J versions, the format of the coding is very similar to DK's Cargo hold 
    // In the US 0x40066666 (2.09999990463) and in Japan 0x3fc00000 (1.5)
    // US Version, thus allowing for greater DI distance
    scope japanese_di_: {
        OS.patch_start(0xBB31C, 0x801408DC)
        j       japanese_di_
        nop
        japanese_di_end_:
        OS.patch_end()
        
        
        lui     at, 0x8019                  // original line 1
        lwc1    f0, 0xC0E0(at)              // original line 2
        Toggles.single_player_guard(Toggles.entry_japanese_di, japanese_di_end_)
        lui     at, 0x3FC0                  // Japanese coding part 1
        mtc1    at, f0                      // Japanese coding part 2
        
        j      japanese_di_end_          // return
        nop
    }
	
	// @ Description
    // Toggle for Japanese Style Shield Stun.
    // The length of shield stun is different in the international vs J versions.
    // In the US 0x3FCF5C29 (1.62) and in Japan 0x3FE00000 (1.75)
    scope japanese_shieldstun_: {
        OS.patch_start(0xC3B78, 0x80149138)
        j       japanese_shieldstun_
        lwc1	f8, 0xC200(at)				// original line 1
        japanese_shieldstun_end_:
        OS.patch_end()
        
        
        lw		t7, 0x07C8(v0)              // original line 2
        Toggles.single_player_guard(Toggles.entry_japanese_shieldstun, japanese_shieldstun_end_)
        lui     at, 0x3FE0                  // Japanese coding part 1
        mtc1    at, f8                      // Japanese coding part 2
        
        j      japanese_shieldstun_end_     // return
        nop
    }
    
    // @ Description
    // Toggle for the Momentum Sliding Glitch present in the Japanese version.
    // A very straightforward fix was added to the international version of Smash
    // During a momentum slide input it checks the current velocity of the character against character's max run speed
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
        Toggles.single_player_guard(Toggles.entry_momentum_slide, momentum_slide_end_)
        j       0x8013F150
        nop
 
        _end:
        j       momentum_slide_end_                          // return
        nop
    }

    // @ Description
    // These are the differences between the U and J hit sound fgm_ids
    constant PUNCH_S_DIFF(FGM.hit.J_PUNCH_S - FGM.hit.PUNCH_S)
    constant PUNCH_M_DIFF(FGM.hit.J_PUNCH_M - FGM.hit.PUNCH_M)
    constant PUNCH_L_DIFF(FGM.hit.J_PUNCH_L - FGM.hit.PUNCH_L)
    constant KICK_S_DIFF(FGM.hit.J_KICK_S - FGM.hit.KICK_S)
    constant KICK_M_DIFF(FGM.hit.J_KICK_M - FGM.hit.KICK_M)
    constant KICK_L_DIFF(FGM.hit.J_KICK_L - FGM.hit.KICK_L)

    // @ Description
    // This is the difference between the U and J beam sword sound fgm_ids
    // It is the same for both light and heavy, so we just calculate one
    constant BEAM_SWORD_DIFF(FGM.item.J_BEAM_SWORD_LIGHT - FGM.item.BEAM_SWORD_LIGHT)

    // @ Description
    // This changes the hit and beam sword sound effects for J characters or all characters if J sound toggle is ALWAYS
    scope japanese_sfx_: {
        OS.patch_start(0x0005B06C, 0x800DF86C)
        jal     japanese_sfx_
        sw      t7, 0x0004(s0)                 // original line 1
        OS.patch_end()

        // s1 = player struct

        and     a0, a0, at                     // original line 2
        andi    a0, a0, 0xFFFF                 // original line 4 - now a0 is the fgm_id

        slti    t7, a0, FGM.item.BEAM_SWORD_HEAVY
        beqzl   t7, _beam_sword                // if the fgm_id >= FGM.item.BEAM_SWORD_HEAVY, check if beam sword
        ori     at, r0, BEAM_SWORD_DIFF        // at = BEAM_SWORD_DIFF

        // otherwise, check if a hit sound
        lli     t7, FGM.hit.PUNCH_S            // t7 = FGM.hit.PUNCH_S
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_S, go to toggle check
        ori     at, r0, PUNCH_S_DIFF           // at = PUNCH_S_DIFF
        lli     t7, FGM.hit.PUNCH_M            // t7 = FGM.hit.PUNCH_M
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_M, go to toggle check
        ori     at, r0, PUNCH_M_DIFF           // at = PUNCH_M_DIFF
        lli     t7, FGM.hit.PUNCH_L            // t7 = FGM.hit.PUNCH_L
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_L, go to toggle check
        ori     at, r0, PUNCH_L_DIFF           // at = PUNCH_L_DIFF
        lli     t7, FGM.hit.KICK_S             // t7 = FGM.hit.KICK_S
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_S, go to toggle check
        ori     at, r0, KICK_S_DIFF            // at = KICK_S_DIFF
        lli     t7, FGM.hit.KICK_M             // t7 = FGM.hit.KICK_M
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_M, go to toggle check
        ori     at, r0, KICK_M_DIFF            // at = KICK_M_DIFF
        lli     t7, FGM.hit.KICK_L             // t7 = FGM.hit.KICK_L
        beql    t7, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_L, go to toggle check
        ori     at, r0, KICK_L_DIFF            // at = KICK_L_DIFF

        b       _return                        // otherwise, return
        nop

        _beam_sword:
        // beam sword
        lli     t7, FGM.item.BEAM_SWORD_LIGHT  // t7 = FGM.item.BEAM_SWORD_LIGHT
        beq     t7, a0, _check_toggle          // if the fgm_id = FGM.item.BEAM_SWORD_LIGHT, go to toggle check
        nop
        lli     t7, FGM.item.BEAM_SWORD_MEDIUM // t7 = FGM.item.BEAM_SWORD_MEDIUM
        beq     t7, a0, _check_toggle          // if the fgm_id = FGM.item.BEAM_SWORD_MEDIUM, go to toggle check
        nop
        lli     t7, FGM.item.BEAM_SWORD_HEAVY  // t7 = FGM.item.BEAM_SWORD_HEAVY
        bne     t7, a0, _return                // if the fgm_id != FGM.item.BEAM_SWORD_HEAVY, skip
        nop

        _check_toggle:
        li      t7, Toggles.entry_japanese_sounds
        lw      t7, 0x0004(t7)                 // t7 = 1 if always, 2 if never, 0 if default
        lli     v1, 0x0001                     // v1 = always
        beql    t7, v1, _return                // if set to always,
        addu    a0, a0, at                     // then use J sound
        lli     v1, 0x0002                     // v1 = never
        beq     t7, v1, _return                // if set to never, then use u sounds
        nop                                    // otherwise, test if player is J player

        lbu     t7, 0x000B(s1)                 // t7 = character_id
        li      v1, Character.sound_type.table // v1 = address of sound_type table
        addu    v1, v1, t7                     // v1 = address of sound_type
        lbu     v1, 0x0000(v1)                 // v1 = sound_type
        addiu   t7, r0, Character.sound_type.J // t7 = sound_type.J
        beql    t7, v1, _return                // if sound_type is J,
        addu    a0, a0, at                     // then use J sound

        _return:
        lw      t7, 0x0004(s0)                 // restore t7, just in case
        jr      ra
        addiu   v1, t7, -0x0004                // restore v1, just in case
    }
    
    // @ Description
    // This changes the sound effects for when Link's bomb hits another bomb for J characters or all characters if J sound toggle is ALWAYS
    // It is coded to be more generic, so may apply to other sounds that we don't know about
    scope japanese_sfx_link_bomb_collide_: {
        OS.patch_start(0x000E8F88, 0x8016E548)
        jal     japanese_sfx_link_bomb_collide_
        lw      t1, 0x003C(v1)                 // original line 2
        OS.patch_end()

        // check if a hit sound
        lli     t9, FGM.hit.PUNCH_S            // t9 = FGM.hit.PUNCH_S
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_S, go to toggle check
        ori     at, r0, PUNCH_S_DIFF           // at = PUNCH_S_DIFF
        lli     t9, FGM.hit.PUNCH_M            // t9 = FGM.hit.PUNCH_M
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_M, go to toggle check
        ori     at, r0, PUNCH_M_DIFF           // at = PUNCH_M_DIFF
        lli     t9, FGM.hit.PUNCH_L            // t9 = FGM.hit.PUNCH_L
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_L, go to toggle check
        ori     at, r0, PUNCH_L_DIFF           // at = PUNCH_L_DIFF
        lli     t9, FGM.hit.KICK_S             // t9 = FGM.hit.KICK_S
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.KICK_S, go to toggle check
        ori     at, r0, KICK_S_DIFF            // at = KICK_S_DIFF
        lli     t9, FGM.hit.KICK_M             // t9 = FGM.hit.KICK_M
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.KICK_M, go to toggle check
        ori     at, r0, KICK_M_DIFF            // at = KICK_M_DIFF
        lli     t9, FGM.hit.KICK_L             // t9 = FGM.hit.KICK_L
        beql    t9, t2, _check_toggle          // if the fgm_id = FGM.hit.KICK_L, go to toggle check
        ori     at, r0, KICK_L_DIFF            // at = KICK_L_DIFF

        b       _return                        // otherwise, return
        nop

        _check_toggle:
        li      t9, Toggles.entry_japanese_sounds
        lw      t9, 0x0004(t9)                 // t9 = 1 if always, 2 if never, 0 if default
        lli     t3, 0x0001                     // t3 = always
        beql    t9, t3, _return                // if set to always,
        addu    t2, t2, at                     // then use J sound
        lli     t3, 0x0002                     // t3 = never
        beq     t9, t3, _return                // if set to never, then use u sounds
        nop                                    // otherwise, test if player is J player

        lw      t4, 0x0020(sp)                 // t4 = player struct address (maybe)
        beqz    t4, _return                    // if t4 is zero, then not a player struct, so use U sound
        nop
        li      t9, Global.p_struct_head       // t9 = pointer to player struct linked list
        lw      t9, 0x0000(t9)                 // t9 = 1p player struct address
        _loop:
        beqz    t9, _return                    // if t9 is zero, then player structs not initialized or we reached the end of the linked list, so use U sound
        nop
        beq     t4, t9, _check_char            // if t4 is a player struct address, check if character is J
        nop
        b       _loop                          // loop over all player structs
        lw      t9, 0x0000(t9)                 // t9 = next player struct address

        _check_char:
        lbu     t9, 0x000B(t4)                 // t9 = character_id
        li      t3, Character.sound_type.table // t3 = address of sound_type table
        addu    t3, t3, t9                     // t3 = address of sound_type
        lbu     t3, 0x0000(t3)                 // t3 = sound_type
        addiu   t9, r0, Character.sound_type.J // t9 = sound_type.J
        beql    t9, t3, _return                // if sound_type is J,
        addu    t2, t2, at                     // then use J sound

        _return:
        jr      ra
        sh      t2, 0x156(s0)                  // original line 1
    }

    // @ Description
    // This changes the sound effects for when Link's boomerang hits a Link bomb for J characters or all characters if J sound toggle is ALWAYS
    // It is coded to be more generic, so may apply to other sounds that we don't know about
    scope japanese_sfx_link_boomerang_collide_: {
        OS.patch_start(0xE045C, 0x80165A1C)
        jal     japanese_sfx_link_boomerang_collide_
        lbu     t2, 0x002E(v1)                 // original line 2
        OS.patch_end()

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t9, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        lh      t4, 0x0156(s0)              // save this since we don't want to update it
        sw      t4, 0x0014(sp)              // ~

        lw      t4, 0x0008(a0)              // t4 = player object address (maybe)
        bnezl   t4, pc() + 8                // if t4 is not zero
        lw      t4, 0x0084(t4)              // ...then load player struct (maybe)
        sw      t4, 0x0020(sp)              // save player struct address to where japanese_sfx_link_bomb_collide_ expects it

        jal     japanese_sfx_link_bomb_collide_
        or      t2, r0, t3                  // t2 = t3 (fgm_id)
        or      t3, r0, t2                  // t3 = updated fgm_id
        lw      t4, 0x0014(sp)              // ~
        sh      t4, 0x0156(s0)              // restore this since we don't want to update it

        lw      ra, 0x0004(sp)              // restore registers
        lw      t9, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        sh      t3, 0x146(s0)                  // original line 1
    }

    // @ Description
    // This changes the sound effects for when J characters' projectiles hit a character or for all characters if J sound toggle is ALWAYS
    scope japanese_sfx_projectile_: {
        OS.patch_start(0x0005ED9C, 0x800E359C)
        j       japanese_sfx_projectile_
        lhu     a0, 0x0046(s1)                 // original line 2 (FGM_ID)
        japanese_sfx_projectile_return:
        OS.patch_end()

        // check if a hit sound
        lli     t9, FGM.hit.PUNCH_S            // t9 = FGM.hit.PUNCH_S
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_S, go to toggle check
        ori     at, r0, PUNCH_S_DIFF           // at = PUNCH_S_DIFF
        lli     t9, FGM.hit.PUNCH_M            // t9 = FGM.hit.PUNCH_M
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_M, go to toggle check
        ori     at, r0, PUNCH_M_DIFF           // at = PUNCH_M_DIFF
        lli     t9, FGM.hit.PUNCH_L            // t9 = FGM.hit.PUNCH_L
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.PUNCH_L, go to toggle check
        ori     at, r0, PUNCH_L_DIFF           // at = PUNCH_L_DIFF
        lli     t9, FGM.hit.KICK_S             // t9 = FGM.hit.KICK_S
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_S, go to toggle check
        ori     at, r0, KICK_S_DIFF            // at = KICK_S_DIFF
        lli     t9, FGM.hit.KICK_M             // t9 = FGM.hit.KICK_M
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_M, go to toggle check
        ori     at, r0, KICK_M_DIFF            // at = KICK_M_DIFF
        lli     t9, FGM.hit.KICK_L             // t9 = FGM.hit.KICK_L
        beql    t9, a0, _check_toggle          // if the fgm_id = FGM.hit.KICK_L, go to toggle check
        ori     at, r0, KICK_L_DIFF            // at = KICK_L_DIFF

        b       _return                        // otherwise, return
        nop

        _check_toggle:
        li      t9, Toggles.entry_japanese_sounds
        lw      t9, 0x0004(t9)                 // t9 = 1 if always, 2 if never, 0 if default
        lli     t3, 0x0001                     // t3 = always
        beql    t9, t3, _return                // if set to always,
        addu    a0, a0, at                     // then use J sound
        lli     t3, 0x0002                     // t3 = never
        beq     t9, t3, _return                // if set to never, then use u sounds
        nop                                    // otherwise, test if player is J player

        lw      t4, 0x0008(s0)                 // t4 = projectile struct address (maybe)
        beqz	t4, _return                    // if t4 is zero, then not a projectile struct, so use U sound
		nop
		lw      t4, 0x0084(t4)                 // t4 = player struct address (maybe)
        beqz    t4, _return                    // if t4 is zero, then not a player struct, so use U sound
        nop
        li      t9, Global.p_struct_head       // t9 = pointer to player struct linked list
        lw      t9, 0x0000(t9)                 // t9 = 1p player struct address
        _loop:
        beqz    t9, _return                    // if t9 is zero, then player structs not initialized or we reached the end of the linked list, so use U sound
        nop
        beq     t4, t9, _check_char            // if t4 is a player struct address, check if character is J
        nop
        b       _loop                          // loop over all player structs
        lw      t9, 0x0000(t9)                 // t9 = next player struct address

        _check_char:
        lbu     t9, 0x000B(t4)                 // t9 = character_id
        li      t3, Character.sound_type.table // t3 = address of sound_type table
        addu    t3, t3, t9                     // t3 = address of sound_type
        lbu     t3, 0x0000(t3)                 // t3 = sound_type
        addiu   t9, r0, Character.sound_type.J // t9 = sound_type.J
        beql    t9, t3, _return                // if sound_type is J,
        addu    a0, a0, at                     // then use J sound

        _return:
        jal     0x800269C0                     // original line 1
        nop

        j       japanese_sfx_projectile_return
        nop
    }

    // @ Description
    // This changes the reflect multiplier for J characters
    scope reflect_: {
        constant J_MULTIPLIER(0x3FC0)      // float:1.5
        
        OS.patch_start(0xE1814, 0x80166DD4)
        j       reflect_
        nop
        _return:
        OS.patch_end()
        
        // v1 = projectile struct
        // at this point in the routine the projectile's "owner" has already been set as the reflecting character
        lui     at, 0x8019                     // original line 1
        lwc1    f4, 0xCA78(at)                 // original line 2 (f4 = reflect multiplier)
        lw      t0, 0x0008(v1)                 // t0 = projectile owner object struct
        lw      t0, 0x0084(t0)                 // t0 = projectile owner player struct
        lw      t0, 0x0008(t0)                 // t0 = projectile owner id (reflecting character)
        li      at, Character.sound_type.table // at = address of sound_type table
        addu    at, at, t0                     // at = address of sound_type
        lbu     at, 0x0000(at)                 // at = sound_type
        addiu   t0, r0, Character.sound_type.J // t0 = sound_type.J
        bne     at, t0, _end                   // skip if sound_type != J
        nop
        // loads the J multiplier if execution reaches here
        lui     at, J_MULTIPLIER               // ~
        mtc1    at, f4                         // f4 = J_MULTIPLIER
        
        _end:
        j       _return                        // return
        nop
        
    }
}

} // __JAPAN__
