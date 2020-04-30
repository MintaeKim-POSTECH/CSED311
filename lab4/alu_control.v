`include "macro.v"

module alu_control (inst, opcode, funcode);
	input [`WORD_SIZE-1:0] inst;
	output [3:0] opcode;
	output [5:0] funcode;

	assign opcode = inst[15:12];
	assign funcode = inst[5:0];
endmodule
