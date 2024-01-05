// Bowser.asm

// This file contains file inclusions, action edits, and assembly for Bowser.

scope Bowser {
    // Insert Moveset files

    insert USPG, "moveset/USPG.bin"
    insert USPA, "moveset/USPA.bin"
    insert NSP, "moveset/NSP.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    insert GRAB_PULL, "moveset/GRAB_PULL.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert FTHROW_2, "moveset/FTHROW_2.bin"
    insert FTHROW_3, "moveset/FTHROW_3.bin"
    insert BTHROW_DATA, "moveset/BTHROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BTHROW.bin"
    insert DSP_GROUND, "moveset/DSP_GROUND.bin"
    insert DSP_AIR, "moveset/DSP_AIR.bin"
    insert DSP_LAND, "moveset/DSP_LAND.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert FSMASH, "moveset/FSMASH.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert FTILT, "moveset/FTILT.bin"
    insert FTILT_HIGH, "moveset/FTILT_HIGH.bin"
    insert FTILT_LOW, "moveset/FTILT_LOW.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert DAIR, "moveset/DAIR.bin"
    insert DAIR_LAND, "moveset/DAIR_LAND.bin"
    insert JAB1, "moveset/JAB1.bin"
    insert JAB2, "moveset/JAB2.bin"
    insert JAB3, "moveset/JAB3.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert VICTORY1, "moveset/VICTORY1.bin"
    insert CSS, "moveset/CSS.bin"
    insert JUMP1, "moveset/JUMP1.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert TAUNT, "moveset/TAUNT.bin"
    insert DASH_ATTACK, "moveset/DASH_ATTACK.bin"
    insert DOWNATTACK_D, "moveset/DOWNATTACK_D.bin"
    insert DOWNATTACK_U, "moveset/DOWNATTACK_U.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert EDGEATTACKF1, "moveset/EDGEATTACKF1.bin"
    insert EDGEATTACKF2, "moveset/EDGEATTACKF2.bin"
    insert EDGEATTACKS1, "moveset/EDGEATTACKS1.bin"
    insert EDGEATTACKS2, "moveset/EDGEATTACKS2.bin"
	insert VICTORY2, "moveset/VICTORY2.bin"
    insert TURN_RUN, "moveset/TURN_RUN.bin"
	insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
	insert SLEEP, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP)   // loops
	insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
	insert TECH, "moveset/TECH.bin"
	insert TECHF, "moveset/TECHF.bin"
	insert TEETER, "moveset/TEETER.bin"
	insert ENTRY, "moveset/ENTRY.bin"
	insert CLAP, "moveset/CLAP.bin"
	insert WALK2, "moveset/WALK2.bin"; Moveset.GO_TO(WALK2)            	// loops
	insert WALK3, "moveset/WALK3.bin"; Moveset.GO_TO(WALK3)            	// loops
	insert RUN, "moveset/RUN.bin"; Moveset.GO_TO(RUN)            		// loops
	insert DASH, "moveset/DASH.bin"
	insert TURN, "moveset/TURN.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(BOWSER,    Action.Entry,      		File.BOWSER_IDLE,   		 -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ReviveWait,      File.BOWSER_IDLE,   		 -1,                        -1)
	Character.edit_action_parameters(BOWSER,    0x06,      				File.BOWSER_IDLE,   		 -1,                        -1)

	Character.edit_action_parameters(BOWSER,    Action.Walk1,      		File.BOWSER_WALK1,   		 -1,                     	-1)
	Character.edit_action_parameters(BOWSER,    Action.Walk2,      		File.BOWSER_WALK2,   		 WALK2,                     -1)
	Character.edit_action_parameters(BOWSER,    Action.Walk3,      		File.BOWSER_WALK3,   		 WALK3,                     -1)

    Character.edit_action_parameters(BOWSER,    Action.DamageHigh1,     File.BOWSER_DAMAGE_HIGH_1,   -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DamageHigh2,     File.BOWSER_DAMAGE_HIGH_2,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageHigh3,     File.BOWSER_DAMAGE_HIGH_3,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageMid1,      File.BOWSER_DAMAGE_MID_1,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageMid2,      File.BOWSER_DAMAGE_MID_2,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageMid3,      File.BOWSER_DAMAGE_MID_3,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageLow1,      File.BOWSER_DAMAGE_LOW_1,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageLow2,      File.BOWSER_DAMAGE_LOW_2,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageLow3,      File.BOWSER_DAMAGE_LOW_3,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageAir1,      File.BOWSER_DAMAGE_AIR_1,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageAir2,      File.BOWSER_DAMAGE_AIR_2,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageAir3,      File.BOWSER_DAMAGE_AIR_3,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageElec1,     File.BOWSER_DAMAGE_ELEC,     -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageElec2,     File.BOWSER_DAMAGE_ELEC,     -1,                        -1)

    Character.edit_action_parameters(BOWSER,    Action.Sleep,     		File.BOWSER_STUNNED,     	 SLEEP,                     -1)
	Character.edit_action_parameters(BOWSER,    Action.Stun,     		File.BOWSER_STUNNED,     	 STUN,                      -1)
	Character.edit_action_parameters(BOWSER,    Action.ShieldBreak,     -1,     					 SHIELD_BREAK,              -1)
	Character.edit_action_parameters(BOWSER,    Action.Tech,     		File.BOWSER_TECH,     		 TECH,              		-1)
	Character.edit_action_parameters(BOWSER,    Action.TechF,     		File.BOWSER_TECH_F,     	 TECHF,              		-1)
	Character.edit_action_parameters(BOWSER,    Action.TechB,     		File.BOWSER_TECH_B,     	 TECHF,              		-1)

	Character.edit_action_parameters(BOWSER,    Action.EnterPipe,       File.BOWSER_ENTER_PIPE,      -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ExitPipe,        File.BOWSER_EXIT_PIPE,       -1,                        -1)

    Character.edit_action_parameters(BOWSER,    Action.Crouch,          File.BOWSER_CROUCH,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.CrouchIdle,      File.BOWSER_CROUCH_IDLE,     -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.CrouchEnd,       File.BOWSER_CROUCH_END,      -1,                        -1)

    Character.edit_action_parameters(BOWSER,    Action.CeilingBonk,     File.BOWSER_CEILING_BONK,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DownBounceD,     File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.StunLandD,       File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.Revive1,         File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DownBounceU,     File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.StunLandU,       File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DownStandD,      File.BOWSER_DOWN_STAND_D,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownStandU,      File.BOWSER_DOWN_STAND_U,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.Revive2,         File.BOWSER_DOWN_STAND_D,    -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.StunStartD,      File.BOWSER_DOWN_STAND_D,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.StunStartU,      File.BOWSER_DOWN_STAND_U,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownForwardD,    File.BOWSER_DOWN_FORWARD_D,  -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownForwardU,    File.BOWSER_DOWN_FORWARD_U,  -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownBackD,    	File.BOWSER_DOWN_BACK_D,     -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownBackU,       File.BOWSER_DOWN_BACK_U,     -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownAttackU,     File.BOWSER_DOWN_ATTACK_U,   DOWNATTACK_U,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DownAttackD,     File.BOWSER_DOWN_ATTACK_D,   DOWNATTACK_D,                        -1)

	Character.edit_action_parameters(BOWSER,    Action.CliffCatch, 		File.BOWSER_CLIFFCATCH, 	 -1,              			-1)
	Character.edit_action_parameters(BOWSER,    Action.CliffWait, 		File.BOWSER_CLIFFWAIT, 	     -1,              			-1)
	Character.edit_action_parameters(BOWSER,    Action.CliffQuick, 		File.BOWSER_CLIFFQUICK, 	 -1,              			-1)
	Character.edit_action_parameters(BOWSER,    Action.CliffSlow, 		File.BOWSER_CLIFFSLOW, 	     -1,              			-1)
	Character.edit_action_parameters(BOWSER,    Action.CliffClimbQuick1, File.BOWSER_CLIFF_CLIMB_QUICK_1, -1,                   -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffClimbQuick2, File.BOWSER_CLIFF_CLIMB_QUICK_2, -1,                   -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffClimbSlow1, File.BOWSER_CLIFF_CLIMB_SLOW_1, -1,                     -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffClimbSlow2, File.BOWSER_CLIFF_CLIMB_SLOW_2, -1,                     -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffEscapeQuick1, File.BOWSER_CLIFF_ESCAPE_QUICK_1, -1,                 -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffEscapeQuick2, File.BOWSER_CLIFF_ESCAPE_QUICK_2, -1,                 -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffEscapeSlow1, File.BOWSER_CLIFF_ESCAPE_SLOW_1, -1,                   -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffEscapeSlow2, File.BOWSER_CLIFF_ESCAPE_SLOW_2, -1,                   -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffAttackQuick1, File.BOWSER_CLIFFATTACKQ1, EDGEATTACKF1,              -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffAttackQuick2, File.BOWSER_CLIFFATTACKQ2, EDGEATTACKF2,              -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffAttackSlow1, File.BOWSER_CLIFFATTACKS1,  EDGEATTACKS1,              -1)
	Character.edit_action_parameters(BOWSER,    Action.CliffAttackSlow2, File.BOWSER_CLIFFATTACKS2,  EDGEATTACKS2,              -1)

    Character.edit_action_parameters(BOWSER,    Action.DamageFlyHigh,   File.BOWSER_DAMAGE_FLY_HIGH, -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.DamageFlyMid,    File.BOWSER_DAMAGE_FLY_MID,  -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageFlyLow,    File.BOWSER_DAMAGE_FLY_LOW,  -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageFlyTop,    File.BOWSER_DAMAGE_FLY_TOP,  -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DamageFlyRoll,   File.BOWSER_DAMAGE_FLY_ROLL, -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.DeadU,           File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ScreenKO,        File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.WallBounce,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.Tumble,          File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.Tornado,         File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ShieldBreak,     File.BOWSER_DAMAGE_FLY_TOP,  -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ShieldBreakFall, File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.InhalePulled,    File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.InhaleSpat,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.InhaleCopied,    File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.FalconDivePulled, File.BOWSER_DAMAGE_HIGH_3,  -1,                        -1)
    Character.edit_action_parameters(BOWSER,    0xB4,                   File.BOWSER_TUMBLE,          -1,                        -1)

	Character.edit_action_parameters(BOWSER,    Action.LightItemPickup, File.BOWSER_LIGHT_ITEM_PICK, -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.HeavyItemPickup, File.BOWSER_HEAVY_ITEM_PICK, -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ItemDrop,        File.BOWSER_ITEM_DROP,       -1,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.ItemThrowDash,   File.BOWSER_ITEM_THROW_DASH, -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowF,      File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowB,      File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowSmashF, File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowSmashF, File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowU,      File.BOWSER_ITEM_THROW_U,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowSmashU, File.BOWSER_ITEM_THROW_U,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowD,      File.BOWSER_ITEM_THROW_D,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowSmashD, File.BOWSER_ITEM_THROW_D,    -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirF,   File.BOWSER_ITEM_THROW_F_AIR, -1,                       -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirSmashF, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirB,   File.BOWSER_ITEM_THROW_F_AIR,    -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirSmashB, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirU,   File.BOWSER_ITEM_THROW_U_AIR,    -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirSmashU, File.BOWSER_ITEM_THROW_U_AIR, -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirD,   File.BOWSER_ITEM_THROW_D_AIR,    -1,                    -1)
	Character.edit_action_parameters(BOWSER,    Action.ItemThrowAirSmashD, File.BOWSER_ITEM_THROW_D_AIR, -1,                    -1)

	Character.edit_action_parameters(BOWSER,    Action.HeavyItemThrowF, File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.HeavyItemThrowB, File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.HeavyItemThrowSmashF, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)
	Character.edit_action_parameters(BOWSER,    Action.HeavyItemThrowSmashB, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)

	Character.edit_action_parameters(BOWSER,    Action.RayGunShoot,     File.BOWSER_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.RayGunShootAir,  File.BOWSER_RAYGUN_AIR,      -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.FireFlowerShoot, File.BOWSER_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.FireFlowerShootAir, File.BOWSER_RAYGUN_AIR,   -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.HammerIdle,      File.BOWSER_HAMMER_IDLE,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.HammerWalk,      File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.HammerTurn,      File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.HammerJumpSquat, File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.HammerAir,       File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.HammerLanding,   File.BOWSER_HAMMER_WALK,     -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.CapturePulled,   File.BOWSER_EGG_LAY_PULLED,  -1,                    	 -1)
    Character.edit_action_parameters(BOWSER,    Action.EggLay,    		File.BOWSER_IDLE, 		     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.EggLayPulled,    File.BOWSER_EGG_LAY_PULLED,  -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.ThrownDKPulled,  File.BOWSER_THROWN_DK_PULLED,  -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.ThrownDK,        File.BOWSER_THROWN_DK,  -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.Thrown1,         File.BOWSER_THROWN_1,        -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.Thrown2,         File.BOWSER_THROWN_2,        -1,                         -1)

    Character.edit_action_parameters(BOWSER,    Action.Taunt,           File.BOWSER_TAUNT,          TAUNT,                      -1)

    Character.edit_action_parameters(BOWSER,    Action.Turn,            File.BOWSER_TURN,           TURN,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.Jab1,            File.BOWSER_JAB1,           JAB1,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.Jab2,            File.BOWSER_JAB2,           JAB2,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.DTilt,           File.BOWSER_DTILT,          DTILT,                      -1)
    Character.edit_action_parameters(BOWSER,    Action.AttackAirN,      File.BOWSER_NAIR,           NAIR,                       -1)

    Character.edit_action_parameters(BOWSER,    Action.Idle,            File.BOWSER_IDLE,           -1,                         0x00000000)
    Character.edit_action_parameters(BOWSER,    Action.JumpSquat,       File.BOWSER_LANDING,        -1,                         0x00000000)
    Character.edit_action_parameters(BOWSER,    Action.ShieldJumpSquat, File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(BOWSER,    Action.LandingLight,    File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(BOWSER,    Action.LandingHeavy,    File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(BOWSER,    Action.LandingSpecial,  File.BOWSER_LANDING,        -1,                         0x00000000)

	Character.edit_action_parameters(BOWSER,    Action.Fall,            File.BOWSER_FALL,           -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.FallAerial,      File.BOWSER_FALL2,           -1,                        -1)
	Character.edit_action_parameters(BOWSER,    Action.AttackAirF,      File.BOWSER_FAIR,           FAIR,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.LandingAirF,     File.BOWSER_FAIR_LAND,      -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.LandingAirN,     File.BOWSER_LANDING,        -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.Grab,            File.BOWSER_GRAB,           GRAB,                       0x10000000)
    Character.edit_action_parameters(BOWSER,    Action.FSmash,          File.BOWSER_FSMASH,         FSMASH,                     0x40000000)
    Character.edit_action_parameters(BOWSER,    Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(BOWSER,    Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(BOWSER,    Action.DSmash,          -1,                         DSMASH,                     -1)

    Character.edit_action_parameters(BOWSER,    Action.GrabPull,        File.BOWSER_PULL,           GRAB_PULL,                  0x10000000)
    Character.edit_action_parameters(BOWSER,    Action.ThrowF,          File.BOWSER_IDLE,           0x80000000,                 0x00000000)
    Character.edit_action_parameters(BOWSER,    Action.ThrowB,          File.BOWSER_BTHROW,         BTHROW,                     0x10000000)
	Character.edit_action_parameters(BOWSER,    Action.ThrownMarioBros, File.BOWSER_THROWN_MARIO,   -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.ShieldOn, 		File.BOWSER_SHIELD_ON,   	-1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.ShieldOff, 		File.BOWSER_SHIELD_OFF,   	-1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.ShieldDrop, 		File.BOWSER_SHIELD_DROP,   	-1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.Pass, 			File.BOWSER_SHIELD_DROP,   	-1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.RollF, 			File.BOWSER_ROLL_F,   	    -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.RollB, 			File.BOWSER_ROLL_B,   	    -1,                         -1)

    Character.edit_action_parameters(BOWSER,    0xE0,                   File.BOWSER_BOMB_GROUND,    DSP_GROUND,                 -1)
    Character.edit_action_parameters(BOWSER,    0xE1,                   File.BOWSER_BOMB_LAND,      DSP_LAND,                   -1)
    Character.edit_action_parameters(BOWSER,    0xE2,                   File.BOWSER_BOMB_AIR,       DSP_AIR,                    -1)
    Character.edit_action_parameters(BOWSER,    0xE5,                   File.BOWSER_FTHROW,         FTHROW,                     0x50000000)
    Character.edit_action_parameters(BOWSER,    0xE6,                   File.BOWSER_FTHROW_2,       FTHROW_2,                   0x50000000)
    Character.edit_action_parameters(BOWSER,    0xE8,                   File.BOWSER_FTHROW_3,       FTHROW_3,                   0x50000000)
    Character.edit_action_parameters(BOWSER,    0xDE,                   File.BOWSER_USP_GROUND,     USPG,                       0x00000000)
    Character.edit_action_parameters(BOWSER,    0xDF,                   File.BOWSER_USP_AIR,        USPA,                       0x00000000)
    Character.edit_action_parameters(BOWSER,    0xE4,                   File.BOWSER_FIRE,           NSP,                        0x00000001)
    Character.edit_action_parameters(BOWSER,    0xE7,                   File.BOWSER_FIRE,           NSP,                        0x00000001)
    Character.edit_action_parameters(BOWSER,    0xE9,                   File.BOWSER_JAB3,           JAB3,                       0x40000000)
    Character.edit_action_parameters(BOWSER,    Action.FallSpecial,     File.BOWSER_SFALL,          -1,                         -1)

    Character.edit_action_parameters(BOWSER,    Action.AttackAirB,      File.BOWSER_BAIR,           BAIR,                       -1)
	Character.edit_action_parameters(BOWSER,    Action.LandingAirB,     File.BOWSER_BAIR_LANDING,   -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.AttackAirU,      File.BOWSER_UAIR,           UAIR,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.AttackAirD,      File.BOWSER_DAIR,           DAIR,                       0x00000000)
    Character.edit_action_parameters(BOWSER,    Action.LandingAirD,     File.BOWSER_DAIR_LAND,      DAIR_LAND,                  0x00000000)

    Character.edit_action_parameters(BOWSER,    Action.UTilt,           File.BOWSER_UTILT,          UTILT,                      -1)
    Character.edit_action_parameters(BOWSER,    Action.USmash,          File.BOWSER_USMASH,         USMASH,                     -1)

	Character.edit_action_parameters(BOWSER,    Action.DSmash,          File.BOWSER_DSMASH,         -1,                     	-1)

    Character.edit_action_parameters(BOWSER,    Action.Teeter,          File.BOWSER_TEETER_LOOP,    TEETER,                     -1)
    Character.edit_action_parameters(BOWSER,    Action.TeeterStart,     File.BOWSER_TEETER_START,   -1,                         -1)

    Character.edit_action_parameters(BOWSER,    Action.FTiltHigh,       File.BOWSER_FTILT_HIGH,     FTILT_HIGH,                 -1)
    Character.edit_action_parameters(BOWSER,    Action.FTilt,           File.BOWSER_FTILT,          FTILT,                      -1)
    Character.edit_action_parameters(BOWSER,    Action.FTiltLow,        File.BOWSER_FTILT_LOW,      FTILT_LOW,                  -1)

    Character.edit_action_parameters(BOWSER,    Action.Dash,            File.BOWSER_DASH,           DASH,                       -1)
    Character.edit_action_parameters(BOWSER,    Action.Run,             File.BOWSER_RUN,            RUN,                        -1)
    Character.edit_action_parameters(BOWSER,    Action.TurnRun,         File.BOWSER_TURN_RUN,       TURN_RUN,                   -1)
    Character.edit_action_parameters(BOWSER,    Action.RunBrake,        File.BOWSER_RUN_BRAKE,      -1,                         -1)
    Character.edit_action_parameters(BOWSER,    Action.DashAttack,      File.BOWSER_DASH_ATTACK,    DASH_ATTACK,                -1)
    Character.edit_action_parameters(BOWSER,    Action.JumpF,           File.BOWSER_JUMPF,          JUMP1,                      -1)
    Character.edit_action_parameters(BOWSER,    Action.JumpB,           File.BOWSER_JUMPB,          JUMP1,                      -1)
    Character.edit_action_parameters(BOWSER,    Action.JumpAerialB,     File.BOWSER_JUMP2_B,        JUMP2,                      0x00000000)
    Character.edit_action_parameters(BOWSER,    Action.JumpAerialF,     File.BOWSER_JUMP2,          JUMP2,                      -1)

	Character.edit_action_parameters(BOWSER,    Action.BeamSwordNeutral, File.BOWSER_SWING_NEUTRAL, -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BeamSwordTilt,   File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BeamSwordSmash,  File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BeamSwordDash,   File.BOWSER_SWING_DASH,     -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.BatNeutral, 		File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BatTilt,   		File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BatSmash,  		File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.BatDash,   		File.BOWSER_SWING_DASH,     -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.FanNeutral, 		File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.FanTilt,   		File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.FanSmash,  		File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.FanDash,   		File.BOWSER_SWING_DASH,     -1,                         -1)

	Character.edit_action_parameters(BOWSER,    Action.StarRodNeutral,  File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.StarRodTilt,     File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.StarRodSmash,    File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(BOWSER,    Action.StarRodDash,     File.BOWSER_SWING_DASH,     -1,                         -1)
	Character.edit_action_parameters(BOWSER,    0xDC,     				File.BOWSER_ENTRY,     		ENTRY,                      0x40000001)
	Character.edit_action_parameters(BOWSER,    0xDD,     				File.BOWSER_ENTRY,     		ENTRY,                      0x40000001)


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM                  // Movement/Physics ASM                         // Collision ASM
    Character.edit_action(BOWSER, 0xDE,             -1,             0x8015B6D0,                 -1,                                     BowserUSP.ground_physics_,                      -1)
    Character.edit_action(BOWSER, 0xDF,             -1,             0x8015B6F0,                 -1,       			                    BowserUSP.air_physics_,                         -1)
    Character.edit_action(BOWSER, 0xE0,             -1,             -1,                         -1,                                     -1,                                             -1)
    Character.edit_action(BOWSER, 0xE2,             -1,             -1,                         -1,                                     BowserDSP.air_physics_,                         -1)
    Character.edit_action(BOWSER, 0xE4,             -1,             BowserNSP.main_,            -1,                                     0x800D8BB4,                                     0x800DDF44)
    Character.edit_action(BOWSER, 0xE7,             -1,             BowserNSP.main_,            -1,                                     -1,                                             BowserNSP.air_collision_)             //0x800DE934
    Character.edit_action(BOWSER, 0xE5,             0x23,           BowserFThrow.main_,         0x00000000,                             0x800D93E4,                                     BowserFThrow.collision_)
    Character.edit_action(BOWSER, 0xE6,             0x0,            0x00000000,                 0x00000000,                             0x00000000,                                     BowserFThrow.collision_)
    Character.edit_action(BOWSER, 0xE8,             -1,             0x8014A0C0,                 0x00000000,                             0x8014A4F8,                                     0x8014A538)
    Character.edit_action(BOWSER, 0xE9,             0x3,            0x800D94C4,                 0x00000000,                             0x800D8C14,                                     0x800DDF44)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(BOWSER,    0x0,               File.BOWSER_IDLE,           -1,                            -1)
	Character.edit_menu_action_parameters(BOWSER,    0x1,               File.BOWSER_DANCE,          VICTORY2,                      -1)
	Character.edit_menu_action_parameters(BOWSER,    0x2,               File.BOWSER_CSS,            CSS,                           -1)
    Character.edit_menu_action_parameters(BOWSER,    0x3,               File.BOWSER_LAUGH,          VICTORY1,                      -1)
    Character.edit_menu_action_parameters(BOWSER,    0x4,               File.BOWSER_LAUGH,          VICTORY1,                      -1)
	Character.edit_menu_action_parameters(BOWSER,    0x5,               File.BOWSER_CLAP,           CLAP,                          -1)
    Character.edit_menu_action_parameters(BOWSER,    0xE,               File.BOWSER_1P_CPU,         0x80000000,                    -1)
    Character.edit_menu_action_parameters(BOWSER,    0xD,               File.BOWSER_1P,             -1,                            -1)
    Character.edit_menu_action_parameters(BOWSER,    0x9,               File.BOWSER_CONTINUE_FALL,  -1,                            -1)
    Character.edit_menu_action_parameters(BOWSER,    0xA,               File.BOWSER_CONTINUE_UP,    -1,                            -1)

	Character.table_patch_start(variants, Character.id.BOWSER, 0x4)
    db      Character.id.GBOWSER // set as BOSS variant for Bowser
    db      Character.id.NBOWSER // set as POLYGON variant for BOWSER
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.BOWSER, 0x4)
    dw      BowserUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.BOWSER, 0x4)
    dw      BowserNSP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.BOWSER, 0x4)
    dw      BowserNSP.air_initial_
    OS.patch_end()

	// Adds Clown Copter to entry.
    Character.table_patch_start(entry_script, Character.id.BOWSER, 0x4)
    dw 0x8013DD14                          // routine typically used by Captain Falcon to load Blue Falcon, now used for Clown Copter
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.BOWSER, 0x2)
    dh  0x0363
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.BOWSER, 0x4)
    float32 1.2
    OS.patch_end()

	// Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.BOWSER, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.BOWSER, 0xC)
    dh 0x15
    OS.patch_end()

	// Set Yoshi Egg Size override ID, these values are just copied from DK
    Character.table_patch_start(yoshi_egg, Character.id.BOWSER, 0x1C)
    dw  0x40600000
	dw	0x00000000
	dw	0x43660000
	dw	0x00000000
	dw	0x43750000
	dw	0x43750000
	dw	0x43750000
    OS.patch_end()

    // Add Jab 3
    Character.table_patch_start(jab_3_timer, Character.id.BOWSER, 0x4)
    dw 0x8014EB54                           // jab 3 timer routine copied from Mario
    OS.patch_end()
    Character.table_patch_start(jab_3_action, Character.id.BOWSER, 0x4)
    dw set_jab_3_action_                    // subroutine which sets action id
    OS.patch_end()
    Character.table_patch_start(jab_3, Character.id.BOWSER, 0x4)
    dw Character.jab_3.ENABLED              // jab 3 = ENABLED
    OS.patch_end()

    // @ Description
    // Bowser's extra actions
    scope Action {
        constant Appear1(0x0DC)
        constant Appear2(0x0DD)
        constant WhirlingFortress(0x0DE)
        constant WhirlingFortressAir(0x0DF)
        constant BowserBomb(0x0E0)
        constant BowserBombLanding(0x0E1)
        constant BowserBombAir(0x0E2)
        constant BowserBombDrop(0x0E3)
        constant FireBreath(0x0E4)
        constant BowserForwardThrow1(0x0E5)
        constant BowserForwardThrow2(0x0E6)
        constant FireBreathAir(0x0E7)
        constant BowserForwardThrow3(0x0E8)
        constant Jab3(0x0E9)

        // strings!
        string_0x0DE:; String.insert("WhirlingFortress")
        string_0x0DF:; String.insert("WhirlingFortressAir")
        string_0x0E0:; String.insert("BowserBomb")
        string_0x0E1:; String.insert("BowserBombLanding")
        string_0x0E2:; String.insert("BowserBombAir")
        string_0x0E3:; String.insert("BowserBombDrop")
        string_0x0E4:; String.insert("FlameBreath")
        string_0x0E5:; String.insert("BowserForwardThrow1")
        string_0x0E6:; String.insert("BowserForwardThrow2")
        string_0x0E7:; String.insert("FireBreathAir")
        string_0x0E8:; String.insert("BowserForwardThrow3")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw Action.COMMON.string_jab3
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.BOWSER, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    Teams.add_team_costume(YELLOW, BOWSER, 0x5)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(BOWSER, GREEN, RED, BLUE, BLACK, ORANGE, YELLOW, NA, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.BOWSER, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.BOWSER, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.BOWSER_USP_DSP	// no risky down or up specials
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  10,  21,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  8,   44,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  24,  35,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  8,   48,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  8,   39,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  6,   22,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  26,  32,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  12,  15,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,  -1,  -1, -1, -1, -1) // todo: check range
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,   31,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  20,  80,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  20,  80,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  7,   32,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   0x0D, 6,   50,  -1, -1, -1, -1) // don't want to use Yoshis USP logic
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   0x0D, 5,   49,  -1, -1, -1, -1) // don't want to use Yoshis USP logic
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  15,  24,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  8,   17,  -1, -1, -1, -1)

    // @ Description
    // Sets Bowser's Jab 3 action.
    scope set_jab_3_action_: {
        ori     t7, r0, 0x00E9              // t7 = action id
        j       0x8014EC30                  // return
        sw      t7, 0x0020(sp)              // store action id
    }

    // @ Description
    // Patch which prevents Bowser from changing action during ThrownMarioBros
    scope thrown_mario_bros_fix_: {
        OS.patch_start(0xC558C, 0x8014AB4C)
        j       thrown_mario_bros_fix_
        nop
        _return:
        OS.patch_end()

        // v0 = throwing player struct
        // a2 = thrown player struct

        lw      at, 0x0008(a2)              // at = thrown character id
        lli     a1, Character.id.BOWSER     // a1 = bowser id
        beq     at, a1, _end                // skip if character id == BOWSER
        nop
		lli     a1, Character.id.GBOWSER    // a1 = gbowser id
        beq     at, a1, _end                // skip if character id == GIGA BOWSER
        nop
        lli     a1, Character.id.NBOWSER    // a1 = nbowser id
        beq     at, a1, _end                // skip if character id == POLYGON BOWSER
        nop
        // this original function is what changes the action from ThrownMarioBros
        jal     0x8014ACB4                  // original line 1
        lw      a1, 0x0B18(a2)              // original line 2
        _end:
        j       _return                     // return
        nop
    }

    // Runs every frame, used to recharge Bowser's flame ammo
    scope bowser_nsp_recharge: {
        OS.patch_start(0x5DBE0, 0x800E23E0)
        j       bowser_nsp_recharge
        lw      t0, 0x0008(s1)              // original line 1, loads character ID
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.KIRBY       // KIRBY ID
        beq     t0, at, _kirby
        addiu   at, r0, Character.id.JKIRBY      // JKIRBY ID
        beq     t0, at, _kirby
        addiu   at, r0, Character.id.BOWSER      // BOWSER ID

        bne     t0, at, _end
        lhu     at, 0x0ADC(s1)          // load player struct free space used for timer and ammo

        addiu   t0, r0, 0x001E
        addiu   at, at, 0x0001

        bne     at, t0, _end
        sh      at, 0x0ADC(s1)          // save updated timer

        sh      r0, 0x0ADC(s1)          // restart timer

        lw      at, 0x0024(s1)          // load current action
        addiu   t0, r0, 0x00E4          // NSP Action

        beq     at, t0, _end            // don't update ammo if currently in nsp
        addiu   t0, r0, 0x00E7          // NSP Action

        beq     at, t0, _end            // don't update ammo if currently in nsp
        lhu     at, 0xADE(s1)           // load ammo

        addiu   t0, r0, 0x0014          // max ammo for bowser

        beq     t0, at, _end
        addiu   at, at, 0x0002

        beq     r0, r0, _end
        sh      at, 0xADE(s1)           // save updated ammo

        _kirby:
        lw      at, 0x0ADC(s1)          // load Kirby Power
        ori     t0, r0, Character.id.BOWSER

        bne     at, t0, _end
        lhu     at, 0x0AE0(s1)          // load player struct free space used for timer and ammo

        addiu   t0, r0, 0x001E
        addiu   at, at, 0x0001

        bne     at, t0, _end
        sh      at, 0x0AE0(s1)          // save updated timer

        sh      r0, 0x0AE0(s1)          // restart timer

        lw      at, 0x0024(s1)          // load current action
        addiu   t0, r0, Kirby.Action.BOWSER_NSP_Ground          // NSP Action

        beq     at, t0, _end            // don't update ammo if currently in nsp
        addiu   t0, r0, Kirby.Action.BOWSER_NSP_Air          // NSP Action

        beq     at, t0, _end            // don't update ammo if currently in nsp
        lhu     at, 0xAE2(s1)           // load ammo

        addiu   t0, r0, 0x0014          // max ammo for bowser

        beq     t0, at, _end
        addiu   at, at, 0x0002

        beq     r0, r0, _end
        sh      at, 0xAE2(s1)           // save updated ammo

        _end:
        lw      t0, 0x0008(s1)           // original line 1, loads character ID
        j       _return                  // return
        addiu   at, r0, 0x0008           // original line 2, places Kirby Character ID into at for check
    }

	// IMPORTANT NOTE: Bowser Copter code is in captainshared.asm and must be changed when the Copter is changed.
    // IMPORTANT NOTE: Ammo is refilled at limbo_clear in SinglePlayerModes.asm
   }
