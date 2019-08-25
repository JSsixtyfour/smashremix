// Moveset.asm (Fray)

// NOTE: THIS FILE IS TEMPORARY

// This file adds support for reading moveset data from a pointer

// @ Description
// by default, this parameter is an offset added to the base moveset file address
// by default, a value of 0x80000000 is used to indicate no moveset data
// new functionality will treat any value greater than 0x80000000 as a pointer to moveset data
scope moveset_data_: {
    // s1 = player struct
    // v0 = moveset data address
    // t2 = action parameters
    addiu   sp, sp,-0x0010              // allocate stack space
    sw      t0, 0x0004(sp)              // store t0
    sw      t1, 0x0008(sp)              // store t1
    _check_pointer:
    lw      t0, 0x0004(t2)              // t0 = moveset data offset/pointer
    bgez    t0, _end                    // skip if t0 is between 0x00000000 and 0x7FFFFFFF (offset)
    nop
    _check_none:
    lui     t1, 0x8000                  // t1 = 0x80000000
    beq     t0, t1, _end                // skip if t0 = 0x80000000 (no moveset data)
    nop
    or      v0, t0, r0                  // overwrite moveset data address
   
    _end:      
    sw      t0, 0x0004(sp)              // load t0
    lw      t1, 0x0008(sp)              // load t1
    addiu   sp, sp, 0x0010              // deallocate stack space
    sw      v0, 0x08AC(s1)              // store pointer
    sw      v0, 0x086C(s1)              // original line (store pointer)
    j       _moveset_data_return        // return
    nop
    
    
    // write changes to rom
    // moveset_data_ hook
    pushvar origin, base
    origin  0x63140
    base    0x800E7940
    j       moveset_data_
    nop
    origin  0x6316C
    base    0x800E796C
    _moveset_data_return:
    
    
    // replace moveset data
    scope gnd {
        // up tilt
        origin  0x9D4BC
        dw      GND_UTILT
        // forward smash
        origin  0x9D4DC
        dw      0x0000064E                  // animation
        dw      GND_FSMASH
        dw      0x00000000                  // animation flags
        origin  0x9D4F4
        dw      0x0000064E                  // animation
        dw      GND_FSMASH
        dw      0x00000000                  // animation flags
        origin  0x9D50C
        dw      0x0000064E                  // animation
        dw      GND_FSMASH
        dw      0x00000000                  // animation flags
        // up smash
        origin  0x9D518
        dw      0x00000854                  // animation
        dw      GND_USMASH
        dw      0x00000000                  // animation flags
        // dair
        origin  0x9D564
        dw      GND_DAIR
        // ground down special
        origin  0x9D630 
        dw      GND_DSP_GROUND
        // down special flip
        origin  0x9D63C
        dw      GND_DSP_FLIP
        // down special landing
        origin  0x9D648   
        dw      GND_DSP_LAND
        // air down special
        origin  0x9D654
        dw      GND_DSP_AIR
        // ground up special
        origin  0x9D66C
        dw      GND_USP_GROUND
        // up special grab
        origin  0x9D678
        dw      GND_USP_GRAB
        // up special release
        origin  0x9D684
        dw      GND_USP_RELEASE
        // air up special
        origin  0x9D690
        dw      GND_USP_AIR  
        // taunt
        origin  0x9D440
        dw      0x00000861                  // animation
        dw      GND_TAUNT 
		// down smash
        origin  0x9D524
		base	0x80121D24
        dw 		0x00000855					// animation
		dw      GND_DOWN_SMASH 
		// fair
		origin 0x0009D53C
		base 0x80121D3C
		dw 0x00000857
		// nair
		origin 0x0009D530
		base 0x80121D30
		dw 0x00000667
    }
    
    scope falco {
        // taunt
        origin  0x94C60
        dw      0x00000868                  // animation
        dw      FALCO_TAUNT
        // up tilt
        origin  0x94CD8
        dw      0x00000869                  // animation
        dw      FALCO_UTILT
        // forward smash
        origin  0x94D14
        dw      0x00000867                  // animation
        dw      FALCO_FSMASH
        // jab 1
        origin  0x94C70
        dw      FALCO_JAB_1
        // jab 2
        origin  0x94C7C
        dw      FALCO_JAB_2
        // dash attack
        origin  0x94C88
        dw      FALCO_DASH_ATTACK
        // up smash
        origin  0x94D3C
        dw      FALCO_USMASH
        // bair
        origin  0x94D6C
        dw      FALCO_BAIR
        // uair
        origin  0x94D78
        dw      FALCO_UAIR
        // dair
        origin  0x94D84
        dw      FALCO_DAIR
        // ground neutral special
        origin  0x94E10
        dw      0x000002E9                  // animation
        dw      FALCO_NSP_GROUND
        // air neutral special
        origin  0x94E1C
        dw      0x000002E9                  // animation
        dw      FALCO_NSP_AIR
    }
    
    scope ylink {
        // air up special
        origin  0x9ACB8
        dw      YLINK_USP_AIR
        // ground up special
        origin  0x9ACA0
        dw      YLINK_USP_GROUND
        // ground up special
        origin  0x9ACAC
        dw      YLINK_USP_GROUND_END
        // dash attack
        origin  0x9AB04
        dw      0x000004B2                  // animation
        dw      YLINK_DASH_ATTACK
        // ylink fair
        origin  0x9ABE0
        dw      YLINK_FAIR
        // ylink bair
        origin  0x9ABEC
        dw      YLINK_BAIR
        // ylink dair
        origin  0x9AC04
        dw      YLINK_DAIR
    }
    scope drm {
        // drm neutral special ground
        origin  0x92FCC
        base    0x801177CC
        dw      DRM_NSP_GROUND
        // drm neutral special air
        origin  0x92FD8
        base    0x801177D8
        dw      DRM_NSP_AIR
        // drm down special ground
        origin  0x92FFC
        base    0x801177FC
        dw      DRM_DSP_GROUND
        // drm down special air
        origin  0x93008
        base    0x80117808
        dw      DRM_DSP_AIR
        // drm up special air
        origin  0x92FF0
        base    0x801177F0
        dw      DRM_USP
        // drm up special ground
        origin  0x92FE4
        base    0x801177E4
        dw      DRM_USP
        // drm down air
        origin  0x92F50
        base    0x80117750
        dw      0x00000858                  // animation
        dw      DRM_DAIR
        dw      0x00000000                  // animation flags
        // drm up smash
        origin  0x92F0C
        base    0x8011770C
        dw      DRM_UP_SMASH
        // drm fair
        origin  0x92F2C
        base    0x8011772C
        dw      0x00000859                  // animation
        dw      DRM_FAIR
        // drm dash attack
        origin  0x92E58
        base    0x80117658
        dw      DRM_DASH_ATTACK
        // drm bair
        origin  0x92F3C
        base    0x8011773C
        dw      DRM_BAIR
        // drm uair
        origin  0x92F48
        base    0x80117748
        dw      DRM_UAIR
        // drm utilt
        origin  0x92EAC
        base    0x801176AC
        dw      DRM_UTILT
        // fsmash
        origin  0x92ED0
        base    0x801176D0
        dw      DRM_FSMASHU
        origin  0x92EDC
        base    0x801176DC
        dw      DRM_FSMASHMU
        origin  0x92EE8
        base    0x801176E8
        dw      DRM_FSMASHM
        origin  0x92EF4
        base    0x801176F4
        dw      DRM_FSMASHMD
        origin  0x92F00
        base    0x80117700
        dw      DRM_FSMASHD
        // ftilt
        origin  0x92E64
        base    0x80117664
        dw      DRM_FTILTUP
        origin  0x92E7C
        base    0x8011767C
        dw      DRM_FTILTMID
        origin  0x92E94
        base    0x80117694
        dw      DRM_FTILTDOWN
        // jab 1
        origin  0x92E40
        base    0x80117640
        dw      DRM_NEUTRAL1
        // jab 2
        origin  0x92E4C
        base    0x8011764C
        dw      DRM_NEUTRAL2
        origin  0x92FA8
        base    0x801177A8
        // jab 2
        dw      DRM_NEUTRAL3
        // dtilt
        origin  0x92EC4
        base    0x801176C4
        dw      DRM_DTILT
		// taunt
        origin  0x92E30
		base	0x80117630
        dw 		0x0000085A					// animation
		dw      DRM_TAUNT
    }
    pullvar base, origin
    
    
    // insert files
    insert  GND_UTILT,"moveset/gnd/UP_TILT.bin"
    insert  GND_FSMASH,"moveset/gnd/FORWARD_SMASH.bin"
    insert  GND_USMASH,"moveset/gnd/UP_SMASH.bin"
    insert  GND_DAIR,"moveset/gnd/DOWN_AERIAL.bin"
    insert  GND_DSP_GROUND,"moveset/gnd/DOWN_SPECIAL_GROUND.bin"
    insert  GND_DSP_FLIP,"moveset/gnd/DOWN_SPECIAL_FLIP.bin"
    insert  GND_DSP_LAND,"moveset/gnd/DOWN_SPECIAL_LANDING.bin"
    insert  GND_DSP_AIR,"moveset/gnd/DOWN_SPECIAL_AIR.bin"
    insert  GND_USP_GRAB,"moveset/gnd/UP_SPECIAL_GRAB.bin"
    insert  GND_USP_RELEASE,"moveset/gnd/UP_SPECIAL_RELEASE.bin"
    insert  GND_USP_THROWDATA,"moveset/gnd/UP_SPECIAL_THROW_DATA.bin"
    insert  GND_TAUNT,"moveset/gnd/TAUNT.bin"
    GND_USP_GROUND:
    dw      0x30000000                      // throw data pointer command
    dw      GND_USP_THROWDATA               // throw data pointer
    insert  "moveset/gnd/UP_SPECIAL_GROUND.bin"
    GND_USP_AIR:
    dw      0x30000000                      // throw data pointer command
    dw      GND_USP_THROWDATA               // throw data pointer
    insert  "moveset/gnd/UP_SPECIAL_AIR.bin"
	insert	GND_DOWN_SMASH,"moveset/gnd/DOWN_SMASH.bin"
    
    insert  FALCO_TAUNT,"moveset/falco/TAUNT.bin"
    insert  FALCO_JAB_1,"moveset/falco/JAB_1.bin"
    insert  FALCO_JAB_2,"moveset/falco/JAB_2.bin"
    insert  FALCO_DASH_ATTACK,"moveset/falco/DASH_ATTACK.bin"
    insert  FALCO_UTILT,"moveset/falco/UP_TILT.bin"
    insert  FALCO_FSMASH,"moveset/falco/FORWARD_SMASH.bin"
    insert  FALCO_USMASH,"moveset/falco/UP_SMASH.bin"
    insert  FALCO_BAIR,"moveset/falco/BACK_AERIAL.bin"
    insert  FALCO_UAIR,"moveset/falco/UP_AERIAL.bin"
    insert  FALCO_DAIR,"moveset/falco/DOWN_AERIAL.bin"
    insert  FALCO_NSP_AIR,"moveset/falco/NEUTRAL_SPECIAL_AIR.bin"
    insert  FALCO_NSP_GROUND,"moveset/falco/NEUTRAL_SPECIAL_GROUND.bin"
    
    insert  YLINK_USP_AIR,"moveset/ylink/UP_SPECIAL_AIR.bin"
    insert  YLINK_USP_GROUND,"moveset/ylink/UP_SPECIAL_GROUND.bin"
    insert  YLINK_USP_GROUND_END,"moveset/ylink/UP_SPECIAL_GROUND_END.bin"
    insert  YLINK_DASH_ATTACK, "moveset/ylink/DASH_ATTACK.bin"
    insert  YLINK_FAIR,"moveset/ylink/FORWARD_AERIAL.bin"
    insert  YLINK_BAIR,"moveset/ylink/BACK_AERIAL.bin"
    insert  YLINK_DAIR,"moveset/ylink/DOWN_AERIAL.bin"
    
    insert  DRM_NSP_GROUND, "moveset/drm/NEUTRAL_SPECIAL_GROUND.bin"
    insert  DRM_NSP_AIR, "moveset/drm/NEUTRAL_SPECIAL_AIR.bin"
    insert  DRM_DSP_GROUND, "moveset/drm/DOWN_SPECIAL_GROUND.bin"
    insert  DRM_DSP_AIR, "moveset/drm/DOWN_SPECIAL_AIR.bin"
    insert  DRM_USP, "moveset/drm/UP_SPECIAL.bin"
    insert  DRM_DAIR, "moveset/drm/DAIR.bin"
    insert  DRM_FAIR, "moveset/drm/FAIR.bin"
    insert  DRM_BAIR, "moveset/drm/BAIR.bin"
    insert  DRM_UAIR, "moveset/drm/UAIR.bin"
    insert  DRM_UP_SMASH, "moveset/drm/UP_SMASH.bin"
    insert  DRM_DASH_ATTACK, "moveset/drm/DASH_ATTACK.bin"
    insert  DRM_UTILT, "moveset/drm/UP_TILT.bin"
    insert  DRM_FSMASHD, "moveset/drm/FSMASHDOWN.bin"
    insert  DRM_FSMASHMD, "moveset/drm/FSMASHMIDDOWN.bin"
    insert  DRM_FSMASHM, "moveset/drm/FSMASHMID.bin"
    insert  DRM_FSMASHMU, "moveset/drm/FSMASHMIDUP.bin"
    insert  DRM_FSMASHU, "moveset/drm/FSMASHUP.bin"
    insert  DRM_FTILTDOWN, "moveset/drm/FTILTDOWN.bin"
    insert  DRM_FTILTMID, "moveset/drm/FTILTMID.bin"
    insert  DRM_FTILTUP, "moveset/drm/FTILTUP.bin"
    insert  DRM_NEUTRAL1, "moveset/drm/NEUTRAL1.bin"
    insert  DRM_NEUTRAL2, "moveset/drm/NEUTRAL2.bin"
    insert  DRM_NEUTRAL3, "moveset/drm/NEUTRAL3.bin"
    insert  DRM_DTILT, "moveset/drm/DTILT.bin"
    insert  DRM_TAUNT, "moveset/drm/TAUNT.bin"
}