// @ Description
// These constants must be defined for a menu item.
define LABEL("Dpad map")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(3)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(DpadFunctions.dpad_macro_table)
constant ONCHANGE_HANDLER(0)
constant DISABLES_HIGH_SCORES(OS.TRUE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_off
dw string_smash
dw string_tilt
dw string_special

// @ Description
// Value labels
string_off:; String.insert("Off")
string_smash:; String.insert("Smash")
string_tilt:; String.insert("Tilt")
string_special:; String.insert("Special")

// @ Description
// Hook into routine that writes Joypad bitmask to player struct (non-cpu players)
// Handles Dpad Macros and Controls
// a3 = Joypad input bitmask
scope dpad_macro_check_: {
    OS.patch_start(0x5CB30, 0x800E1330)
    j       dpad_macro_check_
    nop
    _return:
    OS.patch_end()

    // a2 is player struct
    // a0 is controller struct with port offset (safe to edit)
    // t4, t5, t9 is safe to edit
    // a3 = button pressed bitmask
    // v1 = output bitmask

    _check_dpad_controls:
    li      t4, DpadControl.dpad_controls_table // t4 = dpad controls table
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t4, t4, at              // t4 = player entry in dpad_controls_table
    lw      at, 0x0000(t4)          // at = players value in table

    beqz    at, _check_dpad_macros  // branch if it's disabled for this port
    nop

    li      t5, stick_swap_flag     // t5 = address of stick swap flag
    sw      r0, 0x0000(t5)          // clear flag (just in case)

    // Dpad 'Stick Swap' needs some setup to adjust button bitmask (generate via stick)
    andi    t4, at, 0x0001          // t4 = 1 if (Stick Swap) or (Stick Swap J)
    bnezl   t4, _dpad_macro_move_setup // branch accordingly
    sw      t4, 0x0000(t5)          // stick_swap_flag = 1 (using dpad as stick)

    // Dpad 'Stickless' can use button bitmask as-is
    addiu   t4, r0, 0x0002          // t4 = 2 (Stickless)
    beql    at, t4, _dpad_macro_move// branch accordingly
    or      a0, r0, a3              // a0 = a3 (button pressed bitmask)
    addiu   t4, r0, 0x0004          // t4 = 4 (Stickless J)
    beql    at, t4, _dpad_macro_move// branch accordingly
    or      a0, r0, a3              // a0 = a3 (button pressed bitmask)

    b        _check_dpad_macros    // if none of above, proceed normally (safety branch)
    nop

    _dpad_macro_move_return:
    li      t4, stick_swap_flag     // t4 = address of stick swap flag
    lw      at, 0x0000(t4)          // at = value of stick_swap_flag (0 if Stickless)
    beqz    at, _normal             // skip below unless we're using dpad as stick
    sw      r0, 0x0000(t4)          // zero out stick swap flag

    _check_dpad_macros:
    li      t4, dpad_macro_table    // t4 = dpad macro table
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t4, t4, at              // t4 = player entry in dpad_macro_table
    lw      at, 0x0000(t4)          // at = players value in table

    beqz    at, _normal             // proceed normally if it's disabled for this port
    nop

    // check if Training, and only allow macros if "D-pad Controls" shortcuts are 'OFF'
    li      t9, Global.current_screen
    lbu     t9, 0x0000(t9)          // t9 = current screen
    lli     t4, Global.screen.TRAINING_MODE
    bne     t4, t9, _check_macro_type
    nop
    li      t9, Training.entry_dpad_menu
    lw      t9, 0x0004(t9)          // t9 = 2 if dpad menu is off
    lli     t4, 0x0002              // t1 = dpad menu options disabled
    bne     t9, t4, _normal         // don't check dpad presses unless dpad menu is off
    nop

    _check_macro_type:
    addiu   t4, r0, 0x0002          // t4 = 2 (Tilt)
    beq     at, t4, _dpad_macro_tilt// branch accordingly
    nop

    andi    t4, a3, 0x0F00          // at = 0 if dpad isn't down
    beqz    t4, _normal             // branch if dpad is not down

    addiu   t4, r0, 0x0001          // t4 = 1 (Smash)
    beq     at, t4, _check_usmash   // branch accordingly
    nop

    lh      t4, 0x0000(v0)          // get current button held value
    andi    t4, t4, 0x0F00          // check if holding DPAD
    bnez    t4, _normal             // skip if holding DPAD was just pressed last frame

    addiu   t4, r0, 0x0003          // t4 = 3 (Special)
    beql    at, t4, _add_stick_input// branch accordingly
    ori     v1, a3, 0x4000          // add B press to bitmasks

    b        _normal                // if none of above, proceed normally (safety branch)
    nop

    // check if jumpsquat into usmash
    _check_usmash:
    andi   at, a3, Joypad.DU        // check if dpad up pressed
    beqz   at, _smash_other         // branch if not inputting dpad up
    nop

    // usmash
    lw      at, 0x0024(a2)          // get current action id
    lli     t4, Action.Dash
    beq     at, t4, _add_c_jump     // input jump if dashing
    lli     t4, Action.Run
    beq     at, t4, _add_c_jump     // input jump if running
    nop
    lli     t4, Action.JumpSquat
    beq     at, t4, _smash_input    // input A if jumpsquat
    nop

    _smash_other:
    lh      t4, 0x0000(v0)          // get current button held value
    andi    t4, t4, 0x0F00          // check if holding DPAD D, L, R
    bnez    t4, _normal             // skip if holding DPAD was just pressed last frame
    nop

    _smash_input:
    ori     v1, a3, Joypad.A        // If here, add A press
    _add_stick_input:
    andi    t4, a3, Joypad.DU       // check if pressing up
    bnez    t4, _overwrite
    lli     t4, 0x0050              // t4 = max stick Y value
    andi    t4, a3, Joypad.DD
    bnez    t4, _overwrite
    lli     t4, 0x00B0              // t4 = min stick Y value
    andi    t4, a3, Joypad.DL
    bnez    t4, _overwrite
    lli     t4, 0xB000              // t4 = min stick X value
    andi    t4, a3, Joypad.DR
    bnez    t4, _overwrite
    lli     t4, 0x5000              // t4 = max stick X value

    _add_c_jump:
    b       _normal
    ori     v1, a3, Joypad.CU       // add player jump if in jumpsquat

    _dpad_macro_tilt:
    // check if we need to finish a turning tilt
    li      t9, dpad_turn_tilt      // t9 = dpad turn tilt value
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t9, t9, at              // t9 = player entry in dpad_turn_tilt
    lh      at, 0x0000(t9)          // t9 = players value in dpad_turn_tilt
    beqz    at, _check_dpad_tilt
    lw      at, 0x0024(a2)          // get current action id
    lli     t4, Action.Turn         // t4 = Action.Turn
    bnel    at, t4, _check_dpad_tilt// if the player is not turning, abort
    sh      r0, 0x0000(t9)          // clear flag
    lw      at, 0x001C(a2)          // get current frame of current action
    addiu   t4, r0, 0x0005
    blt     at, t4, _check_dpad_tilt// if frame of turning is less than 5, abort
    nop
    // if we've reached this point, we're good to go
    lh      t4, 0x0000(t9)          // at = players value in dpad_turn_tilt
    sh      r0, 0x0000(t9)          // clear flag
    ori     v1, a3, Joypad.A        // If here, add A press
    b      _overwrite
    nop

    _check_dpad_tilt:
    andi    t4, a3, 0x0F00          // at = 0 if dpad isn't down
    beqz    t4, _normal             // branch if dpad is not down
    nop
    lh      t4, 0x0000(v0)          // get current button held value
    andi    t4, t4, 0x0F00          // check if holding DPAD
    bnez    t4, _normal             // skip if holding DPAD was just pressed last frame

    lw      at, 0x0024(a2)          // get current action id
    lli     t4, Action.Run          // t4 = Action.Run
    beql    at, t4, pc() + 12       // don't try and turn while running
    addiu   t9, r0, 0x0003          // t9 = 3 (so criteria can't be met)
    // otherwise, if the player taps the opposite direction that they are facing, we need to turn them around
    lw      t9, 0x0044(a2)          // t9 = player facing direction (-1 = left, 1 = right)

    andi    t4, a3, Joypad.DU       // check if pressing up
    bnez    t4, _tilt_pressed
    lli     t4, 0x0028              // t4 = halfway max stick Y value
    andi    t4, a3, Joypad.DD
    bnez    t4, _tilt_pressed
    lli     t4, 0x00D8              // t4 = halfway min stick Y value

    andi    at, a3, Joypad.DL
    lli     t4, 0xD800              // t4 = halfway min stick X value
    bnezl   at, _tilt_pressed
    addiu   t9, t9, -0x0001

    andi    at, a3, Joypad.DR
    lli     t4, 0x2800              // t4 = halfway max stick X value
    beqz    at, _normal             // if none of above, proceed normally (safety branch)
    addiu   t9, t9, 0x0001

    _tilt_pressed:
    // if the player is in the air, don't do direction check
    lw      at, 0x014C(a2)          // at = 0 (ground) or 1 (air)
    bnez    at, _tilt_A_press       // use this instead, if airborne
    nop
    beqz    t9, _turn_and_tilt      // branch if pressing in opposite direction
    nop
    andi    at, a3, 0x0300          // at = 1 if pressed DL or DR
    bnez    at, _tilt_A_press       // skip dash check if pressing in same direction as you're moving
    nop
    lw      at, 0x0024(a2)          // get current action id
    lli     t9, Action.Dash         // t9 = Action.Dash
    beq     at, t9, _turn_and_tilt  // tilt out of dash
    nop

    _tilt_A_press:
    ori     v1, a3, 0x8000          // add A press to bitmasks
    b       _overwrite
    nop

    _turn_and_tilt:
    li      t9, dpad_turn_tilt      // t9 = dpad turn tilt value
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t9, t9, at              // t9 = player entry in dpad_turn_tilt
    sh      t4, 0x0000(t9)          // t9 = store direction value to dpad turn tilt value

    lw      t9, 0x0044(a2)          // t9 = player facing direction (-1 = left, 1 = right)
    bgtzl   t9, pc() + 12
    lli     t4, 0xC400              // t4 = more-than-halfway min stick X value (turn left)
    lli     t4, 0x3C00              // t4 = more-than-halfway max stick X value (turn right)

    b       _overwrite
    nop

    // constant DU(0x0800)
    // constant DD(0x0400)
    // constant DL(0x0200)
    // constant DR(0x0100)
    // a0 is a simulated button pressed bitmask (instead of a3) with dpad inputs generated via stick values and visa versa
    _dpad_macro_move_setup:
    or      t4, r0, a0              // t4 = a0 (controller struct with port offset)
    andi    a0, a3, 0xF0FF          // remove pressed dpad input
    lb      at, 0x0008(t4)          // stick X value
    beqz    at, check_up_down
    andi    at, at, 0xFF00          // t6 = 0 if stick left, otherwise stick right
    beqzl   at, pc() + 12
    ori     a0, a0, Joypad.DR       // a0 = pressed button mask + Joypad.DR
    ori     a0, a0, Joypad.DL       // ~
    sb      r0, 0x0008(t4)          // zero out stick X (just in case?)

    check_up_down:
    lb      at, 0x0009(t4)          // stick Y value
    beqz    at, _dpad_macro_move
    andi    at, at, 0xFF00          // t6 = 0 if stick up, otherwise stick down
    beqzl   at, pc() + 12
    ori     a0, a0, Joypad.DU       // a0 = pressed button mask + Joypad.DU
    ori     a0, a0, Joypad.DD       // ~
    sb      r0, 0x0009(t4)          // zero out stick Y

    _dpad_macro_move:
    andi    at, a0, 0x0F00          // at = 0 if dpad isn't down
    bnez    at, _no_move_countdown  // branch if dpad is down
    nop
    // count down timer if dpad not pressed
    li      t4, dpad_move_timer     // t4 = dpad movement timer
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t4, t4, at              // t4 = player entry in dpad_move_timer
    lw      at, 0x0000(t4)          // at = timer value in table
    addiu   at, at, -0x00001        // decrement timer
    bgezl   at, pc() + 8            // update timer value (if non-negative)
    sw      at, 0x0000(t4)          // at = timer value in table
    b       _dpad_macro_move_return
    nop

    _no_move_countdown:
    li      t4, dpad_move_timer     // t4 = dpad movement timer
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t4, t4, at              // t4 = player entry in dpad_move_timer
    lw      t9, 0x0000(t4)          // t9 = timer value in table

    addiu   at, r0, 0x000A          // at = 10 (frame window for double tap)
    beqzl   t9, pc() + 8            // if timer equal to 0 (not started), use partial stick values
    or      t9, r0, at              // t9 = 10
    slti    t9, t9, 0x000A          // t9 = 1 if timer is less than 10 (checking for double tap)
    subu    at, at, t9              // set timer value in table to 10 (or 9 if already active)
    sw      at, 0x0000(t4)          // ~

    // Clear timer if Walk3 is held down long enough (less double tap false positives)
    lw      at, 0x0024(a2)          // get current action id
    lli     t5, Action.Walk3        // t5 = Action.Walk3
    bne     at, t5, _dpad_move_check// branch if the player is not in Walk3
    lw      at, 0x001C(a2)          // get current frame of current action
    slti    at, at, 0x0010          // at = 1 if frame of Walk3 is less than 16
    bnez    at, _dpad_move_check    // if we haven't Walked for at least 16 frames, skip clearing timer
    nop
    sw      r0, 0x0000(t4)          // t4 = dpad movement timer (set to 0)
    addiu   t9, r0, 0x0001          // t9 = 1, so we use full stick values (even though tap timer is reset)

    _dpad_move_check:
    or      t4, r0, r0              // clear t4
    andi    at, a0, 0x0C00          // at = 0 if not pressing Joypad.DU or Joypad.DD
    beqz    at, _dpad_move_checked_down
    nop
    _dpad_move_check_special_character:
    lw      at, 0x0008(a2)                       // get current character id
    lli     t5, Character.id.FOX
    beq     at, t5, _dpad_move_check_action_spacies // branch if relevant character...
    lli     t5, Character.id.FALCO
    beq     at, t5, _dpad_move_check_action_spacies
    lli     t5, Character.id.WOLF
    beq     at, t5, _dpad_move_check_action_spacies
    lli     t5, Character.id.MTWO
    beq     at, t5, _dpad_move_check_action_m2
    // WIP (maybe he's fine as-is?)
    // lli     t5, Character.id.PIKACHU
    // beq     at, t5, _dpad_move_check_action_pika
    lli     t5, Character.id.PEPPY
    bne     at, t5, _dpad_move_check_up          // ...otherwise skip checking special action
    _dpad_move_check_action_spacies:
    lw      at, 0x0024(a2)                       // get current action id (spacies share these FOX action values)
    sltiu   t5, at, Action.FOX.LaserAir          // branch if action is less than FOX.LaserAir
    bnez    t5, _dpad_move_check_up
    lli     t5, Action.FOX.ReadyingFireFox       // t5 = Action.FOX.ReadyingFireFox (0xE5)
    beq     at, t5, _dpad_move_check_special
    lli     t5, Action.FOX.ReadyingFireFoxAir    // t5 = Action.FOX.ReadyingFireFoxAor (0xE6)
    beq     at, t5, _dpad_move_check_special
    lli     t5, Action.FOX.FireFoxStart          // t5 = Action.FOX.FireFoxStart (0xE3)
    beq     at, t5, _dpad_move_check_special
    lli     t5, Action.FOX.FireFoxStartAir       // t5 = Action.FOX.FireFoxStartAir (0xE4)
    bne     at, t5, _dpad_move_check_up          // branch if current action id didn't match any of the above
    _dpad_move_check_action_pika:
    lli     t5, Action.PIKACHU.QuickAttackStart  // t5 = Action.PIKACHU.QuickAttackStart
    beq     at, t5, _dpad_move_check_special
    // lli     t5, Action.PIKACHU.QuickAttack       // t5 = Action.PIKACHU.QuickAttack
    // beq     at, t5, _dpad_move_check_special
    lli     t5, Action.PIKACHU.QuickAttackEnd    // t5 = Action.PIKACHU.QuickAttackEnd
    beq     at, t5, _dpad_move_check_special
    lli     t5, Action.PIKACHU.QuickAttackStartAir // t5 = Action.PIKACHU.QuickAttackStartAir
    beq     at, t5, _dpad_move_check_special
    // lli     t5, Action.PIKACHU.QuickAttackAir    // t5 = Action.PIKACHU.QuickAttackAir
    // beq     at, t5, _dpad_move_check_special
    lli     t5, Action.PIKACHU.QuickAttackEndAir // t5 = Action.PIKACHU.QuickAttackEndAir
    bne     at, t5, _dpad_move_check_up
    _dpad_move_check_action_m2:
    lw      at, 0x0024(a2)                       // get current action id
    lli     t5, Mewtwo.Action.TeleportStart      // t5 = Mewtwo.Action.TeleportStart
    beq     at, t5, _dpad_move_check_special
    lli     t5, Mewtwo.Action.TeleportStartAir   // t5 = Mewtwo.Action.TeleportStartAir
    beq     at, t5, _dpad_move_check_special
    nop

    _dpad_move_check_up:
    andi    at, a0, Joypad.DU       // check if pressing up
    beqz    at, _dpad_move_check_down
    lw      at, 0x014C(a2)          // at = 0 (ground) or 1 (air)
    bnezl   at, pc() + 12           // if the player is in the air, use appropriate stick value
    addiu   t4, t4, 0x0028          // add halfway max stick Y value
    addiu   t4, t4, 0x0050          // add max stick Y value

    _dpad_move_check_down:
    andi    at, a0, Joypad.DD       // check if pressing down
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x00B0          // add min stick Y value
    bnez    t9, _dpad_move_full     // use full horizontal stick range if tapped twice
    nop
    b       _check_for_platform     // otherwise check to see if we're on a platform
    nop

    _dpad_move_check_special:
    andi    at, a0, Joypad.DU       // check if pressing up
    beqz    at, _dpad_move_checked_special_up
    _dpad_move_check_b:
    andi    at, a0, Joypad.B        // check if holding B
    bnezl   at, pc() + 12           // if the player is holding B, use appropriate stick value
    addiu   t4, t4, 0x0028          // add halfway max stick Y value
    addiu   t4, t4, 0x0050          // add max stick Y value
    b   _dpad_move_checked_down
    nop
    // if we're here, we pressed dpad down
    _dpad_move_checked_special_up:
    bnezl   at, pc() + 12           // if the player is holding B, use appropriate stick value
    addiu   t4, t4, 0x00D8          // add halfway min stick Y value
    addiu   t4, t4, 0x00B0          // add min stick Y value
    b   _dpad_move_checked_down
    nop

    _check_for_platform:
    lw      at, 0x0024(a2)          // get current action id
    lli     t5, Action.CrouchIdle   // t5 = Action.CrouchIdle
    beq     at, t5, _dpad_move_checked_down // branch if the player is in CrouchIdle
    nop
    sltiu   at, at, Action.DamageHigh1  // branch if action is not less than damage high
    beqz    at, _dpad_move_checked_down
    nop

    lh      at, 0x00F0(a2)          // at = distance from Platform directly under character
    bnez    at, _dpad_move_checked_down
    nop
    lh      at, 0x00F6(a2)          // current clipping flag (surface id)
    andi    at, at, 0x4000          // t5 = 4000 (soft platform)
    beqz    at, _dpad_move_checked_down // skip if not a soft platform
    nop

    lli     t5, 0x8000              // t5 = 8000 (solid platform)
    sh      t5, 0x00F6(a2)          // temporarily overwrite clipping flag so we can crouch (takes 3 frames)

    _dpad_move_checked_down:
    bnez    t9, _dpad_move_full     // use full horizontal stick range if tapped twice
    nop

    // Check if they press A button (allows Fsmash on Idle or frame 1 of Walk2)
    andi    at, a0, 0x8000          // at = 1 if A pressed
    bnez    at, _dpad_move_full     // branch accordingly
    nop

    _facilitate_walk3:
    // This lets us reach Walk3 while holding down dpad (when not tapping twice)
    lw      at, 0x0024(a2)          // get current action id
    slti    t9, at, 0x00DC          // t9 = 1 if action is less than 0x00DC (non-character-specific)
    beqz    t9, _dpad_move_full     // branch if using special moves etc
    nop
    lli     t9, Action.Shield       // t9 = Action.Shield
    beq     at, t9, _dpad_move_full // branch if the player is shielding (so they can roll)
    nop
    lli     t9, Action.Walk2        // t9 = Action.Walk2
    bne     at, t9, _dpad_move_partial// if the player is not walking, abort
    lw      at, 0x001C(a2)          // get current frame of current action
    slti    t9, at, 0x0003          // t9 = 1 if frame is less than 3 (non-character-specific)
    bnez    t9, _dpad_move_partial  // if frame of Walk2 is not greater than 2, abort
    nop
    // If we're here, we need to sync timer with stick
    li      t9, dpad_move_timer     // t9 = dpad movement timer
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t9, t9, at              // t9 = player entry in dpad_move_timer
    addiu   at, r0, 0x0009          // at = 9
    sw      at, 0x0000(t9)          // t9 = timer value in table

    b       _dpad_move_full
    nop

    _dpad_move_partial:
    andi    at, a0, Joypad.DL
    bnezl   at, pc() + 8
    addiu   t4, t4, 0xD800          // add halfway min stick X value
    andi    at, a0, Joypad.DR
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x2800          // add halfway max stick X value

    b       _dpad_macro_move_return
    sh      t4, 0x01C2(a2)          // overwrite stick input

    _dpad_move_full:
    andi    at, a0, Joypad.DL
    bnezl   at, pc() + 8
    addiu   t4, t4, 0xB000          // add min stick X value
    andi    at, a0, Joypad.DR
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x5000          // add max stick X value

    // 'Turn Tap' handler (double tapping to dash gets buffered, so not eaten up)
    andi    at, a0, 0xC000          // check if pressing A or B
    bnez    at, _dpad_move_end      // skip centering stick if A or B is held (e.g. Fsmash)
    lw      at, 0x0024(a2)          // get current action id
    lli     t9, Action.Turn         // t9 = Action.Turn
    bne     at, t9, _dpad_move_end  // if the player is not turning, continue as normal
    lw      at, 0x001C(a2)          // get current frame of current action
    addiu   t9, r0, 0x000A          // t9 = 10
    beql    at, t9, pc() + 8        // if frame of turning is 10, center stick horizontally
    andi    t4, t4, 0x00FF          // t4 = Y stick value (X is zeroed out)

    _dpad_move_end:
    b       _dpad_macro_move_return
    sh      t4, 0x01C2(a2)          // overwrite stick input

    _overwrite:
    sh      t4, 0x01C2(a2)          // overwrite stick input
    ori     a3, a3, 0x8000          // ~

    // original logic
    _normal:
    beqz    t8, _normal_return
    nop

    j       0x800E133C              // this branch is taken
    lhu     t9, 0x0002(v0)

    _normal_return:
    j       0x800E134C              // original line 1
    sh      v1, 0x0002(v0)          // original line 2

}

// @ Description
// Runs before Training mode to ensure settings aren't applied.
scope clear_settings_for_training_: {
    addiu   sp, sp, -0x0010                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~

    li      t0, dpad_macro_table            // t0 = dpad_macro_table address
    sw      r0, 0x0000(t0)                  // clear dpad state 1p
    sw      r0, 0x0004(t0)                  // clear dpad state 2p
    sw      r0, 0x0008(t0)                  // clear dpad state 3p
    sw      r0, 0x000C(t0)                  // clear dpad state 4p

    lw      t0, 0x0004(sp)
    lw      t1, 0x0008(sp)
    addiu   sp, sp, 0x0010                  // deallocate stack space
    jr      ra
    nop
}



dpad_macro_table:
dw  0
dw  0
dw  0
dw  0

dpad_turn_tilt:
dh  0x0000
dh  0x0000
dh  0x0000
dh  0x0000

stick_swap_flag:
dw  0

dpad_move_timer:
dw  0
dw  0
dw  0
dw  0
