`include "opcodes.v"
module (control, i1, i2, result);
	input control;
	input [`WORD_SIZE-1:0] i1;
	input [`WORD_SIZE-1:0] i2;
	
	output [`WORD_SIZE-1:0] result;

	always (*) begin
		if (control == 1) result = i1;
		else result = i2;
	end
endmodule
