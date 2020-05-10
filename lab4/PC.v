`include "macro.v"

module PC (PC_cur, PC_next, PC_update, reset_n, clk);
	output reg [`WORD_SIZE-1:0] PC_cur;
	input [`WORD_SIZE-1:0] PC_next;
	input PC_update;

	input reset_n, clk;

	initial begin
		PC_cur = 0;
	end

	always @(posedge clk) begin
		$display ("PC_cur : %h, PC_next : %h", PC_cur, PC_next);
		if (!reset_n) begin
			// $display ("CPU-RESET cur: %d", PC_cur);
			PC_cur <= 0;
		end
		else begin
			if (PC_update) PC_cur <= PC_next;
		end
	end

endmodule
