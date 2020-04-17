`include "opcodes.v"
module PC (clk, PC_next, PC_cur);
	input clk;
	input [`WORD_SIZE-1:0] PC_next;
	output reg [`WORD_SIZE-1:0] PC_cur;

	initial begin	
		PC_cur = 0;
	end
	always @(posedge clk) begin
		PC_cur <= PC_next;
	end
endmodule
