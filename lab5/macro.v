`define REG_BITS           2
`define OPCODE_BITS        4
`define FUNCODE_BITS       6
`define IMM_BITS           8
`define TARGET_BITS       10

`define ALU_ACTION_BITS    4 // 9 ALU Actions -> Need 4 Bits

`define WORD_SIZE         16
`define NUM_REGS           4

`define CONT_SIG_COUNT     0 // WB_SIG_COUNT + M_SIG_COUNT + EX_SIG_COUNT + ID_SIG_COUNT
`define PROPA_SIG_COUNT    0 // WB_SIG_COUNT + M_SIG_COUNT + EX_SIG_COUNT

`define WB_SIG_COUNT       0
// 2: _
// 1: _
// 0: _

`define M_SIG_COUNT        0
// 2: _
// 1: _
// 0: _


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
