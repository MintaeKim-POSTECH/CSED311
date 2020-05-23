`include "macro.v"

module adder (res, a, b);
	output reg [`WORD_SIZE-1:0] res;
	input [`WORD_SIZE-1:0] a, b;

	always @(*) begin
		res = (a + b);
	end
endmodule
