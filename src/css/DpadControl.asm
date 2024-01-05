// @ Description (code by goom)
// These constants must be defined for a menu item.
define LABEL("Dpad ctrl")
constant VALUE_TYPE(CharacterSelectDebugMenu.value_type.STRING)
constant MIN_VALUE(0)
constant MAX_VALUE(4)
constant DEFAULT_VALUE(0)
// bitmask: [vs] [1p] [training] [bonus1] [bonus2] [allstar]
constant APPLIES_TO(0b111111)
// bitmask: [human] [cpu]
constant APPLIES_TO_HUMAN_CPU(0b10)
constant VALUE_ARRAY_POINTER(DpadControl.dpad_controls_table)
constant ONCHANGE_HANDLER(0)
// constant ONCHANGE_HANDLER(onchange_handler)
constant DISABLES_HIGH_SCORES(OS.FALSE)

// @ Description
// Holds pointers to value labels
string_table:
dw string_off
dw string_stick_swap
dw string_stickless
dw string_stick_swap_j
dw string_stickless_j

// @ Description
// Value labels
string_off:; String.insert("Off")
string_stick_swap:; String.insert("Stick Swap")
string_stickless:; String.insert("Stickless")
string_stick_swap_j:; String.insert("Stick Swap J")
string_stickless_j:; String.insert("Stickless J")

// @ Description
// Hook into routine that writes Joypad bitmask to player struct (non-cpu players)

// Dpad Control
// 0 = off
// 1 = Stick Swap       // Dpad and Stick inputs are switched; Training-compatible and can be used in conjunction with Dpad map
// 2 = Stickless        // Control scheme for controllers without a stick (can select CSS variants)
// 3 = Stick Swap J     // Alternative control with 'Dpad Up' used to Jump
// 4 = Stickless J      // ~

// @ Description
// Disables setting shield button mask yet (moved after Joystick.set_taunt_mask_)
scope dont_set_shield_mask_: {
    OS.patch_start(0x53CB8, 0x800D84B8)
    nop                     // original line 1 was: sh t5, 0x01B8(s5)
    OS.patch_end()
}

// @ Description
// Overrides button mask for shield per port when Dpad Control is enabled.
scope set_shield_mask_: {
    OS.patch_start(0x53CF0, 0x800D84F0)
    jal     set_shield_mask_
    nop
    OS.patch_end()

    li      t3, dpad_controls_table // t3 = dpad controls table
    lb      t8, 0x000D(s5)          // t8 = player port
    sll     t8, t8, 0x0002          // t8 = offset
    addu    t3, t3, t8              // t3 = address of dpad_controls_table
    lw      t8, 0x0000(t3)          // t8 = players value in table

    beqzl   t8, _end                // if not using Dpad Controls, then use default mask
    lli     t3, Joypad.Z            // t3 = Joypad.Z

    // my code runs first.. so i need an alternative approach (actually just reordered them)
    // check if using custom 'Taunt Btn', and leave Z mapped as Shield if so (otherwise map Z as Taunt)
    li      t8, Joypad.taunt_mask_per_port
    lbu     t3, 0x000D(s5)          // t3 = port
    sll     t3, t3, 0x0002          // t3 = offset
    addu    t8, t8, t3              // t8 = address of taunt mask index
    lw      t8, 0x0000(t8)          // t8 = taunt mask index

    addiu   a2, r0, 0x0009          // a2 = 9 ('Z')
    beql    t8, a2, pc() + 8        // if 9, then it's an automatic 'Z' taunt button and purely cosmetic, so treat it as default
    or      t8, r0, r0              // t8 = 0

    bnezl   t8, _end                // if not 0, then it's not set to default taunt button
    addiu   t3, r0, 0x2020          // t3 = 0x0020 (Joypad.L) + 0x2000 (Joypad.Z)

    lli     t3, Joypad.L            // t3 = Joypad.L
    lli     t8, Joypad.Z            // t8 = Joypad.Z
    sh      t8, 0x01BA(s5)          // t8 = taunt mask (override)

    _end:
    sh      t3, 0x01B8(s5)          // set shield button mask
    lw      t8, 0x0104(v1)          // original line 1
    addiu   a2, v1, 0x011C          // original line 2
    jr      ra
    nop
}

