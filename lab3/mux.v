`include "opcodes.v"

module mux(control, i1, i2, result);
	input control;
	input [`WORD_SIZE-1:0] i1;
	input [`WORD_SIZE-1:0] i2;
	
	output reg [`WORD_SIZE-1:0] result;

	always @(*) begin
		if (control == 0) result = i1;
		else result = i2;
	end
endmodule
