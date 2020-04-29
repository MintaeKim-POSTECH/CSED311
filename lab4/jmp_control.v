`include "opcodes.v"
module jmp_control (PC, target, jmp_addr);
	input [`WORD_SIZE-1:0] PC;
	input [11:0] target;
	output [`WORD_SIZE-1:0] jmp_addr;
	
	assign jmp_addr[15:12] = PC[15:12];
	assign jmp_addr[11:0] = target;
endmodule