// @ Description
// Overrides button macro for R per port when Dpad Control is enabled.
scope set_R_macro: {
    OS.patch_start(0x5CAFC, 0x800E12FC)
    jal     set_R_macro
    nop
    _return:
    OS.patch_end()

    li      t4, dpad_controls_table // t4 = dpad controls table
    lb      t6, 0x000D(a2)          // t6 = player port
    sll     t6, t6, 0x0002          // t6 = offset
    addu    t4, t4, t6              // t4 = address of dpad_controls_table
    lw      t6, 0x0000(t4)          // t6 = players value in table

    beqzl   t6, pc() + 12           // if not using Dpad Controls, set default macro for R (Z+A)
    ori     a3, a1, 0xA000          // original line 1
    ori     a3, a1, 0x8020          // a3 = 0x0020 (Joypad.L) + 0x8000 (Joypad.A)

    _end:
    andi    a3, a3, 0xFFFF          // original line 2
    jr      ra
    nop
}

// @ Description
// Hijacks the controller struct writing routine to allow for dpad cursor control on VS CSS (req. for Dpad Control)
// Has a short hold timer to prevent accidental movement by stick users when tapping dpad to set a variant
// Also handles Dpad Controls, which swaps Stick and Dpad globally
// a1 = port
// a3 = 0x80045228 = Joypad.struct
// v0 = current port controller struct
// t3 = xpos
// t4 = ypos
// t8 = is_held  - check for is_held
// t9 = pressed  - check for !is_held -> is_held
// t2 = turbo    - is_held but continually goes on and off
// t1 = released - check for is_held -> !is_held
// at = 0x80040000 (safe to edit)
scope css_cursor_and_dpad_controls_: {
    OS.patch_start(0x4C00, 0x80004000)
    jal     css_cursor_and_dpad_controls_
    nop
    OS.patch_end()

    li      t5, dpad_controls_table // t5 = dpad controls table
    or      t6, r0, a1              // t6 = player port
    sll     t6, t6, 0x0002          // t6 = offset
    addu    t5, t5, t6              // t5 = address of dpad_controls_table
    lw      t6, 0x0000(t5)          // t6 = player entry in dpad_controls_table
    andi    t5, t6, 0x0001          // t5 = 1 if (Stick Swap) or (Stick Swap J)
    bnez    t5, _stick_dpad_switcheroo // if using 'Stick Swap', swap Stick and Dpad globally
    nop
    beqz    t6, _cursor_control     // skip screen checks if Dpad control is disabled
    nop

    li      t5, Global.current_screen
    lbu     a0, 0x0000(t5)                  // a0 = current screen
    lli     t5, Global.screen.TITLE_AND_1P  // Title, 1p game over screen, 1p battle, remix 1p battle
    beq     t5, a0, _SNJ_check_pause        // branch accordingly
    lli     t5, Global.screen.VS_BATTLE
    beq     t5, a0, _SNJ_check_pause
    lli     t5, Global.screen.BONUS         // Bonus 1, Bonus 2, Bonus 3 (BTT/BTP/RTTF)
    beq     t5, a0, _SNJ_check_pause
    lli     t5, Global.screen.TRAINING_MODE
    beq     t5, a0, _SNJ_check_pause
    lli     t5, Global.screen.REMIX_MODES   // Remix Modes (other than Remix 1P) All-star, Multiman, HRC
    bne     t5, a0, _cursor_control         // this branch is taken if screen is not any of the above
    nop
    _SNJ_check_pause:
    li      t5, Global.match_info
    lw      t5, 0x0000(t5)                  // t5 = match info
    lbu     t5, 0x0011(t5)                  // t5 = pause state
    sltiu   t5, t5, 2                       // t5 = 1 if unpaused (pause state is 0 or 1 if not paused)
    bnez    t5, _SNJ_clear_x_y              // branch accordingly
    nop

    // if we're here, the game is paused; check if we are in training mode
    li      t5, Global.current_screen
    lbu     a0, 0x0000(t5)                  // a0 = current screen
    addiu   t5, r0, Global.screen.TRAINING_MODE
    beq     t5, a0, _training_pause_control // branch if we're in training mode
    nop
    b       _cursor_control
    nop

    // if we're here, the game isn't paused
    _SNJ_clear_x_y:
    // for 'Stickless', clear Joystick X and Y (t3, t4) during unpaused matches
    addiu   t5, r0, 0x0002          // t5 = 2 (Stickless)
    bne     t5, t6, _cursor_control // branch accordingly
    nop
    or      t3, r0, r0              // zero out stick X value
    or      t4, r0, r0              // zero out stick Y value
    b       _end
    nop

    _cursor_control:
    bnez    t6, _check_screen_id    // branch if player is using Dpad Control, regardless of toggle state
    nop                             // otherwise check toggle value
    li      t5, Toggles.entry_dpad_css_control
    lw      t5, 0x0004(t5)          // t5 = 0 if Dpad CSS Cursor Control is disabled
    beqz    t5, _end                // branch accordingly
    nop
    _check_screen_id:
    // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
    li      t5, Global.current_screen
    lbu     a0, 0x0000(t5)          // a0 = current screen
    // Edit: no longer necessary, Training-compatible now
    //// addiu   t5, r0, Global.screen.TRAINING_CSS
    //// beq     t5, a0, _end            // branch if we're on training CSS screen
    //// nop
    sltiu   t5, a0, 0x0010          // t5 = 1 if < 10
    bnez    t5, _end                // branch if we're not on a CSS screen
    nop
    slti    t5, a0, 0x0015          // t5 = 1 if < 15
    beqz    t5, _end                // branch if we're not on a CSS screen
    nop

    // check if dpad is being pressed (Dpad Control isn't necessarily enabled, so we need to be polite)
    li      a0, dpad_css_cursor_timer // a0 = dpad_css_cursor_timer
    sll     t5, a1, 0x0002          // t5 = offset
    addu    a0, a0, t5              // a0 = player entry in dpad_css_cursor_timer
    lh      t5, 0x0000(v0)          // get current button held value
    andi    t5, t5, 0x0F00          // t5 = 0 if dpad isn't down
    bnez    t5, _check_dpad_css_timer // branch if any dpad buttons are held, otherwise reset timer
    nop

    // t6 = players value in dpad macro table
    bnezl   t6, pc() + 12           // if 'Stickless' is enabled for that player, use a shorter timer
    addiu   t5, r0, 12              // t5 = 12
    addiu   t5, r0, 30              // t5 = 30
    sw      t5, 0x0000(a0)          // save updated timer
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
    addiu   t5, r0, Global.screen.VS_CSS
    beq     t6, t5, _check_token_state_vs
    nop
    addiu   t5, r0, Global.screen.TRAINING_CSS // t5 = screen_id
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

    // note: full stick values of 81 min and 7F max is too fast (outside of real range), so we use partial
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

    b       _end
    nop

    // allow 'Stickless' and 'Stickless J' Dpad to be used to navigate Training Menu when paused
    // note: pause value is either 2 (menu) or 3 (custom menu)
    _training_pause_control:
    // Save a copy of original values, and then clear stuff so we can populate it ourselves
    li      t5, original_held_pressed // We store some unmodified values to access later
    sh      t8, 0x0000(t5)          // t8 (held button)
    sh      t9, 0x0002(t5)          // t9 (pressed button)
    andi    t8, t8, 0xF0FF          // remove held dpad input
    andi    t9, t9, 0xF0FF          // remove pressed dpad input
    andi    t2, t2, 0xF0FF          // remove turbo dpad input
    b       _check_dpad             // skip directly to dpad check (no stick change)
    nop

    // Swap Stick and Dpad inputs appropriately
    _stick_dpad_switcheroo:
    // Save a copy of original values, and then clear stuff so we can populate it ourselves
    li      t5, original_held_pressed // We store some unmodified values to access later
    sh      t8, 0x0000(t5)          // t8 (held button)
    sh      t9, 0x0002(t5)          // t9 (pressed button)
    andi    t8, t8, 0xF0FF          // remove held dpad input
    andi    t9, t9, 0xF0FF          // remove pressed dpad input
    andi    t2, t2, 0xF0FF          // remove turbo dpad input
    //// andi    t1, t1, 0xF0FF     // (don't) remove released dpad input

    // Check which direction we are pointing the stick and press/hold the dpad accordingly (taking Deadzone into account)
    _check_stick_x:
    beqz    t3, _check_stick_y      // if stick X (t3) is 0, check stick Y
    nop
    andi    t6, t3, 0xFF00          // t6 = 1 if t3 is negative (left)
    beqz    t6, pc() + 16           // branch if positive
    andi    t6, t3, 0x00FF          // retrieve the last 2 bytes of X value
    xori    t6, t6, 0x00FF          // flip bits to make it positive so we can compare
    addiu   t6, t6, 0x0001          // (negation offset)
    slti    t6, t6, 0x0028          // t6 = 1 if < 40 (DEADZONE)
    bnezl   t6, _check_stick_y      // if stick X is not outside Deadzone range, check stick Y...
    or      t3, r0, r0              // ...and zero out stick X value
    andi    t6, t3, 0xFF00          // t6 = 0 if stick left, otherwise stick right
    bnezl   t6, _check_stick_x_hold
    ori     t8, t8, Joypad.DL       // t8 = held button mask + Joypad.DL
    ori     t8, t8, Joypad.DR       // ~

    // Turbo is needed for Training frame advance Joypad.DR check, so we need to simulate that behaviour
    // Note: Timer normally is/takes 5 frames (cleared at 0x80003EF4)
    li      t6, Global.current_screen
    lbu     a0, 0x0000(t6)          // a0 = current screen
    addiu   t6, r0, Global.screen.TRAINING_MODE
    bne     t6, a0, _check_stick_x_hold // branch if we're not in training mode
    nop

    // No need to check for consecutive frames, the repeat delay is all we care about
    li      t6, DR_stick_training_turbo_timer // t6 = training turbo timer
    sll     a0, a1, 0x0002          // a0 = player port offset
    addu    t6, t6, a0              // t6 = player entry in DR_stick_training_turbo_timer
    lb      a0, 0x0000(t6)          // a0 = timer value in table
    addiu   a0, a0, -0x00001        // decrement timer
    bnezl   a0, _check_stick_x_hold // skip if timer is not zero
    sb      a0, 0x0000(t6)          // a0 = timer value in table
    addiu   a0, r0, 5               // a0 = 5
    sb      a0, 0x0000(t6)          // reset timer

    ori     t8, t8, Joypad.DR       // t8 = held button mask + Joypad.DR
    xori    t2, t2, Joypad.DR       // t2 = turbo button mask + Joypad.DR

    _check_stick_x_hold:
    // check if we were already holding stick left or right (and don't press if so)
    lh      t6, 0x0000(v0)          // t6 = previous held button value
    andi    t6, t6, 0x0300          // t6 = 1 if either DL or DR
    bnezl   t6, _check_stick_y
    or      t3, r0, r0              // zero out stick X value
    andi    t6, t3, 0xFF00          // t6 = 0 if stick left, otherwise stick right
    beqzl   t6, pc() + 12
    ori     t9, t9, Joypad.DR       // t9 = pressed button mask + Joypad.DR
    ori     t9, t9, Joypad.DL       // ~
    or      t3, r0, r0              // zero out stick X value

    _check_stick_y:
    beqz    t4, _check_dpad         // if stick Y (t4) is 0, check dpad
    nop

    andi    t6, t4, 0xFF00          // t6 = 1 if t4 is negative (down)
    beqz    t6, pc() + 16           // branch if positive
    andi    t6, t4, 0x00FF          // retrieve the last 2 bytes of Y value
    xori    t6, t6, 0x00FF          // flip bits to make it positive so we can compare
    addiu   t6, t6, 0x0001          // (negation offset)
    slti    t6, t6, 0x001E          // t6 = 1 if < 30 (DEADZONE)
    bnezl   t6, _check_dpad         // if stick Y is not outside Deadzone range, check dpad...
    or      t4, r0, r0              // ...and zero out stick Y value
    andi    t6, t4, 0xFF00          // t6 = 0 if stick up, otherwise stick down
    beqzl   t6, pc() + 12
    ori     t8, t8, Joypad.DU       // t8 = held button mask + Joypad.DU
    ori     t8, t8, Joypad.DD       // ~

    _check_stick_y_hold:
    // check if we were already holding stick up or down (and don't press if so)
    lh      t6, 0x0000(v0)          // t6 = previous held button value
    andi    t6, t6, 0x0C00          // t6 = 1 if either DU or DD
    bnezl   t6, _check_dpad         // branch accordingly
    or      t4, r0, r0              // zero out stick Y value
    andi    t6, t4, 0xFF00          // t6 = 0 if stick up, otherwise stick down
    beqzl   t6, pc() + 12
    ori     t9, t9, Joypad.DU       // t9 = pressed button mask + Joypad.DU
    ori     t9, t9, Joypad.DD       // ~
    or      t4, r0, r0              // zero out stick Y value

    _check_dpad:
    // check if dpad is being either held or pressed
    li      t5, original_held_pressed // We retrieve some unmodified values to access now
    lh      t6, 0x0002(t5)          // t6 = 'original t9' (pressed button)
    lh      t5, 0x0000(t5)          // t5 = 'original t8' (held button)

    or      t6, t5, t6              // t6 = merged held + pressed masks
    andi    t6, t6, 0x0F00          // t6 = 0 if dpad isn't held down
    beqz    t6, _end                // branch if no dpad buttons are held
    nop

    // note: full stick values of 81 min and 7F max is too fast, so we use partial D0 / 30
    andi    t6, t5, Joypad.DL       // t6 = 1 if dpad left held
    bnezl   t6, pc() + 8
    addiu   t3, r0, 0xB0            // t3 = partial min stick X value
    andi    t6, t5, Joypad.DR       // t6 = 1 if dpad right held
    bnezl   t6, pc() + 8
    addiu   t3, r0, 0x50            // t3 = partial max stick X value
    andi    t6, t5, Joypad.DD       // t6 = 1 if dpad down held
    bnezl   t6, pc() + 8
    addiu   t4, r0, 0xB0            // t4 = partial max stick Y value
    andi    t6, t5, Joypad.DU       // t6 = 1 if dpad up held
    bnezl   t6, pc() + 8
    addiu   t4, r0, 0x50            // t4 = partial min stick Y value

    _end:
    sh      t8, 0x0000(v0)          // t8 = original line (update held buttons)
    sh      t9, 0x0002(v0)          // t9 = original line (update pressed buttons)
    sh      t1, 0x0006(v0)          // original line 1 (write released buttons)
    jr      ra
    sh      t2, 0x0004(v0)          // original line 2 (update turbo buttons)
}

