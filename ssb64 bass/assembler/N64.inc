macro asciiz(string) {
    db {string}, 0x00
}

//=============
// N64 Include
//=============
// N64 MIPS 4300 CPU Registers
constant r0(0)
constant r1(1)
constant r2(2)
constant r3(3)
constant r4(4)
constant r5(5)
constant r6(6)
constant r7(7)
constant r8(8)
constant r9(9)
constant r10(10)
constant r11(11)
constant r12(12)
constant r13(13)
constant r14(14)
constant r15(15)
constant r16(16)
constant r17(17)
constant r18(18)
constant r19(19)
constant r20(20)
constant r21(21)
constant r22(22)
constant r23(23)
constant r24(24)
constant r25(25)
constant r26(26)
constant r27(27)
constant r28(28)
constant r29(29)
constant r30(30)
constant r31(31)

constant at(1)
constant v0(2)
constant v1(3)
constant a0(4)
constant a1(5)
constant a2(6)
constant a3(7)
constant t0(8)
constant t1(9)
constant t2(10)
constant t3(11)
constant t4(12)
constant t5(13)
constant t6(14)
constant t7(15)
constant s0(16)
constant s1(17)
constant s2(18)
constant s3(19)
constant s4(20)
constant s5(21)
constant s6(22)
constant s7(23)
constant t8(24)
constant t9(25)
constant k0(26)
constant k1(27)
constant gp(28)
constant sp(29)
constant s8(30)
constant ra(31)

// N64 MIPS 4300 CP1 Floating Point Unit (FPU) Registers (COP1)
constant f0(0)
constant f1(1)
constant f2(2)
constant f3(3)
constant f4(4)
constant f5(5)
constant f6(6)
constant f7(7)
constant f8(8)
constant f9(9)
constant f10(10)
constant f11(11)
constant f12(12)
constant f13(13)
constant f14(14)
constant f15(15)
constant f16(16)
constant f17(17)
constant f18(18)
constant f19(19)
constant f20(20)
constant f21(21)
constant f22(22)
constant f23(23)
constant f24(24)
constant f25(25)
constant f26(26)
constant f27(27)
constant f28(28)
constant f29(29)
constant f30(30)
constant f31(31)

// Memory Map
constant RDRAM($A000) // $00000000..$003FFFFF RDRAM Memory 4MB ($00000000..$007FFFFF 8MB With Expansion Pak)

constant RDRAM_BASE($A3F0)       // $03F00000..$03F00027 RDRAM Base Register
constant RDRAM_DEVICE_TYPE($00)  // $03F00000..$03F00003 RDRAM: Device Type Register
constant RDRAM_DEVICE_ID($04)    // $03F00004..$03F00007 RDRAM: Device ID Register
constant RDRAM_DELAY($08)        // $03F00008..$03F0000B RDRAM: Delay Register
constant RDRAM_MODE($0C)         // $03F0000C..$03F0000F RDRAM: Mode Register
constant RDRAM_REF_INTERVAL($10) // $03F00010..$03F00013 RDRAM: Ref Interval Register
constant RDRAM_REF_ROW($14)      // $03F00014..$03F00017 RDRAM: Ref Row Register
constant RDRAM_RAS_INTERVAL($18) // $03F00018..$03F0001B RDRAM: Ras Interval Register
constant RDRAM_MIN_INTERVAL($1C) // $03F0001C..$03F0001F RDRAM: Minimum Interval Register
constant RDRAM_ADDR_SELECT($20)  // $03F00020..$03F00023 RDRAM: Address Select Register
constant RDRAM_DEVICE_MANUF($24) // $03F00024..$03F00027 RDRAM: Device Manufacturer Register

constant SP_MEM_BASE($A400) // $04000000..$04000FFF SP MEM Base Register
constant SP_DMEM($0000)     // $04000000..$04000FFF SP: RSP DMEM (4096 Bytes)
constant SP_IMEM($1000)     // $04001000..$04001FFF SP: RSP IMEM (4096 Bytes)

