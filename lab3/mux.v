`include "opcodes.v"

module mux(control, i1, i2, result);
	input control;
	input [`WORD_SIZE-1:0] i1;
	input [`WORD_SIZE-1:0] i2;
	
	output wire [`WORD_SIZE-1:0] result;
	
	assign result =  (control == 0) ? i1 : i2;

endmodule


module mux_2bit(control, i1, i2, result);
	input control;
	input [1:0] i1;
	input [1:0] i2;
	
	output wire [1:0] result;
	
	assign result =  (control == 0) ? i1 : i2;

endmodule