// @ Description
// Runs before Training mode to force 'Stick Swap' if using 'Stickless'
// This is needed now that Dpad Control is Training-compatible (so a stickless controller won't get stuck in menu)
// Note: This is no longer necessary to clear; added Pause Menu support for Stickless (and can disable D-pad shortcuts in Menu)
scope force_settings_for_training_: {
    addiu   sp, sp, -0x0020                 // allocate stack space
    sw      t0, 0x0004(sp)                  // ~
    sw      t1, 0x0008(sp)                  // ~
    sw      t2, 0x000C(sp)                  // ~
    sw      t3, 0x0010(sp)                  // ~
    sw      t4, 0x0014(sp)                  // ~

    li      t0, dpad_controls_table         // t0 = dpad_controls_table address
    or      t4, r0, r0                      // t4 = 0

    _loop:
    addiu   t2, r0, 0x0002                  // t2 = 2 (Stickless)
    addiu   t1, r0, 0x0001                  // t1 = 1 (Stick Swap)
    lw      t3, 0x0000(t0)                  // t3 = dpad state for this port
    beql    t3, t2, _next_port              // if using 'Stickless', force 'Stick Swap'
    sw      t1, 0x0000(t0)                  // ~

    addiu   t2, r0, 0x0004                  // t2 = 4 (Stickless J)
    addiu   t1, r0, 0x0003                  // t1 = 3 (Stick Swap J)
    lw      t3, 0x0000(t0)                  // t3 = dpad state for this port
    beql    t3, t2, pc() + 8                // if using 'Stickless J', force 'Stick Swap J'
    sw      t1, 0x0000(t0)                  // ~

    _next_port:
    sltiu   t2, t4, 0x0003                  // t2 = 1 if still more ports to check
    addiu   t4, t4, 0x0001                  // t4++
    bnez    t2, _loop                       // if not done, continue looping
    addiu   t0, t0, 0x0004                  // t0 = next port in dpad_controls_table

    lw      t0, 0x0004(sp)                  // ~
    lw      t1, 0x0008(sp)                  // ~
    lw      t2, 0x000C(sp)                  // ~
    lw      t3, 0x0010(sp)                  // ~
    lw      t4, 0x0014(sp)                  // ~
    addiu   sp, sp, 0x0020                  // deallocate stack space
    jr      ra
    nop
}

