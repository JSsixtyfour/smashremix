// NWolf.asm

// This file contains file inclusions, action edits, and assembly for Polygon Wolf.

scope NWolf {
    // Insert Moveset files


    // Modify Action Parameters             // Action                   // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NWOLF,  Action.Idle,                File.WOLF_IDLE,         	Wolf.IDLE,               	-1)
	Character.edit_action_parameters(NWOLF,  0xE1,                       File.WOLF_NSP,             Wolf.NSP_GROUND,               	-1)
 	Character.edit_action_parameters(NWOLF,  0xE2,                       File.WOLF_NSP_AIR,          Wolf.NSP_AIR,               	-1)
	Character.edit_action_parameters(NWOLF,  0xE3,                       File.WOLF_USP_1,            Wolf.USP_1,               			0x00000000)
	Character.edit_action_parameters(NWOLF,  0xE8,                       File.WOLF_USP_2,            Wolf.USP_2,               			0x00000000)
    Character.edit_action_parameters(NWOLF,  0xE4,                       File.WOLF_USP_1,            Wolf.USP_1,               			0x00000000)
	Character.edit_action_parameters(NWOLF,  0xE6,                       File.WOLF_USP_2,            Wolf.USP_2,               			0x00000000)
                                     
	Character.edit_action_parameters(NWOLF,  0xEF,                       -1,         		        Wolf.DSP_LOOP,               	-1)
	Character.edit_action_parameters(NWOLF,  0xF0,                       -1,         		        Wolf.DSP_LOOP,               	-1)
	Character.edit_action_parameters(NWOLF,  0xF4,                       -1,         		        Wolf.DSP_LOOP,               	-1)
	Character.edit_action_parameters(NWOLF,  0xF5,                       -1,         		        Wolf.DSP_LOOP,               	-1)
                                     
    Character.edit_action_parameters(NWOLF, Action.RollF,                -1,                        Wolf.FROLL,                      -1)
    Character.edit_action_parameters(NWOLF, Action.RollB,                -1,                        Wolf.BROLL,                      -1)
                                     
	Character.edit_action_parameters(NWOLF,  0xEC,                       -1,         		        Wolf.DSP_INITIAL,               	-1)
	Character.edit_action_parameters(NWOLF,  0xEE,                       File.WOLF_DSP_END_GRND,     -1,               	    -1)
    Character.edit_action_parameters(NWOLF,  0xF1,          		        -1,           		        Wolf.DSP_INITIAL,                     -1)
    Character.edit_action_parameters(NWOLF,  0xF3,                       File.WOLF_DSP_END_AIR,      -1,               	    -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.Sleep,             -1,                      Wolf.ASLEEP,                     -1)
    Character.edit_action_parameters(NWOLF,    Action.ShieldBreak,       -1,                      Wolf.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NWOLF,    Action.Stun,              -1,                      Wolf.STUN,                       -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.ShieldOn,          File.WOLF_SHIELDON,       -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.ShieldOff,         File.WOLF_SHIELDOFF,      -1,                       -1)
	Character.edit_action_parameters(NWOLF,    Action.FallSpecial,       File.WOLF_FALLSPECIAL,    -1,                       -1)
	Character.edit_action_parameters(NWOLF,    Action.Teeter,            -1,                     Wolf.TEETER,                   -1)
	Character.edit_action_parameters(NWOLF, 	  Action.LightItemPickup,   File.WOLF_ITEM_PICKUP,          -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemDrop,          File.WOLF_ITEM_DROP,          -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowF,        File.WOLF_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowB,        File.WOLF_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowSmashF,   File.WOLF_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowSmashB,   File.WOLF_ITEM_THROWF,        -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowU,        File.WOLF_ITEM_THROWU,        -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowSmashU,   File.WOLF_ITEM_THROWU,        -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowD,        File.WOLF_ITEM_THROWD,        -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowSmashD,   File.WOLF_ITEM_THROWD,        -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowDash,     File.WOLF_ITEM_THROW_DASH,    -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirF,      File.WOLF_ITEM_THROWF_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirB,      File.WOLF_ITEM_THROWF_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirU,      File.WOLF_ITEM_THROWU_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirD,      File.WOLF_ITEM_THROWD_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirSmashF, File.WOLF_ITEM_THROWF_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirSmashB, File.WOLF_ITEM_THROWF_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirSmashU, File.WOLF_ITEM_THROWU_AIR,        -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.ItemThrowAirSmashD, File.WOLF_ITEM_THROWD_AIR,        -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.BeamSwordNeutral, File.WOLF_SWING_NEUTRAL, -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BeamSwordTilt,    File.WOLF_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BeamSwordSmash,   File.WOLF_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BeamSwordDash,    File.WOLF_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.BatNeutral, 		File.WOLF_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BatTilt,   		File.WOLF_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BatSmash,  		File.WOLF_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.BatDash,   		File.WOLF_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.FanNeutral, 		File.WOLF_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.FanTilt,   		File.WOLF_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.FanSmash,  		File.WOLF_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.FanDash,   		File.WOLF_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.StarRodNeutral,  File.WOLF_SWING_NEUTRAL,  -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.StarRodTilt,     File.WOLF_SWING_TILT,     -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.StarRodSmash,    File.WOLF_SWING_SMASH,    -1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.StarRodDash,     File.WOLF_SWING_DASH,     -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.RayGunShoot,     File.WOLF_RAYGUN_GND,      -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.RayGunShootAir,  File.WOLF_RAYGUN_AIR,      -1,                         -1)
                                     
	Character.edit_action_parameters(NWOLF, 	  Action.FireFlowerShoot, File.WOLF_RAYGUN_GND,      -1,                        -1)
    Character.edit_action_parameters(NWOLF,    Action.FireFlowerShootAir, File.WOLF_RAYGUN_AIR,    -1,                        -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.ShieldDrop, 		 File.WOLF_SHIELD_DROP,   			-1,                         -1)
	Character.edit_action_parameters(NWOLF,    Action.Pass, 				 File.WOLF_SHIELD_DROP,   			-1,                         -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.Taunt,          File.WOLF_TAUNT,          Wolf.TAUNT,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.Grab,           File.WOLF_GRAB,           -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.GrabPull,       File.WOLF_PULL,         -1,                  -1)
	Character.edit_action_parameters(NWOLF,    Action.ThrowF,         File.WOLF_THROWF,         Wolf.FTHROW,                       0x50000000)
    Character.edit_action_parameters(NWOLF,    Action.ThrowB,         -1,                       Wolf.BTHROW,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Turn,           File.WOLF_TURN,           -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Jab1,           File.WOLF_JAB1,           Wolf.JAB1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Jab2,           File.WOLF_JAB2,           Wolf.JAB2,                       -1)
	Character.edit_action_parameters(NWOLF,    0xDC,            	     File.WOLF_JAB3,         Wolf.JAB3,                     0x40000000)
                                     
	Character.edit_action_parameters(NWOLF,    Action.DTilt,          File.WOLF_DTILT,          Wolf.DTILT,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.UTilt,          File.WOLF_UTILT,          Wolf.UTILT,                      -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.Entry,      	 File.WOLF_IDLE,   		 Wolf.IDLE,                        -1)
	Character.edit_action_parameters(NWOLF,    Action.ReviveWait,     File.WOLF_IDLE,   		 Wolf.IDLE,                        -1)
	Character.edit_action_parameters(NWOLF,    0x06,      		     File.WOLF_IDLE,   		 Wolf.IDLE,                        -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.Walk1,      	 File.WOLF_WALK1,   		 Wolf.IDLE,                     	-1)
	Character.edit_action_parameters(NWOLF,    Action.Walk2,      	 File.WOLF_WALK2,   		 Wolf.IDLE,                     -1)
	Character.edit_action_parameters(NWOLF,    Action.Walk3,      	 File.WOLF_WALK3,   		 Wolf.IDLE,                     -1)
    Character.edit_action_parameters(NWOLF,    Action.Idle,           File.WOLF_IDLE,             -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.JumpSquat,      File.WOLF_JUMP_SQUAT,        -1,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.ShieldJumpSquat, File.WOLF_JUMP_SQUAT,        -1,                      -1)
	Character.edit_action_parameters(NWOLF,    Action.LandingLight,   File.WOLF_JUMP_SQUAT,        -1,                      -1)
	Character.edit_action_parameters(NWOLF,    Action.LandingHeavy,   File.WOLF_JUMP_SQUAT,        -1,                      -1)
	Character.edit_action_parameters(NWOLF,    Action.LandingSpecial, File.WOLF_JUMP_SQUAT,        -1,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.LandingAirX,    File.WOLF_JUMP_SQUAT,        -1,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.LandingAirF,    File.WOLF_FAIR_LANDING,      -1,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.LandingAirB,    File.WOLF_BAIR_LANDING,      -1,                      -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.Fall,            File.WOLF_FALLING,           -1,                         -1)
    Character.edit_action_parameters(NWOLF,    Action.FallAerial,      File.WOLF_FALLING_AERIAL,    -1,                        -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.AttackAirN,      File.WOLF_NAIR,           Wolf.NAIR,                       -1)
	Character.edit_action_parameters(NWOLF,    Action.AttackAirF,      File.WOLF_FAIR,           Wolf.FAIR,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.AttackAirB,      File.WOLF_BAIR,           Wolf.BAIR,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.AttackAirU,      File.WOLF_UAIR,           Wolf.UAIR,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.AttackAirD,      File.WOLF_DAIR,           Wolf.DAIR,                       -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.FSmash,          File.WOLF_FSMASH,         Wolf.FSMASH,                        0x40000000)
    Character.edit_action_parameters(NWOLF,    Action.FSmashHigh,      0,                          0x80000000,              0)
    Character.edit_action_parameters(NWOLF,    Action.FSmashLow,       0,                          0x80000000,              0)
    Character.edit_action_parameters(NWOLF,    Action.USmash,          File.WOLF_USMASH,         Wolf.USMASH,                      -1)
	Character.edit_action_parameters(NWOLF,    Action.DSmash,          File.WOLF_DSMASH,         Wolf.DSMASH,                      -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.FTiltHigh,       File.WOLF_FTILT_HIGH,     Wolf.FTILT_HIGH,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.FTiltMidHigh,    0,                        0x80000000,               0)
	Character.edit_action_parameters(NWOLF,    Action.FTilt,           File.WOLF_FTILT_MID,      Wolf.FTILT_MID,                      -1)
    Character.edit_action_parameters(NWOLF,    Action.FTiltMidLow,     0,          				 0x80000000,                      0)
	Character.edit_action_parameters(NWOLF,    Action.FTiltLow,        File.WOLF_FTILT_LOW,      Wolf.FTILT_LOW,               -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.Dash,            File.WOLF_DASH,           Wolf.DASH,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Run,             File.WOLF_RUN,            Wolf.RUN,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.TurnRun,         File.WOLF_TURN_RUN,       -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.RunBrake,        File.WOLF_RUN_BRAKE,      -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DashAttack,      File.WOLF_DASH_ATTACK,    Wolf.DASHATTACK,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.JumpF,           File.WOLF_JUMP_F,          -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.JumpB,           File.WOLF_JUMP_B,          -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.JumpAerialB,     File.WOLF_JUMP_AB,        Wolf.JUMPAIR,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.JumpAerialF,     File.WOLF_JUMP_AF,        Wolf.JUMPAIR,                     -1)
                                     
	Character.edit_action_parameters(NWOLF,    Action.Crouch,          File.WOLF_CROUCH,          -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.CrouchIdle,      File.WOLF_CROUCH_IDLE,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.CrouchEnd,       File.WOLF_CROUCH_END,      -1,                       -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.Tech,            File.WOLF_TECH,           Wolf.TECH_STAND,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.TechF,           File.WOLF_TECHF,          Wolf.TECH_ROLL,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.TechB,           File.WOLF_TECHB,          Wolf.TECH_ROLL,               -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.DownStandD,      File.WOLF_DOWNSTANDD,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Revive2,         File.WOLF_DOWNSTANDD,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.StunStartD,      File.WOLF_DOWNSTANDD,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownForwardD,    File.WOLF_DOWNFORWARDD,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownAttackD,     File.WOLF_DOWNATTACKD,     Wolf.DOWNATTACKD,               -1)
    Character.edit_action_parameters(NWOLF,    Action.DownStandU,      File.WOLF_DOWNSTANDU,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.StunStartU,      File.WOLF_DOWNSTANDU,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownForwardU,    File.WOLF_DOWNFORWARDU,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownAttackU,     File.WOLF_DOWNATTACKU,     Wolf.DOWNATTACKU,               -1)
    Character.edit_action_parameters(NWOLF,    Action.DownBackU,       File.WOLF_DOWNBACKU,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownBackD,       File.WOLF_DOWNBACKD,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownBounceD,     File.WOLF_DOWNBOUNCED,   -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.StunLandD,       File.WOLF_DOWNBOUNCED,   -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.Revive1,         File.WOLF_DOWNBOUNCED,   -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.DownBounceU,     File.WOLF_DOWNBOUNCEU,   -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.StunLandU,       File.WOLF_DOWNBOUNCEU,   -1,                       -1)
                                     
    Character.edit_action_parameters(NWOLF,    Action.EnterPipe,       File.WOLF_ENTERPIPE,     -1,                       -1)
    Character.edit_action_parameters(NWOLF,    Action.ExitPipe,        File.WOLF_EXITPIPE,      -1,                       -1)
                                     
    Character.edit_action_parameters(NWOLF,    0xDF,                   File.WOLF_IDLE,            0x80000000,                      0x00000000)
    Character.edit_action_parameters(NWOLF,    0xE0,                   File.WOLF_IDLE,            0x80000000,                      0x00000000)


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NWOLF,  0xDC,              -1,             0x8014FE40,  				0x00000000,                     0x800D8CCC,                     0x800DDF44)
    Character.edit_action(NWOLF,  0xDF,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NWOLF,  0xE0,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
	Character.edit_action(NWOLF,  0xE1,              -1,             WolfNSP.main,  				-1,                             -1,                             -1)
	Character.edit_action(NWOLF,  0xE2,              -1,             WolfNSP.main,  				-1,                             -1,                            WolfNSP.air_collision_)
    Character.edit_action(NWOLF,  0xE4,              -1,             WolfUSP.main_air,           WolfUSP.change_direction_,      WolfUSP.physics_,              WolfUSP.collision_)
	Character.edit_action(NWOLF,  0xE3,              -1,             WolfUSP.main_ground,        WolfUSP.change_direction_,      WolfUSP.physics_,              WolfUSP.collision_)
	Character.edit_action(NWOLF,  0xE6,              -1,             WolfUSP.main_2,             WolfUSP.change_direction_,      WolfUSP.physics_,              WolfUSP.collision_)
	Character.edit_action(NWOLF,  0xE8,              -1,             WolfUSP.main_2,             WolfUSP.change_direction_,      WolfUSP.physics_,              WolfUSP.collision_)
                          
	Character.edit_action(NWOLF,  0xF4,              -1,             -1,                         -1,                             WolfDSP.physics_,                     -1)
    Character.edit_action(NWOLF,  0xF3,              -1,             -1,                         -1,                             WolfDSP.physics_,                     -1)
    Character.edit_action(NWOLF,  0xF5,              -1,             -1,                         -1,                             WolfDSP.physics_,                     -1)


    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NWOLF,    0x0,               File.WOLF_IDLE,               Wolf.IDLE,                       -1)
	Character.edit_menu_action_parameters(NWOLF,    0x1,               File.WOLF_VICTORY1,           0x80000000,                 -1)
    Character.edit_menu_action_parameters(NWOLF,    0x2,               File.WOLF_VICTORY2,           0x80000000,                 -1)
    Character.edit_menu_action_parameters(NWOLF,    0x3,               File.WOLF_CSS,                0x80000000,                 -1)
	Character.edit_menu_action_parameters(NWOLF,    0x4,               File.WOLF_CSS,                0x80000000,                 -1)
    Character.edit_menu_action_parameters(NWOLF,    0x5,               -1,                           Wolf.CLAP,                       -1)
    Character.edit_menu_action_parameters(NWOLF,    0xD,               File.WOLF_1P_HMN,             0x80000000,                 -1)
    Character.edit_menu_action_parameters(NWOLF,    0xE,               File.WOLF_1P_CPU,             Wolf.ONEP_CPU,                   -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NWOLF, 0x2)
    dh  0x02B7
    OS.patch_end()

	Character.table_patch_start(air_usp, Character.id.NWOLF, 0x4)
    dw      WolfUSP.initial_air
    OS.patch_end()
	Character.table_patch_start(ground_usp, Character.id.NWOLF, 0x4)
    dw      WolfUSP.initial_ground
    OS.patch_end()


    // Set Kirby copy power and hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x02, Character.id.NWOLF, 0xC)
    dh 0x8
    OS.patch_end()

    // @ Description
    // Polygon Wolf's extra actions
    scope Action {
        constant Jab3(0x0DC)
        //constant JabLoop(0x0DD)
        //constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant Blaster(0x0E1)
        constant BlasterAir(0x0E2)
        constant WolfFlashStartAir(0x0E3)
        constant WolfFlashStart(0x0E4)
        //constant ReadyingFireFox(0x0E5)
        constant WolfFlash(0x0E6)
        //constant FireFox(0x0E7)
        constant WolfFlashAir(0x0E8)
        //constant FireFoxEnd(0x0E9)
        //constant FireFoxEndAir(0x0EA)
        //constant LandingFireFoxAir(0x0EB)
        constant ReflectorStart(0x0EC)
        constant Reflecting(0x0ED)
        constant ReflectorEnd(0x0EE)
        constant ReflectorLoop(0x0EF)
        constant ReflectorSwitchDirection(0x0F0)
        constant ReflectorStartAir(0x0F1)
        // constant ?(0x0F2)
        constant ReflectorEndAir(0x0F3)
        constant ReflectorAir(0x0F4)
        constant ReflectorSwitchDirectionAir(0x0F5)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("JabLoop")
        //string_0x0DE:; String.insert("JabLoopEnd")
        //string_0x0DF:; String.insert("Appear1")
        //string_0x0E0:; String.insert("Appear2")
        string_0x0E1:; String.insert("Blaster")
        string_0x0E2:; String.insert("BlasterAir")
        string_0x0E3:; String.insert("WolfFlashStartAir")
        string_0x0E4:; String.insert("WolfFlashStart")
        //string_0x0E5:; String.insert("ReadyingFireFox")
        string_0x0E6:; String.insert("WolfFlash")
        //string_0x0E7:; String.insert("FireFox")
        string_0x0E8:; String.insert("WolfFlashAir")
        //string_0x0E9:; String.insert("FireFoxEnd")
        //string_0x0EA:; String.insert("FireFoxEndAir")
        //string_0x0EB:; String.insert("LandingFireFoxAir")
        //string_0x0EC:; String.insert("ReflectorStart")
        //string_0x0ED:; String.insert("Reflecting")
        //string_0x0EE:; String.insert("ReflectorEnd")
        //string_0x0EF:; String.insert("ReflectorLoop")
        //string_0x0F0:; String.insert("ReflectorSwitchDirection")
        //string_0x0F1:; String.insert("ReflectorStartAir")
        //string_0x0F2:; String.insert("ReflectingAir")
        //string_0x0F3:; String.insert("ReflectorEndAir")
        //string_0x0F4:; String.insert("ReflectorAir")
        //string_0x0F5:; String.insert("ReflectorSwitchDirectionAir")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw 0 //dw Action.COMMON.string_jabloop
        dw 0 //dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw 0 //dw Action.FOX.string_0x0E5
        dw string_0x0E6
        dw 0 //dw Action.FOX.string_0x0E7
        dw string_0x0E8
        dw 0 //dw Action.FOX.string_0x0E9
        dw 0 //dw Action.FOX.string_0x0EA
        dw 0 //dw Action.FOX.string_0x0EB
        dw Action.FOX.string_0x0EC
        dw Action.FOX.string_0x0ED
        dw Action.FOX.string_0x0EE
        dw Action.FOX.string_0x0EF
        dw Action.FOX.string_0x0F0
        dw Action.FOX.string_0x0F1
        dw Action.FOX.string_0x0F2
        dw Action.FOX.string_0x0F3
        dw Action.FOX.string_0x0F4
        dw Action.FOX.string_0x0F5
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NWOLF, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Shield colors for costume matching
    Character.set_costume_shield_colors(NWOLF, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)
    
    // Set default costumes
    Character.set_default_costumes(Character.id.NWOLF, 0, 1, 4, 5, 1, 3, 2)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NWOLF, 0x4)
    dw      Wolf.CPU_ATTACKS
    OS.patch_end()

	// Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NWOLF, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()
}
