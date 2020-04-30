`include "macro.v"

module inst_register (inst_in, inst_out, IRWrite, reset_n, clk);
	input [`WORD_SIZE-1:0] inst_in;
	output reg [`WORD_SIZE-1:0] inst_out;
	input reset_n, clk;

	input IRWrite;
	
	integer i;
	
	initial begin
		inst_out <= 0;
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			inst_out <= 0;
		end
		else begin
			if (IRWrite) inst_out <= inst_in;
		end
	end
endmodule