// @ Description
// Check if using standard Dpad Control and handle appropriately (during idle, grounded, aerial)
scope check_jump_type_idle_: {
    OS.patch_start(0xB9ECC, 0x8013F48C)
    j       check_jump_type_idle_
    lw      at, 0x0020(a0)              // check if cpu
    _return:
    OS.patch_end()

    // a0 = player struct

    bnezl   at, _normal                 // do normal branch if CPU player
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle
    lb      at, 0x000D(a0)              // at = player port
    li      t7, dpad_controls_table     // t7 = dpad controls table
    sll     at, at, 0x0002
    addu    t7, t7, at                  // t7 = player entry in dpad_controls_table
    lw      at, 0x0000(t7)              // at = entry

    beqzl   at, _normal                 // proceed normally if it's Dpad Control is Off
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle

    slti    at, at, 0x003               // at = 0 if (Stick Swap J) or (Stickless J)
    beqzl   at, _normal                 // proceed normally if using Dpad Control J style
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle

    // if here, using standard Dpad Control
    b       _end
    lli     at, 0x0000                  // return 0

    _normal:
    slti    at, t7, 0x0004              // original line 2

    _end:
    j       _return
    nop

}

// @ Description
// Check if using standard Dpad Control and handle appropriately (during dash, run)
// Can initiate an up special or smash attack if A or B held.
scope check_jump_type_running_: {
    OS.patch_start(0xB9F94, 0x8013F554)
    j       check_jump_type_running_
    lw      at, 0x0020(a0)              // check if cpu
    _return:
    OS.patch_end()

    // a0 = player struct
    bnez    at, _normal                 // do normal branch if CPU player
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle
    lb      at, 0x000D(a0)              // at = player port
    li      t7, dpad_controls_table     // t7 = dpad controls table
    sll     at, at, 0x0002
    addu    t7, t7, at                  // t7 = player entry in dpad_controls_table
    lw      at, 0x0000(t7)              // at = entry

    beqzl   at, _normal                 // proceed normally if Dpad Control is Off
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle
    slti    at, at, 0x003               // at = 0 if (Stick Swap J) or (Stickless J)
    beqzl   at, _normal                 // proceed normally if using Dpad Control J style
    lbu     t7, 0x0269(a0)              // original line 1, get stick angle

    // if here, using standard Dpad Control
    _check_up_special:
    lh      t7, 0x01BE(a0)              // get button pressed
    andi    at, t7, Joypad.B            // check if B pressed
    bnez    at, _check_up_smash         // no USP if B pressed
    lh      t7, 0x01BC(a0)              // get button held
    andi    at, t7, Joypad.B            // check if B held
    beqzl   at, _check_up_smash         // branch if B held
    nop
    b       _up_special                 // if here, then no up smash
    lw      t2, 0x0008(a0)              // get character id

    _check_up_smash:
    lh      t7, 0x01BE(a0)              // get button pressed
    andi    at, t7, Joypad.A            // check if A pressed
    bnez    at, _no_jump_normal         // no USP if A pressed
    lh      t7, 0x01BC(a0)              // get button held
    andi    at, t7, Joypad.A            // check if A held
    beqzl   at, _no_jump_normal         // branch if A not held
    nop

    _up_smash:
    jal     0x801505F0                  // do up smash
    lw      a0, 0x0004(a0)              // argument = player object
    b       _exit_initial
    nop

    _up_special:
    constant UPPER(Character.ground_usp.table >> 16)
    constant LOWER(Character.ground_usp.table & 0xFFFF)
    if LOWER > 0x7FFF {
        lui     t7, (UPPER + 0x1)       // original line 1 (modified)
    } else {
        lui     t7, UPPER               // original line 1 (modified)
    }
    sll     at, t2, 0x2
    addu    t7, t7, at
    lw      t7, LOWER(t7)
    jalr    ra, t7                      // do characters ground NSP routine
    lw      a0, 0x0004(a0)              // argument = player object

    _exit_initial:
    addiu   sp, sp, 0x18                // deallocate stackspace
    lw      ra, 0x0014(sp)              // get return address
    li      at, 0x8013EEB4              // at = RA while in a run action
    bnel    at, ra, _no_jump_normal     // branch if not running (usually because dashing)
    addiu   sp, sp, -0x18               // re-allocate stackspace
    j       0x8013EED8                  // go to end of routine for running
    lli     v0, 0x0001                  // return 1 (don't transition to run stop)

    _no_jump_normal:
    j       _return
    lli     at, 0x0000                  // return 0 (no jump)

    _normal:
    j       _return
    slti    at, t7, 0x0004              // original line 2

}

