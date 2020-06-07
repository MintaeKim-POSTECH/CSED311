`include "macro.v"

module mux16_2to1(control, result, i1, i2);
	input control;

	output reg [`WORD_SIZE-1:0] result;
	
	input [`WORD_SIZE-1:0] i1, i2;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule

module mux16_4to1(control, result, i1, i2, i3, i4);
	input [1:0] control;

	output reg [`WORD_SIZE-1:0] result;
	
	input [`WORD_SIZE-1:0] i1, i2, i3, i4;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
			2: result = i3;
			3: result = i4;
		endcase
	end
endmodule


module mux2_2to1(control, result, i1, i2);
	input control;

	output reg [1:0] result;

	input [1:0] i1, i2;		
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule

module mux2_4to1(control, result, i1, i2, i3, i4);
	input [1:0] control;

	output reg [1:0] result;
	
	input [1:0] i1, i2, i3, i4;
	
	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
			2: result = i3;
			3: result = i4;
		endcase
	end
endmodule

module mux_control_2to1 (control, result, i1, i2);
	input control;
	
	output reg [`PROPA_SIG_COUNT-1:0] result;

	input [`PROPA_SIG_COUNT-1:0] i1, i2;

	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule


module mux_mem_sig_2to1 (control, result, i1, i2);
	input control;
	
	output reg [`WB_SIG_COUNT-1:0] result;

	input [`WB_SIG_COUNT-1:0] i1, i2;

	always @(*) begin
		case (control)
			0: result = i1;
			1: result = i2;
		endcase
	end
endmodule