`include "opcodes.v"

module adder (a, b, res);
	input [`WORD_SIZE-1:0] a, b;
	output reg [`WORD_SIZE-1:0] res;

	always @(*) begin
		res = (a + b);
	end
endmodule
