// Stamina.asm
if !{defined __STAMINA__} {
define __STAMINA__()
print "included Stamina.asm\n"

// @ Description
// This file adds Stamina mode.
scope Stamina {
    // @ Description
    // The amount of HP that each character is to begin with
    TOTAL_HP:
    dw  0x000000C7
    OS.align(4)

    constant STAMINA_MODE(0x05)
    constant VS_MODE(0x800A4D0B)

    // @ Description
    // Displays Player stamina instead of percentage
    scope stamina_display_: {
        OS.patch_start(0x8A1FC, 0x8010E9FC)
        j   stamina_display_
        nop
        _return:
        OS.patch_end()

        li          t6, Global.current_screen   // ~
        lbu         t6, 0x0000(t6)              // t0 = current screen
        addiu       at, r0, 0x0016              // screen id
        bne         t6, at, _end
        addiu       at, r0, 0x000C          // original line 1

        li          t6, VS_MODE
        lbu         t6, 0x0000(t6)          // load mode
        addiu       at, r0, STAMINA_MODE    // stamina mode
        bne         t6, at, _end
        addiu       at, r0, 0x000C          // original line 1

        li          t6, TOTAL_HP            // load total hitpoints address
        lw          t6, 0x0000(t6)          // load total hitpoints amount (player damage will be subtracted from this)
        addiu       t6, t6, 0x0001          // t6 = h.p. value, 1-based
        j           0x8010EA10              // jump to stamina display code, skipping branch that normally skips
        or          a0, a2, r0              // replacement code for skipped code

        _end:
        j           _return
        or          a1, s0, r0              // original line 2
    }

    // @ Description
    // Alters the darkening of HP based on the amount of hp left
    scope stamina_dark_: {
        OS.patch_start(0x8A428, 0x8010EC28)
        j   stamina_dark_
        swc1        f14, 0x000C(t1)         // original line 2
        _return:
        OS.patch_end()

        li          t0, Global.current_screen   // ~
        lbu         t0, 0x0000(t0)              // t0 = current screen
        addiu       s0, r0, 0x0016              // screen id
        bne         t0, s0, _end
        nop

        li          t0, VS_MODE
        lbu         t0, 0x0000(t0)          // load mode
        addiu       s0, r0, STAMINA_MODE    // stamina mode
        bne         t0, s0, _end
        nop

        li          t0, TOTAL_HP            // load total hitpoints address
        lw          t0, 0x0000(t0)          // load total hitpoints amount (player damage will be subtracted from this)
        addiu       t0, t0, 0x0001          // t0 = h.p. value, 1-based
        mtc1        t0, f8                  // move to fp
        cvt.s.w     f8, f8                  // convert to fp number
        mtc1        t4, f10                 // move total damage to f10
        cvt.s.w     f10, f10                // convert to fp number
        div.s       f8, f10, f8             // divide current hp by total hp to get ratio
        lui         t0, 0x4396              // place 300(fp) in t0
        mtc1        t0, f10                 // move to fp
        mul.s       f10, f8, f10            // multiply 300 by ratio
        cvt.w.s     f10, f10                // convert to integer
        mfc1        t4, f10                 // move to register used to save color

        _end:
        j           _return
        sw          t4, 0x0000(t1)          // original line 1, saves darkness amount
    }


//   // @ Description
//   // Alters the darkening of HP based on the amount of hp left
//   scope stamina_dark_fix_1: {
//       OS.patch_start(0x8A7FC, 0x8010EFFC)
//       j   stamina_dark_fix_1
//       addiu       t6, r0, 0x0016              // screen id
//       _return:
//       OS.patch_end()
//
//       li          t5, Global.current_screen   // ~
//       lbu         t5, 0x0000(t5)              // t5 = current screen
//       bnel        t5, t6, _end
//       lw          t5, 0x0000(s1)          // original line 1, loads darkening amount
//
//       li          t5, VS_MODE
//       lbu         t5, 0x0000(t5)          // load mode
//       addiu       t6, r0, STAMINA_MODE    // stamina mode
//       bnel        t5, t6, _end
//       lw          t5, 0x0000(s1)          // original line 1, loads darkening amount
//
//       li          t6, TOTAL_HP            // load total hitpoints address
//       lw          t6, 0x0000(t6)          // load total hitpoints amount (player damage will be subtracted from this)
//       addiu       at, r0, 0x012C          // maximum color
//       subu        at, t6, at
//       addiu       t6, r0, r0
//       slt         t6, r0, at
//       beqz        t6, _end
//       lw          t5, 0x0000(s1)          // original line 1, loads darkening amount
//       addu        t5, t5, at              // add the difference so a check which creates a percent affect is not triggered constantly
//
//       _end:
//       j           _return
//       lui         at, 0x3F80              // original line 2
//   }

    // @ Description
    // Alters the darkening of HP based on the amount of hp left
    scope stamina_dark_fix_2: {
        OS.patch_start(0x8A15C, 0x8010E95C)
        j   stamina_dark_fix_2
        addiu       t6, r0, 0x0016              // screen id
        _return:
        OS.patch_end()

        li          at, Global.current_screen   // ~
        lbu         at, 0x0000(at)              // at = current screen
        bnel        at, t6, _end
        lw          t6, 0x0000(t1)          // original lin 1

        li          at, VS_MODE
        lbu         at, 0x0000(at)          // load mode
        addiu       t6, r0, STAMINA_MODE    // stamina mode
        bnel        at, t6, _end
        lw          t6, 0x0000(t1)          // original lin 1

        li          v0, TOTAL_HP            // load total hitpoints address
        lw          v0, 0x0000(v0)          // load total hitpoints amount (player damage will be subtracted from this)
        addiu       v0, v0, 0x0001
        slti        at, v0, 0x12D
        bnez        at, _end                // if total hp is 300 or less, no need to continue
        lw          t6, 0x0000(t1)          // original line 1, loads darken amount

        lui         at, 0x4396              // maximum color (300)
        mtc1        v0, f14                 // move total percent
        cvt.s.w     f14                     // convert to floating point
        mtc1        at, f16                 // move to floating point
        div.s       f14, f14, f16           // determine ratio of total hp to 300

        mtc1        t6, f16                 // move darken amount to floating point register
        cvt.s.w     f16                     // convert to floating point
        mul.s       f14, f16, f14           // multiply by ratio
        cvt.w.s     f14                     // change to integer
        mfc1        t6, f14                 // move back to t6
        addiu       t6, t6, 0x0002

        _end:
        j           _return
        lwc1        f14, 0x000C(t1)         // original line 2
    }

    // @ Description
    // Set knockback percent for all hits regardless of player damage
    scope stamina_knockback_: {
        OS.patch_start(0x5F764, 0x800E3F64)
        j       stamina_knockback_
        nop
        _return:
        OS.patch_end()

        li          t8, Global.current_screen   // ~
        lbu         t8, 0x0000(t8)              // t0 = current screen
        addiu       a0, r0, 0x0016              // screen id
        bnel        t8, a0, _end
        lw          t8, 0x002C(s0)              // original line 2

        li          t8, VS_MODE
        lbu         t8, 0x0000(t8)              // load mode
        addiu       a0, r0, STAMINA_MODE        // stamina mode
        bne         t8, a0, _end
        lw          t8, 0x002C(s0)              // original line 2

        _stamina:
        j           _return
        addiu       a0, r0, 0x0014              // knockback as if at 20% always

        _end:
        j           _return
        lw          a0, 0x002C(s5)              // original line 1, loads player percent
    }

    // Set knockback percent for thrown items regardless of player damage
    scope stamina_knockback_item_: {
        OS.patch_start(0x5FA24, 0x800E4224)
        j       stamina_knockback_item_
        addiu       a0, r0, 0x0016              // screen id
        _return:
        OS.patch_end()

        li          a1, Global.current_screen   // ~
        lbu         a1, 0x0000(a1)              // a1 = current screen
        bnel        a1, a0, _end
        lw          a0, 0x002C(s5)              // original line 1, loads player percent

        li          a1, VS_MODE
        lbu         a1, 0x0000(a1)              // load mode
        addiu       a0, r0, STAMINA_MODE        // stamina mode
        bnel        a1, a0, _end
        lw          a0, 0x002C(s5)              // original line 1, loads player percent

        addiu       a0, r0, 0x0014              // knockback as if at 20% always

        _end:
        j           _return
        lw          a1, 0x07F0(s5)              // original line 2
    }

    // @ Description
    // Set knockback percent for throws regardless of player damage
    scope stamina_knockback_throw_: {
        OS.patch_start(0xC5AA0, 0x8014B060)
        j       stamina_knockback_throw_
        nop
        _return:
        OS.patch_end()

        li          t1, Global.current_screen   // ~
        lbu         t1, 0x0000(t1)              // t0 = current screen
        addiu       a0, r0, 0x0016              // screen id
        bnel        t1, a0, _end
        lw          a0, 0x002C(s1)              // original line 1, loads player percent

        li          t1, VS_MODE
        lbu         t1, 0x0000(t1)              // load mode
        addiu       a0, r0, STAMINA_MODE        // stamina mode
        bnel        t1, a0, _end
        lw          a0, 0x002C(s1)              // original line 1, loads player percent

        _stamina:
        addiu       a0, r0, 0x0014              // knockback as if at 20% always

        _end:
        j           _return
        lw          t1, 0x000C(v1)              // original line 2, loads kbs

    }

    // @ Description
    // Set knockback percent for tornado regardless of percent and probably other stage effects
    scope stamina_knockback_tornado_: {
        OS.patch_start(0x65670, 0x800E9E70)
        j       stamina_knockback_tornado_
        addiu       at, r0, 0x0016              // screen id
        _return:
        OS.patch_end()

        li          t6, Global.current_screen   // ~
        lbu         t6, 0x0000(t6)              // t0 = current screen
        bnel        t6, at, _end
        addu        t6, a0, a1                  // original line 1, loads player percent + incoming damage for kbs calculation

        li          t6, VS_MODE
        lbu         t6, 0x0000(t6)              // load mode
        addiu       at, r0, STAMINA_MODE        // stamina mode
        bnel        t6, at, _end
        addu        t6, a0, a1                  // original line 1, loads player percent + incoming damage for kbs calculation

        _stamina:
        addiu       t6, r0, 0x0014              // knockback as if at 20% always

        _end:
        j           _return
        mtc1        t6, f10                     // original line 2, moves total player percent to floating point register

    }

    // @ Description
    // Set knockback percent for projectiles regardless of player damage
    scope stamina_knockback_projectile_: {
        OS.patch_start(0x5F900, 0x800E4100)
        j       stamina_knockback_projectile_
        lw      a1, 0x07F0(s5)                  // original line 2
        _return:
        OS.patch_end()

        li          a3, Global.current_screen   // ~
        lbu         a3, 0x0000(a3)              // a3 = current screen
        addiu       a0, r0, 0x0016              // screen id
        bnel        a3, a0, _end
        lw          a0, 0x002C(s5)              // original line 1, loads player percent

        li          a3, VS_MODE
        lbu         a3, 0x0000(a3)              // load mode
        addiu       a0, r0, STAMINA_MODE        // stamina mode
        bnel        a3, a0, _end
        lw          a0, 0x002C(s5)              // original line 1, loads player percent

        _stamina:
        addiu       a0, r0, 0x0014              // knockback as if at 20% always

        _end:
        j           _return
        nop

    }

    // @ Description
    // KO's the player and potentially ends the match if all players have exausted their hitpoints
    scope stamina_ko_: {

        // a0 = character object

        addiu       sp, sp, -0x0048
        sw          ra, 0x0024(sp)
        sw          s0, 0x0020(sp)
        lw          a0, 0x0004(a0)
        lw          t6, 0x0084(a0)          // t6 = player struct
        sw          t6, 0x0044(sp)


        or          s0, a0, r0              // s0 = player object
        sw          s0, 0x0018(sp)
        lw          t1, 0x14C(t6)           // load kinetic state (grounded v. air)

        // mark them as KO'd like a final stock death or remove stock
        lw          s0, 0x0044(sp)          // load player struct
        sw          r0, 0x07E4(s0)          // erase passive armor
        sw          r0, 0x07E8(s0)          // erase yoshi armor
        lw          v0, 0x09C8(s0)          // load attribute struct
        lhu         a0, 0x00B4(v0)          // load ko sound

        jal         0x8013BC60              // plays KO sound and clunk sound
        nop

        lli     a1, 0x0066                  // a1 = Custom Red Flicker id (hard coded)
        or      a2, r0, r0                  // a2 = 0
        addu    a3, s0, r0
        sw      a3, 0x001C(sp)
        jal     0x800E9814                  // begin gfx routine
        lw      a0, 0x0004(s0)              // load player object

        lw      a0, 0x0004(s0)
        OS.save_registers()
        addu    s1, r0, a0
        jal     0x8013C120
        nop
        OS.restore_registers()

        _end:
        lw          ra, 0x0024(sp)
        lw          s0, 0x0020(sp)
        addiu       sp, sp, 0x0048
        jr          ra
        nop
    }

    // @ Description
    // Removes player control after a check to determine the "Player Defeated" fgm
    scope stamina_player_control_: {
        OS.patch_start(0x8F260, 0x80113A60)
        j       stamina_player_control_
        nop
        _return:
        OS.patch_end()



        addiu       sp, sp, -0x0010
        sw          a3, 0x0004(sp)
        sw          a0, 0x0008(sp)
        li          a3, Global.current_screen   // ~
        lbu         a3, 0x0000(a3)              // a3 = current screen
        addiu       a0, r0, 0x0016              // screen id
        bne         a3, a0, _normal
        nop

        li          a3, VS_MODE
        lbu         a3, 0x0000(a3)              // load mode
        addiu       a0, r0, STAMINA_MODE        // stamina mode
        bnel        a3, a0, _normal
        nop


        addiu       a0, r0, 0x0005
        bnez        t6, _0x80113A88         // original line 1 modified
        sb          a0, 0x0023(t9)          // remove player control

        _normal:

        bnez        t6, _0x80113A88         // original line 1 modified
        nop                                 // original line 2

        lw          a3, 0x0004(sp)
        lw          a0, 0x0008(sp)
        addiu       sp, sp, 0x0010
        j           _return
        nop

        _0x80113A88:
        lw          a3, 0x0004(sp)
        lw          a0, 0x0008(sp)
        addiu       sp, sp, 0x0010
        j           0x80113A88
        nop
    }


    // @ Description
    // KO's the player and potentially ends the match if all players have exausted their hitpoints
    scope stamina_main_: {
        OS.patch_start(0x65A70, 0x800EA270)
        j           stamina_main_
        mflo        t1              // original line 3
        nop
        _return:
        OS.patch_end()

        // t7 = new percentage after attack
        addiu       sp, sp, -0x0030
        sw          t0, 0x0004(sp)
        sw          t1, 0x0008(sp)
        sw          t2, 0x000C(sp)
        sw          s0, 0x0010(sp)
        sw          a1, 0x0014(sp)
        sw          v0, 0x0018(sp)
        sw          a2, 0x001C(sp)
        sw          ra, 0x0020(sp)
        sw          a0, 0x0024(sp)

        // vs mode check
        li          t0, Global.current_screen   // ~
        lbu         t0, 0x0000(t0)              // t0 = current screen
        addiu       t1, r0, 0x0016              // screen id
        bne         t0, t1, _end
        nop

        // stamina mode check
        li          t0, VS_MODE
        lbu         t0, 0x0000(t0)          // load mode
        addiu       t1, r0, STAMINA_MODE    // stamina mode
        bne         t0, t1, _end
        nop

        lui         t2, 0x800A
        lw          t2, 0x50E8(t2)          // load hardcoded struct used for stocks and other things
        lbu         t1, 0x000D(a0)          // load port
        sll         t0, t1, 0x3
        subu        t0, t0, t1
        sll         t0, t0, 0x2
        addu        t0, t0, t1
        sll         t0, t0, 0x2
        addu        t0, t0, t2              // stock address for that port
        lb          t0, 0x002B(t0)          // load stock amount
        addiu       t1, r0, 0xFFFF          // place no stocks amount in t1
        beq         t1, t0, _end            // if the player is already defeated, skip KO routines
        nop

        li          t0, TOTAL_HP            // load total hitpoints address
        lw          t0, 0x0000(t0)          // load total hitpoints amount
        slt         t1, t0, t7              // if total hitpoints are less than total percent set t1
        beqz        t1, _end                // jump to end if total percent is less than total hit points
        nop

        // KO Player Routines

        jal         stamina_ko_
        nop

        // check to end match routines

        _end:
        lw          t0, 0x0004(sp)
        lw          t1, 0x0008(sp)
        lw          t2, 0x000C(sp)
        lw          s0, 0x0010(sp)
        lw          a1, 0x0014(sp)
        lw          v0, 0x0018(sp)
        lw          a2, 0x001C(sp)
        lw          ra, 0x0020(sp)
        lw          a0, 0x0024(sp)
        addiu       sp, sp, 0x0030
        or          a3, a0, r0                  // original line 2
        j           _return
        lw          t8, 0x0000(a2)              // original line 1

    }

    // @ Description
    // Forces actions when character is KO'd
    // this modifies the generic change action routine
    scope stamina_ko_action: {
        OS.patch_start(0x6273C, 0x800E6F3C) // things behave differently on menu screens, causing a crash
        j           stamina_ko_action
        sw          a2, 0x0098(sp)              // original line 1
        _return:
        OS.patch_end()

        li      t8, Global.current_screen   // ~
        lbu     t8, 0x0000(t8)              // t0 = current screen
        addiu   t7, r0, 0x0016              // screen id
        bne     t8, t7, _end
        nop

        li      t8, VS_MODE
        lbu     t8, 0x0000(t8)          // load mode
        addiu   t7, r0, STAMINA_MODE    // stamina mode
        bne     t8, t7, _end
        nop

        li      t8, TOTAL_HP            // load total hitpoints address
        lw      t8, 0x0000(t8)          // load total hitpoints amount
        lw      t7, 0x002C(s1)          // load player percent
        slt     t8, t8, t7              // if total hitpoints are less than total percent set t8
        beq     t8, r0, _end            // jump to end if total percent is less than total hit points
        nop

        addiu   t8, r0, Action.ScreenKOWait     // revive action check
        beq     a1, t8, _end                    // if a KO Action, let it go
        nop

        beq     a1, r0, _end                    // if DeadD, jump to end
        addiu   t8, r0, Action.DeadS


        // the checks below check though the "dead actions" to allow them to play out and ignore stamina death
        addiu   t7, r0, 0x0004
        _dead:
        beq     a1, t8, _end
        addiu   t8, t8, 0x0001
        bne     t7, t8, _dead
        nop

        addiu   t8, t8, 0x0021

        // the checks below check though the "damage actions" to allow them to play out and ignore stamina death
        _damage:
        beq     a1, t8, _end
        addiu   t8, t8, 0x0001
        addiu   t7, r0, 0x0039
        bne     t7, t8, _damage
        nop
        addiu   t8, r0, Action.Tornado
        beq     t8, a1, _end                // check tornado
        addiu   t8, t8, 0x0001
        beq     t8, a1, _end                // check barrel
        addiu   t8, r0, Action.DownBounceD

        // the checks below check though the "down actions" to allow them to play out and ignore stamina death
        _down:
        beq     a1, t8, _end
        addiu   t8, t8, 0x0001
        addiu   t7, r0, 0x0047
        bne     t8, t7, _down
        nop

        // check below through clif actions to allow them to play out and ignore stamina death (this shouldn't happen, but is a fail safe to prevent crashing if it does)
        addiu   t8, r0, Action.CliffCatch
        _cliff:
        beq     t8, a1, _end
        addiu   t8, t8, 0x0001
        addiu   t7, r0, Action.CliffEscapeSlow2
        bne     t8, t7, _cliff
        nop

        addiu   t8, r0, Action.CapturePulled

        // the checks below check though the "captured actions" to allow them to play out and ignore stamina death
        _captured:
        beq     t8, a1, _end
        addiu   t8, t8, 0x0001
        addiu   t7, r0, 0xBD
        bne     t8, t7, _captured
        nop

        // if we reached this point the stamina death actions should be forced
        lw      t8, 0x014C(s1)                  // load kinetic state
        beqzl   t8, _corrections                // if grounded set action to DownBounceD
        addiu   a1, r0, Action.DownBounceD
        addiu   a1, r0, Action.Tumble           // if in the air, set to tumble

        _corrections:
        sw      a1, 0x0094(sp)                  // correct stack


        lui     a3, 0x3F80                      // set anim speed to normal

        _end:
        j           _return
        sw          a3, 0x009C(sp)              // original line 3

    }

    // @ Description
    // Prevents issues related to shielding after ko
    scope stamina_shield_prevent: {
        OS.patch_start(0xC3720, 0x80148CE0)
        j           stamina_shield_prevent
        nop
        _return:
        OS.patch_end()

        addiu       sp, sp, -0x0010
        sw          at, 0x0004(sp)
        sw          t0, 0x0008(sp)

        addiu       at, r0, 0x0016              // screen id
        li          t0, Global.current_screen   // ~
        lbu         t0, 0x0000(t0)              // t0 = current screen
        bne         t0, at, _normal
        nop

        li          at, VS_MODE
        lbu         at, 0x0000(at)          // load mode

        addiu       t0, r0, STAMINA_MODE        // stamina mode
        bne         t0, at, _normal
        nop

        lbu         t0, 0x000D(v0)          // load port
        sll         at, t0, 0x3
        subu        at, at, t0
        sll         at, at, 0x2
        addu        at, at, t0
        sll         at, at, 0x2
        lui         t0, 0x800A
        lw          t0, 0x50E8(t0)          // load hardcoded struct used for stocks and other things
        addu        at, at, t0              // stock address for that port
        lb          at, 0x002B(at)          // load stock amount
        addiu       t0, r0, 0xFFFF          // place no stocks amount in t1

        bne         at, t0, _normal
        nop

        addiu       t9, r0, r0

        _normal:
        beql        t9, r0, _0x80148CFC         // original line 1, modified
        or          v0, r0, r0                  // original line 2

        lw          at, 0x0004(sp)
        lw          t0, 0x0008(sp)
        j           _return
        addiu       sp, sp, 0x0010

        _0x80148CFC:
        lw          at, 0x0004(sp)
        lw          t0, 0x0008(sp)
        addiu       sp, sp, 0x0010
        j           0x80148CFC
        nop
    }

     // @ Description
     // Prevents a character from causing glitches by dying again when thrown off blast zone after running out of stamina
     scope stamina_ko_prevent: {
         OS.patch_start(0xB6BA8, 0x8013C168)
         j           stamina_ko_prevent
         nop
         _return:
         OS.patch_end()

         li         a0, VS_MODE
         lbu        a0, 0x0000(a0)          // load mode
         addiu      a1, r0, STAMINA_MODE    // stamina mode
         bne        a0, a1, _end

         lbu         a0, 0x000D(s1)          // load port
         sll         a1, a0, 0x3
         subu        a1, a1, a0
         sll         a1, a1, 0x2
         addu        a1, a1, a0
         sll         a1, a1, 0x2
         lui         a0, 0x800A
         lw          a0, 0x50E8(a0)          // load hardcoded struct used for stocks and other things
         addu        a1, a1, a0              // stock address for that port
         lb          a1, 0x002B(a1)          // load stock amount
         addiu       a0, r0, 0xFFFF          // place no stocks amount in t1

         bne         a1, a0, _end
         nop

         j           0x8013C1B0
         or          a0, s0, r0              // original line 2

         _end:
         jal        0x8013BC8C              // original line 1
         or         a0, s0, r0              // original line 2
         j           _return
         nop

        }

     // @ Description
     // Prevents a character from causing glitches by dying again when thrown off top blast zone after running out of stamina
     scope stamina_ko_prevent_front: {
         OS.patch_start(0xB73F8, 0x8013C9B8)
         j           stamina_ko_prevent_front
         addiu       a1, r0, STAMINA_MODE    // stamina mode
         _return:
         OS.patch_end()

         li          a2, VS_MODE
         lbu         a2, 0x0000(a2)          // load mode
         bne         a1, a2, _end
         lw          a0, 0x001C(sp)          // original line 1
         lbu         a0, 0x000D(a0)          // load port
         sll         a1, a0, 0x3
         subu        a1, a1, a0
         sll         a1, a1, 0x2
         addu        a1, a1, a0
         sll         a1, a1, 0x2
         lui         a0, 0x800A
         lw          a0, 0x50E8(a0)          // load hardcoded struct used for stocks and other things
         addu        a1, a1, a0              // stock address for that port
         lb          a1, 0x002B(a1)          // load stock amount
         addiu       a0, r0, 0xFFFF          // place no stocks amount in t1

         bne         a1, a0, _end
         nop

         j           0x8013C9EC
         lw          a0, 0x001C(sp)            // original line 2

         _end:
         jal        0x8013BC8C              // original line 1
         lw         a0, 0x001C(sp)            // original line 2
         j           _return
         nop
        }

     // @ Description
     // Sets stocks to 1 always in stamina
      scope stamina_stock: {
          OS.patch_start(0x53834, 0x800D8034)
          j           stamina_stock
          nop
          _return:
          OS.patch_end()

          addiu       t4, r0, 0x0016              // screen id
          li          t8, Global.current_screen   // ~
          lbu         t8, 0x0000(t8)              // t8 = current screen
          bnel        t8, t4, _end                // behave normally if not in vs
          lbu         t4, 0x001B(s6)              // original line 1, stocks amount loaded in

          li          t4, VS_MODE
          lbu         t4, 0x0000(t4)          // load mode
          addiu       t8, r0, STAMINA_MODE    // stamina mode
          bnel        t4, t8, _end            // behave normally if not in stamina mode
          lbu         t4, 0x001B(s6)          // original line 1, stocks amount loaded in

          addiu       t4, r0, r0              // set stocks to 1 in stamina mode

          _end:
          j           _return
          addu        t7, t7, t6              // original line 2
      }

     // @ Description
     // Sets stocks to 1 always in stamina
      scope stamina_stock_2: {
          OS.patch_start(0x53814, 0x800D8014)
          j           stamina_stock_2
          nop
          _return:
          OS.patch_end()

          addiu       t6, r0, 0x0016              // screen id
          li          t7, Global.current_screen   // ~
          lbu         t7, 0x0000(t7)              // t7 = current screen
          bnel        t7, t6, _end                // behave normally if not in vs
          nop

          li          t6, VS_MODE
          lbu         t6, 0x0000(t6)          // load mode
          addiu       t7, r0, STAMINA_MODE    // stamina mode
          bnel        t6, t7, _end            // behave normally if not in stamina mode
          nop

          addiu       t2, r0, r0              // set stocks to 1 in stamina mode

          _end:
          beq         t3, at, _branch        // original line 1 modified
          sb          t2, 0x0014(v0)         // original line 2

          j           _return
          nop

          _branch:
          j         0x800D8048
          nop
      }


    // @ Description
    // Stamina Mode fix. If not fixed, matches end after first KO and have a weird victory calculation
    scope stamina_fix_1: {
        OS.patch_start(0xDFBE0, 0x801651A0)
        j           stamina_fix_1
        addiu       v1, r0, STAMINA_MODE    // stamina mode
        _return:
        OS.patch_end()

        bne         t7, v1, _normal
        lw          v1, 0x0084(v0)          // original line 1

        addiu       t7, r0, 0x0002

        _normal:
        j           _return
        andi        t8, t7, 0x0002          // original line 2
    }

    // @ Description
    // Stamina Mode fix. If not fixed, matches end after first KO and have a weird victory calculation
    scope stamina_fix_2: {
        OS.patch_start(0xB68F8, 0x8013BEB8)
        j           stamina_fix_2
        nop
        _return:
        OS.patch_end()

        addiu       sp, sp, -0x0010
        sw          at, 0x0004(sp)
        sw          t0, 0x0008(sp)

        addiu       at, r0, 0x0016              // screen id
        li          t0, Global.current_screen   // ~
        lbu         t0, 0x0000(t0)              // t0 = current screen
        bne         t0, at, _normal
        lbu         at, 0x0003(a2)              // load mode

        addiu       t0, r0, STAMINA_MODE        // stamina mode
        bne         t0, at, _normal
        nop

        addiu       v0, r0, 0x0003              // should function like time/stock
        addu        t8, v0, r0

        _normal:
        beql        t8, r0, _0x8013BF14         // original line 1, modified
        andi        t8, v0, 0x0008              // original line 2

        lw          at, 0x0004(sp)
        lw          t0, 0x0008(sp)
        j           _return
        addiu       sp, sp, 0x0010

        _0x8013BF14:
        lw          at, 0x0004(sp)
        lw          t0, 0x0008(sp)
        addiu       sp, sp, 0x0010
        j           0x8013BF14
        nop
    }

    // @ Description
    // Stamina Mode fix. If not fixed, matches end after first KO and have a weird victory calculation
    scope stamina_fix_3: {
        OS.patch_start(0x8E970, 0x80113170)
        j           stamina_fix_3
        lbu         t0, 0x0003(a0)          // original line 1
        _return:
        OS.patch_end()

        addiu       t1, r0, STAMINA_MODE    // stamina mode
        bne         t0, t1, _normal         // if not stock mode, skip
        nop                                 // otherwise, mimic timed stock mode

        addiu       t0, r0, 0x0003          // t0 = Timed Stock

        _normal:
        j           _return
        andi        t1, t0, 0x0001          // original line 2
    }

    // @ Description
    // Stamina Mode fix. If not fixed, matches end after first KO and have a weird victory calculation
    scope stamina_fix_4: {
        OS.patch_start(0xB6748, 0x8013BD08)
        j           stamina_fix_4
        lbu         t9, 0x0003(v0)          // original line 1
        _return:
        OS.patch_end()

        addiu       a3, r0, STAMINA_MODE    // stamina mode
        bne         t9, a3, _normal
        nop

        addiu       t9, r0, 0x0002

        _normal:
        j           _return
        lw           a3, 0x0084(a0)          // original line 2
    }

    // @ Description
    // Stamina Mode fix. If not fixed, matches end after first KO and have a weird victory calculation
    scope stamina_fix_5: {
        OS.patch_start(0xB694C, 0x8013BF0C)
        j           stamina_fix_5
        lbu         v0, 0x0003(t7)          // original line 1
        _return:
        OS.patch_end()

        addiu       t8, r0, STAMINA_MODE    // stamina mode
        bne         v0, t8, _normal
        nop

        addiu       v0, r0, 0x0002

        _normal:
        j           _return
        andi        t8, v0, 0x0008          // original line 2
    }

    // @ Description
    // Stamina Mode fix. If not fixed, players respawn indefinetly
    scope stamina_fix_6: {
        OS.patch_start(0xB69E4, 0x8013BFA4)
        j           stamina_fix_6
        lbu         a1, 0x0003(v1)          // original line 1
        _return:
        OS.patch_end()

        addiu       v0, r0, STAMINA_MODE    // stamina mode
        bne         v0, a1, _normal
        lw          v0, 0x0084(a0)          // original line 2

        addiu       a1, r0, 0x0002

        _normal:
        j           _return
        nop
    }

    // @ Description
    // Stamina Mode fix. If not fixed, players respawn indefinetly when star ko'd
    scope stamina_fix_7: {
        OS.patch_start(0xB69F8, 0x8013BFB8)
        j           stamina_fix_7
        addiu       t7, r0, 0x0016              // screen id for vs
        _return:
        OS.patch_end()

        li          at, Global.current_screen   // ~
        lbu         at, 0x0000(at)              // at = current screen
        bne         t7, at, _end
        addiu       at, r0, STAMINA_MODE    // stamina mode

        li          t7, VS_MODE
        lbu         t7, 0x0000(t7)          // load mode
        bne         t7, at, _end
        addiu       at, r0, 0xFFFE          // happens when star ko
        lb          t7, 0x0014(v0)          // original line 1, loads current stock amount
        bne         t7, at, _end            // if not star ko'd for last stock, skip
        addiu       at, r0, 0xFFFF          // -1
        sb          at, 0x0014(v0)          // fix KO amount to only be 1

        j           0x8013BFC8              // initate action that changes player to ScreenKOWait
        nop

        _end:
        lb          t7, 0x0014(v0)          // original line 1
        j           _return
        addiu       at, r0, 0xFFFF          // original line 2
    }

    // @ Description
    // Down Wait usually springs up after a period of time, I remove this if in stamina and hp has run out
    scope stamina_down_wait_down: {
        OS.patch_start(0xBEC7C, 0x8014423C)
        j           stamina_down_wait_down
        nop
        _return:
        OS.patch_end()

        li          at, Global.current_screen   // ~
        lbu         at, 0x0000(at)              // t0 = current screen
        addiu       v1, r0, 0x0016              // screen id
        bne         v1, at, _end
        addiu       at, r0, STAMINA_MODE    // stamina mode

        li          v1, VS_MODE
        lbu         v1, 0x0000(v1)          // load mode
        bne         v1, at, _end
        lw          at, 0x002C(a2)          // load player percent

        li          v1, TOTAL_HP            // load total hitpoints address
        lw          v1, 0x0000(v1)          // load total hitpoints amount
        slt         v1, v1, at              // if total hitpoints are less than total percent set v1
        beq         v1, r0, _end            // if health not below 0, continue as normal
        nop

        j           _return
        nop

        _end:
        jal         0x80144580              // original line 1
        nop                                 // original line 2
        j           _return
        nop
    }

    // @ Description
    // Down Wait usually allows players to transition to various actions via button presses, CPUs will continue to do this when they are turned off, I remove this if in stamina and hp has run out
    scope stamina_down_wait_input: {
        OS.patch_start(0xBEC9C, 0x8014425C)
        j           stamina_down_wait_input
        sw          a0, 0x0018(sp)          // original line 2
        _return:
        OS.patch_end()

        li          t6, Global.current_screen   // ~
        lbu         t6, 0x0000(t6)              // t0 = current screen
        addiu       t7, r0, 0x0016              // screen id
        bne         t7, t6, _end
        addiu       t7, r0, STAMINA_MODE    // stamina mode

        li          t6, VS_MODE
        lbu         t6, 0x0000(t6)          // load mode
        bne         t6, t7, _end
        lw          t6, 0x002C(a2)          // load player percent

        li          t7, TOTAL_HP            // load total hitpoints address
        lw          t7, 0x0000(t7)          // load total hitpoints amount
        slt         t7, t7, t6              // if total hitpoints are less than total percent set v1
        beq         t7, r0, _end            // if health not below 0, continue as normal
        nop

        j           0x80144284              // skip any allowance for inputs to transition
        nop

        _end:
        jal         0x8014499C              // original line 1
        nop
        j           _return
        nop
    }

    // @ Description
    // Down Bounce usually allows players to transition to various actions via button presses, CPUs will continue to do this when they are turned off, I remove this if in stamina and hp has run out
    scope stamina_down_bounce_input: {
        OS.patch_start(0xBEDA0, 0x80144360)
        j           stamina_down_bounce_input
        sw          a0, 0x0018(sp)      // original line 2
        _return:
        OS.patch_end()

        li          t6, Global.current_screen   // ~
        lbu         t6, 0x0000(t6)              // t0 = current screen
        addiu       t7, r0, 0x0016              // screen id
        bne         t7, t6, _end
        addiu       t7, r0, STAMINA_MODE    // stamina mode

        li          t6, VS_MODE
        lbu         t6, 0x0000(t6)          // load mode
        bne         t6, t7, _end
        lw          t6, 0x002C(a2)          // load player percent

        li          t7, TOTAL_HP            // load total hitpoints address
        lw          t7, 0x0000(t7)          // load total hitpoints amount
        slt         t7, t7, t6              // if total hitpoints are less than total percent set v1
        beq         t7, r0, _end            // if health not below 0, continue as normal
        nop

        j           0x80144380              // transition to down wait
        nop

        _end:
        jal         0x80144944              // original line 1
        nop                                 // original line 2
        j           _return
        nop
    }

    // @ Description
    // Prevent grabbing ledge when out of stamina
    scope stamina_ledge: {
        OS.patch_start(0xBF674, 0x80144C34)
        j           stamina_ledge
        nop
        _return:
        OS.patch_end()

        li          s0, Global.current_screen   // ~
        lbu         s0, 0x0000(s0)              // t0 = current screen
        addiu       s1, r0, 0x0016              // screen id
        bne         s1, s0, _end
        lw          s0, 0x0084(a0)          // original line 1

        addiu       s1, r0, STAMINA_MODE    // stamina mode
        li          s0, VS_MODE
        lbu         s0, 0x0000(s0)          // load mode
        bne         s0, s1, _end
        lw          s0, 0x0084(a0)          // load player struct

        lw          s0, 0x002C(s0)          // load player percent
        li          s1, TOTAL_HP            // load total hitpoints address
        lw          s1, 0x0000(s1)          // load total hitpoints amount
        slt         s1, s1, s0              // if total hitpoints are less than total percent set v1
        beq         s1, r0, _end            // if health not below 0, continue as normal
        lw          s0, 0x0084(a0)          // load player struct, original line 1

        j           0x80144CE4              // prevent ledge grabbing
        or          s1, a0, r0              // original line 2

        _end:
        j           _return
        or          s1, a0, r0              // original line 2
    }

    // 8013BF50 writes new stock amount
    // 8013C200 clears percent render

    percent_port:
    dw  0x00000000                      // 1p
    dw  0x00000000                      // 2p
    dw  0x00000000                      // 3p
    dw  0x00000000                      // 4p

    // @ Description
    // Prevents writing more damage than is possible, unless its the last hit
    scope stamina_percent_prevent: {
        OS.patch_start(0x65AB4, 0x800EA2B4)
        j           stamina_percent_prevent
        nop
        _return:
        OS.patch_end()

        addiu       a0, r0, 0x0016              // screen id
        li          t9, Global.current_screen   // ~
        lbu         t9, 0x0000(t9)              // t9 = current screen
        bne         t9, a0, _normal
        addu        t9, t5, t7              // original line 1

        li          a0, VS_MODE
        lbu         a0, 0x0000(a0)          // load mode
        addiu       t9, r0, STAMINA_MODE    // stamina mode
        bne         t9, a0, _normal
        addu        t9, t5, t7              // original line 1

        lbu         t9, 0x000D(a3)          // get port
        sll         a0, t9, 0x3
        subu        a0, a0, t9
        sll         a0, a0, 0x2
        addu        a0, a0, t9
        sll         a0, a0, 0x2
        lui         t9, 0x800A
        lw          t9, 0x50E8(t9)          // load hardcoded struct used for stocks and other things
        addu        a0, a0, t9              // stock address for that port
        lb          a0, 0x002B(a0)          // load stock amount
        addiu       t9, r0, 0xFFFF          // place no stocks amount in t1

        beq         a0, t9, _dead           // this skips saving additional damage in stamina mode when player has been defeated
        addu        t9, t5, t7              // original line 1

        _normal:
        beq         r0, r0, _end
        sw          v1, 0x006C(t9)          // original line 2

        _dead:
        lbu         t9, 0x000D(a3)          // get port
        li          at, percent_port        // load address
        sll         t9, t9, 0x0002          // get offset
        addu        at, t9, at              // get address
        lw          a0, 0x0000(at)          // load already dead flag
        bnez        a0, _end
        addiu       t9, r0, 0x0001

        sw          t9, 0x0000(at)          // save flag
        addu        t9, t5, t7              // original line 1
        li          a0, TOTAL_HP            // load address
        lw          a0, 0x0000(a0)          // load total hp amount
        lw          t9, 0x006C(t9)          // load current damage done
        subu        a0, a0, t9              // find difference between total hp and damage done
        addu        a0, t9, a0              // add the difference
        addiu       a0, a0, 0x0001
        addu        t9, t5, t7              // original line 1
        sw          a0, 0x006C(t9)          // save damage done to finish character

        _end:
        j           _return
        nop
    }

    // @ Description
    // Refreshes ports for new match for the above routine
    scope percent_port_refresh: {
        OS.patch_start(0x10A37C, 0x8018D48C)
        j           percent_port_refresh
        lbu         t3, 0x0026(v1)      // original line 1
        _return:
        OS.patch_end()

        li          t4, percent_port
        sw          r0, 0x0000(t4)
        sw          r0, 0x0004(t4)
        sw          r0, 0x0008(t4)
        sw          r0, 0x000C(t4)

        _end:
        j           _return
        sb          t3, 0x0073(sp)      // original line 2
    }

    // @ Description
    // Prevents KO routine from making the character invisible during certain actions
    scope stamina_invis_prevent: {
        OS.patch_start(0xB6B90, 0x8013C150)
        j           stamina_invis_prevent
        addiu       a0, r0, 0x0016              // screen id
        _return:
        OS.patch_end()


        li          t5, Global.current_screen   // ~
        lbu         t5, 0x0000(t5)              // t5 = current screen
        bnel        t5, a0, _end
        sb          t9, 0x018D(s0)              // original line 1, saves invis flag


        li          a0, VS_MODE
        lbu         a0, 0x0000(a0)          // load mode
        addiu       t5, r0, STAMINA_MODE    // stamina mode
        bnel        t5, a0, _end
        sb          t9, 0x018D(s0)          // original line 1, saves invis flag

        addiu       at, r0, r0
        lw          a0, 0x0024(s0)          // load current action
        ori         t5, r0, Action.DamageFlyMid // problematic action for throws
        beq         a0, t5, _end
        ori         t5, r0, Action.CapturePulled // problematic action for throws
        beq         a0, t5, _end
        ori         t5, r0, Action.CaptureWait // problematic action for throws
        beq         a0, t5, _end

        ori         t5, r0, Action.FalconDivePulled // begining of problematic actions
        addiu       t6, r0, 0x0009

        _loop:
        beq         a0, t5, _end            // if problematic action, skip flag
        addiu       t5, t5, 0x0001          // move to next action check, ending at ThrownFoxB
        bne         at, t6, _loop           // loop through all actions
        addiu       at, at, 0x0001          // move to next loop check

        sb          t9, 0x018D(s0)          // original line 1, saves invis flag

        _end:
        j           _return
        ori         t5, t4, 0x0010          // origial line 2
    }

    // @ Description
    // Prevents hit routine from causing a crash when hit during certain actions
    scope action_hit_crash_prevent: {
        OS.patch_start(0x63A5C, 0x800E825C)
        j           action_hit_crash_prevent
        nop
        _return:
        OS.patch_end()

        addiu       sp, sp, -0x0010
        sw          t5, 0x0004(sp)
        sw          t9, 0x0008(sp)
        sw          t0, 0x000C(sp)

        addiu       t9, r0, 0x0016              // screen id
        li          t5, Global.current_screen   // ~
        lbu         t5, 0x0000(t5)              // t5 = current screen
        bne         t5, t9, _end
        nop


        li          t9, VS_MODE
        lbu         t9, 0x0000(t9)          // load mode
        addiu       t5, r0, STAMINA_MODE    // stamina mode
        bne         t5, t9, _end
        nop

        lui         t9, 0x800A
        lw          t9, 0x50E8(t9)          // load hardcoded struct used for stocks and other things
        lbu         t5, 0x000D(a0)          // load port
        sll         t0, t5, 0x3
        subu        t0, t0, t5
        sll         t0, t0, 0x2
        addu        t0, t0, t5
        sll         t0, t0, 0x2
        addu        t0, t0, t9              // stock address for that port
        lb          t0, 0x002B(t0)          // load stock amount
        addiu       t5, r0, 0xFFFF          // place no stocks amount in t1
        bne         t5, t0, _end            // if is not yet defeated proceed normally
        nop

        sw          r0, 0xB18(a0)           // clear action word used in coming actions if player is dead already

        _end:
        lw          t5, 0x0004(sp)
        lw          t9, 0x0008(sp)
        lw          t0, 0x000C(sp)
        addiu       sp, sp, 0x0010
        beqzl       v0, _0x800E8270         // original line 1, modified
        lw          ra, 0x0014(sp)          // original line 2

        j           _return
        nop

        _0x800E8270:
        j           0x800E8270
        nop
    }

    // @ Description
    // Prevents crash when killed in egg lay in stamina
    scope egg_crash_prevent: {
        OS.patch_start(0xB6B74, 0x8013C134)
        j           egg_crash_prevent
        nop
        _return:
        OS.patch_end()

        addiu       sp, sp, -0x0010
        sw          t0, 0x0004(sp)
        sw          t1, 0x0008(sp)
        sw          t2, 0x000C(sp)

        addiu       t0, r0, 0x0016              // screen id
        li          t1, Global.current_screen   // ~
        lbu         t1, 0x0000(t1)              // t1 = current screen
        bnel        t0, t1, _end
        sw          t6, 0x0B18(s0)          // original line 2


        li          t0, VS_MODE
        lbu         t0, 0x0000(t0)          // load mode
        addiu       t1, r0, STAMINA_MODE    // stamina mode
        bnel        t1, t0, _end
        sw          t6, 0x0B18(s0)          // original line 2
        
        lw          t0, 0x0024(s0)          // load current action
        addiu       t1, r0, Action.EggLay   // insert EggLay Action
        bnel        t0, t1, _end            // if not in Eggay, proceed as normal
        sw          t6, 0x0B18(s0)          // original line 2

        _end:
        lw          t0, 0x0004(sp)
        lw          t1, 0x0008(sp)
        lw          t2, 0x000C(sp)
        addiu       sp, sp, 0x0010

        jal         0x800D9444              // original line 1
        nop
        
        j           _return
        nop
    }
    
    // @ Description
    // Prevents armor from causing weirdness with final hits
    scope stamina_armor_fix_: {


        // vs mode check
        li          t0, Global.current_screen   // ~
        lbu         t0, 0x0000(t0)              // t0 = current screen
        addiu       t1, r0, 0x0016              // screen id
        bne         t0, t1, _end
        nop

        // stamina mode check
        li          t0, VS_MODE
        lbu         t0, 0x0000(t0)          // load mode
        addiu       t1, r0, STAMINA_MODE    // stamina mode
        bne         t0, t1, _end
        nop

        lw          t0, 0x002C(s0)          // load current percent
        lw          t1, 0x07F0(s0)          // load incoming damage
        addu        t0, t1, t0              // combine
        li          t1, TOTAL_HP            // load total hitpoints address
        lw          t1, 0x0000(t1)          // load total hitpoints amount
        slt         t1, t1, t0              // if total hitpoints are less than total percent set t1
        beq         t1, r0, _end            // if health not below 0, continue as normal
        nop

        lw          ra, 0x0004(sp)
        addiu       sp, sp, 0x0010

        mtc1        r0, f2                  // set armor to 0 because the player has been defeated
        jr          ra
        mtc1        r0, f12                 // set armor to 0

        _end:
        jr          ra
        nop
    }


    // @ Description
    // Updates VS Menu
    scope vs_menu {
        // Right scroll max value check on Rule. button
        OS.patch_start(0x124BBC, 0x8013420C)
        slti    at, t5, 0x0005              // increase options from 4 to 6
        OS.patch_end()
        // Max value for blinking arrows on Rule. button
        OS.patch_start(0x123080, 0x801326D0)
        addiu   s7, r0, 0x0005              // increase options from 4 to 6
        OS.patch_end()

        // @ Description
        // Adds Stamina to the Rule. button
        scope add_to_rule_button_: {
            // Scrolling indexes
            OS.patch_start(0x122C6C, 0x801322BC)
            addiu   at, r0, 0x0003          // change Time Team index from 2 to 3
            OS.patch_end()
            OS.patch_start(0x122C78, 0x801322C8)
            addiu   at, r0, 0x0004          // change Stock Team index from 3 to 4
            OS.patch_end()

            // Entering CSS
            OS.patch_start(0x001241A4, 0x801337F4)
            addiu   at, r0, 0x0003          // change Time Team index from 2 to 3
            OS.patch_end()
            OS.patch_start(0x001241AC, 0x801337FC)
            addiu   at, r0, 0x0004          // change Stock Team index from 3 to 4
            OS.patch_end()

            // this allows us to set to a new mode when entering CSS
            OS.patch_start(0x001241B8, 0x80133808)
            j       add_to_rule_button_._set_mode
            nop
            OS.patch_end()

            // this allows us to add additional images
            OS.patch_start(0x122C84, 0x801322D4)
            j       add_to_rule_button_
            nop
            OS.patch_end()
            // position added images
            OS.patch_start(0x122EC4, 0x80132514)
            j       add_to_rule_button_._position
            nop
            OS.patch_end()

            // this fixes a check on whether to set up players for team costumes
            OS.patch_start(0x124ACC, 0x8013411C)
            addiu   at, r0, 0x0002          // change last non-team index from 1 to 2
            OS.patch_end()
            OS.patch_start(0x124BE4, 0x80134234)
            addiu   at, r0, 0x0003          // change first team index from 2 to 3
            OS.patch_end()
            OS.patch_start(0x124458, 0x80133AA8)
            // v0 = index
            sw      s0, 0x0014(sp)          // original line 2
            sltiu   at, v0, 0x0003          // at = 1 if non-team index, 0 if team index
            bnez    at, 0x80133AD8          // if non-team, branch to non-team code
            nop
            b       0x80133B30              // otherwise, branch to team code
            or      s1, r0, r0              // original line 7
            OS.patch_end()


            // v0 = rule index
            lli     at, 0x0002              // at = Stamina index
            beq     v0, at, _stamina        // if stamina, use Stamina image
            lli     at, 0x0005              // a0 = Stamina Team index
            beq     v0, at, _stamina_team   // if stamina, use Stamina image
            nop

            j       0x80132514              // original line 1
            lw      ra, 0x0024(sp)          // original line 2

            _stamina:
            lw      t0, 0x4A4C(t0)          // t0 = address of file 0x006
            j       0x80132344              // jump to Time code
            lli     t1, 0x6D28              // t1 = offset to Stamina image

            _stamina_team:
            lui     t7, 0x8013
            lw      t7, 0x4A4C(t7)          // t7 = address of file 0x006
            j       0x80132464              // jump to Time Team code
            lli     t8, 0x6D28              // t1 = offset to Stamina image

            _position:
            lui     t0, 0x8013              // t0 = rule index
            lw      t0, 0x494C(t0)          // ~
            lli     at, 0x0002              // at = Stamina index
            beq     t0, at, _position_stamina // if stamina, reposition Stamina image
            lli     at, 0x0005              // a0 = Stamina Team index
            beq     t0, at, _position_stamina_team // if stamina, reposition Stamina and Team images
            nop

            _end:
            jr      ra                      // original line 2
            addiu   sp, sp, 0x0038          // original line 1

            _position_stamina:
            // v0 = Stamina image stuct
            lui     at, 0x4330              // at = new X position
            b       _end
            sw      at, 0x0058(v0)          // update X position

            _position_stamina_team:
            // v0 = Team image stuct
            lui     at, 0x4360              // at = new X position for Team
            sw      at, 0x0058(v0)          // update X position
            lui     at, 0x3F60              // at = new X scale for Team
            sw      at, 0x0018(v0)          // update X scale
            lw      v0, 0x000C(v0)          // v0 = Stamina image struct
            sw      at, 0x0018(v0)          // update X scale
            lui     at, 0x4326              // at = new X position for Stamina
            b       _end
            sw      at, 0x0058(v0)          // update X position

            _set_mode:
            // v0 = rule index
            lli     t9, STAMINA_MODE        // t9 = Stamina mode
            lli     at, 0x0002              // at = Stamina index
            beql    v0, at, _end_set_mode   // if stamina, set to FFA
            lli     t8, 0x0000              // t8 = ffa
            lli     at, 0x0005              // a0 = Stamina Team index
            beql    v0, at, _end_set_mode   // if stamina team, set to Team
            lli     t8, 0x0001              // t8 = team

            _end_set_mode:
            sb      t8, 0x0002(v1)          // set ffa/team mode
            jr      ra                      // original line 1
            sb      t9, 0x0003(v1)          // set rule
        }

        // @ Description
        // Adds Stamina. to the Stock./Time. button
        scope add_to_stock_time_button_: {
            // repositions Time Team to 3rd
            OS.patch_start(0x123744, 0x80132D94)
            addiu   at, r0, 0x0003          // change Time Team index from 2 to 3
            OS.patch_end()

            // this allows us to add additional images
            OS.patch_start(0x123804, 0x80132E54)
            jal     add_to_stock_time_button_
            lli     t1, 0x3248              // original line 1/2, simplified - t1 = offset to Stock. image
            OS.patch_end()

            // this allows us to change MIN to H.P. and reposition Stamina. image
            OS.patch_start(0x1237B0, 0x80132E00)
            jal     add_to_stock_time_button_._min
            lli     t5, 0x2FC8              // original line 1/2, simplified - t5 = offset to MIN image
            OS.patch_end()
            // this allows us to reposition H.P. image
            OS.patch_start(0x1237C4, 0x80132E14)
            jal     add_to_stock_time_button_._min_position
            lui     at, 0x4345              // original line 2 - X position of MIN image
            OS.patch_end()


            // v0 = rule index
            lli     a1, 0x0002              // a1 = Stamina index
            beql    v0, a1, _stamina        // if stamina, use Stamina. image
            lli     t9, 0x6B28              // t9 = offset to Stamina. image
            lli     a1, 0x0005              // a1 = Stamina Team index
            beql    v0, a1, _stamina        // if stamina team, use Stamina. image
            lli     t9, 0x6B28              // t9 = offset to Stamina. image

            _end:
            jr      ra
            nop

            _stamina:
            j       0x80132DB8              // jump to minutes rendering routine
            lw      t8, 0x4A4C(t8)          // t8 = file 0x006 address

            _min:
            lui     a0, 0x8013              // a0 = rule index
            lw      a0, 0x494C(a0)          // ~
            lli     a1, 0x0002              // a1 = Stamina index
            beql    a0, a1, _stamina_hp     // if stamina, use H.P. image
            lli     t5, 0x6E28              // t5 = offset to H.P. image
            lli     a1, 0x0005              // a1 = Stamina Team index
            beql    a0, a1, _stamina_hp     // if stamina team, use H.P. image
            lli     t5, 0x6E28              // t5 = offset to H.P. image

            jr      ra
            nop

            _stamina_hp:
            lui     at, 0x42A9              // at = X position of Stamina. image
            jr      ra
            sw      at, 0x0058(v0)          // set new X position of Stamina. image

            _min_position:
            lui     a0, 0x8013              // a0 = rule index
            lw      a0, 0x494C(a0)          // ~
            lli     a1, 0x0002              // a1 = Stamina index
            beql    a0, a1, _hp_position    // if stamina, reposition H.P. image
            lui     at, 0x4354              // at = X position of H.P. image
            lli     a1, 0x0005              // a1 = Stamina Team index
            beql    a0, a1, _hp_position    // if stamina team, reposition H.P. image
            lui     at, 0x4354              // at = X position of H.P. image

            _hp_position:
            jr      ra
            lhu     t6, 0x0024(v0)          // original line 1
        }

        // Fix a check on whether to display minutes value
        OS.patch_start(0x1234F0, 0x80132B40)
        addiu   at, r0, 0x0003              // change Time Team index from 2 to 3
        OS.patch_end()

        // @ Description
        // Allows us to use our stamina HP value
        scope add_to_stock_time_value_: {
            // this allows us to use our custom stamina value
            OS.patch_start(0x12353C, 0x80132B8C)
            j       add_to_stock_time_value_
            lui     v0, 0x8013              // original line 1
            _return:
            OS.patch_end()

            // this allows us to reposition the value and display 3 digits
            OS.patch_start(0x123674, 0x80132CC4)
            jal     add_to_stock_time_value_._position
            addiu   t0, sp, 0x0028          // original line 2
            mtc1    v0, f8                  // original line 1
            OS.patch_end()

            // this handles value scrolling to the left
            OS.patch_start(0x124D98, 0x801343E8)
            jal     add_to_stock_time_value_._scroll_left
            lui     a1, 0x8013              // original line 1
            lw      v0, 0x0000(a1)          // original line 3
            bnez    v0, 0x80134404          // original line 4
            nop
            OS.patch_end()

            // this handles value scrolling to the right
            OS.patch_start(0x124F00, 0x80134550)
            jal     add_to_stock_time_value_._scroll_right
            lui     v1, 0x8013              // original line 1
            lw      v0, 0x0000(v1)          // original line 3
            nop
            OS.patch_end()

            lw      v0, 0x494C(v0)          // v0 = rule index
            lli     at, 0x0002              // at = Stamina index
            beq     v0, at, _stamina        // if stamina, get stamina value
            lli     at, 0x0005              // a0 = Stamina Team index
            beq     v0, at, _stamina        // if stamina team, get stamina value
            lui     v0, 0x8013              // original line 1
            j       _return
            lw      v0, 0x4954(v0)          // original line 2 - v0 = stock value

            _stamina:
            // we'll skip a check on displaying infinity and go straight to the rendering routine
            li      a1, TOTAL_HP
            lw      a1, 0x0000(a1)          // a1 = stamina value, 0-based
            addiu   a1, a1, 0x0001          // a1 = stamina value
            j       0x80132C84
            addiu   sp, sp, 0x0018          // restore stack

            _position:
            lui     a0, 0x8013              // a0 = rule index
            lw      a0, 0x494C(a0)          // ~
            lli     a2, 0x0002              // a2 = Stamina index
            beql    a0, a2, _stamina_position // if stamina, reposition value
            lli     v0, 0x00C5              // v0 = X position of value
            lli     a2, 0x0005              // a2 = Stamina Team index
            beql    a0, a2, _stamina_position // if stamina team, reposition value
            lli     v0, 0x00C5               // v0 = X position of value

            _end:
            jr      ra
            addiu   t1, r0, 0x0003          // original line 3, modified - t1 = max digits to display

            _stamina_position:
            sltiu   a2, a1, 0x000A          // a2 = 1 if 1 digit
            bnez    a2, _end                // if 1 digit, then we're good to go
            sltiu   a2, a1, 0x0064          // a2 = 1 if 2 digits
            bnezl   a2, _end                // if 2 digit, then adjust
            lli     v0, 0x00CD              // v0 = X position of value
            b       _end                    // otherwise, 3 digits so adjust
            lli     v0, 0x00D1              // v0 = X position of value

            _scroll_left:
            lui     v0, 0x8013              // v0 = rule index
            lw      v0, 0x494C(v0)          // ~
            lli     t8, 0x0002              // t8 = Stamina index
            beq     v0, t8, _stamina_left   // if stamina, adjust h.p. value
            lli     t8, 0x0005              // t8 = Stamina Team index
            beq     v0, t8, _stamina_left   // if stamina team, adjust h.p. value
            addiu   a1, a1, 0x4954          // original line 2 - a1 = address of stock value
            jr      ra
            addiu   t8, r0, 0x0062          // original line 3 - t8 = max value of stock, 0-based

            _stamina_left:
            addiu   sp, sp, -0x0010         // allocate stack space
            sw      t1, 0x0004(sp)          // save registers
            sw      ra, 0x0008(sp)          // ~
            sw      t0, 0x000C(sp)          // ~

            li      a1, TOTAL_HP            // a1 = address of h.p. value
            lw      t0, 0x0000(a1)          // load h.p. value

            lli     a0, Joypad.L | Joypad.CL | Joypad.DL // a0 - button_mask
            jal     Joypad.check_buttons_all_   // v0 - bool a_pressed
            lli     a2, Joypad.HELD             // a2 - type
            bnez    v0, _left_update            // if held (not using stick)
            nop

            beqz    t0, _left_update        // if h.p. value is 1, increment by 1
            li      t1, 0x0009              // t1 = 10
            blt     t1, t0, _top_left       // branch if h.p. value is greater than 10
            addiu   t1, t0, -0x0001         // calculate the difference needed to set h.p. to 1
            subu    t1, r0, t1              // ~
            addu    t0, t0, t1              // t0 = (0 - (t0 - 1))
            b       _left_update

            _top_left:
            li      t1, 0x03DE              // t1 = 991
            blt     t0, t1, _left_10        // if h.p. value is less than 991, increment by 10
            addiu   t1, t0, -0x03DE         // calculate the difference needed to set h.p. to 990
            subu    t1, r0, t1              // ~
            addu    t0, t0, t1              // t0 = (0 - (t0 - 990))
            b       _left_update
            nop

            _left_10:
            addiu   t0, t0, -0x0009         // adjust h.p. value in 10 increments

            _left_update:
            sw      t0, 0x0000(a1)          // update h.p. value

            lw      t1, 0x0004(sp)          // ~
            lw      ra, 0x0008(sp)          // ~
            lw      t0, 0x000C(sp)          // restore registers
            addiu   sp, sp, 0x0010          // deallocate stack space

            jr      ra
            lli     t8, 0x03E6              // t8 = max h.p. value

            _scroll_right:
            lui     v0, 0x8013              // v0 = rule index
            lw      v0, 0x494C(v0)          // ~
            lli     at, 0x0002              // at = Stamina index
            beq     v0, at, _stamina_right  // if stamina, adjust h.p. value
            lli     at, 0x0005              // at = Stamina Team index
            beq     v0, at, _stamina_right  // if stamina team, adjust h.p. value
            addiu   v1, v1, 0x4954          // original line 2 - v1 = address of stock value
            jr      ra
            addiu   at, r0, 0x0062          // original line 3 - at = max value of stock, 0-based

            _stamina_right:
            addiu   sp, sp, -0x0010         // allocate stack space
            sw      t1, 0x0004(sp)          // save registers
            sw      ra, 0x0008(sp)          // ~
            sw      a0, 0x000C(sp)          // ~

            // v1 not a1
            li      v1, TOTAL_HP            // v1 = address of h.p. value
            lw      t0, 0x0000(v1)          // load h.p. value

            lli     a0, Joypad.R | Joypad.CR | Joypad.DR // a0 - button_mask
            jal     Joypad.check_buttons_all_   // v0 - bool a_pressed
            lli     a2, Joypad.HELD             // a2 - type
            // beqzl   v0, _right_update           // if not held (using stick)
            // addiu   t0, t0, 0x0009              // adjust h.p. value in 10 increments
            bnez    v0, _right_update           // if held (not using stick)

            li      t1, 0x03E6              // t1 = 999
            beq     t0, t1, _right_update   // if h.p. value is 999, increment by 1
            li      t1, 0x0008              // t1 = 9
            blt     t1, t0, _top_right      // branch if h.p. value is greater than 9
            subu    t1, t1, t0              // calculate the difference needed to set h.p. to 10
            addu    t0, t0, t1              // t0 = t0 + (t1 - t0)
            b       _right_update

            _top_right:
            li      t1, 0x03DD              // t1 = 990
            blt     t0, t1, _right_10       // if h.p. value is less than 990, increment by 10
            li      t1, 0x03E5              // t1 = 998
            subu    t1, t1, t0              // calculate the difference needed to set h.p. to 999
            addu    t0, t0, t1              // t0 = t0 + (t1 - t0)
            b       _right_update
            nop

            _right_10:
            addiu   t0, t0, 0x0009          // adjust h.p. value in 10 increments

            _right_update:
            sw      t0, 0x0000(v1)          // update h.p. value

            lw      t1, 0x0004(sp)          // ~
            lw      ra, 0x0008(sp)          // ~
            lw      a0, 0x000C(sp)          // restore registers
            addiu   sp, sp, 0x0010          // deallocate stack space

            jr      ra
            lli     at, 0x03E6              // t8 = max h.p. value
        }

        // this correctly initializes the Rule. button and it's value button when entering the screen
        OS.patch_start(0x124098, 0x801336E8)
        // v0 = team flag
        lbu     t8, 0x0003(v1)              // t8 = 1 if time, 3 if stock, 5 if stamina
        srl     t9, t8, 0x0001              // t9 = 0 if time, 1 if stock, 2 if stamina
        bnezl   v0, pc() + 8                // if team, add 3 to make it the correct index
        addiu   t9, t9, 0x0003              // t9 = 3 if time team, 4 if stock team, 5 if stamina team
        lui     at, 0x8013
        b       0x80133750                  // skip to next part of routine
        sw      t9, 0x494C(at)              // update index
        OS.patch_end()
    }

    // @ Description
    // Updates VS CSS
    scope vs_css {
        // this allows 3 digits to be rendered in the yellow value scroller at the top
        OS.patch_start(0x1323E8, 0x80134168)
        addiu   t3, r0, 0x0003              // render 3 digits instead of 2
        OS.patch_end()

        // @ Description
        // Handles scrolling HP value on CSS
        scope stamina_scrolling_: {
            // scroll right
            OS.patch_start(0x13660C, 0x8013838C)
            jal     stamina_scrolling_._right
            lw      t2, 0xBDAC(t2)          // original line 1 - t2 = 1 if time, 3 if stock, 5 if stamina
            OS.patch_end()
            // scroll left
            OS.patch_start(0x136690, 0x80138410)
            jal     stamina_scrolling_._left
            lw      t3, 0xBDAC(t3)          // original line 1 - t3 = 1 if time, 3 if stock, 5 if stamina
            OS.patch_end()

            _right:
            lli     at, STAMINA_MODE        // at = Stamina index
            beql    t2, at, _stamina        // if stamina, handle
            lli     at, 0x000A              // at = right

            // if here, not stamina so return normally
            jr      ra
            addiu   at, r0, 0x0001          // original line 2

            _left:
            lli     at, STAMINA_MODE        // at = Stamina index
            beql    t3, at, _stamina        // if stamina, handle
            addiu   at, r0, -0x000A         // at = left

            // if here, not stamina so return normally
            jr      ra
            addiu   at, r0, 0x0001          // original line 2

            _stamina:
            li      v0, TOTAL_HP
            lw      v1, 0x0000(v0)          // v1 = current h.p.
            addu    v1, v1, at              // v1 = updated h.p.

            addiu   a0, v1, 0x0001          // a0 = v1 + 1
            beqzl   a0, _set                // if 0, set to 1
            lli     v1, r0                  // v1 = 1
            lli     a0, 0x03DD              // a0 = 990
            lli     t1, 0x03DC              // t1 = 989
            beql    v1, t1, _set            // if 989, set to 990
            or      v1, r0, a0              // v1 = 990
            lli     a0, 0x0009              // a0 = 10
            lli     t1, 0x000A              // t1 = 11
            beql    v1, t1, _set            // if 11, set to 10
            or      v1, r0, a0              // v1 = 10
            lli     a0, 0x03E6              // a0 = max value
            lli     t1, 0x03E7              // t1 = 1000
            beql    v1, t1, _set            // v1 = max value
            or      v1, r0, a0              // if 1000, set to max
            bltzl   v1, _set                // if less than 0, set to max
            or      v1, r0, a0              // v1 = max value
            slt     at, a0, v1              // at = 1 if greater than max
            bnezl   at, _set                // if greater than max, set to 1
            lli     v1, 0x0000              // v1 = 1
            _set:
            sw      v1, 0x0000(v0)          // update value

            jal     0x80134198              // re-render value
            or      a0, v1, r0              // a0 = hp value

            jal     0x800269C0              // play fgm
            ori     a0, r0, 0x00A4          // a0 = scroll fgm_id

            j       0x801384EC              // jump to rest of routine
            lw      a1, 0x0028(sp)          // a1 = cursort special struct
        }

        // @ Description
        // Displays the stamina value in stamina mode
        scope stamina_hp_display_: {
            // this changes the yellow image to one that reads "H.P."
            OS.patch_start(0x132444, 0x801341C4)
            jal     stamina_hp_display_._bg
            lui     t8, 0x8014
            OS.patch_end()

            // this allows us to display the stamina value
            OS.patch_start(0x1324E4, 0x80134264)
            jal     stamina_hp_display_._value
            lw      a0, 0xBD80(a0)          // original line 2
            OS.patch_end()

            _bg:
            li      t0, 0x0001ADE0          // t0 = offset to H.P. bg
            lw      t8, 0xBDAC(t8)          // t8 = 1 if time, 3 if stock, 5 if stamina
            addiu   t8, t8, -STAMINA_MODE   // t8 = 0 if stamina
            bnezl   t8, pc() + 8            // if not stamina, use STOCK offset
            lli     t0, 0x5270              // original lines 1/2, optimized - t0 = offset to STOCK bg

            jr      ra
            nop

            _value:
            lui     t8, 0x8014              // t8 = 1 if time, 3 if stock, 5 if stamina
            lw      t8, 0xBDAC(t8)          // ~
            addiu   t8, t8, -STAMINA_MODE   // t8 = 0 if stamina
            bnez    t8, _end                // if not stamina, skip
            nop
            li      a0, TOTAL_HP
            lw      a0, 0x0000(a0)          // a0 = hp value

            _end:
            jr      ra
            sh      t9, 0x0024(v1)          // original line 1
        }
    }
}

} // __STAMINA__
