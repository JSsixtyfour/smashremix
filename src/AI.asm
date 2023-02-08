// AI.asm (by bit)
if !{defined __AI__} {
define __AI__()
print "included AI.asm\n"

// @ Description
// This file includes things that make the AIs/CPUs suck a little less.

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

scope AI {

    // @ Description
    // All Computers Are Level 9 By Default [Mada0]
    pushvar origin, base
    origin 0x42D38
    db     0x09
    origin 0x42DAC
    db     0x09
    origin 0x42E20
    db     0x09
    origin 0x42E94
    db     0x09
    pullvar base, origin

    // @ Description
    // This removes the up b check allowing the CPU to recover multiple times [bit].
    scope recovery_fix_: {
        OS.patch_start(0x000AFFBC, 0x8013557C)
        jal     recovery_fix_._guard
        nop                                 // original line 2
        OS.patch_end()

        _original:
        // if here, improved AI is off, so we use the original logic
        bnez    t1, _j_0x80135628           // original line 1 (modified to branch to jump)
        nop
        jr      ra
        nop

        _guard:
		// Fix if Remix 1P
        addiu   v1, r0, 0x0004
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, at) // at = Mode Flag Address
        beq     at, v1, _fix_recovery       // if Remix 1p, automatic advanced ai
        nop

		_check_level_10:
		lbu		v1, 0x0013(s0)				// v1 = cpu level
		slti	v1, v1, 10					// t6 = 0 if 10 or greater
		beqz	v1, _fix_recovery			// improved recovery if level 10

		// No fix if Vanilla 1P
        OS.read_word(Global.match_info, at)	// at = current match info struct
		lbu		v1, 0x0000(at)			//
        lli     at, Global.GAMEMODE.CLASSIC
        beq     at, v1, _original         	// dont use toggle if 1P/RTTF
		nop

		// Fix if improved AI is on
        Toggles.guard(Toggles.entry_improved_ai, _original)

        // if here, improved AI is on, so we skip the up b check
        _fix_recovery:
        jr      ra
        nop

        _j_0x80135628:
        j       0x80135628                  // jump to 0x80135628
        nop
    }

    // @ Description
    // Chance to execute various rolls / 100
    constant CHANCE_FORWARD(30)
    constant CHANCE_BACKWARD(30)
    constant CHANCE_IN_PLACE(30)

    // @ Description
    // Chance to roll
    constant CHANCE_Z_CANCEL(95)

    // @ Description
    // Functions that execute different tech options
    // @ Arguments
    // a0 - address of player struct
    // a1 - enum direction (forward = 0x49, backward), if applicable
    constant tech_roll_(0x80144700)
    constant tech_roll_og_(0x80144760)
    constant tech_in_place_(0x80144660)
    constant tech_in_place_og_(0x801446BC)
    constant tech_fail_(0x80144498)
    constant FORWARD(0x49)
    constant BACKWARD(0x4A)

    // @ Description
    // Helper for toggle guard
    scope j_random_teching__orginal_: {
        j       random_teching_._original
        nop
    }

    scope random_teching_: {
        OS.patch_start(0x000BB3C0, 0x80140980)
        jal     random_teching_
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        OS.patch_end()

        OS.patch_start(0x000BE034, 0x801435F4)
        jal     random_teching_
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // save ra

        lw      t0, 0x0084(s0)              // t0 = player struct

        sw      t0, 0x0018(sp)              // save player struct to stackspace
        lw      t2, 0x0008(t0)              // t2 = character ID
        lli     t1, Character.id.SANDBAG
        beq     t2, t1, _fail               // if sandbag, don't tech ever
        nop

		_check_level_10:
		lbu		t1, 0x0013(t0)				// v1 = cpu level
		slti	t1, t1, 10					// t6 = 0 if 10 or greater
		beqz	t1, _advanced_ai			// random teching if level 10

        addiu   t1, r0, 0x0004
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, t0)
        beq     t0, t1, _advanced_ai        // if Remix 1p, automatic advanced ai
        nop

		// No fix if Vanilla 1P
        OS.read_word(Global.match_info, t1)	// t1 = current match info struct
		lbu		t0, 0x0000(t1)
        lli     t1, Global.GAMEMODE.CLASSIC
        beq     t1, t0, _original         	// dont use toggle if 1P/RTTF
		nop

        Toggles.guard(Toggles.entry_improved_ai, j_random_teching__orginal_)

        _advanced_ai:
        li      t0, Global.current_screen   // t0 = address of current screen
        lbu     t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x003C                  // t1 = how to play screen id
        beq     t1, t0, _original           // if we're on the how to play screen, then skip all this
        lli     t1, 0x002D                  // t1 = DK vs Samus intro screen id
        beq     t1, t0, _original           // if we're on the DK vs Samus intro screen, then skip all this
        nop

		_improved_ai:
        OS.read_word(Global.match_info, t0)  // t0 = address of match_info
        addiu   t0, t0, Global.vs.P_OFFSET  // t0 = address of first player sturct

        _loop:
        lbu     t2, 0x0002(t0)              // t2 = enum (man, cpu, none)
        lli     t1, 0x0002                  // t1 = none
        beql    t1, t2, _loop               // if (port is empty), go to next port
        addiu   t0, t0, Global.vs.P_DIFF    // else, increment pointer and loop
        lw      t1, 0x0058(t0)              // t0 = px struct
        beq     t1, s0, _cpu_check          // if (px = p_teched), continue (compare player structs)
        nop
        addiu   t0, t0, Global.vs.P_DIFF    // else, increment pointer and loop
        b       _loop
        nop

        _cpu_check:
        beqz    t2, _original               // if (t2 == man), skip
        nop
        lli     a0, 000100                  // ~
        jal     Global.get_random_int_      // v0 = (0-99)
        nop
        lw      t0, 0x0018(sp)              // load player struct from stack
        lh      t1, 0x018C(t0)              // get player state flags?
        andi    t1, t1, 0x0004              // !0 if off screen
        bnez    t1, _in_place               // avoid tech roll if off screen

        _roll_forward:
        sltiu   t1, v0, CHANCE_FORWARD
        beqz    t1, _roll_backward          // if out of range, skip
        nop                                 // else, continue
        move    a0, s0                      // a0 - player object
        lli     a1, FORWARD                 // a1 - enum direction
        jal     tech_roll_                  // tech roll
        nop
        b       _end                        // end
        nop

        _roll_backward:
        sltiu   t2, v0, (CHANCE_FORWARD + CHANCE_BACKWARD)
        beqz    t2, _in_place               // if out of range, skip
        nop                                 // else, continue
        move    a0, s0                      // a0 - player object
        lli     a1, BACKWARD                // a1 - enum direction
        jal     tech_roll_                  // tech roll
        nop
        b       _end                        // end
        nop

        _in_place:
        sltiu t2, v0, (CHANCE_FORWARD + CHANCE_BACKWARD + CHANCE_IN_PLACE)
        beqz    t2, _fail                   // if out of range, skip
        nop                                 // else, continue
        move    a0, s0                      // a0 - player object
        jal     tech_in_place_              // tech in place
        nop
        b       _end                        // end
        nop

        _fail:
        move    a0, s0                      // a0 - player object
        jal     tech_fail_                  // don't tech
        nop
        b       _end
        nop

        _original:
        jal     tech_roll_og_               // original line 1
        move    a0, s0                      // original line 2
        bnezl   v0, _end                    // original line 3
        nop                                 // original line 4
        jal     tech_in_place_og_           // original line 5
        move    a0, s0                      // original line 6
        bnezl   v0, _end                    // original line 7
        nop                                 // original line 8
        jal     tech_fail_                  // original line 9
        move    a0, s0                      // original line 10
        nop                                 // original line 11

        _end:
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }


    // @ Description
    // Usually, this function checks for a z-cancel press with 10 frames. At the end of this, at
    // holds a boolean for successful z-cancel. This function has been modified to make sure that
    // boolean is true for CPUs (Z_CANCEL_CHANCE)% of the time. [bit]
    scope z_cancel_: {
        OS.patch_start(0x000CB478, 0x80150A38)
        jal     z_cancel_
        nop
        OS.patch_end()

        _original:
        lw      t6, 0x0160(v1)              // original line 1
        slti    at, t6, 0x000B              // original line 2

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers


		_check_level_10:
		lw		t0, 0x0084(a0)				// t0 = player struct
		lbu		t0, 0x0013(t0)				// t0 = cpu level
		slti	t0, t0, 10					// t0 = 0 if 10 or greater
		beqz	t0, _advanced_ai			// z cancel if lvl 10

		// Fix if Remix 1P
        addiu   t1, r0, 0x0004
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, t0) // t0 = singleplayer mode flag
        beq     t0, t1, _advanced_ai        // if Remix 1p, automatic advanced ai
        nop

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // save registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _normal
        nop

        _advanced_ai:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // save registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _skip_toggle
        nop


        _normal:
        Toggles.guard(Toggles.entry_improved_ai, OS.NULL)

        _skip_toggle:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      v1, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // save registers

        li      t0, Global.current_screen   // t0 = address of current screen
        lbu     t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x003C                  // t1 = how to play screen id
        beq     t1, t0, _end                // if we're on the how to play screen, then skip all this
        lli     t1, 0x002D                  // t1 = DK vs Samus intro screen id
        beq     t1, t0, _end                // if we're on the DK vs Samus intro screen, then skip all this
        nop

        OS.read_word(Global.match_info, t0) // t0 = address of match_info
        addiu   t0, t0, Global.vs.P_OFFSET  // t0 = address of first player sturct

        _loop:
        lbu     t2, 0x0002(t0)              // t2 = enum (man, cpu, none)
        lli     t1, 0x0002                  // t1 = none
        beql    t1, t2, _loop               // if (port is empty), go to next port
        addiu   t0, t0, Global.vs.P_DIFF    // else, increment pointer and loop
        lw      t1, 0x0058(t0)              // t0 = px struct
        beq     t1, a0, _cpu_check          // if (px = p_teched), continue (compare player structs)
        nop
        addiu   t0, t0, Global.vs.P_DIFF    // else, increment pointer and loop
        b       _loop
        nop

        _cpu_check:
        beqz    t2, _end                    // if (t2 == man), skip
        nop

		// No fix if Vanilla 1P
        OS.read_word(Global.match_info, t0)	// t0 = current match info struct
		lbu		t2, 0x0000(t0)
        lli     at, Global.GAMEMODE.CLASSIC
        beq     t2, at, _end         		// dont use toggle if vanilla 1P/RTTF

		// Some characters have extra hitboxes if they don't z cancel.
        lw      t1, 0x0008(v1)              // get character ID
        addiu   at, Character.id.KIRBY
        beq     t1, at, _kirby
        addiu   at, Character.id.JKIRBY
        beq     t1, at, _kirby
        addiu   at, Character.id.NKIRBY
        beq     t1, at, _kirby
        addiu   at, Character.id.PIKACHU
        beq     t1, at, _fair_check
        addiu   at, Character.id.JPIKA
        beq     t1, at, _fair_check
        addiu   at, Character.id.EPIKA
        beq     t1, at, _fair_check
        addiu   at, Character.id.NPIKACHU
        beq     t1, at, _fair_check
        addiu   at, Character.id.DSAMUS
        beq     t1, at, _nair_check
        addiu   at, Character.id.MTWO
        beq     t1, at, _nair_check
        //addiu   at, Character.id.NMTWO
        //beq     t1, at, _nair_check
        //addiu   at, Character.id.NDSAMUS
        //beq     t1, at, _nair_check
        addiu   at, Character.id.JIGGLYPUFF
        beq     t1, at, _dair_check
        addiu   at, Character.id.NJIGGLY
        beq     t1, at, _dair_check
        addiu   at, Character.id.EPUFF
        beq     t1, at, _dair_check
        addiu   at, Character.id.JPUFF
        beq     t1, at, _dair_check
        addiu   at, Character.id.NBOWSER
        beq     t1, at, _dair_check
        addiu   at, Character.id.BOWSER
        bne     t1, at, _rng
        lli     a0, 100                      // ~

        _dair_check: // bowser and puff
		lw      t1, 0x0024(v1)               // t1 = current action
        lli     at, Action.AttackAirD        // at = dair
        beql    t1, at, _rng                 // maybe don't cancel if attack has extra hitboxes
        lli     a0, 400                      // ~1/4 chance to z cancel
		b       _rng_normal                  // otherwise do normal
		nop

        _fair_check: // pika
		lw      t1, 0x0024(v1)               // t1 = current action
        lli     at, Action.AttackAirF        // at = fair
        beql    t1, at, _rng                 // maybe don't cancel if attack has extra hitboxes
        lli     a0, 400                      // ~1/4 chance to z cancel
		b       _rng_normal                  // otherwise do normal
		nop

        _nair_check: // Mewtwo and DSamus
		lw      t1, 0x0024(v1)               // t1 = current action
        lli     at, Action.AttackAirN        // at = nair
        beql    t1, at, _rng                 // maybe don't cancel if attack has extra hitboxes
        lli     a0, 400                      // ~1/4 chance to z cancel
		b       _rng_normal                  // otherwise do normal
		nop

        _kirby:
        lw      t1, 0x0024(v1)               // t1 = current action
        lli     at, Action.AttackAirB        // at = attack with no extra hitbox
        bnel    t1, at, _rng                 // maybe don't cancel if attack has extra hitboxes
        lli     a0, 400                      // ~1/4 chance to z cancel
		// otherwise do normal

        _rng_normal:
        lli     a0, 000100                  // ~
        _rng:
        jal     Global.get_random_int_      // v0 = (0-99)
        nop

        _cancel:
        sltiu   t1, v0, CHANCE_Z_CANCEL     // ~
        beqz    t1, _no_cancel              // if (v0 >= Z_CANCEL_CHANCE), set false
        nop
        lli     at, OS.TRUE                 // set true
        b       _end                        // end
        nop

        _no_cancel:
        lli     at, OS.FALSE                // set false
        b       _end                        // end
        nop

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      v1, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // save registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Improves cpu ability to utilize charge attacks
	// Removed for Level 10 cpus (experimental)
    // routine is part of 0x8013837C
    scope improve_remix_charged_NSP: {
        OS.patch_start(0xB1494, 0x80136A54)
        j     improve_remix_charged_NSP
        nop
        OS.patch_end()

        // v0 = character id
		// a0 = player struct
        // a1 = samus's character id

		// lbu 	t0, 0x0013(a0)				// t0 = cpu level
		// slti	t0, t0, 10					// t0 = 0 if 10 or greater
		// beqz    t0, _level_ten		    	// for level 10, skip if shielding (avoids shield-drop issues)
		// nop
		_character_id_check:
        lli     at, Character.id.SHEIK
        beq     at, v0, _check_needle
        // check if DSAMUS or MEWTWO
        lli     at, Character.id.MTWO
        beq     at, v0, _check_charge_shot
        lli     at, Character.id.DSAMUS
        beq     at, v0, _check_charge_shot
        lli     at, Character.id.ESAMUS
        beq     at, v0, _check_charge_shot
        lli     at, Character.id.JSAMUS
        beq     at, v0, _check_charge_shot
        lli     at, Character.id.JDK
        beq     at, v0, _donkey_kong
        nop

        // if here, no charge attacks.
        _end:
        j       0x80136BFC                  // original line 1 (was a branch)
        or      v0, r0, r0                  // original line 2

        _donkey_kong:
        j       0x80136A64                  // jump to dk part of routine
        addiu   at, r0, 0x00DE              // dk logic

        _check_charge_shot:
        j       0x80136B08                  // check if should charge shot
        // don't add any lines here
        _check_needle:
        lw      v0, 0x0024(a0)              // v0 = current action id
        addiu   at, r0, Sheik.Action.NSPG_BEGIN
        beq     v0, at, _end_0x80136BF8     // end if beginning nsp
        addiu   at, r0, Sheik.Action.NSPA_BEGIN
        beq     v0, at, _end_0x80136BF8     // ~
        addiu   at, r0, Sheik.Action.NSPG_CHARGE
        beq     v0, at, _end_0x80136BF8     // end to keep charging
        addiu   at, r0, Sheik.Action.NSPG_SHOOT
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Sheik.Action.NSPA_SHOOT
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Action.JumpSquat
        beq     v0, at, _end                // end if in a jumpsquat
        nop

        // if here, check needle ammo
        lw      t0, 0x0AE0(a0)              // t0 = needle charge level
        slti    at, t0, 0x0006              //
        beqz    at, _end                	//
        nop
        j       0x80136B3C                  // go to original routine for Samus B press?
        nop

		_level_ten:
		// na

        _end_0x80136BF8:
        j      0x80136BF8
        nop

    }

    // @ Description
    // Samus checks the opposing fighter if they are capable of reflecting/absorb before shooting
    // Sometimes this check is ignored by the AI
    scope improve_remix_charged_NSP_2: {
        OS.patch_start(0xB3664, 0x80138C24)
        j       improve_remix_charged_NSP_2
        addiu   at, r0, 0x000B        // original line 1, at = ID.NESS
        OS.patch_end()

        // a2 = opponent player struct
        // v0 = opponent character ID

        beq      v0, at, _sheik_check           // branch if opponent is Ness
        addiu    at, r0, Character.id.FOX
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Fox
        addiu    at, r0, Character.id.LUCAS
        beq      v0, at, _sheik_check           // branch if opponent is Lucas
        addiu    at, r0, Character.id.WOLF
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Piano
        addiu    at, r0, Character.id.MARINA
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Marina
        addiu    at, r0, Character.id.FALCO
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Falco
        addiu    at, r0, Character.id.PIANO
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Piano
        addiu    at, r0, Character.id.JFOX
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is JFox
        addiu    at, r0, Character.id.JNESS
        beq      v0, at, _sheik_check           // branch if opponent is JNess
        nop

        _normal:
        j        0x80138C44                     // original branch if opponent isn't Fox or Ness
        lw       v0, 0x0008(s0)                 // v0 = own ID. (original delay slot)

        _sheik_check:
        lw       v0, 0x0008(s0)                 // v0 = own ID
        addiu    at, r0, Character.id.SHEIK
        beq      at, v0, _normal                // don't care about absorb if Sheik
        nop
        // this part misses Kirby's logic if wearing Sheik's hat

        _fox_or_ness_opponent:
        j        0x80138ED0                     // exit routine if opponent = Fox or Ness
        or       v0, r0, r0                     // v0 = 0 (original delay slot)

    }

    // @ Description
    // jkirby added to kirby hat check
    // remix characters added to samus check, should improve the rate they attempt a full charge attack
    scope improve_remix_charged_NSP_3: {
        OS.patch_start(0xB3684, 0x80138C44)
        j       improve_remix_charged_NSP_3
        addiu   at, r0, Character.id.KIRBY      // original line 1
        OS.patch_end()

        // v0 = character id

        beq      v0, at, _kirby                 // branch if KIRBY
        addiu    at, r0, Character.id.JKIRBY
        beq      v0, at, _kirby                 // branch if JKIRBY
        nop

        _not_kirby:
        b        _charge_shot_check
        or       a0, v0, r0                     // a0 = own character ID

        _kirby:
        lw       a0, 0x0ADC(s0)                 // a0 = own kirby hat ID

        _charge_shot_check:
        lw       v0, 0x0024(s0)                 // v0 = current action
        addiu    at, r0, 0x0003                 // at = ID.Samus / Hat ID for Samus
        beq      a0, at, _samus_action_check    // branch if SAMUS
        addiu    at, r0, Character.id.SHEIK
        beq      a0, at, _sheik_action_check    // branch if SHEIK
        addiu    at, r0, Character.id.MTWO
        beq      a0, at, _mewtwo_action_check   // branch if MEWTWO
        addiu    at, r0, Character.id.DSAMUS
        beq      a0, at, _dsamus_action_check   // branch if DSAMUS
        addiu    at, r0, Character.id.JSAMUS
        beq      a0, at, _samus_action_check    // branch if JSAMUS
        addiu    at, r0, Character.id.ESAMUS
        beq      a0, at, _samus_action_check    // branch if ESAMUS
        nop

        _no_charge_shot:
        j        0x80138CB8                     // if here, no charge attack
        sltiu    at, a0, 0x000E

        _dsamus_action_check:
        addiu   at, r0, Action.KIRBY.DSCharging // check if doing Kirby's Dsamus charge
        beq     v0, at, _using_charge_attack
        nop
        _samus_action_check:
        j        0x80138C68                     // go to Samus's action check
        nop

        _mewtwo_action_check:
        addiu   at, r0, 0x00E0                  // MTWO_NSPG_SHOOT
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x00E4                  // MTWO_NSPA_SHOOT
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallStart
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallCharge
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallShoot
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallStartAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallChargeAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.ShadowBallShootAir
        beq     v0, at, _using_charge_attack
        nop
        j        0x80138C68                     // go to Samus's action check
        nop

        _sheik_action_check:
        addiu   at, r0, 0x0EA                   // NeedleStormStartGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x0EB                   // NeedleStormChargeGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x0EC                   // NeedleStormShootGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x0ED                   // NeedleStormStartAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x0EE                   // NeedleStormChargeAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, 0x0EF                   // NeedleStormShootAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormStartGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormChargeGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormShootGround
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormStartAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormChargeAir
        beq     v0, at, _using_charge_attack
        addiu   at, r0, Action.KIRBY.NeedleStormShootAir
        bnel    v0, at, _no_charge_shot
        sltiu   at, a0, 0x000E
        b       _using_charge_attack
        or      v0, r0, r0

        _using_charge_attack:
        j       0x80138ED0                       // original branch when Samus is using NSP
        or      v0, r0, r0                       // original delay slot

    }

    // @ Description
    // Improves cpu ability to not care about or dodge projectiles hook after M.MARIO/GDK id check
    // Used for Franklin Badge cpus and GBOWSER
    scope remix_ignore_projectiles_: {
        OS.patch_start(0xB2224, 0x801377E4)
        j     remix_ignore_projectiles_
        nop
        _return:
        OS.patch_end()

        // v0 = character id
        // s0 = player struct
        lli     at, Character.id.GBOWSER
        beq     at, v0, _ignore_projectile  // ignore the projectile if GBOWSER
        nop
        // TODO: add a check for remix 1P giant

        define _table(Item.FranklinBadge.players_with_franklin_badge)
        OS.lui_table({_table}, v0)          // v0 = first half of table address
        lbu     at, 0x000D(s0)              // at = port
        sll     at, at, 0x0002              // at = offset to player entry
        addu    v0, v0, at                  // v0 = offset of players badge
        OS.table_read_word({_table}, v0, v0) // v0 = players entry in table

        bnez    v0, _ignore_projectile      // ignore the projectile if cpu wearing badge
        nop

        // if here, proceed as normal
        jal    0x80135B78                   // original line 1
        sw     a2, 0x0034(sp)               // original line 2
        j      _return
        nop

        _ignore_projectile:
        j      0x80137804
        nop

    }

    // @ Description
    // Hook to routine that performs id check for fox. Extended to check for clones
    // best when action ids are shared
    scope fox_usp_check_: {
        OS.patch_start(0xACB80, 0x80132140)
        j     fox_usp_check_
        nop
        _return:
        OS.patch_end()

        // at = fox's character id
        // t9 = character id
        beq      t9, at, _fox      // branch to Fox usp action check
        addiu    at, r0, Character.id.JFOX
        beq      t9, at, _fox      // branch to Fox usp action check
        addiu    at, r0, Character.id.FALCO
        beq      t9, at, _fox      // branch to Fox usp action check
		nop

        _normal:
        j        0x80132174        // skip fox branch
        mtc1     r0, f8            // original line 2 (delay slot)

        _fox:
        j       _return + 0x4     // original - take fox branch
        lw		v0, 0x0024(a0)     // v0 = current action

    }

	// CONTROLLER COMMANDS
	// 0xAxyy - yy = Stick X
	macro STICK_X(stick_value) {
		db 0xA0	//TODO: WAIT TIMER
		db {stick_value}
	}

	// 0xBxyy - yy = Stick Y
	macro STICK_Y(stick_value) {
		db 0xB0	//TODO: WAIT TIMER
		db {stick_value}
	}

	// moves towards target coordinates
	macro MOVE() {
		db 0xC0FF;
	}

	macro PRESS_Z() {
		dh 0xC040;
	}
	macro UNPRESS_Z() {
		dh 0xC050;
	}
	macro PRESS_L() {
		dh 0xC060;
	}

	macro UNPRESS_B() {
		db 0x30;
	}
	macro UNPRESS_A() {
		db 0x50;
	}

	macro RESET_TIMER() {
		dh 0xC0FF;
	}
	macro FAST_FALL() {
		dh 0xC0B1; db 0xB0;
	}
	macro PK_THUNDER() {
		db 0xF3;
	}

	macro CUSTOM(id) {
		db CUSTOM_ROUTINE_ID
		db {id}
	}

	// 0xFF00 - End Control Routine
	macro END() {
		db 0xFF; OS.align(4);
	}

	// @ Description
	// New Controller Routines for Cpus
	SHORT_HOP_COMMAND: // 0x31
    //UNPRESS_Z()
	CUSTOM(1)						// press C
    dh 0xA17F   					// stick x towards opponent. wait(1)
	CUSTOM(2)						// unpress C
    dh 0x0   				        // reset stick x
	END();

    SHORT_HOP_NAIR: // 0x32
    UNPRESS_Z()
    CUSTOM(1)						// press C
    dh 0xA17F   					// stick x towards opponent. wait(1)
    CUSTOM(2)						// unpress C
    dh 0xA17F						// stick x towards opponent. wait(1)
    CUSTOM(0)						// wait until jumpsquat is complete
	// attack:
    dh 0xA000   					// reset stick x
    STICK_Y(0x00)   				// reset stick y
    dh 0x0111       				// press A wait(1)
    END();

	SHORT_HOP_DAIR: // 0x33
    UNPRESS_Z()
	CUSTOM(1)						// press C
    dh 0xA17F   					// stick x towards opponent. wait(1)
	CUSTOM(2)						// unpress C
	dh 0xA17F						// stick x towards opponent. wait(1)
    CUSTOM(0)						// wait until jumpsquat is complete
	// attack:
    dh 0xA000   					// reset stick x
    STICK_Y(0xB0)   				// point stick down
	dh 0x0111       				// press A
	END();

	NESS_DJC_NAIR:  // 0x34
    dh 0xA07F  		// point towards opponent
    dh 0xB200		// reset y. wait 2 frames
    dh 0xA07F		// keep pointing
    dh 0xB135		// jump, wait 2 frames
    dh 0xA07F		// point to opponent
    dh 0xB300
    dh 0xA07F
    dh 0xB135
    dh 0xA000
    dh 0xB100
    dh 0x0111
    dh 0xA07F
    dh 0xB200
	END();

	NESS_DJC_DAIR:  // 0x??
    dh 0xA07F  		// point towards opponent
    dh 0xB200		// reset y. wait 2 frames
    dh 0xA07F		// keep pointing
    dh 0xB135		// jump, wait 2 frames
    dh 0xA07F		// point to opponent
    dh 0xB300
    dh 0xA07F
    dh 0xB135
    dh 0xA000
    dh 0xB100
    dh 0x0111
    dh 0xA07F
    dh 0xB200
	END();

	MULTI_SHINE:    // 0x35
    dh 0xA000  		// reset sticks
    dh 0xB100		// ~ wait(1)
    dh 0xA07F  		// stick x = dash to opponent
    dh 0xB100		// stick y = 0. wait 1 frames
    dh 0xA000  		// stick x = 0
    dh 0xB135		// jump. wait 3 frames
    dh 0xA000  		//
    dh 0xB0B0		// point stick down. wait 2 frames
    dh 0x0221       // press B
	END();

	MULTI_SHINE_TURNAROUND:    // 0x36
    dh 0xA000  		// reset sticks
    dh 0xB100		// ~ wait(1)
    dh 0xA07F  		// stick x = dash to opponent
    dh 0xB500		// stick y = 0. wait 6 frames
    dh 0xA000  		// stick x = 0
    dh 0xB135		// jump. wait 3 frames
    dh 0xA000  		//
    dh 0xB0B0		// point stick down. wait 2 frames
    dh 0x0221       // press B
	END();

	SHIELD_DROP:    // 0x37
	STICK_X(0)		// reset sticks
	STICK_Y(0)		// reset sticks
	db 0x41			// PRESS_Z(); WAIT(1)
	PRESS_Z()		// Keep Z down
	STICK_X(0)
	dh 0xB1B0		// STICK_Y(0xB0) Wait(1)
	STICK_X(0)		// reset sticks
	STICK_Y(0)		// reset sticks
    UNPRESS_Z()		// Unpress Z
	END();			// End routine

	LUCAS_BAT_BACKWARDS:
		dh 0xC0C0		// reset buttons?
		STICK_X(0)  	// reset stick X
		dh 0xB200		// and stick Y, wait(1)
		STICK_X(0xC0)	// hold stick backwards
		dh 0x0111		// press A
		END();			// End routine

	LUCAS_BAT_FORWARDS:
		dh 0xC0C0		// reset buttons?
		STICK_X(0)  	// reset stick X
		dh 0xB200		// and stick Y, wait(1)
		STICK_X(0x70)	// hold stick forward
		dh 0x0111		// press A
		END();			// End routine

	PUFF_SHORT_HOP_DAIR:
		UNPRESS_Z()
		CUSTOM(1)						// press C
		dh 0xA17F   					// stick x towards opponent. wait(1)
		CUSTOM(2)						// unpress C
		dh 0xA17F						// stick x towards opponent. wait(1)
		CUSTOM(0)						// wait until jumpsquat is complete
		dh 0xB100						// wait(1)
		// attack:
		dh 0xA000   					// reset stick x
		STICK_Y(0xB0)   				// point stick down
		dh 0x0111       				// press A
		END();

	CLIFF_LET_GO:
		UNPRESS_A(); UNPRESS_B();
		STICK_X(0)	 					// stick x = 0
		dh 0xB100						// stick y = 0, wait(1)
		STICK_Y(0xB0)					// point stick down
		dh 0xA100						// stick x = 0, wait(1)
		STICK_Y(0x80)					// jump
		dh 0xA400						// stick x = 0, wait(4)
		STICK_Y(0); STICK_X(0); END();	// reset sticks, end


	// @ Description
	// Copy and extend the vanilla ai cpu command table
	// 0x80188340
	constant ORIGINAL_TABLE(0x102D80)
	OS.align(16)
	command_table:
	constant TABLE_ORIGIN(origin())
	OS.copy_segment(ORIGINAL_TABLE, (0x31 * 0x4))
	dw SHORT_HOP_DAIR			    // 0x31 todo: replace
	dw SHORT_HOP_NAIR               // 0x32
	dw SHORT_HOP_DAIR               // 0x33
	dw NESS_DJC_NAIR                // 0x34
	dw MULTI_SHINE                  // 0x35
	dw MULTI_SHINE_TURNAROUND       // 0x36
	dw SHIELD_DROP					// 0x37
	dw LUCAS_BAT_BACKWARDS			// 0x38
	dw LUCAS_BAT_FORWARDS			// 0x39
	dw PUFF_SHORT_HOP_DAIR			// 0x3A
	dw CLIFF_LET_GO					// 0x3B

	// new commands go here ^

	// @ Description
	// Command routine index points to entry in table 0x80132564
	// Applies controller command to cpu
    scope ROUTINE: {
	    constant RESET_STICK(0x00)
	    constant MOVE(0x01)
	    constant TURN(0x02)
	    constant WAIT_1_FRAME(0x03)
	    constant JUMP(0x04)
		constant FTILT(0x05)
			// constant attack_a?(0x06) // constant attack_a?(0x07) // constant attack_a?(0x08)
		constant NSP(0x09)
			//constant NSP2?(0x0A) //constant NSP3?(0x0B)
        constant PRESS_Z(0x0C)
		constant USP(0x0D)
			//constant USP2?(0x0E)
		constant TAUNT(0x0F)
		constant SHIELD_2(0x10)
			// constant WALK2?(0x11) // constant WALK3?(0x12)
	    constant PRESS_A(0x13)
	    constant JAB(0x13)
	    constant NAIR(0x13)
			// constant ?(0x0E) // constant ?(0x0F) // constant ?(0x10) // constant ?(0x11) // constant ?(0x12) // constant ?(0x13) // constant ?(0x14)
		constant SMASH_FORWARD(0x15)
			// constant ?(0x16)
		constant UTILT(0x17)
			// constant RANDOM_ATTACKS?(0x18)
		constant SMASH_UP(0x19)
			// constant RANDOM_ATTACKS?(0x1A)
		constant DSP(0x1B)
		constant GRAB(0x1C)
			//constant GRAB2?(0x1D)
	    constant STICK_LEFT(0x1E)
	    constant STICK_RIGHT(0x1F)
		constant DTILT(0x20)
			// constant RANDOM_ATTACKS?(0x21)
		constant SMASH_DOWN(0x22)
			//constant SHIELD_3(0x23)

        constant STICK_DOWN(0x27)	// fast fall, plat drop
		constant CLIFF_ATTACK(0x28)
		constant HARD_ITEM_THROW(0x2A)
		constant LIGHT_ITEM_THROW(0x2B)
        constant ROLL_LEFT(0x2D)
        constant ROLL_RIGHT(0x2E)
		constant YOSHI_USP(0x2F)
		constant PK_THUNDER(0x30)	// goes to 0x801324F0

		// custom routines start here
		constant SHORT_HOP_DAIR(0x31)
		constant SHORT_HOP_NAIR(0x32)
		constant SHORT_HOP_DAIR_2(0x32) // todo: make different
		constant NESS_DJC_NAIR(0x34)
		constant MULTI_SHINE(0x35)
		constant MULTI_SHINE_TURNAROUND(0x36)
		constant SHIELD_DROP(0x37)
		constant LUCAS_BAT_BACKWARDS(0x38)
		constant LUCAS_BAT_FORWARDS(0x39)
		constant PUFF_SHORT_HOP_DAIR(0x3A)
		constant CLIFF_LET_GO(0x3B)
    }

	// @ Description
	// modifies a hard-coded routine which gets the ptr to an ai's command
	scope extend_commands_1: {
		OS.patch_start(0xAD174, 0x80132734)
		constant UPPER(command_table >> 16)
		constant LOWER(command_table & 0xFFFF)

		if LOWER > 0x7FFF {
			lui     t9, (UPPER + 0x1)   // original line 1 (modified)
		} else {
			lui     t9, UPPER           // original line 1 (modified)
		}

		sll     t7, t8, 2               // original line 2
		addu    t9, t9, t7              // original line 3
		lw      t9, LOWER(t9)           // original line 4 (modified)
		OS.patch_end()
	}

	// another hard-coded place
	scope extend_commands_2: {
		OS.patch_start(0xAD378, 0x80132938)
		constant UPPER(command_table >> 16)
		constant LOWER(command_table & 0xFFFF)

		if (LOWER > 0x7FFF) {
			lui     t9, (UPPER + 0x1)   // original line 1 (modified)
		} else {
			lui     t9, UPPER           // original line 1 (modified)
		}

		sll     t7, t8, 2               // original line 2
		addu    t9, t9, t7              // original line 3
		lw      t9, LOWER(t9)           // original line 4 (modified)
		OS.patch_end()
	}

	// another hard-coded place
	scope extend_commands_3: {
		OS.patch_start(0xAD1A0, 0x80132760)
		constant UPPER(command_table >> 16)
		constant LOWER(command_table & 0xFFFF)

		if (LOWER > 0x7FFF) {
			lui     t8, (UPPER + 0x1)   // original line 1 (modified)
		} else {
			lui     t8, UPPER           // original line 1 (modified)
		}

		sb		t6, 0x01D3(a0)			// original line 2
		addu	t8, t8, t7              // original line 3
		lw      t8, LOWER(t8)           // original line 4 (modified)
		OS.patch_end()
	}

	// @ Description
    // Allows custom AI controller commands.
	// Command = 0xFExx (xx = routine index)
	constant CUSTOM_ROUTINE_ID(0xFE)
	scope CUSTOM_COMMANDS: {

		// halts commands from processing until out of jumpsquat
		scope JUMPSQUAT_WAIT: {
			lw   	t7, 0x0024(a0) 	    // t7 = current action
			addiu   t6, r0, Action.JumpSquat // t6 = Action.JumpSquat
			beql     t6, t7, _jump_squat// branch if doing a jumpsquat
			addiu   at, r0, 0x0001      // a1 = 1

			_end:
			j    	0x8013253C          // back to original routine
			nop
			_jump_squat:

			sh      at, 0x0006(t0)      // wait 1 frame
			j       0x8013254C          // exit command processing
			addiu   a2, a2, -0x0002     // read this command next frame

		}

		// TODO: MAKE SURE THIS DOESN'T STAY STUCK ON.
		scope PRESS_C: {
		constant index(1)
			lh   	t7, 0x01C6(a0) 		// t7 = cpu button pressed flags
			ori  	t8, t7, 0x0001  	// t8 = t7 + c-button press
			j    	0x8013253C     		// back to original routine
			sh   	t8, 0x01C6(a0) 		// save c button press
		}

		scope UNPRESS_C: {
		constant index(2)
			lh   	t7, 0x01C6(a0) 		// t7 = cpu button pressed flags
			andi 	t8, t7, 0xFFF0 		// t8 = t7 - c-button press
			j    	0x8013253C     		// back to original routine
			sh   	t8, 0x01C6(a0) 		// save c button press
		}

		table:					// Command
		dw JUMPSQUAT_WAIT		// 0xFE00
		dw PRESS_C				// 0xFE01
		dw UNPRESS_C			// 0xFE02

		scope extend_routines: {
			OS.patch_start(0x1065BC, 0x8018BB7C)
			dw	extend_routines
			OS.patch_end()

			// a0 = cpu player struct, a2 = argument
			li		at, table			// at = custom ai command table
			lb      t7, 0x0000(a2)  	// t7 = custom routine idle
			sll     t7, t7, 0x0002  	// t7 = offset in table
			addu    at, at, t7
			lw      at, 0x0000(at)
			jr      at					// go to the custom routine
			addiu   a2, a2, 0x0001      // increment a2

		}
	}

	// If the opponent is above? classic characters might do a up special
	scope AERIAL_CHASE: {

		scope ROUTINE: {
			// og table addr. 0x8018BC64
			// vanilla
			constant NORMAL(0x8013389C)
			constant CHASE(0x80133A14)
			// remix
		}


		scope extend_polygon_check_: {
			OS.patch_start(0xAE2C0, 0x80133880)
			j		extend_polygon_check_
			sll		t8, v0, 2						// OG line 2 t8 = offset in ai_long_range_table_
			_return:
			OS.patch_end()

			// at = 0 if character ID is >= POLY MARIO
			bnez	at, _normal_vanilla_character	// branch if orginal vanilla fighter
			sltiu	at, v0, Character.id.FALCO		// at = 1 if vanilla polygon
			bnez	at, _polygon_fighter			// branch if vanilla polygon fighter
			sltiu	at, v0, Character.NUM_CHARACTERS - Character.NUM_POLYGONS // at = 0 if remix polygon
			bnez	at, _normal_vanilla_character
			nop

			_polygon_fighter:
			j		0x8013389C 						// original line 1 branch
			nop

			_normal_vanilla_character:
			j		_return
			nop

		}
	}


	// if the opponent is far away? classic characters will do one of these jumps
	scope LONG_RANGE: {
		scope ROUTINE: {
			// og table addr. 0x8018BF20
			// vanilla
			constant NSP_SHOOT(0x80138D24)		// used by Mario, Fox, Samus etc.
			constant NONE(0x80138ECC)
			constant PHYSICAL_SHOOT(0x80138CD4)	// LINK, boomerang if opponent within 1500.0 units
			// remix
		}

		// @ Description
		// Extends a check that is meant to exclude polygons specifically for determining behaviour when a fighter is far away
		// a0 = character ID
		scope extend_polygon_check_: {
			OS.patch_start(0xB36F8, 0x80138CB8)
			j		extend_polygon_check_
			sll		t5, a0, 2						// OG line 2 t5 = offset in ai_long_range_table_
			_return:
			OS.patch_end()

			// at = 0 if character ID is >= POLY MARIO
			bnez	at, _normal_vanilla_character	// branch if orginal vanilla fighter
			sltiu	at, a0, Character.id.FALCO		// at = 1 if vanilla polygon
			bnez	at, _polygon_fighter			// branch if vanilla polygon fighter
			sltiu	at, a0, Character.NUM_CHARACTERS - Character.NUM_POLYGONS // at = 0 if remix polygon
			bnez	at, _normal_vanilla_character
			nop

			_polygon_fighter:
			j		0x80138ECC 						// original line 1 branch
			nop

			_normal_vanilla_character:
			j		_return
			nop

		}
	}

    // AI behavior Table
    scope ATTACK_TABLE: {
        scope JAB: {
            constant INPUT(0x00000013)
            constant OFFSET(0x0000)
        }
        scope FTILT: {
            constant INPUT(0x00000005)
            constant OFFSET(0x001C)
        }
        scope FSMASH: {
            constant INPUT(0x00000015)
            constant OFFSET(0x0038)
        }
        scope UTILT: {
            constant INPUT(0x00000017)
            constant OFFSET(0x0054)
        }
        scope USMASH: {
            constant INPUT(0x00000019)
            constant OFFSET(0x0070)
        }
        scope DTILT: {
            constant INPUT(0x00000020)
            constant OFFSET(0x008C)
        }
        scope DSMASH: {
            constant INPUT(0x00000022)
            constant OFFSET(0x00A8)
        }
        scope NSPG: {
            constant INPUT(0x00000009)
            constant OFFSET(0x00C4)
        }
        scope USPG: {
            constant INPUT(0x0000000D)
            constant OFFSET(0x00E0)
        }
        scope YOSHI_USPG: {
            constant INPUT(0x0000002F)
            constant OFFSET(0x00E0)
        }
        scope DSPG: {
            constant INPUT(0x0000001B)
            constant OFFSET(0x00FC)
        }
        scope GRAB: {
            constant INPUT(0x0000001C)
            constant OFFSET(0x0118)
        }
        scope ENDG: {
            constant INPUT(0xFFFFFFFF)
            constant OFFSET(0x0134)
        }

        scope NAIR: {
            constant INPUT(0x00000013)
            constant OFFSET(0x0150)
        }
        scope FAIR: {
            constant INPUT(0x00000015)
            constant OFFSET(0x016C)  // shared with bair
        }
        scope BAIR: {
            constant INPUT(0x00000015)
            constant OFFSET(0x016C)  // shared with fair
        }
        scope UAIR: {
            constant INPUT(0x00000019)
            constant OFFSET(0x0188)
        }
        scope DAIR: {
            constant INPUT(0x00000022)
            constant OFFSET(0x01A4)
        }
        scope NSPA {
            constant INPUT(0x00000009)
            constant OFFSET(0x01C0)
        }
        scope USPA: {
            constant INPUT(0x0000000D)
            constant OFFSET(0x01DC)
        }
        scope DSPA: {
            constant INPUT(0x0000001B)
            constant OFFSET(0x01F8)
        }
        scope ENDA: {
            constant INPUT(0xFFFFFFFF)
            constant OFFSET(0x0214)
        }
    }

    // @ Description
    // modifies parameters for cpu behaviour table. This allows us to edit the remix computers behaviour table
    // DON'T OVERWRITE THE PARENT TABLE
    // Arguments
    // behavior_table_origin - address of the characters behaviour table
    // attack_name - the attack to replace. choose one:(JAB, FTILT, DTILT, UTILT, FSMASH, DSMASH, USMASH, NSPG, NSPA, USPG, USPA, DSPG, DSPA, GRAB, FAIR, BAIR, NAIR, DAIR)
    // new_attack - set as "-1" or provide a manual id if you know what you're doing
    // start_hb_frame - The first frame of the attack where hitboxes appear
    // end_hb_frame - The last frame of the attack where hitboxes go away
    // min_x - lower x coord for player detection
    // max_x - higher x coord for player detection
    // min_y - lower y coord for player detection
    // max_y - higher y coord for player detection
    macro edit_attack_behavior(behavior_table_origin, attack_name, new_attack, start_hb_frame, end_hb_frame, min_x, max_x, min_y, max_y) {
        define table_entry(0x00000000)
        define offset(0x0000000)
        evaluate offset(AI.ATTACK_TABLE.{attack_name}.OFFSET)
        evaluate table_entry({behavior_table_origin} + {offset})
        // Modify attack behaviour entry
        pushvar origin, base
        origin {table_entry}
        if {new_attack} != -1 {
            dw    {new_attack}
        } else {; origin origin() + 0x4; }
        if {start_hb_frame} != -1 {
            dw      {start_hb_frame}
        } else {; origin origin() + 0x4; }
        if {end_hb_frame} != -1 {
            dw      {end_hb_frame}
        } else {; origin origin() + 0x4; }
        if {min_x} != -1 {
            float32 {min_x}
        } else {; origin origin() + 0x4; }
        if {max_x} != -1 {
            float32 {max_x}
        } else {; origin origin() + 0x4; }
        if {min_y} != -1 {
            float32 {min_y}
        } else {; origin origin() + 0x4; }
        if {max_y} != -1 {
            float32 {max_y}
        } else {; origin origin() + 0x4; }
        pullvar base, origin
    }

    // MISC CHECKS
    // NESS 0x80133854
    // DK 0x80135C04
    // METAL MARIO 0x80132AA4
    // GDK 0x80133428,
    // 0x80133608, (related to behaviour table)
    // 0x801336B8, (related to behaviour table)
    // 0x8013839C,

	// LINK? 8013CD08

	// fox laser shoot 80135374, 80135ABC (jal 0x80132758), 80138EAC (jal 0x80132778)


	// 0x80132EC8 loops through each entry in attack behaviour struct to see if the cpu should attack


	// related to off-ledge
	// TRACK OPPONENT PLAYER IF OFF STAGE 0x80132A98
	// Manage off-stage AI 0x80134B30

    // @ Description
    // Jumps used by character jump table at 0x801334E4
	// Used to prevent bad AI attacks
    scope PREVENT_ATTACK: {
        scope ROUTINE: {
            // vanilla
            constant NONE(0x80133520)           // default branch used by most characters
            constant MARIO(0x801334EC)          // Used by Mario Clones in vanilla (Prevents sd from DSP/USP)
            constant YOSHI_FALCON(0x80133510)   // Checks Down Special
            constant KIRBY(0x80133500)          // Checks Down Special and Up Special
			// remix
			constant SKIP_ATTACK(0x80133A14)	// debug option for us

			// @ Description
			// Prevents Falco SD with phantasm and usp
            scope FALCO_NSP: {
                // t1 = current cpu attack input
                addiu   at, r0, ATTACK_TABLE.NSPG.INPUT
                beq     t1, at, _prevent_sd
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                beq    t1, at, _check_usp
                nop

                _allow_attack:
                j   	0x80133520                      // jump to original routine
                nop

				_check_usp:
				j		FOX_USP							// LVL 10 Fox USP check
				nop

				_prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

            }


			// @ Description
			// Prevents Marina from doing a dangerous neutral special.
            scope BOWSER_USP_DSP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
                beq     t1, at, _prevent_sd				// branch if doing grounded DSP
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                bne     t1, at, _allow_attack			// branch if not doing grounded USP
                nop

				_prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

				_allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

			// @ Description
			// Prevents Wolf SD with USP
            scope WOLF_USP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                bne     t1, at, _allow_attack
                nop

				// _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

				_allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

			// @ Description
			// Prevents Conker from using Grenade when he can't.
            scope CONKER_GRENADE: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT // 0x1B
                bne     t1, at, _allow_attack
                nop

				// if here check if grenade available:
				// s0 = player struct
				lw      at, 0x0ADC(s0)
				beqz    at, _allow_attack               // branch if grenade available
                nop
                j       0x80133A14                      // skip this attack
                nop

				_allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

			// @ Description
			// Prevents Marina from doing a dangerous neutral special.
            scope MARINA_NSP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.NSPG.INPUT
                bne     t1, at, _allow_attack
                nop

				// _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

				_allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

			// @ Description
			// Prevents non-level 10 puffs from using down special.
            scope PUFF_DSP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT	// at = down special command input
                bne     t1, at, _allow_attack		// allow the attack if it is not down special
                nop
				lbu 	at, 0x0013(s0)				// at = cpu level
				slti	at, at, 10					// at = 0 if 10 or greater
				beqz    at, _lvl_10_dsp				// allow DSP if LVL 10
				nop
				_prevent_dsp:
                j       0x80133A14					// No DSP if < LVL 10
                nop

				_lvl_10_dsp:
				lw		at, 0x01FC(s0)				// get target player object
				lw		v0, 0x0084(at)				// v0 = target player struct
				lh      t6, 0x05BA(v0)				// t6 = targets tangibility flag
				addiu	at, r0, 0x0003
				beq		at, t6, _prevent_dsp		// don't try to rest if they are intangible
				lli		at, 30						// at = 30 hp
				lw		t6, 0x002C(v0)				// t6 = target players hp%
				blt		at, t6, _prevent_dsp		// skip rest check if player is less than 30 percent
				nop

				_allow_attack:
                j   0x80133520						// jump to original routine
                nop
            }

			// @ Description
			// Prevents 10 Fox from using up special offensively
            scope FOX_USP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT	// at = up special command input
                bne     t1, at, _allow_attack		// allow the attack if it is not down special
                nop
				lbu 	at, 0x0013(s0)				// at = cpu level
				slti	at, at, 10					// at = 0 if 10 or greater
				bnez    at, _allow_attack			// allow attack if not level 10
				nop

                j       0x80133A14					// No USP if LVL 10
                nop

				_allow_attack:
                j		0x80133520					// jump to original routine
                nop
            }

        }

		// places of interest
		// 0x8013295C checks if cpu should attack

		// 0x80134000 recovery routine
		// 0x80138EAC neutral B routine
    }

	// @ Description
	// This is the main routine that handles how a cpu player functions
	// There are 3 subroutines which determine the cpus input
	// The last subroutine applies the cpu input
	scope MANAGE_CPU: {
		constant ROUTINE(0x8013A834)

		// skip to the last JAL if still processing a controller command

		// @ Description
		// First, read byte 0x05 and sets byte 0x03
		// Overrides the behaviour
		scope OVERRIDE: {
			constant MAIN(0x8013A63C)
			constant TABLE(0x8018BFFC)

			scope TYPE: {
				constant DEFAULT(0x00)		// ? Used in VS and for some 1P characters
				constant LINK(0x01)			// Do nothing for a bit (1P Link)
				constant YOSHI_TEAM(0x02)	// set to 0x07
				constant KIRBY(0x03)		// set to 0x08
				constant POLYGON(0x04)		// set to 0x09
				constant MARIO_BROS(0x05)	// set to 0x03 for Luigi players
				constant GIANT_DK(0x06)		// set to 0x00
				constant UNKNOWN_1(0x07)	// set to 0x02
				constant RTTF(0x08)			// set to 0x0D
				constant ALLY(0x09)			// set to 0x03
				constant TRAINING(0x0A)		// No override
			}
		}

		// @ Description
		// Second, read byte 0x03 and sets byte 0x01
		// Sets the main behaviour subroutine
		scope SET: {
			constant MAIN(0x8013A4AC)
			constant TABLE(0x8018BFAC)

			scope STATE: {
				constant DEFAULT(0x00)		// 0x0C = 0x80137778, 0x01 = 0x02
				constant UNKNOWN_1(0x01)	// 0x0C = 0x80137778, 0x01 = 0x03
				constant UNKNOWN_2(0x02)	// 0x0C = 0x80137778, 0x01 = 0x08
				constant ALLY(0x03)			// 0x0C = 0x80137778, 0x01 = 0x09
				constant FALCON(0x04)		// 0x0C = 0x80137778, 0x01 = 0x0A
				constant YOSHI_TEAM(0x07)	// 0x0C = 0x80137778, 0x01 = 0x09
				constant KIRBY_TEAM(0x08)	// 0x0C = 0x80137778, 0x01 = 0x0A
				constant POLYGON(0x09)		// 0x0C = 0x80137778, 0x01 = 0x02
				//constant UNUSED_1(0x0A)		// nothing
				//constant UNUSED_2(0x0B)		// nothing
				//constant UNUSED_3(0x0C)		// nothing
				constant RTTF(0x0D)			// 0x0C = 0x80137778, 0x01 = 0x0B
				//constant UNUSED_4(0x0E)		// nothing
				constant STAND(0x0F)		// 0x0C = 0x80137A18
				constant WALK(0x10)			// 0x0C = 0x80137AA4
				constant EVADE(0x11)		// 0x0C = 0x80137C7C
				constant JUMP(0x12)			// 0x0C = 0x80137CD8
				constant UNKNOWN_3(0x13)	// 0x0C = 0x80137E70
			}
		}

		// @ Description
		// Third, run
		// Runs the main behaviour subroutine. (usually is 0x80137778)
		// If still performing a controller command, exit.
		scope CALCULATE_INPUT: {

			// Run the main subroutine to determine the state. Then runs the state.

			// @ Description
			// This is the usually routine that handles SSB's AI
			scope DEFAULT: {
				constant MAIN(0x80137778)


				// Checks own action to decide next input
				scope ACTION_CHECK: {
					constant MAIN(0x80136D0C)

					// BRANCH LOCATIONS
					// 0x80136D20 if Action.CliffWait
					// 0x80136E20 if Action.DownWaitD/DownWaitU
					// 0x80136F4C if Action.Teeter/TeeterStart
					// 0x80136F60 if Action.CrouchIdle
					// 0x80136F7C if Action.Barrel
					// 0x80137024 if Action.GrabPull
					// 0x80137074 if Action.InhaleWait
					// 0x80137080 if Action.EggLay
					// 0x80137088 if Action.Stun
					// 0x80137090 if Action.Sleep
					// 0x80137098 if Action.ThrownDK
					// 0x801370F0 Kirby Check
					// 0x80137160 Ness Check
					// 0x80137294 branch if not in STAND (training)
					// 0x801372D0 branch if unknown timer (0x2C) is not > 300
					// 0x80137300 stick jump if unknown flag?
					// 0x8013731C branch if not taken damage
						// check if state = YOSHI_TEAM, KIRBY_TEAM, or POLYGON?
					// 0x8013759C if Action.Tumble


				}

				// Loops through each player. Run away from them if they meet a criteria
				scope EVADE_CHECK: {
					constant MAIN(0x80132BC8)		// Returns 1 to change state to EVADE
					scope PLAYERS: {
						constant OBJ_PTR(0x800466FC)

						// 0x80132BF8 - Skip to end if no players found

						// 0x80132C00 - Load these floats in case cpu wants to run away from them
						scope evade_area: {
							constant address(0x8018BB90)
							constant x_tolerance(2500.0)
							constant y_tolerance(1500.0)
							constant multiplier(3.0)	// magic
						}

						// loop through players
						// 0x80132C24 - Skip if player = self
						// 0x80132C38 - Skip if same team

						// if here, player = enemy
						// 0x80132C40 - Get enemy x velocity
						// 0x80132C50 - Take enemy coordinates
						// 0x80132C88 - skip enemy if they have a star
						// 0x80132CAC - check if enemy has an item
						// 0x80132CBC - if item = hammer, don't approach
						// if they are too close, walk away from them
					}
				}

				// skip PROJECTILE_CHECK if Character.ID = METAL
				// skip PROJECTILE_CHECK if Character.ID = GDK
				// Remix skips projectile check for GBOWSER

				// @ Description
				// Change state if a hazard is near
				scope HAZARD_CHECK: {
					constant MAIN(0x80135B78)
					scope PROJECTILES: {
						constant OBJECT_PTR(0x80046704)
						scope DANGER_AREA: {
							constant unknown_1(9.0)	// f28 magic # 0x80135C38
							constant distance(15.0)	// f26 magic # 0x80135C40
							constant unknown_2(0.5)	// f24 magic # 0x80135C48
						}
						// 0x80135C34 - skip if to no active projectiles
						// 0x80135C68 - goto 80135CA0 if owner = self
						// 0x80135C78 - goto 80135CA0 if a specific mode?
						// 0x80135D4C - goto 80135CA0 if projectile is not close?
						// 0x80135CA0 - skip if update_interval(0x100) = 0
						// 0x80135CA8 - skip if update_interval(0x100) = 1
						// 0x80135CB8 - skip if tangibility(0x144) = FALSE
						// 0x80135CCC - skip if hitbox(0x150) <= 0
						// 0x80135CF8 - skip if projectile not moving towards cpu

						// 0x80135E70 - Check if cpu can reflect/absorb this (character id check)
					}

					scope ITEMS: {
						constant OBJECT_PTR(0x80046700)
						scope DANGER_AREA: {
							constant unknown_1(9.0)	// f28 magic # 0x80135EE4
							constant distance(15.0)// f26 magic # 0x80135ED4
							constant unknown_2(0.5)	// f24 magic # 0x80135C38
					}
						// 0x80135EF4 - skip if no active items
						// todo: see what is here

						// 0x80136114 - Reflect/Absorb check
					}

				}
				// IF HAZARD FOUND, SET STATE TO SHIELD

				// ITEM CHECK
				// 0x801379B4 - exit routine if no item is in hand
				// ^ check if holding crate, barrel, capsule, or egg
				// Sets state to ITEM_HAVE if they have another item

			}

			// @ Description
			// After the main subroutine is completed,
			scope RUN_STATE: {
				// 0x8013A3C0 - run the state if v0 != 0

				constant TABLE(0x8018BF7C)
				scope STATE_ID: {
					constant NOTHING(0x0)		// do nothing
					constant MOVE(0x01)			// move to a position
					constant ATTACK(0x02)		// attack a position
					constant EVADE(0x03)		// runs away from player
					constant RECOVER(0x04)		// recover to stage
					constant UNKNOWN_1(0x05)	// ? JAL 0x80138104, 	Chad walks over and jabs you
					constant ITEM_HAVE(0x06)	// If they have an item in hand 0x8013815C
					constant SHIELD(0x07)		// ? JAL 0x80137FD4, 	shields on and off constantly
					constant UNKNOWN_4(0x08)	// ? JAL 0x801397F4
					constant YOSHI_TEAM(0x09)	// JAL 0x80139A60
					constant UNKNOWN_5(0x0A)	// ? JAL 0x80139D6C
					constant RTTF(0x0B) 		// JAL 0x8013A298
				}

				scope STATE: {

					// state 0x02
					scope ATTACK: {
						constant MAIN(0x801392C8)

						// returns 1 if valid target found
						scope LOCATE_TARGET: {
						constant MAIN(0x8013837C)
							// checks cpu is yoshi team or Giant DK
							// loop through each player
							scope TARGET_PLAYER: {
								constant MAIN(0x80132D18)
								constant PLAYER_1_PTR(0x800466FC)
								constant RNG_PTR(0x8003B944)

								// 0x80132D8C branch if player changed percent

								// 0x80132DE8 update target player
							}
							// 0x80132A10
							// Returns 0 if target is off stage
							scope IGNORE_CHECK: {
								constant main(0x800F8FFC)
								constant clipping_enabled_PTR(0x80131368)

							}

							// branch if IGNORE_CHECK returned 0
						}

						// loops through each
						// a0 = target player
						scope ATTACK_CHECK: {
								constant MAIN(0x80132EC8)
						}

						// 0x801332E0 check if target in Action.PASS
						// 0x801392D8 branch if no valid target found

						// load the targets coordinates

						// 0x80139384 branch if target is too far away

						// 0x- check if target has a super star?
					}



					// @ Description
					// Used while an item is held by cpu players
					scope ITEM_HAVE: {
						constant MAIN(0x8013815C)

						// first reads item id, then branch if its crate, capsule or egg

						// 0x80138308 - branch if Item ID < Item.EGG.ID
						// 0x80138318 - branch if NOT a Pokeball
					}
				}


			}
		}

		// @ Description
		// Fourth, applies the input that was determined by the previous routines.
		// Uses controller commands to set
		scope APPLY_INPUT: {
			constant MAIN(0x80131C68)
			constant TABLE(0x8018B7C0)
		}
	}

	// @ Description
	// Level 10 stuff
	// Allows the game to not break when an AI is set to Level 10
	scope level_ten: {

		// Run away from opponents who are coming off the respawn plat
		// However, vanilla AI doesn't seem too great at evading.
		scope check_invulnerable_: {
			OS.patch_start(0xAD6C4, 0x80132C84)
			j		check_invulnerable_
			lw		t9, 0x05B4(s0)				// original line 1, get player invuln flag
			OS.patch_end()

			beq		s3, t9, _avoid_player
			lbu		t9, 0x0013(a0)				// t6 = cpu level
			slti	t9, t9, 10					// t9 = 0 if 10 or greater
			bnez	t9, _normal					// do normal logic if not LVL 10
			lw		t9, 0x05A4(s0)				// get invulnerability timer

			beqz	t9, _normal					// proceed as normal if not invulnerable
			nop

			_avoid_player:
			j		0x80132C90
			nop

			_normal:
			j		0x80132CAC
			lw		v0, 0x084C(s0)				// original branch line 2

		}

		// @ Description
		// Allows for additional ways to get up a cliff
		scope extend_cliff_attack_: {
			OS.patch_start(0xB1844, 0x80136E04)
			j		extend_cliff_attack_
			lbu		t9, 0x0013(a0)				// t6 = cpu level
			OS.patch_end()

			slti	t9, t9, 10					// t9 = 0 if 10 or greater
			bnez	t9, _set_input				// do normal logic if not LVL 10
			addiu	a1, r0, 0x0004				// a1 = default input (normal getup)

			// if here, choose to attack normally or to jump
			jal     Global.get_random_int_  	// v0 = (random value)
			lli     a0, 0x2             		// a0 = 2
			lw		a0, 0x004C(sp)				// restore a0
			srl		v0, v0, 1					// v0 = v0 >> 1
			beqzl	v0, _set_input
			addiu	a1, r0, ROUTINE.CLIFF_LET_GO // a1 = custom input

			_set_input:
			jal		0x80132564					// set cpus input
			nop
			j		0x80137768					// goto rest of routine.
			or		v0, r0, r0
		}

		// @ Description
		// Instead of taunting, do something else or nothing
		scope taunt_replace_: {
			OS.patch_start(0xB2194, 0x80137754)
			j    	taunt_replace_
			lbu		t6, 0x0013(a0)				// t6 = cpu level
			OS.patch_end()

			slti	at, t6, 10					// at = 0 if 10 or greater
			bnez	at, _set_input
			addiu	a1, r0, ROUTINE.TAUNT		// do taunt


			// level_10:
			lw      t6, 0x0008(a0)				// t6 = current character id
			addiu   at, r0, Character.id.NESS
			beq     at, t6, _pk_thunder			// branch if NESS
			addiu   at, r0, Character.id.LUCAS
			beq     at, t6, _pk_thunder			// branch if LUCAS
			addiu   at, r0, Character.id.JNESS
			bne     at, t6, _no_input			// branch if not JNESS
			nop

			_pk_thunder:
            // Adding these temporary lines to prevent SD related to PK Thunder
            b       _no_input                   // temporary line 1
            nop                                 // temporary line 2
			b       _set_input
			addiu	a1, r0, ROUTINE.USP			// For Ness clones and Lucas

			_set_input:
			// a1 = command to take
			jal     0x80132564          // execute AI command. original line 1
			nop
			_no_input:
			j       0x80137768			// original branch
			or		v0, r0, r0			// original branch line 2

		}

		// @ Description
		// Adds alternate options for LVL 10 cpus to use instead of rolling back and forth.
		// Not perfect but better than roll spamming
		// TODO: Fix reflect behaviour?
		scope stop_roll_spam_: {
			OS.patch_start(0xB3CD4, 0x80139294)
			j    stop_roll_spam_
			// keep line 2
			OS.patch_end()
			OS.patch_start(0xB3CE4, 0x801392A4)
			j    stop_roll_spam_
			// keep line 2
			OS.patch_end()

			lbu 	t6, 0x0013(a0)			// t6 = cpu level
			slti	at, t6, 10				// at = 0 if 10 or greater
			bnez    at, _end				// do normal if not LVL 10
			nop

			_advanced_ai:
			lw      t6, 0x0024(a0)          // get current action
			lli     at, Action.TurnRun
			slt     at, at, t6				// ~
			bnezl   at, _end				// ~
			lli     a1, ROUTINE.RESET_STICK // Tell the bot to reset stick. Skip if not moving/idle.

			lw      t6, 0x0008(a0)          // get character ID
			sll     t6, t6, 2
			li      at, Character.close_quarter_combat.table
			addu    t6, t6, at				// t6 = entry
			lw		t6, 0x0000(t6)			// load characters entry in jump table
			beqz	t6, _continue			// use do a short hop aerial attack most likely
			nop
			jr      t6
			nop

			_ness:
			b       _end
			addiu   a1, r0, 0x34         	// command = Ness double jump cancel.

			_lucas:
			jal     Global.get_random_int_  // v0 = (random value)
			lli     a0, 0xFF             	// ~
			sll     at, v0, 31
			beqz    at, _continue        	// 1/2 chance to shine
			lw		a0, 0x0048(sp)			// restore player struct
			b       _shine
			nop

			_yoshi:
			b       _end
			addiu   a1, r0, 0x37          	// double jump cancel

			_fox:
			jal     Global.get_random_int_  // v0 = (random value)
			lli     a0, 10             		// 1 in 10 chance to not shine
			beqz	v0, _continue
			lw		a0, 0x0048(sp)			// restore player struct

			_shine:
			addiu   at, r0, 0x2E          // at = rolling forwards command
			beql    at, a1, _fox_direction_check // branch if opponent to the right
			addiu   t6, r0, 0x0001        // a0 = direction to match
			addiu   t6, r0, 0xFFFF        // ~

			_fox_direction_check:
			lh      at, 0x0046(a0)        // at = current direction
			bnel    at, t6, _end
			addiu   a1, r0, ROUTINE.MULTI_SHINE_TURNAROUND 	// custom

			b       _end
			addiu   a1, r0, ROUTINE.MULTI_SHINE // custom

			b       _continue
			nop

			///// kirby

			_kirby:
			constant UTILT_DISTANCE(0x4382)
			addiu   at, r0, 0x2E          	// at = rolling forwards command
			beql    at, a1, _kirby_direction_check // branch if opponent to the right
			addiu   t6, r0, 0x0001        	// a0 = direction to match
			addiu   t6, r0, 0xFFFF        	//
			_kirby_direction_check:
			lh      at, 0x0046(a0)        	// at = current direction
			beq     at, t6, _continue		// maybe do a short hop aerial if opponent in front
			addiu	at, r0, 0x2E           	// at = rolling forwards command
			beq		at, a1, _kirby_less_than // branch if opponent is to the right
			nop
			_kirby_greater_than:
			sub.s	f6, f0, f6				// f6 = f6 - f0
			nop
			b 		_kirby_compare
			nop
			_kirby_less_than:
			sub.s	f6, f8, f0				// f6 = f8 - f0
			nop
			_kirby_compare:
			abs.s   f6, f6
			nop
			lui     at, UTILT_DISTANCE		// at = float 260.0
			mtc1	at, f12					// move at to f12
			c.le.s	f6, f12					// code = 1 if distance less than radius
			nop
			bc1f	_continue
			nop
			b       _end
			lli     a1, ROUTINE.UTILT		// do a UTILT if opponent is behind

			_puff:
			lw		at, 0x01FC(a0)			// get target player
			lw		v0, 0x0084(at)			// v0 = target player struct
			lh      t6, 0x05BA(v0)			// t6 = tangibility flag
			addiu	at, r0, 0x0003
			beq		at, t6, _continue		// don't try to rest if they are intangible
			lli		at, 30					// at = 30 hp
			lw		t6, 0x002C(v0)			// t6 = target players hp%
			blt		at, t6, _continue		// skip rest check if player is less than 30 percent
			addiu	at, r0, 0x2E            // at = rolling forwards command
			beq    at, a1, _puff_less_than  // branch if opponent is to the right
			nop
			_puff_greater_than:
			sub.s	f6, f0, f6				// f6 = f6 - f0
			nop
			b 		_puff_compare
			nop
			_puff_less_than:
			sub.s	f6, f8, f0				// f6 = f8 - f0
			nop
			_puff_compare:
			abs.s   f6, f6
			nop
			lui     at, 0x4382				// at = float 260.0
			mtc1	at, f12					// move at to f12
			c.le.s	f6, f12					// code = 1 if distance less than radius
			nop
			bc1f	_continue
			lli     a1, ROUTINE.PUFF_SHORT_HOP_DAIR	// custom
			b       _end
			lli     a1, ROUTINE.DSP					// do a DSP if close enough to the enemy

			_continue:
			jal     Global.get_random_int_  // v0 = (random value)
			lli     a0, 0xFF             // ~
			sll     at, v0, 30
			beqz    at, _end           	 // 1/4 chance to roll around normally
			lw		a0, 0x0048(sp)			// restore player struct

			// if here then do either a normal shorthop, shorthop dair, or shorthop nair
			addiu   a1, r0, 0x30         // start of custom commands - 1
			andi    at, v0, 3
			addu    a1, a1, at           // command = 0x31 + random(3)

			_end:
			// a1 = command to take (default is a roll. 0x2E or 0x2D)
			jal     0x80132564           // execute AI command. original line 1
			nop
			j       0x801392B8           // original branch
			addiu   v0, r0, 0x0001       // ~

		}

		// Add characters to roll spam jump-table
		// KIRBY
		Character.table_patch_start(close_quarter_combat, Character.id.KIRBY, 0x4)
		dw     stop_roll_spam_._kirby; OS.patch_end()
		// EKIRBY
		Character.table_patch_start(close_quarter_combat, Character.id.JKIRBY, 0x4)
		dw     stop_roll_spam_._kirby; OS.patch_end()
		// NKIRBY
		Character.table_patch_start(close_quarter_combat, Character.id.NKIRBY, 0x4)
		dw     stop_roll_spam_._kirby; OS.patch_end()
		// PUFF
		Character.table_patch_start(close_quarter_combat, Character.id.JIGGLYPUFF, 0x4)
		dw     stop_roll_spam_._puff; OS.patch_end()
		// JPUFF
		Character.table_patch_start(close_quarter_combat, Character.id.JPUFF, 0x4)
		dw     stop_roll_spam_._puff; OS.patch_end()
		// EPUFF
		Character.table_patch_start(close_quarter_combat, Character.id.EPUFF, 0x4)
		dw     stop_roll_spam_._puff; OS.patch_end()
		// FOX
		Character.table_patch_start(close_quarter_combat, Character.id.FOX, 0x4)
		dw     stop_roll_spam_._fox; OS.patch_end()
		// JFOX
		Character.table_patch_start(close_quarter_combat, Character.id.JFOX, 0x4)
		dw     stop_roll_spam_._fox; OS.patch_end()
		// FALCO
		Character.table_patch_start(close_quarter_combat, Character.id.FALCO, 0x4)
		dw     stop_roll_spam_._fox; OS.patch_end()
		// WOLF
		Character.table_patch_start(close_quarter_combat, Character.id.WOLF, 0x4)
		dw     stop_roll_spam_._fox; OS.patch_end()
		// NESS
		Character.table_patch_start(close_quarter_combat, Character.id.NESS, 0x4)
		dw     stop_roll_spam_._ness; OS.patch_end()
		// NNESS
		Character.table_patch_start(close_quarter_combat, Character.id.NNESS, 0x4)
		dw     stop_roll_spam_._ness; OS.patch_end()
		// JNESS
		Character.table_patch_start(close_quarter_combat, Character.id.JNESS, 0x4)
		dw     stop_roll_spam_._ness; OS.patch_end()
		// LUCAS
		Character.table_patch_start(close_quarter_combat, Character.id.LUCAS, 0x4)
		dw     stop_roll_spam_._lucas; OS.patch_end()


		// @ Description
		// Allows cpus to perform a shield drop instead of a normal plat drop
		scope shield_drop_: {
			OS.patch_start(0xB057C, 0x80135B3C)
			j    	shield_drop_
			addiu	a1, r0, ROUTINE.STICK_DOWN		// control routine to run. original line 2
			_return:
			OS.patch_end()

			lbu 	at, 0x0013(a0)			// at = cpu level
			slti	at, at, 10				// at = 0 if 10 or greater
			bnez    at, _end				// do normal if not LVL 10
			nop

			_advanced_ai:
			lw 	    at, 0x0024(a0)			// at = current action
			addiu   a1, r0, Action.Idle
			beql	at, a1, _end            // only shield drop if idle
			addiu	a1, r0, ROUTINE.SHIELD_DROP// a1 = custom shield drop routine
			addiu	a1, r0, ROUTINE.STICK_DOWN // control routine to run. original line 2

			_end:
			// a1 = command to take
			jal     0x80132564           // execute AI command. original line 1
			nop
			j       0x80135B68           // original branch
			lw 		ra, 0x0024(sp)       // original branch line

		}

		// @ Description
		// Adds DSP for LVL 10 JigglyPuffs to use
		scope Puff_DSP_: {

			// These patches will prevent non-level 10 puffs from using DSP
			// JIGGLYPUFF
			Character.table_patch_start(ai_attack_prevent, Character.id.JIGGLYPUFF, 0x4)
			dw    	PREVENT_ATTACK.ROUTINE.PUFF_DSP
			OS.patch_end()

			// JPUFF
			Character.table_patch_start(ai_attack_prevent, Character.id.JPUFF, 0x4)
			dw    	PREVENT_ATTACK.ROUTINE.PUFF_DSP
			OS.patch_end()


			// EPUFF
			Character.table_patch_start(ai_attack_prevent, Character.id.EPUFF, 0x4)
			dw    	PREVENT_ATTACK.ROUTINE.PUFF_DSP
			OS.patch_end()


			// Add DSP as an option to Puffs attack behaviour table
			constant CPU_ATTACKS_ORIGIN(0x1026A4)
			constant dsp_padding(40)
			edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  1,   1,  -130 - dsp_padding, 130 + dsp_padding, 20 - dsp_padding, 280 + dsp_padding)
			edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  1,   1, -130 - dsp_padding, 130 + dsp_padding, 20 - dsp_padding, 280 + dsp_padding)

		}


		// @ Description
		// Helps level 10 Fox not spam his up special
		scope Fox_USP_: {

			// These patches will allow LVL 10 fox to not rely on his up special
			// JIGGLYPUFF
			Character.table_patch_start(ai_attack_prevent, Character.id.FOX, 0x4)
			dw    	PREVENT_ATTACK.ROUTINE.FOX_USP
			OS.patch_end()

			// JFOX
			Character.table_patch_start(ai_attack_prevent, Character.id.JFOX, 0x4)
			dw    	PREVENT_ATTACK.ROUTINE.FOX_USP
			OS.patch_end()

		}

		// @ Description
		// Allow level 10 in CSS. Also allows for all Handicaps to be used.
		scope VS_CSS: {
			scope TABLE {
				constant STRUCT(0x8009EDD0)
			}

			// Handles right arrow press
			scope handle_right_arrow_press_: {
				OS.patch_start(0x133AC8, 0x80135848)
				jal     handle_right_arrow_press_
				lw      t8, 0x0000(s2)     // original line 1 - get current value
				OS.patch_end()

				// s0 = CSS panel struct

				lw      t0, 0x0084(s0)     // t0 = type (0 = HMN, 1 = CPU)
				beqzl   t0, _end           // if Human, then this is Handicap
				lli     t0, 0x0028         // t0 = 40 = max Handicap value

				lli     t0, 0x000A         // t0 = 10 = max CPU Level value

				_end:
				jr      ra
				slt     at, t8, t0         // original line 2 modified from slti
			}

			// Occurs when going from 2 to 1 (left arrow press)
			OS.patch_start(0x134D44, 0x80136AC4)
			b       0x80136B2C             // original line 1 modified to point to jal for render_right_arrow_
			OS.patch_end()

			// 0x80136B2C
			// Check to determine if right arrow should be rendered
			scope render_right_arrow_: {
				OS.patch_start(0x134DAC, 0x80136B2C)
				jal     render_right_arrow_
				sll     t7, s3, 0x0002     // t7 = port * 4
				bne     s1, at, 0x80136B5C // original line 2 (line 3 and 4 are identical, so we can overwrite 3)
				OS.patch_end()

				// s8 = CSS panel struct p1
				// s3 = port
				subu    t7, t7, s3         // t7 = port * 3
				sll     t7, t7, 0x0004     // t7 = port * 0x30
				subu    t7, t7, s3         // t7 = port * 0x2F
				sll     t7, t7, 0x0002     // t7 = port * 0xBC = offset to CSS panel struct
				addu    t7, s8, t7         // t7 = CSS panel struct

				lw      t7, 0x0084(t7)     // t7 = type (0 = HMN, 1 = CPU)
				beqzl   t7, _end           // if Human, then this is Handicap
				lli     at, 0x0028         // at = 40 = max Handicap value

				lli     at, 0x000A         // at = 10 = max CPU Level value

				_end:
				jr      ra
				nop
			}

            // Renders 10 for CPU Level or the appropriate Handicap indicators
            scope render_10_: {
                // render 1
                OS.patch_start(0x135210, 0x80136F90)
                jal     render_10_._render_1
                lw      t9, 0x0038(t9)      // original line 1 - t9 = offset to number image
                OS.patch_end()

                // render 0
                OS.patch_start(0x135270, 0x80136FF0)
                jal     render_10_._render_0
                swc1    f8, 0x005C(v0)      // original line 1 - set y position
                lw      ra, 0x001C(sp)      // original line 2 - restore ra
                jr      ra                  // original line 4 - return
                addiu   sp, sp, 0x0060      // original line 3 - deallocate stack
                OS.patch_end()

                _render_1:
				// 0x0028(sp) = CSS panel struct
                // t6 = CPU level / Handicap
				lw      at, 0x0028(sp)      // at = CSS panel struct
				lw      at, 0x0084(at)      // at = type (0 = HMN, 1 = CPU)
				beqz    at, _handicap       // if Human, then this is Handicap
                lli     at, 0x000A          // at = 10
                beql    t6, at, pc() + 8    // if level 10...
                lw      t9, 0x003C(sp)      // ...then set the offset to be for "1"
				_render_number_return:
                jr      ra
                lw      a0, 0x0034(sp)      // original line 2 - a0 = CPU level object

				_handicap:
				slt     at, t6, at          // at = 1 if less than 10
				bnez    at, _render_number_return // if less than 10, just render the number
				addiu   t0, t6, -0x000A     // t0 = index in handicap.table

				// if 10 or higher, then we'll render icons for indicators
				li      at, handicap.table
				sll     t0, t0, 0x0001      // t0 = offset to handicap indicator info
				addu    at, at, t0          // at = handicap indicator info
				lbu     t1, 0x0001(at)      // t1 = level
				sw      t1, 0x0030(sp)      // save level to stack
				lb      t0, 0x0000(at)      // t0 = icon
				bltz    t0, _use_css_images // if not a char_id, then we'll use the CSS images file
                lw      a0, 0x0034(sp)      // a0 = Handicap value object

				li      t1, 0x80116E10      // t1 = main character struct table
				sll     t2, t0, 0x0002      // t2 = t0 * 4 (offset in struct table)
				addu    t1, t1, t2          // t1 = pointer to character struct
				lw      t1, 0x0000(t1)      // t1 = character struct
				lw      t2, 0x0028(t1)      // t2 = main character file address pointer
				lw      t2, 0x0000(t2)      // t2 = main character file address
				lw      t1, 0x0060(t1)      // t1 = offset to attribute data
				addu    t1, t2, t1          // t1 = attribute data address
				lw      t1, 0x0340(t1)      // t1 = pointer to stock icon footer address
				b       _draw_icon
				lw      a1, 0x0000(t1)      // a1 = stock icon footer address

				_use_css_images:
				addiu   sp, sp, -0x0030     // allocate stack space
				sw      a0, 0x0004(sp)      // save registers
				sw      at, 0x0008(sp)      // ~

				// make sure CSS images file is loaded (this can run before setup_)
		        Render.load_file(File.CSS_IMAGES, Render.file_pointer_2)          // load CSS images into file_pointer_2

				lw      a0, 0x0004(sp)      // load registers
				lw      at, 0x0008(sp)      // ~
				addiu   sp, sp, 0x0030      // deallocate stack space

				lbu     t0, 0x0000(at)      // t0 = icon type
				li      a1, Render.file_pointer_2 // a1 = pointer to CSS images file start address
				lw      a1, 0x0000(a1)      // a1 = base file address
				lli     t1, handicap.type.POLYGON_TEAM
				beql    t0, t1, _draw_icon  // if polygon, use polygon icon
				addiu   a1, a1, CharacterSelect.VARIANT_ICON_OFFSET.POLYGON // a1 = address of polygon icon image
				lli     t1, handicap.type.METAL
				beql    t0, t1, _draw_icon  // if metal mario, use metal mario icon
				addiu   a1, a1, CharacterSelect.VARIANT_ICON_OFFSET.METAL // a1 = address of metal mario icon image
				// if here, then masterhand
				addiu   a1, a1, CharacterSelect.VARIANT_ICON_OFFSET.MASTER_HAND // a1 = address of masterhand icon image

				_draw_icon:
				jal     Render.TEXTURE_INIT_ // v0 = RAM address of texture struct
				addiu   sp, sp, -0x0030     // allocate stack space for TEXTURE_INIT_
				addiu   sp, sp, 0x0030      // restore stack space

				lw      at, 0x0028(sp)      // at = CSS panel struct
				lw      at, 0x0020(at)      // at = Handicap texture object
				lw      at, 0x0074(at)      // at = Handicap image struct
				lwc1    f0, 0x0058(at)      // f0 = Handicap x position
				lui     at, 0x4204          // at = x offset
				mtc1    at, f2              // f2 = x offset
				add.s   f0, f0, f2          // f0 = x position
				lui     at, 0x4347          // at = y position
				swc1    f0, 0x0058(v0)      // set X position
				sw      at, 0x005C(v0)      // set Y position
				lli     a1, 0x0201
				sh      a1, 0x0024(v0)      // turn on blur

				// now draw a rectangle colored for 1p difficulty
				lw      t1, 0x0030(sp)      // t1 = type
				beqz    t1, _end_handicap   // if type is NONE, skip
				lui     t0, 0x8014
				lw      t0, 0xC4A4(t0)      // t0 = file 0x000 address
				addiu   a1, t0, 0x330       // a1 = address of a rectangle
                lw      a0, 0x0034(sp)      // a0 = Handicap value object
				jal     Render.TEXTURE_INIT_ // v0 = RAM address of texture struct
				addiu   sp, sp, -0x0030     // allocate stack space for TEXTURE_INIT_
				addiu   sp, sp, 0x0030      // restore stack space

				lli     t0, 0x0003          // t0 = height
				sh      t0, 0x003C(v0)      // set height
				lui     t0, 0x4352          // Y position
				sw      t0, 0x005C(v0)      // set Y position
				lw      t0, 0x000C(v0)      // t0 = icon image struct
				lw      t0, 0x0058(t0)      // t0 = X position
				sw      t0, 0x0058(v0)      // set X position
				lli     a1, 0x0201
				sh      a1, 0x0024(v0)      // turn on blur

				li      t0, level_colors
				lw      t1, 0x0030(sp)      // t1 = type
				addiu   t1, t1, -0x0001     // t1 = index in colors table
				sll     t1, t1, 0x0002      // t1 = offset in colors table
				addu    t0, t0, t1          // t0 = address of color
				lw      t0, 0x0000(t0)      // t0 = color
				sw      t0, 0x0028(v0)      // set color

				_end_handicap:
				// skip rendering numbers
				j       0x80136FF8
				nop

				level_colors:
				dw 0x416FE4FF // Very Easy
				dw 0x8DBB5AFF // Easy
				dw 0xE4BE41FF // Normal
				dw 0xE47841FF // Hard
				dw 0xE44141FF // Very Hard

                _render_0:
                lw      t6, 0x002C(sp)      // t6 = CPU level
                lli     at, 0x000A          // at = 10
                bne     t6, at, _end        // if not level 10, skip
                lw      a0, 0x0034(sp)      // a0 = CPU level object

                lui     t1, 0x8014
                lw      t1, 0xC4A4(t1)      // t1 = file 0x0 address
                lw      t9, 0x0038(sp)      // t9 = 0 image footer offset
                sw      ra, 0x005C(sp)      // save ra
                jal     Render.TEXTURE_INIT_
                addu    a1, t9, t1          // a1 = texture address

                lw      ra, 0x005C(sp)      // restore ra

                // now update footer
                lw      at, 0x000C(v0)      // at = "1" image footer
                lw      t1, 0x005C(at)      // t1 = y position
                sw      t1, 0x005C(v0)      // set y position
                lh      t1, 0x0024(at)      // t1 = image flags
                sh      t1, 0x0024(v0)      // set image flags
                lui     t1, 0x4100          // t1 = x offset from "1" x position
                mtc1    t1, f4              // f4 = x offset from "1" x position
                lwc1    f6, 0x0058(at)      // f6 = "1" x position
                add.s   f4, f4, f6          // f4 = "0" x position
                swc1    f4, 0x0058(v0)      // set x position

                _end:
                jr      ra
                nop

				scope handicap {
					scope type {
						constant POLYGON_TEAM(0xFD)
						constant METAL(0xFE)
						constant MASTER_HAND(0xFF)
					}
					scope level {
						constant NONE(0)
						constant VERY_EASY(1)
						constant EASY(2)
						constant NORMAL(3)
						constant HARD(4)
						constant VERY_HARD(5)
					}

					table:
					db Character.id.YOSHI, level.VERY_EASY
					db Character.id.YOSHI, level.EASY
					db Character.id.YOSHI, level.NORMAL
					db Character.id.YOSHI, level.HARD
					db Character.id.YOSHI, level.VERY_HARD
					db Character.id.KIRBY, level.VERY_EASY
					db Character.id.KIRBY, level.EASY
					db Character.id.KIRBY, level.NORMAL
					db Character.id.KIRBY, level.HARD
					db Character.id.KIRBY, level.VERY_HARD
					db type.POLYGON_TEAM,  level.VERY_EASY
					db type.POLYGON_TEAM,  level.EASY
					db type.POLYGON_TEAM,  level.NORMAL
					db type.POLYGON_TEAM,  level.HARD
					db type.POLYGON_TEAM,  level.VERY_HARD
					db Character.id.DK,    level.VERY_EASY
					db Character.id.DK,    level.EASY
					db Character.id.DK,    level.NORMAL
					db Character.id.DK,    level.HARD
					db Character.id.DK,    level.VERY_HARD
					db type.METAL, 		   level.VERY_EASY
					db type.METAL, 		   level.EASY
					db type.METAL, 		   level.NORMAL
					db type.METAL, 		   level.HARD
					db type.METAL, 		   level.VERY_HARD
					db type.MASTER_HAND,   level.VERY_EASY
					db type.MASTER_HAND,   level.EASY
					db type.MASTER_HAND,   level.NORMAL
					db type.MASTER_HAND,   level.HARD
					db type.MASTER_HAND,   level.VERY_HARD
					db Character.id.SAMUS, level.NONE
					OS.align(4)
				}
            }
		}


		// @ Description
		// asm fixes and so LVL 10 works in normal gameplay without causing issues for the other cpu levels
		scope fixes: {

			// occurs often
			scope clamp_level_9_1: {
				OS.patch_start(0xACFD0, 0x80132590)
				j		clamp_level_9_1
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t7, 0x0013(a0)		// original line
				slti	v1, t7, 10			// v1 = 0 if 10 or greater
				beqzl	v1, pc() + 8
				lli		t7, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				addiu 	v1, a0, 0x01CC		// original line 3
			}

			// occurs often
			scope clamp_level_9_2: {
				OS.patch_start(0xB2ED0, 0x80138490)
				j		clamp_level_9_2
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t7, 0x0013(a0)		// original line
				slti	t0, t7, 10			// t0 = 0 if 10 or greater
				beqzl	t0, pc() + 8
				lli		t7, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				addiu	t0, r0, 0x0001		// original line 3
			}

			// while aerial against an opponent
			scope clamp_level_9_3: {
				OS.patch_start(0xAD0A4, 0x80132664)
				j		clamp_level_9_3
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t2, 0x0013(a0)		// original line
				slti	v0, t2, 10			// v0 = 0 if 10 or greater
				beqzl	v0, pc() + 8
				lli		t2, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				subu 	v0, t3, t2			// original line 3
			}

			// ?
			scope clamp_level_9_4: {
				OS.patch_start(0xB3568, 0x80138B28)
				j		clamp_level_9_4
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t8, 0x0013(s0)		// original line
				slti	t2, t8, 10			// t2 = 0 if 10 or greater
				beqzl	t2, pc() + 8
				lli		t8, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				addiu 	t2, r0, 0x0001		// original line 3
			}

			// ?
			scope clamp_level_9_5: {
				OS.patch_start(0xAD1E4, 0x801327A4)
				j		clamp_level_9_5
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t7, 0x0013(a0)		// original line
				slti	at, t7, 10			// at = 0 if 10 or greater
				beqzl	at, pc() + 8
				lli		t7, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				lui 	at, 0x3F80			// original line 3
			}

			// ?
			scope clamp_level_9_6: {
				OS.patch_start(0xAD2C4, 0x80132884)
				j		clamp_level_9_6
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t2, 0x0013(a0)		// original line
				slti	t6, t2, 10			// t6 = 0 if 10 or greater
				beqzl	t6, pc() + 8
				lli		t2, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				addiu	t6, r0, 0x0001		// original line 3
			}

			// while near an opponent
			scope clamp_level_9_7: {
				OS.patch_start(0xADAA0, 0x80133060)
				j		clamp_level_9_7
				// keeping original line 2
				_return:
				OS.patch_end()

				lbu		t8, 0x0013(s0)		// original line
				slti	at, t8, 10			// at = 0 if 10 or greater
				beqzl	at, pc() + 8
				lli		t8, 9				// if above 9, clamp to 9

				j 		_return + 0x8
				lui		at, 0x3f80			// original line 3
			}

			// while hanging on cliff
			scope clamp_level_9_8: {
				OS.patch_start(0xB17AC, 0x80136D6C)
				j		clamp_level_9_8
				lbu		t9, 0x0013(a2)		// get cpu level
				nop
				nop
				_return:
				OS.patch_end()

				slti	a1, t9, 10			// a1 = 0 if 10 or greater
				lbu		t9, 0x0013(a2)
				beqzl	a1, pc() + 8
				lli		t9, 9				// if above 9, clamp to 9

				bc1fl 	_og_skip
				nop
				sll		v1, v1, 1

				_og_skip:
				j		_return
				addiu	a1, r0, 0x0009
			}

			// other addresses that read cpus lvl
			// 80131EEC - check if LVL => 5
			// 80133830 - check if LVL => 5
			// 80133A38 - check if LVL => 3
			// 80133A6C - check if LVL => 3
			// 80133A78 - check if LVL => 3
			// 80133A94 - ?
			// 801355E8 - ?
			// 80135684 - check if LVL => 6 (fast fall)
			// 8013569C - ?
			// 80135734 - check if LVL => 5
			// 80135744 - check if LVL => 5
			// 80135784 - check if LVL => 5
			// 80135E38 - ?
			// 801360DC - ?
			// 80136E30 - math
			// 80136E98 - check if LVL => 4
			// 80136EC0 - ?
			// 801370B0 - ?
			// 80137364 - ?
			// 801373B0 - ?
			// 801373FC - ?
			// 801375E8 - check if LVL => 4
			// 80137610 - ?
			// 80137900 - ?
			// 801381B8 - check if LVL => 4
			// 801389C4 - prevent LVL 9 cpu from using Links Bomb, or PK Thunder
			// 80138BE4 - ?
			// 8013908C - check if LVL => 4, or 3
			// 801390B4 - ?
			// 80139138 - check if LVL => 7
			// 80139160 - ?
			// 8013940C - ?
			// 80139934 - ?
			// 80139EB0 - ?
			// 8013A964 - ?
		}

	}


} // __AI__
