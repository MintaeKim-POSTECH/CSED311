`define REG_BITS           2
`define OPCODE_BITS        4
`define FUNCODE_BITS       6
`define IMM_BITS           8
`define TARGET_BITS       10

`define ALU_ACTION_BITS    4 // 9 ALU Actions -> Need 4 Bits

`define WORD_SIZE         16
`define NUM_REGS           4

`define CONT_SIG_COUNT    23 // WB_SIG_COUNT + M_SIG_COUNT + EX_SIG_COUNT + ID_SIG_COUNT
`define PROPA_SIG_COUNT   19 // WB_SIG_COUNT + M_SIG_COUNT + EX_SIG_COUNT


//// WB Stage ////
`define WB_SIG_COUNT       6
// 5: isInst
`define WB_ISINST          5
// 4: isHalt
`define WB_ISHALT          4
// 3: isWWD
`define WB_ISWWD           3
// 2: RegWrite
`define WB_REGWRITE        2
// 1: MemtoReg
`define WB_MEMTOREG        1
// 0: Reg2Save
`define WB_REG2SAVE        0


//// M (MEM) Stage ////
`define M_SIG_COUNT        2
// 1: MemRead
`define M_MEMREAD          1
// 0: MemWrite
`define M_MEMWRITE         0


//// EX Stage ////
`define EX_SIG_COUNT      11
// 10-7: opcode
`define EX_OPCODE         10
// 6-1: funcode
`define EX_FUNCODE         6
// 0: ALUSrc
`define EX_ALUSRC          0


//// ID Stage ////
`define ID_SIG_COUNT       4
// 3-2: PCSrc
`define ID_PCSRC           3
// 1: RegWrite
`define ID_REGWRITE        1
// 0: RegDest
`define ID_REGDEST         0
