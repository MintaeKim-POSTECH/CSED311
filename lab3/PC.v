`include "opcodes.v"
module PC (clk, reset_n, PC_next, PC_cur);
	input clk, reset_n;
	input [`WORD_SIZE-1:0] PC_next;
	output reg [`WORD_SIZE-1:0] PC_cur;

	initial begin	
		PC_cur = -1;
	end
	always @(posedge clk) begin
		PC_cur <= PC_next;
	end

	always @(negedge reset_n) begin // Reset Activated
	end

endmodule