constant SP_BASE($A404)    // $04040000..$0404001F SP Base Register
constant SP_MEM_ADDR($00)  // $04040000..$04040003 SP: Master, SP Memory Address Register
constant SP_DRAM_ADDR($04) // $04040004..$04040007 SP: Slave, SP DRAM DMA Address Register
constant SP_RD_LEN($08)    // $04040008..$0404000B SP: Read DMA Length Register
constant SP_WR_LEN($0C)    // $0404000C..$0404000F SP: Write DMA Length Register
constant SP_STATUS($10)    // $04040010..$04040013 SP: Status Register
constant SP_DMA_FULL($14)  // $04040014..$04040017 SP: DMA Full Register
constant SP_DMA_BUSY($18)  // $04040018..$0404001B SP: DMA Busy Register
constant SP_SEMAPHORE($1C) // $0404001C..$0404001F SP: Semaphore Register

constant SP_PC_BASE($A408) // $04080000..$04080007 SP PC Base Register
constant SP_PC($00)        // $04080000..$04080003 SP: PC Register
constant SP_IBIST_REG($04) // $04080004..$04080007 SP: IMEM BIST Register

constant DPC_BASE($A410)   // $04100000..$0410001F DP Command (DPC) Base Register
constant DPC_START($00)    // $04100000..$04100003 DPC: CMD DMA Start Register
constant DPC_END($04)      // $04100004..$04100007 DPC: CMD DMA End Register
constant DPC_CURRENT($08)  // $04100008..$0410000B DPC: CMD DMA Current Register
constant DPC_STATUS($0C)   // $0410000C..$0410000F DPC: CMD Status Register
constant DPC_CLOCK($10)    // $04100010..$04100013 DPC: Clock Counter Register
constant DPC_BUFBUSY($14)  // $04100014..$04100017 DPC: Buffer Busy Counter Register
constant DPC_PIPEBUSY($18) // $04100018..$0410001B DPC: Pipe Busy Counter Register
constant DPC_TMEM($1C)     // $0410001C..$0410001F DPC: TMEM Load Counter Register

constant DPS_BASE($A420)       // $04200000..$0420000F DP Span (DPS) Base Register
constant DPS_TBIST($00)        // $04200000..$04200003 DPS: Tmem Bist Register
constant DPS_TEST_MODE($04)    // $04200004..$04200007 DPS: Span Test Mode Register
constant DPS_BUFTEST_ADDR($08) // $04200008..$0420000B DPS: Span Buffer Test Address Register
constant DPS_BUFTEST_DATA($0C) // $0420000C..$0420000F DPS: Span Buffer Test Data Register

constant MI_BASE($A430)    // $04300000..$0430000F MIPS Interface (MI) Base Register
constant MI_INIT_MODE($00) // $04300000..$04300003 MI: Init Mode Register
constant MI_VERSION($04)   // $04300004..$04300007 MI: Version Register
constant MI_INTR($08)      // $04300008..$0430000B MI: Interrupt Register
constant MI_INTR_MASK($0C) // $0430000C..$0430000F MI: Interrupt Mask Register

