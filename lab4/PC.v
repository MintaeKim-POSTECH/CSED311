`include "macro.v"

module PC (PC_cur, PC_next, reset_n, clk);
	output reg [`WORD_SIZE-1:0] PC_cur;
	input [`WORD_SIZE-1:0] PC_next;
	input reset_n, clk;

	initial begin
		PC_cur = -1;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			// $display ("CPU-RESET cur: %d", PC_cur);
			PC_cur <= -1;
		end
		else begin
			// $display ("CPU-CLK cur: %d, next: %d", PC_cur, PC_next);
			PC_cur <= PC_next;
		end
	end

endmodule
