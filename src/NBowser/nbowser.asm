// NBowser.asm

// This file contains file inclusions, action edits, and assembly for NBowser.

scope NBowser {
    // Insert Moveset files

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NBOWSER,    Action.Entry,      		File.BOWSER_IDLE,   		 -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ReviveWait,      File.BOWSER_IDLE,   		 -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    0x06,      				File.BOWSER_IDLE,   		 -1,                        -1)

	Character.edit_action_parameters(NBOWSER,    Action.Walk1,      		File.BOWSER_WALK1,   		 -1,                     	-1)
	Character.edit_action_parameters(NBOWSER,    Action.Walk2,      		File.BOWSER_WALK2,   		 Bowser.WALK2,                     -1)
	Character.edit_action_parameters(NBOWSER,    Action.Walk3,      		File.BOWSER_WALK3,   		 Bowser.WALK3,                     -1)

    Character.edit_action_parameters(NBOWSER,    Action.DamageHigh1,     File.BOWSER_DAMAGE_HIGH_1,   -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DamageHigh2,     File.BOWSER_DAMAGE_HIGH_2,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageHigh3,     File.BOWSER_DAMAGE_HIGH_3,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageMid1,      File.BOWSER_DAMAGE_MID_1,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageMid2,      File.BOWSER_DAMAGE_MID_2,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageMid3,      File.BOWSER_DAMAGE_MID_3,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageLow1,      File.BOWSER_DAMAGE_LOW_1,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageLow2,      File.BOWSER_DAMAGE_LOW_2,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageLow3,      File.BOWSER_DAMAGE_LOW_3,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageAir1,      File.BOWSER_DAMAGE_AIR_1,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageAir2,      File.BOWSER_DAMAGE_AIR_2,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageAir3,      File.BOWSER_DAMAGE_AIR_3,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageElec1,     File.BOWSER_DAMAGE_ELEC,     -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageElec2,     File.BOWSER_DAMAGE_ELEC,     -1,                        -1)

    Character.edit_action_parameters(NBOWSER,    Action.Sleep,     		File.BOWSER_STUNNED,     	 Bowser.SLEEP,                     -1)
	Character.edit_action_parameters(NBOWSER,    Action.Stun,     		File.BOWSER_STUNNED,     	 Bowser.STUN,                      -1)
	Character.edit_action_parameters(NBOWSER,    Action.ShieldBreak,     -1,     					 Bowser.SHIELD_BREAK,              -1)
	Character.edit_action_parameters(NBOWSER,    Action.Tech,     		File.BOWSER_TECH,     		 Bowser.TECH,              		-1)
	Character.edit_action_parameters(NBOWSER,    Action.TechF,     		File.BOWSER_TECH_F,     	 Bowser.TECHF,              		-1)
	Character.edit_action_parameters(NBOWSER,    Action.TechB,     		File.BOWSER_TECH_B,     	 Bowser.TECHF,              		-1)

	Character.edit_action_parameters(NBOWSER,    Action.EnterPipe,       File.BOWSER_ENTER_PIPE,      -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ExitPipe,        File.BOWSER_EXIT_PIPE,       -1,                        -1)

    Character.edit_action_parameters(NBOWSER,    Action.Crouch,          File.BOWSER_CROUCH,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.CrouchIdle,      File.BOWSER_CROUCH_IDLE,     -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.CrouchEnd,       File.BOWSER_CROUCH_END,      -1,                        -1)

    Character.edit_action_parameters(NBOWSER,    Action.CeilingBonk,     File.BOWSER_CEILING_BONK,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DownBounceD,     File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.StunLandD,       File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.Revive1,         File.BOWSER_DOWN_BOUNCE_D,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DownBounceU,     File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.StunLandU,       File.BOWSER_DOWN_BOUNCE_U,   -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DownStandD,      File.BOWSER_DOWN_STAND_D,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownStandU,      File.BOWSER_DOWN_STAND_U,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.Revive2,         File.BOWSER_DOWN_STAND_D,    -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.StunStartD,      File.BOWSER_DOWN_STAND_D,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.StunStartU,      File.BOWSER_DOWN_STAND_U,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownForwardD,    File.BOWSER_DOWN_FORWARD_D,  -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownForwardU,    File.BOWSER_DOWN_FORWARD_U,  -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownBackD,    	File.BOWSER_DOWN_BACK_D,     -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownBackU,       File.BOWSER_DOWN_BACK_U,     -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownAttackU,     File.BOWSER_DOWN_ATTACK_U,   Bowser.DOWNATTACK_U,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DownAttackD,     File.BOWSER_DOWN_ATTACK_D,   Bowser.DOWNATTACK_D,                        -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.CliffCatch, 		File.BOWSER_CLIFFCATCH, 	 -1,              			-1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffWait, 		File.BOWSER_CLIFFWAIT, 	     -1,              			-1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffQuick, 		File.BOWSER_CLIFFQUICK, 	 -1,              			-1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffSlow, 		File.BOWSER_CLIFFSLOW, 	     -1,              			-1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffClimbQuick1, File.BOWSER_CLIFF_CLIMB_QUICK_1, -1,                   -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffClimbQuick2, File.BOWSER_CLIFF_CLIMB_QUICK_2, -1,                   -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffClimbSlow1, File.BOWSER_CLIFF_CLIMB_SLOW_1, -1,                     -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffClimbSlow2, File.BOWSER_CLIFF_CLIMB_SLOW_2, -1,                     -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffEscapeQuick1, File.BOWSER_CLIFF_ESCAPE_QUICK_1, -1,                 -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffEscapeQuick2, File.BOWSER_CLIFF_ESCAPE_QUICK_2, -1,                 -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffEscapeSlow1, File.BOWSER_CLIFF_ESCAPE_SLOW_1, -1,                   -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffEscapeSlow2, File.BOWSER_CLIFF_ESCAPE_SLOW_2, -1,                   -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffAttackQuick1, File.BOWSER_CLIFFATTACKQ1, Bowser.EDGEATTACKF1,              -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffAttackQuick2, File.BOWSER_CLIFFATTACKQ2, Bowser.EDGEATTACKF2,              -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffAttackSlow1, File.BOWSER_CLIFFATTACKS1,  Bowser.EDGEATTACKS1,              -1)
	Character.edit_action_parameters(NBOWSER,    Action.CliffAttackSlow2, File.BOWSER_CLIFFATTACKS2,  Bowser.EDGEATTACKS2,              -1)

    Character.edit_action_parameters(NBOWSER,    Action.DamageFlyHigh,   File.BOWSER_DAMAGE_FLY_HIGH, -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.DamageFlyMid,    File.BOWSER_DAMAGE_FLY_MID,  -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageFlyLow,    File.BOWSER_DAMAGE_FLY_LOW,  -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageFlyTop,    File.BOWSER_DAMAGE_FLY_TOP,  -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DamageFlyRoll,   File.BOWSER_DAMAGE_FLY_ROLL, -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.DeadU,           File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ScreenKO,        File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.WallBounce,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.Tumble,          File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.Tornado,         File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ShieldBreak,     File.BOWSER_DAMAGE_FLY_TOP,  -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ShieldBreakFall, File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.InhalePulled,    File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.InhaleSpat,      File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.InhaleCopied,    File.BOWSER_TUMBLE,          -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.FalconDivePulled, File.BOWSER_DAMAGE_HIGH_3,  -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    0xB4,                   File.BOWSER_TUMBLE,          -1,                        -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.LightItemPickup, File.BOWSER_LIGHT_ITEM_PICK, -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.HeavyItemPickup, File.BOWSER_HEAVY_ITEM_PICK, -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ItemDrop,        File.BOWSER_ITEM_DROP,       -1,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.ItemThrowDash,   File.BOWSER_ITEM_THROW_DASH, -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowF,      File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowB,      File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowSmashF, File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowSmashF, File.BOWSER_ITEM_THROW_F,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowU,      File.BOWSER_ITEM_THROW_U,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowSmashU, File.BOWSER_ITEM_THROW_U,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowD,      File.BOWSER_ITEM_THROW_D,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowSmashD, File.BOWSER_ITEM_THROW_D,    -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirF,   File.BOWSER_ITEM_THROW_F_AIR, -1,                       -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirSmashF, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirB,   File.BOWSER_ITEM_THROW_F_AIR,    -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirSmashB, File.BOWSER_ITEM_THROW_F_AIR, -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirU,   File.BOWSER_ITEM_THROW_U_AIR,    -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirSmashU, File.BOWSER_ITEM_THROW_U_AIR, -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirD,   File.BOWSER_ITEM_THROW_D_AIR,    -1,                    -1)
	Character.edit_action_parameters(NBOWSER,    Action.ItemThrowAirSmashD, File.BOWSER_ITEM_THROW_D_AIR, -1,                    -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.HeavyItemThrowF, File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.HeavyItemThrowB, File.BOWSER_HEAVY_ITEM_THROW, -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.HeavyItemThrowSmashF, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)
	Character.edit_action_parameters(NBOWSER,    Action.HeavyItemThrowSmashB, File.BOWSER_HEAVY_ITEM_THROW, -1,                   -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.RayGunShoot,     File.BOWSER_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.RayGunShootAir,  File.BOWSER_RAYGUN_AIR,      -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.FireFlowerShoot, File.BOWSER_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.FireFlowerShootAir, File.BOWSER_RAYGUN_AIR,   -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.HammerIdle,      File.BOWSER_HAMMER_IDLE,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.HammerWalk,      File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.HammerTurn,      File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.HammerJumpSquat, File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.HammerAir,       File.BOWSER_HAMMER_WALK,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.HammerLanding,   File.BOWSER_HAMMER_WALK,     -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.CapturePulled,   File.BOWSER_EGG_LAY_PULLED,  -1,                    	 -1)
    Character.edit_action_parameters(NBOWSER,    Action.EggLay,    		File.BOWSER_IDLE, 		     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.EggLayPulled,    File.BOWSER_EGG_LAY_PULLED,  -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.ThrownDKPulled,  -1,                          -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.ThrownDK,        -1,                          -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.Thrown1,         File.BOWSER_THROWN_1,        -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.Thrown2,         File.BOWSER_THROWN_2,        -1,                         -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.Taunt,           File.BOWSER_TAUNT,          Bowser.TAUNT,                      -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.Turn,            File.BOWSER_TURN,           Bowser.TURN,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.Jab1,            File.BOWSER_JAB1,           Bowser.JAB1,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.Jab2,            File.BOWSER_JAB2,           Bowser.JAB2,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.DTilt,           File.BOWSER_DTILT,          Bowser.DTILT,                      -1)
    Character.edit_action_parameters(NBOWSER,    Action.AttackAirN,      File.BOWSER_NAIR,           Bowser.NAIR,                       -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.Idle,            File.BOWSER_IDLE,           -1,                         0x00000000)
    Character.edit_action_parameters(NBOWSER,    Action.JumpSquat,       File.BOWSER_LANDING,        -1,                         0x00000000)
    Character.edit_action_parameters(NBOWSER,    Action.ShieldJumpSquat, File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(NBOWSER,    Action.LandingLight,    File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(NBOWSER,    Action.LandingHeavy,    File.BOWSER_LANDING,        -1,                         0x00000000)
	Character.edit_action_parameters(NBOWSER,    Action.LandingSpecial,  File.BOWSER_LANDING,        -1,                         0x00000000)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.Fall,            File.BOWSER_FALL,           -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.FallAerial,      File.BOWSER_FALL2,           -1,                        -1)
	Character.edit_action_parameters(NBOWSER,    Action.AttackAirF,      File.BOWSER_FAIR,           Bowser.FAIR,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.LandingAirF,     File.BOWSER_FAIR_LAND,      -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.LandingAirN,     File.BOWSER_LANDING,        -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.Grab,            File.BOWSER_GRAB,           Bowser.GRAB,                       0x10000000)
    Character.edit_action_parameters(NBOWSER,    Action.FSmash,          File.BOWSER_FSMASH,         Bowser.FSMASH,                     0x40000000)
    Character.edit_action_parameters(NBOWSER,    Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(NBOWSER,    Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(NBOWSER,    Action.DSmash,          -1,                         Bowser.DSMASH,                     -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.GrabPull,        File.BOWSER_PULL,           Bowser.GRAB_PULL,                  0x10000000)
    Character.edit_action_parameters(NBOWSER,    Action.ThrowB,          File.BOWSER_BTHROW,         Bowser.BTHROW,                     0x10000000)
	Character.edit_action_parameters(NBOWSER,    Action.ThrownMarioBros, File.BOWSER_THROWN_MARIO,   -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.ShieldOn, 		File.BOWSER_SHIELD_ON,   	-1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.ShieldOff, 		File.BOWSER_SHIELD_OFF,   	-1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.ShieldDrop, 		File.BOWSER_SHIELD_DROP,   	-1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.Pass, 			File.BOWSER_SHIELD_DROP,   	-1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.RollF, 			File.BOWSER_ROLL_F,   	    -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.RollB, 			File.BOWSER_ROLL_B,   	    -1,                         -1)
                                     
    Character.edit_action_parameters(NBOWSER,    0xE0,                   File.BOWSER_BOMB_GROUND,    Bowser.DSP_GROUND,                 -1)
    Character.edit_action_parameters(NBOWSER,    0xE1,                   File.BOWSER_BOMB_LAND,      Bowser.DSP_LAND,                   -1)
    Character.edit_action_parameters(NBOWSER,    0xE2,                   File.BOWSER_BOMB_AIR,       Bowser.DSP_AIR,                    -1)
    Character.edit_action_parameters(NBOWSER,    0xE5,                   File.BOWSER_FTHROW,         Bowser.FTHROW,                     0x50000000)
    Character.edit_action_parameters(NBOWSER,    0xE6,                   File.BOWSER_FTHROW_2,       Bowser.FTHROW_2,                   0x50000000)
    Character.edit_action_parameters(NBOWSER,    0xE8,                   File.BOWSER_FTHROW_3,       Bowser.FTHROW_3,                   0x50000000)
    Character.edit_action_parameters(NBOWSER,    0xDE,                   File.BOWSER_USP_GROUND,     Bowser.USPG,                       0x00000000)
    Character.edit_action_parameters(NBOWSER,    0xDF,                   File.BOWSER_USP_AIR,        Bowser.USPA,                       0x00000000)
    Character.edit_action_parameters(NBOWSER,    0xE4,                   File.BOWSER_FIRE,           Bowser.NSP,                        0x00000001)
    Character.edit_action_parameters(NBOWSER,    0xE7,                   File.BOWSER_FIRE,           Bowser.NSP,                        0x00000001)
    Character.edit_action_parameters(NBOWSER,    0xE9,                   File.BOWSER_JAB3,           Bowser.JAB3,                       0x40000000)
    Character.edit_action_parameters(NBOWSER,    Action.FallSpecial,     File.BOWSER_SFALL,          -1,                         -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.AttackAirB,      File.BOWSER_BAIR,           Bowser.BAIR,                       -1)
	Character.edit_action_parameters(NBOWSER,    Action.LandingAirB,     File.BOWSER_BAIR_LANDING,   -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.AttackAirU,      File.BOWSER_UAIR,           Bowser.UAIR,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.AttackAirD,      File.BOWSER_DAIR,           Bowser.DAIR,                       0x00000000)
    Character.edit_action_parameters(NBOWSER,    Action.LandingAirD,     File.BOWSER_DAIR_LAND,      Bowser.DAIR_LAND,                  0x00000000)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.UTilt,           File.BOWSER_UTILT,          Bowser.UTILT,                      -1)
    Character.edit_action_parameters(NBOWSER,    Action.USmash,          File.BOWSER_USMASH,         Bowser.USMASH,                     -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.DSmash,          File.BOWSER_DSMASH,         -1,                     	-1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.Teeter,          File.BOWSER_TEETER_LOOP,    Bowser.TEETER,                     -1)
    Character.edit_action_parameters(NBOWSER,    Action.TeeterStart,     File.BOWSER_TEETER_START,   -1,                         -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.FTiltHigh,       File.BOWSER_FTILT_HIGH,     Bowser.FTILT_HIGH,                 -1)
    Character.edit_action_parameters(NBOWSER,    Action.FTilt,           File.BOWSER_FTILT,          Bowser.FTILT,                      -1)
    Character.edit_action_parameters(NBOWSER,    Action.FTiltLow,        File.BOWSER_FTILT_LOW,      Bowser.FTILT_LOW,                  -1)
                                     
    Character.edit_action_parameters(NBOWSER,    Action.Dash,            File.BOWSER_DASH,           Bowser.DASH,                       -1)
    Character.edit_action_parameters(NBOWSER,    Action.Run,             File.BOWSER_RUN,            Bowser.RUN,                        -1)
    Character.edit_action_parameters(NBOWSER,    Action.TurnRun,         File.BOWSER_TURN_RUN,       Bowser.TURN_RUN,                   -1)
    Character.edit_action_parameters(NBOWSER,    Action.RunBrake,        File.BOWSER_RUN_BRAKE,      -1,                         -1)
    Character.edit_action_parameters(NBOWSER,    Action.DashAttack,      File.BOWSER_DASH_ATTACK,    Bowser.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NBOWSER,    Action.JumpF,           File.BOWSER_JUMPF,          Bowser.JUMP1,                      -1)
    Character.edit_action_parameters(NBOWSER,    Action.JumpB,           File.BOWSER_JUMPB,          Bowser.JUMP1,                      -1)
    Character.edit_action_parameters(NBOWSER,    Action.JumpAerialB,     File.BOWSER_JUMP2_B,        Bowser.JUMP2,                      0x00000000)
    Character.edit_action_parameters(NBOWSER,    Action.JumpAerialF,     File.BOWSER_JUMP2,          Bowser.JUMP2,                      -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.BeamSwordNeutral, File.BOWSER_SWING_NEUTRAL, -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BeamSwordTilt,   File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BeamSwordSmash,  File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BeamSwordDash,   File.BOWSER_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.BatNeutral, 		File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BatTilt,   		File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BatSmash,  		File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.BatDash,   		File.BOWSER_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.FanNeutral, 		File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.FanTilt,   		File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.FanSmash,  		File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.FanDash,   		File.BOWSER_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NBOWSER,    Action.StarRodNeutral,  File.BOWSER_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.StarRodTilt,     File.BOWSER_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.StarRodSmash,    File.BOWSER_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    Action.StarRodDash,     File.BOWSER_SWING_DASH,     -1,                         -1)
	Character.edit_action_parameters(NBOWSER,    0xDC,     				File.BOWSER_IDLE,     		0x80000000,                      0x00000000)
	Character.edit_action_parameters(NBOWSER,    0xDD,     				File.BOWSER_IDLE,     		0x80000000,                      0x00000000)


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM                  // Movement/Physics ASM                         // Collision ASM
    Character.edit_action(NBOWSER, 0xDC,             -1,             0x8013D994,                 0x00000000,                            0x00000000,                                     0x00000000)
    Character.edit_action(NBOWSER, 0xDD,             -1,             0x8013D994,                 0x00000000,                            0x00000000,                                     0x00000000)
    Character.edit_action(NBOWSER, 0xDE,             -1,             0x8015B6D0,                 -1,                                    BowserUSP.ground_physics_,                      -1)
    Character.edit_action(NBOWSER, 0xDF,             -1,             0x8015B6F0,                 -1,       			                    BowserUSP.air_physics_,                         -1)
    Character.edit_action(NBOWSER, 0xE0,             -1,             -1,                         -1,                                    -1,                                             -1)
    Character.edit_action(NBOWSER, 0xE2,             -1,             -1,                         -1,                                    BowserDSP.air_physics_,                         -1)
    Character.edit_action(NBOWSER, 0xE4,             -1,             BowserNSP.main_,            -1,                                    0x800D8BB4,                                     0x800DDF44)
    Character.edit_action(NBOWSER, 0xE7,             -1,             BowserNSP.main_,            -1,                                    -1,                                             BowserNSP.air_collision_)             //0x800DE934
    Character.edit_action(NBOWSER, 0xE5,             0x23,           BowserFThrow.main_,         0x00000000,                            0x800D93E4,                                     BowserFThrow.collision_)
    Character.edit_action(NBOWSER, 0xE6,             0x0,            0x00000000,                 0x00000000,                            0x00000000,                                     BowserFThrow.collision_)
    Character.edit_action(NBOWSER, 0xE8,             -1,             0x8014A0C0,                 0x00000000,                            0x8014A4F8,                                     0x8014A538)
    Character.edit_action(NBOWSER, 0xE9,             0x3,            0x800D94C4,                 0x00000000,                            0x800D8C14,                                     0x800DDF44)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NBOWSER,    0x0,               File.BOWSER_IDLE,           -1,                            -1)
	Character.edit_menu_action_parameters(NBOWSER,    0x1,               File.BOWSER_DANCE,          Bowser.VICTORY2,                      -1)
	Character.edit_menu_action_parameters(NBOWSER,    0x2,               File.BOWSER_CSS,            Bowser.CSS,                           -1)
    Character.edit_menu_action_parameters(NBOWSER,    0x3,               File.BOWSER_LAUGH,          Bowser.VICTORY1,                      -1)
	Character.edit_menu_action_parameters(NBOWSER,    0x5,               File.BOWSER_CLAP,           Bowser.CLAP,                          -1)
    Character.edit_menu_action_parameters(NBOWSER,    0xE,               File.BOWSER_1P_CPU,         0x80000000,                    -1)
    Character.edit_menu_action_parameters(NBOWSER,    0xD,               File.BOWSER_1P,             -1,                            -1)
    Character.edit_menu_action_parameters(NBOWSER,    0x9,               File.BOWSER_CONTINUE_FALL,  -1,                            -1)
    Character.edit_menu_action_parameters(NBOWSER,    0xA,               File.BOWSER_CONTINUE_UP,    -1,                            -1)

    Character.table_patch_start(variant_original, Character.id.NBOWSER, 0x4)
    dw      Character.id.BOWSER // set Bowser as original character (not Yoshi, who NBOWSER is a clone of)
    OS.patch_end()
    
    Character.table_patch_start(air_usp, Character.id.NBOWSER, 0x4)
    dw      BowserUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.NBOWSER, 0x4)
    dw      BowserNSP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.NBOWSER, 0x4)
    dw      BowserNSP.air_initial_
    OS.patch_end()

	// Removes Entry Script
    Character.table_patch_start(entry_script, Character.id.NBOWSER, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NBOWSER, 0x2)
    dh  0x0363
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NBOWSER, 0x4)
    float32 1.2
    OS.patch_end()

	// Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.NBOWSER, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.NBOWSER, 0xC)
    dh 0x8
    OS.patch_end()

	// Set Yoshi Egg Size override ID, these values are just copied from DK
    Character.table_patch_start(yoshi_egg, Character.id.NBOWSER, 0x1C)
    dw  0x40600000
	dw	0x00000000
	dw	0x43660000
	dw	0x00000000
	dw	0x43750000
	dw	0x43750000
	dw	0x43750000
    OS.patch_end()

    // Add Jab 3
    Character.table_patch_start(jab_3_timer, Character.id.NBOWSER, 0x4)
    dw 0x8014EB54                           // jab 3 timer routine copied from Mario
    OS.patch_end()
    Character.table_patch_start(jab_3_action, Character.id.NBOWSER, 0x4)
    dw set_jab_3_action_                    // subroutine which sets action id
    OS.patch_end()
    Character.table_patch_start(jab_3, Character.id.NBOWSER, 0x4)
    dw Character.jab_3.ENABLED              // jab 3 = ENABLED
    OS.patch_end()


        // @ Description
    // Sets NBowser's Jab 3 action.
    scope set_jab_3_action_: {
        ori     t7, r0, 0x00E9              // t7 = action id
        j       0x8014EC30                  // return
        sw      t7, 0x0020(sp)              // store action id
    }
    
    // @ Description
    // NBowser's extra actions
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
        string_0x0E4:; String.insert("FireBreath")
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
    Character.table_patch_start(action_string, Character.id.NBOWSER, 0x4)
    dw  Action.action_string_table
    OS.patch_end()
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NBOWSER, 0, 1, 4, 5, 1, 3, 2)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(NBOWSER, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NBOWSER, 0x4)
    dw      Bowser.CPU_ATTACKS
    OS.patch_end()
   }
