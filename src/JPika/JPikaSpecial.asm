// JPikaSpecial.asm

// This file contains subroutines used by JPika's special moves.

scope JPikaUSP {
    // @ Description
    // JPika's Up Special Collision Routine
    // J Equivalent (0x801506AC) of U (0x80152B6C) collision routine
    scope JPika_SpecialHiProcMap_: {
        addiu          sp, sp, -0x28
        sw             ra, 0x001c (sp)
        sw             s0, 0x0018 (sp)
        lw             t6, 0x0084 (a0)
        or             s0, a0, r0
        
        jal            0x800ddda8
        sw             t6, 0x0024 (sp)
        
        bnez           v0, _branch_1
        lw             a1, 0x0024 (sp)
        
        lhu            t7, 0x00ce (a1)
        andi           t8, t7, 0x0021
        
        beqz           t8, _branch_2
        nop            
        
        jal            0x800DEEC8
        or             a0, a1, r0
        
        jal            0x80153654
        or             a0, s0, r0
        
        b              _branch_4
        lw             t9, 0x0024 (sp)
        
        _branch_2:
        jal            0x80152DD8
        or             a0, s0, r0
        
        _branch_1:
        lw             t9, 0x0024 (sp)
        
        _branch_4:
        lhu            t0, 0x00ce (t9)
        andi           t1, t0, 0x0021
        
        beqzl          t1, _branch_3
        lw             ra, 0x001c (sp)
        
        jal            0x801535F4
        or             a0, s0, r0
        
        lw             ra, 0x001c (sp)
        
        _branch_3:
        lw             s0, 0x0018 (sp)
        addiu          sp, sp, 0x28
        
        jr             ra
        nop               
    }
    
}