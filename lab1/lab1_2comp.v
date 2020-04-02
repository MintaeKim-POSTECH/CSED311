// lab1_2comp.v

// 2's Complement
// Calculation

// Output 1: C; calculation result, 16bit binary
// Output 2: OverflowFlag; 0
// Input 1: A; input, 16bit binary
// Input 2: E; enable, 1bit binary

`include "lab1_signadd.v"
`include "lab1_bit_not.v"

module complement_16 (output [15:0] C, output OverflowFlag,
	input [15:0] A, input E);
	assign OverflowFlag = 1'b0;
	wire [15:0] A_inv;
	wire o_ul1,o_ul2;
	reg E_temp=1'b1; 
	wire [15:0] one;
	assign one = 16'b0000000000000001;
	wire [15:0]sum;

	assign C=(E == 1'b1)?sum:16'b0000000000000000;

	bit_not16 inv1 (A_inv, o_ul1, A, E_temp);
	sign_adder16 add(sum, o_ul2, A_inv, one, E_temp);

endmodule
