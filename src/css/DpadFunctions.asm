// @ Description
// These constants must be defined for a menu item.
define LABEL("Dpad map")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(4)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b110111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(DpadFunctions.dpad_macro_table)
constant ONCHANGE_HANDLER(0)

// @ Description
// Holds pointers to value labels
string_table:
dw string_off
dw string_smash
dw string_tilt
dw string_special
dw string_move

// @ Description
// Value labels
string_off:; String.insert("Off")
string_smash:; String.insert("Smash")
string_tilt:; String.insert("Tilt")
string_special:; String.insert("Special")
string_move:; String.insert("Movement")

// @ Description
// Hook into routine that writes Joypad bitmask to player struct (non-cpu players)
// a3 = Joypad input bitmask
scope dpad_macro_check_: {
    OS.patch_start(0x5CB30, 0x800E1330)
    j       dpad_macro_check_
    nop
    _return:
    OS.patch_end()

    li      t4, dpad_macro_table    // t4 = dpad macro table
    lb      at, 0x000D(a2)          // at = player port
    sll     at, at, 0x0002          // at = offset
    addu    t4, t4, at              // t4 = player entry in dpad_macro_table
    lw      at, 0x0000(t4)          // at = players value in table

    beqz    at, _normal             // proceed normally if it's disabled for this port
    nop

    // a2 is player struct
    // t4, t5, t9 is safe to edit
    // a3 = button pressed bitmask
    // v1 = output bitmask

    // check which type of macro is enabled
    addiu   t4, r0, 0x0004          // t4 = 4 (Movement)
    beq     at, t4, _dpad_macro_move// branch accordingly
    nop
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
    lli     t4, Action.Run          // t9 = Action.Turn
    beql    at, t4, pc() + 12       // don't try and turn while running
    addiu   t9, r0, 0x0003          // t9 = 3 (so criteria can't be met)
    // otherwise, if the player taps the opposite direction that they are facing, we need to turn them around
    lw      t9, 0x0044(a2)          // t1 = player facing direction (-1 = left, 1 = right)

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

    lw      t9, 0x0044(a2)          // t1 = player facing direction (-1 = left, 1 = right)
    bgtzl   t9, pc() + 12
    lli     t4, 0xC400              // t4 = more-than-halfway min stick X value (turn left)
    lli     t4, 0x3C00              // t4 = more-than-halfway max stick X value (turn right)

    b       _overwrite
    nop

    _dpad_macro_move:
    andi    at, a3, 0x0F00          // at = 0 if dpad isn't down
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
    b       _normal
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
    bnez    at, _dpad_move_check    // if we haven't Walk3d for at least 16 frames, skip clearing timer
    nop
    sw      r0, 0x0000(t4)          // t4 = dpad movement timer (set to 0)
    addiu   t9, r0, 0x0001          // t9 = 1, so we use full stick values (even though tap timer is reset)

    _dpad_move_check:
    or      t4, r0, r0              // clear t4

    andi    at, a3, Joypad.DU       // check if pressing up
    beqz    at, _dpad_move_checked_up
    lw      at, 0x014C(a2)          // at = 0 (ground) or 1 (air)
    bnezl   at, pc() + 12           // if the player is in the air, use appropriate stick value
    addiu   t4, t4, 0x0028          // add halfway max stick Y value
    addiu   t4, t4, 0x0050          // add max stick Y value

    _dpad_move_checked_up:
    andi    at, a3, Joypad.DD       // check if pressing down
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x00B0          // add min stick Y value

    bnez    t9, _dpad_move_full     // use full horizontal stick range if tapped twice
    nop

    // This lets us reach Walk3 while holding down dpad (when not tapping twice)
    lw      at, 0x0024(a2)          // get current action id
    slti    t9, at, 0x00DC          // t9 = 1 if action is less than 0x00DC (non-character-specific)
    beqz    t9, _dpad_move_full     // branch if using special moves etc
    nop
    lli     t9, Action.Walk2        // t9 = Action.Walk2
    bne     at, t9, _dpad_move_partial// if the player is not walking, abort
    lw      at, 0x001C(a2)          // get current frame of current action
    addiu   t9, r0, 0x0002
    ble     at, t9, _dpad_move_partial// if frame of Walk2 is not greater than 2, abort
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
    andi    at, a3, Joypad.DL
    bnezl   at, pc() + 8
    addiu   t4, t4, 0xD800          // add halfway min stick X value
    andi    at, a3, Joypad.DR
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x2800          // add halfway max stick X value

    b       _normal
    sh      t4, 0x01C2(a2)          // overwrite stick input

    _dpad_move_full:
    andi    at, a3, Joypad.DL
    bnezl   at, pc() + 8
    addiu   t4, t4, 0xB000          // add min stick X value
    andi    at, a3, Joypad.DR
    bnezl   at, pc() + 8
    addiu   t4, t4, 0x5000          // add max stick X value

    // 'Turn Tap' handler (double tapping to dash gets buffered, so not eaten up)
    andi    at, a3, 0xC000          // check if pressing A or B
    bnez    at, _dpad_move_end      // skip centering stick if A or B is held (e.g. Fsmash)
    lw      at, 0x0024(a2)          // get current action id
    lli     t9, Action.Turn         // t9 = Action.Turn
    bne     at, t9, _dpad_move_end  // if the player is not turning, continue as normal
    lw      at, 0x001C(a2)          // get current frame of current action
    addiu   t9, r0, 0x000A          // t9 = 10
    beql    at, t9, pc() + 8        // if frame of turning is 10, center stick horizontally
    andi    t4, t4, 0x00FF          // t4 = Y stick value (X is zeroed out)

    _dpad_move_end:
    b       _normal
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

// @ Description
// Disables setting shield button mask yet (moved after Joystick.set_taunt_mask_)
scope dont_set_shield_mask_: {
    OS.patch_start(0x53CB8, 0x800D84B8)
    nop                     // original line 1 was: sh t5, 0x01B8(s5)
    OS.patch_end()
}

// @ Description
// Overrides button mask for shield per port when Dpad is mapped to 'Movement'.
scope set_shield_mask_: {
    OS.patch_start(0x53CF0, 0x800D84F0)
    jal     set_shield_mask_
    nop
    OS.patch_end()

    li      t3, dpad_macro_table    // t3 = dpad macro table
    lb      t8, 0x000D(s5)          // t8 = player port
    sll     t8, t8, 0x0002          // t8 = offset
    addu    t3, t3, t8              // t3 = address of shield mask index
    lw      t8, 0x0000(t3)          // t8 = players value in table

    // skip check if in Training mode (we don't use dpad there)
    li      t3, Global.current_screen   // ~
    lbu     t3, 0x0000(t3)              // t3 = screen_id
    addiu   t3, t3, -0x0036             // t3 = 0 if training
    beqzl   t3, _end                    // skip if screen_id = training mode
    lli     t3, Joypad.Z                // t3 = Joypad.Z

    addiu   t3, r0, 0x0004          // t3 = 4 (Movement)
    bnel    t8, t3, _end            // if not using Dpad Movement, then use default mask
    lli     t3, Joypad.Z            // t3 = Joypad.Z

    // my code runs first.. so i need an alternative approach (actually just reordered them)
    // check if using custom 'Taunt Btn', and leave Z mapped as Shield if so (otherwise map Z as Taunt)
    li      t8, Joypad.taunt_mask_per_port
    lbu     t3, 0x000D(s5)          // t3 = port
    sll     t3, t3, 0x0002          // t3 = offset
    addu    t8, t8, t3              // t8 = address of taunt mask index
    lw      t8, 0x0000(t8)          // t8 = taunt mask index

    bnezl   t8, _end                // if not 0, then it's not set to default taunt button
    addiu   t3, r0, 0x2020          // t3 = 0x0020 (Joypad.L) + 0x2000 (Joypad.Z)

    lli     t3, Joypad.L            // t3 = Joypad.L
    lli     t8, Joypad.Z            // t8 = Joypad.Z
    sh      t8, 0x01BA(s5)          // t4 = taunt mask (override)

    _end:
    sh      t3, 0x01B8(s5)          // set shield button mask
    lw      t8, 0x0104(v1)          // original line 1
    addiu   a2, v1, 0x011C          // original line 2
    jr      ra
    nop
}

// @ Description
// Overrides button macro for R per port when Dpad is mapped to 'Movement'.
scope set_R_macro: {
    OS.patch_start(0x5CAFC, 0x800E12FC)
    jal     set_R_macro
    nop
    _return:
    OS.patch_end()

    li      t4, dpad_macro_table    // t4 = dpad macro table
    lb      t6, 0x000D(a2)          // t6 = player port
    sll     t6, t6, 0x0002          // t6 = offset
    addu    t4, t4, t6              // t4 = address of shield mask index
    lw      t6, 0x0000(t4)          // t6 = players value in table

    addiu   t4, r0, 0x0004          // t4 = 4 (Movement)
    bnel    t6, t4, pc() + 12       // if not using Dpad Movement, set default macro for R (Z+A)
    ori     a3, a1, 0xA000          // original line 1
    ori     a3, a1, 0x8020          // a3 = 0x0020 (Joypad.L) + 0x8000 (Joypad.A)

    _end:
    andi    a3, a3, 0xFFFF          // original line 2
    jr      ra
    nop
}

    // @ Description
    // Hijacks the controller struct writing routine to allow for dpad cursor control on VS CSS (req. for dpad map 'movement')
    // Has a short hold timer to prevent accidental movement by stick users when tapping dpad to set a variant
    // a1 = port
    // a3 = 0x80045228 = Joypad.struct
    // v0 = current port controller struct
    // t3 = xpos
    // t4 = ypos
    scope css_dpad_cursor_control_: {
        OS.patch_start(0x4C00, 0x80004000)
        jal     css_dpad_cursor_control_
        nop
        OS.patch_end()

        // t5, t6, a0 safe to edit

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        li      t5, Global.current_screen
        lbu     t6, 0x0000(t5)          // t6 = current screen
        addiu   t5, r0, 0x0012          // t5 = training screen_id
        beq     t5, t6, _end            // branch if we're on training CSS screen
        nop
        sltiu   t5, t6, 0x0010          // t5 = 0 if < 10
        bnez    t5, _end                // branch if we're not on a CSS screen
        nop
        slti    t5, t6, 0x0015          // t5 = 1 if < 15
        beqz    t5, _end                // branch if we're not on a CSS screen
        nop

        // check if dpad is being pressed
        lh      t5, 0x0000(v0)          // get current button held value
        andi    t5, t5, 0x0F00          // t5 = 0 if dpad isn't down
        li      a0, dpad_css_cursor_timer // a0 = dpad_css_cursor_timer
        sll     t6, a1, 0x0002          // t6 = offset
        addu    a0, a0, t6              // a0 = player entry in dpad_move_timer
        bnez    t5, _check_dpad_css_timer // branch if any dpad buttons are held, otherwise reset timer
        nop

        addiu   t6, r0, 30              // t6 = 30
        sw      t6, 0x0000(a0)          // save updated timer
        b      _end
        nop

        _check_dpad_css_timer:
        lw      t6, 0x0000(a0)          // t6 = dpad_css_cursor_timer value
        beqz    t6, _check_dpad_buttons // branch if we've held dpad long enough and/or token criteria was already met
        nop

        // check if token is already placed or we're not hovering over a character (in which case we disregard timer)
        // CSS modes don't all have same offsets so we need to do some setup first
        li      t5, Global.current_screen
        lbu     t6, 0x0000(t5)          // t6 = current screen
        addiu   t5, r0, 0x0010          // t5 = vs screen_id
        beq     t6, t5, _check_token_state_vs
        nop
        addiu   t5, r0, 0x0012          // t5 = training screen_id
        beq     t6, t5, _check_token_state_train
        nop

        // if we're here, then screen_id is 1p, bonus1, or bonus2
        li      t5, CharacterSelect.css_player_structs
        addiu   t6, t6, -0x0010         // t6 = screen_id - 10
        sll     t6, t6, 0x0002          // t6 = offset
        addu    t5, t5, t6              // t5 = entry in css_player_struct
        lw      t5, 0x0000(t5)          // t5 = address of css player structure for current screen
        b       _check_token_state_1p   // branch to check token state (non-VS)
        nop

        _check_token_state_train:
        li      t5, CharacterSelect.CSS_PLAYER_STRUCT_TRAINING // t5 = Training CSS Panel Struct, p1
        addiu   t6, r0, 0x00B8          // t6 = size of Training CSS Panel Struct (note: different from VS's)
        multu   t6, a1                  // mflo = offset to port's panel struct
        mflo    t6                      // t6 = offset to ports panel struct
        addu    t5, t5, t6              // t5 = port's Training CSS Panel Struct

        _check_token_state_1p:
        lw      t6, 0x007C(t5)          // t6 = held token index (offset for non-VS)
        bltzl   t6, _check_dpad_buttons // if not holding token, skip
        sw      r0, 0x0000(a0)          // a0 = dpad_css_cursor_timer (set to 0)
        lw      t6, 0x0048(t5)          // t6 = selected char_id
        lli     t5, Character.id.NONE   // t5 = Character.id.NONE
        beql    t6, t5, _check_dpad_buttons // if not hovering over a char, skip
        sw      r0, 0x0000(a0)          // a0 = dpad_css_cursor_timer (set to 0)

        b       _update_dpad_css_timer
        nop

        _check_token_state_vs:
        li      t5, CharacterSelect.CSS_PLAYER_STRUCT // t5 = VS CSS Panel Struct, p1
        addiu   t6, r0, 0x00BC          // t6 = size of VS CSS Panel Struct
        multu   t6, a1                  // mflo = offset to port's panel struct
        mflo    t6                      // t6 = offset to ports panel struct
        addu    t5, t5, t6              // t5 = port's VS CSS Panel Struct
        lw      t6, 0x0080(t5)          // t6 = held token index (offset for VS)

        // check token and branch accordingly
        bltzl   t6, _check_dpad_buttons // if not holding token, skip
        sw      r0, 0x0000(a0)          // a0 = dpad_css_cursor_timer (set to 0)
        lw      t6, 0x0048(t5)          // t6 = selected char_id
        lli     t5, Character.id.NONE   // t5 = Character.id.NONE
        beql    t6, t5, _check_dpad_buttons // if not hovering over a char, skip
        sw      r0, 0x0000(a0)          // a0 = dpad_css_cursor_timer (set to 0)

        // if we're here, we are hovering over a character in CSS with token in hand
        _update_dpad_css_timer:
        lw      t6, 0x0000(a0)         // t6 = dpad_css_cursor_timer value
        addiu   t6, t6, -0x0001        // t6--
        bgtz    t6, _end               // branch if timer has not yet reached zero
        sw      t6, 0x0000(a0)         // save updated timer

        // note: full stick values of 81 min and 7F max is too fast, so we use partial
        _check_dpad_buttons:
        lh      t5, 0x0000(v0)          // get current button held value
        andi    t6, t5, Joypad.DL       // t6 = 1 if dpad left pressed
        bnezl   t6, pc() + 8
        addiu   t3, r0, 0xD0            // t3 = partial min stick X value
        andi    t6, t5, Joypad.DR       // t6 = 1 if dpad right pressed
        bnezl   t6, pc() + 8
        addiu   t3, r0, 0x30            // t3 = partial max stick X value
        andi    t6, t5, Joypad.DD       // t6 = 1 if dpad down pressed
        bnezl   t6, pc() + 8
        addiu   t4, r0, 0xD0            // t4 = partial max stick Y value
        andi    t6, t5, Joypad.DU       // t6 = 1 if dpad up pressed
        bnezl   t6, pc() + 8
        addiu   t4, r0, 0x30            // t4 = partial min stick Y value

        _end:
        sh      t1, 0x0006(v0)          // original line 1
        jr      ra
        sh      t2, 0x0004(v0)          // original line 2
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

dpad_move_timer:
dw  0
dw  0
dw  0
dw  0

dpad_css_cursor_timer:
dw  30
dw  30
dw  30
dw  30