constant VI_BASE($A440)         // $04400000..$04400037 Video Interface (VI) Base Register
constant VI_STATUS($00)         // $04400000..$04400003 VI: Status/Control Register
constant VI_ORIGIN($04)         // $04400004..$04400007 VI: Origin Register
constant VI_WIDTH($08)          // $04400008..$0440000B VI: Width Register
constant VI_V_INTR($0C)         // $0440000C..$0440000F VI: Vertical Interrupt Register
constant VI_V_CURRENT_LINE($10) // $04400010..$04400013 VI: Current Vertical Line Register
constant VI_TIMING($14)         // $04400014..$04400017 VI: Video Timing Register
constant VI_V_SYNC($18)         // $04400018..$0440001B VI: Vertical Sync Register
constant VI_H_SYNC($1C)         // $0440001C..$0440001F VI: Horizontal Sync Register
constant VI_H_SYNC_LEAP($20)    // $04400020..$04400023 VI: Horizontal Sync Leap Register
constant VI_H_VIDEO($24)        // $04400024..$04400027 VI: Horizontal Video Register
constant VI_V_VIDEO($28)        // $04400028..$0440002B VI: Vertical Video Register
constant VI_V_BURST($2C)        // $0440002C..$0440002F VI: Vertical Burst Register
constant VI_X_SCALE($30)        // $04400030..$04400033 VI: X-Scale Register
constant VI_Y_SCALE($34)        // $04400034..$04400037 VI: Y-Scale Register

constant AI_BASE($A450)    // $04500000..$04500017 Audio Interface (AI) Base Register
constant AI_DRAM_ADDR($00) // $04500000..$04500003 AI: DRAM Address Register
constant AI_LEN($04)       // $04500004..$04500007 AI: Length Register
constant AI_CONTROL($08)   // $04500008..$0450000B AI: Control Register
constant AI_STATUS($0C)    // $0450000C..$0450000F AI: Status Register
constant AI_DACRATE($10)   // $04500010..$04500013 AI: DAC Sample Period Register
constant AI_BITRATE($14)   // $04500014..$04500017 AI: Bit Rate Register

constant PI_BASE($A460)       // $04600000..$04600033 Peripheral Interface (PI) Base Register
constant PI_DRAM_ADDR($00)    // $04600000..$04600003 PI: DRAM Address Register
constant PI_CART_ADDR($04)    // $04600004..$04600007 PI: Pbus (Cartridge) Address Register
constant PI_RD_LEN($08)       // $04600008..$0460000B PI: Read Length Register
constant PI_WR_LEN($0C)       // $0460000C..$0460000F PI: Write length register
constant PI_STATUS($10)       // $04600010..$04600013 PI: Status Register
constant PI_BSD_DOM1_LAT($14) // $04600014..$04600017 PI: Domain 1 Latency Register
constant PI_BSD_DOM1_PWD($18) // $04600018..$0460001B PI: Domain 1 Pulse Width Register
constant PI_BSD_DOM1_PGS($1C) // $0460001C..$0460001F PI: Domain 1 Page Size Register
constant PI_BSD_DOM1_RLS($20) // $04600020..$04600023 PI: Domain 1 Release Register
constant PI_BSD_DOM2_LAT($24) // $04600024..$04600027 PI: Domain 2 Latency Register
constant PI_BSD_DOM2_PWD($28) // $04600028..$0460002B PI: Domain 2 Pulse Width Register
constant PI_BSD_DOM2_PGS($2C) // $0460002C..$0460002F PI: Domain 2 Page Size Register
constant PI_BSD_DOM2_RLS($30) // $04600030..$04600033 PI: Domain 2 Release Register

constant RI_BASE($A470)       // $04700000..$0470001F RDRAM Interface (RI) Base Register
constant RI_MODE($00)         // $04700000..$04700003 RI: Mode Register
constant RI_CONFIG($04)       // $04700004..$04700007 RI: Config Register
constant RI_CURRENT_LOAD($08) // $04700008..$0470000B RI: Current Load Register
constant RI_SELECT($0C)       // $0470000C..$0470000F RI: Select Register
constant RI_REFRESH($10)      // $04700010..$04700013 RI: Refresh Register
constant RI_LATENCY($14)      // $04700014..$04700017 RI: Latency Register
constant RI_RERROR($18)       // $04700018..$0470001B RI: Read Error Register
constant RI_WERROR($1C)       // $0470001C..$0470001F RI: Write Error Register

