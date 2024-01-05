
    // @ Description
    // ChargeSmashAttacks
    scope ChargeSmashAttacks {

        constant MAX_CHARGE_TIME(60)    // 1 second

        constant ITEM_SMASH_CHARGE_FRAME(22)
        // fsmash
        // 8014FE40

        // usmash/dsmash
        // 800D94C4

        charged_smash_fighter_array:
        dw 0,0,0,0
        dw 0,0,0,0

        shared_item_smash_table:
        dw  16  // BeamSwordSmash
        dw  22  // BatSmash
        dw  7   // FanSmash
        dw  15  // StarRodSmash

        // @ Description
        // Main subroutine that deals with charge smash attacks
        scope smash_attack_main: {
            OS.patch_start(0x54CD0, 0x800D94D0)
            j       smash_attack_main
            nop
            OS.patch_end()

            jal     0x800D9480          // og line 1
            addiu   a1, a1, 0xE1C8      // og line 2

            bnez    v0, _end            // branch if aerial transition
            nop
            
            Toggles.read(entry_charged_smashes, at) // at = toggle address
            beqz    at, _end            // branch if toggle disabled
            lw      v1, 0x0084(a0)      // v1 = fighter struct

            // todo: check item smash action

            // make sure they are doing a smash attack
            lw      t6, 0x0024(v1)      // t6 = action id
            slti    at, t6, Action.FSmashHigh  // at = 0 if FSmashHigh or higher
            bnez    at, _check_item_smash      // branch and check item smash if not fsmash or higher
            slti    at, t6, Action.AttackAirN  // at = 0 if AttackAirN or higher
            bnez    at, _smash_attack   // branch if Smashing
            _check_item_smash:
            lw      at, 0x084C(v1)      // held item
            beqz    at, _end            // branch to end if not holding an item
            addiu   at, r0, Action.BeamSwordSmash
            beq     at, t6, _smash_attack
            // addiu   at, r0, Action.BatSmash
            // beq     at, t6, _smash_attack
            addiu   at, r0, Action.FanSmash
            beq     at, t6, _smash_attack
            addiu   at, r0, Action.StarRodSmash
            bne     at, t6, _end        // branch if not doing a smash attack

            _smash_attack:
            lb      t2, 0xD(v1)         // get player port
            li      at, charged_smash_fighter_array
            sll     t2, t2, 3           // offset in table
            addu    t3, at, t2          // t3 = entry in table
            lw      t4, 0x0000(t3)      // load time player is charging smash attack

            lw      t0, 0x001C(v1)      // get current animation frame
            addiu   at, r0, 1
            bne     at, t0, _skip_initial // skip if not the first frame of animation
            nop

            // first frame of smash attack, initial setup
            sw      r0, 0x0004(t3)      // reset values
            sw      r0, 0x0000(t3)      // ~

            _skip_initial:
            lh      at, 0x01BC(v1)      // buttons held mask
            andi    t7, at, Joypad.A

            lw      at, 0x0008(v1)      // at = character id
            sll     at, at, 2           // at = offset
            li      t8, frame_table
            addu    t8, t8, at          // t8 = entry in charge frame table
            lw      t8, 0x0000(t8)      // ~

            addiu   at, r0, Action.USmash
            beql    at, t6, _check_smash_type
            lb      t1, 0x0001(t8)      // load up smash frame
            addiu   at, r0, Action.DSmash
            beql    at, t6, _check_smash_type
            lb      t1, 0x0002(t8)      // load down smash
            slti    at, t6, Action.FSmashHigh  // at = 0 if FSmashHigh or higher
            beqzl   at, _check_smash_type
            lb      t1, 0x0000(t8)      // load f smash if not down/up smash and action id is not an item smash
            // if here, item smash
            addiu   t6, t6, -0x80       // subtract 0x80
            li      at, shared_item_smash_table
            addu    t6, t6, at          // t6 = entry in item smash table
            lw      t1, 0x0000(t6)      // load frame to start charge smash

            _check_smash_type:
            beq     t1, t0, _charge_begin_check        // skip charged smash if not on the correct animation frame
            nop

            blt     t0, t1, _end        // branch if can't charge attack yet
            nop

            // if here, then player may be holding smash attack
            beqz    t4, _end     // end charge if not holding A
            nop

            _charge_begin_check:
            beqz    t7, _end_charge      // branch if not holding A
            nop
            bnez    t4, _increment_charge // branch if still charging
            lw      t5, 0x0074(a0)      // bone 1

            // initial, set variables
            lw      at, 0x0078(t5)      // load frame speed multiplier
            sw      at, 0x0004(t3)      // store fsm
            sw      r0, 0x0078(t5)      // set fsm to zero

            lw      t5, 0x0084(a0)      // t5 = player struct
            lw      at, 0x0A28(t5)
            bnez    at, _set_fsm
            li      at, GFXRoutine.CHARGE_SMASH
            // if here, set gfx overlay on player
            sw      at, 0x0A28(t5)      // overwrite current gfx routine

            _set_fsm:
            jal     0x8000BB04          // animation fsm subroutine
            addiu   a1, r0, 0
            addiu   t4, t4, 1           // charge time +=1
            sw      t4, 0x0000(t3)      // overwrite value
            FGM.play(0x528)
            b       _end
            nop

            _increment_charge:
            lw      t5, 0x0084(a0)      // t5 = player struct
            lw      at, 0x0A28(t5)
            bnez    at, _increment_charge_continue
            li      at, GFXRoutine.CHARGE_SMASH
            // if here, set gfx overlay on player
            lw      t6, 0x0074(a0)      // t5 = rendering obj
            lw      t6, 0x0078(t6)      // t5 = current FSM
            beqzl   t6, _increment_charge_continue
            sw      at, 0x0A28(t5)      // only overwrite current gfx routine if FSM = 0 (charging smash attack probably)
            _increment_charge_continue:
            addiu   t4, t4, 1           // charge time +=1
            sw      t4, 0x0000(t3)      // overwrite value
            addiu   at, r0, MAX_CHARGE_TIME
            bne     at, t4, _end
            nop

            _end_charge:
            lw      a1, 0x0004(t3)      // load old fsm
            beqz    a1, _end            // skip if old fsm is 0
            lw      t5, 0x0074(a0)      // bone 1 struct
            sw      r0, 0x0004(t3)      // remove old fsm
            jal     0x8000BB04          // fsm subroutine
            sw      a1, 0x0078(t5)      // overwrite fsm

            _end:
            lw      ra, 0x0014(sp)
            jr      ra
            addiu   sp, sp, 0x18

        }


        entry_mario:
        db 5        // forward
        db 5        // up
        db 4        // down
        db 0        // unused

        entry_fox:
        db 2        // forward
        db 3        // up
        db 2        // down
        db 0        // unused

        entry_dk:
        db 6        // forward
        db 5        // up
        db 3        // down
        db 0        // unused

        entry_samus:
        db 8        // forward
        db 8        // up
        db 3        // down
        db 0        // unused

        entry_link:
        db 4        // forward
        db 3        // up
        db 3        // down
        db 0        // unused

        entry_yoshi:
        db 9        // forward
        db 6        // up
        db 2        // down
        db 0        // unused

        entry_falcon:
        db 6        // forward
        db 2        // up
        db 3        // down
        db 0        // unused

        entry_ness:
        db 6        // forward
        db 6        // up
        db 8        // down
        db 0        // unused

        entry_kirby:
        db 3        // forward
        db 3        // up
        db 3        // down
        db 0        // unused

        entry_pikachu:
        db 3        // forward
        db 2        // up
        db 5        // down
        db 0        // unused

        entry_puff:
        db 3        // forward
        db 3        // up
        db 4        // down
        db 0        // unused

        entry_falco:
        db 8        // forward
        db 2        // up
        db 2        // down
        db 0        // unused

        entry_ganon:
        db 0x15     // forward
        db 6        // up
        db 9        // down
        db 0        // unused

        entry_drmario:
        db 3        // forward
        db 3        // up
        db 4        // down
        db 0        // unused

        entry_wario:
        db 3        // forward
        db 5        // up
        db 2        // down
        db 0        // unused

        entry_darksamus:
        db 7        // forward
        db 8        // up
        db 10       // down
        db 0        // unused

        entry_lucas:
        db 5        // forward
        db 5        // up
        db 3        // down
        db 0        // unused

        entry_bowser:
        db 0x12     // forward
        db 0xB      // up
        db 3        // down
        db 0        // unused

        entry_piano:
        db 2        // forward
        db 6        // up
        db 3        // down
        db 0        // unused

        entry_wolf:
        db 2        // forward
        db 3        // up
        db 4        // down
        db 0        // unused

        entry_conker:
        db 4        // forward
        db 7        // up
        db 3        // down
        db 0        // unused

        entry_mewtwo:
        db 0xD      // forward
        db 4        // up
        db 4        // down
        db 0        // unused

        entry_marth:
        db 7        // forward
        db 7        // up
        db 3        // down
        db 0        // unused

        entry_sonic:
        db 4        // forward
        db 2        // up
        db 2        // down
        db 0        // unused

        entry_super_sonic:
        db 3        // forward
        db 2        // up
        db 2        // down
        db 0        // unused

        entry_sheik:
        db 5        // forward
        db 8        // up
        db 2        // down
        db 0        // unused

        entry_marina:
        db 2        // forward
        db 4        // up
        db 2        // down
        db 0        // unused

        entry_dedede:
        db 8        // forward
        db 10       // up
        db 5        // down
        db 0        // unused

        entry_goemon:
        db 5        // forward
        db 4        // up
        db 3        // down
        db 0        // unused
        
        entry_ebisumaru:
        db 3        // forward
        db 3        // up
        db 3        // down
        db 0        // unused

        entry_peppy:
        db 3        // forward
        db 3        // up
        db 2        // down
        db 0        // unused

        entry_slippy:
        db 3        // forward
        db 3        // up
        db 2        // down
        db 0        // unused

        entry_banjo:
        db 4        // forward
        db 3        // up
        db 3        // down
        db 0        // unused

        entry_dragonking:
        db 7        // forward
        db 2        // up
        db 4        // down
        db 0        // unused

        frame_table:
        // vanilla fighters
        dw entry_mario  // mario
        dw entry_fox    // fox
        dw entry_dk     // dk
        dw entry_samus  // samus
        dw entry_mario  // luigi
        dw entry_link   // link
        dw entry_yoshi  // yoshi
        dw entry_falcon // falcon
        dw entry_kirby
        dw entry_pikachu
        dw entry_puff
        dw entry_ness
        // 1P mode fighters
        dw 0
        dw entry_mario
        dw entry_mario
        dw entry_fox
        dw entry_dk
        dw entry_samus
        dw entry_mario
        dw entry_link
        dw entry_yoshi
        dw entry_falcon
        dw entry_kirby
        dw entry_pikachu
        dw entry_puff
        dw entry_ness
        dw entry_dk
        // placeholders
        dw 0
        dw 0
        // remix fighters
        dw entry_falco      // FALCO
        dw entry_ganon      // GND
        dw entry_link       // YLINK
        dw entry_drmario    // DRM
        dw entry_wario      // WARIO
        dw entry_darksamus  // DARK SAMUS
        dw entry_link       // ELINK
        dw entry_samus      // JSAMUS
        dw entry_ness       // JNESS
        dw entry_lucas      // LUCAS
        dw entry_link       // JLINK
        dw entry_falcon     // JFALCON
        dw entry_fox        // JFOX
        dw entry_mario      // JMARIO
        dw entry_mario      // JLUIGI
        dw entry_dk         // JDK
        dw entry_pikachu    // EPIKA
        dw entry_puff       // JPUFF
        dw entry_puff       // EPUFF
        dw entry_kirby      // JKIRBY
        dw entry_yoshi      // JYOSHI
        dw entry_pikachu    // JPIKA
        dw entry_samus      // ESAMUS
        dw entry_bowser     // BOWSER
        dw entry_bowser     // GBOWSER
        dw entry_piano      // PIANO
        dw entry_wolf       // WOLF
        dw entry_conker     // CONKER
        dw entry_mewtwo     // MEWTWO
        dw entry_marth      // MARTH
        dw entry_sonic      // SONIC
        dw 0                // SANDBAG
        dw entry_super_sonic// SUPER SONIC
        dw entry_sheik      // SHEIK 
        dw entry_marina     // MARINA
        dw entry_dedede     // DEDEDE
        dw entry_goemon     // GOEMON
        dw entry_peppy      // PEPPY
        dw entry_slippy     // SLIPPY
        dw entry_banjo      // BANJO
        dw entry_mario      // METAL LUIGI
        dw entry_ebisumaru  // EBI
        dw entry_dragonking // DRAGON KING

        // remix polygons
        dw entry_wario
        dw entry_lucas
        dw entry_bowser
        dw entry_wolf
        dw entry_drmario
        dw entry_sonic
        dw entry_sheik
        dw entry_marina
        dw entry_falco
        dw entry_ganon
        dw entry_darksamus
        dw entry_marth
        dw entry_mewtwo
        dw entry_dedede
        dw entry_link
        dw entry_goemon
        dw entry_conker
        dw entry_banjo
}