// Moveset.asm (Fray)

// This file adds support for reading moveset data from a pointer, and contains other moveset data
// related constants and macros.

scope Moveset {
    // @ Description
    // by default, 0x0004(t2) is an offset added to the base moveset file address
    // by default, a value of 0x80000000 is used to indicate no moveset data
    // new functionality will treat any value greater than 0x80000000 as a pointer to moveset data
    scope get_cmd_address_: {
        OS.patch_start(0x63140, 0x800E7940)
        j       get_cmd_address_
        nop
        origin  0x6316C
        base    0x800E796C
        _return:
        OS.patch_end()
        // s1 = player struct
        // v0 = moveset data address
        // t2 = action parameter struct
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
        j       _return                     // return
        nop
    }

    // @ Description
    // adds a GO_TO moveset command
    macro GO_TO(address) {
        dw 0x90000000                       // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a THROW_DATA moveset command
    macro THROW_DATA(address) {
        dw 0x30000000                       // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a CONCURRENT_STREAM moveset command
    macro CONCURRENT_STREAM(address) {
        dw 0xB8000000                       // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a SUBROUTINE moveset command
    macro SUBROUTINE(address) {
        dw 0x88000000                       // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a RANDOM SFX moveset command
    macro RANDOM_SFX(chance_fgm, type, array_size, address) {
        db 0xD6 ; db {chance_fgm} ; db {type} ; db {array_size} // command
        dw {address}                        // pointer
    }
    
    // @ Description
    // adds a GO_TO_FILE command
    macro GO_TO_FILE(offset) {
        dh 0xDB00 ; dh {offset}
    }
	
	// adds an FGM/SFX moveset command
	macro VOICE(fgm_id) {
		dh 0x4800
		dh {fgm_id}
	}
    
    // @ Description
    // Shared moveset files
    scope shared {
        insert BEAMSWORD_JAB,"moveset/BEAMSWORD_JAB.bin"
        insert BEAMSWORD_TILT,"moveset/BEAMSWORD_TILT.bin"
        insert BEAMSWORD_SMASH,"moveset/BEAMSWORD_SMASH.bin"
        insert BEAMSWORD_DASH,"moveset/BEAMSWORD_DASH.bin"
        insert BAT_JAB,"moveset/BAT_JAB.bin"
        insert BAT_TILT,"moveset/BAT_TILT.bin"
        insert BAT_SMASH,"moveset/BAT_SMASH.bin"
        insert BAT_DASH,"moveset/BAT_DASH.bin"
        insert FAN_JAB,"moveset/FAN_JAB.bin"
        insert FAN_TILT,"moveset/FAN_TILT.bin"
        insert FAN_SMASH,"moveset/FAN_SMASH.bin"
        insert FAN_DASH,"moveset/FAN_DASH.bin"
        insert STARROD_JAB,"moveset/STARROD_JAB.bin"
        insert STARROD_TILT,"moveset/STARROD_TILT.bin"
        insert STARROD_SMASH,"moveset/STARROD_SMASH.bin"
        insert STARROD_DASH,"moveset/STARROD_DASH.bin"
		insert DOWN_BOUNCE,"moveset/DOWN_BOUNCE.bin"
		insert CLIFF_CATCH,"moveset/CLIFF_CATCH.bin"
		insert CLIFF_WAIT,"moveset/CLIFF_WAIT.bin"

    }
}
