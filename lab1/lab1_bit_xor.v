// lab1_bit_xor.v

// Bitwise XOR
// Calculation

// Output 1: C; calculation result, 16bit binary
// Output 2: OverflowFlag; 0
// Input 1: A; input, 16bit binary
// Input 2: B; input, 16bit binary
// Input 3: E; enable, 1bit binary

module bit_xor16 (output [15:0] C, output OverflowFlag,
	input [15:0] A, input [15:0] B, input E);
	
	assign OverflowFlag = 1'b0;
	assign C=(E == 1'b1)?(A ^ B):16'b0000000000000000;

endmodule
