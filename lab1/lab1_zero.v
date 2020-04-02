// lab1_zero.v

// Zero

// Output 1: C; 0, 16bit binary
// Output 2: OverflowFlag; 0

module zero (output [15:0] C, output OverflowFlag);
	
	assign OverflowFlag = 1'b0;
	assign C = 16'b0000000000000000;

endmodule
