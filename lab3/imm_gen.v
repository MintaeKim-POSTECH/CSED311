`include "opcodes.v"
module imm_generator (before, extended);
	input [7:0] before;
	output wire [`WORD_SIZE-1:0] extended;

	// TODO: Sign Extend
	assign extended[7:0]=before[7:0];
	assign extended[`WORD_SIZE-1:8]= before[7]? 8'b11111111 : 0;

endmodule
