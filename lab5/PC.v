`include "macro.v"

module PC (clk, reset_n, hazard, PC_cur, PC_next, PC_update);
	input reset_n, clk, hazard;
	
	output reg [`WORD_SIZE-1:0] PC_cur;
	input [`WORD_SIZE-1:0] PC_next;
	input PC_update;

	initial begin
		PC_cur = -1;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			// $display ("CPU-RESET cur: %d", PC_cur);
			PC_cur <= -1;
		end
		// TODO: Consider Hazard
		else begin
			if (PC_update) PC_cur <= PC_next;
		end
	end

endmodule
