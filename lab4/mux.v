`include "opcodes.v"

module mux16_2to1(control, i1, i2, result);
	input control;
	input [`WORD_SIZE-1:0] i1, i2;
	
	output reg [`WORD_SIZE-1:0] result;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule

module mux16_4to1(control, i1, i2, i3, i4, result);
	input [1:0] control;
	input [`WORD_SIZE-1:0] i1, i2, i3, i4;
	
	output reg [`WORD_SIZE-1:0] result;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
			2: result = i3;
			3: result = i4;
		endcase
	end
endmodule


module mux2_2to1(control, i1, i2, result);
	input control;
	input [1:0] i1, i2;
	
	output reg [1:0] result;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule

module mux2_4to1(control, i1, i2, i3, i4, result);
	input [1:0] control;
	input [1:0] i1, i2, i3, i4;
	
	output reg [1:0] result;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
			2: result = i3;
			3: result = i4;
		endcase
	end
endmodule