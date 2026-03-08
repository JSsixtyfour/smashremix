// Coded by HaloFactory

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
        dw  14  // BeamSwordSmash
        dw  22  // BatSmash
        dw  7   // FanSmash
        dw  15  // StarRodSmash

        scope smash_attack_start: {
            // Runs right as the action is changed into the smash attack action
            // a0 = character struct
            // a1 = new action id
            OS.routine_begin(0x20)
            sw a0, 0x4(sp)
            sw a1, 0x8(sp)

            jal smash_attack_logic
            lw a0, 0x4(a0)

            lw a0, 0x4(sp)
            lw a1, 0x8(sp)

            _end:
            OS.routine_end(0x20)
        }
        
        // @ Description
        // Main subroutine that deals with charge smash attacks
        scope smash_attack_main: {
            OS.patch_start(0x54CD0, 0x800D94D0)
            j       smash_attack_main
            nop
            OS.patch_end()

            lw at, 0x0074(a0) // bone 1
            lw at, 0x0078(at) // load frame speed multiplier

            beqz at, _charging
            nop

            _normal:
            jal     0x800D9480          // og line 1: ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
            addiu   a1, a1, 0xE1C8      // og line 2

            bnez    v0, _end            // branch if aerial transition
            nop

            _charging:
            jal smash_attack_logic
            nop
            
            _end:
            lw      ra, 0x0014(sp)
            jr      ra
            addiu   sp, sp, 0x18
        }

        scope smash_attack_logic: {
            OS.routine_begin(0x20)

            Toggles.read(entry_charged_smashes, at) // at = toggle address
            beqz    at, _end            // branch if toggle disabled
            lw      v1, 0x0084(a0)      // v1 = fighter struct

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
            addiu   t0, t0, 1
            addiu   at, r0, 1
            bne     at, t0, _skip_initial // skip if not the first frame of animation
            nop

            // first frame of smash attack, initial setup
            sw      r0, 0x0004(t3)      // reset values
            sw      r0, 0x0000(t3)      // ~
            or      t4, r0, r0          // reset variable in register too

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

            _shuffle:
            lli     at, 0xFF
            sh      at, 0x276(t5) // shuffle_tics
            sb      r0, 0x272(t5) // shuffle_frame_index = 0
            lli     at, 0x2
            sb      at, 0x274(t5) // is_shuffle_electric = TRUE (it has lower shuffle)
            lli     at, 0x4
            sb      at, 0x273(t5) // shuffle_index_max = 4

            b       _end
            nop

            _increment_charge:
            lw      t5, 0x0074(a0)      // bone 1
            lw      at, 0x0078(t5)      // load frame speed multiplier
            bnez    at, _end            // if not charging, skip
            nop
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

            _spawn_smoke: {
                andi    at, t4, 0x000F  // at = charge % 16
                bnez    at, _check_max_charge
                nop

                addiu sp, sp, -0x50
                sw a0, 0x14(sp)
                sw a1, 0x18(sp)
                sw t3, 0x1C(sp)
                sw t4, 0x20(sp)
                sw v1, 0x24(sp)

                // build a vector 3 structure on 0x4(sp)
                lw      at, 0x78(v1) // at = position vec3

                lwc1    f2, 0x0(at) // f2 = player X
                lwc1    f4, 0x44(v1) // f4 = facing direction
                cvt.s.w f4, f4 // f4 = facing direction (float)
                lui     t0, 0xC2A0 // -80.0f
                mtc1    t0, f6 // f6 = -80
                mul.s   f4, f4, f6 // f4 = offset * facing direction
                add.s   f2, f2, f4
                swc1    f2, 0x4(sp) // save X

                lwc1    f4, 0x4(at) // f4 = player Y
                lui     t0, 0xC2A0 // -80.0f
                mtc1    t0, f2 // f2 = -80
                add.s   f4, f4, f2 // f4 = player Y - 80
                swc1    f4, 0x8(sp) // save Y

                sw      r0, 0xC(sp) // save Z = 0

                addiu   a0, sp, 0x4 // a0 (position) = pointer to vector we created

                addiu   sp, sp, -0x20
                lw      a1, 0x44(v1) // a1 = facing direction
                subu    a1, r0, a1 // a1 = -facing direction
                jal     0x800FF278 // efManagerDustHeavyMakeEffect(Vec3f *pos, s32 lr)
                lui     a2, 0x3F80 // a2 = 1.0F
                addiu   sp, sp, 0x20

                lw a0, 0x14(sp)
                lw a1, 0x18(sp)
                lw t3, 0x1C(sp)
                lw t4, 0x20(sp)
                lw v1, 0x24(sp)
                addiu sp, sp, 0x50
            }

            _check_max_charge:
            Toggles.read(entry_charged_smashes, at) // at = toggle
            andi    at, at, 2                       // at != 0 if 2
            bnez    at, _end                        // don't auto cancel charged smash if unlimited time
            addiu   at, r0, MAX_CHARGE_TIME
            bne     at, t4, _end
            nop

            _end_charge:
            sh      r0, 0x276(v1)       // shuffle_tics = 0 (stop shaking)
            lw      a1, 0x0004(t3)      // load old fsm
            beqz    a1, _end            // skip if old fsm is 0
            lw      t5, 0x0074(a0)      // bone 1 struct
            sw      r0, 0x0004(t3)      // remove old fsm
            jal     0x8000BB04          // fsm subroutine
            sw      a1, 0x0078(t5)      // overwrite fsm

            _end:
            OS.routine_end(0x20)
        }

        // Each entry must have 4 pairs of (x, y)
        // Index is (is_shuffle_electric - 2),
        // so is_shuffle_electric=2 means entry 0 here
        CUSTOM_SHUFFLE_TABLE:
        // Entry 1: smash attack charge
        float32 8.0; float32 0;
        float32 0.0; float32 8.0;
        float32 -8.0; float32 0;
        float32 0.0; float32 -8.0;

        // ftDisplayMainProcDisplay(GObj *fighter_gobj)
        // 0x800F293C+0x538
        // This function handles fighter display; at this point it
        // is about to load the array used for the shuffle/vibration/shake
        // that happens during hitlag when hit
        // The game has 2 arrays (normal, electric) and uses is_shuffle_electric (0x274)
        // in the fighter struct to know which index to use (0 or 1)
        // Here, if index > 1 we'll load from our custom table
        scope custom_shuffle: {
            OS.patch_start(0x6E674, 0x800F2E74)
            j custom_shuffle
            nop
            _return:
            OS.patch_end()

            // t3 = shuffle_index 0x272(fp)
            // t5 = is_shuffle_electric 0x274(fp)
            // t8 = displacement needed to get to the current index in the array (index goes round to animate the shuffle 0x272)
            // t6 = displacement needed to get to the correct array itself (based on being electric or not 0x274)
            // t4 = t6 + t8, so if we add the table address to t4 we get the final address

            _check_index:
            lli at, 0x2
            blt t5, at, _original // if is_shuffle_electric is 0 or 1, original behavior
            nop

            _custom_arrays:
            addiu t5, t5, -2 // index -= 2 to make our first custom entry as index 0 in our table and so on

            li t7, CUSTOM_SHUFFLE_TABLE

            // copied from original code, get offsets based on indexes
            sll t8, t3, 0x3
            sll t6, t5, 0x5
            addu t4, t6, t8

            _original:
            addu v0, t4, t7 // adds t4 (displacement) to t7 (base array address) to get the final address
            lw a1, 0(v0)

            _end:
            j _return // return
            nop
        }

        // Unnamed function 800C9F70
        // This updates item positions for shuffle on hitlag
        // 800C9F70+50
        scope custom_shuffle_item: {
            OS.patch_start(0x459A0, 0x800C9FC0)
            j custom_shuffle_item
            lwc1 f6, 0x48(sp) // original line 1
            _return:
            OS.patch_end()

            // t8 = is_shuffle_electric 0x274(fp)
            // v1 = dFTRenderMainShufflePositions

            _check_index:
            lli at, 0x2
            blt t8, at, _original // if is_shuffle_electric is 0 or 1, original behavior
            nop

            _custom_arrays:
            addiu t8, t8, -2 // index -= 2 to make our first custom entry as index 0 in our table and so on
            li v1, CUSTOM_SHUFFLE_TABLE

            _original:
            _end:
            j _return // return
            sll t9, t8, 0x5 // original line 2
        }

        entry_mario:
        entry_luigi:
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

        entry_lanky:
        db 6        // forward
        db 6        // up
        db 6        // down
        db 0        // unused
        
        entry_giga:
        db 42
        db 23
        db 10
        db 0

        OS.align(4)

        // character table with pointers to each characters charge smash attack frame data
        constant frame_table_origin(origin())
        frame_table:
        fill Character.NUM_CHARACTERS * 4

        // @ Description
        // NOTE: only works for remix characters
        macro set_charged_smash_attacks(character_id, charged_smash_array) {
            pushvar origin, base
            origin  ChargeSmashAttacks.frame_table_origin + ({character_id} * 4)
            dw  {charged_smash_array}
            OS.patch_end()
        }

        // Set charged smash attacks starting frame for each character
        // YOU CAN USE THIS OUTSIDE OF THIS FILE
        // VANILLA
        set_charged_smash_attacks(Character.id.MARIO, entry_mario)
        set_charged_smash_attacks(Character.id.FOX, entry_fox)
        set_charged_smash_attacks(Character.id.DK, entry_dk)
        set_charged_smash_attacks(Character.id.SAMUS, entry_samus)
        set_charged_smash_attacks(Character.id.LUIGI, entry_mario)
        set_charged_smash_attacks(Character.id.LINK, entry_link)
        set_charged_smash_attacks(Character.id.YOSHI, entry_yoshi)
        set_charged_smash_attacks(Character.id.FALCON, entry_falcon)
        set_charged_smash_attacks(Character.id.KIRBY, entry_kirby)
        set_charged_smash_attacks(Character.id.PIKA, entry_pikachu)
        set_charged_smash_attacks(Character.id.PUFF, entry_puff)
        set_charged_smash_attacks(Character.id.NESS, entry_ness)
        // VANILLA SPECIAL
        set_charged_smash_attacks(Character.id.METAL, entry_mario)
        set_charged_smash_attacks(Character.id.BOSS, entry_mario)
        // VANILLA POLY
        set_charged_smash_attacks(Character.id.NMARIO, entry_mario)
        set_charged_smash_attacks(Character.id.NFOX, entry_fox)
        set_charged_smash_attacks(Character.id.NDK, entry_dk)
        set_charged_smash_attacks(Character.id.NSAMUS, entry_samus)
        set_charged_smash_attacks(Character.id.NLUIGI, entry_mario)
        set_charged_smash_attacks(Character.id.NLINK, entry_link)
        set_charged_smash_attacks(Character.id.NYOSHI, entry_yoshi)
        set_charged_smash_attacks(Character.id.NFALCON, entry_falcon)
        set_charged_smash_attacks(Character.id.NKIRBY, entry_kirby)
        set_charged_smash_attacks(Character.id.NPIKA, entry_pikachu)
        set_charged_smash_attacks(Character.id.NPUFF, entry_puff)
        set_charged_smash_attacks(Character.id.NNESS, entry_ness)
        set_charged_smash_attacks(Character.id.GDK, entry_dk)
        // REMIX
        set_charged_smash_attacks(Character.id.FALCO, entry_falco)
        set_charged_smash_attacks(Character.id.GND, entry_ganon)
        set_charged_smash_attacks(Character.id.YLINK, entry_link)
        set_charged_smash_attacks(Character.id.DRM, entry_drmario)
        set_charged_smash_attacks(Character.id.WARIO, entry_wario)
        set_charged_smash_attacks(Character.id.DSAMUS, entry_darksamus)
        set_charged_smash_attacks(Character.id.ELINK, entry_link)
        set_charged_smash_attacks(Character.id.JSAMUS, entry_samus)
        set_charged_smash_attacks(Character.id.JNESS, entry_ness)
        set_charged_smash_attacks(Character.id.LUCAS, entry_lucas)
        set_charged_smash_attacks(Character.id.JLINK, entry_link)
        set_charged_smash_attacks(Character.id.JFALCON, entry_falcon)
        set_charged_smash_attacks(Character.id.JFOX, entry_fox)
        set_charged_smash_attacks(Character.id.JMARIO, entry_mario)
        set_charged_smash_attacks(Character.id.JLUIGI, entry_mario)
        set_charged_smash_attacks(Character.id.JDK, entry_dk)
        set_charged_smash_attacks(Character.id.EPIKA, entry_pikachu)
        set_charged_smash_attacks(Character.id.JPUFF, entry_puff)
        set_charged_smash_attacks(Character.id.EPUFF, entry_puff)
        set_charged_smash_attacks(Character.id.JKIRBY, entry_kirby)
        set_charged_smash_attacks(Character.id.JYOSHI, entry_yoshi)
        set_charged_smash_attacks(Character.id.JPIKA, entry_pikachu)
        set_charged_smash_attacks(Character.id.ESAMUS, entry_samus)
        set_charged_smash_attacks(Character.id.BOWSER, entry_bowser)
        set_charged_smash_attacks(Character.id.GBOWSER, entry_giga)
        set_charged_smash_attacks(Character.id.PIANO, entry_piano)
        set_charged_smash_attacks(Character.id.WOLF, entry_wolf)
        set_charged_smash_attacks(Character.id.CONKER, entry_conker)
        set_charged_smash_attacks(Character.id.MTWO, entry_mewtwo)
        set_charged_smash_attacks(Character.id.MARTH, entry_marth)
        set_charged_smash_attacks(Character.id.SONIC, entry_sonic)
        set_charged_smash_attacks(Character.id.SANDBAG, entry_mario)
        set_charged_smash_attacks(Character.id.SSONIC, entry_sonic)
        set_charged_smash_attacks(Character.id.SHEIK, entry_sheik)
        set_charged_smash_attacks(Character.id.MARINA, entry_marina)
        set_charged_smash_attacks(Character.id.DEDEDE, entry_dedede)
        set_charged_smash_attacks(Character.id.GOEMON, entry_goemon)
        set_charged_smash_attacks(Character.id.PEPPY, entry_peppy)
        set_charged_smash_attacks(Character.id.SLIPPY, entry_slippy)
        set_charged_smash_attacks(Character.id.BANJO, entry_banjo)
        set_charged_smash_attacks(Character.id.MLUIGI, entry_mario)
        set_charged_smash_attacks(Character.id.EBI, entry_ebisumaru)
        set_charged_smash_attacks(Character.id.DRAGONKING, entry_dragonking)
        // REMIX POLYGONS
        set_charged_smash_attacks(Character.id.NWARIO, entry_wario)
        set_charged_smash_attacks(Character.id.NLUCAS, entry_lucas)
        set_charged_smash_attacks(Character.id.NBOWSER, entry_bowser)
        set_charged_smash_attacks(Character.id.NWOLF, entry_wolf)
        set_charged_smash_attacks(Character.id.NDRM, entry_drmario)
        set_charged_smash_attacks(Character.id.NSONIC, entry_sonic)
        set_charged_smash_attacks(Character.id.NSHEIK, entry_sheik)
        set_charged_smash_attacks(Character.id.NMARINA, entry_marina)
        set_charged_smash_attacks(Character.id.NFALCO, entry_falco)
        set_charged_smash_attacks(Character.id.NGND, entry_ganon)
        set_charged_smash_attacks(Character.id.NDSAMUS, entry_darksamus)
        set_charged_smash_attacks(Character.id.NMARTH, entry_marth)
        set_charged_smash_attacks(Character.id.NMTWO, entry_mewtwo)
        set_charged_smash_attacks(Character.id.NDEDEDE, entry_dedede)
        set_charged_smash_attacks(Character.id.NYLINK, entry_link)
        set_charged_smash_attacks(Character.id.NGOEMON, entry_goemon)
        set_charged_smash_attacks(Character.id.NCONKER, entry_conker)
        set_charged_smash_attacks(Character.id.NBANJO, entry_banjo)
        // See NPeach.asm for Peach's entry
        // See NCrash.asm for Peach's entry
}