// Description
// hook into dash attack initial. disables dash attack if using standard Dpad Control and holding up
scope dash_attack_check_: {
    OS.patch_start(0xCA170, 0x8014F730)
    j       dash_attack_check_
    nop
    OS.patch_end()

    lw      v0, 0x0084(a0)              // v0 = player struct
    lw      at, 0x0020(v0)              // check if cpu
    bnez    at, _dash_attack            // do normal branch if CPU player
    lb      at, 0x000D(v0)              // at = player port
    li      a1, dpad_controls_table     // a1 = dpad controls table
    sll     at, at, 0x0002
    addu    a1, a1, at                  // a1 = player entry in dpad_controls_table
    lw      at, 0x0000(a1)              // at = entry

    beqzl   at, _dash_attack            // proceed normally if Dpad Control is Off
    nop
    slti    at, at, 0x003               // at = 0 if (Stick Swap J) or (Stickless J)
    beqzl   at, _dash_attack            // proceed normally if using Dpad Control J style
    nop

    // if here, using standard Dpad Control
    lbu     a1, 0x01C3(v0)              // get stick Y
    beqz    a1, _dash_attack            // dash attack if stick Y not pointing anywhere
    srl     at, a1, 0x0007
    bnez    at, _dash_attack            // dash attack if pointing downwards
    nop

    // if here, then skip dash attack
    _up_smash:
    j       0x8014F744                  // return to original routine
    addiu   v0, r0, 0x0001              // return 1

    _dash_attack:
    jal     0x8014F670                  // original line 1
    nop
    j       0x8014F744                  // return to original routine
    addiu   v0, r0, 0x0001              // return 1
}



dpad_controls_table:
dw  0
dw  0
dw  0
dw  0

dpad_css_cursor_timer:
dw  30
dw  30
dw  30
dw  30

original_held_pressed:
dh  0
dh  0

DR_stick_training_turbo_timer:
db  5
db  5
db  5
db  5
