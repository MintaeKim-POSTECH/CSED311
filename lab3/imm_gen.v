`include "opcodes.v"
module imm_generator (before, after);
	input [7:0] before;
	output reg [`WORD_SIZE-1:0] after;

	// TODO: Sign Extend
endmodule
