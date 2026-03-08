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


    is_default_cpu_lvl_set:
    dw 0

    // set the default cpu level
    // 800A3FE8, 800A4D28, 800A4F18
    scope force_default_cpu_lvl_setup: {
        OS.patch_start(0x1391AC, 0x8013AF2C)
        j       force_default_cpu_lvl_setup
        nop
        _return:
        OS.patch_end()


        addiu   s3, s3, 0xBDC8      // og line 2

        li      at, is_default_cpu_lvl_set
        lw      t2, 0x0000(at)      // t2 = 0 if default cpu level is not already set up
        bnez    t2, _skip_initial_setup
        addiu   t3, r0, 1
        sw      t3, 0x0000(at)      // save setup flag

        // if here, set the default cpu levels
        OS.read_word(Toggles.entry_default_cpu_level + 0x4, t2) // t2 = cpu lvl override
        beqzl   t2, _continue
        lli     t2, 3               // set level to 3 if toggle == 0

        _continue:
        li      t3, 0x800A4D28      // t3 = port 1 default cpu level
        sb      t2, 0x0000(t3)      // overwrite default cpu level 1
        sb      t2, 0x0074(t3)      // overwrite default cpu level 2
        sb      t2, 0x00E8(t3)      // overwrite default cpu level 3
        sb      t2, 0x015C(t3)      // overwrite default cpu level 4
        _skip_initial_setup:
        j       _return             // return
        lui     at, 0x8014          // og line 1

    }

    // @ Description
    // Extend Giant DK check that multiplies the values from attack table
    scope size_multiplier_check_: {
        OS.patch_start(0xADE68, 0x80133428)
        j       size_multiplier_check_
        swc1    f18, 0x00A0(sp)             // og line 2
        _return:
        OS.patch_end()

        bne     a1, at, _check_size         // og line 1, branch if not GIANT DK
        nop

        // giant dk
        j       _return
        nop

        _check_size:
        // s0 = player struct
        // at is safe register
        li      at, Size.multiplier_table
        lbu     t9, 0x000D(s0)              // t9 = controller port
        sll     t9, t9, 0x0002              // t9 = offset to player entry
        addu    at, at, t9                  // at = player entry (float)
        lw      at, 0x0000(at)              // at = player size multiplier entry
        lui     t9, 0x3F80                  // t9 = 1.0F
        beq     at, t9, _normal             // skip if size multiplier is already 1.0F
        nop

        // adjust for size multipler
        mtc1    at, f0                      // if here, set f0 = players size multiplier
        j       0x80133438                  // continue to giant DKs size multiplier part of routine
        nop

        _normal:
        j       0x8013345C                  // do normal code
        nop
    }

    // @ Description
    // CPUs won't evade opponents while they are invulnerable. (super star, respawn)
    scope evade_fix_: {
        OS.patch_start(0xAD640, 0x80132C00)
        j      evade_fix_
        nop
        _return:
        OS.patch_end()

        // automatic improved AI if remix 1P
        addiu   t6, r0, 0x4                 // t6 = remix 1P mode
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, at) // at = Mode Flag Address
        beq     at, v1, _invulnerable_check // if Remix 1p, automatic advanced ai
        nop
        // Check improved AI toggle
        OS.read_word(Toggles.entry_improved_ai + 0x4, at)   // at = improved AI toggle
        beqz    at, _original
        nop

        _invulnerable_check:
        lw      at, 0x05B0(a0)              // at = super star timer
        slti    at, at, 112                 // t0 = 0 if > 112 frames left
        beqz    at, _skip_evade_check       // branch if this player is invulnerable from super star
        lw      at, 0x05A4(a0)              // at = respawn timer
        slti    at, at, 20                  // t0 = 0 if > 20 frames left
        beqz    at, _skip_evade_check       // branch if this player is invulnerable from respawning

        _original:
        lui     at, 0x8019
        j       _return
        lwc1    f24, 0xBB90(at)

        _skip_evade_check:
        j       0x80132CE8                  // skip to end of evasion routine
        nop


    }

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
        lbu     v1, 0x0013(s0)              // v1 = cpu level
        slti    v1, v1, 10                  // t6 = 0 if 10 or greater
        beqz    v1, _fix_recovery           // improved recovery if level 10

        // No fix if Vanilla 1P
        OS.read_word(Global.match_info, at) // at = current match info struct
        lbu     v1, 0x0000(at)          //
        lli     at, Global.GAMEMODE.CLASSIC
        beq     at, v1, _original           // dont use toggle if 1P/RTTF
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

    // If the target is set outside of the blastzone's bounds, move it inwards
    // this is for the CPU to not walk off and SD on stages with walkoffs
    // ftComputerFollowObjectiveWalk(FTStruct *fp)
    // 80134E98+4E4
    scope fix_target_pos_x: {
        OS.patch_start(0xAFDBC, 0x8013537C)
        j fix_target_pos_x
        nop
        _return:
        OS.patch_end()

        constant BLASTZONE_PADDING(0x4348) // 200.0

        Toggles.read(entry_improved_ai, at)
        beqz at, _end // if improved_ai is OFF, skip
        nop

        lw t0, 0x44(sp) // load computer struct

        lwc1 f2, 0x60(t0) // f2 = target X

        lui at, BLASTZONE_PADDING
        mtc1 at, f4 // f4 = BLASTZONE_PADDING

        li t2, 0x80131300 // base for blastzone positions
        lw t2, 0x0(t2)

        _left_blastzone:
        lh t1, 0x007A(t2) // left blastzone
        mtc1 t1, f6
        cvt.s.w f6, f6 // f6 = left blastzone (float)
        add.s f6, f6, f4 // f6 = left blastzone + PADDING
        c.le.s f2, f6  // code = 1 if target X <= (left blastzone + padding)
        nop
        bc1f _right_blastzone // if not, skip
        nop
        // if target X <= (left blastzone + padding), clamp it
        b _end
        swc1 f6, 0x60(t0)

        _right_blastzone:
        lh t1, 0x0078(t2) // right blastzone
        mtc1 t1, f6
        cvt.s.w f6, f6 // f6 = right blastzone (float)
        sub.s f6, f6, f4 // f6 = right blastzone - PADDING
        c.le.s f6, f2 // code = 1 if (right blastzone - padding) <= target X
        nop
        bc1f _end // if not, skip
        nop
        // if target X > (right blastzone - padding), clamp it
        b _end
        swc1 f6, 0x60(t0)

        _end:
        lw t5, 0x14c(s0) // original line 1
        j   _return
        lw t0, 0x44(sp) // original line 2
    }

    // @ Description
    // Allows remix characters to recover properly.
    // Runs every frame while in the recovery state (off stage)
    scope fix_remix_recovery: {
        OS.patch_start(0xB298C, 0x80137F4C)
        j       fix_remix_recovery
        lw t6, 0x8(a0) // t6 = character ID (og line 1)
        OS.patch_end()

        // at = Charater.id.PIKACHU
        // t6 = characters ID
        beq     t6, at, _pikachu
        addiu   at, r0, Character.id.JPIKA
        beq     t6, at, _pikachu
        addiu   at, r0, Character.id.EPIKA
        beq     t6, at, _pikachu
        addiu   at, r0, Character.id.SHEIK
        beq     t6, at, _sheik
        addiu   at, r0, Character.id.DSAMUS
        beq     t6, at, _dsamus
        addiu   at, r0, Character.id.PEPPY
        beq     t6, at, _peppy
        addiu   at, r0, Character.id.MTWO
        beq     t6, at, _mewtwo
        addiu   at, r0, Character.id.WOLF
        beq     t6, at, _wolf
        addiu   at, r0, Character.id.BANJO
        beq     t6, at, _banjo
        nop

        _normal:
        j       0x80137FBC
        nop

        _sheik:
        lw      v0, 0x0024(a0)              // v0 = current action ID
        addiu   at, r0, 0x00EE              // at = Sheiks Aerial Charge action
        bne     at, v0, _normal
        nop
        // if here, cancel NSP
        jal     0x80132564                  // execute AI command
        addiu   a1, r0, 0x0C                // arg1 = command = PRESS Z
        j       0x80137FBC + 0x4            // return to end of routine
        nop

        _dsamus:
        lw      v0, 0x0024(a0)              // v0 = current action ID
        addiu   at, r0, 0x00E7              // at = DSamus Aerial Charge action
        bne     at, v0, _normal
        nop
        // if here, cancel NSP
        jal     0x80132564                  // execute AI command
        addiu   a1, r0, 0x0C                // arg1 = command = PRESS Z
        j       0x80137FBC + 0x4            // return to end of routine
        nop

        _peppy:
        lw      v0, 0x0024(a0)              // v0 = current action ID
        addiu   at, r0, 0x00F2              // at = Peppy's Aerial Charge action
        bne     at, v0, _normal
        nop
        // if here, cancel NSP
        jal     0x80132564                  // execute AI command
        addiu   a1, r0, 0x0C                // arg1 = command = PRESS Z
        j       0x80137FBC + 0x4            // return to end of routine
        nop

        _mewtwo:
        lw      v0, 0x0024(a0)              // v0 = current action ID
        addiu   at, r0, 0x00E2              // at = Mewtwos Aerial Charge action
        bne     at, v0, _normal
        nop
        // if here, cancel NSP
        jal     0x80132564                  // execute AI command
        addiu   a1, r0, 0x0C                // arg1 = command = PRESS Z
        j       0x80137FBC + 0x4            // return to end of routine
        nop


        _pikachu:
        OS.read_word(Global.match_info, v0) // v0 = current match info struct
        lbu     v0, 0x0000(v0)
        lli     at, Global.GAMEMODE.CLASSIC
        beq     v0, at, _pikachu_normal     // branch if vanilla 1P/RTTF
        nop

        Toggles.read(entry_improved_ai, v0)
        bnez    v0, _normal                 // branch to improved ai. (normal recovery behaviour)
        nop

        _pikachu_normal:
        j       0x80137F58 + 0x4
        lw      v0, 0x0024(a0)

        _banjo:
        lw      v0, 0x0024(a0)              // get current action
        addiu   at, r0, 0x00EF              // Banjo Flight
        bne     v0, at, _normal             // exit if not in flight action
        nop

        _banjo_flight:
        lw      v0, 0x001C(a0)              // current frame
        addiu   at, r0, 21                  // frame 22
        bne     v0, at, _normal             // exit if not frame 22
        nop
        // if here, banjo usp input B
        lh      v0, 0x01BE(a0)              // v0 = buttons pressed
        ori    v0, v0, 0x4000               // press B
        sh      v0, 0x01BE(a0)              // save press B mask
        // then check if banjo is already above clipping
        addiu   at, r0, -1                  // at = 0xFFFFFFF
        lw      v0, 0x00EC(a0)              // get current clipping below player
        bne     at, v0, _normal             // don't press B is already safe
        nop

        jal     0x80132564                  // execute AI command
        addiu   a1, r0, 0x09                // arg1 = PRESS B
        j       0x80137FBC + 0x4            // return to end of routine
        nop

        _wolf:
        lw      v0, 0x0024(a0)          // get current action
        addiu   at, r0, 0x00E4          // wolf USP action 1
        beq     at, v0, _wolf_set_target_coordinates
        addiu   at, r0, 0x00E3          // wolf USP action 2
        beq     at, v0, _wolf_set_target_coordinates
        addiu   at, r0, 0x00E6          // wolf USP action 3
        beq     at, v0, _wolf_set_target_coordinates
        addiu   at, r0, 0x00E8          // wolf USP action 4
        bne     at, v0, _normal
        nop

        _wolf_set_target_coordinates:
        addiu   v0, a0, 0x01CC
        sw      r0, 0x0060(v0)          // set target X to 0
        lui     at, 0x457A              // at = 4000.0
        j       0x80137FBC
        sw      at, 0x0064(v0)          // set target Y to a high number

        _center_stage:
        addiu   v0, a0, 0x01CC
        sw      r0, 0x0060(v0)          // set target X to 0
        j       0x80137FBC
        sw      r0, 0x0064(v0)          // set target Y to 0
    }

    // 0x80137F24+0x98
    scope custom_recovery_logic: {
        OS.patch_start(0xB29FC, 0x80137FBC)
        j       custom_recovery_logic
        nop
        _return:
        OS.patch_end()

        jal 0x80134E98 // original line 1: ftComputerFollowObjectiveWalk(fp)
        nop // original line 2

        lw a0,0x18(sp) // restore a0 = player struct

        // check for entries in the recovery logic table
        lw      t6, 0x8(a0) // t6 = character ID
        sll     v0, t6, 2
        li      at, Character.recovery_logic.table
        addu    v0, v0, at              // v0 = entry
        lw      at, 0x0000(v0)          // at = characters entry in jump table
        beqz    at, _end                // skip if no entry
        nop
        or      v0, r0, r0
        jalr    at                      // jump to entry if exists
        nop

        _end:
        j   _return
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

        li      t2, Toggles.entry_single_button_mode
        lw      t2, 0x0004(t2)              // t2 = single_button_mode (0 if OFF, 1 if 'A', 2 if 'B', 3 if 'R', 4 if 'A+C', 5 if 'B+C', 6 if 'R+C')
        beqz    t2, _check_level_10         // branch if Single Button Mode is disabled
        sltiu   t1, t2, 4                   // t1 = 0 if including 'C' button
        beqzl   t1, pc() + 8                // if so, subtract 3 to get corresponding main button value
        addiu   t2, t2, -3                  // ~
        addiu   t1, r0, 0x0003              // t1 = 3 ('R')
        bne     t1, t2, _fail               // don't let CPU tech if Single Button Mode 'A' or 'B'
        nop

        _check_level_10:
        lbu     t1, 0x0013(t0)              // v1 = cpu level
        slti    t1, t1, 10                  // t6 = 0 if 10 or greater
        beqz    t1, _advanced_ai            // random teching if level 10
        addiu   t1, r0, 0x0004              // t1 = Remix 1p single player mode flag (yes, delay slot)
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, t0)
        beq     t0, t1, _advanced_ai        // if Remix 1p, automatic advanced ai
        OS.read_byte(Global.current_screen, t0) // t0 = current screen (yes, delay slot)
        lli     t1, 0x0036                  // t1 = training screen_id
        beq     t0, t1, _improved_ai        // if Training, we'll use the menu's values
        // No fix if Vanilla 1P
        OS.read_word(Global.match_info, t1) // t1 = current match info struct (yes, delay slot)
        lbu     t0, 0x0000(t1)
        lli     t1, Global.GAMEMODE.CLASSIC
        beq     t1, t0, _original           // dont use toggle if 1P/RTTF
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
        OS.read_word(Global.match_info, t0) // t0 = address of match_info
        addiu   t0, t0, Global.vs.P_OFFSET  // t0 = address of first player sturct

        or      t3, r0, t0                      // t3 = address of first player struct
        addiu   t3, t3, (Global.vs.P_DIFF * 4)  // t3 = address of last player struct

        _loop:
        bgt     t0, t3, _original           // if (t0 > p4), skip -- end if we're past port 4
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
        lli     t0, 0x0036                  // t0 = training screen_id
        OS.read_byte(Global.current_screen, t1) // t1 = screen_id
        bne     t0, t1, _do_random          // if not training, always do random
        nop
        OS.read_word(Training.entry_tech_behavior + 0x4, t0) // t0 = index of tech routine
        beqz    t0, _do_random              // if t0 = 0, then do default random behavior
        sll     t0, t0, 0x0002              // t0 = offset to tech routine
        li      t1, tech_option_table
        addu    t1, t1, t0                  // t1 = address of tech routine
        lw      t0, 0x0000(t1)              // t0 = tech routine
        jr      t0                          // do tech routine
        nop

        _do_random:
        jal     Global.get_random_int_      // v0 = (0-99)
        lli     a0, 000100                  // ~
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
        jal     tech_fail_                  // don't tech
        move    a0, s0                      // a0 - player object

        li      t0, VsStats.tech_miss_tracker
        lbu     t2, 0x000D(s1)              // t2 = player index (0 - 3)
        sll     t2, t2, 0x0002              // t2 = player index * 4
        addu    t0, t0, t2                  // t0 = address of missed techs for this player
        lw      t2, 0x0000(t0)              // t2 = missed tech count
        addiu   t2, t2, 0x0001              // increment
        b       _end
        sw      t2, 0x0000(t0)              // store updated tech count

        _original:
        jal     tech_roll_og_               // original line 1
        move    a0, s0                      // original line 2
        bnezl   v0, _end                    // original line 3
        nop                                 // original line 4
        jal     tech_in_place_og_           // original line 5
        move    a0, s0                      // original line 6
        bnezl   v0, _end                    // original line 7
        nop                                 // original line 8
        jal     _fail                       // original line 9, modified
        move    a0, s0                      // original line 10
        nop                                 // original line 11

        _end:
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        _roll_left:
        move    a0, s0                      // a0 - player object
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t0, 0x0044(t0)              // t0 = direction (1 = right, -1 = left)
        lli     a1, FORWARD                 // a1 - enum direction
        lli     t1, 0x0001                  // t1 = right
        beql    t0, t1, pc() + 8            // if facing right, then left is backward
        lli     a1, BACKWARD                // a1 - enum direction
        jal     tech_roll_                  // tech roll
        nop
        b       _end                        // end
        nop

        _roll_right:
        move    a0, s0                      // a0 - player object
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t0, 0x0044(t0)              // t0 = direction (1 = right, -1 = left)
        lli     a1, BACKWARD                // a1 - enum direction
        lli     t1, 0x0001                  // t1 = right
        beql    t0, t1, pc() + 8            // if facing right, then right is forward
        lli     a1, FORWARD                 // a1 - enum direction
        jal     tech_roll_                  // tech roll
        nop
        b       _end                        // end
        nop

        tech_option_table:
        dw 0                                // default, not used
        dw _roll_backward + 12              // backward
        dw _roll_forward + 12               // forward
        dw _in_place + 12                   // in place
        dw _roll_left                       // left
        dw _roll_right                      // right
        dw _fail                            // none
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
        // lw      t6, 0x0160(v1)              // original line 1 (moved to 'ZCancel._z_cancel_opts')
        // slti    at, t6, 0x000B              // original line 2 (moved to 'ZCancel._z_cancel_opts')
        or      at, r0, r0                  // clear at

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        _check_level_10:
        lw      t0, 0x0084(a0)              // t0 = player struct
        lbu     t0, 0x0013(t0)              // t0 = cpu level
        slti    t0, t0, 10                  // t0 = 0 if 10 or greater
        beqz    t0, _advanced_ai            // z cancel if lvl 10

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

        li      t0, Toggles.entry_single_button_mode
        lw      t0, 0x0004(t0)              // t0 = single_button_mode (0 if OFF, 1 if 'A', 2 if 'B', 3 if 'R', 4 if 'A+C', 5 if 'B+C', 6 if 'R+C')
        beqz    t0, _continue               // branch if Single Button Mode is disabled
        sltiu   t1, t0, 4                   // t1 = 0 if including 'C' button
        beqzl   t1, pc() + 8                // if so, subtract 3 to get corresponding main button value
        addiu   t0, t0, -3                  // ~
        addiu   t1, r0, 0x0003              // t1 = 3 ('R')
        bne     t1, t0, _no_cancel          // don't let CPU Z-cancel if Single Button Mode 'A' or 'B'
        nop

        _continue:
        OS.read_word(Global.match_info, t0) // t0 = address of match_info
        addiu   t0, t0, Global.vs.P_OFFSET  // t0 = address of first player sturct

        or      t3, r0, t0                      // t3 = address of first player struct
        addiu   t3, t3, (Global.vs.P_DIFF * 4)  // t3 = address of last player struct

        _loop:
        bgt     t0, t3, _end                // if (t0 > p4), end -- end if we're past port 4
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
        OS.read_word(Global.match_info, t0) // t0 = current match info struct
        lbu     t2, 0x0000(t0)
        lli     a0, Global.GAMEMODE.CLASSIC
        beq     t2, a0, _end                // dont use toggle if vanilla 1P/RTTF

        // Some characters have extra hitboxes if they don't z cancel.
        lw      t1, 0x0008(v1)              // get character ID
        // addiu   at, Character.id.KIRBY
        // beq     t1, at, _kirby
        // addiu   at, Character.id.JKIRBY
        // beq     t1, at, _kirby
        // addiu   at, Character.id.NKIRBY
        // beq     t1, at, _kirby
        // addiu   at, Character.id.PIKACHU
        // beq     t1, at, _fair_check
        // addiu   at, Character.id.JPIKA
        // beq     t1, at, _fair_check
        // addiu   at, Character.id.EPIKA
        // beq     t1, at, _fair_check
        // addiu   at, Character.id.NPIKACHU
        // beq     t1, at, _fair_check
        // addiu   at, Character.id.DSAMUS
        // beq     t1, at, _nair_check
        // addiu   at, Character.id.MTWO
        // beq     t1, at, _nair_check
        // //addiu   at, Character.id.NMTWO
        // //beq     t1, at, _nair_check
        // //addiu   at, Character.id.NDSAMUS
        // //beq     t1, at, _nair_check
        // addiu   at, Character.id.JIGGLYPUFF
        // beq     t1, at, _dair_check
        // addiu   at, Character.id.NJIGGLY
        // beq     t1, at, _dair_check
        // addiu   at, Character.id.EPUFF
        // beq     t1, at, _dair_check
        // addiu   at, Character.id.JPUFF
        // beq     t1, at, _dair_check
        // addiu   at, Character.id.NBOWSER
        // beq     t1, at, _dair_check
        // addiu   at, Character.id.BOWSER
        // bne     t1, at, _rng
        b       _rng
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
    // Makes LV10 CPUs charge NSP less often
    // Attempt to make them more active and fun to fight
    // ftComputerCheckTryChargeSpecialN
    // 80136A20 + C
    scope charge_less_often: {
        OS.patch_start(0xB146C, 0x80136A2C)
        j     charge_less_often
        lli   v1, 2 // original line 1
        _return:
        OS.patch_end()

        // a0 = player struct

        lbu     t0, 0x0013(a0) // t0 = cpu level
        slti    t0, t0, 10     // t0 = 0 if 10 or greater
        bnez    t0, _default    // if not level 10, continue
        nop

        addiu   sp, sp, -0x18 // save variables
        sw      a0, 0x4(sp)
        sw      v0, 0x8(sp)
        sw      v1, 0xC(sp)

        // if the cpu checks in all frames where it thinks it makes sense to charge
        // and we check for a single value to let it pass,
        // you can consider every 60 units as a "one chance in a second"
        jal     Global.get_random_int_      // v0 = (random value)
        lli     a0, 0x3C                    // a0 = random max = 60

        or      t0, r0, v0  // t0 = random result

        lw      a0, 0x4(sp)
        lw      v0, 0x8(sp)
        lw      v1, 0xC(sp)
        addiu   sp, sp, 0x18 // restore variables

        // if random returns anything other than 0, do not initiate charge
        bnez    t0, _skip_charge
        nop

        b _default // otherwise, default behavior
        nop

        _skip_charge:
        j       0x80136BFC // original line 1 (was a branch)
        or      v0, r0, r0 // original line 2 (return 0)

        _default:
        j       _return
        lli     a1, 3 // original line 2
    }

    // @ Description
    // Improves cpu ability to utilize charge attacks
    // ftComputerCheckTryChargeSpecialN
    // 80136A20 + 34
    scope improve_remix_specials: {
        OS.patch_start(0xB1494, 0x80136A54)
        j     improve_remix_specials
        nop
        OS.patch_end()

        // v0 = character id
        // a0 = player struct
        // a1 = samus's character id

        _character_id_check:
        lli     at, Character.id.SHEIK
        beq     at, v0, _check_needle
        lli     at, Character.id.PEPPY
        beq     at, v0, _check_revolver
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
        lli     at, Character.id.BOWSER
        beq     at, v0, _bowser
        lli     at, Character.id.GBOWSER
        beq     at, v0, _bowser
        nop

        // if here, no charge attacks.
        _end:
        j       0x80136BFC                  // original line 1 (was a branch)
        or      v0, r0, r0                  // original line 2

        _donkey_kong:
        j       0x80136A60                  // jump to dk part of routine
        lw      v0, 0x0024(a0)              // v0 = action id

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
        addiu   at, r0, Sheik.Action.NSPA_CHARGE
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Action.JumpSquat
        beq     v0, at, _end                // end if in a jumpsquat
        nop

        // don't add any lines here
        _check_revolver:
        lw      v0, 0x0024(a0)              // v0 = current action id
        addiu   at, r0, Peppy.Action.NSPG_BEGIN
        beq     v0, at, _end_0x80136BF8     // end if beginning nsp
        addiu   at, r0, Peppy.Action.NSPA_BEGIN
        beq     v0, at, _end_0x80136BF8     // ~
        addiu   at, r0, Peppy.Action.NSPG_CHARGE
        beq     v0, at, _end_0x80136BF8     // end to keep charging
        addiu   at, r0, Peppy.Action.NSPG_SHOOT
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Peppy.Action.NSPA_SHOOT
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Peppy.Action.NSPA_CHARGE
        beq     v0, at, _end                // end if shooting
        addiu   at, r0, Action.JumpSquat
        beq     v0, at, _end                // end if in a jumpsquat
        nop

        // if here, check needle ammo
        lw      t0, 0x0AE0(a0)              // t0 = needle charge level
        slti    at, t0, 0x0006              //
        beqz    at, _end                    //
        nop
        j       0x80136B3C                  // go to original routine for Samus B press?
        nop

        _bowser:
        lw      v0, 0x0024(a0)              // v0 = current action id
        addiu   at, r0, 0xDE                // Bowser.Action.USPGround
        bne     v0, at, _end                // branch if not doing a grounded up special
        nop
        sb      r0, 0x01C8(a0)              // set stick x to zero
        b       _end
        nop

        _end_0x80136BF8:
        j      0x80136BF8
        nop

    }

    // @ Description
    // Add Remix characters to charge NSP cancel check in ftComputerCheckTryCancelSpecialN
    // Cancels charge by pressing Z
    // 80136C0C + 34
    scope improve_remix_charged_NSP_1: {
        constant SWITCH_END_ADDR(0x80136C0C+0xF0)

        OS.patch_start(0xB1680, 0x80136C40)
        j     improve_remix_charged_NSP_1
        nop
        OS.patch_end()

        lli     at, Character.id.DONKEY
        beq     v1, at, dk
        nop
        lli     at, Character.id.JDK
        beq     v1, at, dk
        nop
        lli     at, Character.id.DSAMUS
        beq     v1, at, dsamus
        nop
        lli     at, Character.id.SHEIK
        beq     v1, at, sheik
        nop
        lli     at, Character.id.MTWO
        beq     v1, at, mewtwo
        nop

        b _check_giant_dk // no additional characters matched
        nop

        dk:
        j       0x80136C0C+0x3C // DK's block
        nop

        dsamus:
        lw      v0, 0x24(a0) // load current action
        lli     at, Action.SAMUS.ChargeShotCharging
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.DSamusNSPChargeAir
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.DSamusNSPChargeAir
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.DSCharging
        beq     v0, at, _cancel_with_z
        nop
        // If here no actions matched. Exit and return 0
        j       SWITCH_END_ADDR
        move    v0, r0

        sheik:
        lw      v0, 0x24(a0) // load current action
        lli     at, Sheik.Action.NSPG_CHARGE
        beq     v0, at, _cancel_with_z
        lli     at, Sheik.Action.NSPA_CHARGE
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.NeedleStormChargeGround
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.NeedleStormChargeAir
        beq     v0, at, _cancel_with_z
        nop
        // If here no actions matched. Exit and return 0
        j       SWITCH_END_ADDR
        move    v0, r0

        mewtwo:
        lw      v0, 0x24(a0) // load current action
        lli     at, Mewtwo.Action.ShadowBallCharge
        beq     v0, at, _cancel_with_z
        lli     at, Mewtwo.Action.ShadowBallChargeAir
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.ShadowBallCharge
        beq     v0, at, _cancel_with_z
        lli     at, Action.KIRBY.ShadowBallChargeAir
        beq     v0, at, _cancel_with_z
        nop
        // If here no actions matched. Exit and return 0
        j       SWITCH_END_ADDR
        move    v0, r0

        _cancel_with_z:
        jal     0x80132564 // ftComputerSetCommandWaitShort
        lli     a1, 0xC // command = nFTComputerInputButtonZ1
        j       SWITCH_END_ADDR // go to the end of the switch block
        lli     v0,1 // will return 1

        _check_giant_dk:
        // check if character is Giant DK
        lli     at, 0x1a // load Giant DK's id
        bne     v1, at, _end_false // if not Giant DK, go to the end of the switch block
        nop
        j       0x80136C0C+0x3C // if Giant DK, go to his and DK's block
        nop

        _end_false:
        // If here no actions matched. Exit and return 0
        j       SWITCH_END_ADDR
        move    v0, r0
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
        addiu    at, r0, Character.id.SLIPPY
        beq      v0, at, _fox_or_ness_opponent  // branch if opponent is Slippy
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
        lw       a0, 0x0ADC(s0)                 // a0 = kirby hat ID
        lw       v0, 0x0024(s0)                 // v0 = current action
        addiu    at, r0, 0x0003                 // at = ID.Samus / Hat ID for Samus
        beq      a0, at, _samus_action_check    // branch if SAMUS
        addiu    at, r0, 0x1E                   // SHEIK hat id
        beq      a0, at, _sheik_action_check    // branch if SHEIK
        addiu    at, r0, 0x1B                   // MEWTWO hat id
        beq      a0, at, _mewtwo_action_check   // branch if MEWTWO
        addiu    at, r0, 0x13                   // DSAMUS hat id
        beq      a0, at, _dsamus_action_check   // branch if DSAMUS
        nop
        j        0x80138CB8                     // if here, no charge attack
        sltiu    at, a0, 0x000E

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
        lli     at, Character.id.MLUIGI
        beq     at, v0, _ignore_projectile  // ignore the projectile if MLUIGI (same as MMARIO)
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
    // seems to run every aerial frame
    scope usp_check_: {
        OS.patch_start(0xACB80, 0x80132140)
        j     usp_check_
        nop
        _return:
        OS.patch_end()

        // at = fox's character id
        // t9 = character id
        beq      t9, at, _fox      // branch to Fox usp action check
        addiu    at, r0, Character.id.JFOX
        beq      t9, at, _fox      // branch to Fox usp action check
        addiu    at, r0, Character.id.PEPPY
        beq      t9, at, _fox      // branch to Goemon usp action check
        addiu    at, r0, Character.id.GOEMON
        beq      t9, at, _goemon   // branch to Goemon usp action check
        addiu    at, r0, Character.id.EBI
        beq      t9, at, _ebi      // branch to Ebisumaru usp action check
        addiu    at, r0, Character.id.FALCO
        beq      t9, at, _fox      // branch to Fox usp action check
        nop

        _normal:
        j        0x80132174        // skip fox branch
        mtc1     r0, f8            // original line 2 (delay slot)

        _fox:
        j       _return + 0x4     // original - take fox branch
        lw      v0, 0x0024(a0)     // v0 = current action

        _ebi:
        lw      v0, 0x0024(a0)     // v0 = current action
        addiu   at, r0, 0xDF       // MagicCloudRide
        beq     at, v0, _goemon_usp
        nop
        b       _normal
        nop

        _goemon:
        lw      v0, 0x0024(a0)     // v0 = current action
        addiu   at, r0, 0xDF      // MagicCloudRide
        beq     at, v0, _goemon_usp
        addiu   at, r0, 0xE0      // MagicCloudAttack
        beq     at, v0, _goemon_usp
        addiu   at, r0, 0xE1      // MagicCloudJump
        beq     at, v0, _goemon_usp
        addiu   at, r0, 0xE2      // MagicCloudEscape
        beq     at, v0, _goemon_usp
        nop
        b       _normal
        nop

        _goemon_usp:
        j       0x801321A4
        lbu     v0, 0x0003(t0)

    }

    // fixed Goemons recovery so he always points upwards
    // this hook checks ever frame for goemon cpus
    scope recovery_stick_y_fix: {
        OS.patch_start(0xACF7C, 0x8013253C)
        j       recovery_stick_y_fix
        lw      v0, 0x0008(a0)    // v0 = character id
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.EBI        // at = Ebisumaru
        beq     at, v0, _ebisumaru_action_check
        addiu   at, r0, Character.id.GOEMON    // at = Goemon
        bne     at, v0, _continue

        lw      v0, 0x0024(a0)    // v0 = current action
        addiu   at, r0, 0xDF      // MagicCloudRide
        beq     at, v0, _goemon_usp
        addiu   at, r0, 0xE0      // MagicCloudAttack
        beq     at, v0, _goemon_usp
        addiu   at, r0, 0xE2      // MagicCloudEscape
        beq     at, v0, _cloud_escape
        nop

        b       _continue
        nop

        _ebisumaru_action_check:
        lw      v0, 0x0024(a0)    // v0 = current action
        addiu   at, r0, 0xDF      // MagicCloudRide
        bne     at, v0, _continue
        nop
        addiu   v0, r0, 0x50                // v0 =  stick Y
        sb      v0, 0x01C9(a0)              // save stick y
        lw      v0, 0xEC(a0)                // v0 = clipping id cpu is above (0xFFFF if none)
        addiu   at, r0, 0xFFFF
        beq     at, v0, _continue           // branch if still recovering
        nop
        addiu   v0, r0, 0x80                // v0 =  Press A flag
        sb      r0, 0x01C9(a0)              // set stick to zero
        b       _continue
        sb      v0, 0x01C6(a0)              // cpu presses A to perform a nair

        _goemon_usp:
        addiu   v0, r0, 0x50                // v0 =  stick Y
        sb      v0, 0x01C9(a0)              // save stick y

        // end goemon usp
        lw      v0, 0xEC(a0)                // v0 = clipping id cpu is above (0xFFFF if none)
        addiu   at, r0, 0xFFFF
        beq     at, v0, _continue           // branch if still recovering
        nop
        addiu   v0, r0, 0x20                // v0 =  Press Z flag
        b       _continue
        sb      v0, 0x01C6(a0)              // save flag

        _cloud_escape:
        sb      r0, 0x01C6(a0)              // remove z press if already escaping

        _continue:
        lw      t8, 0x0044(sp)              // og line 1
        j       _return
        lbu     t9, 0x0007(t8)              // og line 2
    }



    // CONTROLLER COMMANDS
    // 0xAxyy - yy = Stick X
    macro STICK_X(stick_value) {
        db 0xA0 //TODO: WAIT TIMER
        db {stick_value}
    }

    // 0xBxyy - yy = Stick Y
    macro STICK_Y(stick_value) {
        db 0xB0 //TODO: WAIT TIMER
        db {stick_value}
    }
    // 0xAxyy - yy = Stick X
    macro STICK_X(stick_value, wait) {
        db 0xA{wait}
        db {stick_value}
    }

    // 0xBxyy - yy = Stick Y
    macro STICK_Y(stick_value, wait) {
        db 0xB{wait}
        db {stick_value}
    }

    // moves towards target coordinates
    macro MOVE() {
        db 0xC0FF;
    }

    macro PRESS_A(wait) {
        db 0x0{wait};
    }

    macro UNPRESS_A(wait) {
        db 0x1{wait};
    }

    macro PRESS_B(wait) {
        db 0x2{wait};
    }

    macro UNPRESS_B(wait) {
        db 0x3{wait};
    }

    macro PRESS_Z(wait) {
        db 0x4{wait};
    }

    macro UNPRESS_Z(wait) {
        db 0x5{wait};
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
        db AI.CUSTOM_ROUTINE_ID
        db {id}
    }

    // 0xFF00 - End Control Routine
    macro END() {
        db 0xFF; OS.align(4);
    }

    // @ Description
    // Copy and extend the vanilla ai cpu command table
    // 0x80188340
    constant ORIGINAL_TABLE(0x102D80)
    // Must be increased if we reach the limit!
    constant CPU_COMMAND_TABLE_MAX_ENTRIES(0xFF)
    OS.align(16)
    command_table:
    constant TABLE_ORIGIN(origin())
    OS.copy_segment(ORIGINAL_TABLE, (0x31 * 0x4))
    while pc() < (command_table + (CPU_COMMAND_TABLE_MAX_ENTRIES * 0x4)) {
        dw 0x00000000
    }

    constant NUM_VANILLA_CPU_INPUT_ROUTINES(0x31)
    variable NUM_ADDED_CPU_INPUT_ROUTINES(0)

    macro add_cpu_input_routine(routine_label) {
        pushvar origin, base
        origin (AI.TABLE_ORIGIN + (AI.NUM_VANILLA_CPU_INPUT_ROUTINES * 0x4) + (AI.NUM_ADDED_CPU_INPUT_ROUTINES * 0x4))
        dw {routine_label}
        pullvar base, origin

        global variable AI.ROUTINE.{routine_label}(AI.NUM_VANILLA_CPU_INPUT_ROUTINES + AI.NUM_ADDED_CPU_INPUT_ROUTINES)
        constant ROUTINE.{routine_label}(AI.NUM_VANILLA_CPU_INPUT_ROUTINES + AI.NUM_ADDED_CPU_INPUT_ROUTINES)

        print "AI: CPU input routine added - {routine_label} (0x"
        OS.print_hex(AI.ROUTINE.{routine_label})
        print ")\n"

        AI.NUM_ADDED_CPU_INPUT_ROUTINES = AI.NUM_ADDED_CPU_INPUT_ROUTINES + 1

        if AI.ROUTINE.{routine_label} >= (AI.CPU_COMMAND_TABLE_MAX_ENTRIES) {
            error "ERROR: AI.CPU_COMMAND_TABLE_MAX_ENTRIES is too small! The constant value MUST be increased!!!"
        }
    }

    // @ Description
    // New Controller Routines for Cpus
    SHORT_HOP_TOWARDS:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    STICK_X(0x7F, 1)                // stick towards opponent. wait(1)
    CUSTOM(1)                       // press C
    STICK_X(0x7F, 1)                // stick towards opponent. wait(1)
    CUSTOM(2)                       // unpress C
    CUSTOM(0)                       // wait until jumpsquat is complete
    STICK_X(0x0, 0)                 // reset stick x
    END();
    add_cpu_input_routine(SHORT_HOP_TOWARDS)

    SHORT_HOP_AWAY:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    CUSTOM(1)                       // press C
    STICK_X(0x81, 1)                // stick x away from opponent. wait(1)
    CUSTOM(2)                       // unpress C
    CUSTOM(0)                       // wait until jumpsquat is complete
    STICK_X(0x0, 0)                 // reset stick x
    END();
    add_cpu_input_routine(SHORT_HOP_AWAY)

    SHORT_HOP_IN_PLACE:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    CUSTOM(1)                       // press C
    STICK_X(0, 1)                   // neutral stick. wait(1)
    CUSTOM(2)                       // unpress C
    CUSTOM(0)                       // wait until jumpsquat is complete
    STICK_X(0x0, 1)                 // reset stick x, wait 1 frame
    END();
    add_cpu_input_routine(SHORT_HOP_IN_PLACE)

    // this jump is a bit lower than a fullhop
    FULL_C_JUMP_TOWARDS:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    STICK_X(0x7F, 1)                // stick towards opponent. wait(1)
    CUSTOM(1)                       // press C
    STICK_X(0x7F, 1)                // stick towards opponent. wait(1)
    CUSTOM(0)                       // wait until jumpsquat is complete
    CUSTOM(2)                       // unpress C
    STICK_X(0x0, 0)                 // reset stick x
    END();
    add_cpu_input_routine(FULL_C_JUMP_TOWARDS)

    SHORT_HOP_NAIR: // 0x32
    UNPRESS_Z()
    CUSTOM(1)                       // press C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(2)                       // unpress C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(0)                       // wait until jumpsquat is complete
    // attack:
    dh 0xA000                       // reset stick x
    STICK_Y(0x00)                   // reset stick y
    dh 0x0111                       // press A wait(1)
    END();
    add_cpu_input_routine(SHORT_HOP_NAIR)

    SHORT_HOP_DAIR: // 0x33
    UNPRESS_Z()
    CUSTOM(1)                       // press C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(2)                       // unpress C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(0)                       // wait until jumpsquat is complete
    // attack:
    dh 0xA000                       // reset stick x
    STICK_Y(0xB0)                   // point stick down
    dh 0x0111                       // press A
    END();
    add_cpu_input_routine(SHORT_HOP_DAIR)

    PIVOT_AWAY:
    STICK_X(0x81, 9) // stick away for 9 frames
    STICK_X(0, 2) // neutral stick for 1 frame
    STICK_X(0x7F, 1) // stick towards for 1 frame
    STICK_X(0, 9) // neutral stick for 9 frames
    END();
    add_cpu_input_routine(PIVOT_AWAY)

    NESS_DJC_NAIR:  // 0x34
    dh 0xA07F       // point towards opponent
    dh 0xB200       // reset y. wait 2 frames
    dh 0xA07F       // keep pointing
    dh 0xB135       // jump, wait 2 frames
    dh 0xA07F       // point to opponent
    dh 0xB300
    dh 0xA07F
    dh 0xB135
    dh 0xA000
    dh 0xB100
    dh 0x0111
    dh 0xA07F
    dh 0xB200
    END();
    add_cpu_input_routine(NESS_DJC_NAIR)

    NESS_DJC_DAIR:  // 0x??
    dh 0xA07F       // point towards opponent
    dh 0xB200       // reset y. wait 2 frames
    dh 0xA07F       // keep pointing
    dh 0xB135       // jump, wait 2 frames
    dh 0xA07F       // point to opponent
    dh 0xB300
    dh 0xA07F
    dh 0xB135
    dh 0xA000
    dh 0xB100
    dh 0x0111
    dh 0xA07F
    dh 0xB200
    END();
    add_cpu_input_routine(NESS_DJC_DAIR)

    MULTI_SHINE:    // 0x35
    dh 0xA000       // reset sticks
    dh 0xB100       // ~ wait(1)
    dh 0xA07F       // stick x = dash to opponent
    dh 0xB100       // stick y = 0. wait 1 frames
    dh 0xA000       // stick x = 0
    dh 0xB135       // jump. wait 3 frames
    dh 0xA000       //
    dh 0xB0B0       // point stick down. wait 2 frames
    dh 0x0221       // press B
    END();
    add_cpu_input_routine(MULTI_SHINE)

    MULTI_SHINE_TURNAROUND:    // 0x36
    dh 0xA000       // reset sticks
    dh 0xB100       // ~ wait(1)
    dh 0xA07F       // stick x = dash to opponent
    dh 0xB500       // stick y = 0. wait 6 frames
    dh 0xA000       // stick x = 0
    dh 0xB135       // jump. wait 3 frames
    dh 0xA000       //
    dh 0xB0B0       // point stick down. wait 2 frames
    dh 0x0221       // press B
    END();
    add_cpu_input_routine(MULTI_SHINE_TURNAROUND)

    SHIELD_DROP:    // 0x37
    STICK_X(0)      // reset sticks
    STICK_Y(0)      // reset sticks
    db 0x41         // PRESS_Z(); WAIT(1)
    PRESS_Z()       // Keep Z down
    STICK_X(0)
    dh 0xB1B0       // STICK_Y(0xB0) Wait(1)
    STICK_X(0)      // reset sticks
    STICK_Y(0)      // reset sticks
    UNPRESS_Z()     // Unpress Z
    END();          // End routine
    add_cpu_input_routine(SHIELD_DROP)

    LUCAS_BAT_BACKWARDS:
    dh 0xC0C0       // reset buttons?
    STICK_X(0)      // reset stick X
    dh 0xB200       // and stick Y, wait(1)
    STICK_X(0xC0)   // hold stick backwards
    dh 0x0111       // press A
    END();          // End routine
    add_cpu_input_routine(LUCAS_BAT_BACKWARDS)

    LUCAS_BAT_FORWARDS:
    dh 0xC0C0       // reset buttons?
    STICK_X(0)      // reset stick X
    dh 0xB200       // and stick Y, wait(1)
    STICK_X(0x70)   // hold stick forward
    dh 0x0111       // press A
    END();          // End routine
    add_cpu_input_routine(LUCAS_BAT_FORWARDS)

    PUFF_SHORT_HOP_DAIR:
    UNPRESS_Z()
    CUSTOM(1)                       // press C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(2)                       // unpress C
    dh 0xA17F                       // stick x towards opponent. wait(1)
    CUSTOM(0)                       // wait until jumpsquat is complete
    dh 0xB100                       // wait(1)
    // attack:
    dh 0xA000                       // reset stick x
    STICK_Y(0xB0)                   // point stick down
    dh 0x0111                       // press A
    END();
    add_cpu_input_routine(PUFF_SHORT_HOP_DAIR)

    // alternate cliff getup for level 10
    CLIFF_LET_GO:
    UNPRESS_A(); UNPRESS_B();
    STICK_X(0)                      // stick x = 0
    dh 0xB100                       // stick y = 0, wait(1)
    STICK_Y(0xB0)                   // point stick down
    dh 0xA100                       // stick x = 0, wait(1)
    STICK_Y(0x80)                   // jump
    dh 0xA400                       // stick x = 0, wait(4)
    STICK_Y(0); STICK_X(0); END();  // reset sticks, end
    add_cpu_input_routine(CLIFF_LET_GO)

    SMASH_DSP:
    AI.STICK_X(0, 0)
    AI.STICK_Y(0xB0, 0)
    AI.PRESS_B(1)
    AI.STICK_Y(0, 0)
    AI.UNPRESS_B(0)
    AI.END()
    add_cpu_input_routine(SMASH_DSP)

    NSP_TOWARDS:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0x7F) // stick towards opponent
    AI.PRESS_B(1)
    AI.STICK_X(0)
    AI.UNPRESS_B(0)
    END();
    add_cpu_input_routine(NSP_TOWARDS)

    FAIR:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0x83)
    AI.PRESS_A(1)
    AI.STICK_X(0x7F) // stick towards opponent
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(FAIR)

    BAIR:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0x84)
    AI.PRESS_A(1)
    AI.STICK_X(0x7F) // stick towards opponent
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(BAIR)

    DASH_GRAB:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0, 1) // reset stick x
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    CUSTOM(4); // wait for turnaround to finish if needed
    AI.STICK_X(0x7F, 3) // dash towards opponent for more 3f (total: 4)
    AI.PRESS_Z(0)
    AI.PRESS_A(1) // press grab
    AI.STICK_X(0)
    AI.UNPRESS_Z(0)
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(DASH_GRAB)

    DASH_USMASH:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0, 1) // reset stick x
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    CUSTOM(4); // wait for turnaround to finish if needed
    AI.STICK_X(0x7F, 3) // dash towards opponent for more 3f (total: 4)
    CUSTOM(1) // press C
    UNPRESS_A(1); // wait 1f
    CUSTOM(2) // unpress C
    AI.STICK_Y(0x78, 0) // stick up
    AI.PRESS_A(1) // upsmash
    AI.STICK_X(0)
    AI.UNPRESS_Z(0)
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(DASH_USMASH)

    DASH_ATTACK:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    AI.STICK_X(0x7F, 5) // dash towards opponent for 5f
    AI.PRESS_A(1) // dash attack
    AI.STICK_Y(0)
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(DASH_ATTACK)

    USP_TOWARDS:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B();
    AI.STICK_Y(0x78, 0) // stick up
    AI.STICK_X(0x7F, 0) // stick X autofull towards target
    AI.PRESS_B(1) // upB
    AI.STICK_Y(0)
    AI.STICK_X(0)
    AI.UNPRESS_B(0)
    END();
    add_cpu_input_routine(USP_TOWARDS);

    POINT_STICK_TO_TARGET:
    CUSTOM(3);
    END();
    add_cpu_input_routine(POINT_STICK_TO_TARGET);

    JUMPCANCEL_UPSMASH:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    CUSTOM(1) // press C
    UNPRESS_A(1); // wait 1f
    CUSTOM(2) // unpress C
    AI.STICK_Y(0x78, 0) // stick up
    AI.PRESS_A(1) // upsmash
    AI.STICK_X(0)
    AI.UNPRESS_Z(0)
    AI.UNPRESS_A(0)
    END();
    add_cpu_input_routine(JUMPCANCEL_UPSMASH)

    JUMPCANCEL_USP:
    UNPRESS_Z(); UNPRESS_A(); UNPRESS_B(); STICK_Y(0);
    CUSTOM(1) // press C
    UNPRESS_B(1); // wait 1f
    CUSTOM(2) // unpress C
    AI.STICK_Y(0x78, 0) // stick up
    AI.PRESS_B(1) // upB
    AI.STICK_X(0)
    AI.UNPRESS_Z(0)
    AI.UNPRESS_B(0)
    END();
    add_cpu_input_routine(JUMPCANCEL_USP)

    // Empty input to avoid getting inputs overriten
    // Especially useful with recovery_logic functions
    NULL:
    END();
    add_cpu_input_routine(NULL);

    // Training Spam Mode routines

    FTILT_RIGHT:
    // A028B000 01A00010 FF
    AI.STICK_X(0x28, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_A(1)
    AI.STICK_X(0, 0)
    AI.UNPRESS_A(0)
    AI.END()

    FTILT_LEFT:
    // A0D8B000 01A00010 FF
    AI.STICK_X(-0x28, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_A(1)
    AI.STICK_X(0, 0)
    AI.UNPRESS_A(0)
    AI.END()

    FSMASH_RIGHT:
    // A038B000 01A00010 FF
    AI.STICK_X(0x38, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_A(1)
    AI.STICK_X(0, 0)
    AI.UNPRESS_A(0)
    AI.END()

    FSMASH_LEFT:
    // A0C8B000 01A00010 FF
    AI.STICK_X(-0x38, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_A(1)
    AI.STICK_X(0, 0)
    AI.UNPRESS_A(0)
    AI.END()

    NSP:
    // A000B000 2130FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_B(1)
    AI.UNPRESS_B(0)
    AI.END()

    USP:
    // A000B038 21B00030 FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x38, 0)
    AI.PRESS_B(1)
    AI.STICK_Y(0, 0)
    AI.UNPRESS_B(0)
    AI.END()

    DSP:
    // A000B0C8 21B00030 FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(-0x38, 0)
    AI.PRESS_B(1)
    AI.STICK_Y(0, 0)
    AI.UNPRESS_B(0)
    AI.END()

    GRAB:
    // A000B000 40015010 FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_Z(0)
    AI.PRESS_A(1)
    AI.UNPRESS_Z(0)
    AI.UNPRESS_A(0)
    AI.END()

    JAB:
    // A000B000 0110FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(0, 0)
    AI.PRESS_A(1)
    AI.UNPRESS_A(0)
    AI.END()

    FULL_HOP:
    // A000B078 51B000FF
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x78, 0)
    AI.UNPRESS_Z(1)
    AI.STICK_Y(0, 0)
    AI.END()

    SHORT_HOP:
    CUSTOM(1)                       // press C
    AI.STICK_X(0, 0)
    AI.STICK_Y(0, 1)
    CUSTOM(2)                       // unpress C
    AI.END()

    // @ Description
    // DI Types
    scope di_type {
        constant SMASH(0)
        constant SLIDE(1)
    }

    // @ Description
    // DI Strengths
    scope di_strength {
        constant HIGH(1)
        constant MEDIUM(3)
        constant LOW(5)
    }

    // @ Description
    // Stick input directions
    scope stick_direction {
        constant LEFT(0xB0)
        constant RIGHT(0x50)
        constant DOWN(0xB0)
        constant UP(0x50)
        constant CENTER(0x0)
    }

    // @ Description
    // Creates inputs for the given DI type, strength and starting stick directions
    macro di_input(type, strength, stick_x, stick_y) {
        if di_type.{type} == di_type.SLIDE {
            evaluate wait(di_strength.{strength})

            if stick_direction.{stick_y} == stick_direction.CENTER {
                evaluate stick_x_frame_2(stick_direction.{stick_x})
                evaluate stick_x_frame_4(stick_direction.{stick_x})
                evaluate stick_y_frame_2(stick_direction.DOWN)
                evaluate stick_y_frame_4(stick_direction.UP)
            } else {
                evaluate stick_x_frame_2(stick_direction.LEFT)
                evaluate stick_x_frame_4(stick_direction.RIGHT)
                evaluate stick_y_frame_2(stick_direction.{stick_y})
                evaluate stick_y_frame_4(stick_direction.{stick_y})
            }

            STICK_Y(stick_direction.{stick_y})          // set stick y
            STICK_X(stick_direction.{stick_x}, {wait})  // set stick x, wait according to strength
            STICK_Y({stick_y_frame_2})                  // set stick y
            STICK_X({stick_x_frame_2}, {wait})          // set stick x, wait according to strength
            STICK_Y(stick_direction.{stick_y})          // set stick y
            STICK_X(stick_direction.{stick_x}, {wait})  // set stick x, wait according to strength
            STICK_Y({stick_y_frame_4})                  // set stick y
            STICK_X({stick_x_frame_4}, {wait})          // set stick x, wait according to strength
            END()
        } else {
            evaluate wait(di_strength.{strength})
            STICK_Y(stick_direction.{stick_y})          // set stick y
            STICK_X(stick_direction.{stick_x}, {wait})  // set stick x, wait according to strength
            STICK_Y(0)                                  // stick y = 0
            STICK_X(0, {wait})                          // stick x = 0, wait according to strength
            END()
        }
    }

    DI_SMASH_HIGH_LEFT:
        di_input(SMASH, HIGH, LEFT, CENTER)

    DI_SMASH_HIGH_RIGHT:
        di_input(SMASH, HIGH, RIGHT, CENTER)

    DI_SMASH_HIGH_UP:
        di_input(SMASH, HIGH, CENTER, UP)

    DI_SMASH_HIGH_DOWN:
        di_input(SMASH, HIGH, CENTER, DOWN)

    DI_SMASH_MEDIUM_LEFT:
        di_input(SMASH, MEDIUM, LEFT, CENTER)

    DI_SMASH_MEDIUM_RIGHT:
        di_input(SMASH, MEDIUM, RIGHT, CENTER)

    DI_SMASH_MEDIUM_UP:
        di_input(SMASH, MEDIUM, CENTER, UP)

    DI_SMASH_MEDIUM_DOWN:
        di_input(SMASH, MEDIUM, CENTER, DOWN)

    DI_SMASH_LOW_LEFT:
        di_input(SMASH, LOW, LEFT, CENTER)

    DI_SMASH_LOW_RIGHT:
        di_input(SMASH, LOW, RIGHT, CENTER)

    DI_SMASH_LOW_UP:
        di_input(SMASH, LOW, CENTER, UP)

    DI_SMASH_LOW_DOWN:
        di_input(SMASH, LOW, CENTER, DOWN)

    DI_SLIDE_HIGH_LEFT:
        di_input(SLIDE, HIGH, LEFT, CENTER)

    DI_SLIDE_HIGH_RIGHT:
        di_input(SLIDE, HIGH, RIGHT, CENTER)

    DI_SLIDE_HIGH_UP:
        di_input(SLIDE, HIGH, CENTER, UP)

    DI_SLIDE_HIGH_DOWN:
        di_input(SLIDE, HIGH, CENTER, DOWN)

    DI_SLIDE_MEDIUM_LEFT:
        di_input(SLIDE, MEDIUM, LEFT, CENTER)

    DI_SLIDE_MEDIUM_RIGHT:
        di_input(SLIDE, MEDIUM, RIGHT, CENTER)

    DI_SLIDE_MEDIUM_UP:
        di_input(SLIDE, MEDIUM, CENTER, UP)

    DI_SLIDE_MEDIUM_DOWN:
        di_input(SLIDE, MEDIUM, CENTER, DOWN)

    DI_SLIDE_LOW_LEFT:
        di_input(SLIDE, LOW, LEFT, CENTER)

    DI_SLIDE_LOW_RIGHT:
        di_input(SLIDE, LOW, RIGHT, CENTER)

    DI_SLIDE_LOW_UP:
        di_input(SLIDE, LOW, CENTER, UP)

    DI_SLIDE_LOW_DOWN:
        di_input(SLIDE, LOW, CENTER, DOWN)

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

        constant STICK_DOWN(0x27)   // fast fall, plat drop
        constant CLIFF_ATTACK(0x28)
        constant HARD_ITEM_THROW(0x2A)
        constant LIGHT_ITEM_THROW(0x2B)
        constant ROLL_LEFT(0x2D)
        constant ROLL_RIGHT(0x2E)
        constant YOSHI_USP(0x2F)
        constant PK_THUNDER(0x30)   // goes to 0x801324F0
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

        sb      t6, 0x01D3(a0)          // original line 2
        addu    t8, t8, t7              // original line 3
        lw      t8, LOWER(t8)           // original line 4 (modified)
        OS.patch_end()
    }

    // Extend stick commands to add new options
    // By default there are 2 special numbers for stick towards target (full, half)
    // Add commands for stick away from target too
    // 80131C68 + 13C
    scope extend_stick_x_commands: {
        OS.patch_start(0xAC7E4, 0x80131DA4)
        j       extend_stick_x_commands
        nop
        extend_stick_x_commands_end:
        OS.patch_end()

        lbu v1, 0x0000(a2) // v1 = stick value argument
        lli t2,0x81 // AUTOFULL_AWAY
        beq v1, t2, autofull_away
        nop
        lli t2,0x82 // AUTOHALF_AWAY
        beq v1, t2, autohalf_away
        nop
        lli t2,0x83 // FORWARDS (facing direction)
        beq v1, t2, forwards
        nop
        lli t2,0x84 // BACKWARDS (opposite to facing direction)
        beq v1, t2, backwards
        nop

        b _original
        nop

        autofull_away: // 0x81
            lw      t7, 0x8e8(a0) // fighter struct's joint 0 bone
            lwc1    f4, 0x1c(t7) // player X
            lwc1    f6, 0x60(t0) // target X
            addiu   t8, r0, 0x50 // t8 = 80
            c.lt.s  f4, f6 // player X < target X
            nop
            bc1fl   autofull_away_continue
            nop
            addiu   t8, r0, 0xFFB0 // t8 = -80
            autofull_away_continue:
            sb      t8,0x1c8(a0) // save cpu stick X
            j 0x80131C68+0x8D4 // jump out of the switch like the other commands
            addiu   a2,a2,1

        autohalf_away: // 0x82
            lw      t7, 0x8e8(a0) // fighter struct's joint 0 bone
            lwc1    f4, 0x1c(t7) // player X
            lwc1    f6, 0x60(t0) // target X
            addiu   t8, r0, 0x28 // t8 = 40
            c.lt.s  f4, f6 // player X < target X
            nop
            bc1fl   autohalf_away_continue
            nop
            addiu   t8, r0, 0xFFD8 // t8 = -40
            autohalf_away_continue:
            sb      t8,0x1c8(a0) // save cpu stick X
            j 0x80131C68+0x8D4 // jump out of the switch like the other commands
            addiu   a2,a2,1

        forwards: // 0x83
            lw t7, 0x44(a0) // ft = facing direction
            bgez t7, forwards_continue // if facing right, continue
            addiu t8, r0, 0x50 // t8 = 80
            addiu t8, r0, 0xFFB0 // t8 = -80
            forwards_continue:
            sb t8, 0x1c8(a0) // save cpu stick X
            j 0x80131C68+0x8D4 // jump out of the switch like the other commands
            addiu a2,a2,1

        backwards: // 0x84
            lw t7, 0x44(a0) // ft = facing direction
            bgez t7, backwards_continue // if facing right, continue
            addiu t8, r0, 0xFFB0 // t8 = -80
            addiu t8, r0, 0x50 // t8 = 80
            backwards_continue:
            sb t8, 0x1c8(a0) // save cpu stick X
            j 0x80131C68+0x8D4 // jump out of the switch like the other commands
            addiu a2,a2,1

        _original:
        // original lines:
        // go to case FTCOMPUTER_STICK_AUTOFULL
        lli t2,0x7F
        lbu v1, 0x0000(a2)
        beql v1, t2, _j_80131DC8
        lw t7, 0x08E8(a0)

        _end:
        j extend_stick_x_commands_end
        nop

        _j_80131DC8:
        j 0x80131DC8
        nop
    }

    // @ Description
    // Allows custom AI controller commands.
    // Command = 0xFExx (xx = routine index)
    constant CUSTOM_ROUTINE_ID(0xFE)
    scope CUSTOM_COMMANDS: {

        // halts commands from processing until out of jumpsquat
        scope JUMPSQUAT_WAIT: {
            lw      t7, 0x0024(a0)      // t7 = current action
            addiu   t6, r0, Action.JumpSquat // t6 = Action.JumpSquat
            beql    t6, t7, _jump_squat// branch if doing a jumpsquat
            addiu   at, r0, 0x0001      // a1 = 1

            _end:
            j       0x8013253C          // back to original routine
            nop
            _jump_squat:

            sh      at, 0x0006(t0)      // wait 1 frame
            j       0x8013254C          // exit command processing
            addiu   a2, a2, -0x0002     // read this command next frame
        }

        // TODO: MAKE SURE THIS DOESN'T STAY STUCK ON.
        scope PRESS_C: {
            constant index(1)
            lh      t7, 0x01C6(a0)      // t7 = cpu button pressed flags
            ori     t8, t7, 0x0001      // t8 = t7 + c-button press
            j       0x8013253C          // back to original routine
            sh      t8, 0x01C6(a0)      // save c button press
        }

        scope UNPRESS_C: {
            constant index(2)
            lh      t7, 0x01C6(a0)      // t7 = cpu button pressed flags
            andi    t8, t7, 0xFFF0      // t8 = t7 - c-button press
            j       0x8013253C          // back to original routine
            sh      t8, 0x01C6(a0)      // save c button press
        }

        scope STICK_TO_TARGET: {
            constant index(3)

            lw t0, 0x78(a0) // load location vector
            mtc1 r0, f0 // load zero into f0
            lwc1 f2, 0x0(t0) // f2 = location X
            lwc1 f4, 0x4(t0) // f4 = location Y

            addiu t0, a0, 0x1cc // t0 = ftcomputer struct
            lwc1 f6, 0x60(t0) // target x
            lwc1 f8, 0x64(t0) // target y

            lui at, 0x42A0 // at = 80.0
            mtc1 at, f10

            sub.s f12, f6, f2 // dx = target_x - player_x
            sub.s f14, f8, f4 // dy = target_y - player_y

            // dx^2 + dy^2
            mul.s f2, f12, f12
            mul.s f4, f14, f14
            add.s f6, f2, f4

            // if distance == 0, stick = (0, 0)
            c.eq.s f6, f0
            bc1t _zero
            nop

            // magnitude = sqrt(dx^2 + dy^2)
            sqrt.s f8, f6

            // if magnitude == 0
            c.eq.s f8, f0
            bc1t _zero
            nop

            // scale = max / magnitude
            div.s f0, f10, f8

            // scaled dx/dy
            mul.s f2, f12, f0
            mul.s f4, f14, f0

            // convert to integers (truncate)
            cvt.w.s f2, f2
            cvt.w.s f4, f4
            mfc1 at, f2
            sb at, 0x01C8(a0) // save CPU stick_x
            mfc1 at, f4
            sb at, 0x01C9(a0) // save CPU stick_y
            j 0x8013253C          // back to original routine
            nop

            _zero:
            sb r0, 0x01C8(a0) // save CPU stick_x
            sb r0, 0x01C9(a0) // save CPU stick_y
            j 0x8013253C          // back to original routine
            nop
        }

        // halts commands from processing until out of turning animation
        scope TURNAROUND_WAIT: {
            constant index(4)
            lw      t7, 0x0024(a0)          // t7 = current action
            addiu   t6, r0, Action.Turn     // t6 = Action
            beql    t6, t7, _turning        // branch if action matches
            addiu   t6, r0, Action.TurnRun  // t6 = Action
            beql    t6, t7, _turning        // branch if action matches
            nop

            _end:
            j       0x8013253C          // back to original routine
            nop

            _turning:
            addiu   at, r0, 0x0001      // a1 = 1
            sh      at, 0x0006(t0)      // wait 1 frame
            j       0x8013254C          // exit command processing
            addiu   a2, a2, -0x0002     // read this command next frame
        }

        table:                  // Command
        dw JUMPSQUAT_WAIT       // 0xFE00
        dw PRESS_C              // 0xFE01
        dw UNPRESS_C            // 0xFE02
        dw STICK_TO_TARGET      // 0xFE03
        dw TURNAROUND_WAIT      // 0xFE04

        scope extend_routines: {
            OS.patch_start(0x1065BC, 0x8018BB7C)
            dw  extend_routines
            OS.patch_end()

            // a0 = cpu player struct, a2 = argument
            li      at, table           // at = custom ai command table
            lb      t7, 0x0000(a2)      // t7 = custom routine idle
            sll     t7, t7, 0x0002      // t7 = offset in table
            addu    at, at, t7
            lw      at, 0x0000(at)
            jr      at                  // go to the custom routine
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
            j       extend_polygon_check_
            sll     t8, v0, 2                       // OG line 2 t8 = offset in ai_long_range_table_
            _return:
            OS.patch_end()

            // at = 0 if character ID is >= POLY MARIO
            bnez    at, _normal_vanilla_character   // branch if orginal vanilla fighter
            sltiu   at, v0, Character.id.FALCO      // at = 1 if vanilla polygon
            bnez    at, _polygon_fighter            // branch if vanilla polygon fighter
            sltiu   at, v0, Character.NUM_CHARACTERS - Character.NUM_POLYGONS // at = 0 if remix polygon
            bnez    at, _normal_vanilla_character
            nop

            _polygon_fighter:
            j       0x8013389C                      // original line 1 branch
            nop

            _normal_vanilla_character:
            j       _return
            nop

        }
    }


    // if the opponent is far away? classic characters will do one of these jumps
    scope LONG_RANGE: {
        scope ROUTINE: {
            // og table addr. 0x8018BF20
            // vanilla
            constant NSP_SHOOT(0x80138D24)      // used by Mario, Fox, Samus etc.
            constant NONE(0x80138ECC)
            constant PHYSICAL_SHOOT(0x80138CD4) // LINK, boomerang if opponent within 1500.0 units
            // remix
        }

        // @ Description
        // Extends a check that is meant to exclude polygons specifically for determining behaviour when a fighter is far away
        // a0 = character ID
        scope extend_polygon_check_: {
            OS.patch_start(0xB36F8, 0x80138CB8)
            j       extend_polygon_check_
            sll     t5, a0, 2                       // OG line 2 t5 = offset in ai_long_range_table_
            _return:
            OS.patch_end()

            // at = 0 if character ID is >= POLY MARIO
            bnez    at, _normal_vanilla_character   // branch if orginal vanilla fighter
            sltiu   at, a0, Character.id.FALCO      // at = 1 if vanilla polygon
            bnez    at, _polygon_fighter            // branch if vanilla polygon fighter
            sltiu   at, a0, Character.NUM_CHARACTERS - Character.NUM_POLYGONS // at = 0 if remix polygon
            bnez    at, _normal_vanilla_character
            nop

            _polygon_fighter:
            j       0x80138ECC                      // original line 1 branch
            nop

            _normal_vanilla_character:
            j       _return
            nop
        }

        // 80138AA8 + 3F8
        scope custom_move: {
            OS.patch_start(0xB38E0, 0x80138EA0)
            j       custom_move
            or      a0, s0, r0           // original line 1: a0 = character struct
            _return:
            OS.patch_end()

            // t0, t1 are safe

            // load custom long range move to t1
            lw      t1, 0x0008(a0)          // get character ID
            sll     t1, t1, 2
            li      at, Character.nsp_shoot_custom_move.table
            addu    t1, t1, at              // t6 = entry
            lw      t1, 0x0000(t1)          // load character's entry in table

            // mimic original logic for the end of the function
            // here we're between an if and an else right at the end of the function
            bnez    t2, _else_branch_414 // original line 2
            nop

            // IF path
            beqzl   t1, _if_continue
            nop

            or      a1, r0, t1 // load custom command id

            _if_continue:
            jal     0x80132778 // ftComputerSetCommandWaitLong(a0: character struct, a1: input command id)
            nop
            j       0x80138AA8+0x418 // go to the end of the function
            addiu   v0, r0, 1  // return 1

            // ELSE path
            _else_branch_414:
            li      a1, 0xA // command id 10

            beqzl   t1, _else_branch_414_continue
            nop

            or      a1, r0, t1 // load custom command id

            _else_branch_414_continue:
            jal     0x80132778 // ftComputerSetCommandWaitLong(a0: character struct, a1: input command id)
            nop
            j       0x80138AA8+0x418 // go to the end of the function
            addiu   v0, r0, 1  // return 1
        }
    }

    // hooks at LONG_RANGE.ROUTINE.NSP_SHOOT
    // prevents pikachu from using neutral B, can be added for other characters neutral B attacks
    // scope LVL_10_skip_shoot: {
    //     OS.patch_start(0xB3764, 0x80138D24)
    //     j       LVL_10_skip_shoot
    //     nop
    //     _return:
    //     OS.patch_end();

    //     // s0 = player struct

    //     lbu     t6, 0x0013(s0)              // t6 = cpu level
    //     slti    t6, t6, 10                  // t6 = 0 if 10 or greater
    //     bnez    t6, _shoot                  // branch if not level 10
    //     lw      t6, 0x0008(s0)              // t6 = character/fighter id

    //     // if here, level 10. check character id
    //     addiu   at, r0, Character.id.PIKA   // at = pikas ID
    //     beq     at, t6, _no_shoot           // branch if pika
    //     addiu   at, r0, Character.id.EPIKA  // at = epikas ID
    //     beq     at, t6, _no_shoot           // branch if epika
    //     addiu   at, r0, Character.id.JPIKA  // at = jpikas ID
    //     beq     at, t6, _no_shoot           // branch if jpika
    //     nop

    //     b _shoot // by default, shoot as usual
    //     nop

    //     _no_shoot:
    //     j       LONG_RANGE.ROUTINE.NONE
    //     nop

    //     _shoot:
    //     lbu     t6, 0x0035(v1)          // og line 1
    //     j       _return
    //     addiu   t7, t6, 0x0001          // og line 2
    // }

    // @ Description
    // Location of vanilla cpus attack arrays
    scope ATTACK_ARRAY_ORIGIN {
        constant MARIO(0x1010C4)
        constant FOX(0x1012F4)
        constant DK(0x101524)
        constant SAMUS(0x101754)
        constant LUIGI(0x101984)
        constant LINK(0x101BB4)
        constant YOSHI(0x101DE4)
        constant CAPTAIN_FALCON(0x102014)
        constant FALCON(0x102014)
        constant CAPTAIN(0x102014)
        constant KIRBY(0x102244)
        constant PIKACHU(0x102474)
        constant JIGGLYPUFF(0x1026A4)
        constant PUFF(0x1026A4)
        constant JIGGLY(0x1026A4)
        constant NESS(0x1028D4)
    }

    // AI behavior Table
    scope ATTACK_TABLE {
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

    // @ Description
    // Location of vanilla cpus attack arrays
    macro copy_attack_behaviour(attack, attack_table_origin) {
        OS.copy_segment({attack_table_origin} + AI.ATTACK_TABLE.{attack}.OFFSET, 0x1C)
    }

    // @ Description
    // Location of vanilla cpus attack arrays
    macro add_attack_behaviour(attack_name, hitbox_start_frame, min_x, max_x, min_y, max_y) {
        if {min_x} > {max_x} {
            error "min_x range must be less than max_x range"
        }
        if {min_y} > {max_y} {
            error "min_y range must be less than max_y range"
        }

        dw AI.ATTACK_TABLE.{attack_name}.INPUT
        dw {hitbox_start_frame}
        dw 0 // hitbox end frame, unused
        float32 {min_x}
        float32 {max_x}
        float32 {min_y}
        float32 {max_y}
    }

    // @ Description
    // Location of vanilla cpus attack arrays
    macro add_custom_attack_behaviour(input_id, hitbox_start_frame, min_x, max_x, min_y, max_y) {
        if {min_x} > {max_x} {
            error "min_x range must be less than max_x range"
        }
        if {min_y} > {max_y} {
            error "min_y range must be less than max_y range"
        }
        
        dw {input_id}
        dw {hitbox_start_frame}
        dw 0 // hitbox end frame, unused
        float32 {min_x}
        float32 {max_x}
        float32 {min_y}
        float32 {max_y}
    }


    macro END_ATTACKS() {
        dw 0xFFFFFFFF, 0, 0, 0, 0, 0, 0
    }


    // @ Description
    // Custom table for AI to use to finish off opponents
    scope heavy_attack_arrays {
        mario:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.MARIO)
            copy_attack_behaviour(DSMASH, ATTACK_ARRAY_ORIGIN.MARIO)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.MARIO)
            END_ATTACKS();
            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.MARIO)
            END_ATTACKS();

        luigi:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.LUIGI)
            copy_attack_behaviour(DSMASH, ATTACK_ARRAY_ORIGIN.LUIGI)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.LUIGI)
            END_ATTACKS();

            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.LUIGI)
            END_ATTACKS();

        samus:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.SAMUS)
            copy_attack_behaviour(DSMASH, ATTACK_ARRAY_ORIGIN.SAMUS)
            copy_attack_behaviour(NSPG, ATTACK_ARRAY_ORIGIN.SAMUS)
            END_ATTACKS();

            copy_attack_behaviour(BAIR, ATTACK_ARRAY_ORIGIN.SAMUS)
            END_ATTACKS();

        dk:
            copy_attack_behaviour(NSPG, ATTACK_ARRAY_ORIGIN.DK)
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.DK)
            END_ATTACKS();

            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.DK)
            END_ATTACKS();

        kirby:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.YOSHI)
            END_ATTACKS();

            copy_attack_behaviour(NAIR, ATTACK_ARRAY_ORIGIN.YOSHI)
            END_ATTACKS();

        yoshi:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.YOSHI)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.YOSHI)
            END_ATTACKS();

            copy_attack_behaviour(UAIR, ATTACK_ARRAY_ORIGIN.YOSHI)
            END_ATTACKS();

        link:
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.LINK)
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.LINK)
            END_ATTACKS();

            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.LINK)
            END_ATTACKS();

        fox:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.FOX)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.FOX)
            END_ATTACKS();

            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.FOX)
            END_ATTACKS();

        pikachu:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.PIKACHU)
            END_ATTACKS();

            copy_attack_behaviour(BAIR, ATTACK_ARRAY_ORIGIN.PIKACHU)
            END_ATTACKS();

        captain_falcon:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.FALCON)
            copy_attack_behaviour(NSPG, ATTACK_ARRAY_ORIGIN.FALCON)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.FALCON)
            END_ATTACKS();

            copy_attack_behaviour(NSPA, ATTACK_ARRAY_ORIGIN.FALCON)
            END_ATTACKS();

        jigglypuff:
            add_attack_behaviour(DSPG, 1, -200, 200, -100, 300)
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.PUFF)
            copy_attack_behaviour(DSMASH, ATTACK_ARRAY_ORIGIN.PUFF)
            copy_attack_behaviour(USMASH, ATTACK_ARRAY_ORIGIN.PUFF)
            END_ATTACKS();

            copy_attack_behaviour(NAIR, ATTACK_ARRAY_ORIGIN.PUFF)
            add_attack_behaviour(DSPA, 1, -200, 200, -100, 300)
            END_ATTACKS();

        ness:
            copy_attack_behaviour(FSMASH, ATTACK_ARRAY_ORIGIN.NESS)
            END_ATTACKS();

            copy_attack_behaviour(NAIR, ATTACK_ARRAY_ORIGIN.NESS)
            copy_attack_behaviour(FAIR, ATTACK_ARRAY_ORIGIN.NESS)
            copy_attack_behaviour(UAIR, ATTACK_ARRAY_ORIGIN.NESS)
            END_ATTACKS();
        }

    // @ Description
    // Jumps used by character jump table at 0x801334E4
    // Used to prevent bad AI attacks
    scope PREVENT_ATTACK: {
        scope ROUTINE: {
            // vanilla
            constant NONE(0x80133520)           // default branch used by most characters
            constant MARIO(0x801334EC)          // Used by Mario Clones in vanilla (Prevents sd from USP)
            constant YOSHI_FALCON(0x80133510)   // Checks Down Special
            constant KIRBY(0x80133500)          // Checks Down Special and Up Special
            // remix
            constant SKIP_ATTACK(0x80133A14)    // debug option for us

            // @ Description
            // Prevents Falco SD with phantasm and usp
            scope FALCO_NSP: {
                // t1 = current cpu attack input
                addiu   at, r0, ATTACK_TABLE.NSPG.INPUT
                beq     t1, at, _check_dsp_aerial
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                beq     t1, at, _check_usp
                nop

                _allow_attack:
                j       0x80133520                      // jump to original routine
                nop

                _check_usp:
                j       FOX_USP                         // LVL 10 Fox USP check
                nop

                _check_dsp_aerial:
                lw      at, 0x0014C(s0)                 // get aerial flag
                beqz    at, _allow_attack               // allow attack if grounded (NSP is safe while grounded)
                nop

                _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

            }


            // @ Description
            // Prevents Bowser from doing a dangerous attack near ledge
            scope BOWSER_USP_DSP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
                beq     t1, at, _prevent_sd             // branch if doing grounded DSP
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                bne     t1, at, _allow_attack           // branch if not doing grounded USP
                nop

                _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

                _allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

            // @ Description
            // Prevents Crash from doing dsp on a fall through platform and dying on Snow Go
            scope CRASH: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
                beq     t1, at, _prevent_sd             // branch if doing grounded DSP
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT
                bne     t1, at, _allow_attack           // branch if not doing grounded USP
                nop

                // if here, check if on a soft platform
                _prevent_sd:
                lh      at, 0x00F6(s0)              // at = current clipping flag (surface id)
                andi    at, at, 0x4000              // at = second byte only
                beqz    at, _allow_attack           // skip if not a soft platform
                nop

                // if here, don't do a DSP
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

                _allow_attack:
                j   0x80133520                          // jump to original routine
                nop
            }

            // @ Description
            // Prevents Bowser from doing a dangerous attack near ledge
            scope GBOWSER: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
                beq     t1, at, _prevent_sd             // check facing direction
                nop

                _allow_attack:
                j   0x80133520                          // jump to original routine
                nop

                _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001


            }

            // @ Description
            // Prevents Wolf SD with USP
            scope USP: {
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
            // Prevents Sonic SD with his DSP
            scope SONIC_DSP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
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
            // Prevents Sonic SD with his DSP
            scope WARIO: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT
                beq     t1, at, _prevent_sd
                addiu   at, r0, 0x42        // wario nsp towards
                beq     t1, at, _prevent_sd
                addiu   at, r0, 0x43        // wario nsp towards jump
                beq     t1, at, _prevent_sd
                nop

                j   0x80133520                          // if here, jump to original routine
                nop

                _prevent_sd:
                j       0x80133520                      // jump to original routine
                addiu   t2, r0, 0x0001

            }

            // @ Description
            // Prevents Conker from using Grenade when he can't.
            scope CONKER_GRENADE: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT // 0x1B
                beq     t1, at, _check_granade_available
                nop

                addiu   at, r0, AI.ROUTINE.SMASH_DSP
                beq     t1, at, _check_granade_available
                nop

                b _allow_attack
                nop

                _check_granade_available:
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
                addiu   at, r0, ATTACK_TABLE.DSPG.INPUT // at = down special command input
                bne     t1, at, _allow_attack       // allow the attack if it is not down special
                nop
                lbu     at, 0x0013(s0)              // at = cpu level
                slti    at, at, 10                  // at = 0 if 10 or greater
                beqz    at, _lvl_10_dsp             // allow DSP if LVL 10
                nop
                _prevent_dsp:
                j       0x80133A14                  // No DSP if < LVL 10
                nop

                _lvl_10_dsp:
                lw      at, 0x01FC(s0)              // get target player object
                beqz    at, _allow_attack           // skip if no target player (somehow)
                nop
                lw      v0, 0x0084(at)              // v0 = target player struct
                lh      t6, 0x05BA(v0)              // t6 = targets tangibility flag
                addiu   at, r0, 0x0003
                beq     at, t6, _prevent_dsp        // don't try to rest if they are intangible
                lli     at, 30                      // at = 30 hp
                lw      t6, 0x002C(v0)              // t6 = target players hp%
                blt     at, t6, _prevent_dsp        // skip rest check if player is less than 30 percent
                nop

                _allow_attack:
                j   0x80133520                      // jump to original routine
                nop
            }

            // @ Description
            // Prevents 10 pikas from using neutral special.
            // scope LVL_10_PREVENT_NSP: {
            //     // t1 = current cpu attack command
            //     addiu   at, r0, ATTACK_TABLE.NSPG.INPUT // at = special command input
            //     bne     t1, at, _allow_attack       // allow the attack if it is not nsp
            //     nop
            //     lbu     at, 0x0013(s0)              // at = cpu level
            //     slti    at, at, 10                  // at = 0 if 10 or greater
            //     beqz    at, _prevent_nsp            // allow DSP if LVL 10
            //     nop
            //     _allow_attack:
            //     j       0x80133520                  // jump to original routine
            //     nop

            //     _prevent_nsp:
            //     j       0x80133A14                  // No DSP if < LVL 10
            //     nop
            // }

            // @ Description
            // Prevents 10 Fox from using up special offensively
            scope FOX_USP: {
                // t1 = current cpu attack command
                addiu   at, r0, ATTACK_TABLE.USPG.INPUT // at = up special command input
                bne     t1, at, _allow_attack       // allow the attack if it is not down special
                nop
                lbu     at, 0x0013(s0)              // at = cpu level
                slti    at, at, 10                  // at = 0 if 10 or greater
                bnez    at, _allow_attack           // allow attack if not level 10
                nop

                j       0x80133A14                  // No USP if LVL 10
                nop

                _allow_attack:
                j       0x80133520                  // jump to original routine
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
                constant DEFAULT(0x00)      // ? Used in VS and for some 1P characters
                constant LINK(0x01)         // Do nothing for a bit (1P Link)
                constant YOSHI_TEAM(0x02)   // set to 0x07
                constant KIRBY(0x03)        // set to 0x08
                constant POLYGON(0x04)      // set to 0x09
                constant MARIO_BROS(0x05)   // set to 0x03 for Luigi players
                constant GIANT_DK(0x06)     // set to 0x00
                constant UNKNOWN_1(0x07)    // set to 0x02
                constant RTTF(0x08)         // set to 0x0D
                constant ALLY(0x09)         // set to 0x03
                constant TRAINING(0x0A)     // No override
            }
        }

        // @ Description
        // Second, read byte 0x03 and sets byte 0x01
        // Sets the main behaviour subroutine
        scope SET: {
            constant MAIN(0x8013A4AC)
            constant TABLE(0x8018BFAC)

            scope STATE: {
                constant DEFAULT(0x00)      // 0x0C = 0x80137778, 0x01 = 0x02
                constant UNKNOWN_1(0x01)    // 0x0C = 0x80137778, 0x01 = 0x03
                constant UNKNOWN_2(0x02)    // 0x0C = 0x80137778, 0x01 = 0x08
                constant ALLY(0x03)         // 0x0C = 0x80137778, 0x01 = 0x09
                constant FALCON(0x04)       // 0x0C = 0x80137778, 0x01 = 0x0A
                constant YOSHI_TEAM(0x07)   // 0x0C = 0x80137778, 0x01 = 0x09
                constant KIRBY_TEAM(0x08)   // 0x0C = 0x80137778, 0x01 = 0x0A
                constant POLYGON(0x09)      // 0x0C = 0x80137778, 0x01 = 0x02
                //constant UNUSED_1(0x0A)       // nothing
                //constant UNUSED_2(0x0B)       // nothing
                //constant UNUSED_3(0x0C)       // nothing
                constant RTTF(0x0D)         // 0x0C = 0x80137778, 0x01 = 0x0B
                //constant UNUSED_4(0x0E)       // nothing
                constant STAND(0x0F)        // 0x0C = 0x80137A18
                constant WALK(0x10)         // 0x0C = 0x80137AA4
                constant EVADE(0x11)        // 0x0C = 0x80137C7C
                constant JUMP(0x12)         // 0x0C = 0x80137CD8
                constant UNKNOWN_3(0x13)    // 0x0C = 0x80137E70
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
                    constant MAIN(0x80132BC8)       // Returns 1 to change state to EVADE
                    scope PLAYERS: {
                        constant OBJ_PTR(0x800466FC)

                        // 0x80132BF8 - Skip to end if no players found

                        // 0x80132C00 - Load these floats in case cpu wants to run away from them
                        scope evade_area: {
                            constant address(0x8018BB90)
                            constant x_tolerance(2500.0)
                            constant y_tolerance(1500.0)
                            constant multiplier(3.0)    // magic
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
                            constant unknown_1(9.0) // f28 magic # 0x80135C38
                            constant distance(15.0) // f26 magic # 0x80135C40
                            constant unknown_2(0.5) // f24 magic # 0x80135C48
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
                            constant unknown_1(9.0) // f28 magic # 0x80135EE4
                            constant distance(15.0)// f26 magic # 0x80135ED4
                            constant unknown_2(0.5) // f24 magic # 0x80135C38
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
                    constant NOTHING(0x0)       // do nothing
                    constant MOVE(0x01)         // move to a position
                    constant ATTACK(0x02)       // attack a position
                    constant EVADE(0x03)        // runs away from player
                    constant RECOVER(0x04)      // recover to stage
                    constant UNKNOWN_1(0x05)    // ? JAL 0x80138104,    Chad walks over and jabs you
                    constant ITEM_HAVE(0x06)    // If they have an item in hand 0x8013815C
                    constant SHIELD(0x07)       // ? JAL 0x80137FD4,    shields on and off constantly
                    constant UNKNOWN_4(0x08)    // ? JAL 0x801397F4
                    constant YOSHI_TEAM(0x09)   // JAL 0x80139A60
                    constant UNKNOWN_5(0x0A)    // ? JAL 0x80139D6C
                    constant RTTF(0x0B)         // JAL 0x8013A298
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
    // General LVL 10 AI hooks
    scope level_ten: {
        // 80132EC8+274
        // This allows us to have a unique attack table for lv10 CPUs. Could be expanded to other unique tables too.
        // This is where it loads the entry in the table, so we can override the value or keep the original.
        // The current goal here is to have custom attack config tables for Vanilla characters.
        scope custom_attacks_table: {
            OS.patch_start(0xADB7C, 0x8013313C)
            j custom_attacks_table
            // not editing line 2 because it collides with other patch
            _return:
            OS.patch_end()

            // Check CPU level
            lbu t9, 0x13(s0) // t9 = cpu level
            addiu t9, t9, -10 // t9 = 0 if level 10
            bnezl t9, _original // if not lv10, skip
            nop

            // check for entries in the lv10_ai_behaviour table
            lw t9, 8(s0) // t9 = character id
            sll t0, t9, 2 // 
            li at, Character.lv10_ai_behaviour.table
            addu t0, t0, at // t0 = entry
            lw at, 0x0000(t0) // at = characters entry in jump table
            beqz at, _original // skip if no entry
            nop
            or s2, r0, at // use address from custom table

            _original:
            beqz t7, _j_2A0 // original line 1: this is for a grounded/aerial check on the following lines
            nop

            _end:
            j _return+0x4
            nop            

            _j_2A0:
            j 0x80132EC8+0x2A0
            nop
        }

        // @ Description
        // Hook where jab subroutine checks if player has input a grab during frame 1-2 of jab
        scope auto_jab_grab_: {
            OS.patch_start(0xC48BC, 0x80149E7C)
            j       auto_jab_grab_
            lb      t7, 0x0023(a0)                  // t7 = player type (0 = player, 1 = CPU)
            OS.patch_end()

            beqz    t7, _normal                     // branch if player type = player
            lb      t7, 0x0013(a0)                  // t7 = cpu level
            slti    t7, t7, 10                      // t7 = 0 if level 10 or above
            bnez    t7, _normal
            nop

            // level 10
            lw      t7, 0x001C(a0)                  // t7 = current frame
            slti    t7, t7, 3                       // t7 = 0 if 3 or greater

            bnez    t7, _normal
            nop

            li      t7, Toggles.entry_single_button_mode
            lw      t7, 0x0004(t7)                  // t7 = single_button_mode (0 if OFF, 1 if 'A', 2 if 'B', 3 if 'R', 4 if 'A+C', 5 if 'B+C', 6 if 'R+C')
            beqz    t7, _auto_grab                  // branch if Single Button Mode is disabled
            sltiu   t1, t7, 4                       // t1 = 0 if including 'C' button
            beqzl   t1, pc() + 8                    // if so, subtract 3 to get corresponding main button value
            addiu   t7, t7, -3                      // ~
            addiu   t1, r0, 0x0003                  // t1 = 3 ('R')
            bne     t1, t7, _normal                 // don't have CPU auto grab if Single Button Mode 'A' or 'B'
            nop

            _auto_grab:

            // if here, auto grab
            j       0x80149E84                      // polygon check, then grab if not a polygon
            nop

            _normal:
            // a0 = player struct
            beqz    t9, _original_end               // modified original line 1
            nop

            j       0x80149E88
            lw      t1, 0x0100(t0)                  // do normal routine

            _original_end:
            j           0x80149EA8                  // jump to end of grab interrupt
            lw          ra, 0x0014(sp)              // load ra

        }

        // Run away from opponents who are coming off the respawn plat
        // However, vanilla AI doesn't seem too great at evading.
        scope check_invulnerable_: {
            OS.patch_start(0xAD6C4, 0x80132C84)
            j       check_invulnerable_
            lw      t9, 0x05B4(s0)              // original line 1, get player invuln flag
            OS.patch_end()

            beq     s3, t9, _avoid_player
            lbu     t9, 0x0013(a0)              // t6 = cpu level
            slti    t9, t9, 10                  // t9 = 0 if 10 or greater
            bnez    t9, _normal                 // do normal logic if not LVL 10
            lw      t9, 0x05A4(s0)              // get invulnerability timer

            beqz    t9, _normal                 // proceed as normal if not invulnerable
            nop

            _avoid_player:
            j       0x80132C90
            nop

            _normal:
            j       0x80132CAC
            lw      v0, 0x084C(s0)              // original branch line 2

        }

        // @ Description
        // Allows for additional ways to get up a cliff
        scope extend_cliff_attack_: {
            OS.patch_start(0xB1844, 0x80136E04)
            j       extend_cliff_attack_
            lbu     t9, 0x0013(a0)              // t6 = cpu level
            OS.patch_end()

            slti    t9, t9, 10                  // t9 = 0 if 10 or greater
            bnez    t9, _set_input              // do normal logic if not LVL 10
            addiu   a1, r0, 0x0004              // a1 = default input (normal getup)

            // if here, choose to attack normally or to jump
            jal     Global.get_random_int_      // v0 = (random value)
            lli     a0, 0x2                     // a0 = 2
            lw      a0, 0x004C(sp)              // restore a0
            srl     v0, v0, 1                   // v0 = v0 >> 1
            beqzl   v0, _set_input
            addiu   a1, r0, AI.ROUTINE.CLIFF_LET_GO // a1 = custom input

            _set_input:
            jal     0x80132564                  // set cpus input
            nop
            j       0x80137768                  // goto rest of routine.
            or      v0, r0, r0
        }

        // @ Description
        // Instead of taunting, do something else or nothing
        scope taunt_replace_: {
            OS.patch_start(0xB2194, 0x80137754)
            j       taunt_replace_
            lbu     t6, 0x0013(a0)              // t6 = cpu level
            OS.patch_end()

            slti    at, t6, 10                  // at = 0 if 10 or greater
            bnez    at, _set_input
            addiu   a1, r0, AI.ROUTINE.TAUNT       // do taunt


            // level_10:
            lw      t6, 0x0008(a0)              // t6 = current character id
            addiu   at, r0, Character.id.NESS
            beq     at, t6, _pk_thunder         // branch if NESS
            addiu   at, r0, Character.id.LUCAS
            beq     at, t6, _pk_thunder         // branch if LUCAS
            addiu   at, r0, Character.id.JNESS
            bne     at, t6, _no_input           // branch if not JNESS
            nop

            _pk_thunder:
            // Adding these temporary lines to prevent SD related to PK Thunder
            b       _no_input                   // temporary line 1
            nop                                 // temporary line 2
            b       _set_input
            addiu   a1, r0, AI.ROUTINE.USP         // For Ness clones and Lucas

            _set_input:
            // a1 = command to take
            jal     0x80132564          // execute AI command. original line 1
            nop
            _no_input:
            j       0x80137768          // original branch
            or      v0, r0, r0          // original branch line 2

        }

        // ftComputerProcessAll 8013A834+50
        // This runs after ftComputerProcessTrait, ftComputerProcessBehavior, ftComputerProcessObjective
        // and before ftComputerUpdateInputs
        // which is all updates the CPU has in a frame
        // This patch lets us add one more routine to the CPU processing
        scope cpu_post_process: {
            OS.patch_start(0xB52C4, 0x8013A884)
            j cpu_post_process
            nop
            _return:
            OS.patch_end()

            jal 0x8013A38C
            or a0, s0, s0 // a0 = player struct

            // Make it so CPUs mash the start button when dead to respawn on team battles
            scope _check_respawn: {
                Toggles.read(entry_improved_ai, t0)
                beqz t0, _end // skip if not enabled
                nop

                lw t0, 0x0024(s0) // t0 = current action

                // check if dead: state = 4 (nFTCommonStatusSleep)
                addiu t1, r0, 4 // t1 = 4
                bne t0, t1, _end // branch if not dead
                nop

                // spam the start button to respawn
                li t5, Global.current_screen_frame_count // ~
                lw t5, 0x0000(t5) // t5 = global frame count
                andi t5, t5, 0x0010 // every 16 frames
                beqz t5, _start_mash_release
                lh at, 0x01C6(s0) // at = buttons pressed
                _start_mash_press:
                b _dsp_mash_apply
                ori at, at, Joypad.START // press START
                _start_mash_release:
                andi at, at, 0x0000 // release all buttons
                _dsp_mash_apply:
                sh at, 0x01C6(s0) // save button press mask

                _end:
            }

            // if set to dash attack but can't initiate a dash, cancel the action
            scope _check_if_dash_attack_input_is_possible: {
                lw t0, 0x1D4(s0) // t0 = ft_com->p_command
                li t1, AI.command_table // load command table base address

                lw at, AI.ROUTINE.DASH_ATTACK << 2(t1)
                beq t0, at, _dash_attacking
                nop
                b _end // exit if not going for dash attack
                nop

                _dash_attacking:
                lw t0, 0x24(s0) // t0 = current action
                addiu t1, r0, Action.Idle
                beq t0, t1, _end // can dash attack from this state
                addiu t1, r0, Action.Run
                beq t0, t1, _end // can dash attack from this state
                nop

                _cannot_dash_attack:
                jal 0x80132758 // execute AI command
                lli a1, AI.ROUTINE.NULL // cancel action

                _end:
            }

            // if set to usp or upsmash while dashing/running, do a jump-cancelled up special or up smash
            scope _dash_usmash_usp: {
                lbu at, 0x0013(s0) // at = cpu level
                slti at, at, 10 // at = 0 if 10 or greater
                bnez at, _end // skip if not lv10
                nop
                
                lw t0, 0x24(s0) // t0 = current action
                addiu t1, r0, Action.Dash // t1 = dash action
                beq t0, t1, check_command
                addiu t1, r0, Action.Run // t1 = run action
                beq t0, t1, check_command
                nop
                bne t0, t1, _end // exit if not dashing or running
                nop

                check_command:
                lw t0, 0x1D4(s0) // t0 = ft_com->p_command
                li t1, AI.command_table // load command table base address

                lw at, AI.ATTACK_TABLE.USMASH.INPUT << 2(t1)
                beq t0, at, _dash_upsmash
                lw at, AI.ATTACK_TABLE.USPG.INPUT << 2(t1)
                beq t0, at, _dash_usp
                nop
                b _end // exit if not using upsmash or usp
                nop

                _dash_upsmash:
                jal 0x80132758 // execute AI command
                lli a1, AI.ROUTINE.JUMPCANCEL_UPSMASH // arg1
                b _end
                nop

                _dash_usp:
                jal 0x80132758 // execute AI command
                lli a1, AI.ROUTINE.JUMPCANCEL_USP // arg1

                _end:
            }

            scope _custom_usp_command: {
                // if using USPA while offstage, change to USP_TOWARDS
                lbu at, 0x0013(s0) // at = cpu level
                slti at, at, 10 // at = 0 if 10 or greater
                bnez at, _end // skip if not lv10
                nop
                
                check_command:
                lw t0, 0x1D4(s0) // t0 = ft_com->p_command
                li t1, AI.command_table // load command table base address

                lw at, AI.ATTACK_TABLE.USPA.INPUT << 2(t1)
                beq t0, at, _custom_usp
                nop
                b _end // exit if not using upsmash or usp
                nop

                _custom_usp:
                jal 0x80132758 // execute AI command
                lli a1, AI.ROUTINE.USP_TOWARDS // arg1
                b _end
                nop

                _end:
            }

            // Check for a post process function for this character ID
            scope _post_process_function: {
                // check for entries in the cpu_post_process table
                lw t9, 8(s0) // t9 = character id
                sll t0, t9, 2 // 
                li at, Character.cpu_post_process.table
                addu t0, t0, at // t0 = entry
                lw at, 0x0000(t0) // at = characters entry in jump table

                beqz at, _end // skip if no entry
                nop

                jalr at // jump to custom routine
                or a0, s0, s0 // a0 = player struct

                _end:
            }

            _end:
            j _return
            nop
        }

        // ftComputerProcessTrait 8013A63C+DC
        // Here, from time to time the game does rand(3) and sets behavior to either default, unk2, ally, captain
        // lv10 forces the result to 0 (default) so the objective keeps being "attack"
        scope force_objective_attack: {
            OS.patch_start(0xB5158, 0x8013A718)
            j force_objective_attack
            sh t9,0x14(v1) // original line 2
            _return:
            OS.patch_end()

            lbu at, 0x0013(a0) // at = cpu level
            slti at, at, 10 // at = 0 if 10 or greater
            bnez at, _vanilla // branch if not lv10
            nop

            // level 10
            or v0, r0, r0 // force 0
            b _end
            nop

            _vanilla:
            jal 0x80018910 // original line 1: get random short
            nop
        
            _end:
            j _return
            nop
        }

        // // ftComputerProcessAll 8013A834+10
        // // This spawns a GFX in the position of the CPU target
        // // useful to debugging. Keep commented.
        // scope debug_target_pos: {
        //     // spawn GFX to represent where the target is located
        //     OS.patch_start(0xB5284, 0x8013A844)
        //     j debug_target_pos
        //     nop
        //     _return:
        //     OS.patch_end()

        //     // a0 = player object
        //     // s0 = player struct

        //     addiu   t0, s0, 0x1cc // t0 = ftcomputer struct

        //     addiu   sp, sp, -0x30   // allocate memory
        //     sw      ra, 0x4(sp)
        //     sw      a0, 0x8(sp)
        //     sw      s0, 0xC(sp)     // save registers

        //     // generate sparkle particle at CPU target position
        //     addiu   sp, sp, -0x30     // allocate memory

        //     // create vec3 at 0x18 with the left ledge pos
        //     _left_ledge:
        //     addiu   t0, s0, 0x1cc // t0 = ftcomputer struct

        //     lw      t1, 0x4C(t0) // left ledge x
        //     sw      t1, 0x18(sp) // vec x
        //     lw      t1, 0x50(t0) // left ledge y
        //     sw      t1, 0x1c(sp) // vec y
        //     or      t1, r0, r0
        //     sw      t1, 0x20(sp) // vec z

        //     addiu   a0, sp, 0x18    // arg0 = vec3 we created

        //     jal     0x80101688      // efManagerFlashSmallMakeEffect(Vec3f *pos)
        //     nop

        //     // create vec3 at 0x18 with the right ledge pos
        //     _right_ledge:
        //     addiu   t0, s0, 0x1cc // t0 = ftcomputer struct

        //     lw      t1, 0x54(t0) // right ledge x
        //     sw      t1, 0x18(sp) // vec x
        //     lw      t1, 0x58(t0) // right ledge y
        //     sw      t1, 0x1c(sp) // vec y
        //     or      t1, r0, r0
        //     sw      t1, 0x20(sp) // vec z

        //     addiu   a0, sp, 0x18    // arg0 = vec3 we created

        //     jal     0x80101688      // efManagerFlashSmallMakeEffect(Vec3f *pos)
        //     nop

        //     // create vec3 at 0x18 with the target pos
        //     _target:
        //     addiu   t0, s0, 0x1cc // t0 = ftcomputer struct
        //     lw      t1, 0x60(t0) // target x
        //     sw      t1, 0x18(sp) // vec x
        //     lw      t1, 0x64(t0) // target y
        //     sw      t1, 0x1c(sp) // vec y
        //     or      t1, r0, r0
        //     sw      t1, 0x20(sp) // vec z

        //     addiu   a0, sp, 0x18    // arg0 = vec3 we created

        //     jal     0x801015D4      // efManagerFuraSparkleMakeEffect(Vec3f *pos)
        //     nop

        //     addiu   sp, sp, 0x30 // deallocate memory

        //     lw      ra, 0x4(sp)
        //     lw      a0, 0x8(sp)
        //     lw      s0, 0xC(sp)    // load registers
        //     addiu   sp, sp, 0x30   // deallocate memory

        //     lli     at, 0xC // original line 1
        //     lw      t6, 8(s0) // original line 2

        //     j   _return
        //     nop
        // }

        // 80134000+58
        // ftComputerCheckSetTargetEdgeRight
        // here when the CPU has positive Y speed (going up) it sets the target to itself + a value in X
        // which makes it just drift to this direction for no apparent reason
        scope _fix_weird_air_drift_right: {
            OS.patch_start(0xAEA98, 0x80134058)
            j _fix_weird_air_drift_right
            addiu s4,s2,0x1cc // original line 1
            _return:
            OS.patch_end()

            // a0 = fighter struct

            // Check CPU level
            lbu     t1, 0x0013(a0)           // t1 = cpu level
            addiu   t1, t1, -10              // t1 = 0 if level 10
            bnezl   t1, _original            // if not lv10, skip
            nop

            lui at,0x3f40 // original line 2
            j 0x80134000+0x98 // skip code block
            addiu s3, s3, 0x50E8 // original line 3

            _original:
            j _return
            lui at,0x3f40 // original line 2
        }

        // read comment for the above patch
        // 80134368+58
        scope _fix_weird_air_drift_left: {
            OS.patch_start(0xAEE00, 0x801343C0)
            j _fix_weird_air_drift_left
            addiu s4,s2,0x1cc // original line 1
            _return:
            OS.patch_end()

            // a0 = fighter struct

            // Check CPU level
            lbu     t1, 0x0013(a0)           // t1 = cpu level
            addiu   t1, t1, -10              // t1 = 0 if level 10
            bnezl   t1, _original            // if not lv10, skip
            nop

            lui at,0x3f40 // original line 2
            j 0x80134368+0x98 // skip code block
            addiu s3, s3, 0x50E8 // original line 3

            _original:
            j _return
            lui at,0x3f40 // original line 2
        }

        scope improved_recovery: {
            // a0 = x
            // a1 = y
            // a2 = direction to check: -1 1 (Left/Right)
            // returns
            // v0 = 0 if no ledge found or pointer to vec2 ledge pos
            // v1 = is grabbable, will be 0 if someone is already on the ledge
            scope _find_closest_ledge: {
                OS.routine_begin(0x50)

                constant BLASTZONE_PADDING(0x4348) // 200.0

                define pos_x(0x18(sp))
                define pos_y(0x1C(sp))
                define direction(0x20(sp))
                define min_dist(0x24(sp))
                define edge_pos_x(0x28(sp))
                define edge_pos_y(0x2C(sp))
                define is_grabbable(0x30(sp))

                sw a0, {pos_x}
                sw a1, {pos_y}
                sw a2, {direction}

                li at, 0x7F7FFFFF
                sw at, {min_dist} // min_dist = max float value

                sw r0, {edge_pos_x} // edge_pos.x = 0
                sw r0, {edge_pos_y} // edge_pos.y = 0

                li s3, 0x80131348 // s3 = gMapLineTypeGroups
                lw v0, 0x0004(s3) // v0 = &gMapLineTypeGroups[mpCollision_LineType_Ground].line_id[0];

                lhu     t6, 0(s3)
                blez    t6, _loop_end // if no lines, skip loop
                or      s1, r0, r0 // i = 0
                or      s0, r0, v0 // s0 = line reference = first line id
                addiu   s2, sp, 0x40 // s2 = location to store reference for edge_pos

                scope _loop: { // loop inner logic
                    jal     0x800FC67C // mpCollision_CheckExistLineID(line_ids[i])
                    lhu     a0, 0(s0)
                    beqz    v0, _next_iter // if line id doesn't exist, skip
                    or      a1, r0, s2

                    lw      at, {direction} // at = direction
                    blez    at, _direction_right // if direction >= 0, go left
                    nop

                    _direction_left:
                    jal     0x800F4428 // mpCollisionGetFloorEdgeL(s32 line_id, Vec3f *object_pos)
                    lhu     a0, 0(s0)
                    b       _direction_end
                    nop

                    _direction_right:
                    jal     0x800F4448 // mpCollisionGetFloorEdgeR(s32 line_id, Vec3f *object_pos)
                    lhu     a0, 0(s0)

                    _direction_end:
                    // here s2 = edge_pos(x, y)
                    // calculate distance to arguments
                    lwc1    f0, {pos_x}
                    lwc1    f2, {pos_y}

                    lwc1    f4, 0x0(s2) // edge_pos.x
                    lwc1    f6, 0x4(s2) // edge_pos.y

                    // if ledge is off-screen, skip this ledge
                    _bounds_check: {
                        lui t0, BLASTZONE_PADDING
                        mtc1 t0, f10 // f10 = BLASTZONE_PADDING

                        li t0, 0x80131300 // base for blastzone positions
                        lw t0, 0x0(t0)

                        _top_blastzone:
                        lh t1, 0x0074(t0) // top blastzone
                        mtc1 t1, f8
                        cvt.s.w f8, f8 // f8 = top blastzone (float)
                        sub.s f8, f8, f10 // f8 = top blastzone - PADDING
                        c.le.s f8, f6 // code = 1 if top blastzone <= edge Y
                        nop
                        bc1t _next_iter // if edge pos.y >= blastzone.top, then skip this ledge
                        nop

                        _bottom_blastzone:
                        lh t1, 0x0076(t0) // bottom blastzone
                        mtc1 t1, f8
                        cvt.s.w f8, f8 // f8 = bottom blastzone (float)
                        add.s f8, f8, f10 // f8 = bottom blastzone + PADDING
                        c.le.s f6, f8 // code = 1 if edge Y <= bottom blastzone
                        nop
                        bc1t _next_iter // if edge pos.y <= blastzone.bottom, then skip this ledge
                        nop

                        _left_blastzone:
                        lh t1, 0x007A(t0) // left blastzone
                        mtc1 t1, f8
                        cvt.s.w f8, f8 // f8 = left blastzone (float)
                        add.s f8, f8, f10 // f8 = left blastzone + PADDING
                        c.le.s f8, f4 // code = 1 if left blastzone <= edge X
                        nop
                        bc1f _next_iter // if edge X < left blastzone, skip this ledge
                        nop

                        _right_blastzone:
                        lh t1, 0x0078(t0) // right blastzone
                        mtc1 t1, f8
                        cvt.s.w f8, f8 // f8 = right blastzone (float)
                        sub.s f8, f8, f10 // f8 = right blastzone - PADDING
                        c.le.s f4, f8 // code = 1 if edge X <= right blastzone
                        nop
                        bc1f _next_iter // if edge X > right blastzone, skip this ledge
                        nop
                    }

                    // check if there's ground below this ledge
                    // if so, skip it
                    _check_ground_below: {
                        addiu sp, sp, -0x20

                        // create a vec3 at 0x4(sp)
                        // make it just below ledge pos
                        swc1 f4, 0x4(sp) // x
                        
                        lui at, 0x4248 // at = 50.0
                        mtc1 at, f20 // f20 = 50.0
                        sub.s f20, f6, f20 // f20 = ledge.y - 50.0
                        swc1 f20, 0x8(sp) // y

                        sw r0, 0xC(sp) // z

                        jal 0x800F8FFC // func_ovl2_800F8FFC(Vec3f *position) (check if there's ground below)
                        addiu a0, sp, 0x4 // a0 = ledge pos vec3

                        addiu sp, sp, 0x20
                        lwc1 f0, {pos_x} // restore pos_x
                        lwc1 f2, {pos_y} // restore pos_y
                        lwc1 f4, 0x0(s2) // restore edge_pos.x
                        lwc1 f6, 0x4(s2) // restore edge_pos.y
                        bnez v0, _next_iter // if v0 != 0, there's ground below
                        nop
                    }

                    sub.s f8, f0, f4 // f8 = x distance
                    sub.s f10, f2, f6 // f10 = y distance

                    // Here, if player y < ledge y we make the distance seem greater than it actually is
                    // so that the CPU prefers going to lower ledges
                    c.lt.s f2, f6 // if player_y < edge_y
                    nop
                    bc1fl   _continue // if player Y is higher than edge, continue
                    nop

                    // If here, edge Y is higher than player. Make the distance seem bigger
                    lui t0, 0x3FC0         // t0 = 1.5
                    mtc1 t0, f14            // f14 = 1.5
                    mul.s f10, f10, f14      // f10 = f10 * 1.5 (multiply Y distance by 1.5)

                    _continue:
                    mul.s   f12, f8, f8            // f12 = (x distance)^2
                    mul.s   f14, f10, f10          // f14 = (y distance)^2
                    add.s   f12, f12, f14          // f12 = (x distance)^2 + (y distance)^2
                    sqrt.s  f12, f12               // f12 = sqrt((x distance)^2 + (y distance)^2)
                    lwc1    f16, {min_dist}        // f16 = current minimum distance
                    c.lt.s  f12, f16               // check if new distance is less than current minimum
                    nop
                    bc1f    _next_iter             // if not, skip updating minimum distance
                    nop
                    swc1    f12, {min_dist} // save new minimum distance

                    // save new edge_pos
                    swc1    f4, {edge_pos_x} // edge_pos.x
                    swc1    f6, {edge_pos_y} // edge_pos.y

                    // check if edge is grabbable
                    scope _grabbable_check: {
                        jal     Surface.get_clipping_flag_ // return clipping flag in v0
                        or      a0, r0, s1 // argument = line id

                        andi v0, v0, 0x8000 // MAP_FLAG_FLOOREDGE
                        // set is_grabbable to 1 if v0 is not 0
                        sw r0, {is_grabbable} // set is_grabbable to 0
                        beqz    v0, _end // if v0 is 0, skip
                        lli at, 1 // at = 1
                        sw at, {is_grabbable} // set is_grabbable to 1

                        _end:
                    }

                    // if the ledge is grabbable, check if someone is already on it
                    scope _ledge_grabbed_check: {
                        lw      t0, {is_grabbable} // t0 = is_grabbable
                        beqz    t0, _end // if not grabbable, skip
                        nop

                        lw     a1, {direction} // a1 = direction
                        jal    is_ledge_grabbed // check if someone is on the ledge
                        or     a0, r0, s1 // argument = line id

                        beqz   v0, _end // if no one is on the ledge, skip
                        nop

                        // if here, someone is on our ledge
                        // set is_grabbable to 0
                        sw r0, {is_grabbable} // set is_grabbable to 0

                        _end:
                    }

                    _next_iter: // prepare for next iteration
                    lhu     t7, 0(s3)
                    addiu   s1, s1, 1
                    addiu   s0, s0, 2
                    slt     at, s1, t7
                    bnez    at, _loop
                    nop
                }
                _loop_end: // end of loop

                // v0 should be the address of edge_pos_x
                addiu v0, sp, 0x28 // v0 = edge_pos_x

                lw v1, {is_grabbable} // v1 = is_grabbable

                OS.routine_end(0x50)
            }

            // Checks if someone is already on the ledge
            // a0 = ledge id
            // a1 = direction (-1/1)
            // returns v0 = 0 if no one is on the ledge, 1 if someone is on the ledge
            scope is_ledge_grabbed: {
                OS.routine_begin(0x20)

                or v0, r0, r0 // v0 = 0

                OS.read_word(Global.p_struct_head, at) // at = p1 player struct
                _loop:
                lw t0, 0x0004(at) // t0 = player object
                beqz t0, _next // if no player object, get next player struct
                nop

                // The other player must be grabbing a ledge,
                // facing our ledge direction,
                // and grabbing our ledge id
                lbu t0, 0x190(at) // t0 = fp->is_cliff_hold
                andi t0, t0, 0x1 // bitwise operation to get is_cliff_hold flag
                beqz t0, _next // if not holding a ledge, skip
                nop

                lw t0, 0x44(at) // t0 = player facing direction
                bne t0, a1, _next // if not facing our ledge's direction, skip
                nop

                lw t0, 0x140(at) // t0 = clipping id of ledge being grabbed
                bne t0, a0, _next // if player is not grabbing our ledge, skip
                nop

                // if here, player is grabbing our ledge
                // return 1
                lli v0, 0x1
                b _end
                nop

                _next:
                lw      at, 0x0000(at)              // at = next player struct
                bnez    at, _loop                   // loop while there are more players to check
                nop

                _end:
                OS.routine_end(0x20)
            }

            // This patch improves the CPU's drift when recovering.
            // It separates by situation (above ledge, under ledge, facing ledge, not facing ledge).
            // Takes the character's ledge grab range in consideration.
            // Also makes them less prone to getting pineappled.
            // 80134E98 + 568
            scope _improve_recovery_drift: {
                OS.patch_start(0xAFE40, 0x80135400)
                j _improve_recovery_drift
                nop
                _return:
                OS.patch_end()

                // a0 = fighter struct

                // Check CPU level
                lbu     t1, 0x0013(a0)           // t1 = cpu level
                addiu   t1, t1, -10              // t1 = 0 if level 10
                bnezl   t1, _original            // if not lv10, skip
                nop

                // if in special fall, we always go for the recovery logic
                lw      t0, 0x0024(a0) // get current action
                lli     t1, Action.FallSpecial
                beq     t0, t1, _improved_logic
                nop

                // if all jumps used, also go for recovery logic
                // a lot of times when USP is used the player loses all jumps
                // so this helps them start looking for a place to land sooner
                lw      t0, 0x9C8(a0)   // t0 = attribute pointer
                lw      t0, 0x064(t0)   // t0 = max jumps
                lb      t1, 0x148(a0)   // jumps used
                bge     t1, t0, _improved_logic
                nop

                // t0 = cpu struct
                addiu   t0, s0, 0x1cc // t0 = ftcomputer struct
                // check if current behavior == nFTComputerObjectiveRecover
                lbu     t2, 0(t0) // current behavior
                lli     t1, 0x4 // nFTComputerObjectiveRecover
                bnel    t1, t2, _original // not recovering, skip
                nop

                // padding added in X towards the center of the stage
                constant LEDGE_PADDING(0x4396) // 300.0 - padding in X applied when not looking at ledge

                lw      t0, 0xEC(a0)    // t0 = clipping id cpu is above (0xFFFF if none)
                addiu   at, r0, 0xFFFF
                bne     at, t0, _original
                nop

                constant gMapEdgeBounds(0x80131308)

                _improved_logic:
                addiu   sp, sp, -0x30

                define recovery_direction_int(0x4(sp))
                define ledge_grabbable_left(0x8(sp))
                define ledge_grabbable_right(0xC(sp))
                define ledge_grabbable(0x10(sp))

                // a0 = fighter struct

                // update ledge positions
                _update_left_ledge_pos: {
                    addiu sp, sp, -0x30 // allocate memory
                    sw a0, 0x8(sp) // save a0
                    sw a1, 0xC(sp) // save a1
                    sw a2, 0x10(sp) // save a2
                    sw s0, 0x14(sp) // save s0
                    sw s1, 0x18(sp) // save s1
                    sw s2, 0x1C(sp) // save s2
                    sw s3, 0x20(sp) // save s3
                    // load player pos
                    lw      t0, 0x78(a0) // load location vector
                    lw      a0, 0x0(t0) // a0 = location X
                    lw      a1, 0x4(t0) // a1 = location Y
                    jal     _find_closest_ledge
                    lli     a2, 0x1 // a2 = direction
                    // restore variables
                    lw      a0, 0x8(sp) // restore a0
                    lw      a1, 0xC(sp) // restore a1
                    lw      a2, 0x10(sp) // restore a2
                    lw      s0, 0x14(sp) // restore s0
                    lw      s1, 0x18(sp) // restore s1
                    lw      s2, 0x1C(sp) // restore s2
                    lw      s3, 0x20(sp) // restore s3
                    addiu   sp, sp, 0x30 // deallocate memory
                    // set left ledge pos
                    lw at, 0x0(v0) // at = left ledge pos x
                    sw at, 0x01CC+0x4c(a0) // save nearest LEFT ledge X
                    lw at, 0x4(v0) // at = left ledge pos y
                    sw at, 0x01CC+0x50(a0) // save nearest LEFT ledge Y
                    sw v1, {ledge_grabbable_left} // save ledge grabbable
                }

                _update_right_ledge_pos: {
                    // update right ledge positions
                    addiu sp, sp, -0x30 // allocate memory
                    sw a0, 0x8(sp) // save a0
                    sw a1, 0xC(sp) // save a1
                    sw a2, 0x10(sp) // save a2
                    sw s0, 0x14(sp) // save s0
                    sw s1, 0x18(sp) // save s1
                    sw s2, 0x1C(sp) // save s2
                    sw s3, 0x20(sp) // save s3
                    // load player pos
                    lw      t0, 0x78(a0) // load location vector
                    lw      a0, 0x0(t0) // a0 = location X
                    lw      a1, 0x4(t0) // a1 = location Y
                    jal     _find_closest_ledge
                    addiu   a2, r0, -1 // a2 = direction
                    // restore variables
                    lw      a0, 0x8(sp) // restore a0
                    lw      a1, 0xC(sp) // restore a1
                    lw      a2, 0x10(sp) // restore a2
                    lw      s0, 0x14(sp) // restore s0
                    lw      s1, 0x18(sp) // restore s1
                    lw      s2, 0x1C(sp) // restore s2
                    lw      s3, 0x20(sp) // restore s3
                    addiu   sp, sp, 0x30 // deallocate memory
                    // set left ledge pos
                    lw at, 0x0(v0) // at = left ledge pos x
                    sw at, 0x01CC+0x54(a0) // save nearest RIGHT ledge X
                    lw at, 0x4(v0) // at = left ledge pos y
                    sw at, 0x01CC+0x58(a0) // save nearest RIGHT ledge Y
                    sw v1, {ledge_grabbable_right} // save ledge grabbable
                }

                _prepare:
                lw t1, 0x78(a0) // load location vector
                lwc1 f2, 0x0(t1) // f2 = location X
                lwc1 f4, 0x4(t1) // f4 = location Y

                // check if we're in a inner gap in the stage
                // in this case we can be less aggressive for the CPU to go over these gaps
                // instead of being too scared and avoiding those gaps at all costs
                _check_if_in_inner_gap:
                li t0, gMapEdgeBounds
                lwc1 f6, 0x28(t0) // f6 = gMapEdgeBounds.d2.right
                lwc1 f8, 0x2C(t0) // f8 = gMapEdgeBounds.d2.left

                c.lt.s f2, f8 // position x < left bound?
                nop
                bc1tl _continue // if true, we're offstage
                nop

                c.lt.s f6, f2 // right bound < position x?
                nop
                bc1tl _continue // if true, we're offstage
                nop

                b _inner_gap // we're inside the stage's bounds, so it's an inner gap
                nop

                _inner_gap:
                // if up special was used/is being used, we go for the recovery logic
                lb t0, 0x1CC+0x49(a0) // t0 = com->is_attempt_specialhi_recovery
                bnez t0, _continue
                nop

                // if in special fall, we go for the recovery logic
                lw      t0, 0x0024(a0) // get current action
                lli     t1, Action.FallSpecial
                beq     t0, t1, _continue
                nop

                // check if we're too high to be bothered with recovering at this point
                // location Y is in f4
                lui     at, 0x447A // constant = 1000.0
                mtc1    at, f8 // f8 = constant
                lwc1    f6, 0x01CC+0x50(a0) // nearest LEFT ledge Y
                add.s   f6, f6, f8 // f6 = ledge Y + constant
                c.lt.s  f6, f4 // ledge Y + constant < location Y
                nop
                bc1tl   _end // skip
                nop
                lwc1    f6, 0x01CC+0x58(a0) // nearest RIGHT ledge Y
                add.s   f6, f6, f8 // f6 = ledge Y + constant
                c.lt.s  f6, f4 // ledge Y + constant < location Y
                nop
                bc1tl   _end // skip
                nop

                _continue:
                // we're gonna add a constant to our X in the direction we're looking at
                // to make the CPU prefer going to a ledge it's already facing
                lui at, 0x4348 // load constant 200.0
                mtc1 at, f6 // f6 = constant

                lw at, 0x44(a0) // facing direction
                mtc1 at, f8 // f8 = facing direction (int)
                cvt.s.w f8, f8 // f8 = facing direction (float)
                mul.s f6, f6, f8 // f6 = constant * facing direction
                add.s f2, f2, f6 // location X += constant in the facing direction

                lwc1 f6, 0x01CC+0x54(a0) // nearest RIGHT ledge X
                lwc1 f8, 0x01CC+0x4c(a0) // nearest LEFT ledge X

                sub.s f10, f2, f6
                abs.s f10, f10 // f10 = abs distance in X to the left ledge

                sub.s f12, f2, f8
                abs.s f12, f12 // f12 = abs distance in X to the right ledge

                c.lt.s f10, f12 // distance to left ledge < distance to right ledge?
                nop
                bc1tl _right_ledge // if true, go for right ledge
                nop
                b _left_ledge // if false, go for left ledge
                nop

                _left_ledge:
                lwc1 f10, 0x01CC+0x4c(a0) // nearest LEFT ledge X
                swc1 f10, 0x01CC+0x60(a0) // set as target X
                lwc1 f10, 0x01CC+0x50(a0) // nearest LEFT ledge Y
                swc1 f10, 0x01CC+0x64(a0) // set as target Y

                lui at, 0xBF80 // -1.0
                mtc1 at, f10 // f10 will be used as a multiplier for direction
                li at, 1
                sw at, {recovery_direction_int}

                lw t0, {ledge_grabbable_left}
                sw t0, {ledge_grabbable} // set ledge grabbable

                b _main_logic
                nop

                _right_ledge:
                lwc1 f10, 0x01CC+0x54(a0) // nearest RIGHT ledge X
                swc1 f10, 0x01CC+0x60(a0) // set as target X
                lwc1 f10, 0x01CC+0x58(a0) // nearest RIGHT ledge Y
                swc1 f10, 0x01CC+0x64(a0) // set as target Y

                lui at, 0x3F80 // 1.0
                mtc1 at, f10 // f10 will be used as a multiplier for direction
                li at, -1
                sw at, {recovery_direction_int}

                lw t0, {ledge_grabbable_right}
                sw t0, {ledge_grabbable} // set ledge grabbable

                b _main_logic
                nop

                _main_logic:
                _check_reset_upB_flag:
                lw      t0, 0x0024(a0)          // t0 = current action

                lli     t1, Action.DamageHigh1 // First damage animation
                blt     t0, t1, pc()+(4*6) // if lower than, skip
                lli     t1, Action.DamageFlyRoll // Last damage animation
                bgt     t0, t1, pc()+(4*3) // if bigger than, skip
                nop
                sb      r0, 0x1CC+0x49(a0) // com->is_attempt_specialhi_recovery = FALSE

                // cliff catch -- reset in case the cpu releases ledge by using back
                lli     t1, Action.CliffCatch
                bne     t0, t1, pc()+(4*3) // not cliff catch, skip
                nop
                sb      r0, 0x1CC+0x49(a0) // com->is_attempt_specialhi_recovery = FALSE

                _check_above_ledge:
                lwc1 f6, 0x01CC+0x64(a0) // ledge Y
                lw t1, 0x78(a0) // load location vector
                lwc1 f8, 0x4(t1) // f8 = location Y

                _check_facing_direction: {
                    // if facing the ledge, we can consider our ledge grab Y
                    lw t0, 0x44(a0) // facing direction
                    lw t1, {recovery_direction_int}

                    bne t0, t1, _check_above_ledge_continue // not facing ledge
                    nop

                    lw t0, {ledge_grabbable} // t0 = ledge grabbable
                    beqz t0, _check_above_ledge_continue // if not grabbable, skip
                    nop

                    // if here, we're facing the ledge and it's grabbable
                    lw t6, 0x9c8(a0) // t6 = character attributes
                    lwc1 f4, 0xb0(t6) // f4 = ledge grab Y
                    add.s f8, f8, f4 // y position += ledge grab Y
                }
                _check_above_ledge_continue:
                c.lt.s f6, f8 // ledge Y < my Y?
                nop
                bc1tl above_ledge // if true, above ledge
                nop

                scope below_ledge: {
                    _check_if_using_usp:
                    // if up special was used/is being used, we follow a different logic
                    lb t0, 0x1CC+0x49(a0) // t0 = com->is_attempt_specialhi_recovery

                    beqz t0, below_ledge_continue // if not using recovery move, skip
                    nop

                    _using_usp: {
                        // at this point, target XY = ledge
                        // if we're not in position to make it, let's point towards the correct direction at least
                        // and hope the stage has a wall we can slide up
                        // This covers cases where the character is under the stage, moving away to avoid a pineapple
                        // but they just have to upB at this point. So they would upB away from the stage and SD.
                        lw t0, 0x44(a0) // facing direction
                        lw t1, {recovery_direction_int}

                        beq t0, t1, _end // if facing the ledge, just point to ledge
                        nop

                        // if not in the correct side, let's force the CPU to hold to the correct recovery direction
                        // set ledge xy to player's xy + diagonal up and towards ledge
                        lw t1, 0x78(a0) // load location vector
                        lwc1 f8, 0x0(t1) // f8 = location X
                        lui at, 0x447A // at = 1000.0
                        mtc1 at, f4 // f4 = constant
                        mul.s f4, f4, f10 // f4 = f4 * recovery direction
                        sub.s f8, f8, f4 // f8 = location - constant pointing to the ledge
                        swc1 f8, 0x01CC+0x0060(a0) // target X = our X - constant towards ledge

                        b _end // point towards ledge X, Y to avoid using it in the wrong way
                        nop
                    }

                    below_ledge_continue:
                    lw t0, {ledge_grabbable} // t0 = ledge grabbable
                    beqz t0, below_ledge_facing_away // if not grabbable, consider ourselves facing away
                    nop

                    // For some characters with multiple jumps, we want to always go for the ledge
                    // because later jumps have less height and will end up in failed recoveries
                    lw t0, 0x8(a0) // t0 = character id
                    addiu at, r0, Character.id.JIGGLYPUFF
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.JPUFF
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.EPUFF
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.NJIGGLY
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.KIRBY
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.JKIRBY
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.NKIRBY
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.DEDEDE
                    beq at, t0, below_ledge_facing_away
                    addiu at, r0, Character.id.NDEDEDE
                    beq at, t0, below_ledge_facing_away
                    nop

                    lw t0, 0x44(a0) // facing direction
                    lw t1, {recovery_direction_int}

                    beq t0, t1, below_ledge_facing_towards // facing ledge
                    nop

                    below_ledge_facing_away:
                    // the idea here is to add an outwards padding to the ledge
                    // so the CPU can get in a better position to recover
                    // and not get pineappled
                    lwc1 f6, 0x01CC+0x0060(a0) // f6 = target X (ledge X)
                    lui at, LEDGE_PADDING
                    mtc1 at, f4
                    neg.s f4, f4 // invert direction
                    mul.s f4, f10 // multiply by recovery direction
                    sub.s f6, f6, f4 // add padding in X
                    swc1 f6, 0x01CC+0x0060(a0) // save target X with outwards padding

                    b _end
                    nop

                    below_ledge_facing_towards:
                    lwc1 f6, 0x01CC+0x0064(a0) // f6 = target Y (ledge Y)
                    lw t6, 0x9c8(a0) // t6 = character attributes
                    lwc1 f4, 0xB0(t6) // f4 = ledge grab Y
                    sub.s f6, f6, f4 // y position -= ledge grab Y
                    swc1 f6, 0x01CC+0x0064(a0) // target Y = ledge Y - ledge grab Y

                    lwc1 f6, 0x01CC+0x0060(a0) // f6 = target X (ledge X)
                    lw t6, 0x9c8(a0) // t6 = character attributes
                    lwc1 f4, 0xAC(t6) // f4 = ledge grab X
                    mul.s f4, f10 // correct direction
                    add.s f6, f6, f4 // target X += ledge grab X
                    swc1 f6, 0x01CC+0x0060(a0) // target X = ledge X + ledge grab X

                    b _end
                    nop
                }

                scope above_ledge: {
                    _check_if_using_usp:
                    // if up special was used/is being used, we follow a different logic
                    lb t0, 0x1CC+0x49(a0) // t0 = com->is_attempt_specialhi_recovery

                    beqz t0, above_ledge_continue // if not using recovery move, skip
                    nop

                    _using_usp: {
                        // in case we're using USP from above the ledge
                        // let's point inwards towards the stage instead of the ledge itself
                        // this helps characters like Fox to avoid SDing by pointing towards ledge and overshooting down
                        lwc1 f6, 0x01CC+0x0060(a0) // f6 = target X (ledge X)
                        lui at, LEDGE_PADDING
                        mtc1 at, f4
                        neg.s f4, f4 // invert direction
                        mul.s f4, f10 // multiply by direction
                        add.s f6, f6, f4 // add padding in X
                        swc1 f6, 0x01CC+0x0060(a0) // save target X with inwards padding

                        b _end // point towards ledge X, Y to avoid using it in the wrong way
                        nop
                    }

                    above_ledge_continue:
                    lw t0, {ledge_grabbable} // t0 = ledge grabbable
                    beqz t0, above_ledge_facing_away // if not grabbable, consider ourselves facing away
                    nop

                    lw t0, 0x44(a0) // facing direction
                    lw t1, {recovery_direction_int}

                    beq t0, t1, above_ledge_facing_towards // facing ledge
                    nop

                    above_ledge_facing_away:
                    lwc1 f6, 0x01CC+0x0060(a0) // f6 = target X (ledge X)
                    lui at, LEDGE_PADDING
                    mtc1 at, f4
                    neg.s f4, f4 // invert direction
                    mul.s f4, f10 // multiply by direction
                    add.s f6, f6, f4 // add padding in X
                    swc1 f6, 0x01CC+0x0060(a0) // save target X with inwards padding

                    b _end
                    nop

                    above_ledge_facing_towards:
                    lwc1 f6, 0x01CC+0x0064(a0) // f6 = target Y (ledge Y)
                    lw t6, 0x9c8(a0) // t6 = character attributes
                    lwc1 f4, 0xB0(t6) // f4 = ledge grab Y
                    sub.s f6, f6, f4 // target Y -= ledge grab Y
                    swc1 f6, 0x01CC+0x0064(a0) // target Y = ledge Y - ledge grab Y

                    // target X = ledge X (previously set already)
                }
                
                _end:
                addiu sp, sp, 0x30

                _original:
                lw t8,0x8e8(s0)
                lwc1 f14,0x20(t8)
                lw t0,0x44(sp)
                lwc1 f16, 0x64(t0)
                c.lt.s f14, f16

                j   _return
                nop
            }
        }

        // CPUs will often fastfall and end up SDing because of it
        // so we prevent them from fastfalling when they have no jumps
        // 80134E98+86C
        scope prevent_fastfall: {
            OS.patch_start(0xB0144, 0x80135704)
            j prevent_fastfall
            nop
            _return:
            OS.patch_end()

            // a0 = fighter struct

            // Check CPU level
            lbu     t1, 0x0013(a0)  // t1 = cpu level
            addiu   t1, t1, -10     // t1 = 0 if level 10
            bnezl   t1, _original   // if not lv10, skip
            nop

            // there's this ft_com->ftcom_flags_0x4A_b0 variable that marks if the CPU already attempted to fastfall
            // this is redundant and has a big issue: the CPU will mark it as 1 when it tries to fastfall during hitstun
            // by setting it to 0, we make it so the CPU can try to fastfall again
            lw t0, 0x44(sp)
            lbu t6, 0x4a(t0)
            andi t7, t6, 0xFF7F
            sb t7, 0x4a(t0)

            lw t1, 0x9C8(a0) // t1 = attribute pointer
            lw t1, 0x064(t1) // t1 = max jumps
            lb at, 0x148(a0) // jumps used
            beq at, t1, _skip_fastfall // if jumps used = max jumps, we can't fastfall
            nop

            lw t1, 0x1CC+0x6C(a0) // opponent struct
            beqz t1, _original // if there's no opponent, we can fastfall
            addiu at, r0, -1 // at = 0xFFFFFFF
            lw t1, 0xEC(t1) // get current clipping below opponent
            beq at, t1, _skip_fastfall // opponent is offstage if clipping below is -1, don't fastfall
            nop

            lwc1 f2, 0xF0(a0) // f2 = distance to platform directly under character (negative if above ground)
            lui at, 0xC4FA // ~
            mtc1 at, f4 // f4 = -2000.0
            c.lt.s f2, f4 // if distance > 2000.0
            nop
            bc1fl _skip_fastfall // do not fastfall if very close to the ground, like on a shorthop
            nop

            b _original // all tests passed
            nop

            _skip_fastfall:
            j 0x80134E98+0x87C // skip fastfall
            nop

            _original:
            jal 0x80132564 // ftComputerSetCommandWait
            lli a1, 0x27 // fastfall command

            j   _return
            nop
        }

        // @ Description
        // In ftComputerCheckFindTarget the CPU will check if the opponent is on stage,
        // within the left and right ledges, and above the lower ground.
        // By default, they discard a player that's offstage and will never try to hit them
        // when they're offstage
        // My guess is that Sakurai wanted to avoid the CPU putting itself in bad situations,
        // i.e. jumping offstage or using Fox upB away from the ledge or something
        // To also avoid this, we're going to set the target to a point still on stage, but the CPU
        // should know what moves to use to hit the opponent from there.
        scope hit_offstage_opponents: {
            // ftComputerCheckFindTarget 8013295C+BC
            scope detect_offstage_opponents: {
                OS.patch_start(0xAD458, 0x80132A18)
                j       detect_offstage_opponents
                nop
                _return:
                OS.patch_end()

                // Check CPU level
                lbu     t0, 0x0013(s1)           // t0 = cpu level
                addiu   t0, t0, -10              // t0 = 0 if level 10
                beqz    t0, _skip_onstage_checks // if lv10, skip default checks
                nop

                _normal:
                beqzl   v0, branch_128 // original line 1
                lw      t2, 0x14c(s1) // original line 2

                b       _end_normal
                nop

                branch_128:
                j       0x8013295C+0x128
                nop

                _end_normal:
                j       _return
                nop

                _skip_onstage_checks:
                j       0x8013295C+0x15C
                nop
            }

            // ftComputerCheckFindTarget 8013295C+188
            scope clamp_target_pos_to_stage: {
                OS.patch_start(0xAD524, 0x80132AE4)
                j       clamp_target_pos_to_stage
                nop
                _return:
                OS.patch_end()

                // do not touch f12 or f24 here
                // at the end, the original code uses f20 as target X and f22 as target Y

                // Will use this to avoid having the CPU way too close to the ledge
                // this could lead to them being hit by the opponent's upB and getting sent offstage
                constant LEDGE_PADDING(0x4396) // 300.0

                // Use this as minimum height to consider jumping when at the ledge
                constant JUMP_PADDING(0x4348) // 200.0

                // Check CPU level
                lbu     t0, 0x0013(s1)  // t0 = cpu level
                addiu   t0, t0, -10     // t0 = 0 if level 10
                bnezl   t0, _end        // if not level 10, return normally
                nop

                // f20 = current target X
                // f22 = current target Y

                // f26 = my X
                // f28 = my Y

                lui     at, LEDGE_PADDING
                mtc1    at, f4      // f4 = LEDGE_PADDING

                clamp_min_x:
                lwc1    f2, 0x28(s3) // load left ledge X
                sub.s   f2, f2, f4   // add padding
                c.le.s  f2, f20      // code = 1 if left ledge X <= target X
                nop
                bc1fl   after_clamp_min_x // not offstage, skip
                nop
                mov.s   f20, f2 // replace target X by ledge X + padding
                after_clamp_min_x:

                clamp_max_x:
                lwc1    f2, 0x2C(s3) // load right ledge X
                add.s   f2, f2, f4   // add padding
                c.le.s  f20, f2      // code = 1 if target X <= right ledge X
                nop
                bc1fl   after_clamp_max_x // not offstage, skip
                nop
                mov.s   f20, f2 // replace target X by ledge X + padding
                after_clamp_max_x:

                // if y != CPU's y, they'll try to jump
                // so clamp min Y to stage min Y
                clamp_min_y:
                lui     at, JUMP_PADDING
                mtc1    at, f4      // f4 = JUMP_PADDING

                or      at, r0, r0
                mtc1    at, f2      // f2 = 0

                sub.s   f22, f22, f4    // consider target Y lower than it is using JUMP_PADDING

                c.le.s  f22, f2         // code = 1 if target Y <= stage min Y
                nop
                bc1fl   after_clamp_min_y // not offstage, skip
                nop
                mov.s   f22, f2 // replace target Y by stage min Y
                after_clamp_min_y:

                _end:
                swc1    f20, 0x60(v1) // original line 1: set target X
                swc1    f22, 0x64(v1) // original line 2: set target Y
                j       _return
                nop
            }
        }

        // ftComputerFollowObjectiveWalk
        // 80134E98+c80
        scope shorthop_followup_attack: {
            // Here, the CPU is grounded and the target is above it in Y (and we're not in the initial dash animation, idk why the check)
            // By default, the CPU would fullhop for a frame and then continue to hold towards the target's position
            // and probably go for a follow-up attack
            // In this patch we check if we can just shorthop since it just makes more sense sometimes!
            OS.patch_start(0xB0558, 0x80135B18)
            j       shorthop_followup_attack
            nop
            _return:
            OS.patch_end()

            // a0 = self player struct
            // t0 = target struct !!

            addiu   a1, r0, 0x0004 // original line 2: command = 0x4 = fullhop

            // Check CPU level
            lbu     t1, 0x0013(a0)  // t1 = cpu level
            addiu   t1, t1, -10     // t1 = 0 if level 10
            bnezl   t1, _end        // if not level 10, return normally
            nop

            lw      at, 0x0078(a0)

            // f6 = my Y
            // f4 = target Y
            lw      t1, 0x6C(t0) // t1 = target fighter struct
            beqz    t1, _end     // skip if no target fighter
            nop
            lwc1    f2, 0x4C(t1) // f2 = target air Y velocity
            add.s   f4, f4, f2 // factor in 1 frame

            sub.s   f4, f4, f6 // f4 = my Y - target Y in the next frame

            lui     at, 0x4396 // 300.0
            mtc1    at, f2     // move to f2
            c.le.s  f4, f2     // true if Y diff < constant
            nop
            bc1tl   diff_very_low
            nop
            lui     at, 0x4416 // 600.0
            mtc1    at, f2     // move to f2
            c.le.s  f4, f2     // true if Y diff < constant
            nop
            bc1tl   diff_low
            nop
            lui     at, 0x4461 // 900.0
            mtc1    at, f2     // move to f2
            c.le.s  f4, f2     // true if Y diff < constant
            nop
            bc1tl   diff_med
            nop
            b diff_high
            nop

            diff_very_low:
            b _end
            lli     a1, AI.ROUTINE.MOVE

            diff_low:
            b _end
            lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS

            diff_med:
            b _end
            lli     a1, AI.ROUTINE.FULL_C_JUMP_TOWARDS

            diff_high:
            // no change from vanilla
            _end:
            jal     0x80132564 // original line 1 ftComputerSetCommandWait
            nop
            j       _return
            nop
        }

        scope jump_in_neutral: {
            // the CPU is grounded
            // com->dash_predict <= DISTANCE(com->target_pos.x, fp->joints[nFTPartsJointTopN]->translate.vec.f.x)
            // the CPU is not below the opponent
            // Here, the CPU would just walk towards the target
            // ftComputerFollowObjectiveWalk 80134E98+c24
            scope jump_in_neutral: {
                OS.patch_start(0xB04FC, 0x80135ABC)
                j       jump_in_neutral
                addiu   a1, r0, 0x0001 // original line 2 (action = point stick towards target)
                _return:
                OS.patch_end()

                // Check CPU level
                lbu     t0, 0x0013(a0)           // t0 = cpu level
                addiu   t0, t0, -10              // t0 = 0 if level 10
                bnezl   t0, _end                 // if lv != 10, skip
                nop

                // generate random number, save it in t0
                addiu   sp, sp, -0x18 // save variables
                sw      a0, 0x4(sp)
                sw      v0, 0x8(sp)
                sw      ra, 0xC(sp)

                jal     Global.get_random_int_      // v0 = (random value)
                lli     a0, 200                    // a0 = random max = 200

                or      t0, r0, v0  // t0 = random result

                lw      a0, 0x4(sp)
                lw      v0, 0x8(sp)
                lw      ra, 0xC(sp)
                addiu   sp, sp, 0x18 // restore variables

                lli     t1, 0x0
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS

                lli     t1, 0x1
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS

                lli     t1, 0x2
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS

                lli     t1, 0x3
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.SHORT_HOP_IN_PLACE

                lli     t1, 0x4
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.FULL_C_JUMP_TOWARDS

                lli     t1, 0x5
                beq     t0, t1, _modified
                lli     a1, AI.ROUTINE.FULL_C_JUMP_TOWARDS

                addiu   a1, r0, 0x0001 // if nothing matches, default original line 2 (action = point stick towards target)
                b       _end
                nop

                _modified:
                lli     t0, 0x2 // nFTComputerObjectiveAttack
                sb      t0, 0x1CC(a0) // set cpu behavior

                _end:
                // if we didn't change a1, it's orinal behavior
                jal 0x80132758 // original line 1 ftComputerSetCommandImmediate
                nop
                j       _return
                nop
            }
        }

        // ftComputerFollowObjectiveAttack 801392C8+AC
        scope extend_attack_check_range: {
            OS.patch_start(0xB3DB4, 0x80139374)
            j extend_attack_check_range
            lwc1 f4, 0x68(v1) // original line 1: load distance to target to f4
            _return:
            OS.patch_end()

            // Check CPU level
            lbu at, 0x0013(a0) // t0 = cpu level
            addiu at, at, -10 // t0 = 0 if level 10
            bnez at, _end // if lv != 10, go with original range
            nop

            lui at, 0x44FA // load constant
            mtc1 at, f10 // f10 = 2000.0

            _end:
            j _return
            add.s f16, f8, f10 // original line 2: cpu "view" range = ((random * 300.0F)(f8) + 1200.0F(f10))) 
        }

        // ftComputerFollowObjectiveAttack 801397F4+AC
        scope extend_attack_check_range_2: {
            OS.patch_start(0xB42E0, 0x801398A0)
            j extend_attack_check_range_2
            lwc1 f4, 0x68(v1) // original line 1: load distance to target to f4
            _return:
            OS.patch_end()

            // Check CPU level
            lbu at, 0x0013(a0) // t0 = cpu level
            addiu at, at, -10 // t0 = 0 if level 10
            bnez at, _end // if lv != 10, go with original range
            nop

            lui at, 0x44FA // load constant
            mtc1 at, f10 // f10 = 2000.0

            _end:
            j _return
            add.s f16, f8, f10 // original line 2: cpu "view" range = ((random * 300.0F)(f8) + 1200.0F(f10))) 
        }

        // 80132EC8+2BC
        // Vanilla does some weird decisions when predicting the opponent's position based on their movement
        // In X, it uses the current facing direction when it doesn't affect the opponent's trajectory
        // In Y, it uses gravity for the opponent even when grounded, which might even be why the CPU loves down smash so much
        scope fix_movement_prediction: {
            OS.patch_start(0xADBC4, 0x80133184)
            j fix_movement_prediction
            mtc1 a0, f4 // original line 1: a0 = hit_frame (int)
            _return:
            OS.patch_end()

            // can't use t1!

            // Check CPU level
            lbu t0, 0x0013(s0) // t0 = cpu level
            addiu t0, t0, -10 // t0 = 0 if level 10
            beqz t0, _fixed // if lv10, perform fixed logic
            nop

            _vanilla:
            j _return
            lwc1 f10, 0x18c(sp) // original line 2: f10 = target_vel_x

            _fixed:
            // When dashing or running, ignore any attack options that are not: dash attack, grab, upsmash, nsp, usp
            scope check_skip_move: {
                lw at, 0x24(s0) // at = current action
                lli t0, Action.Dash
                beq at, t0, _running
                lli t0, Action.Run
                beq at, t0, _running
                lli t0, Action.RunBrake
                beq at, t0, _running
                nop
                b _continue_move // not running
                nop

                _running:
                lw at, 0(s2) // at = input command we're considering here

                // check if we're checking an input that can be executed out of a run
                lli t0, AI.ATTACK_TABLE.GRAB.INPUT
                beq at, t0, _continue_move
                lli t0, AI.ATTACK_TABLE.USMASH.INPUT
                beq at, t0, _continue_move
                lli t0, AI.ATTACK_TABLE.USPG.INPUT
                beq at, t0, _continue_move
                lli t0, AI.ATTACK_TABLE.NSPG.INPUT
                beq at, t0, _continue_move
                lli t0, AI.ROUTINE.DASH_ATTACK
                beq at, t0, _continue_move
                nop

                // if we're running and the current action is not possible out of a dash/run,
                // do not consider this action
                _skip_move:
                lw a0, 4(s2)
                j 0x80132EC8+0xB50
                nop

                _continue_move:
            }
            // Should save predicted pos at x=170(sp) y=16C(sp)
            scope x: {
                // vanilla predict_pos_x = ((target_pos_x + (target_vel_x * comattack->hit_start_frame)) - (this_pos_x + (this_vel_x * comattack->hit_start_frame)))
                // here we're considering us doing an attack and the opponent just doing what they're currently doing
                // so for us, if we're grounded we consider ground friction will be active while we perform our move
                // for the opponent, we keep the simple vanilla approach and just project their movement based on current speed
                cvt.s.w f2, f4 // f2 = hit_frame (float)
                
                scope predict_my_x: {
                    lwc1 f18, 0x1ac(sp) // f18 = this_pos_x
                    lwc1 f4, 0x1a4(sp) // f4 = this_vel_x

                    mtc1 r0, f0 // ensure f0 = 0.0

                    c.eq.s f4, f0
                    nop
                    bc1t _end // if xspeed = 0, skip calculations
                    nop

                    lw at, 0x14c(s0) // at = grounded status
                    bnez at, _calc_pos // if aerial, set friction to 0
                    mtc1 r0, f10 // f10 = friction = 0

                    _get_friction:
                    lw t3, 0xF4(s0) // t3 = ground friction
                    li at, 0xFFFF00FF // at = filter for ground type
                    and at, t3, at // at = ground type
                    sll at, at, 0x2 // at = at * 4
                    li t3, Surface.friction_table // t3 = Remix version of dMPCollisionMaterialFrictions
                    addu t3, at, t3 // t3 = address of the current ground's friction
                    lwc1 f16, 0x0(t3) // f16 = ground friction

                    lw at, 0x9C8(s0) // at = attributes pointer
                    lwc1 f20, 0x24(at) // f20 = character friction

                    mul.s f10, f16, f20 // f10 = friction = (ground friction * character friction)

                    _calc_pos:
                    or at, r0, a0 // at = hit_frame (int)
                    
                    _loop_start: {
                        // if at <= 0, end loop
                        blez at, _loop_end
                        nop
                        add.s f18, f18, f4 // f18 = this_pos_x += this_vel_x

                        // decrease speed by friction, check if became zero/crossed over
                        c.le.s f4, f0
                        nop
                        bc1t _negative_speed
                        nop
                        _positive_speed:
                        sub.s f4, f4, f10 // speed -= friction
                        c.le.s f4, f0 // check if speed crossed over zero
                        nop
                        bc1t _loop_end
                        nop
                        b _friction_applied
                        nop

                        _negative_speed:
                        add.s f4, f4, f10 // speed += friction
                        c.le.s f0, f4 // check if speed crossed over zero
                        nop
                        bc1t _loop_end
                        nop
                        _friction_applied:

                        _continue_loop:
                        addiu at, at, -1 // hit_frame-=1
                        b _loop_start
                        nop
                    }
                    _loop_end:
                    _end:
                }

                lwc1 f10, 0x18c(sp) // f10 = target_vel_x
                lwc1 f16, 0x194(sp) // f16 = target_pos_x
                mul.s f6, f2, f10 // f6 = hit_frame * target_vel_x
                add.s f8, f16, f6 // f8 = target_pos_x + (target_vel_x * hit_frame)

                sub.s f16, f8, f18 // f16 = ((target_pos_x + (target_vel_x * hit_frame)) - (this_pos_x)
                swc1 f16, 0x170(sp) // save final predicted X
            }
            scope y: {
                scope predict_my_y: {
                    // if grounded, skip calculations and return our current Y pos as predicted Y
                    lw at, 0x14c(s0)
                    beqz at, _end
                    lwc1 f0, 0x1a8(sp) // f0 = this_pos_y = current y

                    // calculate predicted Y based on gravity and velocity
                    or at, r0, a0 // at = hit_frame (int)
                    lwc1 f0, 0x1a8(sp) // f0 = this_pos_y
                    lwc1 f16, 0x1a0(sp) // f16 = this_vel_y
                    lwc1 f4, 0x198(sp) // f4 = this_gravity
                    lwc1 f6, 0x19c(sp) // f6 = this_max_fall_speed (negative)
                    lwc1 f8, 0xF0(s0) // f8 = distance to platform directly under character (negative if above ground)
                    mtc1 r0, f10 // f10 = 0
                    add.s f18, f0, f8 // f18 = ground Y
                    lw t2, 0xEC(s0) // t2 = current clipping below player (-1 if offstage)

                    _loop_start: {
                        // if at <= 0, end loop
                        blez at, _loop_end
                        nop
                        add.s f0, f0, f16 // f0 = this_pos_y += this_vel_y
                        sub.s f8, f8, f16 // f8 = distance to ground -= this_vel_y (this distance is negative)

                        // if distance from ground >= 0, we'd be grounded, so end loop
                        _ground_check:
                        bltz t2, _ground_check_end // if there's no ground below, skip this check
                        nop
                        c.le.s f10, f8
                        nop
                        bc1tl _loop_end
                        mov.s f0, f18 // final pos y = ground y
                        _ground_check_end:

                        sub.s f16, f16, f4 // this_vel_y -= this_gravity
                        // if this_vel_y > this_max_fall_speed, this_vel_y = this_max_fall_speed
                        c.le.s f16, f6
                        nop
                        bc1f _continue_loop
                        nop
                        _cap_fall_speed:
                        mov.s f16, f6 // this_vel_y = this_max_fall_speed
                        _continue_loop:
                        addiu at, at, -1 // hit_frame-=1
                        b _loop_start
                        nop
                    }
                    _loop_end:

                    _end:
                }

                scope predict_other_y: {
                    // if grounded, skip calculations and return their current Y pos as predicted Y
                    lw t0, 0x1b0(sp) // t0 = other struct
                    lw at, 0x14c(t0)
                    beqz at, _end
                    lwc1 f4, 0x190(sp) // f4 = target_pos_y = current y

                    // calculate predicted Y based on gravity and velocity
                    or at, r0, a0 // at = hit_frame (int)
                    lwc1 f4, 0x190(sp) // f4 = target_pos_y
                    lwc1 f16, 0x188(sp) // f16 = target_vel_y
                    lwc1 f12, 0x180(sp) // f12 = target_gravity
                    lwc1 f6, 0x184(sp) // f6 = target_max_fall_speed (negative)
                    lwc1 f8, 0xF0(t0) // f8 = distance to platform directly under character (negative if above ground)
                    mtc1 r0, f10 // f10 = 0
                    add.s f18, f4, f8 // f18 = ground Y
                    lw t2, 0xEC(t0) // t2 = current clipping below player (-1 if offstage)

                    _loop_start: {
                        // if at <= 0, end loop
                        blez at, _loop_end
                        nop
                        add.s f4, f4, f16 // f4 = target_pos_y += target_vel_y
                        sub.s f8, f8, f16 // f8 = distance to ground -= target_vel_y (this distance is negative)

                        // if distance from ground >= 0, we'd be grounded, so end loop
                        _ground_check:
                        bltz t2, _ground_check_end // if there's no ground below, skip this check
                        nop
                        c.le.s f10, f8
                        nop
                        bc1tl _loop_end
                        mov.s f4, f18 // final pos y = ground y
                        _ground_check_end:

                        sub.s f16, f16, f12 // target_vel_y -= target_gravity
                        // if target_vel_y > target_max_fall_speed, target_vel_y = target_max_fall_speed
                        c.le.s f16, f6
                        nop
                        bc1f _continue_loop
                        nop
                        _cap_fall_speed:
                        mov.s f16, f6 // target_vel_y = target_max_fall_speed
                        _continue_loop:
                        addiu at, at, -1 // hit_frame-=1
                        b _loop_start
                        nop
                    }
                    _loop_end:

                    _end:
                }

                sub.s f6, f4, f0 // f6 = predict_pos_y
                swc1 f6, 0x16c(sp)
            }

            lw a1, 0x8(s0) // a1 = input command
            lw a3,0x44(s0) // a3 = facing direction
            lw a0, 4(s2)
            j 0x80132EC8+0x534 // skip original logic
            or t2, r0, r0 // is_attempt_cliffcatch = FALSE;
        }

        // CPUs will wait to be in nFTCommonStatusFall when using multiple double jumps,
        // resulting in them falling more than necessary and SDing
        // here we add a check if the current update function is ftCommonJumpAerialProcUpdate (used for any kind of aerial jump)
        // Here, we're below ledge and want to see if we can try jumping again
        // 80134E98 + 6B8
        scope fix_multi_doublejump_usage: {
            OS.patch_start(0xAFF90, 0x80135550)
            j fix_multi_doublejump_usage
            nop
            _return:
            OS.patch_end()

            // Check CPU level
            lbu t1, 0x0013(s0) // t1 = cpu level
            addiu t1, t1, -10 // t1 = 0 if level 10
            bnez t1, _original // if not lv10, perform original logic
            nop

            _lv10:
            li t1, 0x8013FB00 // ftCommonJumpAerialProcUpdate
            lw at, 0x9D4(s0) // at = current proc_update function
            beq t1, at, _b_6c0 // ok to jump
            lli at, 0x3A // original line 0: ftStatus_Common_FallSpecial

            _original:
            bnel v0, at, _b_6d4 // original line 1: fp->status_info.status_id == ftStatus_Common_FallSpecial
            lbu t8, 0x0(t0) // original line 2

            _end:
            j       _return
            nop

            _b_6d4:
            // skip jump
            j 0x80134E98+0x6D4
            nop

            _b_6c0:
            // jump
            j 0x80134E98+0x6C0
            nop
        }

        // 80132EC8+8BC
        scope weight_attack_options: {
            OS.patch_start(0xAE1C4, 0x80133784)
            j weight_attack_options
            nop
            _return:
            OS.patch_end()

            lw t7, 0x0000(s2) // original line 1
            sll a0, s1, 0x2 // original line 2

            // Check CPU level
            lbu t0, 0x0013(s0) // t0 = cpu level
            addiu t0, t0, -10 // t0 = 0 if level 10
            bnez t0, _end // if not lv10, perform original logic
            nop
            
            addu t9, sp, a0
            sw t7, 0x10C(t9) // save input type to this slot

            // s2 = current input config
            // 0xBC(sp+a0) = address for chance

            addu t0, sp, a0 // t0 = chance address
            lui at, 0x3F80
            sw at, 0xBC(t0) // initial chance = 1.0

            lw t4, 0x1CC+0x6C(s0) // opponent struct
            beqz t4, _b_b4c
            nop

            scope _check_landing: {
                // if we're going to land before the move comes out, do not go for it
                lw t2, 0xEC(s0) // t2 = current clipping below player (-1 if offstage)
                bltz t2, _end // if no ground below, skip check
                nop

                lw at, 0x14c(s0) // if grounded, skip checks
                beqz at, _end
                nop

                // calculate predicted Y based on gravity and velocity
                lw at, 0x4(s2) // at = move start frame
                lwc1 f0, 0x1a8(sp) // f0 = this_pos_y
                lwc1 f16, 0x1a0(sp) // f16 = this_vel_y
                lwc1 f4, 0x198(sp) // f4 = this_gravity
                lwc1 f6, 0x19c(sp) // f6 = this_max_fall_speed (negative)
                lwc1 f8, 0xF0(s0) // f8 = distance to platform directly under character (negative if above ground)
                mtc1 r0, f10 // f10 = 0

                _loop_start: {
                    // if at <= 0, end loop
                    blez at, _not_landing
                    nop
                    add.s f0, f0, f16 // f0 = this_pos_y += this_vel_y
                    sub.s f8, f8, f16 // f8 = distance to ground -= this_vel_y (this distance is negative)

                    // if distance from ground >= 0, we'd be grounded, so end loop
                    _ground_check:
                    c.le.s f10, f8
                    nop
                    bc1f _ground_check_end
                    nop
                    b _landing // we're going to land before the move comes out
                    nop
                    _ground_check_end:

                    sub.s f16, f16, f4 // this_vel_y -= this_gravity
                    // if this_vel_y > this_max_fall_speed, this_vel_y = this_max_fall_speed
                    c.le.s f16, f6
                    nop
                    bc1f _continue_loop
                    nop
                    _cap_fall_speed:
                    mov.s f16, f6 // this_vel_y = this_max_fall_speed
                    _continue_loop:
                    addiu at, at, -1 // hit_frame-=1
                    b _loop_start
                    nop
                }
                _landing:
                sw r0, 0xBC(t0) // discard this move

                _not_landing:
                _end:
            }

            scope _check_combo: {
                // only check if the opponent is in hitstun
                lw t6, 0x18c(t4) // fp->is_hitstun (and other flags)
                andi t6, t6, 0x1 // get is_hitstun bit
                beqz t6, _not_combo
                nop

                lw t2, 0xB18(t4) // t2 = opponent's hitstun timer

                scope _check_opponent_landing: {
                    // if the opponent is in tumble and going to land, consider it a dropped combo
                    // if grounded, skip calculations and return their current Y pos as predicted Y
                    or v0, r0, r0 // v0 = in how many frames the opponent will land

                    lw at, 0xEC(t4) // at = current clipping below player (-1 if offstage)
                    bltz at, _end // if there's no ground below, skip this check
                    nop

                    lw at, 0x14c(t4) // if grounded, skip checks
                    beqz at, _end
                    nop

                    // only check if the opponent will have a chance to tech
                    lw t6, 0x24(t4) // opponent's current action
                    sltiu at, t6, Action.DamageFlyHigh // at = 1 if next action < DamageFlyHigh
                    bnez at, _end // skip if next action is below ground teching range
                    sltiu at, t6, Action.Tumble + 1 // at = 1 if next action =< Tumble
                    beqz at, _end // skip if next action is not within ground teching range
                    nop

                    // calculate predicted Y based on gravity and velocity
                    lw at, 0x4(s2) // at = move start frame
                    lwc1 f4, 0x190(sp) // f4 = target_pos_y
                    lwc1 f16, 0x188(sp) // f16 = target_vel_y
                    lwc1 f12, 0x180(sp) // f12 = target_gravity
                    lwc1 f6, 0x184(sp) // f6 = target_max_fall_speed (negative)
                    lwc1 f8, 0xF0(t4) // f8 = distance to platform directly under character (negative if above ground)
                    mtc1 r0, f10 // f10 = 0

                    _loop_start: {
                        // if at <= 0, end loop
                        blez at, _not_landing
                        nop
                        // if hitstun would end before landing, skip
                        beq v0, t2, _end
                        nop

                        add.s f4, f4, f16 // f4 = target_pos_y += target_vel_y
                        sub.s f8, f8, f16 // f8 = distance to ground -= target_vel_y (this distance is negative)

                        // if distance from ground >= 0, we'd be grounded, so end loop
                        _ground_check:
                        c.le.s f10, f8
                        nop
                        bc1f _ground_check_end
                        nop
                        b _landing // they're going to land before the move comes out
                        nop
                        _ground_check_end:

                        sub.s f16, f16, f12 // target_vel_y -= target_gravity
                        // if target_vel_y > target_max_fall_speed, target_vel_y = target_max_fall_speed
                        c.le.s f16, f6
                        nop
                        bc1f _continue_loop
                        nop
                        _cap_fall_speed:
                        mov.s f16, f6 // target_vel_y = target_max_fall_speed
                        _continue_loop:
                        addiu at, at, -1 // hit_frame-=1
                        addiu v0, v0, 0x1 // frames until landing += 1
                        b _loop_start
                        nop
                    }
                    _landing:
                    // if the opponent is in a damage animation that leads to tech
                    // and will land during this hitstun time,
                    // consider the time to land as the true hitstun
                    addiu t2, v0, -1 // t2 = opponent's hitstun timer->frames until landing - 1

                    _not_landing:
                    _end:
                }

                lw t1, 0x4(s2) // t1 = move start frame
                addiu t2, t2, 0x2 // give a 2 frame window for almost combos
                ble t1, t2, _combo // if the move will combo
                nop

                // check for true block strings
                lw t2, 0x24(t4) // t2 = target action
                addiu at, r0, Action.ShieldStun
                beq t2, at, _opponent_shielding
                nop

                b _not_combo // not shielding
                nop

                _opponent_shielding:
                lwc1 f2, 0xb34(t4) // f2 = opponent's shieldstun timing (float)
                trunc.w.s f2, f2
                mfc1 t2, f2
                ble t1, t2, _combo // if the move will hit before they can release it
                nop
                b _not_combo
                nop

                _combo:
                // if the move will combo but we'll have plenty hitstun remaining, opt to not go for it sometimes
                // trying to get the cpu to use the hitstun duration better for positioning and go for better combos
                // instead of picking the first option that becomes available
                lw t1, 0x4(s2) // t1 = move start frame
                lw t2, 0x40(t4) // t2 = opponent's hitstun timer
                subu t2, t2, t1 // t2 = hitstun diff
                lli t1, 0x2 // if the move will hit with less than 2 frames remaining, I'll let you just go for it
                blt t2, t1, _combo_continue
                nop

                addiu sp, sp, -0x18 // save registers
                sw a0, 0x4(sp)
                sw v0, 0x8(sp)
                sw v1, 0xC(sp)
                jal Global.get_random_int_  // v0 = (random value)
                or a0, r0, t2 // rand(hitstun_diff) - the bigger the remaining difference, less likely to go for it
                or at, r0, v0 // move rand result to at
                lw a0, 0x4(sp)
                lw v0, 0x8(sp)
                lw v1, 0xC(sp)
                addiu sp, sp, 0x18 // restore registers
                bnez at, _zero_odds
                nop

                _combo_continue:
                // if the move will combo, increase odds of using it
                lui at, 0x447A //
                mtc1 at, f4 // f4 = 1000.0

                lwc1 f8, 0xBC(t0) // f8 = current value for detect_ranges_x (chance of using this move)
                mul.s f4, f4, f8 // f4 = chance * multiplier
                swc1 f4, 0xBC(t0) // save new chance

                b _end
                nop

                _zero_odds:
                b _end
                sw r0, 0xBC(t0) // discard this move

                _not_combo:
                // If the move we're looking at will not combo
                // We check for its starting frame
                // A lot of times these slow moves are the first ones that get considered by the CPU
                // For example: if they jump towards the opponent, at a long distance they think "my 40f move will hit if I start it now"
                // So we decrease the odds these moves are even considered
                // With that, it gives the character a chance to move closer to the opponent and open up for other quick options instead
                // If it's part of a combo, we don't get here and just let it rip
                scope _less_hard_reads: {
                    lw t1, 0x4(s2) // t1 = move start frame

                    jal Global.get_random_float // f0 = random float (0.0-1.0)
                    nop

                    lli t2, 30
                    bge t1, t2, _30
                    lli t2, 20
                    bge t1, t2, _20
                    lli t2, 15
                    bge t1, t2, _15
                    nop

                    b _end
                    nop

                    _15:
                    b _check_odds
                    lui at, 0x3E00 // 0.125

                    _20:
                    b _check_odds
                    lui at, 0x3D00 // 0.03125

                    _30:
                    b _check_odds
                    lui at, 0x3C80 // 0.015625

                    _check_odds:
                    mtc1 at, f2
                    c.lt.s f0, f2 // if rand() < threshold
                    nop
                    bc1fl _zero_odds // discard move if false
                    nop
                    b _end // do not discard move
                    nop

                    _zero_odds:
                    sw r0, 0xBC(t0) // discard this move

                    _end:
                }
                _end:
            }

            scope _less_odds_slow_moves: {
                _opponent_offstage:
                addiu at, r0, -1 // at = 0xFFFFFFF
                lw t1, 0x00EC(t4) // get current clipping below player
                beq at, t1, _advantage // opponent is offstage if clipping below is -1, so we're in advantage
                nop

                _state_check:
                lw t1, 0x24(t4) // t1 = target action
                lli t2, Action.DownBounceD
                beq t1, t2, _advantage
                lli t2, Action.DownBounceU
                beq t1, t2, _advantage
                lli t2, Action.ShieldBreak
                beq t1, t2, _advantage
                lli t2, Action.ShieldBreakFall
                beq t1, t2, _advantage
                lli t2, Action.StunLandD
                beq t1, t2, _advantage
                lli t2, Action.StunLandU
                beq t1, t2, _advantage
                lli t2, Action.StunStartD
                beq t1, t2, _advantage
                lli t2, Action.StunStartU
                beq t1, t2, _advantage
                lli t2, Action.Stun
                beq t1, t2, _advantage
                lli t2, Action.Sleep
                beq t1, t2, _advantage
                lli t2, Action.FallSpecial
                beq t1, t2, _advantage
                lli t2, Action.EggLay
                beq t1, t2, _advantage
                lli t2, Action.EggLayPulled
                beq t1, t2, _advantage
                lli t2, Action.CapturePulled
                beq t1, t2, _advantage
                lli t2, Action.RollF
                beq t1, t2, _small_advantage
                lli t2, Action.RollB
                beq t1, t2, _small_advantage
                lli t2, Action.Tech
                beq t1, t2, _small_advantage
                lli t2, Action.TechF
                beq t1, t2, _small_advantage
                lli t2, Action.TechB
                beq t1, t2, _small_advantage
                nop

                _percent_check:
                lw at, 0x2C(t4) // at = opponent's damage/percentage/%
                lli t1, 150
                bgt at, t1, _normal // at very high %, even fast moves will KO. So "normal"
                lli t1, 90
                bgt at, t1, _small_advantage // at high %, prioritize stronger moves
                nop

                _normal:
                lw t1, 0x4(s2) // t1 = move start frame
                mtc1 t1, f4 //
                cvt.s.w f4, f4 // f4 = float(move start frame)
                mul.s f4, f4 // f4^2
                lwc1 f8, 0xBC(t0) // f8 = current value for detect_ranges_x (chance of using this move)
                div.s f8, f8, f4 // f8 = chance / start frame (chance decreases with starting frame)
                swc1 f8, 0xBC(t0) // save new chance
                b _end
                nop

                _small_advantage:
                lw t1, 0x4(s2) // t1 = move start frame
                mtc1 t1, f4 //
                cvt.s.w f4, f4 // f4 = float(move start frame)
                lwc1 f8, 0xBC(t0) // f8 = current value for detect_ranges_x (chance of using this move)
                mul.s f8, f8, f4 // f8 = chance * start frame (chance increases with starting frame)
                swc1 f8, 0xBC(t0) // save new chance
                b _end
                nop

                _advantage:
                lw t1, 0x4(s2) // t1 = move start frame
                mtc1 t1, f4 //
                cvt.s.w f4, f4 // f4 = float(move start frame)
                mul.s f4, f4 // f4^2
                lwc1 f8, 0xBC(t0) // f8 = current value for detect_ranges_x (chance of using this move)
                mul.s f8, f8, f4 // f8 = chance * start frame ^ 2 (chance increases with starting frame)
                swc1 f8, 0xBC(t0) // save new chance

                _end:
            }
            
            scope _check_shield: {
                lw at, 0x0(s2) // action input
                lli t1, 28 // grab input command
                beq at, t1, _shield_action_check
                lli t1, AI.ROUTINE.DASH_GRAB
                beq at, t1, _shield_action_check
                nop
                b _end
                nop

                _shield_action_check:
                lw t1, 0x24(t4) // opponent's current action
                addiu at, r0, Action.Shield
                beq t1, at, _continue
                addiu at, r0, Action.ShieldStun
                beq t1, at, _continue
                addiu at, r0, Action.ShieldOn
                beq t1, at, _continue
                nop
                b _end // no actions matched
                nop

                _continue:
                // if the opponent is shielding, prioritize grabs
                lui at, 0x447A //
                mtc1 at, f4 // f4 = 1000.0

                lwc1 f8, 0xBC(t0) // f8 = current value for detect_ranges_x (chance of using this move)
                mul.s f4, f4, f8 // f4 = chance * multiplier
                swc1 f4, 0xBC(t0) // save new chance

                _end:
            }

            jal _custom_weight_table
            nop

            b _b_b4c
            addiu s1, s1, 1

            _end:
            jal _custom_weight_table
            nop
            j _return
            nop

            _b_b4c:
            j 0x80132EC8+0xB4C
            nop

            scope _custom_weight_table: {
                // if a character has a custom weight table, use it to modify the chance of using this move
                addiu sp, sp, -0x10 // save ra
                sw ra, 0x4(sp) // ~

                lw t0, 0x8(s0) // t0 = character ID
                sll t0, t0, 2
                li at, Character.cpu_attack_weight.table
                addu t0, t0, at // t0 = entry
                lw t0, 0x0(t0) // load characters entry in table
                beqz t0, _custom_weight_table_end // skip if no entry
                nop
                addu at, sp, a0 // at = chance address
                lwc1 f2, 0xBC+0x10(at) // f2 = current value for detect_ranges_x (chance of using this move)
                jalr t0 // jump to custom function
                nop
                addu t0, sp, a0 // t0 = chance address
                swc1 f2, 0xBC+0x10(t0) // save new chance
                _custom_weight_table_end:

                lw ra, 0x4(sp) // ~
                jr ra
                addiu sp, sp, 0x10 // restore ra
            }
        }

        // 80132EC8+C88
        // Here the CPU tracks recently used inputs and changes the perceived range on repeated use
        // since we add different options for inputs, we're going to skip this check
        scope skip_repeated_input_check: {
            OS.patch_start(0xAE590, 0x80133B50)
            j skip_repeated_input_check
            nop
            _return:
            OS.patch_end()

            // Check CPU level
            lbu     t0, 0x0013(s0) // t0 = cpu level
            addiu   t0, t0, -10 // t0 = 0 if level 10
            bnez    t0, _original // if not lv10, perform original logic
            nop

            // skip switch statement
            b _b_f60 // go to the "default" option at the end of the switch
            nop

            _original:
            beqz at, _b_f60 // original line 1
            sll t5, t5, 0x2 // original line 2
            b _end
            nop

            _b_f60:
            j 0x80132EC8+0xF60
            sll t5, t5, 0x2 // original line 2
            
            _end:
            j       _return
            nop
        }

        // 80132EC8+FD0
        // Here we already have the input for the CPU to use
        // but before using it, the CPU checks if this same move was used 4 times in a row
        // if so, it skips the input and jumps instead
        scope skip_repeated_input_skip: {
            OS.patch_start(0xAE8D8, 0x80133E98)
            j skip_repeated_input_skip
            nop
            _return:
            OS.patch_end()

            // Check CPU level
            lbu     at, 0x0013(s0) // t0 = cpu level
            addiu   at, at, -10 // t0 = 0 if level 10
            bnez    at, _original // if not lv10, perform original logic
            nop

            _lv10:
            j 0x80132EC8+0x1008 // not checking for the 4x inputs, just branching as always false
            sb r0, 0x37(v1)

            _original:
            bnel t5, t6, _j_1008 // original line 1
            sb r0, 0x37(v1) // original line 2
            b _end
            nop

            _j_1008:
            j 0x80132EC8+0x1008
            sb r0, 0x37(v1) // original line 2

            _end:
            j       _return
            nop
        }

        // 80132EC8+10FC
        // Here we already have the input for the CPU to use
        // but before using it, the CPU checks if this same move was used 4 times in a row
        // if so, it skips the input and jumps instead
        scope no_attack_when_all_odds_eq_zero: {
            OS.patch_start(0xAEA04, 0x80133FC4)
            j no_attack_when_all_odds_eq_zero
            lw ra,0x54(sp)
            _return:
            OS.patch_end()

            // Check CPU level
            lbu at, 0x0013(s0) // t0 = cpu level
            addiu at, at, -10 // t0 = 0 if level 10
            bnez at, _original // if not lv10, perform original logic
            nop

            j 0x80132EC8+0x1108
            or v0, r0, r0 // return FALSE

            _original:
            j 0x80132EC8+0x1108
            lw ra,0x54(sp)
        }

        // @ Description
        // Adds alternate options for LVL 10 cpus to use instead of rolling back and forth.
        // Not perfect but better than roll spamming
        scope stop_roll_spam_: {
            OS.patch_start(0xB3CD4, 0x80139294)
            j    stop_roll_spam_
            // keep line 2
            OS.patch_end()
            OS.patch_start(0xB3CE4, 0x801392A4)
            j    stop_roll_spam_
            // keep line 2
            OS.patch_end()

            lw      t6, 0x0008(a0)          // t6 = character id
            addiu   at, r0, Character.id.GBOWSER
            beq     at, t6, _advanced_ai    // automatic advanced AI if GBOWSER
            lbu     t6, 0x0013(a0)          // t6 = cpu level
            slti    at, t6, 10              // at = 0 if 10 or greater
            bnez    at, _end                // do normal if not LVL 10
            nop

            _advanced_ai:
            lw      t6, 0x0024(a0)          // get current action
            lli     at, Action.TurnRun
            slt     at, at, t6              // ~
            bnezl   at, _end                // ~
            lli     a1, AI.ROUTINE.RESET_STICK // Tell the bot to reset stick. Skip if not moving/idle.

            lw      t6, 0x0008(a0)          // get character ID
            sll     t6, t6, 2
            li      at, Character.close_quarter_combat.table
            addu    t6, t6, at              // t6 = entry
            lw      t6, 0x0000(t6)          // load characters entry in jump table
            beqz    t6, _continue           // use do a short hop aerial attack most likely
            nop
            jr      t6
            nop

            _ness:
            b       _end
            addiu   a1, r0, AI.ROUTINE.NESS_DJC_NAIR   // command = Ness double jump cancel.

            _lucas:
            jal     Global.get_random_int_  // v0 = (random value)
            lli     a0, 0xFF                // ~
            sll     at, v0, 31
            beqz    at, _continue           // 1/2 chance to shine
            lw      a0, 0x0048(sp)          // restore player struct
            b       _shine
            nop

            _yoshi:
            b       _end
            addiu   a1, r0, AI.ROUTINE.SHIELD_DROP // double jump cancel

            _fox:
            lw      t0, 0x01FC(a0)          // get opponent struct
            beqz    t0, _shine_check        // skip opponent action check if no opponent
            nop
            lw      t0, 0x0084(t0)          // ~
            lw      t0, 0x0024(t0)          // t0 = opponents action
            addiu   at, r0, Action.Shield   // at = action.shield
            beq     t0, at, _shine          // ~
            addiu   at, r0, Action.ShieldStun // ~
            beq     t0, at, _shine          // always shine if opponent is shielding
            addiu   at, r0, Action.ShieldOn // ~
            beq     t0, at, _shine          // always shine if opponent is shielding
            slti    at, t0, Action.ShieldBreak  // at = 0 if Action.Shieldbreak or greater
            bnez    at, _shine_check        // branch if not shield broken
            slti    at, t0, Action.Sleep    // at = 0 if Action.Grab or greater
            bnezl   at, _end                // just fsmash if they are shield broken
            addiu   a1, r0, AI.ROUTINE.SMASH_FORWARD // a1 = F SMASH id

            _shine_check:
            jal     Global.get_random_int_  // v0 = (random value)
            lli     a0, 4                   // 1 in 10 chance to not shine
            beqz    v0, _continue
            lw      a0, 0x0048(sp)          // restore player struct

            _shine:
            addiu   at, r0, 0x2E          // at = rolling forwards command
            beql    at, a1, _fox_direction_check // branch if opponent to the right
            addiu   t6, r0, 0x0001        // a0 = direction to match
            addiu   t6, r0, 0xFFFF        // ~

            _fox_direction_check:
            lh      at, 0x0046(a0)        // at = current direction
            bnel    at, t6, _end
            addiu   a1, r0, AI.ROUTINE.MULTI_SHINE_TURNAROUND  // custom

            b       _end
            addiu   a1, r0, AI.ROUTINE.MULTI_SHINE // custom


            b       _continue
            nop

            ///// kirby

            _kirby:
            constant UTILT_DISTANCE(0x4382)
            addiu   at, r0, 0x2E            // at = rolling forwards command
            beql    at, a1, _kirby_direction_check // branch if opponent to the right
            addiu   t6, r0, 0x0001          // a0 = direction to match
            addiu   t6, r0, 0xFFFF          //
            _kirby_direction_check:
            lh      at, 0x0046(a0)          // at = current direction
            beq     at, t6, _continue       // maybe do a short hop aerial if opponent in front
            addiu   at, r0, 0x2E            // at = rolling forwards command
            beq     at, a1, _kirby_less_than // branch if opponent is to the right
            nop
            _kirby_greater_than:
            sub.s   f6, f0, f6              // f6 = f6 - f0
            nop
            b       _kirby_compare
            nop
            _kirby_less_than:
            sub.s   f6, f8, f0              // f6 = f8 - f0
            nop
            _kirby_compare:
            abs.s   f6, f6
            nop
            lui     at, UTILT_DISTANCE      // at = float 260.0
            mtc1    at, f12                 // move at to f12
            c.le.s  f6, f12                 // code = 1 if distance less than radius
            nop
            bc1f    _continue
            nop
            b       _end
            lli     a1, AI.ROUTINE.UTILT       // do a UTILT if opponent is behind

            _puff:
            lw      at, 0x01FC(a0)          // get target player
            beqz    at, _continue           // branch if no opponent (somehow)
            nop
            lw      v0, 0x0084(at)          // v0 = target player struct
            lh      t6, 0x05BA(v0)          // t6 = tangibility flag
            addiu   at, r0, 0x0003
            beq     at, t6, _continue       // don't try to rest if they are intangible
            lli     at, 30                  // at = 30 hp
            lw      t6, 0x002C(v0)          // t6 = target players hp%
            blt     at, t6, _continue       // skip rest check if player is less than 30 percent
            addiu   at, r0, 0x2E            // at = rolling forwards command
            beq    at, a1, _puff_less_than  // branch if opponent is to the right
            nop
            _puff_greater_than:
            sub.s   f6, f0, f6              // f6 = f6 - f0
            nop
            b       _puff_compare
            nop
            _puff_less_than:
            sub.s   f6, f8, f0              // f6 = f8 - f0
            nop
            _puff_compare:
            abs.s   f6, f6
            nop
            lui     at, 0x4382              // at = float 260.0
            mtc1    at, f12                 // move at to f12
            c.le.s  f6, f12                 // code = 1 if distance less than radius
            nop
            bc1f    _continue
            lli     a1, AI.ROUTINE.PUFF_SHORT_HOP_DAIR // custom
            b       _end
            lli     a1, AI.ROUTINE.DSP                 // do a DSP if close enough to the enemy

            _continue:
            // this is a check where we're up close and the CPU plans to roll
            // doing nothing (_skip) allows the CPU to consider going for more attacks

            // if the opponent is in any kind of stun state, we're on advantage
            // why would we really want to dodge in any way?
            // here we have 2 paths: advantage and not advantage
            lw      a0, 0x0048(sp)      // restore player struct

            lw      at, 0x01FC(a0)      // get target player
            beqz    at, not_advantage   // branch if no opponent (somehow)
            nop
            lw      t0, 0x0084(at)      // t0 = target player struct
            lw      t1, 0x24(t0)        // load target fighter action

            advantage_check_damage_states:
            lli     t2, Action.DamageHigh1 // First damage animation
            blt     t1, t2, advantage_check_other_states // if lower than, skip to next round of checks
            nop
            lli     t2, Action.DamageFlyRoll // Last damage animation
            bgt     t1, t2, advantage_check_other_states // if bigger than, skip to next round of checks
            nop
            b       advantage
            nop

            advantage_check_other_states:
            lli     t2, Action.DownBounceD
            beq     t1, t2, advantage // if state matches, we have the advantage
            lli     t2, Action.DownBounceU
            beq     t1, t2, advantage // if state matches, we have the advantage
            lli     t2, Action.Stun
            beq     t1, t2, advantage // if state matches, we have the advantage
            lli     t2, Action.Sleep
            beq     t1, t2, advantage // if state matches, we have the advantage
            nop
            b       not_advantage // no matches, we're not 100% in advantage
            nop

            advantage:
            jal     Global.get_random_int_  // v0 = (random value)
            lli     a0, 0x10                 // v0 = 0-15 -- 2/15 shorthop, 13/15 nothing (most probably an attack)
            lw      a0, 0x0048(sp)          // restore player struct

            lli     at, 0x0
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.SHORT_HOP_IN_PLACE // shorthop

            lli     at, 0x1
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS // shorthop

            // if at is any other value, do nothing
            b       _skip
            nop

            not_advantage:
            jal     Global.get_random_int_  // v0 = (random value)
            lli     a0, 0x10                 // v0 = 0-15
            lw      a0, 0x0048(sp)          // restore player struct

            // 1/15 roll
            // 3/15 shorthop
            // 3/15 pivot
            // 8/15 nothing (most probably an attack)

            beq     v0, r0, _end
            nop // roll

            lli     at, 0x1
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.SHORT_HOP_IN_PLACE // shorthop

            lli     at, 0x2
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS // shorthop

            lli     at, 0x3
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.SHORT_HOP_AWAY // shorthop

            lli     at, 0x4
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.PIVOT_AWAY // pivot away

            lli     at, 0x5
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.PIVOT_AWAY // pivot away

            lli     at, 0x5
            beq     v0, at, _end
            lli     a1, AI.ROUTINE.PIVOT_AWAY // pivot away

            // if at is any other value, do nothing
            b       _skip
            nop

            _end:
            // a1 = command to take (default is a roll. 0x2E or 0x2D)
            jal     0x80132564           // execute AI command. original line 1
            nop
            j       0x801392B8           // original branch
            addiu   v0, r0, 0x0001       // ~

            _skip:
            j       0x801392B8           // original branch
            addiu   v0, r0, 0x0000       // ~
        }

        // // Add characters to roll spam jump-table
        // // KIRBY
        // Character.table_patch_start(close_quarter_combat, Character.id.KIRBY, 0x4)
        // dw     stop_roll_spam_._kirby; OS.patch_end()
        // // EKIRBY
        // Character.table_patch_start(close_quarter_combat, Character.id.JKIRBY, 0x4)
        // dw     stop_roll_spam_._kirby; OS.patch_end()
        // // NKIRBY
        // Character.table_patch_start(close_quarter_combat, Character.id.NKIRBY, 0x4)
        // dw     stop_roll_spam_._kirby; OS.patch_end()
        // // PUFF
        // Character.table_patch_start(close_quarter_combat, Character.id.JIGGLYPUFF, 0x4)
        // dw     stop_roll_spam_._puff; OS.patch_end()
        // // JPUFF
        // Character.table_patch_start(close_quarter_combat, Character.id.JPUFF, 0x4)
        // dw     stop_roll_spam_._puff; OS.patch_end()
        // // EPUFF
        // Character.table_patch_start(close_quarter_combat, Character.id.EPUFF, 0x4)
        // dw     stop_roll_spam_._puff; OS.patch_end()
        // // FOX
        // Character.table_patch_start(close_quarter_combat, Character.id.FOX, 0x4)
        // dw     stop_roll_spam_._fox; OS.patch_end()
        // // JFOX
        // Character.table_patch_start(close_quarter_combat, Character.id.JFOX, 0x4)
        // dw     stop_roll_spam_._fox; OS.patch_end()
        // // FALCO
        // Character.table_patch_start(close_quarter_combat, Character.id.FALCO, 0x4)
        // dw     stop_roll_spam_._fox; OS.patch_end()
        // // WOLF
        // Character.table_patch_start(close_quarter_combat, Character.id.WOLF, 0x4)
        // dw     stop_roll_spam_._fox; OS.patch_end()
        // // NESS
        // Character.table_patch_start(close_quarter_combat, Character.id.NESS, 0x4)
        // dw     stop_roll_spam_._ness; OS.patch_end()
        // // NNESS
        // Character.table_patch_start(close_quarter_combat, Character.id.NNESS, 0x4)
        // dw     stop_roll_spam_._ness; OS.patch_end()
        // // JNESS
        // Character.table_patch_start(close_quarter_combat, Character.id.JNESS, 0x4)
        // dw     stop_roll_spam_._ness; OS.patch_end()
        // // LUCAS
        // Character.table_patch_start(close_quarter_combat, Character.id.LUCAS, 0x4)
        // dw     stop_roll_spam_._lucas; OS.patch_end()
        // // SLIPPY
        // Character.table_patch_start(close_quarter_combat, Character.id.SLIPPY, 0x4)
        // dw     stop_roll_spam_._fox; OS.patch_end()
        // // PIANO
        // Character.table_patch_start(close_quarter_combat, Character.id.PIANO, 0x4)
        // dw     stop_roll_spam_._end; OS.patch_end()
        // // GBOWSER
        // Character.table_patch_start(close_quarter_combat, Character.id.GBOWSER, 0x4)
        // dw     stop_roll_spam_._skip; OS.patch_end()


        // @ Description
        // Allows cpus to perform a shield drop instead of a normal plat drop
        scope shield_drop_: {
            OS.patch_start(0xB057C, 0x80135B3C)
            j       shield_drop_
            addiu   a1, r0, AI.ROUTINE.STICK_DOWN      // control routine to run. original line 2
            _return:
            OS.patch_end()

            lbu     at, 0x0013(a0)          // at = cpu level
            slti    at, at, 10              // at = 0 if 10 or greater
            bnez    at, _end                // do normal if not LVL 10
            nop

            _advanced_ai:
            lw      at, 0x0024(a0)          // at = current action
            addiu   a1, r0, Action.Idle
            beql    at, a1, _end                    // only shield drop if idle
            addiu   a1, r0, AI.ROUTINE.SHIELD_DROP  // a1 = custom shield drop routine
            addiu   a1, r0, AI.ROUTINE.STICK_DOWN   // control routine to run. original line 2

            _end:
            // a1 = command to take
            jal     0x80132564           // execute AI command. original line 1
            nop
            j       0x80135B68           // original branch
            lw      ra, 0x0024(sp)       // original branch line

        }

        // 80134E98 + C24
        // Make LV10 CPUs randomly shorthop when approaching in the ground
        // This adds variety and stop with the common run-in-dash-attack approach they like to do
        // scope shorthop_approach: {
        //     OS.patch_start(0xB04FC, 0x80135ABC)
        //     j       shorthop_approach
        //     addiu   a1, r0, 0x1 // original line 2, command to take
        //     _return:
        //     OS.patch_end()

        //     lbu     at, 0x0013(a0)          // at = cpu level
        //     slti    at, at, 10              // at = 0 if 10 or greater
        //     bnez    at, _end                // do normal if not LVL 10
        //     nop

        //     _advanced_ai: {
        //         _check_grounded:
        //         lw      t0, 0x014C(a0)

        //         bnez    t0, _end // skip if aerial
        //         nop

        //         _check_distance:
        //         lw      t0, 0x44(sp)
        //         lw      t1, 0x8e8(a0) // fighter struct's joint 0 bone
        //         lwc1    f0, 0x68(t0) // distance to target fighter

        //         lui     at, 0x447A // 1000.0
        //         mtc1    at, f2

        //         c.le.s  f0, f2  // code = 1 if distance < constant
        //         nop
        //         bc1f    _end
        //         nop

        //         jal     Global.get_random_int_  // v0 = random(a0)
        //         lli     a0, 0x0008              // a0 = 8
        //         or      a0, r0, s0              // restore a0

        //         bne     v0, r0, _end            // skip if random != 0
        //         nop

        //         // change action
        //         lli     a1, AI.ROUTINE.SHORT_HOP_TOWARDS
        //     }

        //     _end:
        //     // a1 = command to take
        //     jal     0x80132758 // original line 1, computer set command immediate
        //     nop

        //     j       _return
        //     nop
        // }

        // // @ Description
        // // Adds DSP for LVL 10 JigglyPuffs to use
        // scope Puff_DSP_: {
        //     // These patches will prevent non-level 10 puffs from using DSP
        //     // JIGGLYPUFF
        //     Character.table_patch_start(ai_attack_prevent, Character.id.JIGGLYPUFF, 0x4)
        //     dw PREVENT_ATTACK.ROUTINE.PUFF_DSP
        //     OS.patch_end()

        //     // JPUFF
        //     Character.table_patch_start(ai_attack_prevent, Character.id.JPUFF, 0x4)
        //     dw PREVENT_ATTACK.ROUTINE.PUFF_DSP
        //     OS.patch_end()

        //     // EPUFF
        //     Character.table_patch_start(ai_attack_prevent, Character.id.EPUFF, 0x4)
        //     dw PREVENT_ATTACK.ROUTINE.PUFF_DSP
        //     OS.patch_end()

        //     // Add DSP as an option to Puffs attack behaviour table
        //     constant CPU_ATTACKS_ORIGIN(0x1026A4)
        //     constant dsp_padding(40)
        //     edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  1,   1,  -130 - dsp_padding, 130 + dsp_padding, 20 - dsp_padding, 280 + dsp_padding)
        //     edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  1,   1, -130 - dsp_padding, 130 + dsp_padding, 20 - dsp_padding, 280 + dsp_padding)
        // }

        // @ Description
        // Removes NSP for LVL 10 Pikas
        // scope Pika_NSP_: {

        //     // These patches will prevent non-level 10 puffs from using DSP
        //     // PIKA
        //     Character.table_patch_start(ai_attack_prevent, Character.id.PIKA, 0x4)
        //     dw      PREVENT_ATTACK.ROUTINE.LVL_10_PREVENT_NSP
        //     OS.patch_end();

        //     // JPIKA
        //     Character.table_patch_start(ai_attack_prevent, Character.id.JPIKA, 0x4)
        //     dw      PREVENT_ATTACK.ROUTINE.LVL_10_PREVENT_NSP
        //     OS.patch_end();

        //     // EPIKA
        //     Character.table_patch_start(ai_attack_prevent, Character.id.EPIKA, 0x4)
        //     dw      PREVENT_ATTACK.ROUTINE.LVL_10_PREVENT_NSP
        //     OS.patch_end();

        // }


        // @ Description
        // Helps level 10 Fox not spam his up special
        scope Fox_USP_: {
            // These patches will allow LVL 10 fox to not rely on his up special
            // FOX
            Character.table_patch_start(ai_attack_prevent, Character.id.FOX, 0x4)
            dw PREVENT_ATTACK.ROUTINE.FOX_USP
            OS.patch_end()

            // JFOX
            Character.table_patch_start(ai_attack_prevent, Character.id.JFOX, 0x4)
            dw PREVENT_ATTACK.ROUTINE.FOX_USP
            OS.patch_end()

            // SLIPPY
            Character.table_patch_start(ai_attack_prevent, Character.id.SLIPPY, 0x4)
            dw PREVENT_ATTACK.ROUTINE.FOX_USP
            OS.patch_end()

            // FALCO
            Character.table_patch_start(ai_attack_prevent, Character.id.FALCO, 0x4)
            dw PREVENT_ATTACK.ROUTINE.FOX_USP
            OS.patch_end()
        }

        // @ Description
        // Holds current combo DI parameters for each port
        // [type, strength, direction, advanced_ai_index]
        cpu_di_parameters:
        db -1, -1, -1, -1 // p1
        db -1, -1, -1, -1 // p2
        db -1, -1, -1, -1 // p3
        db -1, -1, -1, -1 // p4

        // @ Description
        // Adds DI to CPU behavior
        scope cpu_di_: {
            OS.patch_start(0xB4E08, 0x8013A3C8)
            jal     cpu_di_
            lui     at, 0x8019                      // original line 1
            OS.patch_end()

            addu    at, at, t6                      // original line 2

            addiu   sp, sp, -0x0020                 // allocate stack space
            sw      ra, 0x0004(sp)                  // save registers
            sw      a0, 0x0008(sp)                  // ~
            sw      v0, 0x000C(sp)                  // ~
            sw      at, 0x0018(sp)                  // ~

            addiu   t0, r0, -0x0001                 // t0 = -1 = [-1, -1, -1, -1] for cpu_di_parameters
            sw      t0, 0x0010(sp)                  // save cpu_di_parameters for when not in a combo
            lbu     t0, 0x000D(a1)                  // t0 = port

            li      v0, Global.match_info
            lw      v0, 0x0000(v0)                  // v0 = match info
            lli     a0, 0x0074                      // a0 = size of match info block
            multu   a0, t0                          // mflo = offset to hit count address
            mflo    a0                              // a0 = offset to hit count address
            addiu   v0, v0, 0x0074                  // t0 = p1 hit count address
            addu    v0, v0, a0                      // v0 = hit count address
            lw      v0, 0x0000(v0)                  // v0 = hit count

            li      a0, cpu_di_parameters
            sll     t0, t0, 0x0002                  // t0 = offset to cpu_di_parameters
            addu    a0, a0, t0                      // a0 = address of cpu_di_parameters
            sw      a0, 0x0014(sp)                  // save address of cpu_di_parameters

            lw      t0, 0x0000(a0)                  // t0 = current parameters
            bnezl   v0, pc() + 8                    // if in a combo, then keep prior value
            sw      t0, 0x0010(sp)                  // save cpu_di_parameters from beginning of combo

            lw      t0, 0x0040(a1)                  // t0 = hitstun
            beqzl   t0, _end                        // if not in hitstun, return normally
            lw      at, 0x0018(sp)                  // restore at

            lli     t0, 0x0036                      // t0 = training screen_id
            OS.read_byte(Global.current_screen, t1) // t1 = screen_id
            bne     t0, t1, _check_hit_normal       // if not training, don't use menu value
            nop
            OS.read_word(Training.entry_di_first_hit + 0x4, t0) // t0 = first hit to apply DI
            sltu    t1, v0, t0                      // t1 = 1 if hit count is < DI first hit value
            beqz    t1, _check_action               // if hit count is >= DI first hit value, then can DI
            nop
            b       _end                            // otherwise can't DI
            lw      at, 0x0018(sp)                  // restore at

            _check_hit_normal:
            // mimic human DIing after realizing they're in a combo by hit 2,
            // or during a big first hit
            sltiu   t1, v0, 0x0002                  // t1 = 1 if hit count is 0 or 1
            beqz    t1, _check_action               // if hit count is >= 2, then can DI
            lw      t0, 0x001C(a1)                  // t0 = frame count for current action
            sltiu   t1, t0, 10                      // t1 = 1 if frame count < 10
            bnez    t1, _end                        // if haven't been in hitstun too long on first hit, then don't DI
            lw      at, 0x0018(sp)                  // restore at

            _check_action:
            lw      t0, 0x0024(a1)                  // t0 = action ID
            sltiu   t1, t0, Action.DamageHigh1      // t1 = 1 if not a damage action
            bnezl   t1, _end                        // if not a damage action, return normally
            lw      at, 0x0018(sp)                  // restore at
            sltiu   t1, t0, Action.DamageFlyRoll + 1 // t1 = 1 if a damage action
            beqzl   t1, _end                        // if not a damage action, return normally
            lw      at, 0x0018(sp)                  // restore at

            // if here, we are in hitstun
            lli     t0, 0x0036                      // t0 = training screen_id
            OS.read_byte(Global.current_screen, t1) // t1 = screen_id
            bne     t0, t1, _check_level_10         // if not training, check level 10
            nop
            OS.read_word(Training.entry_di_type + 0x4, t0) // t0 = DI type index
            beqzl   t0, _end                        // if DI is none, return normally
            lw      at, 0x0018(sp)                  // restore at

            addiu   t0, t0, -0x0002                 // t0 = DI type
            bgez    t0, _apply_di_type              // if not random DI type, skip
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters

            lb      t0, 0x0000(a0)                  // t0 = saved DI type, or -1
            bgez    t0, _apply_di_type              // if not -1 then we're in the middle of a combo
            nop                                     // otherwise we'll generate a random DI Type

            jal     Global.get_random_int_          // v0 = 0 or 1
            lli     a0, 0x0002                      // a0 = 2
            or      t0, v0, r0                      // t0 = DI type
            sb      t0, 0x0010(sp)                  // save to cpu_di_parameters

            _apply_di_type:
            li      t8, smash_di_table              // t8 = smash_di_table
            bnezl   t0, pc() + 8                    // if slide DI, use slide_di_table
            addiu   t8, t8, slide_di_table - smash_di_table // t8 = slide_di_table

            OS.read_word(Training.entry_di_strength + 0x4, t1) // t1 = DI strength
            OS.read_word(Training.entry_di_direction + 0x4, t2) // t2 = DI direction

            addiu   t1, t1, -0x0001                 // t1 = index of strength group
            addiu   t2, t2, -0x0001                 // t2 = index of direction in group

            bgez    t1, _check_direction_random     // if strength is not random, skip
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters

            lb      t1, 0x0001(a0)                  // t1 = saved DI strength, or -1
            bgez    t1, _check_direction_random     // if not -1 then we're in the middle of a combo
            nop                                     // otherwise we'll generate a random DI strength

            jal     Global.get_random_int_          // v0 = 0, 1 or 2
            lli     a0, 0x0003                      // a0 = 3
            or      t1, v0, r0                      // t1 = strength index
            sb      t1, 0x0011(sp)                  // save to cpu_di_parameters

            _check_direction_random:
            bgez    t2, _check_away_toward          // if direction is not random, skip
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters

            lb      t2, 0x0002(a0)                  // t2 = saved DI direction, or -1
            bgez    t2, _check_away_toward          // if not -1 then we're in the middle of a combo
            nop                                     // otherwise we'll generate a random DI direction

            jal     Global.get_random_int_          // v0 = 0, 1, 2 or 3
            lli     a0, 0x0004                      // a0 = 4
            or      t2, v0, r0                      // t2 = direction index
            sb      t2, 0x0012(sp)                  // save to cpu_di_parameters

            _check_away_toward:
            sltiu   at, t2, 0x0004                  // at = 0 if direction is away or toward
            bnez    at, _get_di_routine             // if not away or toward, skip
            addiu   at, t2, -0x0004                 // at = 0 if away, 1 if toward
            lw      t3, 0x0044(a1)                  // t3 = 1 if right, -1 if left

            slt     t3, r0, t3                      // t3 = 0 if left, 1 if right
            lli     t2, 0x0000                      // t2 = left direction
            beql    at, t3, _get_di_routine         // if away&&left or toward&&right, then do right direction
            lli     t2, 0x0001                      // t2 = right direction

            _get_di_routine:
            sll     at, t1, 0x0004                  // at = offset to strength group
            sll     t2, t2, 0x0002                  // t2 = offset to direction group
            addu    at, at, t2                      // at = offset to di routine
            addu    t8, t8, at                      // t8 = di routine address
            b       _set_di
            lw      t8, 0x0000(t8)                  // t8 = di routine

            _check_level_10:
            lbu     t0, 0x0013(a1)                  // t0 = cpu level
            addiu   t0, t0, -10                     // t0 = 0 if level 10
            bnezl   t0, _check_advanced_ai          // if not level 10, return normally
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters

            lb      v0, 0x0003(a0)                  // v0 = saved advanced_ai_index, or -1
            bgez    v0, _skip_random_level_10       // if not -1 then we're in the middle of a combo
            nop                                     // otherwise we'll generate a random advanced_ai_index

            jal     Global.get_random_int_          // v0 = [0, 8]
            lli     a0, 0x0009                      // a0 = 9

            sb      v0, 0x0013(sp)                  // save to cpu_di_parameters

            _skip_random_level_10:
            beqzl   v0, _end                        // if 0, then don't DI
            lw      at, 0x0018(sp)                  // restore at

            addiu   t0, v0, -0x0001                 // t0 = index, maybe
            sltiu   t1, t0, 0x0004                  // t1 = 1 if [0, 3]

            li      t8, smash_di_table              // t8 = smash_di_table, high strength
            beqzl   t1, pc() + 8                    // if slide DI, use slide_di_table
            addiu   t8, t8, slide_di_table - smash_di_table // t8 = slide_di_table
            beqzl   t1, pc() + 8                    // if slide DI, fix index
            addiu   t0, t0, -0x0004                 // t0 = index

            sll     t0, t0, 0x0002                  // t0 = offset to direction routine
            addu    t8, t8, t0                      // t8 = address of routine

            b       _set_di
            lw      t8, 0x0000(t8)                  // t8 = di routine

            _check_advanced_ai:
            addiu   a0, r0, 0x0004                  // a0 = Remix 1p mode flag value
            OS.read_word(SinglePlayerModes.singleplayer_mode_flag, t0) // t0 = Mode Flag Address
            beq     t0, a0, _is_advanced_ai         // if Remix 1p, automatic advanced ai
            nop

            OS.read_word(Toggles.entry_improved_ai + 0x4, t0) // t0 = improved AI
            beqz    t0, _end                        // if not improved AI, return normally
            lw      at, 0x0018(sp)                  // restore at

            OS.read_word(Global.match_info, t0)     // t0 = current match info struct
            lbu     t0, 0x0000(t0)
            lli     a0, Global.GAMEMODE.CLASSIC
            beq     t0, a0, _end                    // if vanilla 1P/RTTF, return normally
            lw      at, 0x0018(sp)                  // restore at

            _is_advanced_ai:
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters
            lb      v0, 0x0003(a0)                  // v0 = saved advanced_ai_index, or -1
            bgez    v0, _skip_random_advanced_ai    // if not -1 then we're in the middle of a combo
            nop                                     // otherwise we'll generate a random advanced_ai_index

            jal     Global.get_random_int_          // v0 = [0, 8]
            lli     a0, 0x0009                      // a0 = 9

            sb      v0, 0x0013(sp)                  // save to cpu_di_parameters

            _skip_random_advanced_ai:
            beqzl   v0, _end                        // if 0, then don't DI
            lw      at, 0x0018(sp)                  // restore at

            li      t8, smash_di_table + 0x10       // t8 = smash_di_table, medium strength
            // base strength on CPU level
            lbu     t0, 0x0013(a1)                  // t0 = CPU level
            sltiu   t1, t0, 4                       // t1 = 1 if CPU level = 1, 2 or 3
            bnezl   t1, _end                        // if CPU level 1, 2, or 3, then don't DI
            lw      at, 0x0018(sp)                  // restore at
            sltiu   t1, t0, 7                       // t1 = 1 if CPU level = 4, 5 or 6
            bnezl   t1, pc() + 8                    // if CPU level 4, 5, or 6, then set to low
            addiu   t8, t8, 0x10                    // t8 = smash_di_table, low strength

            addiu   t0, v0, -0x0001                 // t0 = index, maybe
            sltiu   t1, t0, 0x0004                  // t1 = 1 if [0, 3]
            beqzl   t1, pc() + 8                    // if slide DI, use slide_di_table
            addiu   t8, t8, slide_di_table - smash_di_table // t8 = slide_di_table
            beqzl   t1, pc() + 8                    // if slide DI, fix index
            addiu   t0, t0, -0x0004                 // t0 = index

            sll     t0, t0, 0x0002                  // t0 = offset to direction routine
            addu    t8, t8, t0                      // t8 = address of routine
            lw      t8, 0x0000(t8)                  // t8 = di routine

            _set_di:
            li      ra, 0x8013A49C                  // skip CPU AI jump table
            sw      ra, 0x0004(sp)                  // update ra in stack
            lw      v0, 0x000C(sp)                  // v0 = CPU/AI struct
            sw      t8, 0x0008(v0)                  // set di routine
            lli     t8, 0x0001
            sb      t8, 0x0007(v0)                  // set controller command wait timer

            _end:
            lw      t0, 0x0010(sp)                  // t0 = cpu_di_parameters
            lw      a0, 0x0014(sp)                  // a0 = address of cpu_di_parameters
            sw      t0, 0x0000(a0)                  // update cpu_di_parameters

            lw      ra, 0x0004(sp)                  // restore registers
            lw      a0, 0x0008(sp)                  // ~
            lw      v0, 0x000C(sp)                  // ~
            jr      ra
            addiu   sp, sp, 0x0020                  // deallocate stack space

            smash_di_table:
            dw DI_SMASH_HIGH_LEFT
            dw DI_SMASH_HIGH_RIGHT
            dw DI_SMASH_HIGH_UP
            dw DI_SMASH_HIGH_DOWN
            dw DI_SMASH_MEDIUM_LEFT
            dw DI_SMASH_MEDIUM_RIGHT
            dw DI_SMASH_MEDIUM_UP
            dw DI_SMASH_MEDIUM_DOWN
            dw DI_SMASH_LOW_LEFT
            dw DI_SMASH_LOW_RIGHT
            dw DI_SMASH_LOW_UP
            dw DI_SMASH_LOW_DOWN

            slide_di_table:
            dw DI_SLIDE_HIGH_LEFT
            dw DI_SLIDE_HIGH_RIGHT
            dw DI_SLIDE_HIGH_UP
            dw DI_SLIDE_HIGH_DOWN
            dw DI_SLIDE_MEDIUM_LEFT
            dw DI_SLIDE_MEDIUM_RIGHT
            dw DI_SLIDE_MEDIUM_UP
            dw DI_SLIDE_MEDIUM_DOWN
            dw DI_SLIDE_LOW_LEFT
            dw DI_SLIDE_LOW_RIGHT
            dw DI_SLIDE_LOW_UP
            dw DI_SLIDE_LOW_DOWN
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
                    db type.METAL,         level.VERY_EASY
                    db type.METAL,         level.EASY
                    db type.METAL,         level.NORMAL
                    db type.METAL,         level.HARD
                    db type.METAL,         level.VERY_HARD
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
            // 80132564+2C
            scope clamp_level_9_1: {
                OS.patch_start(0xACFD0, 0x80132590)
                j       clamp_level_9_1
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t7, 0x0013(a0)      // original line
                slti    v1, t7, 10          // v1 = 0 if 10 or greater
                beqzl   v1, pc() + 8
                lli     t7, 9               // if above 9, clamp to 9

                j       _return + 0x8
                addiu   v1, a0, 0x01CC      // original line 3
            }

            // occurs often
            scope clamp_level_9_2: {
                OS.patch_start(0xB2ED0, 0x80138490)
                j       clamp_level_9_2
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t7, 0x0013(a0)      // original line
                slti    t0, t7, 10          // t0 = 0 if 10 or greater
                beqzl   t0, pc() + 8
                lli     t7, 9               // if above 9, clamp to 9

                j       _return + 0x8
                addiu   t0, r0, 0x0001      // original line 3
            }

            // while aerial against an opponent
            // 80132564+100
            scope clamp_level_9_3: {
                OS.patch_start(0xAD0A4, 0x80132664)
                j       clamp_level_9_3
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t2, 0x0013(a0)      // original line
                slti    v0, t2, 10          // v0 = 0 if 10 or greater
                beqzl   v0, pc() + 8
                lli     t2, 9               // if above 9, clamp to 9

                j       _return + 0x8
                subu    v0, t3, t2          // original line 3
            }

            // ?
            scope clamp_level_9_4: {
                OS.patch_start(0xB3568, 0x80138B28)
                j       clamp_level_9_4
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t8, 0x0013(s0)      // original line
                slti    t2, t8, 10          // t2 = 0 if 10 or greater
                beqzl   t2, pc() + 8
                lli     t8, 9               // if above 9, clamp to 9

                j       _return + 0x8
                addiu   t2, r0, 0x0001      // original line 3
            }

            // ?
            scope clamp_level_9_5: {
                OS.patch_start(0xAD1E4, 0x801327A4)
                j       clamp_level_9_5
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t7, 0x0013(a0)      // original line
                slti    at, t7, 10          // at = 0 if 10 or greater
                beqzl   at, pc() + 8
                lli     t7, 9               // if above 9, clamp to 9

                j       _return + 0x8
                lui     at, 0x3F80          // original line 3
            }

            // ?
            scope clamp_level_9_6: {
                OS.patch_start(0xAD2C4, 0x80132884)
                j       clamp_level_9_6
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t2, 0x0013(a0)      // original line
                slti    t6, t2, 10          // t6 = 0 if 10 or greater
                beqzl   t6, pc() + 8
                lli     t2, 9               // if above 9, clamp to 9

                j       _return + 0x8
                addiu   t6, r0, 0x0001      // original line 3
            }

            // while near an opponent
            scope clamp_level_9_7: {
                OS.patch_start(0xADAA0, 0x80133060)
                j       clamp_level_9_7
                // keeping original line 2
                _return:
                OS.patch_end()

                lbu     t8, 0x0013(s0)      // original line
                slti    at, t8, 10          // at = 0 if 10 or greater
                beqzl   at, _lv10
                lli     t8, 9               // if above 9, clamp to 9

                _original:
                j       _return + 0x8
                lui     at, 0x3f80          // original line 3

                _lv10:
                j       _return + 0x8
                lui     at, 0x3f60          // original line 3, but underestimate collision size (0.875 instead of 1.0)
            }

            // while hanging on cliff
            scope clamp_level_9_8: {
                OS.patch_start(0xB17AC, 0x80136D6C)
                j       clamp_level_9_8
                lbu     t9, 0x0013(a2)      // get cpu level
                nop
                nop
                _return:
                OS.patch_end()

                slti    a1, t9, 10          // a1 = 0 if 10 or greater
                lbu     t9, 0x0013(a2)
                beqzl   a1, pc() + 8
                lli     t9, 9               // if above 9, clamp to 9

                bc1fl   _og_skip
                nop
                sll     v1, v1, 1

                _og_skip:
                j       _return
                addiu   a1, r0, 0x0009
            }

            // 8013877C + 250
            // compares some timer to ((-this_fp->level * 2) + 18)).
            // At lv9 this results in 0, but at level 10 it's -2. Clamp.
            scope clamp_level_9_9: {
                OS.patch_start(0xB340C, 0x801389CC)
                j       clamp_level_9_9
                sll     t2, t1, 0x1 // original line 1
                _return:
                OS.patch_end()

                addiu   t3, t2, 0x12 // original line 2, t3 = t2 + 18

                // if t3 < 0, then clamp to 0
                bgezl   t3, _end // if >= 0, skip
                nop

                lli     t3, 0 // t3 = 0

                _end:
                j _return
                nop
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

    }


} // __AI__
