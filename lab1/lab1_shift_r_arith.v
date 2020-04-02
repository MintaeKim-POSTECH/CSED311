// lab1_shift_r_arith.v

// Arithmetic Right Shift
// Calculation

// Output 1: C; calculation result, 16bit binary
// Output 2: OverflowFlag; 0
// Input 1: A; input, 16bit binary
// Input 2: E; enable, 1bit binary

module arith_right16 (output [15:0] C, output OverflowFlag,
   input [15:0] A, input E);

   assign OverflowFlag = 1'b0;
   assign C[15] = (E==1'b1)?A[15]:0;
   assign C[14:0] = (E==1'b1)?A[15:1]:15'b000_0000_0000_0000;

endmodule
