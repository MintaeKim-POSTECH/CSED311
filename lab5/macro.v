`define REG_BITS           2
`define OPCODE_BITS        4
`define FUNCODE_BITS       6
`define IMM_BITS           8
`define TARGET_BITS       10

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

`define EX_SIG_COUNT       0
// 2: _
// 1: _
// 0: _

`define ID_SIG_COUNT       0
// 2: _
// 1: _
// 0: _
