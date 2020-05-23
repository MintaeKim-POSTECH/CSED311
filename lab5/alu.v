`include "macro.v"	   

module adder (res, a, b);
	output reg [`WORD_SIZE-1:0] res;
	input [`WORD_SIZE-1:0] a, b;

	always @(*) begin
		res = (a + b);
	end
endmodule

module alu(ALUAction, result, A, B);
	input [`ALU_ACTION_BITS-1:0] ALUAction;

	output reg signed [`WORD_SIZE-1:0] result;

	input signed [`WORD_SIZE-1:0] A;
	input signed [`WORD_SIZE-1:0] B;

	initial begin
		result = 0;
	end

	always @(*) begin
		// Operation Execution
		case (ALUAction)
			0: result = (A + B);
			1: result = (A - B);
			2: result = (A & B);
			3: result = (A | B);
			4: result = ~A;
			5: result = (~A + 1);
			6: result = (A << 1);
			7: result = (A >> 1);
			8: result = (B << 8);
			9: result = A;
		endcase 
	end
endmodule