constant SI_BASE($A480)         // $04800000..$0480001B Serial Interface (SI) Base Register
constant SI_DRAM_ADDR($00)      // $04800000..$04800003 SI: DRAM Address Register
constant SI_PIF_ADDR_RD64B($04) // $04800004..$04800007 SI: Address Read 64B Register
//*RESERVED*($08)               // $04800008..$0480000B SI: Reserved Register
//*RESERVED*($0C)               // $0480000C..$0480000F SI: Reserved Register
constant SI_PIF_ADDR_WR64B($10) // $04800010..$04800013 SI: Address Write 64B Register
//*RESERVED*($14)               // $04800014..$04800017 SI: Reserved Register
constant SI_STATUS($18)         // $04800018..$0480001B SI: Status Register

constant CART_DOM2_ADDR1($A500) // $05000000..$0507FFFF Cartridge Domain 2(Address 1) SRAM
constant CART_DOM1_ADDR1($A600) // $06000000..$07FFFFFF Cartridge Domain 1(Address 1) 64DD
constant CART_DOM2_ADDR2($A800) // $08000000..$0FFFFFFF Cartridge Domain 2(Address 2) SRAM
constant CART_DOM1_ADDR2($B000) // $10000000..$18000803 Cartridge Domain 1(Address 2) ROM

constant PIF_BASE($BFC0) // $1FC00000..$1FC007BF PIF Base Register
constant PIF_ROM($000)   // $1FC00000..$1FC007BF PIF: Boot ROM
constant PIF_RAM($7C0)   // $1FC007C0..$1FC007FF PIF: RAM (JoyChannel)
constant PIF_HWORD($7C4) // $1FC007C4..$1FC007C5 PIF: HWORD
constant PIF_XBYTE($7C6) // $1FC007C6 PIF: Analog X Byte
constant PIF_YBYTE($7C7) // $1FC007C7 PIF: Analog Y Byte

constant CART_DOM1_ADDR3($BFD0) // $1FD00000..$7FFFFFFF Cartridge Domain 1 (Address 3)

constant EXT_SYS_AD($8000) // $80000000..$FFFFFFFF External SysAD Device

constant VI_NTSC_CLOCK(48681812) // NTSC: Hz = 48.681812 MHz
constant VI_PAL_CLOCK(49656530)  // PAL:  Hz = 49.656530 MHz
constant VI_MPAL_CLOCK(48628316) // MPAL: Hz = 48.628316 MHz

macro align(size) { // Align Byte Amount
  while (pc() % {size}) {
    db 0
  }
}

macro N64_INIT() { // Initialise N64 (Stop N64 From Crashing 5 Seconds After Boot)
  lui a0,PIF_BASE // A0 = PIF Base Register ($BFC00000)
  lli t0,8
  sw t0,PIF_RAM+$3C(a0)
}

macro DMA(start, end, dest) { // DMA Data Copy Cart->DRAM: Start Cart Address, End Cart Address, Destination DRAM Address
  lui a0,PI_BASE // A0 = PI Base Register ($A4600000)
  -
    lw t0,PI_STATUS(a0) // T0 = Word From PI Status Register ($A4600010)
    andi t0,3 // AND PI Status With 3
    bnez t0,- // IF TRUE DMA Is Busy
    nop // Delay Slot

  la t0,{dest}&$7FFFFF // T0 = Aligned DRAM Physical RAM Offset ($00000000..$007FFFFF 8MB)
  sw t0,PI_DRAM_ADDR(a0) // Store RAM Offset To PI DRAM Address Register ($A4600000)
  la t0,$10000000|({start}&$3FFFFFF) // T0 = Aligned Cart Physical ROM Offset ($10000000..$13FFFFFF 64MB)
  sw t0,PI_CART_ADDR(a0) // Store ROM Offset To PI Cart Address Register ($A4600004)
  la t0,({end}-{start})-1 // T0 = Length Of DMA Transfer In Bytes - 1
  sw t0,PI_WR_LEN(a0) // Store DMA Length To PI Write Length Register ($A460000C)
}